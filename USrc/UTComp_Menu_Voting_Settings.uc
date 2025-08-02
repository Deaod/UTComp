

class UTComp_Menu_Voting_Settings extends UTComp_Menu_MainMenu;

var automated GUIComboBox co_Skins, co_Hitsounds, co_TeamOverlay;
var automated GUIComboBox co_Warmup,  co_NewNet, co_forward;

var automated GUIButton bu_Skins, bu_Hitsounds, bu_TeamOverlay;
var automated GUIButton bu_Warmup,  bu_newNet, bu_forward;

var automated GUILabel l_Skins, l_HitSounds, l_TeamOverlay, l_Warmup;
var automated GUILabel l_Restart, l_NoRestart, l_NewNet, l_forward;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(myController,MyOwner);

    co_Skins.AddItem("Epic Style");
    co_Skins.AddItem("Brighter Epic Style");
    co_Skins.AddItem("UTComp Style");

    co_HitSounds.AddItem("Disabled");
    co_HitSounds.AddItem("Line-Of-Sight");
    co_HitSounds.AddItem("Everywhere");

    co_TeamOverlay.AddItem("Disabled");
    co_TeamOverlay.AddItem("Enabled");

    co_Warmup.AddItem("Disabled");
    co_Warmup.AddItem("Enabled");


    co_newnet.AddItem("Disabled");
    co_newnet.AddItem("Enabled");

    co_forward.additem("Disabled");
    co_forward.additem("Enabled");

    co_Skins.REadOnly(True);
    co_HitSounds.ReadOnly(True);
    co_TeamOverlay.ReadOnly(True);
    co_Warmup.ReadOnly(True);
    co_newnet.ReadOnly(True);
    co_forward.ReadOnly(True);
    Blehz();
  //  co_Amp.bVisible=False;
}

function bool InternalOnClick( GUIComponent Sender )
{

    switch (Sender)
    {
        case bu_Skins:   BS_xPlayer(PlayerOwner()).CallVote(1, co_Skins.GetIndex(), "");  PlayerOwner().ClientCloseMenu();  break;
        case bu_hitsounds:   BS_xPlayer(PlayerOwner()).CallVote(2, co_Hitsounds.GetIndex(), "");   PlayerOwner().ClientCloseMenu(); break;
        case bu_TeamOverlay:  BS_xPlayer(PlayerOwner()).CallVote(3, co_TeamOverlay.GetIndex(), "");  PlayerOwner().ClientCloseMenu();  break;
        case bu_Warmup:  BS_xPlayer(PlayerOwner()).CallVote(4, co_Warmup.GetIndex(), ""); PlayerOwner().ClientCloseMenu(); break;
        case bu_NewNet:  BS_xPlayer(PlayerOwner()).CallVote(9, co_NewNet.GetIndex(), ""); PlayerOwner().ClientCloseMenu(); break;
        case bu_forward:  BS_xPlayer(PlayerOwner()).CallVote(10, co_Forward.GetIndex(), ""); PlayerOwner().ClientCloseMenu(); break;
    }
    return super.InternalOnClick(Sender);
}



function Blehz()
{
    local UTComp_ServerReplicationInfo RepInfo;

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    if(RepInfo!=None && (!RepInfo.bEnableVoting || !RepInfo.bEnableBrightskinsVoting))
        co_Skins.DisableMe();
    else
        co_Skins.EnableMe();
    if(RepInfo!=None && (!RepInfo.bEnableVoting || !RepInfo.bEnableHitsoundsVoting))
        co_Hitsounds.DisableMe();
    else
        co_HitSounds.EnableMe();
    if(RepInfo!=None && (!RepInfo.bEnableVoting || !RepInfo.bEnableTeamOverlayVoting))
        co_TeamOverlay.DisableMe();
    else
        co_TeamOverlay.EnableMe();
    if(RepInfo!=None && (!RepInfo.bEnableVoting || !RepInfo.bEnableWarmupVoting))
        co_Warmup.DisableMe();
    else
        co_Warmup.EnableMe();
    if(RepInfo!=None && (!RepInfo.bEnableVoting || !RepInfo.bEnableEnhancedNetCodeVoting))
        co_NewNet.DisableMe();
    else
        co_NewNet.EnableMe();
    if(RepInfo!=None && (!RepInfo.bEnableVoting) || !RepInfo.bEnableForwardVoting)
        co_Forward.DisableMe();
    else
        co_Forward.EnableMe();

    if(RepInfo!=None)
    {
        co_Skins.SetIndex(RepInfo.EnableBrightSkinsMode-1);
        co_HitSounds.SetIndex(RepInfo.EnableHitSoundsMode);
        if(RepInfo.bEnableTeamOverlay)
            co_TeamOverlay.SetIndex(1);
        if(RepInfo.bEnableWarmup)
            co_Warmup.SetIndex(1);
        if(RepInfo.bEnableEnhancedNetCode)
            co_NewNet.SetIndex(1);
        if(RepInfo.bForward)
            co_Forward.SetIndex(1);
    }
}

