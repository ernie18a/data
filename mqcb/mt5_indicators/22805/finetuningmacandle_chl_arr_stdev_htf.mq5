//+------------------------------------------------------------------+ 
//|                         FineTuningMACandle_Chl_Arr_StDev_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.70"
#property description "FineTuningMACandle_Chl_Arr_StDev с фиксированным во входных параметрах таймфреймом"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано десять буферов
#property indicator_buffers 10
//---- использовано всего семь графических построений
#property indicator_plots   7
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                             // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "FineTuningMACandle_Chl_Arr_StDev"   // Константа для имени индикатора
#define SIZE 10                                             // Константа для количества вызовов функции CountIndicator в коде

//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  C'170,255,227'
//--- отображение метки индикатора
#property indicator_label1  "Upper Signal Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color2  C'255,255,187'
//--- отображение метки индикатора
#property indicator_label2  "Lower Signal Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использована цветная линия
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3   clrDeepPink,clrGray,clrCornflowerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "FineTuningMACandle Signal line"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color4  clrRed
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Dn_Signal 1"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован салатовый цвет
#property indicator_color5  clrMediumSpringGreen
//---- толщина линии индикатора 5 равна 2
#property indicator_width5  2
//---- отображение бычей метки индикатора
#property indicator_label5  "Up_Signal 1"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде символа
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color6  clrRed
//---- толщина линии индикатора 6 равна 5
#property indicator_width6  5
//---- отображение медвежьей метки индикатора
#property indicator_label6  "Dn_Signal 2"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 7 в виде символа
#property indicator_type7   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован салатовый цвет
#property indicator_color7  clrMediumSpringGreen
//---- толщина линии индикатора 7 равна 5
#property indicator_width7  5
//---- отображение бычей метки индикатора
#property indicator_label7  "Up_Signal 2"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;             //Период графика индикатора
//---
input uint   FTMA=10;
input double rank1=2;
input double rank2=2;
input double rank3=2;
input double Shift1=1;
input double Shift2=1;
input double Shift3=1;
input int PriceShift=0;                                //cдвиг индикатора по вертикали в пунктах
input uint Gap=10;                                     //размер неучитываемого гэпа в пунктах
input uint BBLength=10;                                //период Боллинджера                                                   
input double BandsDeviation=1.0;                       //девиация
input double dK1=1.5;                            //коэффициент 1 для квадратичного фильтра
input double dK2=2.5;                            //коэффициент 2 для квадратичного фильтра
input uint std_period=9;                         //период квадратичного фильтра
input int        Shift=0;                              //сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[];
double ExtBuffer[],ExtColorBuffer[];
double BearsBuffer1[],BullsBuffer1[];
double BearsBuffer2[],BullsBuffer2[];
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
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора FineTuningMACandle_Chl_Arr_StDev
   Ind_Handle=iCustom(Symbol(),TimeFrame,"FineTuningMACandle_Chl_Arr_StDev",FTMA,rank1,rank2,rank3,Shift1,Shift2,Shift3,
                      PriceShift,Gap,BBLength,BandsDeviation,dK1,dK2,std_period,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора FineTuningMACandle_Chl_Arr_StDev");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов  
   IndInit(0,UpUpBuffer,INDICATOR_DATA);
   IndInit(1,UpDnBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,NULL,min_rates_total,Shift);
//--- инициализация индикаторных буферов  
   IndInit(2,DnUpBuffer,INDICATOR_DATA);
   IndInit(3,DnDnBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(1,NULL,min_rates_total,Shift);
//---- превращение динамических массивов в индикаторные буферы
   IndInit(4,ExtBuffer,INDICATOR_DATA);
   IndInit(5,ExtColorBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(2,NULL,min_rates_total,Shift);

//---- превращение динамических массивов в индикаторные буферы
   IndInit(6,BearsBuffer1,INDICATOR_DATA);
   IndInit(7,BullsBuffer1,INDICATOR_DATA);
   IndInit(8,BearsBuffer2,INDICATOR_DATA);
   IndInit(9,BullsBuffer2,INDICATOR_DATA);

//--- инициализация индикаторов
   PlotInit(3,NULL,min_rates_total,Shift);
   PlotInit(4,NULL,min_rates_total,Shift);
   PlotInit(5,NULL,min_rates_total,Shift);
   PlotInit(6,NULL,min_rates_total,Shift);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   PlotIndexSetInteger(4,PLOT_ARROW,159);
   PlotIndexSetInteger(5,PLOT_ARROW,159);
   PlotIndexSetInteger(6,PLOT_ARROW,159);

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
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE BufferType)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,BufferType);
//---- индексация элементов в буферах как в таймсериях
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
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----   
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
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,UpUpBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame,Ind_Handle,1,UpDnBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame,Ind_Handle,2,DnUpBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(3,NULL,TimeFrame,Ind_Handle,3,DnDnBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(4,NULL,TimeFrame,Ind_Handle,4,ExtBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(5,NULL,TimeFrame,Ind_Handle,5,ExtColorBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(6,NULL,TimeFrame,Ind_Handle,6,BearsBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(7,NULL,TimeFrame,Ind_Handle,7,BullsBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(8,NULL,TimeFrame,Ind_Handle,8,BearsBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(9,NULL,TimeFrame,Ind_Handle,9,BullsBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора 1
                    double&  IndBuf[],        // Приемный буфер индикатора 1
                    const datetime& Time[],   // Таймсерия времени
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
      if(CopyTime(Symbol(),TFrame,Time[bar],1,IndTime)<=0) return(RESET);
      //---
      if(Time[bar]>=IndTime[0] && Time[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,Time[bar],1,Arr)<=0) return(RESET);
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
