//+------------------------------------------------------------------+
//|                                            CADXWOnRingBuffer.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 07 Dec 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//--- Class to calculate the MA using the ring buffer:
#include <IncOnRingBuffer\CMAOnRingBuffer.mqh>
//+------------------------------------------------------------------+
//| Class CADXWOnRingBuffer                                          |
//| Appointment: class is designed for the calculation of the        |
//|              technical indicator Average Directional Movement    |
//|              Index Wilder (Average Directional Movement Index    |
//|              Wilder, ADX Wilder) using the class for working with|
//|              the ring buffer.                                    |
//| Link: http://www.mql5.com/ru/code/1356                           |
//+------------------------------------------------------------------+
class CADXWOnRingBuffer
  {
public:
   CArrayRing        pdi;              // positive directional index 
   CArrayRing        ndi;              // negative directional index
private:
   CMAOnRingBuffer   m_adxw;           // average directional movement index Wilder
   CMAOnRingBuffer   m_pds;
   CMAOnRingBuffer   m_nds;
   CMAOnRingBuffer   m_atr;
   string            m_name;           // indicator name  
   bool              m_as_series;      // true, if the indexing as in time series
   int               m_bars_required;  // number of elements required to calculate
   int               m_begin;          // index of the first significant element
   int               m_start;          // index of element to start the calculation
   int               m_index;          // current element index
   
   double            m_high;           // maximal value
   double            m_low;            // minimal value
   double            m_close;          // closing price
   double            m_phigh;          // maximum value of the previous bar
   double            m_plow;           // minimum value of the previous bar
   double            m_pclose;         // closing price of the previous bar
   
   double            m_PD;
   double            m_ND;
public:
                     CADXWOnRingBuffer() {} 
                    ~CADXWOnRingBuffer() {}
   //--- initialization method:
   bool              Init(int             ma_period=14,
                          ENUM_MA_METHOD  ma_method=MODE_SMMA, 
                          int             size_buffer=256, 
                          bool            as_series=false);             
   //--- basic methods:          
   int               MainOnArray(const int      rates_total, 
                                 const int      prev_calculated,
                                 const double  &high[],
                                 const double  &low[],
                                 const double  &close[]);
   double            MainOnValue(const int      rates_total,
                                 const int      prev_calculated, 
                                 const int      begin, 
                                 const double   high, 
                                 const double   low, 
                                 const double   close, 
                                 const int      index);
   //--- methods to get access to private data:
   int               BarsRequired()                { return(m_bars_required);             }
   string            NameADXW()                    { return("ADX Wilder"+m_name);         }
   string            NameNDI()                     { return("-DI"+m_name);                }
   string            NamePDI()                     { return("+DI"+m_name);                }
   string            MAMethod()                    { return(m_adxw.MAMethod());           }
   int               MAPeriod()                    { return(m_adxw.MAPeriod());           }
   int               Size()                        { return(m_adxw.Size());               }
   //--- returns the value of element with the specified index:
   double operator   [](const int index) const     { return(m_adxw.At(index));            }
private:
   //--- indicator calculation method:
   void              ADXW(const int rates_total, const int prev_calculated);
  };

//+------------------------------------------------------------------+
//|  Initialization method                                           |
//+------------------------------------------------------------------+
bool CADXWOnRingBuffer :: Init(int ma_period=14,ENUM_MA_METHOD ma_method=MODE_SMMA, int size_buffer=256, bool as_series=false)
  {
//--- initialize the CMAOnRingBuffer class instances:
   if(!pdi.Init(size_buffer))   return false;
   if(!ndi.Init(size_buffer))   return false;
   if(!m_atr.Init(ma_period,ma_method,size_buffer)) return false;
   if(!m_pds.Init(ma_period,ma_method,size_buffer)) return false;
   if(!m_nds.Init(ma_period,ma_method,size_buffer)) return false;
   if(!m_adxw.Init(ma_period,ma_method,size_buffer)) return false;
//---
   m_name="("+IntegerToString(ma_period)+","+MAMethod()+")";
//---
   m_as_series=as_series;
   m_bars_required=m_adxw.BarsRequired()+1;
   return true;   
  }

