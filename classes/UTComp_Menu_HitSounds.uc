

class UTComp_Menu_HitSounds extends UTComp_Menu_MainMenu;

var automated GUISlider sl_Volume;
var automated GUISlider sl_Pitch;

var automated moCheckBox ch_CPMAStyle;
var automated moCheckBox ch_EnableHitSounds;

var automated GUIComboBox co_EnemySound;
var automated GUIComboBox co_FriendlySound;

var automated GUILabel l_Volume;
var automated GUILabel l_Pitch;
var automated GUILabel l_EnemySound;
var automated GUILabel l_FriendlySound;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController,MyOwner);

    sl_Volume.Value=class'UTComp_Settings'.default.HitSoundVolume;
    sl_Pitch.Value=class'UTComp_Settings'.default.CPMAPitchModifier;

    ch_CPMAStyle.Checked(class'UTComp_Settings'.default.bCPMAStyleHitsounds);
    ch_EnableHitSounds.Checked(class'UTComp_Settings'.default.bEnableHitSounds);

    co_EnemySound.AddItem((class'UTComp_Settings'.default.EnemySound));
    co_FriendlySound.AddItem((class'UTComp_Settings'.default.FriendlySound));

    DisableStuff();
}

function DisableStuff()
{
    local UTComp_ServerReplicationInfo RepInfo;

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    if(!ch_EnableHitSounds.IsChecked() || (RepInfo!=None && RepInfo.EnableHitSoundsMode==0))
    {
        sl_volume.DisableMe();
        sl_Pitch.DisableMe();
        co_EnemySound.DisableMe();
        co_FriendlySound.DisableMe();
        ch_CPMAStyle.DisableMe();
    }
    else
    {
        sl_volume.EnableMe();
        if(ch_CPMAStyle.IsChecked())
        {
            sl_Pitch.EnableMe();
        }
        else
        {
            sl_Pitch.DisableMe();
        }
        co_EnemySound.EnableMe();
        co_FriendlySound.EnableMe();
        ch_CPMAStyle.EnableMe();
    }
}

function InternalOnChange( GUIComponent C )
{
    switch(C)
    {
        case ch_EnableHitSounds: class'UTComp_Settings'.default.bEnableHitSounds=ch_enableHitSounds.IsChecked(); break;
        case sl_Volume:  class'UTComp_Settings'.default.HitSoundVolume=sl_Volume.Value; break;
        case sl_Pitch:  class'UTComp_Settings'.default.CPMAPitchModifier=sl_Pitch.Value; break;
    //    case co_EnemySound:  class'UTComp_Settings'.default.EnemySound=Sound(DynamicLoadObject(co_EnemySound.GetText(), class'Sound', True)); break;
   //    case co_FriendlySound:  class'UTComp_Settings'.default.FriendlySound=Sound(DynamicLoadObject(co_FriendlySound.GetText(), class'Sound', True)); break;
        case co_EnemySound:  class'UTComp_Settings'.default.EnemySound=co_EnemySound.GetText(); break;
        case co_FriendlySound:  class'UTComp_Settings'.default.FriendlySound=co_FriendlySound.GetText(); break;
        case ch_CPMAStyle:   class'UTComp_Settings'.default.bCPMAStyleHitSounds=ch_CPMAStyle.IsChecked(); break;
    }
    BS_xPlayer(PlayerOwner()).MakeSureSaveConfig();
    class'BS_xPlayer'.Static.StaticSaveConfig();
    class'UTComp_Settings'.static.staticSaveConfig();
    DisableStuff();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (Key == 0x1B)
        return false;
  //  class'UTComp_Settings'.default.EnemySound=Sound(DynamicLoadObject(co_EnemySound.GetText(), class'Sound', True));
 //   class'UTComp_Settings'.default.FriendlySound=Sound(DynamicLoadObject(co_FriendlySound.GetText(), class'Sound', True));
    class'UTComp_Settings'.default.EnemySound=co_EnemySound.GetText();
    class'UTComp_Settings'.default.FriendlySound=co_FriendlySound.GetText();
    BS_xPlayer(PlayerOwner()).MakeSureSaveConfig();
    BS_xPlayer(PlayerOwner()).LoadedFriendlySound = None;
    BS_xPlayer(PlayerOwner()).LoadedEnemySound = none;
    class'UTComp_Settings'.static.staticSaveConfig();
    class'BS_xPlayer'.Static.StaticSaveConfig();

    return true;
}

