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
   local Inventory INV;
   if(Pawn==None)
       return;
   for(Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory)
   {
      if(Inv.IsA('ShieldGun'))
      {
          if(!Weapon(inv).AmmoMaxed(1))
             ShieldGun(inv).AddAmmo(Damage*SHIELD_DAMAGE_MULTIPLIER,1);
      }
   }
}

function ClientBecameSpecator()
{
    SavedShieldAmmoCount= 0;
}


DefaultProperties
{
}
