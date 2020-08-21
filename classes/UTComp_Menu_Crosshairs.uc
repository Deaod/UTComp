

class UTComp_Menu_Crosshairs extends UTComp_Menu_MainMenu;


#exec texture Import File=textures\64_4_circle.dds Name=BigCircle Mips=Off Alpha=1
#exec texture Import File=textures\64_3_circle.dds Name=MedCircle Mips=Off Alpha=1
#exec texture Import File=textures\64_2_circle.dds Name=SmallCircle Mips=Off Alpha=1
#exec texture Import File=textures\64_1_circle.dds Name=UberSmallCircle Mips=Off Alpha=1

#exec texture Import File=textures\32_4_circle.dds Name=BigCircle_2 Mips=Off Alpha=1
#exec texture Import File=textures\32_3_circle.dds Name=MedCircle_2 Mips=Off Alpha=1
#exec texture Import File=textures\32_2_circle.dds Name=SmallCircle_2 Mips=Off Alpha=1
#exec texture Import File=textures\32_1_circle.dds Name=UberSmallCircle_2 Mips=Off Alpha=1

#exec texture Import File=textures\32_Square_1.dds Name=BigSquare Mips=Off Alpha=1
#exec texture Import File=textures\32_Square_2.dds Name=BigSquare_2 Mips=Off Alpha=1
#exec texture Import File=textures\32_Square_3.dds Name=BigSquare_3 Mips=Off Alpha=1

#exec texture Import File=textures\32_diamond_1.dds Name=Bigdiamond Mips=Off Alpha=1
#exec texture Import File=textures\32_diamond_2.dds Name=Bigdiamond_2 Mips=Off Alpha=1
#exec texture Import File=textures\32_diamond_3.dds Name=Bigdiamond_3 Mips=Off Alpha=1

#exec texture Import File=textures\32_bracket_0.dds Name=Bigbracket Mips=Off Alpha=1
#exec texture Import File=textures\32_bracket_1.dds Name=Bigbracket_1 Mips=Off Alpha=1
#exec texture Import File=textures\32_bracket_2.dds Name=Bigbracket_2 Mips=Off Alpha=1
#exec texture Import File=textures\32_bracket_3.dds Name=Bigbracket_3 Mips=Off Alpha=1
#exec texture Import File=textures\32_bracket_4.dds Name=Bigbracket_4 Mips=Off Alpha=1
#exec texture Import File=textures\32_bracket_5.dds Name=Bigbracket_5 Mips=Off Alpha=1
#exec texture Import File=textures\32_bracket_6.dds Name=Bigbracket_6 Mips=Off Alpha=1
#exec texture Import File=textures\32_bracket_7.dds Name=Bigbracket_7 Mips=Off Alpha=1


#exec texture Import File=textures\32_VertLine.dds Name=BigHoriz Mips=Off Alpha=1
#exec texture Import File=textures\32_HorizLine.dds Name=BigVert Mips=Off Alpha=1


#exec texture Import File=textures\64_VertLine.dds Name=SmallHoriz Mips=Off Alpha=1
#exec texture Import File=textures\64_HorizLine.dds Name=SmallVert Mips=Off Alpha=1

var automated GUIListBox lb_CrossHairs;

var automated GUIComboBox co_UTCompCrosshairs;

var automated GUIButton bu_MoveUp, bu_MoveDown, bu_AddHair, bu_DeleteHair;

var automated moCheckBox ch_UseFactory, ch_SizeIncrease;

var automated GUISlider sl_SizeHair, sl_OpacityHair, sl_HorizHair, sl_VertHair;
var automated GUISlider sl_RedHair, sl_GreenHair, sl_BlueHair;

var automated GUILabel l_Size, l_Opacity, l_Horiz, l_Vert;
var automated GUILabel l_Red, l_Green, l_Blue;

var automated GUIImage i_CurrentHairBG, i_CurrentHair, i_TotalHairBG;
var automated GUIImage i_ListBoxBG;

var automated array<GUIImage> i_TotalHair;

struct UTCompCrosshair
{
    var string xHairName;
    var texture xHairTexture;
};

