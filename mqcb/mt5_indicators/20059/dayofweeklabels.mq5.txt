//+------------------------------------------------------------------+
//|                                              DayOfWeekLabels.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_INPUT_YES_NO InpShowDay        =  INPUT_YES;     // Show days
input ENUM_INPUT_YES_NO InpShowMon        =  INPUT_YES;     // Show months
input ENUM_INPUT_YES_NO InpShowYear       =  INPUT_YES;     // Show years
input string            InpNameMon        =  "Monday";      // Name of Monday label
input string            InpNameTue        =  "Tuesday";     // Name of Tuesday label
input string            InpNameWed        =  "Wednesday";   // Name of Wednesday label
input string            InpNameThu        =  "Thursday";    // Name of Thursday label
input string            InpNameFri        =  "Friday";      // Name of Friday label
input string            InpNameSat        =  "Saturday";    // Name of Saturday label
input string            InpNameSun        =  "Sunday";      // Name of Sunday label
input string            InpNameJan        =  "January";     // Name of January label
input string            InpNameFeb        =  "February";    // Name of February label
input string            InpNameMar        =  "March";       // Name of March label
input string            InpNameApr        =  "April";       // Name of April label
input string            InpNameMay        =  "May";         // Name of May label
input string            InpNameJun        =  "June";        // Name of June label
input string            InpNameJul        =  "July";        // Name of July label
input string            InpNameAug        =  "August";      // Name of August label
input string            InpNameSep        =  "September";   // Name of September label
input string            InpNameOct        =  "October";     // Name of October label
input string            InpNameNov        =  "November";    // Name of November label
input string            InpNameDec        =  "December";    // Name of December label
input color             InpColorDayLine   =  clrGreen;      // Day line color
input uint              InpWidthDay       =  2;             // Day line width
input color             InpColorDayLabel  =  clrGreen;      // Day label color
input uint              InpFontSizeDay    =  8;             // Day label size
input color             InpColorMonLine   =  clrCrimson;    // Month line color
input uint              InpWidthMon       =  3;             // Month line width
input color             InpColorMonLabel  =  clrCrimson;    // Month label color
input uint              InpFontSizeMon    =  10;            // Month label size
input string            InpFontName       =  "Calibri";     // Font name
//--- global variables
int    BeginMinutes;
string MondayNameH,TuesdayNameH,WednesdayNameH,ThursdayNameH,FridayNameH,SaturdayNameH,SundayNameH;
string JanuaryNameH,FebruaryNameH,MarchNameH,AprilNameH,MayNameH,JuneNameH,JulyNameH,AugustNameH,SeptemberNameH,OctoberNameH,NovemberNameH,DecemberNameH;
string prefix;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   prefix="DayOW_";  
   MondayNameH=GetName(InpNameMon);
   TuesdayNameH=GetName(InpNameTue);
   WednesdayNameH=GetName(InpNameWed);
   ThursdayNameH=GetName(InpNameThu);
   FridayNameH=GetName(InpNameFri);
   SaturdayNameH=GetName(InpNameSat);
   SundayNameH=GetName(InpNameSun);
   JanuaryNameH=GetName(InpNameJan);
   FebruaryNameH=GetName(InpNameFeb);
   MarchNameH=GetName(InpNameMar);
   AprilNameH=GetName(InpNameApr);
   MayNameH=GetName(InpNameMay);
   JuneNameH=GetName(InpNameJun);
   JulyNameH=GetName(InpNameJul);
   AugustNameH=GetName(InpNameAug);
   SeptemberNameH=GetName(InpNameSep);
   OctoberNameH=GetName(InpNameOct);
   NovemberNameH=GetName(InpNameNov);
   DecemberNameH=GetName(InpNameDec);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,prefix);
   ChartRedraw();
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
     }
