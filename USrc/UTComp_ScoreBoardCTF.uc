

class UTComp_ScoreBoardCTF extends UTComp_ScoreBoard;

#exec texture Import File=textures\UTCompLogo.TGA Name=UTCompLogo Mips=Off Alpha=1
#exec texture Import File=textures\forward_logo.dds name=ForwardLogo Mips=Off Alpha=1 LodSet=5
#exec texture Import File=textures\ScoreboardText.TGA Name=ScoreboardText Mips=Off Alpha=1

//font names and objects
var Font FontArrayFonts[9];
var localized string FontArrayNames[9];

//Font indices
var int FONT_PLAYER_PING;
var int FONT_PLAYER_PL;
var int FONT_PLAYER_LOCATION;
var int FONT_PLAYER_STAT_NUM;
var int FONT_PLAYER_STAT;
var int FONT_PLAYER_SCORE;
var int FONT_PLAYER_NAME;
var int FONT_TEAM_POWERUP_NUM;
var int FONT_TEAM_PING;
var int FONT_TEAM_PL;
var int FONT_TEAM_POWERUP_PER;
var int FONT_TEAM_SCORE;

//Stats stuff fore scoreboard layout
struct Stats
{
  var string name;
  var float nameW;
  var float nameH;
  var string value;
  var float valueW;
  var float valueH;
};

//Materials for backgrounds
var material TeamBoxMaterial;
var material TeamHeaderMaterial;

/*
 * Draw the map title, ie "Capture the Flag on Grendelkeep"
 */
function DrawMapTitle(Canvas Canvas)
{
  return; //fuck this who cares
  local string titlestring,scoreinfostring,RestartString;
  local float xl, yl, full, height, top, medH, smallH, titleXL, scoreInfoXL;

  Canvas.Font = HUDClass.static.GetMediumFontFor(Canvas);
  Canvas.StrLen("W",xl,medH);
  height = medH;
  Canvas.Font = HUDClass.static.GetConsoleFont(Canvas);
  Canvas.StrLen("W",xl,smallH);
  height += smallH;

  full = height;
  top  = Canvas.ClipY - 8 - full;

  titleString     = GetTitleString();
  scoreInfoString = GetDefaultScoreInfoString();

  Canvas.StrLen(titleString, titleXL, YL);
  Canvas.DrawColor = HUDClass.default.GoldColor;

  if (UnrealPlayer(Owner).bDisplayLoser)
  {
    ScoreInfoString = class'HUDBase'.default.YouveLostTheMatch;
  }
  else if (UnrealPlayer(Owner).bDisplayWinner)
  {
    ScoreInfoString = class'HUDBase'.default.YouveWonTheMatch;
  }
  else if (PlayerController(Owner).IsDead())
  {
    RestartString = GetRestartString();
    ScoreInfoString = RestartString;
  }

  Canvas.StrLen(scoreInfoString,scoreInfoXL,YL);

  Canvas.Font = NotReducedFont;
  Canvas.SetDrawColor(255,150,0,255);
  Canvas.StrLen(TitleString,TitleXL,YL);
  Canvas.SetPos( (Canvas.ClipX/2) - (TitleXL/2), Canvas.ClipY*0.03);
  Canvas.DrawText(TitleString);


  Canvas.Font = HUDClass.static.GetMediumFontFor(Canvas);
  Canvas.StrLen(ScoreInfoString,ScoreInfoXL,YL);
  Canvas.SetPos( (Canvas.ClipX/2) - (ScoreInfoXL/2), Top + (Full/2) - (YL/2));
  Canvas.DrawText(ScoreInfoString);
}

/*
 * Re-draw the scoreboard with updated data
 */
