/*
UTComp - UT2004 Mutator
Copyright (C) 2004-2005 Aaron Everitt & Joël Moffatt

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
class BS_xPlayer extends xPlayer;

var float LastHitSoundTime;

var bool blah;
var byte ScreenshotsTaken;
var bool bAutoDemoStarted;
var bool clientChangedScoreboard;
var bool bWantsStats;
var bool oldbShowScoreBoard;

var sound LoadedEnemySound, LoadedFriendlySound;

var UTComp_Warmup uWarmup;
var UTComp_ServerReplicationInfo RepInfo;
var UTComp_PRI UTCompPRI;

var ONSPowerCore oldFoundCore;
var xweaponbase oldFoundWep;
var Controller LastViewedController;
var string UTCompMenuClass;
var string UTCompVotingMenuClass;

//For Colored Names
var color redmessagecolor;
var color greenmessagecolor;
var color bluemessagecolor;
var color yellowmessagecolor;
var color graymessagecolor;

var float OvertimeEndTime;
var bool bInTimedOvertime;
var float LastBroadcastVoteTime;
var float LastBroadcastReadyTime;

//Stats Variables
struct WepStats
{
    var string WepName;
    var class<DamageType> DamageType;
    var int Hits;
    var int Percent;
    var int Damage;
};

var array<WepStats> CustomWepStats;
var array<WepStats> NormalWepStatsPrim;  //14
var array<WepStats> NormalWepStatsAlt;  //14
var localized string WepStatNames[15];
var int DamG;

var class<DamageType> WepStatDamTypesAlt[15];
var class<DamageType> WepStatDamTypesPrim[15];

var bool bGetMapList;

struct DamTypeGrouping
{
    var string WepName;
    var string DamType[6];
};

var array<DamTypeGrouping> CustomWepTypes;

const HITSOUNDTWEENTIME = 0.05;


var bool bWaitingOnGrouping;
var bool bWaitingEnemy;
var int DelayedDamageTotal;
var float WaitingOnGroupingTime;

var float errorsamples, totalerror;

var bool bDisableSpeed, bDisableBooster, bDisableInvis, bDisableberserk;

var bool bSpecingViewGoal;

var vector PlayerMouse;
var float LastHUDSizeX;
var float LastHUDSizeY;
var UTComp_OVerlay Overlay;


var UTComp_PRI currentStatDraw;

var bool bUseNewEyeHeightAlgorithm;

// Fractional Parts of Pitch/Yaw Input
var transient float PitchFraction, YawFraction;

var transient PlayerInput PlayerInput2;
var float TimeBetweenUpdates;

var UTComp_Settings Settings;
var UTComp_HUDSettings HUDSettings;

var float LastWeaponEffectSent;

replication
{
    unreliable if(Role==Role_Authority)
        ReceiveHit, ReceiveStats, ReceiveHitSound;
    reliable if (Role==Role_Authority)
        StartDemo, NotifyEndWarmup, SetClockTime, NotifyRestartMap, SetClockTimeOnly, SetEndTimeOnly, TimeBetweenUpdates;
    reliable if(Role<Role_Authority)
        SetbStats, TurnOffNetCode, ServerSetEyeHeightAlgorithm, ServerSetNetUpdateRate;
    unreliable if(Role<Role_Authority)
        ServerNextPlayer, ServerGoToPlayer, ServerFindNextNode,
        serverfindprevnode, servergotonode, ServerGoToWepBase, speclockRed, speclockBlue, ServerGoToTarget, CallVote;
    reliable if(Role<Role_Authority)
        ServerAdminReady, BroadCastVote, BroadCastReady;

    unreliable if(role < Role_Authority)
        RequestStats, RequestCTFStats;
    unreliable if(Role == Role_Authority)
        SendHitPrim,SendHitAlt,SendFiredPrim,SendFiredAlt,
        SendDamagePrim,SendDamageAlt,SendDamageGR,SendPickups,
        SendCTFStats;

    unreliable if (Role < ROLE_Authority)
        UTComp_ServerMove, UTComp_DualServerMove, UTComp_ShortServerMove;

    reliable if (RemoteRole == ROLE_AutonomousProxy)
        ReceiveWeaponEffect;
    reliable if (bDemoRecording)
        DemoReceiveWeaponEffect;

    reliable if(Role == ROLE_Authority)
        ClientResetNetcode;        
}

simulated function SaveSettings()
{
    Log("Saving settings");
    Settings.SaveConfig();
    HUDSettings.SaveConfig();
}


exec function SetEnemySkinColor(string S)
{
    local array <string> Parts;

    Split(S, " ", Parts);

    if(Parts.length >=3)
    {
        Settings.BlueEnemyUTCompSkinColor.R=byte(Parts[0]);
        Settings.BlueEnemyUTCompSkinColor.G=byte(Parts[1]);
        Settings.BlueEnemyUTCompSkinColor.B=byte(Parts[2]);
        SaveSettings();
    }
    else
    echo("Invalid command, need 3 colors");
}

exec function SetFriendSkinColor(string S)
{
    local array <string> Parts;

    Split(S, " ", Parts);
    if(Parts.length >=3)
    {
        Settings.RedTeammateUTCompSkinColor.R=byte(Parts[0]);
        Settings.RedTeammateUTCompSkinColor.G=byte(Parts[1]);
        Settings.RedTeammateUTCompSkinColor.B=byte(Parts[2]);
        SaveSettings();
    }
    else
    echo("Invalid command, need 3 colors");
}


exec function SetBlueSkinColor(string S)
{
   SetEnemySkinColor(S);
}

exec function SetRedSkinColor(string S)
{
  SetFriendSkinColor(S);
}

exec function SetStats(int i)
{

}

function ServerSetNetUpdateRate(float Rate, int NetSpeed) {
    local float MaxRate;
    local float MinRate;

    MaxRate = class'MutUTComp'.default.MaxNetUpdateRate;
    if (NetSpeed != 0)
        MaxRate = FMin(MaxRate, NetSpeed/100.0);

    MinRate = class'MutUTComp'.default.MinNetUpdateRate;

    TimeBetweenUpdates = 1.0 / FClamp(Rate, MinRate, MaxRate);
}

exec function SetNetUpdateRate(float Rate) {
    Settings.DesiredNetUpdateRate = Rate;
    SaveSettings();
    ServerSetNetUpdateRate(Rate, Player.CurrentNetSpeed);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    AssignStatNames();
    ChangeDeathMessageOrder();

    foreach AllObjects(class'UTComp_Settings', Settings)
        break;

    if (Settings == none) {
        Settings = new(none, "ClientSettings") class'UTComp_Settings';
        Settings.CheckSettings();
    }

    foreach AllObjects(class'UTComp_HUDSettings', HUDSettings)
        break;

    if (HUDSettings == none)
        HUDSettings = new(none, "ClientHUDSettings") class'UTComp_HUDSettings';
}

// Variable PlayerInput of Engine.PlayerController is private.
// This gets our own reference to it.
event InitInputSystem()
{
    // this actually creates the PlayerInput object
    super.InitInputSystem();

    FindPlayerInput();
}

function FindPlayerInput() {
    local PlayerInput PIn;
    local PlayerInput PInAlt;

    // so that we can now capture it
    foreach AllObjects(class'PlayerInput', PIn)
        if (PIn.Outer == self) {
            PInAlt = PIn;
            if (InStr(PIn, ".PlayerInput") < 0)
                PlayerInput2 = PIn;
        }

    if (PlayerInput2 == none)
        PlayerInput2 = PInAlt;
}

simulated function ChangeDeathMessageOrder()
{
    if(class'Crushed'.default.DeathString ~="%o was crushed by %k.")
    {
        class'DamTypeHoverBikeHeadshot'.default.DeathString = "%o was run over by %k";
        class'DamRanOver'.default.DeathString = "%o was run over by %k";
        class'DamTypeHoverBikePlasma'.default.DeathString ="%o was killed by %k with a Manta's Plasma.";
        class'DamTypeONSAvriLRocket'.default.DeathString="%o was blown away by %k with an Avril.";
        class'DamTypeONSVehicleExplosion'.default.DeathString="%o was taken out by %k with a vehicle explosion.";
        class'DamTypePRVLaser'.default.DeathString="%o was laser shocked by %k";
        class'DamTypeRoadkill'.default.DeathString="%o was run over by %k";
        class'DamTypeTankShell'.default.DeathString="%o was blown into flaming bits by %k's tank shell.";
        class'DamTypeTurretBeam'.default.DeathString="%o was turret electrivied by %k.";
        class'DamTypeMASPlasma'.default.DeathString="%o was plasmanted by %k's Leviathan turret.";
        class'DamTypeClassicHeadshot'.default.DeathString="%o's skull was blown apart by %k's Sniper Rifle.";
        class'DamTypeClassicSniper'.default.DeathString="%o was killed by %k with a Sniper Rifle";
    }
}

event PlayerTick(float deltatime)
{
    if (RepInfo==None)
        foreach DynamicActors(Class'UTComp_ServerReplicationInfo', RepInfo)
            break;
    if (uWarmup==None)
        foreach Dynamicactors(class'UTComp_Warmup', uWarmup)
            break;
    if (UTCompPRI==None)
        UTCompPRI=class'UTComp_Util'.static.GetUTCompPRIFor(self);
    if (Level.NetMode!=NM_DedicatedServer && !Blah && PlayerReplicationInfo !=None && PlayerReplicationInfo.CustomReplicationInfo!=None && myHud !=None && RepInfo!=None && UTCompPRI!=None)
    {
        if (uWarmup==None || !uWarmup.bInWarmup)
            StartDemo();
        InitializeStuff();
        blah=true;
    }

    if(bWaitingOnGrouping)
    {
        if(Level.TimeSeconds > WaitingOnGroupingTime)
        {
            DelayedHitSound(DelayedDamageTotal, bWaitingEnemy);
            bWaitingOnGrouping=false;
        }
    }

    if (DoubleClickDir == DCLICK_Active &&
        UTComp_xPawn(Pawn) != none && UTComp_xPawn(Pawn).MultiDodgesRemaining > 0
    ) {
        UTComp_xPawn(Pawn).MultiDodgesRemaining -= 1;
        DoubleClickDir = DCLICK_None;
    }

    if (Level.NetMode == NM_Client && RepInfo != none) {
        if (Player.CurrentNetSpeed > RepInfo.MaxNetSpeed)
            SetNetSpeed(RepInfo.MaxNetSpeed);
        else if (Player.CurrentNetSpeed < RepInfo.MinNetSpeed)
            SetNetSpeed(RepInfo.MinNetSpeed);
    }

    if(myHud!=None && myHud.bShowScoreBoard && !oldbShowScoreBoard)
    {
        StatMine();
    }
    oldbShowScoreBoard=myHud.bShowScoreBoard;

    Super.PlayerTick(deltatime);
}

function SetBStats(bool b)
{
    bWantsStats=b;
    if(UTCompPRI==None)
        UTCompPRI=class'UTComp_Util'.static.GetUTCompPRIFor(self);
    if(UTCompPRI!=None)
        UTCompPRI.bSendWepStats=b;
}


simulated function InitializeStuff()
{
    InitializeScoreboard();
    SetInitialColoredName();
    SetShowSelf(Settings.bShowSelfInTeamOverlay);
    SetBStats(class'UTComp_Scoreboard'.default.bDrawStats || class'UTComp_ScoreBoard'.default.bOverrideDisplayStats);
    SetEyeHeightAlgorithm(Settings.bUseNewEyeHeightAlgorithm);
    ServerSetNetUpdateRate(Settings.DesiredNetUpdateRate, Player.CurrentNetSpeed);
    if(Settings.bFirstRun)
    {
        Settings.bFirstRun=False;
        ConsoleCommand("Set Input f5 MyMenu");
        if(!class'DeathMatch'.default.bForceDefaultCharacter)
        {
           Settings.bRedTeammateModelsForced=False;
           Settings.bBlueEnemyModelsForced=False;
           class'UTComp_xPawn'.Static.StaticSaveConfig();
        }
        else
        {
            Settings.BlueEnemyModelName=class'xGame.xPawn'.default.PlacedCharacterName;
            Settings.RedTeammateModelName=class'xGame.xPawn'.default.PlacedCharacterName;
            class'UTComp_xPawn'.static.staticsaveconfig();
        }
        SaveSettings();
    }
    MatchHudColor();
    GetMapList();
}

simulated function InitializeScoreboard()
{
    local class<scoreboard> NewScoreboardclass;

    if(myHud!=None && myHUD.ScoreBoard.IsA('UTComp_ScoreBoard') && GameReplicationInfo!=None)
    {
        if(Settings.bUseDefaultScoreboard)
        {
            if(GameReplicationInfo.bTeamGame)
                NewScoreboardClass=class'UTComp_ScoreBoardTDM';
            else
                NewScoreboardClass=class'UTComp_ScoreBoardDM';
            clientChangedScoreboard=True;
        }
    }
    else if(ClientChangedScoreBoard && !Settings.bUseDefaultScoreboard)
    {
        //TODO: SCOREBOARD
        //if (Level.Game.IsA('xCTFGame'))
        //    NewScoreboardClass = class'UTComp_ScoreBoardCTF';
        //else
            NewScoreboardClass = class'UTComp_ScoreBoard';
    }
    if(myHUD!=None && NewScoreBoardClass!=None)
        myHUD.SetScoreBoardClass( NewScoreboardClass);
}

simulated function SetInitialColoredName()
{
    SetColoredNameOldStyle();
}


simulated function StartDemo()
{
    local string S;
    S=StripIllegalWindowsCharacters(Settings.DemoRecordingmask);

    if (Settings.bEnableUTCompAutoDemorec && (level.NetMode!=NM_DedicatedServer))
    {
        Player.Console.DelayedConsoleCommand("Demorec "$S);
        bAutoDemoStarted=True;
    }
}

simulated function string StripIllegalWindowsCharacters(string S)
{
    S=MakeDemoName(S);
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

simulated function string MakeDemoname(string S)
{
    local string hourdigits, minutedigits;
    local string playerNames;
    local int i;

    if(Len(level.hour)==1)
        hourDigits="0"$Level.Hour;
    else
        hourDigits=Left(level.Hour, 2);
    if(len(level.minute)==1)
        minutedigits="0"$Level.Minute;
    else
        minutedigits=Left(Level.Minute, 2);
    for(i=0; i<GamereplicationInfo.PRIArray.Length; i++)
    {
        if(GamereplicationInfo.PRIArray[i].bOnlySpectator==False && !GameReplicationInfo.PRIArray[i].bOnlySpectator && GamereplicationInfo.PRIArray[i].Team==None || GamereplicationInfo.PRIArray[i].Team != PlayerReplicationInfo.Team)
            playerNames=PlayerNames$GamereplicationInfo.PRIArray[i].PlayerName$"-";
    }
    S=Repl(S, "%t", hourdigits$"-"$minutedigits);
    S=repl(S, "%p", Playerreplicationinfo.PlayerName);
    S=repl(S, "%o", playerNames);
    S=Left(S,100);
    return S;
}

state GameEnded
{
    function BeginState()
    {
        Super.BeginState();
        if(Level.NetMode==NM_DedicatedServer)
            return;
        SetTimer(0.5, False);
        if(myHUD!=None)
            myHUD.bShowScoreBoard = true;
    }
    function Timer()
    {
        if (Settings.bEnableAutoScreenShot && screenshotstaken==0)
        {
            ConsoleCommand("shot "$StripIllegalWindowsCharacters(Settings.ScreenShotMask));
            screenshotstaken++;
        }
        Super.Timer();
    }
}


//====================================
// Stats / Hitsounds
//====================================

// both stat/hitsound
simulated function ReceiveHit(class<DamageType> DamageType, int Damage, pawn Injured)
{
    if(Level.NetMode==NM_DedicatedServer)
        return;

    if(Injured!=None && Injured.Controller!=None && Injured.Controller==Self)
        RegisterSelfHit(DamageType, Damage);
    else if(Injured.GetTeamNum()==255 || (Injured.GetTeamNum() != GetTeamNum()))
    {
        RegisterEnemyHit(DamageType, Damage);
        if(Settings.bCPMAStyleHitsounds && (DamageType == class'DamTypeFlakChunk' || DamageType == class'DamTypeFlakShell') && (RepInfo==None || RepInfo.EnableHitSoundsMode==2 || LineOfSightTo(Injured)))
        {
            GroupDamageSound(DamageType, Damage, true);
        }
        else if(RepInfo==None || RepInfo.EnableHitSoundsMode==2 || LineOfSightTo(Injured) || IsHitScan(DamageType))
            PlayEnemyHitSound(Damage);
    }
    else
    {
        RegisterTeammateHit(DamageType, Damage);
        if(Settings.bCPMAStyleHitsounds && (DamageType == class'DamTypeFlakChunk' || DamageType == class'DamTypeFlakShell') && (RepInfo==None || RepInfo.EnableHitSoundsMode==2 || LineOfSightTo(Injured)))
        {
            GroupDamageSound(DamageType, Damage, false);
        }
        else if(RepInfo==None || RepInfo.EnableHitSoundsMode==2 || LineOfSightTo(Injured) || IsHitScan(DamageType))
            PlayTeammateHitSound(Damage);
    }
}

simulated function ServerReceiveHit(class<DamageType> DamageType, int Damage, pawn Injured)
{
    if(Injured!=None && Injured.Controller!=None && Injured.Controller==Self)
        ServerRegisterSelfHit(DamageType, Damage);
    else if(Injured.GetTeamNum()==255 || (Injured.GetTeamNum() != GetTeamNum()))
        ServerRegisterEnemyHit(DamageType, Damage);
    else
        ServerRegisterTeammateHit(DamageType, Damage);
}

simulated function bool IsHitScan(class<DamageType> DamageType)
{
    return
        DamageType == Class'XWeapons.DamTypeSuperShockBeam' ||
        DamageType == Class'XWeapons.DamTypeLinkShaft' ||
        DamageType == Class'XWeapons.DamTypeSuperShockBeam' ||
        DamageType == Class'XWeapons.DamTypeSniperShot' ||
        DamageType == Class'XWeapons.DamTypeMinigunBullet' ||
        DamageType == Class'XWeapons.DamTypeShockBeam' ||
        DamageType == Class'XWeapons.DamTypeAssaultBullet' ||
        DamageType == Class'XWeapons.DamTypeShieldImpact' ||
        DamageType == Class'XWeapons.DamTypeMinigunAlt' ||
        DamageType == Class'DamTypeSniperHeadShot' ||
        DamageType == Class'DamTypeClassicHeadshot' ||
        DamageType == Class'DamTypeClassicSniper';
}

// only stats
simulated function ReceiveStats(class<DamageType> DamageType, int Damage, pawn Injured)
{
    if(Level.NetMode==NM_DedicatedServer)
        return;
    if(Injured.Controller!=None && Injured.Controller==Self)
        RegisterSelfHit(DamageType, Damage);

    else if(Injured.GetTeamNum()==255 || (Injured.GetTeamNum() != GetTeamNum()))
    {
        RegisterEnemyHit(DamageType, Damage);
    }
    else
    {
        RegisterTeammateHit(DamageType, Damage);
    }
}

simulated function GroupDamageSound(class<DamageType> DamageType, int Damage, bool bEnemy)
{
    bWaitingOnGrouping=True;
    bWaitingEnemy = bEnemy;
    DelayedDamageTotal +=Damage;
    WaitingOnGroupingTime = Level.TimeSeconds+0.030;
}

simulated function DelayedHitSound(int Damage, bool bEnemy)
{
    if (bEnemy)
        PlayEnemyHitSound(Damage);
    else
        PlayTeammateHitSound(Damage);
    DelayedDamageTotal=0;
}

// only hitsound, LOS check done i9n gamerules
simulated function ReceiveHitSound(int Damage, byte iTeam)
{
    if (Level.NetMode==NM_DedicatedServer)
        return;
    if (bBehindView)
        return;
    if (iTeam==1)
        PlayEnemyHitSound(Damage);
    else if (iTeam==2)
        PlayTeammateHitSound(Damage);
}

simulated function RegisterSelfHit(class<DamageType> DamageType, int Damage)
{
}

simulated function ServerRegisterSelfHit(class<DamageType> DamageType, int Damage)
{
}


simulated function RegisterEnemyHit(class<DamageType> DamageType, int Damage)
{
    local int i, j, k;
    if (DamageType==None)
        return;

    DamG+=Damage;
    for(i=0; i<=14; i++)
    {
        if (DamageType==WepStatDamTypesPrim[i])
        {
            NormalWepStatsPrim[i].Hits +=1;
            NormalWepStatsPrim[i].Damage+=Damage;
            return;
        }
        else if (DamageType==WepStatDamTypesAlt[i])
        {
            NormalWepStatsAlt[i].Hits +=1;
            NormalWepStatsAlt[i].Damage+=Damage;
            return;
        }
        //Hack DamageTypes(more than 1, currently only sniper)
        else if (DamageType==class'DamTypeSniperHeadShot' || DamageType==class'DamTypeClassicHeadshot' || DamageType==class'DamTypeClassicSniper')
        {
            NormalWepStatsPrim[5].Hits +=1;
            NormalWepStatsPrim[5].Damage+=Damage;

            if (DamageType!=class'DamTypeClassicSniper')
            {
                NormalWepStatsAlt[5].Hits +=1;
            }
            return;
        }
    }
    //Custom weapon Stats
    for(i=0; i<CustomWepStats.Length; i++)
    {
        if(CustomWepStats[i].WepName!="")
        {
            for(j=0; j<CustomWepTypes.Length; j++)
            {
                for(k=0; k<ArrayCount(CustomWepTypes[j].DamType); k++)
                {
                    if (( CustomWepTypes[j].DamType[k]!="" && InstrNonCaseSensitive(string(DamageType), CustomWepTypes[j].DamType[k])) && CustomWepTypes[j].WepName~=CustomWepStats[i].WepName)
                    {
                        CustomWepStats[i].Hits+=1;
                        CustomWepStats[i].Damage+=Damage;
                        return;
                    }
                }
            }
        }
        if (DamageType==CustomWepStats[i].DamageType)
        {
            CustomWepStats[i].Hits+=1;
            CustomWepStats[i].Damage+=Damage;
            return;
        }

    }

    i=CustomWepStats.Length+1;
    CustomWepStats.Length=i;
    for(j=0; j<CustomWepTypes.Length; j++)
    {
        for(k=0; k<ArrayCount(CustomWepTypes[j].DamType); k++)
            if (( CustomWepTypes[j].DamType[k]!="" && InstrNonCaseSensitive(string(DamageType), CustomWepTypes[j].DamType[k])))
                CustomWepStats[i-1].WepName=CustomWepTypes[j].WepName;
    }
    CustomWepStats[i-1].DamageType=DamageType;
    CustomWepStats[i-1].Damage=Damage;
    CustomWepStats[i-1].Hits=1;
}

simulated function ServerRegisterEnemyHit(class<DamageType> DamageType, int Damage)
{
    local int i;
    if (DamageType==None || UTCompPRI==None)
        return;

    UTCompPRI.DamG+=Damage;
    for(i=0; i<=14; i++)
    {
        if(DamageType==WepStatDamTypesPrim[i])
        {
            UTCompPRI.NormalWepStatsPrimHit[i] +=1;
            UTCompPRI.NormalWepStatsPrimDamage[i]+=Damage;
            return;
        }
        else if(DamageType==WepStatDamTypesAlt[i])
        {
            UTCompPRI.NormalWepStatsAltHit[i] +=1;
            UTCompPRI.NormalWepStatsAltDamage[i]+=Damage;
            return;
        }
        //Hack DamageTypes(more than 1, currently only sniper)
        else if(DamageType==class'DamTypeSniperHeadShot' || DamageType==class'DamTypeClassicHeadshot' || DamageType==class'DamTypeClassicSniper')
        {
            UTCompPRI.NormalWepStatsPrimHit[5] +=1;
            UTCompPRI.NormalWepStatsPrimDamage[5]+=Damage;

            if(DamageType!=class'DamTypeClassicSniper')
            {
                UTCompPRI.NormalWepStatsAltHit[5] +=1;
            }
            return;
        }
    }
}


exec function StatMine()
{
    if(PlayerReplicationInfo == None || !PlayerREplicationInfo.bOnlySpectator)
        currentStatDraw=UTCompPRI;
    else
        StatSpec();
}

exec function StatSpec()
{
    if (viewTarget==none)
    {
        StatNext();
        return;
    }
    if (ViewTarget.IsA('Pawn') && Pawn(ViewTarget).PlayerReplicationInfo!=None
        && !Pawn(ViewTarget).PlayerReplicationInfo.bBot
    ) {
        currentStatDraw =  class'UTComp_Util'.static.GetUTCompPRI(Pawn(ViewTarget).PlayerReplicationInfo);
    }

    if (currentStatDraw == None)
        StatNext();
    else
        RequestStats(currentStatDraw);
}

exec function StatNext()
{
    local utcomp_PRI upri;
    local playerreplicationinfo pri;
    local bool buseNext;
    local int i;
    local utcomp_pri startPRI;

    if (gameREplicationInfo == None)
        return;

    startPRI = currentStatDraw;

    if (currentStatDraw == None)
    {
        for (i = 0; i < GameReplicationInfo.PRIArray.length; i++)
        {
            pri = GameReplicationInfo.PRIArray[i];
            uPRI = class'UTComp_Util'.static.GetUTCompPRI(GameReplicationInfo.PRIArray[i]);
            if (uPRI!=None && uPRI!=UTCompPRI && !PRI.bBot && !pri.bOnlySpectator)
            {
                currentStatDraw=uPRI;
                break;
            }
        }
    }
    else
    {
        for (i = 0; i < GameReplicationInfo.PRIArray.length; i++)
        {
            uPRI = class'UTComp_Util'.static.GetUTCompPRI(GameReplicationInfo.PRIArray[i]);
            pri = GameReplicationInfo.PRIArray[i];
            if (bUseNext && !PRI.bBot && !pri.bOnlySpectator)
            {
                currentStatDraw=uPRI;
                bUseNext=false;
                break;
            }
            if(currentStatDraw==uPRI)
                bUseNext=true;
        }

        if(bUseNext)
        {
            for (i = 0; i < GameReplicationInfo.PRIArray.length; i++)
            {
                uPRI = class'UTComp_Util'.static.GetUTCompPRI(GameREplicationInfo.PRIArray[i]);
                pri = GameREplicationInfo.PRIArray[i];
                if (!PRI.bBot && !pri.bOnlySpectator)
                    currentStatDraw=uPRI;
                break;
            }
        }
    }

    if (startPRI != None && currentStatDraw == startPRI)
    {
        currentStatDraw=none;
        StatNext();
        return;
    }
    if (UTCompPRI != currentStatDraw && currentStatDraw != None)
        RequestStats(currentStatDraw);
}

/**
  This is called in on the server. It thens executes SendCTFStats on the client that requested the stats.
  */
