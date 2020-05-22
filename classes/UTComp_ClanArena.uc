
class UTComp_ClanArena extends xTeamGame;

var config float LockWeaponTime;
var UTComp_Warmup uWarmup;
var int RoundTimeRemaining;
var bool bWeaponsLocked;
var int lastscoredteam;

var string SecondaryMutatorClass;

const HEALTH_REMOVE = 5.0;
const RESTART_WAIT_TIME = 8.0;

var config int Round_Health;
var config int Round_Armor;

var bool bGameInProgress;
var array<PlayerController> WaitingPlayer;

function PostBeginPlay()
{
    super.PostBeginPlay();

    SpawnProtectionTime = LockWeaponTime - 2;
    bAllowWeaponThrowing=false;
}

event InitGame( string Options, out string Error )
{
    super.InitGame(Options,Error);
    AddMutator(SecondaryMutatorClass);
}

function StartMatch()
{
    super.StartMatch();
    if(uWarmup.bInWarmup)
    {
       bGameInProgress=false;
       return;
    }
    LockWeapons();
    bWeaponsLocked=True;
    uWarmup.SetClientTimerOnly(RemainingTime);
    bGameInProgress=true;
}

function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	if ( ViewTarget == None || uWarmup.bWaitingOnRestart || ElapsedTime < 5)
		return false;
    if ( bOnlySpectator )
	{
		if ( Controller(ViewTarget) != None )
			return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator
                && !Controller(ViewTarget).PlayerReplicationInfo.bOutOfLives );
		return true;
	}
	if ( Controller(ViewTarget) != None )
		return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOutOfLives
				&& (Controller(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
	return ( (Pawn(ViewTarget) != None)
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}

state MatchInProgress
{
   function Timer()
   {
       local int i;
       super.Timer();
       if(uWarmup.bInWarmup)
           return;
       GameReplicationInfo.RemainingTime = RoundTimeRemaining;
       if ( RoundTimeRemaining % 60 == 0 )
           GameReplicationInfo.RemainingMinute = RoundTimeRemaining;
       SpecForce();
       if(ElapsedTime == LockWeaponTime)
       {
           UnlockWeapons();
           BroadcastLocalizedMessage(class'Unlock_Beep');
       }
       else if(ElapsedTime < LockWeaponTime)
       {
           BroadcastLocalizedMessage(class'Silent_TimerMessage', LockWeaponTime - ElapsedTime);
           BroadcastLocalizedMessage(class'RoundMessage', ((Teams[0].Score+Teams[1].Score+1)<< 10) + (GoalScore*2-1));
       }
       if(bOvertime && !uWarmup.bInWarmup && !uWarmup.bWaitingOnRestart)
       {
           DrainHealth();
           SetClockTimes();
       }


       	if ( !bGameInProgress && WaitingPlayer.Length >0 )
		{
			for(i=0; i<WaitingPlayer.Length; i++)
			{
            	WaitingPlayer[i].BecomeActivePlayer();
				WaitingPlayer.Remove (i,1);
			}
		}
   }
}

function SpecForce ()
{
	local Controller C;


	for(C = Level.ControllerList; C!=None; C=C.NextController)
	{
		if ( C.IsA('PlayerController') )
		{
			if ( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.Pawn==None && PlayerController(C).ViewTarget == C )
			{
				PlayerController(C).ServerViewNextPlayer();
				PlayerController(C).BehindView(False);
			}
		}
	}
}

function SetClockTimes ()
{
	local Controller C;

	for(C = Level.ControllerList; C!=None; C=C.NextController)
	{
		if ( C.IsA('BS_xPlayer') )
		{
			BS_xPlayer(C).SetClockTime(0);
		}
	}
}

function DrainHealth()
{
    local controller c;
    local vector V;
    local array<pawn> pRed;
    local array<pawn> pBlue;
    local int i;
    local bool bRedLiving, bBlueLiving;

    for(C=Level.controllerlist; C!=None; C=C.NextController)
    {
        if(C.Pawn!=None && C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOutOfLives)
        {
            if(c.pawn.Health - HEALTH_REMOVE <=0)
            {
                if(c.pawn.GetTeamNum()==0)
                {
                    i=pRed.length;
                    pRed.length=i+1;
                    pRed[i]=c.pawn;
                }
                else
                {
                    i=pblue.length;
                    pblue.length=i+1;
                    pblue[i]=c.pawn;
                }
            }
            else
            {
                c.pawn.Health -=HEALTH_REMOVE;
                if(c.Pawn.GetTeamNum() == 0)
                    bRedLiving=true;
                else
                    bBlueLiving=true;
            }
        }
    }
    if(bRedLiving || bBlueLiving)
    {
       for(i=0; i<pRed.Length; i++)
            pRed[i].TakeDamage(HEALTH_REMOVE, pRed[i],pRed[i].location,v,class'UTComp_HealthDrain');
       for(i=0; i<pBlue.Length; i++)
            pBlue[i].TakeDamage(HEALTH_REMOVE, pBlue[i],pBlue[i].location,v,class'UTComp_HealthDrain');
    }
    else if((pRed.Length > pBlue.length || (LastScoredTeam==0 && pRed.Length == pBlue.length)) && pBlue.Length >= 0 )
       for(i=0; i<pBlue.Length; i++)
            pBlue[i].TakeDamage(HEALTH_REMOVE, pBlue[i],pBlue[i].location,v,class'UTComp_HealthDrain');
    else
       for(i=0; i<pRed.Length; i++)
            pRed[i].TakeDamage(HEALTH_REMOVE, pRed[i],pRed[i].location,v,class'UTComp_HealthDrain');

}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    local utcomp_pri uPRI;

    Damage=Super.ReduceDamage(damage,injured, instigatedby, hitlocation, momentum, damagetype);
    if(instigatedby!=None)
        uPRI = class'UTComp_Util'.static.GetUTCompPRIForPawn(Instigatedby);
    if(uPRI!=None)
    {
        if(InstigatedBy!=None && Injured!=None && InstigatedBy.GetTeamNum() != Injured.GetTeamNum() && InstigatedBy.PlayerReplicationInfo!=None)
            InstigatedBy.PlayerReplicationInfo.Score+= (uPRI.TotalDamageG+Damage)/100 - uPRI.TotalDamageG/100;
        uPRI.TotalDamageG+=Damage;
    }
    return damage;
}

function LockWeapons()
{
    local controller C;
    local inventory inv;
    if(uWarmup.bInWarmup)
         return;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(C.Pawn!=None)
        {
            for(Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory)
            {
               if(UTComp_AssaultRifle(Inv)!=None)
                  UTComp_AssaultRifle(Inv).LockOut();
               else if( UTComp_BioRifle(Inv)!=None)
                  UTComp_BioRifle(Inv).LockOut();
               else if(UTComp_ShockRifle(Inv)!=None)
                  UTComp_ShockRifle(Inv).LockOut();
               else if(UTComp_MiniGun(Inv)!=None)
                  UTComp_MiniGun(Inv).LockOut();
               else if(UTComp_LinkGun(Inv)!=None)
                  UTComp_LinkGun(Inv).LockOut();
               else if(UTComp_RocketLauncher(Inv)!=None)
                  UTComp_RocketLauncher(inv).LockOut();
               else if(UTComp_FlakCannon(inv)!=None)
                  UTComp_FlakCannon(inv).LockOut();
               else if(UTComp_SniperRifle(inv)!=None)
                  UTComp_SniperRifle(inv).LockOut();
               else if(UTComp_ShieldGun(inv)!=None)
                  UTComp_ShieldGun(inv).LockOut();
            }
        }
    }
}

