
class UTComp_GameRules extends GameRules;

var MutUTComp UTCompMutator;
var float OVERTIMETIME;
var float OverTimeEndTime;
var bool bFirstRun;
var bool bFirstEndOT;

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    local byte HitSoundType;
    local UTComp_PRI uPRI;
    local controller C;

    if(Damage>0 && InstigatedBy!=None && Injured!=None && InstigatedBy.Controller!=None && BS_xPlayer(InstigatedBy.Controller)!=None)
    {
        if(UTCompMutator.EnableHitSoundsMode>0)
        {
            if(BS_xPlayer(InstigatedBy.Controller).bWantsStats && UTCompMutator.bEnableWeaponStats)
                BS_xPlayer(InstigatedBy.Controller).ReceiveHit(DamageType, Damage, Injured);
            else  //send less info
            {
                if(InstigatedBy==Injured)
                    HitSoundType=0;
                else if(InstigatedBy.GetTeamNum()==255 || InstigatedBy.GetTeamNum() != Injured.GetTeamNum())
                    HitSoundType=1;
                else
                    HitSoundType=2;
                if(InstigatedBy.LineOfSightTo(Injured))
                    BS_xPlayer(InstigatedBy.Controller).ReceiveHitSound(Damage, HitSoundType);
            }

            if(InstigatedBy==Injured)
                HitSoundType=0;
            else if(InstigatedBy.GetTeamNum()==255 || InstigatedBy.GetTeamNum() != Injured.GetTeamNum())
                HitSoundType=1;
            else
                HitSoundType=2;
            for(C=Level.ControllerList; C!=None; C=C.NextController)
            {
                if(BS_xPlayer(C)!=None && C.PlayerReplicationInfo!=None && (C.PlayerReplicationInfo.bOnlySpectator || C.PlayerReplicationInfo.bOutOfLives) && PlayerController(C).ViewTarget == InstigatedBy)
                {
                    BS_xPlayer(C).ReceiveHitSound(Damage, HitSoundType);
                }
            }
        }
        else if(BS_xPlayer(InstigatedBy.Controller).bWantsStats && UTCompMutator.bEnableWeaponStats)
        {
            BS_xPlayer(InstigatedBy.Controller).ReceiveStats(DamageType, Damage, Injured);
        }

        BS_xPlayer(InstigatedBy.Controller).ServerReceiveHit(DamageType, Damage, Injured);
    }
    if(Injured!=None && Injured.Controller!=None && BS_xPlayer(Injured.Controller)!=None)
    {
            uPRI=Class'UTComp_Util'.Static.GetUTCompPRIForPawn(Injured);
            if(uPRI!=None)
                uPRI.DamR+=Damage;
    }
    if ( NextGameRules != None )
		return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	return Damage;
}

function LogPickup(Pawn other, Pickup item)
{
    UTCompMutator.LogPickup(other, item);
}

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
    local UTComp_PRI uPRI;

    uPRI=class'UTComp_Util'.Static.GetUTCompPRIForPawn(Other);

    if(uPRI!=None && UTCompMutator.bEnablePowerupStats)
    {
        if(Item.IsA('ShieldPack'))
        {
            if(!Level.Game.bTeamGame || !Other.IsA('xPawn') || xPawn(Other).CanUseShield(50)!=0 || Other.IsA('Forward_Pawn'))
            {
                uPRI.PickedUpFifty++;
            }
        }
        else if(Item.IsA('SuperShieldPack'))
        {
            uPRI.PickedUpHundred++;
            LogPickup(other, item);
        }
        else if(Item.IsA('SuperHealthPack') || Item.IsA('Forward_MiniSuperHealth'))
        {
            if(Other.Health<Other.SuperHealthMax || Other.IsA('Forward_Pawn'))
            {
                uPRI.PickedUpKeg++;
                LogPickup(other, item);
            }
        }
        else if(Item.IsA('HealthPack'))
        {
            if(Other.Health<Other.HealthMax)
            {
                uPRI.PickedUpHealth++;
            }
        }
        else if(Item.IsA('MiniHealthPack'))
        {
            if(Other.Health<Other.SuperHealthMax)
            {
                uPRI.PickedUpVial++;
            }
        }
        else if(Item.IsA('UDamagePack'))
        {
            uPRI.PickedUpAmp++;
            LogPickup(other, item);
        }
        else if(Item.IsA('AdrenalinePickup'))
        {
            uPRI.PickedUpAdren += AdrenalinePickup(Item).AdrenalineAmount/2;
        }
    }

    if ( (NextGameRules != None) &&  NextGameRules.OverridePickupQuery(Other, item, bAllowPickup) )
		return true;
	return false;
}


