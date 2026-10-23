//+------------------------------------------------------------------+ 
//|                                                 XChannel_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
#property description "Индикатор XChannel с возможностью изменения таймфрейма во входных параметрах"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                      // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "XChannel"                    // Константа для имени индикатора
#define SIZE 2                                       // Константа для количества вызовов функции CountIndicator
#define INDTOTAL 1                                   // Константа для количества отображаемых мувингов
//+----------------------------------------------+
//---- количество индикаторных буферов
#property indicator_buffers SIZE 
//---- использовано всего одно графическое построение
#property indicator_plots   INDTOTAL
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета индикатора использован
#property indicator_color1  clrYellow
//---- отображение метки индикатора
#property indicator_label1 "Up;Down"
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Smooth_Method
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Период графика индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+  
input Smooth_Method XMA_Method=MODE_SMA_;   //метод усреднения
input uint XLength=20;                      //глубина усреднения                    
input int XPhase=15;                        //параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int Delta=100;                        //смещение каналов по вертикали в пунктах
input int Shift=0;                          // Сдвиг индикатора по горизонтали в барах    
//+----------------------------------------------+
//---- Объявление стрингов
string Symbol_,Word;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//|  Класс индикаторных буферов                                      |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
   //---
public:
   double            m_LineBuffer[];
   //--- 
  };
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
CIndBuffers Ind[SIZE];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);

//---- Инициализация переменных 
   min_rates_total=2;
   Symbol_=NULL;
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- получение хендла индикатора XChannel
   Ind_Handle=iCustom(Symbol(),TimeFrame,INDICATOR_NAME,XMA_Method,XLength,XPhase,Delta,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XChannel");
      return(INIT_FAILED);
     }

//---- Инициализация индикаторов
   for(int count=0; count<INDTOTAL; count++) IndInit(count,EMPTY_VALUE,min_rates_total,Shift);
//---- Инициализация индикаторного буферов
   for(int count=0; count<SIZE; count++) BuffInit(count,Ind[count].m_LineBuffer);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//----
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//----     
   return(rates_total);
  }
//----
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void IndInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//----
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void BuffInit(int Number,double &Buffer[])
  {
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(Buffer,true);
//----
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(
                    uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    const datetime& iTime[],  // Таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total // минимальное количество истории в барах для расчёта
                    )
//---- 
  {
//----
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчёта всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчёта новых баров 

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      for(int count=0; count<INDTOTAL; count++) Ind[count].m_LineBuffer[bar]=EMPTY_VALUE;

      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         
         for(int count=0; count<SIZE; count++)
           {
            double Arr[1];
            //---- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(IndHandle,count,iTime[bar],1,Arr)<=0) return(RESET);
            Ind[count].m_LineBuffer[bar]=Arr[0];
           }
        }
      else for(int count=0; count<SIZE; count++) Ind[count].m_LineBuffer[bar]=Ind[count].m_LineBuffer[bar+1];
     }
//----     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(
                     string IndName,
                     ENUM_TIMEFRAMES TFrame //Период графика индикатора
                     )
//TimeFramesCheck(INDICATOR_NAME,TimeFrame)
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
