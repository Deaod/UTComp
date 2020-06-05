

class UTComp_VotingHandler extends Info;

CONST fVOTINGTIMER = 1.0;
var float fVotingTime;
var float fVotingPercent;

var byte CurrentVoteID;
var byte iOldVoteID;

var string sVotingOptions;
var string sVotingOptionsAlt;
var int VoteSwitch;
var int VoteSwitch2;
var bool bAdminBypassVote;
var bool bVoteFailed;
var string CallingPlayer;

var MutUTComp UTCompMutator;

function InitializeVoting()
{
    SetTimer(fVOTINGTIMER, true);
}

function bool StartVote(byte b, byte p, string Options, optional string Caller, optional byte P2, optional string Options2, optional bool bAdminBypass)
{
    if(CurrentVoteID==255)
    {
        CurrentVoteID=b;
        VoteSwitch=p;
        VoteSwitch2=p2;
        sVotingOptions=Options;
        sVotingOptionsAlt=Options2;
        fVotingTime=default.fVotingTime;
        bAdminBypassVote=bAdminBypass;
        CallingPlayer = Caller;
        return true;
    }
    return false;
}

function Timer()
{
    if(!UTcompMutator.bEnableVoting)
        return;

    if(VoteInProgress() && !TimedOut() && VotePasses())
    {
        TakeActionOnVote(CurrentVoteID, VoteSwitch, sVotingOptions);
        ResetVoting();
    }
}

function ResetVoting()
{
    VoteSwitch=255;
    CurrentVoteID=255;
    iOldVoteID=255;
}

function bool TimedOut()
{
    fVotingTime-=fVOTINGTIMER;
    if(fVotingTime<=0)
    {
        CurrentVoteID=255;
        iOldVoteID=255;
        if(bVoteFailed)
        {
            NotifyPlayersFail();
            bVoteFailed=false;
        }
        else
            NotifyPlayersTimeOut();
        return true;
    }
    return false;
}

