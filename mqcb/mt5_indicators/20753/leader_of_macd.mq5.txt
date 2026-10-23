//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "MACD of average"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "Leader"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_label3  "Leader of MACD"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width3  2
#property indicator_label4  "MACD signal"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_DOT
//--- input parameters
enum enColorOn
  {
   color_onSlope, // Change color on MACD slope change
   color_onSignal // Change color on MACD crossing signal line
  };
enum enSignalOn
  {
   signal_onLeader, // Signal on leader
   signal_onMacd    // Signal on macd
  };
input int                inpFastPeriod   = 12;             // MACD fast period
input int                inpSlowPeriod   = 26;             // MACD slow period
input int                inpSignalPeriod = 9;              // MACD signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;    // Price 
input enSignalOn         inpSignalOn     = signal_onMacd;  // Signal on :
input enColorOn          inpColorOn      = color_onSignal; // Color change on :
//--- buffers declarations
double val[],valc[],signal[],macd[],leader[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,macd,INDICATOR_DATA);
   SetIndexBuffer(1,leader,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,signal,INDICATOR_DATA);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Leader of MACD ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double price=getPrice(inpPrice,open,close,high,low,i,rates_total);
      double iFastEma = iEma(price         ,inpFastPeriod,i,rates_total,0);
      double iSlowEma = iEma(price         ,inpSlowPeriod,i,rates_total,1);
      double iFastEmx = iEma(price-iFastEma,inpFastPeriod,i,rates_total,2);
      double iSlowEmx = iEma(price-iSlowEma,inpSlowPeriod,i,rates_total,3);
      //
      //---
      //
      macd[i]   = iFastEma-iSlowEma;
      leader[i] = iFastEma+iFastEmx-iSlowEma-iSlowEmx;
      signal[i] = (inpSignalOn==signal_onLeader) ? leader[i]-iEma(leader[i],inpSignalPeriod,i,rates_total,4) : iEma(macd[i],inpSignalPeriod,i,rates_total,4);
      val[i]    = (inpSignalOn==signal_onLeader) ? leader[i] : macd[i];
      if(inpColorOn==color_onSlope)
            valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
      else  valc[i] = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 : (i>0) ? valc[i-1] : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workEma[][5];
//
//---
//
double iEma(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=bars) ArrayResize(workEma,bars);
   //
   //---
   //
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
