

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

    sl_Volume.Value=Settings.HitSoundVolume;
    sl_Pitch.Value=Settings.CPMAPitchModifier;

    ch_CPMAStyle.Checked(Settings.bCPMAStyleHitsounds);
    ch_EnableHitSounds.Checked(Settings.bEnableHitSounds);

    co_EnemySound.AddItem((Settings.EnemySound));
    co_FriendlySound.AddItem((Settings.FriendlySound));

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
        case ch_EnableHitSounds: Settings.bEnableHitSounds=ch_enableHitSounds.IsChecked(); break;
        case sl_Volume:  Settings.HitSoundVolume=sl_Volume.Value; break;
        case sl_Pitch:  Settings.CPMAPitchModifier=sl_Pitch.Value; break;
        case co_EnemySound:  Settings.EnemySound=co_EnemySound.GetText(); break;
        case co_FriendlySound:  Settings.FriendlySound=co_FriendlySound.GetText(); break;
        case ch_CPMAStyle:   Settings.bCPMAStyleHitSounds=ch_CPMAStyle.IsChecked(); break;
    }
    class'BS_xPlayer'.Static.StaticSaveConfig();
    SaveSettings();
    DisableStuff();
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (Key == 0x1B)
        return false;
    Settings.EnemySound=co_EnemySound.GetText();
    Settings.FriendlySound=co_FriendlySound.GetText();
    BS_xPlayer(PlayerOwner()).LoadedFriendlySound = None;
    BS_xPlayer(PlayerOwner()).LoadedEnemySound = none;
    SaveSettings();
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
     sl_Volume=GUISlider'UTComp_Menu_HitSounds.HitSoundVolume'

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
     sl_Pitch=GUISlider'UTComp_Menu_HitSounds.PitchMod'

     Begin Object Class=moCheckBox Name=CPMAstyle
         Caption="CPMA Style Hitsounds"
         OnCreateComponent=CPMAstyle.InternalOnCreateComponent
         WinTop=0.490000
         WinLeft=0.250000
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
     End Object
     ch_CPMAStyle=moCheckBox'UTComp_Menu_HitSounds.CPMAstyle'

     Begin Object Class=moCheckBox Name=EnableHit
         Caption="Enable Hitsounds"
         OnCreateComponent=CPMAstyle.InternalOnCreateComponent
         WinTop=0.360000
         WinLeft=0.250000
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
     End Object
     ch_EnableHitSounds=moCheckBox'UTComp_Menu_HitSounds.EnableHit'

     Begin Object Class=GUIComboBox Name=EnemySound
         WinTop=0.654000
         WinLeft=0.412500
         WinWidth=0.340000
         WinHeight=0.030000
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
         OnKeyEvent=UTComp_Menu_HitSounds.InternalOnKeyEvent
     End Object
     co_EnemySound=GUIComboBox'UTComp_Menu_HitSounds.EnemySound'

     Begin Object Class=GUIComboBox Name=TeammateSound
         WinTop=0.704000
         WinLeft=0.412500
         WinWidth=0.340000
         WinHeight=0.030000
         OnChange=UTComp_Menu_HitSounds.InternalOnChange
         OnKeyEvent=UTComp_Menu_HitSounds.InternalOnKeyEvent
     End Object
     co_FriendlySound=GUIComboBox'UTComp_Menu_HitSounds.TeammateSound'

     Begin Object Class=GUILabel Name=VolumeLabel
         Caption="Hitsound Volume"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.390000
         WinLeft=0.250000
     End Object
     l_Volume=GUILabel'UTComp_Menu_HitSounds.VolumeLabel'

     Begin Object Class=GUILabel Name=PitchLabel
         Caption="CPMA Pitch Modifier"
         TextColor=(B=0,G=200,R=230)
         WinTop=0.540000
         WinLeft=0.250000
     End Object
     l_Pitch=GUILabel'UTComp_Menu_HitSounds.PitchLabel'

     Begin Object Class=GUILabel Name=EnemySoundLabel
         Caption="Enemy Sound"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.640000
         WinLeft=0.250000
     End Object
     l_EnemySound=GUILabel'UTComp_Menu_HitSounds.EnemySoundLabel'

     Begin Object Class=GUILabel Name=FriendlySoundLabel
         Caption="Team Sound"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.690000
         WinLeft=0.250000
     End Object
     l_FriendlySound=GUILabel'UTComp_Menu_HitSounds.FriendlySoundLabel'

}
