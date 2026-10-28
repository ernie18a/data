//+------------------------------------------------------------------+
//|                                            Volatility_FBA_NR.mq5 |
//|                                      Copyright © 2010, Svinozavr |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2010, Svinozavr"
//---- author of the indicator
#property link      ""
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
//---- Green color is used for indicator line
#property indicator_color1  clrGreen
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- Red color is used for indicator line
#property indicator_color2  Red
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum AlgMode
  {
   VOLUME,//volume
   ATR,    //ATR
   STDEV   //StDev
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input AlgMode Source=ATR; // source
input uint SourcePeriod=22; // source period
input uint FrontPeriod=1; // front smoothing period; <1
input uint BackPeriod=444; // damping smoothing period; <1
input uint Sens=0; // sensitivity threshold in points or in ticks (for volume)
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double VltBuffer[];
double SigBuffer[];
//---- declaration of variables for the EMA coefficients
double per0,per1,per3;
double sens; // sensitivity threshold in prices
int FBA; // 1 - front smoothing, -1 - damping smoothing, 0 - normal MA - smooth all!
//---- Declaration of integer variables for the indicator handles
int Ind_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   string ShortName;
   if(Sens>0) ShortName=string(Sens)+" ";
   FBA=0;

   string _fr=string(FrontPeriod);
   string _bk=string(BackPeriod);
   string _src;
//----
   switch(Source)
     {
      case VOLUME:  _src="Volume"; break;
      case ATR:
         _src="ATR";
         //---- getting the iATR indicator handle
         Ind_Handle=iATR(NULL,0,SourcePeriod);
         if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of iATR indicator");
         break;

      case STDEV:
         _src="StDev";
         //---- getting handle of the iStdDev indicator
         Ind_Handle=iStdDev(NULL,0,SourcePeriod,0,MODE_SMA,PRICE_CLOSE);
         if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of iStdDev indicator");
     }

   ShortName=ShortName+"("+_src+string(SourcePeriod)+")";

//---- front and damping
   if(FrontPeriod!=1 || BackPeriod!=1)
     {
      if(FrontPeriod==BackPeriod) ShortName=ShortName+" ("+_fr+")";
      else
        {
         if(FrontPeriod!=1) ShortName=ShortName+" Front("+_fr+")";
         if(BackPeriod!=1) ShortName=ShortName+" Back("+_bk+")";
        }
     }

//---- sensitivity threshold in prices
   if(Source>0) sens=Sens*_Point;
   else sens=Sens; // in ticks

//----
   if(FrontPeriod==BackPeriod)
     {
      FBA=0;
      per0=2.0/(1+FrontPeriod);
      per1=+1;
     }

   if(FrontPeriod<BackPeriod)
     {
      FBA=-1;
      per0=2.0/(1+FrontPeriod);
      per1=2.0/(1+BackPeriod);
     }
   else
     {
      FBA=+1;
      per0=2.0/(1+BackPeriod);
      per1=2.0/(1+FrontPeriod);
     }

   per3=2.0/(1+SourcePeriod);

//---- Initialization of variables of the start of data calculation
   min_rates_total=int(SourcePeriod+1+1);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,VltBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(VltBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,SigBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SigBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(Source>VOLUME && BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar;
   double ema0,ema1;
   static double prev_ema0,prev_ema1;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars

      if(Source==VOLUME)
        {
         if(VolumeType==VOLUME_TICK) prev_ema1=double(tick_volume[min_rates_total]);
         else prev_ema1=double(volume[min_rates_total]);
        }
      else prev_ema1=0;

      prev_ema0=prev_ema1;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

//--- copy newly appeared data in the array
   if(Source>VOLUME)
     {
      int to_copy=limit+1;
      if(CopyBuffer(Ind_Handle,0,0,to_copy,VltBuffer)<=0) return(RESET);
     }
   else
     {
      if(VolumeType==VOLUME_TICK)
        {
         //---- indexing elements in arrays as timeseries  
         ArraySetAsSeries(tick_volume,true);
         for(bar=limit; bar>=0 && !IsStopped(); bar--) VltBuffer[bar]=EMA_FBA(tick_volume[bar],VltBuffer[bar+1],per3,0);
        }
      else
        {
         //---- indexing elements in arrays as timeseries  
         ArraySetAsSeries(volume,true);
         for(bar=limit; bar>=0 && !IsStopped(); bar--)VltBuffer[bar]=EMA_FBA(volume[bar],VltBuffer[bar+1],per3,0);
        }

     }

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ema0=EMA_FBA(VltBuffer[bar],prev_ema0,per0,0);
      ema1=EMA_FBA(ema0,prev_ema1,per1,FBA);

      SigBuffer[bar]=MathMax(ema1,sens);

      if(bar)
        {
         prev_ema0=ema0;
         prev_ema1=ema1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| calculation of EMA FBA                                           |
//+------------------------------------------------------------------+
/* 
 * The EMA with different smoothing pframeters for the front and dumping
 * double Series     input signal
 * double EMA1       EMA values on the previous bar
 * double period     smoothing period; if >1, then recalculated into EMA coefficient 
 * int FBA          +1 - front smoothing, 
 *                  -1 - dumping smoothing,
 *                   0 - normal EMA - smooth all!
 */
//+------------------------------------------------------------------+
double EMA_FBA(double Series,double EMA1,double period,int fba)
  {
//----
   if(period==1) return(Series);

//---- coeff. EMA 
   if(period>1) period=2.0/(1+period);

//---- EMA
   double EMA=period*Series+(1-period)*EMA1;

//---- separation of front and dumping
   switch(fba)
     {
      case  0: /* normal MA */ return(EMA);
      case  1: /* front smoothing */ if(Series>EMA1) return(EMA); else return(Series);
      case -1: /* dumping smoothing */ if(Series<EMA1) return(EMA); else return(Series);
     }
//----
   return(EMA);
  }
//+------------------------------------------------------------------+
