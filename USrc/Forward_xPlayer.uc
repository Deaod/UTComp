//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_xPlayer extends BS_xPlayer;

const SHIELD_DAMAGE_MULTIPLIER = 0.2;
var int SavedShieldAmmoCount;


function Reset()
{
    super.Reset();
}

function AwardAdrenaline(float amount)
{
   return;
}


state PlayerWalking
{
	//Smooth out landing by not lowering velocity upon landing
    function bool NotifyLanded(vector HitNormal)
	{
		if (DoubleClickDir == DCLICK_Active)
		{
			DoubleClickDir = DCLICK_Done;
			ClearDoubleClick();
			Pawn.Velocity *= Vect(1.0,1.0,1.0);
		}
		else
			DoubleClickDir = DCLICK_None;

        if ( Global.NotifyLanded(HitNormal) )
			return true;

		return false;
	}

    //Reworked function to notify the server of all pressed jumps, whether or not they are double jumps
     function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
        local vector OldAccel;
        local bool OldCrouch;

		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UnrealPawn(Pawn).Dodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}

        if ( Pawn == None )
			return;
        OldAccel = Pawn.Acceleration;
        if ( Pawn.Acceleration != NewAccel )
			Pawn.Acceleration = NewAccel;
		if ( bDoubleJump && (bUpdating || Pawn.CanDoubleJump()) )
		{
            Pawn.DoDoubleJump(bUpdating);
        }
        if ( bPressedJump )
		{
            Pawn.DoJump(bUpdating);
        }
        Pawn.SetViewPitch(Rotation.Pitch);

        if ( Pawn.Physics != PHYS_Falling )
        {
            OldCrouch = Pawn.bWantsToCrouch;
            if (bDuck == 0)
                Pawn.ShouldCrouch(false);
            else if ( Pawn.bCanCrouch )
                Pawn.ShouldCrouch(true);
        }
    }
}

function AwardDamage(int Damage)
{
    local Inventory Inv;

    if(Pawn==None)
        return;

    for(Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory)
        if (Inv.IsA('ShieldGun'))
            if (!Weapon(inv).AmmoMaxed(1))
                ShieldGun(inv).AddAmmo(int(float(Damage)*SHIELD_DAMAGE_MULTIPLIER),1);
}

function ClientBecameSpecator()
{
    SavedShieldAmmoCount= 0;
}

/* replace calls fro old weapons if newnet is on */
exec function GetWeapon(class<Weapon> NewWeaponClass )
{
    if(RepInfo==None)
        foreach DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo);

    if (RepInfo.bEnableEnhancedNetCode) {
        if (NewWeaponClass == class'AssaultRifle')
            NewWeaponClass = class'Forward_NewNet_AssaultRifle';
        else if (NewWeaponClass == class'BioRifle')
            NewWeaponClass = class'Forward_NewNet_BioRifle';
        else if (NewWeaponClass == class'ClassicSniperRifle')
            NewWeaponClass = class'Forward_NewNet_SniperRifle';
        else if (NewWeaponClass == class'FlakCannon')
            NewWeaponClass = class'Forward_NewNet_FlakCannon';
        else if (NewWeaponClass == class'LinkGun')
            NewWeaponClass = class'Forward_NewNet_LinkGun';
        else if (NewWeaponClass == class'MiniGun')
            NewWeaponClass = class'Forward_NewNet_MiniGun';
        else if (NewWeaponClass == class'ONSAvril')
            NewWeaponClass = class'NewNet_ONSAvril';
        else if (NewWeaponClass == class'ONSGrenadeLauncher')
            NewWeaponClass = class'NewNet_ONSGrenadeLauncher';
        else if (NewWeaponClass == class'ONSMineLayer')
            NewWeaponClass = class'NewNet_ONSMineLayer';
        else if (NewWeaponClass == class'RocketLauncher')
            NewWeaponClass = class'Forward_NewNet_RocketLauncher';
        else if (NewWeaponClass == class'ShockRifle')
            NewWeaponClass = class'Forward_NewNet_ShockRifle';
        else if (NewWeaponClass == class'SniperRifle')
            NewWeaponClass = class'Forward_NewNet_SniperRifle';
    } else {
        if (NewWeaponClass == class'AssaultRifle')
            NewWeaponClass = class'Forward_UTComp_AssaultRifle';
        else if (NewWeaponClass == class'BioRifle')
            NewWeaponClass = class'Forward_UTComp_BioRifle';
        // else if (NewWeaponClass == class'ClassicSniperRifle')
        //     NewWeaponClass = class'Forward_UTComp_ClassicSniperRifle';
        else if (NewWeaponClass == class'FlakCannon')
            NewWeaponClass = class'Forward_UTComp_FlakCannon';
        else if (NewWeaponClass == class'LinkGun')
            NewWeaponClass = class'Forward_UTComp_LinkGun';
        else if (NewWeaponClass == class'MiniGun')
            NewWeaponClass = class'Forward_UTComp_MiniGun';
        // else if (NewWeaponClass == class'ONSAvril')
        //     NewWeaponClass = class'Forward_UTComp_ONSAvril';
        // else if (NewWeaponClass == class'ONSGrenadeLauncher')
        //     NewWeaponClass = class'Forward_UTComp_ONSGrenadeLauncher';
        // else if (NewWeaponClass == class'ONSMineLayer')
        //     NewWeaponClass = class'Forward_UTComp_ONSMineLayer';
        else if (NewWeaponClass == class'RocketLauncher')
            NewWeaponClass = class'Forward_UTComp_RocketLauncher';
        else if (NewWeaponClass == class'ShockRifle')
            NewWeaponClass = class'Forward_UTComp_ShockRifle';
        else if (NewWeaponClass == class'SniperRifle')
            NewWeaponClass = class'Forward_UTComp_SniperRifle';
    }

    super.GetWeapon(NewWeaponClass);
}


DefaultProperties
{
}
