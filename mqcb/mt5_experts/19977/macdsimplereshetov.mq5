//+------------------------------------------------------------------+
//|                  MACDSimpleReshetov(barabashkakvn's edition).mq5 |
//|                               Copyright © 2006, Yury V. Reshetov |
//|                                         http://reshetov.xnet.uz/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Yury V. Reshetov ICQ: 282715499"
#property link      "http://reshetov.xnet.uz/"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input double   Lots        = 2;  // Объем открываемых позиций
input uchar    DF          = 1;  // Приращение периода быстрой средней к периоду сигнальной линии
input uchar    DS          = 2;  // Приращение периода медленной средней к периоду быстрой средней
input uchar    SignalPeriod= 10; // Период сигнальной линии
input ulong    m_magic=42828093; // magic number
ulong          m_slippage=10;    // slippage
//---
int         handle_iMACD;        // variable for storing the handle of the iMACD indicator 
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
   if(!CheckVolumeValue(Lots,err_text))
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
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(m_symbol.Name(),Period(),SignalPeriod+DF,SignalPeriod+DS+DF,SignalPeriod,PRICE_CLOSE);
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
//--- мы работаем только во время рождения нового бара
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//--- значение основной линии MACD
   double main=iMACDGet(MAIN_LINE,0);
//--- значение сигнальной линии MACD
   double signal=iMACDGet(SIGNAL_LINE,0);
//--- открытые позиции
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && main<0) // здесь мы покупали, а сигнал на продажу
              {
               //--- так дело не пойдет, выходим из рынка
               m_trade.PositionClose(m_position.Ticket());
               return;
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL && main>0) // здесь мы продавали, а сигнал на покупку
              {
               //--- верните наши денежки или то, что от них осталось
               m_trade.PositionClose(m_position.Ticket());
               return;
              }
            //--- Открытая позиция на этом инструменте уже есть, вторую открывать не будем, 
            //--- а лучше завершим работу эксперта
            return;
           }
//--- если обе линии по одну сторону фронта, то входим в рынок
   if((main*signal)>0)
     {
      //--- если сигнал на покупку
      if(main>0)
        {
         //--- значит купим
         if(main>signal)
            m_trade.Buy(Lots,m_symbol.Name());
         return;
        }
      else
        {
         //--- здесь мы продаем
         if(main<signal)
            m_trade.Sell(Lots,m_symbol.Name());
         return;
        }
     }
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
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
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
