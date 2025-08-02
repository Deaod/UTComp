class NewNet_SuperShockRifle extends UTComp_SuperShockRifle
	HideDropDown
	CacheExempt;

var TimeStamp_Pawn T;
var MutUTComp M;
var float LastDT;

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

replication
{
    reliable if( Role<ROLE_Authority )
        NewNet_ServerStartFire,NewNet_OldServerStartFire;
}

function DisableNet()
{
    NewNet_SuperShockBeamFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_SuperShockBeamFire(FireMode[0]).PingDT = 0.00;
    NewNet_SuperShockBeamFire(FireMode[1]).bUseEnhancedNetCode = false;
    NewNet_SuperShockBeamFire(FireMode[1]).PingDT = 0.00;
}

//// client only ////
simulated event ClientStartFire(int Mode)
{
    if(Level.NetMode!=NM_Client || !BS_xPlayer(Level.GetLocalPlayerController()).UseNewNet() || NewNet_SuperShockBeamFire(FireMode[Mode]) == None)
        super.ClientStartFire(mode);
    else
        NewNet_ClientStartFire(mode);
}

simulated event NewNet_ClientStartFire(int Mode)
{
    local ReplicatedRotator R;
    local ReplicatedVector V;
    local vector Start;
    local byte stamp;
    local bool b;
    local actor A;
    local vector HN,HL;

    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (AltReadyToFire(Mode) && StartFire(Mode))
        {
            if(!ReadyToFire(Mode))
            {
                if(T==None)
                    foreach DynamicActors(class'TimeStamp_Pawn', T)
                        break;
                Stamp = T.TimeStamp;
                NewNet_OldServerStartFire(Mode,Stamp, T.DT);
             //   Log("This should never execute");
                return;
            }
            R.Pitch = Pawn(Owner).Controller.Rotation.Pitch;
            R.Yaw = Pawn(Owner).Controller.Rotation.Yaw;
            STart=Pawn(Owner).Location + Pawn(Owner).EyePosition();

            V.X = Start.X;
            V.Y = Start.Y;
            V.Z = Start.Z;

            if(T==None)
                foreach DynamicActors(class'TimeStamp_Pawn', T)
                     break;
            Stamp = T.TimeStamp;


            NewNet_SuperShockBeamFire(FireMode[mode]).DoInstantFireEffect();


            A = Trace(HN,HL,Start+Vector(Pawn(Owner).Controller.Rotation)*40000.0,Start,true);
            if(A!=None && (A.IsA('xPawn') || A.IsA('Vehicle')))
            {
                    b=true;
            }

            NewNet_ServerStartFire(Mode, stamp, T.DT, R, V,b,A);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

simulated function bool AltReadyToFire(int Mode)
{
    return ReadyToFire(Mode);
}

simulated function WeaponTick(float deltatime)
{
   lastDT = deltatime;
   Super.tick(deltatime);
}

//// client & server ////
simulated function bool StartFire(int Mode)
{
    local int alt;
    if ( bWaitForCombo && (Bot(Instigator.Controller) != None) )
	{
		if ( (ComboTarget == None) || ComboTarget.bDeleteMe )
			bWaitForCombo = false;
		else
			return false;
	}

    if (!ReadyToFire(Mode))
        return false;

    if (Mode == 0)
        alt = 1;
    else
        alt = 0;

    FireMode[Mode].bIsFiring = true;

    FireMode[Mode].NextFireTime = Level.TimeSeconds-LastDT*0.5 + FireMode[Mode].PreFireTime;

    if (FireMode[alt].bModeExclusive)
    {
        // prevents rapidly alternating fire modes
        FireMode[Mode].NextFireTime = FMax(FireMode[Mode].NextFireTime, FireMode[alt].NextFireTime);
    }

    if (Instigator.IsLocallyControlled())
    {
        if (FireMode[Mode].PreFireTime > 0.0 || FireMode[Mode].bFireOnRelease)
        {
            FireMode[Mode].PlayPreFire();
        }
        FireMode[Mode].FireCount = 0;
    }

    return true;
}


function NewNet_ServerStartFire(byte Mode, byte ClientTimeStamp, float DT, ReplicatedRotator R, ReplicatedVector V, bool bBelievesHit, actor A/*, bool bBelievesHit, ReplicatedVector BelievedHLDelta, Actor A, vector HN, vector HL*/)
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

    NewNet_SuperShockBeamFire(FireMode[Mode]).PingDT = M.ClientTimeStamp - M.GetStamp(ClientTimeStamp)-DT + 0.5*M.AverDT;
    NewNet_SuperShockBeamFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    NewNet_SuperShockBeamFire(FireMode[Mode]).AverDT = M.AverDT;

    if(bBelievesHit)
    {
        NewNet_SuperShockBeamFire(FireMode[Mode]).bBelievesHit=true;
        NewNet_SuperShockBeamFire(FireMode[Mode]).BelievedHitActor=A;
    }
    else
    {
        NewNet_SuperShockBeamFire(FireMode[Mode]).bBelievesHit=false;
    }
    NewNet_SuperShockBeamFire(FireMode[Mode]).bFirstGo=true;
    if ( (FireMode[Mode].NextFireTime <= Level.TimeSeconds + FireMode[Mode].PreFireTime)
		&& StartFire(Mode) )
    {
        FireMode[Mode].ServerStartFireTime = Level.TimeSeconds;
        FireMode[Mode].bServerDelayStartFire = false;
        NewNet_SuperShockBeamFire(FireMode[Mode]).SavedVec.X = V.X;
        NewNet_SuperShockBeamFire(FireMode[Mode]).SavedVec.Y = V.Y;
        NewNet_SuperShockBeamFire(FireMode[Mode]).SavedVec.Z = V.Z;
        NewNet_SuperShockBeamFire(FireMode[Mode]).SavedRot.Yaw = R.Yaw;
        NewNet_SuperShockBeamFire(FireMode[Mode]).SavedRot.Pitch = R.Pitch;
        NewNet_SuperShockBeamFire(FireMode[Mode]).bUseReplicatedInfo=IsReasonable(NewNet_SuperShockBeamFire(FireMode[Mode]).SavedVec);
    }
    else if ( FireMode[Mode].AllowFire() )
    {
        FireMode[Mode].bServerDelayStartFire = true;
	}
	else
		ClientForceAmmoUpdate(Mode, AmmoAmount(Mode));
}


function NewNet_OldServerStartFire(byte Mode, byte ClientTimeStamp, float dt)
{
    if(M==None)
        foreach DynamicActors(class'MutUTComp', M)
            break;
    NewNet_SuperShockBeamFire(FireMode[Mode]).PingDT = M.ClientTimeStamp - M.GetStamp(ClientTimeStamp)-DT + 0.5*M.AverDT;
    NewNet_SuperShockBeamFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    ServerStartFire(mode);
}

function bool IsReasonable(Vector V)
{
    local vector LocDiff;
    local float clErr;

    if(Owner == none || Pawn(Owner) == none)
        return true;

    LocDiff = V - (Pawn(Owner).Location + Pawn(Owner).EyePosition());
    clErr = (LocDiff dot LocDiff);
   // if(clErr>=750)
   //   Log("ERROR TOO GREAT");
   return clErr < 1250.0;
}


DefaultProperties
{
    ItemName="NewNet SSR"
    FireModeClass(0)=class'NewNet_SuperShockBeamFire'
    FireModeClass(1)=class'NewNet_SuperShockBeamFire'
}
