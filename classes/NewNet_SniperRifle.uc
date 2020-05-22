
class NewNet_SniperRifle extends UTComp_SniperRifle
    HideDropDown
	CacheExempt;

struct ReplicatedRotator
{
    var int Yaw;
    var int Pitch;
};

struct ReplicatedVector
{
    var float X;
    var float Y;
    var float Z;
};

var TimeStamp T;
var MutUTComp M;

replication
{
    reliable if(Role < Role_Authority)
        NewNet_ServerStartFire;
    unreliable if(bDemoRecording)
        SpawnLGEffect;
}

function DisableNet()
{
    NewNet_SniperFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_SniperFire(FireMode[0]).PingDT = 0.00;
}

simulated function SpawnLGEffect(class<Actor> tmpHitEmitClass, vector ArcEnd, vector HitNormal, vector HitLocation)
{
    local xEmitter HitEmitter;
    hitEmitter = xEmitter(Spawn(tmpHitEmitClass,,, arcEnd, Rotator(HitNormal)));
    if ( hitEmitter != None )
	  	hitEmitter.mSpawnVecA = HitLocation;
    if(Level.NetMode!=NM_Client)
        Warn("Server should never spawn the client lightningbolt");
}

simulated function ClientStartFire(int mode)
{
    if(Level.NetMode!=NM_Client)
    {
        Super.ClientStartFire(mode);
        return;
    }

    if (mode == 1)
    {
        FireMode[mode].bIsFiring = true;
        if( Instigator.Controller.IsA( 'PlayerController' ) )
            PlayerController(Instigator.Controller).ToggleZoom();
    }
    else
    {
        if(class'BS_xPlayer'.static.UseNewNet())
            NewNet_ClientStartFire(mode);
        else
            super(Weapon).ClientStartFire(mode);
    }
}

simulated function NewNet_ClientStartFire(int mode)
{
    local ReplicatedRotator R;
    local ReplicatedVector V;
    local vector Start;
    local float stamp;
 //   local bool b;
 //   local actor A;
 //   local vector HN,HL;
 //   local ReplicatedVector V2;

    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (AltReadyToFire(mode) && StartFire(Mode) )
        {
            R.Pitch = Pawn(Owner).Controller.Rotation.Pitch;
            R.Yaw = Pawn(Owner).Controller.Rotation.Yaw;
            STart=Pawn(Owner).Location + Pawn(Owner).EyePosition();

            V.X = Start.X;
            V.Y = Start.Y;
            V.Z = Start.Z;

            if(T==None)
                foreach DynamicActors(class'TimeStamp', T)
                     break;
            Stamp = T.ClientTimeStamp;

            NewNet_SniperFire(FireMode[mode]).DoInstantFireEffect();
     /*       A = Trace(HN,HL,Start+Vector(Pawn(Owner).Controller.Rotation)*10000.0,Start,true);
            if(A!=None && A.IsA('xPawn'))
            {
                b=true;
                V2.X = A.Location.X;
                V2.Y = A.Location.Y;
                V2.Z = A.Location.Z;
            }           */

            NewNet_ServerStartFire(Mode, stamp, R, V/*, b, V2, A,HN,HL*/);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

simulated function bool AltReadyToFire(int Mode)
{
    local int alt;
    local float f;

    //There is a very slight descynchronization error on the server
    // with weapons due to differing deltatimes which accrues to a pretty big
    // error if people just hold down the button...
    // This will never cause the weapon to actually fire slower
    f = 0.015;

    if(!ReadyToFire(Mode))
        return false;

    if ( Mode == 0 )
        alt = 1;
    else
        alt = 0;

    if ( ((FireMode[alt] != FireMode[Mode]) && FireMode[alt].bModeExclusive && FireMode[alt].bIsFiring)
		|| !FireMode[Mode].AllowFire()
		|| (FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].PreFireTime - f) )
    {
        return false;
    }

	return true;
}

function NewNet_ServerStartFire(byte Mode, float ClientTimeStamp, ReplicatedRotator R, ReplicatedVector V/*, bool bBelievesHit, ReplicatedVector BelievedHLDelta, Actor A, vector HN, vector HL*/)
{
	if ( (Instigator != None) && (Instigator.Weapon != self) )
	{
		if ( Instigator.Weapon == None )
			Instigator.ServerChangedWeapon(None,self);
		else
			Instigator.Weapon.SynchronizeWeapon(self);
		return;
	}

	if(M==None)
        foreach DynamicActors(class'MutUTComp', M)
	        break;

    NewNet_SniperFire(FireMode[Mode]).PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
   // Log(PlayerController(Pawn(Owner).Controller).ExactPing);
    NewNet_SniperFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    if ( (FireMode[Mode].NextFireTime <= Level.TimeSeconds + FireMode[Mode].PreFireTime)
		&& StartFire(Mode) )
    {
        FireMode[Mode].ServerStartFireTime = Level.TimeSeconds;
        FireMode[Mode].bServerDelayStartFire = false;
        NewNet_SniperFire(FireMode[Mode]).SavedVec.X = V.X;
        NewNet_SniperFire(FireMode[Mode]).SavedVec.Y = V.Y;
        NewNet_SniperFire(FireMode[Mode]).SavedVec.Z = V.Z;
        NewNet_SniperFire(FireMode[Mode]).SavedRot.Yaw = R.Yaw;
        NewNet_SniperFire(FireMode[Mode]).SavedRot.Pitch = R.Pitch;
        NewNet_SniperFire(FireMode[Mode]).bUseReplicatedInfo=IsReasonable(NewNet_SniperFire(FireMode[Mode]).SavedVec);
   //     NewNet_SniperFire(FireMode[Mode]).bBelievesHit=bBelievesHit;
   //     NewNet_SniperFire(FireMode[Mode]).bCount=true;
   /*     NewNet_SniperFire(FireMode[Mode]).BelievedHLDelta.X = BelievedHLDelta.X;
        NewNet_SniperFire(FireMode[Mode]).BelievedHLDelta.Y = BelievedHLDelta.Y;
        NewNet_SniperFire(FireMode[Mode]).BelievedHLDelta.Z = BelievedHLDelta.Z;
        NewNet_SniperFire(FireMode[Mode]).SavedVec = Pawn(Owner).Location;
        NewNet_SniperFire(FireMode[Mode]).SavedRot = Pawn(Owner).Controller.Rotation;
    */
    }
    else if ( FireMode[Mode].AllowFire() )
    {
        FireMode[Mode].bServerDelayStartFire = true;
	}
	else
		ClientForceAmmoUpdate(Mode, AmmoAmount(Mode));
}

function bool IsReasonable(Vector V)
{
    local vector LocDiff;
    local float clErr;

    if(Owner == none || Pawn(Owner) == none)
        return true;

    LocDiff = V - (Pawn(Owner).Location + Pawn(Owner).EyePosition());
    clErr = (LocDiff dot LocDiff);

//    if(clErr > 500.0*M.AverDT)
//    PlayerController(Pawn(Owner).Controller).ClientMessage("Exceeded error"@clErr);
//    Log(ClErr@(Pawn(Owner).Velocity dot Pawn(Owner).Velocity));
    return clErr < 750.0;
}


defaultproperties
{
    FireModeClass(0) = class'NewNet_SniperFire'
    PickupClass=Class'UTCompv18.NewNet_SniperRiflePickup'
}
