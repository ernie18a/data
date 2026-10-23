//+------------------------------------------------------------------+
//|                                          PrintClosedPosition.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "3.000"
#property description "The script prints info about a closed position by its position ticket or identifier, on a retail hedging account."
#property script_show_inputs

#include <Trade\DealInfo.mqh>

//--- input variables
input long InpPositionTicket=12345;  // Position ticket or identifier
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- account margin mode
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Alert("Error: no retail hedging account (Forex)!");
      return;
     }
//---
   PrintClosedPosition(InpPositionTicket);
  }
//+------------------------------------------------------------------+
//| Print info of a closed position by its pos_ticket or pos_id.     |
//+------------------------------------------------------------------+
bool PrintClosedPosition(long position_ticket)
  {
//--- request the history of deals and orders for the specified position
   if(!HistorySelectByPosition(position_ticket))
     {
      Print(__FUNCTION__+" > Error: failed to select position ticket #",position_ticket,". Error Code: ", GetLastError());
      return(false);
     }
//---
   CDealInfo deal;
   string    pos_symbol=NULL;
   long      pos_id=-1;
   long      pos_type=-1;
   long      pos_magic=-1;
   double    pos_open_price=0;
   double    pos_close_price=0;
   double    pos_sl = 0;
   double    pos_tp = 0;
   double    pos_commission = 0;
   double    pos_swap=0;
   double    pos_profit=0;
   double    pos_open_volume= 0;
   double    pos_close_volume=0;
   datetime  pos_open_time=0;
   datetime  pos_close_time=0;
   double    pos_sum_cost=0;
   long      pos_open_reason=-1;
   long      pos_close_reason=-1;
   string    pos_open_comment = NULL;
   string    pos_close_comment = NULL;
   string    pos_deal_in = NULL;
   string    pos_deal_out=NULL;

//--- now process the list of received deals for the specified position
   int deals=HistoryDealsTotal();
   for(int i=0; i<deals && !IsStopped(); i++)
     {
      if(!deal.SelectByIndex(i))
        {
         Print(__FUNCTION__+" > Error: failed to select deal at index #", i);
         return(false);
        }
      //---
      pos_id              = deal.PositionId();
      pos_symbol          = deal.Symbol();
      pos_commission     += deal.Commission();
      pos_swap           += deal.Swap();
      pos_profit         += deal.Profit();
      //--- Entry deal for position
      if(deal.Entry()==DEAL_ENTRY_IN)
        {
         pos_magic           = deal.Magic();
         pos_type            = deal.DealType();
         pos_open_time       = deal.Time();
         pos_open_price      = deal.Price();
         pos_open_volume     = deal.Volume();
         //---
         pos_open_comment    = deal.Comment();
         pos_deal_in         = IntegerToString(deal.Ticket());
         pos_open_reason     = HistoryDealGetInteger(deal.Ticket(), DEAL_REASON);
        }
      //--- Exit deal(s) for position
      else if(deal.Entry()==DEAL_ENTRY_OUT || deal.Entry()==DEAL_ENTRY_OUT_BY)
        {
         pos_close_time      = deal.Time();
         pos_sum_cost       += deal.Volume() * deal.Price();
         pos_close_volume   += deal.Volume();
         pos_close_price     = pos_sum_cost / pos_close_volume;
         pos_sl              = HistoryDealGetDouble(deal.Ticket(), DEAL_SL);
         pos_tp              = HistoryDealGetDouble(deal.Ticket(), DEAL_TP);
         //---
         pos_close_comment  += deal.Comment() + " ";
         pos_deal_out       += IntegerToString(deal.Ticket()) + " ";
         pos_close_reason    = HistoryDealGetInteger(deal.Ticket(), DEAL_REASON);
        }
     }
//--- If the position is still open, it will not be displayed in the history.
   if(deals<2 || MathAbs(pos_open_volume-pos_close_volume)>0.00001)
     {
      Print(__FUNCTION__+" > Error: position with ticket #",position_ticket," is still open.");
      return(false);
     }
//---
   StringTrimLeft(pos_close_comment);
   StringTrimRight(pos_close_comment);
   StringTrimRight(pos_deal_out);
//---
   SymbolSelect(pos_symbol,true);
   int digits=(int)SymbolInfoInteger(pos_symbol,SYMBOL_DIGITS);
   double point=SymbolInfoDouble(pos_symbol,SYMBOL_POINT);
//---
   string acc_curr=AccountInfoString(ACCOUNT_CURRENCY);
//---
   Print("Position Open Time: ", (string)pos_open_time);
   Print("Position Symbol: ",        pos_symbol);
   Print("Position Ticket: ",        pos_id);
   Print("Position Type: ",          EnumToString((ENUM_POSITION_TYPE)pos_type));
   Print("Position Volume: ",        DoubleToString(pos_open_volume,2));
   Print("Position Open Price: ",    DoubleToString(pos_open_price,digits));
   Print("Position S/L: ", (pos_sl ? DoubleToString(pos_sl,digits) : ""));
   Print("Position T/P: ", (pos_tp ? DoubleToString(pos_tp,digits) : ""));
   Print("Position Close Time: ", (string)pos_close_time);
   Print("Position Close Price: ",   DoubleToString(pos_close_price,(deals==2 ? digits : digits+3)));
   Print("Position Commission: ",    DoubleToString(pos_commission,2), " ", acc_curr);
   Print("Position Swap: ",          DoubleToString(pos_swap,2), " ", acc_curr);
   Print("Position Profit: ",        DoubleToString(pos_profit,2), " ", acc_curr);
   Print("Position Profit Points: ", (int)MathRound((pos_type == DEAL_TYPE_BUY ? pos_close_price - pos_open_price : pos_open_price - pos_close_price) / point));
   Print("Position Net Profit: ",    DoubleToString(pos_profit + pos_swap + pos_commission,2), " ", acc_curr);
   Print("Position Magic Number: ",  pos_magic);
   Print("Position Open Reason: ",   EnumToString((ENUM_DEAL_REASON)pos_open_reason));
   Print("Position Close Reason: ",  EnumToString((ENUM_DEAL_REASON)pos_close_reason));
   Print("Position Open Comment: ",  pos_open_comment);
   Print("Position Close Comment: ", pos_close_comment);
   Print("Position Deal In Ticket: ",pos_deal_in);
   Print("Position Deal Out Ticket(s): ",  pos_deal_out);
//---
   return(true);
  }
//+------------------------------------------------------------------+
