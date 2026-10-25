//+------------------------------------------------------------------+
//|                                                  Grid EA Pro.mq5 |
//|                                   COPYRIGHT 2026, VIVEK PANU     |
//|                         https://www.mql5.com/en/users/vivekpanu  |
//+------------------------------------------------------------------+
#property copyright "COPYRIGHT 2026, VIVEK PANU"
#property link      "https://www.mql5.com/en/users/vivekpanu"
#property version   "3.0"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

CTrade        Trade;
CPositionInfo PosInfo;

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY
  {
   RSI_MODE       = 1,
   Fixed_Points   = 2,
   MANUAL         = 3
  };

enum ENUM_TRADE_MODE
  {
   BUY_ONLY  = 0,
   SELL_ONLY = 1,
   BOTH      = 2
  };

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input ENUM_TRADE_MODE    MODE             = BOTH;
input ENUM_STRATEGY      STRATEGY         = RSI_MODE;
//--- RSI Settings
input int                RSI_PERIOD       = 10;       // RSI Period
input int                UP_LEVEL         = 70;       // RSI Upper Level (Sell Signal)
input int                DN_LEVEL         = 30;       // RSI Lower Level (Buy Signal)
input ENUM_TIMEFRAMES    RSI_TIMEFRAME    = PERIOD_H4;// RSI Timeframe
//--- Entry Settings
input int                DISTANCE         = 50;       // Distance in pips (Fixed Points mode)
input int                TIMER_SEC        = 10;       // Timer interval in seconds
//--- Lot Settings
input double             VOLUME           = 0.01;     // Base lot size
input int                FROM_BALANCE     = 1000;     // Balance per base lot (0 = disabled)
input double             RISK_PER_TRADE   = 0.0;      // Risk % per trade (0 = disabled)
input double             LOT_MULTIPLIER   = 1.1;      // Lot multiplier for grid
input double             MAX_LOT          = 999.9;    // Maximum lot size
//--- Grid Settings
input int                STEP_ORDERS      = 100;      // Grid step in pips
input double             STEP_MULTIPLIER  = 1.1;      // Step multiplier
input int                MAX_STEP         = 1000;     // Maximum grid step
//--- Overlap Settings
input int                OVERLAP_ORDERS   = 5;        // Min orders before overlap activates
input int                OVERLAP_PIPS     = 10;       // Min profit pips to close overlapping orders
//--- SL/TP Settings
input int                STOPLOSS         = -1;       // Stop Loss in pips (-1 = disabled)
input int                TAKEPROFIT       = 500;      // Take Profit in pips (-1 = disabled)
//--- Breakeven Settings
input int                BREAKEVEN_STOP   = -1;       // Breakeven activation level (-1 = disabled)
input int                BREAKEVEN_STEP   = 10;       // Breakeven step in pips
//--- Trailing Stop Settings
input int                TRAILING_STOP    = 50;       // Trailing stop level (-1 = disabled)
input int                TRAILING_STEP    = 50;       // Trailing step in pips
//--- Order Settings
input int                MAGIC_NUMBER     = -1;       // Magic Number (-1 = any)
input string             ORDERS_COMMENT   = "Grid EA Pro"; // Order comment
//--- Time Filter
input string             START_TIME       = "00:00";  // Start time (00:00 = disabled)
input string             END_TIME         = "00:00";  // End time   (00:00 = disabled)

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
bool   CLOSE_BUY  = false;
bool   CLOSE_SELL = false;
bool   CLOSE_ALL  = false;

double ZEROLEVEL_ALL  = 0, ZEROLEVEL_BUY = 0, ZEROLEVEL_SELL = 0;

double TRAILINGSTOP_BUY   = 0, TRAILINGSTEP_BUY  = 0;
double TRAILINGSTOP_SELL  = 0, TRAILINGSTEP_SELL = 0;

double BREAKEVENSTOP_BUY  = 0, BREAKEVENSTEP_BUY  = 0;
double BREAKEVENSTOP_SELL = 0, BREAKEVENSTEP_SELL = 0;

double TAKEPROFIT_BUY  = 0, STOPLOSS_BUY  = 0;
double TAKEPROFIT_SELL = 0, STOPLOSS_SELL = 0;

double BUY_PROFIT  = 0, SELL_PROFIT = 0;
double BUY_LOTS    = 0, SELL_LOTS   = 0;

double TICKVALUE = 0;
int    SPREAD    = 0;

int  PREV_BUYS  = 0, PREV_SELLS = 0;
bool DEINIT     = false;
bool FIRST_RUN  = true;

int  BUYS = 0, SELLS = 0, BUYLIMITS = 0, SELLLIMITS = 0, BUYSTOPS = 0, SELLSTOPS = 0;

color  BUTTONL_CLR = clrNONE;
double LAST_BID    = 0;
double TEMP_LOT    = 0;   // initialized in OnInit from VOLUME
double LAST_LOT    = 0;

int    WIN_TYPE   = 0, WIN_TICKET   = 0;
double WIN_PROFIT = 0, WIN_LOT      = 0;

int    LOSS_TYPE   = 0, LOSS_TICKET   = 0;
double LOSS_PROFIT = 0, LOSS_LOT      = 0;

double ZEROLEVEL     = 0;
double OVERLAP_CLOSE = 0;

double LAST_BUY_PRICE  = 0, LAST_BUY_LOT  = 0;
double LAST_SELL_PRICE = 0, LAST_SELL_LOT = 0;
double GRID_BUY_PRICE  = 0, GRID_SELL_PRICE = 0;

bool     SIGNAL      = true, SIGNAL_BUY = true, SIGNAL_SELL = true;
double   BUY_PRICE   = 0.0,  SELL_PRICE = 0.0;
int      INP_TIME    = 0;
datetime TIME_CURRENT = 0;
datetime TIMER_VAR   = 0;

// RSI handle — created ONCE in OnInit (MQL5 best practice)
int RSI_HANDLE = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Auto-detect broker filling mode (fixes "Unsupported filling mode")|
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetFillingMode(string symbol)
  {
   // Use SYMBOL_FILLING_MODE (not FLAGS) with return-value form — no reference needed
   long filling = SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
   if((filling & SYMBOL_FILLING_FOK) != 0) return ORDER_FILLING_FOK;
   if((filling & SYMBOL_FILLING_IOC) != 0) return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
  }

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   INP_TIME = TIMER_SEC;
   if(INP_TIME > 60)
      INP_TIME = 60;

   TEMP_LOT = VOLUME;

   // Create RSI handle ONCE here (not on every tick — common MQL5 mistake)
   RSI_HANDLE = iRSI(_Symbol, RSI_TIMEFRAME, RSI_PERIOD, PRICE_CLOSE);
   if(RSI_HANDLE == INVALID_HANDLE)
     {
      Print("ERROR: Failed to create RSI handle. Error: ", GetLastError());
      return(INIT_FAILED);
     }

   EventSetTimer(1);

   LAST_BID  = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   TICKVALUE = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   // Configure CTrade object
   Trade.SetExpertMagicNumber(MAGIC_NUMBER == -1 ? 0 : MAGIC_NUMBER);
   Trade.SetDeviationInPoints(10);
   Trade.SetTypeFilling(GetFillingMode(_Symbol));

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Save last lot from button before cleanup
   string lotText = ObjectGetString(0, "BUTTON_LOT", OBJPROP_TEXT);
   if(lotText != "")
      LAST_LOT = StringToDouble(lotText);

   EventKillTimer();
   DEINIT = true;

   // Release RSI indicator handle
   if(RSI_HANDLE != INVALID_HANDLE)
      IndicatorRelease(RSI_HANDLE);

   DEINIT_HLINE();
   DEINIT_BUTTON();
   DEINIT_LABEL();
  }

//+------------------------------------------------------------------+
//| Timer — calls OnTick                                             |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OnTick();
  }

//+------------------------------------------------------------------+
//| Chart Events (button clicks etc.)                                |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
      ON_CHART_EVENTS();
  }

