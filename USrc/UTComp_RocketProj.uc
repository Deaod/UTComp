/******************************************************************************
UTPlus
Copyright (c) 2005-2006 by Wormbo

This program is free software; you can redistribute and/or modify
it under the terms of the Open Unreal Mod License version 1.1.
http://wiki.beyondunreal.com/wiki/OpenUnrealModLicense


Fix for rocket duds.
******************************************************************************/


class UTComp_RocketProj extends SeekingRocketProj;

//=============================================================================
// Variables
//=============================================================================

var vector DecalNormal;
var bool bCanHitOwner;
var int OwnerHitCountdown;


//=============================================================================
// Replication
//=============================================================================

replication
{
	unreliable if ( Role == ROLE_Authority )
		DecalNormal;
}


function Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
}

function ProcessTouch(Actor Other, vector HitLocation)
{
	if ( (Other != Instigator || bCanHitOwner) && (Projectile(Other) == None || Other.bProjTarget) )
		Explode(HitLocation, -1 * vector(Rotation));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion3',, 2.5 * TransientSoundVolume);
	if ( EffectIsRelevant(Location, false) ) {
		Spawn(class'NewExplosionA',,, HitLocation + HitNormal * 20, rotator(HitNormal));
		PC = Level.GetLocalPlayerController();
		if ( PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) < 5000 )
			Spawn(class'ExplosionCrap',,, HitLocation + HitNormal * 20, rotator(HitNormal));
	}

	BlowUp(HitLocation);
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

simulated function Timer()
{
	if (!bCanHitOwner && --OwnerHitCountdown <= 0) {
		bCanHitOwner = True;
		SetOwner(None);   // HACK: make sure non-moving owner can be hit as well
	}
	Super.Timer();
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
	OwnerHitCountdown         = 5
	bNetTemporary             = False
	bUpdateSimulatedPosition  = True
}
