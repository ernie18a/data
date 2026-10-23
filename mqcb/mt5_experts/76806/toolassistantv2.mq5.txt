//+------------------------------------------------------------------+
//| ToolAssistant v2.0 by tradingpulse.asia / @gold.gamers           |
//| Semi Manual Trading Assistant                                    |
//+------------------------------------------------------------------+
#property strict
#property version   "2.0"

#include <Trade/Trade.mqh>

CTrade trade;

// =========================================================
// INPUTS
// =========================================================

input group "Main"
input int      RunCheckingEverySecond = 5; //TimerSecondRun (trailing)
input double   DefaultLot             = 0.01;
input color    Label_Color            = clrDimGray;

input group "Break Even"
input bool   AutoSetBEForEmptySL = true;
input double AutoBETriggerPip    = 40;
input double BEPipsPlus           = 6;

input group "Trailing"
input bool     TrailingDefault        = true;
input double   TrailingStartPips      = 60;
input double   TrailingStepPips       = 5;

input group "Pending Order"
input double   LimitSL                = 70;
input double   LimitTP                = 80;

// =========================================================
// PANEL OBJECTS
// =========================================================

string PFX = "TPA_";

string OBJ_BTN_BUY             = PFX + "btn_buy";
string OBJ_BTN_SELL            = PFX + "btn_sell";
string OBJ_BTN_CLOSE_ALL       = PFX + "btn_close_all";
string OBJ_BTN_CLOSE_PROFIT    = PFX + "btn_close_profit";
string OBJ_BTN_CLOSE_LOSS      = PFX + "btn_close_loss";
string OBJ_BTN_TOGGLE_TRAIL    = PFX + "btn_toggle_trail";
string OBJ_BTN_SET_BE          = PFX + "btn_set_be";
string OBJ_BTN_SET_TP          = PFX + "btn_set_tp";
string OBJ_BTN_SET_SL          = PFX + "btn_set_sl";
string OBJ_BTN_BUY_PENDING     = PFX + "btn_buy_pending";
string OBJ_BTN_SELL_PENDING    = PFX + "btn_sell_pending";
string OBJ_BTN_DELETE_PENDING  = PFX + "btn_delete_pending";
string OBJ_BTN_CALC_LOT        = PFX + "btn_calc_lot";
string OBJ_BTN_CLOSE_ABOVE     = PFX + "btn_close_above";
string OBJ_BTN_CLOSE_BELOW     = PFX + "btn_close_below";

string OBJ_EDIT_LOT            = PFX + "edit_lot";
string OBJ_EDIT_ENTRIES        = PFX + "edit_entries";
string OBJ_EDIT_RISK           = PFX + "edit_risk";
string OBJ_EDIT_SL_PIP         = PFX + "edit_sl_pip";
string OBJ_EDIT_TP             = PFX + "edit_tp";
string OBJ_EDIT_SL             = PFX + "edit_sl";

string OBJ_LABEL_INFO          = PFX + "lbl_info";
string OBJ_LABEL_TRAIL         = PFX + "lbl_trail";
string OBJ_LABEL_BE            = PFX + "lbl_be";
string OBJ_LABEL_STATS         = PFX + "lbl_stats";

string OBJ_BTN_RESET            = PFX + "btn_reset";

// =========================================================
// GLOBALS
// =========================================================

int DefaultEntries = 1;
double DefaultPriceTP = 0.0;
double DefaultPriceSL = 0.0;


double CurrentLot;
int    CurrentEntries;
double CurrentPriceTP;
double CurrentPriceSL;

bool trailingEnabled = false;
double closeAbovePrice_ = 0;
double closeBelowPrice_ = 0;

double lbl_openlot = 0;
double lbl_maxloss = 0;

int PANEL_X;
int PANEL_Y;

bool panelVisible = true;

string OBJ_BTN_HIDE_PANEL = "btn_hide_panel";

