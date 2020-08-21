

class UTComp_Menu_TeamOverlay extends UTComp_Menu_MainMenu;

var automated moCheckBox ch_Enable, ch_ShowSelf, ch_Icons;

var automated GUISlider sl_redBG, sl_blueBG, sl_greenBG;
var automated GUISlider sl_redName, sl_blueName, sl_greenName;
var automated GUISlider sl_redLoc, sl_blueLoc, sl_greenLoc;

var automated GUILabel l_redBG, l_blueBG, l_greenBG;
var automated GUILabel l_redName, l_blueName, l_greenName;
var automated GUILabel l_redLoc, l_blueLoc, l_greenLoc;

var automated GUILabel l_BGColor, l_NameColor, l_LocColor;
var automated GUILabel l_Horiz, l_Vert, l_Size;

var automated GUISlider sl_Horiz, sl_Vert, sl_Size;

var interaction overl;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController,MyOwner);

    ch_Enable.Checked(class'UTComp_Overlay'.default.OverlayEnabled);
    ch_ShowSelf.Checked(Settings.bShowSelfInTeamOverlay);
    ch_Icons.Checked(class'UTComp_Overlay'.default.bDrawIcons);

    sl_redBG.SetValue(class'UTComp_Overlay'.default.BGColor.R);
    sl_greenBG.SetValue(class'UTComp_Overlay'.default.BGColor.G);
    sl_blueBG.SetValue(class'UTComp_Overlay'.default.BGColor.B);

    sl_redName.SetValue(class'UTComp_Overlay'.default.InfoTextColor.R);
    sl_greenName.SetValue(class'UTComp_Overlay'.default.InfoTextColor.G);
    sl_blueName.SetValue(class'UTComp_Overlay'.default.InfoTextColor.B);

    sl_redLoc.SetValue(class'UTComp_Overlay'.default.LocTextColor.R);
    sl_greenLoc.SetValue(class'UTComp_Overlay'.default.LocTextColor.G);
    sl_blueLoc.SetValue(class'UTComp_Overlay'.default.LocTextColor.B);

    sl_Horiz.SetValue(class'UTComp_Overlay'.default.HorizPosition);
    sl_Vert.SetValue(class'UTComp_Overlay'.default.VertPosition);
    sl_Size.SetValue(class'UTComp_Overlay'.default.theFontSize);

    FindCurrentOverlay();
    DisableStuff();
}

function DisableStuff()
{
    local UTComp_ServerReplicationInfo RepInfo;

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    if(ch_Enable.IsChecked() && (RepInfo==None || RepInfo.bEnableTeamOverlay))
    {
        sl_Horiz.EnableMe();
        sl_Vert.EnableMe();
        sl_Size.EnableMe();

        sl_RedLoc.EnableMe();
        sl_GreenLoc.EnableMe();
        sl_BlueLoc.EnableMe();

        sl_RedName.EnableMe();
        sl_GreenName.EnableMe();
        sl_BlueName.EnableMe();

        sl_RedBG.EnableMe();
        sl_GreenBG.EnableMe();
        sl_BlueBG.EnableMe();

        ch_ShowSelf.EnableMe();
        ch_Icons.EnableMe();
    }
    else
    {
        sl_Horiz.DisableMe();
        sl_Vert.DisableMe();
        sl_Size.DisableMe();

        sl_RedLoc.DisableMe();
        sl_GreenLoc.DisableMe();
        sl_BlueLoc.DisableMe();

        sl_RedName.DisableMe();
        sl_GreenName.DisableMe();
        sl_BlueName.DisableMe();

        sl_RedBG.DisableMe();
        sl_GreenBG.DisableMe();
        sl_BlueBG.DisableMe();

        ch_ShowSelf.DisableMe();
        ch_Icons.DisableMe();
    }
}

