//+------------------------------------------------------------------+
//|                                                        Clock.mq5 |
//|                               Copyright © 2012, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2012,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
#property description "The three options of time displaying: local, server and GMT!"

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
input color  Color1=clrBlue;//color of local time
input color  Color2=clrMagenta;//color of server time
input color  Color3=clrTeal;//color of GMT time
input int    FontSize=11; //font size
input type_font FontType=Font14; //font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; //location corner
input uint Y_=20; //vertical location
input uint X_=5; //horizontal location
input string LableSirname="Clock 1";
//+----------------------------------------------+
string sFontType,Lable1,Lable2,Lable3,Lable1_,Lable2_,Lable3_;
uint shift_1,shift_2,shift_3,X1,X2;
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
   Lable1=LableSirname+"_"+"Local_Time";
   Lable2=LableSirname+"_"+"Brokers_Time";
   Lable3=LableSirname+"_"+"GMT";
//----   
   Lable1_=LableSirname+"_"+"Local_Time_";
   Lable2_=LableSirname+"_"+"Brokers_Time_";
   Lable3_=LableSirname+"_"+"GMT_";
//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=int(Y_+FontSize*3.0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+0);
         X1=int(X_+FontSize*6);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=int(Y_+FontSize*3.0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+0);
         X1=int(X_);
         X2=X_+FontSize*10;
         break;
        }

      case CORNER_RIGHT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+FontSize*3.0);
         X1=int(X_+FontSize*6);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+FontSize*3.0);
         X1=int(X_);
         X2=int(X_+FontSize*10);
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
   ObjectDelete(0,Lable3);
   ObjectDelete(0,Lable1_);
   ObjectDelete(0,Lable2_);
   ObjectDelete(0,Lable3_);
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
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
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
   string sTime1,sTime2,sTime3;

   sTime1=TimeToString(TimeLocal(),TIME_SECONDS);
   sTime2=TimeToString(TimeCurrent(),TIME_SECONDS);
   sTime3=TimeToString(TimeGMT(),TIME_SECONDS);

//----
   SetTLabel(0,Lable1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_1,"Local Time: ",Color1,sFontType,FontSize);
   SetTLabel(0,Lable1_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_1,sTime1,Color1,sFontType,FontSize);

   SetTLabel(0,Lable2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_2,"Brokers Time: ",Color2,sFontType,FontSize);
   SetTLabel(0,Lable2_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_2,sTime2,Color2,sFontType,FontSize);

   SetTLabel(0,Lable3,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_3,"GMT: ",Color3,sFontType,FontSize);
   SetTLabel(0,Lable3_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_3,sTime3,Color3,sFontType,FontSize);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
