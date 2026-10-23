//+------------------------------------------------------------------+
//|                        E-Skoch-Open(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Хлыстов Владимир"
#property link      "cmillion@narod.ru"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input ushort   stoploss       = 130;         // уровень SL. если 0, то SL не выставляется
input ushort   takeprofit     = 200;         // уровень TP. если 0, то TP не выставляется
input ulong    m_magic=586483;         // magic number
input bool     SELL           = true;        // открыть SELL
input bool     BUY            = true;        // открыть BUY
input double   InpLot         = 0.01;        // объем
input ulong    m_slippage     = 30;          // slippage
input double   _percentProfit = 1.2;         // Профецит
input bool     Close_ON       = false;       //закрытие позиции по обратному сигналу
input int      MaxBuyCount    = 1;           // Макс кол-во открытых BUY. "-1" - не нограничено 
input int      MaxSellCount   = 1;           // Макс кол-во открытых SELL. "-1" - не ограничено
//---
datetime   BARflag=0;                        // для побарового режима
//---
double lot_last=0.0;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   lot_last=InpLot;
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
   datetime now=iTime(0);                 // для побарового режима
   if(BARflag>=now)
      return;                          // для побарового режима
   BARflag=now;                           // для побарового режима

   int nPos; // максимально открытых поизций
   if(CountPositions(-1)==0)
      GlobalVariableSet(IntegerToString(m_magic)+" eq",m_account.Equity());
   double  global=GlobalVariableGet(IntegerToString(m_magic)+" eq");
   Comment("Контрольное эквити ",global,
           "Текущее эквити ",m_account.Equity(),"\n",
           "Текущий процент роста Эквити ",100*(m_account.Equity()-global)/global," %");

   CheckProfit();

//--- BUY
   if((iClose(3)>iClose(2)) && (iClose(1)<iClose(2)))
     {
      if(Close_ON)
        {
         ClosePositions(POSITION_TYPE_SELL);
         return;
        }

      nPos=CountPositions(POSITION_TYPE_BUY);
      if(MaxSellCount!=-1 && nPos>=MaxSellCount)
         return;

      if(BUY)
        {
         if(!RefreshRates())
            return;

         double SL=0.0;
         double TP=0.0;
         if(takeprofit!=0)
            TP=m_symbol.NormalizePrice(m_symbol.Ask()+takeprofit*m_adjusted_point);

         if(stoploss!=0)
            SL=m_symbol.NormalizePrice(m_symbol.Ask()-stoploss*m_adjusted_point);

         if(m_trade.Buy(lot_last,NULL,m_symbol.Ask(),SL,TP))
           {
            if(m_trade.ResultDeal()==0)
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
           }
         else
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
        }
     }

//--- SELL
   if((iClose(3)>iClose(2)) && (iClose(2)<iClose(1)))
     {
      if(Close_ON)
        {
         ClosePositions(POSITION_TYPE_BUY);
         return;
        }
      nPos=CountPositions(POSITION_TYPE_SELL);
      if(MaxSellCount!=-1 && nPos>=MaxSellCount)
         return;

      if(SELL)
        {
         if(!RefreshRates())
            return;

         double SL=0.0;
         double TP=0.0;
         if(takeprofit!=0)
            TP=m_symbol.NormalizePrice(m_symbol.Bid()-takeprofit*m_adjusted_point);

         if(stoploss!=0)
            SL=m_symbol.NormalizePrice(m_symbol.Bid()+stoploss*m_adjusted_point);

         if(m_trade.Sell(lot_last,NULL,m_symbol.Bid(),SL,TP))
           {
            if(m_trade.ResultDeal()==0)
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
           }
         else
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Профецит                                                         |
//+------------------------------------------------------------------+
void CheckProfit()
  {
   double  global=GlobalVariableGet(IntegerToString(m_magic)+" eq");

   if(100*(m_account.Equity()-global)/global>=_percentProfit)
      CloseAllPositions();

   return;
  }
//+------------------------------------------------------------------+
//| Close ALL Positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountPositions(ENUM_POSITION_TYPE pos_type)
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               total++;

   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE pos_type)
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket());

   return;
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
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==Symbol() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_profit>0)
               lot_last=InpLot;
            else
              {
               lot_last=InpLot*1.6;
               lot_last=LotCheck(lot_last);
              }
           }
     }
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
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
//------------------------------------------------------------------------------------------------------+
