//+------------------------------------------------------------------+
//|                                             AlgoFX.mq5  |
//|   Trend-filtered potential BUY / SELL zones + risk panel         |
//|   Signals use closed bars only - no repainting.                  |
//+------------------------------------------------------------------+
#property copyright   "Alban Haxha"
#property version     "1.00"
#property description "Highlights potential BUY zones in uptrends and potential SELL zones in downtrends."
#property description "Includes a risk panel with automatic lot size for your balance and a daily loss guard."
#property description "Zones are areas of interest, not trade instructions. Always use your own analysis."
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

#property indicator_label1  "Fast EMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  1

#property indicator_label2  "Slow EMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_width2  2

#property indicator_label3  "Potential BUY zone"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLimeGreen
#property indicator_width3  2

#property indicator_label4  "Potential SELL zone"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrTomato
#property indicator_width4  2

//--- Trend & zones
input group "Trend & zones"
input int      InpFastEMA        = 50;    // Fast EMA period
input int      InpSlowEMA        = 200;   // Slow EMA period (trend)
input int      InpSlopeBars      = 10;    // Bars used to confirm slow EMA slope
input int      InpATRPeriod      = 14;    // ATR period
input double   InpZoneDepthATR   = 1.0;   // Zone depth below/above fast EMA (x ATR)
input bool     InpUseRSIFilter   = true;  // Skip zones when RSI is stretched
input int      InpRSIPeriod      = 14;    // RSI period
input double   InpRSIUpper       = 70.0;  // No BUY zone above this RSI
input double   InpRSILower       = 30.0;  // No SELL zone below this RSI
input int      InpCooldownBars   = 12;    // Min bars between zones of the same side
input int      InpZoneLengthBars = 20;    // How far the zone box extends to the right
input int      InpHistoryBars    = 1500;  // Bars of history to scan

//--- Risk management
input group "Risk management"
input double   InpRiskPercent    = 1.0;   // Risk per trade (% of balance)
input bool     InpUseEquity      = false; // Use equity instead of balance
input double   InpStopATRMult    = 1.5;   // Assumed stop distance for lot calc (x ATR)
input double   InpMaxLot         = 5.0;   // Never suggest more than this lot
input double   InpMaxDailyLoss   = 4.0;   // Daily loss guard (% of start-of-day balance)

//--- Display & alerts
input group "Display & alerts"
input bool     InpChartDesign    = true;  // Apply the AlgoFX dark chart design
input bool     InpShowZoneBoxes  = true;  // Draw zone boxes
input bool     InpShowLabels     = true;  // Show "Potential BUY/SELL zone" text
input bool     InpShowPanel      = true;  // Show risk panel
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Panel corner
input int      InpPanelX         = 10;    // Panel X offset
input int      InpPanelY         = 25;    // Panel Y offset
input int      InpFontSize       = 9;     // Panel font size
input bool     InpPopupAlert     = true;  // Pop-up alert on new zone
input bool     InpPushAlert      = false; // Push notification on new zone
input color    InpBuyZoneColor   = C'0,90,40';  // BUY zone box color
input color    InpSellZoneColor  = C'110,20,20';// SELL zone box color

//--- buffers & handles
double BufFast[], BufSlow[], BufBuy[], BufSell[];
int    hFast = INVALID_HANDLE, hSlow = INVALID_HANDLE, hATR = INVALID_HANDLE, hRSI = INVALID_HANDLE;
double atrArr[], rsiArr[];

const string PFX = "AFX_";
datetime g_lastAlertBar = 0;

//====================================================================
// CHART DESIGN (display only) - dark AlgoFX/AlbTrades look.
// The trader's original colours are restored when the indicator is removed.
//====================================================================
#define DESIGN_BG      C'26,28,41'      // #1a1c29
#define DESIGN_BUY     C'131,133,144'   // bullish candles
#define DESIGN_SELL    C'185,54,51'     // #b93633 bearish candles
#define DESIGN_TEXT    C'200,202,212'   // price/time scale text

struct ChartLook { long bg, fg, up, down, bull, bear, line, bid, ask, grid, oneClick; };
ChartLook g_savedLook;
bool      g_lookSaved = false;
bool      g_designOn  = false;

