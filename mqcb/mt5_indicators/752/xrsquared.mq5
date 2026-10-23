//+---------------------------------------------------------------------+
//|                                                      XR-Squared.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "R-Squared"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- DeepPink color is used for the indicator line
#property indicator_color1 DeepPink
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "R-Squared"
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- DodgerBlue color is used for the indicator line
#property indicator_color2 DodgerBlue
//---- the indicator line is a dot-dash one
#property indicator_style2  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1       70.0
#property indicator_level2       30.0
#property indicator_levelcolor DarkOrchid
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ // Type of constant
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
/*enum Smooth_Method is declared in the SmoothAlgorithms.mqh file
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
input int XPeriod=14;                    // Indicator period
input Smooth_Method RMethod=MODE_JJMA;   // Smoothing method
input int RPeriod=3;                     // Smoothing period
input int RPhase=100;                    // Smoothing parameter
input Smooth_Method SignMethod=MODE_SMA; // Smoothing method 
input int SignPeriod=14;                 // Signal line smoothing period
input int SignPhase=15;                  // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;    // Applied price
input int Shift=0;                       // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double RSquared[],XRSquared[];
//---- declaration of the integer variables for the start of data calculation
int StartBars,StartBarsR,StartBarsX;
//---- declaration of dynamic arrays that
//---- will be used as ring buffers
int Count[];
double MA[];
//----
int SumX,SumX2;
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[], // return the current value of the price series by the link
                          int Size)     // number of the elements in the ring buffer
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+   
//| XR-Squared indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBarsR=XMA.GetStartBars(RMethod,RPeriod,RPhase)+1;
   StartBarsX=StartBarsR+XPeriod+1;
   StartBars=StartBarsX+XMA.GetStartBars(SignMethod,SignPeriod,SignPhase);

//---- setting up alerts for unacceptable values of external variables
   XMA.XMALengthCheck("SignPeriod",SignPeriod);
   XMA.XMAPhaseCheck("SignPhase",SignPhase,SignMethod);

//---- setting up alerts for unacceptable values of external variables
   XMA.XMALengthCheck("RPeriod",RPeriod);
   XMA.XMAPhaseCheck("RPhase",RPhase,RMethod);

//---- memory distribution for variables' arrays  
   ArrayResize(Count,XPeriod);
   ArrayResize(MA,XPeriod);

//---- initialization of the variables arrays
   ArrayInitialize(Count,0);
   ArrayInitialize(MA,0.0);

//---- initialization of variables  
   SumX=0;
   for(int iii=0; iii<XPeriod; iii++) SumX+=iii+1;

   SumX2=0;
   for(int iii=0; iii<XPeriod; iii++) SumX2+=(iii+1)*(iii+1);

//---- set RSquared dynamic array as indicator buffer
   SetIndexBuffer(0,RSquared,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,RPeriod);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set XRSquared dynamic array as indicator buffer
   SetIndexBuffer(1,XRSquared,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname,Smooth;
   Smooth=XMA.GetString_MA_Method(SignMethod);
   StringConcatenate(shortname,"XR-Squared(",string(RPeriod),",",Smooth,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| XRSI iteration function                                          | 
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

//---- declaration of variables with a floating point  
   double price_,SumY,SumY2,SumXY,Q1,Q2,Q3,Q23;
//---- declaration of integer variables and getting already calculated bars
   int first,bar;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=0;
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get incrementation of the input price dprice_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      MA[Count[0]]=XMA.XMASeries(0,prev_calculated,rates_total,RMethod,RPhase,RPeriod,price_,bar,false);

      if(bar<StartBarsX)
        {
         //---- recalculation of the elements positions in the Smooth[] ring buffer
         if(bar<rates_total-2) Recount_ArrayZeroPos(Count,XPeriod);
         continue;
        }

      SumY=0;
      for(int iii=0; iii<XPeriod; iii++) SumY+=MA[Count[iii]];

      SumY2=0;
      for(int iii=0; iii<XPeriod; iii++) SumY2+=MathPow(MA[Count[iii]],2);

      SumXY=0;
      for(int iii=0; iii<XPeriod; iii++) SumXY+=(iii+1)*MA[Count[iii]];

      Q1=SumXY-SumX*SumY/XPeriod;
      Q2=SumX2-SumX*SumX/XPeriod;
      Q3=SumY2-SumY*SumY/XPeriod;
      Q23=Q2*Q3;

      if(Q23) RSquared[bar] = 100*Q1*Q1/(Q23);
      else    RSquared[bar] = 0.0;

      //----
      // XRSquared[bar]=XMA.XMASeries(StartBarsX,prev_calculated,rates_total,SignMethod,SignPhase,SignPeriod,RSquared[bar],bar,false);

      //---- recalculation of the elements positions in the Smooth[] ring buffer
      if(bar<rates_total-2) Recount_ArrayZeroPos(Count,XPeriod);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
