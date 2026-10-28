//+------------------------------------------------------------------+
//|                                                                  |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property version   "1.00"
#property description "Scheduling helper."
#property strict
//+------------------------------------------------------------------+
//| Define an hour and minute, like 14:25                            |
//+------------------------------------------------------------------+
class TimeStamp
  {
public:
   int               Hour;
   int               Minute;
   void TimeStamp(string str)
     {
      string sep=":";
      string result[];
      ushort u_sep=StringGetCharacter(sep,0);
      int k=StringSplit(str,u_sep,result);
      int h= StrToInteger(result[0]);
      int m= StrToInteger(result[1]);
      Hour=h;
      Minute=m;
     }
   string ToString()
     {
      return(StringFormat("%02i%s%02i", Hour, ":", Minute));
     }
  };
//+------------------------------------------------------------------+
//| Defines a schedule.                                              |
//+------------------------------------------------------------------+
class Schedule
  {
public:
   ENUM_DAY_OF_WEEK  DayStart;
   TimeStamp        *TimeStart;
   ENUM_DAY_OF_WEEK  DayEnd;
   TimeStamp        *TimeEnd;
   void Schedule(ENUM_DAY_OF_WEEK startDay,
                 string startTime,
                 ENUM_DAY_OF_WEEK endDay,
                 string endTime)
     {
      DayStart=startDay;
      DayEnd=endDay;
      TimeStart=new TimeStamp(startTime);
      TimeEnd=new TimeStamp(endTime);
     }

   bool IsActive(datetime when)
     {
      bool result=false;
      ENUM_DAY_OF_WEEK d=(ENUM_DAY_OF_WEEK)TimeDayOfWeek(when);
      int h = TimeHour(when);
      int m = TimeMinute(when);
      bool activeDay=(d>=DayStart && d<=DayEnd);
      if(activeDay)
        {
         bool activeHour=(h>=TimeStart.Hour && h<=TimeEnd.Hour);
         if(activeHour)
           {
            bool hourOrLess=TimeStart.Hour==TimeEnd.Hour;
            if(hourOrLess)
              {
               result=m>=TimeStart.Minute && m<=TimeEnd.Minute;
              }
            else
              {
               bool ignoreStartAndEndMinutes=((h!=TimeStart.Hour) && (h!=TimeEnd.Hour));
               if(ignoreStartAndEndMinutes)
                 {
                  result=true;
                 }
               else
                 {
                  if(h==TimeStart.Hour)
                    {
                     result=m>=TimeStart.Minute;
                    }
                  if(h==TimeEnd.Hour)
                    {
                     result=m<=TimeEnd.Minute;
                    }
                 }
              }
           }
        }

      return result;
     }

   string ToString()
     {
      return (StringConcatenate(EnumToString(DayStart)," to ",EnumToString(DayEnd), " from ", TimeStart.ToString(), " to ", TimeEnd.ToString()));
     }

   void ~Schedule()
     {
      delete TimeStart;
      delete TimeEnd;
     }
  };
//+------------------------------------------------------------------+