void SaveChartLook()
{
   g_savedLook.bg       = ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   g_savedLook.fg       = ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   g_savedLook.up       = ChartGetInteger(0, CHART_COLOR_CHART_UP);
   g_savedLook.down     = ChartGetInteger(0, CHART_COLOR_CHART_DOWN);
   g_savedLook.bull     = ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
   g_savedLook.bear     = ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
   g_savedLook.line     = ChartGetInteger(0, CHART_COLOR_CHART_LINE);
   g_savedLook.bid      = ChartGetInteger(0, CHART_COLOR_BID);
   g_savedLook.ask      = ChartGetInteger(0, CHART_COLOR_ASK);
   g_savedLook.grid     = ChartGetInteger(0, CHART_SHOW_GRID);
   g_savedLook.oneClick = ChartGetInteger(0, CHART_SHOW_ONE_CLICK);
   g_lookSaved = true;
}

void RestoreChartLook()
{
   if(!g_lookSaved) return;
   ChartSetInteger(0, CHART_COLOR_BACKGROUND,  g_savedLook.bg);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND,  g_savedLook.fg);
   ChartSetInteger(0, CHART_COLOR_CHART_UP,    g_savedLook.up);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN,  g_savedLook.down);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, g_savedLook.bull);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, g_savedLook.bear);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE,  g_savedLook.line);
   ChartSetInteger(0, CHART_COLOR_BID,         g_savedLook.bid);
   ChartSetInteger(0, CHART_COLOR_ASK,         g_savedLook.ask);
   ChartSetInteger(0, CHART_SHOW_GRID,         g_savedLook.grid);
   ChartSetInteger(0, CHART_SHOW_ONE_CLICK,    g_savedLook.oneClick);
}

void ApplyChartDesign()
{
   g_designOn = InpChartDesign;
   if(!g_designOn) return;
   if(!g_lookSaved) SaveChartLook();
   ChartSetInteger(0, CHART_COLOR_BACKGROUND,  DESIGN_BG);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND,  DESIGN_TEXT);
   ChartSetInteger(0, CHART_SHOW_GRID,         false);
   ChartSetInteger(0, CHART_COLOR_CHART_UP,    DESIGN_BUY);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, DESIGN_BUY);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN,  DESIGN_SELL);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, DESIGN_SELL);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE,  DESIGN_TEXT);
   ChartSetInteger(0, CHART_COLOR_ASK,         DESIGN_BUY);
   ChartSetInteger(0, CHART_COLOR_BID,         DESIGN_SELL);
   ChartSetInteger(0, CHART_SHOW_ONE_CLICK,    false);
   ChartRedraw(0);
}

void RemoveChartDesign(const int reason)
{
   if(!g_designOn) return;
   if(reason == REASON_REMOVE) RestoreChartLook();   // indicator taken off -> original colours back
}

