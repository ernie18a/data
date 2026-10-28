//+------------------------------------------------------------------+
//|                                               InvertBar_Plus.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Перевёрнутый свечной график в отдельном окне с линиями Ask и Bid"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные бары
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrTeal,clrGray,clrMagenta
//---- толщина линий
#property indicator_width1 3
//---- отображение метки индикатора
#property indicator_label1  "InvertedOpen;InvertedHigh;InvertedLow;InvertedClose"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input bool AskShow=true;                       // отображать Ask
input color AskColor=clrBlue;                  // цвет линии Ask
input ENUM_LINE_STYLE AskStyle=STYLE_SOLID;    // стиль линии Ask
input bool BidShow=true;                       // отображать  Bid
input color BidColor=clrRed;                   // цвет линии  Bid
input ENUM_LINE_STYLE BidStyle=STYLE_SOLID;    // стиль линии Bid
input int IndicatorDigits=6;                   // формат точности отображения индикатора
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
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_total=1;

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
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,IndicatorDigits);
//---- имя для окон данных и метка для субъокон 
   string short_name="InvertBar_Plus";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- параметры отрисовки линии Bid и Ask 
   if(BidShow && AskShow)
    {
     IndicatorSetInteger(INDICATOR_LEVELS,2);
     IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,AskColor);
     IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,AskStyle);
     IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,BidColor);
     IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,BidStyle);
     
    }
  if(BidShow && !AskShow)
    {
     IndicatorSetInteger(INDICATOR_LEVELS,1);
     IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,BidColor);
     IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,BidStyle);
    }
  if(!BidShow && AskShow)
    {
     IndicatorSetInteger(INDICATOR_LEVELS,1);
     IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,AskColor);
     IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,AskStyle);
    }
//---- 
   return(INIT_SUCCEEDED);
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
   if(rates_total<min_rates_total)return(RESET);

//---- объявления локальных переменных 
   int limit,bar;

//---- расчёты необходимого количества копируемых данных и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(spread,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtOpenBuffer[bar]=1.0/open[bar];
      ExtCloseBuffer[bar]=1.0/close[bar];
      ExtHighBuffer[bar]=1.0/low[bar];
      ExtLowBuffer[bar]=1.0/high[bar];
     }
//---- Основной цикл исправления и окрашивания свечей
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2;
      else ExtColorBuffer[bar]=1;
     }
//---- отрисовка линий Bid и Ask 
   if(BidShow && AskShow)
    {
     IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtCloseBuffer[0]);
     IndicatorSetDouble(INDICATOR_LEVELVALUE,1,1.0/(close[0]+spread[0]*_Point));
    }
  if(BidShow && !AskShow)
    {
     IndicatorSetDouble(INDICATOR_LEVELVALUE,0,1.0/(close[0]+spread[0]*_Point));
    }
  if(!BidShow && AskShow)
    {
     IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtCloseBuffer[0]);
    }
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
                      color    Color,             // price color
                      int      fontsize,          // price size
                      string   text               // текст
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,fontsize);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);
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
                   color    Color,             // price color
                   int      fontsize,          // price size
                   string   text               // текст
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,fontsize,text);
   else
     {
      ObjectMove(chart_id,name,0,time,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }

//----
  }
//+------------------------------------------------------------------+
