//+------------------------------------------------------------------+ 
//|                              Heiken_Ashi_Smoothed_HTF_Signal.mq5 | 
//|                               Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
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
input string Symbol_="";                   // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6; // Timeframe for the indicator calculation
input Smooth_Method hMA_Method=MODE_JJMA;  // Smoothing method
input int hLength=30;                      // Smoothing depth                    
input int hPhase=100;                      // Smoothing parameter
//---- indicator display settings
input string Symbols_Sirname="Heiken_Ashi_Label_"; // Indicator labels names
input uint  BarTotal=4;                            // Number of displayed bars
input color UpSymbol_Color=Lime;                   // Growth symbol color
input color DnSymbol_Color=Red;                    // Downfall symbol color
input color IndName_Color=DarkOrchid;              // Indicator name color
input uint Symbols_Size=34;                        // Signal symbols size
input uint Font_Size=15;                           // Indicator name font size
input int Xn=5;                                    // Horizontal shift of the name
input int Yn=-20;                                  // Vertical shift of the name
input bool ShowIndName=true;                       // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint X_=0;                                   // Horizontal shift
input uint Y_=30;                                  // Vertical shift
//+-----------------------------------+
//---- declaration of integer variables for the indicators handles
int HeiAshi_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,total;
//---- declaration of integer variables of the indices horizontal and vertical location
uint X1[],Y1[],X_n,Y_n;
//---- declaration of variables arrays for the indicators values storage
double HeiAshi[];
//----
color Color1[];
//---- declaration of variables for labels names
string name1[],namen,IndName,Symb;
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
                  string textTT,           // tooltip text
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
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); // background object
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
               string textTT,           // tooltip text
               color  Color,            // text color
               string Font,             // text font
               int    Size)             // font size
  {
//----
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
//----
  }
//+------------------------------------------------------------------+    
//| BrainTrend indicator initialization function                     | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=GetStartBars(hMA_Method,hLength,hPhase)+2+4;
   total=int(BarTotal);
   if(total<1) total=1;

//---- memory distribution for variables' arrays
   if(ArrayResize(X1,total)<total) Print("Failed to distribute the memory for X1[] array");
   if(ArrayResize(Y1,total)<total) Print("Failed to distribute the memory for Y1[] array");
   if(ArrayResize(name1,total)<total) Print("Failed to distribute the memory for name1[] array");
   if(ArrayResize(HeiAshi,total)<total) Print("Failed to distribute the memory for HeiAshi[] array");
   if(ArrayResize(Color1,total)<total) Print("Failed to distribute the memory for Color1[] array");

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(HeiAshi,true);

//---- initialization of variables
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();

   int size=int(Symbols_Size*1.1);
   int shift1=int(Symbols_Size/6);

   for(int numb=0; numb<total; numb++)
     {
      X1[numb]=uint(X_+numb*size);
      Y1[numb]=uint(Y_+5);
      name1[numb]=Symbols_Sirname+"1_"+string(numb);
     }

   if(ShowIndName)
     {
      X_n=X1[0]+Xn;
      Y_n=Y1[0]+Yn;
      namen=Symbols_Sirname+"0";
     }

   StringConcatenate(IndName,"Heiken_Ashi(",Symb," ",GetStringTimeframe(Timeframe),")");

//---- getting handle of the Heiken_Ashi indicator
   HeiAshi_Handle=HeiAshi_Handle=iCustom(Symbol_,Timeframe,"Heiken_Ashi_Smoothed",hMA_Method,hLength,hPhase);
   if(HeiAshi_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Heiken_Ashi_Smoothed indicator");
      return(INIT_FAILED);
     }

//---- name for the data window and the label for sub-windows 
   string short_name="Heiken_Ashi";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----  
   for(int numb=0; numb<total; numb++) if(ObjectFind(0,name1[numb])!=-1) ObjectDelete(0,name1[numb]);
   if(ObjectFind(0,namen)!=-1) ObjectDelete(0,namen);
//----
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
//| BrainTrend iteration function                                    | 
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
   if(BarsCalculated(HeiAshi_Handle)<min_rates_total) return(RESET);

//--- copy newly appeared data in the arrays
   if(CopyBuffer(HeiAshi_Handle,4,0,total,HeiAshi)<=0) return(RESET);

   for(int numb=0; numb<total; numb++)
     {
      int HeiAs=int(HeiAshi[numb]);

      switch(HeiAs)
        {
         case 1: Color1[numb]=DnSymbol_Color; break;
         case 0: Color1[numb]=UpSymbol_Color; break;
        }

      SetTLabel(0,name1[numb],0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),
                X1[numb],Y1[numb],"n",IndName,Color1[numb],"Wingdings",Symbols_Size);
     }

   if(ShowIndName)
      SetTLabel(0,namen,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),
                X_n,Y_n,IndName,IndName,IndName_Color,"Georgia",Font_Size);

//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
