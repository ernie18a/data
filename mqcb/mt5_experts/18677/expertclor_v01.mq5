//+------------------------------------------------------------------+
//|                      ExpertClor_v01(barabashkakvn's edition).mq5 |
//|                                           Сергей Заикин as Vuki  |
//|                                                 f_kombi@mail.ru  |
//+------------------------------------------------------------------+
#property copyright "Сергей Заикин as Vuki"
#property link      "f_kombi@mail.ru"
#property description "ATTENTION!!! The adviser only CLOSES positions !!!"
#property version "1.000"
#define ATR_MAX 0
#define ATR_MIN 1
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input string               Attention="ATTENTION!!! The adviser only CLOSES positions !!!"; // ATTENTION!!! The adviser only CLOSES positions !!!
input bool                 MA_CloseOnOff        = true;           // Closing mode on the intersection of two MA
input bool                 StATR_CloseOnOff     = true;           // Mode StopLoss by the indicator StopATR_auto
input int                  Fast_ma_period       = 5;              // Fast ma_period
input ENUM_MA_METHOD       Fast_ma_method       = MODE_EMA;       // Fast ma_method 
input ENUM_APPLIED_PRICE   Fast_applied_price   = PRICE_CLOSE;    // Fast type of price
input int                  Slow_ma_period       = 7;              // Slow ma_period 
input ENUM_MA_METHOD       Slow_ma_method       = MODE_EMA;       // Slow ma_method 
input ENUM_APPLIED_PRICE   Slow_applied_price   = PRICE_OPEN;     // Slow type of price
input ENUM_TIMEFRAMES      TimeFrame            = PERIOD_M5;      // Period
input ushort               Breakeven            = 0;              // Breakeven (in pips)
input int                  CountBarsForAverage  = 12;             // StopATR_auto ATR period
input double               Target               = 2.0;            // StopATR_auto Target
//---
ulong          m_magic=222848220;            // magic number
ulong          m_slippage=30;                // slippage
double         ExtBreakeven=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
int            handle_iCustom;               // variable for storing the handle of the iCustom indicator 
int            handle_iMA_fast;              // variable for storing the handle of the iMA indicator 
int            handle_iMA_slow;              // variable for storing the handle of the iMA indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtBreakeven=Breakeven*m_adjusted_point;
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),TimeFrame,"Downloads\\StopATR_auto",
                          CountBarsForAverage,
                          Target
                          );
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(TimeFrame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_fast=iMA(m_symbol.Name(),TimeFrame,Fast_ma_period,0,Fast_ma_method,Fast_applied_price);
//--- if the handle is not created 
   if(handle_iMA_fast==INVALID_HANDLE)
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
   handle_iMA_slow=iMA(m_symbol.Name(),TimeFrame,Slow_ma_period,0,Slow_ma_method,Slow_applied_price);
//--- if the handle is not created 
   if(handle_iMA_slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
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
   if(MQLInfoInteger(MQL_DEBUG) || MQLInfoInteger(MQL_PROFILER) || 
      MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION))
     {
      static long counter=-50;
      static bool trade_buy=true;

      if(counter==0)
         m_trade.Buy(m_symbol.LotsMin());
      else if(counter%1500==0)
        {
         if(RefreshRates())
           {
            if(trade_buy)
              {
               OpenBuy(m_symbol.LotsMin());
               trade_buy=false;
              }
            else
              {
               OpenSell(m_symbol.LotsMin());
               trade_buy=true;
              }
           }
         else
            counter=counter-9;
        }

      counter++;
     }
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
               continue;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               double StopL=iCustomGet(ATR_MIN,0);
               StopL=m_symbol.NormalizePrice(StopL);
               //--- transfer to breakeven position "Buy"    
               if(ExtBreakeven!=0 && (m_symbol.Bid()-m_position.PriceOpen()>=ExtBreakeven) && 
                  m_position.StopLoss()<m_position.PriceOpen())
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  else
                     Comment("The \"Buy\" position is transferred into a breakeven!\n");

                  continue;
                 }
               //--- modification StopLoss by "StopATR_auto"
               if(StATR_CloseOnOff)
                  if(m_position.StopLoss()<StopL)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),StopL,m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     else
                        Comment("StopLoss position \"Buy\" has been changed by the indicator \"StopATR_auto\"!\n");
                    }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               double StopL=iCustomGet(ATR_MAX,0);
               StopL=m_symbol.NormalizePrice(StopL);
               //--- transfer to breakeven position "Sell"      
               if(ExtBreakeven!=0 && (m_position.PriceOpen()-m_symbol.Ask()>=ExtBreakeven) && 
                  m_position.StopLoss()>m_position.PriceOpen())
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  else
                     Comment("The \"Sell\" position is transferred into a breakeven!\n");

                  continue;
                 }
               //--- modification StopLoss by "StopATR_auto"
               if(StATR_CloseOnOff)
                  if(m_position.StopLoss()==0.0 || m_position.StopLoss()>StopL)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),StopL,m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     else
                        Comment("StopLoss position \"Sell\" has been changed by the indicator \"StopATR_auto\"!\n");
                    }
              }
           }

   if(MA_CloseOnOff)
      FunctionSignalClose();
  }
// Функция рассчета сигналов Закрыть Бай, Закрыть Селл
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FunctionSignalClose()
  {
   double maFast1,maSlow1,maFast2,maSlow2;
   maFast1=iMAGet(handle_iMA_fast,1);
   maSlow1=iMAGet(handle_iMA_slow,1);
   maFast2=iMAGet(handle_iMA_fast,2);
   maSlow2=iMAGet(handle_iMA_slow,2);
   if(maFast1<=maSlow1 && maFast2>maSlow2)
     {
      Comment("Close \"Buy\" position!\n");
      ClosePositions(POSITION_TYPE_BUY);

     }
   else if(maFast1>=maSlow1 && maFast2<maSlow2)
     {
      Comment("Close \"Sell\" position!\n");
      ClosePositions(POSITION_TYPE_SELL);
     }
//---
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
//| Get value of buffers for the iiCustom                            |
//|  the buffer numbers are the following:                           |
//|   0 - ATR_MAX, 1 - ATR_MIN                                       |
//+------------------------------------------------------------------+
double iCustomGet(const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCustom,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
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
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(const double volume)
  {
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),volume,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=volume)
        {
         if(m_trade.Buy(volume,m_symbol.Name()))
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
void OpenSell(const double volume)
  {
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),volume,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=volume)
        {
         if(m_trade.Sell(volume,m_symbol.Name()))
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
