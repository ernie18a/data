//+------------------------------------------------------------------+
//|                       VR---STEALS-2(barabashkakvn's edition).mq5 |
//|                                                      Voldemar227 |
//|                                         http://www.trading-go.ru |
//+------------------------------------------------------------------+
#property copyright "Voldemar227"
#property link      "http://www.trading-go.ru"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\DealInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CDealInfo      m_deal;                       // deals object
//---
input ushort InpTakeProfit    = 50;    // TakeProfit (если 0 то не используется)
input ushort InpStopLoss      = 50;    // StopLoss (если 0 то не используется)
input ushort InpBreakeven     = 20;    // Breakeven(если 0 то не используется)
input ushort InpBreakMinDis   = 9;     // Минимальная фиксация прибыли при переводе в безубыток
input ulong  Magic            = 0;     // (если 0 то по всем меджикам)
input ulong  InpSlip          = 20;    // Проскальзывания
input int    coment           = 1;     // Количество строк сообщений если 0 сообщения не выводятся
//---
double ExtTakeProfit = 0.0;
double ExtStopLoss   = 0.0;
double ExtBreakeven  = 0.0;
double ExtBreakMinDis= 0.0;
ulong  ExtSlip       = 0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(Magic);    // sets magic number
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

   ExtTakeProfit  = InpTakeProfit*digits_adjust;
   ExtStopLoss    = InpStopLoss*digits_adjust;
   ExtBreakeven   = InpBreakeven*digits_adjust;
   ExtBreakMinDis = InpBreakMinDis*digits_adjust;
   ExtSlip        = InpSlip*digits_adjust;

   m_trade.SetDeviationInPoints(ExtSlip);
//--- Выведем при старте на экран наши установленные параметры
   pr("TakeProfit = "+DoubleToString(ExtTakeProfit,0));
   pr("StopLoss   = "+DoubleToString(ExtStopLoss,0));
   pr("Breakeven  = "+DoubleToString(ExtBreakeven,0));
   if(Magic==0)
      pr("По всем меджик номерам  = "+IntegerToString(Magic));
   else
      pr("Меджик номер  = "+IntegerToString(Magic));
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static bool first=true;
   if(first)
     {
      m_trade.Buy(0.01);
      first=false;
     }
