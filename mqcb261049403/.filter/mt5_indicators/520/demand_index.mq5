//+---------------------------------------------------------------------+
//|                                                    Demand Index.mq5 |
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\\MQL5\Include                |
//+---------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link to the website of the author
#property link "farria@mail.redcom.ru"
#property description "Demand Index"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- one buffer is used for calculation and drawing the indicator
#property indicator_buffers 1
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- medium slate blue color is used for the indicator bullish line
#property indicator_color1  MediumSlateBlue
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of the indicator 1 line is equal to 1
#property indicator_width1  1
//---- bullish indicator label display
#property indicator_label1  "Demand Index"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE_,        // Simple Price (OC/2)
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
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input Smooth_Method MA_SMethod=MODE_SMA;           // Smoothing method
input int SmLength=12;                             // Smoothing depth                    
input int SmPhase=15;                              // Smoothing parameter
input Applied_price_ IPC=PRICE_QUARTER_;           // Price constant
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Volume
input int Shift=0;                                 // Horizontal shift of the indicator in bars 
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double DIBuffer[];
//---- declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars=XMA1.GetStartBars(MA_SMethod,SmLength,SmPhase)+1;
//---- setting up alerts for invalid values of external variables
   XMA1.XMALengthCheck("Length", SmLength);
   XMA1.XMAPhaseCheck("Phase", SmPhase, MA_SMethod);
//---- initialization of the vertical shift
//---- set dynamic array DIBuffer[] as an indicator buffer
   SetIndexBuffer(0,DIBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by StartBars
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Demand Index");
//---- determine the accuracy of displaying the indicator values
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
   if(rates_total<StartBars) return(0);
//---- declarations of local variables 
   int first,bar,Sign;
   double AvgTR,Avg,VolAvg,price0,price1,WtCRatio=0.0,VolRatio;
   double Constant,DMI,TempDI,BuyPres,SellPres,BuyP,SellP;
   long Volume;
   static double VolAvg_,BuyPres_,SellPres_;
//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=1;                                           // starting index for calculation of all bars

      BuyPres_=1;
      SellPres_=1;

      if(VolumeType==VOLUME_TICK) VolAvg_=double(tick_volume[0]);
      else                        VolAvg_=double(volume[0]);
     }

   else first=prev_calculated-1; // starting index for calculation of new bars
//---- restore values of the variables
   VolAvg=VolAvg_;
   BuyPres=BuyPres_;
   SellPres=SellPres_;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
        {
         VolAvg_=VolAvg;
         BuyPres_=BuyPres;
         SellPres_=SellPres;
        }
      //---- call of the PriceSeries function to get the input price 'price_'
      price0=PriceSeries(IPC,bar,  open,low,high,close);
      price1=PriceSeries(IPC,bar-1,open,low,high,close);

      if(VolumeType==VOLUME_TICK) Volume=long(tick_volume[bar]);
      else                        Volume=long(volume[bar]);

      Avg=MathMax(high[bar],high[bar-1])-MathMin(low[bar],low[bar-1]);
      AvgTR=XMA1.XMASeries(1,prev_calculated,rates_total,MA_SMethod,SmPhase,SmLength,Avg,bar,false);
      VolAvg=((VolAvg *(SmLength-1))+Volume)/SmLength;

      if(price0!=0 && price1!=0 && AvgTR!=0 && VolAvg!=0)
         WtCRatio=(price0-price1)/MathMin(price0,price1);

      if(VolAvg!=0)VolRatio=Volume/VolAvg;
      else         VolRatio=1;

      Constant=((price0*3)/AvgTR)*MathAbs(WtCRatio);

      if(Constant>88) Constant=88;

      Constant=VolRatio/MathExp(Constant);

      if(WtCRatio>0)
        {
         BuyP=VolRatio;
         SellP=Constant;
        }
      else
        {
         BuyP=Constant;
         SellP=VolRatio;
        }

      BuyPres =((BuyPres *(SmLength-1))+BuyP )/SmLength;
      SellPres=((SellPres*(SmLength-1))+SellP)/SmLength;

      TempDI=+1;

      if(SellPres>BuyPres)
        {
         Sign=-1;
         if(SellPres!=0) TempDI=BuyPres/SellPres;
        }
      else
        {
         Sign=+1;
         if(BuyPres!=0) TempDI=SellPres/BuyPres;
        }

      TempDI*=Sign;

      if(TempDI<0) DMI= -1-TempDI;
      else        DMI =+1-TempDI;

      DIBuffer[bar]=DMI*100.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
