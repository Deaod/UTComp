//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_Pawn extends UTComp_xPawn;
//==========================
// Midair Damage Variables
//==========================
const     MIDAIR_DELAY = 0.30;

var float MidAirActivateTime;
var float MidAirDamageFactor;


//==========================
// BunnyHopping Variables
//==========================
const JUMPTHRESHOLD = 0.3;
const LANDING_GRACE_PERIOD = 0.10;
const LANDING_SLOWDOWN_TIME = 0.15;
const LANDING_SLOWDOWN_FACTOR = 350;

const MIDAIR_SPEED_INCREASE = 75.0;
const MIDAIR_SPEED_INCREASE_DURATION = 0.5;
const MaxMidAirSpeed = 1150.0;


var float LastJumpTime;
var float LastLandTime;
var vector LastLandVelocity;
var float LastLandSpeed;

var float NewMidAirSpeed;

var bool bShouldJump;
var bool bAutoJump;

var float SLOPEJUMP_EXPONENT;
var float SLOPEJUMP_FACTOR;

//=====================================
//  Small Tweaks
//=====================================
const SELF_DAMAGE_MODIFIER = 0.5;
const LAND_ON_HEAD_DAMAGE = 50.0;
const SHIELD_ABSORB_FACTOR = 0.66;



//==========================================================================
// Reworked Dodge function which allows walldodges to occur regardless of whether
// or not a wall is within range
//==========================================================================
function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    local bool b;
    b=OtherDodge(DoubleClickMove);
	return b;
}

function bool OtherDodge(eDoubleClickDir DoubleClickMove)
{
    local vector X,Y,Z, Dir, cross;

	local rotator TurnRot;

    if ( bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking && Physics != PHYS_Falling) )
        return false;

	TurnRot.Yaw = Rotation.Yaw;
    GetAxes(TurnRot,X,Y,Z);

    if ( Physics == PHYS_Falling )
    {
		if ( !bCanWallDodge )
			return false;
	}
    if (DoubleClickMove == DCLICK_Forward)
    {
		Dir = X;
		Cross = Y;
	}
    else if (DoubleClickMove == DCLICK_Back)
    {
		Dir = -1 * X;
		Cross = Y;
	}
    else if (DoubleClickMove == DCLICK_Left)
    {
		Dir = -1 * Y;
		Cross = X;
	}
    else if (DoubleClickMove == DCLICK_Right)
    {
		Dir = Y;
		Cross = X;
	}
	if ( AIController(Controller) != None )
		Cross = vect(0,0,0);
	return PerformDodge(DoubleClickMove, Dir,cross);
}

function TakeFallingDamage()
{
    return;
}

//==========================================================================
//Reworked Dodge function to take into account the changing groundpseed in movement
//and remove falling damage
//==========================================================================
function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
    local float VelocityZ;
    local name Anim;

    if ( Physics == PHYS_Falling )
    {
        if (DoubleClickMove == DCLICK_Forward)
            Anim = WallDodgeAnims[0];
        else if (DoubleClickMove == DCLICK_Back)
            Anim = WallDodgeAnims[1];
        else if (DoubleClickMove == DCLICK_Left)
            Anim = WallDodgeAnims[2];
        else if (DoubleClickMove == DCLICK_Right)
            Anim = WallDodgeAnims[3];

        if ( PlayAnim(Anim, 1.0, 0.1) )
            bWaitForAnim = true;
            AnimAction = Anim;

	//	TakeFallingDamage();
        if (Velocity.Z < -DodgeSpeedZ*0.5)
			Velocity.Z += DodgeSpeedZ*0.5;
    }

    VelocityZ = Velocity.Z;
    Velocity = DodgeSpeedFactor*default.GroundSpeed*Dir + (Velocity dot Cross)*Cross;

    if ( !bCanDodgeDoubleJump )
		MultiJumpRemaining = 0;
	if ( bCanBoostDodge || (Velocity.Z < -100) )
		Velocity.Z = VelocityZ + DodgeSpeedZ;
	else
		Velocity.Z = DodgeSpeedZ;

    CurrentDir = DoubleClickMove;
    SetPhysics(PHYS_Falling);
    if(ShouldPlaySound())
        PlayOwnedSound(GetSound(EST_Dodge), SLOT_Pain, GruntVolume,,80);

    return true;
}

