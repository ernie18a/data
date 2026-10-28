//+------------------------------------------------------------------+
//|                                               iForexSessions.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.99"
#property description "Forex Sessions indicator"
#property description "Highlights the Forex Market Sessions"
#property description "The indicator assumes local \"wall clock\" trading hours of 8:00 AM - 5:00 PM in "
#property description "each Forex market, except in Sydney it is 7:00 AM - 4:00 PM or 9:00 AM - 6:00 PM."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#include <Canvas\Canvas.mqh>
#include "SessionHours.mqh"
//+------------------------------------------------------------------+
//--- input parameters
input int            InpNumDays       =  35;                // Number of days to display
input color          InpColorSydney   =  clrPurple;         // Sydney session color
input color          InpColorTokyo    =  clrTeal;           // Tokyo session color
input color          InpColorLondon   =  clrMaroon;         // London session color
input color          InpColorNewYork  =  clrDarkBlue;       // NewYork session color
input bool           InpShowLabels    =  true;              // Show session labels
input bool           InpShowVLines    =  true;              // Show sydney-session start lines
input bool           InpShowClock     =  true;              // Show broker's clock (left lower corner)
input bool           InpShowGrid      =  false;             // Show grid in the chart
input bool           InpUseGoldSymbol =  true;              // Load XAUUSD symbol for estimation of the server's TZ/DST
//+------------------------------------------------------------------+
//--- global variables
string obj_name_prefix=MQLInfoString(MQL_PROGRAM_NAME);
int WidthScreen;
int HeightScreen;
CCanvas canv;
bool canv_on=false;
bool ready_H1=false;
bool chart_grid;
enum ENUM_SESSIONS
  {
   SYD = 0,
   TOK = 1,
   LON = 2,
   NYC = 3
  };
struct SBrokerSession
  {
   datetime          BeginBroker;  // session time begin in broker time
   datetime          EndBroker;    // session time end in broker time
  };
SBrokerSession Sessions[][4];      // 2d array of 4 sessions for n days
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()>PERIOD_H4)
     {
      Alert("This indicator works only on H4 charts and lower");
     }
//--- timer
   if(InpShowClock)
     {
      EventSetTimer(1);
     }
//--- remember chart grid flag
   ChartGetInteger(0,CHART_SHOW_GRID,chart_grid);
//--- set chart grid flag
   ChartSetInteger(0,CHART_SHOW_GRID,InpShowGrid);
   ChartRedraw();
