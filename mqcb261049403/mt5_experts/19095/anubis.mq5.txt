//+------------------------------------------------------------------+
//|                              Anubis(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright c 2006, Andrew Tikhonov"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedRisk m_money;
//---
#define          UNDEF   0
#define          BUY    1
#define          SELL  -1
//--- input parameters 
input double   InpLots        = 1;           // volume transaction
input double   CCIthres       = 80;          // CCI thres
input int      CCIPeriod      = 11;          // CCI Period 
input ushort   InpStopLoss    = 100;         // Stop Loss (in pips)
input ushort   InpBreakeven   = 65;
input int      M_FastEMA      = 20;          // MACD Fast EMA
input int      M_SlowEMA      = 50;          // MACD Slow EMA
input int      M_Signal       = 2;           // MACD Signal
input double   LossFactor     = 0.6;         // Coefficient on the volume transaction, if there was a loss
input double   Risk           = 5;           // Risk in percent for a deal from a free margin
//----
int       MaxSellPositions=2;
int       MaxBuyPositions=2;
//----
input double    closeK=2; // 4.5 // 3.5
input ushort    Thres=28; // 25
input double    stdK=2.9; // 3 // 6.2
//----
datetime OpenBarBuy=0;
datetime OpenBarSell=0;
//----
double lastLongPrice=0.0;
double lastShortPrice=0.0;
//----
datetime expTime=0;
//---
double         m_last_profit=0.0;            // profit at last trade
ulong          m_magic=15489;                // magic number
ulong          m_slippage=30;                // slippage
double         ExtStopLoss=0;
double         ExtBreakeven=0;
double         ExtThres=0.0;
int            handle_iStdDev_20;            // variable for storing the handle of the iStdDev indicator
int            handle_iStdDev_30;            // variable for storing the handle of the iStdDev indicator
int            handle_iMACD;                 // variable for storing the handle of the iMACD indicator 
int            handle_iCCI;                  // variable for storing the handle of the iCCI indicator 
int            handle_iATR;                  // variable for storing the handle of the iATR indicator 
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(InpLots<=0.0)
     {
      Print("The \"volume transaction\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
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

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtBreakeven=InpBreakeven*m_adjusted_point;
   ExtThres=Thres*m_adjusted_point;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(Risk);
//--- create handle of the indicator iStdDev   
   handle_iStdDev_20=iStdDev(m_symbol.Name(),PERIOD_H4,20,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iStdDev_20==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStdDev indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iStdDev   
   handle_iStdDev_30=iStdDev(m_symbol.Name(),PERIOD_H4,30,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iStdDev_30==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStdDev indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(m_symbol.Name(),PERIOD_H4,CCIPeriod,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iCCI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(m_symbol.Name(),PERIOD_M15,M_FastEMA,M_SlowEMA,M_Signal,PRICE_CLOSE);
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
//--- create handle of the indicator iATR
   handle_iATR=iATR(m_symbol.Name(),PERIOD_M15,12);
//--- if the handle is not created 
   if(handle_iATR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
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
   start_flatSystem();
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
//|                                                                  |
//+------------------------------------------------------------------+
void setFlatBreakeven()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-ExtBreakeven>m_position.PriceOpen() && m_position.PriceOpen()>m_position.StopLoss())
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
              }
            else
              {
               if(m_position.PriceCurrent()+ExtBreakeven<m_position.PriceOpen() && m_position.PriceOpen()<m_position.StopLoss())
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),m_position.TakeProfit()))
                     Print("Modify ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
              }

           }
  }
//+------------------------------------------------------------------+
//| Calculate loss                                                   |
//+------------------------------------------------------------------+
double CalculateLoss()
  {
   if(m_last_profit<0.0)
      return(LossFactor);
   else
      return(1.0);
  }
