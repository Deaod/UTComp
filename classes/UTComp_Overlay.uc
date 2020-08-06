

//-----------------------------------------------------------
// Part of TeamOverlay by Adam 'Heywood' Booth - heywood@malevolence.com.au
// altered/recoded by Aaron 'Lotus' Everitt for use in UTComp
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
var int oldscreenwidth, oldScreenHeight, oldfontsize;
var float currentX, currentY, strlenX, strlenY, strLenLocationX, strLenLocationY, strlenX3, strlenY3, iconscale;
var float OnJoinMessageDrawTime;
var config float DesiredOnJoinMessageTime;

var config bool OverlayEnabled, PowerupOverlayEnabled, bDrawIcons;
var bool BiggerFont;

var vector savedLocation[8];
var string printLocation[8];

var config float VertPosition, HorizPosition;

var config Color BGColor, BGColorBlue, BGColorRed, InfoTextColor, LocTextColor;
var config int theFontSize;

var LevelInfo Level;

var float PowerupIconOffset;
var float PowerupCountdownOffset;

var config bool bAlwaysShowPowerups;
var BS_xPlayer PC;
var UTComp_PRI uPRI;
var PlayerReplicationInfo PRI;
var int numPlayersRed;
var int numPlayersBlue;
var int numPowerups;

var Texture MouseCursorTexture;
var float MousePosX, MousePosY;


event NotifyLevelChange()
{
        Master.RemoveInteraction(self);
}

event Initialized()
{
    foreach ViewportOwner.Actor.DynamicActors(class'GameReplicationInfo', GRI)
        If (GRI != None)
            Break;

    Level = ViewPortOwner.Actor.Level;
    PC = BS_xPlayer(ViewportOwner.Actor);
    uPRI = PC.UTCompPRI;
    PRI = PC.PlayerReplicationInfo;

    OnJoinMessageDrawTime=Level.TimeSeconds+default.DesiredOnJoinMessageTime;
}

function float GetWeaponIconWidth()
{
  return 40 * iconScale;
}

function float GetHeaderIconHeight()
{
  return 24.0*iconScale;
}

function float GetHeaderIconWidth()
{
  return 24.0*iconScale;
}

function float GetBoxWidth()
{
  return wepIconOffset + GetWeaponIconWidth();
}

function float GetBoxHeight(int numPlayers)
{
  local float height;
  height = numPlayers * (strLenY+strLenLocationY);

  if (default.bDrawIcons)
    height += GetHeaderIconHeight();

    return height;
}

/*  If we click on a player or powerup, spectates that player/powerup */
function Click()
{
  local float boxPositionX, boxPositionY, boxWidth, boxHeight;
  local float playerIndex;

  boxPositionX = GetRedBoxPositionX();
  boxPositionY = GetRedBoxPositionY();
  boxWidth = GetBoxWidth();
  boxHeight = GetBoxHeight(numPlayersRed);



  if (boxPositionX <= MousePosX && MousePosX <= (boxPositionX+boxWidth) && boxPositionY <= MousePosY && MousePosY <= (boxPositionY+boxHeight))
  {
    if (bDrawIcons)
      playerIndex = Int((MousePosY - boxPositionY - GetHeaderIconHeight()) /  (strLenY + strLenLocationY));
    else
      playerIndex = Int((MousePosY - boxPositionY) /  (strLenY + strLenLocationY));

    if (playerIndex >= 0 && playerIndex < 8 && uPRI.OverlayInfoRed[playerIndex].PRI != None)
    {
      PC.ServerGoToTarget(uPRI.OverlayInfoRed[playerIndex].PRI);
      return;
    }
  }

  boxPositionX = GetBlueBoxPositionX();
  boxPositionY = GetBlueBoxPositionY();
  boxWidth = GetBoxWidth();
  boxHeight = GetBoxHeight(numPlayersBlue);

  if (boxPositionX <= MousePosX && MousePosX <= (boxPositionX+boxWidth) && boxPositionY <= MousePosY && MousePosY <= (boxPositionY+boxHeight))
  {
    if (bDrawIcons)
      playerIndex = Int((MousePosY - boxPositionY - GetHeaderIconHeight()) /  (strLenY + strLenLocationY));
    else
      playerIndex = Int((MousePosY - boxPositionY) /  (strLenY + strLenLocationY));

    if (playerIndex >= 0 && playerIndex < 8 && uPRI.OverlayInfoBlue[playerIndex].PRI != None)
    {
      PC.ServerGoToTarget(uPRI.OverlayInfoBlue[playerIndex].PRI);
      return;
    }
  }

  boxPositionX = GetPowerupBoxPositionX();
  boxPositionY = GetPowerupBoxPositionY();
  boxWidth = GetPowerupBoxWidth();
  boxHeight = GetPowerupBoxHeight();

  if (boxPositionX <= MousePosX && MousePosX <= (boxPositionX+boxWidth) && boxPositionY <= MousePosY && MousePosY <= (boxPositionY+boxHeight))
  {
    playerIndex = Int((MousePosY - boxPositionY) /  (strLenY + strLenLocationY));

    if (playerIndex >= 0 && playerIndex < 8 && uPRI.PowerupInfo[playerIndex].Pickup != None)
    {
      PC.ServerGoToTarget(uPRI.PowerupInfo[playerIndex].Pickup);
      return;
    }
  }


}

