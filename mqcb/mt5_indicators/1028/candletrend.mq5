//+------------------------------------------------------------------+
//|                                                  CandleTrend.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property description "The indicator shows the direction of candles on different timeframes"
//---- indicator version number
#property version   "1.00"
//---- draw indicator in the main window
#property indicator_chart_window
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // Constant for sending the indicator recalculation command back to the terminal
//+----------------------------------------------+
// type_font enumeration description             |
// CFontName class description                   | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input color  UpColor=LimeGreen;  // currency uptrend color
input color  DnColor=Red;        // currency downtrend color
input color  ZrColor=Gray;       // no change color
input int    FontSize=11;        // font size
input type_font FontType=Font14; // font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; // location corner
input uint Y_=20;                                     // vertical location
input uint X_=5;                                      // horizontal location
//+----------------------------------------------+
string sFontType;
uint xshift,shift_1,shift_2,shift_3,shift_4,shift_5,shift_6;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//----
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
//----  
   xshift=int(X_+5.7*FontSize);
//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=Y_+110;
         shift_2=Y_+88;
         shift_3=Y_+66;
         shift_4=Y_+44;
         shift_5=Y_+22;
         shift_6=Y_+0;
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=Y_+110;
         shift_2=Y_+88;
         shift_3=Y_+66;
         shift_4=Y_+44;
         shift_5=Y_+22;
         shift_6=Y_+0;
         break;
        }
      default:
        {
         shift_1=Y_+0;
         shift_2=Y_+22;
         shift_3=Y_+44;
         shift_4=Y_+66;
         shift_5=Y_+88;
         shift_6=Y_+110;
        }
     }
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   ObjectDelete(0,"H4Stat+");
   ObjectDelete(0,"H8Stat+");
   ObjectDelete(0,"H12Stat+");
   ObjectDelete(0,"DailyStat+");
   ObjectDelete(0,"WeeklyStat+");
   ObjectDelete(0,"MonthlyStat+");
//----   
   ObjectDelete(0,"H4Stat_");
   ObjectDelete(0,"H8Stat_");
   ObjectDelete(0,"H12Stat_");
   ObjectDelete(0,"DailyStat_");
   ObjectDelete(0,"WeeklyStat_");
   ObjectDelete(0,"MonthlyStat_");
//----
  }
//+------------------------------------------------------------------+
//|  Create text label                                               |
//+------------------------------------------------------------------+
void CreateTLabel
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner, // base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // distance from the base corner along the X-axis in pixels
 int    Y,                // distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Set text label                                                  |
//+------------------------------------------------------------------+
void SetTLabel
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner, // base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//----
   double H4OpPrice[1],H4ClPrice[1],H8OpPrice[1],H8ClPrice[1],H12OpPrice[1],H12ClPrice[1];
   double DayOpPrice[1],DayClPrice[1],WeekOpPrice[1],WeekClPrice[1],MonthOpPrice[1],MonthClPrice[1];

//---- copy newly appeared data into the arrays 
   if(CopyOpen(Symbol(),PERIOD_H4,0,1,H4OpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_H4,0,1,H4ClPrice)<=0) return(RESET);
   if(CopyOpen(Symbol(),PERIOD_H8,0,1,H8OpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_H8,0,1,H8ClPrice)<=0) return(RESET);
   if(CopyOpen(Symbol(),PERIOD_H12,0,1,H12OpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_H12,0,1,H12ClPrice)<=0) return(RESET);
//---- copy newly appeared data into the arrays     
   if(CopyOpen(Symbol(),PERIOD_D1,0,1,DayOpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_D1,0,1,DayClPrice)<=0) return(RESET);
   if(CopyOpen(Symbol(),PERIOD_W1,0,1,WeekOpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_W1,0,1,WeekClPrice)<=0) return(RESET);
   if(CopyOpen(Symbol(),PERIOD_MN1,0,1,MonthOpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_MN1,0,1,MonthClPrice)<=0) return(RESET);
//----
   color ColorH4Gain=ZrColor;
   color ColorH8Gain=ZrColor;
   color ColorH12Gain=ZrColor;  
   color ColorDailyGain=ZrColor;
   color ColorWeeklyGain=ZrColor;
   color ColorMonthlyGain=ZrColor;
//----
   if(H4ClPrice[0]-H4OpPrice[0]<0) ColorH4Gain=DnColor; else ColorH4Gain=UpColor;
   if(H8ClPrice[0]-H8OpPrice[0]<0) ColorH8Gain=DnColor; else ColorH8Gain=UpColor;
   if(H12ClPrice[0]-H12OpPrice[0]<0) ColorH12Gain=DnColor; else ColorH12Gain=UpColor;
   if(DayClPrice[0]-DayOpPrice[0]<0) ColorDailyGain=DnColor; else ColorDailyGain=UpColor;
   if(WeekClPrice[0]-WeekOpPrice[0]<0) ColorWeeklyGain=DnColor; else ColorWeeklyGain=UpColor;
   if(MonthClPrice[0]-MonthOpPrice[0]<0) ColorMonthlyGain=DnColor; else ColorMonthlyGain=UpColor;
//----
   SetTLabel(0,"H4Stat+",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_1,"H4: ",ColorH4Gain,sFontType,FontSize);
   SetTLabel(0,"H4Stat_",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),xshift,shift_1,"n",ColorH4Gain,"Wingdings",FontSize);
   
   SetTLabel(0,"H8Stat+",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_2,"H8: ",ColorH8Gain,sFontType,FontSize);
   SetTLabel(0,"H8Stat_",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),xshift,shift_2,"n",ColorH8Gain,"Wingdings",FontSize);
   
   SetTLabel(0,"H12Stat+",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_3,"H12: ",ColorH12Gain,sFontType,FontSize);
   SetTLabel(0,"H12Stat_",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),xshift,shift_3,"n",ColorH12Gain,"Wingdings",FontSize);
   
   SetTLabel(0,"DailyStat+",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_4,"Daily: ",ColorDailyGain,sFontType,FontSize);
   SetTLabel(0,"DailyStat_",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),xshift,shift_4,"n",ColorDailyGain,"Wingdings",FontSize);
   
   SetTLabel(0,"WeeklyStat+",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_5,"Weekly: ",ColorWeeklyGain,sFontType,FontSize);
   SetTLabel(0,"WeeklyStat_",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),xshift,shift_5,"n",ColorWeeklyGain,"Wingdings",FontSize);
   
   SetTLabel(0,"MonthlyStat+",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_6,"Monthly: ",ColorMonthlyGain,sFontType,FontSize);
   SetTLabel(0,"MonthlyStat_",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),xshift,shift_6,"n",ColorMonthlyGain,"Wingdings",FontSize);       
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
