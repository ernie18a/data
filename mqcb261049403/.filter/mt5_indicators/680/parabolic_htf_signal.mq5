//+------------------------------------------------------------------+ 
//|                                         Parabolic_HTF_Signal.mq5 | 
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
#property indicator_buffers  1
#property indicator_plots    1
//+------------------------------------------------+
//|  Declaration of constants                      |
//+------------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
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
input string Symbol_="";                         // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;       // Indicator calculation timeframe
input double Step=0.02;                          // Step
input double Maximum=0.2;                        // Maximum
//--- indicator display settings
input uint SignalBar=0;                          // Signal bar index, 0 is a current bar
input string Symbols_Sirname="Parabolic_Label_"; // Indicator labels names
input color Up1Symbol_Color=BlueViolet;          // Symbol color for long
input color UpSymbol_Color=MediumBlue;           // Growth symbol color
input color DnSymbol_Color=Red;                  // Downfall symbol color
input color Dn1Symbol_Color=DeepPink;            // Symbol color for short
input color IndName_Color=DarkOrchid;            // Indicator name color
input uint Symbols_Size=60;                      // Signal symbols size
input uint Font_Size=10;                         // Indicator name font size
input int X_1=5;                                 // Horizontal shift of the name
input int Y_1=-15;                               // Vertical shift of the name
input bool ShowIndName=true;                     // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint X_=0;                                 // Horizontal shift
input uint Y_=20;                                // Vertical shift
//--- alerts settings
input ENUM_ALERT_MODE alert_mode=OnlySound;      // Actuation indication version
input uint AlertCount=0;                         // Number of submitted alerts
//+-----------------------------------+
//--- declaration of integer variables for the indicators handles
int Parabolic_Handle;
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
//--- initialization of variables of the start of data calculation
   min_rates_total=10+int(SignalBar);
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
      StringConcatenate(IndName,"Parabolic(",Symb," ",GetStringTimeframe(Timeframe),")");
     }
//--- getting handle of the Parabolic indicator
   Parabolic_Handle=iCustom(Symb,Timeframe,"Color_Parabolic",Step,Maximum);
   if(Parabolic_Handle==INVALID_HANDLE) 
     {
      Print(" Failed to get handle of the Parabolic indicator");
      return(INIT_FAILED);
     }
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Parabolic");
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
   return(INIT_FAILED);
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
   if(BarsCalculated(Parabolic_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(Parabolic_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//---
   int limit=rates_total-prev_calculated;
   if(limit<int(SignalBar) && limit>=0) return(rates_total);
//--- declaration of local variables
   double UpSar[1],DnSar[1],BuySar[1],SellSar[1];
   static datetime TIME[1];
   color Color0=clrNONE;
   string SignSymbol;
   static datetime bartime=0;
   static uint buycount=0,sellcount=0;
//--- copy newly appeared data in the array 
   if(CopyBuffer(Parabolic_Handle,0,SignalBar,1,DnSar)<=0) return(RESET);
   if(CopyBuffer(Parabolic_Handle,1,SignalBar,1,UpSar)<=0) return(RESET);
   if(CopyBuffer(Parabolic_Handle,2,SignalBar,1,SellSar)<=0) return(RESET);
   if(CopyBuffer(Parabolic_Handle,3,SignalBar,1,BuySar)<=0) return(RESET);
   if(CopyTime(Symb,Timeframe,SignalBar,1,TIME)<=0) return(RESET);
//--- set alerts counters to the initial position   
   if(TIME[0]!=bartime && AlertCount)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
      bartime=TIME[0];
     }
//---
   if(BuySar[0])
     {
      Color0=Up1Symbol_Color;
      SignSymbol="й";
      if(buycount)
        {
         if(alert_mode==OnlyAlert) Alert(IndName+": Signal for buying");
         if(alert_mode==OnlySound) PlaySound("alert.wav");
         buycount--;
        }
     }
//---
   if(SellSar[0])
     {
      Color0=Dn1Symbol_Color;
      SignSymbol="к";
      if(sellcount)
        {
         if(alert_mode==OnlyAlert) Alert(IndName+": Signal for selling");
         if(alert_mode==OnlySound) PlaySound("alert.wav");
         sellcount--;
        }
     }
//---
   if(!BuySar[0] && !SellSar[0])
     {
      if(UpSar[0])
        {
         Color0=UpSymbol_Color;
         SignSymbol="l";
        }
      if(DnSar[0])
        {
         Color0=DnSymbol_Color;
         SignSymbol="l";
        }
     }
//--- creation of trend symbols or deals signals
   if(ShowIndName)
      SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1_,Y_1_,IndName,IndName,IndName_Color,"Georgia",Font_Size);
   SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,"Wingdings",Symbols_Size);
//---
   ChartRedraw(0);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
