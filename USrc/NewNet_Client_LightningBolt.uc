
class NewNet_Client_LightningBolt extends NewLightningBolt;

function PostBeginPlay()
{
   super.PostBeginPlay();
   if(Level.NetMode!=NM_Client)
       Warn("Server should never spawn the client lightningbolt");
}

DefaultProperties
{

}
