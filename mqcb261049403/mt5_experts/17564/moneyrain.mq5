//+------------------------------------------------------------------+
//|                           MoneyRain(barabashkakvn's edition).mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---- input parameters
input int      ma_period_DeMarker=31;    // период усреднения DeMarker
input ushort   InpTakeProfit=5;    // TakeProfit   
input ushort   InpStopLoss          = 20;    // StopLoss
input double   InpLots              = 0.01;  // Lots
input int      losseslimit=1000000;
input bool     fastoptimize=false;
datetime       prevtime=0;
int            losses=0;
//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=10;                // slippage

int            handle_iDeMarker;             // variable for storing the handle of the iDeMarker indicator 
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
//--- create handle of the indicator iDeMarker
   handle_iDeMarker=iDeMarker(m_symbol.Name(),Period(),ma_period_DeMarker);
//--- if the handle is not created 
   if(handle_iDeMarker==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iDeMarker indicator for the symbol %s/%s, error code %d",
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
   if(iTime(0)==prevtime)
      return;
   prevtime=iTime(0);

   if(!IsTradeAllowed())
     {
      prevtime=iTime(1);
      MathSrand(GetTickCount());
      Sleep(30000+MathRand());
     }
//--- работаем только с одной позицией
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return;

   double lt = getLots();
   if(losses>=losseslimit)
     {
      SendMail(MQLInfoString(MQL_PROGRAM_NAME)+" Too many losses","Chart "+Symbol());
      return;
     }

   if(iDeMarkerGet(0)>0.5)
     {
      if(!RefreshRates())
        {
         prevtime=iTime(1);
         return;
        }

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),lt,m_symbol.Ask(),ORDER_TYPE_BUY);

      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=lt)
           {
            double sl=m_symbol.NormalizePrice(m_symbol.Ask()-InpStopLoss*m_adjusted_point);
            double tp=m_symbol.NormalizePrice(m_symbol.Ask()+InpTakeProfit*m_adjusted_point);

            if(m_trade.Buy(lt,NULL,m_symbol.Ask(),sl,tp,MQLInfoString(MQL_PROGRAM_NAME)))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  prevtime=iTime(1);
                 }
               else
                  Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               prevtime=iTime(1);
              }
           }
     }
   else
     {
      if(!RefreshRates())
        {
         prevtime=iTime(1);
         return;
        }

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),lt,m_symbol.Bid(),ORDER_TYPE_SELL);

      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=lt)
           {
            double sl=m_symbol.NormalizePrice(m_symbol.Bid()+InpStopLoss*m_adjusted_point);
            double tp=m_symbol.NormalizePrice(m_symbol.Bid()-InpTakeProfit*m_adjusted_point);

            if(m_trade.Sell(lt,NULL,m_symbol.Bid(),sl,tp))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  prevtime=iTime(1);
                 }
               else
                  Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               prevtime=iTime(1);
              }
           }
     }
//--- exit
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLots()
  {
   if(fastoptimize)
      return(InpLots);

   losses=0;
   int profits=0;
   double lossesvolume=0;
   double minlot=m_symbol.LotsMin();
   int round_=(int)(MathAbs(MathLog(minlot)/MathLog(10.0))+0.5);
   double result=InpLots;
   double spread=m_symbol.Spread();

//--- request trade history from Mounts
   HistorySelect(TimeCurrent()-30*24*60*60,TimeCurrent()+36000);

   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   string   symbol;
   long     magic;
   double   profit;
   double   volume;

//--- for all deals 
   for(uint i=0;i<total;i++)
     {
      //--- try to get deals ticket 
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties 
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
         profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
         //--- only for current symbol 
         if(symbol==m_symbol.Name() && magic==m_magic)
           {
            if(profit>0)
              {
               if(lossesvolume>0.5 && profits<1)
                 {
                  if(InpTakeProfit-spread==0)
                     result=InpLots;
                  else
                     result=InpLots*lossesvolume *(InpStopLoss+spread)/(InpTakeProfit-spread);
                 }
               else
                  result=InpLots;

               losses=0;
               if(profits>1)
                  lossesvolume=0;

               profits++;
              }
            else
              {
               result=InpLots;
               losses++;
               lossesvolume=lossesvolume+volume/InpLots;
               profits=0;
              }
           }
        }

     }

   result=NormalizeDouble(result,round_);
   double maxlot=m_symbol.LotsMax();
   if(result>maxlot)
      result=maxlot;

   return(result);
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
//| Get value of buffers for the iDeMarker                           |
//+------------------------------------------------------------------+
double iDeMarkerGet(const int index)
  {
   double DeMarker[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iDeMarker array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iDeMarker,0,index,1,DeMarker)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iDeMarker indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(DeMarker[0]);
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