//+------------------------------------------------------------------+
//| Indicator on array                                               |
//+------------------------------------------------------------------+
int CADXWOnRingBuffer :: MainOnArray(const int      rates_total, 
                                     const int      prev_calculated,
                                     const double  &high[],
                                     const double  &low[],
                                     const double  &close[])
  {
//--- save as_series flags:
   bool as_series_high  = ArrayGetAsSeries(high);
   bool as_series_low   = ArrayGetAsSeries(low);
   bool as_series_close = ArrayGetAsSeries(close);
   if(as_series_high)  ArraySetAsSeries(high, false);
   if(as_series_low)   ArraySetAsSeries(low,  false);
   if(as_series_close) ArraySetAsSeries(close,false);
//--- first calculation:
   if(prev_calculated==0)
     {
      for(int i=0;i<rates_total;i++)
        {
         if(high[i]!=0  && high[i] != EMPTY_VALUE && 
            low[i]!=0   && low[i]  != EMPTY_VALUE && 
            close[i]!=0 && close[i]!= EMPTY_VALUE)
           {
            m_start=MathMax(i+1,rates_total-Size()-m_bars_required);
            break;
           }
        }        
      m_begin=m_start;
     }
//--- number of bars was changed:
   else m_start=prev_calculated-1;   
//--- main loop:
   for(m_index=m_start;m_index<rates_total;m_index++)
     {
   //--- fill main positive and main negative buffers:
      m_phigh  = high [m_index-1];
      m_plow   = low  [m_index-1];
      m_pclose = close[m_index-1];   
      m_high   = high [m_index];
      m_low    = low  [m_index]; 
   //--- calculation of the average directional movement index:
      ADXW(rates_total,prev_calculated);
     }
//--- restore as_series flags
   if(as_series_high)  ArraySetAsSeries(high, true);
   if(as_series_low)   ArraySetAsSeries(low,  true);
   if(as_series_close) ArraySetAsSeries(close,true);
//--- return value of prev_calculated for next call:
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Indicator on value                                               |
//+------------------------------------------------------------------+
double CADXWOnRingBuffer:: MainOnValue(const int    rates_total,
                                       const int    prev_calculated, 
                                       const int    begin, 
                                       const double high, 
                                       const double low, 
                                       const double close, 
                                       const int    index)
  {
//--- check as_series flags:
   if(m_as_series) m_index=rates_total-1-index;
   else m_index=index;
//--- check begin:
   if(m_index<begin) return(EMPTY_VALUE);
//--- initial calculation:
   if(m_index==begin)
     {
      m_high=high;
      m_low=low;
      m_close=close;
      m_begin=begin+1;
      return(EMPTY_VALUE);
     }     
//--- remember the prices:
   if(prev_calculated-1!=m_index) 
     {
      m_phigh  = m_high;
      m_plow   = m_low;
      m_pclose = m_close;   
     }
   m_high  = high;
   m_low   = low;
   m_close = close;  
//--- calculation of the average directional movement index:
   ADXW(rates_total,prev_calculated);
//--- result:
   return(m_adxw.Last());          
  }       
  
//+------------------------------------------------------------------+
//| Average directional movement index                               |
//+------------------------------------------------------------------+
void CADXWOnRingBuffer:: ADXW(const int rates_total, const int prev_calculated)
  {
//--- fill main positive and main negative buffers
   double dTmpP=m_high-m_phigh;
   double dTmpN=m_plow-m_low;
   if(dTmpP<0.0)   dTmpP=0.0;
   if(dTmpN<0.0)   dTmpN=0.0;
   if(dTmpP>dTmpN) dTmpN=0.0;
   else
     {
      if(dTmpP<dTmpN) dTmpP=0.0;
      else
        {
         dTmpP=0.0;
         dTmpN=0.0;
        }
     }
//--- define TR
   double tr=MathMax(MathMax(MathAbs(m_high-m_low),MathAbs(m_high-m_pclose)),MathAbs(m_low-m_pclose)); 
//--- fill smoothed positive and negative buffers and TR buffer
   tr    = m_atr.MainOnValue(rates_total,prev_calculated,m_begin,tr,   m_index);
   dTmpP = m_pds.MainOnValue(rates_total,prev_calculated,m_begin,dTmpP,m_index);
   dTmpN = m_nds.MainOnValue(rates_total,prev_calculated,m_begin,dTmpN,m_index);     
   if(tr==EMPTY_VALUE)    tr=0.0;
   if(dTmpP==EMPTY_VALUE) dTmpP=0.0;
   if(dTmpN==EMPTY_VALUE) dTmpN=0.0;
//--- calculate PDI and NDI buffers
   if(m_index==prev_calculated-1)
     {
      if(tr!=0.0 || tr!=EMPTY_VALUE)
        {
         pdi.Last(100.0*dTmpP/tr);
         ndi.Last(m_ND=100.0*dTmpN/tr);
        }
      else
        {
         pdi.Last(0.0);
         ndi.Last(0.0);
        }      
     }
   else
     {
      if(tr!=0.0)
        {
         pdi.Add(100.0*dTmpP/tr);
         ndi.Add(m_ND=100.0*dTmpN/tr);
        }
      else
        {
         pdi.Add(0.0);
         ndi.Add(0.0);
        }      
     }
//--- ADXWTtmp
   double dTmp=pdi.Last()+ndi.Last();
   if(dTmp!=0.0)
      dTmp=100.0*MathAbs((pdi.Last()-ndi.Last())/dTmp);
   else
      dTmp=0.0;
//--- fill smoothed ADXW buffer
   m_adxw.MainOnValue(rates_total,prev_calculated,m_begin,dTmp,m_index);         
  }         