//+------------------------------------------------------------------+
//| Main tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
  {
   // UI updates (not in optimization/testing unless visual)
   if(MQLInfoInteger(MQL_VISUAL_MODE) || (!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER)))
     {
      INFO();
      DRAW_BUTTON();
      ON_CHART_EVENTS();
      HLINE();
     }

   GET_TICKVALUE();

   BUY_PROFIT = BUY_LOTS = SELL_PROFIT = SELL_LOTS = 0;
   TOTAL_VALUE(BUY_PROFIT, BUY_LOTS, SELL_PROFIT, SELL_LOTS, MAGIC_NUMBER);

   BUYS = SELLS = BUYLIMITS = SELLLIMITS = BUYSTOPS = SELLSTOPS = 0;
   COUNT_ORDERS(BUYS, SELLS, BUYLIMITS, SELLLIMITS, BUYSTOPS, SELLSTOPS, MAGIC_NUMBER);

   if(OVERLAP_ORDERS > 0 && BUYS + SELLS >= OVERLAP_ORDERS)
      OVERLAP(-1);

   if(BUYS > 0)
     {
      if(TRAILING_STOP > 0)  VIRTUAL_TRAILINGSTOP((int)POSITION_TYPE_BUY);
      if(BREAKEVEN_STOP > 0) VIRTUAL_BREAKEVEN((int)POSITION_TYPE_BUY);
      if(STOPLOSS + TAKEPROFIT > 0) VIRTUAL_STOPLOSS_TAKEPROFIT((int)POSITION_TYPE_BUY);
     }

   if(SELLS > 0)
     {
      if(TRAILING_STOP > 0)  VIRTUAL_TRAILINGSTOP((int)POSITION_TYPE_SELL);
      if(BREAKEVEN_STOP > 0) VIRTUAL_BREAKEVEN((int)POSITION_TYPE_SELL);
      if(STOPLOSS + TAKEPROFIT > 0) VIRTUAL_STOPLOSS_TAKEPROFIT((int)POSITION_TYPE_SELL);
     }

   LAST_BUY_PRICE = LAST_BUY_LOT = LAST_SELL_PRICE = LAST_SELL_LOT = 0;
   OPENED_VALUES(LAST_BUY_PRICE, LAST_BUY_LOT, LAST_SELL_PRICE, LAST_SELL_LOT);

   if(WORKING_HOURS(START_TIME, END_TIME))
     {
      double LOT = LOT_CALCULATE(RISK_PER_TRADE, STOPLOSS, FROM_BALANCE, VOLUME);

      //--- STRATEGY 1: RSI Mode
      if(STRATEGY == RSI_MODE)
        {
         if(MQLInfoInteger(MQL_VISUAL_MODE) || (!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER)))
           {
            if(BUYS + SELLS > 0)
               Comment(
                  "WIN ORDER:  TYPE " + (string)WIN_TYPE  + ", TICKET " + (string)WIN_TICKET  + ", PROFIT " + DoubleToString(WIN_PROFIT, 2)  + ", LOT " + DoubleToString(WIN_LOT, 2)  + "\n" +
                  "LOSS ORDER: TYPE " + (string)LOSS_TYPE + ", TICKET " + (string)LOSS_TICKET + ", PROFIT " + DoubleToString(LOSS_PROFIT, 2) + ", LOT " + DoubleToString(LOSS_LOT, 2)
               );
           }

         // RSI checked on CANDLE CLOSE (index 1 = last closed bar) — fixes the random-trigger bug
         double rsiValue = GET_RSI_VALUE(1);

         if(CLOSE_SELL == false && SELLS == 0 && rsiValue >= UP_LEVEL)
           {
            if(MODE == BOTH || MODE == SELL_ONLY)
               ORDER_SEND(ORDER_TYPE_SELL, LOT, ORDERS_COMMENT, MAGIC_NUMBER);
           }

         if(CLOSE_BUY == false && BUYS == 0 && rsiValue <= DN_LEVEL)
           {
            if(MODE == BOTH || MODE == BUY_ONLY)
               ORDER_SEND(ORDER_TYPE_BUY, LOT, ORDERS_COMMENT, MAGIC_NUMBER);
           }
        }

      //--- STRATEGY 2: Fixed Points Mode
      if(STRATEGY == Fixed_Points)
        {
         TIME_CURRENT = TimeCurrent();

         if(INP_TIME == 0)
            SIGNAL = true;
         else
           {
            if(TIMER_VAR == 0) TIMER_VAR = TIME_CURRENT;
            if(TIME_CURRENT >= TIMER_VAR + INP_TIME)
              {
               SIGNAL     = true;
               TIMER_VAR += INP_TIME;
              }
           }

         if(SIGNAL)
           {
            if(BUYS == 0)  BUY_PRICE  = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + DISTANCE * _Point;
            if(SELLS == 0) SELL_PRICE = SymbolInfoDouble(_Symbol, SYMBOL_BID) - DISTANCE * _Point;
            SIGNAL      = false;
            SIGNAL_BUY  = true;
            SIGNAL_SELL = true;
           }

         if(SIGNAL_BUY)
           {
            if(BUY_PRICE > 0 && !(BUY_PRICE - SymbolInfoDouble(_Symbol, SYMBOL_ASK) > _Point))
              {
               if(BUYS == 0 && CLOSE_BUY == false)
                 {
                  if(MODE == BOTH || MODE == BUY_ONLY)
                     ORDER_SEND(ORDER_TYPE_BUY, LOT, ORDERS_COMMENT, MAGIC_NUMBER);
                  SIGNAL_BUY = false;
                  BUY_PRICE  = 0;
                  DEINIT_HLINE();
                 }
              }
           }

         if(SIGNAL_SELL)
           {
            if(SELL_PRICE > 0 && !(SymbolInfoDouble(_Symbol, SYMBOL_BID) - SELL_PRICE > _Point))
              {
               if(SELLS == 0 && CLOSE_SELL == false)
                 {
                  if(MODE == BOTH || MODE == SELL_ONLY)
                     ORDER_SEND(ORDER_TYPE_SELL, LOT, ORDERS_COMMENT, MAGIC_NUMBER);
                  SIGNAL_SELL = false;
                  SELL_PRICE  = 0;
                  DEINIT_HLINE();
                 }
              }
           }

         if(MQLInfoInteger(MQL_VISUAL_MODE) || (!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER)))
           {
            if(BUY_PRICE > 0)  OBJECT_HLINE("HLINE_BUY",  BUY_PRICE,  "OPEN BUY",  clrRed, 0);
            if(SELL_PRICE > 0) OBJECT_HLINE("HLINE_SELL", SELL_PRICE, "OPEN SELL", clrRed, 0);

            int PRINT_PRICE = 0, PRINT_TIME = 0;
            PRINT_TIME  = INP_TIME - (int)StringSubstr(TimeToString(TIME_CURRENT - TIMER_VAR, TIME_SECONDS), 6, 2);
            PRINT_PRICE = (int)MathMin(
                             (BUY_PRICE  - SymbolInfoDouble(_Symbol, SYMBOL_ASK)) / _Point,
                             (SymbolInfoDouble(_Symbol, SYMBOL_BID) - SELL_PRICE) / _Point);

            Comment(
               "WIN ORDER:  TYPE " + (string)WIN_TYPE  + ", TICKET " + (string)WIN_TICKET  + ", PROFIT " + DoubleToString(WIN_PROFIT, 2)  + ", LOT " + DoubleToString(WIN_LOT, 2)  + "\n" +
               "LOSS ORDER: TYPE " + (string)LOSS_TYPE + ", TICKET " + (string)LOSS_TICKET + ", PROFIT " + DoubleToString(LOSS_PROFIT, 2) + ", LOT " + DoubleToString(LOSS_LOT, 2) + "\n" +
               "DISTANCE: " + (string)PRINT_PRICE + " PIPS\n" +
               "TIMER: "    + (string)PRINT_TIME  + " SEC"
            );
           }
        }

      //--- Grid: add orders as price moves against positions
      if(STEP_ORDERS > 0)
        {
         if(BUYS > 0)
           {
            int STEP = (int)MathMin(STEP_ORDERS, MAX_STEP);
            if(STEP_MULTIPLIER > 1 && BUYS > 1)
               STEP = (int)MathMin((BUYS - 1) * STEP_MULTIPLIER * STEP_ORDERS, (double)MAX_STEP);

            LOT = LOT_CALCULATE(RISK_PER_TRADE, STOPLOSS, FROM_BALANCE, VOLUME);
            if(LOT_MULTIPLIER > 1 && BUYS > 0)
               LOT = MathMin(LAST_BUY_LOT * LOT_MULTIPLIER, MAX_LOT);

            GRID_BUY_PRICE = LAST_BUY_PRICE - STEP * _Point;

            if(SymbolInfoDouble(_Symbol, SYMBOL_ASK) <= GRID_BUY_PRICE && !CLOSE_ALL && !CLOSE_BUY)
               ORDER_SEND(ORDER_TYPE_BUY, LOT, ORDERS_COMMENT, MAGIC_NUMBER);
           }

         if(SELLS > 0)
           {
            int STEP = (int)MathMin(STEP_ORDERS, MAX_STEP);
            if(STEP_MULTIPLIER > 1 && SELLS > 1)
               STEP = (int)MathMin((SELLS - 1) * STEP_MULTIPLIER * STEP_ORDERS, (double)MAX_STEP);

            LOT = LOT_CALCULATE(RISK_PER_TRADE, STOPLOSS, FROM_BALANCE, VOLUME);
            if(LOT_MULTIPLIER > 1 && SELLS > 0)
               LOT = MathMin(LAST_SELL_LOT * LOT_MULTIPLIER, MAX_LOT);

            GRID_SELL_PRICE = LAST_SELL_PRICE + STEP * _Point;

            if(SymbolInfoDouble(_Symbol, SYMBOL_BID) >= GRID_SELL_PRICE && !CLOSE_ALL && !CLOSE_SELL)
               ORDER_SEND(ORDER_TYPE_SELL, LOT, ORDERS_COMMENT, MAGIC_NUMBER);
           }
        }
     }

   //--- Close logic
   if(CLOSE_BUY)
     {
      if(BUYS > 0) POSITIONS_CLOSE((int)POSITION_TYPE_BUY);
      if(BUYS == 0) CLOSE_BUY = false;
     }

   if(CLOSE_SELL)
     {
      if(SELLS > 0) POSITIONS_CLOSE((int)POSITION_TYPE_SELL);
      if(SELLS == 0) CLOSE_SELL = false;
     }

   if(CLOSE_ALL)
     {
      if(BUYS + SELLS > 0) POSITIONS_CLOSE(-1);
      if(BUYS + SELLS == 0) CLOSE_ALL = false;
     }

   if(PREV_BUYS + PREV_SELLS != BUYS + SELLS || FIRST_RUN)
      RECALCULATION_PARAMETERS();

   FIRST_RUN  = false;
   DEINIT     = false;
   PREV_BUYS  = BUYS;
   PREV_SELLS = SELLS;
   LAST_BID   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  }

