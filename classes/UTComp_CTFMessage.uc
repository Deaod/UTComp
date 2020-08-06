class UTComp_CTFMessage extends CTFMessage;

#exec AUDIO IMPORT FILE=Sounds\CoverSpreeSound.wav	GROUP=Sounds

// 0 = Cover
// 1 = Seal base
// 4 = Ultra Cover
// 5 = Cover Spree
// 7 = Saved by

// 0 + 64 = You got Cover
// 1 + 64 = You got Seal base
// 4 + 64 = You got Ultra Cover
// 5 + 64 = You got Cover Spree
// 7 + 64 = You got Saved by

var(Message) localized string CoveredMsg, YouCoveredMsg;
var(Message) localized string CoverSpreeMsg, YouCoverSpreeMsg;
var(Message) localized string UltraCoverMsg, YouUltraCoverMsg;
var(Message) localized string SealMsg, YouSealMsg;
var(Message) localized string SavedMsg, YouSavedMsg;

var(Action) Sound CoverSpreeSound;

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == None)
		return;

	switch (Switch)
	{
		case 5: // Cover spree - guitarsound for player, spreesound for all
			//Log("Cover spree!");
			if (RelatedPRI_1 == P.PlayerReplicationInfo)
			{
				//Log("Cover spree! sound");
				P.PlayAnnouncement(default.CoverSpreeSound, 1, True);
			}
			else
			{
				//Log("Cover spree! beep");
				P.PlayBeepSound();
			}
			break;
	}

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == None)
		return "";

	switch (Switch)
  	{
		case 0: // Cover FC
			return RelatedPRI_1.PlayerName @ default.CoveredMsg;
		case 1: // Seal base
			return RelatedPRI_1.PlayerName @ default.SealMsg;
		case 4: // Ultra cover
			return RelatedPRI_1.PlayerName @ default.UltraCoverMsg;
		case 5: // Cover spree
			return RelatedPRI_1.PlayerName @ default.CoverSpreeMsg;
		case 7: // Saved by ...
			return default.SavedMsg @ RelatedPRI_1.PlayerName $ "!";

		case 0 + 64:
			return default.YouCoveredMsg;
		case 1 + 64:
			return default.YouSealMsg;
		case 4 + 64:
			return default.YouUltraCoverMsg;
		case 5 + 64:
			return default.YouCoverSpreeMsg;
		case 7 + 64:
			return default.YouSavedMsg;
  	}
	return "";
}


defaultproperties
{
	//defaults
	CoverSpreeSound=Sound'Sounds.CoverSpreeSound'

	CoveredMsg="covered the flagcarrier!"
	YouCoveredMsg="You covered the flagcarrier!"
	CoverSpreeMsg="is on a cover spree!"
	YouCoverSpreeMsg="You are on a cover spree!"
	UltraCoverMsg="got a multi cover!"
	YouUltraCoverMsg="You got a multi cover!"
	SealMsg="is sealing off the base!"
	YouSealMsg="You are sealing off the base!"
	SavedMsg="Saved By"
	YouSavedMsg="Close save!!"

	DrawColor=(R=24,G=192,B=24)
}