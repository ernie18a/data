//+------------------------------------------------------------------+
//| StrategicVisual2MemorySequence.mq5                               |
//| Copyright © MQL5 x Tangerinelover1                               |
//+------------------------------------------------------------------+
#property copyright "MQL5 x Tangerinelover1"
#property link      "https://www.mql5.com/en/users/tangerinelover1/seller"
#property version   "5.24"
#property indicator_chart_window
#property indicator_plots 0
#property description "Cross-chart time sync for one symbol. Set IsHost=true on exactly one chart."
#property description "Host writes the selected candle onto every same-symbol chart."
#property description "MT5 EventChartCustom + ChartRedraw wakes all tabs. No DLL."
#property description "Starts at maximum zoom. Manual wheel zoom-out is allowed after attach."
#property description "Indigo candle bodies. Chartreuse wicks."

#define SV2MS_EVENT 222

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input bool   IsHost             = false;        // true on the host (master) chart only
input bool   HostLockToLatest   = true;         // Host stays pinned to incoming ticks
input bool   AutoFollowHostBar  = true;         // Host live bar is published without a new click
input bool   WakeAllCharts      = true;         // Broadcast + redraw every same-symbol chart
input bool   ShowHostCrosshair  = true;         // Host mouse crosshair snapped to candle
input bool   DrawPriceLine      = true;         // Horizontal close line on all charts
input bool   DrawHostCandleBox  = true;         // Box covering the selected host candle window
input bool   RightAlignOnSync   = true;         // Slaves keep the host window visible
input bool   ForceCandlesticks  = true;         // Keep CHART_CANDLES (never bars/line)
input bool   StartMaxZoom       = true;         // Start at CHART_SCALE = 5; manual zoom-out allowed
input int    DesiredVisibleBars = 0;            // Used only if StartMaxZoom = false (0 = skip)
input color  LineColor          = clrYellow;    // Sync line / selected-box color
input color  CrosshairColor     = clrAqua;      // Host live crosshair color
input color  HoverBoxColor      = clrDodgerBlue;// Host hover candle box
input int    LineWidthHost      = 3;            // Vertical line width on host
input int    LineWidthSlave     = 1;            // Vertical line width on slaves
input bool   ShowLabels         = true;         // Corner host/slave labels
input int    FontSize           = 12;           // Label font size
input color  LabelColor         = clrGray;     // Label color
input color  CandleColor        = clrIndigo;    // Bull and bear candle body color
input color  WickColor          = clrChartreuse;// Bull and bear wick/border color

string vline_name      = "SV2MS_VLine";
string vline_end_name  = "SV2MS_VLineEnd";
string hline_name      = "SV2MS_HLine";
string label_name      = "SV2MS_Label";
string tf_label_name   = "SV2MS_TFLabel";
string xh_v_name       = "SV2MS_XH_V";
string xh_h_name       = "SV2MS_XH_H";
string hover_box_name  = "SV2MS_HoverBox";
string select_box_name = "SV2MS_SelectBox";

string sync_time_var    = "";
string sync_end_var     = "";
string sync_price_var   = "";
string sync_period_var  = "";
string sync_seq_var     = "";

datetime last_sync_time    = 0;
datetime last_sync_end     = 0;
double   last_sync_price   = 0.0;
int      last_sync_period  = 0;
datetime last_applied_time = 0;
datetime last_applied_end  = 0;
double   last_seq          = 0.0;
bool     last_align_ok     = false;
datetime last_live_bar     = 0;

//+------------------------------------------------------------------+
int TfSeconds(const int per)
  {
   if(per <= 0)
      return((int)PeriodSeconds(PERIOD_CURRENT));
   int sec = (int)PeriodSeconds((ENUM_TIMEFRAMES)per);
   if(sec <= 0)
      return((int)PeriodSeconds(PERIOD_CURRENT));
   return(sec);
  }

