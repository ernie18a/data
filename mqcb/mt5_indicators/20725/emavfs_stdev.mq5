//+------------------------------------------------------------------+
//|                                                 EMAVFS_StDev.mq5 | 
///|                             Copyright © 2018, Станислав Булашев |
//|                         http://stan.okis.ru/file/stan/EMAVFS.pdf | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Станислав Булашев"
#property link "http://stan.okis.ru/file/stan/EMAVFS.pdf" 
#property description "Экспоненциальная скользящая средняя с переменным фактором сглаживания"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки линии индикатора        |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color1  clrMagenta,clrGray,clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "EMAVFS"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color2  clrRed
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Dn_Signal 1"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован аквамариновый цвет
#property indicator_color3  clrAqua
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение бычей метки индикатора
#property indicator_label3  "Up_Signal 1"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color4  clrRed
//---- толщина линии индикатора 4 равна 4
#property indicator_width4  4
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Dn_Signal 2"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован аквамариновый цвет
#property indicator_color5  clrAqua
//---- толщина линии индикатора 5 равна 4
#property indicator_width5  4
//---- отображение бычей метки индикатора
#property indicator_label5  "Up_Signal 2"
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
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
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input double Wmin=0;                      // минимальная чувствительность  
input double Wmax=5;                      // максимальная чувствительность
input double Efactor=1.01;                // коэффициент E (менять значение около единицы на десятые и сотые доли) 
input double Afactor=1.001;               // степень A (менять значение около единицы на десятые и сотые доли)                   
input Applied_price_ IPC=PRICE_CLOSE_;    // ценовая константа
input int PriceShift=0;               // cдвиг по вертикали в пунктах
input double dK1=2.001;               // коэффициент 1 для квадратичного фильтра
input double dK2=4.001;               // коэффициент 2 для квадратичного фильтра
input uint std_period=9;              // период квадратичного фильтра
input int Shift=0;                    // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer[],ColorExtLineBuffer[];
double BearsBuffer1[],BullsBuffer1[];
double BearsBuffer2[],BullsBuffer2[];
int start;
double dPriceShift,dEMAVFS[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- проверка входных переменных индикатора на корректность
   if(dK1>=dK2)
     {
      Print(" Некрректные значения входных параметров для коэффициентов 1 и 2 для квадратичного фильтра!");
      return(INIT_FAILED);
     }

//---- инициализация переменных 
   start=2+int(std_period);
//---- Распределение памяти под массивы переменных  
   ArrayResize(dEMAVFS,std_period);
//---- инициализации переменной для короткого имени индикатора
   string shortname="EMAVFS_StDev";
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(2,BearsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(3,BullsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(4,BearsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,start);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(5,BullsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,start);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<start) return(0);

//---- объявления локальных переменных 
   int first,bar,clr;
   double series,wema,w;
   static double wema_prew;
   double SMAdif,Sum,StDev,dstd,BEARS1,BULLS1,BEARS2,BULLS2,Filter1,Filter2;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=1; // стартовый номер для расчёта всех баров
      wema_prew=PriceSeries(IPC,first-1,open,low,high,close);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      series=PriceSeries(IPC,bar,open,low,high,close);     
      w=Wmin+(Wmax-Wmin)*(1.0-MathExp(-MathPow(MathAbs(series-wema_prew/Efactor),Afactor)));
      wema=wema_prew+w*(series-wema_prew);
      ExtLineBuffer[bar]=wema+dPriceShift;
      if(bar<rates_total-1) wema_prew=wema;
     }

//---- пересчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first++;

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=1;
      if(ExtLineBuffer[bar-1]<ExtLineBuffer[bar]) clr=2;
      if(ExtLineBuffer[bar-1]>ExtLineBuffer[bar]) clr=0;
      ColorExtLineBuffer[bar]=clr;
     }

