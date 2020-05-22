//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_FlakCannon extends NewNet_FlakCannon
HideDropDown
CacheExempt;

defaultproperties
{
    FireModeClass[0] = Class'UTCompv18.Forward_NewNet_FlakFire'
    FireModeClass[1] = Class'UTCompv18.Forward_newNet_FlakAltFire'
}
