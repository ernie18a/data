//+------------------------------------------------------------------+ 
//|                                             ColorRsiMACD_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrGray,clrTeal,clrBlueViolet,clrIndianRed,clrMagenta
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "ColorRsiMACD"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора в виде трёхцветной линии
#property indicator_type2 DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color2 clrGray,clrDodgerBlue,clrMagenta
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2 3
//---- отображение метки сигнальной линии
#property indicator_label2  "Signal Line"
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
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
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
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
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Период графика
input uint    RSIPeriod=14;
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
input Smooth_Method XMA_Method=MODE_T3; //метод усреднения гистограммы
input uint Fast_XMA = 12; //период быстрого мувинга
input uint Slow_XMA = 26; //период медленного мувинга
input int XPhase=100;  //параметр усреднения мувингов,
                       //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method Signal_Method=MODE_JJMA; //метод усреднения сигнальной линии
input int Signal_XMA=9; //период сигнальной линии 
input int Signal_Phase=100; // параметр сигнальной линии,
                            //изменяющийся в пределах -100 ... +100,
//влияет на качество переходного процесса;
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//ценовая константа
input bool ReDraw=false; //повтор отображения инфомации на пустых барах
//+-----------------------------------+
//---- Объявление переменной для хранения результата инициализации индикатора
bool Init;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int XMACD_Handle;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double XMACDBuffer[],SignBuffer[],ColorXMACDBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+
//|  Получение стрингового таймфрейма                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+    
//| XMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=3;
   Init=true;

//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора ColorRsiMACD не может быть меньше периода текущего графика");
      Init=false;
      return;
     }

//---- получение хендла индикатора ColorRsiMACD
   XMACD_Handle=iCustom(Symbol(),TimeFrame,"ColorRsiMACD",RSIPeriod,RSIPrice,XMA_Method,Fast_XMA,Slow_XMA,XPhase,Signal_Method,Signal_XMA,Signal_Phase,AppliedPrice);
   if(XMACD_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorRsiMACD");
      Init=false;
      return;
     }

//---- превращение динамического массива XMACDBuffer в индикаторный буфер
   SetIndexBuffer(0,XMACDBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(XMACDBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorXMACDBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorXMACDBuffer,true);

//---- превращение динамического массива SignBuffer в индикаторный буфер
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SignBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorSignBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorSignBuffer,true);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
   CXMA XMA;
   string Smooth1=XMA.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA.GetString_MA_Method(Signal_Method);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ColorRsiMACD HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| XMACD iteration function                                         | 
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
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(XMACD_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- Объявление целых переменных
   int limit,bar;
//---- Объявление переменных с плавающей точкой  
   double XMACD[2],SIGN[2];
   datetime XMACDTime[1];
   static uint LastCountBar;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      XMACDBuffer[bar]=EMPTY_VALUE;
      SignBuffer[bar]=EMPTY_VALUE;
      ColorXMACDBuffer[bar]=0;
      ColorSignBuffer[bar]=0;

      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,XMACDTime)<=0) return(RESET);

      if(time[bar]>=XMACDTime[0] && time[bar+1]<XMACDTime[0])
        {
         LastCountBar=bar;
         
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(XMACD_Handle,0,time[bar],2,XMACD)<=0) return(RESET);
         if(CopyBuffer(XMACD_Handle,2,time[bar],2,SIGN)<=0) return(RESET);

         //---- Загрузка полученных значений в индикаторные буферы
         XMACDBuffer[bar]=XMACD[1];
         SignBuffer[bar]=SIGN[1];
         
         if(XMACDBuffer[bar]>0)
           {
            if(XMACD[1]>XMACD[0]) ColorXMACDBuffer[bar]=1;
            if(XMACD[1]<XMACD[0]) ColorXMACDBuffer[bar]=2;
           }

         if(XMACDBuffer[bar]<0)
           {
            if(XMACD[1]<XMACD[0]) ColorXMACDBuffer[bar]=3;
            if(XMACD[1]>XMACD[0]) ColorXMACDBuffer[bar]=4;
           }

         if(XMACDBuffer[bar]>SignBuffer[bar]) ColorSignBuffer[bar]=1;
         if(XMACDBuffer[bar]<SignBuffer[bar]) ColorSignBuffer[bar]=2;
        }
        
       if(ReDraw)
         {
          if(XMACDBuffer[bar+1]!=EMPTY_VALUE&&XMACDBuffer[bar]==EMPTY_VALUE)
            {
             XMACDBuffer[bar]=XMACDBuffer[bar+1];
             ColorXMACDBuffer[bar]=ColorXMACDBuffer[bar+1];
             SignBuffer[bar]=SignBuffer[bar+1];
             ColorSignBuffer[bar]=ColorSignBuffer[bar+1];
            }
         }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
