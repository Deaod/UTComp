

//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UTComp_PlayerNameMessage extends PlayerNameMessage;

var UTComp_Settings Settings;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local UTComp_PRI uPRI;

    if (default.Settings == none)
        foreach RelatedPRI_1.AllObjects(class'UTComp_Settings', default.Settings)
            break;

    if(default.Settings != none && default.Settings.bEnableColoredNamesOnEnemies)
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
