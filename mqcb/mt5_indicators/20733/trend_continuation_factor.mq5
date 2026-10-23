//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Trend continuation factor"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Trend continuation factor zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrPowderBlue,clrAntiqueWhite
#property indicator_label2  "Trend continuation factor"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
input int                inpLength     = 30;           // Trend continuation factor period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;  // Price
//
//--- buffers and global variables declarations
//
double val[],valc[],levup[],levdn[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,levup,INDICATOR_DATA);
   SetIndexBuffer(1,levdn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,prices,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend continuation factor ("+(string)inpLength+")");
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
double values[][4];
#define plus_ch  0
#define minus_ch 1
#define plus_cf  2
#define minus_cf 3
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
   if(ArrayRange(values,0)!=rates_total) ArrayResize(values,rates_total);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);
      double roc= (i>0) ? prices[i]-prices[i-1]: 0;
      values[i][plus_ch]  = 0;
      values[i][minus_ch] = 0;
      values[i][plus_cf]  = 0;
      values[i][minus_cf] = 0;
      if(roc>0)
        {
         values[i][plus_ch] = roc;
         values[i][plus_cf] = (i>0) ? values[i][plus_ch]+values[i-1][plus_cf] : values[i][plus_ch];
        }
      if(roc<0)
        {
         values[i][minus_ch]=-roc;
         values[i][minus_cf] = (i>0) ? values[i][minus_ch]+values[i-1][minus_cf] : values[i][minus_ch];
        }
      levup[i] = 0;
      levup[i] = 0;
      for(int l=0; l<inpLength && (i-l)>=0; l++)
        {
         levup[i] += values[i-l][plus_ch]-values[i-l][minus_cf];
         levdn[i] += values[i-l][minus_ch]-values[i-l][plus_cf];
        }
      val[i]   =  levup[i];
      valc[i]  = (levup[i]>levdn[i]) ? 2 : (levup[i]<levdn[i]) ? 1 : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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
