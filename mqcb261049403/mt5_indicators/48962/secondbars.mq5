//+------------------------------------------------------------------+
//|                                                   SecondBars.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                              https://www.mql5.com/ru/users/s22aa |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com/ru/users/s22aa"
#property version   "1.00"
#property indicator_chart_window

#property indicator_plots   1
#property indicator_buffers 5

#property indicator_type1  DRAW_CANDLES
#property indicator_color1 clrBlack,clrWhite,clrBlack
#property indicator_label1 "Open;High;Low;Close"

input int day = 1;
input int SecPeriod = 10;
enum type
  {
   Bar,
   Candle
  };
input type m_type = Candle;
input color clrBarUp = clrWhite;
input color clrBarDn = clrBlack;
input bool crosshair = true;// перекрестие

double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtTimeBuffer[];

int size, prev_size;
bool tester, chart_mode_Bid;
double prev_prmax, prev_prmin, prev_volume;
datetime  start_time, prev_time;
long prev_time_msc;
color clr;
MqlRates m_Rates[];
MqlTick ticks[];
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtOpenBuffer,  INDICATOR_DATA);
   SetIndexBuffer(1, ExtHighBuffer,  INDICATOR_DATA);
   SetIndexBuffer(2, ExtLowBuffer,   INDICATOR_DATA);
   SetIndexBuffer(3, ExtCloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ExtTimeBuffer, INDICATOR_CALCULATIONS);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0.0);

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ArraySetAsSeries(ExtOpenBuffer, true);
   ArraySetAsSeries(ExtHighBuffer, true);
   ArraySetAsSeries(ExtLowBuffer, true);
   ArraySetAsSeries(ExtCloseBuffer, true);
   ArraySetAsSeries(ExtTimeBuffer, true);

   if(m_type == Bar)
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_BARS);
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrBarDn);//(color)ChartGetInteger(0, CHART_COLOR_CHART_LINE));
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, clrBarUp);//(color)ChartGetInteger(0, CHART_COLOR_CHART_UP));
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, clrBarDn);//(color)ChartGetInteger(0, CHART_COLOR_CHART_DOWN));

      int width_bar = (int)ChartGetInteger(0, CHART_SCALE) - 2 > 0 ? (int)ChartGetInteger(0, CHART_SCALE) - 2 : 1;
      PlotIndexSetInteger(0, PLOT_LINE_WIDTH, width_bar);
     }
   else
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_CANDLES);
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrBarDn);// (color)ChartGetInteger(0, CHART_COLOR_CHART_LINE)); 0 – цвет контура и теней
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, clrBarUp);// (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL));1 – цвет тела бычьей свечи
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, 2, clrBarDn);// (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR));2 – цвет тела медвежьей свечи
     }

   Chart();// сохраним текущие настройки графика

   ObjectCreate(0, "_S_TimeFrames", OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, "_S_TimeFrames", OBJPROP_TEXT, StringFormat("TF S%d", SecPeriod));
   ObjectSetInteger(0, "_S_TimeFrames", OBJPROP_COLOR, clr);
   ObjectSetInteger(0, "_S_TimeFrames", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "_S_TimeFrames", OBJPROP_XDISTANCE, 5);
   ObjectSetInteger(0, "_S_TimeFrames", OBJPROP_YDISTANCE, 20);

   tester = MQLInfoInteger(MQL_VISUAL_MODE);

   if(!tester)
     {
      ChartSetInteger(0, CHART_EVENT_MOUSE_WHEEL, 1);
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      int widthPx = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);//Ширина графика в пикселях
      if(crosshair)
        {
         VLineCreate("VLine", TimeCurrent());
         HLineCreate(0);
        }
      RectLabelCreate(0, 23, widthPx, 24);
      RectLabelCreate(0, 21, 125, 20, clrWhite, "1");
      LabelCreate("Time", "Time", 3, 19);
     }

   start_time = iTime(_Symbol, PERIOD_D1, day);
   chart_mode_Bid = (SymbolInfoInteger(_Symbol, SYMBOL_CHART_MODE) == SYMBOL_CHART_MODE_BID);
   prev_time = 0;
   prev_time_msc = 0;
   size = -1;
   prev_size = 0;
   prev_volume = 0;
   prev_prmax = 0;
   prev_prmin = DBL_MAX;
   ArrayResize(m_Rates, 10000, 10000);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(!tester)
      Chart(1);
   ObjectsDeleteAll(0, "_S_");
  }
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
   int limit = 0;

   IsTicks();

   if(size <= 0)
      return 0;

   if(prev_calculated <= 0)
     {
      ArrayInitialize(ExtOpenBuffer, 0);
      ArrayInitialize(ExtHighBuffer, 0);
      ArrayInitialize(ExtLowBuffer, 0);
      ArrayInitialize(ExtCloseBuffer, 0);
      ArrayInitialize(ExtTimeBuffer, 0);
      limit = MathMin(size, rates_total) - 1;
     }
   else
      if(size - prev_size > 1)
        {
         prev_size = 0;
         return 0;
        }

   ArraySetAsSeries(m_Rates, true);

   for(int i = limit; i >= 0 && !IsStopped(); i--)
     {
      if(prev_calculated == rates_total && size - prev_size == 1) // если это не новый бар по стандартному таймфрейму графика
        {
         for(int j = MathMin(size, rates_total) - 1; j >= 0; j--) // передвинем все массивы на 1 индекс назад
           {
            ExtOpenBuffer[j + 1] = ExtOpenBuffer[j];
            ExtHighBuffer[j + 1] = ExtHighBuffer[j];
            ExtLowBuffer[j + 1] = ExtLowBuffer[j];
            ExtCloseBuffer[j + 1] = ExtCloseBuffer[j];
            ExtTimeBuffer[j + 1] = ExtTimeBuffer[j];
           }
         IsChartScale(1);
        }

      ExtOpenBuffer[i] = m_Rates[i].open;
      ExtHighBuffer[i] = m_Rates[i].high;
      ExtLowBuffer[i] = m_Rates[i].low;
      ExtCloseBuffer[i] = m_Rates[i].close;
      ExtTimeBuffer[i] = (double)m_Rates[i].time;
     }

   prev_size = size;
   return(rates_total);
  }
