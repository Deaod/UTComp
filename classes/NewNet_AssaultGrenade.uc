
class NewNet_AssaultGrenade extends UTComp_AssaultGrenade;

var float PingDT;
var bool bUseEnhancedNetCode;

const PROJ_TIMESTEP = 0.0201;
const MAX_PROJECTILE_FUDGE = 0.0750;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Grenade g;
    local vector X, Y, Z;
    local float pawnSpeed;
    local vector Velocity;
    local float Speed;

    local rotator NewDir, outDir;
    local actor Other;
    local vector HitNormal,HitLocation,End;
    local float h,f;

    if(!bUseEnhancedNetCode)
    {
        return super.SpawnProjectile(start,dir);
    }

    Weapon.GetViewAxes(X,Y,Z);
    pawnSpeed = X dot Instigator.Velocity;
    if ( Bot(Instigator.Controller) != None )
		Speed = mHoldSpeedMax;
	else
		Speed = mHoldSpeedMin + HoldTime*mHoldSpeedGainPerSec;
	Speed = FClamp(Speed, mHoldSpeedMin, mHoldSpeedMax);
    Speed = pawnSpeed + Speed;
    Velocity = Speed * Vector(Dir);

    if(PingDT > 0.0 && Weapon.Owner!=None)
    {
            OutDir=Dir;
            for(f=0.00; f<pingDT + PROJ_TIMESTEP; f+=PROJ_TIMESTEP)
            {
                //Make sure the last trace we do is right where we want
                //the proj to spawn if it makes it to the end
                h = Fmin(pingdt, f);
                //Where will it be after deltaF, NewDir byRef for next tick

                End = Start + NewExtrapolate(Dir, h, outDir);
               /* if(f > pingDT)
                   End = Start + Extrapolate(Dir, (pingDT-f+PROJ_TIMESTEP),Speed);
                else
                   End = Start + Extrapolate(Dir, PROJ_TIMESTEP,Speed);
               */
                //Put pawns there
                TimeTravel(pingdt - h);
                //Trace between the start and extrapolated end
                Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);
                if(Other!=None)
                {
                    break;
                }
                //repeat
             //   Start=End;
           }
           UnTimeTravel();

           if(Other!=None && Other.IsA('PawnCollisionCopy'))
           {
                 HitLocation = HitLocation + PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
                 Other=PawnCollisionCopy(Other).CopiedPawn;
           }

           Velocity = Speed * Vector(OutDir);
           if(Other == none)
               g = Grenade(Weapon.Spawn(ProjectileClass,,, End, NewDir));
           else
               g = Grenade(Weapon.Spawn(ProjectileClass,,, HitLocation - Vector(Newdir)*16.0, NewDir));
    }
    else
        g = Grenade(Weapon.Spawn(ProjectileClass, instigator,, Start, Dir));


    if(g==None)
        return none;

    g.Speed = Speed;
    g.Velocity = Velocity;
    g.Damage *= DamageAtten;

    return g;
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

function vector Extrapolate(out rotator Dir, float dF, float Speed)
{
    local rotator OldDir;
    OldDir=Dir;

    Dir = rotator(vector(OldDir)*speed + Weapon.Owner.PhysicsVolume.Gravity*dF);

    return vector(OldDir)*speed*dF + 0.5*Square(dF)*Weapon.Owner.PhysicsVolume.Gravity;
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

    if(NewNet_AssaultRifle(Weapon).M == none)
        foreach Weapon.DynamicActors(class'MutUTComp',NewNet_AssaultRifle(Weapon).M)
            break;

    for(PCC = NewNet_AssaultRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TimeTravelPawn(Delta);
}

function UnTimeTravel()
{
    local PawnCollisionCopy PCC;
    //Now, lets turn off the old hits
    for(PCC = NewNet_AssaultRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TurnOffCollision();
}


defaultproperties
{
}
