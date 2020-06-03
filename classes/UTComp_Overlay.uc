

//-----------------------------------------------------------
// Part of TeamOverlay by Adam 'Heywood' Booth - heywood@malevolence.com.au
// altered/recoded by Aaron 'Lotus' Everitt for use in UTCompv18
//-----------------------------------------------------------
class UTComp_Overlay extends Interaction;

#exec texture Import File=textures\weaponicon_assaultrifle.dds Name=AssaultIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_biorifle.dds Name=BioIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_linkgun.dds Name=LinkIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_flakcannon.dds Name=FlakIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_rocketlauncher.dds Name=RocketIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_minigun.dds Name=MiniIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_shockrifle.dds Name=ShockIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_lightninggun.dds Name=LightningIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_shieldgun.dds Name=ShieldIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_SniperRifle.dds Name=SniperIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_dualassaultrifle.dds Name=DualARIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_GrenadeLauncher.dds Name=GrenadeIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_MineLayer.dds Name=SpiderIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_Avril.dds Name=AvrilIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_Redeemer.dds Name=RedeemerIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_Painter.dds Name=PainterIcon Mips=Off Alpha=1
#exec texture Import File=textures\weaponicon_Translocator.dds Name=TranslocIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Manta.dds Name=MantaIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Goliath.dds Name=GoliathIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Hellbender.dds Name=HellbenderIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Scorpion.dds Name=ScorpionIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Raptor.dds Name=RaptorIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Leviathan.dds Name=LeviathanIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Turret.dds Name=TurretIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_SPMA.tga Name=SPMAIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Cicada.tga Name=CicadaIcon Mips=Off Alpha=1
#exec texture Import File=textures\vehicle_Paladin.tga Name=PaladinIcon Mips=Off Alpha=1


//#exec texture import file=textures\Powerup_Doubledamage.tga name=DDIcon Mips=Off Alpha=1
var gamereplicationinfo GRI;
var font InfoFont, LocationFont;
var float healthOffset, armorOffset, wepiconoffset;
var int oldscreenwidth, oldfontsize;
var float tmpX, tmpY, strlenX, strlenY, strlenX2, strlenY2, strlenX3, strlenY3,iconscale;
var float OnJoinMessageDrawTime;
var config float DesiredOnJoinMessageTime;

var config bool OverlayEnabled, bDrawIcons;
var bool BiggerFont;

var vector savedLocation[8];
var string printLocation[8];

var config float VertPosition, HorizPosition;

var config Color BGColor, InfoTextColor, LocTextColor;
var config int theFontSize;

event NotifyLevelChange()
{
        Master.RemoveInteraction(self);
}

event Initialized()
{
    foreach ViewportOwner.Actor.DynamicActors(class'GameReplicationInfo', GRI)
        If (GRI != None)
            Break;
    OnJoinMessageDrawTime=ViewPortOwner.Actor.Level.TimeSeconds+default.DesiredOnJoinMessageTime;
}

