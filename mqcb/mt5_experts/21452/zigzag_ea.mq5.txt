//+------------------------------------------------------------------+
//|                           ZigZag EA(barabashkakvn's edition).mq5 |
//|                                   Copyright © 2009, Tokman Yuriy |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Tokman Yuriy"
#property link      "yuriytokman@gmail.com"
#property version   "1.002"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
CMoneyFixedMargin *m_money;
//---
enum ENUM_FIBO
  {
   level_0_0   = 0,  // 0.0% 
   level_23_6  = 1,  // 23.6%
   level_38_2  = 2,  // 38.2%
   level_50_0  = 3,  // 50.0% 
   level_61_8  = 4,  // 61.8%
   level_100_0 = 5,  // 100.0% 
   level_161_8 = 6,  // 161.8%
   level_261_8 = 7,  // 261.8%
   level_423_6 = 8,  // 423.6%
  };
//--- input parameters
input string      ____1___          = "Настройки индикатора ZigZag";
input int         ExtDepth          = 12;             // Depth
input int         ExtDeviation      = 5;              // Deviation
input int         ExtBackstep       = 3;              // Backstep
//---
input string      ____2___          = "Время работы советника";
input int         StartHour         = 00;             // Старт работы часы
input int         StartMinute       = 01;             // Старт работы минуты
input int         StopHour          = 23;             // Стоп работы часы
input int         StopMinute        = 59;             // Стоп работы минуты
//---
input string      ____3___          = "Настройки коридора и отступа";
input ushort      N_pips            = 5;              // Отступ в пунктах
input ushort      Min_Corridor      = 20;             // Минимальный размер коридора
input ushort      Max_Corridor      = 100;            // Максимальный размер коридора
//---
input string      ____4___          = "Настройки ММ";
input double      InpLots           = 0;              // Lots (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input double      Risk              = 5;              // Risk (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
//---
input string      _____5_____       = "Настройки советника";
input ENUM_FIBO   Fibo_StopLoss     = level_61_8;     // Размер стопа в процентах
input ENUM_FIBO   Fibo_TakeProfit   = level_161_8;    // Размер тейка в процентах
input ushort      InpTrailingStop   = 5;              // Trailing Stop (in pips)
input ushort      InpTrailingStep   = 5;              // Trailing Step (in pips)
input bool        Line              = false;          // Показывать линии канала
input ulong       m_magic           = 154897;         // magic number
//---
ulong             m_slippage=10;                      // slippage
//--- Глобальные переменные советника
int           NumberAccount    = 0;             // Номер торгового счёта
bool          gbDisabled       = false;         // Флаг блокировки советника
bool          gbNoInit         = false;         // Флаг неудачной инициализации
double current_high = 0, current_low = 0;
double          ppB = 0,         ppS = 0;
int    StopLoss     = 0;
int    TakeProfit   = 0;

double         ExtN_pips=0.0;
double         ExtMin_Corridor=0.0;
double         ExtMax_Corridor=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;

