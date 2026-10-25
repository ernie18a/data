//+------------------------------------------------------------------+
//|                                                  SessionTWAP.mq5 |
//|                                                    Timon Krueger |
//|                     https://www.mql5.com/en/users/sg_mephisot    |
//+------------------------------------------------------------------+
#property copyright "Timon Krueger"
#property link "https://www.mql5.com/en/users/sg_mephisot"
#property version "1.00"
#property description "Time weighted average price from the cash open of a chosen exchange session."
#property description "Every second of the session counts the same: minutes without ticks carry the last price,"
#property description "so the line is not biased by the tick counter a CFD reports as volume."
#property description "Frankfurt, London, New York and Tokyo anchors with automatic daylight saving. Display only."
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 5
#property indicator_label1 "Session TWAP"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Band 1 upper"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrDarkGray
#property indicator_style2 STYLE_DOT
#property indicator_width2 1
#property indicator_label3 "Band 1 lower"
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrDarkGray
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
#property indicator_label4 "Band 2 upper"
#property indicator_type4 DRAW_LINE
#property indicator_color4 clrSilver
#property indicator_style4 STYLE_DOT
#property indicator_width4 1
#property indicator_label5 "Band 2 lower"
#property indicator_type5 DRAW_LINE
#property indicator_color5 clrSilver
#property indicator_style5 STYLE_DOT
#property indicator_width5 1

//--- session anchor selected by the user
enum ENUM_ST_SESSION
  {
   ST_AUTO=0, // Auto (from symbol name)
   ST_EU=1, // Frankfurt 09:00 local
   ST_UK=2, // London 08:00 local
   ST_US=3, // New York 09:30 local
   ST_TOKYO=4, // Tokyo 09:00 local
   ST_MANUAL=5 // Manual time in server time
  };

//--- price of a bar that is held for the bar's duration
enum ENUM_ST_PRICE
  {
   ST_PRICE_TYPICAL=0, // Typical (high+low+close)/3
   ST_PRICE_CLOSE=1, // Close
   ST_PRICE_MEDIAN=2, // Median (high+low)/2
   ST_PRICE_WEIGHTED=3 // Weighted (high+low+2*close)/4
  };

input ENUM_ST_SESSION  InpSession          =ST_AUTO;             // Anchor the average at
input string           InpManualOpen       ="09:00";             // Manual open HH:MM (server time, used by Manual)
input ENUM_ST_PRICE    InpPrice            =ST_PRICE_TYPICAL;    // Price of each bar
input double           InpBand1            =1.0;                 // Inner band in standard deviations (0 = off)
input double           InpBand2            =2.0;                 // Outer band in standard deviations (0 = off)
input bool             InpShowInfo         =true;                // Show the info label
input ENUM_BASE_CORNER InpInfoCorner       =CORNER_LEFT_UPPER;   // Info label corner
input int              InpInfoX            =10;                  // Info label X offset in pixels
input int              InpInfoY            =20;                  // Info label Y offset in pixels
input color            InpInfoColor        =clrDimGray;          // Info label colour
input int              InpInfoSize         =9;                   // Info label font size

//--- indicator buffers
double ExtTwap[];
double ExtBand1Up[];
double ExtBand1Dn[];
double ExtBand2Up[];
double ExtBand2Dn[];

//--- object prefix keeps several instances on one chart apart
string   g_prefix="";
bool     g_tooSlow=false;
//--- statistics of the newest session that has at least one bar; kept across calls so the label
//--- can still show the last completed session while today's session has not opened yet
datetime g_statOpen=0;
double   g_statTwap=0.0;
double   g_statClose=0.0;
double   g_statLocation=0.0;
double   g_statAbove=0.0;

//+------------------------------------------------------------------+
//| Build a UTC datetime from calendar fields                        |
//+------------------------------------------------------------------+
datetime MakeUtc(const int year,const int month,const int day,const int hour,const int minute=0)
  {
   MqlDateTime st;
   ZeroMemory(st);
//--- StructToTime works on plain fields, the value is read as UTC by the callers
   st.year=year;
   st.mon=month;
   st.day=day;
   st.hour=hour;
   st.min=minute;
   return StructToTime(st);
  }

