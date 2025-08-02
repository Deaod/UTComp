
class UTComp_AssaultGrenade extends AssaultGrenade;

event ModeDoFire()
{
    local UTComp_PRI uPRI;
    if(weapon.owner.IsA('xPawn') && xPawn(Weapon.Owner).Controller!=None)
    {
        uPRI=class'UTComp_Util'.static.GetUTCompPRIFor(xPawn(Weapon.Owner).Controller);
        if(uPRI!=None)
            uPRI.NormalWepStatsAlt[12]+=1;
    }
    Super.ModeDoFire();
}

function Projectile SpawnProjectile(vector Start, rotator Dir)
{
    local Projectile g;
    local vector X, Y, Z;
    local float pawnSpeed;

    g = Weapon.Spawn(ProjectileClass, Instigator,, Start, Dir);
    if (g != None) {
        Weapon.GetViewAxes(X, Y, Z);
        pawnSpeed = X dot Instigator.Velocity;

        if ( Bot(Instigator.Controller) != None )
            g.Speed = mHoldSpeedMax;
        else
            g.Speed = mHoldSpeedMin + HoldTime * mHoldSpeedGainPerSec;
        g.Speed = FClamp(g.Speed, mHoldSpeedMin, mHoldSpeedMax);
        g.Speed = pawnSpeed + g.Speed;
        g.Velocity = g.Speed * vector(Dir);

        g.Damage *= DamageAtten;
    }
    return g;
}

defaultproperties
{
    ProjectileClass = Class'UTComp_Grenade'
}
