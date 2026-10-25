//+------------------------------------------------------------------+
//|                                                  ArrayLayers.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Class constants                                                  |
//+------------------------------------------------------------------+
#define  ArrayLayers    CArrayLayers
//+------------------------------------------------------------------+
//| Connect neural layer classes                                     |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
#include "neuronbase.mqh"
#include "neuronconv.mqh"
#include "neuronlstm.mqh"
#include "neuronattention.mqh"
#include "neuronmhattention.mqh"
#include "neurondropout.mqh"
#include "neuronbatchnorm.mqh"
//+------------------------------------------------------------------+
//| Class CArrayLayers                                               |
//| Purpose: Class of dynamic array for collection of neural layers  |
//+------------------------------------------------------------------|
class CArrayLayers   :  public CArrayObj
  {
protected:
   CMyOpenCL*        m_cOpenCL;
   int               m_iFileHandle;
public:
                     CArrayLayers(void): m_cOpenCL(NULL), m_iFileHandle(INVALID_HANDLE) { }
                    ~CArrayLayers(void) { };
   //---
   virtual bool      SetOpencl(CMyOpenCL *opencl);
   virtual bool      Load(const int file_handle) override;
   //--- method of creating an element of array
   virtual bool      CreateElement(const int index) override;
   virtual bool      CreateElement(const int index, CLayerDescription *description);
   //--- method of identifying the object
   virtual int       Type(void) override const { return(defArrayLayers); }
  };
//+------------------------------------------------------------------+
//|  GPT model uses this class to organize internal                  |
//|  neural layers. Therefore we connect this layer after declaring  |
//|  the class                                                       |
//+------------------------------------------------------------------+
#include "neurongpt.mqh"
//+------------------------------------------------------------------+
//| Method for creating a dynamic array element                      |
//+------------------------------------------------------------------+
bool CArrayLayers::CreateElement(const int index)
  {
//--- source data checking bock
   if(index < 0 || m_iFileHandle==INVALID_HANDLE)
      return false;
//--- reserving an array element for a new object
   if(!Reserve(index + 1))
      return false;
//--- read the type of the desired object from the file and create the corresponding neural layer
   CNeuronBase *temp = NULL;
   int type = FileReadInteger(m_iFileHandle);
   switch(type)
     {
      case defNeuronBase:
         temp = new CNeuronBase();
         break;
      case defNeuronConv:
         temp = new CNeuronConv();
         break;
      case defNeuronProof:
         temp = new CNeuronProof();
         break;
      case defNeuronLSTM:
         temp = new CNeuronLSTM();
         break;
      case defNeuronAttention:
         temp = new CNeuronAttention();
         break;
      case defNeuronMHAttention:
         temp = new CNeuronMHAttention();
         break;
      case defNeuronGPT:
         temp = new CNeuronGPT();
         break;
      case defNeuronDropout:
         temp = new CNeuronDropout();
         break;
      case defNeuronBatchNorm:
         temp = new CNeuronBatchNorm();
         break;
      default:
         return false;
     }
//--- control new object creation
   if(!temp)
      return false;
//--- add pointer to the created object to array
   if(m_data[index])
      delete m_data[index];

   temp.SetOpenCL(m_cOpenCL);
   m_data[index] = temp;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for creating a dynamic array element                      |
//+------------------------------------------------------------------+
bool CArrayLayers::CreateElement(const int index, CLayerDescription *desc)
  {
//--- source data checking bock
   if(index < 0 || !desc)
      return false;
//--- reserving an array element for a new object
   if(!Reserve(index + 1))
      return false;
//--- create the corresponding neural layer
   CNeuronBase *temp = NULL;
   switch(desc.type)
     {
      case defNeuronBase:
         temp = new CNeuronBase();
         break;
      case defNeuronConv:
         temp = new CNeuronConv();
         break;
      case defNeuronProof:
         temp = new CNeuronProof();
         break;
      case defNeuronLSTM:
         temp = new CNeuronLSTM();
         break;
      case defNeuronAttention:
         temp = new CNeuronAttention();
         break;
      case defNeuronMHAttention:
         temp = new CNeuronMHAttention();
         break;
      case defNeuronGPT:
         temp = new CNeuronGPT();
         break;
      case defNeuronDropout:
         temp = new CNeuronDropout();
         break;
      case defNeuronBatchNorm:
         temp = new CNeuronBatchNorm();
         break;
      default:
         return false;
     }
//--- control new object creation
   if(!temp)
      return false;
//--- add pointer to the created object to array
   if(!temp.Init(desc))
      return false;

   if(m_data[index])
      delete m_data[index];

   temp.SetOpenCL(m_cOpenCL);
   m_data[index] = temp;
   m_data_total  = fmax(m_data_total, index + 1);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method to pass pointer to the OpenCL context                     |
//+------------------------------------------------------------------+
bool CArrayLayers::SetOpencl(CMyOpenCL *opencl)
  {
//--- source data checking bock
   if(m_cOpenCL)
      delete m_cOpenCL;

   m_cOpenCL = opencl;
//--- pass pointer to all elements of the array
   for(int i = 0; i < m_data_total; i++)
     {
      if(!m_data[i])
         return false;
      if(!((CNeuronBase *)m_data[i]).SetOpenCL(m_cOpenCL))
         return false;
     }
//--- 
   return(!!m_cOpenCL);
  }
//+------------------------------------------------------------------+
//| Method for reading a dynamic array from a file                   |
//+------------------------------------------------------------------+
bool CArrayLayers::Load(const int file_handle)
  {
   m_iFileHandle = file_handle;
   return CArrayObj::Load(file_handle);
  }
//+------------------------------------------------------------------+
