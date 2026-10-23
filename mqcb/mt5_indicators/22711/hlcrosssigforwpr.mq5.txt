//+------------------------------------------------------------------+
//|                                      HL Cross Signal for WPR.mq5 |
//|                                  Copyright © 2008, Bigeev Rustem |
//|                                             http://www.parch.ru/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2008, Bigeev Rustem"
//---- ссылка на сайт автора
#property link      "http://www.parch.ru/"
//---- номер версии индикатора
#property version   "2.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 8
//---- использовано четыре графических построения
#property indicator_plots   8
//+----------------------------------------------+ 
//|  объявление констант                         |
//+----------------------------------------------+ 
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color1  clrRed
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение медвежьей метки индикатора
#property indicator_label1  "Sell Stop"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован зелёный цвет
#property indicator_color2  clrLime
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение бычей метки индикатора
#property indicator_label2 "Buy Stop"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3 DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color3 clrMagenta
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Sell TakeProfit"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4 DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован салатовый цвет
#property indicator_color4 clrAqua
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение бычей метки индикатора
#property indicator_label4 "Buy TakeProfit"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5 DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован розовый  цвет
#property indicator_color5 clrMagenta 
//---- толщина линии индикатора 5 равна 1
#property indicator_width5  1
//---- отображение медвежьей метки индикатора
#property indicator_label5  "Sell Signal"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде символа
#property indicator_type6 DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован салатовый цвет
#property indicator_color6 clrAqua
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение бычей метки индикатора
#property indicator_label6 "Buy Signal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 7 в виде символа
#property indicator_type7 DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color7 clrRed 
//---- толщина линии индикатора 7 равна 3
#property indicator_width7  3
//---- отображение медвежьей метки индикатора
#property indicator_label7  "Sell Input"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 8 в виде символа
#property indicator_type8 DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован зелёный цвет
#property indicator_color8 clrLime
//---- толщина линии индикатора 8 равна 3
#property indicator_width8  3
//---- отображение бычей метки индикатора
#property indicator_label8 "Buy Input"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Supr_Period=6;    //Период пробиваемого диапазона, чем больше значение, тем более поздние сигналы и реже
input int MA_Period=21;     //Период для Heiken Ashi variable. Служит в качестве доп. фильтра
input int Risk=0;           //Максимальный риск в пипсах для расчета уровня входа исходя из уровня ближайшего MAX/MIN
input int ATR_Period=120;   //Период АТR. Служит для расчета уровня волатильности.
input double Q=0.7;         //Параметр для постановки Тейка. - Доля от размера Стопа. если =1, Тейк = Стопу
input int WPR_Period=12;    //Период WPR. Служит в качестве доп. фильтра
input int HLine=-38;        //Верхняя сигнальная линия стопов для WPR
input int LLine=-62;        //Нижняя сигнальная линия стопов для WPR
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double Sell[];
double Buy[];
double SellStop[];
double BuyStop[];
double SellTake[];
double BuyTake[];
double SellInput[];
double BuyInput[];
//----
double PointRisk,PointRisk10;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление переменных для хранения хендлов индикаторов
int WPR_Handle,ATR_Handle,MA_Handle,MA1_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(MA_Period,MathMax(WPR_Period,MathMax(ATR_Period,Supr_Period+1))));

//---- Инициализация переменных  
   PointRisk=Risk*_Point;
   PointRisk10=10*PointRisk;

//---- получение хендла индикатора MA
   MA_Handle=iMA(NULL,0,MA_Period,0,MODE_SMA,PRICE_MEDIAN);
   if(MA_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора MA");

//---- получение хендла индикатора MA1
   MA1_Handle=iMA(NULL,0,1,0,MODE_SMA,PRICE_MEDIAN);
   if(MA1_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора MA1");

//---- получение хендла индикатора WPR
   WPR_Handle=iWPR(NULL,0,WPR_Period);
   if(WPR_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора WPR");

//---- Получение хендла индикатора
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора ATR");

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellStop,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,119);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellStop,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyStop,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyStop,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,SellTake,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,158);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellTake,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,BuyTake,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,158);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyTake,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,Sell,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,234);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Sell,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,Buy,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(5,PLOT_ARROW,233);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buy,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,SellInput,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 7
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(6,PLOT_ARROW,177);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellInput,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,BuyInput,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 8
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(7,PLOT_ARROW,177);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyInput,true);

