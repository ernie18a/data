//+------------------------------------------------------------------+
//|                                      HistorySelectByPosition.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property script_show_inputs
//---
input long position_id=0;                    // идентификатор позиции - POSITION_IDENTIFIER 
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- request trade history 
   if(!HistorySelectByPosition(position_id))
     {
      Print("Error HistorySelectByPosition");
      return;
     }
   uint     total=HistoryDealsTotal();
//--- for all deals 
   for(uint i=0;i<total;i++)
     {
      ulong deal_ticket          = HistoryDealGetTicket(i);
      double volume              = HistoryDealGetDouble(deal_ticket,DEAL_VOLUME);
      datetime transaction_time  = (datetime)HistoryDealGetInteger(deal_ticket,DEAL_TIME);
      ulong order_ticket         = HistoryDealGetInteger(deal_ticket,DEAL_ORDER);
      long deal_type             = HistoryDealGetInteger(deal_ticket,DEAL_TYPE);
      long deal_entry            = HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
      string symbol              = HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
      long position_ID           = HistoryDealGetInteger(deal_ticket,DEAL_POSITION_ID);
      string deal_description    = GetDealDescription(deal_entry,deal_type,volume,symbol,order_ticket,position_ID);
      //--- сделаем красивое форматирование для номера сделки 
      string print_index=StringFormat("% 3d",i);
      //--- выведем информацию по сделке 
      Print(print_index+": deal #",deal_ticket," at ",transaction_time," ",deal_description);
     }
  }
//+------------------------------------------------------------------+ 
//| Возвращает строковое описание операции                           | 
//+------------------------------------------------------------------+ 
string GetDealDescription(long deal_entry,long deal_type,double volume,string symbol,long ticket,long pos_ID)
  {
   string descr;
//---
   switch((int)deal_entry)
     {
      case DEAL_ENTRY_IN:     descr="Вход в рынок, "; break;
      case DEAL_ENTRY_OUT:    descr="Выход из рынка, "; break;
      case DEAL_ENTRY_INOUT:  descr="Разворот, "; break;
      case DEAL_ENTRY_OUT_BY: descr="Закрытие встречной позицией, "; break;
     }
//--- 
   switch((int)deal_type)
     {
      case DEAL_TYPE_BALANCE:                  return ("balance");
      case DEAL_TYPE_CREDIT:                   return ("credit");
      case DEAL_TYPE_CHARGE:                   return ("charge");
      case DEAL_TYPE_CORRECTION:               return ("correction");
      case DEAL_TYPE_BUY:                      descr+="buy"; break;
      case DEAL_TYPE_SELL:                     descr+="sell"; break;
      case DEAL_TYPE_BONUS:                    return ("bonus");
      case DEAL_TYPE_COMMISSION:               return ("additional commission");
      case DEAL_TYPE_COMMISSION_DAILY:         return ("daily commission");
      case DEAL_TYPE_COMMISSION_MONTHLY:       return ("monthly commission");
      case DEAL_TYPE_COMMISSION_AGENT_DAILY:   return ("daily agent commission");
      case DEAL_TYPE_COMMISSION_AGENT_MONTHLY: return ("monthly agent commission");
      case DEAL_TYPE_INTEREST:                 return ("interest rate");
      case DEAL_TYPE_BUY_CANCELED:             descr+="cancelled buy deal"; break;
      case DEAL_TYPE_SELL_CANCELED:            descr+="cancelled sell deal"; break;
     }
   descr=StringFormat("%s %G %s (order #%d, position ID %d)",
                      descr,  // текущее описание 
                      volume, // объем сделки 
                      symbol, // инструмент сделки 
                      ticket, // тикет ордера,вызвавшего сделку 
                      pos_ID  // ID позиции, в которой участвовала сделка 
                      );
   return(descr);
//--- 
  }
//+------------------------------------------------------------------+
