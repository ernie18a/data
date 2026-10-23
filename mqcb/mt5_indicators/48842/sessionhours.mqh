//+------------------------------------------------------------------+
//|                                                 SessionHours.mqh |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#ifndef SESSIONHOURS_UNIQUE_HEADER_ID_H
#define SESSIONHOURS_UNIQUE_HEADER_ID_H
#property version "2.17"

#include "TimeZoneInfo.mqh"

//+------------------------------------------------------------------+
//| Class CSessionHours.                                             |
//| Purpose: Class to access the local trading session hours for     |
//|          the specified location.                                 |
//|          Derives from class CTimeZoneInfo.                       |
//| Note:    The default session hours are set to 8:00 am - 5:00 pm  |
//|          local time for new CSessionHours objects.               |
//+------------------------------------------------------------------+
class CSessionHours : public CTimeZoneInfo
  {
protected:
   int               m_beginlocalhour;
   int               m_beginlocalminute;
   int               m_endlocalhour;
   int               m_endlocalminute;
   datetime          m_beginlocaltime;
   datetime          m_endlocaltime;

public:
                     CSessionHours(const ENUM_ZONE_ID placeId);
                    ~CSessionHours(void) { }

   //--- methods to access the local session time
   bool              RefreshTime(void);                                     // Refresh the current local time and session hours for the day
   bool              SetLocalTime(const datetime pLocalTime);

   //--- methods to override default local session hours
   bool              BeginLocalTime(const int pHour, const int pMinute);    // Set the local session begin time using a begin hour and minute
   bool              EndLocalTime(const int pHour, const int pMinute);      // Set the local session end time using an end hour and minute

   //--- methods to access local session hours
   datetime          BeginLocalTime(void) const { return(m_beginlocaltime); }
   datetime          EndLocalTime(void)   const { return(m_endlocaltime);   }
   bool              CheckLocalSession(void) const;                         // Check whether the local trading session is currently active
   int               SecRemainingSession(void) const;                       // Time remaining in seconds till local session closes for the day

   //--- static methods that do not require the creation of an object.
   static datetime   ForexCloseTime(void);                                  // The broker time when the Forex market closes for this week
   static int        SecRemainingForex(void);                               // Time remaining in seconds till Forex market closes for this week
   static string     SecondsToString(const int seconds);                    // Format the time in seconds to a string (like 2d 14:58:04)
  };
//+------------------------------------------------------------------+
//| Constructor.                                                     |
//| CSessionHours objects automatically instantiate with the current |
//| local time and local session hours for the specified location.   |
//+------------------------------------------------------------------+
CSessionHours::CSessionHours(const ENUM_ZONE_ID placeId) :  CTimeZoneInfo(placeId),  // call parent constructor
                                                            m_beginlocalhour(8),
                                                            m_beginlocalminute(0),
                                                            m_endlocalhour(17),
                                                            m_endlocalminute(0)
  {
//--- instantiate with the current local time
   RefreshTime();
  }
//+------------------------------------------------------------------+
//| Refresh the current local time and session hours for the day.    |
//+------------------------------------------------------------------+
bool CSessionHours::RefreshTime(void)
  {
   return(SetLocalTime(0));
  }
//+------------------------------------------------------------------+
//| Set the local time for this location to the specified time and   |
//| populate the session local hours, accordingly.                   |
//+------------------------------------------------------------------+
bool CSessionHours::SetLocalTime(const datetime pLocalTime)
  {
   bool res = CTimeZoneInfo::SetLocalTime(pLocalTime);
   BeginLocalTime(m_beginlocalhour, m_beginlocalminute);
   EndLocalTime(m_endlocalhour, m_endlocalminute);
   return(res);
  }
//+------------------------------------------------------------------+
//| Set the local session begin time using a begin hour and minute.  |
//+------------------------------------------------------------------+
bool CSessionHours::BeginLocalTime(const int pHour, const int pMinute)
  {
   m_beginlocalhour   = pHour;
   m_beginlocalminute = pMinute;
//---
   MqlDateTime st;
   TimeToStruct(this.TimeLocal(), st);
   st.hour = pHour;
   st.min = pMinute;
   st.sec = 0;
   m_beginlocaltime = StructToTime(st);
   return(true);
  }
//+------------------------------------------------------------------+
//| Set the local session end time using an end hour and minute.     |
//+------------------------------------------------------------------+
bool CSessionHours::EndLocalTime(const int pHour, const int pMinute)
  {
   m_endlocalhour   = pHour;
   m_endlocalminute = pMinute;
//---
   MqlDateTime st;
   TimeToStruct(this.TimeLocal(), st);
   st.hour = pHour;
   st.min = pMinute;
   st.sec = 0;
   m_endlocaltime = StructToTime(st);
   return(true);
  }
//+------------------------------------------------------------------+
//| Check whether the local trading session is currently active.     |
//+------------------------------------------------------------------+
bool CSessionHours::CheckLocalSession(void) const
  {
//--- using local times, Saturday and Sunday are weekend days.
   datetime localtime = this.TimeLocal();
   return(DayOfWeek(localtime) != SATURDAY && DayOfWeek(localtime) != SUNDAY && localtime >= m_beginlocaltime && localtime < m_endlocaltime);
  }
//+-------------------------------------------------------------------+
//| Time remaining in seconds till local session closes for the day.  |
//+-------------------------------------------------------------------+
int CSessionHours::SecRemainingSession(void) const
  {
   datetime localtime = this.TimeLocal();
   int remaining = 0;
   if(DayOfWeek(localtime) != SATURDAY && DayOfWeek(localtime) != SUNDAY && localtime < m_endlocaltime)
     {
      remaining = (int)(m_endlocaltime - localtime) - 1;
     }
   return(remaining);
  }
//+------------------------------------------------------------------+
//| The broker time when the Forex market closes for this week.      |
//| Returns the last close time, if called during the weekend.       |
//+------------------------------------------------------------------+
datetime CSessionHours::ForexCloseTime(void)
  {
   CSessionHours newyork(ZONE_ID_NEWYORK);
   datetime localtime = newyork.TimeLocal();
   datetime sunday = StartOfWeek(localtime);  // the weekend "Sunday 00:00" before this time
   datetime open = sunday + 17 * HOURSECS;    // Forex opens Sun, 17:00 NY
   datetime close = open + 5 * DAYSECS - 1;   // Forex closes Fri, 17:00 NY
//--- Fix Sunday 00:00 - 17:00
   if(localtime < open)
     {
      close -= WEEKSECS;
     }
   return(CTimeZoneInfo::ConvertTimeForPlace(close, ZONE_ID_NEWYORK, ZONE_ID_BROKER));
  }
//+-------------------------------------------------------------------+
//| Time remaining in seconds till Forex market closes for this week. |
//| Returns 0 remaining sec, if called during the weekend.            |
//+-------------------------------------------------------------------+
int CSessionHours::SecRemainingForex(void)
  {
   datetime now = TimeTradeServer();
   datetime close = ForexCloseTime();
   int remaining = 0;
   if(now < close)
     {
      remaining = (int)(close - now);
     }
   return(remaining);
  }
//+------------------------------------------------------------------+
//| Format the time in seconds to a string (like 2d 14:58:04)        |
//+------------------------------------------------------------------+
string CSessionHours::SecondsToString(const int seconds)
  {
   const int days = (int)(seconds / DAYSECS);
   const string d = days ? (string)days + "d " : "";
   return (d + TimeToString(seconds,TIME_SECONDS));
  }
//+------------------------------------------------------------------+


#endif // #ifndef SESSIONHOURS_UNIQUE_HEADER_ID_H