simulated function RequestCTFStats(UTComp_PRI uPRI)
{
    local string S;

    if (uPRI == None)
        return;

    S = uPRI.FlagGrabs@uPRI.FlagCaps@uPRI.FlagPickups@uPRI.FlagKills@uPRI.FlagSaves@uPRI.FlagDenials@uPRI.Assists@uPRI.Covers@uPRI.CoverSpree@uPRI.Seals@uPRI.SealSpree@uPRI.DefKills;
    SendCTFStats(S, uPRI);
}

/**
  Receives S from the server and sets the values to the local uPRI in order to display the stats.
  */
simulated function SendCTFStats(string S, UTComp_PRI uPRI)
{
    local array<string> parts;

    Split(S, " ", Parts);

    uPRI.FlagGrabs=int(Parts[0]);
    uPRI.FlagCaps=int(Parts[1]);
    uPRI.FlagPickups=int(Parts[2]);
    uPRI.FlagKills=int(Parts[3]);
    uPRI.FlagSaves=int(Parts[4]);
    uPRI.FlagDenials=int(Parts[5]);
    uPRI.Assists=int(Parts[6]);
    uPRI.Covers=int(Parts[7]);
    uPRI.CoverSpree=int(Parts[8]);
    uPRI.Seals=int(Parts[9]);
    uPRI.SealSpree=int(Parts[10]);
    uPRI.DefKills=int(Parts[11]);
}

simulated function RequestStats(UTComp_PRI uPRI)
{
    local string S;
    local int i;

    if(uPRI == None)
        return;
    S="";
    for(i=0; i<ArrayCount(uPRI.NormalWepStatsPrimHit); i++)
    {
        if(i==0)
            S=S$uPRI.NormalWepStatsPrimHit[i];
        else
            S=S@uPRI.NormalWepStatsPrimHit[i];
    }
    SendHitPrim(S, uPRI);

    S="";
    for(i=0; i<ArrayCount(uPRI.NormalWepStatsAltHit); i++)
    {
        if(i==0)
            S=S$uPRI.NormalWepStatsAltHit[i];
        else
            S=S@uPRI.NormalWepStatsAltHit[i];
    }
    SendHitAlt(S, uPRI);

    S="";
    for(i=0; i<ArrayCount(uPRI.NormalWepStatsPrim); i++)
    {
        if(i==0)
            S=S$uPRI.NormalWepStatsPrim[i];
        else
            S=S@uPRI.NormalWepStatsPrim[i];
    }
    SendFiredPrim(S, uPRI);

    S="";
    for(i=0; i<ArrayCount(uPRI.NormalWepStatsAlt); i++)
    {
        if(i==0)
            S=S$uPRI.NormalWepStatsAlt[i];
        else
            S=S@uPRI.NormalWepStatsAlt[i];
    }
    SendFiredAlt(S, uPRI);

    S="";
    for(i=0; i<ArrayCount(uPRI.NormalWepStatsPrimDamage); i++)
    {
        if(i==0)
            S=S$uPRI.NormalWepStatsPrimDamage[i];
        else
            S=S@uPRI.NormalWepStatsPrimDamage[i];
    }
    SendDamagePrim(S, uPRI);

    S="";
    for(i=0; i<ArrayCount(uPRI.NormalWepStatsAltDamage); i++)
    {
        if(i==0)
            S=S$uPRI.NormalWepStatsAltDamage[i];
        else
            S=S@uPRI.NormalWepStatsAltDamage[i];
    }
    SendDamageAlt(S, uPRI);

    SendDamageGR(uPRI.damG,uPRI.damR, uPRI);

    S = uPRI.PickedUpFifty@uPRI.PickedUpHundred@uPRI.PickedUpAmp@uPRI.PickedUpVial@uPRI.PickedUpHealth@uPRI.PickedUpKeg@uPRI.PickedUpAdren;
    sendPickups(S,uPRI);
}

simulated function SendPickups(string S, UTComp_PRI uPRI)
{
    local array<string> parts;
    //log("getting pickups");

    Split(S, " ", Parts);

    uPRI.PickedUpFifty=int(Parts[0]);
    uPRI.PickedUpHundred=int(Parts[1]);
    uPRI.PickedUpAmp=int(Parts[2]);
    uPRI.PickedUpVial=int(Parts[3]);
    uPRI.PickedUpHealth=int(Parts[4]);
    uPRI.PickedUpKeg=int(Parts[5]);
    uPRI.PickedUpAdren=int(Parts[6]);
}

simulated function SendDamageGR(int damageG, int damageR, UTComp_PRI uPRI)
{

    uPRI.damG = damageG;
    uPRI.damR = damageR;
}


simulated function SendHitPrim(string S, utcomp_PRI uPRI)
{
    local int i;
    local array<string> parts;

    Split(S," ", parts);
    for(i=0; i<Parts.length; i++)
    {
        uPRI.NormalWepStatsPrimHit[i]=int(Parts[i]);
    }
}

simulated function SendHitAlt(string S, utcomp_PRI uPRI)
{
    local int i;
    local array<string> parts;

    Split(S," ", parts);
    for(i=0; i<Parts.length; i++)
    {
        uPRI.NormalWepStatsAltHit[i]=int(Parts[i]);
    }
}


simulated function SendFiredPrim(string S, utcomp_PRI uPRI)
{
    local int i;
    local array<string> parts;

    Split(S," ", parts);
    for(i=0; i<Parts.length; i++)
    {
        uPRI.NormalWepStatsPrim[i]=int(Parts[i]);
    }
}

simulated function SendFiredAlt(string S, utcomp_PRI uPRI)
{
    local int i;
    local array<string> parts;

    Split(S," ", parts);
    for(i=0; i<Parts.length; i++)
    {
        uPRI.NormalWepStatsAlt[i]=int(Parts[i]);
    }
}


