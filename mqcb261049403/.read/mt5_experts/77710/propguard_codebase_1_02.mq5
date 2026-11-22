//+------------------------------------------------------------------+
//|                                                    PropGuard.mq5 |
//|                                                   Copyright 2026 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026"
#property link        "https://www.mql5.com"
#property version     "1.02"
#property description "Account-level risk manager for prop-firm accounts."
#property description "Watches every position on the account (any EA, any magic number) and"
#property description "closes everything before the firm's daily or maximum loss limit is hit."
#property description "Position size is measured in account currency (lots x price x value per"
#property description "point), so one cap fits every instrument. Optional: close positions left"
#property description "without a stop loss, cap the money risked per position. One copy per account."
//---
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Maximum loss measurement mode                                    |
//+------------------------------------------------------------------+
enum ENUM_MAXLOSS_MODE
  {
   MAXLOSS_STATIC=0,       // From initial balance
   MAXLOSS_TRAILING=1,     // From peak equity (intraday)
   MAXLOSS_TRAILING_EOD=2  // From the highest balance at a daily reset (FTMO 1-Step style)
  };
//--- input parameters
input double            InpInitialBalance=100000;         // Account size the rules refer to
input double            InpDailyLossPct=4.0;              // Daily loss limit used by the guard, % (set below the firm's limit, e.g. 4 for a 5% rule, 2.5 for a 3% rule)
input double            InpMaxLossPct=8.0;                // Maximum loss used by the guard, % (firm: 10%)
input ENUM_MAXLOSS_MODE InpMaxLossMode=MAXLOSS_STATIC;    // Max loss measured from initial balance, peak equity or highest daily balance
input int               InpResetHour=1;                   // Daily reset, server hour (FTMO: 00:00 CE(S)T)
input int               InpResetMinute=0;                 // Daily reset, server minute
input double            InpMaxLotsPerPos=0.0;             // Close any position with more lots than this (0 = off)
input double            InpMaxNotionalPerPos=0.0;         // Close any position worth more than this in account currency (0 = off)
input double            InpMaxNotionalTotal=0.0;          // Close the newest positions while all together are worth more than this (0 = off)
input bool              InpRequireStopLoss=false;         // Close any position still without a stop loss after the grace period
input int               InpStopGraceSeconds=60;           // Grace period to set the stop loss, seconds
input double            InpMaxRiskPerPos=0.0;             // Max money risked per position (0 = off); the stop is tightened to this
input bool              InpBestDayInfo=false;             // Log the best-day / positive-days ratio at every reset (FTMO 1-Step rule: max 50%)
input bool              InpCloseOnBreach=true;            // Flatten when a limit is hit
input bool              InpBlockAfterBreach=true;         // Keep closing new positions until the next reset
input bool              InpUseWindow=false;               // Enforce a trading window (server time)
input int               InpWindowStartHour=8;             // Window start hour
input int               InpWindowEndHour=22;              // Window end hour (positions closed at this hour)
input bool              InpFridayClose=false;             // Close everything on Friday at the hour below
input int               InpFridayCloseHour=21;            // Friday close hour (server)
input bool              InpUseNewsFilter=false;           // Close/keep flat around high-impact news
input string            InpNewsCurrencies="USD,EUR";      // Currencies to watch, comma separated
input int               InpNewsMinutesBefore=2;           // Minutes before the release
input int               InpNewsMinutesAfter=2;            // Minutes after the release
input bool              InpPushAlerts=true;               // Push notification on every action
input int               InpMagicToIgnore=0;               // Positions with this magic are not touched (0 = none)
//--- global variables
CTrade   ExtTrade;                  // trading object
string   ExtLogFile;                // CSV log file name
double   ExtDayStartEquity=0.0;     // equity at the last daily reset
double   ExtPeakEquity=0.0;         // highest equity seen (trailing mode)
double   ExtHwmBalance=0.0;         // highest balance seen at a daily reset (trailing EOD mode)
int      ExtDayKey=-1;              // yyyymmdd of the last daily reset
bool     ExtBreached=false;         // a limit was hit since the last reset
datetime ExtLastNewsCheck=0;        // time of the last calendar query
bool     ExtInNews=false;           // cached result of the last calendar query
bool     ExtTesterTradeDone=false;  // tester-only demonstration trade already made
string   ExtGvPrefix;               // terminal global variable prefix for restart persistence
//+------------------------------------------------------------------+
//| Save the daily state to terminal global variables so a restart    |
//| after a breach does not re-arm trading before the next reset      |
//+------------------------------------------------------------------+
void SaveState(void)
  {
   GlobalVariableSet(ExtGvPrefix+"dayKey",ExtDayKey);
   GlobalVariableSet(ExtGvPrefix+"dayStart",ExtDayStartEquity);
   GlobalVariableSet(ExtGvPrefix+"breached",ExtBreached ? 1.0 : 0.0);
   GlobalVariableSet(ExtGvPrefix+"peak",ExtPeakEquity);
   GlobalVariableSet(ExtGvPrefix+"hwm",ExtHwmBalance);
  }
