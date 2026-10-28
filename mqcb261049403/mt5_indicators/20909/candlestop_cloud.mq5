//+------------------------------------------------------------------+
//|                                             CandleStop_Cloud.mq5 |
//|                                         Copyright © 2009, CrushD |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, CrushD"
#property link "CrushD"
#property description "Индикатор для подтягивания трейлинстопов с цветовым фоновым заполнением канала и с отображением последних значений в виде ценовых меток"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 7
#property indicator_buffers 7 
//---- использовано всего 5 графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrAquamarine
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color2  clrLightPink
//---- отображение метки индикатора
#property indicator_label2  "Lower Cloud"
//+--------------------------------------------+
//|  Параметры отрисовки центральной линии     |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован SlateBlue цвет
#property indicator_color3 clrSlateBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение лэйбы индикатора
#property indicator_label3  "Middle Candle Stop"

//+--------------------------------------------+
//|  Параметры отрисовки индикатора уровней    |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//---- ввыбор цветов уровней
#property indicator_color4  clrLimeGreen
#property indicator_color5  clrDeepPink
//---- уровни - непрерывные кривые
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
//---- толщина уровней равна 1
#property indicator_width4  1
#property indicator_width5  1
//---- отображение меток уровней
#property indicator_label4  "Upper Trail Stop"
#property indicator_label5  "Lower Trail Stop"

//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint UpTrailPeriods=5; //Период поиска для хая               
input uint DnTrailPeriods=5; //Период поиска для лоу
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//---- цвета ценовых меток
input color  Middle_color=clrBlue;
input color  Upper_color=clrMediumSeaGreen;
input color  Lower_color=clrRed;
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов уровней
double ExtLineBuffer0[],ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[],ExtLineBuffer6[];

//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление стрингов для текстовых меток
string upper_name,middle_name,lower_name;
//+------------------------------------------------------------------+   
//| CandleStop initialization function                               | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(UpTrailPeriods,DnTrailPeriods));
//---- Инициализация стрингов
   upper_name="CandleStop_Cloud Upper text lable";
   middle_name="CandleStop_Cloud middle text lable";
   lower_name="CandleStop_Cloud lower text lable";
//---- инициализация индикаторных буферов   
   BufferInit(0,ExtLineBuffer0);
   BufferInit(1,ExtLineBuffer1);
   BufferInit(2,ExtLineBuffer2);
   BufferInit(3,ExtLineBuffer3);
   BufferInit(4,ExtLineBuffer4);
   BufferInit(5,ExtLineBuffer5);
   BufferInit(6,ExtLineBuffer6);
//---- инициализация индикаторов   
   IndInit(0,EMPTY_VALUE,min_rates_total,Shift);
   IndInit(1,EMPTY_VALUE,min_rates_total,Shift);
   IndInit(2,EMPTY_VALUE,min_rates_total,Shift);
   IndInit(3,EMPTY_VALUE,min_rates_total,Shift);
   IndInit(4,EMPTY_VALUE,min_rates_total,Shift);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"CandleStop_Cloud");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,upper_name);
   ObjectDelete(0,middle_name);
   ObjectDelete(0,lower_name);
//----
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void BufferInit(int Number,double &Buffer[])
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
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
  }
//+------------------------------------------------------------------+ 
//| CandleStop iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double HH,LL,HL;
//---- Объявление целых переменных и получение
   int limit,bar;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(time,true);

//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HH=high[ArrayMaximum(high,bar,UpTrailPeriods)];
      LL=low [ArrayMinimum(low, bar,DnTrailPeriods)];
      HL=(HH+LL)/2.0;    
      
      ExtLineBuffer0[bar]=ExtLineBuffer5[bar]=HH;
      ExtLineBuffer1[bar]=ExtLineBuffer2[bar]=ExtLineBuffer4[bar]=HL;
      ExtLineBuffer3[bar]=ExtLineBuffer6[bar]=LL;
     }
     
   SetRightPrice(0,middle_name,0,time[0],ExtLineBuffer1[0],Middle_color,"Georgia");
   SetRightPrice(0,upper_name,0,time[0],ExtLineBuffer0[0],Upper_color,"Georgia");
   SetRightPrice(0,lower_name,0,time[0],ExtLineBuffer3[0],Lower_color,"Georgia");
//----  
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color,             // Text color
                      string   Font               // Text font
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,2);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color,             // Text color
                   string   Font               // Text font
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,Font);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