simulated event UpdateScoreBoard(Canvas C)
{
  local PlayerReplicationInfo PRI, OwnerPRI;
  local PlayerReplicationInfo RedPRI[MAXPLAYERS], BluePRI[MAXPLAYERS], SPecPRI[MAXPLAYERS];
  local int i, BluePlayerCount, RedPlayerCount, RedOwnerOffset, BlueOwnerOffset, maxTiles, numspecs;
  local float screenScale;
  local bool bOwnerDrawn;

  // Fonts
  mainFont         = HUDClass.static.GetMediumFontFor(C);
  notReducedFont   = GetSmallerFontFor(C,1);
  sortaReducedFont = GetSmallerFontFor(C,2);
  reducedFont      = GetSmallerFontFor(C,3);
  smallerFont      = GetSmallerFontFor(C,4);
  soTiny           = GetSmallerFontFor(C,5);
  maxTiles=8; //max players per team?


  FONT_PLAYER_PING      = 1;
  FONT_PLAYER_PL        = 1;
  FONT_PLAYER_LOCATION  = 4;
  FONT_PLAYER_STAT_NUM  = 1;
  FONT_PLAYER_STAT      = 1;
  FONT_PLAYER_SCORE     = 6;
  FONT_PLAYER_NAME      = 6;
  FONT_TEAM_POWERUP_NUM = 3;
  FONT_TEAM_PING        = 3;
  FONT_TEAM_PL          = 3;
  FONT_TEAM_POWERUP_PER = 5;
  FONT_TEAM_SCORE       = 7;



  if(Owner!=None)
  {
    OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
  }

  //Fill team PRI arrays

  //Red/Blue offsets are useless?
  RedOwnerOffset  = -1;
  BlueOwnerOffset = -1;

  for (i=0; i<GRI.PRIArray.Length; i++)
  {
    PRI = GRI.PRIArray[i];

    if(PRI.bOnlySpectator)
    {
      specPRI[numSpecs]=PRI;
      numSpecs++;
    }

    if ((!PRI.bOnlySpectator || PRI.bWaitingPlayer))
    {
      if (PRI.Team == None || PRI.Team.TeamIndex == 0)
      {
        if (RedPlayerCount < MAXPLAYERS)
        {
          RedPRI[RedPlayerCount] = PRI;

          if (PRI == OwnerPRI)
          {
            RedOwnerOffset = RedPlayerCount;
          }

          RedPlayerCount++;
        }
      }
      else
      {
        if (BluePlayerCount < MAXPLAYERS)
        {
          BluePRI[BluePlayerCount] = PRI;

          if (PRI == OwnerPRI)
          {
            BlueOwnerOffset = BluePlayerCount;
          }

          BluePlayerCount++;
        }
      }
    }
  }

  screenScale = C.ClipX/1920; //1920 as a base..go down from there. 1024x768 --> 1024/1920 = 0.533 etc

  //what the fuck?
  // C.FontScaleX = C.ClipX / 1920;
  // C.FontScaleY = C.ClipX / 1080;
  //DrawLogo(C, screenScale);
  //DrawMapTitle(C);

  DrawTeamHeader(C,0);
  DrawCTFTeamInfoBoxes(C, 0, RedPlayerCount);
  DrawTeamHeader(C,1);
  DrawCTFTeamInfoBoxes(C, 1, BluePlayerCount);

  C.SetDrawColor(255,255,255,255);

  if (((FPHTime == 0) || (!UnrealPlayer(Owner).bDisplayLoser && !UnrealPlayer(Owner).bDisplayWinner)) && (GRI.ElapsedTime > 0))
  {
    FPHTime = GRI.ElapsedTime;
  }

  for ( i=0; i<RedPlayerCount && i<maxTiles; i++ )
  {
    if(!redPRI[i].bOnlySpectator)
    {
      if(i==(maxTiles-1) && !bOwnerDrawn && OwnerPRI.Team != none && OwnerPRI.Team.TeamIndex==0 && !OwnerPRI.bOnlySpectator)
      {
        DrawPlayerInformation(C, OwnerPRI, 95, 185 + 85*i, screenScale);
      }
      else
      {
        DrawPlayerInformation(C, RedPRI[i], 95, 185 + 85*i, screenScale);
      }

      if (RedPRI[i]==OwnerPRI)
      {
        bOwnerDrawn=True;
      }
    }
  }

  for ( i=0; i<BluePlayerCount && i<maxTiles; i++ )
  {
    if(!BluePRI[i].bOnlySpectator)
    {
      if(i==(maxTiles-1) && !bOwnerDrawn && OwnerPRI.Team != none && OwnerPRI.Team.TeamIndex==1 && !OwnerPRI.bOnlySpectator)
      {
        DrawPlayerInformation(C, OwnerPRI, 985, 185 + 85*i, screenScale);
      }
      else
      {
        DrawPlayerInformation(C, BluePRI[i], 985, 185 + 85*i, screenScale);
      }

      if (BluePRI[i]==OwnerPRI)
      {
        bOwnerDrawn=True;
      }
    }
  }

  DrawStats(C);
  DrawPowerups(C);

  if(numSpecs>0)
  {
    //ArrangeSpecs(specPRI);
    for (i=0; i<numspecs && specPRI[i]!=None; i++)
    {
      DrawSpecs(C, SpecPRI[i], i);
    }

    DrawSpecs(C,None,i);
  }
}


