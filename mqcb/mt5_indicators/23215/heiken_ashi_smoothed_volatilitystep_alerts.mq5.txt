//+------------------------------------------------------------------+ 
//|                   Heiken_Ashi_Smoothed_VolatilityStep_Alerts.mq5 | 
//|                                       Copyright © 2007, Eva Ruft | 
//|                                               briz18@rambler.ru/ | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, Eva Ruft"
#property link      "briz18@rambler.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
//---- в качестве цвета бычей линии индикатора использован SlateBlue цвет
#property indicator_color1 clrSlateBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1  4
//---- отображение метки индикатора
#property indicator_label1  "Heiken_Ashi_Smoothed_VolatilityStep"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Описание классов усреднений                 |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAO,XMAL,XMAH,XMAC;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
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
  }; */
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input Smooth_Method     HMA_Method=MODE_JJMA;      // Метод усреднения
input uint              HLength=5;                 // Глубина  усреднения                    
input int               HPhase=100;                // Параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int               Shift=0;                   // сдвиг индикатора по горизонтали в барах
input uint              LevelsTotal=20;            // количество уровеней
input uint              StartLevel=50;             // стартовый уровень
input uint              LevelsStep=50;             // расстояние между уровнями
input color             LevelsColor=clrDarkOrange; // цвет уровеней
input uint AlertLevel=150;                      // Уровень срабатывания
input uint NumberofBar=1;                       // Номер бара для подачи сигнала
input bool SoundON=true;                        // Разрешение алерта
input uint NumberofAlerts=2;                    // Количество алертов
input bool EMailON=false;                       // Разрешение почтовой отправки сигнала
input bool PushON=false;                        // Разрешение отправки сигнала на мобильный
input color AlertLevelColor=clrMagenta;         // цвет уровня срабатывания
//+----------------------------------------------+
//---- индикаторный буфер
double IndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Volatility indicator initialization function                     | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(HMA_Method,HLength,HPhase)+1;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname="Heiken_Ashi_Smoothed_VolatilityStep_Alerts("+string(HLength)+","+string(AlertLevel)+")";
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
   if(rates_total<min_rates_total) return(RESET);
   
//---- объявления локальных переменных 
   int first,bar;
   double XmaOpen,XmaHigh,XmaLow,XmaClose;
   double Volatility,Res,O,H,L,C;
   static double HAO_prev,HAC_prev;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчета всех баров
      HAO_prev=(open[first]+close[first])/2; 
      HAC_prev=(open[first]+high[first]+low[first]+close[first])/4;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      IndBuffer[bar]=NULL;
      //---- Четыре вызова функции XMASeries.  
      XmaOpen=XMAO.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,open[bar],bar,false);
      XmaClose=XMAC.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,close[bar],bar,false);
      XmaHigh=XMAH.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,high[bar],bar,false);
      XmaLow=XMAL.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,low[bar],bar,false);
      if(bar<min_rates_total) continue;
      //---- 
      O=(HAO_prev+HAC_prev)/2;
      C=(XmaOpen+XmaHigh+XmaLow+XmaClose)/4;
      H=MathMax(XmaHigh,MathMax(O,C));
      L=MathMin(XmaLow,MathMin(O,C));
      //---- 
      Volatility=(H-L)/_Point; 
      if(Volatility>=StartLevel)
        {
         Res=MathMax(Volatility-StartLevel,0);
         IndBuffer[bar]=StartLevel+LevelsStep*int(Res/LevelsStep);
        }
      //---- 
      if(bar<rates_total-1)
        {
         HAO_prev=O;
         HAC_prev=C;
        }
     }
//---     
   TrendSignal("Heiken_Ashi_Smoothed_VolatilityStep_Alerts",rates_total,prev_calculated,close,spread);
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
   int index=Rates_total-1-int(NumberofBar);
   int index1=Rates_total-1-int(NumberofBar)-1;
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
