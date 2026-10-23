//+------------------------------------------------------------------+
//|                        UmnickTrader(barabashkakvn's edition).mq5 |
//|                              © 2009 Umnick. All rights reserved. |
//|                                            http://www.umnick.com |
//+------------------------------------------------------------------+
#property copyright "© 2009 Umnick. All rights reserved."
#property link      "http://www.umnick.com"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedRisk m_money;
//---- input parameters
input double   StopBase       = 0.0170;
input double   InpLots        = 0.1;         // размер лота
input ulong    m_magic        = 15489;       // magic number
input ulong    m_slippage     = 10;          // slippage
input double   spred          = 0.0005;      // размер спрэда
int currentBuySell=1;
double pricePrev=0;
double equityPrev=0;

bool isOpenPosition=false;
double arrayProfit[8];
double arrayLoss[8];
int currentIndex= 0;
double drawDown = 0;
double maxProfit= 0;
string currentIdOrder="1";ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
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
   m_trade.SetExpertMagicNumber(m_magic);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//---
   ArrayInitialize(arrayProfit,0.0);
   ArrayInitialize(arrayLoss,0.0);
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
   string action= "";
   double limit = StopBase,stop = StopBase;
   double sumProfit=0.,sumLoss=0.;
   int i;

   CalcDrawDown();
   if(NextBar())
     {
      //--- разрешение на анализ при открытии следующей позиции
      if(CalculatePositions()==0)
        {
         //--- открытых позиций нет - проверяем результат последней сделки
         double resultTransaction=m_account.Equity()-equityPrev;
         equityPrev=m_account.Equity();
         if(isOpenPosition)
           {
            //--- позиция была открыта - закрылась
            isOpenPosition=false;
            if(resultTransaction>0)
              {
               //--- последняя сделка прибыльная
               arrayProfit[currentIndex]=maxProfit-spred*3;
               arrayLoss[currentIndex]=StopBase+spred*7;
              }
            else
              {
               // последняя сделка убыточная
               arrayProfit[currentIndex]=StopBase-spred*3;
               arrayLoss[currentIndex]=drawDown+spred*7;
               // изменяем направление сделок
               currentBuySell=-currentBuySell;
              }
            if(currentIndex+1<8)
               currentIndex=currentIndex+1;
            else
               currentIndex=0;
           }
         // вычисляем лимиты и стопы
         sumProfit=0.;
         sumLoss=0.;
         for(i=0; i<8; i++)
           {
            sumProfit=sumProfit+arrayProfit[i];
            sumLoss=sumLoss+arrayLoss[i];
           }
         if(sumProfit>StopBase/2)
            limit=sumProfit/8;
         if(sumLoss>StopBase/2)
            stop=sumLoss/8;
         // открываем новую позицию
         if(currentBuySell==1)
            action="Buy";
         else
            action="Sell";
         ActionPosition(action,currentIdOrder,InpLots,limit,stop);
         if(CalculatePositions()>0)
           {
            // позиция открылась
            isOpenPosition=true;
            maxProfit= 0;
            drawDown = 0;
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NextBar()
  {
   bool rt=false;
   double price=(iOpen(1)+iHigh(1)+iLow(1)+iClose(1))/4;
   if(MathAbs(price-pricePrev)>=StopBase)
     {
      pricePrev=price;
      rt=true;
     }
   return(rt);
  }
//+------------------------------------------------------------------+
//| Подсчёт позиций Buy и Sell                                       |
//+------------------------------------------------------------------+
int CalculatePositions()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Определении максимальной прибыли и максимальной просадки         |
//+------------------------------------------------------------------+
void CalcDrawDown()
  {
   double openPrice=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            openPrice=m_position.PriceOpen();
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(maxProfit<iHigh(0)-openPrice)
                  maxProfit=iHigh(0)-openPrice;
               if(drawDown<openPrice-iLow(0))
                  drawDown=openPrice-iLow(0);
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(maxProfit<openPrice-iLow(0))
                  maxProfit=openPrice-iLow(0);
               if(drawDown<iHigh(0)-openPrice)
                  drawDown=iHigh(0)-openPrice;
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionPosition(string action,string idSignal,double amount,double limit,double stop)
  {
   double price=0.;

   if(action=="Buy")
     {
      //-- покупаем
      for(int i=0; i<7; i++)
        {
         if(IsTradeAllowed())
           {
            if(!RefreshRates())
               return;
            double sl=m_symbol.NormalizePrice(m_symbol.Ask()-stop);
            double tp=m_symbol.NormalizePrice(m_symbol.Ask()+limit);

            if(m_trade.Buy(amount,NULL,m_symbol.Ask(),sl,tp,idSignal))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  PlaySound("disconnect.wav");
                 }
               else
                 {
                  Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  PlaySound("ok.wav");
                 }
              }
            else
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PlaySound("disconnect.wav");
              }

           }
         Sleep(10000);
        }
     }
   else if(action=="BuyClose")
     {
      //--- закрываем покупки
      ClosePositions(POSITION_TYPE_BUY);
     }
   else if(action=="Sell")
     {
      //--- продаём
      for(int i=0; i<7; i++)
        {
         if(IsTradeAllowed())
           {
            if(!RefreshRates())
               return;
            double sl=m_symbol.NormalizePrice(m_symbol.Bid()+stop);
            double tp=m_symbol.NormalizePrice(m_symbol.Bid()-limit);

            if(m_trade.Sell(amount,NULL,m_symbol.Bid(),sl,tp,idSignal))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  PlaySound("disconnect.wav");
                 }
               else
                 {
                  Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  PlaySound("ok.wav");
                 }
              }
            else
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PlaySound("disconnect.wav");
              }

           }
         Sleep(10000);
        }
     }
   else if(action=="SellClose")
     {
      //--- закрываем продажи
      ClosePositions(POSITION_TYPE_SELL);
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
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
