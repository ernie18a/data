//+------------------------------------------------------------------+
//|                                         TradeExcursionReport.mq5  |
//|  Writes one CSV line per closed trade, with the excursion numbers  |
//|  the statement does not carry, and prints a summary.               |
//|                                                                    |
//|  Same measurement as the TradeExcursion indicator, but written to  |
//|  a file instead of drawn - because the questions worth asking of   |
//|  this data are questions a chart cannot answer:                    |
//|                                                                    |
//|    Does the capture ratio depend on the hour of entry?             |
//|    Are the trades I close early the ones held longest?             |
//|    Do losers on Mondays reach a different MAE than on Fridays?     |
//|                                                                    |
//|  Those are one pivot table away once the CSV exists, and out of    |
//|  reach while the numbers live only on a chart.                     |
//|                                                                    |
//|  Output: MQL5\Files\<name>.csv, semicolon separated, one header    |
//|  row. Opens in any spreadsheet.                                    |
//|                                                                    |
//|  MEASUREMENT LIMIT: excursions come from the high and low of the   |
//|  bars each trade spanned, on the chosen timeframe. The path inside |
//|  a bar is unknown. The bars column tells you the resolution each   |
//|  trade actually got - a trade measured over 1 bar was not really   |
//|  measured, and the summary counts those separately instead of      |
//|  quietly averaging them in.                                        |
//+------------------------------------------------------------------+
#property copyright "Joao Prata Silva Yglesias"
#property link      "https://www.mql5.com/en/users/jotayglesias"
#property version   "1.00"
#property script_show_inputs
#property description "Exports MFE/MAE of every closed trade to CSV, with a summary in the log."

#include "TradeExcursion.mqh"

input int              InpDias     = 365;            // Days of history to read
input bool             InpSoEsteAtivo = false;       // This chart's symbol only
input ENUM_TIMEFRAMES  InpTF       = PERIOD_CURRENT; // Timeframe to measure on
input string           InpArquivo  = "trade_excursion.csv";

//+------------------------------------------------------------------+
void OnStart()
  {
   ENUM_TIMEFRAMES tf = (InpTF == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : InpTF;

   datetime ate = TimeCurrent() + 86400;
   datetime de  = ate - (datetime)InpDias * 86400;

   TradeInfo t[];
   int n = CollectTrades(de, ate, InpSoEsteAtivo ? _Symbol : "", tf, t);
   if(n == 0)
     {
      Print("TradeExcursionReport: no closed trades in the last ", InpDias, " days.");
      return;
     }

   int h = FileOpen(InpArquivo, FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
   if(h == INVALID_HANDLE)
     {
      Print("TradeExcursionReport: could not create ", InpArquivo,
            " (error ", GetLastError(), ")");
      return;
     }

   FileWrite(h, "position", "symbol", "side", "volume", "open_time", "close_time",
             "minutes_held", "bars", "open_price", "close_price",
             "result_points", "result_money", "mfe_points", "mae_points",
             "capture_pct", "mae_over_result", "measured");

   double capt[], mfeWin[], maeWin[], maeLoss[], barras[];
   int nWin = 0, nLoss = 0, semMedida = 0, umaBarra = 0;
   double soma = 0;

   for(int i = 0; i < n; i++)
     {
      double captura = (t[i].mfePoints > 0)
                       ? 100.0 * t[i].resultPoints / t[i].mfePoints : 0.0;
      double maeSobre = (MathAbs(t[i].resultPoints) > 0)
                        ? t[i].maePoints / MathAbs(t[i].resultPoints) : 0.0;

      FileWrite(h, (string)t[i].position, t[i].symbol, t[i].isBuy ? "buy" : "sell",
                DoubleToString(t[i].volume, 2),
                TimeToString(t[i].openTime, TIME_DATE | TIME_MINUTES),
                TimeToString(t[i].closeTime, TIME_DATE | TIME_MINUTES),
                (string)(int)((t[i].closeTime - t[i].openTime) / 60),
                (string)t[i].bars,
                DoubleToString(t[i].openPrice, _Digits),
                DoubleToString(t[i].closePrice, _Digits),
                DoubleToString(t[i].resultPoints, 1),
                DoubleToString(t[i].profit, 2),
                DoubleToString(t[i].mfePoints, 1),
                DoubleToString(t[i].maePoints, 1),
                DoubleToString(captura, 1),
                DoubleToString(maeSobre, 2),
                t[i].measured ? "yes" : "no");

      if(!t[i].measured) { semMedida++; continue; }
      if(t[i].bars <= 1) umaBarra++;
      soma += t[i].profit;
      int b = ArraySize(barras); ArrayResize(barras, b + 1); barras[b] = t[i].bars;

      if(t[i].profit >= 0)
        {
         nWin++;
         int k = ArraySize(mfeWin); ArrayResize(mfeWin, k + 1); mfeWin[k] = t[i].mfePoints;
         int m = ArraySize(maeWin); ArrayResize(maeWin, m + 1); maeWin[m] = t[i].maePoints;
         if(t[i].mfePoints > 0)
           { int c = ArraySize(capt); ArrayResize(capt, c + 1); capt[c] = captura; }
        }
      else
        {
         nLoss++;
         int k = ArraySize(maeLoss); ArrayResize(maeLoss, k + 1); maeLoss[k] = t[i].maePoints;
        }
     }
   FileClose(h);

   Print("========================================================");
   PrintFormat("TRADE EXCURSION  |  %d trades  |  measured on %s",
               n, EnumToString(tf));
   PrintFormat("period: %s to %s",
               TimeToString(de, TIME_DATE), TimeToString(ate, TIME_DATE));
   Print("");
   PrintFormat("  won %d   lost %d   net %.2f %s",
               nWin, nLoss, soma, AccountInfoString(ACCOUNT_CURRENCY));
   if(nWin > 0)
     {
      PrintFormat("  winners  MFE median %.0f pts   MAE median %.0f pts",
                  Median(mfeWin), Median(maeWin));
      PrintFormat("           CAPTURE median %.0f%%  <- of the profit each winner",
                  Median(capt));
      Print("                                       showed at its best, this is");
      Print("                                       how much was actually kept");
     }
   if(nLoss > 0)
      PrintFormat("  losers   MAE median %.0f pts", Median(maeLoss));
   Print("");
   PrintFormat("  bars per trade, median: %.0f", Median(barras));
   if(umaBarra > 0)
      PrintFormat("  WARNING: %d trade(s) spanned a single bar on %s - their",
                  umaBarra, EnumToString(tf));
   if(umaBarra > 0)
      Print("           excursion is the bar's own range, not a measurement.");
   if(umaBarra > 0)
      Print("           Rerun on a finer timeframe to measure those properly.");
   if(semMedida > 0)
      PrintFormat("  %d trade(s) had no history available and were not measured.",
                  semMedida);
   Print("");
   Print("  file: MQL5\\Files\\", InpArquivo);
   Print("========================================================");
  }
//+------------------------------------------------------------------+