int            handle_iCustom;               // variable for storing the handle of the iCustom indicator 

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(StartHour>23)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Параметр \"Старт работы часы\" не может быть больше 23 часов!":
                  "Parameter \"Старт работы часы\" can not be more than 23 hours!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(StopHour>23)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Параметр \"Стоп работы часы\" не может быть больше 23 часов!":
                  "Parameter \"Стоп работы часы\" can not be more than 23 hours!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      string text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                  "Трейлинг невозможен: параметр \"Trailing Step\" равен нулю!":
                  "Trailing is not possible: parameter \"Trailing Step\" is zero!";
      Alert(__FUNCTION__," ERROR! ",text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtN_pips      = N_pips          * m_adjusted_point;
   ExtMin_Corridor= Min_Corridor    * m_adjusted_point;
   ExtMax_Corridor= Max_Corridor    * m_adjusted_point;
   ExtTrailingStop= InpTrailingStop * m_adjusted_point;
   ExtTrailingStep= InpTrailingStep * m_adjusted_point;
//---
   if(!LotsOrRisk(InpLots,Risk,digits_adjust))
      return(INIT_PARAMETERS_INCORRECT);
//---
   if(m_money!=NULL)
      delete m_money;
   m_money=new CMoneyFixedMargin;
   if(m_money!=NULL)
     {
      if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
         return(INIT_FAILED);
      m_money.Percent(Risk);
     }
   else
     {
      Print(__FUNCTION__,", ERROR: Object CMoneyFixedMargin is NULL");
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustom=iCustom(m_symbol.Name(),Period(),"Examples\\ZigZag");
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      if(m_money!=NULL)
         delete m_money;
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   if(Line)
     {
      HLineCreate(0,"00",0,0.0,clrYellow);
      HLineCreate(0,"high",0,0.0,clrBlue);
      HLineCreate(0,"low",0,0.0,clrRed);
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
   if(m_money!=NULL)
      delete m_money;

   if(Line)
     {
      HLineDelete(0,"00");
      HLineDelete(0,"high");
      HLineDelete(0,"low");
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Trailing();
//---
   double array_results[];
   if(!SearchZigZagExtremums(3,array_results))
      return;

   double high=0.0,low=0.0;
   double room_0 = array_results[0];
   double room_1 = array_results[1];
   double room_2 = array_results[2];
//--- находим верх и низ
   if(room_1>room_2)
     {
      high=room_1;
      low=room_2;
     }
   else
     {
      high=room_2;
      low=room_1;
     }
   double size_corridor=high-low;      // ширина коридора
   double STOPLEVEL=m_symbol.StopsLevel()*m_symbol.Point();
//--- вычисляем СТ и ТП
   StopLoss=(int)((size_corridor/100.0*GetFibo(Fibo_StopLoss))/m_symbol.Point());//  ???
   TakeProfit=(int)(((size_corridor/100.0*Fibo_TakeProfit)-size_corridor)/m_symbol.Point());//  ???
   ppB        = MathRound(high/m_symbol.Point() + N_pips )*m_symbol.Point();  //???
   ppS        = MathRound(low/m_symbol.Point()  - N_pips )*m_symbol.Point();  //???
//--- прорисовка линий для анализа
   if(Line)
     {
      HLineMove(0,"00",room_0);
      HLineMove(0,"high",high);
      HLineMove(0,"low",low);
     }
//--- удаляем отложку если есть рыночный ордер
   if(IsPositionExists())// есть открытая позиция
      if(IsPendingOrdersExists())
        {
         DeleteAllPendingOrders();// удаляем отложки
         return;
        }
//---
   double sl=0,tp=0,ti=0;

   if(size_corridor>ExtMin_Corridor && size_corridor<ExtMax_Corridor // коридор допустимой величины
      && high>room_0+STOPLEVEL && low<room_0-STOPLEVEL) // нулевая точка зига находится в коридоре   
     {
      if(!IsPositionExists()) //нет открытых позиций 
        {
         int   count_buy_stop    = 0;
         ulong ticket_buy_stop   = 0;
         int   count_sell_stop   = 0;
         ulong ticket_sell_stop  = 0;
         CalculateAllPendingOrders(count_buy_stop,ticket_buy_stop,count_sell_stop,ticket_sell_stop);
         if(count_buy_stop>1 || count_sell_stop>1)
            return;

         if(count_buy_stop==0) // нет байстопа
           {
            if(StopLoss>0)
               sl=ppB-StopLoss*m_symbol.Point();
            else
               sl=0;
            if(TakeProfit>0)
               tp=ppB+TakeProfit*m_symbol.Point();
            else
               tp=0;
            if(!RefreshRates())
               return;
            PendingBuyStop(ppB,sl,tp); // устанавливаем бай стоп
           }
         else if(count_buy_stop==1) // есть байстоп
           {
            if(m_order.Select(ticket_buy_stop))
               if(!CompareDoubles(m_order.PriceOpen(),ppB,m_symbol.Digits()))
                 {
                  //--- модифицируем
                  if(StopLoss>0)
                     sl=ppB-StopLoss*m_symbol.Point();
                  else
                     sl=0;
                  if(TakeProfit>0)
                     tp=ppB+TakeProfit*m_symbol.Point();
                  else
                     tp=0;
                  if(!RefreshRates())
                     return;
                  if(!m_trade.OrderModify(ticket_buy_stop,ppB,sl,tp,m_order.TypeTime(),m_order.TimeExpiration()))
                     Print("Modify BUY_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                           ", ticket of order: ",m_trade.ResultOrder());
                 }
           }

         if(count_sell_stop==0) //нет селлстопа     
           {
            if(StopLoss>0)
               sl=ppS+StopLoss*m_symbol.Point();
            else
               sl=0;
            if(TakeProfit>0)
               tp=ppS-TakeProfit*m_symbol.Point();
            else
               tp=0;
            if(!RefreshRates())
               return;
            PendingSellStop(ppS,sl,tp); // устанавливаем селл стоп    
           }
         else if(count_sell_stop==1) // есть селлстоп
           {
            if(m_order.Select(ticket_sell_stop))
               if(!CompareDoubles(m_order.PriceOpen(),ppS,m_symbol.Digits()))
                 {
                  //--- модифицируем
                  if(StopLoss>0)
                     sl=ppS+StopLoss*m_symbol.Point();
                  else
                     sl=0;
                  if(TakeProfit>0)
                     tp=ppS-TakeProfit*m_symbol.Point();
                  else
                     tp=0;
                  if(!RefreshRates())
                     return;
                  if(!m_trade.OrderModify(ticket_sell_stop,ppS,sl,tp,m_order.TypeTime(),m_order.TimeExpiration()))
                     Print("Modify SELL_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                           ", ticket of order: ",m_trade.ResultOrder());
                 }
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
//| Check the correctness of the position volume                     |
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
//| Lots or risk in percent for a deal from a free margin            |
//+------------------------------------------------------------------+
bool LotsOrRisk(const double lots,const double risk,const int digits_adjust)
  {
   if(lots<0.0 && risk<0.0)
     {
      Print(__FUNCTION__,", ERROR: Parameter (\"lots\" or \"risk\") can't be less than zero");
      return(false);
     }
   if(lots==0.0 && risk==0.0)
     {
      Print(__FUNCTION__,", ERROR: Trade is impossible: You have set \"lots\" == 0.0 and \"risk\" == 0.0");
      return(false);
     }
   if(lots>0.0 && risk>0.0)
     {
      Print(__FUNCTION__,", ERROR: Trade is impossible: You have set \"lots\" > 0.0 and \"risk\" > 0.0");
      return(false);
     }
   if(lots>0.0)
     {
      string err_text="";
      if(!CheckVolumeValue(lots,err_text))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(false);
        }
     }
   else if(risk>0.0)
     {
      if(m_money!=NULL)
         delete m_money;
      m_money=new CMoneyFixedMargin;
      if(m_money!=NULL)
        {
         if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
            return(INIT_FAILED);
         m_money.Percent(risk);
        }
      else
        {
         Print(__FUNCTION__,", ERROR: Object CMoneyFixedMargin is NULL");
         return(INIT_FAILED);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=false,   // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
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
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     RefreshRates();
                     m_position.SelectByIndex(i);
                     PrintResultModify(m_trade,m_symbol,m_position);
                     continue;
                    }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     RefreshRates();
                     m_position.SelectByIndex(i);
                     PrintResultModify(m_trade,m_symbol,m_position);
                    }
              }

           }
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }
//+------------------------------------------------------------------+
//| Search for indicator extremums                                   |
//+------------------------------------------------------------------+
bool SearchZigZagExtremums(const int count,double &array_results[])
  {
   if(!ArrayIsDynamic(array_results))
     {
      Print("This a no dynamic array!");
      return(false);
     }
   ArrayFree(array_results);
   ArrayResize(array_results,count);
   ArraySetAsSeries(array_results,true);
   int      buffer_num=0;           // indicator buffer number 
   double   arr_buffer[];
   ArraySetAsSeries(arr_buffer,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer
   int copied=CopyBuffer(handle_iCustom,buffer_num,0,100,arr_buffer);
   if(copied<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   int elements=0;
   for(int i=0;i<copied;i++)
     {
      if(arr_buffer[i]!=0)
        {
         array_results[elements]=arr_buffer[i];
         elements++;
         if(elements==count)
            break;
        }
     }
   if(elements==count)
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| GetFibo                                                          |
//+------------------------------------------------------------------+
double GetFibo(const ENUM_FIBO fibo)
  {
   double result=0;;
   switch(fibo)
     {
      case level_0_0:   result= 0.0;   break;
      case level_23_6:  result= 23.6;  break;
      case level_38_2:  result= 38.2;  break;
      case level_50_0:  result= 50.0;  break;
      case level_61_8:  result= 61.8;  break;
      case level_100_0: result= 100.0; break;
      case level_161_8: result= 161.8; break;
      case level_261_8: result= 261.8; break;
      case level_423_6: result= 423.6; break;
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders(void)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Is pendinf orders exists                                         |
//+------------------------------------------------------------------+
bool IsPendingOrdersExists(void)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Calculate all pending orders for symbol                          |
//+------------------------------------------------------------------+
void CalculateAllPendingOrders(int &count_buy_stop,ulong &ticket_buy_stop,
                               int &count_sell_stop,ulong &ticket_sell_stop)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
              {
               count_buy_stop++;
               ticket_buy_stop=m_order.Ticket();
              }
            if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
              {
               count_sell_stop++;
               ticket_sell_stop=m_order.Ticket();
              }
           }
//---
  }
//+------------------------------------------------------------------+
//| Pending order of Buy Stop                                        |
//+------------------------------------------------------------------+
void PendingBuyStop(double price,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=0.0;
   if(Risk>0.0)
     {
      check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_long_lot==0.0)
        {
         Print(__FUNCTION__,", ERROR: method CheckOpenLong returned the value of \"0.0\"");
         return;
        }
     }
   else
      check_open_long_lot=InpLots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=check_open_long_lot)
        {
         if(m_trade.BuyStop(check_open_long_lot,m_symbol.NormalizePrice(price),
            m_symbol.Name(),m_symbol.NormalizePrice(sl),m_symbol.NormalizePrice(tp)))
           {
            if(m_trade.ResultOrder()==0)
              {
               Print("#1 Buy Stop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Buy Stop -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Buy Stop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         string text="";
         if(Risk>0.0)
            text="< method CheckOpenLong ("+DoubleToString(check_open_long_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(InpLots,2)+")";
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               text);
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Pending order of Sell Stop                                       |
//+------------------------------------------------------------------+
void PendingSellStop(double price,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=0.0;
   if(Risk>0.0)
     {
      check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_short_lot==0.0)
        {
         Print(__FUNCTION__,", ERROR: method CheckOpenShort returned the value of \"0.0\"");
         return;
        }
     }
   else
      check_open_short_lot=InpLots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=check_open_short_lot)
        {
         if(m_trade.SellStop(check_open_short_lot,m_symbol.NormalizePrice(price),
            m_symbol.Name(),m_symbol.NormalizePrice(sl),m_symbol.NormalizePrice(tp)))
           {
            if(m_trade.ResultOrder()==0)
              {
               Print("#1 Sell Stop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Sell Stop -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Sell Stop -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         string text="";
         if(Risk>0.0)
            text="< method CheckOpenShort ("+DoubleToString(check_open_short_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(InpLots,2)+")";
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(InpLots,2),") ",
               text);
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   digits--;
   if(digits<0)
      digits=0;
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
