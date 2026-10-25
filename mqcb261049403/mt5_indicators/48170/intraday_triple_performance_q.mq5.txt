//+------------------------------------------------------------------+
//|                                       Intraday Performance %.mq5 |
//|                                                           Pueblo |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Pueblo"
#property link      "https://www.mql5.com/it/users/pueblo"
//---- indicator version number
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
//+----------------------------------------------+
//|  Indicator drawing parameters                |
#property indicator_type1   DRAW_LINE
#property indicator_color1  Yellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1



#property indicator_type3   DRAW_LINE
#property indicator_color3  Lime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input string pair1="EURUSD";//Cross 1
input string pair2="EURGBP";//Cross 2
input string pair3="GBPUSD";//Cross 3
input int bars=5000;
input string tm="00:00";// Start time in the format hours:minutes
//+----------------------------------------------+
double OscBuffer1[];
double OscBuffer2[];
double OscBuffer3[];

double open1[];
double close1[];
double open2[];
double close2[];
double open3[];
double close3[];

int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   min_rates_total=2;

   SetIndexBuffer(0,OscBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,OscBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,OscBuffer3,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   SetIndexBuffer(3,open1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,close1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,open2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,close2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,open3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,close3,INDICATOR_CALCULATIONS);

   string shortname;
   StringConcatenate(shortname,"Perf.% "+pair1+" "+pair2+" "+pair3+" (",tm,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   PlotIndexSetString(0,PLOT_LABEL,"% "+pair1);
   PlotIndexSetString(1,PLOT_LABEL,"% "+pair2);
   PlotIndexSetString(2,PLOT_LABEL,"% "+pair3);

//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
   const int rates_total,    // amount of history in bars at the current tick
   const int prev_calculated,// amount of history in bars at the previous tick
   const datetime &time[],
   const double &open[],
   const double& high[],     // price array of maximums of price for the calculation of indicator
   const double& low[],      // price array of price lows for the indicator calculation
   const double &close[],
   const long &tick_volume[],
   const long &volume[],
   const int &spread[]
)
  {
   if(rates_total<min_rates_total)
      return(0);

   int first,bar;
   static double Open1=0.0;
   static double Open2=0.0;
   static double Open3=0.0;

   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=min_rates_total; // starting index for calculation of all bars
     }
   else
      first=prev_calculated-1; // starting number for calculation of new bars

   CopyOpen(pair1,PERIOD_CURRENT,0,bars,open1);

   CopyClose(pair1,PERIOD_CURRENT,0,bars,close1);

   CopyOpen(pair2,PERIOD_CURRENT,0,bars,open2);

   CopyClose(pair2,PERIOD_CURRENT,0,bars,close2);


   CopyOpen(pair3,PERIOD_CURRENT,0,bars,open3);

   CopyClose(pair3,PERIOD_CURRENT,0,bars,close3);


//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {


      if(TimeToString(time[bar],TIME_MINUTES)==tm)
        {
         Open1=open1[bar];
         Open2=open2[bar];
         Open3=open3[bar];

        }

      if(Open1!=0)

         OscBuffer1[bar]=(close1[bar]-Open1)/Open1*100;

      if(Open2!=0)
         OscBuffer2[bar]=(close2[bar]-Open2)/Open2*100;

      if(Open3!=0)
         OscBuffer3[bar]=(close3[bar]-Open3)/Open3*100;
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
