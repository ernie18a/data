//+------------------------------------------------------------------+
//|                    Multi Stochastic(barabashkakvn's edition).mq5 |
//|                                   Copyright © 2009, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol1;                    // symbol info object
CSymbolInfo    m_symbol2;                    // symbol info object
CSymbolInfo    m_symbol3;                    // symbol info object
CSymbolInfo    m_symbol4;                    // symbol info object
//--- input parameters
input bool     Use_Symbol1       = true;     // Use symbol #1
input string   Symbol1           = "EURUSD"; // The symbol name #1
input bool     Use_Symbol2       = true;     // Use symbol #2
input string   Symbol2           = "USDCHF"; // The symbol name #2
input bool     Use_Symbol3       = true;     // Use symbol #3
input string   Symbol3           = "GBPUSD"; // The symbol name #3
input bool     Use_Symbol4       = true;     // Use symbol #4
input string   Symbol4           = "USDJPY"; // The symbol name #4
input ushort   InpStopLoss       = 50;       // Stop Loss (in pips)
input ushort   InpTakeProfit     = 10;       // Take Profit (in pips)
input ulong    m_magic           = 15489;    // magic number
//---
ulong          m_slippage=30;                // slippage
double         ExtStopLoss1=0;
double         ExtStopLoss2=0;
double         ExtStopLoss3=0;
double         ExtStopLoss4=0;
double         ExtTakeProfit1=0;
double         ExtTakeProfit2=0;
double         ExtTakeProfit3=0;
double         ExtTakeProfit4=0;
int            handle_iStochastic1;          // variable for storing the handle of the iStochastic indicator 
int            handle_iStochastic2;          // variable for storing the handle of the iStochastic indicator 
int            handle_iStochastic3;          // variable for storing the handle of the iStochastic indicator 
int            handle_iStochastic4;          // variable for storing the handle of the iStochastic indicator 
double         m_adjusted_point1;            // point value adjusted for 3 or 5 points
double         m_adjusted_point2;            // point value adjusted for 3 or 5 points
double         m_adjusted_point3;            // point value adjusted for 3 or 5 points
double         m_adjusted_point4;            // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(Use_Symbol1)
     {
      if(!m_symbol1.Name(Symbol1)) // sets symbol name
         return(INIT_FAILED);
      RefreshRates(m_symbol1);
     }
   if(Use_Symbol2)
     {
      if(!m_symbol2.Name(Symbol2)) // sets symbol name
         return(INIT_FAILED);
      RefreshRates(m_symbol2);
     }
   if(Use_Symbol3)
     {
      if(!m_symbol3.Name(Symbol3)) // sets symbol name
         return(INIT_FAILED);
      RefreshRates(m_symbol3);
     }
   if(Use_Symbol4)
     {
      if(!m_symbol4.Name(Symbol4)) // sets symbol name
         return(INIT_FAILED);
      RefreshRates(m_symbol4);
     }
   if(!Use_Symbol1 && !Use_Symbol2 && !Use_Symbol3 && !Use_Symbol4)
     {
      Print("You must select at least one symbol!");
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
   if(Use_Symbol1)
     {
      if(m_symbol1.Digits()==3 || m_symbol1.Digits()==5)
         digits_adjust=10;
      m_adjusted_point1=m_symbol1.Point()*digits_adjust;
     }

   digits_adjust=1;
   if(Use_Symbol2)
     {
      if(m_symbol2.Digits()==3 || m_symbol2.Digits()==5)
         digits_adjust=10;
      m_adjusted_point2=m_symbol2.Point()*digits_adjust;
     }

   digits_adjust=1;
   if(Use_Symbol3)
     {
      if(m_symbol3.Digits()==3 || m_symbol3.Digits()==5)
         digits_adjust=10;
      m_adjusted_point3=m_symbol3.Point()*digits_adjust;
     }

   digits_adjust=1;
   if(Use_Symbol4)
     {
      if(m_symbol4.Digits()==3 || m_symbol4.Digits()==5)
         digits_adjust=10;
      m_adjusted_point4=m_symbol4.Point()*digits_adjust;
     }

   if(Use_Symbol1)
     {
      ExtStopLoss1=InpStopLoss*m_adjusted_point1;
      ExtTakeProfit1=InpTakeProfit*m_adjusted_point1;
     }
   if(Use_Symbol2)
     {
      ExtStopLoss2=InpStopLoss*m_adjusted_point2;
      ExtTakeProfit2=InpTakeProfit*m_adjusted_point2;
     }
   if(Use_Symbol3)
     {
      ExtStopLoss3=InpStopLoss*m_adjusted_point3;
      ExtTakeProfit3=InpTakeProfit*m_adjusted_point3;
     }
   if(Use_Symbol4)
     {
      ExtStopLoss4=InpStopLoss*m_adjusted_point4;
      ExtTakeProfit4=InpTakeProfit*m_adjusted_point4;
     }
//---
   if(Use_Symbol1)
     {
      //--- create handle of the indicator iStochastic
      handle_iStochastic1=iStochastic(m_symbol1.Name(),Period(),5,3,3,MODE_SMA,STO_LOWHIGH);
      //--- if the handle is not created 
      if(handle_iStochastic1==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                     m_symbol1.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
   if(Use_Symbol2)
     {
      //--- create handle of the indicator iStochastic
      handle_iStochastic2=iStochastic(m_symbol2.Name(),Period(),5,3,3,MODE_SMA,STO_LOWHIGH);
      //--- if the handle is not created 
      if(handle_iStochastic2==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                     m_symbol2.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
   if(Use_Symbol3)
     {
      //--- create handle of the indicator iStochastic
      handle_iStochastic3=iStochastic(m_symbol3.Name(),Period(),5,3,3,MODE_SMA,STO_LOWHIGH);
      //--- if the handle is not created 
      if(handle_iStochastic3==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                     m_symbol3.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
     }
   if(Use_Symbol4)
     {
      //--- create handle of the indicator iStochastic
      handle_iStochastic4=iStochastic(m_symbol4.Name(),Period(),5,3,3,MODE_SMA,STO_LOWHIGH);
      //--- if the handle is not created 
      if(handle_iStochastic4==INVALID_HANDLE)
        {
         //--- tell about the failure and output the error code 
         PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                     m_symbol4.Name(),
                     EnumToString(Period()),
                     GetLastError());
         //--- the indicator is stopped early 
         return(INIT_FAILED);
        }
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
   bool is_positions1=false;
   bool is_positions2=false;
   bool is_positions3=false;
   bool is_positions4=false;
   ExistPositions(is_positions1,is_positions2,is_positions3,is_positions4);
//---
   if(Use_Symbol1)
      if(!is_positions1)
        {
         int signal=GetSignal(handle_iStochastic1);
         if(signal!=0)
            if(RefreshRates(m_symbol1))
              {
               if(signal==1)
                 {
                  double sl=(InpStopLoss==0)?0.0:m_symbol1.Ask()-ExtStopLoss1;
                  double tp=(InpTakeProfit==0)?0.0:m_symbol1.Ask()+ExtTakeProfit1;
                  OpenBuy(m_symbol1,sl,tp);
                 }
               if(signal==-1)
                 {
                  double sl=(InpStopLoss==0)?0.0:m_symbol1.Bid()+ExtStopLoss1;
                  double tp=(InpTakeProfit==0)?0.0:m_symbol1.Bid()-ExtTakeProfit1;
                  OpenSell(m_symbol1,sl,tp);
                 }
              }
        }
   if(Use_Symbol2)
      if(!is_positions2)
        {
         int signal=GetSignal(handle_iStochastic2);
         if(signal!=0)
            if(RefreshRates(m_symbol2))
              {
               if(signal==1)
                 {
                  double sl=(InpStopLoss==0)?0.0:m_symbol2.Ask()-ExtStopLoss1;
                  double tp=(InpTakeProfit==0)?0.0:m_symbol2.Ask()+ExtTakeProfit1;
                  OpenBuy(m_symbol2,sl,tp);
                 }
               if(signal==-1)
                 {
                  double sl=(InpStopLoss==0)?0.0:m_symbol2.Bid()+ExtStopLoss1;
                  double tp=(InpTakeProfit==0)?0.0:m_symbol2.Bid()-ExtTakeProfit1;
                  OpenSell(m_symbol2,sl,tp);
                 }
              }
        }
   if(Use_Symbol3)
      if(!is_positions3)
        {
         int signal=GetSignal(handle_iStochastic3);
         if(signal!=0)
            if(RefreshRates(m_symbol3))
              {
               if(signal==1)
                 {
                  double sl=(InpStopLoss==0)?0.0:m_symbol3.Ask()-ExtStopLoss1;
                  double tp=(InpTakeProfit==0)?0.0:m_symbol3.Ask()+ExtTakeProfit1;
                  OpenBuy(m_symbol3,sl,tp);
                 }
               if(signal==-1)
                 {
                  double sl=(InpStopLoss==0)?0.0:m_symbol3.Bid()+ExtStopLoss1;
                  double tp=(InpTakeProfit==0)?0.0:m_symbol3.Bid()-ExtTakeProfit1;
                  OpenSell(m_symbol3,sl,tp);
                 }
              }
        }
   if(Use_Symbol4)
      if(!is_positions4)
        {
         int signal=GetSignal(handle_iStochastic4);
         if(signal!=0)
            if(RefreshRates(m_symbol4))
              {
               if(signal==1)
                 {
                  double sl=(InpStopLoss==0)?0.0:m_symbol4.Ask()-ExtStopLoss1;
                  double tp=(InpTakeProfit==0)?0.0:m_symbol4.Ask()+ExtTakeProfit1;
                  OpenBuy(m_symbol4,sl,tp);
                 }
               if(signal==-1)
                 {
                  double sl=(InpStopLoss==0)?0.0:m_symbol4.Bid()+ExtStopLoss1;
                  double tp=(InpTakeProfit==0)?0.0:m_symbol4.Bid()-ExtTakeProfit1;
                  OpenSell(m_symbol4,sl,tp);
                 }
              }
        }
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
//| Searching Availability position                                  |
//+------------------------------------------------------------------+
void ExistPositions(bool &is_positions1,bool &is_positions2,bool &is_positions3,bool &is_positions4)
  {
   is_positions1=false;
   is_positions2=false;
   is_positions3=false;
   is_positions4=false;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Magic()==m_magic)
           {
            if(m_position.Symbol()==m_symbol1.Name())
               is_positions1=true;
            if(m_position.Symbol()==m_symbol2.Name())
               is_positions2=true;
            if(m_position.Symbol()==m_symbol3.Name())
               is_positions3=true;
            if(m_position.Symbol()==m_symbol4.Name())
               is_positions4=true;
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignal(int &handle)
  {
   int vSignal=0;

   double Stoch_Main_0 =iStochasticGet(handle,MAIN_LINE,0);
   double Stoch_Main_1 =iStochasticGet(handle,MAIN_LINE,1);
   double Stoch_Sign_0 =iStochasticGet(handle,SIGNAL_LINE,0);
   double Stoch_Sign_1 =iStochasticGet(handle,SIGNAL_LINE,1);

   if(Stoch_Main_0<20 && Stoch_Main_1<Stoch_Sign_1 && Stoch_Main_0>Stoch_Sign_0)
      vSignal=+1;//up
   else
   if(Stoch_Main_0>80 && Stoch_Main_1>Stoch_Sign_1 && Stoch_Main_0<Stoch_Sign_0)
      vSignal=-1;//down
//---
   return(vSignal);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(CSymbolInfo &m_symbol)
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
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(int handle_iStochastic,const int buffer,const int index)
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
void OpenBuy(CSymbolInfo &m_symbol,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),m_symbol.LotsMin(),m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=m_symbol.LotsMin())
        {
         if(m_trade.Buy(m_symbol.LotsMin(),m_symbol.Name(),m_symbol.Ask(),sl,tp))
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
void OpenSell(CSymbolInfo &m_symbol,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),m_symbol.LotsMin(),m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=m_symbol.LotsMin())
        {
         if(m_trade.Sell(m_symbol.LotsMin(),m_symbol.Name(),m_symbol.Bid(),sl,tp))
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
