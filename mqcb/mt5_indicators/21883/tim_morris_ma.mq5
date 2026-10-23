//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Tim Morris MA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
input int                Length    = 10;           // Inverse of driving coefficient (length)
input double             Damping   =  5;           // Smoothing percent
input double             Noise     = 30;           // Noise (in pips)
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE;  // Price
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Tim Morris MA ("+(string)Length+")");
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
   double _noise = Noise*_Point*MathPow(10,_Digits%2);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      val[i]=iTmSmooth(getPrice(inpPrice,open,close,high,low,i,rates_total),Damping,_noise,Length,i,rates_total);
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double wrkTm[][3];
#define _price 0
#define _y1    1
#define _y2    2
//
//---
//
double iTmSmooth(double price, double damping, double noise, double length, int i, int bars)
{
   if (ArrayRange(wrkTm,0) != bars) ArrayResize(wrkTm,bars);
   if (length<=1) return(price);

   //
   //
   //
   //
   //

      wrkTm[i][_price] = price;

         double y1 = i>0 ? wrkTm[i-1][_y1] : 0;
         double y2 = i>0 ? wrkTm[i-1][_y2] : 0;
         
         double err = (wrkTm[i][_price]-2.0*y1+y2)/noise; 
         double drv = MathMax(MathMin((1.0/length)*err*err+(1.0/length)*MathAbs(err),0.5),0.0);
         double dmp = MathMax(MathMin((1.0/length)*MathAbs(y1-y2)/noise + damping/100.0,1.0),0.0);
         
         //
         //
         //
         //
         //
         
      double tmAvg  = y1 + noise*err*drv + (y1-y2)*(1.0-dmp);
      wrkTm[i][_y1] = tmAvg;
      wrkTm[i][_y2] = y1;
      return(tmAvg);
      #undef _price
      #undef _y1
      #undef _y2
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
