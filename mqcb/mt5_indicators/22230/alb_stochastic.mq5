//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Adaptive lookback stochastic"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Stochastic"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width1  2
//--- input parameters
input int                inpAlbSwingCount = 5;           // Alb swing count
input double             inpAlbSpeed      = 0.1;         // Alb "speed"
input int                inpSlowing       = 3;           // Slowing/smoothing period
input ENUM_APPLIED_PRICE inpPrice         = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Alb adaptive stochastic ("+(string)inpAlbSwingCount+","+(string)inpAlbSpeed+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i]  = iStoch(_price,_price,_price,(int)iAlb(high,low,inpAlbSwingCount,inpAlbSpeed,i,rates_total),inpSlowing,i,rates_total);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double _albWork[];
//
//---
//
double iAlb(const double& high[],const double& low[], int swingCount, double speed, int i, int bars)
{
   if (ArraySize(_albWork)!=bars) ArrayResize(_albWork,bars); _albWork[i]=0;
      if (i>3 && high[i]>high[i-1] && high[i-1]>high[i-2] && low[i-2] < low[i-3] && low[i-3] < low[i-4]) _albWork[i] = -1;
      if (i>3 && low[i] < low[i-1] && low[i-1] < low[i-2] && high[i-2]>high[i-3] && high[i-3]>high[i-4]) _albWork[i] =  1;
   
      //
      //---
      //
      
      int k=i,n = 0;
         for (; k>=0 && (n<swingCount); k--) if(_albWork[k]!=0) n++;
   return(MathMax(MathRound((speed!=0 && swingCount!=0) ? double(i-k)/swingCount/speed : double(i-k)/swingCount),1));
}
//
//---
//
#define _stochInstances 1
#define _stochInstancesSize 5
double workSto[][_stochInstances*_stochInstancesSize];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
//
//---
//
double iStoch(double priceR,double priceH,double priceL,int period,int slowing,int i, int bars, int instanceNo=0)
  {
   if(ArrayRange(workSto,0)!=bars) ArrayResize(workSto,bars); instanceNo*=_stochInstancesSize;
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
   for(int k=1; k<period && (i-k)>=0; k++)
     {
      workSto[i][_mi+instanceNo] = MathMin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
      workSto[i][_ma+instanceNo] = MathMax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
     }
   double sumlow  = 0.0;
   double sumhigh = 0.0;
   for(int k=0; k<slowing && (i-k)>=0; k++)
     {
      sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
      sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
     }
   if(sumhigh!=0.0)
         return(100.0*sumlow/sumhigh);
   else  return(0);
  }  
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