//+------------------------------------------------------------------+
//| Day of the last Sunday in a month                                |
//+------------------------------------------------------------------+
int LastSundayOf(const int year,const int month)
  {
//--- step back one day from the first of the next month
   datetime lastDay=(month==12) ? MakeUtc(year+1,1,1,0)-86400 : MakeUtc(year,month+1,1,0)-86400;
   MqlDateTime st;
   TimeToStruct(lastDay,st);
   return st.day-st.day_of_week;
  }

//+------------------------------------------------------------------+
//| Day of the n-th Sunday in a month                                |
//+------------------------------------------------------------------+
int NthSundayOf(const int year,const int month,const int n)
  {
   MqlDateTime st;
   TimeToStruct(MakeUtc(year,month,1,0),st);
//--- day_of_week of the first day tells how far the first Sunday is away
   return 1+(7-st.day_of_week)%7+7*(n-1);
  }

//+------------------------------------------------------------------+
//| Central European offset to UTC in hours                          |
//+------------------------------------------------------------------+
int EuropeOffsetHours(const datetime utc)
  {
   MqlDateTime st;
   TimeToStruct(utc,st);
//--- summer time runs from the last Sunday of March to the last Sunday of October
   datetime start=MakeUtc(st.year,3,LastSundayOf(st.year,3),1);
   datetime end=MakeUtc(st.year,10,LastSundayOf(st.year,10),1);
   return (utc>=start && utc<end) ? 2 : 1;
  }

//+------------------------------------------------------------------+
//| London offset to UTC in hours                                    |
//+------------------------------------------------------------------+
int LondonOffsetHours(const datetime utc)
  {
//--- London follows the same switching dates as the continent, one hour behind
   return EuropeOffsetHours(utc)-1;
  }

//+------------------------------------------------------------------+
//| New York offset to UTC in hours                                  |
//+------------------------------------------------------------------+
int NewYorkOffsetHours(const datetime utc)
  {
   MqlDateTime st;
   TimeToStruct(utc,st);
//--- daylight saving runs from the second Sunday of March to the first Sunday of November
   datetime start=MakeUtc(st.year,3,NthSundayOf(st.year,3,2),7);
   datetime end=MakeUtc(st.year,11,NthSundayOf(st.year,11,1),6);
   return (utc>=start && utc<end) ? -4 :-5;
  }

//+------------------------------------------------------------------+
//| Broker server offset to UTC in seconds                           |
//+------------------------------------------------------------------+
int ServerOffsetSec()
  {
//--- rounded to half hours, that covers every server time zone in use
   long diff=(long)TimeTradeServer()-(long)TimeGMT();
   return (int)(MathRound((double)diff/1800.0)*1800.0);
  }

//+------------------------------------------------------------------+
//| Session guessed from the symbol name                             |
//+------------------------------------------------------------------+
ENUM_ST_SESSION DetectSession()
  {
   string name=_Symbol;
   StringToUpper(name);

//--- British indices open in London
   if(StringFind(name,"UK100")>=0 || StringFind(name,"FTSE")>=0)
      return ST_UK;

//--- continental European indices open in Frankfurt or at the same minute
   if(StringFind(name,"GER")>=0 || StringFind(name,"DAX")>=0 || StringFind(name,"DE40")>=0 ||
      StringFind(name,"DE30")>=0 || StringFind(name,"FRA40")>=0 || StringFind(name,"CAC")>=0 ||
      StringFind(name,"SPA35")>=0 || StringFind(name,"IBEX")>=0 || StringFind(name,"SWI20")>=0 ||
      StringFind(name,"SMI")>=0 || StringFind(name,"EUSTX")>=0 || StringFind(name,"EU50")>=0 ||
      StringFind(name,"ITA40")>=0 || StringFind(name,"NED25")>=0)
      return ST_EU;

//--- Japanese index first, its name contains no US or EU token
   if(StringFind(name,"JP225")>=0 || StringFind(name,"NIKKEI")>=0 || StringFind(name,"JPN225")>=0)
      return ST_TOKYO;

//--- Russell before the other US tokens, US2000 contains neither US30 nor US100
   if(StringFind(name,"US2000")>=0 || StringFind(name,"RUSSELL")>=0 || StringFind(name,"RUT")>=0 ||
      StringFind(name,"US30")>=0 || StringFind(name,"DJ30")>=0 || StringFind(name,"DOW")>=0 ||
      StringFind(name,"NAS")>=0 || StringFind(name,"US100")>=0 || StringFind(name,"USTEC")>=0 ||
      StringFind(name,"NDX")>=0 || StringFind(name,"US500")>=0 || StringFind(name,"SP500")>=0 ||
      StringFind(name,"SPX")>=0)
      return ST_US;

//--- unknown symbols fall back to Frankfurt, the info label marks the guess
   return ST_EU;
  }

