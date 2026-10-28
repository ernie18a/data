//+------------------------------------------------------------------+
//| XPro Trade Panel                                                 |
//| Version: 1.0           | Date: 2026-04-09                        |
//| Platform: MT5 / MT4                                              |
//| Author: XANDER PRO FX                                            |
//+------------------------------------------------------------------+
// CHANGELOG:
// v1.0  - 2026-04-09 - Initial release based on SimpleOrderPanel v2.08
//                      Rebranded as XPro Trade Panel by XANDER PRO FX
//                      All button groups enabled by default
//                      New color scheme (dark amber / gold palette)
//                      Nandara-style input panel with separators
//                      Freelancer contact note added
//+------------------------------------------------------------------+
// FREELANCER CONTACT:
// Need a custom EA, indicator or trade panel?
// Contact me on MQL5 Freelance:
//   https://www.mql5.com/en/users/09151993a
// Join the community on Telegram:
//   https://t.me/+-r54bygXwv9kYjQ5
//+------------------------------------------------------------------+
#property copyright "© XANDER PRO FX | mql5.com/en/users/09151993a"
#property link      "https://t.me/+-r54bygXwv9kYjQ5"
#property version   "1.00"

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>

// Instance ID fix for template issues
#define M_NAME "XPT1"

#ifdef __MQL5__

#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>

#define POS_TOTAL                    PositionsTotal()
#define ORD_TOTAL                    OrdersTotal()
#define ASK_PRICE                    SymbolInfoDouble(_Symbol, SYMBOL_ASK)
#define BID_PRICE                    SymbolInfoDouble(_Symbol, SYMBOL_BID)

#define POS_SELECT_BY_INDEX(i)       if (!m_position.SelectByIndex(i)) continue;
#define POS_SYMBOL                   m_position.Symbol()
#define POS_MAGIC                    m_position.Magic()
#define POS_TYPE                     m_position.PositionType()
#define POS_OPEN                     m_position.PriceOpen()
#define POS_STOP                     m_position.StopLoss()
#define POS_TAKE_PROFIT              m_position.TakeProfit()
#define POS_TICKET                   m_position.Ticket()

#define ORD_SELECT_BY_INDEX(i)       if (!m_order.SelectByIndex(i)) continue;
#define ORD_SYMBOL                   m_order.Symbol()
#define ORD_MAGIC                    m_order.Magic()
#define ORD_TYPE                     m_order.OrderType()
#define ORD_OPEN                     m_order.PriceOpen()
#define ORD_STOP                     m_order.StopLoss()
#define ORD_TAKE_PROFIT              m_order.TakeProfit()
#define ORD_TICKET                   m_order.Ticket()

#define POS_BUY(lots, price, sl, tp)           m_trade.Buy(lots, _Symbol, price, sl, tp, trade_comment);
#define POS_SELL(lots, price, sl, tp)          m_trade.Sell(lots, _Symbol, price, sl, tp, trade_comment);
#define ORDER_BUY_LIMIT(lots, price, sl, tp)   m_trade.BuyLimit(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, trade_comment);
#define ORDER_BUY_STOP(lots, price, sl, tp)    m_trade.BuyStop(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, trade_comment);
#define ORDER_SELL_LIMIT(lots, price, sl, tp)  m_trade.SellLimit(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, trade_comment);
#define ORDER_SELL_STOP(lots, price, sl, tp)   m_trade.SellStop(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, trade_comment);
#define POS_MODIFY(ticket, stop, take)         if(!m_trade.PositionModify(ticket, stop, take)) Print("Error modifying position: ", GetLastError());
#define POS_CLOSE(ticket)                      if(!m_trade.PositionClose(ticket)) Print("Error closing position, ", GetLastError());
#define POS_CLOSE_PARTIAL(ticket)              if(!m_trade.PositionClosePartial(ticket, partialLots)) Print("Error closing partial position, ", GetLastError());
#define ORD_DELETE(ticket)                     if (!m_trade.OrderDelete(ticket)) Print("Error deleting order, ", GetLastError());
#define ORD_MODIFY(ticket, stop, take)         if (!m_trade.OrderModify(ticket, ORD_OPEN, stop, take, ORDER_TIME_GTC, 0)) Print("Error modifying order: ", GetLastError());

#define TRIM_STRING_LEFT(param)   StringTrimLeft(param)
#define TRIM_STRING_RIGHT(param)  StringTrimRight(param)

CTrade        m_trade;
CPositionInfo m_position;
COrderInfo    m_order;

#else //__MQL4__

#define POSITION_TYPE_BUY   OP_BUY
#define POSITION_TYPE_SELL  OP_SELL

#define POS_TOTAL           OrdersTotal()
#define ORD_TOTAL           OrdersTotal()
#define ASK_PRICE           Ask
#define BID_PRICE           Bid

#define POS_SELECT_BY_INDEX(i)  if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
#define POS_SYMBOL              OrderSymbol()
#define POS_MAGIC               OrderMagicNumber()
#define POS_TYPE                OrderType()
#define POS_OPEN                OrderOpenPrice()
#define POS_STOP                OrderStopLoss()
#define POS_TAKE_PROFIT         OrderTakeProfit()
#define POS_TICKET              OrderTicket()

#define ORD_SELECT_BY_INDEX(i)  if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
#define ORD_SYMBOL              OrderSymbol()
#define ORD_MAGIC               OrderMagicNumber()
#define ORD_TYPE                OrderType()
#define ORD_OPEN                OrderOpenPrice()
#define ORD_STOP                OrderStopLoss()
#define ORD_TAKE_PROFIT         OrderTakeProfit()
#define ORD_TICKET              OrderTicket()