//--- create canvas to output debug info
   WidthScreen =(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   HeightScreen=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   ChartSetInteger(0,CHART_FOREGROUND,false);
   if(!canv.CreateBitmapLabel(0,0,"Canvas07",0,0,WidthScreen,HeightScreen,COLOR_FORMAT_ARGB_NORMALIZE))
      Print("Error creating canvas: ",GetLastError());
   canv.FontSet("Courier New",18);
   canv.FontFlagsSet(FW_SEMIBOLD);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
//--- set the option of using Gold symbol for estimation of the server's TZ/DST
   CTimeZoneInfo::SetUsingGoldSymbol(InpUseGoldSymbol);
//--- Initialization completed successfully
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete timer
   EventKillTimer();
//--- delete canvas
   canv.Destroy();
//---- restore chart grid
   ChartSetInteger(0,CHART_SHOW_GRID,chart_grid);
//--- delete objects
   ObjectsDeleteAll(0,obj_name_prefix);
   ChartRedraw();
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
   ENUM_TIMEFRAMES P=Period();
   if(P > PERIOD_H4)
      return(0);
//--- make sure that H1 timeframe is loaded.
   datetime timeH1=iTime(NULL,PERIOD_H1,0);
   if(timeH1==0)
     {
      datetime times[];
      if(CopyTime(Symbol(),PERIOD_H1,time[0],1,times)<=0)
        {
         ChartSetSymbolPeriod(0,NULL,P); // emulate a tick
        }
      ready_H1=false;
      return(0);
     }
   ready_H1=true;
//--- draw only if a new hourly bar has arrived
   static datetime prevtime;
   if(timeH1 == prevtime)
      return(0);
   else
      prevtime=timeH1;
//---
   GetForexSessions(Sessions,InpNumDays);
   DrawSessions(Sessions);
   ChartRedraw();
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      if(ready_H1)
        {
         GetForexSessions(Sessions,InpNumDays);
         DrawSessions(Sessions);
         ChartRedraw();
        }
      WidthScreen =(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      HeightScreen=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      canv.Resize(WidthScreen,HeightScreen);
     }
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- moving the mouse on a chart while the "Ctrl" key is pressed
      if(TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL))
        {
         int      x     =(int)lparam;
         int      y     =(int)dparam;
         datetime time  =0;
         double   price =0;
         int      window=0;
         //--- convert the X and Y coordinates in terms of time/price
         if(ChartXYToTimePrice(0,x,y,window,time,price))
           {
            int i1=iBarShift(_Symbol,_Period,time);
            datetime bartime = iTime(_Symbol,_Period,i1);
            bool dst = CTimeZoneInfo::IsDaylightSavingsTime(ZONE_ID_BROKER, bartime);
            //---
            ChartTimePriceToXY(0,window,bartime,price,x,y);
            canv.Erase(0);
            canv.LineVertical(x,HeightScreen-1,0,ColorToARGB(clrRed));
            canv.TextOut(WidthScreen-600,HeightScreen-170,"bar #"+IntegerToString(i1),ColorToARGB(dst ? clrYellow: clrOrange));
            canv.TextOut(WidthScreen-600,HeightScreen-150,CTimeZoneInfo::FormatTimeForPlace(bartime, ZONE_ID_BROKER),ColorToARGB(dst ? clrYellow: clrOrange));
            //---
            ENUM_ZONE_ID ids[]= {ZONE_ID_SYDNEY, ZONE_ID_TOKYO, ZONE_ID_LONDON, ZONE_ID_NEWYORK};
            for(int i = 0; i < ArraySize(ids); i++)
              {
               ENUM_ZONE_ID id = ids[i];
               datetime converted = CTimeZoneInfo::ConvertTimeForPlace(bartime, ZONE_ID_BROKER, id);
               dst = CTimeZoneInfo::IsDaylightSavingsTime(id, converted);
               //PrintFormat("bar #%d | %s | %s", i1, CTimeZoneInfo::FormatTimeForPlace(bartime, ZONE_ID_BROKER), CTimeZoneInfo::FormatTimeForPlace(converted, id));
               canv.TextOut(WidthScreen-600,HeightScreen-130+i*20,CTimeZoneInfo::FormatTimeForPlace(converted, id),ColorToARGB(dst ? clrYellow: clrOrange));
              }
            canv.Update();
            canv_on=true;
           }
        }
      //--- moving the mouse on a chart while the "Ctrl" key is released
      else
         if(canv_on)
           {
            canv.Erase(0);
            canv.Update();
            canv_on=false;
           }
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdateBrokerClock();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Get forex market sessions for the specified num of days.         |
//+------------------------------------------------------------------+
int GetForexSessions(SBrokerSession &BrokerSessions[][4], int numDays=9)
  {
   ArrayFree(BrokerSessions);
   if(numDays <= 0)
      return(0);
   ArrayResize(BrokerSessions,numDays);
//--- Forex pairs start at 17:00 NY. Gold starts an hour later.
   string beginNYC = "17:00";
   if(StringSubstr(Symbol(),0,3)=="XAU"||StringSubstr(Symbol(),0,4)=="GOLD")
     {
      beginNYC = "18:00";
     }
   int day = 0;
   int bars = iBars(NULL,PERIOD_H1);
   for(int i = 0; i < bars; i++)
     {
      datetime bartime = iTime(NULL,PERIOD_H1,i);
      datetime tNYC = CTimeZoneInfo::ConvertTimeForPlace(bartime, ZONE_ID_BROKER, ZONE_ID_NEWYORK);
      if(TimeToString(tNYC,TIME_MINUTES) == beginNYC)  // find the H1 bar matching Fx opening in NY.
        {
         //--- server time corresponding to forex opening at 5 pm in New York (or 6 pm for gold)
         BrokerSessions[day][SYD].BeginBroker = bartime;
         BrokerSessions[day][SYD].EndBroker = bartime + 9*PeriodSeconds(PERIOD_H1);
         //--- set session hours to 8:00 am - 5:00 pm local time
         datetime beginlocal = StringToTime(TimeToString(tNYC+PeriodSeconds(PERIOD_D1), TIME_DATE) + " " + "08:00");
         datetime endlocal   = StringToTime(TimeToString(tNYC+PeriodSeconds(PERIOD_D1), TIME_DATE) + " " + "17:00");
         //--- conversion to broker time
         BrokerSessions[day][TOK].BeginBroker = CTimeZoneInfo::ConvertTimeForPlace(beginlocal, ZONE_ID_TOKYO, ZONE_ID_BROKER);
         BrokerSessions[day][TOK].EndBroker = CTimeZoneInfo::ConvertTimeForPlace(endlocal, ZONE_ID_TOKYO, ZONE_ID_BROKER);
         BrokerSessions[day][LON].BeginBroker = CTimeZoneInfo::ConvertTimeForPlace(beginlocal, ZONE_ID_LONDON, ZONE_ID_BROKER);
         BrokerSessions[day][LON].EndBroker = CTimeZoneInfo::ConvertTimeForPlace(endlocal, ZONE_ID_LONDON, ZONE_ID_BROKER);
         BrokerSessions[day][NYC].BeginBroker = CTimeZoneInfo::ConvertTimeForPlace(beginlocal, ZONE_ID_NEWYORK, ZONE_ID_BROKER);
         BrokerSessions[day][NYC].EndBroker = CTimeZoneInfo::ConvertTimeForPlace(endlocal, ZONE_ID_NEWYORK, ZONE_ID_BROKER);
         //---
         if(++day>=numDays)
            break;
        }
     }
   numDays = MathMin(numDays,day);
   ArrayResize(BrokerSessions,numDays);
// ArrayPrint(BrokerSessions);
//---
   return(numDays);
  }
