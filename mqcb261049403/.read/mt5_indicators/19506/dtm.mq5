//+------------------------------------------------------------------+
//|                                                          Dtm.mq5 |
//|                                  Copyright 2002, Finware.ru Ltd. |
//|                                http://www.forex-instruments.info |
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright 2002, Finware.ru Ltd."
//---- авторство индикатора
#property link      "http://www.forex-instruments.info"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color1  clrTeal,clrGold
//---- отображение метки линии индикатора
#property indicator_label1  "Dtm"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_SOLID
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
#define MAXPERIOD 84  // константа для ограничения маскимального периода
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;       // ценовая константа
input int Shift=0;                                // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double FTLMBuffer[],STLMBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=MAXPERIOD+1;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,FTLMBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,STLMBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Dtm(",EnumToString(IPC),",",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,5);
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
   int first,bar;
   double value1,value2,value3,value4;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=min_rates_total+1;                   // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      value1=
             0.112952*PriceSeries(IPC,bar-0,open,low,high,close)
             +0.111644*PriceSeries(IPC,bar-1,open,low,high,close)
             +0.109058*PriceSeries(IPC,bar-2,open,low,high,close)
             +0.105254*PriceSeries(IPC,bar-3,open,low,high,close)
             +0.100320*PriceSeries(IPC,bar-4,open,low,high,close)
             +0.094368*PriceSeries(IPC,bar-5,open,low,high,close)
             +0.087532*PriceSeries(IPC,bar-6,open,low,high,close)
             +0.079966*PriceSeries(IPC,bar-7,open,low,high,close)
             +0.071834*PriceSeries(IPC,bar-8,open,low,high,close)
             +0.063313*PriceSeries(IPC,bar-9,open,low,high,close)
             +0.054575*PriceSeries(IPC,bar-10,open,low,high,close)
             +0.045801*PriceSeries(IPC,bar-11,open,low,high,close)
             +0.037159*PriceSeries(IPC,bar-12,open,low,high,close)
             +0.028809*PriceSeries(IPC,bar-13,open,low,high,close)
             +0.020898*PriceSeries(IPC,bar-14,open,low,high,close)
             +0.013548*PriceSeries(IPC,bar-15,open,low,high,close)
             +0.006870*PriceSeries(IPC,bar-16,open,low,high,close)
             +0.000944*PriceSeries(IPC,bar-17,open,low,high,close)
             -0.004166*PriceSeries(IPC,bar-18,open,low,high,close)
             -0.008428*PriceSeries(IPC,bar-19,open,low,high,close)
             -0.011828*PriceSeries(IPC,bar-20,open,low,high,close)
             -0.014378*PriceSeries(IPC,bar-21,open,low,high,close)
             -0.016112*PriceSeries(IPC,bar-22,open,low,high,close)
             -0.017080*PriceSeries(IPC,bar-23,open,low,high,close)
             -0.017348*PriceSeries(IPC,bar-24,open,low,high,close)
             -0.016998*PriceSeries(IPC,bar-25,open,low,high,close)
             -0.016118*PriceSeries(IPC,bar-26,open,low,high,close)
             -0.014806*PriceSeries(IPC,bar-27,open,low,high,close)
             -0.013156*PriceSeries(IPC,bar-28,open,low,high,close)
             -0.011270*PriceSeries(IPC,bar-29,open,low,high,close)
             -0.009238*PriceSeries(IPC,bar-30,open,low,high,close)
             -0.007152*PriceSeries(IPC,bar-31,open,low,high,close)
             -0.005090*PriceSeries(IPC,bar-32,open,low,high,close)
             -0.003120*PriceSeries(IPC,bar-33,open,low,high,close)
             -0.001302*PriceSeries(IPC,bar-34,open,low,high,close)
             +0.000322*PriceSeries(IPC,bar-35,open,low,high,close)
             +0.001714*PriceSeries(IPC,bar-36,open,low,high,close)
             +0.002858*PriceSeries(IPC,bar-37,open,low,high,close)
             +0.003744*PriceSeries(IPC,bar-38,open,low,high,close)
             +0.004372*PriceSeries(IPC,bar-39,open,low,high,close)
             +0.004754*PriceSeries(IPC,bar-40,open,low,high,close)
             +0.004910*PriceSeries(IPC,bar-41,open,low,high,close)
             +0.004864*PriceSeries(IPC,bar-42,open,low,high,close)
             +0.004646*PriceSeries(IPC,bar-43,open,low,high,close)
             +0.004288*PriceSeries(IPC,bar-44,open,low,high,close)
             +0.003824*PriceSeries(IPC,bar-45,open,low,high,close)
             +0.003288*PriceSeries(IPC,bar-46,open,low,high,close)
             +0.002712*PriceSeries(IPC,bar-47,open,low,high,close)
             +0.002124*PriceSeries(IPC,bar-48,open,low,high,close)
             +0.001548*PriceSeries(IPC,bar-49,open,low,high,close)
             +0.001010*PriceSeries(IPC,bar-50,open,low,high,close)
             +0.000522*PriceSeries(IPC,bar-51,open,low,high,close)
             +0.000098*PriceSeries(IPC,bar-52,open,low,high,close)
             -0.000254*PriceSeries(IPC,bar-53,open,low,high,close)
             -0.000530*PriceSeries(IPC,bar-54,open,low,high,close)
             -0.000734*PriceSeries(IPC,bar-55,open,low,high,close)
             -0.000866*PriceSeries(IPC,bar-56,open,low,high,close)
             -0.000934*PriceSeries(IPC,bar-57,open,low,high,close)
             -0.000948*PriceSeries(IPC,bar-58,open,low,high,close)
             -0.000914*PriceSeries(IPC,bar-59,open,low,high,close)
             -0.000844*PriceSeries(IPC,bar-60,open,low,high,close)
             -0.000750*PriceSeries(IPC,bar-61,open,low,high,close)
             -0.000638*PriceSeries(IPC,bar-62,open,low,high,close)
             -0.000520*PriceSeries(IPC,bar-63,open,low,high,close)
             -0.000922*PriceSeries(IPC,bar-64,open,low,high,close);

      value2=
             0.038953*PriceSeries(IPC,bar-0,open,low,high,close)
             +0.042502*PriceSeries(IPC,bar-1,open,low,high,close)
             +0.045773*PriceSeries(IPC,bar-2,open,low,high,close)
             +0.048702*PriceSeries(IPC,bar-3,open,low,high,close)
             +0.051237*PriceSeries(IPC,bar-4,open,low,high,close)
             +0.053326*PriceSeries(IPC,bar-5,open,low,high,close)
             +0.054931*PriceSeries(IPC,bar-6,open,low,high,close)
             +0.056018*PriceSeries(IPC,bar-7,open,low,high,close)
             +0.056566*PriceSeries(IPC,bar-8,open,low,high,close)
             +0.056566*PriceSeries(IPC,bar-9,open,low,high,close)
             +0.056018*PriceSeries(IPC,bar-10,open,low,high,close)
             +0.054931*PriceSeries(IPC,bar-11,open,low,high,close)
             +0.053326*PriceSeries(IPC,bar-12,open,low,high,close)
             +0.051237*PriceSeries(IPC,bar-13,open,low,high,close)
             +0.048702*PriceSeries(IPC,bar-14,open,low,high,close)
             +0.045773*PriceSeries(IPC,bar-15,open,low,high,close)
             +0.042502*PriceSeries(IPC,bar-16,open,low,high,close)
             +0.038953*PriceSeries(IPC,bar-17,open,low,high,close)
             +0.035190*PriceSeries(IPC,bar-18,open,low,high,close)
             +0.031281*PriceSeries(IPC,bar-19,open,low,high,close)
             +0.027295*PriceSeries(IPC,bar-20,open,low,high,close)
             +0.023298*PriceSeries(IPC,bar-21,open,low,high,close)
             +0.019357*PriceSeries(IPC,bar-22,open,low,high,close)
             +0.015532*PriceSeries(IPC,bar-23,open,low,high,close)
             +0.011880*PriceSeries(IPC,bar-24,open,low,high,close)
             +0.008451*PriceSeries(IPC,bar-25,open,low,high,close)
             +0.005287*PriceSeries(IPC,bar-26,open,low,high,close)
             +0.002424*PriceSeries(IPC,bar-27,open,low,high,close)
             -0.000112*PriceSeries(IPC,bar-28,open,low,high,close)
             -0.002305*PriceSeries(IPC,bar-29,open,low,high,close)
             -0.004142*PriceSeries(IPC,bar-30,open,low,high,close)
             -0.005624*PriceSeries(IPC,bar-31,open,low,high,close)
             -0.006758*PriceSeries(IPC,bar-32,open,low,high,close)
             -0.007558*PriceSeries(IPC,bar-33,open,low,high,close)
             -0.008042*PriceSeries(IPC,bar-34,open,low,high,close)
             -0.008240*PriceSeries(IPC,bar-35,open,low,high,close)
             -0.008177*PriceSeries(IPC,bar-36,open,low,high,close)
             -0.007890*PriceSeries(IPC,bar-37,open,low,high,close)
             -0.007415*PriceSeries(IPC,bar-38,open,low,high,close)
             -0.006786*PriceSeries(IPC,bar-39,open,low,high,close)
             -0.006041*PriceSeries(IPC,bar-40,open,low,high,close)
             -0.005219*PriceSeries(IPC,bar-41,open,low,high,close)
             -0.004349*PriceSeries(IPC,bar-42,open,low,high,close)
             -0.003466*PriceSeries(IPC,bar-43,open,low,high,close)
             -0.002596*PriceSeries(IPC,bar-44,open,low,high,close)
             -0.001764*PriceSeries(IPC,bar-45,open,low,high,close)
             -0.000991*PriceSeries(IPC,bar-46,open,low,high,close)
             -0.000294*PriceSeries(IPC,bar-47,open,low,high,close)
             +0.000318*PriceSeries(IPC,bar-48,open,low,high,close)
             +0.000835*PriceSeries(IPC,bar-49,open,low,high,close)
             +0.001254*PriceSeries(IPC,bar-50,open,low,high,close)
             +0.001575*PriceSeries(IPC,bar-51,open,low,high,close)
             +0.001801*PriceSeries(IPC,bar-52,open,low,high,close)
             +0.001937*PriceSeries(IPC,bar-53,open,low,high,close)
             +0.001993*PriceSeries(IPC,bar-54,open,low,high,close)
             +0.001978*PriceSeries(IPC,bar-55,open,low,high,close)
             +0.001902*PriceSeries(IPC,bar-56,open,low,high,close)
             +0.001777*PriceSeries(IPC,bar-57,open,low,high,close)
             +0.001616*PriceSeries(IPC,bar-58,open,low,high,close)
             +0.001428*PriceSeries(IPC,bar-59,open,low,high,close)
             +0.001228*PriceSeries(IPC,bar-60,open,low,high,close)
             +0.001020*PriceSeries(IPC,bar-61,open,low,high,close)
             +0.000816*PriceSeries(IPC,bar-62,open,low,high,close)
             +0.000622*PriceSeries(IPC,bar-63,open,low,high,close)
             +0.000445*PriceSeries(IPC,bar-64,open,low,high,close)
             +0.000287*PriceSeries(IPC,bar-65,open,low,high,close)
             +0.000154*PriceSeries(IPC,bar-66,open,low,high,close)
             +0.000045*PriceSeries(IPC,bar-67,open,low,high,close)
             -0.000040*PriceSeries(IPC,bar-68,open,low,high,close)
             -0.000100*PriceSeries(IPC,bar-69,open,low,high,close)
             -0.000139*PriceSeries(IPC,bar-70,open,low,high,close)
             -0.000159*PriceSeries(IPC,bar-71,open,low,high,close)
             -0.000161*PriceSeries(IPC,bar-72,open,low,high,close)
             -0.000672*PriceSeries(IPC,bar-73,open,low,high,close);

      value3=
             0.0729811286*PriceSeries(IPC,bar-0,open,low,high,close)
             +0.0727839290*PriceSeries(IPC,bar-1,open,low,high,close)
             +0.0721970455*PriceSeries(IPC,bar-2,open,low,high,close)
             +0.0712248998*PriceSeries(IPC,bar-3,open,low,high,close)
             +0.0698810899*PriceSeries(IPC,bar-4,open,low,high,close)
             +0.0681787637*PriceSeries(IPC,bar-5,open,low,high,close)
             +0.0661384062*PriceSeries(IPC,bar-6,open,low,high,close)
             +0.0637836328*PriceSeries(IPC,bar-7,open,low,high,close)
             +0.0611379416*PriceSeries(IPC,bar-8,open,low,high,close)
             +0.0582328720*PriceSeries(IPC,bar-9,open,low,high,close)
             +0.0551006677*PriceSeries(IPC,bar-10,open,low,high,close)
             +0.0517729856*PriceSeries(IPC,bar-11,open,low,high,close)
             +0.0482864520*PriceSeries(IPC,bar-12,open,low,high,close)
             +0.0446761673*PriceSeries(IPC,bar-13,open,low,high,close)
             +0.0409807341*PriceSeries(IPC,bar-14,open,low,high,close)
             +0.0372349199*PriceSeries(IPC,bar-15,open,low,high,close)
             +0.0334766035*PriceSeries(IPC,bar-16,open,low,high,close)
             +0.0297389677*PriceSeries(IPC,bar-17,open,low,high,close)
             +0.0260572889*PriceSeries(IPC,bar-18,open,low,high,close)
             +0.0224620500*PriceSeries(IPC,bar-19,open,low,high,close)
             +0.0189846476*PriceSeries(IPC,bar-20,open,low,high,close)
             +0.0156508337*PriceSeries(IPC,bar-21,open,low,high,close)
             +0.0124844115*PriceSeries(IPC,bar-22,open,low,high,close)
             +0.0095064451*PriceSeries(IPC,bar-23,open,low,high,close)
             +0.0067348956*PriceSeries(IPC,bar-24,open,low,high,close)
             +0.0041825353*PriceSeries(IPC,bar-25,open,low,high,close)
             +0.0018620649*PriceSeries(IPC,bar-26,open,low,high,close)
             -0.0002214306*PriceSeries(IPC,bar-27,open,low,high,close)
             -0.0020618579*PriceSeries(IPC,bar-28,open,low,high,close)
             -0.0036612349*PriceSeries(IPC,bar-29,open,low,high,close)
             -0.0050199184*PriceSeries(IPC,bar-30,open,low,high,close)
             -0.0061460477*PriceSeries(IPC,bar-31,open,low,high,close)
             -0.0070453847*PriceSeries(IPC,bar-32,open,low,high,close)
             -0.0077311361*PriceSeries(IPC,bar-33,open,low,high,close)
             -0.0082154598*PriceSeries(IPC,bar-34,open,low,high,close)
             -0.0085069196*PriceSeries(IPC,bar-35,open,low,high,close)
             -0.0086364464*PriceSeries(IPC,bar-36,open,low,high,close)
             -0.0086063959*PriceSeries(IPC,bar-37,open,low,high,close)
             -0.0084385053*PriceSeries(IPC,bar-38,open,low,high,close)
             -0.0081544217*PriceSeries(IPC,bar-39,open,low,high,close)
             -0.0077720532*PriceSeries(IPC,bar-40,open,low,high,close)
             -0.0073096701*PriceSeries(IPC,bar-41,open,low,high,close)
             -0.0067829639*PriceSeries(IPC,bar-42,open,low,high,close)
             -0.0062100031*PriceSeries(IPC,bar-43,open,low,high,close)
             -0.0056056555*PriceSeries(IPC,bar-44,open,low,high,close)
             -0.0049866671*PriceSeries(IPC,bar-45,open,low,high,close)
             -0.0043657084*PriceSeries(IPC,bar-46,open,low,high,close)
             -0.0037560684*PriceSeries(IPC,bar-47,open,low,high,close)
             -0.0031670013*PriceSeries(IPC,bar-48,open,low,high,close)
             -0.0026079202*PriceSeries(IPC,bar-49,open,low,high,close)
             -0.0020858529*PriceSeries(IPC,bar-50,open,low,high,close)
             -0.0016064640*PriceSeries(IPC,bar-51,open,low,high,close)
             -0.0011734916*PriceSeries(IPC,bar-52,open,low,high,close)
             -0.0007908741*PriceSeries(IPC,bar-53,open,low,high,close)
             -0.0004588212*PriceSeries(IPC,bar-54,open,low,high,close)
             -0.0001790390*PriceSeries(IPC,bar-55,open,low,high,close)
             +0.0000510113*PriceSeries(IPC,bar-56,open,low,high,close)
             +0.0002315881*PriceSeries(IPC,bar-57,open,low,high,close)
             +0.0003671215*PriceSeries(IPC,bar-58,open,low,high,close)
             +0.0004595615*PriceSeries(IPC,bar-59,open,low,high,close)
             +0.0005144014*PriceSeries(IPC,bar-60,open,low,high,close)
             +0.0005345365*PriceSeries(IPC,bar-61,open,low,high,close)
             +0.0005256791*PriceSeries(IPC,bar-62,open,low,high,close)
             +0.0028871340*PriceSeries(IPC,bar-63,open,low,high,close);

      value4=
             0.0077174463*PriceSeries(IPC,bar-0,open,low,high,close)
             +0.0093613543*PriceSeries(IPC,bar-1,open,low,high,close)
             +0.0110760659*PriceSeries(IPC,bar-2,open,low,high,close)
             +0.0128488828*PriceSeries(IPC,bar-3,open,low,high,close)
             +0.0146643234*PriceSeries(IPC,bar-4,open,low,high,close)
             +0.0165073564*PriceSeries(IPC,bar-5,open,low,high,close)
             +0.0183605871*PriceSeries(IPC,bar-6,open,low,high,close)
             +0.0202076529*PriceSeries(IPC,bar-7,open,low,high,close)
             +0.0220298758*PriceSeries(IPC,bar-8,open,low,high,close)
             +0.0238101118*PriceSeries(IPC,bar-9,open,low,high,close)
             +0.0255293260*PriceSeries(IPC,bar-10,open,low,high,close)
             +0.0271702104*PriceSeries(IPC,bar-11,open,low,high,close)
             +0.0287147044*PriceSeries(IPC,bar-12,open,low,high,close)
             +0.0301471980*PriceSeries(IPC,bar-13,open,low,high,close)
             +0.0314517917*PriceSeries(IPC,bar-14,open,low,high,close)
             +0.0326129335*PriceSeries(IPC,bar-15,open,low,high,close)
             +0.0336190364*PriceSeries(IPC,bar-16,open,low,high,close)
             +0.0344584557*PriceSeries(IPC,bar-17,open,low,high,close)
             +0.0351210901*PriceSeries(IPC,bar-18,open,low,high,close)
             +0.0356004564*PriceSeries(IPC,bar-19,open,low,high,close)
             +0.0358898494*PriceSeries(IPC,bar-20,open,low,high,close)
             +0.0359870888*PriceSeries(IPC,bar-21,open,low,high,close)
             +0.0358898494*PriceSeries(IPC,bar-22,open,low,high,close)
             +0.0356004564*PriceSeries(IPC,bar-23,open,low,high,close)
             +0.0351210901*PriceSeries(IPC,bar-24,open,low,high,close)
             +0.0344584557*PriceSeries(IPC,bar-25,open,low,high,close)
             +0.0336190364*PriceSeries(IPC,bar-26,open,low,high,close)
             +0.0326129335*PriceSeries(IPC,bar-27,open,low,high,close)
             +0.0314517917*PriceSeries(IPC,bar-28,open,low,high,close)
             +0.0301471980*PriceSeries(IPC,bar-29,open,low,high,close)
             +0.0287147044*PriceSeries(IPC,bar-30,open,low,high,close)
             +0.0271702104*PriceSeries(IPC,bar-31,open,low,high,close)
             +0.0255293260*PriceSeries(IPC,bar-32,open,low,high,close)
             +0.0238101118*PriceSeries(IPC,bar-33,open,low,high,close)
             +0.0220298758*PriceSeries(IPC,bar-34,open,low,high,close)
             +0.0202076529*PriceSeries(IPC,bar-35,open,low,high,close)
             +0.0183605871*PriceSeries(IPC,bar-36,open,low,high,close)
             +0.0165073564*PriceSeries(IPC,bar-37,open,low,high,close)
             +0.0146643234*PriceSeries(IPC,bar-38,open,low,high,close)
             +0.0128488828*PriceSeries(IPC,bar-39,open,low,high,close)
             +0.0110760659*PriceSeries(IPC,bar-40,open,low,high,close)
             +0.0093613543*PriceSeries(IPC,bar-41,open,low,high,close)
             +0.0077174463*PriceSeries(IPC,bar-42,open,low,high,close)
             +0.0061560794*PriceSeries(IPC,bar-43,open,low,high,close)
             +0.0046876404*PriceSeries(IPC,bar-44,open,low,high,close)
             +0.0033209857*PriceSeries(IPC,bar-45,open,low,high,close)
             +0.0020624135*PriceSeries(IPC,bar-46,open,low,high,close)
             +0.0009181866*PriceSeries(IPC,bar-47,open,low,high,close)
             -0.0001091877*PriceSeries(IPC,bar-48,open,low,high,close)
             -0.0010167048*PriceSeries(IPC,bar-49,open,low,high,close)
             -0.0018053597*PriceSeries(IPC,bar-50,open,low,high,close)
             -0.0024753283*PriceSeries(IPC,bar-51,open,low,high,close)
             -0.0030306241*PriceSeries(IPC,bar-52,open,low,high,close)
             -0.0034740883*PriceSeries(IPC,bar-53,open,low,high,close)
             -0.0038122332*PriceSeries(IPC,bar-54,open,low,high,close)
             -0.0040510538*PriceSeries(IPC,bar-55,open,low,high,close)
             -0.0041947730*PriceSeries(IPC,bar-56,open,low,high,close)
             -0.0042586429*PriceSeries(IPC,bar-57,open,low,high,close)
             -0.0042438250*PriceSeries(IPC,bar-58,open,low,high,close)
             -0.0041610379*PriceSeries(IPC,bar-59,open,low,high,close)
             -0.0040209559*PriceSeries(IPC,bar-60,open,low,high,close)
             -0.0038324095*PriceSeries(IPC,bar-61,open,low,high,close)
             -0.0036044078*PriceSeries(IPC,bar-62,open,low,high,close)
             -0.0033446882*PriceSeries(IPC,bar-63,open,low,high,close)
             -0.0030621605*PriceSeries(IPC,bar-64,open,low,high,close)
             -0.0027641559*PriceSeries(IPC,bar-65,open,low,high,close)
             -0.0024589320*PriceSeries(IPC,bar-66,open,low,high,close)
             -0.0021527365*PriceSeries(IPC,bar-67,open,low,high,close)
             -0.0018521222*PriceSeries(IPC,bar-68,open,low,high,close)
             -0.0015616524*PriceSeries(IPC,bar-69,open,low,high,close)
             -0.0012859688*PriceSeries(IPC,bar-70,open,low,high,close)
             -0.0010285368*PriceSeries(IPC,bar-71,open,low,high,close)
             -0.0007921495*PriceSeries(IPC,bar-72,open,low,high,close)
             -0.0005786502*PriceSeries(IPC,bar-73,open,low,high,close)
             -0.0003899810*PriceSeries(IPC,bar-74,open,low,high,close)
             -0.0002262453*PriceSeries(IPC,bar-75,open,low,high,close)
             -0.0000882844*PriceSeries(IPC,bar-76,open,low,high,close)
             +0.0000251537*PriceSeries(IPC,bar-77,open,low,high,close)
             +0.0001141964*PriceSeries(IPC,bar-78,open,low,high,close)
             +0.0001810281*PriceSeries(IPC,bar-79,open,low,high,close)
             +0.0002266104*PriceSeries(IPC,bar-80,open,low,high,close)
             +0.0002536520*PriceSeries(IPC,bar-81,open,low,high,close)
             +0.0002635807*PriceSeries(IPC,bar-82,open,low,high,close)
             +0.0002592130*PriceSeries(IPC,bar-83,open,low,high,close)
             +0.0014236495*PriceSeries(IPC,bar-84,open,low,high,close);

      STLMBuffer[bar]=value3-value4;
      FTLMBuffer[bar]=value1-value2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries
(
 uint applied_price,// Ценовая константа
 uint   bar,// Индекс сдвига относительно текущего бара на указанное количество периодов назад или вперёд).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----         
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];
         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
