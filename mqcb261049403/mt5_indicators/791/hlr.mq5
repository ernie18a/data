//+------------------------------------------------------------------+
//|                                                          HLR.mq4 |
//|                                      Copyright © 2007, Alexandre |
//|                      http://www.kroufr.ru/content/view/1184/124/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Alexandre"
#property link      "http://www.kroufr.ru/content/view/1184/124/"
#property description "Hi-Lo Range Oscillator"
//---- indicator version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window 
//---- indicator buffers
#property indicator_buffers 1 
//---- indicator plots used
#property indicator_plots   1
//+----------------------------------------------+
//| Indicator plot settings                      |
//+----------------------------------------------+
//---- drawing style - line
#property indicator_type1   DRAW_LINE
//---- line color - Red
#property indicator_color1 Red
//---- line style - solid line
#property indicator_style1  STYLE_SOLID
//---- line width - 1
#property indicator_width1  1
//---- line label
#property indicator_label1  "Hi-Lo Range Oscillator"
//+----------------------------------------------+
//| horizontal levels settings                   |
//+----------------------------------------------+
#property indicator_level1 80
#property indicator_level2 50
#property indicator_level3 20
#property indicator_levelcolor LimeGreen
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0 // RESET - recalculation of the indicator values
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint HLR_Range=40; // Period
input int  Shift=0;      // Horizontal shift (in bars)
//+----------------------------------------------+
//---- declaration of dynamic array, used as indicator buffer
double HLRBuffer[];
//---- declaration of integer variables
int min_rates_total;
//+------------------------------------------------------------------+   
//| HLR indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- min rates total
   min_rates_total=int(HLR_Range+1);

//---- set HLRBuffer[] as indicator buffer
   SetIndexBuffer(0,HLRBuffer,INDICATOR_DATA);
//---- set horiziontal shift (in bars)
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- set plot draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- define empty values (not shown at the chart)
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set indexing as time series
   ArraySetAsSeries(HLRBuffer,true);

//---- prepare indicator short name
   string shortname;
   StringConcatenate(shortname,"Hi-Lo Range Oscillator(",HLR_Range,", ",Shift,")");
//--- define indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- finish
  }
//+------------------------------------------------------------------+ 
//| HLR iteration function                                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // total bars in the history
                const int prev_calculated,// bars, calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking of bars
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of double variables
   double m_pr,HH,LL,HL;
//---- declatation of integer variables
   int limit,bar;

//---- calculation of starting bar index
   if(prev_calculated>rates_total || prev_calculated<=0)// checking of first call
     {
      limit=rates_total-min_rates_total-1; // starting bar index for all bars
     }
   else limit=rates_total-prev_calculated; // starting bar index for new bars

//---- set indexing as time series
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- calculation of the indicator values
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HH=high[ArrayMaximum(high,bar,HLR_Range)];
      LL=low [ArrayMinimum(low, bar,HLR_Range)];

      m_pr=(high[bar]+low[bar])/2.0;
      HL=HH-LL;
      if(HL) HLRBuffer[bar]=100.0*(m_pr-LL)/(HL);
      else HLRBuffer[bar]=0.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
