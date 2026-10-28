//+------------------------------------------------------------------+
//|                          Robot_MACD(barabashkakvn's edition).mq5 |
//|                                                     Tokman Yuriy |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input ushort   InpTakeProfit=300;
input double   Lots=1;
//---
ulong          m_magic=15489;                // magic number
double         ExtTakeProfit=0.0;
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
int            handle_iMACD;                 // variable for storing the handle of the iMACD indicator 
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
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
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
   double MacdCurrent=iMACDGet(MAIN_LINE,0);
   double MacdPrevious=iMACDGet(MAIN_LINE,1);
   double SignalCurrent=iMACDGet(SIGNAL_LINE,0);
   double SignalPrevious=iMACDGet(SIGNAL_LINE,1);

   int total=0;                           // количество позиций по данному символу и данному Magic
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            total++;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //--- условие закрытия
               if(MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               //--- условие закрытия
               if(MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
              }
           }

   if(total==0)
     {
      //--- проверка свободных средств
      if(m_account.FreeMargin()<(1000*Lots)) //количество свободных средств
        {
         Print("Недостаточно средств = ",DoubleToString(m_account.FreeMargin(),2));
         return;
        }
      //--- открытие длинной позиции
      if(MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious && MacdCurrent<0 && SignalCurrent<0)
        {
         if(!RefreshRates())
            return;

         if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),0.0,m_symbol.Ask()+ExtTakeProfit))
           {
            Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         return;
        }
      //--- открытие короткой позиции
      if(MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && MacdCurrent>0 && SignalCurrent>0)
        {
         if(!RefreshRates())
            return;

         if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),0.0,m_symbol.Bid()-ExtTakeProfit))
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
//---
   return;
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
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,index,1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[0]);
  }
//+------------------------------------------------------------------+
