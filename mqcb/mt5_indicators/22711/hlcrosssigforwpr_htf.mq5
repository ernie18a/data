//+------------------------------------------------------------------+ 
//|                                         HLCrossSigForWPR_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.00"
///---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 8
//---- использовано четыре графических построения
#property indicator_plots   8
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                       // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "HLCrossSigForWPR"             // Константа для имени индикатора
#define SIZE 8                                        // Константа для количества вызовов функции CountLine
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color1  clrRed
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение медвежьей метки индикатора
#property indicator_label1  "Sell Stop"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован зелёный цвет
#property indicator_color2  clrLime
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение бычей метки индикатора
#property indicator_label2 "Buy Stop"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3 DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color3 clrMagenta
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Sell TakeProfit"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4 DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован салатовый цвет
#property indicator_color4 clrAqua
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение бычей метки индикатора
#property indicator_label4 "Buy TakeProfit"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5 DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован розовый  цвет
#property indicator_color5 clrMagenta 
//---- толщина линии индикатора 5 равна 1
#property indicator_width5  1
//---- отображение медвежьей метки индикатора
#property indicator_label5  "Sell Signal"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде символа
#property indicator_type6 DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован салатовый цвет
#property indicator_color6 clrAqua
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение бычей метки индикатора
#property indicator_label6 "Buy Signal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 7 в виде символа
#property indicator_type7 DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color7 clrRed 
//---- толщина линии индикатора 7 равна 3
#property indicator_width7  3
//---- отображение медвежьей метки индикатора
#property indicator_label7  "Sell Input"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 8 в виде символа
#property indicator_type8 DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован зелёный цвет
#property indicator_color8 clrLime
//---- толщина линии индикатора 8 равна 3
#property indicator_width8  3
//---- отображение бычей метки индикатора
#property indicator_label8 "Buy Input"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;     //Период графика
input int Supr_Period=6;                       //Период пробиваемого диапазона, чем больше значение, тем более поздние сигналы и реже
input int MA_Period=21;                        //Период для Heiken Ashi variable. Служит в качестве доп. фильтра
input int Risk=0;                              //Максимальный риск в пипсах для расчета уровня входа исходя из уровня ближайшего MAX/MIN
input int ATR_Period=120;                      //Период АТR. Служит для расчета уровня волатильности.
input double Q=0.7;                            //Параметр для постановки Тейка. - Доля от размера Стопа. если =1, Тейк = Стопу
input int WPR_Period=12;                       //Период WPR. Служит в качестве доп. фильтра
input int HLine=60;                            //Верхняя сигнальная линия стопов для WPR
input int LLine=40;                            //Нижняя сигнальная линия стопов для WPR
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];
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
//--- инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- получение хендла индикатора HLCrossSigForWPR
   Ind_Handle=iCustom(Symbol_,TimeFrame,"HLCrossSigForWPR",Supr_Period,MA_Period,Risk,ATR_Period,Q,WPR_Period,HLine,LLine);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора HLCrossSigForWPR");
      return(INIT_FAILED);
     }
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer8,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,NULL);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
   PlotIndexSetInteger(2,PLOT_ARROW,158);
   PlotIndexSetInteger(3,PLOT_ARROW,158);
   PlotIndexSetInteger(4,PLOT_ARROW,234);
   PlotIndexSetInteger(5,PLOT_ARROW,233);
   PlotIndexSetInteger(6,PLOT_ARROW,177);
   PlotIndexSetInteger(7,PLOT_ARROW,177);  
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   ArraySetAsSeries(ExtLineBuffer7,true);
   ArraySetAsSeries(ExtLineBuffer8,true);
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
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
   ChartRedraw(0);
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
//--- основной цикл расчета индикатора
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,ExtLineBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame,Ind_Handle,1,ExtLineBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame,Ind_Handle,2,ExtLineBuffer3,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(3,NULL,TimeFrame,Ind_Handle,3,ExtLineBuffer4,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(4,NULL,TimeFrame,Ind_Handle,4,ExtLineBuffer5,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(5,NULL,TimeFrame,Ind_Handle,5,ExtLineBuffer6,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(6,NULL,TimeFrame,Ind_Handle,6,ExtLineBuffer7,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(7,NULL,TimeFrame,Ind_Handle,7,ExtLineBuffer8,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
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
      //--- обнулим содержимое индикаторных буферов до расчета
      IndBuf[bar]=NULL;
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TimeFrame,nTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(nTime[bar]>=IndTime[0] && nTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массив Arr
         if(CopyBuffer(IndHandle,BuffNumb,nTime[bar],1,Arr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
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