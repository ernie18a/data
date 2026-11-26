//+------------------------------------------------------------------+
//|                                           FineTuningMACandle.mq5 | 
//|                                         Copyright © 2018, gumgum |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, gumgum"
#property link      ""
//---- номер версии индикатора
#property version   "1.00"
//---- описание индикатора
#property description "Свечной график на более тонком усреднении таймсерий"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrDeepPink,clrGray,clrCornflowerBlue
//---- отображение метки индикатора
#property indicator_label1  "FineTuningMA Open;FineTuningMA High;FineTuningMA Low;FineTuningMA Close"
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint   FTMA=10;
input double rank1=2;
input double rank2=2;
input double rank3=2;
input double shift1=1;
input double shift2=1;
input double shift3=1;
input int Shift=0;      // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
input uint Gap=10;      // размер неучитываемого гэпа в пунктах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//----
double PM[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| FineTuningMA indicator initialization function                   | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- распределение памяти под массивы переменных  
   ArrayResize(PM,FTMA);

//---- Инициализация переменных
   double sum=0;
   for(int h=0; h<int(FTMA); h++)
     {
      PM[h]=shift1+MathPow(h/(FTMA-1.0),rank1)*(1.0-shift1);
      PM[h]=(shift2+MathPow(1-(h/(FTMA-1.0)),rank2)*(1.0-shift2))*PM[h];

      if((h/(FTMA-1.))<0.5) PM[h]=(shift3+MathPow((1-(h/(FTMA-1.0))*2.0),rank3)*(1.0-shift3))*PM[h];
      else PM[h]=(shift3+MathPow((h/(FTMA-1.0))*2.0-1.0,rank3)*(1.0-shift3))*PM[h];

      sum+=PM[h];
     }

   double sum1=0;
   for(int h=0; h<int(FTMA); h++)
     {
      PM[h]=PM[h]/sum;
      sum1+=PM[h];
     }

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(FTMA)+1;
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"FineTuningMACandle("+string(FTMA)+")");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| FineTuningMA iteration function                                  | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;
   double O,H,L,C;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_total; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {      
      O=NULL;
      for(int index=0; index<int(FTMA); index++) O+=PM[index]*open[bar-index];
      H=NULL;
      for(int index=0; index<int(FTMA); index++) H+=PM[index]*high[bar-index];
      L=NULL;
      for(int index=0; index<int(FTMA); index++) L+=PM[index]*low[bar-index];
      C=NULL;
      for(int index=0; index<int(FTMA); index++) C+=PM[index]*close[bar-index];
      
      //---- исправляем значения полученных свечек
      double Max=MathMax(O,C);
      Max=MathMax(Max,L);
      Max=MathMax(Max,H);
      double Min=MathMin(O,C);
      Min=MathMin(Min,L);
      Min=MathMin(Min,H);
      ExtOpenBuffer[bar]=O;
      ExtHighBuffer[bar]=Max;
      ExtLowBuffer[bar]=Min;
      ExtCloseBuffer[bar]=C;
      //---- удаляем несуществующие гепы
      if(MathAbs(open[bar]-close[bar])<=Gap) ExtOpenBuffer[bar]=ExtCloseBuffer[MathMax(bar-1,0)];
      //---- красим свечи
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;      
      //---- сдвигаем свечи по вертикали
      ExtOpenBuffer[bar]+=dPriceShift;
      ExtHighBuffer[bar]+=dPriceShift;
      ExtLowBuffer[bar]+=dPriceShift;
      ExtCloseBuffer[bar]+=dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| PriceSeries() function                                           |
//+------------------------------------------------------------------+
double PriceSeries
(
 uint applied_price,// Ценовая константа
 uint   bar,// Индекс сдвига относительно текущего бара на указанное количество периодов назад или вперёд).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