function DrawBackground(Canvas canvas, int numPlayers, int team)
{
  local float boxSizeX;
  local float boxSizeY;
  local float iconHeight;

  Canvas.Style = 5;
  Canvas.SetPos(currentX, currentY);
  if (team == 0)
    Canvas.DrawColor = BGColorRed;
  else
    Canvas.DrawColor = BGColorBlue;
  boxSizeX = GetBoxWidth();
  boxSizeY = GetBoxHeight(numPlayers);

  Canvas.DrawTileStretched(material'Engine.WhiteTexture', boxSizeX, boxSizeY);

  if (default.bDrawIcons)
  {
    iconHeight = GetHeaderIconHeight();

    Canvas.SetDrawColor(255, 255, 255, 255);

    // Health Icon
    Canvas.SetPos(currentX+HealthOffset + ((ArmorOffset-HealthOffset-GetHeaderIconWidth()) / 2), currentY);
    Canvas.DrawTile(material'HudContent.Generic.Hud',iconHeight,iconHeight,75,167,48,48);

    // Armor Icon
    Canvas.SetPos(currentX+ArmorOffset + ((wepIconOffset-ArmorOffset-GetHeaderIconWidth()) / 2), currentY);
    Canvas.DrawTile(material'HudContent.Generic.Hud',iconHeight,iconHeight,1,248,66,66);

    currentY += GetHeaderIconHeight();
  }
}

function DrawWelcomeBanner(Canvas canvas)
{
  Canvas.SetPos(currentX, currentY);
  Canvas.Style=5;
  Canvas.DrawColor=BGColor;
  Canvas.Font=GetFont(AutoPickFont(Canvas.SizeX, -3), 1);
  Canvas.StrLen("This server is running", StrLenX3, StrLenY3);
  if(GetNewNetEnabled())
     Canvas.DrawTileStretched(material'Engine.WhiteTexture',StrLenX3+5.0, 8*(StrLenY3));
  else
     Canvas.DrawTileStretched(material'Engine.WhiteTexture',StrLenX3+5.0, 6*(StrLenY3));
  Canvas.SetPos(currentX, currentY);
  Canvas.DrawColor=InfoTextColor;
  Canvas.DrawText("This server is running");
  Canvas.StrLen("W", StrLenX3, StrLenY3);
  Canvas.SetPos(currentX, currentY+1*(StrLenY3+2.0));
  Canvas.DrawText("UTComp "$MakeColorCode(class'Hud'.Default.GoldColor)$class'MutUTComp'.default.FriendlyVersionNumber$MakeColorCode(InfoTextColor)$".");
  Canvas.SetPos(currentX, currentY+3*(StrLenY3+2.0));
  Canvas.DrawText("Press "$MakeColorCode(class'Hud'.Default.GoldColor)$class'GameInfo'.Static.GetKeyBindName("mymenu", PC)$MakeColorCode(InfoTextColor)$" to change");
  Canvas.SetPos(currentX, currentY+4*(StrLenY3+2.0));
  Canvas.DrawText("your settings");
  if(GetNewNetEnabled())
  {
     Canvas.SetPos(currentX, currentY+5*(StrLenY3+2.0));
     Canvas.DrawText("Enh. Net:"@MakeColorCode(class'Hud'.Default.GoldColor)$"Enabled"$MakeColorCode(InfoTextColor)$".");
  }
}

