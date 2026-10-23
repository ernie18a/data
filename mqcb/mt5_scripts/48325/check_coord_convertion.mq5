//+------------------------------------------------------------------+
//|                                       Check_coord_convertion.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
void OnStart()
  {
   int generations_total = {};
   int deviations_total = {};
   uint time_start_script = GetTickCount();
   while(!IsStopped())
     {
      int x_input = 16383 - MathRand();
      int y_input = 16383 - MathRand();
      int first_bar_downloaded = TerminalInfoInteger(TERMINAL_MAXBARS) - 1;
      datetime time_first_bar_downloaded = iTime(Symbol(), Period(), first_bar_downloaded);
      double price_max_start = ChartGetDouble(0, CHART_PRICE_MAX);
      double price_min_start = ChartGetDouble(0, CHART_PRICE_MIN);
      int first_bar_start = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      int chart_scale_start = (int)ChartGetInteger(0, CHART_SCALE);
      int x_0 = GetXFromTime(time_first_bar_downloaded);
      int y_0 = GetYFromPrice(0);
      if(x_input < x_0)
         x_input = x_0;
      if(y_input > y_0)
         y_input = y_0;
      datetime time = GetTimeFromX(x_input);
      double price = GetPriceFromY(y_input);
      int x_output = GetXFromTime(time);
      int y_output = GetYFromPrice(price);
      double price_max_stop = ChartGetDouble(0, CHART_PRICE_MAX);
      double price_min_stop = ChartGetDouble(0, CHART_PRICE_MIN);
      int first_bar_stop = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      int chart_scale_stop = (int)ChartGetInteger(0, CHART_SCALE);
      if(price_max_start == price_max_stop && price_min_start == price_min_stop && first_bar_start == first_bar_stop && chart_scale_start == chart_scale_stop)//проверяем чтобы в момент перевода координат из одной системы в другую и обратно, масштаб и положение графика не менялись
        {
         ++generations_total;
         if(x_input != x_output || y_input != y_output)
           {
            ++deviations_total;
            Print("!!! deviation detected !!!");
            Print("x_input= ", x_input, " y_input= ", y_input);
            Print("x_output= ", x_output, " y_output= ", y_output);
           }
        }
     }
   Print("Test ended up with ", deviations_total, " deviations");
   if(deviations_total == 0)
      Print("Everything is Ok");
   Print("generations_total= ", generations_total);
   int generations_rate = generations_total / ((double)(GetTickCount() - time_start_script) / 1000);
   Print("generations rate= ", generations_rate, " generations / sec");
  }
//+------------------------------------------------------------------+
int GetXFromTime(datetime time)
  {
   int pixels_per_bar = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) / (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS) + 1;
   double pixels_per_time = (double)pixels_per_bar / PeriodSeconds();
   int first_bar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   datetime time_first_bar = iTime(Symbol(), Period(), first_bar);
   datetime time_0 = iTime(Symbol(), Period(), 0);
   if(time <= time_0)
     {
      int nearest_bar = iBarShift(Symbol(), Period(), time);
      datetime time_nearest_bar = iTime(Symbol(), Period(), nearest_bar);
      datetime time_remaining = time - time_nearest_bar;
      time_remaining -= (int)MathFloor(time_remaining / PeriodSeconds()) * PeriodSeconds();
      return (first_bar - nearest_bar) * pixels_per_bar + (int)MathRound(time_remaining * pixels_per_time);
     }
   else
      return first_bar * pixels_per_bar + (int)MathRound((time - time_0) * pixels_per_time);
  }
//+------------------------------------------------------------------+
int GetYFromPrice(double price)
  {
   double price_max = ChartGetDouble(0, CHART_PRICE_MAX);
   double price_min = ChartGetDouble(0, CHART_PRICE_MIN);
   double pixels_per_price = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) / (price_max - price_min);
   return (int)MathRound((price_max - price) * pixels_per_price);
  }
//+------------------------------------------------------------------+
datetime GetTimeFromX(int x_dist)
  {
   int first_bar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   datetime time_first_bar = iTime(Symbol(), Period(), first_bar);
   int pixels_per_bar = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) / (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS) + 1;
   double time_per_pixel = (double)PeriodSeconds() / pixels_per_bar;
   datetime time_remaining = (int)(((double)x_dist / pixels_per_bar - (int)(x_dist / pixels_per_bar)) * pixels_per_bar * time_per_pixel);
   int nearest_bar = first_bar - (int)(x_dist / pixels_per_bar);
   datetime time_nearest_bar = {};
   if(nearest_bar < 0)
     {
      datetime time_0 = iTime(Symbol(), Period(), 0);
      datetime delta_time_start = time_0 - time_first_bar;
      datetime delta_time_stop = (0 - nearest_bar) * PeriodSeconds();
      time_nearest_bar = time_first_bar + delta_time_start + delta_time_stop;
     }
   else
      time_nearest_bar = iTime(Symbol(), Period(), nearest_bar);
   return time_nearest_bar + time_remaining;
  }
//+------------------------------------------------------------------+
double GetPriceFromY(int y_dist)
  {
   double price_per_pixel = (ChartGetDouble(0, CHART_PRICE_MAX) - ChartGetDouble(0, CHART_PRICE_MIN)) / ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   double price_max = ChartGetDouble(0, CHART_PRICE_MAX);
   return price_max - price_per_pixel * y_dist;
  }
//+------------------------------------------------------------------+
