//+---------------------------------------------------------------------+
//|                                                           Fast3.mq5 | 
//|                                             Copyright © 2008, xrust | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, xrust"
#property link ""
//---- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//----two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- pink is used for the color of the bearish indicator line
#property indicator_color1  clrMagenta
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- indicator bullish label display
#property indicator_label1  "Fast3 Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- cyan color is used as the color of the bullish line of the indicator
#property indicator_color2  clrDodgerBlue
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- bearish indicator label display
#property indicator_label2 "Fast3 Buy"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_LWMA; // Method of averaging of the first smoothing 
input uint Length1=3;                     // Depth of the first smoothing                    
input int  Phase1=15;                     // Parameter of the first smoothing
// for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method MA_Method2=MODE_LWMA; // Method of averaging of the second smoothing 
input uint Length2=9;                     // Depth of the second smoothing 
input int  Phase2=15;                     // Parameter of the second smoothing,
// for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
// for VIDIA it is a CMO period, for AMA it is a slow average period
input int Shift=0;                        // Horizontal shift of the indicator in bars
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//--- declaration of integer variables for the indicators handles
int ATR_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of dynamic arrays that
//---- will be used as ring buffers
int Count[];
double Xma1[],Xma2[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+      
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by reference
                          int Size)
  {
//---
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
//---
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- initialization of variables of the start of data calculation
   int ATR_Period=15;
   int min_rates_1=XMA1.GetStartBars(MA_Method1,Length1,Phase1);
   int min_rates_2=XMA2.GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total=MathMax(min_rates_1+min_rates_2,ATR_Period);

//--- setting up alerts for unacceptable values of external variables
   XMA1.XMALengthCheck("Length1",Length1);
   XMA2.XMALengthCheck("Length2",Length2);

//--- setting up alerts for unacceptable values of external variables
   XMA1.XMAPhaseCheck("Phase1",Phase1,MA_Method1);
   XMA2.XMAPhaseCheck("Phase2",Phase2,MA_Method2);

//---- memory distribution for variables' arrays  
   ArrayResize(Count,3);
   ArrayResize(Xma1,3);
   ArrayResize(Xma2,3);

//---- initialization of the variables arrays
   ArrayInitialize(Xma1,0.0);
   ArrayInitialize(Xma2,0.0);

//---- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);

//--- initializations of a variable for the indicator short name
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"Fast3(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(0);

//--- declaration of variables with a floating point  
   double price_,ATR[1];
//--- declaration of integer variables and getting already calculated bars
   int first,bar;

//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      first=2;                 // starting index for calculation of all bars
     }
   else
     {
      first=prev_calculated-1; // starting index for calculation of new bars
     }

//--- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;

      //--- getting the entry price price_
      price_=close[bar]-open[bar]+((close[bar-1]-open[bar-1])/MathSqrt(2))+((close[bar-2]-open[bar-2])/MathSqrt(3));

      //---- two calls of the XMASeries function. 
      Xma1[Count[0]]=XMA1.XMASeries(2,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price_,bar,false);
      Xma2[Count[0]]=XMA2.XMASeries(2,prev_calculated,rates_total,MA_Method2,Phase2,Length2,price_,bar,false);

      //---       
      if(Xma1[Count[2]]>Xma2[Count[2]]
         && Xma1[Count[1]]<Xma2[Count[1]]
         && Xma1[Count[0]]<Xma2[Count[0]]
         && Xma1[Count[2]]>=Xma1[Count[1]])
        {
         //---- copy newly appeared data in the ATR[] array
         if(CopyBuffer(ATR_Handle,0,rates_total-bar-1,1,ATR)<=0) return(0);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }

      //---       
      if(Xma1[Count[2]]<Xma2[Count[2]]
         && Xma1[Count[1]]>Xma2[Count[1]]
         && Xma1[Count[0]]>Xma2[Count[0]]
         && Xma1[Count[2]]<=Xma1[Count[1]])
        {
         //---- copy newly appeared data in the ATR[] array
         if(CopyBuffer(ATR_Handle,0,rates_total-bar-1,1,ATR)<=0) return(0);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }

      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,3);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
