//+------------------------------------------------------------------+
//|                          eur usd m5(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input ushort   InpStep=25;
input int      StepMode=0; //0 - шаг равен ExtStep, 1 - шаг постепенно увеличивается
input ushort   InpProfitFactor=20;
input double   mult=1.5;
input double   LotsBuy=0.01;
input double   lotssell=0.01;
//input ushort   InpTrailingStop=25;
// ExtTrailingStop для паследнего ордера серии
input int      per_K=200;
input int      per_D=20;
input int      slow=20;
input double   zoneBUY=65;
input double   zoneSELL=70;
input bool     Reverse=false;             // revers signals
//---
ulong          m_magic=555;               // magic number
double         LastOpenVolimeBuy=0.0;     // last open volume "Buy"     
double         LastOpenVolimeSell=0.0;    // last open volume "Sell"
double         LastOpenPriceBuy=0.0;      // last open price "Buy"     
double         LastOpenPriceSell=0.0;     // last open price "Sell"
double         ExtStep=0.0;
double         ExtProfitFactor=0.0;
double         ExtTrailingStop=0.0;
int            handle_iStochastic;        // variable for storing the handle of the iStochastic indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
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
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtStep        = InpStep * digits_adjust;
   ExtProfitFactor= InpProfitFactor * digits_adjust;
//ExtTrailingStop= InpTrailingStop * digits_adjust;

//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(m_symbol.Name(),Period(),per_K,per_D,slow,MODE_LWMA,STO_CLOSECLOSE);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
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
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllBuy()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               m_trade.PositionClose(m_position.Ticket());
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllSell()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               m_trade.PositionClose(m_position.Ticket());
           }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//static datetime prev_time=0;
//datetime time_0=iTime(0);
//if(prev_time==time_0)
//   return;
//prev_time=time_0;
//---
   double profitbuy=0;double profitsell=0;
   double minLots=m_symbol.LotsMin();
   double maxLots=m_symbol.LotsMax();

   double TotalBuysVolume=0.0;
   double TotalSelslVolume=0.0;
   double TotalBuysProfit=0.0;
   double TotalSellsProfit=0.0;
   int    TotalBuys=0;
   int    TotalSells=0;

   TotalPositions(TotalBuysVolume,TotalSelslVolume,TotalBuysProfit,TotalSellsProfit,TotalBuys,TotalSells);

   if(TotalBuys>0)
     {
      if((TotalBuysVolume+LastOpenVolimeBuy*mult)<maxLots)
        {
         if(!RefreshRates())
            return;

         if(StepMode==0) // 0 - шаг равен ExtStep
           {
            if(m_symbol.Ask()<=LastOpenPriceBuy-ExtStep*Point()) // last position "Buy" has loss
              {
               double m_check=LotCheck(LastOpenVolimeBuy*mult);
               if(m_check!=0)
                 {
                  m_trade.Buy(m_check,m_symbol.Name(),m_symbol.Ask(),0.0,0.0,"MartingailExpert");
                 }
              }
           }
         if(StepMode==1) // 1 - шаг постепенно увеличивается
           {
            if(m_symbol.Ask()<=LastOpenPriceBuy-ExtStep*TotalBuys*Point())
              {
               double m_check=LotCheck(LastOpenVolimeBuy*mult);
               if(m_check!=0)
                 {
                  m_trade.Buy(m_check,m_symbol.Name(),m_symbol.Ask(),0.0,0.0,"MartingailExpert");
                 }
              }
           }
        }
     }
   if(TotalSells>0)
     {
      if((TotalSelslVolume+LastOpenVolimeSell*mult)<maxLots)
        {
         if(!RefreshRates())
            return;

         if(StepMode==0) // 0 - шаг равен ExtStep
           {
            if(m_symbol.Bid()>=LastOpenPriceSell+ExtStep*Point()) // last position "Sell" has loss
              {
               double m_check=LotCheck(LastOpenVolimeSell*mult);
               if(m_check!=0)
                 {
                  m_trade.Sell(m_check,m_symbol.Name(),m_symbol.Bid(),0.0,0.0,"MartingailExpert");
                 }
              }
           }
         if(StepMode==1) // 1 - шаг постепенно увеличивается
           {
            if(m_symbol.Bid()>=LastOpenPriceSell+ExtStep*TotalSells*Point())
              {
               double m_check=LotCheck(LastOpenVolimeSell*mult);
               if(m_check!=0)
                 {
                  m_trade.Sell(m_check,m_symbol.Name(),m_symbol.Bid(),0.0,0.0,"MartingailExpert");
                 }
              }
           }
        }
     }

   if(!RefreshRates())
      return;

