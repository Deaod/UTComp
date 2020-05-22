//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_ShockProjectile extends NewNet_ShockProjectile;
simulated function bool CheckForFakeProj()
{
     local Projectile FP;

     ping = FMax(0.0, class'NewNet_PRI'.default.PredictedPing - 1.50*class'TimeStamp'.default.AverDT);
     if(FPM == none)
        FindFPM();
     FP = FPM.GetFP(class'Forward_NewNet_Fake_ShockProjectile');
     if(FP != none)
     {
         bInterpFake=true;
         if(bMoved)
             DesiredDeltaFake = Location - FP.Location;
         else
             DesiredDeltaFake = (Location+Velocity*ping) - FP.Location;
         DoSetLoc(FP.Location);
         FPM.RemoveProjectile(FP);
         bOwned=False;
         return true;
     }
     return false;
}
DefaultProperties
{
   speed=1500
   maxspeed=1500
   Damage=30
}
