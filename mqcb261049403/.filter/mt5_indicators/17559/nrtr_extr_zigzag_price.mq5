//+------------------------------------------------------------------+
//|                                       NRTR_extr_ZigZag_Price.mq5 |
//|                                        Copyright © 2005, Ramdass | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Ramdass" 
#property link      "" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано всего 1 графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использован ZIGZAG
#property indicator_type1   DRAW_ZIGZAG
//---- отображение метки индикатора
#property indicator_label1  "NRTR_ZigZag"
//---- в качестве цвета линии индикатора использован DeepPink цвет
#property indicator_color1 clrDeepPink
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string  SirName="NRTR_extr_ZigZag_Price";//Первая часть имени графических объектов
input uint iPeriod=10;  // Период индикатора
input int iDig=0;       // Разряд
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
input bool ShowPrice=true;
input uint nSize=1;
input color UpColor=clrDodgerBlue;
input color DnColor=clrMagenta;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double TrendUp[],TrendDown[];
double SignUp[],SignDown[];
double HighestBuffer[],LowestBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
string UpLable_,DnLable_;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(iPeriod);
   UpLable_=SirName+"_Up_";
   DnLable_=SirName+"_Dn_";

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"NRTR_extr_ZigZag(",string(iPeriod),", ",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,TrendUp,INDICATOR_CALCULATIONS);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(TrendUp,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,TrendDown,INDICATOR_CALCULATIONS);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(TrendDown,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,SignUp,INDICATOR_CALCULATIONS);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignUp,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,SignDown,INDICATOR_CALCULATIONS);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignDown,true);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,SirName,0,OBJ_ARROW_RIGHT_PRICE);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   double price,value,dK;
   static double price_prev,value_prev,lastlow,lasthigh;
   int limit,bar,trend;
   string stime;
   static int trend_prev,lastlowpos,lasthighpos;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
      trend_prev=0;
      price_prev=value_prev=close[limit];   
      lastlow=999999999.99999;
      lasthigh=NULL;
      lastlowpos=lasthighpos=0;  
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }
   trend=trend_prev;
   price=price_prev;
   value=value_prev;
   lastlowpos+=limit;
   lasthighpos+=limit;

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      TrendUp[bar]=NULL;
      TrendDown[bar]=NULL;
      SignUp[bar]=NULL;
      SignDown[bar]=NULL;
      HighestBuffer[bar]=NULL;
      LowestBuffer[bar]=NULL;

      double AvgRange=NULL;
      for(int iii=0; iii<int(iPeriod); iii++) AvgRange+=MathAbs(high[bar+iii]-low[bar+iii]);
      dK=(AvgRange/iPeriod)/MathPow(10,SymbolInfoInteger("EURUSD",SYMBOL_DIGITS)-_Digits-iDig);

      if(trend>=0)
        {
         price=MathMax(price,high[bar]);
         value=MathMax(value,price*(1.0-dK));
         if(high[bar]<value)
           {
            price = high[bar];
            value = price*(1.0+dK);
            trend = -1;
           }
        }
      else if(trend<=0)
        {
         price=MathMin(price,low[bar]);
         value=MathMin(value,price*(1.0+dK));
         if(low[bar]>value)
           {
            price = low[bar];
            value = price*(1.0-dK);
            trend = +1;
           }
        }

      if(trend>0) TrendUp[bar]=value;
      if(trend<0) TrendDown[bar]=value;

      if(trend_prev<0 && trend>0) SignUp[bar]=TrendUp[bar];
      if(trend_prev>0 && trend<0) SignDown[bar]=TrendDown[bar];
      
      if(trend>0)
        {
         if(TrendUp[bar+1])
           {
            if(high[bar]>lasthigh)
              {
               HighestBuffer[bar]=lasthigh=high[bar];
               stime=TimeToString(time[bar],TIME_DATE|TIME_MINUTES);
               CreateArrowRightPrice(0,UpLable_+stime,0,time[bar],high[bar],UpColor,nSize);
               HighestBuffer[lasthighpos]=NULL;
               stime=TimeToString(time[lasthighpos],TIME_DATE|TIME_MINUTES);
               ObjectDelete(0,UpLable_+stime);
               lasthighpos=bar;
              }
           }
         else
           {
            HighestBuffer[bar]=lasthigh=high[bar];
            stime=TimeToString(time[bar],TIME_DATE|TIME_MINUTES);
            CreateArrowRightPrice(0,UpLable_+stime,0,time[bar],high[bar],UpColor,nSize);
            lasthighpos=bar;
           }
        }

      if(trend<0)
        {
         if(TrendDown[bar+1])
           {
            if(low[bar]<lastlow)
              {
               LowestBuffer[bar]=lastlow=low[bar];
               stime=TimeToString(time[bar],TIME_DATE|TIME_MINUTES);
               CreateArrowRightPrice(0,DnLable_+stime,0,time[bar],low[bar],DnColor,nSize);
               LowestBuffer[lastlowpos]=NULL;
               stime=TimeToString(time[lastlowpos],TIME_DATE|TIME_MINUTES);
               ObjectDelete(0,DnLable_+stime);
               lastlowpos=bar;
              }
           }
         else
           {
            LowestBuffer[bar]=lastlow=low[bar];
            stime=TimeToString(time[bar],TIME_DATE|TIME_MINUTES);
            CreateArrowRightPrice(0,DnLable_+stime,0,time[bar],low[bar],DnColor,nSize);
            lastlowpos=bar;
           }
        }

      if(bar)
        {
         trend_prev=trend;
         price_prev=price;
         value_prev=value;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание текстовой лейбы                                        |
//+------------------------------------------------------------------+
void CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
(
 long   chart_id,         // идентификатор графика
 string name,             // имя объекта
 int    nwin,             // индекс окна
 datetime Time,           // положение ценовой метки по времени
 double Price,            // положение ценовой метки по вертикали
 color  Color,            // цвет текста
 uint    Size             // размер шрифта
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,Size);
//ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
