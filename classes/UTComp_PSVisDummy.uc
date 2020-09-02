class UTComp_PSVisDummy extends Actor;

function InitDummy(PlayerStart PS) {
    LoopAnim('Idle_Rest', 1.0);
}

defaultproperties
{
    // Player=(
    //     DefaultName="Gorge",
    //     Race="Juggernaut",
    //     Mesh=Jugg.JuggMaleA,
    //     species=xGame.SPECIES_Jugg,
    //     BodySkin=PlayerSkins.JuggMaleABodyA,
    //     FaceSkin=PlayerSkins.JuggMaleAHeadA,
    //     Portrait=PlayerPictures.cJuggMaleAA,
    //     Text=XPlayers.JuggMaleAA,
    //     Sex=Male,
    //     Menu="",
    //     Aggressiveness=+0.1,
    //     CombatStyle=+0.1,
    //     Tactics=+0.5,
    //     BotUse=1)

    Physics=PHYS_None
    CollisionHeight=0
    CollisionRadius=0
    bCollideActors=False
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False
    bBlockProjectiles=False
    bProjTarget=False
    bBlockZeroExtentTraces=False
    bBlockNonZeroExtentTraces=False
    bBlockKarma=False

    DrawType=DT_Mesh
    Mesh=mesh'Jugg.JuggMaleA'
    Skins(0)=material'PlayerSkins.JuggMaleABodyA'
    Skins(1)=material'PlayerSkins.JuggMaleAHeadA'
    bReplicateAnimations=True
}
