
class NewNet_RocketLauncher extends UTComp_RocketLauncher
    HideDropDown
	CacheExempt;

const MAX_PROJECTILE_FUDGE = 0.275;
const MAX_PROJECTILE_FUDGE_ALT = 0.275;
const PROJ_TIMESTEP = 0.0201;

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

var float PingDT;
var bool bUseEnhancedNetCode;

var float lastDT;


replication
{
    reliable if(Role < Role_Authority)
        NewNet_ServerStartFire;
}

function DisableNet()
{
    NewNet_RocketFire(FireMode[0]).bUseEnhancedNetCode = false;
 //   NewNet_RocketFire(FireMode[0]).PingDT = 0.00;
    NewNet_RocketMultiFire(FireMode[1]).bUseEnhancedNetCode = false;
    bUseEnhancedNetCode=false;
    PingDT = 0.00;
  //  NewNet_RocketMultiFire(FireMode[1]).PingDT = 0.00;
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
	local int OtherMode;

	if ( RocketMultiFire(FireMode[Mode]) != None )
	{
		SetTightSpread(false);
	}
    else
    {
		if ( Mode == 0 )
			OtherMode = 1;
		else
			OtherMode = 0;

		if ( FireMode[OtherMode].bIsFiring || (FireMode[OtherMode].NextFireTime > Level.TimeSeconds) )
		{
			if ( FireMode[OtherMode].Load > 0 )
				SetTightSpread(true);
			if ( bDebugging )
				log("No RL reg fire because other firing "$FireMode[OtherMode].bIsFiring$" next fire "$(FireMode[OtherMode].NextFireTime - Level.TimeSeconds));
			return;
		}
	}
    NewNet_AltClientStartFire(Mode);
}

