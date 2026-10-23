//+------------------------------------------------------------------+
#property copyright "© 2026, ChukwuBuikem"
#property link      "https://www.mql5.com/en/users/bikeen"
#property version   "1.00"
#property indicator_chart_window
#property  indicator_plots 0
#include <ChartObjects\ChartObjectsFibo.mqh>
#define  PROG_NAME "CRT(MTF) Explorer"
#define  OBJ_NAME PROG_NAME + "_Fibo" + (string) ObjectsTotal(0)

input ENUM_TIMEFRAMES inpHTF = PERIOD_H4;//CRT reference timeframe

int start = -1;
datetime lastCrtTime = 0;
CChartObjectFibo fibo;
//+------------------------------------------------------------------+
//| Indicator initialization function                               |
//+------------------------------------------------------------------+
int OnInit() {
//---
   if(PERIOD_CURRENT > inpHTF) {
      Print("Invalid timeframe configuration. LTF must be lower than HTF.");
      return INIT_FAILED;
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Indicator deinitialization function                               |
//+------------------------------------------------------------------+
void OnDeinit(const int32_t reason) {
//---
   ObjectsDeleteAll(0, PROG_NAME);
}
//+------------------------------------------------------------------+
//|     Indicator calculation function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total, const int32_t prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int32_t &spread[]) {
//---
   if(prev_calculated != rates_total && prev_calculated > 0) {
      start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
      for(int w = start; w < rates_total && !IsStopped(); w++) {
         if(isNewHTFBar(inpHTF) && iBars(_Symbol, inpHTF) > 2) {
            MqlRates rates[];
            ArraySetAsSeries(rates, true);
            if((CopyRates(_Symbol, inpHTF, 1, 2, rates)) < 2) {
               Print("HTF bar data failed to copy");
               return rates_total;
            }
            if(isBullishCRT(rates) && lastCrtTime < rates[1].time) {
               lastCrtTime = rates[1].time;
               //-Draw levels on current timeframe(LTF)
               createFibo(OBJ_NAME, rates[1].time, rates[1].high, rates[1].time + (PeriodSeconds(inpHTF) * 2), rates[1].low, clrBlue);
               return rates_total;
            }
            if(isBearishCRT(rates) && lastCrtTime < rates[1].time) {
               lastCrtTime = rates[1].time;
               //-Draw levels on current timeframe(LTF)
               createFibo(OBJ_NAME, rates[1].time, rates[1].high, rates[1].time + (PeriodSeconds(inpHTF) * 2), rates[1].low, clrRed);
               return rates_total;
            }
         }
      }
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
//|   Function to new bar formation on HTF
//+------------------------------------------------------------------+
bool isNewHTFBar(const ENUM_TIMEFRAMES tf) {
//---
   static datetime lastTime = LONG_MIN;
   datetime newTime = iTime(_Symbol, tf, 0);
   if(lastTime == LONG_MIN) {
      lastTime = newTime;
      return false;
   }
   if(lastTime != newTime) {
      lastTime = newTime;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//|   Function to detect bullish CRT setup
//+------------------------------------------------------------------+
bool isBullishCRT(const MqlRates & arr[]) {
//---
   return (arr[1].close < arr[1].open && arr[0].close > arr[0].open && arr[0].low < arr[1].low && arr[0].close > arr[1].close
           && arr[0].close < MathAbs(arr[1].high + arr[1].low) / 2 && arr[0].high < MathAbs(arr[1].high + arr[1].low) / 2);
}
//+------------------------------------------------------------------+
//|   Function to detect bearish CRT setup
//+------------------------------------------------------------------+
bool isBearishCRT(const MqlRates & arr[]) {
//---
   return (arr[1].close > arr[1].open && arr[0].close < arr[0].open && arr[0].high > arr[1].high && arr[0].close < arr[1].close
           && arr[0].close > MathAbs(arr[1].high + arr[1].low) / 2 && arr[0].low > MathAbs(arr[1].high + arr[1].low) / 2) ;
}
//+------------------------------------------------------------------+
//|   Function to create fibo using ChartObjectsFibo (chart object library)
//+------------------------------------------------------------------+
bool createFibo(const string objName, const datetime time1, const double price1, const datetime time2,
                const double price2, const color clr) {
//---
   if(fibo.Create(0, objName, 0, time1, price1, time2, price2)) {
      fibo.LevelsCount(2);//Set Number of FIBO levels
      fibo.LevelValue(0, 0.0);
      fibo.LevelWidth(0, 2);
      fibo.LevelStyle(0, STYLE_SOLID);
      fibo.LevelColor(0, clr);
      fibo.SetString(OBJPROP_LEVELTEXT, 0, "CRL - " + EnumToString(inpHTF));//Set text
      fibo.LevelValue(1, 1.0);
      fibo.LevelWidth(1, 2);
      fibo.LevelStyle(1, STYLE_SOLID);
      fibo.LevelColor(1, clr);
      fibo.SetString(OBJPROP_LEVELTEXT, 1, "CRH - " + EnumToString(inpHTF));
      fibo.Color(clrNONE);
      ChartRedraw();
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