//+------------------------------------------------------------------+
void IsTicks()
  {
   double volume = 0;

   if(prev_size == 0)
      prev_time_msc = 0;

   if(prev_time_msc == 0)
      if(start_time == 0)
         prev_time_msc = TimeCurrent() * 1000;
      else
         prev_time_msc = start_time * 1000;

   ArraySetAsSeries(m_Rates, false);

   int result = CopyTicksRange(_Symbol, ticks, (chart_mode_Bid ? COPY_TICKS_INFO : COPY_TICKS_TRADE), prev_time_msc);

   if(result <= 0)
      return;

   for(int i = 0; i < result && !IsStopped(); i++)
     {
      if(ticks[i].time_msc < prev_time_msc)
         continue;

      double prise = chart_mode_Bid ? ticks[i].bid : ticks[i].last;

      if(ticks[i].time >= prev_time + SecPeriod) //находим время следующего бара
        {
         prev_time = ticks[i].time - ticks[i].time % SecPeriod;
         prev_time_msc = ticks[i].time_msc;
         size++;
         ArrayResize(m_Rates, size + 1, 10000); // записываем значения первого тика в секундной свече
         m_Rates[size].time = ticks[i].time;
         m_Rates[size].open = prise;
         m_Rates[size].high = prise;
         m_Rates[size].low = prise;
         m_Rates[size].close = prise;
         prev_volume = 0;
         volume = 0;
        }
      else
        {
         if(m_Rates[size].high < prise)
            m_Rates[size].high = prise;
         if(m_Rates[size].low > prise)
            m_Rates[size].low = prise;
         m_Rates[size].close = prise;
        }

      if(ticks[i].time_msc > prev_time_msc)
        {
         prev_time_msc = ticks[i].time_msc;
         prev_volume += volume;
         volume = 0;
        }

      volume += ticks[i].volume_real;
      m_Rates[size].real_volume = (long)(prev_volume + volume);
     }
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long & lparam,
                  const double & dparam,
                  const string & sparam
                 )
  {
   if(!tester)
      if(id == CHARTEVENT_MOUSE_WHEEL && (dparam >= 120 || dparam >= -120))
        {
         IsChartScale();
         IsScrolTime((int)lparam, (int)dparam);
         ChartRedraw();
        }
      else
         if(id == CHARTEVENT_MOUSE_MOVE)
           {
            IsScrolTime((int)lparam, (int)dparam);
            if(sparam == "1")
               IsChartScale();
            ChartRedraw();
           }
  }
