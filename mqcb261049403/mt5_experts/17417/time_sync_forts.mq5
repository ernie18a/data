//+------------------------------------------------------------------+
//|                                              Time_sync_forts.mq5 |
//|                   Copyright 2017 Sergey Chalyshev & prostotrader |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017 Sergey Chalyshev & prostotrader"
#property link      "https://forge.mql5.io"
#property version   "1.09"
//---
struct _SYSTEMTIME
  {
   short wYear;
   short wMonth;
   short wDayOfWeek;
   short wDay;
   short wHour;
   short wMinute;
   short wSecond;
   short wMilliseconds;
  };

_SYSTEMTIME loc_time;

#import "kernel32.dll"
//void GetLocalTime(_SYSTEMTIME &sys_time);
bool SetLocalTime(_SYSTEMTIME &sys_time);
#import
//
input ENUM_DAY_OF_WEEK FirstDay  = SATURDAY;        //Первый выходной
input ENUM_DAY_OF_WEEK SecondDay = SUNDAY;          //Второй выходной
//
MqlTick tick;
MqlDateTime sv_time, tts_time;
int st_st_mon   = 35100; //09-45
int end_st_mon  = 36000; //10-00
int st_tr_mon   = 36060; //10-01
int end_tr_mon  = 36120; //10-02
int st_end_mon  = 50280; //13-58
int end_end_mon = 50400; //14-00
int st_st_day   = 50700; //14-05
int end_st_day  = 50760; //14-06
int st_end_day  = 67380; //18-43
int end_end_day = 67500; //18-45
int st_st_evn   = 68700; //19-05
int end_st_evn  = 68760; //19-06
int st_end_evn  = 85680; //23-48
int end_end_evn = 85800; //23-50
//---
bool  is_sync;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  is_sync = true;
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert Convert To Time function                                  |
//+------------------------------------------------------------------+
bool ConvertToTime(const ulong n_value,_SYSTEMTIME  &a_time)
  {
   MqlDateTime cur_time={0};
   TimeToStruct(datetime(n_value/1000),cur_time);
   if(cur_time.year>0)
     {
      a_time.wDay=short(cur_time.day);
      a_time.wDayOfWeek=short(cur_time.day_of_week);
      a_time.wHour=short(cur_time.hour);
      a_time.wMinute= short(cur_time.min);
      a_time.wMonth = short(cur_time.mon);
      a_time.wSecond= short(cur_time.sec);
      a_time.wYear=short(cur_time.year);
      a_time.wMilliseconds=short(n_value%1000);
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Expert On Tick function                                          |
//+------------------------------------------------------------------+
void OnTick()
{
  tts_time.year = 0;
  TimeTradeServer(tts_time);
  if(tts_time.year > 0)
  {
    if((tts_time.day_of_week == int(FirstDay)) ||
       (tts_time.day_of_week == int(SecondDay))) return;
    int cur_time = tts_time.hour * 3600 + tts_time.min * 60 + tts_time.sec;
    if(((cur_time >= st_st_mon) && (cur_time < end_st_mon)) ||
       ((cur_time >= st_tr_mon) && (cur_time < end_tr_mon)) ||
       ((cur_time >= st_end_mon) && (cur_time < end_end_mon)) ||
       ((cur_time >= st_st_day) && (cur_time < end_st_day)) ||
       ((cur_time >= st_end_day) && (cur_time < end_end_day)) ||
       ((cur_time >= st_st_evn) && (cur_time < end_st_evn)) ||
       ((cur_time >= st_end_evn) && (cur_time < end_end_evn)))
    {
      if(!is_sync)
      {
        if(!SymbolInfoTick(Symbol(), tick))
        {
          Print("Error SymbolInfoTick", GetLastError());
          return;
        }
        sv_time.year = 0;
        TimeToStruct(tick.time, sv_time);
        if(sv_time.year>0)
        {
          ulong last_ping=ulong(NormalizeDouble(double(TerminalInfoInteger(TERMINAL_PING_LAST))/2000,0));
          ulong mls_time=ulong(tick.time_msc%1000);
          if((mls_time+last_ping)>999)
          {
            mls_time=tick.time_msc+last_ping;
            if(!ConvertToTime(mls_time, loc_time)) return;
          }
          else
          {
            loc_time.wYear = short(sv_time.year);
            loc_time.wMonth = short(sv_time.mon);
            loc_time.wDay = short(sv_time.day);
            loc_time.wDayOfWeek = short(sv_time.day_of_week);
            loc_time.wHour = short(sv_time.hour);
            loc_time.wMinute = short(sv_time.min);
            loc_time.wSecond = short(sv_time.sec);
            loc_time.wMilliseconds=short(mls_time+last_ping);
          }
          if(SetLocalTime(loc_time))
          {
            is_sync=true;
            Print("Local time sync is done. Symbol = ",Symbol()," Sync hour = ",loc_time.wHour, " Sync min = ",loc_time.wMinute,
                  " Sync sec = ",loc_time.wSecond," Sync ms = ",loc_time.wMilliseconds);
          }
        }
      }
    }
    else is_sync = false;
  } 
}  
//+------------------------------------------------------------------+
