//+------------------------------------------------------------------+
//|                                        BasketProtectiveClose.mq5 |
//|                                                       Judi Gosal |
//|                https://www.mql5.com/en/users/priscilla_william2  |
//+------------------------------------------------------------------+
#property copyright "Judi Gosal"
#property link      "https://www.mql5.com/en/users/priscilla_william2"
#property version   "1.00"
#property description "Closes a basket of positions when its floating loss reaches a limit."
#property description "The limit can be fixed money, a percent of balance or a percent of equity."
#property description "Optional profit target. Filter by symbol or magic numbers. One shot or re-arm."

#include <Trade/Trade.mqh>

enum ENUM_LIMIT_MODE
  {
   LIMIT_MONEY       = 0,  // Fixed money
   LIMIT_PCT_BALANCE = 1,  // Percent of balance
   LIMIT_PCT_EQUITY  = 2   // Percent of equity
  };

enum ENUM_SCOPE
  {
   SCOPE_ALL    = 0,       // All positions on the account
   SCOPE_SYMBOL = 1,       // Current chart symbol only
   SCOPE_MAGIC  = 2        // Magic numbers from the list
  };

enum ENUM_PROFIT_MODE
  {
   PROFIT_OFF         = 0, // Off
   PROFIT_MONEY       = 1, // Fixed money
   PROFIT_PCT_BALANCE = 2  // Percent of balance
  };

input group "Loss limit"
input ENUM_LIMIT_MODE  InpLossMode        = LIMIT_PCT_BALANCE; // Loss limit type
input double           InpLossValue       = 2.0;               // Loss limit value (money or percent)
input group "Profit target"
input ENUM_PROFIT_MODE InpProfitMode      = PROFIT_OFF;        // Profit target type
input double           InpProfitValue     = 0.0;               // Profit target value (money or percent)
input group "Which positions count"
input ENUM_SCOPE       InpScope           = SCOPE_ALL;         // Scope
input string           InpMagicList       = "0";               // Magic numbers, comma separated (0 = manual trades)
input group "Behaviour"
input bool             InpOneShot         = false;             // Stop monitoring after first trigger
input int              InpDeviationPoints = 20;                // Max deviation on close (points)
input group "Notifications"
input bool             InpAlertPopup      = true;              // Alert window on trigger
input bool             InpPushNotify      = false;             // Push notification on trigger

// sweeps run on the 500 ms timer only, so this is a 20 second retry window
#define MAX_CLOSE_SWEEPS 40

CTrade  trade;
long    g_magics[];
ulong   g_basket[];         // tickets captured at trigger time, the only ones ever closed
bool    g_armed        = true;
bool    g_closing      = false;
int     g_sweeps       = 0;
int     g_triggers     = 0;
string  g_trigger_why  = "";

