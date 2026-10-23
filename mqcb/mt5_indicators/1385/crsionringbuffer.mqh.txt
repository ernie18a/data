//+------------------------------------------------------------------+
//|                                             CRSIOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 16 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the MA using the ring buffer:
#include <IncOnRingBuffer\CMAOnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class CRSIOnRingBuffer                                           |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Adaptive Moving Average         |
//|              (Adaptive Moving Average, RSI) using the class for  |
//|              working with the ring buffer.                       |
//| Link: http://www.mql5.com/ru/code/1385                           |
//+------------------------------------------------------------------+
class CRSIOnRingBuffer : public CArrayRing
  {
private:
   CMAOnRingBuffer   m_pma;            // average value of positive price changes;
   CMAOnRingBuffer   m_nma;            // average value of negative price changes;
   string            m_name;           // indicator name  
   double            m_prev_value;
   double            m_cur_value;
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     CRSIOnRingBuffer() {} 
                    ~CRSIOnRingBuffer() {}
   //--- initialization method:
   bool              Init(int            period      = 14,
                          ENUM_MA_METHOD method      = MODE_SMMA,
                          int            size_buffer = 256, 
                          bool           as_series   = false);
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
   int               BarsRequired()                { return(m_bars_required);    }
   string            Name()                        { return(m_name);             }
   int               Period()                      { return(m_pma.MAPeriod());   }
   string            Method()                      { return(m_pma.MAMethod());   }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));          }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CRSIOnRingBuffer :: Init(int            period      = 14,
                              ENUM_MA_METHOD method      = MODE_SMMA,
                              int            size_buffer = 256, 
                              bool           as_series   = false)
  {
//--- check for input values
   int sizebuffer=period;
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffer for the indicator data:
   if(!CArrayRing::Init(sizebuffer))   return false;
//--- initialize the CMAOnRingBuffer class instances:
   if(!m_pma.Init(period,method,sizebuffer)) return false;
   if(!m_nma.Init(period,method,sizebuffer)) return false;
//---
   m_name="RSI("+IntegerToString(Period())+","+Method()+")"; 
//---
   m_as_series=as_series;
   m_bars_required=m_pma.BarsRequired()+1;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CRSIOnRingBuffer :: MainOnArray(const int      rates_total, 
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
      m_start=m_begin=MathMax(i,rates_total-Size()-m_bars_required)+1;
     } 
//--- number of bars was changed:
   else m_start=prev_calculated-1;      
   double diff=array[m_start]-array[m_start-1]; 
   double positive=(diff>0?diff:0); 
   double negative=(diff<0?-diff:0); 
   double pma=m_pma.MainOnValue(rates_total,prev_calculated,m_begin,positive,m_start);
   double nma=m_nma.MainOnValue(rates_total,prev_calculated,m_begin,negative,m_start);
   //--- calculate RSI
   if(pma==EMPTY_VALUE || nma==EMPTY_VALUE) Last(EMPTY_VALUE);
   else if(nma!=0) Last(100.0-100.0/(1+pma/nma));       
        else if(pma!=0.0) Last(100.0);
             else Last(50.0);
//--- main loop:     
   for(int i=m_start+1;i<rates_total && !IsStopped();i++) 
     { 
      diff=array[i]-array[i-1]; 
      positive=(diff>0?diff:0); 
      negative=(diff<0?-diff:0); 
      pma=m_pma.MainOnValue(rates_total,prev_calculated,m_begin,positive,i);
      nma=m_nma.MainOnValue(rates_total,prev_calculated,m_begin,negative,i);
      //--- calculate RSI
      if(pma==EMPTY_VALUE || nma==EMPTY_VALUE) Add(EMPTY_VALUE);
      else if(nma!=0.0) Add(100.0-100.0/(1+pma/nma));       
           else if(pma!=0.0) Add(100.0);
                else Add(50.0);
     }
//--- restore as_series flags:
   if(as_series)  ArraySetAsSeries(array,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CRSIOnRingBuffer:: MainOnValue(const int    rates_total,
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
   if(m_index==begin)
     {
      m_prev_value=value;
      m_cur_value=value;
      return(EMPTY_VALUE);
     }
//--- main calculation:
   if(prev_calculated-1!=m_index) m_prev_value=m_cur_value;
   m_cur_value=value;
   double diff=value-m_prev_value; 
   double positive=(diff>0?diff:0); 
   double negative=(diff<0?-diff:0); 
   double pma=m_pma.MainOnValue(rates_total,prev_calculated,begin+1,positive,m_index);
   double nma=m_nma.MainOnValue(rates_total,prev_calculated,begin+1,negative,m_index);
   //--- calculate RSI
   if(prev_calculated-1==m_index) 
     {
      if(pma==EMPTY_VALUE || nma==EMPTY_VALUE) Last(EMPTY_VALUE);
      else if(nma!=0.0) Last(100.0-100.0/(1+pma/nma));       
           else if(pma!=0.0) Last(100.0);
                else Last(50.0);
     }
   else
     {
      if(pma==EMPTY_VALUE || nma==EMPTY_VALUE) Add(EMPTY_VALUE);
      else if(nma!=0.0) Add(100.0-100.0/(1+pma/nma));       
           else if(pma!=0.0) Add(100.0);
                else Add(50.0);
     }
//--- result:
   return(Last());          
  }       
  
