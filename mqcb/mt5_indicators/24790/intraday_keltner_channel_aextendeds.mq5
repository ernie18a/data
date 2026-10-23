//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Upper band"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Average"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_DOT

//
//---
//

input int                inpPeriod     = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
input double             inpMultiplier = 1.0;         // ATR multiplier

double val[],valu[],vald[],tr[],prices[];
ENUM_TIMEFRAMES _timeFrame=PERIOD_D1; string _timeFrameName = "day";

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,valu  ,INDICATOR_DATA);
   SetIndexBuffer(1,val   ,INDICATOR_DATA);
   SetIndexBuffer(2,vald  ,INDICATOR_DATA);
   SetIndexBuffer(3,tr    ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,prices,INDICATOR_CALCULATIONS);
      if (_Period==PERIOD_D1)                        { _timeFrame = PERIOD_W1;  _timeFrameName = "week";  }
      if (_Period==PERIOD_W1 || _Period==PERIOD_MN1) { _timeFrame = PERIOD_MN1; _timeFrameName = "month"; }
      

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Intra-"+_timeFrameName+" Keltner channel ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      int      _highTfBar  = iBarShift(_Symbol,_timeFrame,time[i]);
      datetime _highTfTime = iTime(_Symbol,_timeFrame,_highTfBar);
      int      _firstBar   = iBarShift(_Symbol,_Period,_highTfTime);
         
         //
         //
         //
         
         prices[i] = getPrice(inpPrice,open,high,low,close,i);
         tr[i] = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) - (low[i]<close[i-1] ? low[i] : close[i-1]) : high[i]-low[i];
         
            int k=1,_period = (_timeFrame==PERIOD_MN1) ? inpPeriod : i-(rates_total-_firstBar-1)+1; if (_period>inpPeriod) _period = inpPeriod;
            val[i] = prices[i];
            double _atr = tr[i]; for (; k<_period && i>=k; k++) { _atr += tr[i-k]; val[i] += prices[i-k]; }
                   _atr /= (double)k;
                   val[i] /= (double)k;
                   valu[i] = val[i] + inpMultiplier*_atr;
                   vald[i] = val[i] - inpMultiplier*_atr;
   }      
   return(i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[], T& high[], T& low[], T& close[], int i)
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
//------------------------------------------------------------------