//+------------------------------------------------------------------+
//|                                                  ColorDM_361.mq5 | 
//|                                  Copyright 2002, Finware.ru Ltd. | 
//|                                           http://www.finware.ru/ | 
//+------------------------------------------------------------------+
#property copyright "Copyright 2002, Finware.ru Ltd."
#property link "http://www.finware.ru/"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветных значков
#property indicator_type1   DRAW_COLOR_ARROW
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color1  clrMagenta,clrGray,clrTeal
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ColorDM_361"
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
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double InBuffer[];
double ColorInBuffer[];

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=65;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,InBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorInBuffer,INDICATOR_COLOR_INDEX);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"ColorDM_361");

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
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
   double Res1,Res2;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar,clr;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_total; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Res1=
           -0.057943686277445900*PriceSeries(IPC,bar-00,open,low,high,close)
           -0.043658266634319700*PriceSeries(IPC,bar-01,open,low,high,close)
           +0.016893339337967300*PriceSeries(IPC,bar-02,open,low,high,close)
           +0.110448213843891000*PriceSeries(IPC,bar-03,open,low,high,close)
           +0.205220247113110000*PriceSeries(IPC,bar-04,open,low,high,close)
           +0.264664029548369000*PriceSeries(IPC,bar-05,open,low,high,close)
           +0.264664029548369000*PriceSeries(IPC,bar-06,open,low,high,close)
           +0.205220247113110000*PriceSeries(IPC,bar-07,open,low,high,close)
           +0.110448213843891000*PriceSeries(IPC,bar-08,open,low,high,close)
           +0.016893339337967300*PriceSeries(IPC,bar-09,open,low,high,close)
           -0.043658266634319700*PriceSeries(IPC,bar-10,open,low,high,close)
           -0.057943686277445900*PriceSeries(IPC,bar-11,open,low,high,close)
           -0.034834636631794200*PriceSeries(IPC,bar-12,open,low,high,close)
           +0.002212354734218340*PriceSeries(IPC,bar-13,open,low,high,close)
           +0.028933121721909400*PriceSeries(IPC,bar-14,open,low,high,close)
           +0.032424401776343200*PriceSeries(IPC,bar-15,open,low,high,close)
           +0.015569833996195800*PriceSeries(IPC,bar-16,open,low,high,close)
           -0.007660554868813180*PriceSeries(IPC,bar-17,open,low,high,close)
           -0.022138347829420900*PriceSeries(IPC,bar-18,open,low,high,close)
           -0.020552990368271800*PriceSeries(IPC,bar-19,open,low,high,close)
           -0.006433347602730440*PriceSeries(IPC,bar-20,open,low,high,close)
           +0.009627481503821010*PriceSeries(IPC,bar-21,open,low,high,close)
           +0.017394469333231100*PriceSeries(IPC,bar-22,open,low,high,close)
           +0.013176086997509700*PriceSeries(IPC,bar-23,open,low,high,close)
           +0.001209424586624090*PriceSeries(IPC,bar-24,open,low,high,close)
           -0.010002709133594700*PriceSeries(IPC,bar-25,open,low,high,close)
           -0.013505578777899800*PriceSeries(IPC,bar-26,open,low,high,close)
           -0.008035831519405070*PriceSeries(IPC,bar-27,open,low,high,close)
           +0.001903891095510710*PriceSeries(IPC,bar-28,open,low,high,close)
           +0.009480467257466930*PriceSeries(IPC,bar-29,open,low,high,close)
           +0.010166090979082400*PriceSeries(IPC,bar-30,open,low,high,close)
           +0.004303104789688430*PriceSeries(IPC,bar-31,open,low,high,close)
           -0.003659787203963280*PriceSeries(IPC,bar-32,open,low,high,close)
           -0.008411956859246820*PriceSeries(IPC,bar-33,open,low,high,close)
           -0.007282846005800100*PriceSeries(IPC,bar-34,open,low,high,close)
           -0.001620704470705190*PriceSeries(IPC,bar-35,open,low,high,close)
           +0.004466014467332310*PriceSeries(IPC,bar-36,open,low,high,close)
           +0.007048985722291220*PriceSeries(IPC,bar-37,open,low,high,close)
           +0.004847799927165300*PriceSeries(IPC,bar-38,open,low,high,close)
           -0.000217319809293247*PriceSeries(IPC,bar-39,open,low,high,close)
           -0.004603538852047050*PriceSeries(IPC,bar-40,open,low,high,close)
           -0.005574817063020290*PriceSeries(IPC,bar-41,open,low,high,close)
           -0.002877047191674200*PriceSeries(IPC,bar-42,open,low,high,close)
           +0.001371504969476030*PriceSeries(IPC,bar-43,open,low,high,close)
           +0.004280506570424680*PriceSeries(IPC,bar-44,open,low,high,close)
           +0.004136269885199370*PriceSeries(IPC,bar-45,open,low,high,close)
           +0.001361513374633290*PriceSeries(IPC,bar-46,open,low,high,close)
           -0.001973820228459360*PriceSeries(IPC,bar-47,open,low,high,close)
           -0.003675699277522370*PriceSeries(IPC,bar-48,open,low,high,close)
           -0.002836788589562860*PriceSeries(IPC,bar-49,open,low,high,close)
           -0.000284631689719810*PriceSeries(IPC,bar-50,open,low,high,close)
           +0.002153387731732640*PriceSeries(IPC,bar-51,open,low,high,close)
           +0.002934855205103340*PriceSeries(IPC,bar-52,open,low,high,close)
           +0.001758962821343280*PriceSeries(IPC,bar-53,open,low,high,close)
           -0.000389897847025107*PriceSeries(IPC,bar-54,open,low,high,close)
           -0.002031006983868290*PriceSeries(IPC,bar-55,open,low,high,close)
           -0.002197277408694140*PriceSeries(IPC,bar-56,open,low,high,close)
           -0.000975033303736501*PriceSeries(IPC,bar-57,open,low,high,close)
           +0.000693883112457725*PriceSeries(IPC,bar-58,open,low,high,close)
           +0.001751056105124850*PriceSeries(IPC,bar-59,open,low,high,close)
           +0.001683817123497210*PriceSeries(IPC,bar-60,open,low,high,close)
           +0.000645916394658871*PriceSeries(IPC,bar-61,open,low,high,close)
           -0.001229513645906610*PriceSeries(IPC,bar-62,open,low,high,close)
           -0.005497165615453070*PriceSeries(IPC,bar-63,open,low,high,close)
           +0.001719892732445040*PriceSeries(IPC,bar-64,open,low,high,close);
      Res2=
           +0.210642090317950000*PriceSeries(IPC,bar-00,open,low,high,close)
           +0.271656355551084000*PriceSeries(IPC,bar-01,open,low,high,close)
           +0.271656355551084000*PriceSeries(IPC,bar-02,open,low,high,close)
           +0.210642090317950000*PriceSeries(IPC,bar-03,open,low,high,close)
           +0.113366214899538000*PriceSeries(IPC,bar-04,open,low,high,close)
           +0.017339655129830400*PriceSeries(IPC,bar-05,open,low,high,close)
           -0.044811701929405100*PriceSeries(IPC,bar-06,open,low,high,close)
           -0.059474537088348700*PriceSeries(IPC,bar-07,open,low,high,close)
           -0.035754954878029800*PriceSeries(IPC,bar-08,open,low,high,close)
           +0.002270804329963180*PriceSeries(IPC,bar-09,open,low,high,close)
           +0.029697524121816400*PriceSeries(IPC,bar-10,open,low,high,close)
           +0.033281042507046500*PriceSeries(IPC,bar-11,open,low,high,close)
           +0.015981183265287400*PriceSeries(IPC,bar-12,open,low,high,close)
           -0.007862943901791450*PriceSeries(IPC,bar-13,open,low,high,close)
           -0.022723234810281000*PriceSeries(IPC,bar-14,open,low,high,close)
           -0.021095992789986800*PriceSeries(IPC,bar-15,open,low,high,close)
           -0.006603314272564040*PriceSeries(IPC,bar-16,open,low,high,close)
           +0.009881836012723110*PriceSeries(IPC,bar-17,open,low,high,close)
           +0.017854024794657900*PriceSeries(IPC,bar-18,open,low,high,close)
           +0.013524194354160800*PriceSeries(IPC,bar-19,open,low,high,close)
           +0.001241377137939080*PriceSeries(IPC,bar-20,open,low,high,close)
           -0.010266977018020800*PriceSeries(IPC,bar-21,open,low,high,close)
           -0.013862391185810200*PriceSeries(IPC,bar-22,open,low,high,close)
           -0.008248135223019260*PriceSeries(IPC,bar-23,open,low,high,close)
           +0.001954191195740410*PriceSeries(IPC,bar-24,open,low,high,close)
           +0.009730937704226890*PriceSeries(IPC,bar-25,open,low,high,close)
           +0.010434675351580300*PriceSeries(IPC,bar-26,open,low,high,close)
           +0.004416791230436310*PriceSeries(IPC,bar-27,open,low,high,close)
           -0.003756477431473020*PriceSeries(IPC,bar-28,open,low,high,close)
           -0.008634197655553740*PriceSeries(IPC,bar-29,open,low,high,close)
           -0.007475256109987750*PriceSeries(IPC,bar-30,open,low,high,close)
           -0.001663522884800100*PriceSeries(IPC,bar-31,open,low,high,close)
           +0.004584004921651760*PriceSeries(IPC,bar-32,open,low,high,close)
           +0.007235217324080300*PriceSeries(IPC,bar-33,open,low,high,close)
           +0.004975877012459140*PriceSeries(IPC,bar-34,open,low,high,close)
           -0.000223061318466289*PriceSeries(IPC,bar-35,open,low,high,close)
           -0.004725162649865770*PriceSeries(IPC,bar-36,open,low,high,close)
           -0.005722101672782540*PriceSeries(IPC,bar-37,open,low,high,close)
           -0.002953057716881230*PriceSeries(IPC,bar-38,open,low,high,close)
           +0.001407739624700190*PriceSeries(IPC,bar-39,open,low,high,close)
           +0.004393595974558090*PriceSeries(IPC,bar-40,open,low,high,close)
           +0.004245548609330800*PriceSeries(IPC,bar-41,open,low,high,close)
           +0.001397484055608480*PriceSeries(IPC,bar-42,open,low,high,close)
           -0.002025967830578520*PriceSeries(IPC,bar-43,open,low,high,close)
           -0.003772809896144160*PriceSeries(IPC,bar-44,open,low,high,close)
           -0.002911735497357070*PriceSeries(IPC,bar-45,open,low,high,close)
           -0.000292151553936419*PriceSeries(IPC,bar-46,open,low,high,close)
           +0.002210279441029960*PriceSeries(IPC,bar-47,open,low,high,close)
           +0.003012392996694690*PriceSeries(IPC,bar-48,open,low,high,close)
           +0.001805433970046320*PriceSeries(IPC,bar-49,open,low,high,close)
           -0.000400198804275733*PriceSeries(IPC,bar-50,open,low,high,close)
           -0.002084665438964100*PriceSeries(IPC,bar-51,open,low,high,close)
           -0.002255328667062000*PriceSeries(IPC,bar-52,open,low,high,close)
           -0.001000793323845250*PriceSeries(IPC,bar-53,open,low,high,close)
           +0.000712215248254048*PriceSeries(IPC,bar-54,open,low,high,close)
           +0.001797318361302890*PriceSeries(IPC,bar-55,open,low,high,close)
           +0.001728302950591050*PriceSeries(IPC,bar-56,open,low,high,close)
           +0.000662981267470111*PriceSeries(IPC,bar-57,open,low,high,close)
           -0.001261996942755200*PriceSeries(IPC,bar-58,open,low,high,close)
           -0.005642398702623070*PriceSeries(IPC,bar-59,open,low,high,close)
           +0.001765331663815800*PriceSeries(IPC,bar-60,open,low,high,close);
      //----       
      InBuffer[bar]=Res2-Res1;
     }

//---- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_total; // стартовый номер для расчёта всех баров

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total; bar++)
     {
      clr=1;
      if(InBuffer[bar-1]<InBuffer[bar]) clr=2;
      if(InBuffer[bar-1]>InBuffer[bar]) clr=0;
      ColorInBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries
(
 uint applied_price,// Ценовая константа
 uint   bar,// Индекс сдвига относительно текущего бара на указанное количество периодов назад или вперёд).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----         
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];

         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
