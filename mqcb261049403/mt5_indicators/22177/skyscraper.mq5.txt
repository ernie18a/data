//+------------------------------------------------------------------+
//|                                                   Skyscraper.mq5 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
#property description "Индикатор торговой системы pabloski."
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета индикатора использован LimeGreen цвет
#property indicator_color1  clrLimeGreen
//---- толщина индикатора 1 равна 2
#property indicator_width1  2
//---- отображение бычей метки индикатора
#property indicator_label1  "Lower Skyscraper"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета индикатора использован DeepPink цвет
#property indicator_color2  clrDeepPink
//---- толщина индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Upper Skyscraper"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета индикатора использован LimeGreen цвет
#property indicator_color3  clrLimeGreen
//---- толщина индикатора 3 равна 5
#property indicator_width3  5
//---- отображение бычей метки индикатора
#property indicator_label3  "Skyscraper Buy"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован DeepPink цвет
#property indicator_color4  clrDeepPink
//---- толщина индикатора 4 равна 5
#property indicator_width4  5
//---- отображение медвежьей метки индикатора
#property indicator_label4 "Skyscraper Sell"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован SlateBlue цвет
#property indicator_color5  clrSlateBlue
//---- толщина индикатора 5 равна 1
#property indicator_width5  1
//---- отображение медвежьей метки индикатора
#property indicator_label5 "Skyscraper Middle"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Method
  {
   MODE_HighLow,  //High/Low
   MODE_Close     //Close
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint    Length=10;             // Период ATR
input double  Kv=0.9;                // Фактор чувствительности индикатора
input double  Percentage=0;          // Приближение средней линии к линиям экстремумов
input Method  HighLow=MODE_HighLow;  // Расчёт индикатора по High/Low или Close
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double BuyBuffer[],SellBuffer[];
double UpBuffer[],DnBuffer[];
double LineBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Инициализация переменных    
   min_rates_total=int(Length+1);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,172);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,172);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,LineBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,172);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LineBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);

//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="Skyscraper("+string(Length)+","+DoubleToString(Kv)+","+string(HighLow)+")";
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
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit,trend0,Step;
   double smin0,smax0,ATRmin0=0.0,ATRmax0=0.0,AvgRange,ATR0,xStep,x2Step,Line;
   static double smin1,smax1,ATRmin1,ATRmax1;
   static int trend1;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      ATRmax1=DBL_MIN;
      ATRmin1=DBL_MAX;
      smin1=Close[limit];
      smax1=Close[limit];
      trend1=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
//----

//----   

//---- первый цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpBuffer[bar]=0.0;
      DnBuffer[bar]=0.0;
      trend0=trend1;

      AvgRange=0;
      for(int iii=0; iii<int(Length); iii++) AvgRange+=(High[bar+iii]-Low[bar+iii]);
      ATR0=AvgRange/Length;

      ATRmax0=MathMax(ATRmax1,ATR0);
      ATRmin0=MathMin(ATRmin1,ATR0);
      Step=int(0.5*Kv*(ATRmax0+ATRmin0)/_Point);

      xStep=Step*_Point;
      x2Step=2.0*xStep;

      if(HighLow==MODE_HighLow)
        {
         smax0=Low[bar]+x2Step;
         smin0=High[bar]-x2Step;
        }
      else
        {
         smax0=Close[bar]+x2Step;
         smin0=Close[bar]-x2Step;
        }

      if(Close[bar]>smax1) trend0=+1;
      if(Close[bar]<smin1) trend0=-1;

      if(trend0>0)
        {
         smin0=MathMax(smin0,smin1);
         UpBuffer[bar]=smin0;
         Line=smin0+Step*_Point;
         LineBuffer[bar]=Line-Percentage/100.0*Step*_Point;
        }

      else
        {
         smax0=MathMin(smax0,smax1);
         DnBuffer[bar]=smax0;
         Line=smax0-Step*_Point;
         LineBuffer[bar]=Line+Percentage/100.0*Step*_Point;
        }

      if(bar)
        {
         smin1=smin0;
         smax1=smax0;
         ATRmax1=ATRmax0;
         ATRmin1=ATRmin0;
         trend1=trend0;
        }
     }

//---- пересчёт стартового номера для расчёта всех баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора     
      limit--;

//---- второй цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      BuyBuffer[bar]=SellBuffer[bar]=NULL;

      if(UpBuffer[bar+1] && DnBuffer[bar]) BuyBuffer [bar]=DnBuffer[bar];
      if(DnBuffer[bar+1] && UpBuffer[bar]) SellBuffer[bar]=UpBuffer[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
