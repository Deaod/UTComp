class UTComp_ClanArena extends xTeamGame;

var UTComp_Warmup uWarmup;
var int RoundTimeRemaining;
var bool bWeaponsLocked;
var int lastscoredteam;
var bool bFirstSpawn;

var string SecondaryMutatorClass;

const HEALTH_REMOVE = 5.0;
const RESTART_WAIT_TIME = 8.0;

var config float LockWeaponTime;
var config int RoundHealth;
var config int MaxHealth;
var config int RoundArmor;
var config int MaxArmor;
var config int AssaultRifleAmmo;
var config int AssaultRifleGrenades;
var config int BioRifleAmmo;
var config int ShockRifleAmmo;
var config int LinkGunAmmo;
var config int MinigunAmmo;
var config int FlakCannonAmmo;
var config int RocketLauncherAmmo;
var config int LightningGunAmmo;

var localized string LockWeaponTimeTitle;
var localized string RoundHealthTitle;
var localized string MaxHealthTitle;
var localized string RoundArmorTitle;
var localized string MaxArmorTitle;
var localized string AssaultRifleAmmoTitle;
var localized string AssaultRifleGrenadesTitle;
var localized string BioRifleAmmoTitle;
var localized string ShockRifleAmmoTitle;
var localized string LinkGunAmmoTitle;
var localized string MinigunAmmoTitle;
var localized string FlakCannonAmmoTitle;
var localized string RocketLauncherAmmoTitle;
var localized string LightningGunAmmoTitle;

var localized string LockWeaponTimeDesc;
var localized string RoundHealthDesc;
var localized string MaxHealthDesc;
var localized string RoundArmorDesc;
var localized string MaxArmorDesc;
var localized string AssaultRifleAmmoDesc;
var localized string AssaultRifleGrenadesDesc;
var localized string BioRifleAmmoDesc;
var localized string ShockRifleAmmoDesc;
var localized string LinkGunAmmoDesc;
var localized string MinigunAmmoDesc;
var localized string FlakCannonAmmoDesc;
var localized string RocketLauncherAmmoDesc;
var localized string LightningGunAmmoDesc;

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
    bFirstSpawn = true;
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

/* Return the 'best' player start for this player to start from.
 */
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
    local NavigationPoint N, BestStart;
    local Teleporter Tel;
    local float BestRating, NewRating;
    local byte Team;

    if((Player != None) && (Player.StartSpot != None))
        LastPlayerStartSpot = Player.StartSpot;

    // always pick StartSpot at start of match
    if(Level.NetMode == NM_Standalone && bWaitingToStartMatch && Player != None && Player.StartSpot != None)
    {
        return Player.StartSpot;
    }

    if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player, InTeam, incomingName);
        if ( N != None )
            return N;
    }

    // if incoming start is specified, then just use it
    if( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if( string(Tel.Tag)~=incomingName )
                return Tel;

    // use InTeam if player doesn't have a team yet
    if((Player != None) && (Player.PlayerReplicationInfo != None))
    {
        if(Player.PlayerReplicationInfo.Team != None)
            Team = Player.PlayerReplicationInfo.Team.TeamIndex;
        else
            Team = InTeam;
    }
    else
        Team = InTeam;

    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
    {
        if(N.IsA('PathNode') || N.IsA('PlayerStart') || N.IsA('JumpSpot'))
            NewRating = RatePlayerStart(N, Team, Player);
        else
            NewRating = 1;
        if ( NewRating > BestRating )
        {
            BestRating = NewRating;
            BestStart = N;
        }
    }

    if (BestStart == None)
    {
        log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
        BestRating = -100000000;
        ForEach AllActors( class 'NavigationPoint', N )
        {
            NewRating = RatePlayerStart(N,0,Player);
            if ( InventorySpot(N) != None )
                NewRating -= 50;
            NewRating += 20 * FRand();
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = N;
            }
        }
    }

    LastStartSpot = BestStart;
    if(Player != None)
        Player.StartSpot = BestStart;

    if(!bWaitingToStartMatch)
        bFirstSpawn = false;

    return BestStart;
}

