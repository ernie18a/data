//+------------------------------------------------------------------+ 
//|                                        Float_Pivot_Digit_Box.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2018, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора не использовано ни одного буфера
#property indicator_buffers 0
//---- использовано ноль графических построений
#property indicator_plots   0
//+----------------------------------------------+ 
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET     0            // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_,  //PRICE_TRENDFOLLOW0_2
   PRICE_DEMARK_         //Demark Price 
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string SirName="Float_Pivot_Digit_Box";       //Имя объекта 
input ENUM_TIMEFRAMES Timeframe=PERIOD_D1;          //Таймфрейм индикатора для расчета индикатора
input uint   NumberofBar=1;                         //Номер бара для расчета индикатора
input int IPeriod=100;                              //Период поиска экстремумов
input ENUM_APPLIED_PRICE_ IPC=PRICE_MEDIAN_;        //ценовая константа
input uint Digit=2;                                 //количество разрядов округления
input bool ShowPrice=true;                          //показывать ценовые метки
input color Upper_color=clrTeal;                    //Цвет верхней ценовой метки
input color Middle_color=clrBlue;                   //Цвет средней ценовой метки
input color Lower_color=clrMagenta;                 //Цвет нижней ценовой метки
input uint   BarsTotal=30;                          //количество баров прямоугольников
input uint   RightTail=5;                           //выступ прямоугольников за нулевой бар вправо в барах текущего графика
input color  Color_Res=C'202,255,202';              //Цвет верхней коробки
input color  Color_Sup=C'255,176,255';              //Цвет нижней коробки
//+----------------------------------------------+
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
string UpBoxName,DnBoxName;
string upper_name,middle_name,lower_name;
uint SecondRightTail,SecondLeftTail;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- получение хендла индикатора Float_Pivot_Digit
   Ind_Handle=iCustom(Symbol(),Timeframe,"Float_Pivot_Digit",SirName,IPeriod,IPC,0,Digit,false,Upper_color,Middle_color,Lower_color);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Float_Pivot_Digit");
      return(INIT_FAILED);
     }
//----
   SecondRightTail=RightTail*PeriodSeconds(PERIOD_CURRENT);
//---- Инициализация стрингов
   upper_name=SirName+" upper text lable";
   middle_name=SirName+" middle text lable";
   lower_name=SirName+" lower text lable";
   UpBoxName=SirName+"_Up";
   DnBoxName=SirName+"_Dn";
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- создание меток для отображения в DataWindow и имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Float_Pivot_Digit_Box");
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,SirName,0,-1);
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
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),Timeframe)) return(prev_calculated);
//----
   double Up[1],Md[1],Dn[1];
   int to_copy;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//----
   to_copy=1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,2,NumberofBar,1,Up)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,3,NumberofBar,1,Md)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,4,NumberofBar,1,Dn)<=0) return(RESET);
//----
   datetime time0=time[0]+SecondRightTail;
   SetRectangle(0,UpBoxName,0,time[BarsTotal-1],Md[0],time0,Up[0],Color_Res,true,UpBoxName);
   SetRectangle(0,DnBoxName,0,time[BarsTotal-1],Md[0],time0,Dn[0],Color_Sup,true,DnBoxName);
//----
   if(ShowPrice)
     {
      SetRightPrice(0,upper_name,0,time0,Up[0],Upper_color);
      SetRightPrice(0,middle_name,0,time0,Md[0],Middle_color);
      SetRightPrice(0,lower_name,0,time0,Dn[0],Lower_color);
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание прямоугольного объекта                                 |
//+------------------------------------------------------------------+
void CreateRectangle
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1
 double   price1,        // цена 1
 datetime time2,         // время 2
 double   price2,        // цена 2
 color    Color,         // цвет линии
 bool     background,    // фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); //запрет всплывающей подсказки
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка прямоугольного объекта                            |
//+------------------------------------------------------------------+
void SetRectangle
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время 1
 double   price1,        // цена 1
 datetime time2,         // время 2
 double   price2,        // цена 2
 color    Color,         // цвет линии
 bool     background,    // фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRectangle(chart_id,name,nwin,time1,price1,time2,price2,Color,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
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
