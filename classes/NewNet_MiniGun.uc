class NewNet_MiniGun extends UTComp_MiniGun
	HideDropDown
	CacheExempt;

var TimeStamp T;
var MutUTComp M;

replication
{
    reliable if( Role<ROLE_Authority )
        NewNet_ServerStartFire;
}

function DisableNet()
{
    NewNet_MiniGunFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_MiniGunFire(FireMode[0]).PingDT = 0.00;
    NewNet_MiniGunAltFire(FireMode[1]).bUseEnhancedNetCode = false;
    NewNet_MiniGunAltFire(FireMode[1]).PingDT = 0.00;
}

//// client only ////
simulated event ClientStartFire(int Mode)
{
    if(Level.NetMode!=NM_Client || !class'BS_xPlayer'.static.UseNewNet())
        super.ClientStartFire(mode);
    else
        NewNet_ClientStartFire(mode);
}

simulated event NewNet_ClientStartFire(int Mode)
{
    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (StartFire(Mode))
        {
            if(T==None)
                foreach DynamicActors(class'TimeStamp', T)
                     break;

            NewNet_ServerStartFire(mode, T.ClientTimeStamp);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

function NewNet_ServerStartFire(byte Mode, float ClientTimeStamp)
{
    if(M==None)
        foreach DynamicActors(class'MutUTComp', M)
	        break;

    if(NewNet_MiniGunFire(FireMode[Mode])!=None)
    {
        NewNet_MiniGunFire(FireMode[Mode]).PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
        NewNet_MiniGunFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }
    else if(NewNet_MiniGunAltFire(FireMode[Mode])!=None)
    {
        NewNet_MiniGunAltFire(FireMode[Mode]).PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
        NewNet_MiniGunAltFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }

    ServerStartFire(Mode);
}


DefaultProperties
{
    FireModeClass(0)=class'UTCompv18a.NewNet_MiniGunFire'
    FireModeClass(1)=class'UTCompv18a.NewNet_MiniGunAltFire'
    PickupClass=Class'UTCompv18a.NewNet_MiniGunPickup'
}
