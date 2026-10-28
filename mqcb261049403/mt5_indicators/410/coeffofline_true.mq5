//+------------------------------------------------------------------+
//|                                             CoeffofLine_true.mq5 |
//|                                       Ramdass - Conversion only  |
//+------------------------------------------------------------------+
#property copyright "Ramdass - Conversion only"
#property link ""
//---- version
#property version   "1.00"
//---- plot in a separate window
#property indicator_separate_window
//---- one indicator buffer is used
#property indicator_buffers 1
//---- one graphic plot is used
#property indicator_plots   1
//---- draw as a histogram
#property indicator_type1   DRAW_HISTOGRAM
//---- indicator line color MediumSlateBlue
#property indicator_color1  MediumSlateBlue
//---- indicator line width
#property indicator_width1  2

//---- input parameters
input int SMMAPeriod=5; //averaging period

//---- declaration of dynamic array, used as an indicator buffer
double ExtLineBuffer[];
//---- indicator handle
int Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- set ExtLineBuffer as indicator buffer
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);

//---- set plot draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,2*SMMAPeriod+3);

//---- indexing as timeseries
   ArraySetAsSeries(ExtLineBuffer,true);

//---- create iMA indicator
   Handle=iMA(NULL,0,SMMAPeriod,3,MODE_SMMA,PRICE_MEDIAN);
   if(Handle==INVALID_HANDLE)
   {
      Print(" Error in creating of SMMA indicator");
      return(-1);
   }
   
   return(0);
//----
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // rates total
                const int prev_calculated,// bars, calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // high
                const double& low[],      // low
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {  
//---- check bars
   if(BarsCalculated(Handle)<rates_total || rates_total<2*SMMAPeriod-1)
      return(0);

//---- declaration of local variables
   int to_copy,limit,Count,bar,cnt,iii,ndot=SMMAPeriod;
   double Sum,SMMA[],TYVar,ZYVar,TIndicatorVar,ZIndicatorVar,M,N,AY,AIndicator;
   
//---- set indexing as timeseries
   ArraySetAsSeries(SMMA,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- set starting bar for calculations (limit)
   if(prev_calculated>rates_total || prev_calculated<=0) // at first call
     {
      limit=rates_total-SMMAPeriod-ndot-1; // starting bar
      to_copy=rates_total-SMMAPeriod;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting bar
      to_copy=limit+ndot+1;
     }

//--- copy data from the SMMA indicator to SMMA[] array
   if(CopyBuffer(Handle,0,0,to_copy,SMMA)<=0) return(0);

//---- main loop
   for(bar=limit; bar>=0; bar--)
     {
      TYVar = 0;
      ZYVar = 0;
      N = 0;
      M = 0;
      TIndicatorVar = 0;
      ZIndicatorVar = 0;

      //---- summation loop
      for(cnt=ndot; cnt>=1; cnt--) // n=5 -  five points
        {
         iii = bar + cnt - 1;
         Sum = (high[iii] + low[iii]) / 2;
         Count=SMMAPeriod+1-cnt;
         //ZYVar += Sum * Count; 
         ZYVar+=((high[bar+cnt-1]+low[bar+cnt-1])/2)*(6-cnt);
         TYVar+= Sum;
         N+=cnt*cnt; //equal to 55
         M+=cnt; //equal to 15
         ZIndicatorVar += SMMA[iii] * Count;
         TIndicatorVar += SMMA[iii];
        }

      AY=(TYVar+(N-2*ZYVar)*ndot/M)/M;
      AIndicator = (TIndicatorVar + (N - 2 * ZIndicatorVar) * ndot / M) / M;
      if(Symbol()=="EURUSD" || Symbol()=="GBPUSD" || Symbol()=="USDCAD" || Symbol()=="USDCHF"
         || Symbol()=="EURGBP" || Symbol()=="EURCHF" || Symbol()=="AUDUSD"
         || Symbol()=="GBPCHF")
        {ExtLineBuffer[bar]=(-1000)*MathLog(AY/AIndicator);}
      else {ExtLineBuffer[bar]=(1000)*MathLog(AY/AIndicator);}
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
