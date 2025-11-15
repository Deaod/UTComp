

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
        PlayerReplicationInfo.Destroy();
        PlayerReplicationInfo = None;
    }

    super.Destroyed();
}

defaultproperties
{
}
