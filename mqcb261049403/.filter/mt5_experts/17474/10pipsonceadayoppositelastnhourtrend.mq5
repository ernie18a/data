//+------------------------------------------------------------------+
//|10pipsOnceADayOppositeLastNHourTrend(barabashkakvn's edition).mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "slacktrader"
#property link      ""

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object

int      TIMEFRAME=0;
int      MAXPOS=1;

int      TRADINGDAYHOURS[]={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};

//Expert Settings
extern double   FIXLOT            = 0.1;      //if 0, uses maximumrisk, else uses only this while trading
extern double   MINLOTS           = 0.1;      //minimum lot
extern double   MAXLOTS           = 5;        //maximum lot
extern double   MAXIMUMRISK       = 0.05;     //maximum risk, if FIXLOT = 0
extern int      SLIPPAGE          = 3;        //max slippage alowed

extern int      TRADINGHOUR       = 7;        //time when position should be oppened
extern int      HOURSTOCHECKTREND  = 30;      //amount of hours to check price difference to see a "trend"
extern int      POSMAXAGE=75600;    //max age of position - closes older positions

extern int      FIRSTMULTIPLICATOR   = 4;     //multiply lots when position -1 was loss
extern int      SECONDMULTIPLICATOR  = 2;     //multiply lots when position -2 was loss
extern int      THIRDMULTIPLICATOR   = 5;     //multiply lots when position -3 was loss
extern int      FOURTHMULTIPLICATOR  = 5;     //multiply lots when position -4 was loss
extern int      FIFTHMULTIPLICATOR   = 1;     //multiply lots when position -5 was loss

extern double   STOPLOSS          = 50;       //SL
extern double   TRAILINGSTOP      = 0;        //
extern double   TAKEPROFIT        = 10;       //TP

                                              //Globals
datetime LastBarTraded=0;
ulong          m_magic=35656889;                // magic numberENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
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
   CheckForClosePositions();
   CheckForModifyPositions();
   if(TradeAllowed())
      OpenPosition(CheckForOpenPosition(),GetLots());
  }
