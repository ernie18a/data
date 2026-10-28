//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Smoother momentum"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Smoother momentum"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrDodgerBlue
#property indicator_width1  2
//--- input parameters
input int                inpMomPeriod     = 20;           // Momentum period
input ENUM_APPLIED_PRICE inpPrice         =  PRICE_CLOSE; // Price
//--- buffers and global variables declarations
double val[],valc[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoother momentum ("+(string)inpMomPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]  = iSmoothMomentum(getPrice(inpPrice,open,close,high,low,i,rates_total),inpMomPeriod,i,rates_total);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _smomInstances 1
#define _smomInstancesSize 3
double workSmom[][_smomInstances*_smomInstancesSize];
#define _ema0 0
#define _ema1 1
#define _ema2 2
//
//---
//
double iSmoothMomentum(double price,double period,int r,int bars,int instanceNo=0)
  {
      static int m_arraySize=0;
             if (m_arraySize<bars)
             {
                 int _res = ArrayResize(workSmom,bars+500);
                 if (_res<=bars) return(0);
                     m_arraySize = _res;
             }
   
   instanceNo*=_smomInstancesSize;
   workSmom[r][_ema0+instanceNo] = price;
   workSmom[r][_ema1+instanceNo] = price;
   workSmom[r][_ema2+instanceNo] = price;
   if(r>0)
     {
      double alphar=2.0/(1.0+period);
      double alphad=2.0/(1.0+MathSqrt(period));
      workSmom[r][_ema0+instanceNo]=workSmom[r-1][_ema0+instanceNo]+alphar*(price                        -workSmom[r-1][_ema0+instanceNo]);
      workSmom[r][_ema1+instanceNo]=workSmom[r-1][_ema1+instanceNo]+alphad*(price                        -workSmom[r-1][_ema1+instanceNo]);
      workSmom[r][_ema2+instanceNo]=workSmom[r-1][_ema2+instanceNo]+alphad*(workSmom[r][_ema1+instanceNo]-workSmom[r-1][_ema2+instanceNo]);
     }
   return(workSmom[r][_ema2+instanceNo]-workSmom[r][_ema0+instanceNo]);
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
