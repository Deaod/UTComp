
class UTComp_Warmup extends ReplicationInfo;

//General Warmup Settings
var bool bInWarmup;
var bool bInFinalCountdown;
var int iFinalCountDown;
var int iWarmupTime; //0=unlimited, #=time in seconds
var int iWarmupTimeRemaining;
var bool bTimeUnlimitedWarmup;

//For choosing Weapons to give in Warmup
var array<string> sWeaponsToGive;
var bool bWeaponsChecked;

//Readying Up
var float fReadyPercent;
var bool bAdminBypassReady;

var bool bWaitingOnRestart;
var int RestartWaitTime;

//AutoDemoRec
var bool bAutoDemoStarted;
var bool bSoftRestart;

var bool bGivePlayerWeaponHack;

var byte savedbots;

struct SavedPRI
{
    var PlayerReplicationInfo pri;
    var int score;
    var int deaths;
    var int Kills;
};
var Array<SavedPRI> SavedPRIList;

var array<UTComp_PSVisDummy> PSVisDummies;

const iCOUNTDOWNSECONDS = 10;


function InitializeWarmup()
{
    Deathmatch(level.game).bplayersmustbeready=false;
    Deathmatch(level.game).netwait=0;
    Deathmatch(level.game).bwaitfornetplayers=false;

    bInWarmup=True;
    bInFinalCountDown=False;
    iFinalCountDown=0;
    SetTimer(1.0, True);
    if(iWarmupTime<=0)
        bTimeUnlimitedWarmup=True;
    else
        iWarmupTimeRemaining=iWarmupTime;

    InitSpawnVisualization();
}

function InitSpawnVisualization() {
    local PlayerStart PS;
    local UTComp_PSVisDummy PSD;
    local int i;

    if (class'MutUTComp'.default.bShowSpawnsDuringWarmup) {
        i = 0;
        foreach AllActors(class'PlayerStart', PS) {
            PSD = Spawn(class'UTComp_PSVisDummy',,, PS.Location, PS.Rotation);
            PSD.InitDummy(PS);
            PSVisDummies[i] = PSD;
            i++;
        }
    }
}

function RemoveSpawnVisualization() {
    local int i;

    for (i = 0; i < PSVisDummies.Length; i++)
        PSVisDummies[i].Destroy();

    PSVisDummies.Remove(0, PSVisDummies.Length);
}

function SoftRestart()
{
    bSoftRestart=true;
    if(class'MutUTComp'.default.bEnableWarmup || Level.Game.IsA('UTComp_ClanArena'))
    {
        bGivePlayerWeaponHack=True;
        KillAllPlayers();
        EndWarmup(true);
        bGivePlayerWeaponHack=False;
        InitializeWarmup();
        ResetStats();
        NotifyPlayersOfRestart();
        if(bAutoDemoStarted)
        {
            ConsoleCommand("StopDemo");
            bAutoDemoStarted=false;
        }
        bWaitingOnRestart=false;
        if(Level.Game.IsA('UTComp_ClanArena'))
            UTComp_ClanArena(Level.Game).UnlockWeapons();
    }
    bSoftRestart=false;
}

function SoftArenaRestart()
{
        SaveScores();
        KillAllPlayers();
        EndArenaWarmup(true);
        RevertScores();
        bGivePlayerWeaponHack=False;
}

function SaveScores()
{
   local int i;
   local controller c;
   for(C=Level.ControllerList; C!=None; C=C.NextController)
   {
      if(C.PlayerReplicationInfo!=None)
      {
          i = SavedPRIList.Length;
          SavedPRIList.Length = i+1;
          SavedPRIList[i].PRI=C.PlayerReplicationInfo;
          SavedPRIList[i].Score=C.PlayerReplicationInfo.Score;
          SavedPRIList[i].Deaths=C.PlayerReplicationInfo.Deaths;
          SavedPRIList[i].Kills=C.PlayerReplicationInfo.Kills;
      }
   }
}

function RevertScores()
{
    local int i;
    local controller c;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(C.PlayerReplicationInfo!=None)
        {
            for(i=0; i<SavedPRIList.Length; i++)
            {
                if(C.PlayerReplicationInfo == SavedPRIList[i].PRI)
                {
                    C.PlayerReplicationInfo.Kills = SavedPRIList[i].Kills;
                    C.PlayerReplicationInfo.Score = SavedPRIList[i].Score;
                    C.PlayerReplicationInfo.Deaths = SavedPRIList[i].Deaths;
                    break;
                }
            }
        }
    }
    for(i=SavedPRIList.Length-1; i>=0; i--)
    {
        SavedPRIList.Remove(i,1);
    }
}

