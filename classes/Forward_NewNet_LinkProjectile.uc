//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_LinkProjectile extends NewNet_LinkProjectile;
simulated function bool CheckForFakeProj()
{
     local float ping;
     local Projectile FP;

     ping = FMax(0.0, class'NewNet_PRI'.default.PredictedPing - 0.5*class'TimeStamp'.default.AverDT);

     if(FPM == none)
        FindFPM();
     FP = FPM.GetFP(class'Forward_NewNet_Fake_LinkProjectile', index);
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
    Damage=40
    Speed = 1300
}
