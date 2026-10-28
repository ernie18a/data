//+------------------------------------------------------------------+
//|                         Momo_trades(barabashkakvn's edition).mq5 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "#xrustsolution#"
#property link      "#xrust.ucoz.net#"
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
//--- input parameters
input bool     InpManualLot         = true;  // Manual Lot: "true" -> use manual lot, "false" -> use risk percent
input double   InpLots              = 0.1;   // Lots
input ushort   InpStopLoss          = 25;    // Stop Loss (in pips)
input ushort   InpTakeProfit        = 0;     // Take Profit, if "0" we use "Breakeven"(in pips)
input ushort   InpTrailingStop      = 0;     // Trailing Stop, if we use "Breakeven" - we do not use trailing (in pips)
input ushort   InpTrailingStep      = 5;     // Trailing Step (in pips)
input ushort   InpBreakeven         = 10;    // Breakeven (in pips)
input double   Risk                 = 10;    // Risk in percent for a deal from a free margin
input ushort   InpPriseShift        = 5;     // Price Shift between Close and Moving Average (in pips)
input bool     InpCloseEndDay       = true;  // Close End Day
input int      Inp_ma_period        = 22;    // Moving Average: period of ma 
input int      Inp_MA_Bar           = 6;     // Moving Average: bar from which we get the value 
input int      Inp_fast_ema_period  = 12;    // MACD: period of fast ma 
input int      Inp_slow_ema_period  = 26;    // MACD: period of slow ma 
input int      Inp_signal_period    = 9;     // MACD: period of averaging of difference 
input int      Inp_MACD_Bar         = 2;     // MACD: bar from which we get the value
input ulong    m_magic=474600515; // magic number
//---
ulong          m_slippage=10;                // slippage
double         m_arr_macd_main[];

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
double         ExtBreakeven=0.0;
double         ExtPriseShift=0.0;

int            handle_iMA;                   // variable for storing the handle of the iMA indicator 
int            handle_iMACD;                 // variable for storing the handle of the iMACD indicator 

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(m_arr_macd_main,11);
   ArrayInitialize(m_arr_macd_main,0.0);
   ArraySetAsSeries(m_arr_macd_main,true);
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(InpManualLot)
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
   ExtBreakeven=InpBreakeven*m_adjusted_point;
   ExtPriseShift=InpPriseShift*m_adjusted_point;
//---
   if(!InpManualLot)
     {
      if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
         return(INIT_FAILED);
      m_money.Percent(Risk);
     }
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),Inp_ma_period,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(m_symbol.Name(),Period(),Inp_fast_ema_period,Inp_slow_ema_period,Inp_signal_period,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
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
   if(!RefreshRates())
     {
      PrevBars=iTime(1);
      return;
     }
//---
   ArrayInitialize(m_arr_macd_main,0.0);
   if(!iMACDGet(MAIN_LINE,Inp_MACD_Bar,11,m_arr_macd_main))
      return;
//--- trailing or breakeven
   int pos_total=Trailing();

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   int end=21;
   if(str1.day_of_week!=5)
      end=23;
   if(str1.hour>=end && InpCloseEndDay)
     {
      //--- pos_total>0 => CloseAllPositions() => retun; pos_total==0 => retun
      if(pos_total>0)
         CloseAllPositions();
      return;
     }
//---
   if(pos_total==0)
     {
      double close_MA_Bar=iClose(Inp_MA_Bar);
      if(close_MA_Bar==0)
         return;
      bool compare=CompareDoubles(m_arr_macd_main[5],0.0,1);
      if(MacdBuy() && EmaBuy(close_MA_Bar))
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
         OpenBuy(sl,tp);
        }
      if(MacdSell() && EmaSell(close_MA_Bar))
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
         OpenSell(sl,tp);
        }
     }
