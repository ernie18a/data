//+------------------------------------------------------------------+
//|                                             COBVOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 20 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class of the ring buffer:
#include <IncOnRingBuffer\CArrayRing.mqh>
//--- Macro substitution:
#define DOBV(p,pp,v) if((p)>(pp)) m_dobv=(v); else if((p)<(pp)) m_dobv=-(v); else m_dobv=0;

//+------------------------------------------------------------------+
//| Class COBVOnRingBuffer                                           |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator On Balance Volume (On Balance   |
//|              Volume, OBV) using the class for working with the   |
//|              ring buffer.                                        |
//| Link: http://www.mql5.com/ru/code/1402                           |
//+------------------------------------------------------------------+
class COBVOnRingBuffer : public CArrayRing
  {
private:
   CArrayRing           m_dOBV;          // ring buffer for the OBV increments
   string               m_name;          // indicator name  
   int                  m_period;        // calculation period
   long                 m_dobv;          
   double               m_prev_price;    // previous price
   double               m_cur_price;     // current price
   bool                 m_as_series;     // true, if the indexing as in time series
   int                  m_bars_required; // number of elements required to calculate
   int                  m_begin;         // index of the first significant element
   int                  m_start;         // index of element to start the calculation
   int                  m_index;         // current element index

public:
                        COBVOnRingBuffer() {} 
                       ~COBVOnRingBuffer() {}
   //--- initialization method:
   bool                 Init(int                 period      = 0,
                             int                 size_buffer = 256, 
                             bool                as_series   = false);
   //--- basic methods:          
   int                  MainOnArray(const int     rates_total, 
                                    const int     prev_calculated,
                                    const double& price[],
                                    const long&   volume[]);
   double               MainOnValue(const int     rates_total,
                                    const int     prev_calculated, 
                                    const int     begin,
                                    const double  price,
                                    const long    volume, 
                                    const int     index);
   //--- methods to get access to private data:
   int                  BarsRequired()                { return(m_bars_required);    }
   string               Name()                        { return(m_name);             }
   int                  Period()                      { return(m_period);           }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const        { return(At(index));          }
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool COBVOnRingBuffer :: Init(int  period      = 0,
                              int  size_buffer = 256, 
                              bool as_series   = false)
  {
//--- check for input values
   if(period<0)
     {
      m_period=0;
      printf("Input parameter Period has incorrect value (%d). Indicator will use value %d for calculations.",
             period,m_period);
     }  
   else m_period=period;
   //---
   int sizebuffer=2;
   if(size_buffer<sizebuffer)
     {
      printf("Input parameter size_buffer has incorrect value (%d). Indicator will use value %d for calculations.",
             size_buffer,sizebuffer);
     }
   else sizebuffer=size_buffer;
//--- initialization of the ring buffer for the indicator data:
   if(!CArrayRing::Init(sizebuffer)) return false;
   if(!m_dOBV.Init(m_period+1))      return false;
//---
   m_bars_required=0;
   m_name="OBV"; 
   if(m_period>0)
     {
      m_bars_required=m_period;
      m_name+="("+IntegerToString(m_period)+")";
     }
//---
   m_as_series=as_series;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int COBVOnRingBuffer :: MainOnArray(const int     rates_total, 
                                    const int     prev_calculated,
                                    const double& price[],
                                    const long&   volume[])
                  
  {
//--- save as_series flags:
   bool as_series_price = ArrayGetAsSeries(price);
   bool as_series_vol   = ArrayGetAsSeries(volume);
   if(as_series_price) ArraySetAsSeries(price, false);
   if(as_series_vol)   ArraySetAsSeries(volume,false);
//--- first calculation:
   if(prev_calculated==0) 
     { 
      //--- looking the start of significant data:
      int i=-1;
      while(++i<rates_total && !IsStopped())
         if(price[i]!=0 && price[i]!=EMPTY_VALUE) break;
      //--- precalculation of OBV values:
      if(m_period>0)
        {
         m_start=i+m_period;
         Update(0.0,1);
         while(++i<=m_start && !IsStopped())
           {
            DOBV(price[i],price[i-1],volume[i]);
            m_dOBV.Add(m_dobv); 
            Update(At(1)+m_dobv,1);
           }
         m_dOBV.Add(m_dobv); 
        }
      else
        {
         m_start=i;
         Update(volume[i],1);
        }
      //--- index of the element from which start calculations:
      m_start=m_start+1;
     } 
//--- number of bars was changed:
   else m_start=prev_calculated-1;      
//--- calculate m_dobv:
   DOBV(price[m_start],price[m_start-1],volume[m_start]);
//--- calculate OBV
   Last(At(1)+m_dobv);
   if(m_period>0)
     {
      m_dOBV.Last(m_dobv);
      Last(Last()-m_dOBV[m_period]);
      //--- main loop:     
      for(int i=m_start+1;i<rates_total && !IsStopped();i++)
        {
         DOBV(price[i],price[i-1],volume[i]);
         m_dOBV.Add(m_dobv); 
         Add(Last()+m_dobv-m_dOBV.At(m_period));
        }
     }
   else
     {
      //--- main loop:     
      for(int i=m_start+1;i<rates_total && !IsStopped();i++)
        {
         DOBV(price[i],price[i-1],volume[i]);
         Add(Last()+m_dobv); 
        }
     }
//--- restore as_series flags:
   if(as_series_price) ArraySetAsSeries(price,true);
   if(as_series_vol) ArraySetAsSeries(volume,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double COBVOnRingBuffer:: MainOnValue(const int    rates_total,
                                      const int    prev_calculated, 
                                      const int    begin,
                                      const double price,
                                      const long   volume, 
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
      m_prev_price=m_cur_price=price;
      if(m_period>0)
        {
         Last(0.0);
         return(0.0);
        }
      else
        {
         Update(volume,1);
         Update(volume,0);
         return((double)volume);
        }
     }
//---
   if(prev_calculated-1!=m_index) m_prev_price=m_cur_price;
   m_cur_price=price;
//--- calculate m_dobv:
   DOBV(price,m_prev_price,volume);
//--- init:
   if(m_period>0)
     {
      if(m_index<=m_begin+m_period)
        {
         m_dOBV.Add(m_dobv);
         Last(Last()+m_dobv);
         if(m_index==m_begin+m_period) Update(Last(),1);
         return(0.0);
        }
     }
//--- main calculation:
   if(prev_calculated-1==m_index) 
     {
      m_dOBV.Last(m_dobv); 
      Last(At(1)+m_dobv);
     }
   else
     {
      m_dOBV.Add(m_dobv);
      Add(Last()+m_dobv);
     }  
   if(m_period>0) Last(Last()-m_dOBV[m_period]);   
//--- result:
   return(Last());          
  }       