class NewNet_SuperShockBeamFire extends UTComp_SuperShockBeamFire;

var bool bUseReplicatedInfo;
var rotator savedRot;
var vector savedVec;

var float PingDT;
var bool bSkipNextEffect;
var bool bUseEnhancedNetCode;
var bool bBelievesHit;
var Actor BelievedHitActor;
var vector BelievedHitLocation;
var float averdt;
var bool bFirstGo;

function PlayFiring()
{
   super.PlayFiring();

   if(Level.NetMode != NM_Client || !BS_xPlayer(Level.GetLocalPlayerController()).UseNewNet())
       return;
   if(!bSkipNextEffect)
       CheckFireEffect();
   else
   {
      bSkipNextEffect=false;
      Weapon.ClientStopFire(0);
   }
}

function CheckFireEffect()
{
   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
   {
       DoFireEffect();
   }
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local int Damage;
    local bool bDoReflect;
    local int ReflectNum;
    local vector PawnHitLocation;
    local actor AltOther;
	local vector AltHitlocation,altHitNormal,altPawnHitLocation;
	local float f;

//	local vector ShockLoc;

    if(!bUseEnhancedNetCode)
    {
        super.DoTrace(Start,Dir);
        return;
    }

	MaxRange();

    ReflectNum = 0;

    while (true)
    {
        TimeTravel(pingDT);
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        if(PingDT <=0.0)
            Other = Weapon.Trace(HitLocation,HitNormal,End,Start,true);
        else
            Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);

        if(Other!=None && Other.IsA('PawnCollisionCopy'))
        {
             PawnHitLocation = HitLocation + PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
             Other=PawnCollisionCopy(Other).CopiedPawn;
        }
        else
        {
            PawnHitLocation = HitLocation;
        }

        if(bFirstGo && bBelievesHit && !(Other == BelievedHitActor))
        {

            if(ReflectNum==0)
            {
                f = 0.02;
                while(abs(f) < (0.04 + 2.0*AverDT))
                {

                    TimeTravel(PingDT-f);
                    if((PingDT-f) <=0.0)
                          AltOther = Weapon.Trace(AltHitLocation,AltHitNormal,End,Start,true);
                    else
                          AltOther = DoTimeTravelTrace(AltHitLocation, AltHitNormal, End, Start);

                    if(AltOther!=None && AltOther.IsA('PawnCollisionCopy'))
                    {
                         AltPawnHitLocation = AltHitLocation + PawnCollisionCopy(AltOther).CopiedPawn.Location - AltOther.Location;
                         AltOther=PawnCollisionCopy(AltOther).CopiedPawn;
                    }
                    else
                         AltPawnHitLocation=AltHitLocation;

                    if(altOther == BelievedHitACtor)
                    {
                    //   Log("Fixed At"@f@"with max"@(0.04 + 2.0*AverDT));
                       Other=altOther;
                       PawnHitLocation=AltPawnHitLocation;
                       HitLocation=AltHitLocation;
                       f=10.0;
                    }
                    if(f > 0.00)
                        f = -1.0*f;
                    else
                        f = -1.0*f+0.02;
                }
              //  if(abs(f)<9.0)
                //   log("Failed to fix");
            }
        }
        else if(bFirstGo && !bBelievesHit && Other!=None && (Other.IsA('xpawn') || Other.IsA('Vehicle')))
        {
            if(ReflectNum==0)
            {
                f = 0.02;
                while(abs(f) < (0.04 + 2.0*AverDT))
                {
                    AltOther=None;
                    TimeTravel(PingDT-f);
                    if((PingDT-f) <=0.0)
                          AltOther = Weapon.Trace(AltHitLocation,AltHitNormal,End,Start,true);
                    else
                          AltOther = DoTimeTravelTrace(AltHitLocation, AltHitNormal, End, Start);

                    if(AltOther!=None && AltOther.IsA('PawnCollisionCopy'))
                    {
                         AltPawnHitLocation = AltHitLocation + PawnCollisionCopy(AltOther).CopiedPawn.Location - AltOther.Location;
                         AltOther=PawnCollisionCopy(AltOther).CopiedPawn;
                    }
                    else
                         AltPawnHitLocation=AltHitLocation;

                    if(altOther == None || !(altOther.IsA('xpawn') || altOther.IsA('Vehicle')))
                    {
                     //  Log("Reverse Fixed At"@f);
                       Other=altOther;
                       PawnHitLocation=AltPawnHitLocation;
                       HitLocation=altHitLocation;
                       f=10.0;
                    }
                    if(f > 0.00)
                        f = -1.0*f;
                    else
                        f = -1.0*f+0.02;
                }
                //if(abs(f)<9.0)
                //   log("Failed to reverse fix");
            }
        }
        bFirstGo=false;
        UnTimeTravel();

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(PawnHitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = true;
                HitNormal = Vect(0,0,0);
            }
            else if ( !Other.bWorldGeometry )
            {
				Damage = DamageMin;
				if ( (DamageMin != DamageMax) && (FRand() > 0.5) )
					Damage += Rand(1 + DamageMax - DamageMin);
                Damage = Damage * DamageAtten;

				// Update hit effect except for pawns (blood) other than vehicles.
               	if ( Other.IsA('Vehicle') || (!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume')) )
					WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other, PawnHitLocation, HitNormal);

               	Other.TakeDamage(Damage, Instigator, PawnHitLocation, Momentum*X, DamageType);
                HitNormal = Vect(0,0,0);
            }
            else if ( WeaponAttachment(Weapon.ThirdPersonActor) != None )
				WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,PawnHitLocation,HitNormal);
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
			WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,PawnHitLocation,HitNormal);
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if (bDoReflect && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }

}

