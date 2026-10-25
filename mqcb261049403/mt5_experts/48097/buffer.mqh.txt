//+------------------------------------------------------------------+
//|                                                 BufferDouble.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include <Arrays\Array.mqh>
#include "opencl.mqh"
//+------------------------------------------------------------------+
//| Class CBufferType                                                |
//| Purpose: Dynamic data buffer class                               |
//+------------------------------------------------------------------+
class CBufferType: public CObject
  {
protected:
   CMyOpenCL*        m_cOpenCL;     // OpenCL context object
   int               m_myIndex;     // data buffer index in context
public:
                     CBufferType(void);
                    ~CBufferType(void);
   //---
   MATRIX            m_mMatrix;
   //--- method for initializing the buffer with initial values
   virtual bool      BufferInit(const ulong rows, const ulong columns, const TYPE value = 0);
   //--- create a new buffer in the OpenCL context
   virtual bool      BufferCreate(CMyOpenCL *opencl);
   //--- delete a buffer in the OpenCL context
   virtual bool      BufferFree(void);
   //--- read data of the buffer from the OpenCL context
   virtual bool      BufferRead(void);
   //--- write buffer data to the OpenCL context
   virtual bool      BufferWrite(void);
   //--- get buffer index
   virtual int       GetIndex(void);
   //--- change buffer index
   virtual bool      SetIndex(int index)
     {
      if(!m_cOpenCL.BufferFree(m_myIndex))
         return false;
      m_myIndex = index;
      return true;
     }
   //--- copy buffer data to the array
   virtual int       GetData(TYPE &values[], bool load = true);
   virtual int       GetData(MATRIX &values, bool load = true);
   virtual int       GetData(CBufferType *values, bool load = true);
   //--- calculate the average value of the data buffer
   virtual TYPE    MathMean(void);
   //--- vector operations
   virtual bool      SumArray(CBufferType *src);
   virtual int       Scaling(TYPE value);
   virtual bool      Split(CBufferType* target1, CBufferType* target2, const int position);
   virtual bool      Concatenate(CBufferType* target1, CBufferType* target2, const ulong positions1, const ulong positions2);
   //--- file handling methods
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //--- class identifier
   virtual int       Type(void)               const { return defBuffer;             }

   ulong             Rows(void)               const { return m_mMatrix.Rows();      }
   ulong             Cols(void)               const { return m_mMatrix.Cols();      }
   ulong             Total(void)              const { return (m_mMatrix.Rows() * m_mMatrix.Cols()); }
   TYPE              At(uint index)           const { return m_mMatrix.Flat(index); }
   TYPE              operator[](ulong index)  const { return m_mMatrix.Flat(index); }
   VECTOR            Row(ulong row)                 { return m_mMatrix.Row(row);    }
   VECTOR            Col(ulong col)                 { return m_mMatrix.Col(col);    }  
   bool              Row(VECTOR& vec,  ulong row)   { return m_mMatrix.Row(vec, row);  }
   bool              Col(VECTOR& vec,  ulong col)   { return m_mMatrix.Col(vec, col);  }
   bool              Activation(MATRIX& mat_out, ENUM_ACTIVATION_FUNCTION func) { return m_mMatrix.Activation(mat_out, func);}
   bool              Derivative(MATRIX& mat_out, ENUM_ACTIVATION_FUNCTION func) { return m_mMatrix.Derivative(mat_out, func);}
   bool              Reshape(ulong rows, ulong cols){ return m_mMatrix.Reshape(rows, cols); }

   bool              Update(uint index, TYPE value)
     {
      if(index >= Total())
         return false;
      m_mMatrix.Flat(index, value);
      return true;
     }

   bool              Update(uint row, uint col, TYPE value)
     {
      if(row >= Rows() || col >= Cols())
         return false;
      m_mMatrix[row, col] = value;
      return true;
     }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CBufferType::CBufferType(void)  : m_myIndex(-1)
  {
   m_cOpenCL = NULL;
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CBufferType::~CBufferType(void)
  {
   if(m_cOpenCL && m_myIndex >= 0)
     {
      if(m_cOpenCL.BufferFree(m_myIndex))
        {
         m_myIndex = -1;
         m_cOpenCL = NULL;
        }
     }
  }
//+------------------------------------------------------------------+
//| Creating a new buffer in the OpenCL context                      |
//+------------------------------------------------------------------+
bool CBufferType::BufferCreate(CMyOpenCL *opencl)
  {
//--- source data checking bock
   if(!opencl)
     {
      BufferFree();
      return false;
     }
//--- if the received pointer matches the previously saved one, copy the buffer contents to the context memory
   if(opencl == m_cOpenCL && m_myIndex >= 0)
      return BufferWrite();

//--- check the presence of a previously saved pointer to OpenCL context
//--- if present, delete the buffer from the unused context
   if(m_cOpenCL && m_myIndex >= 0)
     {
      if(m_cOpenCL.BufferFree(m_myIndex))
        {
         m_myIndex = -1;
         m_cOpenCL = NULL;
        }
      else
         return false;
     }
//--- create a new buffer in the specified OpenCL context
   if((m_myIndex = opencl.AddBufferFromArray(m_mMatrix, 0, CL_MEM_READ_WRITE)) < 0)
      return false;
   m_cOpenCL = opencl;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for removing the buffer from the OpenCL context           |
//+------------------------------------------------------------------+
bool CBufferType::BufferFree(void)
  {
//--- check the presence of a previously saved pointer to OpenCL context
//--- if present, delete the buffer from the unused context
   if(m_cOpenCL && m_myIndex >= 0)
      if(m_cOpenCL.BufferFree(m_myIndex))
        {
         m_myIndex = -1;
         m_cOpenCL = NULL;
         return true;
        }
   if(m_myIndex >= 0)
      m_myIndex = -1;
//---
   return false;
  }
//+------------------------------------------------------------------+
//| Method for reading data from the buffer in the OpenCL context    |
//+------------------------------------------------------------------+
bool CBufferType::BufferRead(void)
  {
   if(!m_cOpenCL || m_myIndex < 0)
      return false;
//---
   return m_cOpenCL.BufferRead(m_myIndex, m_mMatrix, 0);
  }
//+------------------------------------------------------------------+
//| Method for writing data to the buffer in the OpenCL context      |
//+------------------------------------------------------------------+
bool CBufferType::BufferWrite(void)
  {
   if(!m_cOpenCL || m_myIndex < 0)
      return false;
//---
   return m_cOpenCL.BufferWrite(m_myIndex, m_mMatrix, 0);
  }
//+------------------------------------------------------------------+
//| Method for initializing the buffer with initial values           |
//+------------------------------------------------------------------+
bool CBufferType::BufferInit(ulong rows, ulong columns, TYPE value)
  {
   if(rows <= 0 || columns <= 0)
      return false;
//---
   m_mMatrix = MATRIX::Full(rows, columns, value);
   if(m_cOpenCL)
     {
      CMyOpenCL *opencl=m_cOpenCL;
      BufferFree();
      return BufferCreate(opencl);
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for getting buffer values                                 |
//+------------------------------------------------------------------+
int CBufferType::GetData(TYPE &values[], bool load = true)
  {
   if(load && !BufferRead())
      return -1;
   if(ArraySize(values) != Total() &&
      ArrayResize(values, (uint)Total()) <= 0)
      return false;
//---
   for(uint i = 0; i < Total(); i++)
      values[i] = m_mMatrix.Flat(i);
   return (int)Total();
  }
//+------------------------------------------------------------------+
//| Method for getting buffer values                                 |
//+------------------------------------------------------------------+
int CBufferType::GetData(MATRIX &values, bool load = true)
  {
   if(load && !BufferRead())
      return -1;
//---
   values = m_mMatrix;
   return (int)Total();
  }
//+------------------------------------------------------------------+
//| Method for getting buffer values                                 |
//+------------------------------------------------------------------+
int CBufferType::GetData(CBufferType *values, bool load = true)
  {
   if(!values)
      return -1;
   if(load && !BufferRead())
      return -1;
   values.m_mMatrix.Copy(m_mMatrix);
   return (int)values.Total();
  }
//+------------------------------------------------------------------+
//| Method for summing up elements of two data buffers               |
//+------------------------------------------------------------------+
bool CBufferType::SumArray(CBufferType *src)
  {
//--- check source data array
   if(!src || src.Total() != Total())
      return(false);
//---
   if(!m_cOpenCL)
     {
      //--- resizing the matrix
      MATRIX temp = src.m_mMatrix;
      if(!temp.Reshape(Rows(), Cols()))
         return(false);
      //--- adding matrices
      m_mMatrix += temp;
     }
   else
     {
      if(src.GetIndex() < 0 && !BufferCreate(m_cOpenCL))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Sum, def_sum_inputs1, m_myIndex))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Sum, def_sum_inputs2, src.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Sum, def_sum_outputs, m_myIndex))
         return false;
      uint off_set[] = {0};
      uint NDRange[] = {(uint)Total()};
      if(!m_cOpenCL.Execute(def_k_Sum, 1, off_set, NDRange))
         return false;
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Method for computing the average value of the array              |
//+------------------------------------------------------------------+
TYPE CBufferType::MathMean(void)
  {
   return m_mMatrix.Mean();
  }
//+------------------------------------------------------------------+
//| Get the index of the buffer in the OpenCL context                |
//+------------------------------------------------------------------+
int CBufferType::GetIndex(void)
  {
   if(!m_cOpenCL || m_myIndex < 0)
     {
      m_myIndex = -1;
      m_cOpenCL = NULL;
      return m_myIndex;
     }
//---
   if(!m_cOpenCL.CheckBuffer(m_myIndex))
      m_myIndex = BufferCreate(m_cOpenCL);
//---
   return m_myIndex;
  }
//+------------------------------------------------------------------+
//| Data scaling method (multiplying by a constant)                  |
//+------------------------------------------------------------------+
int CBufferType::Scaling(TYPE value)
  {
   if(!m_cOpenCL)
      m_mMatrix *= value;
   else
     {
      if(m_myIndex <= 0)
         return false;
      //--- pass parameters to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_inputs, m_myIndex))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_outputs, m_myIndex))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_a, value))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_b, 0))
         return false;
      //--- place kernel to the execution queue
      int off_set[] = {0};
      int NDRange[] = { (int)Total() };
      if(!m_cOpenCL.Execute(def_k_LineActivation, 1, off_set, NDRange))
         return false;
     }
//---
   return (int)Total();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferType::Save(const int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
   if(m_myIndex >= 0)
      if(!BufferRead())
         return false;
//---
   if(FileWriteInteger(file_handle, Type()) < INT_VALUE)
      return false;
   if(FileWriteLong(file_handle, Rows()) < sizeof(long))
      return false;
   if(FileWriteLong(file_handle, Cols()) < sizeof(long))
      return false;
//---
   for(ulong r = 0; r < Rows(); r++)
      for(ulong c = 0; c < Cols(); c++)
         if(FileWriteDouble(file_handle, m_mMatrix[r, c]) < sizeof(double))
            return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferType::Load(const int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
   if(FileReadInteger(file_handle) != Type())
      return false;
//---
   ulong rows = FileReadLong(file_handle);
   ulong cols = FileReadLong(file_handle);
   if(!m_mMatrix.Init(rows, cols))
      return false;
   for(ulong r = 0; r < rows; r++)
      for(ulong c = 0; c < cols; c++)
         m_mMatrix[r, c] = (TYPE)FileReadDouble(file_handle);
//---
   if(m_myIndex >= 0)
     {
      if(!BufferFree())
         return false;
      if(!BufferCreate(m_cOpenCL))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferType::Split(CBufferType *target1, CBufferType *target2, const int position)
  {
   if(!target1 || !target2)
      return false;
//---
   if(!m_cOpenCL)
     {
      ulong split[] = {position};
      MATRIX m[];
      if(!m_mMatrix.Vsplit(split, m))
         return false;
      if(target1!=GetPointer(this))
         target1.m_mMatrix = m[0];
      target2.m_mMatrix = m[1];
     }
   else
     {
      if((int)target1.Total() < position)
         return false;
      if(target1.GetIndex() < 0 && !target1.BufferCreate(m_cOpenCL))
         return false;
      if(target2.GetIndex() < 0 && !target2.BufferCreate(m_cOpenCL))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Split, def_split_source, m_myIndex))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Split, def_split_target1, target1.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Split, def_split_target2, target2.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_Split, def_split_total_source, (int)Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_Split, def_split_total_target1, position))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_Split, def_split_total_target2, (int)target2.Total()))
         return false;
      //--- place kernel to the execution queue
      int off_set[] = {0};
      int NDRange[] = {(int)Total()};
      ResetLastError();
      if(!m_cOpenCL.Execute(def_k_Split, 1, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBufferType::Concatenate(CBufferType *source1, CBufferType *source2, const ulong positions1, const ulong positions2)
  {
   if(!source1 || source1.Total() < positions1)
      return false;
   if(!source2 || source2.Total() < positions2)
      return false;
//---
   if(!m_cOpenCL)
     {
      m_mMatrix = source1.m_mMatrix;
      if(!m_mMatrix.Resize(m_mMatrix.Rows(), positions1 + positions2))
         return false;
      for(ulong c = 0; c < positions2; c++)
         if(!m_mMatrix.Col(source2.m_mMatrix.Col(c), positions1 + c))
            return false;
     }
   else
     {
      if(source1.Total() < positions1)
         return false;
      if(source2.Total() < positions2)
         return false;
      if(Total() < positions1 + positions2)
         return false;
      if(source1.GetIndex() < 0 && !source1.BufferCreate(m_cOpenCL))
         return false;
      if(source2.GetIndex() < 0 && !source2.BufferCreate(m_cOpenCL))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Concatenate, def_concat_source1, source1.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Concatenate, def_concat_source2, source2.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_Concatenate, def_concat_target, m_myIndex))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_Concatenate, def_concat_total_target, (int)Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_Concatenate, def_concat_total_source1, (int)positions1))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_Concatenate, def_concat_total_sourse2, (int)positions2))
         return false;
      //--- place kernel to the execution queue
      int off_set[] = {0};
      int NDRange[] = {(int)Total()};
      ResetLastError();
      if(!m_cOpenCL.Execute(def_k_Concatenate, 1, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
