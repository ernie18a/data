//+------------------------------------------------------------------+
//|                                    Session Liquidity Map MT5.mq5 |
//|                                         Copyright 2026, Shahrukh |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Shahrukh"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Broker time session boxes with confirmed highs, lows and ranges."
#property indicator_chart_window
#property indicator_plots 0
#property indicator_buffers 0

input group "Session Times in Broker Time"
input bool   InpShowAsianSession   = true;
input string InpAsianStart         = "00:00";
input string InpAsianEnd           = "08:00";
input bool   InpShowLondonSession  = true;
input string InpLondonStart        = "08:00";
input string InpLondonEnd          = "13:00";
input bool   InpShowNewYorkSession = true;
input string InpNewYorkStart       = "13:00";
input string InpNewYorkEnd         = "21:00";

input group "History and Display"
input int    InpLookbackDays       = 5;
input bool   InpShowRangeText      = true;
input bool   InpExtendHighLow      = true;
input int    InpExtendBars         = 30;
input color  InpAsianColor         = clrAliceBlue;
input color  InpLondonColor        = clrHoneydew;
input color  InpNewYorkColor       = clrMistyRose;
input uchar  InpTransparency       = 45;

string   g_prefix="SLMAP_";
datetime g_last_bar=0;

//+------------------------------------------------------------------+
bool ParseClock(const string value,int &hour,int &minute)
  {
   string parts[];
   if(StringSplit(value,':',parts)!=2)
      return(false);
   hour=(int)StringToInteger(parts[0]);
   minute=(int)StringToInteger(parts[1]);
   return(hour>=0 && hour<=23 && minute>=0 && minute<=59);
  }

//+------------------------------------------------------------------+
datetime DayStart(const datetime source)
  {
   MqlDateTime data;
   TimeToStruct(source,data);
   data.hour=0;
   data.min=0;
   data.sec=0;
   return(StructToTime(data));
  }

//+------------------------------------------------------------------+
datetime SessionTime(const datetime midnight,const string clock)
  {
   int hour=0,minute=0;
   if(!ParseClock(clock,hour,minute))
      return(0);
   return(midnight+(datetime)(hour*3600+minute*60));
  }

//+------------------------------------------------------------------+
bool GetSessionRange(const datetime start_time,const datetime end_time,
                     double &session_high,double &session_low)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates,false);
   int copied=CopyRates(_Symbol,_Period,start_time,end_time,rates);
   if(copied<=0)
      return(false);

   session_high=rates[0].high;
   session_low=rates[0].low;
   for(int index=1; index<copied; index++)
     {
      if(rates[index].high>session_high) session_high=rates[index].high;
      if(rates[index].low<session_low) session_low=rates[index].low;
     }
   return(true);
  }

//+------------------------------------------------------------------+
void DrawHorizontalSegment(const string name,const datetime start_time,
                           const datetime end_time,const double price,
                           const color line_color)
  {
   if(!ObjectCreate(0,name,OBJ_TREND,0,start_time,price,end_time,price))
      return;
   ObjectSetInteger(0,name,OBJPROP_COLOR,line_color);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
void DrawSession(const string session_name,const string object_id,
                 datetime start_time,datetime end_time,const color session_color)
  {
   datetime now=TimeCurrent();
   if(start_time==0 || end_time==0 || start_time>now)
      return;

   if(end_time<=start_time)
      end_time+=86400;

   const datetime measured_end=(end_time<now ? end_time : now);
   double session_high=0.0,session_low=0.0;
   if(!GetSessionRange(start_time,measured_end,session_high,session_low))
      return;

   const string box_name=g_prefix+"BOX_"+object_id;
   if(ObjectCreate(0,box_name,OBJ_RECTANGLE,0,start_time,session_high,measured_end,session_low))
     {
      ObjectSetInteger(0,box_name,OBJPROP_COLOR,ColorToARGB(session_color,InpTransparency));
      ObjectSetInteger(0,box_name,OBJPROP_FILL,true);
      ObjectSetInteger(0,box_name,OBJPROP_BACK,true);
      ObjectSetInteger(0,box_name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,box_name,OBJPROP_HIDDEN,true);
     }

   const int seconds=PeriodSeconds(_Period);
   const int bar_seconds=(seconds>0 ? seconds : 60);
   datetime line_end=measured_end;
   if(InpExtendHighLow)
      line_end=measured_end+(datetime)(bar_seconds*InpExtendBars);

   DrawHorizontalSegment(g_prefix+"HIGH_"+object_id,start_time,line_end,session_high,session_color);
   DrawHorizontalSegment(g_prefix+"LOW_"+object_id,start_time,line_end,session_low,session_color);

   if(InpShowRangeText)
     {
      const string text_name=g_prefix+"TEXT_"+object_id;
      if(ObjectCreate(0,text_name,OBJ_TEXT,0,start_time,session_high))
        {
         const double range_points=(session_high-session_low)/_Point;
         ObjectSetString(0,text_name,OBJPROP_TEXT,
                         StringFormat("%s  %.0f points",session_name,range_points));
         ObjectSetString(0,text_name,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,text_name,OBJPROP_FONTSIZE,8);
         ObjectSetInteger(0,text_name,OBJPROP_COLOR,session_color);
         ObjectSetInteger(0,text_name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
         ObjectSetInteger(0,text_name,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,text_name,OBJPROP_HIDDEN,true);
        }
     }
  }

//+------------------------------------------------------------------+
void BuildSessions()
  {
   ObjectsDeleteAll(0,g_prefix);
   const datetime today=DayStart(TimeCurrent());

   for(int day=InpLookbackDays-1; day>=0; day--)
     {
      const datetime midnight=today-(datetime)(day*86400);
      const string date_id=TimeToString(midnight,TIME_DATE);

      if(InpShowAsianSession)
         DrawSession("Asia",date_id+"_ASIA",SessionTime(midnight,InpAsianStart),
                     SessionTime(midnight,InpAsianEnd),InpAsianColor);
      if(InpShowLondonSession)
         DrawSession("London",date_id+"_LONDON",SessionTime(midnight,InpLondonStart),
                     SessionTime(midnight,InpLondonEnd),InpLondonColor);
      if(InpShowNewYorkSession)
         DrawSession("New York",date_id+"_NEWYORK",SessionTime(midnight,InpNewYorkStart),
                     SessionTime(midnight,InpNewYorkEnd),InpNewYorkColor);
     }
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   int hour=0,minute=0;
   if(InpLookbackDays<1 || InpLookbackDays>60 || InpExtendBars<0 ||
      !ParseClock(InpAsianStart,hour,minute) || !ParseClock(InpAsianEnd,hour,minute) ||
      !ParseClock(InpLondonStart,hour,minute) || !ParseClock(InpLondonEnd,hour,minute) ||
      !ParseClock(InpNewYorkStart,hour,minute) || !ParseClock(InpNewYorkEnd,hour,minute))
     {
      Print("Invalid session settings. Use HH:MM broker time values.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME,"Session Liquidity Map");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,g_prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  {
   if(rates_total<10)
      return(0);

   if(time[0]!=g_last_bar || prev_calculated==0)
     {
      g_last_bar=time[0];
      BuildSessions();
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
