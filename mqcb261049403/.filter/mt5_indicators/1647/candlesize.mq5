//+------------------------------------------------------------------+
//|                                                   CandleSize.mq5 |
//|                               Copyright © 2012, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2012,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
#property description "The size in points of the last three candlesticks of the selected timeframe"

//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- no buffers are used for the calculation and drawing of the indicator
#property indicator_buffers 0
//---- 0 graphical plots are used in total
#property indicator_plots   0
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
input string Symbol_="";                    // financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;  // Indicator timeframe for the indicator calculation
input color  UpColor=clrTeal;                         // rising candlestick color
input color  MdColor=clrGray;                         // candlestick line color
input color  DnColor=clrMagenta;                      // falling candlestick color
input int    FontSize=13;                             // font size
input type_font FontType=Font14;                      // font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; // location corner
input uint Y_=20;                                      // vertical location
input uint X_=5;                                       // horizontal location
input string LableSirname="CandleSize 1";
//+----------------------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
string sFontType,Lable1,Lable2,Lable3,Lable1_,Lable2_,Lable3_,symbol;
uint shift_1,shift_2,shift_3,X1,X2;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(1+PeriodSeconds(Timeframe)/PeriodSeconds(PERIOD_CURRENT))*3;

//---- initialization of variables 
   if(Symbol_!="") symbol=Symbol_;
   else symbol=Symbol();

//----
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
//---- 
   Lable1=LableSirname+"_"+"Candle_0";
   Lable2=LableSirname+"_"+"Candle_1";
   Lable3=LableSirname+"_"+"Candle_2";
//----   
   Lable1_=LableSirname+"_"+"Candle_0_";
   Lable2_=LableSirname+"_"+"Candle_1_";
   Lable3_=LableSirname+"_"+"Candle_2_";
//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=int(Y_+FontSize*3.0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+0);
         X1=int(X_+FontSize*3);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=int(Y_+FontSize*3.0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+0);
         X1=int(X_);
         X2=X_+FontSize*5;
         break;
        }

      case CORNER_RIGHT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+FontSize*3.0);
         X1=int(X_+FontSize*3);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*1.5);
         shift_3=int(Y_+FontSize*3.0);
         X1=int(X_);
         X2=int(X_+FontSize*5);
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
   ChartRedraw(0);
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
//---- checking for the sufficiency of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);

//----
   double iHigh[3],iLow[3],iOpen[3],iClose[3],point;
   double Trend0,Trend1,Trend2;
   int Range0,Range1,Range2;
   string sRange0,sRange1,sRange2;
   color ColorX0,ColorX1,ColorX2;

//---- copy newly appeared data into the arrays
   if(CopyLow(symbol,Timeframe,0,3,iLow)<=0) return(RESET);
   if(CopyHigh(symbol,Timeframe,0,3,iHigh)<=0) return(RESET);
   if(CopyOpen(symbol,Timeframe,0,3,iOpen)<=0) return(RESET);
   if(CopyClose(symbol,Timeframe,0,3,iClose)<=0) return(RESET);
//---- 
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(RESET);
   Range0=int((iHigh[2]-iLow[2])/point);
   Range1=int((iHigh[1]-iLow[1])/point);
   Range2=int((iHigh[0]-iLow[0])/point);
//----   
   sRange0=string(Range0);
   sRange1=string(Range1);
   sRange2=string(Range2);
//----   
   Trend0=iClose[2]-iOpen[2];
   Trend1=iClose[1]-iOpen[1];
   Trend2=iClose[0]-iOpen[0];
//----
   if(Trend0>0) ColorX0=UpColor; else if(Trend0<0) ColorX0=DnColor; else ColorX0=MdColor;
   if(Trend1>0) ColorX1=UpColor; else if(Trend1<0) ColorX1=DnColor; else ColorX1=MdColor;
   if(Trend2>0) ColorX2=UpColor; else if(Trend2<0) ColorX2=DnColor; else ColorX2=MdColor;
//----
   SetTLabel(0,Lable1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_1,"bar[0]: ",ColorX0,sFontType,FontSize);
   SetTLabel(0,Lable1_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_1,sRange0,ColorX0,sFontType,FontSize);

   SetTLabel(0,Lable2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_2,"bar[1]: ",ColorX1,sFontType,FontSize);
   SetTLabel(0,Lable2_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_2,sRange1,ColorX1,sFontType,FontSize);

   SetTLabel(0,Lable3,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X1,shift_3,"bar[2]: ",ColorX2,sFontType,FontSize);
   SetTLabel(0,Lable3_,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X2,shift_3,sRange2,ColorX2,sFontType,FontSize); 
//----  
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
