//+------------------------------------------------------------------+
//|                                             Trade Manager.mq5    |
//|                                  Copyright 2026, Ahmad Arju      |
//|                               https://www.mql5.com/en/users/arju |
//+------------------------------------------------------------------+
#property copyright "Ahmad Arju"
#property link      "https://www.mql5.com/en/users/arju0612_/"
#property version   "1.00"

#include <Trade\Trade.mqh>
#define PREFIX "EA_SCALPER_"

//--- Global Objects & Variables
CTrade trade;
int    atr_handle;
double atr_buffer[];

//--- Arrays to store active positions and pending orders
double arr_pos_entry[];
double arr_pos_sl[];
double arr_pos_tp[];
double arr_pend_entry[];
double arr_pend_sl[];
double arr_pend_tp[];

//--- General Trading States & Inputs
double inp_risk_pct      = 0.5;
int    inp_order_mode    = 0;       // 0 = Execution (Market), 1 = Pending Order
double inp_tp_ratio      = 2.0;
double inp_pending_price = 0.0;
int    inp_preview_dir   = 0;       // 0 = Buy, 1 = Sell
bool   inp_panel_show    = true;    // Panel visibility toggle state

//--- Stop Loss Configurations (Separated for Execution and Pending modes)
int    exec_sl_mode      = 0;       // 0 = Points, 1 = ATR
double exec_point_val    = 10000.0;
double exec_atr_val      = 1.5;
int    pend_sl_mode      = 0;       // 0 = Points, 1 = ATR
double pend_point_val    = 10000.0;
double pend_atr_val      = 1.5;

//--- UI Color Palette
color clr_bg = C'16,16,22', clr_border = C'0,168,150', clr_title = C'0,210,190';
color clr_text = C'225,225,230', clr_input_bg = C'30,30,38';
color clr_btn_buy = C'41,128,185', clr_btn_sell = C'192,57,43';
color clr_btn_action = C'243,156,18', clr_btn_toggle = C'52,73,94';
color clr_btn_active = C'39,174,96';
color clr_profit = C'46,204,113', clr_loss = C'231,76,60', clr_flat = C'140,140,150';

//+------------------------------------------------------------------+
//| Helper Functions for SL Mode and Values                          |
//+------------------------------------------------------------------+
int SLMode()
  {
   return (inp_order_mode == 0) ? exec_sl_mode : pend_sl_mode;
  }

double SLValue()
  {
   if(inp_order_mode == 0)
      return (exec_sl_mode == 0) ? exec_point_val : exec_atr_val;
   else
      return (pend_sl_mode == 0) ? pend_point_val : pend_atr_val;
  }

void SetSLMode(int m)
  {
   if(inp_order_mode == 0) exec_sl_mode = m; else pend_sl_mode = m;
  }

void SetSLValue(double v)
  {
   if(inp_order_mode == 0)
     {
      if(exec_sl_mode == 0) exec_point_val = v; else exec_atr_val = v;
     }
   else
     {
      if(pend_sl_mode == 0) pend_point_val = v; else pend_atr_val = v;
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   LoadState();
   atr_handle = iATR(_Symbol, PERIOD_CURRENT, 14);
   ArraySetAsSeries(atr_buffer, true);
   
   if(inp_pending_price == 0)
      inp_pending_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
   CreateGUI();
   CreateAllLines();
   RefreshLines();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SaveState();
   ObjectsDeleteAll(0, PREFIX);
   IndicatorRelease(atr_handle);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   RefreshLines();
  }

//+------------------------------------------------------------------+
//| Trade transaction event handler                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
   if(trans.symbol == _Symbol)
     {
      if(trans.type == TRADE_TRANSACTION_ORDER_DELETE || 
         trans.type == TRADE_TRANSACTION_ORDER_UPDATE ||
         trans.type == TRADE_TRANSACTION_POSITION ||
         trans.type == TRADE_TRANSACTION_DEAL_ADD)
        {
         RefreshLines();
        }
     }
  }

