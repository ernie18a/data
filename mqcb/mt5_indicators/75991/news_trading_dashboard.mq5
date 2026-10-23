//+------------------------------------------------------------------+
//|                                       News Trading Dashboard MT5 |
//|                                                                  |
//|                    Professional Trading Utility for MetaTrader 5 |
//|                                Copyright (c) 2026 Marian Beceanu |
//|                            https://www.mql5.com/en/users/zorbacc |
//|                                  Email: marian.beceanu@gmail.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Marian Beceanu"
#property link      "https://forge.mql5.io"
#property version   "2.00"
#property strict
#property indicator_chart_window
#property indicator_plots   0
#property description "Bloomberg-style News Trading Dashboard - ATR volatility spike detector"

//====================================================================
// ENUMERATIONS (rendered as dropdown lists in the Inputs tab)
//====================================================================
enum ENUM_BG_THEME
  {
   THEME_BLOOMBERG_BLACK, // Bloomberg Black (Amber Accent)
   THEME_MIDNIGHT_NAVY,   // Midnight Navy (Gold Accent)
   THEME_CHARCOAL_GRAY,   // Charcoal Gray (Silver Accent)
   THEME_DEEP_PURPLE,     // Deep Purple (Violet Accent)
   THEME_PURE_BLACK,      // Pure Black (High Contrast White)
   THEME_STEEL_BLUE       // Steel Blue (Cyan Accent)
  };

enum ENUM_PANEL_CORNER
  {
   PANEL_TOP_LEFT,        // Top Left
   PANEL_TOP_RIGHT,       // Top Right
   PANEL_BOTTOM_LEFT,     // Bottom Left
   PANEL_BOTTOM_RIGHT     // Bottom Right
  };

//====================================================================
// INPUT PARAMETERS
//====================================================================
input group "===== NEWS / VOLATILITY DETECTION ====="
input int                 InpATRPeriod         = 14;      // ATR period
input double              InpSpikeMultiplier   = 2.0;      // Spike multiplier (range > ATR * multiplier)
input int                 InpTimerSeconds       = 1;        // Refresh interval (seconds)

input group "===== DASHBOARD APPEARANCE ====="
input bool                InpShowDashboard      = true;     // Show dashboard
input ENUM_BG_THEME       InpTheme              = THEME_BLOOMBERG_BLACK; // Background color theme
input int                 InpFontSize           = 10;        // Base text size (6-20)
input bool                InpAutoScalePanel     = true;      // Auto-scale panel to longest text
input int                 InpMinPanelWidth      = 260;       // Minimum panel width (px)

input group "===== DASHBOARD POSITION ====="
input ENUM_PANEL_CORNER   InpCorner             = PANEL_TOP_LEFT; // Panel corner / anchor
input int                 InpOffsetX            = 15;        // Horizontal offset from corner (px)
input int                 InpOffsetY            = 15;        // Vertical offset from corner (px)

input group "===== MULTI-INSTANCE ====="
input int                 InpInstanceID         = 0;         // Instance ID (use a different value per copy on the same chart)

//====================================================================
// GLOBALS
//====================================================================
string   g_prefix        = "NEWSDASH_";
int      g_atr_handle    = INVALID_HANDLE;
int      g_font_size     = 10;
double   g_spike_mult    = 2.0;
int      g_panel_width   = 260;
int      g_panel_height  = 200;
int      g_corner        = CORNER_LEFT_UPPER;
bool     g_flip_x        = false; // true when anchored on the right side (x offsets measured from the right edge)
bool     g_flip_y        = false; // true when anchored on the bottom (y offsets measured from the bottom edge)
bool     g_dashboard_ok  = false;
bool     g_data_ready    = false; // becomes true after the first successful OnCalculate update
int      g_last_status   = -1;    // -1=none, 0=normal, 1=warning, 2=spike -> used to skip redundant redraws
datetime g_last_update   = 0;

// Resolved theme colors
color  gc_bg, gc_border, gc_header_bg, gc_title, gc_sub, gc_label, gc_value,
       gc_green, gc_amber, gc_red, gc_divider, gc_footer;

