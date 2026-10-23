//+------------------------------------------------------------------+
//|                          2MA_4Level(barabashkakvn's edition).mq5 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh> 
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//+------------------------------------------------------------------+
//| 2 SMA, первая с параметрами 14, вторая с 180                     |
//| также есть параллельные построения:                              |
//|  SMA 180 + 250 пунктов по Y                                      |
//|  SMA 180 + 500 пунктов по Y                                      |
//|  SMA 180 - 250 пунктов по Y                                      |
//|  SMA 180 - 500 пунктов по Y                                      |
//| Работает так: когда MA14 пересекает любую линию                  |
//|  происходит либо покупка, либо продажа                           |
//+------------------------------------------------------------------+
input string               str_1                = "Торговые настройки";
input ushort               InpTakeProfit        = 55;
input ushort               InpStopLoss          = 260;
input int                  Lots                 = 1;
input string               str_2                = "Настройки индикаторов";
input ushort               calculation_bar      = 1;              // расчётный бар
input int                  ma_period_fast       = 50;             // период усреднения быстрой MA
input ENUM_MA_METHOD       ma_method_fast       = MODE_SMMA;      // тип сглаживания быстрой MA
input ENUM_APPLIED_PRICE   applied_price_fast   = PRICE_MEDIAN;   // тип цены быстрой MA 
input int                  ma_period_slow       = 130;            // период усреднения медленной MA  
input ENUM_MA_METHOD       ma_method_slow       = MODE_SMMA;      // тип сглаживания медленной MA    
input ENUM_APPLIED_PRICE   applied_price_slow   = PRICE_MEDIAN;   // тип цены медленной MA   
input string               str_3                = "Настройки уровней ";
//+------------------------------------------------------------------+
//| Для индикаторов, накладывающихся на график цен,                  |
//|  уровни отрисовываются путем суммирования значений индикатора    |
//|  и заданного уровня.                                             |
//+------------------------------------------------------------------+
input ushort               most_top_level       = 500;            // самый верхний уровень
input ushort               top_level            = 250;            // верхний уровень
input ushort               lower_level          = 250;            // нижний уровень
input ushort               lowermost_level      = 500;            // самый нижний уровень
//---
ulong  m_magic=276958256;                       // magic number
double ExtTakeProfit=0.0;
double ExtStopLoss=0.0;
int    handle_iMA_fast;                         // variable for storing the handle of the iMA indicator 
int    handle_iMA_slow;                         // variable for storing the handle of the iMA indicator 

ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double            m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
   if(ma_period_fast>=ma_period_slow)
     {
      Print("\"ma_period_fast\" is equal or more than \"ma_period_slow\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(most_top_level==0 || top_level==0 || lower_level==0 || lowermost_level==0)
     {
      Print("one of parameters (\"most_top_level\", \"top_level\", \"lower_level\", \"lowermost_level\") is equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(most_top_level<=top_level)
     {
      Print("\"most_top_level\" is less or equal \"top_level\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(lower_level>=lowermost_level)
     {
      Print("\"lower_level\" is more or equal \"lowermost_level\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   ExtTakeProfit  = InpTakeProfit * m_adjusted_point;
   ExtStopLoss    = InpStopLoss   * m_adjusted_point;
//--- create handle of the indicator iMA
   handle_iMA_fast=iMA(Symbol(),Period(),ma_period_fast,0,ma_method_fast,applied_price_fast);
//--- if the handle is not created 
   if(handle_iMA_fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle_iMA_fast of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMA
   handle_iMA_slow=iMA(Symbol(),Period(),ma_period_slow,0,ma_method_slow,applied_price_slow);
//--- if the handle is not created 
   if(handle_iMA_slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle_iMA_slow of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
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
   if(!ExistPositions())
     {
      if(!RefreshRates())
         return;

      if(GetSignal()==1)
        {
         if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),m_symbol.Ask()-ExtStopLoss,m_symbol.Ask()+ExtTakeProfit))
           {
            Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
        }
      if(GetSignal()==-1)
        {
         if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),m_symbol.Bid()+ExtStopLoss,m_symbol.Bid()-ExtTakeProfit))
           {
            Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
           }
        }
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignal()
  {
   double MA_fast_0=iMAGet(handle_iMA_fast,calculation_bar);
   double MA_fast_1=iMAGet(handle_iMA_fast,calculation_bar+1);
   double MA_slow_0=iMAGet(handle_iMA_slow,calculation_bar);
   double MA_slow_1=iMAGet(handle_iMA_slow,calculation_bar+1);

   int vSignal=0;
   double poin=m_symbol.Point();
   if(MA_fast_1<=MA_slow_1 && MA_fast_0>MA_slow_0)
      vSignal=1; // up
   else if(MA_fast_1<=MA_slow_1+most_top_level*poin && MA_fast_0>MA_slow_0+most_top_level*poin)
                      vSignal=1; // up
   else if(MA_fast_1<=MA_slow_1+top_level*poin && MA_fast_0>MA_slow_0+top_level*poin)
                      vSignal=1; // up    
   else if(MA_fast_1<=MA_slow_1-lowermost_level*poin && MA_fast_0>MA_slow_0-lowermost_level*poin)
                      vSignal=1; // up
   else if(MA_fast_1<=MA_slow_1-lower_level*poin && MA_fast_0>MA_slow_0-lower_level*poin)
                      vSignal=1; // up    
   else if(MA_fast_1>=MA_slow_1 && MA_fast_0<MA_slow_0)
                      vSignal=-1; // down
   else if(MA_fast_1>=MA_slow_1+most_top_level*poin && MA_fast_0<MA_slow_0+most_top_level*poin)
                      vSignal=-1; // down
   else if(MA_fast_1>=MA_slow_1+top_level*poin && MA_fast_0<MA_slow_0+top_level*poin)
                      vSignal=-1; // down
   else if(MA_fast_1>=MA_slow_1-lowermost_level*poin && MA_fast_0<MA_slow_0-lowermost_level*poin)
                      vSignal=-1; // down
   else if(MA_fast_1>=MA_slow_1-lower_level*poin && MA_fast_0<MA_slow_0-lower_level*poin)
                      vSignal=-1; // down    
   return (vSignal);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExistPositions(string sy="",int op=-1,int mn=-1,datetime ot=0)
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
