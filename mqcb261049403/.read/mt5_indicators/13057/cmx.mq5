//+------------------------------------------------------------------+ 
//|                                                          CMx.mq5 | 
//|                                       Copyright © 2005, Alexandr | 
//|                                              beluck[at]gmail.com | 
//+------------------------------------------------------------------+ 
//--- авторство индикатора
#property copyright "Copyright © 2005, Alexandr"
//--- авторство индикатора
#property link      ""
//--- номер версии индикатора
#property version   "1.01"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//--- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован LimeGreen цвет
#property indicator_color1  clrLimeGreen
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "CMx"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
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
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[];
//---
double L_adxk;
//--- объявление целочисленных переменных для хендлов индикаторов
int MA1_Handle,MA2_Handle,Ind_Handle,ADX_Handle,CCI_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   int Fk=int(MathRound(MathAbs(F*k)));
   min_rates_total=int(MathMax(F,Fk));
   if(F>0) min_rates_total*=2;
//--- 
   if(F<0)
     {
      //--- получение хендла индикатора iMA 1
      MA1_Handle=iMA(Symbol(),PERIOD_CURRENT,-F,0,MODE_EMA,PRICE_CLOSE);
      if(MA1_Handle==INVALID_HANDLE)
        {
         Print("Не удалось получить хендл индикатора iMA 1");
         return(INIT_FAILED);
        }
      //--- получение хендла индикатора iMA 2
      MA2_Handle=iMA(Symbol(),PERIOD_CURRENT,Fk,0,MODE_EMA,PRICE_CLOSE);
      if(MA2_Handle==INVALID_HANDLE)
        {
         Print("Не удалось получить хендл индикатора iMA 2");
         return(INIT_FAILED);
        }
     }
   else if(F>0)
     {
      L_adxk=L_adx*k;
      string IndName=MQLInfoString(MQL_PROGRAM_NAME);
      //---- получение хендла индикатора CMx
      Ind_Handle=iCustom(Symbol(),PERIOD_CURRENT,IndName,-F,k,L_adx,0);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print("Не удалось получить хендл индикатора CMx");
         return(INIT_FAILED);
        }
      //--- получение хендла индикатора iCCI
      CCI_Handle=iCCI(Symbol(),PERIOD_CURRENT,Fk,Ind_Handle);
      if(CCI_Handle==INVALID_HANDLE)
        {
         Print("Не удалось получить хендл индикатора iCCI");
         return(INIT_FAILED);
        }
      //--- получение хендла индикатора iADX
      ADX_Handle=iADX(Symbol(),PERIOD_CURRENT,F);
      if(ADX_Handle==INVALID_HANDLE)
        {
         Print("Не удалось получить хендл индикатора iADX");
         return(INIT_FAILED);
        }
     }
   else
     {
      Print("Период индикатора не может быть меньше единицы!");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"CMx(",F,", ",DoubleToString(k,4),", ",DoubleToString(L_adx,2),", ",Shift,")");
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
//--- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
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
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//---
   if(F<0)
     {
      if(BarsCalculated(MA1_Handle)<rates_total
         || BarsCalculated(MA2_Handle)<rates_total) return(RESET);
     }
   else
     {
      if(BarsCalculated(Ind_Handle)<rates_total
         || BarsCalculated(ADX_Handle)<rates_total
         || BarsCalculated(CCI_Handle)<rates_total) return(RESET);
     }
//--- объявления локальных переменных 
   int to_copy,limit,bar;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---   
   to_copy=limit+1;
//---
   if(F<0)
     {
      double Ma1[],Ma2[];
      //--- индексация элементов в массивах как в таймсериях  
      ArraySetAsSeries(Ma1,true);
      ArraySetAsSeries(Ma2,true);
      //--- копируем вновь появившиеся данные в буфер
      if(CopyBuffer(MA1_Handle,0,0,to_copy,Ma1)<=0) return(RESET);
      if(CopyBuffer(MA2_Handle,0,0,to_copy,Ma2)<=0) return(RESET);
      //--- основной цикл расчета индикатора
      for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=Ma1[bar]-Ma2[bar];
     }
   else
     {
      double CCI[],ADX[];
      //--- индексация элементов в массивах как в таймсериях  
      ArraySetAsSeries(CCI,true);
      ArraySetAsSeries(ADX,true);
      //--- копируем вновь появившиеся данные в буфер
      if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
      if(CopyBuffer(ADX_Handle,0,0,to_copy,ADX)<=0) return(RESET);
      //--- основной цикл расчета индикатора
      for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=CCI[bar]*ADX[bar]/L_adxk;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
