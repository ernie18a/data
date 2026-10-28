//+------------------------------------------------------------------+
//|                                        CFractalsOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 24 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class of the ring buffer:
#include <IncOnRingBuffer\CArrayRing.mqh>
//+------------------------------------------------------------------+
//| Class CFractalsOnRingBuffer                                      |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Fractals (Fractals) using       |
//|              the class for working with the ring buffer.         |
//| Link: http://www.mql5.com/ru/code/1422                           |
//+------------------------------------------------------------------+
class CFractalsOnRingBuffer
  {
public:
   CArrayRing        upper;            // ring buffer of the upper fractals
   CArrayRing        lower;            // ring buffer of the lower fractals
private:
   CArrayRing        m_high_in;        // ring buffer for the maximums storing
   CArrayRing        m_low_in;         // ring buffer for the minimums storing
   string            m_name;           // indicator name 
   int               m_bars_right;     // number of bars from the right of extremum
   int               m_bars_left;      // number of bars from the left of extremum  
   int               m_bars_total;     // полное количество баров для анализа  
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index

public:
                     CFractalsOnRingBuffer() {} 
                    ~CFractalsOnRingBuffer() {}
   //--- initialization method:
   bool              Init(int  bars_right  = 2,
                          int  bars_left   = 2,
                          int  size_buffer = 256, 
                          bool as_series   = false);
   //--- basic methods:          
   int               MainOnArray(const int     rates_total, 
                                 const int     prev_calculated,
                                 const double& high[],
                                 const double& low[]);
   double            MainOnHigh (const int     rates_total,
                                 const int     prev_calculated, 
                                 const int     begin, 
                                 const double  high, 
                                 const int     index);
   double            MainOnLow  (const int     rates_total,
                                 const int     prev_calculated, 
                                 const int     begin, 
                                 const double  low, 
                                 const int     index);                                 
   //--- methods to get access to private data:
   int               BarsRequired()                { return(m_bars_required);    }
   string            Name()                        { return(m_name);             }
   string            NameUpper()                   { return("Upper "+m_name);    }
   string            NameLower()                   { return("Lower "+m_name);    }
   int               BarsRight()                   { return(m_bars_right);       }
   int               BarsLeft()                    { return(m_bars_left);        }
   int               Size()                        { return(upper.Size());       }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CFractalsOnRingBuffer :: Init(int  bars_right  = 2,
                                   int  bars_left   = 2,
                                   int  size_buffer = 256, 
                                   bool as_series   = false)
  {
//--- check for input values
   if(bars_right<1)
     {
      m_bars_right=1;
      printf("Input parameter bars_right has incorrect value (%d). Indicator will use value %d for calculations.",
             bars_right,m_bars_right);
     }
   else m_bars_right=bars_right;
   //---
   if(bars_left<1)
     {
      m_bars_left=1;
      printf("Input parameter bars_left has incorrect value (%d). Indicator will use value %d for calculations.",
             bars_left,m_bars_left);
     }
   else m_bars_left=bars_left;
   //---
   m_bars_total=m_bars_right+m_bars_left+1;
   //---
   
   int sizebuffer=m_bars_total+1;
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffers for the indicator data:
   if(!upper.Init(sizebuffer))   return false;
   if(!lower.Init(sizebuffer))   return false;
   if(!m_high_in.Init(sizebuffer)) return false;
   if(!m_low_in. Init(sizebuffer)) return false;
//---
   m_name="Fractals("+IntegerToString(m_bars_left)+","+IntegerToString(m_bars_right)+")";
//---
   m_as_series=as_series;
   m_bars_required=m_bars_total;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CFractalsOnRingBuffer :: MainOnArray(const int     rates_total, 
                                         const int     prev_calculated,
                                         const double& high[],
                                         const double& low[])
  {
//--- save as_series flags:
   bool as_series_high = ArrayGetAsSeries(high);
   bool as_series_low  = ArrayGetAsSeries(low);
   if(!as_series_high) ArraySetAsSeries(high,true);
   if(!as_series_low)  ArraySetAsSeries(low, true);
//--- first calculation:
   if(prev_calculated==0) 
     { 
      //--- looking the start of significant data:
      int i=rates_total;
      while(--i>=0 && !IsStopped())
         if(high[i]!=0 && high[i]!=EMPTY_VALUE &&
            low[i]!=0  && low[i]!=EMPTY_VALUE
           ) break;
      //--- index of the element from which start calculations:
      m_start=MathMin(i,upper.Size()+m_bars_required);
      m_start-=m_bars_total;
     } 
//--- number of bars was changed:
   else m_start=rates_total-(prev_calculated-1);
   m_index=m_start+m_bars_right;
   //--- Upper Fractal
   if(ArrayMaximum(high,m_start,m_bars_total)==m_index) upper.Update(high[m_index],m_bars_right);
   else upper.Update(EMPTY_VALUE,m_bars_right);
   //--- Lower Fractal
   if(ArrayMinimum(low,m_start,m_bars_total)==m_index) lower.Update(low[m_index],m_bars_right);
   else lower.Update(EMPTY_VALUE,m_bars_right);
//--- main loop:     
   for(int i=m_start-1;i>=0 && !IsStopped();i--) 
     { 
      m_index--;
      //--- Upper Fractal
      upper.Add(EMPTY_VALUE);
      if(ArrayMaximum(high,i,m_bars_total)==m_index) upper.Update(high[m_index],m_bars_right);
      else upper.Update(EMPTY_VALUE,m_bars_right);
      //--- Lower Fractal
      lower.Add(EMPTY_VALUE);
      if(ArrayMinimum(low,i,m_bars_total)==m_index) lower.Update(low[m_index],m_bars_right);
      else lower.Update(EMPTY_VALUE,m_bars_right);
     }
//--- restore as_series flags:
   if(!as_series_high) ArraySetAsSeries(high,false);
   if(!as_series_low)  ArraySetAsSeries(low, false);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on the value High                                      |
//+------------------------------------------------------------------+
double CFractalsOnRingBuffer:: MainOnHigh(const int    rates_total,
                                          const int    prev_calculated, 
                                          const int    begin, 
                                          const double high, 
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
//---
   if(prev_calculated-1==m_index) m_high_in.Last(high);
   else m_high_in.Add(high);
//---
   if(m_index<m_begin+m_bars_required) return(EMPTY_VALUE);
//--- Upper Fractal
   if(prev_calculated-1!=m_index) upper.Add(EMPTY_VALUE);
   //---
   int index_max=0;
   for(int i=1;i<m_bars_total;i++)
      if(m_high_in[index_max]<m_high_in[i]) index_max=i;
   //---      
   if(index_max==m_bars_right) upper.Update(m_high_in[index_max],m_bars_right);
   else upper.Update(EMPTY_VALUE,m_bars_right);
//--- result:
   return(upper.At(m_bars_right));          
  }  
  
//+------------------------------------------------------------------+
//| Indicator on the value Low                                       |
//+------------------------------------------------------------------+
double CFractalsOnRingBuffer:: MainOnLow(const int    rates_total,
                                         const int    prev_calculated, 
                                         const int    begin, 
                                         const double low, 
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
//---
   if(prev_calculated-1==m_index) m_low_in.Last(low);
   else m_low_in.Add(low);
//---
   if(m_index<m_begin+m_bars_required) return(EMPTY_VALUE);
//--- Lower Fractal
   if(prev_calculated-1!=m_index) lower.Add(EMPTY_VALUE);
   //---
   int index_min=0;
   for(int i=1;i<m_bars_total;i++)
      if(m_low_in[index_min]>m_low_in[i]) index_min=i;
   //---      
   if(index_min==m_bars_right) lower.Update(m_low_in[index_min],m_bars_right);
   else lower.Update(EMPTY_VALUE,m_bars_right);
//--- result:
   return(lower.At(m_bars_right));          
  }         
  
