

class UTComp_Menu_Voting_GameType extends UTComp_Menu_MainMenu;

var automated GUIListBox lb_MapList;

var automated GUIEditBox eb_MapInput;
var automated GUINumericEdit ne_NumPlayers;
var automated GUIComboBox co_GameTypeList;

var automated GUIButton bu_QuickRestart, bu_ChangeMap;

var automated GUILabel l_MapName, l_GameType, l_MaxPlayers;

var automated moCheckBox cb_UseAdvancedOptions;
var automated moCheckBox cb_Adren, cb_DD, cb_SuperWeapons, cb_WeaponStay;

var automated GUINumericEdit ne_GoalScore, ne_TimeLimit, ne_Grenades, ne_OverTime;
var automated GUILabel l_GoalScore, l_TimeLimit, l_grenades, l_OverTime;

var automated GUIButton bu_Refresh;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

    Super.Initcomponent(MyController, MyOwner);
    ne_Grenades.SetValue(4);
    Blehz();
}

function InternalOnChange( GUIComponent C )
{
    Switch(C)
    {
       case lb_MapList:  eb_MapInput.SetText(lb_MapList.List.SelectedText()); break;
       case cb_UseAdvancedOptions: NewFunc(); break;
       case co_GameTypeList:  NewFunc(); RefreshMapList(); NE_numPlayersSetValue(); break;

    }
}

function Blehz()
{
    local UTComp_ServerReplicationInfo RepInfo;
    local int i;


    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;
    co_GameTypeList.ReadOnly(False);
    co_GameTypeList.Clear();
    for(i=0; RepInfo!=None && i<ArrayCount(RepInfo.VotingNames); i++)
    {
        if(RepInfo.VotingNames[i]!="")
            co_GameTypeList.AddItem(RepInfo.VotingNames[i]);
    }
    co_GameTypeList.ReadOnly(True);

 /*   if(RepInfo!=None && !RepInfo.bEnableWarmup)
        bu_QuickRestart.DisableMe();
    else
       bu_QuickRestart.EnableMe();  */
    ne_NumPlayers.SetValue(RepInfo.MaxPlayersClone);
    NE_NumPlayersSetValue();
    ne_NumPlayers.MaxValue=RepInfo.ServerMaxPlayers;

    l_MaxPlayers.Caption="Max Players(Max "$RepInfo.ServerMaxPlayers$")";

    bu_QuickRestart.DisableMe();
    Newfunc();
}

function NE_NumPlayersSetValue()
{
    local int i;
    local string S;
    S = co_gameTypeList.GetText();
    if(S == "1v1")
        i = 2;
    else if(S == "FFA")
        i = 8;
    else if(S == "Team Deathmatch")
        i = 8;
    else if(S == "Capture the Flag")
        i = 10;
    else if(S == "Onslaught")
        i = 12;
    else if(S == "Assault")
        i = 12;
    else if(S == "Double Domination")
        i = 8;
    else if(S == "Bombing Run")
        i =10;
    else if(S == "Clan Arena")
        i =8;
    else
        return;
    ne_numPlayers.SetValue(i);
}

