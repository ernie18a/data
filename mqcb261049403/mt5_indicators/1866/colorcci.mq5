//+------------------------------------------------------------------+
//|                                                     ColorCCI.mq5 |
//|                                         Copyright © 2013, ArtONE | 
//|                                                     artone@bk.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, ArtONE"
#property link "artone@bk.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графические построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде трехцветной линии
#property indicator_type1 DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1 clrRed,clrGold,clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "ColorCCI"
#property indicator_type2   DRAW_LINE
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum WIDTH //Тип константы
  {
   W1 = 1,     //1
   W2,         //2
   W3,         //3
   W4,         //4
   W5          //5
  };
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum STYLE //Тип константы
  {
   SOLID = 0,     //Сплошная линия
   DASH,          //Прерывистая линия
   DOT,           //Пунктир
   DASHDOT,       //Штрих-пунктир
   DASHDOTDOT     //Штрих-две точки
  };
//+-----------------------------------+
//|  Входные параметры индикатора     |
//+-----------------------------------+
input int iCCIPeriod=14;                              // Период CCI
input ENUM_APPLIED_PRICE   iCCIPrice=PRICE_TYPICAL;   // Ценовая таймсерия 
input int iHighLevel=100;                             // Уровень перезакупа
input int iMiddleLevel=0;                             // Середина диапазона
input int iLowLevel=-100;                             // Уровень перепроданности
input color iColor=clrDarkGray;                       // Цвет уровней
input STYLE iStyle=STYLE_DOT;                         // Стиль исполнения уровней
input WIDTH iWidth=W1;                                // Ширина уровней

//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double ColorBuffer[],ExtLineBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int CCI_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int HighLevel,MiddleLevel,LowLevel;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчёта данных
   min_rates_total=iCCIPeriod;
//---- инициализация переменных 
   HighLevel=MathMin(100,MathMax(0,iHighLevel));
   MiddleLevel=MathMin(100,MathMax(0,iMiddleLevel));
   LowLevel=MathMin(-100,MathMax(0,iLowLevel));

//---- получение хендла индикатора iCCI
   CCI_Handle=iCCI(NULL,0,iCCIPeriod,iCCIPrice);
   if(CCI_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iCCI");

//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ColorCCI(",iCCIPeriod,")");
//---- создание метки для отображения в Окне данных
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);

//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);

//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,iColor);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,iColor);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,iStyle);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,iStyle);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,iStyle);
//---- толщина линий уровней
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,int(iWidth));
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,int(iWidth));
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2,int(iWidth));
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(CCI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar,clr;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- расчет необходимого количества копируемых данных
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(CCI_Handle,0,0,to_copy,ExtLineBuffer)<=0) return(RESET);

//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      clr=1;
      double res=ExtLineBuffer[bar];

      if(res>HighLevel) clr=2;
      else if(res<LowLevel) clr=0;

      ColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
