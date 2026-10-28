//+------------------------------------------------------------------+
//|                                 PeriodConverterAllTimeframes.mq4 |
//|                                          Copyright 2017,fxMeter. |
//|                            https://www.mql5.com/en/users/fxmeter |
//+------------------------------------------------------------------+
//2018-1-25 14:29:27 publish to codebase  
//https://www.mql5.com/en/code/19839
//When we do back-test, we usually download M1 data from a third party ,
//and then convert M1 data to other timeframes.
//This script helps to convert M1 to M5,M15,M30,H1,H4,D1,W1,MN, 
//This script must run on M1 chart.

//2017-12-28 19:16:09  关于日线,周线,月线开盘时间的问题,已经解决:ConverterOpenTime().
//2017-12-27 16:40:35  改写MT4自带的PeriodConverter转换脚本,用来转换M1 hst文件为M5,M15,M30,H1,H4,D1,W1,MN
//1.脚本必须在M1图上运行
//2.如果转换为D1,W1,MN的数据,则存在开盘时间不对的问题,所以默认是不转换D1,W1,MN,
//  一般平台对这3个周期的数据至少有5年,应付测试是足够了。

#property copyright "Copyright 2017,fxMeter."
#property link      "https://www.mql5.com/en/users/fxmeter"
#property strict
#property strict
#property show_inputs

input bool ConverterD1=false;
input bool ConverterW1=false;
input bool ConverterMN=false;

int       ExtHandle=-1;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(Period()!=1)
     {
      Alert("Script must run on M1 chart");
      return;
     }

   WriteHst(PERIOD_M5);
   WriteHst(PERIOD_M15);
   WriteHst(PERIOD_M30);
   WriteHst(PERIOD_H1);
   WriteHst(PERIOD_H4);
   if(ConverterD1)WriteHst(PERIOD_D1);
   if(ConverterW1)WriteHst(PERIOD_W1);
   if(ConverterMN)WriteHst(PERIOD_MN1);

   Alert(WindowExpertName()+": Finished");

   MqlDateTime dt;

//---
  }
//+------------------------------------------------------------------+

void WriteHst(int timeframe)
  {
   datetime time0;
   ulong    lastFilePos=0;
   long     lastVolume=0;
   int      i,startPos,periodSeconds;
   int      cnt=0;
//---- History header
   int      fileVersion=401;
   string   copyRight;
   string   symbol=Symbol();
   int      periods=timeframe; //  periods in minute,  Period()*timeframe,  Period()==1
   int      digits=Digits;
   int      unused[13];
   MqlRates rate;
//---  
   ExtHandle=FileOpenHistory(symbol+(string)periods+".hst",FILE_BIN|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
   if(ExtHandle<0)
      return;
   copyRight="Copyright 2017, MetaQuotes Software Corp.";
   ArrayInitialize(unused,0);
//--- write history file header
   FileWriteInteger(ExtHandle,fileVersion,LONG_VALUE);
   FileWriteString(ExtHandle,copyRight,64);
   FileWriteString(ExtHandle,symbol,12);
   FileWriteInteger(ExtHandle,periods,LONG_VALUE);
   FileWriteInteger(ExtHandle,digits,LONG_VALUE);
   FileWriteInteger(ExtHandle,0,LONG_VALUE);
   FileWriteInteger(ExtHandle,0,LONG_VALUE);
   FileWriteArray(ExtHandle,unused,0,13);
//--- write history file
   periodSeconds=periods*60;
   startPos=Bars-1;
   rate.open=Open[startPos];
   rate.low=Low[startPos];
   rate.high=High[startPos];
   rate.tick_volume=(long)Volume[startPos];
   rate.spread=0;
   rate.real_volume=0;
//--- normalize open time
   rate.time=ConverterOpenTime(timeframe,Time[startPos]);

//---   
   for(i=startPos-1; i>=0; i--)
     {
      time0=Time[i];
      if(timeframe==PERIOD_MN1)periodSeconds=MonthSeconds(time0);
      //---
      if(time0>=rate.time+periodSeconds || i==0)
        {
         //--- i==0 即当下最右边的K线
         if(i==0 && time0<rate.time+periodSeconds)
           {
            rate.tick_volume+=(long)Volume[0];
            if(rate.low>Low[0])rate.low=Low[0];
            if(rate.high<High[0])rate.high=High[0];
            rate.close=Close[0];
           }

         lastFilePos=FileTell(ExtHandle);
         lastVolume=(long)Volume[i];
         FileWriteStruct(ExtHandle,rate);
         cnt++;
         if(time0>=rate.time+periodSeconds)
           {
            rate.time=ConverterOpenTime(timeframe,time0);
            rate.open=Open[i];
            rate.low=Low[i];
            rate.high=High[i];
            rate.close=Close[i];
            rate.tick_volume=lastVolume;
           }
        }
      else
        {
         rate.tick_volume+=(long)Volume[i];
         if(rate.low>Low[i])rate.low=Low[i];
         if(rate.high<High[i])rate.high=High[i];
         rate.close=Close[i];
        }
     }
   FileFlush(ExtHandle);

   if(ExtHandle>=0)
     {
      FileClose(ExtHandle);
      ExtHandle=-1;
     }
   string fn=symbol+(string)periods+".hst";

   Alert(fn," OK, Written:",cnt);
  }
//+------------------------------------------------------------------+
//---把t转换成正确的日线，周线，月线开盘时间 
//---Calculate the correct Open Time.
datetime ConverterOpenTime(int tf,datetime t)
  {
   if(tf<PERIOD_D1)
     {
      int periodSeconds=tf*60;
      datetime ot=t/periodSeconds;//计算分钟数，取整数，作为高级别的开仓时间，以分钟算
      ot*=periodSeconds;//转换成以秒算
      return(ot);
     }

   MqlDateTime qt;
   TimeToStruct(t,qt);
   int y = qt.year;
   int m = qt.mon;
   int d = qt.day;
   int w = qt.day_of_week;
   int h = qt.hour;
   int min=qt.min;

   if(tf==PERIOD_D1)
     {
      string st=StringFormat("%4d.%02d.%02d",y,m,d);
      datetime ot=StringToTime(st);
      return(ot);
     }

   if(tf==PERIOD_W1)
     {
      datetime ot_week=0;
      ot_week=t -w*1440*60-h*60*60-min*60;
      MqlDateTime qt1;
      TimeToStruct(ot_week,qt1);
      y=qt1.year;
      m=qt1.mon;
      d=qt1.day;
      string st=StringFormat("%4d.%02d.%02d",y,m,d);
      datetime ot=StringToTime(st);
      return(ot);
     }

   if(tf==PERIOD_MN1)
     {
      int day=1;
      string st=StringFormat("%4d.%02d.%02d",y,m,day);
      datetime ot=StringToTime(st);
      return(ot);
     }

   return(t);
  }
//+------------------------------------------------------------------+
//---Calculate the correct seconds of month.
int MonthSeconds(datetime t)
  {
   int seconds=0;
   bool leepYear=false;
   MqlDateTime qt;
   TimeToStruct(t,qt);
   int y = qt.year;
   int m = qt.mon;

   if(y%400==0)leepYear=true;
   else
     {
      if(y%4==0 && y%100!=0)leepYear=true;
     }

   if(m==4 || m==6 || m==9 || m==11)
     {
      seconds=30*24*3600;
     }
   else if(m==2)
     {
      if(leepYear)seconds=29*24*3600;
      else seconds=28*24*3600;
     }
   else seconds=31*24*3600;

   return(seconds);

  }
//+------------------------------------------------------------------+