var array<UTCompCrosshair> UTCompNewHairs;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local array<CacheManager.CrosshairRecord> CustomCrosshairs;
    local int i;

    Super.InitComponent(myController,MyOwner);
    class'CacheManager'.static.GetCrosshairList(CustomCrosshairs);

    //Select xHair combobox
    for(i=0; i<CustomCrosshairs.Length; i++)
        co_UTCompCrosshairs.AddItem(CustomCrosshairs[i].FriendlyName, CustomCrosshairs[i].CrosshairTexture);
    for(i=0; i<UTCompNewHairs.Length; i++)
        co_UTCompCrosshairs.AddItem(UTCompNewHairs[i].xHairName, UTCompNewHairs[i].xHairTexture);
    co_UTCompCrosshairs.ReadOnly(True);

    //ListBox of current xhairs
    lb_Crosshairs.List.bDropSource=True;
	lb_Crosshairs.List.bDropTarget=True;
	lb_Crosshairs.List.bMultiSelect=False;
    for(i=0; i<HUDSettings.UTCompCrosshairs.Length; i++)
        lb_Crosshairs.List.Add(FindDescriptionFor(HUDSettings.UTCompCrosshairs[i].CrossTex), HUDSettings.UTCompCrosshairs[i].CrossTex);

    ch_UseFactory.Checked(HUDSettings.bEnableUTCompCrosshairs);
    ch_SizeIncrease.Checked(HUDSettings.bEnableCrosshairSizing);

    if(HUDSettings.UTCompCrosshairs.Length>0)
    {
        sl_SizeHair.SetValue(HUDSettings.UTCompCrosshairs[0].CrossScale);
        sl_OpacityHair.SetValue(HUDSettings.UTCompCrosshairs[0].CrossColor.A);
        sl_HorizHair.SetValue(HUDSettings.UTCompCrosshairs[0].OffsetX);
        sl_VertHair.SetValue(HUDSettings.UTCompCrosshairs[0].OffsetY);
        sl_RedHair.SetValue(HUDSettings.UTCompCrosshairs[0].CrossColor.R);
        sl_GreenHair.SetValue(HUDSettings.UTCompCrosshairs[0].CrossColor.G);
        sl_BlueHair.SetValue(HUDSettings.UTCompCrosshairs[0].CrossColor.B);
    }

    i_CurrentHair.WinWidth=(0.10*HUDSettings.UTCompCrosshairs[0].CrossScale);
    i_CurrentHair.WinHeight=(0.10*HUDSettings.UTCompCrosshairs[0].CrossScale);
    i_CurrentHair.WinTop=0.480+(sl_VertHair.Value-0.50);
    i_CurrentHair.WinLeft=0.784+(sl_HorizHair.Value-0.50);

    if(HUDSettings.UTCompCrosshairs.Length>0)
    {
        i_CurrentHair.Image=HUDSettings.UTCompCrosshairs[0].CrossTex;
        i_CurrentHair.ImageColor=HUDSettings.UTCompCrosshairs[0].CrossColor;
    }

    RefreshFullCrossHair();
    DisableStuff();
}

function RefreshFullCrossHair()
{
    local int i;

    for(i=0; i<HUDSettings.UTCompCrosshairs.Length && i<12; i++)
    {
        i_totalhair[i].WinWidth=(0.10*HUDSettings.UTCompCrosshairs[i].CrossScale);
        i_totalhair[i].WinHeight=(0.10*HUDSettings.UTCompCrosshairs[i].CrossScale);
        i_totalhair[i].WinTop=0.680+(HUDSettings.UTCompCrosshairs[i].OffsetY-0.50);
        i_totalhair[i].WinLeft=0.784+(HUDSettings.UTCompCrosshairs[i].OffsetX-0.50);
        i_totalhair[i].Image=HUDSettings.UTCompCrosshairs[i].CrossTex;
        i_totalhair[i].ImageColor=HUDSettings.UTCompCrosshairs[i].CrossColor;
    }
    for(i=HUDSettings.UTCompCrosshairs.Length; i<12; i++)
        i_totalhair[i].Image=None;
}

