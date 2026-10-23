//+------------------------------------------------------------------+
//|                         CompletedBarRegimeDashboardMT5.mq5       |
//| A completed-candle trend and market-regime dashboard for MT5.    |
//+------------------------------------------------------------------+
#property version   "1.00"
#property description "Completed-bar trend and regime dashboard for MetaTrader 5."
#property description "Shows EMA structure, higher-timeframe alignment, ADX/DI strength,"
#property description "ATR volatility, breakout readiness and spread context."
#property indicator_chart_window
#property indicator_plots   0
#property indicator_buffers 0

input group "Analysis timeframes"
input ENUM_TIMEFRAMES InpSignalTimeframe = PERIOD_H4; // Signal timeframe
input ENUM_TIMEFRAMES InpHigherTimeframe = PERIOD_D1; // Higher timeframe confirmation

input group "Trend model"
input int    InpFastEMAPeriod   = 21;    // Fast EMA period
input int    InpSlowEMAPeriod   = 55;    // Slow EMA period
input int    InpFilterEMAPeriod = 100;   // Long-term filter EMA period
input int    InpADXPeriod       = 14;    // ADX period
input double InpMinimumADX      = 22.0;  // Minimum ADX for a trend

input group "Breakout and volatility"
input int    InpATRPeriod            = 14;   // ATR period
input int    InpBreakoutLookback     = 20;   // Completed bars in breakout range
input double InpMinimumBodyATR       = 0.30; // Minimum candle body as ATR fraction

input group "Dashboard"
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Dashboard corner
input int              InpPanelX      = 12;                // Horizontal offset
input int              InpPanelY      = 24;                // Vertical offset
input int              InpFontSize    = 9;                 // Base font size

const int PANEL_WIDTH  = 600;
const int PANEL_HEIGHT = 338;

const color COLOR_PANEL       = C'10,24,43';
const color COLOR_PANEL_ALT   = C'15,34,57';
const color COLOR_BORDER      = C'62,90,120';
const color COLOR_TEXT        = C'224,233,242';
const color COLOR_MUTED       = C'149,170,191';
const color COLOR_ACCENT      = C'47,180,255';
const color COLOR_BULL        = C'42,196,117';
const color COLOR_BEAR        = C'239,83,80';
const color COLOR_NEUTRAL     = C'255,185,75';

string   g_prefix;
int      g_fast_handle       = INVALID_HANDLE;
int      g_slow_handle       = INVALID_HANDLE;
int      g_filter_handle     = INVALID_HANDLE;
int      g_adx_handle        = INVALID_HANDLE;
int      g_atr_handle        = INVALID_HANDLE;
int      g_higher_fast_handle= INVALID_HANDLE;
int      g_higher_slow_handle= INVALID_HANDLE;
datetime g_last_signal_bar   = 0;

//+------------------------------------------------------------------+
//| Return a compact timeframe label.                                |
//+------------------------------------------------------------------+
string TimeframeText(const ENUM_TIMEFRAMES timeframe)
  {
   string text=EnumToString(timeframe);
   StringReplace(text,"PERIOD_","");
   return text;
  }

