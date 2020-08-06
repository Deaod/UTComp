
class NewNet_RocketFire extends UTComp_RocketFire;

var float PingDT;
var bool bUseEnhancedNetCode;

var bool bUseReplicatedInfo;
var rotator savedRot;
var vector savedVec;

var vector OldInstigatorLocation;
var Vector OldInstigatorEyePosition;
var vector OldXAxis,OldYAxis, OldZAxis;
var rotator OldAim;

var class<Projectile> FakeProjectileClass;
var FakeProjectileManager FPM;
var MutUTComp MNN;
var bool bSkipNextEffect;

const PROJ_TIMESTEP = 0.0201;
const MAX_PROJECTILE_FUDGE = 0.075;
const SLACK = 0.035;

function PlayFiring()
{
   super.PlayFiring();

   if(Level.NetMode != NM_Client || !BS_xPlayer(Level.GetLocalPlayerController()).UseNewNet())
       return;
   if(!bSkipNextEffect)
       CheckFireEffect();
   else
   {
      bSkipNextEffect=false;
      Weapon.ClientStopFire(0);
   }
}

function CheckFireEffect()
{
   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
   {
       if(class'NewNet_PRI'.default.PredictedPing - SLACK > MAX_PROJECTILE_FUDGE)
       {
           OldInstigatorLocation = Instigator.Location;
           OldInstigatorEyePosition = Instigator.EyePosition();
           Weapon.GetViewAxes(OldXAxis,OldYAxis,OldZAxis);
           OldAim=AdjustAim(OldInstigatorLocation+OldInstigatorEyePosition, AimError);
           SetTimer(class'NewNet_PRI'.default.PredictedPing - SLACK - MAX_PROJECTILE_FUDGE, false);
       }
       else
           DoClientFireEffect();
   }
}

function Timer()
{
   DoTimedClientFireEffect();
}

function DoInstantFireEffect()
{
   CheckFireEffect();
   bSkipNextEffect=true;
}

simulated function DoTimedClientFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    //Weapon.GetViewAxes(X,Y,Z);
    X = OldXAxis;
    Y = OldXAxis;
    Z = OldXAxis;

   // StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartTrace = OldInstigatorLocation + OldInstigatorEyePosition;

   StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

   // Aim = AdjustAim(StartProj, AimError);
     Aim = OldAim;
    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            if(FPM==None)
                FindFPM();
            if(FPM.AllowFakeProjectile(FakeProjectileClass, p))
            {
                FPM.RegisterFakeProjectile(FlakChunk(SpawnFakeProjectile(StartProj, Rotator(X >> R))), p);
            }
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnFakeProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnFakeProjectile(StartProj, Aim);
    }
}

simulated function DoClientFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));
    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnFakeProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnFakeProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnFakeProjectile(StartProj, Aim);
    }
}


simulated function projectile SpawnFakeProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = FakeSuperSpawnProjectile(Start,Dir);
    if(FPM==None)
       FindFPM();
    FPM.RegisterFakeProjectile(p);
	return p;
}

simulated function projectile FakeSuperSpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if( ProjectileClass != None )
        p = Weapon.Spawn(FakeProjectileClass,,, Start, Dir);

    if( p == none )
        return None;
    p.Damage *= DamageAtten;
    return p;
}

simulated function FindFPM()
{
    foreach Weapon.DynamicActors(class'FakeProjectileManager', FPM)
        break;
}

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    if(bUseReplicatedInfo)
        StartTrace = SavedVec;
    else
        StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;

    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    if (Other != None)
    {
        StartProj = HitLocation;
    }

    if(bUseReplicatedInfo)
    {
        Aim = SavedRot;
        bUseReplicatedInfo=false;
    }
    else
        Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
    }
}


DefaultProperties
{
    FakeProjectileClass = class'NewNet_Fake_RocketProj'
}
