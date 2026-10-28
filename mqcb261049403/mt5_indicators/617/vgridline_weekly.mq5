//+------------------------------------------------------------------+ 
//|                                             VGridLine_Weekly.mq5 |
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
#property description "The indicator works at all timeframes less than a week."
#property indicator_buffers 1
#property indicator_plots 1
//+----------------------------------------------+ 
//|  Indicator drawing parameters                |
//+----------------------------------------------+ 
//---- drawing the indicator in the main window
#property indicator_chart_window 
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for storing the value, returning of which to OnCalculate() will lead to the indicator recalculation
#define WEEKLY_PERIOD_SECOND 604800 // The number of seconds in a week period including Sundays
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
enum STYLE
  {
   SOLID_,       // Solid line
   DASH_,        // Dashed line
   DOT_,         // Dotted line
   DASHDOT_,     // Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+----------------------------------------------+ 
//|  Indicator input parameters                  |
//+----------------------------------------------+ 
input string LinesSirname="VLine_Grid_Weekly_"; // Line name
input color Line_Color=Aqua;                    // Line color
input STYLE Line_Style=SOLID_;                  // Line display style
input ENUM_WIDTH Line_Width=w_1;                // Line width
input bool SetBackground=true;                  // Lines background display
input uint LinesTotal=10;                       // Number of lines in history
input uint FutureTotal=1;                       // Number of lines in future empty history
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as ring buffers
uint Count[];
datetime VLineTime[];
//---- declaration of the integer variables for the start of data calculation
uint LinesTotal_;
//+------------------------------------------------------------------+
//|  Recalculation of position of a newest element in the array      |
//+------------------------------------------------------------------+   
bool CheckVLinePoint(int bar,datetime bartime)
  {
//----
   MqlDateTime tm;
   TimeToStruct(bartime,tm);
   if(tm.day_of_week==0 || tm.day_of_week==6) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//|  Recalculation of position of a newest element in the array      |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[], // return the current value of the price series by the link
                          int Size)     // number of the elements in the ring buffer
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//|  Vertical line renaming                                          |
//+------------------------------------------------------------------+
bool RenameVline(long     chart_id,      // chart ID
                 string   oldname,       // object old name
                 string   newname)       // object new name
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- checking the chart period to be enough for the calculation
   if(Period()>PERIOD_D1) return;
   Deinit();
//---- initialization of variables of the start of data calculation
   LinesTotal_=LinesTotal+FutureTotal;

//---- memory distribution for variables' arrays  
   ArrayResize(Count,LinesTotal_);
   ArrayResize(VLineTime,LinesTotal_);
   
//---- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"VGridLine_Weekly(",LinesSirname,", ",LinesTotal,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
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
   if(Period()>PERIOD_D1) return(RESET);
//---- checking the number of bars to be enough for the calculation
   if(rates_total<2) return(RESET);
   if(prev_calculated==rates_total) return(rates_total);

//---- declarations of local variables 
   string Name;
   datetime Time;
   int limit,bar;
   static datetime LastTime=0;

//---- indexing elements in arrays as timeseries 
   ArraySetAsSeries(time,true);

//---- calculate the limit starting index for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-2; // starting index for calculation of all bars
      uint VLineCount=0;
      for(bar=0; bar<=limit && !IsStopped(); bar++)
         if(CheckVLinePoint(bar,(time[bar]+time[bar+1])/2))
           {
            VLineCount++;
            if(VLineCount>=LinesTotal) break;
           }
      if(bar<limit) limit=bar;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indicator calculation loop on current bars
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(CheckVLinePoint(bar,(time[bar]+time[bar+1])/2))
        {
         Name=LinesSirname+TimeToString(time[bar]);
         RenameVline(0,LinesSirname+TimeToString(VLineTime[Count[FutureTotal]]),Name);
         SetVline(0,Name,0,time[bar],Line_Color,Line_Style,Line_Width,SetBackground,"week bar");
         VLineTime[Count[FutureTotal]]=time[bar];
         if(bar>0) Recount_ArrayZeroPos(Count,LinesTotal_);
         LastTime=time[bar];
        }
     }

//---- indicator future calculation loop 
   for(int numb=int(FutureTotal)-1; numb>=0 && !IsStopped(); numb--)
     {
      Time=LastTime+WEEKLY_PERIOD_SECOND*(FutureTotal-numb);
      Name=LinesSirname+TimeToString(Time);
      RenameVline(0,LinesSirname+TimeToString(VLineTime[Count[numb]]),Name);
      SetVline(0,Name,0,Time,Line_Color,Line_Style,Line_Width,SetBackground,"week bar");
      VLineTime[Count[numb]]=Time;
     }
//---- 
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