function FindCurrentOverlay()
{
  local int i;
  local PlayerController PC;
  local bool bFindInteraction;

  bFindInteraction = false;

  ForEach AllObjects(class'PlayerController',PC)
  {
    if ( Viewport(PC.Player) != None )
    {
      While (!bFindInteraction)
      {
        overl = PC.Player.LocalInteractions[i];
        if (overl == none)
          break;
        else
        if (overl.IsA('UTComp_Overlay'))
          bFindInteraction = true;
	i++;
      }
      if (!bFindInteraction)
	overl = None;
    }
  }
}

function UpdateOverlay()
{
  if(overl==None)
  {
    FindCurrentOverlay();
    return;
  }
  utcomp_Overlay(overl).vertPosition=Class'utcomp_Overlay'.default.VertPosition;
  utcomp_Overlay(overl).horizposition=Class'utcomp_Overlay'.default.HorizPosition;
  utcomp_Overlay(overl).BGColor=Class'utcomp_Overlay'.default.BGColor;
  utcomp_Overlay(overl).infotextcolor=Class'utcomp_Overlay'.default.infotextColor;
  utcomp_Overlay(overl).loctextcolor=Class'utcomp_Overlay'.default.loctextColor;
  utcomp_Overlay(overl).OverlayEnabled=Class'utcomp_Overlay'.default.overlayenabled;
  utcomp_Overlay(overl).bDrawIcons=Class'utcomp_Overlay'.default.bDrawIcons;
  utcomp_Overlay(overl).theFontSize=Class'utcomp_overlay'.default.theFontSize;
}

