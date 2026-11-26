//+------------------------------------------------------------------+ 
//|                                             XMACD_HTF_Signal.mq5 | 
//|                               Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- indicator version
#property version   "1.00"
//+----------------------------------------------+ 
//|  Indicator drawing parameters                |
//+----------------------------------------------+ 
//--- drawing the indicator in the main window
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+    
//|  Smoothings classes description   |
//+-----------------------------------+    
#include <SmoothAlgorithms.mqh>
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum APPLIED_PRICE       // Type of constant
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
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input string Symbol_="";                        // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;      // Indicator timeframe for the indicator calculation
input Smooth_Method XMA_Method=MODE_T3;         // Histogram smoothing method
input int Fast_XMA = 12;                        // Fast moving average period
input int Slow_XMA = 26;                        // Slow moving average period
input int XPhase= 100;                          // Smoothing parameter 
input Smooth_Method Signal_Method=MODE_JJMA;    // Signal line smoothing method
input int Signal_XMA=9;                         // Signal line period 
input int Signal_XPhase=100;                    // Signal line parameter
input APPLIED_PRICE AppliedPrice=PRICE_CLOSE_;  // Price constant
//--- indicator display settings
input string symbols_Sirname="XMACD_Label_";    // Indicator labels name
input color Upsymbol_Color=Lime;                // Growth symbol color
input color Dnsymbol_Color=Red;                 // Downfall symbol color
input color IndName_Color=DarkOrchid;           // Indicator name color
input uint symbols_Size=34;                     // Signal symbols size
input uint Font_Size=15;                        // Indicator name font size
input int X_3=120;                              // Horizontal shift of the name
input int Y_3=10;                               // Vertical shift of the name
input bool ShowIndName=true;                    // Indicator name display
input ENUM_BASE_CORNER WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint X_=0;                                // Horizontal shift
input uint Y_=0;                                // Vertical shift
//+-----------------------------------+
//--- declaration of integer variables for the indicators handles
int XMACD_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables of the indices horizontal and vertical location
uint X_0,X_1,X_2,X_3_,Yn,Y_3_;
//--- declaration of variables for labels names
string name0,name1,name2,name3,IndName,Symb;
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
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
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
               color  Color,            // text color
               string Font,             // text font
               int    Size)             // font size
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
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
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
   CXMA XMA;
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=MathMax(Fast_XMA,XMA.GetStartBars(XMA_Method,Slow_XMA,XPhase))
                   +XMA.GetStartBars(Signal_Method,Signal_XMA,Signal_XPhase)+3;
//--- initialization of variables
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();

   X_0=X_;
   X_1=uint(X_0+symbols_Size*1.1);
   X_2=uint(X_1+symbols_Size*1.1);
   Yn=Y_+5;

   name0=symbols_Sirname+"0";
   name1=symbols_Sirname+"1";
   name2=symbols_Sirname+"2";
   if(ShowIndName)
     {
      Y_3_=Yn+Y_3;
      X_3_=X_0+X_3;
      name3=symbols_Sirname+"3";
      StringConcatenate(IndName,"XMACD(",Symb," ",GetStringTimeframe(Timeframe),")");
     }
//--- getting handle of XMACD indicator
   XMACD_Handle=iCustom(Symb,Timeframe,"XMACD",XMA_Method,Fast_XMA,Slow_XMA,XPhase,Signal_Method,Signal_XMA,Signal_XPhase,AppliedPrice);
   if(XMACD_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of XMACD indicator");
      return(INIT_FAILED);
     }
//--- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,
                     "XMACD( ",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
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
   if(ObjectFind(0,name2)!=-1) ObjectDelete(0,name2);
   if(ObjectFind(0,name3)!=-1) ObjectDelete(0,name3);
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
//| XMACD iteration function                                         | 
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
   if(BarsCalculated(XMACD_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(XMACD_Handle)<Bars(Symbol(),Timeframe)) return(prev_calculated);
//--- declaration of local variables
   int to_copy=3;
   double dxmacd0,dxmacd1,dxmacd2;
   double XMACD[3],SIGN[3];
   color Color0,Color1,Color2;

//--- copy newly appeared data in the arrays
   if(CopyBuffer(XMACD_Handle,0,0,to_copy,XMACD)<=0) return(RESET);
   if(CopyBuffer(XMACD_Handle,1,0,to_copy, SIGN)<=0) return(RESET);

   dxmacd0=XMACD[2]-SIGN[2];
   dxmacd1=XMACD[1]-SIGN[1];
   dxmacd2=XMACD[0]-SIGN[0];

   if(dxmacd0<0) Color0=Dnsymbol_Color; else Color0=Upsymbol_Color;
   if(dxmacd1<0) Color1=Dnsymbol_Color; else Color1=Upsymbol_Color;
   if(dxmacd2<0) Color2=Dnsymbol_Color; else Color2=Upsymbol_Color;

   if(ShowIndName)
      SetTLabel(0,name3,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_3_,Y_3_,IndName,IndName_Color,"Georgia",Font_Size);
   SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,"t",Color0,"Wingdings 2",symbols_Size);
   SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1,Yn,"u",Color1,"Wingdings 2",symbols_Size);
   SetTLabel(0,name2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_2,Yn,"v",Color2,"Wingdings 2",symbols_Size);
//---
   ChartRedraw(0);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
