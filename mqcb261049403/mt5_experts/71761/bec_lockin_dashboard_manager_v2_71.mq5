//+------------------------------------------------------------------+
//|                           BEC -Lockin Dashboard Manager v2.71.mq5|
//|                               BEC -Lockin Dashboard Manager v2.71|
//|                               Extended with bulk trade actions   |
//+------------------------------------------------------------------+
#property link          "https://mrshafaq.com"
#property version       "2.71"
#property copyright     "BEC Trading Systems - 2026"
#property description   "BEC - Breakeven Dashboard Manager"
#property description   "Bulk close / partial close / per-trade BE / 2 trail modes."
#property description   "POS trail from current SL, trade profit labels, SL labels."
#property description   "Extended with bulk trade actions."
#property description   "mrshafaq@gmail.com"
#property description   "WARNING: Use this software at your own risk."

#include <Trade/Trade.mqh>

//--- Enums
enum ENUM_CONSIDER
  {
   All  = -1,
   Buy  = POSITION_TYPE_BUY,
   Sell = POSITION_TYPE_SELL
  };

enum ENUM_ADJUST_TO
  {
   ADJUST_DONT,
   ADJUST_TO_ASK,
   ADJUST_TO_BID
  };

enum mode_of_operation { Risk, Reward };

//============================================================
//  INPUT PARAMETERS
//============================================================
input group "=== BEC SINGLE BREAKEVEN (ACCOUNT / EQUITY) ==="
input int    ProfitCurToTrigger          = 2;
input int    AdditionalProfitCur         = 10;
input ENUM_ADJUST_TO AdjustToPrice       = ADJUST_TO_BID;
input int    DelayBetweenAdjustments     = 1;
input bool   AdjustForSwapsCommission    = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "=== BEC TRAILING STOP (PRICE DISTANCE) ==="
input int    TrailingStop                = 30;
input int    TrailingProfit              = 30;

input group "=== PER-TRADE BREAKEVEN LOCK PROFIT ==="
input int    TradeBETriggerPips          = 100;
input int    TradeBELockPips             = 30;

input group "=== POSITION TRAIL FROM CURRENT SL ==="
input int    PositionTrailStepPips       = 30;
input bool   PositionTrailUseEntryIfNoSL = true;

input group "=== SCALPING ==="
input double ScalpingLot                 = 0.01;
input int    ScalpingTrailPips           = 30;
input int    ScalpingStartPips           = 10;

input group "=== ORDERS FILTERING ==="
input ENUM_CONSIDER OnlyType             = All;
input bool   UseMagic                    = false;
input int    MagicNumber                 = 0;
input bool   UseComment                  = false;
input string CommentFilter               = "BEC";

input group "=== ENABLE / DISABLE ==="
input bool   EnableBEParam               = false;
input bool   EnableTrailParam            = false;
input bool   EnableTradeBEParam          = false;
input bool   EnablePosTrailParam         = false;

input group "=== CHART VISUALS ==="
input bool   ShowBasketBELine            = true;
input bool   ShowTradeFloatingLabels     = true;
input int    TradeLabelOffsetPoints      = 100;
input int    TradeLabelShiftBars         = 8;
input int    SLLabelOffsetPoints         = 50;

input group "=== NOTIFICATIONS ==="
input bool   EnableNotify                = false;
input bool   SendAlert                   = false;
input bool   SendApp                     = false;
input bool   SendEmail                   = false;

input group "=== DASHBOARD ==="
input bool   ShowPanel                   = true;
input int    Xoff                        = 15;
input int    Yoff                        = 0;
input ENUM_BASE_CORNER ChartCorner       = CORNER_LEFT_LOWER;
input int    FontSize                    = 9;
input int    MaxCloseDeviationPoints     = 10;
input int    BulkSLRetryPasses           = 5;
input int    BulkSLRetryDelayMs          = 25;

//============================================================
//  GLOBALS
//============================================================
string ExpertName   = "BEC";
string AccCurrency;
double DPIScale;
int    PanelMovY, PanelLabX, PanelLabY, PanelRecX;
int    PanelWidthPx, PanelHeightPx;
int    PanelOriginX, PanelOriginY;

bool     EnableBE         = EnableBEParam;
bool     EnableTrail      = EnableTrailParam;
bool     EnableTradeBE    = EnableTradeBEParam;
bool     EnablePosTrail   = EnablePosTrailParam;
datetime LastAdjustment;

CTrade *Trade;

// Basket BE tracking
double BasketBEPrice           = 0.0;
double LockedProfit            = 0.0;
double AdditionalProfitCurLive = 0.0;
bool   HasCustomLockProfit     = false;
bool   LockEditActive          = false;

// panel names
string PanelBase              = "BEC-P-BASE";
string PanelTitle             = "BEC-P-TITLE";
string PanelPrice             = "BEC-P-PRICE";
string PanelEquity            = "BEC-P-EQUITY";
string PanelFloating          = "BEC-P-FLOAT";
string PanelDayProfit         = "BEC-P-DAYP";
string PanelLocked            = "BEC-P-LOCK";

string PanelLockInfo          = "BEC-P-LOCKINFO";
string PanelLockEdit          = "BEC-P-LOCKEDIT";
string PanelLockApply         = "BEC-P-LOCKAPPLY";

string PanelBEToggle          = "BEC-P-BETOG";
string PanelTSToggle          = "BEC-P-TSTOG";
string PanelTradeBEToggle     = "BEC-P-TBE";
string PanelPosTrailToggle    = "BEC-P-PTRAIL";

string PanelBtnCloseProfit    = "BEC-P-CLOSEPROFIT";
string PanelBtnCloseLoss      = "BEC-P-CLOSELOSS";
string PanelBtnHalfBEAll      = "BEC-P-HALFBEALL";
string PanelBtnHalfBEProfit   = "BEC-P-HALFBEPROFIT";
string PanelBtnTradeBEAll     = "BEC-P-TRADEBEALL";
string PanelBtnCancelAllSL    = "BEC-P-CANCELALLSL";
string PanelBtnCloseAll       = "BEC-P-CLOSEALL";

string PanelScalpBuy          = "BEC-P-SBUY";
string PanelScalpSell         = "BEC-P-SSELL";

// chart objects
string ObjBasketBE            = "BEC-CHART-BASKET-BE";
string ObjTradeLinePrefix     = "BEC-CHART-TRADELINE-";
string ObjTradeTextPrefix     = "BEC-CHART-TRADETEXT-";
string ObjSLLinePrefix        = "BEC-CHART-SLLINE-";
string ObjSLTextPrefix        = "BEC-CHART-SLTEXT-";

int    PositionsLong, PositionsShort;
double ProfitTotal;

// ============================================================
// FIX #3: Panel Z-order layering
// Base background gets a LOWER z-order than buttons so buttons
// render on top of the background rect, not vice versa.
// All objects use OBJPROP_BACK=false to stay in front of
// indicator/EA chart objects which are always rendered in the
// background layer (OBJPROP_BACK=true).
// ============================================================
long PanelZOrderBase   = 2147483000;   // background rect
long PanelZOrderButton = 2147483001;   // all buttons / labels on top of base
long ChartZOrder       = 0;

//============================================================
//  POS TRAIL STATE
//============================================================
struct PosTrailState
  {
   ulong             ticket;
   double            start_sl;
   double            anchor_price;
   bool              initialized;
  };

PosTrailState g_posTrailStates[];

//============================================================
//  FORWARD DECLARATIONS
//============================================================
void DrawPanel();
void CleanPanel();
bool ApplyFilters();
void ToggleBE();
void ToggleTrail();
void ToggleTradeBE();
void TogglePosTrail();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EnsureTradingEnabled();
double PipSize(string sym);
double NormalizeVolumeToStep(string sym, double volume);
void PrepareTradeSymbol(const string sym);
bool ModifySLIfBetter(ulong ticket, double newSL, double currentTP, string reasonTag);
bool ClosePositionProtected(ulong ticket, string reasonTag);
bool ClosePartialProtected(ulong ticket, double volume, string reasonTag);
bool HasEqualOrBetterSL(ulong ticket, double targetSL);
bool ApplyAccountBEStopsFast(double baseBEPrice);
void CommitLockEditValue();
void SetBulkMode(bool enabled);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllTradesAndOrdersBulk();
void CloseOnlyProfitTradesBulk();
void CloseOnlyLossTradesBulk();
void CloseHalfAndSetBreakevenBulk(bool onlyProfit);
void ApplyPerTradeBELockAll();
void CancelAllStopLossBulk();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoSingleBE();
void DoTrailingStop();
void DoPerTradeBreakEvenLock();
void DoPositionBasedTrailing();
void DoScalpTrailing();
double CalculateSingleBreakeven();
double CalculateCommission();
double CalculatePointValue(mode_of_operation mode);
double CalculateUnitCost(const string cp, const mode_of_operation mode);
double CalculateAdjustment(const string ProfitCurrency, const mode_of_operation mode);
string GetSymbolByCurrencies(string base_currency, string profit_currency);
double GetCurrencyCorrectionCoefficient(MqlTick &tick, const mode_of_operation mode, const bool ReferenceSymbolMode);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendBENotification(long Ticket, double Price, string Instrument);
void SendTSNotification(ulong Ticket, double Price, string Instrument);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTodayProfit();
double GetFloatingProfit();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBasketBELine();
void RemoveBasketBELine();
void DrawTradeFloatingObjects();
void RemoveTradeFloatingObjects();
void RemoveMissingTradeObjects();
string TradeFloatingText(ulong ticket);
string SLValueText(ulong ticket);
color  TradeFloatingColor(double profit);
datetime GetRightSideTime();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  FindPosTrailState(ulong ticket);
void ClearPosTrailStates();
void ClearStalePosTrailStates();
bool EnsurePosTrailState(ulong ticket, string sym, long type, double currentSL, double openPrice, double bid, double ask);
void RemovePosTrailStateByIndex(int idx);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, int w, int h, string text,
                 color fg, color bg, int fsize, bool bold = false,
                 ENUM_ALIGN_MODE align = ALIGN_CENTER, bool selectable = false);
