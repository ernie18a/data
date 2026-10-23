//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "ATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrPaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//---
//

input int inpPeriod = 14; // period

double val[],tr[];
ENUM_TIMEFRAMES _timeFrame=PERIOD_D1; string _timeFrameName = "day";

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,tr ,INDICATOR_CALCULATIONS);
      if (_Period==PERIOD_D1)                        { _timeFrame = PERIOD_W1;  _timeFrameName = "week";  }
      if (_Period==PERIOD_W1 || _Period==PERIOD_MN1) { _timeFrame = PERIOD_MN1; _timeFrameName = "month"; }

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Intra-"+_timeFrameName+" ATR ("+(string)inpPeriod+")");
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
         
         tr[i] = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) - (low[i]<close[i-1] ? low[i] : close[i-1]) : high[i]-low[i];
         int k=1,_period = (_timeFrame==PERIOD_MN1) ? inpPeriod : i-(rates_total-_firstBar-1)+1; if (_period>inpPeriod) _period = inpPeriod;

            val[i] = tr[i]; for (; k<_period && i>=k; k++) val[i] += tr[i-k];
            val[i] /= (double)k;
   }      
   return(i);
}