//---- пересчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=start;
//---- основной цикл расчёта индикатора стандартных отклонений
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- загружаем приращения индикатора в массив для промежуточных вычислений
      for(int iii=0; iii<int(std_period); iii++) {dEMAVFS[iii]=ExtLineBuffer[bar-iii]-ExtLineBuffer[bar-iii-1];}

      //---- находим простое среднее приращений индикатора
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dEMAVFS[iii];
      SMAdif=Sum/std_period;

      //---- находим сумму квадратов разностей приращений и среднего
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dEMAVFS[iii]-SMAdif,2);

      //---- определяем итоговое значение среднеквадратичного отклонения StDev от приращения индикатора
      StDev=MathSqrt(Sum/std_period);

      //---- инициализация переменных
      dstd=NormalizeDouble(dEMAVFS[0],_Digits+2);
      Filter1=NormalizeDouble(dK1*StDev,_Digits+2);
      Filter2=NormalizeDouble(dK2*StDev,_Digits+2);
      BEARS1=EMPTY_VALUE;
      BULLS1=EMPTY_VALUE;
      BEARS2=EMPTY_VALUE;
      BULLS2=EMPTY_VALUE;
      wema=ExtLineBuffer[bar];

      //---- вычисление индикаторных значений
      if(dstd<-Filter1 && dstd>=-Filter2) BEARS1=wema; //есть нисходящий тренд
      if(dstd<-Filter2) BEARS2=wema; //есть нисходящий тренд
      if(dstd>+Filter1 && dstd<=+Filter2) BULLS1=wema; //есть восходящий тренд
      if(dstd>+Filter2) BULLS2=wema; //есть восходящий тренд

      //---- инициализация ячеек индикаторных буферов полученными значениями 
      BullsBuffer1[bar]=BULLS1;
      BearsBuffer1[bar]=BEARS1;
      BullsBuffer2[bar]=BULLS2;
      BearsBuffer2[bar]=BEARS2;
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
 const double &dOpen[],
 const double &dLow[],
 const double &dHigh[],
 const double &dClose[]
 )
//PriceSeries(applied_price, bar, dOpen, dLow, dHigh, dClose)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(dClose[bar]);
      case  PRICE_OPEN: return(dOpen [bar]);
      case  PRICE_HIGH: return(dHigh [bar]);
      case  PRICE_LOW: return(dLow[bar]);
      case  PRICE_MEDIAN: return((dHigh[bar]+dLow[bar])/2.0);
      case  PRICE_TYPICAL: return((dClose[bar]+dHigh[bar]+dLow[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*dClose[bar]+dHigh[bar]+dLow[bar])/4.0);

      //----                            
      case  8: return((dOpen[bar] + dClose[bar])/2.0);
      case  9: return((dOpen[bar] + dClose[bar] + dHigh[bar] + dLow[bar])/4.0);
      //----                                
      case 10:
        {
         if(dClose[bar]>dOpen[bar])return(dHigh[bar]);
         else
           {
            if(dClose[bar]<dOpen[bar])
               return(dLow[bar]);
            else return(dClose[bar]);
           }
        }
      //----         
      case 11:
        {
         if(dClose[bar]>dOpen[bar])return((dHigh[bar]+dClose[bar])/2.0);
         else
           {
            if(dClose[bar]<dOpen[bar])
               return((dLow[bar]+dClose[bar])/2.0);
            else return(dClose[bar]);
           }
         break;
        }
      //----         
      case 12:
        {
         double res=dHigh[bar]+dLow[bar]+dClose[bar];
         if(dClose[bar]<dOpen[bar]) res=(res+dLow[bar])/2;
         if(dClose[bar]>dOpen[bar]) res=(res+dHigh[bar])/2;
         if(dClose[bar]==dOpen[bar]) res=(res+dClose[bar])/2;
         return(((res-dLow[bar])+(res-dHigh[bar]))/2);
        }
      //----
      default: return(dClose[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+