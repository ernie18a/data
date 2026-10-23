//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "TrendStrength rsx"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "rsx"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "trend up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2
#property indicator_label3  "trend down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_width3  2
//--- input parameters
input double             inpPeriod   = 32;           // Period
input double             inpStrength = 4.236;        // Strength
input ENUM_APPLIED_PRICE inpPrice    = PRICE_MEDIAN; // Price

//--- indicator buffers
double rsx[],valu[],vald[],smin[],smax[],trend[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,rsx,INDICATOR_DATA);
   SetIndexBuffer(1,valu,INDICATOR_DATA);
   SetIndexBuffer(2,vald,INDICATOR_DATA);
   SetIndexBuffer(3,smin,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,smax,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,trend,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"TrendStrength (rsx) ("+(string)inpPeriod+","+(string)inpStrength+")");
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
      rsx[i]   = iRsx(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);
      valu[i]  = EMPTY_VALUE;
      vald[i]  = EMPTY_VALUE;
      trend[i] = 0;
      if(i>0)
        {
         double hrsx = rsx[i];
         double lrsx = rsx[i];
         if(rsx[i] > rsx[i-1]) { hrsx = rsx[i];   lrsx = rsx[i-1]; }
         if(rsx[i] < rsx[i-1]) { hrsx = rsx[i-1]; lrsx = rsx[i];   }

         double delta=hrsx-lrsx;
         smin[i]   = rsx[i] - inpStrength*delta;
         smax[i]   = rsx[i] + inpStrength*delta;
         trend[i]  = trend[i-1];
         if(rsx[i]>smax[i-1]) trend[i]= 1;
         if(rsx[i]<smin[i-1]) trend[i]=-1;
         if(trend[i]>0) { if(smin[i]<smin[i-1]) smin[i]=smin[i-1]; valu[i]=smin[i]; }
         if(trend[i]<0) { if(smax[i]>smax[i-1]) smax[i]=smax[i-1]; vald[i]=smax[i]; }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _rsxInstances      1
#define _rsxInstancesSize 13
double workRsx[][_rsxInstances*_rsxInstancesSize];
#define _price  0
#define _change 1
#define _changa 2
//
//---
//
double iRsx(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsx,0)!=bars) ArrayResize(workRsx,bars); int z=instanceNo*_rsxInstancesSize;
//
//---
//
   workRsx[r][z+_price]=price;
   double Kg=(3.0)/(2.0+period),Hg=1.0-Kg;
   if(r<period) { for(int k=1; k<13; k++) workRsx[r][k+z]=0; return(50); }
//
//---
//
   double mom = workRsx[r][_price+z]-workRsx[r-1][_price+z];
   double moa = MathAbs(mom);
   for(int k=0; k<3; k++)
     {
      int kk=k*2;
      workRsx[r][z+kk+1] = Kg*mom                + Hg*workRsx[r-1][z+kk+1];
      workRsx[r][z+kk+2] = Kg*workRsx[r][z+kk+1] + Hg*workRsx[r-1][z+kk+2]; mom = 1.5*workRsx[r][z+kk+1] - 0.5 * workRsx[r][z+kk+2];
      workRsx[r][z+kk+7] = Kg*moa                + Hg*workRsx[r-1][z+kk+7];
      workRsx[r][z+kk+8] = Kg*workRsx[r][z+kk+7] + Hg*workRsx[r-1][z+kk+8]; moa = 1.5*workRsx[r][z+kk+7] - 0.5 * workRsx[r][z+kk+8];
     }
   return(MathMax(MathMin((mom/MathMax(moa,DBL_MIN)+1.0)*50.0,100.00),0.00));
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