void CreateEdit(string name, int x, int y, int w, int h, string text,
                color fg, color bg, int fsize);
void UpdatePanelOrigin();
int PanelCoordX(int localX, int objW);
int PanelCoordY(int localY, int objH);
double CalculateBasketPreviewPrice(double targetProfit);

//============================================================
//  INIT
//============================================================
int OnInit()
  {
   CleanPanel();

   EnableBE       = EnableBEParam;
   EnableTrail    = EnableTrailParam;
   EnableTradeBE  = EnableTradeBEParam;
   EnablePosTrail = EnablePosTrailParam;

   AdditionalProfitCurLive = (double)AdditionalProfitCur;
   HasCustomLockProfit     = false;

   DPIScale   = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0;
   PanelMovY  = (int)MathRound(18 * DPIScale);
   PanelLabX  = (int)MathRound(200 * DPIScale);
   PanelLabY  = PanelMovY;
   PanelRecX  = PanelLabX + 4;
   PanelWidthPx  = 314;
   PanelHeightPx = 0;
   PanelOriginX  = Xoff;
   PanelOriginY  = Yoff;
   LastAdjustment = 0;

   Trade = new CTrade;
   ArrayResize(g_posTrailStates, 0);

   if(ShowPanel)
      DrawPanel();

   return INIT_SUCCEEDED;
  }

//============================================================
//  DEINIT
//============================================================
void OnDeinit(const int reason)
  {
   RemoveBasketBELine();
   RemoveTradeFloatingObjects();
   ClearPosTrailStates();
   CleanPanel();
   ChartRedraw();
   delete Trade;
  }

//============================================================
//  TICK
//============================================================
void OnTick()
  {
   CalculateSingleBreakeven();

   if(EnableBE)
      DoSingleBE();

   if(EnableTrail && !EnablePosTrail)
      DoTrailingStop();

   if(EnableTradeBE)
      DoPerTradeBreakEvenLock();

   if(EnablePosTrail)
      DoPositionBasedTrailing();
   else
      ClearPosTrailStates();

   DoScalpTrailing();

   if(ShowBasketBELine)
      DrawBasketBELine();
   else
      RemoveBasketBELine();

   if(ShowTradeFloatingLabels)
      DrawTradeFloatingObjects();
   else
      RemoveTradeFloatingObjects();

   if(ShowPanel)
      DrawPanel();
  }