simulated function FootStepping(int Side)
{
    local int SurfaceNum, i;
	local actor A;
	local material FloorMat;
	local vector HL,HN,Start,End,HitLocation,HitNormal;

    SurfaceNum = 0;

    for ( i=0; i<Touching.Length; i++ )
		if ( ((PhysicsVolume(Touching[i]) != None) && PhysicsVolume(Touching[i]).bWaterVolume)
			|| (FluidSurfaceInfo(Touching[i]) != None) )
		{
		/*	if ( FRand() < 0.5 )
				PlaySound(sound'PlayerSounds.FootStepWater2', SLOT_Interact, FootstepVolume );
			else
				PlaySound(sound'PlayerSounds.FootStepWater1', SLOT_Interact, FootstepVolume );
         */
			if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.NetMode != NM_DedicatedServer)
				&& !Touching[i].TraceThisActor(HitLocation, HitNormal,Location - CollisionHeight*vect(0,0,1.1), Location) )
					Spawn(class'WaterRing',,,HitLocation,rot(16384,0,0));
			return;
		}

	if ( bIsCrouched || bIsWalking )
		return;

	if ( (Base!=None) && (!Base.IsA('LevelInfo')) && (Base.SurfaceType!=0) )
	{
		SurfaceNum = Base.SurfaceType;
	}
	else
	{
		Start = Location - Vect(0,0,1)*CollisionHeight;
		End = Start - Vect(0,0,16);
		A = Trace(hl,hn,End,Start,false,,FloorMat);
		if (FloorMat !=None)
			SurfaceNum = FloorMat.SurfaceType;
	}
//	PlaySound(SoundFootsteps[SurfaceNum], SLOT_Interact, FootstepVolume,,400 );
}

//==========================================================================
// Checks whether or not the pawn is likely to hit the ground in the pre-jump
// time.  This makes sure they won't double jump when they actually want
// to hit the ground.
//==========================================================================

simulated function bool CheckWillHitGround()
{
    local vector TraceStart,TraceEnd,HitLocation,HitNormal;
    local actor HitActor;

    if(Velocity.Z > -100)
        return false;

    TraceStart = Location - CollisionHeight*Vect(0,0,1);
    TraceEnd = TraceStart + Velocity*JUMPTHRESHOLD;
    HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false, vect(1,1,1));

    if ( (HitActor == None) || (!HitActor.bWorldGeometry && (Mover(HitActor) == None)) || HitNormal.Z < 0.7 )
             return false;
    return true;
}

//==============================================================
// The movement works as follows.
// Upon landing on the ground, the groundspeed of the player is
// increased by a maximum of 75.0.  If the player stays on the ground
// too long, the speed however decreases.  All actual acceleration
// takes place in the air.
//==============================================================

simulated function Tick(Float deltatime)
{
  super.Tick(deltaTime);

  if(Physics == Phys_Walking)
  {
      if(LastLandTime + LANDING_GRACE_PERIOD >= Level.TimeSeconds && LastLandSpeed > default.GroundSpeed)
          GroundSpeed = LastLandSpeed;
      else if(LastLandTime + LANDING_GRACE_PERIOD + LANDING_SLOWDOWN_TIME*LastLandSpeed/LANDING_SLOWDOWN_FACTOR>= Level.TimeSeconds && LastLandSpeed > default.GroundSpeed)
      {
          GroundSpeed = (LastLandSpeed-default.groundspeed)*(LastLandTime+LANDING_SLOWDOWN_TIME*LastLandSpeed/LANDING_SLOWDOWN_FACTOR+LANDING_GRACE_PERIOD-Level.TimeSeconds)/(LANDING_SLOWDOWN_TIME*LastLandSpeed/LANDING_SLOWDOWN_FACTOR)+default.GroundSpeed;
          NewMidAirSpeed = GroundSpeed;
      }
      else
      {
          GroundSpeed = default.GroundSpeed;
          NewMidAirSpeed = GroundSpeed;
      }
  }
  else if(Physics == Phys_Falling)
  {
       GroundSpeed = FMAX(NewMidAirSpeed,vSize(Velocity-vect(0,0,1)*Velocity.Z));//FCLAMP(default.GroundSpeed,MidAirSpeed, MaxMidAirSpeed);
       AirControl = default.GroundSpeed*0.250/FMAX(vSize(Velocity-vect(0,0,1)*Velocity.Z),default.GroundSpeed);
  }
  else
  {
      GroundSpeed = default.GroundSpeed;
  }


  //Perform Auto-Jump if player requested
  if(bShouldJump && LocalPC!=None && LocalPC==Controller)
  {
     LocalPC.bPressedJump=true;
     bShouldJump=false;
     bAutoJump = true;
  }
  else if(bAutoJump)
     bAutoJump=false;
}

