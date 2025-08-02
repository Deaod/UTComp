//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_Flakshell extends NewNet_Flakshell;

simulated function bool CheckForFakeProj()
{
     local Projectile FP;

     if(FPM == none)
        FindFPM();
     FP = FPM.GetFP(class'ForwarD_NewNet_Fake_FlakShell');
     if(FP != none)
     {
      //  bInterpFake=true;
         DesiredDeltaFake = Location - FP.Location;
         doSetLoc(FP.Location);
         FPM.RemoveProjectile(FP);
         bOwned=False;
         return true;
     }
     return false;
}
DefaultProperties
{
   speed=1450.000000
   maxspeed=1450.000000
   MomentumTransfer=100000
}
