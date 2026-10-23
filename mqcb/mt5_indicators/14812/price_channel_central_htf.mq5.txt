//+------------------------------------------------------------------+ 
//|                                    Price_Channel_Central_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "Price_Channel_Central с фиксированным во входных параметрах таймфреймом"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 5
#property indicator_buffers 5 
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                      // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Price_Channel_Central_HTF"   // константа для имени индикатора
#define SIZE 1                                       // константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве индикатора использована линия
#property indicator_type1   DRAW_LINE
//---- отображение метки индикатора
#property indicator_label1  "Chanell Upper"
//---- в качестве цветов линии индикатора использован
#property indicator_color1 clrLime
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width1  5
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве индикатора использована линия
#property indicator_type2   DRAW_LINE
//---- отображение метки индикатора
#property indicator_label2  "Chanell Middle"
//---- в качестве цветов линии индикатора использован
#property indicator_color2 clrBlue
//---- линия индикатора - сплошная
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width2  5
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве индикатора использована линия
#property indicator_type3   DRAW_LINE
//---- отображение метки индикатора
#property indicator_label3  "Chanell Lower"
//---- в качестве цветов линии индикатора использован
#property indicator_color3 clrRed
//---- линия индикатора - сплошная
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width3  5
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color4  clrMagenta
//--- толщина линии индикатора 4 равна 5
#property indicator_width4  5
//--- отображение медвежьей метки индикатора
#property indicator_label4  "Price_Channel_Central Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован голубой цвет
#property indicator_color5  clrDodgerBlue
//--- толщина линии индикатора 5 равна 5
#property indicator_width5  5
//--- отображение бычьей метки индикатора
#property indicator_label5 "Price_Channel_Central Buy"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Период графика индикатора
//---
input uint Bars_Count=32;
input color  Upper_color=clrTeal;
input color  Middle_color=clrBlue;
input color  Lower_color=clrRed;
input int Shift=0;                           // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
double Ind4Buffer[];
double Ind5Buffer[];
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
//--- получение хендла индикатора Price_Channel_Central
   Ind_Handle=iCustom(Symbol(),TimeFrame,"Price_Channel_Central",Bars_Count,Upper_color,Middle_color,Lower_color);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Price_Channel_Central");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   BuffInit(0,Ind1Buffer);
   BuffInit(1,Ind2Buffer);
   BuffInit(2,Ind3Buffer);
   BuffInit(3,Ind4Buffer);
   BuffInit(4,Ind5Buffer);
//--- инициализация индикаторов   
   IndInit(0,0.0,min_rates_total,Shift);
   IndInit(1,0.0,min_rates_total,Shift);
   IndInit(2,0.0,min_rates_total,Shift);
   IndInit(3,0.0,min_rates_total,Shift);
   IndInit(4,0.0,min_rates_total,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
//---
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
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,
      Ind1Buffer,1,Ind2Buffer,2,Ind3Buffer,3,Ind4Buffer,4,Ind5Buffer,
      time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void BuffInit(int Number,double &Buffer[])
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void IndInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb1,       // Номер буфера обрабатываемого индикатора 1
                    double&  IndBuf1[],       // Приемный буфер индикатора 1
                    uint     BuffNumb2,       // Номер буфера обрабатываемого индикатора 2
                    double&  IndBuf2[],       // Приемный буфер индикатора 2
                    uint     BuffNumb3,       // Номер буфера обрабатываемого индикатора 3
                    double&  IndBuf3[],       // Приемный буфер индикатора 3                    
                    uint     BuffNumb4,       // Номер буфера обрабатываемого индикатора 4
                    double&  IndBuf4[],       // Приемный буфер индикатора 4
                    uint     BuffNumb5,       // Номер буфера обрабатываемого индикатора 5
                    double&  IndBuf5[],       // Приемный буфер индикатора 5
                    const datetime& iTime[],  // Таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZE];
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
         if(CopyBuffer(IndHandle,BuffNumb1,iTime[bar],1,Arr)<=0) return(RESET); IndBuf1[bar]=Arr[0];
         if(CopyBuffer(IndHandle,BuffNumb2,iTime[bar],1,Arr)<=0) return(RESET); IndBuf2[bar]=Arr[0];
         if(CopyBuffer(IndHandle,BuffNumb3,iTime[bar],1,Arr)<=0) return(RESET); IndBuf3[bar]=Arr[0];
         if(CopyBuffer(IndHandle,BuffNumb4,iTime[bar],1,Arr)<=0) return(RESET); IndBuf4[bar]=Arr[0];
         if(CopyBuffer(IndHandle,BuffNumb5,iTime[bar],1,Arr)<=0) return(RESET); IndBuf5[bar]=Arr[0];
        }
      else
        {
         IndBuf1[bar]=IndBuf1[bar+1];
         IndBuf2[bar]=IndBuf2[bar+1];
         IndBuf3[bar]=IndBuf3[bar+1];
         IndBuf4[bar]=IndBuf4[bar+1];
         IndBuf5[bar]=IndBuf5[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) // Период графика индикатора
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
