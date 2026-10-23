//+------------------------------------------------------------------+ 
//|                                           BlauCSI_HTF_Signal.mq5 | 
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- Indicator version number
#property version   "1.00"
//+------------------------------------------------+ 
//|  Indicator drawing parameters                  |
//+------------------------------------------------+ 
//--- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------+ 
//|  Declaration of constants                      |
//+------------------------------------------------+
#define INDICATOR_NAME      "BlauCSI"           // The name of the indicator
#define RESET               0                   // The constant for getting the command for the indicator recalculation back to the terminal
#define NAMES_SYMBOLS_FONT  "Georgia"           // Indicator name font
#define SIGNAL_SYMBOLS_FONT "Wingdings 3"       // Market entry symbol font
#define TREND_SYMBOLS_FONT  "Wingdings 3"       // Trend symbol font
#define UP_SIGNAL_SYMBOL    "ж"                 // Long position opening symbol
#define DN_SIGNAL_SYMBOL    "и"                 // Short position opening symbol
#define UP_TREND_SYMBOL     "в"                 // Uptrend symbol
#define DN_TREND_SYMBOL     "в"                 // Downtrend symbol
#define BUY_SOUND           "alert.wav"         // Audio file for a long position opening
#define SELL_SOUND          "alert.wav"         // Audio file for a short position opening
#define BUY_ALERT_TEXT      "Buy signal" // Alert text for a long position opening
#define SELL_ALERT_TEXT     "Sell signal" // Alert text for a short position opening
//+------------------------------------------------+ 
//| Enumeration for the level actuation indication |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE // Type of constant
  {
   OnlySound,   // only sound
   OnlyAlert    // only alert
  };
//+------------------------------------------------+ 
//|  Declaration of enumerations                   |
//+------------------------------------------------+ 
enum Applied_price_      // type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPL_,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price
  };
//+------------------------------------------------+
//|  CXMA class description                        |
//+------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------+ 
//|  Indicator input parameters                    |
//+------------------------------------------------+ 
input string Symbol_="";                    // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;            // Indicator timeframe for the indicator calculation
input Smooth_Method XMA_Method=MODE_EMA;               // Method of averaging
input uint XLength=1;                                  // Period of Momentum
input uint XLength1=20;                                // Depth of the first averaging
input uint XLength2=5;                                 // Depth of the second averaging
input uint XLength3=3;                                 // Depth of the third averaging
input int XPhase=15;                                   // Smoothing parameter
//--- XPhase: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- XPhase: for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC1=PRICE_CLOSE;                 // Price constant of closing
input Applied_price_ IPC2=PRICE_OPEN;                  // Price constant of opening
//--- indicator display settings
input uint SignalBar=0;                                // Signal bar index, 0 is a current bar
input string Symbols_Sirname=INDICATOR_NAME"_Label_";  // Indicator labels name
input color UpSymol_Color=clrSteelBlue;                // Growth symbol color
input color DnSymol_Color=clrDeepPink;                 // Fall symbol color
input color IndName_Color=clrDarkOrchid;               // Indicator name color
input uint Symbols_Size=60;                            // Signal symbols size
input uint Font_Size=10;                               // Indicator name font size
input int X_1=5;                                       // Horizontal shift of the name
input int Y_1=-15;                                     // Vertical shift of the name
input bool ShowIndName=true;                           // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint X_=0;                                       // Horizontal shift
input uint Y_=20;                                      // Vertical shift
//--- alerts settings
input ENUM_ALERT_MODE alert_mode=OnlySound;            // Triggering indication option
input uint AlertCount=0;                               // Number of produced alerts
input bool Push=true;                                  // Allow push notifications
//+-----------------------------------+
//--- Declaration of integer variables for indicators handles
int BlauCSI_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables of the indices horizontal and vertical location
uint X_0,Yn,X_1_,Y_1_;
//--- declaration of variables for labels names
string name0,name1,IndName,Symb;
//--- declaration of variables for alert text
string BuySignal,SellSignal;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+
//|  Creation of a text label                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // chart ID
                  string name,             // Object name
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
//|  Resetting the text label                                        |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // chart ID
               string name,             // Object name
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
   CXMA XMA;
