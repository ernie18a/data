//+------------------------------------------------------------------+
//|                                            ResetHourClock.mq5    |
//|                    Server Clock and Daily Reset Hour             |
//|                                                                  |
//|  A read-only chart panel that answers one question:              |
//|  "What hour, in my broker's server time, does my trading day     |
//|   actually reset?"                                               |
//|                                                                  |
//|  Enter the reset rule the way your firm writes it (for example   |
//|  5:00 pm New York) and the panel converts it to broker server    |
//|  time, keeps a countdown to the next reset, and warns you        |
//|  before daylight saving shifts the answer by an hour.            |
//|                                                                  |
//|  Sends no orders. Reads no account data. Display only.           |
//+------------------------------------------------------------------+
#property copyright "Sabarinathan R"
#property version   "1.00"
#property strict
#property description "Shows broker server time, local time and UTC, converts your firm's daily reset rule into server time, and warns before daylight saving changes it."

//--- reset rule ------------------------------------------------------
enum ENUM_RESET_ZONE
  {
   ZONE_NEW_YORK = 0,   // New York (US Eastern)
   ZONE_CHICAGO  = 1,   // Chicago (US Central)
   ZONE_LONDON   = 2,   // London (UK)
   ZONE_FRANKFURT= 3,   // Frankfurt (Central Europe)
   ZONE_UTC      = 4,   // UTC (no daylight saving)
   ZONE_CUSTOM   = 5    // Custom fixed offset, set below
  };

input ENUM_RESET_ZONE ResetZone       = ZONE_NEW_YORK; // time zone your firm's rule is written in
input int    ResetHour                = 17;            // reset hour in that zone (0-23)
input int    ResetMinute              = 0;             // reset minute in that zone (0-59)
input int    CustomZoneOffsetMinutes  = 0;             // only used when ResetZone = Custom

//--- server offset ---------------------------------------------------
input bool   AutoDetectServerOffset   = true;          // work out the server's UTC offset automatically
input int    ManualServerOffsetMinutes= 180;           // used when auto-detect is off (180 = UTC+3)

//--- appearance ------------------------------------------------------
input int    PanelX                   = 12;
input int    PanelY                   = 20;
input int    FontSize                 = 10;
input color  PanelColor               = C'28,32,42';
input color  TextColor                = clrWhiteSmoke;
input color  AccentColor              = C'120,190,255';
input color  WarnColor                = C'255,190,90';
input color  GoodColor                = C'130,220,150';

//--- internals -------------------------------------------------------
#define OBJ_PREFIX "RHC_"

int    g_lineCount        = 0;
int    g_lastDrawnLines   = 0;
int    g_maxLineChars     = 0;

//+------------------------------------------------------------------+
//| Calendar helpers                                                 |
//+------------------------------------------------------------------+
datetime MakeTime(const int y,const int mo,const int d,const int h,const int mi)
  {
   MqlDateTime t;
   ZeroMemory(t);
   t.year = y;
   t.mon  = mo;
   t.day  = d;
   t.hour = h;
   t.min  = mi;
   t.sec  = 0;
   return(StructToTime(t));
  }

int DaysInMonth(const int y,const int mo)
  {
   int days[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
   if(mo == 2)
     {
      bool leap = ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0));
      return(leap ? 29 : 28);
     }
   return(days[mo-1]);
  }

//--- day-of-month of the first given weekday (0 = Sunday)
int FirstWeekdayDay(const int y,const int mo,const int weekday)
  {
   MqlDateTime t;
   TimeToStruct(MakeTime(y,mo,1,0,0),t);
   int shift = (weekday - t.day_of_week + 7) % 7;
   return(1 + shift);
  }

int NthWeekdayDay(const int y,const int mo,const int weekday,const int nth)
  {
   return(FirstWeekdayDay(y,mo,weekday) + (nth-1)*7);
  }

int LastWeekdayDay(const int y,const int mo,const int weekday)
  {
   int dim = DaysInMonth(y,mo);
   MqlDateTime t;
   TimeToStruct(MakeTime(y,mo,dim,0,0),t);
   int back = (t.day_of_week - weekday + 7) % 7;
   return(dim - back);
  }

//+------------------------------------------------------------------+
//| Daylight saving                                                  |
//+------------------------------------------------------------------+
enum ENUM_DST_RULE { DST_NONE = 0, DST_US = 1, DST_EU = 2 };