function PostRender( canvas Canvas )
{
   local int i, numplayers;
   local UTComp_PRI uPRI;

   if(ViewportOwner.Actor.IsA('BS_xPlayer'))
   {
      if(BS_xPlayer(ViewportOwner.Actor).UTCompPRI!=None)
          uPRI=BS_xPlayer(ViewportOwner.Actor).UTCompPRI;
   }
   if(uPRI==None || ViewportOwner.Actor.myHUD.bShowScoreBoard || !default.OverlayEnabled)
       return;

   tmpX=Canvas.ClipX*default.HorizPosition;//0.003;
   tmpY=Canvas.ClipY*default.VertPosition;//0.07;
  // iconScale=Canvas.ClipX/1280.0;
   if((Canvas.SizeX != OldScreenWidth) || infoFont==None || locationFont==None || oldFontSize != default.theFontSize)
   {
       GetFonts(Canvas);
       oldFontSize=default.TheFontSize;
       OldScreenWidth=Canvas.SizeX;
       Canvas.Font=infoFont;
       Canvas.StrLen("X", strlenx, strleny);
       Canvas.Font=LocationFont;
       Canvas.StrLen("X", strlenx2, strleny2);
       iconScale=strLenY/16.0;
       if(BiggerFont)
       {
           HealthOffset=10*strlenX;
           ArmorOffset=14*strlenX;
           wepiconOffset=18*strLenX;
       }
       else
       {
           HealthOffset=15*strlenX;
           ArmorOffset=19*strlenX;
           wepiconOffset=23*strLenX;
  /*     HealthOffset=Canvas.ClipX*0.16;
       armorOffset=Canvas.ClipX*0.20;
       wepiconOffset=Canvas.ClipX*0.24;  */
       }
   }

   if(ViewPortOwner.Actor.Level.TimeSeconds<OnJoinMessageDrawTime)
   {
       Canvas.SetPos(TmpX, TmpY);
       Canvas.Style=5;
       Canvas.DrawColor=BGColor;
       Canvas.Font=GetFont(AutoPickFont(Canvas.SizeX, -3), 1);
       Canvas.StrLen("This server is running", StrLenX3, StrLenY3);
       if(GetNewNetEnabled())
           Canvas.DrawTileStretched(material'Engine.WhiteTexture',StrLenX3+5.0, 8*(StrLenY3));
       else
           Canvas.DrawTileStretched(material'Engine.WhiteTexture',StrLenX3+5.0, 6*(StrLenY3));
       Canvas.SetPos(TmpX, TmpY);
       Canvas.DrawColor=InfoTextColor;
       Canvas.DrawText("This server is running");
       Canvas.StrLen("W", StrLenX3, StrLenY3);
       Canvas.SetPos(TmpX, TmpY+1*(StrLenY3+2.0));
       Canvas.DrawText("UTComp "$MakeColorCode(class'Hud'.Default.GoldColor)$class'MutUTComp'.default.FriendlyVersionNumber$MakeColorCode(InfoTextColor)$".");
       Canvas.SetPos(TmpX, TmpY+3*(StrLenY3+2.0));
       Canvas.DrawText("Press "$MakeColorCode(class'Hud'.Default.GoldColor)$class'GameInfo'.Static.GetKeyBindName("mymenu", BS_xPlayer(ViewportOwner.Actor))$MakeColorCode(InfoTextColor)$" to change");
       Canvas.SetPos(TmpX, TmpY+4*(StrLenY3+2.0));
       Canvas.DrawText("your settings");
       if(GetNewNetEnabled())
       {
           Canvas.SetPos(TmpX, TmpY+5*(StrLenY3+2.0));
           Canvas.DrawText("Enh. Net:"@MakeColorCode(class'Hud'.Default.GoldColor)$"Enabled"$MakeColorCode(InfoTextColor)$".");
       }
       return;
   }

    // Draw BackGround
     for(i=0; i<8; i++)
        if(uPRI.OverlayInfo[i].PRI!=None)
           numPlayers++;
     if(numPlayers<=0)
        return;
     Canvas.Style=5;
     Canvas.SetPos(tmpX, tmpY);
    // Canvas.SetDrawColor(10,10,10,155);
     Canvas.DrawColor=default.BGColor;
     if(default.bDrawIcons)
     {
         Canvas.DrawTileStretched(material'Engine.WhiteTexture',wepIconOffset+iconScale*40.0, numPlayers*(strLenY+strLenY2)+24.0*iconScale);

     // Draw Health/Armor Icons
     Canvas.SetPos((tmpX+HealthOffset + tmpX+armorOffSet-24.0*iconScale)/2, tmpY);
     Canvas.SetDrawColor(255,255,255,255);
     Canvas.DrawTile(material'HudContent.Generic.Hud',24*iconScale,24*iconScale,75,167,48,48);

     Canvas.SetPos((tmpX+ArmorOffset + tmpX+WepIconOffSet-24.0*iconScale)/2, tmpY);
     Canvas.DrawTile(material'HudContent.Generic.Hud',24*iconScale,25*iconScale,1,248,66,66);
     tmpY+=24.0*iconScale;
     }
     else
        Canvas.DrawTileStretched(material'Engine.WhiteTexture',wepIconOffset+iconScale*40.0, numPlayers*(strLenY+strLenY2));
    DrawPlayerNames(uPRI, Canvas);
    DrawHealth(uPRI, Canvas);
    drawArmor(uPRI, Canvas);
    drawIcons(uPRI, Canvas);
    DrawLocation(uPRI, Canvas);
}

