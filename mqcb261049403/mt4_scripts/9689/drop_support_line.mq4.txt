#include <stdlib.mqh>   



//+------ CHANGE HERE THE COLOR AND WIDTH OF SUPPORT LINE --------+

color Support_Color = DodgerBlue;   
int   Support_Width = 1;         // From 1 (thin) to 5 (thick) 

//+------------------------------------------------------------------+   






//+-----------------------------SCRIPT CODE--------------------------+
int start()
  { 
   double Support = WindowPriceOnDropped();
   int TimeNow = TimeCurrent();
   
         ObjectCreate("Support_Line" + TimeNow,OBJ_HLINE,0,0,Support);
         
         ObjectSet("Support_Line" + TimeNow,OBJPROP_COLOR,Support_Color);
         ObjectSet("Support_Line" + TimeNow,OBJPROP_WIDTH,Support_Width);
         
   return(0);
  }
//+------------------------------------------------------------------+