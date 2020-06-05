
class utcomp_ScoreBoardTDM extends ScoreBoardTeamDeathMatch;

var font Smallerfont;

function DrawNetInfo(Canvas Canvas,int FontReduction,int HeaderOffsetY,int PlayerBoxSizeY,int BoxSpaceY,int BoxTextOffsetY,int OwnerOffset,int PlayerCount, int NetXPos)
{
	local float XL,YL;
	local int i;
	local bool bHaveHalfFont, bDrawFPH, bDrawPL;

        local UTComp_Warmup uWarmup;
        local UTComp_PRI uPRI;

        foreach dynamicactors(class'UTComp_Warmup', uWarmup)
        break;
	// draw admins
	if ( GRI.bMatchHasBegun )
	{
		Canvas.DrawColor = HUDClass.default.RedColor;
		for ( i=0; i<PlayerCount; i++ )
			if ( PRIArray[i].bAdmin )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(AdminText,true);
				}
		if ( (OwnerOffset >= PlayerCount) && PRIArray[OwnerOffset].bAdmin )
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*PlayerCount + BoxTextOffsetY);
			Canvas.DrawText(AdminText,true);
		}
	}

    Canvas.DrawColor = HUDClass.default.CyanColor;
	Canvas.Font = GetSmallFontFor(Canvas.ClipX, FontReduction);
	Canvas.StrLen("Test", XL, YL);
	BoxTextOffsetY = HeaderOffsetY + 0.5*PlayerBoxSizeY;
	bHaveHalfFont = ( YL < 0.5 * PlayerBoxSizeY);
	// if game hasn't begun, draw ready or not ready
	if ( !GRI.bMatchHasBegun )
	{
		bDrawPL = PlayerBoxSizeY > 3 * YL;
		for ( i=0; i<PlayerCount; i++ )
		{
			if ( bDrawPL )
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.4 * YL);
				Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
				Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
			}
			else if ( bHaveHalfFont )
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
				Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			}
			else
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
			if ( PRIArray[i].bReadyToPlay )
				Canvas.DrawText(ReadyText,true);
			else
				Canvas.DrawText(NotReadyText,true);
		}
		return;
	}

	// draw time and ping
	if ( Canvas.ClipX < 512 )
		PingText = "";
	else
	{
		PingText = Default.PingText;
		bDrawFPH = PlayerBoxSizeY > 3 * YL;
		bDrawPL = PlayerBoxSizeY > 4 * YL;
	}
	if ( ((FPHTime == 0) || (!UnrealPlayer(Owner).bDisplayLoser && !UnrealPlayer(Owner).bDisplayWinner))
		&& (GRI.ElapsedTime > 0) )
		FPHTime = GRI.ElapsedTime;

	for ( i=0; i<PlayerCount; i++ )
	{
    	uPRI=class'UTComp_Util'.static.GetUTCompPRI(PRIArray[i]);
        if ( !PRIArray[i].bAdmin && !PRIArray[i].bOutOfLives )
 			{
 				if ( bDrawPL && uWarmup!=None && uWarmup.bInWarmup)
 				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.9 * YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.9 * YL);
					Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);

					if (uPRI.bisReady == False)
				        {
                                        Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.1 * YL);
                                        Canvas.DrawText("Not Ready",true);
			                }
                                        else
				        {
                                           Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.1 * YL);
                                           Canvas.DrawText("Ready",true);
                                        }
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 1.1 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}

 				else if ( bDrawPL )
 				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.9 * YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.9 * YL);
					Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.1 * YL);
					Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 1.1 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}

				else if (bDrawFPH && uWarmup!=None && uWarmup.bInWarmup)
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.4 * YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
					if (uPRI.bisReady == False)
				        {
                                        Canvas.DrawText("Not Ready",true);
			                }
                                        else
				        {
                                        Canvas.DrawText("Ready",true);
                                        }
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
                                }

                                else if ( bDrawFPH )
 				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.4 * YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
					Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}


                                else if ( bHaveHalfFont && uWarmup!=None && uWarmup.bInWarmup)
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					if (uPRI.bisReady == False)
			                {
                                           Canvas.DrawText("Not Ready",true);
		                        }
                                        else
			                {
                                           Canvas.DrawText("Ready",true);
                                        }
				}

				else if ( bHaveHalfFont )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
				else
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
				}
			}
		}
	if ( (OwnerOffset >= PlayerCount) && !PRIArray[OwnerOffset].bAdmin && !PRIArray[OwnerOffset].bOutOfLives )
	{
 		 uPRI=class'UTComp_Util'.static.GetUTCompPRI(PRIArray[OwnerOffset]);
         if ( bDrawFPH )
 		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.4 * YL);
			Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
			if (uPRI.bisReady == False)
			{
                           Canvas.DrawText("Not Ready",true);
		        }
                          else
			{
                           Canvas.DrawText("Ready",true);
                        }
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
			Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
		}
		else if ( bHaveHalfFont )
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
			Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			if (uPRI.bisReady == False)
			{
                           Canvas.DrawText("Not Ready",true);
		        }
                          else
			{
                           Canvas.DrawText("Ready",true);
                        }
		}
		else
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
			Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
		}
	}
}

