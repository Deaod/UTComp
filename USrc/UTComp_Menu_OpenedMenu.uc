
class UTComp_Menu_OpenedMenu extends UTComp_Menu_MainMenu;

var automated array<GUILabel> l_Mode;
var automated GUIImage i_UTCompLogo;
var automated GUIButton bu_Ready, bu_NotReady;

var color GoldColor;

var UTComp_ServerReplicationInfo RepInfo;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
   // local mutator mut;

    l_Mode[2].Caption=class'MutUTComp'.default.FriendlyVersionPrefix $ class'Gameinfo'.Static.MakeColorCode(GoldColor) @ class'MutUTComp'.default.FriendlyVersionNumber;


  /*  for ( mut=PlayerOwner().Level.Game.BaseMutator; mut!=None; mut=mut.NextMutator )
	if ( mut.IsA('Forward_Mutator') )
	{
         i_UTCompLogo.Image = texture'ForwardLogo';
         return;
	}
  */
	Super.InitComponent(myController,MyOwner);
}

function RandomCrap()
{
    if(RepInfo==None)
       foreach PlayerOwner().ViewTarget.DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
          break;

    if (RepInfo.EnableBrightSkinsMode == 1)
        l_Mode[0].Caption = class'Gameinfo'.Static.MakeColorCode(GoldColor)$"Brightskins Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Brightskins Disabled";
    else if (RepInfo.EnableBrightSkinsMode == 2)
        l_Mode[0].Caption = class'Gameinfo'.Static.MakeColorCode(GoldColor)$"Brightskins Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Bright Epic Style Skins";
    else if (RepInfo.EnableBrightSkinsMode == 3)
        l_Mode[0].Caption = class'gameinfo'.Static.MakeColorCode(GoldColor)$"Brightskins Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  UTComp Style Skins";
    if (RepInfo.EnableHitSoundsMode == 0)
       l_Mode[1].Caption = class'gameinfo'.Static.MakeColorCode(GoldColor)$"Hitsounds Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Disabled";
    else if (RepInfo.EnableHitSoundsMode == 1)
       l_Mode[1].Caption = class'gameinfo'.Static.MakeColorCode(GoldColor)$"Hitsounds Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Line Of Sight";
    else if (RepInfo.EnableHitSoundsMode == 2)
       l_Mode[1].Caption = class'gameinfo'.Static.MakeColorCode(GoldColor)$"Hitsounds Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$"  Everywhere";
    if(RepInfo.benableDoubleDamage)
       l_Mode[3].Caption =class'gameinfo'.Static.MakeColorCode(GoldColor)$"Double Damage Mode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$" Enabled";
    else
       l_Mode[3].Caption =class'GameInfo'.Static.MakeColorCode(GoldColor)$"Double Damage Mode:"$class'GameInfo'.Static.MakeColorCode(WhiteColor)$" Disabled";
    if(RepInfo.bEnableEnhancedNetCode)
       l_Mode[5].Caption =class'gameinfo'.Static.MakeColorCode(GoldColor)$"Enhanced Netcode:"$class'gameinfo'.Static.MakeColorCode(WhiteColor)$" Enabled";
    else
       l_Mode[5].Caption =class'GameInfo'.Static.MakeColorCode(GoldColor)$"Enhanced Netcode:"$class'GameInfo'.Static.MakeColorCode(WhiteColor)$" Disabled";

   if(!PlayerOwner().PlayerReplicationInfo.bOnlySpectator)
   {
     bu_Ready.Caption="Ready";
     bu_NotReady.Caption="Not Ready";
   }
   else
   {
     bu_Ready.Caption="Coach Red";
     bu_NotReady.Caption="Coach Blue";
   }
}

event opened(GUIComponent Sender)
{
    super.Opened(Sender);
    RandomCrap();
}

