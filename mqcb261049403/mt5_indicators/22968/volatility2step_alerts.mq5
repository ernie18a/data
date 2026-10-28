//+------------------------------------------------------------------+ 
//|                                       Volatility2Step_Alerts.mq5 | 
//|                                       Copyright © 2007, Eva Ruft | 
//|                                               briz18@rambler.ru/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, Eva Ruft"
#property link      "briz18@rambler.ru"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- зафиксирован нихний предел отображения индикатора
#property indicator_minimum 0
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован BlueViolet цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1  4
//---- отображение метки индикатора
#property indicator_label1  "Volatility2Step"
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input  ENUM_MA_METHOD   MAType=MODE_SMA;           // метод усреднения
input uint              VolatilityPeriod=5;        // период индикатора
input int               Shift=0;                   // сдвиг индикатора по горизонтали в барах
input uint              LevelsTotal=20;            // количество уровеней
input uint              StartLevel=25;             // стартовый уровень
input uint              LevelsStep=25;             // расстояние между уровнями
input color             LevelsColor=clrDarkOrange; // цвет уровеней
input uint AlertLevel=150;                      // Уровень срабатывания
input uint NumberofBar=1;                       // Номер бара для подачи сигнала
input bool SoundON=true;                        // Разрешение алерта
input uint NumberofAlerts=2;                    // Количество алертов
input bool EMailON=false;                       // Разрешение почтовой отправки сигнала
input bool PushON=false;                        // Разрешение отправки сигнала на мобильный
input color AlertLevelColor=clrMediumSeaGreen;  // цвет уровня срабатывания
//+-----------------------------------+
//---- индикаторный буфер
double IndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int HMA_Handle,LMA_Handle;
//+------------------------------------------------------------------+    
//| Volatility indicator initialization function                     | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(VolatilityPeriod);

//---- получение хендла индикатора iMA
   HMA_Handle=iMA(NULL,0,VolatilityPeriod,0,MAType,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iMA");

//---- получение хендла индикатора iMA
   LMA_Handle=iMA(NULL,0,VolatilityPeriod,0,MAType,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iMA");

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname="Volatility2Step_Alerts("+string(VolatilityPeriod)+")";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- количество  горизонтальных уровней индикатора LevelsTotal   
   IndicatorSetInteger(INDICATOR_LEVELS,LevelsTotal+1);
   for(int numb=0; numb<int(LevelsTotal); numb++)
     {
      int level=int(StartLevel+LevelsStep*numb);
      //---- значения горизонтальных уровней индикатора   
      IndicatorSetDouble(INDICATOR_LEVELVALUE,numb,level);
      //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,numb,LevelsColor);
      //---- в линии горизонтального уровня использован короткий штрих-пунктир  
      IndicatorSetInteger(INDICATOR_LEVELSTYLE,numb,STYLE_DASHDOTDOT);
     }
//---- значения уровня срабатывания индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,LevelsTotal,AlertLevel);
//---- в качестве цвета линии уровня срабатывания ипользован цвет  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,LevelsTotal,AlertLevelColor);
//---- в линии уровня срабатывания использована сплошная линия 
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,LevelsTotal,STYLE_SOLID);
//---- толщина линии уровня срабатывания 
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,LevelsTotal,3);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Volatility iteration function                                    | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double HMA[],LMA[],Volatility,Res;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчёта только новых баров

   to_copy=limit+1;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(spread,true);

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Volatility=(HMA[bar]-LMA[bar])/_Point;
      IndBuffer[bar]=NULL;
      if(Volatility>=StartLevel)
        {
         Res=MathMax(Volatility-StartLevel,0);
         IndBuffer[bar]=StartLevel+LevelsStep*int(Res/LevelsStep);
        }
     }
//---     
   TrendSignal("Volatility2Step_Alerts",rates_total,prev_calculated,close,spread);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| TrendSignal function                                             |
//+------------------------------------------------------------------+
void TrendSignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
                 const int Rates_total,     // текущее количество баров
                 const int Prev_calculated, // количество баров на предыдущем тике
                 const double &Close[],     // цена закрытия
                 const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   string SignalText="";
   bool Signal=false;
   int index=int(NumberofBar);
   int index1=int(NumberofBar)+1;
//--- 
   if(IndBuffer[index1]<=AlertLevel && IndBuffer[index]>AlertLevel)
     {
      Signal=true;
      SignalText=SignalText+"Усиление тренда: Округлённая волатильность на баре номер "+string(NumberofBar)+" превысила уровень "+string(AlertLevel)+"!";
     }
//---              
   if(Signal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      double Ask=Close[index];
      double Bid=Close[index];
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SoundON) Alert(SignalText+"\n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail(SignalSirname+": "+SignalText," at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification(SignalSirname+": "+SignalText+" at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
     }

//---
  }
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
