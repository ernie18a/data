//+------------------------------------------------------------------+
//|                                  GO(barabashkakvn's edition).mq5 | 
//|                             Copyright © 2006, Victor Chebotariov |
//|                                      http://www.chebotariov.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Victor Chebotariov"
#property link      "http://www.chebotariov.com/"
#property version   "1.001"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double            Risk           =30.0;
input int               MaxPositions   =5;
input ENUM_MA_METHOD    ma_method      =MODE_SMA;        // тип сглаживания 
input int               ma_period      =174;             // период усреднения 
//--- parameters
ulong                   m_magic=30072006;    // magic number
datetime                m_time=0;
int    handle_iMA_open;                      // variable for storing the handle of the iMA indicator 
int    handle_iMA_high;                      // variable for storing the handle of the iMA indicator 
int    handle_iMA_low;                       // variable for storing the handle of the iMA indicator 
int    handle_iMA_close;                     // variable for storing the handle of the iMA indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(m_account.MarginMode()!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- create handle of the indicator iMA
   handle_iMA_open=iMA(m_symbol.Name(),Period(),ma_period,0,ma_method,PRICE_OPEN);
//--- if the handle is not created 
   if(handle_iMA_open==INVALID_HANDLE)
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
   handle_iMA_high=iMA(m_symbol.Name(),Period(),ma_period,0,ma_method,PRICE_HIGH);
//--- if the handle is not created 
   if(handle_iMA_high==INVALID_HANDLE)
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
   handle_iMA_low=iMA(m_symbol.Name(),Period(),ma_period,0,ma_method,PRICE_LOW);
//--- if the handle is not created 
   if(handle_iMA_low==INVALID_HANDLE)
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
   handle_iMA_close=iMA(m_symbol.Name(),Period(),ma_period,0,ma_method,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_close==INVALID_HANDLE)
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
//| Расчет оптимального объема лота                                  |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
//---
   double Lots=NormalizeDouble(m_account.Balance()*Risk/100000.0,1);
   if(m_account.FreeMargin()<(1000*Lots))
     {
      Lots=NormalizeDouble(m_account.FreeMargin()*Risk/100000.0,1);
     }
//---
   return(LotCheck(Lots));
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double open =iMAGet(handle_iMA_open,0);
   double high =iMAGet(handle_iMA_high,0);
   double low  =iMAGet(handle_iMA_low,0);
   double close=iMAGet(handle_iMA_close,0);
   double GO=((close-open)+(high-open)+(low-open)+(close-low)+(close-high))*iTickVolume(m_symbol.Name(),Period(),0);

   if(GO<0)
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i))
            if(m_position.PositionType()==POSITION_TYPE_BUY && m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               m_trade.PositionClose(m_position.Ticket());
               return;
              }
     }

   if(GO>0)
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i))
            if(m_position.PositionType()==POSITION_TYPE_SELL && m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               m_trade.PositionClose(m_position.Ticket());
               return;
              }
     }

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if((GO>0 || GO<0) && (m_time!=iTime(m_symbol.Name(),Period(),0) && total<MaxPositions))
     {
      double vol=LotsOptimized();
      if(vol==0)
         return;
      if(m_account.FreeMargin()<(1000*vol))
        {
         Print("У Вас недостаточно денег. Свободной маржи = ",DoubleToString(m_account.FreeMargin(),2));
         return;
        }
      if(GO>0)
        {
         if(!RefreshRates())
            return;
         ulong m_ticket=0;
         if(m_trade.Buy(vol,m_symbol.Name(),m_symbol.Ask(),0,0,"MoneyPlus"))
            m_ticket=m_trade.ResultDeal();

         if(m_ticket>0)
           {
            Print("BUY order opened : ",m_trade.ResultRetcodeDescription());
            m_time=iTime(m_symbol.Name(),Period(),0);
           }
         else
           {
            Print("Error opening BUY order. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         return;
        }
      if(GO<0)
        {
         if(!RefreshRates())
            return;
         ulong m_ticket=0;
         if(m_trade.Sell(vol,m_symbol.Name(),m_symbol.Bid(),0,0,"MoneyPlus"))
            m_ticket=m_trade.ResultDeal();

         if(m_ticket>0)
           {
            Print("SELL order opened : ",m_trade.ResultRetcodeDescription());
            m_time=iTime(m_symbol.Name(),Period(),0);
           }
         else
           {
            Print("Error opening SELL order. Result Retcode: ",m_trade.ResultRetcode(),
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle,const int index)
  {
   double MA[];
   ArraySetAsSeries(MA,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[index]);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
