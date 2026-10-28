//+------------------------------------------------------------------+
//|                                                       VQbars.mq5 |
//|                                       Copyright © 2011, raff1410 | 
//|                                                   raff1410@o2.pl | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, raff1410"
#property link "raff1410@o2.pl"
#property description "VQbars"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator as a symbol
#property indicator_type1   DRAW_COLOR_ARROW
//---- the following colors are used for the indicator
#property indicator_color1  Gray,Magenta,Blue
//---- indicator line width is equal to 4
#property indicator_width1  4
//---- displaying the indicator label
#property indicator_label1  "VQbars Flat,VQbars Sell,VQbars Buy"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET  0    // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Smoothings classes description   |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA and CMomentum classes from the SmoothAlgorithms.mqh file
CXMA XMAO,XMAL,XMAH,XMAC;
CMomentum MOM;
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
input Smooth_Method VQMA_Method=MODE_SMA; // Smoothing method
input int VQLength=12;                    // Smoothing depth                    
input int VQPhase=15;                     // Smoothing parameter
input Applied_price_ IPC=PRICE_CLOSE;     // Applied price
input int VQMomentum=1;                   // Momentum
input uint Filter=5;                      // Maximum deviation
input int Shift=0;                        // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,xmin_rates_total,min_rates_total_;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   xmin_rates_total=XMAO.GetStartBars(VQMA_Method,VQLength,VQPhase);
   min_rates_total=xmin_rates_total+VQMomentum+1;
   min_rates_total_=min_rates_total-1;
//---- setting up alerts for unacceptable values of external variables
   XMAO.XMALengthCheck("VQLength", VQLength);
   XMAO.XMAPhaseCheck("VQPhase", VQPhase, VQMA_Method);

//---- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- set ColorIndBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="VQbars";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
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
   if(rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int first,bar,trend0,bar0;
   double MH,ML,MO,MC,MC1,VQ=0.0,SumVQ0,SumVQ1;
   static double SumVQ1_;
   static int trend1;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0;                   // starting index for calculation of all bars
      SumVQ1_=close[min_rates_total_];
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

   bar0=rates_total-1;

//---- restore values of the variables
   SumVQ1=SumVQ1_;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==bar0) SumVQ1_=SumVQ1;

      //---- 4 calls of the XMASeries method
      MO = XMAO.XMASeries(0, prev_calculated, rates_total, VQMA_Method, VQPhase, VQLength, open [bar], bar, false);
      MC = XMAC.XMASeries(0, prev_calculated, rates_total, VQMA_Method, VQPhase, VQLength, close[bar], bar, false);
      MH = XMAH.XMASeries(0, prev_calculated, rates_total, VQMA_Method, VQPhase, VQLength, high [bar], bar, false);
      ML = XMAL.XMASeries(0, prev_calculated, rates_total, VQMA_Method, VQPhase, VQLength, low  [bar], bar, false);
      MC1= MC-MOM.MomentumSeries(xmin_rates_total,prev_calculated,rates_total,VQMomentum,MC,bar,false);
      if(bar<min_rates_total) continue;

      if(MH-ML>0) VQ=MathAbs(((MC-MC1)/MathMax(MH-ML,MathMax(MH-MC1,MC1-ML))+(MC-MO)/(MH-ML))*0.5)*((MC-MC1+(MC-MO))*0.5);
      SumVQ0=SumVQ1+VQ;

      if(bar<=min_rates_total)
        {
         SumVQ1=SumVQ0;
         continue;
        }

      if(Filter && MathAbs(SumVQ0-SumVQ1)<Filter*_Point) SumVQ0=SumVQ1;

      trend0=trend1;
      if(SumVQ0 > SumVQ1) trend0=+1;
      if(SumVQ0 < SumVQ1) trend0=-1;

      IndBuffer[bar]=MC;
      ColorIndBuffer[bar]=0;

      if(trend0>0) ColorIndBuffer[bar]=2;
      else if(trend0<0) ColorIndBuffer[bar]=1;

      if(bar!=bar0) trend1=trend0;
      SumVQ1=SumVQ0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
