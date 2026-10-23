//+------------------------------------------------------------------+
//|                                                          MPC.mq5 | 
//|                                      Copyright © 2007, Alexandre |
//|                       http://www.kroufr.ru/content/view/885/124/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Alexandre"
#property link "http://www.kroufr.ru/content/view/885/124/"
#property description "Middle Point Channel"
//---- indicator version
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- indicator buffers
#property indicator_buffers 3 
//---- indicator plots
#property indicator_plots   3
//+--------------------------------------------+ 
//|  declaration of constants                  |
//+--------------------------------------------+
#define RESET 0  // Reset constant
//+--------------------------------------------+
//|  Indicator plot settings                   |
//+--------------------------------------------+
//---- drawing style - draw as a line
#property indicator_type1 DRAW_LINE
//---- line color - Red
#property indicator_color1 Red
//---- line style
#property indicator_style1  STYLE_SOLID
//---- line width 2
#property indicator_width1  2
//---- line label
#property indicator_label1  "Middle MPC"
//+--------------------------------------------+
//|  Channel plot settings                     |
//+--------------------------------------------+
//---- drawing style
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- channel colors
#property indicator_color2  Magenta
#property indicator_color3  Aqua
//---- line style
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- line width
#property indicator_width2  2
#property indicator_width3  2
//---- plot labels
#property indicator_label2  "Upper MPC"
#property indicator_label3  "Lower MPC"
//+-----------------------------------+
//| Indicator input parameters        |
//+-----------------------------------+
input uint MPC_Range=40; // Period
input int  Shift=0;      // Shift
//+-----------------------------------+
//---- declaration of dynamic arrays, that will be used as indicator buffers
double MDBuffer[],UpMDBuffer[],DnMDBuffer[];
//---- declaration of integer variables
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- min rates total
   min_rates_total=int(MPC_Range);

//---- set MDBuffer[] as indicator buffer
   SetIndexBuffer(0,MDBuffer,INDICATOR_DATA);
//---- set horizontal shift (in bars)
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- set plot graw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- define 0 as an empty value (these values not plotted at chart)
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- set indexing as time series
   ArraySetAsSeries(MDBuffer,true);

//---- set UpMDBuffer[] and DnMDBuffer[] as indicator buffers
   SetIndexBuffer(1,UpMDBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,DnMDBuffer,INDICATOR_DATA);
//---- set plot shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- set draw begin
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- disable plot of empty values
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- set indexing as time series
   ArraySetAsSeries(UpMDBuffer,true);
   ArraySetAsSeries(DnMDBuffer,true);

//--- define indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,"Middle Point Channel");
//--- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- finish of initialization
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // total bars in history
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

//---- declaration of local variables
   int limit;
   double HH,LL;

//---- set indexing as time series
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- calculation of starting bar index
   if(prev_calculated>rates_total || prev_calculated<=0) // checking of first start of the indicator
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- calculation of indicator values
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {      
      HH=high[ArrayMaximum(high,bar,MPC_Range)];
      LL=low [ArrayMinimum(low, bar,MPC_Range)];
      UpMDBuffer[bar]=HH;
      MDBuffer[bar]=(HH+LL)/2;
      DnMDBuffer[bar]=LL;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
