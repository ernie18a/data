//+------------------------------------------------------------------+ 
//|                                   Background_FiboCandles_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "Индикатор усредненных свечек с возможностью изменения таймфрейма во входных параметрах."
//--- отрисовка индикатора в основном окне
#property indicator_chart_window
//--- количество индикаторных буферов 12
#property indicator_buffers 12 
//--- использовано шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                        // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Background_FiboCandles"        // Константа для имени индикатора
#define SIZE  1                                        // Константа для количества вызовов функции CountIndicator в коде
#define EMPTYVALUE 0                                   // Константа для неотображаемых значений индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цвета индикатора использованы
#property indicator_color1  clrPaleGreen,clrYellow
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label1  "Upper Shade"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//--- в качестве цвета индикатора использованы
#property indicator_color2  clrLimeGreen,clrDarkOrange
//--- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label2  "Body"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 3            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type3   DRAW_FILLING
//--- в качестве цвета индикатора использован
#property indicator_color3  clrPaleGreen,clrYellow
//--- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label3  "Lower Shade"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 4            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type4   DRAW_FILLING
//--- в качестве цвета индикатора использованы
#property indicator_color4  clrPaleGreen,clrYellow
//--- линия индикатора - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label4  "Upper Shade"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 5            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//--- в качестве цвета индикатора использованы
#property indicator_color5  clrLimeGreen,clrDarkOrange
//--- линия индикатора - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label5  "Body"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 6            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type6   DRAW_FILLING
//--- в качестве цвета индикатора использованы
#property indicator_color6  clrPaleGreen,clrYellow
//--- линия индикатора - непрерывная кривая
#property indicator_style6  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label6  "Lower Shade"
//+------------------------------------------------+
//|  объявление констант                           |
//+------------------------------------------------+
//---- константы фибо-уровней
#define LEVEL_1 0.236
#define LEVEL_2 0.382
#define LEVEL_3 0.500
#define LEVEL_4 0.618
#define LEVEL_5 0.762
//+------------------------------------------------+
//|  Перечисление для фибо-уровней                 |
//+------------------------------------------------+
enum ENUM_FIBORATIO //Тип константы
  {
   LEVEL_1_ = 1,   //0.236
   LEVEL_2_,       //0.382
   LEVEL_3_,       //0.500
   LEVEL_4_,       //0.618
   LEVEL_5_        //0.762
  };
//+------------------------------------------------+ 
//| Перечисление для индикации срабатывания уровня |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE //Тип константы
  {
   OnlySound,   //только звук
   OnlyAlert    //только алерт
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Период графика индикатора
input uint period=10;                       // Период индикатора
input ENUM_FIBORATIO fiboLevel=LEVEL_1_;    // Значение фибоуровня
//---- настройки для подаваемых алертов
input uint SignalBar=0;                     // Номер бара для получения сигнала (0 - текущий бар)
input ENUM_ALERT_MODE alert_mode=OnlySound; // Вариант индикации срабатывания
input uint AlertCount=0;                    // Количество подаваемых алертов
input int    Shift=0;                       // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double ExtA1Buffer[];
double ExtB1Buffer[];
double ExtA2Buffer[];
double ExtB2Buffer[];
double ExtA3Buffer[];
double ExtB3Buffer[];
double ExtA4Buffer[];
double ExtB4Buffer[];
double ExtA5Buffer[];
double ExtB5Buffer[];
double ExtA6Buffer[];
double ExtB6Buffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- получение хендла индикатора FiboCandles
   Ind_Handle=iCustom(Symbol(),TimeFrame,"FiboCandles",period,fiboLevel,SignalBar,alert_mode,AlertCount);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора FiboCandles");
      return(INIT_FAILED);
     }
//--- инициализация переменных 
   min_rates_total=2;
//--- превращение динамических массивов в индикаторные буферы
   ArrayInit(0,ExtA1Buffer);
   ArrayInit(1,ExtB1Buffer);
   ArrayInit(2,ExtA2Buffer);
   ArrayInit(3,ExtB2Buffer);
   ArrayInit(4,ExtA3Buffer);
   ArrayInit(5,ExtB3Buffer);
   ArrayInit(6,ExtA4Buffer);
   ArrayInit(7,ExtB4Buffer);
   ArrayInit(8,ExtA5Buffer);
   ArrayInit(9,ExtB5Buffer);
   ArrayInit(10,ExtA6Buffer);
   ArrayInit(11,ExtB6Buffer);