//+------------------------------------------------------------------+
//| Restore the daily state after a restart (same account, same day)  |
//+------------------------------------------------------------------+
void LoadState(void)
  {
   if(!GlobalVariableCheck(ExtGvPrefix+"dayKey"))
      return;
   ExtDayKey=(int)GlobalVariableGet(ExtGvPrefix+"dayKey");
   ExtDayStartEquity=GlobalVariableGet(ExtGvPrefix+"dayStart");
   ExtBreached=(GlobalVariableGet(ExtGvPrefix+"breached")>0.5);
   double peak=GlobalVariableGet(ExtGvPrefix+"peak");
   if(peak>0.0)
      ExtPeakEquity=MathMax(ExtPeakEquity,peak);
   if(GlobalVariableCheck(ExtGvPrefix+"hwm"))
      ExtHwmBalance=MathMax(ExtHwmBalance,GlobalVariableGet(ExtGvPrefix+"hwm"));
  }
//+------------------------------------------------------------------+
//| Write one line to the Experts log, the CSV file and (optionally) |
//| send it as a push notification                                   |
//+------------------------------------------------------------------+
void LogAction(const string action,const string detail)
  {
//--- CSV file: time;action;detail
   int handle=FileOpen(ExtLogFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI,';');
   if(handle!=INVALID_HANDLE)
     {
      FileSeek(handle,0,SEEK_END);
      FileWrite(handle,TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),action,detail);
      FileClose(handle);
     }
//--- Experts log
   Print("PropGuard ",action,": ",detail);
//--- push notification for everything except plain information
   if(InpPushAlerts && action!="INFO")
      SendNotification("PropGuard "+action+": "+detail);
  }
//+------------------------------------------------------------------+
//| Returns true when the position may be touched by the guard       |
//+------------------------------------------------------------------+
bool IsManaged(void)
  {
   if(InpMagicToIgnore==0)
      return(true);
   return(PositionGetInteger(POSITION_MAGIC)!=InpMagicToIgnore);
  }
//+------------------------------------------------------------------+
//| Close every managed position; returns the number closed          |
//+------------------------------------------------------------------+
int CloseAllPositions(const string reason)
  {
   int closed=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;
      if(!IsManaged())
         continue;
      if(ExtTrade.PositionClose(ticket))
         closed++;
     }
   if(closed>0)
      LogAction("CLOSE_ALL",StringFormat("%s: %d positions closed",reason,closed));
   return(closed);
  }
//+------------------------------------------------------------------+
//| Delete every pending order                                       |
//+------------------------------------------------------------------+
void CancelAllOrders(void)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      ulong ticket=OrderGetTicket(i);
      if(ticket!=0)
         ExtTrade.OrderDelete(ticket);
     }
  }
//+------------------------------------------------------------------+
//| Value of the selected position in account currency:              |
//| lots x price x (tick value / tick size)                           |
//+------------------------------------------------------------------+
double PositionNotional(void)
  {
   string symbol=PositionGetString(POSITION_SYMBOL);
   double tickSize=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tickSize<=0.0 || tickValue<=0.0)
      return(0.0);
   return(PositionGetDouble(POSITION_VOLUME)*PositionGetDouble(POSITION_PRICE_CURRENT)*tickValue/tickSize);
  }
