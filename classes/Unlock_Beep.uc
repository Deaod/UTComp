
class Unlock_Beep extends CriticalEventPlus;

var sound beep;

static function ClientReceive(
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

    P.PlayAnnouncement(Default.Beep,1,True);
}
DefaultProperties
{
    bIsConsoleMessage=False
    beep = sound'menusounds.select3'
}
