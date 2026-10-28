//+------------------------------------------------------------------+
//|                                        CMomentumOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 18 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class of the ring buffer:
#include <IncOnRingBuffer\CArrayRing.mqh>
//+------------------------------------------------------------------+
//| Class CMomentumOnRingBuffer                                      |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Momentum (Momentum) using the   |
//|              class for working with the ring buffer.             |
//| Link: http://www.mql5.com/ru/code/1396                           |
//+------------------------------------------------------------------+
class CMomentumOnRingBuffer : public CArrayRing
  {
private:
   CArrayRing        m_value_in;       // input data array
   string            m_name;           // indicator name
   int               m_period;         // Momentum period
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index
public:
                     CMomentumOnRingBuffer() {} 
                    ~CMomentumOnRingBuffer() {}
   //--- initialization method:
   bool              Init(int period=14, int size_buffer=256, bool as_series=false);             
   //--- basic methods:          
   int               MainOnArray(const int      rates_total, 
                                 const int      prev_calculated,
                                 const double&  array[]);
   double            MainOnValue(const int      rates_total,
                                 const int      prev_calculated, 
                                 const int      begin, 
                                 const double   value, 
                                 const int      index);
   //--- methods to get access to private data:
   int               BarsRequired()                { return(m_bars_required); }
   string            Name()                        { return(m_name);          }
   int               Period()                      { return(m_period);        }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));       }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CMomentumOnRingBuffer :: Init(int period=14, int size_buffer=256, bool as_series=false)
  {
//--- check for input values
   if(period<0)
     {
      m_period=14;
      Print("Input parameter Period has wrong value. Indicator will use value ",m_period);
     }
   else m_period=period;
   //---
   int sizebuffer=period;
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffers for the indicator data:
   if(!CArrayRing::Init(sizebuffer)) return false;
   if(!m_value_in.Init(m_period+1))  return false;
//---
   m_as_series=as_series;
   m_bars_required=m_period+1;
   m_name="Momentum("+IntegerToString(m_period)+")";
//---
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CMomentumOnRingBuffer :: MainOnArray(const int      rates_total, 
                                         const int      prev_calculated,
                                         const double&  array[])
  {
//--- save as_series flags:
   bool as_series = ArrayGetAsSeries(array);
   if(as_series) ArraySetAsSeries(array, false);
//--- first calculation:
   if(prev_calculated==0)
     {
      //--- looking the start of significant data:
      int i=-1;
      while(++i<rates_total && !IsStopped())
         if(array[i]!=0 && array[i]!=EMPTY_VALUE) break;
      //--- index of the element from which start calculations:
      m_start=MathMax(i,rates_total-Size()-m_bars_required)+m_period;
     }
//--- number of bars was changed:
   else m_start=prev_calculated-1;
   if(array[m_start-m_period]!=0) Last(array[m_start]*100.0/array[m_start-m_period]);
   else Last(EMPTY_VALUE);
//--- main loop:
   for(int i=m_start+1, j=m_start+1-m_period; i<rates_total && !IsStopped(); i++, j++)
     {
      if(array[j]!=0) Add(array[i]*100.0/array[j]);
      else Add(EMPTY_VALUE);
     }
//--- restore as_series flags:
   if(as_series) ArraySetAsSeries(array, true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CMomentumOnRingBuffer:: MainOnValue(const int    rates_total,
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
//--- fill the ring buffer of input data:
   if(prev_calculated-1==m_index) m_value_in.Last(value);
   else m_value_in.Add(value);
//--- initial calculation:
   if(m_index<begin+m_period) return (EMPTY_VALUE);
//--- main calculation:
   if(prev_calculated-1==m_index)
     {
      if(m_value_in[m_period]!=0) 
         Last(value*100.0/m_value_in[m_period]);
      else Last(EMPTY_VALUE);
     }
   else
     {
      if(m_value_in[m_period]!=0) 
         Add(value*100.0/m_value_in[m_period]);
      else Add(EMPTY_VALUE);
     }
//--- result:
   return(Last());          
  }       
