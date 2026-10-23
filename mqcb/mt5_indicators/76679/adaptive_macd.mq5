//+------------------------------------------------------------------+
//|                                             Adaptive_MACD.mq5    |
//|                                                                  |
//+------------------------------------------------------------------+
#property description "Author WeChat: wy911449"


//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_color1  C'0x5B,0x9C,0xF6',C'0x5B,0x9C,0xF6',C'0xF7,0x7C,0x80',C'0xF7,0x7C,0x80'
#property indicator_color2  clrWhite
#property indicator_color3  C'0xFF,0x5D,0x00'
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_label1  "Histogram"
#property indicator_label2  "MACD"
#property indicator_label3  "Signal"

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "Settings"
input int    InpR2Length   = 20;                    // R2 Period
input int    InpFast       = 10;                    // Fast Length
input int    InpSlow       = 20;                    // Slow Length
input int    InpSignal     = 9;                     // Signal Length

input group "Style"
input color  InpBullColor   = C'0x5B,0x9C,0xF6';    // Histogram Bull Color
input color  InpBearColor   = C'0xF7,0x7C,0x80';    // Histogram Bear Color
input bool   InpAutoFg      = true;                 // Auto MACD Color (theme)
input color  InpMacdColor   = clrWhite;             // MACD Color (manual)
input color  InpSignalColor = C'0xFF,0x5D,0x00';    // Signal Color

//+------------------------------------------------------------------+
//| Indicator buffers                                                |
//+------------------------------------------------------------------+
double  HistBuf[];       // 0 : Histogram value
double  ColorBuf[];      // 1 : Histogram color index (0..3)
double  MacdBuf[];       // 2 : MACD line
double  SigBuf[];        // 3 : Signal line

//--- Internal state
double  m_a1    = 0.0;
double  m_a2    = 0.0;
double  m_aSig  = 0.0;

//+------------------------------------------------------------------+
//| Pearson correlation coefficient: close vs. bar_index              |
//| (window length 'len', ending at 'start')                          |
//+------------------------------------------------------------------+
double PearsonCorrelation(const double &src[], const int start, const int len)
  {
   if(len < 2 || start < len - 1)
      return(0.0);
   const int first = start - len + 1;
//--- Means
   double sumX = 0.0;
   double sumY = 0.0;
   for(int k = 0; k < len; k++)
     {
      sumX += src[first + k];
      sumY += (first + k);
     }
   double meanX = sumX / len;
   double meanY = sumY / len;
//--- Covariance and variances
   double cov  = 0.0;
   double varX = 0.0;
   double varY = 0.0;
   for(int k = 0; k < len; k++)
     {
      double dx = src[first + k] - meanX;
      double dy = (first + k) - meanY;
      cov  += dx * dy;
      varX += dx * dx;
      varY += dy * dy;
     }
   if(varX == 0.0 || varY == 0.0)
      return(0.0);
   return(cov / MathSqrt(varX * varY));
  }

//+------------------------------------------------------------------+
//| Update MACD line color (auto: inverse based on chart background)  |
//+------------------------------------------------------------------+
void UpdateMacdColor()
  {
   if(!InpAutoFg)
     {
      PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, InpMacdColor);
      return;
     }
   static long lastBg = -1;
   long bg = ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   if(bg == lastBg)
      return;
   lastBg = bg;
//--- Calculate brightness, select foreground color
   uint   u = (uint)(bg & 0xFFFFFF);
   uint   r = u & 0xFF;
   uint   g = (u >> 8)  & 0xFF;
   uint   b = (u >> 16) & 0xFF;
   double y = 0.299 * (double)r + 0.587 * (double)g + 0.114 * (double)b;
   color fg = (y > 128.0) ? clrBlack : clrWhite;
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, fg);
  }

//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- Buffer mapping
   SetIndexBuffer(0, HistBuf,  INDICATOR_DATA);
   SetIndexBuffer(1, ColorBuf, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, MacdBuf,  INDICATOR_DATA);
   SetIndexBuffer(3, SigBuf,   INDICATOR_DATA);
//--- Histogram 4-state colors (0 strong bullish, 1 weak bullish, 2 strong bearish, 3 weak bearish)
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, InpBullColor);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, ColorToARGB(InpBullColor, 128));
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, InpBearColor);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 3, ColorToARGB(InpBearColor, 128));
//--- Start drawing position (no data when correlation window is insufficient)
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpR2Length - 1);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpR2Length - 1);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, InpR2Length - 1);
//--- Line colors and labels
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, InpMacdColor);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 0, InpSignalColor);
   PlotIndexSetString(0, PLOT_LABEL, "Histogram");
   PlotIndexSetString(1, PLOT_LABEL, "MACD");
   PlotIndexSetString(2, PLOT_LABEL, "Signal");
//--- Others
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "Adaptive MACD");
//--- Coefficients (Pine: var a1/a2, signal EMA alpha)
   m_a1   = 2.0 / (double)(InpFast   + 1);
   m_a2   = 2.0 / (double)(InpSlow   + 1);
   m_aSig = 2.0 / (double)(InpSignal + 1);
   UpdateMacdColor();
  }

//+------------------------------------------------------------------+
//| Main calculation                                                  |
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
   if(rates_total < 2)
      return(0);
//--- Dynamic foreground color
   UpdateMacdColor();
//--- Recursive state
   double prevMacd1 = 0.0;   // macd[i-1]
   double prevMacd2 = 0.0;   // macd[i-2]
   double emaPrev   = 0.0;   // ema[i-1]
   bool   firstEma  = true;
//--- Main loop
   for(int i = 0; i < rates_total && !IsStopped(); i++)
     {
      //--- Correlation window insufficient: no data (corresponds to Pine's na segment)
      if(i < InpR2Length - 1)
        {
         HistBuf[i]     = EMPTY_VALUE;
         ColorBuf[i]    = 0;
         MacdBuf[i]     = EMPTY_VALUE;
         SigBuf[i]      = EMPTY_VALUE;
         continue;
        }
      //--- Adaptive coefficient K
      double corr = PearsonCorrelation(close, i, InpR2Length);
      double r2   = 0.5 * corr * corr + 0.5;
      double K    = r2 * ((1.0 - m_a1) * (1.0 - m_a2))
                    + (1.0 - r2) * ((1.0 - m_a1) / (1.0 - m_a2));
      //--- Adaptive MACD second-order recurrence
      double macdVal = (close[i] - close[i - 1]) * (m_a1 - m_a2)
                       + (2.0 - m_a1 - m_a2) * prevMacd1
                       - K * prevMacd2;
      prevMacd2 = prevMacd1;
      prevMacd1 = macdVal;
      //--- Signal line EMA
      double emaVal;
      if(firstEma)
        {
         emaVal   = macdVal;
         firstEma = false;
        }
      else
         emaVal = macdVal * m_aSig + emaPrev * (1.0 - m_aSig);
      emaPrev = emaVal;
      //--- Buffers
      MacdBuf[i]     = macdVal;
      SigBuf[i]      = emaVal;
      double histVal = macdVal - emaVal;
      HistBuf[i]     = histVal;
      //--- Color index (0 strong bullish, 1 weak bullish, 2 strong bearish, 3 weak bearish)
      double hPrev = HistBuf[i - 1];
      if(hPrev == EMPTY_VALUE)
         ColorBuf[i] = 3;                       // First valid bar: corresponds to Pine's na branch
      else
         if(histVal > 0.0)
            ColorBuf[i] = (histVal > hPrev) ? 0 : 1;
         else
            ColorBuf[i] = (histVal < hPrev) ? 2 : 3;
     }
//---
   return(rates_total);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+