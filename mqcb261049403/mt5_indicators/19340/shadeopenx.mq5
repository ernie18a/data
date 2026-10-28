//+------------------------------------------------------------------+ 
//|                                                   ShadeOpenX.mq5 | 
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "Индикатор ночных ссесий в виде свечек."
//--- отрисовка индикатора в основном окне
#property indicator_chart_window
//--- количество индикаторных буферов 0
#property indicator_buffers 0
//--- не использовано ни одного графического построения
#property indicator_plots   0
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                        // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "ShadeOpenX"                    // Константа для имени индикатора
#define EMPTYVALUE 0                                   // Константа для неотображаемых значений индикатора
//+------------------------------------------------------------------+
//|  Объявление перечисления часов суток                             |
//+------------------------------------------------------------------+
enum HOURS
  {
   ENUM_HOUR_0=0,   //0
   ENUM_HOUR_1,     //1
   ENUM_HOUR_2,     //2
   ENUM_HOUR_3,     //3
   ENUM_HOUR_4,     //4
   ENUM_HOUR_5,     //5
   ENUM_HOUR_6,     //6
   ENUM_HOUR_7,     //7
   ENUM_HOUR_8,     //8
   ENUM_HOUR_9,     //9
   ENUM_HOUR_10,     //10
   ENUM_HOUR_11,     //11   
   ENUM_HOUR_12,     //12
   ENUM_HOUR_13,     //13
   ENUM_HOUR_14,     //14
   ENUM_HOUR_15,     //15
   ENUM_HOUR_16,     //16
   ENUM_HOUR_17,     //17
   ENUM_HOUR_18,     //18
   ENUM_HOUR_19,     //19
   ENUM_HOUR_20,     //20
   ENUM_HOUR_21,     //21  
   ENUM_HOUR_22,     //22
   ENUM_HOUR_23      //23    
  };
