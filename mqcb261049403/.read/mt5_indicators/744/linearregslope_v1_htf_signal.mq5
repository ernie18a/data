//+------------------------------------------------------------------+ 
//|                                 LinearRegSlope_V1_HTF_Signal.mq5 | 
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- indicator version
#property version   "1.00"
//+------------------------------------------------+ 
//|  Indicator drawing parameters                  |
//+------------------------------------------------+ 
//--- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers 1
#property indicator_plots   1
//+------------------------------------------------+ 
//|  Declaration of constants                      |
//+------------------------------------------------+
#define INDICATOR_NAME      "LinearRegSlope_V1" // Indicator name
#define RESET               0                   // The constant for getting the command for the indicator recalculation back to the terminal
#define NAMES_SYMBOLS_FONT  "Georgia"           // Indicator name font
#define SIGNAL_SYMBOLS_FONT "Wingdings 3"       // Markey entry symbol font
#define TREND_SYMBOLS_FONT  "Wingdings 3"       // Trend symbol font
#define UP_SIGNAL_SYMBOL    "г"                 // Long position opening symbol
#define DN_SIGNAL_SYMBOL    "д"                 // Short position opening symbol
#define UP_TREND_SYMBOL     "u"                 // Uptrend symbol
#define DN_TREND_SYMBOL     "u"                 // Downtrend symbol
#define BUY_SOUND           "alert.wav"         // Audio file for a long position opening
#define SELL_SOUND          "alert.wav"         // Audio file for a short position opening
#define BUY_ALERT_TEXT      "Buy signal"        // Alert text for a long position opening
#define SELL_ALERT_TEXT     "Sell signal"       // Alert text for a short position opening
//+------------------------------------------------+
//|  CXMA class description                        |
//+------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------+ 
//| Enumeration for the level actuation indication |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE // type of constant
  {
   OnlySound,   // only sound
   OnlyAlert    // only alert
  };
//+------------------------------------------------+ 
//| Price constant enumeration                     |
//+------------------------------------------------+ 
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
//+------------------------------------------------+ 
//|  Indicator input parameters                    |
//+------------------------------------------------+ 
input string Symbol_="";                    // Financial instrument
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;  // Indicator timeframe for the indicator calculation
input Smooth_Method SlMethod=MODE_SMA;      // Smoothing method
input int SlLength=12;                      // Smoothing depth
input int SlPhase=15;                       // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;       // Price constant
input uint TriggerShift=1;                  // Bar shift for the trigger
//--- indicator display settings
input uint SignalBar=0;                                // Signal bar index, 0 is a current bar
input string Symbols_Sirname=INDICATOR_NAME"_Label_";  // Indicator labels name
input color UpSymol_Color=Blue;                        // Growth symbol color
input color DnSymol_Color=HotPink;                     // Downfall symbol color
input color IndName_Color=DarkOrchid;                  // Indicator name color
input uint Symbols_Size=60;                            // Signal symbols size
input uint Font_Size=10;                               // Indicator name font size
input int X_1=5;                                       // Horizontal shift of the name
input int Y_1=-15;                                     // Vertical shift of the name
input bool ShowIndName=true;                           // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint X_=0;                                       // Horizontal shift
input uint Y_=20;                                      // Vertical shift
//--- alerts settings
input ENUM_ALERT_MODE alert_mode=OnlySound;  // Actuation indication version
input uint AlertCount=0;                     // Number of submitted alerts
//+-----------------------------------+
//--- declaration of integer variables for the indicators handles
int LinRegSlop_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables of the indices horizontal and vertical location
uint X_0,Yn,X_1_,Y_1_;
//--- declaration of variables for labels names
string name0,name1,IndName,Symb;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+
//|  Creation of a text label                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // chart ID
                  string name,             // object name
                  int    nwin,             // window index
                  ENUM_BASE_CORNER corner, // base corner location
                  ENUM_ANCHOR_POINT point, // anchor point location
                  int    X,                // the distance from the base corner along the X-axis in pixels
                  int    Y,                // the distance from the base corner along the Y-axis in pixels
                  string text,             // text
                  string textTT,           // tooltip text
                  color  Color,            // text color
                  string Font,             // text font
                  int    Size)             // font size
  {
//---
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); // background object
//---
  }
//+------------------------------------------------------------------+
//|  Text label reinstallation                                       |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // chart ID
               string name,             // object name
               int    nwin,             // window index
               ENUM_BASE_CORNER corner, // base corner location
               ENUM_ANCHOR_POINT point, // anchor point location
               int    X,                // the distance from the base corner along the X-axis in pixels
               int    Y,                // the distance from the base corner along the Y-axis in pixels
               string text,             // text
               string textTT,           // tooltip text
               color  Color,            // text color
               string Font,             // text font
               int    Size)             // font size
  {
//---
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,textTT,Color,Font,Size);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//---
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
   CXMA XMA1;
