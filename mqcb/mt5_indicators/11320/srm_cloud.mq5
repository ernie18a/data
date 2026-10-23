//+------------------------------------------------------------------+ 
//|                                                    SRm_Cloud.mq5 | 
//|                                          Copyright © 2013, HgCl2 | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, HgCl2"
#property link ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета индикатора использован PaleTurquoise
#property indicator_color1  clrPaleTurquoise
//---- отображение метки индикатора
#property indicator_label1  "SRm_Cloud"
//+-----------------------------------+
//|  Объявление перечисления          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
  };
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint period=14;
input double k_std = 1.0;   // Коэффициент стандартного отклонения Std
input double k  = 1.0;      // Коэффициент среднего минимального колебания AV
input Applied_price_ Price=PRICE_OPEN_;
//+-----------------------------------+
double m[10000];
double o[10000];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtABuffer[];
double ExtBBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(period+1);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtABuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtBBuffer,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"SRm_Cloud("+DoubleToString(k_std,4)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   static double LastHigh,LastLow;
   double w,gsv1=0.0,gsv2=0.0;
//---- Объявление целых переменных
   int limit,x=0;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      for(int bar=rates_total-1; bar>=0 && !IsStopped(); bar--)
        {
         ExtABuffer[bar]=0.0;
         ExtBBuffer[bar]=0.0;
        }
      LastHigh=0;
      LastLow=999999999;
     }
   else limit=rates_total-prev_calculated;  // стартовый номер для расчёта только новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   if(Price==PRICE_OPEN_) ArraySetAsSeries(Open,true);
   else ArraySetAsSeries(Close,true);

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      LastHigh=MathMax(LastHigh,High[bar+1]);
      LastLow=MathMin(LastLow,Low[bar+1]);
      //----
      MqlDateTime tm0,tm1;
      TimeToStruct(Time[bar],tm0);
      TimeToStruct(Time[bar+1],tm1);
      //----
      if(tm0.day!=tm1.day && (( tm1.day_of_week>0 && tm1.day_of_week<6) || Period()>PERIOD_D1))
        {
         x++;
         if(Price==PRICE_OPEN_) o[x]=Open[bar];
         else o[x]=Close[bar];
         m[x]=LastHigh-o[x-1];
         if(LastHigh-o[x-1]>o[x-1]-LastLow) m[x]=o[x-1]-LastLow;
         LastLow=100000;
         LastHigh=0;
         //----
         if(x>int(period))
           {
            w=0;
            for(int y=0; y<int(period); y++) w+=m[x-y];
            double v=w/period;
            //----
            w=0;
            for(int y=0; y<int(period); y++) w+=MathPow(m[x-y]-v,2);
            double e=w/period;
            //----
            double std=k*v+k_std*MathPow(e,0.5);
            gsv1=o[x]+std;
            gsv2=o[x]-std;
           }
        }

      if(x>int(period))
        {
         ExtABuffer[bar]=gsv1;
         ExtBBuffer[bar]=gsv2;
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