//+------------------------------------------------------------------+
//| Get RSI value using handle+CopyBuffer (MQL5 way)                 |
//| index=1 → last CLOSED bar (fixes random-trigger bug from MQL4)  |
//+------------------------------------------------------------------+
double GET_RSI_VALUE(int index = 1)
  {
   if(RSI_HANDLE == INVALID_HANDLE)
      return(0);

   double rsiArray[];
   ArraySetAsSeries(rsiArray, true);

   if(CopyBuffer(RSI_HANDLE, 0, 0, index + 1, rsiArray) < 0)
     {
      Print("CopyBuffer RSI error: ", GetLastError());
      return(0);
     }

   return(NormalizeDouble(rsiArray[index], 2));
  }

//+------------------------------------------------------------------+
//| Overlap function — closes win+loss pair when combined profit ≥ 0 |
//+------------------------------------------------------------------+
void OVERLAP(int ORDERTYPE = -1)
  {
   WIN_TYPE = WIN_TICKET = 0;
   WIN_PROFIT = WIN_LOT = 0;
   WIN_POSITION(WIN_TYPE, WIN_TICKET, WIN_PROFIT, WIN_LOT, _Symbol, ORDERTYPE, MAGIC_NUMBER);

   LOSS_TYPE = LOSS_TICKET = 0;
   LOSS_PROFIT = LOSS_LOT = 0;
   LOSS_POSITION(LOSS_TYPE, LOSS_TICKET, LOSS_PROFIT, LOSS_LOT, _Symbol, ORDERTYPE, MAGIC_NUMBER);

   if(-LOSS_PROFIT == 0 || WIN_PROFIT == 0) return;

   if(WIN_TYPE == LOSS_TYPE)
     {
      if(TICKVALUE * (WIN_LOT + LOSS_LOT) == 0) { ZEROLEVEL = 0; OVERLAP_CLOSE = 0; return; }

      if(WIN_TYPE == (int)POSITION_TYPE_BUY)
        {
         ZEROLEVEL    = NormalizeDouble(SymbolInfoDouble(NULL, SYMBOL_BID) - ((WIN_PROFIT + LOSS_PROFIT) / (TICKVALUE * (WIN_LOT + LOSS_LOT)) * _Point), _Digits);
         OVERLAP_CLOSE = NormalizeDouble(ZEROLEVEL + OVERLAP_PIPS * _Point, _Digits);
         if(SymbolInfoDouble(NULL, SYMBOL_BID) >= OVERLAP_CLOSE)
           {
            POSITIONS_CLOSE_TICKET(WIN_TICKET,  WIN_LOT);
            POSITIONS_CLOSE_TICKET(LOSS_TICKET, LOSS_LOT);
            ZEROLEVEL = 0; OVERLAP_CLOSE = 0;
           }
        }

      if(WIN_TYPE == (int)POSITION_TYPE_SELL)
        {
         ZEROLEVEL    = NormalizeDouble(SymbolInfoDouble(NULL, SYMBOL_ASK) + ((WIN_PROFIT + LOSS_PROFIT) / (TICKVALUE * (WIN_LOT + LOSS_LOT)) * _Point), _Digits);
         OVERLAP_CLOSE = NormalizeDouble(ZEROLEVEL - OVERLAP_PIPS * _Point, _Digits);
         if(SymbolInfoDouble(NULL, SYMBOL_ASK) <= OVERLAP_CLOSE)
           {
            POSITIONS_CLOSE_TICKET(WIN_TICKET,  WIN_LOT);
            POSITIONS_CLOSE_TICKET(LOSS_TICKET, LOSS_LOT);
            ZEROLEVEL = 0; OVERLAP_CLOSE = 0;
           }
        }
     }

   if(WIN_TYPE != LOSS_TYPE)
     {
      if(TICKVALUE * MathAbs(WIN_LOT - LOSS_LOT) == 0) { ZEROLEVEL = 0; OVERLAP_CLOSE = 0; return; }

      if(WIN_LOT > LOSS_LOT)
        {
         if(WIN_TYPE == (int)POSITION_TYPE_BUY)
           {
            ZEROLEVEL    = NormalizeDouble(SymbolInfoDouble(NULL, SYMBOL_BID) - ((WIN_PROFIT + LOSS_PROFIT) / (TICKVALUE * MathAbs(WIN_LOT - LOSS_LOT)) * _Point), _Digits);
            OVERLAP_CLOSE = NormalizeDouble(ZEROLEVEL + OVERLAP_PIPS * _Point, _Digits);
            if(SymbolInfoDouble(NULL, SYMBOL_BID) >= OVERLAP_CLOSE)
              {
               POSITIONS_CLOSE_TICKET(WIN_TICKET,  WIN_LOT);
               POSITIONS_CLOSE_TICKET(LOSS_TICKET, LOSS_LOT);
               ZEROLEVEL = 0; OVERLAP_CLOSE = 0;
              }
           }
         if(WIN_TYPE == (int)POSITION_TYPE_SELL)
           {
            ZEROLEVEL    = NormalizeDouble(SymbolInfoDouble(NULL, SYMBOL_ASK) + ((WIN_PROFIT + LOSS_PROFIT) / (TICKVALUE * MathAbs(WIN_LOT - LOSS_LOT)) * _Point), _Digits);
            OVERLAP_CLOSE = NormalizeDouble(ZEROLEVEL - OVERLAP_PIPS * _Point, _Digits);
            if(SymbolInfoDouble(NULL, SYMBOL_ASK) <= OVERLAP_CLOSE)
              {
               POSITIONS_CLOSE_TICKET(WIN_TICKET,  WIN_LOT);
               POSITIONS_CLOSE_TICKET(LOSS_TICKET, LOSS_LOT);
               ZEROLEVEL = 0; OVERLAP_CLOSE = 0;
              }
           }
        }

      if(WIN_LOT < LOSS_LOT)
        {
         if(LOSS_TYPE == (int)POSITION_TYPE_BUY)
           {
            ZEROLEVEL    = NormalizeDouble(SymbolInfoDouble(NULL, SYMBOL_BID) - ((WIN_PROFIT + LOSS_PROFIT) / (TICKVALUE * MathAbs(WIN_LOT - LOSS_LOT)) * _Point), _Digits);
            OVERLAP_CLOSE = NormalizeDouble(ZEROLEVEL + OVERLAP_PIPS * _Point, _Digits);
            if(SymbolInfoDouble(NULL, SYMBOL_BID) >= OVERLAP_CLOSE)
              {
               POSITIONS_CLOSE_TICKET(WIN_TICKET,  WIN_LOT);
               POSITIONS_CLOSE_TICKET(LOSS_TICKET, LOSS_LOT);
               ZEROLEVEL = 0; OVERLAP_CLOSE = 0;
              }
           }
         if(LOSS_TYPE == (int)POSITION_TYPE_SELL)
           {
            ZEROLEVEL    = NormalizeDouble(SymbolInfoDouble(NULL, SYMBOL_ASK) + ((WIN_PROFIT + LOSS_PROFIT) / (TICKVALUE * MathAbs(WIN_LOT - LOSS_LOT)) * _Point), _Digits);
            OVERLAP_CLOSE = NormalizeDouble(ZEROLEVEL - OVERLAP_PIPS * _Point, _Digits);
            if(SymbolInfoDouble(NULL, SYMBOL_ASK) <= OVERLAP_CLOSE)
              {
               POSITIONS_CLOSE_TICKET(WIN_TICKET,  WIN_LOT);
               POSITIONS_CLOSE_TICKET(LOSS_TICKET, LOSS_LOT);
               ZEROLEVEL = 0; OVERLAP_CLOSE = 0;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Update TICKVALUE from open positions (more accurate)             |
//+------------------------------------------------------------------+
void GET_TICKVALUE()
  {
   SPREAD = (int)MathMax(
               (SymbolInfoDouble(NULL, SYMBOL_ASK) - SymbolInfoDouble(NULL, SYMBOL_BID)) / _Point,
               (double)SymbolInfoInteger(NULL, SYMBOL_SPREAD));

   // Update tick value from live position data for accuracy
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetSymbol(i) == _Symbol)
        {
         double profit    = PositionGetDouble(POSITION_PROFIT);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double curPrice  = PositionGetDouble(POSITION_PRICE_CURRENT);
         double lots      = PositionGetDouble(POSITION_VOLUME);

         if(profit != 0 && (curPrice - openPrice) != 0 && lots > 0)
            TICKVALUE = MathAbs(profit / ((curPrice - openPrice) / _Point) / lots);
        }
     }
  }

//+------------------------------------------------------------------+
//| Sum profit and lots for BUY and SELL positions                   |
//+------------------------------------------------------------------+
void TOTAL_VALUE(double &PROFIT_BUY, double &LOTS_BUY, double &PROFIT_SELL, double &LOTS_SELL, int MAGIC = -1)
  {
   PROFIT_BUY = LOTS_BUY = PROFIT_SELL = LOTS_SELL = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         ((long)PositionGetInteger(POSITION_MAGIC) == MAGIC || MAGIC == -1))
        {
         double profit = NormalizeDouble(
                            PositionGetDouble(POSITION_PROFIT) +
                            PositionGetDouble(POSITION_SWAP), 2);
         double lots   = PositionGetDouble(POSITION_VOLUME);
         int posType   = (int)PositionGetInteger(POSITION_TYPE); // cast enum → int

         if(posType == (int)POSITION_TYPE_BUY)
           {
            PROFIT_BUY += profit;
            LOTS_BUY   += lots;
           }
         if(posType == (int)POSITION_TYPE_SELL)
           {
            PROFIT_SELL += profit;
            LOTS_SELL   += lots;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Reset all calculated parameters (called when order count changes)|
//+------------------------------------------------------------------+
void RECALCULATION_PARAMETERS()
  {
   Print("RECALCULATION");
   ZEROLEVEL_BUY = ZEROLEVEL_SELL = ZEROLEVEL_ALL = 0;
   ZEROLEVEL     = OVERLAP_CLOSE  = 0;
   GRID_BUY_PRICE  = GRID_SELL_PRICE = 0;
   TRAILINGSTOP_BUY  = TRAILINGSTEP_BUY  = 0;
   TRAILINGSTOP_SELL = TRAILINGSTEP_SELL = 0;
   BREAKEVENSTOP_BUY  = BREAKEVENSTEP_BUY  = 0;
   BREAKEVENSTOP_SELL = BREAKEVENSTEP_SELL = 0;
   STOPLOSS_BUY  = STOPLOSS_SELL  = 0;
   TAKEPROFIT_BUY = TAKEPROFIT_SELL = 0;
  }

//+------------------------------------------------------------------+
//| Close all positions of a type (or all if CMD=-1)                 |
//| CMD: 0=BUY, 1=SELL, -1=ALL                                      |
//+------------------------------------------------------------------+
void POSITIONS_CLOSE(int CMD = -1)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      int posType = (int)PositionGetInteger(POSITION_TYPE); // cast enum → int for safe comparison

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         (posType == CMD || CMD == -1) &&
         ((long)PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER || MAGIC_NUMBER == -1))
        {
         if(!Trade.PositionClose(ticket))
           {
            Print(__FUNCTION__, " ", __LINE__, " ERROR: ", GetLastError());
            Sleep(1000);
            return;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Close specific position by ticket + lot (partial if needed)      |
//+------------------------------------------------------------------+
void POSITIONS_CLOSE_TICKET(ulong ticket, double lots = -1)
  {
   if(!PositionSelectByTicket(ticket)) return;

   double posLots = PositionGetDouble(POSITION_VOLUME);
   double closeLots = (lots == -1 || lots >= posLots) ? posLots : lots;

   if(!Trade.PositionClose(ticket))
      Print(__FUNCTION__, " ERROR closing ticket ", ticket, ": ", GetLastError());
  }

//+------------------------------------------------------------------+
//| Count open orders by type                                        |
//+------------------------------------------------------------------+
void COUNT_ORDERS(int &BUY, int &SELL, int &BUYLIMIT, int &SELLLIMIT, int &BUYSTOP, int &SELLSTOP, int MAGIC = -1)
  {
   BUY = SELL = BUYLIMIT = SELLLIMIT = BUYSTOP = SELLSTOP = 0;

   // Count open positions
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         ((long)PositionGetInteger(POSITION_MAGIC) == MAGIC || MAGIC == -1))
        {
         int posType = (int)PositionGetInteger(POSITION_TYPE); // cast enum → int
         if(posType == (int)POSITION_TYPE_BUY)  BUY++;
         if(posType == (int)POSITION_TYPE_SELL) SELL++;
        }
     }

   // Count pending orders
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
         (OrderGetInteger(ORDER_MAGIC) == MAGIC || MAGIC == -1))
        {
         switch((int)OrderGetInteger(ORDER_TYPE))
           {
            case ORDER_TYPE_BUY_LIMIT:  BUYLIMIT++;  break;
            case ORDER_TYPE_SELL_LIMIT: SELLLIMIT++; break;
            case ORDER_TYPE_BUY_STOP:   BUYSTOP++;   break;
            case ORDER_TYPE_SELL_STOP:  SELLSTOP++;  break;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Delete all chart objects whose name contains "HLINE"            |
//+------------------------------------------------------------------+
void DEINIT_HLINE()
  {
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, "HLINE", 0) >= 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Create or update a horizontal line on the chart                  |
//+------------------------------------------------------------------+
void OBJECT_HLINE(string NAME, double _PRICE, string TEXT, color CLR, int STYLE = 3)
  {
   if(ObjectFind(0, NAME) < 0)
     {
      ObjectCreate(0, NAME, OBJ_HLINE, 0, 0, 0);
      ObjectSetInteger(0, NAME, OBJPROP_COLOR,     CLR);
      ObjectSetInteger(0, NAME, OBJPROP_STYLE,     STYLE);
      ObjectSetInteger(0, NAME, OBJPROP_WIDTH,     1);
      ObjectSetInteger(0, NAME, OBJPROP_BACK,      true);
      ObjectSetInteger(0, NAME, OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0, NAME, OBJPROP_SELECTED,  false);
      ObjectSetInteger(0, NAME, OBJPROP_HIDDEN,    true);
      ObjectSetDouble (0, NAME, OBJPROP_PRICE,     _PRICE);
      ObjectSetString (0, NAME, OBJPROP_TOOLTIP,   TEXT);
     }
   else
     {
      ObjectSetDouble (0, NAME, OBJPROP_PRICE,   _PRICE);
      ObjectSetString (0, NAME, OBJPROP_TOOLTIP, TEXT);
      ObjectSetInteger(0, NAME, OBJPROP_COLOR,   CLR);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Delete all DRAW_BUTTON objects                                   |
//+------------------------------------------------------------------+
void DEINIT_BUTTON()
  {
   for(int i = ObjectsTotal(0) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);
      if(StringFind(name, "BUTTON") >= 0 || StringFind(name, "DRAW_BUTTON") >= 0)
         ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
//| Create or update a button object                                 |
//+------------------------------------------------------------------+
bool OBJECT_BUTTON(const long             CHART_ID   = 0,
                   const string           NAME       = "",
                   const int              SUB_WINDOW = 0,
                   const int              X          = 0,
                   const int              Y          = 0,
                   const int              WIDTH      = 50,
                   const int              HEIGHT     = 18,
                   const ENUM_BASE_CORNER CORNER     = CORNER_LEFT_UPPER,
                   const string           TEXT       = "",
                   const string           FONT       = "",
                   const int              FONT_SIZE  = 10,
                   const color            CLR        = clrBlack,
                   const color            BACK_CLR   = clrNONE,
                   const color            BORDER_CLR = clrNONE,
                   const bool             state      = false,
                   const bool             BACK       = false,
                   const bool             SELECTION  = false,
                   const bool             HIDDEN     = true,
                   const long             ZORDER     = 0)
  {
   ResetLastError();
   if(ObjectFind(0, NAME) < 0)
     {
      ObjectCreate(CHART_ID, NAME, OBJ_BUTTON, SUB_WINDOW, 0, 0);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_XDISTANCE,   X);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_YDISTANCE,   Y);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_XSIZE,       WIDTH);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_YSIZE,       HEIGHT);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_CORNER,      CORNER);
      ObjectSetString (CHART_ID, NAME, OBJPROP_TEXT,        TEXT);
      ObjectSetString (CHART_ID, NAME, OBJPROP_FONT,        FONT);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_FONTSIZE,    FONT_SIZE);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR,       CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BGCOLOR,     BACK_CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BORDER_COLOR,BORDER_CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BACK,        BACK);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_STATE,       state);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_SELECTABLE,  SELECTION);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_SELECTED,    SELECTION);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_HIDDEN,      HIDDEN);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_ZORDER,      ZORDER);
     }
   else
     {
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR,        CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BGCOLOR,      BACK_CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BORDER_COLOR, BORDER_CLR);
     }
   ChartRedraw();
   return true;
  }

