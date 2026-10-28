//+------------------------------------------------------------------+
//|                                              CEROnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 07 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the ring buffer:
#include <IncOnRingBuffer\CArrayRing.mqh>
//+------------------------------------------------------------------+
//| Class CEROnRingBuffer                                            |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Efficiency Ratio (Efficiency    |
//|              Ratio, ER), which is used in the calculation of     |
//|              Adaptive Moving Average (Adaptive Moving            |
//|              Average, AMA), using the class for working with     |
//|              ring                                                |
//|              buffer.                                             |
//| Link: http://www.mql5.com/ru/code/1374                           |
//+------------------------------------------------------------------+
class CEROnRingBuffer : public CArrayRing
  {
public:
   CArrayRing        m_array_in;       // input data buffer
private:
   CArrayRing        m_dnoise;         // buffer for noise increments
   int               m_period;         // calculation period
   double            m_noise;          // noise value for the period
   string            m_name;           // indicator name  
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     CEROnRingBuffer() {} 
                    ~CEROnRingBuffer() {}
   //--- initialization method:
   bool              Init(int  period        = 34,
                          int  size_buffer   = 256, 
                          bool as_series     = false);
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
   int               BarsRequired()                { return(m_bars_required);      }
   string            Name()                        { return(m_name);               }
   int               Period()                      { return(m_period);             }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));            }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CEROnRingBuffer :: Init(int            period        = 34,
                             int            size_buffer   = 256, 
                             bool           as_series     = false)
  {
//--- check for input values
   if(period<=0)
     {
      m_period=34;
      printf("Input parameter Period has incorrect value (%d). Indicator will use value %d for calculations.",
             period,m_period);
     }
   else m_period = period;
   //---
   int sizebuffer = size_buffer;
   if(size_buffer<period+1)
     {
      sizebuffer=m_period+1;
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
//--- initialization of the ring buffer for the indicator data:
   if(!CArrayRing::Init(sizebuffer)) return false;
   if(!m_dnoise.Init(m_period+1))    return false;
   if(!m_array_in.Init(m_period+1))  return false;
//---
   m_name="ER("+IntegerToString(m_period)+")";
//---
   m_as_series=as_series;
   m_bars_required=m_period+1;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CEROnRingBuffer :: MainOnArray(const int      rates_total, 
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
      m_start=MathMax(i,rates_total-Size()-m_bars_required)+m_period;
      //--- Noise
      m_noise=0.0;
      for(i=m_start-m_period+1;i<=m_start && !IsStopped();i++)
        {
         m_dnoise.Add(fabs(array[i]-array[i-1]));
         m_noise+=m_dnoise.Last();
        }
     } 
//--- number of bars was changed:
   else m_start=prev_calculated-1;
   //--- Noise
   m_noise-=m_dnoise.Last();
   m_dnoise.Last(fabs(array[m_start]-array[m_start-1]));
   m_noise+=m_dnoise.Last();
   //--- ER
   if(m_noise==0) Last(0.0);
   else Last(fabs(array[m_start]-array[m_start-m_period])/m_noise);
//--- main loop:     
   for(int i=m_start+1;i<rates_total && !IsStopped();i++) 
     { 
      //--- Noise
      m_dnoise.Add(fabs(array[i]-array[i-1]));
      m_noise+=m_dnoise.Last()-m_dnoise[m_period];
      //--- ER
      if(m_noise==0) Add(0.0);
      else Add(fabs(array[i]-array[i-m_period])/m_noise);
     }
//--- restore as_series flags:
   if(as_series)  ArraySetAsSeries(array,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CEROnRingBuffer:: MainOnValue(const int    rates_total,
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
//--- fill input data
   if(prev_calculated-1==m_index) m_array_in.Last(value);
   else m_array_in.Add(value);
//--- initial calculation:
   m_begin=begin+m_period;
   if(m_index<m_begin) return(EMPTY_VALUE);
   //---
   if(m_index==m_begin)
     {
      //--- Noise
      m_noise=0.0;
      for(int i=m_period-1;i>=0 && !IsStopped();i--)
        {
         m_dnoise.Add(fabs(m_array_in[i]-m_array_in[i+1]));
         m_noise+=m_dnoise.Last();
        }      
      //--- ER
      if(m_noise==0) Add(0.0);
      else Add(fabs(value-m_array_in[m_period])/m_noise);
      //--- result:
      return(Last());          
     }     
//--- main calculation:
   if(prev_calculated-1==m_index) 
     {
      //--- Noise
      m_noise-=m_dnoise.Last();
      m_dnoise.Last(fabs(value-m_array_in[1]));
      m_noise+=m_dnoise.Last();
      //--- ER
      if(m_noise==0) Last(0.0);
      else Last(fabs(value-m_array_in[m_period])/m_noise);
     }
   else
     {
      //--- Noise
      m_dnoise.Add(fabs(value-m_array_in[1]));
      m_noise+=m_dnoise.Last()-m_dnoise[m_period];
      //--- ER
      if(m_noise==0) Add(0.0);
      else Add(fabs(value-m_array_in[m_period])/m_noise);
     }
//--- result:
   return(Last());          
  }