function NotifyPlayersOfRestart()
{
    local Controller C;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
        if(BS_xPlayer(C)!=None)
        {
            BS_xPlayer(C).NotifyRestartMap();
        }
}

function Timer()
{
    if(bWaitingOnRestart)
    {
        SetClientTimerOnly(150);
        RestartWaitTime--;
        if(RestartWaitTime <=0)
        {
            SoftArenaRestart();
            bWaitingOnRestart=False;
        }
        else if(RestartWaitTime <=5)
           BroadCastLocalizedMessage(class'TimerMessage', RestartWaitTime);
        return;
    }

    if(!bInWarmup)
        return;
    if(bInFinalCountDown)
        WarmupFinalization(iFinalCountDown);
    else if(ReadyCheck() || NoTimeLeftCheck())
        BeginFinalCountdown();
    else
    {
        ResetKills();
        ResetCore();
    }
}

function TimedRestart(int i)
{
    SetTimer(1.0, true);
    bWaitingOnRestart=True;
    RestartWaitTime = i;
}

function ResetKills()
{
    local Controller C;
    local UTComp_PRI uPRI;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if ( C.PlayerReplicationInfo != None)
        {
            C.PlayerReplicationInfo.Kills = 0;
            C.PlayerReplicationInfo.Score = 0;
            C.PlayerReplicationInfo.Deaths = 0;
            C.PlayerReplicationInfo.NumLives=0;
            if (C.PlayerReplicationInfo.Team != none)
                C.PlayerReplicationInfo.Team.Score = 0;
            if(TeamPlayerReplicationInfo(C.PlayerReplicationInfo)!=None)
                TeamPlayerReplicationInfo(C.PlayerReplicationInfo).Suicides=0;
            uPRI=class'UTComp_Util'.static.GetUTCompPRI(C.PlayerReplicationInfo);
            if(uPRI!=None)
                uPRI.RealKills=0;
        }
    }
}

function ResetCore()
{
    local NavigationPoint NP;

    for ( NP = Level.NavigationPointList; NP!=None; NP=NP.NextNavigationPoint )
    {
        if (NP.IsA('ONSPowerCore') && !NP.IsA('ONSPowerNode'))
            ONSPowerCore(NP).health=ONSPowerCore(NP).Default.DamageCapacity;
    }
}

function FindWhatWeaponsToGive()
{
    local WeaponLocker WL;
    local WeaponPickup WP;
    local string s;
    local int i;
    local int j;
    local bool bFound;

    //search, and if it isn't already in the array
    //of weapons to give, add it.
    foreach AllActors(class'WeaponLocker', WL)
    {
        for(j=0; j<WL.Weapons.Length; j++)
        {
            s=string(WL.Weapons[j].WeaponClass);
            for(i=0; i<sWeaponsToGive.Length; i++)
            {
                if(s~=sWeaponsToGive[i])
                    bFound=True;
            }
            if(s~="XWeapons.Redeemer" || s~="OnslaughtFull.ONSPainter" || s~="XWeapons.Painter")
                ;
            else if(!bFound)
                sWeaponsToGive[sWeaponsToGive.Length]=s;
            bFound=False;
        }
    }

    foreach DynamicActors(class'WeaponPickup', WP)
    {
        s=string(WP.InventoryType);
        for(i=0; i<sWeaponsToGive.Length; i++)
        {
            if(s~=sWeaponsToGive[i])
                bFound=True;
        }
            if(s~="XWeapons.Redeemer" || s~="OnslaughtFull.ONSPainter" || s~="XWeapons.Painter")
                ;
            else if(!bFound)
                sWeaponsToGive[sWeaponsToGive.Length]=s;
            bFound=False;
    }
    bWeaponsChecked=True;
}

function BeginFinalCountdown()
{
    iFinalCountDown=iCOUNTDOWNSECONDS;
    bInFinalCountDown=True;
    KillAllPlayers();
    ResetStats();
    if(iFinalCountDown<10)
    BroadcastLocalizedMessage(class'UTComp_WarmupEndMessage');
}