//+------------------------------------------------------------------+
//| Chart event handler for UI buttons and line dragging             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam,
                  const double &dparam, const string &sparam)
  {
   // Handle button clicks
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(ObjectGetInteger(0, sparam, OBJPROP_TYPE) == OBJ_BUTTON)
        {
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
         ChartRedraw();
        }

      if(sparam == PREFIX + "BTN_TOGGLE")
        {
         inp_panel_show = !inp_panel_show;
         UpdateGUI();
         RefreshLines();
        }
      else if(sparam == PREFIX + "BTN_MODE")
        {
         inp_order_mode = (inp_order_mode == 0) ? 1 : 0;
         UpdateGUI();
         RefreshLines();
        }
      else if(sparam == PREFIX + "BTN_SLMODE")
        {
         SetSLMode((SLMode() == 0) ? 1 : 0);
         UpdateGUI();
         RefreshLines();
        }
      else if(sparam == PREFIX + "BTN_DIRECTION")
        {
         inp_preview_dir = (inp_preview_dir == 0) ? 1 : 0;
         UpdateGUI();
         RefreshLines();
        }
      else if(sparam == PREFIX + "BTN_BUY")
        {
         ExecTrade(ORDER_TYPE_BUY);
         RefreshLines();
        }
      else if(sparam == PREFIX + "BTN_SELL")
        {
         ExecTrade(ORDER_TYPE_SELL);
         RefreshLines();
        }
      else if(sparam == PREFIX + "BTN_CLOSE")
        {
         CloseAll();
         RefreshLines();
        }
      else if(sparam == PREFIX + "BTN_DELPEND")
        {
         DelPend();
         RefreshLines();
        }
     }

   // Handle text input edits
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
     {
      if(StringFind(sparam, PREFIX) < 0) return;

      if(sparam == PREFIX + "E_SLVAL")
        {
         double v = StringToDouble(ObjectGetString(0, PREFIX + "E_SLVAL", OBJPROP_TEXT));
         if(v > 0) SetSLValue(v);
        }
      else if(sparam == PREFIX + "E_RISK")
        {
         double v = StringToDouble(ObjectGetString(0, PREFIX + "E_RISK", OBJPROP_TEXT));
         if(v > 0) inp_risk_pct = v;
        }
      else if(sparam == PREFIX + "E_PENDING")
        {
         double v = StringToDouble(ObjectGetString(0, PREFIX + "E_PENDING", OBJPROP_TEXT));
         if(v > 0) inp_pending_price = v;
        }
      else if(sparam == PREFIX + "E_TPRATIO")
        {
         double v = StringToDouble(ObjectGetString(0, PREFIX + "E_TPRATIO", OBJPROP_TEXT));
         if(v > 0) inp_tp_ratio = v;
        }

      UpdateGUI();
      RefreshLines();
     }

   // Handle chart line dragging interactions
   if(id == CHARTEVENT_OBJECT_DRAG)
     {
      if(StringFind(sparam, PREFIX + "LINE_SETUP_") >= 0)
         HandleDrag(sparam);
     }
  }

//+------------------------------------------------------------------+
//| Update Floating Profit/Loss metrics on GUI                       |
//+------------------------------------------------------------------+
void UpdateFloatingPL()
  {
   double money = 0.0, points = 0.0;
   int count = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetSymbol(i) == _Symbol)
        {
         money += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);

         double open = PositionGetDouble(POSITION_PRICE_OPEN);
         long type = PositionGetInteger(POSITION_TYPE);
         double cur = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         
         points += (type == POSITION_TYPE_BUY) ? (cur - open) / _Point : (open - cur) / _Point;
         count++;
        }
     }

   color c = (money > 0) ? clr_profit : (money < 0) ? clr_loss : clr_flat;

   string cur_sym = AccountInfoString(ACCOUNT_CURRENCY);
   string money_txt = StringFormat("%s%s %.2f", (money >= 0 ? "+" : "-"), cur_sym, MathAbs(money));
   string sub_txt = StringFormat("%s%.1f pts   •   %d position", (points >= 0 ? "+" : "-"), MathAbs(points), count);

   ObjectSetString(0, PREFIX + "FPL_VALUE", OBJPROP_TEXT, money_txt);
   ObjectSetInteger(0, PREFIX + "FPL_VALUE", OBJPROP_COLOR, c);
   ObjectSetString(0, PREFIX + "FPL_PIPS", OBJPROP_TEXT, sub_txt);
   ObjectSetInteger(0, PREFIX + "FPL_PIPS", OBJPROP_COLOR, c);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_COLOR, c);
  }