/*
 * Draw the UTComp logo
 */
simulated function DrawLogo(Canvas C , float scale)
{
  // Border
	C.SetPos(0,0);
  C.Style=5;
  C.SetDrawColor(255,255,255,180);
  C.DrawTileStretched(TeamHeaderMaterial,C.ClipX,C.ClipY*0.066);

  // TCM Logo
  C.SetPos(0,0);

  C.DrawTile(material'UTCompLogo',(512*0.75)*Scale,(128*0.75)*Scale,0,0,256,64);
}

/*
 * Draw team header
 */

simulated function DrawTeamHeader(Canvas C, byte team)
{
  local float scoreWidth, scoreHeight;
  local float pingWidth, pingHeight;
  local float plWidth, plHeight;
  local float powerupPercentWidth, powerupPercentHeight;
  local float powerupNumWidth, powerupNumHeight;
  local float pingMaxWidth, pingMaxHeight;
  local float scoreX, scoreY;
  local float x_ping, x_pl;
  local int baseHeight, baseWidth, baseY, baseX;
  local int x;

  switch (team)
  {
    case 0:
      baseX = 95;
      break;
    case 1:
      baseX = 985;
      break;
    default:
  }

  baseHeight = 75;
  baseWidth  = 840;
  baseY      = 110;
  // redBaseX   = 95;  //95+840 width = 935, 960-935 = 25 (Gap to mid)
  // blueBaseX  = 985; //960 + 25 gap from mid

  //Turn on alpha for transparent fuckery
  C.Style = ERenderStyle.STY_Alpha;

  C.SetDrawColor(0,0,0,90);

  //Main header
  SetPosScaled(C, baseX, baseY);
  DrawTileStretchedScaled(C, TeamHeaderMaterial, baseWidth, baseHeight);

  //Score
  C.SetDrawColor(255, 255, 255, 255);
  C.Style = ERenderStyle.STY_Normal;
  C.Font = GetFontWithSize(FONT_TEAM_SCORE);

  C.StrLen(int(GRI.Teams[team].Score), scoreWidth, scoreHeight);

  switch (team)
  {
    case 0:
      scoreX = baseX + baseWidth - scoreWidth - 15;
      break;
    case 1:
      scoreX = baseX + 15;
      break;
    default:
  }

  scoreY = baseY - scoreHeight + (baseHeight + scoreHeight)/2;
  SetPosScaled(C, scoreX, scoreY);
  C.DrawText(int(GRI.Teams[team].Score));

  //Average ping/PL
  C.Font = GetFontWithSize(FONT_TEAM_PING);
  //STRLEN IS FUCKING STUPID
  C.StrLen("Ping", pingWidth, pingHeight);
  C.StrLen("PL", plWidth, plHeight);
  C.StrLen("Ping 999ms", pingMaxWidth, pingMaxHeight);

  switch (team)
  {
    case 0:
      x_ping = baseX + 20;
      x_pl = x_ping + pingWidth - plWidth;
      break;
    case 1:
      x_ping = baseX + baseWidth - pingMaxWidth;
      x_pl = x_ping + plWidth;
      break;
    default:
  }

  SetPosScaled(C, x_ping, baseY + (baseHeight - pingHeight - plHeight)/2);
  C.DrawText("Ping"@GetAverageTeamPing(team)$"ms");
  SetPosScaled(C, x_pl, baseY + pingHeight + (baseHeight - pingHeight - plHeight)/2);
  C.DrawText("PL"@GetAverageTeamPL(team)$"%");

  //Powerups/flag timing
  C.Font = GetFontWithSize(FONT_TEAM_POWERUP_PER);
  C.StrLen("100%", powerupPercentWidth, powerupPercentHeight);
  C.Font = GetFontWithSize(FONT_TEAM_POWERUP_NUM);
  C.StrLen("99", powerupNumWidth, powerupNumHeight);

  for (x = 0; x < 3; x++) {

    //TODO: scale icons by resolution
    //TODO: fix flag/clock so it doesnt look dumb + flag has some extra shit at top right
    switch (x)
    {
      case 0:
        SetPosScaled(C, baseX + pingMaxWidth - 64 + 100 + 200*x, baseY + (baseHeight - 64)/2);
        C.DrawTile(material'HudContent.Generic.Hud', 64, 64, 0, 164, 73, 82); //amp
        break;
      case 1:
        SetPosScaled(C, baseX + pingMaxWidth - 64 + 100 + 200*x, baseY + (baseHeight - 64)/2);
        C.DrawTile(material'HudContent.Generic.Hud', 64, 64, 1, 248, 64, 64); //100a
        break;
      case 2:
        SetPosScaled(C, baseX + pingMaxWidth - 64 + 100 + 200*x, baseY + 35); //clock is short, so move it down
        C.DrawTile(material'HudContent.Generic.Hud', 40, 40, 148, 354, 40, 40); //clock
        SetPosScaled(C, baseX + pingMaxWidth - 64 + 100 + 200*x, baseY + (baseHeight - 64)/2);
        C.DrawTile(material'HudContent.Generic.Hud', 64, 64, 338, 128, 56, 81); //flag
        break;
      default:

    }

    SetPosScaled(C, baseX + pingMaxWidth + 100 + 200*x, baseY + (baseHeight - powerupNumHeight - powerupPercentHeight)/2);
    C.Font = GetFontWithSize(FONT_TEAM_POWERUP_PER);
    C.DrawText("0%");

    SetPosScaled(C, baseX + pingMaxWidth + 100 + 200*x, baseY + powerupPercentHeight + (baseHeight - powerupNumHeight - powerupPercentHeight)/2);
    C.Font = GetFontWithSize(FONT_TEAM_POWERUP_NUM);
    C.DrawText("0");
  }
}

