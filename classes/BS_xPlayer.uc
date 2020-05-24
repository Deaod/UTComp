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

replication
{
    unreliable if(Role==Role_Authority)
        ReceiveHit, ReceiveStats, ReceiveHitSound;
    reliable if (Role==Role_Authority)
        StartDemo, NotifyEndWarmup, SetClockTime, NotifyRestartMap, SetClockTimeOnly, SetEndTimeOnly;
    reliable if(Role<Role_Authority)
        SetbStats, TurnOffNetCode;
    unreliable if(Role<Role_Authority)
        ServerNextPlayer, ServerGoToPlayer, ServerFindNextNode,
        serverfindprevnode, servergotonode, ServerGoToWepBase, speclockRed, speclockBlue, CallVote;
    reliable if(Role<Role_Authority)
        ServerAdminReady, BroadCastVote, BroadCastReady;
}



simulated function MakeSureSaveConfig()
{
 /* local int i;

  bStats = class'UTComp_Settings'.default.bStats;
  bEnableUTCompAutoDemorec = class'UTComp_Settings'.default.bEnableUTCompAutoDemorec;
  DemoRecordingMask = class'UTComp_Settings'.default.DemoRecordingMask;
  bEnableAutoScreenshot = class'UTComp_Settings'.default.bEnableAutoScreenshot;
  ScreenShotMask = class'UTComp_Settings'.default.ScreenShotMask;
  FriendlySound = class'UTComp_Settings'.default.FriendlySound;
  EnemySound = class'UTComp_Settings'.default.EnemySound;
  bEnableHitSounds = class'UTComp_Settings'.default.bEnableHitSounds;
  HitSoundVolume = class'UTComp_Settings'.default.HitSoundVolume;
  bCPMAStyleHitsounds = class'UTComp_Settings'.default.bCPMAStyleHitsounds;
  CPMAPitchModifier = class'UTComp_Settings'.default.CPMAPitchModifier;
  SavedSpectateSpeed = class'UTComp_Settings'.default.SavedSpectateSpeed;
  bUseDefaultScoreBoard = class'UTComp_Settings'.default.bUseDefaultScoreBoard;
  bShowSelfInTeamOverlay = class'UTComp_Settings'.default.bShowSelfInTeamOverlay;
  bEnableEnhancedNetCode = class'UTComp_Settings'.default.bEnableEnhancedNetCode;
  bEnableColoredNamesOnEnemies = class'UTComp_Settings'.default.bEnableColoredNamesOnEnemies;

  ballowcoloredmessages = class'UTComp_Settings'.default.ballowcoloredmessages;
  bEnableColoredNamesInTalk = class'UTComp_Settings'.default.bEnableColoredNamesInTalk;

  LoadedEnemySound = Sound(DynamicLoadObject(class'UTComp_Settings'.default.EnemySound, class'Sound', True));
  LoadedFriendlySound = Sound(DynamicLoadObject(class'UTComp_Settings'.default.FriendlySound, class'Sound', True));




  CurrentSelectedColoredName = class'UTComp_Settings'.default.CurrentSelectedColoredName;
  for(i=0; i<ArrayCount(ColorName); i++)
  {
      ColorName[i] = class'UTComp_Settings'.default.ColorName[i];
  }
  ColoredName =  class'UTComp_Settings'.default.ColoredName;       */
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    AssignStatNames();
    ChangeDeathMessageOrder();
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
    if(RepInfo==None)
        foreach DynamicActors(Class'UTComp_ServerReplicationInfo', RepInfo)
            break;
    if(uWarmup==None)
        foreach Dynamicactors(class'UTComp_Warmup', uWarmup)
            break;
    if(UTCompPRI==None)
        UTCompPRI=class'UTComp_Util'.static.GetUTCompPRIFor(self);
    if(Level.NetMode!=NM_DedicatedServer && !Blah && PlayerReplicationInfo !=None && PlayerReplicationInfo.CustomReplicationInfo!=None && myHud !=None && RepInfo!=None && UTCompPRI!=None)
    {
        if(uWarmup==None || !uWarmup.bInWarmup)
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
    SetShowSelf(class'UTComp_Settings'.default.bShowSelfInTeamOverlay);
    SetBStats(class'UTComp_Scoreboard'.default.bDrawStats);
    if(class'UTComp_Settings'.default.bFirstRun)
    {
        class'UTComp_Settings'.default.bFirstRun=False;
        ConsoleCommand("Set Input f5 MyMenu");
        class'UTComp_Settings'.default.bFirstRun=False;
        if(!class'DeathMatch'.default.bForceDefaultCharacter)
        {
           class'UTComp_Settings'.default.bRedTeammateModelsForced=False;
           class'UTComp_Settings'.default.bBlueEnemyModelsForced=False;
           class'UTComp_xPawn'.Static.StaticSaveConfig();
        }
        else
        {
            class'UTComp_Settings'.default.BlueEnemyModelName=class'xGame.xPawn'.default.PlacedCharacterName;
            class'UTComp_Settings'.default.RedTeammateModelName=class'xGame.xPawn'.default.PlacedCharacterName;
            class'UTComp_xPawn'.static.staticsaveconfig();
        }
        class'UTComp_Settings'.Static.StaticSaveConfig();
    }
    MatchHudColor();
    GetMapList();
}

simulated function InitializeScoreboard()
{
   local class<scoreboard> NewScoreboardclass;

   if(myHud!=None && myHUD.ScoreBoard.IsA('UTComp_ScoreBoard') && gamereplicationinfo!=None)
   {
       if(class'UTComp_Settings'.default.bUseDefaultScoreboard)
       {
           if(gamereplicationinfo.bTeamGame)
               NewScoreboardClass=class<Scoreboard>(DynamicLoadObject("UTCompv18.UTComp_ScoreBoardTDM", class'Class'));
           else
               NewScoreboardClass=class<Scoreboard>(DynamicLoadObject("UTCompv18.UTComp_ScoreBoardDM", class'Class'));
           ClientChangedScoreboard=True;
        }
   }
   else if(ClientChangedScoreBoard && !class'UTComp_Settings'.default.bUseDefaultScoreboard)
       NewScoreboardClass=class<Scoreboard>(DynamicLoadObject("UTCompv18.UTComp_ScoreBoard", class'Class'));
   if(myHUD!=None && NewScoreBoardClass!=None)
        myHUD.SetScoreBoardClass( NewScoreboardClass);
}

simulated function SetInitialColoredName()
{
    if(class'UTComp_Settings'.default.currentselectedcoloredname!=255 && class'UTComp_Settings'.default.currentselectedcoloredname<class'UTComp_Settings'.default.ColoredName.Length)
    {
        SetColoredNameOldStyleCustom(,class'UTComp_Settings'.default.currentselectedcoloredname);
    }
    else
        SetColoredNameOldStyle();
}


simulated function StartDemo()
{
    local string S;
    S=StripIllegalWindowsCharacters(class'UTComp_Settings'.default.DemoRecordingmask);

    if (class'UTComp_Settings'.default.bEnableUTCompAutoDemorec && (level.NetMode!=NM_DedicatedServer))
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
        if (class'UTComp_Settings'.default.bEnableAutoScreenShot && screenshotstaken==0)
        {
            ConsoleCommand("shot "$StripIllegalWindowsCharacters(class'UTComp_Settings'.default.ScreenShotMask));
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
        if(class'UTComp_Settings'.default.bCPMAStyleHitsounds && (DamageType == class'DamTypeFlakChunk' || DamageType == class'DamTypeFlakShell') && (RepInfo==None || RepInfo.EnableHitSoundsMode==2 || LineOfSightTo(Injured)))
        {
            GroupDamageSound(DamageType, Damage, true);
        }
        else if(RepInfo==None || RepInfo.EnableHitSoundsMode==2 || LineOfSightTo(Injured) || IsHitScan(DamageType))
            PlayEnemyHitSound(Damage);
    }
    else
    {
        RegisterTeammateHit(DamageType, Damage);
        if(class'UTComp_Settings'.default.bCPMAStyleHitsounds && (DamageType == class'DamTypeFlakChunk' || DamageType == class'DamTypeFlakShell') && (RepInfo==None || RepInfo.EnableHitSoundsMode==2 || LineOfSightTo(Injured)))
        {
            GroupDamageSound(DamageType, Damage, false);
        }
        else if(RepInfo==None || RepInfo.EnableHitSoundsMode==2 || LineOfSightTo(Injured) || IsHitScan(DamageType))
            PlayTeammateHitSound(Damage);
    }
}

simulated function bool IsHitScan(class<DamageType> DamageType)
{
    if(
       DamageType == Class'XWeapons.DamTypeSuperShockBeam'
    || DamageType == Class'XWeapons.DamTypeLinkShaft'
    || DamageType == Class'XWeapons.DamTypeSuperShockBeam'
    || DamageType == Class'XWeapons.DamTypeSniperShot'
    || DamageType == Class'XWeapons.DamTypeMinigunBullet'
    || DamageType == Class'XWeapons.DamTypeShockBeam'
    || DamageType == Class'XWeapons.DamTypeAssaultBullet'
    || DamageType == Class'XWeapons.DamTypeShieldImpact'
    || DamageType == Class'XWeapons.DamTypeMinigunAlt'
    || DamageType == Class'DamTypeSniperHeadShot'
    || DamageType == Class'DamTypeClassicHeadshot'
    || DamageType == Class'DamTypeClassicSniper'
    )
        return true;
    return false;
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
    if(bEnemy)
        PlayEnemyHitSound(Damage);
    else
        PlayTeammateHitSound(Damage);
    DelayedDamageTotal=0;
}

// only hitsound, LOS check done i9n gamerules
simulated function ReceiveHitSound(int Damage, byte iTeam)
{
    if(Level.NetMode==NM_DedicatedServer)
        return;
    if(bBehindView)
        return;
    if(iTeam==1)
        PlayEnemyHitSound(Damage);
    else if(iTeam==2)
        PlayTeammateHitSound(Damage);
}

simulated function RegisterSelfHit(class<DamageType> DamageType, int Damage)
{
}

simulated function RegisterEnemyHit(class<DamageType> DamageType, int Damage)
{
    local int i, j, k;
    if(DamageType==None)
        return;

    DamG+=Damage;
    for(i=0; i<=14; i++)
    {
        if(DamageType==WepStatDamTypesPrim[i])
        {
            NormalWepStatsPrim[i].Hits +=1;
            NormalWepStatsPrim[i].Damage+=Damage;
            return;
        }
        else if(DamageType==WepStatDamTypesAlt[i])
        {
            NormalWepStatsAlt[i].Hits +=1;
            NormalWepStatsAlt[i].Damage+=Damage;
            return;
        }
        //Hack DamageTypes(more than 1, currently only sniper)
        else if(DamageType==class'DamTypeSniperHeadShot' || DamageType==class'DamTypeClassicHeadshot' || DamageType==class'DamTypeClassicSniper')
        {
            NormalWepStatsPrim[5].Hits +=1;
            NormalWepStatsPrim[5].Damage+=Damage;

            if(DamageType!=class'DamTypeClassicSniper')
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
                    if(( CustomWepTypes[j].DamType[k]!="" && InstrNonCaseSensitive(string(DamageType), CustomWepTypes[j].DamType[k])) && CustomWepTypes[j].WepName~=CustomWepStats[i].WepName)
                    {
                        CustomWepStats[i].Hits+=1;
                        CustomWepStats[i].Damage+=Damage;
                        return;
                    }
                }
            }
        }
        if(DamageType==CustomWepStats[i].DamageType)
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
           if(( CustomWepTypes[j].DamType[k]!="" && InstrNonCaseSensitive(string(DamageType), CustomWepTypes[j].DamType[k])))
               CustomWepStats[i-1].WepName=CustomWepTypes[j].WepName;
    }
    CustomWepStats[i-1].DamageType=DamageType;
    CustomWepStats[i-1].Damage=Damage;
    CustomWepStats[i-1].Hits=1;
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