function float GetRedBoxPositionX()
{
  return OldScreenWidth*default.HorizPosition;//0.003;
}

function float GetRedBoxPositionY()
{
  return OldScreenHeight*default.VertPosition;//0.07;
}

function float GetBlueBoxPositionX()
{
  return OldScreenWidth - OldScreenWidth*default.HorizPosition - GetBoxWidth();//0.003;
}

function float GetBlueBoxPositionY()
{
  return OldScreenHeight*default.VertPosition;//0.07;
}

function PostRender( canvas Canvas )
{
   local int i, numplayers;

   if (uPRI == None)
   {
    // Tried to put that in event Initialized, but it didn't work. Maybe the replicationinfo are not created yet?
    uPRI = PC.UTCompPRI;
    PRI = PC.PlayerReplicationInfo;
   }

   if (uPRI==None || ViewportOwner.Actor.myHUD.bShowScoreBoard || ViewportOwner.Actor.myHUD.bShowLocalStats || !default.OverlayEnabled)
       return;

  // iconScale=Canvas.ClipX/1280.0;
   if((Canvas.SizeX != OldScreenWidth) || (Canvas.SizeY != OldScreenHeight) || infoFont==None || locationFont==None || oldFontSize != default.theFontSize)
   {
       GetFonts(Canvas);
       oldFontSize=default.TheFontSize;
       OldScreenWidth=Canvas.SizeX;
       OldScreenHeight=Canvas.SizeY;
       Canvas.Font=infoFont;
       Canvas.StrLen("X", strlenx, strleny);
       Canvas.Font=LocationFont;
       Canvas.StrLen("X", strLenLocationX, strLenLocationY);
       iconScale=strLenY/16.0;
       if(BiggerFont)
       {
           HealthOffset=10*strlenX;
           ArmorOffset=14*strlenX;
           wepiconOffset=18*strLenX;

           PowerupIconOffset = strLenX;
           PowerupCountdownOffset = 5*strLenX;
       }
       else
       {
           HealthOffset=15*strlenX;
           ArmorOffset=19*strlenX;
           wepiconOffset=23*strLenX;

           PowerupIconOffset = strLenX;
           PowerupCountdownOffset = 10*strLenX;
  /*     HealthOffset=Canvas.ClipX*0.16;
       armorOffset=Canvas.ClipX*0.20;
       wepiconOffset=Canvas.ClipX*0.24;  */
       }
   }

   currentX = GetRedBoxPositionX();
   currentY = GetRedBoxPositionY();

   if(ViewPortOwner.Actor.Level.TimeSeconds<OnJoinMessageDrawTime)
   {
      DrawWelcomeBanner(Canvas);
      return;
   }

   if ((PRI.Team != None && PRI.Team.TeamIndex == 0) || (PRI.bOnlySpectator && (uPRI.CoachTeam == 255 || uPRI.CoachTeam == 0)))
       {
    for (i = 0; i < 8; i++)
    {
      if (uPRI.OverlayInfoRed[i].PRI != None)
        numPlayers++;
       }

    numPlayersRed = numPlayers;

    if (numPlayers > 0)
    {
      DrawBackground(Canvas, numPlayers, 0);
      DrawPlayerNames(Canvas, uPRI, 0);
      DrawHealth(Canvas, uPRI, 0);
      DrawArmor(Canvas, uPRI, 0);
      DrawIcons(Canvas, uPRI, 0);
      DrawLocation(Canvas, uPRI, 0);
    }

    //Switch to the other side in case we have to draw the blue team, in spec mode.
    currentX = GetBlueBoxPositionX();
    currentY = GetBlueBoxPositionY();
   }

  if ((PRI.Team != None && PRI.Team.TeamIndex == 1) || (PRI.bOnlySpectator && (uPRI.CoachTeam == 255 || uPRI.CoachTeam == 1)))
  {

    numPlayers = 0;
    for (i = 0; i < 8; i++)
    {
      if (uPRI.OverlayInfoBlue[i].PRI != None)
           numPlayers++;
    }

    numPlayersBlue = numPlayers;
    if (numPlayers > 0)
     {
      DrawBackground(Canvas, numPlayers, 1);
      DrawPlayerNames(Canvas, uPRI, 1);
      DrawHealth(Canvas, uPRI, 1);
      DrawArmor(Canvas, uPRI, 1);
      DrawIcons(Canvas, uPRI, 1);
      DrawLocation(Canvas, uPRI, 1);
    }
  }

  DrawPowerups(Canvas, PRI);

  PC.LastHUDSizeX = Canvas.SizeX;
  PC.LastHUDSizeY = Canvas.SizeY;

  if (PC.IsInState('PlayerMousing'))
     DrawMouseCursor(Canvas);
}

