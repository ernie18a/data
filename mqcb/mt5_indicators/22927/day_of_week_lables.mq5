//+------------------------------------------------------------------+
//|                                           Day_Of_Week_Lables.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Day of week indicator"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//--- input parameters
input uint              InpHoursOffset       =  0;             // Hours offset
input ENUM_INPUT_YES_NO InpShowDaysDate      =  INPUT_YES;     // Show days numbers
input color             InpDayLabelColor     =  clrGreen;      // Day label color
input uchar             InpDayLabelSize      =  8;             // Day label font size
input string            InpDayLabelFont      =  "Calibri";     // Day label font name
input color             InpDaySepColor       =  clrDarkGray;   // Day dividing lines color
input ENUM_LINE_STYLE   InpDaySepStyle       =  STYLE_DOT;     // Day dividing lines style
input uchar             InpDaySepWidth       =  1;             // Day dividing lines width
input ENUM_INPUT_YES_NO InpDaySepDate        =  INPUT_NO;      // Show day dividing lines date field
input color             InpMonthLabelColor   =  clrRed;        // Month label color
input uchar             InpMonthLabelSize    =  10;            // Month label font size
input string            InpMonthLabelFont    =  "Calibri";     // Month label font name
input color             InpMonthSepColor     =  clrDarkOrange; // Month dividing lines color
input ENUM_LINE_STYLE   InpMonthSepStyle     =  STYLE_SOLID;   // Month dividing lines style
input uchar             InpMonthSepWidth     =  2;             // Month dividing lines width
input ENUM_INPUT_YES_NO InpMonthSepDate      =  INPUT_YES;     // Show month dividing lines date field
//--- global variables
string         prefix;
string         days[7];
string         month[12];
string         day_date;
int            hour_offset;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set timer
   EventSetTimer(90);
//--- set global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   hour_offset=int(InpHoursOffset>23 ? 23 : InpHoursOffset);
   days[0]=TextByLanguage("Воскресение","Sunday");
   days[1]=TextByLanguage("Понедельник","Monday");
   days[2]=TextByLanguage("Вторник","Tuesday");
   days[3]=TextByLanguage("Среда","Wednesday");
   days[4]=TextByLanguage("Четверг","Thursday");
   days[5]=TextByLanguage("Пятница","Friday");
   days[6]=TextByLanguage("Суббота","Saturday");
//---
   month[0]=TextByLanguage("Январь","January");
   month[1]=TextByLanguage("Февраль","February");
   month[2]=TextByLanguage("Март","March");
   month[3]=TextByLanguage("Апрель","April");
   month[4]=TextByLanguage("Май","May");
   month[5]=TextByLanguage("Июнь","June");
   month[6]=TextByLanguage("Июль","July");
   month[7]=TextByLanguage("Август","August");
   month[8]=TextByLanguage("Сентябрь","September");
   month[9]=TextByLanguage("Октябрь","October");
   month[10]=TextByLanguage("Ноябрь","November");
   month[11]=TextByLanguage("Декабрь","December");
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Day of week");
//---
   iTime(NULL,PERIOD_D1,1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete objects
   ObjectsDeleteAll(0,prefix);
   ChartRedraw();
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Every 1.5 minutes to keep data D1 up to date
   iTime(NULL,PERIOD_D1,1);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<4 || !IsTimeframeDataReady(PERIOD_D1)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
     }

//--- Расчёт индикатора
   day_date="";
   static int last_month=WRONG_VALUE;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(TimeHour(time[i])==hour_offset)
        {
         day_date=(InpShowDaysDate ? IntegerToString(TimeDay(time[i]),2,'0') : "");
         //--- Day
         Separator(prefix+"day_sep_"+(string)i,time[i],InpDaySepColor,InpDaySepWidth,InpDaySepStyle,InpDaySepDate);
         ObjectMakeText(prefix+"day_"+(string)i,time[i]+(PeriodSeconds(PERIOD_D1)/2),iHigh(NULL,PERIOD_D1,iBarShift(NULL,PERIOD_D1,time[i]))+(20*Point()),days[TimeDayOfWeek(time[i])]+" "+day_date,InpDayLabelColor,InpDayLabelFont,InpDayLabelSize);
         //--- Month
         int cur_month=TimeMonth(time[i]);
         if(cur_month!=last_month)
           {
            Separator(prefix+"month_sep"+(string)i,time[i],InpMonthSepColor,InpMonthSepWidth,InpMonthSepStyle,InpMonthSepDate);
            ObjectMakeText(prefix+"month_"+(string)i,time[i]+(PeriodSeconds(PERIOD_D1)/2),iLow(NULL,PERIOD_D1,iBarShift(NULL,PERIOD_D1,time[i]))+(30*Point()),month[TimeMonth(time[i])-1],InpMonthLabelColor,InpMonthLabelFont,InpMonthLabelSize);
            last_month=cur_month;
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Рисует разделительную линию                                      |
//+------------------------------------------------------------------+
void Separator(const string name,const datetime time,const color clr,const int width,const int style,const bool date=false)
  {
   if(ObjectFind(0,name)<1)
      ObjectCreate(0,name,OBJ_VLINE,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_TIME,0,time);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_RAY,date);
  }
//+------------------------------------------------------------------+
//| Выводит текст                                                    |
//+------------------------------------------------------------------+
void ObjectMakeText(const string name,const datetime time,const double price,const string text,const color clr,const string font="Calibri",const int size=8)
  {
   if(ObjectFind(0,name)<1)
      ObjectCreate(0,name,OBJ_TEXT,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price);
   ObjectSetInteger(0,name,OBJPROP_TIME,0,time);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   return;
  }
//+------------------------------------------------------------------+
//| Возвращает день месяца указанной даты                            |
//+------------------------------------------------------------------+
int TimeDay(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.day;
  }
//+------------------------------------------------------------------+
//| Возвращает день недели указанной даты                            |
//+------------------------------------------------------------------+
int TimeDayOfWeek(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.day_of_week;
  }
//+------------------------------------------------------------------+
//| Возвращает номер месяца указанного времени                       |
//+------------------------------------------------------------------+
int TimeMonth(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.mon;
  }
//+------------------------------------------------------------------+
//| Возвращает час указанного времени                                |
//+------------------------------------------------------------------+
int TimeHour(const datetime time)
  {
   MqlDateTime tm;
   if(!TimeToStruct(time,tm)) return WRONG_VALUE;
   return tm.hour;
  }
//+------------------------------------------------------------------+
//| Возвращает текст на одном из двух языков                         |
//+------------------------------------------------------------------+
string TextByLanguage(const string text_ru,const string text_en)
  {
   return((TerminalInfoString(TERMINAL_LANGUAGE)=="Russian") ? text_ru : text_en);
  }
//+------------------------------------------------------------------+
//| Проверка наличия исторических данных по таймфрейму               |
//| https://www.mql5.com/ru/forum/280448#comment_8762312             |
//+------------------------------------------------------------------+
bool IsTimeframeDataReady(ENUM_TIMEFRAMES timeframe)
  {
   ResetLastError();
   iTime(NULL,timeframe,1);
   return GetLastError()==ERR_SUCCESS;
  }
//+------------------------------------------------------------------+
