//+------------------------------------------------------------------+
//|                                               TradeExcursion.mq5  |
//|  Draws, for every closed trade on this chart's symbol, how far it  |
//|  went in your favour before it closed, and how far against you     |
//|  before it worked.                                                 |
//|                                                                    |
//|  Your statement tells you what you KEPT. It does not tell you what |
//|  you HAD. The gap between those two numbers is where two very      |
//|  common problems hide, and neither is visible in a balance curve:  |
//|                                                                    |
//|    - winners closing far below their best unrealised profit        |
//|      -> the exit leaves money on the table                         |
//|    - losers whose worst excursion barely exceeded the stop         |
//|      -> the stop sits inside the noise, and the trade was right    |
//|                                                                    |
//|  For each trade the indicator draws a vertical span from the worst |
//|  point it reached to the best point it reached, an arrow at the    |
//|  entry, and a line at the exit. The panel summarises the whole set. |
//|                                                                    |
//|  THE NUMBER TO LOOK AT is the capture ratio: of the profit a       |
//|  winning trade showed at its best, how much did you actually take  |
//|  home? A median of 90% says the exits are well placed. A median of |
//|  30% says the market kept offering and the exit kept refusing.     |
//|                                                                    |
//|  MEASUREMENT LIMIT, STATED UP FRONT: excursions come from the high |
//|  and low of the bars the trade spanned, on the timeframe you run   |
//|  this on. The path inside a bar is unknown. Run it fine enough for |
//|  your holding period - the panel reports the median number of bars |
//|  per trade so you can see when the resolution is too coarse.       |
//|                                                                    |
//|  This indicator predicts nothing. It measures trades that already  |
//|  happened, on your own account.                                    |
//+------------------------------------------------------------------+
#property copyright "Joao Prata Silva Yglesias"
#property link      "https://www.mql5.com/en/users/jotayglesias"
#property version   "1.00"
#property description "Maximum Favourable and Adverse Excursion of your own closed trades,"
#property description "drawn on the chart. Shows how much of each winner you actually kept"
#property description "and how close each loser came to working. Measures, does not predict."

#property indicator_chart_window
#property indicator_plots 0

#include "TradeExcursion.mqh"

input int    InpDias       = 90;                 // Days of history to read
input bool   InpSoEsteAtivo = true;              // This chart's symbol only
input color  InpCorGanho   = clrSeaGreen;        // Winners
input color  InpCorPerda   = clrIndianRed;       // Losers
input color  InpCorMFE     = clrSilver;          // Excursion span
input int    InpLarguraSpan = 1;                 // Span line width
input bool   InpMostrarPainel = true;            // Summary panel
input int    InpPainelX    = 12;                 // Panel X
input int    InpPainelY    = 24;                 // Panel Y

#define PREFIXO "TrEx_"

//+------------------------------------------------------------------+
void LimpaObjetos()
  {
   ObjectsDeleteAll(0, PREFIXO);
  }

//+------------------------------------------------------------------+
void Rotulo(const string nome, const int x, const int y, const string texto,
            const color cor, const int tamanho = 8)
  {
   string id = PREFIXO + nome;
   if(ObjectFind(0, id) < 0)
      ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, id, OBJPROP_COLOR, cor);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, tamanho);
   ObjectSetInteger(0, id, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, id, OBJPROP_BACK, false);
   ObjectSetString(0, id, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, id, OBJPROP_TEXT, texto);
  }

//+------------------------------------------------------------------+
//| One trade: the span it travelled, where it opened, where it closed.|
//+------------------------------------------------------------------+
void DesenhaTrade(const int idx, const TradeInfo &t)
  {
   if(!t.measured) return;

   double point = SymbolInfoDouble(t.symbol, SYMBOL_POINT);
   if(point <= 0) point = _Point;

   double melhor = t.isBuy ? t.openPrice + t.mfePoints * point
                           : t.openPrice - t.mfePoints * point;
   double pior   = t.isBuy ? t.openPrice - t.maePoints * point
                           : t.openPrice + t.maePoints * point;

   // O intervalo percorrido, do pior ao melhor ponto, no instante da entrada.
   string sid = StringFormat("%sspan_%d", PREFIXO, idx);
   if(ObjectCreate(0, sid, OBJ_TREND, 0, t.openTime, pior, t.openTime, melhor))
     {
      ObjectSetInteger(0, sid, OBJPROP_COLOR, InpCorMFE);
      ObjectSetInteger(0, sid, OBJPROP_WIDTH, InpLarguraSpan);
      ObjectSetInteger(0, sid, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, sid, OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0, sid, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, sid, OBJPROP_BACK, true);
     }

   color cor = (t.profit >= 0) ? InpCorGanho : InpCorPerda;

   string aid = StringFormat("%sent_%d", PREFIXO, idx);
   if(ObjectCreate(0, aid, OBJ_ARROW, 0, t.openTime, t.openPrice))
     {
      ObjectSetInteger(0, aid, OBJPROP_ARROWCODE, t.isBuy ? 233 : 234);
      ObjectSetInteger(0, aid, OBJPROP_COLOR, cor);
      ObjectSetInteger(0, aid, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, aid, OBJPROP_SELECTABLE, false);
      double captura = (t.mfePoints > 0) ? 100.0 * t.resultPoints / t.mfePoints : 0.0;
      ObjectSetString(0, aid, OBJPROP_TOOLTIP, StringFormat(
         "%s %.2f\nresult %+.0f pts (%.2f)\nMFE %.0f  MAE %.0f\ncapture %.0f%%  bars %d",
         t.isBuy ? "buy" : "sell", t.volume, t.resultPoints, t.profit,
         t.mfePoints, t.maePoints, captura, t.bars));
     }

   string xid = StringFormat("%sexit_%d", PREFIXO, idx);
   if(ObjectCreate(0, xid, OBJ_TREND, 0, t.openTime, t.closePrice,
                   t.closeTime, t.closePrice))
     {
      ObjectSetInteger(0, xid, OBJPROP_COLOR, cor);
      ObjectSetInteger(0, xid, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, xid, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, xid, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, xid, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, xid, OBJPROP_BACK, true);
     }
  }

