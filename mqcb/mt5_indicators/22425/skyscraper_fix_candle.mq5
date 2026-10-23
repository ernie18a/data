//+------------------------------------------------------------------+
//|                                        Skyscraper_Fix_Candle.mq5 |
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
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrLime,clrTeal,clrBrown,clrRed
//---- отображение метки индикатора
#property indicator_label1  "Skyscraper_Fix Open;Skyscraper_Fix High;Skyscraper_Fix Low;Skyscraper_Fix Close"
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
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
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
   
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой буфер
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtColorBuffer,true);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
   
//--- инициализация индикаторов
   PlotInit(0,NULL,min_rates_total,0);

//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="Skyscraper_Fix_Candle("+string(Length)+","+DoubleToString(Kv)+","+string(HighLow)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
   return(INIT_SUCCEEDED);  
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
   double ATR[],smin0,smax0,ATRmin,ATRmax,xStep,x2Step;
   static double smin1,smax1;
   static int trend1;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Open,true);
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
      ExtOpenBuffer[bar]=Open[bar];
      ExtHighBuffer[bar]=High[bar];
      ExtLowBuffer[bar]=Low[bar];
      ExtCloseBuffer[bar]=Close[bar];
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
         if(Close[bar]>=Open[bar]) ExtColorBuffer[bar]=0;
         else ExtColorBuffer[bar]=1;
         if(bar) smax1=DBL_MAX;
        }

      else
        {
         smax0=MathMin(smax0,smax1);
         if(Close[bar]<=Open[bar]) ExtColorBuffer[bar]=3;
         else ExtColorBuffer[bar]=2;
         if(bar) smin1=DBL_MIN;
        }

      if(bar)
        {
         smin1=smin0;
         smax1=smax0;
         trend1=trend0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