//+------------------------------------------------------------------+
//| TradeAllowed function return true if trading is possible         |
//+------------------------------------------------------------------+
bool TradeAllowed()
  {
//--- Trade only once on each bar
   if(LastBarTraded==iTime(0))
      return(false);
//--- Trade only open price of current hour
   if(iTickVolume(0,NULL,PERIOD_H1)>1)
      return(false);
   if(!IsTradeAllowed())
      return(false);
//---
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
   if(total>=MAXPOS)
      return(false);
   if(!IsTradingHour())
     {
      CheckForClosePositions();
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradingHour()
  {
   int i;
   bool istradinghour=false;

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   for(i=0; i<ArraySize(TRADINGDAYHOURS); i++)
     {
      if(TRADINGDAYHOURS[i]==str1.hour)
        {
         istradinghour=true;
         break;
        }
     }
   return(istradinghour);
  }
//+------------------------------------------------------------------+
//| Get amount of lots to trade                                      |
//+------------------------------------------------------------------+
double GetLots()
  {
   double lot=0.0;
   if(FIXLOT==0)
      lot=NormalizeDouble(m_account.FreeMargin()*MAXIMUMRISK/1000.0,1);
   else
      lot=FIXLOT;

//--- история за последние 7 календарных дней
//--- 60(кол-во секунд в минуте) * 60 (кол-во минут в часе) * 24 (кол-во часов в сутках) * 7 (семь дней)
   datetime from_date=TimeCurrent()-60*60*24*7;
   datetime to_date=TimeCurrent()+60*60*24;
//--- request trade history 
   HistorySelect(from_date,to_date);
   for(int i=HistoryDealsTotal()-1;i>=0;i--) // returns the number of history deals
      if(m_deal.SelectByIndex(i)) // selects the history deal by index for further access to its properties
         if(m_deal.Symbol()==m_symbol.Name() && m_deal.Magic()==m_magic)
            if(m_deal.Entry()==DEAL_ENTRY_OUT)
              {
               static int count=1;
               if(m_deal.Profit()>0)
                  break;
               if(m_deal.Profit()<0)
                 {
                  if(count==1)
                     lot*=FIRSTMULTIPLICATOR;
                  if(count==2)
                     lot*=SECONDMULTIPLICATOR;
                  if(count==3)
                     lot*=THIRDMULTIPLICATOR;
                  if(count==4)
                     lot*=FOURTHMULTIPLICATOR;
                  if(count==5)
                    {
                     lot*=FIFTHMULTIPLICATOR;
                     break;
                    }
                 }
               count++;
              }

   if(lot>NormalizeDouble(m_account.FreeMargin()/1000.0,1))
      lot=NormalizeDouble(m_account.FreeMargin()/1000.0,1);

   if(lot<MINLOTS)
      lot=MINLOTS;
   else if(lot>MAXLOTS)
      lot=MAXLOTS;

   return(lot);
  }
//+------------------------------------------------------------------+
//| Checks of open short, long or nothing (-1, 1, 0)                 |
//+------------------------------------------------------------------+
int CheckForOpenPosition()
  {
   int result=0;

//--- Trade only this hour in a day - once a day at this time
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(str1.hour!=TRADINGHOUR)
      return(result);

//--- Long if last N hour was bearish - short when last N hour was bullish
   if(iClose(HOURSTOCHECKTREND,NULL,PERIOD_H1)>iClose(1,NULL,PERIOD_H1))
      result=1;
   else
      result=-1;

//---
   return(result);
  }
//+------------------------------------------------------------------------------------+
//| Opens position according to arguments (-1 short || 1 long, amount of Lots to trade |
//+------------------------------------------------------------------------------------+
void OpenPosition(int ShortLong,double Lots)
  {
   if(!RefreshRates())
      return;

   double SL=0.0;
   double TP=0.0;
   if(ShortLong==-1)
     {
      if(STOPLOSS!=0)
         SL=m_symbol.Bid()+STOPLOSS*m_adjusted_point;
      else
         SL=0;
      if(TAKEPROFIT!=0)
         TP=m_symbol.Bid()-TAKEPROFIT*m_adjusted_point;
      else
         TP=0;
      m_trade.Sell(Lots,NULL,m_symbol.Bid(),SL,TP,TimeToString(iTime(0),TIME_DATE|TIME_MINUTES));
     }
   else if(ShortLong==1)
     {
      if(STOPLOSS!=0)
         SL=m_symbol.Ask()-STOPLOSS*m_adjusted_point;
      else
         SL=0;
      if(TAKEPROFIT!=0)
         TP=m_symbol.Ask()+TAKEPROFIT*m_adjusted_point;
      else
         TP=0;
      m_trade.Buy(Lots,NULL,m_symbol.Ask(),SL,TP,TimeToString(iTime(0),TIME_DATE|TIME_MINUTES));
     }
   if(ShortLong!=0)
      LastBarTraded=iTime(0);
  }
//+------------------------------------------------------------------------------------+
//| Closes position based on indicator state                                           |
//+------------------------------------------------------------------------------------+
void CheckForClosePositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.Time()+POSMAXAGE<TimeCurrent())
               m_trade.PositionClose(m_position.Ticket());
//---
   return;
  }
//+------------------------------------------------------------------------------------+
//| Modify positions - Stoploss based on Trailing stop                                            |
//+------------------------------------------------------------------------------------+
void CheckForModifyPositions()
  {
   if(!RefreshRates())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(TRAILINGSTOP>0)
                  if(m_symbol.Bid()-m_position.PriceOpen()>m_adjusted_point*TRAILINGSTOP)
                     if(m_position.StopLoss()<m_symbol.Bid()-m_adjusted_point*TRAILINGSTOP)
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Bid()-m_adjusted_point*TRAILINGSTOP,
                                               m_position.TakeProfit());
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(TRAILINGSTOP>0)
                  if(m_symbol.Ask()+m_position.PriceOpen()<m_adjusted_point*TRAILINGSTOP)
                     if(m_position.StopLoss()>m_symbol.Ask()+m_adjusted_point*TRAILINGSTOP)
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Ask()+m_adjusted_point*TRAILINGSTOP,
                                               m_position.TakeProfit());
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
