//+------------------------------------------------------------------+
//|                                               Grid_Master_EA.mq5 |
//|                                         Copyright 2025, Fox Wave |
//|                                   https://www.foxwavetrading.top |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Fox Wave"
#property link      "https://www.foxwavetrading.top"
#property version   "2.40"
#property strict

#include <Trade\Trade.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

CTrade trade;

//================ INPUTS =================
input group "=== LOT MANAGEMENT ==="
input bool   Use_Fixed_Lot     = false;
input double Fixed_Lot         = 0.01;
input double Max_Risk_Percent  = 2.0;

input group "=== GRID SETTINGS ==="
input double Grid_Step         = 1000;
input double Distance          = 500;
input ushort Numb_Orders       = 5;
input bool   Type_Limit        = false;
input double Take_Profit       = 1000;
input ulong  Magic_Number      = 123456;

input group "=== STOP LOSS PROTECTION ==="
input bool   Enable_StopLoss   = true;
input double StopLoss_Points   = 500;

input group "=== TRAILING & BREAKEVEN ==="
input bool   Enable_Trailing   = false;
input double Trail_Start       = 500;
input double Trail_Step        = 200;
input bool   Enable_Breakeven  = false;
input double Breakeven_Profit  = 300;
input double Breakeven_Offset  = 50;

input group "=== START SETTINGS ==="
input bool   Market_Start      = true;
input bool   Start_Buy         = true;

//================ GLOBALS =================
bool grid_placed=false;
bool market_done=false;
datetime last_tick=0;
bool trading_enabled=false;

// Button names
#define BTN_CLOSE_ORDERS "btn_close_orders"
#define BTN_CLOSE_BUY "btn_close_buy"
#define BTN_CLOSE_SELL "btn_close_sell"
#define BTN_CLOSE_ALL "btn_close_all"
#define BTN_TRADING "btn_trading"
#define PANEL_BG "panel_bg"
#define PANEL_TITLE "panel_title"

//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(Magic_Number);
   trade.SetDeviationInPoints(50);
   trade.SetTypeFillingBySymbol(_Symbol);
   
   CreateControlPanel();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteControlPanel();
}

//+------------------------------------------------------------------+
void OnTick()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return;
   if(tick.time==last_tick) return;
   last_tick=tick.time;
   
   UpdateTradingButton();
   
   if(!IsTradeAllowed() || !trading_enabled) return;
   
   if(Market_Start && !market_done)
   {
      if(OpenMarketStart()) 
         market_done=true;
      else 
         return;
   }
   
   if(!grid_placed)
   {
      if(PlaceGrid()) 
         grid_placed=true;
   }
   
   if(Enable_Trailing || Enable_Breakeven)
      ManagePositions();
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam==BTN_CLOSE_ORDERS)
      {
         if(MessageBox("Close all pending orders?","Confirm",MB_YESNO|MB_ICONQUESTION)==IDYES)
         {
            CloseOrders();
            ObjectSetInteger(0,BTN_CLOSE_ORDERS,OBJPROP_STATE,false);
         }
      }
      else if(sparam==BTN_CLOSE_BUY)
      {
         if(MessageBox("Close all BUY positions?","Confirm",MB_YESNO|MB_ICONQUESTION)==IDYES)
         {
            ClosePositions(POSITION_TYPE_BUY);
            ObjectSetInteger(0,BTN_CLOSE_BUY,OBJPROP_STATE,false);
         }
      }
      else if(sparam==BTN_CLOSE_SELL)
      {
         if(MessageBox("Close all SELL positions?","Confirm",MB_YESNO|MB_ICONQUESTION)==IDYES)
         {
            ClosePositions(POSITION_TYPE_SELL);
            ObjectSetInteger(0,BTN_CLOSE_SELL,OBJPROP_STATE,false);
         }
      }
      else if(sparam==BTN_CLOSE_ALL)
      {
         if(MessageBox("Close ALL positions and orders?","Confirm",MB_YESNO|MB_ICONQUESTION)==IDYES)
         {
            CloseOrders();
            ClosePositions(POSITION_TYPE_BUY);
            ClosePositions(POSITION_TYPE_SELL);
            ObjectSetInteger(0,BTN_CLOSE_ALL,OBJPROP_STATE,false);
         }
      }
      else if(sparam==BTN_TRADING)
      {
         trading_enabled=!trading_enabled;
         UpdateTradingButton();
         ObjectSetInteger(0,BTN_TRADING,OBJPROP_STATE,false);
      }
      
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
void CreateControlPanel()
{
   int x=10, y=30;
   int width=150, height=30;
   int spacing=35;
   
   // Background panel
   ObjectCreate(0,PANEL_BG,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_XDISTANCE,x-5);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_YDISTANCE,y-25);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_XSIZE,width+10);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_YSIZE,spacing*5+35);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_COLOR,clrDodgerBlue);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,PANEL_BG,OBJPROP_BACK,false);
   
   // Title
   ObjectCreate(0,PANEL_TITLE,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,PANEL_TITLE,OBJPROP_XDISTANCE,x+20);
   ObjectSetInteger(0,PANEL_TITLE,OBJPROP_YDISTANCE,y-20);
   ObjectSetInteger(0,PANEL_TITLE,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,PANEL_TITLE,OBJPROP_COLOR,clrDodgerBlue);
   ObjectSetInteger(0,PANEL_TITLE,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,PANEL_TITLE,OBJPROP_FONT,"Arial Bold");
   ObjectSetString(0,PANEL_TITLE,OBJPROP_TEXT,"Fox Wave Grid");
   
   // Close Orders button
   CreateButton(BTN_CLOSE_ORDERS,"Close Orders",x,y,width,height,clrOrangeRed);
   y+=spacing;
   
   // Close Buy button
   CreateButton(BTN_CLOSE_BUY,"Close Buy",x,y,width,height,clrDodgerBlue);
   y+=spacing;
   
   // Close Sell button
   CreateButton(BTN_CLOSE_SELL,"Close Sell",x,y,width,height,clrTomato);
   y+=spacing;
   
   // Close All button
   CreateButton(BTN_CLOSE_ALL,"Close All",x,y,width,height,clrCrimson);
   y+=spacing;
   
   // Trading Enable/Disable button
   CreateButton(BTN_TRADING,"Trading: ON",x,y,width,height,clrLimeGreen);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
