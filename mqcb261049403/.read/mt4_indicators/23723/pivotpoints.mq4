//+------------------------------------------------------------------+
//|                                                  PivotPoints.mq4 |
//|                                                     Erdem Bozyel |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Erdem Bozyel"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window

extern color SupportColor = Red;
extern color ResistanceColor = Green;
extern color PivotColor = Maroon;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
 //Demark Saatlik Pivot-Destek-Direnç
   double op = iOpen(NULL,PERIOD_H4,1);
   double hi = iHigh(NULL,PERIOD_H4,1);
   double lo = iLow(NULL,PERIOD_H4,1);
   double cl = iClose(NULL,PERIOD_H4,1);

//demark
   double X=0;
   if(cl<op)
     {
      X=hi+(2*lo)+cl;
     }
   if(cl>op)
     {
      X=(2*hi)+lo+cl;
     }
   if(cl==op)
     {
      X=hi+lo+(2*cl);
     }
   double pivotDemark=X/4;
   double supportDemark=X/2-hi;
   double resistanceDemark=X/2-lo;

//Günlük Pivot-Destek-Direnç

   double hiDay=iHigh(NULL,PERIOD_D1,1);
   double loDay=iLow(NULL,PERIOD_D1,1);
   double clDay=iClose(NULL,PERIOD_D1,1);
   double pivotDay=(hiDay+loDay+clDay)/3;

   double resistance3Day=hiDay+2*(pivotDay-loDay);
   double resistance2Day=(pivotDay+(hiDay-loDay));
   double resistance1Day=(2*pivotDay)-loDay;

   double support1Day=(2*pivotDay)-hiDay;
   double support2Day=pivotDay-(hiDay-loDay);
   double support3Day=loDay-2*(hiDay-pivotDay);

//Demark create lines
   ObjectDelete("pivotDemark");
   ObjectCreate("pivotDemark",OBJ_HLINE,0,0,pivotDemark);
   ObjectSet("pivotDemark",OBJPROP_COLOR,PivotColor);
   ObjectSet("pivotDemark",OBJPROP_WIDTH,0);
   ObjectSet("pivotDemark",OBJPROP_STYLE,2);
   ObjectSet("pivotDemark",OBJPROP_RAY,false);
   ObjectSetText("pivotDemark","Pivot",0,"",PivotColor);

   ObjectDelete("supportDemark");
   ObjectCreate("supportDemark",OBJ_HLINE,0,0,supportDemark);
   ObjectSet("supportDemark",OBJPROP_COLOR,SupportColor);
   ObjectSet("supportDemark",OBJPROP_WIDTH,0);
   ObjectSet("supportDemark",OBJPROP_STYLE,2);
   ObjectSet("supportDemark",OBJPROP_RAY,false);
   ObjectSetText("supportDemark","Support",0,"",SupportColor);

   ObjectDelete("resistanceDemark");
   ObjectCreate("resistanceDemark",OBJ_HLINE,0,0,resistanceDemark);
   ObjectSet("resistanceDemark",OBJPROP_COLOR,ResistanceColor);
   ObjectSet("resistanceDemark",OBJPROP_WIDTH,0);
   ObjectSet("resistanceDemark",OBJPROP_STYLE,2);
   ObjectSet("resistanceDemark",OBJPROP_RAY,false);
   ObjectSetText("resistanceDemark","Resisdance",0,"",ResistanceColor);

//Day create lines
   ObjectDelete("pivotDay");
   ObjectCreate("pivotDay",OBJ_HLINE,0,0,pivotDay);
   ObjectSet("pivotDay",OBJPROP_COLOR,PivotColor);
   ObjectSet("pivotDay",OBJPROP_WIDTH,2);
   ObjectSet("pivotDay",OBJPROP_STYLE,0);
   ObjectSet("pivotDay",OBJPROP_RAY,false);
   ObjectSetText("pivotDay","Pivot Day",0,"",PivotColor);

   ObjectDelete("resistance1Day");
   ObjectCreate("resistance1Day",OBJ_HLINE,0,0,resistance1Day);
   ObjectSet("resistance1Day",OBJPROP_COLOR,ResistanceColor);
   ObjectSet("resistance1Day",OBJPROP_WIDTH,2);
   ObjectSet("resistance1Day",OBJPROP_STYLE,0);
   ObjectSet("resistance1Day",OBJPROP_RAY,false);
   ObjectSetText("resistance1Day","Resistance 1 Day",0,"",ResistanceColor);

   ObjectDelete("resistance2Day");
   ObjectCreate("resistance2Day",OBJ_HLINE,0,0,resistance2Day);
   ObjectSet("resistance2Day",OBJPROP_COLOR,ResistanceColor);
   ObjectSet("resistance2Day",OBJPROP_WIDTH,2);
   ObjectSet("resistance2Day",OBJPROP_STYLE,0);
   ObjectSet("resistance2Day",OBJPROP_RAY,false);
   ObjectSetText("resistance2Day","Resistance 2 Day",0,"",ResistanceColor);

   ObjectDelete("resistance3Day");
   ObjectCreate("resistance3Day",OBJ_HLINE,0,0,resistance3Day);
   ObjectSet("resistance3Day",OBJPROP_COLOR,ResistanceColor);
   ObjectSet("resistance3Day",OBJPROP_WIDTH,2);
   ObjectSet("resistance3Day",OBJPROP_STYLE,0);
   ObjectSet("resistance3Day",OBJPROP_RAY,false);
   ObjectSetText("resistance3Day","Resistance 3 Day",0,"",ResistanceColor);

   ObjectDelete("support1Day");
   ObjectCreate("support1Day",OBJ_HLINE,0,0,support1Day);
   ObjectSet("support1Day",OBJPROP_COLOR,SupportColor);
   ObjectSet("support1Day",OBJPROP_WIDTH,2);
   ObjectSet("support1Day",OBJPROP_STYLE,0);
   ObjectSet("support1Day",OBJPROP_RAY,false);
   ObjectSetText("support1Day","Support 1 Day",0,"",SupportColor);

   ObjectDelete("support2Day");
   ObjectCreate("support2Day",OBJ_HLINE,0,0,support2Day);
   ObjectSet("support2Day",OBJPROP_COLOR,SupportColor);
   ObjectSet("support2Day",OBJPROP_WIDTH,2);
   ObjectSet("support2Day",OBJPROP_STYLE,0);
   ObjectSet("support2Day",OBJPROP_RAY,false);
   ObjectSetText("support2Day","Support 2 Day",0,"",SupportColor);

   ObjectDelete("support3Day");
   ObjectCreate("support3Day",OBJ_HLINE,0,0,support3Day);
   ObjectSet("support3Day",OBJPROP_COLOR,SupportColor);
   ObjectSet("support3Day",OBJPROP_WIDTH,2);
   ObjectSet("support3Day",OBJPROP_STYLE,0);
   ObjectSet("support3Day",OBJPROP_RAY,false);
   ObjectSetText("support3Day","Support 3 Day",0,"",SupportColor);
