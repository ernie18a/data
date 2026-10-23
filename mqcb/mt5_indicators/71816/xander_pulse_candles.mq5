//+------------------------------------------------------------------+
//| XANDER Pulse Candles                                             |
//| Version: 1.2          | Date: 2026-04-11                         |
//| Platform: MT5                                                    |
//| Company: XANDER Systems                                          |
//+------------------------------------------------------------------+
// CHANGELOG:
// v1.0 - 2026-04-11 - Initial release
// v1.1 - 2026-04-11 - Electric Depth color palette, 5-state coloring
// v1.2 - 2026-04-11 - Removed contact links from input panel (MQL5 policy)
//+------------------------------------------------------------------+
// Join our trading community:
// Telegram : https://t.me/botmetatrader5
//
// Freelance & development requests — MQL5 profile only:
// MQL5     : https://www.mql5.com/en/users/09151993a
//+------------------------------------------------------------------+
#property copyright "© XANDER Systems"
#property link      "https://www.mql5.com/en/users/09151993a"
#property version   "1.20"
#property description "XANDER Pulse Candles — Colors chart candles based on momentum state."
#property description "Electric Depth palette: 4 bias states + neutral."
#property description "Three modes: Momentum vs Center, Momentum vs Extremes, Momentum Direction."
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  0x00FF7F,0x00BFFF,0xFF4500,0xDA70D6,0x696969
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
enum ENUM_PULSE_MODE
  {
   PULSE_VS_CENTER,    // Momentum vs Center Line
   PULSE_VS_EXTREMES,  // Momentum vs Extreme Zones
   PULSE_DIRECTION,    // Momentum Rising or Falling
  };
enum ENUM_CANDLE_BIAS
  {
   BIAS_BULL,
   BIAS_BEAR,
   BIAS_NEUTRAL,
  };
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string  sep0          = "★ XANDER Pulse Candles";  // ══ XANDER Systems ══
input string  sep1          = "══════ COLORING MODE ══════"; // ─────────────────────
input ENUM_PULSE_MODE xs_Mode         = PULSE_VS_CENTER; // Coloring Mode
input string  sep2          = "══════ MOMENTUM SETTINGS ══════"; // ─────────────────────
input uint    xs_Period      = 14;          // Momentum Period
input ENUM_APPLIED_PRICE xs_Price = PRICE_CLOSE; // Applied Price
input string  sep3          = "══════ EXTREME ZONES ══════"; // ─────────────────────
input double  xs_UpperZone   = 70.0;        // Upper Extreme Zone
input double  xs_LowerZone   = 30.0;        // Lower Extreme Zone
input string  sep4          = "══════ XANDER Systems ══════"; // ─────────────────────
//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
double buf_Open[];
double buf_High[];
double buf_Low[];
double buf_Close[];
double buf_Colors[];
double buf_Momentum[];
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int    xs_period;
double xs_upper;
double xs_lower;
int    handle_momentum;
bool   prev_grid;
bool   prev_volumes;
bool   prev_trade_history;
bool   prev_trade_levels;
bool   prev_bid_line;
bool   prev_ask_line;
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate and store inputs
   xs_period = int(xs_Period < 1 ? 1 : xs_Period);
   xs_upper  = (xs_UpperZone > 100 ? 100 : xs_UpperZone < 0.1 ? 0.1 : xs_UpperZone);
   xs_lower  = (xs_LowerZone < 0   ? 0   : xs_LowerZone >= xs_upper ? xs_upper - 0.1 : xs_LowerZone);
//--- save chart state
   prev_grid          = (bool)ChartGetInteger(0, CHART_SHOW_GRID);
   prev_volumes       = (bool)ChartGetInteger(0, CHART_SHOW_VOLUMES);
   prev_trade_history = (bool)ChartGetInteger(0, CHART_SHOW_TRADE_HISTORY);
   prev_trade_levels  = (bool)ChartGetInteger(0, CHART_SHOW_TRADE_LEVELS);
   prev_bid_line      = (bool)ChartGetInteger(0, CHART_SHOW_BID_LINE);
   prev_ask_line      = (bool)ChartGetInteger(0, CHART_SHOW_ASK_LINE);
//--- clean chart
   ChartSetInteger(0, CHART_SHOW_GRID,          false);
   ChartSetInteger(0, CHART_SHOW_VOLUMES,        false);
   ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY,  false);
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS,   false);
   ChartSetInteger(0, CHART_SHOW_BID_LINE,       false);
   ChartSetInteger(0, CHART_SHOW_ASK_LINE,       false);
   ChartSetInteger(0, CHART_FOREGROUND,          false);
   ChartRedraw(0);
