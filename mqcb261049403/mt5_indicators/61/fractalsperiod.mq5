//+------------------------------------------------------------------+
//|                                               FractalsPeriod.mq5 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Alexander Piechotta"
#property link      "setchar@googlemail.com"
#property version   "2.00"
#property description "FractalsPeriod - Anzahl der Bars vor und nach"
#property description "dem aktuellen Hoch/Tief(ermittelt Fraktal)"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//---- plot Fractal Up
#property indicator_label1  "Fractal Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  Yellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//---- plot Fractal Down
#property indicator_label2  "Fractal Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- indicator buffers
double  upper_fr[];
double  lower_fr[];

//--- 10 pixels upper from high price
int    ExtArrowShift=-10;

//--- input parameters
input bool CompleteBarsOnly=true;
input int  FractalsPeriodBefore=2;
input int  FractalsPeriodAfter=5;
input int  MaxBars=100;

//
#include <CalcFrac.mqh>

CalcFrac Higher,Lower;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {

//--- indicator buffers mapping
   SetIndexBuffer(0,upper_fr,INDICATOR_DATA);
   SetIndexBuffer(1,lower_fr,INDICATOR_DATA);

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//---- arrow shifts when drawing   
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

   Lower.before_period =FractalsPeriodBefore;
   Lower.after_period  =FractalsPeriodAfter;
   Higher.before_period=FractalsPeriodBefore;
   Higher.after_period =FractalsPeriodAfter;
//---- initialization done

  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
 
   int Limit;

   if(rates_total<5) return(0);
     
   if(CopyLow(NULL,NULL,0,rates_total,Lower.values)<=0)
     {
      Print("Getting Low data is failed! Error",GetLastError());
      return(0);
     }

   if(CopyHigh(NULL,NULL,0,rates_total,Higher.values)<=0)
     {
      Print("Getting High data is failed! Error",GetLastError());
      return(0);
     }

   Limit=(int)MathAbs(fmin(rates_total,MaxBars)-rates_total);
   if(prev_calculated<5)
     {
      //buffers cleanup 
      ArrayInitialize(upper_fr,0.0);
      ArrayInitialize(lower_fr,0.0);
     }

   for(int i=Limit+FractalsPeriodBefore;i<rates_total-FractalsPeriodAfter-CompleteBarsOnly;i++)
     {
      //Fractals calculated and show 
      if(Higher.is_upper_fr(i)) upper_fr[i]=high[i]; else upper_fr[i]=0.;
      if(Lower.is_lower_fr(i)) lower_fr[i]=low[i]; else lower_fr[i]=0.;
     }

//--- OnCalculate done. Return new prev_calculated. 
   return(rates_total);
  }

//+------------------------------------------------------------------+
