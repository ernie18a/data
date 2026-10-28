//+------------------------------------------------------------------+ 
//|                                           X2MA_HTF_Signal_BG.mq5 | 
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- indicator version
#property version   "1.00"
//+------------------------------------------------+ 
//| Indicator drawing parameters                   |
//+------------------------------------------------+ 
//--- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------+ 
//| Declaration of constants                       |
//+------------------------------------------------+
#define INDICATOR_NAME      "X2MA"              // The name of the indicator
#define RESET               0                   // A constant for returning the indicator recalculation command to the terminal
#define NAMES_SYMBOLS_FONT  "Georgia"           // Indicator name font
#define BUY_SOUND           "alert.wav"         // Audio file for a long position opening
#define SELL_SOUND          "alert.wav"         // Audio file for a short position opening
#define BUY_ALERT_TEXT      "Buy signal"        // Alert text for a long position opening
#define SELL_ALERT_TEXT     "Sell signal"       // Alert text for a short position opening
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
//+------------------------------------------------+ 
//| Enumeration for the level actuation indication |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE // Type of constant
  {
   OnlySound,   // only sound
   OnlyAlert    // only alert
  };
//+------------------------------------------------+ 
//|  Declaration of enumerations                   |
//+------------------------------------------------+ 
enum Applied_price_      //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------+
//|  CXMA class description                        |
//+------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------+ 
//| Input parameters for drawing a session         |
//+------------------------------------------------+
input bool   SessionDrawOff=false;                     // Show session in a non-session period 
input string SessionSirName="Asian";                   // Session name
input Hour   StartHour=H00;                            // Session start hour
input Min    StartMinute=M00;                          // Session start minute
input uint   SessionTime=480;                          // Session duration in minutes
input color Up_Color=clrPaleTurquoise;                 // Growth color
input color Buy_Color=clrLime;                         // Buy color
input color Sell_Color=clrDeepPink;                    // Fall color
input color Dn_Color=clrLightPink;                     // Sell color
//+------------------------------------------------+ 
//|  Indicator input parameters                    |
//+------------------------------------------------+ 
input string Symbol_="";                               // Financial instrument
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;             // Indicator timeframe for the indicator calculation
input Smooth_Method MA_Method1=MODE_SMA;               // Method of averaging of the first smoothing 
input int Length1=12;                                  // Depth of the first smoothing                    
input int Phase1=15;                                   // Parameter of the first smoothing
//--- Phase1: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- Phase1: for VIDIA it is a CMO period, for AMA it is a slow average period
input Smooth_Method MA_Method2=MODE_JJMA;              // Method of averaging of the second smoothing 
input int Length2= 5;                                  // Depth of the second smoothing 
input int Phase2=15;                                   // Parameter of the second smoothing
//--- Phase2: for JJMA it varies within the range -100 ... +100 and influences the quality of the transient period;
//--- Phase2: for VIDIA it is a CMO period, for AMA it is a slow average period
input Applied_price_ IPC=PRICE_CLOSE;                  // Price constant
//--- indicator display settings
input uint SignalBar=0;                                // Signal bar index, 0 is a current bar
input string Symbols_Sirname=INDICATOR_NAME"_Label_";  // Indicator labels name
input color IndName_Color=DarkOrchid;                  // Indicator name color
input uint Font_Size=10;                               // Indicator name font size
input int X_1=5;                                       // Horizontal shift of the name
input int Y_1=-15;                                     // Vertical shift of the name
input bool ShowIndName=true;                           // Indicator name display
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
//--- alert settings
input ENUM_ALERT_MODE alert_mode=OnlySound;            // Triggering indication option
input uint AlertCount=0;                               // Number of produced alerts
input bool Push=true;                                  // Allow push notifications
//+-----------------------------------+
//--- declaration of integer variables for the indicators handles
int X2MA_Handle;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables of the horizontal and vertical indices location
uint X_1_,Y_1_;
//--- declaration of variables for labels names
string name1,IndName,Symb;
//--- declaration of variables for alert text
string BuySignal,SellSignal;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
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
//---
   ObjectCreate(chart_id,name,OBJ_CHANNEL,nwin,time1,price1,time2,price2,time3,price3);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);            //color filling of the object 
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);             //
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);      //object in the background
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");          //tooltip disabled
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);            //object in the background
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_LEFT,true);        //beam continues to the left
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);       //beam continues to the right
//---
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
//---
   if(ObjectFind(chart_id,name)==-1) CreateChannel(chart_id,name,nwin,time1,price1,time2,price2,time3,price3,Color,background,text);
   else
     {
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectMove(chart_id,name,2,time3,price3);
     }
//---
  }
//+------------------------------------------------------------------+
//|  Creation of a text label                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // chart ID
                  string name,             // Object name
                  int    nwin,             // window index
                  ENUM_BASE_CORNER corner, // base corner location
                  ENUM_ANCHOR_POINT point, // anchor point location
                  int    X,                // the distance from the base corner along the X-axis in pixels
                  int    Y,                // the distance from the base corner along the Y-axis in pixels
                  string text,             // text
                  string textTT,           // tooltip text
                  color  Color,            // text color
                  string Font,             // text font
                  int    Size)             // font size
  {
//---
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); // background object
//---
  }