#define POS_BUY(lots, price, sl, tp)           OrderSend(_Symbol, OP_BUY, lots, price, expertDeviation, sl, tp, trade_comment, expertMagic, 0, clrNONE);
#define POS_SELL(lots, price, sl, tp)          OrderSend(_Symbol, OP_SELL, lots, price, expertDeviation, sl, tp, trade_comment, expertMagic, 0, clrNONE);
#define ORDER_BUY_LIMIT(lots, price, sl, tp)   OrderSend(_Symbol, OP_BUYLIMIT, lots, NormalizeDouble(price,_Digits), expertDeviation, sl, tp, trade_comment, expertMagic, 0, clrNONE);
#define ORDER_BUY_STOP(lots, price, sl, tp)    OrderSend(_Symbol, OP_BUYSTOP, lots, NormalizeDouble(price,_Digits), expertDeviation, sl, tp, trade_comment, expertMagic, 0, clrNONE);
#define ORDER_SELL_LIMIT(lots, price, sl, tp)  OrderSend(_Symbol, OP_SELLLIMIT, lots, NormalizeDouble(price,_Digits), expertDeviation, sl, tp, trade_comment, expertMagic, 0, clrNONE);
#define ORDER_SELL_STOP(lots, price, sl, tp)   OrderSend(_Symbol, OP_SELLSTOP, lots, NormalizeDouble(price,_Digits), expertDeviation, sl, tp, trade_comment, expertMagic, 0, clrNONE);
#define POS_MODIFY(ticket, stop, take)         if (!OrderModify(ticket, POS_OPEN, stop, take, OrderExpiration(), clrNONE)) Print("Error modifying position: ", GetLastError());
#define POS_CLOSE(ticket)                      if(POS_TYPE==POSITION_TYPE_BUY) { if(!OrderClose(ticket,OrderLots(),BID_PRICE,expertDeviation)) Print("Error closing position, ",GetLastError()); } else if(POS_TYPE==POSITION_TYPE_SELL) { if(!OrderClose(ticket,OrderLots(),ASK_PRICE,expertDeviation)) Print("Error closing position, ",GetLastError()); }
#define POS_CLOSE_PARTIAL(ticket)              if(POS_TYPE==POSITION_TYPE_BUY) { if(!OrderClose(ticket,MathMin(partialLots,OrderLots()),BID_PRICE,expertDeviation)) Print("Error closing partial position, ",GetLastError()); } else if(POS_TYPE==POSITION_TYPE_SELL) { if(!OrderClose(ticket,MathMin(partialLots,OrderLots()),ASK_PRICE,expertDeviation)) Print("Error closing partial position, ",GetLastError()); }
#define ORD_DELETE(ticket)                     if (!OrderDelete(ticket)) Print("Error deleting order, ", GetLastError());
#define ORD_MODIFY(ticket, stop, take)         if (!OrderModify(ticket, ORD_OPEN, stop, take, OrderExpiration(), clrNONE)) Print("Error modifying order: ", GetLastError());

#define TRIM_STRING_LEFT(param)   param=StringTrimLeft(param)
#define TRIM_STRING_RIGHT(param)  param=StringTrimRight(param)

#endif

//+------------------------------------------------------------------+
//| Layout constants                                                 |
//+------------------------------------------------------------------+
#define INDENT_LEFT      (11)
#define INDENT_TOP       (11)
#define INDENT_RIGHT     (11)
#define INDENT_BOTTOM    (11)
#define CONTROLS_GAP_X   (10)
#define CONTROLS_GAP_Y   (10)
#define BUTTON_WIDTH     (100)
#define BUTTON_HEIGHT    (25)

//+------------------------------------------------------------------+
//| Button / edit identifiers                                        |
//+------------------------------------------------------------------+
#define RISK_LABEL              "RISK"
#define STOP_EDIT               "SL_EDIT"
#define TAKE_EDIT               "TP_EDIT"
#define RISK_EDIT               "R_EDIT"
#define BUY_BUTTON              "BUY"
#define SELL_BUTTON             "SELL"
#define BREAKEVEN_BUTTON        "SL BREAKEVEN"
#define CLOSE_BUTTON            "CLOSE ALL"
#define CLOSE_BUY_BUTTON        "CLOSE BUYS"
#define CLOSE_SELL_BUTTON       "CLOSE SELLS"
#define STOP_BUTTON             "MODIFY SL"
#define TAKE_BUTTON             "MODIFY TP"
#define PARTIAL_EDIT            "PARTIAL_EDIT"
#define PARTIAL_BUTTON          "CLOSE PARTIAL"
#define COMMENT_EDIT            "COMM_EDIT"
#define BUY_PEND_BUTTON         "PENDING BUY"
#define SELL_PEND_BUTTON        "PENDING SELL"
#define DELETE_BUY_PEND_BUTTON  "DEL BUY ORD."
#define DELETE_SELL_PEND_BUTTON "DEL SELL ORD."

//+------------------------------------------------------------------+
//| Global variable names                                            |
//+------------------------------------------------------------------+
#define GVAR_POSITION_X   "XProPanel_positionX"
#define GVAR_POSITION_Y   "XProPanel_positionY"
#define GVAR_RISK_NAME    "XProPanel_risk_percent"
#define GVAR_CALC_TYPE    "XProPanel_calc_mode"
#define GVAR_STOP_LOSS    "XProPanel_stop_loss"
#define GVAR_TAKE_PROFIT  "XProPanel_take_profit"
#define GVAR_PARTIAL_LOTS "XProPanel_partial_close"

//+------------------------------------------------------------------+
//| Enumerators                                                      |
//+------------------------------------------------------------------+
enum RiskMode
{
   BALANCE_PERCENT, //Percentage of balance
   FIXED_LOTS       //Fixed lots
};

enum SLTPMode
{
   ST_PRICE,    //Price
   ST_DISTANCE  //Distance to open price (points)
};

enum BidAskMode
{
   BA_NORMAL,   //Bid for sell / Ask for buy
   BA_INVERT,   //Ask for sell / Bid for buy (inv)
   BA_ONLY_ASK, //Only Ask price
   BA_ONLY_BID  //Only Bid price
};

//+------------------------------------------------------------------+
//| Inputs — Nandara separator style                                 |
//+------------------------------------------------------------------+
input string sep0        = "★ XPro Trade Panel";           // ══ XANDER PRO FX ══
input string sep1        = "══════ TRADE SETTINGS ══════"; // ─────────────────────
input RiskMode  xp_riskCalculation   = FIXED_LOTS;          // Risk calculation mode
input SLTPMode  xp_stop_takeMode     = ST_DISTANCE;         // SL / TP mode
input BidAskMode xp_bidAskReference  = BA_NORMAL;           // Price reference for SL and TP
input int       xp_expertDeviation   = 20;                  // Maximum slippage (points)
input int       xp_expertMagic       = 450913;              // Expert Magic number
input bool      xp_affectOtherTrades = false;               // Modify trades from other EAs