function string GetFriendlyPowerupName(Pickup pickup, int team)
{
  local string friendlyName;
  if (team == 0)
    friendlyName = "RED ";
  else if (team == 1)
    friendlyName = "BLUE ";
  else
    friendlyName = "MID ";

//if (bickupBase.PowerUp == class'XPickups.SuperShieldPack' || bickupBase.PowerUp == class'XPickups.SuperHealthPack' || bickupBase.PowerUp == class'XPickups.UDamagePack')
  if (pickup.IsA('UDamagePack'))
    friendlyName = friendlyName$"Amp";
  else if (pickup.IsA('SuperHealthPack'))
    friendlyName = friendlyName$"Keg";
  else if (pickup.IsA('SuperShieldPack'))
    friendlyName = friendlyName$"100";

  return friendlyName;
}

simulated function String FormatTime( int Seconds )
{
    local int Minutes, Hours;
    local String Time;

    if (Seconds <= 0)
      return "UP!";

    if( Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

        Time = Hours$":";
     }
  Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    if( Minutes >= 10 )
        Time = Time $ Minutes $ ":";
    else
        Time = Time $ "0" $ Minutes $ ":";

    if( Seconds >= 10 )
        Time = Time $ Seconds;
     else
        Time = Time $ "0" $ Seconds;

    return Time;
}

function float GetPowerupIconHeight()
{
  return 24.0*iconScale;
}

function float GetPowerupBoxWidth()
{
  return PowerupCountdownOffset + 9*strLenLocationX;
}

function float GetPowerupBoxHeight()
{
  return numPowerups * (strLenY+strLenLocationY);
}

function float GetPowerupBoxPositionY()
{
  return OldScreenHeight * 0.45;//0.07;
}

function float GetPowerupBoxPositionX()
{
  return OldScreenWidth * default.HorizPosition;//0.003;
}

