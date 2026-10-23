//+--------------------------------------------------------------------+
//|                   20/200 expert v3(barabashkakvn's edition).mq5    |
//|                                                    1H   EUR/USD    |
//|                                                    Smirnov Pavel   |
//|                                                 www.autoforex.ru   |
//| The original EA by Pavel Smirnoy, modified, with a quite proper    |
//| optimization and additional function of the automated lot size.    |
//| And lot increasing to cover losses. After modification the EA      |
//| behaviour is not bad. But is still nonproductive. One can earn     |
//| more trading mamnually. tested in reality. Works like in the       |
//| tester. Recommended for a deposit from $10000. With lower          |
//| deposite profit is too small. Only for EUR/USD on 1H chart!!!!     |
//|                                                               AntS |
//+--------------------------------------------------------------------+
#property copyright "Smirnov Pavel"
#property link      "www.autoforex.ru"
#property version   "1.001"

#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
CAccountInfo   m_account;                    // account info wrapper
CSymbolInfo    m_symbol;                     // symbol info object
CTrade         m_trade;                      // trading object
CPositionInfo  m_position;                   // trade position object

int TakeProfit_L = 39; // Take Profit in points
int StopLoss_L = 147;  // Stop Loss in points
int TakeProfit_S = 32; // Take Profit in points
int StopLoss_S = 267;  // Stop Loss in points
int TradeTime=18;      // Time (Hour) to enter the market
int t1=6;
int t2=2;
int delta_L=6;
int delta_S=21;
input double lot=0.01;  // Lot size
int max_Positions=1;    // maximal number of positions opened at a time
int MaxOpenTime=504;
int BigLotSize=6;       // By how much lot size is multiplicated in Big lot
input bool AutoLot=true;

ulong m_ticket;
int m_total,cnt;
bool cantrade=true;
double closeprice;
double m_tmp;

double ExtLot=0.0;
//+------------------------------------------------------------------+
//| Calculate Lot Size                                               |
//+------------------------------------------------------------------+
void LotSize()
// The function opens a short position with ExtLot size=volume
  {
   ExtLot=m_account.Balance()*m_symbol.LotsMin()/300;
   ExtLot=NormalizeDouble(m_symbol.LotsStep()*MathFloor(ExtLot/m_symbol.LotsStep()),2);
   if(ExtLot<m_symbol.LotsMin())
      ExtLot=m_symbol.LotsMin();
   if(ExtLot>m_symbol.LotsMax())
      ExtLot=m_symbol.LotsMax();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int globPos()
// the function calculates big lot size
  {
   double v1=GlobalVariableGet("globalPosic");
   GlobalVariableSet("globalPosic",v1+1);
   return(0);
  }
//+------------------------------------------------------------------+
//| Opens a long position with lot size=volume                       |
//+------------------------------------------------------------------+
void OpenLong(double volume=0.1)
  {
   string comment="20/200 expert v2 (Long)";

   if(GlobalVariableGet("globalBalans")>m_account.Balance()) volume=ExtLot*BigLotSize;
//  if (GlobalVariableGet("globalBalans")>AccountBalance()) if (AutoLot) LotSize();

//--- refresh rates
   if(!m_symbol.RefreshRates())
      return;
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return;

   if(m_trade.Buy(volume,Symbol(),m_symbol.Ask(),m_symbol.Ask()-StopLoss_L*Point(),
      m_symbol.Ask()+TakeProfit_L*Point(),comment))
     {
      //m_ticket=m_trade.ResultDeal();
      //Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
      //      ", description of result: ",m_trade.ResultRetcodeDescription(),
      //      ", ticket of deal: ",m_trade.ResultDeal());
     }
   else
     {
      Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription(),
            ", ticket of deal: ",m_trade.ResultDeal());
     }

   GlobalVariableSet("globalBalans",m_account.Balance());
   globPos();
//  if (GlobalVariableGet("globalPosic")>25)
//  {
   GlobalVariableSet("globalPosic",0);
   if(AutoLot)
      LotSize();
//  }
  }