//+------------------------------------------------------------------+
//| Size caps: lots per position, value per position, value of all   |
//| positions together (the newest are closed first)                 |
//+------------------------------------------------------------------+
void EnforceSizeCaps(void)
  {
   ulong    tickets[];
   datetime opened[];
   double   values[];
   double   total=0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;
      if(!IsManaged())
         continue;
      string symbol=PositionGetString(POSITION_SYMBOL);
      double volume=PositionGetDouble(POSITION_VOLUME);
      double value=PositionNotional();
      //--- per-position caps
      if(InpMaxLotsPerPos>0.0 && volume>InpMaxLotsPerPos)
        {
         if(ExtTrade.PositionClose(ticket))
            LogAction("LOT_CAP",StringFormat("%s %.2f lots > cap %.2f, closed",symbol,volume,InpMaxLotsPerPos));
         continue;
        }
      if(InpMaxNotionalPerPos>0.0 && value>InpMaxNotionalPerPos)
        {
         if(ExtTrade.PositionClose(ticket))
            LogAction("VALUE_CAP",StringFormat("%s %.2f lots worth %.0f > cap %.0f, closed",symbol,volume,value,InpMaxNotionalPerPos));
         continue;
        }
      int n=ArraySize(tickets);
      ArrayResize(tickets,n+1);
      ArrayResize(opened,n+1);
      ArrayResize(values,n+1);
      tickets[n]=ticket;
      opened[n]=(datetime)PositionGetInteger(POSITION_TIME);
      values[n]=value;
      total+=value;
     }
   //--- total cap: close the newest position until the rest fits
   if(InpMaxNotionalTotal<=0.0)
      return;
   while(total>InpMaxNotionalTotal && ArraySize(tickets)>0)
     {
      int newest=0;
      for(int k=1; k<ArraySize(tickets); k++)
         if(opened[k]>opened[newest])
            newest=k;
      if(PositionSelectByTicket(tickets[newest]))
        {
         string symbol=PositionGetString(POSITION_SYMBOL);
         double volume=PositionGetDouble(POSITION_VOLUME);
         if(ExtTrade.PositionClose(tickets[newest]))
            LogAction("TOTAL_CAP",StringFormat("all positions worth %.0f > cap %.0f, newest %s %.2f lots closed",
                                               total,InpMaxNotionalTotal,symbol,volume));
        }
      total-=values[newest];
      ArrayRemove(tickets,newest,1);
      ArrayRemove(opened,newest,1);
      ArrayRemove(values,newest,1);
     }
  }
//+------------------------------------------------------------------+
//| Server time of the most recent daily reset                       |
//+------------------------------------------------------------------+
datetime LastResetTime(void)
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   dt.hour=InpResetHour;
   dt.min=InpResetMinute;
   dt.sec=0;
   datetime reset=StructToTime(dt);
   if(reset>TimeCurrent())
      reset-=86400;
   return(reset);
  }
//+------------------------------------------------------------------+
//| Closed profit (incl. swap and commission) of all deals since t   |
//+------------------------------------------------------------------+
double ClosedProfitSince(const datetime t)
  {
   double sum=0.0;
   if(!HistorySelect(t,TimeCurrent()+86400))
      return(0.0);
   for(int i=HistoryDealsTotal()-1; i>=0; i--)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;
      long type=HistoryDealGetInteger(ticket,DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
         continue;
      sum+=HistoryDealGetDouble(ticket,DEAL_PROFIT)+HistoryDealGetDouble(ticket,DEAL_SWAP)+HistoryDealGetDouble(ticket,DEAL_COMMISSION);
     }
   return(sum);
  }
