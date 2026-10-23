//+------------------------------------------------------------------+ 
//|                                           TangoLineCloud_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "TangoLineCloud с фиксированным во входных параметрах таймфреймом"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 7
#property indicator_buffers 7 
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                               // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "TangoLineCloud_HTF"   // константа для имени индикатора
#define SIZE 1                                // константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+
//| Параметры отрисовки облака                   |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLightSkyBlue
//---- отображение метки индикатора
#property indicator_label1  "Upper TangoLineCloud Cloud"
//+----------------------------------------------+
//| Параметры отрисовки облака                   |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color2  clrPink
//---- отображение метки индикатора
#property indicator_label2  "Lower TangoLineCloud Cloud"
//+--------------------------------------------+
//| Параметры отрисовки индикатора             |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован BlueViolet цвет
#property indicator_color3 clrBlueViolet
//---- линия индикатора - сплошная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width3  5
//---- отображение метки индикатора
#property indicator_label3  "TangoLine"
//+--------------------------------------------+
//| Параметры отрисовки индикатора уровней     |
//+--------------------------------------------+
//---- отрисовка уровней  в виде линий
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//---- выбор цветов уровней
#property indicator_color4  clrLimeGreen
#property indicator_color5  clrRed
//---- уровни - сплошные кривые
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
//---- толщина уровней равна 2
#property indicator_width4  2
#property indicator_width5  2
//---- отображение меток уровней
#property indicator_label4  "Upper"
#property indicator_label5  "Lower"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Период графика индикатора
//---
input  int InpPeriod=20;                     // Period
input  double MinSpread=5;                   // Min Spread 
input int Shift=0;                           // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
double Ind4Buffer[];
double Ind5Buffer[];
double Ind6Buffer[];
double Ind7Buffer[];
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
//--- получение хендла индикатора TangoLineCloud
   Ind_Handle=iCustom(Symbol(),TimeFrame,"TangoLineCloud",InpPeriod,MinSpread,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора TangoLineCloud");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   BuffInit(0,Ind1Buffer);
   BuffInit(1,Ind2Buffer);
   BuffInit(2,Ind3Buffer);
   BuffInit(3,Ind4Buffer);
   BuffInit(4,Ind5Buffer);
   BuffInit(5,Ind6Buffer);
   BuffInit(6,Ind7Buffer);
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
      Ind1Buffer,1,Ind2Buffer,2,Ind3Buffer,3,Ind4Buffer,4,Ind5Buffer,5,Ind6Buffer,6,Ind7Buffer,
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
                    uint     BuffNumb6,       // Номер буфера обрабатываемого индикатора 6
                    double&  IndBuf6[],       // Приемный буфер индикатора 6
                    uint     BuffNumb7,       // Номер буфера обрабатываемого индикатора 7
                    double&  IndBuf7[],       // Приемный буфер индикатора 7
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
         if(CopyBuffer(IndHandle,BuffNumb6,iTime[bar],1,Arr)<=0) return(RESET); IndBuf6[bar]=Arr[0];
         if(CopyBuffer(IndHandle,BuffNumb7,iTime[bar],1,Arr)<=0) return(RESET); IndBuf7[bar]=Arr[0];
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
