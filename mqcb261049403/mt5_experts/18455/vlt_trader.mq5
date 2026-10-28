//+------------------------------------------------------------------+
//|                          VLT_TRADER(barabashkakvn's edition).mq5 |
//|                                                     FORTRADER.RU |
//|                                          http://www.fortrader.ru |
//+------------------------------------------------------------------+
#property copyright "FORTRADER.RU"
#property link      "http://www.fortrader.ru"
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
input double   InpLots          = 0.1;       // Lots
input ushort   InpTakeProfit    = 10;        // Take Profit (in pips)
input ushort   InpStopLoss      = 10;        // Stop Loss (in pips)
input ushort   InpSizeCandles   = 100;       // Maximum size candles (in pips)
input uchar    InpCountCandles  = 6;         // Count candles (min value == 1)
//---
ulong          m_magic=191570542;            // magic number
ulong          m_slippage=10;                // slippage
//---
double         ExtTakeProfit=0.0;
double         ExtStopLoss=0.0;
double         ExtSizeCandles=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpCountCandles<1)
     {
      Print("\"Count candles\" < 1");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
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

   ExtTakeProfit  =  InpTakeProfit  * m_adjusted_point;
   ExtStopLoss    =  InpStopLoss    * m_adjusted_point;
   ExtSizeCandles =  InpSizeCandles * m_adjusted_point;
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

   double VLT_1=0.0,VLT_minimum=DBL_MAX;

//--- gap protection
   double high_0=iHigh(m_symbol.Name(),Period(),0);
   double high_1=iHigh(m_symbol.Name(),Period(),1);
   double low_1=iLow(m_symbol.Name(),Period(),1);
   if(high_0>high_1)
      return;

   VLT_1=MathAbs(high_1-low_1);

   for(int i=2;i<(2+InpCountCandles);i++)
     {
      double size=MathAbs(iHigh(m_symbol.Name(),Period(),i)-iLow(m_symbol.Name(),Period(),i));
      if(size<ExtSizeCandles  &&  size>0.0)
        {
         if(size<VLT_minimum)
            VLT_minimum=size;
        }
     }

   int count_buys=0,count_sells=0;
   CalculatePositions(count_buys,count_sells);

   if(VLT_1<VLT_minimum && count_buys==0)
     {
      double OpenPrice  = m_symbol.NormalizePrice(high_1+10*m_adjusted_point);
      double Stop       = m_symbol.NormalizePrice(OpenPrice-ExtStopLoss);
      double Profit     = m_symbol.NormalizePrice(OpenPrice+ExtTakeProfit);
      DeleteOrders(ORDER_TYPE_BUY_STOP);
      if(!m_trade.BuyStop(InpLots,OpenPrice,m_symbol.Name(),Stop,Profit))
        {
         Print("BuyStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription());
        }
     }

   if(VLT_1<VLT_minimum && count_sells==0)
     {
      double OpenPrice  = m_symbol.NormalizePrice(low_1-10*m_adjusted_point);
      double Stop       = m_symbol.NormalizePrice(OpenPrice+ExtStopLoss);
      double Profit     = m_symbol.NormalizePrice(OpenPrice-ExtTakeProfit);
      DeleteOrders(ORDER_TYPE_SELL_STOP);
      if(!m_trade.SellStop(InpLots,OpenPrice,m_symbol.Name(),Stop,Profit))
        {
         Print("SellStop -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription());
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
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
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
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
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
void DeleteOrders(ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
