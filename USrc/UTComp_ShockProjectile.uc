

class UTComp_ShockProjectile extends ShockProjectile;

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    local UTComp_PRI uPRI;
    if (EventInstigator != None && EventInstigator.Controller!=None)
        uPRI=class'UTComp_Util'.static.GetUTCompPRIFor(EventInstigator.Controller);

    if (DamageType == ComboDamageType)
    {
        Instigator = EventInstigator;
        SuperExplosion();

        if(uPRI != None)
        {
            uPRI.NormalWepStatsPrim[0]+=1;
	        uPRI.NormalWepStatsAlt[10]-=1;
	        uPRI.NormalWepStatsPrim[10]-=1;
	    }
        if( EventInstigator.Weapon != None )
        {
			EventInstigator.Weapon.ConsumeAmmo(0, ComboAmmoCost, true);
            Instigator = EventInstigator;
        }
    }
}

defaultproperties
{
}
