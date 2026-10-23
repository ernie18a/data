//+------------------------------------------------------------------+
//|                                      ParkinsonHistVolatility.mq5 | 
//|                              Copyright © 2008, Victor Umnyashkin |
//|                                                   v354@hotbox.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Victor Umnyashkin"
#property link      "v354@hotbox.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing the indicator as a three-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used
#property indicator_color1 clrGray,clrDarkOrchid,clrDeepSkyBlue
//---- the indicator line is a continuous curve
#property indicator_style1 STYLE_SOLID
//---- the indicator line width is 4
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "ParkinsonHistVolatility"
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS     |
//+-----------------------------------+
input int Per=21;
input int Trading_Day_In_Year=365;
input int Percent=100;
input double Coeff=1;       
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
double Hi[],Lo[];
//---- indicator buffers
double LineBuffer[],ColorLineBuffer[];
//---- Declaration of integer variables of data starting point
int YearBase,min_rates_total;
//+------------------------------------------------------------------+   
//| ParkinsonHistVolatility initialization function                  | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data starting point
   min_rates_total=Per+1;
   
//---- Initialization of variables
   YearBase=Trading_Day_In_Year*PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
   
//---- Memory allocation
   ArrayResize(Hi,Per);   
   ArrayResize(Lo,Per);

//---- setting dynamic array as indicator buffer
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- setting the indicator values that will be invisible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(LineBuffer,true);
   
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorLineBuffer,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorLineBuffer,true);
   
//---- initialization of a variable for a short name of the indicator
   string shortname;
   StringConcatenate(shortname,"Parkinson Hi Vol(",Per,")");
//--- creating a name to be displayed in a separate subwindow and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| ParkinsonHistVolatility iteration function                       | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // history in bars at the current tick
                const int prev_calculated,// history in bars at the previous tick
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
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of variables with a floating point  
   double Volatility;
//---- Declaration of integer variables and getting the bars already calculated
   int limit,bar;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }


//---- indexing array elements as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);


//---- Main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      for(int jj=0; jj<Per; jj++)
         { 
         Hi[jj]=high[bar+jj];
         Lo[jj]=low[bar+jj];       
         }

       Volatility=WVHiVolParkinson(Per,Hi,Lo);       
       LineBuffer[bar]=Volatility*MathSqrt(1.0*YearBase/Per)*Percent*Coeff;
     }
 
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;   
//---- Main indicator coloring loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {    
      ColorLineBuffer[bar]=0;
      if(LineBuffer[bar]>LineBuffer[bar+1]) ColorLineBuffer[bar]=2;
      if(LineBuffer[bar]<LineBuffer[bar+1]) ColorLineBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+
double WVHiVolParkinson(int N,const double& HiArr[],const double& LoArr[])
{
//-----
   static bool first=true;
   static double Log2x4;
   
   if(first)
     {
      first=false;
      Log2x4=4*MathLog(2.0);
     }

   double sum=0;
   for(int iii =0 ; iii<N ; iii++ )
      sum +=MathPow( MathLog( HiArr[iii]/LoArr[iii] ) ,2 )/Log2x4;
//-----  
   return(MathSqrt(sum));
}
//+------------------------------------------------------------------+
