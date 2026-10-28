//+------------------------------------------------------------------+
//|                                               LiveTestDriver.mq5 |
//|  Test driver for the article "Live testing of Expert Advisors on |
//|  a demo account".                                                |
//|                                                                  |
//|  Runs one test phase per terminal start against the EA under     |
//|  test (ExampleDailyLock_DemoTest), writes PASS/FAIL lines to     |
//|  MQL5\Files\LiveTestBench\results_<phase>.txt and closes the     |
//|  terminal. The phase name is read from phase.txt in that folder. |
//|  Demo accounts only.                                             |
//+------------------------------------------------------------------+
#property copyright "Article example"
#property version   "1.00"
#property description "Live test driver: demo accounts only."

#include <Trade\Trade.mqh>

#define DIR        "LiveTestBench\\"
#define EA_NAME    "ExampleDailyLock_DemoTest"
#define EA_PATH    "Experts\\LiveTestBench\\ExampleDailyLock_DemoTest.ex5"
#define MY_MAGIC   770077
#define LOSS_LIMIT 1.0       // daily limit given to the EA under test, account currency

CTrade   g_trade;
string   g_phase = "";
string   g_symbol = "";
long     g_login = 0;
int      g_resetHour = 0;
int      g_pass = 0, g_fail = 0;
int      g_log = INVALID_HANDLE;
bool     g_done = false;

//+------------------------------------------------------------------+
int OnInit()
  {
   g_phase = ReadText(DIR + "phase.txt");
   StringTrimLeft(g_phase);
   StringTrimRight(g_phase);
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_log != INVALID_HANDLE)
      FileClose(g_log);
  }

void OnTick() {}

void OnTimer()
  {
   if(g_done)
      return;
   // the driver starts before the terminal is connected: wait for the account
   if(TerminalInfoInteger(TERMINAL_CONNECTED) == 0 || AccountInfoDouble(ACCOUNT_BALANCE) <= 0.0)
      return;
   static datetime seen = 0;
   if(seen == 0)
      seen = TimeLocal();
   if(TimeLocal() - seen < 5)
      return;
   g_done = true;
   EventKillTimer();

   g_log = FileOpen(DIR + "results_" + g_phase + ".txt", FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ);
   Log(StringFormat("=== phase %s, server time %s", g_phase, TimeToString(TimeTradeServer(), TIME_DATE | TIME_SECONDS)));
   if(!IsDemo())
      Log("ABORT: not a demo account, nothing was done");
   else
      if(g_phase == "A")
         PhaseA();
      else
         if(g_phase == "B")
            PhaseB();
         else
            if(g_phase == "C")
               PhaseC();
            else
               Log("Unknown phase '" + g_phase + "'");
   Log(StringFormat("=== %d passed, %d failed", g_pass, g_fail));
   FileClose(g_log);
   g_log = INVALID_HANDLE;
   TerminalClose(0);
  }

//+------------------------------------------------------------------+
//| Phase A: start, one copy per account, lock, then close for B     |
//+------------------------------------------------------------------+
void PhaseA()
  {
   if(!Prepare())
      return;
   // reset hour = current server hour, so today's history starts empty
   MqlDateTime t;
   TimeToStruct(TimeTradeServer(), t);
   g_resetHour = t.hour;
   WriteText(DIR + "reset_hour.txt", IntegerToString(g_resetHour));
   GlobalVariablesDeleteAll(GvPrefix());

   const long c1 = OpenChart();
   Check(Attach(c1) && WaitOwner(c1, 20), "EA started and owns the account");
   Sleep(1500);
   const datetime key = DayKey(TimeTradeServer());
   Check((datetime)(long)Gv("dayKey") == key, "day start = " + TimeToString(key));
   Check(MathAbs(Gv("dayBal") - (AccountInfoDouble(ACCOUNT_BALANCE) - ClosedProfitSince(key))) < 0.005, "day-start balance rebuilt from history");
   Check(Gv("locked") == 0.0, "not locked at start");

   // a second copy must be refused, even after the account was quiet for a while
   Sleep(12000);
   const double dayBal = Gv("dayBal");
   const long c2 = OpenChart();
   Attach(c2, false);
   Sleep(6000);
   Check(ChartGetString(c2, CHART_EXPERT_NAME) != EA_NAME, "second copy refused");
   Check(Gv("owner") == InstanceId(c1) && Gv("dayBal") == dayBal, "first copy still owns the account, state unchanged");
   ChartClose(c2);

   // push the loss over the limit: 0.1 lot at a time until the EA locks
   bool locked = false;
   for(int i = 0; i < 10 && !locked; i++)
     {
      Open(i % 2 == 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, 0.1);
      for(int w = 0; w < 8 && !locked; w++)
        {
         Sleep(250);
         locked = (Gv("locked") == 1.0);
        }
     }
   Check(locked, "locked when the daily loss reached the limit");
   Sleep(2000);
   Check(MyPositions() == 0, "positions closed by the lock");

   // a new position while locked must be closed at once
   const ulong start = GetTickCount64();
   Open(ORDER_TYPE_BUY, 0.1);
   while(MyPositions() > 0 && GetTickCount64() - start < 6000)
      Sleep(50);
   Check(MyPositions() == 0, StringFormat("position opened while locked closed after %I64u ms", GetTickCount64() - start));

   SaveSnapshot();
   Log("closing the terminal to test the restart");
  }

