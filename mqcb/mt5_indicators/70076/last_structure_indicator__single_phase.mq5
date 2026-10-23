//+------------------------------------------------------------------+
#property copyright "© 2026, ChukwuBuikem"
#property link      "https://www.mql5.com/en/users/bikeen"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
#include <ChartObjects\ChartObjectsFibo.mqh>
#define DEF_OBJNAME "Last Structure Indicator" + (string)ObjectsTotal(0)

enum ENUM_STRUCTURE_MODE {
   STRUCTURE_MODE_WICK = 0,//Candle wick detection
   STRUCTURE_MODE_BODY = 1//Candle close detection
};
//---+
struct st_Chart {
//---
private:
   bool isSeparator;
public:
   st_Chart(): isSeparator((bool)ChartGetInteger(0, CHART_SHOW_PERIOD_SEP)) {}
   //---+
   void showSeparator() {
      //---
      ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
      ChartRedraw();
   }
   void restore() {
      ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, isSeparator);
      ChartRedraw();
   }
} chart;
input ENUM_STRUCTURE_MODE structMode = STRUCTURE_MODE_WICK;//Structure detection mode
input int rightLeftBars = 3;//Pivot strength (bars on each side)
input color levelColor = clrBlue;//Structure level draw color

CChartObjectTrend trendline;
int barsPerDay = -1, start = -1;
//+------------------------------------------------------------------+
//| Indicator initialization function                               |
//+------------------------------------------------------------------+
int OnInit() {
//---
   barsPerDay = 86400 / PeriodSeconds();//Number of bars per trading day (based on current timeframe)
   chart.showSeparator();//Enable chart period separators
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Indicator deinitialization function                               |
//+------------------------------------------------------------------+
void OnDeinit(const int32_t reason) {
   //---
   chart.restore();//Restore chart to original state on deinitialization
}
//+------------------------------------------------------------------+
//| Indicator calculation function                                   |
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
//-Detect new bars formation
   if(prev_calculated > 0 && rates_total != prev_calculated) {
      //--Ensure we have enough bars
      if(rates_total < barsPerDay)return rates_total;

      start = (prev_calculated == 0) ? barsPerDay : prev_calculated - 1;
      for(int w = start; w < rates_total && !IsStopped(); w++) {
         //-Detect new trading day
         if(isNewDay(time[w])) {
            //-Per new day
            MqlRates rates[];
            ArraySetAsSeries(rates, true);
            //-Copy needed candle data
            if((CopyRates(_Symbol, PERIOD_CURRENT, time[w], iTime(_Symbol, PERIOD_CURRENT, w + barsPerDay - 1), rates)) >= barsPerDay) {
               scanForStruture(rates, time[w]);
            }
         }
      }
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
// Function to detect new trading (independent of PERIOD_D1)
//+------------------------------------------------------------------+
bool isNewDay(const datetime barTime) {
//---
   static datetime lastDay = 0;
   MqlDateTime time;
   TimeToStruct(barTime, time);
   datetime currentDay = StructToTime(time);
   currentDay -= (time.hour * 3600 + time.min * 60 + time.sec);
   if(lastDay == 0) {
      lastDay = currentDay;
      return false;
   }
   if(currentDay != lastDay) {
      lastDay = currentDay;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
// Function to detect and validate a resistance level
//+------------------------------------------------------------------+
bool isValidResistance(const MqlRates & priceRates[], const int index) {
//---
   int totalBars = ArraySize(priceRates);
//--- Index boundary validation
   if(index >= totalBars - rightLeftBars - 1)return false;

   for(int w = 1; w <= rightLeftBars; w++) {
      if(index - w < 1)return false;
      if(rPrice(priceRates[index]) < rPrice(priceRates[index - w])) return false;
      if(rPrice(priceRates[index]) < rPrice(priceRates[index + w])) return false;
   }
   return true;
}
//+------------------------------------------------------------------+
// Function to detect and validate a support level
//+------------------------------------------------------------------+
bool isValidSupport(const MqlRates & priceRates[], const int index) {
//---
   int totalBars = ArraySize(priceRates);
//--- Index boundary validation
   if(index >= totalBars - (rightLeftBars + 1))return false;

   for(int w = 1; w <= rightLeftBars; w++) {
      if(index - w < 1)return false;
      if(sPrice(priceRates[index]) > sPrice(priceRates[index - w])) return false;
      if(sPrice(priceRates[index]) > sPrice(priceRates[index + w])) return false;
   }
   return true;
}
//+------------------------------------------------------------------+
// Function to return support reference price (body close or wick : low)
//+------------------------------------------------------------------+
double sPrice(const MqlRates & bar) {
//---
   return (structMode == STRUCTURE_MODE_BODY)
          ?  bar.close : bar.low;
}
//+------------------------------------------------------------------+
// Function to return resistance reference price (body close or wick : high)
//+------------------------------------------------------------------+
double rPrice(const MqlRates & bar) {
//-
   return (structMode == STRUCTURE_MODE_BODY)
          ?  bar.close : bar.high;
}
//+------------------------------------------------------------------+
// Function to ensure dtected structure was respected until day end
//+------------------------------------------------------------------+
bool isStructureBroken(const MqlRates & priceRates[],
                       const int index,
                       const bool isSupport) {
//--- Reference price
   double levelPrice = (isSupport) ? sPrice(priceRates[index]) : rPrice(priceRates[index]);
   datetime levelTime = priceRates[index].time;
   //--- End of previous trading day
   datetime prevDayEnd = iTime(_Symbol, PERIOD_D1, 0) - 1;
//--- Get bar shifts
   int fromShift = iBarShift(_Symbol, PERIOD_CURRENT, levelTime);
   int toShift   = iBarShift(_Symbol, PERIOD_CURRENT, prevDayEnd);
   if(fromShift < 0 || toShift < 0)
      return true;//treat as broken
//--- Bars count
   int bars = MathAbs(fromShift - toShift) + 1;
   MqlRates myRates[];
   if(CopyRates(_Symbol, PERIOD_CURRENT, levelTime, prevDayEnd, myRates) < bars) {
      Print(__FUNCTION__, ": insufficient bars data");
      return true;
   }
//--- Break validation
   for(int w = 0; w < bars; w++) {
      if(isSupport) {//SUPPORT
         if(myRates[w].close < levelPrice)
            return true;//broken
      } else if(!isSupport) {//RESISTNACE
         if(myRates[w].close > levelPrice)
            return true;//broken
      }
   }
   return false;//respected until day end
}
//+------------------------------------------------------------------+
// Function to scan,detect and draw trendline on valid levels
//+------------------------------------------------------------------+
bool scanForStruture(const MqlRates & priceRates[], const datetime extendTime) {
//---
   int bars = ArraySize(priceRates);
   int upper = bars - rightLeftBars - 1;

   for(int w = rightLeftBars; w <= upper; w++) {
      if(isValidResistance(priceRates, w) && !isStructureBroken(priceRates, w, false)) {
         createTrendline(DEF_OBJNAME, priceRates[w].time, rPrice(priceRates[w]), extendTime);
         return true;
      } else if (isValidSupport(priceRates, w) && !isStructureBroken(priceRates, w, true)) {
         createTrendline(DEF_OBJNAME, priceRates[w].time, sPrice(priceRates[w]), extendTime);
         return true;
      }
   }
   return false;
}
//+------------------------------------------------------------------+
// Function to create trendline using ChartObjectsFibo (chart object library)
//+------------------------------------------------------------------+
void createTrendline(const string objName, const datetime time1,
                     const double price, const datetime time2) {
//---
   if(ObjectFind(0, objName) == -1) {
      if(trendline.Create(0,  objName, 0, time1, price, time2, price)) {
         trendline.Color(levelColor);
         trendline.Selectable(false);
         trendline.Width(2);
         ChartRedraw();
         return;
      }
   }
}
//+------------------------------------------------------------------+
