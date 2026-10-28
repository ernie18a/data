//+------------------------------------------------------------------+
//|                                     ytg_Change_Price_Percent.mq5 |
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
input string Symbol1="EURUSD";
input string Symbol2="USDCHF";
input string Symbol3="GBPUSD";
input string Symbol4="USDJPY";
input color  UpColor=Teal;//color for the upward move
input color  DnColor=Magenta;//color for the downward move
input color  ZrColor=Gray;//color for no change
input int    FontSize=11; //font size
input type_font FontType=Font14; //font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; //location corner
input uint Y_=20; //vertical location
input uint X_=5; //horizontal location
input string LableSirname="ytg_Change_Price_Percent 1";
//+----------------------------------------------+
string sFontType,Lable1,Lable2,Lable3,Lable4;
uint shift_1,shift_2,shift_3,shift_4;
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
   Lable3=LableSirname+"_"+string(3);
   Lable4=LableSirname+"_"+string(4);

//----
   if(!SymbolInfoInteger(Symbol1,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) Print(__FUNCTION__,"(): There is no such a symbol  - ",Symbol1,"!!!");
      if(!SymbolSelect(Symbol1,true)) Print(__FUNCTION__,"(): Failed to add a symbol ",Symbol1," to the MarketWatch window!!!");
     }
//----
   if(!SymbolInfoInteger(Symbol2,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) Print(__FUNCTION__,"(): There is no such a symbol - ",Symbol2,"!!!");
      if(!SymbolSelect(Symbol2,true)) Print(__FUNCTION__,"(): Failed to add a symbol ",Symbol2," to the MarketWatch window!!!");
     }
//----
   if(!SymbolInfoInteger(Symbol3,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) Print(__FUNCTION__,"(): There is no such a symbol - ",Symbol3,"!!!");
      if(!SymbolSelect(Symbol3,true)) Print(__FUNCTION__,"(): Failed to add a symbol ",Symbol3," to the MarketWatch window");
     }
//----
   if(!SymbolInfoInteger(Symbol4,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) Print(__FUNCTION__,"(): There is no such a symbol  - ",Symbol4,"!!!");
      if(!SymbolSelect(Symbol4,true)) Print(__FUNCTION__,"(): Failed to add a symbol ",Symbol4," to the MarketWatch window!!!");
     }

//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=Y_+60;
         shift_2=Y_+40;
         shift_3=Y_+20;
         shift_4=Y_+0;
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=Y_+60;
         shift_2=Y_+40;
         shift_3=Y_+20;
         shift_4=Y_+0;
         break;
        }
      default:
        {
         shift_1=Y_+0;
         shift_2=Y_+20;
         shift_3=Y_+40;
         shift_4=Y_+60;
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
   ObjectDelete(0,Lable4);
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
   double Price1[2],Price2[2],Price3[2],Price4[2];

//--- copy newly appeared data in the array  
   if(CopyClose(Symbol1,PERIOD_D1,0,2,Price1)<=0) return(RESET);
   if(CopyClose(Symbol2,PERIOD_D1,0,2,Price2)<=0) return(RESET);
   if(CopyClose(Symbol3,PERIOD_D1,0,2,Price3)<=0) return(RESET);
   if(CopyClose(Symbol4,PERIOD_D1,0,2,Price4)<=0) return(RESET);

   double sym_1 =(Price1[1] - Price1[0])*100/Price1[0];
   double sym_2 =(Price2[1] - Price2[0])*100/Price2[0];
   double sym_3 =(Price3[1] - Price3[0])*100/Price3[0];
   double sym_4 =(Price4[1] - Price4[0])*100/Price4[0];
//----
   color  ColorGain1=ZrColor;
   color  ColorGain2=ZrColor;
   color  ColorGain3=ZrColor;
   color  ColorGain4=ZrColor;
//----
   string Symbol_1 =Symbol1+" = "+DoubleToString(sym_1,4)+" %";
   string Symbol_2 =Symbol2+" = "+DoubleToString(sym_2,4)+" %";
   string Symbol_3 =Symbol3+" = "+DoubleToString(sym_3,4)+" %";
   string Symbol_4 =Symbol4+" = "+DoubleToString(sym_4,4)+" %";
//----
   if(sym_1<0) ColorGain1=DnColor; else ColorGain1=UpColor;
   if(sym_2<0) ColorGain2=DnColor; else ColorGain2=UpColor;
   if(sym_3<0) ColorGain3=DnColor; else ColorGain3=UpColor;
   if(sym_4<0) ColorGain4=DnColor; else ColorGain4=UpColor;
//----
   SetTLabel(0,Lable1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_1,Symbol_1,ColorGain1,sFontType,FontSize);
   SetTLabel(0,Lable2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_2,Symbol_2,ColorGain2,sFontType,FontSize);
   SetTLabel(0,Lable3,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_3,Symbol_3,ColorGain3,sFontType,FontSize);
   SetTLabel(0,Lable4,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_4,Symbol_4,ColorGain4,sFontType,FontSize);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
