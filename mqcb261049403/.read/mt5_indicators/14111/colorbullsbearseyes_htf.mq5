//+------------------------------------------------------------------+ 
//|                                      ColorBullsBearsEyes_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего одно графические построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде пятицветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов трехцветной гистограммы использованы
#property indicator_color1 clrBlue,clrRed,clrLime
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ColorBullsBearsEyes"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum AlgMode
  {
   twist,//изменение направления
   breakdown1,  //пробой средней линии
   breakdown2,  //пробой уровней перезакупа и перепроданности
   breakdown3   //выход из зон перекупленности и перепроданности + пробой уровней перезакупа и перепроданности
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Период графика
input int period=13; // Период усреднения индикатора
input double gamma=0.6; // Коэффициент сглаживания индикатора
input AlgMode Mode=breakdown2; // Алгоритм расчета сигнала входа
input uint HighLevel=75; // Уровень перекупленности
input uint MiddleLevel=50; // Уровень середины
input uint LowLevel=25; // Уровень перепроданности
input int  Shift=0;     // Сдвиг индикатора по горизонтали в барах
input bool ReDraw=true; // Повтор отображения инфомации на пустых барах
//+----------------------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer1[],IndBuffer2[],ColorIndBuffer[];
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=3;
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора ColorBullsBearsEyes не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ColorBullsBearsEyes
   Ind_Handle=iCustom(Symbol(),TimeFrame,"ColorBullsBearsEyes",period,gamma,Mode,HighLevel,MiddleLevel,LowLevel,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorBullsBearsEyes");
      return(INIT_FAILED);
     }
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer1,true);
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(1,IndBuffer2,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer2,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ColorBullsBearsEyes HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 5   
   IndicatorSetInteger(INDICATOR_LEVELS,5);
//---- значения горизонтальных уровней индикатора
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,100);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,LowLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,0);
//---- в качестве цветов линий горизонтальных уровней использованы
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrLimeGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrLimeGreen);
//---- в линии горизонтального уровня использован короткий штрих-пунктир
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_DASH);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
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
   double Ind[2],Col[1];
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
      IndBuffer1[bar]=EMPTY_VALUE;
      IndBuffer2[bar]=MiddleLevel;
      ColorIndBuffer[bar]=0;
      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,IndTime)<=0) return(RESET);
      //----
      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind_Handle,0,time[bar],1,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,Col)<=0) return(RESET);
         //---- загрузка полученных значений в индикаторные буферы
         IndBuffer1[bar]=Ind[0];
         ColorIndBuffer[bar]=Col[0];
        }
      //----
      if(ReDraw)
        {
         if(IndBuffer1[bar+1]!=EMPTY_VALUE && IndBuffer1[bar]==EMPTY_VALUE)
           {
            IndBuffer1[bar]=IndBuffer1[bar+1];
            ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
