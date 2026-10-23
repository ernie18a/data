//+------------------------------------------------------------------+ 
//|                                                   SolarWinds.mq5 | 
//|                                 Copyright © 2005, Yura Prokofiev |
//|                                         Yura.prokofiev@gmail.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005, Yura Prokofiev"
#property  link      "Yura.prokofiev@gmail.com"
//---- indicator version number
#property version   "1.01"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrRed,clrFireBrick,clrGray,clrTeal,clrChartreuse
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "Solar Winds"

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int period=10; //period of averaging
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| Solar Winds indicator initialization function                    | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=period;

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer,true);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ColorIndBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Solar Winds");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Solar Winds iteration function                                   | 
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
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit,bar;
   double Value,SolarWinds,price,MinL,MaxH,Res;
   static double Prev_Value;

//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
      Prev_Value=0.0;
      IndBuffer[limit+1]=0.0;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);


//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MaxH=high[ArrayMaximum(high,bar,period)];
      MinL=low[ArrayMinimum(low,bar,period)];
      price=(high[bar]+low[bar])/2;
      Res=MaxH-MinL;
      Value=0.0;
      if(Res) Value=0.33*2*((price-MinL)/Res-0.5)+0.67*Prev_Value;
      Value=MathMin(MathMax(Value,-0.999),0.999);

      Res=1-Value;
      if(Res) SolarWinds=0.5*MathLog((1+Value)/(1-Value))+0.5*IndBuffer[bar+1];
      else SolarWinds=0.0;
      
      //---- saving values of variables
      if(bar) Prev_Value=Value;

      IndBuffer[bar]=SolarWinds;
      ColorIndBuffer[bar]=2;

      if(SolarWinds>0)
        {
         if(SolarWinds>IndBuffer[bar+1]) ColorIndBuffer[bar]=4;
         if(SolarWinds<IndBuffer[bar+1]) ColorIndBuffer[bar]=3;
        }

      if(SolarWinds<0)
        {
         if(SolarWinds<IndBuffer[bar+1]) ColorIndBuffer[bar]=0;
         if(SolarWinds>IndBuffer[bar+1]) ColorIndBuffer[bar]=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
