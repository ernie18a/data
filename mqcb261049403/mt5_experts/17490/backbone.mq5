//+------------------------------------------------------------------+
//|                            Backbone(barabashkakvn's edition).mq5 |
//|                                           Copyright © 2008, gpwr |
//|                                               gpwr9k95@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, gpwr"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double   MaxRisk     =0.5; // max. risk for all trades at any time
input int      ntmax       =10;  // max. number of trades in one direction
input ushort   TakeProfit  =170; // TakeProfit
input ushort   StopLoss    =40;  // StopLoss
input ushort   TrailingStop=300; // TrailingStop
//--- global variables
ulong          m_magic=5245679;              // magic number
int LastPosition; // 1 = long, -1 = short, 0 = none
double BidMax,AskMin;
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
//---
   m_trade.SetExpertMagicNumber(m_magic);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//---
   LastPosition=0;
   BidMax=0.0;
   AskMin=10000.0;
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
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   if(!RefreshRates())
     {
      time_0=iTime(1);
      return;
     }

//--- finding the first entry point
   if(LastPosition==0)
     {
      if(m_symbol.Bid()>BidMax)
         BidMax=m_symbol.Bid();
      if(m_symbol.Ask()<AskMin)
         AskMin=m_symbol.Ask();
      if(m_symbol.Bid()<BidMax-TrailingStop*m_adjusted_point)
         LastPosition=-1;
      if(m_symbol.Ask()>AskMin+TrailingStop*m_adjusted_point)
         LastPosition=1;
     }

//--- begin trading 
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

//--- modifying stop-loss
   if(TrailingStop>0 && StopLoss>0)
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.Profit()>0)
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>TrailingStop*m_adjusted_point)
                     if(m_position.StopLoss()<m_position.PriceCurrent()-TrailingStop*m_adjusted_point)
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_position.PriceCurrent()-TrailingStop*m_adjusted_point,
                                               m_position.TakeProfit());
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Profit()>0)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()<TrailingStop*m_adjusted_point)
                     if(m_position.StopLoss()>m_position.PriceCurrent()+TrailingStop*m_adjusted_point)
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_position.PriceCurrent()+TrailingStop*m_adjusted_point,
                                               m_position.TakeProfit());
                 }
              }
//--- sending OPEN LONG order 
   double lots=0.0;
   if((LastPosition==-1 && total==0) || (LastPosition==1 && total>0 && total<ntmax))
     {
      lots=Vol(Symbol(),total);
      if(lots>0.0)
        {
         double sl=0.0;
         double tp=0.0;

         if(StopLoss!=0)
            sl=m_symbol.NormalizePrice(m_symbol.Ask()-StopLoss*m_adjusted_point);

         if(TakeProfit!=0)
            tp=m_symbol.NormalizePrice(m_symbol.Ask()+TakeProfit*m_adjusted_point);

         if(m_trade.Buy(lots,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
           }
         else
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());

         LastPosition=1;
        }
     }
//--- sending OPEN SHORT order 
   else if((LastPosition==1 && total==0) || (LastPosition==-1 && total>0 && total<ntmax))
     {
      lots=Vol(Symbol(),total);
      if(lots>0.0)
        {
         double sl=0.0;
         double tp=0.0;

         if(StopLoss!=0)
            sl=m_symbol.NormalizePrice(m_symbol.Bid()+StopLoss*m_adjusted_point);

         if(TakeProfit!=0)
            tp=m_symbol.NormalizePrice(m_symbol.Bid()-TakeProfit*m_adjusted_point);

         if(m_trade.Sell(lots,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
           }
         else
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());

         LastPosition=-1;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Lots Calculation Function                                        |
//+------------------------------------------------------------------+
double Vol(string symbol,// symbol=symbol of the currency pair, for example "EURUSD"
           int total) // total=number of open orders in the same direction
  {
   string first   =StringSubstr(symbol,0,3);                            // first symbol, for example      EUR
   string second  =StringSubstr(symbol,3,3);                            // second symbol, for example     USD
   string currency=m_account.Currency();                                // account currency, for example  USD
   long leverage=m_account.Leverage();                                  // leverage, for example          100
   double bid     =SymbolInfoDouble(symbol,SYMBOL_BID);                 // bid price
   double contract=SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE); // size of 1 lot, for example     100,000
   double lot_min =SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double lot_max =SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   double lot_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   double vol=0.0;
//--- only allow standard Forex symbols XXXYYY
   if(StringLen(symbol)!=6)
     {
      Print("Lots: '",symbol,"' must be standard forex symbol XXXYYY");
      return(0.0);
     }
//--- check data
   if(bid<=0 || contract<=0)
     {
      Print("Lots: no market information for '",symbol,"'");
      return(0.0);
     }
   if(lot_min<0 || lot_max<=0.0 || lot_step<=0.0)
     {
      Print("Lots: invalid MarketInfo() results [",lot_min,",",lot_max,",",lot_step,"]");
      return(0);
     }
   if(m_account.Leverage()<=0)
     {
      Print("Lots: invalid m_account.Leverage() [",m_account.Leverage(),"]");
      return(0);
     }

//--- calulating lots based on margin call scenario
   double frac=1.0/(ntmax/MaxRisk-total);
//--- if one of the currencies in the pair is the same as the account currency
   if(first==currency)
      vol=NormalizeDouble(m_account.FreeMargin()*frac*leverage/contract,2);      // USDxxx
   if(second==currency)
      vol=NormalizeDouble(m_account.FreeMargin()*frac*leverage/contract/bid,2);  // xxxUSD
//--- if neither currency in the pair is the same as the account currency
   string base=currency+first;                                       // USDxxx
   if(SymbolInfoDouble(base,SYMBOL_BID)>0)
      vol=NormalizeDouble(m_account.FreeMargin()*frac*leverage*SymbolInfoDouble(base,SYMBOL_BID)/contract,2);
   base=first+currency;                                              // xxxUSD
   if(SymbolInfoDouble(base,SYMBOL_BID)>0)
      vol=NormalizeDouble(m_account.FreeMargin()*frac*leverage/contract/SymbolInfoDouble(base,SYMBOL_BID),2);

//--- calculating lots based on StopLoss
   double volSL=NormalizeDouble(m_account.FreeMargin()*frac/contract/(StopLoss*Point()),2);

//--- select the smallest value for lots
   if(volSL<vol) vol=volSL;

//--- check lot min, max and step
   vol=NormalizeDouble(vol/lot_step,0)*lot_step;
   if(vol<lot_min)
      vol=0.0;
   if(vol>lot_max)
      vol=lot_max;
   return(vol);
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
