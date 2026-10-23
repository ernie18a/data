//+------------------------------------------------------------------+
//|                                           SafeRiskManagerEA.mq5  |
//|                         Original educational CodeBase example    |
//+------------------------------------------------------------------+
#property copyright "2026"
#property version   "1.02"
#property strict
#property description "Risk-based Buy/Sell panel with daily-loss, spread, break-even and trailing-stop protection."

#include <Trade/Trade.mqh>

input group "Trade settings"
input ulong  InpMagicNumber        = 26090501;
input double InpRiskPercent        = 1.00;
input int    InpStopLossPoints     = 500;
input int    InpTakeProfitPoints   = 1000;
input int    InpMaxSpreadPoints    = 80;
input int    InpDeviationPoints    = 20;

input group "Account protection"
input double InpDailyLossPercent   = 3.00;
input bool   InpIncludeFloatingPnL = true;
input bool   InpCloseAtDailyLimit  = false;

input group "Position management"
input bool   InpUseBreakEven       = true;
input int    InpBreakEvenTrigger   = 500;
input int    InpBreakEvenOffset    = 20;
input bool   InpUseTrailingStop    = true;
input int    InpTrailStartPoints   = 700;
input int    InpTrailDistance      = 350;

input group "Panel"
input ENUM_BASE_CORNER InpCorner   = CORNER_LEFT_UPPER;
input int    InpPanelX             = 15;
input int    InpPanelY             = 25;

CTrade trade;
string prefix = "SRM_";
bool daily_lock = false;
string daily_lock_key = "";

//+------------------------------------------------------------------+
int OnInit()
{
   // Separate position ownership is required: netting can merge other trades.
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Print("This educational EA requires a hedging account. Netting is not supported.");
      return INIT_FAILED;
   }
   if(InpRiskPercent <= 0.0 || InpStopLossPoints <= 0 ||
      InpDailyLossPercent <= 0.0)
   {
      Print("Invalid risk, stop-loss or daily-loss input.");
      return INIT_PARAMETERS_INCORRECT;
   }

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpDeviationPoints);
   trade.SetTypeFillingBySymbol(_Symbol);
   daily_lock_key=StringFormat("SRM_LOCK_%I64d_%I64d_%s",
                               AccountInfoInteger(ACCOUNT_LOGIN),
                               (long)InpMagicNumber,_Symbol);
   daily_lock=DailyLossReached();
   CreatePanel();
   RefreshPanel();
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0,prefix);
   ChartRedraw();
}

//+------------------------------------------------------------------+
void OnTick()
{
   const bool was_locked=daily_lock;
   daily_lock=DailyLossReached();

   if(daily_lock && !was_locked)
   {
      Print("Daily loss limit reached. New entries are locked.");
      if(InpCloseAtDailyLimit)
         CloseManagedPositions();
   }

   ManagePositions();
   RefreshPanel();
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,
                  const string &sparam)
{
   if(id!=CHARTEVENT_OBJECT_CLICK)
      return;

   if(sparam==prefix+"BUY")
      OpenTrade(ORDER_TYPE_BUY);
   else if(sparam==prefix+"SELL")
      OpenTrade(ORDER_TYPE_SELL);
   else if(sparam==prefix+"CLOSE")
      CloseManagedPositions();

   ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
   ChartRedraw();
}