void CreateButton(string name,string text,int x,int y,int width,int height,color clr)
{
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrWhite);
}

//+------------------------------------------------------------------+
void DeleteControlPanel()
{
   ObjectDelete(0,PANEL_BG);
   ObjectDelete(0,PANEL_TITLE);
   ObjectDelete(0,BTN_CLOSE_ORDERS);
   ObjectDelete(0,BTN_CLOSE_BUY);
   ObjectDelete(0,BTN_CLOSE_SELL);
   ObjectDelete(0,BTN_CLOSE_ALL);
   ObjectDelete(0,BTN_TRADING);
}

//+------------------------------------------------------------------+
void UpdateTradingButton()
{
   string text=trading_enabled?"Trading: ON":"Trading: OFF";
   color clr=trading_enabled?clrLimeGreen:clrGray;
   ObjectSetString(0,BTN_TRADING,OBJPROP_TEXT,text);
   ObjectSetInteger(0,BTN_TRADING,OBJPROP_BGCOLOR,clr);
}

//+------------------------------------------------------------------+
void CloseOrders()
{
   int total=OrdersTotal();
   for(int i=total-1;i>=0;i--)
   {
      ulong ticket=OrderGetTicket(i);
      if(OrderGetInteger(ORDER_MAGIC)==Magic_Number)
         trade.OrderDelete(ticket);
   }
}

//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE type)
{
   int total=PositionsTotal();
   for(int i=total-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=Magic_Number) continue;
      if(PositionGetInteger(POSITION_TYPE)==type)
         trade.PositionClose(ticket);
   }
}

//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) return false;
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) return false;
   if(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_FULL) return false;
   return true;
}

//+------------------------------------------------------------------+
double CalcLot()
{
   if(Use_Fixed_Lot)
   {
      double minLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
      double maxLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
      double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
      double lot=Fixed_Lot;
      lot=MathMax(lot,minLot);
      lot=MathMin(lot,maxLot);
      return NormalizeDouble(lot/step,0)*step;
   }
   
   double freeMargin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double riskMoney = freeMargin * Max_Risk_Percent / 100.0;
   double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double margin1lot;
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,1.0,price,margin1lot))
      return 0;
   
   double lot=riskMoney/margin1lot;
   double minLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   lot=MathMax(lot,minLot);
   lot=MathMin(lot,maxLot);
   
   return NormalizeDouble(lot/step,0)*step;
}