//+------------------------------------------------------------------+
//| Format a price using the current symbol's digits.                 |
//+------------------------------------------------------------------+
string PriceText(const double value)
  {
   return DoubleToString(value,(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
  }

//+------------------------------------------------------------------+
//| Read one indicator-buffer value.                                 |
//+------------------------------------------------------------------+
bool ReadBufferValue(const int handle,
                     const int buffer,
                     const int shift,
                     double &value)
  {
   double data[1];
   if(handle==INVALID_HANDLE || CopyBuffer(handle,buffer,shift,1,data)!=1)
      return false;

   value=data[0];
   return MathIsValidNumber(value);
  }

//+------------------------------------------------------------------+
//| Create or update a dashboard rectangle.                           |
//+------------------------------------------------------------------+
void SetRectangle(const string suffix,
                  const int x,
                  const int y,
                  const int width,
                  const int height,
                  const color background,
                  const color border)
  {
   string name=g_prefix+suffix;
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpPanelX+x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpPanelY+y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
  }

//+------------------------------------------------------------------+
//| Create or update one text label.                                 |
//+------------------------------------------------------------------+
void SetLabel(const string suffix,
              const string text,
              const int x,
              const int y,
              const int size,
              const color text_color,
              const string font="Segoe UI")
  {
   string name=g_prefix+suffix;
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpPanelX+x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpPanelY+y);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_color);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,1);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//| Draw the fixed dashboard frame.                                  |
//+------------------------------------------------------------------+
void DrawFrame()
  {
   SetRectangle("panel",0,0,PANEL_WIDTH,PANEL_HEIGHT,COLOR_PANEL,COLOR_BORDER);
   SetRectangle("header",1,1,PANEL_WIDTH-2,58,COLOR_PANEL_ALT,COLOR_PANEL_ALT);
   SetRectangle("status",14,70,PANEL_WIDTH-28,38,COLOR_NEUTRAL,COLOR_NEUTRAL);
   SetRectangle("divider",14,119,PANEL_WIDTH-28,1,COLOR_BORDER,COLOR_BORDER);
   SetRectangle("column",299,132,1,156,COLOR_BORDER,COLOR_BORDER);
   SetRectangle("footer_line",14,301,PANEL_WIDTH-28,1,COLOR_BORDER,COLOR_BORDER);

   SetLabel("title","COMPLETED-BAR TREND REGIME",18,10,InpFontSize+4,COLOR_TEXT,"Segoe UI Semibold");
   SetLabel("context",_Symbol+"  |  signal "+TimeframeText(InpSignalTimeframe)+
                    "  |  higher "+TimeframeText(InpHigherTimeframe),18,37,InpFontSize,COLOR_MUTED);
   SetLabel("trend_heading","TREND EVIDENCE",18,132,InpFontSize,COLOR_ACCENT,"Segoe UI Semibold");
   SetLabel("market_heading","MARKET CONTEXT",318,132,InpFontSize,COLOR_ACCENT,"Segoe UI Semibold");
   SetLabel("footer","Analysis only  |  completed bars  |  no orders",18,312,InpFontSize,COLOR_MUTED);
  }

//+------------------------------------------------------------------+
//| Show a clear data-loading state.                                 |
//+------------------------------------------------------------------+
void ShowWaitingState()
  {
   SetRectangle("status",14,70,PANEL_WIDTH-28,38,COLOR_NEUTRAL,COLOR_NEUTRAL);
   SetLabel("status_text","WAITING FOR HISTORY",28,78,InpFontSize+3,C'24,31,38',"Segoe UI Semibold");
   SetLabel("trend_1","EMA structure: waiting",18,158,InpFontSize,COLOR_MUTED);
   SetLabel("trend_2","EMA slope: waiting",18,184,InpFontSize,COLOR_MUTED);
   SetLabel("trend_3","ADX / DI: waiting",18,210,InpFontSize,COLOR_MUTED);
   SetLabel("trend_4","Higher timeframe: waiting",18,236,InpFontSize,COLOR_MUTED);
   SetLabel("decision","Decision: waiting for completed-bar data",18,270,InpFontSize,COLOR_NEUTRAL,"Segoe UI Semibold");
   SetLabel("market_1","Last close: waiting",318,158,InpFontSize,COLOR_MUTED);
   SetLabel("market_2","ATR: waiting",318,184,InpFontSize,COLOR_MUTED);
   SetLabel("market_3","Spread context: waiting",318,210,InpFontSize,COLOR_MUTED);
   SetLabel("market_4","Breakout: waiting",318,236,InpFontSize,COLOR_MUTED);
  }

