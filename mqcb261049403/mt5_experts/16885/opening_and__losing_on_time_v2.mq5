//+------------------------------------------------------------------+
//|                               Opening and Сlosing on time v2.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "2.002"
//+------------------------------------------------------------------+
//| Version 2:                                                       |
//|  comparison of two iMA (fast and slow)                           |
//|  Take Profit                                                     |
//|  Stop Loss                                                       |
//| Version 2.002:                                                   |
//|  add ENUM_TRADE                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Enum Trade                                                       |
//+------------------------------------------------------------------+
enum ENUM_TRADE
  {
   buy=0,         // only Buy
   sell=1,        // only Sell
   buy_and_sell=2,// Buy and Sell
  };
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                            // trade position object
CTrade         m_trade;                               // trading object
CSymbolInfo    m_symbol;                              // symbol info object
//--- input parameters
input datetime    m_time_open = D'1980.07.19 05:00:00';     // opening time (only HH:mm are considered)
input datetime    m_time_close= D'1980.07.19 21:01:00';     // closing time (only HH:mm are considered)
input string      InpSymbol   = "EURUSD";                   // symbol
input double      m_lots      = 1.0;                        // volume transaction
input ushort      Inp_sl      = 30;                         // sell stop
input ushort      Inp_tp      = 50;                         // take profit 
input ENUM_TRADE  Inp_trade   = buy_and_sell;               // type trading
input ulong       m_magic     = 19624;                      // magic number
input int                  Slow_MA_Period          =200;
input ENUM_MA_METHOD       Slow_MA_Method          =MODE_EMA;
input ENUM_APPLIED_PRICE   Slow_MA_Applied_Price   =PRICE_MEDIAN;
input int                  Fast_MA_Period          =50;
input ENUM_MA_METHOD       Fast_MA_Method          =MODE_EMA;
input ENUM_APPLIED_PRICE   Fast_MA_Applied_Price   =PRICE_MEDIAN;
//---
bool     IF_POSITION_ALREADY_OPEN=false;
int      handle_iMASlow;                  // variable for storing the handle of the iMA indicator 
int      handle_iMAFast;                  // variable for storing the handle of the iMA indicator 
double   Extm_sl=0;
double   Extm_tp=0;
double   m_adjusted_point;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- moving average only run expert advisor if there is enough candle/bars in history
   if(Bars(Symbol(),Period())<Slow_MA_Period+1 || Bars(Symbol(),Period())<Fast_MA_Period+1)
     {
      Print("Moving average does not have enough Bars in history to open a trade!\n",
            "Must be at least ",Slow_MA_Period," and ",Fast_MA_Period," bars to perform technical analysis.");
      return(INIT_FAILED);
     }
   if(Fast_MA_Period>=Slow_MA_Period)
     {
      Print("\"Fast_MA_Period\" can't be more or equally to \"Slow_MA_Period\".");
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMA
   handle_iMASlow=iMA(Symbol(),Period(),Slow_MA_Period,0,Slow_MA_Method,Slow_MA_Applied_Price);
//--- if the handle is not created 
   if(handle_iMASlow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

//--- create handle of the indicator iMA
   handle_iMAFast=iMA(Symbol(),Period(),Fast_MA_Period,0,Fast_MA_Method,Fast_MA_Applied_Price);
//--- if the handle is not created 
   if(handle_iMAFast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }

   if(m_time_open==m_time_close)
      return(INIT_PARAMETERS_INCORRECT);

   if(m_lots<=0.0)
     {
      Print("The \"volume transaction\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }

   string err_text="";
   if(!CheckVolumeValue(m_lots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!SymbolsFind(InpSymbol))
     {
      Print("The ",InpSymbol," symbol isn't found in MarketWatch");
      return(INIT_PARAMETERS_INCORRECT);
     }

   m_symbol.Name(InpSymbol);
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   Extm_sl  =Inp_sl*m_adjusted_point;
   Extm_tp  =Inp_tp*m_adjusted_point;

   m_trade.SetExpertMagicNumber(m_magic);
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
   MqlDateTime str_time_current,str_time_open,str_time_close;
   TimeToStruct(TimeCurrent(),str_time_current);
   TimeToStruct(m_time_open,str_time_open);
   TimeToStruct(m_time_close,str_time_close);

   if(!IF_POSITION_ALREADY_OPEN)
     {
      if(str_time_current.hour==str_time_open.hour)
         if(str_time_current.min==str_time_open.min)
           {
            if(Inp_trade==buy)
              {
               if(!CheckMoneyForTrade(InpSymbol,m_lots,ORDER_TYPE_BUY))
                  return;
              }
            else if(Inp_trade==sell)
              {
               if(!CheckMoneyForTrade(InpSymbol,m_lots,ORDER_TYPE_SELL))
                  return;
              }
            else if(Inp_trade==buy_and_sell)
              {
               double lot=LotCheck(m_lots*2.0);
               if(lot==0.0)
                  return;
               if(!CheckMoneyForTrade(InpSymbol,lot,ORDER_TYPE_BUY))
                  return;
               if(!CheckMoneyForTrade(InpSymbol,lot,ORDER_TYPE_SELL))
                  return;
              }
            //--- let's open the position
            double price=0.0;
            double tp=0.0;
            double sl=0.0;
            if(Inp_trade==buy || Inp_trade==buy_and_sell)
              {
               if(iMAGet(handle_iMAFast,1)>iMAGet(handle_iMASlow,1))
                 {
                  if(!RefreshRates())
                     return;

                  price=m_symbol.Ask();
                  sl=(Inp_sl==0)?0.0:m_symbol.Ask()-Extm_sl;
                  if(sl>=m_symbol.Bid()) // incident: the position isn't opened yet, and has to be already closed
                     return;
                  tp=(Inp_tp==0)?0.0:m_symbol.Ask()+Extm_tp;
                  m_trade.Buy(m_lots,InpSymbol,price,sl,tp);
                 }
              }
            if(Inp_trade==sell || Inp_trade==buy_and_sell)
              {
               if(iMAGet(handle_iMAFast,1)<iMAGet(handle_iMASlow,1))
                 {
                  if(!RefreshRates())
                     return;
                  price=m_symbol.Bid();
                  sl=(Inp_sl==0)?0.0:m_symbol.Bid()+Extm_sl;
                  if(sl<=m_symbol.Ask()) // incident: the position isn't opened yet, and has to be already closed
                     return;
                  tp=(Inp_tp==0)?0.0:m_symbol.Bid()-Extm_tp;
                  m_trade.Sell(m_lots,InpSymbol,price,sl,tp);
                 }
              }
            IF_POSITION_ALREADY_OPEN=true;
           }
     }
   else
     {
      if(str_time_current.hour==str_time_close.hour)
         if(str_time_current.min==str_time_close.min)
           {
            //--- let's close the position
            for(int i=PositionsTotal()-1;i>=0;i--)
              {
               m_position.SelectByIndex(i);
               if(m_position.Magic()==m_magic)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
              }
            IF_POSITION_ALREADY_OPEN=false;
           }
     }
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
//| Symbols Find                                                     |
//+------------------------------------------------------------------+
bool SymbolsFind(const string name_symbol)
  {
   int m_total=SymbolsTotal(false);
   for(int i=0;i<m_total;i++)
     {
      if(SymbolName(i,false)==name_symbol)
        {
         return(true);
         break;
        }
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Check Money For Trade                                            |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- call of the checking function
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- something went wrong, report and return false
      Print("Error in ",__FUNCTION__," code=",GetLastError());
      return(false);
     }
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      Print("Not enough money for ",EnumToString(type)," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle,const int index)
  {
   double MA[];
   ArraySetAsSeries(MA,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,0,index+1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[index]);
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