function string FindDescriptionFor(Texture T)
{
    local array<CacheManager.CrosshairRecord> CustomCrosshairs;
    local int i;

    class'CacheManager'.static.GetCrosshairList(CustomCrosshairs);

    for(i=0; i<CustomCrosshairs.Length; i++)
        if(T==CustomCrosshairs[i].CrosshairTexture)
            return CustomCrosshairs[i].FriendlyName;
    for(i=0; i<UTCompNewHairs.Length; i++)
        if(T==UTCompNewHairs[i].xHairTexture)
            return UTCompNewHairs[i].xHairName;
    return string(T);
}

function InternalOnChange( GUIComponent C )
{
    Switch(C)
    {
    case ch_UseFactory: HUDSettings.bEnableUTCompCrosshairs=ch_UseFactory.IsChecked();  break;
    case ch_SizeIncrease: HUDSettings.bEnableCrosshairSizing=ch_SizeIncrease.IsChecked(); break;

        case sl_SizeHair: if(lb_CrossHairs.List.Index>=0)
                          HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossScale=sl_SizeHair.Value; break;
        case sl_OpacityHair: if(lb_CrossHairs.List.Index>=0)
                             HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossColor.A=sl_OpacityHair.Value; break;
        case sl_HorizHair: if(lb_CrossHairs.List.Index>=0)
                           HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].OffsetX=sl_HorizHair.Value; break;
        case sl_VertHair: if(lb_CrossHairs.List.Index>=0)
                          HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].OffsetY=sl_VertHair.Value; break;
        case sl_RedHair: if(lb_CrossHairs.List.Index>=0)
                         HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossColor.R=sl_RedHair.Value; break;
        case sl_GreenHair: if(lb_CrossHairs.List.Index>=0)
                           HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossColor.G=sl_GreenHair.Value; break;
        case sl_BlueHair: if(lb_CrossHairs.List.Index>=0)
                          HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossColor.B=sl_BlueHair.Value; break;

    case lb_CrossHairs:  UpdateSliders();
                         co_UTCompCrosshairs.SetIndex(co_UTCompCrosshairs.FindIndex(FindDescriptionFor(Texture(lb_CrossHairs.List.GetObject()))));
                         break;

    case co_UTCompCrosshairs:   if(lb_CrossHairs.List.Index>=0)
                          {
                              HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossTex=texture(co_UTCompCrosshairs.GetObject());
                              lb_CrossHairs.List.SetObjectAtIndex(lb_CrossHairs.List.Index,co_UTCompCrosshairs.GetObject());
                              lb_CrossHairs.List.SetItemAtIndex(lb_CrossHairs.List.Index,FindDescriptionFor(Texture(co_UTCompCrosshairs.GetObject())));
                              break;
                          }
    }
    SaveHUDSettings();
    UpdateImages();
    RefreshFullCrossHair();
    DisableStuff();
}

function DisableStuff()
{
     if(ch_UseFactory.IsChecked())
     {
         sl_SizeHair.EnableMe();
         sl_OpacityHair.EnableMe();
         sl_HorizHair.EnableMe();
         sl_VertHair.EnableMe();
         sl_RedHair.EnableMe();
         sl_GreenHair.EnableMe();
         sl_BlueHair.EnableMe();

         lb_CrossHairs.EnableMe();
         co_UTCompCrosshairs.EnableMe();
         bu_MoveUp.EnableMe();
         bu_MoveDown.EnableMe();
         bu_AddHair.EnableMe();
         bu_DeleteHair.EnableMe();
     }
     else
     {
         sl_SizeHair.DisableMe();
         sl_OpacityHair.DisableMe();
         sl_HorizHair.DisableMe();
         sl_VertHair.DisableMe();
         sl_RedHair.DisableMe();
         sl_GreenHair.DisableMe();
         sl_BlueHair.DisableMe();

         lb_CrossHairs.DisableMe();
         co_UTCompCrosshairs.DisableMe();
         bu_MoveUp.DisableMe();
         bu_MoveDown.DisableMe();
         bu_AddHair.DisableMe();
         bu_DeleteHair.DisableMe();
    }
    if(HUDSettings.UTCompCrosshairs.Length==0)
    {
         sl_SizeHair.DisableMe();
         sl_OpacityHair.DisableMe();
         sl_HorizHair.DisableMe();
         sl_VertHair.DisableMe();
         sl_RedHair.DisableMe();
         sl_GreenHair.DisableMe();
         sl_BlueHair.DisableMe();

         lb_CrossHairs.DisableMe();
         co_UTCompCrosshairs.DisableMe();
         bu_MoveUp.DisableMe();
         bu_MoveDown.DisableMe();
         bu_DeleteHair.DisableMe();
    }
}