//+------------------------------------------------------------------+
//| Session actually used after the Auto choice is resolved          |
//+------------------------------------------------------------------+
ENUM_ST_SESSION EffectiveSession()
  {
   if(InpSession!=ST_AUTO)
      return InpSession;
   return DetectSession();
  }

//+------------------------------------------------------------------+
//| Exchange local open in minutes and offset for one session        |
//+------------------------------------------------------------------+
void SessionLocalOpen(const ENUM_ST_SESSION session,const datetime dayUtc,int &localMinutes,int &offsetHours)
  {
//--- every anchor is the cash open of the exchange, not the futures open
   switch(session)
     {
      case ST_UK:
         localMinutes=8*60;
         offsetHours=LondonOffsetHours(dayUtc);
         break;
      case ST_US:
         localMinutes=9*60+30;
         offsetHours=NewYorkOffsetHours(dayUtc);
         break;
      case ST_TOKYO:
         localMinutes=9*60;
         offsetHours=9;
         break;
      default:
         localMinutes=9*60;
         offsetHours=EuropeOffsetHours(dayUtc);
         break;
     }
  }

//+------------------------------------------------------------------+
//| Minutes after server midnight of the manual open                 |
//+------------------------------------------------------------------+
int ManualOpenMinutes()
  {
//--- the string is read defensively, a malformed entry falls back to midnight
   int hour=(int)StringToInteger(StringSubstr(InpManualOpen,0,2));
   int minute=(int)StringToInteger(StringSubstr(InpManualOpen,3,2));
   if(hour<0 || hour>23)
      hour=0;
   if(minute<0 || minute>59)
      minute=0;
   return hour*60+minute;
  }

//+------------------------------------------------------------------+
//| Session open in server time on the calendar day of a bar         |
//+------------------------------------------------------------------+
datetime SessionOpenOfDay(const datetime barTime)
  {
   MqlDateTime st;
   TimeToStruct(barTime,st);
   int totalMinutes;

   ENUM_ST_SESSION session=EffectiveSession();
   if(session==ST_MANUAL)
      totalMinutes=ManualOpenMinutes();
   else
     {
      //--- midday avoids the ambiguous hour on the switching weekend
      datetime dayUtc=MakeUtc(st.year,st.mon,st.day,12);
      int localMinutes,offsetHours;
      SessionLocalOpen(session,dayUtc,localMinutes,offsetHours);
      //--- exchange local time to UTC to server time
      totalMinutes=localMinutes-offsetHours*60+ServerOffsetSec()/60;
     }

//--- wrap into the day, a session can start before server midnight
   totalMinutes=((totalMinutes%1440)+1440)%1440;
   st.hour=totalMinutes/60;
   st.min=totalMinutes%60;
   st.sec=0;
   return StructToTime(st);
  }

//+------------------------------------------------------------------+
//| Short name of the session in use                                 |
//+------------------------------------------------------------------+
string SessionName()
  {
   string name;
   switch(EffectiveSession())
     {
      case ST_UK:
         name="London 08:00";
         break;
      case ST_US:
         name="New York 09:30";
         break;
      case ST_TOKYO:
         name="Tokyo 09:00";
         break;
      case ST_MANUAL:
         name="Manual "+InpManualOpen;
         break;
      default:
         name="Frankfurt 09:00";
         break;
     }
//--- a guessed session is marked, the reader should never take it for a setting
   if(InpSession==ST_AUTO)
      name=name+" (auto)";
   return name;
  }