//+------------------------------------------------------------------+
void OpenTrade(const ENUM_ORDER_TYPE order_type)
{
   daily_lock=DailyLossReached();
   if(daily_lock)
   {
      Alert("Daily loss protection is active. Entry blocked.");
      return;
   }

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;

   const double spread=(tick.ask-tick.bid)/_Point;
   if(spread>InpMaxSpreadPoints)
   {
      Alert("Spread filter blocked entry: ",DoubleToString(spread,1)," points");
      return;
   }

   const double volume=CalculateRiskVolume(InpStopLossPoints);
   if(volume<=0.0)
   {
      Alert("Unable to calculate a valid trade volume.");
      return;
   }

   const int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   const double price=(order_type==ORDER_TYPE_BUY ? tick.ask : tick.bid);
   double sl=(order_type==ORDER_TYPE_BUY ? price-InpStopLossPoints*_Point
                                         : price+InpStopLossPoints*_Point);
   double tp=0.0;
   if(InpTakeProfitPoints>0)
      tp=(order_type==ORDER_TYPE_BUY ? price+InpTakeProfitPoints*_Point
                                     : price-InpTakeProfitPoints*_Point);

   sl=NormalizeDouble(sl,digits);
   tp=NormalizeDouble(tp,digits);

   bool ok=false;
   if(order_type==ORDER_TYPE_BUY)
      ok=trade.Buy(volume,_Symbol,0.0,sl,tp,"Safe Risk Manager");
   else
      ok=trade.Sell(volume,_Symbol,0.0,sl,tp,"Safe Risk Manager");

   if(!ok)
      Print("Entry failed. Retcode=",trade.ResultRetcode()," ",trade.ResultRetcodeDescription());
}

//+------------------------------------------------------------------+
double CalculateRiskVolume(const int stop_points)
{
   const double risk_money=AccountInfoDouble(ACCOUNT_EQUITY)*InpRiskPercent/100.0;
   const double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   const double tick_value=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
   const double volume_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   const double volume_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   const double volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(risk_money<=0.0 || tick_size<=0.0 || tick_value<=0.0 || volume_step<=0.0)
      return 0.0;

   const double loss_per_lot=(stop_points*_Point/tick_size)*tick_value;
   if(loss_per_lot<=0.0)
      return 0.0;

   double volume=MathFloor((risk_money/loss_per_lot)/volume_step)*volume_step;
   // Never force the broker minimum when it exceeds the requested risk.
   if(volume<volume_min)
      return 0.0;
   volume=MathMin(volume_max,volume);
   return NormalizeDouble(volume,VolumeDigits(volume_step));
}

//+------------------------------------------------------------------+
int VolumeDigits(double step)
{
   int digits=0;
   while(digits<8 && MathAbs(step-NormalizeDouble(step,digits))>1e-10)
      digits++;
   return digits;
}

//+------------------------------------------------------------------+
datetime StartOfServerDay()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(),dt);
   dt.hour=0;
   dt.min=0;
   dt.sec=0;
   return StructToTime(dt);
}

//+------------------------------------------------------------------+
double TodaysPnL()
{
   double pnl=0.0;
   if(HistorySelect(StartOfServerDay(),TimeCurrent()))
   {
      const int total=HistoryDealsTotal();
      for(int i=0;i<total;i++)
      {
         const ulong ticket=HistoryDealGetTicket(i);
         if(ticket==0)
            continue;
         const ENUM_DEAL_TYPE type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
         if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
            continue;
         pnl+=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         pnl+=HistoryDealGetDouble(ticket,DEAL_SWAP);
         pnl+=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         pnl+=HistoryDealGetDouble(ticket,DEAL_FEE);
      }
   }

   if(InpIncludeFloatingPnL)
      pnl+=AccountInfoDouble(ACCOUNT_PROFIT);
   return pnl;
}

//+------------------------------------------------------------------+
bool DailyLossReached()
{
   const datetime day=StartOfServerDay();
   if(daily_lock_key!="" && GlobalVariableCheck(daily_lock_key))
   {
      const datetime locked_day=(datetime)GlobalVariableGet(daily_lock_key);
      if(locked_day==day)
         return true;
      GlobalVariableDel(daily_lock_key);
   }

   const double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance<=0.0)
      return true;
   const bool reached=TodaysPnL()<=-(balance*InpDailyLossPercent/100.0);
   if(reached && daily_lock_key!="")
      GlobalVariableSet(daily_lock_key,(double)day);
   return reached;
}