//========================================================
// Function records various data at time of landing
// and requests an auto-jump if appropriate.
//========================================================
event Landed(vector HitNormal)
{
    super(unrealpawn).Landed( HitNormal );

    MultiJumpRemaining = MaxMultiJump;

    if ( (Health > 0) && !bHidden && (Level.TimeSeconds - SplashTime > 0.25) && ShouldPlaySound() )
        PlayOwnedSound(GetSound(EST_Land), SLOT_Interact, FMin(1,-0.3 * Velocity.Z/JumpZ));

    LastLandTime = Level.TimeSeconds;
    LastLandVelocity = Velocity;
    LastLandSpeed = vSize(Velocity-vect(0,0,1)*Velocity.Z);

    NewMidAirSpeed = FCLAMP(LastLandSpeed + MIDAIR_SPEED_INCREASE,default.groundspeed ,MaxMidAirSpeed);

    MidAirDamageFactor = 1.0;

    if(Level.TimeSeconds <= LastJumpTime)
         bShouldJump = true;
}


function bool CanDoubleJump()
{
	return ( (MultiJumpRemaining > 0) && (Physics == PHYS_Falling) );
}

//===============================================================
// Edited jump function which allows double jumping when falling
// and adds in extra height for '"Slope Jumps"
//===============================================================
function bool DoJump( bool bUpdating )
{
    // This extra jump allows a jumping or dodging pawn to jump again mid-air
    // (via thrusters). The pawn must be within +/- 100 velocity units of the
    // apex of the jump to do this special move.
    local float ExtraJumpZ;

    if ( !bUpdating && CanDoubleJump() && (Velocity.Z < 100) && IsLocallyControlled() && !CheckWillHitGround())
    {
        if ( PlayerController(Controller) != None )
			PlayerController(Controller).bDoubleJump = true;
        DoDoubleJump(bUpdating);
        MultiJumpRemaining -= 1;
        return true;
    }


    ExtraJumpZ = AdjustJumpHeight();

    if(!bAutoJump)
        LastJumpTime = Level.TimeSeconds+JUMPTHRESHOLD;

    if ( super(Pawn).DoJump(bUpdating) )
    {
        Velocity.Z+=ExtraJumpZ;

        if ( !bUpdating )
		{
        	if(ShouldPlaySound())
                PlayOwnedSound(GetSound(EST_Jump), SLOT_Pain, GruntVolume,,80);
        }
        return true;
    }
    return false;
}

function DoDoubleJump( bool bUpdating )
{
    PlayDoubleJump();

    if ( !bIsCrouched && !bWantsToCrouch )
    {
		if ( !IsLocallyControlled() || (AIController(Controller) != None) )
			MultiJumpRemaining -= 1;
        Velocity.Z = JumpZ + MultiJumpBoost;
        SetPhysics(PHYS_Falling);
        if ( !bUpdating )
	    {

           if(ShouldPlaySound())
               PlayOwnedSound(GetSound(EST_DoubleJump), SLOT_Pain, GruntVolume,,80);
        }
    }
}

//===============================================================
// Calcualtes the extra height for a "Slope Jump"
// FixMe:  Don't like the way this works on lower angles
//===============================================================
simulated function float AdjustJumpHeight()
{
     local float extra;
     extra = (1.00-Floor.Z**SLOPEJUMP_EXPONENT)*SLOPEJUMP_FACTOR*-1.0*(Velocity dot Floor);
     return FMAX(extra,0);
}

function int ShieldAbsorb( int dam )
{
   local int Absorbed;

   Absorbed = MIN(ShieldStrength,Ceil(dam*SHIELD_ABSORB_FACTOR));

   ShieldStrength-=Absorbed;

   if(Absorbed >0)
   {
        SetOverlayMaterial( ShieldHitMat, ShieldHitMatTime, false );
	    PlaySound(sound'WeaponSounds.ArmorHit', SLOT_Pain,2*TransientSoundVolume,,400);
   }
   return (dam-Absorbed);
}

