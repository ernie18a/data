//+------------------------------------------------------------------+ 
//|                                                   TrendPaint.mq5 | 
//|                                      Copyright © 2009, BACKSPACE | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, BACKSPACE"
#property link "" 
#property description "TrendPaint"
//---- indicator version number
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- five buffers are used for calculation of drawing of the indicator
#property indicator_buffers 5
//---- only one plot is used
#property indicator_plots   1
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRed,clrPurple,clrDarkGray,clrLavender,clrTeal,clrLime
//---- displaying the indicator label
#property indicator_label1  "TrendPaint Open";"TrendPaint High";"TrendPaint Low";"TrendPaint Close"

//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
#define SELL -2 //
#define BUY +2 //
#define FLAT 0 //
#define LONG +1 //
#define SHORT -1 //
//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input Smooth_Method Fast_Method=MODE_JJMA; //'Fast' averaging method
input uint Fast_Period=10; //Depth of the 'Fast' averaging                 
input int Fast_Phase=100; //'Fast' averaging parameter,
                         // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input uint Fast_Round=0; // The 'Rounding Fast' rounding ratio in points

input Smooth_Method Slow_Method=MODE_SMA; //'Slow' averaging method
input int Slow_Period=30; //Depth of the 'Slow' averaging                   
input int Slow_Phase=100; //'Slow' averaging parameter,
                         // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input uint Slow_Round=0; // The 'Rounding Slow' rounding ratio in points

