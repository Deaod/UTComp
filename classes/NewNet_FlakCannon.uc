
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NewNet_FlakCannon extends UTComp_FlakCannon
    HideDropDown
	CacheExempt;

const MAX_PROJECTILE_FUDGE = 0.075;
const MAX_PROJECTILE_FUDGE_ALT = 0.075;

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

var TimeStamp_Pawn T;
var MutUTComp M;

var rotator RandSeed[9];
var int RandIndex;
var float lastDT;


replication
{
    reliable if(Role < Role_Authority)
        NewNet_ServerStartFire, NewNet_OldServerStartFire;
    unreliable if(Role == Role_Authority && bNetOwner)
        RandSeed;
}

function DisableNet()
{
    NewNet_FlakFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_FlakFire(FireMode[0]).PingDT = 0.00;
    NewNet_FlakAltFire(FireMode[1]).bUseEnhancedNetCode = false;
    NewNet_FlakAltFire(FireMode[1]).PingDT = 0.00;
}

//// client only ////
simulated event ClientStartFire(int Mode)
{
    if(Level.NetMode!=NM_Client || !BS_xPlayer(Level.GetLocalPlayerController()).UseNewNet())
        super.ClientStartFire(mode);
    else
        NewNet_ClientStartFire(mode);
}

simulated event NewNet_ClientStartFire(int Mode)
{
    local ReplicatedRotator R;
    local ReplicatedVector V;
    local vector Start;
    local float stamp;

    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (AltReadyToFire(Mode) && StartFire(Mode) )
        {
            if(!ReadyToFire(Mode))
            {
                if(T==None)
                    foreach DynamicActors(class'TimeStamp_Pawn', T)
                         break;
                Stamp = T.TimeStamp;
                NewNet_OldServerStartFire(Mode,Stamp, T.dt);
                return;
            }
            if(T==None)
                foreach DynamicActors(class'TimeStamp_Pawn', T)
                     break;
            if(NewNet_FlakAltFire(FireMode[Mode])!=None)
                NewNet_FlakAltFire(FireMode[Mode]).DoInstantFireEffect();
            else if(NewNet_FlakFire(FireMode[Mode])!=None)
                NewNet_FlakFire(FireMode[Mode]).DoInstantFireEffect();
            R.Pitch = Pawn(Owner).Controller.Rotation.Pitch;
            R.Yaw = Pawn(Owner).Controller.Rotation.Yaw;
            STart=Pawn(Owner).Location + Pawn(Owner).EyePosition();

            V.X = Start.X;
            V.Y = Start.Y;
            V.Z = Start.Z;

            NewNet_ServerStartFire(mode, T.TimeStamp, T.Dt, R, V);
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

function NewNet_ServerStartFire(byte Mode, byte ClientTimeStamp, float dt, ReplicatedRotator R, ReplicatedVector V)
{
    if(M==None)
        foreach DynamicActors(class'MutUTComp', M)
	        break;

    if ( (Instigator != None) && (Instigator.Weapon != self) )
	{
		if ( Instigator.Weapon == None )
			Instigator.ServerChangedWeapon(None,self);
		else
			Instigator.Weapon.SynchronizeWeapon(self);
		return;
	}


    if(NewNet_FlakFire(FireMode[Mode])!=None)
    {
        NewNet_FlakFire(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - M.GetStamp(ClientTimeStamp)-DT + 0.5*M.AverDT, MAX_PROJECTILE_FUDGE_ALT);
        NewNet_FlakFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }
    else if(NewNet_FlakAltFire(FireMode[Mode])!=None)
    {
        NewNet_FlakAltFire(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - M.GetStamp(ClientTimeStamp)-DT + 0.5*M.AverDT, MAX_PROJECTILE_FUDGE);
        NewNet_FlakAltFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }

    if ( (FireMode[Mode].NextFireTime <= Level.TimeSeconds + FireMode[Mode].PreFireTime)
		&& StartFire(Mode) )
    {
        FireMode[Mode].ServerStartFireTime = Level.TimeSeconds;
        FireMode[Mode].bServerDelayStartFire = false;

        if(NewNet_FlakFire(FireMode[Mode])!=None)
        {
            NewNet_FlakFire(FireMode[Mode]).SavedVec.X = V.X;
            NewNet_FlakFire(FireMode[Mode]).SavedVec.Y = V.Y;
            NewNet_FlakFire(FireMode[Mode]).SavedVec.Z = V.Z;
            NewNet_FlakFire(FireMode[Mode]).SavedRot.Yaw = R.Yaw;
            NewNet_FlakFire(FireMode[Mode]).SavedRot.Pitch = R.Pitch;
            NewNet_FlakFire(FireMode[Mode]).bUseReplicatedInfo=IsReasonable(NewNet_FlakFire(FireMode[Mode]).SavedVec);
        }
        else if(NewNet_FlakAltFire(FireMode[Mode])!=None)
        {
            NewNet_FlakAltFire(FireMode[Mode]).SavedVec.X = V.X;
            NewNet_FlakAltFire(FireMode[Mode]).SavedVec.Y = V.Y;
            NewNet_FlakAltFire(FireMode[Mode]).SavedVec.Z = V.Z;
            NewNet_FlakAltFire(FireMode[Mode]).SavedRot.Yaw = R.Yaw;
            NewNet_FlakAltFire(FireMode[Mode]).SavedRot.Pitch = R.Pitch;
            NewNet_FlakAltFire(FireMode[Mode]).bUseReplicatedInfo=IsReasonable(NewNet_FlakAltFire(FireMode[Mode]).SavedVec);
        }
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
    return clErr < 1250.0;
}

function SendNewRandSeed()
{
    local rotator R;
    local int i;
    local float Spread;
    Spread = class'NewNet_FlakFire'.default.Spread;
    for(i=0; i<ArrayCount(RandSeed); i++)
    {
        R.Yaw = Spread * (FRand()-0.5);
        R.Pitch = Spread * (FRand()-0.5);
        R.Roll = Spread * (FRand()-0.5);

        RandSeed[i]=R;
    }
    RandIndex=0;
}

simulated function rotator GetRandRot()
{
    if(RandIndex > 8)
    {
        RandIndex = 0;
    }
    RandIndex++;
    return RandSeed[RandIndex-1];
}

simulated event PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    SendNewRandSeed();
}

function NewNet_OldServerStartFire(byte Mode, byte ClientTimeStamp, float dt)
{
    if(M==None)
        foreach DynamicActors(class'MutUTComp', M)
	        break;

    if(NewNet_FlakFire(FireMode[Mode])!=None)
    {
        NewNet_FlakFire(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - M.GetStamp(ClientTimeStamp)-DT + 0.5*M.AverDT, MAX_PROJECTILE_FUDGE_ALT);
        NewNet_FlakFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }
    else if(NewNet_FlakAltFire(FireMode[Mode])!=None)
    {
        NewNet_FlakAltFire(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - M.GetStamp(ClientTimeStamp)-DT + 0.5*M.AverDT, MAX_PROJECTILE_FUDGE);
        NewNet_FlakAltFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }

    ServerStartFire(mode);
}

defaultproperties
{
    FireModeClass(0)=class'NewNet_FlakFire'
    FireModeClass(1)=class'NewNet_FlakAltFire'
    PickupClass=Class'NewNet_FlakCannonPickup'
}
