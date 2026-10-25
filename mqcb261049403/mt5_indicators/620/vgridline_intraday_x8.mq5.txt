//+------------------------------------------------------------------+ 
//|                                        VGridLine_Intraday_X8.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- author of the indicator
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link to the website of the author
#property link "farria@mail.redcom.ru" 
//---- indicator version
#property version   "1.00"
#property description "Time grid mesh. Grid step - 1 week"
#property description "The indicator works at all timeframes less than a hour."
//+----------------------------------------------+ 
//|  Indicator drawing parameters                |
//+----------------------------------------------+ 
//---- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers 1
#property indicator_plots   1
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for storing the value, returning of which to OnCalculate() will lead to the indicator recalculation
#define DAILY_PERIOD_SECOND 86400 // Number of seconds in a day period
#define WEEKLY_PERIOD_SECOND 604800 // Number of seconds in a week period including Sundays
//+----------------------------------------------+ 
//|  Declaration of enumerations                 |
//+----------------------------------------------+ 
enum ENUM_WIDTH //Type of constant
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum STYLE
  {
   SOLID_,     // Solid line
   DASH_,      // Dashed line
   DOT_,       // Dotted line
   DASHDOT_,   // Dot-dash line
   DASHDOTDOT_ // Dot-dash line with double dots
  };
//+----------------------------------------------+ 
//|  Indicator input parameters                  |
//+----------------------------------------------+ 
//---- general settings
input string LinesSirname="VGridLine_Intraday_X8"; // Line name
input uint WeeklyTotal=4;                          // Number of weeks in history for indexing
input uint FutureTotal=1;                          // Number of lines in future for indexing

//---- settings for week bars
input color Line_Color_W=Gold;       // Week line color
input STYLE Line_Style_W=SOLID_;     // Week line style
input ENUM_WIDTH Line_Width_W=w_1;   // Week line width
input bool SetBackground_W=true;     // Week line background display
input uint FutureTotal_W=1;          // Number of lines in empty future history

//---- settings for day bars
input color Line_Color_D=Red;        // Day line color
input STYLE Line_Style_D=SOLID_;     // Day line display style
input ENUM_WIDTH Line_Width_D=w_1;   // Day line width
input bool SetBackground_D=true;     // Day lines background display


//---- settings for intraday bars (8 hours)
input color Line_Color_D1=Lime;       // 8 hours line color
input STYLE Line_Style_D1=DASH_;      // 8 hours line style
input ENUM_WIDTH Line_Width_D1=w_1;   // 8 hours line width
input bool SetBackground_D1=true;     // 8 hours line background display

