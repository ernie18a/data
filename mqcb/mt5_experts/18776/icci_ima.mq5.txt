//+------------------------------------------------------------------+
//|                            iCCI iMA(barabashkakvn's edition).mq5 |
//|                   Copyright © 2008,  AEliseev k800elik@gmail.com |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008,  Andrey E. k800elik@gmail.com"
#property link      "https://www.metaquotes.net"
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
input int      Inp_CCI_ma_period       = 14;       // period of moving average CCI
input int      Inp_CCI_close_ma_period = 14;       // period of moving average CCI_close
input int      Inp_MA_ma_period        = 9;        // averaging period MA
input double   InpLots                 = 0.1;      // Lots (only if "Money Management"==false)
input ushort   InpStopLoss             = 50;       // Stop Loss (in pips)
input ushort   InpTakeProfit           = 40;       // Take Profit (in pips)
input bool     InpMM                   = false;    // Money Management
input double   InpDeposit              = 1000.0;   // Deposit (only if "Money Management"==true)
input ulong    m_magic                 = 292269984;// Magic 
//---
ulong          m_slippage=30;                      // slippage
double         ExtStopLoss=0;
double         ExtTakeProfit=0;
long           m_coeff_lot=1;
datetime       PrevBars=0;
//---
int    handle_iCCI;                          // variable for storing the handle of the iCCI indicator 
int    handle_iCCI_close;                    // variable for storing the handle of the iCCI indicator 
int    handle_iMA;                           // variable for storing the handle of the iMA indicator 
double m_adjusted_point;                     // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Comment("CCI_MA v1.5 © 2008,  Andrey E. k800elik@gmail.com");
   PrevBars=0;
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   if(!InpMM)
     {
      string err_text="";
      if(!CheckVolumeValue(InpLots,err_text))
        {
         Print(err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
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
   handle_iCCI=iCCI(m_symbol.Name(),Period(),Inp_CCI_ma_period,PRICE_TYPICAL);
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
//--- create handle of the indicator iCCI
   handle_iCCI_close=iCCI(m_symbol.Name(),Period(),Inp_CCI_close_ma_period,PRICE_TYPICAL);
//--- if the handle is not created 
   if(handle_iCCI_close==INVALID_HANDLE)
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
   handle_iMA=iMA(m_symbol.Name(),Period(),15,0,MODE_EMA,handle_iCCI);
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
   if(isNewBar())
      EveryBar();
   EveryTick();
  }
//+------------------------------------------------------------------+
//| Check for the appearance of a new bar                            |
//+------------------------------------------------------------------+
bool isNewBar()
  {
//--- we work only at the time of the birth of new bar
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return(false);
   PrevBars=time_0;
//---
   return (true);
  }
//+------------------------------------------------------------------+
//| Trading                                                          |
//+------------------------------------------------------------------+
void EveryBar()
  {
   double cci_0=iCCIGet(handle_iCCI,0);
   double cci_2=iCCIGet(handle_iCCI,2);
   double cci_close_0=iCCIGet(handle_iCCI_close,0);
   double cci_close_2=iCCIGet(handle_iCCI_close,2);
   double ma_0=iMAGet(0);
   double ma_2=iMAGet(2);

//--- the CCI crosses MA from the bottom up
   bool signal_close_buy=(
                          (cci_close_2>100 && cci_close_0<=100) || (cci_0<ma_0 &&
                          cci_2>=ma_2)
                          );
//--- the CCI crosses MA from top to bottom
   bool signal_close_sell=(
                           (cci_close_2<-100 && cci_close_0>=-100) || (cci_0>ma_0 &&
                           cci_2<=ma_2)
                           );

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               if(signal_close_buy)
                  m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               if(signal_close_sell)
                  m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
           }

//--- check whether it is possible to open a position
   if((cci_0>ma_0) && (cci_2<ma_2))
     {
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      //--- open Buy position
      double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      double lot=LotCheck(m_coeff_lot*InpLots);
      if(lot>0.0)
         if(!OpenBuy(lot,sl,tp))
            PrevBars=iTime(1);
     }
//--- 
   if((cci_0<ma_0) && (cci_2>ma_2))
     {
      if(!RefreshRates())
        {
         PrevBars=iTime(1);
         return;
        }
      //--- open Sell position
      double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      double lot=LotCheck(m_coeff_lot*InpLots);
      if(lot>0.0)
         if(!OpenSell(lot,sl,tp))
            PrevBars=iTime(1);
     }
  }
//+------------------------------------------------------------------+
//| We perform calculations for each price change                    |
//+------------------------------------------------------------------+   
void EveryTick()
  {
   if(InpMM)
     {
      long result=(long)(m_account.Balance()/InpDeposit);
      if(result<2)
         return;
      else if(result>20)
        {
         m_coeff_lot=20;
         return;
        }
      else
         m_coeff_lot=result;
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
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(int handle,const int index)
  {
   double CCI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,index,1,CCI)<0)
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double lot,double sl,double tp)
  {
   bool result=false;
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,m_symbol.Name(),m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double lot,double sl,double tp)
  {
   bool result=false;
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,m_symbol.Name(),m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(result);
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