//+------------------------------------------------------------------+
//| Price of one bar according to the input                          |
//+------------------------------------------------------------------+
double BarPrice(const double high,const double low,const double close)
  {
   switch(InpPrice)
     {
      case ST_PRICE_CLOSE:
         return close;
      case ST_PRICE_MEDIAN:
         return (high+low)/2.0;
      case ST_PRICE_WEIGHTED:
         return (high+low+2.0*close)/4.0;
      default:
         return (high+low+close)/3.0;
     }
  }

//+------------------------------------------------------------------+
//| Clear all plots of one bar                                       |
//+------------------------------------------------------------------+
void ClearBar(const int i)
  {
   ExtTwap[i]=EMPTY_VALUE;
   ExtBand1Up[i]=EMPTY_VALUE;
   ExtBand1Dn[i]=EMPTY_VALUE;
   ExtBand2Up[i]=EMPTY_VALUE;
   ExtBand2Dn[i]=EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//| Write or update one line of the info label                       |
//+------------------------------------------------------------------+
void SetInfoLine(const int line,const string text)
  {
   string name=g_prefix+"INFO"+IntegerToString(line);
   if(!InpShowInfo || text=="")
     {
      ObjectDelete(0,name);
      return;
     }
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetString(0,name,OBJPROP_FONT,"Arial");
     }
//--- lower corners count upwards, so the first line sits highest there as well
   bool lower=(InpInfoCorner==CORNER_LEFT_LOWER || InpInfoCorner==CORNER_RIGHT_LOWER);
   bool right=(InpInfoCorner==CORNER_RIGHT_UPPER || InpInfoCorner==CORNER_RIGHT_LOWER);
   int step=InpInfoSize+8;
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpInfoCorner);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,right ? (lower ? ANCHOR_RIGHT_LOWER : ANCHOR_RIGHT_UPPER) : (lower ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER));
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpInfoX);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpInfoY+(lower ? (1-line)*step : line*step));
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpInfoColor);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,InpInfoSize);
//--- a chart label shows 63 characters at most, both lines stay below that
   ObjectSetString(0,name,OBJPROP_TEXT,StringSubstr(text,0,63));
  }

