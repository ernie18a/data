//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Synthetic smoothed RSI"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Synthetic smoothed RSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_level1  80
#property indicator_level2  20
//--- input parameters
input int                inpEmaPeriod1   = 48;  // Ema 1 period
input int                inpRsiPeriod1   = 32;  // Rsi 1 period
input int                inpEmaPeriod2   = 24;  // Ema 2 period
input int                inpRsiPeriod2   = 16;  // Rsi 2 period
input int                inpEmaPeriod3   = 12;  // Ema 3 period
input int                inpRsiPeriod3   =  8;  // Rsi 3 period
input ENUM_APPLIED_PRICE inpPrice= PRICE_CLOSE; // Price 
input int                inpSignalPeriod=8;
//--- buffers declarations
double val[],valc[],signal[],signalc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_DATA);
   SetIndexBuffer(3,signalc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Synthetic smoothed RSI ("+(string)inpRsiPeriod1+","+(string)inpEmaPeriod1+","+(string)inpRsiPeriod2+","+(string)inpEmaPeriod2+","+(string)inpRsiPeriod3+","+(string)inpEmaPeriod3+")");
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
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      double price= getPrice(inpPrice,open,close,high,low,i,rates_total);
      double rsi1 = iSRsi(iEma(price,inpEmaPeriod1,i,rates_total,0),inpRsiPeriod1,i,rates_total,0);
      double rsi2 = iSRsi(iEma(price,inpEmaPeriod2,i,rates_total,1),inpRsiPeriod2,i,rates_total,1);
      double rsi3 = iSRsi(iEma(price,inpEmaPeriod3,i,rates_total,2),inpRsiPeriod3,i,rates_total,2);
      val[i]     = (rsi3+2.0*rsi2+3.0*rsi1)/6.0;
      signal[i]  = iEma(val[i],inpSignalPeriod,i,rates_total,3);
      valc[i]    = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 : (i>0) ? valc[i-1] : 0;
      signalc[i] = valc[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define rsiInstances 3
#define rsiInstancesSize 2
double workSRsi[][rsiInstances*rsiInstancesSize];
#define _price  0
#define _value  1
//
//---
//
double iSRsi(double price,int period,int r,int bars,int instanceNo)
  {
   if(ArrayRange(workSRsi,0)!=bars) ArrayResize(workSRsi,bars); int z=instanceNo*rsiInstancesSize;
//
//---
//
   workSRsi[r][z+_price]=price;
   double rsi = 0;
   double cu  = 0;
   double cd  = 0;

   for(int k=0;(r-k)>0 && k<period; k++)
     {
      double diff=workSRsi[r-k][z+_price]-workSRsi[r-k-1][z+_price];
      if(diff > 0) cu += diff;
      if(diff < 0) cd -= diff;
     }
   workSRsi[r][z+_value]=((cu+cd)!=0) ? 50.0*((cu-cd)/(cu+cd)+1.0) : 0;
   return(r>1 ? (workSRsi[r][z+_value]+2.0*workSRsi[r-1][z+_value]+workSRsi[r-2][z+_value])/4.0 : workSRsi[r][z+_value]);
  };
//
//---
//
double workEma[][4];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
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
