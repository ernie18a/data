//+------------------------------------------------------------------+
//|                                                   Statistics.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.003"
#property description "Statistics of repeating of behavior of bar"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
input ushort   InpCandleHeight   = 10;       // Min Candle Height ("0" -> the parameter is disabled)
input double   InpLots           = 0.1;      // Lots
input ushort   InpStopLoss       = 15;       // Stop Loss (in pips)
input int      InpDays           = 10;       // Days of History
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;      // MARGIN_MODE
//---
double         ExtLots=0.0;
ulong          m_magic=15489;                // magic number
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
double         m_martin=1.618;               // Gain ratio
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtLots=InpLots;
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
//--- работаем только на новом баре
   static datetime prev_time=0;  // static variable for storage of time of opening of bar on the previous tic
   if(prev_time==iTime(0))
      return;
   prev_time=iTime(0);
   MqlDateTime str1;
   TimeToStruct(prev_time,str1);
//--- we here, means the new bar appeared
//--- at first we will close the current line items
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_trade.PositionClose(m_position.Ticket()))
              {
               Print("PositionClose -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               if(m_trade.ResultRetcode()!=10009)
                 {
                  prev_time=iTime(1);
                  return;
                 }
              }
            else
              {
               Print("PositionClose -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
                 {
                  prev_time=iTime(1);
                  return;
                 }
              }
           }
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true); // the element with the index "0" will be with current date
   int copied=CopyRates(Symbol(),0,prev_time-30,prev_time-InpDays*PeriodSeconds(PERIOD_D1)-60*60,rates);
   if(copied!=-1)
     {
      //MqlDateTime str1;
      //TimeToStruct(prev_time,str1);
      int hour=str1.hour;        // operating hour of the current bar
      int min=str1.min;          // minutes of opening of the current bar
      int bull=0;                // size of bull bars
      int bear=0;                // size of bear bars
      //---
      for(int i=0;i<copied;i++)
        {
         TimeToStruct(rates[i].time,str1);
         if(str1.hour==hour && str1.min==min) // found bar with the same time of opening
           {
            //--- check on height of bar
            int size=(int)((rates[i].close-rates[i].open)/m_symbol.Point());
            if(size!=0.0)
              {
               if(InpCandleHeight!=0 && InpCandleHeight>MathAbs(size))
                  continue;
               if(size>0.0)
                  bull+=size;
               else
                  bear+=MathAbs(size);
              }
           }
        }
      if(bear==bull)
         return;
      Print(prev_time,", size bear bars: ",IntegerToString(bear),
            ", size bull bars: ",IntegerToString(bull));
      //---
      if(!RefreshRates())
        {
         prev_time=iTime(1);
         return;
        }
      if(bull>bear)
        {
         double price=m_symbol.Ask();
         double sl=m_symbol.Ask()-InpStopLoss*m_adjusted_point;
         //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
         double lot_check=LotCheck(ExtLots);
         double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),lot_check,m_symbol.Ask(),ORDER_TYPE_BUY);

         if(chek_volime_lot!=0.0)
            if(chek_volime_lot<lot_check)
               return;
         //---
         if(m_trade.Buy(lot_check,NULL,price,m_symbol.NormalizePrice(sl)))
           {
            if(m_trade.ResultDeal()==0)
              {
               prev_time=iTime(1);
               return;
              }
           }
         else
           {
            prev_time=iTime(1);
            return;
           }
        }
      if(bear>bull)
        {
         double price=m_symbol.Bid();
         double sl=m_symbol.Bid()+InpStopLoss*m_adjusted_point;
         //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
         double lot_check=LotCheck(ExtLots);
         double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),lot_check,m_symbol.Bid(),ORDER_TYPE_SELL);

         if(chek_volime_lot!=0.0)
            if(chek_volime_lot<lot_check)
               return;
         //---
         if(m_trade.Sell(lot_check,NULL,price,m_symbol.NormalizePrice(sl)))
           {
            if(m_trade.ResultDeal()==0)
              {
               prev_time=iTime(1);
               return;
              }
           }
         else
           {
            prev_time=iTime(1);
            return;
           }
        }
      //}
     }
   else
     {
      //prev_time=iTime(1);
      Print("It wasn't succeeded to obtain historical data on a symbol ",Symbol());
     }

//---
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_profit>0)
              {
               ExtLots=InpLots;
              }
            else
              {
               ExtLots=InpLots*m_martin;
              }
           }
     }
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
