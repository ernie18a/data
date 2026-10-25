//+------------------------------------------------------------------+
//|                                           Waddah_Attar_Pivot.mq5 |
//|                        Copyright © 2007, waddahattar@hotmail.com |
//|                             Waddah Attar waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, waddahattar@hotmail.com"
#property link      "waddahattar@hotmail.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки Daily Pivot              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован зелёный цвет
#property indicator_color1  clrLime
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "Daily Pivot"
//+----------------------------------------------+
//| Параметры отрисовки Weekly Pivot             |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color2  clrRed
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//---- отображение метки индикатора
#property indicator_label2  "Weekly Pivot"
//+----------------------------------------------+
//| Параметры отрисовки Monthly Pivot            |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color3  clrBlue
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 5
#property indicator_width3  5
//---- отображение метки индикатора
#property indicator_label3  "Monthly Pivot"
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input string  SirName="Waddah_Attar_Pivot";         //Первая часть имени графических объектов
input int Shift=0;                                  //сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double IndBuffer1[],IndBuffer2[],IndBuffer3[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление стрингов для текстовых меток
string daily_price_name,weekly_price_name,monthly_price_name;
string daily_text_name,weekly_text_name,monthly_text_name;
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,daily_price_name);
   ObjectDelete(0,weekly_price_name);
   ObjectDelete(0,monthly_price_name);
   ObjectDelete(0,daily_text_name);
   ObjectDelete(0,weekly_text_name);
   ObjectDelete(0,monthly_text_name);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных 
   min_rates_total=2;
//---- Инициализация стрингов
   daily_price_name=SirName+" upper price lable";
   weekly_price_name=SirName+" middle price lable";
   monthly_price_name=SirName+" lower price lable";
   daily_text_name=SirName+" upper text lable";
   weekly_text_name=SirName+" middle text lable";
   monthly_text_name=SirName+" lower text lable";

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer1,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,IndBuffer2,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer2,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer3,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer3,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Waddah_Attar_Pivot");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   double PP,iClose[2],iHigh[2],iLow[2];
//---- Объявление целых переменных и получение уже посчитанных баров
   int limit,bar;
//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(time,true);

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(!CopyClose(Symbol(),PERIOD_D1,time[bar],2,iClose)) return(prev_calculated);
      if(!CopyLow(Symbol(),PERIOD_D1,time[bar],2,iLow)) return(prev_calculated);
      if(!CopyHigh(Symbol(),PERIOD_D1,time[bar],2,iHigh)) return(prev_calculated);
      //---- 
      PP=(iHigh[0]+iLow[0]+iClose[0])/3;
      IndBuffer1[bar]=PP;
      //---- 
      if(!CopyClose(Symbol(),PERIOD_W1,time[bar],2,iClose)) return(prev_calculated);
      if(!CopyLow(Symbol(),PERIOD_W1,time[bar],2,iLow)) return(prev_calculated);
      if(!CopyHigh(Symbol(),PERIOD_W1,time[bar],2,iHigh)) return(prev_calculated);
      //---- 
      PP=(iHigh[0]+iLow[0]+iClose[0])/3;
      IndBuffer2[bar]=PP;
      //---- 
      if(!CopyClose(Symbol(),PERIOD_MN1,time[bar],2,iClose)) return(prev_calculated);
      if(!CopyLow(Symbol(),PERIOD_MN1,time[bar],2,iLow)) return(prev_calculated);
      if(!CopyHigh(Symbol(),PERIOD_MN1,time[bar],2,iHigh)) return(prev_calculated);
      //---- 
      PP=(iHigh[0]+iLow[0]+iClose[0])/3;
      IndBuffer3[bar]=PP;
     }
//----
   SetRightPrice(0,daily_price_name,0,time[0],IndBuffer1[0],indicator_color1);
   SetRightPrice(0,weekly_price_name,0,time[0],IndBuffer2[0],indicator_color2);
   SetRightPrice(0,monthly_price_name,0,time[0],IndBuffer3[0],indicator_color3);
//----  
   SetText(0,daily_text_name,0,"Daily Pivot",time[10],IndBuffer1[0],indicator_color1);
   SetText(0,weekly_text_name,0,"Weekly Pivot",time[10],IndBuffer2[0],indicator_color2);
   SetText(0,monthly_text_name,0,"Monthly Pivot",time[10],IndBuffer3[0],indicator_color3);
//----     
   ChartRedraw(0);
   return(rates_total);
  }
//+----------------------------------------------------+
//| calc lwma atr                                      |
//+----------------------------------------------------+
double calc_atr(int index,const double  &h[],const double  &l[],const double  &c[])
  {
//--- 
   return(MathMax(h[index],c[index-1])-MathMin(l[index],c[index-1]));
//--- 
  }
//+------------------------------------------------------------------+
//|  CreateText creation                                             |
//+------------------------------------------------------------------+
void CreateText(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      string   txt,               // text
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color              // Text color
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,txt);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,1);
//----
  }
//+------------------------------------------------------------------+
//|  SetText reinstallation                                          |
//+------------------------------------------------------------------+
void SetText(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   string   txt,               // text
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color              // Text color
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateText(chart_id,name,nwin,txt,time,price,Color);
   else 
    {
     ObjectMove(chart_id,name,0,time,price);
     ObjectSetString(chart_id,name,OBJPROP_TEXT,txt);
    }
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color              // Text color
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,2);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color              // Text color
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