function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local NavigationPoint P;
    local float Score, NextDist;
    local Controller OtherPlayer;

    P = N;

    if ((P == None) || P.PhysicsVolume.bWaterVolume || Player == None)
        return -10000000;

    /*if(bFirstSpawn && Player != None && Player.bIsPlayer)
        return(FMax(4000000.0 * FRand(), 5));*/

    Score = 1000000.0;

    if(bFirstSpawn && LastPlayerStartSpot != None)
    {
        NextDist = VSize(N.Location - LastPlayerStartSpot.Location);
        Score += (NextDist * (0.25 + 0.75 * FRand()));

        if(N == LastStartSpot || N == LastPlayerStartSpot)
            Score -= 100000000.0;
        else if(FastTrace(N.Location, LastPlayerStartSpot.Location))
            Score -= 1000000.0;
    }

    //Score += (N.Location.Z * 10) * FRand();

    for(OtherPlayer = Level.ControllerList; OtherPlayer != None; OtherPlayer = OtherPlayer.NextController)
    {
        if(OtherPlayer != None && OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None))
        {
            NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);

            if(NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight)
                return 0.0;
            else
            {
                // same team
                if(OtherPlayer.GetTeamNum() == Player.GetTeamNum() && OtherPlayer != Player)
                {
                    if(FastTrace(OtherPlayer.Pawn.Location, N.Location))
                        Score += 10000.0;

                    if(NextDist > 1500)
                        Score -= (NextDist * 10);
                    else if (NextDist < 1000)
                        Score += (NextDist * 10);
                    else
                        Score += (NextDist * 20);
                }
                // different team
                else if(OtherPlayer.GetTeamNum() != Player.GetTeamNum())
                {
                    if(FastTrace(OtherPlayer.Pawn.Location, N.Location))
                        Score -= 20000.0;       // strongly discourage spawning in line-of-sight of an enemy

                    Score += (NextDist * 10);
                }
            }
        }
    }

    return FMax(Score, 5);
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