//+------------------------------------------------------------------+
//| Draw the manual Buy/Sell panel buttons                           |
//+------------------------------------------------------------------+
void DRAW_BUTTON()
  {
   int X = 2, Y = 15;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(bid != LAST_BID && bid > LAST_BID) BUTTONL_CLR = (color)StringToInteger("0x0E10BE"); // blue
   if(bid != LAST_BID && bid < LAST_BID) BUTTONL_CLR = (color)StringToInteger("0xBE100F"); // red

   OBJECT_BUTTON(0,"BUTTON_SELL", 0, X+1,   Y+15, 55, 25, CORNER_LEFT_LOWER, "SELL", "Arial", 10, clrWhite, BUTTONL_CLR,           clrBlack, false,false,false,true,0);
   OBJECT_BUTTON(0,"BUTTON_-LOT", 0, X+56,  Y+15, 20, 25, CORNER_LEFT_LOWER, "-",    "Arial", 10, clrBlack, (color)0xEBEBEB,        clrBlack, false,false,false,true,0);
   OBJECT_EDIT  (0,"BUTTON_LOT",  0, X+76,  Y+15, 45, 25, DoubleToString(TEMP_LOT,2),"Arial",10,ALIGN_RIGHT,false,CORNER_LEFT_LOWER,clrBlack, clrWhite,clrBlack,false,false,false,0);
   OBJECT_BUTTON(0,"BUTTON_+LOT", 0, X+121, Y+15, 20, 25, CORNER_LEFT_LOWER, "+",    "Arial", 10, clrBlack, (color)0xEBEBEB,        clrBlack, false,false,false,true,0);
   OBJECT_BUTTON(0,"BUTTON_BUY",  0, X+141, Y+15, 55, 25, CORNER_LEFT_LOWER, "BUY",  "Arial", 10, clrWhite, BUTTONL_CLR,           clrBlack, false,false,false,true,0);
  }