//+------------------------------------------------------------------+
int OnInit()
{
   if(InpFastEMA < 1 || InpSlowEMA <= InpFastEMA || InpATRPeriod < 1 || InpSlopeBars < 1 ||
      InpRiskPercent <= 0 || InpRiskPercent > 100 || InpStopATRMult <= 0)
   {
      Print("AlgoFX: invalid inputs (Slow EMA must be > Fast EMA, risk 0-100%).");
      return INIT_PARAMETERS_INCORRECT;
   }

   SetIndexBuffer(0, BufFast, INDICATOR_DATA);
   SetIndexBuffer(1, BufSlow, INDICATOR_DATA);
   SetIndexBuffer(2, BufBuy,  INDICATOR_DATA);
   SetIndexBuffer(3, BufSell, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT,  15);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -15);
   for(int p = 0; p < 4; p++) PlotIndexSetDouble(p, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   hFast = iMA(_Symbol, _Period, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE);
   hSlow = iMA(_Symbol, _Period, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE);
   hATR  = iATR(_Symbol, _Period, InpATRPeriod);
   hRSI  = iRSI(_Symbol, _Period, InpRSIPeriod, PRICE_CLOSE);
   if(hFast == INVALID_HANDLE || hSlow == INVALID_HANDLE || hATR == INVALID_HANDLE || hRSI == INVALID_HANDLE)
   {
      Print("AlgoFX: failed to create indicator handles, error ", GetLastError());
      return INIT_FAILED;
   }

   ApplyChartDesign();
   IndicatorSetString(INDICATOR_SHORTNAME, "AlgoFX");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, PFX);
   RemoveChartDesign(reason);
   if(hFast != INVALID_HANDLE) IndicatorRelease(hFast);
   if(hSlow != INVALID_HANDLE) IndicatorRelease(hSlow);
   if(hATR  != INVALID_HANDLE) IndicatorRelease(hATR);
   if(hRSI  != INVALID_HANDLE) IndicatorRelease(hRSI);
   ChartRedraw();
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   int minBars = InpSlowEMA + InpSlopeBars + 2;
   if(rates_total < minBars) return 0;

   // all indicator data must be ready before we trust it
   if(BarsCalculated(hFast) < rates_total || BarsCalculated(hSlow) < rates_total ||
      BarsCalculated(hATR)  < rates_total || BarsCalculated(hRSI)  < rates_total)
      return prev_calculated;

   ArraySetAsSeries(BufFast, false); ArraySetAsSeries(BufSlow, false);
   ArraySetAsSeries(BufBuy,  false); ArraySetAsSeries(BufSell, false);
   ArraySetAsSeries(atrArr,  false); ArraySetAsSeries(rsiArr,  false);

   if(CopyBuffer(hFast, 0, 0, rates_total, BufFast) != rates_total) return prev_calculated;
   if(CopyBuffer(hSlow, 0, 0, rates_total, BufSlow) != rates_total) return prev_calculated;
   if(CopyBuffer(hATR,  0, 0, rates_total, atrArr)  != rates_total) return prev_calculated;
   if(CopyBuffer(hRSI,  0, 0, rates_total, rsiArr)  != rates_total) return prev_calculated;

   int firstValid = MathMax(minBars, rates_total - InpHistoryBars);
   int start;
   if(prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ObjectsDeleteAll(0, PFX + "Z");
      for(int k = 0; k < rates_total; k++) { BufBuy[k] = EMPTY_VALUE; BufSell[k] = EMPTY_VALUE; }
      start = firstValid;
   }
   else
      start = MathMax(prev_calculated - 2, firstValid);

   int lastClosed = rates_total - 2;          // the forming bar is never evaluated
   BufBuy[rates_total - 1]  = EMPTY_VALUE;
   BufSell[rates_total - 1] = EMPTY_VALUE;

   for(int i = start; i <= lastClosed; i++)
   {
      BufBuy[i]  = EMPTY_VALUE;
      BufSell[i] = EMPTY_VALUE;

      double atr = atrArr[i];
      if(atr <= 0) continue;

      bool upTrend   = BufFast[i] > BufSlow[i] && BufSlow[i] > BufSlow[i - InpSlopeBars] && close[i] > BufSlow[i];
      bool downTrend = BufFast[i] < BufSlow[i] && BufSlow[i] < BufSlow[i - InpSlopeBars] && close[i] < BufSlow[i];

      // BUY zone: uptrend pullback into fast EMA band, bar closes bullish and back above the band floor
      if(upTrend)
      {
         double zTop = BufFast[i];
         double zBot = BufFast[i] - InpZoneDepthATR * atr;
         bool touched = low[i] <= zTop && low[i] >= zBot - 0.5 * atr;
         bool held    = close[i] > open[i] && close[i] > zBot;
         bool rsiOk   = !InpUseRSIFilter || rsiArr[i] < InpRSIUpper;
         if(touched && held && rsiOk && !RecentSignal(BufBuy, i))
         {
            BufBuy[i] = low[i];
            DrawZone(true, time, i, rates_total, zTop, zBot);
         }
      }
      // SELL zone: mirror
      else if(downTrend)
      {
         double zBot = BufFast[i];
         double zTop = BufFast[i] + InpZoneDepthATR * atr;
         bool touched = high[i] >= zBot && high[i] <= zTop + 0.5 * atr;
         bool held    = close[i] < open[i] && close[i] < zTop;
         bool rsiOk   = !InpUseRSIFilter || rsiArr[i] > InpRSILower;
         if(touched && held && rsiOk && !RecentSignal(BufSell, i))
         {
            BufSell[i] = high[i];
            DrawZone(false, time, i, rates_total, zTop, zBot);
         }
      }
   }

   // alert once, only for a zone on the bar that just closed (not on history load)
   if(prev_calculated > 0 && time[lastClosed] != g_lastAlertBar)
   {
      if(BufBuy[lastClosed] != EMPTY_VALUE)  SendAlert("Potential BUY zone", time[lastClosed]);
      if(BufSell[lastClosed] != EMPTY_VALUE) SendAlert("Potential SELL zone", time[lastClosed]);
   }

   if(InpShowPanel)
   {
      int trend = 0;
      if(BufFast[lastClosed] > BufSlow[lastClosed] && BufSlow[lastClosed] > BufSlow[lastClosed - InpSlopeBars]) trend = 1;
      else if(BufFast[lastClosed] < BufSlow[lastClosed] && BufSlow[lastClosed] < BufSlow[lastClosed - InpSlopeBars]) trend = -1;
      UpdatePanel(trend, atrArr[lastClosed]);
   }
   return rates_total;
}

