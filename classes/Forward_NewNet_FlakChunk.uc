//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_FlakChunk extends NewNet_FlakChunk;
simulated function bool CheckForFakeProj()
{
     local Projectile FP;

     if(FPM == none)
        FindFPM();
     FP = FPM.GetFP(class'Forward_NewNet_Fake_FlakChunk', ChunkNum);
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
   speed=3500
   maxspeed=3500
   MomentumTransfer=20000
}
