//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_SuperHealthPack extends SuperHealthPack
HideDropDown
CacheExempt;

auto state Pickup
{
	function Touch( actor Other )
	{
		local Pawn P;

		if(!Other.IsA('xPawn'))
		{
            super.Touch(Other);
            return;
        }

		if ( ValidTouch(Other) )
		{
			P = Pawn(Other);
            P.GiveHealth(HealingAmount, GetHealMax(P));
            AnnouncePickup(P);
            SetRespawn();
		}
	}
}

defaultproperties

RespawnTime = 44.0
}
