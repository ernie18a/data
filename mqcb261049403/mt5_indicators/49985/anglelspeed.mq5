//+------------------------------------------------------------------+
//|                                                  Angle&Speed.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                              https://www.mql5.com/ru/users/s22aa |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com/ru/users/s22aa"
#property version   "1.02"
#property description "индикатор расчитывает угол между трендовой линией и горизонталью"
#property description "или"
#property description "индикатор расчитывает среднюю скорость изменения цены"
#property description "пунктов в минуту"
#property description "нарисовать трендовую линию, задать ей цвет как в настройках индикатора"
#property indicator_separate_window
#property indicator_plots   1
#property indicator_buffers 1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_label1  "Angle&Speed"
#property indicator_minimum 0

enum var
  {
   angle,
   average_speed
  };
sinput var    variant    = angle;
sinput color  trendColor = clrWhite; // цвет трендовой линии
sinput int    bar        = 30;       // period
sinput bool   basement   = true;     // показывать подвал
string prefix = "";
int perSec;
double speed[];
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, speed, INDICATOR_DATA);

   if(!basement)
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
      ChartSetInteger(0, CHART_HEIGHT_IN_PIXELS, ChartWindowFind(), 0);
     }
   else
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
      ChartSetInteger(0, CHART_HEIGHT_IN_PIXELS, ChartWindowFind(), -1);
     }

   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   string name = (variant == angle ? "angle (" : "speed (") + (string)bar + ") ";
   IndicatorSetString(INDICATOR_SHORTNAME, name);
   prefix = (string)trendColor;
   perSec = PeriodSeconds(PERIOD_CURRENT);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);
   return(INIT_SUCCEEDED);
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
   int limit = prev_calculated - 1;
   if(prev_calculated <= 0)
     {
      ArrayInitialize(speed, 0);
      limit = bar;
     }

   for(int i = limit; i < rates_total; i++)
     {
      switch(variant)
        {
         case  angle:
            speed[i] = atan(MathAbs((close[i] - close[i - bar]) / _Point) / (bar * (perSec / 60))) * 180 / M_PI;
            if(close[i] - close[i - bar] < 0)
               speed[i] = 360 - speed[i];
            break;
         default:
            speed[i] = MathAbs((close[i] - close[i - bar]) / _Point) / (bar * (perSec / 60));
            break;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long & lparam,
                  const double & dparam,
                  const string & sparam
                 )
  {
   if(id == CHARTEVENT_OBJECT_DRAG || id == CHARTEVENT_OBJECT_CHANGE)
      if(ObjectGetInteger(0, sparam, OBJPROP_TYPE) == OBJ_TREND)
         if(ObjectGetInteger(0, sparam, OBJPROP_COLOR) == trendColor)
           {
            ObjectsDeleteAll(0, prefix + sparam, 0, OBJ_TEXT);

            double price1 = ObjectGetDouble(0, sparam, OBJPROP_PRICE, 0);
            double price2 = ObjectGetDouble(0, sparam, OBJPROP_PRICE, 1);
            double pips = (price2 - price1) / _Point;

            datetime time1 = (datetime)ObjectGetInteger(0, sparam, OBJPROP_TIME, 0);
            datetime time2 = (datetime)ObjectGetInteger(0, sparam, OBJPROP_TIME, 1);
            double minut = double(time2 - time1) / 60;

            string txt = "90";
            if(minut != 0)
               switch(variant)
                 {
                  case  angle:
                    {
                     double Angle = atan(pips / minut) * 180 / M_PI;
                     Angle = minut < 0 ?  Angle + 180 : pips < 0 ? Angle + 360 :  Angle;
                     txt = DoubleToString(Angle, 2) + "°";
                    }
                  break;
                  default:
                     txt = DoubleToString(MathAbs(pips / minut), 2);
                     break;
                 }

            string name = prefix + sparam + (string)time2;
            TextCreate(name, time2, price2, txt);

            ObjectSetInteger(0, sparam, OBJPROP_TIME, 0, time1);
            ObjectSetInteger(0, sparam, OBJPROP_TIME, 1, time2);
            ObjectSetInteger(0, sparam, OBJPROP_BACK, false);
            ChartRedraw();
           }
         else
           {
            ObjectsDeleteAll(0, prefix + sparam, 0, OBJ_TEXT);
            ChartRedraw();
           }

   if(id == CHARTEVENT_OBJECT_DELETE && StringFind(sparam, prefix) < 0)
     {
      ObjectsDeleteAll(0, prefix + sparam, 0, OBJ_TEXT);
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason != REASON_CHARTCHANGE)
      ObjectsDeleteAll(0, prefix, 0, OBJ_TEXT);
  }
//+------------------------------------------------------------------+
void TextCreate(string name, datetime time, double price, string txt)
  {
   ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, trendColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }
//+------------------------------------------------------------------+