//====================================================================
// THEME RESOLUTION
//====================================================================
void ResolveTheme(ENUM_BG_THEME theme)
  {
   switch(theme)
     {
      case THEME_MIDNIGHT_NAVY:
         gc_bg=C'8,14,28';       gc_border=C'58,84,120';  gc_header_bg=C'13,22,40';
         gc_title=C'255,201,71';  gc_sub=C'235,235,240';   gc_label=C'185,196,212';
         gc_value=C'255,255,255';gc_divider=C'70,90,120'; gc_footer=C'255,201,71';
         break;
      case THEME_CHARCOAL_GRAY:
         gc_bg=C'26,26,28';      gc_border=C'80,80,84';   gc_header_bg=C'34,34,37';
         gc_title=C'240,240,245';gc_sub=C'220,220,225';   gc_label=C'190,190,195';
         gc_value=C'255,255,255';gc_divider=C'95,95,100';  gc_footer=C'225,225,230';
         break;
      case THEME_DEEP_PURPLE:
         gc_bg=C'18,10,30';      gc_border=C'95,60,130';  gc_header_bg=C'26,15,42';
         gc_title=C'210,170,255';gc_sub=C'235,228,242';   gc_label=C'195,180,215';
         gc_value=C'255,255,255';gc_divider=C'110,80,150'; gc_footer=C'210,170,255';
         break;
      case THEME_PURE_BLACK:
         gc_bg=C'0,0,0';         gc_border=C'95,95,95';   gc_header_bg=C'12,12,12';
         gc_title=C'255,255,255';gc_sub=C'232,232,232';   gc_label=C'200,200,200';
         gc_value=C'255,255,255';gc_divider=C'110,110,110'; gc_footer=C'225,225,225';
         break;
      case THEME_STEEL_BLUE:
         gc_bg=C'10,20,30';      gc_border=C'55,100,130'; gc_header_bg=C'15,28,40';
         gc_title=C'130,205,255';gc_sub=C'232,238,244';   gc_label=C'190,208,222';
         gc_value=C'255,255,255';gc_divider=C'80,120,150'; gc_footer=C'130,205,255';
         break;
      default: // THEME_BLOOMBERG_BLACK
         gc_bg=C'0,0,0';         gc_border=C'90,90,90';   gc_header_bg=C'14,14,14';
         gc_title=C'255,178,54'; gc_sub=C'225,225,225';   gc_label=C'195,195,195';
         gc_value=C'255,255,255';gc_divider=C'85,85,85';  gc_footer=C'255,178,54';
         break;
     }
   gc_green=C'0,200,120';
   gc_amber=C'255,153,0';
   gc_red=C'255,60,60';
  }

//====================================================================
// TEXT MEASUREMENT HELPER (uses GDI TextGetSize, matched to label font)
//====================================================================
int MeasureTextWidth(const string text,int font_size)
  {
   uint w=0,h=0;
   ResetLastError();
   // Negative size (tenths of a point) keeps the measurement consistent
   // with OBJPROP_FONTSIZE used on OBJ_LABEL objects.
   if(!TextSetFont("Arial",-(font_size*10),0,0) || !TextGetSize(text,w,h))
     {
      // Safe heuristic fallback if the OS/GDI call is unavailable
      return (int)(StringLen(text)*font_size*0.62)+8;
     }
   return (int)w;
  }

//====================================================================
// OBJECT CREATION HELPERS
//====================================================================
void CreateRect(string name,int x,int y,int w,int h,color bg,color border)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,MathMax(w,1));
   ObjectSetInteger(0,name,OBJPROP_YSIZE,MathMax(h,1));
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,name,OBJPROP_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_CORNER,g_corner);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
  }

void CreateLabel(string name,string text,int x,int y,int font_size,color clr,bool bold=false)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,bold?"Arial Bold":"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,g_corner);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,1);
  }

// Converts an X coordinate measured from the panel's own left edge into the
// distance MT5 expects for the active corner (mirrors it for right corners).
int ResolveX(int local_x,int element_w=0)
  {
   if(!g_flip_x) return InpOffsetX+local_x;
   return InpOffsetX+(g_panel_width-local_x-element_w);
  }

int ResolveY(int local_y,int element_h=0)
  {
   if(!g_flip_y) return InpOffsetY+local_y;
   return InpOffsetY+(g_panel_height-local_y-element_h);
  }