//--- map buffers
   SetIndexBuffer(0, buf_Open,     INDICATOR_DATA);
   SetIndexBuffer(1, buf_High,     INDICATOR_DATA);
   SetIndexBuffer(2, buf_Low,      INDICATOR_DATA);
   SetIndexBuffer(3, buf_Close,    INDICATOR_DATA);
   SetIndexBuffer(4, buf_Colors,   INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5, buf_Momentum, INDICATOR_CALCULATIONS);
//--- set as time series
   ArraySetAsSeries(buf_Open,     true);
   ArraySetAsSeries(buf_High,     true);
   ArraySetAsSeries(buf_Low,      true);
   ArraySetAsSeries(buf_Close,    true);
   ArraySetAsSeries(buf_Colors,   true);
   ArraySetAsSeries(buf_Momentum, true);
//--- indicator properties
   IndicatorSetString(INDICATOR_SHORTNAME, "XANDER Pulse Candles (" + (string)xs_period + ")");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
//--- create momentum handle
   ResetLastError();
   handle_momentum = iRSI(NULL, PERIOD_CURRENT, xs_period, xs_Price);
   if(handle_momentum == INVALID_HANDLE)
     {
      Print("XANDER Pulse Candles: Failed to create momentum handle. Error ", GetLastError());
      return INIT_FAILED;
     }
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ChartSetInteger(0, CHART_SHOW_GRID,         prev_grid);
   ChartSetInteger(0, CHART_SHOW_VOLUMES,       prev_volumes);
   ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY, prev_trade_history);
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS,  prev_trade_levels);
   ChartSetInteger(0, CHART_SHOW_BID_LINE,      prev_bid_line);
   ChartSetInteger(0, CHART_SHOW_ASK_LINE,      prev_ask_line);
   ChartSetInteger(0, CHART_FOREGROUND,         false);
   ChartRedraw(0);
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
   if(rates_total < fmax(xs_period, 4)) return 0;
//--- set as time series
   ArraySetAsSeries(open,  true);
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);
//--- determine bars to calculate
   int limit = rates_total - prev_calculated;
   if(limit > 1)
     {
      limit = rates_total - 2;
      ArrayInitialize(buf_Open,     EMPTY_VALUE);
      ArrayInitialize(buf_High,     EMPTY_VALUE);
      ArrayInitialize(buf_Low,      EMPTY_VALUE);
      ArrayInitialize(buf_Close,    EMPTY_VALUE);
      ArrayInitialize(buf_Colors,   4);
      ArrayInitialize(buf_Momentum, 0);
     }
//--- copy momentum data
   int count  = (limit > 1 ? rates_total : 1);
   int copied = CopyBuffer(handle_momentum, 0, 0, count, buf_Momentum);
   if(copied != count) return 0;
//--- main loop
   for(int i = limit; i >= 0 && !IsStopped(); i--)
     {
      buf_Open[i]  = open[i];
      buf_High[i]  = high[i];
      buf_Low[i]   = low[i];
      buf_Close[i] = close[i];
      ENUM_CANDLE_BIAS candle_bias  = GetCandleBias(i, open, close);
      ENUM_CANDLE_BIAS momentum_bias = GetMomentumBias(i);
      buf_Colors[i] =
        (
         momentum_bias == BIAS_BULL ?
         (candle_bias == BIAS_BULL ? 0 : candle_bias == BIAS_BEAR ? 1 : 4) :
         momentum_bias == BIAS_BEAR ?
         (candle_bias == BIAS_BEAR ? 2 : candle_bias == BIAS_BULL ? 3 : 4) : 4
        );
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
//| Returns momentum bias based on selected mode                     |
//+------------------------------------------------------------------+
ENUM_CANDLE_BIAS GetMomentumBias(const int shift)
  {
   switch(xs_Mode)
     {
      case PULSE_VS_EXTREMES:
         return(buf_Momentum[shift] > xs_upper ? BIAS_BULL :
                buf_Momentum[shift] < xs_lower ? BIAS_BEAR : BIAS_NEUTRAL);
      case PULSE_DIRECTION:
         return(buf_Momentum[shift] > buf_Momentum[shift + 1] ? BIAS_BULL :
                buf_Momentum[shift] < buf_Momentum[shift + 1] ? BIAS_BEAR : BIAS_NEUTRAL);
      default: // PULSE_VS_CENTER
         return(buf_Momentum[shift] > 50 ? BIAS_BULL :
                buf_Momentum[shift] < 50 ? BIAS_BEAR : BIAS_NEUTRAL);
     }
  }
//+------------------------------------------------------------------+
//| Returns candle body direction                                     |
//+------------------------------------------------------------------+
ENUM_CANDLE_BIAS GetCandleBias(const int shift, const double &open[], const double &close[])
  {
   return(open[shift] < close[shift] ? BIAS_BULL :
          open[shift] > close[shift] ? BIAS_BEAR : BIAS_NEUTRAL);
  }
//+------------------------------------------------------------------+