simulated function SendDamagePrim(string S, utcomp_PRI uPRI)
{
    local int i;
    local array<string> parts;

    Split(S," ", parts);
    for(i=0; i<Parts.length; i++)
    {
        uPRI.NormalWepStatsPrimDamage[i]=int(Parts[i]);
    }
}

simulated function SendDamageAlt(string S, utcomp_PRI uPRI)
{
    local int i;
    local array<string> parts;

    Split(S," ", parts);
    for(i=0; i<Parts.length; i++)
    {
        uPRI.NormalWepStatsAltDamage[i]=int(Parts[i]);
    }
}

exec function StatPrev()
{
}

simulated function bool InStrNonCaseSensitive(String S, string S2)
{
    local int i;
    for(i=0; i<=(Len(S)-Len(S2)); i++)
    {
        if(Mid(S, i, Len(s2))~=S2)
            return true;
    }
    return false;
}


simulated function AssignStatNames()
{
    local int i;
    NormalWepStatsPrim.Length=15;
    NormalWepStatsAlt.Length=15;
    for(i=0; i<15; i++)
    {
        NormalWepStatsPrim[i].WepName=WepStatNames[i];
        NormalWepStatsAlt[i].WepName=WepStatNames[i];
    }
}

simulated function UpdatePercentages()
{
    local int i;
    if(UTCompPRI==None)
        return;
    for(i=0; i<NormalWepStatsPrim.Length; i++)
    {
        if(UTCompPRI.NormalWepStatsPrim[i]>0)
            NormalWepStatsPrim[i].Percent=float(NormalWepStatsPrim[i].Hits)/float(UTCompPRI.NormalWepStatsPrim[i])*100.0;
    }
    for(i=0; i<NormalWepStatsPrim.Length; i++)
        if(UTCompPRI.NormalWepStatsAlt[i]>0)
            NormalWepStatsAlt[i].Percent=float(NormalWepStatsAlt[i].Hits)/float(UTCompPRI.NormalWepStatsAlt[i])*100.0;
}

simulated function SyncPRI()
{
    local int i;
    if(UTCompPRI==None)
        return;

    for(i=0; i<15; i++)
    {
        UTCompPRI.NormalWepStatsPrimHit[i]=NormalWepStatsPrim[i].Hits;
        UTCompPRI.NormalWepStatsPrimPercent[i]=NormalWepStatsPrim[i].Percent;
        UTCompPRI.NormalWepStatsAltHit[i]=NormalWepStatsAlt[i].Hits;
        UTCompPRI.NormalWepStatsAltPercent[i]=NormalWepStatsAlt[i].Percent;
    }
}

simulated function RegisterTeammateHit(class<DamageType> DamageType, int Damage)
{
}

simulated function ServerRegisterTeammateHit(class<DamageType> DamageType, int Damage)
{
}

simulated function PlayEnemyHitSound(int Damage)
{
    local float HitSoundPitch;

    if (!Settings.bEnableHitSounds || LastHitSoundTime>Level.TimeSeconds)
        return;

    LastHitSoundTime = Level.TimeSeconds + HITSOUNDTWEENTIME;

    HitSoundPitch = 1.0;
    if (Settings.bCPMAStyleHitSounds)
        HitSoundPitch = Settings.CPMAPitchModifier * 30.0 / Damage;

    if (LoadedEnemySound == none)
        LoadedEnemySound = Sound(DynamicLoadObject(Settings.EnemySound, class'Sound', True));

    if (ViewTarget != None)
        ViewTarget.PlaySound(LoadedEnemySound,,Settings.HitSoundVolume,,,HitSoundPitch);
}

simulated function PlayTeammateHitSound(int Damage)
{
    local float HitSoundPitch;

    if (!Settings.bEnableHitSounds || LastHitSoundTime>Level.TimeSeconds)
        return;

    LastHitSoundTime = Level.TimeSeconds + HITSOUNDTWEENTIME;

    HitSoundPitch = 1.0;
    if (Settings.bCPMAStyleHitSounds)
        HitSoundPitch = Settings.CPMAPitchModifier * 30.0 / Damage;

    if (LoadedFriendlySound == none)
        LoadedFriendlySound = Sound(DynamicLoadObject(Settings.FriendlySound, class'Sound', True));

    if (ViewTarget != None)
        ViewTarget.PlaySound(LoadedFriendlySound,,Settings.HitSoundVolume,,,HitSoundPitch);
}

exec function myMenu()
{
    if (UTCompPRI.CurrentVoteID==255 ||( Playerreplicationinfo.bonlyspectator && !IsInState('GameEnded')))
        ClientOpenMenu(UTCompMenuClass);
    else
        ClientOpenMenu(UTCompVotingMenuClass);
}

exec function OpenVoteMenu()
{
    ClientOpenMenu(UTCompVotingMenuClass);
}

exec function SetVolume(float f)
{
    ConsoleCommand("set alaudio.alaudiosubsystem soundvolume "$f);
}

exec function Echo(string S)
{
    ClientMessage(""$S);
}

function ServerSpecViewGoal()
{
    local actor NewGoal;

    if(!IsCoaching())
    {
        bSpecingViewGoal = true;
        super.ServerSpecViewGoal();
    }

    if ( PlayerReplicationInfo.bOnlySpectator && IsInState('Spectating') )
    {
        NewGoal = Level.Game.FindSpecGoalFor(PlayerReplicationInfo,0);
        if (NewGoal!=None)
        {
            if(Pawn(NewGoal)!=None && ((Pawn(NewGoal).GetTeamNum() == 1 && IsCoachingBlue()) || (Pawn(NewGoal).GetTeamNum() == 0 && IsCoachingRed())))
            {
                SetViewTarget(NewGoal);
                ClientSetViewTarget(NewGoal);
                //bBehindView = true; //bChaseCam;
            }
        }
    }
}

function ServerViewSelf()
{
  bSpecingViewGoal = false;
  Super.ServerViewSelf();
}

exec function voteyes()
{
    if(UTCompPRI!=None && UTCompPRI.CurrentVoteID!=255)
    {
        UTCompPRI.Vote=1;
        UTCompPRI.SetVoteMode(1);
        if(PlayerReplicationInfo!=None && (!PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bAdmin) && Level.TimeSeconds > LastBroadcastVoteTime)
        {
            BroadcastVote(True);
            LastBroadcastVoteTime=Level.TimeSeconds + 5.0;
        }
    }
}

exec function VoteNo()
{
    if(UTCompPRI!=None && UTCompPRI.CurrentVoteID!=255)
    {
        UTCompPRI.Vote=2;
        UTCompPRI.SetVoteMode(2);
        if(PlayerReplicationInfo!=None && (!PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bAdmin) && Level.TimeSeconds > LastBroadcastVoteTime)
        {
            BroadcastVote(False);
            LastBroadcastVoteTime=Level.TimeSeconds + 5.0;
        }
    }
}

exec function Ready()
{
    if(UTCompPRI!=None)
        UTCompPRI.bIsReady=True;
    UTCompPRI.Ready();
    if(PlayerReplicationInfo!=None && !PlayerReplicationInfo.bOnlySpectator && Level.TimeSeconds > LastBroadcastReadyTime)
    {
        LastBroadcastReadyTime=5.0+Level.TimeSeconds;
        BroadcastReady(True);
    }
}

exec function NotReady(optional bool bSilent)
{
    if(UTCompPRI!=None)
        UTCompPRI.bIsReady=False;
    UTCompPRI.NotReady();
    if(!bSilent && PlayerReplicationInfo!=None && !PlayerReplicationInfo.bOnlySpectator && Level.TimeSeconds > LastBroadcastReadyTime)
    {
        LastBroadcastReadyTime=5.0+Level.TimeSeconds;
        BroadcastReady(False);
    }
}

exec function NextNode()
{
    if (IsCoaching())
        return;
    ServerFindNextNode();
}

exec function PrevNode()
{
    if (IsCoaching())
        return;
    ServerFindPrevNode();
}

exec function Node(int k)
{
    if (IsCoaching())
        return;
    ServerGotoNode(k+1);
}

exec function Core(int k)
{
    if (IsCoaching())
        return;
    k=Max(k, 1);
    k=Min(k, 2);
    ServergotoNode(k-1);
}

exec function bool NextRedPlayer()
{
    if (IsCoaching() && !IsCoachingRed())
        return false;
    return(ServerNextPlayer(0));
}

exec function bool NextBluePlayer()
{
    if (IsCoaching() && !IsCoachingBlue())
        return false;

    return(ServerNextPlayer(1));
}

exec function GoToPlayer(int k)
{
    if (IsCoaching())
        return ;
    ServerGoToPlayer(k-1);
}

function ServerGoToTarget(Actor a)
{
    local rotator R;

    bSpecingViewGoal = false;

    if (a.IsA('PlayerReplicationInfo'))
        ServerSetViewTarget(a.Owner);
    else
    {
        bBehindView = true;
        ServerSetViewTarget(a);
        ClientSetBehindview(true);
        if (a.IsA('Pickup'))
        {
            R = Pickup(a).PickUpBase.rotation;
            R.Yaw += 90*182.0444;
            R.Pitch -= 15*182.0444;
        }
        else
            R = CalcViewRotation;

        ClientSetLocation(CalcViewLocation, R);
    }
}

function bool ServerNextPlayer(int teamindex)
{
    local int k;
    local controller C;
    local array<Controller> RedPlayers;

    for(C=Level.ControllerList; c!=None; C=C.NextController)
    {
      if(C.PlayerReplicationInfo !=None && C.PlayerReplicationInfo.Team !=None && C.PlayerReplicationInfo.Team.TeamIndex==teamindex)
      RedPlayers[RedPlayers.Length]=C;
    }
    for(k=0; k<RedPlayers.Length; k++)
    {
        if(RedPlayers[k]==LastViewedController)
        {
            if(k==RedPlayers.Length-1)
            {
                ServerSetViewTarget(RedPlayers[0]);
                LastViewedController=RedPlayers[0];
                if(IsCoaching())
                {
                    ClientSetBehindview(False);
                    bBehindView=False;
                }
                return true;
            }
            else
            {
                ServerSetViewTarget(RedPlayers[k+1]);
                LastViewedController=RedPlayers[k+1];
                if (IsCoaching())
                {
                    ClientSetBehindview(False);
                    bBehindView=False;
                }
                return true;
            }
        }
    }
    if(RedPlayers.Length>0)
    {
        ServerSetViewTarget(RedPlayers[0]);
        LastViewedController=RedPlayers[0];
        if(IsCoaching())
        {
            ClientSetBehindview(False);
            bBehindView=False;
        }
        return true;
    }
    else
    {
        return false;
    }
}

exec function GoToItem(string CmdLine)
{
    local string pickup;
    local string team;
    local class<Pickup> pickupClass;
    local int teamNum;

    teamNum = -1;

    if (IsCoaching())
        return;

    if (!Divide(CmdLine," ", pickup, team))
        pickup = CmdLine;


    if(pickup ~= "50" || pickup ~= "Small" || pickup ~= "50a")
        pickupClass = class'XPickups.ShieldPack';
    else if(pickup ~= "100" || pickup ~= "100a" || pickup ~= "Large" || pickup ~="Big")
        pickupClass = class'XPickups.SuperShieldPack';
    else if(pickup ~= "DD" || pickup ~= "Amp" || pickup ~= "Double-Damage" || pickup ~= "DoubleDamage")
        pickupClass = class'XPickups.UDamagePack';
    else if (pickup ~= "keg")
        pickupClass = class'XPickups.SuperHealthPack';

    if (pickupClass == None)
        return;

    if (team ~= "0" || team ~= "red")
        teamNum = 0;
    else if (team ~= "1" || team ~= "blue")
        teamNum = 1;

    ServerGoToWepBase(pickupClass, teamNum);
}

function bool IsInZone(Actor a, int team)
{
    local string loc;

    loc = a.Region.Zone.LocationName;

    if (team == 0)
        return (Instr(Caps(loc), "RED" ) != -1);
    else
        return (Instr(Caps(loc), "BLUE") != -1);

    return false;
}

function ServerGoToWepBase(class<Pickup> theClass, int team)
{
    local xPickupBase xPBase;

    foreach allactors(class'xPickupBase', xPBase)
    {
        if (xPBase.PowerUp == theClass)
        {
            ServerSetViewTarget(xPBase);
            break;
        }
    }
}

function ServerGoToPlayer(int k)
{
    local int j;
    local Controller C;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if (j==k)
        {
            ServerSetViewTarget(C);
            return;
        }
        j++;
    }
}


function ServerSetViewTarget(actor A)
{
    if(PlayerReplicationInfo.bOnlySpectator==False)
        return;
    SetViewTarget(A);
    ClientSetViewTarget(A);
}

exec function SetSavedSpectateSpeed(float F)
{
    Settings.SavedSpectateSpeed=F;
    SetSpectateSpeed(F);
    SaveSettings();
}

exec function NextSuperWeapon()
{
    if(IsCoaching())
        return;
    ServerGoToNextSuperWeapon();
}


function ServerGoToNextSuperWeapon()
{
    local xWeaponBase xWep;
    local xWeaponBase foundWep;
    local xweaponBase firstWep;
    local bool bfirstactor;

    if(PlayerReplicationInfo.bOnlySpectator==False)
        return;

    foreach AllActors(class'xWeaponBase', xWep)
    {
        if(!bfirstactor && (xWep.WeaponType == class'Redeemer' || xWep.WeaponType == class'Painter'))
        {
            firstWep=xWep;
            bFirstActor=true;
        }
        if(FoundWep !=None && (xWep.WeaponType == class'Redeemer' || xWep.WeaponType == class'Painter') )
        {
            SetViewTarget(xWep);
            ClientSetViewTarget(xWep);
            bBehindView = true;
            OldFoundWep=xWep;
            ClientSetBehindview(True);
            break;
        }
        if (xWep==OldFoundWep)
            FoundWep=xWep;
    }
    if(FoundWep==None && firstWep !=None)
    {
        SetViewTarget(firstWep);
        ClientSetViewTarget(firstWep);
        bBehindView = true;
        OldFoundWep=firstWep;
        ClientSetBehindview(True);
    }
    else if(OldFoundWep !=None)
    {
        SetViewTarget(oldFoundWep);
        ClientSetViewTarget(OldFoundWep);
        bBehindView = true;
        ClientSetBehindview(True);
    }
}


function ServerGoToNode(int k)
{
    if(PlayerReplicationInfo.bOnlySpectator==False || !Level.Game.IsA('ONSOnslaughtGame')
       || k>=ONSOnslaughtGame(Level.Game).PowerCores.Length)
    return;
    SetViewTarget(ONSOnslaughtGame(Level.Game).PowerCores[k]);
    ClientSetViewTarget(ONSOnslaughtGame(Level.Game).PowerCores[k]);
    bBehindView = true;
    OldFoundCore=ONSOnslaughtGame(Level.Game).PowerCores[k];
}

function ServerFindNextNode()
{

    local ONSPowerCore FoundCore;
    local int k;
    if(PlayerReplicationInfo.bOnlySpectator==False)
        return;
    if(!Level.Game.IsA('ONSOnslaughtGame'))
        return;
    for(k=0; k<ONSOnslaughtGame(Level.Game).PowerCores.Length; k++)
    {
        if(ONSOnslaughtGame(Level.Game).PowerCores[k] == OldfoundCore && k<ONSOnslaughtGame(Level.Game).PowerCores.Length-1)
        {
            FoundCore=ONSOnslaughtGame(Level.Game).PowerCores[k+1];
            break;
        }
    }
    if(OldFoundCore==None)
    {
        FoundCore=ONSOnslaughtGame(Level.Game).PowerCores[0];
    }
    if(FoundCore==None)
    {
        FoundCore=ONSOnslaughtGame(Level.Game).PowerCores[0];
    }
    SetViewTarget(FoundCore);
    ClientSetViewTarget(FoundCore);
    bBehindView = true;
    OldFoundCore=FoundCore;
}

