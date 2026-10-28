//+------------------------------------------------------------------+
//|                             MACDCCI(barabashkakvn's edition).mq5 |
//|                                                  The # one Lotfy |
//|                                             hmmlotfy@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "The # one Lotfy"
#property link      "hmmlotfy@hotmail.com"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input double   InpLot=0.01;                  // Lot
input int      cci_ma_period=8;
input int      macd_fast_ema_period = 13;
input int      macd_slow_ema_period = 33;
input int      macd_coefficient=86000;       // согласование cci и macd
input double   buyLevel=85;
input double   increase=1.62;                // наращивание позиции
input int      back=0;                       // работать на баре номер   
//---
int buyTotal=0;
int sellTotal=0;
int pos=0;
bool buy=false;
bool sell=false;
//---
ulong          m_magic=343;                  // magic number
double         ExtLot=0.0;
int            handle_iCCI;                  // variable for storing the handle of the iCCI indicator 
int            handle_iMACD;                 // variable for storing the handle of the iMACD indicator 
int            Number_of_losses=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//SetMarginMode();
//if(!IsHedging())
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
//---
   Number_of_losses=0;
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(Symbol(),Period(),cci_ma_period,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iCCI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(Symbol(),Period(),macd_fast_ema_period,macd_slow_ema_period,2,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
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
   double cci=iCCIGet(back);
   double macd=iMACDGet(MAIN_LINE,back)*macd_coefficient;
   Comment("cci: ",DoubleToString(cci,2),"\n",
           "macd: ",DoubleToString(macd,Digits()+1),"\n",
           "buyLevel: ",buyLevel);
   buyTotal=0;
   sellTotal=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               buyTotal++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               sellTotal++;
           }

   if(cci>buyLevel && macd>buyLevel)
     {
      sell= true;
      buy = false;
     }
   else if(cci<-buyLevel && macd<-buyLevel)
     {
      buy=true;
      sell=false;
     }
   if(buy && cci<buyLevel)
     {
      FuncBuy();
      buy=false;
     }
   if(sell && cci<-buyLevel)
     {
      FuncSell();
      sell=false;
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FuncBuy()
  {
   CloseAll(POSITION_TYPE_SELL);
   if(buyTotal==0)
     {
      if(Number_of_losses>0.0)
         ExtLot=InpLot*MathPow(2,increase);
      else
         ExtLot=InpLot;

      ExtLot=LotCheck(ExtLot);
      if(ExtLot!=0.0)
         m_trade.Buy(ExtLot);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FuncSell()
  {
   CloseAll(POSITION_TYPE_BUY);
   if(sellTotal==0)
     {
      if(Number_of_losses>0.0)
         ExtLot=InpLot*MathPow(2,increase);
      else
         ExtLot=InpLot;

      ExtLot=LotCheck(ExtLot);
      if(ExtLot!=0.0)
         m_trade.Sell(ExtLot);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll(ENUM_POSITION_TYPE type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.Type()==type)
               m_trade.PositionClose(m_position.Ticket()); // or OrderClosePrice()

            if(m_position.Type()==type)
               m_trade.PositionClose(m_position.Ticket()); // or OrderClosePrice()
           }
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
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(const int index)
  {
   double CCI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCCI,0,index,1,CCI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(CCI[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,index,1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[0]);
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
              {
               Number_of_losses--;
              }
            else
              {
               Number_of_losses++;
              }
            Comment("Number_of_losses: ",Number_of_losses);
           }
     }
  }
//+------------------------------------------------------------------+
