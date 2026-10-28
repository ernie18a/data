//+------------------------------------------------------------------+
//|                                            CDEMAOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 24 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the MA using the ring buffer:
#include <IncOnRingBuffer\CMAOnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class CDEMAOnRingBuffer                                          |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Double Exponential Moving       |
//|              Average (Double Exponential Moving Average, DEMA)   |
//|              using the class for working with the ring           |
//|              buffer.                                             |
//| Link: http://www.mql5.com/ru/code/1416                           |
//+------------------------------------------------------------------+
class CDEMAOnRingBuffer : public CArrayRing
  {
public:
   CMAOnRingBuffer   ma;               // moving average
private:
   CMAOnRingBuffer   m_ma2;            // MA2 - double sequential smoothing
   string            m_name;           // indicator name  
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_begin1;         // index of the first significant element for the MA calculation
   int               m_begin2;         // index of the first significant element for the MA2 calculation
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     CDEMAOnRingBuffer() {} 
                    ~CDEMAOnRingBuffer() {}
   //--- initialization method:
   bool              Init(int            period      = 12,
                          ENUM_MA_METHOD method      = MODE_EMA,
                          int            size_buffer = 256, 
                          bool           as_series   = false);
   //--- basic methods:          
   int               MainOnArray(const int     rates_total, 
                                 const int     prev_calculated,
                                 const double& array[]);
   double            MainOnValue(const int     rates_total,
                                 const int     prev_calculated, 
                                 const int     begin, 
                                 const double  value, 
                                 const int     index);
   //--- methods to get access to private data:
   int               BarsRequired()                { return(m_bars_required); }
   string            Name()                        { return(m_name);          }
   int               Period()                      { return(ma.MAPeriod());   }
   string            Method()                      { return(ma.MAMethod());   }
   double            MA(int index)                 { return(ma.At(index));    }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));       }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CDEMAOnRingBuffer :: Init(int            period      = 12,
                               ENUM_MA_METHOD method      = MODE_EMA,
                               int            size_buffer = 256, 
                               bool           as_series   = false)
  {
//--- check for input values
   //---
   int sizebuffer=2;
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffer for the indicator data:
   if(!CArrayRing::Init(sizebuffer))   return false;
//--- initialize the CMAOnRingBuffer class instances:
   if(!ma.Init(period,method,sizebuffer)) return false;
   if(!m_ma2.Init(period,method,period+1)) return false;
//---
   m_name="DEMA("+IntegerToString(Period())+","+Method()+")";
//---
   m_as_series=as_series;
   m_bars_required=ma.BarsRequired()+m_ma2.BarsRequired();;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CDEMAOnRingBuffer :: MainOnArray(const int     rates_total, 
                                     const int     prev_calculated,
                                     const double& array[])
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
      m_start=m_begin1=MathMax(i,rates_total-Size()-m_bars_required);
      m_begin2=m_begin1+ma.BarsRequired();
     } 
   else m_start=prev_calculated-1;
//--- number of bars was changed:
   //--- calculate MA
   double ma1=ma.MainOnValue(rates_total,prev_calculated,m_begin1,array[m_start],m_start);
   double ma2=m_ma2.MainOnValue(rates_total,prev_calculated,m_begin2,ma1,m_start);
   //--- calculate DEMA
   if(ma1==EMPTY_VALUE || ma2==EMPTY_VALUE) Last(EMPTY_VALUE);
   else Last(2.0*ma1-ma2);
//--- main loop:     
   for(int i=m_start+1;i<rates_total && !IsStopped();i++) 
     { 
      //--- calculate MA
      ma1=ma.MainOnValue(rates_total,prev_calculated,m_begin1,array[i],i);
      ma2=m_ma2.MainOnValue(rates_total,prev_calculated,m_begin2,ma1,i);
      //--- calculate DEMA
      if(ma1==EMPTY_VALUE || ma2==EMPTY_VALUE) Last(EMPTY_VALUE);
      else Add(2.0*ma1-ma2);
     }
//--- restore as_series flags:
   if(as_series)  ArraySetAsSeries(array,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CDEMAOnRingBuffer:: MainOnValue(const int    rates_total,
                                       const int    prev_calculated, 
                                       const int    begin, 
                                       const double value, 
                                       const int    index)
  {
//--- check as_series flags:
   if(m_as_series) 
     {
      m_begin=rates_total-1-begin;
      m_index=rates_total-1-index;
     }
   else
     {
      m_begin=begin;
      m_index=index;
     }
//--- check begin:
   if(m_index<m_begin) return(EMPTY_VALUE);
   if(m_index==m_begin)
     {
      m_begin1=m_begin;
      m_begin2=m_begin+ma.BarsRequired();
     }
//--- main calculation:
   //--- calculate MA
   double ma1=ma.MainOnValue(rates_total,prev_calculated,m_begin1,value,m_index);
   double ma2=m_ma2.MainOnValue(rates_total,prev_calculated,m_begin2,ma1,m_index);
   //--- calculate DEMA
   if(prev_calculated-1==m_index) 
     {
      if(ma1==EMPTY_VALUE || ma2==EMPTY_VALUE) Last(EMPTY_VALUE);
      else Last(2.0*ma1-ma2);
     }
   else
      if(ma1==EMPTY_VALUE || ma2==EMPTY_VALUE) Add(EMPTY_VALUE);
      else Add(2.0*ma1-ma2);
//--- result:
   return(Last());          
  }       
  
