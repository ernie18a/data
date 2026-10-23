//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Moving slope rate of change - extended"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "msrc filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'218,231,226',C'255,221,217'
#property indicator_label2  "msrc value"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrCrimson
#property indicator_width2  2

//--- input parameters
input int                inpPeriod       = 20;          // Calculation period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price 
input int                inpLevLookBack  = 25;          // Floating level period (<=0 no floating level)
input double             inpLevLevelUp   = 90;          // Floating level up %
input double             inpLevLevelDown = 10;          // Floating level down %

//--- buffers declarations
double fillu[],filld[],val[],valc[];
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
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Moving slope rate of change ("+(string)inpPeriod+")");
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
      //--- least squares value calculation
      double sum_xy = 0;
      double sum_x  = 0;
      double sum_y  = 0;
      double sum_xx = 0;
      for(int j=0; j<inpPeriod && (i-j)>=0; j++) 
        {
         double y = getPrice(inpPrice,open,close,high,low,i-j,rates_total);
         double x = inpPeriod - j;

         sum_xy += x*y;
         sum_x  += x;
         sum_y  += y;
         sum_xx += x*x;
        }
      double numerator   = inpPeriod*sum_xy - sum_x*sum_y;
      double denominator = inpPeriod*sum_xx - sum_x*sum_x;
      val[i]   = (denominator!=0) ? numerator/denominator : 0;
      fillu[i] = val[i];

      //--- floating level calculation (if allowed)
      if(inpLevLookBack>0)
        {
         int    start = MathMax(i-inpLevLookBack+1,0);
         double min   = val[ArrayMinimum(val,start,inpLevLookBack)];
         double max   = val[ArrayMaximum(val,start,inpLevLookBack)];
         double range = max-min;
         double levu  = min+inpLevLevelUp*range/100.0;
         double levd  = min+inpLevLevelDown*range/100.0;
         filld[i] = (val[i]>levu) ? levu : (val[i]<levd) ? levd : val[i];
         valc[i]  = (val[i]>levu) ? 1 :(val[i]<levd) ? 2 : 0;
        }
      else
        {
         filld[i]=0;
         valc[i]=(i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
        }
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
