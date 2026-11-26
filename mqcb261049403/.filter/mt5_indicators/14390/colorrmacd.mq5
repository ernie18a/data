//+---------------------------------------------------------------------+ 
//|                                                      ColorRMACD.mq5 | 
//|                                  Copyright © 2010, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//| Параметры отрисовки индикатора 1  |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырехцветной гистограммы использованы
#property indicator_color1 clrGray,clrTeal,clrBlueViolet,clrIndianRed,clrMagenta
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "RMACD"
//+-----------------------------------+
//| Параметры отрисовки индикатора 2  |
//+-----------------------------------+
//---- отрисовка индикатора в виде трехцветной линии
#property indicator_type2 DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color2 clrGray,clrLime,clrRed
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style2 STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 3
#property indicator_width2 3
//---- отображение метки сигнальной линии
#property indicator_label2  "Signal Line"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Описание классов усреднений       |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------+
//| Объявление перечислений           |
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
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint Fast_RVI=12;  // Период быстрой средней
input uint Slow_TRVI=26; // Период медленной средней
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; // Объем
input Smooth_Method Signal_Method=MODE_JJMA; // Метод усреднения сигнальной линии
input uint Signal_XMA=9; // Период сигнальной линии
input int Signal_Phase=100; // Параметр сигнальной линии
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input uint AlertCount=0; // Количество подаваемых алертов
//+-----------------------------------+
//---- объявление целочисленных переменных для хранения хендлов индикаторов
int RVI_Handle,TRVI_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double RMACDBuffer[],SignBuffer[],ColorRMACDBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+
//| Описание функции iPriceSeries                                    |
//| Описание класса Moving_Average                                   | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| RMACD indicator initialization function                          | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates=int(MathMax(Fast_RVI,Slow_TRVI+8));
   min_rates_total=min_rates+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase);
//---- получение хендла индикатора RVI
   RVI_Handle=iRVI(NULL,0,Fast_RVI);
   if(RVI_Handle==INVALID_HANDLE) Print("Не удалось получить хендл индикатора RVI");
//---- получение хендла индикатора TRVI
   TRVI_Handle=iCustom(NULL,0,"TRVI",Slow_TRVI,VolumeType,0);
   if(TRVI_Handle==INVALID_HANDLE) Print("Не удалось получить хендл индикатора TRVI");

//---- превращение динамического массива RMACDBuffer в индикаторный буфер
   SetIndexBuffer(0,RMACDBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(RMACDBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorRMACDBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorRMACDBuffer,true);

//---- превращение динамического массива SignBuffer в индикаторный буфер
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SignBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorSignBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorSignBuffer,true);

//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Fast_RVI", Fast_RVI);
   XMA1.XMALengthCheck("Slow_TRVI", Slow_TRVI);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Signal_Phase",Signal_Phase,Signal_Method);

//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"RMACD( ",Fast_RVI,", ",Slow_TRVI,", ",Smooth,", ",Signal_XMA," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| RMACD iteration function                                         | 
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
   if(BarsCalculated(RVI_Handle)<rates_total
      || BarsCalculated(TRVI_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//---- объявление локальных переменных 
   int to_copy,limit,bar,maxbar;
   double RVI[],TRVI[];
//----
   static uint UpCount,DnCount;
//---- объявление переменных с плавающей точкой  
   double rmacd,sign_xma;
//----
   maxbar=rates_total-1-min_rates;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=maxbar; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RVI_Handle,MAIN_LINE,0,to_copy,RVI)<=0) return(RESET);
   if(CopyBuffer(TRVI_Handle,SIGNAL_LINE,0,to_copy,TRVI)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(RVI,true);
   ArraySetAsSeries(TRVI,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      rmacd=RVI[bar]-TRVI[bar];
      sign_xma=XMA1.XMASeries(maxbar,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,rmacd,bar,true);
      //---- загрузка полученных значений в индикаторные буферы      
      RMACDBuffer[bar]= rmacd;
      SignBuffer[bar] = sign_xma;
     }
//----
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- основной цикл раскраски индикатора RMACD
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorRMACDBuffer[bar]=0;
      //----
      if(RMACDBuffer[bar]>0)
        {
         if(RMACDBuffer[bar]>RMACDBuffer[bar+1]) ColorRMACDBuffer[bar]=1;
         if(RMACDBuffer[bar]<RMACDBuffer[bar+1]) ColorRMACDBuffer[bar]=2;
        }
      //----
      if(RMACDBuffer[bar]<0)
        {
         if(RMACDBuffer[bar]<RMACDBuffer[bar+1]) ColorRMACDBuffer[bar]=3;
         if(RMACDBuffer[bar]>RMACDBuffer[bar+1]) ColorRMACDBuffer[bar]=4;
        }
     }
//----
   if(prev_calculated>rates_total || prev_calculated<=0) limit=rates_total-1-min_rates_total-1;
//---- основной цикл раскраски сигнальной линии
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorSignBuffer[bar]=0;
      if(RMACDBuffer[bar]>SignBuffer[bar+1]) ColorSignBuffer[bar]=1;
      if(RMACDBuffer[bar]<SignBuffer[bar+1]) ColorSignBuffer[bar]=2;
     }
//---- сброс счетчиков алертов в нули
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
     }
//----
   int bar1=1;
   int bar2=2;
//---- подача алерта для покупки
   if(UpCount<AlertCount && ColorSignBuffer[bar1]==2 && ColorSignBuffer[bar2]==1)
     {
      UpCount++;
      Alert("RMACD индикатор "+Symbol()+EnumToString(PERIOD_CURRENT)+": ""Сигнал на покупку "+Symbol());
     }
//---- подача алерта для продажи
   if(DnCount<AlertCount && ColorSignBuffer[bar1]==1 && ColorSignBuffer[bar2]==2)
     {
      DnCount++;
      Alert("RMACD индикатор "+Symbol()+EnumToString(PERIOD_CURRENT)+": ""Сигнал на продажу "+Symbol());
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
