//+------------------------------------------------------------------+
//|               DoubleMA Crossover EA(barabashkakvn's edition).mq5 | 
//|            Written by MrPip from idea of Jason Robinson for Eric |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MrPip"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
//--- Trailing Stop Type
enum ENUM_TRAILING_TYPE
  {
   type1=0,     // without delay 
   type2=1,     // waits for price to move the amount
   type3=2,     // uses up to 3 levels for trailing stop  
  };
//---
input bool AccountIsMini=false;       // Change to true if trading mini account
input bool MoneyManagement=true;     // Change to false to shutdown money management controls.
//---                            // Lots = 1 will be in effect and only 1 lot will be open regardless of equity.
input double TradeSizePercent=5;      // Change to whatever percent of equity you wish to risk.
input double Lots=0.1;                  // standard lot size. 
input double MaxLots=1;
//+---------------------------------------------------+
//|Indicator Variables                                |
//| Change these to try your own system               |
//| or add more if you like                           |
//+---------------------------------------------------+
sinput string              string_FastMa     = "//+-----+"; // Fast Ma Parameters
input int                  Fast_ma_period    = 2;           // averaging period 
input int                  Fast_ma_shift     = 0;           // horizontal shift 
input ENUM_MA_METHOD       Fast_ma_method    = MODE_SMA;    // smoothing type 
input ENUM_APPLIED_PRICE   Fast_applied_price= PRICE_CLOSE; // type of price
sinput string              string_SlowMa     = "//+-----+"; // Slow Ma Parameters
input int                  Slow_ma_period    = 5;           // averaging period 
input int                  Slow_ma_shift     = 0;           // horizontal shift 
input ENUM_MA_METHOD       Slow_ma_method    = MODE_SMA;    // smoothing type 
input ENUM_APPLIED_PRICE   Slow_applied_price= PRICE_CLOSE; // type of price
input ushort               BreakOutLevel     = 45;          // Start trade after breakout is reached
input uint                 SignalCandle      = 1;           // Signal Candle
sinput string              string_MM         = "//+-----+"; // Money Management
input ushort               StopLoss          = 25;          // Maximum pips willing to lose per position
input bool                 UseTrailingStop   = false;       // Use TrailingStop
input ENUM_TRAILING_TYPE   TrailingStopType  = type3;       // 
input ushort               TrailingStop      = 40;          // Trailing Stop
input ushort               TRStopLevel_1     = 20;          // Type 3  first level pip gain
input ushort               TrailingStop1     = 20;          // Move Stop to Breakeven
input ushort               TRStopLevel_2     = 30;          // Type 3 second level pip gain
input ushort               TrailingStop2     = 20;          // Move stop to lock is profit
input ushort               TRStopLevel_3     = 50;          // type 3 third level pip gain
input ushort               TrailingStop3     = 20;          // Move stop and trail from there
input ushort               TakeProfit        = 0;           // Maximum profit level achieved.
input double               Margincutoff      = 800;         // Expert will stop trading if equity level decreases to that level
input ulong                m_slippage        = 30;          // Slippage    
//---
bool UseTimeLimit=true;
int StartHour =11;                    // Start trades after time
int StopHour=16;                      // Stop trading after time
bool UseFridayCloseAll=true;
string FridayCloseTime="21:30";
bool UseFridayStopTrading=false;
string FridayStopTradingTime="19:00";
//---
ulong                      m_magic=0;                       // appointment in OnInit ()
int                        handle_iMA_fast;                 // variable for storing the handle of the iMA indicator 
int                        handle_iMA_slow;                 // variable for storing the handle of the iMA indicator 
ENUM_ACCOUNT_MARGIN_MODE   m_margin_mode;
double                     m_adjusted_point;                // point value adjusted for 3 or 5 points
//+---------------------------------------------------+
//|General controls                                   |
//+---------------------------------------------------+
string setup="";
bool YesStop=false;
double lotMM=0.0;
int TradesInThisSymbol=0;
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
   setup="DoubleMA_Crossover "+m_symbol.Name()+"_"+EnumToString(Period());
   m_magic=3000+func_Symbol2Val(m_symbol.Name())*100+PeriodSeconds(Period());
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
   handle_iMA_fast=iMA(m_symbol.Name(),Period(),Fast_ma_period,Fast_ma_shift,Fast_ma_method,Fast_applied_price);
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
   handle_iMA_slow=iMA(m_symbol.Name(),Period(),Slow_ma_period,Slow_ma_shift,Slow_ma_method,Slow_applied_price);
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
//--- Check for Open Position                                          
   HandleOpenPositions();
   if(UseTimeLimit)
     {
      //--- trading from 7:00 to 13:00 GMT
      //--- trading from Start1 to Start2
      YesStop=true;
      MqlDateTime str1;
      TimeToStruct(TimeCurrent(),str1);
      if(str1.hour>=StartHour && str1.hour<=StopHour)
         YesStop=false;
      //      Comment ("Trading has been stopped as requested - wrong time of day");
      if(YesStop)
         return;
     }
   TradesInThisSymbol=openPositions()+openStops();