//+------------------------------------------------------------------+
//| Calculate and redraw the dashboard.                              |
//+------------------------------------------------------------------+
void RefreshDashboard(const bool force_redraw=false)
  {
   datetime signal_bar=iTime(_Symbol,InpSignalTimeframe,1);
   if(!force_redraw && signal_bar!=0 && signal_bar==g_last_signal_bar)
     {
      // Spread changes between bars, so keep this single field current.
      MqlTick tick;
      if(SymbolInfoTick(_Symbol,tick))
        {
         double spread_points=(tick.ask-tick.bid)/_Point;
         SetLabel("spread_live","Live spread: "+DoubleToString(spread_points,1)+" points",
                  400,312,InpFontSize,COLOR_MUTED);
         ChartRedraw(0);
        }
      return;
     }

   DrawFrame();

   double fast_1,fast_2,slow_1,filter_1;
   double adx_1,plus_di_1,minus_di_1,atr_1;
   double higher_fast_1,higher_slow_1;
   bool ready=
      ReadBufferValue(g_fast_handle,0,1,fast_1) &&
      ReadBufferValue(g_fast_handle,0,2,fast_2) &&
      ReadBufferValue(g_slow_handle,0,1,slow_1) &&
      ReadBufferValue(g_filter_handle,0,1,filter_1) &&
      ReadBufferValue(g_adx_handle,0,1,adx_1) &&
      ReadBufferValue(g_adx_handle,1,1,plus_di_1) &&
      ReadBufferValue(g_adx_handle,2,1,minus_di_1) &&
      ReadBufferValue(g_atr_handle,0,1,atr_1) &&
      ReadBufferValue(g_higher_fast_handle,0,1,higher_fast_1) &&
      ReadBufferValue(g_higher_slow_handle,0,1,higher_slow_1);

   MqlRates signal_rates[];
   MqlRates higher_rates[];
   ArraySetAsSeries(signal_rates,true);
   ArraySetAsSeries(higher_rates,true);
   if(CopyRates(_Symbol,InpSignalTimeframe,1,1,signal_rates)!=1 ||
      CopyRates(_Symbol,InpHigherTimeframe,1,1,higher_rates)!=1)
      ready=false;

   double prior_highs[];
   double prior_lows[];
   if(InpBreakoutLookback>0)
     {
      if(CopyHigh(_Symbol,InpSignalTimeframe,2,InpBreakoutLookback,prior_highs)!=InpBreakoutLookback ||
         CopyLow(_Symbol,InpSignalTimeframe,2,InpBreakoutLookback,prior_lows)!=InpBreakoutLookback)
         ready=false;
     }
   else
      ready=false;

   if(!ready || atr_1<=0.0 || ArraySize(signal_rates)<1 || ArraySize(higher_rates)<1)
     {
      ShowWaitingState();
      ChartRedraw(0);
      return;
     }

   double prior_high=prior_highs[0];
   double prior_low =prior_lows[0];
   for(int index=1; index<ArraySize(prior_highs); index++)
      prior_high=MathMax(prior_high,prior_highs[index]);
   for(int index=1; index<ArraySize(prior_lows); index++)
      prior_low=MathMin(prior_low,prior_lows[index]);

   double close_1=signal_rates[0].close;
   double body_1 =MathAbs(signal_rates[0].close-signal_rates[0].open);
   double body_atr=body_1/atr_1;
   bool impulse=(body_atr>=InpMinimumBodyATR);
   bool breakout_up=(close_1>prior_high);
   bool breakout_down=(close_1<prior_low);

   bool ema_bull=(fast_1>slow_1 && close_1>filter_1);
   bool ema_bear=(fast_1<slow_1 && close_1<filter_1);
   bool slope_up=(fast_1>fast_2);
   bool slope_down=(fast_1<fast_2);
   bool higher_bull=(higher_fast_1>higher_slow_1 && higher_rates[0].close>higher_fast_1);
   bool higher_bear=(higher_fast_1<higher_slow_1 && higher_rates[0].close<higher_fast_1);
   bool adx_bull=(adx_1>=InpMinimumADX && plus_di_1>minus_di_1);
   bool adx_bear=(adx_1>=InpMinimumADX && minus_di_1>plus_di_1);

   bool bullish=(ema_bull && slope_up && higher_bull && adx_bull);
   bool bearish=(ema_bear && slope_down && higher_bear && adx_bear);

   string status_text="RANGE / TRANSITION";
   color status_color=COLOR_NEUTRAL;
   if(bullish)
     {
      status_text="BULLISH TREND";
      status_color=COLOR_BULL;
     }
   else if(bearish)
     {
      status_text="BEARISH TREND";
      status_color=COLOR_BEAR;
     }

   SetRectangle("status",14,70,PANEL_WIDTH-28,38,status_color,status_color);
   SetLabel("status_text",status_text,28,78,InpFontSize+3,C'245,248,251',"Segoe UI Semibold");

   string ema_text=ema_bull ? "Bullish | close above filter" :
                   ema_bear ? "Bearish | close below filter" :
                              "Mixed | no clean alignment";
   string slope_text=slope_up ? "Rising" : slope_down ? "Falling" : "Flat";
   string higher_text=higher_bull ? "Bullish" : higher_bear ? "Bearish" : "Mixed";
   color ema_color=(ema_bull ? COLOR_BULL : ema_bear ? COLOR_BEAR : COLOR_NEUTRAL);
   color slope_color=(slope_up ? COLOR_BULL : slope_down ? COLOR_BEAR : COLOR_NEUTRAL);
   color higher_color=(higher_bull ? COLOR_BULL : higher_bear ? COLOR_BEAR : COLOR_NEUTRAL);

   SetLabel("trend_1","EMA stack: "+ema_text,18,158,InpFontSize,ema_color);
   SetLabel("trend_2","Fast EMA slope: "+slope_text,18,184,InpFontSize,slope_color);
   SetLabel("trend_3","ADX "+DoubleToString(adx_1,1)+"  |  +DI "+DoubleToString(plus_di_1,1)+
                      "  |  -DI "+DoubleToString(minus_di_1,1),18,210,InpFontSize,
                      adx_1>=InpMinimumADX ? COLOR_TEXT : COLOR_NEUTRAL);
   SetLabel("trend_4",TimeframeText(InpHigherTimeframe)+" alignment: "+higher_text,
            18,236,InpFontSize,higher_color);

   MqlTick tick;
   double spread_points=0.0;
   double spread_atr_percent=0.0;
   if(SymbolInfoTick(_Symbol,tick))
     {
      spread_points=(tick.ask-tick.bid)/_Point;
      spread_atr_percent=(tick.ask-tick.bid)/atr_1*100.0;
     }

   string breakout_text="Inside "+IntegerToString(InpBreakoutLookback)+"-bar range";
   color breakout_color=COLOR_MUTED;
   if(breakout_up)
     {
      breakout_text="Closed above prior range";
      breakout_color=COLOR_BULL;
     }
   else if(breakout_down)
     {
      breakout_text="Closed below prior range";
      breakout_color=COLOR_BEAR;
     }

   SetLabel("market_1","Last completed close: "+PriceText(close_1),318,158,InpFontSize,COLOR_TEXT);
   SetLabel("market_2","ATR("+IntegerToString(InpATRPeriod)+"): "+PriceText(atr_1)+
                       "  |  body "+DoubleToString(body_atr,2)+" ATR",318,184,InpFontSize,
                       impulse ? COLOR_TEXT : COLOR_MUTED);
   SetLabel("market_3","Spread: "+DoubleToString(spread_points,1)+" points  |  "+
                       DoubleToString(spread_atr_percent,2)+"% of ATR",318,210,InpFontSize,COLOR_TEXT);
   SetLabel("market_4","Breakout: "+breakout_text,318,236,InpFontSize,breakout_color);

   string decision="NO TREND SETUP - STAND ASIDE";
   color decision_color=COLOR_NEUTRAL;
   if(bullish && breakout_up && impulse)
     {
      decision="BULLISH TREND + COMPLETED-BAR BREAKOUT";
      decision_color=COLOR_BULL;
     }
   else if(bearish && breakout_down && impulse)
     {
      decision="BEARISH TREND + COMPLETED-BAR BREAKOUT";
      decision_color=COLOR_BEAR;
     }
   else if(bullish)
     {
      decision="BULLISH TREND - WAITING FOR BREAKOUT";
      decision_color=COLOR_BULL;
     }
   else if(bearish)
     {
      decision="BEARISH TREND - WAITING FOR BREAKOUT";
      decision_color=COLOR_BEAR;
     }

   SetLabel("decision","Decision: "+decision,18,270,InpFontSize,decision_color,"Segoe UI Semibold");
   SetLabel("spread_live","Live spread: "+DoubleToString(spread_points,1)+" points",
            400,312,InpFontSize,COLOR_MUTED);

   g_last_signal_bar=signal_bar;
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Initialize the indicator.                                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpFastEMAPeriod<1 || InpSlowEMAPeriod<2 || InpFilterEMAPeriod<2 ||
      InpADXPeriod<2 || InpATRPeriod<2 || InpBreakoutLookback<2 ||
      InpMinimumADX<0.0 || InpMinimumBodyATR<0.0 || InpFontSize<7)
      return INIT_PARAMETERS_INCORRECT;

   g_prefix=StringFormat("CBRD_%I64d_",ChartID());
   IndicatorSetString(INDICATOR_SHORTNAME,"Completed Bar Trend Regime Dashboard");

   g_fast_handle=iMA(_Symbol,InpSignalTimeframe,InpFastEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   g_slow_handle=iMA(_Symbol,InpSignalTimeframe,InpSlowEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   g_filter_handle=iMA(_Symbol,InpSignalTimeframe,InpFilterEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   g_adx_handle=iADX(_Symbol,InpSignalTimeframe,InpADXPeriod);
   g_atr_handle=iATR(_Symbol,InpSignalTimeframe,InpATRPeriod);
   g_higher_fast_handle=iMA(_Symbol,InpHigherTimeframe,InpFastEMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   g_higher_slow_handle=iMA(_Symbol,InpHigherTimeframe,InpSlowEMAPeriod,0,MODE_EMA,PRICE_CLOSE);

   if(g_fast_handle==INVALID_HANDLE || g_slow_handle==INVALID_HANDLE ||
      g_filter_handle==INVALID_HANDLE || g_adx_handle==INVALID_HANDLE ||
      g_atr_handle==INVALID_HANDLE || g_higher_fast_handle==INVALID_HANDLE ||
      g_higher_slow_handle==INVALID_HANDLE)
      return INIT_FAILED;

   DrawFrame();
   ShowWaitingState();
   EventSetTimer(1);
   RefreshDashboard(true);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Release resources.                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0,g_prefix);

   if(g_fast_handle!=INVALID_HANDLE)        IndicatorRelease(g_fast_handle);
   if(g_slow_handle!=INVALID_HANDLE)        IndicatorRelease(g_slow_handle);
   if(g_filter_handle!=INVALID_HANDLE)      IndicatorRelease(g_filter_handle);
   if(g_adx_handle!=INVALID_HANDLE)         IndicatorRelease(g_adx_handle);
   if(g_atr_handle!=INVALID_HANDLE)         IndicatorRelease(g_atr_handle);
   if(g_higher_fast_handle!=INVALID_HANDLE) IndicatorRelease(g_higher_fast_handle);
   if(g_higher_slow_handle!=INVALID_HANDLE) IndicatorRelease(g_higher_slow_handle);

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Refresh on timer so the spread field remains current.             |
//+------------------------------------------------------------------+
void OnTimer()
  {
   RefreshDashboard(false);
  }

//+------------------------------------------------------------------+
//| Reposition/redraw when the chart layout changes.                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
      RefreshDashboard(true);
  }

//+------------------------------------------------------------------+
//| Indicator calculation entry point.                               |
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
   RefreshDashboard(false);
   return rates_total;
  }
//+------------------------------------------------------------------+