void UpdatePanelPosition()
{
   int chartHeight =
      (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

   int marginRight = 130;
   int marginBottom = 100;

   int panelHeight = 310;

   // karena RIGHT_UPPER:
   PANEL_X = marginRight;

   // tinggi chart berubah
   PANEL_Y = chartHeight - panelHeight - marginBottom;

   if(PANEL_Y < 10)
      PANEL_Y = 10;
}

// Load Settings

void LoadSettings()
{
   CurrentLot =
      GlobalVariableCheck("EA_Lot")
      ? GlobalVariableGet("EA_Lot")
      : DefaultLot;

   CurrentEntries =
      GlobalVariableCheck("EA_Entries")
      ? (int)GlobalVariableGet("EA_Entries")
      : DefaultEntries;

   CurrentPriceTP =
      GlobalVariableCheck("EA_TP")
      ? GlobalVariableGet("EA_TP")
      : DefaultPriceTP;

   CurrentPriceSL =
      GlobalVariableCheck("EA_SL")
      ? GlobalVariableGet("EA_SL")
      : DefaultPriceSL;
}

// =========================================================
// INIT
// =========================================================

int OnInit()
{
   trailingEnabled = TrailingDefault;

   UpdatePanelPosition();
   
   CreateButton(OBJ_BTN_HIDE_PANEL, "Hide", 130, 35);
   CreatePanel();

   EventSetTimer(RunCheckingEverySecond);

   return(INIT_SUCCEEDED);
}

// =========================================================
// DEINIT
// =========================================================

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, PFX);
   EventKillTimer();
}

// =========================================================
// TIMER
// =========================================================

void OnTimer()
{
   ManageTrailing();
   AutoSetBEForPositionsWithoutSL();
}

// =========================================================
// CHART EVENT
// =========================================================

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(sparam == OBJ_BTN_HIDE_PANEL)
   {
      panelVisible = !panelVisible;
   
      // =========================
      // SHOW PANEL
      // =========================
   
      if(panelVisible)
      {
         UpdatePanelPosition();
   
         CreatePanel();
   
         UpdateStats();
         UpdateTrailLabel();
         UpdateBELabel();
   
         ObjectSetString(
            0,
            OBJ_BTN_HIDE_PANEL,
            OBJPROP_TEXT,
            "Hide"
         );
      }
   
      // =========================
      // HIDE PANEL
      // =========================
   
      else
      {
         ObjectsDeleteAll(0,PFX);
         CreateButton(OBJ_BTN_HIDE_PANEL, "Show", 130, 35);
      }
   
      return;
   }
   
   // selesai edit textbox
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
      if(
         sparam == OBJ_EDIT_LOT ||
         sparam == OBJ_EDIT_ENTRIES ||
         sparam == OBJ_EDIT_TP ||
         sparam == OBJ_EDIT_SL
      )
      {
         SaveSettings();
      }
   }

   if(id == CHARTEVENT_CHART_CHANGE)
   {
      ObjectsDeleteAll(0, PFX);
   
      UpdatePanelPosition();
   
      CreatePanel();
   
      UpdateStats();
      UpdateTrailLabel();
      UpdateBELabel();
   
      return;
   }

   if(id != CHARTEVENT_OBJECT_CLICK)
      return;

   if(sparam == OBJ_BTN_BUY)
      OpenPositions(true);

   if(sparam == OBJ_BTN_SELL)
      OpenPositions(false);

   if(sparam == OBJ_BTN_CLOSE_ALL)
      ClosePositions(0);

   if(sparam == OBJ_BTN_CLOSE_PROFIT)
      ClosePositions(1);

   if(sparam == OBJ_BTN_CLOSE_LOSS)
      ClosePositions(-1);

   if(sparam == OBJ_BTN_SET_TP)
      SetAllTP();

   if(sparam == OBJ_BTN_SET_SL)
      SetAllSL();

   if(sparam == OBJ_BTN_SET_BE)
      SetBreakEven();

   if(sparam == OBJ_BTN_TOGGLE_TRAIL)
   {
      trailingEnabled = !trailingEnabled;
      UpdateTrailLabel();
   }

   if(sparam == OBJ_BTN_BUY_PENDING)
      CreatePending(true);

   if(sparam == OBJ_BTN_SELL_PENDING)
      CreatePending(false);

   if(sparam == OBJ_BTN_DELETE_PENDING)
      DeleteAllPending();

   if(sparam == OBJ_BTN_CALC_LOT)
      CalculateLotFromRisk();

   if(sparam == OBJ_BTN_CLOSE_ABOVE)
   {
      string txt = ObjectGetString(0, OBJ_EDIT_TP, OBJPROP_TEXT);
      closeAbovePrice_ = StringToDouble(txt);
      CloseAbovePrice(closeAbovePrice_);
   }

   if(sparam == OBJ_BTN_CLOSE_BELOW)
   {
      string txt = ObjectGetString(0, OBJ_EDIT_SL, OBJPROP_TEXT);
      closeBelowPrice_ = StringToDouble(txt);
      CloseBelowPrice(closeBelowPrice_);
   }
   
   if(sparam == OBJ_BTN_RESET)
   {
      ResetSettings();
   }
   

   
   ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
}

