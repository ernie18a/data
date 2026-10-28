//+------------------------------------------------------------------+
//|                                               PriceTimeScale.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                              https://www.mql5.com/ru/users/s22aa |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/ru/users/s22aa"
#property version   "1.08"
#property indicator_separate_window
#property indicator_buffers 0
#property indicator_plots 0
#include <Canvas\Canvas.mqh>
CCanvas canvasTime1;
CCanvas canvasTime2;
CCanvas canvasPrice1;
CCanvas canvasPrice2;
CCanvas canvasPrice3;

input int    font_size        = 9;              // Scale font size
input int    RoundPriceLevels = 5;              // Round price levels
input bool   Crosshair        = true;           // Crosshair always
input bool   ChartSync        = true;           // Chart Sync
input bool   OnlyChartSync    = false;          // Only the charts of the same name
input bool   notRemoveTime    = false;          // Do not remove the time scale.
input bool   notRemovePrice   = false;          // Do not remove the price scale.
input string font             = "Trebuchet MS"; // Font
input int    shiftTime        = 0;              // time shift, hour

bool crosshair = false;
color txtclr, clrBack, priceclr;
int ChartWidth;
int ChartHeight;
int perSec = 0;
uint run_width, run_height, txt_width, txt_height, font_width, font_height, lenPrice;
int sub_window = 0;
double coef, priceMin, priceMax;
ENUM_TIMEFRAMES period;
bool chart_mode_Bid;
bool expert = false;
bool prevExpert = false;
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!CheckInd())
      return INIT_FAILED;

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 0, true);
   ChartSetInteger(0, CHART_EVENT_MOUSE_WHEEL, 0, true);
   ChartSetInteger(0, CHART_FOREGROUND, 0, false);
   ChartSetInteger(0, CHART_AUTOSCROLL, false);

   if(!notRemovePrice)
      ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, 0, false);

   if(!notRemoveTime)
      ChartSetInteger(0, CHART_SHOW_DATE_SCALE, 0, false);

   TextSetFont(font, font_size * -10);
   TextGetSize("0", font_width, font_height);
   TextGetSize("00 May 00:00", txt_width, txt_height);
   TextGetSize("2025.01.01 00:00", run_width, run_height);

   canvasTime1.FontSet(font, (font_size * -10), FW_LIGHT);
   canvasTime2.FontSet(font, (font_size * -10), FW_LIGHT);
   canvasPrice1.FontSet(font, (font_size * -10), FW_THIN);
   canvasPrice2.FontSet(font, (font_size * -10), FW_THIN);
   canvasPrice3.FontSet(font, (font_size * -10), FW_THIN);

   clrBack = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   txtclr = (color)AnotherColor(clrBack);
   perSec = PeriodSeconds(PERIOD_CURRENT);
   ChartWidth  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   ChartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   IndicatorSetInteger(INDICATOR_HEIGHT, font_height + font_height / 2);
   sub_window = ChartWindowFind();

   if(Crosshair)
     {
      VLineCreate(txtclr);
      HLineCreate(txtclr);
     }
   else
     {
      ObjectDelete(0, "VLine");
      ObjectDelete(0, "HLine");
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   if(prev_calculated <= 0)
     {
      ObjectDelete(0, "PriceLast");
      ObjectDelete(0, "Price");
      ObjectDelete(0, "PriceScale");
      ObjectDelete(0, "ScaleTime");
      ObjectDelete(0, "RunnerTime");
      ChartRedraw();
      RunnerPrice(0, 0, true);
      RunnerTime(0, 0, true);// есть проблема с отрисовкой шкалы при удалении с графика другого индикатора. Связанная вероятнее всего с использованием iTime
     }

   double price = close[rates_total - 1];
   if(price >= priceMin && price <= priceMax)
      PriceLast(price);
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long & lparam, const double & dparam, const string & sparam)
  {
   static long lastWidth = 0, lastHeight = 0;
   static double lastY = 0;
   static long timeClick = 0, timeRunner = 0;
   static bool QUICK_NAVIGATION = false;

   ChartInactive(id, lparam, dparam);

   if(id == CHARTEVENT_CLICK)
      // отслеживает двойной клик по шкале с ценой, чтоб отключить фиксированный вертикальный масштаб
      if(lparam > ChartWidth - font_width * (lenPrice + 2))
         if(GetTickCount() <= timeClick + 500)
            ChartSetInteger(0, CHART_SCALEFIX, false);
         else
            timeClick = GetTickCount();

   if(id == CHARTEVENT_MOUSE_MOVE)
     {
      if(((uint)sparam & 1) == 1) //  "ЛКМ"
        {
         if(crosshair)
           {
            if(Crosshair)
              {
               VLineCreate(txtclr);
               HLineCreate(txtclr);
              }
            crosshair = false;
           }

         if(lparam > ChartWidth - font_width * (lenPrice + 2))// сжатие графика по вертикали (изменение вертикального масштаба))
           {
            double deltaY = dparam - lastY;
            if(deltaY != 0)
              {
               priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
               priceMax = ChartGetDouble(0, CHART_PRICE_MAX);
               coef = ChartHeight / (priceMax - priceMin);
               priceMin = ChartGetDouble(0, CHART_PRICE_MIN) - deltaY / coef;
               priceMax = ChartGetDouble(0, CHART_PRICE_MAX) + deltaY / coef;
               ChartSetInteger(0, CHART_SCALEFIX, true);
               ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
               ChartSetDouble(0, CHART_FIXED_MIN, priceMin);
               ChartSetDouble(0, CHART_FIXED_MAX, priceMax);
               ChartRedraw();
               ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
              }
           }
        }
      lastY = dparam;

      //перерисовка бегунка вслед за мышью
      if(timeRunner + 15 < GetTickCount())
        {
         timeRunner = GetTickCount();

         datetime time;
         double price;
         int subWindow;
         if(ChartXYToTimePrice(0, (int)lparam, (int)dparam, subWindow, time, price))
           {
            ChartActive(time, price);

            if(!crosshair)
              {
               ObjectSetDouble(0, "HLine", OBJPROP_PRICE, price);
               ObjectSetInteger(0, "VLine", OBJPROP_TIME, time);
              }

            RunnerPrice((int)dparam, price);
            RunnerTime((int)lparam, time);
           }

         if(Crosshair)
            if(sparam == "16")
              {
               ObjectDelete(0, "HLine");
               ObjectDelete(0, "VLine");
               crosshair = true;
               ChartRedraw();
              }
            else
               if(sparam == "2" && crosshair)
                 {
                  VLineCreate(txtclr);
                  HLineCreate(txtclr);
                  crosshair = false;
                 }
        }
     }

   if(id == CHARTEVENT_MOUSE_WHEEL)
     {
      //прокрутка графика по горизонтали с помощью колёсика миши
      int x_cursor = (int)(short)lparam;
      int y_cursor = (int)(short)(lparam >> 16);

      datetime time;
      double price;
      int subWindow;
      if(ChartXYToTimePrice(0, x_cursor, y_cursor, subWindow, time, price))
        {
         ChartActive(time, price);

         RunnerPrice(y_cursor, price);
         RunnerTime(x_cursor, time);

         if(!crosshair)
           {
            ObjectSetDouble(0, "HLine", OBJPROP_PRICE, price);
            ObjectSetInteger(0, "VLine", OBJPROP_TIME, time);
           }
        }
     }

   if(id == CHARTEVENT_CHART_CHANGE)
     {
      expert = (ChartGetString(0, CHART_EXPERT_NAME) != NULL);
      ChartWidth  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      ChartHeight = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
      if(lastWidth != ChartWidth || lastHeight != ChartHeight || prevExpert != expert || period != _Period)
        {
         prevExpert = expert;
         period = _Period;
         chart_mode_Bid = (SymbolInfoInteger(_Symbol, SYMBOL_CHART_MODE) == SYMBOL_CHART_MODE_BID);
         if(chart_mode_Bid)
            priceclr = (color)ChartGetInteger(0, CHART_COLOR_BID);
         else
            priceclr = (color)ChartGetInteger(0, CHART_COLOR_LAST);

         lastWidth = ChartWidth;
         lastHeight = ChartHeight;
         prevExpert = expert;

         ObjectDelete(0, "PriceLast");
         ObjectDelete(0, "Price");
         ObjectDelete(0, "PriceScale");
         ObjectDelete(0, "ScaleTime");
         ObjectDelete(0, "RunnerTime");

         clrBack = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
         txtclr = (color)AnotherColor(clrBack);
         RunnerPrice(0, 0, true);
         RunnerTime(0, 0, true);
        }
     }
  }
