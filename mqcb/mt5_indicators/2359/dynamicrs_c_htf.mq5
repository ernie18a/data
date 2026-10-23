//+------------------------------------------------------------------+ 
//|                                              DynamicRS_C_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.00"
#property description "DynamicRS_C с возможностью изменения таймфрейма во входных параметрах"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window
//--- количество индикаторных буферов
#property indicator_buffers 2 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-------------------------------------+
//| объявление констант                 |
//+-------------------------------------+
#define RESET 0                      // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "DynamicRS_C" // Константа для имени индикатора
#define SIZE 1                       // Константа для количества вызовов функции CountIndicator
//+-------------------------------------+
//| Параметры отрисовки индикатора 1    |
//+-------------------------------------+
//--- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//--- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrMagenta,clrGold,clrBlueViolet
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 4
#property indicator_width1  4
//--- отображение метки индикатора
#property indicator_label1  INDICATOR_NAME
//---
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; //Период графика индикатора
//+-------------------------------------+
//| Входные параметры индикатора        |
//+-------------------------------------+
input uint Length=5;     // Период анализа             
input int Shift=0;       // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0;  // Сдвиг индикатора по вертикали в пунктах
//+-------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
//--- объявление строковых переменных
string Symbol_,Word;
//--- объявление целочисленных переменных начала отсчёта данных
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
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- получение хендла индикатора DynamicRS_C
   Ind_Handle=iCustom(Symbol(),TimeFrame,INDICATOR_NAME,Length,Shift,PriceShift);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора DynamicRS_C");
      return(INIT_FAILED);
     }
//--- инициализация индикаторного буферов
   IndInit(0,IndBuffer,ColorIndBuffer,0.0,min_rates_total,0);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame)," ,",Length,")");
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
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,1,ColorIndBuffer,
      time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double &ColorBuffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---
   int indnumb=2*Number;
   int plotnumb=indnumb;
//--- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(indnumb,Buffer,INDICATOR_DATA);
   SetIndexBuffer(indnumb+1,ColorBuffer,INDICATOR_COLOR_INDEX);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(plotnumb,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(plotnumb,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(plotnumb,PLOT_SHIFT,nShift);
//--- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(Buffer,true);
   ArraySetAsSeries(ColorBuffer,true);
//---
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора
                    double&  IndBuf[],        // Приёмный буфер индикатора
                    uint     ColBuffNumb,     // Номер буфера обрабатываемого индикатора
                    double&  ColIndBuf[],     // Приёмный буфер индикатора
                    const datetime& iTime[],  // Таймсерия времени
                    const int Rates_Total,    // Количество истории в барах на текущем тике
                    const int Prev_Calculated,// Количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// Минимальное количество истории в барах для расчёта
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- расчёты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчёта баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчёта всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчёта новых баров 
//--- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- обнулим содержимое индикаторных буферов до расчёта
      IndBuf[bar]=0.0;
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1],ColArr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,ColBuffNumb,iTime[bar],1,ColArr)<=0) return(RESET);
         //---
         IndBuf[bar]=Arr[0];
         ColIndBuf[bar]=ColArr[0];
        }
      else
        {
         IndBuf[bar]=IndBuf[bar+1];
         ColIndBuf[bar]=ColIndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Период графика индикатора
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
