//+------------------------------------------------------------------+
//|                                                        WATR.mq5  |
//|                      Written WizardSerg under article konkop in  |
//|                                        "Modern trading" #4/2001  |
//|                                  http://www.wizardserg.inweb.ru  |
//|                                              wizardserg@mail.ru  |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Written WizardSerg under article konkop in <Modern trading> #4/2001"
//---- ссылка на сайт автора
#property link      "http://www.wizardserg.inweb.ru"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано 4 графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован DodgerBlue цвет
#property indicator_color1  clrDodgerBlue
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение бычей метки индикатора
#property indicator_label1  "Upper WATR"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета медвежей линии индикатора использован Coral цвет
#property indicator_color2  clrCoral
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Lower WATR"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован Aqua цвет
#property indicator_color3  clrAqua
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 4
#property indicator_width3  4
//---- отображение бычей метки индикатора
#property indicator_label3  "Upper WATR"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежей линии индикатора использован Magenta цвет
#property indicator_color4  clrMagenta
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 4
#property indicator_width4  4
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Lower WATR"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int    WATR_K = 10;
input double WATR_M = 4.0;
input int    ATR=21;
input int    Shift=0; // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//---- Объявление целых переменных для хендлов индикаторов
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
bool AntiTrendBar(const double &Open[],const double &Close[],int bar)
  {
//----
   bool res=(TrendUp(Close,bar) && (Close[bar]<Open[bar])) || (!TrendUp(Close,bar) && (Close[bar]>Open[bar]));
//----   
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
double CalcIndicValue(double &ATRArray[],const double &Close[],int bar,bool trend)
  {
//----
   double res=Close[bar];
   if(trend)res -= (WATR_K*_Point + WATR_M*ATRArray[bar]);
   else     res += (WATR_K*_Point + WATR_M*ATRArray[bar]);
//----   
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
bool TrendUp(const double &Close[],int bar)
  {
//----
   return((Close[bar+1]>ExtMapBufferUp[bar+1]) && (ExtMapBufferUp[bar+1]!=EMPTY_VALUE));
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR);
   if(ATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=ATR;
//---- превращение динамического массива ExtMapBufferUp в индикаторный буфер
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper WATR");
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива ExtMapBufferDown в индикаторный буфер
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Lower WATR");
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива ExtMapBufferUp1 в индикаторный буфер
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Upper WATR");
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,108);

//---- превращение динамического массива ExtMapBufferDown1 в индикаторный буфер
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"Lower WATR");
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,108);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"WATR(",WATR_K,", ",WATR_M,", ",ATR,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,to_copy,bar;
   double iATR_[];

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(iATR_,true);

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      to_copy=rates_total;
      ExtMapBufferUp[limit+1]=close[limit+1]-WATR_K*_Point;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      to_copy=limit+1;
     }

//---- копируем вновь появившиеся данные в массив iATR_[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,iATR_)<=0) return(0);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0; bar--)
     {
      if(AntiTrendBar(open,close,bar))
        {
         ExtMapBufferUp[bar]=ExtMapBufferUp[bar+1];
         ExtMapBufferDown[bar]=ExtMapBufferDown[bar+1];
        }
      else
        {
         if(TrendUp(close,bar))
           {
            ExtMapBufferUp[bar]=CalcIndicValue(iATR_,close,bar,true);

            if(ExtMapBufferUp[bar]<ExtMapBufferUp[bar+1])
              {
               ExtMapBufferUp[bar]=ExtMapBufferUp[bar+1];
              }
            ExtMapBufferDown[bar]=EMPTY_VALUE;
           }
         else
           {
            ExtMapBufferDown[bar]=CalcIndicValue(iATR_,close,bar,false);
            ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];

            if(ExtMapBufferDown[bar]>ExtMapBufferDown[bar+1])
              {
               ExtMapBufferDown[bar]=ExtMapBufferDown[bar+1];
              }
            ExtMapBufferUp[bar]=EMPTY_VALUE;
           }
        }
      // пересечения с ценой                 
      if(TrendUp(close,bar) && (close[bar]<ExtMapBufferUp[bar]))
        {
         ExtMapBufferDown[bar]=CalcIndicValue(iATR_,close,bar,false);
         ExtMapBufferUp[bar]=EMPTY_VALUE;
        }
      if((!TrendUp(close,bar)) && (close[bar]>ExtMapBufferDown[bar]))
        {
         ExtMapBufferUp[bar]=CalcIndicValue(iATR_,close,bar,true);
         ExtMapBufferDown[bar]=EMPTY_VALUE;
        }

      ExtMapBufferUp1[bar]=EMPTY_VALUE;
      ExtMapBufferDown1[bar]=EMPTY_VALUE;

      if(ExtMapBufferUp[bar+1]==EMPTY_VALUE && ExtMapBufferUp[bar]!=EMPTY_VALUE)
         ExtMapBufferUp1[bar]=ExtMapBufferUp[bar];

      if(ExtMapBufferDown[bar+1]==EMPTY_VALUE && ExtMapBufferDown[bar]!=EMPTY_VALUE)
         ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
