//+------------------------------------------------------------------+
//|                                                   RS_session.mq5 |
//|                                      Copyright © 2006, DVYU inc. |
//|                                                     dvyu@mail.ru |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2006, DVYU inc."
//--- link to the website of the author
#property link      "dvyu@mail.ru"
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- buffers are not used for indicator calculation and drawing
#property indicator_buffers 0
//--- no graphical constructions
#property indicator_plots   0
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Hour //Type of constant
  {
   H00=0,    //00
   H01,      //01
   H02,      //02
   H03,      //03
   H04,      //04
   H05,      //05
   H06,      //06
   H07,      //07
   H08,      //08
   H09,      //09
   H10,      //10
   H11,      //11
   H12,      //12
   H13,      //13
   H14,      //14
   H15,      //15
   H16,      //16
   H17,      //17
   H18,      //18
   H19,      //19
   H20,      //20
   H21,      //21
   H22,      //22
   H23,      //23
  };
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Min //Type of constant
  {
   M00=0,    //00
   M01,      //01
   M02,      //02
   M03,      //03
   M04,      //04
   M05,      //05
   M06,      //06
   M07,      //07
   M08,      //08
   M09,      //09
   M10,      //10
   M11,      //11
   M12,      //12
   M13,      //13
   M14,      //14
   M15,      //15
   M16,      //16
   M17,      //17
   M18,      //18
   M19,      //19
   M20,      //20
   M21,      //21
   M22,      //22
   M23,      //23
   M24,      //24
   M25,      //25
   M26,      //26
   M27,      //27
   M28,      //28
   M29,      //29
   M30,      //30
   M31,      //31
   M32,      //32
   M33,      //33
   M34,      //34
   M35,      //35
   M36,      //36
   M37,      //37
   M38,      //38
   M39,      //39
   M40,      //40
   M41,      //41
   M42,      //42
   M43,      //43
   M44,      //44
   M45,      //45
   M46,      //46
   M47,      //47
   M48,      //48
   M49,      //49
   M50,      //50
   M51,      //51
   M52,      //52
   M53,      //53
   M54,      //54
   M55,      //55
   M56,      //56
   M57,      //57
   M58,      //58
   M59       //59
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input string SessionSirName="Asian";      // Session name
input Hour   StartHour=H08;               // Session start hour
input Min    StartMinute=M00;             // Session start minute
input uint   SessionTime=400;             // Session time in minutes
input color  Color_Session = clrLavender; // Session color
//+----------------------------------------------+
string ObjName;
int  StartHourSec,StartMinuteSec,SessionTimeSec;
//+------------------------------------------------------------------+
//|  Creating an equidistant channel                                 |
//+------------------------------------------------------------------+
void CreateChannel(long     chart_id,      // Chart ID
                   string   name,          // object name
                   int      nwin,          // window index
                   datetime time1,         // time 1
                   double   price1,        // price 1
                   datetime time2,         // time 2
                   double   price2,        // price 2
                   datetime time3,         // time 3
                   double   price3,        // price 3
                   color    Color,         // channel color 
                   bool     background,    // line background display
                   string   text)          // text
  {
   ObjectCreate(chart_id,name,OBJ_CHANNEL,nwin,time1,price1,time2,price2,time3,price3);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);       //color filling of the object 
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background); //object in the background
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");     //tooltip disabled
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);       //object in the background
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_LEFT,true);   //beam continues to the left
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);  //beam continues to the right
  }
//+------------------------------------------------------------------+
//|  Resetting the equidistant channel                               |
//+------------------------------------------------------------------+
void SetChannel(long     chart_id,      // Chart ID
                string   name,          // object name
                int      nwin,          // window index
                datetime time1,         // time 1
                double   price1,        // price 1
                datetime time2,         // time 2
                double   price2,        // price 2
                datetime time3,         // time 3
                double   price3,        // price 3
                color    Color,         // channel color
                bool     background,    // line background display
                string   text)          // text
  {
   if(ObjectFind(chart_id,name)==-1) CreateChannel(chart_id,name,nwin,time1,price1,time2,price2,time3,price3,Color,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectMove(chart_id,name,2,time3,price3);
     }
  }
//+------------------------------------------------------------------+   
//| iBarShift() function                                             |
//+------------------------------------------------------------------+  
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)
  {
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
   ObjName=SessionSirName+" Session";
   StartHourSec=int(StartHour)*60*60;
   StartMinuteSec=int(StartMinute)*60;
   SessionTimeSec=int(SessionTime)*60;
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- Creating labels for displaying in DataWindow and the name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"RS_session");
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
   ObjectDelete(0,ObjName);
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   Deinit();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   datetime iTime[1];
//--- copy newly appeared data in the array
   if(CopyTime(Symbol(),PERIOD_D1,time[0],1,iTime)<=0) return(0);

   datetime StartTime=datetime(iTime[0]+StartHourSec+StartMinuteSec);
   datetime EndTime=datetime(StartTime+SessionTimeSec);

   if(StartTime>TimeCurrent())
     {
      Deinit();
      return(0);
     }

   int StartBar=iBarShift(NULL,PERIOD_CURRENT,StartTime);
   int EndBar=MathMax(iBarShift(NULL,PERIOD_CURRENT,EndTime),0);
   int Count=StartBar-EndBar;
   double C=close[StartBar];

   SetChannel(0,ObjName,0,StartTime,C,StartTime,0.0,EndTime,0.0,Color_Session,true,ObjName);
//---
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+