function bool GetNewNetEnabled()
{
    local UTComp_ServerReplicationInfo SRI;

    foreach ViewportOwner.Actor.DynamicActors(class'UTComp_ServerReplicationInfo', SRI)
        break;
    if(SRI==None)
        return false;
    return SRI.bEnableEnhancedNetCode;

}

function string MakeColorCode(color aColor)
{
   return chr(0x1b)$chr(Max(aColor.R, 1))$chr(Max(aColor.G, 1))$chr(Max(aColor.B, 1));
}

function DrawPlayerNames(utcomp_PRI uPRI, Canvas Canvas)
{
  local int i;
  local float oldClipX;
  local float lenX, lenY;

  oldClipX=Canvas.ClipX;
  Canvas.ClipX=tmpX+Healthoffset;
    for(i=0; i<8; i++)
    {
      if(uPRI.OverlayInfo[i].PRI==None)
         break;
         if (uPRI.OverlayInfo[i].PRI.HasFlag!=None || (uPRI.OverlayInfo[i].PRI.Team!=None && (GRI!=None && GRI.FlagHolder[uPRI.OverlayInfo[i].PRI.Team.TeamIndex] == uPRI.OverlayInfo[i].PRI)))
         {
             Canvas.SetDrawColor(255,255,0);
          }
          else if(uPRI.bHasDD[i]==1)
          {
               Canvas.SetDrawColor(255,0,255);
          }
          else
              Canvas.DrawColor=default.InfoTextColor;
        Canvas.StrLen(uPRI.OverlayInfo[i].PRI.PlayerName, lenX, lenY);
        if(LenX>HealthOffset-tmpX)
            Canvas.Font=LocationFont;
        else
            Canvas.Font=InfoFont;
        Canvas.SetPos(tmpX,tmpY+(strLenY+strLenY2)*i);
        Canvas.DrawTextClipped(uPRI.OverlayInfo[i].PRI.PlayerName);
    }
    Canvas.ClipX=oldClipX;
}

function DrawHealth(utcomp_PRI uPRI, Canvas Canvas)
{
    local int i;
    Canvas.Font=InfoFont;
    for(i=0; i<8; i++)
    {
        if(uPRI.OverlayInfo[i].PRI==None)
            return;
        if(uPRI.OverlayInfo[i].Health>=100)
            Canvas.SetDrawColor(0,255,0,255);
        else if(uPRI.OverlayInfo[i].Health>=45 && uPRI.OverlayInfo[i].Health<100)
            Canvas.SetDrawColor(255,255,0,255);
        else if(uPRI.OverlayInfo[i].Health<45)
             Canvas.SetDrawColor(255,0,0,255);
        if(uPRI.OverlayInfo[i].Health<1000)
            Canvas.DrawTextJustified(uPRI.OverlayInfo[i].Health, 1, tmpX+HealthOffset, tmpY+(strLenY+strLenY2)*i, tmpX+ArmorOffset, tmpY+strLenY*(i+1)+strLenY2*i);
        else
            Canvas.DrawTextJustified(Left(String(uPRI.OverlayInfo[i].Health), Len(uPRI.OverlayInfo[i].Health)-3)$"K", 1, tmpX+HealthOffset, tmpY+(strLenY+strLenY2)*i, tmpX+ArmorOffset, tmpY+strLenY*(i+1)+strLenY2*i);
    }
}

function DrawArmor(utcomp_PRI uPRI, Canvas Canvas)
{
    local int i;
    Canvas.SetDrawColor(255,255,255,255);
    for(i=0; i<8; i++)
    {
        if(uPRI.OverlayInfo[i].PRI==None)
            return;
        Canvas.DrawTextJustified(uPRI.OverlayInfo[i].Armor, 1, tmpX+armorOffset, tmpY+(strLenY+strLenY2)*i, tmpX+wepIconOffset, tmpY+strLenY*(i+1)+strLenY2*i);
    }
}


