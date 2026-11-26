//+---------------------------------------------------------------------+
//|                            AbsolutelyNoLagLwma_BBx7_Cloud_Digit.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "AbsolutelyNoLagLwma Bollinger Bands"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 11
#property indicator_buffers 11 
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrDeepSkyBlue
//---- отображение метки индикатора
#property indicator_label1  "Upper Sigma3 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color2  clrLime
//---- отображение метки индикатора
#property indicator_label2  "Upper Sigma2 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type3   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color3  clrLavender
//---- отображение метки индикатора
#property indicator_label3  "Sigma1 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки мувинга                 |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color4 clrBlueViolet
//---- линия индикатора - сплошная
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4  2
//---- отображение метки индикатора
#property indicator_label4  "AbsolutelyNoLagLwma"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color5  clrMagenta
//---- отображение метки индикатора
#property indicator_label5  "Lower Sigma2 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type6   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color6  clrMediumOrchid
//---- отображение метки индикатора
#property indicator_label6  "Lower Sigma3 Cloud"
//+--------------------------------------------+
//|  Описание классов усреднений               |
//+--------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+--------------------------------------------+
//---- объявление переменных класса CStdDeviation из файла SmoothAlgorithms.mqh
CStdDeviation STD1,STD2,STD3;
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
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА              |
//+--------------------------------------------+
input uint LLength=7; //глубина  усреднения                    
input double BandsDeviation1=2.0; //девиация 1
input double BandsDeviation2=3.0; //девиация 2
input double BandsDeviation3=4.0; //девиация 3
input uint Digit=2; //количество разрядов округления
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
input bool ShowPrice=true; //показывать ценовые метки
//---- цвета ценовых меток
input color  Upper_color3=clrBlue;
input color  Upper_color2=clrDodgerBlue;
input color  Upper_color1=clrMediumSeaGreen;
input color  Middle_color=clrDarkGray;
input color  Lower_color1=clrRed;
input color  Lower_color2=clrMagenta;
input color  Lower_color3=clrOrange;
//+--------------------------------------------+
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer0[];
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов уровней Боллинджера
double UpBuffer1[],DnBuffer1[],UpBuffer2[],DnBuffer2[],UpBuffer3[],DnBuffer3[];
double UpBuffer4[],DnBuffer4[],UpBuffer5[],DnBuffer5[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift,PointPow10;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//---- Объявление стрингов для текстовых меток
string upper_name1,middle_name,lower_name1,upper_name2,lower_name2,upper_name3,lower_name3;
//---- объявление глобальных переменных
int Count[];
double Price[],Lwma[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(LLength*2.0);
   min_rates_total=min_rates_1+int(LLength);
   PointPow10=_Point*MathPow(10,Digit);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
   if(BandsDeviation1>=BandsDeviation2)
     {
      Print("Входной параметр Девиация 2 всегда должен быть больше входного параметра Девиация 1! Исправьте значения этих входных параметров индикатора!");
      return(INIT_FAILED);
     }
   if(BandsDeviation2>=BandsDeviation3)
     {
      Print("Входной параметр Девиация 3 всегда должен быть больше входного параметра Девиация 2! Исправьте значения этих входных параметров индикатора!");
      return(INIT_FAILED);
     }
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,LLength);
   ArrayResize(Price,LLength);
   ArrayResize(Lwma,LLength);

//---- Инициализация стрингов
   upper_name1="AbsolutelyNoLagLwma_BBx7_Cloud_Digit upper text lable 1";
   middle_name="AbsolutelyNoLagLwma_BBx7_Cloud_Digit middle text lable";
   lower_name1="AbsolutelyNoLagLwma_BBx7_Cloud_Digit lower text lable 1";
   upper_name2="AbsolutelyNoLagLwma_BBx7_Cloud_Digit upper text lable 2";
   lower_name2="AbsolutelyNoLagLwma_BBx7_Cloud_Digit lower text lable 2";
   upper_name3="AbsolutelyNoLagLwma_BBx7_Cloud_Digit upper text lable 3";
   lower_name3="AbsolutelyNoLagLwma_BBx7_Cloud_Digit lower text lable 3";

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer4,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer4,INDICATOR_DATA);
   SetIndexBuffer(2,UpBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
   SetIndexBuffer(4,UpBuffer1,INDICATOR_DATA);
   SetIndexBuffer(5,DnBuffer1,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer0,INDICATOR_DATA);
   SetIndexBuffer(7,UpBuffer3,INDICATOR_DATA);
   SetIndexBuffer(8,DnBuffer3,INDICATOR_DATA);
   SetIndexBuffer(9,UpBuffer5,INDICATOR_DATA);
   SetIndexBuffer(10,DnBuffer5,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"AbsolutelyNoLagLwma_BBx7_Cloud_Digit(",LLength,", ",
                     DoubleToString(BandsDeviation1,2),", ",DoubleToString(BandsDeviation2,2),", ",DoubleToString(BandsDeviation3,2),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,upper_name1);
   ObjectDelete(0,middle_name);
   ObjectDelete(0,lower_name1);
   ObjectDelete(0,upper_name2);
   ObjectDelete(0,lower_name2);
   ObjectDelete(0,upper_name3);
   ObjectDelete(0,lower_name3);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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

//---- Объявление переменных с плавающей точкой  
   double line,stdev;
      double sum,sumw,lwma2;

//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar,weight;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      ArrayInitialize(Count,0);
      ArrayInitialize(Price,0.0);
      ArrayInitialize(Lwma,0.0);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Price[Count[0]]=PriceSeries(IPC,bar,open,low,high,close);
      //----
      sum=0;
      sumw=0;
      for(int kkk=0; kkk<int(LLength); kkk++) { weight=int(LLength)-kkk; sumw+=weight; sum+=weight*Price[Count[kkk]]; }
      if(sumw) Lwma[Count[0]]=sum/sumw;
      else  Lwma[Count[0]]=NULL;
      //----
      sum=0;
      sumw=0;
      for(int kkk=0; kkk<int(LLength); kkk++) { weight=int(LLength)-kkk; sumw+=weight; sum+=weight*Lwma[Count[kkk]]; }
      if(sumw) lwma2=sum/sumw;
      else  lwma2=NULL;
      //----
      line=lwma2+dPriceShift;
      ExtLineBuffer0[bar]=PointPow10*MathRound(line/PointPow10);
      //---- расчёт и округление Боллинджера 1
      stdev=STD1.StdDevSeries(min_rates_1,prev_calculated,rates_total,LLength,BandsDeviation1,Price[Count[0]],lwma2,bar,false);
      UpBuffer1[bar]=DnBuffer2[bar]=PointPow10*MathCeil((line+stdev)/PointPow10);
      DnBuffer1[bar]=UpBuffer3[bar]=PointPow10*MathFloor((line-stdev)/PointPow10);
      //---- исправление Боллинджера 1
      if(ExtLineBuffer0[bar]>=UpBuffer1[bar]) UpBuffer1[bar]=DnBuffer2[bar]=ExtLineBuffer0[bar]+PointPow10;
      if(ExtLineBuffer0[bar]<=DnBuffer1[bar]) DnBuffer1[bar]=UpBuffer3[bar]=ExtLineBuffer0[bar]-PointPow10;
      //---- расчёт и округление Боллинджера 2
      stdev=STD2.StdDevSeries(min_rates_1,prev_calculated,rates_total,LLength,BandsDeviation2,Price[Count[0]],lwma2,bar,false);
      UpBuffer2[bar]=DnBuffer4[bar]=PointPow10*MathCeil((line+stdev)/PointPow10);
      DnBuffer3[bar]=UpBuffer5[bar]=PointPow10*MathFloor((line-stdev)/PointPow10);
      //---- исправление Боллинджера 2
      if(UpBuffer1[bar]>=UpBuffer2[bar]) UpBuffer2[bar]=DnBuffer4[bar]=UpBuffer1[bar]+PointPow10;
      if(DnBuffer1[bar]<=DnBuffer3[bar]) DnBuffer3[bar]=UpBuffer5[bar]=DnBuffer1[bar]-PointPow10;
      //---- расчёт и округление Боллинджера 3        
      stdev=STD3.StdDevSeries(min_rates_1,prev_calculated,rates_total,LLength,BandsDeviation3,Price[Count[0]],lwma2,bar,false);
      UpBuffer4[bar]=PointPow10*MathCeil((line+stdev)/PointPow10);
      DnBuffer5[bar]=PointPow10*MathFloor((line-stdev)/PointPow10);
      //---- исправление Боллинджера 3
      if(UpBuffer2[bar]>=UpBuffer4[bar]) UpBuffer4[bar]=UpBuffer2[bar]+PointPow10;
      if(DnBuffer3[bar]<=DnBuffer5[bar]) DnBuffer5[bar]=DnBuffer3[bar]-PointPow10;
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,LLength);
     }
   if(ShowPrice)
     {
      int bar0=rates_total-1;
      datetime time0=time[bar0]+Shift*PeriodSeconds();
      SetRightPrice(0,middle_name,0,time0,ExtLineBuffer0[bar0],Middle_color,"Georgia");
      SetRightPrice(0,upper_name1,0,time0,UpBuffer1[bar0],Upper_color1,"Georgia");
      SetRightPrice(0,lower_name1,0,time0,DnBuffer1[bar0],Lower_color1,"Georgia");
      SetRightPrice(0,upper_name2,0,time0,UpBuffer2[bar0],Upper_color2,"Georgia");
      SetRightPrice(0,lower_name2,0,time0,DnBuffer3[bar0],Lower_color2,"Georgia");
      SetRightPrice(0,upper_name3,0,time0,UpBuffer4[bar0],Upper_color3,"Georgia");
      SetRightPrice(0,lower_name3,0,time0,DnBuffer5[bar0],Lower_color3,"Georgia");
     }
//----     
   ChartRedraw(0);
   return(rates_total);
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
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,2);
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
