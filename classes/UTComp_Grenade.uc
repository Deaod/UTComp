/******************************************************************************
UTPlus
Copyright (c) 2005-2006 by Wormbo

This program is free software; you can redistribute and/or modify
it under the terms of the Open Unreal Mod License version 1.1.
http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense


Fix for assault grenade.
******************************************************************************/


class UTComp_Grenade extends Grenade;


//=============================================================================
// Variables
//=============================================================================

var vector DecalNormal;


//=============================================================================
// Replication
//=============================================================================

replication
{
  unreliable if ( Role == ROLE_Authority )
    DecalNormal;
}


function PostNetBeginPlay();

function Timer()
{
  Super.Timer();
}

function ProcessTouch(Actor Other, vector HitLocation)
{
  Super.ProcessTouch(Other, HitLocation);
}

simulated function HitWall(vector HitNormal, Actor Wall)
{
  local vector VNorm;
  local PlayerController PC;

  SetOwner(None);   // HACK: make sure non-moving owner can be hit as well
  bCanHitOwner = True;

  if ( Pawn(Wall) != None || GameObjective(Wall) != None ) {
    if (Level.NetMode != NM_Client)
      Explode(Location, HitNormal);
    return;
  }

  if (Role == ROLE_Authority && !bTimerSet) {
    SetTimer(ExplodeTimer, false);
    bTimerSet = true;
  }

  // Reflect off Wall w/damping
  VNorm = (Velocity dot HitNormal) * HitNormal;
  Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

  if (Level.NetMode != NM_DedicatedServer) {
    RandSpin(100000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
  }
  Speed = VSize(Velocity);

  if ( Speed < 20 ) {
    bBounce = False;
    PrePivot.Z = -1.5;
    SetPhysics(PHYS_None);
    if (Level.NetMode != NM_DedicatedServer) {
      DesiredRotation = Rotation;
      DesiredRotation.Roll = 0;
      DesiredRotation.Pitch = 0;
      SetRotation(DesiredRotation);
    }
    if ( Trail != None )
      Trail.mRegen = false; // stop the emitter from regenerating
  }
  else {
    if ( Level.NetMode != NM_DedicatedServer ) {
      if ( Speed > 250 )
        PlaySound(ImpactSound, SLOT_Misc);
      else {
        bFixedRotationDir = false;
        bRotateToDesired = true;
        DesiredRotation.Pitch = 0;
        RotationRate.Pitch = 50000;
      }
    }
    if ( !Level.bDropDetail && Level.DetailMode != DM_Low && Level.TimeSeconds - LastSparkTime > 0.5 && EffectIsRelevant(Location,false) ) {
      PC = Level.GetLocalPlayerController();
      if ( PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) < 6000 )
        Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
      LastSparkTime = Level.TimeSeconds;
    }
  }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
  BlowUp(HitLocation);
  PlaySound(sound'WeaponSounds.BExplosion3',, 2.5 * TransientSoundVolume);
  if ( EffectIsRelevant(Location,false) ) {
    Spawn(class'NewExplosionB',,, HitLocation, rot(0,0,0));
    Spawn(ExplosionDecal, self,, HitLocation, rotator(-HitNormal));
  }
  if ( Level.NetMode != NM_Client ) {
    LifeSpan = 0.1;
    bHidden = True;
    DecalNormal = HitNormal;
    SetLocation(HitLocation);
    NetUpdateTime = Level.TimeSeconds - 1;
    SetPhysics(PHYS_None);
    SetCollision(False, False, False);
    bTearOff = True;
  }
  else
    Destroy();
}

simulated function TornOff()
{
  if (Level.NetMode == NM_Client)
    Explode(Location, DecalNormal);
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
  bNetTemporary = False
  bUpdateSimulatedPosition = True
}
