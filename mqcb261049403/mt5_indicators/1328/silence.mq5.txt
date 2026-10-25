//+------------------------------------------------------------------+ 
//|                                                      Silence.mq5 | 
//|                   Copyright © 2009, Trofimov Evgeniy Vitalyevich | 
//|                                     http://TrofimovVBA.narod.ru/ | 
//+------------------------------------------------------------------+
//---- author of the indicator 
#property copyright "Copyright © 2009, Trofimov Evgeniy Vitalyevich"
//---- author of the indicator
#property link      "http://TrofimovVBA.narod.ru/"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- Blue color is used as the color of the bullish line of the indicator
#property indicator_color1  clrBlue
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Aggressiveness"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used for the indicator bearish line
#property indicator_color2  clrRed
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Volatility"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 50.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint MyPeriod1=12;// volatility period
input uint MyPeriod2=96;// extremums searching period
input int  Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer1[];
double IndBuffer2[];
//---- Declaration of integer variables of data starting point
int min_rates_,min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as ring buffers
int Count[];
double Aggress[],Volatility[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the ring     |
//|  buffer                                                          |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(
                          int &CoArr[],// Return the current value of the price series by the link
                          int Size // Ring buffers size
                          )
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//|  calculation of interpolated values                              |
//+------------------------------------------------------------------+   
double Interpolation(double a,double b,double c,double d,double X)
//a; X; b - column of known data, c; d; - column of unknown data.
  {
//----
   if(b-a==0) return(10000000); //infinity
   else return(d -(b-X) *(d-c)/(b-a));
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_=int(MyPeriod1+1);
   min_rates_total=min_rates_+int(MyPeriod2);

//---- memory distribution for variables' arrays  
   ArrayResize(Count,MyPeriod2);
   ArrayResize(Aggress,MyPeriod2);
   ArrayResize(Volatility,MyPeriod2);

//---- Initialization of arrays of variables
   ArrayInitialize(Aggress,0.0);
   ArrayInitialize(Volatility,0.0);

//---- indexing elements in arrays as timeseries
   ArraySetAsSeries(Count,true);
   ArraySetAsSeries(Aggress,true);
   ArraySetAsSeries(Volatility,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer1,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,IndBuffer2,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(IndBuffer2,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Silence(",MyPeriod1,", ",MyPeriod2,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit,bar,bar0;
   double Sum,HH,LL,MAX,MIN;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar0=Count[0];

      //---- calculate the aggressiveness
      Sum=0;
      for(int x=0; x<int(MyPeriod1); x++)
        {
         int barx=bar+x;
         if(close[barx]>open[barx]) Sum+=close[barx]-close[barx+1]; //white candle
         else Sum+=close[barx+1]-close[barx]; //black candle
        }
      Aggress[bar0]=Sum/(_Point*MyPeriod1);
      
      //---- normalization aggressiveness
      MAX=Aggress[ArrayMaximum(Aggress,0,WHOLE_ARRAY)];
      MIN=Aggress[ArrayMinimum(Aggress,0,WHOLE_ARRAY)];
      //---- normalize the resulting value of aggressiveness within the range from 0 to 100 and load in the indicator buffer
      IndBuffer1[bar]=Interpolation(MAX,MIN,100,0,Aggress[bar0]);

      //---- calculate the volatility
      HH=high[ArrayMaximum(high,bar,MyPeriod1)];
      LL=low [ArrayMinimum(low, bar,MyPeriod1)];
      Volatility[bar0]=(HH-LL)/(_Point*MyPeriod1);
      
      //---- normalize the volatility
      MAX=Volatility[ArrayMaximum(Volatility,0,WHOLE_ARRAY)];
      MIN=Volatility[ArrayMinimum(Volatility,0,WHOLE_ARRAY)];
      //---- normalize the resulting value of volatility within the range from 0 to 100 and load in the indicator buffer
      IndBuffer2[bar]=Interpolation(MAX,MIN,100,0,Volatility[bar0]);

      //---- recalculate the positions in ring buffers   
      if(bar>0) Recount_ArrayZeroPos(Count,MyPeriod2);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
