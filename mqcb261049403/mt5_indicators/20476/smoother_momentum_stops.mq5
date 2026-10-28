//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Smoother momentum stops"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_label1  "Smoother momentum support"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSkyBlue
#property indicator_width1  2
#property indicator_label2  "Smoother momentum support signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrSkyBlue
#property indicator_width2  1
#property indicator_label3  "Smoother momentum resistance"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_width3  2
#property indicator_label4  "Smoother momentum resistance signal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrOrangeRed
#property indicator_width4  1
//--- input parameters
input int                inpMomPeriod     = 20;           // Momentum period
input int                inpAvgPeriod     = 20;           // Average period
input ENUM_MA_METHOD     inpAvgMethod     = MODE_SMA;     // Average method
input ENUM_APPLIED_PRICE inpPrice         =  PRICE_CLOSE; // Price
input double             inpMultiplier    = 1.5;          // Stops distance
//--- buffers and global variables declarations
double stopu[],stopua[],stopd[],stopda[];
//--- induicator handles
int _maHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,stopu,INDICATOR_DATA);
   SetIndexBuffer(1,stopua,INDICATOR_DATA); PlotIndexSetInteger(0,PLOT_ARROW,159);
   SetIndexBuffer(2,stopd,INDICATOR_DATA);
   SetIndexBuffer(3,stopda,INDICATOR_DATA); PlotIndexSetInteger(1,PLOT_ARROW,159);
   _maHandle=iMA(_Symbol,0,inpAvgPeriod,0,inpAvgMethod,inpPrice); if(_maHandle==INVALID_HANDLE) { return(INIT_FAILED); }
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoother momentum stops("+(string)inpMomPeriod+","+(string)inpMomPeriod+")");
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
double _avgVal[1];
//
//---
//
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
   if(BarsCalculated(_maHandle)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int    _avgCopied=CopyBuffer(_maHandle,0,time[i],1,_avgVal);
      double _avg = (_avgCopied==1) ? _avgVal[0] : 0;
      double _mom = inpMultiplier*iSmoothMomentum(getPrice(inpPrice,open,close,high,low,i,rates_total),inpMomPeriod,i,rates_total);
      if(_mom>0)
        {
         stopu[i]=(i>0) ? stopu[i-1]==EMPTY_VALUE ? _avg-_mom : MathMax(stopu[i-1],_avg-_mom) : _avg-_mom; stopd[i]=EMPTY_VALUE; stopda[i]=EMPTY_VALUE;
         stopua[i]=(i>0) ?(stopu[i-1]==EMPTY_VALUE) ? stopu[i]: EMPTY_VALUE : EMPTY_VALUE;
        }
      if(_mom<0)
        {
         stopd[i]=(i>0) ? stopd[i-1]==EMPTY_VALUE ? _avg-_mom : MathMin(stopd[i-1],_avg-_mom) : _avg-_mom; stopu[i]=EMPTY_VALUE; stopua[i]=EMPTY_VALUE;
         stopda[i]=(i>0) ?(stopd[i-1]==EMPTY_VALUE) ? stopd[i]: EMPTY_VALUE : EMPTY_VALUE;
        }
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
   if(ArrayRange(workSmom,0)!=bars) ArrayResize(workSmom,bars); instanceNo*=_smomInstancesSize;
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
