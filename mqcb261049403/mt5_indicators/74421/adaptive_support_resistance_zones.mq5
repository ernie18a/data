//+------------------------------------------------------------------+
//|                         Adaptive Support Resistance Zones        |
//|                       Educational indicator for MQL5.com         |
//+------------------------------------------------------------------+
#property copyright "Talal N Z Aljarusha"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Maps confirmed price reaction areas and ranks them by repeated interaction, rejection and recency."
#property indicator_chart_window
#property indicator_plots 0

input int      InpLookbackBars       = 1200;          // Bars used for analysis
input int      InpPivotDepth         = 3;             // Bars on each side of a confirmed pivot
input int      InpATRPeriod          = 14;            // ATR period
input double   InpZoneWidthATR       = 0.18;          // Half zone width in ATR
input double   InpMergeDistanceATR   = 0.35;          // Merge distance in ATR
input int      InpReactionBars       = 8;             // Bars used to measure rejection
input int      InpMaxZonesPerSide    = 4;             // Maximum support/resistance zones
input int      InpMinimumTouches     = 2;             // Minimum merged interactions
input int      InpExtendBars         = 80;            // Extend zones into the future
input bool     InpShowStrength       = true;          // Show zone score
input color    InpSupportColor       = clrMediumSeaGreen;
input color    InpResistanceColor    = clrIndianRed;
input int      InpTransparency       = 62;             // 0 transparent, 255 opaque
input string   InpObjectPrefix       = "ASRZ_";

struct PriceZone
{
   double   center;
   double   half_width;
   double   rejection_sum;
   int      touches;
   datetime newest_touch;
   datetime oldest_touch;
   double   score;
};

PriceZone g_zones[];
datetime  g_last_bar = 0;

//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Adaptive Support Resistance Zones");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteObjects();
}

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
   if(rates_total < InpATRPeriod + InpPivotDepth * 2 + 10)
      return(rates_total);

   const datetime current_bar = iTime(_Symbol, _Period, 0);
   if(prev_calculated > 0 && current_bar == g_last_bar)
      return(rates_total);

   g_last_bar = current_bar;
   RebuildZones();
   return(rates_total);
}

//+------------------------------------------------------------------+
void RebuildZones()
{
   MqlRates rates[];
   const int requested = MathMax(100, InpLookbackBars);
   int copied = CopyRates(_Symbol, _Period, 1, requested, rates);
   if(copied < InpATRPeriod + InpPivotDepth * 2 + 10)
      return;

   ArraySetAsSeries(rates, false);
   ArrayResize(g_zones, 0);

   double atr[];
   BuildATR(rates, copied, atr);

   const int first = MathMax(InpATRPeriod, InpPivotDepth);
   const int last  = copied - InpPivotDepth - 1;

   for(int i = first; i <= last; i++)
   {
      if(atr[i] <= 0.0)
         continue;

      if(IsPivotHigh(rates, i, InpPivotDepth))
      {
         const double rejection = MeasureBearishRejection(rates, copied, i, atr[i]);
         AddCandidate(rates[i].high, atr[i], rejection, rates[i].time);
      }

      if(IsPivotLow(rates, i, InpPivotDepth))
      {
         const double rejection = MeasureBullishRejection(rates, copied, i, atr[i]);
         AddCandidate(rates[i].low, atr[i], rejection, rates[i].time);
      }
   }

   CalculateScores(rates[copied - 1].time);
   DrawZones(rates[copied - 1].close, rates[copied - 1].time);
}

//+------------------------------------------------------------------+
void BuildATR(const MqlRates &rates[], const int count, double &atr[])
{
   ArrayResize(atr, count);
   ArrayInitialize(atr, 0.0);

   double running = 0.0;
   for(int i = 1; i < count; i++)
   {
      const double tr = MathMax(rates[i].high - rates[i].low,
                                MathMax(MathAbs(rates[i].high - rates[i - 1].close),
                                        MathAbs(rates[i].low - rates[i - 1].close)));

      if(i <= InpATRPeriod)
      {
         running += tr;
         if(i == InpATRPeriod)
            atr[i] = running / InpATRPeriod;
      }
      else
      {
         atr[i] = (atr[i - 1] * (InpATRPeriod - 1) + tr) / InpATRPeriod;
      }
   }
}

