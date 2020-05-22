
class UTComp_Vote_Passed extends CriticalEventPlus;

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    if(Switch==1)
        return "Voting Has Passed, Please Restart the Map!";
    return "Voting Has Passed!";
}

defaultproperties
{
}
