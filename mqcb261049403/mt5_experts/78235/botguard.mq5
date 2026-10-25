//+------------------------------------------------------------------+
//|                                                     BotGuard.mq5 |
//|  Health heartbeat for hosted MT5 terminals. Attach to one chart  |
//|  per terminal. It never trades. guard.ps1 reads the heartbeat    |
//|  to detect frozen/disconnected terminals and send alerts.        |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property version   "1.00"
#property description "BotGuard: writes a health heartbeat (connection, AutoTrading, equity, daily P/L) for the MT5 Guard watchdog. Does not trade."

input int    InpHeartbeatSec  = 30;    // Heartbeat interval (seconds)
input int    InpLogEveryMin   = 5;     // Equity log interval for reports (minutes)
input double InpEquityDropPct = 10.0;  // Push alert if equity drops this % below day start (0 = off)
input bool   InpPushAlerts    = true;  // Send MT5 mobile push notifications

int      dayOfYear      = -1;
double   dayStartEquity = 0.0;
bool     ddAlerted      = false;
bool     wasConnected   = true;
bool     wasTradeOn     = true;
datetime lastLogTime    = 0;
string   hbFile, logFile;

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpHeartbeatSec < 5)
      return(INIT_PARAMETERS_INCORRECT);

   long login = AccountInfoInteger(ACCOUNT_LOGIN);
   hbFile  = "botguard_" + (string)login + ".json";
   logFile = "botguard_" + (string)login + "_log.csv";

   UpdateDay();
   EventSetTimer(InpHeartbeatSec);
   WriteHeartbeat();
   AppendLog();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }

//+------------------------------------------------------------------+
void OnTick()
  {
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdateDay();
   CheckHealth();
   WriteHeartbeat();
   if(TimeLocal() - lastLogTime >= InpLogEveryMin * 60)
      AppendLog();
  }

//+------------------------------------------------------------------+
void UpdateDay()
  {
   MqlDateTime dt;
   TimeToStruct(TimeLocal(), dt);
   if(dt.day_of_year != dayOfYear)
     {
      dayOfYear      = dt.day_of_year;
      dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      ddAlerted      = false;
     }
  }

//+------------------------------------------------------------------+
double DayPLPct()
  {
   if(dayStartEquity <= 0)
      return(0);
   return((AccountInfoDouble(ACCOUNT_EQUITY) / dayStartEquity - 1.0) * 100.0);
  }

//+------------------------------------------------------------------+
void Notify(const string msg)
  {
   Print("BotGuard: ", msg);
   if(InpPushAlerts && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
      SendNotification("BotGuard " + (string)AccountInfoInteger(ACCOUNT_LOGIN) + ": " + msg);
  }

//+------------------------------------------------------------------+
void CheckHealth()
  {
   bool connected = (bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   bool tradeOn   = (bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);

   if(connected && !wasConnected)
      Notify("connection restored");
   wasConnected = connected;

   if(!tradeOn && wasTradeOn)
      Notify("AutoTrading was switched OFF - bots cannot trade");
   if(tradeOn && !wasTradeOn)
      Notify("AutoTrading is ON again");
   wasTradeOn = tradeOn;

   if(InpEquityDropPct > 0 && !ddAlerted && DayPLPct() <= -InpEquityDropPct)
     {
      Notify(StringFormat("equity is down %.1f%% today", -DayPLPct()));
      ddAlerted = true;
     }
  }

//+------------------------------------------------------------------+
string JsonStr(const string s)
  {
   string r = s;
   StringReplace(r, "\\", "\\\\");
   StringReplace(r, "\"", "\\\"");
   return("\"" + r + "\"");
  }

//+------------------------------------------------------------------+
void WriteHeartbeat()
  {
   string json = "{";
   json += "\"time_utc\":" + (string)(long)TimeGMT() + ",";
   json += "\"login\":" + (string)AccountInfoInteger(ACCOUNT_LOGIN) + ",";
   json += "\"server\":" + JsonStr(AccountInfoString(ACCOUNT_SERVER)) + ",";
   json += "\"company\":" + JsonStr(AccountInfoString(ACCOUNT_COMPANY)) + ",";
   json += "\"currency\":" + JsonStr(AccountInfoString(ACCOUNT_CURRENCY)) + ",";
   json += "\"connected\":" + ((bool)TerminalInfoInteger(TERMINAL_CONNECTED) ? "true" : "false") + ",";
   json += "\"trade_allowed\":" + ((bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ? "true" : "false") + ",";
   json += "\"ping_ms\":" + DoubleToString(TerminalInfoInteger(TERMINAL_PING_LAST) / 1000.0, 1) + ",";
   json += "\"balance\":" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + ",";
   json += "\"equity\":" + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + ",";
   json += "\"margin_level\":" + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 1) + ",";
   json += "\"positions\":" + (string)PositionsTotal() + ",";
   json += "\"orders\":" + (string)OrdersTotal() + ",";
   json += "\"day_start_equity\":" + DoubleToString(dayStartEquity, 2) + ",";
   json += "\"day_pl_pct\":" + DoubleToString(DayPLPct(), 2) + ",";
   json += "\"build\":" + (string)TerminalInfoInteger(TERMINAL_BUILD);
   json += "}";

   // Write to a temp file, then swap it in, so the watchdog never reads a half-written file
   string tmp = hbFile + ".tmp";
   int h = FileOpen(tmp, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(h == INVALID_HANDLE)
     {
      Print("BotGuard: cannot write heartbeat, error ", GetLastError());
      return;
     }
   FileWriteString(h, json);
   FileClose(h);
   if(!FileMove(tmp, FILE_COMMON, hbFile, FILE_COMMON | FILE_REWRITE))
      Print("BotGuard: cannot replace heartbeat, error ", GetLastError());
  }

//+------------------------------------------------------------------+
void AppendLog()
  {
   bool isNew = !FileIsExist(logFile, FILE_COMMON);
   int h = FileOpen(logFile, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(h == INVALID_HANDLE)
      return;
   FileSeek(h, 0, SEEK_END);
   if(isNew)
      FileWriteString(h, "time_utc,balance,equity,positions,connected\r\n");
   FileWriteString(h, StringFormat("%s,%.2f,%.2f,%d,%d\r\n",
                   TimeToString(TimeGMT(), TIME_DATE | TIME_SECONDS),
                   AccountInfoDouble(ACCOUNT_BALANCE),
                   AccountInfoDouble(ACCOUNT_EQUITY),
                   PositionsTotal(),
                   (int)TerminalInfoInteger(TERMINAL_CONNECTED)));
   FileClose(h);
   lastLogTime = TimeLocal();
  }
//+------------------------------------------------------------------+
