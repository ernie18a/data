//+---------------------------------------------------------------------+
//|                                                       NonLagAMA.mq5 | 
//|                                         Copyright © 2009, edwinodus | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2009, edwinodus"
#property link "Copyright © 2009, edwinodus"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a multicolored line
#property indicator_type1   DRAW_COLOR_LINE
//---- colors of the three-color line are
#property indicator_color1  clrMagenta,clrGray,clrDeepSkyBlue
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "NonLagAMA"

//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA;
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_=1,       //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_,        //Demark Price
   PRICE_NAVEL_          //Navel Price 
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
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint Length0=12; // depth of averaging NonLagAMA
input double Deviation=0; //deviation
input uint Filter=0; //price measurement value, not considered by the Moving Average in points
input Smooth_Method MA_Method1=MODE_SMA; //smoothing method
input uint Length1=12; //smoothing depth                    
input int Phase1=15; //smoothing parameter,
                     //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Applied_price_ IPC=PRICE_CLOSE;//price constant
input int Shift=0; // horizontal shift of the indicator in bars
input int PriceShift=0; // vertical shift of the indicator in points
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[];
double ColorIndBuffer[];

double Coeff,pi,Cycle,res1,res2,FPoint;
//---- Declaration of the average vertical shift value variable
double dPriceShift;
//---- Declaration of integer variables of data starting point
int min_rates_total,Length0_,Len;
//---- declaration of global variables
int Count[];
double Value[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by the link
                          int Size)
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
//| NonLagAMA indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=XMA.GetStartBars(MA_Method1,Length1,Phase1);
//---- setting alerts for invalid values of external parameters
   XMA.XMALengthCheck("Length1",Length1);
//---- setting alerts for invalid values of external parameters
   XMA.XMAPhaseCheck("Phase1",Phase1,MA_Method1);

//---- Initialization of the vertical shift
   dPriceShift=_Point*PriceShift;

   pi=3.1415926535;
//----
   Cycle=4;
   Coeff=3*pi;
   Length0_=int(MathMin(Length0-1,2));
   Len=int(Length0*Cycle+Length0_);  
   res1=1.0/(Length0_-1);   
   double res=Cycle*Length0-1;
   if(!res) res=1;
   res2=(2*Cycle-1)/res;
   FPoint=Filter*_Point;

//---- memory allocation for arrays of variables  
   ArrayResize(Count,int(Len));
   ArrayResize(Value,int(Len));
//----
   ArrayInitialize(Count,0);
   ArrayInitialize(Value,0.0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"NonLagAMA");

//---- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| NonLagAMA iteration function                                     | 
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
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of variables with a floating point  
   double price;
   double alfa,t,Sum,Weight,g;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) //checking for the first start of calculation of an indicator
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      Value[Count[0]]=XMA.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price,bar,false);

      Weight=0;
      Sum=0;
      t=0;

      for(int iii=0; iii<Len; iii++)
        {
         g=1.0/(Coeff*t+1);
         if(t<=0.5) g=1;
         alfa=g*MathCos(pi*t);
         Sum+=alfa*Value[Count[iii]];
         Weight+=alfa;
         if(t<1) t+=res1;
         else if(t<Len-1) t+=res2;
        }
        
      if (Weight) IndBuffer[bar]=dPriceShift+(1.0+Deviation/100)*Sum/Weight;
      if(bar && MathAbs(IndBuffer[bar]-IndBuffer[bar-1])<FPoint) IndBuffer[bar]=IndBuffer[bar-1];
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,Len);
     }
//---- correction of the first variable value
   if(prev_calculated>rates_total || prev_calculated<=0) //checking for the first start of calculation of an indicator
      first=min_rates_total; // starting index for calculation of all bars

//---- Main loop of the signal line coloring
   for(bar=first; bar<rates_total; bar++)
     {
      ColorIndBuffer[bar]=1;
      if(IndBuffer[bar-1]<IndBuffer[bar]) ColorIndBuffer[bar]=2;
      if(IndBuffer[bar-1]>IndBuffer[bar]) ColorIndBuffer[bar]=0;
      if(IndBuffer[bar-1]==IndBuffer[bar]) ColorIndBuffer[bar]= ColorIndBuffer[bar-1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
