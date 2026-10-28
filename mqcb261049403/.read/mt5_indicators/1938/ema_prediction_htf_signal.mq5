//+------------------------------------------------------------------+ 
//|                                    EMA_Prediction_HTF_Signal.mq5 | 
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
#define INDICATOR_NAME      "EMA_Prediction"    // Indicator name
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
//|  Indicator input parameters                    |
//+------------------------------------------------+ 
input string Symbol_="";                    // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;            // Indicator timeframe for the indicator calculation
input uint               FastMAPeriod=1;               // Fast MA period
input  ENUM_MA_METHOD    FastMAType=MODE_EMA;          // Fast MA averaging
input ENUM_APPLIED_PRICE FastMAPrice=PRICE_CLOSE;      // Fast MA price
input uint               SlowMAPeriod=2;               // Slow MA period
input  ENUM_MA_METHOD    SlowMAType=MODE_EMA;          // Slow MA averaging 
input ENUM_APPLIED_PRICE SlowMAPrice=PRICE_CLOSE;      // Slow MA price

//--- indicator display settings
input uint SignalBar=0;                                // Signal bar index, 0 is a current bar
input string Symbols_Sirname=INDICATOR_NAME"_Label_";  // Indicator labels name
input color UpSymol_Color=clrDodgerBlue;               // Growth symbol color
input color DnSymol_Color=clrMagenta;                  // Downfall symbol color
input color IndName_Color=clrDarkOrchid;               // Indicator name сolor
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
input bool Push=true;                        // Allow push notifications
input uint AlertCount=0;                     // Number of submitted alerts
//+-----------------------------------+
//--- Declaration of integer variables for indicators handles
int EMA_Prediction_Handle;
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
//|  Text label reinstallation                                       |
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
//--- Initialization of variables of the start of data calculation   
   int ATR_Period=12;
   min_rates_total=int(MathMax(MathMax(FastMAPeriod,SlowMAPeriod),ATR_Period))+1+int(SignalBar);
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
//--- getting the handle of EMA_Prediction
   EMA_Prediction_Handle=iCustom(Symb,Timeframe,"EMA_Prediction",FastMAPeriod,FastMAType,FastMAPrice,SlowMAPeriod,SlowMAType,SlowMAPrice);
   if(EMA_Prediction_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of EMA_Prediction");
      return(INIT_FAILED);
     }
//--- initializations of variable for indicator short name
   string shortname=name1;
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
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
   if(BarsCalculated(EMA_Prediction_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(EMA_Prediction_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//--- declaration of local variables
   int limit,trend;
   double UpBTR[1],DnBTR[1];
   color Color0=clrNONE;
   string SignSymbol;
   static int prev_trend;
   bool signal=false;
   static uint buycount,sellcount,prev_Bars;
//--- calculations of the necessary amount of copied data for the CopyBuffer function
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=Bars(Symb,Timeframe)-min_rates_total-1;
      prev_Bars=min_rates_total+1+SignalBar;
      buycount=0;
      sellcount=0;
      prev_trend=0;
     }
   else
     {
      if(prev_calculated==rates_total && SignalBar && (!buycount || !sellcount)) return(rates_total);
      limit=int(Bars(Symb,Timeframe)-prev_Bars+SignalBar);
     }

   trend=prev_trend;

//--- the main loop of the indicator calculation
   for(int bar=limit; bar>=int(SignalBar) && !IsStopped(); bar--)
     {
      if(CopyBuffer(EMA_Prediction_Handle,0,bar,1,DnBTR)<=0) return(prev_calculated);
      if(CopyBuffer(EMA_Prediction_Handle,1,bar,1,UpBTR)<=0) return(prev_calculated);

      if(UpBTR[0]&&UpBTR[0]!=EMPTY_VALUE) {trend=+1; if(bar==int(SignalBar)) signal=true;}
      if(DnBTR[0]&&DnBTR[0]!=EMPTY_VALUE) {trend=-1; if(bar==int(SignalBar)) signal=true;}
      if(bar || SignalBar) prev_trend=trend;
     }

   prev_Bars=Bars(Symb,Timeframe);

//--- set alerts counters to the initial position   
   if(prev_calculated!=rates_total && AlertCount && signal)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
     }
//---
   if(trend>0)
     {
      Color0=UpSymol_Color;
      if(signal)
        {
         SignSymbol=UP_SIGNAL_SYMBOL;
         if(Push && SignalBar && prev_calculated!=rates_total) SendNotification(IndName+": "+BUY_ALERT_TEXT);
         if(buycount && SignalBar)
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
         if(Push && SignalBar && prev_calculated!=rates_total) SendNotification(IndName+": "+SELL_ALERT_TEXT);

         if(sellcount && SignalBar)
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
   return(rates_total);
  }
//+------------------------------------------------------------------+