function KillAllPlayers()
{
    local controller C;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(PlayerController(C)!=None && C.Pawn!=None && C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator)
            C.Pawn.Died(PlayerController(C), class'DamageType', C.Pawn.Location);
        if(PlayerController(C)!=None && C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator)
            C.GoToState('None');
    }
    SavedBots=Level.Game.NumBots;
    if(!Level.Game.IsA('UTComp_ClanArena'))
        Level.Game.KillBots(Level.Game.NumBots+1);
}

function EndWarmup(bool bIsRestart)
{
    ResetCore();
    ResetWarmupVariables();
    ClearRandomStuff();
    ResetTheLevel();
    if(!bIsRestart)
        NotifyPlayers();
    ResetStats();
    ResetKills();
    RemoveSpawnVisualization();
    AutoDemoRecord();
}

function EndArenaWarmup(bool bIsRestart)
{
    ResetCore();
    ClearRandomStuff();
    ResetTheLevel();
    if(!bIsRestart)
        NotifyPlayers();
}

function AutoDemoRecord()
{
    if(class'MutUTComp'.default.bEnableAutoDemorec)
    {
        ConsoleCommand("Demorec"@CreateAutoDemoRecName());
        bAutoDemoStarted=True;
    }
}

function string CreateAutoDemoRecName()
{
    local string S;
    S=class'MutUTComp'.default.AutoDemoRecMask;
    S=Repl(S, "%p", CreatePlayerString());
    S=Repl(S, "%t", CreateTimeString());
    S=StripIllegalWindowsCharacters(S);
    return S;
}

function string CreatePlayerString()
{
    local controller C;
    local array<string> RedPlayerNames;
    local array<string> BluePlayerNames;
    local string ReturnString;
    local int i;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(PlayerController(C)!=None && C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.PlayerName!="")
        {
            if(C.GetTeamNum()==1)
                BluePlayerNames[BluePlayerNames.Length]=C.PlayerReplicationInfo.PlayerName;
            else
                RedPlayerNames[RedPlayerNames.Length]=C.PlayerReplicationInfo.PlayerName;
        }
    }

    if(BluePlayerNames.Length>0 && RedPlayerNames.Length>0)
    {
        ReturnString=BluePlayerNames[0];
        for(i=1; i<BluePlayerNames.Length && i<4; i++)
        {
            ReturnString$="-"$BluePlayerNames[i];
        }
        ReturnString$="-vs-"$RedPlayerNames[0];
        for(i=1; i<RedPlayerNames.Length && i<4; i++)
        {
            ReturnString$="-"$RedPlayerNames[i];
        }
    }
    else if(RedPlayerNames.Length>0)
    {
        ReturnString=RedPlayerNames[0];
        for(i=1; i<RedPlayerNames.Length && i<8; i++)
        {
            ReturnString$="-vs-"$RedPlayerNames[i];
        }
    }
    else if(BluePlayerNames.Length>0)
    {
        ReturnString=BluePlayerNames[0];
        for(i=1; i<BluePlayerNames.Length && i<4; i++)
        {
            ReturnString$="-"$BluePlayerNames[i];
        }
        returnString$="-vs-EmptyTeam";
    }
    returnstring=Left(ReturnString, 100);
    return ReturnString;
}

function string CreateTimeString()
{
    local string hourdigits, minutedigits;

    if(Len(level.hour)==1)
        hourDigits="0"$Level.Hour;
    else
        hourDigits=Left(level.Hour, 2);
    if(len(level.minute)==1)
        minutedigits="0"$Level.Minute;
    else
        minutedigits=Left(Level.Minute, 2);

   return hourdigits$"-"$minutedigits;
}

simulated function string StripIllegalWindowsCharacters(string S)
{
    S=repl(S, ".", "-");
    S=repl(S, "*", "-");
    S=repl(S, ":", "-");
    S=repl(S, "|", "-");
    S=repl(S, "/", "-");
    S=repl(S, ";", "-");
    S=repl(S, "\\","-");
    S=repl(S, ">", "-");
    S=repl(S, "<", "-");
    S=repl(S, "+", "-");
    S=repl(S, " ", "-");
    S=repl(S, "?", "-");
    return S;
}

function ClearRandomStuff()
{
    ResetVehicles();
    ResetProjectiles();
    ResetWeaponPickups();
    ResetBombs();
    ResetDomPoints();
    ResetFlags();
    ResetPowerNodes();
}

