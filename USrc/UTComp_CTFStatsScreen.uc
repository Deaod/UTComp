class UTComp_CTFStatsScreen extends DMStatsScreen;

var UTComp_PRI uPRI;

var localized string FlagCaps, FlagGrabs, FlagPickups, FlagKills, FlagSaves, FlagDenials, Assists, Covers, Seals, DefKills;

function NextStats()
{
	local int i,j;

	if ( (PlayerOwner == None) || (PlayerOwner.GameReplicationInfo == None) )
		return;

	LastUpdateTime = 0;
	for ( i=0; i<PlayerOwner.GameReplicationInfo.PRIArray.Length-1; i++ )
		if ( PRI == PlayerOwner.GameReplicationInfo.PRIArray[i] )
		{
			for ( j=i+1; j<PlayerOwner.GameReplicationInfo.PRIArray.Length; j++ )
			{
				PRI = TeamPlayerReplicationInfo(PlayerOwner.GameReplicationInfo.PRIArray[j]);
				uPRI = class'UTComp_Util'.static.GetUTCompPRI(PRI);
				if ( PRI != None )
					return;
			}
		}
	PRI = TeamPlayerReplicationInfo(PlayerOwner.GameReplicationInfo.PRIArray[0]);
	uPRI = class'UTComp_Util'.static.GetUTCompPRI(PRI);
}