function TakeActionOnVote(byte VoteType, byte VoteSwitch, string Options)
{
    local string S;
    local array<String> Parts, Parts2;
    local int i, j;
    local bool bMutatorFound, bUseAdren, bUseSuper, bfoundadren, bfoundsuper;

    fVotingTime=0;

    if(VoteType==1 && UTCompMutator.bEnableBrightskinsVoting)
    {
        UTCompMutator.EnableBrightSkinsMode=Min(VoteSwitch+1, 3);
        UTCompMutator.default.EnableBrightSkinsMode=Min(VoteSwitch+1, 3);
        UTCompMutator.RepInfo.EnableBrightSkinsMode=Min(VoteSwitch+1, 3);
    }
    else if(VoteType==2 && UTCompMutator.bEnableHitSoundsVoting)
    {
        UTCompMutator.EnableHitSoundsMode=Min(VoteSwitch, 2);
        UTCompMutator.default.EnableHitSoundsMode=Min(VoteSwitch, 2);
        UTCompMutator.RepInfo.EnableHitSoundsMode=Min(VoteSwitch, 2);
    }
    else if(VoteType==3 && UTCompMutator.bEnableTeamOverlayVoting)
    {
        UTCompMutator.bEnableTeamOverlay=(VoteSwitch==1);
        UTCompMutator.default.bEnableTeamOverlay=(VoteSwitch==1);
        UTCompMutator.RepInfo.bEnableTeamOverlay=(VoteSwitch==1);
    }
    else if(VoteType==4 && UTCompMutator.bEnableWarmupVoting)
    {
        UTCompMutator.bEnableWarmup=(VoteSwitch==1);
        UTCompMutator.default.bEnableWarmup=(VoteSwitch==1);
        UTCompMutator.RepInfo.bEnableWarmup=(VoteSwitch==1);
    }
    else if(VoteType==5 && UTCompMutator.WarmupClass!=None && (UTCompMutator.bEnableMapVoting || UTCompMutator.bAllowRestartVoteEvenIfMapVotingIsTurnedOff) )
    {
        UTCompMutator.WarmupClass.SoftRestart();
    }
    else if(VoteType==6 && UTCompMutator.bEnableGameTypeVoting && UTCompMutator.bEnableMapVoting)
    {
        if(!UTCompMutator.bForceMapVoteMatchPrefix || MatchesGametypePrefix(sVotingOptions, UTCompMutator.VotingGameType[Voteswitch].GameTypeOptions))
        {
        }
        else
        {
            BroadcastLocalizedMessage(class'UTComp_VoteFailed');
            return;
        }
        S=sVotingOptions$UTCompMutator.VotingGameType[Voteswitch].GameTypeOptions$"?MaxPlayers="$Min(VoteSwitch2, UTCompMutator.ServerMaxPlayers);

        Split(S,"?",Parts);
        for(i=0; i<Parts.Length; i++)
        {
            if(Left(Parts[i],7)~="Mutator")
            {
               bMutatorFound=True;
               for(j=0; j<UTCompMutator.AlwaysUseThisMutator.Length; j++)
                  Parts[i]=Parts[i]$","$UTCompMutator.AlwaysUseThisMutator[j];
            }
        }

        S=Parts[0];
        for(i=1; i<Parts.Length; i++)
        {
            S=S$"?"$Parts[i];
        }
        if(!bMutatorFound)
        {
            S=S$"?Mutator=";

            if(UTCompMutator.AlwaysUseThisMutator.Length>0)
            {
                S=S$UTCompMutator.AlwaysUseThisMutator[0];
            }
            for(j=1; j<UTCompMutator.AlwaysUseThisMutator.Length; j++)
                S=S$","$UTCompMutator.AlwaysUseThisMutator[j];
        }
        bMutatorFound=False;
        if(UTCompMutator.bEnableAdvancedVotingOptions)
        {
            split(sVotingOptionsAlt, "?", Parts2);

            for(j=0; j<Parts2.Length; j++)
            {
                //Add DD
                if(Left(Parts2[j], 13)~="DoubleDamage="
                && (Right(Parts2[j], Len(Parts2[j])-13)~="True" || Right(Parts2[j], Len(Parts2[j])-13)~="False"))
                {
                    if(InstrNonCaseSensitive(S, "DoubleDamage="))
                    {
                        for(i=0; i<Parts.Length; i++)
                        {
                            if(Left(Parts[i], 13)~="DoubleDamage=")
                                S=Repl(S,Parts[i],Parts2[j]);
                        }
                    }
                    else
                        S=S$"?"$Parts2[j];
                }
                //Add GrenadesOnSpawn
                else if(Left(Parts2[j], 16)~="GrenadesOnSpawn=")
                {
                    if(InstrNonCaseSensitive(S, "GrenadesOnSpawn="))
                    {
                        for(i=0; i<Parts.Length; i++)
                        {
                            if(Left(Parts[i], 16)~="GrenadesOnSpawn=")
                                S=Repl(S,Parts[i],Parts2[j]);
                        }
                    }
                    else
                        S=S$"?"$Parts2[j];
                }
                else if(Left(Parts2[j], 20)~="TimedOverTimeLength=")
                {
                    if(InstrNonCaseSensitive(S, "TimedOverTimeLength="))
                    {
                        for(i=0; i<Parts.Length; i++)
                        {
                            if(Left(Parts[i], 20)~="TimedOverTimeLength=")
                                S=Repl(S,Parts[i],Parts2[j]);
                        }
                    }
                    else
                        S=S$"?"$Parts2[j];
                }
                //Add WepStay
                else if(Left(Parts2[j], 11)~="WeaponStay="
                && (Right(Parts2[j], Len(Parts2[j])-11)~="True" || Right(Parts2[j], Len(Parts2[j])-11)~="False"))
                {
                    if(InstrNonCaseSensitive(S, "WeaponStay="))
                    {
                        for(i=0; i<Parts.Length; i++)
                        {
                            if(Left(Parts[i], 11)~="WeaponStay=")
                                S=Repl(S,Parts[i],Parts2[j]);
                        }
                    }
                    else
                        S=S$"?"$Parts2[j];
                }
                //Add GoalScore
                else if(Left(Parts2[j], 10)~="GoalScore=")
                {
                    if(InstrNonCaseSensitive(S, "GoalScore="))
                    {
                        for(i=0; i<Parts.Length; i++)
                        {
                            if(Left(Parts[i], 10)~="GoalScore=")
                                S=Repl(S,Parts[i],Parts2[j]);
                        }
                    }
                    else
                        S=S$"?"$Parts2[j];
                }
                //Add TimeLimit
                else if(Left(Parts2[j], 10)~="TimeLimit=")
                {
                    if(InstrNonCaseSensitive(S, "TimeLimit="))
                    {
                        for(i=0; i<Parts.Length; i++)
                        {
                            if(Left(Parts[i], 10)~="TimeLimit=")
                                S=Repl(S,Parts[i],Parts2[j]);
                        }
                    }
                    else
                        S=S$"?"$Parts2[j];
                }
                //Add SuperWeps/Adren
                else if(Left(Parts2[j],6)~="Adren=")
                {
                    bFoundAdren=True;
                    bUseAdren=(Right(Parts2[j], Len(Parts2[j])-6)~="False");
                }
                else if(Left(Parts2[j],10)~="SuperWeps=")
                {
                    bFoundSuper=True;
                    bUseSuper=(Right(Parts2[j], Len(Parts2[j])-10)~="False");
                }
            }
            for(i=0; i<UTCompMutator.AlwaysUseThisMutator.Length; i++)
            {
               if(UTCompMutator.AlwaysUseThisMutator[i]~="xGame.MutNoAdrenaline")
                   bUseAdren=False;
               if(UTCompMutator.AlwaysUseThisMutator[i]~="xWeapons.MutNoSuperWeapon")
                   bUseSuper=False;
            }

            if(bFoundAdren || bFoundSuper)
            {
                if(InstrNonCaseSensitive(S, "Mutator="))
                {
                    if(bFoundAdren && bUseAdren)
                    {
                        if(instrNonCaseSensitive(S, "xGame.MutNoAdrenaline"))
                        {
                            S=repl(S, ",xGame.MutNoAdrenaline", "");
                            S=repl(S, "=xGame.MutNoAdrenaline,", "=");
                            S=repl(S, "xGame.MutNoAdrenaline", "");
                        }
                    }
                    if(bFoundSuper && bUseSuper)
                    {
                        if(InstrNonCaseSensitive(S, "xWeapons.MutNoSuperWeapon"))
                        {
                            S=repl(S, ",xWeapons.MutNoSuperWeapon", "");
                            S=repl(S, "=xWeapons.MutNoSuperWeapon,", "=");
                            S=repl(S, "xWeapons.MutNoSuperWeapon", "");
                        }
                    }
                    if(bFoundAdren && !bUseAdren)
                    {
                        if(!instrNonCaseSensitive(S, "xGame.MutNoAdrenaline"))
                            S=Repl(S, "Mutator=", "Mutator=xGame.MutNoAdrenaline,");
                    }
                    if(bFoundSuper && !bUseSuper)
                    {
                        if(!instrNonCaseSensitive(S, "xWeapons.MutNoSuperWeapon"))
                            S=Repl(S, "Mutator=", "Mutator=xWeapons.MutNoSuperWeapon,");
                    }
                }
                else
                {
                    if(bFoundSuper && bFoundAdren)
                    {
                        if(bUseSuper && bUseAdren)
                            S=S$"?Mutator=xGame.MutNoAdrenaline,xWeapons.MutNoSuperWeapon";
                        else if(bUseSuper)
                           S=S$"?Mutator=xWeapons.MutNoSuperWeapon";
                        else if(bUseAdren)
                           S=S$"?Mutator=xGame.MutNoAdrenaline";
                    }
                    else if(bFoundSuper && bUseSuper)
                        S=S$"?Mutator=xWeapons.MutNoSuperWeapon";
                    else if(bFoundAdren && bUseAdren)
                        S=S$"?Mutator=xGame.MutNoAdrenaline";
                }
            }
        }
        Level.ServerTravel(S,False);
    }
    else if(VoteType==7 && UTCompMutator.bEnableMapVoting)
    {
        if(!UTCompMutator.bForceMapVoteMatchPrefix || Left(sVotingOptions, Len(Level.Game.MapPrefix))~=Level.Game.MapPrefix)
            Level.ServerTravel(sVotingOptions, False);
        else
            BroadcastLocalizedMessage(class'UTComp_VoteFailed');
    }
    else if(VoteType==8 && UTCompMutator.bEnableTimedOvertimeVoting)
    {
        UTCompMutator.bEnableTimedOverTime=(VoteSwitch==1);
        UTCompMutator.default.bEnableTimedOverTime=(VoteSwitch==1);
        UTCompMutator.RepInfo.bEnableTimedOverTime=(VoteSwitch==1);
    }
    else if(VoteType==9 && UTCompMutator.bEnableEnhancedNetCodeVoting)
    {
        UTCompMutator.bEnableEnhancedNetCode=(VoteSwitch==1);
        UTCompMutator.default.bEnableEnhancedNetCode=(VoteSwitch==1);
        UTCompMutator.RepInfo.bEnableEnhancedNetCode=(VoteSwitch==1);
    }
    else if(VoteType==10 && UTCompMutator.bEnableForwardVoting)
    {
        UTCompMutator.bForward=(VoteSwitch==1);
        UTCompMutator.default.bForward=(VoteSwitch==1);
    }
    UTCompMutator.static.StaticSaveConfig();
}

