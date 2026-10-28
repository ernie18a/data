//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "KAMA with filter"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "KAMA with filter"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input int                inpPeriod           = 14;          // Period
input int                inpFastPeriod       =  2;          // Fast end period
input int                inpSlowPeriod       = 30;          // Slow end period
input double             inpPower            =  2;          // Smooth power
input int                inpFilter           = 50;          // Filter
input int                inpFilterPeriod     =  4;          // Filter period
input double             inpFilterDifference = 50;          // Filter difference
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],ama[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ama,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"KAMA with filter ("+(string)inpPeriod+")");
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
      ama[i] = iKama(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,inpFastPeriod,inpSlowPeriod,inpPower,i,open,close,high,low,rates_total);
      val[i] = ama[i];
      //
      //---
      //
      if(inpFilter>0)
        {
         double sAmaDiff    = 0; for(int k=0; k<inpSlowPeriod && (i-k-1)>=0; k++) sAmaDiff += MathAbs(ama[i-k]-ama[i-k-1]);
         double cAmaDiff    = (i>0) ? ama[i]-ama[i-1] : 0;
         double aAmaDiff    = MathAbs(cAmaDiff);
         double filterValue = NormalizeDouble(inpFilter*sAmaDiff/(100.0*inpSlowPeriod),_Digits);

         int _start=MathMax(i-inpFilterPeriod,0);
         if(cAmaDiff>0)
            if(cAmaDiff<filterValue && high[i]<=(high[ArrayMaximum(high,_start,inpFilterPeriod)]+inpFilterDifference*_Point))
               val[i]=(i>0) ? val[i-1]: ama[i];
         if(cAmaDiff<0)
            if(aAmaDiff<filterValue && low[i]>=(low[ArrayMinimum(low,_start,inpFilterPeriod)]-inpFilterDifference*_Point))
               val[i]=(i>0) ? val[i-1]: ama[i];
        }
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define amaInstances     1
#define amaInstancesSize 3
double workAma[][amaInstances*amaInstancesSize];
#define _diff  0
#define _kama  1
#define _price 2
//
//---
//
double iKama(double price,int period,double fast,double slow,double power,int i,const double &open[],const double &close[],const double &high[],const double &low[],int bars,int instanceNo=0)
  {
   if(ArrayRange(workAma,0)!=bars) ArrayResize(workAma,bars);  int r=i; instanceNo*=amaInstancesSize;
   double fastend = (2.0 /(fast + 1));
   double slowend = (2.0 /(slow + 1));
//
//---
//
   double efratio=1; workAma[r][instanceNo+_price]=price;
   double signal = (r>=period) ? MathAbs(price-workAma[r-period][instanceNo+_price]) : 0;
   double noise  = 0;
   workAma[r][instanceNo+_diff]=(r>0) ? MathAbs(price-workAma[r-1][instanceNo+_price]) : 0;
   for(int k=0; k<period && r-k>=0; k++)
      noise+=workAma[r-k][instanceNo+_diff];
//
//---
//
   if(noise!=0)
      efratio = signal/noise;
   else  efratio = 1;
   double smooth=MathPow(efratio*(fastend-slowend)+slowend,power);
   workAma[r][instanceNo+_kama]=(r>0) ? workAma[r-1][instanceNo+_kama]+smooth*(price-workAma[r-1][instanceNo+_kama]) : price;
   return(workAma[r][instanceNo+_kama]);
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