//+------------------------------------------------------------------+
bool RecentSignal(const double &buf[], const int i)
{
   int from = MathMax(0, i - InpCooldownBars);
   for(int k = i - 1; k >= from; k--)
      if(buf[k] != EMPTY_VALUE) return true;
   return false;
}

//+------------------------------------------------------------------+
void DrawZone(const bool isBuy, const datetime &time[], const int i, const int rates_total,
              const double top, const double bot)
{
   string id = PFX + "Z" + (isBuy ? "B" : "S") + IntegerToString((long)time[i]);
   int endIdx = MathMin(i + InpZoneLengthBars, rates_total - 1);
   datetime t2 = time[endIdx] + (datetime)PeriodSeconds() * MathMax(0, i + InpZoneLengthBars - endIdx);

   if(InpShowZoneBoxes && ObjectFind(0, id) < 0)
   {
      ObjectCreate(0, id, OBJ_RECTANGLE, 0, time[i], top, t2, bot);
      ObjectSetInteger(0, id, OBJPROP_COLOR, isBuy ? InpBuyZoneColor : InpSellZoneColor);
      ObjectSetInteger(0, id, OBJPROP_FILL, true);
      ObjectSetInteger(0, id, OBJPROP_BACK, true);
      ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, id, OBJPROP_HIDDEN, true);
   }
   string tid = id + "_T";
   if(InpShowLabels && ObjectFind(0, tid) < 0)
   {
      ObjectCreate(0, tid, OBJ_TEXT, 0, time[i], isBuy ? bot : top);
      ObjectSetString(0, tid, OBJPROP_TEXT, isBuy ? "Potential BUY zone" : "Potential SELL zone");
      ObjectSetInteger(0, tid, OBJPROP_COLOR, isBuy ? clrLimeGreen : clrTomato);
      ObjectSetInteger(0, tid, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, tid, OBJPROP_ANCHOR, isBuy ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, tid, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, tid, OBJPROP_HIDDEN, true);
   }
}

//+------------------------------------------------------------------+
void SendAlert(const string what, const datetime barTime)
{
   g_lastAlertBar = barTime;
   string msg = StringFormat("AlgoFX: %s on %s %s", what, _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period));
   if(InpPopupAlert) Alert(msg);
   if(InpPushAlert)  SendNotification(msg);
}

//+------------------------------------------------------------------+
//| Lot for a given risk in money and stop distance in price         |
//+------------------------------------------------------------------+
double CalcLot(const double riskMoney, const double stopDist)
{
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValue <= 0) tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = MathMin(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX), InpMaxLot);
   if(tickSize <= 0 || tickValue <= 0 || step <= 0 || stopDist <= 0 || riskMoney <= 0) return 0.0;

   double lossPerLot = stopDist / tickSize * tickValue;
   double lot = MathFloor(riskMoney / lossPerLot / step) * step;   // round DOWN: never exceed risk
   if(lot < minLot) return 0.0;                                      // risk too small for min lot
   return MathMin(lot, maxLot);
}

