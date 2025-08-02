//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_RocketLauncher extends NewNet_RocketLauncher
HideDropDown
CacheExempt;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local RocketProj Rocket;
    local SeekingRocketProj SeekingRocket;
	local bot B;
	local actor Other;
	local float f,g;

	local vector HitNormal, End, HitLocation;

	if(!bUseEnhancedNetCode)
	{
	    return ForwardsuperSpawnProjectile(Start, Dir);
	}

    bBreakLock = true;

	// decide if bot should be locked on
	B = Bot(Instigator.Controller);
	if ( (B != None) && (B.Skill > 2 + 5 * FRand()) && (FRand() < 0.6) && (B.Target != None)
		&& (B.Target == B.Enemy) && (VSize(B.Enemy.Location - B.Pawn.Location) > 2000 + 2000 * FRand())
		&& (Level.TimeSeconds - B.LastSeenTime < 0.4) && (Level.TimeSeconds - B.AcquireTime > 1.5) )
	{
		bLockedOn = true;
		SeekTarget = B.Enemy;
	}

    if (bLockedOn && SeekTarget != None)
    {
        if(PingDT > 0.0 && Owner!=None)
        {
            Start-=1.0*vector(Dir);
            for(f=0.00; f<pingDT + PROJ_TIMESTEP; f+=PROJ_TIMESTEP)
            {
                //Make sure the last trace we do is right where we want
                //the proj to spawn if it makes it to the end
                g = Fmin(pingdt, f);
                //Where will it be after deltaF, Dir byRef for next tick
                if(f > pingDT)
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
               SeekingRocket = Spawn(class'Forward_NewNet_SeekingRocketProj',,, End, Dir);
           else
           {
               SeekingRocket = Spawn(class'Forward_NewNet_SeekingRocketProj',,, HitLocation - Vector(dir)*20.0, Dir);
           }
        }
        if(SeekingRocket==None)
            SeekingRocket = Spawn(class'Forward_NewNet_SeekingRocketProj',,, Start, Dir);

        SeekingRocket.Seeking = SeekTarget;
        if ( B != None )
        {
			//log("LOCKED");
			bLockedOn = false;
			SeekTarget = None;
		}
        return SeekingRocket;
    }
    else
    {
        if(PingDT > 0.0 && Owner!=None)
        {
            Start-=1.0*vector(Dir);
            for(f=0.00; f<pingDT + PROJ_TIMESTEP; f+=PROJ_TIMESTEP)
            {
                //Make sure the last trace we do is right where we want
                //the proj to spawn if it makes it to the end
                g = Fmin(pingdt, f);
                //Where will it be after deltaF, Dir byRef for next tick
                if(f > pingDT)
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
               Rocket = Spawn(class'Forward_NewNet_RocketProj',,, End, Dir);
           else
           {
               Rocket = Spawn(class'Forward_NewNet_RocketProj',,, HitLocation - Vector(dir)*20.0, Dir);
           }
        }
        else
            Rocket = Spawn(class'Forward_NewNet_RocketProj',,, Start, Dir);
        return Rocket;
    }
}

function  Projectile ForwardSuperSpawnProjectile(Vector Start, Rotator Dir)
{
    local RocketProj Rocket;
    local SeekingRocketProj SeekingRocket;
	local bot B;

    bBreakLock = true;

	// decide if bot should be locked on
	B = Bot(Instigator.Controller);
	if ( (B != None) && (B.Skill > 2 + 5 * FRand()) && (FRand() < 0.6) && (B.Target != None)
		&& (B.Target == B.Enemy) && (VSize(B.Enemy.Location - B.Pawn.Location) > 2000 + 2000 * FRand())
		&& (Level.TimeSeconds - B.LastSeenTime < 0.4) && (Level.TimeSeconds - B.AcquireTime > 1.5) )
	{
		bLockedOn = true;
		SeekTarget = B.Enemy;
	}

    if (bLockedOn && SeekTarget != None)
    {
        SeekingRocket = Spawn(class'Forward_SeekingRocketProj',,, Start, Dir);
        SeekingRocket.Seeking = SeekTarget;
        if ( B != None )
        {
			//log("LOCKED");
			bLockedOn = false;
			SeekTarget = None;
		}
        return SeekingRocket;
    }
    else
    {
        Rocket = Spawn(class'Forward_RocketProj',,, Start, Dir);
        return Rocket;
    }
}


DefaultProperties
{
    FireModeClass[0] = Class'Forward_newNet_RocketFire';
    FireModeClass[1] = Class'Forward_NewNet_RocketMultiFire';
}
