//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UTComp_menu_AdrenMenu extends UTComp_Menu_MainMenu;

var automated moCheckBox ch_booster;
var automated moCheckBox ch_invis;
var automated moCheckBox ch_speed;
var automated moCheckBox ch_berserk;

var automated GUILAbel l_adren;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController,MyOwner);

    ch_booster.Checked(!Settings.bDisableBooster);
    ch_speed.Checked(!Settings.bDisableSpeed);
    ch_berserk.Checked(!Settings.bDisableBerserk);
    ch_invis.Checked(!Settings.bDisableInvis);
}

function InternalOnChange( GUIComponent C )
{
    switch(C)
    {
        case ch_booster: Settings.bDisableBooster=!ch_booster.IsChecked(); break;
        case ch_invis:  Settings.bDisableInvis=!ch_Invis.IsChecked();
        case ch_speed:  Settings.bDisableSpeed=!ch_Speed.IsChecked(); break;
        case ch_berserk: Settings.bDisableberserk=!ch_Berserk.IsChecked(); break;
    }
    SaveSettings();
}


DefaultProperties
{
    Begin Object Class=GUILabel Name=AdrenLabel
        Caption="----Adrenaline Combo Settings----"
        TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.250000
		WinTop=0.36
     End Object
     l_Adren=GUILabel'UTComp_Menu_AdrenMenu.AdrenLabel'


     Begin Object Class=moCheckBox Name=BoosterCheck
        Caption="Enable Booster Combo"
        OnCreateComponent=BoosterCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.430000
         OnChange=UTComp_Menu_AdrenMenu.InternalOnChange
     End Object
     ch_Booster=moCheckBox'UTComp_Menu_AdrenMenu.BoosterCheck'

      Begin Object Class=moCheckBox Name=InvisCheck
        Caption="Enable Invisibility Combo"
        OnCreateComponent=InvisCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.480000
         OnChange=UTComp_Menu_AdrenMenu.InternalOnChange
     End Object
     ch_Invis=moCheckBox'UTComp_Menu_AdrenMenu.InvisCheck'

          Begin Object Class=moCheckBox Name=SpeedCheck
        Caption="Enable Speed Combo"
        OnCreateComponent=SpeedCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.530000
         OnChange=UTComp_Menu_AdrenMenu.InternalOnChange
     End Object
     ch_Speed=moCheckBox'UTComp_Menu_AdrenMenu.SpeedCheck'

     Begin Object Class=moCheckBox Name=BerserkCheck
        Caption="Enable Berserk Combo"
        OnCreateComponent=BerserkCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.580000
         OnChange=UTComp_Menu_AdrenMenu.InternalOnChange
     End Object
     ch_Berserk=moCheckBox'UTComp_Menu_AdrenMenu.BerserkCheck'
}