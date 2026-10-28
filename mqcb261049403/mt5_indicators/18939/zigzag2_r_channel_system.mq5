//+------------------------------------------------------------------+
//|                                     Zigzag2_R_channel_System.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
/* В стандартном индикаторе http://codebase.mql4.com/ru/238 для      |
рисования использовался стиль DRAW_SECTION. Этот стиль позволяет     |
рисовать отрезками только между точками, находящимимся на разных     |
барах. Стиль отрисовки DRAW_ARROW позволяет снять это ограничение,   |
для этого используются два буфера вместо одного. Для иллюстрации     |
этого стиля и был написан Zigzag2_R_Arrows.mq5.                      |
В код добавлена обработка внешнего  бара (outside bar), когда  High  |
текущего бара выше предыдущих, а Low текущего бара ниже предыдущих.  |
Блок обработки внешнего бара дан как пример. Вы можете использовать  |
свой алгоритм для такой ситуации.                                    |
//+------------------------------------------------------------------+
*/
//---- авторство индикатора
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.00"
#property description "ZigZag" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано пятнадцать буферов
#property indicator_buffers 15
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки индикатора облака       |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "Zigzag2_R_channel Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде многоцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цвета индикатора использованы
#property indicator_color2  clrAqua,clrGold
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Up Zigzag2_R_channel"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цвета индикатора использованы
#property indicator_color3  clrAqua,clrGold
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3 "Down Zigzag2_R_channel"
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован Blue
#property indicator_color4  clrBlue
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение бычей метки индикатора
#property indicator_label4  "Up Zigzag2_R_Arrows"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован DeepPink
#property indicator_color5  clrDeepPink
//---- толщина линии индикатора 5 равна 2
#property indicator_width5  2
//---- отображение медвежьей метки индикатора
#property indicator_label5 "Down Zigzag2_R_Arrows"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type6   DRAW_COLOR_CANDLES
#property indicator_color6  clrChartreuse,clrTeal,clrPurple,clrMagenta
//---- отображение метки индикатора
#property indicator_label6  "Zigzag2_R_channel_Candle"
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input int ExtDepth=12;
input int ExtDeviation=5;
input int ExtBackstep=3;
input uint  UpLable=119;//лейба верхнего фрактала
input uint  DnLable=119;//лейба нижнего фрактала
input uint NumberofBar=1;//Номер бара для подачи сигнала
input bool SoundON=true; //Разрешение алерта
input uint NumberofAlerts=2;//Количество алертов
input bool EMailON=false; //Разрешение почтовой отправки сигнала
input bool PushON=false; //Разрешение отправки сигнала на мобильный
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем  использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
double UpperBuffer[],LowerBuffer[];
double ColorUpperBuffer[],ColorLowerBuffer[];
double ZigzagPeakBuffer[],ZigzagLawnBuffer[];
double HighMapBuffer[],LowMapBuffer[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов для свеч
double ExtOpenBuffer[],ExtHighBuffer[];
double ExtLowBuffer[],ExtCloseBuffer[];
double ExtColorBuffer[];
int level=3; // recounting's depth 
bool downloadhistory=false;
double dExtDeviation;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=ExtDepth+ExtBackstep;
   dExtDeviation=ExtDeviation*_Point;

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ColorUpperBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ColorLowerBuffer,INDICATOR_COLOR_INDEX);
//---- превращение динамических массивов в индикаторные буферы  
   SetIndexBuffer(6,ZigzagPeakBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ZigzagLawnBuffer,INDICATOR_DATA);

