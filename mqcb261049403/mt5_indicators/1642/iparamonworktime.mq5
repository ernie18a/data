//+------------------------------------------------------------------+
//|                                            i-ParamonWorkTime.mq5 |
//|                          Copyright © 2006, Kim Igor V. aka KimIV |
//|                                              http://www.kimiv.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Kim Igor V. aka KimIV"
#property link      "http://www.kimiv.ru"
#property description "The iParamon WorkTime indicator"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 0 
//---- only 0 plots are used
#property indicator_plots   0


//+-----------------------------------+
//|  declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int    NumberOfDays=5;            // Number of days in history
input string Begin_1     ="08:00";      // Start time 1
input string End_1       ="11:00";      // End time 1
input color  Color_1     =clrDarkBlue;  // Paramon color 1
input string Begin_2     ="14:00";      // Start time 2
input string End_2       ="17:00";      // End time 2
input color  Color_2     =clrPurple;    // Paramon color 2
input bool   HighRange   =false;
//+-----------------------------------+

//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| i-ParamonWorkTime indicator initialization function              | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=NumberOfDays*PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"i-ParamonWorkTime");

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| i-ParamonWorkTime deinitialization function                      |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   for(int i=0; i<NumberOfDays; i++)
     {
      ObjectDelete(0,"PWT1"+string(i));
      ObjectDelete(0,"PWT2"+string(i));
     }
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+ 
//| i-ParamonWorkTime iteration function                             | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   datetime dt=TimeCurrent();
   for(int i=0; i<NumberOfDays; i++)
     {
      DrawRectangle(dt,"PWT1"+string(i),Begin_1,End_1,Color_1,high,low);
      DrawRectangle(dt,"PWT2"+string(i),Begin_2,End_2,Color_2,high,low);
      dt=decDateTradeDay(dt);
      MqlDateTime ttt;
      TimeToStruct(dt,ttt);

      while(ttt.day_of_week>5)
        {
         dt=decDateTradeDay(dt);
         TimeToStruct(dt,ttt);
        }
     }
//----
   ChartRedraw(0);    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Drawing objects in the chart                                     |
//| Parameters:                                                      |
//|   dt - date of the trading day                                   |
//|   no - name of the object                                        |
//|   tb - starting time of the session                              |
//|   te - ending time of the session                                |
//+------------------------------------------------------------------+
void DrawRectangle(datetime dt,string no,string tb,string te,color clr,const double &High[],const double &Low[])
  {
//----
   datetime t1,t2;
   double p1,p2;
   int b1,b2;
//----
   t1=StringToTime(TimeToString(dt,TIME_DATE)+" "+tb);
   t2=StringToTime(TimeToString(dt,TIME_DATE)+" "+te);
//----
   b1=iBarShift(NULL,0,t1);
   b2=iBarShift(NULL,0,t2);
//----   
   int res=b1-b2;
   int extr=MathMax(0,ArrayMaximum(High,b2,res));
   p1=High[extr];
   extr=MathMax(0,ArrayMinimum(Low,b2,res));
   p2=Low[extr];

   if(!HighRange)
     {
      p1=0;
      p2=2*p2;
     }
//----
   SetRectangle(0,no,0,t1,p1,t2,p2,clr,false,no);
//----
  }
//+------------------------------------------------------------------+
//| Decrease date on one trading day                                 |
//| Parameters:                                                      |
//|   dt - date of the trading day                                   |
//+------------------------------------------------------------------+
datetime decDateTradeDay(datetime dt)
  {
//----
   MqlDateTime ttt;
   TimeToStruct(dt,ttt);
   int ty=ttt.year;
   int tm=ttt.mon;
   int td=ttt.day;
   int th=ttt.hour;
   int ti=ttt.min;
//----
   td--;
   if(td==0)
     {
      tm--;

      if(!tm)
        {
         ty--;
         tm=12;
        }

      if(tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
      if(tm==2) if(!MathMod(ty,4)) td=29; else td=28;
      if(tm==4 || tm==6 || tm==9 || tm==11) td=30;
     }

   string text;
   StringConcatenate(text,ty,".",tm,".",td," ",th,":",ti);
//----
   return(StringToTime(text));
  }
//+------------------------------------------------------------------+   
//| iBarShift() function                                             |
//+------------------------------------------------------------------+  
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)

// iBarShift(symbol, timeframe, time)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----
  }
//+------------------------------------------------------------------+
//| Creating rectangle object:
//+------------------------------------------------------------------+
void CreateRectangle
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // time 1
 double   price1,        // price 1
 datetime time2,         // time 2
 double   price2,        // price 2
 color    Color,         // line color
 bool     background,    // line background display
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_RECTANGLE,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); // tooltip disabling
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); // background object
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the rectangle object                          |
//+------------------------------------------------------------------+
void SetRectangle
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // time 1
 double   price1,        // price 1
 datetime time2,         // time 2
 double   price2,        // price 2
 color    Color,         // line color
 bool     background,    // line background display
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRectangle(chart_id,name,nwin,time1,price1,time2,price2,Color,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
  }
//+------------------------------------------------------------------+
