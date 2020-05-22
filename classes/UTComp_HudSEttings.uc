

class UTComp_HudSettings extends Object;

struct SpecialCrosshair
{
    var texture CrossTex;
    var float CrossScale;
    var color CrossColor;
    var float OffsetX;
    var float OffsetY;
};

var config array<SpecialCrosshair> UTCompCrosshairs;
var config bool bEnableUTCompCrosshairs;
var config bool bEnableCrosshairSizing;

var config bool bMatchHudColor;

var SpecialCrosshair TempxHair;

defaultproperties
{
    bEnableCrosshairSizing=True
}
