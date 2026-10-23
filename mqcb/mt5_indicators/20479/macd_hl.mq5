//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Macd high/low"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   7
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_label2  "Early level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Zero level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Early level down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrCrimson
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Level down"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrCrimson
#property indicator_label6  "Macd value"
#property indicator_type6   DRAW_COLOR_LINE
#property indicator_color6  clrDarkGray,clrDodgerBlue,clrDeepSkyBlue,clrCrimson,clrRed
#property indicator_width6  3
#property indicator_label7  "Macd signal"
#property indicator_type7   DRAW_COLOR_LINE
#property indicator_color7  clrDarkGray,clrDodgerBlue,clrDeepSkyBlue,clrCrimson,clrRed
#property indicator_width7  1
//--- input parameters
input int                inpFastPeriod     = 19;          // Fast DEMA period
input int                inpSlowPeriod     = 39;          // Slow DEMA period
input int                inpSignalPeriod   = 9;           // Signal period
input int                inpLookBackPeriod = 50;          // Lookback period
input double             inpEarlyLevel     = 25;          // Early levels %
input ENUM_APPLIED_PRICE inpPrice          = PRICE_CLOSE; // Price 
//--- buffers declarations
double val[],valc[],signal[],signalc[],levelm[],levelu1[],levelu2[],leveld1[],leveld2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,levelu2,INDICATOR_DATA);
   SetIndexBuffer(1,levelu1,INDICATOR_DATA);
   SetIndexBuffer(2,levelm,INDICATOR_DATA);
   SetIndexBuffer(3,leveld1,INDICATOR_DATA);
   SetIndexBuffer(4,leveld2,INDICATOR_DATA);
   SetIndexBuffer(5,val,INDICATOR_DATA);
   SetIndexBuffer(6,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,signal,INDICATOR_DATA);
   SetIndexBuffer(8,signalc,INDICATOR_COLOR_INDEX);
   for(int i=0; i<5; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Macd high/low ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+","+(string)inpLookBackPeriod+")");
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
      val[i]    = iEma(_price,inpFastPeriod,i,rates_total,0)-iEma(_price,inpSlowPeriod,i,rates_total,1);
      signal[i] = iEma(val[i],inpSignalPeriod,i,rates_total,2);
      int _start=MathMax(i-inpLookBackPeriod,0); // shifted by 1 to the past on purpose, no error
      int _count= MathMin(_start+1,inpLookBackPeriod);
      double max = val[ArrayMaximum(val,_start,_count)];
      double min = val[ArrayMinimum(val,_start,_count)];
      levelu2[i] = max;
      leveld2[i] = min;
      levelm[i]  = (max+min)/2.0;
      levelu1[i] = levelm[i]+(levelu2[i]-levelm[i])*inpEarlyLevel/100.0;
      leveld1[i] = levelm[i]-(levelm[i]-leveld2[i])*inpEarlyLevel/100.0;
      valc[i]=(val[i]>signal[i]) ?(val[i]>levelu2[i]) ? 2 :(val[i])>levelm[i]? 1 : 0 :(val[i]<signal[i]) ? val[i]<leveld2[i]? 4 :(val[i]<levelm[i]) ? 3 : 0 :(i>0) ? valc[i-1]: 0;
      signalc[i]=valc[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workEma[][3];
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
