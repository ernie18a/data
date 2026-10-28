//+------------------------------------------------------------------+
//|                                        ZigZag_NK_Color_Price.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
/*                                                                   |
//Version: Final, November 01, 2008                                  |
Editing:   Nikolay Kositsin  farria@mail.redcom.ru                   |
//----- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+ 
Этот вариант индикатора ZigZag, в отличие от оригинала, на каждом тике 
пересчитывается  только на  ещё  непосчитанных барах и поэтому  совсем 
не грузит компьютер.  Помимо этого в данном индикаторе отрисовка линии
происходит именно в стиле ZIGZAG,    и  поэтому  индикатор   корректно 
изображает одновременно две своих верщины(Хай и Лоу) на одном и том же 
баре!
Николай Косицин
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
 */
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.10"
#property description "ZigZag" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано 2 буфера
#property indicator_buffers 3
//---- использовано всего 2 графических построения
#property indicator_plots   1
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использован ZIGZAG
#property indicator_type1   DRAW_COLOR_ZIGZAG
//---- отображение метки индикатора
#property indicator_label1  "ZigZag"
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrMagenta,clrBlueViolet
//---- линия индикатора - длинный пунктир
#property indicator_style1  STYLE_DASH
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input string  SirName="ZigZag_NK_Color_Price";//Первая часть имени графических объектов
input int ExtDepth=12;
input int ExtDeviation=5;
input int ExtBackstep=3;
input bool ShowPrice=true;
input uint nSize=1;
input color UpColor=clrTeal;
input color DnColor=clrRed;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double LowestBuffer[];
double HighestBuffer[];
double ColorBuffer[];

//---- Объявление переменных памяти для пересчёта индикатора только на непосчитанных барах
int LASTlowpos,LASThighpos,LASTColor;
double LASTlow0,LASTlow1,LASThigh0,LASThigh1;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
string UpLable_,DnLable_;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=ExtDepth+ExtBackstep;
   UpLable_=SirName+"_Up_";
   DnLable_=SirName+"_Dn_";

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- создание меток для отображения в Окне данных
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag_NK_Color");
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);
//---- установка позиции, с которой начинается отрисовка индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"ZigZag_NK_Color(ExtDepth=",ExtDepth,"ExtDeviation = ",ExtDeviation,"ExtBackstep = ",ExtBackstep,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,SirName,0,OBJ_ARROW_RIGHT_PRICE);
//----
   ChartRedraw(0);
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
   int limit,climit,bar,back,lasthighpos,lastlowpos;
   double curlow,curhigh,lasthigh0=NULL,lastlow0=NULL,lasthigh1,lastlow1,val,res;
   bool Max,Min;
   string stime;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      climit=limit; // стартовый номер для раскраски индикатора

      lastlow1=-1;
      lasthigh1=-1;
      lastlowpos=-1;
      lasthighpos=-1;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      climit=limit+min_rates_total; // стартовый номер для раскраски индикатора

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
   ArraySetAsSeries(time,true);

//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && !bar)
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
            for(back=1; back<=ExtBackstep; back++)
              {
               res=LowestBuffer[bar+back];
               if(res && res>val)
                 {
                  LowestBuffer[bar+back]=NULL;
                  stime=TimeToString(time[bar+back],TIME_DATE|TIME_MINUTES);
                  ObjectDelete(0,DnLable_+stime);
                 }
              }
           }
        }
      LowestBuffer[bar]=val;
      if(val)
        {
         stime=TimeToString(time[bar],TIME_DATE|TIME_MINUTES);
         CreateArrowRightPrice(0,DnLable_+stime,0,time[bar],val,DnColor,nSize);
        }

      //--- high
      val=high[ArrayMaximum(high,bar,ExtDepth)];
      if(val==lasthigh0) val=NULL;
      else
        {
         lasthigh0=val;
         if(val-high[bar]>ExtDeviation*_Point) val=NULL;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=HighestBuffer[bar+back];
               if(res && res<val)
                 {
                  HighestBuffer[bar+back]=NULL;
                  stime=TimeToString(time[bar+back],TIME_DATE|TIME_MINUTES);
                  ObjectDelete(0,UpLable_+stime);
                 }
              }
           }
        }
      HighestBuffer[bar]=val;
      if(val)
        {
         stime=TimeToString(time[bar],TIME_DATE|TIME_MINUTES);
         CreateArrowRightPrice(0,UpLable_+stime,0,time[bar],val,UpColor,nSize);
        }
     }

//---- Второй большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && !bar)
        {
         LASTlow1=lastlow1;
         LASThigh1=lasthigh1;
         //----
         LASTlowpos=lastlowpos;
         LASThighpos=lasthighpos;
        }

      curlow=LowestBuffer[bar];
      curhigh=HighestBuffer[bar];
      //---
      if(!curlow && !curhigh)continue;
      //---
      if(curhigh)
        {
         if(lasthigh1>0)
           {
            if(lasthigh1<curhigh)
              {
               HighestBuffer[lasthighpos]=NULL;
               stime=TimeToString(time[lasthighpos],TIME_DATE|TIME_MINUTES);
               ObjectDelete(0,UpLable_+stime);
              }
            else
              {
               HighestBuffer[bar]=NULL;
               stime=TimeToString(time[bar],TIME_DATE|TIME_MINUTES);
               ObjectDelete(0,UpLable_+stime);
              }
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
            if(lastlow1>curlow)
              {
               LowestBuffer[lastlowpos]=NULL;
               stime=TimeToString(time[lastlowpos],TIME_DATE|TIME_MINUTES);
               ObjectDelete(0,DnLable_+stime);
              }
            else
              {
               LowestBuffer[bar]=NULL;
               stime=TimeToString(time[bar],TIME_DATE|TIME_MINUTES);
               ObjectDelete(0,DnLable_+stime);
              }
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

//---- Третий большой цикл раскраски индикатора
   for(bar=climit; bar>=0 && !IsStopped(); bar--)
     {
      Max=HighestBuffer[bar];
      Min=LowestBuffer[bar];

      if(!Max && !Min) ColorBuffer[bar]=ColorBuffer[bar+1];
      if(Max && Min)
        {
         if(ColorBuffer[bar+1]==0) ColorBuffer[bar]=1;
         else                      ColorBuffer[bar]=0;
        }

      if( Max && !Min) ColorBuffer[bar]=1;
      if(!Max &&  Min) ColorBuffer[bar]=0;
     }
//---- 
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание текстовой лейбы                                        |
//+------------------------------------------------------------------+
void CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
(
 long   chart_id,         // идентификатор графика
 string name,             // имя объекта
 int    nwin,             // индекс окна
 datetime Time,           // положение ценовой метки по времени
 double Price,            // положение ценовой метки по вертикали
 color  Color,            // цвет текста
 uint    Size             // размер шрифта
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,Size);
//ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