//+------------------------------------------------------------------+
//| The panel. Medians, not averages: one trade that ran 4000 points   |
//| would drag an average somewhere no typical trade ever goes.        |
//+------------------------------------------------------------------+
void DesenhaPainel(const TradeInfo &t[])
  {
   int n = ArraySize(t);
   double capt[], mfeG[], maeP[], maeG[], barras[];
   int nG = 0, nP = 0, semMedida = 0;
   double somaP = 0;

   for(int i = 0; i < n; i++)
     {
      if(!t[i].measured) { semMedida++; continue; }
      somaP += t[i].profit;
      int b = ArraySize(barras); ArrayResize(barras, b + 1); barras[b] = t[i].bars;

      if(t[i].profit >= 0)
        {
         nG++;
         int k = ArraySize(mfeG); ArrayResize(mfeG, k + 1); mfeG[k] = t[i].mfePoints;
         int m = ArraySize(maeG); ArrayResize(maeG, m + 1); maeG[m] = t[i].maePoints;
         if(t[i].mfePoints > 0)
           {
            int c = ArraySize(capt); ArrayResize(capt, c + 1);
            capt[c] = 100.0 * t[i].resultPoints / t[i].mfePoints;
           }
        }
      else
        {
         nP++;
         int k = ArraySize(maeP); ArrayResize(maeP, k + 1); maeP[k] = t[i].maePoints;
        }
     }

   int y = InpPainelY;
   int dy = 15;
   color neutro = clrDimGray, forte = clrBlack;
   if((color)ChartGetInteger(0, CHART_COLOR_BACKGROUND) == clrBlack ||
      ChartGetInteger(0, CHART_COLOR_FOREGROUND) == clrWhite)
     { neutro = clrDarkGray; forte = clrWhiteSmoke; }

   Rotulo("t0", InpPainelX, y, "TRADE EXCURSION", forte, 9); y += dy + 3;
   Rotulo("t1", InpPainelX, y, StringFormat("%d trades  %d won  %d lost",
          n - semMedida, nG, nP), neutro); y += dy;
   Rotulo("t2", InpPainelX, y, StringFormat("net %.2f %s", somaP,
          AccountInfoString(ACCOUNT_CURRENCY)), neutro); y += dy + 4;

   if(nG > 0)
     {
      Rotulo("t3", InpPainelX, y, StringFormat("winners  MFE med %.0f pts",
             Median(mfeG)), InpCorGanho); y += dy;
      double c = Median(capt);
      Rotulo("t4", InpPainelX, y, StringFormat("         capture  %.0f%%", c),
             InpCorGanho); y += dy;
      Rotulo("t5", InpPainelX, y, StringFormat("         MAE med  %.0f pts",
             Median(maeG)), neutro); y += dy + 4;
     }
   if(nP > 0)
     {
      Rotulo("t6", InpPainelX, y, StringFormat("losers   MAE med %.0f pts",
             Median(maeP)), InpCorPerda); y += dy + 4;
     }

   Rotulo("t7", InpPainelX, y, StringFormat("bars/trade med %.0f on %s",
          Median(barras), EnumToString((ENUM_TIMEFRAMES)_Period)), neutro); y += dy;
   if(semMedida > 0)
      Rotulo("t8", InpPainelX, y, StringFormat("%d not measured (no history)",
             semMedida), InpCorPerda);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("Trade Excursion (%d days)", InpDias));
   if(InpDias < 1)
     {
      Print("TradeExcursion: days of history must be 1 or greater.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   LimpaObjetos();

   TradeInfo trades[];
   datetime ate = TimeCurrent() + 86400;
   datetime de  = ate - (datetime)InpDias * 86400;
   int n = CollectTrades(de, ate, InpSoEsteAtivo ? _Symbol : "",
                         (ENUM_TIMEFRAMES)_Period, trades);

   if(n == 0)
     {
      Rotulo("t0", InpPainelX, InpPainelY,
             "TRADE EXCURSION: no closed trades in the window", clrDimGray, 9);
      Print("TradeExcursion: no closed trades found in the last ", InpDias,
            " days", InpSoEsteAtivo ? " for " + _Symbol : "");
      return(INIT_SUCCEEDED);
     }

   for(int i = 0; i < n; i++) DesenhaTrade(i, trades[i]);
   if(InpMostrarPainel) DesenhaPainel(trades);
   ChartRedraw(0);
   Print("TradeExcursion: ", n, " closed trade(s) drawn.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason) { LimpaObjetos(); }

//+------------------------------------------------------------------+
//| Nothing is recomputed on ticks. The history only changes when a    |
//| trade closes, and redrawing hundreds of objects on every tick      |
//| would cost far more than it is worth. Reattach to refresh.         |
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