function UnLockWeapons()
{
    local controller C;
    local inventory inv;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(C.Pawn!=None)
        {
             for(Inv=C.Pawn.Inventory; Inv!=None; Inv=Inv.Inventory)
            {

               if(UTComp_AssaultRifle(Inv)!=None)
                  UTComp_AssaultRifle(Inv).UnLock();
               else if( UTComp_BioRifle(Inv)!=None)
                  UTComp_BioRifle(Inv).UnLock();
               else if(UTComp_ShockRifle(Inv)!=None)
                  UTComp_ShockRifle(Inv).UnLock();
               else if(UTComp_MiniGun(Inv)!=None)
                  UTComp_MiniGun(Inv).UnLock();
               else if(UTComp_LinkGun(Inv)!=None)
                  UTComp_LinkGun(Inv).UnLock();
               else if(UTComp_RocketLauncher(Inv)!=None)
                  UTComp_RocketLauncher(inv).UnLock();
               else if(UTComp_FlakCannon(inv)!=None)
                  UTComp_FlakCannon(inv).UnLock();
               else if(UTComp_SniperRifle(inv)!=None)
                  UTComp_SniperRifle(inv).UnLock();
               else if(UTComp_ShieldGun(inv)!=None)
                  UTComp_ShieldGun(inv).UnLock();
            }
        }
    }
    bWeaponsLocked=false;
}

