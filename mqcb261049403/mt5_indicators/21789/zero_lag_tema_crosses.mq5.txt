//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Zero lag TEMA fast"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
#property indicator_label2  "Zero lag TEMA slow"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2
//--- input parameters
input double             inpPeriodFast = 22;          // Fast period
input double             inpPeriodSlow = 144;         // Slow period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],vals[],valsc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,vals,INDICATOR_DATA);
   SetIndexBuffer(3,valsc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero lag TEMA crosses ("+(string)inpPeriodFast+","+(string)inpPeriodSlow+")");
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
      double price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i] =iZlTema(price,inpPeriodFast,i,rates_total,0);
      vals[i]=iZlTema(price,inpPeriodSlow,i,rates_total,1);
      valc[i]= (val[i]>vals[i]) ? 2 :(val[i]<vals[i]) ? 1 : (i>0) ? valc[i-1]: 0;
      valsc[i] = valc[i];
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _zltmaInstances 2
#define _zltmaInstancesSize 6

double workZlTema[][_zltmaInstances*_zltmaInstancesSize];
#define _ztema11 0
#define _ztema21 1
#define _ztema31 2
#define _ztema12 3
#define _ztema22 4
#define _ztema32 5
//
//---
//
double iZlTema(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(period<=1) return(price);
   if(ArrayRange(workZlTema,0)!=bars) ArrayResize(workZlTema,bars); instanceNo*=6;
   workZlTema[r][_ztema11+instanceNo] = price;
   workZlTema[r][_ztema21+instanceNo] = price;
   workZlTema[r][_ztema31+instanceNo] = price;
   workZlTema[r][_ztema12+instanceNo] = price;
   workZlTema[r][_ztema22+instanceNo] = price;
   workZlTema[r][_ztema32+instanceNo] = price;
   double alpha=2.0/(1.0+period);
   if(r>0)
     {
      workZlTema[r][_ztema11+instanceNo] = workZlTema[r-1][_ztema11+instanceNo]+alpha*(price                             -workZlTema[r-1][_ztema11+instanceNo]);
      workZlTema[r][_ztema21+instanceNo] = workZlTema[r-1][_ztema21+instanceNo]+alpha*(workZlTema[r][_ztema11+instanceNo]-workZlTema[r-1][_ztema21+instanceNo]);
      workZlTema[r][_ztema31+instanceNo] = workZlTema[r-1][_ztema31+instanceNo]+alpha*(workZlTema[r][_ztema21+instanceNo]-workZlTema[r-1][_ztema31+instanceNo]);
      double tema1=workZlTema[r][_ztema31+instanceNo]+3.0*(workZlTema[r][_ztema11+instanceNo]-workZlTema[r][_ztema21+instanceNo]);

      workZlTema[r][_ztema12+instanceNo] = workZlTema[r-1][_ztema12+instanceNo]+alpha*(tema1                             -workZlTema[r-1][_ztema12+instanceNo]);
      workZlTema[r][_ztema22+instanceNo] = workZlTema[r-1][_ztema22+instanceNo]+alpha*(workZlTema[r][_ztema12+instanceNo]-workZlTema[r-1][_ztema22+instanceNo]);
      workZlTema[r][_ztema32+instanceNo] = workZlTema[r-1][_ztema32+instanceNo]+alpha*(workZlTema[r][_ztema22+instanceNo]-workZlTema[r-1][_ztema32+instanceNo]);
      double tema2=workZlTema[r][_ztema32+instanceNo]+3.0*(workZlTema[r][_ztema12+instanceNo]-workZlTema[r][_ztema22+instanceNo]);
      return(2.0*tema1-tema2);
     }
   return(price);
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
