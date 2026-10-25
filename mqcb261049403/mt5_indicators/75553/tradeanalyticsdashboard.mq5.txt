//+------------------------------------------------------------------+
//|                                      TradeAnalyticsDashboard.mq5 |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Adeolu Gbadebo"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <Canvas\Canvas.mqh>

//--- inputs -----------------------------------------------------------------
input group "=== Panel ==="
input ENUM_BASE_CORNER InpCorner        = CORNER_LEFT_UPPER; // Panel corner
input int              InpOffsetX       = 12;                // X offset (pixels)
input int              InpOffsetY       = 18;                // Y offset (pixels)
input int              InpPanelWidth    = 300;                // Panel width (pixels)
input int              InpPanelHeight   = 250;                // Panel height (pixels)
input int              InpRefreshSecs   = 5;                  // Refresh interval (seconds)

input group "=== Data Scope ==="
input int              InpHistoryDays   = 90;                 // Lookback window, days
input bool             InpAllSymbols    = true;                // Include every symbol (false = current chart symbol only)

input group "=== Colors ==="
input color            InpBackColor     = C'12,18,32';   // Panel background (ink)
input color            InpBorderColor   = C'242,169,59';  // Panel border (amber)
input color            InpTextColor     = C'237,239,245'; // Primary text (off-white)
input color            InpAccentColor   = C'242,169,59';  // Accent (amber)
input color            InpProfitColor   = C'62,142,222';  // Equity curve up (cyan)
input color            InpLossColor     = C'198,40,40';   // Equity curve down (red)

//--- globals ------------------------------------------------------------------
CCanvas g_canvas;
string  g_panelName = "TAD_Panel";
bool    g_canvasReady = false;

struct DashboardStats
  {
   int    totalTrades;
   int    wins;
   int    losses;
   double grossProfit;
   double grossLoss;
   double netProfit;
   int    currentStreak;     // positive = winning streak, negative = losing streak
   string bestSymbol;
   double bestSymbolProfit;
   string worstSymbol;
   double worstSymbolProfit;
   double equityCurve[];     // cumulative net profit, oldest to newest
  };

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!g_canvas.CreateBitmapLabel(g_panelName, InpOffsetX, InpOffsetY,
                                   InpPanelWidth, InpPanelHeight,
                                   COLOR_FORMAT_ARGB_NORMALIZE))
     {
      Print("TradeAnalyticsDashboard: failed to create canvas, error ", GetLastError());
      return(INIT_FAILED);
     }

   ObjectSetInteger(0, g_panelName, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(0, g_panelName, OBJPROP_XDISTANCE, InpOffsetX);
   ObjectSetInteger(0, g_panelName, OBJPROP_YDISTANCE, InpOffsetY);
   ObjectSetInteger(0, g_panelName, OBJPROP_BACK, false);
   ObjectSetInteger(0, g_panelName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, g_panelName, OBJPROP_HIDDEN, true);

   g_canvasReady = true;

   EventSetTimer(MathMax(1, InpRefreshSecs));
   RefreshDashboard();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_canvasReady)
      g_canvas.Destroy();
   ObjectDelete(0, g_panelName);
  }

