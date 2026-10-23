//+------------------------------------------------------------------+
//|                                              WeekendGapCheck.mq5 |
//|  Before the Friday close: how much the open positions could lose |
//|  if the market reopens with a gap, compared with the room left   |
//|  under the daily loss limit of the next trading day.             |
//+------------------------------------------------------------------+
#property copyright "Amedeo Nustriani"
#property version   "1.00"
#property description "Weekend gap check for prop firm and funded accounts."
#property description "For every open position it estimates the loss if the market reopens with"
#property description "a gap against it, adds them up and compares the total with the room left"
#property description "under the daily loss limit of the next trading day."
#property description "It only reads the account: it never opens, changes or closes a position."
#property script_show_inputs

input group "Account rules (check them with your prop firm)"
input double InpAccountSize  = 0.0;   // Account size (0 = use the current balance)
input double InpDailyLossPct = 5.0;   // Daily loss limit (% of account size)
input bool   InpFloatCounts  = true;  // A floating loss carried over counts against the next day's limit
input double InpSafetyPct    = 80.0;  // Use at most this % of the room (safety margin)

input group "Gap you accept, as % of the price"
input double InpGapFx        = 0.5;   // Currency pairs
input double InpGapMetals    = 1.5;   // Metals
input double InpGapIndices   = 1.5;   // Stock indices
input double InpGapCrypto    = 3.0;   // Crypto (often trades in the weekend: the move while you are away)
input double InpGapOther     = 1.0;   // Everything else

input group "Symbol groups (a part of the name is enough)"
input string InpMetals  = "XAU,XAG,GOLD,SILVER,XPT,XPD";
input string InpIndices = "US500,US100,US30,USTEC,NAS,SPX,GER,DE40,DAX,JP225,NIKKEI,UK100,FTSE,EU50,STOXX,FRA40,AUS200,HK50";
input string InpCrypto  = "BTC,ETH,LTC,XRP,SOL,ADA,DOGE,BNB";

//--- true if the symbol name contains one of the comma separated parts
bool InList(const string symbol, const string list)
  {
   string sym = symbol;
   StringToUpper(sym);
   string parts[];
   int n = StringSplit(list, ',', parts);
   for(int i = 0; i < n; i++)
     {
      string p = parts[i];
      StringTrimLeft(p);
      StringTrimRight(p);
      StringToUpper(p);
      if(StringLen(p) > 0 && StringFind(sym, p) >= 0)
         return(true);
     }
   return(false);
  }

//--- group name and the gap accepted for it
string GroupOf(const string symbol, double &gapPct)
  {
   if(InList(symbol, InpMetals))
     { gapPct = InpGapMetals;  return("metal"); }
   if(InList(symbol, InpIndices))
     { gapPct = InpGapIndices; return("index"); }
   if(InList(symbol, InpCrypto))
     { gapPct = InpGapCrypto;  return("crypto"); }
   long mode = SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE);
   if(mode == SYMBOL_CALC_MODE_FOREX || mode == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE)
     { gapPct = InpGapFx;      return("currency"); }
   gapPct = InpGapOther;
   return("other");
  }

//--- money lost if the price moves gapPct % against the position
double GapLoss(const string symbol, const double lots, const double price, const double gapPct)
  {
   double ts = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double tv = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tv <= 0.0)
      tv = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   if(ts <= 0.0 || tv <= 0.0 || price <= 0.0)
      return(-1.0);
   double move = price * gapPct / 100.0;
   return(move / ts * tv * lots);
  }

string Pad(const string s, const int width)
  {
   string out = s;
   while(StringLen(out) < width)
      out += " ";
   return(out);
  }

//+------------------------------------------------------------------+
void OnStart(void)
  {
   string ccy     = AccountInfoString(ACCOUNT_CURRENCY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double size    = (InpAccountSize > 0.0 ? InpAccountSize : balance);

   if(size <= 0.0 || InpDailyLossPct <= 0.0 || InpSafetyPct <= 0.0 || InpSafetyPct > 100.0)
     {
      Alert("Weekend Gap Check: check the inputs (account size, daily loss %, safety %).");
      return;
     }

   double dailyLimit = size * InpDailyLossPct / 100.0;
   double floating   = equity - balance;
   double carried    = (InpFloatCounts && floating < 0.0 ? -floating : 0.0);
   double room       = dailyLimit - carried;
   double allowed    = room * InpSafetyPct / 100.0;

   string lines[];
   int    nl = 0;
   ArrayResize(lines, 0);

   int    total   = PositionsTotal();
   double sumLoss = 0.0;
   int    unknown = 0;

   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      string sym   = PositionGetString(POSITION_SYMBOL);
      double lots  = PositionGetDouble(POSITION_VOLUME);
      double price = PositionGetDouble(POSITION_PRICE_CURRENT);
      bool   buy   = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      double gap   = 0.0;
      string grp   = GroupOf(sym, gap);
      double loss  = GapLoss(sym, lots, price, gap);

      string row = Pad(sym, 12) + Pad((buy ? "BUY " : "SELL") + " " + DoubleToString(lots, 2), 12) +
                   Pad(grp + " " + DoubleToString(gap, 1) + "%", 16);
      if(loss < 0.0)
        {
         unknown++;
         row += "cannot be measured (no tick value)";
        }
      else
        {
         sumLoss += loss;
         row += "-" + DoubleToString(loss, 2) + " " + ccy;
        }
      ArrayResize(lines, nl + 1);
      lines[nl++] = row;
     }

   string head = "WEEKEND GAP CHECK  (it only reads the account)\n";
   head += StringFormat("Daily limit of the next day: %.2f %s (%.1f%% of %.2f)\n",
                        dailyLimit, ccy, InpDailyLossPct, size);
   if(carried > 0.0)
      head += StringFormat("Floating loss you carry over: -%.2f %s, already counted against it\n", carried, ccy);
   head += StringFormat("Room: %.2f %s   usable with %.0f%% safety: %.2f %s\n",
                        room, ccy, InpSafetyPct, allowed, ccy);
   head += "\n";

   string body = "";
   for(int k = 0; k < nl; k++)
      body += lines[k] + "\n";

   string verdict;
   if(total == 0)
      verdict = "No open positions: nothing can gap against you.";
   else if(room <= 0.0)
      verdict = "The floating loss already uses all the room of the next day. Any gap breaks the limit.";
   else if(sumLoss <= allowed)
      verdict = StringFormat("OK: a gap on all positions would cost about -%.2f %s, inside the usable room (it uses %.0f%% of the room).",
                             sumLoss, ccy, sumLoss / room * 100.0);
   else
     {
      double keep = (sumLoss > 0.0 ? allowed / sumLoss : 0.0);
      verdict = StringFormat("TOO MUCH: a gap on all positions would cost about -%.2f %s, more than the usable room %.2f %s.\n"
                             "Reduce every position to about %.0f%% of its size before the close, or close the largest ones.\n"
                             "A stop loss does not protect you from a gap: it is filled at the first price after the gap.",
                             sumLoss, ccy, allowed, ccy, keep * 100.0);
     }
   if(unknown > 0)
      verdict += StringFormat("\n%d position(s) could not be measured: check them by hand.", unknown);

   string text = head + body + "\n" + verdict;
   Comment(text);
   Print(text);
   Alert("Weekend Gap Check: ", verdict);
  }
//+------------------------------------------------------------------+
