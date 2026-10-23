//+------------------------------------------------------------------+
//|                                         SessionRangeBreakout.mq5 |
//|                              Session Range Visualizer for XAUUSD |
//|                               Free indicator - Code Base edition |
//+------------------------------------------------------------------+
#property copyright   "nazarkeyko"
#property link        "https://www.mql5.com/en/users/nazarkeyko"
#property version     "1.10"
#property description "Session Range Breakout Indicator for XAUUSD"
#property description ""
#property description "Visualizes Asian session consolidation range and"
#property description "London breakout trigger levels with colored zones,"
#property description "thick breakout lines, and arrow signals."
#property description ""
#property description "Best on M15. Automated version: London Gold Breakout EA"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6

//--- Plot 1-2: Range band (thick blue)
#property indicator_label1  "Range High"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Range Low"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Plot 3-4: Breakout triggers (thick green/red)
#property indicator_label3  "Buy Trigger"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_DASH
#property indicator_width3  3

#property indicator_label4  "Sell Trigger"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrangeRed
#property indicator_style4  STYLE_DASH
#property indicator_width4  3

//--- Plot 5-6: Arrows on breakout
#property indicator_label5  "Buy Arrow"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrLime
#property indicator_width5  3

#property indicator_label6  "Sell Arrow"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrOrangeRed
#property indicator_width6  3

//--- Inputs
input group "--- SESSION TIMES (Server Time) ---"
input int    InpRangeStartHour  = 0;        // Range start hour
input int    InpRangeStartMin   = 0;        // Range start minute
input int    InpRangeEndHour    = 6;        // Range end hour
input int    InpRangeEndMin     = 0;        // Range end minute
input int    InpTradeEndHour    = 10;       // Trade window end hour
input int    InpTradeEndMin     = 0;        // Trade window end minute

input group "--- DISPLAY ---"
input int    InpBreakoutBuffer  = 20;       // Breakout buffer (points)
input color  InpBoxColorBull    = C'0,40,80';   // Box color (range zone)
input color  InpBoxBorder       = clrDodgerBlue; // Box border color
input int    InpMaxDays         = 50;       // Max days to display

input group "--- ALERTS ---"
input bool   InpAlertBreakout   = true;     // Alert on breakout
input bool   InpPushAlert       = false;    // Push notification

//--- Buffers
double bufHigh[];
double bufLow[];
double bufBuyTrigger[];
double bufSellTrigger[];
double bufBuyArrow[];
double bufSellArrow[];

//--- Day tracking
int    gDayList[];
double gDayHigh[];
double gDayLow[];
bool   gDayReady[];
bool   gDayAlertUp[];
bool   gDayAlertDn[];
int    gDayCount = 0;

//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, bufHigh, INDICATOR_DATA);
   SetIndexBuffer(1, bufLow, INDICATOR_DATA);
   SetIndexBuffer(2, bufBuyTrigger, INDICATOR_DATA);
   SetIndexBuffer(3, bufSellTrigger, INDICATOR_DATA);
   SetIndexBuffer(4, bufBuyArrow, INDICATOR_DATA);
   SetIndexBuffer(5, bufSellArrow, INDICATOR_DATA);
   
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   
   //--- Arrow codes
   PlotIndexSetInteger(4, PLOT_ARROW, 233);  // Up arrow
   PlotIndexSetInteger(5, PLOT_ARROW, 234);  // Down arrow
   
   IndicatorSetString(INDICATOR_SHORTNAME, "Session Range Breakout");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   ArrayResize(gDayList, InpMaxDays);
   ArrayResize(gDayHigh, InpMaxDays);
   ArrayResize(gDayLow, InpMaxDays);
   ArrayResize(gDayReady, InpMaxDays);
   ArrayResize(gDayAlertUp, InpMaxDays);
   ArrayResize(gDayAlertDn, InpMaxDays);
   gDayCount = 0;
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "SRB_");
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
int GetDayInt(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return dt.year * 10000 + dt.mon * 100 + dt.day;
}

int GetMins(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return dt.hour * 60 + dt.min;
}

//+------------------------------------------------------------------+
int FindOrCreateDay(int day)
{
   for(int i = 0; i < gDayCount; i++)
      if(gDayList[i] == day) return i;
   
   if(gDayCount >= InpMaxDays)
   {
      // Remove oldest
      string oldBox = "SRB_Box_" + IntegerToString(gDayList[0]);
      string oldLbl = "SRB_Lbl_" + IntegerToString(gDayList[0]);
      ObjectDelete(0, oldBox);
      ObjectDelete(0, oldLbl);
      for(int i = 0; i < gDayCount - 1; i++)
      {
         gDayList[i] = gDayList[i+1];
         gDayHigh[i] = gDayHigh[i+1];
         gDayLow[i] = gDayLow[i+1];
         gDayReady[i] = gDayReady[i+1];
         gDayAlertUp[i] = gDayAlertUp[i+1];
         gDayAlertDn[i] = gDayAlertDn[i+1];
      }
      gDayCount--;
   }
   
   int idx = gDayCount;
   gDayList[idx] = day;
   gDayHigh[idx] = 0;
   gDayLow[idx] = 999999;
   gDayReady[idx] = false;
   gDayAlertUp[idx] = false;
   gDayAlertDn[idx] = false;
   gDayCount++;
   return idx;
}

