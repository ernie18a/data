//+------------------------------------------------------------------+
//|                                                  EveningStar.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.003"
#property description "An \"Evening Star\" is a bearish candlestick pattern"
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
input ENUM_POSITION_TYPE   InpEveningStar       = POSITION_TYPE_SELL;   // Evening Star
input ushort               InpTakeProfit        = 150;                  // Take Profit (in pips)
input ushort               InpStopLoss          = 50;                   // Stop Loss (in pips)
input double               InpRisk              = 5;                    // Risk in percent for a deal
input uchar                InpShift             = 1;                    // Shift in bars (from 1 to 255)
input bool                 InpGap               = true;                 // Gap. true -> gap is taken into account
input bool                 InpCandle2Type       = true;                 // Candle 2 type. true -> type of candle 2 is taken into account
input bool                 InpCandleSizes       = true;                 // Candle sizes. true -> candle sizes is taken into account
input bool                 InpOppositeSignal    = true;                 // true -> close opposite positions
input ulong                m_magic              = 270656512;            // magic number
//---
ulong                      m_slippage=30;                               // slippage
double                     ExtTakeProfit=0.0;
double                     ExtStopLoss=0.0;
double                     ExtDistance=0.0;                             // minimum size of gap
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

   ExtTakeProfit  =InpTakeProfit *  m_adjusted_point;
   ExtStopLoss    =InpStopLoss   *  m_adjusted_point;
   ExtDistance=1             *m_adjusted_point;                                      // minimum size of gap
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
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   MqlRates rates[];
   ArraySetAsSeries(rates,true); // true -> rates[0] - the rightmost bar
   int start_pos  =InpShift;     // start position 
   int count      =3;            // data count to copy 
   int copied=CopyRates(m_symbol.Name(),Period(),start_pos,count,rates);
/*
   "2"    "1"    "0"
   
           |
        C --- 
          | |
          | |     |
    |   O ---  O --- 
 C ---     |     ||| 
   | |           |||
   | |           |||
   | |           |||
   | |         C ---
   | |            |
   | | 
 O ---
    |
*/
   if(copied==count)
     {
      //--- OHLC
      //--- rough check: bar with the index "0" - bearish and bar with the index "2" - bullish
      if(rates[0].open>rates[0].close && rates[2].open<rates[2].close) // 
        {
         if(InpCandleSizes) // Candle sizes 
            if(MathAbs(rates[0].open-rates[0].close)<MathAbs(rates[1].open-rates[1].close) ||
               MathAbs(rates[2].open-rates[2].close)<MathAbs(rates[1].open-rates[1].close))
               return;
         if(InpCandle2Type) // Candle 2 type
           {
            if(rates[1].open>rates[1].close)
               return;
           }
         else
           {
            if(rates[1].close>rates[1].open)
               return;
           }
         if(InpGap) // Gap
            if(rates[0].open>=rates[1].close-ExtDistance || rates[1].open<=rates[2].close+ExtDistance)
               return;
         //--- open positions
         if(!RefreshRates())
           {
            PrevBars=iTime(1);
            return;
           }
         if(InpEveningStar==POSITION_TYPE_BUY)
           {
            if(InpOppositeSignal)
               ClosePositions(POSITION_TYPE_SELL);
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp);
            return;
           }
         if(InpEveningStar==POSITION_TYPE_SELL)
           {
            if(InpOppositeSignal)
               ClosePositions(POSITION_TYPE_BUY);
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp);
            return;
           }
        }
     }
   else
     {
      PrevBars=iTime(1);
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
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
