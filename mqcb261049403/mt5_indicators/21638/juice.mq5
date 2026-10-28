//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Juice indicator"
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
input double             inpLevel       = 4;              // Level (in pips)
input ENUM_APPLIED_PRICE inpPrice       = PRICE_MEDIAN;   // Price

double val[],valc[],fill1[],fill2[];
double _workLevel;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,fill1  ,INDICATOR_DATA);
   SetIndexBuffer(1,fill2  ,INDICATOR_DATA);
   SetIndexBuffer(2,val    ,INDICATOR_DATA);
   SetIndexBuffer(3,valc   ,INDICATOR_COLOR_INDEX);
      _workLevel =  inpLevel*_Point*MathPow(10,_Digits%2);
         IndicatorSetInteger(INDICATOR_LEVELS,1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,_workLevel);
   IndicatorSetString(INDICATOR_SHORTNAME,"Juice ("+(string)inpPeriod+","+(string)inpLevel+")");
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

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
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      double price = getPrice(inpPrice,open,close,high,low,i,rates_total);
            val[i]   = iDeviation(price,inpPeriod,i,rates_total)-_workLevel;
            fill1[i] = val[i];
            fill2[i] = _workLevel;
   }
   return(i);
}


//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workDev[];
//
//---
//
double iDeviation(double value,int length,int i,int bars,bool isSample=false)
  {
   if(ArraySize(workDev)!=bars) ArrayResize(workDev,bars);  workDev[i]=value;
   double sumx=0,sumxx=0; for(int k=0; k<length && (i-k)>=0; sumx+=workDev[i-k],sumxx+=workDev[i-k]*workDev[i-k],k++) {}
   return(MathSqrt((sumxx-sumx*sumx/length)/MathMax(length-isSample,1)));
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