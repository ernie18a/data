//+------------------------------------------------------------------+
//|                                         Fair Value Gap Indicator |
//|                                       Copyright 2024, Hieu Hoang |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, hieuhoangcntt@gmail.com"
#property indicator_chart_window
#property indicator_buffers 0
double _low, _high;
string object_names[];
datetime pre_time = 0;
const int bull = 5;
const int bear = 5;
int c_bull;
int c_bear;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isGreenCandle(double open, double close)
  {
   return open < close;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isRedCandle(double open, double close)
  {
   return !isGreenCandle(open, close);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isBullFVG(int index,
               const double &open[],
               const double &high[],
               const double &low[],
               const double &close[])
  {

   if(isGreenCandle(open[index-1], close[index-1]) &&
      high[index-2] < low[index] && high[index-2] < _low
     )
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isBearFVG(int index,
               const double &open[],
               const double &high[],
               const double &low[],
               const double &close[])
  {

   if(isRedCandle(open[index-1], close[index-1]) &&
      low[index-2] > high[index] && low[index-2] > _high
     )
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_object(string name, color clrColor,const datetime time1, const datetime time2, const double low, const double high)
  {
   ArrayResize(object_names, ArraySize(object_names) + 1);
   object_names[ArraySize(object_names) - 1] = name;
   ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, low, time2, high);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);
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
   if(pre_time == time[rates_total - 1])
      return(rates_total);
   pre_time = time[rates_total - 1];
   delete_objects();
   _low = low[rates_total - 1];
   _high = high[rates_total - 1];
   c_bull = 0;
   c_bear = 0;
   for(int i = rates_total - 2; i >= 2; i--)
     {
      _low = _low < low[i] ? _low : low[i];
      _high = _high > high[i] ? _high: high[i];
      if(c_bull < bull && isBullFVG(i, open, high, low, close))
        {
         create_object("Buy range " + high[i-2] + " ↗ " + low[i], clrBlue, time[i-2], time[rates_total-1], low[i], high[i-2]);
         c_bull ++;
         if(c_bull >= bull && c_bear >= bear)
            break;
        }
      else if(c_bear < bear && isBearFVG(i, open, high, low, close))
           {
            create_object("Sell range " + low[i-2] + " ↘ " + high[i], clrRed, time[i-2], time[rates_total-1], high[i], low[i-2]);
            c_bear ++;
            if(c_bull >= bull && c_bear >= bear)
              break;
           }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
void delete_objects()
  {
   for(int i = 0; i < ArraySize(object_names); i++)
      ObjectDelete(0, object_names[i]);
   ArrayResize(object_names, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   pre_time = 0;
   delete_objects();
  }
//+------------------------------------------------------------------+
