//+------------------------------------------------------------------+
//| XANDER Adaptive Cross                                            |
//| Version: 1.1          | Date: 2026-04-19                         |
//| Platform: MT5                                                    |
//| Company: XANDER Systems                                          |
//+------------------------------------------------------------------+
// CHANGELOG:
// v1.0 - 2026-04-19 - Initial release
// v1.1 - 2026-04-19 - Distinct color palettes for Fast (green/red) and Slow (gold/orchid)
//+------------------------------------------------------------------+
// Join our trading community:
// Telegram : https://t.me/xandertool
//
// Freelance & development requests — MQL5 profile only:
// MQL5     : https://www.mql5.com/en/users/09151993a
//+------------------------------------------------------------------+
#property copyright "© XANDER Systems"
#property link      "https://www.mql5.com/en/users/09151993a"
#property version   "1.10"
#property description "XANDER Adaptive Cross — Two adaptive moving averages with crossover signals."
#property description "Fast line (green/red) adapts to price position within the High/Low range."
#property description "Slow line (gold/orchid) adapts to market efficiency (signal-to-noise ratio)."
#property description "Arrows mark crossover events. Each line carries its own color identity."
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
//--- Fast adaptive line
#property indicator_label1  "Fast Adaptive"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  0x696969,0x00FF7F,0xFF4500
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- Slow adaptive line
#property indicator_label2  "Slow Adaptive"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  0x696969,0xFFD700,0xBA55D3
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- Signal up arrow
#property indicator_label3  "Signal Up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  0x00FF7F
#property indicator_width3  2
//--- Signal down arrow
#property indicator_label4  "Signal Down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  0xFF4500
#property indicator_width4  2
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string            sep0         = "★ XANDER Adaptive Cross"; // ══ XANDER Systems ══
input string            sep1         = "══════ ADAPTIVE SETTINGS ══════"; // ─────────────────────
input int               xs_Period    = 14;          // Adaptive Period
input ENUM_APPLIED_PRICE xs_Price    = PRICE_CLOSE; // Applied Price
input string            sep2         = "══════ SMOOTHING ══════"; // ─────────────────────
input int               xs_FastEnd   = 2;           // Fast Smoothing Period
input int               xs_SlowEnd   = 30;          // Slow Smoothing Period
input double            xs_Power     = 2.0;         // Efficiency Curve Power
//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
double buf_Fast[];
double buf_FastColor[];
double buf_Slow[];
double buf_SlowColor[];
double buf_SigUp[];
double buf_SigDn[];
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double g_fastCoeff;
double g_slowCoeff;
int    g_rangePeriod;
bool   prev_grid;
bool   prev_volumes;
bool   prev_trade_history;
bool   prev_trade_levels;
bool   prev_bid_line;
bool   prev_ask_line;
//+------------------------------------------------------------------+
//| Slow adaptive MA — efficiency ratio based                        |
//+------------------------------------------------------------------+
class CSlowAdaptive
  {
private:
   int    m_period;
   int    m_size;
   double m_fastCoeff;
   double m_slowCoeff;
   double m_power;
   struct SBar
     {
      double diff;
      double noise;
      double price;
      double value;
     };
   SBar   m_buf[];

public:
   CSlowAdaptive() { setup(14, 2, 30, 2.0); }
  ~CSlowAdaptive() { ArrayFree(m_buf); }

   bool setup(int period, int fastEnd, int slowEnd, double power)
     {
      m_period    = (period > 1) ? period : 1;
      m_size      = m_period + 32;
      m_fastCoeff = 2.0 / (fastEnd + 1.0);
      m_slowCoeff = 2.0 / (slowEnd + 1.0);
      m_power     = power;
      return ArrayResize(m_buf, m_size) == m_size;
     }

   double calculate(double price, int bar)
     {
      int cur  = bar % m_size;
      int prev = (bar - 1) % m_size;

      m_buf[cur].price = price;
      m_buf[cur].diff  = (bar > 0) ? MathAbs(price - m_buf[prev].price) : 0.0;

      double signal = 0.0;
      if(bar > m_period)
        {
         int old = (bar - m_period) % m_size;
         signal          = MathAbs(price - m_buf[old].price);
         m_buf[cur].noise = m_buf[prev].noise + m_buf[cur].diff - m_buf[old].diff;
        }
      else
        {
         m_buf[cur].noise = m_buf[cur].diff;
         for(int k = 1; k < m_period && bar >= k; k++)
            m_buf[cur].noise += m_buf[(bar - k) % m_size].diff;
        }

      double er   = (m_buf[cur].noise != 0.0) ? signal / m_buf[cur].noise : 1.0;
      double sc   = MathPow(er * (m_fastCoeff - m_slowCoeff) + m_slowCoeff, m_power);
      m_buf[cur].value = (bar > 0)
                         ? m_buf[prev].value + sc * (price - m_buf[prev].value)
                         : price;
      return m_buf[cur].value;
     }
  };
