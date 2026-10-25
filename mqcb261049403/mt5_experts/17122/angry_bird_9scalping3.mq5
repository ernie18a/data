//+------------------------------------------------------------------+
//|               Angry Bird (Scalping)(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "" 
#property link      ""
#property version "1.002"

#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_CLOSE 3

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
//--- input parameters
input ushort   InpStoploss    = 500;         // уровень безубытка
input ushort   InpMinProfitPoint  = 10;      // MinProfitPoint
input ushort   InpTrailStep   = 10;          // TrailStep
input double   LotExponent    = 1.62;        // Увеличение лота для следующего колена
input ushort   InpDefaultPips = 12;          // DefaultPips
input int      Glubina        = 24;          // Glubina
input double   DEL            = 3;           // DEL ???
input ulong    InpSlippage    = 3;           // на сколько может отличаться цена в случае если ДЦ запросит реквоты (в последний момент немного поменяет цену)
input double   Lots           = 0.01;        // разер лота для начала торгов
input int      lotdecimal     = 2;           // сколько знаков после запятой в лоте рассчитывать 0 - нормальные лоты (1), 1 - минилоты (0.1), 2 - микро (0.01)
input ushort   InpTakeProfit  = 20;          // по достижении скольких пунктов прибыли закрывать сделку
input double   CCI_Drop       = 500;
input double   RSI_min        = 30.0;        // нижняя граница RSI
input double   RSI_max        = 70.0;        // верхняя граница RSI
input ulong    m_magic        = 2222;        // волшебное число (помогает советнику отличить свои ставки от чужих)
input int      MaxTrades      = 10;          // максимально количество одновременно открытых ордеров
input bool     UseEquityStop  = false;
input double   TotalEquityRisk= 20.0;
input bool     UseTrailingStop= false;
input double   MaxTradeOpenHours=48.0;       // время таймаута сделок в часах (через сколько закрывать зависшие сделки)
//---
bool   LongTrade = false;                    // true -> last open trade is Buy
bool   ShortTrade = false;                   // true -> last open trade is Sell
double LastOpenBuyPrice = 0.0;               // last open "Buy" price
double LastOpenSellPrice = 0.0;              // last open "Sell" price
bool   NewOrdersPlaced=false;
bool   flag=false;
bool   TradeNow=false;
string EAName="Ilan1.6";
//---
double ExtStoploss=0.0;
double ExtMinProfitPoint=0;
double ExtTrailStep=0.0;
double ExtDefaultPips=0.0;
ulong  ExtSlippage=0;
double ExtTakeProfit=0.0;
int    handle_iCCI;                          // variable for storing the handle of the iCCI indicator 
int    handle_iRSI;                          // variable for storing the handle of the iRSI indicator 
int    digits_adjust=1;
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
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtStoploss=InpStoploss*digits_adjust;
   ExtMinProfitPoint=InpMinProfitPoint*digits_adjust;
   ExtTrailStep   = InpTrailStep * digits_adjust;
   ExtDefaultPips = InpDefaultPips * digits_adjust;
   ExtSlippage    = InpSlippage * digits_adjust;
   ExtTakeProfit  = InpTakeProfit * digits_adjust;

   m_trade.SetDeviationInPoints(ExtSlippage);