simulated function NewNet_AltClientStartFire(int mode)
{
    local ReplicatedRotator R;
    local ReplicatedVector V;
    local vector Start;

    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (StartFire(Mode))
        {
            if(T==None)
                foreach DynamicActors(class'TimeStamp_Pawn', T)
                     break;
         /*   if(NewNet_RocketMultiFire(FireMode[Mode])!=None)
                NewNet_RocketMultiFire(FireMode[Mode]).DoInstantFireEffect();
            else*/ if(NewNet_RocketFire(FireMode[Mode])!=None)
                NewNet_RocketFire(FireMode[Mode]).DoInstantFireEffect();
            R.Pitch = Pawn(Owner).Controller.Rotation.Pitch;
            R.Yaw = Pawn(Owner).Controller.Rotation.Yaw;
            STart=Pawn(Owner).Location + Pawn(Owner).EyePosition();

            V.X = Start.X;
            V.Y = Start.Y;
            V.Z = Start.Z;

            NewNet_ServerStartFire(mode, T.TimeStamp,T.DT, R, V);
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

    return REadyToFire(Mode);
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

    PingDT = FMin(M.ClientTimeStamp - M.GetStamp(ClientTimeStamp)-DT + 0.5*M.AverDT, MAX_PROJECTILE_FUDGE);
    bUseEnhancedNetCode=true;
    if(NewNet_RocketFire(FireMode[Mode])!=None)
    {
       // NewNet_RocketFire(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE_ALT);
        NewNet_RocketFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }
    else if(NewNet_RocketMultiFire(FireMode[Mode])!=None)
    {
     //   NewNet_RocketMultiFire(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE);
        NewNet_RocketMultiFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }

    if ( (FireMode[Mode].NextFireTime <= Level.TimeSeconds + FireMode[Mode].PreFireTime)
		&& StartFire(Mode) )
    {
        FireMode[Mode].ServerStartFireTime = Level.TimeSeconds;
        FireMode[Mode].bServerDelayStartFire = false;

        if(NewNet_RocketFire(FireMode[Mode])!=None)
        {
            NewNet_RocketFire(FireMode[Mode]).SavedVec.X = V.X;
            NewNet_RocketFire(FireMode[Mode]).SavedVec.Y = V.Y;
            NewNet_RocketFire(FireMode[Mode]).SavedVec.Z = V.Z;
            NewNet_RocketFire(FireMode[Mode]).SavedRot.Yaw = R.Yaw;
            NewNet_RocketFire(FireMode[Mode]).SavedRot.Pitch = R.Pitch;
            NewNet_RocketFire(FireMode[Mode]).bUseReplicatedInfo=IsReasonable(NewNet_RocketFire(FireMode[Mode]).SavedVec);

        }
    }
    else if ( FireMode[Mode].AllowFire() )
    {
        FireMode[Mode].bServerDelayStartFire = true;
	}
	else
		ClientForceAmmoUpdate(Mode, AmmoAmount(Mode));
}


simulated function Weapontick(float deltatime)
{
   lastDT = deltatime;
}
//// client & server ////
simulated function bool StartFire(int Mode)
{
    local int alt;
    local int OtherMode;

	if ( Mode == 0 )
		OtherMode = 1;
	else
		OtherMode = 0;
	if ( FireMode[OtherMode].bIsFiring || (FireMode[OtherMode].NextFireTime > Level.TimeSeconds) )
		return false;

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

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local RocketProj Rocket;
    local SeekingRocketProj SeekingRocket;
	local bot B;
	local actor Other;
	local float f,g;

	local vector HitNormal, End, HitLocation;

	if(!bUseEnhancedNetCode)
	{
	    return super.SpawnProjectile(Start, Dir);
	}

    bBreakLock = true;

	// decide if bot should be locked on
	B = Bot(Instigator.Controller);
	if ( (B != None) && (B.Skill > 2 + 5 * FRand()) && (FRand() < 0.6) && (B.Target != None)
		&& (B.Target == B.Enemy) && (VSize(B.Enemy.Location - B.Pawn.Location) > 2000 + 2000 * FRand())
		&& (Level.TimeSeconds - B.LastSeenTime < 0.4) && (Level.TimeSeconds - B.AcquireTime > 1.5) )
	{
		bLockedOn = true;
		SeekTarget = B.Enemy;
	}

    if (bLockedOn && SeekTarget != None)
    {
        if(PingDT > 0.0 && Owner!=None)
        {
            Start-=1.0*vector(Dir);
            for(f=0.00; f<pingDT + PROJ_TIMESTEP; f+=PROJ_TIMESTEP)
            {
                //Make sure the last trace we do is right where we want
                //the proj to spawn if it makes it to the end
                g = Fmin(pingdt, f);

                //Where will it be after deltaF, Dir byRef for next tick
                if(f >= pingDT)
                   End = Start + Extrapolate(Dir, (pingDT-f+PROJ_TIMESTEP));
                else
                   End = Start + Extrapolate(Dir, PROJ_TIMESTEP);
                //Put pawns there
                TimeTravel(pingdt - g);
                //Trace between the start and extrapolated end
                Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);
                if(Other!=None)
                {
                    break;
                }
                //repeat
                Start=End;
           }
           UnTimeTravel();

           if(Other!=None && Other.IsA('PawnCollisionCopy'))
           {
               HitLocation = HitLocation + PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
               Other=PawnCollisionCopy(Other).CopiedPawn;
           }

           if(Other == none)
               SeekingRocket = Spawn(class'NewNet_SeekingRocketProj',,, End, Dir);
           else
           {
               SeekingRocket = Spawn(class'NewNet_SeekingRocketProj',,, HitLocation - Vector(dir)*20.0, Dir);
           }
        }
        if(SeekingRocket==None)
            SeekingRocket = Spawn(class'NewNet_SeekingRocketProj',,, Start, Dir);

        SeekingRocket.Seeking = SeekTarget;
        if ( B != None )
        {
			//log("LOCKED");
			bLockedOn = false;
			SeekTarget = None;
		}
        return SeekingRocket;
    }
    else
    {
        if(PingDT > 0.0 && Owner!=None)
        {
            Start-=1.0*vector(Dir);
            for(f=0.00; f<pingDT + PROJ_TIMESTEP; f+=PROJ_TIMESTEP)
            {
                //Make sure the last trace we do is right where we want
                //the proj to spawn if it makes it to the end
                g = Fmin(pingdt, f);
                //Where will it be after deltaF, Dir byRef for next tick
                if(f >= pingDT)
                   End = Start + Extrapolate(Dir, (pingDT-f+PROJ_TIMESTEP));
                else
                   End = Start + Extrapolate(Dir, PROJ_TIMESTEP);
                //Put pawns there
                TimeTravel(pingdt - g);
                //Trace between the start and extrapolated end
                Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);
                if(Other!=None)
                {
                    break;
                }
                //repeat
                Start=End;
           }
           UnTimeTravel();

           if(Other!=None && Other.IsA('PawnCollisionCopy'))
           {
               HitLocation = HitLocation + PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
               Other=PawnCollisionCopy(Other).CopiedPawn;
           }

           if(Other == none)
               Rocket = Spawn(class'NewNet_RocketProj',,, End, Dir);
           else
           {
               Rocket = Spawn(class'NewNet_RocketProj',,, HitLocation - Vector(dir)*20.0, Dir);
           }
        }
        else
            Rocket = Spawn(class'NewNet_RocketProj',,, Start, Dir);
        return Rocket;
    }
}

