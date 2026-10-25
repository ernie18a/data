//+------------------------------------------------------------------+
//| StrategicVisual2MemorySequence.mq4                               |
//| Cross-chart candle sync. One host click, slaves follow.          |
//+------------------------------------------------------------------+
#property copyright "MQL5 x Tangerinelover1 x SuperGrok"
#property link      "https://www.mql5.com/en/users/tangerinelover1/seller"
#property version   "1.0"
#property strict
#property indicator_chart_window
#property description "Cross-chart candle sync for one symbol. IsHost=true on one chart only."
#property description "Host stays locked to the latest tick. Mouse crosshair shows the candle under the pointer."
#property description "Click snaps to that candle and publishes its open time and close."
#property description "Slave charts move their line to the host candle and align to it."
#property description "Attaches in candlestick mode, scale 5. Manual zoom-out is left alone."

input bool   IsHost             = false;        // Set to true on the host (master) chart only
input bool   LockHostToLatest   = true;         // Host stays on the newest bar while ticks arrive
input bool   DrawPriceLine      = true;         // Draw horizontal price line on all charts for reference
input bool   RightAlignOnSync   = true;         // Slaves align the host candle to the right edge
input bool   ShowMouseCrosshair = true;         // Host: coded crosshair follows the mouse pointer
input color  LineColor          = clrYellow;    // Color for the synced candle line
input color  CrosshairColor     = clrChartreuse;// Color for the host mouse crosshair
input int    LineWidthHost      = 3;            // Width of vertical line on host chart
input int    LineWidthSlave     = 1;            // Width of vertical line on slave charts
input bool   ShowLabels         = true;         // Show identification labels on charts
input int    FontSize           = 12;           // Font size for labels
input color  LabelColor         = clrWhite;     // Color for labels
input color  BullBodyColor      = clrChartreuse;// Bull candle body
input color  BearBodyColor      = clrIndigo;    // Bear candle body
input color  WickColor          = clrSkyBlue;// Wick, shadow, and candle border

string vline_name      = "SV2MS_VLine";
string hline_name      = "SV2MS_HLine";
string label_name      = "SV2MS_Label";
string tf_label_name   = "SV2MS_TFLabel";
string mouse_vline     = "SV2MS_MouseV";
string mouse_hline     = "SV2MS_MouseH";
string mouse_info_name = "SV2MS_MouseInfo";
string sync_time_var   = "";
string sync_price_var  = "";
string sync_period_var = "";
datetime last_sync_time = 0;
double   last_sync_price = 0.0;

//+------------------------------------------------------------------+
//| Timeframe label text                                             |
//+------------------------------------------------------------------+
string GetTimeframeString(int per)
{
   switch(per)
   {
      case PERIOD_M1:  return("M1");
      case PERIOD_M5:  return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1:  return("H1");
      case PERIOD_H4:  return("H4");
      case PERIOD_D1:  return("D1");
      case PERIOD_W1:  return("W1");
      case PERIOD_MN1: return("MN");
      default:         return(IntegerToString(per));
   }
}

//+------------------------------------------------------------------+
//| Candles, colors, and one-time zoom in. Manual zoom-out sticks.   |
//+------------------------------------------------------------------+
void ApplyChartStyle()
{
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, BullBodyColor);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, BearBodyColor);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, WickColor);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, WickColor);
   ChartSetInteger(0, CHART_SCALE, 5);
   ChartSetInteger(0, CHART_SHOW_OHLC, true);
}

//+------------------------------------------------------------------+
//| Keep the host viewing the newest bar only.                       |
//+------------------------------------------------------------------+
void LockHostChart()
{
   if(!IsHost || !LockHostToLatest)
      return;
   ChartSetInteger(0, CHART_AUTOSCROLL, true);
   ChartSetInteger(0, CHART_SHIFT, true);
}