input string sep2        = "══════ BUTTONS ══════";         // ─────────────────────
input bool xp_showBuySell      = true;   // Show Buy / Sell buttons
input bool xp_showCloseSep     = true;   // Show Close Buys / Sells buttons
input bool xp_showSLBECloseAll = true;   // Show SL to Breakeven / Close All buttons
input bool xp_showModify       = true;   // Show Modify SL / TP buttons
input bool xp_showPartialClose = true;   // Show Partial Close button
input bool xp_showPendingOrder = true;   // Show Pending Order buttons
input bool xp_showDeleteOrder  = true;   // Show Delete Pending Order buttons
input bool xp_showComment      = true;   // Show trade comment editor

input string sep3        = "══════ DISPLAY ══════";         // ─────────────────────
input bool   xp_grabSLwithDrag = false;  // Pick SL with crosshair drag (Distance mode)
input int    xp_fontSize       = 10;     // Font size
input double xp_autoSetTP      = 0.0;    // Auto-set TP from SL ratio (0 = disabled)
input bool   xp_autoSetSL      = true;   // Auto-set SL from TP change
#ifdef __MQL5__
input bool   xp_asyncOperations = false; // Use asynchronous orders
#endif

input string sep_last    = "══════ COMMUNITY ══════";       // ─────────────────────
input string xp_community = "https://t.me/+-r54bygXwv9kYjQ5"; // 🔗 Join XANDER PRO FX on Telegram

//+------------------------------------------------------------------+
//| Working variables                                                |
//+------------------------------------------------------------------+
// Alias macros so internal code keeps the same names
#define riskCalculation   xp_riskCalculation
#define stop_takeMode     xp_stop_takeMode
#define bidAskReference   xp_bidAskReference
#define expertDeviation   xp_expertDeviation
#define expertMagic       xp_expertMagic
#define affectOtherTrades xp_affectOtherTrades
#define showBuySellButtons      xp_showBuySell
#define showCloseSepButtons     xp_showCloseSep
#define showSLBECloseAllButtons xp_showSLBECloseAll
#define showModifyButtons       xp_showModify
#define showPartialClose        xp_showPartialClose
#define showPendingOrder        xp_showPendingOrder
#define showDeleteOrder         xp_showDeleteOrder
#define showCommentEdit         xp_showComment
#define grabSLwithDrag          xp_grabSLwithDrag
#define fontSize                xp_fontSize
#define autoSetTP               xp_autoSetTP
#define autoSetSL               xp_autoSetSL
#ifdef __MQL5__
#define asyncOperations         xp_asyncOperations
#endif

int    lot_digits    = 2;
double riskAmount    = 2.0;
double stopLoss      = 0.0;
double takeProfit    = 0.0;
double partialLots   = 1.0;
string trade_comment = NULL;

//+------------------------------------------------------------------+
//| XPro color palette                                               |
//+------------------------------------------------------------------+
#define CLR_BUY           C'0,140,255'     // Electric blue
#define CLR_SELL          C'220,60,60'     // Warm red
#define CLR_CLOSE_BUY     C'0,90,160'      // Dark blue
#define CLR_CLOSE_SELL    C'140,30,30'     // Dark red
#define CLR_BREAKEVEN     C'80,80,80'      // Neutral gray
#define CLR_CLOSE_ALL     C'180,100,0'     // Amber / gold
#define CLR_MODIFY_SL     C'160,60,60'     // Indian red
#define CLR_MODIFY_TP     C'0,130,130'     // Teal
#define CLR_PARTIAL       C'90,60,160'     // Purple
#define CLR_PEND_BUY      C'0,170,100'     // Green
#define CLR_PEND_SELL     C'200,80,0'      // Orange
#define CLR_DEL_BUY       C'0,100,60'      // Dark green
#define CLR_DEL_SELL      C'120,30,0'      // Maroon

//+------------------------------------------------------------------+
//| Panel class                                                      |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
{
private:
   CLabel  m_label, m_stoploss_label, m_takeprofit_label;
   CEdit   m_edit, m_stoploss_edit, m_takeprofit_edit;
   CButton m_buy_button, m_sell_button, m_breakeven_button, m_close_button;
   CButton m_modify_sl_button, m_modify_tp_button;
   CButton m_close_buys_button, m_close_sell_button;
   CButton m_buy_order_button, m_sell_order_button;
   CButton m_delete_buy_button, m_delete_sell_button;
   CEdit   m_partial_edit;
   CButton m_partial_button;
   CEdit   m_comment_edit;

public:
   virtual bool Create(const string name);
   virtual bool OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   double GetRiskPercent();
   double GetStopLoss();
   double GetTakeProfit();
   double GetPartialLots();
   void   SetStopLoss(int stop);

protected:
   bool CreateButton(CButton &button, string name, int x1, int y1, int x2, int y2, color clr_back = clrDarkCyan);
   bool CreateEdit(CEdit &edit, string name, string editText, int x1, int y1, int x2, int y2);
   bool CreateLabel(CLabel &label, string name, int x1, int y1, int x2, int y2);

   void OnEndEditRisk(void);
   void OnEndEditSL(void);
   void OnEndEditTP(void);
   void OnClickBuyButton(void);
   void OnClickSellButton(void);
   void OnClickBreakevenButton(void);
   void OnClickCloseButton(void);
   void OnClickCloseBuyButton(void);
   void OnClickCloseSellButton(void);
   void OnClickModifySLButton(void);
   void OnClickModifyTPButton(void);
   void OnEditPartialClose(void);
   void OnClickPartialCloseButton(void);
   void OnEditComment(void);
   void OnClickBuyOrderButton(void);
   void OnClickSellOrderButton(void);
   void OnClickDeleteBuyOrders(void);
   void OnClickDeleteSellOrders(void);

   void WriteExpertSettings();
   void RestoreExpertSettings();
   void RestoreStopTakeValues();
   void RestoreComment();
   void SaveComment();

   double NormalizeLots(double lots);
};