//+------------------------------------------------------------------+
void ScalePrice(bool redraw)
  {
   static double lastCoef = 0;
   priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
   priceMax = ChartGetDouble(0, CHART_PRICE_MAX);

   if(priceMax - priceMin > 0)// перерисовываем шкалу если изменился priceMin или priceMax
     {
      coef = ChartHeight / (priceMax - priceMin);
      if(lastCoef != coef || redraw)
        {
         lastCoef = coef;
         lenPrice = StringLen(DoubleToString(priceMax, _Digits));

         if(ObjectFind(0, "PriceScale") >= 0)
            canvasPrice1.Attach(0, "PriceScale", COLOR_FORMAT_ARGB_NORMALIZE);
         else
            canvasPrice1.CreateBitmapLabel(0, 0, "PriceScale", ChartWidth - font_width * (lenPrice + 2), (expert ? 20 : 0), font_width * (lenPrice + 2), ChartHeight, COLOR_FORMAT_ARGB_NORMALIZE);
         canvasPrice1.Erase(ColorToARGB(clrBack));
         canvasPrice1.LineThickVertical(0, 0, ChartHeight, ColorToARGB(txtclr), 3, STYLE_SOLID, LINE_END_BUTT);

         uint grid_step = ChartHeight / (font_height * 2);
         if(grid_step == 0)
            return;
         int grid_coef = (int)((priceMax - priceMin) / grid_step / _Point) / RoundPriceLevels * RoundPriceLevels;
         grid_coef = grid_coef == 0 ? RoundPriceLevels : grid_coef;
         double price = (int)(priceMax / _Point) / grid_coef * grid_coef * _Point;

         while(!IsStopped() && price >= priceMin)
           {
            int TextPosY = (int)(coef * (priceMax - price));
            string text = DoubleToString(price, _Digits);
            canvasPrice1.TextOut(font_width, TextPosY - font_height / 2, text,  ColorToARGB(txtclr));
            canvasPrice1.LineThickHorizontal(0, font_width / 2, TextPosY, ColorToARGB(txtclr), 2, STYLE_SOLID, LINE_END_BUTT);
            price -= grid_coef * _Point;
           }
         canvasPrice1.Update(true);

         if(chart_mode_Bid)
            price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         else
            price = SymbolInfoDouble(_Symbol, SYMBOL_LAST);

         if(price >= priceMin && price <= priceMax)
            PriceLast(price);
        }
     }
  }
