
class NewNet_LinkProjectile extends LinkProjectile;

var PlayerController PC;
var vector DesiredDeltaFake;
var float CurrentDeltaFakeTime;
var bool bInterpFake;
var bool bOwned;

var FakeProjectileManager FPM;

var int Index;

replication
{
    reliable if(Role == Role_Authority && bNetInitial)
       Index;
    unreliable if(bDemoRecording)
       DoMove, DoSetLoc;
}

const INTERP_TIME = 0.250;

simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    if(Level.NetMode != NM_Client)
        return;

    PC = Level.GetLocalPlayerController();
    if (CheckOwned())
       CheckForFakeProj();
}

simulated function bool CheckOwned()
{
    if(class'UTComp_Settings'.default.bEnableEnhancedNetCode==false)
        return false;
    bOwned = (PC!=None && PC.Pawn!=None && PC.Pawn == Instigator);
    return bOwned;
}

simulated function DoMove(Vector V)
{
    Move(V);
}

simulated function DoSetLoc(Vector V)
{
    SetLocation(V);
}


simulated function bool CheckForFakeProj()
{
     local float ping;
     local Projectile FP;

     ping = FMax(0.0, class'NewNet_PRI'.default.PredictedPing - 0.5*class'TimeStamp'.default.AverDT);

     if(FPM == none)
        FindFPM();
     FP = FPM.GetFP(class'NewNet_Fake_LinkProjectile', index);
     if(FP != none)
     {
         bInterpFake=true;
         DesiredDeltaFake = Location - FP.Location;
         DoSetLoc(FP.Location);
         FPM.RemoveProjectile(FP);
         bOwned=False;
         return true;
     }
     return false;
}



simulated function FindFPM()
{
    foreach DynamicActors(class'FakeProjectileManager', FPM)
        break;
}


simulated function Tick(float deltatime)
{
    super.Tick(deltatime);
    if(Level.NetMode != NM_Client)
        return;
    if(bInterpFake)
        FakeInterp(deltatime);
    else if(bOwned)
        CheckForFakeProj();
}

simulated function FakeInterp(float dt)
{
    local vector V;
    local float OldDeltaFakeTime;

    V=DesiredDeltaFake*dt/INTERP_TIME;

    OldDeltaFakeTime = CurrentDeltaFakeTime;
    CurrentDeltaFakeTime+=dt;

    if(CurrentDeltaFakeTime < INTERP_TIME)
        DoMove(V);
    else // (We overshot)
    {
        DoMove((INTERP_TIME - OldDeltaFakeTime)/dt*V);
        bInterpFake=False;
        //Turn off checking for fakes
    }
}


defaultproperties
{
}
