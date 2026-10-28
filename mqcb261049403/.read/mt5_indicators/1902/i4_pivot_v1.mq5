//+------------------------------------------------------------------+
//|                                                  i4_pivot_v1.mq5 |
//|                             Copyright c 2005, goldenlion@ukr.net |
//|                                      http://GlobeInvestFund.com/ |
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright c 2005, goldenlion@ukr.net"
//---- link to the website of the author
#property link      "http://GlobeInvestFund.com/"
//---- Indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----seven buffers are used for calculation of drawing of the indicator
#property indicator_buffers 7
//---- seven plots are used
#property indicator_plots   7
//+----------------------------------------------+
//|  R30 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type1   DRAW_ARROW
//---- use the following color for the indicator line
#property indicator_color1 clrMediumSeaGreen
//---- the indicator line width
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Pivot R3.0"
//+----------------------------------------------+
//|  R20 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type2   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color2 clrLime
//---- the indicator line width
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Pivot R2.0"
//+----------------------------------------------+
//|  R10 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_ARROW
//---- medium sea green color is used for the indicator
#property indicator_color3 clrMediumSeaGreen
//---- the indicator width
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Pivot R1.0"
//+----------------------------------------------+
//|  P level drawing parameters                  |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type4   DRAW_ARROW
//---- use the following color for the indicator line
#property indicator_color4 clrBlue
//---- the indicator line width
#property indicator_width4  2
//---- displaying the indicator label
#property indicator_label4  "Pivot P"
//+----------------------------------------------+
//|  S10 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type5   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color5 clrRed
//---- the indicator line width
#property indicator_width5  1
//---- displaying the indicator label
#property indicator_label5  "Pivot S1.0"
//+----------------------------------------------+
//|  S20 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type6   DRAW_ARROW
//---- magenta color is used for the indicator
#property indicator_color6 clrMagenta
//---- the indicator width
#property indicator_width6  1
//---- displaying the indicator label
#property indicator_label6  "Pivot S2.0"
//+----------------------------------------------+
//|  S30 level drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type7   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color7 clrRed
//---- the indicator width
#property indicator_width7  1
//---- displaying the indicator label
#property indicator_label7  "Pivot S3.0"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int  Symbol_R30 = 119;        //R30 level symbol
input int  Symbol_R20 = 167;        //R20 level symbol
input int  Symbol_R10 = 108;        //R10 level symbol
input int  Symbol_P   = 119;        //P level symbol
input int  Symbol_S10 = 108;        //S10 level symbol
input int  Symbol_S20 = 167;        //S20 level symbol
input int  Symbol_S30 = 119;        //S30 level symbol
//+----------------------------------------------+
//---- declaration of dynamic arrays that further
//---- will be used as indicator buffers
double P_Buffer[];
double R10_Buffer[],R20_Buffer[],R30_Buffer[];
double S10_Buffer[],S20_Buffer[],S30_Buffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=3;
   int draw_begin=min_rates_total;
//---- Setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,R30_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,R20_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,R10_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,P_Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,S10_Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,S20_Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,S30_Buffer,INDICATOR_DATA);
//---- символы для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,Symbol_R30);
   PlotIndexSetInteger(1,PLOT_ARROW,Symbol_R20);
   PlotIndexSetInteger(2,PLOT_ARROW,Symbol_R10);
   PlotIndexSetInteger(3,PLOT_ARROW,Symbol_P);
   PlotIndexSetInteger(4,PLOT_ARROW,Symbol_S10);
   PlotIndexSetInteger(5,PLOT_ARROW,Symbol_S20);
   PlotIndexSetInteger(6,PLOT_ARROW,Symbol_S30);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
//---- Set accuracy of displaying for the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- Creating labels for displaying in DataWindow and the name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"i4_pivot_v1");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- 
   if(_Period>=PERIOD_D1 && rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int    bar,first;
   static double P,R1,R2,R3,S1,S2,S3;
   static double yesterday_high1,yesterday_low1;
   double yesterday_high,yesterday_low,yesterday_close;
   
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=min_rates_total;     // starting index for calculation of all bars
      yesterday_high1=0;
      yesterday_low1=999999999;

     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- The main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {

      yesterday_high1=MathMax(yesterday_high1,high[bar]);
      yesterday_low1=MathMin(yesterday_low1,low[bar]);

      MqlDateTime tm0,tm1;
      TimeToStruct(time[bar],tm0);
      TimeToStruct(time[bar-1],tm1);

      if(tm0.day_of_year!=tm1.day_of_year)
        {
         yesterday_high=yesterday_high1;
         yesterday_low=yesterday_low1;
         yesterday_close=close[bar-1];
         yesterday_high1=open[bar];
         yesterday_low1=open[bar];
         P=(yesterday_high+yesterday_low+yesterday_close+yesterday_close)/4;
         R1=P + P - yesterday_low;
         S1=P + P - yesterday_high;
         R2=P + yesterday_high - yesterday_low;
         S2=P - yesterday_high + yesterday_low;
         R3=P + R2 - yesterday_low;
         S3=P + S2 - yesterday_high;
        }
        
      R30_Buffer[bar]=R3;
      R20_Buffer[bar]=R2;
      R10_Buffer[bar]=R1;

      P_Buffer[bar]=P;

      S10_Buffer[bar]=S1;
      S20_Buffer[bar]=S2;
      S30_Buffer[bar]=S3;
     }
//----
   ChartRedraw(0);
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
