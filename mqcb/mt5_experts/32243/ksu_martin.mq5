//+------------------------------------------------------------------+
//|                                                   KSU_martin.mg5 |
//|                                     Copyright 2020, Knazev Segey |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Knazev Segey"
#include <Trade\Trade.mqh>

input bool                start_order=false;           // начать торговлю / закрыть сетку
input double              start_lot=0.1;               // начальный лот
input double              tp_in_money=10.0;            // профит в валюте
input double              multiplier=1.2;              // множитель лота
input double              signal=true;                 // сетка: сигнал / без сигнала
input int                 range=10;                    // шаг сетки
input bool                close_all=true;              // закрывать все ордера
input bool                close_buy=true;              // закрывать все buy ордера
input bool                close_sell=true;             // закрывать все sell ордера


input bool                info=false;                   // вывод информации


input ENUM_TIMEFRAMES     cci_timeframe=PERIOD_M1;      // период графика CCI
input int                 cci_period=14;                // период CCI
input ENUM_APPLIED_PRICE  cci_price=PRICE_CLOSE;        // тип цены CCI
input int                 cci_level=100;                // зона CCI

input ENUM_TIMEFRAMES     rsi_timeframe=PERIOD_M1;      // период графика RSI
input int                 rsi_period=14;                // период RSI
input ENUM_APPLIED_PRICE  rsi_price=PRICE_CLOSE;        // тип цены RSI
input int                 rsi_level=30;                 // зона RSI

input bool                use_ma=true;                  // вкл MA
input ENUM_TIMEFRAMES     ma_timeframe=PERIOD_M1;       // период графика МА
input int                 ma_period=5;                  // период MA
input ENUM_MA_METHOD      ma_metod=MODE_SMA;            // способ усреднения MA
input ENUM_APPLIED_PRICE  ma_price=PRICE_CLOSE;         // тип цены MA

//-- глобальные переменные
ulong             pos_TIC; // переменная для хранения тикета ордеров
string            my_symbol; //переменная для хранения символа
ENUM_TIMEFRAMES   my_timeframe;  //переменная для хранения таймфрейма
double            my_point; // переменная для текущего размер пункта
int               my_digits; // переменная для количество десятичных знаков после запятой
CTrade            m_Trade; //структура для выполнения торговых операций

