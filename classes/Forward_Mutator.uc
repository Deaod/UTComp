//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_Mutator extends Mutator;

var bool bEnhancedNetCodeEnabledAtStartOfMap;
var bool bEnableDoubleDamage;

var bool bWeaponsChecked;
var array<string> sWeaponsToGive;

var string WeaponClassNames[12];
var string AltWeaponClassNames[12];
var string ReplacedWeaponClassNames[12];
var string NewNetWeaponClassNames[12];
var string UTCompWeaponClassNames[12];

simulated function PreBeginPlay()
{
    SetupWeaponTweaks();
    bEnhancedNetCodeEnabledAtStartOfMap = class'MutUTComp'.default.bEnableEnhancedNetCode;
    bEnableDoubleDamage = class'MutUTComp'.default.bEnableDoubleDamage;

    super.PreBeginPlay();
}

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('AdrenalinePickup') )
	{
    	bSuperRelevant = 0;
		return false;
    }
    if ( Controller(Other) != None )
		Controller(Other).bAdrenalineEnabled = false;
	return Super.IsRelevant(Other, bSuperRelevant);
}

function SetupWeaponTweaks()
{
 // class'SniperFire'.default.SecDamageMult=0.0;
 // class'UTComp_SniperFire'.default.SecDamageMult=0.0;
 //  class'NewNet_SniperFire'.default.SecDamageMult=0.0;


  // class'RocketProj'.default.DamageRadius=265.0;
  // class'RocketProj'.default.speed=2000;
  // class'RocketProj'.default.maxspeed=2000;
  // class'RocketProj'.default.MomentumTransfer=100000;
  // class'RocketProj'.default.Damage=60;

  // class'NewNet_RocketProj'.default.DamageRadius=265.0;
  //class'NewNet_RocketProj'.default.speed=2000;
  // class'NewNet_RocketProj'.default.maxspeed=2000;
  // class'NewNet_RocketProj'.default.MomentumTransfer=100000;
  // class'NewNet_RocketProj'.default.Damage=65;

 //  class'NewNet_Fake_RocketProj'.default.DamageRadius=265.0;
 //  class'NewNet_Fake_RocketProj'.default.speed=2000;
 // class'NewNet_Fake_RocketProj'.default.maxspeed=2000;
 //  class'NewNet_Fake_RocketProj'.default.MomentumTransfer=100000;
 //  class'NewNet_Fake_RocketProj'.default.Damage=65;

 /*  class'FlakChunk'.default.speed=3500;
   class'FlakChunk'.default.maxspeed=3500;
   class'FlakChunk'.default.MomentumTransfer=20000;

   class'NewNet_FlakChunk'.default.speed=3500;
   class'NewNet_FlakChunk'.default.maxspeed=3500;
   class'NewNet_FlakChunk'.default.MomentumTransfer=20000;

   class'NewNet_Fake_FlakChunk'.default.speed=3500;
   class'NewNet_Fake_FlakChunk'.default.maxspeed=3500;
   class'NewNet_Fake_FlakChunk'.default.MomentumTransfer=20000;        */

  /* class'FlakShell'.default.speed=1450.000000;
   class'FlakShell'.default.maxspeed=1450.000000;
   class'FlakShell'.default.MomentumTransfer=100000;

   class'NewNet_FlakShell'.default.speed=1450.000000;
   class'NewNet_FlakShell'.default.maxspeed=1450.000000;
   class'NewNet_FlakShell'.default.MomentumTransfer=100000;

   class'NewNet_Fake_FlakShell'.default.speed=1450.000000;
   class'NewNet_Fake_FlakShell'.default.maxspeed=1450.000000;
   class'NewNet_Fake_FlakShell'.default.MomentumTransfer=100000;     */

  /* class'ShockBeamFire'.default.FireRate=0.55;
   class'ShockBeamFire'.default.DamageMin=35;
   class'ShockBeamFire'.default.DamageMax=35;
   class'ShockBeamFire'.default.Momentum=35000;

   class'NewNet_ShockBeamFire'.default.FireRate=0.55;
   class'NewNet_ShockBeamFire'.default.DamageMin=35;
   class'NewNet_ShockBeamFire'.default.DamageMax=35;
   class'NewNet_ShockBeamFire'.default.Momentum=35000;

   class'UTComp_ShockBeamFire'.default.FireRate=0.55;
   class'UTComp_ShockBeamFire'.default.DamageMin=35;
   class'UTComp_ShockBeamFire'.default.DamageMax=35;
   class'UTComp_ShockBeamFire'.default.Momentum=35000;       */


 //  class'ShockProjFire'.default.fireRate=0.45;
 /*  class'ShockProjectile'.default.speed=1500;
   class'ShockProjectile'.default.maxspeed=1500;
   class'ShockProjectile'.default.Damage=30;       */

 //  class'NewNet_ShockProjFire'.default.fireRate=0.45;
/*   class'NewNet_ShockProjectile'.default.speed=1500;
   class'NewNet_ShockProjectile'.default.maxspeed=1500;
   class'NewNet_ShockProjectile'.default.Damage=30;
   class'NewNet_Fake_ShockProjectile'.default.speed=1500;
   class'NewNet_Fake_ShockProjectile'.default.maxspeed=1500;
   class'NewNet_Fake_ShockProjectile'.default.Damage=30;           */


//   class'UTComp_ShockProjFire'.default.fireRate=0.45;
 /*  class'UTComp_ShockProjectile'.default.speed=1500;
   class'UTComp_ShockProjectile'.default.maxspeed=1500;
   class'UTComp_ShockProjectile'.default.Damage=30;         */

 //  class'LinkProjectile'.default.Damage = 40;

//   class'NewNet_LinkProjectile'.default.Damage = 40;

 /*  class'MinigunFire'.default.DamageMin=8;
   class'MinigunFire'.default.DamageMax=9;

   class'NewNet_MinigunFire'.default.DamageMin=8;
   class'NewNet_MinigunFire'.default.DamageMax=9;

   class'UTComp_MinigunFire'.default.DamageMin=8;
   class'UTComp_MinigunFire'.default.DamageMax=9;        */

 /*  class'MinigunAltFire'.default.DamageMin=16;
   class'MinigunAltFire'.default.DamageMax=18;

   class'NewNet_MinigunAltFire'.default.DamageMin=16;
   class'NewNet_MinigunAltFire'.default.DamageMax=18;

   class'UTComp_MinigunAltFire'.default.DamageMin=16;
   class'UTComp_MinigunAltFire'.default.DamageMax=18;      */

/*   class'LinkFire'.default.Damage=15;
   class'LinkFire'.default.MomentumTransfer=6000.0;

   class'NewNet_LinkFire'.default.Damage=15;
   class'NewNet_LinkFire'.default.MomentumTransfer=6000.0;

   class'UTComp_LinkFire'.default.Damage=15;
   class'UTComp_LinkFire'.default.MomentumTransfer=6000.0;      */

   class'ShieldAmmo'.default.InitialAmount = 25;
   class'AssaultAmmo'.default.InitialAmount = 200;
   class'BioAmmo'.default.InitialAmount = 10;
   class'MinigunAmmo'.default.InitialAmount = 50;
   class'ShockAmmo'.default.InitialAmount = 7;
   class'LinkAmmo'.default.InitialAmount = 40;
   class'RocketAmmo'.default.InitialAmount = 4;
   class'FlakAmmo'.default.InitialAmount = 4;
   class'SniperAmmo'.default.InitialAmount = 4;

   class'UDamageCharger'.default.Spawnheight=37.5;

   class'BioGlob'.default.Damage = 15;
   class'NewNet_BioGlob'.default.damage=15;
}


