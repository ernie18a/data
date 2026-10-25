// 22.01.2009 Редактировал Николай Косицин
//+X================================================================X+
//|                                    Moving Average 2p-IdealMA.mq4 |
//|                                      Copyright © 2009,   Neutron |                                                                   | 
//+X================================================================X+
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов
#property  indicator_buffers 1
//---- цвет линиии индикаторов
#property indicator_color1 Blue
//---- входные параметры эксперта
extern double w1 =0.1;
extern double w2 = 0.1;
//---- индикаторные буферы
double MA[];
//---- 
int StartBar;
//+X================================================================X+
//|  2p-IdealMA function                                             |
//+X================================================================X+
double GetIdealMASmooth(double W1_, double W2_,
                       double Series1, double Series0, double Resalt1)
 {
//---+
   double Resalt0, dSeries, dSeries2;
   dSeries = Series0 - Series1;
   dSeries2 = dSeries * dSeries -1.0;
   
   Resalt0 = (W1_ * (Series0 - Resalt1) + 
                   Resalt1 + W2_ * Resalt1 * dSeries2) 
                                           / (1.0 + W2_ * dSeries2);	
   return(Resalt0);
//---+ 
 }
//+X================================================================X+
//|  initialization function                                         |
//+X================================================================X+
int init()
 {
//---+
   //---- стиль изображения индикатора
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 3);
   //---- буфер для первой линии индикатора
   SetIndexBuffer(0, MA);
   //---- минимальное количество баров для расчёта
   StartBar = 2;
   //----
   return(0);
//---+
 }
//+X================================================================X+
//|  start function                                                  |
//+X================================================================X+
int start()
 {
//---+
   //---- проверка количества баров 
                           //на достаточность для дальнейшего расчёта
   if (Bars - 1 < StartBar)
                       return(-1);
   //---- Введение целых переменных и получение уже посчитанных баров 
   int MaxBar, limit, bar, counted_bars = IndicatorCounted();  
   //---- проверка на возможные ошибки
   if (counted_bars < 0)
                  return(-1);
   //---- последний посчитанный бар должен быть пересчитан
   if (counted_bars > 0)
              counted_bars--;
   //---- определение номера самого старого бара,
            //начиная с которого будет произедён пересчёт всех баров
   MaxBar = Bars - 2;       
   //---- определение номера самого старого бара,
            //начиная с которого будет произедён пересчёт новых баров
   limit = Bars - counted_bars - 1; 
   //---- инициализация нуля   
   if (limit >= MaxBar)
     {
      limit = MaxBar;
      MA[MaxBar] = Close[MaxBar];
	   MA[MaxBar + 1] = Close[MaxBar + 1];
     } 
   //---- ВЫЧИСЛЕНИЕ ИНДИКАТОРА  
	for( bar = limit; bar >= 0; bar--)
      MA[bar] = GetIdealMASmooth(w1, w2, 
                            Close[bar + 1], Close[bar], MA[bar + 1]);
   //----
   return(0);
//---+
 }
//+X----------------------------------------------------------------X+

