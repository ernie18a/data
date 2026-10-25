//+------------------------------------------------------------------+
//|             RSI and Bollinger Bands(barabashkakvn's edition).mq5 |
//|                            FORTRADER.RU, Юрий, ftyuriy@gmail.com |
//|   http://FORTRADER.RU, торговля по болленджеру, параболику и RSI |
//+------------------------------------------------------------------+
/*Разработано для 51 выпуска журнала FORTRADER.Ru. 
Отчеты: http://finfile.ru/index.php/files/get/ZpUthihnKs/test2100809.rar
Сет файлы: http://finfile.ru/index.php/files/get/0BF1iPGVQJ/eurusd4h.set
Обсуждение: http://fxnow.ru/group_discussion_view.php?group_id=49&grouptopic_id=409&grouppost_id=3439#post_3439
Архив журнала: http://www.fortrader.ru/arhiv.php
51 выпуск: http://www.fortrader.ru/
*/

#property copyright "FORTRADER.RU, Юрий, ftyuriy@gmail.com"
#property link      "http://FORTRADER.RU, торговля по болленджеру, параболику и RSI"
#property version   "1.002"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
//---
sinput string  _0_                  = "--*--*--*--*--";  // RSI parameters
input int      rsi_ma_period        = 8;                 // RSI averaging period 
sinput string  _1_                  = "--*--*--*--*--";  // Bollinger Bands parameters
input int      bands_period         = 14;                // Bollinger Bands period for average line calculation 
input double   bands_deviation      = 1.0;               // Bollinger Bands number of standard deviations 
sinput string  _2_="--*--*--*--*--";  // SAR parameters
input double   step                 = 0.003;             // SAR price increment step - acceleration factor 
input double   maximum              = 0.2;               // SAR maximum value of step 
sinput string  _3_                  = "--*--*--*--*--";  // trade parameters
input double   InpLots              = 0.1;               // InpLots
input ushort   InpTakeProfit        = 50;                // Take Profit (in pips)
input ushort   InpStopLoss          = 135;               // Stop Loss (in pips)
input ushort   InpIndenting         = 15;                // Indenting (in pips)
input double   InpRSI_Up            = 70;                // RSI Up
input double   InpRSI_Down          = 30;                // RSI Down
input ushort   InpSARTrailingStop   = 10;                // SAR Trailing Stop (in pips)
//---
ulong          m_magic=564651;                           // magic number
ulong          m_slippage=10;                            // slippage
//---
bool okbuy=false,oksell=false;
//---
int            handle_iRSI;                              // variable for storing the handle of the iRSI indicator
int            handle_iBands;                            // variable for storing the handle of the iBands indicator 
int            handle_iSAR;                              // variable for storing the handle of the iSAR indicator 
int            handle_iFractals;                         // variable for storing the handle of the iFractals indicator 
double         m_adjusted_point;                         // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol()); // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

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
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(m_symbol.Name(),Period(),rsi_ma_period,PRICE_CLOSE);
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
//--- create handle of the indicator iBands
   handle_iBands=iBands(m_symbol.Name(),Period(),bands_period,0,bands_deviation,handle_iRSI);
