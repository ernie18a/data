//+------------------------------------------------------------------+
//|                           VR---ZVER(barabashkakvn's edition).mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
CMoneyFixedRisk m_money;
//--- input parameters
sinput string  _0_                                 = "Main Settings";   // Main Settings
input double   InpLots                             = 0.1;               // Lots (if <="0.0" -> use "Risk")
input ushort   InpStopLoss                         = 50;                // Stop Loss (use only > 0)(in pips)
input ushort   InpTakeProfit                       = 70;                // Take Profit (use only > 0) (in pips)
input double   Risk                                = 10;                // Risk in percent for a deal 
input bool     InpLock                             = true;              // Lock 
input bool     InpBuildingPosition                 = false;             // Building of a position
input double   InpLotFactorPendingOrders           = 3;                 // Lot factor for pending orders
input ushort   InpBreakeven                        = 20;                // Breakeven (in pips)
sinput string  _1_                                 = "MA fast";         // MA fast
input bool     InpMA_fast                          = true;              // Use MA fast
input int      MA_fast_ma_period                   = 3;                 // MA fast: averaging period 
input int      MA_fast_ma_shift                    = 0;                 // MA fast: horizontal shift 
input ENUM_MA_METHOD MA_fast_ma_method             = MODE_EMA;          // MA fast: smoothing type      
input ENUM_APPLIED_PRICE MA_fast_applied_price     = PRICE_CLOSE;       // MA fast: type of price
sinput string  _2_                                 = "MA slow";         // MA slow
input int      MA_slow_ma_period                   = 5;                 // MA slow: averaging period 
input int      MA_slow_ma_shift                    = 0;                 // MA slow: horizontal shift
input ENUM_MA_METHOD MA_slow_ma_method             = MODE_EMA;          // MA fast: smoothing type 
input ENUM_APPLIED_PRICE MA_slow_applied_price     = PRICE_CLOSE;       // MA fast: type of price
sinput string  _3_                                 = "MA very slow";    // MA very slow        
input int      MA_veryslow_ma_period               = 7;                 // MA very slow: averaging period 
input int      MA_veryslow_ma_shift                = 0;                 // MA very slow: horizontal shift
input ENUM_MA_METHOD MA_veryslow_ma_method         = MODE_EMA;          // MA very slow: smoothing type 
input ENUM_APPLIED_PRICE MA_veryslow_applied_price = PRICE_CLOSE;       // MA very slow: type of price
sinput string  _4_                                 = "Stochastic";      // Stochastic Oscillator   
input bool     InpStochastic                       = true;              // Use Stochastic Oscillator
input int      sto_Kperiod                         = 42;                // Stochastic: K-period (number of bars for calculations) 
input int      sto_Dperiod                         = 5;                 // Stochastic: D-period (period of first smoothing) 
input int      sto_slowing                         = 7;                 // Stochastic: final smoothing 
input int      sto_UPlevel                         = 60;                // Stochastic: UP level 
input int      sto_DOWNlevel                       = 40;                // Stochastic: DOWN level 
sinput string  _5_                                 = "InpRSI";          // Relative Strength Index indicator
input bool     InpRSI                              = true;              // Use RSI       
input int      RSI_ma_period                       = 14;                // RSI: averaging period 
input int      rsi_UPlevel                         = 60;                // RSI: UP level
input int      rsi_DOWNlevel                       = 40;                // RSI: DOWN level
input ulong    m_magic=79990902;                                        // magic number
//---
ulong          m_slippage=30;                                           // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtBreakeven=0.0;

int            handle_iMA_fast;              // variable for storing the handle of the iMA indicator 
int            handle_iMA_slow;              // variable for storing the handle of the iMA indicator 
int            handle_iMA_veryslow;          // variable for storing the handle of the iMA indicator 
int            handle_iStochastic;           // variable for storing the handle of the iStochastic indicator 
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

   ExtStopLoss    = InpStopLoss  * m_adjusted_point;
   ExtTakeProfit  = InpTakeProfit* m_adjusted_point;
   ExtBreakeven   = InpBreakeven * m_adjusted_point;
//---
   if(InpLots<=0.0)
     {
      if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
         return(INIT_FAILED);
      m_money.Percent(Risk);
     }
//--- create handle of the indicator iMA
   handle_iMA_fast=iMA(m_symbol.Name(),Period(),
                       MA_fast_ma_period,MA_fast_ma_shift,MA_fast_ma_method,MA_fast_applied_price);
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
   handle_iMA_slow=iMA(m_symbol.Name(),Period(),
                       MA_slow_ma_period,MA_slow_ma_shift,MA_slow_ma_method,MA_slow_applied_price);
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
//--- create handle of the indicator iMA
   handle_iMA_veryslow=iMA(m_symbol.Name(),Period(),
                           MA_veryslow_ma_period,MA_veryslow_ma_shift,MA_veryslow_ma_method,MA_veryslow_applied_price);
//--- if the handle is not created 
   if(handle_iMA_veryslow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(m_symbol.Name(),Period(),sto_Kperiod,sto_Dperiod,sto_slowing,MODE_SMA,STO_LOWHIGH);
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
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),RSI_ma_period,PRICE_CLOSE);
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
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   int dw=0;
   int up=0;
   double ma_fast_0     = iMAGet(handle_iMA_fast,0);
   double ma_slow_0     = iMAGet(handle_iMA_slow,0);
   double ma_veryslow_0 = iMAGet(handle_iMA_veryslow,0);
   if(ma_fast_0==0.0 || ma_slow_0==0.0 || ma_veryslow_0==0.0)
     {
      PrevBars=iTime(1);
      return;
     }
   double stoh_main_0   = iStochasticGet(MAIN_LINE,0);
   double stoh_signal_0 = iStochasticGet(SIGNAL_LINE,0);
   double rsi_0         = iRSIGet(0);