//--- Перебираем ордера и работаем с ними
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==Magic || Magic==0)
              {
               if(!RefreshRates())
                  return;
               if(m_position.PositionType()==POSITION_TYPE_BUY) // Работаем с бай ордерами
                 {
                  if(ExtBreakeven!=0) // Если безубыток выставлен
                    {
                     //--- Нарисуем метку безубытка
                     arrov("bz"+IntegerToString(m_position.Ticket()),iTime(0),
                           NormalizeDouble(m_position.PriceOpen()+ExtBreakMinDis*Point(),Digits()),1,clrGreen);
                     //--- Проверим расположение цены относительно безубытка
                     if(m_symbol.Ask()>NormalizeDouble(m_position.PriceOpen()+ExtBreakeven*Point(),Digits()) && m_position.StopLoss()==0)
                       {
                        //--- Если цена больше заданного значения , выставим безубыток с небольшой фиксацией прибыли
                        if(m_trade.PositionModify(m_position.Ticket(),NormalizeDouble(m_position.PriceOpen()+ExtBreakMinDis*Point(),Digits()),m_position.TakeProfit()))
                           pr("Безубыток выставлен"); //Раскоментируем происходящее
                        else
                           pr(IntegerToString(m_trade.ResultRetcode())+", "+m_trade.ResultRetcodeDescription());
                       }
                    }
                  else
                     ObjectDelete(0,"bz"+IntegerToString(m_position.Ticket()));

                  if(ExtTakeProfit!=0)
                    {
                     //--- Нарисуем метку Тейк Профита
                     arrov("tp"+IntegerToString(m_position.Ticket()),iTime(0),NormalizeDouble(m_position.PriceOpen()+ExtTakeProfit*Point(),Digits()),1,clrBlue);
                     //--- Проверим расположение цены относительно Тейк Профита
                     if(m_symbol.Ask()>NormalizeDouble(m_position.PriceOpen()+ExtTakeProfit*Point(),Digits()))
                       {
                        //--- Если цена больше заданного значения , закроем ордер
                        if(m_trade.PositionClose(m_position.Ticket()))
                           pr("Ордер закрыт"); //--- Раскоментируем происходящее  
                        else
                           pr(IntegerToString(m_trade.ResultRetcode())+", "+m_trade.ResultRetcodeDescription());
                       }
                    }
                  else
                     ObjectDelete(0,"tp"+IntegerToString(m_position.Ticket()));

                  if(ExtStopLoss!=0)
                    {
                     //--- Нарисуем метку Стоп Лосса
                     arrov("sl"+IntegerToString(m_position.Ticket()),iTime(0),NormalizeDouble(m_position.PriceOpen()-ExtStopLoss*Point(),Digits()),1,clrRed);
                     //--- Проверим расположение цены относительно Стоп Лосса
                     if(m_symbol.Bid()<NormalizeDouble(m_position.PriceOpen()-ExtStopLoss*Point(),Digits()))
                       {
                        //--- Если цена меньше заданного значения , закроем ордер
                        if(m_trade.PositionClose(m_position.Ticket()))
                           pr("Ордер закрыт"); //--- Раскоментируем происходящее  
                        else
                           pr(IntegerToString(m_trade.ResultRetcode())+", "+m_trade.ResultRetcodeDescription());
                       }
                    }
                  else
                     ObjectDelete(0,"sl"+IntegerToString(m_position.Ticket()));
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL) // Работаем с селл ордерами
                 {
                  if(ExtBreakeven!=0)
                    {
                     arrov("bz"+IntegerToString(m_position.Ticket()),iTime(0),NormalizeDouble(m_position.PriceOpen()-ExtBreakMinDis*Point(),Digits()),1,clrGreen);
                     if(m_symbol.Bid()<NormalizeDouble(m_position.PriceOpen()-ExtBreakeven*Point(),Digits()) && m_position.StopLoss()==0)
                       {
                        if(m_trade.PositionModify(m_position.Ticket(),NormalizeDouble(m_position.PriceOpen()-ExtBreakMinDis*Point(),Digits()),m_position.TakeProfit()))
                           pr("Безубыток выставлен");
                        else
                           pr(IntegerToString(m_trade.ResultRetcode())+", "+m_trade.ResultRetcodeDescription());
                       }
                    }
                  else
                     ObjectDelete(0,"bz"+IntegerToString(m_position.Ticket()));

                  if(ExtTakeProfit!=0)
                    {
                     arrov("tp"+IntegerToString(m_position.Ticket()),iTime(0),NormalizeDouble(m_position.PriceOpen()-ExtTakeProfit*Point(),Digits()),1,clrBlue);
                     if(m_symbol.Bid()<NormalizeDouble(m_position.PriceOpen()-ExtTakeProfit*Point(),Digits()))
                       {
                        if(m_trade.PositionClose(m_position.Ticket()))
                           pr("Ордер закрыт");
                        else
                           pr(IntegerToString(m_trade.ResultRetcode())+", "+m_trade.ResultRetcodeDescription());
                       }
                    }
                  else
                     ObjectDelete(0,"tp"+IntegerToString(m_position.Ticket()));

                  if(ExtStopLoss!=0)
                    {
                     arrov("sl"+IntegerToString(m_position.Ticket()),iTime(0),NormalizeDouble(m_position.PriceOpen()+ExtStopLoss*Point(),Digits()),1,clrRed);
                     if(m_symbol.Ask()>NormalizeDouble(m_position.PriceOpen()+ExtStopLoss*Point(),Digits()))
                       {
                        if(m_trade.PositionClose(m_position.Ticket()))
                           pr("Ордер закрыт");
                        else
                           pr(IntegerToString(m_trade.ResultRetcode())+", "+m_trade.ResultRetcodeDescription());
                       }
                    }
                  else
                     ObjectDelete(0,"sl"+IntegerToString(m_position.Ticket()));
                 }
              }