//+------------------------------------------------------------------+
//| Get current ATR value                                            |
//+------------------------------------------------------------------+
double GetATR()
  {
   return (CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) > 0) ? atr_buffer[0] : 0;
  }

//+------------------------------------------------------------------+
//| Calculate Stop Loss distance in price units                      |
//+------------------------------------------------------------------+
double SLDist()
  {
   return (SLMode() == 0) ? SLValue() * _Point : SLValue() * GetATR();
  }

//+------------------------------------------------------------------+
//| Calculate preview Stop Loss and Take Profit levels               |
//+------------------------------------------------------------------+
void CalcPrev(double e, double &s, double &t)
  {
   double d = SLDist();
   if(inp_preview_dir == 0)
     {
      s = e - d;
      t = e + d * inp_tp_ratio;
     }
   else
     {
      s = e + d;
      t = e - d * inp_tp_ratio;
     }
  }

//+------------------------------------------------------------------+
//| Execute market or pending orders                                 |
//+------------------------------------------------------------------+
void ExecTrade(ENUM_ORDER_TYPE type)
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double d = SLDist(), entry, sl, tp;

   entry = (inp_order_mode == 0) ? ((type == ORDER_TYPE_BUY) ? ask : bid) : inp_pending_price;
   if(entry <= 0) entry = ask;

   if(type == ORDER_TYPE_BUY)
     {
      sl = entry - d;
      tp = entry + d * inp_tp_ratio;
     }
   else
     {
      sl = entry + d;
      tp = entry - d * inp_tp_ratio;
     }

   double lot = CalcLot(d);
   if(lot <= 0)
     {
      Alert("Lot calculation failed!");
      return;
     }

   if(inp_order_mode == 0)
     {
      if(type == ORDER_TYPE_BUY) trade.Buy(lot, _Symbol, entry, sl, tp, "B");
      else trade.Sell(lot, _Symbol, entry, sl, tp, "S");
     }
   else
     {
      if(type == ORDER_TYPE_BUY)
        {
         if(entry < ask) trade.BuyLimit(lot, entry, _Symbol, sl, tp, 0, 0, "BL");
         else trade.BuyStop(lot, entry, _Symbol, sl, tp, 0, 0, "BS");
        }
      else
        {
         if(entry > bid) trade.SellLimit(lot, entry, _Symbol, sl, tp, 0, 0, "SL");
         else trade.SellStop(lot, entry, _Symbol, sl, tp, 0, 0, "SS");
        }
     }
  }

//+------------------------------------------------------------------+
//| Calculate dynamic lot size based on account risk percentage      |
//+------------------------------------------------------------------+
double CalcLot(double d)
  {
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double vs = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vx = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   if(d <= 0 || ts <= 0) return 0;
   
   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * inp_risk_pct / 100.0;
   double loss = (d / ts) * tv;
   
   if(loss <= 0) return 0;
   
   double l = MathFloor(risk / loss / vs) * vs;
   return MathMax(vn, MathMin(vx, l));
  }

//+------------------------------------------------------------------+
//| Close all active positions for the current symbol                |
//+------------------------------------------------------------------+
void CloseAll()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetSymbol(i) == _Symbol)
         trade.PositionClose(PositionGetInteger(POSITION_TICKET));
     }
  }

//+------------------------------------------------------------------+
//| Delete all pending orders for the current symbol                 |
//+------------------------------------------------------------------+
void DelPend()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong t = OrderGetTicket(i);
      if(t > 0 && OrderGetString(ORDER_SYMBOL) == _Symbol)
         trade.OrderDelete(t);
     }
  }

