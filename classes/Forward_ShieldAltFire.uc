//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_ShieldAltFire extends ShieldAltFire
HideDropDown
CacheExempt;


function Timer()
{
    if (!bIsFiring)
    {
		RampTime = 0;
        if ( !Weapon.AmmoMaxed(1) )
            Weapon.AddAmmo(0,0);
        else
            SetTimer(0, false);
    }
    else
    {
        if ( !Weapon.ConsumeAmmo(1,1) )
        {
            if (Weapon.ClientState == WS_ReadyToFire)
                Weapon.PlayIdle();
            StopFiring();
        }
        else
			RampTime += AmmoRegenTime;
    }

	SetBrightness(false);
}

DefaultProperties
{
   AmmoPerFire = 1
}
