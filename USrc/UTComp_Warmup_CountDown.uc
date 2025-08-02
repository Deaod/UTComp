

class UTComp_Warmup_CountDown extends CriticalEventPlus;

var name CountDown[10];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return string(Switch);
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if(Switch>0 && switch<9)
        P.QueueAnnouncement( default.CountDown[Switch-1], 1, AP_InstantOrQueueSwitch, 1 );
    super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     CountDown(0)="one"
     CountDown(1)="two"
     CountDown(2)="three"
     CountDown(3)="four"
     CountDown(4)="five"
     CountDown(5)="six"
     CountDown(6)="seven"
     CountDown(7)="eight"
     CountDown(8)="nine"
     CountDown(9)="ten"
}