//+------------------------------------------------------------------+
//| Check trade volume                                               |
//+------------------------------------------------------------------+
bool CheckTradeVolume()
  {
   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),0.0);
   if(check_open_long_lot==0.0)
      return(false);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);
   if(check_volume_lot==0.0 || check_volume_lot<check_open_long_lot)
      return(false);

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),0.0);
   if(check_open_short_lot==0.0)
      return(false);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);
   if(check_volume_lot==0.0 || check_volume_lot<check_open_short_lot)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start_flatSystem()
  {
   if(expTime!=iTime(0))
      expTime=iTime(0);
   else
      return;
   if(!RefreshRates())
     {
      expTime=iTime(1);
      return;
     }
   if(!CheckTradeVolume())
      return;
//---
   int openCmd=UNDEF;
   int numBuys=0;
   int numSells=0;
   CalculatePositions(numBuys,numSells);

   double stDev   =iStdDevGet(handle_iStdDev_20,1);
   double iCCI0   =iCCIGet(0);
   double iMACD1  =iMACDGet(MAIN_LINE,1);
   double iMACD2  =iMACDGet(MAIN_LINE,2);
   double iMACDs1 =iMACDGet(SIGNAL_LINE,1);
   double iMACDs2 =iMACDGet(SIGNAL_LINE,2);
   double take=stdK*iStdDevGet(handle_iStdDev_30,1);
//---
   if(iCCI0>CCIthres && iMACD2>=iMACDs2 && iMACD1<iMACDs1 && iMACD1>0)
      openCmd=SELL;
   if(iCCI0<(-1)*CCIthres && iMACD2<=iMACDs2 && iMACD1>iMACDs1 && iMACD1<0)
      openCmd=BUY;
   if(numSells==0)
      lastShortPrice=0;
   if(numBuys==0)
      lastLongPrice=0;

   if(openCmd==BUY && OpenBarBuy!=iTime(0) && numBuys<MaxBuyPositions)
     {
      if(MathAbs(m_symbol.Ask()-lastLongPrice)>20*m_adjusted_point)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
         OpenBuy(sl,m_symbol.Ask()+take);
         OpenBarBuy=iTime(0);
         lastLongPrice=m_symbol.Ask();
        }
     }
   if(openCmd==SELL && OpenBarSell!=iTime(0) && numSells<MaxSellPositions)
     {
      if(MathAbs(m_symbol.Ask()-lastShortPrice)>20*m_adjusted_point)
        {
         double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
         OpenSell(sl,m_symbol.Bid()-take);
         OpenBarSell=iTime(0);
         lastLongPrice=m_symbol.Ask();
        }
     }

   setFlatBreakeven();

   double iATR1=iATRGet(1);
   double iClose1=iClose(1,m_symbol.Name(),PERIOD_M15);
   double iOpen1=iOpen(1,m_symbol.Name(),PERIOD_M15);
   if(iATR1==0.0 || iClose1==0.0 || iOpen1==0.0)
     {
      expTime=iTime(1);
      return;
     }

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if((iClose1-iOpen1>closeK*iATR1) || 
                  (iMACD1<iMACD2 && m_position.PriceCurrent()-m_position.PriceOpen()>ExtThres))
                  m_trade.PositionClose(m_position.Ticket());
               continue;
              }
            else
              {
               if(m_position.PriceCurrent()+ExtBreakeven<m_position.PriceOpen() && m_position.PriceOpen()<m_position.StopLoss())
                 {
                  if((iOpen1-iClose1>closeK*iATR1) || 
                     (iMACD1>iMACD2 && m_position.PriceOpen()-m_position.PriceCurrent()>ExtThres))
                     m_trade.PositionClose(m_position.Ticket());
                  continue;
                 }
              }

           }
//---
   return;
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
//| Get Open for specified bar index                                 | 
//+------------------------------------------------------------------+ 
double iOpen(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Open[1];
   double open=0;
   int copied=CopyOpen(symbol,timeframe,index,1,Open);
   if(copied>0) open=Open[0];
   return(open);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
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
//| Get value of buffers for the iStdDev                             |
//+------------------------------------------------------------------+
double iStdDevGet(int handle_iStdDev,const int index)
  {
   double StdDev[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStdDev array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(
      handle_iStdDev,// indicator handle 
      0,             // indicator buffer number 
      index,         // start position 
      1,             // amount to copy 
      StdDev         // target array to copy 
      )<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStdDev indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(StdDev[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(const int index)
  {
   double CCI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCCI,0,index,1,CCI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(CCI[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,index,1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iATR                                |
//+------------------------------------------------------------------+
double iATRGet(const int index)
  {
   double ATR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATR array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iATR,0,index,1,ATR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ATR[0]);
  }
//+------------------------------------------------------------------+
