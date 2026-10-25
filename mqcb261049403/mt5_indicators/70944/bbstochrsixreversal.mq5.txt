//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "© 2026 tshalgo"
#property link "https://www.mql5.com/en/users/protimetrader"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 7   // upper, lower, basis, fillUpper, fillLower, bearArrow, bullArrow
#property indicator_plots   6   // upperLine, lowerLine, basis, fillArea(optional), bearArrow, bullArrow

//--- Plot 1
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  C'0,128,128'
#property indicator_width1  1

//--- Plot 2
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  C'0,128,128'
#property indicator_width2  1

//--- Plot 3
#property indicator_label3  "Basis"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMaroon
#property indicator_width3  1

//--- Plot 4
#property indicator_label4  "Upper;Lower"
#property indicator_type4   DRAW_FILLING
#property indicator_color4  C'0,128,128'

//--- Plot 5
#property indicator_label5  "Bear Signal"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrTomato
#property indicator_width5  2

//--- Plot 6
#property indicator_label6  "Bull Signal"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrOlive
#property indicator_width6  2

//--- Inputs
input int    InpLength      = 20;   // BB Period
input double InpMult        = 2.0;  // BB Deviations
input int    InpSmoothK     = 3;    // K Smoothing
input int    InpSmoothD     = 3;    // D Smoothing
input int    InpLengthRSI   = 14;   // RSI Period
input int    InpLengthStoch = 14;   // Stochastic Length
input double InpUpperLimit  = 90.0; // Upper Limit
input double InpLowerLimit  = 10.0; // Lower Limit
input bool   InpFillBands   = true; // Fill Between Bands
input bool   InpShowDashboard = true; // Show Dashboard

#define ATR_PERIOD 14 // fixed

//--- Plotted indicator buffers
double g_upperBuf[];
double g_lowerBuf[];
double g_basisBuf[];
double g_fillUpperBuf[]; 
double g_fillLowerBuf[];
double g_bearArrowBuf[];
double g_bullArrowBuf[];

int    g_bbHandle  = INVALID_HANDLE;
int    g_atrHandle = INVALID_HANDLE;
double g_atrBuf[];

//--- Last-signal tracking
enum ENUM_SIGNAL_TYPE { SIGNAL_NONE, SIGNAL_BULL, SIGNAL_BEAR };
ENUM_SIGNAL_TYPE g_lastSignalType  = SIGNAL_NONE;
int              g_lastSignalIndex = -1;
double           g_lastSignalPrice = 0.0;

