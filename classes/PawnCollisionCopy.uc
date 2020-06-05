
//-----------------------------------------------------------
//   This class acts simulated collision for the copied
//   pawn, for use in lag compensated firing.
//   This is used mostly so we don't have to worry about screwing
//   with the physics of the actual pawn when moving about.
//
//
//  *    IF YOU AREN'T DOING A TRACE ON THIS COPY,
//   MAKE ABSOLUTELY SURE ITS COLLISION IS TURNED OFF */
//-----------------------------------------------------------
class PawnCollisionCopy extends Actor;

var PawnCollisionCopy Next;

var float CrouchHeight;
var float CrouchRadius;

var MutUTComp M;

var Pawn CopiedPawn;
var bool bNormalDestroy;

struct PawnHistoryElement
{
    var vector Location;
    var rotator Rotation;
    var bool bCrouched;
    var float TimeStamp;
    var EPhysics Physics;
};

var array<PawnHistoryElement> PawnHistory;

//Furthest we will allow backtracking
const MAX_HISTORY_LENGTH = 0.350;

var bool bCrouched;


var InterpCurve LocCurveX, LocCurveY,LocCurveZ;

/* Set up the collision properties of our copy */
function SetPawn(Pawn Other)
{
    if(Level.NetMode == NM_Client)
        Warn("Client should never have a collision copy");

    if(Other == none)
    {
        Warn("PawnCopy spawned without proper Other");
        //  Destroy();
        return;
    }
 //   if(CopiedPawn==None)
    CopiedPawn=Other;

    if(M==None)
        foreach DynamicActors(class'MutUTComp', M)
            break;
    CrouchHeight=CopiedPawn.CrouchHeight;
    CrouchRadius=CopiedPawn.CrouchRadius;
    bUseCylinderCollision = CopiedPawn.bUseCylinderCollision;
    bCrouched=CopiedPawn.bIsCrouched;

    //If we cant use simple collisions, set up the mesh
    if(!bUseCylinderCollision)
        LinkMesh(CopiedPawn.Mesh);
    else
        SetCollisionSize(CopiedPawn.CollisionRadius, CopiedPawn.CollisionHeight);
}

/*
What happens if its not an xpawn and its changing shapes?
*/
function GoToPawn()
{
    if(CopiedPawn == none)
        return;

    SetLocation(CopiedPawn.Location);
    SetCollisionSize(CopiedPawn.CollisionRadius,CopiedPawn.CollisionHeight);

    if(bUseCylinderCollision)
    {
        if(!bCrouched && CopiedPawn.bIsCrouched)
        {
             SetCollisionSize(CrouchRadius, CrouchHeight);
             bCrouched=True;
        }
        else if(bCrouched && !CopiedPawn.bIsCrouched)
        {
            SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
            bCrouched=false;
        }
    }

    SetCollision(true);
}

/*
What happens if its not an xpawn and its changing shapes?
*/
function TimeTravelPawn(float dt)
{
    local int i, Floor, Ceiling;
    local bool bFloor, bCeiling;
  //  local vector V;
    local vector V2;
    local float StampDT;
//    local float Alpha;
  //  local float Interpdt;

    if(CopiedPawn == none || CopiedPawn.DrivenVehicle!=None)
       return;
    StampDT = M.ClientTimeStamp - dt;
    SetCollision(false);

    //We cant backtrack, too recent, just go straight to the pawn
    if(PawnHistory.Length == 0 || PawnHistory[PawnHistory.Length-1].TimeStamp < StampDT )
    {
        GoToPawn();
        return;
    }

    //Sandwich between 2 history parts Ceiling and Floor
    for(i=PawnHistory.Length-1; i >= 0; i--)
    {
        //This will set the more recent part
        if(PawnHistory[i].TimeStamp >= StampDT)
        {
            bFloor=true;
            Floor = i;
        }
        // we either ran into, or got under the stamp
        // this is the older stamp
        // Now we should have a ceiling and floor both
        else
        {
            bCeiling=true;
            Ceiling=i;
            break;
        }
    }

    if(bCeiling)
    {
        /* if(bFloor)
         {
             // interpolate between the 2 locations based on stampDT
             Alpha = (PawnHistory[Floor].TimeStamp - StampDT) / (PawnHistory[Floor].TimeStamp - PawnHistory[ceiling].TimeStamp);
             if(Alpha > 1.0 || alpha < 0.0)
                log("Error, alpha out of expected range");

             V.X = lerp(Alpha, PawnHistory[Floor].Location.X, PawnHistory[ceiling].Location.X, true);
             V.Y = lerp(Alpha, PawnHistory[Floor].Location.Y, PawnHistory[ceiling].Location.Y, true);
             V.Z = lerp(Alpha, PawnHistory[Floor].Location.Z, PawnHistory[ceiling].Location.Z, true);
         }
         else
         {
            log("Error, no floor");
         }
        */
         /* Highest gravity error at center of the 2 samples, 0 at ends
         This doesn't amount to a pinch of shit on any realistic tickrate
         but might as well keep it for now, can always remove it later*/
       /*  if(PawnHistory[Floor].Physics == PHYS_FALLING && PawnHistory[Ceiling].Physics == PHYS_FALLING)
         {
             if(alpha > 0.50)
                InterpDT= (1.0-Alpha)*(PawnHistory[Floor].TimeStamp - PawnHistory[ceiling].TimeStamp);
             else
                InterpDT = (Alpha)*(PawnHistory[Floor].TimeStamp - PawnHistory[ceiling].TimeStamp);
             V = V - 0.5*CopiedPawn.PhysicsVolume.Gravity*Square(InterpDT);   //close enough??
         }     */


         V2.X = InterpCurveEval(LocCurveX,StampDT);
         V2.Y = InterpCurveEval(LocCurveY,StampDT);
         V2.Z = InterpCurveEval(LocCurveZ,StampDT);

         SetLocation(V2);
         SetRotation(PawnHistory[Floor].Rotation);

         if(bUseCylinderCollision)
         {
             if(!bCrouched && PawnHistory[Floor].bCrouched && PawnHistory[Ceiling].bCrouched)
             {
                 SetCollisionSize(CrouchRadius, CrouchHeight);
                 bCrouched=True;
             }
             else if(bCrouched && (!PawnHistory[Floor].bCrouched || !PawnHistory[Ceiling].bCrouched))
             {
                 SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
                 bCrouched=false;
             }
         }

         /* Maybe interpolate rotation? */


    }
    else
    {
          /* FixMe:  This shouldn't need to be set unless it changes, but for now
         lets just be safe and set it every time for now*/
         if(PawnHistory[Floor].bCrouched)
             SetCollisionSize(CrouchRadius, CrouchHeight);
         else if(CopiedPawn.IsA('xPawn'))
             SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
         else if(bUseCylinderCollision)
             SetCollisionSize(CopiedPawn.CollisionRadius, CopiedPawn.CollisionHeight);

         SetLocation(PawnHistory[Floor].Location);
         SetRotation(PawnHistory[Floor].Rotation);
    }
    SetCollision(true);
}