int               Hand_RSI;  // хендел RSI
double            Val_RSI[]; // массив для значений RSI
int               Hand_CCI;  // хендел CCI
double            Val_CCI[]; // массив для значений CCI
int               Hand_MA;   // хендел MA
double            Val_MA[];  // массив для значений MA
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment(" ");
   my_symbol=Symbol();          // текущий символ
   my_timeframe=PERIOD_CURRENT; // текущий период
   my_point=Point();            // размер пункта
   my_digits=Digits();          // количество десятичных знаков

   if(_Digits == 5 || _Digits == 3)
      my_point *= 10;

   Hand_RSI=iRSI(my_symbol,rsi_timeframe,rsi_period,rsi_price);
   Hand_CCI=iCCI(my_symbol,cci_timeframe,cci_period,cci_price);
   Hand_MA=iMA(my_symbol,ma_timeframe,ma_period,0,ma_metod,ma_price);
   if(Hand_RSI<0 || Hand_CCI<0 || Hand_MA<0)
     {
      Alert("Ошибка при создании индикаторов - номер ошибки: ",GetLastError(),"!!");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Удаляем гафику
   Comment(" ");
   ObjectDelete(0,"pr");
   ObjectDelete(0,"or");
   ObjectDelete(0,"to");
//--- Освобождаем хэндлы индикаторов
   IndicatorRelease(Hand_RSI);
   IndicatorRelease(Hand_CCI);
   IndicatorRelease(Hand_MA);
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   if(info)
      draw_info();

   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;

   int copied=CopyTime(my_symbol,my_timeframe,0,1,New_Time);
   if(copied>0)
     {
      if(Old_Time!=New_Time[0])
        {
         IsNewBar=true;
         if(MQL5InfoInteger(MQL5_DEBUGGING))
            Print("Новый бар",New_Time[0],"старый бар",Old_Time);
         Old_Time=New_Time[0];
        }
     }
   else
     {
      Alert("Ошибка копирования времени, номер ошибки =",GetLastError());
      ResetLastError();
      return;
     }
   if(IsNewBar==false)
     {
      return;
     }
//--- обновим структуры, которые будут использоваться для торговли
   MqlTick latest_price;              // для текущих котировок
   MqlTradeRequest mrequest;          // для отправки торговых запросов
   MqlTradeResult mresult;            // для получения результатов исполнения торговых запросов
   MqlRates mrate[];                  // содержит цены, объемы и спред для каждого бара
   ZeroMemory(mrequest);

   ArraySetAsSeries(mrate,true);
   ArraySetAsSeries(Val_CCI,true);
   ArraySetAsSeries(Val_RSI,true);
   ArraySetAsSeries(Val_MA,true);
//--- Получить исторические данные последних 3-х баров
   if(CopyRates(my_symbol,PERIOD_D1,0,3,mrate)<0)
     {
      Alert("Ошибка копирования исторических данных - ошибка:",GetLastError(),"!!");
      return;
     }
//--- Скопировать исторические данные последних значений индикаторов 3-х баров
   if(CopyBuffer(Hand_MA,0,0,3,Val_MA)<0 || CopyBuffer(Hand_RSI,0,0,3,Val_RSI)<0 || CopyBuffer(Hand_CCI,0,0,3,Val_CCI)<0)
     {
      Alert("Ошибка копирования буферов индикаторов - номер ошибки:",GetLastError());
      return;
     }
   if(info)
      draw_info();
//--- Обьявим переменнные для открытия и закрытия ордеров
   bool OpenBuy=Val_CCI[1]<-cci_level && Val_RSI[1]<rsi_level;
   bool OpenSell=Val_CCI[1]>cci_level && Val_RSI[1]>100-rsi_level;

   bool CloseBuy=Val_MA[0]<Val_MA[1] && Val_MA[1]<Val_MA[2];
   bool CloseSell=Val_MA[0]>Val_MA[1] && Val_MA[1]>Val_MA[2];
//--- Открываем первый ордер
   if(start_order && OpenBuy  &&  OrdersBuy()==0)
      m_Trade.Buy(start_lot,my_symbol,Bid(),0,0,"Buy");
   if(start_order && OpenSell && OrdersSell()==0)
      m_Trade.Sell(start_lot,my_symbol,Ask(),0,0,"Sell");
//--- Открываем сетку Buy
   if(signal)
      OpenBuy=true;
   if(OpenBuy && OrdersBuy()>=1)
     {
      if(minOrderBuy()>Ask()+range*my_point || OrdersBuy()==OrdersSell())
         m_Trade.Buy(NormalizeDouble(maxLotBuy()*multiplier,2),my_symbol,Bid(),0,0,"Buy set");
     }
//--- Открываем сетку Sell
   if(signal)
      OpenSell=true;
   if(OpenSell && OrdersSell()>=1)
     {
      if(maxOrderSell()<Bid()-range*my_point || OrdersBuy()==OrdersSell())
         m_Trade.Sell(NormalizeDouble(maxLotSell()*multiplier,2),my_symbol,Ask(),0,0,"Sell set");
     }
//--- Закрываем ордера Buy
   if(close_buy && ProfitBuy()> tp_in_money)
     {
      if(CloseBuy||use_ma!=true)
        {
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(PositionGetSymbol(i)==my_symbol)
               pos_TIC=PositionGetInteger(POSITION_TICKET);
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                  m_Trade.PositionClose(pos_TIC);
              }
           }

        }
     }
//--- Закрываем ордера Sell
   if(close_sell && ProfitSell()> tp_in_money)
     {
      if(CloseSell||use_ma!=true)
        {
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(PositionGetSymbol(i)==my_symbol)
               pos_TIC=PositionGetInteger(POSITION_TICKET);
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                  m_Trade.PositionClose(pos_TIC);
              }
           }

        }
     }
//--- Закрываем все ордера
   if(close_all && ProfitBuy()+ProfitSell()>tp_in_money)
     {
      if((ProfitBuy()>ProfitSell() && (CloseBuy||use_ma!=true)) ||
         (ProfitBuy()<ProfitSell() && (CloseSell||use_ma!=true)))
        {
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(PositionGetSymbol(i)==my_symbol)
               pos_TIC=PositionGetInteger(POSITION_TICKET);
            m_Trade.PositionClose(pos_TIC);
           }
        }
     }
//////////
  }
//+------------------------------------------------------------------+
//--- цена Ask
double Ask()
  {
   double ask=SymbolInfoDouble(my_symbol,SYMBOL_ASK);
   return(ask);
  }
//--- цена Bid
double Bid()
  {
   double bid=SymbolInfoDouble(my_symbol,SYMBOL_BID);
   return(bid);
  }
