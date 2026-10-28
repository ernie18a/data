//+------------------------------------------------------------------+
//|                                                 ACD_Activity.mq5 |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/24742 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/24742"
#property version   "1.00"
#property strict
#property description "How busy the quote stream is against what is normal for"
#property description "this time of day, updated on every tick. The default alpha"
#property description "and beta are a EURUSD fit; refit them per symbol with CAcdModel."

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2

#property indicator_label1  "Activity"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrOrangeRed,clrDodgerBlue
#property indicator_width1  2

#property indicator_label2  "Tick volume"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDimGray
#property indicator_style2  STYLE_DOT

#include <ACD\AcdTypes.mqh>
#include <ACD\AcdEvents.mqh>
#include <ACD\AcdDiurnal.mqh>
#include <ACD\AcdState.mqh>

input group "Model - alpha and beta fitted for this symbol"
input double InpAlpha      = 0.020987;    // alpha
input double InpBeta       = 0.976518;    // beta
input int    InpGapSec     = 300;         // longer waits are a closed market
input group "Rhythm"
input int    InpRhythmDays = 7;           // trading days before the plot that teach the rhythm
input int    InpBinMinutes = 30;          // time-of-day bin width
input group "Display"
input int    InpPlotDays   = 3;           // trading days plotted, today included
input double InpBusy       = 2.0;         // ratio at or above this is coloured busy
input double InpQuiet      = 0.5;         // ratio at or below this is coloured quiet
input bool   InpShowVolume = true;        // also draw raw tick volume against its average

double BufActivity[];
double BufColor[];
double BufVolume[];
double BufRatio[];
double BufExpected[];

SAcdParams  g_params;
CAcdDiurnal g_rhythm;
CAcdState   g_state;
bool        g_built   =false;
bool        g_waiting =false;             // a history request is pending
long        g_last_msc=-1;                // newest tick folded into the state
int         g_bar     =-1;                // bar the newest tick belongs to
double      g_vol_mean=0.0;               // average tick volume per bar, rhythm period