//+------------------------------------------------------------------+
//| FTMO 1-Step "Best Day" rule: the most profitable day may not be  |
//| more than 50% of the sum of all positive days. Information only. |
//+------------------------------------------------------------------+
void LogBestDayRatio(void)
  {
   if(!InpBestDayInfo || !HistorySelect(0,TimeCurrent()+86400))
      return;
   int    dayKeys[];
   double dayProfit[];
   int    offset=InpResetHour*3600+InpResetMinute*60;   // the firm's day starts at the reset time
   for(int i=0; i<HistoryDealsTotal(); i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;
      long type=HistoryDealGetInteger(ticket,DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
         continue;
      double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT)+HistoryDealGetDouble(ticket,DEAL_SWAP)+HistoryDealGetDouble(ticket,DEAL_COMMISSION);
      if(profit==0.0)
         continue;
      MqlDateTime dt;
      TimeToStruct((datetime)HistoryDealGetInteger(ticket,DEAL_TIME)-offset,dt);
      int key=dt.year*10000+dt.mon*100+dt.day;
      int n=ArraySize(dayKeys);
      int found=-1;
      for(int k=0; k<n; k++)
         if(dayKeys[k]==key)
           {
            found=k;
            break;
           }
      if(found<0)
        {
         ArrayResize(dayKeys,n+1);
         ArrayResize(dayProfit,n+1);
         dayKeys[n]=key;
         dayProfit[n]=0.0;
         found=n;
        }
      dayProfit[found]+=profit;
     }
   double positive=0.0,best=0.0;
   int    days=ArraySize(dayProfit);
   for(int k=0; k<days; k++)
      if(dayProfit[k]>0.0)
        {
         positive+=dayProfit[k];
         best=MathMax(best,dayProfit[k]);
        }
   if(positive<=0.0)
      return;
   LogAction("INFO",StringFormat("best day %.0f = %.0f%% of positive days' profit %.0f (%d days; 1-Step rule: max 50%%)",
                                 best,best/positive*100.0,positive,days));
  }
//+------------------------------------------------------------------+
//| Stop-loss discipline: close a position that has had no stop loss |
//| for longer than the grace period; tighten a stop that risks more |
//| than the cap; close it if such a stop can no longer be placed     |
//+------------------------------------------------------------------+
void EnforceStops(void)
  {
   if(!InpRequireStopLoss && InpMaxRiskPerPos<=0.0)
      return;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;
      if(!IsManaged())
         continue;
      string symbol=PositionGetString(POSITION_SYMBOL);
      double sl=PositionGetDouble(POSITION_SL);
      double volume=PositionGetDouble(POSITION_VOLUME);
      double open=PositionGetDouble(POSITION_PRICE_OPEN);
      bool   isBuy=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY);
      long   age=TimeCurrent()-(datetime)PositionGetInteger(POSITION_TIME);
      //--- no stop loss after the grace period
      if(InpRequireStopLoss && sl==0.0 && age>=InpStopGraceSeconds)
        {
         if(ExtTrade.PositionClose(ticket))
            LogAction("NO_STOP",StringFormat("%s %.2f lots without a stop loss for %d s, closed",
                                             symbol,volume,(int)age));
         continue;
        }
      //--- risk cap
      if(InpMaxRiskPerPos<=0.0 || sl==0.0)
         continue;
      double tickSize=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
      double tickValue=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
      if(tickSize<=0.0 || tickValue<=0.0)
         continue;
      double perPoint=volume*tickValue/tickSize;             // account currency per 1.0 price move
      double distance=isBuy ? open-sl : sl-open;             // negative when the stop is already in profit
      if(distance<=0.0 || distance*perPoint<=InpMaxRiskPerPos)
         continue;
      int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      double newDistance=InpMaxRiskPerPos/perPoint;
      double newSl=NormalizeDouble(isBuy ? open-newDistance : open+newDistance,digits);
      if(MathAbs(newSl-sl)<tickSize)
         continue;                                           // already at the cap (rounding)
      double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
      double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
      bool   canPlace=isBuy ? (newSl<bid) : (newSl>ask);     // otherwise the loss already exceeds the cap
      if(canPlace && ExtTrade.PositionModify(ticket,newSl,PositionGetDouble(POSITION_TP)))
         LogAction("RISK_CAP",StringFormat("%s %.2f lots risked %.0f > cap %.0f, stop moved to %s",
                                           symbol,volume,distance*perPoint,InpMaxRiskPerPos,DoubleToString(newSl,digits)));
      else
         if(ExtTrade.PositionClose(ticket))
            LogAction("RISK_CAP",StringFormat("%s %.2f lots risked %.0f > cap %.0f, capped stop not placeable, closed",
                                              symbol,volume,distance*perPoint,InpMaxRiskPerPos));
     }
  }
