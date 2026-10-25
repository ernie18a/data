//+---------------------------------------------------------------------+ 
//|                                             XRSI_Candle_Vol_Zer.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 11
#property indicator_buffers 11 
//---- использовано пять графических построений
#property indicator_plots   5
//+-----------------------------------------+
//|  объявление констант                    |
//+-----------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------------+
//| Параметры отрисовки облака              |
//+-----------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет Lavender
#property indicator_color1 clrLavender
//---- отображение метки индикатора
#property indicator_label1  "XRSI_Candle_Vol Channel"
//+-----------------------------------------+
//|  Параметры отрисовки уровня Res         |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован зелёный цвет
#property indicator_color2 clrTeal
//---- линия индикатора - штрих-пунктир
#property indicator_style2  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 2
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "XRSI_Candle_Vol Res"
//+-----------------------------------------+
//| Параметры отрисовки индикатора RSI      |
//+-----------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3  clrAqua,clrBlue,clrTeal,clrOrangeRed,clrBrown,clrMagenta
//---- отображение метки индикатора
#property indicator_label3  "XRSI_Candle_Vol Open;XRSI_Candle_Vol High;XRSI_Candle_Vol Low;XRSI_Candle_Vol Close"
//+-----------------------------------------+
//|  Параметры отрисовки уровня Supr        |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован багряный цвет
#property indicator_color4 clrCrimson
//---- линия индикатора - штрих-пунктир
#property indicator_style4  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "XRSI_Candle_Vol Supr"
//+-----------------------------------------+
//|  Параметры отрисовки значков            |
//+-----------------------------------------+
//---- отрисовка индикатора 5 в виде цветного символа
#property indicator_type5   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы
#property indicator_color5  clrDodgerBlue,clrMagenta
//---- толщина линии индикатора 5 равна 3
#property indicator_width5  3
//---- отображение метки индикатора
#property indicator_label5  "XRSI_Candle_Vol ZeroSignal"
//+-----------------------------------------+
//|  Описание класса CXMA                   |
//+-----------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAO,XMAH,XMAL,XMAC,XMAV;
//+-----------------------------------------+
//|  объявление перечислений                |
//+-----------------------------------------+
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
   MODE_AMA    // AMA
  }; */
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА           |
//+-----------------------------------------+
input uint                RSIPeriod=14;             // период индикатора
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;   // объём 
input int                 HighLevel=+7;             // уровень перекупленности
input int                 LowLevel=-7;              // уровень перепроданности
input uint                Gap=10;                   // размер неучитываемого гэпа в пунктах
input Smooth_Method       MA_SMethod=MODE_T3;       // Метод усреднения
input uint                MA_Length=12;             // Глубина сглаживания                    
input int                 MA_Phase=15;              // параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int                 Shift=0;                  // Сдвиг индикатора по горизонтали в барах
input uint                SignTotal=3;              // Количество звуковых сигналов при побое свечкой нуля
input uint                SignalBar=1;              // номер бара для получения сигнала пробоя свечкой нуля
//+-----------------------------------------+