simulated function RegisterTeammateHit(class<DamageType> DamageType, int Damage)
{
}

simulated function PlayEnemyHitSound(int Damage)
{
    local float HitSoundPitch;
    if(!class'UTComp_Settings'.default.bEnableHitSounds || LastHitSoundTime>Level.TimeSeconds)
        return;
    LastHitSoundTime=Level.TimeSeconds+HITSOUNDTWEENTIME;
    HitSoundPitch=1.0;
    if(class'UTComp_Settings'.default.bCPMAStyleHitSounds)
        HitSoundPitch=class'UTComp_Settings'.default.CPMAPitchModifier*30.0/Damage;
    if(LoadedEnemySound == none)
        LoadedEnemySound = Sound(DynamicLoadObject(class'UTComp_Settings'.default.EnemySound, class'Sound', True));

    if(ViewTarget!=None)
        ViewTarget.PlaySound(LoadedEnemySound,,class'UTComp_Settings'.default.HitSoundVolume,,,HitSoundPitch);
}

simulated function PlayTeammateHitSound(int Damage)
{
    local float HitSoundPitch;

    if(!class'UTComp_Settings'.default.bEnableHitSounds || LastHitSoundTime>Level.TimeSeconds)
        return;
    LastHitSoundTime=Level.TimeSeconds+HITSOUNDTWEENTIME;
    HitSoundPitch=1.0;
    if(class'UTComp_Settings'.default.bCPMAStyleHitSounds)
        HitSoundPitch=class'UTComp_Settings'.default.CPMAPitchModifier*30.0/Damage;

    if(LoadedFriendlySound == none)
        LoadedFriendlySound = Sound(DynamicLoadObject(class'UTComp_Settings'.default.FriendlySound, class'Sound', True));

    if(ViewTarget!=None)
        ViewTarget.PlaySound(LoadedFriendlySound,,class'UTComp_Settings'.default.HitSoundVolume,,,HitSoundPitch);
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
/*
exec function SpecViewGoal()
{
    if(IsCoaching())
       return;
    Super.SpecViewGoal();
}     */

function ServerSpecViewGoal()
{
    local actor NewGoal;

    if(!IsCoaching())
       super.ServerSpecViewGoal();

    if ( PlayerReplicationInfo.bOnlySpectator && IsInState('Spectating') )
    {
        NewGoal = Level.Game.FindSpecGoalFor(PlayerReplicationInfo,0);
        if (NewGoal!=None)
        {
            if(Pawn(NewGoal)!=None && ((Pawn(NewGoal).GetTeamNum() == 1 && IsCoachingBlue()) || (Pawn(NewGoal).GetTeamNum() == 0 && IsCoachingRed())))
            {
                SetViewTarget(NewGoal);
                ClientSetViewTarget(NewGoal);
                bBehindView = true; //bChaseCam;
            }
        }
    }
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
    if(IsCoaching())
       return;
    ServerFindNextNode();
}

exec function PrevNode()
{
   if(IsCoaching())
       return;
   ServerFindPrevNode();
}

exec function Node(int k)
{
  if(IsCoaching())
       return;
  ServerGotoNode(k+1);
}

exec function Core(int k)
{
  if(IsCoaching())
     return;
  k=Max(k, 1);
  k=Min(k, 2);
  ServergotoNode(k-1);
}

exec function bool NextRedPlayer()
{
   if(IsCoaching() && !IsCoachingRed())
       return false;
   return(ServerNextPlayer(0));
}

exec function bool NextBluePlayer()
{
   if(IsCoaching() && !IsCoachingBlue())
       return false;

   return(ServerNextPlayer(1));
}

exec function GoToPlayer(int k)
{
   if(IsCoaching())
       return ;
   ServerGoToPlayer(k-1);
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
            if(IsCoaching())
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

exec function GoToItem(string PickupString)
{
  if(IsCoaching())
     return;
  if(PickupString ~= "50" || PickupString ~="Small"
  || PickupString ~="50a")
     ServerGoToWepBase(class'XPickups.ShieldPack');
  else if(PickupString ~="100" || PickupString ~="100a"
  || PickupString ~="Large" || PickupString ~="Big")
     ServerGoToWepBase(class'XPickups.SuperShieldPack');
  else if(PickupString ~="DD" || PickupString ~="Amp"
  || PickupString ~="Double-Damage" || PickupString ~="DoubleDamage")
     ServerGoToWepBase(class'XPickups.UDamagePack');
}

function ServerGoToWepBase(class<Pickup> theClass)
{
   local xPickupBase xPBase;
   foreach allactors(class'xPickupBase', xPBase)
   {
     if(xPBase.PowerUp == theClass)
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
   class'UTComp_Settings'.default.SavedSpectateSpeed=F;
  // SavedSpectateSpeed=F;
   SetSpectateSpeed(F);
   class'UTComp_Settings'.static.staticSaveConfig();
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

    if(!PlayerReplicationInfo.bOnlySpectator)
    {
       ClientMessage("Sorry, only spectators can spec lock");
       return;
    }
    if(IsCoaching())
    {
       ClientMessage("Sorry, you may only lock to a team once per game. ");
       return;
    }
    if(NextRedPlayer())
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

    if(!PlayerReplicationInfo.bOnlySpectator)
    {
       ClientMessage("Sorry, only spectators can spec lock");
       return;
    }
    if(IsCoaching())
    {
       ClientMessage("Sorry, you may only lock to a team once per game. ");
       return;
    }
    if(NextBluePlayer())
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
    function BeginState()
    {
        Super.BeginState();
        SetTimer(1.0, True);
    }
      exec function Fire( optional float F )
    {
        if ( bFrozen )
    {
        if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
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
         if(IsCoachingRed())
            if(xPawn(ViewTarget).PlayerReplicationInfo != None && xPAwn(ViewTarget).PlayerReplicationInfo.Team.TeamIndex!= 0)
                 NextRedPlayer();

         else if (IsCoachingBlue())
            if(xPawn(ViewTarget).PlayerReplicationInfo != None && xPawn(ViewTarget).PlayerReplicationInfo.Team.TeamIndex!= 1)
                NextBluePlayer();
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
     //   Log("An Error occured, this is an invalid vote.");
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
    for(i=0; i<NormalWepStatsPrim.Length; i++)
    {
        NormalWepStatsPrim[i].Damage=0;
        NormalWepStatsPrim[i].Hits=0;
        NormalWepStatsPrim[i].Percent=0;
    }
    for(i=0; i<NormalWepStatsalt.Length; i++)
    {
        NormalWepStatsalt[i].Damage=0;
        NormalWepStatsalt[i].Hits=0;
        NormalWepStatsalt[i].Percent=0;
    }
    CustomWepStats.Length=0;
    DamG=0;
}

simulated function ResetEpicStats()
{
    local TeamPlayerReplicationInfo tPRI;
    local int i;
    if(playerReplicationInfo !=None && Teamplayerreplicationinfo(playerreplicationinfo)!=None)
    {
        tPRI=Teamplayerreplicationinfo(playerreplicationinfo);
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
   class'UTComp_Settings'.default.CurrentSelectedColoredName=255;
 //  CurrentSelectedColoredName=255;
   class'UTComp_Settings'.static.staticSaveConfig();staticsaveconfig();
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

    if(S2=="")
    {
       S2=PlayerReplicationInfo.PlayerName;
    }
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& class'UTComp_Settings'.default.ColorName[k-1] == class'UTComp_Settings'.default.ColorName[m] ;m++)
        {
             numdoatonce++;
             k++;
        }
        S=S$class'UTComp_Util'.Static.MakeColorCode(class'UTComp_Settings'.default.ColorName[k-1])$Right(Left(S2, k), numdoatonce);
    }
    if(UTCompPRI!=None)
        UTCompPRI.SetColoredName(S);
}

simulated function string FindColoredName(int CustomColors)
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
       S2=class'UTComp_Settings'.default.ColoredName[CustomColors].SavedName;
    }
    SetNameNoReset(S2);
 //   Log(default.ColoredName[CustomColors].SavedName);
 //   Log(default.ColoredName[CustomColors].SavedColor[0].R@default.ColoredName[CustomColors].SavedColor[0].G@default.ColoredName[CustomColors].SavedColor[0].B);
    for(k=0; k<20; k++)
       class'UTComp_Settings'.default.ColorName[k]=class'UTComp_Settings'.default.ColoredName[CustomColors].SavedColor[k];
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& class'UTComp_Settings'.default.ColoredName[CustomColors].SavedColor[k-1] == class'UTComp_Settings'.default.ColoredName[CustomColors].SavedColor[m] ;m++)
        {
             numdoatonce++;
             k++;
        }
        S=S$class'UTComp_Util'.Static.MakeColorCode(class'UTComp_Settings'.default.ColoredName[CustomColors].SavedColor[k-1])$Right(Left(S2, k), numdoatonce);
    }
    return S;
}