//--- initialization of variables of the start of data calculation
   min_rates_total=XMA1.GetStartBars(SlMethod,SlLength,SlPhase);
//--- initialization of variables
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();
//---
   X_0=X_;
   Yn=Y_+5;
//---
   name0=Symbols_Sirname+"0";
   if(ShowIndName)
     {
      Y_1_=Yn+Y_1;
      X_1_=X_0+X_1;
      name1=Symbols_Sirname+"1";
      StringConcatenate(IndName,INDICATOR_NAME,"(",Symb," ",GetStringTimeframe(Timeframe),")");
     }
//--- getting handle of the LinearRegSlope_V1 indicator
   LinRegSlop_Handle=iCustom(Symb,Timeframe,"LinearRegSlope_V1",SlMethod,SlLength,SlPhase,IPC,0,TriggerShift);
   if(LinRegSlop_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the LinearRegSlope_V1 indicator");
      return(INIT_FAILED);
     }
//--- initializations of variable for indicator short name
   string shortname="";
   StringConcatenate(shortname,INDICATOR_NAME,"(",Symb," ",GetStringTimeframe(Timeframe),")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//---
   if(ObjectFind(0,name0)!=-1) ObjectDelete(0,name0);
   if(ObjectFind(0,name1)!=-1) ObjectDelete(0,name1);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---
   Deinit();
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for the calculation
   if(BarsCalculated(LinRegSlop_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(LinRegSlop_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//--- declaration of local variables
   int limit,trend;
   double SIGN[],SLOP[];
   datetime rates_time,TIME[1];
   color Color0=clrNONE;
   string SignSymbol;
   static datetime prev_time;
   static int trend_;
   bool signal=false;
   static uint buycount=0,sellcount=0;
//--- copy newly appeared data in the arrays
   if(CopyTime(Symb,Timeframe,SignalBar,1,TIME)<=0) return(RESET);
//--- calculations of the necessary amount of copied data for the CopyBuffer function
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      prev_time=time[0];
      trend_=0;
     }
   rates_time=TimeCurrent();
//--- copy newly appeared data in the arrays
   if(CopyBuffer(LinRegSlop_Handle,0,rates_time,prev_time,SLOP)<=0) return(RESET);
   if(CopyBuffer(LinRegSlop_Handle,1,rates_time,prev_time,SIGN)<=0) return(RESET);
//--- calculations of the 'limit' starting index for the bars recalculation loop  
   limit=ArraySize(SIGN)-1;
   trend=trend_;
//--- indexing elements in arrays as time series  
   ArraySetAsSeries(SLOP,true);
   ArraySetAsSeries(SIGN,true);
//--- set alerts counters to the initial position   
   if(TIME[0]!=prev_time && AlertCount)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
     }
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(SLOP[bar]>SIGN[bar]) {trend=+1; if(bar==int(SignalBar)&&trend_<0) signal=true;}
      if(SLOP[bar]<SIGN[bar]) {trend=-1; if(bar==int(SignalBar)&&trend_>0) signal=true;}
      if(bar || SignalBar) trend_=trend;
     }
//---
   if(trend>0)
     {
      Color0=UpSymol_Color;
      if(signal)
        {
         SignSymbol=UP_SIGNAL_SYMBOL;
         if(buycount)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(IndName+": "+BUY_ALERT_TEXT); break;
               case OnlySound: PlaySound(BUY_SOUND); break;
              }
            buycount--;
           }
        }
      else SignSymbol=UP_TREND_SYMBOL;
     }
//---
   if(trend<0)
     {
      Color0=DnSymol_Color;
      if(signal)
        {
         SignSymbol=DN_SIGNAL_SYMBOL;
         if(sellcount)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(IndName+": "+SELL_ALERT_TEXT); break;
               case OnlySound: PlaySound(SELL_SOUND); break;
              }
            sellcount--;
           }
        }
      else SignSymbol=DN_TREND_SYMBOL;
     }
//---
   if(trend)
     {
      if(ShowIndName)
         SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1_,Y_1_,IndName,IndName,IndName_Color,NAMES_SYMBOLS_FONT,Font_Size);
      if(signal) SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,SIGNAL_SYMBOLS_FONT,Symbols_Size);
      else SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,TREND_SYMBOLS_FONT,Symbols_Size);
     }
   else Deinit();
//---
   ChartRedraw(0);
   prev_time=TIME[0];
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
