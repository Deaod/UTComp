

class UTV_BS_xPlayer extends BS_xPlayer;

var string utvOverideUpdate;
var string utvFreeFlight;
var string utvLastTargetName;
var string utvPos;


function LongClientAdjustPosition
(
    float TimeStamp,
    name newState,
    EPhysics newPhysics,
    float NewLocX,
    float NewLocY,
    float NewLocZ,
    float NewVelX,
    float NewVelY,
    float NewVelZ,
    Actor NewBase,
    float NewFloorX,
    float NewFloorY,
    float NewFloorZ
)
{
	local Actor myTarget;

	Super.LongClientAdjustPosition(TimeStamp, newState, newPhysics, NewLocX,NewLocY,NewLocZ,NewVelX,newVelY, newVelZ, NewBase, NewFloorX, NewFloorY, NewFloorZ);

//	ClientMessage(getstatename());
	if(utvOverideUpdate=="true"){
		bUpdatePosition=false;
//		ClientMessage("Adjust position overridden by utvreplication");
		if(utvFreeFlight=="true"){
			bBehindView=false;
			SetViewTarget(self);
			SetLocation(vector(utvPos));
			if(pawn!=none){
				Pawn.SetLocation(vector(utvPos));
			}
		} else {
			target=GetPawnFromName(utvLastTargetName);
			if(myTarget!=none)
				SetViewTarget(myTarget);
		}
	}
}

simulated function Pawn GetPawnFromName(string name)
{
	local Pawn tempPawn;

	foreach AllActors(class'Pawn',tempPawn){
		if(tempPawn.PlayerReplicationInfo!=none && tempPawn.PlayerReplicationInfo.PlayerName==name){
			return tempPawn;
			break;
		}
	}
	return none;
}

state Spectating
{
    simulated function PlayerMove(float DeltaTime)
    {
		local Actor myTarget;

		if(utvOverideUpdate=="true" && !(utvFreeFlight=="true")){
			myTarget=GetPawnFromName(utvLastTargetName);
			if(myTarget!=none){
				SetViewTarget(myTarget);
				TargetViewRotation=myTarget.rotation;
			}
		}
		Super.PlayerMove(DeltaTime);
	}
}

defaultproperties
{
     utvOverideUpdate="false"
     utvFreeFlight="false"
     bAllActorsRelevant=True
}
