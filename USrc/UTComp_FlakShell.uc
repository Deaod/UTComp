/******************************************************************************
UTPlus
Copyright (c) 2005-2006 by Wormbo

This program is free software; you can redistribute and/or modify
it under the terms of the Open Unreal Mod License version 1.1.
http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense


Fix for flak shell.
******************************************************************************/


class UTComp_FlakShell extends FlakShell;


//=============================================================================
// Variables
//=============================================================================

var vector DecalNormal;
var bool bCanHitOwner;


//=============================================================================
// Replication
//=============================================================================

replication
{
  unreliable if ( Role == ROLE_Authority )
    DecalNormal;
}


simulated function PostBeginPlay()
{
  SetTimer(0.5, False);
  Super.PostBeginPlay();
}

function Timer()
{
  // only required to run on the server
  bCanHitOwner = True;
  SetOwner(None);   // HACK: make sure non-moving owner can be hit as well
}

function ProcessTouch(Actor Other, vector HitLocation)
{
  if (Other != Instigator || bCanHitOwner) {
    SpawnEffects(HitLocation, -1 * Normal(Velocity));
    Explode(HitLocation, Normal(HitLocation - Other.Location));
  }
}

function Landed(vector HitNormal)
{
  Super.Landed(HitNormal);
}

function Explode(vector HitLocation, vector HitNormal)
{
  local vector Start;
  local rotator Rot;
  local int i;

  Start = Location + 10 * HitNormal;
  if ( Level.NetMode != NM_Client ) {
    HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
    for (i = 0; i < 6; i++) {
      Rot = Rotation;
      Rot.Yaw += RandRange(-16000, 16000);
      Rot.Pitch += RandRange(-16000, 16000);
      Rot.Roll += RandRange(-16000, 16000);
      Spawn(class'FlakChunk', Instigator, '', Start, Rot);
    }
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
  if (Level.NetMode == NM_Client) {
    SpawnEffects(Location, DecalNormal);
    Destroy();
  }
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
  bNetTemporary = False
}
