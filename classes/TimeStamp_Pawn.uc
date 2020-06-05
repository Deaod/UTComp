//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TimeStamp_Pawn extends Pawn;

var int timestamp;
var int NewTimeStamp;
var float dt;

function prebeginplay()
{
    super.prebeginplay();
}

function PossessedBy(Controller C)
{
   Super.PossessedBy(C);
   NetPriority=default.NetPriority;
}
function destroyed()
{
   super.destroyed();

}

simulated event tick(float deltatime)
{
   Super.tick(deltatime);
   NewTimeStamp = (Rotation.Yaw+Rotation.Pitch*256)/256;
   DT+=deltatime;
   if(NewTimeStamp > TimeStamp || TimeStamp-NewTimeStamp > 5000)
   {
       TimeStamp=NewTimeStamp;
       DT=0.00;
   }
}

DefaultProperties
{
    ControllerClass = class'TimeStamp_Controller'
    bAlwaysRelevant=true
    NetPriority=50
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bProjTarget=false
    bCanBeDamaged=false
    bAcceptsProjectors=false
    bCanTeleport=false
    bBlockPlayers=false
    bDisturbFluidSurface=false
    Physics=Phys_None
}