function ServerFindPrevNode()
{
    local ONSPowerCore FoundCore;
    local int k;
    if(PlayerReplicationInfo.bOnlySpectator==False)
        return;
    if(!Level.Game.IsA('ONSOnslaughtGame'))
        return;
    for(k=ONSOnslaughtGame(Level.Game).PowerCores.Length-1; k>0; k--)
    {
        if(ONSOnslaughtGame(Level.Game).PowerCores[k] == OldfoundCore && k>0)
        {
            FoundCore=ONSOnslaughtGame(Level.Game).PowerCores[k-1];
            break;
        }
    }
    if(OldFoundCore==None)
    {
        FoundCore=ONSOnslaughtGame(Level.Game).PowerCores[ONSOnslaughtGame(Level.Game).PowerCores.Length-1];
    }
    if(FoundCore==None)
    {
        FoundCore=ONSOnslaughtGame(Level.Game).PowerCores[ONSOnslaughtGame(Level.Game).PowerCores.Length-1];
    }
    SetViewTarget(FoundCore);
    ClientSetViewTarget(FoundCore);
    bBehindView = true;
    OldFoundCore=FoundCore;
}

simulated function bool IsCoaching()
{
    if(UTCompPRI==None)
        UTCompPRI=Class'UTComp_Util'.Static.GetUTCompPRI(PlayerReplicationInfo);

    if(UTCompPRI!=None && UTCompPRI.CoachTeam==255)
        return false;
    return True;
}

simulated function bool IsCoachingRed()
{
    if(UTCompPRI==None)
        UTCompPRI=Class'UTComp_Util'.Static.GetUTCompPRI(PlayerReplicationInfo);
    if(UTCompPRI!=None && UTCompPRI.CoachTeam==0)
        return True;
    return False;
}

simulated function bool IsCoachingBlue()
{
    if(UTCompPRI==None)
        UTCompPRI=Class'UTComp_Util'.Static.GetUTCompPRI(PlayerReplicationInfo);
    if(UTCompPRI!=None && UTCompPRI.CoachTeam==1)
        return True;
    return False;
}

exec function BehindView( bool B )
{

    if ( Level.NetMode == NM_Standalone || Level.Game.bAllowBehindView || Vehicle(Pawn) != None || PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bOutOfLives || PlayerReplicationInfo.bAdmin || IsA('Admin') )
    {
        if((ViewTarget.IsA('xPawn') && xPAwn(viewtarget).DrivenVehicle==None) && IsCoaching())
            return;
        if ( (Vehicle(Pawn)==None) || (Vehicle(Pawn).bAllowViewChange) )    // Allow vehicles to limit view changes
        {
            ClientSetBehindView(B);
            bBehindView = B;
        }
    }
}

exec function SpecLockRed()
{
    if(RepInfo==None)
        foreach DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo);

    if(UTCompPRI==None)
        UTCompPRI=Class'UTComp_Util'.Static.GetUTCompPRI(PlayerReplicationInfo);

    if (!PlayerReplicationInfo.bOnlySpectator)
    {
        ClientMessage("Sorry, only spectators can spec lock");
        return;
    }
    if (IsCoaching())
    {
        ClientMessage("Sorry, you may only lock to a team once per game. ");
        return;
    }
    if (NextRedPlayer())
    {
        UTCompPRI.SetCoachTeam(0);
        Level.Game.Broadcast(self, PlayerReplicationInfo.PlayerName@"has become a coach for the Red Team.");
    }
    else
        ClientMessage("Sorry, there are no Red players ingame.  Try again later.");
}

exec function SpecLockBlue()
{
    if(RepInfo==None)
        foreach DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo);

    if(UTCompPRI==None)
        UTCompPRI=Class'UTComp_Util'.Static.GetUTCompPRI(PlayerReplicationInfo);

    if (!PlayerReplicationInfo.bOnlySpectator)
    {
        ClientMessage("Sorry, only spectators can spec lock");
        return;
    }
    if (IsCoaching())
    {
        ClientMessage("Sorry, you may only lock to a team once per game. ");
        return;
    }
    if (NextBluePlayer())
    {
        UTCompPRI.SetCoachTeam(1);
        Level.Game.Broadcast(self, PlayerReplicationInfo.PlayerName@"has become a coach for the Blue Team.");
    }
    else
        ClientMessage("Sorry, there are no Blue players ingame.  Try again later.");
}

exec function ToggleBehindView()
{
    if((ViewTarget.IsA('xPawn') && xPAwn(viewtarget).DrivenVehicle==None) && IsCoaching())
        return;
    ServerToggleBehindview();
}

function ServerToggleBehindView()
{
    local bool B;

    if ( Level.NetMode == NM_Standalone || Level.Game.bAllowBehindView || Vehicle(Pawn) != None || PlayerReplicationInfo.bOnlySpectator || PlayerReplicationInfo.bAdmin || IsA('Admin') || PlayerReplicationInfo.bOutOfLives)
    {
        if ( (Vehicle(Pawn)==None) || (Vehicle(Pawn).bAllowViewChange) )    // Allow vehicles to limit view changes
        {
            B = !bBehindView;
            ClientSetBehindView(B);
            bBehindView = B;
        }
    }
}

state spectating
{
    event PlayerTick( float DeltaTime )
    {
        Super.PlayerTick(DeltaTime);
        if (bRun == 1)
            GoToState('PlayerMousing');
    }

    function BeginState()
    {
        if ( Pawn != None )
        {
            SetLocation(Pawn.Location);
            UnPossess();
        }
        bCollideWorld = true;

        // IT was annoying when we were switching to MouseLooking and Spectating state and had zoomed out. Dunno if it'll break something! haha. ha.
        //CameraDist = Default.CameraDist;

        SetTimer(1.0, True);
    }

    exec function Fire(optional float F)
    {
        if ( bFrozen )
        {
            if ((TimerRate <= 0.0) || (TimerRate > 1.0))
                bFrozen = false;
            return;
        }

        if(IsCoachingRed())
            NextRedPlayer();
        else if(IsCoachingBlue())
            NextBluePlayer();
        else
            ServerViewNextPlayer();
    }

    function Timer()
    {
        if(!IsCoaching())
        Super.Timer();
        else if(ViewTarget==Self)
        {
            if(IsCoachingRed() && NextRedPlayer())
                return;
            else if(IsCoachingBlue() && NextBluePlayer())
                return;
        }
        else if(ViewTarget.IsA('xPawn'))
        {
            if(IsCoachingRed()) {
                if(xPawn(ViewTarget).PlayerReplicationInfo != None && xPAwn(ViewTarget).PlayerReplicationInfo.Team.TeamIndex!= 0)
                    NextRedPlayer();
            } else if (IsCoachingBlue()) {
                if(xPawn(ViewTarget).PlayerReplicationInfo != None && xPawn(ViewTarget).PlayerReplicationInfo.Team.TeamIndex!= 1)
                    NextBluePlayer();
            }
        }
    }

    // Return to spectator's own camera.
    exec function AltFire( optional float F )
    {
        if(IsCoaching())
            return;
        else
            Super.AltFire(F);
    }
}

simulated function CallVote(byte b, optional byte p, optional string Options, optional int p2, optional string Options2)
{
    if(!IsValidVote(b,p,Options,options2))
        return;
    if(UTCompPRI==None)
        UTCompPRI=Class'UTComp_Util'.Static.GetUTCompPRI(PlayerReplicationInfo);
    if(PlayerReplicationInfo!=None && UTCompPRI!=None && PlayerReplicationInfo.bAdmin)
        UTCompPRI.PassVote(b,p,Options,GetPlayerName(),p2,Options2);
    if(UTCompPRI!=None)
        UTCompPRI.CallVote(b,p, Options,GetPlayerName(), p2, Options2);
}

simulated function string GetPlayerName()
{
    if(PlayerReplicationInfo!=None)
        return PlayerReplicationInfo.PlayerName;
    return "";
}

function bool IsValidVote(byte b, byte p, out string S, string S2)
{
    local array<String> maplist;
    local int i;
    local bool bServerHasMap;


    if(UTCompPRI==None)
        UTCompPRI=Class'UTComp_Util'.Static.GetUTCompPRI(PlayerReplicationInfo);

    if(PlayerReplicationInfo==None || (PlayerReplicationInfo.bOnlySpectator && !PlayerReplicationInfo.bAdmin))
    {
        ClientMessage("Sorry, only non-spectating players may call votes.");
        return false;
    }
    if(UTCompPRI==None || UTcompPRI.CurrentVoteID!=255)
    {
        ClientMessage("Sorry, a vote is already in progress.");
        return false;
    }
    if(uWarmup==None)
        foreach DynamicActors(class'UTComp_Warmup', uWarmup)
            break;
    if(b>10 || b<0)
    {
        ClientMessage("An Error occured, this is an invalid vote");
        return false;
    }
    if(b==6 || b==7)
    {
        S=CheckShortMapName(S);
        Level.Game.LoadMapList("", MapList);

        for(i=0; i<maplist.length; i++)
        {
            if(maplist[i]~=S)
            {
                bServerHasMap=True;
                break;
            }
        }
        if(!bServerHasMap || Left(S, 4)~="Tut-" || Left(S, 4)~="Mov-")
        {
            ClientMessage("Sorry, this map is not valid");
            return false;
        }
    }
    return true;
}


simulated function NotifyEndWarmup()
{
    NotReady(true);
    if(GameReplicationInfo!=None)
        SetClockTime(GameReplicationInfo.TimeLimit*60+1);
    ResetEpicStats();
    ResetUTCompStats();
    StartDemo();
    bInTimedOvertime=false;
}

simulated function NotifyRestartMap()
{
    NotReady(true);
    if(bAutoDemoStarted)
    {
        ConsoleCommand("StopDemo");
        bAutoDemoStarted=False;
    }
    ScreenShotsTaken=0;
    ResetUTCompStats();
    ResetEpicStats();
    bDisplayWinner=False;
    bDisplayLoser=False;
    if(GameReplicationInfo!=None)
        SetClockTime(GameReplicationInfo.TimeLimit*60+1);
}

simulated function ResetUTCompStats()
{
    local int i;
    local UTComp_PRI uPRI;

    for(i = 0; i < NormalWepStatsPrim.Length; i++)
    {
        NormalWepStatsPrim[i].Damage=0;
        NormalWepStatsPrim[i].Hits=0;
        NormalWepStatsPrim[i].Percent=0;
    }
    for (i = 0; i < NormalWepStatsalt.Length; i++)
    {
        NormalWepStatsalt[i].Damage=0;
        NormalWepStatsalt[i].Hits=0;
        NormalWepStatsalt[i].Percent=0;
    }
    CustomWepStats.Length=0;
    DamG=0;

    if (PlayerReplicationInfo != None)
    {
        uPRI = class'UTComp_Util'.static.GetUTCompPRI(PlayerReplicationInfo);
        uPRI.FlagGrabs = 0;
        uPRI.FlagCaps = 0;
        uPRI.FlagPickups = 0;
        uPRI.FlagKills = 0;
        uPRI.FlagSaves = 0;
        uPRI.FlagDenials = 0;
        uPRI.Assists = 0;
        uPRI.Covers = 0;
        uPRI.CoverSpree = 0;
        uPRI.Seals = 0;
        uPRI.SealSpree = 0;
        uPRI.DefKills = 0;
    }
}

simulated function ResetEpicStats()
{
    local TeamPlayerReplicationInfo tPRI;
    local int i;
    if (PlayerReplicationInfo != None && TeamPlayerReplicationInfo(PlayerReplicationInfo)!= None)
    {
        tPRI=Teamplayerreplicationinfo(PlayerReplicationInfo);
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
}

simulated function SetClockTime(int iTime)
{
    if(uWarmup!=None && uWarmup.bInWarmup && PlayerReplicationInfo!=None)
        ReceiveLocalizedMessage(class'UTComp_InWarmupMessage',,,,self);

    if(GameReplicationInfo!=None)
    {
        GameReplicationInfo.Remainingtime = iTime;
        GameReplicationInfo.RemainingMinute = iTime;
        GameReplicationInfo.Elapsedtime =  0;
    }
    if(PlayerReplicationInfo!=None)
        PlayerReplicationInfo.StartTime = 0;
}

simulated function SetClockTimeOnly(int iTime)
{
    if(GameReplicationInfo!=None)
    {
        GameReplicationInfo.Remainingtime = iTime;
    }
}

simulated function SetEndTimeOnly(int iTime)
{
    OvertimeEndTime=Gamereplicationinfo.ElapsedTime;
    bInTimedOvertime=True;
}

exec function AdminReady()
{
    ServerAdminReady();
}

function BroadcastVote(bool b)
{
    if(b)
        Level.Game.Broadcast(self, PlayerReplicationInfo.PlayerName@"voted yes.");
    else
        Level.Game.Broadcast(self, PlayerReplicationInfo.PlayerName@"voted no.");
}

function BroadcastReady(bool b)
{
    if(b)
        Level.Game.Broadcast(self, PlayerReplicationInfo.PlayerName@"is now ready.");
    else
        Level.Game.Broadcast(self, PlayerReplicationInfo.PlayerName@"is no longer ready.");
}

function ServerAdminReady()
{
    if(PlayerReplicationInfo!=None && PlayerReplicationInfo.bAdmin)
    {
        if(uWarmup==None)
            foreach DynamicActors(class'UTComp_Warmup', uWarmup)
                break;
        if(uWarmup!=None)
            uWarmup.bAdminBypassReady=True;
    }
}

exec function SetName(coerce string S)
{
    S=StripColorCodes(S);
    Super.SetName(S);
    ReplaceText(S, " ", "_");
    ReplaceText(S, "\"", "");
    SetColoredNameOldStyle(Left(S, 20));
    Settings.CurrentSelectedColoredName=255;
    SaveSettings();staticsaveconfig();
}

exec function SetNameNoReset(coerce string S)
{
    S=StripColorCodes(S);
    Super.SetName(S);
    ReplaceText(S, " ", "_");
    ReplaceText(S, "\"", "");
    SetColoredNameOldStyle(S);
}

simulated function SetColoredNameOldStyle(optional string S2, optional bool bShouldSave)
{
    local string S;
    local byte k;
    local byte numdoatonce;
    local byte m;

    if(Level.NetMode==NM_DedicatedServer || PlayerReplicationInfo==None)
        return;

    if (S2=="")
    {
       S2=PlayerReplicationInfo.PlayerName;
    }
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& Settings.ColorName[k-1] == Settings.ColorName[m] ;m++)
        {
            numdoatonce++;
            k++;
        }
        S=S$class'UTComp_Util'.Static.MakeColorCode(Settings.ColorName[k-1])$Right(Left(S2, k), numdoatonce);
    }
    if (UTCompPRI!=None)
        UTCompPRI.SetColoredName(S);
}

simulated function string FindColoredName(int CustomColors)
{
    local string S;
    local string S2;
    local int i;

    if(Level.NetMode==NM_DedicatedServer || PlayerReplicationInfo==None)
    return "";

    if(S2=="")
    {
       S2=Settings.ColoredName[CustomColors].SavedName;
    }

    for(i=0; i<Len(S2); i++)
        S $= class'UTComp_Util'.Static.MakeColorCode(Settings.ColoredName[CustomColors].SavedColor[i])$Mid(Settings.ColoredName[CustomColors].SavedName,i,1);
    return S;
}

simulated function string AddNewColoredName(int CustomColors)
{
    local string S;
    local byte k;
    local byte numdoatonce;
    local byte m;
    local string S2;

    if(Level.NetMode==NM_DedicatedServer || PlayerReplicationInfo==None)
        return "";

    if(S2=="")
    {
       S2=Settings.ColoredName[CustomColors].SavedName;
    }
    SetNameNoReset(S2);
    for(k=0; k<20; k++)
        Settings.ColorName[k]=Settings.ColoredName[CustomColors].SavedColor[k];
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& Settings.ColoredName[CustomColors].SavedColor[k-1] == Settings.ColoredName[CustomColors].SavedColor[m] ;m++)
        {
            numdoatonce++;
            k++;
        }
        S=S$class'UTComp_Util'.Static.MakeColorCode(Settings.ColoredName[CustomColors].SavedColor[k-1])$Right(Left(S2, k), numdoatonce);
    }
    return S;
}

simulated function SaveNewColoredName()
{
    local int n;
    local int l;

    n=Settings.ColoredName.Length+1;
    Settings.ColoredName.Length=n;

    Settings.ColoredName[n-1].SavedName=PlayerReplicationInfo.PlayerName;

    for(l=0; l<20; l++)
        Settings.ColoredName[n-1].SavedColor[l]=Settings.ColorName[l];

}

