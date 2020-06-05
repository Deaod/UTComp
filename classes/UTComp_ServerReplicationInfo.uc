

class UTComp_ServerReplicationInfo extends ReplicationInfo;

var bool bEnableVoting;
var byte EnableBrightSkinsMode;
var bool bEnableClanSkins;
var bool bEnableTeamOverlay;
var bool bEnableExtraHudClock;
var byte EnableHitSoundsMode;
var bool bEnableScoreboard;
var bool bEnableWarmup;
var bool bEnableWeaponStats;
var bool bEnablePowerupStats;
var bool benableDoubleDamage;
var bool bEnableTimedOvertimeVoting;


var bool bEnableBrightskinsVoting;
var bool bEnableHitsoundsVoting;
var bool bEnableWarmupVoting;
var bool bEnableTeamOverlayVoting;
var bool bEnableMapVoting;
var bool bEnableGametypeVoting;
var bool bEnableDoubleDamageVoting;
var byte ServerMaxPlayers;
var byte MaxPlayersClone;
var bool bEnableAdvancedVotingOptions;

var string VotingNames[15];
var string VotingOptions[15];
var bool bEnableTimedOvertime;

var PlayerReplicationInfo LinePRI[10];
var bool bEnableEnhancedNetCode;
var bool bEnableEnhancedNetCodeVoting;
var bool bForward;
var bool bEnableForwardVoting;

var bool bShieldFix;
var bool bAllowRestartVoteEvenIfMapVotingIsTurnedOff;


replication
{
    reliable if(Role==Role_Authority)
        bEnableVoting, EnableBrightSkinsMode, EnableHitSoundsMode,
        bEnableClanSkins, bEnableTeamOverlay,
        bEnableWarmup, bEnableBrightskinsVoting,
        bEnableHitsoundsVoting, bEnableTeamOverlayVoting,
        bEnableMapVoting, bEnableGametypeVoting, VotingNames,
        benableDoubleDamage, ServerMaxPlayers, bEnableTimedOvertime,
        MaxPlayersClone, bEnableAdvancedVotingOptions, VotingOptions, LinePRI, bEnableTimedOvertimeVoting,
        bEnableEnhancedNetCodeVoting,bEnableEnhancedNetCode, bEnableWarmupVoting, bForward, bEnableForwardVoting,
        bAllowRestartVoteEvenIfMapVotingIsTurnedOff;
}

defaultproperties
{
     bEnableVoting=True
     EnableBrightSkinsMode=3
     bEnableClanSkins=True
     bEnableTeamOverlay=True
     EnableHitSoundsMode=1
     bEnableScoreboard=True
     bEnableWarmup=True
     bEnableWeaponStats=True
     bEnablePowerupStats=True
     bEnableBrightskinsVoting=True
     bEnableHitsoundsVoting=True
     bEnableWarmupVoting=True
     bEnableTeamOverlayVoting=True
     bEnableMapVoting=True
     bEnableGametypeVoting=True
     bEnableDoubleDamageVoting=True
     ServerMaxPlayers=10
     bEnableTimedOvertimeVoting=True
     bEnableTimedOvertime=False
}

