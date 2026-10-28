//+------------------------------------------------------------------+
//|                                      CStochasticOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 12 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the MA using the ring buffer:
#include <IncOnRingBuffer\CMAOnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class CStochasticOnRingBuffer                                    |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Stochastic Oscillator           |
//|              (Stochastic Oscillator) using the class for working |
//|              with the ring buffer.                               |
//| Link: http://www.mql5.com/ru/code/1372                           |
//+------------------------------------------------------------------+
class CStochasticOnRingBuffer
  {
public:
   CMAOnRingBuffer   signal;           // class instance for the signal indicator line
private:
   CArrayRing        m_main;           // class instance for the main indicator line
   CArrayRing        m_max;            // class instance for the highest maximums line for the %K number of periods.
   CArrayRing        m_min;            // class instance for the lowest minimums line for the %K number of periods;
   CArrayRing        m_close;          // class instance for the closing prices
   CArrayRing        m_high;           // class instance for the high prices
   CArrayRing        m_low;            // class instance for the low prices
   //---
   int               m_period_k;       // %K period
   int               m_period_d;       // %D period
   int               m_period_s;       // %K slowing period
   //---
   double            m_sumlow;
   double            m_sumhigh;
   //---
   string            m_name;           // indicator name  
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     CStochasticOnRingBuffer() {} 
                    ~CStochasticOnRingBuffer() {}
   //--- initialization method:
   bool              Init(int            period_k    = 5,
                          int            period_d    = 3,
                          int            period_s    = 3,
                          ENUM_MA_METHOD method      = MODE_SMA,
                          int            size_buffer = 256, 
                          bool           as_series   = false);
   //--- basic methods:          
   int               MainOnArray(const int      rates_total, 
                                 const int      prev_calculated,
                                 const double  &high[],
                                 const double  &low[],
                                 const double  &close[]);
   double            MainOnValue(const int      rates_total,
                                 const int      prev_calculated, 
                                 const int      begin, 
                                 const double   high, 
                                 const double   low, 
                                 const double   close, 
                                 const int      index);
   //--- methods to get access to private data:
   int               BarsRequired()                { return(m_bars_required);       }
   string            Name()                        { return("Main"+m_name);         }
   string            NameSignal()                  { return("Signal"+m_name);       }
   string            Method()                      { return(signal.MAMethod());     }
   int               PeriodK()                     { return(m_period_k);            }
   int               PeriodS()                     { return(m_period_s);            }
   int               PeriodD()                     { return(m_period_d);            }
   int               Size()                        { return(m_main.Size());         }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(m_main.At(index));      }