//+------------------------------------------------------------------+
//| Closed P/L today (all symbols) for the daily loss guard           |
//+------------------------------------------------------------------+
double ClosedProfitToday()
{
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime dayStart = StructToTime(dt);
   if(!HistorySelect(dayStart, TimeCurrent() + 60)) return 0.0;

   double sum = 0.0;
   int n = HistoryDealsTotal();
   for(int k = 0; k < n; k++)
   {
      ulong tk = HistoryDealGetTicket(k);
      if(tk == 0) continue;
      long type = HistoryDealGetInteger(tk, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;   // skip deposits etc.
      sum += HistoryDealGetDouble(tk, DEAL_PROFIT) + HistoryDealGetDouble(tk, DEAL_SWAP)
           + HistoryDealGetDouble(tk, DEAL_COMMISSION) + HistoryDealGetDouble(tk, DEAL_FEE);
   }
   return sum;
}

//+------------------------------------------------------------------+
void UpdatePanel(const int trend, const double atr)
{
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   = AccountInfoDouble(ACCOUNT_EQUITY);
   double base     = InpUseEquity ? equity : balance;
   string ccy      = AccountInfoString(ACCOUNT_CURRENCY);

   double riskMoney = base * InpRiskPercent / 100.0;
   double stopDist  = InpStopATRMult * atr;
   double lot       = CalcLot(riskMoney, stopDist);

   double closedToday = ClosedProfitToday();
   double dayStartBal = balance - closedToday;
   double dayPL       = closedToday + AccountInfoDouble(ACCOUNT_PROFIT);
   double dayPLPct    = dayStartBal > 0 ? dayPL / dayStartBal * 100.0 : 0.0;
   bool   limitHit    = InpMaxDailyLoss > 0 && dayPLPct <= -InpMaxDailyLoss;

   string trendTxt = trend > 0 ? "UPTREND - look for BUY zones" : trend < 0 ? "DOWNTREND - look for SELL zones" : "NO CLEAR TREND - stay patient";
   color  trendClr = trend > 0 ? clrLimeGreen : trend < 0 ? clrTomato : clrSilver;
   int    pts      = (int)MathRound(stopDist / _Point);

   string lines[8]; color clrs[8];
   lines[0] = "AlgoFX  |  " + _Symbol + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7); clrs[0] = clrGold;
   lines[1] = "Trend: " + trendTxt;                                                     clrs[1] = trendClr;
   lines[2] = StringFormat("%s: %.2f %s", InpUseEquity ? "Equity" : "Balance", base, ccy); clrs[2] = clrWhite;
   lines[3] = StringFormat("Risk per trade: %.2f%% = %.2f %s", InpRiskPercent, riskMoney, ccy); clrs[3] = clrWhite;
   lines[4] = StringFormat("Stop used for sizing: %.1f x ATR (%d pts)", InpStopATRMult, pts);   clrs[4] = clrWhite;
   lines[5] = lot > 0 ? StringFormat("Suggested lot: %.2f", lot) : "Suggested lot: risk below min lot"; clrs[5] = clrAqua;
   lines[6] = StringFormat("Today P/L: %.2f %s (%.2f%%)  limit -%.1f%%", dayPL, ccy, dayPLPct, InpMaxDailyLoss); clrs[6] = dayPL >= 0 ? clrLimeGreen : clrOrange;
   lines[7] = limitHit ? "DAILY LOSS LIMIT REACHED - no new trades today" : "Daily risk OK";   clrs[7] = limitHit ? clrRed : clrLimeGreen;

   int lineH = InpFontSize * 2 + 2;
   string bg = PFX + "P_BG";
   if(ObjectFind(0, bg) < 0)
   {
      ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'34,37,54');   // a shade lighter than the chart background
      ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg, OBJPROP_COLOR, clrGold);
      ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);
   }
   ObjectSetInteger(0, bg, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, InpPanelX);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, InpPanelY);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, InpFontSize * 36);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, lineH * 8 + 10);

   for(int k = 0; k < 8; k++)
   {
      string nm = PFX + "P_L" + IntegerToString(k);
      if(ObjectFind(0, nm) < 0)
      {
         ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
         ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
         ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, nm, OBJPROP_HIDDEN, true);
      }
      bool right = (InpPanelCorner == CORNER_RIGHT_UPPER || InpPanelCorner == CORNER_RIGHT_LOWER);
      bool lower = (InpPanelCorner == CORNER_LEFT_LOWER  || InpPanelCorner == CORNER_RIGHT_LOWER);
      ObjectSetInteger(0, nm, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, nm, OBJPROP_ANCHOR, right ? (lower ? ANCHOR_RIGHT_LOWER : ANCHOR_RIGHT_UPPER)
                                                    : (lower ? ANCHOR_LEFT_LOWER  : ANCHOR_LEFT_UPPER));
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, InpPanelX + 8);
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, lower ? InpPanelY + 6 + (7 - k) * lineH : InpPanelY + 6 + k * lineH);
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, clrs[k]);
      ObjectSetString(0, nm, OBJPROP_TEXT, lines[k]);
   }
}
//+------------------------------------------------------------------+
