//+------------------------------------------------------------------+
//|                                                  StepMA_NRTR.mq5 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
//--- author of the indicator
#property copyright "Copyright © 2006, TrendLaboratory"
//--- link to the website of the author
#property link "http://www.forex-instruments.info"
#property link "http://finance.groups.yahoo.com/group/TrendLaboratory"
//--- indicator version
#property version   "7.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//--- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Indicator line drawing parameters           |
//+----------------------------------------------+
//--- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- blue violet color is used as the color of the bullish line of the indicator
#property indicator_color1  BlueViolet
//--- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the bullish label of the indicator line
#property indicator_label1  "Upper StepMA"
//--- drawing the indicator 2 as a line
//+----------------------------------------------+
//|  Indicator line drawing parameters           |
//+----------------------------------------------+
#property indicator_type2   DRAW_LINE
//--- use gold color for the bearish indicator line
#property indicator_color2  Gold
//--- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the label of the bearish indicator line
#property indicator_label2  "Lower StepMA"
//+----------------------------------------------+
//|  Indicator label drawing parameters          |
//+----------------------------------------------+
//--- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//--- spring green color is used as the color of the bullish indicator line
#property indicator_color3  SpringGreen
//--- the indicator 3 line is a continuous curve
#property indicator_style3  STYLE_SOLID
//--- the indicator 3 line width is equal to 4
#property indicator_width3  4
//--- displaying the indicator label
#property indicator_label3  "StepMA Buy"
//+----------------------------------------------+
//|  Indicator label drawing parameters          |
//+----------------------------------------------+
//--- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//--- use red color for the bearish indicator line
#property indicator_color4  Red
//--- the indicator 2 line is a continuous curve
#property indicator_style4  STYLE_SOLID
//--- the indicator 4 line width is equal to 4
#property indicator_width4  4
//--- displaying the indicator label
#property indicator_label4  "StepMA Sell"
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
input int        StepSize    = 0;       // Constant Step Size (if needed)
input MA_MODE    MA_Mode     = SMA;     // Volty MA Mode : SMA, LWMA 
input double     Percentage  = 0;       // Percentage of Up/Down Moving   
input PRICE_MODE Switch      = HighLow; // High/Low Mode Switch (more sensitive)    
input int        Shift=0;               // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double UpBuffer[];
double DnBuffer[];
double SellBuffer[];
double BuyBuffer[];

double ratio;
int trend1,trend1_,trend0;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+ 
//| StepSize Calculation                                             |
//+------------------------------------------------------------------+ 
double StepSizeCalc(const double &High[],const double &Low[],int Len,double Km,int Size,int bar)
  {
//---
   double ATR0,result,alfa;
   static double ATRmax=-100000,ATRmin=1000000;
   static double ATRmax_,ATRmin_;

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

   if(bar==0)
     {
      ATRmax=ATRmax_;
      ATRmin=ATRmin_;
     }

//---
   return(result);
  }
//+------------------------------------------------------------------+
//| StepMA Calculation                                               |
//+------------------------------------------------------------------+ 
double StepMACalc(const double &High[],const double &Low[],const double &Close[],bool HL,double Size,int bar)
  {
//---
   double result,smax0,smin0,SizeP,Size2P;
   static double smax1,smin1;
   static bool FirstStart=true;
   SizeP=Size*_Point;
   Size2P=2.0*SizeP;

//--- variables start initialization
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
      trend1_=trend1;
      trend1=trend0;
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=Length+3;
//--- initialization of variables  
   ratio=Percentage/100.0*_Point;
//--- set BufferUp[] dynamic array as indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(UpBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set BufferDown[] dynamic array as indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(DnBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set BufferUp1[] dynamic array as indicator buffer
   SetIndexBuffer(2,BuyBuffer,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(BuyBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,108);
//--- set BufferDown1[] dynamic array as indicator buffer
   SetIndexBuffer(3,SellBuffer,INDICATOR_DATA);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//--- shifting the start of drawing the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(SellBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,108);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"StepMA NRTR (",Length,", ",Kv,", ",StepSize,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
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
//--- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   int limit,bar;
   double StepMA,Step;
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total;                 // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;               // starting index for calculation of new bars
//--- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
      SellBuffer[bar]=EMPTY_VALUE;
      BuyBuffer[bar]=EMPTY_VALUE;
      //---
      Step=StepSizeCalc(high,low,Length,Kv,StepSize,bar);
      if(!Step) continue;
      //---
      StepMA=StepMACalc(high,low,close,Switch,Step,bar)+ratio/Step;
      //---
      if(trend0>0)
        {
         UpBuffer[bar]=StepMA-Step*_Point;
         if(trend1_<0) BuyBuffer[bar]=UpBuffer[bar];
         DnBuffer[bar]=EMPTY_VALUE;
        }
      //---
      if(trend0<0)
        {
         DnBuffer[bar]=StepMA+Step*_Point;
         if(trend1_>0) SellBuffer[bar]=DnBuffer[bar];
         UpBuffer[bar]=EMPTY_VALUE;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