//--- Check if OK to make new trades                                   
   if(m_account.FreeMargin()<Margincutoff)
      return;
//--- Only allow 1 trade per Symbol
   if(TradesInThisSymbol>0)
      return;
//---
   lotMM=GetLots();
   if(CheckEntryCondition("BUY"))
      if(RefreshRates())
         OpenBuyStopOrder();

   if(CheckEntryCondition("SELL"))
      if(RefreshRates())
         OpenSellStopOrder();
  }
//+------------------------------------------------------------------+
//| CheckExitCondition                                               |
//| Check if any exit condition is met                               |
//+------------------------------------------------------------------+
bool CheckExitCondition(string TradeType)
  {
   bool YesClose=false;
   double fMA=0.0,sMA=0.0;
//---
   YesClose=false;
   fMA=iMAGet(handle_iMA_fast,SignalCandle);
   sMA=iMAGet(handle_iMA_slow,SignalCandle);
//--- Check for cross down
   if(TradeType=="BUY" && fMA-sMA<0)
      YesClose=true;
//--- Check for cross up
   if(TradeType=="SELL" && fMA-sMA>0)
      YesClose=true;
//---
   return(YesClose);
  }
//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//| Check if entry condition is met                                  |
//+------------------------------------------------------------------+
bool CheckEntryCondition(string TradeType)
  {
   bool YesTrade;
   double fMA,sMA;
//---
   YesTrade=false;
   fMA=iMAGet(handle_iMA_fast,SignalCandle);
   sMA=iMAGet(handle_iMA_slow,SignalCandle);

//--- Check for cross up
   if(TradeType=="BUY" && fMA-sMA>0)
      YesTrade=true;
//--- Check for cross down
   if(TradeType=="SELL" && fMA-sMA<0)
      YesTrade=true;
//---
   return(YesTrade);
  }
//+------------------------------------------------------------------+
//| Open BuyStop                                                     |
//| Open a new trade using Buy Stop                                  |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
void OpenBuyStopOrder()
  {
   double myStopLoss=0,myTakeProfit=0;
   double LongTradeRate=m_symbol.Ask()+BreakOutLevel*m_adjusted_point;
   if(StopLoss>0)
      myStopLoss=LongTradeRate-StopLoss*m_adjusted_point;
   if(TakeProfit>0)
      myTakeProfit=LongTradeRate+TakeProfit*m_adjusted_point;
   if(m_trade.BuyStop(lotMM,LongTradeRate,NULL,
      m_symbol.NormalizePrice(myStopLoss),
      m_symbol.NormalizePrice(myTakeProfit)))
     {
      if(m_trade.ResultOrder()==0)
         Print("BuyStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
      //else
      //   Print("BuyStop -> true. Result Retcode: ",m_trade.ResultRetcode(),
      //         ", description of result: ",m_trade.ResultRetcodeDescription());
     }
   else
      Print("BuyStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription());
  }
//+------------------------------------------------------------------+
//| Open SellStop                                                    |
//| Open a new trade using Sell Stop                                 |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
void OpenSellStopOrder()
  {
   double myStopLoss=0,myTakeProfit=0;
   double ShortTradeRate=m_symbol.Bid()-BreakOutLevel*m_adjusted_point;
   if(StopLoss>0)
      myStopLoss=ShortTradeRate+StopLoss*m_adjusted_point;
   if(TakeProfit>0)
      myTakeProfit=ShortTradeRate-TakeProfit*m_adjusted_point;
   if(m_trade.SellStop(lotMM,ShortTradeRate,NULL,
      m_symbol.NormalizePrice(myStopLoss),
      m_symbol.NormalizePrice(myTakeProfit)))
     {
      if(m_trade.ResultOrder()==0)
         Print("SellStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
      //else
      //   Print("SellStop -> true. Result Retcode: ",m_trade.ResultRetcode(),
      //         ", description of result: ",m_trade.ResultRetcodeDescription());
     }
   else
      Print("SellStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of result: ",m_trade.ResultRetcodeDescription());
  }
//+------------------------------------------------------------------------+
//| counts the number of open positions                                    |
//+------------------------------------------------------------------------+
int openPositions()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   return(total);
  }
//+------------------------------------------------------------------------+
//| counts the number of STOP positions                                    |
//+------------------------------------------------------------------------+
int openStops()
  {
   int total=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            total++;

   return(total);
  }
//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//+------------------------------------------------------------------+
void HandleOpenPositions()
  {
   bool YesClose=false;
   double pt=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(CheckExitCondition("BUY"))
                 {
                  ClosePosition(m_position.Ticket());
                 }
               else
                 {
                  if(UseTrailingStop)
                    {
                     HandleTrailingStop("BUY",m_position.Ticket(),m_position.PriceOpen(),
                                        m_position.StopLoss(),m_position.TakeProfit());
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(CheckExitCondition("SELL"))
                 {
                  ClosePosition(m_position.Ticket());
                 }
               else
                 {
                  if(UseTrailingStop)
                    {
                     HandleTrailingStop("SELL",m_position.Ticket(),m_position.PriceOpen(),
                                        m_position.StopLoss(),m_position.TakeProfit());
                    }
                 }
              }
           }

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP && CheckExitCondition("BUY"))
               DeleteOrder(m_order.Ticket());
            if(m_order.OrderType()==ORDER_TYPE_SELL_STOP && CheckExitCondition("SELL"))
               DeleteOrder(m_order.Ticket());
           }
  }