// =========================================================
// PANEL
// =========================================================

void CreatePanel()
{
   //int x = 120;
   //int y = 520;
   int x = PANEL_X;
   int y = PANEL_Y;

   int gap = 50;

   CreateButton(OBJ_BTN_RESET, "# RESET #", x, y);
   
   y += gap;
   
   CreateButton(OBJ_BTN_BUY, "# BUY #", x, y);
   CreateLabel(PFX+"lotlbl", "Lot", x+110, y);
   CreateEdit(OBJ_EDIT_LOT, DoubleToString(DefaultLot,2), x+90, y, 80, 32);

   y += gap;

   CreateButton(OBJ_BTN_SELL, "# SELL #", x, y);
   CreateLabel(PFX+"entlbl", "Entries", x+110, y);
   CreateEdit(OBJ_EDIT_ENTRIES, "1", x+90, y, 80, 32);

   y += gap;

   CreateButton(OBJ_BTN_CLOSE_ABOVE, "Close Above", x+480, y);
   CreateButton(OBJ_BTN_BUY_PENDING, "BUY Pending", x+360, y);
   CreateEdit(OBJ_EDIT_TP, "0.0", x+233, y, 100, 32);
   CreateButton(OBJ_BTN_SET_TP, "Set All TP", x+120, y);
   CreateButton(OBJ_BTN_CLOSE_PROFIT, "Close Profit", x, y);
   
   y += gap;

   CreateButton(OBJ_BTN_CLOSE_BELOW, "Close Below", x+480, y);
   CreateButton(OBJ_BTN_SELL_PENDING, "SELL Pending", x+360, y);
   CreateEdit(OBJ_EDIT_SL, "0.0", x+233, y, 100, 32);
   CreateButton(OBJ_BTN_SET_SL, "Set All SL", x+120, y);
   CreateButton(OBJ_BTN_CLOSE_LOSS, "Close Loss", x, y);
   
   y += gap;
   CreateLabel(PFX+"risklbl", "Risk%", x+665, y);
   CreateEdit(OBJ_EDIT_RISK, "5", x+660, y, 60, 32);
   CreateLabel(PFX+"piplbl", "Pip", x+555, y);
   CreateEdit(OBJ_EDIT_SL_PIP, "50", x+550, y, 60, 32);
   CreateButton(OBJ_BTN_CALC_LOT, "Calc Lot", x+480, y);
   CreateButton(OBJ_BTN_DELETE_PENDING, "Delete Pending", x+360, y);
   CreateButton(OBJ_BTN_SET_BE, "Set BE", x+240, y);
   CreateButton(OBJ_BTN_TOGGLE_TRAIL, "On/Off Trail", x+120, y);
   CreateButton(OBJ_BTN_CLOSE_ALL, "Close All", x, y);

   
   

   y += gap;

   CreateLabel(OBJ_LABEL_STATS, "MaxLot: 0 | MaxLoss: 0 | OpenLot: 0", 10, y);

   y += 25;
   
   string trailText =
   TrailingDefault
   ? "Trail:ON"
   : "Trail:OFF";

   CreateLabel(OBJ_LABEL_TRAIL, trailText, 10, y);   
   UpdateTrailLabel();
   
   y += 25;
   

   string beText =
   AutoSetBEForEmptySL
   ? "AutoBE:ON |"
   : "AutoBE:OFF |";
   
   CreateLabel(OBJ_LABEL_BE, beText, 10, y);   
   UpdateBELabel();


   y += 25;
   
   CreateLabel(OBJ_LABEL_INFO, "NOT FOR SALE!!! At your own risk. by @gold.gamers", 10, y);
   
   SyncUI();
}

