//+------------------------------------------------------------------+
//|                                           AdaptiveCyberCycle.mq5 |
//|                                                                  |
//| Adaptive Cyber Cycle                                             |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Coded by Witold Wozniak"
//---- author of the indicator
#property link      "www.mqlsoft.com"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Cycle indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- red color is used as the color of the indicator line
#property indicator_color1  Red
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Adaptive Cyber Cycle"
//+----------------------------------------------+
//|  Trigger indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator signal line
#property indicator_color2  Blue
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Trigger"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input double Alpha=0.07;  // Indicator ratio 
input int Shift=0;        // Horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double CycleBuffer[];
double TriggerBuffer[];
//---- declaration of integer variables for the indicators handles
int CP_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as ring buffers
int Count[];
double Smooth[],Price[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[]) // return the current value of the price series by the link
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=7;
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=7+6;
//---- memory distribution for variables' arrays  
   ArrayResize(Count,7);
   ArrayResize(Smooth,7);
   ArrayResize(Price,7);
//---- initialization of the variables arrays
   ArrayInitialize(Count,0);
   ArrayInitialize(Smooth,0.0);
   ArrayInitialize(Price,0.0);
//---- getting handle of the CyclePeriod indicator
   CP_Handle=iCustom(NULL,0,"CyclePeriod",Alpha);
   if(CP_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the CyclePeriod indicator");
      return(1);
     }
//---- set CycleBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,CycleBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,3*min_rates_total);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(CycleBuffer,true);

//---- set TriggerBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,3*min_rates_total+1);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(TriggerBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Adaptive Cyber Cycle(",DoubleToString(Alpha,4),", ",Shift,")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   return(0);
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
   if(BarsCalculated(CP_Handle)<rates_total || rates_total<min_rates_total) return(0);

//---- declarations of local variables 
   int MaxBar,limit,bar;
   int bar0,bar1,bar2,bar3;
   double K0,K1,K2,K3,period[1],alpha1;

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-2;                              // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;              // starting index for calculation of new bars

   MaxBar=rates_total-min_rates_total-3;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar0=Count[0];
      bar1=Count[1];
      bar2=Count[2];
      bar3=Count[3];

      Price[bar0]=(high[bar]+low[bar])/2.0;
      Smooth[bar0]=(Price[bar0]+2.0*Price[bar1]+2.0*Price[bar2]+Price[bar3])/6.0;

      if(bar<=MaxBar)
        {
         //--- copy newly appeared data in the array
         if(CopyBuffer(CP_Handle,0,bar,1,period)<=0) return(0);

         //---- initialization of variables
         alpha1=2.0/(period[0]+1.0);
         K0=MathPow((1.0 - 0.5*alpha1),2);
         K1=2.0;
         K2=K1 *(1.0 - alpha1);
         K3=MathPow((1.0 - alpha1),2);

         CycleBuffer[bar]=K0*(Smooth[bar0]-K1*Smooth[bar1]+Smooth[bar2])+K2*CycleBuffer[bar+1]-K3*CycleBuffer[bar+2];
        }
      else CycleBuffer[bar]=(Price[bar0]-2.0*Price[bar1]+Price[bar2])/4.0;

      TriggerBuffer[bar]=CycleBuffer[bar+1];
      if(bar>0) Recount_ArrayZeroPos(Count);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