void ZoneProfile(const ENUM_RESET_ZONE zone,int &stdOffMin,int &dstOffMin,ENUM_DST_RULE &rule,string &label)
  {
   switch(zone)
     {
      case ZONE_NEW_YORK:  stdOffMin = -300; dstOffMin = -240; rule = DST_US;   label = "New York";  break;
      case ZONE_CHICAGO:   stdOffMin = -360; dstOffMin = -300; rule = DST_US;   label = "Chicago";   break;
      case ZONE_LONDON:    stdOffMin =    0; dstOffMin =   60; rule = DST_EU;   label = "London";    break;
      case ZONE_FRANKFURT: stdOffMin =   60; dstOffMin =  120; rule = DST_EU;   label = "Frankfurt"; break;
      case ZONE_UTC:       stdOffMin =    0; dstOffMin =    0; rule = DST_NONE; label = "UTC";       break;
      default:
         stdOffMin = CustomZoneOffsetMinutes;
         dstOffMin = CustomZoneOffsetMinutes;
         rule      = DST_NONE;
         label     = "custom zone";
         break;
     }
  }

//--- UTC instants at which the zone switches, for a given year
void DstBoundaries(const int year,const ENUM_DST_RULE rule,const int stdOffMin,const int dstOffMin,
                   datetime &startUTC,datetime &endUTC)
  {
   startUTC = 0;
   endUTC   = 0;
   if(rule == DST_US)
     {
      // second Sunday in March, 02:00 local standard time
      startUTC = (datetime)((long)MakeTime(year,3,NthWeekdayDay(year,3,0,2),2,0) - (long)stdOffMin*60);
      // first Sunday in November, 02:00 local daylight time
      endUTC   = (datetime)((long)MakeTime(year,11,NthWeekdayDay(year,11,0,1),2,0) - (long)dstOffMin*60);
     }
   else if(rule == DST_EU)
     {
      // last Sunday in March / last Sunday in October, both at 01:00 UTC
      startUTC = MakeTime(year,3,LastWeekdayDay(year,3,0),1,0);
      endUTC   = MakeTime(year,10,LastWeekdayDay(year,10,0),1,0);
     }
  }

bool IsDstActive(const datetime utcNow,const ENUM_DST_RULE rule,const int stdOffMin,const int dstOffMin)
  {
   if(rule == DST_NONE)
      return(false);
   MqlDateTime t;
   TimeToStruct(utcNow,t);
   datetime s,e;
   DstBoundaries(t.year,rule,stdOffMin,dstOffMin,s,e);
   return(utcNow >= s && utcNow < e);
  }

//--- the next switch after utcNow, and whether it turns daylight saving on or off
bool NextDstChange(const datetime utcNow,const ENUM_DST_RULE rule,const int stdOffMin,const int dstOffMin,
                   datetime &whenUTC,bool &turnsOn)
  {
   if(rule == DST_NONE)
      return(false);

   MqlDateTime t;
   TimeToStruct(utcNow,t);

   datetime best     = 0;
   bool     bestOn   = false;
   bool     found    = false;

   // gather this year's and next year's boundaries, keep the earliest one still ahead of us
   for(int y = t.year; y <= t.year+1; y++)
     {
      datetime s,e;
      DstBoundaries(y,rule,stdOffMin,dstOffMin,s,e);

      if(s > utcNow && (!found || s < best))
        {
         best   = s;
         bestOn = true;
         found  = true;
        }
      if(e > utcNow && (!found || e < best))
        {
         best   = e;
         bestOn = false;
         found  = true;
        }
     }

   if(!found)
      return(false);

   whenUTC = best;
   turnsOn = bestOn;
   return(true);
  }

//+------------------------------------------------------------------+
//| Formatting helpers                                               |
//+------------------------------------------------------------------+
string HHMM(const int totalMinutes)
  {
   int m = totalMinutes % 1440;
   if(m < 0)
      m += 1440;
   return(StringFormat("%02d:%02d",m/60,m%60));
  }

string OffsetLabel(const int minutes)
  {
   int a = MathAbs(minutes);
   string sign = (minutes < 0 ? "-" : "+");
   if(a % 60 == 0)
      return(StringFormat("UTC%s%d",sign,a/60));
   return(StringFormat("UTC%s%d:%02d",sign,a/60,a%60));
  }

string Countdown(const int seconds)
  {
   int s = seconds;
   if(s < 0)
      s = 0;
   int h = s/3600;
   int m = (s%3600)/60;
   int sec = s%60;
   return(StringFormat("%02dh %02dm %02ds",h,m,sec));
  }