//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(Symbol(),PERIOD_M15,55,PRICE_CLOSE);
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
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(PERIOD_H1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   LongTrade=false;                          // true -> last open trade is Buy
   ShortTrade=false;                         // true -> last open trade is Sell
   LastOpenBuyPrice = 0.0;                   // last open "Buy" price
   LastOpenSellPrice = 0.0;                  // last open "Sell" price
   NewOrdersPlaced=false;
   flag=false;
   TradeNow=false;
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
//--- calculate highest and lowest price from last bar to "Glubina" bars ago
   double high_val=iHigh(m_symbol.Name(),Period(),iHighest(m_symbol.Name(),Period(),MODE_HIGH,Glubina,1));
   double low_val=iLow(m_symbol.Name(),Period(),iLowest(m_symbol.Name(),Period(),MODE_LOW,Glubina,1));
//--- calculate pips for spread between positions
   double PipStep=NormalizeDouble((high_val-low_val)/Point()/digits_adjust,0);
   if(PipStep<ExtDefaultPips)
      PipStep=ExtDefaultPips;

//if(PipStep>ExtDefaultPips*DEL)
//   PipStep=NormalizeDouble(ExtDefaultPips*DEL,0); // if dynamic pips fail, assign pips extreme value

   double PrevCl=0.0;
   double CurrCl=0.0;

   double AveragePrice=CalculationAveragePrice();

   if(UseTrailingStop && AveragePrice!=0.0)
      TrailingAlls(ExtMinProfitPoint,ExtTrailStep,AveragePrice);

   if((iCCIGet(0)>CCI_Drop && ShortTrade) || (iCCIGet(0)<(-CCI_Drop) && LongTrade)) // !!! ShortTrade and LongTrade
     {
      CloseThisSymbolAll();
      Print("Closed All CCI_Drop");
      return;
     }

   static datetime timeprev=0;
   if(timeprev==iTime(m_symbol.Name(),Period(),0))
      return;
   timeprev=iTime(m_symbol.Name(),Period(),0);

   double iLots=0.0;
   double CurrentPairProfit=CalculateProfit();
   if(UseEquityStop)
     {
      if(CurrentPairProfit<0.0 && MathAbs(CurrentPairProfit)>TotalEquityRisk*m_account.Equity()/100.0)
        {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         NewOrdersPlaced=false;
         return;
        }
     }

   int count_trades=CountTrades();
   if(count_trades==0) // ???
      flag=false;

   if(count_trades>0 && count_trades<=MaxTrades)
     {
      if(!RefreshRates())
         return;

      if(LongTrade && LastOpenBuyPrice-m_symbol.Ask()>=PipStep*Point())
         TradeNow=true;

      if(ShortTrade && m_symbol.Bid()-LastOpenSellPrice>=PipStep*Point())
         TradeNow=true;
     }

   if(count_trades<1)
     {
      ShortTrade= false;
      LongTrade = false;
      TradeNow=true;
     }

   if(TradeNow)
     {
      if(ShortTrade)
        {
         iLots=NormalizeDouble(Lots*MathPow(LotExponent,count_trades),lotdecimal);
         if(!RefreshRates())
            return;

         if(!m_trade.Sell(iLots,Symbol(),m_symbol.Bid(),0.0,0.0,EAName+"-"+IntegerToString(count_trades)+"-"+DoubleToString(PipStep,0)))
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
            return;
           }
         TradeNow=false;
         NewOrdersPlaced=true;
         return;
        }

      if(LongTrade)
        {
         iLots=NormalizeDouble(Lots*MathPow(LotExponent,count_trades),lotdecimal);
         if(!RefreshRates())
            return;

         if(!m_trade.Buy(iLots,Symbol(),m_symbol.Ask(),0.0,0.0,EAName+"-"+IntegerToString(count_trades)+"-"+DoubleToString(PipStep,0)))
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
            return;
           }
         TradeNow=false;
         NewOrdersPlaced=true;
         return;
        }
     }

   if(TradeNow && count_trades<1)
     {
      PrevCl = iClose(m_symbol.Name(),Period(),2);
      CurrCl = iClose(m_symbol.Name(),Period(),1);

      if(!ShortTrade && !LongTrade)
        {
         iLots=NormalizeDouble(Lots*MathPow(LotExponent,count_trades),lotdecimal);
         if(PrevCl>CurrCl)
           {
            if(iRSIGet(1)>RSI_min)
              {
               if(!RefreshRates())
                  return;

               if(!m_trade.Sell(iLots,Symbol(),m_symbol.Bid(),0.0,0.0,EAName+"-"+IntegerToString(count_trades)))
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  return;
                 }
               TradeNow=false;
               NewOrdersPlaced=true;
               return;
              }
            if(iRSIGet(1)<RSI_max)
              {
               if(!RefreshRates())
                  return;

               if(!m_trade.Buy(iLots,Symbol(),m_symbol.Ask(),0.0,0.0,EAName+"-"+IntegerToString(count_trades)))
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of deal: ",m_trade.ResultDeal());
                  return;
                 }
               TradeNow=false;
               NewOrdersPlaced=true;
               return;
              }
           }
        }
     }

