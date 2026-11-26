//+------------------------------------------------------------------+
//|                                                     UltraMFI.mq5 |
//|                                   Copyright © 2008, dm34@mail.ru | 
//|                                    http://www.fxexpert.ru/forum/ | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2008, dm34@mail.ru"
//---- ссылка на сайт автора
#property link "http://www.fxexpert.ru/forum/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+ 
//|  объявление констант              |
//+-----------------------------------+ 
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  Параметры отрисовки заливки      |
//+-----------------------------------+
//---- отрисовка индикатора в виде заливки между двумя линиями
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов заливки индикатора использованы зелёный цвет и оранжевый цвета
#property indicator_color1  clrLime, clrDarkOrange
//---- отображение метки индикатора
#property indicator_label1 "Ultra MFI"
//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA[];
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
//|  объявление перечисления          |
//+-----------------------------------+  
enum WIDTH
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+-----------------------------------+
//|  объявление перечисления          |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,//Сплошная линия
   DASH_,//Штриховая линия
   DOT_,//Пунктирная линия
   DASHDOT_,//Штрих-пунктирная линия
   DASHDOTDOT_   //Штрих-пунктирная линия с двойными точками
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int MFI_Period=13; //период индикатора MFI
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём индикатора MFI 
//----
input Smooth_Method W_Method=MODE_JJMA; //метод усреднения
input int StartLength=3; //стартовый период усреднения                    
input int WPhase=100; //параметр усреднения,
                      //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
//----  
input uint Step=5; //шаг изменения периода
input uint StepsTotal=10; //количество изменений периода
//----
input Smooth_Method SmoothMethod=MODE_JJMA; //метод сглаживания
input int SmoothLength=3; //глубина сглаживания                    
input int SmoothPhase=100; //параметр сглаживания,
                           //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//----                          
input uint UpLevel=80; // уровень перезакупа в %%
input uint DnLevel=20; // уровень перепродажи в %%
input color UpLevelsColor=Blue; //цвет уровня перезакупа
input color DnLevelsColor=Blue; //цвет уровня перепродажи
input STYLE Levelstyle=DASH_;   //стиль уровней
input WIDTH  LevelsWidth=Width_1;  //толщина уровней
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double BullsBuffer[];
double BearsBuffer[];
//---- Объявление массива переменных для хранения периодов сигнальных линий индикатора MFI
int period[];
//---- Объявление массивов переменных для хранения усреднённых значений индикатора MFI
double xmfi0[],xmfi1[];
//---- Объявление целых переменных для хендлов индикаторов
int MFI_Handle;
//---- Объявление целых переменных начала отсчёта данных
uint StTot1,StTot2;
int min_rates_total,min_rates_mfi,min_rates_xma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- распределение памяти под массивы переменных
   int size=int(StepsTotal+3);
   if(ArrayResize(XMA,size)<size) Print("Не удалось распределить память под массив XMA[]");
   size-=2;
   if(ArrayResize(xmfi0,size)<size) Print("Не удалось распределить память под массив xmfi0[]");
   if(ArrayResize(xmfi1,size)<size) Print("Не удалось распределить память под массив xmfi1[]");
   if(ArrayResize(period,size)<size) Print("Не удалось распределить память под массив period[]");

//---- Инициализация переменных
   for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--) period[sm]=int(StartLength+sm*Step);

//---- установка алертов на недопустимые значения внешних переменных
   XMA[0].XMALengthCheck("StartLength", StartLength);
   XMA[0].XMAPhaseCheck("WPhase", WPhase, W_Method);
   XMA[0].XMALengthCheck("SmoothLength", SmoothLength);
   XMA[0].XMAPhaseCheck("SmoothPhase", SmoothPhase, SmoothMethod);

//---- Инициализация переменных начала отсчёта данных
   min_rates_mfi=MFI_Period;
   min_rates_xma=min_rates_mfi+XMA[0].GetStartBars(W_Method,StartLength+Step*StepsTotal,WPhase)+1;
   min_rates_total=min_rates_xma+XMA[0].GetStartBars(SmoothMethod,SmoothLength,SmoothPhase);
   StTot1=StepsTotal+1;
   StTot2=StepsTotal+2;

//---- получение хендла индикатора MFI
   MFI_Handle=iMFI(NULL,0,MFI_Period,VolumeType);
   if(MFI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора MFI");
      return(INIT_FAILED);
     }

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(0,BullsBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BullsBuffer,true);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BearsBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname="Ultra MFI";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);

//---- параметры отрисовки линий  
   IndicatorSetInteger(INDICATOR_LEVELS,2);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,StepsTotal*UpLevel/100);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,StepsTotal*DnLevel/100);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
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
   if(BarsCalculated(MFI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar,maxbar1,maxbar2;
   double MFI[],upsch,dnsch;

//---- расчёт стартового номера maxbar для функции XMASeries()
   maxbar1=rates_total-1-min_rates_mfi;
   maxbar2=rates_total-1-min_rates_xma;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=maxbar1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
//----   
   to_copy=limit+2;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(MFI_Handle,0,0,to_copy,MFI)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(MFI,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--)
         xmfi0[sm]=XMA[sm].XMASeries(maxbar1,prev_calculated,rates_total,W_Method,WPhase,period[sm],MFI[bar],bar,true);

      if(bar>maxbar2)
        {
         if(bar) ArrayCopy(xmfi1,xmfi0,0,0,WHOLE_ARRAY);
         continue;
        }

      upsch=0;
      dnsch=0;
      for(int sm=int(StepsTotal); sm>=0 && !IsStopped(); sm--) if(xmfi0[sm]>xmfi1[sm]) upsch++; else dnsch++;

      BullsBuffer[bar]=XMA[StTot1].XMASeries(maxbar2,prev_calculated,rates_total,SmoothMethod,SmoothPhase,SmoothLength,upsch,bar,true);
      BearsBuffer[bar]=XMA[StTot2].XMASeries(maxbar2,prev_calculated,rates_total,SmoothMethod,SmoothPhase,SmoothLength,dnsch,bar,true);

      if(bar) ArrayCopy(xmfi1,xmfi0,0,0,WHOLE_ARRAY);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