//+------------------------------------------------------------------+
//|  Text label reinstallation                                       |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // chart ID
               string name,             // Object name
               int    nwin,             // window index
               ENUM_BASE_CORNER corner, // base corner location
               ENUM_ANCHOR_POINT point, // anchor point location
               int    X,                // the distance from the base corner along the X-axis in pixels
               int    Y,                // the distance from the base corner along the Y-axis in pixels
               string text,             // text
               string textTT,           // tooltip text
               color  Color,            // text color
               string Font,             // text font
               int    Size)             // font size
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,textTT,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
      ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
     }
//---
  }
//+------------------------------------------------------------------+   
//| iBarShift() function                                             |
//+------------------------------------------------------------------+  
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)
  {
//---
   if(time<0) return(-1);
   datetime Arr[],time1;
//---
   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);
//---
   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//---
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
   CXMA XMA;
//--- initialization of variables of the start of data calculation  
   min_rates_total=XMA.GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_total+=XMA.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total+=int(SignalBar)+1+3;
//---
   ObjName=SessionSirName+" Session";
   StartHourSec=int(StartHour)*60*60;
   StartMinuteSec=int(StartMinute)*60;
   SessionTimeSec=int(SessionTime)*60;
//--- initialization of variables
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();
//---
   int X_0=5;
   int Yn=30;
//---
   if(ShowIndName)
     {
      Y_1_=Yn+Y_1;
      X_1_=X_0+X_1;
      name1=Symbols_Sirname+"1";
      StringConcatenate(IndName,INDICATOR_NAME,"(",Symb," ",GetStringTimeframe(Timeframe),")");
     }
//--- getting the handle of the X2MA indicator
   X2MA_Handle=iCustom(Symb,Timeframe,"X2MA",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,IPC,0,0);
   if(X2MA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of the X2MA indicator");
      return(INIT_FAILED);
     }
//---
   BuySignal=IndName+": "+BUY_ALERT_TEXT;
   SellSignal=IndName+": "+SELL_ALERT_TEXT;
//--- initializations of a variable for the indicator short name
   string shortname=name1;
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//---
   if(ObjectFind(0,ObjName)!=-1) ObjectDelete(0,ObjName);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---
   Deinit();
   if(ObjectFind(0,name1)!=-1) ObjectDelete(0,name1);
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(BarsCalculated(X2MA_Handle)<min_rates_total) return(RESET);
//---
   datetime iTime[1];
//--- copy newly appeared data in the array
   if(CopyTime(Symbol(),PERIOD_D1,time[rates_total-1],1,iTime)<=0) return(RESET);
//---
   datetime StartTime=datetime(iTime[0]+StartHourSec+StartMinuteSec);
   datetime EndTime=datetime(StartTime+SessionTimeSec);
//---
   if(StartTime>TimeCurrent() || (!SessionDrawOff && TimeCurrent()>EndTime))
     {
      Deinit();
      return(RESET);
     }
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(close,true);
   int StartBar=iBarShift(NULL,PERIOD_CURRENT,StartTime);
   int EndBar=MathMax(iBarShift(NULL,PERIOD_CURRENT,EndTime),0);
//---- declaration of local variables
   int trend=0;
   double Mov[3];
   color Color0=clrNONE;
   bool signal=false;
   static uint buycount,sellcount;
   static bool RePush;
//--- calculations of the necessary amount of copied data for the CopyBuffer function
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      buycount=0;
      sellcount=0;
     }
   else
     {
      if(prev_calculated==rates_total && SignalBar && (!buycount || !sellcount)) return(rates_total);
     }
//--- copy newly appeared data in the array  
   if(CopyBuffer(X2MA_Handle,0,SignalBar,3,Mov)<=0) return(prev_calculated);
//---
   if(Mov[1]<Mov[2])
     {
      trend=+1;
      if(Mov[0]>Mov[1]) signal=true;
     }
//---
   if(Mov[1]>Mov[2])
     {
      trend=-1;
      if(Mov[0]<Mov[1]) signal=true;
     }
//--- set alerts counters to the initial position   
   if(prev_calculated!=rates_total && AlertCount && signal)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
     }
//---- getting buy signals
   if(trend>0)
     {
      if(signal)
        {
         Color0=Buy_Color;
         if(Push && SignalBar && prev_calculated!=rates_total) RePush=true;
         if(RePush) if(SendNotification(BuySignal)) RePush=false;

         if(buycount && SignalBar)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(BuySignal); break;
               case OnlySound: PlaySound(BUY_SOUND); break;
              }
            buycount--;
           }
        }
      else Color0=Up_Color;
     }
//---- Getting sell signals
   if(trend<0)
     {
      if(signal)
        {
         Color0=Sell_Color;
         if(Push && SignalBar && prev_calculated!=rates_total) RePush=true;
         if(RePush) if(SendNotification(SellSignal)) RePush=false;

         if(sellcount && SignalBar)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(SellSignal); break;
               case OnlySound: PlaySound(SELL_SOUND); break;
              }

            sellcount--;
           }
        }
      else Color0=Dn_Color;;
     }
//--- Show signals on the chart
   SetChannel(0,ObjName,0,StartTime,close[StartBar],StartTime,0.0,EndTime,0.0,Color0,true,ObjName);
   if(ShowIndName)
      SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1_,Y_1_,IndName,IndName,IndName_Color,NAMES_SYMBOLS_FONT,Font_Size);
//---
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