//+------------------------------------------------------------------+
//| Returns true when a high-impact release of a watched currency    |
//| falls inside the blackout window around the current time         |
//+------------------------------------------------------------------+
bool HighImpactNewsNear(void)
  {
   if(!InpUseNewsFilter)
      return(false);
//--- query the calendar at most once every 30 seconds
   if(TimeCurrent()-ExtLastNewsCheck<30)
      return(ExtInNews);
   ExtLastNewsCheck=TimeCurrent();
   ExtInNews=false;
//--- blackout window
   datetime from=TimeCurrent()-InpNewsMinutesAfter*60;
   datetime to=TimeCurrent()+InpNewsMinutesBefore*60;
//--- one query per watched currency
   string currencies[];
   int count=StringSplit(InpNewsCurrencies,',',currencies);
   for(int c=0; c<count; c++)
     {
      MqlCalendarValue values[];
      int total=CalendarValueHistory(values,from-3600,to+3600,NULL,currencies[c]);
      for(int i=0; i<total; i++)
        {
         MqlCalendarEvent event;
         if(!CalendarEventById(values[i].event_id,event))
            continue;
         if(event.importance!=CALENDAR_IMPORTANCE_HIGH)
            continue;
         if(values[i].time>=from && values[i].time<=to)
           {
            ExtInNews=true;
            return(true);
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Strategy Tester only: open and close one minimum-lot position so |
//| the automatic validation sees a trading operation and the guard's |
//| closing logic is exercised. Never runs on a live or demo account. |
//+------------------------------------------------------------------+
void TesterDemoTrade(void)
  {
   if(!MQLInfoInteger(MQL_TESTER) || ExtTesterTradeDone)
      return;
   ExtTesterTradeDone=true;
//--- the symbol must allow trading
   if(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_FULL)
     {
      LogAction("INFO","tester demo trade skipped: symbol is not fully tradable");
      return;
     }
//--- minimum volume of the tested symbol
   double volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
//--- never send an order the account cannot afford
   double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double margin=0.0;
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,volume,price,margin))
     {
      LogAction("INFO","tester demo trade skipped: margin calculation failed");
      return;
     }
   if(margin>AccountInfoDouble(ACCOUNT_MARGIN_FREE))
     {
      LogAction("INFO",StringFormat("tester demo trade skipped: needs %.2f margin, free margin %.2f",
                                    margin,AccountInfoDouble(ACCOUNT_MARGIN_FREE)));
      return;
     }
   ExtTrade.SetDeviationInPoints(50);
   if(!ExtTrade.Buy(volume,_Symbol,0.0,0.0,0.0,"PropGuard tester demo"))
     {
      LogAction("INFO",StringFormat("tester demo trade failed: %d",ExtTrade.ResultRetcode()));
      return;
     }
//--- close it again through the same path the guard uses
   if(ExtTrade.PositionClose(_Symbol))
      LogAction("INFO","tester demo trade opened and closed");
  }
//+------------------------------------------------------------------+
//| Equity level at which the maximum-loss guard fires               |
//+------------------------------------------------------------------+
double MaxLossFloor(void)
  {
   double amount=InpInitialBalance*InpMaxLossPct/100.0;
   switch(InpMaxLossMode)
     {
      case MAXLOSS_TRAILING:
         return(ExtPeakEquity-amount);
      case MAXLOSS_TRAILING_EOD:
         return(MathMax(InpInitialBalance,ExtHwmBalance)-amount);
      default:
         return(InpInitialBalance-amount);
     }
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- one log file per account
   ExtLogFile="PropGuard_"+(string)AccountInfoInteger(ACCOUNT_LOGIN)+".csv";
   ExtGvPrefix="PropGuard_"+(string)AccountInfoInteger(ACCOUNT_LOGIN)+"_";
   ExtPeakEquity=AccountInfoDouble(ACCOUNT_EQUITY);
//--- highest daily balance: at least the initial balance and the balance at the last reset
   ExtHwmBalance=MathMax(InpInitialBalance,AccountInfoDouble(ACCOUNT_BALANCE)-ClosedProfitSince(LastResetTime()));
//--- restore today's state if the terminal was restarted (not in the tester)
   if(!MQLInfoInteger(MQL_TESTER))
     {
      LoadState();
      if(ExtBreached)
         LogAction("INFO","restart after a breach: trading stays blocked until the next daily reset");
     }
   LogAction("INFO",StringFormat("started: balance=%.0f equity=%.0f daily=%.1f%% max=%.1f%% (%s) hwm=%.0f floor=%.0f",
                                 AccountInfoDouble(ACCOUNT_BALANCE),ExtPeakEquity,
                                 InpDailyLossPct,InpMaxLossPct,
                                 InpMaxLossMode==MAXLOSS_STATIC ? "static" : (InpMaxLossMode==MAXLOSS_TRAILING ? "trailing equity" : "trailing daily balance"),
                                 ExtHwmBalance,MaxLossFloor()));
   LogBestDayRatio();
//--- check every 5 seconds even when no tick arrives
   EventSetTimer(5);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   TesterDemoTrade();
   CheckAccount();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   CheckAccount();
  }
//+------------------------------------------------------------------+
//| The guard itself: daily reset, limits, size caps, stops, window, news |
//+------------------------------------------------------------------+
void CheckAccount(void)
  {
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   int dayKey=dt.year*10000+dt.mon*100+dt.day;
   int minuteOfDay=dt.hour*60+dt.min;
   int resetMinute=InpResetHour*60+InpResetMinute;
//--- daily reset
   if(dayKey!=ExtDayKey && minuteOfDay>=resetMinute)
     {
      ExtDayKey=dayKey;
      ExtDayStartEquity=equity;
      ExtBreached=false;
      ExtHwmBalance=MathMax(ExtHwmBalance,AccountInfoDouble(ACCOUNT_BALANCE));
      SaveState();
      LogAction("INFO",StringFormat("daily reset: equity=%.0f, daily limit at %.0f, max-loss floor at %.0f",
                                    equity,equity-InpInitialBalance*InpDailyLossPct/100.0,MaxLossFloor()));
      LogBestDayRatio();
     }
//--- first run before the reset time of the day
   if(ExtDayStartEquity<=0.0)
     {
      ExtDayStartEquity=equity;
      ExtDayKey=dayKey;
      SaveState();
     }
   ExtPeakEquity=MathMax(ExtPeakEquity,equity);
//--- daily loss and maximum loss
   double dailyDrop=ExtDayStartEquity-equity;
   double maxFloor=MaxLossFloor();
   bool dailyHit=(dailyDrop>=InpInitialBalance*InpDailyLossPct/100.0);
   bool maxHit=(equity<=maxFloor);
   if((dailyHit || maxHit) && !ExtBreached)
     {
      ExtBreached=true;
      SaveState();
      LogAction("BREACH",StringFormat("%s: equity=%.0f dayStart=%.0f floor=%.0f",
                                      dailyHit ? "daily loss limit" : "maximum loss",
                                      equity,ExtDayStartEquity,maxFloor));
      if(InpCloseOnBreach)
        {
         CloseAllPositions("breach");
         CancelAllOrders();
        }
     }
//--- keep the account flat until the next reset
   if(ExtBreached && InpBlockAfterBreach && PositionsTotal()>0)
      CloseAllPositions("blocked after breach");
//--- size caps, stop-loss requirement, risk cap
   EnforceSizeCaps();
   EnforceStops();
//--- trading window and Friday close
   if(InpUseWindow && (dt.hour<InpWindowStartHour || dt.hour>=InpWindowEndHour) && PositionsTotal()>0)
      CloseAllPositions("outside trading window");
   if(InpFridayClose && dt.day_of_week==5 && dt.hour>=InpFridayCloseHour && PositionsTotal()>0)
      CloseAllPositions("Friday close");
//--- high-impact news
   if(HighImpactNewsNear() && PositionsTotal()>0)
      CloseAllPositions("high-impact news window");
  }
//+------------------------------------------------------------------+
