//+------------------------------------------------------------------+
//|                                        CandleReplayMagnifier.mq5 |
//|                                    Copyright 2025, ProtimeTrader |
//|                      https://www.mql5.com/en/users/protimetrader |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2025, ProtimeTrader"
#property link          "https://www.mql5.com/en/users/protimetrader"
#property version       "1.05"
#property description   "Visual replay magnifier for selected candles."
#property description   "Draws an overlay of candles from a past date over current chart."
#property description   "Highlight area auto-initialized; user selects replay date."

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- parameters for initial rectangle range
#define BAR_RANGE 32
#define PUSH(A,V) (A[ArrayResize(A, ArraySize(A) + 1) - 1] = V)

//--- inputs
input datetime InpReplayDate       = 0;                   // Date to replay candle data from
input color    InpMainZoneColor    = clrRed;              // Highlight color for the main (current) zone
input color    InpReplayZoneColor  = clrGreen;            // Highlight color for the replay (historical) zone
input color    InpBullColor        = clrAquamarine;       // Color for bullish (up) replay candles
input color    InpBearColor        = clrPink;             // Color for bearish (down) replay candles

//+------------------------------------------------------------------+
//| Class representing a single candle's data                        |
//+------------------------------------------------------------------+
class CCandleData
  {
public:
   datetime          time;
   double            open, high, low, close;

   void              CCandleData(datetime t, double o, double h, double l, double c)
     {
      time = t;
      open = o;
      high = h;
      low = l;
      close = c;
     }
  };

//--- internal constants
const string   m_OBJ_NAME_PREFIX  = "CRM_";
const string   m_OBJ_ZONE         = m_OBJ_NAME_PREFIX + "Zone";
const string   m_OBJ_REPLAY_ZONE  = m_OBJ_NAME_PREFIX + "ReplayZone";
const string   m_OBJ_BODY_PREFIX  = m_OBJ_NAME_PREFIX + "Body_";

//--- global variables
CCandleData *candles[];

datetime     m_replayDate = 0;
int          m_barRange;
double       m_zoneHigh, m_zoneLow;
int          m_index;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// set bar range to default.
   m_barRange = BAR_RANGE;

   m_replayDate = InpReplayDate;
   if(m_replayDate == 0)
     {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);

      dt.day--;             // Go to yesterday
      dt.hour = 0;
      dt.min  = 0;
      dt.sec  = 0;

      m_replayDate = StructToTime(dt);
      int dayOfWeek = dt.day_of_week;  // Sunday = 0, Saturday = 6

      if(dayOfWeek == 0)
        {
         PrintFormat("[CandleReplay] Note: %s is a Sunday. Market may be closed or have missing candles.",
                     TimeToString(m_replayDate, TIME_DATE));
        }
      else
         if(dayOfWeek == 6)
           {
            PrintFormat("[CandleReplay] Note: %s is a Saturday. Market may be closed or have missing candles.",
                        TimeToString(m_replayDate, TIME_DATE));
           }
     }

   if(_Period >= PERIOD_D1)
     {
      Alert("[CandleReplay]: This indicator is designed for intraday timeframes only. Please select a period lower than Daily.");
     }

// initializes the replay zone visuals and loads the historical candle data to display the replay overlay on the chart
   DrawZone();
   if(FetchReplayCandles())
      DrawReplayCandles();

// Print selected replay date and bar range
   PrintFormat("[CandleReplay] Initialized.\nReplay Date: %s\nBar Range: %d bars",
               TimeToString(m_replayDate, TIME_DATE),
               m_barRange);

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Cleanup                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int totalObjects = ObjectsDeleteAll(0, m_OBJ_NAME_PREFIX);
   PrintFormat("[CandleReplay] Deleted %d chart objects with prefix '%s'.", totalObjects, m_OBJ_NAME_PREFIX);

   int totalCandles = ArraySize(candles);
   for(int i = 0; i < totalCandles; ++i)
     {
      delete candles[i];
     }

   ArrayResize(candles, 0);
   PrintFormat("[CandleReplay] Cleared %d candle data objects from memory.", totalCandles);
  }