exec function ShowColoredNames()
{
    local int i, j;
    local string S;
    for(i=0; i<Settings.ColoredName.Length; i++)
    {
        Log(Settings.ColoredName[i].SavedName);
        for(j=0; j<20; j++)
            S=S$Settings.ColoredName[i].SavedColor[j].R@Settings.ColoredName[i].SavedColor[j].G@Settings.ColoredName[i].SavedColor[j].B;
        Log(S);
    }
}


simulated function SetColoredNameOldStyleCustom(optional string S2, optional int CustomColors)
{
    local string S;
    local byte k;
    local byte numdoatonce;
    local byte m;

    if(Level.NetMode==NM_DedicatedServer || PlayerReplicationInfo==None)
        return;

    if(S2=="")
    {
       S2=Settings.ColoredName[CustomColors].SavedName;
    }
    SetNameNoReset(S2);

    for(k=0; k<20; k++)
        Settings.ColorName[k]=Settings.ColoredName[CustomColors].SavedColor[k];
    SaveSettings();
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& Settings.ColoredName[CustomColors].SavedColor[k-1] == Settings.ColoredName[CustomColors].SavedColor[m] ;m++)
        {
            numdoatonce++;
            k++;
        }
        S=S$class'UTComp_Util'.Static.MakeColorCode(Settings.ColoredName[CustomColors].SavedColor[k-1])$Right(Left(S2, k), numdoatonce);
    }
    if(UTCompPRI!=None)
        UTCompPRI.SetColoredName(S);
}

exec function ListColoredNames()
{
    local int i;
    for(i=0; i<Settings.ColoredName.Length; i++)
        echo(Settings.coloredname[i].SavedName);
}

simulated function SetShowSelf(Bool b)
{
    Settings.bShowSelfInTeamOverlay=b;
    SaveSettings();staticsaveconfig();
    if(UTCompPRI!=None)
        UTCompPRI.SetShowSelf(b);
}


simulated function string StripColorCodes(String S)
{
    local array<string> StringParts;
    local int i;
    local string S2;

    Split(S, chr(27), stringParts);
    if(StringParts.Length>=1)
        S2=StringParts[0];
    for(i=1; i<stringParts.Length; i++)
    {
        StringParts[i]=Right(StringParts[i], Len(stringParts[i])-3);
        S2=S2$stringParts[i];
    }
    if(Right(s2,1)==chr(27))
        S2=Left(S2, Len(S2)-1);
    return S2;
}

simulated function reskinall()
{
    local UTComp_xPawn P;
    if(Level.NetMode==NM_DedicatedServer)
        return;
    foreach dynamicactors(class'UTComp_xPawn', P)
    {
        if(!P.bInvis)
        P.ColorSkins();
    }
}

function bool AllowTextMessage(string Msg)
{
    local int k;

    if ( (Level.NetMode == NM_Standalone) || PlayerReplicationInfo.bAdmin )
        return true;

    if ( (Level.Pauser == none) && (Level.TimeSeconds - LastBroadcastTime < 0.66) )
        return false;

    // lower frequency if same text
    if ( Level.TimeSeconds - LastBroadcastTime < 5 )
    {
        Msg = Left(Msg,Clamp(len(Msg) - 4, 8, 64));
        for ( k=0; k<4; k++ )
            if ( LastBroadcastString[k] ~= Msg )
                return false;
    }
    for ( k=3; k>0; k-- )
        LastBroadcastString[k] = LastBroadcastString[k-1];

    LastBroadcastTime = Level.TimeSeconds;
    return true;
}

simulated function ClientCallMapVote(String S, int i)
{
    CallVote(6,,CheckShortMapName(S));
}

simulated function string CheckShortMapName(coerce string MapName)
{
    if(mapname~= "Joust")
        mapName="CTF-1on1-Joust";
    else if(mapname~= "Avaris")
        mapName="CTF-Avaris";
    else if(mapname~= "Bol" || mapname~= "Bolwerk" || mapname~= "Boll" || mapname~= "Bollwerk")
        mapName="CTF-BollwerkRuins2004-PRO";
    else if(mapname~= "Bridge")
        mapName="CTF-BridgeOfFate";
    else if(mapname~= "Chrome")
        mapName="CTF-Chrome";
    else if(mapname~= "Cit" || mapname~= "Citadel")
        mapName="CTF-Citadel";
    else if(mapname~= "Dec" || mapname~= "December")
        mapName="CTF-December";
    else if(mapname~= "Face" || mapname~= "FaceClassic")
        mapName="CTF-FaceClassic";
    else if(mapname~= "Geo")
        mapName="CTF-GeoThermal";
    else if(mapname~= "Grendel")
        mapName="DM-DE-GrendelKeep";
    else if(mapname~= "Face3")
        mapname="CTF-Face3";
    else if(mapname~= "Geo")
        mapname="CTF-GeoThermal";
    else if(mapname~= "Jan" || mapname ~="January")
        mapname="CTF-January";
    else if(mapname~= "Lost" || mapname ~="LostFaith")
        mapname="CTF-LostFaith";
    else if(mapname~= "Magma")
        mapname="CTF-Magma";
    else if(mapname~= "Maul")
        mapname="CTF-Maul";
    else if(mapname~="Orb" || mapname~="Orbital" || mapname~="Orbital2")
        mapname="CTF-Orbital2";
    else if(mapname~="smote")
        mapname="CTF-Smote";
    else if(mapname~="TwinTombs")
        mapname="CTF-TwinTombs";
    else if(mapname~="Iron" || mapname~="IronDust")
        mapname="DM-1on1-IronDust";
    else if(mapname~="roughinery" || mapname~="Rough")
        mapname="DM-1on1-Roughinery";
    else if(mapname~="roughFPS" || mapname~="Rough-FPS")
        mapname="DM-1on1-Roughinery-FPS";
    else if(mapname~="Lea")
        mapname="DM-1on1-Lea";
    else if(mapname~="DeckFPS" || mapname~="Deck--FPS")
        mapname="DM-1on1-Roughinery-FPS";
    else if(mapname~="camp" || mapname~="campgrounds" || mapname~="dm6")
        mapname="DM-Campgrounds2004-G1E";
    else if(mapname~="Spirit")
        mapname="DM-1on1-Spirit";
    else if(mapname~="Squader")
        mapname="DM-1on1-Squader";
    else if(mapname~="Trite")
        mapname="DM-1on1-Trite";
    else if(mapname~="Ant" || mapname~="Antalus")
        mapname="DM-Antalus";
    else if(mapname~="Asb" || mapname~="Asbestos")
        mapname="DM-Asbestos";
    else if(mapname~="comp" || mapname~="Compressed")
        mapname="DM-Compressed";
    else if(mapname~="corr" || mapname~="Corrugation")
        mapname="DM-Corrugation";
    else if(mapname~="curse" || mapname~="curse4")
        mapname="DM-Curse4";
    else if(mapname~="Deck" || mapname~="Deck17")
        mapname="DM-Deck17";
    //begin dnx3 code
    else if(mapname~= "Torlan")
        mapName="ONS-Torlan";
    else if(mapname~= "Sev" || mapname~= "Severance")
        mapName="ONS-Severance";
    else if(mapname~= "Red" || mapname~= "Redplanet")
        mapName="ONS-Redplanet";
    else if(mapname~= "Prime" || mapname~= "Prim" || mapname~= "Primeval")
        mapName="ONS-Primeval";
    else if(mapname~= "Frost" || mapname~= "Frostbite")
        mapName="ONS-Frostbite";
    else if(mapname~= "Dria")
        mapName="ONS-Dria";
    else if(mapname~= "Dawn")
        mapName="ONS-Dawn";
    else if(mapname~= "Cross" || mapname~= "Crossfire")
        mapName="ONS-Crossfire";
    else if(mapname~= "Arc" || mapname~= "Arctic" || mapname~= "Arcticstronghold")
        mapName="ONS-Arcticstronghold";
    else if(mapname~= "RRajigar" || mapname~= "rra")
        mapName="DM-RRajigar";
    else if(mapname~= "Rankin" || mapname~= "Rank" || mapname~= "Ran")
        mapName="DM-Rankin";
    else if(mapname~= "Morph" || mapname~= "Morpheus" || mapname~= "Morpheus3")
        mapName="DM-Morpheus3";
    else if(mapname~= "IronDeity")
        mapName="DM-Irondeity";
    else if(mapname~= "Ins" || mapname~= "Insidious")
        mapName="DM-Insidious";
    else if(mapname~= "Gol" || mapname~= "Goliath")
        mapName="DM-Goliath";
    else if(mapname~= "Gael")
        mapName="DM-Gael";
    else if(mapname~= "Flux" || mapname~= "Flux2")
        mapName="DM-Flux2";
    else if(mapname~= "Desert" || mapname~= "Desertisle")
        mapName="DM-Desertisle";
    else if(mapname~= "Osi" || mapname~= "Osiris" || mapname~= "Osiris2")
        mapName="DM-DE-Osiris2";
    else if(mapname~= "Ironic" || mapname~= "Leet" || mapname~= "BestMap")
        mapName="DM-DE-Ironic";
    else if(mapname~= "Grendel" || mapname~= "Gren" || mapname~= "Grendelkeep" || mapname~= "Lame")
        mapName="DM-DE-Grendelkeep";
    else if(mapname~= "Achilles" || mapname~= "Ach" || mapname~= "Achil")
        mapName="DM-CBP2-Achilles";
    else if(mapname~= "Archipel" || mapname~= "Archipelago")
        mapName="DM-CBP2-Archipelago";
    else if(mapname~= "Azures")
        mapName="DM-CBP2-Azures";
    else if(mapname~= "Buli" || mapname~= "Buliwyf")
        mapName="DM-CBP2-Buliwyf";
    else if(mapname~= "Drak" || mapname~= "Drakonis")
        mapName="DM-CBP2-Drakonis";
    else if(mapname~= "Griff" || mapname~= "Griffin")
        mapName="DM-CBP2-Griffin";
    else if(mapname~= "Kadath")
        mapName="DM-CBP2-Kadath";
    else if(mapname~= "Kero" || mapname~= "Kerosene")
        mapName="DM-CBP2-Kerosene";
    else if(mapname~= "Khrono")
        mapName="DM-CBP2-Khrono";
    else if(mapname~= "KillBB" || mapname~= "KillbillyBarn")
        mapName="DM-CBP2-KillbillyBarn";
    else if(mapname~= "Koma")
        mapName="DM-CBP2-Koma";
    else if(mapname~= "Krouj" || mapname~= "KroujKran")
        mapName="DM-CBP2-KroujKran";
    else if(mapname~= "Masu" || mapname~= "Masurao")
        mapName="DM-CBP2-Masurao";
    else if(mapname~= "Meitak")
        mapName="DM-CBP2-Meitak";
    else if(mapname~= "Nifl" || mapname~= "Niflheim")
        mapName="DM-CBP2-Niflheim";
    else if(mapname~= "Recon" || mapname~= "Reconstruct")
        mapName="DM-CBP2-Reconstruct";
    else if(mapname~= "Summit")
        mapName="DM-CBP2-Summit";
    else if(mapname~= "TelMeco" || mapname~= "TelMecoMex")
        mapName="DM-CBP2-TelMecoMEX";
    else if(mapname~= "Temp" || mapname~= "Tempest")
        mapName="DM-CBP2-Tempest";
    else if(mapname~= "Tensile" || mapname~= "TensileSteel")
        mapName="DM-CBP2-TensileSteel";
    else if(mapname~= "Tork" || mapname~= "Torken" || mapname~= "Torkenstein")
        mapName="DM-CBP2-Torkenstein";
    else if(mapname~= "Tydal")
        mapName="DM-CBP2-Tydal";
    else if(mapname~= "Bah" || mapname~= "Bahe" || mapname~= "Bahera")
        mapName="CTF-CBP2-Bahera";
    else if(mapname~= "Botanic")
        mapName="CTF-CBP2-Botanic";
    else if(mapname~= "Deca" || mapname~= "Decadence")
        mapName="CTF-CBP2-Decadence";
    else if(mapname~= "Deep")
        mapName="CTF-CBP2-Deep";
    else if(mapname~= "Gaz" || mapname~= "Gazpacho")
        mapName="CTF-CBP2-Gazpacho";
    else if(mapname~= "Pist" || mapname~= "Pistola")
        mapName="CTF-CBP2-Pistola";
    else if(mapname~= "Sko" || mapname~= "Skorb" || mapname~= "Skorbut")
        mapName="CTF-CBP2-Skorbut";
    else if(mapname~= "Argento")
        mapName="ONS-CBP2-Argento";
    else if(mapname~= "Brass" || mapname~= "Brassed")
        mapName="ONS-CBP2-Brassed";
    else if(mapname~= "Mirage")
        mapName="ONS-CBP2-Mirage";
    else if(mapname~= "Pasar" || mapname~= "Pasargadae")
        mapName="ONS-CBP2-Pasargadae";
    else if(mapname~= "Trop" || mapname~= "Tropica")
        mapName="ONS-CBP2-Tropica";
    else if(mapname~= "Val" || mapname~= "Valarna")
        mapName="ONS-CBP2-Valarna";
    else if(mapname~= "Yorda")
        mapName="ONS-CBP2-Yorda";
    else if(mapname~= "Icarus")
        mapName="ONS-Icarus";
    else if(mapname~= "Ari" || mapname~= "Aridoom")
        mapName="ONS-Aridoom";
    else if(mapname~= "Asc" || mapname~= "Ascend" || mapname~= "Ascendancy")
        mapName="ONS-Ascendancy";
    else if(mapname~= "Goose" || mapname~= "Goose2k4")
        mapName="DM-Goose2k4";
    return MapName;
}

event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type  )
{
    local string c;
    local int k;
    // Wait for player to be up to date with replication when joining a server, before stacking up messages
    if ( Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None )
        return;

    if( AllowTextToSpeech(PRI, Type) )
        TextToSpeech( S, TextToSpeechVoiceVolume );
    if ( Type == 'TeamSayQuiet' )
        Type = 'TeamSay';

    //replace the color codes
    if(Settings.bAllowColoredMessages)
    {
        for(k=7; k>=0; k--)
        {
            S=Repl(S, "^"$k, ColorReplace(k));
        }
    }
    else
    {
        for(k=7; k>=0; k--)
        {
            S=Repl(S, "^"$k, "");
        }
    }
    if ( myHUD != None )
    {
        if (Settings.bEnableColoredNamesInTalk)
            Message( PRI, c$S, Type );
        else
            myHud.Message( PRI, c$S, Type );
    }
    if ( (Player != None) && (Player.Console != None) )
    {
        if ( PRI!=None )
        {
            if ( PRI.Team!=None && GameReplicationInfo.bTeamGame)
            {
                if (PRI.Team.TeamIndex==0)
                    c = chr(27)$chr(200)$chr(1)$chr(1);
                else if (PRI.Team.TeamIndex==1)
                    c = chr(27)$chr(125)$chr(200)$chr(253);
            }
            S = PRI.PlayerName$": "$S;
        }
        Player.Console.Chat( c$s, 6.0, PRI );
    }
}

function ServerSay( string Msg )
{
    local controller C;

    // center print admin messages which start with #
    if (PlayerReplicationInfo.bAdmin && left(Msg,1) == "#" )
    {
        Msg = right(Msg,len(Msg)-1);
        for( C=Level.ControllerList; C!=None; C=C.nextController )
            if( C.IsA('PlayerController') )
            {
                PlayerController(C).ClearProgressMessages();
                PlayerController(C).SetProgressTime(6);
                PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
            }
        return;
    }
    if(PlayerReplicationInfo.bOnlySpectator && IsCoaching() && gamereplicationinfo.bTeamGame)
        Level.Game.BroadcastTeam( self, Level.Game.ParseMessageString( Level.Game.BaseMutator , self, Msg ) , 'TeamSay');
    else
        Level.Game.Broadcast(self, Msg, 'Say');
}

function ServerTeamSay( string Msg )
{
    LastActiveTime = Level.TimeSeconds;

    if( !GameReplicationInfo.bTeamGame)
    {
        if(!playerreplicationInfo.bOnlySpectator)
        {
            Say( Msg );
            return;
        }
        else
        {
            SpecDMSay(msg);
            return;
        }
    }
    if(GameReplicationInfo.bTeamGame && IsCoaching() && PlayerReplicationInfo.bOnlySpectator)
        SpecLockTeamSay(msg);
    else
        Level.Game.BroadcastTeam( self, Level.Game.ParseMessageString( Level.Game.BaseMutator , self, Msg ) , 'TeamSay');
}