simulated event UpdateScoreBoard(Canvas Canvas)
{
	local PlayerReplicationInfo PRI, OwnerPRI;
	local int i, FontReduction,HeaderOffsetY,HeadFoot,PlayerBoxSizeY, BoxSpaceY;
	local float XL,YL, IconSize, MaxScaling, MessageFoot;
	local int BluePlayerCount, RedPlayerCount, RedOwnerOffset, BlueOwnerOffset, MaxPlayerCount;
	local PlayerReplicationInfo RedPRI[MAXPLAYERS], BluePRI[MaxPlayers], SPECPRI[maxPlayers];
	local font MainFont;
    local int numSpecs;

	OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
	RedOwnerOffset = -1;
	BlueOwnerOffset = -1;
    for (i=0; i<GRI.PRIArray.Length; i++)
	{
		PRI = GRI.PRIArray[i];
		if ( (PRI.Team != None) && (!PRI.bIsSpectator || PRI.bWaitingPlayer) )
		{
			if ( PRI.Team.TeamIndex == 0 )
			{
				if ( RedPlayerCount < MAXPLAYERS )
				{
					RedPRI[RedPlayerCount] = PRI;
					if ( PRI == OwnerPRI )
						RedOwnerOffset = RedPlayerCount;
					RedPlayerCount++;
				}
			}
			else if ( BluePlayerCount < MAXPLAYERS )
			{
				BluePRI[BluePlayerCount] = PRI;
				if ( PRI == OwnerPRI )
					BlueOwnerOffset = BluePlayerCount;
				BluePlayerCount++;
			}
		}
		if( numSpecs < MAXPLAYERS)
		{
			 if(PRI.bOnlySpectator)
             {
                 SpecPRI[numSpecs]=PRI;
			     numSpecs++;
			 }
		}
	}
	MaxPlayerCount = Max(RedPlayerCount,BluePlayerCount);

	// Select best font size and box size to fit as many players as possible on screen
	Canvas.Font = HUDClass.static.GetMediumFontFor(Canvas);
	Canvas.StrLen("Test", XL, YL);
	IconSize = FMax(2 * YL, 64 * Canvas.ClipX/1024);
	BoxSpaceY = 0.25 * YL;
	if ( HaveHalfFont(Canvas, FontReduction) )
		PlayerBoxSizeY = 2.125 * YL;
	else
		PlayerBoxSizeY = 1.75 * YL;
	HeadFoot = 4*YL + IconSize;
	MessageFoot = 1.4 * HeadFoot;
	if ( MaxPlayerCount > (Canvas.ClipY*0.80 - 1.4 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
	{
		BoxSpaceY = 0.125 * YL;
		if ( MaxPlayerCount > (Canvas.ClipY*0.80 - 1.4 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
		{
			if ( MaxPlayerCount > (Canvas.ClipY*0.80 - 1.4 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
			{
				FontReduction++;
				Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
				Canvas.StrLen("Test", XL, YL);
				BoxSpaceY = 0.125 * YL;
				if ( HaveHalfFont(Canvas, FontReduction) )
					PlayerBoxSizeY = 2.125 * YL;
				else
					PlayerBoxSizeY = 1.75 * YL;
				HeadFoot = 4*YL + IconSize;
				if ( MaxPlayerCount > (Canvas.ClipY*0.80 - 1.4 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
				{
					FontReduction++;
					Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
					Canvas.StrLen("Test", XL, YL);
					BoxSpaceY = 0.125 * YL;
					if ( HaveHalfFont(Canvas, FontReduction) )
						PlayerBoxSizeY = 2.125 * YL;
					else
						PlayerBoxSizeY = 1.75 * YL;
					HeadFoot = 4*YL + IconSize;
					if ( (Canvas.ClipY >= 600) && (MaxPlayerCount > (Canvas.ClipY*0.80 - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY)) )
					{
						FontReduction++;
						Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
						Canvas.StrLen("Test", XL, YL);
						BoxSpaceY = 0.125 * YL;
						if ( HaveHalfFont(Canvas, FontReduction) )
							PlayerBoxSizeY = 2.125 * YL;
						else
							PlayerBoxSizeY = 1.75 * YL;
						HeadFoot = 4*YL + IconSize;
						if ( MaxPlayerCount > (Canvas.ClipY*0.80 - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
						{
							FontReduction++;
							Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
							Canvas.StrLen("Test", XL, YL);
							BoxSpaceY = 0.125 * YL;
							if ( HaveHalfFont(Canvas, FontReduction) )
								PlayerBoxSizeY = 2.125 * YL;
							else
								PlayerBoxSizeY = 1.75 * YL;
							HeadFoot = 4*YL + IconSize;
						}
					}
				}
			}
		}
	}

	MaxPlayerCount = Min(MaxPlayerCount, 1+(Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) );
	if ( FontReduction > 2 )
		MaxScaling = 3;
	else
		MaxScaling = 2.125;
	PlayerBoxSizeY = FClamp((1+(Canvas.ClipY*0.80 - 0.67 * MessageFoot))/MaxPlayerCount - BoxSpaceY, PlayerBoxSizeY, MaxScaling * YL);
	//bDisplayMessages = (MaxPlayerCount < (Canvas.ClipY - MessageFoot)/(PlayerBoxSizeY + BoxSpaceY));
	bDisplayMessages=!class'UTcomp_ScoreBoard'.default.bDrawStats;
    RedPlayerCount = Min(RedPlayerCount,MaxPlayerCount);
	BluePlayerCount = Min(BluePlayerCount,MaxPlayerCount);
	if ( RedOwnerOffset >= RedPlayerCount )
		RedPlayerCount -= 1;
	if ( BlueOwnerOffset >= BluePlayerCount )
		BluePlayerCount -= 1;
	HeaderOffsetY = 1.4*YL + IconSize;

/*
	// draw center U
	if ( Canvas.ClipX >= 512 )
	{
		Canvas.DrawColor = 0.75 * HUDClass.default.WhiteColor;
		ScoreBackScale = Canvas.ClipX/1024;
		Canvas.SetPos(0.5 * Canvas.ClipX - 128 * ScoreBackScale, HeaderOffsetY - 128 * ScoreBackScale);
		Canvas.DrawTile( ScoreboardU, 256*ScoreBackScale, 128*ScoreBackScale, 0, 0, 256, 128);
	}
*/
	// draw title
	Canvas.Style = ERenderStyle.STY_Normal;
	DrawTitle(Canvas, HeaderOffsetY, (MaxPlayerCount+1)*(PlayerBoxSizeY + BoxSpaceY), PlayerBoxSizeY);

	// draw red team
	MainFont = Canvas.Font;
	for (i=0; i<32; i++ )
		PRIArray[i] = RedPRI[i];
	DrawTeam(0,RedPlayerCount,RedOwnerOffset,Canvas, FontReduction,BoxSpaceY,PlayerBoxSizeY,HeaderOffsetY);

	// draw blue team
	Canvas.Font = MainFont;
	for (i=0; i<32; i++ )
		PRIArray[i] = BluePRI[i];
	DrawTeam(1,BluePlayerCount,BlueOwnerOffset,Canvas, FontReduction,BoxSpaceY,PlayerBoxSizeY,HeaderOffsetY);

	if ( Level.NetMode != NM_Standalone )
		DrawMatchID(Canvas,FontReduction);
	SmallerFont  = GetSmallerFontFor (Canvas,4);
    DrawStats(Canvas);
    DrawPowerUps(Canvas);

    if(numSpecs>0)
    {
       for (i=0; i<numspecs && specPRI[i]!=None; i++)
          DrawSpecs(Canvas, SpecPRI[i], i);
       DrawSpecs(Canvas,None,i);
    }
}

function DrawTeam(int TeamNum, int PlayerCount, int OwnerOffset, Canvas Canvas, int FontReduction, int BoxSpaceY, int PlayerBoxSizeY, int HeaderOffsetY)
{
	local int i, OwnerPos, NetXPos, NameXPos, BoxTextOffsetY, ScoreXPos, ScoreYPos, BoxXPos, BoxWidth, LineCount,NameY;
	local float XL,YL,IconScale,ScoreBackScale,ScoreYL,MaxNamePos,LongestNameLength, oXL, oYL;
	local string PlayerName[MAXPLAYERS], OrdersText, LongestName;
	local font MainFont, ReducedFont;
	local bool bHaveHalfFont, bNameFontReduction;
	local int SymbolUSize, SymbolVSize, OtherTeam, LastLine;
    local UTComp_PRI uPRI;

	BoxWidth = 0.47 * Canvas.ClipX;
	BoxXPos = 0.5 * (0.5 * Canvas.ClipX - BoxWidth);
	BoxWidth = 0.5 * Canvas.ClipX - 2*BoxXPos;
	BoxXPos = BoxXPos + TeamNum * 0.5 * Canvas.ClipX;
	NameXPos = BoxXPos + 0.05 * BoxWidth;
	ScoreXPos = BoxXPos + 0.55 * BoxWidth;
	NetXPos = BoxXPos + 0.76 * BoxWidth;
	bHaveHalfFont = HaveHalfFont(Canvas, FontReduction);

	// draw background box
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(BoxXPos, HeaderOffsetY);
	Canvas.DrawTileStretched( TeamBoxMaterial[TeamNum], BoxWidth, PlayerCount * (PlayerBoxSizeY + BoxSpaceY));

	// draw team header
	IconScale = Canvas.ClipX/4096;
	ScoreBackScale = Canvas.ClipX/1024;
	if ( GRI.TeamSymbols[TeamNum] != None )
	{
		SymbolUSize = GRI.TeamSymbols[TeamNum].USize;
		SymbolVSize = GRI.TeamSymbols[TeamNum].VSize;
	}
	else
	{
		SymbolUSize = 256;
		SymbolVSize = 256;
	}
	ScoreYPos = HeaderOffsetY - SymbolVSize * IconScale - BoxSpaceY;

	Canvas.DrawColor = 0.75 * HUDClass.default.WhiteColor;
	Canvas.SetPos(BoxXPos, ScoreYPos - BoxSpaceY);
	Canvas.DrawTileStretched( Material'InterfaceContent.ScoreBoxA', BoxWidth, HeaderOffsetY + BoxSpaceY - ScoreYPos);

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = TeamColors[TeamNum];
	Canvas.SetPos((0.25 + 0.5*TeamNum) * Canvas.ClipX - (SymbolUSize + 32) * IconScale, ScoreYPos);
	if ( GRI.TeamSymbols[TeamNum] != None )
		Canvas.DrawIcon(GRI.TeamSymbols[TeamNum],IconScale);
	MainFont = Canvas.Font;
	Canvas.Font = HUDClass.static.LargerFontThan(MainFont);
	Canvas.StrLen("TEST",XL,ScoreYL);
	if ( ScoreYPos == 0 )
		ScoreYPos = HeaderOffsetY - ScoreYL;
	else
		ScoreYPos = ScoreYPos + 0.5 * SymbolVSize * IconScale - 0.5 * ScoreYL;
	Canvas.SetPos((0.25 + 0.5*TeamNum) * Canvas.ClipX + 32*IconScale,ScoreYPos);
	Canvas.DrawText(int(GRI.Teams[TeamNum].Score));
	Canvas.Font = MainFont;
	Canvas.DrawColor = HUDClass.default.WhiteColor;

	IconScale = Canvas.ClipX/1024;

	if ( PlayerCount <= 0 )
		return;

	// draw lines between sections
	if ( TeamNum == 0 )
		Canvas.DrawColor = HUDClass.default.RedColor;
	else
		Canvas.DrawColor = HUDClass.default.BlueColor;
	if ( OwnerOffset >= PlayerCount )
		LastLine = PlayerCount+1;
	else
		LastLine = PlayerCount;
	for ( i=1; i<LastLine; i++ )
	{
		Canvas.SetPos( NameXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY)*i - 0.5*BoxSpaceY);
		Canvas.DrawTileStretched( Material'InterfaceContent.ButtonBob', 0.9*BoxWidth, ScorebackScale*3);
	}
	Canvas.DrawColor = HUDClass.default.WhiteColor;

	// draw player names
	MaxNamePos = 0.95 * (ScoreXPos - NameXPos);
	for ( i=0; i<PlayerCount; i++ )
	{
        uPRI=class'UTComp_Util'.static.GetUTCompPRI(PRIArray[i]);
        if(class'UTComp_SCoreBoard'.default.bEnableColoredNamesOnScoreboard==True)
        {
           playername[i] = uPRI.ColoredName;
           if(PlayerName[i]=="")
              PlayerName[i]=GRI.PRIArray[i].PlayerName;
        }
        else
            playername[i] = GRI.PRIArray[i].PlayerName;
		Canvas.StrLen(playername[i], XL, YL);
		if ( XL > FMax(LongestNameLength,MaxNamePos) )
		{
			LongestName = PlayerName[i];
			LongestNameLength = XL;
		}
	}
	if ( OwnerOffset >= PlayerCount )
	{
		uPRI=class'UTComp_Util'.static.GetUTCompPRI(PRIArray[OwnerOffset]);
        if(class'UTComp_SCoreBoard'.default.bEnableColoredNamesOnScoreboard==True)
        {
           playername[OwnerOffset] = uPRI.ColoredName;
           if(PlayerName[OwnerOffset]=="")
              PlayerName[OwnerOffset]=GRI.PRIArray[OwnerOffset].PlayerName;
        }
        else
            playername[OwnerOffset] = GRI.PRIArray[OwnerOffset].PlayerName;
		Canvas.StrLen(playername[OwnerOffset], XL, YL);
		if ( XL > FMax(LongestNameLength,MaxNamePos) )
		{
			LongestName = PlayerName[i];
			LongestNameLength = XL;
		}
	}

	if ( LongestNameLength > 0 )
	{
		bNameFontReduction = true;
		Canvas.Font = GetSmallerFontFor(Canvas,FontReduction+1);
		Canvas.StrLen(LongestName, XL, YL);
		if ( XL > MaxNamePos )
		{
			Canvas.Font = GetSmallerFontFor(Canvas,FontReduction+2);
			Canvas.StrLen(LongestName, XL, YL);
			if ( XL > MaxNamePos )
				Canvas.Font = GetSmallerFontFor(Canvas,FontReduction+3);
		}
		ReducedFont = Canvas.Font;
	}

	for ( i=0; i<PlayerCount; i++ )
	{

        uPRI=class'UTComp_Util'.static.GetUTCompPRI(PRIArray[i]);
        if(class'UTComp_SCoreBoard'.default.bEnableColoredNamesOnScoreboard==True)
        {
           playername[i] = uPRI.ColoredName;
           if(PlayerName[i]=="")
              PlayerName[i]=PRIArray[i].PlayerName;
        }
        else
            playername[i] = PRIArray[i].PlayerName;
		Canvas.StrLen(playername[i], XL, YL);
	/*	if ( XL > MaxNamePos )
			playername[i] = left(playername[i], MaxNamePos/XL * len(PlayerName[i]));*/
	}
	if ( OwnerOffset >= PlayerCount )
	{
		uPRI=class'UTComp_Util'.static.GetUTCompPRI(PRIArray[OwnerOffset]);
        if(class'UTComp_SCoreBoard'.default.bEnableColoredNamesOnScoreboard==True)
        {
           playername[OwnerOffset] = uPRI.ColoredName;
           if(PlayerName[OwnerOffset]=="")
              PlayerName[OwnerOffset]=PRIArray[OwnerOffset].PlayerName;
        }
        else
            playername[OwnerOffset] = PRIArray[OwnerOffset].PlayerName;
		Canvas.StrLen(playername[OwnerOffset], XL, YL);
		/*if ( XL > MaxNamePos )
			playername[OwnerOffset] = left(playername[OwnerOffset], MaxNamePos/XL * len(PlayerName[OwnerOffset]));*/
	}

	if ( Canvas.ClipX < 512 )
		NameY = 0.5 * YL;
	else if ( !bHaveHalfFont )
		NameY = 0.125 * YL;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);
	BoxTextOffsetY = HeaderOffsetY + 0.5 * PlayerBoxSizeY - 0.5 * YL;
	Canvas.DrawColor = HUDClass.default.WhiteColor;

	if ( OwnerOffset == -1 )
	{
		for ( i=0; i<PlayerCount; i++ )
			if ( i != OwnerOffset )
			{
				Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
				Canvas.DrawText(playername[i],true);
			}
	}
	else
	{
		for ( i=0; i<PlayerCount; i++ )
			if ( i != OwnerOffset )
			{
				Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL + NameY);
				Canvas.DrawText(playername[i],true);
			}
	}
	if ( bNameFontReduction )
		Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);

	// draw scores
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	for ( i=0; i<PlayerCount; i++ )
		if ( i != OwnerOffset )
		{
			Canvas.SetPos(ScoreXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			if ( PRIArray[i].bOutOfLives )
				Canvas.DrawText(OutText,true);
			else
				Canvas.DrawText(int(PRIArray[i].Score),true);
		}

	// draw owner line
	if ( OwnerOffset >= 0 )
	{
		if ( OwnerOffset >= PlayerCount )
		{
			OwnerPos = (PlayerBoxSizeY + BoxSpaceY)*PlayerCount + BoxTextOffsetY;
			// draw extra box
			Canvas.Style = ERenderStyle.STY_Alpha;
			Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY)*PlayerCount);
			Canvas.DrawTileStretched( TeamBoxMaterial[TeamNum], BoxWidth, PlayerBoxSizeY);
			Canvas.Style = ERenderStyle.STY_Normal;
			if ( PRIArray[OwnerOffset].HasFlag != None )
			{
				Canvas.DrawColor = HUDClass.default.WhiteColor;
				Canvas.SetPos(NameXPos - 48*IconScale, OwnerPos - 16*IconScale);
				Canvas.DrawTile( FlagIcon, 64*IconScale, 32*IconScale, 0, 0, 256, 128);
			}
		}
		else
			OwnerPos = (PlayerBoxSizeY + BoxSpaceY)*OwnerOffset + BoxTextOffsetY;

		Canvas.DrawColor = HUDClass.default.GoldColor;
		Canvas.SetPos(NameXPos, OwnerPos-0.5*YL+NameY);
		if ( bNameFontReduction )
			Canvas.Font = ReducedFont;
		Canvas.DrawText(playername[OwnerOffset],true);
		if ( bNameFontReduction )
			Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
		Canvas.SetPos(ScoreXPos, OwnerPos);
		if ( PRIArray[OwnerOffset].bOutOfLives )
			Canvas.DrawText(OutText,true);
		else
			Canvas.DrawText(int(PRIArray[OwnerOffset].Score),true);
	}

	// draw flag icons
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	if ( TeamNum == 0 )
		OtherTeam = 1;
	if ( (GRI.FlagState[OtherTeam] != EFlagState.FLAG_Home) && (GRI.FlagState[OtherTeam] != EFlagState.FLAG_Down) )
	{
		for ( i=0; i<PlayerCount; i++ )
			if ( (PRIArray[i].HasFlag != None) || (PRIArray[i] == GRI.FlagHolder[TeamNum]) )
			{
				Canvas.SetPos(NameXPos - 48*IconScale, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 16*IconScale);
				Canvas.DrawTile( FlagIcon, 64*IconScale, 32*IconScale, 0, 0, 256, 128);
			}
	}

	// draw location and/or orders
	if ( (OwnerOffset >= 0) && (Canvas.ClipX >= 512) )
	{
		BoxTextOffsetY = HeaderOffsetY + 0.5*PlayerBoxSizeY + NameY;
		Canvas.DrawColor = HUDClass.default.CyanColor;
		if ( FontReduction > 3 )
			bHaveHalfFont = false;
		if ( Canvas.ClipX >= 1280 )
			Canvas.Font = GetSmallFontFor(Canvas.ClipX, FontReduction+2);
		else
			Canvas.Font = GetSmallFontFor(Canvas.ClipX, FontReduction+1);
		Canvas.StrLen("Test", XL, YL);
		for ( i=0; i<PlayerCount; i++ )
		{
			LineCount = 0;
			if( PRIArray[i].bBot && (TeamPlayerReplicationInfo(PRIArray[i]) != None) && (TeamPlayerReplicationInfo(PRIArray[i]).Squad != None) )
			{
				LineCount = 1;
				Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
				if ( Canvas.ClipX < 800 )
					OrdersText = "("$PRIArray[i].GetCallSign()$") "$TeamPlayerReplicationInfo(PRIArray[i]).Squad.GetShortOrderStringFor(TeamPlayerReplicationInfo(PRIArray[i]));
				else
				{
					OrdersText = TeamPlayerReplicationInfo(PRIArray[i]).Squad.GetOrderStringFor(TeamPlayerReplicationInfo(PRIArray[i]));
					OrdersText = "("$PRIArray[i].GetCallSign()$") "$OrdersText;
					Canvas.StrLen(OrdersText, oXL, oYL);
					if ( oXL >= ScoreXPos - NameXPos )
						OrdersText = "("$PRIArray[i].GetCallSign()$") "$TeamPlayerReplicationInfo(PRIArray[i]).Squad.GetShortOrderStringFor(TeamPlayerReplicationInfo(PRIArray[i]));
				}
				Canvas.DrawText(OrdersText,true);
			}
			if ( bHaveHalfFont || !PRIArray[i].bBot )
			{
				Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + LineCount*YL);
				Canvas.DrawText(PRIArray[i].GetLocationName(),true);
			}
		}
		if ( OwnerOffset >= PlayerCount )
		{
			Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(PRIArray[OwnerOffset].GetLocationName(),true);
		}
	}

	if ( Level.NetMode == NM_Standalone )
		return;
	Canvas.Font = MainFont;
	Canvas.StrLen("Test",XL,YL);
	BoxTextOffsetY = HeaderOffsetY + 0.5 * PlayerBoxSizeY - 0.5 * YL;
	DrawNetInfo(Canvas,FontReduction,HeaderOffsetY,PlayerBoxSizeY,BoxSpaceY,BoxTextOffsetY,OwnerOffset,PlayerCount,NetXPos);
}

function DrawSpecs(Canvas C, PlayerReplicationInfo PRI, int i)
{
    local string DrawText;
    local float BoxSizeX, BoxSizeY;
    local float StartPosX, StartPosY;
    local float bordersize;
    local UTComp_PRI uPRI;

    if(C.SizeX<630)
        return;
    C.Font=SmallerFont;
    C.StrLen(" 100% / 100%", BoxSizeX, BoxSizeY);
    StartPosX=C.ClipX-BoxSizeX*1.25;
    StartPosY=(C.ClipY*0.9150-BoxSizeY);
    bordersize=1.0;

    if(PRI==None)
    {
        DrawText="Spectators";
        C.SetPos(StartPosX, StartPosY-(BoxSizeY+BorderSize)*(i-1)-BorderSize);
        C.DrawTileStretched(material'Engine.WhiteTexture',BoxSizeX,BorderSize);
    }
    else
    {
        DrawText=PRI.PlayerName;
        uPRI=Class'UTComp_Util'.static.GetUTCompPRI(PRI);
    }

    if(uPRI==None || uPRI.CoachTeam==255)
        C.SetDrawColor(10,10,10,155);
    else if(uPRI.CoachTeam==0)
        C.SetDrawColor(250,0,0,155);
    else if(uPRI.CoachTeam==1)
        C.SetDrawColor(0,0,250,155);

    C.SetPos(StartPosX, StartPosY-(BoxSizeY+BorderSize)*i);
    C.DrawTileStretched(material'Engine.WhiteTexture', BoxSizeX, BoxSizeY+BorderSize);
    C.SetDrawColor(255,255,255,255);
    C.DrawTextJustified(DrawText, 1, StartPosX, StartPosY-(BoxSizeY+BorderSize)*i, StartPosX+BoxSizeX,  StartPosY-(BoxSizeY+BorderSize)*i+BoxSizeY);
}

function DrawOtherPowerups(Canvas C)
{
    local float BoxSizeX, BoxSizeY;
    local float StartPosX, StartPosY;
    local float bordersize;
    local UTComp_PRI uPRI;
    local BS_xPlayer UxP;
    local int Hundreds, fifties, Health, Adren, amp;
    local int lines, i;
    local float charoffset, charoffset2;


    if(!class'UTComp_ScoreBoard'.default.bDrawPickups || BS_xPlayer(Owner)==None || BS_xPlayer(Owner).UTCompPRI==None || C.SizeX<=630)
        return;
    UxP=BS_xPlayer(Owner);
    uPRI=UxP.currentStatDraw;

    C.StrLen(" 100% / 100%", BoxSizeX, BoxSizeY);
    StartPosX=C.ClipX-BoxSizeX*3.0;
    StartPosY=(C.ClipY*0.9150)-(BoxSizeY+BorderSize);
    bordersize=1.0;
    C.StrLen("A", charoffset, charoffset2);
    charoffset=charoffset*0.5;

    if(uPRI.PickedUpFifty>0)
    {
        fifties+=uPRI.PickedUpFifty;
        Lines++;
    }
    if(uPRI.PickedUpHundred>0)
    {
        hundreds+=uPRI.PickedUpHundred;
        Lines++;
    }
    if(uPRI.PickedUpAmp>0)
    {
        Amp+=uPRI.PickedUpAmp;
        Lines++;
    }
    if(uPRI.PickedUpVial>0)
    {
        Health+=5*uPRI.PickedUpVial;
    }
    if(uPRI.PickedUpHealth>0)
    {
        Health+=25*uPRI.PickedUpHealth;
    }
    if(uPRI.PickedUpKeg>0)
    {
        Health+=100*uPRI.PickedUpKeg;
    }
    if(uPRI.PickedUpAdren>0)
    {
        Adren+=2*uPRI.PickedUpAdren;
        Lines++;
    }
    if(health>0)
    {
        Lines++;
    }

    if(lines==0)
        return;


    C.Style=5;


    //draw borders
    C.SetDrawColor(255,255,255,255);

    C.SetPos(StartPosX, StartPosY+(boxsizey));
    C.DrawTileStretched(material'Engine.WhiteTexture',(BoxSizeX+BorderSize),BorderSize);

    C.SetPos(StartPosX+BoxSizeX, StartPosY-(Lines-1)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture',(BorderSize),(BorderSize+BoxSizeY)*Lines);

    C.SetPos(StartPosX, StartPosY-(Lines-1)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture',(BorderSize),(BorderSize+BoxSizeY)*Lines);
    C.DrawTileStretched(material'Engine.WhiteTexture',(BoxSizeX+BorderSize),BorderSize);

    //draw background
    C.SetDrawColor(45,45,45,155);
    C.DrawTileStretched(material'Engine.WhiteTexture',(BoxSizeX+BorderSize), lines*(BoxSizeY+BorderSize));
    C.SetDrawColor(255,255,255,255);


        C.SetPos(StartPosX+CharOffset, StartPosY);
        if(Adren>0)
        {
            C.DrawText("Adren:  "$Adren);
            i++;
            C.SetPos(StartPosX+CharOffset, StartPosY-i*(BoxSizeY+BorderSize));
        }
        if(Fifties>0)
        {
            C.DrawText("50s:    "$Fifties);
            i++;
            C.SetPos(StartPosX+CharOffset, StartPosY-i*(BoxSizeY+BorderSize));
        }
        if(Hundreds>0)
        {
            C.DrawText("100s:   "$Hundreds);
            i++;
            C.SetPos(StartPosX+CharOffset, StartPosY-i*(BoxSizeY+BorderSize));
        }
        if(Health>0)
        {
            C.DrawText("Health: "$Health);
            i++;
            C.SetPos(StartPosX+CharOffset, StartPosY-i*(BoxSizeY+BorderSize));
        }
        if(amp>0)
            C.DrawText("DD:     "$Amp);
}

function DrawPowerups(Canvas C)
{
    local float BoxSizeX, BoxSizeY;
    local float StartPosX, StartPosY;
    local float bordersize;
    local UTComp_PRI uPRI;
    local BS_xPlayer UxP;
    local int Hundreds, fifties, Health, Adren, amp;
    local int lines, i;
    local float charoffset, charoffset2;


    if(!class'UTComp_ScoreBoard'.default.bDrawPickups || BS_xPlayer(Owner)==None || BS_xPlayer(Owner).UTCompPRI==None || C.SizeX<=630)
        return;
    UxP=BS_xPlayer(Owner);
    if(UxP.currentStatDraw!=None && UxP.currentStatDraw!=UxP.UTCompPRI)
    {
        DrawOtherPowerups(C);
        return;
    }
    uPRI=UxP.UTCompPRI;

    C.StrLen(" 100% / 100%", BoxSizeX, BoxSizeY);
    StartPosX=C.ClipX-BoxSizeX*3.0;
    StartPosY=(C.ClipY*0.9150)-(BoxSizeY+BorderSize);
    bordersize=1.0;
    C.StrLen("A", charoffset, charoffset2);
    charoffset=charoffset*0.5;

    if(uPRI.PickedUpFifty>0)
    {
        fifties+=uPRI.PickedUpFifty;
        Lines++;
    }
    if(uPRI.PickedUpHundred>0)
    {
        hundreds+=uPRI.PickedUpHundred;
        Lines++;
    }
    if(uPRI.PickedUpAmp>0)
    {
        Amp+=uPRI.PickedUpAmp;
        Lines++;
    }
    if(uPRI.PickedUpVial>0)
    {
        Health+=5*uPRI.PickedUpVial;
    }
    if(uPRI.PickedUpHealth>0)
    {
        Health+=25*uPRI.PickedUpHealth;
    }
    if(uPRI.PickedUpKeg>0)
    {
        Health+=100*uPRI.PickedUpKeg;
    }
    if(uPRI.PickedUpAdren>0)
    {
        Adren+=2*uPRI.PickedUpAdren;
        Lines++;
    }
    if(health>0)
    {
        Lines++;
    }

    if(lines==0)
        return;


    C.Style=5;


    //draw borders
    C.SetDrawColor(255,255,255,255);

    C.SetPos(StartPosX, StartPosY+(boxsizey));
    C.DrawTileStretched(material'Engine.WhiteTexture',(BoxSizeX+BorderSize),BorderSize);

    C.SetPos(StartPosX+BoxSizeX, StartPosY-(Lines-1)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture',(BorderSize),(BorderSize+BoxSizeY)*Lines);

    C.SetPos(StartPosX, StartPosY-(Lines-1)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture',(BorderSize),(BorderSize+BoxSizeY)*Lines);
    C.DrawTileStretched(material'Engine.WhiteTexture',(BoxSizeX+BorderSize),BorderSize);

    //draw background
    C.SetDrawColor(10,10,10,155);
    C.DrawTileStretched(material'Engine.WhiteTexture',(BoxSizeX+BorderSize), lines*(BoxSizeY+BorderSize));
    C.SetDrawColor(255,255,255,255);


        C.SetPos(StartPosX+CharOffset, StartPosY);
        if(Adren>0)
        {
            C.DrawText("Adren:  "$Adren);
            i++;
            C.SetPos(StartPosX+CharOffset, StartPosY-i*(BoxSizeY+BorderSize));
        }
        if(Fifties>0)
        {
            C.DrawText("50s:    "$Fifties);
            i++;
            C.SetPos(StartPosX+CharOffset, StartPosY-i*(BoxSizeY+BorderSize));
        }
        if(Hundreds>0)
        {
            C.DrawText("100s:   "$Hundreds);
            i++;
            C.SetPos(StartPosX+CharOffset, StartPosY-i*(BoxSizeY+BorderSize));
        }
        if(Health>0)
        {
            C.DrawText("Health: "$Health);
            i++;
            C.SetPos(StartPosX+CharOffset, StartPosY-i*(BoxSizeY+BorderSize));
        }
        if(amp>0)
            C.DrawText("DD:     "$Amp);
}

function DrawOtherStats(Canvas C)
{
    local float BoxSizeX;
    local float BoxSizeY;
    local float BorderSize;
    local int NumColumns;
    local int i;
    local int j;
  //  local int k;
    local float StartPosX;
    local float StartPosY;
    local float StrLenX;
    local float StrLenY;
    local float TmpX;
    local float TmpY;
    local UTComp_PRI UxP;
    local array<int> toDrawStandard;
    local string DrawString;
    local float TextOffsetX;
    local float TextOffsetY;
    local bool bShouldDraw;


    bDisplayMessages=!class'UTComp_ScoreBoard'.default.bDrawStats;
    if(!class'UTComp_ScoreBoard'.default.bDrawStats || !Owner.IsA('BS_xPlayer') || BS_xPlayer(Owner).UTCompPRI==None)
        return;


    UxP=BS_xPlayer(Owner).currentStatDraw;
    UxP.UpdatePercentages();

    C.Font=SmallerFont;
    C.StrLen(" 100% / 100%", BoxSizeX, BoxSizeY);
    C.Style=5;
    BorderSize=1.0;
    StartPosX=(0.05*C.ClipX/*-(2.5*boxSizeX+borderSize)*/);
    StartPosY=(C.ClipY*0.9150);
    StartPosY-=BoxSizeY;
    C.StrLen("/", textOffsetX, textOffsetY);
    //Get The Background Size
    for(i=0; i<arraycount(UxP.NormalWepStatsPrim); i++)
    {
        bShouldDraw=True;
        if(UxP.NormalWepStatsPrim[i]!=0 || UxP.NormalWepStatsAlt[i]!=0 || UxP.NormalWepStatsAltHit[i]!=0 || UxP.NormalWepStatsPrimHit[i]!=0)
        {
            for(j=0; j<class'UTComp_Settings'.default.DontDrawInStats.Length; j++)
                if(class'UTComp_Settings'.default.DontDrawInStats[j]==i)
                    bShouldDraw=False;
            if(bShouldDraw)
            {
                NumColumns++;
                ToDrawStandard[ToDrawStandard.Length]=i;
            }
        }
    }

    if(NumColumns==0)
        return;

    //Draw Borders
    C.SetDrawColor(255,255,255,255);
    for(i=-1; i<=NumColumns+2; i++)
    {
        C.SetPos(StartPosX, StartPosY-i*(BoxSizeY+BorderSize)-BorderSize);
        C.DrawTileStretched(material'Engine.WhiteTexture', 5*(BoxSizeX+BorderSize), BorderSize);
    }
    C.SetPos(StartPosX, StartPosY-(NumColumns+2)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture', BorderSize, (NumColumns+3)*(BoxSizeY+BorderSize));

    C.SetPos(StartPosX+BoxSizeX+BorderSize, StartPosY-(NumColumns+1)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture', BorderSize, (NumColumns+1)*(BoxSizeY+BorderSize));

    C.SetPos(StartPosX+5*(BoxSizeX+BorderSize), StartPosY-(NumColumns+2)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture', BorderSize, (NumColumns+3)*(BoxSizeY+BorderSize));

    // Draw Background
    C.SetDrawColor(45,45,45,155);
    C.SetPos(StartPosX, StartPosY-(NumColumns+2)*(BoxSizeY+BorderSize)-BorderSize);
    C.DrawTileStretched(material'Engine.WhiteTexture', 5*(BoxSizeX+BorderSize)+BorderSize, (NumColumns+3)*(BoxSizeY+BorderSize)+BorderSize);

    //Draw Text
    C.SetDrawColor(255,255,255,255);

    //Player Text

    if(class'UTComp_ScoreBoard'.default.bEnableColoredNamesOnScoreboard==True)
        DrawString = "Stats For"@UxP.ColoredName$class'UTComp_Util'.static.MakeColorCode(C.MakeColor(255,255,255))$"."@GetNextKeyString();
    else
        DrawString = "Stats For"@GetNonColoredName(UxP)$"."@GetNextKeyString();
    C.StrLen("Stats For"@GetNonColoredName(UxP)$"."@GetNextKeyString(),StrLenX, strLenY);
    C.SetPos(StartPosX+2.5*(BoxSizeX+BorderSize)-0.5*StrLenX,StartPosY-(NumColumns+2)*(BorderSize+BoxSizeY));
    C.DrawText(DrawString);

    //Headings
    for(i=0; i<5; i++)
    {
        switch(i)
        {

            case 0:  DrawString="Weapon:"; break;
            case 1:  DrawString="Hits:"; break;
            case 2:  DrawString="Fired:"; break;
            case 3:  DrawString="Hit %:"; break;
            case 4:  DrawString="Damage:"; break;
        }
        C.StrLen(DrawString, StrLenX, StrLenY);
        C.SetPos(StartPosX+(i+0.5)*(BoxSizeX+BorderSize)-0.5*StrLenX,StartPosY-(NumColumns+1)*(BorderSize+BoxSizeY));
        C.DrawText(DrawString);
    }
    //Standard weps
    for(i=0; i<NumColumns; i++)
    {
        TmpY=StartPosY-((i+1)*(BoxSizeY+BorderSize));
        TmpX=StartPosX+BorderSize+0.5*TextOffsetX;
        if(i<ToDrawStandard.Length)
            j=ToDrawStandard[i];
        else
            break;

        //Wep Name
        DrawString=BS_xPlayer(Owner).NormalWepStatsPrim[j].WepName;
        C.SetPos(TmpX, TmpY);
        C.DrawText(DrawString);

        //Hit
        DrawString=StatView(UxP.NormalWepStatsPrimHit[j])@"/";
        C.StrLen(DrawString, StrLenX, StrLenY);
        DrawString@=StatView(UxP.NormalWepStatsAltHit[j]);
        if(j == 5 )
        {
            if(UxP.NormalWepStatsAltHit[j] > 0)
            {
                if(UxP.NormalWepStatsAltHit[j] > 99)
                    DrawString$="HS";
                else
                    DrawString@="HS";
            }
        }
        C.SetPos(TmpX+(BorderSize+BoxSizeX)+(0.5*boxSizeX)-strLenX, TmpY);
        C.DrawText(DrawString);

        //Fired
        DrawString=StatView(UxP.NormalWepStatsPrim[j])@"/";
        C.StrLen(DrawString, StrLenX, StrLenY);
        DrawString@=StatView(UxP.NormalWepStatsAlt[j]);
        C.SetPos(TmpX+2*(BorderSize+BoxSizeX)+(0.5*boxSizeX)-strLenX, TmpY);
        C.DrawText(DrawString);

        //Pct
        DrawString=PercView(UxP.NormalWepStatsPrimPercent[j])@"/";
        C.StrLen(DrawString, StrLenX, StrLenY);
        DrawString@=PercView(UxP.NormalWepStatsAltPercent[j]);
        C.SetPos(TmpX+3*(BorderSize+BoxSizeX)+(0.5*boxSizeX)-strLenX, TmpY);
        C.DrawText(DrawString);

        //Damage
        DrawString=StatView(UxP.NormalWepStatsPrimDamage[j])@"/";
        C.StrLen(DrawString, StrLenX, StrLenY);
        DrawString@=StatView(UxP.NormalWepStatsAltDamage[j]);
        C.SetPos(TmpX+4*(BorderSize+BoxSizeX)+(0.5*boxSizeX)-strLenX, TmpY);
        C.DrawText(DrawString);
    }
    TmpY=StartPosY+(BoxSizeY+BorderSize);
    TmpX=StartPosX+BorderSize+0.5*TextOffsetX;
    C.SetPos(TmpX+1*(BorderSize+BoxSizeX), TmpY-BoxSizeY-BorderSize);
    C.DrawText("Damage Received:"@UxP.DamR);
    C.SetPos(TmpX+3*(BorderSize+BoxSizeX), TmpY-BoxSizeY-BorderSize);
    C.DrawText("Damage Given:"@UxP.DamG);
}

function string GetNonColoredName(UTComp_PRI uPRI)
{
   local int i;
   for(i=0; i<GRI.PRIArray.Length; i++)
   {
      if(class'UTComp_util'.static.GetUTCompPRI(GRI.PRIArray[i]) == uPRI)
           return GRI.PRIArray[i].Playername;
   }
   return uPRI.ColoredName;
}

function DrawStats(Canvas C)
{
    local float BoxSizeX;
    local float BoxSizeY;
    local float BorderSize;
    local int NumColumns;
    local int i;
    local int j;
    local int k;
    local float StartPosX;
    local float StartPosY;
    local float StrLenX;
    local float StrLenY;
    local float TmpX;
    local float TmpY;
    local BS_xPlayer UxP;
    local array<int> toDrawStandard;
    local string DrawString;
    local float TextOffsetX;
    local float TextOffsetY;
    local bool bShouldDraw;


    bDisplayMessages=!class'UTComp_ScoreBoard'.default.bDrawStats;
    if(!class'UTComp_ScoreBoard'.default.bDrawStats || !Owner.IsA('BS_xPlayer') || BS_xPlayer(Owner).UTCompPRI==None)
        return;


    UxP=BS_xPlayer(Owner);


    if(UXP.currentStatDraw != None && (UxP.currentStatDraw != UxP.UTCompPRI))
    {
        DrawOtherStats(C);
        return;
    }

    UxP.UpdatePercentages();

    C.Font=SmallerFont;
    C.StrLen(" 100% / 100%", BoxSizeX, BoxSizeY);
    C.Style=5;
    BorderSize=1.0;
    StartPosX=(0.05*C.ClipX/*-(2.5*boxSizeX+borderSize)*/);
    StartPosY=(C.ClipY*0.9150);
    StartPosY-=BoxSizeY;
    C.StrLen("/", textOffsetX, textOffsetY);
    //Get The Background Size
    for(i=0; i<arraycount(UxP.UTCompPRI.NormalWepStatsPrim); i++)
    {
        bShouldDraw=True;
        if(UxP.UTCompPRI.NormalWepStatsPrim[i]!=0 || UxP.UTCompPRI.NormalWepStatsAlt[i]!=0 || UxP.NormalWepStatsAlt[i].Hits!=0 || UxP.NormalWepStatsPrim[i].Hits!=0)
        {
            for(j=0; j<class'UTComp_Settings'.default.DontDrawInStats.Length; j++)
                if(class'UTComp_Settings'.default.DontDrawInStats[j]==i)
                    bShouldDraw=False;
            if(bShouldDraw)
            {
                NumColumns++;
                ToDrawStandard[ToDrawStandard.Length]=i;
            }
        }
    }
    NumColumns+=UxP.CustomWepStats.Length;
    if(NumColumns==0)
        return;

    //Draw Borders
    C.SetDrawColor(255,255,255,255);
    for(i=-1; i<=NumColumns+2; i++)
    {
        C.SetPos(StartPosX, StartPosY-i*(BoxSizeY+BorderSize)-BorderSize);
        C.DrawTileStretched(material'Engine.WhiteTexture', 5*(BoxSizeX+BorderSize), BorderSize);
    }
    C.SetPos(StartPosX, StartPosY-(NumColumns+2)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture', BorderSize, (NumColumns+3)*(BoxSizeY+BorderSize));

    C.SetPos(StartPosX+BoxSizeX+BorderSize, StartPosY-(NumColumns+1)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture', BorderSize, (NumColumns+1)*(BoxSizeY+BorderSize));

    C.SetPos(StartPosX+5*(BoxSizeX+BorderSize), StartPosY-(NumColumns+2)*(BoxSizeY+BorderSize));
    C.DrawTileStretched(material'Engine.WhiteTexture', BorderSize, (NumColumns+3)*(BoxSizeY+BorderSize));

    // Draw Background
    C.SetDrawColor(10,10,10,155);
    C.SetPos(StartPosX, StartPosY-(NumColumns+2)*(BoxSizeY+BorderSize)-BorderSize);
    C.DrawTileStretched(material'Engine.WhiteTexture', 5*(BoxSizeX+BorderSize)+BorderSize, (NumColumns+3)*(BoxSizeY+BorderSize)+BorderSize);

    //Draw Text
    C.SetDrawColor(255,255,255,255);

    if(class'UTComp_ScoreBoard'.default.bEnableColoredNamesOnScoreboard==True)
        DrawString = "Stats For"@UxP.UTCompPRI.ColoredName$class'UTComp_Util'.static.MakeColorCode(C.MakeColor(255,255,255))$"."@GetNextKeyString();
    else
        DrawString = "Stats For"@GetNonColoredName(UxP.UTCompPRI)$"."@GetNextKeyString();
    C.StrLen("Stats For"@GetNonColoredName(UxP.UTCompPRI)$"."@GetNextKeyString(),StrLenX, strLenY);
    C.SetPos(StartPosX+2.5*(BoxSizeX+BorderSize)-0.5*StrLenX,StartPosY-(NumColumns+2)*(BorderSize+BoxSizeY));
    C.DrawText(DrawString);

    //Headings
    for(i=0; i<5; i++)
    {
        switch(i)
        {

            case 0:  DrawString="Weapon:"; break;
            case 1:  DrawString="Hits:"; break;
            case 2:  DrawString="Fired:"; break;
            case 3:  DrawString="Hit %:"; break;
            case 4:  DrawString="Damage:"; break;
        }
        C.StrLen(DrawString, StrLenX, StrLenY);
        C.SetPos(StartPosX+(i+0.5)*(BoxSizeX+BorderSize)-0.5*StrLenX,StartPosY-(NumColumns+1)*(BorderSize+BoxSizeY));
        C.DrawText(DrawString);
    }
    //Standard weps
    for(i=0; i<NumColumns; i++)
    {
        TmpY=StartPosY-((i+1)*(BoxSizeY+BorderSize));
        TmpX=StartPosX+BorderSize+0.5*TextOffsetX;
        if(i<ToDrawStandard.Length)
            j=ToDrawStandard[i];
        else
            break;

        //Wep Name
        DrawString=UxP.NormalWepStatsPrim[j].WepName;
        C.SetPos(TmpX, TmpY);
        C.DrawText(DrawString);

        //Hit
        DrawString=StatView(UxP.NormalWepStatsPrim[j].Hits)@"/";
        C.StrLen(DrawString, StrLenX, StrLenY);
        DrawString@=StatView(UxP.NormalWepStatsAlt[j].Hits);
        if(j == 5 )
        {
            if(UxP.NormalWepStatsAlt[j].Hits > 0)
            {
                if(UxP.NormalWepStatsAlt[j].Hits > 99)
                    DrawString$="HS";
                else
                    DrawString@="HS";
            }
        }
        C.SetPos(TmpX+(BorderSize+BoxSizeX)+(0.5*boxSizeX)-strLenX, TmpY);
        C.DrawText(DrawString);

        //Fired
        DrawString=StatView(UxP.UTCompPRI.NormalWepStatsPrim[j])@"/";
        C.StrLen(DrawString, StrLenX, StrLenY);
        DrawString@=StatView(UxP.UTCompPRI.NormalWepStatsAlt[j]);
        C.SetPos(TmpX+2*(BorderSize+BoxSizeX)+(0.5*boxSizeX)-strLenX, TmpY);
        C.DrawText(DrawString);

        //Pct
        DrawString=PercView(UxP.NormalWepStatsPrim[j].Percent)@"/";
        C.StrLen(DrawString, StrLenX, StrLenY);
        DrawString@=PercView(UxP.NormalWepStatsAlt[j].Percent);
        C.SetPos(TmpX+3*(BorderSize+BoxSizeX)+(0.5*boxSizeX)-strLenX, TmpY);
        C.DrawText(DrawString);

        //Damage
        DrawString=StatView(UxP.NormalWepStatsPrim[j].Damage)@"/";
        C.StrLen(DrawString, StrLenX, StrLenY);
        DrawString@=StatView(UxP.NormalWepStatsAlt[j].Damage);
        C.SetPos(TmpX+4*(BorderSize+BoxSizeX)+(0.5*boxSizeX)-strLenX, TmpY);
        C.DrawText(DrawString);
    }
    //Custom Weps
    while(i<NumColumns)
    {

        TmpY=StartPosY-((i+1)*(BoxSizeY+BorderSize));
        TmpX=StartPosX+BorderSize+0.5*TextOffsetX;
        if(k>=UxP.CustomWepStats.Length)
            break;
        //Wep Name
        C.SetPos(TmpX, TmpY);
        if(UxP.CustomWepStats[k].WepName!="")
            C.DrawText(UxP.CustomWepStats[k].WepName);
        else
            C.DrawText("Custom "$k);
        TmpX+=BoxSizeX*0.4;
        //Hit
        C.SetPos(TmpX+(BorderSize+BoxSizeX), TmpY);
        C.DrawText(UxP.CustomWepStats[k].Hits);

        //Fired
        C.SetPos(TmpX+2*(BorderSize+BoxSizeX), TmpY);
        C.DrawText("");

        //Pct
        C.SetPos(TmpX+3*(BorderSize+BoxSizeX), TmpY);
        C.DrawText("");

        //Damage
        C.SetPos(TmpX+4*(BorderSize+BoxSizeX), TmpY);
        C.DrawText(UxP.CustomWepStats[k].Damage);
        i++;
        k++;
    }
    TmpY=StartPosY+(BoxSizeY+BorderSize);
    TmpX=StartPosX+BorderSize+0.5*TextOffsetX;
    C.SetPos(TmpX+1*(BorderSize+BoxSizeX), TmpY-BoxSizeY-BorderSize);
    C.DrawText("Damage Received:"@UxP.UTCompPRI.DamR);
    C.SetPos(TmpX+3*(BorderSize+BoxSizeX), TmpY-BoxSizeY-BorderSize);
    C.DrawText("Damage Given:"@UxP.DamG);
}

function string GetNextKeyString()
{
    local string key;
    local color Col;

    key = class'GameInfo'.Static.GetKeyBindName("NextStats", BS_xPlayer(owner));
    col.R=255;
    Col.G=255;
    Col.B=255;

    return "Press"@key@"for next player.";
}


function string StatView(coerce string S)
{
    if(S~="0" || S~= "0.00")
        return "";
    else
        return S;
}

function string PercView(coerce string S)
{
    if(S~="0")
        return "";
    else
        return S$"%";
}

simulated function NextStats()
{
    if(BS_xPlayer(Owner)!=None)
        BS_xPlayer(Owner).StatNext();
}

defaultproperties
{
}
