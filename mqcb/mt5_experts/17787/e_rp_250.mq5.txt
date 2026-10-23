//+------------------------------------------------------------------+
//|                            e_RP_250(barabashkakvn's edition).mq5 |
//|                                      Copyright 2017, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
input double   Lots=0.1;
input ushort   TakeProfit=15;
input ushort   StopLoss=999;
input ushort   TrailingStop=0;
input ushort   ReversePoint=250;
//---
datetime TimeN;
bool temp1=false,temp2=false;
double RPoint_High=0,RPoint_Low=0,Reverse_High=0,Reverse_Low=0;
//---
ulong          m_magic=50908;                // magic number
ulong          m_slippage=30;                // slippage
int            handle_iRPoint;               // variable for storing the handle of the RPoint indicator 
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
//--- create handle of the indicator RPoint
   handle_iRPoint=iCustom(m_symbol.Name(),Period(),"rPoint",ReversePoint,0);
//--- if the handle is not created 
   if(handle_iRPoint==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iADX indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   TimeN=0;
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
   datetime TimeC=iTime(0);

   for(int ii=0; ii<=ReversePoint; ii++)
     {
      double val=iRPointGet(ii);
      if(val==iHigh(ii))
        {
         RPoint_High=val;
         break;
        }
      if(val==iLow(ii))
        {
         RPoint_Low=val;
         break;
        }
     }

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(TrailingStop>0)
                 {
                  if(!RefreshRates())
                     return;
                  if(m_symbol.Bid()-m_position.PriceOpen()>TrailingStop*m_adjusted_point)
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-(TrailingStop+10)*m_adjusted_point)
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_symbol.Bid()-TrailingStop*m_adjusted_point),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }

               if(RPoint_High!=Reverse_High)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(TrailingStop>0)
                 {
                  if(!RefreshRates())
                     return;
                  if((m_position.PriceOpen()-m_symbol.Ask())>(TrailingStop*m_adjusted_point))
                    {
                     if((m_position.StopLoss()>(m_symbol.Ask()+(TrailingStop+10)*m_adjusted_point)) || 
                        (m_position.StopLoss()==0))
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_symbol.Ask()+TrailingStop*m_adjusted_point),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
               if(RPoint_Low!=Reverse_Low)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  return;
                 }
              }
           }

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   if(total>0)
      return;
   if(TimeC==TimeN)
      return;

   if(temp1==true || (temp1==false && RPoint_High!=Reverse_High))
     {
      if(!RefreshRates())
         return;
      Alert(RPoint_High);
      if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),
         m_symbol.NormalizePrice(m_symbol.Bid()+StopLoss*m_adjusted_point),
         m_symbol.NormalizePrice(m_symbol.Bid()-TakeProfit*m_adjusted_point),"Super"))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            temp1=true;
           }
         else
           {
            Reverse_High=RPoint_High;
            temp1=false;
            TimeN=TimeC;
           }
        }
      else
        {
         Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         temp1=true;
        }

     }

   if(temp2==true || (temp2==false && RPoint_Low!=Reverse_Low))
     {
      if(!RefreshRates())
         return;
      Alert(RPoint_Low);
      if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),
         m_symbol.NormalizePrice(m_symbol.Ask()-StopLoss*m_adjusted_point),
         m_symbol.NormalizePrice(m_symbol.Ask()+TakeProfit*m_adjusted_point),"Super"))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            temp2=true;
           }
         else
           {
            Reverse_Low=RPoint_Low;
            temp2=false;
            TimeN=TimeC;
           }
        }
      else
        {
         Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         temp2=true;
        }
     }
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
//| Get value of buffers for the iRPoint                             |
//+------------------------------------------------------------------+
double iRPointGet(const int index)
  {
   double RPoint[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the RPointBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRPoint,0,index,1,RPoint)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRPoint indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RPoint[0]);
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
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0) high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0) low=Low[0];
   return(low);
  }
//+------------------------------------------------------------------+