function SpecDMSay(string msg)
{
    local playercontroller P;
    local controller C;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        P=PlayerController(C);
        if(P!=None && P.PlayerReplicationInfo!=None && P.PlayerReplicationInfo.bOnlySpectator)
            Level.Game.BroadcastHandler.BroadcastText(PlayerReplicationInfo, P, msg, 'teamsay');
    }
}

function SpecLockTeamSay(string msg)
{
    local playercontroller P;
    local controller C;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        P=PlayerController(C);
        if(P!=None && P.PlayerReplicationInfo!=None && P.PlayerReplicationInfo.Team !=None && P.PlayerReplicationInfo.Team.TeamIndex==UTCompPRI.CoachTeam)
            Level.Game.BroadcastHandler.BroadcastText(PlayerReplicationInfo, P, msg, 'coachteamsay');
    }
    Level.Game.BroadCastHandler.BroadCastText(PlayerReplicationInfo, self, msg, 'coachteamsay');
}

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
    local Class<LocalMessage> LocalMessageClass2;

    switch( MsgType )
    {
        case 'Say':
            if ( PRI == None )
                return;

            if(class'UTComp_Util'.Static.GetUTCompPRI(PRI)==None || class'UTComp_Util'.Static.GetUTCompPRI(PRI).ColoredName=="")
                Msg = PRI.PlayerName$": "$Msg;
            else if(pri.team!= none && PRI.Team.TeamIndex == 0)
                Msg= class'UTComp_Util'.Static.GetUTCompPRI(PRI).ColoredName$class'UTComp_Util'.Static.MakeColorCode(RedMessageColor)$": "$Msg;
            else if(pri.team!= none && PRI.Team.TeamIndex == 1)
                Msg= class'UTComp_Util'.Static.GetUTCompPRI(PRI).ColoredName$class'UTComp_Util'.Static.MakeColorCode(blueMessageColor)$": "$Msg;
            else
                MSG= class'UTComp_Util'.Static.GetUTCompPRI(PRI).ColoredName$class'UTComp_Util'.Static.MakeColorCode(yellowMessageColor)$": "$Msg;
            LocalMessageClass2 = class'SayMessagePlus';
            break;

        case 'TeamSay':
            if ( PRI == None )
                return;
            if(class'UTComp_Util'.Static.GetUTCompPRI(PRI)==None || class'UTComp_Util'.Static.GetUTCompPRI(PRI).ColoredName=="")
                Msg = PRI.PlayerName$"("$PRI.GetLocationName()$"): "$Msg;
            else
                Msg = class'UTComp_Util'.Static.GetUTCompPRI(PRI).ColoredName$class'UTComp_Util'.Static.MakeColorCode(GreenMessageColor)$"("$PRI.GetLocationName()$"): "$Msg;
            LocalMessageClass2 = class'TeamSayMessagePlus';
            break;

        case 'CoachTeamSay':
            if ( PRI == None )
                return;
            if(class'UTComp_Util'.Static.GetUTCompPRI(PRI)==None || class'UTComp_Util'.Static.GetUTCompPRI(PRI).ColoredName=="")
                Msg = PRI.PlayerName$"("$PRI.GetLocationName()$"): "$Msg;
            else
                Msg = class'UTComp_Util'.Static.GetUTCompPRI(PRI).ColoredName$class'UTComp_Util'.Static.MakeColorCode(GrayMessageColor)$"("$PRI.GetLocationName()$"): "$Msg;
            LocalMessageClass2 = class'CoachTeamSayMessagePlus';
            break;

        case 'CriticalEvent':
            LocalMessageClass2 = class'CriticalEventPlus';
            myHud.LocalizedMessage( LocalMessageClass2, 0, None, None, None, Msg );
            return;

        case 'DeathMessage':
            LocalMessageClass2 = class'xDeathMessage';
            break;

        default:
            LocalMessageClass2 = class'StringMessagePlus';
            break;
    }
    if(myHud!=None)
        myHud.AddTextMessage(Msg,LocalMessageClass2,PRI);
}

function GetMapList()
{
    UTCompPRI.GetMapList();
}

function string randomcolor()
{
    local color thecolor;
    theColor.R=Rand(250);
    theColor.G=Rand(250);
    theColor.B=Rand(250);
    return class'UTComp_Util'.Static.MakeColorCode(thecolor);
}

function string ColorReplace(int k)   //makes the 8 primary colors
{
    local color theColor;

    theColor.R=GetBit(k,0)*250;
    theColor.G=GetBit(k,1)*250;
    theColor.B=GetBit(k,2)*250;  //cant be 255 because of the chat window
    return class'UTComp_Util'.Static.MakeColorCode(theColor);
}

simulated function int GetBit(int theInt, int bitNum)
{
    return ((theInt & 1<<bitNum));
}

simulated function bool GetBitBool(int theInt, int bitNum)
{
   return ((theInt & 1<<bitNum)!=0);
}

simulated function MatchHudColor()
{
    local HudCDeathMatch DMHud;
    if(myHud==None || HudCDeathMatch(myHud)==None)
        return;
    DMHud=HudCDeathMatch(myHud);
    if(!HUDSettings.bMatchHudColor)
    {
        DMHud.HudColorRed=class'HudCDeathMatch'.default.HudColorRed;
        DMHud.HudColorBlue=class'HudCDeathMatch'.default.HudColorBlue;
        return;
    }

    if(!Settings.bEnemyBasedSkins)
    {
        if(Settings.ClientSkinModeRedTeammate == 3)
        {
            DMHud.HudColorRed=Settings.RedTeammateUTCompSkinColor;
        }
        else if(Settings.ClientSkinModeRedTeammate == 2
            || Settings.ClientSkinModeRedTeammate == 1)
        {
            DMHud.HudColorRed=class'UTComp_xPawn'.default.BrightSkinColors[Settings.PreferredSkinColorRedTeammate];
        }

        if(Settings.ClientSkinModeBlueEnemy == 3)
        {
            DMHud.HudColorBlue=Settings.BlueEnemyUTCompSkinColor;
        }
        else if(Settings.ClientSkinModeBlueEnemy == 2
            || Settings.ClientSkinModeBlueEnemy == 1)
        {
            DMHud.HudColorBlue=class'UTComp_xPawn'.default.BrightSkinColors[Settings.PreferredSkinColorBlueEnemy];
        }
    }
    else
    {
        if(Settings.ClientSkinModeRedTeammate == 3)
        {
            DMHud.HudColorBlue=Settings.RedTeammateUTCompSkinColor;
            DMHud.HudColorRed=Settings.RedTeammateUTCompSkinColor;
        }
        else if(Settings.ClientSkinModeRedTeammate == 2
            || Settings.ClientSkinModeRedTeammate == 1)
        {
            DMHud.HudColorBlue=class'UTComp_xPawn'.default.BrightSkinColors[Settings.PreferredSkinColorRedTeammate];
            DMHud.HudColorRed=class'UTComp_xPawn'.default.BrightSkinColors[Settings.PreferredSkinColorRedTeammate];
        }
    }
}

function BecomeSpectator()
{
    super.BecomeSpectator();
    ResetUTCompStats();
    ResetNet();
}

function ResetNet()
{
    if(UTCompPRI!=None)
        UTCompPRI.RealKills=0;
}

state PlayerWalking
{
    function bool NotifyLanded(vector HitNormal)
    {
        if (DoubleClickDir == DCLICK_Active)
        {
            DoubleClickDir = DCLICK_Done;
            ClearDoubleClick();
            Pawn.Velocity *= Vect(0.8,0.8,1.0);
        }
        else
            DoubleClickDir = DCLICK_None;

        if ( Global.NotifyLanded(HitNormal) )
            return true;

        return false;
    }

    function PlayerMove( float DeltaTime )
    {
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

        if( Pawn == None )
        {
            GotoState('Dead'); // this was causing instant respawns in mp games
            return;
        }

        GetAxes(Pawn.Rotation,X,Y,Z);

        // Update acceleration.
        NewAccel = aForward*X + aStrafe*Y;
        NewAccel.Z = 0;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);
        if (PlayerInput2 == none || PlayerInput2.Outer != self) {
            FindPlayerInput();
        }
        DoubleClickMove = PlayerInput2.CheckForDoubleClickMove(1.1*DeltaTime/Level.TimeDilation);

        GroundPitch = 0;
        ViewRotation = Rotation;
        if ( Pawn.Physics == PHYS_Walking )
        {
            // tell pawn about any direction changes to give it a chance to play appropriate animation
            //if walking, look up/down stairs - unless player is rotating view
             if ( (bLook == 0)
                && (((Pawn.Acceleration != Vect(0,0,0)) && bSnapToLevel) || !bKeyboardLook) )
            {
                if ( bLookUpStairs || bSnapToLevel )
                {
                    GroundPitch = FindStairRotation(deltaTime);
                    ViewRotation.Pitch = GroundPitch;
                }
                else if ( bCenterView )
                {
                    ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                    if (ViewRotation.Pitch > 32768)
                        ViewRotation.Pitch -= 65536;
                    ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                    if ( (Abs(ViewRotation.Pitch) < 250) && (ViewRotation.Pitch < 100) )
                        ViewRotation.Pitch = -249;
                }
            }
        }
        else
        {
            if ( !bKeyboardLook && (bLook == 0) && bCenterView )
            {
                ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                if (ViewRotation.Pitch > 32768)
                    ViewRotation.Pitch -= 65536;
                ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                if ( (Abs(ViewRotation.Pitch) < 250) && (ViewRotation.Pitch < 100) )
                    ViewRotation.Pitch = -249;
            }
        }
        Pawn.CheckBob(DeltaTime, Y);

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);
        bDoubleJump = false;

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            UTComp_ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }
}

function ServerSetEyeHeightAlgorithm(bool B) {
    bUseNewEyeHeightAlgorithm = B;
}

function SetEyeHeightAlgorithm(bool B) {
    bUseNewEyeHeightAlgorithm = B;
    ServerSetEyeHeightAlgorithm(B);
}

function TurnOffNetCode()
{
    local inventory inv;
    if(Pawn == none)
        return;
    for(inv = Pawn.Inventory; inv!=None; inv=inv.inventory)
    {
        if(Weapon(inv)!=None)
        {
            if(NewNet_AssaultRifle(Inv)!=None)
                NewNet_AssaultRifle(Inv).DisableNet();
            else if( NewNet_BioRifle(Inv)!=None)
                NewNet_BioRifle(Inv).DisableNet();
            else if(NewNet_ShockRifle(Inv)!=None)
                NewNet_ShockRifle(Inv).DisableNet();
            else if(NewNet_MiniGun(Inv)!=None)
                NewNet_MiniGun(Inv).DisableNet();
            else if(NewNet_LinkGun(Inv)!=None)
                NewNet_LinkGun(Inv).DisableNet();
            else if(NewNet_RocketLauncher(Inv)!=None)
                NewNet_RocketLauncher(inv).DisableNet();
            else if(NewNet_FlakCannon(inv)!=None)
                NewNet_FlakCannon(inv).DisableNet();
            else if(NewNet_SniperRifle(inv)!=None)
                NewNet_SniperRifle(inv).DisableNet();
            else if(NewNet_ClassicSniperRifle(inv)!=None)
                NewNet_ClassicSniperRifle(inv).DisableNet();
        }
    }
}

exec function GetSensitivity()
{
    Player.Console.Message("Sensitivity"@class'PlayerInput'.default.MouseSensitivity, 6.0);
}

// Add in a check for ping here eventually
// so we shut off if its outside the max
simulated function bool UseNewNet()
{
    return Settings.bEnableEnhancedNetCode;
}

/* replace calls fro old weapons if newnet is on */
exec function GetWeapon(class<Weapon> NewWeaponClass )
{
    if(RepInfo==None)
        foreach DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo);

    if (RepInfo.bEnableEnhancedNetCode) {
        if (NewWeaponClass == class'AssaultRifle')
            NewWeaponClass = class'NewNet_AssaultRifle';
        else if (NewWeaponClass == class'BioRifle')
            NewWeaponClass = class'NewNet_BioRifle';
        else if (NewWeaponClass == class'ClassicSniperRifle')
            NewWeaponClass = class'NewNet_ClassicSniperRifle';
        else if (NewWeaponClass == class'FlakCannon')
            NewWeaponClass = class'NewNet_FlakCannon';
        else if (NewWeaponClass == class'LinkGun')
            NewWeaponClass = class'NewNet_LinkGun';
        else if (NewWeaponClass == class'MiniGun')
            NewWeaponClass = class'NewNet_MiniGun';
        else if (NewWeaponClass == class'ONSAvril')
            NewWeaponClass = class'NewNet_ONSAvril';
        else if (NewWeaponClass == class'ONSGrenadeLauncher')
            NewWeaponClass = class'NewNet_ONSGrenadeLauncher';
        else if (NewWeaponClass == class'ONSMineLayer')
            NewWeaponClass = class'NewNet_ONSMineLayer';
        else if (NewWeaponClass == class'RocketLauncher')
            NewWeaponClass = class'NewNet_RocketLauncher';
        else if (NewWeaponClass == class'ShockRifle')
            NewWeaponClass = class'NewNet_ShockRifle';
        else if (NewWeaponClass == class'SniperRifle')
            NewWeaponClass = class'NewNet_SniperRifle';
    } else {
        if (NewWeaponClass == class'ShieldGun')
            NewWeaponClass = class'UTComp_ShieldGun';
        else if (NewWeaponClass == class'AssaultRifle')
            NewWeaponClass = class'UTComp_AssaultRifle';
        else if (NewWeaponClass == class'BioRifle')
            NewWeaponClass = class'UTComp_BioRifle';
        // else if (NewWeaponClass == class'ClassicSniperRifle')
        //     NewWeaponClass = class'UTComp_ClassicSniperRifle';
        else if (NewWeaponClass == class'FlakCannon')
            NewWeaponClass = class'UTComp_FlakCannon';
        else if (NewWeaponClass == class'LinkGun')
            NewWeaponClass = class'UTComp_LinkGun';
        else if (NewWeaponClass == class'MiniGun')
            NewWeaponClass = class'UTComp_MiniGun';
        // else if (NewWeaponClass == class'ONSAvril')
        //     NewWeaponClass = class'UTComp_ONSAvril';
        // else if (NewWeaponClass == class'ONSGrenadeLauncher')
        //     NewWeaponClass = class'UTComp_ONSGrenadeLauncher';
        // else if (NewWeaponClass == class'ONSMineLayer')
        //     NewWeaponClass = class'UTComp_ONSMineLayer';
        else if (NewWeaponClass == class'RocketLauncher')
            NewWeaponClass = class'UTComp_RocketLauncher';
        else if (NewWeaponClass == class'ShockRifle')
            NewWeaponClass = class'UTComp_ShockRifle';
        else if (NewWeaponClass == class'SniperRifle')
            NewWeaponClass = class'UTComp_SniperRifle';
    }
    super.GetWeapon(NewWeaponClass);
}

function DoCombo( class<Combo> ComboClass )
{
    if (Adrenaline >= ComboClass.default.AdrenalineCost && !Pawn.InCurrentCombo() && !ComboDisabled(ComboClass))
    {
        ServerDoCombo( ComboClass );
    }
}

function bool ComboDisabled(class<Combo> ComboClass)
{
    if(Settings.bDisableSpeed && ComboClass == class'xGame.ComboSpeed')
        return true;
    if(Settings.bDisableBooster && ComboClass == class'xGame.ComboDefensive')
        return true;
    if(Settings.bDisableInvis && ComboClass == class'xGame.ComboInvis')
        return true;
    if(Settings.bDisableBerserk && ComboClass == class'xGame.ComboBerserk')
        return true;

    return false;
}

event ClientTravel( string URL, ETravelType TravelType, bool bItems ) {
    super.ClientTravel(URL, TravelType, bItems);
    PlayerInput2 = none;
}

//--------------------------
//Additions for UTCompCTF
//--------------------------

//Override to modify suicide timer
exec function Suicide()
{
    if ((Pawn != None) && (Level.TimeSeconds - Pawn.LastStartTime > class'MutUTComp'.Default.SuicideInterval)) {
        Pawn.Suicide();
    }
}

