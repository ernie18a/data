//+------------------------------------------------------------------+
//|                         ichimok2005(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, ForexProf"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
sinput string           _0_               = "Ichimoku settings";  // Ichimoku settings
input int               Ich_tenkan_sen    = 9;                    // Ichimoku: period of Tenkan-sen 
input int               Ich_kijun_sen     = 26;                   // Ichimoku: period of Kijun-sen 
input int               Ich_senkou_span_b = 52;                   // Ichimoku: period of Senkou Span B 
sinput string           _1_               = "Trade settings";     // Trade settings
input double            InpLots           = 0.1;                  // Lots
input ushort            InpStopLoss       = 30;                   // Stop Loss (in pips)
input ushort            InpTakeProfit     = 60;                   // Take Profit (in pips)
input ulong             m_magic           = 108813112;            // magic number
//---
ulong                   m_slippage=30;                            // slippage

double                  ExtStopLoss=0.0;
double                  ExtTakeProfit=0.0;

int                     handle_iIchimoku;                         // variable for storing the handle of the iIchimoku indicator 
double                  m_adjusted_point;                         // point value adjusted for 3 or 5 points
//----
bool buysig,sellsig; int lastsig;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol()))
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
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
//--- create handle of the indicator iIchimoku
   handle_iIchimoku=iIchimoku(m_symbol.Name(),Period(),Ich_tenkan_sen,Ich_kijun_sen,Ich_senkou_span_b);
//--- if the handle is not created 
   if(handle_iIchimoku==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iIchimoku indicator for the symbol %s/%s, error code %d",
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
   bool  buys=false;
   bool  sells=false;
   if(!CheckForSignals(buys,sells))
     {
      PrevBars=iTime(1);
      return;
     }
   if(buys)
     {
      double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
      OpenBuy(sl,tp);
      ClosePositions(POSITION_TYPE_SELL);
     }
   if(sells)
     {
      double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
      double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
      OpenSell(sl,tp);
      ClosePositions(POSITION_TYPE_BUY);
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
//| Get value of buffers for the iIchimoku                           |
//|  the buffer numbers are the following:                           |
//|   0 - TENKANSEN_LINE, 1 - KIJUNSEN_LINE, 2 - SENKOUSPANA_LINE,   |
//|   3 - SENKOUSPANB_LINE, 4 - CHIKOUSPAN_LINE                      |
//+------------------------------------------------------------------+
double iIchimokuGet(const int buffer,const int index)
  {
   double Ichimoku[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iIchimoku array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iIchimoku,buffer,index,1,Ichimoku)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iIchimoku indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Ichimoku[0]);
  }
//+------------------------------------------------------------------+ 
//| Get Open for specified bar index                                 | 
//+------------------------------------------------------------------+ 
double iOpen(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Open[1];
   double open=0;
   int copied=CopyOpen(symbol,timeframe,index,1,Open);
   if(copied>0)
      open=Open[0];
   return(open);
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
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
bool CheckForSignals(bool  &buys,bool  &sells)
  {
//+------------------------------------------------------------------+
//| Get value of buffers for the iIchimoku                           |
//|  the buffer numbers are the following:                           |
//|   0 - TENKANSEN_LINE, 1 - KIJUNSEN_LINE, 2 - SENKOUSPANA_LINE,   |
//|   3 - SENKOUSPANB_LINE, 4 - CHIKOUSPAN_LINE                      |
//+------------------------------------------------------------------+
   double Senkou_Span_A=iIchimokuGet(SENKOUSPANA_LINE,1);
   double Senkou_Span_B=iIchimokuGet(SENKOUSPANB_LINE,1);
   if(Senkou_Span_A==0.0 || Senkou_Span_B==0.0)
      return(false);
   double Open=iOpen(1);
   double Close=iClose(1);
   if(Open==0.0 || Close==0.0)
      return(false);

   if(Senkou_Span_A>Senkou_Span_B)
      if(Close>Open)
         if(Senkou_Span_B<Close && Close<Senkou_Span_A)
           {
            //--- sell signal
            buys=true;
            sells=false;
            return(true);
           }
   if(Senkou_Span_B>Senkou_Span_A)
      if(Open>Close)
         if(Senkou_Span_B>Close && Close>Senkou_Span_A)
           {
            //--- sell signal
            buys=false;
            sells=true;
            return(true);
           }
//---
   return(false);
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
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,NULL,m_symbol.Ask(),sl,tp))
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
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,NULL,m_symbol.Bid(),sl,tp))
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