input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//----
int min_rates_total;
double Fast_nRound,Slow_nRound;
//---- declaration of dynamic arrays that will further be 
// used as ring buffers
int Count[];
double Round_Fast[],Round_Slow[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   int min_rates_1=XMA1.GetStartBars(Fast_Method,Fast_Period,Fast_Phase);
   int min_rates_2=XMA2.GetStartBars(Slow_Method,Slow_Period,Slow_Phase);
   min_rates_total=MathMax(min_rates_1,min_rates_2)+4;
   Slow_nRound=Slow_Round*_Point;
   Fast_nRound=Fast_Round*_Point;

//---- memory distribution for variables' arrays  
   ArrayResize(Count,4);
   ArrayResize(Round_Fast,4);
   ArrayResize(Round_Slow,4);

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Fast_Period", Fast_Period);
   XMA2.XMALengthCheck("Slow_Period", Slow_Period);
   XMA1.XMAPhaseCheck("Fast_Phase", Fast_Phase, Fast_Method);
   XMA2.XMAPhaseCheck("Slow_Phase", Slow_Phase, Slow_Method);

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="TrendPaint";
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
//---- checking for the sufficiency of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int first,bar,bar0,bar1,bar2,bar3,Trend,Fast_Al_0=0,Slow_Al_0=0;
   double price_,Fast_MA_0,Slow_MA_0,HHigh,LLow,ExtremumLong,ExtremumShort,res0,res1;

   static double Fast_MA_1,Slow_MA_1,ExtremumLong_,ExtremumShort_;
   static int Trend_,Fast_Al_1,Slow_Al_1;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=0; // starting index for calculation of all bars
      Fast_MA_1=PriceSeries(IPC,first,open,low,high,close);
      Slow_MA_1=Fast_MA_1;
      Trend_=FLAT;
      Fast_Al_1=0;
      Slow_Al_1=0;
      ExtremumLong_=999999999;
      ExtremumShort_=0;
      Fast_Al_1=0;
      Slow_Al_1=0;
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Restoring the values of the variables
   Trend=Trend_;
   ExtremumLong=ExtremumLong_;
   ExtremumShort=ExtremumShort_;

//---- Main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- four calls of the XMASeries function.  
      Fast_MA_0 = XMA1.XMASeries(0, prev_calculated, rates_total, Fast_Method, Fast_Phase, Fast_Period, price_, bar, false);
      Slow_MA_0 = XMA2.XMASeries(0, prev_calculated, rates_total, Slow_Method, Slow_Phase, Slow_Period, price_, bar, false);

      bar0=Count[0];
      bar1=Count[1];
      bar2=Count[2];
      bar3=Count[3];

      res1=Round_Fast[bar1];
      
      if(Fast_MA_0>Fast_MA_1+Fast_nRound || Fast_MA_0<Fast_MA_1-Fast_nRound
         || Fast_MA_0>res1+Fast_nRound
         || Fast_MA_0<res1-Fast_nRound
         ||(Fast_MA_0>res1 && Fast_Al_1==+1)
         ||(Fast_MA_0<res1 && Fast_Al_1==-1))
         Round_Fast[bar0]=Fast_MA_0;
      else Round_Fast[bar0]=res1;

      res0=Round_Fast[bar0];
      if(res0<res1) Fast_Al_0=-1;
      if(res0>res1) Fast_Al_0=+1;
      if(res0==res1) Fast_Al_0=Fast_Al_1;
      
      res1=Round_Slow[bar1];

      if(Slow_MA_0>Slow_MA_1+Slow_nRound
         || Slow_MA_0<Slow_MA_1-Slow_nRound
         || Slow_MA_0>res1+Slow_nRound
         || Slow_MA_0<res1-Slow_nRound
         || (Slow_MA_0>res1 && Slow_Al_1==+1)
         || (Slow_MA_0<res1 && Slow_Al_1==-1))
         Round_Slow[bar0]=Slow_MA_0;
      else Round_Slow[bar0]=res1;

      res0=Round_Slow[bar0];
      if(res0<res1) Slow_Al_0 =-1;
      if(res0>res1) Slow_Al_0 =+1;
      if(res0==res1) Slow_Al_0=Slow_Al_1;

      if(open[bar]>close[bar])
        {
         HHigh=open[bar];
         LLow =close[bar];
        }
      else if(open[bar]<close[bar])
        {
         HHigh=close[bar];
         LLow=open[bar];
        }
      else
        {
         HHigh=close[bar];
         LLow=open[bar];
        }

      if(HHigh>ExtremumLong) ExtremumLong=HHigh;
      if(LLow<ExtremumShort) ExtremumShort=LLow;

      if(Round_Slow[bar1]<Round_Fast[bar1] && Round_Slow[bar2]>=Round_Fast[bar2] && Round_Slow[bar3]>Round_Fast[bar3]) Trend=BUY;
      if(Round_Slow[bar1]>Round_Fast[bar1] && Round_Slow[bar2]<=Round_Fast[bar2] && Round_Slow[bar3]<Round_Fast[bar3]) Trend=SELL;
      if(Trend==BUY && Round_Slow[bar1]>Round_Fast[bar1] || Trend==SELL && Round_Slow[bar1]<Round_Fast[bar1]) Trend=FLAT;

      //--- Initialization of candles
      ExtOpenBuffer[bar]=open[bar];
      ExtCloseBuffer[bar]=close[bar];
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer[bar]=low[bar];

      //--- candlesticks coloring
      switch(Trend)
        {
         case SELL: if(close[bar]>=open[bar]) ExtColorBuffer[bar]=1; else ExtColorBuffer[bar]=0; break;
         case FLAT: if(close[bar]>=open[bar]) ExtColorBuffer[bar]=3; else ExtColorBuffer[bar]=2; break;
         case BUY:  if(close[bar]>=open[bar]) ExtColorBuffer[bar]=5; else ExtColorBuffer[bar]=4; break;
        }

      //--- recalculation of positions in ring buffers  
      if(bar<rates_total-1)
        {
         Recount_ArrayZeroPos(Count);
         Fast_MA_1=Fast_MA_0;
         Slow_MA_1=Slow_MA_0;
         Fast_Al_1=Fast_Al_0;
         Slow_Al_1=Slow_Al_0;
        }

      //---- Saving values of variables
      if(bar==rates_total-2)
        {
         Trend_=Trend;
         ExtremumLong_=ExtremumLong;
         ExtremumShort_=ExtremumShort;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  recalculation of position of a newest element in the array      |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos
(
 int &CoArr[]// Return the current value of the price series by the link
 )
// Recount_ArrayZeroPos(count, Length)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=4;
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
