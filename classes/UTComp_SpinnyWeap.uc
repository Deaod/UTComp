

//-----------------------------------------------------------
//      edited spinnywep so it looks right even if the
//      player is not facing at pitch/roll=0 for BSkins
//      Menu in utcomp vSrc
//-----------------------------------------------------------
class UTComp_SpinnyWeap extends SpinnyWeap;

function Tick(float Delta)
{
	local vector X,Y,Z;
    local vector X2,Y2;
    local rotator R2;
    local vector  V;
    local rotator R;

	R = Rotation;

    //changed from SpinnyWeap so that it rotates around
    //the players viewing direction, not just absolute
    R2.Yaw = Delta * SpinRate/Level.TimeDilation;
    GetAxes(R,X,Y,Z);
    V=vector(R2);
    X2=V.X*X + V.Y*Y;
    Y2=V.X*Y - V.Y*X;
    R2=OrthoRotation(X2,Y2,Z);

    SetRotation(R2);

	CurrentTime += Delta/Level.TimeDilation;

	// If desired, play some random animations
	if(bPlayRandomAnims && CurrentTime >= NextAnimTime)
	{
		PlayNextAnim();
	}
}

DefaultProperties
{

}