/*
 * Draw the background boxes for each player.
 */
simulated function DrawCTFTeamInfoBoxes(Canvas C, byte team, int playerCount)
{
  local int baseHeight, baseWidth, baseX, baseY;
  local int rVal, bVal;
  local int x;
  local int alpha;

  switch (team)
  {
    case 0:
      rVal = 255;
      bVal = 0;
      baseX = 95;
      break;
    case 1:
      rVal = 0;
      bVal = 255;
      baseX = 985;
    default:
  }

  baseHeight = 85;
  baseWidth  = 840;
  baseY      = 110+75; //offset+height of header

  C.Style = ERenderStyle.STY_Alpha;

  for (x = 0; x < playerCount; x++) {
    if (x % 2 == 0) {
      alpha = 64;
    } else {
      alpha = 84;
    }

    C.SetDrawColor(rVal, 0, bVal, alpha);

    SetPosScaled(C, baseX, baseY + x*baseHeight);
    DrawTileStretchedScaled(C, TeamBoxMaterial, baseWidth, baseHeight);
  }
}


/*
 * Score, Ping, PL, Name, and stats for a given player (PRI)
 */
simulated function DrawPlayerInformation(Canvas C, PlayerReplicationInfo PRI, float baseX, float baseY, float scale)
{
  local UTComp_PRI uPRI;
  local TeamPlayerReplicationInfo tPRI;
  local float scoreWidth, scoreHeight, maxScoreWidth;
  local float pingplWidth, pingplHeight;
  local float playerNameWidth, playerNameHeight;
  local int boxWidth, boxHeight;
  local string pingplString;
  local int count;
  local array<Stats> statsArray;
  local float longestOStatName, longestDStatName;
  local float statX;
  local Stats stat1, stat2, stat3, stat4, stat5, stat6;

  if (uWarmup == none)
    foreach dynamicActors(class'UTComp_Warmup', uWarmup)
      break;

  //TODO: Global this or something
  boxWidth  = 840;
  boxHeight = 85;

  uPRI = class'UTComp_Util'.static.GetUTCompPRI(PRI);
  tPRI = TeamPlayerReplicationInfo(PRI);

  //Ready/Not Ready
  if (uWarmup.bInWarmup) {
    if (!uPRI.bIsReady) {
      C.SetDrawColor(255, 0, 0, 255);
    } else {
      C.SetDrawColor(0, 255, 0, 255);
    }


    SetPosScaled(C, baseX + 20, baseY + (boxHeight - 64)/2);
    C.DrawTile(material'HudContent.Generic.Hud', 64, 64, 338, 128, 56, 81); //flag, tinted red (?)
    C.SetDrawColor(255, 255, 255, 255);
  }

  //Score and Ping/PL
  pingplString = string(PRI.Ping*4)$"ms\ "@string(PRI.PacketLoss)$"%";

  C.Font = GetFontWithSize(FONT_PLAYER_SCORE);
  C.StrLen(PRI.Score, scoreWidth, scoreHeight);
  C.StrLen("999", maxScoreWidth, scoreHeight);

  C.Font = GetFontWithSize(FONT_PLAYER_PING);
  C.StrLen(pingplString, pingplWidth, pingplHeight);

  if (!uWarmup.bInWarmup) {
  C.Font = GetFontWithSize(FONT_PLAYER_SCORE);
  SetPosScaled(C, baseX + 15, baseY + (boxHeight - scoreHeight - pingplHeight)/2);
  C.DrawText(int(PRI.Score));
  }

  C.Font = GetFontWithSize(FONT_PLAYER_PING);
  SetPosScaled(C, baseX + 15 + 3, baseY + scoreHeight + (boxHeight - scoreHeight - pingplHeight)/2);
  C.DrawText(pingplString);

  //Player Name
  C.Font = GetFontForPlayerName(PRI.PlayerName);
  C.StrLen(PRI.PlayerName, playerNameWidth, playerNameHeight);
  SetPosScaled(C, baseX + 40 + maxScoreWidth, baseY + (boxHeight - playerNameHeight)/2);
  if (uPRI.ColoredName == "") {
    C.DrawText(PRI.PlayerName);
  } else {
    C.DrawText(uPRI.ColoredName);
  }

  //Stats

  //TODO: LESS SHITTY PLZ
  statsArray[statsArray.Length] = stat1;
  statsArray[0].name = "Grabs";
  statsArray[0].value = uPRI.FlagGrabs@"("$uPRI.FlagPickups$")";

  statsArray[statsArray.Length] = stat2;
  statsArray[1].name = "Caps";
  statsArray[1].value = uPRI.FlagCaps@"("$uPRI.Assists$")";

  statsArray[statsArray.Length] = stat3;
  statsArray[2].name = "Covers";
  statsArray[2].value = string(uPRI.Covers);

  statsArray[statsArray.Length] = stat4;
  statsArray[3].name = "Flag Kills";
  statsArray[3].value = string(uPRI.FlagKills);

  statsArray[statsArray.Length] = stat5;
  statsArray[4].name = "Returns";
  statsArray[4].value = string(tPRI.FlagReturns);

  statsArray[statsArray.Length] = stat6;
  statsArray[5].name = "Seals";
  statsArray[5].value = string(uPRI.Seals);

  //Get StrLen shit for spacing
  for (count = 0; count < 6; count++) {
    C.Font = GetFontWithSize(FONT_PLAYER_STAT);
    C.StrLen(statsArray[count].name, statsArray[count].nameW, statsArray[count].nameH);

    //Find the longest name for both left and right.
    if (count<3 && statsArray[count].nameW > longestOStatName) {
      longestOStatName = statsArray[count].nameW;
    } else if (count>3 && statsArray[count].nameW > longestDStatName) {
      longestDStatName = statsArray[count].nameW;
    }

    C.Font = GetFontWithSize(FONT_PLAYER_STAT_NUM);
    C.StrLen(statsArray[count].value, statsArray[count].valueW, statsArray[count].valueH);
  }


  statX = baseX + boxWidth - 300;

  //Left column
  for (count = 0; count < 3; count++) {
    C.Font = GetFontWithSize(FONT_PLAYER_STAT);
    SetPosScaled(C, statX + longestOStatName - statsArray[count].nameW, baseY + (boxHeight - statsArray[count].nameH*3)/2 + statsArray[count].nameH*count);
    C.DrawText(statsArray[count].name);

    C.Font = GetFontWithSize(FONT_PLAYER_STAT_NUM);
    SetPosScaled(C, statX + longestOStatName + 5, baseY + (boxHeight - statsArray[count].nameH*3)/2 + statsArray[count].nameH*count);
    C.DrawText(statsArray[count].value);
  }

  //Right column
  for (count = 3; count < 6; count++) {
    C.Font = GetFontWithSize(FONT_PLAYER_STAT);
    SetPosScaled(C, statX + 100 + longestOStatName + longestDStatName - statsArray[count].nameW, baseY + (boxHeight - statsArray[count].nameH*3)/2 + statsArray[count].nameH*(count - 3));
    C.DrawText(statsArray[count].name);

    C.Font = GetFontWithSize(FONT_PLAYER_STAT_NUM);
    SetPosScaled(C, statX + 100 + longestOStatName + longestDStatName + 5, baseY + (boxHeight - statsArray[count].nameH*3)/2 + statsArray[count].nameH*(count - 3));
    C.DrawText(statsArray[count].value);
  }
}

