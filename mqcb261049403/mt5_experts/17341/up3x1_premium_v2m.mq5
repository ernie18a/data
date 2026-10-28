//+------------------------------------------------------------------+
//|                   up3x1_premium_v2M(barabashkakvn's edition).mq5 |
//|                                  Copyright © 2006, Izhutov Pavel |
//|                        www.forexnow.narod.ru   izhutov@yandex.ru |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input double   Lots               = 0.05;
input double   MaximumRisk        = 0.1;
input double   DecreaseFactor     = 3;
input double   InpTakeProfit      = 150;
input double   InpStopLoss        = 100;
input double   InpTrailingStop    = 10;
input int      ma_period_one      = 12;
input int      ma_period_two      = 26;
input int      ma_period_day      = 10;
//---
ulong          m_magic=20050612;             // magic number
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
double         ExtTakeProfit=0.0;
double         ExtStopLoss=0.0;
double         ExtTrailingStop=0.0;
int            losses=0;
int    handle_iMA_one;                       // variable for storing the handle of the iMA indicator 
int    handle_iMA_two;                       // variable for storing the handle of the iMA indicator 
int    handle_iMA_day;                       // variable for storing the handle of the iMA indicator 
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtTakeProfit     = InpTakeProfit   * m_adjusted_point;
   ExtStopLoss       = InpStopLoss     * m_adjusted_point;
   ExtTrailingStop   = InpTrailingStop * m_adjusted_point;

   losses=0;
//--- create handle of the indicator iMA
   handle_iMA_one=iMA(m_symbol.Name(),Period(),ma_period_one,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_one==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_two=iMA(m_symbol.Name(),Period(),ma_period_two,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_two==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_day=iMA(m_symbol.Name(),PERIOD_D1,ma_period_day,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_day==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
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
   if(CalculateCurrentPositions()==0)
      CheckForOpen();
   else
      CheckForClose();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateCurrentPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
               total++;

   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=m_account.FreeMargin()*MaximumRisk/1000.0;

   if(DecreaseFactor>0)
      if(losses>1)
         lot=lot-lot*losses/DecreaseFactor;
   if(lot<=0.0)
      lot=Lots;
   lot=LotCheck(lot);
   return(lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   if(iTickVolume(0)>1)
      return;

   double high_1=iHigh(1);
   double low_1=iLow(1);
   double high_2=iHigh(2);
   double low_2=iLow(2);
   double open_1=iOpen(1);
   double close_1=iClose(1);
   double open_2=iOpen(2);
   double close_2=iClose(2);
   double open_day_1=iOpen(1,NULL,PERIOD_D1);
   double close_day_1=iClose(1,NULL,PERIOD_D1);
   double ma_one_2=iMAGet(handle_iMA_one,2);
   double ma_one_1=iMAGet(handle_iMA_one,1);
   double ma_two_2=iMAGet(handle_iMA_two,2);
   double ma_two_1=iMAGet(handle_iMA_two,1);
   double open_0=iOpen(0);
   double close_0=iClose(0);
   double ma_day_0=iMAGet(handle_iMA_day,0);

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(!RefreshRates())
      return;

//--- buy
   if(((ma_one_2<ma_two_2 && ma_two_1<ma_one_1 && open_2<open_1) || (high_1-low_1>0.0060 && open_1<close_1 && 
      close_1-open_1>0.0050)) || (str1.hour==0 && (open_day_1>close_day_1 && (open_day_1-close_day_1)>0.0060)) || 
      (ma_day_0>m_symbol.Ask()) || (ma_day_0<m_symbol.Ask()) || (ma_day_0==m_symbol.Ask()))

     {
      double price=m_symbol.Ask();
      double sl=m_symbol.NormalizePrice(m_symbol.Ask()-ExtStopLoss);
      double tp=m_symbol.NormalizePrice(m_symbol.Ask()+ExtTakeProfit);
      double lots=LotsOptimized();
      if(lots==0.0)
         DebugBreak();
      if(m_trade.Buy(lots,NULL,price,sl,tp,"NeuroCluster-testing-AI-PB1"))
        {
         Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      else
        {
         Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal(),
               ", lot: ",lots);
        }
      return;
     }
//--- sell
   if(((ma_one_2>ma_two_2 && ma_two_1>ma_one_1 && open_2>open_1) || (high_1-low_1>0.0060 && open_1>close_1 && 
      open_1-close_1>0.0050)) || (str1.hour==0 && (open_day_1<close_day_1 && (close_day_1-open_day_1)>0.0060)))

     {
      double price=m_symbol.Bid();
      double sl=m_symbol.NormalizePrice(m_symbol.Bid()+ExtStopLoss);
      double tp=m_symbol.NormalizePrice(m_symbol.Bid()-ExtTakeProfit);
      double lots=LotsOptimized();
      if(m_trade.Sell(lots,NULL,price,sl,tp,"NeuroCluster-testing-AI-PB1"))
        {
         Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      else
        {
         Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription(),
               ", ticket of deal: ",m_trade.ResultDeal());
        }
      return;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   if(iTickVolume(0)>1)
      return;

   double ma_one_2=iMAGet(handle_iMA_one,2);
   double ma_one_1=iMAGet(handle_iMA_one,1);
   double ma_two_2=iMAGet(handle_iMA_two,2);
   double ma_two_1=iMAGet(handle_iMA_two,1);

   if(!RefreshRates())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(ma_one_1>ma_two_1*0.999 && ma_one_1<ma_two_1*1.001)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  break;
                 }
               if(ExtTrailingStop>0)
                 {
                  if(m_symbol.Bid()-m_position.PriceOpen()>ExtTrailingStop)
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-ExtTrailingStop)
                       {
                        double sl=m_symbol.NormalizePrice(m_symbol.Bid()-ExtTrailingStop);
                        m_trade.PositionModify(m_position.Ticket(),sl,m_position.TakeProfit());
                       }
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(ma_one_1>ma_two_1*0.999 && ma_one_1<ma_two_1*1.001)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  break;
                 }
               if(ExtTrailingStop>0)
                 {
                  if(m_position.PriceOpen()-m_symbol.Ask()>ExtTrailingStop)
                    {
                     if(m_position.StopLoss()==0.0 || m_position.StopLoss()>(m_symbol.Ask()+ExtTrailingStop))
                       {
                        double sl=m_symbol.NormalizePrice(m_symbol.Ask()+ExtTrailingStop);
                        m_trade.PositionModify(m_position.Ticket(),sl,m_position.TakeProfit());
                        m_trade.PositionModify(m_position.Ticket(),sl,m_position.TakeProfit());
                       }
                    }
                 }
              }
           }
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
      string   deal_symbol       ="";
      long     deal_magic        =0;
      long     deal_entry        =0;
      double   deal_profit       =0.0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_profit<0)
               losses++;
           }
     }
  }
//+------------------------------------------------------------------+ 
//| Get Open for specified bar index                                 | 
//+------------------------------------------------------------------+ 
double iOpen(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Open[1];
   double open=0;
   int copied=CopyOpen(symbol,timeframe,index,1,Open);
   if(copied>0) open=Open[0];
   return(open);
  }
//+------------------------------------------------------------------+ 
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0) high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0) low=Low[0];
   return(low);
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
//| Get TickVolume for specified bar index                           | 
//+------------------------------------------------------------------+ 
long iTickVolume(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   long TickVolume[1];
   long tickvolume=0;
   int copied=CopyTickVolume(symbol,timeframe,index,1,TickVolume);
   if(copied>0) tickvolume=TickVolume[0];
   return(tickvolume);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