//====================================================================
// REMOVE EVERY OBJECT BELONGING TO THIS INSTANCE ONLY
//====================================================================
void DeleteAllObjects()
  {
   int total=ObjectsTotal(0,-1,-1);
   for(int i=total-1;i>=0;i--)
     {
      if(IsStopped()) break; // never let cleanup hang the terminal on shutdown
      string name=ObjectName(0,i,-1,-1);
      if(StringFind(name,g_prefix)==0)
         ObjectDelete(0,name);
     }
   ChartRedraw(0);
  }

//====================================================================
// BUILD (CREATE) THE DASHBOARD
//====================================================================
void BuildPanel()
  {
   DeleteAllObjects();
   if(!InpShowDashboard) return;

   ResolveTheme(InpTheme);

   int pad      = 14;
   int gap      = 10;
   int rowH     = g_font_size+12;
   int titleFS  = g_font_size+4;
   int subFS    = g_font_size-1; if(subFS<7) subFS=7;
   int smallFS  = g_font_size-1; if(smallFS<7) smallFS=7;

   // ---- Compute the widest content, so the panel scales to the text ----
   int maxContentW=0;

   string title_txt = "NEWS TRADING DASHBOARD";
   string sub_txt   = "REAL-TIME VOLATILITY MONITOR";
   maxContentW = MathMax(maxContentW, MeasureTextWidth(title_txt,titleFS));
   maxContentW = MathMax(maxContentW, MeasureTextWidth(sub_txt,subFS));

   string keys[6] =
     {
      "SYMBOL","TIMEFRAME","ATR PERIOD","ATR VALUE","CURRENT RANGE","SPIKE THRESHOLD"
     };
   string vals[6] =
     {
      _Symbol,
      StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7),
      IntegerToString(InpATRPeriod),
      DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits+1),
      DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits+1),
      DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits+1)
     };

   int keyW=0;
   for(int i=0;i<6;i++) keyW=MathMax(keyW,MeasureTextWidth(keys[i]+" ",g_font_size));
   int valW=0;
   for(int i=0;i<6;i++) valW=MathMax(valW,MeasureTextWidth(vals[i],g_font_size)+70); // buffer for value growth
   maxContentW = MathMax(maxContentW,keyW+gap+valW);

   string status_variants[3] =
     {
      "● NORMAL MARKET CONDITIONS",
      "● APPROACHING VOLATILITY ZONE",
      "● HIGH VOLATILITY - NEWS SPIKE DETECTED"
     };
   for(int i=0;i<3;i++) maxContentW=MathMax(maxContentW,MeasureTextWidth(status_variants[i],g_font_size+1));

   string action_variants[3] =
     {
      "ACTION: MARKET MONITORING - NO ACTION REQUIRED",
      "ACTION: CAUTION - REDUCE EXPOSURE",
      "ACTION: AVOID NEW ENTRIES - HIGH NEWS RISK"
     };
   for(int i=0;i<3;i++) maxContentW=MathMax(maxContentW,MeasureTextWidth(action_variants[i],smallFS));

   maxContentW = MathMax(maxContentW, MeasureTextWidth("VOLATILITY GAUGE            999%",smallFS));

   string footer_txt = "Instance #"+IntegerToString(InpInstanceID)+"  |  News Trading Dashboard v2.0";
   maxContentW = MathMax(maxContentW, MeasureTextWidth(footer_txt,smallFS));

   g_panel_width  = MathMax(InpAutoScalePanel ? (maxContentW+2*pad) : InpMinPanelWidth, InpMinPanelWidth);

   // Clamp to the visible chart area so the panel can never overflow off-screen
   long chart_w=0;
   if(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,chart_w) && chart_w>0)
      g_panel_width = (int)MathMin(g_panel_width, MathMax(chart_w-2*InpOffsetX,InpMinPanelWidth));

   // ---- Vertical layout ----
   int y = 0;
   int headerH   = titleFS+subFS+22;
   int dividerH  = 1;
   int rowsH     = rowH*6;
   int statusH   = g_font_size+18;
   int actionH   = smallFS+14;
   int gaugeH    = smallFS+26;
   int footerH   = smallFS+16;

   g_panel_height = headerH + dividerH + rowsH + dividerH + statusH + actionH + dividerH + gaugeH + dividerH + footerH + pad;

   // ---- Background panel ----
   CreateRect(g_prefix+"BG",ResolveX(0,g_panel_width),ResolveY(0,g_panel_height),g_panel_width,g_panel_height,gc_bg,gc_border);

   // ---- Header ----
   CreateRect(g_prefix+"HDR",ResolveX(0,g_panel_width),ResolveY(0,headerH),g_panel_width,headerH,gc_header_bg,gc_header_bg);
   CreateLabel(g_prefix+"TITLE",title_txt,ResolveX(pad),ResolveY(8),titleFS,gc_title,true);
   CreateLabel(g_prefix+"SUB",sub_txt,ResolveX(pad),ResolveY(8+titleFS+6),subFS,gc_sub,false);
   y = headerH;

   CreateRect(g_prefix+"DIV1",ResolveX(0,g_panel_width),ResolveY(y,dividerH),g_panel_width,dividerH,gc_divider,gc_divider);
   y += dividerH+4;

   // ---- Info rows (key / value pairs) ----
   string row_names[6] = {"ROW_SYMBOL","ROW_TF","ROW_ATRPERIOD","ROW_ATRVAL","ROW_RANGE","ROW_THRESH"};
   for(int i=0;i<6;i++)
     {
      CreateLabel(g_prefix+row_names[i]+"_K",keys[i]+":",ResolveX(pad),ResolveY(y+3),g_font_size,gc_label,false);
      CreateLabel(g_prefix+row_names[i]+"_V",vals[i],ResolveX(pad+keyW+gap),ResolveY(y+3),g_font_size,gc_value,true);
      y += rowH;
     }

   CreateRect(g_prefix+"DIV2",ResolveX(0,g_panel_width),ResolveY(y,dividerH),g_panel_width,dividerH,gc_divider,gc_divider);
   y += dividerH+6;

   // ---- Status line ----
   CreateLabel(g_prefix+"STATUS",status_variants[0],ResolveX(pad),ResolveY(y),g_font_size+1,gc_green,true);
   y += statusH;

   // ---- Action line ----
   CreateLabel(g_prefix+"ACTION",action_variants[0],ResolveX(pad),ResolveY(y),smallFS,gc_label,false);
   y += actionH;

   CreateRect(g_prefix+"DIV3",ResolveX(0,g_panel_width),ResolveY(y,dividerH),g_panel_width,dividerH,gc_divider,gc_divider);
   y += dividerH+6;

   // ---- Volatility gauge ----
   CreateLabel(g_prefix+"GAUGE_LBL","VOLATILITY GAUGE",ResolveX(pad),ResolveY(y),smallFS,gc_label,false);
   CreateLabel(g_prefix+"GAUGE_PCT","0%",ResolveX(g_panel_width-pad-50),ResolveY(y),smallFS,gc_value,true);
   int barY = y+smallFS+6;
   int barW = g_panel_width-2*pad;
   int barH = 10;
   CreateRect(g_prefix+"GAUGE_BG",ResolveX(pad,barW),ResolveY(barY,barH),barW,barH,gc_header_bg,gc_border);
   CreateRect(g_prefix+"GAUGE_FILL",ResolveX(pad+1,1),ResolveY(barY+1,barH-2),1,barH-2,gc_green,gc_green);
   y = barY+barH+8;

   CreateRect(g_prefix+"DIV4",ResolveX(0,g_panel_width),ResolveY(y,dividerH),g_panel_width,dividerH,gc_divider,gc_divider);
   y += dividerH+6;

   // ---- Footer ----
   CreateLabel(g_prefix+"FOOTER",footer_txt,ResolveX(pad),ResolveY(y),smallFS,gc_footer,false);

   // Store the gauge geometry for fast updates without recomputation
   g_dashboard_ok = true;
   ChartRedraw(0);
  }