/*
 * Arrange specs - WebAdmin, DemoRecSpectator go first.
 */
simulated function ArrangeSpecs(out PlayerReplicationInfo PRI[MAXPLAYERS])
{

}

/*
 *-----------------
 * Scaling functions
 * Regular Canvas functions but scaled versions to reduce stuff like ClipX*0.01248 existing in all the draw functions
 * These are here because I am too lazy to subclass Canvas (lol)
 *-----------------
 */

function float ScaleX(Canvas C, float value)
{
  return C.ClipX * (value/1920);
}

function float ScaleY(Canvas C, float value)
{
  return C.ClipY * (value/1080);
}

function SetPosScaled(Canvas C, float x, float y)
{
  C.SetPos(ScaleX(C, x), ScaleY(C, y));
}

function DrawTileStretchedScaled(Canvas C, material mat, float XL, float YL)
{
  C.DrawTileStretched(mat, ScaleX(C, XL), ScaleY(C, YL));
}

function DrawBoxScaled(Canvas C, float w, float h)
{

}

function DrawTextJustifiedScaled(Canvas C, coerce string text, byte justification, float x1, float y1, float x2, float y2)
{
  C.DrawTextJustified(text, justification, ScaleX(C, x1), ScaleY(C, y1), ScaleX(C, x2), ScaleY(C, y2));
}

