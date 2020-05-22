

class UTComp_OverlayUpdate extends Info;

var MutUTComp UTCompMutator;
var bool bVariablesCleared;

CONST fUPDATETIME = 1.0;
CONST iMAXPLAYERS = 8;

function InitializeOverlay()
{
    if(Level.Game.bTeamGame)
        SetTimer(fUPDATETIME, true);
}

function Timer()
{
    if(UTCompMutator.bEnableTeamOverlay)
        UpdateVariables();
    else if(!bVariablesCleared)
        ClearVariables();
}

function ClearVariables()
{
    local UTComp_PRI uPRI;
    local int i;
    foreach DynamicActors(class'UTComp_PRI', uPRI)
    {
        for(i=0; i<iMAXPLAYERS; i++)
        {
            uPRI.OverlayInfo[i].PRI=None;
            uPRI.OverlayInfo[i].Weapon=0;
            uPRI.OverlayInfo[i].Health=0;
            uPRI.OverlayInfo[i].Armor=0;
            uPRI.bHasDD[i]=0;
       }
    }
    bVariablesCleared=True;
}

function UpdateVariables()
{
    FindInfoForTeam(0);
    FindInfoForTeam(1);
    bVariablesCleared=False;
}

function FindInfoForTeam(byte iTeam)
{
    local int i, j, k;
    local Controller C;
    local UTComp_PRI uPRI;

    local PlayerReplicationInfo PRI[iMAXPLAYERS];
    local byte Weapon[iMAXPLAYERS];
    local int Health[iMAXPLAYERS];
    local byte Armor[iMAXPLAYERS];
    local byte bHasDD[8];

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(j>= iMAXPLAYERS)
            j--;
        if(C.GetTeamNum()==iTeam)
        {
            if(UpdateVariablesFor(C, Weapon[j], Health[j], Armor[j], PRI[j], bHasDD[j]))
               j++;
        }
    }
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
       if(iTeam!=255 && C.PlayerReplicationInfo!=None && PlayerController(C)!=None)
           uPRI=Class'UTComp_Util'.Static.GetUTCompPRI(C.PlayerReplicationInfo);
       if(uPRI!=None && (C.GetTeamNum() == iTeam || iTeam==uPRI.CoachTeam))
       {
           k=0;
           for(i=0; i<iMAXPLAYERS; i++)
           {
               if(uPRI.bShowSelf || C.PlayerReplicationInfo!=PRI[i])
               {
                   uPRI.OverlayInfo[k].Weapon=Weapon[i];
                   uPRI.OverlayInfo[k].Health=Health[i];
                   uPRI.OverlayInfo[k].Armor=Armor[i];
                   uPRI.OverlayInfo[k].PRI=PRI[i];
                   uPRI.bHasDD[k]=bHasDD[i];
                   k++;
               }
           }
       }
       else if(uPRI!=None && uPRI.CoachTeam==255 && C.PlayerReplicationInfo!=None && C.PlayerReplicationInfo.bOnlySpectator)
       {
           for(i=0; i<iMAXPLAYERS; i++)
           {
               uPRI.OverlayInfo[i].PRI=none;
           }
       }
       uPRI=None;
    }
}

function bool UpdateVariablesFor(Controller C, out byte Weapon, out int Health, out byte Armor, out PlayerReplicationInfo PRI, out byte IsDD)
{
 //  if(C.Pawn==None || C.PlayerReplicationInfo==None)
   if(C.PlayerReplicationInfo==None)
   {
        return false;
   }
   PRI=C.PlayerReplicationInfo;
   if(C.Pawn==None)
       return true;
   else if(xPawn(C.Pawn)!=None)
   {
       Health=C.Pawn.Health;
       Armor=C.Pawn.ShieldStrength;
       if(C.Pawn.Weapon!=None)
           Weapon=FindWeaponID(C.Pawn.Weapon);
       if(xPawn(C.Pawn).UDamageTime - Level.TimeSeconds >0)
           IsDD=1;
   }
   else if(ONSWeaponPawn(C.Pawn)!=None)
   {
       Health=C.Pawn.Health;
       Armor=0;
       if(ONSWeaponPawn(C.Pawn).VehicleBase !=None)
           Weapon=FindVehicleID(ONSWeaponPawn(C.Pawn).VehicleBase);
   }
   else if(Vehicle(C.Pawn)!=None)
   {
       Health=C.Pawn.Health;
       Armor=0;
       Weapon=FindVehicleID(Vehicle(C.Pawn));
   }
   else if(RedeemerWarHead(C.Pawn)!=None)
   {
       if(RedeemerWarhead(C.Pawn).oldpawn!=None)
       {
           Health=RedeemerWarhead(C.Pawn).oldpawn.Health;
           Armor=RedeemerWarhead(C.Pawn).oldpawn.ShieldStrength;
       }
       Weapon=15;
   }
   else
   {
       Health=C.Pawn.Health;
       Armor=C.Pawn.ShieldStrength;
   }
   return true;
}

function byte FindWeaponID(Weapon aWeapon)
{
    if(ShieldGun(aWeapon) !=None)
        return 1;
    else if(AssaultRifle(aWeapon)!=None)
    {
        if(AssaultRifle(aWeapon).bDualMode)
            return 11;
        else
            return 2;
    }
    else if(BioRifle(aWeapon)!=None)
        return 3;
    else if(ShockRifle(aWeapon)!=None)
        return 4;
    else if(LinkGun(aWeapon)!=None)
        return 5;
    else if(MiniGun(aWeapon)!=None)
        return 6;
    else if(FlakCannon(aWeapon)!=None)
        return 7;
    else if(RocketLauncher(aWeapon)!=None)
        return 8;
    else if(SniperRifle(aWeapon)!=None)
        return 9;
    else if(ClassicSniperRifle(aWeapon)!=None)
        return 10;
    else if(ONSMineLayer(aWeapon)!=None)
        return 12;
    else if(ONSGrenadeLauncher(aWeapon)!=None)
        return 13;
    else if(ONSAVRiL(aWeapon)!=None)
        return 14;
    else if(Redeemer(aWeapon)!=None)
        return 15;
    else if(Painter(aWeapon)!=None)
        return 16;
    else if(TransLauncher(aWeapon)!=None)
        return 17;
}

function byte FindVehicleID(Vehicle aVehicle)
{
    if(aVehicle.VehicleNameString ~="Manta")
        return 21;
    else if(aVehicle.VehicleNameString ~="Goliath")
        return 22;
    else if(aVehicle.VehicleNameString ~="Scorpion")
        return 23;
    else if(aVehicle.VehicleNameString ~="Hellbender" )
        return 24;
    else if(aVehicle.VehicleNameString ~="Leviathan")
        return 25;
    else if(aVehicle.VehicleNameString ~="Raptor")
        return 26;
    else if(aVehicle.VehicleNameString ~="Cicada")
        return 27;
    else if(aVehicle.VehicleNameString ~="Paladin")
        return 28;
    else if(aVehicle.VehicleNameString ~="SPMA")
        return 29;
}

defaultproperties
{
     bHidden=True
}