//============================================================
//  CHART EVENTS
//============================================================
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == PanelLockEdit)
        {
         LockEditActive = true;
         ObjectSetInteger(ChartID(), PanelLockEdit, OBJPROP_READONLY, false);
         ObjectSetInteger(ChartID(), PanelLockEdit, OBJPROP_SELECTABLE, true);
         ObjectSetInteger(ChartID(), PanelLockEdit, OBJPROP_SELECTED, true);
         ChartRedraw();
         return;
        }
      else
         if(sparam == PanelLockApply)
           {
            CommitLockEditValue();
            DrawPanel();
            ChartRedraw();
            return;
           }
         else
            if(sparam == PanelBEToggle)
              {
               ToggleBE();
               DrawPanel();
              }
            else
               if(sparam == PanelTSToggle)
                 {
                  ToggleTrail();
                  DrawPanel();
                 }
               else
                  if(sparam == PanelTradeBEToggle)
                    {
                     ToggleTradeBE();
                     DrawPanel();
                    }
                  else
                     if(sparam == PanelPosTrailToggle)
                       {
                        TogglePosTrail();
                        DrawPanel();
                       }
                     else
                        if(sparam == PanelBtnCloseProfit)
                          {
                           CloseOnlyProfitTradesBulk();
                          }
                        else
                           if(sparam == PanelBtnCloseLoss)
                             {
                              CloseOnlyLossTradesBulk();
                             }
                           else
                              if(sparam == PanelBtnHalfBEAll)
                                {
                                 CloseHalfAndSetBreakevenBulk(false);
                                }
                              else
                                 if(sparam == PanelBtnHalfBEProfit)
                                   {
                                    CloseHalfAndSetBreakevenBulk(true);
                                   }
                                 else
                                    if(sparam == PanelBtnTradeBEAll)
                                      {
                                       ApplyPerTradeBELockAll();
                                      }
                                    else
                                       if(sparam == PanelBtnCancelAllSL)
                                         {
                                          CancelAllStopLossBulk();
                                         }
                                       else
                                          if(sparam == PanelBtnCloseAll)
                                            {
                                             CloseAllTradesAndOrdersBulk();
                                            }
                                          else
                                             if(sparam == PanelScalpBuy)
                                               {
                                                OpenScalpTrade(true);
                                               }
                                             else
                                                if(sparam == PanelScalpSell)
                                                  {
                                                   OpenScalpTrade(false);
                                                  }
     }

   if(id == CHARTEVENT_OBJECT_ENDEDIT)
     {
      if(sparam == PanelLockEdit)
        {
         CommitLockEditValue();
         DrawPanel();
         ChartRedraw();
         return;
        }
     }

   if(id == CHARTEVENT_KEYDOWN)
     {
      if(LockEditActive && (lparam == 13 || lparam == 10))
        {
         CommitLockEditValue();
         DrawPanel();
         ChartRedraw();
         return;
        }

      if(lparam == 27)
        {
         if(MessageBox("Close BEC EA?", "EXIT?", MB_YESNO) == IDYES)
            ExpertRemove();
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CommitLockEditValue()
  {
   LockEditActive = false;

   string txt = "";
   if(ObjectFind(ChartID(), PanelLockEdit) >= 0)
      txt = ObjectGetString(ChartID(), PanelLockEdit, OBJPROP_TEXT);

   StringTrimLeft(txt);
   StringTrimRight(txt);
   double val = StringToDouble(txt);

   if(txt == "" || val <= 0.0)
     {
      HasCustomLockProfit = false;
      AdditionalProfitCurLive = (double)AdditionalProfitCur;
     }
   else
     {
      HasCustomLockProfit = true;
      AdditionalProfitCurLive = val;
     }

   if(ObjectFind(ChartID(), PanelLockEdit) >= 0)
     {
      ObjectSetString(ChartID(), PanelLockEdit, OBJPROP_TEXT, DoubleToString(AdditionalProfitCurLive, 2));
      ObjectSetInteger(ChartID(), PanelLockEdit, OBJPROP_SELECTED, false);
      ObjectSetInteger(ChartID(), PanelLockEdit, OBJPROP_READONLY, false);
     }
  }

//============================================================
//  TOGGLE FUNCTIONS
//============================================================
bool EnsureTradingEnabled()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      MessageBox("Enable Algo Trading in platform settings.", "WARNING", MB_OK);
      return false;
     }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      MessageBox("Enable Algo Trading in EA Common tab.", "WARNING", MB_OK);
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ToggleBE()
  {
   if(!EnableBE && !EnsureTradingEnabled())
      return;
   EnableBE = !EnableBE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ToggleTrail()
  {
   if(!EnableTrail && !EnsureTradingEnabled())
      return;
   EnableTrail = !EnableTrail;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ToggleTradeBE()
  {
   if(!EnableTradeBE && !EnsureTradingEnabled())
      return;
   EnableTradeBE = !EnableTradeBE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TogglePosTrail()
  {
   if(!EnablePosTrail && !EnsureTradingEnabled())
      return;
   EnablePosTrail = !EnablePosTrail;
   ClearPosTrailStates();
  }

//============================================================
//  HELPERS
//============================================================
bool IsEditingLockInput()
  {
   return LockEditActive;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PipSize(string sym)
  {
   int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   if(digits == 3 || digits == 5)
      return point * 10.0;
   return point;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeVolumeToStep(string sym, double volume)
  {
   double minLot  = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);

   if(lotStep <= 0.0)
      lotStep = 0.01;

   volume = MathMax(minLot, MathMin(maxLot, volume));
   volume = MathFloor(volume / lotStep) * lotStep;

   int volDigits = 2;
   if(lotStep == 1.0)
      volDigits = 0;
   else
      if(lotStep == 0.1)
         volDigits = 1;
      else
         if(lotStep == 0.01)
            volDigits = 2;
         else
            if(lotStep == 0.001)
               volDigits = 3;

   return NormalizeDouble(volume, volDigits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrepareTradeSymbol(const string sym)
  {
   if(Trade == NULL)
      return;

   Trade.SetTypeFillingBySymbol(sym);
   Trade.SetDeviationInPoints(MaxCloseDeviationPoints);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetBulkMode(bool enabled)
  {
   if(Trade != NULL)
      Trade.SetAsyncMode(enabled);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ModifySLIfBetter(ulong ticket, double newSL, double currentTP, string reasonTag)
  {
   if(!PositionSelectByTicket(ticket))
      return false;

   string sym      = PositionGetString(POSITION_SYMBOL);
   long   type     = PositionGetInteger(POSITION_TYPE);
   double oldSL    = PositionGetDouble(POSITION_SL);
   double bid      = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask      = SymbolInfoDouble(sym, SYMBOL_ASK);
   double tickSize = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   double point    = SymbolInfoDouble(sym, SYMBOL_POINT);
   double stopLvl  = (double)SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL) * point;
   double freezeLvl= (double)SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL) * point;

   if(tickSize > 0.0)
      newSL = NormalizeDouble(MathRound(newSL / tickSize) * tickSize, (int)SymbolInfoInteger(sym, SYMBOL_DIGITS));

   if(type == POSITION_TYPE_BUY)
     {
      if(newSL >= bid - stopLvl || newSL >= bid - freezeLvl)
         return false;
      if(oldSL != 0.0 && newSL <= oldSL + (point / 2.0))
         return false;
     }
   else
      if(type == POSITION_TYPE_SELL)
        {
         if(newSL <= ask + stopLvl || newSL <= ask + freezeLvl)
            return false;
         if(oldSL != 0.0 && newSL >= oldSL - (point / 2.0))
            return false;
        }

   PrepareTradeSymbol(sym);

   if(Trade.PositionModify(ticket, newSL, currentTP))
     {
      Print(reasonTag, ": Modified #", ticket, " SL=", DoubleToString(newSL, _Digits));
      return true;
     }

   Print(reasonTag, ": Failed modify #", ticket, " err=", GetLastError());
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePositionProtected(ulong ticket, string reasonTag)
  {
   if(!PositionSelectByTicket(ticket))
      return false;

   string sym = PositionGetString(POSITION_SYMBOL);
   PrepareTradeSymbol(sym);

   for(int attempt = 0; attempt < 3; attempt++)
     {
      ResetLastError();
      if(Trade.PositionClose(ticket))
         return true;
      Sleep(75);
      PrepareTradeSymbol(sym);
     }

   Print(reasonTag, ": failed #", ticket, " err=", GetLastError());
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePartialProtected(ulong ticket, double volume, string reasonTag)
  {
   if(!PositionSelectByTicket(ticket))
      return false;

   string sym = PositionGetString(POSITION_SYMBOL);
   PrepareTradeSymbol(sym);

   for(int attempt = 0; attempt < 3; attempt++)
     {
      ResetLastError();
      if(Trade.PositionClosePartial(ticket, volume))
         return true;
      Sleep(75);
      PrepareTradeSymbol(sym);
     }

   Print(reasonTag, ": partial close failed #", ticket, " err=", GetLastError());
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasEqualOrBetterSL(ulong ticket, double targetSL)
  {
   if(!PositionSelectByTicket(ticket))
      return false;

   string sym   = PositionGetString(POSITION_SYMBOL);
   long   type  = PositionGetInteger(POSITION_TYPE);
   double oldSL = PositionGetDouble(POSITION_SL);
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);

   if(oldSL == 0.0)
      return false;

   if(type == POSITION_TYPE_BUY)
      return (oldSL >= targetSL - (point / 2.0));

   return (oldSL <= targetSL + (point / 2.0));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ApplyAccountBEStopsFast(double baseBEPrice)
  {
   string sym = Symbol();
   ulong tickets[];
   int count = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != sym)
         continue;
      if(!ApplyFilters())
         continue;

      ArrayResize(tickets, count + 1);
      tickets[count] = ticket;
      count++;
     }

   if(count == 0)
      return true;

   bool allProtected = false;

   for(int pass = 0; pass < MathMax(1, BulkSLRetryPasses); pass++)
     {
      int pending = 0;

      for(int i = 0; i < count; i++)
        {
         ulong ticket = tickets[i];
         if(ticket == 0 || !PositionSelectByTicket(ticket))
            continue;

         long   type    = PositionGetInteger(POSITION_TYPE);
         double tp      = PositionGetDouble(POSITION_TP);
         double target  = baseBEPrice;
         double tickSz  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);

         if(type == POSITION_TYPE_BUY)
           {
            if((AdjustToPrice == ADJUST_TO_ASK) && (PositionsShort > 0))
               target -= SymbolInfoInteger(sym, SYMBOL_SPREAD) * _Point;
           }
         else
           {
            if((AdjustToPrice == ADJUST_TO_BID) && (PositionsLong > 0))
               target += SymbolInfoInteger(sym, SYMBOL_SPREAD) * _Point;
           }

         if(tickSz > 0.0)
            target = NormalizeDouble(MathRound(target / tickSz) * tickSz, _Digits);
         else
            target = NormalizeDouble(target, _Digits);

         if(HasEqualOrBetterSL(ticket, target))
            continue;

         if(!ModifySLIfBetter(ticket, target, tp, "BEC ACC BE BULK"))
            pending++;
        }

      if(pending == 0)
        {
         allProtected = true;
         break;
        }

      if(BulkSLRetryDelayMs > 0)
         Sleep(BulkSLRetryDelayMs);
     }

   return allProtected;
  }

//============================================================
//  POS TRAIL STATE HELPERS
//============================================================
int FindPosTrailState(ulong ticket)
  {
   int n = ArraySize(g_posTrailStates);
   for(int i = 0; i < n; i++)
     {
      if(g_posTrailStates[i].ticket == ticket)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemovePosTrailStateByIndex(int idx)
  {
   int n = ArraySize(g_posTrailStates);
   if(idx < 0 || idx >= n)
      return;

   for(int i = idx; i < n - 1; i++)
      g_posTrailStates[i] = g_posTrailStates[i + 1];

   ArrayResize(g_posTrailStates, n - 1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearPosTrailStates()
  {
   ArrayResize(g_posTrailStates, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearStalePosTrailStates()
  {
   for(int i = ArraySize(g_posTrailStates) - 1; i >= 0; i--)
     {
      ulong ticket = g_posTrailStates[i].ticket;
      if(ticket == 0 || !PositionSelectByTicket(ticket) || PositionGetString(POSITION_SYMBOL) != Symbol())
         RemovePosTrailStateByIndex(i);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EnsurePosTrailState(ulong ticket, string sym, long type, double currentSL, double openPrice, double bid, double ask)
  {
   int idx = FindPosTrailState(ticket);
   if(idx >= 0)
      return true;

   PosTrailState st;
   st.ticket = ticket;
   st.initialized = true;

   if(currentSL != 0.0)
      st.start_sl = currentSL;
   else
     {
      if(!PositionTrailUseEntryIfNoSL)
         return false;
      st.start_sl = openPrice;
     }

   st.anchor_price = (type == POSITION_TYPE_BUY) ? bid : ask;

   int n = ArraySize(g_posTrailStates);
   ArrayResize(g_posTrailStates, n + 1);
   g_posTrailStates[n] = st;
   return true;
  }

//============================================================
//  OPEN SCALP TRADE
//============================================================
void OpenScalpTrade(bool isBuy)
  {
   if(!EnsureTradingEnabled())
      return;

   string sym = Symbol();
   double lot = NormalizeVolumeToStep(sym, ScalpingLot);

   double price = isBuy ? SymbolInfoDouble(sym, SYMBOL_ASK)
                  : SymbolInfoDouble(sym, SYMBOL_BID);

   bool result = false;

   if(isBuy)
      result = Trade.Buy(lot, sym, price, 0, 0, "SCALP");
   else
      result = Trade.Sell(lot, sym, price, 0, 0, "SCALP");

   if(!result)
      Print("Scalp trade failed: ", GetLastError());
  }

//============================================================
//  FILTER HELPER
//============================================================
bool ApplyFilters()
  {
   if(UseMagic && PositionGetInteger(POSITION_MAGIC) != MagicNumber)
      return false;

   if(UseComment && StringFind(PositionGetString(POSITION_COMMENT), CommentFilter) < 0)
      return false;

   if(OnlyType != All && PositionGetInteger(POSITION_TYPE) != OnlyType)
      return false;

   return true;
  }

//============================================================
//  BULK ACTIONS
//============================================================
void CloseOnlyProfitTradesBulk()
  {
   if(!EnsureTradingEnabled())
      return;

   SetBulkMode(true);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(profit <= 0.0)
         continue;

      ClosePositionProtected(ticket, "BEC BULK CLOSE PROFIT");
     }

   SetBulkMode(false);
   DrawPanel();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOnlyLossTradesBulk()
  {
   if(!EnsureTradingEnabled())
      return;

   SetBulkMode(true);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(profit >= 0.0)
         continue;

      ClosePositionProtected(ticket, "BEC BULK CLOSE LOSS");
     }

   SetBulkMode(false);
   DrawPanel();
  }

// ============================================================
// FIX #2: CloseHalfAndSetBreakevenBulk now honours TradeBELockPips
// instead of always using raw open price (which set SL at zero
// lock profit). Mirrors the logic in DoPerTradeBreakEvenLock.
// ============================================================
void CloseHalfAndSetBreakevenBulk(bool onlyProfit)
  {
   if(!EnsureTradingEnabled())
      return;

   string sym = Symbol();
   double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double pip    = PipSize(sym);

   SetBulkMode(true);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != sym)
         continue;
      if(!ApplyFilters())
         continue;

      double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(onlyProfit && profit <= 0.0)
         continue;

      long   type      = PositionGetInteger(POSITION_TYPE);
      double volume    = PositionGetDouble(POSITION_VOLUME);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentTP = PositionGetDouble(POSITION_TP);
      double halfVolume = NormalizeVolumeToStep(sym, volume / 2.0);

      if(halfVolume < minLot || halfVolume >= volume)
         continue;

      if(!ClosePartialProtected(ticket, halfVolume, "BEC HALF+BE"))
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      double beSL = 0.0;
      if(type == POSITION_TYPE_BUY)
         beSL = openPrice + (TradeBELockPips * pip);
      else
         beSL = openPrice - (TradeBELockPips * pip);

      ModifySLIfBetter(ticket, beSL, currentTP, "BEC HALF+BE");
     }

   SetBulkMode(false);
   DrawPanel();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyPerTradeBELockAll()
  {
   if(!EnsureTradingEnabled())
      return;

   SetBulkMode(true);

   string sym = Symbol();
   double pip = PipSize(sym);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != sym)
         continue;
      if(!ApplyFilters())
         continue;

      long   type      = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double tp        = PositionGetDouble(POSITION_TP);
      double bid       = SymbolInfoDouble(sym, SYMBOL_BID);
      double ask       = SymbolInfoDouble(sym, SYMBOL_ASK);

      double profitPips = 0.0;
      double newSL = 0.0;

      if(type == POSITION_TYPE_BUY)
        {
         profitPips = (bid - openPrice) / pip;
         if(profitPips < TradeBETriggerPips)
            continue;
         newSL = openPrice + (TradeBELockPips * pip);
        }
      else
        {
         profitPips = (openPrice - ask) / pip;
         if(profitPips < TradeBETriggerPips)
            continue;
         newSL = openPrice - (TradeBELockPips * pip);
        }

      ModifySLIfBetter(ticket, newSL, tp, "BEC TRADE BE BULK");
     }

   SetBulkMode(false);
   DrawPanel();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CancelAllStopLossBulk()
  {
   if(!EnsureTradingEnabled())
      return;

   SetBulkMode(true);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      double tp = PositionGetDouble(POSITION_TP);
      double sl = PositionGetDouble(POSITION_SL);
      if(sl == 0.0)
         continue;

      PrepareTradeSymbol(Symbol());
      if(!Trade.PositionModify(ticket, 0.0, tp))
         Print("BEC CANCEL ALL SL: failed #", ticket, " err=", GetLastError());
     }

   SetBulkMode(false);
   DrawPanel();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllTradesAndOrdersBulk()
  {
   if(!EnsureTradingEnabled())
      return;

   SetBulkMode(true);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      ClosePositionProtected(ticket, "BEC CLOSE ALL");
     }

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(!OrderSelect(ticket))
         continue;
      if(OrderGetString(ORDER_SYMBOL) != Symbol())
         continue;

      PrepareTradeSymbol(Symbol());
      if(!Trade.OrderDelete(ticket))
         Print("BEC CLOSE ALL: failed delete order #", ticket, " err=", GetLastError());
     }

   SetBulkMode(false);
   DrawPanel();
  }

//============================================================
//  SINGLE BREAKEVEN LOGIC (ACCOUNT / EQUITY)
//============================================================
void DoSingleBE()
  {
   if(TimeCurrent() < LastAdjustment + DelayBetweenAdjustments)
      return;

   double BE_Price = BasketBEPrice;
   if(BE_Price <= 0.0)
      return;
   if(ProfitTotal < ProfitCurToTrigger)
      return;

   SetBulkMode(false);

   bool allProtected = ApplyAccountBEStopsFast(BE_Price);

   SetBulkMode(false);

   if(allProtected)
      LastAdjustment = TimeCurrent();
   else
      LastAdjustment = TimeCurrent() - DelayBetweenAdjustments;
  }

//============================================================
//  TRAILING STOP LOGIC (PRICE DISTANCE)
//============================================================
void DoTrailingStop()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0 || !PositionSelectByTicket(ticket))
         continue;
      if(SymbolInfoInteger(PositionGetString(POSITION_SYMBOL), SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_DISABLED)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      string sym      = PositionGetString(POSITION_SYMBOL);
      double point    = SymbolInfoDouble(sym, SYMBOL_POINT);
      double TSTP     = TrailingStop * point;
      double P        = TrailingProfit * point;
      double Bid      = SymbolInfoDouble(sym, SYMBOL_BID);
      double Ask      = SymbolInfoDouble(sym, SYMBOL_ASK);
      double OpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double StopLoss  = PositionGetDouble(POSITION_SL);
      double TakeProfit= PositionGetDouble(POSITION_TP);
      int    eDigits   = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      double TickSize  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         if(NormalizeDouble(Bid - OpenPrice, eDigits) >= NormalizeDouble(P, eDigits))
           {
            double new_sl = NormalizeDouble(Bid - TSTP, eDigits);
            if(TickSize > 0.0)
               new_sl = NormalizeDouble(MathRound(new_sl / TickSize) * TickSize, eDigits);

            if((TSTP != 0.0) && (StopLoss < new_sl))
               Trade.PositionModify(ticket, new_sl, TakeProfit);
           }
        }
      else
        {
         if(NormalizeDouble(OpenPrice - Ask, eDigits) >= NormalizeDouble(P, eDigits))
           {
            double new_sl = NormalizeDouble(Ask + TSTP, eDigits);
            if(TickSize > 0.0)
               new_sl = NormalizeDouble(MathRound(new_sl / TickSize) * TickSize, eDigits);

            if((TSTP != 0.0) && ((StopLoss > new_sl) || (StopLoss == 0.0)))
               Trade.PositionModify(ticket, new_sl, TakeProfit);
           }
        }
     }
  }

//============================================================
//  PER-TRADE BREAKEVEN LOCK PROFIT
//============================================================
void DoPerTradeBreakEvenLock()
  {
   string sym = Symbol();
   double pip = PipSize(sym);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != sym)
         continue;
      if(!ApplyFilters())
         continue;

      long   type      = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double tp        = PositionGetDouble(POSITION_TP);
      double bid       = SymbolInfoDouble(sym, SYMBOL_BID);
      double ask       = SymbolInfoDouble(sym, SYMBOL_ASK);

      double profitPips = 0.0;
      double newSL = 0.0;

      if(type == POSITION_TYPE_BUY)
        {
         profitPips = (bid - openPrice) / pip;
         if(profitPips < TradeBETriggerPips)
            continue;
         newSL = openPrice + (TradeBELockPips * pip);
        }
      else
        {
         profitPips = (openPrice - ask) / pip;
         if(profitPips < TradeBETriggerPips)
            continue;
         newSL = openPrice - (TradeBELockPips * pip);
        }

      if(ModifySLIfBetter(ticket, newSL, tp, "BEC TRADE BE AUTO"))
         SendBENotification((long)ticket, newSL, sym);
     }
  }

//============================================================
//  POSITION TRAIL FROM CURRENT SL
//============================================================
void DoPositionBasedTrailing()
  {
   string sym = Symbol();
   double pip = PipSize(sym);
   double stepPips = MathMax(1.0, (double)PositionTrailStepPips);

   ClearStalePosTrailStates();

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != sym)
         continue;
      if(!ApplyFilters())
         continue;

      long   type      = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double tp        = PositionGetDouble(POSITION_TP);
      double bid       = SymbolInfoDouble(sym, SYMBOL_BID);
      double ask       = SymbolInfoDouble(sym, SYMBOL_ASK);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentPx = (type == POSITION_TYPE_BUY) ? bid : ask;

      if(!EnsurePosTrailState(ticket, sym, type, currentSL, openPrice, bid, ask))
         continue;

      int idx = FindPosTrailState(ticket);
      if(idx < 0)
         continue;

      double anchor   = g_posTrailStates[idx].anchor_price;
      double startSL  = g_posTrailStates[idx].start_sl;
      double movePips = 0.0;
      double newSL    = 0.0;

      if(type == POSITION_TYPE_BUY)
        {
         movePips = (currentPx - anchor) / pip;
         if(movePips < stepPips)
            continue;

         newSL = startSL + (stepPips * pip);

         if(ModifySLIfBetter(ticket, newSL, tp, "BEC POS TRAIL"))
           {
            g_posTrailStates[idx].start_sl     = newSL;
            g_posTrailStates[idx].anchor_price = currentPx;
            SendTSNotification(ticket, newSL, sym);
           }
        }
      else
        {
         movePips = (anchor - currentPx) / pip;
         if(movePips < stepPips)
            continue;

         newSL = startSL - (stepPips * pip);

         if(ModifySLIfBetter(ticket, newSL, tp, "BEC POS TRAIL"))
           {
            g_posTrailStates[idx].start_sl     = newSL;
            g_posTrailStates[idx].anchor_price = currentPx;
            SendTSNotification(ticket, newSL, sym);
           }
        }
     }
  }

//============================================================
//  SCALPING TRAILING
//============================================================
void DoScalpTrailing()
  {
   string sym = Symbol();
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   int digits   = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);

   double pip = (digits == 3 || digits == 5) ? 10.0 * point : point;
   double trail = ScalpingTrailPips * pip;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;

      if(PositionGetString(POSITION_SYMBOL) != sym)
         continue;
      if(PositionGetString(POSITION_COMMENT) != "BEC-SCALP")
         continue;

      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl   = PositionGetDouble(POSITION_SL);
      double tp   = PositionGetDouble(POSITION_TP);

      double bid = SymbolInfoDouble(sym, SYMBOL_BID);
      double ask = SymbolInfoDouble(sym, SYMBOL_ASK);

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         double profitDistance = bid - open;
         if(profitDistance >= ScalpingStartPips * pip)
           {
            double newSL = NormalizeDouble(bid - trail, digits);
            if(sl == 0.0 || newSL > sl)
               ModifySLIfBetter(ticket, newSL, tp, "BEC TRADE BE BULK");
           }
        }

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
         double profitDistance = open - ask;
         if(profitDistance >= ScalpingStartPips * pip)
           {
            double newSL = NormalizeDouble(ask + trail, digits);
            if(sl == 0.0 || newSL < sl)
               ModifySLIfBetter(ticket, newSL, tp, "BEC TRADE BE BULK");
           }
        }
     }
  }

