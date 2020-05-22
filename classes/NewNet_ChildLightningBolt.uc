
class NewNet_ChildLightningBolt extends ChildLightningBolt;

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
     bReplicateInstigator=True
     bSkipActorPropertyReplication=False
}
