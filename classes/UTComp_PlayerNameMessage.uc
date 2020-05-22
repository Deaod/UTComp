

//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UTComp_PlayerNameMessage extends PlayerNameMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local utcomp_pri upri;
    if(class'UTComp_Settings'.default.bEnableColoredNamesOnEnemies)
    {
        uPRI = class'UTComp_Util'.static.GetUTCompPRI(RelatedPRI_1);
        if(uPRI!=None && uPRI.ColoredName != "")
            return uPRI.ColoredName;
    }
    return RelatedPRI_1.PlayerName;
}


DefaultProperties
{

}
