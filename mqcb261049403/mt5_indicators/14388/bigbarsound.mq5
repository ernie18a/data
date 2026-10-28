//+------------------------------------------------------------------+
//|                                                  BigBarSound.mq5 |
//|                                               Alexey Volchanskiy |
//|                                         http://www.robo-forex.ru |
//+------------------------------------------------------------------+
#property copyright "Alexey Volchanskiy"
#property link      "http://www.robo-forex.ru"
#property version   "1.00"
#property strict
#property description "Indicator plays WavFile when bar size is lager of BarPoint value"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 0
#property indicator_buffers 0
//---- использовано ноль графических построений
#property indicator_plots   0
//+------------------------------------------------+
//| Объявление констант                            |
//+------------------------------------------------+
#define RESET 0                            // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "BigBarSound"       // константа для имени индикатора
//+------------------------------------------------+ 
//| Перечисление для индикации срабатывания        |
//+------------------------------------------------+ 
enum START_POINT //Тип константы
  {
   OPEN_CLOSE,   //ход цены от открытия open до close
   HIGH_LOW      //размер свечи от low до high
  };
//+------------------------------------------------+
//| Входные параметры индикатора                   |
//+------------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame   = PERIOD_H4;      // Период графика индикатора
input uint            BarPoint    = 200;            // Минимальный размер свечного хода для сигнала
input START_POINT     SP          = HIGH_LOW;       // Вариант движения
input string          WavFile     = "alert.wav";    // Имя звукового файла
input uint            TimeDeley   = 10;             // Минимальная задержка между двумя сигналами
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
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
   if(Bars(Symbol(),TimeFrame)<1) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
   int range;
   static datetime lasttime,itime;
   datetime iTime[1];
//--- копируем вновь появившиеся данные в массивы
   if(SP==HIGH_LOW)
     {
      double iLow[1],iHigh[1];
      if(CopyLow(Symbol(),TimeFrame,time[0],1,iLow)<=0) return(RESET);
      if(CopyHigh(Symbol(),TimeFrame,time[0],1,iHigh)<=0) return(RESET);
      range=int((iHigh[0]-iLow[0])/_Point);
     }
   else
     {
      double iOpen[1],iClose[1];
      if(CopyOpen(Symbol(),TimeFrame,time[0],1,iOpen)<=0) return(RESET);
      if(CopyClose(Symbol(),TimeFrame,time[0],1,iClose)<=0) return(RESET);
      range=int((MathAbs(iClose[0]-iOpen[0]))/_Point);
     }
   if(CopyTime(Symbol(),TimeFrame,time[0],1,iTime)<=0) return(RESET);
   if(iTime[0]!=itime)
     {
      lasttime=NULL;
      itime=iTime[0];
     }
//---
   if(TimeCurrent()-lasttime>=TimeDeley && range>int(BarPoint))
     {
      PlaySound(WavFile);
      lasttime=TimeCurrent();
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
