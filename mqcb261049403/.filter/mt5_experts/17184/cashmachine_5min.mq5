//+------------------------------------------------------------------+
//|                    CashMachine 5min(barabashkakvn's edition).mq5 |
//|                                             Puncher Poland© 2008 |
//|                                        http://www.terazpolska.pl |
//+------------------------------------------------------------------+
#property copyright "Puncher Poland© 2008: bemowo@tlen.pl"
#property link      "http://www.terazpolska.pl"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- inpur parameter
input double            hidden_TakeProfit    = 60;
input double            hidden_StopLoss      = 30;
input double            Lots                 = 0.2;            // Lots
input double            target_tp1           = 20;             // the first level of profit
input double            target_tp2           = 35;             // the second level of profit
input double            target_tp3           = 50;             // the third level of profit
//--- DeMarker
input ENUM_TIMEFRAMES   DeMarker_period      = PERIOD_CURRENT; // DeMarket period 
input int               DeMarker_ma_period   = 14;             // DeMarket averaging period 
//--- Stochastic Oscillator
input ENUM_TIMEFRAMES   Stochastic_period    = PERIOD_CURRENT; // Stochastic period 
input int               Stochastic_Kperiod   = 5;              // Stochastic K-period (number of bars for calculations) 
input int               Stochastic_Dperiod   = 3;              // Stochastic D-period (period of first smoothing) 
input int               Stochastic_slowing   = 3;              // Stochastic final smoothing 
//---
ulong                   m_magic=12345; // magic number
int                     handle_iDeMarker; // variable for storing the handle of the iDeMarker indicator 
int                     handle_iStochastic; // variable for storing the handle of the iStochastic indicator 
double                  m_digits_adjust=0.0; // 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Bars(Symbol(),Period())<100)
     {
      Print("bars less than 100");
      return(INIT_FAILED);
     }
//--- create handle of the indicator iDeMarker
   handle_iDeMarker=iDeMarker(Symbol(),DeMarker_period,DeMarker_ma_period);
//--- if the handle is not created 
   if(handle_iDeMarker==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iDeMarker indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(Symbol(),Stochastic_period,Stochastic_Kperiod,Stochastic_Dperiod,Stochastic_slowing,MODE_EMA,STO_LOWHIGH);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
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
   m_digits_adjust = digits_adjust * m_symbol.Point();
//---
   if(hidden_TakeProfit*m_digits_adjust<10*m_digits_adjust)
     {
      Print("TakeProfit less than 10");
      return(INIT_FAILED);  // check TakeProfit
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
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            total++;

   if(total<1)
     {
      if(iDeMarkerGet(1)<0.30 && iDeMarkerGet(0)>=0.30)
        {
         if(iStochasticGet(MAIN_LINE,1)<20 && iStochasticGet(MAIN_LINE,0)>=20)
           {
            if(!RefreshRates())
               return;

            if(m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),0.0,0.0,"Cash machine buy"))
              {
               Print("BUY opened : ",m_trade.ResultPrice());
              }
            else
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription(),
                     ", ticket of deal: ",m_trade.ResultDeal());
              }
            return;
           }
        }
      if(iDeMarkerGet(1)>0.70 && iDeMarkerGet(0)<=0.70)
        {
         if(iStochasticGet(MAIN_LINE,1)>80 && iStochasticGet(MAIN_LINE,0)<=80)
           {
            if(!RefreshRates())
               return;

            if(m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),0.0,0.0,"Cash machine sell"))
              {
               Print("Sell opened : ",m_trade.ResultPrice());
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
      return;
     }
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
               return;

            if(m_position.PositionType()==POSITION_TYPE_BUY) // если  открыта длинная позиция
              {
               //--- обеспечить проверку прибыли или принять максимальную убыток, который позволяет hidden_StopLoss
               if(m_symbol.Bid()<=(m_position.PriceOpen()-(hidden_StopLoss*m_digits_adjust)) ||
                  m_symbol.Bid()>=(m_position.PriceOpen()+(hidden_TakeProfit*m_digits_adjust)))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
               //--- прибыль достигла третьего безопасного порога
               if(m_symbol.Bid()>=m_position.PriceOpen()+(target_tp3*m_digits_adjust))
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_symbol.Bid() -(m_digits_adjust *(target_tp3-13)),
                                         m_symbol.Ask()+(m_digits_adjust*hidden_TakeProfit));
                  return;
                 }
               //--- прибыль достигла второго безопасного порога
               if(m_symbol.Bid()>=m_position.PriceOpen()+(target_tp2*m_digits_adjust) && 
                  m_symbol.Bid()<m_position.PriceOpen()+(target_tp3*m_digits_adjust))
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_symbol.Bid() -(m_digits_adjust *(target_tp2-13)),
                                         m_symbol.Ask()+(m_digits_adjust*hidden_TakeProfit));
                  return;
                 }
               //--- прибыль достигла первого безопасного порога
               if(m_symbol.Bid()>=m_position.PriceOpen()+(target_tp1*m_digits_adjust) && 
                  m_symbol.Bid()<m_position.PriceOpen()+(target_tp3*m_digits_adjust) &&
                  m_symbol.Bid()<m_position.PriceOpen()+(target_tp2*m_digits_adjust))
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_symbol.Bid() -(m_digits_adjust *(target_tp1-13)),
                                         m_symbol.Ask()+(m_digits_adjust*hidden_TakeProfit));
                  return;
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL) // если  открыта короткая позиция
              {
               //--- обеспечить проверку прибыли или принять максимальную убыток, который позволяет hidden_StopLoss
               if(m_symbol.Ask()>=(m_position.PriceOpen()+(hidden_StopLoss*m_digits_adjust)) ||
                  m_symbol.Ask()<=(m_position.PriceOpen()-(hidden_TakeProfit*m_digits_adjust)))
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
               //--- прибыль достигла третьего безопасного порога       
               if(m_symbol.Ask()<=m_position.PriceOpen()-(target_tp3*m_digits_adjust))
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_symbol.Ask()+(m_digits_adjust *(target_tp3+13)),
                                         m_symbol.Bid() -(m_digits_adjust*hidden_TakeProfit));
                  return;
                 }
               //--- прибыль достигла второго безопасного порога
               if(m_symbol.Ask()<=m_position.PriceOpen()-(target_tp2*m_digits_adjust) && 
                  m_symbol.Ask()>m_position.PriceOpen()-(target_tp3*m_digits_adjust))
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_symbol.Ask()+(m_digits_adjust *(target_tp2+13)),
                                         m_symbol.Bid() -(m_digits_adjust*hidden_TakeProfit));
                  return;
                 }
               //--- прибыль достигла первого безопасного порога
               if(m_symbol.Ask()<=m_position.PriceOpen()-(target_tp1*m_digits_adjust) && 
                  m_symbol.Ask()>m_position.PriceOpen()-(target_tp2*m_digits_adjust) &&
                  m_symbol.Ask()>m_position.PriceOpen()-(target_tp3*m_digits_adjust))
                 {
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_symbol.Ask()+(m_digits_adjust *(target_tp1+13)),
                                         m_symbol.Bid() -(m_digits_adjust*hidden_TakeProfit));
                  return;
                 }
              }
           }
//---
   return;
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
   if(CopyBuffer(handle_iStochastic,buffer,index,1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[0]);
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