//+------------------------------------------------------------------+
//| Timer — periodic refresh independent of ticks                     |
//+------------------------------------------------------------------+
void OnTimer()
  {
   RefreshDashboard();
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                 const double &open[], const double &high[], const double &low[], const double &close[],
                 const long &tick_volume[], const long &volume[], const int &spread[])
  {
   //--- refresh once per new bar as well, in case the timer misses a fast market
   static datetime lastBar = 0;
   if(rates_total > 0 && time[rates_total - 1] != lastBar)
     {
      lastBar = time[rates_total - 1];
      RefreshDashboard();
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Pulls closed-deal history and rebuilds the stats struct            |
//+------------------------------------------------------------------+
bool BuildStats(DashboardStats &stats)
  {
   ZeroMemory(stats);
   ArrayResize(stats.equityCurve, 0);
   stats.bestSymbol  = "-";
   stats.worstSymbol = "-";

   datetime fromDate = TimeCurrent() - (InpHistoryDays * 86400);
   if(!HistorySelect(fromDate, TimeCurrent()))
      return(false);

   int total = HistoryDealsTotal();
   if(total <= 0)
      return(true); // nothing traded yet in this window, not an error

   //--- aggregate per-symbol P/L for the best/worst summary
   string symbols[];
   double symbolPL[];

   double cumulative = 0.0;
   int    streak = 0;
   int    lastSign = 0;

   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;

      long entryType = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entryType != DEAL_ENTRY_OUT && entryType != DEAL_ENTRY_INOUT)
         continue; // only count deals that actually closed a position

      string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
      if(!InpAllSymbols && symbol != _Symbol)
         continue;

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                     + HistoryDealGetDouble(ticket, DEAL_SWAP)
                     + HistoryDealGetDouble(ticket, DEAL_COMMISSION);

      stats.totalTrades++;
      if(profit >= 0.0)
        {
         stats.wins++;
         stats.grossProfit += profit;
        }
      else
        {
         stats.losses++;
         stats.grossLoss += MathAbs(profit);
        }
      stats.netProfit += profit;

      //--- running win/loss streak (based on chronological order of deals)
      int sign = (profit >= 0.0) ? 1 : -1;
      if(sign == lastSign)
         streak += sign;
      else
         streak = sign;
      lastSign = sign;

      //--- per-symbol aggregation
      int idx = -1;
      for(int s = 0; s < ArraySize(symbols); s++)
         if(symbols[s] == symbol)
           {
            idx = s;
            break;
           }
      if(idx == -1)
        {
         idx = ArraySize(symbols);
         ArrayResize(symbols, idx + 1);
         ArrayResize(symbolPL, idx + 1);
         symbols[idx]  = symbol;
         symbolPL[idx] = 0.0;
        }
      symbolPL[idx] += profit;

      //--- equity curve sample
      cumulative += profit;
      int ePos = ArraySize(stats.equityCurve);
      ArrayResize(stats.equityCurve, ePos + 1);
      stats.equityCurve[ePos] = cumulative;
     }

   stats.currentStreak = streak;

   double bestPL = -DBL_MAX, worstPL = DBL_MAX;
   for(int s = 0; s < ArraySize(symbols); s++)
     {
      if(symbolPL[s] > bestPL)
        {
         bestPL = symbolPL[s];
         stats.bestSymbol = symbols[s];
         stats.bestSymbolProfit = symbolPL[s];
        }
      if(symbolPL[s] < worstPL)
        {
         worstPL = symbolPL[s];
         stats.worstSymbol = symbols[s];
         stats.worstSymbolProfit = symbolPL[s];
        }
     }

   return(true);
  }

