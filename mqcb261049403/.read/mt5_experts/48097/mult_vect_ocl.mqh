//+------------------------------------------------------------------+
//|                                                Mult_Vect_OCL.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                https://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//| Calculate sum of two vectors using OpenCL                        |
//+------------------------------------------------------------------+
#include <OpenCL/OpenCL.mqh>
#resource "mult_vect_ocl.cl" as string OCLprogram
#define TYPE                        float
const string ExtType = StringFormat("#define TYPE %s\r\n"
                                    "#define TYPE4 %s4\r\n",
                                    typename(TYPE), typename(TYPE));
#define cl_program                  ExtType+OCLprogram

//+------------------------------------------------------------------+
//|  Defines                                                         |
//+------------------------------------------------------------------+
#define k_kernel     0
#define k_source1    0
#define k_source2    1
#define k_result     2
#define k_cols       3
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
COpenCL         *cOpenCL;
int             buffer_Source1;
int             buffer_Source2;
int             buffer_Result;
//+------------------------------------------------------------------+
//| Initialize OpenCL program                                        |
//+------------------------------------------------------------------+
bool OpenCL_Init(matrix<TYPE> &source1, vector<TYPE> &source2)
  {
//--- create OpenCL program, kernel and buffers
   cOpenCL = new COpenCL();
   if(!cOpenCL.Initialize(cl_program, true))
      return false;
   if(!cOpenCL.SetKernelsCount(1))
      return false;
   if(!cOpenCL.KernelCreate(k_kernel, "MultVectors"))
      return false;
   buffer_Source1 = CLBufferCreate(cOpenCL.GetContext(), (uint)(sizeof(TYPE) * source1.Rows() * source1.Cols()), CL_MEM_READ_ONLY);
   buffer_Source2 = CLBufferCreate(cOpenCL.GetContext(), (uint)(sizeof(TYPE) * source2.Size()), CL_MEM_READ_ONLY);
   buffer_Result = CLBufferCreate(cOpenCL.GetContext(), (uint)(sizeof(TYPE) * source1.Rows()), CL_MEM_WRITE_ONLY);
   if(buffer_Result <= 0 || buffer_Source1 <= 0 || buffer_Source2 <= 0)
      return false;
   if(!CLBufferWrite(buffer_Source1,0,source1) || !CLBufferWrite(buffer_Source2,0,source2))
     return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|  Product of vectors                                              |
//+------------------------------------------------------------------+
bool MultOCL(int rows, int cols, vector<TYPE> &result)
  {
   result=vector<TYPE>::Zeros(rows);
//--- Set parameters
   if(!CLSetKernelArgMem(cOpenCL.GetKernel(k_kernel), k_source1, buffer_Source1))
      return false;
   if(!CLSetKernelArgMem(cOpenCL.GetKernel(k_kernel), k_source2, buffer_Source2))
      return false;
   if(!CLSetKernelArgMem(cOpenCL.GetKernel(k_kernel), k_result, buffer_Result))
      return false;
   if(!cOpenCL.SetArgument(k_kernel, k_cols, cols))
      return false;
//--- Run kernel
   int off_set[] = {0};
   int NDRange[] = {rows};
   if(!cOpenCL.Execute(k_kernel, 1, off_set, NDRange))
      return false;
//--- Get result
   uint data_read = CLBufferRead(buffer_Result, 0, result);
   if(data_read <= 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Delete OpenCL program                                            |
//+------------------------------------------------------------------+
void OpenCL_Deinit()
  {
   if(!cOpenCL)
      return;
//---
   cOpenCL.Shutdown();
   delete cOpenCL;
  }
//+------------------------------------------------------------------+