//+------------------------------------------------------------------+
bool IsPivotHigh(const MqlRates &rates[], const int index, const int depth)
{
   for(int offset = 1; offset <= depth; offset++)
      if(rates[index].high <= rates[index - offset].high ||
         rates[index].high <  rates[index + offset].high)
         return(false);

   return(true);
}

//+------------------------------------------------------------------+
bool IsPivotLow(const MqlRates &rates[], const int index, const int depth)
{
   for(int offset = 1; offset <= depth; offset++)
      if(rates[index].low >= rates[index - offset].low ||
         rates[index].low >  rates[index + offset].low)
         return(false);

   return(true);
}

//+------------------------------------------------------------------+
double MeasureBearishRejection(const MqlRates &rates[], const int count,
                               const int index, const double atr)
{
   double lowest = rates[index].low;
   const int finish = MathMin(count - 1, index + MathMax(1, InpReactionBars));
   for(int i = index + 1; i <= finish; i++)
      lowest = MathMin(lowest, rates[i].low);

   return(MathMax(0.0, rates[index].high - lowest) / atr);
}

//+------------------------------------------------------------------+
double MeasureBullishRejection(const MqlRates &rates[], const int count,
                               const int index, const double atr)
{
   double highest = rates[index].high;
   const int finish = MathMin(count - 1, index + MathMax(1, InpReactionBars));
   for(int i = index + 1; i <= finish; i++)
      highest = MathMax(highest, rates[i].high);

   return(MathMax(0.0, highest - rates[index].low) / atr);
}

//+------------------------------------------------------------------+
void AddCandidate(const double price, const double atr,
                  const double rejection, const datetime touch_time)
{
   const double candidate_width = MathMax(_Point * 2.0, atr * InpZoneWidthATR);
   const double merge_distance  = MathMax(candidate_width, atr * InpMergeDistanceATR);

   int nearest = -1;
   double nearest_distance = DBL_MAX;

   for(int i = 0; i < ArraySize(g_zones); i++)
   {
      const double distance = MathAbs(price - g_zones[i].center);
      if(distance <= MathMax(merge_distance, g_zones[i].half_width) &&
         distance < nearest_distance)
      {
         nearest = i;
         nearest_distance = distance;
      }
   }

   if(nearest < 0)
   {
      const int size = ArraySize(g_zones);
      ArrayResize(g_zones, size + 1);
      g_zones[size].center        = price;
      g_zones[size].half_width    = candidate_width;
      g_zones[size].rejection_sum = rejection;
      g_zones[size].touches       = 1;
      g_zones[size].newest_touch  = touch_time;
      g_zones[size].oldest_touch  = touch_time;
      g_zones[size].score         = 0.0;
      return;
   }

   PriceZone zone = g_zones[nearest];
   const double old_weight = (double)zone.touches;
   zone.center = (zone.center * old_weight + price) / (old_weight + 1.0);
   zone.half_width = MathMax(zone.half_width, candidate_width);
   zone.rejection_sum += rejection;
   zone.touches++;
   zone.newest_touch = MathMax(zone.newest_touch, touch_time);
   zone.oldest_touch = MathMin(zone.oldest_touch, touch_time);
   g_zones[nearest] = zone;
}

