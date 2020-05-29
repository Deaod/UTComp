

class UTComp_Menu_Miscellaneous extends UTComp_Menu_MainMenu;

var automated GUILabel l_ScoreboardTitle;
var automated GUILabel l_InfoTitle;
var automated GUILabel l_GenericTitle;
var automated GUILabel l_CrossScale;
var automated GUILabel l_NewNet;


var automated moCheckBox ch_UseScoreBoard;
var automated moCheckBox ch_WepStats;
var automated moCheckBox ch_PickupStats;
var automated moCheckBox ch_InfoBox;
var automated moCheckBox ch_FootSteps;
var automated moCheckBox ch_MatchHudColor;
var automated moCheckBox ch_UseEyeHeightAlgo;
var automated moCheckBox ch_UseNewNet;

var automated moComboBox co_CrosshairScale;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController,MyOwner);

    ch_InfoBox.Checked(class'UTComp_Overlay'.default.DesiredOnJoinMessageTime!=0.0);
    ch_UseScoreboard.Checked(!class'UTComp_Settings'.default.bUseDefaultScoreboard);
    ch_WepStats.Checked(class'UTComp_Scoreboard'.default.bDrawStats);
    ch_PickupStats.Checked(class'UTComp_Scoreboard'.default.bDrawPickups);
    ch_FootSteps.Checked(class'UTComp_xPawn'.default.bPlayOwnFootSteps);
    ch_MatchHudColor.Checked(class'UTComp_HudSettings'.default.bMatchHudColor);
    ch_UseEyeHeightAlgo.Checked(class'UTComp_Settings'.default.bUseNewEyeHeightAlgorithm);
    ch_UseNewNet.Checked(class'UTComp_Settings'.default.bEnableEnhancedNetCode);
}

function InternalOnChange( GUIComponent C )
{
    switch(C)
    {
        case ch_InfoBox:  if(ch_InfoBox.IsChecked())
                              class'UTComp_Overlay'.default.DesiredOnJoinMessageTime=6.0;
                          else
                              class'UTComp_Overlay'.default.DesiredOnJoinMessageTime=0;  break;
        case ch_UseScoreboard: class'UTComp_Settings'.default.bUseDefaultScoreboard=!ch_UseScoreBoard.IsChecked(); break;
        case ch_WepStats:  class'UTComp_Scoreboard'.default.bDrawStats=ch_WepStats.IsChecked();
                           BS_xPlayer(PlayerOwner()).SetBStats(class'UTComp_Scoreboard'.default.bDrawStats);break;
        case ch_PickupStats:  class'UTComp_Scoreboard'.default.bDrawPickups=ch_PickupStats.IsChecked(); break;
        case ch_FootSteps: class'UTComp_xPawn'.default.bPlayOwnFootSteps=ch_FootSteps.IsChecked(); break;
        case ch_MatchHudColor:  class'UTComp_HudSettings'.default.bMatchHudColor=ch_MatchHudColor.IsChecked(); break;
        case ch_UseEyeHeightAlgo: class'UTComp_Settings'.default.bUseNewEyeHeightAlgorithm=ch_UseEyeHeightAlgo.IsChecked(); break;
        case ch_UseNewNet:  class'UTComp_Settings'.default.bEnableEnhancedNetCode=ch_UseNewNet.IsChecked();
                            BS_xPlayer(PlayerOwner()).TurnOffNetCode(); break;
    }
    class'UTComp_Overlay'.static.StaticSaveConfig();
    class'BS_xPlayer'.static.StaticSaveConfig();
    class'UTComp_Settings'.static.staticSaveConfig();
    class'UTComp_Scoreboard'.static.StaticSaveConfig();
    class'UTComp_xPawn'.static.StaticSaveConfig();
    class'UTComp_HudCDeathMatch'.Static.StaticSaveConfig();
    class'UTComp_HudSettings'.static.StaticSaveConfig();
    BS_xPlayer(PlayerOwner()).MakeSureSaveConfig();
    BS_xPlayer(PlayerOwner()).MatchHudColor();

}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (Key == 0x1B)
        return false;
    return true;
}

