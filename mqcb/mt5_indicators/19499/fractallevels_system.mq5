//+------------------------------------------------------------------+
//|                                         FractalLevels_System.mq5 |
//|                                        Copyright © 2008, lotos4u |
//|                                                lotos4u@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, lotos4u"
#property link      "lotos4u@gmail.com"
#property description "Fractal Levels"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано тринадцать буферов
#property indicator_buffers 13
//---- использовано всего восемь графических построений
#property indicator_plots   8
//+--------------------------------------------+
//|  объявление констант                       |
//+--------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора облака       |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "FractalLevels Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение бычей метки индикатора
#property indicator_label2  "Фрактальное сопротивление"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован MediumOrchid цвет
#property indicator_color3  clrMediumOrchid
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Фрактальное поддержка"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве индикатора использован Lime цвет
#property indicator_color4  clrLime
//---- толщина индикатора 4 равна 2
#property indicator_width4  2
//---- отображение бычей метки индикатора
#property indicator_label4  "Фрактал ВЕРХ"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован Red цвет
#property indicator_color5  clrRed
//---- толщина индикатора 5 равна 2
#property indicator_width5  2
//---- отображение медвежьей метки индикатора
#property indicator_label5 "Фрактал ВНИЗ"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде символа
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета индикатора использован Blue цвет
#property indicator_color6  clrBlue
//---- толщина индикатора 6 равна 3
#property indicator_width6  3
//---- отображение бычей метки индикатора
#property indicator_label6  "Пробой ВВЕРХ"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 7 в виде символа
#property indicator_type7   DRAW_ARROW
//---- в качестве цвета индикатора использован Purple цвет
#property indicator_color7  clrPurple
//---- толщина  индикатора 7 равна 3
#property indicator_width7  3
//---- отображение медвежьей метки индикатора
#property indicator_label7 "Пробой ВНИЗ"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type8   DRAW_COLOR_CANDLES
#property indicator_color8  clrChartreuse,clrTeal,clrPurple,clrMagenta
//---- отображение метки индикатора
#property indicator_label8  "Zigzag2_R_channel_Candle"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint LeftBars_  = 3;
input uint RightBars_ = 3;
input uint NumberofBar=1;//Номер бара для подачи сигнала
input bool SoundON=true; //Разрешение алерта
input uint NumberofAlerts=2;//Количество алертов
input bool EMailON=false; //Разрешение почтовой отправки сигнала
input bool PushON=false; //Разрешение отправки сигнала на мобильный
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
double LineUpBuffer[],LineDownBuffer[];
double ArrowUpBuffer[],ArrowDownBuffer[];
double ArrowBreakUpBuffer[],ArrowBreakDownBuffer[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов для свеч
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
uint LeftBars,RightBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных
   LeftBars=LeftBars_;
   RightBars=RightBars_;
   if(LeftBars<2) LeftBars=2;
   if(RightBars<2) RightBars=2;
   min_rates_total=int(LeftBars+RightBars+1);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,LineUpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LineUpBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,LineDownBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LineDownBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,ArrowUpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,119);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ArrowUpBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,ArrowDownBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,119);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ArrowDownBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,ArrowBreakUpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 5
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(5,PLOT_ARROW,108);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ArrowBreakUpBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,ArrowBreakDownBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 6
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(6,PLOT_ARROW,108);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ArrowBreakDownBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(8,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(11,ExtCloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(12,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="Fractal Levels";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| поиск верхнего фрактала                                          |
//+------------------------------------------------------------------+
double isFractalUp(int index,int lBars,int rBars,const double &High[])
  {
//----   
   int start=index-rBars;
   int end=index+lBars+1;
   double max=High[index]; //Принимаем за максимум значение Хая исследуемого бара

   for(int i=start; i<end; i++)
      if(max<High[i] && i!=index)
        {
         if(max<High[i]) return(0);
         if(MathAbs(i-index)>1) return(0);
        }
//----
   return(max);
  }
//+------------------------------------------------------------------+
//| поиск нижнего фрактала                                           |
//+------------------------------------------------------------------+
double isFractalDown(int index,int lBars,int rBars,const double &Low[])
  {
//----   
   int start=index-rBars;
   int end=index+lBars+1;
   double min=Low[index]; //Принимаем за минимум значение Лоу исследуемого бара

   for(int i=start; i<end; i++)
      if(min>Low[i] && i!=index)
        {
         if(min>Low[i]) return(0);
         if(MathAbs(i-index)>1) return(0);
        }
//----
   return(min);
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

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated+min_rates_total; // стартовый номер для расчёта новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ArrowUpBuffer[bar]=NULL;
      ArrowDownBuffer[bar]=NULL;
      ArrowBreakUpBuffer[bar]=NULL;
      ArrowBreakDownBuffer[bar]=NULL;

      if(bar<int(RightBars))
        {
         LineUpBuffer[bar]=UpBuffer[bar]=LineUpBuffer[bar+1];
         LineDownBuffer[bar]=DnBuffer[bar]=LineDownBuffer[bar+1];
         continue;
        }

      UpBuffer[bar]=LineUpBuffer[bar]=isFractalUp(bar,LeftBars,RightBars,high);

      if(!LineUpBuffer[bar]) LineUpBuffer[bar]=UpBuffer[bar]=LineUpBuffer[bar+1];
      else ArrowUpBuffer[bar]=LineUpBuffer[bar];

      LineDownBuffer[bar]=DnBuffer[bar]=isFractalDown(bar,LeftBars,RightBars,low);

      if(!LineDownBuffer[bar]) LineDownBuffer[bar]=DnBuffer[bar]=LineDownBuffer[bar+1];
      else ArrowDownBuffer[bar]=LineDownBuffer[bar];

      if(close[bar]>LineUpBuffer[bar]   && close[bar+1]<=LineUpBuffer[bar+1]  ) ArrowBreakUpBuffer[bar]=close[bar];
      if(close[bar]<LineDownBuffer[bar] && close[bar+1]>=LineDownBuffer[bar+1]) ArrowBreakDownBuffer[bar]=close[bar];
     }
     
   int barHH,barLL,barHH1,barLL1;
   double HH,LL,HH1,LL1;

//---- Третий большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtOpenBuffer[bar]=NULL;
      ExtHighBuffer[bar]=NULL;
      ExtLowBuffer[bar]=NULL;
      ExtCloseBuffer[bar]=NULL;
      ExtColorBuffer[bar]=EMPTY_VALUE;
      //----
      barHH=FindFirstExtremum(bar,rates_total,ArrowBreakUpBuffer,HH);
      barHH1=FindFirstExtremum(barHH+1,rates_total,ArrowBreakUpBuffer,HH1);
      //----
      barLL=FindFirstExtremum(bar,rates_total,ArrowBreakDownBuffer,LL);
      barLL1=FindFirstExtremum(barLL+1,rates_total,ArrowBreakDownBuffer,LL1);
      //----
      if(barHH>=0 && barHH1>=0 && barLL>=0 && barLL1>=0)
        {
         for(int index=MathMax(barHH1-1,barLL1-1); index>=bar && !IsStopped(); index--)
           {
            ExtOpenBuffer[index]=NULL;
            ExtHighBuffer[index]=NULL;
            ExtLowBuffer[index]=NULL;
            ExtCloseBuffer[index]=NULL;
            ExtColorBuffer[index]=EMPTY_VALUE;
            //----
            if(close[index]-UpBuffer[index]>0.0)
              {
               ExtOpenBuffer[index]=open[index];
               ExtHighBuffer[index]=high[index];
               ExtLowBuffer[index]=low[index];
               ExtCloseBuffer[index]=close[index];
               if(close[index]-open[index]<0) ExtColorBuffer[index]=1.0;
               else ExtColorBuffer[index]=0.0;
              }
            //---- 
            if(DnBuffer[index]-close[index]>0.0)
              {
               ExtOpenBuffer[index]=open[index];
               ExtHighBuffer[index]=high[index];
               ExtLowBuffer[index]=low[index];
               ExtCloseBuffer[index]=close[index];
               ExtColorBuffer[index]=1.0;
               if(close[index]-open[index]>0) ExtColorBuffer[index]=2.0;
               else ExtColorBuffer[index]=3.0;
              }

           }

        }
     }
//---     
   string text="FractalLevels_System";

   if(ExtColorBuffer[NumberofBar]==0 || ExtColorBuffer[NumberofBar]==1)
     {
      if(ExtColorBuffer[NumberofBar+1]!=0 && ExtColorBuffer[NumberofBar+1]!=1) text=text+" Пробой канала! ";
      else text=text+" Продолжение тренда! ";
     }

   if(ExtColorBuffer[NumberofBar]==2 || ExtColorBuffer[NumberofBar]==3)
     {
      if(ExtColorBuffer[NumberofBar]!=2 && ExtColorBuffer[NumberofBar+1]!=3) text=text+" Пробой канала! ";
      else text=text+" Продолжение тренда! ";
     }

   BuySignal(text,ExtColorBuffer,rates_total,prev_calculated,close,spread);
   SellSignal(text,ExtColorBuffer,rates_total,prev_calculated,close,spread);
//---         
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Поиск самой первой вершины Зигзага в буферах таймсериях          |
//+------------------------------------------------------------------+     
int FindFirstExtremum(int StartPos,int Rates_total,double &Array[],double &Extremum)
  {
//----
   for(int bar=StartPos; bar<Rates_total; bar++)
     {
      if(Array[bar] && Array[bar]!=EMPTY_VALUE)
        {
         Extremum=Array[bar];
         return(bar);
         break;
        }
     }
//----
   Extremum=NULL;
   return(-1);
  }
//+------------------------------------------------------------------+
//| Buy signal function                                              |
//+------------------------------------------------------------------+
void BuySignal(string SignalSirname,      // текст имени индикатора для почтовых и пуш-сигналов
               double &BuyArrow[],        // индикаторный буфер с сигналами для покупки
               const int Rates_total,     // текущее количество баров
               const int Prev_calculated, // количество баров на предыдущем тике
               const double &Close[],     // цена закрытия
               const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool BuySignal=false;
   bool SeriesTest=ArrayGetAsSeries(BuyArrow);
   int index;
   if(SeriesTest) index=int(NumberofBar);
   else index=Rates_total-int(NumberofBar)-1;
   if(BuyArrow[index]==0 || BuyArrow[index]==1) BuySignal=true;
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
                double &SellArrow[],       // индикаторный буфер с сигналами для покупки
                const int Rates_total,     // текущее количество баров
                const int Prev_calculated, // количество баров на предыдущем тике
                const double &Close[],     // цена закрытия
                const int &Spread[])       // спред
  {
//---
   static uint counter=0;
   if(Rates_total!=Prev_calculated) counter=0;

   bool SellSignal=false;
   bool SeriesTest=ArrayGetAsSeries(SellArrow);
   int index;
   if(SeriesTest) index=int(NumberofBar);
   else index=Rates_total-int(NumberofBar)-1;
   if(SellArrow[index]==2 || SellArrow[index]==3) SellSignal=true;
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