// SYNC With Current TEXT Values
void SyncUI()
{
   ObjectSetString(0, OBJ_EDIT_LOT,
      OBJPROP_TEXT,
      DoubleToString(CurrentLot,2));

   ObjectSetString(0, OBJ_EDIT_ENTRIES,
      OBJPROP_TEXT,
      IntegerToString(CurrentEntries));

   ObjectSetString(0, OBJ_EDIT_TP,
      OBJPROP_TEXT,
      DoubleToString(CurrentPriceTP,0));

   ObjectSetString(0, OBJ_EDIT_SL,
      OBJPROP_TEXT,
      DoubleToString(CurrentPriceSL,0));
}

// Save TEXT EDIT Values
void SaveSettings()
{
   CurrentLot =
      StringToDouble(
         ObjectGetString(0,OBJ_EDIT_LOT,OBJPROP_TEXT));

   CurrentEntries =
      (int)StringToInteger(
         ObjectGetString(0,OBJ_EDIT_ENTRIES,OBJPROP_TEXT));

   CurrentPriceTP =
      StringToDouble(
         ObjectGetString(0,OBJ_EDIT_TP,OBJPROP_TEXT));

   CurrentPriceSL =
      StringToDouble(
         ObjectGetString(0,OBJ_EDIT_SL,OBJPROP_TEXT));

   GlobalVariableSet("EA_Lot",CurrentLot);
   GlobalVariableSet("EA_Entries",CurrentEntries);
   GlobalVariableSet("EA_TP",CurrentPriceTP);
   GlobalVariableSet("EA_SL",CurrentPriceSL);
}

// RESET TEXT EDIT Values to Default
void ResetSettings()
{
   CurrentLot     = DefaultLot;
   CurrentEntries = DefaultEntries;
   CurrentPriceTP      = DefaultPriceTP;
   CurrentPriceSL      = DefaultPriceSL;

   SyncUI();

   GlobalVariableSet("EA_Lot",CurrentLot);
   GlobalVariableSet("EA_Entries",CurrentEntries);
   GlobalVariableSet("EA_TP",CurrentPriceTP);
   GlobalVariableSet("EA_SL",CurrentPriceSL);
}

// =========================================================
// OPEN MARKET
// =========================================================

void OpenPositions(bool isBuy)
{
   double lot = StringToDouble(ObjectGetString(0, OBJ_EDIT_LOT, OBJPROP_TEXT));
   int entries = (int)StringToInteger(ObjectGetString(0, OBJ_EDIT_ENTRIES, OBJPROP_TEXT));

   if(entries <= 0)
      entries = 1;

   for(int i=0;i<entries;i++)
   {
      if(isBuy)
         trade.Buy(lot, _Symbol);
      else
         trade.Sell(lot, _Symbol);
   }
}

// =========================================================
// PENDING
// =========================================================

void CreatePending(bool isBuy)
{
   double price = StringToDouble(ObjectGetString(0, isBuy ? OBJ_EDIT_TP : OBJ_EDIT_SL, OBJPROP_TEXT));
   double lot   = StringToDouble(ObjectGetString(0, OBJ_EDIT_LOT, OBJPROP_TEXT));
   int entries = (int)StringToInteger(ObjectGetString(0, OBJ_EDIT_ENTRIES, OBJPROP_TEXT));
   
   if(entries <= 0)
      entries = 1;

   for(int i=0;i<entries;i++)
   {
      if(price <= 0)
         return;
   
      double pip = PipPoint();
   
      double sl = 0;
      double tp = 0;
   
      if(isBuy)
      {
         sl = price - (LimitSL * pip);
         tp = price + (LimitTP * pip);
   
         if(price > SymbolInfoDouble(_Symbol, SYMBOL_ASK))
            trade.BuyStop(lot, price, _Symbol, sl, tp);
         else
            trade.BuyLimit(lot, price, _Symbol, sl, tp);
      }
      else
      {
         sl = price + (LimitSL * pip);
         tp = price - (LimitTP * pip);
   
         if(price < SymbolInfoDouble(_Symbol, SYMBOL_BID))
            trade.SellStop(lot, price, _Symbol, sl, tp);
         else
            trade.SellLimit(lot, price, _Symbol, sl, tp);
      }
   }
}

