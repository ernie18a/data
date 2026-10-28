//+------------------------------------------------------------------+
//|                                              TradeExcursion.mqh   |
//|  Rebuilds closed trades from account history and measures how far  |
//|  each one went in your favour before it closed, and how far it     |
//|  went against you before it worked.                                |
//|                                                                    |
//|  MFE - Maximum Favourable Excursion: the best unrealised profit    |
//|        the trade ever showed.                                      |
//|  MAE - Maximum Adverse Excursion: the worst unrealised loss it     |
//|        ever showed.                                                |
//|                                                                    |
//|  WHY THESE TWO NUMBERS ARE WORTH THE TROUBLE                       |
//|                                                                    |
//|  A profit and loss statement tells you what you kept. It does not  |
//|  tell you what you had. Those are different numbers, and the gap   |
//|  between them is where two of the most common problems hide:       |
//|                                                                    |
//|    - winners closed far below their MFE  -> exits too early, or a  |
//|      target that the market routinely overshoots                   |
//|    - losers whose MAE barely exceeds the stop -> the stop is sized |
//|      just inside the noise, and the trade would have worked        |
//|                                                                    |
//|  Neither problem is visible in a balance curve. Both are obvious   |
//|  once the excursions are measured.                                 |
//|                                                                    |
//|  HONEST LIMITATION, STATED UP FRONT                                |
//|                                                                    |
//|  The excursion is measured from the HIGH and LOW of the bars the   |
//|  trade spanned, on the timeframe you run this on. The path inside  |
//|  a bar is unknown, so on a coarse timeframe the measurement is     |
//|  coarse: a trade that opened and closed inside one bar cannot be   |
//|  measured at all beyond that bar's own range.                      |
//|                                                                    |
//|  Run it on a timeframe fine enough for your holding period. If     |
//|  your trades last minutes, M1 is the honest choice; if they last   |
//|  weeks, H1 is plenty. The code reports how many bars each trade    |
//|  spanned so you can tell when the resolution is too coarse.        |
//+------------------------------------------------------------------+
//| Joao Prata Silva Yglesias                                          |
//| https://www.mql5.com/en/users/jotayglesias                         |
//+------------------------------------------------------------------+
#ifndef TRADE_EXCURSION_MQH
#define TRADE_EXCURSION_MQH

struct TradeInfo
  {
   long              position;      // position identifier
   string            symbol;
   bool              isBuy;
   datetime          openTime;
   datetime          closeTime;
   double            openPrice;     // volume weighted
   double            closePrice;    // volume weighted
   double            volume;
   double            profit;        // net: profit + commission + swap + fee
   double            resultPoints;  // signed, in points
   double            mfePoints;     // always >= 0
   double            maePoints;     // always >= 0
   int               bars;          // bars the trade spanned on the measuring TF
   bool              measured;      // false when history was not available
  };

//+------------------------------------------------------------------+
//| Rebuilds one position from its deals.                              |
//|                                                                    |
//| Entry and exit prices are VOLUME WEIGHTED, so a position built or  |
//| unwound in pieces gives the price you actually paid, not the price |
//| of whichever deal happened to be first.                            |
//+------------------------------------------------------------------+
bool BuildTrade(const long position, TradeInfo &t)
  {
   if(!HistorySelectByPosition(position)) return(false);

   double volIn = 0, volOut = 0, sumIn = 0, sumOut = 0;
   t.position = position;
   t.profit = 0;
   t.openTime = 0;
   t.closeTime = 0;
   t.symbol = "";

   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      long type = HistoryDealGetInteger(d, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;

      double vol = HistoryDealGetDouble(d, DEAL_VOLUME);
      double price = HistoryDealGetDouble(d, DEAL_PRICE);
      datetime when = (datetime)HistoryDealGetInteger(d, DEAL_TIME);
      long entry = HistoryDealGetInteger(d, DEAL_ENTRY);

      if(t.symbol == "") t.symbol = HistoryDealGetString(d, DEAL_SYMBOL);

      t.profit += HistoryDealGetDouble(d, DEAL_PROFIT)
                + HistoryDealGetDouble(d, DEAL_COMMISSION)
                + HistoryDealGetDouble(d, DEAL_SWAP)
                + HistoryDealGetDouble(d, DEAL_FEE);

      if(entry == DEAL_ENTRY_IN)
        {
         volIn += vol; sumIn += price * vol;
         if(t.openTime == 0 || when < t.openTime) t.openTime = when;
         t.isBuy = (type == DEAL_TYPE_BUY);
        }
      else if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
        {
         volOut += vol; sumOut += price * vol;
         if(when > t.closeTime) t.closeTime = when;
        }
     }

   if(volIn <= 0 || volOut <= 0) return(false);      // still open, or not a trade
   t.openPrice  = sumIn / volIn;
   t.closePrice = sumOut / volOut;
   t.volume     = volIn;

   double point = SymbolInfoDouble(t.symbol, SYMBOL_POINT);
   if(point <= 0) point = _Point;
   t.resultPoints = ((t.isBuy) ? (t.closePrice - t.openPrice)
                               : (t.openPrice - t.closePrice)) / point;
   t.mfePoints = 0;
   t.maePoints = 0;
   t.bars = 0;
   t.measured = false;
   return(true);
  }