function NewFunc()
{
    local UTComp_ServerReplicationInfo RepInfo;
    local array<string> Parts;
    local int i;
    local bool MutsFound, ddFound;

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    if(RepInfo==None || RepInfo.bEnableAdvancedVotingOptions)
        cb_UseAdvancedOptions.EnableMe();
    else
        cb_UseAdvancedOptions.DisableMe();

    if(cb_UseAdvancedOptions.IsChecked() && (RepInfo==None || RepInfo.bEnableAdvancedVotingOptions))
    {
         ne_GoalScore.EnableMe();
         ne_TimeLimit.EnableMe();
         ne_Grenades.EnableMe();
         ne_OverTime.EnableMe();
         cb_Adren.EnableMe();
         cb_DD.EnableMe();
         cb_SuperWeapons.EnableMe();
         cb_WeaponStay.EnableMe();
         l_GoalScore.EnableMe();
         l_TimeLimit.EnableMe();
         l_Grenades.EnableMe();
         l_OverTime.EnableMe();
    }
    else
    {
         ne_GoalScore.disableme();
         ne_TimeLimit.disableme();
         ne_Grenades.DisableMe();
         ne_OverTime.DisableMe();
         cb_Adren.disableme();
         cb_DD.disableme();
         cb_SuperWeapons.disableme();
         cb_WeaponStay.disableme();
         l_GoalScore.disableme();
         l_TimeLimit.disableme();
         l_Grenades.disableme();
         l_OverTime.disableme();
    }

    if(RepInfo==None)
        return;

    if(co_GameTypeList.GetIndex()>=0 &&  co_GameTypeList.GetIndex()<ArrayCount(RepInfo.VotingOptions))
        Split(RepInfo.VotingOptions[co_GameTypeList.GetIndex()], "?", Parts);
    for(i=0; i<Parts.Length; i++)
    {
        if(Left(Parts[i],10)~="GoalScore=")
        {
            ne_GoalScore.SetValue(int(Right(Parts[i], Len(Parts[i])-10)));
        }
        else if(Left(Parts[i],10)~="TimeLimit=")
        {
            ne_TimeLimit.SetValue(int(Right(Parts[i], Len(Parts[i])-10)));
        }
        else if(Left(Parts[i],16)~="GrenadesOnSpawn=")
        {
            ne_Grenades.SetValue(int(Right(Parts[i], Len(Parts[i])-16)));
        }
        else if(Left(Parts[i],20)~="TimedOverTimeLength=")
        {
            ne_OverTime.SetValue(int(Right(Parts[i], Len(Parts[i])-20)));
        }
        else if(Left(Parts[i],8)~="Mutator=")
        {
            cb_Adren.Checked(!InStrNonCaseSensitive(Parts[i], "xGame.MutNoAdrenaline"));
            cb_SuperWeapons.Checked(!InStrNonCaseSensitive(Parts[i], "xWeapons.MutNoSuperWeapon"));
            MutsFound=True;
        }
        else if(Left(Parts[i],13)~="DoubleDamage=")
        {
             cb_DD.Checked(Right(Parts[i], Len(Parts[i])-13)~="True");
             ddFound=True;
        }
        else if(Left(Parts[i],11)~="WeaponStay=")
        {
             cb_WeaponStay.Checked(Right(Parts[i], Len(Parts[i])-11)~="True");
        }
    }
    if(!MutsFound)
    {
       cb_Adren.Checked(True);
       cb_SuperWeapons.Checked(True);
    }
    if(!ddFound)
    {
        cb_DD.Checked(RepInfo==None || RepInfo.bEnableDoubleDamage);
    }
}

simulated function bool InStrNonCaseSensitive(String S, string S2)
{                                //S2 in S
    local int i;
    for(i=0; i<=(Len(S)-Len(S2)); i++)
    {
        if(Mid(S, i, Len(s2))~=S2)
            return true;
    }
    return false;
}


function bool InternalOnClick( GUIComponent Sender )
{

    local UTComp_ServerReplicationInfo RepInfo;
    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    switch (Sender)
    {
        case bu_ChangeMap:    ne_NumPlayers.SetValue(Min(int(ne_NumPlayers.Value), RepInfo.ServerMaxPlayers));
                              if(eb_MapInput.GetText()!="")
                                  BS_xPlayer(PlayerOwner()).CallVote(6, co_GameTypeList.GetIndex(), eb_MapInput.GetText(), int(ne_NumPlayers.Value), ConstructMapTravelText());
                              else
                                  BS_xPlayer(PlayerOwner()).CallVote(6, co_GameTypeList.GetIndex(), lb_MapList.List.SelectedText(), int(ne_NumPlayers.Value), ConstructMapTravelText());
                              PlayerOwner().ClientCloseMenu();  break;
        case  bu_QuickRestart:  BS_xPlayer(PlayerOwner()).CallVote(5);
                              PlayerOwner().ClientCloseMenu();  break;
        case bu_Refresh:  RefreshMapList(); break;

    }
    return super.InternalOnClick(Sender);
}

function RefreshMapList()
{
    local int i;
    local UTComp_ServerReplicationInfo RepInfo;
    local string filter;
    local class<GameInfo> G;
    local array<string> Parts;
    local string S;

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    lb_MapList.List.Clear();
    if(RepInfo!=None)
    {
        Split(RepInfo.VotingOptions[co_GameTypeList.GetIndex()], "?", parts);
        for(i=0; i<parts.length; i++)
        {
            if(Left(parts[i], 5) ~="Game=")
                S=right(parts[i], len(parts[i])-5);
        }
        G=class<GameInfo>(DynamicLoadObject(S, class'class', true));
        if(S!="" && G!=None)
            filter=G.default.MapPrefix;
    }

    for(i=0; i<BS_xPlayer(PlayerOwner()).UTCompPRI.UTCompMapListclient.Length; i++)
    {
    //   Log("Adding"@BS_xPlayer(PlayerOwner()).UTCompPRI.UTCompMapListclient[i]);
       if(filter == "" || Left(BS_xPlayer(PlayerOwner()).UTCompPRI.UTCompMapListclient[i], len(filter))~=filter)
           lb_MapList.List.Add(BS_xPlayer(PlayerOwner()).UTCompPRI.UTCompMapListclient[i]);
    }
    if(BS_xPlayer(PlayerOwner()).UTCompPRI.TotalMapsToBeReceived<BS_xPlayer(PlayerOwner()).UTCompPRI.UTCompMapListclient.Length)
    {
  //      lb_MapList.DisableMe();
    }
    else
        lb_MapList.EnableMe();
}