//--- Initialization of variables of the start of data calculation   
   min_rates_total=int(XLength-1);
   min_rates_total+=XMA.GetStartBars(XMA_Method,XLength1,XPhase);
   min_rates_total+=XMA.GetStartBars(XMA_Method,XLength2,XPhase);
   min_rates_total=XMA.GetStartBars(XMA_Method,XLength3,XPhase)+int(SignalBar);
   if(IPC1==IPC2 && XLength==1) Print("Invalid values of price constants!");

//--- initialization of variables
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();

   X_0=X_;
   Yn=Y_+5;

   name0=Symbols_Sirname+"0";
   if(ShowIndName)
     {
      Y_1_=Yn+Y_1;
      X_1_=X_0+X_1;
      name1=Symbols_Sirname+"1";
      StringConcatenate(IndName,INDICATOR_NAME,"(",Symb," ",GetStringTimeframe(Timeframe),")");
     }

//--- getting handle of the BlauCSI indicator
   BlauCSI_Handle=iCustom(Symb,Timeframe,"BlauCSI",XMA_Method,XLength,XLength1,XLength2,XLength3,XPhase,IPC1,IPC2,0);
   if(BlauCSI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the BlauCSI indicator");
      return(INIT_FAILED);
     }
     
   BuySignal=IndName+": "+BUY_ALERT_TEXT;
   SellSignal=IndName+": "+SELL_ALERT_TEXT;

//--- Initializations of variable for indicator short name
   string shortname=name1;
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
                const int prev_calculated,// amount of history in bars at the previous tick
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
   if(BarsCalculated(BlauCSI_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(BlauCSI_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);

//--- Declaration of local variables
   int trend=0;
   double Sign[2];
   color Color0=clrNONE;
   string SignSymbol;
   bool signal=false;
   static uint buycount,sellcount;
   static bool RePush;

//--- calculations of the necessary amount of copied data for the CopyBuffer function
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      buycount=0;
      sellcount=0;
     }
   else
     {
      if(prev_calculated==rates_total && SignalBar && (!buycount || !sellcount)) return(rates_total);
     }

//--- Copy the new data into the array  
   if(CopyBuffer(BlauCSI_Handle,1,SignalBar,2,Sign)<=0) return(prev_calculated);

   if(Sign[1]>2)
     {
      trend=+1;
      if(Sign[0]<2) signal=true;
     }

   if(Sign[1]<2)
     {
      trend=-1;
      if(Sign[0]>2) signal=true;
     }

//--- set alerts counters to the initial position   
   if(prev_calculated!=rates_total && AlertCount && signal)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
     }

//--- getting buy signals
   if(trend>0)
     {
      Color0=UpSymol_Color;

      if(signal)
        {
         SignSymbol=UP_SIGNAL_SYMBOL;
         if(Push && SignalBar && prev_calculated!=rates_total) RePush=true;        
         if(RePush) if(SendNotification(BuySignal)) RePush=false;

         if(buycount && SignalBar)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(BuySignal); break;
               case OnlySound: PlaySound(BUY_SOUND); break;
              }

            buycount--;
           }
        }
      else SignSymbol=UP_TREND_SYMBOL;
     }

//--- Getting sell signals
   if(trend<0)
     {
      Color0=DnSymol_Color;

      if(signal)
        {
         SignSymbol=DN_SIGNAL_SYMBOL;
         if(Push && SignalBar && prev_calculated!=rates_total) RePush=true;        
         if(RePush) if(SendNotification(SellSignal)) RePush=false;

         if(sellcount && SignalBar)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(SellSignal); break;
               case OnlySound: PlaySound(SELL_SOUND); break;
              }

            sellcount--;
           }

        }
      else SignSymbol=DN_TREND_SYMBOL;
     }
     
//--- Show signals on the chart
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
   return(rates_total);
  }
//+------------------------------------------------------------------+