//+------------------------------------------------------------------+
//| Create vertical lines and colored rectangles for forex sessions  |
//+------------------------------------------------------------------+
void DrawSessions(SBrokerSession &BrokerSessions[][4])
  {
   string obj_name, tooltip;
   datetime time1, time2;
   double price1, price2;
   color sColor;
   double high[];
   double dayhigh;
   bool weekstart;
//---
   string session_names[]= {"Sydney","Tokyo","London","NewYork"};
   string session_labels[]= {"SYD","TOK","LON","NYC"};
   color session_colors[4];
   session_colors[0]=InpColorSydney;
   session_colors[1]=InpColorTokyo;
   session_colors[2]=InpColorLondon;
   session_colors[3]=InpColorNewYork;
//--- find the highest and lowest values of the chart
   double max_price=ChartGetDouble(0,CHART_PRICE_MAX);
   double min_price=ChartGetDouble(0,CHART_PRICE_MIN);
   double height=(max_price-min_price)/70;
//--- delete objects
   ObjectsDeleteAll(0,obj_name_prefix);
//---
   for(int i = 0; i < ArrayRange(BrokerSessions, 0); i++)
     {
      if(InpShowVLines)
        {
         //--- Show sydney-session start lines
         time1     = BrokerSessions[i][SYD].BeginBroker;
         obj_name  = obj_name_prefix+":  "+CTimeZoneInfo::FormatTimeForPlace(time1, ZONE_ID_BROKER, false, false);
         weekstart = (i+1 < ArrayRange(BrokerSessions, 0)) && (time1 - BrokerSessions[i+1][SYD].BeginBroker > 24*3600);
         sColor    = weekstart ? clrDarkOrange : clrWheat;
         VLineCreate(obj_name,time1,sColor,STYLE_DASHDOTDOT);
         //--- Show day of week text label
         int shift = iBarShift(Symbol(),0,time1);
         double low = iLow(Symbol(),0,shift);
         string wkday = EnumToString((ENUM_DAY_OF_WEEK)(((uint)time1 / 86400 + 4) % 7));                  
         TextCreate(obj_name+"_wkday",wkday,time1,low-50*_Point,sColor);                               
        }
      int copied=CopyHigh(Symbol(),PERIOD_H1,BrokerSessions[i][SYD].BeginBroker,BrokerSessions[i][NYC].EndBroker,high);
      if(copied<=0)
         continue;
      dayhigh=high[ArrayMaximum(high)];
      for(int s = 0; s < ArraySize(session_names); s++)
        {
         obj_name = obj_name_prefix+session_names[s]+"Rect"+(string)i;
         time1    = BrokerSessions[i][s].BeginBroker;
         time2    = BrokerSessions[i][s].EndBroker;
         price1   = dayhigh + (height*1.3)*(4-s);
         price2   = price1 - height;
         sColor   = session_colors[s];
         tooltip  = session_names[s]+" session from "+TimeToString(time1,TIME_MINUTES)+" to "+TimeToString(time2,TIME_MINUTES)+" (server time)";
         RectangleCreate(obj_name,time1,price1,time2,price2,sColor,tooltip);
         //---
         if(InpShowLabels)
           {
            obj_name = obj_name_prefix+session_names[s]+"Text"+(string)i;
            tooltip  = session_labels[s]+" "+TimeToString(time1,TIME_MINUTES);
            TextCreate(obj_name,tooltip,time1,price1-(height/2),clrWheat);
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateBrokerClock()
  {
   string obj_name, text;
   int x_, y_;
   color sColor;
//---
   int sec = CSessionHours::SecRemainingForex();
   datetime forexCloseTime = CSessionHours::ForexCloseTime();
   int shiftInSeconds = CheckTimeSync();
//---
   string brokers_labels[4][2] =
     {
        {"Server Time   : ", CTimeZoneInfo::FormatTimeForPlace(TimeTradeServer(), ZONE_ID_BROKER)},
        {"Closing Time  : ", CTimeZoneInfo::FormatTimeForPlace(forexCloseTime, ZONE_ID_BROKER)},
        {"Remaining sec : ", StringFormat("%i sec =  %s %s", sec, CSessionHours::SecondsToString(sec), sec ? sec >= 7200 ? "" : "  (closing soon)" : "  (market closed)")},
        {"PC Time sync  : ", shiftInSeconds < 30 ? "Ok" : StringFormat("Shift of pc time is %i sec - Check www.time.is", shiftInSeconds)}
     };
//---
   for(int i = 0; i < ArrayRange(brokers_labels,0); i++)
      for(int j = 0; j < ArrayRange(brokers_labels,1); j++)
        {
         obj_name = obj_name_prefix+"BrokerLabel_"+(string)(i+4*j);
         text     = brokers_labels[i][j];
         x_       = 12+112*j;
         y_       = 72-14*i;
         sColor   = sec != 0 ? clrWheat : clrDarkGray;
         LabelCreate(obj_name,text,x_,y_,sColor);
        }
  }
//+------------------------------------------------------------------+
//| Check the time synchronization of the local computer.            |
//+------------------------------------------------------------------+
int CheckTimeSync()
  {
   static datetime current, before;
   static int shiftInSeconds = 0;
   before = current;
   current = TimeCurrent();
//--- if it is the first call of the function
   if(before == 0)
      return(0);
//--- if the server is not "frozen" due to weekends/holidays
   if(current != before)
     {
      shiftInSeconds = (int)(TimeTradeServer() - current);
     }
   return(shiftInSeconds);
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
//| Create rectangle by the given coordinates                        |
//+------------------------------------------------------------------+
void RectangleCreate(string name, datetime time1, double price1, datetime time2, double price2, color clr, string tooltip)
  {
   ObjectCreate(0,name,OBJ_RECTANGLE,0,time1,price1,time2,price2);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_FILL,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
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
//| Create a text label                                              |
//+------------------------------------------------------------------+
void LabelCreate(string name, string text, int x, int y, color clr=clrWhiteSmoke)
  {
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetDouble(0,name,OBJPROP_ANGLE,0.00);
   ObjectSetString(0,name,OBJPROP_FONT,"Lucida Console");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
  }
//+------------------------------------------------------------------+
