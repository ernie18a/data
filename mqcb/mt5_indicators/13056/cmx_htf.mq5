//+------------------------------------------------------------------+ 
//|                                                      CMx_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырехцветной гистограммы использованы
#property indicator_color1 clrRed,clrMediumVioletRed,clrGray,clrBlue,clrDodgerBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width1 5
//---- отображение лэйбы индикатора
#property indicator_label1 "CMx HTF"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Период графика
input int    F=12;
input double k=1.682;
input double L_adx=18;
input int    Shift=0;            // Сдвиг индикатора по горизонтали в барах
input double Level1=+423.6;      // Уровень 1
input double Level2=+261.8;      // Уровень 2
input double Level3=+161.8;      // Уровень 3
input double Level4=+61.8;       // Уровень 4
input double Level5=0.0;         // Уровень 5
input double Level6=-61.8;       // Уровень 6
input double Level7=-161.8;      // Уровень 7
input double Level8=-261.8;      // Уровень 8
input double Level9=-423.6;      // Уровень 9
input bool ReDraw=true;          // Повтор отображения инфомации на пустых барах
//+----------------------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| CMx initialization function                                      | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=3;
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора CMx не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора CMx
   Ind_Handle=iCustom(Symbol(),TimeFrame,"CMx",F,k,L_adx,0,Level1,Level2,Level3,Level4,Level5,Level6,Level7,Level8,Level9);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора CMx");
      return(INIT_FAILED);
     }
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"CMx HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- количество  горизонтальных уровней индикатора 9   
   IndicatorSetInteger(INDICATOR_LEVELS,9);
//--- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Level1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Level2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,Level3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,Level4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,Level5);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,5,Level6);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,6,Level7);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,7,Level8);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,8,Level9);
//--- в качестве цветов линий горизонтальных уровней использованы цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,5,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,6,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,7,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,8,clrBlue);
//--- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,5,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,6,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,7,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,8,STYLE_DASHDOTDOT);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| CMx oscillator function                                          | 
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//---- объявление целочисленных переменных
   int limit,bar;
//---- объявление переменных с плавающей точкой  
   double Ind[2];
   datetime IndTime[1];
   static uint LastCountBar;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчета новых баров 
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчета
      IndBuffer[bar]=EMPTY_VALUE;
      ColorIndBuffer[bar]=2;
      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,IndTime)<=0) return(RESET);
      //---
      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind_Handle,0,time[bar],2,Ind)<=0) return(RESET);
         //---- загрузка полученных значений в индикаторные буферы
         IndBuffer[bar]=Ind[1];
         int clr=2;
         //---
         if(IndBuffer[bar]>0)
           {
            if(Ind[1]>Ind[0]) clr=4;
            if(Ind[1]<Ind[0]) clr=3;
           }
         //---
         if(IndBuffer[bar]<0)
           {
            if(Ind[1]<Ind[0]) clr=0;
            if(Ind[1]>Ind[0]) clr=1;
           }
         ColorIndBuffer[bar]=clr;
        }
      //---
      if(ReDraw && IndBuffer[bar+1]!=EMPTY_VALUE && IndBuffer[bar]==EMPTY_VALUE)
        {
         IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
