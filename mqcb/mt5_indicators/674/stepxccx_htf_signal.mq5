//+------------------------------------------------------------------+
//|                                          StepXCCX_HTF_Signal.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//| in the following directory: terminal_data_folder\MQL5\Indicators |
//| ColorStepXCCX indicator must be compiled                         |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version
#property version   "1.00"
//+----------------------------------------------+ 
//|  Indicator drawing parameters                |
//+----------------------------------------------+ 
//---- drawing the indicator in the main window
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
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input string Symbol_="";                     // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;   // Indicator timeframe for the indicator calculation
input Smooth_Method DSmoothMethod=MODE_JJMA; // Price smoothing method
input int DPeriod=30;                        // Moving average period
input int DPhase=100;                        // Smoothing parameter
input Smooth_Method MSmoothMethod=MODE_T3;   // Deviation smoothing method
input int MPeriod=7;                         // Average deviation period
input int MPhase=15;                         // Deviation smoothing parameter
input APPLIED_PRICE IPC=PRICE_TYPICAL;       // Applied price
input int StepSizeFast=5;                    // Fast step
input int StepSizeSlow=30;                   // Slow step
//---- indicator display settings
input string Symbols_Sirname="StepXCCX_";    // Indicator labels name
input int   Up1Level=+50;                    // Overbought level
input int   Dn1Level=-50;                    // Oversold level
input color Up1Symbol_Color=Lime;            // Maximum growth symbol color
input color UpSymbol_Color=Teal;             // Growth symbol color
input color DnSymbol_Color=Red;              // Downfall symbol color
input color Dn1Symbol_Color=Magenta;         // Maximum downfall symbol color
input color IndName_Color=DarkOrchid;        // Indicator name color
input uint Symbols_Size=40;                  // Signal symbols size
input uint Font_Size=12;                     // Indicator name font size
input int X_3=110;                           // Horizontal shift of the name
input int Y_3=17;                            // Vertical shift of the name
input bool ShowIndName=true;                 // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint X_=0;                             // Horizontal shift
input uint Y_=0;                             // Vertical shift
//+-----------------------------------+
//---- declaration of integer variables for the indicators handles
int StepXCCX_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables of the indices horizontal and vertical location
uint X_0,X_1,X_2,X_3_,Yn,Y_3_;
//---- declaration of variables for labels names
string name0,name1,name2,name3,IndName,Symb;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
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
//----
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
//+------------------------------------------------------------------+    
//| StepXCCX indicator initialization function                       | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
   CXMA XMA;
//---- initialization of variables of the start of data calculation
   min_rates_total=XMA.GetStartBars(DSmoothMethod,DPeriod,DPhase)
                   +XMA.GetStartBars(MSmoothMethod,MPeriod,MPhase)+3;

//---- initialization of variables
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();

   X_0=X_;
   X_1=uint(X_0+Symbols_Size*0.83);
   X_2=uint(X_1+Symbols_Size*0.83);
   Yn=Y_+5;

   name0=Symbols_Sirname+"0";
   name1=Symbols_Sirname+"1";
   name2=Symbols_Sirname+"2";
   if(ShowIndName)
     {
      Y_3_=Yn+Y_3;
      X_3_=X_0+X_3;
      name3=Symbols_Sirname+"3";
      StringConcatenate(IndName,"StepXCCX(",Symb," ",GetStringTimeframe(Timeframe),")");
     }

//---- getting handle of the StepXCCX indicator
   StepXCCX_Handle=iCustom(Symb,Timeframe,"ColorStepXCCX",DSmoothMethod,DPeriod,DPhase,
                           MSmoothMethod,MPeriod,MPhase,IPC,StepSizeFast,StepSizeSlow,0);
   if(StepXCCX_Handle==INVALID_HANDLE) Print(" Failed to get handle of the ColorStepXCCX indicator");

//---- initializations of variable for indicator short name
   string shortname,SmoothD,SmoothM;
   SmoothD=XMA.GetString_MA_Method(DSmoothMethod);
   SmoothM=XMA.GetString_MA_Method(MSmoothMethod);
   StringConcatenate(shortname,"StepXCCX(",
                     string(DPeriod),",",string(MPeriod),",",SmoothD,",",SmoothM,
                     StepSizeFast,", ",StepSizeSlow,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+
//| StepXCCX deinitialization function                               |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   if(ObjectFind(0,name0)!=-1) ObjectDelete(0,name0);
   if(ObjectFind(0,name1)!=-1) ObjectDelete(0,name1);
   if(ObjectFind(0,name2)!=-1) ObjectDelete(0,name2);
   if(ObjectFind(0,name3)!=-1) ObjectDelete(0,name3);
//----
  }
//+------------------------------------------------------------------+
//| StepXCCX deinitialization function                               |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| StepXCCX iteration function                                      | 
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(StepXCCX_Handle)<min_rates_total) return(RESET);

//---- declaration of local variables
   int to_copy=3;
   double dxccx0,dxccx1,dxccx2;
   double XCCX1[3],XCCX2[3];
   color Color0,Color1,Color2;

//--- copy newly appeared data in the arrays
   if(CopyBuffer(StepXCCX_Handle,0,0,to_copy,XCCX1)<=0) return(RESET);
   if(CopyBuffer(StepXCCX_Handle,1,0,to_copy,XCCX2)<=0) return(RESET);

   dxccx0=XCCX1[2]-XCCX2[2];
   dxccx1=XCCX1[1]-XCCX2[1];
   dxccx2=XCCX1[0]-XCCX2[0];

//---- 0 bar drawing parameters
   if(dxccx0<0)
     {
      if(XCCX1[2]<Dn1Level) Color0=Dn1Symbol_Color;
      else                  Color0=DnSymbol_Color;
     }
   else
     {
      if(XCCX1[2]>Up1Level) Color0=Up1Symbol_Color;
      else                  Color0=UpSymbol_Color;
     }

//---- 1 bar drawing parameters    
   if(dxccx1<0)
     {
      if(XCCX1[1]<Dn1Level) Color1=Dn1Symbol_Color;
      else                  Color1=DnSymbol_Color;
     }
   else
     {
      if(XCCX1[1]>Up1Level) Color1=Up1Symbol_Color;
      else                  Color1=UpSymbol_Color;
     }

//---- 2 bar drawing parameters   
   if(dxccx2<0)
     {
      if(XCCX1[0]<Dn1Level) Color2=Dn1Symbol_Color;
      else                  Color2=DnSymbol_Color;
     }
   else
     {
      if(XCCX1[0]>Up1Level) Color2=Up1Symbol_Color;
      else                  Color2=UpSymbol_Color;
     }
//----

   if(ShowIndName)
      SetTLabel(0,name3,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_3_,Y_3_,IndName,IndName_Color,"Georgia",Font_Size);
   SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,"l",Color0,"Wingdings",Symbols_Size);
   SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1,Yn,"l",Color1,"Wingdings",Symbols_Size);
   SetTLabel(0,name2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_2,Yn,"l",Color2,"Wingdings",Symbols_Size);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