//+------------------------------------------------------------------+
//| Drawing                                                          |
//+------------------------------------------------------------------+
void DrawLine(const string text,const color clr)
  {
   string name = OBJ_PREFIX + "L" + IntegerToString(g_lineCount);
   if(ObjectFind(0,name) < 0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,10);
      ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
     }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,PanelX);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,PanelY + g_lineCount*(FontSize+7));
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,text);

   int len = StringLen(text);
   if(len > g_maxLineChars)
      g_maxLineChars = len;
   g_lineCount++;
  }

void DrawBackdrop()
  {
   string name = OBJ_PREFIX + "BG";
   if(ObjectFind(0,name) < 0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      // drawn in front of the chart, behind the text labels
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
     }
   // TextGetSize()/TextSetFont() would measure real pixel width, but
   // this session has no way to compile and run MQL5 to verify which
   // way TextSetFont's point/pixel sign convention actually goes --
   // getting that backwards would silently produce a WORSE result
   // than a plain estimate, with no compiler error to catch it. Using
   // a deliberately generous per-character estimate instead, which is
   // the fallback this fix (REQ-003) explicitly allows.
   //
   // The previous 0.62 factor was measured live and confirmed too
   // small: a 34-character line at FontSize 10 produced a ~235px
   // panel that the text visibly overflowed. Consolas' real rendered
   // advance width runs closer to 0.8x the point size at typical
   // screen DPI (roughly 0.6 font-design-units-per-em x ~1.33
   // px-per-point) -- raised further to 0.85 with more flat padding,
   // since this is still an estimate, not a measurement.
   int width  = (int)(g_maxLineChars * FontSize * 0.85) + 40;
   int height = g_lineCount * (FontSize+7) + 16;
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,PanelX-10);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,PanelY-8);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,PanelColor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,C'70,80,95');
  }

void ClearUnusedLines()
  {
   for(int i = g_lineCount; i < g_lastDrawnLines; i++)
      ObjectDelete(0,OBJ_PREFIX + "L" + IntegerToString(i));
   g_lastDrawnLines = g_lineCount;
  }

void RemoveAllObjects()
  {
   ObjectsDeleteAll(0,OBJ_PREFIX);
  }

