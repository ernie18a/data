//+------------------------------------------------------------------+
//|                                    ZigZagOnParabolic_channel.mq5 |
//|                                      Copyright © 2009, EarnForex |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2009, EarnForex"
//---- ссылка на сайт автора
#property link      "http://www.earnforex.com"
//---- номер версии индикатора
#property version   "1.00"
#property description "ZigZag on Parabolic в виде канала" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано восемь буферов
#property indicator_buffers 8
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки индикатора облака       |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "ZigZagOnParabolic_channel Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде многоцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цвета индикатора использованы
#property indicator_color2  clrTeal,clrPurple
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Up ZigZagOnParabolic_channel"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цвета индикатора использованы
#property indicator_color3  clrTeal,clrPurple
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3 "Down ZigZagOnParabolic_channel"
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован DodgerBlue
#property indicator_color4  clrDodgerBlue
//---- толщина линии индикатора 4 равна 1
#property indicator_width4  1
//---- отображение бычей метки индикатора
#property indicator_label4  "Up ZigZagOnParabolic_Arrows"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован DeepPink
#property indicator_color5  clrDeepPink
//---- толщина линии индикатора 5 равна 1
#property indicator_width5  1
//---- отображение медвежьей метки индикатора
#property indicator_label5 "Down ZigZagOnParabolic_Arrows"
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input double Step=0.02; //SAR шаг
input double Maximum=0.2; //SAR максимум
input bool ExtremumsShift=true; //флаг сдвига вершины
input uint  UpLable=163;//лейба верхнего фрактала
input uint  DnLable=163;//лейба нижнего фрактала
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
double UpperBuffer[],LowerBuffer[];
double ColorUpperBuffer[],ColorLowerBuffer[];
double LowestBuffer[],HighestBuffer[];
//---- Объявление целых переменных
int EShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int SAR_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=1;
//---- Инициализация констант   
   if(ExtremumsShift) EShift=1;
   else               EShift=0;

//---- получение хендла индикатора SAR
   SAR_Handle=iSAR(NULL,0,Step,Maximum);
   if(SAR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора SAR");
      return(INIT_FAILED);
     }

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ColorUpperBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ColorLowerBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,LowestBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);
   ArraySetAsSeries(ColorUpperBuffer,true);
   ArraySetAsSeries(ColorLowerBuffer,true);
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- символы для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,DnLable);
   PlotIndexSetInteger(4,PLOT_ARROW,UpLable);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   IndicatorSetString(INDICATOR_SHORTNAME,"ZigZagOnParabolic_channel");
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
   if(BarsCalculated(SAR_Handle)<rates_total || rates_total<min_rates_total)return(0);

//---- объявления локальных переменных 
   static int j_,lastcolor_;
   static bool dir_;
   static double h_,l_;
   int j,limit,climit,to_copy,bar,shift,NewBar,lastcolor;
   int barHH,barLL,barHH1,barLL1;
   double h,l,mid0,mid1,SAR[],HH,LL,HH1,LL1;
   bool dir;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчёта всех баров

      h_=0.0;
      l_=999999999;
      dir_=false;
      j_=0;
      lastcolor_=0;

      for(int index=rates_total-1; index>=limit && !IsStopped(); index--)
        {
         UpBuffer[index]=NULL;
         UpperBuffer[index]=NULL;
         HighestBuffer[index]=NULL;

         DnBuffer[index]=NULL;
         LowerBuffer[index]=NULL;
         LowestBuffer[index]=NULL;
        }
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

   climit=limit; // стартовый номер для раскраски индикатора

   to_copy=limit+2;
   if(limit==0) NewBar=1;
   else         NewBar=0;

//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(SAR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(SAR_Handle,0,0,to_copy,SAR)<=0) return(0);

//---- восстанавливаем значения переменных
   j=j_;
   dir=dir_;
   h=h_;
   l=l_;
   lastcolor=lastcolor_;

//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         j_=j;
         dir_=dir;
         h_=h;
         l_=l;
        }

      mid0=(high[bar]+low[bar])/2;
      mid1=(high[bar+1]+low[bar+1])/2;

      HighestBuffer[bar]=0.0;
      LowestBuffer[bar]=0.0;

      if(bar>0) j++;

      if(dir)
        {
         if(h<high[bar])
           {
            h=high[bar];
            j=NewBar;
           }
         if(SAR[bar+1]<=mid1 && SAR[bar]>mid0)
           {
            shift=bar+EShift *(j+NewBar);
            if(shift>rates_total-1) shift=rates_total-1;
            HighestBuffer[shift]=h;
            dir=false;
            l=low[bar];
            j=0;
            if(shift>climit) climit=shift;
           }
        }
      else
        {
         if(l>low[bar])
           {
            l=low[bar];
            j=NewBar;
           }
         if(SAR[bar+1]>=mid1 && SAR[bar]<mid0)
           {
            shift=bar+EShift *(j+NewBar);
            if(shift>rates_total-1) shift=rates_total-1;
            LowestBuffer[shift]=l;
            dir=true;
            h=high[bar];
            j=0;
            if(shift>climit) climit=shift;
           }
        }
     }

//---- Третий большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      barHH=FindFirstExtremum(bar,rates_total,HighestBuffer,HH);
      barHH1=FindFirstExtremum(barHH+1,rates_total,HighestBuffer,HH1);

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

      barLL=FindFirstExtremum(bar,rates_total,LowestBuffer,LL);
      barLL1=FindFirstExtremum(barLL+1,rates_total,LowestBuffer,LL1);

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
     }
//----     
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