//+------------------------------------------------------------------+
//| Main calculation loop                                            |
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
   if(prev_calculated != rates_total)
     {
      ResizeZone();

      // Get the time of the left boundary of the zone from the chart object
      datetime t1 = (datetime)ObjectGetInteger(0, m_OBJ_REPLAY_ZONE, OBJPROP_TIME, 0);

      // Convert the retrieved time into a bar shift index to determine how many bars the zone spans
      m_barRange = iBarShift(_Symbol, _Period, t1);

      if(FetchReplayCandles())
         DrawReplayCandles();
     }

// If the latest price goes outside the defined zone boundaries, resize the zone to include it
   if(high[rates_total - 1] > m_zoneHigh || low[rates_total - 1] < m_zoneLow)
      ResizeZone();

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Handle chart events (e.g., dragging the zone rectangle)          |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
// When the user moves or changes the main zone object
   if((id == CHARTEVENT_OBJECT_CHANGE || id == CHARTEVENT_OBJECT_DRAG) && sparam == m_OBJ_ZONE)
     {
      // Get new start time from the updated zone object
      datetime t1 = (datetime)ObjectGetInteger(0, m_OBJ_ZONE, OBJPROP_TIME, 0);

      // Recalculate the bar range based on new start time
      m_barRange = iBarShift(_Symbol, _Period, t1);

      // Attempt to resize the visual zone rectangle
      if(!ResizeZone())
         Print("Failed to resize zone");

      // Delete previously drawn candle bodies to prepare for redrawing
      for(int i = 0; i < ArraySize(candles); ++i)
         ObjectDelete(0, m_OBJ_BODY_PREFIX + IntegerToString(i));  // <--- Candle body objects removed here

      // Fetch and redraw historical candles for the updated zone
      if(FetchReplayCandles())
         DrawReplayCandles();
     }
  }

//+------------------------------------------------------------------+
//| DrawZone                                                         |
//|                                                                  |
//| This function initializes the main zone rectangle by calculating |
//| the start and end time range (t1, t2) based on m_barRange, and   |
//| determining the highest high and lowest low within that range.   |
//| It then creates or updates the zone object and the associated    |
//| replay zone object on the chart.                                 |
//|                                                                  |
//| Returns:                                                         |
//|    true  - if the zone and replay zone are successfully created  |
//|    false - if object creation fails                              |
//+------------------------------------------------------------------+
bool DrawZone()
  {
// Determine start time (t1) based on the earliest bar in range
   datetime t1 = iTime(_Symbol, _Period, m_barRange);

// Determine end time (t2) symmetrically opposite to t1 from the current bar
   datetime t2 = iTime(_Symbol, _Period, 0) + (iTime(_Symbol, _Period, 0) - t1);

// Calculate the highest price in the selected range to define the zone top
   m_zoneHigh = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, m_barRange + 1, 0));

// Calculate the lowest price in the selected range to define the zone bottom
   m_zoneLow  = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, m_barRange + 1, 0));

// Attempt to create or update the zone rectangle on the chart
   if(!CreateOrUpdateObjectZone(t1, t2, m_zoneHigh, m_zoneLow))
      return false;

// Draw the replay zone for visual backtesting or analysis purposes
   CreateObjectReplayZone(t1, t2);

   return true;
  }

//+------------------------------------------------------------------+
//| Resize the zone rectangle on the chart                           |
//| This updates the existing zone object with new time and price    |
//| bounds based on the current m_barRange.                          |
//+------------------------------------------------------------------+
bool ResizeZone()
  {
   datetime t1 = iTime(_Symbol, _Period, m_barRange);
   datetime t2 = iTime(_Symbol, _Period, 0) + (iTime(_Symbol, _Period, 0) - iTime(_Symbol, _Period, m_barRange));

// Recalculate the zone's high and low based on the current visible range
   m_zoneHigh = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, m_barRange + 1, 0));
   m_zoneLow  = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, m_barRange + 1, 0));

// Attempt to update the zone rectangle with the new values
   if(!CreateOrUpdateObjectZone(t1, t2, m_zoneHigh, m_zoneLow))
     {
      PrintFormat("ResizeZone Error: Failed to update object '%s' on symbol %s (Period: %s, Range: %d bars)",
                  m_OBJ_ZONE, _Symbol, EnumToString(_Period), m_barRange);
      return false;
     }

   ObjectSetInteger(0, m_OBJ_REPLAY_ZONE, OBJPROP_TIME, 0, t1);
   ObjectSetInteger(0, m_OBJ_REPLAY_ZONE, OBJPROP_TIME, 1, t2);

   return true;
  }

