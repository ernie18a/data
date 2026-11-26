//+------------------------------------------------------------------+
//|                                            AdaptiveRenko_Cld.mq5 |
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
//---- для расчёта и отрисовки индикатора использовано 8 буферов
#property indicator_buffers 8
//---- использовано всего cемь графических построений
#property indicator_plots   7
//+----------------------------------------------+
//|  Параметры отрисовки облака индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака индикатора использован 240,240,251
#property indicator_color1  C'240,240,251'
//---- отображение метки индикатора
#property indicator_label1  "AdaptiveRenko channel Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_DASHDOTDOT
//---- толщина индикатора 2 равна 1
#property indicator_width2  1
//---- отображение бычей метки индикатора
#property indicator_label2  "Lower AdaptiveRenko"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета индикатора использован Magenta цвет
#property indicator_color3  clrMagenta
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_DASHDOTDOT
//---- толщина индикатора 3 равна 1
#property indicator_width3  1
//---- отображение медвежьей метки индикатора
#property indicator_label3 "Upper AdaptiveRenko"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета индикатора использован Lime цвет
#property indicator_color4  clrLime
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина индикатора 4 равна 2
#property indicator_width4  2
//---- отображение бычей метки индикатора
#property indicator_label4  "AdaptiveRenko Support"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета индикатора использован Red цвет
#property indicator_color5  clrRed
//---- линия индикатора - сплошная
#property indicator_style5 STYLE_SOLID
//---- толщина индикатора 5 равна 2
#property indicator_width5  2
//---- отображение медвежьей метки индикатора
#property indicator_label5 "AdaptiveRenko Resistance"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета индикатора использован Lime цвет
#property indicator_color6  clrLime
//---- толщина индикатора 6 равна 2
#property indicator_width6  2
//---- отображение бычей метки индикатора
#property indicator_label6  "AdaptiveRenko Support Arrow"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 7 в виде значка
#property indicator_type7   DRAW_ARROW
//---- в качестве цвета индикатора использован Red цвет
#property indicator_color7  clrRed
//---- толщина индикатора 7 равна 2
#property indicator_width7  2
//---- отображение медвежьей метки индикатора
#property indicator_label7 "AdaptiveRenko Resistance Arrow"
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
input double K=1.000001;                  //множитель
input IndMode Indicator=ATR;              //индикатор для расчёта
input uint VltPeriod=10;                  //период волатильности
input PriceMode Price=Close_;             //способ расчёта цены
input uint WideMin=2;                     //минимальная толщина кирпича в пунктах
//+----------------------------------------------+
double sens;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double DnBuffer[],UpBuffer[],DnClBuffer[],UpClBuffer[];
double UpTrendBuffer[],DnTrendBuffer[],UpTrendArBuffer[],DnTrendArBuffer[];
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
   SetIndexBuffer(0,UpClBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpClBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnClBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnClBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,UpTrendBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpTrendBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,DnTrendBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnTrendBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,UpTrendArBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpTrendArBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,DnTrendArBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 7
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnTrendArBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,NULL);

//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="AdaptiveRenko_Cld("+DoubleToString(K,3)+","+EnumToString(Indicator)+","
                                    +string(VltPeriod)+","+EnumToString(Price)+","+string(WideMin)+")";
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

      UpBuffer[bar]=UpClBuffer[bar]=Up;
      DnBuffer[bar]=DnClBuffer[bar]=Dn;
      UpTrendBuffer[bar]=DnTrendBuffer[bar]=UpTrendArBuffer[bar]=DnTrendArBuffer[bar]=NULL;

      if(UpBuffer[bar+1]<Up) trend=+1;
      if(DnBuffer[bar+1]>Dn) trend=-1;

      if(trend>0) UpTrendArBuffer[bar]=UpTrendBuffer[bar]=Dn-Brick;
      if(trend<0) DnTrendArBuffer[bar]=DnTrendBuffer[bar]=Up+Brick;

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

    