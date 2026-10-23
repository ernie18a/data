//+---------------------------------------------------------------------+
//|                                                       X2MA NRTR.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Place the file SmoothAlgorithms.mqh                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- MediumSlateBlue color is used for the indicator line
#property indicator_color1 MediumSlateBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "X2MA NRTR"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_SMA;  // First smoothing averaging method 
input int Length1=12;                     // First smoothing depth                    
input int Phase1=15;                      // First smoothing parameter
input Smooth_Method MA_Method2=MODE_JJMA; // Second smoothing averaging method 
input int Length2= 5;                     // Second smoothing depth 
input int Phase2=15;                      // Second smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;     // Price constant
input uint Step=30;                       // Flat oscillations size
input uint Max_DEV=55;                    // Terminal deviation of price from X2MA that does not change the value of the average
input int Shift=0;                        // Horizontal shift of the indicator in bars
input int PriceShift=0;                   // Vertical shift of the indicator in points
//+-----------------------------------+
//---- declaration of a dynamic array that 
//---- will be used as an indicator buffer
double X2MA[];
//---- declaration of the average vertical shift value variable
double dPriceShift;
//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBars1,StartBars2;
//---- declaration of global variables
double Max_Dev,Norma;
//+------------------------------------------------------------------+   
//| X2MA indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   StartBars2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   StartBars=StartBars1+StartBars2;
//---- setting up alerts for invalid values of external variables
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//---- setting up alerts for invalid values of external variables
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);

//---- initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

//---- initialization of constants
   Max_Dev=MathMax(Max_DEV,1)*_Point;
   Norma=MathMax(Step,1)*_Point;

//---- set X2MA[] dynamic array as an indicator buffer
   SetIndexBuffer(0,X2MA,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"X2MA");
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA NRTR(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| X2MA iteration function                                          | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- memory variables declaration 
   static int trend_;
   static double Max_,Min_,Resalt_;
//---- declaration of variables with a floating point
   double price_,x1xma,x2xma,Resalt,Swng,Velue,Min,Max;
//---- declaration of integer variables and getting already calculated bars
   int first,bar,trend;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0;                   // starting index for calculation of all bars
      Max_=-1;
      Min_=999999999;
      trend_=0;
      Resalt_=0.0;
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- restore values of the variables
   Max=Max_;
   Min=Min_;
   trend=trend_;
   Resalt=Resalt_;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         Max_=Max;
         Min_=Min;
         trend_=trend;
         Resalt_=Resalt;
        }

      //---- call of the PriceSeries function to get the input price 'price_'
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- two calls of the XMASeries function. 
      //---- The 'begin' parameter is increased by StartBars1 in the second call, as it is another XMA smoothing  
      x1xma = XMA1.XMASeries( 0, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_, bar, false);
      x2xma = XMA2.XMASeries(StartBars1, prev_calculated, rates_total, MA_Method2, Phase2, Length2,  x1xma, bar, false);
      Velue=x2xma;

      //---- discretization and NRTR processing of the obtained X2MA indicator
      //---- Velue obtained value normalizing
      Velue/= Norma;
      Velue = NormalizeDouble(Velue,0);
      Velue*=Norma;

      Swng=price_-Velue;

      if(trend>=0)
        {
         if(Velue>=Max)
           {
            Max=Velue;
            Resalt=Velue;
           }
         else
         if(Swng<-Max_Dev)
           {
            Min=Velue;
            Resalt = Velue;
            trend  = -1;
           }
         else Resalt=Max;
        }

      if(trend<=0)
        {
         if(Velue<=Min)
           {
            Min=Velue;
            Resalt=Velue;
           }
         else
         if(Swng>+Max_Dev)
           {
            Max=Velue;
            Resalt = Velue;
            trend  = +1;
           }
         else Resalt=Min;
        }

      X2MA[bar]=Resalt+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
