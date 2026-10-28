#include <stdlib.mqh>   



//+------ CHANGE HERE SUPPORT LINE PARAMETERS -----------------------+

color Support_Color     = DodgerBlue;  //  
int   Support_Width     = 2;           // From 1 (thin) to 5 (thick) 
int   Support_length    = 4000;        // Length of support line. 
bool  Support_Ray       = false;       // If "false" support line will be drawn as a "segment". If "true", as a "Ray".

//+------------------------------------------------------------------+   






//+-----------------------------SCRIPT CODE--------------------------+
int start()
  { 
   double      Support = WindowPriceOnDropped();
   datetime    time = WindowTimeOnDropped();
   int         TimeNow = TimeCurrent();
   int         timeframe = Period();
   double      factor;

   switch(timeframe)
      {
      case 1      : factor = 0.2;   break;
      case 5      : factor = 1;     break;
      case 15     : factor = 3;     break;
      case 30     : factor = 6;     break;
      case 60     : factor = 12;    break;
      case 240    : factor = 48;    break;
      case 1440   : factor = 288;   break;
      case 10080  : factor = 2016;  break;
      case 43200  : factor = 8640;  break;
      }
   
   int length = factor * Support_length;

         ObjectCreate("Support_Line" + TimeNow,OBJ_TREND,0,time+length,Support,time-length,Support);        
         ObjectSet("Support_Line" + TimeNow,OBJPROP_COLOR,Support_Color);
         ObjectSet("Support_Line" + TimeNow,OBJPROP_WIDTH,Support_Width);
         ObjectSet("Support_Line" + TimeNow,OBJPROP_RAY,false);
         
   return(0);
  }
//+------------------------------------------------------------------+