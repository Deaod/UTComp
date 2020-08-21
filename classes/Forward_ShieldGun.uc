//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_ShieldGun extends UTComp_Shieldgun
HideDropDown
CacheExempt;


const SHIELD_DAMAGE_MULTIPLIER = 1.0;
const SHIELD_USE_MULTIPLIER = 0.1;

function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation,
						         out Vector Momentum, class<DamageType> DamageType)
{
    local int Drain;
	local vector Reflect;
    local vector HitNormal;
    local float DamageMax;

	DamageMax = 100.0;
	if ( DamageType == class'Fell' )
		DamageMax = 20.0;
    else if( !DamageType.default.bArmorStops || (DamageType == class'DamTypeShieldImpact' && InstigatedBy == Instigator) )
        return;

    if ( CheckReflect(HitLocation, HitNormal, 0) )
    {
        Drain = Min( AmmoAmount(1)*2, Damage );
		Drain = Min(Drain,DamageMax);
	    Reflect = MirrorVectorByNormal( Normal(Location - HitLocation), Vector(Instigator.Rotation) );
        Damage -= Drain;
        Momentum *= 1.25;
    	ConsumeAmmo(1,Drain/2);
        DoReflectEffect(Drain/2);
    }
}


DefaultProperties
{
    FireModeClass(1)=Class'Forward_ShieldAltFire'
}
