//+------------------------------------------------------------------+
//|                                             FractalsNoRedraw.mq5 |
//|                                                         Tapochun |
//|                           https://www.mql5.com/ru/users/tapochun |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property copyright "Tapochun"
#property link      "https://www.mql5.com/ru/users/tapochun"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//---
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrWhite
#property indicator_label1  "Fractal_nr Up"
#property indicator_width1  1
//---
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrWhite
#property indicator_label2  "Fractal_nr Dn"
#property indicator_width2  1
//---- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_FRACTAL      // Перечисление - типы фракталов
  {
   UP, // Фрактал вверх
   DN  // Фрактал вниз
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);   // Точность отображения индикатора
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
  }
//+------------------------------------------------------------------+
//|  Accelerator/Decelerator Oscillator                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,// Текущее количество просчитанных свечей
                const int prev_calculated,// Количество просчитанных свечей на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Если фракталов меньше, чем необходимо для формирования фрактала
   if(rates_total<5) return(0);         // Возвращаем 0 (будет записано в prev_calculated на след. тике)
//---
   if(prev_calculated<=0) // Если первый запуск					
     {                    // Рисуем предыдущие фракталы
      //--- Устанавливаем пустые значения всех элементов массивов
      ArrayInitialize( ExtUpperBuffer, EMPTY_VALUE );   // Цены фракталов вверх
      ArrayInitialize( ExtLowerBuffer, EMPTY_VALUE );   // Цены фракталов вниз
      //---
      for(int i=2; i<rates_total-3; i++) // Цикл по просчитанным свечам
        {
         CheckFractal(UP,i,ExtUpperBuffer,high);        // Проверяем фрактал вверх
         CheckFractal(DN,i,ExtLowerBuffer,low);         // Проверяем фрактал вниз
        }
      return( rates_total );
     }
   else                               // Если не первый запуск
     {
      if(rates_total>prev_calculated) // Если образовался новый бар
        {
         //--- Очищаем значения фракталов на текущем баре
         ExtUpperBuffer[ rates_total-1 ] = EMPTY_VALUE;
         ExtLowerBuffer[ rates_total-1 ] = EMPTY_VALUE;
         //--- Проверяем, образовался ли новый фрактал на баре rates_total-4 (третий сформированный с конца)
         CheckFractal(UP,rates_total-4,ExtUpperBuffer,high);   // Проверяем фрактал вверх
         CheckFractal(DN,rates_total-4,ExtLowerBuffer,low);    // Проверяем фрактал вниз
        }
      return( rates_total );
     }
//---
   return(rates_total); // Возвращаем количество просчитанных баров на текущем тике
  }
//+------------------------------------------------------------------+
//| Проверяем наличие фрактала на i свече типа type                  |
//+------------------------------------------------------------------+
void CheckFractal(const ENUM_FRACTAL type, // Тип фрактала, который ищем
                  const int i,             // Номер свечи на которой ищем
                  double &buffer[],        // Буфер значений фракталов (out)
                  const double &price[])   // Соответствующие цены
  {
//--- Короткие имена (для удобства)
   double p=price[i];                  // Цена проверяемого экстремума (rates_total-4)
   double pf_1 = price[ i+1 ];         // Цена последующего первого
   double pf_2 = price[ i+2 ];         // Цена последующего второго (первого сформированного/rates_total-2)
   double pp_1 = price[ i-1 ];         // Цена предыдущего первого
   double pp_2 = price[ i-2 ];         // Цена предыдущего второго (rates_total-6)
//---
   if(type==UP) // Проверяем фрактал вверх	
     {
      if(p>pf_1 && p>pf_2 && p>=pp_1 && p>=pp_2)
         ExtUpperBuffer[i]=price[i];   // Запоминаем значение фрактала вверх
      //---
      return;
     }
//---
   if(type==DN) // Проверяем фрактал вниз
     {
      if(p<pf_1 && p<pf_2 && p<=pp_1 && p<=pp_2)
         ExtLowerBuffer[i]=price[i];   // Запоминаем значение фрактала вниз
      //---
      return;
     }
//--- Если передан неизвестный тип фрактала
   Print(__FUNCTION__,": ОШИБКА! Передан неизвестный тип фрактала: "+EnumToString(type));
   return;
  }
//+------------------------------------------------------------------+
