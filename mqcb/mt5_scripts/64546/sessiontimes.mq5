//+------------------------------------------------------------------+
//|                                                 SessionTimes.mq5 |
//|                                            Copyright 2025, phade |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, phade"
#property link      "https://forge.mql5.io"
#property version   "1.00"

#include <ChartObjects\ChartObjectsTxtControls.mqh>

CChartObjectLabel labels[24];
string session_by_hour[24];
int session_count_by_hour[24];

struct Session
  {
   string            name;
   int               start_gmt;
   int               duration;
  };


// Session times (The GMT start hour, and session duration with overlap hours)
Session sessions[] =
  {
     {"Sydney",   21, 12},  // 21:00–09:00 GMT
     {"Tokyo",     0, 9},   // 00:00–09:00 GMT
     {"London",    8, 9},   // 08:00–17:00 GMT
     {"New York", 13, 9}    // 13:00–22:00 GMT
  };


// Convert GMT hour to broker time
int GetServerOffsetHours()
  {
   MqlDateTime gmt, local;
   TimeToStruct(TimeGMT(), gmt);
   TimeToStruct(TimeCurrent(), local);
   int offset = local.hour - gmt.hour;
   if(offset < 0)
      offset += 24;
   return offset;
  }


void BuildSessionMap()
  {
   int offset = GetServerOffsetHours();

   for(int i = 0; i < ArraySize(sessions); i++)
     {
      int start = (sessions[i].start_gmt + offset + 24) % 24;

      for(int h = 0; h < sessions[i].duration; h++)
        {
         int hour = (start + h) % 24;

         if(session_count_by_hour[hour] != 0)
            session_by_hour[hour] += " + ";

         session_by_hour[hour] += sessions[i].name;
         session_count_by_hour[hour]++;
        }
     }
  }

string GetSessionName(int hour)
  {
   if(session_count_by_hour[hour] == 2)
      return session_by_hour[hour] + " Overlap";

   return session_by_hour[hour];
  }

void InitLabels()
  {
   BuildSessionMap();

   MqlDateTime base;
   TimeToStruct(TimeCurrent(), base); // broker time
   base.hour = 0;
   base.min = 0;
   base.sec = 0;
   datetime base_day = StructToTime(base);

   int sy = 20;
   int dy = 16;

   for(int i = 0; i < 24; i++)
     {
      datetime server_dt = base_day + i * 3600;
      datetime local_dt = 0;

      if(TimeCurrent() > TimeLocal())
         local_dt = server_dt - (TimeCurrent() - TimeLocal());
      else
         if(TimeCurrent() < TimeLocal())
            local_dt = server_dt + (TimeLocal() - TimeCurrent());

      string server_str = TimeToString(server_dt, TIME_MINUTES);
      string local_str  = TimeToString(local_dt, TIME_MINUTES);
      string session    = GetSessionName(i);

      string label_text = server_str + " - " + session + " (Local time -- " + local_str + ")";

      labels[i].Create(0, "Label"+IntegerToString(i), 0, 10, sy + i * dy);
      labels[i].Description(label_text);
      labels[i].Color(clrWhite);
      labels[i].FontSize(8);

      //Print(i + " " + session + "\n");
     }     
  }

void OnStart()
  {
   InitLabels();

   while(!IsStopped())
     {
      MqlDateTime now;
      TimeToStruct(TimeCurrent(), now); // server time
      int current_hour = now.hour;

      for(int i = 0; i < 24; i++)
        {
         if(i == current_hour)
            labels[i].Color(clrYellow); // highlight current session
         else
            labels[i].Color(clrWhite);
        }

      ChartRedraw();
      Sleep(1000);
     }
  }