//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);
   ArraySetAsSeries(ColorUpperBuffer,true);
   ArraySetAsSeries(ColorLowerBuffer,true);
   ArraySetAsSeries(ZigzagLawnBuffer,true);
   ArraySetAsSeries(ZigzagPeakBuffer,true);
   ArraySetAsSeries(HighMapBuffer,true);
   ArraySetAsSeries(LowMapBuffer,true);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- символы для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,DnLable);
   PlotIndexSetInteger(4,PLOT_ARROW,UpLable);

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

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(13,HighMapBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,LowMapBuffer,INDICATOR_CALCULATIONS);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"Zigzag2_R_Arrows(ExtDepth=",ExtDepth,"ExtDeviation = ",ExtDeviation,"ExtBackstep = ",ExtBackstep,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
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
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,bar;
   int iii=0,counterZ=0,whatlookfor=0;
   int back,lasthighpos,lastlowpos;
   double val,res;
   double curlow=9999999999.0,curhigh=0.0,lasthigh=0.0,lastlow=999999999.0;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      ArrayInitialize(ZigzagPeakBuffer,NULL);
      ArrayInitialize(ZigzagLawnBuffer,NULL);
      ArrayInitialize(HighMapBuffer,NULL);
      ArrayInitialize(LowMapBuffer,NULL);
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      //----
      while(counterZ<level && iii<100)
        {
         res=(ZigzagPeakBuffer[iii]+ZigzagLawnBuffer[iii]);
         //----
         if(res) counterZ++;
         iii++;
        }
      iii--;
      limit=iii;
      //----
      if(LowMapBuffer[iii])
        {
         curlow=LowMapBuffer[iii];
         whatlookfor=1;
        }
      else
        {
         curhigh=HighMapBuffer[iii];
         whatlookfor=-1;
        }
      //----
      for(iii=limit-1; iii>=0; iii--)
        {
         ZigzagPeakBuffer[iii] = NULL;
         ZigzagLawnBuffer[iii] = NULL;
         LowMapBuffer[iii]=NULL;
         HighMapBuffer[iii]=NULL;
        }
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      val=low[ArrayMinimum(low,bar,ExtDepth)];
      //----
      if(val==lastlow)
         val=NULL;
      else
        {
         lastlow=val;
         //----
         if(low[bar]-val>dExtDeviation)
            val=NULL;
         else
           {
            //----
            for(back=1; back<=ExtBackstep; back++)
              {
               res=LowMapBuffer[bar+back];
               //----
               if(res && res>val) LowMapBuffer[bar+back]=NULL;
              }
           }
        }
      //----
      if(low[bar]==val)
         LowMapBuffer[bar]=val;
      else
         LowMapBuffer[bar]=NULL;
      //--- high
      val=high[ArrayMaximum(high,bar,ExtDepth)];
      //----
      if(val==lasthigh)
         val=NULL;
      else
        {
         lasthigh=val;
         //----
         if(val-high[bar]>dExtDeviation)
            val=NULL;
         else
           {
            //----
            for(back=1; back<=ExtBackstep; back++)
              {
               res=HighMapBuffer[bar+back];
               //----
               if(res && res<val) HighMapBuffer[bar+back]=NULL;
              }
           }
        }
      //----
      if(high[bar]==val)
         HighMapBuffer[bar]=val;
      else
         HighMapBuffer[bar]=NULL;
     }

//---- final cutting 
   if(!whatlookfor)
     {
      lastlow=NULL;
      lasthigh=NULL;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }

//---- Второй большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      res=NULL;
      switch(whatlookfor)
        {
         // look for peak or lawn 
         case 0: if(!lastlow && !lasthigh)
           {
            if(HighMapBuffer[bar])
              {
               lasthigh=high[bar];
               lasthighpos = bar;
               whatlookfor = -1;
               ZigzagPeakBuffer[bar]=lasthigh;
               res=1;
              }
            if(LowMapBuffer[bar])
              {
               lastlow=low[bar];
               lastlowpos=bar;
               whatlookfor=1;
               ZigzagLawnBuffer[bar]=lastlow;
               res=1;
              }
           }
         break;
         // look for peak
         case 1: if(LowMapBuffer[bar] && LowMapBuffer[bar]<lastlow && !HighMapBuffer[bar])
           {
            ZigzagLawnBuffer[lastlowpos]=NULL;
            lastlowpos=bar;
            lastlow=LowMapBuffer[bar];
            ZigzagLawnBuffer[bar]=lastlow;
            res=1;
           }
         if(HighMapBuffer[bar] && !LowMapBuffer[bar])
           {
            lasthigh=HighMapBuffer[bar];
            lasthighpos=bar;
            ZigzagPeakBuffer[bar]=lasthigh;
            whatlookfor=-1;
            res=1;
           }
         break;
         // look for lawn
         case -1:  if(HighMapBuffer[bar] && HighMapBuffer[bar]>lasthigh && !LowMapBuffer[bar])
           {
            ZigzagPeakBuffer[lasthighpos]=NULL;
            lasthighpos=bar;
            lasthigh=HighMapBuffer[bar];
            ZigzagPeakBuffer[bar]=lasthigh;
           }
         if(LowMapBuffer[bar] && !HighMapBuffer[bar])
           {
            lastlow=LowMapBuffer[bar];
            lastlowpos=bar;
            ZigzagLawnBuffer[bar]=lastlow;
            whatlookfor=1;
           }
         break;
         default: return(rates_total);
        }
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

      barHH=FindFirstExtremum(bar,rates_total,ZigzagPeakBuffer,HH);
      barHH1=FindFirstExtremum(barHH+1,rates_total,ZigzagPeakBuffer,HH1);

      if(barHH>=0 && barHH1>=0)
        {
         for(int index=barHH1-1; index>barHH && !IsStopped(); index--)
           {
            UpBuffer[index]=HH1;
            UpperBuffer[index]=HH1;
            ColorUpperBuffer[index]=ColorUpperBuffer[index+1];
           }

         for(int index=barHH; index>=bar && !IsStopped(); index--)
           {
            UpBuffer[index]=HH;
            UpperBuffer[index]=HH;
            if(HH>HH1) ColorUpperBuffer[index]=0;
            else if(HH<HH1) ColorUpperBuffer[index]=1;
            else ColorUpperBuffer[index]=ColorUpperBuffer[index+1];
           }
        }

      barLL=FindFirstExtremum(bar,rates_total,ZigzagLawnBuffer,LL);
      barLL1=FindFirstExtremum(barLL+1,rates_total,ZigzagLawnBuffer,LL1);

      if(barLL>=0 && barLL1>=0)
        {
         for(int index=barLL1-1; index>barLL && !IsStopped(); index--)
           {
            DnBuffer[index]=LL1;
            LowerBuffer[index]=LL1;
            ColorLowerBuffer[index]=ColorLowerBuffer[index+1];
           }

         for(int index=barLL; index>=bar && !IsStopped(); index--)
           {
            DnBuffer[index]=LL;
            LowerBuffer[index]=LL;
            if(LL>LL1) ColorLowerBuffer[index]=0;
            else if(LL<LL1) ColorLowerBuffer[index]=1;
            else ColorLowerBuffer[index]=ColorLowerBuffer[index+1];
           }
        }
        
      if(barHH>=0 && barHH1>=0 && barLL>=0 && barLL1>=0)
        {
         for(int index=MathMax(barHH1-1,barLL1-1); index>=bar && !IsStopped(); index--)
           {
            ExtOpenBuffer[index]=NULL;
            ExtHighBuffer[index]=NULL;
            ExtLowBuffer[index]=NULL;
            ExtCloseBuffer[index]=NULL;
            ExtColorBuffer[index]=EMPTY_VALUE;
            
            if(close[index]-UpBuffer[index]>0.0)
              {
               ExtOpenBuffer[index]=open[index];
               ExtHighBuffer[index]=high[index];
               ExtLowBuffer[index]=low[index];
               ExtCloseBuffer[index]=close[index];
               if(close[index]-open[index]<0) ExtColorBuffer[index]=1.0;
               else ExtColorBuffer[index]=0.0;
              }
              
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
   string text="Zigzag2_R_channel_System";
   
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
