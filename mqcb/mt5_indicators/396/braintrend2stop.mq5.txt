//+------------------------------------------------------------------+
//|                                              BrainTrend2Stop.mq5 |
//|                               Copyright © 2005, BrainTrading Inc |
//|                                      http://www.braintrading.com |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, BrainTrading Inc."
//---- ссылка на сайт автора
#property link      "http://www.braintrading.com/"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color1  clrRed
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычей метки индикатора
#property indicator_label1  "BrainSell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей метки индикатора
#property indicator_label2 "BrainBuy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color3  clrRed
//---- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3 2
//---- отображение бычей метки индикатора
#property indicator_label3  "Brain2Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color4  clrBlue
//---- толщина линии индикатора 4 равна 1
#property indicator_width4  1
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4 2
//---- отображение медвежьей метки индикатора
#property indicator_label4 "Brain2Buy"

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int ATR_Period=7;
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double SellStopBuffer[];
double BuyStopBuffer[];
double SellStopBuffer_[];
double BuyStopBuffer_[];
//---
bool   river=true,river_;
int    glava,glava_,StartBars,p,P_,OldTrend;
double r,R_,artp_2,s,dartp,cecf,Emaxtra,Emaxtra_,Values_[],Values[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных 
   s=1.5;
   cecf = 0.7;
   dartp=7.0;
//----
   artp_2=0.5*ATR_Period *(ATR_Period+1.0);
   StartBars=ATR_Period+2;

//---- распределение памяти под массивы переменных   
   if(ArrayResize(Values,ATR_Period)<ATR_Period)
      Print("Не удалось распределить память под массив Values");
   if(ArrayResize(Values_,ATR_Period)<ATR_Period)
      Print("Не удалось распределить память под массив Values_");

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellStopBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Brain2SellStop");
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellStopBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyStopBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Brain2BuyStop");
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyStopBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,SellStopBuffer_,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Brain2SellStop");
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellStopBuffer_,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,BuyStopBuffer_,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"Brain2BuyStop");
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyStopBuffer_,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="BrainTrend2Stop";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   if(rates_total<StartBars) return(0);

//---- объявления локальных переменных    
   int bar,J,limit,Curr,to_copy;
   double ATR,widcha,TR,Spread,r1;
   double Weight,Series1,High,Low,range2;

//---- расчёты необходимого количества копируемых данных,
//стартового номера limit для цикла пересчёта баров
// и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-StartBars; // стартовый номер для расчёта всех баров
      to_copy=rates_total; // расчётное количество всех баров
      Emaxtra=close[limit+1];
      glava=0;
      double T_Series2=close[limit+2];
      double T_Series1=close[limit+1];
      if(T_Series2>T_Series1)
         river=true;
      else river=false;

      TR=spread[limit]+high[limit]-low[limit];

      if(MathAbs(spread[limit]+high[limit]-T_Series1)>TR)
         TR=MathAbs(spread[limit]+high[limit]-T_Series1);

      if(MathAbs(low[limit]-T_Series1)>TR)
         TR=MathAbs(low[limit]-T_Series1);

      ArrayInitialize(Values,TR);
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      to_copy=rates_total-prev_calculated+1; // расчётное количество только новых баров
     }

//---- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(spread,true);
   ArraySetAsSeries(Values,true);
   ArraySetAsSeries(Values_,true);

//---- восстанавливаем значения переменных
   p=P_;
   r=R_;
   glava=glava_;
   Emaxtra=Emaxtra_;
   river=river_;
   ArrayCopy(Values,Values_,0,WHOLE_ARRAY);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0; bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         glava_=glava;
         Emaxtra_=Emaxtra;
         river_=river;
         ArrayCopy(Values_,Values,0,WHOLE_ARRAY);
        }

      BuyStopBuffer[bar]=0.0;
      SellStopBuffer[bar]=0.0;
      BuyStopBuffer_[bar]=0.0;
      SellStopBuffer_[bar]=0.0;

      Spread=spread[bar]*_Point;

      High=high[bar];
      Low=low[bar];
      Series1=close[bar+1];
      TR=Spread+High-Low;

      if(MathAbs(Spread+High-Series1)>TR)
         TR=MathAbs(Spread+High-Series1);

      if(MathAbs(Low-Series1)>TR)
         TR=MathAbs(Low-Series1);

      Values[glava]=TR;

      ATR=0;
      Weight=ATR_Period;
      Curr=glava;

      for(J=0; J<=ATR_Period-1; J++)
        {
         ATR+=Values[Curr]*Weight;
         Weight-=1.0;
         Curr--;
         if(Curr==-1) Curr=ATR_Period-1;
        }

      ATR=2.0*ATR/(dartp *(dartp+1.0));
      glava++;

      range2=ATR*s/4;

      if(glava==ATR_Period) glava=0;

      widcha=cecf*ATR;

      if(river && Low<Emaxtra-widcha)
        {
         river=false;
         Emaxtra=Spread+High;
        }

      if(!river && Spread+High>Emaxtra+widcha)
        {
         river=true;
         Emaxtra=Low;
        }

      if(river && Low>Emaxtra)
        {
         Emaxtra=Low;
        }

      if(!river && Spread+High<Emaxtra)
        {
         Emaxtra=Spread+High;
        }

      if(river)
        {
         r1=Low-range2;
         if(r1<r && OldTrend>0) r1=r;

         BuyStopBuffer[bar]=r1;
         BuyStopBuffer_[bar]=r1;

         if(bar!=0)
           {
            r=r1;
            OldTrend=+1;
           }

        }
      else
        {
         r1=High+range2;
         if(r1>r && OldTrend<0) r1=r;

         SellStopBuffer[bar]=r1;
         SellStopBuffer_[bar]=r1;

         if(bar!=0)
           {
            r=r1;
            OldTrend=-1;
           }
        }
      if(!BuyStopBuffer[bar] && !SellStopBuffer[bar])
        {
         BuyStopBuffer[bar]=BuyStopBuffer[bar+1];
         SellStopBuffer[bar]=SellStopBuffer[bar+1];
        }
     }

//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
