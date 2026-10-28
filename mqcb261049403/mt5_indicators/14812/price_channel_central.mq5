//+------------------------------------------------------------------+
//|                                        Price_Channel_Central.mq5 |
//|                             Copyright © 2015, Yuriy Tokman (YTG) |
//|                                               http://ytg.com.ua/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Yuriy Tokman (YTG)"
//---- ссылка на сайт автора
#property link      "http://ytg.com.ua/"
//---- номер версии индикатора
#property version   "1.00"
#property description "Price Channel Central" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано 5 буферов
#property indicator_buffers 5
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве индикатора использована линия
#property indicator_type1   DRAW_LINE
//---- отображение метки индикатора
#property indicator_label1  "Chanell Upper"
//---- в качестве цветов линии индикатора использован
#property indicator_color1 clrLime
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве индикатора использована линия
#property indicator_type2   DRAW_LINE
//---- отображение метки индикатора
#property indicator_label2  "Chanell Middle"
//---- в качестве цветов линии индикатора использован
#property indicator_color2 clrBlue
//---- линия индикатора - сплошная
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- в качестве индикатора использована линия
#property indicator_type3   DRAW_LINE
//---- отображение метки индикатора
#property indicator_label3  "Chanell Lower"
//---- в качестве цветов линии индикатора использован
#property indicator_color3 clrRed
//---- линия индикатора - сплошная
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color4  clrMagenta
//--- толщина линии индикатора 4 равна 5
#property indicator_width4  5
//--- отображение медвежьей метки индикатора
#property indicator_label4  "Price_Channel_Central Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован голубой цвет
#property indicator_color5  clrDodgerBlue
//--- толщина линии индикатора 5 равна 5
#property indicator_width5  5
//--- отображение бычьей метки индикатора
#property indicator_label5 "Price_Channel_Central Buy"
//+----------------------------------------------+ 
//| Объявление констант                          |
//+----------------------------------------------+ 
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input uint Bars_Count=32;
input color  Upper_color=clrTeal;
input color  Middle_color=clrBlue;
input color  Lower_color=clrRed;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double LowestBuffer[];
double HighestBuffer[];
double MiddleBuffer[];
double SellBuffer[];
double BuyBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление строковых переменных для текстовых меток
string upper_name,middle_name,lower_name;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   int ATR_Period=15;
   min_rates_total=int(MathMax(Bars_Count,ATR_Period))+1;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- инициализация строковых переменных
   upper_name="Price_Channel_Central upper text lable";
   middle_name="Price_Channel_Central middle text lable";
   lower_name="Price_Channel_Central lower text lable";
//---- превращение динамических массивов в индикаторные буферы    
   SetIndexBuffer(0,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,SellBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,BuyBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(MiddleBuffer,true);
   ArraySetAsSeries(SellBuffer,true);
   ArraySetAsSeries(BuyBuffer,true);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"Price_Channel_Central(",Bars_Count,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,upper_name);
   ObjectDelete(0,middle_name);
   ObjectDelete(0,lower_name);
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total)return(RESET);
//---- объявление локальных переменных 
   int limit,to_copy,bar;
   double ATR[];
//---- расчет стартового номера limit для цикла пересчета баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ATR,true);
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//---- первый большой цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double HH=high[ArrayMaximum(high,bar,Bars_Count)];
      double LL=low[ArrayMinimum(low,bar,Bars_Count)];
      double MM=(HH+LL)/2;
      HighestBuffer[bar]=HH;
      LowestBuffer[bar]=LL;
      MiddleBuffer[bar]=MM;
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(close[bar]>HighestBuffer[bar+1]) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(close[bar]<LowestBuffer[bar+1]) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
     }
   SetRightPrice(0,upper_name,0,time[0],HighestBuffer[0],Upper_color,"Georgia");
   SetRightPrice(0,middle_name,0,time[0],MiddleBuffer[0],Middle_color,"Georgia");
   SetRightPrice(0,lower_name,0,time[0],LowestBuffer[0],Lower_color,"Georgia");
//----     
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
                      string   Font)              // Text font
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
void SetRightPrice(long chart_id,              // chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color,             // Text color
                   string   Font)              // Text font
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,Font);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