//+------------------------------------------------------------------+
//| Event map                                                        |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_END_EDIT, m_edit,            OnEndEditRisk)
ON_EVENT(ON_END_EDIT, m_stoploss_edit,   OnEndEditSL)
ON_EVENT(ON_END_EDIT, m_takeprofit_edit, OnEndEditTP)
if (showBuySellButtons)
{
   ON_EVENT(ON_CLICK, m_buy_button,  OnClickBuyButton)
   ON_EVENT(ON_CLICK, m_sell_button, OnClickSellButton)
}
if (showCloseSepButtons)
{
   ON_EVENT(ON_CLICK, m_close_buys_button, OnClickCloseBuyButton)
   ON_EVENT(ON_CLICK, m_close_sell_button, OnClickCloseSellButton)
}
if (showSLBECloseAllButtons)
{
   ON_EVENT(ON_CLICK, m_breakeven_button, OnClickBreakevenButton)
   ON_EVENT(ON_CLICK, m_close_button,     OnClickCloseButton)
}
if (showModifyButtons)
{
   ON_EVENT(ON_CLICK, m_modify_sl_button, OnClickModifySLButton)
   ON_EVENT(ON_CLICK, m_modify_tp_button, OnClickModifyTPButton)
}
if (showPartialClose)
{
   ON_EVENT(ON_END_EDIT, m_partial_edit,   OnEditPartialClose)
   ON_EVENT(ON_CLICK,    m_partial_button, OnClickPartialCloseButton)
}
if (showCommentEdit)
{
   ON_EVENT(ON_END_EDIT, m_comment_edit, OnEditComment)
}
if (showPendingOrder)
{
   ON_EVENT(ON_CLICK, m_buy_order_button,  OnClickBuyOrderButton)
   ON_EVENT(ON_CLICK, m_sell_order_button, OnClickSellOrderButton)
}
if (showDeleteOrder)
{
   ON_EVENT(ON_CLICK, m_delete_buy_button,  OnClickDeleteBuyOrders)
   ON_EVENT(ON_CLICK, m_delete_sell_button, OnClickDeleteSellOrders)
}
EVENT_MAP_END(CAppDialog)