//+------------------------------------------------------------------+
//| Phase B: after the restart                                       |
//+------------------------------------------------------------------+
void PhaseB()
  {
   if(!Prepare())
      return;
   long c1 = -1;
   for(long c = ChartFirst(); c >= 0; c = ChartNext(c))
      if(ChartGetString(c, CHART_EXPERT_NAME) == EA_NAME)
         c1 = c;
   Check(c1 >= 0, "EA chart restored with the profile");
   if(c1 < 0)
      return;
   Check(WaitOwner(c1, 30), "EA started again after the restart");
   Sleep(1500);
   Check(SnapshotMatches(), "saved state identical after the restart");
   Check(Gv("locked") == 1.0, "still locked after the restart");

   const ulong start = GetTickCount64();
   Open(ORDER_TYPE_SELL, 0.1);
   while(MyPositions() > 0 && GetTickCount64() - start < 6000)
      Sleep(50);
   Check(MyPositions() == 0, StringFormat("lock enforced after the restart (%I64u ms)", GetTickCount64() - start));

   // no saved state: the day start must be rebuilt from today's deals
   ChartClose(c1);
   Sleep(1500);
   GlobalVariablesDeleteAll(GvPrefix());
   const long c2 = OpenChart();
   Check(Attach(c2) && WaitOwner(c2, 15), "EA attached with no saved state");
   Sleep(2000);
   const datetime key = DayKey(TimeTradeServer());
   const double expected = AccountInfoDouble(ACCOUNT_BALANCE) - ClosedProfitSince(key);
   Check(MathAbs(Gv("dayBal") - expected) < 0.005, StringFormat("day start rebuilt: %.2f (expected %.2f)", Gv("dayBal"), expected));
   Check(Gv("locked") == 1.0, "lock re-derived from today's losses");
   ChartClose(c2);
   Sleep(1500);
   GlobalVariablesDeleteAll(GvPrefix());
  }

