//+------------------------------------------------------------------+
//|                                     period_converter_All_kai.mq4 |
//|              Original Copyright ?2005, MetaQuotes Software Corp. |
//|            Original Copyright https://www.mql5.com/ru/code/11201 |
//| Modified by RootCauseMarketing based on Period_Converter_ALL.mq4 |
//|                     https://www.mql5.com/en/users/mt4kabukimono/ |
//+------------------------------------------------------------------+
#property copyright		"Copyright 2023 Modified by RootCauseMarketing"
#property link			"https://www.metaquotes.net"
#property version		"1.02"	//
#property description	"Convert historical data from M1 to M1, M5, M15, M30, H1, H4, D1, W1 and MN, specifying the start date.";
#property strict
#property show_inputs

input datetime	stdate = D'2020.01.01 00:00';	// Start Date

/* ---------------------------------------------------------------------
How to use this script.
1. Download or import your historical data.
2. Close all charts and restart MT4.
3. Menu->File->Open Offline, open an offline chart of the target symbol M1.
*NOTICE* The target offline chart must be marked in grey.
4. Execute "period_converter_all_kai" from the script folder.
5. Enter "Start Date" and press OK.
6. Wait for the message "Converting to period(1), bars to end: 0".
7. Restart MT4 and check all timeframes.
------------------------------------------------------------------------ */

