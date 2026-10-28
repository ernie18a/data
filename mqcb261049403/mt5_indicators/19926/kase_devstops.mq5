//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Kase dev-stops"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   4
#property indicator_label1  "Dev-stop 1"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Dev-stop 2"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Dev-stop 3"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Main dev-stop"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_width4  2
//--- input parameters
input int                inpDesPeriod  = 20;          // Dev-stop period
input int                inpSlowPeriod = 21;          // Dev-stop slow period
input int                inpFastPeriod = 10;          // Dev-stop fast period
input double             inpStdDev1    = 0.0;         // Deviation 1
input double             inpStdDev2    = 1.0;         // Deviation 2
input double             inpStdDev3    = 2.2;         // Deviation 3
input double             inpStdDev4    = 3.6;         // Deviation 4
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 

//--- buffers and global variables declarations
double val[],valc[],val1[],val1c[],val2[],val2c[],val3[],val3c[],trend[],price[],pricc[],range[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val1,INDICATOR_DATA);
   SetIndexBuffer(3,val1c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,val2,INDICATOR_DATA);
   SetIndexBuffer(5,val2c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,val3,INDICATOR_DATA);
   SetIndexBuffer(7,val3c,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,price,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,pricc,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,range,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Kase dev-stop ("+(string)inpDesPeriod+","+(string)inpSlowPeriod+","+(string)inpFastPeriod+")");
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
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);

   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      pricc[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);
      double average1 = iSma(pricc[i],inpFastPeriod,i,rates_total,0);
      double average2 = iSma(pricc[i],inpSlowPeriod,i,rates_total,1);

      trend[i] = (average1>average2) ? 1 : (average1<average2) ? -1 : (i>0) ? trend[i-1] : 0;
      price[i] = (i>0) ? price[i-1] : pricc[i];
      if (i>0 && trend[i]!=trend[i-1])
         if(trend[i]==1)
            price[i] = high[i];
      else  price[i] = low[i];
      if(trend[i]>0) price[i] = MathMax(price[i],high[i]);
      if(trend[i]<0) price[i] = MathMin(price[i],low[i]);

      double max = (i>2) ? MathMax(MathMax(high[i],high[i-1]),pricc[i-2]) : 0;
      double min = (i>2) ? MathMin(MathMin(low[i],low[i-1])  ,pricc[i-2]) : 0;
      range[i]=max-min;
      double avg = range[i];
      int n=1; for(; n<inpDesPeriod && (i-n)>=0; n++) avg += range[i-n]; avg /= n;
      double dev = MathPow(range[i]-avg,2);
      for(n=1; n<inpDesPeriod && (i-n)>=0; n++) dev+=(range[i-n]-avg)*(range[i-n]-avg); dev=MathSqrt(dev/n);

      val [i] = price[i]+(-1)*trend[i]*(avg+(inpStdDev1*dev));
      val1[i] = price[i]+(-1)*trend[i]*(avg+(inpStdDev2*dev));
      val2[i] = price[i]+(-1)*trend[i]*(avg+(inpStdDev3*dev));
      val3[i] = price[i]+(-1)*trend[i]*(avg+(inpStdDev4*dev));
      valc[i] = val1c[i] = val2c[i] = val3c[i] = (trend[i] == 1) ? 1 : (trend[i] == -1) ? 2 : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workSma[][2];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSma(double tprice,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=tprice;
   double avg=tprice; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>0 && i<_bars)
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