//+------------------------------------------------------------------+
//| Write or update the two line info label                          |
//+------------------------------------------------------------------+
void UpdateInfoLabel(const string first,const string second)
  {
   SetInfoLine(0,first);
   SetInfoLine(1,second);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,ExtTwap,INDICATOR_DATA);
   SetIndexBuffer(1,ExtBand1Up,INDICATOR_DATA);
   SetIndexBuffer(2,ExtBand1Dn,INDICATOR_DATA);
   SetIndexBuffer(3,ExtBand2Up,INDICATOR_DATA);
   SetIndexBuffer(4,ExtBand2Dn,INDICATOR_DATA);
   for(int p=0; p<5; p++)
      PlotIndexSetDouble(p,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//--- one prefix per chart, several instances never fight over objects
   g_prefix="STWAP_"+IntegerToString((int)ChartID())+"_";
   IndicatorSetString(INDICATOR_SHORTNAME,"Session TWAP ("+SessionName()+")");

//--- above one hour a session holds too few bars for a meaningful average
   g_tooSlow=(PeriodSeconds(PERIOD_CURRENT)>3600);
   if(g_tooSlow)
      Print("SessionTWAP: use a timeframe from M1 to H1, the line stays empty above H1.");
   if(InpBand1<0.0 || InpBand2<0.0)
      Print("SessionTWAP: negative band widths are treated as 0 (off).");
   return INIT_SUCCEEDED;
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
   if(rates_total<=0)
      return 0;
   if(g_tooSlow)
     {
      for(int i=MathMax(0,prev_calculated-1); i<rates_total; i++)
         ClearBar(i);
      UpdateInfoLabel("Session TWAP: use M1 to H1","");
      return rates_total;
     }

//--- on a new tick only the running session is recalculated, its start is searched backwards
   int start=0;
   if(prev_calculated>0)
     {
      start=MathMin(prev_calculated-1,rates_total-1);
      datetime open0=SessionOpenOfDay(time[start]);
      while(start>0 && time[start-1]>=open0 && SessionOpenOfDay(time[start-1])==open0)
         start--;
     }

   int period=PeriodSeconds(PERIOD_CURRENT);
   double band1=MathMax(0.0,InpBand1);
   double band2=MathMax(0.0,InpBand2);
   datetime currentOpen=0;
   double sumW=0.0,sumWP=0.0,sumWP2=0.0,sumAbove=0.0;
   double sessHigh=0.0,sessLow=0.0;
   datetime dayKey=0,dayOpen=0;

   for(int i=start; i<rates_total; i++)
     {
      //--- the session open is computed once per calendar day, not once per bar
      datetime key=time[i]-time[i]%86400;
      if(key!=dayKey)
        {
         dayKey=key;
         dayOpen=SessionOpenOfDay(time[i]);
        }
      if(time[i]<dayOpen)
        {
         ClearBar(i);
         continue;
        }
      //--- a new session resets every running sum
      if(dayOpen!=currentOpen)
        {
         currentOpen=dayOpen;
         sumW=0.0;
         sumWP=0.0;
         sumWP2=0.0;
         sumAbove=0.0;
         sessHigh=high[i];
         sessLow=low[i];
        }

      //--- time weight: the bar's own duration, the forming bar only as far as it has run
      double weight=(double)period;
      if(i==rates_total-1)
         weight=MathMax(1.0,MathMin((double)period,(double)(TimeCurrent()-time[i])));
      double price=BarPrice(high[i],low[i],close[i]);
      sumW+=weight;
      sumWP+=weight*price;
      sumWP2+=weight*price*price;
      sessHigh=MathMax(sessHigh,high[i]);
      sessLow=MathMin(sessLow,low[i]);

      double twap=sumWP/sumW;
      double variance=MathMax(0.0,sumWP2/sumW-twap*twap);
      double sigma=MathSqrt(variance);
      if(close[i]>twap)
         sumAbove+=weight;
      ExtTwap[i]=twap;
      g_statOpen=currentOpen;
      g_statTwap=twap;
      g_statClose=close[i];
      g_statLocation=(sessHigh>sessLow) ? (close[i]-sessLow)/(sessHigh-sessLow)*100.0 : 50.0;
      g_statAbove=sumAbove/sumW*100.0;
      ExtBand1Up[i]=(band1>0.0) ? twap+band1*sigma : EMPTY_VALUE;
      ExtBand1Dn[i]=(band1>0.0) ? twap-band1*sigma : EMPTY_VALUE;
      ExtBand2Up[i]=(band2>0.0) ? twap+band2*sigma : EMPTY_VALUE;
      ExtBand2Dn[i]=(band2>0.0) ? twap-band2*sigma : EMPTY_VALUE;

      //--- a gap to the next bar of the same session means minutes without a tick: the price stood at this close
      if(i<rates_total-1 && time[i+1]>time[i]+period && time[i+1]-time[i+1]%86400==key && time[i+1]>=dayOpen)
        {
         double gap=(double)(time[i+1]-time[i]-period);
         sumW+=gap;
         sumWP+=gap*close[i];
         sumWP2+=gap*close[i]*close[i];
         if(close[i]>twap)
            sumAbove+=gap;
        }
     }

//--- the info label describes the newest session on the chart; before its open, the last completed one
   int last=rates_total-1;
   if(g_statOpen==0)
      UpdateInfoLabel("Session TWAP "+SessionName(),"no session on this chart yet");
   else
     {
      bool running=(ExtTwap[last]!=EMPTY_VALUE);
      double distPts=(g_statClose-g_statTwap)/_Point;
      double distPct=(g_statTwap>0.0) ? (g_statClose/g_statTwap-1.0)*100.0 : 0.0;
      string first="TWAP "+DoubleToString(g_statTwap,_Digits)+"  "+SessionName();
      if(!running)
         first="last session "+TimeToString(g_statOpen,TIME_DATE)+": TWAP "+DoubleToString(g_statTwap,_Digits);
      string second=StringFormat("close %+.0f pts (%+.2f%%)  range %.0f%%  above %.0f%% of time",
                                 distPts,distPct,g_statLocation,g_statAbove);
      UpdateInfoLabel(first,second);
     }
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- the chart is left exactly as it was found
   ObjectsDeleteAll(0,g_prefix);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
