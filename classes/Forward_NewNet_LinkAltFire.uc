//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_LinkAltFire extends NewNet_LinkAltFire;
function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local LinkProjectile Proj;
    local vector HitLocation, HitNormal, End;
    local actor Other;
    local UTComp_PRI uPRI;
    local float f,g;

    if(Level.NetMode == NM_Client && class'BS_xPlayer'.static.UseNewNet())
        return SpawnFakeProjectile(Start,Dir);
    if(!bUseEnhancedNetCode)
    {
       return ForwardsuperSpawnProjectile(Start,Dir);
    }

    if(weapon.owner.IsA('xPawn') && xPawn(Weapon.Owner).Controller!=None)
    {
        uPRI=class'UTComp_Util'.static.GetUTCompPRIFor(xPawn(Weapon.Owner).Controller);
        if(uPRI!=None)
            uPRI.NormalWepStatsPrim[9]+=2;
    }

    Start += Vector(Dir) * 10.0 * LinkGun(Weapon).Links;
    if(PingDT > 0.0 && Weapon.Owner!=None)
    {
        Start-=1.0*vector(Dir);
        for(f=0.00; f<pingDT + PROJ_TIMESTEP; f+=PROJ_TIMESTEP)
        {
            //Make sure the last trace we do is right where we want
            //the proj to spawn if it makes it to the end
            g = Fmin(pingdt, f);
            //Where will it be after deltaF, Dir byRef for next tick
            if(f >= pingDT)
               End = Start + Extrapolate(Dir, (pingDT-f+PROJ_TIMESTEP));
            else
               End = Start + Extrapolate(Dir, PROJ_TIMESTEP);
            //Put pawns there
            TimeTravel(pingdt - g);
            //Trace between the start and extrapolated end
            Other = DoTimeTravelTrace(HitLocation, HitNormal, End, Start);
            if(Other!=None)
            {
                break;
            }
            //repeat
            Start=End;
       }
       UnTimeTravel();

       if(Other!=None && Other.IsA('PawnCollisionCopy'))
       {
             HitLocation = HitLocation + PawnCollisionCopy(Other).CopiedPawn.Location - Other.Location;
             Other=PawnCollisionCopy(Other).CopiedPawn;
       }

       if(Other == none)
           Proj = Weapon.Spawn(class'Forward_NewNet_LinkProjectile',,, End, Dir);
       else
       {
           Proj = Weapon.Spawn(class'Forward_NewNet_LinkProjectile',,, HitLocation - Vector(dir)*20.0, Dir);
           NewNet_LinkGun(Weapon).DispatchClientEffect(HitLocation - Vector(dir)*20.0, Dir);
       }
    }
    else
        Proj = Weapon.Spawn(class'Forward_NewNet_LinkProjectile',,, Start, Dir);
    if ( Proj != None )
    {
		Proj.Links = LinkGun(Weapon).Links;
		Proj.LinkAdjust();
	}
	if(NewNet_LinkProjectile(proj)!=None)
    {
        NewNet_LinkProjectile(proj).Index=NewNet_LinkGun(Weapon).CurIndex;
        NewNet_LinkGun(Weapon).CurIndex++;
    }

    return Proj;
}

function Projectile ForwardSuperSpawnProjectile(Vector Start, Rotator Dir)
{
    local LinkProjectile Proj;
    local UTComp_PRI uPRI;

    if(weapon.owner.IsA('xPawn') && xPawn(Weapon.Owner).Controller!=None)
    {
        uPRI=class'UTComp_Util'.static.GetUTCompPRIFor(xPawn(Weapon.Owner).Controller);
        if(uPRI!=None)
            uPRI.NormalWepStatsPrim[9]+=2;
    }

    // super function
    Start += Vector(Dir) * 10.0 * LinkGun(Weapon).Links;
    Proj = Weapon.Spawn(class'Forward_LinkProjectile',,, Start, Dir);
    if ( Proj != None )
    {
		Proj.Links = LinkGun(Weapon).Links;
		Proj.LinkAdjust();
	}
    return Proj;
}

DefaultProperties
{
    ProjectileClass=class'Forward_NewNet_LinkProjectile'
    FakeProjectileClass=class'Forward_NewNet_FAke_LinkProjectile'
}
