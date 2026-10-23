//+------------------------------------------------------------------+ 
//|                                 Volume_Weighted_MA_Cloud_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 6 
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                       // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Volume_Weighted_MA_Cloud"     // Константа для имени индикатора
#define SIZE 6                                        // Константа для количества вызовов функции CountLine
//+------------------------------------------------+
//|  Параметры отрисовки фона                      |
//+------------------------------------------------+
//---- отрисовка фона в облачном виде
#property indicator_type1   DRAW_FILLING
#property indicator_type2   DRAW_FILLING
//---- выбор цветов фона
#property indicator_color1  clrPaleTurquoise
#property indicator_color2  clrLightPink
//---- отображение меток
#property indicator_label1  "Upper Cloud"
#property indicator_label2  "Lower Cloud"
//+------------------------------------------------+
//|  Параметры отрисовки индикатора                |
//+------------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color3  clrMagenta,clrGray,clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width3  5
//---- отображение метки индикатора
#property indicator_label3  "Volume_Weighted_MA"
//+------------------------------------------------+
//|  объявление перечислений                       |
//+------------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;         //период графика
input uint Length=12;                              //глубина сглаживания                    
input Applied_price_ IPC=PRICE_CLOSE_;             //ценовая константа
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //объём 
input int Shift=0;                                 //сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                            //cдвиг индикатора по вертикали в пунктах
input uint Dev=20;                                 //Девиация заливки фоном
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[],ExtLineBuffer6[];
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
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора Volume_Weighted_MA_Cloud не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//--- инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- получение хендла индикатора Volume_Weighted_MA_Cloud
   Ind_Handle=iCustom(Symbol_,TimeFrame,"Volume_Weighted_MA_Cloud",Length,IPC,VolumeType,0,PriceShift,Dev);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Volume_Weighted_MA_Cloud");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер   
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(5,ExtLineBuffer6,INDICATOR_COLOR_INDEX);
   
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME"(",GetStringTimeframe(TimeFrame),")");
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
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//--- основной цикл расчета индикатора
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,ExtLineBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame,Ind_Handle,1,ExtLineBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame,Ind_Handle,2,ExtLineBuffer3,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(3,NULL,TimeFrame,Ind_Handle,3,ExtLineBuffer4,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(4,NULL,TimeFrame,Ind_Handle,4,ExtLineBuffer5,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(5,NULL,TimeFrame,Ind_Handle,5,ExtLineBuffer6,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора
                    double&  IndBuf[],        // Приемный буфер индикатора
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