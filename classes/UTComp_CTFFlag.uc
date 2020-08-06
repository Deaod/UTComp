class UTComp_CTFFlag extends CTFFlag;

struct FlagCarrier
{
    var Controller C;
    var float Time;
};

var array<FlagCarrier> FlagCarriers;
var float PickupTime;

/*
  Adds a flag carrier to the list so we can reward him if there's a cap.
*/
function AddFlagCarrier(Controller c)
{
  local int i;
  local FlagCarrier fc;
  local float dt;

  dt = Level.TimeSeconds - PickupTime;

  //Log("AddFlagCarrier"@c.PlayerReplicationInfo.PlayerName@dt);

  if (c == None || !c.bIsPlayer || (c.PlayerReplicationInfo != None && c.PlayerReplicationInfo.bOnlySpectator))
    return;

  for (i = 0; i < FlagCarriers.length; i++)
  {
    if (FlagCarriers[i].C == c)
    {
      FlagCarriers[i].Time += dt;
      //Log("AddFlagCarrier-Existing"@c.PlayerReplicationInfo.PlayerName@dt);
      return;
    }
  }

  fc.C = c;
  fc.Time = dt;
  FlagCarriers[FlagCarriers.Length] = fc;
  //Log("AddFlagCarrier-New"@c.PlayerReplicationInfo.PlayerName@dt);
}

function string CarriedString(float Time, float TotalTime)
{
  local int Perc;
  local float f;

  if (TotalTime == 0)
    f = 0;
  else
    f = (Time / TotalTime) * 100;

  Time /= Level.TimeDilation;

  Perc = Clamp(f, 0, 100);
  if (Perc == 100)
    return "(Solocap," @ int(Time) @ "sec.)";
  else
    return "(Carried" @ Perc $ "% of the time:" @ int(Time) @ "sec.)";
}

/*t
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
 * Reset cover and seal sprees of Team cause of flag return.
 */
function ResetSprees()
{
  local UTComp_PRI uPRI;
  local Controller C;
  local PlayerReplicationInfo PRI;

  for (C = Level.ControllerList; C != None; C = C.NextController)
  {
    PRI = c.PlayerReplicationInfo;
    if (PRI != None && PRI.Team != None && PRI.Team != Team) // != because this is called on the flag that was capped.
    {
        uPRI = class'UTComp_Util'.static.GetUTCompPRI(C.PlayerReplicationInfo);

        if (uPRI != None)
        {
            uPRI.CoverSpree = 0;
            uPRI.SealSpree = 0;
        }
    }
  }
}

function bool IsOtherFlagHome()
{
  return CTFBase(xCTFGame(Level.Game).Teams[1 - TeamNum].HomeBase).myFlag.bHome;
}

