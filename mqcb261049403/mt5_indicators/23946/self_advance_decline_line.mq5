//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Self Advance Decline line ..."
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Self AD line "
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2
//
//--- input parameters
//
input int inpPeriod =  25; // Period
//
//--- buffers declarations
//
double val[],valc[],sum[],state[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val  ,INDICATOR_DATA);
         SetIndexBuffer(1,valc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,sum  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,state,INDICATOR_CALCULATIONS);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Self Advance Decline line ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      state[i] = (close[i]>open[i]) ? 1 : (close[i]<open[i]) ? -1 : 0;
      if (i>inpPeriod)
             sum[i] = sum[i-1] + state[i]-state[i-inpPeriod];
      else { sum[i] = state[i]; for (int k=1; k<inpPeriod && i>=k; k++) sum[i] += state[i-k]; }
      val[i]  = (i>0) ? val[i-1] + sum[i] : sum[i];
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }
   return (i);
}