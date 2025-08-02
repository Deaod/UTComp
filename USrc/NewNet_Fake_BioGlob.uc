
class NewNet_Fake_BioGlob extends BioGlob;

simulated function Destroyed()
{
	if ( Fear != None )
		Fear.Destroy();
    if (Trail != None)
        Trail.Destroy();
    super(Projectile).Destroyed();
}

defaultproperties
{
    bNetTemporary=false
}
