
class NewNet_NewLightningBolt extends NewLightningBolt;

simulated function PostNetBeginPlay()
{
    local playercontroller pc;
    super.PostNetBeginPlay();
    if(Role==Role_Authority)
        return;
    PC = Level.GetLocalPlayerController();

    if(PC!=None && PC.Pawn!=None && PC.Pawn == Instigator)
    {
        Destroy();
    }
}

defaultproperties
{
     bSkipActorPropertyReplication=False
}