//--- MA fast
   int ma=0;
   int maup=0;
   int madw=0;
   if(InpMA_fast)
     {
      ma=1;
      if(ma_fast_0>ma_slow_0 && ma_slow_0>ma_veryslow_0)
         maup=1;
      if(ma_veryslow_0>ma_slow_0 && ma_slow_0>ma_fast_0)
         madw=1;
     }
//--- Stochastic
   int stoh=0;
   int stohup=0;
   int stohdw=0;
   if(InpStochastic)
     {
      stoh=1;
      if(stoh_signal_0<stoh_main_0 && sto_DOWNlevel>stoh_main_0)
         stohup=1;
      if(stoh_signal_0>stoh_main_0 && sto_UPlevel<stoh_main_0)
         stohdw=1;
     }
//--- RSI
   int rsi=0;
   int rsiup=0;
   int rsidw=0;
   if(InpRSI)
     {
      rsi=1;
      if(rsi_0<rsi_DOWNlevel)
         rsiup=1;
      if(rsi_0>rsi_UPlevel)
         rsidw=1;
     }
   int UP=rsi+stoh+ma;
   if(UP==maup+stohup+rsiup)
      up=1;
   if(UP==+madw+stohdw+rsidw)
      dw=1;
//--- новые параметры входа
   if(!RefreshRates())
     {
      PrevBars=iTime(1);
      return;
     }
   double sl_buy_one_half  = m_symbol.Ask()-ExtStopLoss/1.5;
   double sl_buy           = m_symbol.Ask()-ExtStopLoss;
   double tp_buy           = m_symbol.Ask()+ExtTakeProfit;

   double sl_sell_one_half = m_symbol.Bid()+ExtStopLoss/1.5;
   double sl_sell          = m_symbol.Bid()+ExtStopLoss;
   double tp_sell          = m_symbol.Bid()-ExtTakeProfit;

   double price_buy_stop   = sl_sell_one_half;
   double price_sell_stop  = sl_buy_one_half;
//--- КОНЕЦ новых параметров входа
   int total_positions=0;
//int total_positions=CalculateAllPositions();
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            total_positions++;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               double pos_price_open= m_position.PriceOpen();
               double pos_stop_loss = m_position.StopLoss();
               double fan           = pos_price_open+ExtBreakeven;
               if(m_symbol.Bid()>=fan)
                  if(pos_stop_loss<pos_price_open)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(pos_price_open),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               double pos_price_open= m_position.PriceOpen();
               double pos_stop_loss = m_position.StopLoss();
               double fan           = pos_price_open-ExtBreakeven;
               if(m_symbol.Ask()<=fan)
                  if(pos_stop_loss>pos_price_open)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(pos_price_open),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }
           }
//---
   if(total_positions==0)
     {
      DeleteAllOrders();
      double lot_buy=0.0;
      double lot_sell=0.0;
      double lot_buy_stop=0.0;
      double lot_sell_stop=0.0;
      if(up==1 || dw==1)
        {
         lot_buy  = CalculateLot(sl_buy_one_half,tp_buy,POSITION_TYPE_BUY);
         lot_sell = CalculateLot(sl_sell_one_half,tp_sell,POSITION_TYPE_SELL);
         if(lot_buy==0.0 || lot_sell==0.0)
            return;
         lot_buy_stop=LotCheck(lot_buy*InpLotFactorPendingOrders);
         lot_sell_stop=LotCheck(lot_sell*InpLotFactorPendingOrders);
         if(lot_buy_stop==0.0 || lot_sell_stop==0.0)
            return;
        }
      if(up==1)
        {
         OpenBuy(sl_buy_one_half,tp_buy,lot_buy);
         if(InpLock)
            m_trade.SellStop(lot_sell_stop,price_sell_stop,m_symbol.Name(),0.0,sl_buy);
         if(InpBuildingPosition)
            m_trade.BuyStop(lot_buy,price_buy_stop,m_symbol.Name(),0.0,tp_buy);
        }
      else if(dw==1)
        {
         OpenSell(sl_sell_one_half,tp_sell,lot_sell);
         if(InpBuildingPosition)
            m_trade.SellStop(lot_sell_stop,price_sell_stop,m_symbol.Name(),0.0,tp_sell);
         if(InpLock)
            m_trade.BuyStop(lot_buy_stop,price_buy_stop,m_symbol.Name(),0.0,sl_sell);
        }
     }
//---
   return;
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
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Calculate lot                                                    |
//+------------------------------------------------------------------+
double CalculateLot(double sl,double tp,ENUM_POSITION_TYPE pos_type)
  {
   if(InpLots>0.0)
      return(InpLots);
   double lot=0.0;
   if(pos_type==POSITION_TYPE_BUY)
     {
      sl=m_symbol.NormalizePrice(sl);
      tp=m_symbol.NormalizePrice(tp);

      double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_long_lot==0.0)
         return(0.0);
      lot=check_open_long_lot;
     }
   else if(pos_type==POSITION_TYPE_SELL)
     {
      sl=m_symbol.NormalizePrice(sl);
      tp=m_symbol.NormalizePrice(tp);

      double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_short_lot==0.0)
         return(0.0);
      lot=check_open_short_lot;
     }
//---
   return(lot);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,double lot)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,NULL,m_symbol.Ask(),sl,tp))
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
void OpenSell(double sl,double tp,double lot)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,NULL,m_symbol.Bid(),sl,tp))
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
//| Delete  AllOrders                                                |
//+------------------------------------------------------------------+
void DeleteAllOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