function DrawIcons(utcomp_PRI uPRI, Canvas Canvas)
{
    local int i;
    local texture wepIcon;

    Canvas.SetDrawColor(255,255,255,255);

    for(i=0; i<8; i++)
    {
        if(uPRI.OverlayInfo[i].PRI==None)
            break;
          switch(uPRI.OverlayInfo[i].Weapon)
          {
          case 1:
              wepicon=texture'shieldIcon'; break;
          Case 2:
              wepicon=texture'AssaultIcon'; break;
          Case 3:
              wepicon=texture'BioIcon';break;
          Case 4:
              wepicon=texture'ShockIcon'; break;
          Case 5:
              wepicon=texture'LinkIcon'; break;
          Case 6:
              wepicon=texture'MiniIcon';break;
          Case 7:
              wepicon=texture'FlakIcon';break;
          Case 8:
              wepicon=texture'RocketIcon'; break;
          Case 9:
              wepicon=texture'LightningIcon'; break;
          Case 10:
              wepicon=texture'SniperIcon'; break;
          Case 11:
              wepicon=texture'DualARIcon';break;
          Case 12:
              wepicon=texture'SpiderIcon';break;
          Case 13:
              wepicon=texture'GrenadeIcon';break;
          Case 14:
              wepicon=texture'AvrilIcon';break;
          Case 15:
              wepicon=texture'RedeemerIcon';break;
          Case 16:
              wepicon=texture'PainterIcon';break;
          Case 17:
              wepicon=texture'translocicon';break;
          Case 21:
              wepicon=texture'MantaIcon'; break;
          Case 22:
              wepicon=texture'GoliathIcon'; break;
          Case 23:
              wepicon=texture'ScorpionIcon'; break;
          Case 24:
              wepicon=texture'HellbenderIcon'; break;
          Case 25:
              wepicon=texture'LeviathanIcon'; break;
          Case 26:
              wepicon=texture'RaptorIcon'; break;
          case 27:
              wepicon=texture'CicadaIcon'; break;
          case 28:
              wepicon=texture'PaladinIcon'; break;
          case 29:
              wepicon=texture'SPMAIcon'; break;
          default:
              wepicon=None;
          }

        if(wepicon!=None)
        {
            Canvas.SetPos(tmpX+wepiconOffset, tmpY+(strLenY+strLenY2)*i);
            Canvas.DrawIcon(wepIcon, iconScale);
        }
    }
/*    for(i=0; i<8; i++)
    {
      if(uPRI.OverlayInfo[i].PRI==None)
         break;
      if (uPRI.OverlayInfo[i].PRI.HasFlag!=None || GRI.FlagHolder[uPRI.OverlayInfo[i].PRI.Team.TeamIndex] == uPRI.OverlayInfo[i].PRI)
      {
         Canvas.SetPos(TMPX+WepIconOffset+40.0*iconScale, tmpY+((strLenY2+strLenY)*i));
         Canvas.DrawTile(Texture'S_FlagIcon',46.0*IconScale,32.0*IconScale,0.0,0.0,90.0,64.0);
      }
      else if(uPRI.HasDD==i+1 && uPRI.HasDD<9)
      {
        Canvas.SetPos(TMPX+WepIconOffset+40.0*iconScale, tmpY+((strLenY2+strLenY)*i));
        Canvas.DrawTile(Texture'HUD',32.0*IconScale,32.0*IconScale,0.0,164.0,78.0,78.0);
      }
    }    */
}

