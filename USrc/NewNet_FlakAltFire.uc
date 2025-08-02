
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NewNet_FlakAltFire extends UTComp_FlakAltFire;

var float PingDT;
var bool bUseEnhancedNetCode;
var bool bSkipNextEffect;

var bool bUseReplicatedInfo;
var rotator savedRot;
var vector savedVec;

var class<Projectile> FakeProjectileClass;
var FakeProjectileManager FPM;

const PROJ_TIMESTEP = 0.0201;
const MAX_PROJECTILE_FUDGE = 0.075;
const SLACK = 0.035;

var vector OldInstigatorLocation;
var Vector OldInstigatorEyePosition;
var vector OldXAxis,OldYAxis, OldZAxis;
var rotator OldAim;

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
   // Weapon.GetViewAxes(X,Y,Z);
    X = OldXaxis;
    Y = OldXaxis;
    Z = OldXaxis;

  //  StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
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

function DoClientFireEffect()
{
   super.DoFireEffect();
}

function DoInstantFireEffect()
{
/*   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
   {
       DoClientFireEffect();
       bSkipNextEffect=true;
   }    */
   CheckFireEffect();
   bSkipNextEffect=true;
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    local rotator NewDir, outDir;
    local float f,g;
    local vector End, HitLocation, HitNormal, VZ;
    local actor Other;

    if(Level.NetMode == NM_Client && BS_xPlayer(Level.GetLocalPlayerController()).UseNewNet())
        return SpawnFakeProjectile(Start,Dir);

    if(!bUseEnhancedNetCode)
        return super.SpawnProjectile(start,Dir);
    if( ProjectileClass != none )
    {
        if(PingDT > 0.0 && Weapon.Owner!=None)
        {
            //NewDir=Dir;
            OutDir=Dir;
            for(f=0.00; f<pingDT + PROJ_TIMESTEP; f+=PROJ_TIMESTEP)
            {
                //Make sure the last trace we do is right where we want
                //the proj to spawn if it makes it to the end
                g = Fmin(pingdt, f);
                //Where will it be after deltaF, NewDir byRef for next tick
                End = Start + NewExtrapolate(Dir, g, outDir);

             /*  if(f >= pingDT)
                   End = Start + Extrapolate(Dir, speed, (pingDT-f+PROJ_TIMESTEP),g==0.0);
               else
                   End = Start + Extrapolate(Dir, speed, PROJ_TIMESTEP,g==0.0);
             */
                //Put pawns there
                TimeTravel(pingdt - g);
                //Trace between the start and extrapolated end
                Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);
                if(Other!=None)
                {
                    break;
                }
                //repeat
               // Start=End;
             }

           UnTimeTravel();

           if(Other!=None && Other.IsA('PawnCollisionCopy'))
           {
                 HitLocation = HitLocation + PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
                 Other=PawnCollisionCopy(Other).CopiedPawn;
           }

           VZ.Z = ProjectileClass.default.TossZ;
           NewDir =  rotator(vector(OutDir)*ProjectileClass.default.speed - VZ);

           if(Other == none)
               p = Weapon.Spawn(ProjectileClass,,, End, NewDir);
           else
               p = Weapon.Spawn(ProjectileClass,,, HitLocation - vector(dir)*20.0, NewDir);
        }
        else
            p = Weapon.Spawn(ProjectileClass,,, Start, Dir);
    }

    if( p == None )
        return None;

    p.Damage *= DamageAtten;
    return p;
}



function vector NewExtrapolate(rotator Dir, float dF, out rotator outDir)
{
    local vector V;
    local vector Pos;

   // if(vSize(vector(Dir)) != 1.0)
   //    log(vSize(vector(Dir)));

    V = vector(Dir)*ProjectileClass.default.speed;
    V.Z += ProjectileClass.default.TossZ;

    Pos = V*dF + 0.5*square(dF)*Weapon.Owner.PhysicsVolume.Gravity;
    OutDir = rotator(V + dF*Weapon.Owner.PhysicsVolume.Gravity);
    return Pos;
}

