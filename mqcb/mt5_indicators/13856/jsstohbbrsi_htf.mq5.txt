//+------------------------------------------------------------------+ 
//|                                           JS-Stoh-BB-RSI_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 5
#property indicator_buffers 5 
//---- использовано всего 5 графических построений
#property indicator_plots   5
//+----------------------------------------------+
//| Параметры отрисовки индикатора  1            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color1 clrBlue
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Stochastic"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован зеленый цвет
#property indicator_color2 clrTeal
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "RSI"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color3 clrBlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "Stochastic Signal"
//+----------------------------------------------+
//| Параметры отрисовки индикатора BB уровней    |
//+----------------------------------------------+
//---- отрисовка уровней Боллинджера в виде линий
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//---- ввыбор цветов уровней Боллинджера
#property indicator_color4  clrRed
#property indicator_color5  clrRed
//---- уровни Боллинджера - сплошные кривые
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
//---- толщина уровней Боллинджера равна 1
#property indicator_width4  1
#property indicator_width5  1
//---- отображение меток уровней Боллинджера
#property indicator_label4  "+2Sigma Stochastic"
#property indicator_label5  "-2Sigma Stochastic"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1  80.0
#property indicator_level2  70.0
#property indicator_level3  50.0
#property indicator_level4  30.0
#property indicator_level5  20.0
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                   // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "JS-Stoh-BB-RSI_HTF"       // константа для имени индикатора
#define SIZE 5                                    // константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4; // Период графика индикатора (таймфрейм)
input uint STO_KPeriod=5;  // K period стохастика
input uint STO_DPeriod=3;  // D period стохастика
input uint STO_Slowing=3;  // Slowing стохастика
input ENUM_MA_METHOD STO_Method=MODE_SMA; // Тип сглаживания стохастика
input ENUM_STO_PRICE STO_Price=STO_LOWHIGH; // Способ расчета стохастика
input uint BandsPeriod=10; // Период усреднения BB
input double BandsDeviation=1.0; // Девиация
input uint RSI_Period=8; // Период индикатора RSI
input ENUM_APPLIED_PRICE RSI_Price=PRICE_CLOSE; // Тип цены для индикатора RSI
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer1[],IndBuffer2[],IndBuffer3[],IndBuffer4[],IndBuffer5[];
//--- объявление строковых переменных
string Symbol_,Word;
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
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
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
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора JS-Stoh-BB-RSI не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//--- инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- получение хендла индикатора JS-Stoh-BB-RSI_HTF
   Ind_Handle=iCustom(Symbol_,TimeFrame,"JS-Stoh-BB-RSI",STO_KPeriod,STO_DPeriod,STO_Slowing,STO_Method,STO_Price,BandsPeriod,BandsDeviation,RSI_Period,RSI_Price,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора JS-Stoh-BB-RSI");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,IndBuffer1,INDICATOR_DATA);
   IndInit(1,IndBuffer2,INDICATOR_DATA);
   IndInit(2,IndBuffer3,INDICATOR_DATA);
   IndInit(3,IndBuffer4,INDICATOR_DATA);
   IndInit(4,IndBuffer5,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,EMPTY_VALUE,0,Shift);
   PlotInit(1,EMPTY_VALUE,0,Shift);
   PlotInit(2,EMPTY_VALUE,0,Shift);
   PlotInit(3,EMPTY_VALUE,0,Shift);
   PlotInit(4,EMPTY_VALUE,0,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//--- основной цикл расчета индикатора
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,1,IndBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,2,IndBuffer3,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,3,IndBuffer4,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,4,IndBuffer5,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
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
      //--- обнулим содержимое индикаторных буферов до расчета
      IndBuf[bar]=0.0;
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TimeFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массив Arr
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
