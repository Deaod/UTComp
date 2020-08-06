

class UTComp_PRI extends LinkedReplicationInfo;

var int PickedUpFifty;
var int PickedUpHundred;
var int PickedUpAmp;
var int PickedUpVial;
var int PickedUpHealth;
var int PickedUpKeg;
var int PickedUpAdren;

var int NormalWepStatsAlt[15];
var int NormalWepStatsPrim[15];

var int NormalWepStatsAltHit[15];
var int NormalWepStatsPrimHit[15];

var int NormalWepStatsAltPercent[15];
var int NormalWepStatsPrimPercent[15];

var int NormalWepStatsAltDamage[15];
var int NormalWepStatsPrimDamage[15];

var string ColoredName;
var int RealKills;
var bool bIsReady;
var byte CoachTeam;
var byte Vote;
var byte VoteSwitch;
var byte VoteSwitch2;
var byte VotedYes, VotedNo;
var bool bShowSelf;
var string VoteOptions;
var string VoteOptions2;

var bool bSendWepStats;

var int DamR;
var int DamG;

var byte CurrentVoteID;
var bool bWantsMapList;
var bool bReplied;
var int CurrentMapsSent;
var array<string> UTCompMapList;
var array<string> UTCompMapListClient; //necessary due to IA
var int TotalMapsToBeReceived;

var bool bIsLegitPlayer;
var int totaldamageg;

// CTF stats
var int FlagGrabs;
var int FlagCaps;
var int FlagPickups;
var int FlagKills;
var int FlagSaves; // Returned the flag at the last second
var int FlagDenials; // Killed the EFC at the last second
var int Assists;
var int Covers;
var int CoverSpree;
var int Seals;
var int SealSpree;
var int DefKills;



const iMAXPLAYERS = 8;

struct TeamOverlayInfo
{
    var byte Armor;
    var byte Weapon;
    var int Health;
    var PlayerReplicationInfo PRI;
};


var TeamOverlayInfo OverlayInfoRed[iMAXPLAYERS];
var TeamOverlayInfo OverlayInfoBlue[iMAXPLAYERS];


// Don't be stupid and try to move those in the TeamOverlayInfo. It breaks the replication
// Lost 3 hours to learn that lesson. I imagine lotus and co. learned that the hard way too, 
// but didn't care enough to point it out. &?/*()%
var byte bHasDDRed[iMAXPLAYERS];
var byte bHasDDBlue[iMAXPLAYERS];

struct PowerupInfoStruct
{
    var Pickup Pickup;
    var int Team;
    var float NextRespawnTime;
    var PlayerReplicationInfo LastTaker;
};

var PowerupInfoStruct PowerupInfo[8];


var bool bMapListCompleted;

var localized string WepStatNames[15];

var string HitPrim, HitAlt, FiredPrim, FiredAlt, DamagePrim, DamageAlt;

replication
{
    reliable if(Role==Role_Authority)
         bIsReady, CoachTeam, CurrentVoteID,
         ColoredName, RealKills,
         FlagGrabs, FlagCaps, FlagPickups, FlagKills, FlagSaves, FlagDenials,
         Assists, Covers, CoverSpree, Seals, SealSpree, DefKills;

    unreliable if(Role==Role_Authority && bNetOwner)
        PickedUpFifty, PickedUpHundred, PickedUpAmp,
        PickedUpVial, PickedUpHealth, PickedUpKeg,
        PickedUpAdren, DamR, VoteSwitch, VoteOptions,
        Vote, VoteOptions2, VoteSwitch2;

    unreliable if(Role==Role_Authority && bNetOwner && bSendWepStats)
        NormalWepStatsPrim, NormalWepStatsAlt;

    unreliable if(Role==Role_Authority && bNetOwner)
        OverlayInfoRed, OverlayInfoBlue, bHasDDRed, bHasDDBlue, VotedYes, VotedNo, PowerupInfo;

    reliable if(Role<Role_Authority)
        Ready, NotReady, SetVoteMode, SetCoachTeam,
        CallVote, PassVote, SetColoredName, SetShowSelf, GetMapList, ReplyToMapSend;
        
    reliable if(Role==Role_Authority && bNetOwner)
        MapListSend, SendTotalMapNumber;
}






