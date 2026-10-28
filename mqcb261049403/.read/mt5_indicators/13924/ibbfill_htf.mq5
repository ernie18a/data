//+------------------------------------------------------------------+ 
//|                                                  iBBFill_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "iBBFill с возможностью изменения таймфрейма во входных параметрах"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window
//--- количество индикаторных буферов 10
#property indicator_buffers 10
//--- использовано шесть графических построений
#property indicator_plots  6
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                   // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "iBBFill"  // константа для имени индикатора
#define SIZECL 3                  // константа для количества вызовов функции CountCloudIndicator в коде
#define SIZEL 3                   // константа для количества вызовов функции CountLineIndicator в коде
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цвета индикатора использован
#property indicator_color1  C'10,10,70'
//--- отображение метки индикатора
#property indicator_label1  "UpTrend"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//--- в качестве цвета индикатора использован
#property indicator_color2  C'70,10,10'
//--- отображение метки индикатора
#property indicator_label2  "DnTrend"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type3   DRAW_FILLING
//--- в качестве цвета индикатора использован
#property indicator_color3  C'50,50,50'
//--- отображение метки индикатора
#property indicator_label3  "Flat"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 4             |
//+----------------------------------------------+
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован Yellow цвет
#property indicator_color4 clrYellow
//---- линия индикатора - сплошная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4  2
//---- отображение метки индикатора
#property indicator_label4  "BB MA"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 5             |
//+----------------------------------------------+
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color5 clrDodgerBlue
//---- линия индикатора - сплошная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width5  2
//---- отображение метки индикатора
#property indicator_label5  "BB Upper"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 6             |
//+----------------------------------------------+
#property indicator_type6   DRAW_LINE
//---- в качестве цвета линии индикатора использован Redцвет
#property indicator_color6 clrRed
//---- линия индикатора - сплошная кривая
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width6  2
//---- отображение метки индикатора
#property indicator_label6  "BB Lower"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;       // Период графика индикатора (таймфрейм)
input uint                 BBPeriod=20;          // Период BB
input double              BBDeviation=2;         // Ширина BB
input ENUM_APPLIED_PRICE  BBPrice=PRICE_CLOSE;   // Цена BB
input int Shift=0;                               // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double UpIndBuffer1[],DnIndBuffer1[];
double UpIndBuffer2[],DnIndBuffer2[];
double UpIndBuffer3[],DnIndBuffer3[];
double IndBuffer1[];
double IndBuffer2[];
double IndBuffer3[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора iBBFill
   Ind_Handle=iCustom(Symbol(),TimeFrame,"iBBFill",BBPeriod,BBDeviation,BBPrice);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iBBFill");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,UpIndBuffer1,INDICATOR_DATA);
   IndInit(1,DnIndBuffer1,INDICATOR_DATA);
   IndInit(2,UpIndBuffer2,INDICATOR_DATA);
   IndInit(3,DnIndBuffer2,INDICATOR_DATA);
   IndInit(4,UpIndBuffer3,INDICATOR_DATA);
   IndInit(5,DnIndBuffer3,INDICATOR_DATA);
   IndInit(6,IndBuffer1,INDICATOR_DATA);
   IndInit(7,IndBuffer2,INDICATOR_DATA);
   IndInit(8,IndBuffer3,INDICATOR_DATA);
//--- инициализация индикаторов
   for(int count=0; count<6; count++) PlotInit(count,0,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   if(!CountCloudIndicator(0,NULL,TimeFrame,Ind_Handle,0,UpIndBuffer1,1,DnIndBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountCloudIndicator(1,NULL,TimeFrame,Ind_Handle,2,UpIndBuffer2,3,DnIndBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountCloudIndicator(2,NULL,TimeFrame,Ind_Handle,4,UpIndBuffer3,5,DnIndBuffer3,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountLineIndicator(0,NULL,TimeFrame,Ind_Handle,6,IndBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountLineIndicator(1,NULL,TimeFrame,Ind_Handle,7,IndBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountLineIndicator(2,NULL,TimeFrame,Ind_Handle,8,IndBuffer3,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void PlotInit(int Number,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---
  }
//+------------------------------------------------------------------+
//| CountCloudIndicator                                              |
//+------------------------------------------------------------------+
bool CountCloudIndicator(uint Numb,                // номер функции CountCloudIndicator по списку в коде индикатора (стартовый номер - 0)
                         string   Symb,            // символ графика
                         ENUM_TIMEFRAMES TFrame,   // период графика
                         int      IndHandle,       // хендл обрабатываемого индикатора
                         uint     UpBuffNumb,      // номер верхнего буфера обрабатываемого индикатора для облака
                         double&  UpIndBuf[],      // приемный верхний буфер индикатора для облака
                         uint     DnBuffNumb,      // номер нижнего буфера обрабатываемого индикатора для облака
                         double&  DnIndBuf[],      // приемный нижний буфер индикатора для облака
                         const datetime& iTime[],  // таймсерия времени
                         const int Rates_Total,    // количество истории в барах на текущем тике
                         const int Prev_Calculated,// количество истории в барах на предыдущем тике
                         const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZECL];
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double UpArr[1],DnArr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,UpBuffNumb,iTime[bar],1,UpArr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,DnBuffNumb,iTime[bar],1,DnArr)<=0) return(RESET);
         //---
         UpIndBuf[bar]=UpArr[0];
         DnIndBuf[bar]=DnArr[0];
        }
      else
        {
         UpIndBuf[bar]=UpIndBuf[bar+1];
         DnIndBuf[bar]=DnIndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| CountLineIndicator                                               |
//+------------------------------------------------------------------+
bool CountLineIndicator(uint Numb,                // номер функции CountLineIndicator по списку в коде индикатора (стартовый номер - 0)
                        string   Symb,            // символ графика
                        ENUM_TIMEFRAMES TFrame,   // период графика
                        int      IndHandle,       // хендл обрабатываемого индикатора
                        uint     BuffNumb,        // номер буфера обрабатываемого индикатора
                        double&  IndBuf[],        // приемный буфер индикатора
                        const datetime& iTime[],  // таймсерия времени
                        const int Rates_Total,    // количество истории в барах на текущем тике
                        const int Prev_Calculated,// количество истории в барах на предыдущем тике
                        const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZEL];
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         //---
         IndBuf[bar]=Arr[0];
        }
      else
        {
         IndBuf[bar]=IndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //период графика индикатора (таймфрейм)
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