int				ExtHandle = -1;
static	int		ArrPeriod[];
//+------------------------------------------------------------------+
//| script program start function|
//+------------------------------------------------------------------+
int start()
  {
   if(Period() != PERIOD_M1)
     {
      MessageBox("Start Period Must be M1.");
      return(0);
     }
   ArrayResize(ArrPeriod, 9);
   ArrPeriod[0] = 5;
   ArrPeriod[1] = 15;
   ArrPeriod[2] = 30;
   ArrPeriod[3] = 60;
   ArrPeriod[4] = 240;
   ArrPeriod[5] = 1440;
   ArrPeriod[6] = 10080;
   ArrPeriod[7] = 43200;
   ArrPeriod[8] = 1;	// add rcm
   int	i, start_pos, i_time, e_time, time0, last_fpos, periodseconds;
   double d_open, d_low, d_high, d_close, d_volume;
   int	hwnd = 0, cnt = 0;

//---- History header
   int version = 400;
   string c_copyright = "(C)opyright 2003, MetaQuotes Software Corp.";
   string c_symbol = Symbol();
   int i_period = 1;
   int i_digits = Digits;
   int i_unused[13];
   string Comm = "";
   for(int qq = 0; qq < ArraySize(ArrPeriod); qq++)
     {
      //if(ArrPeriod[qq]==0){ continue; }		// for debug
      i_period = Period()*ArrPeriod[qq];
      Comm = "Converting to Period (" + IntegerToString(i_period) + "), bars to end: ";
      //----
      ExtHandle = FileOpenHistory(c_symbol + IntegerToString(i_period) + ".hst", FILE_BIN|FILE_WRITE|FILE_SHARE_WRITE);
      if(ExtHandle < 0)
         return(-1);
      cnt = 0;

      //---- write history file header
      FileWriteInteger(ExtHandle, version, LONG_VALUE);
      FileWriteString(ExtHandle, c_copyright, 64);
      FileWriteString(ExtHandle, c_symbol, 12);
      FileWriteInteger(ExtHandle, i_period, LONG_VALUE);
      FileWriteInteger(ExtHandle, i_digits, LONG_VALUE);
      FileWriteInteger(ExtHandle, 0, LONG_VALUE); //timesign
      FileWriteInteger(ExtHandle, 0, LONG_VALUE); //last_sync
      FileWriteArray(ExtHandle, i_unused, 0, 13);

      //---- find start bar no from start date
      periodseconds = i_period*60;
      start_pos = iBarShift(NULL,PERIOD_CURRENT, stdate, true);
      if(start_pos<0)
        {
         start_pos = iBarShift(NULL,PERIOD_CURRENT, stdate, false)-1;
        }
      if(start_pos<0)
        {
         start_pos = Bars - 1;
        }

      // init data
      d_open = Open[start_pos];
      d_low = Low[start_pos];
      d_high = High[start_pos];
      d_volume = (double)Volume[start_pos];
      d_close = Close[start_pos];														// add rcm

      //---- set next from(i_time) to(e_time)
      time0 = (int)Time[start_pos];
      if(i_period == 10080)
        {
         i_time = ((int)(time0/(1440*60))*(1440*60))-TimeDayOfWeek((datetime)time0)*(1440*60);
         e_time = i_time+periodseconds;
        }
      else
         if(i_period == 43200)
           {
            i_time = (int)StringToTime(IntegerToString(TimeYear((datetime)time0))+"."+IntegerToString(TimeMonth((datetime)time0))+".1");
            e_time = (int)StringToTime(IntegerToString(TimeYear((datetime)time0))+"."+IntegerToString(TimeMonth((datetime)time0)+1)+".1");
           }
         else
           {
            i_time = ((int)(time0/periodseconds)*periodseconds);
            e_time = i_time+periodseconds;
           }
      //Print(__LINE__ +" start_pos:"+ time0 +" from:"+ (datetime)i_time +" to:"+ (datetime)e_time);

      for(i = start_pos - 1; i >= 0; i--)
        {
         if(MathMod(i, 1000) == 0)
            Comment(Comm + " " + IntegerToString(i) +"\nFrom "+ TimeToString(Time[start_pos]) +" to "+ TimeToString((datetime)e_time));
         time0 = (int)Time[i];
         if(time0 >= e_time || i == 0)
           {
            if(i==0)
              {
               Print(IntegerToString(__LINE__)+": lastRecord qq:"+ IntegerToString(qq) +" ps:"+ IntegerToString(periodseconds/60) +" t0:"+ TimeToString((datetime)time0) +" from:"+ TimeToString((datetime)(i_time))  +" to:"+ TimeToString((datetime)e_time) +" i:"+ IntegerToString(i));
              }
            if(i == 0 && time0 < e_time)
              {
               d_volume += (double)Volume[0];
               if(Low[0] < d_low)
                  d_low = Low[0];
               if(High[0] > d_high)
                  d_high = High[0];
               d_close = Close[0];
              }
            last_fpos = (int)FileTell(ExtHandle);
            FileWriteInteger(ExtHandle, i_time, LONG_VALUE);
            FileWriteDouble(ExtHandle, d_open, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_low, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_high, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_close, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_volume, DOUBLE_VALUE);
            FileFlush(ExtHandle);
            cnt++;

            //---- set next from(i_time) to(e_time)
            if(i_period == 10080)
              {
               i_time = ((int)(time0/(1440*60))*(1440*60))-TimeDayOfWeek((datetime)time0)*(1440*60);
               e_time = i_time+periodseconds;
              }
            else
               if(i_period == 43200)
                 {
                  i_time = (int)StringToTime(IntegerToString(TimeYear((datetime)time0))+"."+IntegerToString(TimeMonth((datetime)time0))+".1");
                  e_time = (int)StringToTime(IntegerToString(TimeYear((datetime)time0))+"."+IntegerToString(TimeMonth((datetime)time0)+1)+".1");
                 }
               else
                 {
                  i_time = ((int)(time0/periodseconds)*periodseconds);
                  e_time = i_time+periodseconds;
                 }
            //Print(__LINE__ +" start_pos:"+ time0 +" from:"+ (datetime)i_time +" to:"+ (datetime)e_time);	//for debug
            d_open = Open[i];
            d_low = Low[i];
            d_high = High[i];
            d_close = Close[i];
            d_volume = (double)Volume[i];
            //if(i==0){  Print(__LINE__+": st:"+ start_pos +" pe:"+ (periodseconds/60) +" qq:"+ qq +" t0:"+ (datetime)time0 +">= it:"+ (datetime)(i_time) +" i:"+ i); }
            //break;	//for debug
           }
         else
           {
            d_volume += (double)Volume[i];
            if(Low[i] < d_low)
               d_low = Low[i];
            if(High[i] > d_high)
               d_high = High[i];
            d_close=Close[i];
           }
        }
      FileFlush(ExtHandle);
      if(ExtHandle >= 0)
        {
         FileClose(ExtHandle);
         ExtHandle = -1;
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//||
//+------------------------------------------------------------------+
void deinit()
  {
   if(ExtHandle >= 0)
     {
      FileClose(ExtHandle);
      ExtHandle = -1;
     }
//Comment("");
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
