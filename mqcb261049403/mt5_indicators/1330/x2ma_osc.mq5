//+---------------------------------------------------------------------+
//|                                                        X2MA_Osc.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.10"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- MediumOrchid color is used as the color of the indicator line
#property indicator_color1 clrMediumOrchid
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "X2MA_Osc"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  CXMA class description                      |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
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
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input uint nPeriod=100; //oscillator normalization period
input Smooth_Method MA_Method1=MODE_SMA; //first smoothing averaging method 
input uint Length1=12; //first smoothing depth                    
input int Phase1=15; //first smoothing parameter,
  // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
  // For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Smooth_Method MA_Method2=MODE_JJMA; //second smoothing averaging method 
input uint Length2 = 5; //second smoothing depth 
input int Phase2=15;  //second smoothing parameter,
  // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
  // For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in pointsх
//+----------------------------------------------+

//---- declaration of a dynamic array that further 
// will be used as an indicator buffer
double X2MAOsc[];
//---- declaration of dynamic arrays that will further be 
// used as ring buffers
int Count[];
double X2MA[];
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_1,min_rates_2;
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
//| X2MA Osc indicator initialization function                       | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   min_rates_2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=min_rates_1+min_rates_2;
//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);
   
//---- memory distribution for variables' arrays  
   ArrayResize(Count,nPeriod);
   ArrayResize(X2MA,nPeriod);

//---- Initialization of arrays of variables
   ArrayInitialize(Count,0);
   ArrayInitialize(X2MA,0.0);

//---- indexing elements in arrays as timeseries
   ArraySetAsSeries(Count,true);
   ArraySetAsSeries(X2MA,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,X2MAOsc,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(X2MAOsc,true);
   
//---- initializations of variable for indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA_Osc(",nPeriod,", ",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| X2MA Osc iteration function                                      | 
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);
   
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);

//---- declaration of variables with a floating point  
   double price_,x1xma,x2xmaosc,MAX,MIN;
//---- Declaration of integer variables and getting the bars already calculated
   int limit,bar,maxbar1,maxbar2;
   
   maxbar1=rates_total-1;
   maxbar2=maxbar1-min_rates_1;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- Two calls of the XMASeries function. 
      //---- The 'begin' parameter is increased by StartBars1 in the second call, as к. another XMA smoothing  
      x1xma=XMA1.XMASeries(maxbar1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price_,bar,true);
      X2MA[Count[0]]=XMA2.XMASeries(maxbar2,prev_calculated,rates_total,MA_Method2,Phase2,Length2,x1xma,bar,true);
      
      //---- normalize the volatility
      MAX=X2MA[ArrayMaximum(X2MA,0,WHOLE_ARRAY)];
      MIN=X2MA[ArrayMinimum(X2MA,0,WHOLE_ARRAY)];
      //---- normalize the resulting value of volatility within the range from 0 to 100 and load in the indicator buffer
      x2xmaosc=Interpolation(MAX,MIN,100,0,X2MA[Count[0]]);
      //----       
      X2MAOsc[bar]=x2xmaosc-50;
      
      //---- recalculate the positions in ring buffers   
      if(bar>0) Recount_ArrayZeroPos(Count,nPeriod);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
