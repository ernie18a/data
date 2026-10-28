//+------------------------------------------------------------------+
//|                                              LacusTstopandBE.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "http://wmua.ru/slesar/"
#property version   "3.100"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
//--- input parameters
input ushort   InpStopLoss=40;                  // Stop loss
input ushort   InpTakeProfit=200;               // Take profit
sinput string  Closefunctions="Closefunctions"; // Closefunctions
input double   Percentofbalance=1;              // Close all if profit reached the x percent of balance or
input double   ProfitAmount=12;                 // close all if profit reached the x profit amount in currency
input double   InpProfit=4;                     // Close if profit reached x profit amount  
input ushort   InpTrailingStart=30;             // Trailing Start after reaching x pips
input ushort   InpTrailingStop=20;              // Trailing Stop distance from current price
input ushort   InpBreakevenGain=25;             // Breakeven Gain after reaching x pips
input ushort   InpBreakeven=10;                 // Breakeven x pips locked in profit
input bool     STEALTH=false;                   // Stealth mode for Stoploss and Takeprofit values
//---
ulong          m_slippage=10;                   // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStart=0.0;
double         ExtTrailingStop=0.0;
double         ExtBreakevenGain=0.0;
double         ExtBreakeven=0.0;
//---
double         m_adjusted_point;                // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpBreakeven>=InpBreakevenGain)
     {
      Print("\"Breakeven\" (",IntegerToString(InpBreakeven),
            ") can not be greater than or equal to \"Breakeven Gain\" (",IntegerToString(InpBreakevenGain),")");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpTrailingStop>=InpTrailingStart)
     {
      Print("\"Trailing Stop\" (",IntegerToString(InpTrailingStop),
            ") can not be greater than or equal to \"Trailing Start\" (",IntegerToString(InpTrailingStart),")");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
   ExtTrailingStart=InpTrailingStart*m_adjusted_point;
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtBreakevenGain=InpBreakevenGain*m_adjusted_point;
   ExtBreakeven=InpBreakeven*m_adjusted_point;
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
   if(STEALTH==false)
     {
      SetSLTP();         //function for setting SL and TP for orders
      Movebreakeven();   //moving to "InpBreakeven" pips after reaching "InpBreakevenGain" pips
      TrailingStop();    //trailing stop after reaching InpTrailingStart pips 
      CloseOnProfit();   //close order on actual pair if orderprofit reached x amount of acc currency
      CloseAll();  //close all opened orders/buy and sell/ if profit on account reached x percent of balance, or profit reached the x profit amount in acc currency, for example 12 euros.
     }
   else
     {
      CloseonStealthSLTP();
      CloseOnProfit();
      CloseAll();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSLTP()
  {
   double stops_freeze_level=(m_symbol.StopsLevel()>m_symbol.FreezeLevel())?m_symbol.StopsLevel():m_symbol.FreezeLevel();
   stops_freeze_level*=m_symbol.Point();

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            long magic=m_position.Magic();
            m_trade.SetExpertMagicNumber(magic);
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               if(m_position.StopLoss()==0.0 || m_position.TakeProfit()==0.0)
                 {
                  double sl=0.0;
                  if(m_position.StopLoss()==0.0)
                    {
                     if(m_position.PriceOpen()-ExtStopLoss<m_position.PriceCurrent()-stops_freeze_level)
                        sl=m_symbol.NormalizePrice(m_position.PriceOpen()-ExtStopLoss);
                    }
                  else
                     sl=m_position.StopLoss();
                  double tp=0.0;
                  if(m_position.TakeProfit()==0.0)
                    {
                     if(m_position.PriceOpen()+ExtTakeProfit>m_position.PriceCurrent()+stops_freeze_level)
                        tp=m_symbol.NormalizePrice(m_position.PriceOpen()+ExtTakeProfit);
                    }
                  else
                     tp=m_position.TakeProfit();
                  if(sl!=0.0 || tp!=0.0)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),sl,tp))
                        Print("Modify ",m_position.Ticket(),
                              " Position BUY -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());

                    }
                 }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.StopLoss()==0.0 || m_position.TakeProfit()==0.0)
                 {
                  double sl=0.0;
                  if(m_position.StopLoss()==0.0)
                    {
                     if(m_position.PriceOpen()+ExtStopLoss>m_position.PriceCurrent()+stops_freeze_level)
                        sl=m_symbol.NormalizePrice(m_position.PriceOpen()+ExtStopLoss);
                    }
                  else
                     sl=m_position.StopLoss();
                  double tp=0.0;
                  if(m_position.TakeProfit()==0.0)
                    {
                     if(m_position.PriceOpen()-ExtTakeProfit<m_position.PriceCurrent()-stops_freeze_level)
                        tp=m_symbol.NormalizePrice(m_position.PriceOpen()-ExtTakeProfit);
                    }
                  else
                     tp=m_position.TakeProfit();
                  if(sl!=0.0 || tp!=0.0)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),sl,tp))
                        Print("Modify ",m_position.Ticket(),
                              " Position SELL -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());

                    }
                 }
              }
           }
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name())
           {
            long magic=m_order.Magic();
            m_trade.SetExpertMagicNumber(magic);
            if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
               if(m_order.StopLoss()==0.0 || m_order.TakeProfit()==0.0)
                 {
                  double sl=(m_order.StopLoss()==0.0)?m_symbol.NormalizePrice(m_order.PriceOpen()-ExtStopLoss):0.0;
                  double tp=(m_order.TakeProfit()==0.0)?m_symbol.NormalizePrice(m_order.PriceOpen()+ExtTakeProfit):0.0;
                  if(!m_trade.OrderModify(m_order.Ticket(),m_order.PriceOpen(),
                     sl,tp,m_order.TypeTime(),m_order.TimeExpiration()))
                     Print("Modify ",m_order.Ticket(),
                           " Pending ",EnumToString(m_order.OrderType())," -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
            if(m_order.OrderType()==ORDER_TYPE_SELL_LIMIT || m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               if(m_order.StopLoss()==0.0 || m_order.TakeProfit()==0.0)
                 {
                  double sl=(m_order.StopLoss()==0.0)?m_symbol.NormalizePrice(m_order.PriceOpen()+ExtStopLoss):0.0;
                  double tp=(m_order.TakeProfit()==0.0)?m_symbol.NormalizePrice(m_order.PriceOpen()-ExtTakeProfit):0.0;
                  if(!m_trade.OrderModify(m_order.Ticket(),m_order.PriceOpen(),
                     sl,tp,m_order.TypeTime(),m_order.TimeExpiration()))
                     Print("Modify ",m_order.Ticket(),
                           " Pending ",EnumToString(m_order.OrderType())," -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
           }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Movebreakeven()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            long magic=m_position.Magic();
            m_trade.SetExpertMagicNumber(magic);
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtBreakevenGain)
                  if(m_position.StopLoss()<m_position.PriceOpen() || m_position.StopLoss()==0.0)
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceOpen()+ExtBreakeven),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position BUY -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtBreakevenGain)
                  if(m_position.StopLoss()>m_position.PriceOpen() || m_position.StopLoss()==0.0)
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceOpen()-ExtBreakeven),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position SELL -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingStop()
  {
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            long magic=m_position.Magic();
            m_trade.SetExpertMagicNumber(magic);
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-ExtTrailingStart-ExtTrailingStop>m_position.StopLoss() && m_position.StopLoss()!=0.0)
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStart),
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position BUY -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.PriceCurrent()+ExtTrailingStart+ExtTrailingStop<m_position.StopLoss() && m_position.StopLoss()!=0.0)
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStart),
                     m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position SELL -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOnProfit()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            long magic=m_position.Magic();
            m_trade.SetExpertMagicNumber(magic);
            if(m_position.Commission()+m_position.Swap()+m_position.Profit()>InpProfit)
               m_trade.PositionClose(m_position.Ticket());
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
//---
   double profit=m_account.Profit();
   double profitpercent=Percentofbalance*(m_account.Balance()/100.0);
   if(profit>ProfitAmount || profit>profitpercent)
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
           {
            long magic=m_position.Magic();
            m_trade.SetExpertMagicNumber(magic);
            m_trade.PositionClose(m_position.Ticket());
           }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseonStealthSLTP()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            long magic=m_position.Magic();
            m_trade.SetExpertMagicNumber(magic);
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.StopLoss()==0.0 && InpStopLoss>0 && 
                  m_position.PriceCurrent()<=m_position.PriceOpen()-ExtStopLoss)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  continue;
                 }
               if(m_position.TakeProfit()==0.0 && InpTakeProfit>0 && 
                  m_position.PriceCurrent()>=m_position.PriceOpen()+ExtTakeProfit)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  continue;
                 }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.StopLoss()==0.0 && InpStopLoss>0 && 
                  m_position.PriceCurrent()>=m_position.PriceOpen()+ExtStopLoss)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  continue;
                 }
               if(m_position.TakeProfit()==0.0 && InpTakeProfit>0 && 
                  m_position.PriceCurrent()<=m_position.PriceOpen()-ExtTakeProfit)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  continue;
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