//+------------------------------------------------------------------+
//| Main refresh                                                     |
//+------------------------------------------------------------------+
void Refresh()
  {
   g_lineCount    = 0;
   g_maxLineChars = 0;

   datetime serverNow = TimeTradeServer();
   datetime utcNow    = TimeGMT();
   datetime localNow  = TimeLocal();

   //--- server offset from UTC
   int serverOffMin;
   if(AutoDetectServerOffset)
     {
      int raw = (int)((serverNow - utcNow) / 60);
      // round to the nearest 15 minutes to absorb clock jitter
      serverOffMin = (int)(MathRound(raw / 15.0) * 15);
     }
   else
      serverOffMin = ManualServerOffsetMinutes;

   //--- zone profile and current daylight-saving state
   int stdOff, dstOff;
   ENUM_DST_RULE rule;
   string zoneLabel;
   ZoneProfile(ResetZone,stdOff,dstOff,rule,zoneLabel);

   bool dstOn     = IsDstActive(utcNow,rule,stdOff,dstOff);
   int  zoneOff   = dstOn ? dstOff : stdOff;

   //--- convert the reset rule into server time
   int resetZoneMinutes   = ResetHour*60 + ResetMinute;
   int resetUtcMinutes    = resetZoneMinutes - zoneOff;
   int resetServerMinutes = resetUtcMinutes + serverOffMin;
   int dayShift           = (int)MathFloor(resetServerMinutes / 1440.0);
   int resetServerOfDay   = resetServerMinutes - dayShift*1440;

   //--- countdown to the next reset
   MqlDateTime st;
   TimeToStruct(serverNow,st);
   int nowMinutes = st.hour*60 + st.min;
   int minsToReset = resetServerOfDay - nowMinutes;
   if(minsToReset <= 0)
      minsToReset += 1440;
   int secsToReset = minsToReset*60 - st.sec;

   //--- panel ---------------------------------------------------------
   DrawLine("SERVER CLOCK AND DAILY RESET", AccentColor);
   // A single space, not an empty string -- OBJ_LABEL falls back to
   // rendering its default object description ("Label") when
   // OBJPROP_TEXT is set to "", which is exactly why every blank
   // spacer line was showing that literal word (REQ-004). RiskMirror
   // already gets this right with DrawLine(" ", ColNormal).
   DrawLine(" ", TextColor);

   DrawLine(StringFormat("  Broker server time   %s   (%s)",
                         TimeToString(serverNow,TIME_MINUTES|TIME_SECONDS),
                         OffsetLabel(serverOffMin)), TextColor);
   DrawLine(StringFormat("  UTC                  %s",
                         TimeToString(utcNow,TIME_MINUTES|TIME_SECONDS)), TextColor);
   DrawLine(StringFormat("  Your computer        %s",
                         TimeToString(localNow,TIME_MINUTES|TIME_SECONDS)), TextColor);
   DrawLine(" ", TextColor);

   DrawLine(StringFormat("  Your reset rule      %s %s",
                         HHMM(resetZoneMinutes), zoneLabel), TextColor);
   if(rule != DST_NONE)
      DrawLine(StringFormat("  That zone is now on  %s (%s)",
                            dstOn ? "daylight saving time" : "standard time",
                            OffsetLabel(zoneOff)), TextColor);

   string shiftNote = "";
   if(dayShift > 0)
      shiftNote = "  (next day)";
   else
      if(dayShift < 0)
         shiftNote = "  (previous day)";

   DrawLine(" ", TextColor);
   DrawLine(StringFormat("  RESET HOUR IN SERVER TIME:  %s%s",
                         HHMM(resetServerOfDay), shiftNote), GoodColor);
   DrawLine(StringFormat("  Next reset in        %s", Countdown(secsToReset)), TextColor);

   //--- daylight-saving warning ---------------------------------------
   if(rule != DST_NONE)
     {
      datetime changeUTC;
      bool turnsOn;
      if(NextDstChange(utcNow,rule,stdOff,dstOff,changeUTC,turnsOn))
        {
         int daysAway = (int)((changeUTC - utcNow) / 86400);
         int newZoneOff = turnsOn ? dstOff : stdOff;
         int newServerMinutes = ResetHour*60 + ResetMinute - newZoneOff + serverOffMin;
         int newShift = (int)MathFloor(newServerMinutes / 1440.0);
         int newOfDay = newServerMinutes - newShift*1440;

         DrawLine(" ", TextColor);
         if(newOfDay != resetServerOfDay)
           {
            color c = (daysAway <= 14) ? WarnColor : TextColor;
            DrawLine(StringFormat("  Clocks change in %d days (%s).",
                                  daysAway, TimeToString(changeUTC,TIME_DATE)), c);
            DrawLine(StringFormat("  Your server reset hour becomes %s then.",
                                  HHMM(newOfDay)), c);
           }
         else
            DrawLine(StringFormat("  Clocks change %s, reset hour unaffected.",
                                  TimeToString(changeUTC,TIME_DATE)), TextColor);
        }
     }

   //--- sanity note ----------------------------------------------------
   if(AutoDetectServerOffset)
     {
      int rawDiff = (int)((serverNow - utcNow) / 60);
      if(MathAbs(rawDiff - serverOffMin) > 5)
        {
         DrawLine(" ", TextColor);
         DrawLine("  Note: your computer clock may be inaccurate.", WarnColor);
        }
     }

   ClearUnusedLines();
   DrawBackdrop();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Lifecycle                                                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(ResetHour < 0 || ResetHour > 23 || ResetMinute < 0 || ResetMinute > 59)
     {
      Print("Reset hour must be 0-23 and reset minute 0-59.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   // Create the backdrop FIRST, before any text label exists. MQL5
   // draws foreground objects (OBJPROP_BACK false) in creation order,
   // not by OBJPROP_ZORDER -- that property only affects mouse-click
   // priority. DrawBackdrop() was previously only called at the end of
   // Refresh(), after every label had already been created, so on the
   // very first refresh it was created LAST and painted over all of
   // them -- a solid panel with no visible text. Calling it here once,
   // before the labels exist, means every label drawn afterward is
   // created after it and therefore renders on top. Its size will be
   // wrong for this one call (0 lines counted yet) but Refresh() below
   // corrects it before anything is ever shown on screen.
   DrawBackdrop();
   EventSetTimer(1);
   Refresh();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   RemoveAllObjects();
   ChartRedraw(0);
  }

void OnTimer()
  {
   Refresh();
  }

void OnTick()
  {
   // nothing: this utility never reads or sends trade data
  }
//+------------------------------------------------------------------+