//+------------------------------------------------------------------+
void IsScrolTime(int lparam, int dparam)// двигает вертикальную линию и ползунок со временем вслед за мышей
  {
   datetime time = 0;
   double price = 0;
   int sub_window = 0;
   ChartXYToTimePrice(0, lparam, dparam, sub_window, time, price);
   if(time != 0 && size != 0)
     {
      if(crosshair)
        {
         ObjectMove(0, "_S_VLine", 0, time, 0);
         ObjectMove(0, "_S_HLine", 0, 0, price);
        }
      ObjectSetInteger(0, "_S_RectLabel1", OBJPROP_XDISTANCE, lparam - 60);
      ObjectSetInteger(0, "_S_Time", OBJPROP_XDISTANCE, lparam - 57);
      int shift_time = iBarShift(_Symbol, PERIOD_CURRENT, time);
      if(shift_time < size)
         ObjectSetString(0, "_S_Time", OBJPROP_TEXT, TimeToString(time < TimeCurrent() ? m_Rates[shift_time].time : time, TIME_DATE | TIME_SECONDS));
     }
  }
//+------------------------------------------------------------------+
void Width_Scale()// если изменился масштаб баров, сделаем их толще/тоньше
  {
   static int prev_width_Scale = 0;
   if(m_type == Bar)
     {
      int width_Scale = (int)ChartGetInteger(0, CHART_SCALE) - 2 > 0 ? (int)ChartGetInteger(0, CHART_SCALE) - 2 : 1;
      if(prev_width_Scale != width_Scale)
        {
         PlotIndexSetInteger(0, PLOT_LINE_WIDTH, width_Scale);
         prev_width_Scale = width_Scale;
        }
     }
  }
//+------------------------------------------------------------------+
void IsChartScale(const int flag = 0)// выравнивает мах и мин цену свечей по высоте графика
  {
   if(!tester)
     {
      static int prev_barVisible = 0;
      static int prev_widthPx = 0;
      int barVisible = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      if(flag == 1 || prev_barVisible != barVisible)
        {
         double prmax = 0, prmin = DBL_MAX;
         int barWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);

         if(flag == 1 || size >= barVisible - barWidth)
           {
            int limit = barVisible - barWidth > 0 ? barVisible - barWidth : 0;
            for(int i = size - 1 > barVisible ? barVisible : size - 1; i >= limit; i--)
              {
               if(prmax < m_Rates[i].high)
                  prmax = m_Rates[i].high;
               if(prmin > m_Rates[i].low)
                  prmin = m_Rates[i].low;
              }
            double shift = (prmax - prmin) * 0.05;
            ChartSetDouble(0, CHART_FIXED_MAX, prmax + shift);
            ChartSetDouble(0, CHART_FIXED_MIN, prmin - shift * 2);
            int widthPx = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);//Ширина графика в пикселях
            if(prev_widthPx != widthPx)// если размер графика изменился, подстроим под него нижний прямоугольник
              {
               RectLabelCreate(0, 23, widthPx, 24);
               prev_widthPx = widthPx;
              }
           }
        }
      Width_Scale();
     }
  }
