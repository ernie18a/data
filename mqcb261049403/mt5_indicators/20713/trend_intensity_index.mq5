//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Trend intensity index"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
#property indicator_label1  "Trend intensity index trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "Trend intensity index"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
input int                inpLength     = 30;           // Trend intensity index period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;  // Price
input ENUM_MA_METHOD     inpMaMode     = MODE_SMA;     // Average method
input double             inpLevelHigh  = 80;           // Level high
input double             inpLevelLow   = 20;           // Level low
                                                       //
//--- buffers and global variables declarations
//
double val[],valc[],levup[],levdn[],prices[],state[];
int _maHandle;
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
   SetIndexBuffer(5,state,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpLevelHigh);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inpLevelLow);
//---
   _maHandle=iMA(_Symbol,0,inpLength*2,0,inpMaMode,inpPrice); if(_maHandle==INVALID_HANDLE) { return(INIT_FAILED); }
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend intensity index ("+(string)inpLength+")");
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
   if(BarsCalculated(_maHandle)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double _maVal[1];
      int    _maCopied=CopyBuffer(_maHandle,0,time[i],1,_maVal);
      double ma =  (_maCopied==1) ? _maVal[0] : 0;
      prices[i] = getPrice(inpPrice,open,close,high,low,i,rates_total);

      //
      //---
      //

      double sumUpDeviations = 0;
      double sumDnDeviations = 0;
      for(int j=0; j<inpLength && (i-j)>=0; j++)
        {
         double diff=prices[i-j]-ma;
         if(diff>0)
            sumUpDeviations += diff;
         else  sumDnDeviations -= diff;
        }

      //
      //
      //
      //
      //

      val[i]   = ((sumUpDeviations+sumDnDeviations)!=0) ? 100*sumUpDeviations/(sumUpDeviations+sumDnDeviations) : 0;
      levdn[i] = 50;
      levup[i] = (val[i]>inpLevelHigh) ? 100: (val[i]<inpLevelLow) ? 0 : 50;
      valc[i]  = (val[i]>inpLevelHigh) ? 2 : (val[i]<inpLevelLow) ? 1 : 0;
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