//---- инициализации переменной для короткого имени индикатора
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"HL Cross Signal for WPR");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
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
                const double& low[],      // ценовой массив минимумов  цены для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(MA1_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(WPR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- объявления локальных переменных 
   int limit,bar,Flag;
   double WPR[1],ATR[1],MA[1],MA1[1];
   double Lhigh,Llow,Spread;
   static int Flag_;

//---- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(spread,true);

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1;  // стартовый номер для расчёта всех баров
      Flag_=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- восстанавливаем значения переменных
   Flag=Flag_;

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
         Flag_=Flag;

      Sell[bar]=SellTake[bar]=SellStop[bar]=SellInput[bar]=NULL;
      Buy[bar]=BuyTake[bar]=BuyStop[bar]=BuyInput[bar]=NULL;
      
      Spread=spread[bar]*_Point;

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(MA_Handle,0,bar,1,MA)<=0) return(RESET);
      if(CopyBuffer(MA1_Handle,0,bar,1,MA1)<=0) return(RESET);
      if(CopyBuffer(WPR_Handle,0,bar,1,WPR)<=0) return(RESET);
      if(CopyBuffer(ATR_Handle,0,bar,1,ATR)<=0) return(RESET);
      Lhigh=high[ArrayMaximum(high,bar+1,Supr_Period)];
      Llow=low[ArrayMinimum(low,bar+1,Supr_Period)];

      // Условие сигнала на покупку
      if(Flag<=0)
         if((high[bar]>=Lhigh && close[bar]>MA1[0] && close[bar]>MA[0] && high[bar]>MA[0] && WPR[0]>=HLine)
           ||(close[bar]>=SellStop[bar+1] && high[bar]>Lhigh))
           {
            Buy[bar]=MathMin(close[bar],(Llow+2*ATR[0]));
            if(Risk!=0 && Buy[bar]-Llow>PointRisk) Buy[bar]=Llow+PointRisk10;
            if(close[bar]<Llow+PointRisk10) Buy[bar]=close[bar];
            Flag=+1;
           }

      

      // Условие сигнала на продажу
      if(Flag>=0)
         if((low[bar]<=Llow && close[bar]<MA1[0] && close[bar]<MA[0] && low[bar]<MA[0] && WPR[0]<=LLine)
           ||(close[bar]<=BuyStop[bar+1] && low[bar]<Llow))
           {
            Sell[bar]=MathMax(close[bar],(Lhigh-2*ATR[0]));
            if(Risk!=0 && Lhigh-Sell[bar]>PointRisk) Sell[bar]=Lhigh-PointRisk10;
            if(close[bar]>Lhigh-PointRisk10) Sell[bar]=close[bar];
            Flag=-1;
           }
           
      if(Flag>0)
        {
         BuyStop[bar]=Llow-Spread*2;
         BuyTake[bar]=Lhigh+Spread*3;
         
         if(BuyStop[bar]<BuyStop[bar+1]&&!SellStop[bar+1]) BuyStop[bar]=BuyStop[bar+1];
         if(BuyTake[bar]<BuyTake[bar+1]&&!SellTake[bar+1]) BuyTake[bar]=BuyTake[bar+1];
        }

      if(Flag<0)
        {
         SellStop[bar]=Lhigh+Spread*3;
         SellTake[bar]=Llow-Spread*2;
         
         if(SellStop[bar]>SellStop[bar+1]&&!BuyStop[bar+1]) SellStop[bar]=SellStop[bar+1];
         if(SellTake[bar]>SellTake[bar+1]&&!BuyTake[bar+1]) SellTake[bar]=SellTake[bar+1];
        }
        
      if(Buy[bar]) BuyInput[bar]=Buy[bar]+(Buy[bar]-BuyStop[bar])*Q; 
      if(Sell[bar]) SellInput[bar]=Sell[bar]-(SellStop[bar]-Sell[bar])*Q+Spread;

     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