//--- В случае если ордер закрыт удалим его метки   
   objdel();
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Удаление меток созданных советником при удалении советника
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
        {
         ObjectDelete(0,"bz"+IntegerToString(m_position.Ticket()));
         ObjectDelete(0,"tp"+IntegerToString(m_position.Ticket()));
         ObjectDelete(0,"sl"+IntegerToString(m_position.Ticket()));
         ObjectDelete(0,"txtw"+IntegerToString(i));
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void objdel()
  {
   HistorySelect(TimeCurrent()-86400,TimeCurrent()+86400);
   ulong    ticket=0;
   uint     total=HistoryDealsTotal();
   for(uint i=0;i<total;i++)
      if(m_deal.SelectByIndex(i))
         if(m_deal.Entry()==DEAL_ENTRY_OUT || m_deal.Entry()==DEAL_ENTRY_INOUT) // В случае если позиция закрыта удалим его метки  
           {
            ObjectDelete(0,"bz"+IntegerToString(m_deal.PositionId()));
            ObjectDelete(0,"tp"+IntegerToString(m_deal.PositionId()));
            ObjectDelete(0,"sl"+IntegerToString(m_deal.PositionId()));
           }
  }
//+------------------------------------------------------------------+
//| Функция отрисовки меток                                          |
//+------------------------------------------------------------------+
void arrov(string name,datetime time,double price,int width,color clr)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_ARROW_RIGHT_PRICE,0,0,0);
   ObjectMove(0,name,0,time,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
  }
//+------------------------------------------------------------------+
//| Функция отрисовки сообщений                                      |
//+------------------------------------------------------------------+
void pr(string txt)
  {
   string info[];
   ArrayResize(info,coment);
   string h,m,s,cm; //int i;

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   h=IntegerToString(str1.hour);
   if(StringLen(h)<2)
      h="0"+h;

   m=IntegerToString(str1.min);
   if(StringLen(m)<2)
      m="0"+m;

   s=IntegerToString(str1.sec);
   if(StringLen(s)<2)
      s="0"+s;

   txt=h+":"+m+":"+s+"  "+txt;
   for(int i=coment-1; i>=1; i--)
      info[i]=info[i-1];
   info[0]=txt;

   for(int i=coment-1; i>=0; i--)
      if(info[i]!="")
        {
         cm=info[i];
         ObjectCreate(0,"txtw"+IntegerToString(i),OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,"txtw"+IntegerToString(i),OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"txtw"+IntegerToString(i),OBJPROP_XDISTANCE,10);
         ObjectSetInteger(0,"txtw"+IntegerToString(i),OBJPROP_YDISTANCE,30+15*i);
         ObjectSetString(0,"txtw"+IntegerToString(i),OBJPROP_TEXT,txt);
         ObjectSetString(0,"txtw"+IntegerToString(i),OBJPROP_FONT,"Times New Roman");
         ObjectSetInteger(0,"txtw"+IntegerToString(i),OBJPROP_FONTSIZE,10);
         ObjectSetInteger(0,"txtw"+IntegerToString(i),OBJPROP_COLOR,clrGreen);
        }
  }
