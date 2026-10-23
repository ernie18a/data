//+------------------------------------------------------------------+ 
//|                   Hans_Indicator_x62_Cloud_System_Tail_Alert.mq5 | 
//|                                       Copyright © 2014, Shimodax | 
//|   http://www.strategybuilderfx.com/forums/showthread.php?t=15439 | 
//+------------------------------------------------------------------+ 
/* Introduction:

   Draw ranges for "Simple Combined Breakout System for EUR/USD and GBP/USD" thread
   (see http://www.strategybuilderfx.com/forums/showthread.php?t=15439)

   LocalTimeZone: TimeZone for which MT5 shows your local time, 
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight 
                  savings time).  Use zero for no adjustment.
                  
                  The MetaQuotes demo server uses GMT +2.   
   Enjoy  :-)
   
   Markus

*/
#property copyright "Copyright © 2014, Shimodax"
#property link "http://www.strategybuilderfx.com/forums/showthread.php?t=15439"
#property description "Индикатор расширяющихся коридоров временных зон с тридцатью одним коридором,  с фоновым цветовым заполнением, средней линией коридора,"
#property description "с окрашиванием свечек при выходе из сформированного четырёхчасового коридора."
#property description "Сформированный коридор равен четырём часам, расширения коридора - шестнадцать часов."
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window  
//---- количество индикаторных буферов 74
#property indicator_buffers 74
//---- использовано шестьдесят восемь графических построений
#property indicator_plots   68
//+-----------------------------------------+
//|  объявление констант                    |
//+-----------------------------------------+
#define LINES_TOTAL         32    // Константа для количества пар линий индикатора для уровней 
#define RESET               NULL  // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------------+
//| Параметры отрисовки верхнего облака     |
//+-----------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'202,255,237'
#property indicator_color1 C'202,255,237'
//---- отображение метки индикатора
#property indicator_label1  "Upper Hans_Indicator_x62 cloud"
//+-----------------------------------------+
//| Параметры отрисовки нижнего облака      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'255,225,255'
#property indicator_color2 C'255,225,255'
//---- отображение метки индикатора
#property indicator_label2  "Lower Hans_Indicator_x62 cloud"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 3       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color3 clrBlue
//---- линия индикатора - сплошная
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Upper Hans_Indicator 1"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 4       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован Magenta цвет
#property indicator_color4 clrMagenta
//---- линия индикатора - сплошная
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "Lower Hans_Indicator 1"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 5       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован Lime цвет
#property indicator_color5 clrLime
//---- линия индикатора - сплошная
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width5 3
//---- отображение метки индикатора
#property indicator_label5  "Upper Hans_Indicator 2"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 6       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type6   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color6 clrRed
//---- линия индикатора - сплошная
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width6  3
//---- отображение метки индикатора
#property indicator_label6  "Lower Hans_Indicator 2"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 7       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type7   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color7 clrGreen
//---- линия индикатора - сплошная
#property indicator_style7  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width7 3
//---- отображение метки индикатора
#property indicator_label7  "Upper Hans_Indicator 3"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 8       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type8   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color8 clrIndigo
//---- линия индикатора - сплошная
#property indicator_style8  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width8  3
//---- отображение метки индикатора
#property indicator_label8  "Lower Hans_Indicator 3"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 9       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type9   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color9 clrGreen
//---- линия индикатора - пунктир
#property indicator_style9  STYLE_DASH
//---- толщина линии индикатора равна 1
#property indicator_width9 1
//---- отображение метки индикатора
#property indicator_label9  "Upper Hans_Indicator 4"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 10      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type10   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color10 clrIndigo
//---- линия индикатора - пунктир
#property indicator_style10  STYLE_DASH
//---- толщина линии индикатора равна 1
#property indicator_width10  1
//---- отображение метки индикатора
#property indicator_label10  "Lower Hans_Indicator 4"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 11      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type11   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color11 clrGreen
//---- линия индикатора - штрих-пунктир
#property indicator_style11  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width11 1
//---- отображение метки индикатора
#property indicator_label11  "Upper Hans_Indicator 5"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 12      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type12   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color12 clrIndigo
//---- линия индикатора - штрих-пунктир
#property indicator_style12  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width12  1
//---- отображение метки индикатора
#property indicator_label12  "Lower Hans_Indicator 5"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 13      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type13   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color13 clrGreen
//---- линия индикатора - сплошная
#property indicator_style13  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width13  1
//---- отображение метки индикатора
#property indicator_label13  "Upper Hans_Indicator 6"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 14      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type14   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color14 clrIndigo
//---- линия индикатора - сплошная
#property indicator_style14  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width14  1
//---- отображение метки индикатора
#property indicator_label14  "Lower Hans_Indicator 6"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 67      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type67   DRAW_LINE
//---- в качестве цвета линии индикатора использован SlateGray цвет
#property indicator_color67 clrSlateGray
//---- линия индикатора - сплошная
#property indicator_style67  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width67 2
//---- отображение метки индикатора
#property indicator_label67  "Middle Hans_Indicator"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора свеч    |
//+-----------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type68   DRAW_COLOR_CANDLES
#property indicator_color68   clrDeepSkyBlue,clrBlue,clrGray,clrPurple,clrMagenta
//---- отображение метки индикатора
#property indicator_label68  "Hans_Indicator Open;Hans_Indicator High;Hans_Indicator Low;Hans_Indicator Close"
//+-----------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА           |
//+-----------------------------------------+
input uint LocalTimeZone=0;         // час начала отсчёта исходного коридора
input uint DestTimeZone=4;          // сдвиг коридора влево в барах
input uint PipsForEntryStep=50;     // шаг расширения границ каждого сформированного коридора в пунктах
input int  Shift=0;                 // Сдвиг индикатора по горизонтали в барах
input bool Draw_Tail=true;          // Разрешение дорисовки уровней до конца ссесии
input uint NumberofBar=1;       // Номер бара для подачи сигнала
input bool SoundON=true;        // Разрешение алерта
input uint NumberofAlerts=2;    // Количество алертов
input bool EMailON=false;       // Разрешение почтовой отправки сигнала
input bool PushON=false;        // Разрешение отправки сигнала на мобильный
input uint  Slip=0;             // Смещение координатной сетки по вертикали на PipsForEntryStep от середины 
//+-----------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[],MiddleBuffer[];
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных буферов            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    ZoneUpper[];
public: double    ZoneLower[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=100;
//---- объявление массивов для стилей индикаторных линий
   ENUM_LINE_STYLE line_style[];
   color line_color[];
   int line_width[];
   ENUM_DRAW_TYPE plot_type[];
//---- Распределение памяти под массивы переменных
   int size=10;
   ArrayResize(line_style,size);
   ArrayResize(line_color,size);
   ArrayResize(line_width,size);
   ArrayResize(plot_type,size);
   ArrayResize(Ind,LINES_TOTAL);
//---- получение свойств индикаторных линий
   for(int plot=4; plot<14; plot++)
     {
      plot_type[plot-4]=ENUM_DRAW_TYPE(PlotIndexGetInteger(plot,PLOT_DRAW_TYPE));
      line_style[plot-4]=ENUM_LINE_STYLE(PlotIndexGetInteger(plot,PLOT_LINE_STYLE));
      line_width[plot-4]=PlotIndexGetInteger(plot,PLOT_LINE_WIDTH);
      line_color[plot-4]=color(PlotIndexGetInteger(plot,PLOT_LINE_COLOR));
     }

//---- инициализация свойств индикаторных линий   
   for(int step=0; step<5; step++) for(int count=0; count<10; count++)
     {
      int number=14+10*step+count;
      PlotIndexSetInteger(number,PLOT_DRAW_TYPE,plot_type[count]);
      PlotIndexSetInteger(number,PLOT_LINE_STYLE,line_style[count]);
      PlotIndexSetInteger(number,PLOT_LINE_WIDTH,line_width[count]);
      PlotIndexSetInteger(number,PLOT_LINE_COLOR,line_color[count]);
     }
   for(int count=0; count<2; count++)
     {
      int number=64+count;
      PlotIndexSetInteger(number,PLOT_DRAW_TYPE,plot_type[count]);
      PlotIndexSetInteger(number,PLOT_LINE_STYLE,line_style[count]);
      PlotIndexSetInteger(number,PLOT_LINE_WIDTH,line_width[count]);
      PlotIndexSetInteger(number,PLOT_LINE_COLOR,line_color[count]);
     }
   for(int count=0; count<LINES_TOTAL-6; count++)
     {
      PlotIndexSetString(14+2*count,PLOT_LABEL,"Upper Hans_Indicator "+string(7+count));
      PlotIndexSetString(15+2*count,PLOT_LABEL,"Lower Hans_Indicator "+string(7+count));
     }
//---- Инициализация индикаторных буферов 
   IndBufferInit(0,UpUpBuffer);
   IndBufferInit(1,UpDnBuffer);
//----
   IndBufferInit(2,DnUpBuffer);
   IndBufferInit(3,DnDnBuffer);
//----
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      IndBufferInit(4+2*numb,Ind[numb].ZoneUpper);
      IndBufferInit(5+2*numb,Ind[numb].ZoneLower);
     }