function ResetStats()
{
    local controller C;
    local teamplayerreplicationinfo tPRI;
    local UTComp_PRI uPRI;
    local int i;

    DeathMatch(Level.Game).bFirstBlood=false;
    for(C=Level.Controllerlist; C!=None; C=C.NextController)
    {
        if(C.PlayerReplicationInfo!=None && TeamPlayerReplicationInfo(C.PlayerReplicationInfo)!=None)
        {
            tPRI=TeamPlayerReplicationInfo(C.PlayerReplicationInfo);
        }
        if(tPRI!=None)
        {
            tPRI.bFirstBlood=False;
            tPRI.FlagTouches=0;
            tPRI.FlagReturns=0;
            for(i=0; i<=5; i++)
            {
                tPRI.Spree[i]=0;
                tPRI.MultiKills[i]=0;
            }
            tPRI.MultiKills[6]=0;
            tPRI.flakcount=0;
            tPRI.combocount=0;
            tPRI.headcount=0;
            tPRI.ranovercount=0;
            tPRI.DaredevilPoints=0;
            for(i=0; i<=4; i++)
                tPRI.Combos[i]=0;
            for ( i = tPRI.VehicleStatsArray.Length - 1; i >= 0; i-- )
		        {
                tPRI.VehicleStatsArray.Remove(i,1);
            }
            for ( i = tPRI.WeaponStatsArray.Length - 1; i >= 0; i-- )
		        {
                tPRI.WeaponStatsArray.Remove(i,1);
            }
        }
        tPRI=None;
    }
    foreach dynamicactors(class'UTComp_PRI', uPRI)
        uPRI.ClearStats();
}

function ResetTheLevel()
{
    local Controller C;
    local Actor A;
    local int i;

    for (C=Level.ControllerList; C!=None;C=C.NextController)
    {
        if(C.PlayerReplicationInfo!=None)
        {
            if(PlayerController(C) != none && (!C.PlayerReplicationInfo.bOnlySpectator || C.PlayerReplicationInfo.bOutOfLives))
            {
                PlayerController(C).ClientReset();
            }
            if((C.IsInState('GameEnded') || C.IsInState('RoundEnded')) && PlayerController(C) != none && C.PlayerReplicationInfo.bOnlySpectator)
            {
                PlayerController(C).ClientReset();
            }
            C.Reset();
        }
        C.Adrenaline=0;
    }
    foreach AllActors(class'Actor', A)
    {
        if( ZoneInfo(A)==None && Controller(A)==None && TeamInfo(A)==None && (PlayerReplicationInfo(A)==None || !PlayerReplicationInfo(A).bOnlySpectator))
            A.Reset();
    }
    SetTimer(0.0, false);

    Deathmatch(Level.Game).RemainingTime = Deathmatch(Level.Game).Timelimit*60+1;
    UNREALMPGAmeInfo(Level.Game).FindNewObjectives(None);
    level.game.startmatch();
    Deathmatch(Level.Game).RemainingTime = Deathmatch(Level.Game).Timelimit*60+1;

    for (C= Level.ControllerList; C!=None; C=C.nextController)
    {
        if (C.IsA('PlayerController') && !C.IsA('MessagingSpectator'))
            PlayerController(C).ClientSetBehindView(false);
    }
    i=0;
    if(Level.NetMode==NM_DedicatedServer && !Level.Game.IsA('UTComp_ClanArena'))
        DeathMatch(Level.Game).AddBots(SavedBots);
    SavedBots=0;
}

function ResetWarmupVariables()
{
    bInWarmup=False;
}

function NotifyPlayers()
{
    local Controller C;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
        if(BS_xPlayer(C)!=None)
        {
            BS_xPlayer(C).NotifyEndWarmup();
        }
}

function ResetVehicles()
{
    local Vehicle V;
    foreach DynamicActors(class'vehicle', V)
        if(!V.IsA('ONSStationaryweaponpawn'))
            V.destroy();
}

function ResetProjectiles()
{
    local Projectile P;
    foreach DynamicActors(class'Projectile', P)
        P.Destroy();
}

function ResetWeaponPickups()
{
    local WeaponPickup WP;
    foreach DynamicActors(class'WeaponPickup', WP)
        if (WP.bDropped)
            WP.Destroy();
}