//============================================================
//  BREAKEVEN CALCULATION
//============================================================
double CalculateBasketPreviewPrice(double targetProfit)
  {
   PositionsLong  = 0;
   double VolumeLong  = 0.0, ProfitLong  = 0.0;
   PositionsShort = 0;
   double VolumeShort = 0.0, ProfitShort = 0.0;

   ProfitTotal    = 0.0;
   BasketBEPrice  = 0.0;
   LockedProfit   = targetProfit;

   AccCurrency = AccountInfoString(ACCOUNT_CURRENCY);
   double point_value_risk = CalculatePointValue(Risk);
   if(point_value_risk == 0.0)
      return 0.0;

   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
     {
      string Instrument = PositionGetSymbol(i);
      if(Instrument == "" || Instrument != Symbol())
         continue;
      if(!ApplyFilters())
         continue;

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         PositionsLong++;
         VolumeLong += PositionGetDouble(POSITION_VOLUME);
         ProfitLong += PositionGetDouble(POSITION_PROFIT);
         if(AdjustForSwapsCommission)
            ProfitLong += PositionGetDouble(POSITION_SWAP) + CalculateCommission();
         if((PositionsShort > 0) && (AdjustToPrice == ADJUST_TO_ASK))
            ProfitLong -= SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * _Point * PositionGetDouble(POSITION_VOLUME) * point_value_risk;
        }
      else
        {
         PositionsShort++;
         VolumeShort += PositionGetDouble(POSITION_VOLUME);
         ProfitShort += PositionGetDouble(POSITION_PROFIT);
         if(AdjustForSwapsCommission)
            ProfitShort += PositionGetDouble(POSITION_SWAP) + CalculateCommission();
         if((PositionsLong > 0) && (AdjustToPrice == ADJUST_TO_BID))
            ProfitShort -= SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) * _Point * PositionGetDouble(POSITION_VOLUME) * point_value_risk;
        }
     }

   double VolumeTotal = VolumeLong - VolumeShort;
   ProfitTotal = ProfitLong + ProfitShort;

   if((PositionsLong + PositionsShort) == 0 || VolumeTotal == 0.0)
      return 0.0;

   double DistancePoints = (targetProfit - ProfitTotal) / MathAbs(VolumeTotal * point_value_risk);
   double BE_Price = 0.0;

   if(VolumeTotal > 0.0)
      BE_Price = SymbolInfoDouble(Symbol(), SYMBOL_BID) + DistancePoints;
   else
      BE_Price = SymbolInfoDouble(Symbol(), SYMBOL_ASK) - DistancePoints;

   BasketBEPrice = BE_Price;
   return BE_Price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateSingleBreakeven()
  {
   double targetProfit = MathMax(0.0, AdditionalProfitCurLive);
   double previewPrice = CalculateBasketPreviewPrice(targetProfit);

   if(previewPrice <= 0.0)
      return 0.0;

   if(ProfitTotal < ProfitCurToTrigger)
      return 0.0;

   return previewPrice;
  }

