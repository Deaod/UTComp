

class UTComp_Vote_Started extends CriticalEventPlus;

#exec AUDIO IMPORT FILE=Sounds\error2.wav	GROUP=Sounds

var Sound error2;

static simulated function ClientReceive (PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
	P.PlayAnnouncement(Default.error2,1,True);
}

defaultproperties
{
     error2=Sound'Sounds.error2'
}
