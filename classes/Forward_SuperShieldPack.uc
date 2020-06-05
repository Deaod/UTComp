//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_SuperShieldPack extends SuperShieldPack
HideDropDown
CacheExempt;

auto state Pickup
{
	function Touch( actor Other )
	{
        local xPawn P;

        if(!Other.IsA('xPawn'))
        {
            super.Touch(Other);
            return;
        }
        if ( ValidTouch(Other) )
		{
			P = xPawn(Other);
            if(P.ShieldStrength <= P.ShieldStrengthMax)
            {
                P.ShieldStrength=Min(P.ShieldStrength + ShieldAmount,P.ShieldStrengthMax);
			    AnnouncePickup(P);
                SetRespawn();
            }
		}
	}
}

defaultproperties
{
    RespawnTime = 33
}