function ScoreKill(Controller Killer, Controller Killed)
{
	  local UTComp_PRI uPRI;
      local Controller C;
      local BS_xPlayer uPC;

      if(Killer != none && Killed !=None)
      {
          if ( Killer == Killed)
          {}
          else if(Killer.PlayerReplicationInfo==None || Killed.PlayerReplicationInfo==None)
          {}
          else if(Killer.PlayerReplicationInfo.Team==None || (Killer.PlayerReplicationInfo.Team != Killed.PlayerReplicationInfo.Team))
          {
              uPRI=class'UTComp_Util'.static.GetUTCompPRI(Killer.PlayerReplicationInfo);
              if(uPRI!=None)
                  uPRI.RealKills++;
          }
          else
          {
              uPRI=class'UTComp_Util'.static.GetUTCompPRI(Killer.PlayerReplicationInfo);
              if(uPRI!=None)
                  uPRI.RealKills--;
              uPRI=None;
              uPRI=class'UTComp_Util'.static.GetUTCompPRI(Killed.PlayerReplicationInfo);
              if(uPRI!=None)
                  uPRI.RealKills++;
          }


        if (Level.Game.IsA('CTFGame') && Killed.PlayerReplicationInfo.HasFlag != None)
        {
            if ( (Killer!=None) && (Killer.PlayerReplicationInfo.Team != Killed.PlayerReplicationInfo.Team) )
            {
                if (CTFGame(Level.Game).NearGoal(Killed))
                {
                    uPRI=class'UTComp_Util'.static.GetUTCompPRI(Killer.PlayerReplicationInfo);
                    if (uPRI!=None)
                        uPRI.FlagDenials++;
                }
            }
        }
    }



    // Next, if we are spectating a flag carrier through SpecViewGoal, we want to move to free cam at the location the FC died !
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        uPC = BS_xPlayer(C);
        if (uPC != None && C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.bOnlySpectator)
        {
            if (xPawn(uPC.ViewTarget) != None && uPC.bSpecingViewGoal && (xPawn(uPC.ViewTarget).Controller == Killed || xPawn(uPC.ViewTarget).OldController == Killed))
            {
                uPC.SetLocation(uPC.CalcViewLocation);
                uPC.SetViewTarget(uPC);

                uPC.bBehindView = true;
                uPC.ClientSetLocation(uPC.CalcViewLocation, uPC.CalcViewRotation);
                uPC.ClientSetViewTarget(uPC);
            }
        }
    }

    if ( NextGameRules != None )
		NextGameRules.ScoreKill(Killer,Killed);
}

/*
  Determines if the controller in the team's zone.
*/
function bool IsInZone(Controller c, int team)
{
  local string loc;

  if (c.PlayerReplicationInfo != None)
  {
    loc = c.PlayerReplicationInfo.GetLocationName();

    if (team == 0)
      return (Instr(Caps(loc), "RED" ) != -1);
      else
        return (Instr(Caps(loc), "BLUE") != -1);
  }

  return false;
}

/*
 * This is used for the covers, seals and flag kills.
 */