//+------------------------------------------------------------------+
void DrawRangeBox(int dayIdx, datetime tStart, datetime tEnd)
{
   string boxName = "SRB_Box_" + IntegerToString(gDayList[dayIdx]);
   double hi = gDayHigh[dayIdx];
   double lo = gDayLow[dayIdx];
   
   if(ObjectFind(0, boxName) >= 0)
      ObjectDelete(0, boxName);
   
   ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, tStart, hi, tEnd, lo);
   ObjectSetInteger(0, boxName, OBJPROP_COLOR, InpBoxColorBull);
   ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
   ObjectSetInteger(0, boxName, OBJPROP_BACK, true);
   ObjectSetInteger(0, boxName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, boxName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, boxName, OBJPROP_HIDDEN, true);
   
   // Label with range width
   string lblName = "SRB_Lbl_" + IntegerToString(gDayList[dayIdx]);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int width = 0;
   if(point > 0)
      width = (int)MathRound((hi - lo) / point);
   
   if(ObjectFind(0, lblName) >= 0)
      ObjectDelete(0, lblName);
   
   string labelText = IntegerToString(width) + " pts";
   ObjectCreate(0, lblName, OBJ_TEXT, 0, tStart, hi + 2.0);
   ObjectSetString(0, lblName, OBJPROP_TEXT, labelText);
   ObjectSetInteger(0, lblName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, lblName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, lblName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, lblName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, lblName, OBJPROP_HIDDEN, true);
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
   if(rates_total < 50) return 0;
   
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double buf = InpBreakoutBuffer * point;
   
   int rangeStart = InpRangeStartHour * 60 + InpRangeStartMin;
   int rangeEnd = InpRangeEndHour * 60 + InpRangeEndMin;
   int tradeEnd = InpTradeEndHour * 60 + InpTradeEndMin;
   
   int start = (prev_calculated == 0) ? MathMax(0, rates_total - InpMaxDays * 96) : prev_calculated - 1;
   
   for(int i = start; i < rates_total; i++)
   {
      bufHigh[i] = EMPTY_VALUE;
      bufLow[i] = EMPTY_VALUE;
      bufBuyTrigger[i] = EMPTY_VALUE;
      bufSellTrigger[i] = EMPTY_VALUE;
      bufBuyArrow[i] = EMPTY_VALUE;
      bufSellArrow[i] = EMPTY_VALUE;
      
      int day = GetDayInt(time[i]);
      int mins = GetMins(time[i]);
      int dIdx = FindOrCreateDay(day);
      
      // Accumulate range during Asian session
      if(mins >= rangeStart && mins < rangeEnd)
      {
         if(high[i] > gDayHigh[dIdx]) gDayHigh[dIdx] = high[i];
         if(low[i] < gDayLow[dIdx]) gDayLow[dIdx] = low[i];
      }
      
      // Mark ready after range end
      if(mins >= rangeEnd && !gDayReady[dIdx])
      {
         if(gDayHigh[dIdx] > 0 && gDayLow[dIdx] < 999999)
         {
            gDayReady[dIdx] = true;
            // Draw box from range start to trade end
            datetime boxStart = time[i] - (long)(mins - rangeStart) * 60;
            datetime boxEnd = time[i] + (long)(tradeEnd - mins) * 60;
            DrawRangeBox(dIdx, boxStart, boxEnd);
         }
      }
      
      // Draw levels during trade window
      if(gDayReady[dIdx] && mins >= rangeEnd && mins <= tradeEnd)
      {
         bufHigh[i] = gDayHigh[dIdx];
         bufLow[i] = gDayLow[dIdx];
         bufBuyTrigger[i] = gDayHigh[dIdx] + buf;
         bufSellTrigger[i] = gDayLow[dIdx] - buf;
         
         // Breakout arrows
         if(close[i] > gDayHigh[dIdx] + buf && !gDayAlertUp[dIdx])
         {
            bufBuyArrow[i] = low[i] - 2.0;
            gDayAlertUp[dIdx] = true;
            
            if(i == rates_total - 1 && InpAlertBreakout)
            {
               Alert("SRB: Breakout UP! ", _Symbol, " at ", DoubleToString(close[i], 2));
               if(InpPushAlert)
                  SendNotification("SRB BUY: " + _Symbol + " " + DoubleToString(close[i], 2));
            }
         }
         
         if(close[i] < gDayLow[dIdx] - buf && !gDayAlertDn[dIdx])
         {
            bufSellArrow[i] = high[i] + 2.0;
            gDayAlertDn[dIdx] = true;
            
            if(i == rates_total - 1 && InpAlertBreakout)
            {
               Alert("SRB: Breakout DOWN! ", _Symbol, " at ", DoubleToString(close[i], 2));
               if(InpPushAlert)
                  SendNotification("SRB SELL: " + _Symbol + " " + DoubleToString(close[i], 2));
            }
         }
      }
   }
   
   return rates_total;
}
//+------------------------------------------------------------------+
