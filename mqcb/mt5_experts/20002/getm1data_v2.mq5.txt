//+------------------------------------------------------------------+
//|                                                    GetM1Data.mq5 |
//|                                          Copyright 2017,fxMeter. |
//|                                https://mql5.com/en/users/fxmeter |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,fxMeter."
#property link      "https://mql5.com/en/users/fxmeter"
#property version   "1.00"
#property strict
//+-----------------------------------------------------------------------------+
//| Class    CMT4HstBar                                                         |
//| Purpose: Get M1 data in tester and write it into hst file.                  |
//|                                                                             |
//+-----------------------------------------------------------------------------+
class CMT4HstBar
  {
private:
   //--- hst file head data structure   
   int               m_digit;  //the digit of after point
   int               m_version;//the hst file version. it should be 401
   int               m_timeframe; //the time frame of hst chart
   int               m_unused[13];//unused space
   string            m_symbol;//the max length is 11 chars
   string            m_copyright;//copyright,the max length is 64 chars
   string            m_filename;//the hst file name

public:
                     CMT4HstBar();
                     CMT4HstBar(string sym,ENUM_TIMEFRAMES timeframe);
                    ~CMT4HstBar(){};

public:
   void              SaveData(int fileType=0);//write hst file after testing. the file is in the tester folder.  
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMT4HstBar::CMT4HstBar(void)
  {
   m_digit=_Digits;
   m_version=401;
   m_timeframe=_Period;
   ArrayInitialize(m_unused,0);
   m_symbol=StringSubstr(Symbol(),0,11);//max length 11.
   m_copyright= "Copyright 2017, MetaQuotes Software Corp.";
   m_filename = m_symbol+(string)m_timeframe+".hst";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMT4HstBar::CMT4HstBar(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   m_digit=_Digits;
   m_version=401;
   m_timeframe=(timeframe==0) ? Period():timeframe;
   ArrayInitialize(m_unused,0);
   m_symbol=StringSubstr(symbol,0,11);//max length 11.
   m_copyright= "Copyright 2017, MetaQuotes Software Corp.";
   m_filename = m_symbol+(string)m_timeframe+".hst";
  }
//+------------------------------------------------------------------+
//| SaveData()：write rates to hst file or txt file                  |
//| fileType=0 : hst file                                            |
//| fileType==1: txt file                                            |
//| fileType==2: hst and txt file                                    |
//+------------------------------------------------------------------+
void CMT4HstBar::SaveData(int fileType=0)
  {

   MqlRates rates[];
   int bars=Bars(Symbol(),(ENUM_TIMEFRAMES)m_timeframe);

   if(bars<=0)
     {
      printf("No data");
      return;
     }

   int cnt=CopyRates(Symbol(),(ENUM_TIMEFRAMES)m_timeframe,0,bars,rates);
   printf("bars = %d,copied number = %d",bars,cnt);
   if(cnt<=0)
     {
      Alert("copied data error#",GetLastError());
      return;
     }

   if(fileType==0 || fileType==2)
     {
      int handle=FileOpen(m_filename,FILE_BIN|FILE_WRITE|FILE_ANSI);
      if(handle==-1)
        {
         printf("Write HST file head %s  error# %d",m_filename,GetLastError());
         return;
        }
      //--- write hst file head  
      FileWriteInteger(handle,m_version,INT_VALUE);
      FileWriteString(handle,m_copyright,64);
      FileWriteString(handle,m_symbol,12);// 11+'0'
      FileWriteInteger(handle,m_timeframe,INT_VALUE);
      FileWriteInteger(handle,m_digit,INT_VALUE);
      FileWriteInteger(handle,0,INT_VALUE);
      FileWriteInteger(handle,0,INT_VALUE);
      FileWriteArray(handle,m_unused,0,13);

      //---  write data to hst file
      for(int i=0;i<cnt;i++)
        {
         FileWriteStruct(handle,rates[i]);
        }

      FileClose(handle);
     }

   if(fileType==1 || fileType==2)//.txt
     {
      int handle=FileOpen(m_filename+".txt",FILE_TXT|FILE_WRITE|FILE_ANSI,',');
      if(handle==-1)
        {
         printf("Write TXT file %s  error# %d",m_filename,GetLastError());
         return;
        }
      FileWrite(handle,"Time","Open","High","Low","Close","Vol");
      for(int i=0;i<cnt;i++)
        {
         string t=TimeToString(rates[i].time,TIME_DATE|TIME_MINUTES);
         string op=DoubleToString(rates[i].open,_Digits);
         string hi=DoubleToString(rates[i].high,_Digits);
         string lo=DoubleToString(rates[i].low,_Digits);
         string cl=DoubleToString(rates[i].close,_Digits);
         FileWrite(handle,t,op,hi,lo,cl,rates[i].tick_volume);
        }
      FileFlush(handle);
      FileClose(handle);
     }
  }

//+------------------------------------------------------------------+
CMT4HstBar hstBar(Symbol(),PERIOD_M1);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
   hstBar.SaveData(0);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---  
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
