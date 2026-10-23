//+------------------------------------------------------------------+
//|                                                PropFirmGuard.mqh |
//|                                      Copyright 2026, German Soto |
//|                                                https://shushi.cl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, German Soto"
#property link      "https://shushi.cl"

#ifndef PROPFIRMGUARD_MQH
#define PROPFIRMGUARD_MQH

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Prop-firm account guard                                          |
//|                                                                  |
//| Watches account equity against a daily loss limit and a total     |
//| drawdown limit, both reduced by a safety buffer. On breach it     |
//| flattens the account and blocks new trades until the next daily   |
//| reset (daily limit) or for good (total drawdown limit).           |
//|                                                                  |
//| Usage from any expert advisor:                                    |
//|   #include "PropFirmGuard.mqh"                                    |
//|   CPropFirmGuard ExtGuard;                                        |
//|   int OnInit()  { ExtGuard.Init(5.0,10.0,0.5,0); ... }            |
//|   void OnTick() { ExtGuard.Update();                              |
//|                   if(!ExtGuard.Allowed()) return; ...trade... }   |
//|                                                                  |
//| The guard polls the account state on every Update() call, so it   |
//| needs no notification from the caller and also covers manual      |
//| trades and other experts running on the same account.             |
//|                                                                  |
//| It keeps all state in memory and uses no global variables and no  |
//| files, so it behaves identically on a chart and in the strategy   |
//| tester. If the expert restarts intraday, the daily baseline is    |
//| re-anchored to the current equity, which never allows more loss   |
//| than a fresh trading day would.                                   |
//+------------------------------------------------------------------+
class CPropFirmGuard
  {
private:
   //--- configuration
   double            m_daily_loss_pct;    // daily loss limit (% of day-start equity)
   double            m_total_dd_pct;      // total drawdown limit (% from equity peak)
   double            m_buffer_pct;        // safety buffer subtracted from both limits
   int               m_reset_hour;        // server hour at which the trading day rolls
   ulong             m_magic;             // 0 = guard whole account, else only this magic
   int               m_retry_seconds;     // minimum delay between two flatten passes
   //--- state
   double            m_day_start_equity;  // equity baseline of the current trading day
   double            m_peak_equity;       // equity high-water mark since Init()
   long              m_current_day;       // index of the current trading day (-1 = unset)
   bool              m_daily_breached;    // daily limit hit, blocked until next reset
   bool              m_total_breached;    // total limit hit, blocked for good
   datetime          m_last_close_try;    // time of the last flatten pass
   int               m_close_passes;      // flatten passes done for the active breach
   CTrade            m_trade;             // trading object used to flatten

   //--- internal helpers
   long              DayIndex(const datetime time) const;
   double            EffectiveDaily(void) const;
   double            EffectiveTotal(void) const;
   bool              MagicMatches(const long magic) const;
   void              FlattenPass(void);

public:
                     CPropFirmGuard(void);
                    ~CPropFirmGuard(void);
   //--- setup
   bool              Init(const double daily_loss_pct, const double total_dd_pct,
                          const double buffer_pct, const int reset_hour,
                          const ulong magic=0);
   //--- main entry point, call it on every tick before any trading logic
   void              Update(void);
   //--- true while the expert is allowed to open new trades
   bool              Allowed(void) const { return(!m_daily_breached && !m_total_breached); }
   //--- state read-outs for panels and logs
   bool              DailyBreached(void)     const { return(m_daily_breached);   }
   bool              TotalBreached(void)     const { return(m_total_breached);   }
   double            DayStartEquity(void)    const { return(m_day_start_equity); }
   double            PeakEquity(void)        const { return(m_peak_equity);      }
   double            EffectiveDailyPct(void) const { return(EffectiveDaily());   }
   double            EffectiveTotalPct(void) const { return(EffectiveTotal());   }
   double            DailyLossNowPct(void) const;
   double            TotalDdNowPct(void) const;
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPropFirmGuard::CPropFirmGuard(void) : m_daily_loss_pct(5.0),
                                       m_total_dd_pct(10.0),
                                       m_buffer_pct(0.5),
                                       m_reset_hour(0),
                                       m_magic(0),
                                       m_retry_seconds(5),
                                       m_day_start_equity(0.0),
                                       m_peak_equity(0.0),
                                       m_current_day(-1),
                                       m_daily_breached(false),
                                       m_total_breached(false),
                                       m_last_close_try(0),
                                       m_close_passes(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPropFirmGuard::~CPropFirmGuard(void)
  {
  }
//+------------------------------------------------------------------+
//| Trading day index of a server time, shifted by the reset hour    |
//+------------------------------------------------------------------+
long CPropFirmGuard::DayIndex(const datetime time) const
  {
   return(((long)time-(long)m_reset_hour*3600)/86400);
  }
//+------------------------------------------------------------------+
//| Daily loss limit actually enforced, after the safety buffer      |
//+------------------------------------------------------------------+
double CPropFirmGuard::EffectiveDaily(void) const
  {
   return(MathMax(0.1,m_daily_loss_pct-m_buffer_pct));
  }
//+------------------------------------------------------------------+
//| Total drawdown limit actually enforced, after the safety buffer  |
//+------------------------------------------------------------------+
double CPropFirmGuard::EffectiveTotal(void) const
  {
   return(MathMax(0.1,m_total_dd_pct-m_buffer_pct));
  }
//+------------------------------------------------------------------+
//| Checks whether a position or order belongs to the guarded scope  |
//+------------------------------------------------------------------+
bool CPropFirmGuard::MagicMatches(const long magic) const
  {
   return(m_magic==0 || (ulong)magic==m_magic);
  }
//+------------------------------------------------------------------+
//| Initialization and checking for input parameters                 |
//+------------------------------------------------------------------+
bool CPropFirmGuard::Init(const double daily_loss_pct,const double total_dd_pct,
                          const double buffer_pct,const int reset_hour,
                          const ulong magic)
  {
//--- both limits must be positive
   if(daily_loss_pct<=0.0 || total_dd_pct<=0.0)
     {
      Print("[PropFirmGuard] Init rejected: limits must be positive");
      return(false);
     }
//--- the buffer only makes sense inside both limits
   if(buffer_pct<0.0 || buffer_pct>=MathMin(daily_loss_pct,total_dd_pct))
     {
      Print("[PropFirmGuard] Init rejected: buffer must be >= 0 and smaller than both limits");
      return(false);
     }
//--- the reset hour is a server clock hour
   if(reset_hour<0 || reset_hour>23)
     {
      Print("[PropFirmGuard] Init rejected: reset hour must be 0..23");
      return(false);
     }
//--- store the configuration
   m_daily_loss_pct=daily_loss_pct;
   m_total_dd_pct=total_dd_pct;
   m_buffer_pct=buffer_pct;
   m_reset_hour=reset_hour;
   m_magic=magic;
//--- anchor the equity baselines, the first Update() opens the trading day
   m_day_start_equity=AccountInfoDouble(ACCOUNT_EQUITY);
   m_peak_equity=m_day_start_equity;
   m_current_day=-1;
   m_daily_breached=false;
   m_total_breached=false;
   m_last_close_try=0;
   m_close_passes=0;
   PrintFormat("[PropFirmGuard] armed: daily %.2f%% / total DD %.2f%% / buffer %.2f%% / reset hour %02d:00 (effective %.2f%% and %.2f%%)",
               m_daily_loss_pct,m_total_dd_pct,m_buffer_pct,m_reset_hour,
               EffectiveDaily(),EffectiveTotal());
   return(true);
  }
//+------------------------------------------------------------------+
//| Main guard cycle: rollover, limit checks and flattening          |
//+------------------------------------------------------------------+
void CPropFirmGuard::Update(void)
  {
   double   equity=AccountInfoDouble(ACCOUNT_EQUITY);
   datetime now=TimeCurrent();
   long     day=DayIndex(now);
//--- daily rollover, this also opens the very first trading day
   if(day!=m_current_day)
     {
      m_current_day=day;
      m_day_start_equity=equity;
      m_daily_breached=false;
      m_close_passes=0;
      PrintFormat("[PropFirmGuard] New trading day (%s server), baseline equity %.2f",
                  TimeToString(now,TIME_DATE|TIME_MINUTES),equity);
     }
//--- update the equity high-water mark
   if(equity>m_peak_equity)
      m_peak_equity=equity;
//--- total drawdown check, this one latches for good
   if(!m_total_breached && m_peak_equity>0.0)
     {
      double drawdown_pct=(m_peak_equity-equity)/m_peak_equity*100.0;
      if(drawdown_pct>=EffectiveTotal())
        {
         m_total_breached=true;
         m_close_passes=0;
         PrintFormat("[PropFirmGuard] TOTAL DRAWDOWN limit hit: %.2f%% >= %.2f%% (peak %.2f, equity %.2f), flattening account",
                     drawdown_pct,EffectiveTotal(),m_peak_equity,equity);
        }
     }
//--- daily loss check, this one latches until the next reset
   if(!m_daily_breached && m_day_start_equity>0.0)
     {
      double loss_pct=(m_day_start_equity-equity)/m_day_start_equity*100.0;
      if(loss_pct>=EffectiveDaily())
        {
         m_daily_breached=true;
         m_close_passes=0;
         PrintFormat("[PropFirmGuard] DAILY LOSS limit hit: %.2f%% >= %.2f%% (day start %.2f, equity %.2f), flattening account",
                     loss_pct,EffectiveDaily(),m_day_start_equity,equity);
        }
     }
//--- while breached, keep the account flat
   if(m_daily_breached || m_total_breached)
      FlattenPass();
  }
//+------------------------------------------------------------------+
//| One throttled pass closing positions and deleting orders         |
//|                                                                  |
//| Never loops: at most one pass every m_retry_seconds. Tickets the |
//| broker refuses are simply retried on the next pass.              |
//+------------------------------------------------------------------+
void CPropFirmGuard::FlattenPass(void)
  {
   datetime now=TimeCurrent();
//--- throttle the retries after the first pass
   if(m_close_passes>0 && (long)now-(long)m_last_close_try<m_retry_seconds)
      return;
   bool anything_left=false;
//--- close every guarded position, by ticket, valid for netting and hedging
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;
      if(!MagicMatches(PositionGetInteger(POSITION_MAGIC)))
         continue;
      anything_left=true;
      if(!m_trade.PositionClose(ticket))
         PrintFormat("[PropFirmGuard] close rejected for position #%I64u (retcode %u '%s'), retry in %d s",
                     ticket,m_trade.ResultRetcode(),m_trade.ResultRetcodeDescription(),m_retry_seconds);
     }
//--- delete every guarded pending order
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0)
         continue;
      if(!MagicMatches(OrderGetInteger(ORDER_MAGIC)))
         continue;
      anything_left=true;
      if(!m_trade.OrderDelete(ticket))
         PrintFormat("[PropFirmGuard] delete rejected for order #%I64u (retcode %u '%s'), retry in %d s",
                     ticket,m_trade.ResultRetcode(),m_trade.ResultRetcodeDescription(),m_retry_seconds);
     }
//--- remember the pass only if there was something to close
   if(anything_left)
     {
      m_last_close_try=now;
      m_close_passes++;
     }
  }
//+------------------------------------------------------------------+
//| Loss of the current trading day, in percent                      |
//+------------------------------------------------------------------+
double CPropFirmGuard::DailyLossNowPct(void) const
  {
   if(m_day_start_equity<=0.0)
      return(0.0);
   return((m_day_start_equity-AccountInfoDouble(ACCOUNT_EQUITY))/m_day_start_equity*100.0);
  }
//+------------------------------------------------------------------+
//| Drawdown from the equity peak, in percent                        |
//+------------------------------------------------------------------+
double CPropFirmGuard::TotalDdNowPct(void) const
  {
   if(m_peak_equity<=0.0)
      return(0.0);
   return((m_peak_equity-AccountInfoDouble(ACCOUNT_EQUITY))/m_peak_equity*100.0);
  }
//+------------------------------------------------------------------+
#endif // PROPFIRMGUARD_MQH
//+------------------------------------------------------------------+