//+------------------------------------------------------------------+
//| Create or update an Edit field                                   |
//+------------------------------------------------------------------+
bool OBJECT_EDIT(const long             CHART_ID   = 0,
                 const string           NAME       = "",
                 const int              SUB_WINDOW = 0,
                 const int              X          = 0,
                 const int              Y          = 0,
                 const int              WIDTH      = 0,
                 const int              HEIGHT     = 0,
                 const string           TEXT       = "",
                 const string           FONT       = "",
                 const int              FONT_SIZE  = 0,
                 const ENUM_ALIGN_MODE  ALIGN      = ALIGN_CENTER,
                 const bool             READ_ONLY  = false,
                 const ENUM_BASE_CORNER CORNER     = CORNER_LEFT_UPPER,
                 const color            CLR        = clrBlack,
                 const color            BACK_CLR   = clrWhite,
                 const color            BORDER_CLR = clrNONE,
                 const bool             BACK       = false,
                 const bool             SELECTION  = false,
                 const bool             HIDDEN     = true,
                 const long             ZORDER     = 0)
  {
   ResetLastError();
   if(ObjectFind(0, NAME) < 0)
     {
      ObjectCreate(CHART_ID, NAME, OBJ_EDIT, SUB_WINDOW, 0, 0);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_XDISTANCE,   X);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_YDISTANCE,   Y);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_XSIZE,       WIDTH);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_YSIZE,       HEIGHT);
      ObjectSetString (CHART_ID, NAME, OBJPROP_TEXT,        TEXT);
      ObjectSetString (CHART_ID, NAME, OBJPROP_FONT,        FONT);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_FONTSIZE,    FONT_SIZE);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_ALIGN,       ALIGN);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_READONLY,    READ_ONLY);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_CORNER,      CORNER);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR,       CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BGCOLOR,     BACK_CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BORDER_COLOR,BORDER_CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BACK,        BACK);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_SELECTABLE,  SELECTION);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_SELECTED,    SELECTION);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_HIDDEN,      HIDDEN);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_ZORDER,      ZORDER);
     }
   else
     {
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR,        CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BGCOLOR,      BACK_CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BORDER_COLOR, BORDER_CLR);
     }
   ChartRedraw();
   return true;
  }