//===============================================================
//  Reworked Damage function for midair-damage changes and
//  self-damage reduction
//===============================================================
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{

    local int actualDamage;
	local Controller Killer;


    if ( damagetype == None )
	{
		if ( InstigatedBy != None )
			warn("No damagetype for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);
		DamageType = class'DamageType';
	}

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if ( Health <= 0 )
		return;

	if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
		instigatedBy = DelayedDamageInstigatorController.Pawn;

	if ( (Physics == PHYS_None) && (DrivenVehicle == None) )
		SetMovementPhysics();
	if (Physics == PHYS_Walking && damageType.default.bExtraMomentumZ)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));

    //Midair Damage Calculation
    if (Physics == PHYS_Falling && MidairDamageFactor > 1.0 && Level.TimeSeconds > MidAirActivateTime)
	 {
        if(MidAirable(DamageType) )
        {    Damage *= MidairDamageFactor;
            // if(InstigatedBy!=None && InstigatedBy.Controller!=None && InstigatedBy.Controller.IsA('PlayerController'))
            //     PlayerController(Instigatedby.Controller).ClientMessage("Midair with factor"@MidAirDamageFactor);
        }
    }

	momentum = momentum/Mass;

	if (Weapon != None)
		Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	if (DrivenVehicle != None)
        	DrivenVehicle.AdjustDriverDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	if ( (InstigatedBy != None) && InstigatedBy.HasUDamage() )
		Damage *= 2;
	//Self Damage Modification
    if (InstigatedBy == self)
	    Damage *= SELF_DAMAGE_MODIFIER;

  /*  if(InstigatedBy !=None && InstigatedBy.Controller!=None && InstigatedBy.Controller.IsA('Forward_xPlayer'))
    {
        Forward_xPlayer(InstigatedBy.Controller).AwardDamageAggression(damage, damagetype, self);
    }   */

    actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

    if( DamageType.default.bArmorStops && (actualDamage > 0) )
		actualDamage = ShieldAbsorb(actualDamage);

	Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;

	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
	if ( Health <= 0 )
	{
		// pawn died
		if ( DamageType.default.bCausedByWorld && (instigatedBy == None || instigatedBy == self) && LastHitBy != None )
			Killer = LastHitBy;
		else if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		if ( Killer == None && DamageType.Default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = momentum;
		Died(Killer, damageType, HitLocation);
	/*	if(Killer !=None && Killer.IsA('Forward_xPlayer'))
        {
            Forward_xPlayer(Killer).AwardKillAggression(damagetype, self);
        }      */
	}
	else
	{
		//Calculate the midair bonus for the next hit
        if(momentum.Z > 0 && (InstigatedBy==None || (Instigatedby.GetTeamNum()==255 && InstigatedBy!=self) || InstigatedBy.GetTeamNum() != GetTeamNum()))
		{
            if(MidAirDamageFactor <= 1.0)
                MidAirActivateTime = Level.TimeSeconds + MIDAIR_DELAY;
            MidAirDamageFactor = FMax(Momentum.Z/(Momentum.Z+abs(Velocity.Z))*0.5 + 1.0, MidAirDamageFactor);
		}
        AddVelocity( momentum );

		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
		if ( instigatedBy != None && instigatedBy != self )
			LastHitBy = instigatedBy.Controller;
	}
	MakeNoise(1.0);
}

//===============================================================
//  These damagetypes will receive a bonus for midair shots
//  ToDo:  Perhaps change the multiplier on a per-weapon basis?
//===============================================================
static simulated function bool MidAirable(class<damagetype> Damagetype)
{
    if(
       Damagetype == class'XWeapons.DamTypeRocketHoming'
    || DamageType == Class'XWeapons.DamTypeFlakShell'
    || DamageType == class'XWeapons.DamTypeShockBall'
    || DamageType == class'XWeapons.DamTypeAssaultGrenade'
    || DamageType == class'XWeapons.DamTypeShockCombo'
    || DamageType == class'Onslaught.DamTypeONSAVRiLRocket'
    || DamageType == class'XWeapons.DamTypeRocket'
    || DamageType == class'XWeapons.DamTypeFlakChunk'
    || DamageType == class'XWeapons.DamTypeLinkPlasma'
    || DamageType == class'XWeapons.DamTypeBioGlob'
    )
        return true;
    return false;
}

