//+------------------------------------------------------------------+
//|                                            cm_ind_level_cndl.mq5 |
//|                                Copyright 2014, cmillion@narod.ru |
//|                                               http://cmillion.ru |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2014, cmillion@narod.ru"
//---- ссылка на сайт автора
#property link      "http://cmillion.ru"
//---- номер версии индикатора
#property version   "1.00"
#property description "Индикатор показывает точку разворота цены"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано ноль буферов
#property indicator_buffers 0
//---- использовано всего ноль графических построений
#property indicator_plots   0
//+------------------------------------------------+
//| Входные параметры индикатора                   |
//+------------------------------------------------+
input string level_name="cm_ind_level_cndl"; //первая часть имени графических объектов
input uint Candles=5;                        //сколько свечей зацепила цена
input uint History=50;                       //на каком промежутке ищем
input color buy_level_color=clrLime;         //цвет покупок
input color sell_level_color=clrMagenta;     //цвет продаж
//+----------------------------------------------+
string UP,DN,UP1,DN1;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
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
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,false);
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация стринговых имён  
    UP=DN=UP1=DN1=level_name;
    UP+="UP";
    DN+="DN";
    UP1+="UP1";
    DN1+="DN1";
//---- Инициализация переменных начала отсчёта данных   
    min_rates_total=int(History);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---- удаляем все графические объекты, созданные индикатором
   ObjectsDeleteAll(NULL,level_name,-1,OBJ_TREND); 
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
   if(rates_total<min_rates_total) return(0);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//----
    for(int kkk=0,iii=int(History)-1; iii>=0; iii--)
     {
      double H=high[iii];
      double L=MathMax(open[iii],close[iii]);
      bool YES=true;
      for(kkk=iii; kkk<iii+int(Candles); kkk++)
        {
         if(high[kkk]<L || MathMax(open[kkk],close[kkk])>H)
          {
           YES=false;
           break;
           }
         if(H>high[kkk]) H=high[kkk];
         if(L<MathMax(open[kkk],close[kkk])) L=MathMax(open[kkk],close[kkk]);
        }
      if(YES)
        {     
         SetTline(0,UP,0,time[kkk],H,time[iii],H,buy_level_color,STYLE_SOLID,5,"buy_level");
         SetTline(0,UP1,0,time[kkk],H,time[0],H,buy_level_color,STYLE_SOLID,1,"buy_level");
        }

      H=MathMin(open[iii],close[iii]);
      L=low[iii];
      YES=true;
      for(kkk=iii; kkk<iii+int(Candles); kkk++)
        {
         if(MathMin(open[kkk],close[kkk])<L || low[kkk]>H) {YES=false;break;}
         if(H>MathMin(open[kkk],close[kkk])) H=MathMin(open[kkk],close[kkk]);
         if(L<low[kkk]) L=low[kkk];
        }
      if(YES)
        {
         SetTline(0,DN,0,time[kkk],L,time[iii],L,sell_level_color,STYLE_SOLID,5,"sell_level");
         SetTline(0,DN1,0,time[kkk],L,time[0],L,sell_level_color,STYLE_SOLID,1,"sell_level");
        }
     }
//----   
   ChartRedraw(NULL); 
   return(rates_total);
  }
//+------------------------------------------------------------------+
