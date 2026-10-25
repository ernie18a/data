//+------------------------------------------------------------------+
//|                                                       opencl.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#ifndef Defines
#include "defines.mqh"
#endif
#include <OpenCL\OpenCL.mqh>
//+------------------------------------------------------------------+
//| Class CMyOpenCL                                                  |
//| Purpose: Class for organizing operations with the OpenCL context |
//+------------------------------------------------------------------+
class CMyOpenCL   :  public COpenCL
  {
public:
                     CMyOpenCL(void)   {};
                    ~CMyOpenCL(void)   {};
   //--- initialization and shutdown
   virtual bool      Initialize(const string program, const bool show_log = true);
   //---
   template<typename T>
   int               AddBufferFromArray(T &data[], const uint data_array_offset, const uint data_array_count, const uint flags);
   int               AddBufferFromArray(MATRIX &data, const uint data_array_offset, const uint flags);
   int               AddBuffer(const uint size_in_bytes, const uint flags);
   bool              CheckBuffer(const int index);
   //---
   bool              BufferFromMatrix(const int buffer_index, MATRIX &data, const uint data_array_offset, const uint flags);
   bool              BufferRead(const int buffer_index, MATRIX &data, const uint cl_buffer_offset);
   bool              BufferWrite(const int buffer_index, MATRIX &data, const uint cl_buffer_offset);
  };
//+------------------------------------------------------------------+
//| Method for creating a buffer in the OpenCL context               |
//+------------------------------------------------------------------+
template<typename T>
int CMyOpenCL::AddBufferFromArray(T &data[], const uint data_array_offset, const uint data_array_count, const uint flags)
  {
//--- Search for a free element in a dynamic array of pointers
   int result = -1;
   for(int i = 0; i < m_buffers_total; i++)
     {
      if(m_buffers[i] != INVALID_HANDLE)
         continue;
      result = i;
      break;
     }
//--- If a free element is not found, add a new element to the array
   if(result < 0)
     {
      if(ArrayResize(m_buffers, m_buffers_total + 1) > 0)
        {
         m_buffers_total = ArraySize(m_buffers);
         result = m_buffers_total - 1;
         m_buffers[result] = INVALID_HANDLE;
        }
      else
         return result;
     }
//--- Create a buffer in the OpenCL context
   if(!BufferFromArray(result, data, data_array_offset, data_array_count, flags))
      return -1;
//---
   return result;
  }
//+------------------------------------------------------------------+
//| Method for creating a buffer in the OpenCL context               |
//+------------------------------------------------------------------+
int CMyOpenCL::AddBufferFromArray(MATRIX &data, const uint data_array_offset, const uint flags)
  {
//--- Search for a free element in a dynamic array of pointers
   int result = -1;
   for(int i = 0; i < m_buffers_total; i++)
     {
      if(m_buffers[i] != INVALID_HANDLE)
         continue;
      result = i;
      break;
     }
//--- If a free element is not found, add a new element to the array
   if(result < 0)
     {
      if(ArrayResize(m_buffers, m_buffers_total + 1) > 0)
        {
         m_buffers_total = ArraySize(m_buffers);
         result = m_buffers_total - 1;
         m_buffers[result] = INVALID_HANDLE;
        }
      else
         return result;
     }
//--- Create a buffer in the OpenCL context
   if(!BufferFromMatrix(result, data, data_array_offset, flags))
      return -1;
   return result;
  }
//+------------------------------------------------------------------+
//| Method for creating a buffer in the OpenCL context               |
//+------------------------------------------------------------------+
int CMyOpenCL::AddBuffer(const uint size_in_bytes, const uint flags)
  {
//--- Search for a free element in a dynamic array of pointers
   int result = -1;
   for(int i = 0; i < m_buffers_total; i++)
     {
      if(m_buffers[i] != INVALID_HANDLE)
         continue;
      result = i;
      break;
     }
//--- If a free element is not found, add a new element to the array
   if(result < 0)
     {
      if(ArrayResize(m_buffers, m_buffers_total + 1) > 0)
        {
         m_buffers_total = ArraySize(m_buffers);
         result = m_buffers_total - 1;
         m_buffers[result] = INVALID_HANDLE;
        }
      else
         return result;
     }
//--- Create a buffer in the OpenCL context
   if(!BufferCreate(result, size_in_bytes, flags))
      return -1;
   return result;
  }