//+------------------------------------------------------------------+
string GetTimeframeString(const int per)
  {
   switch(per)
     {
      case PERIOD_M1:
         return("M1");
      case PERIOD_M2:
         return("M2");
      case PERIOD_M3:
         return("M3");
      case PERIOD_M4:
         return("M4");
      case PERIOD_M5:
         return("M5");
      case PERIOD_M6:
         return("M6");
      case PERIOD_M10:
         return("M10");
      case PERIOD_M12:
         return("M12");
      case PERIOD_M15:
         return("M15");
      case PERIOD_M20:
         return("M20");
      case PERIOD_M30:
         return("M30");
      case PERIOD_H1:
         return("H1");
      case PERIOD_H2:
         return("H2");
      case PERIOD_H3:
         return("H3");
      case PERIOD_H4:
         return("H4");
      case PERIOD_H6:
         return("H6");
      case PERIOD_H8:
         return("H8");
      case PERIOD_H12:
         return("H12");
      case PERIOD_D1:
         return("D1");
      case PERIOD_W1:
         return("W1");
      case PERIOD_MN1:
         return("MN");
      default:
         return(IntegerToString(per));
     }
  }

//+------------------------------------------------------------------+
void SetVisibleBars(const long cid, const int desired)
  {
   if(desired <= 0)
      return;

   int best_scale = 0;
   long min_diff = 2147483647;
   int scale;

   for(scale = 0; scale <= 5; scale++)
     {
      ChartSetInteger(cid, CHART_SCALE, scale);
      ChartRedraw(cid);

      long vis = ChartGetInteger(cid, CHART_WIDTH_IN_BARS);
      long diff = MathAbs(vis - desired);
      if(diff < min_diff)
        {
         min_diff = diff;
         best_scale = scale;
        }
     }

   ChartSetInteger(cid, CHART_SCALE, best_scale);
   ChartRedraw(cid);
  }

//+------------------------------------------------------------------+
void ApplyForcedCandles()
  {
   if(!ForceCandlesticks)
      return;

   if((int)ChartGetInteger(0, CHART_MODE) != CHART_CANDLES)
      ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
  }

//+------------------------------------------------------------------+
void ApplyCandleColors()
  {
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, CandleColor);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, CandleColor);
   ChartSetInteger(0, CHART_COLOR_CHART_UP,    WickColor);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN,  WickColor);
  }

//+------------------------------------------------------------------+
void ApplyStartupZoom()
  {
   if(StartMaxZoom)
     {
      if(ChartGetInteger(0, CHART_SCALE) != 5)
         ChartSetInteger(0, CHART_SCALE, 5);
     }
   else
      SetVisibleBars(0, DesiredVisibleBars);
  }

//+------------------------------------------------------------------+
void ApplyHostLockState()
  {
   if(IsHost && HostLockToLatest)
     {
      ChartSetInteger(0, CHART_AUTOSCROLL, true);
      ChartSetInteger(0, CHART_SHIFT, true);
     }
  }

//+------------------------------------------------------------------+
void RightAlignBarOnChart(const long cid, const int bar)
  {
   if(bar < 0)
      return;

   ChartSetInteger(cid, CHART_AUTOSCROLL, false);

   int extra = 1;
   if(ChartGetInteger(cid, CHART_SHIFT) != 0)
      extra = 2;

   ChartNavigate(cid, CHART_END, -bar - extra);
  }

//+------------------------------------------------------------------+
int ClampBarOn(const string sym, const ENUM_TIMEFRAMES tf, const int bar)
  {
   if(bar < 0)
      return(-1);

   int bars_avail = Bars(sym, tf);
   if(bars_avail <= 0)
      return(-1);
   if(bar > bars_avail - 1)
      return(bars_avail - 1);
   return(bar);
  }

//+------------------------------------------------------------------+
void UpdateTFLabelPosition()
  {
   if(ObjectFind(0, tf_label_name) < 0)
      return;

   long width  = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   long height = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   ObjectSetInteger(0, tf_label_name, OBJPROP_XDISTANCE, (int)(width / 2 - 20));
   ObjectSetInteger(0, tf_label_name, OBJPROP_YDISTANCE, (int)(height / 2));
  }

