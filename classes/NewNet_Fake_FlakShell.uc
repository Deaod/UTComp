
class NewNet_Fake_FlakShell extends FlakShell;

simulated function Explode(vector HitLocation, vector HitNormal)
{
    Destroy();
}

defaultproperties
{
     bNetTemporary=False
}
