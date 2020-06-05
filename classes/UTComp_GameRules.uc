
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

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
    local UTComp_PRI uPRI;

    uPRI=class'UTComp_Util'.Static.GetUTCompPRIForPawn(Other);

    if(uPRI!=None && UTCompMutator.bEnablePowerupStats)
    {
        if(Item.IsA('ShieldPack'))
        {
            if(!Level.Game.bTeamGame || !Other.IsA('xPawn') || xPawn(Other).CanUseShield(50)!=0 || Other.IsA('Forward_Pawn'))
                uPRI.PickedUpFifty++;
        }
        else if(Item.IsA('SuperShieldPack'))
            uPRI.PickedUpHundred++;
        else if(Item.IsA('SuperHealthPack') || Item.IsA('Forward_MiniSuperHealth'))
        {
            if(Other.Health<Other.SuperHealthMax || Other.IsA('Forward_Pawn'))
                uPRI.PickedUpKeg++;
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
            uPRI.PickedUpAmp++;
        else if(Item.IsA('AdrenalinePickup'))
            uPRI.PickedUpAdren+= AdrenalinePickup(Item).AdrenalineAmount/2;
    }

    if ( (NextGameRules != None) &&  NextGameRules.OverridePickupQuery(Other, item, bAllowPickup) )
		return true;
	return false;
}


function ScoreKill(Controller Killer, Controller Killed)
{
	  local UTComp_PRI uPRI;

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
      }

    if ( NextGameRules != None )
		NextGameRules.ScoreKill(Killer,Killed);
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
