//+------------------------------------------------------------------+
//|                                 EMA(barabashkakvn's edition).mq5 |
//|                                                          Виталик |
//|                                                   wwwita@mail.ru |
//+------------------------------------------------------------------+
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input double   Lots                 = 0.1;   // Lots
input ushort   InpVirtualProfitPips = 5;     // Virtual Profit Pips
input ushort   InpMoveBack          = 3;     // MoveBack 
input ushort   InpStopLoss          = 20;    // StopLoss
//---
int            check                = 0;
double         ExtVirtualProfitPips = 0.0;   //  
double         ExtMoveBack          = 0.0;   //  
double         ExtVirtualStopLoss=0.0;   // 
ulong          m_magic= 8317357;             // magic number
ulong          m_slippage= 30;               // slippage
int            handle_iMA_one;               // variable for storing the handle of the iMA indicator 
int            handle_iMA_two;               // variable for storing the handle of the iMA indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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

   check                = 0;
   ExtVirtualProfitPips = InpVirtualProfitPips * m_adjusted_point;
   ExtMoveBack          = InpMoveBack * m_adjusted_point;
   ExtVirtualStopLoss   = InpStopLoss * m_adjusted_point;
//--- create handle of the indicator iMA
   handle_iMA_one=iMA(m_symbol.Name(),Period(),5,0,MODE_EMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_one==INVALID_HANDLE)
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
   handle_iMA_two=iMA(m_symbol.Name(),Period(),10,0,MODE_EMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_two==INVALID_HANDLE)
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
   double hi=iHigh(m_symbol.Name(),Period(),1);
   double lo=iLow(m_symbol.Name(),Period(),1);
   double EMA_one_1=iMAGet(handle_iMA_one,1);
   double EMA_two_1=iMAGet(handle_iMA_two,1);
   double EMA_one_0=iMAGet(handle_iMA_one,0);
   double EMA_two_0=iMAGet(handle_iMA_two,0);

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if(total<1)
     {
      if(m_account.FreeMargin()<(1000*Lots))
        {
         Print("У вас нет денег. Свободные средства = ",DoubleToString(m_account.FreeMargin(),2));
         return;
        }
      if(((EMA_one_1>EMA_two_1) && (EMA_one_0<EMA_two_0)) || ((EMA_one_1<EMA_two_1) && (EMA_one_0>EMA_two_0)))
        {
         check=1;
         Print("Позиция возможна!");
        }
      if(check==1)
        {
         if(!RefreshRates())
            return;

         if(EMA_two_0-EMA_one_0>2*m_adjusted_point && m_symbol.Bid()>=(lo+ExtMoveBack))
           {
            if(m_trade.Sell(Lots))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  return;
                 }
               else
                 {
                  Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  check=0;
                 }
              }
            else
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return;
              }
           }
         if(EMA_one_0-EMA_two_0>2*m_adjusted_point && m_symbol.Ask()<=(hi-ExtMoveBack))
           {
            if(m_trade.Buy(Lots))
              {
               if(m_trade.ResultDeal()==0)
                 {
                  Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  return;
                 }
               else
                 {
                  Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  check=0;
                 }
              }
            else
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return;
              }
           }
        }
      return;
     }
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
               return;

            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               // проверим, может уже пора закрываться?
               if(m_symbol.Bid()>=(m_position.PriceOpen()+ExtVirtualProfitPips))
                 {
                  check=0;
                  m_trade.PositionClose(m_position.Ticket()); // закрываем позицию
                  return; // выходим
                 }
               if(m_symbol.Bid()<=(m_position.PriceOpen()-ExtVirtualStopLoss))
                 {
                  check=0;
                  m_trade.PositionClose(m_position.Ticket()); // закрываем позицию
                  return; // выходим
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               // проверим, может уже пора закрываться?
               if(m_symbol.Ask()<=(m_position.PriceOpen()-ExtVirtualProfitPips))
                 {
                  check=0;
                  m_trade.PositionClose(m_position.Ticket()); // закрываем позицию
                  return; // выходим
                 }
               if(m_symbol.Ask()>=(m_position.PriceOpen()+ExtVirtualStopLoss))
                 {
                  check=0;
                  m_trade.PositionClose(m_position.Ticket()); // закрываем позицию
                  return; // выходим
                 }
              }
           }
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
