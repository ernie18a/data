//+------------+--------------------------------------------------------+
//| v.11.09.06 |                                     SnakeInBorders.mq5 |
//+------------+                                      "ФИЛЬТРУЙ БАЗАР!" |
//|  Комплект  |                           Copyright © 2006, Bookkeeper |
//+---------------------------------------------------------------------+
//|  Snake рассчитывает коридор отфильтрованного рынка, ограниченный    |
//|  двумя бордюрами BorderTop[] и BorderBot[], и сигнальную Mart[].    |
//|                                                                     |
//|  Внешние переменные:                                                |
//|  SnakeRange - полупериод расчета оси Snake'а Axis[] - оптимально    |
//|  = 4;                                                               |
//|  FilterPeriod - период фильтрации. ( оптимально больше 13);         |
//|  MartFiltr - коэффициент фильтрации рынка. Чем MartFiltr больше,    |
//|  тем уже коридор отфильтрованного рынка. Коэффициент надо           |
//|  подбирать, по умолчанию = 2;                                       |
//|  У Snake'а два режима: HardCalc = true - не пересчитывать, и        |
//|  = false - пересчитывать значения Axis[Pos]...[Pos+SnakeRange+1].   |
//|  Поведение сигнальной Mart[] внутри коридора:                       |
//|  При движении рынка вверх - сигнальная отходит от нижнего           |
//|  бордюра, пересекает коридор и сливается с верхним бордюром.        |
//|  Аналогично, с точностью до наоборот, - при движении рынка вниз.    |
//|  До тех пор, пока рынок будет двигаться направленно, сигнальная     |
//|  будет "держаться" соответствующей границы коридора. При этом       |
//|  увеличение ширины коридора означает направленное движение. При     |
//|  колебаниях рынка коридор начинает сужаться. Сужением коридора      |
//|  сопровождается движением сигнальной от одной границы к другой      |
//|  внутри коридора, после достижения противоположной границы -        |
//|  коридор начнет расширяться.                                        |
//|  Snake можно использовать как самостоятельно, сравнивая движение    |
//|  сигнальной на разных ТФ одновременно, так и для построения         |
//|  других индикаторов, используя Mart[] вместо цены бара. Для         |
//|  индикаторов типа MA, OA, AC,.. использовать HardCalc = true, а     |
//|  для индикаторов типа ZigZag, Channel,.. - HardCalc = false, а      |
//|  значение MartFiltr подбирать от 3...5. При этом можно отсеивать    | 
//|  истинные и ложные вершины: если вершина промежуточная,             | 
//|  сигнальная Mart[] не будет совпадать с бордюром.                   |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2016, Bookkeeper"
#property link "yuzefovich@gmail.com"
#property description "Коридор отфильтрованного рынка, ограниченный двумя бордюрами"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+--------------------------------------------+
//|  Параметры отрисовки индикатора            |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Mart"
//+--------------------------------------------+
//|  Параметры отрисовки индикатора BB уровней |
//+--------------------------------------------+
//---- отрисовка канала в виде облака
#property indicator_type2   DRAW_FILLING
//---- выбор цвета облака
#property indicator_color2  clrLavender
//---- отображение метки индикатора
#property indicator_label2  "Channels"
//+--------------------------------------------+
//|  Описание классов усреднений               |
//+--------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+--------------------------------------------+
//---- объявление переменных классов CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+--------------------------------------------+
//|  объявление перечислений                   |
//+--------------------------------------------+
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
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price 
  };
