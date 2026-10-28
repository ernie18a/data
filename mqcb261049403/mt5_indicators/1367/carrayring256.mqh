//+------------------------------------------------------------------+
//|                                                CArrayRing256.mqh |
//|                               Copyright 2012, Konstantin Gruzdev |
//|                              https://www.mql5.com/ru/users/lizar |
//|                                             Revision 29 Nov 2012 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, Konstantin Gruzdev"
#property link        "https://www.mql5.com/ru/users/lizar"

//+------------------------------------------------------------------+
//| Class CArrayRing256                                              |
//| Appointment: class to work with tne finite ring buffers          |
//|  of data. The oldest buffer element is replaced by the           |
//|  newest element. This class is a simple version                  |
//|  of ring buffer and has the following features:                  |
//|   - predefined (256 elements) fixed buffer size                  |
//|   - the indexing strictly as in timeseries                       |
//+------------------------------------------------------------------+
class CArrayRing256
  {
private:
   double            m_data[];         // ring buffer of data
   int               m_size;           // buffer size
   uchar             m_last_pos;       // last buffer element position

public:
                     CArrayRing256();
                    ~CArrayRing256()               { ArrayFree(m_data);                         }
   //--- buffer initialization method:
   bool              Init(double volue=EMPTY_VALUE);             
   //--- method returns the buffer size:
   int               Size()                        { return m_size-1;                           }
   //--- method of adding a new element to the buffer:
   void              Add(const double element)     { m_data[++m_last_pos]=element;              } 
   //--- method returns the value of element with the specified index:
   double            At(const uchar index) const   { return(m_data[uchar(m_last_pos-index)]);   }
   double operator   [](const uchar index) const   { return(At(index));                         }
   //--- method returns the value of the last element stored in the buffer:
   double            Last() const                  { return(m_data[m_last_pos]);                } 
   //--- method overwrites the value of the last element in the buffer:
   void              Last(const double element)    { m_data[m_last_pos]=element;                }  
   //--- method overwrites the value of element with the specified index:
   void              Update(const double element,const uchar index=0);  
  };
//+------------------------------------------------------------------+
//| Constructor.                                                     |
//+------------------------------------------------------------------+
CArrayRing256::CArrayRing256()
  {
   m_last_pos=0;                                                        // last element position
   m_size=ArraySize(m_data);                                            // get size of the ring buffer
  }
//+------------------------------------------------------------------+
//| Buffer initialization method.                                    |
//+------------------------------------------------------------------+
bool CArrayRing256::Init(double volue=EMPTY_VALUE)
  {
   m_last_pos=0;                                                        // last element position
   bool result=(m_size=ArrayResize(m_data,UCHAR_MAX+1))==UCHAR_MAX+1;   // create a buffer with the desired size
   ArrayFill(m_data,0,m_size,volue);                                    // fill the buffer with specified value
   return(result);                  
  }  
//+------------------------------------------------------------------+
//| Overwrites the value of element with the specified index.        |
//+------------------------------------------------------------------+
void CArrayRing256::Update(const double element,const uchar index=0)
  {
   m_data[uchar(m_last_pos-index)]=element;
  }