//---- settings for intraday bars (16 hours)
input color Line_Color_D2=BlueViolet; // 16 hours line color
input STYLE Line_Style_D2=DASH_;      // 16 hours line style
input ENUM_WIDTH Line_Width_D2=w_1;   // 16 hours line width
input bool SetBackground_D2=true;     // 16 hours line background display
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as ring buffers
uint Count_W[],Count_D0[],Count_D1[],Count_D2[];
datetime VLineTime_W[],VLineTime_D0[],VLineTime_D1[],VLineTime_D2[];
//---- declaration of the integer variables for the start of data calculation
uint WeeklyTotal_,LinesTotal_D_,LinesTotal_D,FutureTotal_D;
//---- declaration of lines labels variables
string Sirname_W,Sirname_D[3];
//+------------------------------------------------------------------+
//|  Checking the bar for the day line installation                  |
//+------------------------------------------------------------------+   
bool CheckVLinePoint_D(datetime bartime1,datetime bartime0)
  {
//----
   MqlDateTime tm0,tm1;
   TimeToStruct(bartime0,tm0);
   TimeToStruct(bartime1,tm1);
   if(tm0.day_of_year!=tm1.day_of_year) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//|  Checking the bar for the intraday line installation             |
//+------------------------------------------------------------------+   
bool CheckVLinePoint_DN(datetime bartime1,datetime bartime0,uint hour)
  {
//----
   MqlDateTime tm0,tm1;
   TimeToStruct(bartime0,tm0);
   TimeToStruct(bartime1,tm1);
   if(tm1.hour!=hour && tm0.hour==hour) return(true);
   if(tm0.day_of_year!=tm1.day_of_year && tm0.hour==hour) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+   
bool CheckVLinePoint_W(int bar,datetime bartime)
  {
//----
   MqlDateTime tm;
   TimeToStruct(bartime,tm);
   if(tm.day_of_week==0 || tm.day_of_week==6) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//|  Recalculation of position of the newest element in the array    |
//+------------------------------------------------------------------+  
class CRecount_ArrayZeroPos
  {
public:
   void  Recount_ArrayZeroPos(int &CoArr[],// Return the current value of the price series by the link
                              int Size) // number of the elements in the ring buffer
     {
      //----
      int numb,Max1,Max2;

      Max2=Size;
      Max1=Max2-1;

      m_count--;
      if(m_count<0) m_count=Max1;

      for(int iii=0; iii<Max2; iii++)
        {
         numb=iii+m_count;
         if(numb>Max1) numb-=Max2;
         CoArr[iii]=numb;
        }
      //----
     }
                     CRecount_ArrayZeroPos(){m_count=1;};
protected:
   int               m_count;
  };
//+------------------------------------------------------------------+
//|  Vertical line renaming                                          |
//+------------------------------------------------------------------+
bool RenameVline(long     chart_id,  // chart ID
                 string   oldname,   // object old name
                 string   newname)   // object new name
  {
//----
   if(ObjectFind(chart_id,oldname)>0)
     {
      ObjectSetString(chart_id,oldname,OBJPROP_NAME,newname);
      return(true);
     }
//----
   return(false);
  }
//+------------------------------------------------------------------+
//|  Vertical line creation                                          |
//+------------------------------------------------------------------+
void CreateVline(long     chart_id,      // chart ID
                 string   name,          // object name
                 int      nwin,          // window index
                 datetime time1,         // vertical level time
                 color    Color,         // line color
                 int      style,         // line style
                 int      width,         // line width
                 bool     background,    // line background display
                 string   text)          // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time1,999999999);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
//----
  }
//+------------------------------------------------------------------+
//|  Vertical line reinstallation                                    |
//+------------------------------------------------------------------+
void SetVline(long     chart_id,      // chart ID
              string   name,          // object name
              int      nwin,          // window index
              datetime time1,         // vertical level time
              color    Color,         // line color
              int      style,         // line style
              int      width,         // line width
              bool     background,    // line background display
              string   text)          // text
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateVline(chart_id,name,nwin,time1,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,999999999);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void Deinit()
  {
//----
   int total=ObjectsTotal(0,0,-1)-1;
   string name,sirname;

   for(int numb=total; numb>=0 && !IsStopped(); numb--)
     {
      name=ObjectName(0,numb,0,-1);
      sirname=StringSubstr(name,0,StringLen(LinesSirname));

      if(sirname==LinesSirname) ObjectDelete(0,name);
     }
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- checking the chart period to be enough for the calculation
   if(Period()>PERIOD_H4 || Period()==PERIOD_H3) return;
   Deinit();

//---- initialization of variables of the start of data calculation
   WeeklyTotal_=WeeklyTotal+FutureTotal_W;

   LinesTotal_D=WeeklyTotal_*6;
   FutureTotal_D=FutureTotal;
   LinesTotal_D_=LinesTotal_D+FutureTotal_D;

//---- initialization of line variables for the labels
   Sirname_W=LinesSirname+"_W_";
   Sirname_D[0]=LinesSirname+"_D0_";
   Sirname_D[1]=LinesSirname+"_D1_";
   Sirname_D[2]=LinesSirname+"_D2_";

//---- memory distribution for variables' arrays  
   ArrayResize(Count_W,WeeklyTotal_);
   ArrayResize(VLineTime_W,WeeklyTotal_);
   ArrayResize(Count_D0,LinesTotal_D_);
   ArrayResize(VLineTime_D0,LinesTotal_D_);
   ArrayResize(Count_D1,LinesTotal_D_);
   ArrayResize(VLineTime_D1,LinesTotal_D_);
   ArrayResize(Count_D2,LinesTotal_D_);
   ArrayResize(VLineTime_D2,LinesTotal_D_);

//---- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"VGridLine_Intraday_X8(",LinesSirname,", ",WeeklyTotal,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the chart period to be enough for the calculation
   if(Period()>PERIOD_H4 || Period()==PERIOD_H3) return(RESET);

//---- checking the number of bars to be enough for the calculation
   if(rates_total<2) return(RESET);
   if(prev_calculated==rates_total) return(rates_total);

//---- declarations of local variables 
   string Name;
   datetime Time,TimeCur;
   int limit,bar;
   static datetime LastTime_W=0,LastTime_D[3];
   static CRecount_ArrayZeroPos W,D0,D1,D2;
   ArrayInitialize(LastTime_D,0);

//---- indexing elements in arrays as timeseries 
   ArraySetAsSeries(time,true);

//---- calculate the limit starting index for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-2; // starting index for calculation of all bars
      uint VLineCount_W=0;
      for(bar=0; bar<=limit && !IsStopped(); bar++)
         if(CheckVLinePoint_W(bar,(time[bar]+time[bar+1])/2))
           {
            VLineCount_W++;
            if(VLineCount_W>=WeeklyTotal) break;
           }

      if(bar<limit) limit=bar;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indicator calculation loop on current bars
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- building the 8 hours intraday line in history
      if(CheckVLinePoint_DN(time[bar+1],time[bar],8))
        {
         Name=Sirname_D[1]+TimeToString(time[bar]);
         Time=VLineTime_D1[Count_D1[FutureTotal_D]];
         RenameVline(0,Sirname_D[1]+TimeToString(Time),Name);
         SetVline(0,Name,0,time[bar],Line_Color_D1,Line_Style_D1,Line_Width_D1,SetBackground_D1,"8 hours intraday bar");
         VLineTime_D1[Count_D1[FutureTotal_D]]=time[bar];
         if(bar>0) D1.Recount_ArrayZeroPos(Count_D1,LinesTotal_D_);
         LastTime_D[1]=time[bar];
        }

      //---- building the 16 hours intraday line in history
      if(CheckVLinePoint_DN(time[bar+1],time[bar],16))
        {
         Name=Sirname_D[2]+TimeToString(time[bar]);
         Time=VLineTime_D2[Count_D2[FutureTotal_D]];
         RenameVline(0,Sirname_D[2]+TimeToString(Time),Name);
         SetVline(0,Name,0,time[bar],Line_Color_D2,Line_Style_D2,Line_Width_D2,SetBackground_D2,"16 hours intraday bar");
         VLineTime_D2[Count_D2[FutureTotal_D]]=time[bar];
         if(bar>0) D2.Recount_ArrayZeroPos(Count_D2,LinesTotal_D_);
         LastTime_D[2]=time[bar];
        }

      //---- building the day line in history
      if(CheckVLinePoint_D(time[bar+1],time[bar]))
        {
         Name=Sirname_D[0]+TimeToString(time[bar]);
         Time=VLineTime_D0[Count_D0[FutureTotal_D]];
         RenameVline(0,Sirname_D[0]+TimeToString(Time),Name);
         SetVline(0,Name,0,time[bar],Line_Color_D,Line_Style_D,Line_Width_D,SetBackground_D,"day bar");
         VLineTime_D0[Count_D0[FutureTotal_D]]=time[bar];
         if(bar>0) D0.Recount_ArrayZeroPos(Count_D0,LinesTotal_D_);
         LastTime_D[0]=time[bar];
        }

      //---- building the week line in history
      if(CheckVLinePoint_W(bar,(time[bar]+time[bar+1])/2))
        {
         Name=Sirname_W+TimeToString(time[bar]);
         Time=VLineTime_W[Count_W[FutureTotal_W]];
         RenameVline(0,Sirname_W+TimeToString(Time),Name);
         SetVline(0,Name,0,time[bar],Line_Color_W,Line_Style_W,Line_Width_W,SetBackground_W,"week bar");
         VLineTime_W[Count_W[FutureTotal_W]]=time[bar];
         if(bar>0) W.Recount_ArrayZeroPos(Count_W,WeeklyTotal_);
         LastTime_W=time[bar];
        }
     }

   TimeCur=TimeCurrent();
//---- indicator calculation loop in future (day and intraday lines)
   for(int numb=int(FutureTotal_D)-1; numb>=0 && !IsStopped(); numb--)
     {
      //---- building the 8 hours intraday line in future
      Time=LastTime_D[1]+DAILY_PERIOD_SECOND*(FutureTotal_D-numb);
      if(TimeCur>=Time) Time+=DAILY_PERIOD_SECOND;
      if(TimeCur>=Time) Time+=DAILY_PERIOD_SECOND;
      Name=Sirname_D[1]+TimeToString(Time);
      RenameVline(0,Sirname_D[1]+TimeToString(VLineTime_D1[Count_D1[numb]]),Name);
      SetVline(0,Name,0,Time,Line_Color_D1,Line_Style_D1,Line_Width_D1,SetBackground_D1,"4 hours intraday bar");
      VLineTime_D1[Count_D1[numb]]=Time;

      //---- building the 16 hours intraday line in future
      Time=LastTime_D[2]+DAILY_PERIOD_SECOND*(FutureTotal_D-numb);
      if(TimeCur>=Time) Time+=DAILY_PERIOD_SECOND;
      if(TimeCur>=Time) Time+=DAILY_PERIOD_SECOND;
      Name=Sirname_D[2]+TimeToString(Time);
      RenameVline(0,Sirname_D[2]+TimeToString(VLineTime_D2[Count_D2[numb]]),Name);
      SetVline(0,Name,0,Time,Line_Color_D2,Line_Style_D2,Line_Width_D2,SetBackground_D2,"8 hours intraday bar");
      VLineTime_D2[Count_D2[numb]]=Time;

      //---- building the 0 hours day line in future
      Time=LastTime_D[0]+DAILY_PERIOD_SECOND*(FutureTotal_D-numb);
      if(TimeCur>=Time) Time+=DAILY_PERIOD_SECOND;
      if(TimeCur>=Time) Time+=DAILY_PERIOD_SECOND;
      Name=Sirname_D[0]+TimeToString(Time);
      RenameVline(0,Sirname_D[0]+TimeToString(VLineTime_D0[Count_D0[numb]]),Name);
      SetVline(0,Name,0,Time,Line_Color_D,Line_Style_D,Line_Width_D,SetBackground_D,"day bar");
      VLineTime_D0[Count_D0[numb]]=Time;
     }

//---- indicator calculation loop in future (week lines)
   for(int numb=int(FutureTotal_W)-1; numb>=0 && !IsStopped(); numb--)
     {
      Time=LastTime_W+WEEKLY_PERIOD_SECOND*(FutureTotal_W-numb);
      Name=Sirname_W+TimeToString(Time);
      RenameVline(0,Sirname_W+TimeToString(VLineTime_W[Count_W[numb]]),Name);
      SetVline(0,Name,0,Time,Line_Color_W,Line_Style_W,Line_Width_W,SetBackground_W,"week bar");
      VLineTime_W[Count_W[numb]]=Time;
     }
//---- 
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
