//+------------------------------------------------------------------+
#property copyright "© 2026, ChukwuBuikem"
#property link      "https://www.mql5.com/en/users/bikeen"
#property version   "1.00"
#property indicator_chart_window
#property  indicator_plots 0
#include <ChartObjects\ChartObjectsFibo.mqh>
#define  DEF_OBJNAME "CRT(STF) Explorer"
#define LEVEL_COLOR C'25,90,200'

CChartObjectTrend trendline;
int start = -1;
//+------------------------------------------------------------------+
//| Indicator initialization function                               |
//+------------------------------------------------------------------+
int OnInit() {
//---
  
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Indicator deinitialization function                               |
//+------------------------------------------------------------------+
void OnDeinit(const int32_t reason) {
//-- Clear chart
   ObjectsDeleteAll(0, DEF_OBJNAME);
   ChartRedraw();
}
//+------------------------------------------------------------------+
//|     Indicator calculation function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[]) {
//---
   if(rates_total != prev_calculated && prev_calculated > 0) {
      if(rates_total < 2)return rates_total;
      start = (prev_calculated == 0) ? 2 : prev_calculated - 1;
      for(int w = start; w < rates_total && !IsStopped(); w++) {
         //--- BulBearish CRT setup detection
         // 1) Bullish reference candle (w-2)
         // 2) Bearish expansion candle (w-1)
         // 3) Liquidity sweep above prior high
         // 4) Bearish close below prior close
         // 5) Close remains above midpoint of reference candle
         // 6) Low holds above midpoint (mid-candle rejection zone)
         if(close[w - 2] > open[w - 2] &&
               open[w - 1] > close[w - 1] &&
               high[w - 1] > high[w - 2] &&
               close[w - 1] < close[w - 2] &&
               close[w - 1] > MathAbs(high[w - 2] + low[w - 2]) / 2 &&
               low[w - 1] > MathAbs(high[w - 2] + low[w - 2]) / 2 ) {
            //--- Draw CRT range (reference candle high/low)
            createTrendline(trendline, DEF_OBJNAME + "_H" +  (string)ObjectsTotal(0), time[w - 2], high[w - 2]);
            createTrendline(trendline, DEF_OBJNAME + "_L" + (string)ObjectsTotal(0), time[w - 2], low[w - 2]);
            ChartRedraw();//Force visual update
            return rates_total;//--- Exit after each valid CRT detection
         }
         //--- Bullish CRT setup detection
         // 1) Bearish reference candle (w-2)
         // 2) Bullish expansion candle (w-1)
         // 3) Liquidity sweep below prior low
         // 4) Bullish close above prior close
         // 5) Close remains below midpoint of reference candle
         // 6) High capped below midpoint (mid-candle rejection zone)
         if(open[w - 2] > close[w - 2] &&
               close[w - 1] > open[w - 1] &&
               low[w - 1] < low[w - 2] &&
               close[w - 1] > close[w - 2] &&
               close[w - 1] < MathAbs(high[w - 2] + low[w - 2]) / 2 &&
               high[w - 1] < MathAbs(high[w - 2] + low[w - 2]) / 2 ) {
            //--- Draw CRT range (reference candle high/low)
            createTrendline(trendline, DEF_OBJNAME + "_H" + (string)ObjectsTotal(0), time[w - 2], high[w - 2]);
            createTrendline(trendline, DEF_OBJNAME + "_L" + (string)ObjectsTotal(0), time[w - 2], low[w - 2]);
            ChartRedraw();
            return rates_total;//--- Exit after each valid CRT detection
         }
      }
   }
   return rates_total;
}
//+------------------------------------------------------------------+
//|   Function to create trendline using ChartObjectsFibo (chart object library)
//+------------------------------------------------------------------+
void createTrendline(CChartObjectTrend &trendObj, const string objName,
                     const datetime crTime, const double crPrice) {
//---
   if(trendObj.Create(0, objName, 0, crTime, crPrice, crTime + (PeriodSeconds() * 2), crPrice)) {
      trendObj.Width(3);//Set visual thickness
      trendObj.Color(LEVEL_COLOR);//Set visual color
   }
}
//+------------------------------------------------------------------+
