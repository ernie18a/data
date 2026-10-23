//+------------------------------------------------------------------+
//|                         Gandalf_PRO(barabashkakvn's edition).mq5 |
//|                                                          budimir |
//|                                              tartar27@bigmir.net |
//+------------------------------------------------------------------+
#property copyright "budimir"
#property link      "tartar27@bigmir.net"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh> 
#include <Trade\AccountInfo.mqh> 
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---- input parameters
input bool      In_BUY=true;
int             Count_buy=24;
input double    w_price=0.18;
input double    w_trend=0.18;
input int       SL_buy=62;
input int       Risk_buy=0;
input bool      In_SELL=true;
int             Count_sell=24;
input double    m_price=0.18;
input double    m_trend=0.18;
input int       SL_sell=62;
input int       Risk_sell=0;
//--- other parameters
static datetime  prevtime=0;
ulong Magic_BUY  =123;
ulong Magic_SELL =321;
//---
int    handle_iMA_Count_buy_LWMA;               // variable for storing the handle of the iMA indicator 
int    handle_iMA_Count_buy_SMA;                // variable for storing the handle of the iMA indicator 
int    handle_iMA_Count_sell_LWMA;              // variable for storing the handle of the iMA indicator 
int    handle_iMA_Count_sell_SMA;               // variable for storing the handle of the iMA indicator 
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
   m_symbol.Refresh();
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iMA
   handle_iMA_Count_buy_LWMA=iMA(Symbol(),Period(),Count_buy,0,MODE_LWMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Count_buy_LWMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Count_buy_SMA=iMA(Symbol(),Period(),Count_buy,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Count_buy_SMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Count_sell_LWMA=iMA(Symbol(),Period(),Count_sell,0,MODE_LWMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Count_sell_LWMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Count_sell_SMA=iMA(Symbol(),Period(),Count_sell,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Count_sell_SMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
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
   if(iTime(0)==prevtime)
      return;
   prevtime=iTime(0);

   if(!IsTradeAllowed())
     {
      prevtime=iTime(1);
      MathSrand((int)TimeCurrent());
      Sleep(30000+MathRand());
     }

   if(In_BUY)
      Trade_BUY(Magic_BUY,Count_buy,w_price,w_trend,SL_buy);

   if(In_SELL)
      Trade_SELL(Magic_SELL,Count_sell,m_price,m_trend,SL_sell);

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade_BUY(ulong mn,int num,double factor1,double factor2,int sl)
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==mn)
            return;

   if(!RefreshRates())
      return;

   double target=Out(num,factor1,factor2);

   if(target>(m_symbol.Bid()+15*m_adjusted_point) && IsTradeAllowed())
     {
      m_trade.SetExpertMagicNumber(mn);

      if(!m_trade.Buy(lot(Risk_buy),Symbol(),m_symbol.Ask(),
         m_symbol.NormalizePrice(m_symbol.Ask()-sl*m_adjusted_point),
         target,DoubleToString(mn,0)))
        {
         Sleep(30000);
         prevtime=iTime(1);
        }
     } //-- Exit ---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade_SELL(ulong mn,int num,double factor1,double factor2,int sl)
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==mn)
            return;

   if(!RefreshRates())
      return;

   double target=Out(num,factor1,factor2);

   if(target<(m_symbol.Ask()-15*m_adjusted_point) && IsTradeAllowed())
     {
      m_trade.SetExpertMagicNumber(mn);

      if(!m_trade.Sell(lot(Risk_sell),Symbol(),m_symbol.Bid(),
         m_symbol.NormalizePrice(m_symbol.Ask()+sl*m_adjusted_point),
         target,DoubleToString(mn,0)))
        {
         Sleep(30000);
         prevtime=iTime(1);
        }
     } //-- Exit ---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Out(int n,double l1,double l2)
  {
   double t[120];
   double s[120];
   double lm=0.0;
   double sm=0.0;

   if(n==Count_buy)
     {
      lm=iMAGet(handle_iMA_Count_buy_LWMA,1);
      sm=iMAGet(handle_iMA_Count_buy_SMA,1);
     }

   if(n==Count_sell)
     {
      lm=iMAGet(handle_iMA_Count_sell_LWMA,1);
      sm=iMAGet(handle_iMA_Count_sell_SMA,1);
     }

   t[n]=(6*lm-6*sm)/(n-1);
   s[n]=4*sm-3*lm-t[n];

   for(int k=n-1; k>0; k--)
     {
      s[k]=l1*iClose(k)+(1-l1)*(s[k+1]+t[k+1]);
      t[k]=l2*(s[k]-s[k+1])+(1-l2)*t[k+1];
     }

   return(NormalizeDouble(s[1]+t[1],Digits()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lot(int R)
  {
   double minlot=m_symbol.LotsMin();
   int o=(int)(MathAbs(MathLog(minlot) *0.4343)+0.5);
   double lot=minlot;

   double MarginCheck=m_account.MarginCheck(Symbol(),ORDER_TYPE_BUY,1.0,m_symbol.Ask());

   lot=NormalizeDouble(m_account.FreeMargin()*0.00001*R,o);//---
   if(m_account.FreeMargin()<lot*MarginCheck)
     {
      lot=NormalizeDouble(m_account.FreeMargin()/MarginCheck,o);
     }

   if(lot<minlot)
      lot=minlot;

   double maxlot=m_symbol.LotsMax();

   if(lot>maxlot)
      lot=maxlot;

   return(lot);
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle,const int index)
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
