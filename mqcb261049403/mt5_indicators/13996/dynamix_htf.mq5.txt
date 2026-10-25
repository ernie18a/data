//+------------------------------------------------------------------+
//|                                                  dynamix_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0                                      // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "dynamix"                     // Константа для имени индикатора
#define SIZE 27                                      // Константа для количества вызовов функции CountIndicator
//+-----------------------------------+
#property description "dynamix",SIZE
//---- количество индикаторных буферов
#property indicator_buffers SIZE 
//---- использовано всего графических построений
#property indicator_plots   SIZE

//+-----------------------------------+
//|  Параметры отрисовки индикаторов  |
//+-----------------------------------+
//---- отрисовка осцилляторов в виде линий
#property indicator_type1   DRAW_LINE
//---- линии - штрихпунктирные кривые
#property indicator_style1 STYLE_SOLID
//---- толщина линий 2
#property indicator_width1 2
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
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
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Период графика индикатора
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint step=10; //шаг построения скользящих средних, оптимальный диапазон значений - от 1 до 10
input Applied_price_ IPC=PRICE_CLOSE;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int ColorWidth=40; //ширина цветовой палитры (изменяется от 0 до 131)
//+-----------------------------------+
//---- Объявление стрингов
string Symbol_,Word;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных буферов            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[SIZE];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
   
//---- получение хендла индикатора dynamix
   Ind_Handle=iCustom(Symbol(),TimeFrame,INDICATOR_NAME,step,IPC,0,40);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора "+INDICATOR_NAME);
      return(INIT_FAILED);
     }

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2;

   color ArrayColors[]=
     {
      //---- 
      Black,DarkGreen,DarkSlateGray,Olive,Green,Teal,Navy,Purple,Maroon,Indigo,MidnightBlue,DarkBlue,
      DarkOliveGreen,SaddleBrown,ForestGreen,OliveDrab,SeaGreen,DarkGoldenrod,DarkSlateBlue,Sienna,MediumBlue,
      Brown,DarkTurquoise,DimGray,LightSeaGreen,DarkViolet,FireBrick,MediumVioletRed,MediumSeaGreen,Chocolate,
      Crimson,SteelBlue,Goldenrod,MediumSpringGreen,LawnGreen,CadetBlue,DarkOrchid,YellowGreen,LimeGreen,OrangeRed,
      DarkOrange,Orange,Gold,Yellow,Chartreuse,Lime,SpringGreen,Aqua,DeepSkyBlue,Blue,Magenta,Red,Gray,
      SlateGray,Peru,BlueViolet,LightSlateGray,DeepPink,MediumTurquoise,DodgerBlue,Turquoise,RoyalBlue,SlateBlue,
      DarkKhaki,IndianRed,MediumOrchid,GreenYellow,MediumAquamarine,DarkSeaGreen,Tomato,RosyBrown,Orchid,MediumPurple,
      PaleVioletRed,Coral,CornflowerBlue,DarkGray,SandyBrown,MediumSlateBlue,Tan,DarkSalmon,BurlyWood,HotPink,Salmon,
      Violet,LightCoral,SkyBlue,LightSalmon,Plum,Khaki,LightGreen,Aquamarine,Silver,LightSkyBlue,LightSteelBlue,
      LightBlue,PaleGreen,Thistle,PowderBlue,PaleGoldenrod,PaleTurquoise,LightGray,Wheat,NavajoWhite,Moccasin,LightPink,
      Gainsboro,PeachPuff,Pink,Bisque,LightGoldenrod,BlanchedAlmond,LemonChiffon,Beige,AntiqueWhite,PapayaWhip,Cornsilk,
      LightYellow,LightCyan,Linen,Lavender,MistyRose,OldLace,WhiteSmoke,Seashell,Ivory,Honeydew,AliceBlue,
      LavenderBlush,MintCream,Snow,White
      //---- 
     };

   int size=ArraySize(ArrayColors);
   size-=2;
   int ColorWidth_=ColorWidth;
   if(ColorWidth>size) ColorWidth_=size;
   if(ColorWidth<1) ColorWidth_=1;

   color Colors[];

   if(ArrayResize(Colors,ColorWidth_)<ColorWidth_) Print("Не удалось распределить память под массив Colors");
   ArrayCopy(Colors,ArrayColors,0,2,ColorWidth_);

//---- индексация элементов в массиве как в таймсерии   
   ArraySetAsSeries(Colors,true);

   double K=double(ColorWidth_/(SIZE*1.0));
//----
   for(int numb=0; numb<SIZE; numb++)
     {
      string shortname="";
      StringConcatenate(shortname,"dynamix",numb);
      //--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- установка значений индикатора, которые не будут видимы на графике
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- осуществление сдвига начала отсчёта отрисовки индикатора
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(numb,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- копирование свойств первой линии индикатора для всех остальных
      PlotIndexSetInteger(numb,PLOT_DRAW_TYPE,PlotIndexGetInteger(0,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb,PLOT_LINE_STYLE,PlotIndexGetInteger(0,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb,PLOT_LINE_WIDTH,PlotIndexGetInteger(0,PLOT_LINE_WIDTH));
      //---- задание цвета для линии
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,Colors[int(numb*K)]);
     }

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"dynamix",SIZE,"(",step,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
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
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true); 
//----
   for(int numb=0; numb<SIZE; numb++) if(!CountIndicator(numb,NULL,TimeFrame,Ind_Handle,numb,Ind[numb].IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(
                    uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора
                    double&  IndBuf[],        // Приёмный буфер индикатора
                    const datetime& iTime[],  // Таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total // минимальное количество истории в барах для расчёта
                    )
//---- 
  {
//----
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчёта всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчёта новых баров 

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      IndBuf[bar]=0.0;

      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];

         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);

         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
     }
//----     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(
                     string IndName,
                     ENUM_TIMEFRAMES TFrame //Период графика индикатора
                     )
//TimeFramesCheck(INDICATOR_NAME,TimeFrame)
  {
//---- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
