//+------------------------------------------------------------------+
//|                                  Simple_Session_Price_Change.mq5 |
//|                                       Copyright 2024, MrBrooklin |
//|                         https://www.mql5.com/ru/users/mrbrooklin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MrBrooklin"
#property link      "https://www.mql5.com/ru/users/mrbrooklin"
#property version   "1.00"
#property indicator_chart_window // выведем индикатор в окне графика
#property indicator_plots   0    // зададим количество графических серий в индикаторе
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectCreate(0,"Inscription",OBJ_LABEL,0,0,0); // создадим объект "текстовая метка"
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, "Inscription"); // удалим надпись с графика при завершении работы индикатора
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Label_Create(string text)
  {
   ObjectSetInteger(0,"Inscription",OBJPROP_XDISTANCE,500);  // установим координаты метки по оси X
   ObjectSetInteger(0,"Inscription",OBJPROP_YDISTANCE,30);   // установим координаты метки по оси Y
//--- определим угол графика, откуда будут определяться координаты точки привязки
   ObjectSetInteger(0,"Inscription",OBJPROP_CORNER,2);
   ObjectSetString(0,"Inscription",OBJPROP_TEXT,text);       // зададим текст для вывода на экран
   ObjectSetString(0,"Inscription",OBJPROP_FONT,"Segoe UI"); // зададим шрифт текста
   ObjectSetInteger(0,"Inscription",OBJPROP_FONTSIZE,12);    // зададим размер шрифта
   ObjectSetInteger(0,"Inscription",OBJPROP_COLOR,clrDarkMagenta); // зададим цвет текста
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Info_Print()
  {
   double change=0.0; // объявим и инициализируем переменную change (изменение цены в % с момента открытия торговой сессии)
   MqlTick mql_tick; // объявим и инициализируем переменную mql_tick для упрощенного доступа к структуре MqlTick
   SymbolInfoTick(_Symbol,mql_tick); // получим актуальные текущие цены
   double price_bid=mql_tick.bid; // получим текущую цену bid
   double price_open_day=iOpen(_Symbol,PERIOD_D1,0); // получим цену открытия торговой сессии
   if(price_open_day>0 && price_bid>0) // если все цены получены и они больше нуля
      change=((price_bid-price_open_day)*100)/price_open_day; // вычисляем изменение цены в %
   return(change); // возвращаем значение изменения цены в %
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
//--- выводим надпись в правой нижней части окна графика
   Label_Create("Изменение цены с момента открытия торговой сессии = " + DoubleToString(Info_Print(),2)+" %");
//--- возвращаем значение rates_total для следующего вызова
   return(rates_total);
  }
//+------------------------------------------------------------------+