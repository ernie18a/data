//+------------------------------------------------------------------+
//|                 Hedge any positions(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.000"
#property description "When a loss is reached N-pips opens the opposite position"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input ushort   InpLosing         = 5;        // Losing, in pips (1.00045-1.00055=1 pips)
input double   InpLotCoefficient = 2.0;      // Lot coefficient
input bool     InpPrintResult    = false;    // Print result
//---
ulong          m_slippage=10;                // slippage
long           id_array[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArrayFree(id_array);
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
//--- when testing
   if(MQLInfoInteger(MQL_TESTER))
      if(!IsPositionExists())
        {
         int m=MathRand();
         if(m<32767/2)
            OpenBuy(1.0,0.0,0.0);
         else
            OpenSell(1.0,0.0,0.0);
        }
//---
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
        {
         long id=m_position.Identifier();
         if(FingId(id))
            continue;
         //---
         string symbol        = m_position.Symbol();
         ulong magic          = m_position.Magic();
         double freeze_level  = 0.0,stop_level=0.0;
         if(!RefreshRates(symbol,magic,freeze_level,stop_level))
            continue;
         //--- tuning for 3 or 5 digits
         int digits_adjust=1;
         if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
            digits_adjust=10;
         double m_adjusted_point=m_symbol.Point()*digits_adjust;
         //---
         if(m_position.PositionType()==POSITION_TYPE_BUY)
            if(m_position.PriceOpen()-m_position.PriceCurrent()>=InpLosing*m_adjusted_point)
              {
               double lot=LotCheck(m_position.Volume()*InpLotCoefficient);
               if(lot==0.0)
                  continue;
               //---
               if(OpenSell(lot,0.0,0.0))
                  AddId(id);
              }

         if(m_position.PositionType()==POSITION_TYPE_SELL)
            if(m_position.PriceCurrent()-m_position.PriceOpen()>=InpLosing*m_adjusted_point)
              {
               double lot=LotCheck(m_position.Volume()*InpLotCoefficient);
               if(lot==0.0)
                  continue;
               //---
               if(OpenBuy(lot,0.0,0.0))
                  AddId(id);
              }
        }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(const string symbol,const ulong magic,double freeze_level,double stop_level)
  {
   if(!m_symbol.Name(symbol)) // sets symbol name
      return(false);
//---
   m_trade.SetExpertMagicNumber(magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- refresh
   if(!m_symbol.Refresh())
     {
      Print("Refres error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
   if(freeze_level==0.0)
      freeze_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
   freeze_level*=1.1;

   stop_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(stop_level==0.0)
      stop_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
   stop_level*=1.1;

   if(freeze_level<=0.0 || stop_level<=0.0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Fing position identifier in array                                |
//+------------------------------------------------------------------+
bool FingId(const long id)
  {
   int size=ArraySize(id_array);
   for(int i=0;i<size;i++)
      if(id_array[i]==id)
         return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Fing position identifier in array                                |
//+------------------------------------------------------------------+
void AddId(const long id)
  {
   int size=ArraySize(id_array);
   ArrayResize(id_array,size+1);
   id_array[size]=id;
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(const double lot,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double long_lot=lot;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,long_lot,m_symbol.Ask());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,long_lot,m_symbol.Bid());
   if(free_margin_check>margin_check*1.1)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),m_symbol.Ask(),sl,tp))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintResult)
               PrintResultTrade(m_trade,m_symbol);
            return(false);
           }
         else
           {
            Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintResult)
               PrintResultTrade(m_trade,m_symbol);
            return(true);
           }
        }
      else
        {
         Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintResult)
            PrintResultTrade(m_trade,m_symbol);
         return(false);
        }
     }
   else
     {
      if(InpPrintResult)
         Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return(false);
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(const double lot,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double short_lot=lot;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   if(free_margin_check>margin_check*1.1)
     {
      if(m_trade.Sell(short_lot,m_symbol.Name(),m_symbol.Bid(),sl,tp))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintResult)
               PrintResultTrade(m_trade,m_symbol);
            return(false);
           }
         else
           {
            Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintResult)
               PrintResultTrade(m_trade,m_symbol);
            return(true);
           }
        }
      else
        {
         Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintResult)
            PrintResultTrade(m_trade,m_symbol);
         return(false);
        }
     }
   else
     {
      if(InpPrintResult)
         Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return(false);
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