function ResetFlags()
{
    local CTFFlag F;
    foreach DynamicActors(class'CTFFlag', F)
    {
        if(F.IsInState('Held') && F.Holder==None)
            F.Drop(vect(0,0,0));
        else if(F.IsInState('Held') && F.Holder !=None)
            F.Holder.DropFlag();
        F.SendHome();
    }
}

function ResetBombs()
{
    local xBombFlag xBF;
    foreach DynamicActors(Class'xBombFlag', xBF)
    {
        if(xBF.IsInState('Held'))
            xBF.Drop(vect(0,0,0));
            xBF.SendHome();
    }
}

function ResetDomPoints()
{
    local NavigationPoint NP;
    for(NP=Level.NavigationPointList; NP!=None; NP=NP.NextNavigationPoint)
    {
        if (xDomPoint(NP)!=None)
            xDomPoint(NP).ResetPoint(True);
    }
}

function ResetPowerNodes()
{
    local NavigationPoint NP;
    for(NP=Level.NavigationPointList; NP!=None; NP=NP.NextNavigationPoint)
        if(ONSPowerNode(NP)!=None)
            ONSPowerNode(NP).PowerCoreNeutral();
}

function WarmupFinalization(int iTimeRemaining)
{
    if(iTimeRemaining==0)
    {
        EndWarmup(false);
        bInFinalCountdown=False;
    }
    if(iFinalCountDown>0)
        BroadCastLocalizedMessage(class'UTComp_Warmup_CountDown', iFinalCountDown);
    iFinalCountDown--;
}


function bool NoTimeLeftCheck()
{
    local int Clients;
    if(bTimeUnlimitedWarmup)
    {
        SetClientTimer(0);
        return false;
    }
    else if(iWarmupTimeRemaining>1)
        SetClientTimer(iWarmupTimeRemaining+12);
    else
        SetClientTimer(0);
    Clients=GetNumClients();
    if( Clients > 0)
        iWarmupTimeRemaining--;
    else
        iWarmupTimeRemaining=iWarmuptime;
    if(iWarmupTimeRemaining <= 0)
        return true;
    return false;
}

function int GetNumClients()
{
    local controller C;
    local int i;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
       if(PlayerController(C)!=None && PlayerController(C).PlayerReplicationInfo!=None && !PlayerController(C).PlayerReplicationInfo.bOnlySpectator)
           i++;
    }
    return i;
}

function SetClientTimer(int iTime)
{
    local Controller C;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(BS_xPlayer(C)!=None)
            BS_xPlayer(C).SetClockTime(iTime);
    }
    //Server Times
    Deathmatch(Level.Game).RemainingTime = Deathmatch(Level.Game).Timelimit*60+1;
}

function SetClientTimerOnly(int iTime)
{
    local Controller C;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(BS_xPlayer(C)!=None)
            BS_xPlayer(C).SetClockTimeOnly(iTime);
    }
}
function SetEndTimeOnly(int iTime)
{
    local Controller C;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(BS_xPlayer(C)!=None)
            BS_xPlayer(C).SetEndTimeOnly(iTime);
    }
}

function bool ReadyCheck()
{
    local Controller C;
    local float iReadyPlayers;
    local float iTotalPlayers;
    local bool bHumanPlayerIngame;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(PlayerController(C)!=None && PlayerController(C).PlayerReplicationInfo!=None && !PlayerController(C).PlayerReplicationInfo.bOnlySpectator)
        {
            iTotalPlayers+=1.00;
            if(PlayerIsReady(PlayerController(C)))
            {
                iReadyPlayers+=1.00;
                bHumanPlayerIngame=True;
            }
        }
    }
    if(iReadyPlayers >= 1.0 && iReadyPlayers/iTotalPlayers >= fReadyPercent/100.0)
        return True;
    if(bAdminBypassReady==True)
    {
        bAdminBypassReady=False;
        return true;
    }
    return false;
}

function bool PlayerIsReady(Controller C)
{
    local UTComp_PRI uPRI;

    uPRI=class'UTComp_Util'.Static.GetUTCompPRIfor(C);
    if(uPRI!=None)
        return uPRI.bIsReady;

    return false;
}

replication
{
    reliable if(Role==Role_Authority)
        bInWarmup;
}

defaultproperties
{
     iWarmupTimeRemaining=30
     fReadyPercent=100.000000
}