//+------------------------------------------------------------------+
//| Retrieve all active positions into arrays                        |
//+------------------------------------------------------------------+
void GetAllPositions()
  {
   int total = PositionsTotal();
   ArrayResize(arr_pos_entry, total);
   ArrayResize(arr_pos_sl, total);
   ArrayResize(arr_pos_tp, total);
   
   for(int i = 0; i < total; i++)
     {
      arr_pos_entry[i] = 0;
      arr_pos_sl[i] = 0;
      arr_pos_tp[i] = 0;
     }
   
   int idx = 0;
   for(int i = 0; i < total; i++)
     {
      if(PositionGetSymbol(i) == _Symbol)
        {
         arr_pos_entry[idx] = PositionGetDouble(POSITION_PRICE_OPEN);
         arr_pos_sl[idx]    = PositionGetDouble(POSITION_SL);
         arr_pos_tp[idx]    = PositionGetDouble(POSITION_TP);
         idx++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Retrieve all pending orders into arrays                          |
//+------------------------------------------------------------------+
void GetAllPendingOrders()
  {
   int total = OrdersTotal();
   ArrayResize(arr_pend_entry, total);
   ArrayResize(arr_pend_sl, total);
   ArrayResize(arr_pend_tp, total);
   
   for(int i = 0; i < total; i++)
     {
      arr_pend_entry[i] = 0;
      arr_pend_sl[i] = 0;
      arr_pend_tp[i] = 0;
     }
   
   int idx = 0;
   for(int i = 0; i < total; i++)
     {
      ulong tk = OrderGetTicket(i);
      if(tk > 0 && OrderGetString(ORDER_SYMBOL) == _Symbol)
        {
         arr_pend_entry[idx] = OrderGetDouble(ORDER_PRICE_OPEN);
         arr_pend_sl[idx]    = OrderGetDouble(ORDER_SL);
         arr_pend_tp[idx]    = OrderGetDouble(ORDER_TP);
         idx++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Chart Lines Management Functions                                 |
//+------------------------------------------------------------------+
void CreateAllLines()
  {
   // Setup preview lines
   MkH("LINE_SETUP_ENTRY", clrYellow, STYLE_SOLID, 2, " SETUP ENTRY", false);
   MkH("LINE_SETUP_SL", clrRed, STYLE_SOLID, 1, " SETUP SL", false);      
   MkH("LINE_SETUP_TP", clrLime, STYLE_SOLID, 1, " SETUP TP", false);     
   
   for(int i = 0; i < 10; i++)
     {
      string suffix = IntegerToString(i);
      
      // Active position lines
      MkH("LINE_POS_ENTRY_" + suffix, clrCyan, STYLE_SOLID, 2, "POS ENTRY #" + suffix);
      MkH("LINE_POS_SL_" + suffix, C'255,80,80', STYLE_SOLID, 1, "POS SL #" + suffix);
      MkH("LINE_POS_TP_" + suffix, C'80,255,80', STYLE_SOLID, 3, "POS TP #" + suffix);
      
      // Pending order lines
      MkH("LINE_PEND_ENTRY_" + suffix, clrOrange, STYLE_DOT, 2, "PEND ENTRY #" + suffix);
      MkH("LINE_PEND_SL_" + suffix, C'255,140,140', STYLE_DOT, 1, "PEND SL #" + suffix);
      MkH("LINE_PEND_TP_" + suffix, C'140,255,140', STYLE_DOT, 1, "PEND TP #" + suffix);
     }
  }

void MkH(string n, color c, ENUM_LINE_STYLE s, int w, string t, bool back = true)
  {
   string f = PREFIX + n;
   if(ObjectFind(0, f) < 0) ObjectCreate(0, f, OBJ_HLINE, 0, 0, 0);
   ObjectSetInteger(0, f, OBJPROP_COLOR, c);
   ObjectSetInteger(0, f, OBJPROP_STYLE, s);
   ObjectSetInteger(0, f, OBJPROP_WIDTH, w);
   ObjectSetString(0, f, OBJPROP_TEXT, t);
   ObjectSetInteger(0, f, OBJPROP_ZORDER, 5);
   ObjectSetInteger(0, f, OBJPROP_BACK, back);
   ObjectSetInteger(0, f, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, f, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
  }

void Show(string n, double p)
  { 
   string f = PREFIX + n;
   if(ObjectFind(0, f) >= 0)
     {
      ObjectSetDouble(0, f, OBJPROP_PRICE, p);
      ObjectSetInteger(0, f, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS); 
      ObjectSetInteger(0, f, OBJPROP_HIDDEN, false);
     }
  }

void Hide(string n)
  {
   string f = PREFIX + n;
   if(ObjectFind(0, f) >= 0)
     {
      ObjectSetDouble(0, f, OBJPROP_PRICE, 0.0);
      ObjectSetInteger(0, f, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      ObjectSetInteger(0, f, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, f, OBJPROP_HIDDEN, true);
     }
  }

bool IsBeingDragged(string n)
  {
   string f = PREFIX + n;
   return (ObjectFind(0, f) >= 0 && ObjectGetInteger(0, f, OBJPROP_SELECTED) == 1);
  }

void RefreshLines()
  {
   // 1. Preview Lines (Setup) - Hide if panel is minimized
   double pe;
   if(inp_order_mode == 0)
      pe = (inp_preview_dir == 0) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   else
     {
      pe = inp_pending_price;
      if(pe <= 0) pe = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
     }

   double ps, pt;
   CalcPrev(pe, ps, pt);

   if(inp_panel_show)
     {
      if(!IsBeingDragged("LINE_SETUP_ENTRY")) Show("LINE_SETUP_ENTRY", pe);
      if(!IsBeingDragged("LINE_SETUP_SL")) Show("LINE_SETUP_SL", ps);
      if(!IsBeingDragged("LINE_SETUP_TP")) Show("LINE_SETUP_TP", pt);

      ObjectSetInteger(0, PREFIX + "LINE_SETUP_ENTRY", OBJPROP_SELECTABLE, (inp_order_mode == 1));
      ObjectSetInteger(0, PREFIX + "LINE_SETUP_SL", OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, PREFIX + "LINE_SETUP_TP", OBJPROP_SELECTABLE, true);
     }
   else
     {
      Hide("LINE_SETUP_ENTRY");
      Hide("LINE_SETUP_SL");
      Hide("LINE_SETUP_TP");
     }

   // 2. Fetch Active Positions and Pending Orders Data
   GetAllPositions();
   GetAllPendingOrders();
   
   int pos_count = ArraySize(arr_pos_entry);
   int pend_count = ArraySize(arr_pend_entry);

   // 3. Render Active Position Lines
   for(int i = 0; i < 10; i++)
     {
      string sfx = IntegerToString(i);
      bool has_data = false;
      
      if(i < pos_count && arr_pos_entry[i] > 0) 
        {
         Show("LINE_POS_ENTRY_" + sfx, arr_pos_entry[i]);
         if(arr_pos_sl[i] > 0) Show("LINE_POS_SL_" + sfx, arr_pos_sl[i]); 
         else Hide("LINE_POS_SL_" + sfx);
         
         if(arr_pos_tp[i] > 0) Show("LINE_POS_TP_" + sfx, arr_pos_tp[i]); 
         else Hide("LINE_POS_TP_" + sfx);
         has_data = true;
        }
      if(!has_data)
        {
         Hide("LINE_POS_ENTRY_" + sfx);
         Hide("LINE_POS_SL_" + sfx);
         Hide("LINE_POS_TP_" + sfx);
        }
     }

   // 4. Render Pending Order Lines
   for(int i = 0; i < 10; i++)
     {
      string sfx = IntegerToString(i);
      bool has_data = false;
      
      if(i < pend_count && arr_pend_entry[i] > 0)
        {
         Show("LINE_PEND_ENTRY_" + sfx, arr_pend_entry[i]);
         if(arr_pend_sl[i] > 0) Show("LINE_PEND_SL_" + sfx, arr_pend_sl[i]); 
         else Hide("LINE_PEND_SL_" + sfx);
         
         if(arr_pend_tp[i] > 0) Show("LINE_PEND_TP_" + sfx, arr_pend_tp[i]); 
         else Hide("LINE_PEND_TP_" + sfx);
         has_data = true;
        }
      if(!has_data)
        {
         Hide("LINE_PEND_ENTRY_" + sfx);
         Hide("LINE_PEND_SL_" + sfx);
         Hide("LINE_PEND_TP_" + sfx);
        }
     }

   UpdateFloatingPL();
   ChartRedraw();
  }

void HandleDrag(string obj)
  {
   double ep = ObjectGetDouble(0, PREFIX + "LINE_SETUP_ENTRY", OBJPROP_PRICE);
   double sp = ObjectGetDouble(0, PREFIX + "LINE_SETUP_SL", OBJPROP_PRICE);
   double tp = ObjectGetDouble(0, PREFIX + "LINE_SETUP_TP", OBJPROP_PRICE);

   if(obj == PREFIX + "LINE_SETUP_ENTRY" && inp_order_mode == 1)
      inp_pending_price = ep;
   else if(obj == PREFIX + "LINE_SETUP_SL")
     {
      double dtp = MathAbs(tp - ep);  
      double dist = MathAbs(ep - sp); 
      
      if(SLMode() == 0) SetSLValue(NormalizeDouble(dist / _Point, 0));
      else
        {
         double a = GetATR();
         if(a > 0) SetSLValue(NormalizeDouble(dist / a, 2));
        }

      if(dist > 0) inp_tp_ratio = NormalizeDouble(dtp / dist, 2);
     }
   else if(obj == PREFIX + "LINE_SETUP_TP")
     {
      double dtp = MathAbs(tp - ep), dsl = SLDist();
      if(dsl > 0) inp_tp_ratio = NormalizeDouble(dtp / dsl, 2);
     }

   ObjectSetInteger(0, obj, OBJPROP_SELECTED, false);
   UpdateGUI();
   RefreshLines();
  }

//+------------------------------------------------------------------+
//| State Management (Global Variables)                              |
//+------------------------------------------------------------------+
string GN(string k)
  {
   return PREFIX + _Symbol + "_" + k;
  }

void SaveState()
  {
   GlobalVariableSet(GN("Risk"), inp_risk_pct);
   GlobalVariableSet(GN("Mode"), inp_order_mode);
   GlobalVariableSet(GN("TPR"), inp_tp_ratio);
   GlobalVariableSet(GN("Pend"), inp_pending_price);
   GlobalVariableSet(GN("Dir"), inp_preview_dir);
   GlobalVariableSet(GN("ExSLM"), exec_sl_mode);
   GlobalVariableSet(GN("ExPV"), exec_point_val);
   GlobalVariableSet(GN("ExAV"), exec_atr_val);
   GlobalVariableSet(GN("PeSLM"), pend_sl_mode);
   GlobalVariableSet(GN("PePV"), pend_point_val);
   GlobalVariableSet(GN("PeAV"), pend_atr_val);
   GlobalVariableSet(GN("Show"), inp_panel_show);
  }

void LoadState()
  {
   if(GlobalVariableCheck(GN("Risk"))) inp_risk_pct = GlobalVariableGet(GN("Risk"));
   if(GlobalVariableCheck(GN("Mode"))) inp_order_mode = (int)GlobalVariableGet(GN("Mode"));
   if(GlobalVariableCheck(GN("TPR")))  inp_tp_ratio = GlobalVariableGet(GN("TPR"));
   if(GlobalVariableCheck(GN("Pend"))) inp_pending_price = GlobalVariableGet(GN("Pend"));
   if(GlobalVariableCheck(GN("Dir")))  inp_preview_dir = (int)GlobalVariableGet(GN("Dir"));
   if(GlobalVariableCheck(GN("ExSLM"))) exec_sl_mode = (int)GlobalVariableGet(GN("ExSLM"));
   if(GlobalVariableCheck(GN("ExPV")))  exec_point_val = GlobalVariableGet(GN("ExPV"));
   if(GlobalVariableCheck(GN("ExAV")))  exec_atr_val = GlobalVariableGet(GN("ExAV"));
   if(GlobalVariableCheck(GN("PeSLM"))) pend_sl_mode = (int)GlobalVariableGet(GN("PeSLM"));
   if(GlobalVariableCheck(GN("PePV")))  pend_point_val = GlobalVariableGet(GN("PePV"));
   if(GlobalVariableCheck(GN("PeAV")))  pend_atr_val = GlobalVariableGet(GN("PeAV"));
   if(GlobalVariableCheck(GN("Show")))  inp_panel_show = (bool)GlobalVariableGet(GN("Show"));
  }

//+------------------------------------------------------------------+
//| GUI Construction and Control Functions                           |
//+------------------------------------------------------------------+
void CreateGUI()
  {
   int x = 20, y = 30, w = 230, h = 480;

   ObjectCreate(0, PREFIX + "BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_XSIZE, w);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_YSIZE, h);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_BGCOLOR, clr_bg);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_COLOR, clr_border);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_ZORDER, 0);
   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_HIDDEN, true);

   MkL("TITLE", x + w / 2, y + 8, "TRADE MANAGER", clr_title, 11, ANCHOR_UPPER);
   MkB("BTN_TOGGLE", x + w - 25, y + 6, 18, 18, "-", clr_btn_toggle);

   ObjectCreate(0, PREFIX + "SEP", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, PREFIX + "SEP", OBJPROP_XDISTANCE, x + 10);
   ObjectSetInteger(0, PREFIX + "SEP", OBJPROP_YDISTANCE, y + 32);
   ObjectSetInteger(0, PREFIX + "SEP", OBJPROP_XSIZE, w - 20);
   ObjectSetInteger(0, PREFIX + "SEP", OBJPROP_YSIZE, 1);
   ObjectSetInteger(0, PREFIX + "SEP", OBJPROP_BGCOLOR, clr_border);
   ObjectSetInteger(0, PREFIX + "SEP", OBJPROP_COLOR, clr_border);
   ObjectSetInteger(0, PREFIX + "SEP", OBJPROP_ZORDER, 10);
   ObjectSetInteger(0, PREFIX + "SEP", OBJPROP_HIDDEN, true);

   int s = 35, cy = y + 45;
   MkL("L_RISK", x + 10, cy, "Risk (%)", clr_text);
   MkE("E_RISK", x + 120, cy - 2, 95, 20, "");
   
   cy += s; MkB("BTN_MODE", x + 10, cy, 210, 25, "", clr_btn_active);
   
   cy += s;
   MkL("L_PENDING", x + 10, cy, "Entry Price", clr_text);
   MkE("E_PENDING", x + 120, cy - 2, 95, 20, "");
   
   cy += s; MkB("BTN_SLMODE", x + 10, cy, 210, 25, "", clr_btn_active);
   
   cy += s;
   MkL("L_SLVAL", x + 10, cy, "SL Value", clr_text);
   MkE("E_SLVAL", x + 120, cy - 2, 95, 20, "");
   
   cy += s;
   MkL("L_TPRATIO", x + 10, cy, "TP Ratio", clr_text);
   MkE("E_TPRATIO", x + 120, cy - 2, 95, 20, "");
   
   cy += s; MkB("BTN_DIRECTION", x + 10, cy, 210, 25, "", clr_btn_buy);
   
   cy += s + 10;
   MkB("BTN_BUY", x + 10, cy, 100, 35, "BUY", clr_btn_buy);
   MkB("BTN_SELL", x + 120, cy, 100, 35, "SELL", clr_btn_sell);
   
   cy += 42;
   MkB("BTN_CLOSE", x + 10, cy, 100, 25, "Close All", clr_btn_toggle);
   MkB("BTN_DELPEND", x + 120, cy, 100, 25, "Del Pend", clr_btn_toggle);

   int fpl_y = cy + 38;

   ObjectCreate(0, PREFIX + "FPL_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_XDISTANCE, x + 10);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_YDISTANCE, fpl_y);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_XSIZE, w - 20);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_YSIZE, 82);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_BGCOLOR, C'22,22,30');
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_COLOR, clr_flat);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_ZORDER, 1);
   ObjectSetInteger(0, PREFIX + "FPL_BG", OBJPROP_HIDDEN, true);

   MkL("FPL_TITLE", x + w / 2, fpl_y + 8, "FLOATING P/L", C'120,120,135', 8, ANCHOR_UPPER);
   MkL("FPL_VALUE", x + w / 2, fpl_y + 26, "+$0.00", clr_flat, 17, ANCHOR_UPPER);
   MkL("FPL_PIPS", x + w / 2, fpl_y + 58, "+0.0 pts   •   0 position", clr_flat, 8, ANCHOR_UPPER);

   UpdateGUI();
  }

void MkL(string n, int x, int y, string t, color c, int fs = 9, ENUM_ANCHOR_POINT a = ANCHOR_LEFT_UPPER)
  {
   ObjectCreate(0, PREFIX + n, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_ANCHOR, a);
   ObjectSetString(0, PREFIX + n, OBJPROP_TEXT, t);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_COLOR, c);
   ObjectSetString(0, PREFIX + n, OBJPROP_FONT, "Trebuchet MS");
   ObjectSetInteger(0, PREFIX + n, OBJPROP_FONTSIZE, fs);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 10);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_HIDDEN, true);
  }

void MkE(string n, int x, int y, int w, int h, string t)
  {
   ObjectCreate(0, PREFIX + n, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_YSIZE, h);
   ObjectSetString(0, PREFIX + n, OBJPROP_TEXT, t);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_BGCOLOR, clr_input_bg);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_BORDER_COLOR, clr_border);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 10);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_READONLY, false);
  }