simulated event DrawScoreboard( Canvas C )
{
	local int i,j, temp, AwardsNum, CombosNum,GoalsNum;
	local int Ordered[20];
	local float OffsetY;
	local float AwardsOffsetY, CombosOffsetY, GoalsOffsetY, CombatOffsetY, WeaponsOffsetY, VehiclesOffsetY;
	local float AwardsBoxSizeY, CombosBoxSizeY, GoalsBoxSizeY, CombatBoxSizeY, WeaponsBoxSizeY, VehiclesBoxSizeY, XL, LargeYL;
	local float IndentX, AwardWidth, WeaponWidth, AwardX, AwardsBoxX, CombatBoxX, GoalsBoxX, CombosBoxX;
	local float GoalsBoxXOffset, GoalsBoxColumnX, GoalsBoxColumn;
	if ( PlayerOwner == None )
	{
		PlayerOwner = UnrealPlayer(Owner);
		if ( PlayerOwner == None )
		{
			C.SetPos(IndentX,IndentX);
			C.DrawText(WaitingForStats);
			return;
		}
	}
	if ( PRI == None )
	{
		PRI = TeamPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo);
		if ( PRI == None )
		{
			C.SetPos(IndentX,IndentX);
			C.DrawText(WaitingForStats);
			return;
		}
	}

	if (uPRI == None)
	{
		uPRI = class'UTComp_Util'.static.GetUTCompPRI(PRI);
		if (uPRI == None)
		{
			C.SetPos(IndentX,IndentX);
			C.DrawText(WaitingForStats);
			return;
		}
	}

	if ( Level.TimeSeconds - LastUpdateTime > 2 )
	{
		LastUpdateTime = Level.TimeSeconds;
		PlayerOwner.ServerUpdateStats(PRI);
		BS_xPlayer(PlayerOwner).RequestCTFStats(uPRI);
	}
	C.DrawColor = HUDClass.default.WhiteColor;

	// draw boxes
	C.Font = PlayerOwner.myHUD.GetFontSizeIndex(C,-2);
	C.StrLen(StatsString, XL, LargeYL);

	IndentX = 0.015 * C.ClipX;
	AwardsOffsetY = IndentX + 2*LargeYL;

	if ( PRI.bFirstBlood )
		AwardsNum++;

	for ( i=0; i<6; i++ )
		if ( PRI.Spree[i] > 0 )
			AwardsNum++;

	for ( i=0; i<7; i++ )
		if ( PRI.MultiKills[i] > 0 )
			AwardsNum++;

	if ( PRI.flakcount >= 15 )
		AwardsNum++;
	if ( PRI.combocount >= 15 )
		AwardsNum++;
	if ( PRI.headcount >= 15 )
		AwardsNum++;
	if ( PRI.ranovercount >= 10 )
		AwardsNum++;
	if ( PRI.DaredevilPoints > 0 )
		AwardsNum++;
	if ( PRI.GoalsScored >= 3 )
		AwardsNum++;

	C.StrLen("REALLY X999"$KillString[5], AwardWidth, LargeYL);
	if ( AwardsNum > 0 )
	{
		AwardsBoxX = FMin(0.9*C.ClipX, Min(3,AwardsNum)*AwardWidth + 4*IndentX);
		AwardsBoxSizeY = LargeYL + (2 + (AwardsNum-1)/3) * LargeYL;
		C.SetPos(IndentX, AwardsOffsetY);
		C.DrawColor = HUDClass.default.PurpleColor;
		C.DrawColor.R = 128;
		C.DrawTileStretched( BoxMaterial, AwardsBoxX, AwardsBoxSizeY);
	}

	CombosOffsetY = AwardsOffsetY + AwardsBoxSizeY + 0.5*LargeYL;
	for ( i=0; i<5; i++ )
		if ( PRI.Combos[i] > 0 )
			CombosNum++;

	if ( CombosNum > 0 )
	{
		C.DrawColor = HUDClass.default.BlueColor;
		CombosBoxSizeY = LargeYL + (1+CombosNum) * LargeYL;
		C.SetPos(IndentX, CombosOffsetY);
		C.StrLen(AdrenalineCombos, XL, LargeYL);
		CombosBoxX = 4*IndentX + 2*XL;
		C.DrawTileStretched( BoxMaterial, CombosBoxX, CombosBoxSizeY);
	}

	C.DrawColor = HUDClass.default.GreenColor;
	CombatOffsetY = CombosOffsetY + CombosBoxSizeY + 0.5*LargeYL;
	CombatBoxSizeY = LargeYL + 4 * LargeYL;
	C.SetPos(IndentX, CombatOffsetY);
	C.StrLen(CombatResults, XL, LargeYL);
	CombatBoxX = XL + 4*IndentX;
	C.DrawTileStretched( BoxMaterial, CombatBoxX, CombatBoxSizeY);

	GoalsOffsetY = CombatOffsetY;

	if (uPRI.FlagCaps > 0)
		GoalsNum++;
	if (uPRI.FlagGrabs > 0)
		GoalsNum++;
	if (uPRI.FlagPickups > 0)
		GoalsNum++;
	if (uPRI.FlagKills > 0)
		GoalsNum++;
	if (PRI.FlagReturns > 0)
		GoalsNum++;
	if (uPRI.FlagSaves > 0)
		GoalsNum++;
	if (uPRI.FlagDenials > 0)
		GoalsNum++;

	if (uPRI.Assists > 0)
		GoalsNum++;
	if (uPRI.Covers > 0)
		GoalsNum++;
	if (uPRI.Seals > 0)
		GoalsNum++;
	if (uPRI.DefKills > 0)
		GoalsNum++;

	


	if ( GoalsNum > 0 )
	{
		C.DrawColor = HUDClass.default.GoldColor;
		GoalsBoxSizeY = LargeYL + Min(5, GoalsNum) * LargeYL;
		C.SetPos(3*IndentX+CombatBoxX, GoalsOffsetY);
		C.StrLen(FlagPickups$" 999 XXXxxXX", XL, LargeYL);
		GoalsBoxX = CombatBoxX;
		GoalsBoxColumnX = CombatBoxX;
		if (GoalsNum > 5)
			GoalsBoxX = 2 * GoalsBoxX;
		C.DrawTileStretched( BoxMaterial, GoalsBoxX, GoalsBoxSizeY);
	}

	C.DrawColor = HUDClass.default.WhiteColor;
	WeaponsOffsetY = GoalsOffsetY + FMax(CombatBoxSizeY,GoalsBoxSizeY) + 0.5*LargeYL;
	WeaponsBoxSizeY = FMin(3*LargeYL + PRI.WeaponStatsArray.Length * LargeYL, C.ClipY - WeaponsOffsetY - IndentX);
	C.SetPos(IndentX, WeaponsOffsetY);
	C.StrLen("ROCKET LAUNCHER REALLY", WeaponWidth, LargeYL);
	C.DrawTileStretched( BoxMaterial, C.ClipX - 2*IndentX, WeaponsBoxSizeY);

	if (PRI.VehicleStatsArray.length > 0)
	{
		VehiclesOffsetY = WeaponsOffsetY + WeaponsBoxSizeY + 0.5*LargeYL;
		VehiclesBoxSizeY = FMin(3*LargeYL + PRI.VehicleStatsArray.Length * LargeYL, C.ClipY - VehiclesOffsetY - IndentX);
		C.SetPos(IndentX, VehiclesOffsetY);
		C.DrawTileStretched(BoxMaterial, C.ClipX - 2*IndentX, VehiclesBoxSizeY);
	}

	// Draw text
	C.SetPos(IndentX,IndentX);
	C.DrawText(StatsString@PRI.PlayerName);
	C.SetPos(IndentX,IndentX+LargeYL);

	if ( (Level.NetMode == NM_Client) && (PRI.WeaponStatsArray.Length == 0) && (AwardsNum == 0) && (CombosNum == 0) && (GoalsNum == 0) )
		C.DrawText(WaitingForStats);
	else
		C.DrawText(NextStatsString);

	if ( AwardsNum > 0 )
	{
		AwardsNum = 0;
		AwardX = 2*IndentX;
		OffsetY = AwardsOffsetY + 0.5*LargeYL;
		C.SetPos(AwardX,OffsetY);
		C.DrawColor = HUDClass.default.GoldColor;
		C.DrawText(AwardsString);
		OffsetY += LargeYL;
		C.SetPos(AwardX,OffsetY);

		C.DrawColor = HUDClass.default.RedColor;
		if ( PRI.bFirstBlood )
		{
			C.DrawText(FirstBloodString);
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		C.DrawColor = HUDClass.default.TurqColor;
		for ( i=0; i<6; i++ )
			if ( PRI.Spree[i] > 0 )
			{
				C.DrawText(class'KillingSpreeMessage'.default.SelfSpreeNote[i]@MakeColorCode(HUDClass.default.GoldColor)$"X"$PRI.Spree[i]);
				AwardsNum++;
				if ( AwardsNum%3 == 0 )
					OffsetY += LargeYL;
				C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
			}

		C.DrawColor = HUDClass.default.RedColor;
		C.DrawColor.G = 128;
		for ( i=0; i<7; i++ )
			if ( PRI.MultiKills[i] > 0 )
			{
				C.DrawText(KillString[i]@MakeColorCode(HUDClass.default.GoldColor)$"X"$PRI.MultiKills[i]);
				AwardsNum++;
				if ( AwardsNum%3 == 0 )
					OffsetY += LargeYL;
				C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
			}

		C.DrawColor = HUDClass.default.WhiteColor;
		if ( PRI.flakcount >= 15 )
		{
			C.DrawText(FlakMonkey);
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		if ( PRI.combocount >= 15 )
		{
			C.DrawText(ComboWhore);
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		if ( PRI.headcount >= 15 )
		{
			C.DrawText(HeadHunter);
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		if ( PRI.ranovercount >= 10 )
		{
			C.DrawText(RoadRampage);
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		if ( PRI.GoalsScored >= 3 )
		{
			C.DrawColor = HUDClass.default.GoldColor;
			C.DrawText(HatTrick);
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		if ( PRI.DaredevilPoints > 0 )
		{
			C.DrawText(DaredevilString@MakeColorCode(HUDClass.default.GoldColor)$PRI.DaredevilPoints);
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
	}

	if ( CombosNum > 0 )
	{
		CombosNum = 0;
		OffsetY = CombosOffsetY + 0.5*LargeYL;
		C.SetPos(2*IndentX,OffsetY);
		C.DrawColor = HUDClass.default.GoldColor;
		C.DrawText(AdrenalineCombos);
		OffsetY += LargeYL;
		C.SetPos(2*IndentX,OffsetY);
		C.DrawColor = HUDClass.default.CyanColor;
		for ( i=0; i<5; i++ )
			if ( PRI.Combos[i] > 0 )
			{
				C.DrawText(ComboNames[i]@MakeColorCode(HUDClass.default.GoldColor)$"X"$PRI.Combos[i]);
				CombosNum++;
				if ( CombosNum%2 == 0 )
					OffsetY += LargeYL;
				C.SetPos(2*IndentX + (CombosNum%2)*0.5*CombosBoxX,OffsetY);
			}
	}

	C.DrawColor = HUDClass.default.GoldColor;
	OffsetY = CombatOffsetY + 0.5*LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(CombatResults);
	C.DrawColor = HUDClass.default.WhiteColor;
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(Kills);
	C.StrLen(PRI.Kills, XL, LargeYL);
	C.SetPos(CombatBoxX - XL - 2*IndentX,OffsetY);
	C.DrawText(PRI.Kills);
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(Deaths);
	C.StrLen(int(PRI.Deaths), XL, LargeYL);
	C.SetPos(CombatBoxX - XL - 2*IndentX,OffsetY);
	C.DrawText(int(PRI.Deaths));
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(Suicides);
	C.StrLen(PRI.Suicides, XL, LargeYL);
	C.SetPos(CombatBoxX - XL - 2*IndentX,OffsetY);
	C.DrawText(PRI.Suicides);

	if ( GoalsNum > 0 )
	{
		if (GoalsNum > 4)
			GoalsBoxXOffset = CombatBoxX / 2.0;

		GoalsNum = 0;
		GoalsBoxColumn = 0;

		C.DrawColor = HUDClass.default.CyanColor;
		OffsetY = CombatOffsetY + 0.5*LargeYL;
		C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		if ( uPRI.FlagCaps > 0 )
		{
			C.DrawText(FlagCaps);
			C.StrLen(PRI.GoalsScored, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.FlagCaps);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.FlagGrabs > 0 )
		{
			C.DrawText(FlagGrabs);
			C.StrLen(uPRI.FlagGrabs, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.FlagGrabs);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.FlagPickups > 0 )
		{
			C.DrawText(FlagPickups);
			C.StrLen(uPRI.FlagPickups, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.FlagPickups);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.FlagKills > 0 )
		{
			C.DrawText(FlagKills);
			C.StrLen(uPRI.FlagKills, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.FlagKills);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( PRI.FlagReturns > 0 )
		{
			C.DrawText(FlagReturns);
			C.StrLen(PRI.FlagReturns, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(PRI.FlagReturns);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.FlagDenials > 0 )
		{
			C.DrawText(FlagDenials);
			C.StrLen(uPRI.FlagDenials, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.FlagDenials);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.FlagSaves > 0 )
		{
			C.DrawText(FlagSaves);
			C.StrLen(uPRI.FlagSaves, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.FlagSaves);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.Assists > 0 )
		{
			C.DrawText(Assists);
			C.StrLen(uPRI.Assists, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.Assists);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.Covers > 0 )
		{
			C.DrawText(Covers);
			C.StrLen(uPRI.Covers, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.Covers);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.Seals > 0 )
		{
			C.DrawText(Seals);
			C.StrLen(uPRI.Seals, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.Seals);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}

		if ( uPRI.DefKills > 0 )
		{
			C.DrawText(DefKills);
			C.StrLen(uPRI.DefKills, XL, LargeYL);
			C.SetPos((GoalsBoxColumn+1)*IndentX+CombatBoxX+(GoalsBoxColumn+1)*GoalsBoxColumnX - XL,OffsetY);
			C.DrawText(uPRI.DefKills);
			OffsetY += LargeYL;
			GoalsNum++;
			if (GoalsNum == 5 && GoalsBoxColumn == 0)
			{
				GoalsBoxColumn = 1;
				OffsetY = CombatOffsetY + 0.5*LargeYL;
			}
			C.SetPos(4*IndentX+CombatBoxX+GoalsBoxColumn*(GoalsBoxColumnX+IndentX),OffsetY);
		}
	}

	//weapon stats
	OffsetY = WeaponsOffsetY + 0.5*LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawColor = HUDClass.default.GoldColor;
	C.DrawText(KillsByWeapon);
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawColor = HUDClass.default.GrayColor;
	C.DrawColor.G = 255;

	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(WeaponString);
	C.SetPos(2*IndentX + WeaponWidth,OffsetY);
	C.DrawText(Kills);
	C.SetPos(2*IndentX + WeaponWidth + 0.2 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
	C.DrawText(DeathsBy);
	C.SetPos(2*IndentX + WeaponWidth + 0.5 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
	C.DrawText(DeathsHolding);
	C.SetPos(2*IndentX + WeaponWidth + 0.8 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
	C.DrawText(EfficiencyString);
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawColor = HUDClass.default.GreenColor;

	for ( i=0; i<PRI.WeaponStatsArray.Length; i++ )
		Ordered[i] = i;

	for ( i=0; i<PRI.WeaponStatsArray.Length; i++ )
	{
		for ( j=i; j<PRI.WeaponStatsArray.Length; j++ )
		{
			if ( PRI.WeaponStatsArray[Ordered[i]].Kills < PRI.WeaponStatsArray[Ordered[j]].Kills )
			{
				temp = Ordered[i];
				Ordered[i] = Ordered[j];
				Ordered[j] = temp;
			}
		}
	}
	for ( i=0; i<PRI.WeaponStatsArray.Length; i++ )
	{
		C.DrawText(PRI.WeaponStatsArray[Ordered[i]].WeaponClass.Default.ItemName);
		C.SetPos(2*IndentX + WeaponWidth,OffsetY);
		C.DrawText(PRI.WeaponStatsArray[Ordered[i]].Kills);
		C.SetPos(2*IndentX + WeaponWidth + 0.2 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		C.DrawText(PRI.WeaponStatsArray[Ordered[i]].Deaths);
		C.SetPos(2*IndentX + WeaponWidth + 0.5 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		C.DrawText(PRI.WeaponStatsArray[Ordered[i]].DeathsHolding);
		C.SetPos(2*IndentX + WeaponWidth + 0.8 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		if ( PRI.WeaponStatsArray[Ordered[i]].DeathsHolding+PRI.WeaponStatsArray[Ordered[i]].Kills == 0 )
			C.DrawText("0%");
		else
			C.DrawText(int(100 * float(PRI.WeaponStatsArray[Ordered[i]].Kills)/float(PRI.WeaponStatsArray[Ordered[i]].DeathsHolding+PRI.WeaponStatsArray[Ordered[i]].Kills))$"%");

		OffsetY += LargeYL;
		C.SetPos(2*IndentX,OffsetY);

		if ( OffsetY > C.ClipY - LargeYL - IndentX )
			break;
	}

	//vehicle stats
	if (PRI.VehicleStatsArray.Length > 0)
	{
		OffsetY = VehiclesOffsetY + 0.5*LargeYL;
		C.SetPos(2*IndentX,OffsetY);
		C.DrawColor = HUDClass.default.GoldColor;
		C.DrawText(KillsByVehicle);
		OffsetY += LargeYL;
		C.SetPos(2*IndentX,OffsetY);
		C.DrawColor = HUDClass.default.GrayColor;
		C.DrawColor.G = 255;

		C.SetPos(2*IndentX,OffsetY);
		C.DrawText(VehicleString);
		C.SetPos(2*IndentX + WeaponWidth,OffsetY);
		C.DrawText(Kills);
		C.SetPos(2*IndentX + WeaponWidth + 0.2 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		C.DrawText(DeathsBy);
		C.SetPos(2*IndentX + WeaponWidth + 0.5 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		C.DrawText(DeathsHolding);
		C.SetPos(2*IndentX + WeaponWidth + 0.8 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		C.DrawText(EfficiencyString);
		OffsetY += LargeYL;
		C.SetPos(2*IndentX,OffsetY);
		C.DrawColor = HUDClass.default.GreenColor;

		for ( i=0; i<PRI.VehicleStatsArray.Length; i++ )
			Ordered[i] = i;

		for ( i=0; i<PRI.VehicleStatsArray.Length; i++ )
		{
			for ( j=i; j<PRI.VehicleStatsArray.Length; j++ )
			{
				if ( PRI.VehicleStatsArray[Ordered[i]].Kills < PRI.VehicleStatsArray[Ordered[j]].Kills )
				{
					temp = Ordered[i];
					Ordered[i] = Ordered[j];
					Ordered[j] = temp;
				}
			}
		}
		for ( i=0; i<PRI.VehicleStatsArray.Length; i++ )
		{
			C.DrawText(PRI.VehicleStatsArray[Ordered[i]].VehicleClass.Default.VehicleNameString);
			C.SetPos(2*IndentX + WeaponWidth,OffsetY);
			C.DrawText(PRI.VehicleStatsArray[Ordered[i]].Kills);
			C.SetPos(2*IndentX + WeaponWidth + 0.2 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
			C.DrawText(PRI.VehicleStatsArray[Ordered[i]].Deaths);
			C.SetPos(2*IndentX + WeaponWidth + 0.5 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
			C.DrawText(PRI.VehicleStatsArray[Ordered[i]].DeathsDriving);
			C.SetPos(2*IndentX + WeaponWidth + 0.8 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
			if ( PRI.VehicleStatsArray[Ordered[i]].DeathsDriving+PRI.VehicleStatsArray[Ordered[i]].Kills == 0 )
				C.DrawText("0%");
			else
				C.DrawText(int(100 * float(PRI.VehicleStatsArray[Ordered[i]].Kills)/float(PRI.VehicleStatsArray[Ordered[i]].DeathsDriving+PRI.VehicleStatsArray[Ordered[i]].Kills))$"%");

			OffsetY += LargeYL;
			C.SetPos(2*IndentX,OffsetY);

			if ( OffsetY > C.ClipY - LargeYL - IndentX )
				break;
		}
	}
}

DefaultProperties
{
	FlagCaps = "Flag Captures"
	FlagGrabs = "Flag Grabs"
	FlagPickups = "Flag Pickups"
	FlagKills = "Flag Kills"
	FlagSaves = "Flag Saves"
	FlagDenials = "Flag Denials"
	Assists = "Assists"
	Covers = "Covers"
	Seals = "Seals"
	DefKills = "Defender Kills"
}