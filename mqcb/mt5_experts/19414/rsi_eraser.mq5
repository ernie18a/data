//+------------------------------------------------------------------+
//|                                                   RSI Eraser.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                             https://www.mql5.com/ru/forum/219752 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/forum/219752"
#property version   "1.001"
#property description "Based on the theme https://www.mql5.com/ru/forum/219752"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedRisk m_money;
//--- input parameters
input int      Inp_ma_period  = 14;          // RSI: averaging period 
input ushort   InpStopLoss    = 50;          // Stop Loss (in pips)
input double   Risk           = 5;           // Risk in percent for a deal from a free margin
//---
ulong          m_ticket;
ulong          m_magic=176747716;            // magic number
ulong          m_slippage=30;                // slippage

double         ExtStopLoss=0;
int            handle_iRSI;                  // variable for storing the handle of the iRSI indicator
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

   ExtStopLoss=InpStopLoss*m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(Risk);
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),PERIOD_H1,Inp_ma_period,PRICE_CLOSE);
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
   int signal=SignalsRSI();
   if(signal==0)
      return;
//---
   ulong    last_ticket_buy=ULONG_MAX;
   ulong    last_ticket_sell=ULONG_MAX;
   datetime last_DEAL_ENTRY_IN_buy=0;
   datetime last_DEAL_ENTRY_IN_sell=0;
   int count_buys=0;
   int count_sells=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.Time()>last_DEAL_ENTRY_IN_buy)
                 {
                  last_ticket_buy=m_position.Ticket();
                  last_DEAL_ENTRY_IN_buy=m_position.Time();
                 }
               count_buys++;
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.Time()>last_DEAL_ENTRY_IN_sell)
                 {
                  last_ticket_sell=m_position.Ticket();
                  last_DEAL_ENTRY_IN_sell=m_position.Time();
                 }
               count_sells++;
              }
           }
//---
   bool        buy_is_allowed=true;
   bool        sell_is_allowed=true;
   MqlDateTime str_time_current;
   MqlDateTime str_last_DEAL_ENTRY_IN_buy;
   MqlDateTime str_last_DEAL_ENTRY_IN_sell;
   TimeToStruct(TimeCurrent(),str_time_current);
   if(last_ticket_buy!=ULONG_MAX)
     {
      TimeToStruct(last_DEAL_ENTRY_IN_buy,str_last_DEAL_ENTRY_IN_buy);
      if(str_last_DEAL_ENTRY_IN_buy.day==str_time_current.day || str_last_DEAL_ENTRY_IN_buy.day>str_time_current.day)
         buy_is_allowed=false;
     }
   if(last_ticket_sell!=ULONG_MAX)
     {
      TimeToStruct(last_DEAL_ENTRY_IN_sell,str_last_DEAL_ENTRY_IN_sell);
      if(str_last_DEAL_ENTRY_IN_sell.day==str_time_current.day || str_last_DEAL_ENTRY_IN_sell.day>str_time_current.day)
         sell_is_allowed=false;
     }
//---
   if(!RefreshRates())
      return;
   if(buy_is_allowed && signal==1)
     {
      double sl_low=iLow(1,m_symbol.Name(),PERIOD_D1);
      if(sl_low==0.0)
         return;
      sl_low-=10*m_adjusted_point;
      double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      if(sl_low<sl)
         return;
      double tp=(sl==0)?0.0:m_symbol.Ask()+3.0*ExtStopLoss;
      OpenBuy(sl,tp);
     }
   if(sell_is_allowed && signal==-1)
     {
      double sl_high=iHigh(1,m_symbol.Name(),PERIOD_D1);
      if(sl_high==0.0)
         return;
      sl_high+=10*m_adjusted_point;
      double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      if(sl_high>sl)
         return;
      double tp=(sl==0.0)?0.0:m_symbol.Bid()-3.0*ExtStopLoss;
      OpenSell(sl,tp);
     }
//--- breakeven
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.Profit()>0.0)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtStopLoss)
                     if(!CompareDoubles(m_position.StopLoss(),m_position.PriceOpen()))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                       }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtStopLoss)
                     if(!CompareDoubles(m_position.StopLoss(),m_position.PriceOpen()))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                       }
              }
//---
  }
//+------------------------------------------------------------------+
//| Signals RSI                                                      |
//|   RSI > 50.0 -> signal BUY  (+1)                                 |
//|   RSI < 50.0 -> signal SELL (-1)                                 |
//|        ERROR ->             (0)                                  |
//+------------------------------------------------------------------+
int  SignalsRSI()
  {
   double rsi=iRSIGet(1);
   if(rsi==0.0)
      return(0);
   if(rsi>50.0)
      return(1);
   else
      return(-1);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
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
//| Get value of buffers for the iRSI                                |
//+------------------------------------------------------------------+
double iRSIGet(const int index)
  {
   double RSI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,0,index,1,RSI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RSI[0]);
  }
//+------------------------------------------------------------------+ 
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0)
      high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0)
      low=Low[0];
   return(low);
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
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
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
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,m_symbol.Digits())==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
   DebugBreak();
  }
//+------------------------------------------------------------------+