//---
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
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0)
      close=Close[0];
   return(close);
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
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
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
bool iMACDGet(const int buffer,const int start_pos,const int count,double &array[])
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,start_pos,count,array)!=count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
int Trailing()
  {
   int total=0;
/*
   input ushort   InpTakeProfit  = 0;     // Take Profit, if "0" => a breakeven(in pips)
   input ushort   InpTrailingStop= 0;     // Trailing Stop (in pips)
   
   if we use "breakeven" - then we do not use trailing
*/
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               total++;
               if(InpTakeProfit>0 && InpTrailingStop>0) // use trailing
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                     if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Trailing Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }
               else if(InpTakeProfit==0 && InpBreakeven>0) // use breakeven
                 {
                  if(CompareDoubles(m_position.StopLoss(),m_position.PriceOpen(),m_symbol.Digits()))
                     continue;
                  if(m_position.PriceOpen()+ExtBreakeven<m_position.PriceCurrent())
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceOpen()),
                        m_position.TakeProfit()))
                        Print("Breakeven Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
              }
            else
              {
               total++;
               if(InpTakeProfit>0 && InpTrailingStop>0) // use trailing
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                     if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                        (m_position.StopLoss()==0))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }
               else if(InpTakeProfit==0 && InpBreakeven>0) // use breakeven
                 {
                  if(CompareDoubles(m_position.StopLoss(),m_position.PriceOpen(),m_symbol.Digits()))
                     continue;
                  if(m_position.PriceOpen()-ExtBreakeven>m_position.PriceCurrent())
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceOpen()),
                        m_position.TakeProfit()))
                        Print("Breakeven Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
              }
           }
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MacdBuy()
  {
   if(/*(m_arr_macd_main[3]>m_arr_macd_main[4] && 
      m_arr_macd_main[4]>m_arr_macd_main[5] && 
      CompareDoubles(m_arr_macd_main[5],0.0,m_symbol.Digits()) && 
      m_arr_macd_main[5]>m_arr_macd_main[6] && 
      m_arr_macd_main[6]>m_arr_macd_main[7]) || 
      (*/m_arr_macd_main[3]>m_arr_macd_main[4] && 
      m_arr_macd_main[4]>m_arr_macd_main[5] && 
      m_arr_macd_main[5]>=0&&
      m_arr_macd_main[6]<=0&&
      m_arr_macd_main[6]>m_arr_macd_main[7] && 
      m_arr_macd_main[7]>m_arr_macd_main[8])/*)*/
     {
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MacdSell()
  {
   bool _MacdSell=false;
   if(/*(m_arr_macd_main[3]<m_arr_macd_main[4] && 
      m_arr_macd_main[4]<m_arr_macd_main[5] && 
      CompareDoubles(m_arr_macd_main[5],0.0,m_symbol.Digits()) && 
      m_arr_macd_main[5]<m_arr_macd_main[6] && 
      m_arr_macd_main[6]<m_arr_macd_main[7]) || 
      (*/m_arr_macd_main[3]<m_arr_macd_main[4] && 
      m_arr_macd_main[4]<m_arr_macd_main[5] && 
      m_arr_macd_main[5]<=0.0&&
      m_arr_macd_main[6]>=0.0&&
      m_arr_macd_main[6]<m_arr_macd_main[7] && 
      m_arr_macd_main[7]<m_arr_macd_main[8])/*)*/
     {
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EmaBuy(double  &close)
  {

   if(close-iMAGet(Inp_MA_Bar)>ExtPriseShift)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EmaSell(double  &close)
  {
   if(iMAGet(Inp_MA_Bar)-close>ExtPriseShift)
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=0.0;
   if(!InpManualLot)
     {
      check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      //Print("sl=",DoubleToString(sl,m_symbol.Digits()),
      //      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
      //      ", Balance: ",    DoubleToString(m_account.Balance(),2),
      //      ", Equity: ",     DoubleToString(m_account.Equity(),2),
      //      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_long_lot==0.0)
         return;
     }
   else
      check_open_long_lot=InpLots;
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
               //PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            //PrintResult(m_trade,m_symbol);
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
   if(!InpManualLot)
     {
      check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      //Print("sl=",DoubleToString(sl,m_symbol.Digits()),
      //      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
      //      ", Balance: ",    DoubleToString(m_account.Balance(),2),
      //      ", Equity: ",     DoubleToString(m_account.Equity(),2),
      //      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_short_lot==0.0)
         return;
     }
   else
      check_open_short_lot=InpLots;

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
               //PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            //PrintResult(m_trade,m_symbol);
           }
        }
//---
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
