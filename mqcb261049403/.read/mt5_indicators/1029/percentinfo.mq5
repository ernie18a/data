//+------------------------------------------------------------------+
//|                                                  PercentInfo.mq5 |
//|  Copyright © 2009, Arif Endro Nugroho <arif_endro@vectra.web.id> |
//|                                             http://vectra.web.id |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Arif E. Nugroho <arif_endro@vectra.web.id>"
#property link      "http://vectra.web.id"
#property description ""

//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
// type_font enumeration description               |
// CFontName class description                     | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//| Indicator input parameters                 |
//+----------------------------------------------+
input color  UpColor=Teal;//color for the upward move
input color  DnColor=Magenta;//color for the downward move
input color  ZrColor=Gray;//color for no change
input int    FontSize=11; //font size
input type_font FontType=Font14; //font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; //location corner
input uint Y_=20; //vertical location
input uint X_=5; //horizontal location
//+----------------------------------------------+
string sFontType;
int shift_1,shift_2,shift_3;
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
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=40;
         shift_2=20;
         shift_3=0;
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=40;
         shift_2=20;
         shift_3=0;
         break;
        }
      default:
        {
         shift_1=0;
         shift_2=20;
         shift_3=40;
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
   ObjectDelete(0,"DailyStat");
   ObjectDelete(0,"WeeklyStat");
   ObjectDelete(0,"MonthlyStat");
//----
  }
//+------------------------------------------------------------------+
//|  Creating a text label                                        |
//+------------------------------------------------------------------+
void CreateTLabel
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
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
//|  Resetting a text label                                   |
//+------------------------------------------------------------------+
void SetTLabel
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
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
string StringWordConvertor(string Name,double OpPrice,double ClPrice,int digits)
  {
//----
   string word=Name;
   word=word+DoubleToString(OpPrice, digits) + "/";
   word=word+DoubleToString(ClPrice, digits) + " [";
   double dPrice=ClPrice-OpPrice;
   word=word+DoubleToString(MathPow(10, digits)*MathAbs(dPrice), 0) + "|";
   word=word+DoubleToString(100*(MathAbs(dPrice)/OpPrice),2) + "%]";
//----
   return(word);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
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
   double DayOpPrice[1],DayClPrice[1],WeekOpPrice[1],WeekClPrice[1],MonthOpPrice[1],MonthClPrice[1];

//---- copy the new data into the array  
   if(CopyOpen(Symbol(),PERIOD_D1,0,1,DayOpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_D1,0,1,DayClPrice)<=0) return(RESET);
   if(CopyOpen(Symbol(),PERIOD_W1,0,1,WeekOpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_W1,0,1,WeekClPrice)<=0) return(RESET);
   if(CopyOpen(Symbol(),PERIOD_MN1,0,1,MonthOpPrice)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_MN1,0,1,MonthClPrice)<=0) return(RESET);
//----
   color  ColorDayGain=ZrColor;
   color  ColorWeekGain=ZrColor;
   color  ColorMonthGain=ZrColor;
//----
   string DailyInfo  = StringWordConvertor("Daily....: ",DayOpPrice[0],DayClPrice[0],_Digits);
   string WeeklyInfo = StringWordConvertor("Weekly...: ",WeekOpPrice[0],WeekClPrice[0],_Digits);
   string MonthlyInfo= StringWordConvertor("Monthly..: ",MonthOpPrice[0],MonthClPrice[0],_Digits);
//----
   if(DayClPrice[0]-DayOpPrice[0]<0) ColorDayGain=DnColor;
   else ColorDayGain=UpColor;
//----
   if(WeekClPrice[0]-WeekOpPrice[0]<0) ColorWeekGain=DnColor;
   else ColorWeekGain=UpColor;
//----
   if(MonthClPrice[0]-MonthOpPrice[0]<0) ColorMonthGain=DnColor;
   else ColorMonthGain=UpColor;
//----
   SetTLabel(0,"DailyStat",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+shift_1,DailyInfo,ColorDayGain,sFontType,FontSize);
   SetTLabel(0,"WeeklyStat",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+shift_2,WeeklyInfo,ColorWeekGain,sFontType,FontSize);
   SetTLabel(0,"MonthlyStat",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+shift_3,MonthlyInfo,ColorMonthGain,sFontType,FontSize);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
