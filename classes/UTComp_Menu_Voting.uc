

class UTComp_Menu_Voting extends UTComp_Menu_MainMenu;

var automated GUIButton bu_GameTypeMenu, bu_MapChangeMenu, bu_UTComp_SettingsMenu;

var automated GUILabel l_VotingLabel;

function bool InternalOnClick(GUIComponent C)
{
    switch(C)
    {
        case bu_GameTypeMenu:  PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_Voting_GameType')); break;
        case bu_MapChangeMenu:  PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_Voting_Map'));  break;
        case bu_UTComp_SettingsMenu:  PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_Voting_Settings'));    break;
    }
    Blehz();
    return super.InternalOnClick(C);
}

event Opened(guicomponent sender)
{
    Super.Opened(sender);

   Blehz();
}

function Blehz()
{
        local UTComp_ServerReplicationInfo RepInfo;

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
         break;
    if((RepInfo.bEnableMapVoting==false && RepInfo.bAllowRestartVoteEvenIfMapVotingIsTurnedOff == false) || RepInfo.bEnableVoting==false)
        bu_MapChangeMenu.DisableMe();
    else
        bu_MapChangeMenu.EnableMe();
    if(RepInfo.bEnableVoting==False)
        bu_UTComp_SettingsMenu.DisableMe();
    else
        bu_UTComp_SettingsMenu.EnableMe();
    if(RepInfo.bEnableMapVoting==False || RepInfo.bEnableVoting==False || RepInfo.bEnableGameTypeVoting==False)
        bu_GameTypeMenu.DisableMe();
    else
        bu_GameTypeMenu.EnableMe();
}

defaultproperties
{
     Begin Object Class=GUIButton Name=GameTypeButton
         Caption="Gametype"
		WinWidth=0.180000
		WinHeight=0.123437
		WinLeft=0.312500
		WinTop=0.572916
         OnClick=UTComp_Menu_Voting.InternalOnClick
         OnKeyEvent=GameTypeButton.InternalOnKeyEvent
     End Object
     bu_GameTypeMenu=GUIButton'UTComp_Menu_Voting.GameTypeButton'

     Begin Object Class=GUIButton Name=MapChangeButton
         Caption="Change Map"
		WinWidth=0.373751
		WinHeight=0.123437
		WinLeft=0.315625
		WinTop=0.449999
         OnClick=UTComp_Menu_Voting.InternalOnClick
         OnKeyEvent=MapChangeButton.InternalOnKeyEvent
     End Object
     bu_MapChangeMenu=GUIButton'UTComp_Menu_Voting.MapChangeButton'

     Begin Object Class=GUIButton Name=UTComp_SettingsButton
         Caption="Settings"
		WinWidth=0.180000
		WinHeight=0.123437
		WinLeft=0.512501
		WinTop=0.572916
         OnClick=UTComp_Menu_Voting.InternalOnClick
         OnKeyEvent=UTComp_SettingsButton.InternalOnKeyEvent
     End Object
     bu_UTComp_SettingsMenu=GUIButton'UTComp_Menu_Voting.UTComp_SettingsButton'

     Begin Object class=GUILabel Name=DemnoHeadingLabel
        Caption="------- Select your voting type -------"
        TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.281250
		WinTop=0.385000
     End Object
     l_VotingLabel=GUILabel'DemnoHeadingLabel'

}
