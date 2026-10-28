//+------------------------------------------------------------------+
//|                              ID Compare HH LL and delta base.mq5 |
//|                                                      Dina Paches |
//|                                    https://dipaches.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Dina Paches"
#property link      "https://dipaches.blogspot.com"
#property version   "1.098"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//---
#property indicator_label1  "High High delta"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkSlateGray,clrLightGreen,clrDeepPink,clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//---
#property indicator_label2  "Low Low delta"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrLightGreen,clrDarkSlateGray,clrGold,clrDeepPink
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5
//---
#define BAR_FIRST                          (1)
#define BARS_DELTA                         (2)
#define DELTA_BASE                         (5)
#define INDICATOR_SHORT_NAME(d,b)          "ID Compare HH LL (delta base = "+IntegerToString(d)+\
                                            " points; bars = "+IntegerToString(b)+")"
//--- 
input uint i_delta_base = DELTA_BASE;
input uint i_bars       = 1000;
//---
double          gp_delta_base,buff_0[],buff_0_clr[],buff_1[],buff_1_clr[];
int             gp_bars,gp_digits;
string          gp_symbol;
ENUM_TIMEFRAMES gp_period;
//+------------------------------------------------------------------+
int OnInit()
  {
   gp_bars       = (i_bars<BAR_FIRST) ? BAR_FIRST :(int)i_bars;
   gp_symbol     = Symbol();
   gp_period     = Period();
   gp_digits     = Digits();
   gp_delta_base = i_delta_base*Point();
//---
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_SHORT_NAME(i_delta_base,gp_bars));
//---
   IndicatorSetInteger(INDICATOR_DIGITS,gp_digits);
//---
   SetIndexBuffer(0,buff_0,INDICATOR_DATA);
   SetIndexBuffer(1,buff_0_clr,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,buff_1,INDICATOR_DATA);
   SetIndexBuffer(3,buff_1_clr,INDICATOR_COLOR_INDEX);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
   BuffSetAsSerios();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason){}
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   static int  sp_limit    = 0;
   static bool sp_continue = false;
//---
   if(prev_calculated==0)
     {
      sp_limit=(MathMin(rates_total-BARS_DELTA,gp_bars+BARS_DELTA))-BAR_FIRST;
      //---
      if(sp_limit<BAR_FIRST+BARS_DELTA){return(0);}
      //---
      BuffInitializeAndSetAsSerios();
      //---
      sp_continue=true;
     }
   else if(rates_total-prev_calculated==1)
     {
      sp_limit=BAR_FIRST+BARS_DELTA;
      //---
      sp_continue=true;
     }
//---
   if(sp_continue)
     {
      sp_continue=ActionsHighHigh(sp_limit);
      //---
      if(!sp_continue){return(0);}
      //---
      sp_continue=ActionsLowLow(sp_limit);
      //---
      if(!sp_continue){return(0);}
      //---
      buff_0[0]=EMPTY_VALUE;
      buff_1[0]=EMPTY_VALUE;
      //---
      sp_continue=false;
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
void  BuffSetAsSerios()
  {
   ArraySetAsSeries(buff_0,true);
   ArraySetAsSeries(buff_0_clr,true);
   ArraySetAsSeries(buff_1,true);
   ArraySetAsSeries(buff_1_clr,true);
//---
   return;
  }
//+------------------------------------------------------------------+
void BuffInitializeAndSetAsSerios()
  {
   ArrayInitialize(buff_0,EMPTY_VALUE);
   ArrayInitialize(buff_1,EMPTY_VALUE);
//---
   BuffSetAsSerios();
  }
//+------------------------------------------------------------------+                                                             |
bool ActionsHighHigh(int limit)
  {
   static double high_arr[];
   ArrayResizeAndSetAsSeries(high_arr,limit,true);
//---
   if(!CopyHighArr(limit,high_arr)){return(false);}
//---
   double delta=0;
//---
   for(int i=BAR_FIRST;i<limit-BAR_FIRST;i++)
     {
      delta=high_arr[i]-high_arr[i+1];
      //---
      ActionsHighDeltaAndDeltaBase(delta,i);
     }
//---
   ArrayFree(high_arr);
//---
   return(true);
  }
//+------------------------------------------------------------------+                                                             |
bool ActionsLowLow(int limit)
  {
   static double low_arr[];
   ArrayResizeAndSetAsSeries(low_arr,limit,true);
//---
   if(!CopyLowArr(limit,low_arr)){return(false);}
//---
   double delta=0;
//---
   for(int i=BAR_FIRST;i<limit-BAR_FIRST;i++)
     {
      delta=low_arr[i]-low_arr[i+1];
      //---
      ActionsLowDeltaAndDeltaBase(delta,i);
     }
//---
   ArrayFree(low_arr);
//---
   return(true);
  }
//+------------------------------------------------------------------+
void ArrayResizeAndSetAsSeries(double     &array[],
                               const int  new_size,
                               const bool flag)
  {
   ArrayResize(array,new_size,new_size);
   ArraySetAsSeries(array,flag);
  }
//+------------------------------------------------------------------+
bool CopyHighArr(const int size,double &array[])
  {
   int copied=CopyHigh(gp_symbol,gp_period,0,size,array);
//---
   if(copied<size){Print("Error CopyHigh");return(false);}
//---
   return(true);
  }
//+------------------------------------------------------------------+
bool CopyLowArr(const int size,double &array[])
  {
   int copied=CopyLow(gp_symbol,gp_period,0,size,array);
//---
   if(copied<size){Print("Error CopyLow");return(false);}
//---
   return(true);
  }
//+------------------------------------------------------------------+
void  ActionsHighDeltaAndDeltaBase(double delta,int index,int clr_index=0)
  {
   if(delta<0){delta*=-1; clr_index=1;}
//---
   if(NormalizeDouble(delta-gp_delta_base,gp_digits)<0) {clr_index=(clr_index==0) ? 2 : 3;}
//---    
   buff_0[index]     = delta;
   buff_0_clr[index] = clr_index;
  }
//+------------------------------------------------------------------+
void  ActionsLowDeltaAndDeltaBase(double delta,int index,int clr_index=0)
  {
   if(delta>0){delta*=-1;clr_index=1;}
//---
   if(NormalizeDouble(delta+gp_delta_base,gp_digits)>0){clr_index=(clr_index==0) ? 2 : 3;}
//---    
   buff_1[index]     = delta;
   buff_1_clr[index] = clr_index;
  }
//+------------------------------------------------------------------+