function UpdateSliders()
{
    if(lb_CrossHairs.List.Index<0)
         return;
    sl_SizeHair.SetValue(HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossScale);
    sl_OpacityHair.SetValue(HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossColor.A);
    sl_HorizHair.SetValue(HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].OffsetX);
    sl_VertHair.SetValue(HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].OffsetY);
    sl_RedHair.SetValue(HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossColor.R);
    sl_GreenHair.SetValue(HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossColor.G);
    sl_BlueHair.SetValue(HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index].CrossColor.B);

}

function UpdateImages()
{
    if(lb_Crosshairs.List.Index>=0)
    {
        i_CurrentHair.WinWidth=(0.10*HUDSettings.UTCompCrosshairs[lb_Crosshairs.List.Index].CrossScale);
        i_CurrentHair.WinHeight=(0.10*HUDSettings.UTCompCrosshairs[lb_Crosshairs.List.Index].CrossScale);
        i_CurrentHair.WinTop=0.480+(HUDSettings.UTCompCrosshairs[lb_Crosshairs.List.Index].OffsetY-0.50);
        i_CurrentHair.WinLeft=0.784+(HUDSettings.UTCompCrosshairs[lb_Crosshairs.List.Index].OffsetX-0.50);

        if(HUDSettings.UTCompCrosshairs.Length>0)
        {
            i_CurrentHair.Image=HUDSettings.UTCompCrosshairs[lb_Crosshairs.List.Index].CrossTex;
            i_CurrentHair.ImageColor=HUDSettings.UTCompCrosshairs[lb_Crosshairs.List.Index].CrossColor;
        }
    }
}

function SetupNewHair(int i)
{
    HUDSettings.UTCompCrosshairs[i].CrossScale=1.0;
    HUDSettings.UTCompCrosshairs[i].CrossColor.A=255;
    HUDSettings.UTCompCrosshairs[i].OffsetX=0.50;
    HUDSettings.UTCompCrosshairs[i].OffsetY=0.50;
    HUDSettings.UTCompCrosshairs[i].CrossColor.R=255;
    HUDSettings.UTCompCrosshairs[i].CrossColor.G=255;
    HUDSettings.UTCompCrosshairs[i].CrossColor.B=255;
}

function bool InternalOnClick( GUIComponent Sender )
{
    local int i;

    switch (Sender)
    {
        case bu_AddHair:   i=HUDSettings.UTCompCrosshairs.Length;
                       HUDSettings.UTCompCrosshairs.Length=i+1;
                       HUDSettings.UTCompCrosshairs[i].CrossTex=Texture(lb_Crosshairs.List.GetObject());
                       SetupNewHair(i);
                       UpdateSliders();
                       lb_Crosshairs.List.Add("New", None);
                       break;
        case bu_DeleteHair: i=lb_Crosshairs.List.Index;
                        if(i<HUDSettings.UTCompCrosshairs.Length && i>=0)
                        {
                            HUDSettings.UTCompCrosshairs.Remove(i,1);
                            lb_Crosshairs.List.Clear();
                            for(i=0; i<HUDSettings.UTCompCrosshairs.Length; i++)
                               lb_Crosshairs.List.Add(FindDescriptionFor(HUDSettings.UTCompCrosshairs[i].CrossTex), HUDSettings.UTCompCrosshairs[i].CrossTex);
                        }
                        DisableStuff();
                        break;
        case bu_MoveUp:  if(lb_CrossHairs.List.Index>0)
                         {
                             lb_CrossHairs.List.Swap(lb_CrossHairs.List.Index,lb_CrossHairs.List.Index-1);
                             HUDSettings.TempXHair=HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index];
                             HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index]=HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index-1];
                             HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index-1]=HUDSettings.TempXHair;
                         }
                         break;
        case bu_MoveDown: if(HUDSettings.UTCompCrosshairs.Length>lb_CrossHairs.List.Index+1 && lb_CrossHairs.List.Index>=0)
                          {
                             lb_CrossHairs.List.Swap(lb_CrossHairs.List.Index,lb_CrossHairs.List.Index+1);
                             HUDSettings.TempXHair=HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index];
                             HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index]=HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index+1];
                             HUDSettings.UTCompCrosshairs[lb_CrossHairs.List.Index+1]=HUDSettings.TempXHair;
                          }
                          break;
    }
    UpdateImages();
    RefreshFullCrossHair();
    DisableStuff();
    return super.InternalOnClick(Sender);
}

