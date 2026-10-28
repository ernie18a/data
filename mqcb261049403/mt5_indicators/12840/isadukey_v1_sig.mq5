//+------------------------------------------------------------------+
//|                                             i-Sadukey_v1_Sig.mq5 |
//|                                                                  | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright ""
#property link ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован DeepPink цвет
#property indicator_color1  clrDeepPink
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "Sadukey_v1 Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Sadukey_v1 Buy"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0       // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Shift=0;    // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   int ATR_Period=10;
   min_rates_total=int(MathMax(67+3,ATR_Period));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,172);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,172);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- инициализации переменной для короткого имени индикатора
   string shortname="i-Sadukey_v1_Sig";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int first;
//--- объявление переменных с плавающей точкой                 
   double Vel1,Vel2,Diff0,ATR[1];
   static double Diff1;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=67; // стартовый номер для расчета всех баров
      Diff1=0;
     }
   else
     {
      first=prev_calculated-1; // стартовый номер для расчета новых баров
     }
//--- основной цикл расчета индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Vel1=
           +0.11859648*((open[bar- 0]+close[bar- 0]+high[bar- 0]+low[bar- 0])/4+close[bar- 0])/2
           +0.11781324*((open[bar- 1]+close[bar- 1]+high[bar- 1]+low[bar- 1])/4+close[bar- 1])/2
           +0.11548308*((open[bar- 2]+close[bar- 2]+high[bar- 2]+low[bar- 2])/4+close[bar- 2])/2
           +0.11166411*((open[bar- 3]+close[bar- 3]+high[bar- 3]+low[bar- 3])/4+close[bar- 3])/2
           +0.10645106*((open[bar- 4]+close[bar- 4]+high[bar- 4]+low[bar- 4])/4+close[bar- 4])/2
           +0.09997253*((open[bar- 5]+close[bar- 5]+high[bar- 5]+low[bar- 5])/4+close[bar- 5])/2
           +0.09238688*((open[bar- 6]+close[bar- 6]+high[bar- 6]+low[bar- 6])/4+close[bar- 6])/2
           +0.08387751*((open[bar- 7]+close[bar- 7]+high[bar- 7]+low[bar- 7])/4+close[bar- 7])/2
           +0.07464713*((open[bar- 8]+close[bar- 8]+high[bar- 8]+low[bar- 8])/4+close[bar- 8])/2
           +0.06491178*((open[bar- 9]+close[bar- 9]+high[bar- 9]+low[bar- 9])/4+close[bar- 9])/2
           +0.05489443*((open[bar-10]+close[bar-10]+high[bar-10]+low[bar-10])/4+close[bar-10])/2
           +0.04481833*((open[bar-11]+close[bar-11]+high[bar-11]+low[bar-11])/4+close[bar-11])/2
           +0.03490071*((open[bar-12]+close[bar-12]+high[bar-12]+low[bar-12])/4+close[bar-12])/2
           +0.02534672*((open[bar-13]+close[bar-13]+high[bar-13]+low[bar-13])/4+close[bar-13])/2
           +0.01634375*((open[bar-14]+close[bar-14]+high[bar-14]+low[bar-14])/4+close[bar-14])/2
           +0.00805678*((open[bar-15]+close[bar-15]+high[bar-15]+low[bar-15])/4+close[bar-15])/2
           +0.00062421*((open[bar-16]+close[bar-16]+high[bar-16]+low[bar-16])/4+close[bar-16])/2
           -0.00584512*((open[bar-17]+close[bar-17]+high[bar-17]+low[bar-17])/4+close[bar-17])/2
           -0.01127391*((open[bar-18]+close[bar-18]+high[bar-18]+low[bar-18])/4+close[bar-18])/2
           -0.01561738*((open[bar-19]+close[bar-19]+high[bar-19]+low[bar-19])/4+close[bar-19])/2
           -0.01886307*((open[bar-20]+close[bar-20]+high[bar-20]+low[bar-20])/4+close[bar-20])/2
           -0.02102974*((open[bar-21]+close[bar-21]+high[bar-21]+low[bar-21])/4+close[bar-21])/2
           -0.02216516*((open[bar-22]+close[bar-22]+high[bar-22]+low[bar-22])/4+close[bar-22])/2
           -0.02234315*((open[bar-23]+close[bar-23]+high[bar-23]+low[bar-23])/4+close[bar-23])/2
           -0.02165992*((open[bar-24]+close[bar-24]+high[bar-24]+low[bar-24])/4+close[bar-24])/2
           -0.02022973*((open[bar-25]+close[bar-25]+high[bar-25]+low[bar-25])/4+close[bar-25])/2
           -0.01818026*((open[bar-26]+close[bar-26]+high[bar-26]+low[bar-26])/4+close[bar-26])/2
           -0.01564777*((open[bar-27]+close[bar-27]+high[bar-27]+low[bar-27])/4+close[bar-27])/2
           -0.01277219*((open[bar-28]+close[bar-28]+high[bar-28]+low[bar-28])/4+close[bar-28])/2
           -0.00969230*((open[bar-29]+close[bar-29]+high[bar-29]+low[bar-29])/4+close[bar-29])/2
           -0.00654127*((open[bar-30]+close[bar-30]+high[bar-30]+low[bar-30])/4+close[bar-30])/2
           -0.00344276*((open[bar-31]+close[bar-31]+high[bar-31]+low[bar-31])/4+close[bar-31])/2
           -0.00050728*((open[bar-32]+close[bar-32]+high[bar-32]+low[bar-32])/4+close[bar-32])/2
           +0.00217042*((open[bar-33]+close[bar-33]+high[bar-33]+low[bar-33])/4+close[bar-33])/2
           +0.00451354*((open[bar-34]+close[bar-34]+high[bar-34]+low[bar-34])/4+close[bar-34])/2
           +0.00646441*((open[bar-35]+close[bar-35]+high[bar-35]+low[bar-35])/4+close[bar-35])/2
           +0.00798513*((open[bar-36]+close[bar-36]+high[bar-36]+low[bar-36])/4+close[bar-36])/2
           +0.00905725*((open[bar-37]+close[bar-37]+high[bar-37]+low[bar-37])/4+close[bar-37])/2
           +0.00968091*((open[bar-38]+close[bar-38]+high[bar-38]+low[bar-38])/4+close[bar-38])/2
           +0.00987326*((open[bar-39]+close[bar-39]+high[bar-39]+low[bar-39])/4+close[bar-39])/2
           +0.00966639*((open[bar-40]+close[bar-40]+high[bar-40]+low[bar-40])/4+close[bar-40])/2
           +0.00910488*((open[bar-41]+close[bar-41]+high[bar-41]+low[bar-41])/4+close[bar-41])/2
           +0.00824306*((open[bar-42]+close[bar-42]+high[bar-42]+low[bar-42])/4+close[bar-42])/2
           +0.00714199*((open[bar-43]+close[bar-43]+high[bar-43]+low[bar-43])/4+close[bar-43])/2
           +0.00586655*((open[bar-44]+close[bar-44]+high[bar-44]+low[bar-44])/4+close[bar-44])/2
           +0.00448255*((open[bar-45]+close[bar-45]+high[bar-45]+low[bar-45])/4+close[bar-45])/2
           +0.00305396*((open[bar-46]+close[bar-46]+high[bar-46]+low[bar-46])/4+close[bar-46])/2
           +0.00164061*((open[bar-47]+close[bar-47]+high[bar-47]+low[bar-47])/4+close[bar-47])/2
           +0.00029596*((open[bar-48]+close[bar-48]+high[bar-48]+low[bar-48])/4+close[bar-48])/2
           -0.00093445*((open[bar-49]+close[bar-49]+high[bar-49]+low[bar-49])/4+close[bar-49])/2
           -0.00201426*((open[bar-50]+close[bar-50]+high[bar-50]+low[bar-50])/4+close[bar-50])/2
           -0.00291701*((open[bar-51]+close[bar-51]+high[bar-51]+low[bar-51])/4+close[bar-51])/2
           -0.00362661*((open[bar-52]+close[bar-52]+high[bar-52]+low[bar-52])/4+close[bar-52])/2
           -0.00413703*((open[bar-53]+close[bar-53]+high[bar-53]+low[bar-53])/4+close[bar-53])/2
           -0.00445206*((open[bar-54]+close[bar-54]+high[bar-54]+low[bar-54])/4+close[bar-54])/2
           -0.00458437*((open[bar-55]+close[bar-55]+high[bar-55]+low[bar-55])/4+close[bar-55])/2
           -0.00455457*((open[bar-56]+close[bar-56]+high[bar-56]+low[bar-56])/4+close[bar-56])/2
           -0.00439006*((open[bar-57]+close[bar-57]+high[bar-57]+low[bar-57])/4+close[bar-57])/2
           -0.00412379*((open[bar-58]+close[bar-58]+high[bar-58]+low[bar-58])/4+close[bar-58])/2
           -0.00379323*((open[bar-59]+close[bar-59]+high[bar-59]+low[bar-59])/4+close[bar-59])/2
           -0.00343966*((open[bar-60]+close[bar-60]+high[bar-60]+low[bar-60])/4+close[bar-60])/2
           -0.00310850*((open[bar-61]+close[bar-61]+high[bar-61]+low[bar-61])/4+close[bar-61])/2
           -0.00285188*((open[bar-62]+close[bar-62]+high[bar-62]+low[bar-62])/4+close[bar-62])/2
           -0.00273508*((open[bar-63]+close[bar-63]+high[bar-63]+low[bar-63])/4+close[bar-63])/2
           -0.00274361*((open[bar-64]+close[bar-64]+high[bar-64]+low[bar-64])/4+close[bar-64])/2
           +0.01018757*((open[bar-65]+close[bar-65]+high[bar-65]+low[bar-65])/4+close[bar-65])/2;
      //---
      Vel2=
           +0.11859648*((open[bar- 0]+close[bar- 0]+high[bar- 0]+low[bar- 0])/4+open[bar- 0])/2
           +0.11781324*((open[bar- 1]+close[bar- 1]+high[bar- 1]+low[bar- 1])/4+open[bar- 1])/2
           +0.11548308*((open[bar- 2]+close[bar- 2]+high[bar- 2]+low[bar- 2])/4+open[bar- 2])/2
           +0.11166411*((open[bar- 3]+close[bar- 3]+high[bar- 3]+low[bar- 3])/4+open[bar- 3])/2
           +0.10645106*((open[bar- 4]+close[bar- 4]+high[bar- 4]+low[bar- 4])/4+open[bar- 4])/2
           +0.09997253*((open[bar- 5]+close[bar- 5]+high[bar- 5]+low[bar- 5])/4+open[bar- 5])/2
           +0.09238688*((open[bar- 6]+close[bar- 6]+high[bar- 6]+low[bar- 6])/4+open[bar- 6])/2
           +0.08387751*((open[bar- 7]+close[bar- 7]+high[bar- 7]+low[bar- 7])/4+open[bar- 7])/2
           +0.07464713*((open[bar- 8]+close[bar- 8]+high[bar- 8]+low[bar- 8])/4+open[bar- 8])/2
           +0.06491178*((open[bar- 9]+close[bar- 9]+high[bar- 9]+low[bar- 9])/4+open[bar- 9])/2
           +0.05489443*((open[bar-10]+close[bar-10]+high[bar-10]+low[bar-10])/4+open[bar-10])/2
           +0.04481833*((open[bar-11]+close[bar-11]+high[bar-11]+low[bar-11])/4+open[bar-11])/2
           +0.03490071*((open[bar-12]+close[bar-12]+high[bar-12]+low[bar-12])/4+open[bar-12])/2
           +0.02534672*((open[bar-13]+close[bar-13]+high[bar-13]+low[bar-13])/4+open[bar-13])/2
           +0.01634375*((open[bar-14]+close[bar-14]+high[bar-14]+low[bar-14])/4+open[bar-14])/2
           +0.00805678*((open[bar-15]+close[bar-15]+high[bar-15]+low[bar-15])/4+open[bar-15])/2
           +0.00062421*((open[bar-16]+close[bar-16]+high[bar-16]+low[bar-16])/4+open[bar-16])/2
           -0.00584512*((open[bar-17]+close[bar-17]+high[bar-17]+low[bar-17])/4+open[bar-17])/2
           -0.01127391*((open[bar-18]+close[bar-18]+high[bar-18]+low[bar-18])/4+open[bar-18])/2
           -0.01561738*((open[bar-19]+close[bar-19]+high[bar-19]+low[bar-19])/4+open[bar-19])/2
           -0.01886307*((open[bar-20]+close[bar-20]+high[bar-20]+low[bar-20])/4+open[bar-20])/2
           -0.02102974*((open[bar-21]+close[bar-21]+high[bar-21]+low[bar-21])/4+open[bar-21])/2
           -0.02216516*((open[bar-22]+close[bar-22]+high[bar-22]+low[bar-22])/4+open[bar-22])/2
           -0.02234315*((open[bar-23]+close[bar-23]+high[bar-23]+low[bar-23])/4+open[bar-23])/2
           -0.02165992*((open[bar-24]+close[bar-24]+high[bar-24]+low[bar-24])/4+open[bar-24])/2
           -0.02022973*((open[bar-25]+close[bar-25]+high[bar-25]+low[bar-25])/4+open[bar-25])/2
           -0.01818026*((open[bar-26]+close[bar-26]+high[bar-26]+low[bar-26])/4+open[bar-26])/2
           -0.01564777*((open[bar-27]+close[bar-27]+high[bar-27]+low[bar-27])/4+open[bar-27])/2
           -0.01277219*((open[bar-28]+close[bar-28]+high[bar-28]+low[bar-28])/4+open[bar-28])/2
           -0.00969230*((open[bar-29]+close[bar-29]+high[bar-29]+low[bar-29])/4+open[bar-29])/2
           -0.00654127*((open[bar-30]+close[bar-30]+high[bar-30]+low[bar-30])/4+open[bar-30])/2
           -0.00344276*((open[bar-31]+close[bar-31]+high[bar-31]+low[bar-31])/4+open[bar-31])/2
           -0.00050728*((open[bar-32]+close[bar-32]+high[bar-32]+low[bar-32])/4+open[bar-32])/2
           +0.00217042*((open[bar-33]+close[bar-33]+high[bar-33]+low[bar-33])/4+open[bar-33])/2
           +0.00451354*((open[bar-34]+close[bar-34]+high[bar-34]+low[bar-34])/4+open[bar-34])/2
           +0.00646441*((open[bar-35]+close[bar-35]+high[bar-35]+low[bar-35])/4+open[bar-35])/2
           +0.00798513*((open[bar-36]+close[bar-36]+high[bar-36]+low[bar-36])/4+open[bar-36])/2
           +0.00905725*((open[bar-37]+close[bar-37]+high[bar-37]+low[bar-37])/4+open[bar-37])/2
           +0.00968091*((open[bar-38]+close[bar-38]+high[bar-38]+low[bar-38])/4+open[bar-38])/2
           +0.00987326*((open[bar-39]+close[bar-39]+high[bar-39]+low[bar-39])/4+open[bar-39])/2
           +0.00966639*((open[bar-40]+close[bar-40]+high[bar-40]+low[bar-40])/4+open[bar-40])/2
           +0.00910488*((open[bar-41]+close[bar-41]+high[bar-41]+low[bar-41])/4+open[bar-41])/2
           +0.00824306*((open[bar-42]+close[bar-42]+high[bar-42]+low[bar-42])/4+open[bar-42])/2
           +0.00714199*((open[bar-43]+close[bar-43]+high[bar-43]+low[bar-43])/4+open[bar-43])/2
           +0.00586655*((open[bar-44]+close[bar-44]+high[bar-44]+low[bar-44])/4+open[bar-44])/2
           +0.00448255*((open[bar-45]+close[bar-45]+high[bar-45]+low[bar-45])/4+open[bar-45])/2
           +0.00305396*((open[bar-46]+close[bar-46]+high[bar-46]+low[bar-46])/4+open[bar-46])/2
           +0.00164061*((open[bar-47]+close[bar-47]+high[bar-47]+low[bar-47])/4+open[bar-47])/2
           +0.00029596*((open[bar-48]+close[bar-48]+high[bar-48]+low[bar-48])/4+open[bar-48])/2
           -0.00093445*((open[bar-49]+close[bar-49]+high[bar-49]+low[bar-49])/4+open[bar-49])/2
           -0.00201426*((open[bar-50]+close[bar-50]+high[bar-50]+low[bar-50])/4+open[bar-50])/2
           -0.00291701*((open[bar-51]+close[bar-51]+high[bar-51]+low[bar-51])/4+open[bar-51])/2
           -0.00362661*((open[bar-52]+close[bar-52]+high[bar-52]+low[bar-52])/4+open[bar-52])/2
           -0.00413703*((open[bar-53]+close[bar-53]+high[bar-53]+low[bar-53])/4+open[bar-53])/2
           -0.00445206*((open[bar-54]+close[bar-54]+high[bar-54]+low[bar-54])/4+open[bar-54])/2
           -0.00458437*((open[bar-55]+close[bar-55]+high[bar-55]+low[bar-55])/4+open[bar-55])/2
           -0.00455457*((open[bar-56]+close[bar-56]+high[bar-56]+low[bar-56])/4+open[bar-56])/2
           -0.00439006*((open[bar-57]+close[bar-57]+high[bar-57]+low[bar-57])/4+open[bar-57])/2
           -0.00412379*((open[bar-58]+close[bar-58]+high[bar-58]+low[bar-58])/4+open[bar-58])/2
           -0.00379323*((open[bar-59]+close[bar-59]+high[bar-59]+low[bar-59])/4+open[bar-59])/2
           -0.00343966*((open[bar-60]+close[bar-60]+high[bar-60]+low[bar-60])/4+open[bar-60])/2
           -0.00310850*((open[bar-61]+close[bar-61]+high[bar-61]+low[bar-61])/4+open[bar-61])/2
           -0.00285188*((open[bar-62]+close[bar-62]+high[bar-62]+low[bar-62])/4+open[bar-62])/2
           -0.00273508*((open[bar-63]+close[bar-63]+high[bar-63]+low[bar-63])/4+open[bar-63])/2
           -0.00274361*((open[bar-64]+close[bar-64]+high[bar-64]+low[bar-64])/4+open[bar-64])/2
           +0.01018757*((open[bar-65]+close[bar-65]+high[bar-65]+low[bar-65])/4+open[bar-65])/2;
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      Diff0=Vel1-Vel2;
      //---      
      if(Diff1<=0 && Diff0>0)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(Diff1>=0 && Diff0<0)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      if(bar<rates_total-1) Diff1=Diff0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