//+------------------------------------------------------------------+
//| Handle button click events                                       |
//+------------------------------------------------------------------+
void ON_CHART_EVENTS()
  {
   double minLot = SymbolInfoDouble(NULL, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(NULL, SYMBOL_VOLUME_MAX);

   // Read and validate lot field
   TEMP_LOT = StringToDouble(ObjectGetString(0, "BUTTON_LOT", OBJPROP_TEXT));
   if(TEMP_LOT < minLot)
      ObjectSetString(0, "BUTTON_LOT", OBJPROP_TEXT, DoubleToString(MathMax(LAST_LOT, minLot), 2));

   // +LOT button
   if((bool)ObjectGetInteger(0, "BUTTON_+LOT", OBJPROP_STATE))
     {
      double lots = StringToDouble(ObjectGetString(0, "BUTTON_LOT", OBJPROP_TEXT));
      lots = MathMin(lots + minLot, maxLot);
      ObjectSetString(0, "BUTTON_LOT", OBJPROP_TEXT, DoubleToString(lots, 2));
      TEMP_LOT = lots;
      ObjectSetInteger(0, "BUTTON_+LOT", OBJPROP_STATE, false);
     }

   // -LOT button
   if((bool)ObjectGetInteger(0, "BUTTON_-LOT", OBJPROP_STATE))
     {
      double lots = StringToDouble(ObjectGetString(0, "BUTTON_LOT", OBJPROP_TEXT));
      lots = MathMax(lots - minLot, minLot);
      ObjectSetString(0, "BUTTON_LOT", OBJPROP_TEXT, DoubleToString(lots, 2));
      TEMP_LOT = lots;
      ObjectSetInteger(0, "BUTTON_-LOT", OBJPROP_STATE, false);
     }

   // BUY button
   if((bool)ObjectGetInteger(0, "BUTTON_BUY", OBJPROP_STATE))
     {
      ORDER_SEND(ORDER_TYPE_BUY, TEMP_LOT, ORDERS_COMMENT, MAGIC_NUMBER);
      ObjectSetInteger(0, "BUTTON_BUY", OBJPROP_STATE, false);
      BUYS++;
     }

   // SELL button
   if((bool)ObjectGetInteger(0, "BUTTON_SELL", OBJPROP_STATE))
     {
      ORDER_SEND(ORDER_TYPE_SELL, TEMP_LOT, ORDERS_COMMENT, MAGIC_NUMBER);
      ObjectSetInteger(0, "BUTTON_SELL", OBJPROP_STATE, false);
      SELLS++;
     }
  }

//+------------------------------------------------------------------+
//| Send a market order (MQL5 version using MqlTradeRequest)         |
//+------------------------------------------------------------------+
void ORDER_SEND(ENUM_ORDER_TYPE CMD, double LOTS, string COMMENT, int MAGIC)
  {
   // Check order limit
   long maxOrders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   if(maxOrders > 0 && PositionsTotal() + OrdersTotal() >= maxOrders)
     {
      Print("Order limit reached: ", maxOrders);
      return;
     }

   // Normalize lot
   double minLot  = SymbolInfoDouble(NULL, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(NULL, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(NULL, SYMBOL_VOLUME_STEP);

   LOTS = MathMax(LOTS, minLot);
   LOTS = MathMin(LOTS, maxLot);
   LOTS = NormalizeDouble(MathRound(LOTS / lotStep) * lotStep, 2);

   // Check free margin
   double marginRequired = 0;
   if(!OrderCalcMargin(CMD, _Symbol, LOTS, SymbolInfoDouble(_Symbol, CMD == ORDER_TYPE_SELL ? SYMBOL_BID : SYMBOL_ASK), marginRequired))
     {
      Print("OrderCalcMargin error: ", GetLastError());
      return;
     }
   if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < marginRequired + minLot * marginRequired)
     {
      Print("Insufficient free margin. Required: ", marginRequired);
      return;
     }

   // Check symbol trade mode
   if((ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
     {
      Print("Symbol not fully tradeable: ", _Symbol);
      return;
     }

   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};

   request.action   = TRADE_ACTION_DEAL;
   request.symbol   = _Symbol;
   request.volume   = LOTS;
   request.type     = CMD;
   request.price    = (CMD == ORDER_TYPE_BUY)
                      ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   request.deviation= 10;
   request.magic    = (MAGIC == -1) ? 0 : MAGIC;
   request.comment  = COMMENT;
   request.type_filling = GetFillingMode(_Symbol);

   if(!OrderSend(request, result))
     {
      Print(__FUNCTION__, " ", __LINE__, " ERROR: ", result.retcode, " - ", result.comment);
      Sleep(1000);
     }
  }

//+------------------------------------------------------------------+
//| Draw all indicator lines on the chart                            |
//+------------------------------------------------------------------+
void HLINE()
  {
   // Zero level & overlap close
   if(ZEROLEVEL > 0)    OBJECT_HLINE("HLINE_ZEROLEVEL",      ZEROLEVEL,      "ZEROLEVEL",    clrGold, 0);
   else if(ObjectFind(0,"HLINE_ZEROLEVEL") >= 0)      ObjectDelete(0,"HLINE_ZEROLEVEL");

   if(OVERLAP_CLOSE > 0) OBJECT_HLINE("HLINE_OVERLAP_CLOSE", OVERLAP_CLOSE, "OVERLAP CLOSE", clrRed);
   else if(ObjectFind(0,"HLINE_OVERLAP_CLOSE") >= 0)  ObjectDelete(0,"HLINE_OVERLAP_CLOSE");

   // Grid levels
   if(GRID_BUY_PRICE > 0)  OBJECT_HLINE("HLINE_GRID_BUY_PRICE",  GRID_BUY_PRICE,  "GRID BUY",  clrGreen);
   else if(ObjectFind(0,"HLINE_GRID_BUY_PRICE") >= 0)  ObjectDelete(0,"HLINE_GRID_BUY_PRICE");

   if(GRID_SELL_PRICE > 0) OBJECT_HLINE("HLINE_GRID_SELL_PRICE", GRID_SELL_PRICE, "GRID SELL", clrGreen);
   else if(ObjectFind(0,"HLINE_GRID_SELL_PRICE") >= 0) ObjectDelete(0,"HLINE_GRID_SELL_PRICE");

   // Trailing stop levels
   if(TRAILINGSTOP_BUY > 0)  OBJECT_HLINE("HLINE_TRAILINGSTOP_BUY",  TRAILINGSTOP_BUY,  "TRAILINGSTOP BUY",  clrYellow);
   else if(ObjectFind(0,"HLINE_TRAILINGSTOP_BUY") >= 0)  ObjectDelete(0,"HLINE_TRAILINGSTOP_BUY");

   if(TRAILINGSTEP_BUY > 0)  OBJECT_HLINE("HLINE_TRAILINGSTEP_BUY",  TRAILINGSTEP_BUY,  "TRAILINGSTEP BUY",  clrRed);
   else if(ObjectFind(0,"HLINE_TRAILINGSTEP_BUY") >= 0)  ObjectDelete(0,"HLINE_TRAILINGSTEP_BUY");

   if(TRAILINGSTOP_SELL > 0) OBJECT_HLINE("HLINE_TRAILINGSTOP_SELL", TRAILINGSTOP_SELL, "TRAILINGSTOP SELL", clrYellow);
   else if(ObjectFind(0,"HLINE_TRAILINGSTOP_SELL") >= 0) ObjectDelete(0,"HLINE_TRAILINGSTOP_SELL");

   if(TRAILINGSTEP_SELL > 0) OBJECT_HLINE("HLINE_TRAILINGSTEP_SELL", TRAILINGSTEP_SELL, "TRAILINGSTEP SELL", clrRed);
   else if(ObjectFind(0,"HLINE_TRAILINGSTEP_SELL") >= 0) ObjectDelete(0,"HLINE_TRAILINGSTEP_SELL");

   // Breakeven levels
   if(BREAKEVENSTOP_BUY > 0)  OBJECT_HLINE("HLINE_BREAKEVENSTOP_BUY",  BREAKEVENSTOP_BUY,  "BREAKEVENSTOP BUY",  clrYellow);
   else if(ObjectFind(0,"HLINE_BREAKEVENSTOP_BUY") >= 0)  ObjectDelete(0,"HLINE_BREAKEVENSTOP_BUY");

   if(BREAKEVENSTEP_BUY > 0)  OBJECT_HLINE("HLINE_BREAKEVENSTEP_BUY",  BREAKEVENSTEP_BUY,  "BREAKEVENSTEP BUY",  clrRed);
   else if(ObjectFind(0,"HLINE_BREAKEVENSTEP_BUY") >= 0)  ObjectDelete(0,"HLINE_BREAKEVENSTEP_BUY");

   if(BREAKEVENSTOP_SELL > 0) OBJECT_HLINE("HLINE_BREAKEVENSTOP_SELL", BREAKEVENSTOP_SELL, "BREAKEVENSTOP SELL", clrYellow);
   else if(ObjectFind(0,"HLINE_BREAKEVENSTOP_SELL") >= 0) ObjectDelete(0,"HLINE_BREAKEVENSTOP_SELL");

   if(BREAKEVENSTEP_SELL > 0) OBJECT_HLINE("HLINE_BREAKEVENSTEP_SELL", BREAKEVENSTEP_SELL, "BREAKEVENSTEP SELL", clrRed);
   else if(ObjectFind(0,"HLINE_BREAKEVENSTEP_SELL") >= 0) ObjectDelete(0,"HLINE_BREAKEVENSTEP_SELL");

   // SL/TP levels
   if(STOPLOSS_BUY > 0)   OBJECT_HLINE("HLINE_STOPLOSS_BUY",   STOPLOSS_BUY,   "STOPLOSS BUY",   clrRed);
   else if(ObjectFind(0,"HLINE_STOPLOSS_BUY") >= 0)   ObjectDelete(0,"HLINE_STOPLOSS_BUY");

   if(STOPLOSS_SELL > 0)  OBJECT_HLINE("HLINE_STOPLOSS_SELL",  STOPLOSS_SELL,  "STOPLOSS SELL",  clrRed);
   else if(ObjectFind(0,"HLINE_STOPLOSS_SELL") >= 0)  ObjectDelete(0,"HLINE_STOPLOSS_SELL");

   if(TAKEPROFIT_BUY > 0)  OBJECT_HLINE("HLINE_TAKEPROFIT_BUY",  TAKEPROFIT_BUY,  "TAKEPROFIT BUY",  clrLime);
   else if(ObjectFind(0,"HLINE_TAKEPROFIT_BUY") >= 0)  ObjectDelete(0,"HLINE_TAKEPROFIT_BUY");

   if(TAKEPROFIT_SELL > 0) OBJECT_HLINE("HLINE_TAKEPROFIT_SELL", TAKEPROFIT_SELL, "TAKEPROFIT SELL", clrLime);
   else if(ObjectFind(0,"HLINE_TAKEPROFIT_SELL") >= 0) ObjectDelete(0,"HLINE_TAKEPROFIT_SELL");
  }

//+------------------------------------------------------------------+
//| Find the most profitable (furthest in-profit) position           |
//+------------------------------------------------------------------+
void WIN_POSITION(int &TYPE, int &TICKET, double &PROFIT, double &LOT,
                  string SYMBOL = "", int ORDERTYPE = -1, int MAGIC = -1)
  {
   double DISTANCE_ = 0.0;
   TYPE = TICKET = 0;
   PROFIT = LOT = 0;
   if(SYMBOL == "") SYMBOL = _Symbol;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetString(POSITION_SYMBOL) == SYMBOL &&
         ((long)PositionGetInteger(POSITION_MAGIC) == MAGIC || MAGIC == -1))
        {
         int    posType  = (int)PositionGetInteger(POSITION_TYPE);
         double openP    = PositionGetDouble(POSITION_PRICE_OPEN);
         double bid      = SymbolInfoDouble(SYMBOL, SYMBOL_BID);
         double ask      = SymbolInfoDouble(SYMBOL, SYMBOL_ASK);

         if((ORDERTYPE == -1 || posType == ORDERTYPE))
           {
            if(posType == (int)POSITION_TYPE_BUY && openP < bid)
              {
               double dist = MathAbs(openP - bid);
               if(dist > DISTANCE_)
                 {
                  DISTANCE_ = dist;
                  TYPE   = posType;
                  TICKET = (int)ticket;
                  PROFIT = NormalizeDouble(PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP), 2);
                  LOT    = PositionGetDouble(POSITION_VOLUME);
                 }
              }
            if(posType == (int)POSITION_TYPE_SELL && openP > ask)
              {
               double dist = MathAbs(openP - ask);
               if(dist > DISTANCE_)
                 {
                  DISTANCE_ = dist;
                  TYPE   = posType;
                  TICKET = (int)ticket;
                  PROFIT = NormalizeDouble(PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP), 2);
                  LOT    = PositionGetDouble(POSITION_VOLUME);
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Find the most losing (furthest against) position                 |
//+------------------------------------------------------------------+
void LOSS_POSITION(int &TYPE, int &TICKET, double &PROFIT, double &LOT,
                   string SYMBOL = "", int ORDERTYPE = -1, int MAGIC = -1)
  {
   double DISTANCE_ = 0.0;
   TYPE = TICKET = 0;
   PROFIT = LOT = 0;
   if(SYMBOL == "") SYMBOL = _Symbol;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetString(POSITION_SYMBOL) == SYMBOL &&
         ((long)PositionGetInteger(POSITION_MAGIC) == MAGIC || MAGIC == -1))
        {
         int    posType = (int)PositionGetInteger(POSITION_TYPE);
         double openP   = PositionGetDouble(POSITION_PRICE_OPEN);
         double bid     = SymbolInfoDouble(SYMBOL, SYMBOL_BID);
         double ask     = SymbolInfoDouble(SYMBOL, SYMBOL_ASK);

         if((ORDERTYPE == -1 || posType == ORDERTYPE))
           {
            if(posType == (int)POSITION_TYPE_BUY && openP > bid)
              {
               double dist = MathAbs(openP - bid);
               if(dist > DISTANCE_)
                 {
                  DISTANCE_ = dist;
                  TYPE   = posType;
                  TICKET = (int)ticket;
                  PROFIT = NormalizeDouble(PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP), 2);
                  LOT    = PositionGetDouble(POSITION_VOLUME);
                 }
              }
            if(posType == (int)POSITION_TYPE_SELL && openP < ask)
              {
               double dist = MathAbs(openP - ask);
               if(dist > DISTANCE_)
                 {
                  DISTANCE_ = dist;
                  TYPE   = posType;
                  TICKET = (int)ticket;
                  PROFIT = NormalizeDouble(PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP), 2);
                  LOT    = PositionGetDouble(POSITION_VOLUME);
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Get price and lot of the most recently opened BUY and SELL       |
//+------------------------------------------------------------------+
void OPENED_VALUES(double &PRICE_BUY, double &LOTS_BUY, double &PRICE_SELL, double &LOTS_SELL)
  {
   PRICE_BUY = LOTS_BUY = PRICE_SELL = LOTS_SELL = 0;
   ulong lastTicket = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         ((long)PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER || MAGIC_NUMBER == -1))
        {
         if(ticket > lastTicket)
           {
            int posType = (int)PositionGetInteger(POSITION_TYPE);
            if(posType == (int)POSITION_TYPE_BUY)
              {
               PRICE_BUY = PositionGetDouble(POSITION_PRICE_OPEN);
               LOTS_BUY  = PositionGetDouble(POSITION_VOLUME);
              }
            if(posType == (int)POSITION_TYPE_SELL)
              {
               PRICE_SELL = PositionGetDouble(POSITION_PRICE_OPEN);
               LOTS_SELL  = PositionGetDouble(POSITION_VOLUME);
              }
            lastTicket = ticket;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Virtual trailing stop — closes when price reverses past trigger  |
//+------------------------------------------------------------------+
void VIRTUAL_TRAILINGSTOP(int CMD = -1)
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(CMD == (int)POSITION_TYPE_BUY && BUYS > 0)
     {
      if(TICKVALUE * BUY_LOTS <= 0) return;
      ZEROLEVEL_BUY  = NormalizeDouble(bid - (BUY_PROFIT / (TICKVALUE * BUY_LOTS) * _Point), _Digits);
      TRAILINGSTOP_BUY = NormalizeDouble((TRAILINGSTEP_BUY > 0 ? TRAILINGSTEP_BUY : ZEROLEVEL_BUY) + (TRAILING_STOP + TRAILING_STEP) * _Point, _Digits);

      if(bid >= NormalizeDouble(ZEROLEVEL_BUY + (TRAILING_STOP + TRAILING_STEP) * _Point, _Digits) &&
         (NormalizeDouble(bid - (TRAILING_STOP + TRAILING_STEP) * _Point, _Digits) >= TRAILINGSTEP_BUY || TRAILINGSTEP_BUY == 0))
         TRAILINGSTEP_BUY = NormalizeDouble(bid - TRAILING_STEP * _Point, _Digits);

      if(TRAILINGSTEP_BUY > 0 && bid <= TRAILINGSTEP_BUY)
         CLOSE_BUY = true;
     }

   if(CMD == (int)POSITION_TYPE_SELL && SELLS > 0)
     {
      if(TICKVALUE * SELL_LOTS <= 0) return;
      ZEROLEVEL_SELL  = NormalizeDouble(ask + (SELL_PROFIT / (TICKVALUE * SELL_LOTS) * _Point), _Digits);
      TRAILINGSTOP_SELL = NormalizeDouble((TRAILINGSTEP_SELL > 0 ? TRAILINGSTEP_SELL : ZEROLEVEL_SELL) - (TRAILING_STOP + TRAILING_STEP) * _Point, _Digits);

      if(ask <= NormalizeDouble(ZEROLEVEL_SELL - (TRAILING_STOP + TRAILING_STEP) * _Point, _Digits) &&
         (NormalizeDouble(ask + (TRAILING_STOP + TRAILING_STEP) * _Point, _Digits) <= TRAILINGSTEP_SELL || TRAILINGSTEP_SELL == 0))
         TRAILINGSTEP_SELL = NormalizeDouble(ask + TRAILING_STEP * _Point, _Digits);

      if(TRAILINGSTEP_SELL > 0 && ask >= TRAILINGSTEP_SELL)
         CLOSE_SELL = true;
     }
  }

//+------------------------------------------------------------------+
//| Virtual breakeven — move effective SL to breakeven + step        |
//+------------------------------------------------------------------+
void VIRTUAL_BREAKEVEN(int CMD = -1)
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(CMD == (int)POSITION_TYPE_BUY && BUYS > 0)
     {
      if(TICKVALUE * BUY_LOTS <= 0) return;
      ZEROLEVEL_BUY    = NormalizeDouble(bid - (BUY_PROFIT / (TICKVALUE * BUY_LOTS) * _Point), _Digits);
      BREAKEVENSTOP_BUY = NormalizeDouble(ZEROLEVEL_BUY + (BREAKEVEN_STOP + BREAKEVEN_STEP) * _Point, _Digits);

      if(bid >= BREAKEVENSTOP_BUY)
         BREAKEVENSTEP_BUY = NormalizeDouble(ZEROLEVEL_BUY + BREAKEVEN_STEP * _Point, _Digits);

      if(BREAKEVENSTEP_BUY > 0 && bid <= BREAKEVENSTEP_BUY)
         CLOSE_BUY = true;
     }

   if(CMD == (int)POSITION_TYPE_SELL && SELLS > 0)
     {
      if(TICKVALUE * SELL_LOTS <= 0) return;
      ZEROLEVEL_SELL    = NormalizeDouble(ask + (SELL_PROFIT / (TICKVALUE * SELL_LOTS) * _Point), _Digits);
      BREAKEVENSTOP_SELL = NormalizeDouble(ZEROLEVEL_SELL - (BREAKEVEN_STOP + BREAKEVEN_STEP) * _Point, _Digits);

      if(ask <= BREAKEVENSTOP_SELL)
         BREAKEVENSTEP_SELL = NormalizeDouble(ZEROLEVEL_SELL - BREAKEVEN_STEP * _Point, _Digits);

      if(BREAKEVENSTEP_SELL > 0 && ask >= BREAKEVENSTEP_SELL)
         CLOSE_SELL = true;
     }
  }

//+------------------------------------------------------------------+
//| Virtual SL/TP — close all positions when combined P/L hits level |
//+------------------------------------------------------------------+
void VIRTUAL_STOPLOSS_TAKEPROFIT(int CMD = -1)
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(CMD == (int)POSITION_TYPE_BUY && BUYS > 0)
     {
      if(TICKVALUE * BUY_LOTS <= 0) return;
      ZEROLEVEL_BUY = NormalizeDouble(bid - (BUY_PROFIT / (TICKVALUE * BUY_LOTS) * _Point), _Digits);

      if(STOPLOSS > 0)   STOPLOSS_BUY   = NormalizeDouble(ZEROLEVEL_BUY - STOPLOSS   * _Point, _Digits);
      if(TAKEPROFIT > 0) TAKEPROFIT_BUY = NormalizeDouble(ZEROLEVEL_BUY + TAKEPROFIT * _Point, _Digits);

      if(TAKEPROFIT > 0 && TAKEPROFIT_BUY != 0 && bid >= TAKEPROFIT_BUY) CLOSE_BUY = true;
      if(STOPLOSS > 0   && STOPLOSS_BUY   != 0 && bid <= STOPLOSS_BUY)   CLOSE_BUY = true;
     }

   if(CMD == (int)POSITION_TYPE_SELL && SELLS > 0)
     {
      if(TICKVALUE * SELL_LOTS <= 0) return;
      ZEROLEVEL_SELL = NormalizeDouble(ask + (SELL_PROFIT / (TICKVALUE * SELL_LOTS) * _Point), _Digits);

      if(STOPLOSS > 0)   STOPLOSS_SELL   = NormalizeDouble(ZEROLEVEL_SELL + STOPLOSS   * _Point, _Digits);
      if(TAKEPROFIT > 0) TAKEPROFIT_SELL = NormalizeDouble(ZEROLEVEL_SELL - TAKEPROFIT * _Point, _Digits);

      if(TAKEPROFIT > 0 && TAKEPROFIT_SELL != 0 && ask <= TAKEPROFIT_SELL) CLOSE_SELL = true;
      if(STOPLOSS > 0   && STOPLOSS_SELL   != 0 && ask >= STOPLOSS_SELL)   CLOSE_SELL = true;
     }
  }

//+------------------------------------------------------------------+
//| Working hours filter                                             |
//+------------------------------------------------------------------+
bool WORKING_HOURS(string STARTTIME = "00:00", string ENDTIME = "00:00")
  {
   if(STARTTIME == "00:00" && ENDTIME == "00:00") return true;

   MqlDateTime t;
   TimeCurrent(t);
   double DATETIME = t.hour + t.min / 60.0;

   double TEMP_START = (int)StringSubstr(STARTTIME,0,2) + (int)StringSubstr(STARTTIME,3,2) / 60.0;
   double TEMP_END   = (int)StringSubstr(ENDTIME,  0,2) + (int)StringSubstr(ENDTIME,  3,2) / 60.0;
   double START_H    = MathMin(TEMP_END, TEMP_START);
   double END_H      = MathMax(TEMP_END, TEMP_START);

   bool ALLOWED = (DATETIME >= START_H && DATETIME < END_H);
   return (TEMP_START > TEMP_END) ? !ALLOWED : ALLOWED;
  }

//+------------------------------------------------------------------+
//| Info display on chart (profit statistics)                        |
//+------------------------------------------------------------------+
void INFO()
  {
   int    GROWTH_PIPS = 0;
   double TODAY=0, WEEK=0, MONTH=0, GROWTH=0;
   double VTODAY=0, VWEEK=0, VMONTH=0, VTOTAL=0;
   PROFIT_OTHER_SYMBOLS(TODAY, WEEK, MONTH, GROWTH, VTODAY, VWEEK, VMONTH, VTOTAL, GROWTH_PIPS);

   int    SPIPS_TODAY=0, SPIPS_WEEK=0, SPIPS_MONTH=0, SPIPS_GROWTH=0;
   double STODAY=0, SWEEK=0, SMONTH=0, SGROWTH=0;
   double SVTODAY=0, SVWEEK=0, SVMONTH=0, SVTOTAL=0;
   PROFIT_SYMBOL(STODAY,SWEEK,SMONTH,SGROWTH,SVTODAY,SVWEEK,SVMONTH,SVTOTAL,SPIPS_TODAY,SPIPS_WEEK,SPIPS_MONTH,SPIPS_GROWTH);

   double BAL = AccountInfoDouble(ACCOUNT_BALANCE);

   double TODAY_PCT  = (BAL - TODAY  - STODAY  != 0) ? NormalizeDouble(STODAY  / (BAL - TODAY  - STODAY)  * 100, 2) : 0;
   double WEEK_PCT   = (BAL - WEEK   - SWEEK   != 0) ? NormalizeDouble(SWEEK   / (BAL - WEEK   - SWEEK)   * 100, 2) : 0;
   double MONTH_PCT  = (BAL - MONTH  - SMONTH  != 0) ? NormalizeDouble(SMONTH  / (BAL - MONTH  - SMONTH)  * 100, 2) : 0;
   double GROWTH_PCT = (BAL - GROWTH - SGROWTH != 0) ? NormalizeDouble(SGROWTH / (BAL - GROWTH - SGROWTH) * 100, 2) : 0;

   string CUR = AccountInfoString(ACCOUNT_CURRENCY);
   OBJECT_LABEL(0,"LABEL_TODAY",  0,10,20, CORNER_RIGHT_UPPER, "\nTODAY: "  +DoubleToString(TODAY_PCT,2)+" %, "+DoubleToString(STODAY,2)+" "+CUR+", "+(string)SPIPS_TODAY+" PIPS",  "Arial",10,clrGold,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
   OBJECT_LABEL(0,"LABEL_WEEK",   0,10,40, CORNER_RIGHT_UPPER, "\nWEEK: "   +DoubleToString(WEEK_PCT,2)+" %, "+DoubleToString(SWEEK,2)+" "+CUR+", "+(string)SPIPS_WEEK+" PIPS",    "Arial",10,clrGold,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
   OBJECT_LABEL(0,"LABEL_MONTH",  0,10,60, CORNER_RIGHT_UPPER, "\nMONTH: "  +DoubleToString(MONTH_PCT,2)+" %, "+DoubleToString(SMONTH,2)+" "+CUR+", "+(string)SPIPS_MONTH+" PIPS", "Arial",10,clrGold,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
   OBJECT_LABEL(0,"LABEL_GROWTH", 0,10,80, CORNER_RIGHT_UPPER, "\nGROWTH: " +DoubleToString(GROWTH_PCT,2)+" %, "+DoubleToString(SGROWTH,2)+" "+CUR+", "+(string)SPIPS_GROWTH+" PIPS","Arial",10,clrGold,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
  }

//+------------------------------------------------------------------+
//| Delete all label objects                                         |
//+------------------------------------------------------------------+
void DEINIT_LABEL()
  {
   for(int i = ObjectsTotal(0,-1,-1)-1; i >= 0; i--)
     {
      string name = ObjectName(0,i,-1,-1);
      if(StringFind(name,"LABEL",0) >= 0)
         ObjectDelete(0,name);
     }
  }

//+------------------------------------------------------------------+
//| Create or update a text label                                    |
//+------------------------------------------------------------------+
bool OBJECT_LABEL(const long              CHART_ID   = 0,
                  const string            NAME       = "",
                  const int               SUB_WINDOW = 0,
                  const int               X          = 0,
                  const int               Y          = 0,
                  const ENUM_BASE_CORNER  CORNER     = CORNER_LEFT_UPPER,
                  const string            TEXT       = "",
                  const string            FONT       = "",
                  const int               FONT_SIZE  = 10,
                  const color             CLR        = clrRed,
                  const double            ANGLE      = 0.0,
                  const ENUM_ANCHOR_POINT ANCHOR     = ANCHOR_LEFT_UPPER,
                  const bool              BACK       = false,
                  const bool              SELECTION  = false,
                  const bool              HIDDEN     = true,
                  const long              ZORDER     = 0,
                  string                  TOOLTIP    = "\n")
  {
   ResetLastError();
   if(ObjectFind(0, NAME) < 0)
     {
      ObjectCreate(CHART_ID, NAME, OBJ_LABEL, SUB_WINDOW, 0, 0);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_XDISTANCE, X);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_YDISTANCE, Y);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_CORNER,    CORNER);
      ObjectSetString (CHART_ID, NAME, OBJPROP_TEXT,      TEXT);
      ObjectSetString (CHART_ID, NAME, OBJPROP_FONT,      FONT);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_FONTSIZE,  FONT_SIZE);
      ObjectSetDouble (CHART_ID, NAME, OBJPROP_ANGLE,     ANGLE);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_ANCHOR,    ANCHOR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR,     CLR);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_BACK,      BACK);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_SELECTABLE,SELECTION);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_SELECTED,  SELECTION);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_HIDDEN,    HIDDEN);
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_ZORDER,    ZORDER);
      ObjectSetString (CHART_ID, NAME, OBJPROP_TOOLTIP,   TOOLTIP);
     }
   else
     {
      ObjectSetInteger(CHART_ID, NAME, OBJPROP_COLOR, CLR);
      ObjectSetString (CHART_ID, NAME, OBJPROP_TEXT,  TEXT);
     }
   ChartRedraw();
   return true;
  }