CSlowAdaptive slowMA;
//+------------------------------------------------------------------+
//| Get price by applied price type                                  |
//+------------------------------------------------------------------+
double GetPrice(ENUM_APPLIED_PRICE type, int i,
                const double &open[], const double &high[],
                const double &low[],  const double &close[])
  {
   switch(type)
     {
      case PRICE_OPEN:     return open[i];
      case PRICE_HIGH:     return high[i];
      case PRICE_LOW:      return low[i];
      case PRICE_MEDIAN:   return (high[i] + low[i]) / 2.0;
      case PRICE_TYPICAL:  return (high[i] + low[i] + close[i]) / 3.0;
      case PRICE_WEIGHTED: return (high[i] + low[i] + close[i] * 2.0) / 4.0;
      default:             return close[i];
     }
  }
//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate inputs
   if(xs_Period < 1 || xs_FastEnd < 1 || xs_SlowEnd <= xs_FastEnd)
     {
      Print("XANDER Adaptive Cross: Invalid input parameters.");
      return INIT_PARAMETERS_INCORRECT;
     }
//--- compute coefficients
   g_fastCoeff  = 2.0 / (xs_FastEnd + 1.0);
   g_slowCoeff  = 2.0 / (xs_SlowEnd + 1.0);
   g_rangePeriod = xs_Period + 1;
//--- init slow MA engine
   slowMA.setup(xs_Period, xs_FastEnd, xs_SlowEnd, xs_Power);
//--- save chart state
   prev_grid          = (bool)ChartGetInteger(0, CHART_SHOW_GRID);
   prev_volumes       = (bool)ChartGetInteger(0, CHART_SHOW_VOLUMES);
   prev_trade_history = (bool)ChartGetInteger(0, CHART_SHOW_TRADE_HISTORY);
   prev_trade_levels  = (bool)ChartGetInteger(0, CHART_SHOW_TRADE_LEVELS);
   prev_bid_line      = (bool)ChartGetInteger(0, CHART_SHOW_BID_LINE);
   prev_ask_line      = (bool)ChartGetInteger(0, CHART_SHOW_ASK_LINE);
//--- clean chart
   ChartSetInteger(0, CHART_SHOW_GRID,         false);
   ChartSetInteger(0, CHART_SHOW_VOLUMES,       false);
   ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY, false);
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS,  false);
   ChartSetInteger(0, CHART_SHOW_BID_LINE,      false);
   ChartSetInteger(0, CHART_SHOW_ASK_LINE,      false);
   ChartSetInteger(0, CHART_FOREGROUND,         false);
   ChartRedraw(0);
//--- map buffers
   SetIndexBuffer(0, buf_Fast,      INDICATOR_DATA);
   SetIndexBuffer(1, buf_FastColor, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, buf_Slow,      INDICATOR_DATA);
   SetIndexBuffer(3, buf_SlowColor, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, buf_SigUp,     INDICATOR_DATA);
   SetIndexBuffer(5, buf_SigDn,     INDICATOR_DATA);
//--- arrow codes
   PlotIndexSetInteger(2, PLOT_ARROW,       217);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
   PlotIndexSetInteger(3, PLOT_ARROW,       218);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -10);
//--- short name
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "XANDER Adaptive Cross (" + (string)xs_Period + ")");
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
   static int    last_bar = -1;
   static double last_max, last_min;

   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;

   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      double price = GetPrice(xs_Price, i, open, high, low, close);

      //--- range high/low for fast adaptive
      if(last_bar != i)
        {
         last_bar = i;
         int from = i - g_rangePeriod + 1;
         if(from < 0) from = 0;
         last_max = high[ArrayMaximum(high, from, i - from + 1)];
         last_min = low [ArrayMinimum(low,  from, i - from + 1)];
        }
      double rng_max = (high[i] > last_max) ? high[i] : last_max;
      double rng_min = (low[i]  < last_min) ? low[i]  : last_min;

      //--- fast adaptive: price position within range
      double mltp = (rng_max != rng_min)
                    ? MathAbs(((price - rng_min) - (rng_max - price)) / (rng_max - rng_min))
                    : 1.0;
      double sc   = mltp * (g_fastCoeff - g_slowCoeff) + g_slowCoeff;

      buf_Fast[i] = (i > 0) ? buf_Fast[i-1] + sc * sc * (price - buf_Fast[i-1]) : price;

      //--- slow adaptive: efficiency ratio based
      buf_Slow[i] = slowMA.calculate(price, i);

      //--- color index: 0=neutral, 1=bull (fast>slow), 2=bear (fast<slow)
      int bias;
      if(buf_Fast[i] > buf_Slow[i])       bias = 1;
      else if(buf_Fast[i] < buf_Slow[i])  bias = 2;
      else                                bias = (i > 0) ? (int)buf_FastColor[i-1] : 0;

      buf_FastColor[i] = bias;
      buf_SlowColor[i] = bias;

      //--- crossover arrows
      bool crossed = (i > 0 && bias != (int)buf_FastColor[i-1]);
      buf_SigUp[i] = (crossed && bias == 1) ? MathMin(buf_Slow[i], low[i])  : EMPTY_VALUE;
      buf_SigDn[i] = (crossed && bias == 2) ? MathMax(buf_Slow[i], high[i]) : EMPTY_VALUE;
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
