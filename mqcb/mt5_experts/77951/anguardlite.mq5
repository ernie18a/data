//+------------------------------------------------------------------+
//|                                                  ANGuardLite.mq5 |
//|  Trade journal and report for any Expert Advisor (or manual      |
//|  trading). It does NOT open, modify or close any position.       |
//+------------------------------------------------------------------+
#property copyright "Amedeo Nustriani"
#property version   "1.01"
#property description "Journal and report for any Expert Advisor or manual trading."
#property description "It never opens, modifies or closes a position."
#property description "It writes a CSV journal of every trade with the exit reason,"
#property description "and a text report that shows how far each trade ran, in R,"
#property description "before it closed."

//--- which positions to watch
enum ENUM_WATCH_SCOPE
  {
   SCOPE_SYMBOL = 0,   // Only the symbol of this chart
   SCOPE_ALL    = 1    // All positions of the account
  };

input group "What to watch"
input ENUM_WATCH_SCOPE InpScope       = SCOPE_SYMBOL; // Scope
input long             InpOnlyMagic   = 0;            // Only this magic number (0 = all)

input group "Files"
input string           InpJournalFile = "journal";    // Journal file base name
input string           InpReportFile  = "report";     // Report file base name
input bool             InpWriteJournal = true;        // Write the CSV journal
input bool             InpAlertNoStop = true;         // Alert when a position has no stop loss

#define J_DELIM       ';'
#define J_TRADE_OPEN  "TRADE_OPEN"
#define J_TRADE_CLOSE "TRADE_CLOSE"
#define J_INFO        "INFO"

//+------------------------------------------------------------------+
//| Number of decimals needed to show a lot size of this symbol      |
//+------------------------------------------------------------------+
int LotDigits(const string symbol)
  {
   double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   int d = 0;
   while(d < 8 && MathAbs(step * MathPow(10, d) - MathRound(step * MathPow(10, d))) > 1e-9)
      d++;
   return(MathMax(d, 2));
  }

//+------------------------------------------------------------------+
//| Timeframe name without the PERIOD_ prefix (M1, H1, D1...)        |
//+------------------------------------------------------------------+
string TfName(void)
  {
   return(StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period), 7));
  }

//+------------------------------------------------------------------+
//| Human readable reason why the program stopped                    |
//+------------------------------------------------------------------+
string StopReason(const int reason)
  {
   switch(reason)
     {
      case REASON_REMOVE:      return("removed from the chart");
      case REASON_CHARTCLOSE:  return("chart closed");
      case REASON_CHARTCHANGE: return("symbol or timeframe changed");
      case REASON_PARAMETERS:  return("inputs changed");
      case REASON_RECOMPILE:   return("recompiled");
      case REASON_ACCOUNT:     return("account changed");
      case REASON_TEMPLATE:    return("template applied");
      case REASON_CLOSE:       return("terminal closed");
      case REASON_INITFAILED:  return("initialization failed");
     }
   return("code " + IntegerToString(reason));
  }