//+------------------------------------------------------------------+
//|  Объявление перечисления минут часов                             |
//+------------------------------------------------------------------+
enum MINUTS
  {
   ENUM_MINUT_0=0,   //0
   ENUM_MINUT_1,     //1
   ENUM_MINUT_2,     //2
   ENUM_MINUT_3,     //3
   ENUM_MINUT_4,     //4
   ENUM_MINUT_5,     //5
   ENUM_MINUT_6,     //6
   ENUM_MINUT_7,     //7
   ENUM_MINUT_8,     //8
   ENUM_MINUT_9,     //9
   ENUM_MINUT_10,     //10
   ENUM_MINUT_11,     //11   
   ENUM_MINUT_12,     //12
   ENUM_MINUT_13,     //13
   ENUM_MINUT_14,     //14
   ENUM_MINUT_15,     //15
   ENUM_MINUT_16,     //16
   ENUM_MINUT_17,     //17
   ENUM_MINUT_18,     //18
   ENUM_MINUT_19,     //19
   ENUM_MINUT_20,     //20
   ENUM_MINUT_21,     //21  
   ENUM_MINUT_22,     //22
   ENUM_MINUT_23,     //23
   ENUM_MINUT_24,     //24
   ENUM_MINUT_25,     //25
   ENUM_MINUT_26,     //26
   ENUM_MINUT_27,     //27
   ENUM_MINUT_28,     //28
   ENUM_MINUT_29,     //29
   ENUM_MINUT_30,     //30
   ENUM_MINUT_31,     //31  
   ENUM_MINUT_32,     //32
   ENUM_MINUT_33,     //33
   ENUM_MINUT_34,     //34
   ENUM_MINUT_35,     //35
   ENUM_MINUT_36,     //36
   ENUM_MINUT_37,     //37
   ENUM_MINUT_38,     //38
   ENUM_MINUT_39,     //39 
   ENUM_MINUT_40,     //40
   ENUM_MINUT_41,     //41  
   ENUM_MINUT_42,     //42
   ENUM_MINUT_43,     //43
   ENUM_MINUT_44,     //44
   ENUM_MINUT_45,     //45
   ENUM_MINUT_46,     //46
   ENUM_MINUT_47,     //47
   ENUM_MINUT_48,     //48
   ENUM_MINUT_49,     //49
   ENUM_MINUT_50,     //50
   ENUM_MINUT_51,     //51  
   ENUM_MINUT_52,     //52
   ENUM_MINUT_53,     //53
   ENUM_MINUT_54,     //54
   ENUM_MINUT_55,     //55
   ENUM_MINUT_56,     //56
   ENUM_MINUT_57,     //57
   ENUM_MINUT_58,     //58
   ENUM_MINUT_59      //59             
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input string SirName=INDICATOR_NAME; //имя графических объектов]
input HOURS  StartH=ENUM_HOUR_6;     //Старт торговли (Часы)
input MINUTS StartM=ENUM_MINUT_30;   //Старт торговли (Минуты)
input HOURS  EndH=ENUM_HOUR_13;      //Окончание торговли (Часы)
input MINUTS EndM=ENUM_MINUT_5;      //Окончание торговли (Минуты) 
input color Upbody=clrLimeGreen;     //цвет тела свечи Рост
input color Dnbody=clrDarkOrange;    //цвет тела свечи Падение
input color Uphigh=clrPaleGreen;     //цвет верхней тени Рост
input color Dnhigh=clrYellow;        //цвет верхней тени Падение
input color Uplow=clrPaleGreen;     //цвет нижней тени Рост
input color Dnlow=clrYellow;        //цвет нижней тени Падение
//+----------------------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление стринговых имён графических объектов
string candlebody,candlehigh,candlelow;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка входных переменных 
   if(StartH>EndH || (StartH==EndH && StartM>=EndM))
     {
      Print("Неверные значения входных переменных старта и окончания торговли!");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- инициализация переменных 
   min_rates_total=2;
   candlebody=SirName+"_candlebody";
   candlehigh=SirName+"_candlehigh";
   candlelow=SirName+"_candlelow";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---- 
   ObjectDelete(0,candlebody);
   ObjectDelete(0,candlehigh);
   ObjectDelete(0,candlelow);
//----
   ChartRedraw(NULL);
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
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- поиск начала дня
   datetime iTime[1];
   if(CopyTime(Symbol(),PERIOD_D1,time[0],1,iTime)<=0) return(RESET);
   limit=0;
   for(int bar=0; bar<rates_total-1 && !IsStopped(); bar++)
     {
      if(time[bar]<iTime[0]) break;
      limit++;
     }

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(!ShadeOpenCheck(time[bar]))
        {

         continue;
        }
      else
        {
         datetime Start=GetShadeOpenStart(time[bar]);
         datetime End=MathMin(GetShadeOpenEnd(time[bar]),time[0]);
         double iOpen[1],iClose[1],iHigh[],iLow[];
         //---- индексация элементов в массивах как в таймсериях  
         ArraySetAsSeries(iHigh,true);
         ArraySetAsSeries(iLow,true);
         //----
         if(CopyOpen(Symbol(),PERIOD_CURRENT,Start,1,iOpen)<=0) return(RESET);
         if(CopyHigh(Symbol(),PERIOD_CURRENT,Start,End,iHigh)<=0) return(RESET);
         if(CopyLow(Symbol(),PERIOD_CURRENT,Start,End,iLow)<=0) return(RESET);
         if(CopyClose(Symbol(),PERIOD_CURRENT,End,1,iClose)<=0) return(RESET);
         //----
         double ihigh=iHigh[ArrayMaximum(iHigh,0,WHOLE_ARRAY)];
         double ilow=iLow[ArrayMinimum(iLow,0,WHOLE_ARRAY)];
         //----
         if(iClose[0]>=iOpen[0])
           {
            SetRectangle(0,candlebody,0,Start,iOpen[0],End,iClose[0],Upbody,0,0,candlebody);
            SetRectangle(0,candlehigh,0,Start,iClose[0],End,ihigh,Uphigh,0,0,candlehigh);
            SetRectangle(0,candlelow,0,Start,iOpen[0],End,ilow,Uplow,0,0,candlelow);
           }
         else
           {
            SetRectangle(0,candlebody,0,Start,iOpen[0],End,iClose[0],Dnbody,0,0,candlebody);
            SetRectangle(0,candlehigh,0,Start,iOpen[0],End,ihigh,Dnhigh,0,0,candlehigh);
            SetRectangle(0,candlelow,0,Start,iClose[0],End,ilow,Dnlow,0,0,candlelow);
           }
        }
     }
//----  
   ChartRedraw(NULL);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание прямоугольника                                         |
//+------------------------------------------------------------------+
void CreateRectangle
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1 ценового уровня
 double   price1,        // 1 ценовой уровень
 datetime time2,         // время 2 ценового уровня
 double   price2,        // 2 ценовой уровень
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка прямоугольника                                    |
//+------------------------------------------------------------------+
void SetRectangle
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1 ценового уровня
 double   price1,        // 1 ценовой уровень
 datetime time2,         // время 2 ценового уровня
 double   price2,        // 2 ценовой уровень
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRectangle(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+  
//| Определение сигналов для торговли в периоде                      |
//+------------------------------------------------------------------+  
bool ShadeOpenCheck(datetime ChkTime)
  {
//---- Объявление переменной для разрешения торговли
   bool Trade=false;
   MqlDateTime tm;
   TimeToStruct(ChkTime,tm);

   if(StartH<EndH)
     {
      if(tm.hour==StartH && tm.min>=StartM) Trade=true;
      if(tm.hour>StartH && tm.hour<EndH) Trade=true;
      if(tm.hour>StartH && tm.hour==EndH && tm.min<EndM) Trade=true;
     }
   if(StartH==EndH)
     {
      if(tm.hour==StartH && tm.min>=StartM && tm.min<EndM) Trade=true;
     }
//---- 
   return(Trade);
  }
//+------------------------------------------------------------------+  
//| Определение начала для торговли в периоде                        |
//+------------------------------------------------------------------+  
datetime GetShadeOpenStart(datetime ChkTime)
  {
//---- 
   datetime Start,iTime[1];
   if(CopyTime(Symbol(),PERIOD_D1,ChkTime,1,iTime)<=0) return(RESET);
   Start=iTime[0]+StartH*60*60+StartM*60;
//---- 
   return(Start);
  }
//+------------------------------------------------------------------+  
//| Определение конца для торговли в периоде                         |
//+------------------------------------------------------------------+  
datetime GetShadeOpenEnd(datetime ChkTime)
  {
//---- Объявление
   datetime End,iTime[1];
   if(CopyTime(Symbol(),PERIOD_D1,ChkTime,1,iTime)<=0) return(RESET);
   End=iTime[0]+EndH*60*60+EndM*60;
//---- 
   return(End);
  }
//+------------------------------------------------------------------+
//| PlotInit()                                                       |
//+------------------------------------------------------------------+    
void PlotInit(uint PlotNumber,
              int DrawBegin,
              int PlotShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,DrawBegin);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,PlotShift);
//---
  }
//+------------------------------------------------------------------+
//| ArrayInit()                                                      |
//+------------------------------------------------------------------+    
void ArrayInit(uint ArrNumber,
               double &Array[])
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(ArrNumber,Array,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Array,true);
//---
  }
//+------------------------------------------------------------------+
