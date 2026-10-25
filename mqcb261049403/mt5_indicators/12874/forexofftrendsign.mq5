//+------------------------------------------------------------------+ 
//|                                            ForexOFFTrendSign.mq5 | 
//|                        Copyright © 2006, rewritten by CrazyChart | 
//|                                                  http://viac.ru/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, rewritten by CrazyChart"
#property link "http://viac.ru/"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в основном окне
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
//--- в качестве цвета медвежьей линии индикатора использован Orchid цвет
#property indicator_color1  clrOrchid
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "ForexOFFTrendSign Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован LimeGreen цвет
#property indicator_color2  clrLimeGreen
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "ForexOFFTrendSign Buy"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint    SSP = 7;         // Период поиска экстремумов
input uint   KPer = 7;         // Период сдвига сигнальной огибающей 
input double Kmax = 50.6;
input int   Shift=0;           // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int  min_rates_total,KPer3;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//--- объявление глобальных переменных
int Count[];
double Value[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//---
   int numb,Max1,Max2;
   static int count=1;
//---
   Max2=Size;
   Max1=Max2-1;
//---
   count--;
   if(count<0) count=Max1;
//---
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(SSP,KPer)+KPer);
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,min_rates_total))+3;
   KPer3=int(KPer+3);
//--- распределение памяти под массивы переменных  
   ArrayResize(Count,KPer3);
   ArrayResize(Value,KPer3);
   ArrayInitialize(Count,0);
   ArrayInitialize(Value,0.0);
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
   PlotIndexSetInteger(0,PLOT_ARROW,93);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,93);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"ForexOFFTrendSign("+string(SSP)+")");
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
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявление переменных с плавающей точкой  
   double HH,LL,ATR[1];
//--- объявление целочисленных переменных
   int limit;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-int(MathMax(SSP,KPer))-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated;        // стартовый номер для расчета только новых баров
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HH=High[ArrayMaximum(High,bar,SSP)];
      LL=Low[ArrayMinimum(Low,bar,SSP)];
      Value[Count[0]]=HH-(HH-LL)*Kmax/100;
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---      
      if(Value[Count[1]]<=Value[Count[KPer+1]] && Value[Count[0]]>Value[Count[KPer]])
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,Time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=Low[bar]-ATR[0]*3/8;
        }
      //---   
      if(Value[Count[1]]>=Value[Count[KPer+1]] && Value[Count[0]]<Value[Count[KPer]])
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,Time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=High[bar]+ATR[0]*3/8;
        }
      //---        
      if(bar) Recount_ArrayZeroPos(Count,KPer3);
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