function PostBeginPlay()
{
    local Forward_GameRules G;

    super.PostBeginPlay();

	G = spawn(class'Forward_GameRules');
    if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else
		Level.Game.GameRulesModifiers.AddGameRules(G);

    Level.Game.DefaultPlayerClassName=string(class'Forward_Pawn');
    Level.Game.PlayerControllerClassName=string(class'Forward_xPlayer');
}

function ModifyPlayer(Pawn Other)
{
    local int i;

    if(xPawn(Other)!=None)
		xPawn(Other).bCanBoostDodge = true;


    if(!Level.Game.IsA('UTComp_ClanArena'))
    {
        if(!bWeaponsChecked)
            FindWhatWeaponsToGive();
        for(i=0; i<sWeaponsToGive.Length; i++)
            Other.CreateInventory(sWeaponsToGive[i]);
    }

    if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

function FindWhatWeaponsToGive()
{
    local WeaponLocker WL;
    local WeaponPickup WP;
    local string s;
    local int i;
    local int j;
    local bool bFound;

    //search, and if it isn't already in the array
    //of weapons to give, add it.
    foreach AllActors(class'WeaponLocker', WL)
    {
        for(j=0; j<WL.Weapons.Length; j++)
        {
            s=string(WL.Weapons[j].WeaponClass);
            for(i=0; i<sWeaponsToGive.Length; i++)
            {
                if(s~=sWeaponsToGive[i])
                    bFound=True;
            }
            if(s~="XWeapons.Redeemer" || s~="OnslaughtFull.ONSPainter" || s~="XWeapons.Painter")
                ;
            else if(!bFound)
                sWeaponsToGive[sWeaponsToGive.Length]=s;
            bFound=False;
        }
    }

    foreach DynamicActors(class'WeaponPickup', WP)
    {
        s=string(WP.InventoryType);
        for(i=0; i<sWeaponsToGive.Length; i++)
        {
            if(s~=sWeaponsToGive[i])
                bFound=True;
        }
            if(s~="XWeapons.Redeemer" || s~="OnslaughtFull.ONSPainter" || s~="XWeapons.Painter")
                ;
            else if(!bFound)
                sWeaponsToGive[sWeaponsToGive.Length]=s;
            bFound=False;
    }
    bWeaponsChecked=True;
}




function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
 //  local int x, i;
//   local WeaponLocker L;
   bSuperRelevant=0;

  /* if(bEnhancedNetCodeEnabledAtStartOfMap)
   {
        if (xWeaponBase(Other) != None)
    	{
	    	for (x = 0; x < ArrayCount(ReplacedWeaponClasses); x++)
	    		if (xWeaponBase(Other).WeaponType == ReplacedWeaponClasses[x])
	    		{
                	xWeaponBase(Other).WeaponType = WeaponClasses[x];
                 }
        }
        else if (WeaponPickup(Other) != None)
    	{
             for (x = 0; x < ArrayCount(ReplacedWeaponClasses); x++)
		    	if ( Other.Class == ReplacedWeaponPickupClasses[x])
		    	{
                    ReplaceWith(Other, WeaponPickupClassNames[x]);
                    return false;
	     		}
    	}
    	else if (WeaponLocker(Other) != None)
    	{
    		if(Level.Game.IsA('UTComp_ClanArena'))
                L.GotoState('Disabled');
            L = WeaponLocker(Other);
    		for (x = 0; x < ArrayCount(ReplacedWeaponClasses); x++)
    			for (i = 0; i < L.Weapons.Length; i++)
    				if (L.Weapons[i].WeaponClass == ReplacedWeaponClasses[x])
    					L.Weapons[i].WeaponClass = WeaponClasses[x];
    		return true;
    	}
	}
	else
	{
        if (xWeaponBase(Other) != None)
    	{
	    	for (x = 0; x < ArrayCount(ReplacedWeaponClasses); x++)
	    		if (xWeaponBase(Other).WeaponType == ReplacedWeaponClasses[x])
	    		{
                	xWeaponBase(Other).WeaponType = AltWeaponClasses[x];
                 }
        }
        else if (WeaponPickup(Other) != None)
    	{
             for (x = 0; x < ArrayCount(ReplacedWeaponClasses); x++)
		    	if ( Other.Class == ReplacedWeaponPickupClasses[x])
		    	{
                    ReplaceWith(Other, AltWeaponPickupClassNames[x]);
                    return false;
	     		}
    	}
    	else if (WeaponLocker(Other) != None)
    	{
    		if(Level.Game.IsA('UTComp_ClanArena'))
                L.GotoState('Disabled');
            L = WeaponLocker(Other);
    		for (x = 0; x < ArrayCount(ReplacedWeaponClasses); x++)
    			for (i = 0; i < L.Weapons.Length; i++)
    				if (L.Weapons[i].WeaponClass == ReplacedWeaponClasses[x])
    					L.Weapons[i].WeaponClass = AltWeaponClasses[x];
    		return true;
    	}
	}           */


    if(Other.IsA('UTAmmoPickup'))
        return false;
    else if(Other.IsA('xPickupBase'))
    {
       if(!bEnableDoubleDamage)
       {
            if(Other.IsA('UDAMAGECHARGER'))
            {
                UDamageCharger(Other).PowerUp = class'Forward_MiniSuperHealthPack';
                UDamageCharger(Other).Spawnheight=37.5;
                UDamageCharger(Other).bDelayedSpawn=false;
                return true;
            }
            else if(Other.IsA('SuperHealthCharger'))
            {
                SuperHealthCharger(Other).PowerUp = class'Forward_MiniSuperHealthPack';
                SuperHealthCharger(Other).bDelayedSpawn=false;
                return true;
            }
       }
       else
       {
          if(Other.IsA('UDAMAGECHARGER'))
          {
             UDamageCharger(Other).PowerUp = class'Forward_UDamagePack';
             UDamageCharger(Other).bDelayedspawn=false;
          }
       }
        if(Other.IsA('SuperShieldCharger'))
	    {
            SuperShieldCharger(Other).PowerUp=class'Forward_SuperShieldPack';
            SuperShieldCharger(Other).bDelayedSpawn=false;
            return true;
        }
	    else if(Other.IsA('ShieldCharger'))
	    {
            ShieldCharger(Other).PowerUp=class'Forward_ShieldPack';
            ShieldCharger(Other).bDelayedSpawn=false;
            return true;
        }
        else if(Other.IsA('SuperHealthCharger'))
        {
            SuperHealthCharger(Other).PowerUp = class'Forward_SuperHealthPack';
            SuperHealthCharger(Other).bDelayedSpawn=false;
            return true;
        }
        else if(Other.IsA('HealthCharger'))
        {
            HealthCharger(Other).PowerUp = class'Forward_HealthPack';
            return true;
        }
        else if(Other.IsA('xWeaponBase'))
        {
            if(xWeaponBase(Other).WeaponType!=None)
                xWeaponBase(Other).WeaponType.default.PickupClass.default.RespawnTime = 11;
            if(xWeaponBase(Other).Powerup !=None)
                xWeaponBase(Other).Powerup.default.RespawnTime = 11;
            if(xWeaponBase(Other).myPickup!=None)
                xWeaponBase(other).myPickup.RespawnTime = 11;
            return true;
         }
    }
    else if(Other.IsA('MiniHealthPack') && Other.Class == class'MiniHealthPack')
    {
        ReplaceWith(Other,string(class'Forward_MiniHealthPack'));
        return false;
    }
    else if(Other.IsA('HealthPack') && Other.Class == class'HealthPack')
    {
        ReplaceWith(Other,string(class'Forward_HealthPack'));
        return false;
    }
    else if(Other.IsA('SuperHealthPack') && Other.Class == class'SuperHealthPack')
    {
        ReplaceWith(Other,string(class'Forward_SuperHealthPack'));
        return false;
    }
    else if(Other.IsA('ShieldPack') && Other.Class == class'ShieldPack')
    {
        ReplaceWith(Other,string(class'Forward_ShieldPack'));
        return false;
    }
    else if(Other.IsA('SuperShieldPack') && Other.Class == class'SuperShieldPack')
    {
        ReplaceWith(Other,string(class'Forward_SuperShieldPack'));
        return false;
    }
    else if ( GameReplicationInfo(Other) != None )
	{
		GameReplicationInfo(Other).bFastWeaponSwitching = true;
		return true;
	}
	return true;
}

