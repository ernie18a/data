//+------------------------------------------------------------------+
//|                                   PChannel3_Cloud_Digit_Grid.mq5 |
//|                                           Copyright © 2005, Xaoc |
//|                                             http://forex.xcd.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Xaoc"
#property link      "http://forex.xcd.ru/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано семь буферов
#property indicator_buffers 7
//--- использовано пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован PaleGreen
#property indicator_color1  clrPaleGreen
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхней границы         |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычьей линии индикатора использован зеленый цвет
#property indicator_color2  clrTeal
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычьей метки индикатора
#property indicator_label2  "TOPBAND"
//+----------------------------------------------+
//|  Параметры отрисовки средней линии           |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован синий цвет
#property indicator_color3  clrBlue
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "MIDBAND"
//+----------------------------------------------+
//|  Параметры отрисовки нижней границы          |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color4  clrRed
//---- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "BOTBAND"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//---- в качестве цвета облака использован Pink
#property indicator_color5  clrPink
//---- отображение метки индикатора
#property indicator_label5  "Upper Cloud"
//+----------------------------------------------+
//|  Объявление перечисления                     |
//+----------------------------------------------+  
enum WIDTH
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+----------------------------------------------+
//|  Объявление перечисления                     |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,//Сплошная линия
   DASH_,//Штриховая линия
   DOT_,//Пунктирная линия
   DASHDOT_,//Штрих-пунктирная линия
   DASHDOTDOT_   //Штрих-пунктирная линия с двойными точками
  };