//+------------------------------------------------------------------+
//| The journal: one CSV line for every event                        |
//+------------------------------------------------------------------+
class CJournal
  {
private:
   int               m_handle;
   bool              m_enabled;
   string            m_filename;

   //--- remove everything that would break a column
   string            Clean(const string s)
     {
      string out = s;
      StringReplace(out, ";", ",");
      StringReplace(out, "\r", " ");
      StringReplace(out, "\n", " ");
      StringReplace(out, "\"", "'");
      return(out);
     }

public:
                     CJournal(void) : m_handle(INVALID_HANDLE),
                                      m_enabled(false),
                                      m_filename("") {}
                    ~CJournal(void) { Close(); }

   bool              Open(const string base, const bool enabled)
     {
      m_enabled = enabled;
      if(!m_enabled)
         return(true);

      m_filename = base + "_" + _Symbol + "_" +
                   TfName() + ".csv";

      m_handle = FileOpen(m_filename, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI |
                          FILE_SHARE_READ | FILE_SHARE_WRITE, J_DELIM);
      if(m_handle == INVALID_HANDLE)
        {
         Print("Journal: cannot open ", m_filename, " error ", GetLastError());
         m_enabled = false;
         return(false);
        }

      //--- new file: write the header. Existing file: append at the end.
      if(FileSize(m_handle) == 0)
         FileWrite(m_handle, "datetime", "symbol", "event", "side", "price",
                   "lots", "sl", "tp", "result", "reason");
      else
         FileSeek(m_handle, 0, SEEK_END);
      return(true);
     }

   void              Close(void)
     {
      if(m_handle != INVALID_HANDLE)
        {
         FileClose(m_handle);
         m_handle = INVALID_HANDLE;
        }
     }

   void              Write(const string event,
                           const string symbol,
                           const string side,
                           const double price,
                           const double lots,
                           const double sl,
                           const double tp,
                           const double result,
                           const string reason)
     {
      if(!m_enabled || m_handle == INVALID_HANDLE)
         return;

      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      FileWrite(m_handle,
                TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS),
                Clean(symbol),
                Clean(event),
                Clean(side),
                DoubleToString(price, digits),
                DoubleToString(lots, LotDigits(symbol)),
                DoubleToString(sl, digits),
                DoubleToString(tp, digits),
                DoubleToString(result, 2),
                Clean(reason));
      FileFlush(m_handle);
     }

   void              Info(const string reason)
     {
      Write(J_INFO, _Symbol, "-", 0.0, 0.0, 0.0, 0.0, 0.0, reason);
     }

   //--- a note about a specific symbol (the symbol column shows that symbol)
   void              Note(const string symbol, const string reason)
     {
      Write(J_INFO, symbol, "-", 0.0, 0.0, 0.0, 0.0, 0.0, reason);
     }
  };

//+------------------------------------------------------------------+
//| One closed trade, with what is needed to judge it                |
//+------------------------------------------------------------------+
struct TradeRec
  {
   long              posId;      // position identifier
   datetime          closed;     // when it closed
   double            net;        // net result in account currency
   double            riskPts;    // initial risk, as a price distance
   double            maxGainR;   // how far it ran, in R
   bool              hasR;       // could it be measured in R?
  };

