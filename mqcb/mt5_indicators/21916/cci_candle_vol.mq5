//+------------------------------------------------------------------+ 
//|                                               CCI_Candle_Vol.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 9
#property indicator_buffers 9 
//---- использовано четыре графических построения
#property indicator_plots   4
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
#property indicator_label1  "CCI_Candle_Vol Channel"
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
#property indicator_label2  "CCI_Candle_Vol Res"
//+-----------------------------------------+
//| Параметры отрисовки индикатора CCI      |
//+-----------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3  clrAqua,clrBlue,clrTeal,clrOrangeRed,clrBrown,clrGold
//---- отображение метки индикатора
#property indicator_label3  "CCI_Candle_Vol Open;CCI_Candle_Vol High;CCI_Candle_Vol Low;CCI_Candle_Vol Close"
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
#property indicator_label4  "CCI_Candle_Vol Supr"
//+-----------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА           |
//+-----------------------------------------+
input uint                CCIPeriod=14;             // период индикатора
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;   // объём 
input int                 HighLevel=+100;           // уровень перекупленности
input int                 LowLevel=-100;            // уровень перепроданности
input uint                Gap=10;                   // размер неучитываемого гэпа в пунктах
input int                 Shift=0;                  // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------------+

//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double OpenBuffer[],HighBuffer[],LowBuffer[],CloseBuffer[],ColorBuffer[];
double UpIndBuffer[],DnIndBuffer[];
double UpCldIndBuffer[],DnCldIndBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int CCI_Handle[4];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(CCIPeriod);
//---- получение хендла индикатора iCCI 1
   CCI_Handle[0]=iCCI(NULL,0,CCIPeriod,PRICE_OPEN);
   if(CCI_Handle[0]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iCCI 1");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iCCI 2
   CCI_Handle[1]=iCCI(NULL,0,CCIPeriod,PRICE_HIGH);
   if(CCI_Handle[1]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iCCI 2");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iCCI 3
   CCI_Handle[2]=iCCI(NULL,0,CCIPeriod,PRICE_LOW);
   if(CCI_Handle[2]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iCCI 3");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iCCI 4
   CCI_Handle[3]=iCCI(NULL,0,CCIPeriod,PRICE_CLOSE);
   if(CCI_Handle[3]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iCCI 4");
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

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI_Candle_Vol("+string(CCIPeriod)+")");
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
   if(BarsCalculated(CCI_Handle[0])<rates_total
      || BarsCalculated(CCI_Handle[1])<rates_total
      || BarsCalculated(CCI_Handle[2])<rates_total
      || BarsCalculated(CCI_Handle[3])<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных
   int to_copy,limit,bar;
   double vol;

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
   if(CopyBuffer(CCI_Handle[0],0,0,to_copy,OpenBuffer)<=0) return(RESET);
   if(CopyBuffer(CCI_Handle[1],0,0,to_copy,HighBuffer)<=0) return(RESET);
   if(CopyBuffer(CCI_Handle[2],0,0,to_copy,LowBuffer)<=0) return(RESET);
   if(CopyBuffer(CCI_Handle[3],0,0,to_copy,CloseBuffer)<=0) return(RESET);

//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- исправляем значения CCI
      double Max=MathMax(OpenBuffer[bar],CloseBuffer[bar]);
      Max=MathMax(Max,LowBuffer[bar]);
      Max=MathMax(Max,HighBuffer[bar]);
      double Min=MathMin(OpenBuffer[bar],CloseBuffer[bar]);
      Min=MathMin(Min,LowBuffer[bar]);
      Min=MathMin(Min,HighBuffer[bar]);
      HighBuffer[bar]=Max;
      LowBuffer[bar]=Min;

      if(VolumeType==VOLUME_TICK) vol=double(Tick_Volume[bar]);
      else vol=double(Volume[bar]);

      //---- домножаем значение CCI на объём
      OpenBuffer[bar]*=vol;
      HighBuffer[bar]*=vol;
      LowBuffer[bar]*=vol;
      CloseBuffer[bar]*=vol;
      //---- исправляем значения CCI
      if(MathAbs(Open[bar]-Close[bar])<=Gap) OpenBuffer[bar]=CloseBuffer[bar+1];

      UpIndBuffer[bar]=UpCldIndBuffer[bar]=HighLevel*vol;
      DnIndBuffer[bar]=DnCldIndBuffer[bar]=LowLevel*vol;

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
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