defaultproperties
{

     Begin Object Class=GUILabel Name=ScoreboardLabel
         Caption="----------Scoreboard----------"
         TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.250000
		WinTop=0.290000
     End Object
     l_ScoreboardTitle=GUILabel'ScoreboardLabel'

     Begin Object Class=moCheckBox Name=ScoreboardCheck
         Caption="Use UTComp enhanced scoreboard."
         OnCreateComponent=ScoreboardCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.330000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_UseScoreBoard=moCheckBox'UTCompv18.UTComp_Menu_Miscellaneous.ScoreboardCheck'

     Begin Object Class=moCheckBox Name=StatsCheck
         Caption="Show weapon stats on scoreboard."
         OnCreateComponent=StatsCheck.InternalOnCreateComponent
         WinLeft=0.250000
         WinTop=0.370000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_WepStats=moCheckBox'UTCompv18.UTComp_Menu_Miscellaneous.StatsCheck'

     Begin Object Class=moCheckBox Name=PickupCheck
         Caption="Show pickup stats on scoreboard."
         OnCreateComponent=PickupCheck.InternalOnCreateComponent
         WinLeft=0.250000
         WinTop=0.410000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_PickupStats=moCheckBox'UTCompv18.UTComp_Menu_Miscellaneous.PickupCheck'

     Begin Object Class=GUILabel Name=InfoLabel
         Caption="--------Information Box--------"
         TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.250000
		WinTop=0.450000
     End Object
     l_InfoTitle=GUILabel'UTCompv18.UTComp_Menu_Miscellaneous.InfoLabel'

     Begin Object Class=moCheckBox Name=InfoCheck
         Caption="Show UTComp info box on connect."
         OnCreateComponent=InfoCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.490000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_InfoBox=moCheckBox'UTCompv18.UTComp_Menu_Miscellaneous.InfoCheck'

     Begin Object Class=GUILabel Name=GenericLabel
         Caption="----Generic UT2004 Settings----"
         TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.250000
		WinTop=0.530000
     End Object
     l_GenericTitle=GUILabel'UTCompv18.UTComp_Menu_Miscellaneous.GenericLabel'

     Begin Object Class=moCheckBox Name=FootCheck
         Caption="Play own footstep sounds."
         OnCreateComponent=FootCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.570000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_FootSteps=moCheckBox'UTCompv18.UTComp_Menu_Miscellaneous.FootCheck'

     Begin Object Class=moCheckBox Name=HudColorCheck
         Caption="Match Hud Color To Skins"
         OnCreateComponent=HudColorCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.610000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_MatchHudColor=moCheckBox'UTCompv18.UTComp_Menu_Miscellaneous.HudColorCheck'

     Begin Object Class=moCheckBox Name=UseEyeHeightAlgoCheck
         Caption="Use New EyeHeight Algorithm"
         OnCreateComponent=HudColorCheck.InternalOnCreateComponent
         WinWidth=0.500000
         WinHeight=0.030000
         WinLeft=0.250000
         WinTop=0.650000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_UseEyeHeightAlgo=moCheckBox'UTCompv18.UTComp_Menu_Miscellaneous.UseEyeHeightAlgoCheck'

     Begin Object Class=GUILabel Name=NewNetLabel
     Caption="-----------Net Code-----------"
         TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.250000
		WinTop=0.690000
     End Object
     l_NewNet=GUILabel'NewNetLabel'

     Begin Object Class=moCheckBox Name=NewNetCheck
         Caption="Enable Enhanced Netcode"
         OnCreateComponent=NewNetCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.730000
         OnChange=UTComp_Menu_Miscellaneous.InternalOnChange
     End Object
     ch_UseNewNet=moCheckBox'UTCompv18.UTComp_Menu_Miscellaneous.NewNetCheck'

}
