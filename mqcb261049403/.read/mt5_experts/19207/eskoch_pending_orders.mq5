//+------------------------------------------------------------------+
//|              e-Skoch pending orders(barabashkakvn's edition).mq5 |
//|                      Copyright © 2012, MetaQuotes Software Corp. |
//|                                         http://www.fxgeneral.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, MetaQuotes Software Corp."
#property link      "http://www.fxgeneral.com"
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
//--- input parameters
input double   InpLots           = 0.01;     // Lots
input ushort   InpTakeProfit_BUY = 60;       // Take Profit for BUY (in pips)
input ushort   InpStopLoss_BUY   = 10;       // Stop Loss for BUY (in pips)
input ushort   InpTakeProfit_SELL= 60;       // Take Profit for SELL (in pips)
input ushort   InpStopLoss_SELL  = 30;       // Stop Loss for SELL (in pips)
input ushort   InpIndentingHigh  = 70;       // Indenting price from High (in pips)
input ushort   InpIndentingLow   = 70;       // Indenting price from Low (in pips)
input bool     InpCheckTrade     = true;     // true -> If there is a position, do not place a pending order
input double   InpPercentEquity  = 2.2;      // Percent equity
input ulong    m_magic           = 15489;    // magic number
//---
ulong          m_slippage=30;                // slippage

double         ExtTakeProfit_BUY=0.0;
double         ExtStopLoss_BUY=0.0;
double         ExtTakeProfit_SELL=0.0;
double         ExtStopLoss_SELL=0.0;
double         ExtIndentingHigh=0.0;
double         ExtIndentingLow=0.0;
//---
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
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

   ExtTakeProfit_BUY    = InpTakeProfit_BUY  * m_adjusted_point;
   ExtStopLoss_BUY      = InpStopLoss_BUY    * m_adjusted_point;
   ExtTakeProfit_SELL   = InpTakeProfit_SELL * m_adjusted_point;
   ExtStopLoss_SELL     = InpStopLoss_SELL   * m_adjusted_point;
   ExtIndentingHigh     = InpIndentingHigh   * m_adjusted_point;
   ExtIndentingLow      = InpIndentingLow    * m_adjusted_point;
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
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
     {
      PrevBars=iTime(m_symbol.Name(),Period(),1);
      return;
     }
//---
   double _price=0.0,oldprice=0.0;
   double _tpBuy=0.0,_tpSell=0.0,_slBuy=0.0,_slSell=0.0;
//---
   int count_buys=0;
   int count_sells=0;
   CalculatePositions(count_buys,count_sells);
   if(count_buys+count_sells==0)
      GlobalVariableSet("eq_"+IntegerToString(m_magic),m_account.Equity());
   Comment("Control equity ",GlobalVariableGet("eq_"+IntegerToString(m_magic)),"\n",
           "current equity ",m_account.Equity(),"\n",
           "current percentage of growth Equity ",100.0*(m_account.Equity()-GlobalVariableGet("eq_"+IntegerToString(m_magic)))/GlobalVariableGet("eq_"+IntegerToString(m_magic))," %");
   CheckProfit();
//---
   double high_2=iHigh(m_symbol.Name(),Period(),2);
   double high_1=iHigh(m_symbol.Name(),Period(),1);
   double high_2_D1=iHigh(m_symbol.Name(),PERIOD_D1,2);
   double high_1_D1=iHigh(m_symbol.Name(),PERIOD_D1,1);
   if(high_2==0.0 || high_1==0.0 || high_2_D1==0.0 || high_1_D1==0.0)
     {
      PrevBars=iTime(m_symbol.Name(),Period(),1);
      return;
     }
   double low_2=iLow(m_symbol.Name(),Period(),2);
   double low_1=iLow(m_symbol.Name(),Period(),1);
   double low_2_D1=iLow(m_symbol.Name(),PERIOD_D1,2);
   double low_1_D1=iLow(m_symbol.Name(),PERIOD_D1,2);
   if(low_2==0.0 || low_1==0.0 || low_2_D1==0.0 || low_1_D1==0.0)
     {
      PrevBars=iTime(m_symbol.Name(),Period(),1);
      return;
     }
//---
   if(high_2_D1>high_1_D1)
      if(high_2>high_1 && count_buys==0)
        {
         if(!InpCheckTrade || (InpCheckTrade && count_buys==0))
           {
            _price=high_1+ExtIndentingHigh;
            if(ExtStopLoss_BUY>0.0)
               _slBuy=_price-ExtStopLoss_BUY;
            if(ExtTakeProfit_BUY>0.0)
               _tpBuy=_price+ExtTakeProfit_BUY;
            oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
            if(oldprice==-1 || _price<oldprice) // No order or New price is better
              {
               DeleteOrders(ORDER_TYPE_BUY_STOP);
               if(m_trade.BuyStop(InpLots,m_symbol.NormalizePrice(_price),m_symbol.Name(),
                  m_symbol.NormalizePrice(_slBuy),m_symbol.NormalizePrice(_tpBuy)))
                  Print("BUY_STOP - > true. ticket of order = ",m_trade.ResultOrder());
               else
                  Print("BUY_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of order: ",m_trade.ResultOrder());
              }
           }
        }
//---
   if(low_2_D1<low_1_D1)
      if(low_2<low_1)
         if(!InpCheckTrade || (InpCheckTrade && count_sells==0))
           {
            _price=low_1-ExtIndentingLow;
            if(ExtStopLoss_SELL>0.0)
               _slSell=_price+ExtStopLoss_SELL;
            if(ExtTakeProfit_SELL>0.0)
               _tpSell=_price-ExtTakeProfit_SELL;
            oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
            if(oldprice==-1 || _price>oldprice) // No order or New price is better
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               if(m_trade.SellStop(InpLots,m_symbol.NormalizePrice(_price),m_symbol.Name(),
                  m_symbol.NormalizePrice(_slSell),m_symbol.NormalizePrice(_tpSell)))
                  Print("SELL_STOP - > true. ticket of order = ",m_trade.ResultOrder());
               else
                  Print("SELL_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                        ", ticket of order: ",m_trade.ResultOrder());
              }
           }
  }
//+------------------------------------------------------------------+
//| Check profit                                                     |
//+------------------------------------------------------------------+
void CheckProfit()
  {
   if(100.0*(m_account.Equity()-GlobalVariableGet("eq_"+IntegerToString(m_magic)))/GlobalVariableGet("eq_"+IntegerToString(m_magic))>=InpPercentEquity)
      CloseAllPositions();
   return;
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Calculate all positions and pending orders                       |
//+------------------------------------------------------------------+
int CalculateAll()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Price last stop order                                            |
//+------------------------------------------------------------------+
double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time=0;
   double last_price=-1.0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==pending_order_type)
               if(m_order.TimeSetup()>last_time)
                 {
                  last_time=m_order.TimeSetup();
                  last_price=m_order.PriceOpen();
                 }
//---
   return(last_price);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
// double min_volume=m_symbol.LotsMin();
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
// double max_volume=m_symbol.LotsMax();
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
// double volume_step=m_symbol.LotsStep();
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0.0;
   count_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
