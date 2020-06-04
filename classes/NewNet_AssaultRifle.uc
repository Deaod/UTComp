
class NewNet_AssaultRifle extends UTComp_AssaultRifle
	HideDropDown
	CacheExempt;

var TimeStamp T;
var MutUTComp M;

const MAX_PROJECTILE_FUDGE = 0.075;

replication
{
    reliable if( Role<ROLE_Authority )
        NewNet_ServerStartFire;
    unreliable if(Role == Role_Authority)
        DispatchClientEffect;
}

function DisableNet()
{
    NewNet_AssaultFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_AssaultFire(FireMode[0]).PingDT = 0.00;
    NewNet_AssaultGrenade(FireMode[1]).bUseEnhancedNetCode = false;
    NewNet_AssaultGrenade(FireMode[1]).PingDT = 0.00;
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

    if(NewNet_AssaultFire(FireMode[Mode])!=None)
    {
        NewNet_AssaultFire(FireMode[Mode]).PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
        NewNet_AssaultFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }
    else if(NewNet_AssaultGrenade(FireMode[Mode])!=None)
    {
        NewNet_AssaultGrenade(FireMode[Mode]).PingDT = FMin(M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT, MAX_PROJECTILE_FUDGE);
        NewNet_AssaultGrenade(FireMode[Mode]).bUseEnhancedNetCode = true;
    }

    ServerStartFire(Mode);
}


simulated function DispatchClientEffect(Vector V, rotator R)
{
    if(Level.NetMode != NM_Client)
        return;
    Spawn(class'LinkProjectile',,,V,R);
}

DefaultProperties
{
    FireModeClass(0)=class'UTCompv18a.NewNet_AssaultFire'
    FireModeClass(1)=class'UTCompv18a.NewNet_AssaultGrenade'
    PickupClass=Class'UTCompv18a.NewNet_AssaultRiflePickup'
}
