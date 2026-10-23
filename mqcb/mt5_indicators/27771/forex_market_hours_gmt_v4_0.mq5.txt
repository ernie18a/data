//+------------------------------------------------------------------+
//|                                  Forex_Market_Hours_GMT_v4.0.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "4.000"
#property description   "The indicator assumes local \"wall clock\" trading hours of 8:00 AM - 5:00 PM in "
#property description   "each Forex market, except in Tokyo it is 9:00 AM - 6:00 PM."
//---
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 0
//+------------------------------------------------------------------+
#include <Generic\HashMap.mqh>
//+------------------------------------------------------------------+
//--- Daylight Saving Time
enum ENUM_DST_TIMEZONE
  {
   DST_TIMEZONE_USA,              // USA summer time (DST)
   DST_TIMEZONE_EU                // Europe summer time (DST)
  };
enum ENUM_PANEL_TIMEMODE
  {
   PANEL_TIMEMODE_GMT,            // GMT
   PANEL_TIMEMODE_TRADESERVER,    // Server time (ST)
   PANEL_TIMEMODE_LOCAL           // Local time (LT)
  };
//+------------------------------------------------------------------+
//--- input variables
input int            Shift_Horz   = 220;              // Horizontal shift
input int            Shift_Vert   = 20;               // Vertical shift
input int            ZoomLevel    = 125;              // Panel zoom level (%)
input color          PanelColor   = clrDarkSlateGray; // Panel background color
input color          SydneyColor  = clrDeepSkyBlue;   // Sydney color
input color          TokyoColor   = clrMagenta;       // Tokyo color
input color          FrankColor   = clrMediumBlue;    // Frankfurt color
input color          LondonColor  = clrLimeGreen;     // London color
input color          NewYorkColor = C'207,0,0';       // New York color
input bool           ShowCalendar = false;            // Show economic calendar events
input ENUM_CALENDAR_EVENT_IMPORTANCE importance = CALENDAR_IMPORTANCE_MODERATE;  // Event importance >=
input ENUM_PANEL_TIMEMODE PanelTimeMode = 0;          // Panel time mode
input ENUM_DST_TIMEZONE   DstTimeZone   = 0;          // DST setting on the sever:
//+------------------------------------------------------------------+
//--- global variables
string obj_name_prefix="MarketHours_";
bool bServerSummerTime=0;
datetime ServerLastCheckTime=0;
datetime PanelLastUpdateTime=0;
datetime CalendarLastUpdateTime=0;
double ZoomFactor=0.0;
long GMTOffset=0;
//+------------------------------------------------------------------+
//--- indicator buffer
double buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Set the indicator properties
   SetIndexBuffer(0,buffer,INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME,"Forex Market Hours");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- Check summer time (DST) on the trade server
   bool check_result=IsServerSummerTime();
//--- Store result of the check into a global variable
   bServerSummerTime=check_result;
//--- Save the time of the last server check
   ServerLastCheckTime=TimeGMT();
//--- Recalculate the panel zoom factor
   ZoomFactor=ZoomLevel/100.0;
//--- Calculate the GMT offset in seconds
   if(PanelTimeMode==PANEL_TIMEMODE_TRADESERVER)
      GMTOffset=TimeTradeServer()-TimeGMT();
   if(PanelTimeMode==PANEL_TIMEMODE_LOCAL)
      GMTOffset=TimeLocal()-TimeGMT();
//--- Draw the forex market hours panel
   FuncDrawMarketHoursPanel();
//--- Update the clock and move the timer bar
   FuncUpdateThePanelClock();
//--- Draw the economic calendar markers
   if(ShowCalendar)
     {
      FuncUpdateEconomicCalendar();
      CalendarLastUpdateTime=TimeGMT()-10;
     }
//--- Initialization completed successfully
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,obj_name_prefix);
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
//--- Check the broker's DST once every 60 seconds
   if(TimeGMT()>ServerLastCheckTime+60)
     {
      //--- Detect state transition of the trade server time
      bool check_result=IsServerSummerTime();

      //--- The trade server switched to summer time (DST).
      if(check_result && !bServerSummerTime)
        {
         //--- Store result of the check into a global variable
         bServerSummerTime = 1;
         //--- Draw the forex market hours panel
         FuncDrawMarketHoursPanel();
        }

      //--- The trade server reverted to winter (standard) time.
      if(!check_result && bServerSummerTime)
        {
         //--- Store result of the check into a global variable
         bServerSummerTime = 0;
         //--- Draw the forex market hours panel
         FuncDrawMarketHoursPanel();
        }

      //--- Save the time of the last server check
      ServerLastCheckTime=TimeGMT();
     }

