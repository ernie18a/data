//+------------------------------------------------------------------+ 
//|                                                          HVR.mq5 | 
//|                                         Copyright © 2005, Albert | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Albert"
#property link ""
//---- Indicator version
#property version   "1.01"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- indigo color is used as the color of the indicator line
#property indicator_color1 clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 1
#property indicator_width1  1
//---- displaying of the the indicator label
#property indicator_label1  "HVR"
//+-----------------------------------+
//|  Declaration of enumerations      |
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
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input Applied_price_ IPC=PRICE_CLOSE_; //Price constant
//+-----------------------------------+

//---- declaration of a dynamic array that
//---- will be used as an indicator buffer
double ExtLineBuffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total,N;
//--- declaration of dynamic arrays that
//---- will be used as ring buffers
int Count[];
double diff[],x6[],x100[];
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by reference
                          int Size)    // number of the elements in the ring buffer
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
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   N=100;
   min_rates_total=N;

//---- memory distribution for variables' arrays  
   ArrayResize(Count,N);
   ArrayResize(diff,N);
   ArrayResize(x100,N);
   ArrayResize(x6,N);

//---- initialization of the variables arrays
   ArrayInitialize(Count,0);
   ArrayInitialize(diff,0.0);
   ArrayInitialize(x100,0.0);
   ArrayInitialize(x6,0.0);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer,true);

//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"HVR");
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- initialization end
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
   if(rates_total<min_rates_total) return(0);

//--- declaration of variables with a floating point  
   double  hv6,hv100,mean6,mean100;
//--- declaration of integer variables and getting already calculated bars
   int limit,bar,bar0,i;

//--- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      limit=rates_total-2;                              // calculated number of all bars
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar0=Count[0];
      diff[bar0]=MathLog(PriceSeries(IPC,bar,open,low,high,close)/PriceSeries(IPC,bar+1,open,low,high,close));

      for(i=0; i<6; i++) x6[bar0]=diff[Count[i]];
      for(i=0; i<100; i++) x100[bar0]=diff[Count[i]];

      mean6=0;
      for(i=0; i<6; i++) mean6+=x6[Count[i]];
      mean6/=6;

      mean100=0;
      for(i=0; i<100; i++) mean100+=x100[Count[i]];
      mean100/=100;

      hv6=0;
      for(i=0; i<6; i++) hv6+=MathPow(x6[Count[i]]-mean6,2);
      hv6=MathSqrt(hv6/5)*7.211102550927978586238442534941;

      hv100=0;
      for(i=0; i<100; i++) hv100+=MathPow(x100[Count[i]]-mean100,2);
      hv100=MathSqrt(hv100/99)*7.211102550927978586238442534941;

      if(hv100) ExtLineBuffer[bar]=hv6/hv100;
      else ExtLineBuffer[bar]=ExtLineBuffer[bar+1];

      //---- recalculation of the elements positions in ring buffers
      if(bar>0) Recount_ArrayZeroPos(Count,N);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Getting values of a price time series                            |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,   // Applied price
                   uint   bar,           // Index of shift relative to the current bar for a specified number of periods back or forward).
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//---
   switch(applied_price)
     {
      //--- price constants from the ENUM_APPLIED_PRICE enumeration
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);
      //---                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //---                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //---         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //---         
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];
         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //---
      default: return(Close[bar]);
     }
//---
  }
//+------------------------------------------------------------------+