event Opened(GUIComponent Sender)
{
     super.Opened(Sender);
     Blehz();
}

defaultproperties
{
     Begin Object Class=GUIComboBox Name=SkinsComboBox
         WinTop=0.400000
         WinLeft=0.382187
         WinWidth=0.250000
         WinHeight=0.030000
         OnKeyEvent=SkinsComboBox.InternalOnKeyEvent
     End Object
     co_Skins=GUIComboBox'UTComp_Menu_Voting_Settings.SkinsComboBox'

     Begin Object Class=GUIComboBox Name=HitsoundsComboBox
         WinTop=0.450000
         WinLeft=0.382187
         WinWidth=0.250000
         WinHeight=0.030000
         OnKeyEvent=HitsoundsComboBox.InternalOnKeyEvent
     End Object
     co_Hitsounds=GUIComboBox'UTComp_Menu_Voting_Settings.HitsoundsComboBox'

     Begin Object Class=GUIComboBox Name=TeamOverlayComboBox
         WinTop=0.500000
         WinLeft=0.382187
         WinWidth=0.250000
         WinHeight=0.030000
         OnKeyEvent=TeamOverlayComboBox.InternalOnKeyEvent
     End Object
     co_TeamOverlay=GUIComboBox'UTComp_Menu_Voting_Settings.TeamOverlayComboBox'

     Begin Object Class=GUIComboBox Name=WarmupComboBox
		WinWidth=0.250000
		WinHeight=0.035000
		WinLeft=0.382187
		WinTop=0.622918
         OnKeyEvent=WarmupComboBox.InternalOnKeyEvent
     End Object
     co_Warmup=GUIComboBox'UTComp_Menu_Voting_Settings.WarmupComboBox'

     Begin Object Class=GUIComboBox Name=NewNetComboBox
		WinWidth=0.250000
		WinHeight=0.035000
		WinLeft=0.382187
		WinTop=0.672918
         OnKeyEvent=NewNetComboBox.InternalOnKeyEvent
     End Object
     co_NewNet=GUIComboBox'UTComp_Menu_Voting_Settings.NewNetComboBox'

     Begin Object Class=GUIComboBox Name=ForwardComboBox
		WinWidth=0.250000
		WinHeight=0.035000
		WinLeft=0.382187
		WinTop=0.722918
         OnKeyEvent=NewNetComboBox.InternalOnKeyEvent
     End Object
     co_Forward=GUIComboBox'UTComp_Menu_Voting_Settings.ForwardComboBox'

     Begin Object Class=GUIButton Name=SkinsButton
         Caption="Call Vote"
         WinTop=0.395000
         WinLeft=0.665625
         WinWidth=0.117500
         WinHeight=0.042500
         OnClick=UTComp_Menu_Voting_Settings.InternalOnClick
         OnKeyEvent=SkinsButton.InternalOnKeyEvent
     End Object
     bu_Skins=GUIButton'UTComp_Menu_Voting_Settings.SkinsButton'

     Begin Object Class=GUIButton Name=HitsoundsButton
         Caption="Call Vote"
         WinTop=0.445000
         WinLeft=0.665625
         WinWidth=0.117500
         WinHeight=0.042500
         OnClick=UTComp_Menu_Voting_Settings.InternalOnClick
         OnKeyEvent=HitsoundsButton.InternalOnKeyEvent
     End Object
     bu_Hitsounds=GUIButton'UTComp_Menu_Voting_Settings.HitsoundsButton'

     Begin Object Class=GUIButton Name=TeamOverlayButton
         Caption="Call Vote"
         WinTop=0.495000
         WinLeft=0.665625
         WinWidth=0.117500
         WinHeight=0.042500
         OnClick=UTComp_Menu_Voting_Settings.InternalOnClick
         OnKeyEvent=TeamOverlayButton.InternalOnKeyEvent
     End Object
     bu_TeamOverlay=GUIButton'UTComp_Menu_Voting_Settings.TeamOverlayButton'

     Begin Object Class=GUIButton Name=WarmupButton
         Caption="Call Vote"
		WinWidth=0.117500
		WinHeight=0.047500
		WinLeft=0.665625
		WinTop=0.615834
         OnClick=UTComp_Menu_Voting_Settings.InternalOnClick
         OnKeyEvent=WarmupButton.InternalOnKeyEvent
     End Object
     bu_Warmup=GUIButton'UTComp_Menu_Voting_Settings.WarmupButton'

     Begin Object Class=GUIButton Name=NewNetButton
         Caption="Call Vote"
		WinWidth=0.117500
		WinHeight=0.047500
		WinLeft=0.665625
		WinTop=0.665834
         OnClick=UTComp_Menu_Voting_Settings.InternalOnClick
         OnKeyEvent=NewNetButton.InternalOnKeyEvent
     End Object
     bu_NewNet=GUIButton'UTComp_Menu_Voting_Settings.NewNetButton'

     Begin Object Class=GUIButton Name=ForwardButton
         Caption="Call Vote"
		WinWidth=0.117500
		WinHeight=0.047500
		WinLeft=0.665625
		WinTop=0.715834
         OnClick=UTComp_Menu_Voting_Settings.InternalOnClick
         OnKeyEvent=NewNetButton.InternalOnKeyEvent
     End Object
     bu_Forward=GUIButton'UTComp_Menu_Voting_Settings.ForwardButton'

     Begin Object Class=GUILabel Name=SkinsLabel
         Caption="Skins"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.395000
         WinLeft=0.162000
     End Object
     l_Skins=GUILabel'UTComp_Menu_Voting_Settings.SkinsLabel'

     Begin Object Class=GUILabel Name=HitsoundsLabel
         Caption="Hitsounds"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.445000
         WinLeft=0.162000
     End Object
     l_HitSounds=GUILabel'UTComp_Menu_Voting_Settings.HitsoundsLabel'

     Begin Object Class=GUILabel Name=TeamOverlayLabel
         Caption="Team Overlay"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.162
		WinTop=0.495000
     End Object
     l_TeamOverlay=GUILabel'UTComp_Menu_Voting_Settings.TeamOverlayLabel'

     Begin Object Class=GUILabel Name=WarmupLabel
         Caption="Warmup"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.160125
		WinTop=0.611668
     End Object
     l_Warmup=GUILabel'UTComp_Menu_Voting_Settings.WarmupLabel'

      Begin Object Class=GUILabel Name=NewNetLabel
         Caption="Enhanced Netcode"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.160125
		WinTop=0.661667
     End Object
     l_NewNet=GUILabel'UTComp_Menu_Voting_Settings.newNetLabel'

     Begin Object Class=GUILabel Name=ForwardLabel
         Caption="Forward Mode"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.160125
		WinTop=0.711667
     End Object
     l_Forward=GUILabel'UTComp_Menu_Voting_Settings.ForwardLabel'

          Begin Object class=GUILabel Name=DemnoHeadingLabel
        Caption="--- These settings require a map reload to take effect ---"
        TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.176562
		WinTop=0.562085
     End Object
     l_Restart=GUILabel'DemnoHeadingLabel'

    Begin Object class=GUILabel Name=RestartLabel
        Caption="--- These settings are applied instantly after the vote passes ---"
        TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.118750
		WinTop=0.332917
     End Object
     l_NoRestart=GUILabel'RestartLabel'

}