//+------------------------------------------------------------------+
//| Center the large timeframe label after a resize.                 |
//+------------------------------------------------------------------+
void UpdateTFLabelPosition()
{
   if(ObjectFind(0, tf_label_name) < 0)
      return;

   long width = 0;
   long height = 0;
   ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0, width);
   ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, height);

   ObjectSetInteger(0, tf_label_name, OBJPROP_XDISTANCE, (int)(width / 2 - 20));
   ObjectSetInteger(0, tf_label_name, OBJPROP_YDISTANCE, (int)(height / 2));
}

//+------------------------------------------------------------------+
//| Slave charts jump to the host candle. Host does not leave latest.|
//+------------------------------------------------------------------+
void AlignSlaveToTime(datetime bar_time)
{
   if(IsHost && LockHostToLatest)
      return;
   if(!RightAlignOnSync)
      return;

   int bar = iBarShift(NULL, 0, bar_time, false);
   if(bar < 0)
      return;

   long vis = 0;
   ChartGetInteger(0, CHART_WIDTH_IN_BARS, 0, vis);
   if(vis < 1)
      vis = 1;

   int leftmost = bar + (int)vis - 1;
   if(leftmost < 0)
      leftmost = 0;
   ChartNavigate(0, CHART_BEGIN, leftmost);
   ChartSetInteger(0, CHART_AUTOSCROLL, (bar == 0));
}

