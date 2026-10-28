//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "SRsi"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrYellow,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//
//

input int    inpRsiPeriod  = 20;   // RSI period
input double inpLevels     = 0.38; // Levels
input double inpNLevels    = 0.05; // Neutral zone

double val[],valc[],srsiv[],srsis[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valc ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,srsiv,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,srsis,INDICATOR_CALCULATIONS);
      IndicatorSetInteger(INDICATOR_LEVELS,4);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0, inpLevels);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-inpLevels);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,2, inpNLevels);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-inpNLevels);
      IndicatorSetString(INDICATOR_SHORTNAME,"SRsi ("+(string)inpRsiPeriod+","+(string)inpNLevels+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }
int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      srsiv[i] = (high[i]!=low[i]) ? (close[i]-open[i])/(high[i]-low[i]) : 0;
         if (i>inpRsiPeriod)
                srsis[i] = srsis[i-1]-srsiv[i-inpRsiPeriod]+srsiv[i];
         else { srsis[i] = srsiv[i]; for (int k=1; k<inpRsiPeriod && i>=k; k++) srsis[i] += srsiv[i-k]; }
                  
         val[i]  = srsis[i]/inpRsiPeriod;
         valc[i] = (val[i]>inpNLevels) ? 1 : (val[i]<-inpNLevels) ? 2 : 0;
   }
   return(i);
}