simulated function SaveNewColoredName()
{
 //   local int i;
    local int n;
    local int l;

    n=class'UTComp_Settings'.default.ColoredName.Length+1;
    class'UTComp_Settings'.default.ColoredName.Length=n;

 //   Log(default.ColoredName.Length);

    class'UTComp_Settings'.default.ColoredName[n-1].SavedName=PlayerReplicationInfo.PlayerName;

    for(l=0; l<20; l++)
         class'UTComp_Settings'.default.ColoredName[n-1].SavedColor[l]=class'UTComp_Settings'.default.ColorName[l];

   /* ColoredName.Length=class'UTComp_Settings'.default.ColoredName.Length;
    for(i=0; i<class'UTComp_Settings'.default.ColoredName.Length; i++)
        ColoredName[i]=class'UTComp_Settings'.default.ColoredName[i];
    for(i=0; i<ArrayCount(ColorName); i++)
        ColorName[i]=class'UTComp_Settings'.default.ColorName[i];
    */
}

exec function ShowColoredNames()
{
    local int i, j;
    local string S;
    for(i=0; i<class'UTComp_Settings'.default.ColoredName.Length; i++)
    {
        Log(class'UTComp_Settings'.default.ColoredName[i].SavedName);
        for(j=0; j<20; j++)
            S=S$class'UTComp_Settings'.default.ColoredName[i].SavedColor[j].R@class'UTComp_Settings'.default.ColoredName[i].SavedColor[j].G@class'UTComp_Settings'.default.ColoredName[i].SavedColor[j].B;
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
       S2=class'UTComp_Settings'.default.ColoredName[CustomColors].SavedName;
    }
    SetNameNoReset(S2);
  //  Log(default.ColoredName[CustomColors].SavedName);
 //   Log(default.ColoredName[CustomColors].SavedColor[0].R@default.ColoredName[CustomColors].SavedColor[0].G@default.ColoredName[CustomColors].SavedColor[0].B);
    for(k=0; k<20; k++)
        class'UTComp_Settings'.default.ColorName[k]=class'UTComp_Settings'.default.ColoredName[CustomColors].SavedColor[k];
    for(k=1; k<=Len(S2); k++)
    {
        numdoatonce=1;
        for(m=k;m<Len(S2)&& class'UTComp_Settings'.default.ColoredName[CustomColors].SavedColor[k-1] == class'UTComp_Settings'.default.ColoredName[CustomColors].SavedColor[m] ;m++)
        {
             numdoatonce++;
             k++;
        }
        S=S$class'UTComp_Util'.Static.MakeColorCode(class'UTComp_Settings'.default.ColoredName[CustomColors].SavedColor[k-1])$Right(Left(S2, k), numdoatonce);
    }
    if(UTCompPRI!=None)
        UTCompPRI.SetColoredName(S);
}

