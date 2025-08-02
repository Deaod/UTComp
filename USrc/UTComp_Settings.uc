//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UTComp_Settings extends Object
    Config(UTComp)
    PerObjectConfig;

#exec AUDIO IMPORT FILE=Sounds\HitSound.wav     GROUP=Sounds
#exec AUDIO IMPORT FILE=Sounds\HitSoundFriendly.wav    GROUP=Sounds

var config bool bFirstRun;
var config bool bStats;
var config bool bEnableUTCompAutoDemorec;
var config string DemoRecordingMask;
var config bool bEnableAutoScreenshot;
var config string ScreenShotMask;
var config string FriendlySound;
var config string EnemySound;
var config bool bEnableHitSounds;
var config float HitSoundVolume;
var config bool bCPMAStyleHitsounds;
var config float CPMAPitchModifier;
var config float SavedSpectateSpeed;
var config bool bUseDefaultScoreBoard;
var config bool bShowSelfInTeamOverlay;
var config bool bEnableEnhancedNetCode;
var config bool bEnableColoredNamesOnEnemies;
var config bool ballowcoloredmessages;
var config bool bEnableColoredNamesInTalk;
var config array<byte> DontDrawInStats;


var config int CurrentSelectedColoredName;
var config color ColorName[20];

var config bool bDisableSpeed;
var config bool bDisableBooster;
var config bool bDisableInvis;
var config bool bDisableberserk;

struct ColoredNamePair
{
    var color SavedColor[20];
    var string SavedName;
};

var config array<ColoredNamePair> ColoredName;



struct ClanSkinTripple
{
    var string PlayerName;
    var color PlayerColor;
    var string ModelName;
};

var config string FallbackCharacterName;
var config bool bEnemyBasedSkins;
var config byte ClientSkinModeRedTeammate;
var config byte ClientSkinModeBlueEnemy;
var config byte PreferredSkinColorRedTeammate;
var config byte PreferredSkinColorBlueEnemy;
var config color BlueEnemyUTCompSkinColor;
var config color RedTeammateUTCompSkinColor;
var config bool bBlueEnemyModelsForced;
var config bool bRedTeammateModelsForced;
var config string BlueEnemyModelName;
var config string RedTeammateModelName;
var config bool bEnableDarkSkinning;
var config array<ClanSkinTripple> ClanSkins;
var config array<string> DisallowedEnemyNames;
var config bool bEnemyBasedModels;
var config bool bUseNewEyeHeightAlgorithm;
var config float DesiredNetUpdateRate;

function CheckSettings() {
    local string PackageName;

    PackageName = string(self.Class);
    PackageName = Left(PackageName, InStr(PackageName, "."));

    if (Left(FriendlySound, 6) ~= "UTComp")
        FriendlySound = PackageName$Mid(FriendlySound, InStr(FriendlySound, "."));
    if (Left(EnemySound, 6) ~= "UTComp")
        EnemySound = PackageName$Mid(EnemySound, InStr(EnemySound, "."));

    SaveConfig();
}

defaultproperties
{
    bFirstRun=True
    bStats=True
    DemoRecordingMask="%d-(%t)-%m-%p"
    ScreenShotMask="%d-(%t)-%m-%p"
    FriendlySound="UTCompv18c.Sounds.HitSoundFriendly"
    EnemySound="UTCompv18c.Sounds.HitSound"
    bEnableHitSounds=true
    HitSoundVolume=1.0
    bCPMAStyleHitsounds=true
    CPMAPitchModifier=1.40
    SavedSpectateSpeed=800.00
    bShowSelfInTeamOverlay=True
    bEnableEnhancedNetCode=True
    ballowcoloredmessages=True
    bEnableColoredNamesInTalk=True
    CurrentSelectedColoredName=255
    ColorName(0)=(R=255,G=255,B=255,A=255)
    ColorName(1)=(R=255,G=255,B=255,A=255)
    ColorName(2)=(R=255,G=255,B=255,A=255)
    ColorName(3)=(R=255,G=255,B=255,A=255)
    ColorName(4)=(R=255,G=255,B=255,A=255)
    ColorName(5)=(R=255,G=255,B=255,A=255)
    ColorName(6)=(R=255,G=255,B=255,A=255)
    ColorName(7)=(R=255,G=255,B=255,A=255)
    ColorName(8)=(R=255,G=255,B=255,A=255)
    ColorName(9)=(R=255,G=255,B=255,A=255)
    ColorName(10)=(R=255,G=255,B=255,A=255)
    ColorName(11)=(R=255,G=255,B=255,A=255)
    ColorName(12)=(R=255,G=255,B=255,A=255)
    ColorName(13)=(R=255,G=255,B=255,A=255)
    ColorName(14)=(R=255,G=255,B=255,A=255)
    ColorName(15)=(R=255,G=255,B=255,A=255)
    ColorName(16)=(R=255,G=255,B=255,A=255)
    ColorName(17)=(R=255,G=255,B=255,A=255)
    ColorName(18)=(R=255,G=255,B=255,A=255)
    ColorName(19)=(R=255,G=255,B=255,A=255)
    FallbackCharacterName="Arclite"
    ClientSkinModeRedTeammate=1
    ClientSkinModeBlueEnemy=1
    BlueEnemyUTCompSkinColor=(R=0,G=0,B=128,A=255)
    RedTeammateUTCompSkinColor=(R=128,G=0,B=0,A=255)
    BlueEnemyModelName="Arclite"
    RedTeammateModelName="Arclite"
    bEnableDarkSkinning=True
    DesiredNetUpdateRate=90
}
