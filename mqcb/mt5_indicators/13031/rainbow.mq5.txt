//+---------------------------------------------------------------------+
//|                                                         Rainbow.mq5 | 
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
//---- использовано всего шестьдесят графических построений
#property indicator_plots   INDTOTAL
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве цветов линий индикатора использованы
#property indicator_color1 clrGold
#property indicator_color2 clrGold
#property indicator_color3 clrGold
#property indicator_color4 clrGold
#property indicator_color5 clrGold
#property indicator_color6 clrGold
#property indicator_color7 clrGold
#property indicator_color8 clrGold
#property indicator_color9 clrGold
#property indicator_color10 clrGold
//----
#property indicator_color11 clrDodgerBlue
#property indicator_color12 clrDodgerBlue
#property indicator_color13 clrDodgerBlue
#property indicator_color14 clrDodgerBlue
#property indicator_color15 clrDodgerBlue
#property indicator_color16 clrDodgerBlue
#property indicator_color17 clrDodgerBlue
#property indicator_color18 clrDodgerBlue
#property indicator_color19 clrDodgerBlue
#property indicator_color20 clrDodgerBlue
#property indicator_color21 clrDodgerBlue
//---- 
#property indicator_color22 clrLimeGreen
#property indicator_color23 clrLimeGreen
#property indicator_color24 clrLimeGreen
#property indicator_color25 clrLimeGreen
#property indicator_color26 clrLimeGreen
#property indicator_color27 clrLimeGreen
#property indicator_color28 clrLimeGreen
#property indicator_color29 clrLimeGreen
#property indicator_color30 clrLimeGreen
#property indicator_color31 clrLimeGreen
#property indicator_color32 clrLimeGreen
#property indicator_color33 clrLimeGreen
//---- 
#property indicator_color34 clrRed
#property indicator_color35 clrRed
#property indicator_color36 clrRed
#property indicator_color37 clrRed
#property indicator_color38 clrRed
#property indicator_color39 clrRed
#property indicator_color40 clrRed
#property indicator_color41 clrRed
#property indicator_color42 clrRed
#property indicator_color43 clrRed
#property indicator_color44 clrRed
#property indicator_color45 clrRed
#property indicator_color46 clrRed
//---- 
#property indicator_color47 clrDarkOrchid
#property indicator_color48 clrDarkOrchid
#property indicator_color49 clrDarkOrchid
#property indicator_color50 clrDarkOrchid
#property indicator_color51 clrDarkOrchid
#property indicator_color52 clrDarkOrchid
#property indicator_color53 clrDarkOrchid
#property indicator_color54 clrDarkOrchid
#property indicator_color55 clrDarkOrchid
#property indicator_color56 clrDarkOrchid
#property indicator_color57 clrDarkOrchid
#property indicator_color58 clrDarkOrchid
#property indicator_color59 clrDarkOrchid
#property indicator_color60 clrDarkOrchid
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1[60];
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
//| Объявление перечислений                      |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_EMA; // Метод усреднения
input uint StartLength=2; // Первая глубина усреднения
input uint StartStep=2;   // Стартовый шаг изменения усреднения 
input uint EndStep=6;     // Финишный шаг изменения усреднения                                         
input int XPhase=15;      // Параметр усреднения
                          // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                          // для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_QUARTER_;// Ценовая константа
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // Сдвиг индикатора по вертикали в пунктах
//+----------------------------------------------+
//---- объявление переменной значения вертикального сдвига скользящей средней
double dPriceShift;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
int period[INDTOTAL];
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
   period[0]=int(StartLength);
   for(int count=1; count<INDTOTAL; count++) period[count]=period[count-1]+int(StartStep+count*ratio);
   min_rates_total=int(XMA1[0].GetStartBars(XMA_Method,int(period[INDTOTAL-1]),XPhase));
//---- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- превращение динамических массивов в индикаторные буферы
   for(int count=0; count<INDTOTAL; count++) SetIndexBuffer(count,Ind[count].m_LineBuffer,INDICATOR_DATA);
//---- отрисовка индикаторов в виде линий
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetInteger(count,PLOT_DRAW_TYPE,DRAW_LINE);
//---- осуществление сдвига индикаторов по горизонтали
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetInteger(count,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetInteger(count,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetDouble(count,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- отображение меток индикаторов
   for(int count=0; count<INDTOTAL; count++) PlotIndexSetString(count,PLOT_LABEL,"Line "+string(count+1));
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1[0].GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"Rainbow(",StartLength,", ",Smooth1,")");
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
   double price;
//---- объявление целочисленных переменных и получение уже посчитанных баров
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
         Ind[count].m_LineBuffer[bar]=XMA1[count].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,period[count],price,bar,false)+dPriceShift;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