//+------------------------------------------------------------------+
void ManagePositions()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;
   const int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || PositionGetInteger(POSITION_MAGIC)!=(long)InpMagicNumber ||
         PositionGetString(POSITION_SYMBOL)!=_Symbol)
         continue;

      const ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      const double open=PositionGetDouble(POSITION_PRICE_OPEN);
      const double old_sl=PositionGetDouble(POSITION_SL);
      const double tp=PositionGetDouble(POSITION_TP);
      const double current=(type==POSITION_TYPE_BUY ? tick.bid : tick.ask);
      const double profit_points=(type==POSITION_TYPE_BUY ? current-open : open-current)/_Point;
      double new_sl=old_sl;

      if(InpUseBreakEven && profit_points>=InpBreakEvenTrigger)
      {
         const double be=(type==POSITION_TYPE_BUY ? open+InpBreakEvenOffset*_Point
                                                  : open-InpBreakEvenOffset*_Point);
         if(BetterStop(type,be,new_sl))
            new_sl=be;
      }

      if(InpUseTrailingStop && profit_points>=InpTrailStartPoints)
      {
         const double trail=(type==POSITION_TYPE_BUY ? current-InpTrailDistance*_Point
                                                     : current+InpTrailDistance*_Point);
         if(BetterStop(type,trail,new_sl))
            new_sl=trail;
      }

      new_sl=NormalizeDouble(new_sl,digits);
      if(new_sl>0.0 && MathAbs(new_sl-old_sl)>=_Point)
      {
         if(!trade.PositionModify(ticket,new_sl,tp))
            Print("Stop update failed for #",ticket,". ",trade.ResultRetcodeDescription());
      }
   }
}

//+------------------------------------------------------------------+
bool BetterStop(const ENUM_POSITION_TYPE type,const double candidate,const double current)
{
   if(current==0.0)
      return true;
   if(type==POSITION_TYPE_BUY)
      return candidate>current;
   return candidate<current;
}

//+------------------------------------------------------------------+
void CloseManagedPositions()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || PositionGetInteger(POSITION_MAGIC)!=(long)InpMagicNumber ||
         PositionGetString(POSITION_SYMBOL)!=_Symbol)
         continue;
      if(!trade.PositionClose(ticket))
         Print("Close failed for #",ticket,". ",trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
void CreatePanel()
{
   CreateLabel(prefix+"TITLE","SAFE RISK MANAGER",InpPanelX,InpPanelY,clrWhite,11);
   CreateLabel(prefix+"STATUS","",InpPanelX,InpPanelY+24,clrSilver,9);
   CreateButton(prefix+"BUY","BUY",InpPanelX,InpPanelY+52,75,26,clrWhite,clrSeaGreen);
   CreateButton(prefix+"SELL","SELL",InpPanelX+82,InpPanelY+52,75,26,clrWhite,clrFireBrick);
   CreateButton(prefix+"CLOSE","CLOSE EA TRADES",InpPanelX,InpPanelY+84,157,26,clrWhite,clrSlateGray);
}

//+------------------------------------------------------------------+
void RefreshPanel()
{
   MqlTick tick;
   double spread=0.0;
   if(SymbolInfoTick(_Symbol,tick))
      spread=(tick.ask-tick.bid)/_Point;
   const string status=(daily_lock ? "LOCKED" : "READY");
   const string line=status+" | Spread "+DoubleToString(spread,1)+
                     " | Day P/L "+DoubleToString(TodaysPnL(),2);
   ObjectSetString(0,prefix+"STATUS",OBJPROP_TEXT,line);
   ObjectSetInteger(0,prefix+"STATUS",OBJPROP_COLOR,daily_lock ? clrTomato : clrLightGreen);
}

//+------------------------------------------------------------------+
void CreateLabel(const string name,const string text,const int x,const int y,
                 const color clr,const int size)
{
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
}

//+------------------------------------------------------------------+
void CreateButton(const string name,const string text,const int x,const int y,
                  const int width,const int height,const color text_clr,
                  const color background)
{
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_clr);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrBlack);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
}
//+------------------------------------------------------------------+
