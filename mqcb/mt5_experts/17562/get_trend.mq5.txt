//+------------------------------------------------------------------+
//|                           Get trend(barabashkakvn's edition).mq5 |
//|                                          http://www.fortrader.ru |
//+------------------------------------------------------------------+
#property link      "http://www.fortrader.ru"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input ushort   porog=10;
input int      per_MA_M15= 99;
input int      per_MA_H1 = 184;
input int      per_Stoh_slow=27;
input ushort   TakeProfit=540;
input ushort   StopLoss=90;
input ushort   TrailingStop=20;
input double   Lots=0.1;
//---
ulong          m_magic=4583459;              // magic number
ulong          m_slippage=30;                // slippage

int            handle_iMA_M15;               // variable for storing the handle of the iMA indicator 
int            handle_iMA_H1;                // variable for storing the handle of the iMA indicator 
int            handle_iStochastic_M15;       // variable for storing the handle of the iStochastic indicator 

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
   if(Period()!=PERIOD_M15)
     {
      Print(EnumToString(PERIOD_M15)," only!");
      return(INIT_FAILED);
     }
   if(TrailingStop>=TakeProfit)
     {
      Print("Error! TrailingStop>=TakeProfit!");
      return(INIT_PARAMETERS_INCORRECT);
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
//--- create handle of the indicator iMA
   handle_iMA_M15=iMA(m_symbol.Name(),PERIOD_M15,per_MA_M15,8,MODE_SMMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_M15==INVALID_HANDLE)
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
   handle_iMA_H1=iMA(m_symbol.Name(),PERIOD_H1,per_MA_H1,8,MODE_SMMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_H1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic_M15=iStochastic(m_symbol.Name(),PERIOD_M15,per_Stoh_slow,3,3,MODE_SMA,STO_LOWHIGH);
//--- if the handle is not created 
   if(handle_iStochastic_M15==INVALID_HANDLE)
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
//--- работаем только по новому бару
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//--- вычисляем начальные параметры индикаторов для поиска условий входа
   double MA_M15   = iMAGet(handle_iMA_M15,1);
   double MA_H1    = iMAGet(handle_iMA_H1,1);

   double Stoh_slow = iStochasticGet(SIGNAL_LINE,1);
   double Stoh_fast = iStochasticGet(MAIN_LINE,1);
   double Stoh_fast_prew=iStochasticGet(MAIN_LINE,2);

   double price_M15=iClose(1,NULL,PERIOD_M15);
   double price_H1=iClose(1,NULL,PERIOD_H1);

//--- проверка условий для совершения сделки
   if(price_M15<MA_M15 && price_H1<MA_H1 && (MA_M15-price_M15)<=porog*m_adjusted_point)
     {
      if(Stoh_slow<20 && Stoh_fast<20 && Stoh_fast_prew<Stoh_slow && Stoh_fast>Stoh_slow)
        {
         if(!RefreshRates())
            return;

         //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
         double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,m_symbol.Ask(),ORDER_TYPE_BUY);

         if(chek_volime_lot!=0.0)
            if(chek_volime_lot>=Lots)
              {
               Print("BUY разница (MA_M15-price_M15) = ",DoubleToString(MA_M15-price_M15,m_symbol.Digits()),
                     " MA_M15 = ",DoubleToString(MA_M15,m_symbol.Digits()),
                     " price_M15 = ",DoubleToString(price_M15,m_symbol.Digits()));
               double sl=m_symbol.NormalizePrice(m_symbol.Ask()-StopLoss*m_adjusted_point);
               double tp=m_symbol.NormalizePrice(m_symbol.Ask()+TakeProfit*m_adjusted_point);

               if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),sl,tp))
                 {
                  if(m_trade.ResultDeal()==0)
                     Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  else
                     Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
               else
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
        }
     }
   if(price_M15>MA_M15 && price_H1>MA_H1 && (price_M15-MA_M15)<=porog*m_adjusted_point)
     {
      if(Stoh_slow>80 && Stoh_fast>80 && Stoh_fast_prew>Stoh_slow && Stoh_fast<Stoh_slow)
        {
         if(!RefreshRates())
            return;

         //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
         double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,m_symbol.Bid(),ORDER_TYPE_SELL);

         if(chek_volime_lot!=0.0)
            if(chek_volime_lot>=Lots)
              {
               Print("Sell разница (price_M15-MA_M15) = ",DoubleToString(price_M15-MA_M15,m_symbol.Digits()),
                     " MA_M15 = ",DoubleToString(MA_M15,m_symbol.Digits()),
                     " price_M15 = ",DoubleToString(price_M15,m_symbol.Digits()));
               double sl=m_symbol.NormalizePrice(m_symbol.Bid()+StopLoss*m_adjusted_point);
               double tp=m_symbol.NormalizePrice(m_symbol.Bid()-TakeProfit*m_adjusted_point);

               if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),sl,tp))
                 {
                  if(m_trade.ResultDeal()==0)
                     Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  else
                     Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
               else
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
        }
     }
//--- трейлинг
   if(TrailingStop==0)
      return;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(!RefreshRates())
                  continue;

               if(m_symbol.Bid()-m_position.PriceOpen()>TrailingStop*m_adjusted_point)
                 {
                  if(m_position.StopLoss()<m_symbol.Bid()-TrailingStop*m_adjusted_point)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_symbol.Bid()-TrailingStop*m_adjusted_point),
                        m_position.TakeProfit()))
                        Print("PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(!RefreshRates())
                  continue;

               if((m_position.PriceOpen()-m_symbol.Ask())>TrailingStop*m_adjusted_point)
                 {
                  if(m_position.StopLoss()>m_symbol.Ask()+TrailingStop*m_adjusted_point || m_position.StopLoss()==0)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_symbol.Ask()+TrailingStop*m_adjusted_point),
                        m_position.TakeProfit()))
                        Print("PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
              }
           }
//---
   return;
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle_iMA,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int buffer,const int index)
  {
   double Stochastic[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic_M15,buffer,index,1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[0]);
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