//+------------------------------------------------------------------+
//| Redraws the whole panel from a fresh stats snapshot                |
//+------------------------------------------------------------------+
void RefreshDashboard()
  {
   if(!g_canvasReady)
      return;

   DashboardStats stats;
   if(!BuildStats(stats))
      return;

   g_canvas.Erase(ColorToARGB(InpBackColor, 235));
   g_canvas.FillRectangle(0, 0, InpPanelWidth - 1, InpPanelHeight - 1, ColorToARGB(InpBackColor, 235));
   DrawBorder();

   int x = 14;
   int y = 12;
   int lineHeight = 18;

   DrawText(x, y, "TRADE ANALYTICS", InpAccentColor, 11, true);
   y += lineHeight + 4;

   double winRate = (stats.totalTrades > 0) ? (100.0 * stats.wins / stats.totalTrades) : 0.0;
   double profitFactor = (stats.grossLoss > 0.0) ? (stats.grossProfit / stats.grossLoss) : 0.0;

   DrawStatLine(x, y, "Trades (" + IntegerToString(InpHistoryDays) + "d)", IntegerToString(stats.totalTrades));
   y += lineHeight;
   DrawStatLine(x, y, "Win rate", DoubleToString(winRate, 1) + "%");
   y += lineHeight;
   DrawStatLine(x, y, "Profit factor", DoubleToString(profitFactor, 2));
   y += lineHeight;

   color netColor = (stats.netProfit >= 0.0) ? InpProfitColor : InpLossColor;
   DrawStatLine(x, y, "Net P/L", DoubleToString(stats.netProfit, 2), netColor);
   y += lineHeight;

   string streakLabel = (stats.currentStreak >= 0) ? "Win streak" : "Loss streak";
   color  streakColor = (stats.currentStreak >= 0) ? InpProfitColor : InpLossColor;
   DrawStatLine(x, y, streakLabel, IntegerToString((int)MathAbs(stats.currentStreak)), streakColor);
   y += lineHeight;

   DrawStatLine(x, y, "Best symbol", stats.bestSymbol + "  (" + DoubleToString(stats.bestSymbolProfit, 2) + ")");
   y += lineHeight;
   DrawStatLine(x, y, "Worst symbol", stats.worstSymbol + "  (" + DoubleToString(stats.worstSymbolProfit, 2) + ")");
   y += lineHeight + 8;

   DrawEquitySparkline(x, y, InpPanelWidth - 2 * x, 60, stats.equityCurve);

   g_canvas.Update();
  }

//+------------------------------------------------------------------+
//| Helpers                                                            |
//+------------------------------------------------------------------+
void DrawBorder()
  {
   g_canvas.Rectangle(0, 0, InpPanelWidth - 1, InpPanelHeight - 1, ColorToARGB(InpBorderColor, 255));
  }

void DrawText(const int x, const int y, const string text, const color clr,
              const int fontSize = 10, const bool bold = false)
  {
   g_canvas.FontSet(bold ? "Arial Bold" : "Arial", -fontSize * 10);
   g_canvas.TextOut(x, y, text, ColorToARGB(clr, 255));
  }

void DrawStatLine(const int x, const int y, const string label, const string value, const color valueColor = clrNONE)
  {
   g_canvas.FontSet("Arial", -90);
   g_canvas.TextOut(x, y, label, ColorToARGB(InpTextColor, 190));

   color vc = (valueColor == clrNONE) ? InpTextColor : valueColor;
   g_canvas.FontSet("Arial Bold", -90);
   g_canvas.TextOut(InpPanelWidth - 14, y, value, ColorToARGB(vc, 255), TA_RIGHT);
  }

void DrawEquitySparkline(const int x, const int y, const int w, const int h, const double &curve[])
  {
   g_canvas.FontSet("Arial", -80);
   g_canvas.TextOut(x, y - 4, "Equity curve", ColorToARGB(InpTextColor, 150));

   int top = y + 12;
   g_canvas.Rectangle(x, top, x + w, top + h, ColorToARGB(InpBorderColor, 90));

   int n = ArraySize(curve);
   if(n < 2)
     {
      g_canvas.TextOut(x + 6, top + h / 2 - 6, "Not enough closed trades yet", ColorToARGB(InpTextColor, 140));
      return;
     }

   double minV = curve[0], maxV = curve[0];
   for(int i = 1; i < n; i++)
     {
      if(curve[i] < minV) minV = curve[i];
      if(curve[i] > maxV) maxV = curve[i];
     }
   double range = (maxV - minV);
   if(range <= 0.0)
      range = 1.0;

   color lineColor = (curve[n - 1] >= curve[0]) ? InpProfitColor : InpLossColor;

   int prevX = x, prevY = top + h - (int)((curve[0] - minV) / range * h);
   for(int i = 1; i < n; i++)
     {
      int px = x + (int)((double)i / (n - 1) * w);
      int py = top + h - (int)((curve[i] - minV) / range * h);
      g_canvas.Line(prevX, prevY, px, py, ColorToARGB(lineColor, 255));
      prevX = px;
      prevY = py;
     }
  }
//+------------------------------------------------------------------+