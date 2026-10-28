//+------------------------------------------------------------------+
//|                                                    UltraFatl.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh                  |
//| следует положить в папку: каталог_данных_терминала\\MQL5\Include |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+ 
//|  объявление констант                         |
//+----------------------------------------------+ 
#define RESET 0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Параметры отрисовки заливки                 |
//+----------------------------------------------+
//---- отрисовка индикатора в виде заливки между двумя линиями
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов индикатора использованы цвета
#property indicator_color1  clrGray,clrMagenta,clrHotPink,clrRed,clrBrown,clrLimeGreen,clrTeal,clrLime,clrPaleGreen
//---- толщина линии индикатора равна 4
#property indicator_width1 4
//---- отображение метки индикатора
#property indicator_label1 "Ultra Fatl"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA и CFATL из файла SmoothAlgorithms.mqh
CXMA XMA[];
CFATL Fatl;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_      // Тип константы
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };
//+----------------------------------------------+
//|  объявление перечисления                     |
//+----------------------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+----------------------------------------------+
//|  объявление перечисления                     |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,       // Сплошная линия
   DASH_,        // Штриховая линия
   DOT_,         // Пунктирная линия
   DASHDOT_,     // Штрих-пунктирная линия
   DASHDOTDOT_   // Штрих-пунктирная линия с двойными точками
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_APPLIED_PRICE Applied_price=PRICE_CLOSE; // использованная цена
//----
input Smooth_Method W_Method=MODE_JJMA;             // Метод усреднения
input int StartLength=3;                            // Стартовый период усреднения                    
input int WPhase=100;                               // Параметр усреднения
//----  
input uint Step=5;                                  // Шаг изменения периода
input uint StepsTotal=10;                           // Количество изменений периода
//----
input Smooth_Method SmoothMethod=MODE_JJMA;         // Метод сглаживания
input int SmoothLength=3;                           // Глубина сглаживания
input int SmoothPhase=100;                          // Параметр сглаживания
input Applied_price_ IPC=PRICE_CLOSE_;              //ценовая константа
//----                          
input uint UpLevel=80;                              // Уровень перекупленности в %%
input uint DnLevel=20;                              // Уровень перепроданности в %%
input color UpLevelsColor=Blue;                     // Цвет уровня перекупленности
input color DnLevelsColor=Blue;                     // Цвет уровня перепроданности
input STYLE Levelstyle=DASH_;                       // Стиль уровней
input WIDTH  LevelsWidth=Width_1;                   // Толщина уровней                       
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double BullsBuffer[];
double BearsBuffer[];
double ColorBuffer[];
//---- объявление массива переменных для хранения периодов сигнальных линий индикатора WPR
int period[];
//---- объявление массивов переменных для хранения усредненных значений индикатора RSI
double invelue0[],invelue1[];
//----
double dUpLevel,dDnLevel;
//---- объявление целочисленных переменных начала отсчета данных
uint StTot1,StTot2;
int min_rates_total,min_rates_fatl,min_rates_xma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- распределение памяти под массивы переменных
   int size=int(StepsTotal+3);
   if(ArrayResize(XMA,size)<size) Print("Не удалось распределить память под массив XMA[]");
   size-=2;
   if(ArrayResize(invelue0,size)<size) Print("Не удалось распределить память под массив invelue0[]");
   if(ArrayResize(invelue1,size)<size) Print("Не удалось распределить память под массив invelue1[]");
   if(ArrayResize(period,size)<size) Print("Не удалось распределить память под массив period[]");

   ZeroMemory(invelue0);
   ZeroMemory(invelue1);
   ZeroMemory(period);

//---- инициализация переменных
   for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--) period[sm]=int(StartLength+sm*Step);
   dUpLevel=StepsTotal*UpLevel/100.0;
   dDnLevel=StepsTotal*DnLevel/100.0;

//---- установка алертов на недопустимые значения внешних переменных
   XMA[0].XMALengthCheck("StartLength", StartLength);
   XMA[0].XMAPhaseCheck("WPhase", WPhase, W_Method);
   XMA[0].XMALengthCheck("SmoothLength", SmoothLength);
   XMA[0].XMAPhaseCheck("SmoothPhase", SmoothPhase, SmoothMethod);

//---- инициализация переменных начала отсчета данных
   min_rates_fatl=40;
   min_rates_xma=min_rates_fatl+XMA[0].GetStartBars(W_Method,StartLength+Step*StepsTotal,WPhase)+1;
   min_rates_total=min_rates_xma+XMA[0].GetStartBars(SmoothMethod,SmoothLength,SmoothPhase);
   StTot1=StepsTotal+1;
   StTot2=StepsTotal+2;

//---- превращение динамического массива BullsBuffer[] в индикаторный буфер
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BullsBuffer,true);   
   
//---- превращение динамического массива BearsBuffer[] в индикаторный буфер
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BearsBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBuffer,true);
   
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//---- инициализации переменной для короткого имени индикатора
   string shortname="Ultra Fatl";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);

//---- параметры отрисовки линий  
   IndicatorSetInteger(INDICATOR_LEVELS,2);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,dUpLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,dDnLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit,bar,maxbar0,maxbar1,maxbar2;
   double upsch,dnsch,fatl,price;

//---- расчет стартового номера maxbar для функции XMASeries()
   maxbar0=rates_total-1;
   maxbar1=maxbar0-min_rates_fatl;
   maxbar2=maxbar0-min_rates_xma;

//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=maxbar0;                       // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      fatl=Fatl.FATLSeries(maxbar0,prev_calculated,rates_total,price,bar,true);

      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--)
         invelue0[sm]=XMA[sm].XMASeries(maxbar1,prev_calculated,rates_total,W_Method,WPhase,period[sm],fatl,bar,true);

      if(bar>maxbar2)
        {
         if(bar) ArrayCopy(invelue1,invelue0,0,0,WHOLE_ARRAY);
         continue;
        }

      upsch=0;
      dnsch=0;
      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--)
         if(invelue0[sm]>invelue1[sm]) upsch++;
      else                          dnsch++;

      BullsBuffer[bar]=XMA[StTot1].XMASeries(maxbar2,prev_calculated,rates_total,SmoothMethod,SmoothPhase,SmoothLength,upsch,bar,true);
      BearsBuffer[bar]=XMA[StTot2].XMASeries(maxbar2,prev_calculated,rates_total,SmoothMethod,SmoothPhase,SmoothLength,dnsch,bar,true);

      if(bar) ArrayCopy(invelue1,invelue0,0,0,WHOLE_ARRAY);
     }

//---- коррекция стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit--;
      
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=0;
      if(BullsBuffer[bar]>BearsBuffer[bar])
        {
         if(BullsBuffer[bar]>dUpLevel || BearsBuffer[bar]<dDnLevel)
           {
            if(BullsBuffer[bar+1]<=BullsBuffer[bar]) clr=7;
            else clr=8;
           }
         else
           {
            if(BullsBuffer[bar+1]<=BullsBuffer[bar]) clr=5;
            else clr=6;
           }
        }

      if(BullsBuffer[bar]<BearsBuffer[bar])
        {
         if(BullsBuffer[bar]<dDnLevel || BearsBuffer[bar]>dUpLevel)
           {
            if(BearsBuffer[bar+1]<=BearsBuffer[bar]) clr=1;
            else clr=2;
           }
         else
           {
            if(BearsBuffer[bar+1]<=BearsBuffer[bar]) clr=3;
            else clr=4;
           }
        }
      ColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