//+------------------------------------------------------------------+
//| Get deposit/withdrawal amounts from history                      |
//+------------------------------------------------------------------+
double GET_WITHDRAW(ENUM_TIMEFRAMES _TIMEFRAME = PERIOD_CURRENT, int _STARTBAR = 0, int _ENDBAR = 0)
  {
   double _WITHDRAW = 0;
   datetime startTime = iTime(NULL, _TIMEFRAME, _STARTBAR);
   datetime endTime   = (_ENDBAR == -1) ? 0 : iTime(NULL, _TIMEFRAME, _ENDBAR);

   HistorySelect(0, TimeCurrent());
   for(int i = HistoryDealsTotal()-1; i >= 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BALANCE)
        {
         double p = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         datetime ct = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         if(p < 0 && ct >= startTime && (_ENDBAR == -1 || ct < endTime))
            _WITHDRAW -= p;
        }
     }
   return _WITHDRAW;
  }

double GET_DEPOSIT(ENUM_TIMEFRAMES _TIMEFRAME = PERIOD_CURRENT, int _STARTBAR = 0, int _ENDBAR = 0)
  {
   double _DEPOSIT = 0;
   datetime startTime = iTime(NULL, _TIMEFRAME, _STARTBAR);
   datetime endTime   = (_ENDBAR == -1) ? 0 : iTime(NULL, _TIMEFRAME, _ENDBAR);

   HistorySelect(0, TimeCurrent());
   for(int i = HistoryDealsTotal()-1; i >= 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BALANCE)
        {
         double p = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         datetime ct = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         if(p >= 0 && ct >= startTime && (_ENDBAR == -1 || ct < endTime))
            _DEPOSIT += p;
        }
     }
   return _DEPOSIT;
  }