//----
   IndBufferInit(4+2*LINES_TOTAL,MiddleBuffer);
//----
   IndBufferInit(5+2*(LINES_TOTAL),ExtOpenBuffer);
   IndBufferInit(6+2*(LINES_TOTAL),ExtHighBuffer);
   IndBufferInit(7+2*(LINES_TOTAL),ExtLowBuffer);
   IndBufferInit(8+2*(LINES_TOTAL),ExtCloseBuffer);
   IndBufferInit(9+2*(LINES_TOTAL),ExtColorBuffer);

//---- Инициализация индикаторов  
//for(int count=0; count<2; count++) IndCldInit(count,min_rates_total,Shift);
   for(int count=0; count<2; count++) IndInit(count,EMPTY_VALUE,min_rates_total,Shift);
   for(int count=2; count<2*LINES_TOTAL+6; count++) IndInit(count,NULL,min_rates_total,Shift);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Hans_Indicator_x62_Cloud_System_Tail_Alert("+
                      string(LocalTimeZone)+","+string(DestTimeZone)+","+string(PipsForEntryStep)+","+string(Shift)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndBufferInit(int BuffNumber,double &Buffer[])
  {
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(BuffNumber,Buffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(Buffer,true);
//----
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void IndCldInit(int PlotNumber,int Draw_Begin,int nShift)
  {
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,Draw_Begin);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,nShift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_SHOW_DATA,false);
//----
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void IndInit(int PlotNumber,double Empty_Value,int Draw_Begin,int nShift)
  {
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(PlotNumber,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,nShift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_SHOW_DATA,false);
//----
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных
   int limit,limit1;

//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=limit1=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else limit=limit1=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

//---- основной цикл расчёта индикатора
   BreakoutRanges(0,limit,LocalTimeZone,DestTimeZone,rates_total,Time,Open,High,Low,Close);

   if(Draw_Tail)
     {
      int last_tail=FindLastTail(rates_total,Open,High,Low,Close,limit1);
      if(last_tail>0) limit1=last_tail;
      //---- цикл дорисовки уровней и окраски свечек до конца ссесии
      for(int bar=limit1; bar>=0 && !IsStopped(); bar--)
        {
         if(!Ind[0].ZoneUpper[bar])
           {
            for(int numb=1; numb<LINES_TOTAL; numb++)
              {
               Ind[numb].ZoneUpper[bar]=Ind[numb].ZoneUpper[bar+1];
               Ind[numb].ZoneLower[bar]=Ind[numb].ZoneLower[bar+1];
              }
            MiddleBuffer[bar]=MiddleBuffer[bar+1];
            ExtOpenBuffer[bar]=ExtHighBuffer[bar]=ExtLowBuffer[bar]=ExtCloseBuffer[bar]=NULL;
            ExtColorBuffer[bar]=2;
            if(Close[bar]>Ind[1].ZoneUpper[bar])
              {
               ExtOpenBuffer[bar]=Open[bar];
               ExtHighBuffer[bar]=High[bar];
               ExtLowBuffer[bar]=Low[bar];
               ExtCloseBuffer[bar]=Close[bar];
               if(Close[bar]>=Open[bar]) ExtColorBuffer[bar]=0;
               else ExtColorBuffer[bar]=1;
              }
            if(Close[bar]<Ind[1].ZoneLower[bar])
              {
               ExtOpenBuffer[bar]=Open[bar];
               ExtHighBuffer[bar]=High[bar];
               ExtLowBuffer[bar]=Low[bar];
               ExtCloseBuffer[bar]=Close[bar];
               if(Close[bar]<=Open[bar]) ExtColorBuffer[bar]=4;
               else ExtColorBuffer[bar]=3;
              }
           }
         if(Ind[0].ZoneUpper[bar]) if(!Ind[0].ZoneUpper[bar+1])
           {
            MiddleBuffer[bar+1]=NULL;
            for(int numb=1; numb<LINES_TOTAL; numb++) Ind[numb].ZoneUpper[bar]=Ind[numb].ZoneLower[bar]=NULL;
           }
        }
     }
//---     
   BuySignal("Hans_Indicator_x62_Cloud_System_Tail_Alert",ExtColorBuffer,rates_total,prev_calculated,Close,Spread);
   SellSignal("Hans_Indicator_x62_Cloud_System_Tail_Alert",ExtColorBuffer,rates_total,prev_calculated,Close,Spread);
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| поиск последнего конца уровней                                   |
//+------------------------------------------------------------------+    
int FindLastTail(const int Rates_Total,const double &Open_[],const double &High_[],const double &Low_[],const double &Close_[],int nShift)
  {
//---- 
   for(int bar=nShift; bar<Rates_Total && !IsStopped(); bar++)
     {
      if(!Ind[0].ZoneUpper[bar]) for(int index=bar; index<Rates_Total && !IsStopped(); index++) if(Ind[0].ZoneUpper[index]) return(index);
     }
//----
   return(-1);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
               double &ColorArrow[],      // цветовой индикаторный  буфер с сигналами для покупки
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool BuySignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorArrow);
   int index,index1;
   if(SeriesTest)
     {
      index=int(NumberofBar);
      index1=index+1;
     }
   else
     {
      index=Rates_total-int(NumberofBar)-1;
      index1=index-1;
     }
   if(ColorArrow[index]<2 && ColorArrow[index1]>1) BuySignal=true;
   if(BuySignal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      SeriesTest=ArrayGetAsSeries(Close);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      double Ask=Close[index];
      double Bid=Close[index];
      SeriesTest=ArrayGetAsSeries(Spread);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SoundON) Alert("BUY signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail(SignalSirname+": BUY signal alert","BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification(SignalSirname+": BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
     }

//---
  }
//+------------------------------------------------------------------+
//| Sell signal function                                             |
//+------------------------------------------------------------------+
void SellSignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
                double &ColorArrow[],      // цветовой индикаторный  буфер с сигналами для продажи
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=false;
   bool SeriesTest=ArrayGetAsSeries(ColorArrow);
   int index,index1;
   if(SeriesTest)
     {
      index=int(NumberofBar);
      index1=index+1;
     }
   else
     {
      index=Rates_total-int(NumberofBar)-1;
      index1=index-1;
     }
   if(ColorArrow[index]>2 && ColorArrow[index1]<3) SellSignal=true;
   if(SellSignal && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      string text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      SeriesTest=ArrayGetAsSeries(Close);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      double Ask=Close[index];
      double Bid=Close[index];
      SeriesTest=ArrayGetAsSeries(Spread);
      if(SeriesTest) index=int(NumberofBar);
      else index=Rates_total-int(NumberofBar)-1;
      Bid+=Spread[index]*_Point;
      string sAsk=DoubleToString(Ask,_Digits);
      string sBid=DoubleToString(Bid,_Digits);
      string sPeriod=GetStringTimeframe(ChartPeriod());
      if(SoundON) Alert("SELL signal \n Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail(SignalSirname+": SELL signal alert","SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification(SignalSirname+": SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
     }
//---
  }
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//| Compute index of first/last bar of yesterday and today           |
//+------------------------------------------------------------------+
int BreakoutRanges(int offset,int &lastbar,int tzlocal,int tzdest,const int rates_total_,const datetime &Time_[],
                   const double &Open_[],const double &High_[],const double &Low_[],const double &Close_[])
  {
//----
   int i,j,k,
   tzdiff=tzlocal-tzdest,
   tzdiffsec=tzdiff*3600,
   tidxstart[2]={ 0,0},
   tidxend[2]={ 0,0 };
   double thigh[2]={ 0.0,0.0 },
   tlow[2]={ DBL_MAX };
   string tfrom[3]={ "04:00","08:00",/*rest of day: */ "12:00"},
   tto[3]={ "08:00","12:00",/*rest of day: */ "24:00" },
   tday;
   bool inperiod=-1;
   datetime timet;

//
// search back for the beginning of the day
//
   tday=TimeToString(Time_[lastbar]-tzdiffsec,TIME_DATE);
   for(; lastbar<rates_total_-1; lastbar++)
     {
      if(TimeToString(Time_[lastbar]-tzdiffsec,TIME_DATE)!=tday)
        {
         lastbar--;
         break;
        }
     }

//
// find the high/low for the two periods and carry them forward through the day
//
   tday="XXX";
   for(i=lastbar; i>=offset; i--)
     {

      timet=Time_[i]-tzdiffsec;   // time of this bar

      string timestr=TimeToString(timet,TIME_MINUTES),// current time HH:MM
      thisday=TimeToString(timet,TIME_DATE);       // current date

                                                   //
      // for all three periods (first period, second period, rest of day)
      //
      for(j=0; j<2; j++)
        {
         if(tfrom[j]<=timestr && timestr<tto[j])
           {   // Bar[i] in this period
            if(inperiod!=j)
              { // entered new period, so last one is completed

               if(j>0)
                 {      // now draw high/low back over the recently completed period
                  for(k=tidxstart[j-1]; k>=tidxend[j-1]; k--)
                    {
                     ExtOpenBuffer[k]=ExtHighBuffer[k]=ExtLowBuffer[k]=ExtCloseBuffer[k]=NULL;
                     ExtColorBuffer[k]=2;
                     if(j-1==0)
                       {
                        Ind[0].ZoneUpper[k]= thigh[j-1];
                        Ind[0].ZoneLower[k]= tlow[j-1];
                        MiddleBuffer[k]=(Ind[0].ZoneUpper[k]+Ind[0].ZoneLower[k])/2;

                        if(Close_[k]>Ind[0].ZoneUpper[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]>=Open_[k]) ExtColorBuffer[k]=0;
                           else ExtColorBuffer[k]=1;
                          }
                        if(Close_[k]<Ind[0].ZoneLower[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]<=Open_[k]) ExtColorBuffer[k]=4;
                           else ExtColorBuffer[k]=3;
                          }
                       }

                     if(j-1==1)
                       {
                        Ind[1].ZoneUpper[k]= thigh[j-1];
                        Ind[1].ZoneLower[k]= tlow[j-1];
                        MiddleBuffer[k]=(Ind[1].ZoneUpper[k]+Ind[1].ZoneLower[k])/2;
                        if(Close_[k]>Ind[1].ZoneUpper[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]>=Open_[k]) ExtColorBuffer[k]=0;
                           else ExtColorBuffer[k]=1;
                          }
                        if(Close_[k]<Ind[1].ZoneLower[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]<=Open_[k]) ExtColorBuffer[k]=4;
                           else ExtColorBuffer[k]=3;
                          }
                       }
                    }
                 }

               inperiod=j;   // remember current period
              }

            if(inperiod==2) // inperiod==2 (end of day) is just to check completion of zone 2
               break;

            // for the current period find idxstart, idxend and compute high/low
            if(tidxstart[j]==0)
              {
               tidxstart[j]=i;
               tday=thisday;
              }

            tidxend[j]=i;

            thigh[j]=MathMax(thigh[j],High_[i]);
            tlow[j]=MathMin(tlow[j],Low_[i]);
           }
        }

      // 
      // carry forward the periods for which we have definite high/lows
      //
      if(inperiod>=1 && tday==thisday)
        { // first time period completed

         for(int numb=1; numb<LINES_TOTAL; numb++)
           {
            Ind[numb].ZoneUpper[i]=thigh[0]+numb*PipsForEntryStep*_Point;
            Ind[numb].ZoneLower[i]=tlow[0]-numb*PipsForEntryStep*_Point;
           }

         Ind[0].ZoneUpper[i]=Ind[1].ZoneUpper[i];
         Ind[0].ZoneLower[i]=Ind[1].ZoneLower[i];

         for(int numb=1; numb<LINES_TOTAL; numb++)
           {
            Ind[numb].ZoneUpper[i]+=Slip*PipsForEntryStep*_Point;
            Ind[numb].ZoneLower[i]-=Slip*PipsForEntryStep*_Point;
           }

         MiddleBuffer[i]=UpDnBuffer[i]=DnUpBuffer[i]=(Ind[0].ZoneUpper[i]+Ind[0].ZoneLower[i])/2;
         UpUpBuffer[i]=Ind[LINES_TOTAL-1].ZoneUpper[i];
         DnDnBuffer[i]=Ind[LINES_TOTAL-1].ZoneLower[i];
         ExtOpenBuffer[i]=ExtHighBuffer[i]=ExtLowBuffer[i]=ExtCloseBuffer[i]=NULL;
         ExtColorBuffer[i]=2;
         if(Close_[i]>Ind[0].ZoneUpper[i])
           {
            ExtOpenBuffer[i]=Open_[i];
            ExtHighBuffer[i]=High_[i];
            ExtLowBuffer[i]=Low_[i];
            ExtCloseBuffer[i]=Close_[i];
            if(Close_[i]>=Open_[i]) ExtColorBuffer[i]=0;
            else ExtColorBuffer[i]=1;
           }
         if(Close_[i]<Ind[0].ZoneLower[i])
           {
            ExtOpenBuffer[i]=Open_[i];
            ExtHighBuffer[i]=High_[i];
            ExtLowBuffer[i]=Low_[i];
            ExtCloseBuffer[i]=Close_[i];
            if(Close_[i]<=Open_[i]) ExtColorBuffer[i]=4;
            else ExtColorBuffer[i]=3;
           }
        }
      else
        {   // none yet to carry forward (zero to clear old values, e.g. from switching timeframe)         
         Ind[0].ZoneUpper[i]=NULL;
         Ind[0].ZoneLower[i]=NULL;
         for(int numb=0; numb<LINES_TOTAL; numb++)
           {
            Ind[numb].ZoneUpper[i]=NULL;
            Ind[numb].ZoneLower[i]=NULL;
           }
         MiddleBuffer[i]=UpDnBuffer[i]=DnUpBuffer[i]=UpUpBuffer[i]=DnDnBuffer[i]=NULL;
         ExtOpenBuffer[i]=ExtHighBuffer[i]=ExtLowBuffer[i]=ExtCloseBuffer[i]=NULL;
         ExtColorBuffer[i]=2;
        }

      //
      // at the beginning of a new day reset everything
      //
      if(tday!="XXX" && tday!=thisday)
        {
         //Print("#",i,"new day ",thisday,"/",tday);

         tday="XXX";

         inperiod=-1;

         for(j=0; j<2; j++)
           {
            tidxstart[j]=0;
            tidxend[j]=0;

            thigh[j]=0;
            tlow[j]=99999;
           }
        }
     }
//----
   return (0);
  }
//+------------------------------------------------------------------+