//+------------------------------------------------------------------+
//| Fetch candle data from selected date or current day              |
//+------------------------------------------------------------------+
bool FetchReplayCandles()
  {
   MqlRates rates[];
   int copied = 0;
   int targetDay = 0;

// Handle fetching current day data
   if(OnSameDay())
     {
      copied = CopyRates(_Symbol, _Period, 0, m_barRange, rates);
     }
   else
     {
      // Align replay time to the current visible zone time (hour & minute matched)
      MqlDateTime zoneTime;
      datetime zoneEnd = (datetime)ObjectGetInteger(0, m_OBJ_ZONE, OBJPROP_TIME, 1);
      TimeToStruct(zoneEnd, zoneTime);

      MqlDateTime replayTime;
      TimeToStruct(m_replayDate, replayTime);
      replayTime.hour = zoneTime.hour;
      replayTime.min  = zoneTime.min;
      replayTime.sec  = 0;

      datetime fullTime = StructToTime(replayTime);

      // Find exact bar shift of this time
      int shift = iBarShift(_Symbol, _Period, fullTime, false);
      datetime target = iTime(_Symbol, _Period, shift);

      MqlDateTime targetStruct;
      TimeToStruct(target, targetStruct);
      targetDay = targetStruct.day;

      // Fetch a large enough range for matching candles
      int startShift = iBarShift(_Symbol, _Period, target);
      copied = CopyRates(_Symbol, _Period, startShift, m_barRange * 2 + 1, rates);
     }

   if(copied <= 0)
     {
      PrintFormat("[CRM] Failed to fetch candle data. Bars copied: %d", copied);
      return false;
     }

// Cleanup previously stored candles
   for(int i = 0; i < ArraySize(candles); ++i)
      delete candles[i];
   ArrayResize(candles, 0);

// Convert MqlRates to CCandleData and find replay index
   for(int i = 0; i < copied; ++i)
     {
      MqlDateTime rateTime;
      datetime candleTime = rates[i].time;
      TimeToStruct(candleTime, rateTime);

      int replayDay  = rateTime.day;
      int replayHour = rateTime.hour;
      int replayMin  = rateTime.min;

      // Match replay candle to the visual zone's starting bar
      MqlDateTime currentStruct;
      TimeToStruct(iTime(_Symbol, _Period, 0), currentStruct);

      if(replayDay == targetDay && currentStruct.hour == replayHour && currentStruct.min == replayMin)
         m_index = i;

      PUSH(candles, new CCandleData(rates[i].time, rates[i].open, rates[i].high, rates[i].low, rates[i].close));
     }

// Validation: Make sure valid index was found
   if(m_index < m_barRange && !OnSameDay())
     {
      PrintFormat("[CRM] Failed to find matching replay index (m_index = %d, expected ≥ %d)", m_index, m_barRange);
      return false;
     }

   if(ArraySize(candles) <= 0)
     {
      PrintFormat("[CRM] Candle array is empty after fetch.");
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| DrawReplayCandles: Draws replay candles as colored rectangles    |
//| overlaid on the current chart, shifted vertically to align with  |
//| current price levels. Updates the replay zone price bounds.      |
//+------------------------------------------------------------------+
void DrawReplayCandles()
  {
   int total = ArraySize(candles);
   if(total == 0)  // No candles to draw, exit early
      return;

   int candle_width = PeriodSeconds();  // Duration of one candle in seconds

// Calculate vertical price shift to align replay candles with current price
   double downwardShift = iOpen(_Symbol, _Period, 0) - (OnSameDay() ? candles[0].low : candles[m_index].open);
   downwardShift = OnSameDay() ? 0.0 : downwardShift;

// Initialize high and low price bounds for the replay zone
   double highPrice = candles[0].close + downwardShift;
   double lowPrice  = candles[0].close + downwardShift;

// Loop through replay candles (except last one) to draw each candle rectangle
   for(int i = 0; i < total - 1; ++i)
     {
      // Calculate candle start and end times relative to current time and bar range
      datetime t      = TimeCurrent() - PeriodSeconds() * (m_barRange - i);
      datetime t_next = t + candle_width;

      // Adjust replay candle prices by the vertical shift for overlay alignment
      double open  = candles[i].open  + downwardShift;
      double close = candles[i].close + downwardShift;
      double high  = candles[i].high  + downwardShift;
      double low   = candles[i].low   + downwardShift;

      // Update replay zone boundaries if this candle exceeds previous high or low
      if(high > highPrice)
         highPrice = high;
      if(low  < lowPrice)
         lowPrice  = low;

      // Draw the individual candle body as an object on the chart
      CreateObjectBody(i, t, t_next, open, close, high, low);
     }

// Set the price range (high and low) for the replay zone rectangle object
   ObjectSetDouble(0, m_OBJ_REPLAY_ZONE, OBJPROP_PRICE, 0, highPrice);
   ObjectSetDouble(0, m_OBJ_REPLAY_ZONE, OBJPROP_PRICE, 1, lowPrice);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OnSameDay()
  {
   MqlDateTime selected, now;
   TimeToStruct(m_replayDate, selected);
   TimeToStruct(TimeCurrent(), now);

   return (selected.year == now.year &&
           selected.mon  == now.mon  &&
           selected.day  == now.day);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateOrUpdateObjectZone(datetime t1, datetime t2, double high, double low)
  {
   if(ObjectFind(0, m_OBJ_ZONE) < 0)
     {
      // Create the zone if it does not exist
      if(!ObjectCreate(0, m_OBJ_ZONE, OBJ_RECTANGLE, 0, t1, high, t2, low))
         return false;

      ObjectSetInteger(0, m_OBJ_ZONE, OBJPROP_COLOR, InpMainZoneColor);
      ObjectSetInteger(0, m_OBJ_ZONE, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_OBJ_ZONE, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, m_OBJ_ZONE, OBJPROP_BACK, false);
      ObjectSetInteger(0, m_OBJ_ZONE, OBJPROP_FILL, false);
      ObjectSetInteger(0, m_OBJ_ZONE, OBJPROP_SELECTABLE, true);
     }
   else
     {
      // Update the zone if it already exists
      if(!ObjectSetInteger(0, m_OBJ_ZONE, OBJPROP_TIME, 1, t2))
         return false;

      ObjectSetInteger(0, m_OBJ_ZONE, OBJPROP_TIME, 0, t1);
      ObjectSetDouble(0, m_OBJ_ZONE, OBJPROP_PRICE, 0, high);
      ObjectSetDouble(0, m_OBJ_ZONE, OBJPROP_PRICE, 1, low);
     }

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObjectReplayZone(datetime t1, datetime t2)
  {
   ObjectCreate(0, m_OBJ_REPLAY_ZONE, OBJ_RECTANGLE, 0, t1, 0, t2, 0);
   ObjectSetInteger(0, m_OBJ_REPLAY_ZONE, OBJPROP_COLOR, InpReplayZoneColor);
   ObjectSetInteger(0, m_OBJ_REPLAY_ZONE, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, m_OBJ_REPLAY_ZONE, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetInteger(0, m_OBJ_REPLAY_ZONE, OBJPROP_BACK, false);
   ObjectSetInteger(0, m_OBJ_REPLAY_ZONE, OBJPROP_FILL, false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObjectBody(int i, datetime t, datetime t_next, double open, double close, double high, double low)
  {
   string name = m_OBJ_BODY_PREFIX + IntegerToString(i);
   double top = MathMax(open, close);
   double bottom = MathMin(open, close);
   color barColor = (close >= open) ? InpBullColor : InpBearColor;
   string direction = (close >= open) ? "Bullish" : "Bearish";
   double range = high - low;
   long volume = (long)iVolume(_Symbol, _Period, i);

   string tooltip = StringFormat("Time: %s\nOpen: %s\nHigh: %s\nLow: %s\nClose: %s\nRange: %s\nDirection: %s\nVolume: %ld",
                                 TimeToString(candles[i].time, TIME_DATE | TIME_MINUTES),
                                 DoubleToString(candles[i].open, _Digits),
                                 DoubleToString(candles[i].high, _Digits),
                                 DoubleToString(candles[i].low, _Digits),
                                 DoubleToString(candles[i].close, _Digits),
                                 DoubleToString(range, 3),
                                 direction,
                                 volume);

   ObjectCreate(0, name, OBJ_RECTANGLE, 0, t, top, t_next, bottom);
   ObjectSetInteger(0, name, OBJPROP_COLOR, barColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
  }
//+------------------------------------------------------------------+
