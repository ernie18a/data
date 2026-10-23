//+---------------------------------------------------------------------+ 
//|                                                       ColorSTLM.mq5 | 
//|                                  Copyright © 2013, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2013, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link      "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора STLM          |
//+----------------------------------------------+
//---- отрисовка индикатора STLM в виде цветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов пятицветной гистограммы использованы
#property indicator_color1 clrRed,clrMagenta,clrGray,clrTeal,clrSpringGreen
//---- линия индикатора-непрерывная кривая
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "STLM HISTOGRAM"
//+----------------------------------------------+
//| Параметры отрисовки индикатора STLM          |
//+----------------------------------------------+
//---- отрисовка индикатора FTLM в виде линии
#property indicator_type2 DRAW_LINE
//---- в качестве цвета сигнальной линии использован серый цвет
#property indicator_color2 clrGray
//---- линия индикатора-штрихпунктирная кривая
#property indicator_style2 STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2 2
//---- отображение метки сигнальной линии
#property indicator_label2  "STLM"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrBlueViolet
#property indicator_levelstyle STYLE_SOLID
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int JLength=3;   // Глубина сглаживания                   
input int JPhase=100;  // Параметр сглаживания
                       // изменяющийся в пределах -100 ... +100,
                       // влияет на качество переходного процесса
input int STLMShift=0; // Сдвиг STLM по горизонтали в барах
//+----------------------------------------------+
//---- объявление и инициализация переменной для хранения количества расчетных баров
int STLMPeriod=91;
//---- объявление динамического массивoв, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[],IndBuffer_[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Описание класса CJJMA                                             |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=STLMPeriod+1+30;
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,IndBuffer_,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,STLMPeriod);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,STLMPeriod);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализации переменной для короткого имени индикатора
   string shortname="STLM";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,1);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // количество истории в барах на текущем тике
                const int prev_calculated, // количество истории в барах на предыдущем тике
                const int begin,           // номер начала достоверного отсчета баров
                const double &price[])     // ценовой массив для расчета индикатора
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(0);
//---- объявления локальных переменных 
   int first,bar;
   double STLM,JSTLM,value1,value2,clr;
   static int minbar;
