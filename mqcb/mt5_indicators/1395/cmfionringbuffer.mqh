//+------------------------------------------------------------------+
//|                                             CMFIOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 18 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the MA using the ring buffer:
#include <IncOnRingBuffer\CMAOnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class CMFIOnRingBuffer                                           |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Money Flow Index (Money Flow    |
//|              Index, MFI) using the class for working with        |
//|              the ring buffer.                                    |
//| Link: http://www.mql5.com/ru/code/1395                           |
//+------------------------------------------------------------------+
class CMFIOnRingBuffer : public CArrayRing
  {
private:
   CMAOnRingBuffer      m_pma;            // average value of positive price changes;
   CMAOnRingBuffer      m_nma;            // average value of negative price changes;
   string               m_name;           // indicator name  
   double               m_prev_price;
   double               m_cur_price;
   ENUM_APPLIED_PRICE   m_applied_price;  // the selected price ID for the calculation
   ENUM_APPLIED_VOLUME  m_applied_volume; // the selected volume ID for the calculation
   bool                 m_as_series;      // true, if the indexing as in time series
   int                  m_bars_required;  // number of elements required to calculate
   int                  m_begin;          // index of the first significant element
   int                  m_start;          // index of element to start the calculation
   int                  m_index;          // current element index

public:
                        CMFIOnRingBuffer() {} 
                       ~CMFIOnRingBuffer() {}
   //--- initialization method:
   bool                 Init(int                   period         = 14,
                             ENUM_MA_METHOD        method         = MODE_SMA,
                             ENUM_APPLIED_PRICE    applied_price  = PRICE_TYPICAL,
                             ENUM_APPLIED_VOLUME   applied_volume = VOLUME_TICK,
                             int                   size_buffer    = 256, 
                             bool                  as_series      = false);
   //--- basic methods:          
   int                  MainOnArray(const int      rates_total, 
                                    const int      prev_calculated,
                                    const double&  open[],
                                    const double&  high[],
                                    const double&  low[],
                                    const double&  close[],
                                    const long&    tick_volume[],
                                    const long&    volume[]);
   double               MainOnValue(const int      rates_total,
                                    const int      prev_calculated, 
                                    const int      begin,
                                    const double   open,
                                    const double   high,
                                    const double   low,
                                    const double   close,
                                    const long     tick_volume,
                                    const long     volume, 
                                    const int      index);
   //--- methods to get access to private data:
   int                  BarsRequired()                { return(m_bars_required);    }
   string               Name()                        { return(m_name);             }
   int                  Period()                      { return(m_pma.MAPeriod());   }
   string               Method()                      { return(m_pma.MAMethod());   }
   ENUM_APPLIED_PRICE   Price()                       { return(m_applied_price);    }
   ENUM_APPLIED_VOLUME  Volume()                      { return(m_applied_volume);   }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(At(index));          }
private:
   double               Price(const double open,
                              const double high,
                              const double low,
                              const double close);
   double               Volume(const long tick_volume,
                               const long volume);
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CMFIOnRingBuffer :: Init(int                  period         = 14,
                              ENUM_MA_METHOD       method         = MODE_SMA,
                              ENUM_APPLIED_PRICE   applied_price  = PRICE_TYPICAL,
                              ENUM_APPLIED_VOLUME  applied_volume = VOLUME_TICK,
                              int                  size_buffer    = 256, 
                              bool                 as_series      = false)
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
   m_name="MFI("+IntegerToString(Period())+","+Method()+")"; 