//+------------------------------------------------------------------+
//| The report: what the journal means                               |
//+------------------------------------------------------------------+
class CReport
  {
private:
   TradeRec          m_rec[];
   CJournal         *m_journal;
   double            m_startBalance;
   string            m_ccy;

   int               Find(const long posId)
     {
      for(int i = ArraySize(m_rec) - 1; i >= 0; i--)
         if(m_rec[i].posId == posId)
            return(i);
      return(-1);
     }

   int               Add(const long posId)
     {
      int n = ArraySize(m_rec);
      ArrayResize(m_rec, n + 1);
      m_rec[n].posId    = posId;
      m_rec[n].closed   = 0;
      m_rec[n].net      = 0.0;
      m_rec[n].riskPts  = 0.0;
      m_rec[n].maxGainR = 0.0;
      m_rec[n].hasR     = false;
      return(n);
     }

   //--- right-aligned columns
   string            PadLeft(const string s, const int width = 14)
     {
      string out = s;
      while(StringLen(out) < width)
         out = " " + out;
      return(out);
     }

   string            Money(const double v, const int width = 14)
     {
      return(PadLeft((v >= 0 ? "+" : "") + DoubleToString(v, 2), width));
     }

   string            Row(const string label, const string value)
     {
      string l = "   " + label;
      while(StringLen(l) < 30)
         l += " ";
      return(l + PadLeft(value));
     }

public:
                     CReport(void) : m_journal(NULL),
                                     m_startBalance(0.0),
                                     m_ccy("")
     {
      ArrayResize(m_rec, 0);
     }

   void              Init(CJournal &journal)
     {
      m_journal      = GetPointer(journal);
      m_startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_ccy          = AccountInfoString(ACCOUNT_CURRENCY);
     }

   //--- called when a position closes
   void              OnClose(const long posId, const datetime when, const double net)
     {
      int i = Find(posId);
      if(i < 0)
         i = Add(posId);
      m_rec[i].closed = when;
      m_rec[i].net   += net;        // += because a position can close in several parts
     }

   //--- called when a position is gone: how far it ran, and with what risk
   void              OnMeasured(const long posId, const double riskPts, const double maxGainR)
     {
      int i = Find(posId);
      if(i < 0)
         i = Add(posId);
      m_rec[i].riskPts  = riskPts;
      m_rec[i].maxGainR = maxGainR;
      m_rec[i].hasR     = (riskPts > 0.0);
     }

   int               Count(void) { return(ArraySize(m_rec)); }

   //--- writes the report to a text file. Returns the net profit.
   double            Write(const string base)
     {
      int total = ArraySize(m_rec);
      if(total == 0)
         return(0.0);

      //--- sort by closing time (a handful of trades, not millions)
      for(int a = 0; a < total - 1; a++)
         for(int b = 0; b < total - 1 - a; b++)
            if(m_rec[b].closed > m_rec[b + 1].closed)
              {
               TradeRec t   = m_rec[b];
               m_rec[b]     = m_rec[b + 1];
               m_rec[b + 1] = t;
              }

      int    wins = 0, losses = 0;
      double grossWin = 0.0, grossLoss = 0.0, net = 0.0, worst = 0.0;
      int    streak = 0, worstStreak = 0;
      double equity = 0.0, peak = 0.0, maxDD = 0.0, maxDDpct = 0.0;
      int    small = 0;

      for(int i = 0; i < total; i++)
        {
         double v = m_rec[i].net;
         net += v;

         if(v > 0.0)
           {
            wins++;
            grossWin += v;
            streak = 0;
           }
         else
           {
            losses++;
            grossLoss += -v;
            streak++;
            if(streak > worstStreak)
               worstStreak = streak;
           }

         if(v < worst)
            worst = v;

         equity += v;
         if(equity > peak)
            peak = equity;
         //--- drawdown is measured from the highest point reached
         double dd = peak - equity;
         if(dd > maxDD)
            maxDD = dd;

         double refEquity = m_startBalance + peak;
         if(refEquity > 0.0)
           {
            double ddp = dd / refEquity * 100.0;
            if(ddp > maxDDpct)
               maxDDpct = ddp;
           }
        }

      double avgWin  = (wins   > 0 ? grossWin  / wins   : 0.0);
      double avgLoss = (losses > 0 ? grossLoss / losses : 0.0);
      double winRate = (total  > 0 ? (double)wins / total * 100.0 : 0.0);
      double pf      = (grossLoss > 0.0 ? grossWin / grossLoss : 0.0);
      double expect  = (total  > 0 ? net / total : 0.0);

      //--- wins worth less than a fifth of the average loss: scratch trades
      double smallThreshold = avgLoss * 0.2;
      if(smallThreshold > 0.0)
         for(int i = 0; i < total; i++)
            if(m_rec[i].net > 0.0 && m_rec[i].net < smallThreshold)
               small++;

      //--- how far each trade ran
      int b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, bN = 0;
      for(int i = 0; i < total; i++)
        {
         if(!m_rec[i].hasR)
           {
            bN++;
            continue;
           }
         double g = m_rec[i].maxGainR;
         if(g < 0.5)      b0++;
         else if(g < 1.0) b1++;
         else if(g < 1.5) b2++;
         else if(g < 2.5) b3++;
         else             b4++;
        }

      string name = base + "_" + _Symbol + "_" + TfName() + ".txt";
      int h = FileOpen(name, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ);
      if(h == INVALID_HANDLE)
        {
         Print("Report: cannot write ", name, " error ", GetLastError());
         return(net);
        }

      FileWrite(h, "================================================================");
      FileWrite(h, " REPORT   " + _Symbol + "   " + TfName());
      FileWrite(h, " from " + TimeToString(m_rec[0].closed, TIME_DATE) +
                " to " + TimeToString(m_rec[total - 1].closed, TIME_DATE));
      FileWrite(h, "================================================================");
      FileWrite(h, " starting balance " + DoubleToString(m_startBalance, 2) +
                " " + m_ccy + "   -   all amounts are in " + m_ccy);
      FileWrite(h, "");
      FileWrite(h, " RESULT");
      FileWrite(h, Row("net profit",            Money(net)));
      FileWrite(h, Row("closed trades",         IntegerToString(total)));
      FileWrite(h, Row("won / lost",            IntegerToString(wins) + " / " +
                       IntegerToString(losses)));
      FileWrite(h, Row("win rate",              DoubleToString(winRate, 1) + " %"));
      FileWrite(h, Row("profit factor",         DoubleToString(pf, 2)));
      FileWrite(h, "");
      FileWrite(h, " WHAT A WIN IS WORTH");
      FileWrite(h, Row("average win",           Money(avgWin)));
      FileWrite(h, Row("average loss",          Money(-avgLoss)));
      FileWrite(h, Row("expectancy per trade",  Money(expect)));
      FileWrite(h, "");
      FileWrite(h, "   Expectancy is what every trade earns on average.");
      FileWrite(h, "   If it is negative the win rate does not matter: the more");
      FileWrite(h, "   it trades, the more it loses.");

      if(small > 0)
        {
         FileWrite(h, "   WARNING: " + IntegerToString(small) + " of the " +
                   IntegerToString(wins) + " wins are worth less than a fifth");
         FileWrite(h, "   of the average loss. They are scratch trades: they raise");
         FileWrite(h, "   the win rate and do not pay for the losses.");
        }

      FileWrite(h, "");
      FileWrite(h, " RISK");
      FileWrite(h, Row("max drawdown (amount)", Money(-maxDD)));
      FileWrite(h, Row("max drawdown (percent)", "- " + DoubleToString(maxDDpct, 1) + " %"));
      FileWrite(h, Row("worst trade",           Money(worst)));
      FileWrite(h, Row("losses in a row",       IntegerToString(worstStreak)));
      FileWrite(h, "");
      FileWrite(h, "   Drawdown is measured from the highest point reached,");
      FileWrite(h, "   not from the starting balance.");
      FileWrite(h, "");

      FileWrite(h, " MONTH BY MONTH");
      int idx = 0;
      while(idx < total)
        {
         MqlDateTime s;
         TimeToStruct(m_rec[idx].closed, s);
         int y = s.year, mo = s.mon;
         double sum = 0.0;
         int    cnt = 0;
         while(idx < total)
           {
            MqlDateTime t;
            TimeToStruct(m_rec[idx].closed, t);
            if(t.year != y || t.mon != mo)
               break;
            sum += m_rec[idx].net;
            cnt++;
            idx++;
           }
         string line = Row(IntegerToString(y) + "." + (mo < 10 ? "0" : "") +
                           IntegerToString(mo), Money(sum)) +
                       PadLeft(IntegerToString(cnt) + " trades", 12);
         if(sum < 0.0)
            line += "   <- losing month";
         FileWrite(h, line);
        }

      FileWrite(h, "");
      FileWrite(h, " HOW FAR EACH TRADE RAN");
      FileWrite(h, "   (best gain reached before closing, in R)");
      FileWrite(h, Row("under 0.5 R",   IntegerToString(b0)));
      FileWrite(h, Row("0.5 - 1.0 R",   IntegerToString(b1)));
      FileWrite(h, Row("1.0 - 1.5 R",   IntegerToString(b2)));
      FileWrite(h, Row("1.5 - 2.5 R",   IntegerToString(b3)));
      FileWrite(h, Row("over 2.5 R",    IntegerToString(b4)));
      if(bN > 0)
         FileWrite(h, Row("not measurable", IntegerToString(bN)) +
                   "   (no stop loss known)");
      FileWrite(h, "");
      FileWrite(h, "   If many trades stop just above 1.0 R, it is not the market:");
      FileWrite(h, "   it is the break even or the trailing that cuts them.");
      FileWrite(h, "");
      FileWrite(h, "================================================================");
      FileWrite(h, " This report is built from the trades that really closed.");
      FileWrite(h, " No month was removed and no parameter was optimized.");
      FileWrite(h, "================================================================");
      FileClose(h);

      if(m_journal != NULL)
         m_journal.Info("report written: " + name + " - " + IntegerToString(total) +
                        " trades, net " + DoubleToString(net, 2));
      return(net);
     }
  };

