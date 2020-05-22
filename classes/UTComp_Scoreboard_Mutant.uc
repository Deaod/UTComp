

class UTComp_Scoreboard_Mutant extends UTComp_ScoreBoardDM;


var()	Material	BottomFeederMarker;
var()	Material	MutantMarker;

function ExtraMarking(Canvas Canvas, int PlayerCount, int OwnerOffset, int XPos, int YPos, int YOffset)
{
	local int i, OwnerPos;
	local float IconScale;
	local MutantGameReplicationInfo MutantInfo;

	MutantInfo = MutantGameReplicationInfo(GRI);

	// draw mutant and BF marker
	IconScale = Canvas.ClipX/1024;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.Style = ERenderStyle.STY_Normal;

	for ( i=0; i<PlayerCount; i++ )
	{
		// If this is the bottom feeder
		if( MutantInfo.BottomFeederPRI == GRI.PRIArray[i] )
		{
			Canvas.SetPos(XPos - 64*IconScale, YPos*i + YOffset - 16*IconScale);
			Canvas.DrawTile( BottomFeederMarker, 64*IconScale, 64*IconScale, 0, 0, 256, 256);
		}

		// If this is the mutant (should never be able to be both!!!)
		if( MutantInfo.MutantPRI == GRI.PRIArray[i] )
		{
			Canvas.SetPos(XPos - 64*IconScale, YPos*i + YOffset);
			Canvas.DrawTile( MutantMarker, 64*IconScale, 32*IconScale, 0, 0, 256, 128);
		}
	}

	if ( OwnerOffset >= PlayerCount )
	{
		OwnerPos = YPos*PlayerCount + YOffset;

		// Mutant/Bottom Feeder marker for owner
		if( MutantInfo.BottomFeederPRI == GRI.PRIArray[OwnerOffset] )
		{
			Canvas.SetPos(XPos - 64*IconScale, OwnerPos - 16*IconScale);
			Canvas.DrawTile( BottomFeederMarker, 64*IconScale, 64*IconScale, 0, 0, 256, 256);
		}

		if( MutantInfo.MutantPRI == GRI.PRIArray[OwnerOffset] )
		{
			Canvas.SetPos(XPos - 64*IconScale, OwnerPos);
			Canvas.DrawTile( MutantMarker, 64*IconScale, 32*IconScale, 0, 0, 256, 128);
		}
	}
}

defaultproperties
{
	BottomFeederMarker=Material'MutantSkins.BFeeder_icon'
	MutantMarker=Material'MenuEffects.ScoreboardU_FB'
}