function Tick(float deltatime)
{
   super.Tick(deltatime);
   if(uWarmup==None)
      foreach dynamicactors(class'UTComp_warmup', uWarmup)
          break;
}

function CheckEndRound(controller Killer,controller Other)
{
	local int TeamToCheck;
	local controller C;

    if(uWarmup.bSoftRestart)
	    return;

    TeamToCheck=Other.GetTeamNum();
    if(TeamToCheck == 1)
        LastScoredTeam = 0;
    else
        LastScoredTeam = 1;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(C!=Other && C.GetTeamNum() == TeamToCheck && C.PlayerReplicationInfo != none && !C.PlayerReplicationInfo.bOutOfLives && !C.IsInState('Spectating'))
             return;
    }
    if(teamToCheck == 1)
        TeamToCheck = 0;
    else
        TeamToCheck = 1;
    if(Killer == none || Killer == Other)
    {
        EndRound(TeamToCheck,None);
    }
    else
        EndRound(TeamToCheck, Killer.PlayerReplicationInfo);
}

function SitOut(Controller Other)
{
    if(Other.PlayerReplicationInfo!=None)
        Other.PlayerReplicationInfo.bOutOfLives=True;
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
    local controller C;
    if(Reason != "FragLimit" || uWarmup.bInWarmup)
        return false;

	if ( Teams[1].Score > Teams[0].Score )
		GameReplicationInfo.Winner = Teams[1];
	else
		GameReplicationInfo.Winner = Teams[0];

	EndTime = Level.TimeSeconds + EndTimeDelay;

	SetEndGameFocus(Winner);


    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
       if(C.PlayerReplicationInfo!=None && C.GetTeamNum()!=255)
       {
           C.PlayerReplicationInfo.bOutOfLives=false;
       }
    }

	return true;
}


function ScoreKill(Controller Killer, Controller Other)
{
	if(uWarmup.bInWarmup || uWarmup.bWaitingOnRestart)
	    return;

    TeamGameScoreKill(Killer,Other);
    SitOut(Other);
    CheckEndRound(killer,other);

}

function PlayStartupMessage()
{
	local Controller P;

    // keep message displayed for waiting players
    if(StartupStage==5||startupstage==6)
        return;
    for (P=Level.ControllerList; P!=None; P=P.NextController )
        if ( UnrealPlayer(P) != None )
            UnrealPlayer(P).PlayStartUpMessage(StartupStage);
}


