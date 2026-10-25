//+------------------------------------------------------------------+ 
//|                                            ColorBarRange_HTF.mq5 | 
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов
#property indicator_buffers 6 
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "ColorBarRange_HTF" // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "ColorBarRange_HTF Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цветов линии использованы
#property indicator_color2  clrMediumSeaGreen,clrDeepPink
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "ColorBarRange_HTF Upper"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цветов линии использованы
#property indicator_color3  clrMediumSeaGreen,clrDeepPink
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width3  3
//---- отображение метки индикатора
#property indicator_label3  "ColorBarRange_HTF Lower"
//+-------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА       |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H12;//Период графика
//+-------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА       |
//+-------------------------------------+
input string  SirName="ColorBarRange_HTF"; // Первая часть имени графических объектов
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
input bool ShowPrice=true;                    // показывать ценовую метку
//---- цвета ценовых меток
input color  Up_Price_color=clrTeal;          // цвет верхней ценовой метки
input color  Dn_Price_color=clrRed;           // цвет нижней ценовой метки
//+-------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpLineBuffer[],ColorUpLineBuffer[];
double DnLineBuffer[],ColorDnLineBuffer[];
double UpBuffer[],DnBuffer[];
double dPriceShift;
//---- Объявление стрингов
string Symbol_,Word;
//---- Объявление стрингов для текстовых меток
string Up_Price_name,Dn_Price_name;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора ColorBarRange_HTF не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- Инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
   
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- Инициализация стрингов
   Up_Price_name=SirName+"Up_Price";
   Dn_Price_name=SirName+"Dn_Price";
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpLineBuffer,INDICATOR_DATA);   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorUpLineBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpLineBuffer,true);
   ArraySetAsSeries(ColorUpLineBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DnLineBuffer,INDICATOR_DATA);   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(5,ColorDnLineBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnLineBuffer,true);
   ArraySetAsSeries(ColorDnLineBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,Up_Price_name);
   ObjectDelete(0,Dn_Price_name);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   double iHigh[1],iLow[1],clr;
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- копируем вновь появившиеся данные в массив iTime
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);

      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         LastCountBar=bar;

         //---- копируем вновь появившиеся данные в массивы
         if(CopyHigh(Symbol(),TimeFrame,time[bar],1,iHigh)<=0) return(RESET);
         if(CopyLow(Symbol(),TimeFrame,time[bar],1,iLow)<=0) return(RESET);

         UpLineBuffer[bar]=UpBuffer[bar]=iHigh[0]+dPriceShift;
         DnLineBuffer[bar]=DnBuffer[bar]=iLow[0]+dPriceShift;
         
         if(UpLineBuffer[bar+1]<UpLineBuffer[bar]) clr=0;
         else if(UpLineBuffer[bar+1]>UpLineBuffer[bar]) clr=1;
         else clr=ColorUpLineBuffer[bar+1];
         ColorUpLineBuffer[bar]=clr;
         
         if(DnLineBuffer[bar+1]<DnLineBuffer[bar]) clr=0;
         else if(DnLineBuffer[bar+1]>DnLineBuffer[bar]) clr=1;
         else clr=ColorDnLineBuffer[bar+1];
         ColorDnLineBuffer[bar]=clr;
        }
      else
        {
         UpLineBuffer[bar]=UpBuffer[bar]=UpLineBuffer[bar+1];
         DnLineBuffer[bar]=DnBuffer[bar]=DnLineBuffer[bar+1];
         ColorUpLineBuffer[bar]=ColorUpLineBuffer[bar+1];
         ColorDnLineBuffer[bar]=ColorDnLineBuffer[bar+1];
        }
     }
     
//---- отображение ценовой метки
   if(ShowPrice)
     {
      int bar0=0;
      datetime time0=time[bar0]+1*PeriodSeconds();
      SetRightPrice(0,Up_Price_name,0,time0,UpBuffer[bar0],Up_Price_color);
      SetRightPrice(0,Dn_Price_name,0,time0,DnBuffer[bar0],Dn_Price_color);
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
                      color    Color              // Text color
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
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
                   color    Color              // Text color
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
