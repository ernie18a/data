//+---------------------------------------------------------------------+ 
//|                                           2pbIdealXOSMA_Candles.mq5 | 
//|                                  Copyright © 2012, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version number
#property version   "1.01"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 6
#property indicator_buffers 6 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRed,clrOrange,clrPurple,clrViolet,clrBlue,clrDeepSkyBlue,clrTeal,clrLime
//---- displaying the indicator label
#property indicator_label1  "2pbIdealXOSMA Open";"2pbIdealXOSMA High";"2pbIdealXOSMA Low";"2pbIdealXOSMA Close"

//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
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
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int Period1 = 10; //rough smoothing
input int Period2 = 10; //adjusting smoothing

input int PeriodX1 = 10; //first rough smoothing
input int PeriodX2 = 10; //first adjusting smoothing
input int PeriodY1 = 10; //second rough smoothing
input int PeriodY2 = 10; //second adjusting smoothing
input int PeriodZ1 = 10; //third rough smoothing
input int PeriodZ2 = 10; //third adjusting smoothing

input Smooth_Method SmoothMethod=MODE_JJMA; //smoothing method
input int Smooth_XMA=9; //smoothing period
input int Smooth_Phase=100;   //moving averages smoothing parameter,
                       // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
double OsmaBuffer[];
//---- declarations of variables for smoothing constants
double w1,w2,wX1,wX2,wY1,wY2,wZ1,wZ2;
//---- declarations of variables for storing smoothing results
double Moving0_,Moving01_,Moving11_,Moving21_;
//+------------------------------------------------------------------+
// The iPriceSeries function description                             |
// Moving_Average class description                                  | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
//+------------------------------------------------------------------+
//|  Smoothing from Neutron                                          |
//+------------------------------------------------------------------+
double GetIdealMASmooth
(
 double W1_,//first smoothing constant
 double W2_,//second smoothing constant
 double Series1,//the value of the time series from the current bar 
 double Series0,//the value of the time series from the previous bar 
 double Resalt1 //the value of the moving from the previous bar
 )
  {
//----
   double Resalt0,dSeries,dSeries2;
   dSeries=Series0-Series1;
   dSeries2=dSeries*dSeries-1.0;

   Resalt0=(W1_ *(Series0-Resalt1)+
            Resalt1+W2_*Resalt1*dSeries2)
   /(1.0+W2_*dSeries2);
//----
   return(Resalt0);
  }
//+------------------------------------------------------------------+    
//| 2pbIdealXOSMA indicator initialization function                  | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2+XMA1.GetStartBars(SmoothMethod,Smooth_XMA,Smooth_Phase);

//---- initializations of variables
   w1=1.0/Period1;
   w2=1.0/Period2;
   wX1=1.0/PeriodX1;
   wX2=1.0/PeriodX2;
   wY1=1.0/PeriodY1;
   wY2=1.0/PeriodY2;
   wZ1=1.0/PeriodZ1;
   wZ2=1.0/PeriodZ2;

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,OsmaBuffer,INDICATOR_DATA);
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Smooth_XMA",Smooth_XMA);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Smooth_Phase",Smooth_Phase,SmoothMethod);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"2pbIdealXOSMA Candles");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| 2pbIdealXOSMA iteration function                                 | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<min_rates_total) return(0);

///---- declaration of local variables 
   int first,bar;
   double Osma0,Osma1,price0,price1;
   double Moving0,SlowMA,FastMA,macd;
   double Moving00,Moving10,Moving20;
   double Moving01,Moving11,Moving21;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=1;  // starting number for calculation of all bars

      //---- the starting initialization  
      Moving0_=price0=PriceSeries(IPC,0,open,low,high,close);
      Moving01_=Moving0_;
      Moving11_=Moving0_;
      Moving21_=Moving0_;
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- restore values of the variables
   Moving0=Moving0_;
   Moving01=Moving01_;
   Moving11=Moving11_;
   Moving21=Moving21_;

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      //---- call of the PriceSeries function to get a price
      price0=PriceSeries(IPC,bar,open,low,high,close);
      price1=PriceSeries(IPC,bar-1,open,low,high,close);
      
      Moving0=GetIdealMASmooth(w1,w2,price1,price0,Moving0);
      Moving00=GetIdealMASmooth(wX1,wX2,price1,price0,Moving01);
      Moving10=GetIdealMASmooth(wY1,wY2,Moving01,    Moving00,  Moving11);
      Moving20=GetIdealMASmooth(wZ1,wZ2,Moving11,    Moving10,  Moving21);
      //----                       
      Moving01 = Moving00;
      Moving11 = Moving10;
      Moving21 = Moving20;

      SlowMA=Moving20;
      FastMA=Moving0;
      macd=FastMA-SlowMA;
      OsmaBuffer[bar]=XMA1.XMASeries(1,prev_calculated,rates_total,SmoothMethod,Smooth_Phase,Smooth_XMA,macd,bar,false);

      if(bar==rates_total-2)
        {
         Moving0_=Moving0;
         Moving01_=Moving01;
         Moving11_=Moving11;
         Moving21_=Moving21;
        }
     }

   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//---- main loop of the Ind indicator coloring
   for(bar=first; bar<rates_total; bar++)
     {
      //--- Initialization of candles
      ExtOpenBuffer[bar]=open[bar];
      ExtCloseBuffer[bar]=close[bar];
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer[bar]=low[bar];

      
      Osma0=OsmaBuffer[bar];
      Osma1=OsmaBuffer[bar-1];

      if(Osma0>=0)
        {
         if(Osma1>Osma0) {if(close[bar]>=open[bar]) ExtColorBuffer[bar]=5; else ExtColorBuffer[bar]=4;}
         if(Osma1<=Osma0) {if(close[bar]>=open[bar]) ExtColorBuffer[bar]=7; else ExtColorBuffer[bar]=6;}
        }

      if(Osma0<0)
        {
         if(Osma1<=Osma0) {if(close[bar]>=open[bar]) ExtColorBuffer[bar]=3; else ExtColorBuffer[bar]=2;}
         if(Osma1>Osma0) {if(close[bar]>=open[bar]) ExtColorBuffer[bar]=1; else ExtColorBuffer[bar]=0;}
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