int    g_rsiHandle = INVALID_HANDLE;
double g_rsiBuf[];       // copied from iRSI
double g_stochHighest[]; // rolling highest RSI over InpLengthStoch
double g_stochLowest[];  // rolling lowest RSI over InpLengthStoch
double g_stochRaw[];     // raw stoch-of-RSI ratio, pre-smoothing
double g_stochK[];       // SMA(raw, smoothK)
double g_stochD[];       // SMA(K,   smoothD)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool StochRSI_Init()
  {
   g_rsiHandle = iRSI(_Symbol, _Period, InpLengthRSI, PRICE_CLOSE);
   if(g_rsiHandle == INVALID_HANDLE)
     {
      Print("StochRSI: failed to create RSI handle");
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool StochRSI_Calculate(const int rates_total, const int prev_calculated)
  {
   const int min_bars = InpLengthRSI + InpLengthStoch + InpSmoothK + InpSmoothD;
   if(rates_total <= min_bars)
      return false;

   if(ArraySize(g_rsiBuf) != rates_total)
     {
      ArrayResize(g_rsiBuf,       rates_total);
      ArrayResize(g_stochHighest, rates_total);
      ArrayResize(g_stochLowest,  rates_total);
      ArrayResize(g_stochRaw,     rates_total);
      ArrayResize(g_stochK,       rates_total);
      ArrayResize(g_stochD,       rates_total);
     }

   ArraySetAsSeries(g_rsiBuf, false);
   if(CopyBuffer(g_rsiHandle, 0, 0, rates_total, g_rsiBuf) <= 0)
      return false;

   int i, k, start;

   start = InpLengthStoch - 1;
   if(start + 1 < prev_calculated)
      start = prev_calculated - 2;
   else
     {
      for(i = 0; i < start; i++)
        {
         g_stochHighest[i] = 0.0;
         g_stochLowest[i]  = 0.0;
        }
     }
   for(i = start; i < rates_total && !IsStopped(); i++)
     {
      double dmin =  DBL_MAX;
      double dmax = -DBL_MAX;
      for(k = i - InpLengthStoch + 1; k <= i; k++)
        {
         const double r = g_rsiBuf[k];
         if(dmin > r)
            dmin = r;
         if(dmax < r)
            dmax = r;
        }
      g_stochLowest[i]  = dmin;
      g_stochHighest[i] = dmax;
     }

   start = InpLengthStoch - 1;
   if(start + 1 < prev_calculated)
      start = prev_calculated - 2;
   else
     {
      for(i = 0; i < start; i++)
         g_stochRaw[i] = 0.0;
     }
   for(i = start; i < rates_total && !IsStopped(); i++)
     {
      const double range = g_stochHighest[i] - g_stochLowest[i];
      g_stochRaw[i] = (range == 0.0) ? 100.0 : (g_rsiBuf[i] - g_stochLowest[i]) / range * 100.0;
     }

   start = InpLengthStoch - 1 + InpSmoothK - 1;
   if(start + 1 < prev_calculated)
      start = prev_calculated - 2;
   else
     {
      for(i = 0; i < start; i++)
         g_stochK[i] = 0.0;
     }
   for(i = start; i < rates_total && !IsStopped(); i++)
     {
      double sum = 0.0;
      for(k = i - InpSmoothK + 1; k <= i; k++)
         sum += g_stochRaw[k];
      g_stochK[i] = sum / InpSmoothK;
     }

   start = InpLengthStoch - 1 + InpSmoothK - 1 + InpSmoothD - 1;
   if(start + 1 < prev_calculated)
      start = prev_calculated - 2;
   else
     {
      for(i = 0; i < start; i++)
         g_stochD[i] = 0.0;
     }
   for(i = start; i < rates_total && !IsStopped(); i++)
     {
      double sum = 0.0;
      for(k = i - InpSmoothD + 1; k <= i; k++)
         sum += g_stochK[k];
      g_stochD[i] = sum / InpSmoothD;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| PANEL                                        |
//+------------------------------------------------------------------+
#define PNL_PREFIX "BBSRX_"
#define PNL_X      10
#define PNL_Y      20
#define PNL_WIDTH  256
#define PNL_ROWH   16
#define PNL_LEFTW  90
#define PNL_PAD    6

color clrPnlBg     = C'26,29,34';
color clrPnlMuted  = C'150,154,160';
color clrPnlTeal   = C'0,168,168';
color clrPnlSep    = C'70,74,82';
color clrPnlFooter = C'120,125,132';

string PnlName(const string suffix) { return PNL_PREFIX + suffix; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PnlCreateRect(const string suffix, int x, int y, int w, int h, color bg)
  {
   const string name = PnlName(suffix);
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PnlCreateLabel(const string suffix, string text, int x, int y, color clr, int fontSize = 9)
  {
   const string name = PnlName(suffix);
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Segoe UI");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PnlCreateRow(const string suffix, string leftText, string rightText, int y)
  {
   PnlCreateLabel(suffix + "_lbl", leftText, PNL_X + PNL_PAD, y, clrPnlMuted);
   PnlCreateLabel(suffix + "_val", rightText, PNL_X + PNL_LEFTW, y, clrWhite);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PnlSetRowValue(const string rowSuffix, string text) { ObjectSetString(0, PnlName(rowSuffix + "_val"), OBJPROP_TEXT, text); }
void PnlSetRowColor(const string rowSuffix, color clr)   { ObjectSetInteger(0, PnlName(rowSuffix + "_val"), OBJPROP_COLOR, clr); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PanelCreate()
  {
   PnlCreateRect("bg", PNL_X, PNL_Y, PNL_WIDTH, 400, clrPnlBg);

   int y = PNL_Y + 4;
   PnlCreateLabel("title", "BB StochRSI Xtreme Reversal", PNL_X + PNL_PAD, y + 2, clrPnlTeal, 10);
   y += 22;
   PnlCreateRect("sep0", PNL_X, y, PNL_WIDTH, 1, clrPnlSep);
   y += 6;

   PnlCreateRow("close",   "Close:",    "--", y);
   y += PNL_ROWH;
   PnlCreateRow("bbupper", "BB Upper:", "--", y);
   y += PNL_ROWH;
   PnlCreateRow("bbbasis", "BB Basis:", "--", y);
   y += PNL_ROWH;
   PnlCreateRow("bblower", "BB Lower:", "--", y);
   y += PNL_ROWH;
   PnlCreateRow("atr",     "ATR(14):",  "--", y);
   y += PNL_ROWH;
   PnlCreateRect("sep1", PNL_X, y, PNL_WIDTH, 1, clrPnlSep);
   y += 6;

   PnlCreateRow("k",     "StochRSI K:", "--",      y);
   y += PNL_ROWH;
   PnlCreateRow("d",     "StochRSI D:", "--",      y);
   y += PNL_ROWH;
   PnlCreateRow("zone",  "Zone:",       "NEUTRAL", y);
   y += PNL_ROWH;
   PnlCreateRow("setup", "Setup:",      "-",       y);
   y += PNL_ROWH;
   PnlCreateRect("sep2", PNL_X, y, PNL_WIDTH, 1, clrPnlSep);
   y += 6;

   PnlCreateRow("sigtype",  "Last Signal:", "-", y);
   y += PNL_ROWH;
   PnlCreateRow("sigprice", "Price:",       "-", y);
   y += PNL_ROWH;
   PnlCreateRow("sigage",   "Age:",         "-", y);
   y += PNL_ROWH;
   PnlCreateRect("sep3", PNL_X, y, PNL_WIDTH, 1, clrPnlSep);
   y += 6;

   PnlCreateLabel("params1", "len - / mult - / rsi - / stoch -", PNL_X + PNL_PAD, y, clrPnlFooter, 8);
   y += 12;
   PnlCreateLabel("params2", "smoothK - / smoothD - / lim -/-",  PNL_X + PNL_PAD, y, clrPnlFooter, 8);
   y += 14;

   ObjectSetInteger(0, PnlName("bg"), OBJPROP_YSIZE, y - PNL_Y + PNL_PAD);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PanelSetParams(int length, double mult, int rsiPeriod, int lengthStoch,
                    int smoothK, int smoothD, double upperLimit, double lowerLimit)
  {
   ObjectSetString(0, PnlName("params1"),
                   OBJPROP_TEXT,
                   "len " + IntegerToString(length) +
                   " / mult " + DoubleToString(mult, 1) +
                   " / rsi " + IntegerToString(rsiPeriod) +
                   " / stoch " + IntegerToString(lengthStoch));

   ObjectSetString(0, PnlName("params2"),
                   OBJPROP_TEXT,
                   "smoothK " + IntegerToString(smoothK) +
                   " / smoothD " + IntegerToString(smoothD) +
                   " / lim " + DoubleToString(upperLimit, 0) +
                   "/" + DoubleToString(lowerLimit, 0));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatePanel(const int rates_total, const double &close[], const double &high[], const double &low[])
  {
   if(rates_total < 2)
      return;

   const int digits = (int)_Digits;
   const int c = rates_total - 1; // current (forming) bar
   const int p = rates_total - 2; // last closed bar

   PnlSetRowValue("close",   DoubleToString(close[c], digits));
   PnlSetRowValue("bbupper", DoubleToString(g_upperBuf[c], digits));
   PnlSetRowValue("bbbasis", DoubleToString(g_basisBuf[c], digits));
   PnlSetRowValue("bblower", DoubleToString(g_lowerBuf[c], digits));
   PnlSetRowValue("atr",     DoubleToString(g_atrBuf[c], digits));

   PnlSetRowValue("k", DoubleToString(g_stochK[c], 1));
   PnlSetRowValue("d", DoubleToString(g_stochD[c], 1));

   if(g_stochK[c] > InpUpperLimit && g_stochD[c] > InpUpperLimit)
     {
      PnlSetRowValue("zone", "OVERBOUGHT (>" + IntegerToString((int)InpUpperLimit) + ")");
      PnlSetRowColor("zone", clrTomato);
     }
   else
      if(g_stochK[c] < InpLowerLimit && g_stochD[c] < InpLowerLimit)
        {
         PnlSetRowValue("zone", "OVERSOLD (<" + IntegerToString((int)InpLowerLimit) + ")");
         PnlSetRowColor("zone", clrOlive);
        }
      else
        {
         PnlSetRowValue("zone", "NEUTRAL");
         PnlSetRowColor("zone", clrGray);
        }

   const bool bearArmed = close[p] > g_upperBuf[p] && g_stochK[p] > InpUpperLimit && g_stochD[p] > InpUpperLimit;
   const bool bullArmed = close[p] < g_lowerBuf[p] && g_stochK[p] < InpLowerLimit && g_stochD[p] < InpLowerLimit;

   if(bearArmed)
     {
      PnlSetRowValue("setup", "ARMED - BEAR (waiting cross)");
      PnlSetRowColor("setup", clrOrange);
     }
   else
      if(bullArmed)
        {
         PnlSetRowValue("setup", "ARMED - BULL (waiting cross)");
         PnlSetRowColor("setup", clrOrange);
        }
      else
        {
         PnlSetRowValue("setup", "-");
         PnlSetRowColor("setup", clrGray);
        }

   if(g_lastSignalType == SIGNAL_NONE)
     {
      PnlSetRowValue("sigtype", "-");
      PnlSetRowColor("sigtype", clrGray);
      PnlSetRowValue("sigprice", "-");
      PnlSetRowValue("sigage", "-");
     }
   else
     {
      const bool isBull = (g_lastSignalType == SIGNAL_BULL);
      PnlSetRowValue("sigtype", isBull ? "BULL" : "BEAR");
      PnlSetRowColor("sigtype", isBull ? clrOlive : clrTomato);
      PnlSetRowValue("sigprice", DoubleToString(g_lastSignalPrice, digits));
      PnlSetRowValue("sigage", IntegerToString(c - g_lastSignalIndex) + " bars ago");
     }

   ChartRedraw(0);
  }

void PanelDestroy() { ObjectsDeleteAll(0, PNL_PREFIX); }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Bollinger Bands handle
   g_bbHandle = iBands(_Symbol, _Period, InpLength, 0, InpMult, PRICE_CLOSE);
   if(g_bbHandle == INVALID_HANDLE)
     {
      Print("Failed to create iBands handle");
      return INIT_FAILED;
     }

//--- ATR(14) handle
   g_atrHandle = iATR(_Symbol, _Period, ATR_PERIOD);
   if(g_atrHandle == INVALID_HANDLE)
     {
      Print("Failed to create iATR handle");
      return INIT_FAILED;
     }

//--- StochRSI 
   if(!StochRSI_Init())
      return INIT_FAILED;

//--- Map plotted buffers
   SetIndexBuffer(0, g_upperBuf,      INDICATOR_DATA);
   SetIndexBuffer(1, g_lowerBuf,      INDICATOR_DATA);
   SetIndexBuffer(2, g_basisBuf,      INDICATOR_DATA);
   SetIndexBuffer(3, g_fillUpperBuf,  INDICATOR_DATA);
   SetIndexBuffer(4, g_fillLowerBuf,  INDICATOR_DATA);
   SetIndexBuffer(5, g_bearArrowBuf,  INDICATOR_DATA);
   SetIndexBuffer(6, g_bullArrowBuf,  INDICATOR_DATA);

//--- Arrow codes
   PlotIndexSetInteger(4, PLOT_ARROW, 226); 
   PlotIndexSetInteger(5, PLOT_ARROW, 225); 

   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   IndicatorSetString(INDICATOR_SHORTNAME, "BB StochRSI Xtreme Reversal");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- Panel
   if(InpShowDashboard)
     {
      PanelCreate();
      PanelSetParams(InpLength, InpMult, InpLengthRSI, InpLengthStoch, InpSmoothK, InpSmoothD, InpUpperLimit, InpLowerLimit);
     }

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_bbHandle != INVALID_HANDLE)
      IndicatorRelease(g_bbHandle);
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   if(g_rsiHandle != INVALID_HANDLE)
      IndicatorRelease(g_rsiHandle);
   PanelDestroy();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
   const int rates_total,
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
   if(prev_calculated == rates_total)
      return rates_total;

   const int min_bars_required = InpLength + InpLengthRSI + InpLengthStoch + InpSmoothK + InpSmoothD + 1;
   if(rates_total <= min_bars_required)
      return 0;

   if(ArraySize(g_atrBuf) != rates_total)
      ArrayResize(g_atrBuf, rates_total);
   ArraySetAsSeries(g_atrBuf, false);

//--- iBands buffer numbering: 0=base(mid), 1=upper, 2=lower
   ArraySetAsSeries(g_basisBuf, false);
   ArraySetAsSeries(g_upperBuf, false);
   ArraySetAsSeries(g_lowerBuf, false);

   if(CopyBuffer(g_bbHandle, 0, 0, rates_total, g_basisBuf) <= 0)
      return 0;
   if(CopyBuffer(g_bbHandle, 1, 0, rates_total, g_upperBuf) <= 0)
      return 0;
   if(CopyBuffer(g_bbHandle, 2, 0, rates_total, g_lowerBuf) <= 0)
      return 0;
   if(CopyBuffer(g_atrHandle, 0, 0, rates_total, g_atrBuf)  <= 0)
      return 0;

   if(ArraySize(g_fillUpperBuf) != rates_total)
     {
      ArrayResize(g_fillUpperBuf, rates_total);
      ArrayResize(g_fillLowerBuf, rates_total);
     }
   ArraySetAsSeries(g_fillUpperBuf, false);
   ArraySetAsSeries(g_fillLowerBuf, false);

   for(int fi = 0; fi < rates_total; fi++)
     {
      if(InpFillBands)
        {
         g_fillUpperBuf[fi] = g_upperBuf[fi];
         g_fillLowerBuf[fi] = g_lowerBuf[fi];
        }
      else
        {
         g_fillUpperBuf[fi] = EMPTY_VALUE;
         g_fillLowerBuf[fi] = EMPTY_VALUE;
        }
     }

   if(!StochRSI_Calculate(rates_total, prev_calculated))
      return 0;

   int start = 1;
   if(start + 1 < prev_calculated)
      start = prev_calculated - 2;
   else
     {
      for(int i = 0; i < start; i++)
        {
         g_bearArrowBuf[i] = EMPTY_VALUE;
         g_bullArrowBuf[i] = EMPTY_VALUE;
        }
     }
   if(start < 1)
      start = 1;

   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      const int p = i - 1; // previous bar

      const bool bear =
         close[p] > g_upperBuf[p] &&
         close[i] < g_upperBuf[i] &&
         g_stochK[p] > InpUpperLimit &&
         g_stochD[p] > InpUpperLimit;

      const bool bull =
         close[p] < g_lowerBuf[p] &&
         close[i] > g_lowerBuf[i] &&
         g_stochK[p] < InpLowerLimit &&
         g_stochD[p] < InpLowerLimit;

      g_bearArrowBuf[i] = bear ? (high[i] + 0.25 * g_atrBuf[i]) : EMPTY_VALUE;
      g_bullArrowBuf[i] = bull ? (low[i]  - 0.25 * g_atrBuf[i]) : EMPTY_VALUE;

      if(bear)
        {
         g_lastSignalType  = SIGNAL_BEAR;
         g_lastSignalIndex = i;
         g_lastSignalPrice = g_bearArrowBuf[i];
        }
      else
         if(bull)
           {
            g_lastSignalType  = SIGNAL_BULL;
            g_lastSignalIndex = i;
            g_lastSignalPrice = g_bullArrowBuf[i];
           }
     }

   if(InpShowDashboard)
      UpdatePanel(rates_total, close, high, low);

   return rates_total;
  }
//+------------------------------------------------------------------+