//+------------------------------------------------------------------+ 
//|                                       Skyscraper_Fix_Cld_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.70"
#property description "Skyscrape_Fix_Cld с возможностью изменения таймфрейма во входных параметрах"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано десять буферов
#property indicator_buffers 10
//---- использовано всего семь графических построений
#property indicator_plots   7
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                              // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Skyscraper_Fix_Cld"  // Константа для имени индикатора
#define SIZE 1                               // Константа для количества вызовов функции CountIndicator коде
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1 C'255,230,255'  
//--- отображение метки индикатора
#property indicator_label1  "Upper Loss Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color2  C'223,255,232'
//--- отображение метки индикатора
#property indicator_label2  "Lower Loss Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета индикатора использован LimeGreen цвет
#property indicator_color3  clrLimeGreen
//---- толщина индикатора 3 равна 3
#property indicator_width3  3
//---- отображение бычей метки индикатора
#property indicator_label3  "Upper Skyscraper"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета индикатора использован DeepPink цвет
#property indicator_color4  clrDeepPink
//---- толщина индикатора 4 равна 3
#property indicator_width4  3
//---- отображение медвежьей метки индикатора
#property indicator_label4 "Lower Skyscraper"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован LimeGreen цвет
#property indicator_color5  clrLimeGreen
//---- толщина индикатора 5 равна 5
#property indicator_width5  5
//---- отображение бычей метки индикатора
#property indicator_label5  "Skyscraper Buy"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде символа
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета индикатора использован DeepPink цвет
#property indicator_color6  clrDeepPink
//---- толщина индикатора 6 равна 5
#property indicator_width6  5
//---- отображение медвежьей метки индикатора
#property indicator_label6 "Skyscraper Sell"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 7 в виде символа
#property indicator_type7   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы
#property indicator_color7  clrTeal,clrFireBrick
//---- толщина индикатора 7 равна 1
#property indicator_width7  1
//---- отображение медвежьей метки индикатора
#property indicator_label7 "Skyscraper Middle"
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Method
  {
   MODE_HighLow,  //High/Low
   MODE_Close     //Close
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;    // Период графика индикатора (таймфрейм)
input uint    Length=10;                      // Период ATR
input double  Kv=0.9;                         // Фактор чувствительности индикатора
input double  Percentage=0;                   // Приближение средней линии к линиям экстремумов
input Method  HighLow=MODE_HighLow;           // Расчёт индикатора по High/Low или Close
input int Shift=0;                            // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double IndBuffer1[];
double IndBuffer2[];
double IndBuffer3[];
double IndBuffer4[];
double IndBuffer5[];
double IndBuffer6[];
double IndBuffer7[];
double IndBuffer8[];
double IndBuffer9[];
double IndBuffer10[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора Skyscraper_Fix_Cld
   Ind_Handle=iCustom(Symbol(),TimeFrame,"Skyscraper_Fix_Cld",Length,Kv,Percentage,HighLow);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Skyscraper_Fix_Cld");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,IndBuffer1,INDICATOR_DATA);
   IndInit(1,IndBuffer2,INDICATOR_DATA);
   IndInit(2,IndBuffer3,INDICATOR_DATA);
   IndInit(3,IndBuffer4,INDICATOR_DATA);
   IndInit(4,IndBuffer5,INDICATOR_DATA);
   IndInit(5,IndBuffer6,INDICATOR_DATA);
   IndInit(6,IndBuffer7,INDICATOR_DATA);
   IndInit(7,IndBuffer8,INDICATOR_DATA);
   IndInit(8,IndBuffer9,INDICATOR_DATA);
   IndInit(9,IndBuffer10,INDICATOR_COLOR_INDEX);
//--- инициализация индикаторов
   PlotClInit(0,0,Shift);
   PlotClInit(1,0,Shift);
   PlotInit(2,0.0,0,Shift);
   PlotInit(3,0.0,0,Shift);
   PlotInit(4,0.0,0,Shift);
   PlotInit(5,0.0,0,Shift);
   PlotInit(6,0.0,0,Shift);
//---- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,172);
   PlotIndexSetInteger(5,PLOT_ARROW,172);
   PlotIndexSetInteger(6,PLOT_ARROW,172);
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
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(RESET);
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer1,1,IndBuffer2,2,IndBuffer3,3,IndBuffer4,4,IndBuffer5,5,IndBuffer6,
      6,IndBuffer7,7,IndBuffer8,8,IndBuffer9,9,IndBuffer10,time,rates_total,prev_calculated,min_rates_total))
      return(RESET);
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
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void PlotClInit(int Number,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----   
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb1,       // Номер 1 буфера обрабатываемого индикатора
                    double&  IndBuf1[],       // Приемный 1 буфер индикатора
                    uint     BuffNumb2,       // Номер 2 буфера обрабатываемого индикатора
                    double&  IndBuf2[],       // Приемный 2 буфер индикатора
                    uint     BuffNumb3,       // Номер 3 буфера обрабатываемого индикатора
                    double&  IndBuf3[],       // Приемный 3 буфер индикатора
                    uint     BuffNumb4,       // Номер 4 буфера обрабатываемого индикатора
                    double&  IndBuf4[],       // Приемный 4 буфер индикатора
                    uint     BuffNumb5,       // Номер 5 буфера обрабатываемого индикатора
                    double&  IndBuf5[],       // Приемный 5 буфер индикатора
                    uint     BuffNumb6,       // Номер 6 буфера обрабатываемого индикатора
                    double&  IndBuf6[],       // Приемный 6 буфер индикатора
                    uint     BuffNumb7,       // Номер 7 буфера обрабатываемого индикатора
                    double&  IndBuf7[],       // Приемный 7 буфер индикатора
                    uint     BuffNumb8,       // Номер 8 буфера обрабатываемого индикатора
                    double&  IndBuf8[],       // Приемный 8 буфер индикатора
                    uint     BuffNumb9,       // Номер 9 буфера обрабатываемого индикатора
                    double&  IndBuf9[],       // Приемный 9 буфер индикатора
                    uint     BuffNumb10,      // Номер 10 буфера обрабатываемого индикатора
                    double&  IndBuf10[],      // Приемный 10 буфер индикатора
                    const datetime& nTime[],  // Таймсерия времени
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
      if(CopyTime(Symbol(),TFrame,nTime[bar],1,IndTime)<=0) return(RESET);
      IndBuf1[bar]=IndBuf2[bar]=IndBuf3[bar]=IndBuf4[bar]=IndBuf5[bar]=IndBuf6[bar]=IndBuf7[bar]=IndBuf8[bar]=IndBuf9[bar]=IndBuf10[bar]=NULL;
      //---
      if(nTime[bar]>=IndTime[0] && nTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr1[1],Arr2[1],Arr3[1],Arr4[1],Arr5[1],Arr6[1],Arr7[1],Arr8[1],Arr9[1],Arr10[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb1,nTime[bar],1,Arr1)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb2,nTime[bar],1,Arr2)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb3,nTime[bar],1,Arr3)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb4,nTime[bar],1,Arr4)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb5,nTime[bar],1,Arr5)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb6,nTime[bar],1,Arr6)<=0) return(RESET);         
         if(CopyBuffer(IndHandle,BuffNumb7,nTime[bar],1,Arr7)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb8,nTime[bar],1,Arr8)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb9,nTime[bar],1,Arr9)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb10,nTime[bar],1,Arr10)<=0) return(RESET);
         //---         
         IndBuf1[bar]=Arr1[0];
         IndBuf2[bar]=Arr2[0];
         IndBuf3[bar]=Arr3[0];
         IndBuf4[bar]=Arr4[0];
         IndBuf5[bar]=Arr5[0];
         IndBuf6[bar]=Arr6[0];         
         IndBuf7[bar]=Arr7[0];
         IndBuf8[bar]=Arr8[0];
         IndBuf9[bar]=Arr9[0];
         IndBuf10[bar]=Arr10[0];
        }
      else
        {
         IndBuf1[bar]=IndBuf1[bar+1];
         IndBuf2[bar]=IndBuf2[bar+1];
         IndBuf3[bar]=IndBuf3[bar+1];
         IndBuf4[bar]=IndBuf4[bar+1];
         IndBuf5[bar]=IndBuf5[bar+1];
         IndBuf6[bar]=IndBuf6[bar+1];
         IndBuf7[bar]=IndBuf7[bar+1];
         IndBuf8[bar]=IndBuf8[bar+1];
         IndBuf9[bar]=IndBuf9[bar+1];
         IndBuf10[bar]=IndBuf10[bar+1];
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
      Comment("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика! \n Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
