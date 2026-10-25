//+------------------------------------------------------------------+
//|                                                   ChannelInd.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description " The indicator draws the High/Low channel for time range (start hour - end hour). "
#property description " Near the lower boundary of the channel displays channel size in points. "
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Channel
#property indicator_label1  "Channel"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrPaleGreen,clrBisque
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Upper
#property indicator_label2  "Upper"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Lower
#property indicator_label3  "Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpHourBegin   =  1;          // Begin trade day hour
input uint              InpHourEnd     =  22;         // End trade day hour
input ENUM_INPUT_YES_NO InpShowSizes   =  INPUT_YES;  // Draw channels size
input uint              InpFontSize    =  8;          // Labels size
input color             InpFontColor   =  clrGray;    // Labels color
input string            InpFontName    =  "Calibri";  // Font name
//--- indicator buffers
double         BufferChannelUP[];
double         BufferChannelDN[];
double         BufferUpperLine[];
double         BufferLowerLine[];
//--- global variables
int            hour_begin;
int            hour_end;
int            font_size;
string         prefix;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   string short_name="Channel("+IntegerToString(hour_begin,2,'0')+":00-"+IntegerToString(hour_end,2,'0')+":00)";
   hour_begin=int(InpHourBegin>23 ? 23 : InpHourBegin);
   hour_end=int(InpHourEnd==(uint)hour_begin ? hour_begin-1 : InpHourEnd>23 ? 23 : InpHourEnd);
   font_size=int(InpFontSize<6 ? 6 : InpFontSize);
   prefix=short_name+"_";
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferChannelUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferChannelDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferUpperLine,INDICATOR_DATA);
   SetIndexBuffer(3,BufferLowerLine,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUpperLine,true);
   ArraySetAsSeries(BufferLowerLine,true);
   ArraySetAsSeries(BufferChannelUP,true);
   ArraySetAsSeries(BufferChannelDN,true);
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
      ArrayInitialize(BufferUpperLine,EMPTY_VALUE);
      ArrayInitialize(BufferLowerLine,EMPTY_VALUE);
      ArrayInitialize(BufferChannelUP,EMPTY_VALUE);
      ArrayInitialize(BufferChannelDN,EMPTY_VALUE);
     }
   static int prev_size=0, size=0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      datetime end_time=EndTime(time[i]);
      if(time[i]>=end_time && time[i+1]<end_time)
        {
         double max_price=high[i];
         double min_price=low[i];
         datetime begin_time=BeginTime(time[i]);
         if(hour_begin>hour_end) begin_time-=86400;
         int pos=i;
         while(pos<rates_total && time[pos]>=begin_time)
           {
            min_price=fmin(min_price,low[pos]);
            max_price=fmax(max_price,high[pos]);
            pos++;
           }
         size=int((max_price-min_price)/Point());
         for(int n=pos-1; n>=i; n--)
           {
            BufferUpperLine[n]=max_price;
            BufferLowerLine[n]=min_price;
            BufferChannelUP[n]=(size>prev_size ? max_price : min_price);
            BufferChannelDN[n]=(size>prev_size ? min_price : max_price);
           }
         if(InpShowSizes && i!=pos-1)
           {
            string name=prefix+TimeToString(time[i],TIME_DATE);
            string text=(string)size;
            if(ObjectFind(0,name)==WRONG_VALUE)
              {
               ObjectCreate(0,name,OBJ_TEXT,0,0,0);
               ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
               ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
               ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
               ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
               ObjectSetInteger(0,name,OBJPROP_COLOR,InpFontColor);
               ObjectSetInteger(0,name,OBJPROP_TIME,0,time[i]);
               ObjectSetDouble(0,name,OBJPROP_PRICE,0,min_price);
               ObjectSetString(0,name,OBJPROP_FONT,InpFontName);
               ObjectSetString(0,name,OBJPROP_TEXT,text);
              }
            else
              {
               ObjectSetDouble(0,name,OBJPROP_PRICE,0,min_price);
              }
           }
         prev_size=size;
        }
      else
        {
         BufferLowerLine[i]=BufferUpperLine[i]=EMPTY_VALUE;
         BufferChannelDN[i]=BufferChannelUP[i]=0;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает начальное время                                       |
//+------------------------------------------------------------------+
datetime BeginTime(const datetime time)
  {
   MqlDateTime tm;
   if(TimeToStruct(time,tm))
     {
      tm.hour=hour_begin;
      tm.min=0;
      return StructToTime(tm);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает конечное время                                        |
//+------------------------------------------------------------------+
datetime EndTime(const datetime time)
  {
   MqlDateTime tm;
   if(TimeToStruct(time,tm))
     {
      tm.hour=hour_end;
      tm.min=0;
      return StructToTime(tm);
     }
   return 0;
  }
//+------------------------------------------------------------------+