// =========================================================
// MODIFY ALL TP
// =========================================================

void SetAllTP()
{
   double tpPip = StringToDouble(ObjectGetString(0, OBJ_EDIT_TP, OBJPROP_TEXT));

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;

      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl   = PositionGetDouble(POSITION_SL);
      double tp   = 0;

      tp = tpPip;

      trade.PositionModify(ticket, sl, tp);
   }
}

// =========================================================
// MODIFY ALL SL
// =========================================================

void SetAllSL()
{
   double slPip = StringToDouble(ObjectGetString(0, OBJ_EDIT_SL, OBJPROP_TEXT));
   
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;

      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double tp   = PositionGetDouble(POSITION_TP);
      double sl   = 0;

      sl = slPip;

      trade.PositionModify(ticket, sl, tp);
   }
}

// =========================================================
// BREAK EVEN
// =========================================================

void SetBreakEven()
{
   double pip = PipPoint();

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double tp   = PositionGetDouble(POSITION_TP);
      double sl;

      if(type == POSITION_TYPE_BUY)
         sl = open + (BEPipsPlus * pip);
      else
         sl = open - (BEPipsPlus * pip);

      trade.PositionModify(ticket, sl, tp);
   }
}

//==================================
// Auto Set BE for empty SL
//==================================
void AutoSetBEForPositionsWithoutSL()
{
   if(!AutoSetBEForEmptySL)
      return;

   double pip = PipPoint();

   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      // symbol filter
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      // hanya posisi tanpa SL
      double currentSL = PositionGetDouble(POSITION_SL);

      if(currentSL > 0)
         continue;

      ENUM_POSITION_TYPE type =
         (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double entry =
         PositionGetDouble(POSITION_PRICE_OPEN);

      double tp =
         PositionGetDouble(POSITION_TP);

      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

      double profitPip = 0;

      // =========================
      // HITUNG PROFIT PIP
      // =========================

      if(type == POSITION_TYPE_BUY)
      {
         profitPip = (bid - entry) / pip;
      }
      else
      if(type == POSITION_TYPE_SELL)
      {
         profitPip = (entry - ask) / pip;
      }

      // belum mencapai trigger
      if(profitPip < AutoBETriggerPip)
         continue;

      // =========================
      // HITUNG BEP SL
      // =========================

      double newSL = 0;

      if(type == POSITION_TYPE_BUY)
      {
         newSL = entry + (BEPipsPlus * pip);

         // SL tidak boleh di atas BID
         if(newSL >= bid)
            continue;
      }
      else
      if(type == POSITION_TYPE_SELL)
      {
         newSL = entry - (BEPipsPlus * pip);

         // SL tidak boleh di bawah ASK
         if(newSL <= ask)
            continue;
      }

      newSL = NormalizeDouble(newSL,_Digits);

      // =========================
      // MODIFY
      // =========================

      bool modified =
         trade.PositionModify(ticket,newSL,tp);

      if(modified)
      {
         Print("AUTO BE SUCCESS : ",ticket,
               " | SL = ",
               DoubleToString(newSL,_Digits));
      }
      else
      {
         Print("AUTO BE FAILED : ",
               ticket,
               " | ",
               trade.ResultComment());
      }
   }
}

// =========================================================
// TRAILING
// =========================================================