exec function ListColoredNames()
{
   local int i;
   for(i=0; i<class'UTComp_Settings'.default.ColoredName.Length; i++)
       echo(class'UTComp_Settings'.default.coloredname[i].SavedName);
}

simulated function SetShowSelf(Bool b)
{
   // bShowSelfInTeamOverlay=b;
    class'UTComp_Settings'.default.bShowSelfInTeamOverlay=b;
    class'UTComp_Settings'.static.staticSaveConfig();staticsaveconfig();
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
    if(class'UTComp_Settings'.default.bAllowColoredMessages)
    {
       for(k=7; k>=0; k--)
       {
          S=Repl(S, "^"$k, ColorReplace(k));
       }
       S=Repl(S, "^r", RandomColor());
    }
    else
    {
       for(k=7; k>=0; k--)
       {
          S=Repl(S, "^"$k, "");
       }
       S=Repl(S, "^r", "");
    }
    if ( myHUD != None )
    {   if (class'UTComp_Settings'.default.bEnableColoredNamesInTalk)
           Message( PRI, c$S, Type );
        else myHud.Message( PRI, c$S, Type );
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

static function int GetBit(int theInt, int bitNum)
{
    return ((theInt & 1<<bitNum));
}

static function bool GetBitBool(int theInt, int bitNum)
{
   return ((theInt & 1<<bitNum)!=0);
}

simulated function MatchHudColor()
{
    local HudCDeathMatch DMHud;
    if(myHud==None || HudCDeathMatch(myHud)==None)
        return;
    DMHud=HudCDeathMatch(myHud);
    if(!class'UTComp_HudSettings'.default.bMatchHudColor)
    {
        DMHud.HudColorRed=class'HudCDeathMatch'.default.HudColorRed;
        DMHud.HudColorBlue=class'HudCDeathMatch'.default.HudColorBlue;
        return;
    }

    if(!class'UTComp_Settings'.default.bEnemyBasedSkins)
    {
        if(class'UTComp_Settings'.default.ClientSkinModeRedTeammate == 3)
        {
            DMHud.HudColorRed=class'UTComp_Settings'.default.RedTeammateUTCompSkinColor;
        }
        else if(class'UTComp_Settings'.default.ClientSkinModeRedTeammate == 2
            || class'UTComp_Settings'.default.ClientSkinModeRedTeammate == 1)
        {
            DMHud.HudColorRed=class'UTComp_xPawn'.default.BrightSkinColors[class'UTComp_Settings'.default.PreferredSkinColorRedTeammate];
        }

        if(class'UTComp_Settings'.default.ClientSkinModeBlueEnemy == 3)
        {
            DMHud.HudColorBlue=class'UTComp_Settings'.default.BlueEnemyUTCompSkinColor;
        }
        else if(class'UTComp_Settings'.default.ClientSkinModeBlueEnemy == 2
            || class'UTComp_Settings'.default.ClientSkinModeBlueEnemy == 1)
        {
            DMHud.HudColorBlue=class'UTComp_xPawn'.default.BrightSkinColors[class'UTComp_Settings'.default.PreferredSkinColorBlueEnemy];
        }
    }
    else
    {
        if(class'UTComp_Settings'.default.ClientSkinModeRedTeammate == 3)
        {
            DMHud.HudColorBlue=class'UTComp_Settings'.default.RedTeammateUTCompSkinColor;
            DMHud.HudColorRed=class'UTComp_Settings'.default.RedTeammateUTCompSkinColor;
        }
        else if(class'UTComp_Settings'.default.ClientSkinModeRedTeammate == 2
            || class'UTComp_Settings'.default.ClientSkinModeRedTeammate == 1)
        {
            DMHud.HudColorBlue=class'UTComp_xPawn'.default.BrightSkinColors[class'UTComp_Settings'.default.PreferredSkinColorRedTeammate];
            DMHud.HudColorRed=class'UTComp_xPawn'.default.BrightSkinColors[class'UTComp_Settings'.default.PreferredSkinColorRedTeammate];
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
}
 /*
exec function UseNewRotation()
{
    bUseNewRotation = !bUseNewRotation;
    default.bUseNewRotation = bUseNewRotation;
    ClientMessage("using rotation:"@bUseNewRotation);
    ClientMessage("using deltatime:"@bUseDeltaTime);
}

exec function UseDelta()
{
    bUseDeltaTime = !bUseDeltaTime;
    default.bUseDeltaTime = bUseDeltaTime;
    ClientMessage("using rotation:"@bUseNewRotation);
    ClientMessage("using deltatime:"@bUseDeltaTime);
}  */

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
simulated static function bool UseNewNet()
{
    return class'UTComp_Settings'.default.bEnableEnhancedNetCode;
}

/* replace calls fro old weapons if newnet is on */
exec function GetWeapon(class<Weapon> NewWeaponClass )
{
    if(NewWeaponClass == class'AssaultRifle')
        super.GetWeapon(class'NewNet_AssaultRifle');
    else if(NewWeaponClass == class'BioRifle')
        super.GetWeapon(class'NewNet_BioRifle');
    else if(NewWeaponClass == class'ClassicSniperRifle')
        super.GetWeapon(class'NewNet_ClassicSniperRifle');
    else if(NewWeaponClass == class'FlakCannon')
        super.GetWeapon(class'NewNet_FlakCannon');
    else if(NewWeaponClass == class'LinkGun')
        super.GetWeapon(class'NewNet_LinkGun');
    else if(NewWeaponClass == class'MiniGun')
        super.GetWeapon(class'NewNet_MiniGun');
    else if(NewWeaponClass == class'ONSAvril')
        super.GetWeapon(class'NewNet_ONSAvril');
    else if(NewWeaponClass == class'ONSGrenadeLauncher')
        super.GetWeapon(class'NewNet_ONSGrenadeLauncher');
    else if(NewWeaponClass == class'ONSMineLayer')
        super.GetWeapon(class'NewNet_ONSMineLayer');
    else if(NewWeaponClass == class'RocketLauncher')
        super.GetWeapon(class'NewNet_RocketLauncher');
    else if(NewWeaponClass == class'ShockRifle')
        super.GetWeapon(class'NewNet_ShockRifle');
    else if(NewWeaponClass == class'SniperRifle')
        super.GetWeapon(class'NewNet_SniperRifle');

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
    if(class'UTComp_Settings'.default.bDisableSpeed && ComboClass == class'xGame.ComboSpeed')
        return true;
    if(class'UTComp_Settings'.default.bDisableBooster && ComboClass == class'xGame.ComboDefensive')
        return true;
    if(class'UTComp_Settings'.default.bDisableInvis && ComboClass == class'xGame.ComboInvis')
        return true;
    if(class'UTComp_Settings'.default.bDisableBerserk && ComboClass == class'xGame.ComboBerserk')
        return true;

    return false;
}

exec function ShowWeaponName() {
    Player.Console.Message(Pawn.Weapon.ItemName, 10);
}


defaultproperties
{

     UTCompMenuClass="UTCompv18.UTComp_Menu_OpenedMenu"
     UTCompVotingMenuClass="UTCompv18.UTComp_Menu_VoteInProgress"
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
}
