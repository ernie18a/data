//+------------------------------------------------------------------+
//|             CrashSpikeBoxMitigationFinal.mq5                     |
//|    Spike pattern + entry line that expires at mitigation         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property version   "1.0"
#property strict

//==== Input Parameters ====
input color    BoxColor     = clrRed;
input color    LineColor    = clrDodgerBlue;
input int      BoxWidth     = 2;
input int      LineWidth    = 1;
input ENUM_LINE_STYLE BoxStyle = STYLE_SOLID;
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID;

//==== Zone Struct ====
struct Zone
{
   datetime boxTime;
   double entryPrice;
   string lineName;
   bool mitigated;
};

Zone zones[100];
int zoneCount = 0;
datetime lastProcessedTime = 0;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   zoneCount = 0;
   lastProcessedTime = 0;
   ObjectsDeleteAll(0, "Box_");
   ObjectsDeleteAll(0, "Line_");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "Box_");
   ObjectsDeleteAll(0, "Line_");
}

//+------------------------------------------------------------------+
//| OnCalculate - Main processing function                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Process historical data on first run or when new data arrives
   if(prev_calculated == 0 || rates_total > prev_calculated)
   {
      ProcessHistory(rates_total, time, open, high, low, close);
   }
   
   // Process real-time data
   if(TimeCurrent() > lastProcessedTime)
   {
      ProcessRealtime();
      lastProcessedTime = TimeCurrent();
   }
   
   return rates_total;
}

//+------------------------------------------------------------------+
//| Process historical data                                          |
//+------------------------------------------------------------------+
void ProcessHistory(const int rates_total,
                   const datetime &time[],
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[])
{
   if(rates_total < 10) return;

   // ---- Pattern Detection ----
   for(int i = rates_total - 4; i >= 2; i--)
   {
      // Skip if we've already processed this candle
      if(time[i+2] <= lastProcessedTime) continue;
      
      double body1 = MathAbs(open[i] - close[i]);
      double wick1 = high[i] - low[i];
      bool isRedSpike1 = close[i] < open[i] && body1 > 0.7 * wick1;

      bool isGreenMid = close[i+1] > open[i+1];

      double body3 = MathAbs(open[i+2] - close[i+2]);
      double wick3 = high[i+2] - low[i+2];
      bool isRedSpike2 = close[i+2] < open[i+2] && body3 > 0.7 * wick3;

      if(isRedSpike1 && isGreenMid && isRedSpike2)
      {
         CreateZone(time[i], time[i+2], 
                   high[i], high[i+1], high[i+2],
                   low[i], low[i+1], low[i+2],
                   open[i+1]);
      }
   }

   // ---- Mitigation Detection ----
   CheckMitigationHistory(rates_total, time, low, high);
}

//+------------------------------------------------------------------+
//| Process real-time data                                           |
//+------------------------------------------------------------------+
void ProcessRealtime()
{
   MqlRates rt[];
   CopyRates(NULL, 0, 0, 4, rt); // Get last 4 candles
   
   if(ArraySize(rt) < 4) return;
   
   // Check if current candle is complete (for M1, wait until minute change)
   if(TimeCurrent() - rt[0].time < PeriodSeconds()) return;
   
   // Check pattern on completed candles
   for(int i = 3; i >= 2; i--)
   {
      // Skip if we've already processed this candle
      if(rt[i].time <= lastProcessedTime) continue;
      
      double body1 = MathAbs(rt[i-2].open - rt[i-2].close);
      double wick1 = rt[i-2].high - rt[i-2].low;
      bool isRedSpike1 = rt[i-2].close < rt[i-2].open && body1 > 0.7 * wick1;

      bool isGreenMid = rt[i-1].close > rt[i-1].open;

      double body3 = MathAbs(rt[i].open - rt[i].close);
      double wick3 = rt[i].high - rt[i].low;
      bool isRedSpike2 = rt[i].close < rt[i].open && body3 > 0.7 * wick3;

      if(isRedSpike1 && isGreenMid && isRedSpike2)
      {
         CreateZone(rt[i-2].time, rt[i].time,
                   rt[i-2].high, rt[i-1].high, rt[i].high,
                   rt[i-2].low, rt[i-1].low, rt[i].low,
                   rt[i-1].open);
      }
   }
   
   // Check for mitigation in real-time
   CheckMitigationRealtime();
}

