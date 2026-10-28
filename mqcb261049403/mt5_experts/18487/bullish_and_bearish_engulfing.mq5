//+------------------------------------------------------------------+
//|                                Bullish and Bearish Engulfing.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.005"
#property description "Bullish and Bearish Engulfing"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedMargin  m_money;
//--- input parameters
input ENUM_POSITION_TYPE   InpBullishEngulfing  = POSITION_TYPE_BUY;    // Bullish Engulfing
input ENUM_POSITION_TYPE   InpBearishEngulfing  = POSITION_TYPE_SELL;   // Bearish Engulfing
input double               InpRisk              = 5;                    // Risk in percent for a deal
input uchar                InpShift             = 1;                    // Shift in bars (from 1 to 255)
input ushort               InpDistance          = 0;                    // Distance (in pips)
input bool                 InpOppositeSignal    = true;                 // true -> close opposite positions
input ulong                m_magic              = 270656512;            // magic number
//---
ulong                      m_slippage=30;                               // slippage
double                     ExtDistance=0.0;
double                     m_lots_min=0.0;
double                     m_adjusted_point;                            // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpShift<1)
     {
      Print("The parameter \"Shift\" can not be less than \"1\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

   m_lots_min=m_symbol.LotsMin();

//string err_text="";
//if(!CheckVolumeValue(m_lots,err_text))
//  {
//   Print(err_text);
//   return(INIT_PARAMETERS_INCORRECT);
//  }
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

   ExtDistance=InpDistance *m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(InpRisk);
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

   MqlRates rates[];
   ArraySetAsSeries(rates,true); // true -> rates[0] - the rightmost bar
   int start_pos=InpShift;
   int copied=CopyRates(m_symbol.Name(),Period(),start_pos,2,rates);
   if(copied==2)
     {
      // OHLC
      if(rates[0].open<rates[0].close) // bar with the index "0" - bullish
        {
         if(rates[1].open>rates[1].close) // bar with the index "1" - bearish
           {
            if(rates[0].high>rates[1].high+ExtDistance &&
               rates[0].close>rates[1].open+ExtDistance &&
               rates[0].open<rates[1].close-ExtDistance &&
               rates[0].low<rates[1].low-ExtDistance)
              {
               if(!RefreshRates())
                 {
                  PrevBars=iTime(m_symbol.Name(),Period(),1);
                  return;
                 }
               //--- bullish Engulfing
               if(InpOppositeSignal)
                 {
                  if(InpBullishEngulfing==POSITION_TYPE_BUY)
                    {
                     ClosePositions(POSITION_TYPE_BUY);
                     OpenSell(0.0,0.0);
                    }
                  else if(InpBullishEngulfing==POSITION_TYPE_SELL)
                    {
                     ClosePositions(POSITION_TYPE_SELL);
                     OpenBuy(0.0,0.0);
                    }
                 }
               else
                 {
                  ClosePositions(POSITION_TYPE_SELL);
                  OpenBuy(0.0,0.0);
                 }
              }
           }
        }
      else if(rates[0].open>rates[0].close) // bar with the index "0" - bearish
        {
         if(rates[1].open<rates[1].close) // bar with the index "1" - bullish
           {
            if(rates[0].high>rates[1].high+ExtDistance &&
               rates[0].open>rates[1].close+ExtDistance &&
               rates[0].close<rates[1].open-ExtDistance &&
               rates[0].low<rates[1].low-ExtDistance)
              {
               if(!RefreshRates())
                 {
                  PrevBars=iTime(m_symbol.Name(),Period(),1);
                  return;
                 }
               //--- bearish Engulfing
               if(InpOppositeSignal)
                 {
                  if(InpBullishEngulfing==POSITION_TYPE_BUY)
                    {
                     ClosePositions(POSITION_TYPE_BUY);
                     OpenSell(0.0,0.0);
                    }
                  else if(InpBullishEngulfing==POSITION_TYPE_SELL)
                    {
                     ClosePositions(POSITION_TYPE_SELL);
                     OpenBuy(0.0,0.0);
                    }
                 }
               else
                 {
                  ClosePositions(POSITION_TYPE_BUY);
                  OpenSell(0.0,0.0);
                 }
              }
           }
        }
     }
   else
     {
      PrevBars=iTime(m_symbol.Name(),Period(),1);
      Print("Failed to get history data for the symbol ",Symbol());
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
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
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

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
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
