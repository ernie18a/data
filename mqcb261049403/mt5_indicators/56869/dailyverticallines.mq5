//+------------------------------------------------------------------+
//|                                           DailyVerticalLines.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.00"
#property description "Draw daily vertical lines plus the day of week labels on the chart."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- input parameters
input int             InpMaxDays     =  20;                // Maximum daily lines to show
input ENUM_LINE_STYLE InpVLineStyle  =  STYLE_DASHDOTDOT;  // Daily vertical lines style
input color           InpVLineColor  =  clrYellow;         // Daily vertical lines color

//--- global variables
string obj_name_prefix = "5days_";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, obj_name_prefix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   ENUM_TIMEFRAMES P = Period();
   if(P > PERIOD_D1)
      return(0);

//--- define indexing direction as timeseries
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(low, true);

//--- if timeseries is loaded or a new bar is added
   if(rates_total > prev_calculated)
     {
      int cnt = MathMin(rates_total, PeriodSeconds(PERIOD_D1)/PeriodSeconds(P)*InpMaxDays);

      for(int i=0; i < cnt; i++)
        {
         if(TimeDayOfWeek(time[i]) != TimeDayOfWeek(time[i+1]))
           {
            string wkday = EnumToString((ENUM_DAY_OF_WEEK)TimeDayOfWeek(time[i]));
            string name = obj_name_prefix + wkday + "_" + TimeToString(time[i]);

            VLineCreate(name,time[i],InpVLineColor,InpVLineStyle);
            TextCreate(name+"_lbl",wkday,time[i],low[i]-50*_Point,InpVLineColor);
           }
        }
     }

//--- return value of prev_calculated for next call
   return (rates_total);
  }
//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
void VLineCreate(string name, datetime time, color clr, ENUM_LINE_STYLE style=STYLE_SOLID, int width=1)
  {
   ObjectCreate(0,name,OBJ_VLINE,0,time,0);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
  }
//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
void TextCreate(string name, string text, datetime time, double price, color clr=clrWhiteSmoke)
  {
   ObjectCreate(0,name,OBJ_TEXT,0,time,price);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetDouble(0,name,OBJPROP_ANGLE,0.00);
   ObjectSetString(0,name,OBJPROP_FONT,"Lucida Console");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
  }
//+------------------------------------------------------------------+
//| Day of the week as integer (0-Sunday, 1-Monday, ... ,6-Saturday) |
//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime t)
  {
   MqlDateTime st;
   TimeToStruct(t, st);
   return(st.day_of_week);
  }
//+------------------------------------------------------------------+
