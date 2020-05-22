

class UTComp_WarmupEndMessage extends CriticalEventPlus;

var sound prepare;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return "Warmup has Ended!";
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	P.PlayAnnouncement(default.prepare,1, true);
}

defaultproperties
{
     prepare=Sound'AnnouncerClassic.prepare'
}