//---- объявление переменной класса JJMA из файла JJMASeries_Cls.mqh
   static CJJMA JMA;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=STLMPeriod-1+begin;  // стартовый номер для расчета всех баров
      minbar=first;
      //---- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0)
        {
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+min_rates_total);
         PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,begin+min_rates_total);
        }
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора STLM
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      value1=
             +0.0982862174*price[bar-0]
             +0.0975682269*price[bar-1]
             +0.0961401078*price[bar-2]
             +0.0940230544*price[bar-3]
             +0.0912437090*price[bar-4]
             +0.0878391006*price[bar-5]
             +0.0838544303*price[bar-6]
             +0.0793406350*price[bar-7]
             +0.0743569346*price[bar-8]
             +0.0689666682*price[bar-9]
             +0.0632381578*price[bar-10]
             +0.0572428925*price[bar-11]
             +0.0510534242*price[bar-12]
             +0.0447468229*price[bar-13]
             +0.0383959950*price[bar-14]
             +0.0320735368*price[bar-15]
             +0.0258537721*price[bar-16]
             +0.0198005183*price[bar-17]
             +0.0139807863*price[bar-18]
             +0.0084512448*price[bar-19]
             +0.0032639979*price[bar-20]
             -0.0015350359*price[bar-21]
             -0.0059060082*price[bar-22]
             -0.0098190256*price[bar-23]
             -0.0132507215*price[bar-24]
             -0.0161875265*price[bar-25]
             -0.0186164872*price[bar-26]
             -0.0205446727*price[bar-27]
             -0.0219739146*price[bar-28]
             -0.0229204861*price[bar-29]
             -0.0234080863*price[bar-30]
             -0.0234566315*price[bar-31]
             -0.0231017777*price[bar-32]
             -0.0223796900*price[bar-33]
             -0.0213300463*price[bar-34]
             -0.0199924534*price[bar-35]
             -0.0184126992*price[bar-36]
             -0.0166377699*price[bar-37]
             -0.0147139428*price[bar-38]
             -0.0126796776*price[bar-39]
             -0.0105938331*price[bar-40]
             -0.0084736770*price[bar-41]
             -0.0063841850*price[bar-42]
             -0.0043466731*price[bar-43]
             -0.0023956944*price[bar-44]
             -0.0005535180*price[bar-45]
             +0.0011421469*price[bar-46]
             +0.0026845693*price[bar-47]
             +0.0040471369*price[bar-48]
             +0.0052380201*price[bar-49]
             +0.0062194591*price[bar-50]
             +0.0070340085*price[bar-51]
             +0.0076266453*price[bar-52]
             +0.0080376628*price[bar-53]
             +0.0083037666*price[bar-54]
             +0.0083694798*price[bar-55]
             +0.0082901022*price[bar-56]
             +0.0080741359*price[bar-57]
             +0.0077543820*price[bar-58]
             +0.0073260526*price[bar-59]
             +0.0068163569*price[bar-60]
             +0.0062325477*price[bar-61]
             +0.0056078229*price[bar-62]
             +0.0049516078*price[bar-63]
             +0.0161380976*price[bar-64];
      //----
      value2=
             -0.0074151919*price[bar-0]
             -0.0060698985*price[bar-1]
             -0.0044979052*price[bar-2]
             -0.0027054278*price[bar-3]
             -0.0007031702*price[bar-4]
             +0.0014951741*price[bar-5]
             +0.0038713513*price[bar-6]
             +0.0064043271*price[bar-7]
             +0.0090702334*price[bar-8]
             +0.0118431116*price[bar-9]
             +0.0146922652*price[bar-10]
             +0.0175884606*price[bar-11]
             +0.0204976517*price[bar-12]
             +0.0233865835*price[bar-13]
             +0.0262218588*price[bar-14]
             +0.0289681736*price[bar-15]
             +0.0315922931*price[bar-16]
             +0.0340614696*price[bar-17]
             +0.0363444061*price[bar-18]
             +0.0384120882*price[bar-19]
             +0.0402373884*price[bar-20]
             +0.0417969735*price[bar-21]
             +0.0430701377*price[bar-22]
             +0.0440399188*price[bar-23]
             +0.0446941124*price[bar-24]
             +0.0450230100*price[bar-25]
             +0.0450230100*price[bar-26]
             +0.0446941124*price[bar-27]
             +0.0440399188*price[bar-28]
             +0.0430701377*price[bar-29]
             +0.0417969735*price[bar-30]
             +0.0402373884*price[bar-31]
             +0.0384120882*price[bar-32]
             +0.0363444061*price[bar-33]
             +0.0340614696*price[bar-34]
             +0.0315922931*price[bar-35]
             +0.0289681736*price[bar-36]
             +0.0262218588*price[bar-37]
             +0.0233865835*price[bar-38]
             +0.0204976517*price[bar-39]
             +0.0175884606*price[bar-40]
             +0.0146922652*price[bar-41]
             +0.0118431116*price[bar-42]
             +0.0090702334*price[bar-43]
             +0.0064043271*price[bar-44]
             +0.0038713513*price[bar-45]
             +0.0014951741*price[bar-46]
             -0.0007031702*price[bar-47]
             -0.0027054278*price[bar-48]
             -0.0044979052*price[bar-49]
             -0.0060698985*price[bar-50]
             -0.0074151919*price[bar-51]
             -0.0085278517*price[bar-52]
             -0.0094111161*price[bar-53]
             -0.0100658241*price[bar-54]
             -0.0104994302*price[bar-55]
             -0.0107227904*price[bar-56]
             -0.0107450280*price[bar-57]
             -0.0105824763*price[bar-58]
             -0.0102517019*price[bar-59]
             -0.0097708805*price[bar-60]
             -0.0091581551*price[bar-61]
             -0.0084345004*price[bar-62]
             -0.0076214397*price[bar-63]
             -0.0067401718*price[bar-64]
             -0.0058083144*price[bar-65]
             -0.0048528295*price[bar-66]
             -0.0038816271*price[bar-67]
             -0.0029244713*price[bar-68]
             -0.0019911267*price[bar-69]
             -0.0010974211*price[bar-70]
             -0.0002535559*price[bar-71]
             +0.0005231953*price[bar-72]
             +0.0012297491*price[bar-73]
             +0.0018539149*price[bar-74]
             +0.0023994354*price[bar-75]
             +0.0028490136*price[bar-76]
             +0.0032221429*price[bar-77]
             +0.0034936183*price[bar-78]
             +0.0036818974*price[bar-79]
             +0.0038037944*price[bar-80]
             +0.0038338964*price[bar-81]
             +0.0037975350*price[bar-82]
             +0.0036986051*price[bar-83]
             +0.0035521320*price[bar-84]
             +0.0033559226*price[bar-85]
             +0.0031224409*price[bar-86]
             +0.0028550092*price[bar-87]
             +0.0025688349*price[bar-88]
             +0.0022682355*price[bar-89]
             +0.0073925495*price[bar-90];
      //---
      STLM=value1-value2;
      JSTLM=JMA.JJMASeries(minbar,prev_calculated,rates_total,0,JPhase,JLength,STLM,bar,false);
      //---- инициализация ячейки индикаторного буфера полученным значением FTLM
      IndBuffer[bar]=JSTLM;
      IndBuffer_[bar]=JSTLM;
     }
//---
   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//---- основной цикл раскраски
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=2;
      //---
      if(IndBuffer[bar]>0) if(IndBuffer[bar-1]>IndBuffer[bar]) clr=3; else clr=4;
      if(IndBuffer[bar]<0) if(IndBuffer[bar-1]<IndBuffer[bar]) clr=1; else clr=0;
      //---
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
