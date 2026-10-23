//+------------------------------------------------------------------+
//|                                              Zigzag2_R_Color.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
/* В стандартном индикаторе http://codebase.mql4.com/ru/238 для      |
рисования использовался стиль DRAW_SECTION. Этот стиль позволяет     |
рисовать отрезками только между точками, находящимимся на разных     |
барах. Стиль отрисовки DRAW_ZIGZAG позволяет снять это ограничение,  |
для этого используются два буфера вместо одного. Для иллюстрации     |
этого стиля и был написан Zigzag2_R_.mq5.                            |
В код добавлена обработка внешнего  бара (outside bar), когда  High  |
текущего бара выше предыдущих, а Low текущего бара ниже предыдущих.  |
Блок обработки внешнего бара дан как пример. Вы можете использовать  |
свой алгоритм для такой ситуации.                                    |
//+------------------------------------------------------------------+
*/
//---- авторство индикатора
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.00"
#property description "ZigZag" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано 5 буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использован ZIGZAG
#property indicator_type1   DRAW_COLOR_ZIGZAG
//---- отображение метки индикатора
#property indicator_label1  "ZigZag"
//---- в качестве цвета линии индикатора использованы
#property indicator_color1 clrMediumVioletRed,clrMediumSeaGreen
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input int ExtDepth=12;
input int ExtDeviation=5;
input int ExtBackstep=3;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ZigzagPeakBuffer[],ZigzagLawnBuffer[];
double HighMapBuffer[],LowMapBuffer[];
double ColorBuffer[];
int level=3; // recounting's depth 
bool downloadhistory=false;
double dExtDeviation;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=ExtDepth+ExtBackstep;
   dExtDeviation=ExtDeviation*_Point;

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ZigzagLawnBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ZigzagPeakBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(3,HighMapBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,LowMapBuffer,INDICATOR_CALCULATIONS);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ZigzagLawnBuffer,true);
   ArraySetAsSeries(ZigzagPeakBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);
   ArraySetAsSeries(HighMapBuffer,true);
   ArraySetAsSeries(LowMapBuffer,true);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"Zigzag2_R_(ExtDepth=",
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
   bool Max,Min;
   int limit,climit,bar;  
   int iii=0,counterZ=0,whatlookfor=0;
   int back,lasthighpos,lastlowpos;
   double val,res;
   double curlow=9999999999.0,curhigh=0.0,lasthigh=0.0,lastlow=999999999.0;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      climit=limit; // стартовый номер для раскраски индикатора
      ArrayInitialize(ZigzagPeakBuffer,NULL);
      ArrayInitialize(ZigzagLawnBuffer,NULL);
      ArrayInitialize(HighMapBuffer,NULL);
      ArrayInitialize(LowMapBuffer,NULL);
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      climit=limit+min_rates_total; // стартовый номер для раскраски индикатора

      //----
      while(counterZ<level && iii<100)
        {
         res=(ZigzagPeakBuffer[iii]+ZigzagLawnBuffer[iii]);
         //----
         if(res) counterZ++;
         iii++;
        }
      iii--;
      limit=iii;     
      //----
      if(LowMapBuffer[iii])
        {
         curlow=LowMapBuffer[iii];
         whatlookfor=1;
        }
      else
        {
         curhigh=HighMapBuffer[iii];
         whatlookfor=-1;
        }
      //----
      for(iii=limit-1; iii>=0; iii--)
        {
         ZigzagPeakBuffer[iii] = NULL;
         ZigzagLawnBuffer[iii] = NULL;
         LowMapBuffer[iii]=NULL;
         HighMapBuffer[iii]=NULL;
        }
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      val=low[ArrayMinimum(low,bar,ExtDepth)];
      //----
      if(val==lastlow)
         val=NULL;
      else
        {
         lastlow=val;
         //----
         if(low[bar]-val>dExtDeviation)
            val=NULL;
         else
           {
            //----
            for(back=1; back<=ExtBackstep; back++)
              {
               res=LowMapBuffer[bar+back];
               //----
               if(res && res>val) LowMapBuffer[bar+back]=NULL;
              }
           }
        }
      //----
      if(low[bar]==val)
         LowMapBuffer[bar]=val;
      else
         LowMapBuffer[bar]=NULL;
      //--- high
      val=high[ArrayMaximum(high,bar,ExtDepth)];
      //----
      if(val==lasthigh)
         val=NULL;
      else
        {
         lasthigh=val;
         //----
         if(val-high[bar]>dExtDeviation)
            val=NULL;
         else
           {
            //----
            for(back=1; back<=ExtBackstep; back++)
              {
               res=HighMapBuffer[bar+back];
               //----
               if(res && res<val)  HighMapBuffer[bar+back]=NULL;
              }
           }
        }
      //----
      if(high[bar]==val)
         HighMapBuffer[bar]=val;
      else
         HighMapBuffer[bar]=NULL;
     }
     
//---- final cutting 
   if(!whatlookfor)
     {
      lastlow=NULL;
      lasthigh=NULL;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }

//---- Второй большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      res=NULL;
      switch(whatlookfor)
        {
         // look for peak or lawn 
         case 0: if(!lastlow && !lasthigh)
           {
            if(HighMapBuffer[bar])
              {
               lasthigh=high[bar];
               lasthighpos = bar;
               whatlookfor = -1;
               ZigzagPeakBuffer[bar]=lasthigh;
               res=1;
              }
            if(LowMapBuffer[bar])
              {
               lastlow=low[bar];
               lastlowpos=bar;
               whatlookfor=1;
               ZigzagLawnBuffer[bar]=lastlow;
               res=1;
              }
           }
         break;
         // look for peak
         case 1: if(LowMapBuffer[bar] && LowMapBuffer[bar] < lastlow && !HighMapBuffer[bar])
           {
            ZigzagLawnBuffer[lastlowpos]=NULL;
            lastlowpos=bar;
            lastlow=LowMapBuffer[bar];
            ZigzagLawnBuffer[bar]=lastlow;
            res=1;
           }
         if(HighMapBuffer[bar] && !LowMapBuffer[bar])
           {
            lasthigh=HighMapBuffer[bar];
            lasthighpos=bar;
            ZigzagPeakBuffer[bar]=lasthigh;
            whatlookfor=-1;
            res=1;
           }
         break;
         // look for lawn
         case -1:  if(HighMapBuffer[bar] && HighMapBuffer[bar]>lasthigh && !LowMapBuffer[bar])
           {
            ZigzagPeakBuffer[lasthighpos]=NULL;
            lasthighpos=bar;
            lasthigh=HighMapBuffer[bar];
            ZigzagPeakBuffer[bar]=lasthigh;
           }
         if(LowMapBuffer[bar] && !HighMapBuffer[bar])
           {
            lastlow=LowMapBuffer[bar];
            lastlowpos=bar;
            ZigzagLawnBuffer[bar]=lastlow;
            whatlookfor=1;
           }
         break;
         default: return(rates_total);
        }
     }
//---- Третий большой цикл раскраски индикатора
   for(bar=climit; bar>=0 && !IsStopped(); bar--)
     {
      Max=ZigzagPeakBuffer[bar];
      Min=ZigzagLawnBuffer[bar];
      
      if(!Max && !Min) ColorBuffer[bar]=ColorBuffer[bar+1];
      if( Max &&  Min)
        {
         if(ColorBuffer[bar+1]==0) ColorBuffer[bar]=1;
         else                      ColorBuffer[bar]=0;
        }

      if( Max && !Min) ColorBuffer[bar]=1;
      if(!Max &&  Min) ColorBuffer[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