/*
 *-----------------
 * String functions
 *-----------------
 */
function String GetRestartString()
{
  local string RestartString;

  RestartString = Restart;
  if (PlayerController(Owner).PlayerReplicationInfo.bOutOfLives)
  {
    RestartString = OutFireText;
  }
  else if ( Level.TimeSeconds - UnrealPlayer(Owner).LastKickWarningTime < 2 )
  {
    RestartString = class'GameMessage'.Default.KickWarning;
  }

  return RestartString;
}


function String GetTitleString()
{
  local string titlestring;

  if ( Level.NetMode == NM_Standalone )
  {
    if ( Level.Game.CurrentGameProfile != None )
    {
      titlestring = SkillLevel[Clamp(Level.Game.CurrentGameProfile.BaseDifficulty,0,7)];
    }
    else
    {
      titlestring = SkillLevel[Clamp(Level.Game.GameDifficulty,0,7)];
    }
  }
  else if ( (GRI != None) && (GRI.BotDifficulty >= 0) )
  {
    titlestring = SkillLevel[Clamp( GRI.BotDifficulty,0,7)];
  }

  return titlestring@GRI.GameName$MapName$Level.Title;
}

function String GetDefaultScoreInfoString()
{
  local String ScoreInfoString;

  if (GRI.MaxLives != 0)
  {
    ScoreInfoString = MaxLives@GRI.MaxLives;
  }
  else if ( GRI.GoalScore != 0 )
  {

    ScoreInfoString = FragLimitTeam@GRI.GoalScore;

    if (GRI.TimeLimit != 0)
    {
      ScoreInfoString = ScoreInfoString@spacer@TimeLimit$FormatTime(GRI.RemainingTime);
    }
  }
  else
  {
    ScoreInfoString = ScoreInfoString@spacer@FooterText@FormatTime(GRI.ElapsedTime);
  }

  return ScoreInfoString;
}

