//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trix"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Trix"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width1  2
//--- input parameters
input int                inpTrixPeriod = 14;           // Trix period
input ENUM_APPLIED_PRICE inpTrixPrice  = PRICE_CLOSE;  // Price
//--- buffers declarations
double val[],valc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"TRIX log ("+(string)inpTrixPeriod+")");
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
double workTrix[][3];
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
   if (ArrayRange(workTrix,0)!=rates_total) ArrayResize(workTrix,rates_total);

   //
   //---
   //
   
   double alpha = 2.0/(1.0+inpTrixPeriod);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      double price = MathLog(getPrice(inpTrixPrice,open,close,high,low,i,rates_total));
            workTrix[i][0] = (i>0) ? workTrix[i-1][0]+alpha*(price         -workTrix[i-1][0]) : 0;
            workTrix[i][1] = (i>0) ? workTrix[i-1][1]+alpha*(workTrix[i][0]-workTrix[i-1][1]) : 0;
            workTrix[i][2] = (i>0) ? workTrix[i-1][2]+alpha*(workTrix[i][1]-workTrix[i-1][2]) : 0;
         
            val[i]  = (i>0) ? (workTrix[i-1][2]!=0) ? (workTrix[i][2]-workTrix[i-1][2])/workTrix[i-1][2] : 0 : 0;
            valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
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
