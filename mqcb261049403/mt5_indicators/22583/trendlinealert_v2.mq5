//+------------------------------------------------------------------+
//|                                            TrendLineAlert_V2.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
 /*
  Индикатор отображает наклонную трендовую линию, с помощью которой задается уровень срабатывания сигнала. 
  При первом запуске индикатора линия, задающая уровень срабатывания, окрашена в серый цвет и неактивна. 
  При изменении положения линии на графике трейдером она становится активной и меняет цвет на красный.
  Как только цена дойдет до линии срабатывания и коснется ее или зайдет за границу линии, индикатор сразу начнет подавать алерты или звуковые сигналы. 
  На каждом тике в момент захода цены за линию индикатор будет подавать по сигналу до тех пор, пока не исчерпает лимит сигналов,
  определяемый в настройках индикатора внешней переменной AlertTotal (количество сигналов).
  После этого линия срабатывания окрасится в серый цвет и станет неактитвной до ее следущего перемещения на требуемые уровни трейдером.
*/
//---- авторство индикатора
#property copyright "Copyright © 2018, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.00"
#property description "Индикатор подаёт сигналы  и отправляет push-сообщения на смартфон при пробое трендовой линии, параметры которой устанавливаются при старте индикатера трейдером"
#property indicator_buffers 0
#property indicator_plots   0
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
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
input string level_name="Trend_Level_1";                            //имя уровня срабатывания
input string level_comment="трендовый уровень срабатывания";        //комментарий к уровню срабатывания
input color active_level_color=clrRed;                              //цвет активированного уровня
input color inactive_level_color=clrGray;                           //цвет сработавшего уровня
input ENUM_LINE_STYLE level_style=STYLE_SOLID;                      //стиль уровня срабатывания
input ENUM_WIDTH level_width=w_3;                                   //толщина уровня срабатывания
input bool AlertON=true;                                            //Разрешение подачи алерта
input uint AlertTotal=3;                                            //количество сигналов
input bool EMailON=false;                                           //Разрешение почтовой отправки сигнала
input bool PushON=false;                                            //Разрешение отправки сигнала на мобильный
input bool Deletelevel=true;                                        //удаление настройки уровня при смене таймфрейма 
//+----------------------------------------------+

//+------------------------------------------------------------------+
//|  Создание трендовой линии                                        |
//+------------------------------------------------------------------+
void CreateTline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1 ценового уровня
 double   price1,        // 1 ценовой уровень
 datetime time2,         // время 2 ценового уровня
 double   price2,        // 2 ценовой уровень
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка трендовой линии                                   |
//+------------------------------------------------------------------+
void SetTline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1 ценового уровня
 double   price1,        // 1 ценовой уровень
 datetime time2,         // время 2 ценового уровня
 double   price2,        // 2 ценовой уровень
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Проверка трендовой линии на перемещение                         |
//+------------------------------------------------------------------+
bool TlineMoveCheck
(
 long      chart_id,      // идентификатор графика
 string    name,          // имя объекта
 int       nwin,          // индекс окна
 datetime& time1,         // время 1 ценового уровня
 double&   price1,        // 1 ценовой уровень
 datetime& time2,         // время 2 ценового уровня
 double&   price2         // 2 ценовой уровень
 )
//---- 
  {
//----
   static double price1_=0,price2_=0;
   static datetime time1_=0,time2_=0;
//----
   if(ObjectFind(chart_id,name)!=-1)
     {
      time1=datetime(ObjectGetInteger(chart_id,name,OBJPROP_TIME,0));
      time2=datetime(ObjectGetInteger(chart_id,name,OBJPROP_TIME,1));
      price1=ObjectGetDouble(chart_id,name,OBJPROP_PRICE,0);
      price2=ObjectGetDouble(chart_id,name,OBJPROP_PRICE,1);

      if(time1!=time1_ || time2!=time2_ || price1!=price1_ || price2!=price2_)
        {
         time1_=time1;
         time2_=time2;
         price1_=price1;
         price2_=price2;
         return(true);
        }
     }
//----
   return(false);
  }
