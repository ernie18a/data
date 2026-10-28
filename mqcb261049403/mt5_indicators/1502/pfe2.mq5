//+------------------------------------------------------------------+ 
//|                                                         PFE2.mq5 | 
//|                               Copyright © 2007,                  | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, "
#property link "" 
//---- indicator version number
#property version   "1.01"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a six-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the six-color histogram are as follows
#property indicator_color1 clrRed,clrMagenta,clrMediumVioletRed,clrTeal,clrDeepSkyBlue,clrLime
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "PFE2"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1 +70.0
#property indicator_level2   0.0
#property indicator_level3 -70.0
#property indicator_levelcolor clrBlueViolet
#property indicator_levelstyle STYLE_DASHDOTDOT

//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input uint Length=7; //smoothing depth 
//+----------------------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total,size;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//---- declaration of global variables
int Count[];
double SMA[];
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
//|  Getting the averaging of a price series values                  |
//+------------------------------------------------------------------+   
double Get_SMA(const double  &Array[],int index)
  {
//----
   double sum=0;
   for(int kkk=int(index-Length-1); kkk<=index; kkk++) sum+=Array[kkk];
//----
   return(sum/Length);
  }
//+------------------------------------------------------------------+    
//| PFE2 indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   size=11;
   min_rates_total=int(Length+size);
   

//---- memory allocation for arrays of variables  
   ArrayResize(Count,size);
   ArrayResize(SMA,size);

   ArrayInitialize(Count,0);
   ArrayInitialize(SMA,0.0);

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"PFE2");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| PFE2 iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,     // amount of history in bars at the current tick
                const int prev_calculated, // amount of history in bars at the previous tick
                const int begin,           // number of beginning of reliable counting of bars
                const double &price[]      // price array for calculation of the indicatorа
                )
  {
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<min_rates_total+begin) return(0);

///---- declaration of local variables 
   int first,bar;
   double PFE,c2c,fraceff,dSMA,res;
   static int min_rates;
  
//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      min_rates=min_rates_total+begin;
      first=min_rates;  // starting number for calculation of all bars
      //---- increase the position of the beginning of data by 'begin' bars as a result of calculation using data of another indicator
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      SMA[Count[0]]=Get_SMA(price,bar);

      c2c=0.0;
      for(int rrr=1; rrr<10; rrr++) c2c+=MathSqrt(MathPow(SMA[Count[rrr+1]]-SMA[Count[rrr]],2)+1);
      if(!c2c) c2c=1.0*_Point;

      dSMA=SMA[Count[0]]-SMA[Count[9]];
      PFE = MathSqrt(MathPow(dSMA,2)+100);
      res=(PFE/c2c)*100;

      if(dSMA>0) fraceff=MathRound(+res);
      else  fraceff=MathRound(-res);

      if(bar>min_rates) IndBuffer[bar]=MathRound((fraceff*0.333)+(IndBuffer[bar-1]*(1-0.333))); 
      else IndBuffer[bar]=fraceff;

      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,size);
     }

   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//---- Main indicator coloring loop
   for(bar=first; bar<rates_total; bar++)
     {
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) ColorIndBuffer[bar]=5;
         if(IndBuffer[bar]==IndBuffer[bar-1]) ColorIndBuffer[bar]=4;
         if(IndBuffer[bar]<IndBuffer[bar-1]) ColorIndBuffer[bar]=3;
        }

      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) ColorIndBuffer[bar]=0;
         if(IndBuffer[bar]==IndBuffer[bar-1]) ColorIndBuffer[bar]=1;
         if(IndBuffer[bar]>IndBuffer[bar-1]) ColorIndBuffer[bar]=2;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
