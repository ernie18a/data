//+------------------------------------------------------------------+
//|                                              positionencoder.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include "buffer.mqh"
//+------------------------------------------------------------------+
//| Class CPositionEncoder                                           |
//| Purpose: Positional encoding class                               |
//+------------------------------------------------------------------+
class CPositionEncoder  : public CBufferType
  {
protected:
   ulong             m_iCount;
   ulong             m_iDimension;
public:
                     CPositionEncoder(void) {};
                    ~CPositionEncoder(void) {};
   //---
   virtual bool      InitEncoder(ulong count, ulong dimension);  // Initialization method
   virtual bool      AddEncoder(CBufferType *&buffer);        // Method for adding positional copying to input data
   //--- File handling method
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
  };
//+------------------------------------------------------------------+
//| Initialization method                                            |
//+------------------------------------------------------------------+
bool CPositionEncoder::InitEncoder(ulong count, ulong dimension)
  {
//--- Save constants
   m_iCount     = count;
   m_iDimension = dimension;
//--- Prepare buffer
   if(!m_mMatrix.Resize(count, dimension))
      return false;
//--- Fill buffer with positional encoding labels
   for(int r = 0; r < (int)count; r++)
     {
      for(int c = 0; c < (int)dimension; c++)
        {
         TYPE value = (TYPE)(r / pow(1000, 2 * c / dimension));
         switch(c % 2)
           {
            case 0:
               m_mMatrix[r, c] = (TYPE)MathSin(value);
               break;
            case 1:
               m_mMatrix[r, c] = (TYPE)MathCos(value);
               break;
           }
        }
     }
//--- Create a buffer in the OpenCL context
   if(m_cOpenCL)
      BufferCreate(m_cOpenCL);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for adding positional encoding to input data              |
//+------------------------------------------------------------------+
bool CPositionEncoder::AddEncoder(CBufferType *&buffer)
  {
//--- Control block
   if(!buffer)
      return false;
   if(buffer.m_mMatrix.Rows() != m_mMatrix.Rows() ||
      buffer.m_mMatrix.Cols() != m_mMatrix.Cols())
      if(!InitEncoder(buffer.m_mMatrix.Rows(), buffer.m_mMatrix.Cols()))
         return false;
//--- Add labels to input data buffer
   buffer.m_mMatrix += m_mMatrix;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CPositionEncoder::Save(const int file_handle)
  {
//--- Control block
   if(file_handle == INVALID_HANDLE)
      return false;
//--- Save constants
   if(!FileWriteInteger(file_handle, (int)m_iCount) ||
      !FileWriteInteger(file_handle, (int)m_iDimension))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from saved data                   |
//+------------------------------------------------------------------+
bool CPositionEncoder::Load(const int file_handle)
  {
//--- Control block
   if(file_handle == INVALID_HANDLE)
      return false;
//--- Read constants
   m_iCount = (uint)FileReadInteger(file_handle);
   m_iDimension = (uint)FileReadInteger(file_handle);
//---
   return InitEncoder(m_iCount, m_iDimension);
  }
//+------------------------------------------------------------------+
