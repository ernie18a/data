//+------------------------------------------------------------------+ 
//|                                                          VHF.mq5 | 
//|                             Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of the indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use blue violet color for the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "VHF"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int N=28;  // Indicator period
//+-----------------------------------+
//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double ExtLineBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as ring buffers
int Count[];
double Temp[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// return the current value of the price series by the link
                          int Size)    // number of the elements in the ring buffer
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
//| VHF indicator initialization function                            | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=N+1;

//---- memory distribution for variables' arrays  
   ArrayResize(Count,N);
   ArrayResize(Temp,N);

//---- initialization of the variables arrays
   ArrayInitialize(Count,0);
   ArrayInitialize(Temp,0.0);

//---- set ExtLineBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(ExtLineBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"VHF( N = ",N,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| JJRSX iteration function                                         | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
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
   if(rates_total<min_rates_total) return(0);
//---- declaration of variables with a floating point  
   double hh,ll,a,b,res;
//---- declaration of integer variables and getting already calculated bars
   int limit,bar,maxbar;
//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-2;                              // calculated number of all bars
   else limit=rates_total-prev_calculated;              // starting index for calculation of new bars

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   maxbar=rates_total-min_rates_total-1;

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      Temp[Count[0]]=MathAbs(close[bar]-close[bar+1]);

      if(bar<maxbar)
        {
         hh=high[ArrayMaximum(high,bar,N)];
         ll=low [ArrayMinimum(low, bar,N)];
         a = hh-ll;

         b=0.0;
         for(int kkk=0; kkk<N; kkk++) b+=Temp[Count[kkk]];

         if(b) res=a/b;
         else  res=0.0;
        }
      else res=EMPTY_VALUE;

      ExtLineBuffer[bar]=res;

      //---- recalculation of the elements positions in the Temp[] ring buffer
      if(bar>0) Recount_ArrayZeroPos(Count,N);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
