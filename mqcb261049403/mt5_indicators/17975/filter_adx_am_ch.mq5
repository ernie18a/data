//+------------------------------------------------------------------+
//|                                             FILTER_ADX_AM_ch.mq5 |
//|                             Copyright © 2009, Andrey Matvievskiy |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2009, Andrey Matvievskiy"
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде значка
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета бычьего значка индикатора использован зелёный цвет
#property indicator_color1  clrLime
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина значка индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычьего метки индикатора
#property indicator_label1  "Weak Upper Trend"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде значка
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета медвежьего значка индикатора использован красный цвет
#property indicator_color2  clrRed
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина значка индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьего метки индикатора
#property indicator_label2  "Weak Lower Trend"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычьего значка индикатора использован зелёный цвет
#property indicator_color3  clrLime
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина значка индикатора 3 равна 3
#property indicator_width3  3
//---- отображение бычьего метки индикатора
#property indicator_label3  "Stronge Upper Trend"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьего значка индикатора использован красный цвет
#property indicator_color4  clrRed
//---- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина значка индикатора 4 равна 3
#property indicator_width4  3
//---- отображение медвежьего метки индикатора
#property indicator_label4  "Stronge Lower Trend"
//+----------------------------------------------+
//| Высота окна индикатора                       |
//+----------------------------------------------+
#property indicator_height 20
//+----------------------------------------------+
//| Вертикальные пределы изменения индикатора    |
//+----------------------------------------------+
#property indicator_minimum 0
#property indicator_maximum 1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int    period = 14;
input double alpha1 = 0.25;
input double alpha2 = 0.33;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtMapBuffer1[],ExtMapBuffer2[],ExtMapBuffer3[],ExtMapBuffer4[];
//---- Объявление целых переменных для хендлов индикаторов
int ADX_Handle,ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- получение хендла индикатора ADX
   ADX_Handle=iADX(NULL,0,period);
   if(ADX_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ADX");
      return(INIT_FAILED);
     }

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=period+2;
   int ATR_Period=15;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+1;
   
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtMapBuffer1,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtMapBuffer2,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtMapBuffer3,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtMapBuffer3,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtMapBuffer4,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4 на min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtMapBuffer4,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"FILTER_ADX_AM(",period,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ADX_Handle)<rates_total 
     || BarsCalculated(ATR_Handle)<rates_total
     || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit,to_copy,bar;
   double ADX[],DIP[],DIM[],ATR[];
   double DiPlus,DiMinus,Adx,xDiPlus,xDiMinus,xAdx;
   static double DiPlus_prev,DiMinus_prev,Adx_prev,xDiPlus_prev,xDiMinus_prev,xAdx_prev;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ADX,true);
   ArraySetAsSeries(DIP,true);
   ArraySetAsSeries(DIM,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-2; // стартовый номер для расчёта всех баров
      DiPlus_prev=DiMinus_prev=Adx_prev=xDiPlus_prev=xDiMinus_prev=xAdx_prev=NULL;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

   to_copy=limit+2;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ADX_Handle,0,0,to_copy,ADX)<=0) return(RESET);
   if(CopyBuffer(ADX_Handle,1,0,to_copy,DIP)<=0) return(RESET);
   if(CopyBuffer(ADX_Handle,2,0,to_copy,DIM)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Инициализация индикаторных буферов
      ExtMapBuffer4[bar]=ExtMapBuffer3[bar]=ExtMapBuffer2[bar]=ExtMapBuffer1[bar]=NULL;
      
      DiPlus=2*DIP[bar]+(alpha1-2)*DIP[bar+1]+(1-alpha1)*DiPlus_prev;
      DiMinus=2*DIM[bar]+(alpha1-2)*DIM[bar+1]+(1-alpha1)*DiMinus_prev;
      Adx=2*ADX[bar]+(alpha1-2)*ADX[bar+1]+(1-alpha1)*Adx_prev;

      xDiPlus=alpha2*DiPlus+(1-alpha2)*xDiPlus_prev;
      xDiMinus=alpha2*DiMinus+(1-alpha2)*xDiMinus_prev;
      xAdx=alpha2*Adx+(1-alpha2)*xAdx_prev;

      if(xDiPlus<xDiMinus)
        {
         if(xAdx>=xAdx_prev) ExtMapBuffer4[bar]=high[bar]+ATR[bar]*3/8;
         else ExtMapBuffer2[bar]=high[bar]+ATR[bar]*3/8;
        }

      if(xDiPlus>xDiMinus)
        {
         if(xAdx>=xAdx_prev) ExtMapBuffer3[bar]=low[bar]-ATR[bar]*3/8;
         else ExtMapBuffer1[bar]=low[bar]-ATR[bar]*3/8;
        }
        
      if(bar)
        {
         DiPlus_prev=DiPlus;
         DiMinus_prev=DiMinus;
         Adx_prev=Adx;
         xDiPlus_prev=xDiPlus;
         xDiMinus_prev=xDiMinus;
         xAdx_prev=xAdx;       
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