function TeamGameScoreKill(Controller Killer, Controller Other)
{
	local Pawn Target;

	if ( !Other.bIsPlayer || ((Killer != None) && !Killer.bIsPlayer) )
	{
		super(Deathmatch).ScoreKill(Killer, Other);
		return;
	}

	if ( (Killer == None) || (Killer == Other)
		|| (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
	{
		if ( (Killer!=None) && (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
		{
			if ( Other.PlayerReplicationInfo.HasFlag != None )
			{
				Killer.AwardAdrenaline(ADR_MajorKill);
				GameObject(Other.PlayerReplicationInfo.HasFlag).bLastSecondSave = NearGoal(Other);
			}

			// Kill Bonuses work as follows (in additional to the default 1 point
			//	+1 Point for killing an enemy targetting an important player on your team
			//	+2 Points for killing an enemy important player

			if ( CriticalPlayer(Other) )
			{
				Killer.PlayerReplicationInfo.Score+= 2;
				Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
				ScoreEvent(Killer.PlayerReplicationInfo,1,"critical_frag");
			}

			if (bScoreVictimsTarget)
			{
				Target = FindVictimsTarget(Other);
				if ( (Target!=None) && (Target.PlayerReplicationInfo!=None) &&
				       (Target.PlayerReplicationInfo.Team == Killer.PlayerReplicationInfo.Team) && CriticalPlayer(Target.Controller) )
				{
					Killer.PlayerReplicationInfo.Score+=1;
					Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
					ScoreEvent(Killer.PlayerReplicationInfo,1,"team_protect_frag");
				}
			}

		}
		super(DeathMatch).ScoreKill(Killer, Other);
	}
	else if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( !bScoreTeamKills )
	{
		if ( Other.bIsPlayer && (Killer != None) && Killer.bIsPlayer && (Killer != Other)
			&& (Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		{
			Killer.PlayerReplicationInfo.Score -= 1;
			Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Killer.PlayerReplicationInfo, -1, "team_frag");
		}
		return;
	}
	if ( Other.bIsPlayer )
	{
		if ( (Killer == None) || (Killer == Other) )
		{
            TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "team_frag");
		}
		else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
		{
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
		}
		else if ( FriendlyFireScale > 0 )
		{
			Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			Killer.PlayerReplicationInfo.Score -= 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "team_frag");
		}
	}

	// check score again to see if team won
    if ( (Killer != None) && bScoreTeamKills )
		CheckScore(Killer.PlayerReplicationInfo);
}

function CheckScore(PlayerReplicationInfo Scorer)
{
    return;
}

function EndRound(int TeamThatWon, PlayerReplicationInfo Winner)
{
    if(Winner==None)
    {
        Teams[TeamThatWon].Score +=1;
        Teams[TeamThatWon].NetUpdateTime = Level.TimeSeconds - 1;
        if(Teams[TeamThatWon].Score >= GoalScore)
        {
            EndGame(Winner, "FragLimit");
            return;
        }
    }
    else
    {
        Winner.Team.Score += 1;
        Winner.Team.NetUpdateTime = Level.TimeSeconds - 1;
        if(Winner.Team.Score >= GoalScore)
        {
            EndGame(Winner, "FragLimit");
            return;
        }
    }

    BroadcastLocalizedMessage(class'RoundWonMessage',teamthatwon);
    uWarmup.TimedRestart(RESTART_WAIT_TIME);
    GameReplicationInfo.RemainingTime = 150.0;
    GameReplicationInfo.RemainingMinute = 150.0; // don't spam people if itme is still counting down
    bGameInProgress = false;

}

function AddGameSpecificInventory(Pawn p)
{
    local inventory inv;
    if(!class'MutUTComp'.default.bEnableEnhancedNetCode)
    {
        p.CreateInventory("UTCompv18.UTComp_ShieldGun");
        p.CreateInventory("UTCompv18.UTComp_AssaultRifle");
        p.CreateInventory("UTCompv18.UTComp_BioRifle");
        p.CreateInventory("UTCompv18.UTComp_MiniGun");
        p.CreateInventory("UTCompv18.UTComp_ShockRifle");
        p.CreateInventory("UTCompv18.UTComp_LinkGun");
        p.CreateInventory("UTCompv18.UTComp_FlakCannon");
        p.CreateInventory("UTCompv18.UTComp_RocketLauncher");
        p.CreateInventory("UTCompv18.UTComp_SniperRifle");
   }
   else
   {
        p.CreateInventory("UTCompv18.UTComp_ShieldGun");
        p.CreateInventory("UTCompv18.NewNet_AssaultRifle");
        p.CreateInventory("UTCompv18.NewNet_BioRifle");
        p.CreateInventory("UTCompv18.NewNet_MiniGun");
        p.CreateInventory("UTCompv18.NewNet_ShockRifle");
        p.CreateInventory("UTCompv18.NewNet_LinkGun");
        p.CreateInventory("UTCompv18.NewNet_FlakCannon");
        p.CreateInventory("UTCompv18.NewNet_RocketLauncher");
        p.CreateInventory("UTCompv18.NewNet_SniperRifle");
   }
   for(inv=p.Inventory; inv!=None; inv=inv.inventory)
   {
       if(weapon(inv)!=None)
       {
           Weapon(inv).Loaded();
           Weapon(inv).MaxOutAmmo();
       }
   }
   p.GiveHealth(Round_Health, Round_Health);
   if(p.ShieldStrength < Round_Armor)
       p.AddShieldStrength(Round_Armor-p.ShieldStrength);


   if(bWeaponsLocked && p.Controller!=None && p.Controller.IsA('bot'))
      for(Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory)
     {
               if(UTComp_AssaultRifle(Inv)!=None)
                  UTComp_AssaultRifle(Inv).LockOut();
               else if( UTComp_BioRifle(Inv)!=None)
                  UTComp_BioRifle(Inv).LockOut();
               else if(UTComp_ShockRifle(Inv)!=None)
                  UTComp_ShockRifle(Inv).LockOut();
               else if(UTComp_MiniGun(Inv)!=None)
                  UTComp_MiniGun(Inv).LockOut();
               else if(UTComp_LinkGun(Inv)!=None)
                  UTComp_LinkGun(Inv).LockOut();
               else if(UTComp_RocketLauncher(Inv)!=None)
                  UTComp_RocketLauncher(inv).LockOut();
               else if(UTComp_FlakCannon(inv)!=None)
                  UTComp_FlakCannon(inv).LockOut();
               else if(UTComp_SniperRifle(inv)!=None)
                  UTComp_SniperRifle(inv).LockOut();
               else if(UTComp_ShieldGun(inv)!=None)
                  UTComp_ShieldGun(inv).LockOut();
            }
}
event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
    local PlayerController NewPlayer;
    local controller c;

    newplayer =  super.Login(portal, options, error);
    if(!uWarmup.bInWarmup && numPlayers > 1)
    {
        for(C=Level.controllerlist; C!=None; C=C.nExtcontroller)
            if(C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && !C.PlayerReplicationInfo.bOutOfLives)
            {
                    newplayer.playerreplicationinfo.boutoflives=true;
                    break;
            }
    }
    return newplayer;
}

function bool AllowBecomeActivePlayer (PlayerController P)
{
	local int i;

	if ( (NumPlayers+NumBots) >1 && bGameInProgress )
	{
		i = WaitingPlayer.Length;
		WaitingPlayer.Length = i+1;
		WaitingPlayer[i] = P;
		P.ClientMessage("You will be added to a team when the current round ends");
		return False;
	}
	return Super.AllowBecomeActivePlayer(P);
}

DefaultProperties
{
     MaxLives=0
     LockWeaponTime = 6.0
     TimeLimit = 2
     GoalScore=8
     GameName="UTComp Clan Arena 1.7 Beta4SRC"
     bAllowWeaponThrowing=false
     SecondaryMutatorClass="UTCompv18.MutUTComp"
     Round_Health = 150
     Round_Armor = 100
     Description = "No Powerups, No Distractions, Full Weapon and armor Load! Kill the enemy team before they kill yours. Dead players are out until the round is over."
     FriendlyFireScale = 0.0
     BroadcastHandlerClass="BonusPack.LMSBroadcastHandler"



