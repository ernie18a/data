//------------------------------------------------------------------
#property copyright    "© mladen, 2018"
#property link         "mladenfx@gmail.com"
#property description  "Fast EMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Fast Ema"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width1  2
//--- input parameters
input double             inpPeriod = 27;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Fast Ema ("+(string)inpPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]=iEmaFast(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i);
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _efastInstances 1
#define _efastInstancesSize 1
#define _efastRingSize 5
double workEfast[_efastRingSize][_efastInstances*_efastInstancesSize];
//
//---
//
double iEmaFast(double price, double period, int i, int instance=0)
{
   int _indP = (i-1)%_efastRingSize;
   int _indC = (i  )%_efastRingSize;
   int _inst = instance*_efastInstancesSize;
   
   //
   //---
   //
   
   if(i>0 && period>1)
      #define _alpha(_period) (2.0/(2.0+(_period-1.0)/2.0))
           workEfast[_indC][_inst] = (i>0) ? workEfast[_indP][_inst]+_alpha(period)*(price-workEfast[_indP][_inst]) : price;
      else workEfast[_indC][_inst] = price;      
   return (workEfast[_indC][_inst]);
   
   //
   //---
   //
   
   #undef _alpha
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
