//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Phase change index"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
#property indicator_label1  "Phase change trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "Phase change index"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrSandyBrown,clrDeepSkyBlue
#property indicator_width2  2
//
//--- input parameters
//
enum enInverted 
{
   inv_regular, // Display regular value
   inv_inverted // Display inverted value
};
input int                inpLength     = 30;           // Phase change index period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;  // Price
input double             inpLevelHigh  = 80;           // Level high
input double             inpLevelLow   = 20;           // Level low
input enInverted         inpInverted   = inv_inverted; // Display type
//
//--- buffers and global variables declarations
//
double val[],valc[],levup[],levdn[],prices[],state[];
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Phase change index ("+(string)inpLength+")");
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
      prices[i] = getPrice(inpPrice,open,close,high,low,i,rates_total);
      //
      //---
      //
      double momentum = (i>=inpLength) ? prices[i]-prices[i-inpLength] : 0;
      double sumUpDi  = 0;
      double sumDnDi  = 0;
      for(int j=1; j<inpLength && (i-j)>=0 && (i-inpLength)>=0; j++)
      {
         double gradient  = prices[i-inpLength]+momentum*(inpLength-j)/(inpLength);
         double deviation = prices[i-j]-gradient;
            if (deviation > 0)
                  sumUpDi += deviation;
            else  sumDnDi -= deviation;
      }                    
      val[i]   = (((sumUpDi+sumDnDi)!=0)) ? 100.0*sumUpDi/(sumUpDi+sumDnDi) : 0; if (inpInverted==inv_inverted) val[i] = 100-val[i];
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