//--- инициализация индикаторов
   PlotInit(0,2,Shift);
   PlotInit(1,2,Shift);
   PlotInit(2,2,Shift);
   PlotInit(3,2,Shift);
   PlotInit(4,2,Shift);
   PlotInit(5,2,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",EnumToString(TimeFrame),")");
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
   if(!CountIndicator(0,Symbol(),TimeFrame,Ind_Handle,
      ExtA1Buffer,ExtB1Buffer,ExtA2Buffer,ExtB2Buffer,
      ExtA3Buffer,ExtB3Buffer,ExtA4Buffer,ExtB4Buffer,
      ExtA5Buffer,ExtB5Buffer,ExtA6Buffer,ExtB6Buffer,
      time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,             // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,             // Символ графика
                    ENUM_TIMEFRAMES TFrame,    // Период графика
                    int      IndHandle,        // Хендл обрабатываемого индикатора
                    double&  ExtA1Buff[],      // Приемный буфер индикатора 1
                    double&  ExtB1Buff[],      // Приемный буфер индикатора 2
                    double&  ExtA2Buff[],      // Приемный буфер индикатора 3
                    double&  ExtB2Buff[],      // Приемный буфер индикатора 4
                    double&  ExtA3Buff[],      // Приемный буфер индикатора 5
                    double&  ExtB3Buff[],      // Приемный буфер индикатора 6
                    double&  ExtA4Buff[],      // Приемный буфер индикатора 7
                    double&  ExtB4Buff[],      // Приемный буфер индикатора 8
                    double&  ExtA5Buff[],      // Приемный буфер индикатора 9
                    double&  ExtB5Buff[],      // Приемный буфер индикатора 10
                    double&  ExtA6Buff[],      // Приемный буфер индикатора 11
                    double&  ExtB6Buff[],      // Приемный буфер индикатора 11
                    const datetime &Time[],    // Таймсерия времени
                    const int Rates_Total,     // количество истории в барах на текущем тике
                    const int Prev_Calculated, // количество истории в барах на предыдущем тике
                    const int Min_Rates_Total) // минимальное количество истории в барах для расчета
  {
//---
   static int Sign;
   static datetime LastTime;
   static int LastCountBar[SIZE];
   double iOpen[1],iLow[1],iHigh[1],iClose[1];
   datetime iTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
      LastTime=0;
      Sign=1;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,Time[bar],1,iTime)<=0) return(RESET);

      if(Time[bar]>=iTime[0] && Time[bar+1]<iTime[0])
        {
         LastCountBar[Numb]=bar;
         if(iTime[0]!=LastTime)
           {
            LastTime=iTime[0];
            Sign*=(-1);
           }
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,0,Time[bar],1,iOpen)<=0) return(RESET);
         if(CopyBuffer(IndHandle,1,Time[bar],1,iHigh)<=0) return(RESET);
         if(CopyBuffer(IndHandle,2,Time[bar],1,iLow)<=0) return(RESET);
         if(CopyBuffer(IndHandle,3,Time[bar],1,iClose)<=0) return(RESET);

         if(Sign>0)
           {
            if(iClose[0]>=iOpen[0])
              {
               ExtA1Buff[bar]=iHigh[0];
               ExtB1Buff[bar]=iClose[0];
               ExtA2Buff[bar]=iClose[0];
               ExtB2Buff[bar]=iOpen[0];
               ExtA3Buff[bar]=iOpen[0];
               ExtB3Buff[bar]=iLow[0];
              }
            else
              {
               ExtB1Buff[bar]=iHigh[0];
               ExtA1Buff[bar]=iClose[0];
               ExtA2Buff[bar]=iClose[0];
               ExtB2Buff[bar]=iOpen[0];
               ExtB3Buff[bar]=iOpen[0];
               ExtA3Buff[bar]=iLow[0];
              }

            ExtA4Buff[bar]=EMPTYVALUE;
            ExtB4Buff[bar]=EMPTYVALUE;
            ExtA5Buff[bar]=EMPTYVALUE;
            ExtB5Buff[bar]=EMPTYVALUE;
            ExtA6Buff[bar]=EMPTYVALUE;
            ExtB6Buff[bar]=EMPTYVALUE;
           }
         else
           {
            if(iClose[0]>=iOpen[0])
              {
               ExtA4Buff[bar]=iHigh[0];
               ExtB4Buff[bar]=iClose[0];
               ExtA5Buff[bar]=iClose[0];
               ExtB5Buff[bar]=iOpen[0];
               ExtA6Buff[bar]=iOpen[0];
               ExtB6Buff[bar]=iLow[0];
              }
            else
              {
               ExtB4Buff[bar]=iHigh[0];
               ExtA4Buff[bar]=iClose[0];
               ExtA5Buff[bar]=iClose[0];
               ExtB5Buff[bar]=iOpen[0];
               ExtB6Buff[bar]=iOpen[0];
               ExtA6Buff[bar]=iLow[0];
              }
            ExtA1Buff[bar]=EMPTYVALUE;
            ExtB1Buff[bar]=EMPTYVALUE;
            ExtA2Buff[bar]=EMPTYVALUE;
            ExtB2Buff[bar]=EMPTYVALUE;
            ExtA3Buff[bar]=EMPTYVALUE;
            ExtB3Buff[bar]=EMPTYVALUE;
           }
        }
      else
        {
         ExtA1Buff[bar]=ExtA1Buff[bar+1];
         ExtB1Buff[bar]=ExtB1Buff[bar+1];
         ExtA2Buff[bar]=ExtA2Buff[bar+1];
         ExtB2Buff[bar]=ExtB2Buff[bar+1];
         ExtA3Buff[bar]=ExtA3Buff[bar+1];
         ExtB3Buff[bar]=ExtB3Buff[bar+1];
         ExtA4Buff[bar]=ExtA4Buff[bar+1];
         ExtB4Buff[bar]=ExtB4Buff[bar+1];
         ExtA5Buff[bar]=ExtA5Buff[bar+1];
         ExtB5Buff[bar]=ExtB5Buff[bar+1];
         ExtA6Buff[bar]=ExtA6Buff[bar+1];
         ExtB6Buff[bar]=ExtB6Buff[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| PlotInit()                                                       |
//+------------------------------------------------------------------+    
void PlotInit(uint PlotNumber,
              int DrawBegin,
              int PlotShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,DrawBegin);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,PlotShift);
//---
  }
//+------------------------------------------------------------------+
//| ArrayInit()                                                      |
//+------------------------------------------------------------------+    
void ArrayInit(uint ArrNumber,
               double &Array[])
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(ArrNumber,Array,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Array,true);
//---
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Период графика индикатора 1 (младший таймфрейм)
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
