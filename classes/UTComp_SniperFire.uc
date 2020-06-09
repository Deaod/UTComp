

class UTComp_SniperFire extends SniperFire;

event ModeDoFire()
{
    local UTComp_PRI uPRI;
    if(weapon.owner.IsA('xPawn') && xPawn(Weapon.Owner).Controller!=None)
    {
        uPRI=class'UTComp_Util'.static.GetUTCompPRIFor(xPawn(Weapon.Owner).Controller);
        if(uPRI!=None)
            uPRI.NormalWepStatsPrim[5]+=1;
    }
    Super.ModeDoFire();
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, RefNormal;
    local Actor Other, mainArcHitTarget;
    local int Damage, ReflectNum, arcsRemaining;
    local bool bDoReflect;
    local xEmitter hitEmitter;
    local class<Actor> tmpHitEmitClass;
    local float tmpTraceRange;
    local vector arcEnd, mainArcHit;
    local Pawn HeadShotPawn;
    local vector EffectOffset;

    if ( class'PlayerController'.Default.bSmallWeapons )
        EffectOffset = Weapon.SmallEffectOffset;
    else
        EffectOffset = Weapon.EffectOffset;

    Weapon.GetViewAxes(X, Y, Z);
    if (Level.NetMode == NM_DedicatedServer) {
        arcEnd = (
            Instigator.Location +
            Instigator.BaseEyeHeight * vect(0,0,1) +
            EffectOffset.Z * Z +
            EffectOffset.Y * Y +
            EffectOffset.X * X
        );
    } else {
        if ( Weapon.WeaponCentered() || SniperRifle(Weapon).zoomed )
            arcEnd = (Instigator.Location +
                EffectOffset.Z * Z);
        else if ( Weapon.Hand == 0 )
        {
            if ( class'PlayerController'.Default.bSmallWeapons )
                arcEnd = (Instigator.Location +
                    EffectOffset.X * X);
            else
                arcEnd = (Instigator.Location +
                    EffectOffset.X * X
                    - 0.5 * EffectOffset.Z * Z);
        }
        else
            arcEnd = (Instigator.Location +
                Instigator.CalcDrawOffset(Weapon) +
                EffectOffset.X * X +
                Weapon.Hand * EffectOffset.Y * Y +
                EffectOffset.Z * Z);
    }

    arcsRemaining = NumArcs;

    tmpHitEmitClass = HitEmitterClass;
    tmpTraceRange = TraceRange;

    ReflectNum = 0;
    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + tmpTraceRange * X;
        Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = true;
            }
            else if ( Other != mainArcHitTarget )
            {
                if ( !Other.bWorldGeometry )
                {
                    Damage = (DamageMin + Rand(DamageMax - DamageMin)) * DamageAtten;

                    if (Vehicle(Other) != None)
                        HeadShotPawn = Vehicle(Other).CheckForHeadShot(HitLocation, X, 1.0);

                    if (HeadShotPawn != None)
                        HeadShotPawn.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
                    else if ( (Pawn(Other) != None) && (arcsRemaining == NumArcs)
                        && Pawn(Other).IsHeadShot(HitLocation, X, 1.0) )
                        Other.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
                    else
                    {
                        if ( arcsRemaining < NumArcs )
                            Damage *= SecDamageMult;
                        Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
                    }
                }
                else
                    HitLocation = HitLocation + 2.0 * HitNormal;
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Normal(Start - End);
        }
        if ( Weapon == None )
            return;
        hitEmitter = xEmitter(Weapon.Spawn(tmpHitEmitClass,,, arcEnd, Rotator(HitNormal)));
        if ( hitEmitter != None )
            hitEmitter.mSpawnVecA = HitLocation;
        if ( HitScanBlockingVolume(Other) != None )
            return;

        if( arcsRemaining == NumArcs )
        {
            mainArcHit = HitLocation + (HitNormal * 2.0);
            if ( Other != None && !Other.bWorldGeometry )
                mainArcHitTarget = Other;
        }

        if (bDoReflect && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else if ( arcsRemaining > 0 )
        {
            arcsRemaining--;

            // done parent arc, now move trace point to arc trace hit location and try child arcs from there
            Start = mainArcHit;
            Dir = Rotator(VRand());
            tmpHitEmitClass = SecHitEmitterClass;
            tmpTraceRange = SecTraceDist;
            arcEnd = mainArcHit;
        }
        else
        {
            break;
        }
    }
}


defaultproperties
{
}
