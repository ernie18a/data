//+------------------------------------------------------------------+
//|                                              X2MA_HTF_Signal.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru |
//+------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version
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
enum APPLIED_PRICE // Type of constant
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
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input string Symbol_="";                   // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6; // Indicator timeframe for the indicator calculation
input Smooth_Method MA_Method1=MODE_SMA;   // First smoothing averaging method 
input int Length1=12;                      // First smoothing depth                    
input int Phase1=15;                       // First smoothing parameter
input Smooth_Method MA_Method2=MODE_JJMA;  // Second smoothing averaging method 
input int Length2=5; // Second smoothing depth 
input int Phase2=15;                       // Second smoothing parameter
input APPLIED_PRICE IPC=PRICE_CLOSE;       // Applied price
input int Shift=0;                         // Horizontal shift of the indicator in bars
input int PriceShift=0;                    // Vertical shift of the indicator in points
//--- indicator display settings
input string Symbols_Sirname="X2MA_Label_"; // Indicator labels name
input color UpSymbol_Color=Blue;            // Growth symbol color
input color DnSymbol_Color=Red;             // Downfall symbol color
input color IndName_Color=DarkOrchid;       // Indicator name color
input uint Symbols_Size=34;                 // Signal symbols size
input uint Font_Size=15;                    // Indicator name font size
input int X_3=120;                          // Horizontal shift of the name
input int Y_3=10;                           // Vertical shift of the name
input bool ShowIndName=true;                // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint X_=0;                            // Horizontal shift
input uint Y_=0;                            // Vertical shift
//+-----------------------------------+
//--- declaration of integer variables for the indicators handles
int X2MA_Handle;
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
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
   CXMA XMA;
//--- initialization of variables of the start of data calculation
   int min_rates_total1=XMA.GetStartBars(MA_Method1, Length1, Phase1);
   int min_rates_total2=XMA.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=min_rates_total1+min_rates_total2+4;
//--- initialization of variables
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();
//---
   X_0=X_;
   X_1=uint(X_0+Symbols_Size*1.1);
   X_2=uint(X_1+Symbols_Size*1.1);
   Yn=Y_+5;
//---
   name0=Symbols_Sirname+"0";
   name1=Symbols_Sirname+"1";
   name2=Symbols_Sirname+"2";
   if(ShowIndName)
     {
      Y_3_=Yn+Y_3;
      X_3_=X_0+X_3;
      name3=Symbols_Sirname+"3";
      StringConcatenate(IndName,"X2MA(",Symb," ",GetStringTimeframe(Timeframe),")");
     }
//--- getting handle of the X2MA indicator
   X2MA_Handle=iCustom(Symb,Timeframe,"X2MA",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,IPC,0,0);
   if(X2MA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the X2MA indicator");
      return(INIT_FAILED);
     }
//--- initialization of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
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
//| X2MA iteration function                                          | 
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
//--- Checking the number of bars to be enough for the calculation
   if(BarsCalculated(X2MA_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(X2MA_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//--- declaration of local variables
   int to_copy=4;
   double dx2ma0,dx2ma1,dx2ma2;
   double X2MA[4];
   color Color0,Color1,Color2;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(X2MA_Handle,0,0,to_copy,X2MA)<=0) return(RESET);
//---
   dx2ma0=X2MA[3]-X2MA[2];
   dx2ma1=X2MA[2]-X2MA[1];
   dx2ma2=X2MA[1]-X2MA[0];
//---
   if(dx2ma0<0) Color0=DnSymbol_Color; else Color0=UpSymbol_Color;
   if(dx2ma1<0) Color1=DnSymbol_Color; else Color1=UpSymbol_Color;
   if(dx2ma2<0) Color2=DnSymbol_Color; else Color2=UpSymbol_Color;
//---
   SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,"t",Color0,"Wingdings 2",Symbols_Size);
   SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1,Yn,"u",Color1,"Wingdings 2",Symbols_Size);
   SetTLabel(0,name2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_2,Yn,"v",Color2,"Wingdings 2",Symbols_Size);
   if(ShowIndName) SetTLabel(0,name3,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_3_,Y_3_,IndName,IndName_Color,"Georgia",Font_Size);
//---
   ChartRedraw(0);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
