
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UTComp_RocketLauncher extends RocketLauncher
    HideDropDown
    CacheExempt;

var bool bCantFire;

replication
{
reliable if( Role==ROLE_Authority )
    LockOut, UnLock;
}

simulated function LockOut()
{
    bCantFire=true;
}

simulated function UnLock()
{
    bCantFire=false;
}

simulated function bool ReadyToFire(int Mode)
{
    if(bCantFire)
        return false;
    return super.ReadyToFire(mode);
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local SeekingRocketProj Rocket;
    local bot B;

    bBreakLock = true;

    // decide if bot should be locked on
    B = Bot(Instigator.Controller);
    if ( (B != None) && (B.Skill > 2 + 5 * FRand()) && (FRand() < 0.6) && (B.Target != None)
        && (B.Target == B.Enemy) && (VSize(B.Enemy.Location - B.Pawn.Location) > 2000 + 2000 * FRand())
        && (Level.TimeSeconds - B.LastSeenTime < 0.4) && (Level.TimeSeconds - B.AcquireTime > 1.5) )
    {
        bLockedOn = true;
        SeekTarget = B.Enemy;
    }

    Rocket = Spawn(class'UTComp_RocketProj',,, Start, Dir);
    if (bLockedOn && SeekTarget != None)
    {
        if (Rocket != none)
            Rocket.Seeking = SeekTarget;
        if ( B != None )
        {
            bLockedOn = false;
            SeekTarget = None;
        }
    }

    return Rocket;
}

DefaultProperties
{

}