/*
  UTComp scoring
*/
function ScoreFlag(Controller Scorer)
{
  local UTComp_PRI uPRI;
  local float Dist,oppDist;
  local vector FlagLoc;

  uPRI = class'UTComp_Util'.static.GetUTCompPRI(Scorer.PlayerReplicationInfo);

  // Flag return
  if (Scorer.PlayerReplicationInfo.Team == Team)
  {
    FlagLoc = selF.Position().Location;
    Dist = vsize(FlagLoc - HomeBase.Location);
    oppDist = vsize(FlagLoc - xCTFGame(Level.Game).Teams[1 - TeamNum].HomeBase.Location);

    CTFGame(Level.Game).GameEvent("flag_returned", ""$TeamNum, Scorer.PlayerReplicationInfo);
    BroadcastLocalizedMessage( class'CTFMessage', 1, Scorer.PlayerReplicationInfo, None, Team );

    if (Dist > 1024)
    {
      // figure out who's closer
      if (IsInZone(Scorer, TeamNum))  // In your team's zone
      {
        Scorer.PlayerReplicationInfo.Score += class'MutUTComp'.Default.BaseReturnBonus;
        Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo, class'MutUTComp'.Default.BaseReturnBonus, "flag_ret_friendly");
      }
      else if (IsInZone(Scorer, 1 - TeamNum))
      {
        if (oppDist <= 1000 && IsOtherFlagHome()) // Denial
        {
          Scorer.PlayerReplicationInfo.Score += 7;
          uPRI.FlagSaves++;
          Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo, 7, "flag_denial");
        }
        else
        {
          Scorer.PlayerReplicationInfo.Score += class'MutUTComp'.Default.EnemyBaseReturnBonus;
          Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo, class'MutUTComp'.Default.EnemyBaseReturnBonus, "flag_ret_enemy");
        }
      }
      else
      {
        Scorer.PlayerReplicationInfo.Score += class'MutUTComp'.Default.MidReturnBonus;
        Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo, class'MutUTComp'.Default.MidReturnBonus, "flag_ret_mid");
      }
    }

    ResetSprees();
  }
  else
  {
    AddFlagCarrier(Scorer);
    RewardFlagCarriers();
    GiveCoverSealBonus();

    uPRI.FlagCaps++;

    // Reset spress on both team.
    ResetSprees();
    ResetFlagCarriers();

    // Apply the team score
    Scorer.PlayerReplicationInfo.Team.Score += 1.0;
    Scorer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;

    CTFGame(Level.Game).TeamScoreEvent(Scorer.PlayerReplicationInfo.Team.TeamIndex, 1, "flag_cap");
    CTFGame(Level.Game).GameEvent("flag_captured",""$TeamNum,Scorer.PlayerReplicationInfo);

    BroadcastLocalizedMessage(class'CTFMessage', 0, Scorer.PlayerReplicationInfo, None, Team);
    CTFGame(Level.Game).AnnounceScore(Scorer.PlayerReplicationInfo.Team.TeamIndex);
    CTFGame(Level.Game).CheckScore(Scorer.PlayerReplicationInfo);

    if (CTFGame(Level.Game).bOverTime)
    {
      CTFGame(Level.Game).EndGame(Scorer.PlayerReplicationInfo, "timelimit");
    }
  }
}

/*
 * Gives all players of Team that covered their FC extra bonus points after the cap.
 */
function GiveCoverSealBonus()
{
    local PlayerReplicationInfo PRI;
    local Controller C;
    local UTComp_PRI uPRI;
    local float bonus;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PRI = C.PlayerReplicationInfo;
        if (PRI != None && PRI.Team != Team) // != because this is called on the flag that was capped.
        {
            uPRI = class'UTComp_Util'.static.GetUTCompPRI(PRI);

            if (uPRI != None)
            {
                iF (uPRI.SealSpree > 0)
                {
                    bonus = uPRI.SealSpree * class'MutUTComp'.Default.SealBonus;
                    PRI.Score += Int(bonus);

                    if (class'MutUTComp'.Default.bShowSealRewardConsoleMsg)
                    {
                        if (C.Pawn != None)
                        {
                          C.Pawn.ClientMessage("You killed " $ uPRI.SealSpree $ " people sealing off the base. You get " $ Int(bonus) $ " bonus pts!");
                        }
                    }

                }

                if (uPRI.CoverSpree > 0)
                {
                    bonus = uPRI.CoverSpree * class'MutUTComp'.Default.CoverBonus;
                    PRI.Score += Int(bonus);

                    if (class'MutUTComp'.Default.bShowSealRewardConsoleMsg)
                    {
                        if (C.Pawn != None)
                        {
                          C.Pawn.ClientMessage("You killed " $ uPRI.CoverSpree $ " people covering your FC. You get " $ Int(bonus) $ " bonus pts!");
                        }
                    }
                }
            }
        }
    }
}

