//+------------------------------------------------------------------+
//|                         3MACross EA(barabashkakvn's edition).mq5 |
//|                                  Copyright © 2007, Forex-Experts |
//|                                     http://www.forex-experts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Forex-Experts"
#property link      "http://www.forex-experts.com"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedMargin m_money;
//---
#define COMMENT "3MaCross_EA"
//--- input parameters
sinput string        _0_                  = "Trade parameters:";
input double         InpLots              = 0.1;         // Lots (if <=0 -> use risk from a free margin)
input ushort         InpStopLoss          = 0;           // Stop Loss (in pips)
input ushort         InpTakeProfit        = 145;         // Take Profit (in pips)
input ushort         InpTrailingStop      = 0;           // Trailing Stop (in pips)
ushort               InpTrailingStep      = 5;           // Trailing Step (in pips)
input double         Risk                 = 10;          // Risk in percent for a deal from a free margin
input bool           InpAutoSLTP          = false;       // Auto SL/TP (only if "Trailing Stop" == 0)
input bool           InpTradeAtCloseBar   = true;        // Trade at close bar
input ushort         InpBreakEven         = 15;          // BreakEven (only if "Trailing Stop"==0 and "Auto SL/TP"==false)
input int            InpMaxOpenPositions  = 5;           // Max open positions
sinput string        _1_                  = "MA Cross 3MACross Alert WarnSig:";
sinput string        _2_                  = "Parameters of the first Moving Average";
input int            InpMAPeriodFirst     = 23;          // Period of the first Moving Average
input int            InpMAShiftFirst      = 0;           // Shift of the first Moving Average
input ENUM_MA_METHOD InpMAMethodFirst     = MODE_SMMA;   // Method of the first Moving Average
sinput string        _3_                  = "Parameters of the second Moving Average";
input int            InpMAPeriodSecond    = 61;          // Period of the second Moving Average
input int            InpMAShiftSecond     = 0;           // Shift of the second Moving Average
input ENUM_MA_METHOD InpMAMethodSecond    = MODE_SMMA;   // Method of the second Moving Average
sinput string        _4_                  = "Parameters of the Third Moving Average";
input int            InpMAPeriodThird     = 122;         // Period of the third Moving Average
input int            InpMAShiftThird      = 0;           // Shift of the third Moving Average
input ENUM_MA_METHOD InpMAMethodThird     = MODE_SMMA;   // Method of the third Moving Average
input bool           crossesOnCurrent     = true;
input bool           alertsOn             = true;
input bool           alertsMessage        = true;
input bool           alertsSound          = false;
input bool           alertsEmail          = false;
sinput string        _5_                  = "Price Channel:";
input int            InpChannelPeriod     = 15;
//---
ulong                m_ticket;
ulong                m_magic=15489;                // magic number
ulong                m_slippage=30;                // slippage

double               ExtStopLoss=0.0;
double               ExtTakeProfit=0.0;
double               ExtTrailingStop=0.0;
double               ExtTrailingStep=0.0;
double               ExtBreakEven=0.0;

