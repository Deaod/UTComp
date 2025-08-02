
class UTComp_Menu_MainMenu extends PopupPageBase;

var automated array<GUIButton> UTCompMenuButtons;
var automated GUITabControl c_Main;
var automated FloatingImage i_FrameBG2;
var UTComp_Settings Settings;
var UTComp_HUDSettings HUDSettings;

simulated function SaveSettings()
{
    Log("Saving settings");
    Settings.SaveConfig();
}

simulated function SaveHUDSettings()
{
    Log("Saving HUD settings");
    HUDSettings.SaveConfig();
}

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	super.InitComponent(MyController, MyComponent);
    Settings = BS_xPlayer(PlayerOwner()).Settings;
    HUDSettings = BS_xPlayer(PlayerOwner()).HUDSettings;
}

function bool InternalOnClick(GUIComponent C)
{
    if(C==UTCompMenuButtons[0])
        PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_BrightSkins'));

    else if(C==UTCompMenuButtons[1])
        PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_ColorNames'));

    else if(C==UTCompMenuButtons[2])
        PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_TeamOverlay'));

    else if(C==UTCompMenuButtons[3])
        PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_Crosshairs'));

    else if(C==UTCompMenuButtons[4])
        PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_Hitsounds'));

    else if(C==UTCompMenuButtons[5])
        PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_Voting'));

    else if(C==UTCompMenuButtons[6])
        PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_AutoDemoSS'));

    else if(C==UTCompMenuButtons[7])
        PlayerOwner().ClientReplaceMenu(string(class'UTComp_Menu_Miscellaneous'));

    return false;
}

function OnClose(optional bool bCancelled)
{
   if(PlayerOwner().IsA('BS_xPlayer'))
   {
      BS_xPlayer(PlayerOwner()).ReSkinAll();
      BS_xPlayer(PlayerOwner()).InitializeScoreboard();
      BS_xPlayer(PlayerOwner()).MatchHudColor();
   }
   super.OnClose(bCancelled);
}

defaultproperties
{
     Begin Object class=GUIButton name=SkinModelButton
         Caption="Skins/Models"
         WinTop=0.150000
         WinLeft=0.11250000
         WinWidth=0.180000
         WinHeight=0.060000
         OnClick=InternalOnClick
     End Object
     UTCompMenuButtons(0)=GUIButton'SkinModelButton'

     Begin Object class=GUIButton name=ColoredNameButton
         Caption="Colored Names"
         WinTop=0.150000
         WinLeft=0.31250000
         WinWidth=0.180000
         WinHeight=0.060000
         OnClick=InternalOnClick
     End Object
     UTCompMenuButtons(1)=GUIButton'ColoredNameButton'

     Begin Object class=GUIButton name=OverlayButton
         Caption="Team Overlay"
         WinTop=0.150000
         WinLeft=0.51250000
         WinWidth=0.180000
         WinHeight=0.060000
         OnClick=InternalOnClick
     End Object
     UTCompMenuButtons(2)=GUIButton'OverlayButton'

     Begin Object class=GUIButton name=CrosshairButton
         Caption="Crosshairs"
         WinTop=0.150000
         WinLeft=0.71250000
         WinWidth=0.180000
         WinHeight=0.060000
         OnClick=InternalOnClick
     End Object
     UTCompMenuButtons(3)=GUIButton'CrosshairButton'

     Begin Object class=GUIButton name=HitsoundButton
         Caption="Hitsounds"
         WinTop=0.220000
         WinLeft=0.11250000
         WinWidth=0.180000
         WinHeight=0.060000
         OnClick=InternalOnClick
     End Object
     UTCompMenuButtons(4)=GUIButton'HitsoundButton'

     Begin Object class=GUIButton name=VotingButton
         Caption="Voting"
         WinTop=0.220000
         WinLeft=0.31250000
         WinWidth=0.180000
         WinHeight=0.060000
         OnClick=InternalOnClick
     End Object
     UTCompMenuButtons(5)=GUIButton'VotingButton'

     Begin Object class=GUIButton name=AutoDemoButton
         Caption="Auto Demo/SS"
         WinTop=0.220000
         WinLeft=0.51250000
         WinWidth=0.180000
         WinHeight=0.060000
         OnClick=InternalOnClick
     End Object
     UTCompMenuButtons(6)=GUIButton'AutoDemoButton'

     Begin Object class=GUIButton name=MiscButton
         Caption="Misc"
         WinTop=0.220000
         WinLeft=0.71250000
         WinWidth=0.180000
         WinHeight=0.060000
         OnClick=InternalOnClick
     End Object
     UTCompMenuButtons(7)=GUIButton'MiscButton'

     Begin Object Class=GUITabControl Name=LoginMenuTC
         bFillSpace=True
         bDockPanels=True
         TabHeight=0.08
         BackgroundStyleName=""
		 WinWidth=0.725325
		 WinHeight=0.208177
		 WinLeft=0.134782
	     WinTop=0.072718
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=LoginMenuTC.InternalOnActivate
     End Object
     c_Main=GUITabControl'UTComp_Menu_MainMenu.LoginMenuTC'


     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'2K4Menus.NewControls.Display99'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.100000
         WinLeft=0.0750000
         WinWidth=0.850000
         WinHeight=0.750000
         bBoundToParent=False
         bScaleToParent=False
         RenderWeight = 0.01
         DropShadowX=0
         DropShadowY=0
     End Object
     i_FrameBG=FloatingImage'UTComp_Menu_MainMenu.FloatingFrameBackground'

     Begin Object Class=FloatingImage Name=FloatingFrameBackground2
         Image=Texture'2K4Menus.NewControls.Display95'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.270000
         WinLeft=0.0750000
         WinWidth=0.850000
         WinHeight=0.580000
         bBoundToParent=False
         bScaleToParent=False
         RenderWeight = 0.02
         DropShadowX=0
         DropShadowY=0
     End Object
     i_FrameBG2=FloatingImage'UTComp_Menu_MainMenu.FloatingFrameBackground2'


  /*   bResizeWidthAllowed=False
     bResizeHeightAllowed=False
     bMoveAllowed=False      */
     bRequire640x480=True
     bAllowedAsLast=True
     WinWidth=1.000000
	 WinHeight=0.804690
	 WinLeft=0.000000
	 WinTop=0.114990
	 bPersistent=true

}
