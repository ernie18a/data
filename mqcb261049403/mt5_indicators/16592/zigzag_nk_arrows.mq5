//+------------------------------------------------------------------+
//|                                             ZigZag_NK_Arrows.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
/*                                                                   |
//Version: Final, November 01, 2008                                  |
Editing:   Nikolay Kositsin  farria@mail.redcom.ru                   |
//+------------------------------------------------------------------+ 
Этот вариант индикатора ZigZag, в отличие от оригинала, на каждом тике 
пересчитывается  только на  ещё  непосчитанных барах и поэтому  совсем 
не грузит компьютер.  Помимо этого в данном индикаторе отрисовка линии
происходит в стиле фрактальных значков, и поэтому  индикатор корректно 
изображает одновременно две своих верщины(Хай и Лоу) на одном и том же 
баре!
//----- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
Depth - это  минимальное кол-во  баров, на котором  не  будет  второго 
максимума  (минимума)  меньше  (больше)  на  Deviation  пипсов,    чем 
предыдущего, то  есть  расходиться  ZigZag  может  всегда,  а сходится 
(либо сдвинуться  целиком) больше,  чем  на  Deviation,  ZigZag  может 
только после Depth  баров. Backstep - это минимальное количество баров 
между максимумами (минимумами).
//----- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
Индикатор  Зигзаг  —  ряд линий тренда, которые соединяют существенные
вершины   и   основания  на  ценовом  графике.  Параметр  минимального
изменения  цен определяет процент, на который цена должна переместить,
чтобы  сформировать  новую  "Зиг"  или  "Заг"  линию.  Этот  индикатор
отсеивает  изменения на анализируемом графике, величина которых меньше
заданной.   Таким   образом,   зигзаг   отражает  только  существенные
изменения.  Зигзаг  используется,  главным  образом,  для облегченного
восприятия  графиков,  так  как он показывает только наиболее значимые
изменения  и  развороты.  Также  с  его  помощью  можно выявлять Волны
Эллиота  и  различные  фигуры на графике. Важно усвоить, что последний
отрезок   индикатора   может   меняться  в  зависимости  от  изменений
анализируемых  данных.  Это  один  из немногих индикаторов, у которого
изменение  цены  бумаги  может вызвать изменение предыдущего значения.
Подобная  способность  корректировки  своих  значений  по  последующим
изменениям  цены делает Зигзаг прекрасным инструментом для анализа уже
произошедших  ценовых  изменений.  Поэтому не следует пытаться создать
торговую  систему  на  основе  Зигзага:  он лучше подходит для анализа
исторических данных, чем для прогнозирования.
 Copyright © 2005, MetaQuotes Software Corp.
 */
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.00"
#property description "ZigZag"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано 2 буфера
#property indicator_buffers 2
//---- использовано всего 2 графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//---- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//---- отображение бычей метки индикатора
#property indicator_label1  "Up ZigZag_NK_Arrows"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Down ZigZag_NK_Arrows"
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input uint ExtDepth=12;
input uint ExtDeviation=5;
input uint ExtBackstep =3;
input uint  UpLable=164;//лейба верхнего фрактала
input uint  DnLable=164;//лейба нижнего фрактала
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double HighestBuffer[];
double LowestBuffer[];

//---- Объявление переменных памяти для пересчёта индикатора только на непосчитанных барах
int LASTlowpos,LASThighpos;
double LASTlow0,LASTlow1,LASThigh0,LASThigh1,dExtDeviation;

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(ExtDepth+ExtBackstep);
   dExtDeviation=ExtDeviation*_Point;

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- символы для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,DnLable);
   PlotIndexSetInteger(1,PLOT_ARROW,UpLable);
//---- создание меток для отображения в Окне данных
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag Lowest");
   PlotIndexSetString(1,PLOT_LABEL,"ZigZag Highest");
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"ZigZag (ExtDepth=",
              ExtDepth,"ExtDeviation = ",ExtDeviation,"ExtBackstep = ",ExtBackstep,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,bar,back,lasthighpos,lastlowpos;
   double curlow,curhigh,lasthigh0=NULL,lastlow0=NULL,lasthigh1,lastlow1,val,res;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      lastlow1=-1;
      lasthigh1=-1;
      lastlowpos=-1;
      lasthighpos=-1;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

      //---- восстанавливаем значения переменных
      lastlow0=LASTlow0;
      lasthigh0=LASThigh0;
      lastlow1=LASTlow1;
      lasthigh1=LASThigh1;     
      lastlowpos=LASTlowpos+limit;
      lasthighpos=LASThighpos+limit;
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         LASTlow0=lastlow0;
         LASThigh0=lasthigh0;
        }

      //--- low
      val=low[ArrayMinimum(low,bar,ExtDepth)];
      if(val==lastlow0) val=NULL;
      else 
        { 
         lastlow0=val; 
         if(low[bar]-val>ExtDeviation*_Point) val=NULL;
         else
           {
            for(back=1; back<=int(ExtBackstep); back++)
              {
               res=LowestBuffer[bar+back];
               if(res && res>val ) LowestBuffer[bar+back]=NULL; 
              }
           }
        } 
      LowestBuffer[bar]=val;
      
      //--- high
      val=high[ArrayMaximum(high,bar,ExtDepth)];
      if(val==lasthigh0) val=NULL;
      else 
        {
         lasthigh0=val;
         if(val-high[bar]>ExtDeviation*_Point) val=NULL;
         else
           {
            for(back=1; back<=int(ExtBackstep); back++)
              {
               res=HighestBuffer[bar+back];
               if(res && res<val) HighestBuffer[bar+back]=NULL; 
              } 
           }
        }
      HighestBuffer[bar]=val;
      
     }

//---- Второй большой цикл расчёта индикатора
   for(bar=limit; bar>=0; bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && !bar)
        {
         LASTlow1=lastlow1;
         LASThigh1=lasthigh1;  
         LASTlowpos=lastlowpos;
         LASThighpos=lasthighpos;
        }

      curlow=LowestBuffer[bar];
      curhigh=HighestBuffer[bar];
      //---
      if(!curlow && !curhigh) continue;
      //---
      if(curhigh)
        {
         if(lasthigh1>0) 
           {
            if(lasthigh1<curhigh) HighestBuffer[lasthighpos]=NULL;
            else HighestBuffer[bar]=NULL;
           }
         //---
         if(lasthigh1<curhigh || lasthigh1<0)
           {
            lasthigh1=curhigh;
            lasthighpos=bar;
           }
         lastlow1=-1;
        }
      //----
      if(curlow)
        {
         if(lastlow1>0)
           {
            if(lastlow1>curlow) LowestBuffer[lastlowpos]=NULL;
            else LowestBuffer[bar]=NULL;
           }
         //---
         if(curlow<lastlow1 || lastlow1<0)
           {
            lastlow1=curlow;
            lastlowpos=bar;
           } 
         lasthigh1=-1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
