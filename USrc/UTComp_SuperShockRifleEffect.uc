class UTComp_SuperShockRifleEffect extends UTComp_WeaponEffect abstract;

static function Play(
    PlayerController Context,
    UTComp_Settings Settings,
    Pawn Source,
    vector SourceLocation,
    vector Direction,
    vector HitLocation,
    vector HitNormal,
    int ReflectNum
) {
    local ShockBeamEffect Beam;

    if (Context.Level.NetMode == NM_DedicatedServer) return;

    if (Context.Pawn == Source)
        SourceLocation.Z -= 32;

    if ( (Source.PlayerReplicationInfo.Team != None) && (Source.PlayerReplicationInfo.Team.TeamIndex == 1) )
        Beam = Source.Spawn(class'BlueSuperShockBeam',Source,, SourceLocation, rotator(Direction));
    else
        Beam = Source.Spawn(Class'SuperShockBeamEffect',Source,, SourceLocation, rotator(Direction));
    Beam.RemoteRole = ROLE_None;
    Beam.Instigator = Source;
    if (ReflectNum != 0) Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}