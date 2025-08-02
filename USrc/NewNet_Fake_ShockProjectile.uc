
class NewNet_Fake_ShockProjectile extends ShockProjectile;

simulated function Destroyed()
{
    if (ShockBallEffect != None)
    {
     	ShockBallEffect.Destroy();
	}
	super(Projectile).Destroyed();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if(Other.IsA('NewNet_ShockProjectile'))
        return;
    super.ProcessTouch(Other, Hitlocation);
}

defaultproperties
{
     bCollideActors=False
}
