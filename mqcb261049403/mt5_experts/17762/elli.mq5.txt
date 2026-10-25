//+------------------------------------------------------------------+
//|                                Elli(barabashkakvn's edition).mq5 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedRisk m_money;
//---
input ushort   TakeProfit        = 60;
input ushort   StopLoss          = 30;
input double   Risk              = 5;
input ulong    m_magic=5101979;

input int      tenkan            = 19;
input int      kijun             = 60;
input int      senkou_b          = 120;
input int      po                = 20;

input ENUM_TIMEFRAMES adx_timeframe=PERIOD_M1;
input int      adx_period        = 10;             //6
input int      convert_high      = 13;             //7-20
input int      convert_low       = 6;              //1-7
//---
ulong          m_slippage=30;             // Проскальзывание цены
//---
bool           UseSound          = true;           // Использовать звуковой сигнал
string         NameFileSound     = "expert.wav";   // Наименование звукового файла
//---
int            handle_iADX;                        // variable for storing the handle of the iADX indicator 
int            handle_iIchimoku;                   // variable for storing the handle of the iIchimoku indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;                   // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(Risk); //  risk
//--- create handle of the indicator iADX
   handle_iADX=iADX(m_symbol.Name(),adx_timeframe,adx_period);
//--- if the handle is not created 
   if(handle_iADX==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iADX indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iIchimoku
   handle_iIchimoku=iIchimoku(m_symbol.Name(),PERIOD_H1,tenkan,kijun,senkou_b);
//--- if the handle is not created 
   if(handle_iIchimoku==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iIchimoku indicator for the symbol %s/%s, error code %d",
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
//---
   double sl=0.0,tp=0.0;

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if(total<1)
     {
      int signal=Signal();

      if(signal!=0)
        {
         if(!IsTradeAllowed())
           {
            Sleep(5000);
            if(!IsTradeAllowed())
               return;
           }
        }

      if(signal==1)
        {
         if(!RefreshRates())
            return;
         if(StopLoss>0)
            sl=m_symbol.Ask()-StopLoss*m_adjusted_point;
         if(TakeProfit>0)
            tp=m_symbol.Ask()+TakeProfit*m_adjusted_point;
         OpenBuy(sl,tp);
        }

      else if(signal==-1)
        {
         if(!RefreshRates())
            return;
         if(StopLoss>0)
            sl=m_symbol.Bid()+StopLoss*m_adjusted_point;
         if(TakeProfit>0)
            tp=m_symbol.Bid()-TakeProfit*m_adjusted_point;
         OpenSell(sl,tp);
        }
     }
  }
//+------------------------------------------------------------------+
//| Signal                                                           |
//+------------------------------------------------------------------+
int Signal()
  {
   double adx_plus_0 = iADXGet(PLUSDI_LINE,0);
   double adx_plus_1 = iADXGet(PLUSDI_LINE,1);
//double adx_minus_0 = iADX(NULL,adx_timeframe,adx_period,0);
//double adx_minus_1 = iADX(NULL,adx_timeframe,adx_period,1);

   double ts=iIchimokuGet(KIJUNSEN_LINE,0);
   double ks = iIchimokuGet(SENKOUSPANA_LINE,0);
   double sa = iIchimokuGet(SENKOUSPANB_LINE,0);
   double sb = iIchimokuGet(CHIKOUSPAN_LINE,0);
   double close=iClose(0,m_symbol.Name(),PERIOD_H1);
   double cf=MathAbs(ts-ks)/m_symbol.Point();

   int ytg_Signal=0;

   if(ts>ks && ks>sa && sa>sb && close>ks && adx_plus_1<convert_low && adx_plus_0>convert_high && cf>po)
     {
      ytg_Signal=1;
      RefreshRates();
     }
   else if(ts<ks && ks<sa && sa<sb && close<ks && adx_plus_1<convert_low && adx_plus_0>convert_high && cf>po)
     {
      //if(ts<ks && ks<sa && sa<sb && close<ks && adx_minus_1<convert_low && adx_minus_0>convert_high && cf>po)
      ytg_Signal=-1;
      RefreshRates();
     }
   return (ytg_Signal);
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
//| Get value of buffers for the iADX                                |
//|  the buffer numbers are the following:                           |
//|    0 - MAIN_LINE, 1 - PLUSDI_LINE, 2 - MINUSDI_LINE              |
//+------------------------------------------------------------------+
double iADXGet(const int buffer,const int index)
  {
   double ADX[];
   ArraySetAsSeries(ADX,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iADX,buffer,0,index+1,ADX)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ADX[index]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iIchimoku                           |
//|  the buffer numbers are the following:                           |
//|   0 - TENKANSEN_LINE, 1 - KIJUNSEN_LINE, 2 - SENKOUSPANA_LINE,   |
//|   3 - SENKOUSPANB_LINE, 4 - CHIKOUSPAN_LINE                      |
//+------------------------------------------------------------------+
double iIchimokuGet(const int buffer,const int index)
  {
   double Ichimoku[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iIchimoku array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iIchimoku,buffer,index,1,Ichimoku)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iIchimoku indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Ichimoku[0]);
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);
   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               if(UseSound)
                  PlaySound(NameFileSound);
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);
   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               if(UseSound)
                  PlaySound(NameFileSound);
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