function string GetInventoryClassOverride(string InventoryClassName)
{
	local int i;
    // here, in mutator subclass, change InventoryClassName if desired.  For example:
	// if ( InventoryClassName == "Weapons.DorkyDefaultWeapon"
	//		InventoryClassName = "ModWeapons.SuperDisintegrator"

	for(i=0; i<ArrayCount(ReplacedWeaponClassNames); i++)
	{
	   if(InventoryClassName~=ReplacedWeaponClassNames[i])
       {
          if(bEnhancedNetCodeEnabledAtStartOfMap)
             InventoryClassName = WeaponClassNames[i];
          else
             InventoryClassName = AltweaponClassNames[i];

          break;
       }
	}
	for(i=0; i<ArrayCount(NewNetWeaponClassNames); i++)
	{
	   if(InventoryClassName~=NewNetWeaponClassNames[i])
       {
          if(bEnhancedNetCodeEnabledAtStartOfMap)
             InventoryClassName = WeaponClassNames[i];
          else
             InventoryClassName = AltweaponClassNames[i];

          break;
       }
	}
	for(i=0; i<ArrayCount(UTCompWeaponClassNames); i++)
	{
	   if(InventoryClassName~=UTCompWeaponClassNames[i])
       {
          if(bEnhancedNetCodeEnabledAtStartOfMap)
             InventoryClassName = WeaponClassNames[i];
          else
             InventoryClassName = AltweaponClassNames[i];

          break;
       }
	}

    if ( NextMutator != None )
		return NextMutator.GetInventoryClassOverride(InventoryClassName);
	return InventoryClassName;
}

