class FakeProjectileManager extends Actor;

struct FPindex
{
    var Projectile FP;
    var int index;
};

var array<FPIndex> FP;

simulated function RegisterFakeProjectile(Projectile P, optional int index)
{
    local int i;
    i= FP.Length+1;
    FP.Length =i;
    FP[i-1].FP=P;
    FP[i-1].index = index;
}

simulated function bool AllowFakeProjectile(class<projectile> pClass, optional int index)
{
   local int i;
   CleanUpProjectiles();
   for(i=0; i<FP.Length; i++)
      if(FP[i].FP!=None && FP[i].FP.class == pClass && FP[i].index == index)
          return false;
   return true;
}

simulated function CleanUpProjectiles()
{
   local int i;

   for(i=FP.Length-1; i>=0; i--)
      if(FP[i].FP==None)
          FP.Remove(i,1);
}

simulated function RemoveProjectile(Projectile P)
{
    local int i;
    for(i=FP.Length-1; i>=0; i--)
    {
        if(FP[i].FP==None || FP[i].FP==P)
            FP.Remove(i,1);
    }
    P.Destroy();
}

simulated function Projectile GetFP(class<Projectile> CP, optional int index)
{
   local int i;
   for(i=0; i<FP.Length; i++)
      if(FP[i].FP!=None && FP[i].FP.class == CP && FP[i].index == index)
         return FP[i].FP;
   return none;
}

defaultproperties
{
     bHidden=True
}
