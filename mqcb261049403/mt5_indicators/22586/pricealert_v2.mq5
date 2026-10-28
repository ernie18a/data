//+------------------------------------------------------------------+
//|                                                PriceAlert_V2.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2018, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.10"
#property description "Индикатор подает сигналы при пробое горизонтального уровня"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//--- количество индикаторных буферов
#property indicator_buffers 0
//--- использовано всего графических построений
#property indicator_plots   0
//+------------------------------------------------+ 
//| Перечисление для толщины уровня                |
//+------------------------------------------------+ 
enum ENUM_WIDTH //Тип константы
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+------------------------------------------------+
//| Входные параметры индикатора                   |
//+------------------------------------------------+
input string level_name="Price_Level_1";           // Имя уровня срабатывания
input string level_comment="уровень срабатывания"; // Комментарий к уровню срабатывания
input color active_level_color=Red;                // Цвет активированного уровня
input color inactive_level_color=Gray;             // Цвет сработавшего уровня
input ENUM_LINE_STYLE level_style=STYLE_SOLID;     // Стиль уровня срабатывания
input ENUM_WIDTH level_width=w_3;                  // Толщина уровня срабатывания
input bool AlertON=true;                           // Разрешение подачи алерта
input uint AlertTotal=3;                           // количество сигналов
input bool EMailON=false;                          // Разрешение почтовой отправки сигнала
input bool PushON=false;                           // Разрешение отправки сигнала на мобильный
input bool Deletelevel=true;                       // удаление настройки уровня при смене таймфрейма 
//+----------------------------------------------+

//+------------------------------------------------------------------+
//|  Создание горизонтальной линии                                   |
//+------------------------------------------------------------------+
void CreateHline(long     chart_id,      // идентификатор графика
                 string   name,          // имя объекта
                 int      nwin,          // индекс окна
                 double   price,         // цена горизонтального уровня
                 color    Color,         // цвет линии
                 int      style,         // стиль линии
                 int      width,         // толщина линии
                 bool     background,    // фоновое отображение линии
                 string   text)          // текст
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,nwin,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка горизонтальной линии                              |
//+------------------------------------------------------------------+
void SetHline(long     chart_id,      // идентификатор графика
              string   name,          // имя объекта
              int      nwin,          // индекс окна
              double   price,         // цена горизонтального уровня
              color    Color,         // цвет линии
              int      style,         // стиль линии
              int      width,         // толщина линии
              bool     background,    // фоновое отображение линии
              string   text)          // текст
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   if(ObjectFind(0,level_name)==-1) CreateHline(0,level_name,0,0,inactive_level_color,level_style,level_width,false,level_comment);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   if(Deletelevel) ObjectDelete(0,level_name);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- объявления локальных переменных 
   double level,price0=close[rates_total-1];
   static double startprice,oldlevel;
   static uint count;

   if(ObjectFind(0,level_name)==-1)
     {
      if(count) CreateHline(0,level_name,0,oldlevel,active_level_color,level_style,level_width,false,level_comment);
      else CreateHline(0,level_name,0,oldlevel,inactive_level_color,level_style,level_width,false,level_comment);
     }

   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      level=ObjectGetDouble(0,level_name,OBJPROP_PRICE);
      if(!level)
        {
         level=price0;
         SetHline(0,level_name,0,level,inactive_level_color,level_style,level_width,false,level_comment);
         oldlevel=level;
         count=0;
        }
     }

   level=ObjectGetDouble(0,level_name,OBJPROP_PRICE);

   if(level!=oldlevel)
     {
      SetHline(0,level_name,0,level,active_level_color,level_style,level_width,false,level_comment);
      oldlevel=level;
      count=AlertTotal;
      startprice=price0;
     }
        
//---- подача алерта и отправка сообщений
   if(count) if(price0>=level && startprice<level)
        {
         BuySignal("PriceAlert_V2: Произошел пробой ценового уровня "+DoubleToString(level,_Digits),rates_total,prev_calculated,close,spread);
         count--;
         if(!count) SetHline(0,level_name,0,level,inactive_level_color,level_style,level_width,false,level_comment);
        }

//---- подача алерта и отправка сообщений
   if(count) if(price0<=level && startprice>level)
        {
         SellSignal("PriceAlert_V2: Произошел пробой ценового уровня "+DoubleToString(level,_Digits),rates_total,prev_calculated,close,spread);
         count--;
         if(!count) SetHline(0,level_name,0,level,inactive_level_color,level_style,level_width,false,level_comment);
        }

//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;
   bool BuySignal=true;
   bool SeriesTest=ArrayGetAsSeries(Close);
   int index;
   if(SeriesTest) index=0;
   else index=Rates_total-1;
   if(BuySignal && counter<=AlertTotal)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      double Ask=Close[index];
      double Bid=Close[index];
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(AlertON)
        {
         Alert(SignalSirname);
         Alert("BUY signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
        }
      if(EMailON)
        {
         SendMail(SignalSirname+": BUY signal alert","BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
        }
      if(PushON)
        {
         SendNotification(SignalSirname);
         SendNotification("BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
        }
     }

//---
  }
//+------------------------------------------------------------------+
//| Sell signal function                                             |
//+------------------------------------------------------------------+
void SellSignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=true;
   bool SeriesTest=ArrayGetAsSeries(Close);
   int index;
   if(SeriesTest) index=0;
   else index=Rates_total-1;
   if(SellSignal && counter<=AlertTotal)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      double Ask=Close[index];
      double Bid=Close[index];
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(AlertON)
        {
         Alert(SignalSirname);
         Alert("SELL signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
        }
      if(EMailON)
        {
         SendMail(SignalSirname+": SELL signal alert","SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
        }
      if(PushON)
        {
         SendNotification(SignalSirname);
         SendNotification("SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+