//+------------------------------------------------------------------+
//|                                                AdaptiveRenko.mq5 |
//|                                    Copyright © 2010,   Svinozavr | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010,   Svinozavr"
#property link ""
#property description "Адаптивный Ренко"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано 4
#property indicator_buffers 4
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета индикатора использован DodgerBlue цвет
#property indicator_color1  DodgerBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_DASHDOTDOT
//---- толщина индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычей лэйбы индикатора
#property indicator_label1  "Lower AdaptiveRenko"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета индикатора использован Magenta цвет
#property indicator_color2  Magenta
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_DASHDOTDOT
//---- толщина индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей лэйбы индикатора
#property indicator_label2 "Upper AdaptiveRenko"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета индикатора использован Lime цвет
#property indicator_color3  Lime
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина индикатора 3 равна 4
#property indicator_width3  4
//---- отображение бычей лэйбы индикатора
#property indicator_label3  "AdaptiveRenko Support"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета индикатора использован Red цвет
#property indicator_color4  Red
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина индикатора 4 равна 4
#property indicator_width4  4
//---- отображение медвежьей лэйбы индикатора
#property indicator_label4 "AdaptiveRenko Resistance"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  объявление перечисления                     |
//+----------------------------------------------+
enum IndMode //Тип константы
  {
   ATR,     //ATR индикатор
   StDev    //StDev индикатор
  };
//+----------------------------------------------+
//|  объявление перечисления                     |
//+----------------------------------------------+
enum PriceMode //Тип константы
  {
   HighLow_, //High/Low
   Close_    //Close
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double K=1; //множитель
input IndMode Indicator=ATR; //индикатор для расчёта
input uint VltPeriod=10; // период волатильности
input PriceMode Price=Close_; //способ расчёта цены
input uint WideMin=2; // минимальная толщина кирпича в пунктах
//+----------------------------------------------+
double sens;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double DnBuffer[],UpBuffer[];
double UpTrendBuffer[],DnTrendBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//---- Объявление целых переменных для хранения хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Инициализация переменных    
   min_rates_total=int(VltPeriod);
   sens=WideMin*_Point;

   if(Indicator==ATR) Ind_Handle=iATR(NULL,0,VltPeriod);
   else  Ind_Handle=iStdDev(NULL,0,VltPeriod,0,MODE_SMA,PRICE_CLOSE);
   if(Ind_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора");

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpTrendBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpTrendBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnTrendBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnTrendBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="AdaptiveRenko";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate
(const int rates_total,
const int prev_calculated,
const datetime &Time[],
const double &Open[],
const double &High[],
const double &Low[],
const double &Close[],
const long &Tick_Volume[],
const long &Volume[],
const int &Spread[]
 )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar,trend;
   double Hi,Lo,vlt,Brick,Up,Dn;
   double IndArray[];
   static double Brick_,Up_,Dn_;
   static int trend_;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(IndArray,true);

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      if(Price==Close_) {Hi=Close[limit]; Lo=Hi;}
      else {Hi=High[limit]; Lo=Low[limit];}
      Brick_=MathMax(K*(Hi-Lo),sens);
      Up_=Hi;
      Dn_=Lo;
      trend_=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
//----   
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,0,0,to_copy,IndArray)<=0) return(RESET);
   
//---- востановление значений переменных
   Up=Up_;
   Dn=Dn_;
   Brick=Brick_;
   trend=trend_;

//---- первый цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Price==Close_) {Hi=Close[bar]; Lo=Hi;}
      else {Hi=High[bar]; Lo=Low[bar];}

      vlt=MathMax(K*IndArray[bar],sens);

      if(Hi>Up+Brick)
        {
         if(Brick) Up+=MathFloor((Hi-Up)/Brick)*Brick;
         Brick=vlt;
         Dn=Up-Brick;
        }

      if(Lo<Dn-Brick)
        {
         if(Brick) Dn-=MathFloor((Dn-Lo)/Brick)*Brick;
         Brick=vlt;
         Up=Dn+Brick;
        }

      UpBuffer[bar]=Up;
      DnBuffer[bar]=Dn;
      UpTrendBuffer[bar]=0.0;
      DnTrendBuffer[bar]=0.0;

      if(UpBuffer[bar+1]<Up) trend=+1;
      if(DnBuffer[bar+1]>Dn) trend=-1;

      if(trend>0) UpTrendBuffer[bar]=Dn-Brick;
      if(trend<0) DnTrendBuffer[bar]=Up+Brick;

      //---- сохранение значений переменных перед многократным прогоном на текущем баре
      if(bar)
        {
         Up_=Up;
         Dn_=Dn;
         Brick_=Brick;
         trend_=trend;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

    