function bool InternalOnClick( GUIComponent C )
{

    switch (C)
    {
      case bu_Ready:   if(PlayerOwner().IsA('BS_xPlayer'))
                           {
                              if(PlayerOwner().PlayerReplicationInfo.bOnlySpectator)
                                BS_xPlayer(PlayerOwner()).SpecLockRed();
                              else
                                BS_xPlayer(PlayerOwner()).Ready();
                           }
                           PlayerOwner().ClientCloseMenu();
                           return false;

      case bu_NotReady:
                           if(PlayerOwner().IsA('BS_xPlayer'))
                           {
                              if(PlayerOwner().PlayerReplicationInfo.bOnlySpectator)
                                BS_xPlayer(PlayerOwner()).SpecLockBlue();
                              else
                                BS_xPlayer(PlayerOwner()).NotReady();
                           }
                           PlayerOwner().ClientCloseMenu();
                           return false;
    }

    return super.internalonclick(C);
}

DefaultProperties
{
     Begin Object Class=GUILabel Name=BrightSkinsModeLabel
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.049485
		WinLeft=0.000000
		WinTop=0.494433
         TextAlign=TXTA_Center
     End Object
     l_Mode(0)=GUILabel'BrightSkinsModeLabel'

     Begin Object Class=GUILabel Name=HitSoundsModeLabel
         TextColor=(B=255,G=255,R=255)
         WinTop=0.530000
         WinLeft=0.000000
         WinHeight=24.000000
         TextAlign=TXTA_Center
     End Object
     l_Mode(1)=GUILabel'HitSoundsModeLabel'

     Begin Object Class=GUILabel Name=VersionLabel
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.049485
		WinLeft=0.000000
		WinTop=0.417011
         TextAlign=TXTA_Center
     End Object
     l_Mode(2)=GUILabel'VersionLabel'

     Begin Object class=GUIButton name=ReadyButton
         WinTop=.65
         WinLeft=.25
         WinWidth=.20
         WinHeight=.06
         OnClick=InternalOnClick
     End Object
     bu_Ready=GUIButton'readybutton'

     Begin Object class=GUIButton name=NotReadyButton
         WinTop=.65
         WinLeft=.55
         WinWidth=.20
         WinHeight=.06
         OnClick=InternalOnClick
     End Object
     bu_NotReady=GUIButton'notreadybutton'


     Begin Object Class=GUILabel Name=AmpModeLabel
         TextColor=(B=255,G=255,R=255)
         WinTop=0.570000
         WinLeft=0.000000
         WinHeight=24.000000
         TextAlign=TXTA_Center
     End Object
     l_Mode(3)=GUILabel'AmpModeLabel'

     Begin Object Class=GUILabel Name=NetCodeModeLabel
         TextColor=(B=255,G=255,R=255)
         WinTop=0.610000
         WinLeft=0.000000
         WinHeight=24.000000
         TextAlign=TXTA_Center
     End Object
     l_Mode(5)=GUILabel'NetCodeModeLabel'

     Begin Object Class=GUILabel Name=ServerSetLabel
		WinWidth=1.000000
		WinHeight=0.049485
		WinLeft=0.000000
		WinTop=0.454433
		TextColor=(B=0,G=200,R=230)
        Caption = "------Server Settings------"
         TextAlign=TXTA_Center
     End Object
     l_Mode(6)=GUILabel'ServerSetLabel'

     Begin Object class=GUIImage name=UTCompLogo
     ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Alpha
		WinWidth=0.375000
		WinHeight=0.125000
		WinLeft=0.312500
		WinTop=0.307113
        Image=Texture'UTCompLogo'
     End Object
     i_UTCompLogo=GUIImage'UTCompLogo'


     Begin Object Class=GUILabel Name=NewVersions
         TextColor=(B=255,G=255,R=255)
     	 WinWidth=1.000000
		 WinHeight=0.050000
		 WinLeft=0.000000
		 WinTop=0.727502
         TextAlign=TXTA_Center
         Caption="Visit https://GitHub.com/Deaod/UTComp for new versions."
     End Object
     l_Mode(4)=GUILabel'NewVersions'

     GoldColor=(B=0,G=200,R=230)
}