//+------------------------------------------------------------------+
//| Profit statistics across ALL symbols                             |
//+------------------------------------------------------------------+
void PROFIT_OTHER_SYMBOLS(double &_TODAY, double &_WEEK, double &_MONTH, double &_GROWTH,
                           double &_VTODAY, double &_VWEEK, double &_VMONTH, double &_VTOTAL,
                           int &_GROWTH_PIPS)
  {
   _GROWTH_PIPS = 0;
   _TODAY = _WEEK = _MONTH = _GROWTH = 0;
   _VTODAY = _VWEEK = _VMONTH = _VTOTAL = 0;

   HistorySelect(0, TimeCurrent());
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;

      long magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if(magic != MAGIC_NUMBER && MAGIC_NUMBER != -1) continue;

      long dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(dealType != DEAL_TYPE_BUY && dealType != DEAL_TYPE_SELL) continue;

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT) +
                      HistoryDealGetDouble(ticket, DEAL_SWAP)   +
                      HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      double lots   = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      datetime ct   = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);

      if(ct >= iTime(NULL,PERIOD_D1, 0)) { _TODAY  += profit; _VTODAY += lots; }
      if(ct >= iTime(NULL,PERIOD_W1, 0)) { _WEEK   += profit; _VWEEK  += lots; }
      if(ct >= iTime(NULL,PERIOD_MN1,0)) { _MONTH  += profit; _VMONTH += lots; }

      double openP  = HistoryDealGetDouble(ticket, DEAL_PRICE);
      // No easy access to open price of the matching position here, skip pips for cross-symbol
      _GROWTH += profit; _VTOTAL += lots;
     }
  }

//+------------------------------------------------------------------+
//| Profit statistics for THIS symbol only                           |
//+------------------------------------------------------------------+
void PROFIT_SYMBOL(double &_TODAY, double &_WEEK, double &_MONTH, double &_GROWTH,
                   double &_VTODAY, double &_VWEEK, double &_VMONTH, double &_VTOTAL,
                   int &_TODAY_PIPS, int &_WEEK_PIPS, int &_MONTH_PIPS, int &_GROWTH_PIPS)
  {
   _TODAY_PIPS = _WEEK_PIPS = _MONTH_PIPS = _GROWTH_PIPS = 0;
   _TODAY = _WEEK = _MONTH = _GROWTH = 0;
   _VTODAY = _VWEEK = _VMONTH = _VTOTAL = 0;

   HistorySelect(0, TimeCurrent());
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;

      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      long magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if(magic != MAGIC_NUMBER && MAGIC_NUMBER != -1) continue;

      long dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(dealType != DEAL_TYPE_BUY && dealType != DEAL_TYPE_SELL) continue;

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT) +
                      HistoryDealGetDouble(ticket, DEAL_SWAP)   +
                      HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      double lots   = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double price  = HistoryDealGetDouble(ticket, DEAL_PRICE);
      datetime ct   = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);

      if(ct >= iTime(NULL, PERIOD_D1,  0)) { _TODAY  += profit; _VTODAY += lots; }
      if(ct >= iTime(NULL, PERIOD_W1,  0)) { _WEEK   += profit; _VWEEK  += lots; }
      if(ct >= iTime(NULL, PERIOD_MN1, 0)) { _MONTH  += profit; _VMONTH += lots; }
      _GROWTH += profit; _VTOTAL += lots;
     }
  }

//+------------------------------------------------------------------+
//| Lot calculation                                                  |
//+------------------------------------------------------------------+
double LOT_CALCULATE(double RISK, double SL, double BALANCE, double BALANCE_LOT)
  {
   double LOT = VOLUME; // safe default

   if(RISK_PER_TRADE > 0 && SL > 0 && TICKVALUE > 0)
     {
      // Risk-based: e.g. 1% of balance / SL pips
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      LOT = NormalizeDouble(((AccountInfoDouble(ACCOUNT_BALANCE) * RISK / 100.0) / SL) / TICKVALUE, 2);
      LOT = NormalizeDouble(MathRound(LOT / lotStep) * lotStep, 2);
     }
   else if(FROM_BALANCE > 0)
     {
      // Balance-proportional lot sizing (documented behavior)
      LOT = AccountInfoDouble(ACCOUNT_BALANCE) / FROM_BALANCE * BALANCE_LOT;
      LOT = NormalizeDouble(LOT, 2);
     }
   else
     {
      // Fixed lot
      LOT = VOLUME;
     }

   // Clamp to broker limits
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   LOT = MathMax(MathMin(LOT, maxLot), minLot);

   return LOT;
  }
//+------------------------------------------------------------------+