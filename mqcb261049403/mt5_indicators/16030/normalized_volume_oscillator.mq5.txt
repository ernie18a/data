//+------------------------------------------------------------------+
//|                                 Normalized_Volume_Oscillator.mq5 |
//|                                Copyright © 2008, Vadim Shumiloff |
//|                                                shumiloff@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Vadim Shumiloff"
#property link "shumiloff@mail.ru"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трехцветной гистограммы использованы
#property indicator_color1  clrGray,clrBlue,clrPurple,clrRed,clrYellow
//---- гистограммы индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Normalized_Volume_Oscillator"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint VolumePeriod=10;
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём 
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
//---- Объявление целых переменных начала отсчета данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| Bears indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   min_rates_total=int(VolumePeriod);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Normalized_Volume_Oscillator(",VolumePeriod,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 5  
   IndicatorSetInteger(INDICATOR_LEVELS,4);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,38.2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,61.8);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,100.0);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrTeal);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrRed);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrOrange);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Bears iteration function                                         | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double nvo;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar,clr;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=min_rates_total; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- Основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++) IndBuffer[bar]=NormalizedVolume(VolumeType,tick_volume,volume,bar)*100-100;

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      nvo=IndBuffer[bar];
      if(nvo<0)
        {
         clr=0;
        }
      else
        {
         if(nvo<38.2)
           {
            clr=1;
           }
         else
           {
            if(nvo<61.8)
              {
               clr=2;
              }
            else
              {
               if(nvo<100)
                 {
                  clr=3;
                 }
               else clr=4;
              }
           }
        }
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizedVolume(ENUM_APPLIED_VOLUME type,
                        const long &Tick_Volume[],
                        const long &Volume[],
                        int index)
  {
//----
   double nv=0.0,vol;
   if(type==VOLUME_TICK)
     {
      for(int kkk=0; kkk<int(VolumePeriod); kkk++) nv+=double(Tick_Volume[index-kkk]);
      nv=nv/VolumePeriod;
      vol=Tick_Volume[index]/nv;
     }
   else
     {
      for(int kkk=0; kkk<int(VolumePeriod); kkk++) nv+=double(Volume[index-kkk]);
      nv=nv/VolumePeriod;
      vol=Volume[index]/nv;
     }
//----
   return(vol);
  }
//+------------------------------------------------------------------+