//Alarmlar
   double trend=Close[0];

   if(trend>support1Day && trend<pivotDay)
     {
      ObjectDelete("text");
      ObjectCreate("text",OBJ_LABEL,0,0,0);
      ObjectSet("text",OBJPROP_COLOR,SupportColor);
      ObjectSetText("text","Down Trend",0,"",SupportColor);
      ObjectSet("text",OBJPROP_XDISTANCE,5);
      ObjectSet("text",OBJPROP_YDISTANCE,3);
      ObjectSet("text",OBJPROP_CORNER,3);
     }
   if(trend<resistance1Day && trend>pivotDay)
     {
      ObjectDelete("text");
      ObjectCreate("text",OBJ_LABEL,0,0,0);
      ObjectSet("text",OBJPROP_COLOR,ResistanceColor);
      ObjectSetText("text","Up Trend",0,"",ResistanceColor);
      ObjectSet("text",OBJPROP_XDISTANCE,5);
      ObjectSet("text",OBJPROP_YDISTANCE,20);
      ObjectSet("text",OBJPROP_CORNER,1);
     }

   if(trend>=resistance1Day && trend<resistance2Day)
     {
      ObjectDelete("text");
      ObjectCreate("text",OBJ_LABEL,0,0,0);
      ObjectSet("text",OBJPROP_COLOR,ResistanceColor);
      ObjectSetText("text","Up Trend",0,"",ResistanceColor);
      ObjectSet("text",OBJPROP_XDISTANCE,5);
      ObjectSet("text",OBJPROP_YDISTANCE,20);
      ObjectSet("text",OBJPROP_CORNER,1);
     }

   if(trend>=resistance2Day && trend<resistance3Day)
     {
      ObjectDelete("text");
      ObjectCreate("text",OBJ_LABEL,0,0,0);
      ObjectSet("text",OBJPROP_COLOR,ResistanceColor);
      ObjectSetText("text","Up Trend",0,"",ResistanceColor);
      ObjectSet("text",OBJPROP_XDISTANCE,5);
      ObjectSet("text",OBJPROP_YDISTANCE,20);
      ObjectSet("text",OBJPROP_CORNER,1);
     }

   if(trend>=resistance3Day)
     {
      ObjectDelete("text");
      ObjectCreate("text",OBJ_LABEL,0,0,0);
      ObjectSet("text",OBJPROP_COLOR,ResistanceColor);
      ObjectSetText("text","Up Trend",0,"",ResistanceColor);
      ObjectSet("text",OBJPROP_XDISTANCE,5);
      ObjectSet("text",OBJPROP_YDISTANCE,20);
      ObjectSet("text",OBJPROP_CORNER,1);
     }

   if(trend<=resistance1Day && trend>resistance2Day)
     {
      ObjectDelete("text");
      ObjectCreate("text",OBJ_LABEL,0,0,0);
      ObjectSet("text",OBJPROP_COLOR,SupportColor);
      ObjectSetText("text","Down Trend",0,"",SupportColor);
      ObjectSet("text",OBJPROP_XDISTANCE,5);
      ObjectSet("text",OBJPROP_YDISTANCE,3);
      ObjectSet("text",OBJPROP_CORNER,3);
     }

   if(trend<=resistance2Day && trend>resistance3Day)
     {
      ObjectDelete("text");
      ObjectCreate("text",OBJ_LABEL,0,0,0);
      ObjectSet("text",OBJPROP_COLOR,SupportColor);
      ObjectSetText("text","Down Trend",0,"",SupportColor);
      ObjectSet("text",OBJPROP_XDISTANCE,5);
      ObjectSet("text",OBJPROP_YDISTANCE,3);
      ObjectSet("text",OBJPROP_CORNER,3);
     }

   if(trend<=support3Day)
     {
      ObjectDelete("text");
      ObjectCreate("text",OBJ_LABEL,0,0,0);
      ObjectSet("text",OBJPROP_COLOR,SupportColor);
      ObjectSetText("text","Down Trend",0,"",SupportColor);
      ObjectSet("text",OBJPROP_XDISTANCE,5);
      ObjectSet("text",OBJPROP_YDISTANCE,3);
      ObjectSet("text",OBJPROP_CORNER,3);
     }  
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
