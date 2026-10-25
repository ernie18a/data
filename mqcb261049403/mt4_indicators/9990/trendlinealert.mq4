#property copyright "EmilioStefanoReale"
#property link      ""

#property indicator_chart_window
#include <general.mqh>

//---- input parameters
extern bool      AlertLineUp=true;
extern bool      AlertLineDn=true;
extern double    tollerance = 0;
extern string    LineUpName="U";
extern string    LineDnName="D";
extern string    AlertSoundFile = "trendline.wav";
extern bool      test = false;

bool ready = false;
bool signaled = false;
double tl;

void alarm(string msg) {
   Alert("[TL Alert]", Symbol(), msg);
}

void cmt(string msg)
{
   Comment(msg);
}

string period2str(int period) {
   switch(period) {
      case PERIOD_M1:
         return("M1");
         break;
      case PERIOD_M5:
         return("M5");
         break;
      case PERIOD_M15:
         return("M15");
         break;
      case PERIOD_M30:
         return("M30");
         break;
      case PERIOD_H1:
         return("H1");
         break;
      case PERIOD_H4:
         return("H4");
         break;
      case PERIOD_D1:
         return("DAILY");
         break;
      case PERIOD_W1:
         return("WEEKLY");
         break;
      case PERIOD_MN1:
         return("MONTHLY");
         break;
      default:
         return (DoubleToStr(period, 0));   
   }
}

int init() {
   tl = tollerance * Point;
   ready = true;
   if (ObjectFind(LineUpName) != 0 && AlertLineUp) {
      alarm(" manca la trendline di nome " + LineUpName);
      ready = ready && false;
   }
   if (ObjectFind(LineDnName) != 0 && AlertLineDn) {
      alarm(" manca la trendline di nome " + LineDnName);
      ready = ready && false;
   }
   if (!ready) cmt("verificare errori"); else cmt("... Allarme trendline inizializzato.");
   if (ready && test) {
      Al();
   }   
   return(0);
}

void Al() {
   PlaySound(AlertSoundFile);
   Alert(Symbol(), " ", period2str(Period()), " ","Controllare la rottura trendline.");
}

int deinit() {

   return(0);
}

int start() {
   if (ready) {
      if (AlertLineUp && !signaled) {
         double up = LineValue(LineUpName, 0);
         if (Bid > up - tl) { Al(); signaled = true; }
      }
      if (AlertLineDn && !signaled) {
         double dn = LineValue(LineDnName, 0);
         if (Bid < dn + tl) { Al(); signaled = true; }
      }
   }

   return(0);
}

