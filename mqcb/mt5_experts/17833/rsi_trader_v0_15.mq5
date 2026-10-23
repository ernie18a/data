//+------------------------------------------------------------------+
//|                    RSI trader v0.15(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// Run on EUR/USD H1 
// At a certain time a small breakout often occurs.
//----------------------- HISTORY
// v0.10 Initial release.
//----------------------- TODO
//---
#include <MovingAverages.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
input int ma_period_RSI=14;
input int Short_RSI_MA_periods=9;
input int Long_RSI_MA_periods=45;
input int ma_period_Short=9;
input int ma_period_Long=45;
input double Lots=1;
input bool Reverse=false;
//---
ulong          m_magic=79346413;             // magic number
ulong          m_slippage=30;                // slippage
//---
int    handle_iMA_Short;                     // variable for storing the handle of the iMA indicator 
int    handle_iMA_Long;                      // variable for storing the handle of the iMA indicator 
int    handle_iRSI;                          // variable for storing the handle of the iRSI indicator
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
   handle_iMA_Short=iMA(m_symbol.Name(),Period(),ma_period_Short,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Short==INVALID_HANDLE)
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
   handle_iMA_Long=iMA(m_symbol.Name(),Period(),ma_period_Long,0,MODE_LWMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Long==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),ma_period_RSI,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
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
   int arr_size=(Short_RSI_MA_periods>Long_RSI_MA_periods)?Short_RSI_MA_periods:Long_RSI_MA_periods;
   double RSI[];
   double RSI_SMA[];
   int bar_number=1;
   ArrayResize(RSI,arr_size+bar_number);
   ArrayResize(RSI_SMA,arr_size+bar_number);
   ArraySetAsSeries(RSI,false);
   ArraySetAsSeries(RSI_SMA,true);
//--- copy iRSI value to array
   if(!iRSIGet(0,0,arr_size+2,RSI))
      return;
   double RSI_Short_SMA_1=SimpleMA(arr_size,Short_RSI_MA_periods,RSI);
   double RSI_Long_SMA_1=SimpleMA(arr_size,Long_RSI_MA_periods,RSI);
//---
   double Price_MA_Long_1=iMAGet(handle_iMA_Long,bar_number);
   double Price_MA_Short_1=iMAGet(handle_iMA_Short,bar_number);
//---
   bool Long=false;
   bool Short=false;
   bool Sideways=false;

   if(Price_MA_Short_1>Price_MA_Long_1 && RSI_Short_SMA_1>RSI_Long_SMA_1)
      Long=true;
   if(Price_MA_Short_1<Price_MA_Long_1 && RSI_Short_SMA_1<RSI_Long_SMA_1)
      Short=true;
   if(Price_MA_Short_1>Price_MA_Long_1 && RSI_Short_SMA_1<RSI_Long_SMA_1)
      Sideways=true;
   if(Price_MA_Short_1<Price_MA_Long_1 && RSI_Short_SMA_1>RSI_Long_SMA_1)
      Sideways=true;

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            total++;
            if(Sideways)
              {
               Print("Sideways detected");
               m_trade.PositionClose(m_position.Ticket());
              }
           }

   if(Long && total==0)
     {
      if(!RefreshRates())
         return;
      if(!Reverse)
         OpenBuy(0.0,0.0);
      else
         OpenSell(0.0,0.0);
     }
   if(Short && total==0)
     {
      if(!RefreshRates())
         return;
      if(!Reverse)
         OpenSell(0.0,0.0);
      else
         OpenBuy(0.0,0.0);
     }
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
//| Get value of buffers for the iRSI                                |
//+------------------------------------------------------------------+
bool iRSIGet(const int buffer_num,const int start_pos,const int count,double &arr_buffer[])
  {
   bool result=true;
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,buffer_num,start_pos,count,arr_buffer)<count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(result);
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=Lots)
        {
         if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),sl,tp))
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
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=Lots)
        {
         if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),sl,tp))
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