/*
  Rewards the flag carriers (the cap and the assists)
*/
function RewardFlagCarriers()
{

  local int i;
  local UTComp_PRI uPRI;
  local float totalTime;
  local float bonus;

  for (i = 0; i < FlagCarriers.Length; i++)
    totalTime += FlagCarriers[i].Time;

  //Log("RewardFlagCarriers - TotalTime:"@totalTime);

  for (i = 0; i < FlagCarriers.Length; i++)
  {
    if (FlagCarriers[i].C != None)
    {

      //Log("RewardFlagCarriers - "@FlagCarriers[i].C.PlayerReplicationInfo.PlayerName@"-"@FlagCarriers[i].Time);

      if (totalTime == 0)
        bonus = 0;
      else
        bonus = (FlagCarriers[i].Time / totalTime) * (7 + class'MutUTComp'.Default.CapBonus);

      // At least 5 points for the capper
      if (FlagCarriers[i].C == OldHolder.Controller)
      {
        bonus = Max(bonus, class'MutUTComp'.Default.MinimalCapBonus);

        if (class'MutUTComp'.Default.bShowAssistConsoleMsg)
          FlagCarriers[i].C.Pawn.ClientMessage("You get " $ Int(Bonus) $ " bonus pts for the Capture!" @ CarriedString(FlagCarriers[i].Time, totalTime));
      }
      else
      {
        bonus = Max(bonus, 1);

        if (class'MutUTComp'.Default.bShowAssistConsoleMsg)
          FlagCarriers[i].C.Pawn.ClientMessage("You get " $ Int(Bonus) $ " pts for the Assist!" @ CarriedString(FlagCarriers[i].Time, TotalTime));

        uPRI = class'UTComp_Util'.static.GetUTCompPRI(FlagCarriers[i].C.PlayerReplicationInfo);
        uPRI.Assists++;
      }

      FlagCarriers[i].C.PlayerReplicationInfo.Score += bonus;
    }
  }
}

/*
  Reset the carriers, for when a flag is returned. Called by UTCompCTF_xCTFGame
*/
function ResetFlagCarriers()
{
  FlagCarriers.Remove(0, FlagCarriers.Length);
  PickupTime = 0;
  //Log("PickupTime:"@PickupTime);
}

function LogDropped()
{
  AddFlagCarrier(Holder.Controller);

  Super.LogDropped();
}

auto state Home
{
    // Flag Grab
    function LogTaken(Controller c)
    {
      local UTComp_PRI uPRI;

      ResetFlagCarriers();

      PickupTime = Level.TimeSeconds;
      //Log("PickupTime:"@PickupTime);

      uPRI = class'UTComp_Util'.static.GetUTCompPRI(c.PlayerReplicationInfo);
      uPRI.FlagGrabs++;

      c.PlayerReplicationInfo.Score += class'MutUTComp'.Default.GrabBonus;

      Super.LogTaken(c);
    }

    function SameTeamTouch(Controller c)
    {
      local UTComp_CTFFlag otherFlag;

      if (C.PlayerReplicationInfo.HasFlag == None || !C.PlayerReplicationInfo.HasFlag.isA('UTComp_CTFFlag'))
        return;

      otherFlag = UTComp_CTFFlag(C.PlayerReplicationInfo.HasFlag);
      otherFlag.OldHolder = otherFlag.Holder;

      // Capped the other flag! Doing so, we touched our own so this is where we are at.

      // This next line calls CTFGame.ScoreFlag. We don't want that since we have
      // our own points for scoring.
      //UnrealMPGameInfo(Level.Game).ScoreGameObject(C, otherFlag);
      otherFlag.ScoreFlag(c);
      otherFlag.Score();
      TriggerEvent(HomeBase.Event, HomeBase, C.Pawn);

      if (Bot(C) != None)
          Bot(C).Squad.SetAlternatePath(true);
    }
}

state Dropped
{
    function SameTeamTouch(Controller c)
    {
      // returned flag
      ScoreFlag(c);
      SendHome();
    }
    // Flag Pickup
    function LogTaken(Controller c)
    {
        local UTComp_PRI uPRI;
        local bool bCountPickup;
        local int i;

        PickupTime = Level.TimeSeconds;
        //Log("PickupTime:"@PickupTime);

        uPRI = class'UTComp_Util'.static.GetUTCompPRI(c.PlayerReplicationInfo);

        bCountPickup = true;

        // Count only one pickup from a run. The flag grab counts.
        if (FirstTouch == Controller(uPRI.Owner))
            bCountPickup = false;
        else
        {
            for (i=0; i < Assists.Length; i++)
            {
                if (Assists[i] == Controller(uPRI.Owner))
                {
                   bCountPickup = false;
                   break;
                }
            }
        }

        if (bCountPickup)
            uPRI.FlagPickups++;



       Super.LogTaken(c);
    }
}

DefaultProperties
{

}