//+------------------------------------------------------------------+
void CalculateScores(const datetime newest_bar)
{
   const double period_seconds = MathMax(60, PeriodSeconds(_Period));
   const double lookback = MathMax(1.0, (double)InpLookbackBars);

   for(int i = 0; i < ArraySize(g_zones); i++)
   {
      const double age_bars = (double)(newest_bar - g_zones[i].newest_touch) / period_seconds;
      const double recency  = MathMax(0.0, 1.0 - age_bars / lookback);
      const double average_rejection = g_zones[i].rejection_sum / MathMax(1, g_zones[i].touches);
      const double touch_score = MathMin(1.0, g_zones[i].touches / 5.0);
      const double rejection_score = MathMin(1.0, average_rejection / 3.0);

      g_zones[i].score = 100.0 * (0.45 * touch_score +
                                  0.35 * rejection_score +
                                  0.20 * recency);
   }
}

//+------------------------------------------------------------------+
void DrawZones(const double current_price, const datetime last_bar_time)
{
   DeleteObjects();

   int support_indices[];
   int resistance_indices[];

   for(int i = 0; i < ArraySize(g_zones); i++)
   {
      if(g_zones[i].touches < MathMax(1, InpMinimumTouches))
         continue;

      if(g_zones[i].center <= current_price)
         AppendIndex(support_indices, i);
      else
         AppendIndex(resistance_indices, i);
   }

   SortIndicesByScore(support_indices);
   SortIndicesByScore(resistance_indices);

   const datetime right_time = last_bar_time +
      MathMax(60, PeriodSeconds(_Period)) * MathMax(5, InpExtendBars);

   DrawSelected(support_indices, true, right_time);
   DrawSelected(resistance_indices, false, right_time);
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
void AppendIndex(int &indices[], const int value)
{
   const int size = ArraySize(indices);
   ArrayResize(indices, size + 1);
   indices[size] = value;
}

//+------------------------------------------------------------------+
void SortIndicesByScore(int &indices[])
{
   for(int i = 0; i < ArraySize(indices) - 1; i++)
      for(int j = i + 1; j < ArraySize(indices); j++)
         if(g_zones[indices[j]].score > g_zones[indices[i]].score)
         {
            const int temp = indices[i];
            indices[i] = indices[j];
            indices[j] = temp;
         }
}

//+------------------------------------------------------------------+
void DrawSelected(const int &indices[], const bool support,
                  const datetime right_time)
{
   const int count = MathMin(ArraySize(indices), MathMax(1, InpMaxZonesPerSide));

   for(int rank = 0; rank < count; rank++)
   {
      const PriceZone zone = g_zones[indices[rank]];
      const string side = support ? "SUP_" : "RES_";
      const string name = InpObjectPrefix + side + IntegerToString(rank);
      const color base_color = support ? InpSupportColor : InpResistanceColor;
      const color fill_color = (color)ColorToARGB(base_color,
         (uchar)MathMax(0, MathMin(255, InpTransparency)));

      if(ObjectCreate(0, name, OBJ_RECTANGLE, 0, zone.oldest_touch,
                      zone.center + zone.half_width, right_time,
                      zone.center - zone.half_width))
      {
         ObjectSetInteger(0, name, OBJPROP_COLOR, fill_color);
         ObjectSetInteger(0, name, OBJPROP_FILL, true);
         ObjectSetInteger(0, name, OBJPROP_BACK, true);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      }

      if(InpShowStrength)
      {
         const string label_name = name + "_LABEL";
         const string label = (support ? "Support" : "Resistance") +
            "  " + IntegerToString((int)MathRound(zone.score)) + "%  |  " +
            IntegerToString(zone.touches) + " touches";

         if(ObjectCreate(0, label_name, OBJ_TEXT, 0, right_time,
                         zone.center))
         {
            ObjectSetString(0, label_name, OBJPROP_TEXT, label);
            ObjectSetInteger(0, label_name, OBJPROP_COLOR, base_color);
            ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, 8);
            ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, ANCHOR_RIGHT);
            ObjectSetInteger(0, label_name, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, label_name, OBJPROP_HIDDEN, true);
         }
      }
   }
}

//+------------------------------------------------------------------+
void DeleteObjects()
{
   for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
   {
      const string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, InpObjectPrefix) == 0)
         ObjectDelete(0, name);
   }
}

