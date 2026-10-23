//+---------------------------------------------------------------------+
//|                                                     Rainbow_HMA.mq5 | 
//|                                  Copyright © 2015, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define INDTOTAL 60 // константа для количества отображаемых индикаторов
//+----------------------------------------------+
//---- количество индикаторных буферов
#property indicator_buffers INDTOTAL 
//---- использовано всего одно графическое построение
#property indicator_plots   INDTOTAL
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве цветов линий индикатора использованы
#property indicator_color1 clrPeru
#property indicator_color2 clrPeru
#property indicator_color3 clrPeru
#property indicator_color4 clrPeru
#property indicator_color5 clrPeru
#property indicator_color6 clrPeru
#property indicator_color7 clrPeru
#property indicator_color8 clrPeru
#property indicator_color9 clrPeru
#property indicator_color10 clrPeru
//----
#property indicator_color11 clrBlue
#property indicator_color12 clrBlue
#property indicator_color13 clrBlue
#property indicator_color14 clrBlue
#property indicator_color15 clrBlue
#property indicator_color16 clrBlue
#property indicator_color17 clrBlue
#property indicator_color18 clrBlue
#property indicator_color19 clrBlue
#property indicator_color20 clrBlue
#property indicator_color21 clrBlue
//---- 
#property indicator_color22 clrAqua
#property indicator_color23 clrAqua
#property indicator_color24 clrAqua
#property indicator_color25 clrAqua
#property indicator_color26 clrAqua
#property indicator_color27 clrAqua
#property indicator_color28 clrAqua
#property indicator_color29 clrAqua
#property indicator_color30 clrAqua
#property indicator_color31 clrAqua
#property indicator_color32 clrAqua
#property indicator_color33 clrAqua
//---- 
#property indicator_color34 clrDeepPink
#property indicator_color35 clrDeepPink
#property indicator_color36 clrDeepPink
#property indicator_color37 clrDeepPink
#property indicator_color38 clrDeepPink
#property indicator_color39 clrDeepPink
#property indicator_color40 clrDeepPink
#property indicator_color41 clrDeepPink
#property indicator_color42 clrDeepPink
#property indicator_color43 clrDeepPink
#property indicator_color44 clrDeepPink
#property indicator_color45 clrDeepPink
#property indicator_color46 clrDeepPink
//---- 
#property indicator_color47 clrPurple
#property indicator_color48 clrPurple
#property indicator_color49 clrPurple
#property indicator_color50 clrPurple
#property indicator_color51 clrPurple
#property indicator_color52 clrPurple
#property indicator_color53 clrPurple
#property indicator_color54 clrPurple
#property indicator_color55 clrPurple
#property indicator_color56 clrPurple
#property indicator_color57 clrPurple
#property indicator_color58 clrPurple
#property indicator_color59 clrPurple
#property indicator_color60 clrPurple
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CMoving_Average MA[3][INDTOTAL];
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint StartLength=2; // Первая глубина усреднения
input uint StartStep=2;   // Стартовый шаг изменения усреднения 
input uint EndStep=6;     // Финишный шаг изменения усреднения                                         
input Applied_price_ IPC=PRICE_QUARTER_;// Ценовая константа
input int Shift=0;        // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0;   // Сдвиг индикатора по вертикали в пунктах
//+----------------------------------------------+
//---- объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
int hma_period[INDTOTAL],hma2_period[INDTOTAL],sqrt_period[INDTOTAL];
//+------------------------------------------------------------------+
//| Класс индикаторных буферов                                       |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
public:
   double            m_LineBuffer[];
  };
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
CIndBuffers Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| Rainbow indicator initialization function                        | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   double ratio=(EndStep-StartStep)/(INDTOTAL-1);
   hma_period[0]=int(StartLength);
   for(int count=1; count<INDTOTAL; count++) hma_period[count]+=hma_period[count-1]+int(StartStep+count*ratio);
   for(int count=0; count<INDTOTAL; count++) hma2_period[count]=int(MathFloor(hma_period[count]/2));
   for(int count=0; count<INDTOTAL; count++) sqrt_period[count]=int(MathFloor(MathSqrt(hma_period[count])));
   min_rates_total=int(hma_period[INDTOTAL-1]+sqrt_period[INDTOTAL-1]);
//---- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- превращение динамических массивов в индикаторные буферы
   for(int count=0; count<INDTOTAL; count++) SetIndexBuffer(count,Ind[count].m_LineBuffer,INDICATOR_DATA);
//---- отрисовка индикаторов в виде линий
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetInteger(count,PLOT_DRAW_TYPE,DRAW_LINE);
//---- осуществление сдвига индикаторов по горизонтали
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetInteger(count,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetInteger(count,PLOT_DRAW_BEGIN,int(hma_period[count]+sqrt_period[count]));
//---- установка значений индикатора, которые не будут видимы на графике
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetDouble(count,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- отображение меток индикаторов
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetString(count,PLOT_LABEL,"Line "+string(count+1));
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Rainbow_HMA(",StartLength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Rainbow iteration function                                       | 
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double price,lwma1,lwma2,dma;
//---- объявление целых переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);

      for(int count=0; count<INDTOTAL; count++)
        {
         lwma1=MA[0][count].LWMASeries(0,prev_calculated,rates_total,hma2_period[count],price,bar,false);
         lwma2=MA[1][count].LWMASeries(0,prev_calculated,rates_total,hma_period[count], price,bar,false);
         dma=2*lwma1-lwma2;
         Ind[count].m_LineBuffer[bar]=MA[2][count].LWMASeries(hma_period[count],prev_calculated,rates_total,sqrt_period[count],dma,bar,false)+dPriceShift;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