//+------------------------------------------------------------------+
//| Список ошибок                                                    |
//+------------------------------------------------------------------+
string Error(int error_code)
  {
   string error_string;
   switch(error_code)
     {
      case 0:   error_string="No error returned.";                                                            break;
      case 1:   error_string="No error returned, but the result is unknown.";                                 break;
      case 2:   error_string="Common error.";                                                                 break;
      case 3:   error_string="Invalid trade parameters.";                                                     break;
      case 4:   error_string="Trade server is busy.";                                                         break;
      case 5:   error_string="Old version of the client terminal.";                                           break;
      case 6:   error_string="No connection with trade server.";                                              break;
      case 7:   error_string="Not enough rights.";                                                            break;
      case 8:   error_string="Too frequent requests.";                                                        break;
      case 9:   error_string="Malfunctional trade operation.";                                                break;
      case 64:  error_string="Account disabled.";                                                             break;
      case 65:  error_string="Invalid account.";                                                              break;
      case 128: error_string="Trade timeout.";                                                                break;
      case 129: error_string="Invalid price.";                                                                break;
      case 130: error_string="Invalid stops.";                                                                break;
      case 131: error_string="Invalid trade volume.";                                                         break;
      case 132: error_string="Market is closed.";                                                             break;
      case 133: error_string="Trade is disabled.";                                                            break;
      case 134: error_string="Not enough money.";                                                             break;
      case 135: error_string="Price changed.";                                                                break;
      case 136: error_string="Off quotes.";                                                                   break;
      case 137: error_string="Broker is busy.";                                                               break;
      case 138: error_string="Requote.";                                                                      break;
      case 139: error_string="Order is locked.";                                                              break;
      case 140: error_string="Long positions only allowed.";                                                  break;
      case 141: error_string="Too many requests.";                                                            break;
      case 145: error_string="Modification denied because an order is too close to market.";                  break;
      case 146: error_string="Trade context is busy.";                                                        break;
      case 147: error_string="Expirations are denied by broker.";                                             break;
      case 148: error_string="The amount of opened and pending orders has reached the limit set by a broker.";break;
      case 4000: error_string="No error.";                                                                    break;
      case 4001: error_string="Wrong function pointer.";                                                      break;
      case 4002: error_string="Array index is out of range.";                                                 break;
      case 4003: error_string="No memory for function call stack.";                                           break;
      case 4004: error_string="Recursive stack overflow.";                                                    break;
      case 4005: error_string="Not enough stack for parameter.";                                              break;
      case 4006: error_string="No memory for parameter string.";                                              break;
      case 4007: error_string="No memory for temp string.";                                                   break;
      case 4008: error_string="Not initialized string.";                                                      break;
      case 4009: error_string="Not initialized string in an array.";                                          break;
      case 4010: error_string="No memory for an array string.";                                               break;
      case 4011: error_string="Too long string.";                                                             break;
      case 4012: error_string="Remainder from zero divide.";                                                  break;
      case 4013: error_string="Zero divide.";                                                                 break;
      case 4014: error_string="Unknown command.";                                                             break;
      case 4015: error_string="Wrong jump.";                                                                  break;
      case 4016: error_string="Not initialized array.";                                                       break;
      case 4017: error_string="DLL calls are not allowed.";                                                   break;
      case 4018: error_string="Cannot load library.";                                                         break;
      case 4019: error_string="Cannot call function.";                                                        break;
      case 4020: error_string="EA function calls are not allowed.";                                           break;
      case 4021: error_string="Not enough memory for a string returned from a function.";                     break;
      case 4022: error_string="System is busy.";                                                              break;
      case 4050: error_string="Invalid function parameters count.";                                           break;
      case 4051: error_string="Invalid function parameter value.";                                            break;
      case 4052: error_string="String function internal error.";                                              break;
      case 4053: error_string="Some array error.";                                                            break;
      case 4054: error_string="Incorrect series array using.";                                                break;
      case 4055: error_string="Custom indicator error.";                                                      break;
      case 4056: error_string="Arrays are incompatible.";                                                     break;
      case 4057: error_string="Global variables processing error.";                                           break;
      case 4058: error_string="Global variable not found.";                                                   break;
      case 4059: error_string="Function is not allowed in testing mode.";                                     break;
      case 4060: error_string="Function is not confirmed.";                                                   break;
      case 4061: error_string="Mail sending error.";                                                          break;
      case 4062: error_string="String parameter expected.";                                                   break;
      case 4063: error_string="Integer parameter expected.";                                                  break;
      case 4064: error_string="Double parameter expected.";                                                   break;
      case 4065: error_string="Array as parameter expected.";                                                 break;
      case 4066: error_string="Requested history data in updating state.";                                    break;
      case 4067: error_string="Some error in trade operation execution.";                                     break;
      case 4099: error_string="End of a file.";                                                               break;
      case 4100: error_string="Some file error.";                                                             break;
      case 4101: error_string="Wrong file name.";                                                             break;
      case 4102: error_string="Too many opened files.";                                                       break;
      case 4103: error_string="Cannot open file.";                                                            break;
      case 4104: error_string="Incompatible access to a file.";                                               break;
      case 4105: error_string="No order selected.";                                                           break;
      case 4106: error_string="Unknown symbol.";                                                              break;
      case 4107: error_string="Invalid price.";                                                               break;
      case 4108: error_string="Invalid ticket.";                                                              break;
      case 4109: error_string="Trade is not allowed.";                                                        break;
      case 4110: error_string="Longs are not allowed.";                                                       break;
      case 4111: error_string="Shorts are not allowed.";                                                      break;
      case 4200: error_string="Object already exists.";                                                       break;
      case 4201: error_string="Unknown object property.";                                                     break;
      case 4202: error_string="Object does not exist.";                                                       break;
      case 4203: error_string="Unknown object type.";                                                         break;
      case 4204: error_string="No object name.";                                                              break;
      case 4205: error_string="Object coordinates error.";                                                    break;
      case 4206: error_string="No specified subwindow.";                                                      break;
      default:   error_string="Some error in object operation.";
     }
   return(error_string);
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[];
   datetime time=0;
   ArraySetAsSeries(Time,true);
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