//+------------------------------------------------------------------+
//| Validate the pasted parameters and set up the plot.              |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   SetIndexBuffer(ACD_BUF_ACTIVITY,BufActivity,INDICATOR_DATA);
   SetIndexBuffer(ACD_BUF_COLOR,BufColor,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(ACD_BUF_VOLUME,BufVolume,INDICATOR_DATA);
   SetIndexBuffer(ACD_BUF_RATIO,BufRatio,INDICATOR_CALCULATIONS);
   SetIndexBuffer(ACD_BUF_EXPECTED,BufExpected,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(BufActivity,false);
   ArraySetAsSeries(BufColor,false);
   ArraySetAsSeries(BufVolume,false);
   ArraySetAsSeries(BufRatio,false);
   ArraySetAsSeries(BufExpected,false);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   if(InpAlpha<0.0 || InpBeta<0.0 || InpAlpha+InpBeta>=1.0 ||
      InpBusy<=1.0 || InpQuiet<=0.0 || InpQuiet>=1.0 || InpPlotDays<1 || InpRhythmDays<1)
     {
      Print("ACD_Activity: alpha and beta must be non-negative with a sum below one, "
            "busy above 1, quiet between 0 and 1, and both day counts positive.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_params.dist =ACD_DIST_EXPONENTIAL;
   g_params.alpha=InpAlpha;
   g_params.beta =InpBeta;
   g_params.mean =1.0;
   g_params.omega=1.0-InpAlpha-InpBeta;
   g_params.shape=1.0;

//--- the plot is log2 of the ratio, so doubling and halving are equal steps
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,MathLog(InpBusy)/M_LN2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,MathLog(InpQuiet)/M_LN2);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,StringFormat("busy %.1fx",InpBusy));
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"normal");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,StringFormat("quiet %.1fx",InpQuiet));
   IndicatorSetInteger(INDICATOR_DIGITS,3);
   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("ACD activity (%.4f, %.4f)",InpAlpha,InpBeta));

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Request one range of ticks, a day at a time. Nothing waits in an |
//| indicator, so a failed day is retried on the next calculation.   |
//+------------------------------------------------------------------+
bool FeedRange(const datetime from,const datetime to,CAcdEvents *ev,
               const datetime &time[],const long &tick_volume[],const int rates_total)
  {
   MqlTick buf[];
   for(datetime day=from;day<to;day+=86400)
     {
      const datetime next=(day+86400<to ? day+86400 : to);
      const int n=CopyTicksRange(_Symbol,buf,COPY_TICKS_INFO,(ulong)day*1000,(ulong)next*1000-1);
      if(n<0)
         return false;
      if(ev!=NULL)
        {
         ev.AddTicks(buf,n);
         continue;
        }
      for(int i=0;i<n;i++)
         FeedTick((long)buf[i].time_msc,time,tick_volume,rates_total);
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Write the gauge for one bar; a closed market leaves a break.     |
//+------------------------------------------------------------------+
void WriteBar(const int i,const long now_msc,const long &tick_volume[])
  {
   BufExpected[i]=EMPTY_VALUE;
   if(!g_state.InSession(now_msc))
     {
      BufActivity[i]=EMPTY_VALUE;
      BufRatio[i]   =EMPTY_VALUE;
      BufVolume[i]  =EMPTY_VALUE;
      return;
     }
   const double ratio=g_state.ActivityRatio();
   BufRatio[i]   =ratio;
   BufActivity[i]=MathLog(MathMax(ratio,1.0e-6))/M_LN2;
   BufColor[i]   =(ratio>=InpBusy ? 1.0 : (ratio<=InpQuiet ? 2.0 : 0.0));
   BufVolume[i]  =(InpShowVolume && g_vol_mean>0.0 && tick_volume[i]>0
                   ? MathLog(tick_volume[i]/g_vol_mean)/M_LN2 : EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//| Fold one tick in, closing every bar it has moved past.           |
//+------------------------------------------------------------------+
void FeedTick(const long t_msc,const datetime &time[],const long &tick_volume[],const int rates_total)
  {
   while(g_bar+1<rates_total && t_msc>=(long)time[g_bar+1]*1000)
     {
      WriteBar(g_bar,((long)time[g_bar]+PeriodSeconds())*1000,tick_volume);
      g_bar++;
     }
   g_state.OnEvent(t_msc);
   if(t_msc>g_last_msc)
      g_last_msc=t_msc;
  }

//+------------------------------------------------------------------+
//| Midnight of the n-th most recent trading date, weekends skipped. |
//+------------------------------------------------------------------+
datetime TradingDateStart(const datetime &time[],const int rates_total,const int nth)
  {
   datetime cur=-1,found=0;
   int      dates=0;
   for(int i=rates_total-1;i>=0 && dates<nth;i--)
     {
      const datetime d=time[i]-time[i]%86400;
      if(d==cur)
         continue;
      cur  =d;
      found=d;
      dates++;
     }
   return found;
  }

//+------------------------------------------------------------------+
//| Learn the rhythm on the days before the plot, warm the state,    |
//| then replay the plotted days.                                    |
//+------------------------------------------------------------------+
bool Build(const datetime &time[],const long &tick_volume[],const int rates_total)
  {
   const datetime now        =TimeCurrent();
   const datetime plot_from  =TradingDateStart(time,rates_total,InpPlotDays);
   const datetime rhythm_from=TradingDateStart(time,rates_total,InpPlotDays+InpRhythmDays);
   if(plot_from<=0 || rhythm_from>=plot_from)
      return false;

   CAcdEvents ev;
   ev.SetGapSeconds(InpGapSec);
   if(!FeedRange(rhythm_from,plot_from,GetPointer(ev),time,tick_volume,rates_total))
      return false;
   if(ev.Total()<5000)
     {
      if(!g_waiting)
         PrintFormat("ACD_Activity: only %d quotes before %s, waiting for tick history",
                     ev.Total(),TimeToString(plot_from,TIME_DATE));
      return false;
     }
   if(!g_rhythm.Setup(InpBinMinutes,false) || !g_rhythm.FitWaits(ev,1,ev.Total()-1) ||
      g_rhythm.UnitMeanWaits(ev,1,ev.Total()-1)<=0.0)
      return false;
   if(!g_state.Init(g_params,GetPointer(g_rhythm),InpGapSec))
      return false;
   for(int i=0;i<ev.Total();i++)
      g_state.OnEvent(ev.Time(i));
   g_last_msc=ev.Time(ev.Total()-1);

   double sum=0.0;
   int    cnt=0;
   g_bar=-1;
   for(int i=0;i<rates_total;i++)
     {
      if(time[i]>=rhythm_from && time[i]<plot_from && tick_volume[i]>0)
        {
         sum+=(double)tick_volume[i];
         cnt++;
        }
      if(g_bar<0 && time[i]>=plot_from)
         g_bar=i;
     }
   if(g_bar<0)
      return false;
   g_vol_mean=(cnt>0 ? sum/cnt : 0.0);

   ArrayInitialize(BufActivity,EMPTY_VALUE);
   ArrayInitialize(BufColor,0.0);
   ArrayInitialize(BufVolume,EMPTY_VALUE);
   ArrayInitialize(BufRatio,EMPTY_VALUE);
   ArrayInitialize(BufExpected,EMPTY_VALUE);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,g_bar);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,g_bar);

   return FeedRange(plot_from,now+60,NULL,time,tick_volume,rates_total);
  }

//+------------------------------------------------------------------+
//| Fold in new ticks, each exactly once, and redraw the last bar.   |
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
   if(rates_total<2)
      return 0;
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(tick_volume,false);

   if(prev_calculated<=0 || !g_built)
     {
      g_built=Build(time,tick_volume,rates_total);
      g_waiting=!g_built;
      if(!g_built)
         return 0;
     }
   else
     {
      MqlTick buf[];
      for(int pass=0;pass<50;pass++)
        {
         const int n=CopyTicks(_Symbol,buf,COPY_TICKS_INFO,(ulong)g_last_msc,5000);
         if(n<=0)
            break;
         for(int i=0;i<n;i++)
            if((long)buf[i].time_msc>g_last_msc)
               FeedTick((long)buf[i].time_msc,time,tick_volume,rates_total);
         if(n<5000)
            break;
        }
     }

   const int edge=rates_total-1;
   while(g_bar<edge)
     {
      WriteBar(g_bar,((long)time[g_bar]+PeriodSeconds())*1000,tick_volume);
      g_bar++;
     }
   const long now_msc=MathMax((long)TimeCurrent()*1000,g_last_msc);
   WriteBar(edge,now_msc,tick_volume);
   if(BufRatio[edge]!=EMPTY_VALUE)
      BufExpected[edge]=g_state.ExpectedWaitMs();
   return rates_total;
  }

//+------------------------------------------------------------------+