void ManageTrailing()
{
   if(!trailingEnabled)
      return;

   double pip = PipPoint();

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double tp   = PositionGetDouble(POSITION_TP);
      double sl   = PositionGetDouble(POSITION_SL);

      double current;
      double profitPips;
      double newSL;

      if(type == POSITION_TYPE_BUY)
      {
         current = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         profitPips = (current - open) / pip;

         if(profitPips < TrailingStartPips)
            continue;
         
         // First Step
         if(sl == 0) {
            newSL = open + (TrailingStepPips * pip);  
            trade.PositionModify(ticket, newSL, tp); 
         }
         else {
            double distance = current - sl;

            if(distance >= ((TrailingStepPips+TrailingStartPips) * pip))
            {
               newSL = sl + (TrailingStepPips * pip);
         
               trade.PositionModify(ticket,newSL,tp);
            }  
         }                     
      }
      else
      {
         current = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         profitPips = (open - current) / pip;

         if(profitPips < TrailingStartPips)
            continue;

         // First Step
         if(sl == 0) {
            newSL = open - (TrailingStepPips * pip); 
            trade.PositionModify(ticket, newSL, tp);
         }
         else {
            double distance = sl - current;

            if(distance >= ((TrailingStepPips+TrailingStartPips) * pip))
            {
               newSL = sl - (TrailingStepPips * pip);
         
               trade.PositionModify(ticket,newSL,tp);
            }
         }                  
      }
   }
}

// =========================================================
// CLOSE CONDITIONS
// =========================================================
void CloseAbovePrice(double price)
{
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;

         double entry = PositionGetDouble(POSITION_PRICE_OPEN);

         if(entry >= price)
         {
            trade.PositionClose(ticket);
         }
      }
   }
}

void CloseBelowPrice(double price)
{
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;

         double entry = PositionGetDouble(POSITION_PRICE_OPEN);

         if(entry <= price)
         {
            trade.PositionClose(ticket);
         }
      }
   }
}
// =========================================================
// CLOSE POSITIONS
// =========================================================

void ClosePositions(int mode)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      double profit = PositionGetDouble(POSITION_PROFIT);

      if(mode == 0)
         trade.PositionClose(ticket);

      if(mode == 1 && profit > 0)
         trade.PositionClose(ticket);

      if(mode == -1 && profit < 0)
         trade.PositionClose(ticket);
   }
}

// =========================================================
// DELETE PENDING
// =========================================================

void DeleteAllPending()
{
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      ulong ticket = OrderGetTicket(i);

      if(!OrderSelect(ticket))
         continue;

      ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);

      if(type == ORDER_TYPE_BUY_LIMIT ||
         type == ORDER_TYPE_SELL_LIMIT ||
         type == ORDER_TYPE_BUY_STOP ||
         type == ORDER_TYPE_SELL_STOP)
      {
         trade.OrderDelete(ticket);
      }
   }
}

// =========================================================
// LOT CALCULATOR
// =========================================================

void CalculateLotFromRisk()
{
   double riskPercent = StringToDouble(ObjectGetString(0, OBJ_EDIT_RISK, OBJPROP_TEXT));
   double slPips      = StringToDouble(ObjectGetString(0, OBJ_EDIT_SL_PIP, OBJPROP_TEXT));

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * riskPercent / 100.0;

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   double pipValuePerLot = (tickValue / tickSize) * PipPoint();

   double lot = riskMoney / (slPips * pipValuePerLot);

   lot = NormalizeLot(lot);
   
   double pip = PipPoint();
   double valuePerPip = (pip / tickSize) * tickValue;
   
   lbl_openlot = lot;
   lbl_maxloss = lot * slPips * valuePerPip;
   //ObjectSetString(0, OBJ_EDIT_LOT, OBJPROP_TEXT, DoubleToString(lot,2));

   UpdateStats();
}

// =========================================================
// STATS
// =========================================================

void UpdateStats()
{
   double openLot = 0;

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      openLot += PositionGetDouble(POSITION_VOLUME);
   }

   string txt = StringFormat(
      "MaxLot: %s | MaxLoss: %s %.2f | OpenLot: %.2f",
      DoubleToString(lbl_openlot,2),
      AccountInfoString(ACCOUNT_CURRENCY),
      lbl_maxloss,
      openLot
   );

   ObjectSetString(0, OBJ_LABEL_STATS, OBJPROP_TEXT, txt);
}

