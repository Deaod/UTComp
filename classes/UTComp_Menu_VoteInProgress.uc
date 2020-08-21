
class UTComp_Menu_VoteInProgress extends UTComp_Menu_MainMenu;

var automated GUIButton bu_VoteYes, bu_VoteNo;
var automated GUILabel l_Vote[5];

event Opened(GUIComponent Sender)
{
     local UTComp_ServerReplicationInfo RepInfo;

     super.Opened(Sender);

     foreach PlayerOwner().DynamicActors(class'UTComp_ServerReplicationInfo', RepInfo)
         break;

     l_Vote[0].Caption="";
     l_Vote[1].Caption="A vote has been called to";
     switch(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID)
     {
         case 1:  l_Vote[2].Caption="change Brightskins Mode"; break;
         case 2:  l_Vote[2].Caption="change Hitsounds Mode"; break;
         case 3:  l_Vote[2].Caption="change Team Overlay Mode"; break;
         case 4:  l_Vote[2].Caption="change Warmup Mode"; break;
         case 5:  l_Vote[2].Caption="Restart The Map"; break;
         case 6:  l_Vote[2].Caption="Change Gametype"; break;
         case 7:  l_Vote[2].Caption="Change Map"; break;
         case 8:  l_Vote[2].Caption="Change DoubleDamage Mode"; break;
         case 9:  l_Vote[2].Caption="Change Enhanced Netcode Mode"; break;
         case 10:  l_Vote[2].Caption="Change Forward Mode"; break;
         default:  l_Vote[2].Caption=""; break;
     }
     if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID!=6 && BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID!=7)
     {
         switch(BS_xPlayer(PlayerOwner()).UTCompPRI.VoteSwitch)
         {
             case 0:  if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID==1)
                           l_Vote[3].Caption="Epic Style";
                      else if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID!=5)
                           l_Vote[3].Caption="Disabled";
                      else
                           l_Vote[3].Caption=""; break;
             case 1:  if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID==1)
                           l_Vote[3].Caption="Bright Epic Style";
                      else if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID==2)
                       l_Vote[3].Caption="Line Of Sight";
                      else if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID!=5)
                           l_Vote[3].Caption="Enabled";
                      else
                          l_Vote[3].Caption=""; break;
             case 2:  if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID==1)
                           l_Vote[3].Caption="UTComp Style";
                      else if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID==2)
                           l_Vote[3].Caption="Everywhere"; break;
             default:  l_Vote[3].Caption="";
         }
     }
     else if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID==6)
     {
         if(BS_xPlayer(PlayerOwner()).UTCompPRI.VoteSwitch<ArrayCount(RepInfo.VotingNames))
             l_Vote[3].Caption="To"@RepInfo.VotingNames[BS_xPlayer(PlayerOwner()).UTCompPRI.VoteSwitch]@"On"@BS_xPlayer(PlayerOwner()).UTCompPRI.VoteOptions;
         else l_Vote[3].Caption="";
     }
     else if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID==7)
     {
         if(BS_xPlayer(PlayerOwner()).UTCompPRI.VoteSwitch<ArrayCount(RepInfo.VotingNames))
             l_Vote[3].Caption="To"@BS_xPlayer(PlayerOwner()).UTCompPRI.VoteOptions;
         else l_Vote[3].Caption="";
     }
     if(BS_xPlayer(PlayerOwner()).UTCompPRI.CurrentVoteID==6)
         l_Vote[4].Caption="MP"@BS_xPlayer(PlayerOwner()).UTCompPRI.VoteSwitch2@MakeReadableOptions(BS_xPlayer(PlayerOwner()).UTCompPRI.VoteOptions2);
     else
         l_Vote[4].Caption="";
}

function string MakeReadableOptions(String S)
{
    S=Repl(S, "?", " ");
    S=Repl(S, "DoubleDamage", "DD");
    S=Repl(S, "GoalScore", "GS");
    S=Repl(S, "MaxPlayers", "MP");
    S=Repl(S, "SuperWeps", "Super");
    S=Repl(S, "WeaponStay", "WS");
    S=Repl(S, "TimeLimit", "TL");
    S=Repl(S, "GrenadesOnSpawn", "nades");
    S=Repl(S, "TimedOverTimeLength", "OT");
    if(instrnoncasesensitive(S, "Super=False"))
        S=Repl(S, "Super=False", "Super=True");
    else
        S=Repl(S, "Super=True", "Super=False");
    if(instrnoncasesensitive(S, "Adren=False"))
        S=Repl(S, "Adren=False", "Adren=True");
    else
        S=Repl(S, "Adren=True", "Adren=False");
    return S;
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
        case bu_VoteYes:  BS_xPlayer(PlayerOwner()).VoteYes();
                          PlayerOwner().ClientCloseMenu(); break;
        case bu_VoteNo:  BS_xPlayer(PlayerOwner()).VoteNo();
                         PlayerOwner().ClientCloseMenu(); break;
    }
    return super.InternalOnClick(Sender);
}

defaultproperties
{
     Begin Object Class=GUIButton Name=VoteYesButton
         Caption="Vote Yes"
         WinTop=0.639583
         WinLeft=0.301562
         WinWidth=0.160938
         WinHeight=0.080000
         OnClick=UTComp_Menu_VoteInProgress.InternalOnClick
         OnKeyEvent=VoteYesButton.InternalOnKeyEvent
     End Object
     bu_VoteYes=GUIButton'UTComp_Menu_VoteInProgress.VoteYesButton'

     Begin Object Class=GUIButton Name=votenoButton
         Caption="Vote No"
         WinTop=0.639583
         WinLeft=0.529689
         WinWidth=0.160938
         WinHeight=0.080000
         OnClick=UTComp_Menu_VoteInProgress.InternalOnClick
         OnKeyEvent=votenoButton.InternalOnKeyEvent
     End Object
     bu_VoteNo=GUIButton'UTComp_Menu_VoteInProgress.votenoButton'

     Begin Object Class=GUILabel Name=VoteLabel0
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         WinTop=0.350000
         Caption="--- Vote in progress ---"
     End Object
     l_Vote(0)=GUILabel'UTComp_Menu_VoteInProgress.VoteLabel0'

     Begin Object Class=GUILabel Name=VoteLabel1
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.400000
     End Object
     l_Vote(1)=GUILabel'UTComp_Menu_VoteInProgress.VoteLabel1'

     Begin Object Class=GUILabel Name=VoteLabel2
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.450000
     End Object
     l_Vote(2)=GUILabel'UTComp_Menu_VoteInProgress.VoteLabel2'

     Begin Object Class=GUILabel Name=VoteLabel3
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.500000
     End Object
     l_Vote(3)=GUILabel'UTComp_Menu_VoteInProgress.VoteLabel3'

      Begin Object Class=GUILabel Name=VoteLabel4
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.550000
     End Object
     l_Vote(4)=GUILabel'UTComp_Menu_VoteInProgress.VoteLabel4'

}