private:
   double            Max();
   double            Min();
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CStochasticOnRingBuffer :: Init(int            period_k    = 5,
                                     int            period_d    = 3,
                                     int            period_s    = 3,
                                     ENUM_MA_METHOD method_d    = MODE_SMA,
                                     int            size_buffer = 256, 
                                     bool           as_series   = false)
  {
//--- check for input values:
   if(period_k<=0)
     {
      m_period_k=5;
      printf("Input parameter period_k has incorrect value (%d). Indicator will use value %d for calculations.",
             period_k,m_period_k);
     }
   else m_period_k=period_k;
   if(period_d<=0)
     {
      m_period_d=3;
      printf("Input parameter period_d has incorrect value (%d). Indicator will use value %d for calculations.",
             period_d,m_period_d);
     }
   else m_period_d=period_d;
   if(period_s<=0)
     {
      m_period_s=3;
      printf("Input parameter period_s has incorrect value (%d). Indicator will use value %d for calculations.",
             period_s,m_period_s);
     }  
   else m_period_s=period_s;
   //---
   int sizebuffer=MathMax(m_period_k,MathMax(m_period_d,m_period_s));
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffers for the indicator data and intermediate calculations:
   if(!m_max.  Init(m_period_s+1)) return false;
   if(!m_min.  Init(m_period_s+1)) return false;
   if(!m_close.Init(m_period_k+1)) return false;
   if(!m_high. Init(m_period_k+1)) return false;
   if(!m_low.  Init(m_period_k+1)) return false;
   if(!m_main. Init(sizebuffer))   return false;
//--- initialize the CMACDOnRingBuffer class instances:
   if(!signal.Init(m_period_d,method_d,sizebuffer)) return false;
//---
   m_name="Stoch("+IntegerToString(m_period_k)+","+signal.Name()+","+IntegerToString(m_period_s)+")";
//---
   m_as_series=as_series;
   m_bars_required=signal.BarsRequired()+m_period_k+m_period_s-2;
//--- successful:
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CStochasticOnRingBuffer :: MainOnArray(const int      rates_total, 
                                           const int      prev_calculated,
                                           const double  &high[],
                                           const double  &low[],
                                           const double  &close[])
  {
//--- save as_series flags:
   bool as_series_high  = ArrayGetAsSeries(high);
   bool as_series_low   = ArrayGetAsSeries(low);
   bool as_series_close = ArrayGetAsSeries(close);
   if(as_series_high)  ArraySetAsSeries(high, false);
   if(as_series_low)   ArraySetAsSeries(low,  false);
   if(as_series_close) ArraySetAsSeries(close,false);
//--- first calculation:
   if(prev_calculated==0)
     {
      for(int i=0;i<rates_total && !IsStopped();i++)
        {
         if(high[i]!=0  && high[i] != EMPTY_VALUE && 
            low[i]!=0   && low[i]  != EMPTY_VALUE && 
            close[i]!=0 && close[i]!= EMPTY_VALUE)
           {
            m_start=MathMax(i+1,rates_total-Size()-m_bars_required);
            break;
           }
        }        
      m_sumlow =0.0;
      m_sumhigh=0.0;
      m_start+=m_period_k-1;
      for(int i=m_start;i<m_start+m_period_s && !IsStopped();i++)
        {
         m_max.  Add(high[ArrayMaximum(high,i-m_period_k+1,m_period_k)]);
         m_min.  Add(low [ArrayMinimum(low, i-m_period_k+1,m_period_k)]);
         m_close.Add(close[i]);
         m_sumlow +=close[i]-m_min.Last();
         m_sumhigh+=m_max.Last()-m_min.Last();
        }
      m_start=m_begin=m_start+m_period_s-1;
     }
//--- number of bars was changed:
   else m_start=prev_calculated-1;   
   //--- %K
   m_sumlow -=m_close.Last()-m_min.Last();
   m_sumhigh-=m_max.Last()-m_min.Last();
   m_max.  Last(high[ArrayMaximum(high,m_start-m_period_k+1,m_period_k)]);
   m_min.  Last(low [ArrayMinimum(low, m_start-m_period_k+1,m_period_k)]);
   m_close.Last(close[m_start]);
   m_sumlow +=close[m_start]-m_min.Last();
   m_sumhigh+=m_max.Last()-m_min.Last();
   if(m_sumhigh==0.0) m_main.Last(100.0);
   else m_main.Last(m_sumlow/m_sumhigh*100.0);
   //--- signal
   signal.MainOnValue(rates_total,prev_calculated,m_begin,m_main.Last(),m_start);   
//--- main loop:
   for(m_index=m_start+1;m_index<rates_total && !IsStopped();m_index++)
     {
      //--- %K
      m_max.  Add(high[ArrayMaximum(high,m_index-m_period_k+1,m_period_k)]);
      m_min.  Add(low [ArrayMinimum(low, m_index-m_period_k+1,m_period_k)]);
      m_close.Add(close[m_index]);
      m_sumlow +=close[m_index]-m_min.Last()-close[m_index-m_period_s]+m_min[m_period_s];
      m_sumhigh+=m_max.Last()-m_min.Last()-m_max[m_period_s]+m_min[m_period_s];
      if(m_sumhigh==0.0) m_main.Add(100.0);
      else m_main.Add(m_sumlow/m_sumhigh*100.0);
      //--- signal
      signal.MainOnValue(rates_total,prev_calculated,m_begin,m_main.Last(),m_index);         
     }
//--- restore as_series flags
   if(as_series_high)  ArraySetAsSeries(high, true);
   if(as_series_low)   ArraySetAsSeries(low,  true);
   if(as_series_close) ArraySetAsSeries(close,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CStochasticOnRingBuffer:: MainOnValue(const int    rates_total,
                                             const int    prev_calculated, 
                                             const int    begin, 
                                             const double high, 
                                             const double low, 
                                             const double close, 
                                             const int    index)
  {
//--- check as_series flags:
   if(m_as_series) m_index=rates_total-1-index;
   else m_index=index;
//--- check begin:
   if(m_index<begin) return(EMPTY_VALUE);
//--- initial calculation:
   m_begin=begin+m_period_k-1;
   if(m_index<m_begin) 
     {
      m_high. Add(high);
      m_low.  Add(low);
      m_close.Add(close);
      return(EMPTY_VALUE);
     }
   //---
   if(m_index==m_begin)
     {
      m_sumlow  = 0.0;
      m_sumhigh = 0.0;
     }
   //---
   m_begin+=m_period_s;
   if(m_index<m_begin)
     {
      m_high. Add(high);
      m_low.  Add(low);
      m_close.Add(close);
      m_max.  Add(Max());
      m_min.  Add(Min());
      m_sumlow +=close-m_min.Last();
      m_sumhigh+=m_max.Last()-m_min.Last();
      return(EMPTY_VALUE);
     }     
//--- main calculation:
   //--- %K
   if(prev_calculated-1==m_index) 
     {
      m_sumlow -=m_close.Last()-m_min.Last();
      m_sumhigh-=m_max.Last()-m_min.Last();
      m_high. Last(high);
      m_low.  Last(low);
      m_close.Last(close);
      m_max.  Last(Max());
      m_min.  Last(Min());
      m_sumlow +=close-m_min.Last();
      m_sumhigh+=m_max.Last()-m_min.Last();
      if(m_sumhigh==0.0) m_main.Last(100.0);
      else m_main.Last(m_sumlow/m_sumhigh*100.0);
     }
   else
     {
      m_high. Add(high);
      m_low.  Add(low);
      m_close.Add(close);
      m_max.  Add(Max());
      m_min.  Add(Min());
      m_sumlow +=close-m_min.Last()-m_close[m_period_s]+m_min[m_period_s];
      m_sumhigh+=m_max.Last()-m_min.Last()-m_max[m_period_s]+m_min[m_period_s];
      if(m_sumhigh==0.0) m_main.Add(100.0);
      else m_main.Add(m_sumlow/m_sumhigh*100.0);
     }
   //--- signal
   signal.MainOnValue(rates_total,prev_calculated,m_begin,m_main.Last(),m_index);               
//--- result:
   return(m_main.Last());          
  }       
  
//+------------------------------------------------------------------+
//| Maximum                                                          |
//+------------------------------------------------------------------+
double CStochasticOnRingBuffer:: Max()
  {
   double max=-DBL_MAX;
   for(int i=0;i<m_period_k;i++) max=MathMax(max,m_high[i]);
   return max;
  }
  
//+------------------------------------------------------------------+
//| Minimum                                                          |
//+------------------------------------------------------------------+
double CStochasticOnRingBuffer:: Min()
  {
   double min=DBL_MAX;
   for(int i=0;i<m_period_k;i++) min=MathMin(min,m_low[i]);
   return min;
  }  