function bool MatchesGametypePrefix(string MapName, string S)
{
    local class<GameInfo> G;
    local array<string> Parts;
    local string S2;
    local int i;
    local string filter;

    Split(S, "?", parts);
    for(i=0; i<parts.length; i++)
    {
        if(Left(parts[i], 5) ~="Game=")
            S2=right(parts[i], len(parts[i])-5);
    }
    G=class<GameInfo>(DynamicLoadObject(S2, class'class', true));
    if(S2!="" && G!=None)
        filter=G.default.MapPrefix;
    if(Filter!="" && Left(MapName,Len(filter))~=filter)
        return true;
    return false;
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


function bool VoteInProgress()
{
    if(CurrentVoteID!=255)
    {
        if(CurrentVoteID!=iOldVoteID)
        {
            NotifyPlayersStart();
            iOldVoteID=CurrentVoteID;
        }
        return true;
    }
    return false;
}

function NotifyPlayersPasses()
{
    NotifyPlayersEnd();
    if(VoteSwitch==8 || VoteSwitch == 9 || VoteSwitch == 10)
        BroadCastLocalizedMessage(class'UTComp_Vote_Passed', 1);
    else
        BroadCastLocalizedMessage(class'UTComp_Vote_Passed');
}

function NotifyPlayersStart()
{
    NotifyPlayers();
    BroadCastLocalizedMessage(class'UTComp_Vote_Started', CurrentVoteID);
    Level.Game.Broadcast(Self, "A vote has started by "$CallingPlayer$", press F5 to vote.");
}

function NotifyPlayersTimeOut()
{
    NotifyPlayersEnd();
    BroadCastLocalizedMessage(class'UTComp_Vote_TimeOut');
}

function NotifyPlayersFail()
{
    NotifyPlayersEnd();
    BroadCastLocalizedMessage(class'UTComp_Vote_Failed');
}

function NotifyPlayers()
{
    local controller C;
    local UTComp_PRI uPRI;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(PlayerController(C)!=None && C.PlayerReplicationInfo!=None)
            uPRI=Class'UTComp_Util'.static.GetUTCompPRI(C.PlayerReplicationInfo);
        if(uPRI!=None)
        {
            uPRI.CurrentVoteID=CurrentVoteID;
            uPRI.VoteSwitch=VoteSwitch;
            uPRI.VoteSwitch2=VoteSwitch2;
            uPRI.VoteOptions=sVotingOptions;
            uPRI.VoteOptions2=sVotingOptionsAlt;
        }
    }
}