//+------------------------------------------------------------------+
//| Publish the host candle and mark it on this chart.               |
//+------------------------------------------------------------------+
void PublishHostCandle(datetime bar_time, double bar_close)
{
   GlobalVariableSet(sync_time_var, (double)bar_time);
   GlobalVariableSet(sync_price_var, bar_close);
   GlobalVariableSet(sync_period_var, (double)Period());
   last_sync_time = bar_time;
   last_sync_price = bar_close;

   ObjectSetInteger(0, vline_name, OBJPROP_TIME1, bar_time);
   if(DrawPriceLine && ObjectFind(0, hline_name) >= 0)
      ObjectSetDouble(0, hline_name, OBJPROP_PRICE1, bar_close);

   if(ShowLabels && ObjectFind(0, label_name) >= 0)
   {
      ObjectSetString(0, label_name, OBJPROP_TEXT,
                      "Host | " + GetTimeframeString(Period()) +
                      " candle " + TimeToString(bar_time, TIME_DATE | TIME_MINUTES));
   }
   LockHostChart();
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   sync_time_var   = "SV2MS_" + _Symbol + "_Time";
   sync_price_var  = "SV2MS_" + _Symbol + "_Price";
   sync_period_var = "SV2MS_" + _Symbol + "_Period";

   ApplyChartStyle();
   if(IsHost && LockHostToLatest)
      ChartSetInteger(0, CHART_SHIFT, true);
   else
      ChartSetInteger(0, CHART_SHIFT, false);

   if(ObjectCreate(0, vline_name, OBJ_VLINE, 0, 0, 0))
   {
      ObjectSetInteger(0, vline_name, OBJPROP_COLOR, LineColor);
      ObjectSetInteger(0, vline_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, vline_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, vline_name, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, vline_name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, vline_name, OBJPROP_WIDTH, (IsHost ? LineWidthHost : LineWidthSlave));
      ObjectSetInteger(0, vline_name, OBJPROP_TIME1, iTime(NULL, 0, 0));
   }

   if(DrawPriceLine && ObjectCreate(0, hline_name, OBJ_HLINE, 0, 0, 0))
   {
      ObjectSetInteger(0, hline_name, OBJPROP_COLOR, LineColor);
      ObjectSetInteger(0, hline_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, hline_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, hline_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, hline_name, OBJPROP_WIDTH, 1);
      ObjectSetDouble(0, hline_name, OBJPROP_PRICE1, iClose(NULL, 0, 0));
   }

   if(ShowLabels && ObjectCreate(0, label_name, OBJ_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, label_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, label_name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, label_name, OBJPROP_YDISTANCE, 10);
      ObjectSetString(0, label_name, OBJPROP_TEXT,
                      (IsHost ? "Host Chart - click a candle to sync" : "Slave Chart - waiting for host"));
      ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(0, label_name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, label_name, OBJPROP_COLOR, LabelColor);
      ObjectSetInteger(0, label_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, label_name, OBJPROP_SELECTABLE, false);
   }

   string tf_str = GetTimeframeString(Period());
   if(ObjectCreate(0, tf_label_name, OBJ_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, tf_label_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetString(0, tf_label_name, OBJPROP_TEXT, tf_str);
      ObjectSetInteger(0, tf_label_name, OBJPROP_FONTSIZE, 40);
      ObjectSetString(0, tf_label_name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, tf_label_name, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, tf_label_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, tf_label_name, OBJPROP_SELECTABLE, false);
      UpdateTFLabelPosition();
   }

   if(IsHost && ShowMouseCrosshair)
   {
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

      if(ObjectCreate(0, mouse_vline, OBJ_VLINE, 0, 0, 0))
      {
         ObjectSetInteger(0, mouse_vline, OBJPROP_COLOR, CrosshairColor);
         ObjectSetInteger(0, mouse_vline, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, mouse_vline, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, mouse_vline, OBJPROP_BACK, false);
         ObjectSetInteger(0, mouse_vline, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, mouse_vline, OBJPROP_TIME1, iTime(NULL, 0, 0));
      }
      if(ObjectCreate(0, mouse_hline, OBJ_HLINE, 0, 0, 0))
      {
         ObjectSetInteger(0, mouse_hline, OBJPROP_COLOR, CrosshairColor);
         ObjectSetInteger(0, mouse_hline, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, mouse_hline, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, mouse_hline, OBJPROP_BACK, false);
         ObjectSetInteger(0, mouse_hline, OBJPROP_SELECTABLE, false);
         ObjectSetDouble(0, mouse_hline, OBJPROP_PRICE1, iClose(NULL, 0, 0));
      }
      if(ObjectCreate(0, mouse_info_name, OBJ_LABEL, 0, 0, 0))
      {
         ObjectSetInteger(0, mouse_info_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, mouse_info_name, OBJPROP_XDISTANCE, 10);
         ObjectSetInteger(0, mouse_info_name, OBJPROP_YDISTANCE, 28);
         ObjectSetString(0, mouse_info_name, OBJPROP_TEXT, "Crosshair: move over a candle");
         ObjectSetInteger(0, mouse_info_name, OBJPROP_FONTSIZE, FontSize);
         ObjectSetString(0, mouse_info_name, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, mouse_info_name, OBJPROP_COLOR, CrosshairColor);
         ObjectSetInteger(0, mouse_info_name, OBJPROP_BACK, false);
         ObjectSetInteger(0, mouse_info_name, OBJPROP_SELECTABLE, false);
      }
   }

   if(IsHost)
   {
      datetime init_time = iTime(NULL, 0, 0);
      double init_price = iClose(NULL, 0, 0);
      if(init_time > 0)
         PublishHostCandle(init_time, init_price);
      LockHostChart();
   }
   else
   {
      double dt_val = 0.0;
      if(GlobalVariableGet(sync_time_var, dt_val))
      {
         datetime init_time = (datetime)dt_val;
         ObjectSetInteger(0, vline_name, OBJPROP_TIME1, init_time);
         last_sync_time = init_time;
         AlignSlaveToTime(init_time);

         if(ShowLabels && ObjectFind(0, label_name) >= 0)
         {
            double host_period = 0.0;
            string host_tf = "host";
            if(GlobalVariableGet(sync_period_var, host_period))
               host_tf = GetTimeframeString((int)host_period);
            ObjectSetString(0, label_name, OBJPROP_TEXT,
                            "Slave | obeys " + host_tf + " candle " +
                            TimeToString(init_time, TIME_DATE | TIME_MINUTES));
         }
      }
      if(DrawPriceLine)
      {
         double init_price = 0.0;
         if(GlobalVariableGet(sync_price_var, init_price))
         {
            ObjectSetDouble(0, hline_name, OBJPROP_PRICE1, init_price);
            last_sync_price = init_price;
         }
      }
   }

   EventSetMillisecondTimer(500);
   ChartRedraw(0);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete(0, vline_name);
   ObjectDelete(0, hline_name);
   ObjectDelete(0, label_name);
   ObjectDelete(0, tf_label_name);
   ObjectDelete(0, mouse_vline);
   ObjectDelete(0, mouse_hline);
   ObjectDelete(0, mouse_info_name);

   if(IsHost)
   {
      GlobalVariableDel(sync_time_var);
      GlobalVariableDel(sync_price_var);
      GlobalVariableDel(sync_period_var);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer: slaves follow the host candle. Host stays on latest.      |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(IsHost)
   {
      LockHostChart();
      return;
   }

   double dt_val = 0.0;
   if(GlobalVariableGet(sync_time_var, dt_val))
   {
      datetime new_time = (datetime)dt_val;
      if(new_time != last_sync_time)
      {
         last_sync_time = new_time;
         ObjectSetInteger(0, vline_name, OBJPROP_TIME1, new_time);
         AlignSlaveToTime(new_time);

         if(ShowLabels && ObjectFind(0, label_name) >= 0)
         {
            double host_period = 0.0;
            string host_tf = "host";
            if(GlobalVariableGet(sync_period_var, host_period))
               host_tf = GetTimeframeString((int)host_period);
            ObjectSetString(0, label_name, OBJPROP_TEXT,
                            "Slave | obeys " + host_tf + " candle " +
                            TimeToString(new_time, TIME_DATE | TIME_MINUTES));
         }
         ChartRedraw(0);
      }
   }

   if(DrawPriceLine)
   {
      double new_price = 0.0;
      if(GlobalVariableGet(sync_price_var, new_price) && new_price != last_sync_price)
      {
         last_sync_price = new_price;
         ObjectSetDouble(0, hline_name, OBJPROP_PRICE1, new_price);
         ChartRedraw(0);
      }
   }
}

//+------------------------------------------------------------------+
//| Host crosshair follows the pointer. Click snaps to that candle.  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_MOUSE_MOVE && IsHost && ShowMouseCrosshair)
   {
      int x = (int)lparam;
      int y = (int)dparam;
      int subwindow = 0;
      datetime pointer_time = 0;
      double pointer_price = 0.0;

      if(ChartXYToTimePrice(0, x, y, subwindow, pointer_time, pointer_price))
      {
         if(ObjectFind(0, mouse_vline) >= 0)
            ObjectSetInteger(0, mouse_vline, OBJPROP_TIME1, pointer_time);
         if(ObjectFind(0, mouse_hline) >= 0)
            ObjectSetDouble(0, mouse_hline, OBJPROP_PRICE1, pointer_price);

         int bar = iBarShift(NULL, 0, pointer_time, false);
         if(bar >= 0 && ObjectFind(0, mouse_info_name) >= 0)
         {
            datetime candle_time = iTime(NULL, 0, bar);
            ObjectSetString(0, mouse_info_name, OBJPROP_TEXT,
                            "Candle " + TimeToString(candle_time, TIME_DATE | TIME_MINUTES) +
                            "  C " + DoubleToString(iClose(NULL, 0, bar), _Digits));
         }
         ChartRedraw(0);
      }
      return;
   }

   if(id == CHARTEVENT_CLICK && IsHost)
   {
      int x = (int)lparam;
      int y = (int)dparam;
      int subwindow = 0;
      datetime click_time = 0;
      double click_price = 0.0;

      if(ChartXYToTimePrice(0, x, y, subwindow, click_time, click_price))
      {
         int bar = iBarShift(NULL, 0, click_time, false);
         if(bar < 0)
            return;

         datetime bar_time = iTime(NULL, 0, bar);
         double bar_close = iClose(NULL, 0, bar);
         if(bar_time <= 0)
            return;

         PublishHostCandle(bar_time, bar_close);
         ChartRedraw(0);
      }
      return;
   }

   if(id == CHARTEVENT_CHART_CHANGE)
   {
      UpdateTFLabelPosition();
      LockHostChart();
      ChartRedraw(0);
   }
}
//+------------------------------------------------------------------+