int                  TradeBar=0;
int                  handle_iCustom_3MACross;      // variable for storing the handle of the iCustom indicator 
int                  handle_iCustom_PriceChannel;  // variable for storing the handle of the iCustom indicator 
double               m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpAutoSLTP && InpTrailingStop!=0)
     {
      Print("It is necessary to choose only one parameter: either \"Trailing Stop\" or \"Auto SL/TP\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpBreakEven>0 && (InpTrailingStop!=0 || InpAutoSLTP))
     {
      Print("It is necessary to choose only one parameter: either \"Trailing Stop\" or \"Auto SL/TP\" or \"BreakEven\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(InpTradeAtCloseBar)
      TradeBar=1;
   else
      TradeBar=0;
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(InpLots>0.0)
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

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
   ExtBreakEven=InpBreakEven*m_adjusted_point;
//---
   if(InpLots<=0.0)
     {
      if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
         return(INIT_FAILED);
      m_money.Percent(Risk);
     }
//--- create handle of the indicator iCustom
   handle_iCustom_3MACross=iCustom(m_symbol.Name(),Period(),"MA Cross 3MACross Alert WarnSig",
                                   "Parameters of the first Moving Average",
                                   InpMAPeriodFirst,
                                   InpMAShiftFirst,
                                   InpMAMethodFirst,
                                   "Parameters of the second Moving Average",
                                   InpMAPeriodSecond,
                                   InpMAShiftSecond,
                                   InpMAMethodSecond,
                                   "Parameters of the Third Moving Average",
                                   InpMAPeriodThird,
                                   InpMAShiftThird,
                                   InpMAMethodThird);
//--- if the handle is not created 
   if(handle_iCustom_3MACross==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustom_PriceChannel=iCustom(m_symbol.Name(),Period(),"price_channel",InpChannelPeriod);
//--- if the handle is not created 
   if(handle_iCustom_PriceChannel==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
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
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   double sig_buy = iCustomGet(handle_iCustom_3MACross,0,TradeBar);     // 0 -> "Cross Up" buffer
   double sig_sell= iCustomGet(handle_iCustom_3MACross,1,TradeBar);     // 1 -> "Cross Down"  buffer
   double ch_up   = iCustomGet(handle_iCustom_PriceChannel,0,TradeBar); // 0 -> "Channel upper"  buffer
   double ch_dn   = iCustomGet(handle_iCustom_PriceChannel,1,TradeBar); // 1 -> "Channel lower"  buffer
   if(sig_buy==0.0 || sig_sell==0.0 || ch_up==0.0 || ch_dn==0.0)
     {
      PrevBars=iTime(1);
      return;
     }
   if(!RefreshRates())
     {
      PrevBars=iTime(1);
      return;
     }

   int count_buys=0;
   int count_sells=0;
   CalculatePositions(count_buys,count_sells);

   if(sig_buy!=EMPTY_VALUE)
     {
      if(count_sells>0)
         ClosePositions(POSITION_TYPE_SELL);
      if(count_buys<InpMaxOpenPositions)
        {
         double sl=0.0;
         double tp=0.0;
         if(!InpAutoSLTP)
           {
            sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
           }
         else
           {
            sl=(ch_dn<m_symbol.Ask()-ExtBreakEven)?ch_dn:m_symbol.Ask()-ExtBreakEven;
            tp=(ch_up>m_symbol.Ask()+ExtBreakEven)?ch_up:m_symbol.Ask()+ExtBreakEven;
           }
         OpenBuy(sl,tp);
        }
     }
   if(sig_sell!=EMPTY_VALUE)
     {
      if(count_buys>0)
         ClosePositions(POSITION_TYPE_BUY);
      if(count_sells<InpMaxOpenPositions)
        {
         double sl=0.0;
         double tp=0.0;
         if(!InpAutoSLTP)
           {
            sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
           }
         else
           {
            sl=(ch_up>m_symbol.Bid()+ExtBreakEven)?ch_up:m_symbol.Bid()+ExtBreakEven;
            tp=(ch_dn<m_symbol.Bid()-ExtBreakEven)?ch_dn:m_symbol.Bid()-ExtBreakEven;
           }
         OpenSell(sl,tp);
        }
     }
//--- trailing
   if(InpTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(InpTrailingStop>0)
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                     if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Trailing modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }
               else if(InpAutoSLTP)
                 {
                  if(!CompareDoubles(m_position.StopLoss(),ch_dn) && ch_dn>m_position.StopLoss())
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(ch_dn),
                        m_position.TakeProfit()))
                        Print("Auto SL/TP modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
                 }
               else if(InpBreakEven>0)
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtBreakEven+ExtTrailingStep)
                     if(!CompareDoubles(m_position.StopLoss(),m_position.PriceOpen()+ExtBreakEven))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()+ExtBreakEven),
                           m_position.TakeProfit()))
                           Print("BreakEven modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }
              }
            else
              {
               if(InpTrailingStop>0)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                     if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                        (m_position.StopLoss()==0))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Trailing modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        return;
                       }
                 }
               else if(InpAutoSLTP)
                 {
                  if(!CompareDoubles(m_position.StopLoss(),ch_up) && ch_up<m_position.StopLoss())
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(ch_up),
                        m_position.TakeProfit()))
                        Print("Auto SL/TP modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
                 }
               else if(InpBreakEven>0)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtBreakEven+ExtTrailingStep)
                     if(!CompareDoubles(m_position.StopLoss(),m_position.PriceOpen()-ExtBreakEven))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()-ExtBreakEven),
                           m_position.TakeProfit()))
                           Print("BreakEven modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }
              }
           }
//---
   return;
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
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(int handle,const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
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
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
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

   double check_open_long_lot=0.0;

   if(InpLots<=0.0)
     {
      check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_long_lot==0.0)
         return;
     }
   else
      check_open_long_lot=InpLots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),2.0*check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

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

   double check_open_short_lot=0.0;

   if(InpLots<=0.0)
     {
      check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_short_lot==0.0)
         return;
     }
   else
      check_open_short_lot=InpLots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),2.0*check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

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
//DebugBreak();
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
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
