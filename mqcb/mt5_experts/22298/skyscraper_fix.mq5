//+------------------------------------------------------------------+
//|                                               Skyscraper_Fix.mq5 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                       E-mail: igorad2004@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
#property description "Индикатор торговой системы pabloski."
//---- номер версии индикатора
#property version   "1.20"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
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
#property indicator_label1  "Upper Skyscraper"
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
#property indicator_label2 "Lower Skyscraper"
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
#property indicator_type5   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы
#property indicator_color5  clrTeal,clrFireBrick
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
double LineBuffer[],ColorLineBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
int ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных 
   int ATR_Period=15;
   min_rates_total=ATR_Period+int(Length+1);
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }  
   
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
   SetIndexBuffer(2,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,172);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,172);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
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
//---- превращение динамического массива в цветовой буфер
   SetIndexBuffer(5,ColorLineBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorLineBuffer,true);

//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="Skyscraper_Fix("+string(Length)+","+DoubleToString(Kv)+","+string(HighLow)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
   return(INIT_SUCCEEDED);  
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit,trend0,Step,to_copy;
   double ATR[],smin0,smax0,ATRmin,ATRmax,xStep,x2Step,Line;
   static double smin1,smax1;
   static int trend1;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(ATR,true);

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      smin1=Close[limit];
      smax1=Close[limit];
      trend1=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
//----
   to_copy=limit+1+int(Length);
 
//--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- первый цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpBuffer[bar]=DnBuffer[bar]=NULL;
      trend0=trend1;

      ATRmax=ATR[ArrayMaximum(ATR,bar,Length)];
      ATRmin=ATR[ArrayMinimum(ATR,bar,Length)];
      Step=int(0.5*Kv*(ATRmax+ATRmin)/_Point);

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
         LineBuffer[bar]=MathMax(Line-Percentage/100.0*Step*_Point,LineBuffer[bar+1]);
         ColorLineBuffer[bar]=0;
         if(bar) smax1=DBL_MAX;
        }

      else
        {
         smax0=MathMin(smax0,smax1);
         DnBuffer[bar]=smax0;
         Line=smax0-Step*_Point;
         LineBuffer[bar]=MathMin(Line+Percentage/100.0*Step*_Point,LineBuffer[bar+1]);
         ColorLineBuffer[bar]=1;
         if(bar) smin1=DBL_MIN;
        }

      if(bar)
        {
         smin1=smin0;
         smax1=smax0;
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
      //----
      if(UpBuffer[bar+1] && DnBuffer[bar]) SellBuffer [bar]=DnBuffer[bar];
      if(DnBuffer[bar+1] && UpBuffer[bar]) BuyBuffer[bar]=UpBuffer[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