//+------------------------------------------------------------------+
void RunnerPrice(int y = 0, double price = 0, bool redraw = false)
  {
   static int lastY = 0;
   static double lastPrice = 0;

   ScalePrice(redraw);

   if(y == 0 || price == 0)
     {
      y = lastY;
      price = lastPrice;
     }
   else
     {
      lastY = y;
      lastPrice = price;
     }

   if(ObjectFind(0, "Price") >= 0)
      canvasPrice2.Attach(0, "Price", COLOR_FORMAT_ARGB_NORMALIZE);
   else
      canvasPrice2.CreateBitmapLabel(0, 0, "Price", ChartWidth - font_width * (lenPrice + 2) + 1, 10, font_width * (lenPrice + 2) - 2, font_height, COLOR_FORMAT_ARGB_NORMALIZE);
   canvasPrice2.Erase(ColorToARGB((color)AnotherColor(txtclr)));
   ObjectSetInteger(0, "Price", OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(0, "Price", OBJPROP_YDISTANCE, y);

   canvasPrice2.Rectangle(0, 0, font_width * (lenPrice + 2) - 2, font_height - 1, ColorToARGB(txtclr));
   canvasPrice2.TextOut(font_width, 0, DoubleToString(price, _Digits),  ColorToARGB(txtclr));
   canvasPrice2.Update(true);
  }
//+------------------------------------------------------------------+
void PriceLast(double price)
  {
   int y = (int)(coef * (priceMax - price));
   static double last_prise = 0;
   if(price == 0)
      price = last_prise;
   else
      last_prise = price;

   if(ObjectFind(0, "PriceLast") >= 0)
      canvasPrice3.Attach(0, "PriceLast", COLOR_FORMAT_ARGB_NORMALIZE);
   else
      canvasPrice3.CreateBitmapLabel(0, 0, "PriceLast", ChartWidth - font_width * (lenPrice + 2) + 1, 10, font_width * (lenPrice + 2) - 2, font_height, COLOR_FORMAT_ARGB_NORMALIZE);
   canvasPrice3.Erase(ColorToARGB(priceclr, 200));

   ObjectSetInteger(0, "PriceLast", OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(0, "PriceLast", OBJPROP_YDISTANCE, y);

   canvasPrice3.Rectangle(0, 0, font_width * (lenPrice + 2) - 2, font_height - 1, ColorToARGB(txtclr));
   canvasPrice3.TextOut(font_width, 0, DoubleToString(price, _Digits),  ColorToARGB(txtclr));
   canvasPrice3.Update(true);
  }
//+------------------------------------------------------------------+
void RunnerTime(int x = 0, datetime time = 0, bool redraw = false)
  {
   static int lastX = 0;
   static datetime prevTime = 0;

   ScaleTime(redraw);

   if(x == 0 || time == 0)
     {
      x = lastX;
      time = prevTime;
     }
   else
     {
      lastX = x;
      prevTime = time;
     }

   if(ObjectFind(0, "RunnerTime") >= 0)
      canvasTime2.Attach(0, "RunnerTime", COLOR_FORMAT_ARGB_NORMALIZE);
   else
      canvasTime2.CreateBitmapLabel(0, sub_window, "RunnerTime", 0, 1, run_width + font_width + 1, font_height + font_height / 5 + 1, COLOR_FORMAT_ARGB_NORMALIZE);
   canvasTime2.Erase(ColorToARGB((color)AnotherColor(txtclr)));
   ObjectSetInteger(0, "RunnerTime", OBJPROP_ANCHOR, ANCHOR_UPPER);
   ObjectSetInteger(0, "RunnerTime", OBJPROP_XDISTANCE, x);

   string txt = TimeToString((time - time % perSec + shiftTime * 60 * 60), TIME_DATE | TIME_MINUTES);

   canvasTime2.Rectangle(0, 0, run_width + font_width, font_height + font_height / 5, ColorToARGB(txtclr));
   canvasTime2.TextOut(font_width / 2, font_height / 5 - 1, txt,  ColorToARGB(txtclr));
   canvasTime2.Update(true);
  }
//+------------------------------------------------------------------+
void ScaleTime(bool redraw)
  {
   static long prevFirstBar = 0;
   long first_bar = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);

   if(prevFirstBar != first_bar || redraw)
     {
      prevFirstBar = first_bar;

      if(ObjectFind(0, "ScaleTime") >= 0)
         canvasTime1.Attach(0, "ScaleTime", COLOR_FORMAT_ARGB_NORMALIZE);
      else
         canvasTime1.CreateBitmapLabel(0, sub_window, "ScaleTime", 0, 0, ChartWidth, font_height + font_height / 2, COLOR_FORMAT_ARGB_NORMALIZE);
      canvasTime1.Erase(ColorToARGB(clrBack));

      long scale =  ChartGetInteger(0, CHART_SCALE);
      int coefX = int(1 << scale);
      long vis_bar = ChartGetInteger(0, CHART_VISIBLE_BARS);
      int bar = int(first_bar - vis_bar);
      bar = bar > 0 ? bar : 0;
      datetime right = iTime(_Symbol, _Period, bar) + shiftTime * 60 * 60;
      int barPx = (int)((vis_bar - 1) * coefX);
      int stepBar = (int)MathCeil(txt_width + font_width * 4) / coefX;

      while(!IsStopped() && bar <= first_bar + stepBar)
        {
         string text = ConvertTime(right);
         canvasTime1.TextOut(barPx, font_height / 5, text,  ColorToARGB(txtclr));
         canvasTime1.LineThickVertical(barPx, font_height + font_height / 2, font_height + font_height / 5, ColorToARGB(txtclr), 3, STYLE_SOLID, LINE_END_BUTT);
         barPx -= stepBar * coefX;
         bar += stepBar;
         right = iTime(_Symbol, _Period, bar) + shiftTime * 60 * 60;
        }
     }
   canvasTime1.Update(true);
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
void OnDeinit(const int reason)
  {
   canvasTime1.Destroy();
   canvasTime2.Destroy();
   canvasPrice1.Destroy();
   canvasPrice2.Destroy();
   canvasPrice3.Destroy();

   ObjectDelete(0, "VLine");
   ObjectDelete(0, "HLine");

   if(!notRemovePrice)
      ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, 0, true);
   if(!notRemoveTime)
      ChartSetInteger(0, CHART_SHOW_DATE_SCALE, 0, true);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
string ConvertTime(datetime time)
  {
   MqlDateTime dt;
   TimeToStructFast(time, dt);

   return (StringFormat("%s %s %s:%s",  IntegerToString(dt.day, 2, '0'), Mon(dt.mon), IntegerToString(dt.hour, 2, '0'), IntegerToString(dt.min, 2, '0')));
  }
//+------------------------------------------------------------------+
void TimeToStructFast(datetime time, MqlDateTime & dt_struct)
  {
   static const int Months[13] = {0, -1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333};
   static int last_days = -1;
   static MqlDateTime last_result = {};

   const uint t = (uint)time;
   const int  n = (int)(t / 86400);
   if(last_days != n)
     {
      int  tn      = (n << 2) + 2;
      int  dow     = (n + 4) % 7;
      int  doy     = (tn % 1461) / 4;
      int  year    = (tn / 1461) + 1970; // to 2100
      int  isleap  = ((year & 3) == 0);
      int  leapadj = ((doy < (isleap + 59)) ? 0 : (2 - isleap));
      int  mon     = ((((doy + leapadj) * 67) + 2075) >> 11);
      int  day     = doy - Months[mon] - (isleap && doy > 59);
      last_days = n;
      last_result.year          = year;
      last_result.mon           = mon;
      last_result.day           = day;
      last_result.day_of_week   = dow;
      last_result.day_of_year   = doy;
     }

   dt_struct = last_result;
   dt_struct.hour = (int)(t / 3600) % 24;
   dt_struct.min = (int)(t / 60) % 60;
   dt_struct.sec = (int)(t % 60);
  }
//+------------------------------------------------------------------+
string Mon(int num)
  {
   if(TerminalInfoString(TERMINAL_LANGUAGE) != "Russian")
      switch(num)
        {
         case  1:
            return "Jan";
         case  2:
            return "Feb";
         case  3:
            return "Mar";
         case  4:
            return "Apr";
         case  5:
            return "May";
         case  6:
            return "Jun";
         case  7:
            return "Jul";
         case  8:
            return "Aug";
         case  9:
            return "Sep";
         case  10:
            return "Oct";
         case  11:
            return "Nov";
         case  12:
            return "Dec";
        }

   switch(num)
     {
      case  1:
         return "Янв";
      case  2:
         return "Фев";
      case  3:
         return "Мар";
      case  4:
         return "Апр";
      case  5:
         return "Май";
      case  6:
         return "Июн";
      case  7:
         return "Июл";
      case  8:
         return "Авг";
      case  9:
         return "Сен";
      case  10:
         return "Окт";
      case  11:
         return "Ноя";
      case  12:
         return "Дек";
     }

   return "";
  }
//+------------------------------------------------------------------+
void HLineCreate(color   clr = clrWhite,
                 string  name = "HLine")
  {
   ObjectCreate(0, name, OBJ_HLINE, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_RAY, false);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, "\n");
  }
//+------------------------------------------------------------------+
void VLineCreate(color    clr = clrWhite,
                 string   name = "VLine")
  {
   ObjectCreate(0, name, OBJ_VLINE, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_RAY, false);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, "\n");
  }
