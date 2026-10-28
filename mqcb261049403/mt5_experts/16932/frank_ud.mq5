//+------------------------------------------------------------------+
//|                            Frank Ud(barabashkakvn's edition).mq5 | 
//+------------------------------------------------------------------+
#property version "1.002"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper

input ulong    InpMagic       = 20050611;    // Magic
input ushort   InpTakeprofit  = 12;          // Takeprofit
input ushort   InpStoploss    = 12;          // Stoploss
input ushort   InpStep        = 16;          // Step
input bool     InpLotAuto     = true;        // Auto lot
input double   InpLot         = 0.5;         // only if "Auto lot"
//---
double         ExtTakeprofit  = 0.0;
double         ExtStoploss    = 0.0;
double         ExtStep        = 0.0;
double         ExtLots        = 0.0;
double         Coefficient    = 0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(m_account.MarginMode()!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(InpMagic);   // sets magic number
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtTakeprofit  = InpTakeprofit*digits_adjust*m_symbol.Point();
   ExtStoploss    = InpStoploss  *digits_adjust*m_symbol.Point();
   ExtStep        = InpStep      *digits_adjust*m_symbol.Point();
   Coefficient    = 1.0;
   if(!InpLotAuto)
      ExtLots=m_symbol.LotsMin()*Coefficient;
   else
      ExtLots=InpLot*Coefficient;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(m_account.FreeMargin()<m_account.Balance()*0.5)
      return;

   int count_buy=0;        // count of POSITION_TYPE_BUY
   int count_sell=0;       // count of POSITION_TYPE_SELL

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(!m_position.SelectByIndex(i))
         break;
      if(m_position.Symbol()==Symbol() && m_position.Magic()==InpMagic)
        {
         if(m_position.PositionType()==POSITION_TYPE_BUY)
           {
            count_buy++;
           }
         else
           {
            count_sell++;
           }
        }
     }
//--- there is no open position
   if(count_buy==0 && count_sell==0)
     {
      if(!RefreshRates())
         return;
      Coefficient=1.0;
      if(!m_trade.Buy(ExtLots*Coefficient,Symbol(),m_symbol.Ask(),
         m_symbol.NormalizePrice(m_symbol.Ask()-ExtStoploss),
         m_symbol.NormalizePrice(m_symbol.Ask()+ExtTakeprofit),NULL))
        {
         Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      if(!m_trade.Sell(ExtLots*Coefficient,Symbol(),m_symbol.Bid(),
         m_symbol.NormalizePrice(m_symbol.Bid()+ExtStoploss),
         m_symbol.NormalizePrice(m_symbol.Bid()-ExtTakeprofit),NULL))
        {
         Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      return;
     }
//--- if positions are open only in one direction
   if(count_buy==0 || count_sell==0)
     {
      if(!RefreshRates())
         return;
      double netting_price=0.0;
      if(count_buy==0)
        {
         //--- all open positions - "sell"
         double last_price=0.0;
         //--- calculation of the netting price of all positions  
         netting_price=CalculationNetPrice(POSITION_TYPE_SELL,last_price);
         if(netting_price==0)
            return;
         double stop_loss=0.0;
         double take_prof=NormalizeDouble(netting_price-ExtTakeprofit,Digits());
         //---
         for(int i=PositionsTotal()-1;i>=0;i--)
           {
            if(!m_position.SelectByIndex(i))
               return;
            if(m_position.Symbol()==Symbol() && m_position.Magic()==InpMagic)
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  if(m_position.StopLoss()!=0.0 || m_position.TakeProfit()!=take_prof)
                     m_trade.PositionModify(m_position.Ticket(),stop_loss,take_prof);
           }
         if(last_price!=0.0)
            if(m_symbol.Ask()>last_price+ExtStep)
              {
               Coefficient=LotCheck(Coefficient*2.0);
               if(!CheckMoneyForTrade(Symbol(),ExtLots*Coefficient,ORDER_TYPE_SELL))
                  return;
               if(!m_trade.Sell(ExtLots*Coefficient,Symbol(),m_symbol.Bid(),m_symbol.Ask()+ExtStoploss,0.0,NULL))
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                 }
              }
        }

      if(count_sell==0)
        {
         //--- all open positions - "buy"
         double last_price=0.0;
         //--- calculation of the netting price of all positions  
         netting_price=CalculationNetPrice(POSITION_TYPE_BUY,last_price);
         if(netting_price==0)
            return;
         double stop_loss=0.0;
         double take_prof=NormalizeDouble(netting_price+ExtTakeprofit,Digits());
         //---
         for(int i=PositionsTotal()-1;i>=0;i--)
           {
            if(!m_position.SelectByIndex(i))
               return;
            if(m_position.Symbol()==Symbol() && m_position.Magic()==InpMagic)
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  if(m_position.StopLoss()!=0.0 || m_position.TakeProfit()!=take_prof)
                     m_trade.PositionModify(m_position.Ticket(),stop_loss,take_prof);
           }
         if(last_price!=0.0)
            if(m_symbol.Bid()<last_price-ExtStep)
              {
               Coefficient=LotCheck(Coefficient*2.0);
               if(!CheckMoneyForTrade(Symbol(),ExtLots*Coefficient,ORDER_TYPE_BUY))
                  return;
               if(!m_trade.Buy(ExtLots*Coefficient,Symbol(),m_symbol.Ask(),m_symbol.Bid()-ExtStoploss,0.0,NULL))
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                 }
              }
        }

     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Calculation Net Price                                            |
//+------------------------------------------------------------------+
double CalculationNetPrice(const ENUM_POSITION_TYPE type,double &nearest_price)
  {
   double total_price_multiply_volume  = 0.0;
   double total_volume                 = 0.0;
   double net_price                    = 0.0;
   bool   first_find                   = false;
   double last_price                   = 0.0;

   int total=PositionsTotal();
   for(int i=total-1;i>=0;i--)
     {
      if(!m_position.SelectByIndex(i))
         break;
      if(m_position.Symbol()==Symbol() && m_position.Magic()==InpMagic)
        {
         if(m_position.PositionType()==type)
           {
            total_price_multiply_volume+=m_position.PriceOpen()*m_position.Volume();
            total_volume+=m_position.Volume();
            if(type==POSITION_TYPE_BUY)
              {
               if(!first_find)
                 {
                  last_price=m_position.PriceOpen();
                  first_find=true;
                 }
               else
                 {
                  if(m_position.PriceOpen()<last_price)
                     last_price=m_position.PriceOpen();
                 }
              }
            else
              {
               if(!first_find)
                 {
                  last_price=m_position.PriceOpen();
                  first_find=true;
                 }
               else
                 {
                  if(m_position.PriceOpen()>last_price)
                     last_price=m_position.PriceOpen();
                 }
              }
           }
        }
     }
   if(total_price_multiply_volume!=0 && total_volume!=0)
     {
      net_price=total_price_multiply_volume/total_volume;
      nearest_price=last_price;
     }
   return(net_price);
  }
//+------------------------------------------------------------------+
//| Check Money For Trade                                            |
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