//+------------------------------------------------------------------+
//| What is remembered about each watched position                   |
//+------------------------------------------------------------------+
struct WatchRec
  {
   ulong             ticket;
   long              posId;
   string            symbol;
   double            openPrice;
   double            initialSL;     // 0 if no stop loss has been seen yet
   double            maxGainR;
   datetime          opened;
   bool              isBuy;
   bool              noStopWarned;
  };

//+------------------------------------------------------------------+
//| The watcher: follows the positions opened by someone else        |
//| and tracks how far each one ran. It never touches a position.    |
//+------------------------------------------------------------------+
class CWatcher
  {
private:
   WatchRec          m_w[];
   CJournal         *m_journal;
   CReport          *m_report;

   int               Find(const ulong ticket)
     {
      for(int i = ArraySize(m_w) - 1; i >= 0; i--)
         if(m_w[i].ticket == ticket)
            return(i);
      return(-1);
     }

   void              Remove(const int i)
     {
      int n = ArraySize(m_w);
      if(i < 0 || i >= n)
         return;
      for(int k = i; k < n - 1; k++)
         m_w[k] = m_w[k + 1];
      ArrayResize(m_w, n - 1);
     }

   //--- is the selected position one we should watch?
   bool              Mine(void)
     {
      if(InpScope == SCOPE_SYMBOL && PositionGetString(POSITION_SYMBOL) != _Symbol)
         return(false);
      if(InpOnlyMagic != 0 && PositionGetInteger(POSITION_MAGIC) != InpOnlyMagic)
         return(false);
      return(true);
     }

   void              Say(const string symbol, const string text)
     {
      if(m_journal != NULL)
         m_journal.Note(symbol, text);
      if(InpAlertNoStop && !MQLInfoInteger(MQL_TESTER))
         Alert(text);
     }

public:
                     CWatcher(void) : m_journal(NULL), m_report(NULL)
     {
      ArrayResize(m_w, 0);
     }

   void              Init(CJournal &journal, CReport &report)
     {
      m_journal = GetPointer(journal);
      m_report  = GetPointer(report);
     }

   //--- call on every tick and on a timer
   void              Update(void)
     {
      for(int p = PositionsTotal() - 1; p >= 0; p--)
        {
         ulong ticket = PositionGetTicket(p);
         if(ticket == 0)
            continue;
         if(!Mine())
            continue;

         double curSL = PositionGetDouble(POSITION_SL);
         int i = Find(ticket);
         if(i < 0)
           {
            //--- new position: take note
            int n = ArraySize(m_w);
            ArrayResize(m_w, n + 1);
            m_w[n].ticket       = ticket;
            m_w[n].posId        = PositionGetInteger(POSITION_IDENTIFIER);
            m_w[n].symbol       = PositionGetString(POSITION_SYMBOL);
            m_w[n].openPrice    = PositionGetDouble(POSITION_PRICE_OPEN);
            m_w[n].initialSL    = curSL;
            m_w[n].maxGainR     = 0.0;
            m_w[n].opened       = (datetime)PositionGetInteger(POSITION_TIME);
            m_w[n].isBuy        = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
            m_w[n].noStopWarned = false;
            i = n;

            long   magic = PositionGetInteger(POSITION_MAGIC);
            string who   = (magic == 0 ? "manual or script" : "EA magic " + IntegerToString(magic));
            string slTxt = (curSL > 0.0
                            ? DoubleToString(curSL, (int)SymbolInfoInteger(m_w[i].symbol, SYMBOL_DIGITS))
                            : "NONE");
            if(m_journal != NULL)
               m_journal.Write(J_TRADE_OPEN, m_w[i].symbol,
                               (m_w[i].isBuy ? "BUY" : "SELL"),
                               m_w[i].openPrice,
                               PositionGetDouble(POSITION_VOLUME),
                               curSL,
                               PositionGetDouble(POSITION_TP),
                               0.0,
                               "opened by " + who + " - initial stop " + slTxt);
           }

         //--- many EAs set the stop a moment after the entry: the first one seen is the risk
         if(m_w[i].initialSL <= 0.0 && curSL > 0.0)
           {
            m_w[i].initialSL = curSL;
            if(m_journal != NULL)
               m_journal.Note(m_w[i].symbol,
                              "stop loss first seen at " +
                              DoubleToString(curSL, (int)SymbolInfoInteger(m_w[i].symbol, SYMBOL_DIGITS)) +
                              " after the entry - used as the initial risk");
           }

         //--- no stop loss after a few seconds: say it, once
         if(m_w[i].initialSL <= 0.0 && !m_w[i].noStopWarned &&
            TimeCurrent() - m_w[i].opened >= 10)
           {
            m_w[i].noStopWarned = true;
            Say(m_w[i].symbol, "position on " + m_w[i].symbol +
                " has NO stop loss: the maximum loss is not defined");
           }

         //--- how far it ran, in R
         double riskPts = MathAbs(m_w[i].openPrice - m_w[i].initialSL);
         if(m_w[i].initialSL > 0.0 && riskPts > 0.0)
           {
            double pt = (m_w[i].isBuy
                         ? SymbolInfoDouble(m_w[i].symbol, SYMBOL_BID)
                         : SymbolInfoDouble(m_w[i].symbol, SYMBOL_ASK));
            double gain = (m_w[i].isBuy ? pt - m_w[i].openPrice
                                        : m_w[i].openPrice - pt);
            double gR = gain / riskPts;
            if(gR > m_w[i].maxGainR)
               m_w[i].maxGainR = gR;
           }
        }

      //--- positions that are gone: the measure goes to the report
      for(int i = ArraySize(m_w) - 1; i >= 0; i--)
        {
         if(PositionSelectByTicket(m_w[i].ticket))
            continue;

         double riskPts = (m_w[i].initialSL > 0.0
                           ? MathAbs(m_w[i].openPrice - m_w[i].initialSL) : 0.0);
         if(m_report != NULL)
            m_report.OnMeasured(m_w[i].posId, riskPts, m_w[i].maxGainR);

         if(m_journal != NULL)
           {
            if(riskPts > 0.0)
               m_journal.Note(m_w[i].symbol,
                              StringFormat("%s: best gain reached +%.2f R",
                                           m_w[i].symbol, m_w[i].maxGainR));
            else
               m_journal.Note(m_w[i].symbol,
                              m_w[i].symbol + ": best gain not measurable (no stop loss)");
           }
         Remove(i);
        }
     }
  };

