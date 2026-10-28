//+------------------------------------------------------------------+
//|                                             CAMAOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 13 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the ER using the ring buffer:
#include <IncOnRingBuffer\CEROnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class CAMAOnRingBuffer                                           |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Adaptive Moving Average         |
//|              (Adaptive Moving Average, AMA) using the class for  |
//|              working with the ring buffer.                       |
//| Link: http://www.mql5.com/ru/code/1375                           |
//+------------------------------------------------------------------+
class CAMAOnRingBuffer : public CArrayRing
  {
private:
   CEROnRingBuffer   m_er;
   int               m_period;         // AMA period
   int               m_fast_period;    // Fast EMA period
   int               m_slow_period;    // Slow EMA period
   string            m_name;           // indicator name  
   double            m_fc;
   double            m_sc;
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     CAMAOnRingBuffer() {} 
                    ~CAMAOnRingBuffer() {}
   //--- initialization method:
   bool              Init(int            period        = 10,
                          int            fast_period   = 2,
                          int            slow_period   = 30,
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
   int               BarsRequired()                { return(m_bars_required); }
   string            Name()                        { return(m_name);          }
   int               Period()                      { return(m_period);        }
   int               FastPeriod()                  { return(m_fast_period);   }
   int               SlowPeriod()                  { return(m_slow_period);   }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));       }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CAMAOnRingBuffer :: Init(int            period        = 10,
                              int            fast_period   = 2,
                              int            slow_period   = 30,
                              int            size_buffer   = 256, 
                              bool           as_series     = false)
  {
//--- check for input values
   if(period<=0)
     {
      m_period=10;
      printf("Input parameter Period has incorrect value (%d). Indicator will use value %d for calculations.",
             period,m_period);
     }  
   else m_period=period;
   if(fast_period<=0)
     {
      m_fast_period=2;
      printf("Input parameter Fast Period has incorrect value (%d). Indicator will use value %d for calculations.",
             m_fast_period,fast_period);
     }
   else m_fast_period=fast_period;
   if(slow_period<=0)
     {
      m_slow_period=30;
      printf("Input parameter Slow Period has incorrect value (%d). Indicator will use value %d for calculations.",
             m_slow_period,slow_period);
     }
   else m_slow_period=slow_period;
   //---
   int sizebuffer=m_period;
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffer for the indicator data:
   if(!CArrayRing::Init(sizebuffer))   return false;
//--- initialize the CEROnRingBuffer class instances:
   if(!m_er.Init(m_period,m_period+1)) return false;
//---
   m_name="AMA("+IntegerToString(m_period)+","+IntegerToString(m_fast_period)+","+IntegerToString(m_slow_period)+")";
//---
   m_fc=2.0/(m_fast_period+1.0);
   m_sc=2.0/(m_slow_period+1.0);
//---
   m_as_series=as_series;
   int m=10;
   m_bars_required=m*MathMax(m_fast_period,m_slow_period)+m_period-1;
   return true;   
  }


//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CAMAOnRingBuffer :: MainOnArray(const int      rates_total, 
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
      //--- index of the element from which start calculations:
      m_begin=MathMax(i,rates_total-Size()-m_bars_required);
      m_start=m_begin+m_period;      
      //--- calculate ER
      for(i=m_begin;i<m_start && !IsStopped();i++)
         m_er.MainOnValue(rates_total,prev_calculated,m_begin,array[i],i);
      //--- prev AMA
      Update(array[m_start-1],1);
     } 
//--- number of bars was changed:
   else m_start=prev_calculated-1;   
   //--- calculate ER
   m_er.MainOnValue(rates_total,prev_calculated,m_begin,array[m_start],m_start);
   //--- calculate SSC
   double dCurrentSSC=(m_er.Last()*(m_fc-m_sc))+m_sc;
   //--- calculate AMA
   double dPrevAMA=At(1);
   Last(pow(dCurrentSSC,2)*(array[m_start]-dPrevAMA)+dPrevAMA);
//--- main loop:     
   for(int i=m_start+1;i<rates_total && !IsStopped();i++) 
     { 
      //--- calculate ER
      m_er.MainOnValue(rates_total,prev_calculated,m_begin,array[i],i);
      //--- calculate SSC
      dCurrentSSC=(m_er.Last()*(m_fc-m_sc))+m_sc;
      //--- calculate AMA
      dPrevAMA=Last();
      Add(pow(dCurrentSSC,2)*(array[i]-dPrevAMA)+dPrevAMA);
     }
//--- restore as_series flags:
   if(as_series)  ArraySetAsSeries(array,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CAMAOnRingBuffer:: MainOnValue(const int    rates_total,
                                      const int    prev_calculated, 
                                      const int    begin, 
                                      const double value, 
                                      const int    index)
  {
//--- check as_series flags:
   if(m_as_series) m_index=rates_total-1-index;
   else m_index=index;
//--- calculate ER
   m_er.MainOnValue(rates_total,prev_calculated,begin,value,m_index);
//--- check begin:
   m_begin=begin+m_er.BarsRequired();
   if(m_index<m_begin) return(EMPTY_VALUE);
   if(m_index==m_begin)
     {
      //--- prev AMA
      Update(m_er.m_array_in[1],1);
      Update(m_er.m_array_in[0],0);
     }
//--- main calculation:
   //--- calculate SSC
   double dCurrentSSC=(m_er.Last()*(m_fc-m_sc))+m_sc;
   //--- calculate AMA
   if(prev_calculated-1==m_index) 
      Last(pow(dCurrentSSC,2)*(value-At(1))+At(1));
   else
      Add(pow(dCurrentSSC,2)*(value-Last())+Last());
//--- result:
   return(Last());          
  }       
  