defaultproperties
{
     Begin Object Class=GUISlider Name=HitSoundVolume
         MaxValue=4.000000
         WinTop=0.440000
         WinLeft=0.250000
         WinWidth=0.500000
         OnClick=HitSoundVolume.InternalOnClick
         OnMousePressed=HitSoundVolume.InternalOnMousePressed
         OnMouseRelease=HitSoundVolume.InternalOnMouseRelease
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
         OnKeyEvent=HitSoundVolume.InternalOnKeyEvent
         OnCapturedMouseMove=HitSoundVolume.InternalCapturedMouseMove
     End Object
     sl_Volume=GUISlider'UTCompv18b.UTComp_Menu_HitSounds.HitSoundVolume'

     Begin Object Class=GUISlider Name=PitchMod
         MinValue=1.000000
         MaxValue=3.000000
         Value=1.000000
         WinTop=0.590000
         WinLeft=0.250000
         WinWidth=0.500000
         OnClick=PitchMod.InternalOnClick
         OnMousePressed=PitchMod.InternalOnMousePressed
         OnMouseRelease=PitchMod.InternalOnMouseRelease
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
         OnKeyEvent=PitchMod.InternalOnKeyEvent
         OnCapturedMouseMove=PitchMod.InternalCapturedMouseMove
     End Object
     sl_Pitch=GUISlider'UTCompv18b.UTComp_Menu_HitSounds.PitchMod'

     Begin Object Class=moCheckBox Name=CPMAstyle
         Caption="CPMA Style Hitsounds"
         OnCreateComponent=CPMAstyle.InternalOnCreateComponent
         WinTop=0.490000
         WinLeft=0.250000
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
     End Object
     ch_CPMAStyle=moCheckBox'UTCompv18b.UTComp_Menu_HitSounds.CPMAstyle'

     Begin Object Class=moCheckBox Name=EnableHit
         Caption="Enable Hitsounds"
         OnCreateComponent=CPMAstyle.InternalOnCreateComponent
         WinTop=0.360000
         WinLeft=0.250000
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
     End Object
     ch_EnableHitSounds=moCheckBox'UTCompv18b.UTComp_Menu_HitSounds.EnableHit'

     Begin Object Class=GUIComboBox Name=EnemySound
         WinTop=0.654000
         WinLeft=0.412500
         WinWidth=0.340000
         WinHeight=0.030000
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
         OnKeyEvent=UTComp_Menu_HitSounds.InternalOnKeyEvent
     End Object
     co_EnemySound=GUIComboBox'UTCompv18b.UTComp_Menu_HitSounds.EnemySound'

     Begin Object Class=GUIComboBox Name=TeammateSound
         WinTop=0.704000
         WinLeft=0.412500
         WinWidth=0.340000
         WinHeight=0.030000
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
         OnKeyEvent=UTComp_Menu_HitSounds.InternalOnKeyEvent
     End Object
     co_FriendlySound=GUIComboBox'UTCompv18b.UTComp_Menu_HitSounds.TeammateSound'

     Begin Object Class=GUILabel Name=VolumeLabel
         Caption="Hitsound Volume"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.390000
         WinLeft=0.250000
     End Object
     l_Volume=GUILabel'UTCompv18b.UTComp_Menu_HitSounds.VolumeLabel'

     Begin Object Class=GUILabel Name=PitchLabel
         Caption="CPMA Pitch Modifier"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.540000
         WinLeft=0.250000
     End Object
     l_Pitch=GUILabel'UTCompv18b.UTComp_Menu_HitSounds.PitchLabel'

     Begin Object Class=GUILabel Name=EnemySoundLabel
         Caption="Enemy Sound"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.640000
         WinLeft=0.250000
     End Object
     l_EnemySound=GUILabel'UTCompv18b.UTComp_Menu_HitSounds.EnemySoundLabel'

     Begin Object Class=GUILabel Name=FriendlySoundLabel
         Caption="Team Sound"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.690000
         WinLeft=0.250000
     End Object
     l_FriendlySound=GUILabel'UTCompv18b.UTComp_Menu_HitSounds.FriendlySoundLabel'

}
