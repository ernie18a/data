//+---------------------------------------------------------------------+
//|                                                     EntropyMath.mq5 | 
//|                                     Copyright © 2008, Aleksandr Pak | 
//|                                      http://forum.mql4.com/ru/13708 | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, Aleksandr Pak"
#property link "http://forum.mql4.com/ru/13708" 
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the four-color histogram are as follows
#property indicator_color1 clrMagenta,clrPurple,clrGray,clrBlue,clrTeal
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "EntropyMath"

//---- drawing of the indicator as a three color line
#property indicator_type2 DRAW_COLOR_LINE
//---- colors of the three-color line are
#property indicator_color2 clrRed,clrGray,clrDodgerBlue
//---- the indicator line is a dash-and-dot curve
#property indicator_style2 STYLE_DASHDOTDOT
//---- indicator line width is equal to 5
#property indicator_width2 5
//---- displaying label of the signal line
#property indicator_label2  "Signal EntropyMath"
//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1;
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
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
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_,        //Demark Price
   PRICE_NAVEL_          //Navel Price
  };
//+-----------------------------------+
//|  declaration of enumerations      |
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
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_T3; //method of averaging of the histogram
input uint numbars=12; //period of averaging
input int XPhase= 100;  //parameter of averaging
                       //for JJMA, it varies within the range -100 ... +100 and influences on the quality of the transient period;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input Smooth_Method Signal_Method=MODE_JJMA; //method of averaging of the signal line
input uint Signal_XMA=9; //signal line period 
input int Signal_XPhase=100; // parameter of the signal line,
                            //varying within the range -100 ... +100,
//it influences the quality of the transient period;
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//price constant
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_;
//---- declaration of global variables
int Count[];
double Value[];
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],SignBuffer[],ColorIndBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Returns the number of the current value of the price series by reference
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
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_=XMA1.GetStartBars(XMA_Method,numbars,XPhase)+1;
   min_rates_total=min_rates_+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_XPhase);

//---- memory allocation for arrays of variables  
   ArrayResize(Count,numbars);
   ArrayResize(Value,numbars);

   ArrayInitialize(Count,0);
   ArrayInitialize(Value,0.0);

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(3,ColorSignBuffer,INDICATOR_COLOR_INDEX);

//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- setting alerts for invalid values of external parameters
   XMA1.XMALengthCheck("numbars", numbars);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
//---- setting alerts for invalid values of external parameters
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   XMA1.XMAPhaseCheck("Signal_XPhase", Signal_XPhase, Signal_Method);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"EntropyMath( ",numbars,", ",Smooth1,", ",Signal_XMA,", ",Smooth2," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,3*_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| XMACD iteration function                                         | 
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

//---- Declaration of integer variables
   int first,bar,clr;
//---- Declaration of variables with a floating point  
   double P,sumx,sumx2,avgx,rmsx;


//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      first=1; // starting number for calculation of all bars
     }
   else // starting number for the calculation of new bars
     {
      first=prev_calculated-1;
     }

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      Value[Count[0]]=MathLog(PriceSeries(AppliedPrice,bar,open,low,high,close)/PriceSeries(AppliedPrice,bar-1,open,low,high,close));

      sumx=0.0;
      sumx2=0.0;

      for(int kkk=0; kkk<int(numbars); kkk++)
        {
         sumx+=Value[kkk];
         sumx2+=Value[kkk]*Value[kkk];
        }

      avgx=sumx/numbars;
      rmsx=MathSqrt(sumx2/numbars);
      P=((avgx/rmsx)+1)/2.0;
      IndBuffer[bar]=P*MathLog(1+rmsx)+(1-P)*MathLog(1-rmsx);
      SignBuffer[bar]=XMA1.XMASeries(min_rates_,prev_calculated,rates_total,XMA_Method,XPhase,numbars,IndBuffer[bar],bar,false);
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,numbars);
     }

   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//---- Main loop of the XMACD indicator coloring
   for(bar=first; bar<rates_total; bar++)
     {
      clr=2;
      
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=3;
        }

      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=1;
        }
        
      ColorIndBuffer[bar]=clr;
     }

//---- Main loop of the signal line coloring
   for(bar=first; bar<rates_total; bar++)
     {
      clr=1;
      if(IndBuffer[bar]>SignBuffer[bar-1]) clr=2;
      if(IndBuffer[bar]<SignBuffer[bar-1]) clr=0;
      ColorSignBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
