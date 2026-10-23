//+------------------------------------------------------------------+
//|                                                  StepMA_Line.mq5 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2006, TrendLaboratory"
//---- link to the website of the author
#property link "http://www.forex-instruments.info"
#property link "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- indicator version
#property version   "7.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a colored line
#property indicator_type1   DRAW_COLOR_LINE
//---- Gray, DodgerBlue and Magenta colors are used for the indicator line
#property indicator_color1  Gray,DodgerBlue,Magenta
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator line label
#property indicator_label1  "StepMA Line"
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum MA_MODE // Type of constant
  {
   SMA,      // SMA
   LWMA      // LWMA
  };
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum PRICE_MODE // Type of constant
  {
   HighLow,     // High/Low
   CloseClose   // Close/Close
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int        Length      = 10;      // Volty Length
input double     Kv          = 1.0;     // Sensivity Factor
input int        StepSize    = 0;       // Constant Step Size (if need)
input MA_MODE    MA_Mode     = SMA;     // Volty MA Mode : SMA, LWMA 
input int        Advance     = 0;       // Offset
input double     Percentage  = 0;       // Percentage of Up/Down Moving   
input PRICE_MODE Switch      = HighLow; // High/Low Mode Switch (more sensitive)    
input int        Shift=0;               // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtBuffer[];
double ColorExtBuffer[];
double ratio;
int trend1,trend0;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+ 
//| StepSize Calculation                                             |
//+------------------------------------------------------------------+ 
double StepSizeCalc(const double &High[],const double &Low[],int Len,double Km,int Size,int bar)
  {
//----
   double ATR0,result,alfa;
   static double ATRmax=-100000,ATRmin=1000000;
   static double ATRmax_,ATRmin_;

   if(bar==0)
     {
      ATRmax=ATRmax_;
      ATRmin=ATRmin_;
     }

   if(Size==0)
     {
      double AvgRange=0;
      for(int iii=Len-1; iii>=0; iii--)
        {
         if(MA_Mode==SMA) alfa=1.0; else alfa=1.0+1.0*(Len-iii)/Len;
         AvgRange+=alfa*(High[bar+iii]-Low[bar+iii]);
        }

      ATR0=AvgRange/Len;

      if(ATR0>ATRmax) ATRmax=ATR0;
      if(ATR0<ATRmin) ATRmin=ATR0;

      result=MathRound(0.5*Km*(ATRmax+ATRmin)/_Point);
     }
   else result=Km*StepSize;

   if(bar==1)
     {
      ATRmax_=ATRmax;
      ATRmin_=ATRmin;
     }
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| StepMA Calculation                                               |
//+------------------------------------------------------------------+ 
double StepMACalc(const double &High[],const double &Low[],const double &Close[],bool HL,double Size,int bar)
  {
//----
   double result,smax0,smin0,SizeP,Size2P;
   static double smax1,smin1;
   static bool FirstStart=true;
   SizeP=Size*_Point;
   Size2P=2.0*SizeP;

//---- variables start initialization
   if(FirstStart)
     {
      trend1=0;
      smax1=Low[bar]+Size2P;
      smin1=High[bar]-Size2P;
      FirstStart=false;
     }

   if(HL)
     {
      smax0=Low[bar]+Size2P;
      smin0=High[bar]-Size2P;
     }
   else
     {
      smax0=Close[bar]+Size2P;
      smin0=Close[bar]-Size2P;
     }

   trend0=trend1;

   if(Close[bar]>smax1) trend0=+1;
   if(Close[bar]<smin1) trend0=-1;

   if(trend0>0)
     {
      if(smin0<smin1) smin0=smin1;
      result=smin0+SizeP;
     }
   else
     {
      if(smax0>smax1) smax0=smax1;
      result=smax0-SizeP;
     }

   if(bar!=0)
     {
      smax1=smax0;
      smin1=smin0;
      trend1=trend0;
     }
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=Length+3;
//---- initialization of variables  
   ratio=Percentage/100.0*_Point;

//---- set ExtBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ColorExtBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorExtBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ColorExtBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"StepMA Line (",Length,", ",Kv,", ",StepSize,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int limit,bar;
   double Step;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total;   // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      Step=StepSizeCalc(high,low,Length,Kv,StepSize,bar);
      if(!Step) Step=close[bar];
      ExtBuffer[bar]=StepMACalc(high,low,close,Switch,Step,bar)+ratio/Step;

      if(trend0>0) ColorExtBuffer[bar]=1;
      else if(trend0<0) ColorExtBuffer[bar]=2;
      else ColorExtBuffer[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
