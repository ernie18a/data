//+------------------------------------------------------------------+
//|                                                    FastFrAMA.mq5 |
//|                                  Copyright 2013, Roman Pritulyak |
//|                                                    c1664@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Roman Pritulyak"
#property link      "c1664@mail.ru"
#property version   "1.00"

#property description "FasrFrAMA"
#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_plots 1

#property indicator_type1 DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3
#property indicator_label1 "FasrFrAMA"

#include <FastFrAMA.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_JPRICE
  {
   PRICE_CLOSE_=1,         //CLOSE
   PRICE_OPEN_=2,          //OPEN
   PRICE_HIGH_=3,          //HIGH
   PRICE_LOW_=4,           //LOW
   PRICE_MEDIAN_=5,        //MEDIAN
   PRICE_TYPICAL_=6,       //TYPICAL
   PRICE_WEIGHTED_=7,      //WEIGHTED
   PRICE_SIMPL_=8,         //SIMPLE
   PRICE_QUARTER_=9,       //QUARTER
   PRICE_TRENDFOLLOW0_=10, //TRENDFOLLOW
   PRICE_TRENDFOLLOW1_=11  //HALFTRENDFOLLOW
  };

input int           Inp_period=   7;            //Period
input int           Inp_shift=    0;            //Shift
input ENUM_JPRICE   Inp_price=    PRICE_OPEN_;  //Applied price

double b_FrAMA[];

bool first;
int limit1;
CFRAMA *FRAMA;
//+------------------------------------------------------------------+    
//| FastFrAMA initialization function                                | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//Checking of input parameters
   if(Inp_period<2 || Inp_shift<0)
     {
      Print("Error: invalid inputs");
      return(INIT_FAILED);
     }

//Setting indicator buffers
   SetIndexBuffer(0,b_FrAMA,INDICATOR_DATA);

//Additional indicator settings
   first=true;
   limit1=2*Inp_period+1;
   PlotIndexSetInteger(0,PLOT_SHIFT,Inp_shift);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,limit1);
   PlotIndexSetString(0,PLOT_LABEL,"FastFrAMA");
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| FastFrAMA iteration function                                     | 
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
                const int &spread[]
                )
  {
   int i,from;
   double price;

//Creating class objects
   if(first)
     {
      FRAMA=new CFRAMA;
      first=false;
     }

//Calculating the point of the beginning of calculations
   from=prev_calculated-1;
   if(from<limit1)
      from=limit1;

//The main cycle of calculations
   for(i=from;i<rates_total;i++)
     {
      price=PriceSeries(Inp_price,i,open,low,high,close);
      if(CheckPointer(FRAMA)!=POINTER_INVALID)
         b_FrAMA[i]=FRAMA.FRAMASeries(limit1,prev_calculated,rates_total,Inp_period,price,low,high,i);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+    
//| FastFrAMA deinitialization function                              | 
//+------------------------------------------------------------------+  
void OnDeinit(const int reason)
  {
   delete FRAMA;
  }
//+------------------------------------------------------------------+
