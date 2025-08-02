
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RoundMessage extends CriticalEventPlus;

var() localized string RoundWord;
var() localized string OfWord;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local int i;
    i=switch>>10;
    return default.RoundWord@(i)@default.ofword@(switch-(i<<10));
}

DefaultProperties
{
     RoundWord = "Round"
     OfWord = "Of"
     DrawColor=(B=0,G=255,R=255)
     StackMode=SM_Down
     PosY=0.850000
     FontSize=0
     bIsConsoleMessage=False
}