function int ReduceDamage( int Damage, pawn Injured, pawn InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType ) {
    local UTComp_PRI uPRI;

    Damage = super.ReduceDamage(Damage, Injured, Instigatedby, HitLocation, Momentum, DamageType);
    if (InstigatedBy != none)
        uPRI = class'UTComp_Util'.static.GetUTCompPRIForPawn(Instigatedby);
    
    if (uPRI != none) {
        if (InstigatedBy != none &&
            Injured != none &&
            InstigatedBy.GetTeamNum() != Injured.GetTeamNum() &&
            InstigatedBy.PlayerReplicationInfo != none
        ) {
            InstigatedBy.PlayerReplicationInfo.Score += (float(Damage) / 100.0);
        }
        uPRI.TotalDamageG += Damage;
    }
    return Damage;
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

    for (C = Level.ControllerList; C != None; C = C.NextController)
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


function GiveWeaponTo(string InventoryClassName, Pawn P, int StartingAmmoPrimary, int StartingAmmoSecondary)
{
    local Weapon W;
    local class<Inventory> InventoryClass;

    InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
    if( (InventoryClass!=None) && (P.FindInventoryType(InventoryClass)==None) && ClassIsChildOf(InventoryClass, class'Engine.Weapon') )
    {
        W = Weapon(P.Spawn(InventoryClass));
        if( W != None )
        {
            W.GiveTo(P);
            if ( W != None )
                W.PickupFunction(P);

            if (uWarmup.bInWarmup) {
                W.SuperMaxOutAmmo();
            } else {
                if (StartingAmmoPrimary >= 0)
                    W.AddAmmo(StartingAmmoPrimary - W.AmmoAmount(0), 0);
                else if (StartingAmmoPrimary == -1)
                    W.MaxAmmo(0);

                if (StartingAmmoSecondary >= 0)
                    W.AddAmmo(StartingAmmoSecondary - W.AmmoAmount(1), 1);
                else if (StartingAmmoSecondary == -1);
                    W.MaxAmmo(1);
            }
        }
    }
}

function AddGameSpecificInventory(Pawn P)
{
    local inventory inv;
    if(!class'MutUTComp'.default.bEnableEnhancedNetCode)
    {
        GiveWeaponTo("UTCompv18c.UTComp_ShieldGun", P, -1, -1);
        GiveWeaponTo("UTCompv18c.UTComp_AssaultRifle", P, AssaultRifleAmmo, AssaultRifleGrenades);
        GiveWeaponTo("UTCompv18c.UTComp_BioRifle", P, BioRifleAmmo, -2);
        GiveWeaponTo("UTCompv18c.UTComp_ShockRifle", P, ShockRifleAmmo, -2);
        GiveWeaponTo("UTCompv18c.UTComp_LinkGun", P, LinkGunAmmo, -2);
        GiveWeaponTo("UTCompv18c.UTComp_MiniGun", P, MinigunAmmo, -2);
        GiveWeaponTo("UTCompv18c.UTComp_FlakCannon", P, FlakCannonAmmo, -2);
        GiveWeaponTo("UTCompv18c.UTComp_RocketLauncher", P, RocketLauncherAmmo, -2);
        GiveWeaponTo("UTCompv18c.UTComp_SniperRifle", P, LightningGunAmmo, -2);
    }
    else
    {
        GiveWeaponTo("UTCompv18c.UTComp_ShieldGun", P, -1, -1);
        GiveWeaponTo("UTCompv18c.NewNet_AssaultRifle", P, AssaultRifleAmmo, AssaultRifleGrenades);
        GiveWeaponTo("UTCompv18c.NewNet_BioRifle", P, BioRifleAmmo, -2);
        GiveWeaponTo("UTCompv18c.NewNet_ShockRifle", P, ShockRifleAmmo, -2);
        GiveWeaponTo("UTCompv18c.NewNet_LinkGun", P, LinkGunAmmo, -2);
        GiveWeaponTo("UTCompv18c.NewNet_MiniGun", P, MinigunAmmo, -2);
        GiveWeaponTo("UTCompv18c.NewNet_FlakCannon", P, FlakCannonAmmo, -2);
        GiveWeaponTo("UTCompv18c.NewNet_RocketLauncher", P, RocketLauncherAmmo, -2);
        GiveWeaponTo("UTCompv18c.NewNet_SniperRifle", P, LightningGunAmmo, -2);
    }
    P.SuperHealthMax = MaxHealth;
    xPawn(P).ShieldStrengthMax = MaxArmor;
    P.GiveHealth(RoundHealth, RoundHealth);
    if(P.ShieldStrength < RoundArmor)
        P.AddShieldStrength(RoundArmor-P.ShieldStrength);


    if (bWeaponsLocked && P.Controller!=None && P.Controller.IsA('bot'))
        for (Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory)
        {
            if (UTComp_AssaultRifle(Inv)!=None)
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

static function FillPlayInfo(PlayInfo I) {
    super.FillPlayInfo(I);

    I.AddSetting(default.GameName, "LockWeaponTime",       default.LockWeaponTimeTitle,       0,  0, "Text");
    I.AddSetting(default.GameName, "RoundHealth",          default.RoundHealthTitle,          0,  1, "Text", "3;1:999");
    I.AddSetting(default.GameName, "MaxHealth",            default.MaxHealthTitle,            0,  2, "Text", "3;1:999");
    I.AddSetting(default.GameName, "RoundArmor",           default.RoundArmorTitle,           0,  3, "Text", "3;0:999");
    I.AddSetting(default.GameName, "MaxArmor",             default.MaxArmorTitle,             0,  4, "Text", "3;0:999");
    I.AddSetting(default.GameName, "AssaultRifleAmmo",     default.AssaultRifleAmmoTitle,     0,  5, "Text", "3;0:200");
    I.AddSetting(default.GameName, "AssaultRifleGrenades", default.AssaultRifleGrenadesTitle, 0,  6, "Text", "1;0:8");
    I.AddSetting(default.GameName, "BioRifleAmmo",         default.BioRifleAmmoTitle,         0,  7, "Text", "2;0:50");
    I.AddSetting(default.GameName, "ShockRifleAmmo",       default.ShockRifleAmmoTitle,       0,  8, "Text", "2;0:50");
    I.AddSetting(default.GameName, "LinkGunAmmo",          default.LinkGunAmmoTitle,          0,  9, "Text", "3;0:220");
    I.AddSetting(default.GameName, "MinigunAmmo",          default.MinigunAmmoTitle,          0, 10, "Text", "3;0:300");
    I.AddSetting(default.GameName, "FlakCannonAmmo",       default.FlakCannonAmmoTitle,       0, 11, "Text", "2;0:35");
    I.AddSetting(default.GameName, "RocketLauncherAmmo",   default.RocketLauncherAmmoTitle,   0, 12, "Text", "2;0:30");
    I.AddSetting(default.GameName, "LightningGunAmmo",     default.LightningGunAmmoTitle,     0, 13, "Text", "2;0:40");
}

static event string GetDescriptionText(string PropName)
{
    switch(PropName) {
        case "LockWeaponTime":       return default.LockWeaponTimeDesc;
        case "RoundHealth":          return default.RoundHealthDesc;
        case "MaxHealth":            return default.MaxHealthDesc;
        case "RoundArmor":           return default.RoundArmorDesc;
        case "MaxArmor":             return default.MaxArmorDesc;
        case "AssaultRifleAmmo":     return default.AssaultRifleAmmoDesc;
        case "AssaultRifleGrenades": return default.AssaultRifleGrenadesDesc;
        case "BioRifleAmmo":         return default.BioRifleAmmoDesc;
        case "ShockRifleAmmo":       return default.ShockRifleAmmoDesc;
        case "LinkGunAmmo":          return default.LinkGunAmmoDesc;
        case "MinigunAmmo":          return default.MinigunAmmoDesc;
        case "FlakCannonAmmo":       return default.FlakCannonAmmoDesc;
        case "RocketLauncherAmmo":   return default.RocketLauncherAmmoDesc;
        case "LightningGunAmmo":     return default.LightningGunAmmoDesc;
    }
    return super.GetDescriptionText(PropName);
}

DefaultProperties
{
    MaxLives=0
    LockWeaponTime=6.0
    TimeLimit = 2
    GoalScore=8
    GameName="UTComp Clan Arena 1.8c"
    bAllowWeaponThrowing=false
    SecondaryMutatorClass="UTCompv18c.MutUTComp"
    Description = "No Powerups, No Distractions, Full Weapon and armor Load! Kill the enemy team before they kill yours. Dead players are out until the round is over."
    FriendlyFireScale = 0.0
    BroadcastHandlerClass="BonusPack.LMSBroadcastHandler"

    RoundHealth = 100
    MaxHealth = 125
    RoundArmor = 100
    MaxArmor = 125
    AssaultRifleAmmo = 200
    AssaultRifleGrenades = 8
    BioRifleAmmo = 50
    ShockRifleAmmo = 50
    LinkGunAmmo = 220
    MinigunAmmo = 300
    FlakCannonAmmo = 35
    RocketLauncherAmmo = 30
    LightningGunAmmo = 40

    LockWeaponTimeTitle = "Weapon Unlock Delay"
    RoundHealthTitle = "Starting Health"
    MaxHealthTitle = "Maximum Health"
    RoundArmorTitle = "Starting Armor"
    MaxArmorTitle = "Maximum Armor"
    AssaultRifleAmmoTitle = "Assault Rifle Ammo"
    AssaultRifleGrenadesTitle = "Assault Rifle Grenades"
    BioRifleAmmoTitle = "Bio Rifle Ammo"
    ShockRifleAmmoTitle = "Shock Rifle Ammo"
    LinkGunAmmoTitle = "Link Gun Ammo"
    MinigunAmmoTitle = "Minigun Ammo"
    FlakCannonAmmoTitle = "Flak Cannon Ammo"
    RocketLauncherAmmoTitle = "Rocket Launcher Ammo"
    LightningGunAmmoTitle = "Lightning Gun Ammo"

    LockWeaponTimeDesc = "How many seconds weapons are locked for at the start of each round"
    RoundHealthDesc = "How much health players start with each round"
    MaxHealthDesc = "How much health players can have at most"
    RoundArmorDesc = "How much armor player start with each round"
    MaxArmorDesc = "How much armor player can have at most"
    AssaultRifleAmmoDesc = "Assault Rifle ammo given to each player at the start of each round"
    AssaultRifleGrenadesDesc = "Assault Rifle grenades given to each player at the start of each round"
    BioRifleAmmoDesc = "Bio Rifle ammo given to each player at the start of each round"
    ShockRifleAmmoDesc = "Shock Rifle ammo given to each player at the start of each round"
    LinkGunAmmoDesc = "Link Gun ammo given to each player at the start of each round"
    MinigunAmmoDesc = "Minigun ammo given to each player at the start of each round"
    FlakCannonAmmoDesc = "Flak Cannon ammo given to each player at the start of each round"
    RocketLauncherAmmoDesc = "Rocket Launcher ammo given to each player at the start of each round"
    LightningGunAmmoDesc = "Lightning Gun ammo given to each player at the start of each round"
}



