//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TimeStamp_Controller extends Controller;

var int timestamp;
var bool odd;

function tick(float deltatime)
{
 //  local rotator R;
 //  local int i;
   if(Pawn==none)
   {
       Pawn = spawn(pawnclass);
       possess(pawn);
   }
   if(Pawn==none)
       return;

 /*  R.Yaw = (TimeStamp%256)*256;
   i=TimeStamp/256;
   R.Pitch = i*256;

   odd = !odd;
   Pawn.SetRotation(R);
   TimeStamp+=1;        */
}

DefaultProperties
{
   pawnclass=class'TimeStamp_Pawn'
}