function vector Extrapolate(out rotator Dir, out float speed, float dF, bool bTossZ)
{
    local rotator OldDir;
    local Vector VZ;

    OldDir=Dir;

    if(bTossZ)
    {
        VZ.Z = ProjectileClass.default.TossZ;
        Dir = rotator(vector(OldDir)*ProjectileClass.default.speed + VZ + Weapon.Owner.PhysicsVolume.Gravity*dF);
        Speed = vSize(vector(OldDir)*ProjectileClass.default.speed + VZ + Weapon.Owner.PhysicsVolume.Gravity*dF);
    }
    else
    {
        Dir = rotator(vector(OldDir)*Speed + Weapon.Owner.PhysicsVolume.Gravity*dF);
    }
    if(bTossZ)
    {
        return ((vector(OldDir)*ProjectileClass.default.speed)*dF + 0.5*Square(dF)*Weapon.Owner.PhysicsVolume.Gravity);
    }
     else
        return (vector(OldDir)*Speed*dF + 0.5*Square(dF)*Weapon.Owner.PhysicsVolume.Gravity);
}

// We need to do 2 traces. First, one that ignores the things which have already been copied
// and a second one that looks only for things that are copied
function Actor DoTimeTravelTrace(Out vector Hitlocation, out vector HitNormal, vector End, vector Start)
{
    local Actor Other;
    local bool bFoundPCC;
    local vector NewEnd, WorldHitNormal,WorldHitLocation;
    local vector PCCHitNormal,PCCHitLocation;
    local PawnCollisionCopy PCC, returnPCC;

    //First, lets set the extent of our trace.  End once we hit an actor which won't
    //be checked by an unlagged copy.
    foreach Weapon.TraceActors(class'Actor', Other,WorldHitLocation,WorldHitNormal,End,Start)
    {
       if((Other.bBlockActors || Other.bProjTarget || Other.bWorldGeometry) && !class'MutUTComp'.static.IsPredicted(Other))
       {
           break;
       }
       Other=None;
    }
    if(Other!=None)
        NewEnd=WorldHitlocation;
    else
        NewEnd=End;

    //Now, lets see if we run into any copies, we stop at the location
    //determined by the previous trace.
    foreach Weapon.TraceActors(class'PawnCollisionCopy', PCC, PCCHitLocation, PCCHitNormal, NewEnd,Start)
    {
        if(PCC!=None && PCC.CopiedPawn!=None && PCC.CopiedPawn!=Instigator)
        {
            bFoundPCC=True;
            returnPCC=PCC;
            break;
        }
    }

    // Give back the corresponding info depending on whether or not
    // we found a copy

    if(bFoundPCC)
    {
        HitLocation = PCCHitLocation;
        HitNormal = PCCHitNormal;
        return returnPCC;
    }
    else
    {
        HitLocation = WorldHitLocation;
        HitNormal = WorldHitNormal;
        return Other;
    }
}

function TimeTravel(float delta)
{
    local PawnCollisionCopy PCC;

    if(NewNet_FlakCannon(Weapon).M == none)
        foreach Weapon.DynamicActors(class'MutUTComp',NewNet_FlakCannon(Weapon).M)
            break;

    for(PCC = NewNet_FlakCannon(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TimeTravelPawn(Delta);
}

function UnTimeTravel()
{
    local PawnCollisionCopy PCC;
    //Now, lets turn off the old hits
    for(PCC = NewNet_FlakCannon(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TurnOffCollision();
}

simulated function projectile SpawnFakeProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if(FPM==None)
        FindFPM();
    if(FPM.AllowFakeProjectile(FakeProjectileClass))
    {
        p = Weapon.Spawn(FakeProjectileClass,Weapon.Owner,, Start, Dir);
    }
    if( p == none )
        return None;
    FPM.RegisterFakeProjectile(p);
    return p;
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

simulated function FindFPM()
{
    foreach Weapon.DynamicActors(class'FakeProjectileManager', FPM)
        break;
}

defaultproperties
{
    FakeProjectileClass=Class'NewNet_Fake_FlakShell'
    ProjectileClass=Class'NewNet_FlakShell'
}