//+------------------------------------------------------------------+
//| Opens a short position with lot size=volume                      |
//+------------------------------------------------------------------+
void OpenShort(double volume=0.1)
  {
   string comment="20/200 expert v2 (Short)";

   if(GlobalVariableGet("globalBalans")>m_account.Balance()) volume=ExtLot*BigLotSize;

   if(m_trade.Sell(volume,Symbol(),m_symbol.Bid(),m_symbol.Bid()+StopLoss_S*Point(),
      m_symbol.Bid()-TakeProfit_S*Point(),comment))
     {
      //m_ticket=m_trade.ResultDeal();
      //Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
      //      ", description of result: ",m_trade.ResultRetcodeDescription(),
      //      ", ticket of deal: ",m_trade.ResultDeal());
     }
   else
     {
      Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription(),
            ", ticket of deal: ",m_trade.ResultDeal());
     }

   GlobalVariableSet("globalBalans",m_account.Balance());
   globPos();
//  if (GlobalVariableGet("globalPosic")>25)
//  {
   GlobalVariableSet("globalPosic",0);
   if(AutoLot)
      LotSize();
//  }

  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_symbol.Name(Symbol());                  // sets symbol name
   m_symbol.Refresh();
   m_trade.SetDeviationInPoints(10);         // set slippage
   ExtLot=lot;
// control of a variable before using
   if(AutoLot)
      LotSize();
   if(!GlobalVariableCheck("globalBalans"))
      GlobalVariableSet("globalBalans",m_account.Balance());
   if(!GlobalVariableCheck("globalPosic"))
      GlobalVariableSet("globalPosic",0);
   return(0);
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
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(str1.hour>TradeTime)
      cantrade=true;
// check if there are open orders ...
   m_total=PositionsTotal();
   if(m_total<max_Positions)
     {
      // ... if no open positions, go further
      // check if it's time for trade
      if(str1.hour==TradeTime && cantrade)
        {
         // ... if it is
         if((iOpen(m_symbol.Name(),Period(),t1)-iOpen(m_symbol.Name(),Period(),t2))>delta_S*Point()) //if it is 
           {
            //--- refresh rates
            if(!m_symbol.RefreshRates())
               return;
            //--- protection against the return value of "zero"
            if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
               return;
            //condition is fulfilled, enter a short position:
            // check if there is free money for opening a short position
            if(!CheckMoneyForTrade(Symbol(),ExtLot,ORDER_TYPE_SELL))
               return;
            //if(AccountFreeMarginCheck(Symbol(),OP_SELL,ExtLot)<=0 || GetLastError()==134)
            //  {
            //   Print("Not enough money");
            //   return(0);
            //  }
            OpenShort(ExtLot);

            cantrade=false; //prohibit repeated trade until the next bar
            return;
           }
         if((iOpen(m_symbol.Name(),Period(),t2)-iOpen(m_symbol.Name(),Period(),t1))>delta_L*Point()) //if the price increased by delta
           {
            // condition is fulfilled, enter a long position
            // check if there is free money
            if(!CheckMoneyForTrade(Symbol(),ExtLot,ORDER_TYPE_SELL))
               return;
            //if(AccountFreeMarginCheck(Symbol(),OP_BUY,ExtLot)<=0 || GetLastError()==134)
            //  {
            //   Print("Not enough money");
            //   return(0);
            //  }
            OpenLong(ExtLot);

            cantrade=false;
            return;
           }
        }
     }
// block of a trade validity time checking, if MaxOpenTime=0, do not check.
   if(MaxOpenTime>0)
     {
      for(cnt=0;cnt<m_total;cnt++)
        {
         if(m_position.SelectByIndex(cnt))
           {
            m_tmp=(TimeCurrent()-m_position.Time())/3600.0;
            if(((NormalizeDouble(m_tmp,8)-MaxOpenTime)>=0))
              {
               //--- refresh rates
               if(!m_symbol.RefreshRates())
                  return;
               //--- protection against the return value of "zero"
               if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
                  return;

               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  closeprice=m_symbol.Bid();
               else
                  closeprice=m_symbol.Ask();

               if(m_trade.PositionClose(m_position.Ticket()))
                 {
                  Print("Forced closing of the trade - №",m_position.Ticket(),
                        ", Result Retcode: ",m_trade.ResultRetcode());
                  //OrderPrint();
                 }
               else
                 {
                  Print("PositionClose() in block of a trade validity time checking returned an error - ",
                        m_trade.ResultRetcode());
                 }
              }
           }
         else
            Print("PositionSelect() in block of a trade validity time checking returned an error - ",GetLastError());
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- call of the checking function
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- something went wrong, report and return false
      Print("Error in ",__FUNCTION__," code=",GetLastError());
      return(false);
     }
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      Print("Not enough money for ",EnumToString(type)," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
