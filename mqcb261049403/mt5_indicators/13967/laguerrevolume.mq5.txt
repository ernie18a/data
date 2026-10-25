//+-------------------------------------------------------------------------+ 
//|                                                      LaguerreVolume.mq5 | 
//|                                 Copyright © 2007, Emerald King, t_david |
//| http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators |
//+-------------------------------------------------------------------------+
#property copyright "Copyright © 2007, Emerald King, t_david"
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DarkOrchid цвет
#property indicator_color1 clrDarkOrchid
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1 1
//---- отображение метки индикатора
#property indicator_label1  "LaguerreVolume"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input double gamma=0.618;                          // Коэффициент усреднения
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Объем
input int Shift=0;                                 // Сдвиг индикатора по горизонтали в барах
input double inHighLevel=0.75;
input double inMiddleLevel=0.50;
input double inLowLevel=0.25;
//+-----------------------------------+
//---- индикаторный буфер
double IndBuffer[];
//---- объявление глобальных переменных
int min_rates_total;
//+------------------------------------------------------------------+    
//| LaguerreVolume indicator initialization function                 | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=2;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"LaguerreVolume",DoubleToString(gamma,3),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inHighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inMiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,inLowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrRed);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrGray);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| LaguerreVolume iteration function                                | 
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   long vol;
   int limit,bar;
   double L0,L1,L2,L3,L0A,L1A,L2A,L3A,CD,CU,RES;
//---- объявления статических переменных для хранения действительных значений коэфициентов
   static double L0_,L1_,L2_,L3_,L0A_,L1A_,L2A_,L3A_;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      //---- стартовая инициализация расчетных коэффициентов
      double Vol;
      if(VolumeType==VOLUME_TICK) Vol=double(tick_volume[0]);
      else                        Vol=double(volume[0]);
      L0_ = Vol;
      L1_ = Vol;
      L2_ = Vol;
      L3_ = Vol;
      L0A_ = Vol;
      L1A_ = Vol;
      L2A_ = Vol;
      L3A_ = Vol;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- восстанавливаем значения переменных
   L0 = L0_;
   L1 = L1_;
   L2 = L2_;
   L3 = L3_;
   L0A = L0A_;
   L1A = L1A_;
   L2A = L2A_;
   L3A = L3A_;
//---- индексация элементов в массивах как в таймсериях  
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(tick_volume,true);
   else                        ArraySetAsSeries(volume,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      L0A = L0;
      L1A = L1;
      L2A = L2;
      L3A = L3;
      //----
      if(VolumeType==VOLUME_TICK) vol=tick_volume[bar];
      else                        vol=volume[bar];
      //----
      L0 = (1 - gamma) * vol + gamma * L0A;
      L1 = - gamma * L0 + L0A + gamma * L1A;
      L2 = - gamma * L1 + L1A + gamma * L2A;
      L3 = - gamma * L2 + L2A + gamma * L3A;
      //----
      CU = 0;
      CD = 0;
      //---- 
      if(L0 >= L1) CU  = L0 - L1; else CD  = L1 - L0;
      if(L1 >= L2) CU += L1 - L2; else CD += L2 - L1;
      if(L2 >= L3) CU += L2 - L3; else CD += L3 - L2;
      //----
      RES=CU+CD;
      if(RES) IndBuffer[bar]=CU/RES;
      else IndBuffer[bar]=0.0;
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(bar)
        {
         L0_ = L0;
         L1_ = L1;
         L2_ = L2;
         L3_ = L3;
         L0A_ = L0A;
         L1A_ = L1A;
         L2A_ = L2A;
         L3A_ = L3A;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