//+--------------------------------------------+
//|  объявление перечислений                   |
//+--------------------------------------------+
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
//+--------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА              |
//+--------------------------------------------+
input Smooth_Method XMA_Method=MODE_LWMA_; //метод усреднения
input uint SnakeRange=2; //полупериод расчета оси Snake'а Axis                   
input int XPhase=15; //параметр первого усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint   FilterPeriod = 24;  // период фильтрации
input double MartFiltr    = 2;  // коэффициент фильтрации рынка. Чем MartFiltr больше, тем уже коридор отфильтрованного рынка. Данный коэффициент следует подбирать. По умолчанию 2;
input bool   HardCalc     = true;
input Applied_price_ IPC=PRICE_WEIGHTED_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
input color  Upper_color=clrMediumSeaGreen;
input color  Lower_color=clrRed;
//+--------------------------------------------+
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double MartBuffer[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double BorderTopBuffer[],BorderBotBuffer[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве буферов хранения данных
double AxisBuffer[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,SnakeRange1;
//---- Объявление стрингов для текстовых меток
string upper_name,lower_name;
//+------------------------------------------------------------------+   
//| XMA BBx3 indicator initialization function                       | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   SnakeRange1=int(SnakeRange)+1;
   min_rates_total=GetStartBars(XMA_Method,SnakeRange1,XPhase)+1;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength",SnakeRange1);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- Инициализация стрингов
   upper_name="SnakeInBorders upper text lable";
   lower_name="SnakeInBorders lower text lable";

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,MartBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,BorderTopBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,BorderBotBuffer,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка канала
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- осуществление сдвига индикаторов по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- превращение динамического массива в буфер для расчётов
   SetIndexBuffer(3,AxisBuffer,INDICATOR_CALCULATIONS);

//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(MartBuffer,true);
   ArraySetAsSeries(BorderTopBuffer,true);
   ArraySetAsSeries(BorderBotBuffer,true);
   ArraySetAsSeries(AxisBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"SnakeInBorders");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,upper_name);
   ObjectDelete(0,lower_name);
//----
  }
//+------------------------------------------------------------------+ 
//| XMA BBx3 iteration function                                      | 
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

//---- объявления локальных переменных 
   int limit,maxbar=rates_total-1;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      limit=maxbar; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double price=PriceSeries(IPC,bar,open,high,low,close);
      AxisBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,SnakeRange1,price,bar,true);
      MainCalculation(bar,open,high,low,close,rates_total);
      BorderTopBuffer[bar]+=dPriceShift;
      BorderBotBuffer[bar]+=dPriceShift;
      MartBuffer[bar]+=dPriceShift;
     }
   int bar0=0;
   SetRightPrice(0,upper_name,0,time[bar0],BorderTopBuffer[bar0],Upper_color,"Georgia");
   SetRightPrice(0,lower_name,0,time[bar0],BorderBotBuffer[bar0],Lower_color,"Georgia");
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| MainCalculation()                                                |
//+------------------------------------------------------------------+
void MainCalculation(int Pos,
              const double &Open[],
              const double &High[],
              const double &Low[],
              const double &Close[],
              const int Rates_Total)
  {
//----
   MartAxis(Pos,Open,Low,High,Close,Rates_Total);
   if(HardCalc==true) SmoothOverMart2(Pos,Rates_Total);
   else SmoothOverMart(Pos,Rates_Total);
//----
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MartAxis(int Pos,
              const double &Open[],
              const double &High[],
              const double &Low[],
              const double &Close[],
              const int Rates_Total)
  {
//----
   int    SnakeWeight,i,w,ww,shift;
   double SnakeSum;
   for(shift=int(MathMin(Pos+SnakeRange+2,Rates_Total-1)); shift>Pos; shift--)
     {
      SnakeSum=NULL;
      SnakeWeight=NULL;
      i=NULL;
      w=int(MathMin(shift+SnakeRange,Rates_Total-1));
      ww=shift-int(SnakeRange);
      if(ww<Pos) ww=Pos;
      while(w>=shift)
        {
         i++;
         SnakeSum+=i*PriceSeries(IPC,w,Open,Low,High,Close);
         SnakeWeight+=i;
         w--;
        }
      while(w>=ww)
        {
         i--;
         SnakeSum+=i*PriceSeries(IPC,w,Open,Low,High,Close);
         SnakeWeight+=i;
         w--;
        }
      if(!SnakeWeight) SnakeWeight=1;
      AxisBuffer[shift]=SnakeSum/SnakeWeight;
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| SmoothOverMart()                                                 |
//+------------------------------------------------------------------+
void SmoothOverMart(int Pos,const int Rates_Total)
  { // Правим историю на последних Pos...(Pos+SnakeRange+2) барах
//----
   int    shift;
   double a,t,b;
   for(shift=int(MathMin(Pos+SnakeRange+2,Rates_Total-1)); shift>=Pos; shift--)
     {
      t=AxisBuffer[ArrayMaximum(AxisBuffer,shift,FilterPeriod)];
      b=AxisBuffer[ArrayMinimum(AxisBuffer,shift,FilterPeriod)];
      a=AxisBuffer[shift];
      BorderTopBuffer[shift]=(2*(1+MartFiltr)*a+(t-b))/2/(1+MartFiltr);
      BorderBotBuffer[shift]=(2*(1+MartFiltr)*a-(t-b))/2/(1+MartFiltr);
      MartBuffer[shift]=(2*(2+MartFiltr)*a-(t+b))/2/(1+MartFiltr);
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| SmoothOverMart2()                                                |
//+------------------------------------------------------------------+
void SmoothOverMart2(int shift,const int Rates_Total)
  { // Не подправляем историю на последних барах
//----
   double a,t,b;
   t = AxisBuffer[ArrayMaximum(AxisBuffer,shift,FilterPeriod)];
   b = AxisBuffer[ArrayMinimum(AxisBuffer,shift,FilterPeriod)];
   a = AxisBuffer[shift];
   BorderTopBuffer[shift]=(2*(1+MartFiltr)*a+(t-b))/2/(1+MartFiltr);
   BorderBotBuffer[shift]=(2*(1+MartFiltr)*a-(t-b))/2/(1+MartFiltr);
   MartBuffer[shift]=(2*(2+MartFiltr)*a -(t+b))/2/(1+MartFiltr);
//----
   return;
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color,             // Text color
                      string   Font               // Text font
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color,             // Text color
                   string   Font               // Text font
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,Font);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