//+------------------------------------------------------------------+
// Если такой индикатор уже запущен на графике, вернём false
//+------------------------------------------------------------------+
bool CheckInd()
  {
   int num = 0;
   long chart_id = ChartID();
   int  wnd_total = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
   for(int w = 0; w < wnd_total; w++)
     {
      int ind_total = ChartIndicatorsTotal(chart_id, w);
      string ind_names = MQLInfoString(MQL_PROGRAM_NAME);
      for(int i = 0; i < ind_total; i++)
         if(ind_names == ChartIndicatorName(chart_id, w, i))
            num++;
     }
   return (num <= 1);
  }
//+------------------------------------------------------------------+
void ChartCustom(long lparam, double dparam)  // отправим пользователькое событие всем графикам
  {
   long chart_id = ChartFirst();
   for(int j = 0; j < CHARTS_MAX; j++)
     {
      if(!OnlyChartSync)
         EventChartCustom(chart_id, 1013, lparam, dparam, "");
      else
         if(ChartSymbol(chart_id) == _Symbol)
            EventChartCustom(chart_id, 1013, lparam, dparam, "");

      chart_id = ChartNext(chart_id);
      if(chart_id < 0)
         break;
     }
  }
//+------------------------------------------------------------------+
//+---  Не активный график  ---//
//+------------------------------------------------------------------+
void ChartInactive(const int id, const long lparam, double dparam)
  {
   if(ChartSync)
      if(id == CHARTEVENT_CUSTOM + 1013)
         if(!ChartGetInteger(0, CHART_BRING_TO_TOP))
           {
            datetime time1 = (datetime)(lparam >> 32);
            datetime time2 = (datetime)(lparam & ~(time1 << 32));

            long wisibleBar = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
            long widthBars = ChartGetInteger(0, CHART_WIDTH_IN_BARS);

            if(time2 > 0)
              {
               int barShift = iBarShift(_Symbol, _Period, time2, true);
               ChartNavigate(0, CHART_CURRENT_POS, -(barShift - (int)wisibleBar + (int)widthBars / 2));
              }
            else
              {
               int barShift = iBarShift(_Symbol, _Period, time1, true);
               if(barShift > wisibleBar)
                  ChartNavigate(0, CHART_CURRENT_POS, -(barShift - (int)wisibleBar));
               else
                  if(barShift < wisibleBar - widthBars)
                     ChartNavigate(0, CHART_CURRENT_POS, -(barShift - (int)wisibleBar + (int)widthBars));
              }

            if(!crosshair)
              {
               ObjectSetDouble(0, "HLine", OBJPROP_PRICE, dparam);
               ObjectSetInteger(0, "VLine", OBJPROP_TIME, time1);
              }
            int x = 0, y = 0;
            if(ChartTimePriceToXY(0, 0, time1, dparam, x, y))
              {
               RunnerPrice(y, dparam);
               RunnerTime(x, time1);
              }
           }
  }
//+------------------------------------------------------------------+
//+---  Активный график  ---//
//+------------------------------------------------------------------+
void ChartActive(datetime time1, double price)
  {
   static datetime  lastTime = 0;
   static long prevBar = 0;

   if(ChartSync)
      if(ChartGetInteger(0, CHART_BRING_TO_TOP))
         if(time1 != lastTime && time1 > 0)
           {
            lastTime = time1;
            long wisibleBar = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);

            datetime time2 = 0;
            if(prevBar != wisibleBar)
              {
               prevBar = wisibleBar;
               long widthBars = ChartGetInteger(0, CHART_WIDTH_IN_BARS);
               time2 = iTime(_Symbol, PERIOD_CURRENT, (int)wisibleBar - (int)widthBars / 2);
              }

            long res = (time1 << 32) | time2;// время курсора и время бара находящегося посередине графика
            ChartCustom(res, price);// отправим пользователькое событие всем графикам
           }
  }
//+------------------------------------------------------------------+
// 1.06 => 1.07 убрал всплывающую надпись на линиях перекрестия
