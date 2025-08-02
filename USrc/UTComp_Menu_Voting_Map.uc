

class UTComp_Menu_Voting_Map extends UTComp_Menu_MainMenu;

var automated GUIListBox lb_MapList;

var automated GUIEditBox eb_MapInput;

var automated GUIButton bu_QuickRestart, bu_ChangeMap;

var automated GUILabel l_MapName;

var automated guibutton bu_Refresh;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

    Super.Initcomponent(MyController, MyOwner);
    Blehz();
}

function InternalOnChange( GUIComponent C )
{
    Switch(C)
    {
       case lb_MapList:  eb_MapInput.SetText(lb_MapList.List.SelectedText()); break;
    }
}

function Blehz()
{
    local UTComp_ServerReplicationInfo RepInfo;

    foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
        break;

    if(RepInfo!=None && !RepInfo.bEnableWarmup)
        bu_QuickRestart.DisableMe();
    else
       bu_QuickRestart.EnableMe();
    if(RepInfo!=None && !RepInfo.bEnableMapVoting)
    {
        eb_MapInput.disableme();
        bu_ChangeMap.DisableMe();
    }
    else
    {
        eb_mapinput.enableme();
        bu_ChangeMap.EnableMe();
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

    switch (Sender)
    {
        case bu_ChangeMap:    if(eb_MapInput.GetText()!="")
                                  BS_xPlayer(PlayerOwner()).CallVote(7, , eb_MapInput.GetText());
                              else
                                  BS_xPlayer(PlayerOwner()).CallVote(7, , lb_MapList.List.SelectedText());
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
    local string filter;
    local string S;
    local array<string> Parts;
    lb_MapList.List.Clear();

    S=PlayerOwner().GetURLMap();

    split(s,"-", parts);
    filter=parts[0];

    for(i=0; i<BS_xPlayer(PlayerOwner()).UTCompPRI.UTCompMapListclient.Length; i++)
    {
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


event Opened(GUIComponent Sender)
{
    super.Opened(Sender);

    refreshmaplist();
    Blehz();
    eb_MapInput.SetText(lb_MapList.List.SelectedText());
}

defaultproperties
{
     Begin Object Class=GUIEditBox Name=MapInputEditBox
		WinWidth=0.250000
		WinHeight=0.030000
		WinLeft=0.550312
		WinTop=0.493750
         OnActivate=MapInputEditBox.InternalActivate
         OnDeActivate=MapInputEditBox.InternalDeactivate
         OnKeyType=MapInputEditBox.InternalOnKeyType
         OnKeyEvent=MapInputEditBox.InternalOnKeyEvent
     End Object
     eb_MapInput=GUIEditBox'UTComp_Menu_Voting_Map.MapInputEditBox'

     Begin Object Class=GUIButton Name=quickrestartButton
        Caption="Restart Current Map"
		WinWidth=0.255000
		WinHeight=0.047500
		WinLeft=0.545314
		WinTop=0.607500
         OnClick=UTComp_Menu_Voting_Map.InternalOnClick
         OnKeyEvent=quickrestartButton.InternalOnKeyEvent
     End Object
     bu_QuickRestart=GUIButton'UTComp_Menu_Voting_Map.quickrestartButton'

     Begin Object Class=GUIButton Name=ChangeMapButton
         Caption="Change Map"
		WinWidth=0.256563
		WinHeight=0.047500
		WinLeft=0.546874
		WinTop=0.542915
         OnClick=UTComp_Menu_Voting_Map.InternalOnClick
         OnKeyEvent=ChangeMapButton.InternalOnKeyEvent
     End Object
     bu_ChangeMap=GUIButton'UTComp_Menu_Voting_Map.ChangeMapButton'

     Begin Object Class=GUILabel Name=MapNameLabel
         Caption="Map Name"
         TextColor=(B=255,G=255,R=255)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.380438
		WinTop=0.480417
     End Object
     l_MapName=GUILabel'UTComp_Menu_Voting_Map.MapNameLabel'

     Begin Object class=GUIListBox name=MapListBox
		WinWidth=0.214061
		WinHeight=0.385937
		WinLeft=0.118750
		WinTop=0.350000
        bVisibleWhenEmpty=True
        OnChange=InternalOnChange
     End Object
     lb_MapList=GUIListBox'MapListBox'

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