function vector Extrapolate(out rotator Dir, float dF)
{
    return vector(Dir)*class'NewNet_RocketProj'.default.speed*dF;
}

// We need to do 2 traces. First, one that ignores the things which have already been copied
// and a second one that looks only for things that are copied
function Actor DoTimeTravelTrace(Out vector Hitlocation, out vector HitNormal, vector End, vector Start)
{
    local Actor Other;
    local bool bFoundPCC;
    local vector NewEnd, WorldHitNormal,WorldHitLocation;
    local vector PCCHitNormal,PCCHitLocation;
    local PawnCollisionCopy PCC, returnPCC;

    //First, lets set the extent of our trace.  End once we hit an actor which won't
    //be checked by an unlagged copy.
    foreach Owner.TraceActors(class'Actor', Other,WorldHitLocation,WorldHitNormal,End,Start)
    {
       if((Other.bBlockActors || Other.bProjTarget || Other.bWorldGeometry) && !class'MutUTComp'.static.IsPredicted(Other))
       {
           break;
       }
       Other=None;
    }
    if(Other!=None)
        NewEnd=WorldHitlocation;
    else
        NewEnd=End;


    //Now, lets see if we run into any copies, we stop at the location
    //determined by the previous trace.
    foreach Owner.TraceActors(class'PawnCollisionCopy', PCC, PCCHitLocation, PCCHitNormal, NewEnd,Start)
    {
        if(PCC!=None && PCC.CopiedPawn!=None && PCC.CopiedPawn!=Instigator)
        {
            bFoundPCC=True;
            returnPCC=PCC;
            break;
        }
    }

    // Give back the corresponding info depending on whether or not
    // we found a copy

    if(bFoundPCC)
    {
        HitLocation = PCCHitLocation;
        HitNormal = PCCHitNormal;
        return returnPCC;
    }
    else
    {
        HitLocation = WorldHitLocation;
        HitNormal = WorldHitNormal;
        return Other;
    }
}

function TimeTravel(float delta)
{
    local PawnCollisionCopy PCC;

    if(M == none)
        foreach DynamicActors(class'MutUTComp',M)
            break;

    for(PCC = M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TimeTravelPawn(Delta);
}

function UnTimeTravel()
{
    local PawnCollisionCopy PCC;
    //Now, lets turn off the old hits
    for(PCC = M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TurnOffCollision();
}

DefaultProperties
{
    PickupClass=Class'NewNet_RocketLauncherPickup'
    FireModeClass(0)=class'NewNet_RocketFire'
    FireModeClass(1)=class'NewNet_RocketMultiFire'
}