//+------------------------------------------------------------------+
//| Phase C: a person clicks the Unlock button                       |
//+------------------------------------------------------------------+
void PhaseC()
  {
   if(!Prepare())
      return;
   GlobalVariablesDeleteAll(GvPrefix());
   const long c1 = OpenChart();
   Check(Attach(c1) && WaitOwner(c1, 15), "EA attached");
   Sleep(2000);
   bool locked = (Gv("locked") == 1.0); // today's losses may already exceed the limit
   for(int i = 0; i < 10 && !locked; i++)
     {
      Open(ORDER_TYPE_BUY, 0.1);
      for(int w = 0; w < 8 && !locked; w++)
        {
         Sleep(250);
         locked = (Gv("locked") == 1.0);
        }
     }
   Check(locked, "locked");
   // show the person what to do, keep a picture of it for the report
   ChartSetInteger(c1, CHART_BRING_TO_TOP, true);
   ObjectCreate(c1, "tip", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(c1, "tip", OBJPROP_XDISTANCE, 150);
   ObjectSetInteger(c1, "tip", OBJPROP_YDISTANCE, 44);
   ObjectSetInteger(c1, "tip", OBJPROP_COLOR, clrGold);
   ObjectSetInteger(c1, "tip", OBJPROP_FONTSIZE, 12);
   ObjectSetString(c1, "tip", OBJPROP_TEXT, "TEST: click the Unlock button");
   ChartRedraw(c1);
   Sleep(1500);
   ChartScreenShot(c1, DIR + "phaseC_prompt.png", 740, 400, ALIGN_RIGHT);

   Log("waiting up to 10 minutes for a click on Unlock");
   const ulong start = GetTickCount64();
   while(Gv("locked") == 1.0 && GetTickCount64() - start < 600000)
      Sleep(500);
   Check(Gv("locked") == 0.0, StringFormat("unlocked by a click on the chart (after %I64u s)", (GetTickCount64() - start) / 1000));
   ObjectDelete(c1, "tip");
   ChartClose(c1);
   Sleep(1500);
   GlobalVariablesDeleteAll(GvPrefix());
  }

//+------------------------------------------------------------------+
//| Safety and preparation                                           |
//+------------------------------------------------------------------+
bool IsDemo()
  {
   g_login = AccountInfoInteger(ACCOUNT_LOGIN);
   Log(StringFormat("account %I64d, %s, balance %.2f %s", g_login,
                    AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO ? "demo" : "NOT demo",
                    AccountInfoDouble(ACCOUNT_BALANCE), AccountInfoString(ACCOUNT_CURRENCY)));
   return(AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO);
  }

bool Prepare()
  {
   const string candidates[] = {"EURUSD", "EURUSDm", "GBPUSD", "GBPUSDm"};
   for(int i = 0; i < ArraySize(candidates) && g_symbol == ""; i++)
      if(SymbolSelect(candidates[i], true) && SymbolInfoInteger(candidates[i], SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL)
         g_symbol = candidates[i];
   if(g_phase != "A")
      g_resetHour = (int)StringToInteger(ReadText(DIR + "reset_hour.txt"));
   Check(g_symbol != "", "test symbol " + g_symbol);
   Check(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0, "algo trading enabled");
   g_trade.SetExpertMagicNumber(MY_MAGIC);
   g_trade.SetDeviationInPoints(100);
   return(g_symbol != "" && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0);
  }

//+------------------------------------------------------------------+
//| Charts and the EA under test                                     |
//+------------------------------------------------------------------+
long OpenChart()
  {
   const long id = ChartOpen(g_symbol, PERIOD_M1);
   Sleep(1500);
   return(id);
  }

// Attach the EA under test with a generated template; optionally wait until it runs
bool Attach(const long chart, const bool wait = true)
  {
   string tpl = "<chart>\r\nsymbol=" + g_symbol + "\r\nperiod_type=0\r\nperiod_size=1\r\n";
   tpl += "<expert>\r\nname=" + EA_NAME + "\r\npath=" + EA_PATH + "\r\nexpertmode=33\r\n<inputs>\r\n";
   tpl += "InpDailyLossMoney=" + DoubleToString(LOSS_LIMIT, 2) + "\r\n";
   tpl += "InpResetHour=" + IntegerToString(g_resetHour) + "\r\n";
   tpl += "InpMagic=" + IntegerToString(MY_MAGIC) + "\r\n";
   tpl += "</inputs>\r\n</expert>\r\n";
   tpl += "<window>\r\nheight=100.000000\r\nobjects=0\r\n<indicator>\r\nname=Main\r\npath=\r\napply=1\r\nshow_data=1\r\n";
   tpl += "expertmode=0\r\nfixed_height=-1\r\n</indicator>\r\n</window>\r\n</chart>\r\n";
   const int h = FileOpen(DIR + "ea.tpl", FILE_WRITE | FILE_TXT | FILE_UNICODE);
   if(h == INVALID_HANDLE)
      return(false);
   FileWriteString(h, tpl);
   FileClose(h);
   if(!ChartApplyTemplate(chart, "\\Files\\" + DIR + "ea.tpl"))
      return(false);
   if(!wait)
      return(true);
   for(int i = 0; i < 60; i++)
     {
      if(ChartGetString(chart, CHART_EXPERT_NAME) == EA_NAME) // an empty chart reports "(null)"
         return(true);
      Sleep(250);
     }
   return(false);
  }

double InstanceId(const long chart)
  {
   const long id = chart % 1000000000000;
   return((double)(id > 0 ? id : 1));
  }

bool WaitOwner(const long chart, const int seconds)
  {
   for(int i = 0; i < seconds * 4; i++)
     {
      if(Gv("owner") == InstanceId(chart))
         return(true);
      Sleep(250);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| The EA's state in global variables                               |
//+------------------------------------------------------------------+
string GvPrefix()              { return("EDL." + IntegerToString(g_login) + "."); }
double Gv(const string key)    { return(GlobalVariableCheck(GvPrefix() + key) ? GlobalVariableGet(GvPrefix() + key) : -1.0); }

void SaveSnapshot()
  {
   const string keys[] = {"dayKey", "dayBal", "locked", "lockUntil"};
   string text = "";
   for(int i = 0; i < ArraySize(keys); i++)
      text += keys[i] + "=" + DoubleToString(Gv(keys[i]), 2) + "\n";
   WriteText(DIR + "snapshot.txt", text);
  }

bool SnapshotMatches()
  {
   string lines[];
   const int n = StringSplit(ReadText(DIR + "snapshot.txt"), '\n', lines);
   int checked = 0;
   for(int i = 0; i < n; i++)
     {
      string kv[];
      if(StringSplit(lines[i], '=', kv) != 2)
         continue;
      checked++;
      if(MathAbs(StringToDouble(kv[1]) - Gv(kv[0])) > 0.005)
        {
         Log("  changed: " + kv[0]);
         return(false);
        }
     }
   return(checked > 0);
  }

datetime DayKey(const datetime now)
  {
   MqlDateTime d;
   TimeToStruct(now, d);
   datetime key = now - (d.hour * 3600 + d.min * 60 + d.sec) + g_resetHour * 3600;
   if(now < key)
      key -= 86400;
   return(key);
  }

double ClosedProfitSince(const datetime from)
  {
   HistorySelect(from, TimeTradeServer() + 60);
   double sum = 0.0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      const ulong ticket = HistoryDealGetTicket(i);
      const long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
         sum += HistoryDealGetDouble(ticket, DEAL_PROFIT) + HistoryDealGetDouble(ticket, DEAL_SWAP) +
                HistoryDealGetDouble(ticket, DEAL_COMMISSION) + HistoryDealGetDouble(ticket, DEAL_FEE);
     }
   return(sum);
  }

//+------------------------------------------------------------------+
//| Trading helpers: the driver only touches its own magic number    |
//+------------------------------------------------------------------+
bool Open(const ENUM_ORDER_TYPE type, const double lots)
  {
   g_trade.SetTypeFillingBySymbol(g_symbol);
   const bool ok = (type == ORDER_TYPE_BUY) ? g_trade.Buy(lots, g_symbol) : g_trade.Sell(lots, g_symbol);
   if(!ok)
      Log(StringFormat("order failed: %u %s", g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription()));
   return(ok);
  }

int MyPositions()
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(PositionGetTicket(i) > 0 && PositionGetInteger(POSITION_MAGIC) == MY_MAGIC)
         n++;
   return(n);
  }

//+------------------------------------------------------------------+
//| Files and the report                                             |
//+------------------------------------------------------------------+
string ReadText(const string file)
  {
   const int h = FileOpen(file, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return("");
   string s = "";
   while(!FileIsEnding(h))
      s += FileReadString(h) + "\n";
   FileClose(h);
   return(s);
  }

void WriteText(const string file, const string text)
  {
   const int h = FileOpen(file, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return;
   FileWriteString(h, text);
   FileClose(h);
  }

void Log(const string text)
  {
   Print(text);
   if(g_log != INVALID_HANDLE)
     {
      FileWriteString(g_log, TimeToString(TimeLocal(), TIME_SECONDS) + "  " + text + "\r\n");
      FileFlush(g_log);
     }
  }

void Check(const bool ok, const string what)
  {
   if(ok)
      g_pass++;
   else
      g_fail++;
   Log((ok ? "PASS  " : "FAIL  ") + what);
  }
//+------------------------------------------------------------------+
