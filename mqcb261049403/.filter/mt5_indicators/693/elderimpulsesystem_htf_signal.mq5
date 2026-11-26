//+------------------------------------------------------------------+ 
//|                                ElderImpulseSystem_HTF_Signal.mq5 | 
//|                               Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
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
//|  Indicator input parameters       |
//+-----------------------------------+
input string Symbol_="";                   // Financial asset
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6; // Indicator timeframe for the indicator calculation
input int ma_period=13;                    // MA period
input int fast_ema_period=12;              // MACD fast line period 
input int slow_ema_period=26;              // MACD slow line period
input int signal_period=9;                 // MACD signal line period
//--- indicator display settings
input string symbols_Sirname="ElderImpulseSystem_Label_"; // Indicator labels name
input uint  BarTotal=4;                                   // Number of displayed bars
input color Upsymbol_Color=SpringGreen;                   // Growth symbol color
input color Flsymbol_Color=Blue;                          // Flat symbol color
input color Dnsymbol_Color=Red;                           // Downfall symbol color
input color IndName_Color=DarkOrchid;                     // Indicator name color
input uint symbols_Size=34;                               // Signal symbols size
input uint Font_Size=15;                                  // Indicator name font size
input int Xn=5;                                           // Horizontal shift of the name
input int Yn=-20;                                         // Vertical shift of the name
input bool ShowIndName=true;                              // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER;    // Location corner
input uint X_=0;                                          // Horizontal shift
input uint Y_=30;                                         // Vertical shift
//+-----------------------------------+

//--- declaration of integer variables for the indicators handles
int Elder_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total,total;
//--- declaration of integer variables of the indices horizontal and vertical location
uint X1[],Y1[],X_n,Y_n;
//--- declaration of variables arrays for the indicators values storage
double Elder[];
//---
color Color1[];
//--- declaration of variables for labels names
string name1[],namen,IndName,Symb;
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
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,textTT,Color,Font,Size);
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
//| BrainTrend indicator initialization function                     | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=MathMax(ma_period,MathMax(fast_ema_period,slow_ema_period)+signal_period)+2+4;
   total=int(BarTotal);
   if(total<1) total=1;
//--- memory distribution for variables' arrays
   if(ArrayResize(X1,total)<total) Print("Failed to distribute the memory for X1[] array");
   if(ArrayResize(Y1,total)<total) Print("Failed to distribute the memory for Y1[] array");
   if(ArrayResize(name1,total)<total) Print("Failed to distribute the memory for name1[] array");
   if(ArrayResize(Elder,total)<total) Print("Failed to distribute the memory for Elder[] array");
   if(ArrayResize(Color1,total)<total) Print("Failed to distribute the memory for Color1[] array");
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Elder,true);
//--- initialization of variables
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();
//---
   int size=int(symbols_Size*1.1);
   int shift1=int(symbols_Size/6);
//---
   for(int numb=0; numb<total; numb++)
     {
      X1[numb]=uint(X_+numb*size);
      Y1[numb]=uint(Y_+5);
      name1[numb]=symbols_Sirname+"1_"+string(numb);
     }
//---
   if(ShowIndName)
     {
      X_n=X1[0]+Xn;
      Y_n=Y1[0]+Yn;
      namen=symbols_Sirname+"0";
     }
//---
   StringConcatenate(IndName,"ElderImpulseSystem(",Symb," ",GetStringTimeframe(Timeframe),")");
//--- getting handle of the ElderImpulseSystem indicator
   Elder_Handle=iCustom(Symbol_,Timeframe,"ElderImpulseSystem",ma_period,fast_ema_period,slow_ema_period,signal_period);
   if(Elder_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ElderImpulseSystem indicator");
      return(INIT_FAILED);
     }
//--- name for the data window and the label for tooltips 
   string short_name="ElderImpulseSystem";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   for(int numb=0; numb<total; numb++) if(ObjectFind(0,name1[numb])!=-1) ObjectDelete(0,name1[numb]);
   if(ObjectFind(0,namen)!=-1) ObjectDelete(0,namen);
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
//--- checking the number of bars to be enough for the calculation
   if(BarsCalculated(Elder_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(Elder_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//--- copy newly appeared data in the arrays
   if(CopyBuffer(Elder_Handle,4,0,total,Elder)<=0) return(RESET);
   for(int numb=0; numb<total; numb++)
     {
      int Eld=int(Elder[numb]);
      switch(Eld)
        {
         case 0: Color1[numb]=Flsymbol_Color; break;
         case 1: Color1[numb]=Dnsymbol_Color; break;
         case 2: Color1[numb]=Upsymbol_Color; break;
        }
      SetTLabel(0,name1[numb],0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),
                X1[numb],Y1[numb],"д",IndName,Color1[numb],"Wingdings 2",symbols_Size);
     }
   if(ShowIndName)
      SetTLabel(0,namen,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),
                X_n,Y_n,IndName,IndName,IndName_Color,"Georgia",Font_Size);
//---
   ChartRedraw(0);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