function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( aClassName == "" )
		return true;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
	if ( Other.IsA('Pickup') )
	{
		if ( Pickup(Other).MyMarker != None )
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if ( Pickup(A) != None )
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
		else if ( A.IsA('Pickup') && !A.IsA('WeaponPickup') )
			Pickup(A).Respawntime = 0.0;
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return true;
	}
	return false;
}

function ServerTraveling(string URL, bool bItems)
{
   local xWeaponBase xwb;

   class'ShieldAmmo'.default.InitialAmount = 100;
   class'AssaultAmmo'.default.InitialAmount = 100;
   class'BioAmmo'.default.InitialAmount = 20;
   class'MinigunAmmo'.default.InitialAmount = 150;
   class'ShockAmmo'.default.InitialAmount = 20;
   class'LinkAmmo'.default.InitialAmount = 70;
   class'RocketAmmo'.default.InitialAmount = 12;
   class'FlakAmmo'.default.InitialAmount = 15;
   class'SniperAmmo'.default.InitialAmount = 15;

   foreach allactors(class'xWeaponBase', xwb)
   {
      if(xwb.WeaponType!=None)
          xwb.WeaponType.default.PickupClass.default.RespawnTime = 30;
      if(xwb.Powerup !=None)
          xwb.Powerup.default.RespawnTime = 30;
      if(xwb.myPickup!=None)
          xwb.myPickup.RespawnTime = 30;
   }
   class'UDamageCharger'.default.Spawnheight=60.0;
   class'BioGlob'.default.Damage = 19;
   class'NewNet_BioGlob'.default.damage=19;

    super.ServerTraveling(url, bitems);
}