//+------------------------------------------------------------------+
//| Create panel and all controls                                    |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const string name)
{
   stopLoss    = 0.0;
   takeProfit  = 0.0;
   partialLots = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   RestoreExpertSettings();

   int rows = 3;
   if (showBuySellButtons)      rows++;
   if (showCloseSepButtons)     rows++;
   if (showSLBECloseAllButtons) rows++;
   if (showModifyButtons)       rows++;
   if (showPartialClose)        rows++;
   if (showCommentEdit)         rows++;
   if (showPendingOrder)        rows++;
   if (showDeleteOrder)         rows++;

   if (rows == 3) { Print("Error: no buttons enabled"); return false; }

   int x1 = 100, y1 = 40;
   if (GlobalVariableCheck(GVAR_POSITION_X)) x1 = (int)GlobalVariableGet(GVAR_POSITION_X);
   else GlobalVariableSet(GVAR_POSITION_X, x1);
   if (GlobalVariableCheck(GVAR_POSITION_Y)) y1 = (int)GlobalVariableGet(GVAR_POSITION_Y);
   else GlobalVariableSet(GVAR_POSITION_Y, y1);

   int x2 = 8  + x1 + INDENT_LEFT + 2 * BUTTON_WIDTH + CONTROLS_GAP_X + INDENT_RIGHT;
   int y2 = 30 + y1 + INDENT_TOP  + rows * BUTTON_HEIGHT + (rows - 1) * CONTROLS_GAP_Y + INDENT_BOTTOM;

   if (!CAppDialog::Create(0, name, 1, x1, y1, x2, y2)) return false;

   int bx1 = INDENT_LEFT,  by1 = INDENT_TOP;
   int bx2 = bx1 + BUTTON_WIDTH, by2 = by1 + BUTTON_HEIGHT;

#define NEXT_COLUMN bx1 += (BUTTON_WIDTH+CONTROLS_GAP_X); bx2 += (BUTTON_WIDTH+CONTROLS_GAP_X);
#define PREV_COLUMN bx1 -= (BUTTON_WIDTH+CONTROLS_GAP_X); bx2 -= (BUTTON_WIDTH+CONTROLS_GAP_X);
#define NEXT_ROW    by1 += (BUTTON_HEIGHT+CONTROLS_GAP_Y); by2 += (BUTTON_HEIGHT+CONTROLS_GAP_Y);

   // Row 1 — Risk label + edit
   if (!CreateLabel(m_label, riskCalculation == BALANCE_PERCENT ? "RISK %" : "LOTS", bx1 + BUTTON_WIDTH / 2, by1, bx2, by2)) return false;
   NEXT_COLUMN
   string riskText = (riskCalculation == BALANCE_PERCENT) ? DoubleToString(riskAmount, 2) + " %" : DoubleToString(riskAmount, lot_digits);
   if (!CreateEdit(m_edit, RISK_EDIT, riskText, bx1, by1, bx2, by2)) return false;
   PREV_COLUMN NEXT_ROW

   // Row 2 — SL
   if (!CreateLabel(m_stoploss_label, stop_takeMode == ST_DISTANCE ? "SL (points)" : "SL (price)", bx1 + BUTTON_WIDTH / 3, by1, bx2, by2)) return false;
   NEXT_COLUMN
   string sl_str = stop_takeMode == ST_DISTANCE ? DoubleToString(stopLoss, 0) : DoubleToString(stopLoss, _Digits);
   if (!CreateEdit(m_stoploss_edit, STOP_EDIT, sl_str, bx1, by1, bx2, by2)) return false;
   PREV_COLUMN NEXT_ROW

   // Row 3 — TP
   if (!CreateLabel(m_takeprofit_label, stop_takeMode == ST_DISTANCE ? "TP (points)" : "TP (price)", bx1 + BUTTON_WIDTH / 3, by1, bx2, by2)) return false;
   NEXT_COLUMN
   string tp_str = stop_takeMode == ST_DISTANCE ? DoubleToString(takeProfit, 0) : DoubleToString(takeProfit, _Digits);
   if (!CreateEdit(m_takeprofit_edit, TAKE_EDIT, tp_str, bx1, by1, bx2, by2)) return false;

   if (showBuySellButtons)
   {
      PREV_COLUMN NEXT_ROW
      if (!CreateButton(m_buy_button,  BUY_BUTTON,  bx1, by1, bx2, by2, CLR_BUY))  return false;
      NEXT_COLUMN
      if (!CreateButton(m_sell_button, SELL_BUTTON, bx1, by1, bx2, by2, CLR_SELL)) return false;
   }

   if (showCloseSepButtons)
   {
      PREV_COLUMN NEXT_ROW
      if (!CreateButton(m_close_buys_button, CLOSE_BUY_BUTTON,  bx1, by1, bx2, by2, CLR_CLOSE_BUY))  return false;
      NEXT_COLUMN
      if (!CreateButton(m_close_sell_button, CLOSE_SELL_BUTTON, bx1, by1, bx2, by2, CLR_CLOSE_SELL)) return false;
   }

   if (showSLBECloseAllButtons)
   {
      PREV_COLUMN NEXT_ROW
      if (!CreateButton(m_breakeven_button, BREAKEVEN_BUTTON, bx1, by1, bx2, by2, CLR_BREAKEVEN)) return false;
      NEXT_COLUMN
      if (!CreateButton(m_close_button,     CLOSE_BUTTON,     bx1, by1, bx2, by2, CLR_CLOSE_ALL)) return false;
   }

   if (showModifyButtons)
   {
      PREV_COLUMN NEXT_ROW
      if (!CreateButton(m_modify_sl_button, STOP_BUTTON, bx1, by1, bx2, by2, CLR_MODIFY_SL)) return false;
      NEXT_COLUMN
      if (!CreateButton(m_modify_tp_button, TAKE_BUTTON, bx1, by1, bx2, by2, CLR_MODIFY_TP)) return false;
   }

   if (showPartialClose)
   {
      PREV_COLUMN NEXT_ROW
      string partialStr = DoubleToString(partialLots, lot_digits);
      if (!CreateEdit(m_partial_edit,     PARTIAL_EDIT,   partialStr, bx1, by1, bx2, by2)) return false;
      NEXT_COLUMN
      if (!CreateButton(m_partial_button, PARTIAL_BUTTON, bx1, by1, bx2, by2, CLR_PARTIAL)) return false;
   }

   if (showPendingOrder)
   {
      PREV_COLUMN NEXT_ROW
      if (!CreateButton(m_buy_order_button,  BUY_PEND_BUTTON,  bx1, by1, bx2, by2, CLR_PEND_BUY))  return false;
      NEXT_COLUMN
      if (!CreateButton(m_sell_order_button, SELL_PEND_BUTTON, bx1, by1, bx2, by2, CLR_PEND_SELL)) return false;
   }

   if (showDeleteOrder)
   {
      PREV_COLUMN NEXT_ROW
      if (!CreateButton(m_delete_buy_button,  DELETE_BUY_PEND_BUTTON,  bx1, by1, bx2, by2, CLR_DEL_BUY))  return false;
      NEXT_COLUMN
      if (!CreateButton(m_delete_sell_button, DELETE_SELL_PEND_BUTTON, bx1, by1, bx2, by2, CLR_DEL_SELL)) return false;
   }

   if (showCommentEdit)
   {
      bx1 -= (BUTTON_WIDTH + CONTROLS_GAP_X);
      NEXT_ROW
      if (!CreateEdit(m_comment_edit, COMMENT_EDIT, trade_comment, bx1, by1, bx2, by2)) return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Create helpers                                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButton(CButton &button, string name, int x1, int y1, int x2, int y2, color clr_back = clrDarkCyan)
{
   if (!button.Create(m_chart_id, m_name + name, m_subwin, x1, y1, x2, y2)) return false;
   if (!button.Text(name))          return false;
   if (!button.FontSize(fontSize))  return false;
   button.ColorBorder(C'20,20,20');
   button.Color(clrWhite);
   button.ColorBackground(clr_back);
   if (!Add(button)) return false;
   return true;
}

bool CControlsDialog::CreateEdit(CEdit &edit, string name, string editText, int x1, int y1, int x2, int y2)
{
   if (!edit.Create(m_chart_id, m_name + name, m_subwin, x1, y1, x2, y2)) return false;
   if (!edit.ReadOnly(false))          return false;
   if (!edit.Text(editText))           return false;
   if (!edit.FontSize(fontSize))       return false;
   if (!edit.TextAlign(ALIGN_CENTER))  return false;
   if (!Add(edit)) return false;
   return true;
}

bool CControlsDialog::CreateLabel(CLabel &label, string name, int x1, int y1, int x2, int y2)
{
   if (!label.Create(m_chart_id, m_name + name, m_subwin, x1, y1, x2, y2)) return false;
   if (!label.Text(name))         return false;
   if (!label.FontSize(fontSize)) return false;
   if (!Add(label)) return false;
   return true;
}

//+------------------------------------------------------------------+
//| Getters                                                          |
//+------------------------------------------------------------------+
double CControlsDialog::GetRiskPercent(void)
{
   if (riskCalculation == FIXED_LOTS)
      return NormalizeLots(StringToDouble(m_edit.Text()));
   return MathMin(MathMax(StringToDouble(m_edit.Text()), 0.0), 100.0);
}

double CControlsDialog::GetStopLoss(void)    { return MathMax(StringToDouble(m_stoploss_edit.Text()),   0.0); }
double CControlsDialog::GetTakeProfit(void)  { return MathMax(StringToDouble(m_takeprofit_edit.Text()), 0.0); }
double CControlsDialog::GetPartialLots(void) { return NormalizeLots(StringToDouble(m_partial_edit.Text())); }

//+------------------------------------------------------------------+
//| Button handlers                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickBuyButton(void)
{
   Print("Buy pressed");
   RecalculateValues(POSITION_TYPE_BUY);
   if (!CheckLots()) return;

   double ask = ASK_PRICE;
   double sl = 0.0, tp = 0.0;

   if (stop_takeMode == ST_PRICE)
      { sl = stopLoss; tp = takeProfit; }
   else
   {
      double ref = (bidAskReference == BA_NORMAL || bidAskReference == BA_ONLY_ASK) ? ask : BID_PRICE;
      if (stopLoss   != 0.0) sl = ref - stopLoss   * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if (takeProfit != 0.0) tp = ref + takeProfit  * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   POS_BUY(totalLots, ask, sl, tp)
}

void CControlsDialog::OnClickSellButton(void)
{
   Print("Sell pressed");
   RecalculateValues(POSITION_TYPE_SELL);
   if (!CheckLots()) return;

   double bid = BID_PRICE;
   double sl = 0.0, tp = 0.0;

   if (stop_takeMode == ST_PRICE)
      { sl = stopLoss; tp = takeProfit; }
   else
   {
      double ref = (bidAskReference == BA_NORMAL || bidAskReference == BA_ONLY_BID) ? bid : ASK_PRICE;
      if (stopLoss   != 0.0) sl = ref + stopLoss   * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if (takeProfit != 0.0) tp = ref - takeProfit  * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   POS_SELL(totalLots, bid, sl, tp)
}

void CControlsDialog::OnClickBreakevenButton(void)
{
   Print("Breakeven pressed");
   for (int i = POS_TOTAL - 1; i >= 0; i--)
   {
      POS_SELECT_BY_INDEX(i)
      if (POS_SYMBOL != _Symbol || (!affectOtherTrades && POS_MAGIC != expertMagic)) continue;

      if (POS_TYPE == POSITION_TYPE_BUY)
         { if (BID_PRICE <= POS_OPEN || POS_OPEN == POS_STOP) continue; }
      else if (POS_TYPE == POSITION_TYPE_SELL)
         { if (ASK_PRICE >= POS_OPEN || POS_OPEN == POS_STOP) continue; }
      else continue;

      POS_MODIFY(POS_TICKET, POS_OPEN, POS_TAKE_PROFIT)
   }
}

void CControlsDialog::OnClickCloseButton(void)
{
   Print("Close All pressed");
   for (int i = POS_TOTAL - 1; i >= 0; i--)
   {
      POS_SELECT_BY_INDEX(i)
      if (POS_SYMBOL == _Symbol && (affectOtherTrades || POS_MAGIC == expertMagic))
         POS_CLOSE(POS_TICKET)
   }
}

void CControlsDialog::OnClickCloseBuyButton(void)
{
   Print("Close Buys pressed");
   for (int i = POS_TOTAL - 1; i >= 0; i--)
   {
      POS_SELECT_BY_INDEX(i)
      if (POS_TYPE == POSITION_TYPE_SELL) continue;
      if (POS_SYMBOL == _Symbol && (affectOtherTrades || POS_MAGIC == expertMagic))
         POS_CLOSE(POS_TICKET)
   }
}

void CControlsDialog::OnClickCloseSellButton(void)
{
   Print("Close Sells pressed");
   for (int i = POS_TOTAL - 1; i >= 0; i--)
   {
      POS_SELECT_BY_INDEX(i)
      if (POS_TYPE == POSITION_TYPE_BUY) continue;
      if (POS_SYMBOL == _Symbol && (affectOtherTrades || POS_MAGIC == expertMagic))
         POS_CLOSE(POS_TICKET)
   }
}

void CControlsDialog::OnClickModifySLButton(void)
{
   Print("Modify SL pressed");
   for (int i = POS_TOTAL - 1; i >= 0; i--)
   {
      POS_SELECT_BY_INDEX(i)
      if (POS_SYMBOL != _Symbol || (!affectOtherTrades && POS_MAGIC != expertMagic)) continue;

      double sl = 0.0;
      if (stop_takeMode == ST_PRICE) { sl = stopLoss; }
      else if (stopLoss != 0.0)
      {
         if      (POS_TYPE == POSITION_TYPE_BUY)  sl = BID_PRICE - stopLoss * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         else if (POS_TYPE == POSITION_TYPE_SELL)  sl = ASK_PRICE + stopLoss * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         else continue;
      }

      if (sl != POS_STOP) POS_MODIFY(POS_TICKET, sl, POS_TAKE_PROFIT)
      else Print("SL already at " + (string)sl);
   }
}

void CControlsDialog::OnClickModifyTPButton(void)
{
   Print("Modify TP pressed");
   for (int i = POS_TOTAL - 1; i >= 0; i--)
   {
      POS_SELECT_BY_INDEX(i)
      if (POS_SYMBOL != _Symbol || (!affectOtherTrades && POS_MAGIC != expertMagic)) continue;

      double tp = 0.0;
      if (stop_takeMode == ST_PRICE) { tp = takeProfit; }
      else if (takeProfit != 0.0)
      {
         if      (POS_TYPE == POSITION_TYPE_BUY)  tp = ASK_PRICE + takeProfit * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         else if (POS_TYPE == POSITION_TYPE_SELL)  tp = BID_PRICE - takeProfit * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         else continue;
      }

      if (tp != POS_TAKE_PROFIT) POS_MODIFY(POS_TICKET, POS_STOP, tp)
      else Print("TP already at " + (string)tp);
   }
}

void CControlsDialog::OnClickPartialCloseButton(void)
{
   Print("Partial Close pressed");
   for (int i = POS_TOTAL - 1; i >= 0; i--)
   {
      POS_SELECT_BY_INDEX(i)
      if (POS_SYMBOL == _Symbol && (affectOtherTrades || POS_MAGIC == expertMagic))
         POS_CLOSE_PARTIAL(POS_TICKET)
   }
}

void CControlsDialog::OnClickBuyOrderButton(void)
{
   Print("Pending Buy pressed");
   setting_buy  = true;
   setting_sell = false;
   CreatePendingSetLine(CLR_BUY, ASK_PRICE);
}

void CControlsDialog::OnClickSellOrderButton(void)
{
   Print("Pending Sell pressed");
   setting_sell = true;
   setting_buy  = false;
   CreatePendingSetLine(CLR_SELL, BID_PRICE);
}

void CControlsDialog::OnClickDeleteBuyOrders(void)
{
   Print("Delete Pending Buys pressed");
   for (int j = ORD_TOTAL - 1; j >= 0; j--)
   {
      ORD_SELECT_BY_INDEX(j)
      if (ORD_TYPE != ORDER_TYPE_BUY_LIMIT && ORD_TYPE != ORDER_TYPE_BUY_STOP) continue;
      if (ORD_SYMBOL == _Symbol && (affectOtherTrades || ORD_MAGIC == expertMagic))
         ORD_DELETE(ORD_TICKET)
   }
}

void CControlsDialog::OnClickDeleteSellOrders(void)
{
   Print("Delete Pending Sells pressed");
   for (int j = ORD_TOTAL - 1; j >= 0; j--)
   {
      ORD_SELECT_BY_INDEX(j)
      if (ORD_TYPE != ORDER_TYPE_SELL_LIMIT && ORD_TYPE != ORDER_TYPE_SELL_STOP) continue;
      if (ORD_SYMBOL == _Symbol && (affectOtherTrades || ORD_MAGIC == expertMagic))
         ORD_DELETE(ORD_TICKET)
   }
}

//+------------------------------------------------------------------+
//| Edit handlers                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnEndEditRisk(void)
{
   riskAmount = GetRiskPercent();
   if (riskCalculation == BALANCE_PERCENT)
      m_edit.Text(DoubleToString(riskAmount, 2) + " %");
   else
      m_edit.Text(DoubleToString(riskAmount, lot_digits));
   WriteExpertSettings();
}

void CControlsDialog::OnEndEditSL(void)
{
   stopLoss = GetStopLoss();
   m_stoploss_edit.Text(stop_takeMode == ST_PRICE ? DoubleToString(stopLoss, _Digits) : DoubleToString(stopLoss, 0));
   if (autoSetTP > 0.0 && stop_takeMode == ST_DISTANCE)
   {
      takeProfit = MathRound(stopLoss * autoSetTP);
      m_takeprofit_edit.Text(DoubleToString(takeProfit, 0));
   }
   WriteExpertSettings();
}

void CControlsDialog::OnEndEditTP(void)
{
   takeProfit = GetTakeProfit();
   m_takeprofit_edit.Text(stop_takeMode == ST_PRICE ? DoubleToString(takeProfit, _Digits) : DoubleToString(takeProfit, 0));
   if (autoSetSL && autoSetTP > 0.0 && stop_takeMode == ST_DISTANCE)
   {
      stopLoss = MathRound(takeProfit / autoSetTP);
      m_stoploss_edit.Text(DoubleToString(stopLoss, 0));
   }
   WriteExpertSettings();
}

void CControlsDialog::OnEditPartialClose(void)
{
   partialLots = GetPartialLots();
   m_partial_edit.Text(DoubleToString(partialLots, lot_digits));
   WriteExpertSettings();
}

void CControlsDialog::OnEditComment(void)
{
   trade_comment = m_comment_edit.Text();
   SaveComment();
}

//+------------------------------------------------------------------+
//| Settings persistence                                             |
//+------------------------------------------------------------------+
void CControlsDialog::WriteExpertSettings(void)
{
   GlobalVariableSet(GVAR_RISK_NAME,    riskAmount);
   GlobalVariableSet(GVAR_CALC_TYPE,    stop_takeMode);
   GlobalVariableSet(GVAR_STOP_LOSS,    stopLoss);
   GlobalVariableSet(GVAR_TAKE_PROFIT,  takeProfit);
   GlobalVariableSet(GVAR_PARTIAL_LOTS, partialLots);
}

void CControlsDialog::RestoreExpertSettings(void)
{
   if (showCommentEdit) RestoreComment();
   else trade_comment = NULL;

   if (GlobalVariableCheck(GVAR_RISK_NAME))
   {
      riskAmount  = GlobalVariableGet(GVAR_RISK_NAME);
      if (riskCalculation == FIXED_LOTS) riskAmount = NormalizeLots(riskAmount);
      partialLots = NormalizeLots(GlobalVariableGet(GVAR_PARTIAL_LOTS));
      RestoreStopTakeValues();
   }
   else WriteExpertSettings();
}

void CControlsDialog::RestoreStopTakeValues(void)
{
   if (GlobalVariableCheck(GVAR_CALC_TYPE))
   {
      int typeCalc = (int)GlobalVariableGet(GVAR_CALC_TYPE);
      if (typeCalc == stop_takeMode)
      {
         stopLoss   = GlobalVariableGet(GVAR_STOP_LOSS);
         takeProfit = GlobalVariableGet(GVAR_TAKE_PROFIT);
         return;
      }
   }
   WriteExpertSettings();
}

void CControlsDialog::RestoreComment(void)
{
   if (!FileIsExist("XPT_SavedComment.txt")) return;
   int file = FileOpen("XPT_SavedComment.txt", FILE_READ | FILE_TXT | FILE_SHARE_READ);
   if (file == INVALID_HANDLE) { Print("Error reading comment file"); return; }
   trade_comment = FileReadString(file);
   FileClose(file);
}

void CControlsDialog::SaveComment(void)
{
   int file = FileOpen("XPT_SavedComment.txt", FILE_WRITE | FILE_TXT);
   if (file == INVALID_HANDLE) { Print("Error saving comment file"); return; }
   FileWrite(file, trade_comment);
   FileClose(file);
}

//+------------------------------------------------------------------+
//| Lot normalizer                                                   |
//+------------------------------------------------------------------+
double CControlsDialog::NormalizeLots(double lots)
{
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   return MathMax(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
          MathMin(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX),
                  MathFloor(lots / lotStep) * lotStep));
}

void CControlsDialog::SetStopLoss(int stop)
{
   stopLoss = stop;
   m_stoploss_edit.Text(IntegerToString(stop));
   if (autoSetTP > 0.0 && stop_takeMode == ST_DISTANCE)
   {
      takeProfit = MathRound(stopLoss * autoSetTP);
      m_takeprofit_edit.Text(DoubleToString(takeProfit, 0));
   }
   ChartRedraw();
   WriteExpertSettings();
}

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;

double   totalLots;
MqlRates currentRates[2];

bool     is_tracking    = false;
double   recorded_price = 0.0;

bool     setting_buy  = false;
bool     setting_sell = false;
int      xysub;
double   xyprice;
datetime xytime;

#define PENDING_SETLINE "XPT_setline"

//+------------------------------------------------------------------+
//| Pending line helpers                                             |
//+------------------------------------------------------------------+
void CreatePendingSetLine(color clr, double line_price)
{
   if (ObjectFind(ChartID(), PENDING_SETLINE) < 0)
      ObjectCreate(ChartID(), PENDING_SETLINE, OBJ_HLINE, 0, 0, line_price);
   ObjectSetInteger(ChartID(), PENDING_SETLINE, OBJPROP_COLOR,      clr);
   ObjectSetInteger(ChartID(), PENDING_SETLINE, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(ChartID(), PENDING_SETLINE, OBJPROP_HIDDEN,     false);
   ObjectSetString (ChartID(), PENDING_SETLINE, OBJPROP_TOOLTIP,    "\n");
   ChartRedraw();
}

void MovePendingSetLine(double line_price)
{
   ObjectSetDouble(ChartID(), PENDING_SETLINE, OBJPROP_PRICE, line_price);
   ChartRedraw();
}

void DeletePendingSetLine()
{
   ObjectDelete(ChartID(), PENDING_SETLINE);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Risk calculation                                                 |
//+------------------------------------------------------------------+
void RecalculateValues(int position, double price_ref = 0.0)
{
   if (riskCalculation == FIXED_LOTS) { totalLots = riskAmount; return; }

   double riskTotal = AccountInfoDouble(ACCOUNT_BALANCE) * riskAmount / 100.0;
   double sl = 0.0;

   if (stop_takeMode == ST_PRICE)
   {
      if (stopLoss != 0.0)
      {
         if (price_ref > 0.0) sl = MathAbs(price_ref - stopLoss);
         else
         {
            if      (position == POSITION_TYPE_BUY)  sl = ASK_PRICE - stopLoss;
            else if (position == POSITION_TYPE_SELL)  sl = stopLoss - BID_PRICE;
         }
      }
   }
   else sl = stopLoss * SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   if (sl == 0.0) { totalLots = 0.0; Print("SL cannot be 0 with risk percent"); return; }

   sl /= SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double lotValue   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   double pointValue = riskTotal / sl;

   if (pointValue < 0) { totalLots = 0.0; Print("Invalid stop"); return; }

   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   totalLots = MathFloor((pointValue / lotValue) / lotStep) * lotStep;
}

bool CheckLots()
{
   if (totalLots < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) { Print("Risk too small to open a trade"); return false; }
   if (totalLots > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)) { Print("Lots too large to open a trade"); return false; }
   return true;
}

//+------------------------------------------------------------------+
//| Pending order openers                                            |
//+------------------------------------------------------------------+
void OpenBuyPendingOrder(double order_price)
{
   Print("Open Buy Pending");
   RecalculateValues(POSITION_TYPE_BUY, order_price);
   if (!CheckLots()) return;

   double sl = 0.0, tp = 0.0;
   if (stop_takeMode == ST_PRICE) { sl = stopLoss; tp = takeProfit; }
   else
   {
      if (stopLoss   != 0.0) sl = order_price - stopLoss   * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if (takeProfit != 0.0) tp = order_price + takeProfit * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   if (order_price > ASK_PRICE) ORDER_BUY_STOP(totalLots, order_price, sl, tp)
   else                         ORDER_BUY_LIMIT(totalLots, order_price, sl, tp)
}

void OpenSellPendingOrder(double order_price)
{
   Print("Open Sell Pending");
   RecalculateValues(POSITION_TYPE_SELL, order_price);
   if (!CheckLots()) return;

   double sl = 0.0, tp = 0.0;
   if (stop_takeMode == ST_PRICE) { sl = stopLoss; tp = takeProfit; }
   else
   {
      if (stopLoss   != 0.0) sl = order_price + stopLoss   * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if (takeProfit != 0.0) tp = order_price - takeProfit * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   if (order_price < BID_PRICE) ORDER_SELL_STOP(totalLots, order_price, sl, tp)
   else                         ORDER_SELL_LIMIT(totalLots, order_price, sl, tp)
}

//+------------------------------------------------------------------+
//| OnInit / OnDeinit                                                |
//+------------------------------------------------------------------+
int OnInit()
{
   ObjectsDeleteAll(0, M_NAME);
   lot_digits = int(-MathLog10(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)));

   if (!ExtDialog.Create("XPro Trade Panel"))
      return INIT_FAILED;

   ExtDialog.Run();

#ifdef __MQL5__
   m_trade.SetExpertMagicNumber(expertMagic);
   m_trade.SetDeviationInPoints(expertDeviation);
   if (asyncOperations) m_trade.SetAsyncMode(true);
#endif

   setting_buy  = false;
   setting_sell = false;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   GlobalVariableSet(GVAR_POSITION_X, ExtDialog.Left());
   GlobalVariableSet(GVAR_POSITION_Y, ExtDialog.Top());
   DeletePendingSetLine();
   Comment("");
   ExtDialog.Destroy(reason);
}

//+------------------------------------------------------------------+
//| OnChartEvent                                                     |
//+------------------------------------------------------------------+
#define MASK_RIGHT_CLICK   2
#define MASK_RIGHT_MIDDLE  16

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   ExtDialog.ChartEvent(id, lparam, dparam, sparam);

   if (setting_buy || setting_sell)
   {
      int smask = (int)StringToInteger(sparam);
      if ((id == CHARTEVENT_KEYDOWN && lparam == 27) ||
          (id == CHARTEVENT_MOUSE_MOVE && ((smask & MASK_RIGHT_CLICK) > 0 || (smask & MASK_RIGHT_MIDDLE) > 0)))
      {
         DeletePendingSetLine();
         setting_buy = setting_sell = false;
         return;
      }
   }

   if (setting_buy)
   {
      if (id == CHARTEVENT_CLICK)
      {
         DeletePendingSetLine();
         ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, xysub, xytime, xyprice);
         OpenBuyPendingOrder(xyprice);
         setting_buy = false;
         return;
      }
      if (id == CHARTEVENT_MOUSE_MOVE)
      {
         ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, xysub, xytime, xyprice);
         MovePendingSetLine(xyprice);
         return;
      }
   }

   if (setting_sell)
   {
      if (id == CHARTEVENT_CLICK)
      {
         DeletePendingSetLine();
         ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, xysub, xytime, xyprice);
         OpenSellPendingOrder(xyprice);
         setting_sell = false;
         return;
      }
      if (id == CHARTEVENT_MOUSE_MOVE)
      {
         ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, xysub, xytime, xyprice);
         MovePendingSetLine(xyprice);
         return;
      }
   }

   if (!grabSLwithDrag || stop_takeMode == ST_PRICE) return;

   if (id == CHARTEVENT_CLICK)
   {
      if (!is_tracking) return;
      if (!(recorded_price > 0.0)) { is_tracking = false; return; }
      ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, xysub, xytime, xyprice);
#ifdef __MQL5__
      int pips = (int)MathRound(MathAbs(xyprice - recorded_price) / SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));
#else
      int pips = (int)(MathAbs(xyprice - recorded_price) / SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));
#endif
      if (pips > 0) ExtDialog.SetStopLoss(pips);
      is_tracking = false;
      recorded_price = 0.0;
   }

   if (id == CHARTEVENT_MOUSE_MOVE)
   {
      if (sparam != "1" || is_tracking) return;
      ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, xysub, xytime, xyprice);
      if (xysub > 0) return;
      recorded_price = xyprice;
      is_tracking    = true;
   }

   if (id == CHARTEVENT_CHART_CHANGE || id == CHARTEVENT_CUSTOM + ON_DRAG_PROCESS)
      if (recorded_price > 0) recorded_price = 0.0;
}