//--- Update the panel no more than once every second
   if(TimeGMT()>PanelLastUpdateTime)
     {
      //--- Update the clock and move the timer bar
      FuncUpdateThePanelClock();
      //--- Save the last update time of the panel
      PanelLastUpdateTime=TimeGMT();
     }

   if(ShowCalendar)
     {
      datetime Time=0;

      if(PanelTimeMode==PANEL_TIMEMODE_TRADESERVER)
         Time = TimeTradeServer();
      if(PanelTimeMode==PANEL_TIMEMODE_LOCAL)
         Time = TimeLocal();
      if(PanelTimeMode==PANEL_TIMEMODE_GMT)
         Time = TimeGMT();

      //--- extract the date part from current time
      datetime Date = Time - Time % 86400;

      //--- Update the economic calendar on the start of a new day
      if(Date>CalendarLastUpdateTime)
        {
         //--- Update the economic calendar markers
         FuncUpdateEconomicCalendar();

         //--- Save the last update time of the calendar
         CalendarLastUpdateTime=Date;
        }
     }

//---
   buffer[0]=-1;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnTimer function                                                 |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
  }
//+------------------------------------------------------------------+
//| Function for drawing the forex market hours panel                |
//+------------------------------------------------------------------+
void FuncDrawMarketHoursPanel()
  {
   string obj_name, text;
   int x_, y_, width, height;
   color Color;
//--- create the main panel
   obj_name = obj_name_prefix+"MainPanel";
   x_       = Shift_Horz + 0;
   y_       = Shift_Vert + 0;
   width    = (int)MathFloor(ZoomFactor * 390);
   height   = (int)MathFloor(ZoomFactor * (ShowCalendar ? 122 : 116));
   Color    = PanelColor;
//---
   if(!RectLabelCreate(0,obj_name,0,x_,y_,width,height,Color,BORDER_RAISED,CORNER_LEFT_UPPER,clrBlack,STYLE_SOLID,2))
      return;

   if(!DrawPanelGridLabels())
      return;

   if(!DrawForexSessionsLabels())
      return;

   if(!DrawTimeHoursLabels())
      return;

   if(!DrawTimerBarAndLabel())
      return;

//--- redraw the chart
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Create text labels of the panel grid on the chart                |
//+------------------------------------------------------------------+
bool DrawPanelGridLabels()
  {
   string obj_name, text;
   int x_, y_;
   color Color;
//--- create horizontal "_" grid text labels on the chart
   for(int x=12; x<=366; x+=6)
      for(int y=8; y<=78; y+=14)
        {
         obj_name = obj_name_prefix+"Horiz_"+(string)x+","+(string)y;
         x_       = (int)MathFloor(Shift_Horz + x * ZoomFactor);
         y_       = (int)MathFloor(Shift_Vert + y * ZoomFactor);
         text     = "_";
         Color    = clrGainsboro;
         //---
         if(!LabelCreate(0,obj_name,0,x_,y_,CORNER_LEFT_UPPER,text,"Times New Roman",(int)MathFloor(10*ZoomFactor),Color))
           {
            return(false);
           }
        }
//--- create vertical "|" grid text labels on the chart
   for(int x=12; x<=372; x+=15)
      for(int y=20; y<=80; y+=12)
        {
         obj_name = obj_name_prefix+"Vert_"+(string)x+","+(string)y;
         x_       = Shift_Horz + (int)MathFloor(x * ZoomFactor);
         y_       = Shift_Vert + (int)MathFloor(y * ZoomFactor);
         text     = "|";
         Color    = clrSilver;
         //---
         if(!LabelCreate(0,obj_name,0,x_,y_,CORNER_LEFT_UPPER,text,"Times New Roman",(int)MathFloor(10*ZoomFactor),Color))
           {
            return(false);
           }
        }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create colored rectangle labels for forex sessions               |
//+------------------------------------------------------------------+
bool DrawForexSessionsLabels()
  {
   string obj_name, text;
   int x_, y_;
   int width, height;
   color Color;
//---
// https://www.forexmarkethours.com/
// https://www.forexmarkethours.com/GMT_hours/02/
// http://forex.timezoneconverter.com/
// Forex market hours        GMT +2          GMT
//   int     SydneyOpen     = 0;              22; // + Pacific
//   int     SydneyClose    = 9;              7;
//   int     TokyoOpen      = 2;              0;  // + Asia
//   int     TokyoClose     = 11;             9;
//   int     FrankfurtOpen  = 9;              7;
//   int     FrankfurtClose = 18;             16;
//   int     LondonOpen     = 10;             8;
//   int     LondonClose    = 19;             17;
//   int     NewYorkOpen    = 15;             13;
//   int     NewYorkClose   = 0;              22;
//---
   string session_bar_names[]= {"Sydney_BarL","Sydney_BarR","Tokyo_Bar","Frank_Bar","London_Bar","NewYork_Bar"};
   int session_bar_x_dist[]= {13,343,13,118,133,208};
   int session_bar_x_size[]= {105,30,135,135,135,135};
   int session_bar_y_dist[]= {23,23,37,51,65,79};
   int session_label_x_dist[]= {20,39,147,165,234};
   string session_label_text[]= {"Sydney (GMT)","Tokyo (GMT)","Frankfurt (GMT)","London (GMT)","New York (GMT)"};
//---
   color session_bar_colors[6];
   session_bar_colors[0]=SydneyColor;
   session_bar_colors[1]=SydneyColor;
   session_bar_colors[2]=TokyoColor;
   session_bar_colors[3]=FrankColor;
   session_bar_colors[4]=LondonColor;
   session_bar_colors[5]=NewYorkColor;
//--- Simple hack!
   if(bServerSummerTime)
     {
      //--- decrease all sessions 1 hour except Tokyo session
      int summer_x_dist[]= {13,328,13,103,118,193};
      int summer_x_size[]= {90,45,135,135,135,135};
      int summer_label_x_dist[]= {20,39,132,150,219};
      ArrayCopy(session_bar_x_dist,summer_x_dist);
      ArrayCopy(session_bar_x_size,summer_x_size);
      ArrayCopy(session_label_x_dist,summer_label_x_dist);
     }
//---
   if(PanelTimeMode==PANEL_TIMEMODE_TRADESERVER)
     {
      string temp[]= {"Sydney (ST)","Tokyo (ST)","Frankfurt (ST)","London (ST)","New York (ST)"};
      ArrayCopy(session_label_text,temp);
     }
   if(PanelTimeMode==PANEL_TIMEMODE_LOCAL)
     {
      string temp[]= {"Sydney (LT)","Tokyo (LT)","Frankfurt (LT)","London (LT)","New York (LT)"};
      ArrayCopy(session_label_text,temp);
     }
//---
   for(int i=0; i<ArraySize(session_bar_names); i++)
     {
      obj_name = obj_name_prefix+session_bar_names[i];
      x_       = Shift_Horz + (int)MathFloor(session_bar_x_dist[i] * ZoomFactor);
      y_       = Shift_Vert + (int)MathFloor(session_bar_y_dist[i] * ZoomFactor);
      width    = (int)MathFloor(session_bar_x_size[i] * ZoomFactor);
      height   = (int)MathFloor(13 * ZoomFactor);
      Color    = session_bar_colors[i];
      //---
      if(!RectLabelCreate(0,obj_name,0,x_,y_,width,height,Color,BORDER_SUNKEN,CORNER_LEFT_UPPER,clrBlack,STYLE_SOLID,2))
        {
         return(false);
        }
     }
//---
   for(int y=22,i=0; y<=78; y+=14,i++)
     {
      obj_name = obj_name_prefix+"session_Label"+(string)i;
      x_       = Shift_Horz + (int)MathFloor(session_label_x_dist[i] * ZoomFactor);
      y_       = Shift_Vert + (int)MathFloor(y * ZoomFactor);
      text     = session_label_text[i];
      Color    = clrWhite;
      //---
      if(!LabelCreate(0,obj_name,0,x_,y_,CORNER_LEFT_UPPER,text,"Tahoma",(int)MathFloor(9*ZoomFactor),Color))
        {
         return(false);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create text labels for time hours and summer time label          |
//+------------------------------------------------------------------+
bool DrawTimeHoursLabels()
  {
   string obj_name, text;
   int x_, y_, hour;
   color Color;
   int GMTOffsetInHours=(int)MathRound(GMTOffset/3600.);
//--- create text labels on the chart (time hours 0 1 2 3 4 ...)
   for(int x=10,i=0; x<=355; x+=15,i++)
     {
      obj_name = obj_name_prefix+"time_hour_"+(string)i;
      x_       = Shift_Horz + (int)MathFloor(x * ZoomFactor);
      y_       = Shift_Vert + (int)MathFloor(5 * ZoomFactor);
      hour     = ((i+GMTOffsetInHours) % 24 + 24) % 24;
      text     = (string)hour;
      Color    = clrGainsboro;
      //--- adjust hour labels above 9 GMT
      if(hour>9)
         x_-=(int)MathFloor(3 * ZoomFactor);
      //---
      if(!LabelCreate(0,obj_name,0,x_,y_,CORNER_LEFT_UPPER,text,"Times New Roman",(int)MathFloor(8*ZoomFactor),Color))
        {
         return(false);
        }
     }
//--- create a text label on the chart (Winter/Summer)
   obj_name = obj_name_prefix+"time_summer";
   x_       = Shift_Horz + (int)MathFloor(371 * ZoomFactor);
   y_       = Shift_Vert + (int)MathFloor(5 * ZoomFactor);
   text     = (bServerSummerTime) ? "S" : "W";
   Color    = (bServerSummerTime) ? clrYellow : clrTurquoise;
//---
   if(!LabelCreate(0,obj_name,0,x_,y_,CORNER_LEFT_UPPER,text,"Times New Roman",(int)MathFloor(10*ZoomFactor),Color))
     {
      return(false);
     }
   else
     {
      string tooltip = (bServerSummerTime ? "Summer" : "Winter") + " time on the trade server";
      ObjectSetString(0,obj_name,OBJPROP_TOOLTIP,tooltip);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create vertical bar + text label for the clock timer             |
//+------------------------------------------------------------------+
bool DrawTimerBarAndLabel()
  {
   string obj_name, text;
   int x_, y_;
   int width, height;
   color Color;
//--- create a rectangle label on the chart (timer bar)
   obj_name = obj_name_prefix+"timer_bar";
   x_       = Shift_Horz + (int)MathFloor(12 * ZoomFactor);
   y_       = Shift_Vert + (int)MathFloor(20 * ZoomFactor);
   width    = (int)MathFloor(3 * ZoomFactor);
   height   = (int)MathFloor(76 * ZoomFactor);
   Color    = clrRed;
//---
   if(!RectLabelCreate(0,obj_name,0,x_,y_,width,height,Color,BORDER_RAISED,CORNER_LEFT_UPPER,Color,STYLE_SOLID,2))
     {
      return(false);
     }
//--- create a text label on the chart (timer clock)
   obj_name = obj_name_prefix+"timer_clock";
   x_       = Shift_Horz + (int)MathFloor(ZoomFactor * 8);
   y_       = Shift_Vert + (int)MathFloor(ZoomFactor * (ShowCalendar ? 107 : 98));
   text     = TimeToString(TimeGMT()+GMTOffset,TIME_SECONDS);
   Color    = clrGainsboro;
//---
   if(!LabelCreate(0,obj_name,0,x_,y_,CORNER_LEFT_UPPER,text,"Times New Roman",(int)MathFloor(8*ZoomFactor),Color))
     {
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Function for updating the forex market hours panel               |
//+------------------------------------------------------------------+
void FuncUpdateThePanelClock()
  {
   string obj_name, text;
   int x_, y_;
   int shift;
//--- update position of the vertical timer bar with time
   obj_name = obj_name_prefix+"timer_bar";
   x_       = Shift_Horz + (int)MathFloor(12 * ZoomFactor);
   y_       = Shift_Vert + (int)MathFloor(20 * ZoomFactor);
   shift    = (int)(TimeGMT() % 86400 * (int)MathFloor(360 * ZoomFactor) / 86400);
   RectLabelMove(0,obj_name,(shift + x_), y_);

//--- change and move the clock timer label with time
   obj_name = obj_name_prefix+"timer_clock";
   x_       = Shift_Horz + (int)MathFloor(ZoomFactor * 8);
   y_       = Shift_Vert + (int)MathFloor(ZoomFactor * (ShowCalendar ? 107 : 98));
   shift    = (int) MathMin(shift,(int)MathFloor(330 * ZoomFactor));
   text     = TimeToString(TimeGMT()+GMTOffset,TIME_SECONDS);
   LabelMove(0,obj_name,(shift + x_), y_);
   LabelTextChange(0,obj_name,text);

//--- redraw the chart
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Function for updating the economic calendar markers              |
//+------------------------------------------------------------------+
bool FuncUpdateEconomicCalendar()
  {
//--- delete old economic calendar markers, if any.
   ObjectsDeleteAll(0,obj_name_prefix+"CalendarEvent_");

//--- set the boundaries of the interval we take the events from
   datetime time=0;

   if(PanelTimeMode==PANEL_TIMEMODE_TRADESERVER)
      time = TimeTradeServer();
   if(PanelTimeMode==PANEL_TIMEMODE_LOCAL)
      time = TimeLocal();
   if(PanelTimeMode==PANEL_TIMEMODE_GMT)
      time = TimeGMT();

   datetime from_date= time - time % 86400;  // start time of the current day
   datetime to_date= from_date + 86400;      // end time of the current day

//--- convert the time inputs to trade server timezone for working with the economic calendar
   datetime SourceTimeZoneTime=time;
   datetime DestinationTimeZoneTime=TimeTradeServer();

   if(from_date>0)
      from_date=ConvertTime(from_date,SourceTimeZoneTime,DestinationTimeZoneTime);
   if(to_date>0)
      to_date=ConvertTime(to_date,SourceTimeZoneTime,DestinationTimeZoneTime);

//--- request the events history for the specified period with the ability to sort by country and/or currency.
   MqlCalendarValue values[];
   if(!CalendarValueHistory(values,from_date,to_date,NULL,NULL))
     {
      Print("Failed to receive calendar events, error ",GetLastError());
      return(false);
     }

//--- define a hash map to track overlapping of graphic objects
   CHashMap<datetime,ENUM_CALENDAR_EVENT_IMPORTANCE>HashMap;

   string obj_name, tooltip;
   int x_, y_, width, height;
   int shift;
   color Color;
   datetime gmtTime;

//--- create rectangle labels on the chart (economic calendar markers)
   for(int i = 0; i<ArraySize(values); i++)
     {
      MqlCalendarEvent event;
      MqlCalendarCountry country;
      if(CalendarEventById(values[i].event_id,event) && CalendarCountryById(event.country_id,country))
        {
         if(event.importance>=importance)
           {
            //--- update the hash map of graphic objects
            if(!HashMap.Add(values[i].time,event.importance))
              {
               ENUM_CALENDAR_EVENT_IMPORTANCE imp=-1;
               HashMap.TryGetValue(values[i].time,imp);
               if(event.importance<=imp)
                  continue;
               HashMap.TrySetValue(values[i].time,event.importance);
              }
            //---
            obj_name = obj_name_prefix+"CalendarEvent_"+(string)values[i].event_id;
            x_       = Shift_Horz + (int)MathFloor(10 * ZoomFactor);
            y_       = Shift_Vert + (int)MathFloor(98 * ZoomFactor);
            gmtTime  = ConvertTime(values[i].time,DestinationTimeZoneTime,TimeGMT());
            shift    = (int)(gmtTime % 86400 * (int)MathFloor(360 * ZoomFactor) / 86400);
            width    = (int)MathFloor(7 * ZoomFactor);
            height   = (int)MathFloor(7 * ZoomFactor);
            Color    = clrGainsboro;
            //---
            if(event.importance==CALENDAR_IMPORTANCE_MODERATE)
               Color=clrOrange;
            if(event.importance==CALENDAR_IMPORTANCE_HIGH)
               Color=clrCrimson;
            //---
            if(!RectLabelCreate(0,obj_name,0,(shift + x_),y_,width,height,Color,BORDER_FLAT,CORNER_LEFT_UPPER,Color,STYLE_SOLID,1))
              {
               return(false);
              }
            else
              {
               //--- convert economic calendar times from trade server timezone to the current panel timezone
               time = ConvertTime(values[i].time,DestinationTimeZoneTime,SourceTimeZoneTime);
               //PrintFormat("%s %s \"%s\" %s",TimeToString(time),country.currency,event.name,EnumToString(event.importance));
               tooltip = StringFormat("[%s] %s -> %s",TimeToString(time,TIME_MINUTES),country.currency,event.name);
               ObjectSetString(0,obj_name,OBJPROP_TOOLTIP,tooltip);
              }
           }
        }
      else
         PrintFormat("Failed to get event description for event_d=%s, error %d",
                     values[i].event_id,GetLastError());
     }

//--- redraw the chart
   ChartRedraw();
   return(true);
  }
//+------------------------------------------------------------------+
//| Converts a time from one time zone to another.                   |
//+------------------------------------------------------------------+
datetime ConvertTime(datetime dateTime, datetime sourceTimeZoneTime, datetime destinationTimeZoneTime)
  {
//--- calculate the destination timezone offset in seconds
   long TimeZoneOffset = destinationTimeZoneTime - sourceTimeZoneTime;

   return(dateTime + (int)TimeZoneOffset);
  }
//+------------------------------------------------------------------+
//| Check summer time (DST) on the trade server                      |
//+------------------------------------------------------------------+
bool IsServerSummerTime()
  {
   MqlDateTime dt_struct;
   datetime dst_start,dst_end,tm;
   dst_start=dst_end=0;
   tm=TimeTradeServer(dt_struct);
//---
   if(DstTimeZone==DST_TIMEZONE_EU)
      DST_Europe(dt_struct.year,dst_start,dst_end);
   else
      DST_USA(dt_struct.year,dst_start,dst_end);
//---
   return(tm>=dst_start && tm<dst_end);
  }
//+------------------------------------------------------------------+
//| Compute the daylight saving time changes in London, UK           |
//| Validated to https://www.timeanddate.com/time/change/uk/london   |
//+------------------------------------------------------------------+
void DST_Europe(int iYear, datetime &dst_start, datetime &dst_end)
  {
   datetime dt1,dt2;
   MqlDateTime st1,st2;
   /* UK DST begins at 01:00 local time on the last Sunday of March
      and ends at 02:00 local time on the last Sunday of October */
   dt1=StringToTime((string)iYear+".03.31 01:00");
   dt2=StringToTime((string)iYear+".10.31 02:00");
   TimeToStruct(dt1,st1);
   TimeToStruct(dt2,st2);
   dst_start=dt1-(st1.day_of_week*86400);
   dst_end  =dt2-(st2.day_of_week*86400);
  }
//+------------------------------------------------------------------+
//| Compute the daylight saving time changes in New York, USA        |
//| Validated to https://www.timeanddate.com/time/change/usa/new-york|
//+------------------------------------------------------------------+
void DST_USA(int iYear, datetime &dst_start, datetime &dst_end)
  {
   datetime dt1,dt2;
   MqlDateTime st1,st2;
   /* US DST begins at 02:00 local time on the second Sunday of March
      and ends at 02:00 local time on the first Sunday of November */
   dt1=StringToTime((string)iYear+".03.14 02:00");
   dt2=StringToTime((string)iYear+".11.07 02:00");
   TimeToStruct(dt1,st1);
   TimeToStruct(dt2,st2);
   dst_start=dt1-(st1.day_of_week*86400);
   dst_end  =dt2-(st2.day_of_week*86400);
  }
//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move rectangle label                                             |
//+------------------------------------------------------------------+
bool RectLabelMove(const long   chart_ID=0,       // chart's ID
                   const string name="RectLabel", // label name
                   const int    x=0,              // X coordinate
                   const int    y=0)              // Y coordinate
  {
//--- reset the error value
   ResetLastError();
//--- move the rectangle label
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the label! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move the text label                                              |
//+------------------------------------------------------------------+
bool LabelMove(const long   chart_ID=0,   // chart's ID
               const string name="Label", // label name
               const int    x=0,          // X coordinate
               const int    y=0)          // Y coordinate
  {
//--- reset the error value
   ResetLastError();
//--- move the text label
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the label! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the label text                                            |
//+------------------------------------------------------------------+
bool LabelTextChange(const long   chart_ID=0,   // chart's ID
                     const string name="Label", // object name
                     const string text="Text")  // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
