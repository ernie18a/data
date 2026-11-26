//+------------------------------------------------------------------+ 
//|                                     Bollinger_Squeeze_v9_HTF.mq5 | 
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
//---- использовано всего одно графические построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырехцветной гистограммы использованы
#property indicator_color1 clrRed,clrOrchid,clrGray,clrDodgerBlue,clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "Bollinger_Squeeze_v9 HISTOGRAM"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Mode //тип константы
  {
   ENAME_STOCHASTIC = 1,     //stochastic
   ENAME_CCI,                //cci
   ENAME_RSI,                //rsi
   ENAME_MACD,               //macd
   ENAME_MOMENTUM            //momentum
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Период графика
input Mode triggerType=ENAME_MACD;
input uint stochPeriod_trigger1=14;
input uint cciPeriod_trigger2=50;
input uint rsiPeriod_trigger3=10;
input uint macd_fastEMA_trigger4=5;
input uint macd_slowEMA_trigger4=13;
input uint macd_macdEMA_trigger4=1;
input uint momentumPeriod_trigger5=14;
input bool ReDraw=true;                    // Повтор отображения инфомации на пустых барах
//+----------------------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочислыннех переменных для хендлов индикаторов
int Ind_Handle;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+    
//| Bollinger_Squeeze_v9 indicator initialization function           | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=3;
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора Bollinger_Squeeze_v9 не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора Bollinger_Squeeze_v9
   Ind_Handle=iCustom(Symbol(),TimeFrame,"Bollinger_Squeeze_v9",triggerType,stochPeriod_trigger1,cciPeriod_trigger2,rsiPeriod_trigger3,macd_fastEMA_trigger4,
                      macd_slowEMA_trigger4,macd_macdEMA_trigger4,momentumPeriod_trigger5);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Bollinger_Squeeze_v9");
      return(INIT_FAILED);
     }
//---- установка уровней   
   switch(triggerType)
     {
      case 1:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- значения горизонтальных уровней индикатора   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+30);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-30);
         //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- в линии горизонтального уровня использован короткий штрих-пунктир  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
      case 2:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,4);
         //---- значения горизонтальных уровней индикатора   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+200);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,+100);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-100);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-200);
         //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
         //---- в линии горизонтального уровня использован короткий штрих-пунктир  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
         break;
      case 3:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- значения горизонтальных уровней индикатора   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+20);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-20);
         //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- в линии горизонтального уровня использован короткий штрих-пунктир  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
      case 4:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,0);
         break;
      case 5:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- значения горизонтальных уровней индикатора   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-1);
         //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- в линии горизонтального уровня использован короткий штрих-пунктир  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
     }
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   switch(triggerType)
     {
      case 1: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with Stochastic ("+string(stochPeriod_trigger1)+",3,3)"); break;
      case 2: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with CCI ("+string(cciPeriod_trigger2)+",CLOSE)"); break;
      case 3: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with RSI ("+string(rsiPeriod_trigger3)+",CLOSE)"); break;
      case 4: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with MACD (5,13,1,CLOSE)"); break;
      case 5: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with Momentum ("+string(momentumPeriod_trigger5)+",CLOSE)"); break;
     }
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Bollinger_Squeeze_v9 iteration function                          | 
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
   double Ind[1],Col[1];
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
         IndBuffer[bar]=Ind[0];
         ColorIndBuffer[bar]=Col[0];
        }
      if(ReDraw)
        {
         if(IndBuffer[bar+1]!=EMPTY_VALUE && IndBuffer[bar]==EMPTY_VALUE)
           {
            IndBuffer[bar]=IndBuffer[bar+1];
            ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