function string ConstructMapTravelText()
{
    local string S;

    if(!cb_UseAdvancedOptions.IsChecked())
        return "";

     S=S$"?DoubleDamage="$GetTrueFalse(cb_DD.IsChecked());
     S=S$"?Adren="$GetTrueFalse(!cb_Adren.IsChecked());
     S=S$"?Timelimit="$ne_TimeLimit.Value;
     S=S$"?TimedOverTimeLength="$ne_OverTime.Value;
     S=S$"?GrenadesOnSpawn="$ne_Grenades.Value;
     S=S$"?GoalScore="$ne_GoalScore.Value;
     S=S$"?SuperWeps="$GetTrueFalse(!cb_SuperWeapons.IsChecked());
     S=S$"?WeaponStay="$GetTrueFalse(cb_WeaponStay.IsChecked());
     return S;
}

function string GetTrueFalse(bool b)
{
   if(b)
       return "true";
   return "false";
}

event Opened(GUIComponent Sender)
{
    super.Opened(Sender);
    cb_UseAdvancedOptions.Checked(False);
    refreshmaplist();
    Blehz();
    eb_MapInput.SetText(lb_MapList.List.SelectedText());
}

defaultproperties
{
     Begin Object Class=GUIEditBox Name=MapInputEditBox
		WinWidth=0.250000
		WinHeight=0.030000
		WinLeft=0.559687
		WinTop=0.462500
         OnActivate=MapInputEditBox.InternalActivate
         OnDeActivate=MapInputEditBox.InternalDeactivate
         OnKeyType=MapInputEditBox.InternalOnKeyType
         OnKeyEvent=MapInputEditBox.InternalOnKeyEvent
     End Object
     eb_MapInput=GUIEditBox'UTComp_Menu_Voting_GameType.MapInputEditBox'

     Begin Object Class=GUINumericEdit Name=MaxPlayersNE
         MinValue=2
		WinWidth=0.206250
		WinHeight=0.030000
		WinLeft=0.604999
		WinTop=0.414046
         OnDeActivate=MaxPlayersNE.ValidateValue
     End Object
     ne_NumPlayers=GUINumericEdit'UTComp_Menu_Voting_GameType.MaxPlayersNE'

     Begin Object Class=GUIComboBox Name=MapInputComboBox
		WinWidth=0.250000
		WinHeight=0.035000
		WinLeft=0.560311
		WinTop=0.362994
		OnChange=InternalOnChange
         OnKeyEvent=MapInputComboBox.InternalOnKeyEvent
     End Object
     co_GameTypeList=GUIComboBox'UTComp_Menu_Voting_GameType.MapInputComboBox'

     Begin Object Class=GUIButton Name=quickrestartButton
        bVisible=false
        Caption="Just Restart Map"
		WinWidth=0.217500
		WinHeight=0.047500
		WinLeft=0.379687
		WinTop=0.705418
         OnClick=UTComp_Menu_Voting_GameType.InternalOnClick
         OnKeyEvent=quickrestartButton.InternalOnKeyEvent
     End Object
     bu_QuickRestart=GUIButton'UTComp_Menu_Voting_GameType.quickrestartButton'

     Begin Object Class=GUIButton Name=ChangeMapButton
         Caption="Call Vote"
		WinWidth=0.262813
		WinHeight=0.047500
		WinLeft=0.456252
		WinTop=0.740469
         OnClick=UTComp_Menu_Voting_GameType.InternalOnClick
         OnKeyEvent=ChangeMapButton.InternalOnKeyEvent
     End Object
     bu_ChangeMap=GUIButton'UTComp_Menu_Voting_GameType.ChangeMapButton'

     Begin Object Class=GUILabel Name=MapNameLabel
         Caption="Map Name"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.352313
		WinTop=0.451250
     End Object
     l_MapName=GUILabel'UTComp_Menu_Voting_GameType.MapNameLabel'

     Begin Object Class=GUILabel Name=gametypeLabel
         Caption="Gametype"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.353875
		WinTop=0.349704
     End Object
     l_GameType=GUILabel'UTComp_Menu_Voting_GameType.gametypeLabel'

     Begin Object Class=GUILabel Name=MaxPlayersLabe
         Caption="Max Players"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.353438
		WinTop=0.400713
     End Object
     l_MaxPlayers=GUILabel'UTComp_Menu_Voting_GameType.MaxPlayersLabe'

     Begin Object class=GUIListBox name=MapListBox
		WinWidth=0.214061
		WinHeight=0.385937
		WinLeft=0.118750
		WinTop=0.350000
        bVisibleWhenEmpty=True
        OnChange=InternalOnChange
     End Object
     lb_MapList=GUIListBox'MapListBox'

     Begin Object class=moCheckBox name=AdrenCheck
		WinWidth=0.239062
		WinHeight=0.030000
		WinLeft=0.598437
		WinTop=0.549998
        Caption="Adren"
     End Object
     cb_Adren=moCheckBox'AdrenCheck'

     Begin Object class=moCheckBox name=WeaponStayCheck
        WinTop=0.65
        WinLeft=0.35
        WinWidth=0.24
        Caption="WeaponStay"
     End Object
     cb_WeaponStay=moCheckBox'WeaponStayCheck'

     Begin Object class=moCheckBox name=DDCheck
        WinTop=0.60
        WinLeft=0.35
        WinWidth=0.24
        Caption="DD"
     End Object
     cb_DD=moCheckBox'DDCheck'

     Begin Object class=moCheckBox name=SuperWeaponsCheck
        WinTop=0.55
        WinLeft=0.35
        WinWidth=0.24
        Caption="SuperWeapons"
     End Object
     cb_SuperWeapons=moCheckBox'SuperWeaponsCheck'

     Begin Object class=moCheckBox name=AdvancedOptionsCheck
        WinTop=0.50
        WinLeft=0.35
        WinWidth=0.24
        Caption="Advanced Options"
        OnChange=InternalOnChange
     End Object
     cb_UseAdvancedOptions=moCheckBox'AdvancedOptionsCheck'

     Begin Object Class=GUINumericEdit Name=GoalScoreNE
        MinValue=0
		WinWidth=0.103125
		WinHeight=0.030000
		WinLeft=0.736247
		WinTop=0.598331
         OnDeActivate=GoalScoreNE.ValidateValue
     End Object
     ne_GoalScore=GUINumericEdit'UTComp_Menu_Voting_GameType.GoalScoreNE'

     Begin Object Class=GUINumericEdit Name=timelimitNE
        MinValue=1
		WinWidth=0.103125
		WinHeight=0.030000
		WinLeft=0.736247
		WinTop=0.648331
        OnDeActivate=timelimitNE.ValidateValue
     End Object
     ne_timelimit=GUINumericEdit'UTComp_Menu_Voting_GameType.timelimitNE'


    Begin Object Class=GUINumericEdit Name=GrenadeNE
        MinValue=0
		WinWidth=0.103125
		WinHeight=0.030000
		WinLeft=0.736247
		WinTop=0.698331
		MaxValue=8
        OnDeActivate=GrenadeNE.ValidateValue
     End Object
     ne_grenades=GUINumericEdit'UTComp_Menu_Voting_GameType.grenadeNE'

     Begin Object Class=GUINumericEdit Name=OvertimeNE
        MinValue=0
		WinWidth=0.103125
		WinHeight=0.030000
		WinLeft=0.487810
		WinTop=0.696269
		MaxValue = 10
        OnDeActivate=OvertimeNE.ValidateValue
     End Object
     ne_Overtime=GUINumericEdit'UTComp_Menu_Voting_GameType.OvertimeNE'




     Begin Object Class=GUILabel Name=timelimitLabel
         Caption="Time Limit"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.598313
		WinTop=0.636583
     End Object
     l_timelimit=GUILabel'UTComp_Menu_Voting_GameType.timelimitLabel'

     Begin Object Class=GUILabel Name=grenadeLabel
         Caption="Grenades"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.598313
		WinTop=0.685449
     End Object
     l_grenades=GUILabel'UTComp_Menu_Voting_GameType.grenadeLabel'

     Begin Object Class=GUILabel Name=OvertimeLabel
         Caption="OT Length"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.346750
		WinTop=0.683387
     End Object
     l_OverTime=GUILabel'UTComp_Menu_Voting_GameType.OvertimeLabel'


     Begin Object Class=GUILabel Name=GoalScoreLabel
        Caption="GoalScore"
        TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.598313
		WinTop=0.584500
     End Object
     l_GoalScore=GUILabel'UTComp_Menu_Voting_GameType.GoalScoreLabel'

    Begin Object Class=GUIButton Name=RefreshButton
        Caption="Refresh Maps"
		WinWidth=0.217500
		WinHeight=0.047500
		WinLeft=0.110936
		WinTop=0.738752
		OnClick=InternalOnClick
     End Object
     bu_Refresh=GUIButton'RefreshButton'

}
