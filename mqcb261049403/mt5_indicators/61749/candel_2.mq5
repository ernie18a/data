//+------------------------------------------------------------------+
//|             BoomSpikeBoxMitigationFinal.mq5                      |
//|    Spike pattern + entry line that expires at mitigation         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property version   "1.0"
#property strict

//==== Input Parameters ====
input color    BoxColor     = clrBlue;
input color    LineColor    = clrLimeGreen;
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

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   zoneCount = 0;
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
//| OnCalculate                                                      |
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
   if (rates_total < 10)
      return prev_calculated;

   // ---- Pattern Detection ----
   for (int i = rates_total - 4; i >= 2; i--)
   {
      double body1 = MathAbs(open[i] - close[i]);
      double wick1 = high[i] - low[i];
      bool isGreenSpike1 = close[i] > open[i] && body1 > 0.7 * wick1;

      bool isRedMid = close[i+1] < open[i+1];

      double body3 = MathAbs(open[i+2] - close[i+2]);
      double wick3 = high[i+2] - low[i+2];
      bool isGreenSpike2 = close[i+2] > open[i+2] && body3 > 0.7 * wick3;

      if (isGreenSpike1 && isRedMid && isGreenSpike2)
      {
         datetime boxTime = time[i+2];
         double entryPrice = open[i+1];

         // Check duplicate
         bool exists = false;
         for (int j = 0; j < zoneCount; j++)
         {
            if (zones[j].boxTime == boxTime)
            {
               exists = true;
               break;
            }
         }

         if (!exists && zoneCount < ArraySize(zones))
         {
            double top = MathMax(MathMax(high[i], high[i+1]), high[i+2]);
            double bottom = MathMin(MathMin(low[i], low[i+1]), low[i+2]);

            string boxName = "Box_" + IntegerToString((int)boxTime);
            ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, time[i], top, boxTime, bottom);
            ObjectSetInteger(0, boxName, OBJPROP_COLOR, BoxColor);
            ObjectSetInteger(0, boxName, OBJPROP_WIDTH, BoxWidth);
            ObjectSetInteger(0, boxName, OBJPROP_STYLE, BoxStyle);
            ObjectSetInteger(0, boxName, OBJPROP_BACK, true);

            // Draw extending entry line
            datetime futureTime = TimeCurrent() + PeriodSeconds() * 100;
            string lineName = "Line_" + IntegerToString((int)boxTime);
            ObjectCreate(0, lineName, OBJ_TREND, 0, boxTime, entryPrice, futureTime, entryPrice);
            ObjectSetInteger(0, lineName, OBJPROP_COLOR, LineColor);
            ObjectSetInteger(0, lineName, OBJPROP_WIDTH, LineWidth);
            ObjectSetInteger(0, lineName, OBJPROP_STYLE, LineStyle);

            zones[zoneCount].boxTime = boxTime;
            zones[zoneCount].entryPrice = entryPrice;
            zones[zoneCount].lineName = lineName;
            zones[zoneCount].mitigated = false;

            zoneCount++;
         }
      }
   }

   // ---- Mitigation Detection ----
   for (int j = 0; j < zoneCount; j++)
   {
      if (zones[j].mitigated)
         continue;

      for (int i = 1; i < rates_total; i++)
      {
         if (time[i] <= zones[j].boxTime)
            continue;

         if (low[i] <= zones[j].entryPrice && high[i] >= zones[j].entryPrice)
         {
            if (ObjectFind(0, zones[j].lineName) >= 0)
               ObjectDelete(0, zones[j].lineName);

            string fixedName = zones[j].lineName + "_Fixed";
            ObjectCreate(0, fixedName, OBJ_TREND, 0,
                         zones[j].boxTime, zones[j].entryPrice,
                         time[i], zones[j].entryPrice);
            ObjectSetInteger(0, fixedName, OBJPROP_COLOR, LineColor);
            ObjectSetInteger(0, fixedName, OBJPROP_WIDTH, LineWidth);
            ObjectSetInteger(0, fixedName, OBJPROP_STYLE, LineStyle);

            zones[j].mitigated = true;
            break;
         }
      }
   }

   return rates_total;
}
