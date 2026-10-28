//+------------------------------------------------------------------+ 
//|                                  PriceChannel_Stop_Digit_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "PriceChannel_Stop_Digit с возможностью изменения таймфрейма во входных параметрах"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                       // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "PriceChannel_Stop_Digit"      // Константа для имени индикатора
#define SIZE 1                                        // Константа для количества вызовов функции CountIndicator коде
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета символа входа использован розовый цвет
#property indicator_color1  Magenta
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора 1
#property indicator_label1  "SellSignal"

//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета символов стоплоссов использован розовый цвет
#property indicator_color2  Magenta
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки индикатора 2
#property indicator_label2 "SellStopSignal"

//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии стоплоссов использован розовый цвет
#property indicator_color3  Magenta
//---- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//---- отображение метки индикатора 3
#property indicator_label3 "SellStopLine"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета символа входа использован светло-зеленый цвет
#property indicator_color4  Lime
//---- толщина линии индикатора 4 равна 1
#property indicator_width4  1
//---- отображение метки индикатора 4
#property indicator_label4  "BuySignal"

//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета символов стоплоссов использован светло-зеленый цвет
#property indicator_color5  Lime
//---- толщина линии индикатора 5 равна 1
#property indicator_width5  1
//---- отображение метки индикатора 5
#property indicator_label5 "BuyStopSignal"

//---- отрисовка индикатора 6 в виде символа
#property indicator_type6   DRAW_LINE
//---- в качестве цвета линии стоплоссов использован светло-зеленый цвет
#property indicator_color6  Lime
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение метки индикатора 6
#property indicator_label6 "BuyStopLine"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;    // Период графика индикатора (таймфрейм)
input string  SirName="PriceChannel_Stop_Digit";     //Первая часть имени графических объектов
input int ChannelPeriod=5;
input double Risk=0.10;
input bool Signal=true;
input bool Line=true;
input uint Digit=2; //количество разрядов округления
input bool ShowPrice=true; //показывать ценовые метки
//---- цвета ценовых меток
input color Price_color=clrBlue;
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer1[];
double IndBuffer2[];
double IndBuffer3[];
double IndBuffer4[];
double IndBuffer5[];
double IndBuffer6[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
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
//--- получение хендла индикатора PChannel
   Ind_Handle=iCustom(Symbol(),TimeFrame,"PriceChannel_Stop_Digit",SirName,ChannelPeriod,Risk,Signal,Line,Digit,ShowPrice,Price_color);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора PChannel");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,IndBuffer1,INDICATOR_DATA);
   IndInit(1,IndBuffer2,INDICATOR_DATA);
   IndInit(2,IndBuffer3,INDICATOR_DATA);
   IndInit(3,IndBuffer4,INDICATOR_DATA);
   IndInit(4,IndBuffer5,INDICATOR_DATA);
   IndInit(5,IndBuffer6,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,0.0,0,Shift);
   PlotInit(1,0.0,0,Shift);
   PlotInit(2,0.0,0,Shift);
   PlotInit(3,0.0,0,Shift);
   PlotInit(4,0.0,0,Shift);
   PlotInit(5,0.0,0,Shift);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,108);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW,108);
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
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
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,
      0,IndBuffer1,1,IndBuffer2,2,IndBuffer3,3,IndBuffer4,4,IndBuffer5,5,IndBuffer6,
      time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//--- индексация элементов в буфере как в таймсерии
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
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb1,       // Номер 1 буфера обрабатываемого индикатора
                    double&  IndBuf1[],       // Приемный 1 буфер индикатора
                    uint     BuffNumb2,       // Номер 2 буфера обрабатываемого индикатора
                    double&  IndBuf2[],       // Приемный 2 буфер индикатора
                    uint     BuffNumb3,       // Номер 3 буфера обрабатываемого индикатора
                    double&  IndBuf3[],       // Приемный 3 буфер индикатора
                    uint     BuffNumb4,       // Номер 4 буфера обрабатываемого индикатора
                    double&  IndBuf4[],       // Приемный 4 буфер индикатора                    
                    uint     BuffNumb5,       // Номер 5 буфера обрабатываемого индикатора
                    double&  IndBuf5[],       // Приемный 5 буфер индикатора
                    uint     BuffNumb6,       // Номер 6 буфера обрабатываемого индикатора
                    double&  IndBuf6[],       // Приемный 6 буфер индикатора
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
         double Arr1[1],Arr2[1],Arr3[1],Arr4[1],Arr5[1],Arr6[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb1,iTime[bar],1,Arr1)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb2,iTime[bar],1,Arr2)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb3,iTime[bar],1,Arr3)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb4,iTime[bar],1,Arr4)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb5,iTime[bar],1,Arr5)<=0) return(RESET);
         if(CopyBuffer(IndHandle,BuffNumb6,iTime[bar],1,Arr6)<=0) return(RESET);
         //---         
         IndBuf1[bar]=Arr1[0];
         IndBuf2[bar]=Arr2[0];
         IndBuf3[bar]=Arr3[0];
         IndBuf4[bar]=Arr4[0];
         IndBuf5[bar]=Arr5[0];
         IndBuf6[bar]=Arr6[0];
        }
      else
        {
         IndBuf1[bar]=IndBuf1[bar+1];
         IndBuf2[bar]=IndBuf2[bar+1];
         IndBuf3[bar]=IndBuf3[bar+1];
         IndBuf4[bar]=IndBuf4[bar+1];
         IndBuf5[bar]=IndBuf5[bar+1];
         IndBuf6[bar]=IndBuf6[bar+1];
        }
     }
//--- 
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Период графика индикатора (таймфрейм)
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