//============================================================
//  COMMISSION CALCULATOR
//============================================================
double CalculateCommission()
  {
   double commission_sum = 0.0;
   if(!HistorySelectByPosition(PositionGetInteger(POSITION_IDENTIFIER)))
      return 0.0;

   int deals_total = HistoryDealsTotal();
   for(int i = 0; i < deals_total; i++)
     {
      ulong deal_ticket = HistoryDealGetTicket(i);
      if(deal_ticket == 0)
         continue;
      if((HistoryDealGetInteger(deal_ticket, DEAL_TYPE) != DEAL_TYPE_BUY) &&
         (HistoryDealGetInteger(deal_ticket, DEAL_TYPE) != DEAL_TYPE_SELL))
         continue;
      if(HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) != DEAL_ENTRY_IN)
         continue;
      commission_sum += HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
     }
   return commission_sum;
  }

//============================================================
//  POINT VALUE CALCULATION
//============================================================
double CalculatePointValue(mode_of_operation mode)
  {
   string cp = Symbol();
   double UnitCost = CalculateUnitCost(cp, mode);
   double OnePoint = SymbolInfoDouble(cp, SYMBOL_POINT);
   if(OnePoint == 0.0)
      return 0.0;
   return (UnitCost / OnePoint);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateUnitCost(const string cp, const mode_of_operation mode)
  {
   ENUM_SYMBOL_CALC_MODE CalcMode = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(cp, SYMBOL_TRADE_CALC_MODE);
   if((CalcMode != SYMBOL_CALC_MODE_FOREX) && (CalcMode != SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE) &&
      (CalcMode != SYMBOL_CALC_MODE_FUTURES) && (CalcMode != SYMBOL_CALC_MODE_EXCH_FUTURES) &&
      (CalcMode != SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS))
     {
      double TickSize = SymbolInfoDouble(cp, SYMBOL_TRADE_TICK_SIZE);
      double UnitCost = TickSize * SymbolInfoDouble(cp, SYMBOL_TRADE_CONTRACT_SIZE);
      string ProfitCurrency = SymbolInfoString(cp, SYMBOL_CURRENCY_PROFIT);
      if(ProfitCurrency == "RUR")
         ProfitCurrency = "RUB";
      if(ProfitCurrency != AccCurrency)
         return (UnitCost * CalculateAdjustment(ProfitCurrency, mode));
      return UnitCost;
     }
   else
     {
      if(mode == Risk)
         return SymbolInfoDouble(cp, SYMBOL_TRADE_TICK_VALUE_LOSS);
      else
         return SymbolInfoDouble(cp, SYMBOL_TRADE_TICK_VALUE_PROFIT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateAdjustment(const string ProfitCurrency, const mode_of_operation mode)
  {
   string ReferenceSymbol = GetSymbolByCurrencies(ProfitCurrency, AccCurrency);
   bool ReferenceSymbolMode = true;

   if(ReferenceSymbol == NULL)
     {
      ReferenceSymbol = GetSymbolByCurrencies(AccCurrency, ProfitCurrency);
      ReferenceSymbolMode = false;
     }

   if(ReferenceSymbol == NULL)
     {
      Print("BEC: Cannot detect adjustment currency pair.");
      return 1.0;
     }

   MqlTick tick;
   SymbolInfoTick(ReferenceSymbol, tick);
   return GetCurrencyCorrectionCoefficient(tick, mode, ReferenceSymbolMode);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetSymbolByCurrencies(string base_currency, string profit_currency)
  {
   for(int s = 0; s < SymbolsTotal(false); s++)
     {
      string symbolname = SymbolName(s, false);

      if((SymbolInfoInteger(symbolname, SYMBOL_TRADE_CALC_MODE) != SYMBOL_CALC_MODE_FOREX) &&
         (SymbolInfoInteger(symbolname, SYMBOL_TRADE_CALC_MODE) != SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE))
         continue;

      string b_cur = SymbolInfoString(symbolname, SYMBOL_CURRENCY_BASE);
      string p_cur = SymbolInfoString(symbolname, SYMBOL_CURRENCY_PROFIT);

      if(b_cur == "RUR")
         b_cur = "RUB";
      if(p_cur == "RUR")
         p_cur = "RUB";

      if((b_cur == base_currency) && (p_cur == profit_currency))
        {
         if(!(bool)SymbolInfoInteger(symbolname, SYMBOL_SELECT))
            SymbolSelect(symbolname, true);
         return symbolname;
        }
     }

   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetCurrencyCorrectionCoefficient(MqlTick &tick, const mode_of_operation mode, const bool ReferenceSymbolMode)
  {
   if((tick.ask == 0.0) || (tick.bid == 0.0))
      return -1.0;

   if(mode == Risk)
     {
      if(ReferenceSymbolMode)
         return tick.ask;
      else
         return (1.0 / tick.bid);
     }
   else
     {
      if(ReferenceSymbolMode)
         return tick.bid;
      else
         return (1.0 / tick.ask);
     }
  }

//============================================================
//  NOTIFICATIONS
//============================================================
void SendBENotification(long Ticket, double Price, string Instrument)
  {
   if(!EnableNotify || (!SendAlert && !SendApp && !SendEmail))
      return;

   string msg = "BEC Breakeven: SL for position #" + IntegerToString((int)Ticket) + " -> " + DoubleToString(Price, _Digits);

   if(SendAlert)
      Alert(msg);
   if(SendEmail)
      SendMail("BEC " + Instrument + " BE Notification", msg);
   if(SendApp)
      SendNotification(msg);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTSNotification(ulong Ticket, double Price, string Instrument)
  {
   if(!EnableNotify || (!SendAlert && !SendApp && !SendEmail))
      return;

   string msg = "BEC Trailing Stop: SL for position #" + IntegerToString((int)Ticket) + " -> " + DoubleToString(Price, _Digits);

   if(SendAlert)
      Alert(msg);
   if(SendEmail)
      SendMail("BEC " + Instrument + " TS Notification", msg);
   if(SendApp)
      SendNotification(msg);
  }

//============================================================
//  DASHBOARD — GET TODAY'S PROFIT FROM HISTORY
//============================================================
double GetTodayProfit()
  {
   datetime today_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   HistorySelect(today_start, TimeCurrent());

   double dayProfit = 0.0;
   int deals = HistoryDealsTotal();

   for(int i = 0; i < deals; i++)
     {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0)
         continue;
      if(HistoryDealGetString(deal, DEAL_SYMBOL) != Symbol())
         continue;

      if((HistoryDealGetInteger(deal, DEAL_TYPE) == DEAL_TYPE_BUY) ||
         (HistoryDealGetInteger(deal, DEAL_TYPE) == DEAL_TYPE_SELL))
        {
         dayProfit += HistoryDealGetDouble(deal, DEAL_PROFIT)
                      +  HistoryDealGetDouble(deal, DEAL_SWAP)
                      +  HistoryDealGetDouble(deal, DEAL_COMMISSION);
        }
     }

   return dayProfit;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetFloatingProfit()
  {
   double floating = 0.0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;

      floating += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }

   return floating;
  }

//============================================================
//  CHART VISUALS
//============================================================
datetime GetRightSideTime()
  {
   int visible_bars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS, 0);
   if(visible_bars <= 0)
      visible_bars = 100;

   int shift = MathMax(0, visible_bars / 8);
   if(shift > 3)
      shift = 3;

   datetime t = iTime(Symbol(), Period(), shift);
   if(t <= 0)
      t = TimeCurrent();

   return t;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBasketBELine()
  {
   if(!ShowBasketBELine || BasketBEPrice <= 0.0)
     {
      RemoveBasketBELine();
      return;
     }

   if(ObjectFind(0, ObjBasketBE) < 0)
      ObjectCreate(0, ObjBasketBE, OBJ_HLINE, 0, 0, BasketBEPrice);

   string lockText = HasCustomLockProfit ? DoubleToString(AdditionalProfitCurLive, 2) + " custom"
                     : DoubleToString(AdditionalProfitCurLive, 2) + " settings";

   ObjectSetDouble(0, ObjBasketBE, OBJPROP_PRICE, BasketBEPrice);
   ObjectSetInteger(0, ObjBasketBE, OBJPROP_COLOR, EnableBE ? C'255,170,6' : C'160,160,160');
   ObjectSetInteger(0, ObjBasketBE, OBJPROP_WIDTH, EnableBE ? 2 : 1);
   ObjectSetInteger(0, ObjBasketBE, OBJPROP_STYLE, EnableBE ? STYLE_SOLID : STYLE_DASH);
   ObjectSetInteger(0, ObjBasketBE, OBJPROP_BACK, true);
   ObjectSetInteger(0, ObjBasketBE, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, ObjBasketBE, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, ObjBasketBE, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, ObjBasketBE, OBJPROP_ZORDER, ChartZOrder);
   ObjectSetString(0, ObjBasketBE, OBJPROP_TEXT,
                   (EnableBE ? "ACC BE ACTIVE | Lock " : "ACC BE PREVIEW | Lock ") + lockText + " " + AccountInfoString(ACCOUNT_CURRENCY));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveBasketBELine()
  {
   if(ObjectFind(0, ObjBasketBE) >= 0)
      ObjectDelete(0, ObjBasketBE);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color TradeFloatingColor(double profit)
  {
   return (profit >= 0.0 ? clrLime : clrRed);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TradeFloatingText(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket))
      return "";

   double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   string sign = (profit >= 0.0 ? "+" : "");
   return sign + DoubleToString(profit, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SLValueText(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket))
      return "";

   double sl = PositionGetDouble(POSITION_SL);
   if(sl == 0.0)
      return "";

   return "SL " + DoubleToString(sl, _Digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTradeFloatingObjects()
  {
   string sym = Symbol();
   datetime rightTime = GetRightSideTime();
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL) != sym)
         continue;
      if(!ApplyFilters())
         continue;

      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double profit    = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      double sl        = PositionGetDouble(POSITION_SL);
      color c          = TradeFloatingColor(profit);

      string lineName   = ObjTradeLinePrefix + IntegerToString((int)ticket);
      string textName   = ObjTradeTextPrefix + IntegerToString((int)ticket);
      string slLineName = ObjSLLinePrefix + IntegerToString((int)ticket);
      string slTextName = ObjSLTextPrefix + IntegerToString((int)ticket);

      if(ObjectFind(0, lineName) < 0)
         ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, openPrice);

      ObjectSetDouble(0, lineName, OBJPROP_PRICE, openPrice);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, c);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, lineName, OBJPROP_ZORDER, ChartZOrder);

      double tradeLabelPrice = NormalizeDouble(openPrice + (TradeLabelOffsetPoints * point), digits);

      if(ObjectFind(0, textName) < 0)
         ObjectCreate(0, textName, OBJ_TEXT, 0, rightTime, tradeLabelPrice);

      ObjectMove(0, textName, 0, rightTime, tradeLabelPrice);
      ObjectSetString(0, textName, OBJPROP_TEXT, TradeFloatingText(ticket));
      ObjectSetInteger(0, textName, OBJPROP_COLOR, c);
      ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, FontSize + 2);
      ObjectSetString(0, textName, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, textName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, textName, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, textName, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, textName, OBJPROP_BACK, false);
      ObjectSetInteger(0, textName, OBJPROP_ZORDER, PanelZOrderBase - 100);

      if(sl != 0.0)
        {
         if(ObjectFind(0, slLineName) < 0)
            ObjectCreate(0, slLineName, OBJ_HLINE, 0, 0, sl);

         ObjectSetDouble(0, slLineName, OBJPROP_PRICE, sl);
         ObjectSetInteger(0, slLineName, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, slLineName, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, slLineName, OBJPROP_STYLE, STYLE_DASHDOTDOT);
         ObjectSetInteger(0, slLineName, OBJPROP_BACK, true);
         ObjectSetInteger(0, slLineName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, slLineName, OBJPROP_SELECTED, false);
         ObjectSetInteger(0, slLineName, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, slLineName, OBJPROP_ZORDER, ChartZOrder);

         double slLabelPrice = NormalizeDouble(sl + (SLLabelOffsetPoints * point), digits);

         if(ObjectFind(0, slTextName) < 0)
            ObjectCreate(0, slTextName, OBJ_TEXT, 0, rightTime, slLabelPrice);

         ObjectMove(0, slTextName, 0, rightTime, slLabelPrice);
         ObjectSetString(0, slTextName, OBJPROP_TEXT, SLValueText(ticket));
         ObjectSetInteger(0, slTextName, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, slTextName, OBJPROP_FONTSIZE, FontSize + 1);
         ObjectSetString(0, slTextName, OBJPROP_FONT, "Consolas");
         ObjectSetInteger(0, slTextName, OBJPROP_ANCHOR, ANCHOR_LEFT);
         ObjectSetInteger(0, slTextName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, slTextName, OBJPROP_SELECTED, false);
         ObjectSetInteger(0, slTextName, OBJPROP_HIDDEN, false);
         ObjectSetInteger(0, slTextName, OBJPROP_BACK, false);
         ObjectSetInteger(0, slTextName, OBJPROP_ZORDER, PanelZOrderBase - 100);
        }
      else
        {
         if(ObjectFind(0, slLineName) >= 0)
            ObjectDelete(0, slLineName);
         if(ObjectFind(0, slTextName) >= 0)
            ObjectDelete(0, slTextName);
        }
     }

   RemoveMissingTradeObjects();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveTradeFloatingObjects()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, ObjTradeLinePrefix) == 0 ||
         StringFind(name, ObjTradeTextPrefix) == 0 ||
         StringFind(name, ObjSLLinePrefix) == 0 ||
         StringFind(name, ObjSLTextPrefix) == 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveMissingTradeObjects()
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);

      bool ours =
         (StringFind(name, ObjTradeLinePrefix) == 0) ||
         (StringFind(name, ObjTradeTextPrefix) == 0) ||
         (StringFind(name, ObjSLLinePrefix) == 0) ||
         (StringFind(name, ObjSLTextPrefix) == 0);

      if(!ours)
         continue;

      string ticketStr = "";
      if(StringFind(name, ObjTradeLinePrefix) == 0)
         ticketStr = StringSubstr(name, StringLen(ObjTradeLinePrefix));
      else
         if(StringFind(name, ObjTradeTextPrefix) == 0)
            ticketStr = StringSubstr(name, StringLen(ObjTradeTextPrefix));
         else
            if(StringFind(name, ObjSLLinePrefix) == 0)
               ticketStr = StringSubstr(name, StringLen(ObjSLLinePrefix));
            else
               if(StringFind(name, ObjSLTextPrefix) == 0)
                  ticketStr = StringSubstr(name, StringLen(ObjSLTextPrefix));

      ulong ticket = (ulong)StringToInteger(ticketStr);
      if(ticket == 0 || !PositionSelectByTicket(ticket) || PositionGetString(POSITION_SYMBOL) != Symbol())
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdatePanelOrigin()
  {
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);

   PanelOriginX = Xoff;
   PanelOriginY = Yoff;

   if(ChartCorner == CORNER_RIGHT_UPPER || ChartCorner == CORNER_RIGHT_LOWER)
      PanelOriginX = MathMax(0, chartW - Xoff - PanelWidthPx);

   if(ChartCorner == CORNER_LEFT_LOWER || ChartCorner == CORNER_RIGHT_LOWER)
      PanelOriginY = MathMax(0, chartH - Yoff - PanelHeightPx);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PanelCoordX(int localX, int objW)
  {
   return PanelOriginX + localX;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PanelCoordY(int localY, int objH)
  {
   return PanelOriginY + localY;
  }

//============================================================
//  DRAW PANEL HELPER
//
//  FIX #3 — PANEL ON TOP:
//  The key rule in MT5 is:
//    OBJPROP_BACK = false  → foreground layer (in front of price)
//    OBJPROP_BACK = true   → background layer (behind price/indicators)
//
//  All indicator/EA chart objects (arrows, lines, labels drawn by
//  other EAs and indicators) are ALWAYS in the background layer.
//  So every BEC panel object must have OBJPROP_BACK=false.
//
//  Additionally MT5 orders objects within the same layer by
//  OBJPROP_ZORDER (higher = on top). We use:
//    PanelZOrderBase   = 2147483000  (background rect)
//    PanelZOrderButton = 2147483001  (buttons/labels, one step higher)
//
//  This guarantees:
//    - The panel background sits on top of ALL indicator objects
//    - The buttons sit on top of the background rect
//    - Nothing from other EAs/indicators can pierce through
//============================================================
void CreateLabel(string name, int x, int y, int w, int h, string text,
                 color fg, color bg, int fsize, bool bold = false,
                 ENUM_ALIGN_MODE align = ALIGN_CENTER, bool selectable = false)
  {
   if(ObjectFind(ChartID(), name) >= 0)
      ObjectDelete(ChartID(), name);

   ObjectCreate(ChartID(), name, OBJ_BUTTON, 0, 0, 0);

   ObjectSetInteger(ChartID(), name, OBJPROP_CORNER,       CORNER_LEFT_UPPER);
   ObjectSetInteger(ChartID(), name, OBJPROP_XDISTANCE,    PanelCoordX(x, w));
   ObjectSetInteger(ChartID(), name, OBJPROP_YDISTANCE,    PanelCoordY(y, h));
   ObjectSetInteger(ChartID(), name, OBJPROP_XSIZE,        w);
   ObjectSetInteger(ChartID(), name, OBJPROP_YSIZE,        h);
   ObjectSetString(ChartID(),  name, OBJPROP_TEXT,         text);
   ObjectSetInteger(ChartID(), name, OBJPROP_COLOR,        fg);
   ObjectSetInteger(ChartID(), name, OBJPROP_BGCOLOR,      bg);
   ObjectSetInteger(ChartID(), name, OBJPROP_BORDER_COLOR, clrNONE);
   ObjectSetInteger(ChartID(), name, OBJPROP_FONTSIZE,     fsize);
   ObjectSetString(ChartID(),  name, OBJPROP_FONT,         "Consolas");
   ObjectSetInteger(ChartID(), name, OBJPROP_ALIGN,        align);
   ObjectSetInteger(ChartID(), name, OBJPROP_HIDDEN,       false);
   ObjectSetInteger(ChartID(), name, OBJPROP_READONLY,     !selectable);
   ObjectSetInteger(ChartID(), name, OBJPROP_SELECTABLE,   true);
   ObjectSetInteger(ChartID(), name, OBJPROP_SELECTED,     false);
   ObjectSetInteger(ChartID(), name, OBJPROP_BACK,         false);   // FIX: foreground layer
   ObjectSetInteger(ChartID(), name, OBJPROP_ZORDER,       PanelZOrderButton);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateEdit(string name, int x, int y, int w, int h, string text,
                color fg, color bg, int fsize)
  {
   bool exists = (ObjectFind(ChartID(), name) >= 0);
   string currentText = text;

   if(exists && LockEditActive)
      currentText = ObjectGetString(ChartID(), name, OBJPROP_TEXT);

   if(!exists)
      ObjectCreate(ChartID(), name, OBJ_EDIT, 0, 0, 0);

   ObjectSetInteger(ChartID(), name, OBJPROP_CORNER,       CORNER_LEFT_UPPER);
   ObjectSetInteger(ChartID(), name, OBJPROP_XDISTANCE,    PanelCoordX(x, w));
   ObjectSetInteger(ChartID(), name, OBJPROP_YDISTANCE,    PanelCoordY(y, h));
   ObjectSetInteger(ChartID(), name, OBJPROP_XSIZE,        w);
   ObjectSetInteger(ChartID(), name, OBJPROP_YSIZE,        h);
   if(!LockEditActive)
      ObjectSetString(ChartID(),  name, OBJPROP_TEXT,      currentText);
   ObjectSetInteger(ChartID(), name, OBJPROP_COLOR,        fg);
   ObjectSetInteger(ChartID(), name, OBJPROP_BGCOLOR,      bg);
   ObjectSetInteger(ChartID(), name, OBJPROP_BORDER_COLOR, clrNONE);
   ObjectSetInteger(ChartID(), name, OBJPROP_FONTSIZE,     fsize);
   ObjectSetString(ChartID(),  name, OBJPROP_FONT,         "Consolas");
   ObjectSetInteger(ChartID(), name, OBJPROP_ALIGN,        ALIGN_CENTER);
   ObjectSetInteger(ChartID(), name, OBJPROP_HIDDEN,       false);
   ObjectSetInteger(ChartID(), name, OBJPROP_READONLY,     false);
   ObjectSetInteger(ChartID(), name, OBJPROP_SELECTABLE,   true);
   ObjectSetInteger(ChartID(), name, OBJPROP_SELECTED,     LockEditActive);
   ObjectSetInteger(ChartID(), name, OBJPROP_BACK,         false);   // FIX: foreground layer
   ObjectSetInteger(ChartID(), name, OBJPROP_ZORDER,       PanelZOrderButton);
  }

//============================================================
//  DRAW PANEL — BEC BRANDED DASHBOARD
//============================================================
void DrawPanel()
  {
   int w = 310;
   int rowH = 24;
   int gap  = 5;
   int halfW = w / 2 - 1;
   int localY = 2;

   color cDark       = C'42,46,57';
   color cDark2      = C'44,48,53';
   color cGreen      = C'76,174,76';
   color cGreenDark  = C'61,158,61';
   color cWhite      = clrWhite;
   color cGold       = C'255,170,6';
   color cBorder     = cDark;
   color cRed        = C'220,60,60';
   color cBlue       = C'0,100,180';
   color cPurple     = C'106,76,255';
   color cOrange     = C'210,120,20';

   double floating   = GetFloatingProfit();
   double equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   double dayProfit  = GetTodayProfit();
   double bid        = SymbolInfoDouble(Symbol(), SYMBOL_BID);

   color floatColor = (floating >= 0.0) ? cGreen : cRed;
   color dayColor   = (dayProfit >= 0.0) ? cGreen : cRed;

   PanelWidthPx = w + 4;

   int scalpRowY    = localY;
   localY += rowH + gap;
   int closeAllRowY = localY;
   localY += rowH + gap;
   int beAllRowY    = localY;
   localY += rowH + gap;
   int halfRowY     = localY;
   localY += rowH + gap;
   int closeRowY    = localY;
   localY += rowH + gap;
   int trailRowY    = localY;
   localY += rowH + gap;
   int beRowY       = localY;
   localY += rowH + gap;
   int lockRowY     = localY;
   localY += rowH;
   int dayRowY      = localY;
   localY += rowH;
   int floatRowY    = localY;
   localY += rowH;
   int equityRowY   = localY;
   localY += rowH;
   int priceRowY    = localY;
   localY += rowH;
   int titleRowY    = localY;
   localY += rowH + 2;

   PanelHeightPx = localY + 2;
   UpdatePanelOrigin();

   if(ObjectFind(ChartID(), PanelBase) >= 0)
      ObjectDelete(ChartID(), PanelBase);

   ObjectCreate(ChartID(), PanelBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_XDISTANCE,   PanelCoordX(0, PanelWidthPx));
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_YDISTANCE,   PanelCoordY(0, PanelHeightPx));
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_XSIZE,       PanelWidthPx);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_YSIZE,       PanelHeightPx);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_BGCOLOR,     cDark);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_COLOR,       cBorder);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_HIDDEN,      false);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_SELECTED,    false);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_BACK,        false);
   ObjectSetInteger(ChartID(), PanelBase, OBJPROP_ZORDER,      PanelZOrderBase);

   string scalpSellText = "SCALP SELL " + DoubleToString(ScalpingLot, 2);
   string scalpBuyText  = "SCALP BUY "  + DoubleToString(ScalpingLot, 2);
   CreateLabel(PanelScalpSell, 2, scalpRowY, halfW, rowH+2, scalpSellText, clrWhite, C'180,0,0', FontSize, true, ALIGN_CENTER, true);
   CreateLabel(PanelScalpBuy,  2 + (w/2) + 1, scalpRowY, halfW, rowH+2, scalpBuyText, clrWhite, C'0,150,0', FontSize, true, ALIGN_CENTER, true);

   CreateLabel(PanelBtnCloseAll, 2, closeAllRowY, w, rowH+2, "Close All + Delete Orders", cWhite, cRed, FontSize-1, true, ALIGN_CENTER, true);

   CreateLabel(PanelBtnTradeBEAll, 2, beAllRowY, halfW, rowH+2, "BE Lock Profit (All)", cWhite, cOrange, FontSize-1, true, ALIGN_CENTER, true);
   CreateLabel(PanelBtnCancelAllSL, 2 + (w/2) + 1, beAllRowY, halfW, rowH+2, "Cancel All StopLoss", cWhite, C'120,60,180', FontSize-1, true, ALIGN_CENTER, true);

   CreateLabel(PanelBtnHalfBEAll, 2, halfRowY, halfW, rowH+2, "Close 50% + BE (All)", cWhite, cBlue, FontSize-1, true, ALIGN_CENTER, true);
   CreateLabel(PanelBtnHalfBEProfit, 2 + (w/2) + 1, halfRowY, halfW, rowH+2, "50% + BE (Profit)", cWhite, cPurple, FontSize-1, true, ALIGN_CENTER, true);

   CreateLabel(PanelBtnCloseProfit, 2, closeRowY, halfW, rowH+2, "Close Profit (All)", cDark, cGold, FontSize-1, true, ALIGN_CENTER, true);
   CreateLabel(PanelBtnCloseLoss, 2 + (w/2) + 1, closeRowY, halfW, rowH+2, "Close Loss (All)", cWhite, cRed, FontSize-1, true, ALIGN_CENTER, true);

   string tbeText = EnableTradeBE ? "TRADE BE ON" : "TRADE BE OFF";
   color  tbeBg   = EnableTradeBE ? cPurple : C'100,30,30';
   CreateLabel(PanelTradeBEToggle, 2, trailRowY, halfW, rowH+2, tbeText, cWhite, tbeBg, FontSize-1, false, ALIGN_CENTER, true);

   string ptrText = EnablePosTrail ? "POS TRAIL ON | " + IntegerToString(PositionTrailStepPips) : "POS TRAIL OFF";
   color  ptrBg   = EnablePosTrail ? cOrange : C'100,30,30';
   CreateLabel(PanelPosTrailToggle, 2 + (w/2) + 1, trailRowY, halfW, rowH+2, ptrText, cWhite, ptrBg, FontSize-1, false, ALIGN_CENTER, true);

   string beText  = EnableBE ? "ACC BE ON | +" + DoubleToString(LockedProfit, 2) : "ACC BE OFF";
   color  beBg    = EnableBE ? cGreenDark : C'100,30,30';
   CreateLabel(PanelBEToggle, 2, beRowY, halfW, rowH+2, beText, cWhite, beBg, FontSize-1, false, ALIGN_CENTER, true);

   string tsText  = EnablePosTrail ? "PRICE TRAIL WAIT" : (EnableTrail ? "PRICE TRAIL ON" : "PRICE TRAIL OFF");
   color  tsBg    = (EnableTrail && !EnablePosTrail) ? cGreenDark : C'100,30,30';
   if(EnablePosTrail)
      tsBg = C'90,70,30';
   CreateLabel(PanelTSToggle, 2 + (w/2) + 1, beRowY, halfW, rowH+2, tsText, cWhite, tsBg, FontSize-1, false, ALIGN_CENTER, true);

   int lockInfoW  = (w * 2 / 3) - 1;
   int lockValueW = (w / 3) - 1;
   CreateLabel(PanelLockInfo, 2, lockRowY, lockInfoW, rowH, "BE Lock PROFIT", cWhite, cDark, FontSize, false, ALIGN_CENTER, false);
   CreateLabel(PanelLocked, 2 + lockInfoW + 2, lockRowY, lockValueW, rowH, DoubleToString(AdditionalProfitCurLive, 2), cGold, cDark2, FontSize, true, ALIGN_CENTER, false);

   string dayStr = "Today: " + (dayProfit >= 0.0 ? "+" : "") + DoubleToString(dayProfit, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
   CreateLabel(PanelDayProfit, 2, dayRowY, w, rowH, dayStr, dayColor, cDark, FontSize, false, ALIGN_CENTER);

   string floatStr = "Float: " + (floating >= 0.0 ? "+" : "") + DoubleToString(floating, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
   CreateLabel(PanelFloating, 2, floatRowY, w, rowH, floatStr, floatColor, cDark, FontSize, false, ALIGN_CENTER);

   string eqStr = "Equity: " + DoubleToString(equity, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
   CreateLabel(PanelEquity, 2, equityRowY, w, rowH, eqStr, cWhite, cDark, FontSize, false, ALIGN_CENTER);

   string priceStr = DoubleToString(bid, _Digits);
   CreateLabel(PanelPrice, 2, priceRowY, w, rowH, priceStr, cWhite, cDark2, FontSize+5, true, ALIGN_CENTER);

   CreateLabel(PanelTitle, 2, titleRowY, w, rowH, "BEC  TRADE MANAGER  V2.71", cGold, cDark2, FontSize, true, ALIGN_LEFT);

   ChartRedraw();
  }

//============================================================
//  CLEAN PANEL
//============================================================
void CleanPanel()
  {
   ObjectsDeleteAll(ChartID(), "BEC-");
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