simulated function UpdatePercentages()
{
    local int i;

    for(i=0; i<ArrayCount(NormalWepStatsPrim); i++)
    {
        if(NormalWepStatsPrim[i]>0)
            NormalWepStatsPrimPercent[i]=float(NormalWepStatsPrimHit[i])/float(NormalWepStatsPrim[i])*100.0;
    }
    for(i=0; i<ArrayCount(NormalWepStatsPrim); i++)
        if(NormalWepStatsAlt[i]>0)
            NormalWepStatsAltPercent[i]=float(NormalWepStatsAltHit[i])/float(NormalWepStatsAlt[i])*100.0;
}

function CallVote(byte b, byte switch, string Options, optional string Caller, optional byte P2, optional string Options2)
{
    local UTComp_VotingHandler uVote;

    foreach DynamicActors(class'UTComp_VotingHandler', uVote)
    {
        if(uVote.StartVote(b,switch,Options, caller, p2, options2, false))
            Vote=1;
    }
}

function PassVote(byte b, byte switch, string Options, optional string Caller, optional byte P2, optional string Options2)
{
    local UTComp_VotingHandler uVote;

    foreach DynamicActors(class'UTComp_VotingHandler', uVote)
    {
        if(uVote.StartVote(b,switch,Options, caller, p2, options2, True))
            Vote=1;
    }
}

function NotReady()
{
    bIsReady=False;
}

function Ready()
{
    bIsReady=True;
}

function SetCoachTeam(byte b)
{
    CoachTeam=b;
}

function SetVoteMode(byte b)
{
    Vote=b;
}

function ClearStats()
{
    local int i;
    for(i=0; i<15; i++)
    {
        NormalWepStatsAlt[i]=0;
        NormalWepStatsPrim[i]=0;
        NormalWepStatsPrimHit[i]=0;
        NormalWepStatsAltHit[i]=0;
        NormalWepStatsPrimDamage[i]=0;
        NormalWepStatsAltDamage[i]=0;
    }
    DamR=0;
    DamG=0;
    PickedUpFifty=0;
    PickedUpHundred=0;
    PickedUpAmp=0;
    PickedUpVial=0;
    PickedUpHealth=0;
    PickedUpKeg=0;
    PickedUpAdren=0;
    RealKills=0;
    TotalDamageG=0;
}

function SetColoredName(string S)
{
    ColoredName=S;
}

function SetShowSelf(bool b)
{
    bShowSelf=b;
}

function string MakeSafeName(string S)
{
    local int i;
    local bool NotSafeYet;

    while(Len(S)>0 && NotSafeYet)
    {
        NotSafeYet=False;
        for(i=1; i<4; i++)
        {
            if(Mid(S, Len(S)-i)==chr(0x1B))
            {
                S=Left(S,Len(S)-i);
                NotSafeYet=True;
                break;
            }
        }
    }
    return S;
}

event Tick(float DeltaTime)
{
    if(bWantsMapList && bReplied)
    {
        bReplied=False;
        ServerSendMapList();
    }

    super.Tick(DeltaTime);
}

function ReplyToMapSend()
{
    bReplied=True;
}

function GetMapList()
{
    if(bMapListCompleted)
       return;
    bWantsMapList=True;
    ServerSendMapList();
    SendTotalMapNumber(UTCompMapList.Length);
}

function SendTotalMapNumber(int i)
{
    TotalMapsToBeReceived=i;
}

simulated function MapListSend(string S)
{
    if(Level.NetMode==NM_DedicatedServer)
        return;
    if(!(Left(S, 4) ~="Tut-" || Left(S, 4) ~="Mov-"))
        UTCompMapListClient[UTCompMapListClient.Length]=S;
    ReplyToMapSend();
}

function ServerSendMapList()
{
    if(CurrentMapsSent==0)
    {
        Level.Game.LoadMapList("", UTCompMapList);
    }
    if(UTCompMapList.Length==0)
        bWantsMapList=False;
    if(CurrentMapsSent<UTCompMapList.Length)
    {
        MapListSend(UTCompMapList[CurrentMapsSent]);
        CurrentMapsSent+=1;
    }
    else
    {
        bWantsMapList=False;
        bMapListCompleted=True;
    }
}

defaultproperties
{
     CoachTeam=255
     Vote=255
     VoteSwitch=255
     bSendWepStats=True
     CurrentVoteID=255