CJournal Journal;
CReport  Report;
CWatcher Watcher;

//+------------------------------------------------------------------+
int OnInit(void)
  {
   Journal.Open(InpJournalFile, InpWriteJournal);
   Report.Init(Journal);
   Watcher.Init(Journal, Report);
   Journal.Info("start - journal only, no position is ever opened, changed or closed");
   EventSetMillisecondTimer(500);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(!MQLInfoInteger(MQL_TESTER))
      Report.Write(InpReportFile);
   Journal.Info("stop - " + StopReason(reason));
   Journal.Close();
  }

//+------------------------------------------------------------------+
void OnTick(void)
  {
   Watcher.Update();
  }

//+------------------------------------------------------------------+
void OnTimer(void)
  {
   Watcher.Update();
  }

//+------------------------------------------------------------------+
//| Was the entry deal of this position made with our magic number?  |
//+------------------------------------------------------------------+
bool EntryMagicMatches(const long posId)
  {
   if(!HistorySelectByPosition(posId))
      return(false);
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong d = HistoryDealGetTicket(i);
      if(d == 0)
         continue;
      if(HistoryDealGetInteger(d, DEAL_ENTRY) != DEAL_ENTRY_IN)
         continue;
      return(HistoryDealGetInteger(d, DEAL_MAGIC) == InpOnlyMagic);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Closing deals: exit price, net result, and who closed the trade  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest     &request,
                        const MqlTradeResult      &result)
  {
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return;

   ulong deal = trans.deal;
   if(deal == 0)
      return;

   datetime now = TimeCurrent();
   if(!HistorySelect(now - 3 * 86400, now + 86400))
      return;
   if(!HistoryDealSelect(deal))
      return;

   string sym = HistoryDealGetString(deal, DEAL_SYMBOL);
   if(InpScope == SCOPE_SYMBOL && sym != _Symbol)
      return;

   long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
   if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY)
      return;

   long posId = HistoryDealGetInteger(deal, DEAL_POSITION_ID);
   if(posId == 0)
      return;

   //--- read everything from this deal first
   double price    = HistoryDealGetDouble(deal, DEAL_PRICE);
   double volume   = HistoryDealGetDouble(deal, DEAL_VOLUME);
   double net      = HistoryDealGetDouble(deal, DEAL_PROFIT)
                   + HistoryDealGetDouble(deal, DEAL_SWAP)
                   + HistoryDealGetDouble(deal, DEAL_COMMISSION)
                   + HistoryDealGetDouble(deal, DEAL_FEE);
   long   dealType = HistoryDealGetInteger(deal, DEAL_TYPE);
   int    reasonCode = (int)HistoryDealGetInteger(deal, DEAL_REASON);

   //--- on a stop or a target the magic of the closing deal can be zero,
   //--- because the server creates the order: read it from the entry deal
   if(InpOnlyMagic != 0 && !EntryMagicMatches(posId))
      return;

   string side = (dealType == DEAL_TYPE_SELL ? "BUY" : "SELL");   // side of the position

   string why = "closed";
   switch(reasonCode)
     {
      case DEAL_REASON_SL:     why = "closed by stop loss";                  break;
      case DEAL_REASON_TP:     why = "closed by take profit";                break;
      case DEAL_REASON_SO:     why = "closed by the broker (stop out)";      break;
      case DEAL_REASON_EXPERT: why = "closed by a program";                  break;
      case DEAL_REASON_CLIENT:
      case DEAL_REASON_MOBILE:
      case DEAL_REASON_WEB:    why = "closed by hand";                       break;
     }
   why += StringFormat(" - result %s%.2f", (net >= 0 ? "+" : ""), net);

   Journal.Write(J_TRADE_CLOSE, sym, side, price, volume, 0.0, 0.0, net, why);
   Report.OnClose(posId, now, net);
  }

//+------------------------------------------------------------------+
double OnTester(void)
  {
   double net = Report.Write(InpReportFile);
   int    n   = Report.Count();
   return(n > 0 ? net / n : 0.0);
  }
//+------------------------------------------------------------------+
