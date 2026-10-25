//+------------------------------------------------------------------+
//|                                  Fractals at Close prices EA.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.005"
#property description "Idea: https://www.mql5.com/ru/forum/225066"
//+------------------------------------------------------------------+
//| Enum hours                                                       |
//+------------------------------------------------------------------+
enum ENUM_HOURS
  {
   hour_00  =0,   // 00
   hour_01  =1,   // 01
   hour_02  =2,   // 02
   hour_03  =3,   // 03
   hour_04  =4,   // 04
   hour_05  =5,   // 05
   hour_06  =6,   // 06
   hour_07  =7,   // 07
   hour_08  =8,   // 08
   hour_09  =9,   // 09
   hour_10  =10,  // 10
   hour_11  =11,  // 11
   hour_12  =12,  // 12
   hour_13  =13,  // 13
   hour_14  =14,  // 14
   hour_15  =15,  // 15
   hour_16  =16,  // 16
   hour_17  =17,  // 17
   hour_18  =18,  // 18
   hour_19  =19,  // 19
   hour_20  =20,  // 20
   hour_21  =21,  // 21
   hour_22  =22,  // 22
   hour_23  =23,  // 23
  };
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo     m_position;                   // trade position object
CTrade            m_trade;                      // trading object
CSymbolInfo       m_symbol;                     // symbol info object
//--- input parameters
input ENUM_HOURS  InpStarHour       = hour_10;  // Start trade hour
input ENUM_HOURS  InpEndHour        = hour_22;  // End trade hour
input double      InpLots           = 0.1;      // Lots
input ushort      InpStopLoss       = 30;       // Stop Loss (in pips)
input ushort      InpTakeProfit     = 50;       // Take Profit (in pips)
input ushort      InpTrailingStop   = 15;       // Trailing Stop (in pips)
input ushort      InpTrailingStep   = 5;        // Trailing Step (in pips)
input ulong       m_magic=15489;                // magic number
//---
ulong             m_slippage=30;                // slippage

double            ExtStopLoss=0.0;
double            ExtTakeProfit=0.0;
double            ExtTrailingStop=0.0;
double            ExtTrailingStep=0.0;

int               handle_iCustom;               // variable for storing the handle of the iCustom indicator 

double            m_adjusted_point;             // point value adjusted for 3 or 5 points
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

   ExtStopLoss    = InpStopLoss     * m_adjusted_point;
   ExtTakeProfit  = InpTakeProfit   * m_adjusted_point;
   ExtTrailingStop= InpTrailingStop * m_adjusted_point;
   ExtTrailingStep= InpTrailingStep * m_adjusted_point;
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),"Fractals at Close prices");
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
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
   datetime time_0=0;
   if(!iTime(0,time_0))
      return;
   if(time_0==PrevBars)
      return;
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }
   PrevBars=time_0;
//---
   datetime time_current=PrevBars;
   MqlDateTime struct_time_current;
   MqlDateTime struct_time_start;
   MqlDateTime struct_time_end;
   if(!TimeToStruct(time_current,struct_time_start) || 
      !TimeToStruct(time_current,struct_time_end) || 
      !TimeToStruct(time_current,struct_time_current))
     {
      PrevBars=0;
      return;
     }
   struct_time_start.hour=InpStarHour;
   struct_time_start.sec=0;
   struct_time_end.hour=InpEndHour;
   struct_time_end.sec=0;
   datetime time_start=StructToTime(struct_time_start);
   datetime time_end=StructToTime(struct_time_end);
   if(InpStarHour<InpEndHour) // trade in one day
     {
      if(time_current<time_start || time_current>=time_end)
        {
         CloseAllPositions();
         return;
        }
     }
   else if(InpStarHour>InpEndHour) // trade with transition next day
     {
      if(struct_time_current.hour<InpStarHour && struct_time_current.hour>=InpEndHour)
        {
         CloseAllPositions();
         return;
        }
     }
   else if(InpStarHour==InpEndHour)
     {
      // trade full day!!!
     }
//--- step 1: 
//--- search of the trend directed up (the last minimum has to be above the previous minimum)
//--- search of the trend directed down (the last maximum has to be below the previous maximum)
   int new_size=30;
   double fractal_lower[];
   double fractal_upper[];
   if(!iFractalsGet(handle_iCustom,LOWER_LINE,0,new_size,fractal_lower) || 
      !iFractalsGet(handle_iCustom,UPPER_LINE,0,new_size,fractal_upper) || 
      ArraySize(fractal_lower)!=new_size ||
      ArraySize(fractal_upper)!=new_size)
     {
      PrevBars=0;
      return;
     }
   ArraySetAsSeries(fractal_lower,true);
   ArraySetAsSeries(fractal_upper,true);
   double last_lower=EMPTY_VALUE;
   double previous_lower=EMPTY_VALUE;
   double last_upper=EMPTY_VALUE;
   double previous_upper=EMPTY_VALUE;
   for(int i=2;i<new_size;i++)
     {
      if(fractal_lower[i]!=EMPTY_VALUE && fractal_lower[i]!=0.0)
        {
         if(last_lower==EMPTY_VALUE)
           {
            last_lower=fractal_lower[i];
            continue;
           }
         if(previous_lower==EMPTY_VALUE)
           {
            previous_lower=fractal_lower[i];
            break;
           }
        }
      if(fractal_upper[i]!=EMPTY_VALUE && fractal_upper[i]!=0.0)
        {
         if(last_upper==EMPTY_VALUE)
           {
            last_upper=fractal_upper[i];
            continue;
           }
         if(previous_upper==EMPTY_VALUE)
           {
            previous_upper=fractal_upper[i];
            break;
           }
        }
     }
//---
   if(last_lower!=EMPTY_VALUE && previous_lower!=EMPTY_VALUE)
      if(previous_lower<last_lower)
        {
         ClosePositions(POSITION_TYPE_SELL);
         if(CalculatePositions(POSITION_TYPE_BUY)==0)
           {
            double sl=(InpTakeProfit==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpStopLoss==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            OpenBuy(sl,tp);
           }
        }
   if(last_upper!=EMPTY_VALUE && previous_upper!=EMPTY_VALUE)
      if(previous_upper>last_upper)
        {
         ClosePositions(POSITION_TYPE_BUY);
         if(CalculatePositions(POSITION_TYPE_SELL)==0)
           {
            double sl=(InpTakeProfit==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpStopLoss==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            OpenSell(sl,tp);
           }
        }
//---
   Trailing();
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
bool iTime(const int index,datetime &time,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime time_array[1];
   ResetLastError();
   if(CopyTime(symbol,timeframe,index,1,time_array)==-1)
     {
      Print(__FUNCTION__,", error: ",GetLastError());
      return(false);
     }
   time=time_array[0];
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iFractals                           |
//|  the buffer numbers are the following:                           |
//|   0 - UPPER_LINE, 1 - LOWER_LINE                                 |
//+------------------------------------------------------------------+
bool iFractalsGet(const int indicator_handle,const int buffer,const int start_pos,const int count,double &fractal_array[])
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iFractalsBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(indicator_handle,buffer,start_pos,count,fractal_array)!=count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iFractals indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
int CalculatePositions(const ENUM_POSITION_TYPE pos_type)
  {
   int count=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               count++;
//---
   return(count);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
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
         if(m_trade.Buy(InpLots,m_symbol.Name(),m_symbol.Ask(),sl,tp))
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
         if(m_trade.Sell(InpLots,m_symbol.Name(),m_symbol.Bid(),sl,tp))
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
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify BUY ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0.0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify SELL ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
              }

           }
  }
//+------------------------------------------------------------------+
