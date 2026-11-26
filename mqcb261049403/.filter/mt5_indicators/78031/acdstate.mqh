//+------------------------------------------------------------------+
//|                                                     AcdState.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/24742 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/24742"
#property version   "1.00"
#property strict

#include <ACD\AcdTypes.mqh>
#include <ACD\AcdDiurnal.mqh>

//+------------------------------------------------------------------+
//| CAcdState - the fitted model run live, one quote at a time.      |
//|                                                                  |
//|  One number, the expected adjusted wait, updated per event, no   |
//|  window. Activity ratio: long-run mean over it, 1 = normal.      |
//|  Silence ratio: time since the last quote over the expected wait.|
//|  It shares AcdNextPsi with the fit, so replays are bit-exact.    |
//+------------------------------------------------------------------+
class CAcdState
  {
private:
   SAcdParams        m_p;
   CAcdDiurnal       m_diurnal;
   long              m_gap_ms;
   long              m_last;           // time of the newest event, -1 before any
   double            m_psi;            // expected adjusted wait for the next event
   double            m_x;              // adjusted wait that just ended
   double            m_surprise;       // m_x over what was expected for it
   long              m_events;
   bool              m_ready;

public:
                     CAcdState(void);

//--- fitted parameters and their profile; the gap must match the fit's
   bool              Init(const SAcdParams &p,const CAcdDiurnal *diurnal,const int gap_seconds);
   void              Reset(void);

//--- feed one tick time; false for a same-millisecond tick
   bool              OnEvent(const long t_msc);

   double            Psi(void)      const { return m_psi;      }
   double            Surprise(void) const { return m_surprise; }
   double            AdjustedWait(void) const { return m_x;    }
   long              LastTime(void) const { return m_last;     }
   long              Events(void)   const { return m_events;   }

//--- how busy the market is expected to be, against normal for the hour
   double            ActivityRatio(void) const;

//--- the next wait in milliseconds, rhythm put back in
   double            ExpectedWaitMs(void) const;

//--- time since the last quote over the wait that was expected for it
   double            SilenceRatio(const long now_msc) const;

//--- false before the first event and across a closed market
   bool              InSession(const long now_msc) const;
  };

//+------------------------------------------------------------------+
CAcdState::CAcdState(void)
  {
   m_gap_ms=300000;
   m_ready =false;
   ZeroMemory(m_p);
   Reset();
  }

//+------------------------------------------------------------------+
//| Accept a parameter set only if it describes a stationary model.  |
//+------------------------------------------------------------------+
bool CAcdState::Init(const SAcdParams &p,const CAcdDiurnal *diurnal,const int gap_seconds)
  {
   m_ready=false;
   if(diurnal==NULL || !diurnal.Ready())
     {
      Print("CAcdState: the time-of-day profile has not been fitted");
      return false;
     }
   if(p.alpha<0.0 || p.beta<0.0 || p.alpha+p.beta>=1.0 || p.omega<=0.0 || p.mean<=0.0)
     {
      Print("CAcdState: parameters do not describe a stationary model: ",AcdParamsToString(p));
      return false;
     }
   m_p=p;
   m_diurnal.Assign(diurnal);
   m_gap_ms=(gap_seconds>0 ? (long)gap_seconds*1000 : 300000);
   m_ready =true;
   Reset();
   return true;
  }

//+------------------------------------------------------------------+
//| Forget the past. The next event is treated as a session start.   |
//+------------------------------------------------------------------+
void CAcdState::Reset(void)
  {
   m_last    =-1;
   m_psi     =(m_p.mean>0.0 ? m_p.mean : 1.0);
   m_x       =0.0;
   m_surprise=0.0;
   m_events  =0;
  }

//+------------------------------------------------------------------+
//| One event: adjust the ended wait and fold it into psi. A wait    |
//| over the gap resets psi to the long-run mean, as in the fit.     |
//+------------------------------------------------------------------+
bool CAcdState::OnEvent(const long t_msc)
  {
   if(!m_ready || (m_last>=0 && t_msc<=m_last))
      return false;

   m_events++;
   if(m_last<0 || t_msc-m_last>m_gap_ms)
     {
      m_last    =t_msc;
      m_psi     =m_p.mean;
      m_x       =0.0;
      m_surprise=0.0;
      return true;
     }

   m_x       =(double)(t_msc-m_last)/m_diurnal.Value(m_last);
   m_surprise=m_x/m_psi;
   m_psi     =AcdNextPsi(m_p,m_x,m_psi);
   m_last    =t_msc;
   return true;
  }

//+------------------------------------------------------------------+
double CAcdState::ActivityRatio(void) const
  {
   return (m_psi>0.0 ? m_p.mean/m_psi : 0.0);
  }

//+------------------------------------------------------------------+
double CAcdState::ExpectedWaitMs(void) const
  {
   if(m_last<0)
      return 0.0;
   return m_psi*m_diurnal.Value(m_last);
  }

//+------------------------------------------------------------------+
double CAcdState::SilenceRatio(const long now_msc) const
  {
   const double expected=ExpectedWaitMs();
   if(expected<=0.0 || now_msc<m_last)
      return 0.0;
   return (double)(now_msc-m_last)/expected;
  }

//+------------------------------------------------------------------+
bool CAcdState::InSession(const long now_msc) const
  {
   return (m_last>=0 && now_msc-m_last<=m_gap_ms);
  }
//+------------------------------------------------------------------+