// Safe object update helpers: verify the object still exists before touching
// it, so a manual deletion or a theme rebuild never spams the Experts log.
void SafeSetText(const string name,const string text)
  {
   if(ObjectFind(0,name)>=0) ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
void SafeSetColor(const string name,color clr)
  {
   if(ObjectFind(0,name)>=0) ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
  }

//====================================================================
// REFRESH DYNAMIC VALUES
// IMPORTANT (anti-freeze design): this function receives the current range
// and ATR value as ready-made parameters. It performs ZERO history/series
// requests (no CopyRates, no CopyBuffer) of its own, so it can never block
// the terminal while historical data is being synchronized - the classic
// cause of an indicator "freezing" a chart on W1/MN1 or on symbols whose
// history has not been downloaded yet.
//====================================================================
void RefreshDashboardValues(double current_range,double atr_value)
  {
   if(!InpShowDashboard || !g_dashboard_ok) return;
   if(atr_value<=0.0) return;

   double ratio = current_range/(atr_value*g_spike_mult);

   int status_idx; string status_text; color status_clr; string action_text;

   if(ratio>=1.0)
     {
      status_idx=2;
      status_text="● HIGH VOLATILITY - NEWS SPIKE DETECTED";
      status_clr=gc_red;
      action_text="ACTION: AVOID NEW ENTRIES - HIGH NEWS RISK";
     }
   else if(ratio>=0.75)
     {
      status_idx=1;
      status_text="● APPROACHING VOLATILITY ZONE";
      status_clr=gc_amber;
      action_text="ACTION: CAUTION - REDUCE EXPOSURE";
     }
   else
     {
      status_idx=0;
      status_text="● NORMAL MARKET CONDITIONS";
      status_clr=gc_green;
      action_text="ACTION: MARKET MONITORING - NO ACTION REQUIRED";
     }

   int pct=(int)MathRound(ratio*100.0);
   if(pct<0) pct=0;
   int pad=14;
   int barW=g_panel_width-2*pad;
   double fillRatio=MathMin(ratio/1.5,1.0); // visual bar capped at 150% of threshold
   int fillW=(int)MathRound(barW*fillRatio);
   if(fillW<1) fillW=1;

   // Dirty-check: only touch chart objects (and redraw) when something
   // actually changed. This keeps CPU/GPU load minimal, which matters when
   // several instances run on the same PC during live trading.
   bool changed = (status_idx!=g_last_status);

   if(changed)
     {
      SafeSetText(g_prefix+"STATUS",status_text);
      SafeSetColor(g_prefix+"STATUS",status_clr);
      SafeSetText(g_prefix+"ACTION",action_text);
      SafeSetColor(g_prefix+"GAUGE_PCT",status_clr);
      if(ObjectFind(0,g_prefix+"GAUGE_FILL")>=0)
        {
         ObjectSetInteger(0,g_prefix+"GAUGE_FILL",OBJPROP_BGCOLOR,status_clr);
         ObjectSetInteger(0,g_prefix+"GAUGE_FILL",OBJPROP_COLOR,status_clr);
        }
      g_last_status=status_idx;
     }

   SafeSetText(g_prefix+"ROW_ATRVAL_V",DoubleToString(atr_value,_Digits+1));
   SafeSetText(g_prefix+"ROW_RANGE_V",DoubleToString(current_range,_Digits+1));
   SafeSetText(g_prefix+"ROW_THRESH_V",DoubleToString(atr_value*g_spike_mult,_Digits+1));
   SafeSetText(g_prefix+"GAUGE_PCT",IntegerToString(pct)+"%");
   if(ObjectFind(0,g_prefix+"GAUGE_FILL")>=0)
      ObjectSetInteger(0,g_prefix+"GAUGE_FILL",OBJPROP_XSIZE,fillW);

   g_data_ready=true;
   g_last_update=TimeCurrent();
   ChartRedraw(0);
  }

// Cheap cosmetic refresh: updates only the "last updated" clock in the
// footer. Contains no data/history calls, so it is always instant and safe
// to run every second even while historical data is still synchronizing.
void RefreshFooterClock()
  {
   if(!InpShowDashboard || !g_dashboard_ok) return;
   string txt = g_data_ready
                ? "Instance #"+IntegerToString(InpInstanceID)+"  |  Updated "+TimeToString(g_last_update,TIME_SECONDS)
                : "Instance #"+IntegerToString(InpInstanceID)+"  |  Waiting for market data...";
   SafeSetText(g_prefix+"FOOTER",txt);
   ChartRedraw(0);
  }

//====================================================================
// EXPERT LIFECYCLE
//====================================================================
int OnInit()
  {
   // ---- Sanitize inputs (defensive programming) ----
   g_font_size = (int)MathMax(6,MathMin(20,InpFontSize));
   g_spike_mult = MathMax(0.1,InpSpikeMultiplier);

   int atr_period = (int)MathMax(1,InpATRPeriod);
   int timer_sec  = (int)MathMax(1,InpTimerSeconds);

   g_data_ready  = false;
   g_last_status = -1;

   // ---- Resolve corner + mirroring for X/Y math ----
   switch(InpCorner)
     {
      case PANEL_TOP_RIGHT:    g_corner=CORNER_RIGHT_UPPER; g_flip_x=true;  g_flip_y=false; break;
      case PANEL_BOTTOM_LEFT:  g_corner=CORNER_LEFT_LOWER;  g_flip_x=false; g_flip_y=true;  break;
      case PANEL_BOTTOM_RIGHT: g_corner=CORNER_RIGHT_LOWER; g_flip_x=true;  g_flip_y=true;  break;
      default:                g_corner=CORNER_LEFT_UPPER;  g_flip_x=false; g_flip_y=false; break;
     }

   // ---- Build a unique object prefix so several copies can coexist ----
   g_prefix = "NEWSDASH_"+IntegerToString(InpInstanceID)+"_";
   if(ObjectFind(0,g_prefix+"BG")>=0)
     {
      // Another running instance already owns this ID: auto-generate a
      // guaranteed-unique suffix so both dashboards keep working correctly.
      MathSrand((int)GetTickCount());
      g_prefix = g_prefix+IntegerToString((int)GetTickCount())+"_"+IntegerToString(MathRand())+"_";
     }

   if(!InpShowDashboard)
     {
      IndicatorSetString(INDICATOR_SHORTNAME,"News Trading Dashboard (hidden)");
      return INIT_SUCCEEDED;
     }

   g_atr_handle = iATR(_Symbol,_Period,atr_period);
   if(g_atr_handle==INVALID_HANDLE)
     {
      Print("News Trading Dashboard: failed to create ATR handle, error ",GetLastError());
      return INIT_FAILED;
     }

   IndicatorSetString(INDICATOR_SHORTNAME,"News Trading Dashboard #"+IntegerToString(InpInstanceID));

   // NOTE (anti-freeze): we intentionally do NOT request any history or
   // indicator buffer data here. BuildPanel() only creates chart objects
   // and reads the current Bid via SymbolInfoDouble (instant, no history
   // sync). The first real values are filled in by OnCalculate() as soon
   // as the terminal reports data is actually available - this is what
   // prevents OnInit from ever blocking on W1/MN1 or freshly-loaded symbols.
   BuildPanel();
   SafeSetText(g_prefix+"STATUS","● INITIALIZING...");
   SafeSetColor(g_prefix+"STATUS",gc_label);
   SafeSetText(g_prefix+"ACTION","ACTION: WAITING FOR MARKET DATA");
   ChartRedraw(0);

   EventSetTimer(timer_sec);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_atr_handle!=INVALID_HANDLE)
     {
      IndicatorRelease(g_atr_handle);
      g_atr_handle=INVALID_HANDLE;
     }
   // Always clean up, for every removal reason (deleted, recompiled,
   // chart closed, template changed, etc.) so nothing is ever left behind.
   DeleteAllObjects();
  }

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
   // All series arrays passed in here are already synchronized by the
   // terminal - reading them can never block or freeze the UI. This is why
   // the live volatility calculation lives here instead of behind a manual
   // CopyRates() call.
   if(!InpShowDashboard || !g_dashboard_ok || g_atr_handle==INVALID_HANDLE)
      return rates_total;
   if(rates_total<2)
      return rates_total; // not enough bars yet (e.g. brand-new symbol/timeframe)

   // Only bother once the ATR indicator itself has produced a value for the
   // current bar; otherwise skip this pass silently and try again next tick.
   if(BarsCalculated(g_atr_handle)<=0)
      return rates_total;

   double atr_buf[];
   ArraySetAsSeries(atr_buf,true);
   if(CopyBuffer(g_atr_handle,0,0,1,atr_buf)<1)
      return rates_total; // buffer not ready yet - cheap check, no blocking

   int last = rates_total-1;
   double current_range = high[last]-low[last];

   RefreshDashboardValues(current_range,atr_buf[0]);
   return rates_total;
  }

void OnTimer()
  {
   // Timer is deliberately lightweight: it only refreshes the "last
   // updated" clock in the footer. The actual volatility/ATR calculation
   // runs in OnCalculate(), driven by real ticks/bars, never by the timer.
   RefreshFooterClock();
  }
//+------------------------------------------------------------------+
