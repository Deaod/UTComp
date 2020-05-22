//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_GameRules extends GameRules;

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    if ( NextGameRules != None )
		Damage = NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

    if(InstigatedBy!=None && Injured!=None && InstigatedBy!=Injured && (InstigatedBy.GetTeamNum()!=Injured.GetTeamNum() || InstigatedBy.GetTeamnum()==255))
    {
        if(InstigatedBy.Controller!=None && InstigatedBy.Controller.IsA('Forward_xPlayer'))
            Forward_xPlayer(InstigatedBy.Controller).AwardDamage(damage);
    }

    return Damage;
}

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
	local inventory inv;

    if(Item.IsA('WeaponPickup'))
	{
	    for(Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory)
	        if(Inv.IsA('Weapon') && (Weapon(Inv).InventoryGroup == item.InventoryType.default.InventoryGroup) && !Weapon(inv).AmmoMaxed(0))
	        {
                Weapon(Inv).MaxOutAmmo();
	        }
	}


    if ( (NextGameRules != None) &&  NextGameRules.OverridePickupQuery(Other, item, bAllowPickup) )
		return true;
	return false;
}

defaultproperties
{

}