//+------------------------------------------------------------------+
//| Method for checking the validity of a pointer to the buffer      |
//| by index in the dynamic array                                    |
//+------------------------------------------------------------------+
bool CMyOpenCL::CheckBuffer(const int index)
  {
   if(index < 0 || index > m_buffers_total)
      return false;
   return m_buffers[index] != INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
//| BufferFromMatrix                                                 |
//+------------------------------------------------------------------+
bool CMyOpenCL::BufferFromMatrix(const int buffer_index, MATRIX &data, const uint data_array_offset, const uint flags)
  {
//--- check parameters
   if(m_context == INVALID_HANDLE || m_program == INVALID_HANDLE)
      return(false);
   if(buffer_index < 0 || buffer_index >= m_buffers_total)
      return(false);
//--- buffer does not exists, create it
   if(m_buffers[buffer_index] == INVALID_HANDLE)
     {
      uint size_in_bytes = sizeof(TYPE) * (int)(data.Rows() * data.Cols());
      int buffer_handle = CLBufferCreate(m_context, size_in_bytes, flags);
      if(buffer_handle != INVALID_HANDLE)
        {
         m_buffers[buffer_index] = buffer_handle;
        }
      else
         return(false);
     }
//--- write data to OpenCL buffer
   ResetLastError();
   if(!CLBufferWrite(m_buffers[buffer_index], data_array_offset, data))
     {
      PrintFormat("Write to buffer error %d", GetLastError());
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| BufferRead                                                       |
//+------------------------------------------------------------------+
bool CMyOpenCL::BufferRead(const int buffer_index, MATRIX &data, const uint cl_buffer_offset)
  {
//--- checking parameters
   if(buffer_index < 0 || buffer_index >= m_buffers_total || data.Rows() <= 0)
      return(false);
   if(m_buffers[buffer_index] == INVALID_HANDLE)
      return(false);
   if(m_context == INVALID_HANDLE || m_program == INVALID_HANDLE)
      return(false);
//--- read data of the buffer from the OpenCL context
   if(!CLBufferRead(m_buffers[buffer_index], cl_buffer_offset, data))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| BufferWrite                                                      |
//+------------------------------------------------------------------+
bool CMyOpenCL::BufferWrite(const int buffer_index, MATRIX &data, const uint cl_buffer_offset)
  {
//--- checking parameters
   if(buffer_index < 0 || buffer_index >= m_buffers_total || data.Rows() <= 0)
      return(false);
   if(m_buffers[buffer_index] == INVALID_HANDLE)
      return(false);
   if(m_context == INVALID_HANDLE || m_program == INVALID_HANDLE)
      return(false);
//--- write buffer data to the OpenCL context
   if(!CLBufferWrite(m_buffers[buffer_index], cl_buffer_offset, data))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool CMyOpenCL::Initialize(const string program, const bool show_log = true)
  {
#ifndef TYPE
   return COpenCL::Initialize(program, show_log);
#else
//---
   if((m_context = CLContextCreate(typename(TYPE) == "double" ? CL_USE_GPU_DOUBLE_ONLY : CL_USE_ANY)) == INVALID_HANDLE)
      if((m_context = CLContextCreate(CL_USE_CPU_ONLY)) == INVALID_HANDLE)
        {
         Print("OpenCL not found. Error code=", GetLastError());
         return(false);
        }
//--- check support working with doubles (cl_khr_fp64)
   if(CLGetInfoString(m_context, CL_DEVICE_EXTENSIONS, m_device_extensions))
     {
      string extenstions[];
      StringSplit(m_device_extensions, ' ', extenstions);
      m_support_cl_khr_fp64 = false;
      int size = ArraySize(extenstions);
      for(int i = 0; i < size; i++)
        {
         if(extenstions[i] == "cl_khr_fp64")
            m_support_cl_khr_fp64 = true;
        }
     }
//--- compile the program
   string build_error_log;
   if((m_program = CLProgramCreate(m_context, program, build_error_log)) == INVALID_HANDLE)
     {
      if(show_log)
        {
         string loglines[];
         StringSplit(build_error_log, '\n', loglines);
         int lines_count = ArraySize(loglines);
         for(int i = 0; i < lines_count; i++)
            Print(loglines[i]);
        }
      CLContextFree(m_context);
      Print("OpenCL program create failed. Error code=", GetLastError());
      return(false);
     }
//---
   return(true);
#endif
  }
//+------------------------------------------------------------------+
