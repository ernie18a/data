//+------------------------------------------------------------------+
//|                                                  TimeZoneFmt.mqh |
//|                                    Copyright (c) 2024, marketeer |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#include "TimeServerDST.mqh"

//+------------------------------------------------------------------+
//| Date and time formatting including time zone                     |
//+------------------------------------------------------------------+

string MonthName(const int monthNo) // 1-based index of month
{
   const static string months[12] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
   return months[(uint)(monthNo - 1) % 12];
}

string DayName(const int dayNo)
{
   const static string days[7] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
   return days[(uint)dayNo % 7];
}

int DayOfWeek(const datetime dayTime)
{
   return (int)(((ulong)dayTime / 86400) + 4) % 7;
}

// TIME_ bits are [1 2 4] 8 16 32 64 128 <- used & reserved | custom-> 256 512 1024 2048
#define TIME_DAY_OF_WEEK 256
#define TIME_MONTH_NAME  512
#define TIME_ZONE_UTC   1024
#define TIME_ZONE_GMT   2048
// if neither of UTC/GMT notation is selected, ISO is used, e.g. "+03:00"

string TimeToStringExt(const datetime srvtime, const int flags = TIME_DATE | TIME_MINUTES | TIME_DAY_OF_WEEK)
{
   string timestr = TimeToString(srvtime, flags & 7); // ISO 8601, default of MQL5
   if((flags & (TIME_MONTH_NAME | TIME_DATE)) == (TIME_MONTH_NAME | TIME_DATE)) // RFC822 / IETF, option
   {                                                                            // "2024.05.19" -> "19 May 2024"
      const int ind = (int)StringToInteger(StringSubstr(timestr, 5, 2));
      timestr = StringSubstr(timestr, 8, 2) + " " + MonthName(ind) + " " + StringSubstr(timestr, 0, 4) + StringSubstr(timestr, 10);
   }
   if((flags & TIME_DAY_OF_WEEK) != 0)
   {
      const int dow = DayOfWeek(srvtime);
      timestr = DayName(dow) + ", " + timestr;
   }
   
   return timestr;
}

string ServerTimeZoneToString(const ServerTimeZone &stz, const int notation = TIME_ZONE_UTC)
{
   const static string labels[3] = {"", " UTC", " GMT"};
   return labels[((uint)notation / TIME_ZONE_UTC) % 3]
      + ((notation & 7) != 0 ? StringFormat(notation < TIME_ZONE_UTC ? "%+.2d:00" : "%+d", stz.offsetGMT / -3600) : StringFormat("%+d", stz.offsetGMT))
      + (stz.supportDST ? (stz.offsetDST ? " DST" : " STD") : "");
}

string TimeZoneToString(const datetime srvtime, const ServerTimeZone &stz,
   const int flags = TIME_DATE | TIME_MINUTES | TIME_DAY_OF_WEEK | TIME_ZONE_UTC)
{
   return TimeToStringExt(srvtime, flags) + ServerTimeZoneToString(stz, flags);
}

//+------------------------------------------------------------------+
/*

 examples:
   Print(TimeZoneToString(TimeCurrent(), TimeServerZone(TimeCurrent())));
   Print(TimeZoneToString(TimeCurrent(), TimeServerZone(TimeCurrent()), TIME_DATE | TIME_MINUTES | TIME_MONTH_NAME));
   Print(TimeZoneToString(TimeCurrent(), TimeServerZone(TimeCurrent()), 0));
   
 outputs:
   Wed, 2024.11.20 15:08 UTC+2 STD
   20 Nov 2024 15:08+02:00 STD
   1732104500-7200 STD
   
*/
//+------------------------------------------------------------------+