function DrawLocation(utcomp_PRI uPRI, Canvas Canvas)
{
    local int i;
    local float oldClipX;
    //Canvas.SetDrawColor(255,150,0,255);
    Canvas.DrawColor=default.LocTextColor;
    Canvas.Font=LocationFont;
    OldClipX=Canvas.ClipX;
    Canvas.ClipX=tmpX+wepiconOffset+40.0*iconScale;
    for(i=0; i<8; i++)
    {
        if(uPRI.OverlayInfo[i].PRI==None)
            break;
        Canvas.SetPos(tmpX,tmpY+strLenY*(i+1)+strLenY2*i);
        Canvas.DrawTextClipped(uPRI.OverlayInfo[i].PRI.GetLocationName());
    }
    Canvas.ClipX=OldClipX;
}

function GetFonts(Canvas Canvas)
{
       InfoFont = GetFont(AutoPickFont((Canvas.SizeX),default.theFontSize),1);
       LocationFont = GetFont(AutoPickFont((Canvas.SizeX),default.theFontSize-1), 1);
}

// Picks an appropriate font based on ScrWidth
simulated function string AutoPickFont(int ScrWidth, int SizeModifier)
{
     local string FontArrayNames[9];
     local int FontScreenWidthMedium[9], counter, recommendedfont;

     // ScreenWidths to look at
     FontScreenWidthMedium[0]=2048;
     FontScreenWidthMedium[1]=1600;
     FontScreenWidthMedium[2]=1280;
     FontScreenWidthMedium[3]=1024;
     FontScreenWidthMedium[4]=800;
     FontScreenWidthMedium[5]=640;
     FontScreenWidthMedium[6]=512;
     FontScreenWidthMedium[7]=400;
     FontScreenWidthMedium[8]=320;

     FontArrayNames[0]="2K4Fonts.Verdana34";
     FontArrayNames[1]="2K4Fonts.Verdana28";
     FontArrayNames[2]="2K4Fonts.Verdana24";
     FontArrayNames[3]="2K4Fonts.Verdana20";
     FontArrayNames[4]="2K4Fonts.Verdana16";
     FontArrayNames[5]="2K4Fonts.Verdana14";
     FontArrayNames[6]="2K4Fonts.Verdana12";
     FontArrayNames[7]="2K4Fonts.Verdana8";
     FontArrayNames[8]="2K4Fonts.FontSmallText";

     for(counter=0;counter<=8;counter++)
     {
         if(FontScreenWidthMedium[counter] >= ScrWidth)
         {
             recommendedfont = clamp((counter - SizeModifier), 0,8);
         }
     }

     if(recommendedfont == 9)
        log ("Font selection error");
     if(recommendedFont<8)
       BiggerFont=True;
     else
       BiggerFont=False;
     return FontArrayNames[recommendedfont];
}

simulated function Font GetFont(string FontClassName, float ResX)
{
    local Font fnt;

    fnt = GetGUIFont(FontClassName, ResX);
    if ( fnt == None )
        fnt = Font(DynamicLoadObject(FontClassName, class'Font'));

    if ( fnt == None )
        log(Name$" - FONT NOT FOUND '"$FontClassName$"'",'Error');

    return fnt;
}

// Copied from XInterface.DrawOpBase
simulated function Font GetGUIFont( string FontClassName, float ResX )
{
local class<GUIFont>    FntCls;
local GUIFont Fnt;

    FntCls = class<GUIFont>(DynamicLoadObject(FontClassName, class'Class',True));
    if (FntCls != None)
        Fnt = new(None) FntCls;

    if ( Fnt == None )
        return None;

    return Fnt.GetFont(ResX);
}

function string GetLocation(vector tempLoc, playerreplicationinfo PRI)
{
   return "";
}

function bool MapIsSupported()
{
  return true;
}

function GetLocClass()
{
}

function string GetClosestLocName(vector tempLoc)
{
  return "";
}

function string GetDebugLoc(vector tempLoc)
{
  return "";
}

defaultproperties
{
     DesiredOnJoinMessageTime=6.000000
     OverlayEnabled=True
     bDrawIcons=True
     VertPosition=0.070000
     HorizPosition=0.003000
     BGColor=(B=10,G=10,R=10,A=155)
     InfoTextColor=(B=255,G=255,R=255,A=255)
     LocTextColor=(B=155,G=155,R=155,A=255)
     theFontSize=-5
     bVisible=True
}
