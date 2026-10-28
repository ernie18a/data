//+------------------------------------------------------------------+ 
//|                                               EMAVFS_channel.mq5 | 
//|                              Copyright © 2018, Станислав Булашев |
//|                         http://stan.okis.ru/file/stan/EMAVFS.pdf | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Станислав Булашев"
#property link "http://stan.okis.ru/file/stan/EMAVFS.pdf" 
#property description "Канал с использованием экспоненциальной скользящей средней с переменным фактором сглаживания"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 3 
//---- использовано всего одно графическое построение
#property indicator_plots   3
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован clrDodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1  "EMAVFS Max"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован clrSlateGray цвет
#property indicator_color2 clrSlateGray
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2 1
//---- отображение метки индикатора
#property indicator_label2  "EMAVFS"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован clrDeepPink цвет
#property indicator_color3 clrDeepPink
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3 2
//---- отображение метки индикатора
#property indicator_label3  "EMAVFS Min"
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLdLow0_,  //TrendFoldLow_1 Price 
   PRICE_TRENDFOLdLow1_,  //TrendFoldLow_2 Price 
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
input int Shift=0;                        // сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                   // cдвиг индикатора по вертикали в пунктах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer1[],IndBuffer2[],IndBuffer3[];
double dPriceShift;
//---- Объявление глобальных переменных
int min_rates_total;
//+------------------------------------------------------------------+    
//| EMA indicator initialization function                            | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- индексация элементов в буфере не как в таймсерии!
   ArraySetAsSeries(IndBuffer1,false);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,IndBuffer2,INDICATOR_DATA);
//---- индексация элементов в буфере не как в таймсерии!
   ArraySetAsSeries(IndBuffer2,false);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer3,INDICATOR_DATA);
//---- индексация элементов в буфере не как в таймсерии!
   ArraySetAsSeries(IndBuffer3,false);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);   
   
//---- инициализации переменной для короткого имени индикатора
   string shortname="EMAVFS_channel";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| EMA iteration function                                           | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление локальных переменных
   int first,bar;
   double series,wema,w,eval,ERROR;
   static double wema_prew;
   
//---- индексация элементов в массивах не как в таймсериях  
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);

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
      IndBuffer2[bar]=wema+dPriceShift;
      //----
      eval=series-wema;
      ERROR=wema*MathAbs(eval);
      IndBuffer1[bar]=IndBuffer2[bar]+ERROR;
      IndBuffer3[bar]=IndBuffer2[bar]-ERROR;
      //----
      if(bar<rates_total-1) wema_prew=wema;
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
