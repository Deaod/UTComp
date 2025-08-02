//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_RocketProj extends NewNet_RocketProj;

simulated function bool CheckForFakeProj()
{
     local float ping;
     local Projectile FP;

     ping = FMax(0.0, class'NewNet_PRI'.default.PredictedPing - 0.5*class'TimeStamp'.default.AverDT);

     if(FPM == none)
        FindFPM();
     FP = FPM.GetFP(class'Forward_NewNet_Fake_RocketProj', index);
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

DefaultProperties
{
   DamageRadius=265.0
   speed=2000
   maxspeed=2000
   MomentumTransfer=100000
   Damage=65
}
