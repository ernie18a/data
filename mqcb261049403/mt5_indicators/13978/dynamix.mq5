//+------------------------------------------------------------------+
//|                                                      dynamix.mq5 | 
//|                                Copyright © 2014, Serkov Alexandr | 
//|                                          serkov-alexandr@mail.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Serkov Alexandr"
#property link "serkov-alexandr@mail.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define LINES_TOTAL         27 // константа для количества линий индикатора
#define RESET                0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
#property description "dynamix",LINES_TOTAL
//---- количество индикаторных буферов
#property indicator_buffers LINES_TOTAL 
//---- использовано всего графических построений
#property indicator_plots   LINES_TOTAL
//+-----------------------------------+
//| Параметры отрисовки индикаторов   |
//+-----------------------------------+
//---- отрисовка осцилляторов в виде линий
#property indicator_type1   DRAW_LINE
//---- линии - штрихпунктирные кривые
#property indicator_style1 STYLE_SOLID
//---- толщина линий 1
#property indicator_width1  1
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //тип константы
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
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint step=10; // Шаг построения скользящих средних, оптимальный диапазон значений - от 1 до 10
input Applied_price_ IPC=PRICE_CLOSE; // Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input int ColorWidth=40; // Ширина цветовой палитры (изменяется от 0 до 131)
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//----
double ma[LINES_TOTAL],ma_[LINES_TOTAL];
double mb[LINES_TOTAL][100],mb_[LINES_TOTAL][100];
int ind[LINES_TOTAL]={1,2,3,4,5,6,8,10,12,14,16,18,20,22,24,27,30,33,36,39,42,45,48,51,54,57,60};
//+------------------------------------------------------------------+
//| Массивы переменных для создания индикаторных буферов             |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(61*step);
//----
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
     };
//----
   int size=ArraySize(ArrayColors);
   size-=2;
   int ColorWidth_=ColorWidth;
   if(ColorWidth>size) ColorWidth_=size;
   if(ColorWidth<1) ColorWidth_=1;
//----
   color Colors[];
//----
   if(ArrayResize(Colors,ColorWidth_)<ColorWidth_) Print("Не удалось распределить память под массив Colors");
   ArrayCopy(Colors,ArrayColors,0,2,ColorWidth_);
//---- индексация элементов в массиве как в таймсерии   
   ArraySetAsSeries(Colors,true);
//----
   double K=double(ColorWidth_/(LINES_TOTAL*1.0));
//----
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      string shortname="";
      StringConcatenate(shortname,"dynamix",numb);
      //--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- установка значений индикатора, которые не будут видимы на графике
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- осуществление сдвига начала отсчета отрисовки индикатора
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
   StringConcatenate(shortname,"dynamix",LINES_TOTAL,"(",step,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int bar,limit,maxbar;
//----
   maxbar=rates_total-1;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- вызов функции PriceSeries для получения входной цены price
      for(int x=0; x<LINES_TOTAL; x++) for(int y=99; y>0; y--) mb[x][y]=mb_[x][y-1];
      //----
      for(int x=0; x<LINES_TOTAL; x++)
        {
         ma[x]=ma_[x]-PriceSeries(IPC,bar+int(step*ind[x]),open,low,high,close)+PriceSeries(IPC,bar,open,low,high,close);
         mb[x][0]=ma[x]/(step*ind[x]);
        }
      //----
      for(int numb=0; numb<LINES_TOTAL; numb++)
         Ind[numb].IndBuffer[bar]=((mb[numb][0]-mb[numb][11])+(mb[numb][0]-mb[numb][22])
                                   +(mb[numb][0]-mb[numb][33])+(mb[numb][0]-mb[numb][44])+(mb[numb][0]-mb[numb][55])
                                   +(mb[numb][0]-mb[numb][66])+(mb[numb][0]-mb[numb][77])+(mb[numb][0]-mb[numb][88])
                                   +(mb[numb][0]-mb[numb][99]))/9;
      //----
      if(bar) for(int x=0; x<LINES_TOTAL; x++)
        {
         ma_[x]=ma[x];
         for(int y=99; y>0; y--) mb_[x][y]=mb[x][y];
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,// ценовая константа
                   uint   bar, // индекс сдвига относительно текущего бара на указанное количество периодов назад или вперед
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- ценовые константы из перечисления ENUM_APPLIED_PRICE
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
