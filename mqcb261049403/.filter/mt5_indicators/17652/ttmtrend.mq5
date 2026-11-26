//+------------------------------------------------------------------+ 
//|                                                    ttm-trend.mq5 | 
//|                                     Copyright © 2005, Nick Bilak | 
//|                                              beluck[AT]gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Nick Bilak"
#property link "beluck[AT]gmail.com" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrDeepPink,clrPurple,clrGray,clrTeal,clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "ttm-trend"
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint CompBars=6;
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[],ColorIndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double haOpen[],haClose[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+    
//| ttm-trend indicator initialization function                      | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(CompBars+1);

//---- распределение памяти под массивы переменных  
   ArrayResize(Count,CompBars);
   ArrayResize(haOpen,CompBars);
   ArrayResize(haClose,CompBars);
//---- обнулим содержимое массивов   
   ArrayInitialize(Count,0);
   ArrayInitialize(haOpen,0.0);
   ArrayInitialize(haClose,0.0);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer,true);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"ttm-trend");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| ttm-trend iteration function                                     | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных
   int limit,bar;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Close,true);

//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров 
      int barc=limit+int(CompBars-1);
      haOpen[Count[0]]=Open[barc];
      haClose[Count[0]]=(Open[barc]+High[barc]+Low[barc]+Close[barc])/4.0;
      Recount_ArrayZeroPos(Count,CompBars);

      for(int index=int(CompBars-1)-1; index>=0 && !IsStopped(); index--)
        {
         int barl=limit+index;
         haOpen[Count[0]]=(haOpen[Count[1]]+haClose[Count[1]])/2.0;
         haClose[Count[0]]=(Open[barl]+High[barl]+Low[barl]+Close[barl])/4.0;
         Recount_ArrayZeroPos(Count,CompBars);
        }
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpIndBuffer[bar]=High[bar];
      DnIndBuffer[bar]=Low[bar];
     }

//---- Основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      haOpen[Count[0]]=(haOpen[Count[1]]+haClose[Count[1]])/2.0;
      haClose[Count[0]]=(Open[bar]+High[bar]+Low[bar]+Close[bar])/4.0;
      //----
      int clr=2;
      if(haClose[Count[0]]>haOpen[Count[0]])
        {
         if(Open[bar]<=Close[bar]) clr=4;
         if(Open[bar]>Close[bar]) clr=3;
        }

      if(haClose[Count[0]]<haOpen[Count[0]])
        {
         if(Open[bar]>Close[bar]) clr=0;
         if(Open[bar]<=Close[bar]) clr=1;
        }

      for(int index=1; index<int(CompBars); index++)
        {
         double HH=MathMax(haOpen[Count[index]],haClose[Count[index]]);
         double LL=MathMin(haOpen[Count[index]],haClose[Count[index]]);

         if(haOpen[Count[0]]<=HH && haOpen[Count[0]]>=LL
            && haClose[Count[0]]<=HH && haClose[Count[0]]>=LL)
           {
            clr=int(ColorIndBuffer[bar+index]);
            break;
           }
        }

      ColorIndBuffer[bar]=clr;
      if(bar) Recount_ArrayZeroPos(Count,CompBars);
     }
//----     
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
