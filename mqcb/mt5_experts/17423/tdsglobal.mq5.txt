//+------------------------------------------------------------------+
//|                           TDSGlobal(barabashkakvn's edition).mq5 |
//|                           Copyright © 2005 Bob O'Brien / Barcode |
//|                                       http://mak.tradersmind.com |
//+------------------------------------------------------------------+
// Expert based on Alexander Elder's Triple Screen system. 
// To be run only on a Daily chart.
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
//---- External Variables
input int      Lots=1;
input int      TakeProfit=999;
input int      Stoploss=0;
input int      TrailingStop=10;
input int      WilliamsL=-75;
input int      WilliamsH=-25;
//---
double MacdPrevious=0,MacdPrevious2=0,Direction=0,
OsMAPrevious=0,OsMAPrevious2=0,OsMADirection=0;
datetime newbar=0;
double PriceOpen=0; // Price Open
int TradesThisSymbol=0;
bool WilliamsSell=0,WilliamsBuy=0;
double NewPrice=0;
int StartMinute1=0,EndMinute1=0,StartMinute2=0,EndMinute2=0,
StartMinute3=0,EndMinute3=0;
int StartMinute4=0,EndMinute4=0,StartMinute5=0,EndMinute5=0,
StartMinute6=0,EndMinute6=0;
int StartMinute7=0,EndMinute7=0,DummyField=0;
//---
ulong          m_magic=15489;                // magic number
int            handle_iMACD;                 // variable for storing the handle of the iMACD indicator 
int            handle_iOsMA;                 // variable for storing the handle of the iOsMA indicator 
int            handle_iWPR;                  // variable for storing the handle of the iWPR indicator 
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
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(m_symbol.Name(),PERIOD_D1,12,23,9,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(PERIOD_D1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iOsMA
   handle_iOsMA=iOsMA(m_symbol.Name(),PERIOD_D1,12,26,9,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iOsMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create a handle of iOsMA for the pair %s/%s, error code is %d",
                  m_symbol.Name(),
                  EnumToString(PERIOD_D1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iWPR
   handle_iWPR=iWPR(m_symbol.Name(),PERIOD_D1,24);
//--- if the handle is not created 
   if(handle_iWPR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iWPR indicator for the symbol %s/%s, error code %d",
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

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if((str1.min >= StartMinute1 && str1.min <= EndMinute1) ||
      (str1.min >= StartMinute2 && str1.min <= EndMinute2) ||
      (str1.min >= StartMinute3 && str1.min <= EndMinute3) ||
      (str1.min >= StartMinute4 && str1.min <= EndMinute4) ||
      (str1.min >= StartMinute5 && str1.min <= EndMinute5) ||
      (str1.min >= StartMinute6 && str1.min <= EndMinute6) ||
      (str1.min >= StartMinute7 && str1.min <= EndMinute7))
     {
      // dummy statement because MT will not allow me to use a continue statement
      DummyField=0;
     } // close for LARGE if statement
   else
     {
      DummyField=1;
      return;
     }
//--- Process the next bar details
   if(newbar!=iTime(m_symbol.Name(),Period(),0) || DummyField==0)
     {
      DataPreparation();

      newbar=iTime(m_symbol.Name(),Period(),0);
      if(TradesThisSymbol<1)
        {
         if(!RefreshRates())
           {
            newbar=iTime(m_symbol.Name(),Period(),1);
            return;
           }

         if(Direction==1 && WilliamsBuy)
           {
            //--- Buy 1 point above high of previous candle
            PriceOpen=iHigh(m_symbol.Name(),Period(),1)+1*m_adjusted_point;
            //--- Check if buy price is a least 16 points > m_symbol.Ask()
            if(PriceOpen>(m_symbol.Ask()+16*m_adjusted_point))
              {
               if(!m_trade.BuyStop(Lots,PriceOpen,NULL,
                  iLow(m_symbol.Name(),Period(),1)-1*m_adjusted_point,
                  PriceOpen+TakeProfit*m_adjusted_point))
                  Print("BuyStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of order: ",m_trade.ResultOrder());
               return;

              }
            else
              {
               NewPrice=m_symbol.Ask()+16*m_adjusted_point;
               if(!m_trade.BuyStop(Lots,NewPrice,NULL,
                  iLow(m_symbol.Name(),Period(),1)-1*m_adjusted_point,
                  NewPrice+TakeProfit*m_adjusted_point))
                  Print("BuyStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of order: ",m_trade.ResultOrder());
               return;
              }
           }
         if(Direction==-1 && WilliamsSell)
           {
            PriceOpen=iLow(m_symbol.Name(),Period(),1)-1*m_adjusted_point;
            // Check if buy price is a least 16 points < m_symbol.Bid()
            if(PriceOpen<(m_symbol.Bid()-16*m_adjusted_point))
              {
               if(!m_trade.SellStop(Lots,PriceOpen,NULL,
                  iHigh(m_symbol.Name(),Period(),1)+1*m_adjusted_point,
                  PriceOpen-TakeProfit*m_adjusted_point))
                  Print("SellStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of order: ",m_trade.ResultOrder());
               return;
              }
            else
              {
               NewPrice=m_symbol.Bid()-16*m_adjusted_point;
               if(!m_trade.SellStop(Lots,NewPrice,NULL,
                  iHigh(m_symbol.Name(),Period(),1)+1*m_adjusted_point,
                  NewPrice-TakeProfit*m_adjusted_point))
                  Print("SellStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of order: ",m_trade.ResultOrder());
               return;
              }
           }
        }
      //--- Pending Order Management
      if(TradesThisSymbol>0)
        {
         for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
           {
            if(m_order.SelectByIndex(i)) // selects the pending order by index for further access to its properties
              {
               if(!RefreshRates())
                 {
                  newbar=iTime(m_symbol.Name(),Period(),1);
                  return;
                 }

               if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
                 {
                  if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
                     if(Direction==-1)
                       {
                        m_trade.OrderDelete(m_order.Ticket());
                        return;
                       }
                  if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
                    {
                     if(Direction==1)
                       {
                        m_trade.OrderDelete(m_order.Ticket());
                        return;
                       }
                    }
                  if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
                    {
                     if(iHigh(m_symbol.Name(),Period(),1)<iHigh(m_symbol.Name(),Period(),2))
                       {
                        if(iHigh(m_symbol.Name(),Period(),1)>(m_symbol.Ask()+16*m_adjusted_point))
                          {
                           m_trade.OrderModify(m_order.Ticket(),
                                               iHigh(m_symbol.Name(),Period(),1)+1*m_adjusted_point,
                                               iLow(m_symbol.Name(),Period(),1)-1*m_adjusted_point,
                                               m_order.TakeProfit(),
                                               m_order.TypeTime(),
                                               m_order.TimeExpiration());
                           return;
                          }
                        else
                          {
                           m_trade.OrderModify(m_order.Ticket(),
                                               m_symbol.Ask()+16*m_adjusted_point,
                                               iLow(m_symbol.Name(),Period(),1)-1*m_adjusted_point,
                                               m_order.TakeProfit(),
                                               m_order.TypeTime(),
                                               m_order.TimeExpiration());
                           return;
                          }
                       }
                    }
                  if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
                    {
                     if(iLow(m_symbol.Name(),Period(),1)>iLow(m_symbol.Name(),Period(),2))
                       {
                        if(iLow(m_symbol.Name(),Period(),1)<(m_symbol.Bid()-16*m_adjusted_point))
                          {
                           m_trade.OrderModify(m_order.Ticket(),
                                               iLow(m_symbol.Name(),Period(),1)-1*m_adjusted_point,
                                               iHigh(m_symbol.Name(),Period(),1)+1*m_adjusted_point,
                                               m_order.TakeProfit(),
                                               m_order.TypeTime(),
                                               m_order.TimeExpiration());
                           return;
                          }
                        else
                          {
                           m_trade.OrderModify(m_order.Ticket(),
                                               m_symbol.Bid()-16*m_adjusted_point,
                                               iHigh(m_symbol.Name(),Period(),1)+1*m_adjusted_point,
                                               m_order.TakeProfit(),
                                               m_order.TypeTime(),
                                               m_order.TimeExpiration());
                           return;
                          }
                       }
                    }
                 }
              }
           }
        }
      //--- Stop Loss Management
      if(TradesThisSymbol>0)
        {
         for(int i=PositionsTotal()-1;i>=0;i--)
            if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
               if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
                 {
                  if(!RefreshRates())
                    {
                     newbar=iTime(m_symbol.Name(),Period(),1);
                     return;
                    }

                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     if(m_symbol.Ask()-m_position.PriceOpen()>(TrailingStop*m_adjusted_point))
                       {
                        if(m_position.StopLoss()<(m_symbol.Ask()-TrailingStop*m_adjusted_point))
                          {
                           m_trade.PositionModify(m_position.Ticket(),
                                                  m_symbol.Ask()-TrailingStop*m_adjusted_point,
                                                  m_symbol.Ask()+TakeProfit*m_adjusted_point);
                           return;
                          }
                       }
                    }
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                       {
                        if(m_position.StopLoss()>(m_symbol.Bid()+TrailingStop*m_adjusted_point))
                          {
                           m_trade.PositionModify(m_position.Ticket(),
                                                  m_symbol.Bid()+TrailingStop*m_adjusted_point,
                                                  m_symbol.Bid()-TakeProfit*m_adjusted_point);
                           return;
                          }
                       }
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
void DataPreparation(void)
  {
   TradesThisSymbol=AllPositionsAndPendingOrders();

   MacdPrevious  = iMACDGet(MAIN_LINE, 1);
   MacdPrevious2 = iMACDGet(MAIN_LINE, 2);
   OsMAPrevious  = iOsMAGet(1);
   OsMAPrevious2 = iOsMAGet(2);
   double WPR_1=iWPRGet(1);
   WilliamsSell = WPR_1 > WilliamsH;
   WilliamsBuy  = WPR_1 < WilliamsL;
   if(MacdPrevious>MacdPrevious2)
      Direction=1;
   if(MacdPrevious<MacdPrevious2)
      Direction=-1;
   if(MacdPrevious==MacdPrevious2)
      Direction=0;
   if(OsMAPrevious>OsMAPrevious2)
      OsMADirection=1;
   if(OsMAPrevious<OsMAPrevious2)
      OsMADirection=-1;
   if(OsMAPrevious==OsMAPrevious2)
      OsMADirection=0;
// Select a range of minutes in the day to start trading based on the currency pair.
// This is to stop collisions occurring when 2 or more currencies set orders at the same time.
   if(m_symbol.Name()=="USDCHF")
     {
      StartMinute1 = 0;
      EndMinute1   = 1;
      StartMinute2 = 8;
      EndMinute2   = 9;
      StartMinute3 = 16;
      EndMinute3   = 17;
      StartMinute4 = 24;
      EndMinute4   = 25;
      StartMinute5 = 32;
      EndMinute5   = 33;
      StartMinute6 = 40;
      EndMinute6   = 41;
      StartMinute7 = 48;
      EndMinute7   = 49;
     }
   if(m_symbol.Name()=="GBPUSD")
     {
      StartMinute1 = 2;
      EndMinute1   = 3;
      StartMinute2 = 10;
      EndMinute2   = 11;
      StartMinute3 = 18;
      EndMinute3   = 19;
      StartMinute4 = 26;
      EndMinute4   = 27;
      StartMinute5 = 34;
      EndMinute5   = 35;
      StartMinute6 = 42;
      EndMinute6   = 43;
      StartMinute7 = 50;
      EndMinute7   = 51;
     }
   if(m_symbol.Name()=="USDJPY")
     {
      StartMinute1 = 4;
      EndMinute1   = 5;
      StartMinute2 = 12;
      EndMinute2   = 13;
      StartMinute3 = 20;
      EndMinute3   = 21;
      StartMinute4 = 28;
      EndMinute4   = 29;
      StartMinute5 = 36;
      EndMinute5   = 37;
      StartMinute6 = 44;
      EndMinute6   = 45;
      StartMinute7 = 52;
      EndMinute7   = 53;
     }
   if(m_symbol.Name()=="EURUSD")
     {
      StartMinute1 = 6;
      EndMinute1   = 7;
      StartMinute2 = 14;
      EndMinute2   = 15;
      StartMinute3 = 22;
      EndMinute3   = 23;
      StartMinute4 = 30;
      EndMinute4   = 31;
      StartMinute5 = 38;
      EndMinute5   = 39;
      StartMinute6 = 46;
      EndMinute6   = 47;
      StartMinute7 = 54;
      EndMinute7   = 59;
     }
  }
//+------------------------------------------------------------------+
//| Close Positions                                                  |
//+------------------------------------------------------------------+
int AllPositionsAndPendingOrders(void)
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            total++;

   return(total);
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
//| Get value of buffers for the iOsMA                               |
//+------------------------------------------------------------------+
double iOsMAGet(const int index)
  {
   double OsMA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iOsMA array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iOsMA,0,index,1,OsMA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iOsMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(OsMA[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iWPR                                |
//+------------------------------------------------------------------+
double iWPRGet(const int index)
  {
   double WPR[];
   ArraySetAsSeries(WPR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iWPRBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iWPR,0,0,index+1,WPR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iWPR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(WPR[index]);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