function bool PreventDeath(Pawn Victim, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local PlayerReplicationInfo victimPRI, killerPRI;
    local UTComp_PRI victimuPRI, killeruPRI;

    local Pawn killerTeamFC, victimTeamFC;
    local vector killerTeamFCPosition;
    local bool preventDeath;
    preventDeath = Super.PreventDeath(Victim, Killer, damageType, HitLocation);

    if (preventDeath || !Level.Game.IsA('xCTFGame'))
        return preventDeath;

    if (Victim != None && Killer != None)
    {
        victimPRI = Victim.PlayerReplicationInfo;
        killerPRI = Killer.PlayerReplicationInfo;

        // Covers and seals!
        if (victimPRI != None && killerPRI != None && killerPRI.Team != victimPRI.Team)
        {
            killerTeamFC = CTFBase(victimPRI.Team.HomeBase).myFlag.Holder;
            victimTeamFC = CTFBase(killerPRI.Team.HomeBase).myFlag.Holder;

            if (killerTeamFC != None)
            {
                killerTeamFCPosition = killerTeamFC.Location;
            }


            victimuPRI = class'UTComp_Util'.static.GetUTCompPRI(victimPRI);
            killeruPRI = class'UTComp_Util'.static.GetUTCompPRI(killerPRI);

            if (victimPRI.HasFlag != None)
            {
                killeruPRI.FlagKills++;
                killerPRI.Score += class'MutUTComp'.Default.FlagKillBonus;
            }
            else if (killerPRI.HasFlag == None && killerTeamFC != None)
            {

                // For a cover bonus:
                // a) The victim is 512uu close to the FC
                // b) The killer is 512uu close to the FC
                // c) The victim is 1536uu close to the FC and can see him
                // d) The victim is 1024uu close to the FC and the killer can see the FC
                // e) The victim is 768uu close and is in line-of-sight of the FC (but not necessarely looking at him).

                /*
                Log("_Killer:" @ killerPRI.PlayerName);
                Log("_Killer FC:" @ killerTeamFC.PlayerReplicationInfo.PlayerName);
                Log("KillerTeamFCPosition:"@killerTeamFCPosition);
                Log("KillerLocation:"@Killer.Location);
                Log("__Distance Victim-FC:" @ VSize(Victim.Location - killerTeamFCPosition));
                Log("__Distance Killer-FC:" @ VSize(Killer.Pawn.Location - killerTeamFCPosition));
                Log("__VictimCanSeeFC:" @ Victim.Controller.CanSee(killerTeamFC));
                Log("__KillerCanSeeFC:" @ Killer.CanSee(killerTeamFC));
                Log("__VictimLOSFC:" @ Victim.Controller.lineOfSightTo(killerTeamFC));
                */

                // I actually increased the numbers by 20%. Those (in the comments) were the UT99 numbers
                if ((VSize(Victim.Location - killerTeamFCPosition) < 614.4)
                 || (VSize(Killer.Pawn.Location - killerTeamFCPosition) < 614.4)
                 || (VSize(Victim.Location - killerTeamFCPosition) < 1843.2 && Victim.Controller.CanSee(killerTeamFC))
                 || (VSize(Victim.Location - killerTeamFCPosition) < 1228.8 && Killer.CanSee(killerTeamFC))
                 || (VSize(Victim.Location - killerTeamFCPosition) < 921.6 && Victim.Controller.lineOfSightTo(killerTeamFC)))
                {

                    killeruPRI.Covers++;
                    killeruPRI.CoverSpree++;
                    killerPRI.Score += class'MutUTComp'.Default.CoverBonus;

                    Log("Cover - "@killerPRI.PlayerName);

                    // CoverSpree!
                    if (killeruPRI.CoverSpree == 3)
                    {
                        if (class'MutUTComp'.Default.CoverSpreeMsgType == 1)
                            Killer.Pawn.ClientMessage(class'UTComp_CTFMessage'.static.GetString(4 + 64, killerPRI, victimPRI));
                        else
                            BroadcastLocalizedMessage(class'UTComp_CTFMessage', 4, killerPRI, victimPRI);
                    }
                    else if (killeruPRI.CoverSpree == 4 && class'MutUTComp'.Default.CoverSpreeMsgType > 0)
                    {
                        if (class'MutUTComp'.Default.CoverSpreeMsgType == 1)
                            Killer.Pawn.ClientMessage(class'UTComp_CTFMessage'.static.GetString(5 + 64, killerPRI, victimPRI));
                        else
                            BroadcastLocalizedMessage(class'UTComp_CTFMessage', 5, killerPRI, victimPRI);
                    }
                    else if (class'MutUTComp'.Default.CoverMsgType > 0) // Normal Cover
                    {
                        if (class'MutUTComp'.Default.CoverMsgType == 1)
                            Killer.Pawn.ClientMessage(class'UTComp_CTFMessage'.static.GetString(0 + 64, killerPRI, victimPRI));
                        else
                            BroadcastLocalizedMessage(class'UTComp_CTFMessage', 0, killerPRI, victimPRI);
                    }
                }

                // If the flag is still on the base, we can make seals!
                if (victimTeamFC == None)
                {
                    // If both the victim and the FC are in the FC's zone, it's a seal !
                    if (IsInZone(Victim.Controller, killerPRI.Team.TeamIndex) && IsInZone(killerTeamFC.Controller, killerPRI.Team.TeamIndex))
                    {
                        killeruPRI.Seals++;
                        killeruPRI.SealSpree++;
                        killeruPRI.DefKills++; // seal is also a defkill

                        if (class'MutUTComp'.Default.SealMsgType > 0 && killeruPRI.SealSpree == 2) // Sealing base
                        {
                            if (class'MutUTComp'.Default.SealMsgType == 1)
                                Killer.Pawn.ClientMessage(class'UTComp_CTFMessage'.static.GetString(1 + 64, killerPRI, victimPRI));
                            else
                                BroadcastLocalizedMessage(class'UTComp_CTFMessage', 1, killerPRI, victimPRI);
                        }
                    }
                }
                else
                {
                    if (IsInZone(Victim.Controller, killerPRI.Team.TeamIndex))
                    {
                        killeruPRI.DefKills++;
                    }
                }
            }
        }
    }


    return Super.PreventDeath(Victim, Killer, damageType, HitLocation);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    if(UTCompMutator.WarmupClass!=None && UTCompMutator.WarmupClass.bInWarmup)
        return false;
    if(UTCompMutator.bEnableTimedOvertime && Level.Game.bOverTime && !Level.Game.IsA('UTComp_ClanArena'))
    {
        if(!OvertimeOver())
            return false;
    }
    if ( NextGameRules != None )
		return NextGameRules.CheckEndGame(Winner,Reason);
	return true;
}

function bool OvertimeOver()
{
    if(bFirstRun)
    {
        OvertimeEndTime=Level.TimeSeconds+OVERTIMETIME*Level.TimeDilation;
        UpdateClock((OverTimeEndTime-Level.TimeSeconds)/Level.TimeDilation);
        bFirstRun=false;
        return false;
    }
    UpdateClock((OverTimeEndTime-Level.TimeSeconds)/Level.TimeDilation);
    return (Level.TimeSeconds>=OverTimeEndTime);
}

function UpdateClock(float F)
{
    if(UTCompMutator!=None && UTCompMutator.WarmupClass!=None)
    {
        UTCompMutator.WarmupClass.SetClientTimerOnly(int(Round(F)));
        if(bFirstEndOT && F<=0.0)
        {
            UTCompMutator.WarmupClass.SetEndTimeOnly(int(Round(F)));
            bFirstEndOt=False;
        }
    }
}

function Reset()
{
    super.Reset();
    bFirstrun=True;
    bFirstEndOT=true;
    OvertimeEndTime=0.0;
}


defaultproperties
{
    bFirstRun=True
    bFirstEndOT=true
}
