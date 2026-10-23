//+------------------------------------------------------------------+
//|                                            COsMAOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 10 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the МАCD using the ring buffer:
#include <IncOnRingBuffer\CMACDOnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class COsMAOnRingBuffer                                          |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Moving Average of Oscillator    |
//|              (Moving Average of Oscillator, OsMA) using the class|
//|              for working with the ring buffer.                   |
//| Link: http://www.mql5.com/ru/code/1367                           |
//+------------------------------------------------------------------+
class COsMAOnRingBuffer : public CArrayRing
  {
private:
   CMACDOnRingBuffer m_macd;           // MACD indicator class instance
   string            m_name;           // indicator name  
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     COsMAOnRingBuffer() {} 
                    ~COsMAOnRingBuffer() {}
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
   int               BarsRequired()                { return(m_bars_required);       }
   string            Name()                        { return(m_name);                }
   string            FastMethod()                  { return(m_macd.FastMethod());   }
   string            SlowMethod()                  { return(m_macd.SlowMethod());   }
   string            SignalMethod()                { return(m_macd.SignalMethod()); }
   int               FastPeriod()                  { return(m_macd.FastPeriod());   }
   int               SlowPeriod()                  { return(m_macd.SlowPeriod());   }
   int               SignalPeriod()                { return(m_macd.SignalPeriod()); }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));             }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool COsMAOnRingBuffer :: Init(int            fast_period   = 12,
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
   if(!CArrayRing::Init(sizebuffer)) return false;
//--- initialize the CMACDOnRingBuffer class instances:
   if(!m_macd.Init(fastperiod,slowperiod,signal_period,fast_method,slow_method,signal_method,sizebuffer)) return false;
//---
   m_name="OsMA("+m_macd.Name()+")";
//---
   m_as_series=as_series;
   m_bars_required=m_macd.BarsRequired();
//--- successful:
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int COsMAOnRingBuffer :: MainOnArray(const int      rates_total, 
                                     const int      prev_calculated,
                                     const double  &array[])
  {
//--- calculate the value of the MACD indicator:
   m_macd.MainOnArray(rates_total,prev_calculated,array);
//--- first calculation:
   if(prev_calculated==0) 
     { 
      //--- looking the start of significant data:
      int i=Size();
      while(--i>0 && !IsStopped())
         if(m_macd[i]!=0 && m_macd[i]!=EMPTY_VALUE) break;
      //--- index of the element from which start calculations:
      m_start=i;
     } 
//--- number of bars was changed:
   else m_start=rates_total-prev_calculated;
   Last(m_macd[m_start]-m_macd.signal[m_start]);
//--- main loop:     
   for(int i=m_start-1;i>=0;i--) 
      Add(m_macd[i]-m_macd.signal[i]);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double COsMAOnRingBuffer:: MainOnValue(const int    rates_total,
                                       const int    prev_calculated, 
                                       const int    begin, 
                                       const double value, 
                                       const int    index)
  {
//--- calculate the value of the MACD indicator:
   m_macd.MainOnValue(rates_total,prev_calculated,begin,value,index);
//--- check as_series flags:
   if(m_as_series) m_index=rates_total-1-index;
   else m_index=index;
//--- check begin:
   if(m_index<begin) return(EMPTY_VALUE);
//--- main calculation:
   if(prev_calculated-1==m_index) 
      Last(m_macd.Last()-m_macd.signal.Last());
   else
      Add(m_macd.Last()-m_macd.signal.Last());
//--- result:
   return(Last());          
  }       
  