//+------------------------------------------------------------------+
//| Initialization. Also runs on input change, which is the          |
//| deliberate way to re-arm after a stop.                           |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_armed       = true;
   g_closing     = false;
   g_sweeps      = 0;
   g_trigger_why = "";

   if(InpLossValue <= 0.0)
     {
      Print("Basket Protective Close: loss limit value must be above zero.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpProfitMode != PROFIT_OFF && InpProfitValue <= 0.0)
     {
      Print("Basket Protective Close: profit target value must be above zero when the target is on.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpScope == SCOPE_MAGIC && !ParseMagicList())
      return(INIT_PARAMETERS_INCORRECT);

   trade.SetDeviationInPoints((ulong)MathMax(InpDeviationPoints, 0));
   trade.SetAsyncMode(false);

   // never liquidate blind on attach: if the limit is already breached,
   // start disarmed and let the user confirm by re-applying the inputs
   int count = 0;
   double pl = BasketFloating(count);
   if(count > 0 && pl <= -LossLimitMoney())
     {
      g_armed = false;
      string msg = StringFormat("Basket Protective Close: floating result %.2f is already beyond the limit -%.2f. Started disarmed. Review the inputs and press OK to arm.",
                                pl, LossLimitMoney());
      Print(msg);
      Alert(msg);
      if(InpPushNotify)
         SendNotification(msg);
     }

   EventSetMillisecondTimer(500);
   UpdatePanel(count, pl);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Comment("");
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   Check(false);
  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   Check(true);
  }
//+------------------------------------------------------------------+
//| Read the comma separated magic list into g_magics. A token that  |
//| is not pure digits rejects the whole list: StringToInteger would |
//| silently turn a typo into magic 0, which is the manual trades    |
//| bucket, and this tool closes real positions.                     |
//+------------------------------------------------------------------+
bool ParseMagicList()
  {
   string parts[];
   int n = StringSplit(InpMagicList, ',', parts);
   ArrayResize(g_magics, 0);
   for(int i = 0; i < n; i++)
     {
      string s = parts[i];
      StringTrimLeft(s);
      StringTrimRight(s);
      if(s == "")
         continue;
      for(int j = 0; j < StringLen(s); j++)
        {
         ushort c = StringGetCharacter(s, j);
         if(c < '0' || c > '9')
           {
            Print("Basket Protective Close: '", s, "' in the magic list is not a number.");
            return(false);
           }
        }
      int k = ArraySize(g_magics);
      ArrayResize(g_magics, k + 1);
      g_magics[k] = StringToInteger(s);
     }
   if(ArraySize(g_magics) == 0)
      Print("Basket Protective Close: the magic number list is empty.");
   return(ArraySize(g_magics) > 0);
  }
//+------------------------------------------------------------------+
//| Does the currently selected position belong to the basket        |
//+------------------------------------------------------------------+
bool InScope()
  {
   switch(InpScope)
     {
      case SCOPE_ALL:
         return(true);
      case SCOPE_SYMBOL:
         return(PositionGetString(POSITION_SYMBOL) == _Symbol);
      case SCOPE_MAGIC:
        {
         long magic = PositionGetInteger(POSITION_MAGIC);
         for(int i = 0; i < ArraySize(g_magics); i++)
            if(g_magics[i] == magic)
               return(true);
         return(false);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Floating result of the basket. Profit plus swap of every         |
//| matching position. Deal commission is not available from an open |
//| position, so raw spread accounts should set the limit with that  |
//| in mind.                                                         |
//+------------------------------------------------------------------+
double BasketFloating(int &count)
  {
   double pl = 0.0;
   count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !InScope())
         continue;
      pl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      count++;
     }
   return(pl);
  }
//+------------------------------------------------------------------+
//| Loss limit in account money                                      |
//+------------------------------------------------------------------+
double LossLimitMoney()
  {
   switch(InpLossMode)
     {
      case LIMIT_MONEY:
         return(InpLossValue);
      case LIMIT_PCT_BALANCE:
         return(AccountInfoDouble(ACCOUNT_BALANCE) * InpLossValue / 100.0);
      case LIMIT_PCT_EQUITY:
         return(AccountInfoDouble(ACCOUNT_EQUITY) * InpLossValue / 100.0);
     }
   return(InpLossValue);
  }
//+------------------------------------------------------------------+
//| Profit target in account money, 0 when the target is off         |
//+------------------------------------------------------------------+
double ProfitTargetMoney()
  {
   switch(InpProfitMode)
     {
      case PROFIT_OFF:
         return(0.0);
      case PROFIT_MONEY:
         return(InpProfitValue);
      case PROFIT_PCT_BALANCE:
         return(AccountInfoDouble(ACCOUNT_BALANCE) * InpProfitValue / 100.0);
     }
   return(0.0);
  }
//+------------------------------------------------------------------+
//| Main check. Triggers are detected on every tick and timer event, |
//| but retry sweeps run from the timer only, so the retry window    |
//| does not depend on how fast the chart symbol ticks.              |
//+------------------------------------------------------------------+
void Check(const bool from_timer)
  {
   int count = 0;
   double pl = BasketFloating(count);

   if(g_closing)
     {
      if(from_timer)
         CloseSweep();
      UpdatePanel(count, pl);
      return;
     }
   if(!g_armed)
     {
      UpdatePanel(count, pl);
      return;
     }

   if(count > 0)
     {
      if(pl <= -LossLimitMoney())
         StartTrigger(StringFormat("floating loss %.2f reached the limit %.2f", pl, -LossLimitMoney()));
      else
        {
         double target = ProfitTargetMoney();
         if(target > 0.0 && pl >= target)
            StartTrigger(StringFormat("floating profit %.2f reached the target %.2f", pl, target));
        }
     }
   UpdatePanel(count, pl);
  }
//+------------------------------------------------------------------+
//| Snapshot the basket and begin closing it. Only the tickets       |
//| captured here are ever closed: positions opened by anyone after  |
//| the trigger are not touched and cannot keep the sweep alive.     |
//+------------------------------------------------------------------+
void StartTrigger(string why)
  {
   ArrayResize(g_basket, 0);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !InScope())
         continue;
      int k = ArraySize(g_basket);
      ArrayResize(g_basket, k + 1);
      g_basket[k] = ticket;
     }
   if(ArraySize(g_basket) == 0)
      return;

   g_closing     = true;
   g_sweeps      = 0;
   g_trigger_why = why;

   string msg = "Basket Protective Close: " + why + ". Closing " +
                IntegerToString(ArraySize(g_basket)) + " position(s).";
   Print(msg);
   if(InpAlertPopup)
      Alert(msg);
   if(InpPushNotify)
      SendNotification(msg);

   CloseSweep();
  }
//+------------------------------------------------------------------+
//| One pass over the snapshot. Runs again on the next timer event   |
//| until the snapshot is empty. The sweep budget is only spent on   |
//| real rejections: while the terminal cannot trade at all, or the  |
//| market is closed, the utility waits instead of giving up.        |
//+------------------------------------------------------------------+
void CloseSweep()
  {
   if(!TerminalInfoInteger(TERMINAL_CONNECTED) ||
      !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ||
      !MQLInfoInteger(MQL_TRADE_ALLOWED))
      return;

   bool hard_reject = false;

   for(int i = ArraySize(g_basket) - 1; i >= 0; i--)
     {
      if(!PositionSelectByTicket(g_basket[i]))
        {
         ArrayRemove(g_basket, i, 1);   // already gone
         continue;
        }
      trade.SetTypeFillingBySymbol(PositionGetString(POSITION_SYMBOL));
      bool sent = trade.PositionClose(g_basket[i]);
      uint rc   = trade.ResultRetcode();
      if(sent && rc == TRADE_RETCODE_DONE)
        {
         ArrayRemove(g_basket, i, 1);
         continue;
        }
      // partial close keeps its ticket, everything else is a failure
      if(rc != TRADE_RETCODE_DONE_PARTIAL)
        {
         if(rc != TRADE_RETCODE_MARKET_CLOSED)
            hard_reject = true;
         PrintFormat("Basket Protective Close: close of ticket %I64u failed, retcode %u. Will retry.",
                     g_basket[i], rc);
        }
     }

   if(ArraySize(g_basket) == 0)
     {
      g_closing = false;
      g_triggers++;
      if(InpOneShot)
         g_armed = false;
      string msg = StringFormat("Basket Protective Close: basket flat after %d sweep(s). %s",
                                g_sweeps + 1,
                                InpOneShot ? "Monitoring stopped (one shot). Change any input and press OK to re-arm." : "Re-armed.");
      Print(msg);
      if(InpPushNotify)
         SendNotification(msg);
      return;
     }

   if(hard_reject)
     {
      g_sweeps++;
      if(g_sweeps >= MAX_CLOSE_SWEEPS)
        {
         g_closing = false;
         g_armed   = false;
         string msg = StringFormat("Basket Protective Close: %d position(s) still open after %d rejected sweeps. Monitoring stopped, check the account by hand. Change any input and press OK to re-arm.",
                                   ArraySize(g_basket), g_sweeps);
         Print(msg);
         Alert(msg);
         if(InpPushNotify)
            SendNotification(msg);
        }
     }
  }
//+------------------------------------------------------------------+
//| Chart panel. Values come from the caller so the position list is |
//| scanned once per event.                                          |
//+------------------------------------------------------------------+
void UpdatePanel(const int count, const double pl)
  {
   double limit  = LossLimitMoney();
   double target = ProfitTargetMoney();

   string scope = "all positions";
   if(InpScope == SCOPE_SYMBOL)
      scope = _Symbol + " only";
   if(InpScope == SCOPE_MAGIC)
      scope = "magic list " + InpMagicList;

   string mode = "fixed money";
   if(InpLossMode == LIMIT_PCT_BALANCE)
      mode = StringFormat("%.2f%% of balance", InpLossValue);
   if(InpLossMode == LIMIT_PCT_EQUITY)
      mode = StringFormat("%.2f%% of equity", InpLossValue);

   string status = "armed";
   if(g_closing)
      status = StringFormat("closing basket, %d left: %s", ArraySize(g_basket), g_trigger_why);
   else if(!g_armed)
      status = "stopped (change any input to re-arm)";

   string text = "\nBasket Protective Close\n";
   text += StringFormat("Scope: %s | positions: %d | floating: %.2f %s\n",
                        scope, count, pl, AccountInfoString(ACCOUNT_CURRENCY));
   text += StringFormat("Loss limit: -%.2f (%s) | distance: %.2f\n",
                        limit, mode, pl + limit);
   if(target > 0.0)
      text += StringFormat("Profit target: %.2f | distance: %.2f\n", target, target - pl);
   else
      text += "Profit target: off\n";
   text += StringFormat("Status: %s | triggers: %d\n", status, g_triggers);

   Comment(text);
  }
//+------------------------------------------------------------------+
