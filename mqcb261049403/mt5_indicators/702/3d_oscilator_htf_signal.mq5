//+------------------------------------------------------------------+ 
//|                                     3D_Oscillator_HTF_Signal.mq5 | 
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
#property indicator_buffers    1
#property indicator_plots      1
//+------------------------------------------------+ 
//|  Declaration of constants                      |
//+------------------------------------------------+ 
#define INDICATOR_NAME      "3D_Oscillator"     // Indicator name
#define RESET  0                                // the constant for getting the command for the indicator recalculation back to the terminal
#define NAMES_SYMBOLS_FONT  "Georgia"           // Indicator name font
#define SIGNAL_SYMBOLS_FONT "Georgia"           // Market entry symbol font
#define TREND_SYMBOLS_FONT  "Georgia"           // Trend symbol font
#define UP_SIGNAL_SYMBOL    "Buy 3D"            // Long position opening symbol
#define DN_SIGNAL_SYMBOL    "Sell 3D"           // Short position opening symbol
#define UP_TREND_SYMBOL     "3D"                // Uptrend symbol
#define DN_TREND_SYMBOL     "3D"                // Downtrend symbol
#define BUY_SOUND           "alert.wav"         // Audio file for a long position opening
#define SELL_SOUND          "alert.wav"         // Audio file for a short position opening
#define BUY_ALERT_TEXT      "Buy signal"        // Alert text for a long position opening
#define SELL_ALERT_TEXT     "Sell signal"       // Alert text for a short position opening
//+------------------------------------------------+ 
//| Enumeration for the level actuation indication |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE // type of constant
  {
   OnlySound,   // only sound
   OnlyAlert    // only alert
  };
//+------------------------------------------------+ 
//|  Indicator input parameters                    |
//+------------------------------------------------+ 
input string Symbol_="";                      // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;    // Timeframe for the indicator calculation
input int D1RSIPer=13;
input int D2StochPer=8;
input int D3tunnelPer=8;
input double hot=0.4;
input int sigsmooth=4;
//--- indicator display settings
input uint SignalBar=0;                                // Signal bar index, 0 is a current bar
input string Symbols_Sirname=INDICATOR_NAME"_Label_";  // Indicator labels name
input color BuySymbol_Color=Lime;                      // Growth symbol color
input color UpSymbol_Color=Green;                      // Growth symbol color
input color DnSymbol_Color=Red;                        // Downfall symbol color
input color SellSymbol_Color=Magenta;                  // Downfall symbol color
input color IndName_Color=DarkOrchid;                  // Indicator name color
input uint Symbols_Size=40;                            // Signal symbols size
input uint Font_Size=10;                               // Indicator name font size
input int X_1=5;                                       // Horizontal shift of the name
input int Y_1=-15;                                     // Vertical shift of the name
input bool ShowIndName=true;                           // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint X_=0;                                       // Horizontal shift
input uint Y_=20;                                      // Vertical shift
//--- alerts settings
input ENUM_ALERT_MODE alert_mode=OnlySound; // Actuation indication version
input uint AlertCount=0;                    // Number of submitted alerts
//+-----------------------------------+
//--- declaration of integer variables for the indicators handles
int Oscill_Handle;
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
      ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
     }
//---
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(D1RSIPer+D2StochPer+D2StochPer+hot+sigsmooth+1+SignalBar);
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
//--- getting handle of the 3D_Oscilator indicator
   Oscill_Handle=iCustom(Symb,Timeframe,"3D_Oscilator",D1RSIPer,D2StochPer,D3tunnelPer,hot,sigsmooth);
   if(Oscill_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the 3D_Oscilator indicator");
      return(INIT_FAILED);
     }
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,
                     "( ",D1RSIPer,",",D2StochPer,",",D3tunnelPer,",",hot,",",sigsmooth," )");
//--- creating a name for displaying in a separate sub-window and in a tooltip
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
   if(BarsCalculated(Oscill_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(Oscill_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//--- declaration of local variables
   int limit,trend;
   double Up3D[],Dn3D[];
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
   if(CopyBuffer(Oscill_Handle,2,rates_time,prev_time,Dn3D)<=0) return(RESET);
   if(CopyBuffer(Oscill_Handle,3,rates_time,prev_time,Up3D)<=0) return(RESET);
//--- calculations of the 'limit' starting index for the bars recalculation loop  
   limit=ArraySize(Up3D)-1;
   trend=trend_;
//--- indexing elements in arrays as time series  
   ArraySetAsSeries(Dn3D,true);
   ArraySetAsSeries(Up3D,true);
//--- set alerts counters to the initial position   
   if(TIME[0]!=prev_time && AlertCount)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
     }
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Up3D[bar]&&Up3D[bar]!=EMPTY_VALUE) {trend=+1; if(!bar) signal=true;}
      if(Dn3D[bar]&&Dn3D[bar]!=EMPTY_VALUE) {trend=-1; if(!bar) signal=true;}
      if(bar || SignalBar) trend_=trend;
     }
//---
   if(trend>0)
     {
      if(signal)
        {
         Color0=BuySymbol_Color;
         SignSymbol=UP_SIGNAL_SYMBOL;
         if(buycount>0)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(IndName+": "+BUY_ALERT_TEXT); break;
               case OnlySound: PlaySound(BUY_SOUND); break;
              }
            buycount--;
           }
        }
      else
        {
         SignSymbol=UP_TREND_SYMBOL;
         Color0=UpSymbol_Color;
        }
     }
//---
   if(trend<0)
     {
      if(signal)
        {
         Color0=SellSymbol_Color;
         SignSymbol=DN_SIGNAL_SYMBOL;
         if(sellcount>0)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(IndName+": "+SELL_ALERT_TEXT); break;
               case OnlySound: PlaySound(SELL_SOUND); break;
              }
            sellcount--;
           }
        }
      else
        {
         SignSymbol=DN_TREND_SYMBOL;
         Color0=DnSymbol_Color;
        }
     }
//---
   if(trend)
     {
      if(ShowIndName)
         SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1_,Y_1_,IndName,IndName,IndName_Color,NAMES_SYMBOLS_FONT,Font_Size);
      if(signal)SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,SIGNAL_SYMBOLS_FONT,Symbols_Size);
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
