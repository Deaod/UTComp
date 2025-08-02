//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_MiniSuperHealthPack extends Forward_HealthPack
HideDropDown
CacheExempt;

#exec exec "Classes/Forward_MiniSuperHealthPack.cmds"

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );
    L.AddPrecacheStaticMesh(  StaticMesh'MiniSuperHealth');
}

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
{
    HealingAmount=65
    StaticMesh=StaticMesh'MiniSuperHealth'
    DrawScale=0.45
     bSuperHeal=True
     MaxDesireability=2.000000
     bAmbientGlow=False
     bPredictRespawns=True
     RespawnTime=44.000000
     PickupSound=Sound'PickupSounds.LargeHealthPickup'
     PickupForce="LargeHealthPickup"
     DrawType=DT_StaticMesh
     Physics=PHYS_Rotating
     AmbientGlow=64
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     bUnlit=True
     TransientSoundRadius=450.000000
     CollisionRadius=42.000000
     RotationRate=(Yaw=2000)
}