DefaultProperties
{
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy

     ReplacedWeaponClassNames(0)="xWeapons.ShockRifle"
     ReplacedWeaponClassNames(1)="xWeapons.LinkGun"
     ReplacedWeaponClassNames(2)="xWeapons.MiniGun"
     ReplacedWeaponClassNames(3)="xWeapons.FlakCannon"
     ReplacedWeaponClassNames(4)="xWeapons.RocketLauncher"
     ReplacedWeaponClassNames(5)="xWeapons.SniperRifle"
     ReplacedWeaponClassNames(6)="xWeapons.BioRifle"
     ReplacedWeaponClassNames(7)="xWeapons.AssaultRifle"
     ReplacedWeaponClassNames(8)="UTClassic.ClassicSniperRifle"
     ReplacedWeaponClassNames(9)="Onslaught.ONSAVRiL"
     ReplacedWeaponClassNames(10)="Onslaught.ONSMineLayer"
     ReplacedWeaponClassNames(11)="Onslaught.ONSGrenadeLauncher"

     WeaponClassNames(0)="UTCompv18c.Forward_NewNet_ShockRifle"
     WeaponClassNames(1)="UTCompv18c.Forward_NewNet_LinkGun"
     WeaponClassNames(2)="UTCompv18c.Forward_NewNet_MiniGun"
     WeaponClassNames(3)="UTCompv18c.Forward_NewNet_FlakCannon"
     WeaponClassNames(4)="UTCompv18c.Forward_NewNet_RocketLauncher"
     WeaponClassNames(5)="UTCompv18c.Forward_NewNet_SniperRifle"
     WeaponClassNames(6)="UTCompv18c.Forward_NewNet_BioRifle"
     WeaponClassNames(7)="UTCompv18c.Forward_NewNet_AssaultRifle"
     WeaponClassNames(8)="UTCompv18c.Forward_NewNet_SniperRifle"
     WeaponClassNames(9)="UTCompv18c.NewNet_ONSAVRiL"
     WeaponClassNames(10)="UTCompv18c.NewNet_ONSMineLayer"
     WeaponClassNames(11)="UTCompv18c.NewNet_ONSGrenadeLauncher"

     AltWeaponClassNames(0)="UTCompv18c.Forward_UTComp_ShockRifle"
     AltWeaponClassNames(1)="UTCompv18c.Forward_UTComp_LinkGun"
     AltWeaponClassNames(2)="UTCompv18c.Forward_UTComp_MiniGun"
     AltWeaponClassNames(3)="UTCompv18c.Forward_UTComp_FlakCannon"
     AltWeaponClassNames(4)="UTCompv18c.Forward_UTComp_RocketLauncher"
     AltWeaponClassNames(5)="UTCompv18c.Forward_UTComp_SniperRifle"
     AltWeaponClassNames(6)="UTCompv18c.Forward_UTComp_BioRifle"
     AltWeaponClassNames(7)="UTCompv18c.Forward_UTComp_AssaultRifle"
     AltWeaponClassNames(8)="UTCompv18c.Forward_UTComp_SniperRifle"
     AltWeaponClassNames(9)="Onslaught.ONSAVRiL"
     AltWeaponClassNames(10)="Onslaught.ONSMineLayer"
     AltWeaponClassNames(11)="Onslaught.ONSGrenadeLauncher"

     NewNetWeaponClassNames(0)="UTCompv18c.NewNet_ShockRifle"
     NewNetWeaponClassNames(1)="UTCompv18c.NewNet_LinkGun"
     NewNetWeaponClassNames(2)="UTCompv18c.NewNet_MiniGun"
     NewNetWeaponClassNames(3)="UTCompv18c.NewNet_FlakCannon"
     NewNetWeaponClassNames(4)="UTCompv18c.NewNet_RocketLauncher"
     NewNetWeaponClassNames(5)="UTCompv18c.NewNet_SniperRifle"
     NewNetWeaponClassNames(6)="UTCompv18c.NewNet_BioRifle"
     NewNetWeaponClassNames(7)="UTCompv18c.NewNet_AssaultRifle"
     NewNetWeaponClassNames(8)="UTCompv18c.NewNet_ClassicSniperRifle"
     NewNetWeaponClassNames(9)="UTCompv18c.NewNet_ONSAVRiL"
     NewNetWeaponClassNames(10)="UTCompv18c.NewNet_ONSMineLayer"
     NewNetWeaponClassNames(11)="UTCompv18c.NewNet_ONSGrenadeLauncher"

     UTCompWeaponClassNames(0)="UTCompv18c.UTComp_ShockRifle"
     UTCompWeaponClassNames(1)="UTCompv18c.UTComp_LinkGun"
     UTCompWeaponClassNames(2)="UTCompv18c.UTComp_MiniGun"
     UTCompWeaponClassNames(3)="UTCompv18c.UTComp_FlakCannon"
     UTCompWeaponClassNames(4)="UTCompv18c.UTComp_RocketLauncher"
     UTCompWeaponClassNames(5)="UTCompv18c.UTComp_SniperRifle"
     UTCompWeaponClassNames(6)="UTCompv18c.UTComp_BioRifle"
     UTCompWeaponClassNames(7)="UTCompv18c.UTComp_AssaultRifle"
     UTCompWeaponClassNames(8)="UTCompv18c.UTComp_ClassicSniperRifle"
     UTCompWeaponClassNames(9)="UTCompv18c.UTComp_ONSAVRiL"
     UTCompWeaponClassNames(10)="UTCompv18c.UTComp_ONSMineLayer"
     UTCompWeaponClassNames(11)="UTCompv18c.UTComp_ONSGrenadeLauncher"


     bAddtoServerPackages=true
}
