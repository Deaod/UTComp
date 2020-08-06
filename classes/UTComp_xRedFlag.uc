class UTComp_xRedFlag extends UTComp_CTFFlag;

#exec OBJ LOAD FILE=XGameShaders.utx
#exec OBJ LOAD FILE=XGameShaders2004.utx
#exec OBJ LOAD FILE=TeamSymbols_UT2003.utx

simulated function PostBeginPlay()
{    
    Super.PostBeginPlay();    

    LoopAnim('flag',0.8);
    SimAnim.bAnimLoop = true;  
}

defaultproperties
{
     Mesh=VertMesh'XGame_rc.FlagMesh'
     DrawScale=0.900000
     Skins(0)=FinalBlend'XGameShaders2004.CTFShaders.RedFlagShader_F'
}
