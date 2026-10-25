//+------------------------------------------------------------------+
//|                                risk(barabashkakvn's edition).mq5 |
//|                                                 Виктор Чеботарёв |
//|                                    http://www.chebotariov.co.ua/ |
//+------------------------------------------------------------------+
#property copyright "Виктор Чеботарёв"
#property link      "http://www.chebotariov.co.ua/"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedMargin m_money;
//--- input parameters
input double   Risk=5;        // Risk in percent for a deal from a free margin
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(Risk);
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
   double lots_total=0.0;
   double profit_total=0.0;
   double profit_symbol=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         lots_total+=m_position.Volume();
         profit_total+=m_position.Profit();
         if(m_position.Symbol()==m_symbol.Name())
            profit_symbol+=m_position.Profit();
        }
//--- Check open BUY
   double sl=0.0;
   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
   string text=DoubleToString(Risk,0)+"%"+"\n"+
               "Check open BUY: "+DoubleToString(check_open_long_lot,2)+
               ", Balance: "+    DoubleToString(m_account.Balance(),2)+
               ", Equity: "+     DoubleToString(m_account.Equity(),2)+
               ", FreeMargin: "+ DoubleToString(m_account.FreeMargin(),2);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);
   text=text+"\n"+
        "trade BUY, lot: "+DoubleToString(chek_volime_lot,2);
//--- Check open SELL
   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
   text=text+"\n"+
        "Check open SELL: "+DoubleToString(check_open_short_lot,2)+
        ", Balance: "+    DoubleToString(m_account.Balance(),2)+
        ", Equity: "+     DoubleToString(m_account.Equity(),2)+
        ", FreeMargin: "+ DoubleToString(m_account.FreeMargin(),2);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Bid(),ORDER_TYPE_SELL);
   text=text+"\n"+
        "trade SELL, lot: "+DoubleToString(chek_volime_lot,2);
   Comment(text);
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