defaultproperties
{
    Begin Object class=GUIComboBox name=CrosshairCombo
    	WinWidth=0.248444
		WinHeight=0.035000
		WinLeft=0.350001
		WinTop=0.366666
		OnChange=InternalOnChange
    End Object
    co_UTCompCrosshairs=GUIComboBox'CrosshairCombo'

    Begin Object class=GUIListBox name=CrosshairListBox
		WinWidth=0.160000
		WinHeight=0.264375
		WinLeft=0.140000
		WinTop=0.392917
        bVisibleWhenEmpty=True
        OnChange=InternalOnChange
    End Object
    lb_Crosshairs=GUIListBox'CrosshairListBox'

    Begin Object class=GUIImage name=ListBoxBackgroundImage
        Image=Texture'2K4Menus.Controls.thinpipe_b'
		WinWidth=0.200000
		WinHeight=0.304688
		WinLeft=0.120000
		WinTop=0.372917
		bVisible=True
		ImageStyle=ISTY_Stretched
	End Object
    i_ListBoxBG=GUIImage'ListBoxBackgroundImage'

    Begin Object class=GUISlider name=RedCrossSlider
         WinTop=0.415
         WinLeft=0.41
         WinWidth=0.25
         MinValue=0
         MaxValue=255
         bIntSlider=True
         Value=255
         OnChange=InternalOnChange
    End Object
    sl_RedHair=GUISlider'RedCrossSlider'

    Begin Object class=GUILabel name=RedCrossLabel
         WinTop=0.40
         WinLeft=0.34
         Caption="Red"
         TextColor=(R=255)
    End Object
    l_Red=GUILabel'RedCrossLabel'

    Begin Object class=GUILabel name=GreenCrossLabel
         WinTop=0.44
         WinLeft=0.34
         Caption="Green"
         TextColor=(G=255)
    End Object
    l_Green=GUILabel'GreenCrossLabel'

    Begin Object class=GUILabel name=BlueCrossLabel
         WinTop=0.48
         WinLeft=0.34
         Caption="Blue"
         TextColor=(B=255)
    End Object
    l_Blue=GUILabel'BlueCrossLabel'

    Begin Object class=GUILabel name=OpacityCrossLabel
         WinTop=0.52
         WinLeft=0.34
         Caption="Alpha"
         TextColor=(B=255,R=255,G=255)
    End Object
    l_Opacity=GUILabel'OpacityCrossLabel'

    Begin Object class=GUILabel name=SizeCrossLabel
         WinTop=0.56
         WinLeft=0.34
         Caption="Size"
         TextColor=(B=255,R=255,G=255)
    End Object
    l_Size=GUILabel'SizeCrossLabel'

   Begin Object class=GUILabel name=HorizCrossLabel
         WinTop=0.60
         WinLeft=0.34
         Caption="Left"
         TextColor=(B=255,R=255,G=255)
    End Object
    l_Horiz=GUILabel'HorizCrossLabel'

    Begin Object class=GUILabel name=VertCrossLabel
         WinTop=0.64
         WinLeft=0.34
         Caption="Up"
         TextColor=(B=255,R=255,G=255)
    End Object
    l_Vert=GUILabel'VertCrossLabel'

    Begin Object class=GUISlider name=GreenCrossSlider
         WinTop=0.455
         WinLeft=0.41
         WinWidth=0.25
         MinValue=0
         MaxValue=255
         Value=255
         bIntSlider=True
         OnChange=InternalOnChange
    End Object
    sl_GreenHair=GUISlider'GreenCrossSlider'

    Begin Object class=GUISlider name=BlueCrossSlider
         WinTop=0.495
         WinLeft=0.41
         WinWidth=0.25
         MinValue=0
         MaxValue=255
         Value=255
         bIntSlider=True
         OnChange=InternalOnChange
    End Object
    sl_BlueHair=GUISlider'BlueCrossSlider'

    Begin Object class=GUISlider name=OpacityCrossSlider
         WinTop=0.535
         WinLeft=0.41
         WinWidth=0.25
         MinValue=0
         MaxValue=255
         Value=255
         bIntSlider=True
         OnChange=InternalOnChange
    End Object
    sl_OpacityHair=GUISlider'OpacityCrossSlider'

    Begin Object class=GUISlider name=SizeCrossSlider
         WinTop=0.575
         WinLeft=0.41
         WinWidth=0.25
         MinValue=0
         MaxValue=4
         Value=1.00
         OnChange=InternalOnChange
    End Object
    sl_SizeHair=GUISlider'SizeCrossSlider'

    Begin Object class=GUISlider name=HorizCrossSlider
         WinTop=0.615
         WinLeft=0.41
         WinWidth=0.25
         MinValue=0.4
         MaxValue=0.6
         Value=0.50
         OnChange=InternalOnChange
    End Object
    sl_HorizHair=GUISlider'HorizCrossSlider'

    Begin Object class=GUISlider name=VertCrossSlider
         WinTop=0.655
         WinLeft=0.41
         WinWidth=0.25
         MinValue=0.4
         MaxValue=0.6
         Value=0.50
         OnChange=InternalOnChange
    End Object
    sl_VertHair=GUISlider'VertCrossSlider'

    Begin Object class=moCheckBox name=UseFactoryCheck
		WinWidth=0.350000
		WinHeight=0.030000
		WinLeft=0.126562
		WinTop=0.324583
        Caption="Use Crosshair Factory"
        OnChange=InternalOnChange
    End Object
    ch_UseFactory=moCheckBox'UseFactoryCheck'

   Begin Object class=moCheckBox name=SizeIncreaseCheck
		WinWidth=0.350000
		WinHeight=0.030000
		WinLeft=0.548751
		WinTop=0.328750
        Caption="Crosshair Size Increase"
        OnChange=InternalOnChange
    End Object
    ch_SizeIncrease=moCheckBox'SizeIncreaseCheck'

    Begin Object class=GUIButton name=AddHairButton
		WinWidth=0.080000
		WinHeight=0.040000
		WinLeft=0.126562
		WinTop=0.688559
        Caption="Add"
        OnClick=InternalOnClick
    End Object
    bu_AddHair=GUIButton'AddHairButton'

    Begin Object class=GUIButton name=DeleteHairButton
		WinWidth=0.080000
		WinHeight=0.040000
		WinLeft=0.206562
		WinTop=0.688559
        Caption="Delete"
        OnClick=InternalOnClick
    End Object
    bu_DeleteHair=GUIButton'DeleteHairButton'

    Begin Object class=GUIButton name=MoveUpHairButton
		WinWidth=0.080000
		WinHeight=0.040000
		WinLeft=0.126562
		WinTop=0.734384
        Caption="Up"
        OnClick=InternalOnClick
    End Object
    bu_MoveUp=GUIButton'MoveUpHairButton'

    Begin Object class=GUIButton name=MoveDownHairButton
		WinWidth=0.080000
		WinHeight=0.040000
		WinLeft=0.206562
		WinTop=0.734384
        Caption="Down"
        OnClick=InternalOnClick
    End Object
    bu_MoveDown=GUIButton'MoveDownHairButton'

    Begin Object class=GUIImage name=CurrentHairBackgroundImage
        Image=Texture'2K4Menus.Controls.thinpipe_b'
		WinWidth=0.200000
		WinHeight=0.200000
		WinLeft=0.680000
		WinTop=0.372917
		bVisible=True
		ImageStyle=ISTY_Stretched
	End Object
    i_CurrentHairBG=GUIImage'CurrentHairBackgroundImage'


    Begin Object class=GUIImage name=TotalHairBackgroundImage
        Image=Texture'2K4Menus.Controls.thinpipe_b'
		WinWidth=0.200000
		WinHeight=0.200000
		WinLeft=0.680000
		WinTop=0.58335
		bVisible=True
		ImageStyle=ISTY_Stretched
	End Object
    i_TotalHairBG=GUIImage'TotalHairBackgroundImage'

    Begin Object class=GUIImage name=CurrentHAirImage
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
      End Object
    i_CurrentHair=GUIImage'CurrentHairImage'

    Begin Object class=GUIImage name=TotalHairImage0
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(0)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage1
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
     End Object
    i_TotalHair(1)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage2
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
      End Object
    i_TotalHair(2)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage3
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(3)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage4
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
     End Object
    i_TotalHair(4)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage5
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(5)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage6
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(6)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage7
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(7)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage8
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(8)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage9
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(9)=GUIImage'TotalHairImage0'

        Begin Object class=GUIImage name=TotalHairImage10
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(10)=GUIImage'TotalHairImage0'

    Begin Object class=GUIImage name=TotalHairImage11
        ImageStyle=ISTY_Scaled
        ImageAlign=IMGA_Center
        X1=0
        Y1=0
        X2=64
        Y2=64
    End Object
    i_TotalHair(11)=GUIImage'TotalHairImage0'

    UTCompNewHairs(0)=(xHairName="Big Circle(0)",xHairTexture=Texture'BigCircle')
    UTCompNewHairs(1)=(xHairName="Big Circle(1)",xHairTexture=Texture'MedCircle')
    UTCompNewHairs(2)=(xHairName="Big Circle(2)",xHairTexture=Texture'SmallCircle')
    UTCompNewHairs(3)=(xHairName="Big Circle(3)",xHairTexture=Texture'UberSmallCircle')

    UTCompNewHairs(4)=(xHairName="Small Circle(0)",xHairTexture=Texture'BigCircle_2')
    UTCompNewHairs(5)=(xHairName="Small Circle(1)",xHairTexture=Texture'MedCircle_2')
    UTCompNewHairs(6)=(xHairName="Small Circle(2)",xHairTexture=Texture'SmallCircle_2')
    UTCompNewHairs(7)=(xHairName="Small Circle(3)",xHairTexture=Texture'UberSmallCircle_2')

    UTCompNewHairs(8)=(xHairName="Big Square(0)",xHairTexture=Texture'BigSquare')
    UTCompNewHairs(9)=(xHairName="Big Square(1)",xHairTexture=Texture'BigSquare_2')
    UTCompNewHairs(10)=(xHairName="Big Square(2)",xHairTexture=Texture'BigSquare_3')

    UTCompNewHairs(11)=(xHairName="Big diamond(0)",xHairTexture=Texture'Bigdiamond')
    UTCompNewHairs(12)=(xHairName="Big Diamond(1)",xHairTexture=Texture'Bigdiamond_2')
    UTCompNewHairs(13)=(xHairName="Big Diamond(2)",xHairTexture=Texture'Bigdiamond_3')

    UTCompNewHairs(14)=(xHairName="Big Horiz",xHairTexture=Texture'SmallVert')
    UTCompNewHairs(15)=(xHairName="Small Horiz",xHairTexture=Texture'BigVert')
    UTCompNewHairs(16)=(xHairName="Big Vert",xHairTexture=Texture'SmallHoriz')
    UTCompNewHairs(17)=(xHairName="Small Vert",xHairTexture=Texture'BigHoriz')

    UTCompNewHairs(18)=(xHairName="Big 'L'(0)",xHairTexture=Texture'BigBracket')
    UTCompNewHairs(19)=(xHairName="Big 'L'(1)",xHairTexture=Texture'BigBracket_1')
    UTCompNewHairs(20)=(xHairName="Big 'L'(2)",xHairTexture=Texture'BigBracket_2')
    UTCompNewHairs(21)=(xHairName="Big 'L'(3)",xHairTexture=Texture'BigBracket_3')
    UTCompNewHairs(22)=(xHairName="Big 'L'(4)",xHairTexture=Texture'BigBracket_4')
    UTCompNewHairs(23)=(xHairName="Big 'L'(5)",xHairTexture=Texture'BigBracket_5')
    UTCompNewHairs(24)=(xHairName="Big 'L'(6)",xHairTexture=Texture'BigBracket_6')
    UTCompNewHairs(25)=(xHairName="Big 'L'(7)",xHairTexture=Texture'BigBracket_7')

}
