//+------------------------------------------------------------------+
//|                                            CTEMAOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 24 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the DEMA using the ring buffer:
#include <IncOnRingBuffer\CDEMAOnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class CTEMAOnRingBuffer                                          |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Triple Exponential Moving       |
//|              Average (Triple Exponential Moving Average, TEMA)   |
//|              using the class for working with the ring           |
//|              buffer.                                             |
//| Link: http://www.mql5.com/ru/code/1417                           |
//+------------------------------------------------------------------+
class CTEMAOnRingBuffer : public CArrayRing
  {
public:
   CDEMAOnRingBuffer dema;             // DEMA
private:
   CMAOnRingBuffer   m_dema_err;       // MA from the DEMA error
   string            m_name;           // indicator name  
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin1;         // index of the first significant element for the DEMA calculation
   int               m_begin2;         // index of the first significant element for the DEMA error calculation
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     CTEMAOnRingBuffer() {} 
                    ~CTEMAOnRingBuffer() {}
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
   int               BarsRequired()                { return(m_bars_required);    }
   string            Name()                        { return(m_name);             }
   int               Period()                      { return(dema.Period());      }
   string            Method()                      { return(dema.Method());      }
   //--- methods of access to additional ring buffers:
   double            MA(int index)                 { return(dema.ma.At(index));  }
   double            DEMA(int index)               { return(dema.At(index));     }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));          }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CTEMAOnRingBuffer :: Init(int            period      = 12,
                               ENUM_MA_METHOD method      = MODE_EMA,
                               int            size_buffer = 256, 
                               bool           as_series   = false)
  {
//--- check for input values
   int sizebuffer=2;
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffer for the indicator data:
   if(!CArrayRing::Init(sizebuffer))   return false;
//--- initialize the CMAOnRingBuffer and CDEMAOnRingBuffer class instances:
   if(!dema.Init(period,method,sizebuffer)) return false;
   if(!m_dema_err.Init(period,method,sizebuffer)) return false;
//---
   m_name="TEMA("+IntegerToString(Period())+","+Method()+")";
//---
   m_as_series=as_series;
   m_bars_required=dema.BarsRequired()+m_dema_err.BarsRequired();;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CTEMAOnRingBuffer :: MainOnArray(const int     rates_total, 
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
      m_begin2=m_begin1+dema.BarsRequired();
     } 
   else m_start=prev_calculated-1;
//--- number of bars was changed:
   //--- calculate DEMA
   double demavalue=dema.MainOnValue(rates_total,prev_calculated,m_begin1,array[m_start],m_start);
   //--- calculate DEMA error
   double dema_err=m_dema_err.MainOnValue(rates_total,prev_calculated,m_begin2,array[m_start]-demavalue,m_start);
   //--- calculate TEMA
   if(demavalue==EMPTY_VALUE || dema_err==EMPTY_VALUE) Last(EMPTY_VALUE);
   else Last(demavalue+dema_err);
//--- main loop:     
   for(int i=m_start+1;i<rates_total && !IsStopped();i++) 
     { 
      //--- calculate DEMA
      demavalue=dema.MainOnValue(rates_total,prev_calculated,m_begin1,array[i],i);
      //--- calculate DEMA error
      dema_err=m_dema_err.MainOnValue(rates_total,prev_calculated,m_begin2,array[i]-demavalue,i);
      //--- calculate TEMA
      if(demavalue==EMPTY_VALUE || dema_err==EMPTY_VALUE) Add(EMPTY_VALUE);
      else Add(demavalue+dema_err);
     }
//--- restore as_series flags:
   if(as_series)  ArraySetAsSeries(array,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CTEMAOnRingBuffer:: MainOnValue(const int    rates_total,
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
      m_begin1=begin;
      m_begin2=begin+dema.BarsRequired();
     }
//--- main calculation:
   //--- calculate DEMA
   double demavalue=dema.MainOnValue(rates_total,prev_calculated,m_begin1,value,m_index);
   //--- calculate DEMA error
   double dema_err=m_dema_err.MainOnValue(rates_total,prev_calculated,m_begin2,value-demavalue,m_index);
   //--- calculate TEMA
   if(prev_calculated-1==m_index) 
     {
      if(demavalue==EMPTY_VALUE || dema_err==EMPTY_VALUE) Last(EMPTY_VALUE);
      else Last(demavalue+dema_err);
     }
   else
     {
      if(demavalue==EMPTY_VALUE || dema_err==EMPTY_VALUE) Add(EMPTY_VALUE);
      else Add(demavalue+dema_err);
     }
//--- result:
   return(Last());          
  }       
  