//--- no open positions "Buy". Check the condition of entry in "Buy"
   if(TotalBuys<1)
     {
      if(iStochasticGet(MAIN_LINE,1)>iStochasticGet(SIGNAL_LINE,1) && iStochasticGet(SIGNAL_LINE,1)>zoneBUY)
        {
         if(!Reverse)
            m_trade.Buy(LotsBuy,m_symbol.Name(),m_symbol.Ask(),0.0,0.0,"MartingailExpert");
         else
            m_trade.Sell(lotssell,m_symbol.Name(),m_symbol.Bid(),0.0,0.0,"MartingailExpert");
         //return;
        }
     }

//--- no open positions "Sell". Check the condition of entry in "Sell"
   if(TotalSells<1)
     {
      if(iStochasticGet(MAIN_LINE,1)<iStochasticGet(SIGNAL_LINE,1) && iStochasticGet(SIGNAL_LINE,1)<zoneSELL)
        {
         if(!Reverse)
            m_trade.Sell(lotssell,m_symbol.Name(),m_symbol.Bid(),0.0,0.0,"MartingailExpert");
         else
            m_trade.Buy(LotsBuy,m_symbol.Name(),m_symbol.Ask(),0.0,0.0,"MartingailExpert");
         //return;
        }
     }

   double take_profit_buy=(TotalBuys*ExtProfitFactor*Point())+LastOpenPriceBuy;
   if(TotalBuysProfit>0)
     {
      if(m_symbol.Bid()>=take_profit_buy)
        {
         CloseAllBuy();
         //return;
        }
     }

   double take_profit_sell=LastOpenPriceSell-(TotalSells*ExtProfitFactor*Point());
   if(TotalSellsProfit>0)
     {
      if(m_symbol.Ask()<=take_profit_sell)
        {
         CloseAllSell();
         //return;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TotalPositions(double &total_volume_buy,double &total_volume_sell,
                    double &total_profit_buy,double &total_profit_sell,
                    int &total_buys,int &total_sells)
  {
   total_volume_buy=0.0;
   total_volume_sell=0.0;
   total_profit_buy=0.0;
   total_profit_sell=0.0;
   total_buys=0.0;
   total_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               total_volume_buy+=m_position.Volume();       // summation of volumes of positions
               total_profit_buy+=m_position.Profit();       // summation of profits of positions
               total_buys++;                                // summation quantity of "Buy" positions
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               total_volume_sell+=m_position.Volume();      // summation of volumes of positions
               total_profit_sell+=m_position.Profit();      // summation of profits of positions
               total_sells++;                               // summation quantity of "Sell" positions
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
   double res=0.0;
   int losses=0.0;
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_entry        =0;
      long     deal_type         =0;
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_type=HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price=HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
        {
         if(deal_entry==DEAL_ENTRY_IN) // deal entry "in"
           {
            if(deal_type==DEAL_TYPE_BUY) // there was a deal of "Buy"  
              {
               LastOpenVolimeBuy=deal_volume;   // volume of deal "Buy" 
               LastOpenPriceBuy=deal_price;     // price of deal "Buy" 
              }
            if(deal_type==DEAL_TYPE_SELL) // there was a deal of "Buy" 
              {
               LastOpenVolimeSell=deal_volume;  // volume of deal "Sell" 
               LastOpenPriceSell=deal_price;    // price of deal "Sell" 
              }
           }
         if(deal_entry==DEAL_ENTRY_OUT) // deal entry "out"
           {
            if(deal_type==DEAL_TYPE_BUY) // there was a deal of "Buy" -> was close "Sell" positions  
              {
               LastOpenVolimeSell=0.0;
               LastOpenPriceSell=0.0;
              }
            if(deal_type==DEAL_TYPE_SELL) // there was a deal of "Sell" -> was close "Buy" positions 
              {
               LastOpenVolimeBuy=0.0;
               LastOpenPriceBuy=0.0;
              }
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
   double stepvol=SymbolInfoDouble(m_symbol.Name(),SYMBOL_VOLUME_STEP);
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=SymbolInfoDouble(m_symbol.Name(),SYMBOL_VOLUME_MIN);
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=SymbolInfoDouble(m_symbol.Name(),SYMBOL_VOLUME_MAX);
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
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
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int buffer,const int index)
  {
   double Stochastic[];
   ArraySetAsSeries(Stochastic,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic,buffer,0,index+1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[index]);
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
