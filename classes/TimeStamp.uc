
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TimeStamp extends ReplicationInfo;

//var float ClientTimeStamp;
var float AverDT;

replication
{
   unreliable if(Role == Role_Authority)
       /*ClientTimeStamp,*/ averDT;
}

simulated function PostBeginPlay()
{
    class'ShieldFire'.default.AutoFireTestFreq=0.05;
    Super.PostBeginPlay();
}

simulated function tick(float DeltaTime)
{
   // ClientTimeStamp+=deltatime;
    //Log(ClientTimeStamp);
    default.AverDT = Averdt;
}

function ReplicatetimeStamp(float f)
{
 //   ClientTimeStamp=f;
}

function REplicatedAverDT(float f)
{
    AverDT = f;
}

defaultproperties
{
    NetUpdateFrequency=100.0
    NetPriority=5.0
}