//+------------------------------------------------------------------+
//|  Поиск бара по времени открытия                                  |
//+------------------------------------------------------------------+
int FindBar
(
 int endtbar,//стартовый бар (самый новый)
 int startbar,//конечный бар (самый старый)
 datetime bartime,// время бара
 const datetime &time[]// таймсерия time[]
 )
//---- 
  {
//----
   for(int bar=startbar; bar>=endtbar; bar--) if(time[bar]<=bartime) return(bar);
//----
   return(endtbar);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- создаём уровень, если он отсутствует
   if(ObjectFind(0,level_name)==-1) SetTline(0,level_name,0,0,0,0,0,inactive_level_color,level_style,level_width,level_comment);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---- удаляем уровень, если это необходимо
   if(Deletelevel) ObjectDelete(0,level_name);
//----
   ChartRedraw(NULL); 
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<20) return(0);

//---- объявления локальных переменных 
   double level,price0;
   int bar0;
   static double price2,price1,K;
   static datetime time1,time2;
   static uint count;
   static int bar1,bar2,dbar,startpos;

//---- восстановление уровня в случае его исчезновения
   if(ObjectFind(0,level_name)==-1)
     {
      if(count) SetTline(0,level_name,0,time1,price1,time2,price2,active_level_color,level_style,level_width,level_comment);
      else SetTline(0,level_name,0,time1,price1,time2,price2,inactive_level_color,level_style,level_width,level_comment);
     }

   bar0=rates_total-1;
   price0=close[bar0];

//---- установка уровня в неактивную, стартовую позицию
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      TlineMoveCheck(0,level_name,0,time1,price1,time2,price2);

      if(!price1 || !price2 || !time1 || !time2)
        {
         bar1=rates_total-20;
         bar2=rates_total-1;
         time1=time[bar1];
         time2=time[bar2];
         price1=close[bar1];
         price2=close[bar2];
         SetTline(0,level_name,0,time1,price1,time2,price2,inactive_level_color,level_style,level_width,level_comment);
         TlineMoveCheck(0,level_name,0,time1,price1,time2,price2);
         count=0;
        }
     }

//---- проверка уровня на перемещение и его активизация 
   if(TlineMoveCheck(0,level_name,0,time1,price1,time2,price2))
     {
      bar1=FindBar(0,bar0,time1,time);
      time1=time[bar1];

      bar2=FindBar(0,bar0,time2,time);
      time2=time[bar2];

      SetTline(0,level_name,0,time1,price1,time2,price2,active_level_color,level_style,level_width,level_comment);
      count=AlertTotal;

      dbar=bar2-bar1;
      if(!dbar) dbar=1;
      K=(price2-price1)/dbar;

      level=K*(bar0-bar1)+price1;
      if(price0>level) startpos=+1;
      else             startpos=-1;
     }

//---- вычисление текущего значения трендового, наклонного уровня срабатывания
   level=K*(bar0-bar1)+price1;

//---- подача алерта и отправка сообщений
   if(count) if(price0>=level && startpos<0)
        {
         BuySignal("TrendLineAlert_V2: Произошёл пробой трендовой линии на уровне "+DoubleToString(level,_Digits),rates_total,prev_calculated,close,spread);
         count--;
         if(!count) SetTline(0,level_name,0,time1,price1,time2,price2,inactive_level_color,level_style,level_width,level_comment);
        }

//---- подача алерта и отправка сообщений
   if(count) if(price0<=level && startpos>0)
        {
         SellSignal("TrendLineAlert_V2: Произошёл пробой трендовой линии на уровне "+DoubleToString(level,_Digits),rates_total,prev_calculated,close,spread);
         count--;
         if(!count) SetTline(0,level_name,0,time1,price1,time2,price2,inactive_level_color,level_style,level_width,level_comment);
        }
//----  
   ChartRedraw(NULL); 
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