function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
    return false;
}

singular event BaseChange()
{
	local float decorMass;

	if ( bInterpolating )
		return;
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	else if ( Pawn(Base) != None && Base != DrivenVehicle )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns )
		{
		//	if(Base.IsA('Forward_xPawn'))
         //       Base.TakeDamage( LAND_ON_HEAD_DAMAGE, Self,Location,0.5 * Velocity , class'Crushed');
          //  else
                Base.TakeDamage( LAND_ON_HEAD_DAMAGE, Self,Location,0.5 * Velocity , class'Crushed');
			JumpOffPawn();
		}
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
	}
}

function JumpOffPawn()
{
	//Velocity += (100 + CollisionRadius) * VRand();
	Velocity.Z = 800 + CollisionHeight;
	SetPhysics(PHYS_Falling);
	bNoJumpAdjust = true;
	if ( Controller != None )
		Controller.SetFall();
}

function CreateInventory(string InventoryClassName)
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;

	if(InventoryClassName ~="UTCompv18c.UTComp_ShieldGun")
	    return;

    InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		Inv = Spawn(InventoryClass);
		if( Inv != None )
		{
			Inv.GiveTo(self);
			if ( Inv != None )
				Inv.PickupFunction(self);
		}
	}
}

simulated function bool ShouldPlaySound()
{
  // if(LocalPC == none || !LocalPC.IsA('Forward_xPlayer') || LocalPC.PlayerReplicationInfo==None || LocalPC.PlayerReplicationInfo.bOnlySpectator)
 //      return true;

  // if(Controller!=None && Controller == LocalPC)
   //    return true;
  // return false;

  if(LocalPC == none)
      return false;
  return(Controller==LocalPC || LocalPC.ViewTarget==self);
}

// Add Item to this pawn's inventory.
// Returns true if successfully added, false if not.
function bool AddInventory( inventory NewItem )
{
 //   local inventory inv;

    if(FindInventoryType(NewItem.class)!=None)
        return true;

    /*if(NewItem.IsA('AssaultRifle'))
    {
        for(inv = Inventory; inv!=None; Inv=Inv.Inventory)
            if(inv.IsA('AssaultRifle'))
                return true;
    }
    else if(NewItem.IsA('BioRifle'))
    {
        for(inv = Inventory; inv!=None; Inv=Inv.Inventory)
            if(inv.IsA('BioRifle'))
                return true;
    }
        else if(NewItem.IsA('MiniGun'))
    {
        for(inv = Inventory; inv!=None; Inv=Inv.Inventory)
            if(inv.IsA('MiniGun'))
                return true;
    }
        else if(NewItem.IsA('ShockRifle'))
    {
        for(inv = Inventory; inv!=None; Inv=Inv.Inventory)
            if(inv.IsA('ShockRifle'))
                return true;
    }
        else if(NewItem.IsA('LinkGun'))
    {
        for(inv = Inventory; inv!=None; Inv=Inv.Inventory)
            if(inv.IsA('LinkGun'))
                return true;
    }
    else if(NewItem.IsA('FlakCannon'))
    {
        for(inv = Inventory; inv!=None; Inv=Inv.Inventory)
            if(inv.IsA('FlakCannon'))
                return true;
    }
    else if(NewItem.IsA('RocketLauncher'))
    {
        for(inv = Inventory; inv!=None; Inv=Inv.Inventory)
            if(inv.IsA('RocketLauncher'))
                return true;
    }
    if(NewItem.IsA('SniperRifle'))
    {
        for(inv = Inventory; inv!=None; Inv=Inv.Inventory)
            if(inv.IsA('SniperRifle'))
                return true;
    }          */
    return super.AddInventory(NewItem);
}

defaultproperties
{
     MidAirDamageFactor=1.000000
     SLOPEJUMP_EXPONENT=5.000000
     SLOPEJUMP_FACTOR=0.510000
     ShieldStrengthMax=200
     RequiredEquipment(1)="UTCompv18c.Forward_ShieldGun"
     SuperHealthMax = 200
}