function InternalOnChange( GUIComponent C )
{
    switch(C)
    {
    case ch_Enable: class'UTComp_Overlay'.default.OverlayEnabled=ch_Enable.IsChecked(); break;
    case ch_ShowSelf: BS_xPlayer(PlayerOwner()).SetShowSelf(ch_ShowSelf.IsChecked()); break;
    case ch_Icons: class'UTComp_Overlay'.default.bDrawIcons=ch_Icons.IsChecked(); break;

    case sl_redBG: class'UTComp_Overlay'.default.BGColor.R=sl_redBG.Value; break;
    case sl_greenBG: class'UTComp_Overlay'.default.BGColor.G=sl_GreenBG.Value; break;
    case sl_blueBG: class'UTComp_Overlay'.default.BGColor.B=sl_BlueBG.Value; break;

    case sl_redName: class'UTComp_Overlay'.default.InfoTextColor.R=sl_RedName.Value; break;
    case sl_greenName: class'UTComp_Overlay'.default.InfoTextColor.G=sl_GreenName.Value; break;
    case sl_blueName: class'UTComp_Overlay'.default.InfoTextColor.B=sl_BlueName.Value;break;

    case sl_redLoc: class'UTComp_Overlay'.default.LocTextColor.R=sl_RedLoc.Value;break;
    case sl_greenLoc: class'UTComp_Overlay'.default.LocTextColor.G=sl_GreenLoc.Value; break;
    case sl_blueLoc: class'UTComp_Overlay'.default.LocTextColor.B=sl_BlueLoc.Value;break;

    case sl_Horiz: class'UTComp_Overlay'.default.HorizPosition=sl_Horiz.Value; break;
    case sl_Vert: class'UTComp_Overlay'.default.VertPosition=sl_Vert.Value;break;
    case sl_Size: class'UTComp_Overlay'.default.theFontSize=sl_Size.Value;break;
    }
    class'UTComp_Overlay'.Static.StaticSaveConfig();
    SaveSettings();
    class'BS_xPlayer'.Static.StaticSaveConfig();
    UpdateOverlay();
    DisableStuff();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (Key == 0x1B)
        return false;
    return true;
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=CheckEnable
         Caption="Enable Overlay"
         OnCreateComponent=CheckEnable.InternalOnCreateComponent
         WinTop=0.350000
         WinLeft=0.150000
         WinWidth=0.300000
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
     End Object
     ch_Enable=moCheckBox'UTComp_Menu_TeamOverlay.CheckEnable'

     Begin Object Class=moCheckBox Name=CheckShowSelf
         Caption="Show Self"
         OnCreateComponent=CheckShowSelf.InternalOnCreateComponent
         WinTop=0.400000
         WinLeft=0.150000
         WinWidth=0.300000
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
     End Object
     ch_ShowSelf=moCheckBox'UTComp_Menu_TeamOverlay.CheckShowSelf'

     Begin Object Class=moCheckBox Name=CheckIcons
         Caption="Enable Icons"
         OnCreateComponent=CheckIcons.InternalOnCreateComponent
         WinTop=0.450000
         WinLeft=0.150000
         WinWidth=0.300000
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
     End Object
     ch_Icons=moCheckBox'UTComp_Menu_TeamOverlay.CheckIcons'

     Begin Object Class=GUISlider Name=RedBGSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.515000
         WinLeft=0.200000
         WinWidth=0.300000
         OnClick=RedBGSlider.InternalOnClick
         OnMousePressed=RedBGSlider.InternalOnMousePressed
         OnMouseRelease=RedBGSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=RedBGSlider.InternalOnKeyEvent
         OnCapturedMouseMove=RedBGSlider.InternalCapturedMouseMove
     End Object
     sl_redBG=GUISlider'UTComp_Menu_TeamOverlay.RedBGSlider'

     Begin Object Class=GUISlider Name=BlueBGSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.595000
         WinLeft=0.200000
         WinWidth=0.300000
         OnClick=BlueBGSlider.InternalOnClick
         OnMousePressed=BlueBGSlider.InternalOnMousePressed
         OnMouseRelease=BlueBGSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=BlueBGSlider.InternalOnKeyEvent
         OnCapturedMouseMove=BlueBGSlider.InternalCapturedMouseMove
     End Object
     sl_blueBG=GUISlider'UTComp_Menu_TeamOverlay.BlueBGSlider'

     Begin Object Class=GUISlider Name=GreenBGSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.555000
         WinLeft=0.200000
         WinWidth=0.300000
         OnClick=GreenBGSlider.InternalOnClick
         OnMousePressed=GreenBGSlider.InternalOnMousePressed
         OnMouseRelease=GreenBGSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=GreenBGSlider.InternalOnKeyEvent
         OnCapturedMouseMove=GreenBGSlider.InternalCapturedMouseMove
     End Object
     sl_greenBG=GUISlider'UTComp_Menu_TeamOverlay.GreenBGSlider'

     Begin Object Class=GUISlider Name=RedNameSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.665000
         WinLeft=0.600000
         WinWidth=0.300000
         OnClick=RedNameSlider.InternalOnClick
         OnMousePressed=RedNameSlider.InternalOnMousePressed
         OnMouseRelease=RedNameSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=RedNameSlider.InternalOnKeyEvent
         OnCapturedMouseMove=RedNameSlider.InternalCapturedMouseMove
     End Object
     sl_redName=GUISlider'UTComp_Menu_TeamOverlay.RedNameSlider'

     Begin Object Class=GUISlider Name=BlueNameSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.745000
         WinLeft=0.600000
         WinWidth=0.300000
         OnClick=BlueNameSlider.InternalOnClick
         OnMousePressed=BlueNameSlider.InternalOnMousePressed
         OnMouseRelease=BlueNameSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=BlueNameSlider.InternalOnKeyEvent
         OnCapturedMouseMove=BlueNameSlider.InternalCapturedMouseMove
     End Object
     sl_blueName=GUISlider'UTComp_Menu_TeamOverlay.BlueNameSlider'

     Begin Object Class=GUISlider Name=GreenNameSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.705000
         WinLeft=0.600000
         WinWidth=0.300000
         OnClick=GreenNameSlider.InternalOnClick
         OnMousePressed=GreenNameSlider.InternalOnMousePressed
         OnMouseRelease=GreenNameSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=GreenNameSlider.InternalOnKeyEvent
         OnCapturedMouseMove=GreenNameSlider.InternalCapturedMouseMove
     End Object
     sl_greenName=GUISlider'UTComp_Menu_TeamOverlay.GreenNameSlider'

     Begin Object Class=GUISlider Name=RedLocSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.665000
         WinLeft=0.200000
         WinWidth=0.300000
         OnClick=RedLocSlider.InternalOnClick
         OnMousePressed=RedLocSlider.InternalOnMousePressed
         OnMouseRelease=RedLocSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=RedLocSlider.InternalOnKeyEvent
         OnCapturedMouseMove=RedLocSlider.InternalCapturedMouseMove
     End Object
     sl_redLoc=GUISlider'UTComp_Menu_TeamOverlay.RedLocSlider'

     Begin Object Class=GUISlider Name=BlueLocSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.745000
         WinLeft=0.200000
         WinWidth=0.300000
         OnClick=BlueLocSlider.InternalOnClick
         OnMousePressed=BlueLocSlider.InternalOnMousePressed
         OnMouseRelease=BlueLocSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=BlueLocSlider.InternalOnKeyEvent
         OnCapturedMouseMove=BlueLocSlider.InternalCapturedMouseMove
     End Object
     sl_blueLoc=GUISlider'UTComp_Menu_TeamOverlay.BlueLocSlider'

     Begin Object Class=GUISlider Name=GreenLocSlider
         MaxValue=255.000000
         bIntSlider=True
         WinTop=0.705000
         WinLeft=0.200000
         WinWidth=0.300000
         OnClick=GreenLocSlider.InternalOnClick
         OnMousePressed=GreenLocSlider.InternalOnMousePressed
         OnMouseRelease=GreenLocSlider.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=GreenLocSlider.InternalOnKeyEvent
         OnCapturedMouseMove=GreenLocSlider.InternalCapturedMouseMove
     End Object
     sl_greenLoc=GUISlider'UTComp_Menu_TeamOverlay.GreenLocSlider'

     Begin Object Class=GUILabel Name=RedBGLabel
         Caption="Red"
         TextColor=(R=255)
         WinTop=0.500000
         WinLeft=0.120000
     End Object
     l_redBG=GUILabel'UTComp_Menu_TeamOverlay.RedBGLabel'

     Begin Object Class=GUILabel Name=BlueBGLabel
         Caption="Blue"
         TextColor=(B=255)
         WinTop=0.580000
         WinLeft=0.120000
     End Object
     l_blueBG=GUILabel'UTComp_Menu_TeamOverlay.BlueBGLabel'

     Begin Object Class=GUILabel Name=GreenBGLabel
         Caption="Green"
         TextColor=(G=255)
         WinTop=0.540000
         WinLeft=0.120000
     End Object
     l_greenBG=GUILabel'UTComp_Menu_TeamOverlay.GreenBGLabel'

     Begin Object Class=GUILabel Name=RedNameLabel
         Caption="Red"
         TextColor=(R=255)
         WinTop=0.650000
         WinLeft=0.520000
     End Object
     l_redName=GUILabel'UTComp_Menu_TeamOverlay.RedNameLabel'

     Begin Object Class=GUILabel Name=BlueNameLabel
         Caption="Blue"
         TextColor=(B=255)
         WinTop=0.730000
         WinLeft=0.520000
     End Object
     l_blueName=GUILabel'UTComp_Menu_TeamOverlay.BlueNameLabel'

     Begin Object Class=GUILabel Name=GreenNameLabel
         Caption="Green"
         TextColor=(G=255)
         WinTop=0.690000
         WinLeft=0.520000
     End Object
     l_greenName=GUILabel'UTComp_Menu_TeamOverlay.GreenNameLabel'

     Begin Object Class=GUILabel Name=RedLocLabel
         Caption="Red"
         TextColor=(R=255)
         WinTop=0.650000
         WinLeft=0.120000
     End Object
     l_redLoc=GUILabel'UTComp_Menu_TeamOverlay.RedLocLabel'

     Begin Object Class=GUILabel Name=BlueLocLabel
         Caption="Blue"
         TextColor=(B=255)
         WinTop=0.730000
         WinLeft=0.120000
     End Object
     l_blueLoc=GUILabel'UTComp_Menu_TeamOverlay.BlueLocLabel'

     Begin Object Class=GUILabel Name=GreenLocLabel
         Caption="Green"
         TextColor=(G=255)
         WinTop=0.690000
         WinLeft=0.120000
     End Object
     l_greenLoc=GUILabel'UTComp_Menu_TeamOverlay.GreenLocLabel'

     Begin Object Class=GUILabel Name=BGColorLabel
         Caption="Background Color"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.475000
         WinLeft=0.120000
     End Object
     l_BGColor=GUILabel'UTComp_Menu_TeamOverlay.BGColorLabel'

     Begin Object Class=GUILabel Name=NameColorLabel
         Caption="Name color"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.615000
         WinLeft=0.520000
     End Object
     l_NameColor=GUILabel'UTComp_Menu_TeamOverlay.NameColorLabel'

     Begin Object Class=GUILabel Name=LocColorLabel
         Caption="Location color"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.615000
         WinLeft=0.120000
     End Object
     l_LocColor=GUILabel'UTComp_Menu_TeamOverlay.LocColorLabel'

     Begin Object Class=GUILabel Name=HorizLabel
         Caption="Size:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.425000
         WinLeft=0.550000
     End Object
     l_Horiz=GUILabel'UTComp_Menu_TeamOverlay.HorizLabel'

     Begin Object Class=GUILabel Name=VertLabel
         Caption="Vertical Location:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.365000
         WinLeft=0.550000
     End Object
     l_Vert=GUILabel'UTComp_Menu_TeamOverlay.VertLabel'

     Begin Object Class=GUILabel Name=SizeLabel
         Caption="Horizontal Location:"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.310000
         WinLeft=0.550000
     End Object
     l_Size=GUILabel'UTComp_Menu_TeamOverlay.SizeLabel'

     Begin Object Class=GUISlider Name=SliderHoriz
         MaxValue=0.750000
         WinTop=0.350000
         WinLeft=0.560000
         WinWidth=0.300000
         OnClick=SliderHoriz.InternalOnClick
         OnMousePressed=SliderHoriz.InternalOnMousePressed
         OnMouseRelease=SliderHoriz.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=SliderHoriz.InternalOnKeyEvent
         OnCapturedMouseMove=SliderHoriz.InternalCapturedMouseMove
     End Object
     sl_Horiz=GUISlider'UTComp_Menu_TeamOverlay.SliderHoriz'

     Begin Object Class=GUISlider Name=SliderVert
         MaxValue=1.000000
         WinTop=0.410000
         WinLeft=0.560000
         WinWidth=0.300000
         OnClick=SliderVert.InternalOnClick
         OnMousePressed=SliderVert.InternalOnMousePressed
         OnMouseRelease=SliderVert.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=SliderVert.InternalOnKeyEvent
         OnCapturedMouseMove=SliderVert.InternalCapturedMouseMove
     End Object
     sl_Vert=GUISlider'UTComp_Menu_TeamOverlay.SliderVert'

     Begin Object Class=GUISlider Name=SliderSize
         MinValue=-7.000000
         MaxValue=0.000000
         bIntSlider=True
         WinTop=0.470000
         WinLeft=0.560000
         WinWidth=0.300000
         OnClick=SliderSize.InternalOnClick
         OnMousePressed=SliderSize.InternalOnMousePressed
         OnMouseRelease=SliderSize.InternalOnMouseRelease
         OnChange=UTComp_Menu_TeamOverlay.InternalOnChange
         OnKeyEvent=SliderSize.InternalOnKeyEvent
         OnCapturedMouseMove=SliderSize.InternalCapturedMouseMove
     End Object
     sl_Size=GUISlider'UTComp_Menu_TeamOverlay.SliderSize'

}