//+------------------------------------------------------------------+
//| Delete Open Position Controls                                    |
//|  Try to close position 3 times                                   |
//+------------------------------------------------------------------+
void DeleteOrder(ulong ticket)
  {
   int CloseCnt;
//-- try to close 3 Times
   CloseCnt=0;
   while(CloseCnt<3)
     {
      if(m_trade.OrderDelete(ticket))
        {
         CloseCnt=3;
        }
      else
        {
         Print("Order ",ticket," delete -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         CloseCnt++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Close Open Position Controls                                     |
//|  Try to close position 3 times                                   |
//+------------------------------------------------------------------+
void ClosePosition(ulong ticket)
  {
   int CloseCnt;
//--- try to close 3 Times
   CloseCnt=0;
   while(CloseCnt<3)
     {
      if(m_trade.PositionClose(ticket))
        {
         CloseCnt=3;
        }
      else
        {
         Print("Position ",ticket," Close -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         CloseCnt++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Modify Open Position Controls                                    |
//|  Try to modify position 3 times                                  |
//+------------------------------------------------------------------+
void ModifyOrder(ulong pos_ticket,double op,double sl,double tp)
  {
   int CloseCnt;
   CloseCnt=0;
   while(CloseCnt<3)
     {
      if(m_trade.PositionModify(pos_ticket,sl,tp))
        {
         CloseCnt=3;
        }
      else
        {
         Print("Position ",pos_ticket," Modify -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         CloseCnt++;
        }
     }
  }
//+------------------------------------------------------------------+
//| HandleTrailingStop                                               |
//| Type 1 moves the stoploss without delay.                         |
//| Type 2 waits for price to move the amount of the trailStop       |
//| before moving stop loss then moves like type 1                   |
//| Type 3 uses up to 3 levels for trailing stop                     |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//| Possible future types                                            |
//| Type 4 uses 2 for 1, every 2 pip move moves stop 1 pip           |
//| Type 5 uses 3 for 1, every 3 pip move moves stop 1 pip           |
//+------------------------------------------------------------------+
//HandleTrailingStop("BUY",OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
int HandleTrailingStop(string type,ulong ticket,double op,double os,double tp)
  {
   double pt,TS=0;
   if(type=="BUY")
     {
      switch(TrailingStopType)
        {
         case type1:
            pt=StopLoss*m_adjusted_point;
            if(m_symbol.Bid()-os>pt)
               ModifyOrder(ticket,op,m_symbol.Bid()-pt,tp);
            break;
         case type2:
            pt=TrailingStop*m_adjusted_point;
            if(m_symbol.Bid()-op>pt && os<m_symbol.Bid()-pt)
               ModifyOrder(ticket,op,m_symbol.Bid()-pt,tp);
            break;
         case type3:
            if(m_symbol.Bid()-op>TRStopLevel_1*m_adjusted_point)
              {
               TS=op+TRStopLevel_1*m_adjusted_point-TrailingStop1*m_adjusted_point;
               if(os<TS)
                 {
                  ModifyOrder(ticket,op,TS,tp);
                 }
              }
            if(m_symbol.Bid()-op>TRStopLevel_2*m_adjusted_point)
              {
               TS=op+TRStopLevel_2*m_adjusted_point-TrailingStop2*m_adjusted_point;
               if(os<TS)
                 {
                  ModifyOrder(ticket,op,TS,tp);
                 }
              }
            if(m_symbol.Bid()-op>TRStopLevel_3*m_adjusted_point)
              {
               //                   TS = op + TRStopLevel_3 * Point - TrailingStop3*Point;
               TS=m_symbol.Bid()-TrailingStop3*m_adjusted_point;
               if(os<TS)
                 {
                  ModifyOrder(ticket,op,TS,tp);
                 }
              }
            break;
        }
      return(0);
     }
   if(type=="SELL")
     {
      switch(TrailingStopType)
        {
         case type1:
            pt=StopLoss*m_adjusted_point;
            if(os-m_symbol.Ask()>pt)
               ModifyOrder(ticket,op,m_symbol.Ask()+pt,tp);
            break;
         case type2:
            pt=TrailingStop*m_adjusted_point;
            if(op-m_symbol.Ask()>pt && os>m_symbol.Ask()+pt)
               ModifyOrder(ticket,op,m_symbol.Ask()+pt,tp);
            break;
         case type3:
            if(op-m_symbol.Ask()>TRStopLevel_1*m_adjusted_point)
              {
               TS=op-TRStopLevel_1*m_adjusted_point+TrailingStop1*m_adjusted_point;
               if(os>TS)
                 {
                  ModifyOrder(ticket,op,TS,tp);
                 }
              }
            if(op-m_symbol.Ask()>TRStopLevel_2*m_adjusted_point)
              {
               TS=op-TRStopLevel_2*m_adjusted_point+TrailingStop2*m_adjusted_point;
               if(os>TS)
                 {
                  ModifyOrder(ticket,op,TS,tp);
                 }
              }
            if(op-m_symbol.Ask()>TRStopLevel_3*m_adjusted_point)
              {
               //                  TS = op - TRStopLevel_3 * Point + TrailingStop3 * Point;               
               TS=m_symbol.Ask()+TrailingStop3*m_adjusted_point;
               if(os>TS)
                 {
                  ModifyOrder(ticket,op,TS,tp);
                 }
              }
            break;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Get number of lots for this trade                                |
//+------------------------------------------------------------------+
double GetLots()
  {
   double lot;
   if(MoneyManagement)
     {
      lot=LotsOptimized();
     }
   else
     {
      lot=Lots;
      if(AccountIsMini)
        {
         if(lot > 1.0) lot=lot/10;
         if(lot < 0.1) lot=0.1;
        }
     }
   return(lot);
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
//--- select lot size
   lot=NormalizeDouble(MathFloor(m_account.FreeMargin()*TradeSizePercent/10000)/10,1);
//--- lot at this point is number of standard lots
//---  if (Debug) Print ("Lots in LotsOptimized : ",lot);
//--- Check if mini or standard Account
   if(AccountIsMini)
     {
      lot=MathFloor(lot*10)/10;
      // Use at least 1 mini lot
      if(lot<0.1)
         lot=0.1;
      if(lot>MaxLots)
         lot=MaxLots;
     }
   else
     {
      if(lot<1.0)
         lot=1.0;
      if(lot>MaxLots)
         lot=MaxLots;
     }
   return(lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int func_Symbol2Val(string symbol)
  {
   if(symbol=="AUDCAD")
     {
      return(1);
     }
   else if(symbol=="AUDJPY")
     {
      return(2);
     }
   else if(symbol=="AUDNZD")
     {
      return(3);
     }
   else if(symbol=="AUDUSD")
     {
      return(4);
     }
   else if(symbol=="CHFJPY")
     {
      return(5);
     }
   else if(symbol=="EURAUD")
     {
      return(6);
     }
   else if(symbol=="EURCAD")
     {
      return(7);
     }
   else if(symbol=="EURCHF")
     {
      return(8);
     }
   else if(symbol=="EURGBP")
     {
      return(9);
     }
   else if(symbol=="EURJPY")
     {
      return(10);
     }
   else if(symbol=="EURUSD")
     {
      return(11);
     }
   else if(symbol=="GBPCHF")
     {
      return(12);
     }
   else if(symbol=="GBPJPY")
     {
      return(13);
     }
   else if(symbol=="GBPUSD")
     {
      return(14);
     }
   else if(symbol=="NZDUSD")
     {
      return(15);
     }
   else if(symbol=="USDCAD")
     {
      return(16);
     }
   else if(symbol=="USDCHF")
     {
      return(17);
     }
   else if(symbol=="USDJPY")
     {
      return(18);
     }
   else
     {
      Comment("unexpected Symbol");
      return(0);
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
