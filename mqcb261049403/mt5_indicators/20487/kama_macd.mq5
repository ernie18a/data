//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "KAMA macd"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "KAMA macd filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'218,231,226',C'255,221,217'
#property indicator_label2  "Macd value"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrSandyBrown
#property indicator_width2  2
#property indicator_label3  "Macd signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_width3  1

//--- input parameters
input int                inpFastPeriod    = 19;          // Fast DEMA period
input int                inpSlowPeriod    = 39;          // Slow DEMA period
input int                inpSignalPeriod  = 9;           // Signal period
input int                inpFastEndPeriod =  2;          // Fast end period
input int                inpSlowEndPeriod = 30;          // Slow end period
input double             inpPower         =  2;          // Smooth power
input ENUM_APPLIED_PRICE inpPrice         = PRICE_CLOSE; // Price 
//--- buffers declarations
double fillu[],filld[],val[],valc[],signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,signal,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"KAMA macd ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+")");
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
      double _price=getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i]    = iKama(_price,inpFastPeriod,inpFastEndPeriod,inpSlowEndPeriod,inpPower,i,open,close,high,low,rates_total,0)-iKama(_price,inpSlowPeriod,inpFastEndPeriod,inpSlowEndPeriod,inpPower,i,open,close,high,low,rates_total,1);
      signal[i] = iKama(val[i],inpSignalPeriod,inpFastEndPeriod,inpSlowEndPeriod,inpPower,i,open,close,high,low,rates_total,2);
      fillu[i]  = val[i];
      filld[i]  = signal[i];
      valc[i]=(val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 :(i>0) ? valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define amaInstances     3
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
   double tsignal= (r>=period) ? MathAbs(price-workAma[r-period][instanceNo+_price]) : 0;
   double noise  = 0;
   workAma[r][instanceNo+_diff]=(r>0) ? MathAbs(price-workAma[r-1][instanceNo+_price]) : 0;
   for(int k=0; k<period && r-k>=0; k++)
      noise+=workAma[r-k][instanceNo+_diff];
//
//---
//
   if(noise!=0)
      efratio=tsignal/noise;
   else  efratio= 1;
   double smooth=MathPow(efratio*(fastend-slowend)+slowend,power);
   workAma[r][instanceNo+_kama]=(r>0) ? workAma[r-1][instanceNo+_kama]+smooth*(price-workAma[r-1][instanceNo+_kama]) : price;
   return(workAma[r][instanceNo+_kama]);
  }
//
//
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