state PlayerMousing extends Spectating
{

    event PlayerTick( float DeltaTime )
    {
        Super.PlayerTick(DeltaTime);
        if (bRun == 0)
            GoToState('Spectating');
    }

    exec function Fire(float f)
    {
        // do stuff here for when players click their fire/select button
        Overlay.Click();
        return;
    }

    simulated function PlayerMove(float DeltaTime)
    {
        local vector MouseV, ScreenV;

        // get the new mouse position offset
        MouseV.X = DeltaTime * aMouseX / (InputClass.default.MouseSensitivity * DesiredFOV * 0.01111) * (class'GUIController'.default.MenuMouseSens * 2);
        MouseV.Y = DeltaTime * aMouseY / (InputClass.default.MouseSensitivity * DesiredFOV * -0.01111) * (class'GUIController'.default.MenuMouseSens * 2);

        // update mouse position
        PlayerMouse += MouseV;

        // convert mouse position to screen coords, but only if we have good screen sizes
        if ((LastHUDSizeX > 0) && (LastHUDSizeY > 0))
        {
            ScreenV.X = PlayerMouse.X + LastHUDSizeX * 0.5;
            ScreenV.Y = PlayerMouse.Y + LastHUDSizeY * 0.5;
            // here is where you would use the screen coords to do a trace or check HUD elements
        }

        //Super.PlayerMove(deltaTime);

        return;
    }
}

function int FractionCorrection(float in, out float fraction) {
    local int result;
    local float tmp;

    tmp = in + fraction;
    result = int(tmp);
    fraction = tmp - result;

    return result;
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
    local rotator newRotation, ViewRotation;

    if ( bInterpolating || ((Pawn != None) && Pawn.bInterpolating) )
    {
        ViewShake(deltaTime);
        return;
    }

    // Added FreeCam control for better view control
    if (bFreeCam == True)
    {
        if (bFreeCamZoom == True)
        {
            CameraDeltaRad += FractionCorrection(DeltaTime * 0.25 * aLookUp, PitchFraction);
        }
        else if (bFreeCamSwivel == True)
        {
            CameraSwivel.Yaw += FractionCorrection(16.0 * DeltaTime * aTurn, YawFraction);
            CameraSwivel.Pitch += FractionCorrection(16.0 * DeltaTime * aLookUp, PitchFraction);
        }
        else
        {
            CameraDeltaRotation.Yaw += FractionCorrection(32.0 * DeltaTime * aTurn, YawFraction);
            CameraDeltaRotation.Pitch += FractionCorrection(32.0 * DeltaTime * aLookUp, PitchFraction);
        }
    }
    else
    {
        ViewRotation = Rotation;

        if(Pawn != None && Pawn.Physics != PHYS_Flying) // mmmmm
        {
            // Ensure we are not setting the pawn to a rotation beyond its desired
            if (Pawn.DesiredRotation.Roll < 65535 &&
                (ViewRotation.Roll < Pawn.DesiredRotation.Roll || ViewRotation.Roll > 0)
            ) {
                ViewRotation.Roll = 0;

            } else if (Pawn.DesiredRotation.Roll > 0 &&
                (ViewRotation.Roll > Pawn.DesiredRotation.Roll || ViewRotation.Roll < 65535)
            ) {
                ViewRotation.Roll = 0;
            }
        }

        DesiredRotation = ViewRotation; //save old rotation

        if ( bTurnToNearest != 0 )
            TurnTowardNearestEnemy();
        else if ( bTurn180 != 0 )
            TurnAround();
        else
        {
            TurnTarget = None;
            bRotateToDesired = false;
            bSetTurnRot = false;
            ViewRotation.Yaw += FractionCorrection(32.0 * DeltaTime * aTurn, YawFraction);
            ViewRotation.Pitch += FractionCorrection(32.0 * DeltaTime * aLookUp, PitchFraction);
        }
        if (Pawn != None)
            ViewRotation.Pitch = Pawn.LimitPitch(ViewRotation.Pitch);

        SetRotation(ViewRotation);

        ViewShake(deltaTime);
        ViewFlash(deltaTime);

        NewRotation = ViewRotation;
        //NewRotation.Roll = Rotation.Roll;

        if ( !bRotateToDesired && (Pawn != None) && (!bFreeCamera || !bBehindView) )
            Pawn.FaceRotation(NewRotation, deltatime);
    }
}

function bool WantsSmoothedView()
{
    if (Pawn == none) return false;

    return
        (((Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Spider)) && Pawn.bJustLanded == false) ||
        (Pawn.Physics == PHYS_Falling && UTComp_xPawn(Pawn).OldPhysics2 == PHYS_Walking);
}

state PlayerSwimming {
ignores SeePlayer, HearNoise, Bump;

    function bool WantsSmoothedView()
    {
        return ( !Pawn.bJustLanded );
    }
}

function UTComp_ReplicateMove(
    float DeltaTime,
    vector NewAccel,
    eDoubleClickDir DoubleClickMove,
    rotator DeltaRot
) {
    local SavedMove NewMove, OldMove, AlmostLastMove, LastMove;
    local byte ClientRoll;
    local float OldTimeDelta;
    local int OldAccel;
    local vector BuildAccel, AccelNorm, MoveLoc, CompareAccel;
    local bool bPendingJumpStatus;

    MaxResponseTime = Default.MaxResponseTime * Level.TimeDilation;
    DeltaTime = FMin(DeltaTime, MaxResponseTime);

    // find the most recent move, and the most recent interesting move
    if ( SavedMoves != None )
    {
        LastMove = SavedMoves;
        AlmostLastMove = LastMove;
        AccelNorm = Normal(NewAccel);
        while ( LastMove.NextMove != None )
        {
            // find most recent interesting move to send redundantly
            if ( LastMove.IsJumpMove() )
            {
                OldMove = LastMove;
            }
            else if ( (Pawn != None) && ((OldMove == None) || !OldMove.IsJumpMove()) )
            {
                // see if acceleration direction changed
                if ( OldMove != None )
                    CompareAccel = Normal(OldMove.Acceleration);
                else
                    CompareAccel = AccelNorm;

                if ( (LastMove.Acceleration != CompareAccel) && ((normal(LastMove.Acceleration) Dot CompareAccel) < 0.95) )
                    OldMove = LastMove;
            }

            AlmostLastMove = LastMove;
            LastMove = LastMove.NextMove;
        }
        if ( LastMove.IsJumpMove() )
        {
            OldMove = LastMove;
        }
        else if ( (Pawn != None) && ((OldMove == None) || !OldMove.IsJumpMove()) )
        {
            // see if acceleration direction changed
            if ( OldMove != None )
                CompareAccel = Normal(OldMove.Acceleration);
            else
                CompareAccel = AccelNorm;

            if ( (LastMove.Acceleration != CompareAccel) && ((normal(LastMove.Acceleration) Dot CompareAccel) < 0.95) )
                OldMove = LastMove;
        }
    }

    // Get a SavedMove actor to store the movement in.
    NewMove = GetFreeMove();
    if ( NewMove == None )
        return;
    NewMove.SetMoveFor(self, DeltaTime, NewAccel, DoubleClickMove);
    NewMove.RemoteRole = ROLE_None;

    // Simulate the movement locally.
    bDoubleJump = false;
    ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DoubleClickMove, DeltaRot);

    // see if the two moves could be combined
    if ((PendingMove != None) &&
        (Pawn != None) &&
        (Pawn.Physics == PHYS_Walking) &&
        (NewMove.Delta + PendingMove.Delta < MaxResponseTime) &&
        (NewAccel != vect(0,0,0)) &&
        (PendingMove.SavedPhysics == PHYS_Walking) &&
        !PendingMove.bPressedJump &&
        !NewMove.bPressedJump &&
        (PendingMove.bRun == NewMove.bRun) &&
        (PendingMove.bDuck == NewMove.bDuck) &&
        (PendingMove.bDoubleJump == NewMove.bDoubleJump) &&
        (PendingMove.DoubleClickMove == DCLICK_None) &&
        (NewMove.DoubleClickMove == DCLICK_None) &&
        ((Normal(PendingMove.Acceleration) Dot Normal(NewAccel)) > 0.99) &&
        (Level.TimeDilation >= 0.9)
    ) {
        Pawn.SetLocation(PendingMove.GetStartLocation());
        Pawn.Velocity = PendingMove.StartVelocity;
        if ( PendingMove.StartBase != Pawn.Base);
            Pawn.SetBase(PendingMove.StartBase);
        Pawn.Floor = PendingMove.StartFloor;
        NewMove.Delta += PendingMove.Delta;
        NewMove.SetInitialPosition(Pawn);

        // remove pending move from move list
        if (LastMove == PendingMove) {
            if (SavedMoves == PendingMove) {
                SavedMoves.NextMove = FreeMoves;
                FreeMoves = SavedMoves;
                SavedMoves = None;
            } else {
                PendingMove.NextMove = FreeMoves;
                FreeMoves = PendingMove;
                if (AlmostLastMove != None) {
                    AlmostLastMove.NextMove = None;
                    LastMove = AlmostLastMove;
                }
            }
            FreeMoves.Clear();
        }
        PendingMove = None;
    }

    if (Pawn != None)
        Pawn.AutonomousPhysics(NewMove.Delta);
    else
        AutonomousPhysics(DeltaTime);
    NewMove.PostUpdate(self);

    if (SavedMoves == None)
        SavedMoves = NewMove;
    else
        LastMove.NextMove = NewMove;

    if (PendingMove == None) {
        // Decide whether to hold off on move
        if ((Level.TimeSeconds - ClientUpdateTime) * Level.TimeDilation * 0.91 < TimeBetweenUpdates) {
            PendingMove = NewMove;
            return;
        }
    }

    ClientUpdateTime = Level.TimeSeconds;

    // check if need to redundantly send previous move
    if ( OldMove != None )
    {
        // old move important to replicate redundantly
        OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
        BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
        OldAccel = (CompressAccel(BuildAccel.X) << 23)
                    + (CompressAccel(BuildAccel.Y) << 15)
                    + (CompressAccel(BuildAccel.Z) << 7);
        if (OldMove.bRun)
            OldAccel += 64;
        if (OldMove.bDoubleJump)
            OldAccel += 32;
        if (OldMove.bPressedJump)
            OldAccel += 16;
        OldAccel += OldMove.DoubleClickMove;
    }

    // Send to the server
    ClientRoll = (Rotation.Roll >> 8) & 255;
    if (PendingMove != None) {
        if ( PendingMove.bPressedJump )
            bJumpStatus = !bJumpStatus;
        bPendingJumpStatus = bJumpStatus;
    }
    if (NewMove.bPressedJump)
        bJumpStatus = !bJumpStatus;

    if (Pawn == None)
        MoveLoc = Location;
    else
        MoveLoc = Pawn.Location;

    UTComp_CallServerMove(
        NewMove.TimeStamp,
        NewMove.Acceleration * 10,
        MoveLoc,
        NewMove.bRun,
        NewMove.bDuck,
        bPendingJumpStatus,
        bJumpStatus,
        NewMove.bDoubleJump,
        NewMove.DoubleClickMove,
        ClientRoll,
        ((0xFFFF & Rotation.Pitch) << 16) | (0xFFFF & Rotation.Yaw),
        OldTimeDelta,
        OldAccel
    );
    PendingMove = None;
}

function UTComp_CallServerMove(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbPendingJumpStatus,
    bool NewbJumpStatus,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
) {
    local byte PendingCompress;
    local bool bCombine;

    if ( PendingMove != None ) {
        PendingCompress = PendingCompress | int(PendingMove.bRun);
        PendingCompress = PendingCompress | int(PendingMove.bDuck) << 1;
        PendingCompress = PendingCompress | int(NewbPendingJumpStatus) << 2;
        PendingCompress = PendingCompress | int(PendingMove.bDoubleJump) << 3;
        PendingCompress = PendingCompress | int(NewbRun) << 4;
        PendingCompress = PendingCompress | int(NewbDuck) << 5;
        PendingCompress = PendingCompress | int(NewbJumpStatus) << 6;
        PendingCompress = PendingCompress | int(NewbDoubleJump) << 7;

        // send two moves simultaneously
        if ((InAccel == vect(0,0,0)) &&
            (PendingMove.StartVelocity == vect(0,0,0)) &&
            (DoubleClickMove == DCLICK_None) &&
            (PendingMove.Acceleration == vect(0,0,0)) &&
            (PendingMove.DoubleClickMove == DCLICK_None) &&
            !PendingMove.bDoubleJump
        ) {
            if ( Pawn == None )
                bCombine = (Velocity == vect(0,0,0));
            else
                bCombine = (Pawn.Velocity == vect(0,0,0));

            if (bCombine) {
                if (OldTimeDelta == 0) {
                    UTComp_ShortServerMove(
                        TimeStamp,
                        ClientLoc,
                        NewbRun,
                        NewbDuck,
                        NewbJumpStatus,
                        ClientRoll,
                        View
                    );
                } else {
                    UTComp_ServerMove(
                        TimeStamp,
                        InAccel,
                        ClientLoc,
                        NewbRun,
                        NewbDuck,
                        NewbJumpStatus,
                        NewbDoubleJump,
                        DoubleClickMove,
                        ClientRoll,
                        View,
                        OldTimeDelta,
                        OldAccel
                    );
                }
                return;
            }
        }

        if ( OldTimeDelta == 0 )
            UTComp_DualServerMove(
                PendingMove.TimeStamp,
                PendingMove.Acceleration * 10,
                PendingCompress,
                PendingMove.DoubleClickMove,
                ((0xFFFF & PendingMove.Rotation.Pitch) << 16) | (0xFFFF & PendingMove.Rotation.Yaw),
                TimeStamp,
                InAccel,
                ClientLoc,
                DoubleClickMove,
                ClientRoll,
                View
            );
        else
            UTComp_DualServerMove(
                PendingMove.TimeStamp,
                PendingMove.Acceleration * 10,
                PendingCompress,
                PendingMove.DoubleClickMove,
                ((0xFFFF & PendingMove.Rotation.Pitch) << 16) | (0xFFFF & PendingMove.Rotation.Yaw),
                TimeStamp,
                InAccel,
                ClientLoc,
                DoubleClickMove,
                ClientRoll,
                View,
                OldTimeDelta,
                OldAccel
            );
    } else if ( OldTimeDelta != 0 ) {
        UTComp_ServerMove(
            TimeStamp,
            InAccel,
            ClientLoc,
            NewbRun,
            NewbDuck,
            NewbJumpStatus,
            NewbDoubleJump,
            DoubleClickMove,
            ClientRoll,
            View,
            OldTimeDelta,
            OldAccel
        );
    } else if ((InAccel == vect(0,0,0)) && (DoubleClickMove == DCLICK_None) && !NewbDoubleJump) {
        UTComp_ShortServerMove(
            TimeStamp,
            ClientLoc,
            NewbRun,
            NewbDuck,
            NewbJumpStatus,
            ClientRoll,
            View
        );
    } else {
        UTComp_ServerMove(
            TimeStamp,
            InAccel,
            ClientLoc,
            NewbRun,
            NewbDuck,
            NewbJumpStatus,
            NewbDoubleJump,
            DoubleClickMove,
            ClientRoll,
            View
        );
    }
}

/* ShortServerMove()
compressed version of server move for bandwidth saving
*/
function UTComp_ShortServerMove(
    float TimeStamp,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbJumpStatus,
    byte ClientRoll,
    int View
) {
    UTComp_ServerMove(TimeStamp,vect(0,0,0),ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,false,DCLICK_None,ClientRoll,View);
}

/* DualServerMove()
- replicated function sent by client to server - contains client movement and firing info for two moves
*/
function UTComp_DualServerMove(
    float TimeStamp0,
    vector InAccel0,
    byte PendingCompress,
    eDoubleClickDir DoubleClickMove0,
    int View0,
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
) {
    local bool NewbRun0,NewbDuck0,NewbJumpStatus0,NewbDoubleJump0,
                NewbRun,NewbDuck,NewbJumpStatus,NewbDoubleJump;

    NewbRun0 =        (PendingCompress & 0x01) != 0;
    NewbDuck0 =       (PendingCompress & 0x02) != 0;
    NewbJumpStatus0 = (PendingCompress & 0x04) != 0;
    NewbDoubleJump0 = (PendingCompress & 0x08) != 0;
    NewbRun =         (PendingCompress & 0x10) != 0;
    NewbDuck =        (PendingCompress & 0x20) != 0;
    NewbJumpStatus =  (PendingCompress & 0x40) != 0;
    NewbDoubleJump =  (PendingCompress & 0x80) != 0;

    UTComp_ServerMove(TimeStamp0,InAccel0,vect(0,0,0),NewbRun0,NewbDuck0,NewbJumpStatus0,NewbDoubleJump0,DoubleClickMove0,
            ClientRoll,View0);
    if ( ClientLoc == vect(0,0,0) )
        ClientLoc = vect(0.1,0,0);
    UTComp_ServerMove(TimeStamp,InAccel,ClientLoc,NewbRun,NewbDuck,NewbJumpStatus,NewbDoubleJump,DoubleClickMove,ClientRoll,View,OldTimeDelta,OldAccel);
}

