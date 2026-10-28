//+------------------------------------------------------------------+
//|                                               Opposite trade.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "Opposite trade on any symbol and on any magic"
//---
#include <Trade\Trade.mqh>
CTrade         m_trade;                      // trading object
//---
ulong          m_slippage=30;                // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_type         =-1;
      long     deal_entry        =-1;
      double   deal_volume       =0.0;
      string   deal_symbol       ="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_type         =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
        }
      else
         return;
      if(deal_entry==DEAL_ENTRY_OUT)
        {
         switch((int)deal_type)
           {
            case  DEAL_TYPE_BUY:
               m_trade.Buy(deal_volume,deal_symbol);
               break;
            case  DEAL_TYPE_SELL:
               m_trade.Sell(deal_volume,deal_symbol);
               break;
            default:
               break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