//+----------------------------------------------+
//|  Входные параметры индикатора                |
//+----------------------------------------------+
input string  SirName="PChannel3_Cloud_Digit_Grid";     //Первая часть имени графических объектов
input uint   PCPeriod=55;
input int    Shift=0;     // Сдвиг индикатора по горизонтали в барах 
input uint Digit=2; //количество разрядов округления
input bool RoundPrice=true; //округлять цены
input bool ShowPrice=true; //показывать ценовые метки
//---- цвета ценовых меток
input color  Middle_color=clrBlue;
input color  Upper_color=clrMediumSeaGreen;
input color  Lower_color=clrRed;
//---- Параметры ценовой сетки
input uint  Total=200;                       //количество блоков сетки сверху или снизу от цены
//----
input color  Color_A = clrSlateBlue;         //цвет уровня 1 
input STYLE  Style_A = DASHDOTDOT_;          //стиль линии уровня 1
input WIDTH  Width_A = Width_1;              //толщина линии уровня 1
//----
input color  Color_B = clrDarkOrange;        //цвет уровня 2
input STYLE  Style_B = DASH_;                //стиль линии уровня 2
input WIDTH  Width_B = Width_1;              //толщина линии уровня 2
//----
input color  Color_C = clrMagenta;           //цвет уровня 3
input STYLE  Style_C = SOLID_;               //стиль линии уровня 3
input WIDTH  Width_C = Width_1;              //толщина линии уровня 3
//----
input color  Color_D = clrRed;               //цвет уровня 4
input STYLE  Style_D = SOLID_;               //стиль линии уровня 4
input WIDTH  Width_D = Width_1;              //толщина линии уровня 4
//----
input color  Color_E = clrLime;              //цвет уровня 5
input STYLE  Style_E = SOLID_;               //стиль линии уровня 5
input WIDTH  Width_E = Width_1;              //толщина линии уровня 5
//----
input uint Fontsizex= 2;                     //размер ценовых меток
input bool ShowLineInfo = true;              //отображение значения уровня на ценовом графике
//+----------------------------------------------+
//---- Объявление целочисленных переменных начала отсчета данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtUp1Buffer[];
double ExtUp2Buffer[];
double ExtABuffer[];
double ExtBBuffer[];
double ExtCBuffer[];
double ExtDn1Buffer[];
double ExtDn2Buffer[];
//---- Объявление строковых переменных для текстовых меток
string upper_name,middle_name,lower_name;
//---- Объявление переменных ценовой сетки
color clr;
STYLE Style;
WIDTH Width;
bool ShowPriceLable;
int middle,sizex,Normalize,Count;
string ObjectNames[];
double PointPow10,PointPow100,PointPow1000,PointPow10000,PointPow100000,PriceGrid[],Price[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   min_rates_total=int(PCPeriod);
//---- Инициализация строковых переменных
   upper_name=SirName+" upper text lable";
   middle_name=SirName+" middle text lable";
   lower_name=SirName+" lower text lable";
//---- распределение памяти под массивы переменных ценовой сетки 
   sizex=int(Total*2);
   ArrayResize(ObjectNames,sizex);
   ArrayResize(PriceGrid,sizex);
   ArrayResize(Price,sizex);
//---- инициализация имен
   for(Count=0; Count<sizex; Count++) ObjectNames[Count]=SirName+" PriceLine "+string(Count);
//---- инициализация переменных         
   PointPow10=_Point*MathPow(10,Digit);
   PointPow100=PointPow10*10;
   PointPow1000=PointPow10*100;
   PointPow10000=PointPow10*1000;
   PointPow100000=PointPow10*10000;
   middle=(sizex/2)-1;
   Normalize=int(_Digits-Digit);
//---- инициализация переменных         
   for(Count=middle; Count<sizex; Count++) PriceGrid[Count]=+NormalizeDouble(PointPow10*(Count-middle),Normalize);
   for(Count=middle-1; Count>=0; Count--) PriceGrid[Count]=-NormalizeDouble(PointPow10*(middle-Count),Normalize);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtUp1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtUp2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtUp1Buffer,true);
   ArraySetAsSeries(ExtUp2Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtABuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtABuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtBBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtBBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,ExtCBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtCBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,ExtDn1Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtDn2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtDn1Buffer,true);
   ArraySetAsSeries(ExtDn2Buffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"PChannel3_Cloud_Digit_Grid("+string(PCPeriod)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
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
   for(Count=0; Count<sizex; Count++) ObjectDelete(0,ObjectNames[Count]);
//----
   ChartRedraw(0);
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(Close,false);
   ArraySetAsSeries(Time,false);
//----
   double res=NormalizeDouble(PointPow10*MathCeil(Close[rates_total-1]/PointPow10),Normalize);
   if(prev_calculated!=rates_total)
     {
      for(Count=0; Count<sizex; Count++) ObjectDelete(0,ObjectNames[Count]);
     }
   for(Count=0; Count<sizex; Count++) Price[Count]=NormalizeDouble(res+PriceGrid[Count],Normalize);
   datetime Time0=Time[rates_total-1]+PeriodSeconds()*Shift;
   datetime TimeX=Time[0];
   for(Count=0; Count<sizex; Count++)
     {
      string info="";
      if(ShowLineInfo) info=ObjectNames[Count]+" "+DoubleToString(Price[Count],Normalize);

      if(!NormalizeDouble(Price[Count]-PointPow100000*MathCeil(Price[Count]/PointPow100000),Normalize))
        {
         SetTline(0,ObjectNames[Count],0,TimeX,Price[Count],Time0,Price[Count],Color_E,Style_E,Width_E,info);
        }
      else if(!NormalizeDouble(Price[Count]-PointPow10000*MathCeil(Price[Count]/PointPow10000),Normalize))
        {
         SetTline(0,ObjectNames[Count],0,TimeX,Price[Count],Time0,Price[Count],Color_D,Style_D,Width_D,info);
        }
      else if(!NormalizeDouble(Price[Count]-PointPow1000*MathCeil(Price[Count]/PointPow1000),Normalize))
        {
         SetTline(0,ObjectNames[Count],0,TimeX,Price[Count],Time0,Price[Count],Color_C,Style_C,Width_C,info);
        }
      else  if(!NormalizeDouble(Price[Count]-PointPow100*MathCeil(Price[Count]/PointPow100),Normalize))
        {
         SetTline(0,ObjectNames[Count],0,TimeX,Price[Count],Time0,Price[Count],Color_B,Style_B,Width_B,info);
        }
      else
        {
         SetTline(0,ObjectNames[Count],0,TimeX,Price[Count],Time0,Price[Count],Color_A,Style_A,Width_A,info);
        }
     }
//---- индексация элементов в массивах не как в таймсериях
   ArraySetAsSeries(Close,false);
   ArraySetAsSeries(Time,false);
//---- Объявление целочисленных переменных
   int limit;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчета только новых баров
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtABuffer[bar]=High[ArrayMaximum(High,bar,PCPeriod)];
      ExtCBuffer[bar]=Low[ArrayMinimum(Low,bar,PCPeriod)];
      ExtBBuffer[bar]=(ExtABuffer[bar]+ExtCBuffer[bar])/2.0;
      //----
      if(RoundPrice)
        {
         ExtBBuffer[bar]=PointPow10*MathRound(ExtBBuffer[bar]/PointPow10);
         ExtABuffer[bar]=PointPow10*MathCeil(ExtABuffer[bar]/PointPow10);
         ExtCBuffer[bar]=PointPow10*MathFloor(ExtCBuffer[bar]/PointPow10);
        }
      //----
      ExtUp1Buffer[bar]=ExtABuffer[bar];
      ExtUp2Buffer[bar]=ExtBBuffer[bar];
      ExtDn1Buffer[bar]=ExtBBuffer[bar];
      ExtDn2Buffer[bar]=ExtCBuffer[bar];
     }
//----
   if(ShowPrice)
     {
      int bar0=0;
      Time0=Time[bar0]+Shift*PeriodSeconds();
      SetRightPrice(0,middle_name,0,Time0,ExtBBuffer[bar0],Middle_color,"Georgia");
      SetRightPrice(0,upper_name,0,Time0,ExtABuffer[bar0],Upper_color,"Georgia");
      SetRightPrice(0,lower_name,0,Time0,ExtCBuffer[bar0],Lower_color,"Georgia");
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Создание трендовой линии                                        |
//+------------------------------------------------------------------+
void CreateTline(
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
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка трендовой линии                                   |
//+------------------------------------------------------------------+
void SetTline(
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
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
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