//+------------------------------------------------------------------+
//| Create a new zone                                                |
//+------------------------------------------------------------------+
void CreateZone(datetime startTime, datetime endTime,
               double high1, double high2, double high3,
               double low1, double low2, double low3,
               double entryPrice)
{
   // Check duplicate
   bool exists = false;
   for(int j = 0; j < zoneCount; j++)
   {
      if(zones[j].boxTime == endTime)
      {
         exists = true;
         break;
      }
   }

   if(!exists && zoneCount < ArraySize(zones))
   {
      double top = MathMax(MathMax(high1, high2), high3);
      double bottom = MathMin(MathMin(low1, low2), low3);

      string boxName = "Box_" + IntegerToString((int)endTime);
      ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, startTime, top, endTime, bottom);
      ObjectSetInteger(0, boxName, OBJPROP_COLOR, BoxColor);
      ObjectSetInteger(0, boxName, OBJPROP_WIDTH, BoxWidth);
      ObjectSetInteger(0, boxName, OBJPROP_STYLE, BoxStyle);
      ObjectSetInteger(0, boxName, OBJPROP_BACK, true);

      // Draw extending entry line
      datetime futureTime = TimeCurrent() + PeriodSeconds() * 100;
      string lineName = "Line_" + IntegerToString((int)endTime);
      ObjectCreate(0, lineName, OBJ_TREND, 0, endTime, entryPrice, futureTime, entryPrice);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, LineColor);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, LineWidth);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, LineStyle);

      zones[zoneCount].boxTime = endTime;
      zones[zoneCount].entryPrice = entryPrice;
      zones[zoneCount].lineName = lineName;
      zones[zoneCount].mitigated = false;

      zoneCount++;
   }
}

//+------------------------------------------------------------------+
//| Check for mitigation in historical data                           |
//+------------------------------------------------------------------+
void CheckMitigationHistory(const int rates_total,
                           const datetime &time[],
                           const double &low[],
                           const double &high[])
{
   for(int j = 0; j < zoneCount; j++)
   {
      if(zones[j].mitigated) continue;

      for(int i = 1; i < rates_total; i++)
      {
         if(time[i] <= zones[j].boxTime) continue;

         if(low[i] <= zones[j].entryPrice && high[i] >= zones[j].entryPrice)
         {
            MitigateZone(j, time[i]);
            break;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check for mitigation in real-time                                |
//+------------------------------------------------------------------+
void CheckMitigationRealtime()
{
   MqlRates current[];
   CopyRates(NULL, 0, 0, 1, current);
   
   if(ArraySize(current) < 1) return;
   
   for(int j = 0; j < zoneCount; j++)
   {
      if(zones[j].mitigated) continue;
      
      if(current[0].low <= zones[j].entryPrice && current[0].high >= zones[j].entryPrice)
      {
         MitigateZone(j, current[0].time);
      }
   }
}

//+------------------------------------------------------------------+
//| Handle zone mitigation                                           |
//+------------------------------------------------------------------+
void MitigateZone(int zoneIndex, datetime mitigationTime)
{
   // Delete old line
   if(ObjectFind(0, zones[zoneIndex].lineName) >= 0)
      ObjectDelete(0, zones[zoneIndex].lineName);

   // Draw fixed-length line to mitigation candle
   string fixedName = zones[zoneIndex].lineName + "_Fixed";
   ObjectCreate(0, fixedName, OBJ_TREND, 0,
                zones[zoneIndex].boxTime, zones[zoneIndex].entryPrice,
                mitigationTime, zones[zoneIndex].entryPrice);
   ObjectSetInteger(0, fixedName, OBJPROP_COLOR, LineColor);
   ObjectSetInteger(0, fixedName, OBJPROP_WIDTH, LineWidth);
   ObjectSetInteger(0, fixedName, OBJPROP_STYLE, LineStyle);

   zones[zoneIndex].mitigated = true;
}