function TurnOffCollision()
{
    SetCollision(false);
}

function AddPawnToList(Pawn Other)
{
    // Already got it, dont bother.
  /*  if(Other == CopiedPawn)
        return;         */

    if(next==None)
    {
        Next = Spawn(class'PawnCollisionCopy');
        Next.SetPawn(Other);
    }
    else
       Next.AddPawnToList(Other);
}

//Remove old pawns, returns what Next should be for the caller
//PawnCollisionCopies
function PawnCollisionCopy RemoveOldPawns()
{
    if(CopiedPawn == none)
    {
        bNormalDestroy=True;
        Destroy();
        if(Next!=None)
            return Next.RemoveOldPawns();
        return none;
    }
    else if(Next!=None)
        Next = Next.RemoveOldPawns();
    return self;
}

/* damage the copied pawn, NOT THIS */
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    Warn("Pawn collision copy should never take damage");
}

event destroyed()
{
  /* if(!bNormalDestroy)
      Warn("DESTROYED WITHOUT SETTING UP LIST");     */
   super.Destroyed();
}

function Identify()
{
   if(CopiedPawn==None)
      Log("PCC: No pawn");
   else
   {
      if(CopiedPawn.PlayerReplicationInfo!=None)
          Log("PCC: Pawn"@CopiedPawn.PlayerReplicationInfo.PlayerName);
      else
          Log("PCC: Unnamed Pawn");
   }
}

function tick(float DeltaTime)
{
    if(CopiedPawn==None)
        return;
    AddHistory();
    RemoveOutdatedHistory();
}

function AddHistory()
{
    local int i;
    local InterpCurvePoint XPoint,YPoint,ZPoint;

    i=Pawnhistory.Length;
    PawnHistory.Length=i+1;
    PawnHistory[i].Location = CopiedPawn.Location;
    PawnHistory[i].Rotation = CopiedPawn.Rotation;
    PawnHistory[i].bCrouched = CopiedPawn.bIsCrouched;
    PawnHistory[i].TimeStamp = M.ClientTimeStamp;
    PawnHistory[i].Physics = CopiedPawn.Physics;

    XPoint.InVal = M.ClientTimeStamp;
    XPoint.OutVal = CopiedPawn.Location.X;
    LocCurveX.Points.Insert(LocCurveX.Points.Length,1);
    LocCurveX.Points[LocCurveX.Points.Length-1]=XPoint;

    YPoint.InVal = M.ClientTimeStamp;
    YPoint.OutVal = CopiedPawn.Location.Y;
    LocCurveY.Points.Insert(LocCurveY.Points.Length,1);
    LocCurveY.Points[LocCurveY.Points.Length-1]=YPoint;

    ZPoint.InVal = M.ClientTimeStamp;
    ZPoint.OutVal = CopiedPawn.Location.Z;
    LocCurveZ.Points.Insert(LocCurveZ.Points.Length,1);
    LocCurveZ.Points[LocCurveZ.Points.Length-1]=ZPoint;
}

function RemoveOutdatedHistory()
{
    while(PawnHistory.Length > 0 && PawnHistory[0].TimeStamp + MAX_HISTORY_LENGTH < M.ClientTimeStamp )
       PawnHistory.Remove(0,1);
    while(LocCurveX.Points.Length > 0 &&  LocCurveX.Points[0].InVal + MAX_HISTORY_LENGTH < M.ClientTimeStamp)
    {
        LocCurveX.Points.Remove(0,1);
        LocCurveY.Points.Remove(0,1);
        LocCurveZ.Points.Remove(0,1);
    }
}

defaultproperties
{
    RemoteRole=ROLE_NONE
    Physics==PHYS_NONE

    //Dont collide with ANYTHING but the traces if we can avoid it
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bProjTarget=false
    bBlockProjectiles=false
    bDisturbFluidSurface=false
    bCanBeDamaged=false
    bAcceptsProjectors=false
    bCanTeleport=false
    bHidden=true
    bOnlyDirtyReplication=true
	bSkipActorPropertyReplication=true

    CollisionRadius=25.000000    //Direct copies from xPawn
    CollisionHeight=44.000000

    CrouchHeight=29.000000   //Direct copies from xPawn
    CrouchRadius=25.000000
}
