//+------------------------------------------------------------------+
//|                                OzFx(barabashkakvn's edition).mq5 |
//|                                                     FORTRADER.RU |
//|                                          http://www.FORTRADER.RU |
//+------------------------------------------------------------------+
#property copyright "FORTRADER.RU"
#property link      "http://www.FORTRADER.RU"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double            InpLots           = 0.1;         // Lots
input ushort            InpStopLoss       = 100;         // Stop Loss (in pips)
input ushort            InpTakeProfit     = 50;          // Take Profit (in pips)
input ushort            InpTrailingStop   = 50;          // Trailing Stop (in pips)
input ushort            InpTrailingStep   = 5;           // Trailing Step (in pips)
sinput string           InpStochastic     = "Stochastic";// Stochastic
input int               Kperiod           = 5;           // the K period (the number of bars for calculation) 
input int               Dperiod           = 3;           // the D period (the period of primary smoothing) 
input int               slowing           = 3;           // period of final smoothing       
input ENUM_MA_METHOD    ma_method         = MODE_SMA;    // type of smoothing    
input ENUM_STO_PRICE    price_field       = STO_LOWHIGH; // method of calculation of the Stochastic 
input double            InpStochasticLevel= 50;          // Stochastic level
ulong          m_magic=73263330;             // magic number
ulong          m_slippage=30;                // slippage
//---
bool modok=false;
//---
double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
int            handle_iAC;                   // variable for storing the handle of the iAC indicator 
int            handle_iStochastic;           // variable for storing the handle of the iStochastic indicator 
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

   ExtStopLoss    = InpStopLoss     * m_adjusted_point;
   ExtTakeProfit  = InpTakeProfit   * m_adjusted_point;
   ExtTrailingStop= InpTrailingStop * m_adjusted_point;
   ExtTrailingStep= InpTrailingStep * m_adjusted_point;
//--- create handle of the indicator iAC
   handle_iAC=iAC(m_symbol.Name(),Period());
//--- if the handle is not created 
   if(handle_iAC==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAC indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(m_symbol.Name(),Period(),Kperiod,Dperiod,slowing,ma_method,price_field);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
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

   int count_buys=0,count_sells=0;
   CalculatePositions(count_buys,count_sells);
//---
   double AC_1=iACGet(1);
   double ACPrev_2=iACGet(2);
//+------------------------------------------------------------------+
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
   double Stoh_main_1=iStochasticGet(MAIN_LINE,1);

   if(Stoh_main_1>InpStochasticLevel && AC_1>ACPrev_2 && AC_1>0 && ACPrev_2<0 && count_buys==0)
     {
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=0,tp=0;
      OpenBuy(sl,tp);
      for(int i=1;i<5;i++)
        {
         if(ExtStopLoss>0.0)
            sl=m_symbol.Ask()-ExtStopLoss;
         if(ExtTakeProfit>0.0)
            tp=m_symbol.Ask()+ExtTakeProfit*i;
         OpenBuy(sl,tp);
        }
     }

   if(Stoh_main_1<InpStochasticLevel && AC_1<ACPrev_2 && AC_1<0 && ACPrev_2>0 && count_sells==0)
     {
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      double sl=0,tp=0;
      OpenSell(sl,tp);
      for(int i=1;i<5;i++)
        {
         if(ExtStopLoss>0.0)
            sl=m_symbol.Bid()+ExtStopLoss;
         if(ExtTakeProfit>0.0)
            tp=m_symbol.Bid()-ExtTakeProfit*i;
         OpenSell(sl,tp);
        }
     }
//---
   if(ExtTrailingStop==0)
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY && modok)
                 {
                  if(Stoh_main_1<50 && AC_1<ACPrev_2 && AC_1<0 && ACPrev_2>0)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                  if(m_position.StopLoss()==0.0)
                     if(m_position.PriceCurrent()>m_position.PriceOpen())
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }

                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL && modok)
                 {
                  if(Stoh_main_1>50 && AC_1>ACPrev_2 && AC_1>0 && ACPrev_2<0)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                  if(m_position.StopLoss()==0.0)
                     if(m_position.PriceCurrent()<m_position.PriceOpen())
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }
              }
//---
   if(ExtTrailingStop>0.0)
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(Stoh_main_1<50 && AC_1<ACPrev_2 && AC_1<0 && ACPrev_2>0)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                     if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        continue;
                       }
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(Stoh_main_1>50 && AC_1>ACPrev_2 && AC_1>0 && ACPrev_2<0)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                     if(m_position.StopLoss()>m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep) || m_position.StopLoss()==0.0)
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
              }
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
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iAC                                |
//+------------------------------------------------------------------+
double iACGet(const int index)
  {
   double AC_1[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iACBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iAC,0,index,1,AC_1)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAC indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(AC_1[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int buffer,const int index)
  {
   double Stochastic[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic,buffer,index,1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[0]);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);
   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,NULL,m_symbol.Ask(),sl,tp))
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

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);
   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,NULL,m_symbol.Bid(),sl,tp))
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
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_entry        =0;
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      long     deal_reason       =-1;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason=HistoryDealGetInteger(trans.deal,DEAL_REASON);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_reason==DEAL_REASON_SL)
               modok=false;
            else if(deal_reason==DEAL_REASON_TP)
               modok=true;
           }
     }
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==PERIOD_CURRENT)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
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
