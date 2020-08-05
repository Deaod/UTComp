
class UTComp_FlakAltFire extends FlakAltFire;

event ModeDoFire()
{
    local UTComp_PRI uPRI;
    if(weapon.owner.IsA('xPawn') && xPawn(Weapon.Owner).Controller!=None)
    {
        uPRI=class'UTComp_Util'.static.GetUTCompPRIFor(xPawn(Weapon.Owner).Controller);
        if(uPRI!=None)
            uPRI.NormalWepStatsAlt[7]+=1;
    }
    Super.ModeDoFire();
}

defaultproperties
{
    ProjectileClass=class'UTComp_FlakShell'
}
