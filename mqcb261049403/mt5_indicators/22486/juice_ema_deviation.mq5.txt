//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Juice ema deviation indicator"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2

#property indicator_label1  "Juice fill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'209,243,209',C'255,230,183'
#property indicator_label2  "Juice"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrSilver,clrLimeGreen,clrOrange
#property indicator_width2  2
//
//---
//
input int                inpPeriod      = 32;             // Period
input double             inpLevel       = 6;              // Level (in pips)
input ENUM_APPLIED_PRICE inpPrice       = PRICE_MEDIAN;   // Price

double val[],valc[],fill1[],fill2[];
double _workLevel;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,fill1  ,INDICATOR_DATA);
   SetIndexBuffer(1,fill2  ,INDICATOR_DATA);
   SetIndexBuffer(2,val    ,INDICATOR_DATA);
   SetIndexBuffer(3,valc   ,INDICATOR_COLOR_INDEX);
      _workLevel =  inpLevel*_Point*MathPow(10,_Digits%2);
         IndicatorSetInteger(INDICATOR_LEVELS,1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,_workLevel);
   IndicatorSetString(INDICATOR_SHORTNAME,"Juice ema deviation ("+(string)inpPeriod+","+(string)inpLevel+")");
   return(0);
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
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      double price = getPrice(inpPrice,open,close,high,low,i,rates_total);
            val[i]   = iEmaDeviation(price,inpPeriod,i)-_workLevel;
            valc[i]  = (val[i]<_workLevel) ? 2 : 1;
            fill1[i] = val[i];
            fill2[i] = _workLevel;
   }
   return(i);
}


//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _edevInstances 1
#define _edevInstancesSize 2
#define _edevRingSize 5
double workEmaDeviation[_edevRingSize][_edevInstances*_edevInstancesSize];
#define _ema0 0
#define _ema1 1
//
//---
//
double iEmaDeviation(double price,double period, int i, int instance=0)
{
   int _indP = (i-1)%_edevRingSize;
   int _indC = (i  )%_edevRingSize;
   int _inst = instance*_edevInstancesSize;
   
   if (i>0 && period>1)
   {
      double alpha = 2.0/(1.0+period);
         workEmaDeviation[_indC][_inst+_ema0] = workEmaDeviation[_indP][_inst+_ema0]+alpha*(price      -workEmaDeviation[_indP][_inst+_ema0]);
         workEmaDeviation[_indC][_inst+_ema1] = workEmaDeviation[_indP][_inst+_ema1]+alpha*(price*price-workEmaDeviation[_indP][_inst+_ema1]);
   }         
   else for (int k=0; k<_edevInstancesSize; k++) workEmaDeviation[_indC][_inst+k] = price;
   return(MathSqrt(period*(workEmaDeviation[_indC][_inst+_ema1]-workEmaDeviation[_indC][_inst+_ema0]*workEmaDeviation[_indC][_inst+_ema0])/MathMax(period-1,1)));
}
//
//---
//
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