//--- if the handle is not created 
   if(handle_iBands==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iSAR
   handle_iSAR=iSAR(m_symbol.Name(),Period(),step,maximum);
//--- if the handle is not created 
   if(handle_iSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iFractals
   handle_iFractals=iFractals(m_symbol.Name(),Period());
//--- if the handle is not created 
   if(handle_iFractals==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   okbuy=false;oksell=false;
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
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   Pattern();
   SarTrailingStop();
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Pattern()
  {
   double upfractal=0.0;
   double dwfractal=0.0;
   double fractal=0.0;
   double irsi=0.0;

   double op=0.0,sl=0.0,tp=0.0;

   irsi=iRSIGet(1);

   double bbup=iBandsGet(UPPER_BAND,1);
   double bblow=iBandsGet(LOWER_BAND,1);

   fractal=iFractalsGet(UPPER_LINE,3);
   fractal=(fractal==0.0 || fractal==EMPTY_VALUE)?0.0:fractal;
   if(fractal!=0)
      upfractal=fractal; //iFractals(NULL,0,MODE_UPPER,3);
   fractal=iFractalsGet(LOWER_LINE,3);
   fractal=(fractal==0.0 || fractal==EMPTY_VALUE)?0.0:fractal;
   if(fractal!=0)
      dwfractal=fractal;

   if(upfractal!=0.0)
      if(irsi>bbup && iClose(m_symbol.Name(),Period(),1)<upfractal && !okbuy)
        {
         op=upfractal+InpIndenting*m_adjusted_point;
         if(InpStopLoss>0)
            sl=op-InpStopLoss*m_adjusted_point;

         if(InpTakeProfit>0)
            tp=op+InpTakeProfit*m_adjusted_point;

         if(!m_trade.BuyStop(InpLots,m_symbol.NormalizePrice(op),m_symbol.Name(),
            m_symbol.NormalizePrice(sl),m_symbol.NormalizePrice(tp),0,0,"RSI and Bollinger Bands"))
           {
            Print("BUY_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                  ", op ",DoubleToString(op,m_symbol.Digits()),
                  " sl ",DoubleToString(sl,m_symbol.Digits()),
                  " tp ",DoubleToString(tp,m_symbol.Digits()));
            return;
           }
         okbuy=true;
        }

   if(irsi<InpRSI_Down)
     {
      DeleteOrders(ORDER_TYPE_BUY_STOP);
      okbuy=false;
     }

   if(dwfractal!=0.0)
      if(irsi<bblow && iClose(m_symbol.Name(),Period(),1)>dwfractal && !oksell)
        {
         op=dwfractal-InpIndenting*m_adjusted_point;
         if(InpStopLoss>0)
            sl=op+InpStopLoss*m_adjusted_point;

         if(InpTakeProfit>0)
            tp=op-InpTakeProfit*m_adjusted_point;

         if(!m_trade.SellStop(InpLots,m_symbol.NormalizePrice(op),m_symbol.Name(),
            m_symbol.NormalizePrice(sl),m_symbol.NormalizePrice(tp),0,0,"RSI and Bollinger Bands"))
           {
            Print("SELL_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                  ", op ",DoubleToString(op,m_symbol.Digits()),
                  " sl ",DoubleToString(sl,m_symbol.Digits()),
                  " tp ",DoubleToString(tp,m_symbol.Digits()));
            return;
           }
         oksell=true;
        }

   if(irsi>InpRSI_Up)
     {
      DeleteOrders(ORDER_TYPE_SELL_STOP);
      oksell=false;
     }

   return;
  }
//+------------------------------------------------------------------+
//| Parabolic Trailing                                               |
//+------------------------------------------------------------------+
void SarTrailingStop()
  {
   if(InpSARTrailingStop==0)
      return;

   double sar=iSARGet(1);

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.StopLoss()<sar)
                  if(sar<m_position.PriceCurrent()-InpSARTrailingStop*m_adjusted_point)
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(sar),m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               if(m_position.StopLoss()>sar)
                  if(sar>m_position.PriceCurrent()+InpSARTrailingStop*m_adjusted_point)
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(sar),m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
           }
//---
   return;
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
//| Get value of buffers for the iBands                              |
//|  the buffer numbers are the following:                           |
//|   0 - BASE_LINE, 1 - UPPER_BAND, 2 - LOWER_BAND                  |
//+------------------------------------------------------------------+
double iBandsGet(const int buffer,const int index)
  {
   double Bands[1];
//ArraySetAsSeries(Bands,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iBands,buffer,index,1,Bands)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Bands[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iFractals                           |
//|  the buffer numbers are the following:                           |
//|   0 - UPPER_LINE, 1 - LOWER_LINE                                 |
//+------------------------------------------------------------------+
double iFractalsGet(const int buffer,const int index)
  {
   double Fractals[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iFractalsBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iFractals,buffer,index,1,Fractals)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iFractals indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Fractals[0]);
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iSAR                                |
//+------------------------------------------------------------------+
double iSARGet(const int index)
  {
   double SAR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iSAR,0,index,1,SAR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(SAR[0]);
  }
//+------------------------------------------------------------------+