function DrawPowerups(Canvas canvas, PlayerReplicationInfo PRI)
{
  local int i;
  local float nextRespawn;
  local float iconHeight;

  if (PC.uWarmup.bInWarmup || !PRI.bOnlySpectator || PC.IsCoaching() || !default.PowerupOverlayEnabled)
    return;

  iconHeight = GetPowerupIconHeight();

  numPowerups = 0;
  for (i = 0; i < 8; i++)
  {
    if (uPRI.PowerupInfo[i].Pickup == None)
      break;
    numPowerups++;
  }

  Canvas.DrawColor = BGColor;
  currentX = GetPowerupBoxPositionX();
  currentY = GetPowerupBoxPositionY();

  Canvas.SetPos(currentX, currentY);
  Canvas.DrawTileStretched(material'Engine.WhiteTexture', GetPowerupBoxWidth(), GetPowerupBoxHeight());

  Canvas.DrawColor = default.InfoTextColor;

  for (i = 0; i < 8; i++)
  {
    if (uPRI.PowerupInfo[i].Pickup == None)
      break;

    nextRespawn = (uPRI.PowerupInfo[i].NextRespawnTime - Level.GRI.ElapsedTime) / Level.TimeDilation;

    if (!bAlwaysShowPowerups && nextRespawn > 10)
      break;

    Canvas.Font = LocationFont;

    // Icon
    Canvas.SetPos(currentX + PowerupIconOffset, currentY);
    if (uPRI.PowerupInfo[i].Pickup.IsA('UDamagePack'))
      Canvas.DrawTile(material'HudContent.Generic.Hud',iconHeight,iconHeight,0,164,73,82);
    else if (uPRI.PowerupInfo[i].Pickup.IsA('SuperShieldPack'))
      Canvas.DrawTile(material'HudContent.Generic.Hud',iconHeight,iconHeight,1,248,66,66);
    else if (uPRI.PowerupInfo[i].Pickup.IsA('SuperHealthPack'))
      Canvas.DrawTile(material'HudContent.Generic.Hud',iconHeight,iconHeight,75,167,48,48);

    // Name + location
    Canvas.SetPos(currentX + PowerupCountdownOffset, currentY+strLenLocationY);
    Canvas.DrawText(GetFriendlyPowerupName(uPRI.PowerupInfo[i].Pickup, uPRI.PowerupInfo[i].Team));

    // Countdown
    Canvas.Font = InfoFont;
    Canvas.SetPos(currentX + PowerupCountdownOffset, currentY);
    Canvas.DrawText(FormatTime(nextRespawn));

    currentY += strLenLocationY + strLenY;
  }
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

function GetPlayerNameInfo(UTComp_PRI uPRI, int index, int team, out PlayerReplicationInfo PRI, out byte hasFlag, out byte hasDD)
{
  hasFlag = 0;
  hasDD = 0;

  if (team == 0)
  {
    PRI = uPRI.OverlayInfoRed[index].PRI;
    hasDD = uPRI.bHasDDRed[index];
  }
  else
  {
    PRI = uPRI.OverlayInfoBlue[index].PRI;
    hasDD = uPRI.bHasDDBlue[index];
  }

  if (PRI != None)
  {
    if (PRI.HasFlag != None || (PRI.Team != None && (GRI != None && GRI.FlagHolder[PRI.Team.TeamIndex] == PRI)))
      hasFlag = 1;
  }
}

function DrawPlayerNames(Canvas Canvas, UTComp_PRI uPRI, int team)
{
  local int i;
  local float oldClipX;
  local float lenX, lenY;

  local PlayerReplicationInfo oPRI;
  local byte hasFlag;
  local byte hasDD;

  oldClipX = Canvas.ClipX;
  Canvas.ClipX = currentX + Healthoffset;

  Canvas.Font = infoFont;

  for (i = 0; i < 8; i++)
  {
    GetPlayerNameInfo(uPRI, i, team, oPRI, hasFlag, hasDD);

    if (oPRI==None)
      break;

    if (hasFlag == 1)
      Canvas.SetDrawColor(255,255,0);
    else if (hasDD == 1)
      Canvas.SetDrawColor(255,0,255);
    else
      Canvas.DrawColor = default.InfoTextColor;

    Canvas.StrLen(oPRI.PlayerName, lenX, lenY);

    // Name too big!
    if (lenX > HealthOffset)
      Canvas.Font = LocationFont;
    else
      Canvas.Font = InfoFont;

    Canvas.SetPos(currentX, currentY + (strLenY + strLenLocationY) * i);
    Canvas.DrawTextClipped(oPRI.PlayerName);
  }

  Canvas.ClipX = oldClipX;
}

function GetHealthInfo(UTComp_PRI uPRI, int index, int team, out PlayerReplicationInfo PRI, out int health)
{
  if (team == 0)
          {
    PRI = uPRI.OverlayInfoRed[index].PRI;
    health = uPRI.OverlayInfoRed[index].Health;
          }
          else
  {
    PRI = uPRI.OverlayInfoBlue[index].PRI;
    health = uPRI.OverlayInfoBlue[index].Health;
    }
}

function DrawHealth(Canvas Canvas, UTComp_PRI uPRI, int team)
{
  local int i;
  local int health;
  local PlayerReplicationInfo oPRI;

  Canvas.Font = InfoFont;

  for (i = 0; i < 8; i++)
  {
    GetHealthInfo(uPRI, i, team, oPRI, health);

    if (oPRI == None)
      return;
    if (Health >= 100)
      Canvas.SetDrawColor(0,255,0,255);
    else if (Health >= 45 && Health < 100)
      Canvas.SetDrawColor(255,255,0,255);
    else if (Health < 45)
      Canvas.SetDrawColor(255,0,0,255);
    if (Health < 1000)
      Canvas.DrawTextJustified(Health, 1, currentX+HealthOffset, currentY+(strLenY+strLenLocationY)*i, currentX+ArmorOffset, currentY+strLenY*(i+1)+strLenLocationY*i);
    else
      Canvas.DrawTextJustified(Left(String(Health), Len(Health)-3)$"K", 1, currentX+HealthOffset, currentY+(strLenY+strLenLocationY)*i, currentX+ArmorOffset, currentY+strLenY*(i+1)+strLenLocationY*i);
  }
}

function GetArmorInfo(UTComp_PRI uPRI, int index, int team, out PlayerReplicationInfo PRI, out byte armor)
{
  if (team == 0)
    {
    PRI = uPRI.OverlayInfoRed[index].PRI;
    armor = uPRI.OverlayInfoRed[index].Armor;
  }
  else
  {
    PRI = uPRI.OverlayInfoBlue[index].PRI;
    armor = uPRI.OverlayInfoBlue[index].Armor;
    }
}

function DrawArmor(Canvas Canvas, UTComp_PRI uPRI, int team)
{
    local int i;
  local byte armor;
  local PlayerReplicationInfo oPRI;
    Canvas.SetDrawColor(255,255,255,255);
  for (i = 0; i < 8; i++)
    {
    GetArmorInfo(uPRI, i, team, oPRI, armor);
    if (oPRI == None)
      return;

    Canvas.DrawTextJustified(armor, 1, currentX+armorOffset, currentY+(strLenY+strLenLocationY)*i, currentX+wepIconOffset, currentY+strLenY*(i+1)+strLenLocationY*i);
  }
}

function Texture GetWeaponIcon(byte weapon)
{
    switch(weapon)
    {
        case 1:
            return texture'shieldIcon'; break;
        Case 2:
            return texture'AssaultIcon'; break;
        Case 3:
            return texture'BioIcon';break;
        Case 4:
            return texture'ShockIcon'; break;
        Case 5:
            return texture'LinkIcon'; break;
        Case 6:
            return texture'MiniIcon';break;
        Case 7:
            return texture'FlakIcon';break;
        Case 8:
            return texture'RocketIcon'; break;
        Case 9:
            return texture'LightningIcon'; break;
        Case 10:
            return texture'SniperIcon'; break;
        Case 11:
            return texture'DualARIcon';break;
        Case 12:
            return texture'SpiderIcon';break;
        Case 13:
            return texture'GrenadeIcon';break;
        Case 14:
            return texture'AvrilIcon';break;
        Case 15:
            return texture'RedeemerIcon';break;
        Case 16:
            return texture'PainterIcon';break;
        Case 17:
            return texture'translocicon';break;
        Case 21:
            return texture'MantaIcon'; break;
        Case 22:
            return texture'GoliathIcon'; break;
        Case 23:
            return texture'ScorpionIcon'; break;
        Case 24:
            return texture'HellbenderIcon'; break;
        Case 25:
            return texture'LeviathanIcon'; break;
        Case 26:
            return texture'RaptorIcon'; break;
        case 27:
            return texture'CicadaIcon'; break;
        case 28:
            return texture'PaladinIcon'; break;
        case 29:
            return texture'SPMAIcon'; break;
        default:
            return None;
    }
}

function GetWeaponInfo(UTComp_PRI uPRI, int index, int team, out PlayerReplicationInfo PRI, out byte weapon)
{
  if (team == 0)
        {
    PRI = uPRI.OverlayInfoRed[index].PRI;
    weapon = uPRI.OverlayInfoRed[index].Weapon;
        }
  else
  {
    PRI = uPRI.OverlayInfoBlue[index].PRI;
    weapon = uPRI.OverlayInfoBlue[index].Weapon;
    }
}


function DrawIcons(Canvas Canvas, UTComp_PRI uPRI, int team)
{
  local int i;
  local texture wepIcon;
  local PlayerReplicationInfo oPRI;
  local byte weapon;

  Canvas.SetDrawColor(255, 255, 255, 255);

  for (i = 0; i < 8; i++)
    {
    GetWeaponInfo(uPRI, i, team, oPRI, weapon);
    if (oPRI == None)
         break;

    wepIcon = GetWeaponIcon(weapon);

    if (wepicon!=None)
      {
      Canvas.SetPos(currentX+wepiconOffset, currentY+(strLenY+strLenLocationY)*i);
      Canvas.DrawIcon(wepIcon, iconScale);
      }
  }
}

function GetLocationInfo(UTComp_PRI uPRI, int index, int team, out PlayerReplicationInfo PRI)
{
  if (team == 0)
  {
    PRI = uPRI.OverlayInfoRed[index].PRI;
  }
  else
      {
    PRI = uPRI.OverlayInfoBlue[index].PRI;
      }
}

function DrawLocation(Canvas Canvas, UTComp_PRI uPRI, int team)
{
    local int i;
    local float oldClipX;
    local PlayerReplicationInfo oPRI;

    Canvas.DrawColor=default.LocTextColor;
    Canvas.Font=LocationFont;
    OldClipX=Canvas.ClipX;
    Canvas.ClipX=currentX+wepiconOffset+40.0*iconScale;
    for (i = 0; i < 8; i++)
    {
      GetLocationInfo(uPRI, i, team, oPRI);
      if(oPRI == None)
            break;

      Canvas.SetPos(currentX,currentY+strLenY*(i+1)+strLenLocationY*i);
      Canvas.DrawTextClipped(oPRI.GetLocationName());
    }

    Canvas.ClipX = OldClipX;
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


function DrawMouseCursor(Canvas C)
{
   C.SetDrawColor(255, 255, 255);
   C.Style = 5;

   // find position of cursor, and clamp it to screen
   MousePosX = PC.PlayerMouse.X + C.SizeX / 2.0;
   if (MousePosX < 0)
   {
      PC.PlayerMouse.X -= MousePosX;
      MousePosX = 0;
   }
   else if (MousePosX >= C.SizeX)
   {
      PC.PlayerMouse.X -= (MousePosX - C.SizeX);
      MousePosX = C.SizeX - 1;
   }
   MousePosY = PC.PlayerMouse.Y + C.SizeY / 2.0;
   if (MousePosY < 0)
   {
      PC.PlayerMouse.Y -= MousePosY;
      MousePosY = 0;
   }
   else if (MousePosY >= C.SizeY)
   {
      PC.PlayerMouse.Y -= (MousePosY - C.SizeY);
      MousePosY = C.SizeY - 1;
   }

   // render mouse cursor
   C.SetPos(MousePosX, MousePosY);
   C.DrawIcon(MouseCursorTexture, 1.0);

   return;
}

defaultproperties
{
     DesiredOnJoinMessageTime=6.000000
     OverlayEnabled=True
     PowerupOverlayEnabled=True
     bDrawIcons=True
     VertPosition=0.070000
     HorizPosition=0.003000
     BGColor=(B=10,G=10,R=10,A=155)
     BGColorRed=(B=0,G=0,R=50,A=155)
     BGColorBlue=(B=50,G=0,R=0,A=155)
     InfoTextColor=(B=255,G=255,R=255,A=255)
     LocTextColor=(B=155,G=155,R=155,A=255)
     MouseCursorTexture=Texture'2K4Menus.Cursors.Pointer'
     theFontSize=-5
     bVisible=True
     bAlwaysShowPowerups=True
}
