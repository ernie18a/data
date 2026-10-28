//+------------------------------------------------------------------+
//|                            RabbitM2(barabashkakvn's edition).mq5 |
//|                                                     Peter  Byrom |
//|                                                  pete@byroms.net |
//+------------------------------------------------------------------+
#property copyright "Peter  Byrom"
#property link      "pete@byroms.net"
#property version   "1.007"
//---
#define MODE_LOW 1
#define MODE_HIGH 2
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input int      Inp_CCI_sell_level      = 101;      // CCI sell level
input int      Inp_CCI_buy_level       = 99;       // CCI buy level
input int      Inp_CCI_ma_period       = 14;       // CCI averaging period
input int      Inp_count_bars          = 100;      // Count bars (for iHighest and iLowest)
input int      Inp_max_open_positions  = 1;        // Maximum number of open positions
input double   InpBigWin               = 1.50;     // Positive profit in the deposit currency
input double   InpVolumeStep           = 0.01;     // Volume step
input int      Inp_WPR_calc_period     = 50.0;     // WPR averaging period 
input int      Inp_MA_fast_ma_period   = 40;       // MA Fast ma_period
input int      Inp_MA_slow_ma_period   = 80;       // MA Slow ma_period
input ushort   InpTakeProfit           = 50;       // Take Profit (in pips)
input ushort   InpStopLoss             = 50;       // Stop Loss (in pips)
input double   InpVolume               = 0.01;     // Volume 
input ulong    m_magic                 = 444544;
input ulong    m_slippage              = 30;
bool sell;
bool buy;
//---
double         m_tradesize=0.0;
double         m_big_win=0.0;
double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
int            handle_iCCI;                        // variable for storing the handle of the iCCI indicator 
int            handle_iMA_fast;                    // variable for storing the handle of the iMA indicator 
int            handle_iMA_slow;                    // variable for storing the handle of the iMA indicator 
int            handle_iWPR;                        // variable for storing the handle of the iWPR indicator 
double         m_adjusted_point;                   // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   sell=false;
   buy=false;
   m_tradesize=InpVolume;
   m_big_win=InpBigWin;
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

   string err_text="";
   if(!CheckVolumeValue(InpVolumeStep,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   err_text="";
   if(!CheckVolumeValue(InpVolume,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(m_symbol.Name(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(m_symbol.Name(),SYMBOL_FILLING_IOC))
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
//--- create handle of the indicator iCCI
   handle_iCCI=iCCI(m_symbol.Name(),Period(),Inp_CCI_ma_period,PRICE_CLOSE);
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
//--- create handle of the indicator iMA
   handle_iMA_fast=iMA(m_symbol.Name(),PERIOD_H1,Inp_MA_fast_ma_period,0,MODE_EMA,PRICE_CLOSE);
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
   handle_iMA_slow=iMA(m_symbol.Name(),PERIOD_H1,Inp_MA_slow_ma_period,0,MODE_EMA,PRICE_CLOSE);
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
//--- create handle of the indicator iWPR
   handle_iWPR=iWPR(m_symbol.Name(),PERIOD_M1,Inp_WPR_calc_period);
//--- if the handle is not created 
   if(handle_iWPR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iWPR indicator for the symbol %s/%s, error code %d",
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
   double CCI=iCCIGet(0);
   double ema_fast=iMAGet(handle_iMA_fast,0);
   double ema_slow=iMAGet(handle_iMA_slow,0);
   double will=iWPRGet(0);
   double will_lag=iWPRGet(1);

   if(will==0)
      will=0-1;

   if(will_lag==0)
      will_lag=0-1;

//--- Buying AND Selling 
   if(ema_fast<ema_slow)
     {
      //--- Stop Buying and start Selling
      //--- Step 1: close all buy positios  
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_position.Profit()>m_big_win)
                    {
                     m_tradesize=m_tradesize+InpVolumeStep;
                     m_big_win=m_big_win*2.0;
                    }
                  m_trade.PositionClose(m_position.Ticket());
                 }
              }
      //--- Step 2: set booleans buy = false sell = true
      sell=true;
      buy=false;
     }
   if(ema_fast>ema_slow)
     {
      //--- Stop selling and start buying 
      //--- Step 1: close all sell positios  
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(m_position.Profit()>m_big_win)
                    {
                     m_tradesize=m_tradesize+InpVolumeStep;
                     m_big_win=m_big_win*2.0;
                    }
                  m_trade.PositionClose(m_position.Ticket());
                 }
              }
      //--- Step 2 set booleans buy = false sell = true
      sell=false;
      buy=true;
     }
//---
   int total_positions=CalculateAllPositions();
//-- SELL 
   if(will<-20 && will_lag>-20 && will_lag<0 && 
      Inp_max_open_positions>total_positions && sell && CCI>Inp_CCI_sell_level)
     {
      double volume=LotCheck(m_tradesize);
      if(volume!=0.0)
         if(RefreshRates())
           {
            OpenSell(m_symbol.Bid()+ExtStopLoss,
                     m_symbol.Bid()-ExtTakeProfit,
                     m_tradesize);
           }
     }
//-- BUY     
   if(will>-80 && will_lag<-80 && will_lag<0 && 
      Inp_max_open_positions>total_positions && buy && CCI<Inp_CCI_buy_level)
     {
      double volume=LotCheck(m_tradesize);
      if(volume!=0.0)
         if(RefreshRates())
           {
            OpenBuy(m_symbol.Ask()-ExtStopLoss,
                    m_symbol.Ask()+ExtTakeProfit,
                    m_tradesize);
           }
     }
//--- CLOSE    
//--- Close sells when dochian is high and close buys when donchian is low
//--- CLOSE ALL SELLS   
   double escape=iHighest(m_symbol.Name(),Period(),MODE_HIGH,Inp_count_bars,1);
   if(!RefreshRates())
      return;
   if(m_symbol.Ask()>escape)
     {
      //-- find the sells
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(m_position.Profit()>m_big_win)
                    {
                     m_tradesize=m_tradesize+InpVolumeStep;
                     m_big_win=m_big_win*2.0;
                    }
                  m_trade.PositionClose(m_position.Ticket());
                 }
              }
     }