//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total,min_rates_1,AtrPeriod;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double OpenBuffer[],HighBuffer[],LowBuffer[],CloseBuffer[],ColorBuffer[];
double UpIndBuffer[],DnIndBuffer[];
double UpCldIndBuffer[],DnCldIndBuffer[];
double ZrSigBuffer[],ColorZrSigBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int RSI_Handle[4];
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
double GetRange(int index,const double &High[],const double &Low[],uint Len)
  {
//----
   double AvgRange=0.0;
   for(int count=int(index+Len-1); count>=index; count--) AvgRange+=MathAbs(High[count]-Low[count]);
//---- 
   return(AvgRange/Len);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(RSIPeriod);
   min_rates_total=min_rates_1+GetStartBars(MA_SMethod,MA_Length,MA_Phase);
   AtrPeriod=15;
//---- получение хендла индикатора iRSI 1
   RSI_Handle[0]=iRSI(NULL,0,RSIPeriod,PRICE_OPEN);
   if(RSI_Handle[0]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI 1");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI 2
   RSI_Handle[1]=iRSI(NULL,0,RSIPeriod,PRICE_HIGH);
   if(RSI_Handle[1]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI 2");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI 3
   RSI_Handle[2]=iRSI(NULL,0,RSIPeriod,PRICE_LOW);
   if(RSI_Handle[2]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI 3");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI 4
   RSI_Handle[3]=iRSI(NULL,0,RSIPeriod,PRICE_CLOSE);
   if(RSI_Handle[3]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI 4");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpCldIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpCldIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnCldIndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnCldIndBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer,true);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(3,OpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,LowBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,CloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(7,ColorBuffer,INDICATOR_COLOR_INDEX);

//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(OpenBuffer,true);
   ArraySetAsSeries(HighBuffer,true);
   ArraySetAsSeries(LowBuffer,true);
   ArraySetAsSeries(CloseBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(8,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer,true);
   
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(9,ZrSigBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total+AtrPeriod);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикаторапо горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(4,PLOT_ARROW,124);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ZrSigBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(10,ColorZrSigBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorZrSigBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"XRSI_Candle_Vol_Zer("+string(RSIPeriod)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(BarsCalculated(RSI_Handle[0])<rates_total
      || BarsCalculated(RSI_Handle[1])<rates_total
      || BarsCalculated(RSI_Handle[2])<rates_total
      || BarsCalculated(RSI_Handle[3])<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных
   int to_copy,limit,bar,maxbar;
   double vol,xvol;
   
   maxbar=rates_total-min_rates_1-1;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

   to_copy=limit+1;

//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(Open,true); 
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(Tick_Volume,true);
   else ArraySetAsSeries(Volume,true);

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle[0],0,0,to_copy,OpenBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[1],0,0,to_copy,HighBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[2],0,0,to_copy,LowBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[3],0,0,to_copy,CloseBuffer)<=0) return(RESET);

//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- исправляем значения RSI
      double Max=MathMax(OpenBuffer[bar],CloseBuffer[bar]);
      Max=MathMax(Max,LowBuffer[bar]);
      Max=MathMax(Max,HighBuffer[bar]);
      double Min=MathMin(OpenBuffer[bar],CloseBuffer[bar]);
      Min=MathMin(Min,LowBuffer[bar]);
      Min=MathMin(Min,HighBuffer[bar]);
      HighBuffer[bar]=Max;
      LowBuffer[bar]=Min;
      
      //---- сдвигаем значение RSI на 50 вниз (делаем индикатор симметричным относительно оси времени)
      OpenBuffer[bar]-=50;
      HighBuffer[bar]-=50;
      LowBuffer[bar]-=50;
      CloseBuffer[bar]-=50;
      
      if(VolumeType==VOLUME_TICK) vol=double(Tick_Volume[bar]);
      else vol=double(Volume[bar]);

      //---- домножаем значение RSI на объём
      OpenBuffer[bar]*=vol;
      HighBuffer[bar]*=vol;
      LowBuffer[bar]*=vol;
      CloseBuffer[bar]*=vol;
      
      OpenBuffer[bar]=XMAO.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,OpenBuffer[bar],bar,true); //усредняем таймсерии 
      HighBuffer[bar]=XMAH.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,HighBuffer[bar],bar,true); //усредняем таймсерии 
      LowBuffer[bar]=XMAL.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,LowBuffer[bar],bar,true); //усредняем таймсерии 
      CloseBuffer[bar]=XMAC.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,CloseBuffer[bar],bar,true); //усредняем таймсерии 
      xvol=XMAV.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,vol,bar,true);  //усредняем объём  
      //---- исправляем значения RSI
      if(MathAbs(Open[bar]-Close[bar])<=Gap) OpenBuffer[bar]=CloseBuffer[bar+1];

      UpIndBuffer[bar]=UpCldIndBuffer[bar]=HighLevel*xvol;
      DnIndBuffer[bar]=DnCldIndBuffer[bar]=LowLevel*xvol;

      int clr=2.0;
      if(CloseBuffer[bar]>UpIndBuffer[bar])
        {
         if(CloseBuffer[bar]>=OpenBuffer[bar]) clr=0.0;
         else  clr=1.0;
        }
      else if(CloseBuffer[bar]<DnIndBuffer[bar])
        {
         if(CloseBuffer[bar]<=OpenBuffer[bar]) clr=5.0;
         else  clr=4.0;
        }
      else
        {
         if(CloseBuffer[bar]>=OpenBuffer[bar]) clr=2.0;
         else  clr=3.0;
        }
      ColorBuffer[bar]=clr;
      ColorZrSigBuffer[bar]=2;
      ZrSigBuffer[bar]=EMPTY_VALUE;
      
      if(CloseBuffer[bar+1]>0.0 && CloseBuffer[bar]<=0.0)
        {
         ZrSigBuffer[bar]=HighBuffer[bar]+GetRange(bar,HighBuffer,LowBuffer,AtrPeriod)*0.5;
         ColorZrSigBuffer[bar]=1;
        }
      if(CloseBuffer[bar+1]<0.0 && CloseBuffer[bar]>=0.0)
        {
         ZrSigBuffer[bar]=LowBuffer[bar]-GetRange(bar,HighBuffer,LowBuffer,AtrPeriod)*0.5;
         ColorZrSigBuffer[bar]=0;
        }
     }
//---- подача сигналов при побое свечкой нуля 
     static uint count; 
     if(limit) count=0;  
     if(SignTotal)
       {
         if(count<SignTotal && ColorZrSigBuffer[SignalBar]!=2) 
          {
           PlaySound("alert.wav");
           count++;
          }
       }
   
//----        
   return(rates_total);
  }
//+------------------------------------------------------------------+
