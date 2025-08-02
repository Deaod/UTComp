

class UTComp_xBot extends xBot;

function SetPawnClass(string inClass, string inCharacter)
{
    local class<UTComp_xPawn> pClass;

    if ( inClass != "" )
	{
		pClass = class<UTComp_xPawn>(DynamicLoadObject(inClass, class'Class'));
		if (pClass != None)
			PawnClass = pClass;
	}
    PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
    PlayerReplicationInfo.SetCharacterName(inCharacter);
}


defaultproperties
{
}