function DoInstantFireEffect()
{
   if(Level.NetMode == NM_Client && Instigator.IsLocallyControlled())
   {
       DoFireEffect();
       bSkipNextEffect=true;
   }
}

function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator R, Aim;

    if(!bUseEnhancedNetCode && Level.NetMode != NM_Client)
    {
        super.DoFireEffect();
        return;
    }

    Instigator.MakeNoise(1.0);

    if(bUseReplicatedInfo)
    {
        StartTrace=savedVec;
        R=SavedRot;
        bUseReplicatedInfo=false;
	}
    else
    {
        // the to-hit trace always starts right in front of the eye
        StartTrace = Instigator.Location + Instigator.EyePosition();
        Aim = AdjustAim(StartTrace, AimError);
	    R = rotator(vector(Aim) + VRand()*FRand()*Spread);
    }
    if(Level.NetMode == NM_Client)
        DoClientTrace(StartTrace, R);
    else
        DoTrace(StartTrace, R);
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
    foreach Weapon.TraceActors(class'Actor', Other,WorldHitLocation,WorldHitNormal,End,Start)
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
    foreach Weapon.TraceActors(class'PawnCollisionCopy', PCC, PCCHitLocation, PCCHitNormal, NewEnd,Start)
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

    if(NewNet_SuperShockRifle(Weapon).M == none)
        foreach Weapon.DynamicActors(class'MutUTComp',NewNet_SuperShockRifle(Weapon).M)
            break;

    for(PCC = NewNet_SuperShockRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TimeTravelPawn(Delta);
}

function UnTimeTravel()
{
    local PawnCollisionCopy PCC;
    //Now, lets turn off the old hits
    for(PCC = NewNet_SuperShockRifle(Weapon).M.PCC; PCC!=None; PCC=PCC.Next)
        PCC.TurnOffCollision();
}



simulated function DoClientTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local bool bDoReflect;
    local int ReflectNum;

	MaxRange();

    ReflectNum = 0;
    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = true;
                HitNormal = Vect(0,0,0);
            }
            else if ( !Other.bWorldGeometry )
            {
				// Update hit effect except for pawns (blood) other than vehicles.
               	if ( Other.IsA('Vehicle') || (!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume')) )
					WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other, HitLocation, HitNormal);

                HitNormal = Vect(0,0,0);
            }
            else if ( WeaponAttachment(Weapon.ThirdPersonActor) != None )
				WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
			WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
        }

        SpawnClientBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if (bDoReflect && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }
}

simulated function SpawnClientBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local Controller C;

    if (Instigator.Controller.IsA('BS_xPlayer'))
        C = Instigator.Controller;
    else
        C = Level.GetLocalPlayerController();

    if (C.IsA('BS_xPlayer'))
        BS_xPlayer(C).SendWeaponEffect(
            class'UTComp_SuperShockRifleEffect',
            Instigator,
            Start,
            vector(Dir),
            HitLocation,
            HitNormal,
            ReflectNum
        );
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local Controller C;
    
    if(!bUseEnhancedNetCode)
    {
        Super.SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);
    }
    else
    {
        for (C = Level.ControllerList; C != none; C = C.NextController) {
            if (C == Instigator.Controller) continue;
            if (C.IsA('BS_xPlayer')) {
                BS_xPlayer(C).SendWeaponEffect(
                    class'UTComp_SuperShockRifleEffect',
                    Instigator,
                    Start,
                    vector(Dir),
                    HitLocation,
                    HitNormal,
                    ReflectNum
                );
            }
        }
    }
}


DefaultProperties
{
}
