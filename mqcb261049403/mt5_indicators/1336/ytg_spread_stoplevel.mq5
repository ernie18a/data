//+------------------------------------------------------------------+
//|                                         ytg_Spread_StopLevel.mq5 |
//|                                   Copyright © 2009, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
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
// type_font enumeration description             |
// CFontName class description                   | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input color  UpColor=Teal;//up color
input color  DnColor=Magenta;//down color
input color  ZrColor=Gray;//color for no change
input int    FontSize=11; //font size
input type_font FontType=Font14; //font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; //location corner
input uint Y_=20; //vertical location
input uint X_=5; //horizontal location
input string LableSirname="ytg_Spread_StopLevel";
//+----------------------------------------------+
string sFontType,Lable1,Lable2;
uint shift_1,shift_2;
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
   Lable1=LableSirname+"_"+string(1);
   Lable2=LableSirname+"_"+string(2);
//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=Y_+20;
         shift_2=Y_+0;
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=Y_+20;
         shift_2=Y_+0;
         break;
        }
      default:
        {
         shift_1=Y_+0;
         shift_2=Y_+20;
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
   ObjectDelete(0,Lable1);
   ObjectDelete(0,Lable2);
//----
  }
//+------------------------------------------------------------------+
//|  Creating a text label                                           |
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
//|  Resetting a text label                                          |
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
   static int prev_spread,prev_stoplevel;
   
   int SPREAD=spread[rates_total-1];
   int STOPS_LEVEL=int(SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL));
//----
   color ColorGain1,ColorGain2;
//---- 
   if(SPREAD>prev_spread) ColorGain1=UpColor; else if(SPREAD<prev_spread) ColorGain1=DnColor; else ColorGain1=ZrColor;
   if(STOPS_LEVEL>prev_stoplevel) ColorGain2=UpColor; else if(STOPS_LEVEL<prev_stoplevel) ColorGain2=DnColor; else ColorGain2=ZrColor;
//----
   prev_spread=SPREAD;
   prev_stoplevel=STOPS_LEVEL;
//----
   string text1="Spread "+string(SPREAD);
   string text2="Stop level "+string(STOPS_LEVEL);
//----
   SetTLabel(0,Lable1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_1,text1,ColorGain1,sFontType,FontSize);
   SetTLabel(0,Lable2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_2,text2,ColorGain2,sFontType,FontSize);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
