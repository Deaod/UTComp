class UTComp_xBlueFlag extends UTComp_CTFFlag;

#exec OBJ LOAD FILE=XGameShaders.utx
#exec OBJ LOAD FILE=TeamSymbols_UT2003.utx

simulated function PostBeginPlay()
{    
    Super.PostBeginPlay();  
      
    LoopAnim('flag',0.8);
    SimAnim.bAnimLoop = true;  
}

defaultproperties
{
     TeamNum=1
     LightHue=130
     Mesh=VertMesh'XGame_rc.FlagMesh'
     DrawScale=0.900000
     Skins(0)=FinalBlend'XGameShaders2004.CTFShaders.BlueFlagShader_F'
}