//+------------------------------------------------------------------+
void KickChart(const long cid)
  {
   EventChartCustom(cid, SV2MS_EVENT, (long)last_sync_period, last_sync_price, "SV2MS");
   ChartRedraw(cid);
  }

//+------------------------------------------------------------------+
bool EnsureVLineOnChart(const long cid, const string name, const color clr, const int width, const int style)
  {
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)ChartPeriod(cid);
   datetime t0 = iTime(ChartSymbol(cid), tf, 0);
   if(t0 <= 0)
      t0 = TimeCurrent();

   if(ObjectFind(cid, name) < 0)
     {
      if(!ObjectCreate(cid, name, OBJ_VLINE, 0, t0, 0))
         return(false);
     }

   ObjectSetInteger(cid, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(cid, name, OBJPROP_STYLE, style);
   ObjectSetInteger(cid, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(cid, name, OBJPROP_BACK, false);
   ObjectSetInteger(cid, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(cid, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(cid, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(cid, name, OBJPROP_RAY, true);
   return(true);
  }

//+------------------------------------------------------------------+
bool EnsureHLineOnChart(const long cid, const string name, const color clr)
  {
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)ChartPeriod(cid);
   double p0 = iClose(ChartSymbol(cid), tf, 0);

   if(ObjectFind(cid, name) < 0)
     {
      if(!ObjectCreate(cid, name, OBJ_HLINE, 0, 0, p0))
         return(false);
     }

   ObjectSetInteger(cid, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(cid, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(cid, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(cid, name, OBJPROP_BACK, false);
   ObjectSetInteger(cid, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(cid, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(cid, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(cid, name, OBJPROP_RAY, true);
   return(true);
  }

//+------------------------------------------------------------------+
bool EnsureRectangleOnChart(const long cid, const string name, const color clr)
  {
   string sym = ChartSymbol(cid);
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)ChartPeriod(cid);
   datetime t1 = iTime(sym, tf, 0);
   if(t1 <= 0)
      t1 = TimeCurrent();
   datetime t2 = t1 + PeriodSeconds(tf);
   double hi = iHigh(sym, tf, 0);
   double lo = iLow(sym, tf, 0);
   if(hi <= 0.0)
      hi = 1.0;
   if(lo <= 0.0)
      lo = 1.0;

   if(ObjectFind(cid, name) < 0)
     {
      if(!ObjectCreate(cid, name, OBJ_RECTANGLE, 0, t1, hi, t2, lo))
         return(false);
     }

   ObjectSetInteger(cid, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(cid, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(cid, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(cid, name, OBJPROP_BACK, true);
   ObjectSetInteger(cid, name, OBJPROP_FILL, true);
   ObjectSetInteger(cid, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(cid, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(cid, name, OBJPROP_HIDDEN, true);
   return(true);
  }

//+------------------------------------------------------------------+
void EnsureSyncObjectsOnChart(const long cid)
  {
   int width = LineWidthSlave;
   if(cid == ChartID() && IsHost)
      width = LineWidthHost;

   EnsureVLineOnChart(cid, vline_name, LineColor, width, STYLE_SOLID);
   EnsureVLineOnChart(cid, vline_end_name, LineColor, 1, STYLE_DOT);
   if(DrawPriceLine)
      EnsureHLineOnChart(cid, hline_name, LineColor);
   if(DrawHostCandleBox)
      EnsureRectangleOnChart(cid, select_box_name, LineColor);
  }

//+------------------------------------------------------------------+
void SetRectangleOnChart(const long cid, const string name, const datetime t1, const datetime t2, const double price1, const double price2)
  {
   if(ObjectFind(cid, name) < 0)
      return;

   ObjectSetInteger(cid, name, OBJPROP_TIME, 0, t1);
   ObjectSetInteger(cid, name, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(cid, name, OBJPROP_PRICE, 0, price1);
   ObjectSetDouble(cid, name, OBJPROP_PRICE, 1, price2);
  }

//+------------------------------------------------------------------+
void RangeHighLowOn(const string sym, const ENUM_TIMEFRAMES tf, const datetime t1, const datetime t2, double &hi, double &lo)
  {
   hi = 0.0;
   lo = 0.0;

   datetime now_t = iTime(sym, tf, 0);
   datetime t_last = t2;
   if(now_t > 0 && t_last > now_t)
      t_last = now_t;
   if(t_last < t1)
      t_last = t1;

   int shift_open = ClampBarOn(sym, tf, iBarShift(sym, tf, t1, false));
   int shift_end  = ClampBarOn(sym, tf, iBarShift(sym, tf, t_last, false));
   if(shift_open < 0 && shift_end < 0)
      return;

   if(shift_open < 0)
      shift_open = shift_end;
   if(shift_end < 0)
      shift_end = shift_open;

   int from_bar = shift_end;
   int to_bar   = shift_open;
   if(from_bar > to_bar)
     {
      int tmp = from_bar;
      from_bar = to_bar;
      to_bar = tmp;
     }

   hi = iHigh(sym, tf, from_bar);
   lo = iLow(sym, tf, from_bar);

   for(int i = from_bar + 1; i <= to_bar; i++)
     {
      double h = iHigh(sym, tf, i);
      double l = iLow(sym, tf, i);
      if(h > hi)
         hi = h;
      if(l < lo)
         lo = l;
     }
  }

//+------------------------------------------------------------------+
bool ApplyWindowToChart(const long cid, const datetime t1, const datetime t2_in, const int host_period, const double fallback_price)
  {
   string sym = ChartSymbol(cid);
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)ChartPeriod(cid);
   if(StringLen(sym) == 0)
      return(false);

   EnsureSyncObjectsOnChart(cid);

   datetime t2 = t2_in;
   if(t2 <= t1)
      t2 = t1 + TfSeconds(host_period);

   ObjectSetInteger(cid, vline_name, OBJPROP_TIME, 0, t1);
   ObjectSetInteger(cid, vline_end_name, OBJPROP_TIME, 0, t2);
   if(DrawPriceLine)
      ObjectSetDouble(cid, hline_name, OBJPROP_PRICE, 0, fallback_price);

   if(DrawHostCandleBox)
     {
      double hi = 0.0;
      double lo = 0.0;
      RangeHighLowOn(sym, tf, t1, t2, hi, lo);
      if(hi <= 0.0 || lo <= 0.0)
        {
         hi = fallback_price;
         lo = fallback_price;
        }
      SetRectangleOnChart(cid, select_box_name, t1, t2, hi, lo);
     }

   datetime now_t = iTime(sym, tf, 0);
   datetime t_end_lookup = t2 - 1;
   if(now_t > 0 && t_end_lookup > now_t)
      t_end_lookup = now_t;
   if(t_end_lookup < t1)
      t_end_lookup = t1;

   int bar_open = ClampBarOn(sym, tf, iBarShift(sym, tf, t1, false));
   int bar_end  = ClampBarOn(sym, tf, iBarShift(sym, tf, t_end_lookup, false));
   if(bar_open < 0 && bar_end < 0)
     {
      ChartRedraw(cid);
      return(false);
     }
   if(bar_open < 0)
      bar_open = bar_end;
   if(bar_end < 0)
      bar_end = bar_open;

   bool lock_this = (cid == ChartID() && IsHost && HostLockToLatest);
   if(lock_this)
     {
      ChartSetInteger(cid, CHART_AUTOSCROLL, true);
      ChartSetInteger(cid, CHART_SHIFT, true);
      ChartRedraw(cid);
      return(true);
     }

   if(!RightAlignOnSync)
     {
      ChartSetInteger(cid, CHART_AUTOSCROLL, (bar_end == 0));
      ChartRedraw(cid);
      return(true);
     }

   long vis = ChartGetInteger(cid, CHART_WIDTH_IN_BARS);
   if(vis < 3)
      vis = 3;

   int older = bar_open;
   int newer = bar_end;
   if(older < newer)
     {
      int tmp = older;
      older = newer;
      newer = tmp;
     }

   int span = older - newer + 1;
   int target_right;
   if(span <= vis)
      target_right = newer;
   else
      target_right = older - (int)vis + 2;
   if(target_right < 0)
      target_right = 0;

   RightAlignBarOnChart(cid, target_right);
   ChartSetInteger(cid, CHART_AUTOSCROLL, (target_right == 0));
   ChartRedraw(cid);
   return(true);
  }

//+------------------------------------------------------------------+
void PushSyncToAllCharts()
  {
   if(last_sync_time <= 0)
      return;

   long cid = ChartFirst();
   while(cid >= 0)
     {
      if(ChartSymbol(cid) == _Symbol)
        {
         ApplyWindowToChart(cid, last_sync_time, last_sync_end, last_sync_period, last_sync_price);
         if(WakeAllCharts)
            KickChart(cid);
         else
            ChartRedraw(cid);
        }
      cid = ChartNext(cid);
     }
  }

//+------------------------------------------------------------------+
void PublishHostPick(const datetime bar_time, const double bar_price)
  {
   last_sync_time   = bar_time;
   last_sync_end    = bar_time + TfSeconds((int)_Period);
   last_sync_price  = bar_price;
   last_sync_period = (int)_Period;
   last_seq         = last_seq + 1.0;

   GlobalVariableSet(sync_time_var, (double)last_sync_time);
   GlobalVariableSet(sync_end_var, (double)last_sync_end);
   GlobalVariableSet(sync_price_var, last_sync_price);
   GlobalVariableSet(sync_period_var, (double)last_sync_period);
   GlobalVariableSet(sync_seq_var, last_seq);

   last_align_ok = ApplyWindowToChart(ChartID(), last_sync_time, last_sync_end, last_sync_period, last_sync_price);
   last_applied_time = last_sync_time;
   last_applied_end  = last_sync_end;

   PushSyncToAllCharts();
  }

//+------------------------------------------------------------------+
void UpdateHostCrosshair(const int x, const int y)
  {
   if(!IsHost || !ShowHostCrosshair)
      return;

   datetime t;
   double price;
   int subwindow = 0;

   if(!ChartXYToTimePrice(0, x, y, subwindow, t, price))
      return;
   if(subwindow != 0)
      return;

   int bar = ClampBarOn(_Symbol, PERIOD_CURRENT, iBarShift(_Symbol, PERIOD_CURRENT, t, false));
   datetime bar_t = t;
   if(bar >= 0)
     {
      datetime bt = iTime(_Symbol, PERIOD_CURRENT, bar);
      if(bt > 0)
         bar_t = bt;
     }

   if(ObjectFind(0, xh_v_name) >= 0)
      ObjectSetInteger(0, xh_v_name, OBJPROP_TIME, 0, bar_t);
   if(ObjectFind(0, xh_h_name) >= 0)
      ObjectSetDouble(0, xh_h_name, OBJPROP_PRICE, 0, price);

   if(DrawHostCandleBox && bar >= 0 && ObjectFind(0, hover_box_name) >= 0)
     {
      datetime t2 = bar_t + PeriodSeconds(PERIOD_CURRENT);
      double hi = iHigh(_Symbol, PERIOD_CURRENT, bar);
      double lo = iLow(_Symbol, PERIOD_CURRENT, bar);
      SetRectangleOnChart(0, hover_box_name, bar_t, t2, hi, lo);
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
bool ReadGlobals(datetime &t1, datetime &t2, double &price, int &host_period, double &seq)
  {
   double dt_val = 0.0;
   if(!GlobalVariableGet(sync_time_var, dt_val) || dt_val <= 0.0)
      return(false);

   t1 = (datetime)dt_val;

   double end_val = 0.0;
   if(!GlobalVariableGet(sync_end_var, end_val) || end_val <= dt_val)
     {
      double per_val = 0.0;
      if(!GlobalVariableGet(sync_period_var, per_val) || per_val <= 0.0)
         per_val = (double)_Period;
      end_val = dt_val + (double)TfSeconds((int)per_val);
     }
   t2 = (datetime)end_val;

   price = last_sync_price;
   GlobalVariableGet(sync_price_var, price);

   double per_out = 0.0;
   if(!GlobalVariableGet(sync_period_var, per_out) || per_out <= 0.0)
      per_out = (double)_Period;
   host_period = (int)per_out;

   seq = last_seq;
   GlobalVariableGet(sync_seq_var, seq);
   return(true);
  }

//+------------------------------------------------------------------+
void ApplySyncState(const bool force_align)
  {
   datetime t1, t2;
   double price;
   int host_period;
   double seq;

   if(!ReadGlobals(t1, t2, price, host_period, seq))
      return;

   datetime obj_time = 0;
   if(ObjectFind(0, vline_name) >= 0)
      obj_time = (datetime)ObjectGetInteger(0, vline_name, OBJPROP_TIME, 0);

   bool data_changed = (t1 != last_sync_time || t2 != last_sync_end ||
                        price != last_sync_price || host_period != last_sync_period ||
                        seq != last_seq);
   bool view_stale   = (t1 != last_applied_time || t2 != last_applied_end || obj_time != t1);
   bool need_retry   = !last_align_ok;

   if(!force_align && !data_changed && !view_stale && !need_retry)
      return;

   last_sync_time   = t1;
   last_sync_end    = t2;
   last_sync_price  = price;
   last_sync_period = host_period;
   last_seq         = seq;

   last_align_ok = ApplyWindowToChart(ChartID(), t1, t2, host_period, price);
   if(last_align_ok)
     {
      last_applied_time = t1;
      last_applied_end  = t2;
     }
  }

//+------------------------------------------------------------------+
void PublishLiveHostBarIfNeeded()
  {
   if(!IsHost || !AutoFollowHostBar)
      return;

   datetime live_bar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(live_bar <= 0)
      return;

   bool following_live = (last_sync_time == 0 || last_sync_time == last_live_bar || last_sync_time == live_bar);
   if(!following_live && !HostLockToLatest)
     {
      last_live_bar = live_bar;
      return;
     }

   if(HostLockToLatest && following_live && live_bar != last_sync_time)
      PublishHostPick(live_bar, iClose(_Symbol, PERIOD_CURRENT, 0));

   last_live_bar = live_bar;
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   sync_time_var   = "SV2MS_" + _Symbol + "_Time";
   sync_end_var    = "SV2MS_" + _Symbol + "_TimeEnd";
   sync_price_var  = "SV2MS_" + _Symbol + "_Price";
   sync_period_var = "SV2MS_" + _Symbol + "_Period";
   sync_seq_var    = "SV2MS_" + _Symbol + "_Seq";

   ApplyForcedCandles();
   ApplyStartupZoom();
   ApplyCandleColors();

   if(IsHost && HostLockToLatest)
      ApplyHostLockState();
   else
      ChartSetInteger(0, CHART_SHIFT, false);

   EnsureSyncObjectsOnChart(ChartID());

   if(IsHost && ShowHostCrosshair)
     {
      EnsureVLineOnChart(0, xh_v_name, CrosshairColor, 1, STYLE_DOT);
      EnsureHLineOnChart(0, xh_h_name, CrosshairColor);
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
      if(DrawHostCandleBox)
         EnsureRectangleOnChart(0, hover_box_name, HoverBoxColor);
     }

   if(ShowLabels)
     {
      if(ObjectFind(0, label_name) < 0)
         ObjectCreate(0, label_name, OBJ_LABEL, 0, 0, 0);

      ObjectSetInteger(0, label_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, label_name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, label_name, OBJPROP_YDISTANCE, 10);
      ObjectSetString(0, label_name, OBJPROP_TEXT,
                      (IsHost
                       ? (HostLockToLatest
                          ? "Host - Crosshair snap / click candle / locked to ticks"
                          : "Host - Crosshair snap / click candle to sync")
                       : "Slave - Follows host candle window"));
      ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(0, label_name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, label_name, OBJPROP_COLOR, LabelColor);
      ObjectSetInteger(0, label_name, OBJPROP_BACK, false);
      ObjectSetInteger(0, label_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, label_name, OBJPROP_HIDDEN, true);
     }

   if(ObjectFind(0, tf_label_name) < 0)
      ObjectCreate(0, tf_label_name, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, tf_label_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, tf_label_name, OBJPROP_TEXT, GetTimeframeString((int)_Period));
   ObjectSetInteger(0, tf_label_name, OBJPROP_FONTSIZE, 40);
   ObjectSetString(0, tf_label_name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, tf_label_name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, tf_label_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, tf_label_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, tf_label_name, OBJPROP_HIDDEN, true);
   UpdateTFLabelPosition();

   last_align_ok = false;

   if(IsHost)
     {
      datetime init_time = iTime(_Symbol, PERIOD_CURRENT, 0);
      double   init_price = iClose(_Symbol, PERIOD_CURRENT, 0);
      last_live_bar = init_time;
      PublishHostPick(init_time, init_price);
     }
   else
      ApplySyncState(true);

   EventSetMillisecondTimer(200);
   ChartRedraw(0);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();

   ObjectDelete(0, vline_name);
   ObjectDelete(0, vline_end_name);
   ObjectDelete(0, hline_name);
   ObjectDelete(0, label_name);
   ObjectDelete(0, tf_label_name);
   ObjectDelete(0, xh_v_name);
   ObjectDelete(0, xh_h_name);
   ObjectDelete(0, hover_box_name);
   ObjectDelete(0, select_box_name);

   if(IsHost)
     {
      GlobalVariableDel(sync_time_var);
      GlobalVariableDel(sync_end_var);
      GlobalVariableDel(sync_price_var);
      GlobalVariableDel(sync_period_var);
      GlobalVariableDel(sync_seq_var);
     }

   ChartRedraw(0);
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
   if(IsHost)
     {
      if(HostLockToLatest)
         ApplyHostLockState();
      PublishLiveHostBarIfNeeded();
     }
   else
      ApplySyncState(true);

   return(rates_total);
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
   if(IsHost)
     {
      if(HostLockToLatest)
         ApplyHostLockState();
      PublishLiveHostBarIfNeeded();
     }
   else
      ApplySyncState(true);
  }

//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CUSTOM + SV2MS_EVENT)
     {
      ApplySyncState(true);
      return;
     }

   if(id == CHARTEVENT_MOUSE_MOVE && IsHost && ShowHostCrosshair)
     {
      UpdateHostCrosshair((int)lparam, (int)dparam);
      return;
     }

   if(id == CHARTEVENT_CLICK && IsHost)
     {
      int x = (int)lparam;
      int y = (int)dparam;
      datetime click_time = 0;
      double click_price = 0.0;
      int subwindow = 0;

      if(!ChartXYToTimePrice(0, x, y, subwindow, click_time, click_price))
         return;
      if(subwindow != 0)
         return;

      int bar = ClampBarOn(_Symbol, PERIOD_CURRENT, iBarShift(_Symbol, PERIOD_CURRENT, click_time, false));
      if(bar < 0)
         return;

      last_live_bar = 0;
      PublishHostPick(iTime(_Symbol, PERIOD_CURRENT, bar), iClose(_Symbol, PERIOD_CURRENT, bar));
      return;
     }

   if(id == CHARTEVENT_CHART_CHANGE)
     {
      ApplyForcedCandles();
      ApplyCandleColors();
      UpdateTFLabelPosition();

      if(IsHost && HostLockToLatest)
         ApplyHostLockState();
      else
         ApplySyncState(true);

      ChartRedraw(0);
     }
  }
//+------------------------------------------------------------------+