//+------------------------------------------------------------------+
void RectLabelCreate(const int              x = 0,                    // координата по оси X
                     const int              y = 0,                    // координата по оси Y
                     const int              width = 50,               // ширина
                     const int              height = 18,              // высота
                     const color            back_clr = C'236,233,216', // цвет фона
                     const string           index = "0",
                     string                 name = "_S_RectLabel")
  {
   name += index;
//--- создадим прямоугольную метку
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
//--- установим координаты метки
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
//--- установим размеры метки
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
//--- установим цвет фона
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, back_clr);
//--- установим тип границы
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
//--- установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
//--- установим цвет плоской рамки (в режиме Flat)
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }
//+------------------------------------------------------------------+
//| Создает горизонтальную линию                                     |
//+------------------------------------------------------------------+
void HLineCreate(double                price = 0,           // цена линии
                 //const color           clr = clrWhite,      // цвет линии
                 const string          name = "_S_HLine")   // имя линии

  {
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
//--- установим цвет линии
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
//--- установим стиль отображения линии
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
//--- установим толщину линии
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
//--- включим (true) или отключим (false) режим отображения линии в подокнах графика
   ObjectSetInteger(0, name, OBJPROP_RAY, true);
  }
//+------------------------------------------------------------------+
//| Создает вертикальную линию                                       |
//+------------------------------------------------------------------+
void VLineCreate(string                name = "_S_VLine",   // имя линии
                 datetime              time = 0,            // время линии
                 //const color           clr = clrWhite,      // цвет линии
                 ENUM_LINE_STYLE       style = STYLE_SOLID)
  {
   name = "_S_" + name;
   ObjectCreate(0, name, OBJ_VLINE, 0, time, 0);
//--- установим цвет линии
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
//--- установим стиль отображения линии
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
//--- установим толщину линии
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
//--- включим (true) или отключим (false) режим отображения линии в подокнах графика
   ObjectSetInteger(0, name, OBJPROP_RAY, true);
  }
//+------------------------------------------------------------------+
void LabelCreate(string                  name = "Label",           // имя метки
                 const string            text = "Label",           // текст метки
                 const int               x = 0,                    // координата по оси X
                 const int               y = 0)                    // координата по оси Y
  {
   name = "_S_" + name;
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
//--- установим координаты метки
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
//--- установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
//--- установим текст
   ObjectSetString(0, name, OBJPROP_TEXT, text);
//--- установим шрифт текста
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
//--- установим размер шрифта
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
//--- установим способ привязки
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
//--- установим цвет
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }
//+------------------------------------------------------------------+
void Chart(int index = 0)
  {
   static long clrChart = ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   static long _clrBarUp = ChartGetInteger(0, CHART_COLOR_CHART_UP);
   static long _clrBarDn = ChartGetInteger(0, CHART_COLOR_CHART_DOWN);
   static long clrLine  = ChartGetInteger(0, CHART_COLOR_CHART_LINE);
   static long clrBull  = ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
   static long clrBear  = ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
   static bool sep      = ChartGetInteger(0, CHART_SHOW_PERIOD_SEP);
   clr = (color)AnotherColor((uint)clrChart);

   if(index == 0)
     {
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrChart);
      ChartSetInteger(0, CHART_COLOR_CHART_UP, clrChart);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrChart);

      ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrChart);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrChart);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrChart);

      ChartSetInteger(0, CHART_SCALEFIX, true);
      ChartSetInteger(0, CHART_BRING_TO_TOP, false);
      ChartSetInteger(0, CHART_SHOW_DATE_SCALE, false);
      ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, false);
     }

   if(index == 1)
     {
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrChart);
      ChartSetInteger(0, CHART_COLOR_CHART_UP, _clrBarUp);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, _clrBarDn);

      ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrLine);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrBull);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBear);

      ChartSetInteger(0, CHART_SCALEFIX, false);
      ChartSetInteger(0, CHART_SHOW_DATE_SCALE, true);
      ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, sep);
     }
   ChartRedraw();
  }
//+------------------------------------------------------------------+
uint AnotherColor(uint back)
  {
   union argb
     {
      uint clr;
      uchar c[4];
     };

   argb c;
   c.clr = back;
   c.c[0] = (c.c[0] > 127) ? 0 : 255;
   c.c[1] = (c.c[1] > 127) ? 0 : 255;
   c.c[2] = (c.c[2] > 127) ? 0 : 255;
   return c.clr;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