//CalculationAveragePrice(); // ????????

   double PriceTarget=0.0;
   double BuyTarget=0.0;
   double Stopper=0.0;

   if(NewOrdersPlaced)
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  PriceTarget=AveragePrice+ExtTakeProfit*Point();

                  if(!RefreshRates())
                     return;

                  //--- если текущая цена лучше PriceTarget
                  if(m_symbol.Bid()>PriceTarget)
                     m_trade.PositionClose(m_position.Ticket());
                  else
                    {
                     Stopper=AveragePrice-ExtStoploss*Point();
                     m_trade.PositionModify(m_position.Ticket(),NormalizeDouble(Stopper,Digits()),NormalizeDouble(PriceTarget,Digits()));
                    }
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  PriceTarget=AveragePrice-ExtTakeProfit*Point();

                  if(!RefreshRates())
                     return;

                  //--- если текущая цена лучше PriceTarget
                  if(m_symbol.Ask()<PriceTarget)
                     m_trade.PositionClose(m_position.Ticket());
                  else
                    {
                     Stopper=AveragePrice+ExtStoploss*Point();
                     m_trade.PositionModify(m_position.Ticket(),NormalizeDouble(Stopper,Digits()),NormalizeDouble(PriceTarget,Digits()));
                    }
                 }
              }
      NewOrdersPlaced=false;
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            total++;

   return (total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateProfit()
  {
   double profit=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            profit+=m_position.Profit();

   return (profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingAlls(double profit_point,double step,double average_price)
  {
   double profit=0; // profit in points
   if(step!=0)
     {
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  //--- calculate profit in points
                  profit=NormalizeDouble((m_symbol.Bid()-average_price)/Point()/digits_adjust,0);
                  if(profit<profit_point)
                     continue;

                  if(m_position.StopLoss()==0.0 || 
                     (m_position.StopLoss()!=0.0 && m_symbol.Bid()-step*Point()>m_position.StopLoss()))
                     m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-step*Point(),m_position.TakeProfit());
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  //--- calculate profit in points
                  profit=NormalizeDouble((average_price-m_symbol.Ask())/Point()/digits_adjust,0);
                  if(profit<profit_point)
                     continue;

                  if(m_position.StopLoss()==0.0 || 
                     (m_position.StopLoss()!=0.0 && m_symbol.Ask()+step*Point()<m_position.StopLoss()))
                     m_trade.PositionModify(m_position.Ticket(),m_symbol.Ask()+step*Point(),m_position.TakeProfit());
                 }
              }
     }
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
      long     deal_type         =0;
      double   deal_price        =0.0;
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_type=HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_price=HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==Symbol() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
           {
            if(deal_type==DEAL_TYPE_BUY)
              {
               LongTrade=true;               // true -> last open trade is Buy
               ShortTrade=false;             // true -> last open trade is Sell
               LastOpenBuyPrice=deal_price;  // last open "Buy" price
              }
            if(deal_type==DEAL_TYPE_SELL)
              {
               LongTrade=false;              // true -> last open trade is Buy
               ShortTrade=true;              // true -> last open trade is Sell
               LastOpenSellPrice=deal_price; // last open "Sell" price
              }
           }
      if(deal_entry==DEAL_ENTRY_OUT)
        {
         if(deal_type==DEAL_TYPE_BUY) // close the "Sell" positions
           {
            ShortTrade=false;
            LastOpenSellPrice=0.0;
           }
         if(deal_type==DEAL_TYPE_SELL) // close the "Buy" positions
           {
            LongTrade=false;
            LastOpenBuyPrice=0.0;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Calculation Average Price all open positions                     |
//+------------------------------------------------------------------+
double CalculationAveragePrice()
  {
   double aver_price=0.0;
   double volume=0.0;

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            total++;
            aver_price+=m_position.PriceOpen()*m_position.Volume();
            volume+=m_position.Volume();
           }
   if(total>0)
      aver_price=NormalizeDouble(aver_price/volume,Digits());

   return(aver_price);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iRSI                                |
//+------------------------------------------------------------------+
double iRSIGet(const int index)
  {
   double RSI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iDeMarker array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,0,index,1,RSI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RSI[0]);
  }
//+------------------------------------------------------------------+
