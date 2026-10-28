//+------------------------------------------------------------------+
//|                                            CMACDOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 07 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the MA using the ring buffer:
#include <IncOnRingBuffer\CMAOnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class CMACDOnRingBuffer                                          |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Moving Average                  |
//|              Convergence/Divergence Moving Average               |
//|              Convergence/Divergence, MACD) using the class for   |
//|              working with the ring buffer.                       |
//| Link: http://www.mql5.com/ru/code/1361                           |
//+------------------------------------------------------------------+
class CMACDOnRingBuffer : public CArrayRing
  {
public:
   CMAOnRingBuffer   signal;           // signal line
private:
   CMAOnRingBuffer   m_fast;           // fast line
   CMAOnRingBuffer   m_slow;           // slow line
   string            m_name;           // indicator name  
   string            m_name_main;      // name of main indicator line  
   string            m_name_signal;    // name of signal indicator line  
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     CMACDOnRingBuffer() {} 
                    ~CMACDOnRingBuffer() {}
   //--- initialization method:
   bool              Init(int            fast_period   = 12,
                          int            slow_period   = 26,
                          int            signal_period = 9,
                          ENUM_MA_METHOD fast_method   = MODE_EMA,
                          ENUM_MA_METHOD slow_method   = MODE_EMA,
                          ENUM_MA_METHOD signal_method = MODE_SMA,
                          int            size_buffer   = 256, 
                          bool           as_series     = false);
   //--- basic methods:          
   int               MainOnArray(const int      rates_total, 
                                 const int      prev_calculated,
                                 const double  &array[]);
   double            MainOnValue(const int      rates_total,
                                 const int      prev_calculated, 
                                 const int      begin, 
                                 const double   value, 
                                 const int      index);
   //--- methods to get access to private data:
   int               BarsRequired()                { return(m_bars_required);             }
   string            Name()                        { return(m_name);                      }
   string            NameMain()                    { return(m_name_main);                 }
   string            NameSignal()                  { return(m_name_signal);               }
   string            FastMethod()                  { return(m_fast.MAMethod());           }
   string            SlowMethod()                  { return(m_slow.MAMethod());           }
   string            SignalMethod()                { return(signal.MAMethod());           }
   int               FastPeriod()                  { return(m_fast.MAPeriod());           }
   int               SlowPeriod()                  { return(m_slow.MAPeriod());           }
   int               SignalPeriod()                { return(signal.MAPeriod());           }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));            }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CMACDOnRingBuffer :: Init(int            fast_period   = 12,
                               int            slow_period   = 26,
                               int            signal_period = 9,
                               ENUM_MA_METHOD fast_method   = MODE_EMA,
                               ENUM_MA_METHOD slow_method   = MODE_EMA,
                               ENUM_MA_METHOD signal_method = MODE_SMA,
                               int            size_buffer   = 256, 
                               bool           as_series     = false)
  {
//--- local variables
   int fastperiod   = fast_period;
   int slowperiod   = slow_period;
   int signalperiod = signal_period; 
   int sizebuffer   = size_buffer;
//--- check for input values
   if(fast_period<=0)
     {
      fastperiod=12;
      printf("Input parameter Fast Period has incorrect value (%d). Indicator will use value %d for calculations.",
             fast_period,fastperiod);
     }
   if(slow_period<=0)
     {
      slowperiod=26;
      printf("Input parameter Slow Period has incorrect value (%d). Indicator will use value %d for calculations.",
             slow_period,slowperiod);
     }
   if(signal_period<=0)
     {
      signalperiod=9;
      printf("Input parameter Signal Period has incorrect value (%d). Indicator will use value %d for calculations.",
             signal_period,signalperiod);
     }  
   sizebuffer=MathMax(fastperiod,MathMax(slowperiod,signalperiod));
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffer for the indicator data:
   if(!CArrayRing::Init(sizebuffer))   return false;
//--- initialize the CMAOnRingBuffer class instances:
   if(!m_fast.Init(fastperiod,  fast_method,  sizebuffer)) return false;
   if(!m_slow.Init(slowperiod,  slow_method,  sizebuffer)) return false;
   if(!signal.Init(signalperiod,signal_method,sizebuffer)) return false;
//---
   m_name="MACD("+m_fast.Name()+","+m_slow.Name()+","+signal.Name()+")"; 
   m_name_main="Main("+m_fast.Name()+","+m_slow.Name()+")"; 
   m_name_signal="Signal("+signal.Name()+")"; 
//---
   m_as_series=as_series;
   m_bars_required=MathMax(m_fast.BarsRequired(),m_slow.BarsRequired())+signal.BarsRequired()-1;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CMACDOnRingBuffer :: MainOnArray(const int      rates_total, 
                                     const int      prev_calculated,
                                     const double  &array[])
  {
//--- save as_series flags:
   bool as_series=ArrayGetAsSeries(array);
   if(as_series)  ArraySetAsSeries(array,false);
//--- first calculation:
   if(prev_calculated==0) 
     { 
      //--- looking the start of significant data:
      int i=-1;
      while(++i<rates_total && !IsStopped())
         if(array[i]!=0 && array[i]!=EMPTY_VALUE) break;
      //--- индекс элемента с которого начинаем расчеты:
      m_start=m_begin=MathMax(i,rates_total-Size()-m_bars_required);
     } 
//--- number of bars was changed:
   else m_start=prev_calculated-1;
   m_fast.MainOnValue(rates_total,prev_calculated,m_begin,array[m_start],m_start);
   m_slow.MainOnValue(rates_total,prev_calculated,m_begin,array[m_start],m_start);
   Last(m_fast.Last()-m_slow.Last());
   signal.MainOnValue(rates_total,prev_calculated,m_begin,Last(),m_start);
//--- main loop:     
   for(int i=m_start+1;i<rates_total;i++) 
     { 
      m_fast.MainOnValue(rates_total,prev_calculated,m_begin,array[i],i);
      m_slow.MainOnValue(rates_total,prev_calculated,m_begin,array[i],i);
      Add(m_fast.Last()-m_slow.Last());
      signal.MainOnValue(rates_total,prev_calculated,m_begin,Last(),i);
     }
//--- restore as_series flags:
   if(as_series)  ArraySetAsSeries(array,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CMACDOnRingBuffer:: MainOnValue(const int    rates_total,
                                       const int    prev_calculated, 
                                       const int    begin, 
                                       const double value, 
                                       const int    index)
  {
//--- check as_series flags:
   if(m_as_series) m_index=rates_total-1-index;
   else m_index=index;
//--- check begin:
   if(m_index<begin) return(EMPTY_VALUE);
//--- main calculation:
   m_fast.MainOnValue(rates_total,prev_calculated,begin,value,m_index);
   m_slow.MainOnValue(rates_total,prev_calculated,begin,value,m_index);
   if(prev_calculated-1==m_index) 
      Last(m_fast.Last()-m_slow.Last());
   else
      Add(m_fast.Last()-m_slow.Last());
   signal.MainOnValue(rates_total,prev_calculated,begin,Last(),m_index);
//--- result:
   return(Last());          
  }       
  