void MkB(string n, int x, int y, int w, int h, string t, color bg)
  {
   ObjectCreate(0, PREFIX + n, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_YSIZE, h);
   ObjectSetString(0, PREFIX + n, OBJPROP_TEXT, t);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_COLOR, clrWhite);
   ObjectSetString(0, PREFIX + n, OBJPROP_FONT, "Trebuchet MS");
   ObjectSetInteger(0, PREFIX + n, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_ZORDER, 10);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, PREFIX + n, OBJPROP_STATE, false);
  }

void UpdateGUI()
  {
   long tf = inp_panel_show ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS;
   string items[] = {
      "SEP", "L_RISK", "E_RISK", "BTN_MODE", "L_PENDING", "E_PENDING",
      "BTN_SLMODE", "L_SLVAL", "E_SLVAL", "L_TPRATIO", "E_TPRATIO",
      "BTN_DIRECTION", "BTN_BUY", "BTN_SELL", "BTN_CLOSE", "BTN_DELPEND",
      "FPL_BG", "FPL_TITLE", "FPL_VALUE", "FPL_PIPS"
   };

   for(int i = 0; i < ArraySize(items); i++)
      ObjectSetInteger(0, PREFIX + items[i], OBJPROP_TIMEFRAMES, tf);

   ObjectSetInteger(0, PREFIX + "BG", OBJPROP_YSIZE, inp_panel_show ? 480 : 32);
   ObjectSetString(0, PREFIX + "BTN_TOGGLE", OBJPROP_TEXT, inp_panel_show ? "-" : "+");

   ObjectSetString(0, PREFIX + "E_RISK", OBJPROP_TEXT, DoubleToString(inp_risk_pct, 2));
   ObjectSetString(0, PREFIX + "E_PENDING", OBJPROP_TEXT, DoubleToString(inp_pending_price, _Digits));
   ObjectSetString(0, PREFIX + "E_SLVAL", OBJPROP_TEXT, DoubleToString(SLValue(), 2));
   ObjectSetString(0, PREFIX + "E_TPRATIO", OBJPROP_TEXT, DoubleToString(inp_tp_ratio, 2));

   ObjectSetString(0, PREFIX + "BTN_MODE", OBJPROP_TEXT, inp_order_mode == 0 ? "Mode: EXECUTION" : "Mode: PENDING");
   ObjectSetInteger(0, PREFIX + "BTN_MODE", OBJPROP_BGCOLOR, inp_order_mode == 0 ? clr_btn_active : clr_btn_action);

   ObjectSetString(0, PREFIX + "BTN_SLMODE", OBJPROP_TEXT, SLMode() == 0 ? "SL Mode: POINT" : "SL Mode: ATR");
   ObjectSetInteger(0, PREFIX + "BTN_SLMODE", OBJPROP_BGCOLOR, SLMode() == 0 ? clr_btn_active : clr_btn_action);

   ObjectSetString(0, PREFIX + "L_SLVAL", OBJPROP_TEXT, SLMode() == 0 ? "Point Value" : "ATR Multiplier");

   ObjectSetString(0, PREFIX + "BTN_DIRECTION", OBJPROP_TEXT, inp_preview_dir == 0 ? "Preview: BUY" : "Preview: SELL");
   ObjectSetInteger(0, PREFIX + "BTN_DIRECTION", OBJPROP_BGCOLOR, inp_preview_dir == 0 ? clr_btn_buy : clr_btn_sell);

   ObjectSetInteger(0, PREFIX + "E_PENDING", OBJPROP_READONLY, false);
   ObjectSetInteger(0, PREFIX + "E_PENDING", OBJPROP_BGCOLOR, clr_input_bg);

   ChartRedraw();
  }
//+------------------------------------------------------------------+