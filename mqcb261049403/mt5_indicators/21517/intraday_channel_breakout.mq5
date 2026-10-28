//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "Channel zone filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "Upper limit"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower limit"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Breakout bars"
#property indicator_type4   DRAW_COLOR_HISTOGRAM2
#property indicator_color4  clrLimeGreen,clrRed
#property indicator_width4  2
//
//---
//
input string    inpStartTime = "00:00"; // Start time
input string    inpEndTime   = "03:59"; // Ending time
//
//---
//
double  fillu[],filld[],limu[],limd[],histou[],histod[],histoc[];

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
   SetIndexBuffer(0,fillu ,INDICATOR_DATA);
   SetIndexBuffer(1,filld ,INDICATOR_DATA);
   SetIndexBuffer(2,limu  ,INDICATOR_DATA);
   SetIndexBuffer(3,limd  ,INDICATOR_DATA);
   SetIndexBuffer(4,histou,INDICATOR_DATA);
   SetIndexBuffer(5,histod,INDICATOR_DATA);
   SetIndexBuffer(6,histoc,INDICATOR_COLOR_INDEX);
//
//---
//
   if (_Period>=PERIOD_D1)
   {
      Alert("Indicator can work on time frames less than daily only");  return(INIT_FAILED);
   }
   IndicatorSetString(INDICATOR_SHORTNAME,"Channel "+inpStartTime+" "+inpEndTime+" breakout");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

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
   int _secondsStart = (int)StringToTime("1970.01.01 "+inpStartTime);
   int _secondsEnd   = (int)StringToTime("1970.01.01 "+inpEndTime);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
      datetime _startTime = StringToTime(TimeToString(time[i],TIME_DATE))+_secondsStart;
      datetime _endTime   = StringToTime(TimeToString(time[i],TIME_DATE))+_secondsEnd;
      double max = ((i>0) ? limu[i-1] : high[i]), min = ((i>0) ? limd[i-1] : low[i]);
         if (_startTime<= time[i] && _endTime>=time[i])
         {
            max = high[i];
            min = low[i];
            for (int k=1; i-k>=0 && time[i-k]>=_startTime; k++)
            {
               max = MathMax(max,high[i-k]);
               min = MathMin(min,low[i-k]);
            }
         }                           
      limu[i] = max;
      limd[i] = min;
         if (_startTime<=time[i] && _endTime>=time[i])
         {
            fillu[i] = max;
            filld[i] = min;
            histou[i] = EMPTY_VALUE;
            histod[i] = EMPTY_VALUE;
         }
         else
         {
            fillu[i]  = (limu[i]+limd[i])/2.0;
            filld[i]  = (limu[i]+limd[i])/2.0;
            histou[i] = (close[i]>limu[i] || close[i]<limd[i]) ? high[i] : EMPTY_VALUE;
            histod[i] = (close[i]>limu[i] || close[i]<limd[i]) ? low[i]  : EMPTY_VALUE;
            histoc[i] = (close[i]>limu[i]) ? 0 : 1;
         }
   }      
   return(i);
}