//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
{
   MqlTick tick;
   if(!SymbolInfoTick(symb,tick)) return false;
   
   double price = (type==ORDER_TYPE_SELL || type==ORDER_TYPE_SELL_LIMIT || type==ORDER_TYPE_SELL_STOP) 
                  ? tick.bid : tick.ask;
   
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(!OrderCalcMargin(type,symb,lots,price,margin))
   {
      Print("OrderCalcMargin failed ",GetLastError());
      return false;
   }
   
   if(margin>free_margin)
   {
      Print("Not enough money: need ",margin, " free ",free_margin, 
            " ",EnumToString(type)," ",lots," ",symb);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
bool OpenMarketStart()
{
   double lot=CalcLot();
   if(lot<=0) return false;
   
   double sl_price = 0;
   
   if(Enable_StopLoss)
   {
      double price = Start_Buy ? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID);
      
      if(Start_Buy)
         sl_price = NormalizeDouble(price - StopLoss_Points * _Point, _Digits);
      else
         sl_price = NormalizeDouble(price + StopLoss_Points * _Point, _Digits);
   }
   
   if(Start_Buy)
   {
      if(!CheckMoneyForTrade(_Symbol,lot,ORDER_TYPE_BUY)) return false;
      return trade.Buy(lot, _Symbol, 0, sl_price, 0);
   }
   else
   {
      if(!CheckMoneyForTrade(_Symbol,lot,ORDER_TYPE_SELL)) return false;
      return trade.Sell(lot, _Symbol, 0, sl_price, 0);
   }
}

//+------------------------------------------------------------------+
bool PlaceGrid()
{
   double base_price = 0.0;
   ENUM_POSITION_TYPE base_type = POSITION_TYPE_BUY;
   bool found = false;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC) != Magic_Number) continue;
      base_price = PositionGetDouble(POSITION_PRICE_OPEN);
      base_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      found = true;
      break;
   }
   
   if(!found) return false;
   
   double lot = CalcLot();
   if(lot <= 0) return false;
   
   double point = _Point;
   
   for(int i = 1; i <= Numb_Orders; i++)
   {
      double offset = (Distance + Grid_Step * i) * point;
      double buy = base_price;
      double sell = base_price;
      
      if(base_type == POSITION_TYPE_BUY)
      {
         buy += offset;
         sell -= offset;
      }
      else
      {
         buy -= offset;
         sell += offset;
      }
      
      buy = NormalizeDouble(buy, _Digits);
      sell = NormalizeDouble(sell, _Digits);
      
      double buy_tp = NormalizeDouble(buy + Take_Profit * point, _Digits);
      double sell_tp = NormalizeDouble(sell - Take_Profit * point, _Digits);
      
      double buy_sl = 0;
      double sell_sl = 0;
      
      if(Enable_StopLoss)
      {
         buy_sl = NormalizeDouble(buy - StopLoss_Points * point, _Digits);
         sell_sl = NormalizeDouble(sell + StopLoss_Points * point, _Digits);
      }
      
      if(!Type_Limit)
      {
         if(CheckMoneyForTrade(_Symbol, lot, ORDER_TYPE_BUY_STOP))
            trade.BuyStop(lot, buy, _Symbol, buy_sl, buy_tp);
         if(CheckMoneyForTrade(_Symbol, lot, ORDER_TYPE_SELL_STOP))
            trade.SellStop(lot, sell, _Symbol, sell_sl, sell_tp);
      }
      else
      {
         if(CheckMoneyForTrade(_Symbol, lot, ORDER_TYPE_BUY_LIMIT))
            trade.BuyLimit(lot, buy, _Symbol, buy_sl, buy_tp);
         if(CheckMoneyForTrade(_Symbol, lot, ORDER_TYPE_SELL_LIMIT))
            trade.SellLimit(lot, sell, _Symbol, sell_sl, sell_tp);
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
void ManagePositions()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong t=PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=Magic_Number) continue;
      
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double open=PositionGetDouble(POSITION_PRICE_OPEN);
      double sl=PositionGetDouble(POSITION_SL);
      double tp=PositionGetDouble(POSITION_TP);
      
      double price=(type==POSITION_TYPE_BUY)? SymbolInfoDouble(_Symbol,SYMBOL_BID): SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double profit=(type==POSITION_TYPE_BUY)? (price-open)/_Point: (open-price)/_Point;
      
      double new_sl=sl;
      bool modify=false;
      
      if(Enable_Breakeven && profit>=Breakeven_Profit)
      {
         double be_sl=(type==POSITION_TYPE_BUY)? open+Breakeven_Offset*_Point: open-Breakeven_Offset*_Point;
         
         if(type==POSITION_TYPE_BUY)
         {
            if(sl==0 || be_sl>sl)
            {
               new_sl=be_sl;
               modify=true;
            }
         }
         else
         {
            if(sl==0 || be_sl<sl)
            {
               new_sl=be_sl;
               modify=true;
            }
         }
      }
      
      if(Enable_Trailing && profit>=Trail_Start)
      {
         double trail_sl=(type==POSITION_TYPE_BUY)? price-Trail_Step*_Point: price+Trail_Step*_Point;
         
         if(type==POSITION_TYPE_BUY)
         {
            if(trail_sl>new_sl || new_sl==0)
            {
               new_sl=trail_sl;
               modify=true;
            }
         }
         else
         {
            if(trail_sl<new_sl || new_sl==0)
            {
               new_sl=trail_sl;
               modify=true;
            }
         }
      }
      
      if(modify && new_sl!=sl)
      {
         trade.PositionModify(t,NormalizeDouble(new_sl,_Digits),tp);
      }
   }
}
//+------------------------------------------------------------------+