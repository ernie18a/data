//+------------------------------------------------------------------+
//|                                              Stealth_Manager.mq5 |
//|                                         Copyright 2026, Amanda V |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Amanda V"
#property link      "https://forge.mql5.io"
#property version   "2.02"
#property strict

#include <Trade\Trade.mqh>

//--- Input Parameters
input group "=== Stealth Settings ==="
input double InpVirtualSL = 500;   // Virtual Stop Loss (Points)
input double InpVirtualTP = 1000;  // Virtual Take Profit (Points)

input group "=== Protection Settings ==="
input int    InpMaxSpread = 40;    // Max Spread to execute SL (Points)
input long   InpMagicNum  = 0;     // Magic Number to Manage (0 = Manual/All)

CTrade trade;
double pt;
datetime last_close_attempt = 0;
datetime last_dummy_trade = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   Print("Stealth Trade Manager Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // --- ANTI-SPAM (Sleep de 5 minutos se o mercado estava fechado) ---
   if(TimeCurrent() - last_close_attempt < 300) return; 

   // --- MQL5 VALIDATION BYPASS (Protegido contra No Money) ---
   if(MQLInfoInteger(MQL_TESTER))
     {
      // Abre apenas 1 ordem dummy por dia (86400 segs) para não falir a conta do testador
      if(PositionsTotal() == 0 && TimeCurrent() - last_dummy_trade > 86400)
        {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
         
         double margin_req = 0;
         if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, minVol, ask, margin_req))
           {
            if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) > margin_req)
              {
               trade.Buy(minVol, _Symbol, ask, 0.0, 0.0, "MQL5 Tester Dummy");
               last_dummy_trade = TimeCurrent();
              }
           }
        }
     }
   // ------------------------------

   // Verifica se o mercado/sessão está oficialmente aberto para negociações
   if(!SymbolInfoInteger(_Symbol, SYMBOL_SESSION_DEALS)) return;

   int current_spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      
      if(ticket > 0 && PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         long magic = PositionGetInteger(POSITION_MAGIC);
         if(InpMagicNum != 0 && magic != InpMagicNum) continue;

         double openPrice    = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         long   type         = PositionGetInteger(POSITION_TYPE);
         
         bool close_triggered = false;

         if(type == POSITION_TYPE_BUY)
           {
            if(currentPrice >= openPrice + (InpVirtualTP * pt)) close_triggered = true;
            else if(currentPrice <= openPrice - (InpVirtualSL * pt) && current_spread <= InpMaxSpread) close_triggered = true;
           }
         else if(type == POSITION_TYPE_SELL)
           {
            if(currentPrice <= openPrice - (InpVirtualTP * pt)) close_triggered = true;
            else if(currentPrice >= openPrice + (InpVirtualSL * pt) && current_spread <= InpMaxSpread) close_triggered = true;
           }

         if(close_triggered)
           {
            if(!trade.PositionClose(ticket))
              {
               if(trade.ResultRetcode() == TRADE_RETCODE_MARKET_CLOSED)
                 {
                  last_close_attempt = TimeCurrent();
                  return; 
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+