/* ServerMove()
- replicated function sent by client to server - contains client movement and firing info.
*/
function UTComp_ServerMove(
    float TimeStamp,
    vector InAccel,
    vector ClientLoc,
    bool NewbRun,
    bool NewbDuck,
    bool NewbJumpStatus,
    bool NewbDoubleJump,
    eDoubleClickDir DoubleClickMove,
    byte ClientRoll,
    int View,
    optional byte OldTimeDelta,
    optional int OldAccel
) {
    local float DeltaTime, clientErr, OldTimeStamp;
    local rotator DeltaRot, Rot, ViewRot;
    local vector Accel, LocDiff;
    local int maxPitch, ViewPitch, ViewYaw;
    local bool NewbPressedJump, OldbRun, OldbDoubleJump;
    local eDoubleClickDir OldDoubleClickMove;

    // If this move is outdated, discard it.
    if ( CurrentTimeStamp >= TimeStamp )
        return;

    if ( AcknowledgedPawn != Pawn )
    {
        OldTimeDelta = 0;
        InAccel = vect(0,0,0);
        GivePawn(Pawn);
    }

    // if OldTimeDelta corresponds to a lost packet, process it first
    if (  OldTimeDelta != 0 )
    {
        OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
        if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
        {
            // split out components of lost move (approx)
            Accel.X = OldAccel >>> 23;
            if ( Accel.X > 127 )
                Accel.X = -1 * (Accel.X - 128);
            Accel.Y = (OldAccel >>> 15) & 255;
            if ( Accel.Y > 127 )
                Accel.Y = -1 * (Accel.Y - 128);
            Accel.Z = (OldAccel >>> 7) & 255;
            if ( Accel.Z > 127 )
                Accel.Z = -1 * (Accel.Z - 128);
            Accel *= 20;

            OldbRun = ( (OldAccel & 64) != 0 );
            OldbDoubleJump = ( (OldAccel & 32) != 0 );
            NewbPressedJump = ( (OldAccel & 16) != 0 );
            if ( NewbPressedJump )
                bJumpStatus = NewbJumpStatus;
            switch (OldAccel & 7)
            {
                case 0:
                    OldDoubleClickMove = DCLICK_None;
                    break;
                case 1:
                    OldDoubleClickMove = DCLICK_Left;
                    break;
                case 2:
                    OldDoubleClickMove = DCLICK_Right;
                    break;
                case 3:
                    OldDoubleClickMove = DCLICK_Forward;
                    break;
                case 4:
                    OldDoubleClickMove = DCLICK_Back;
                    break;
            }
            //log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
            OldTimeStamp = FMin(OldTimeStamp, CurrentTimeStamp + MaxResponseTime);
            MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, (bDuck == 1), NewbPressedJump, OldbDoubleJump, OldDoubleClickMove, Accel, rot(0,0,0));
            CurrentTimeStamp = OldTimeStamp;
        }
    }

    // View components
    ViewPitch = View >>> 16;
    ViewYaw = View & 0xFFFF;
    // Make acceleration.
    Accel = InAccel * 0.1;

    NewbPressedJump = (bJumpStatus != NewbJumpStatus);
    bJumpStatus = NewbJumpStatus;

    // Save move parameters.
    DeltaTime = FMin(MaxResponseTime,TimeStamp - CurrentTimeStamp);

    if ( Pawn == None )
    {
        ResetTimeMargin();
    }
    else if ( !CheckSpeedHack(DeltaTime) )
    {
        bWasSpeedHack = true;
        DeltaTime = 0;
        Pawn.Velocity = vect(0,0,0);
    }
    else if ( bWasSpeedHack )
    {
        // if have had a speedhack detection, then modify deltatime if getting too far ahead again
        if ( (TimeMargin > 0.5 * Level.MaxTimeMargin) && (Level.MaxTimeMargin > 0) )
            DeltaTime *= 0.8;
    }

    CurrentTimeStamp = TimeStamp;
    ServerTimeStamp = Level.TimeSeconds;
    ViewRot.Pitch = ViewPitch;
    ViewRot.Yaw = ViewYaw;
    ViewRot.Roll = 0;

    if ( NewbPressedJump || (InAccel != vect(0,0,0)) )
        LastActiveTime = Level.TimeSeconds;

    if ( Pawn == None || Pawn.bServerMoveSetPawnRot )
        SetRotation(ViewRot);

    if ( AcknowledgedPawn != Pawn )
        return;

    if ( (Pawn != None) && Pawn.bServerMoveSetPawnRot )
    {
        Rot.Roll = 256 * ClientRoll;
        Rot.Yaw = ViewYaw;
        if ( (Pawn.Physics == PHYS_Swimming) || (Pawn.Physics == PHYS_Flying) )
            maxPitch = 2;
        else
            maxPitch = 0;
        if ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
        {
            If (ViewPitch < 32768)
                Rot.Pitch = maxPitch * RotationRate.Pitch;
            else
                Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
        }
        else
            Rot.Pitch = ViewPitch;
        DeltaRot = (Rotation - Rot);
        Pawn.SetRotation(Rot);
    }

    // Perform actual movement
    if ( (Level.Pauser == None) && (DeltaTime > 0) )
        MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, NewbDoubleJump, DoubleClickMove, Accel, DeltaRot);

    // Accumulate movement error.
    if ( ClientLoc == vect(0,0,0) )
        return;     // first part of double servermove
    else if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
        ClientErr = 10000;
    else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
    {
        if ( Pawn == None )
            LocDiff = Location - ClientLoc;
        else
            LocDiff = Pawn.Location - ClientLoc;
        ClientErr = LocDiff Dot LocDiff;
    }

    // If client has accumulated a noticeable positional error, correct him.
    if ( ClientErr > 3 )
    {
        if ( Pawn == None )
        {
            PendingAdjustment.newPhysics = Physics;
            PendingAdjustment.NewLoc = Location;
            PendingAdjustment.NewVel = Velocity;
        }
        else
        {
            PendingAdjustment.newPhysics = Pawn.Physics;
            PendingAdjustment.NewVel = Pawn.Velocity;
            PendingAdjustment.NewBase = Pawn.Base;
            if ( (Mover(Pawn.Base) != None) || (Vehicle(Pawn.Base) != None) )
                PendingAdjustment.NewLoc = Pawn.Location - Pawn.Base.Location;
            else
                PendingAdjustment.NewLoc = Pawn.Location;
            PendingAdjustment.NewFloor = Pawn.Floor;
        }
        //if ( (ClientErr != 10000) && (Pawn != None) )
            //Log(" Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Pawn.Physics);
        LastUpdateTime = Level.TimeSeconds;

        PendingAdjustment.TimeStamp = TimeStamp;
        PendingAdjustment.newState = GetStateName();
    }
    //log("Server moved stamp "$TimeStamp$" location "$Pawn.Location$" Acceleration "$Pawn.Acceleration$" Velocity "$Pawn.Velocity);
}

simulated final function ReceiveWeaponEffect(
    class<UTComp_WeaponEffect> Effect,
    Pawn Source,
    vector SourceLocation,
    vector Direction,
    vector HitLocation,
    vector HitNormal,
    int ReflectNum
) {
    Effect.static.Play(
        self,
        Settings,
        Source,
        SourceLocation,
        Normal(Direction/32767),
        HitLocation,
        Normal(HitNormal/32767),
        ReflectNum
    );
}

simulated final function DemoReceiveWeaponEffect(
    class<UTComp_WeaponEffect> Effect,
    Pawn Source,
    vector SourceLocation,
    vector Direction,
    vector HitLocation,
    vector HitNormal,
    int ReflectNum
) {
    if (LastWeaponEffectSent >= 0) return;
    Effect.static.Play(
        self,
        Settings,
        Source,
        SourceLocation,
        Normal(Direction/32767),
        HitLocation,
        Normal(HitNormal/32767),
        ReflectNum
    );
}

simulated final function SendWeaponEffect(
    class<UTComp_WeaponEffect> Effect,
    Pawn Source,
    vector SourceLocation,
    vector Direction,
    vector HitLocation,
    vector HitNormal,
    int ReflectNum
) {
    ReceiveWeaponEffect(
        Effect,
        Source,
        SourceLocation,
        Direction * 32767,
        HitLocation,
        HitNormal * 32767,
        ReflectNum
    );
    LastWeaponEffectSent = Level.TimeSeconds;
    DemoReceiveWeaponEffect(
        Effect,
        Source,
        SourceLocation,
        Direction * 32767,
        HitLocation,
        HitNormal * 32767,
        ReflectNum
    );
}

simulated function ClientResetNetcode()
{
    local Timestamp_Pawn P;

    foreach DynamicActors(class'Timestamp_Pawn', P)
    {
        if(P != None)
            P.Destroy();
    }
}

simulated function Destroyed()
{
    local LinkedReplicationInfo LPRI, Next;

    if(PlayerReplicationInfo != None)
    {
        LPRI = PlayerReplicationInfo.CustomReplicationInfo;
        while(LPRI != None)
        {
            Next = LPRI.NextReplicationInfo;
            LPRI.Destroy();
            LPRI = Next;
        }

        PlayerReplicationInfo.CustomReplicationInfo = None;
    }

    super.Destroyed();
}

defaultproperties
{

     UTCompMenuClass="UTCompv18c.UTComp_Menu_OpenedMenu"
     UTCompVotingMenuClass="UTCompv18c.UTComp_Menu_VoteInProgress"
     redmessagecolor=(B=64,G=64,R=255,A=255)
     greenmessagecolor=(B=128,G=255,R=128,A=255)
     bluemessagecolor=(B=255,G=192,R=64,A=255)
     yellowmessagecolor=(G=255,R=255,A=255)
     graymessagecolor=(B=155,G=155,R=255)

     WepStatNames(0)="Combo"
     WepStatNames(1)="I-Gib"
     WepStatNames(2)="AVRIL"
     WepStatNames(3)="Grenades"
     WepStatNames(4)="Spider"
     WepStatNames(5)="Sniper"
     WepStatNames(6)="Rockets"
     WepStatNames(7)="Flak"
     WepStatNames(8)="Mini"
     WepStatNames(9)="Link"
     WepStatNames(10)="Shock"
     WepStatNames(11)="Bio"
     WepStatNames(12)="Assault"
     WepStatNames(13)="Shield"
     WepStatNames(14)="Crush"
     WepStatDamTypesAlt(6)=Class'XWeapons.DamTypeRocketHoming'
     WepStatDamTypesAlt(7)=Class'XWeapons.DamTypeFlakShell'
     WepStatDamTypesAlt(8)=Class'XWeapons.DamTypeMinigunAlt'
     WepStatDamTypesAlt(9)=Class'XWeapons.DamTypeLinkShaft'
     WepStatDamTypesAlt(10)=Class'XWeapons.DamTypeShockBall'
     WepStatDamTypesAlt(12)=Class'XWeapons.DamTypeAssaultGrenade'
     WepStatDamTypesPrim(0)=Class'XWeapons.DamTypeShockCombo'
     WepStatDamTypesPrim(1)=Class'XWeapons.DamTypeSuperShockBeam'
     WepStatDamTypesPrim(2)=Class'Onslaught.DamTypeONSAVRiLRocket'
     WepStatDamTypesPrim(3)=Class'Onslaught.DamTypeONSGrenade'
     WepStatDamTypesPrim(4)=Class'Onslaught.DamTypeONSMine'
     WepStatDamTypesPrim(5)=Class'XWeapons.DamTypeSniperShot'
     WepStatDamTypesPrim(6)=Class'XWeapons.DamTypeRocket'
     WepStatDamTypesPrim(7)=Class'XWeapons.DamTypeFlakChunk'
     WepStatDamTypesPrim(8)=Class'XWeapons.DamTypeMinigunBullet'
     WepStatDamTypesPrim(9)=Class'XWeapons.DamTypeLinkPlasma'
     WepStatDamTypesPrim(10)=Class'XWeapons.DamTypeShockBeam'
     WepStatDamTypesPrim(11)=Class'XWeapons.DamTypeBioGlob'
     WepStatDamTypesPrim(12)=Class'XWeapons.DamTypeAssaultBullet'
     WepStatDamTypesPrim(13)=Class'XWeapons.DamTypeShieldImpact'
     WepStatDamTypesPrim(14)=Class'Engine.Crushed'
     CustomWepTypes(0)=(WepName="Manta",damtype[0]="Onslaught.DamTypeHoverBikePancake",damtype[1]="Onslaught.DamTypeHoverBikeHeadshot",damtype[2]="Onslaught.DamTypeHoverBikePlasma")
     CustomWepTypes(1)=(WepName="Raptor",damtype[0]="Onslaught.DamTypeAttackCraftPancake",damtype[1]="Onslaught.DamTypeAttackCraftRoadkill",damtype[2]="Onslaught.DamTypeAttackCraftMissle",damtype[3]="Onslaught.DamTypeAttackCraftPlasma")
     CustomWepTypes(2)=(WepName="HBender",damtype[0]="Onslaught.DamTypePRVPancake",damtype[1]="Onslaught.DamTypePRVRoadkill",damtype[2]="Onslaught.DamTypePRVCombo",damtype[3]="Onslaught.DamTypePRVLaser",damtype[4]="Onslaught.DamTypeChargingBeam",damtype[5]="Onslaught.DamTypeSkyMine")
     CustomWepTypes(3)=(WepName="Scorpion",damtype[0]="Onslaught.DamTypeRVPancake",damtype[1]="Onslaught.DamTypeRVRoadkill",damtype[2]="Onslaught.DamTypeONSRVBlade",damtype[3]="Onslaught.DamTypeONSWeb")
     CustomWepTypes(4)=(WepName="Goliath",damtype[0]="Onslaught.DamTypeTankPancake",damtype[1]="Onslaught.DamTypeTankRoadkill",damtype[2]="Onslaught.DamTypeTankShell")
     CustomWepTypes(5)=(WepName="Leviath",damtype[0]="OnslaughtFull.DamTypeMASCannon",damtype[1]="OnslaughtFull.DamTypeMASPlasma",damtype[2]="OnslaughtFull.DamTypeMASRoadKill",damtype[3]="OnslaughtFull.DamTypeMASPanCake")
     CustomWepTypes(6)=(WepName="Fighter",damtype[0]="UT2k4AssaultFull.DamTypeSpaceFighterLaser",damtype[1]="UT2k4AssaultFull.DamTypeSpaceFighterLaser_Skaarj",damtype[2]="UT2k4AssaultFull.DamTypeSpaceFighterMissile",damtype[3]="UT2k4AssaultFull.DamTypeSpaceFighterMissileSkaarj")
     CustomWepTypes(7)=(WepName="IonTank",damtype[0]="OnslaughtFull.DamTypeIonTankBlast",damtype[1]="UT2k4AssaultFull.DamTypeIonCannonBlast")
     CustomWepTypes(8)=(WepName="SuperWep",damtype[0]="XWeapons.DamTypeRedeemer",DamType[1]="XWeapons.DamTypeIonBlast")
     CustomWepTypes(9)=(WepName="Paladin",damtype[0]="OnslaughtBP.DamTypeShockTankProximityExplosion",DamType[1]="OnslaughtBP.DamTypeShockTankShockBall")
     CustomWepTypes(10)=(WepName="Cicada",damtype[0]="OnslaughtBP.DamTypeONSCicadaRocket",DamType[1]="OnslaughtBP.DamTypeONSCicadaLaser")
     CustomWepTypes(11)=(WepName="SPMA",damtype[0]="OnslaughtBP.DamTypeArtilleryShell")
     CustomWepTypes(12)=(WepName="XxxX ESR",damtype[0]="XxxXESRInstaGib",damtype[1]="XxxXESRHeadshot")

     TimeBetweenUpdates=0.0111111;
     LastWeaponEffectSent=-1
}