//---
   m_applied_price=applied_price;
   m_applied_volume=applied_volume;
   m_as_series=as_series;
   m_bars_required=m_pma.BarsRequired()+1;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CMFIOnRingBuffer :: MainOnArray(const int      rates_total, 
                                    const int      prev_calculated,
                                    const double&  open[],
                                    const double&  high[],
                                    const double&  low[],
                                    const double&  close[],
                                    const long&    tick_volume[],
                                    const long&    volume[])
                  
  {
//--- save as_series flags:
   bool as_series_open  = ArrayGetAsSeries(open);
   bool as_series_high  = ArrayGetAsSeries(high);
   bool as_series_low   = ArrayGetAsSeries(low);
   bool as_series_close = ArrayGetAsSeries(close);
   bool as_series_tvol  = ArrayGetAsSeries(tick_volume);
   bool as_series_rvol  = ArrayGetAsSeries(volume);
   if(as_series_open)  ArraySetAsSeries(open,       false);
   if(as_series_high)  ArraySetAsSeries(high,       false);
   if(as_series_low)   ArraySetAsSeries(low,        false);
   if(as_series_close) ArraySetAsSeries(close,      false);
   if(as_series_tvol)  ArraySetAsSeries(tick_volume,false);
   if(as_series_rvol)  ArraySetAsSeries(volume,     false);
//--- first calculation:
   if(prev_calculated==0) 
     { 
      //--- looking the start of significant data:
      int i=-1;
      while(++i<rates_total && !IsStopped())
         if(open[i]!=0  && open[i]!=EMPTY_VALUE  &&
            high[i]!=0  && high[i]!=EMPTY_VALUE  &&
            low[i]!=0   && low[i]!=EMPTY_VALUE   &&
            close[i]!=0 && close[i]!=EMPTY_VALUE
           ) break;
      //--- index of the element from which start calculations:
      m_start=MathMax(i,rates_total-Size()-m_bars_required);
      m_prev_price=m_cur_price=Price(open[m_start],high[m_start],low[m_start],close[m_start]);
      m_start=m_begin=m_start+1;
     } 
//--- number of bars was changed:
   else m_start=prev_calculated-1;      
   //---
   if(prev_calculated-1!=m_start) m_prev_price=m_cur_price;
   m_cur_price=Price(open[m_start],high[m_start],low[m_start],close[m_start]);   
   double positive=m_cur_price>m_prev_price?m_cur_price*Volume(tick_volume[m_start],volume[m_start]):0; 
   double negative=m_cur_price<m_prev_price?m_cur_price*Volume(tick_volume[m_start],volume[m_start]):0; 
   double pma=m_pma.MainOnValue(rates_total,prev_calculated,m_begin,positive,m_start);
   double nma=m_nma.MainOnValue(rates_total,prev_calculated,m_begin,negative,m_start);
   //--- calculate MFI
   if(pma==EMPTY_VALUE || nma==EMPTY_VALUE) Last(EMPTY_VALUE);
   else if(nma!=0) Last(100.0-100.0/(1+pma/nma));       
        else if(pma!=0.0) Last(100.0);
             else Last(50.0);          
//--- main loop:     
   for(int i=m_start+1;i<rates_total && !IsStopped();i++) 
     { 
      m_prev_price=m_cur_price;
      m_cur_price=Price(open[i],high[i],low[i],close[i]);   
      positive=m_cur_price>m_prev_price?m_cur_price*Volume(tick_volume[i],volume[i]):0; 
      negative=m_cur_price<m_prev_price?m_cur_price*Volume(tick_volume[i],volume[i]):0; 
      pma=m_pma.MainOnValue(rates_total,prev_calculated,m_begin,positive,i);
      nma=m_nma.MainOnValue(rates_total,prev_calculated,m_begin,negative,i);
      //--- calculate MFI
      if(pma==EMPTY_VALUE || nma==EMPTY_VALUE) Add(EMPTY_VALUE);
      else if(nma!=0) Add(100.0-100.0/(1+pma/nma));       
           else if(pma!=0.0) Add(100.0);
                else Add(50.0);
     }
//--- restore as_series flags:
   if(as_series_open)  ArraySetAsSeries(open,       true);
   if(as_series_high)  ArraySetAsSeries(high,       true);
   if(as_series_low)   ArraySetAsSeries(low,        true);
   if(as_series_close) ArraySetAsSeries(close,      true);
   if(as_series_tvol)  ArraySetAsSeries(tick_volume,true);
   if(as_series_rvol)  ArraySetAsSeries(volume,     true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CMFIOnRingBuffer:: MainOnValue(const int    rates_total,
                                      const int    prev_calculated, 
                                      const int    begin,
                                      const double open,
                                      const double high,
                                      const double low,
                                      const double close,
                                      const long   tick_volume,
                                      const long   volume, 
                                      const int    index)
  {
//--- check as_series flags:
   if(m_as_series) m_index=rates_total-1-index;
   else m_index=index;
//--- check begin:
   if(m_index<begin) return(EMPTY_VALUE);
   if(m_index==begin)
     {
      m_prev_price=m_cur_price=Price(open,high,low,close);
      return(EMPTY_VALUE);
     }
//--- main calculation:
   if(prev_calculated-1!=m_index) m_prev_price=m_cur_price;
   m_cur_price=Price(open,high,low,close);
   double positive=m_cur_price>m_prev_price?m_cur_price*Volume(tick_volume,volume):0; 
   double negative=m_cur_price<m_prev_price?m_cur_price*Volume(tick_volume,volume):0; 
   double pma=m_pma.MainOnValue(rates_total,prev_calculated,begin+1,positive,m_index);
   double nma=m_nma.MainOnValue(rates_total,prev_calculated,begin+1,negative,m_index);
   //--- calculate MFI
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
  
//+------------------------------------------------------------------+
//| Applied price                                                    |
//+------------------------------------------------------------------+
double CMFIOnRingBuffer :: Price(const double open,
                                 const double high,
                                 const double low,
                                 const double close)
  {
   switch(m_applied_price)
     {
      case  PRICE_OPEN:       return(open);
      case  PRICE_CLOSE:      return(close);
      case  PRICE_HIGH:       return(high);
      case  PRICE_LOW:        return(low);
      case  PRICE_MEDIAN:     return((high+low)/2.0);
      case  PRICE_TYPICAL:    return((high+low+close)/3.0);
      case  PRICE_WEIGHTED:   return((high+low+close+close)/4.0);
     }
   return(EMPTY_VALUE);
  }    
  
//+------------------------------------------------------------------+
//| Applied volume                                                   |
//+------------------------------------------------------------------+
double CMFIOnRingBuffer :: Volume(const long tick_volume,
                                  const long volume)
  {
   switch(m_applied_volume)
     {
      case  VOLUME_TICK: return((double)tick_volume);
      case  VOLUME_REAL: return((double)volume);
     }
   return(EMPTY_VALUE);
  }      