//+------------------------------------------------------------------+
//|                                                  RSICandleV2.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "RSICandle Smoothed"
//---- номер версии индикатора
#property version   "1.00"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRed,clrViolet,clrDeepSkyBlue,clrBlue
//---- отображение метки индикатора
#property indicator_label1  "RSICandle Open;RSICandle High;RSICandle Low;RSICandle Close"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint RSI_Period=14;
input uint HighLevel=60;                          // уровень перекупленности
input uint LowLevel=40;                           // уровень перепроданности
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int RSI_Handle[4];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_total=int(RSI_Period);

//---- получение хендла индикатора iRSI
   RSI_Handle[0]=iRSI(NULL,0,RSI_Period,PRICE_OPEN);
   if(RSI_Handle[0]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iRSI["+string(0)+"]!");

   RSI_Handle[1]=iRSI(NULL,0,RSI_Period,PRICE_HIGH);
   if(RSI_Handle[1]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iRSI["+string(1)+"]!");

   RSI_Handle[2]=iRSI(NULL,0,RSI_Period,PRICE_LOW);
   if(RSI_Handle[2]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iRSI["+string(2)+"]!");

   RSI_Handle[3]=iRSI(NULL,0,RSI_Period,PRICE_CLOSE);
   if(RSI_Handle[3]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iRSI["+string(3)+"]!");

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);

//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- имя для окон данных и метка для субъокон 
   string short_name="RSICandleV2";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- параметры отрисовки уровней индикатора
   IndicatorSetInteger(INDICATOR_LEVELS,2);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,MathMin(100,HighLevel));
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MathMax(0,LowLevel));
//---- в качестве цветов линий горизонтальных уровней использованы 
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(RSI_Handle[0])<rates_total
      || BarsCalculated(RSI_Handle[1])<rates_total
      || BarsCalculated(RSI_Handle[2])<rates_total
      || BarsCalculated(RSI_Handle[3])<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar,clr=0;

//---- расчёты необходимого количества копируемых данных и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle[0],0,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[1],0,0,to_copy,ExtHighBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[2],0,0,to_copy,ExtLowBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[3],0,0,to_copy,ExtCloseBuffer)<=0) return(RESET);


//---- Основной цикл исправления и окрашивания свечей
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);

      Max=ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      Min=ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);

      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar])
        {
         if((Max>HighLevel) || (Max>LowLevel && Min<=LowLevel)) clr=3;
         else clr=2;
        }
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar])
        {
         if((Min<LowLevel) || ((Max>HighLevel && Min<=HighLevel))) clr=0;
         else clr=1;
        }
      ExtColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
