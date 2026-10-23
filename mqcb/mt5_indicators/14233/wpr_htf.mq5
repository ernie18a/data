//+------------------------------------------------------------------+ 
//|                                                      WPR_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
#property description "Williams’ Percent Range с возможностью изменения таймфрейма во входных параметрах"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 1
#property indicator_buffers 1 
//---- использовано всего одно графические построение
#property indicator_plots   1
//---- ограничения масштаба размеров окна индикатора по вертикали
#property indicator_maximum 0
#property indicator_minimum -100
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве цвета линии использован MediumOrchid цвет
#property indicator_color1 clrMediumOrchid
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1 3
//---- отображение метки сигнальной линии
#property indicator_label1  "WPR"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 -30
#property indicator_level2 -70
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-------------------------------------+
//| Объявление констант                 |
//+-------------------------------------+
#define RESET 0              // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "WPR" // константа для имени индикатора
#define SIZE 1               // константа для количества вызовов функции CountIndicator
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_            //PRICE_LOW
  };
//+-------------------------------------+
//| Входные параметры индикатора        |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Период графика индикатора
input uint ExtWPRPeriod=11;                 // Период усреднения
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_; // Ценовая константа
input int Shift = 0;                        // Сдвиг индикатора по горизонтали в барах
//+-------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
//---- объявление строковых переменных
string Symbol_,Word;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
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
//---- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//---- инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//---- получение хендла индикатора WPR
   Ind_Handle=iCustom(Symbol(),TimeFrame,INDICATOR_NAME,ExtWPRPeriod,IPC,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора WPR");
      return(INIT_FAILED);
     }
//---- инициализация индикаторного буферов
   IndInit(0,IndBuffer,EMPTY_VALUE,min_rates_total,Shift);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//----
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(Buffer,true);
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
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
//----
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчета
      IndBuf[bar]=0.0;
      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //----
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         //----
         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
     }
//----     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //период графика индикатора
  {
//---- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
