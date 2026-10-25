//+------------------------------------------------------------------+
//|                                                          MIT.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Momentum In Time"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot MIT
#property indicator_label1  "MIT"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Begin
#property indicator_label2  "Time begin"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uchar    InpHourBegin      =  0; // Hour begin
input uchar    InpMinutesBegin   =  0; // Minutes begin
//--- indicator buffers
double         BufferMIT[];
double         BufferBegin[];
//--- global variables
int            hour;
int            minutes;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   hour=int(InpHourBegin>23 ? 23 : InpHourBegin);
   minutes=int(InpMinutesBegin>59 ? 59 : InpMinutesBegin);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMIT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBegin,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MIT("+IntegerToString(hour,2,'0')+":"+IntegerToString(minutes,2,'0')+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMIT,true);
   ArraySetAsSeries(BufferBegin,true);
//---
   return(INIT_SUCCEEDED);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferMIT,0);
      ArrayInitialize(BufferBegin,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(Period()<PERIOD_D1)
        {
         int day_index=BarShift(NULL,PERIOD_D1,time[i]);
         datetime t=Time(NULL,PERIOD_D1,day_index);
         if(day_index==WRONG_VALUE || t==0)
            continue;
         t+=3600*hour+60*minutes;
         int index=BarShift(NULL,PERIOD_CURRENT,t,false);
         if(index==WRONG_VALUE || index>rates_total-3)
            continue;
         BufferMIT[i]=close[i]-open[index];
         BufferBegin[i]=(i==index ? 0 : EMPTY_VALUE);
        }
      else
         BufferMIT[i]=close[i]-open[i+1];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает Time                                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   datetime array[];
   return(CopyTime(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/code/20417                               |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=iBars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==iBars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return res;
  }
//+------------------------------------------------------------------+
int iBars(const string symbol_name,ENUM_TIMEFRAMES timeframe,datetime start_time,datetime stop_time)
  {
   static string LastSymb=NULL;
   static ENUM_TIMEFRAMES LastTimeFrame=0;
   static datetime LastTime=0;
   static datetime LastTime0=0;
   static int PerSec=0;
   static int PreBars=0,PreBarsS=0,PreBarsF=0;
   static datetime LastBAR=0;
   static datetime LastTimeCur=0;
   static bool flag=true;
   static int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
   datetime TimeCur;
   if(timeframe==0) timeframe=_Period;
   const bool changeTF=LastTimeFrame!=timeframe;
   const bool changeSymb=LastSymb!=symbol_name;
   const bool change=changeTF || changeSymb || flag;

   LastTimeFrame=timeframe; LastSymb=symbol_name;
   if(changeTF) PerSec=PeriodSeconds(timeframe); if(PerSec==0) { flag=true; return(0);}

   if(stop_time<start_time)
     {
      TimeCur=stop_time;
      stop_time=start_time;
      start_time=TimeCur;
     }
   if(changeSymb)
     {
      if(!SymbolInfoInteger(symbol_name,SYMBOL_SELECT))
        {
         SymbolSelect(symbol_name,true);
         ChartRedraw();
        }
     }
   TimeCur=TimeCurrent();
   if(timeframe==PERIOD_W1) TimeCur-=(TimeCur+345600)%PerSec;
   if(timeframe<PERIOD_W1) TimeCur-=TimeCur%PerSec;
   if(start_time>TimeCur) { flag=true; return(0);}
   if(timeframe==PERIOD_MN1)
     {
      MqlDateTime dt;
      TimeToStruct(TimeCur,dt);
      TimeCur=dt.year*12+dt.mon;
     }

   if(changeTF || changeSymb || TimeCur!=LastTimeCur)
      LastBAR=(datetime)SeriesInfoInteger(symbol_name,timeframe,SERIES_LASTBAR_DATE);

   LastTimeCur=TimeCur;
   if(start_time>LastBAR) { flag=true; return(0);}

   datetime tS,tF=0;
   if(timeframe==PERIOD_W1) tS=start_time-(start_time+345599)%PerSec-1;
   else if(timeframe<PERIOD_MN1) tS=start_time-(start_time-1)%PerSec-1;
   //--- PERIOD_MN1
   else
     {
      MqlDateTime dt;
      TimeToStruct(start_time-1,dt);
      tS=dt.year*12+dt.mon;
     }
   if(change || tS!=LastTime) { PreBarsS=Bars(symbol_name,timeframe,start_time,UINT_MAX); LastTime=tS;}
   if(stop_time<=LastBAR)
     {
      if(PreBarsS>=max_bars) PreBars=Bars(symbol_name,timeframe,start_time,stop_time);
      else
        {
         if(timeframe<PERIOD_W1) tF=stop_time-(stop_time)%PerSec;
         else if(timeframe==PERIOD_W1) tF=stop_time-(stop_time+345600)%PerSec;
         else //  PERIOD_MN1
           {
            MqlDateTime dt0;
            TimeToStruct(stop_time-1,dt0);
            tF=dt0.year*12+dt0.mon;
           }
         if(change || tF!=LastTime0)
           { PreBarsF=Bars(symbol_name,timeframe,stop_time+1,UINT_MAX); LastTime0=tF; }
         PreBars=PreBarsS-PreBarsF;
        }
     }
   else PreBars=PreBarsS;
   flag=false;
   return(PreBars);
  }
//+------------------------------------------------------------------+
int iBars(string symbol_name,ENUM_TIMEFRAMES  timeframe)
  {
   return(Bars(symbol_name,timeframe));
  }
//+------------------------------------------------------------------+