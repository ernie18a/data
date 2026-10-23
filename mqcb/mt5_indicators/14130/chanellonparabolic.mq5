//+------------------------------------------------------------------+
//|                                               ChanellOnParabolic |
//|                                      Copyright © 2009, Svinozavr |
//|                                                                  |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2009, Svinozavr"
//---- ссылка на сайт автора
#property link      ""
//---- номер версии индикатора
#property version   "1.01"
#property description "Канал, построенный на параболлике"
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано 3 буфера
#property indicator_buffers 3
//---- использовано всего три графических построения
#property indicator_plots   3
//---- в качестве индикатора использован значек
#property indicator_type1   DRAW_ARROW
//---- отображение метки индикатора
#property indicator_label1  " Parabolic Sar"
//---- в качестве цвета индикатора использован
#property indicator_color1 clrDodgerBlue
//---- толщина индикатора равна 1
#property indicator_width1  1
//---- в качестве индикатора использована линия
#property indicator_type2   DRAW_LINE
//---- отображение метки индикатора
#property indicator_label2  "Chanell On Parabolic Upper"
//---- в качестве цветов линии индикатора использован
#property indicator_color2 clrRed
//---- линия индикатора - сплошная
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//---- в качестве индикатора использована линия
#property indicator_type3   DRAW_LINE
//---- отображение метки индикатора
#property indicator_label3  "Chanell On Parabolic Lower"
//---- в качестве цветов линии индикатора использован
#property indicator_color3 clrMediumSeaGreen
//---- линия индикатора - сплошная
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//+----------------------------------------------+ 
//| Объявление констант                          |
//+----------------------------------------------+ 
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input double Step=0.02; //SAR шаг
input double Maximum=0.2; //SAR максимум
input int Wide=0; // Минимально допустимая ширина канала в пунктах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double LowestBuffer[];
double HighestBuffer[];
double SarBuffer[];
//----
double wide;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int SAR_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=1;
   wide=Wide*_Point;
//---- получение хендла индикатора SAR
   SAR_Handle=iSAR(NULL,0,Step,Maximum);
   if(SAR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора SAR");
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,SarBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,HighestBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(SarBuffer,true);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"Chanell On Parabolic Sar(",DoubleToString(Step,2),", ",DoubleToString(Maximum,2),", ",Wide,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(SAR_Handle)<rates_total || rates_total<min_rates_total)return(RESET);
//---- объявления локальных переменных 
   int limit,to_copy,bar;
   double middleprice0,middleprice1,top,bot;
   static double prev_top,prev_bot;
//---- расчет стартового номера limit для цикла пересчета баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчета всех баров
      to_copy=limit+2;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
      to_copy=limit+1;
     }
//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- восстанавливаем значения переменных
   top=prev_top;
   bot=prev_bot;
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(SAR_Handle,0,0,to_copy,SarBuffer)<=0) return(RESET);
//---- первый большой цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      middleprice0=(high[bar]+low[bar])/2; // средняя цена на текущем баре
      middleprice1=(high[bar+1]+low[bar+1])/2; // средняя цена на предыдущем баре
      //----
      if(SarBuffer[bar+1]>=middleprice1 && SarBuffer[bar]<middleprice0) // переворот вверх
         if(top-SarBuffer[bar]>wide) bot=SarBuffer[bar];
      //----
      if(SarBuffer[bar+1]<=middleprice1 && SarBuffer[bar]>middleprice0) // переворот вниз
         if(SarBuffer[bar]-bot>wide) top=SarBuffer[bar];
      //----
      HighestBuffer[bar]=top;
      LowestBuffer[bar]=bot;
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(bar)
        {
         prev_top=top;
         prev_bot=bot;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
