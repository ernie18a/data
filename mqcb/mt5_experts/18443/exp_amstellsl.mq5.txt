//+------------------------------------------------------------------+
//|                      exp_Amstell-SL(barabashkakvn's edition).mq5 |
//|                                   Copyright © 2009, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
#property version   "1.000"
#property description "Trade without Stop Loss and Take Profit"
#property description "Buy if the opening price of the last open position is higher than the current price"
#property description "and close the position after reaching 100 points"
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
input double   InpLots        = 0.01;        // Lots
input ushort   InpTakeProfit  = 30;          // Take Profit (in pips)
input ushort   InpStopLoss    = 30;          // Stop Loss (in pips)
input ushort   InpDistance    = 10;          // Distance (in pips)
input ulong    m_magic        = 359369142;   // magic number
//---
ulong          m_slippage=30;                // slippage
//---
double         last_open_buy_price=0.0;
double         last_open_sell_price=0.0;
double         ExtTakeProfit=0.0;
double         ExtStopLoss=0.0;
double         ExtDistance=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDistance>=InpTakeProfit || InpDistance>=InpStopLoss)
     {
      Print("Distance can not be greater than and equal to Take Profit or Stop Loss");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
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

   ExtTakeProfit  = InpTakeProfit* m_adjusted_point;
   ExtStopLoss    = InpStopLoss  * m_adjusted_point;
   ExtDistance    = InpDistance  * m_adjusted_point;
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
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
               continue;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_symbol.Bid()-m_position.PriceOpen()>ExtTakeProfit || 
                  m_position.PriceOpen()-m_symbol.Bid()>ExtStopLoss)//
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  continue;
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.PriceOpen()-m_symbol.Ask()>ExtTakeProfit || 
                  m_symbol.Ask()-m_position.PriceOpen()>ExtStopLoss)//
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  continue;
                 }
              }
           }
//---
   int count_buys=0,count_sell=0;
   bool trade_buy=false,trade_sell=false;
   CalculatePositions(count_buys,count_sell);
   if(count_buys==0)
      last_open_buy_price=0.0;
   if(count_sell==0)
      last_open_sell_price=0.0;

   if(!RefreshRates())
      return;

   if(count_buys>0 && last_open_buy_price-m_symbol.Ask()>ExtDistance)
      trade_buy=1;

   if(count_sell>0 && m_symbol.Bid()-last_open_sell_price>10*ExtDistance)
      trade_sell=1;

   if(trade_buy || last_open_buy_price==0.0)
      m_trade.Buy(InpLots);

   if(trade_sell || last_open_sell_price==0.0)
      m_trade.Sell(InpLots);

//---
   return;
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
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
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
      long     deal_entry        =0;
      long     deal_type         =-1;
      double   deal_price        =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_type=HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_price=HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
        {
         if(deal_entry==DEAL_ENTRY_IN)
           {
            if(deal_type==DEAL_TYPE_BUY)
               last_open_buy_price=deal_price;
            else if(deal_type==DEAL_TYPE_SELL)
               last_open_sell_price=deal_price;
           }
         //else if(deal_entry==DEAL_ENTRY_OUT)
         //  {
         //   if(deal_type==DEAL_TYPE_BUY)
         //      last_open_sell_price=0.0;
         //   else if(deal_type==DEAL_TYPE_SELL)
         //      last_open_buy_price=0.0;
         //  }
        }
     }
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0.0;
   count_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
