//+------------------------------------------------------------------+
//|                                             ServerTimeOffset.mq5  |
//|  Prints the three clocks an MQL5 program sees - server, GMT and   |
//|  local - their offsets, and the one rule that keeps timestamps    |
//|  correct when they leave the terminal.                            |
//|                                                                    |
//|  THE TRAP                                                          |
//|                                                                    |
//|  A datetime in MQL5 is an integer: seconds since 1970. Server time |
//|  (TimeCurrent, bar times, deal times) is the broker's wall clock   |
//|  written as if it were UTC. Export it to a CSV, read it in Python  |
//|  or a spreadsheet with a function that assumes "seconds since 1970 |
//|  UTC", and every timestamp shifts by the server's UTC offset. On a |
//|  UTC-3 broker that is three hours: the daily bar dated 00:00 reads |
//|  as 21:00 of the previous day, and "yesterday's session" silently  |
//|  becomes "today's, half formed" - which is exactly what happened   |
//|  to a morning report of mine before this script existed.           |
//|                                                                    |
//|  THE RULE                                                          |
//|                                                                    |
//|  Export server timestamps AS server wall-clock text (yyyy-mm-dd    |
//|  hh:mm:ss), or export the epoch together with the offset printed   |
//|  here, and never let the consumer apply its own timezone to them.  |
//+------------------------------------------------------------------+
#property copyright "Joao Prata Silva Yglesias"
#property link      "https://www.mql5.com/en/users/jotayglesias"
#property version   "1.00"
#property script_show_inputs

input bool InpShowLastBar = true;   // Also show this chart's last bar time

string Fmt(datetime t) { return TimeToString(t, TIME_DATE | TIME_SECONDS); }

void OnStart()
  {
   datetime server = TimeTradeServer();   // server clock even without ticks
   datetime tick   = TimeCurrent();       // last tick's stamp
   datetime gmt    = TimeGMT();
   datetime local  = TimeLocal();
   int offServer   = (int)((long)server - (long)gmt);
   int offLocal    = (int)((long)local  - (long)gmt);

   Print("================================================");
   Print("ServerTimeOffset");
   PrintFormat("  TimeTradeServer : %s   (broker wall clock)", Fmt(server));
   PrintFormat("  TimeCurrent     : %s   (last tick; frozen when no ticks)", Fmt(tick));
   PrintFormat("  TimeGMT         : %s", Fmt(gmt));
   PrintFormat("  TimeLocal       : %s   (this PC)", Fmt(local));
   Print("");
   PrintFormat("  server - GMT    : %+d s  (%+.1f h)", offServer, offServer / 3600.0);
   PrintFormat("  local  - GMT    : %+d s  (%+.1f h)", offLocal,  offLocal  / 3600.0);
   PrintFormat("  server - local  : %+d s  (%+.1f h)", offServer - offLocal, (offServer - offLocal) / 3600.0);
   PrintFormat("  tick lag        : %d s behind the server clock", (int)((long)server - (long)tick));
   if(InpShowLastBar)
     {
      datetime bar = iTime(_Symbol, _Period, 0);
      PrintFormat("  last bar (%s %s): %s server time = %s UTC",
                  _Symbol, EnumToString(_Period), Fmt(bar), Fmt(bar - offServer));
     }
   Print("");
   Print("  Rule: a server datetime is the broker's wall clock stored as if UTC.");
   PrintFormat("  To get real UTC from any server timestamp here, subtract %+d s.", offServer);
   Print("  Feeding it raw to a 'seconds since 1970 UTC' parser shifts every");
   PrintFormat("  timestamp by %.1f h - and the parser will not complain.", offServer / 3600.0);
   Print("================================================");
  }
//+------------------------------------------------------------------+