simulated function string GetAverageTeamPing(byte team)
{
  local int i;
  local float avg;
  local int NumSamples;

  for(i = 0; i < GRI.PRIArray.Length; i++)
  {
    if(!GRI.PRIArray[i].bOnlySpectator && GRI.PRIArray[i].Team != None && GRI.PRIArray[i].Team.TeamIndex == team)
    {
      Avg += GRI.PRIArray[i].Ping;
      NumSamples++;
    }
  }

  return string(int(4.0*Avg/float(NumSamples))); //Why 4?
}

simulated function string GetAverageTeamPL(byte team)
{
  local int i;
  local float avg;
  local int numSamples;

  for (i = 0; i < GRI.PRIArray.length; i++)
  {
    if (!GRI.PRIArray[i].bOnlySpectator && GRI.PRIArray[i].Team != None && GRI.PRIArray[i].Team.TeamIndex == team)
    {
      avg += GRI.PRIArray[i].PacketLoss;
      numSamples++;
    }
  }

  return string(int(avg/float(numSamples)));
}

/*
 * -----------
 * Font loader
 * -----------
 */

static function Font GetFontWithSize(int i)
{
  if( default.FontArrayFonts[i] == None )
  {
    default.FontArrayFonts[i] = Font(DynamicLoadObject(default.FontArrayNames[i], class'Font'));
    if(default.FontArrayFonts[i] == None)
    {
      Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.FontArrayNames[i]);
    }
  }

  return default.FontArrayFonts[i];
}

//TODO: FIX THIS
simulated function Font GetFontForPlayerName(String playerName)
{
  local int length;

  length = Len(playerName);

  if (length >= 14) {
    return GetFontWithSize(FONT_PLAYER_NAME - 1);
  } else {
    return GetFontWithSize(FONT_PLAYER_NAME);
  }
}

defaultproperties
{
  fraglimitteam="SCORE LIMIT:"
  bEnableColoredNamesOnScoreboard=True
  bDrawStats=True
  bDrawPickups=True
  bOverrideDisplayStats=false
  FontArrayNames(0)  = "Engine.DefaultFont"
  FontArrayNames(1)  = "2K4Fonts.Verdana12"
  FontArrayNames(2)  = "2K4Fonts.Verdana14"
  FontArrayNames(3)  = "UT2003Fonts.FontEurostile14"
  FontArrayNames(4)  = "2K4Fonts.Verdana16"
  FontArrayNames(5)  = "UT2003Fonts.FontEurostile17"
  FontArrayNames(6)  = "UT2003Fonts.FontEurostile29"
  FontArrayNames(7)  = "UT2003Fonts.FontEurostile37"
  FontArrayNames(8)  = "Engine.DefaultFont"

  TeamBoxMaterial = Material'Engine.WhiteTexture'
  TeamHeaderMaterial = Material'Engine.BlackTexture'
}
