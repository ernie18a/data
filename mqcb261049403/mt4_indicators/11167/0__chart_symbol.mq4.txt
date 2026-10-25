//+---------------------------------------------------------------------------+
//| Chart Symbol | Author: file45 | http://codebase.mql4.com/en/author/file45 |
//|                                 Copyright 2013, MetaQuotes Software Corp. |
//|                                                     https://forge.mql5.io |
//+---------------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property indicator_chart_window

extern color Font_Color = LightSlateGray;
extern int Font_Size_ = 12;
extern bool Font_Bold = false;
extern int Label_Corner = 1;
extern int Left_Right = 20;
extern int Up_Down = 80;

string TM, TZF;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    switch(Period())
   {    
      case 1:     TM = "M1";  break;
      case 2:     TM = "M2";  break;
      case 3:     TM = "M3";  break;
      case 4:     TM = "M4";  break;
      case 5:     TM = "M5";  break;
      case 6:     TM = "M6";  break;
      case 7:     TM = "M7";  break;
      case 8:     TM = "M8";  break;
      case 9:     TM = "M9";  break;
      case 10:    TM = "M10"; break;
      case 11:    TM = "M11"; break;
      case 12:    TM = "M12"; break;
      case 13:    TM = "M13"; break;
      case 14:    TM = "M14"; break;
      case 15:    TM = "M15"; break;
      case 20:    TM = "M20"; break;
      case 25:    TM = "M25"; break;
      case 30:    TM = "M30"; break;
      case 40:    TM = "M40"; break;
      case 45:    TM = "M45"; break;
      case 50:    TM = "M50"; break;
      case 60:    TM = "H1";  break;
      case 120:   TM = "H2";  break;
      case 180:   TM = "H3";  break;
      case 240:   TM = "H4";  break;
      case 300:   TM = "H5";  break;
      case 360:   TM = "H6";  break;
      case 420:   TM = "H7";  break;
      case 480:   TM = "H8";  break;
      case 540:   TM = "H9";  break;
      case 600:   TM = "H10"; break;
      case 660:   TM = "H11"; break;
      case 720:   TM = "H12"; break;
      case 1440:  TM = "D1";  break;
      case 10080: TM = "W1";  break;
      case 43200: TM = "M4";  break;
   }   
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
   switch(Font_Bold == true)
   {
      case 1: TZF = "Arial Bold"; break;
      case 0: TZF = "Arial"; break;
   }      
   
   ObjectCreate("SYB",OBJ_LABEL,0,0,0);
   ObjectSetText("SYB",Symbol()+ " " + TM,Font_Size_,TZF,Font_Color);
   ObjectSet("SYB",OBJPROP_CORNER, Label_Corner);
   ObjectSet("SYB",OBJPROP_XDISTANCE, Left_Right);
   ObjectSet("SYB",OBJPROP_YDISTANCE, Up_Down);
   
   return(rates_total);
}

int deinit()
{
   ObjectDelete("SYB");
   return(0);
}