//--- CLOSE ALL BUYS    
   double oucha=iLowest(m_symbol.Name(),Period(),MODE_LOW,Inp_count_bars,1);
   if(m_symbol.Bid()<oucha)
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_position.Profit()>m_big_win)
                    {
                     m_tradesize=m_tradesize+InpVolumeStep;
                     m_big_win=m_big_win*2.0;
                    }
                  m_trade.PositionClose(m_position.Ticket());
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
//| Get value of buffers for the iWPR                                |
//+------------------------------------------------------------------+
double iWPRGet(const int index)
  {
   double WPR[];
   ArraySetAsSeries(WPR,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iWPRBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iWPR,0,0,index+1,WPR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iWPR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(WPR[index]);
  }
//+------------------------------------------------------------------+
//| Calculate positions                                              |
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,double lot,string comment=NULL)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,NULL,m_symbol.Ask(),sl,tp,comment))
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
void OpenSell(double sl,double tp,double lot,string comment=NULL)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,NULL,m_symbol.Bid(),sl,tp,comment))
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
//|                                                                  |
//+------------------------------------------------------------------+
double iLowest(string symbol,
               ENUM_TIMEFRAMES timeframe,
               int type,
               int count=WHOLE_ARRAY,
               int start=0)
  {
   if(start<0)
      return(0.0);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_LOW)
     {
      double Low[];
      if(CopyLow(symbol,timeframe,start,count,Low)==-1)
         return(0.0);
      int index_min=ArrayMinimum(Low,0,WHOLE_ARRAY);
      return(Low[index_min]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHighest(string symbol,
                ENUM_TIMEFRAMES timeframe,
                int type,
                int count=WHOLE_ARRAY,
                int start=0)
  {
   if(start<0)
      return(0.0);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_HIGH)
     {
      double High[];
      if(CopyHigh(symbol,timeframe,start,count,High)==-1)
         return(0.0);
      int index_max=ArrayMaximum(High,0,WHOLE_ARRAY);
      return(High[index_max]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
