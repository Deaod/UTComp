

class UTComp_InWarmupMessage extends LocalMessage;
static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
      if(OptionalObject!=None && PlayerController(OptionalObject)!=None && class'GameInfo'.Static.GetKeyBindName("mymenu", PlayerController(OptionalObject))!= "mymenu")
          return class'GameInfo'.static.MakeColorCode(class'Hud'.default.WhiteColor)$"You are in warmup, press '"$class'GameInfo'.static.MakeColorCode(class'Hud'.default.GoldColor)$class'GameInfo'.Static.GetKeyBindName("mymenu", PlayerController(OptionalObject))$class'GameInfo'.static.MakeColorCode(class'Hud'.default.WhiteColor)$"' to ready up.";
      else
          return class'GameInfo'.static.MakeColorCode(class'Hud'.default.WhiteColor)$"You are in warmup, type "$class'GameInfo'.static.MakeColorCode(class'Hud'.default.GoldColor)$"'ready'"$class'GameInfo'.static.MakeColorCode(class'Hud'.default.WhiteColor)$" in the console to ready up";
}

DefaultProperties
{
      bIsConsoleMessage=False
      bFadeMessage=True
      LifeTime=4
      StackMode=2
      PosY=0.93
      FontSize=-2
}