// =========================================================
// HELPERS
// =========================================================

void UpdateTrailLabel()
{
   string txt = StringFormat(
      "Trail: %s | Start: %.1f pip | Step: %.1f pip",
      trailingEnabled ? "ON" : "OFF",
      TrailingStartPips,
      TrailingStepPips
   );
   
   //Print(txt);
   
   ObjectSetString(0, OBJ_LABEL_TRAIL, OBJPROP_TEXT, txt);   
   
   StringToLower(txt);
   
   // ===== FONT HIJAU =====
   if(StringFind(txt,"on") >= 0)
   {
      ObjectSetInteger(0,OBJ_LABEL_TRAIL,OBJPROP_COLOR,clrLimeGreen);
   }
   else {
      ObjectSetInteger(0,OBJ_LABEL_TRAIL,OBJPROP_COLOR,Label_Color);
   }
}

void UpdateBELabel()
{
   string txt = StringFormat(
      "AutoBE: %s | Trigger: %.1f pip",
      AutoSetBEForEmptySL ? "ON" : "OFF",
      AutoBETriggerPip
   );
   
   //Print(txt);

   ObjectSetString(0, OBJ_LABEL_BE, OBJPROP_TEXT, txt);   
   
   StringToLower(txt);
   
   // ===== FONT HIJAU =====
   if(StringFind(txt,"on") >= 0)
   {
      ObjectSetInteger(0,OBJ_LABEL_BE,OBJPROP_COLOR,clrLimeGreen);
   }
   else {
      ObjectSetInteger(0,OBJ_LABEL_BE,OBJPROP_COLOR,Label_Color);
   }
}


double PipPoint()
{
   
   
   string lowerText = _Symbol;
   StringToLower(lowerText);
      
   // forex normal 5 digit
   if(_Digits == 5 || _Digits == 3 || StringFind(lowerText,"xau") >= 0 || StringFind(lowerText,"gold") >= 0)
      return (_Point * 10);

   return _Point;
}

double NormalizeLot(double lot)
{
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   lot = MathFloor(lot / step) * step;

   if(lot < min)
      lot = min;

   if(lot > max)
      lot = max;

   return lot;
}

// =========================================================
// GUI HELPERS
// =========================================================
void CreateButton(string name,string text,int x,int y)
{
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_XSIZE,112);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,32);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);

   ObjectSetString(0,name,OBJPROP_TEXT,text);

   // background default abu MT5
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrNONE);

   string lowerText = text;
   StringToLower(lowerText);
   
   // ===== FONT HIJAU =====
   if(StringFind(lowerText,"buy") >= 0 ||
      StringFind(lowerText,"profit") >= 0 ||
      StringFind(lowerText,"above") >= 0 ||
      StringFind(lowerText,"tp") >= 0)
   {
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrLimeGreen);
   }

   // ===== FONT MERAH =====
   else if(StringFind(lowerText,"sell") >= 0 ||
           StringFind(lowerText,"loss") >= 0 ||
           StringFind(lowerText,"below") >= 0 ||
           StringFind(lowerText,"sl") >= 0)
   {
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrTomato);
   }

   // ===== DEFAULT =====
   else
   {
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrDimGray);
   }
}

void CreateEdit(string name,string value,int x,int y,int sx,int sy)
{
   ObjectCreate(0,name,OBJ_EDIT,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,sx);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,sy);
   ObjectSetString(0,name,OBJPROP_TEXT,value);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrNONE);
}

void CreateLabel(string name,string text,int x,int y)
{
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,Label_Color);   
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   
   string lowerText = text;
   StringToLower(lowerText);
   
   // ===== FONT HIJAU =====
   if(StringFind(lowerText,"on") >= 0)
   {
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrLimeGreen);
   }
   else {
      ObjectSetInteger(0,name,OBJPROP_COLOR,Label_Color);
   }
   
}

//+------------------------------------------------------------------+