//+------------------------------------------------------------------+
//| Measures MFE and MAE over the bars the trade spanned.              |
//|                                                                    |
//| Both are clamped at zero: a trade that never showed a profit has   |
//| MFE 0, not a negative one. Keeping them non-negative is what makes |
//| the ratios below meaningful.                                       |
//+------------------------------------------------------------------+
bool MeasureExcursion(TradeInfo &t, const ENUM_TIMEFRAMES tf)
  {
   MqlRates r[];
   int n = CopyRates(t.symbol, tf, t.openTime, t.closeTime, r);
   if(n <= 0)
     {
      // The close may fall inside the bar that is still forming, or history
      // may simply be missing. Either way: say so instead of reporting zero.
      t.measured = false;
      return(false);
     }

   double hi = r[0].high, lo = r[0].low;
   for(int i = 1; i < n; i++)
     {
      if(r[i].high > hi) hi = r[i].high;
      if(r[i].low  < lo) lo = r[i].low;
     }

   double point = SymbolInfoDouble(t.symbol, SYMBOL_POINT);
   if(point <= 0) point = _Point;

   if(t.isBuy)
     {
      t.mfePoints = MathMax(0.0, (hi - t.openPrice) / point);
      t.maePoints = MathMax(0.0, (t.openPrice - lo) / point);
     }
   else
     {
      t.mfePoints = MathMax(0.0, (t.openPrice - lo) / point);
      t.maePoints = MathMax(0.0, (hi - t.openPrice) / point);
     }
   t.bars = n;
   t.measured = true;
   return(true);
  }

//+------------------------------------------------------------------+
//| Collects every closed trade in the window, optionally for one      |
//| symbol only. Returns how many were collected.                      |
//|                                                                    |
//| Positions are identified by DEAL_POSITION_ID, which is what makes  |
//| this work on hedging accounts as well as netting ones: each        |
//| position is rebuilt from its own deals, whatever else was open at  |
//| the same time.                                                     |
//+------------------------------------------------------------------+
int CollectTrades(const datetime from, const datetime to, const string symbol,
                  const ENUM_TIMEFRAMES tf, TradeInfo &out[])
  {
   ArrayResize(out, 0);
   if(!HistorySelect(from, to)) return(0);

   long vistos[];
   int nVistos = 0;
   int total = HistoryDealsTotal();

   for(int i = 0; i < total; i++)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0) continue;
      long type = HistoryDealGetInteger(d, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;
      if(symbol != "" && HistoryDealGetString(d, DEAL_SYMBOL) != symbol) continue;

      long pos = HistoryDealGetInteger(d, DEAL_POSITION_ID);
      if(pos == 0) continue;

      bool repetido = false;
      for(int k = 0; k < nVistos; k++)
         if(vistos[k] == pos) { repetido = true; break; }
      if(repetido) continue;
      ArrayResize(vistos, nVistos + 1);
      vistos[nVistos++] = pos;

      TradeInfo t;
      if(!BuildTrade(pos, t)) continue;
      MeasureExcursion(t, tf);

      int n = ArraySize(out);
      ArrayResize(out, n + 1);
      out[n] = t;

      // BuildTrade calls HistorySelectByPosition, which replaces the current
      // selection. Restore it or the outer loop starts reading the wrong set.
      HistorySelect(from, to);
     }
   return(ArraySize(out));
  }

//+------------------------------------------------------------------+
//| Median. Sorting a copy, because the caller's order is meaningful.  |
//+------------------------------------------------------------------+
double Median(double &v[])
  {
   int n = ArraySize(v);
   if(n == 0) return(0.0);
   double c[];
   ArrayCopy(c, v);
   ArraySort(c);
   return(((n % 2) != 0) ? c[n / 2] : 0.5 * (c[n / 2 - 1] + c[n / 2]));
  }

#endif // TRADE_EXCURSION_MQH
//+------------------------------------------------------------------+