//--- Расчёт индикатора
   MqlDateTime tm,tm_prev;
   string name="",tooltip="\n",nm_dw="",nm_dm="";
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(!TimeToStruct(time[i],tm)) continue;
      if(InpShowDay)
        {
         int day=tm.day;
         int day_prev=DayNumber(time[i+1]);
         if(day!=day_prev)
           {
            name=prefix+TimeToString(time[i])+"L";
            nm_dw=NameDayOfWeek(tm.day_of_week);
            tooltip=TimeToString(time[i],TIME_DATE)+"\n"+nm_dw;
            if(CreateObject(name,OBJ_VLINE,InpColorDayLine))
              {
               ObjectSetInteger(0,name,OBJPROP_TIME,0,time[i]);
               ObjectSetInteger(0,name,OBJPROP_WIDTH,InpWidthDay);
               ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
              }
            name=prefix+TimeToString(time[i])+"T";
            if(CreateObject(name,OBJ_TEXT,InpColorDayLabel))
              {
               ObjectSetInteger(0,name,OBJPROP_TIME,0,time[i]);
               ObjectSetDouble(0,name,OBJPROP_PRICE,high[i]);
               ObjectSetDouble(0,name,OBJPROP_ANGLE,90);
               ObjectSetInteger(0,name,OBJPROP_FONTSIZE,InpFontSizeDay);
               ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
               ObjectSetString(0,name,OBJPROP_FONT,InpFontName);
               ObjectSetString(0,name,OBJPROP_TEXT,NameDayOfWeek(tm.day_of_week,true));
               ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
              }
           }
        }
      if(InpShowMon)
        {
         int month=tm.mon;
         int month_prev=MonthNumber(time[i+1]);
         int year=tm.year;
         if(month!=month_prev)
           {
            name=prefix+TimeToString(time[i])+"LM";
            nm_dm=NameOfMonth(month,year);
            tooltip=TimeToString(time[i],TIME_DATE)+"\n"+nm_dw+"\n"+nm_dm;
            if(CreateObject(name,OBJ_VLINE,InpColorMonLine))
              {
               ObjectSetInteger(0,name,OBJPROP_TIME,0,time[i]);
               ObjectSetInteger(0,name,OBJPROP_WIDTH,InpWidthMon);
               ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
              }
            name=prefix+TimeToString(time[i])+"TM";
            if(CreateObject(name,OBJ_TEXT,InpColorMonLabel))
              {
               ObjectSetInteger(0,name,OBJPROP_TIME,0,time[i]);
               ObjectSetDouble(0,name,OBJPROP_PRICE,high[i]);
               ObjectSetDouble(0,name,OBJPROP_ANGLE,90);
               ObjectSetInteger(0,name,OBJPROP_FONTSIZE,InpFontSizeMon);
               ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
               ObjectSetString(0,name,OBJPROP_FONT,InpFontName);
               ObjectSetString(0,name,OBJPROP_TEXT,nm_dm);
               ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Создаёт объект                                                   |
//+------------------------------------------------------------------+
bool CreateObject(const string name,const ENUM_OBJECT object_type,const color object_color)
  {
   if(ObjectCreate(0,name,object_type,0,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_COLOR,object_color);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Возвращает имя с отступом                                        |
//+------------------------------------------------------------------+
string GetName(const string name)
  {
   return name+GetHole(StringLen(name));
  }  
//+------------------------------------------------------------------+
//| Возвращает отступ                                                |
//+------------------------------------------------------------------+
string GetHole(int length)
  {
   string hole="";
   for(int i=1; i<=2*length; i++)
      hole+=" ";
   return hole;
  }
//+------------------------------------------------------------------+
//| Возвращает номер дня месяца                                      |
//+------------------------------------------------------------------+
int DayNumber(const datetime time)
  {
   MqlDateTime tm;
   int day_number=WRONG_VALUE;
   if(TimeToStruct(time,tm))
      day_number=tm.day;
   return day_number;
  }
//+------------------------------------------------------------------+
//| Возвращает номер месяца в году                                   |
//+------------------------------------------------------------------+
int MonthNumber(const datetime time)
  {
   MqlDateTime tm;
   int month_number=WRONG_VALUE;
   if(TimeToStruct(time,tm))
      month_number=tm.mon;
   return month_number;
  }
//+------------------------------------------------------------------+
//| Возвращает наименование дня недели                               |
//+------------------------------------------------------------------+
string NameDayOfWeek(const int day_number,const bool hole=false)
  {
   return
     (
      day_number==0 ? (hole ? SundayNameH : InpNameSun) :
      day_number==1 ? (hole ? MondayNameH : InpNameMon) :
      day_number==2 ? (hole ? TuesdayNameH : InpNameTue) :
      day_number==3 ? (hole ? WednesdayNameH : InpNameWed) :
      day_number==4 ? (hole ? ThursdayNameH : InpNameThu) :
      day_number==5 ? (hole ? FridayNameH : InpNameFri) :
      SaturdayNameH
     );
  }
//+------------------------------------------------------------------+
//| Возвращает наименование месяца                                   |
//+------------------------------------------------------------------+
string NameOfMonth(const int month_number,const int year_number)
  {
   string month_name=
     (
      month_number==1   ? JanuaryNameH    :
      month_number==2   ? FebruaryNameH   :
      month_number==3   ? MarchNameH      :
      month_number==4   ? AprilNameH      :
      month_number==5   ? MayNameH        :
      month_number==6   ? JuneNameH       :
      month_number==7   ? JulyNameH       :
      month_number==8   ? AugustNameH     :
      month_number==9   ? SeptemberNameH  :
      month_number==10  ? OctoberNameH    :
      month_number==11  ? NovemberNameH   :
      DecemberNameH
     );
   return(InpShowYear ? (string)year_number+" "+month_name : month_name);
  }
//+------------------------------------------------------------------+