//+------------------------------------------------------------------+
//--- количество ордеров BUY
int OrdersBuy()
  {
   int Orders=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==my_symbol)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            Orders++;
        }
   return(Orders);
  }
//--- количество ордеров SELL
int OrdersSell()
  {
   int Orders=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==my_symbol)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            Orders++;
        }
   return(Orders);
  }
//+------------------------------------------------------------------+
//--- максимальный лот BUY
double maxLotBuy()
  {
   double lotik=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==my_symbol)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            if(lotik<PositionGetDouble(POSITION_VOLUME))
               lotik=PositionGetDouble(POSITION_VOLUME);
           }
        }
   return(lotik);
  }
//--- максимальный лот SELL
double maxLotSell()
  {
   double lotik=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==my_symbol)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            if(lotik<PositionGetDouble(POSITION_VOLUME))
               lotik=PositionGetDouble(POSITION_VOLUME);
           }
        }
   return(lotik);
  }
//+------------------------------------------------------------------+
//--- минимальный ордер BUY
double minOrderBuy()
  {
   double minOrder=99999999;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==my_symbol)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            if(minOrder>PositionGetDouble(POSITION_PRICE_OPEN))
               minOrder=PositionGetDouble(POSITION_PRICE_OPEN);
           }
        }
   return(minOrder);
  }
//--- максимальный ордер SELL
double maxOrderSell()
  {
   double maxOrder=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==my_symbol)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            if(maxOrder<PositionGetDouble(POSITION_PRICE_OPEN))
               maxOrder=PositionGetDouble(POSITION_PRICE_OPEN);
           }
        }
   return(maxOrder);
  }
//+------------------------------------------------------------------+
//--- профит ордеров BUY
double   ProfitBuy()
  {
   double Prof=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==my_symbol)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            Prof+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
           }
        }
   return(Prof);
  }
//--- профит ордеров SELL
double   ProfitSell()
  {
   double Prof=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==my_symbol)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            Prof+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
           }
        }
   return(Prof);
  }
//+------------------------------------------------------------------+
//--- вывод информации
void draw_info()
  {
   string text,text1,text2;
   color col=clrSnow;

   if(ProfitSell()+ProfitBuy()>0)
     {
      text="+"+DoubleToString(ProfitSell()+ProfitBuy(),2);
      col=clrLimeGreen;
     }
   if(ProfitSell()+ProfitBuy()<0)
     {
      text=DoubleToString(ProfitSell()+ProfitBuy(),2);
      col=clrOrangeRed;
     }
   if(ProfitSell()+ProfitBuy()==0)
     {
      text=" ";
      col=clrLimeGreen;
     }
   if(OrdersBuy()+OrdersSell()>0)
      text1="Buy "+DoubleToString(OrdersBuy(),0)+"  Sell "+DoubleToString(OrdersSell(),0);
   else
      text1="Нет ордеров";
   text2="Всего "+DoubleToString(PositionsTotal(),0);

   ObjectDelete(0,"pr");
   ObjectCreate(0,"pr",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"pr",OBJPROP_XDISTANCE,100);
   ObjectSetInteger(0,"pr",OBJPROP_YDISTANCE,60);
   ObjectSetInteger(0,"pr",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetString(0,"pr",OBJPROP_TEXT,text);
   ObjectSetString(0,"pr",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"pr",OBJPROP_FONTSIZE,12);
   ObjectSetInteger(0,"pr",OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,"pr",OBJPROP_COLOR,col);

   ObjectDelete(0,"or");
   ObjectCreate(0,"or",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"or",OBJPROP_XDISTANCE,110);
   ObjectSetInteger(0,"or",OBJPROP_YDISTANCE,42);
   ObjectSetInteger(0,"or",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetString(0,"or",OBJPROP_TEXT,text1);
   ObjectSetString(0,"or",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"or",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"or",OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,"or",OBJPROP_COLOR,clrLimeGreen);

   ObjectDelete(0,"to");
   ObjectCreate(0,"to",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"to",OBJPROP_XDISTANCE,100);
   ObjectSetInteger(0,"to",OBJPROP_YDISTANCE,24);
   ObjectSetInteger(0,"to",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetString(0,"to",OBJPROP_TEXT,text2);
   ObjectSetString(0,"to",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"to",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"to",OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,"to",OBJPROP_COLOR,clrIvory);
  }
//+------------------------------------------------------------------+
