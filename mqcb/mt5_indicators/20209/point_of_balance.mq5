//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Point of balance"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "Point of balance up"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrDeepSkyBlue
#property indicator_width1  2
#property indicator_label1  "Point of balance down"
#property indicator_type2   DRAW_SECTION
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
//--- input parameters
input int                inpPobPeriod  = 12;          // Point of balance period
input int                inpPobLevel   = 10;          // Point of balance level (>=1 and <=10)
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 
//--- buffers declarations
double valu[],vald[],prices[],mpavg[][11];
int _pobLevel;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valu,INDICATOR_DATA);
   SetIndexBuffer(1,vald,INDICATOR_DATA);
   SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
//---
   _pobLevel=MathMax(MathMin(inpPobPeriod,10),1);
   IndicatorSetString(INDICATOR_SHORTNAME,"Point of Balance ("+(string)_pobLevel+")");
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
   if(ArrayRange(mpavg,0)!=rates_total) ArrayResize(mpavg,rates_total);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);
      mpavg[i][ 0] = MidPoint( 0,i);
      mpavg[i][ 1] = MidPoint( 1,i);
      mpavg[i][ 2] = MidPoint( 2,i);
      mpavg[i][ 3] = MidPoint( 3,i);
      mpavg[i][ 4] = MidPoint( 4,i);
      mpavg[i][ 5] = MidPoint( 5,i);
      mpavg[i][ 6] = MidPoint( 6,i);
      mpavg[i][ 7] = MidPoint( 7,i);
      mpavg[i][ 8] = MidPoint( 8,i);
      mpavg[i][ 9] = MidPoint( 9,i);
      mpavg[i][10] = MidPoint(10,i);
      int _start=MathMax(i-_pobLevel,0);
      double hiPrice = prices[ArrayMaximum(prices,_start,_pobLevel)];
      double loPrice = prices[ArrayMinimum(prices,_start,_pobLevel)];
      double _avg    = mpavg[i][0];
      int k=1;
      for(;k<=_pobLevel; k++) _avg+=mpavg[i][k];
      _avg/=k;
      double value=(hiPrice!=loPrice) ? 100*(prices[i]-_avg)/(hiPrice-loPrice) : 0;
      valu[i] = (value > 0) ? value : EMPTY_VALUE;
      vald[i] = (value < 0) ? value : EMPTY_VALUE;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double MidPoint(int _forDim,int shift)
  {
   double maxValue = (_forDim==0) ? prices[shift] : mpavg[shift][_forDim-1];
   double minValue = (_forDim==0) ? prices[shift] : mpavg[shift][_forDim-1];
   for(int i=1; i<inpPobPeriod && (shift-i)>=0; i++)
     {
      minValue = MathMin(minValue,(_forDim==0) ? prices[shift-i] : mpavg[shift-i][_forDim-1]);
      maxValue = MathMax(minValue,(_forDim==0) ? prices[shift-i] : mpavg[shift-i][_forDim-1]);
     }
   return((maxValue+minValue)/2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