function NotifyPlayersEnd()
{
    local controller C;
    local UTComp_PRI uPRI;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(PlayerController(C)!=None && C.PlayerReplicationInfo!=None)
            uPRI=Class'UTComp_Util'.static.GetUTCompPRI(C.PlayerReplicationInfo);
        if(uPRI!=None)
        {
            uPRI.CurrentVoteID=255;
            uPRI.VoteSwitch=255;
            uPRI.Vote=255;
            uPRI.VoteOptions="";
        }
    }
}

function bool VotePasses()
{
    local Controller C;
    local UTComp_PRI uPRI;
    local float fTotalVoteYes;
    local float fTotalVoteNo;
    local float fTotalAbstained;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(C.PlayerReplicationInfo!=None && PlayerController(C)!=None && !C.PlayerReplicationInfo.bOnlySpectator)
        {
            uPRI=Class'UTComp_Util'.static.GetUTCompPRI(C.PlayerReplicationInfo);
        }
        if(uPRI!=None)
        {
            if(uPRI.Vote==1)
                fTotalVoteYes+=1.0;
            else if(uPRI.Vote==2)
                fTotalVoteNo+=1.0;
            else
                fTotalAbstained+=1.0;
        }
        uPRI=None;
     }
     UpdatePlayersOfTotal(fTotalVoteYes, fTotalVoteNo);

     if(fTotalVoteYes>=1.0 && fTotalVoteYes/(fTotalVoteNo+fTotalAbstained+fTotalVoteYes)>=(fVotingPercent/100.0))
     {
         NotifyPlayersPasses();
         return true;
     }

     if(bAdminBypassVote)
     {
         NotifyPlayersPasses();
         bAdminBypassVote=False;
         return true;
     }

     if(fTotalVoteNo>=1.0 && fTotalVoteNo/(fTotalVoteYes+fTotalVoteNo+fTotalAbstained)>(100.0-fVotingPercent)/100.0)
     {
         fVotingTime=0.0;
         bVoteFailed=true;
     }
     return false;
}

function UpdatePlayersOfTotal(float VotedYes, float VotedNo)
{
    local controller C;
    local UTComp_PRI uPRI;

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(PlayerController(C)!=None && C.PlayerReplicationInfo!=None)
            uPRI=Class'UTComp_Util'.static.GetUTCompPRI(C.PlayerReplicationInfo);
        if(uPRI!=None)
        {
            uPRI.VotedYes=VotedYes;
            uPRI.VotedNo=VotedNo;
        }
    }
}

defaultproperties
{
     fVotingTime=30.000000
     fVotingPercent=51.000000
     CurrentVoteID=255
     iOldVoteID=255
     VoteSwitch=255
     bHidden=True
}
