//+------------------------------------------------------------------+
//|                                                   activation.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Include libraries                                                |
//+------------------------------------------------------------------+
#include "buffer.mqh"
//+------------------------------------------------------------------+
//| Class CActivation                                                |
//| Purpose: Class to implement algorithms of activation function    |
//|             and its derivative                                   |
//+------------------------------------------------------------------+
#define m_iOutputsTotal          (m_iRows * m_iCols)
class CActivation : protected CObject
  {
protected:
   ulong             m_iRows;
   ulong             m_iCols;
   VECTOR            m_adParams;
   CMyOpenCL*        m_cOpenCL;
   //---
   CBufferType*      m_cInputs;
   CBufferType*      m_cOutputs;

public:
                     CActivation(void);
                    ~CActivation(void) {if(!!m_cInputs) delete m_cInputs; }
   //---
   virtual bool      Init(VECTOR &params);
   virtual ENUM_ACTIVATION_FUNCTION  GetFunction(VECTOR &params);
   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) { return AF_NONE; }
   virtual bool      Activation(CBufferType*& output);
   virtual bool      Derivative(CBufferType*& gradient)  { return true; }
   //---
   virtual bool      SetOpenCL(CMyOpenCL *opencl, const ulong rows, const ulong cols);
   //--- file handling methods
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //--- object identification method
   virtual int       Type(void) const { return defActivation; }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CActivation::CActivation(void) : m_iRows(0),
   m_iCols(0),
   m_cOpenCL(NULL)
  {
   m_adParams = VECTOR::Ones(2);
   m_adParams[1] = 0;
  }
//+------------------------------------------------------------------+
//| Class initialization function                                    |
//+------------------------------------------------------------------+
bool CActivation::Init(VECTOR &params)
  {
   m_adParams = params;
//---
   m_cInputs = new CBufferType();
   if(!m_cInputs)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| The function returns the activation function used                |
//+------------------------------------------------------------------+
ENUM_ACTIVATION_FUNCTION CActivation::GetFunction(VECTOR &params)
  {
   params = m_adParams;
   return GetFunction();
  }
//+------------------------------------------------------------------+
//| Set the OpenCL context used                                      |
//+------------------------------------------------------------------+
bool CActivation::SetOpenCL(CMyOpenCL *opencl, const ulong rows, const ulong cols)
  {
   m_iRows = rows;
   m_iCols = cols;
   if(m_cOpenCL != opencl)
     {
      if(m_cOpenCL)
         delete m_cOpenCL;
      m_cOpenCL = opencl;
     }
//---
   if(!!m_cInputs)
     {
      if(!m_cInputs.BufferInit(m_iRows, m_iCols, 0))
         return false;
      m_cInputs.BufferCreate(m_cOpenCL);
     }
//---
   return(!!m_cOpenCL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CActivation::Activation(CBufferType *&output)
  {
   if(!output || output.Total() <= 0)
      return false;
   m_cOutputs = m_cInputs;
   m_cInputs = output;
   output = m_cOutputs;
   if(GetFunction() == AF_NONE && output != m_cInputs)
     {
      delete output;
      output = m_cInputs;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Class saving method                                              |
//+------------------------------------------------------------------+
bool CActivation::Save(const int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
   if(FileWriteInteger(file_handle, Type()) <= 0 ||
      FileWriteInteger(file_handle, (int)GetFunction()) <= 0 ||
      FileWriteInteger(file_handle, (int)m_iRows) <= 0 ||
      FileWriteInteger(file_handle, (int)m_iCols) <= 0 ||
      FileWriteDouble(file_handle, (double)m_adParams[0]) <= 0 ||
      FileWriteDouble(file_handle, (double)m_adParams[1]) <= 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring class elements from previously saved data   |
//+------------------------------------------------------------------+
bool CActivation::Load(const int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
   m_iRows = (uint)FileReadInteger(file_handle);
   m_iCols = (uint)FileReadInteger(file_handle);
   m_adParams.Init(2);
   m_adParams[0] = (TYPE)FileReadDouble(file_handle);
   m_adParams[1] = (TYPE)FileReadDouble(file_handle);
//---
   if(!m_cInputs)
     {
      m_cInputs = new CBufferType();
      if(!m_cInputs)
         return false;
     }
   if(!m_cInputs.BufferInit(m_iRows, m_iCols, 0))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Linear activation function                                       |
//| Parameters 'value' weighted sum of source data for activation    |
//| 'm_adParams[0]' line inclination coefficient                     |
//| 'm_adParams[1]' vertical line shift                              |
//+------------------------------------------------------------------+
class CActivationLine   :  public CActivation
  {
public:
                     CActivationLine(void) {};
                    ~CActivationLine(void) {};
   //---
   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) override { return AF_LINEAR; }
   virtual bool      Activation(CBufferType*& output) override;
   virtual bool      Derivative(CBufferType*& gradient) override;
  };
//+------------------------------------------------------------------+
//| Calculate activation function                                    |
//+------------------------------------------------------------------+
bool CActivationLine::Activation(CBufferType*& output)
  {
   if(!CActivation::Activation(output))
      return false;
//---
   if(!m_cOpenCL)
     {
      if(!m_cInputs.m_mMatrix.Activation(output.m_mMatrix, AF_LINEAR, AXIS_VERT, m_adParams[0], m_adParams[1]))
         return false;
     }
   else
     {
      if(m_cInputs.GetIndex() < 0)
         return false;
      if(m_cOutputs.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_inputs, m_cInputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_a, m_adParams[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_b, m_adParams[1]))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_LineActivation, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Derivative of linear activation function returns Parameter[0]    |
//+------------------------------------------------------------------+
bool CActivationLine::Derivative(CBufferType*& gradient)
  {
   if(!m_cInputs || !m_cOutputs ||
      !gradient || gradient.Total() < m_cOutputs.Total())
      return false;
//---
   if(!m_cOpenCL)
     {
      gradient.m_mMatrix = gradient.m_mMatrix * m_adParams[0];
     }
   else
     {
      if(gradient.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_inputs, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_outputs, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_a, m_adParams[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_b, (TYPE)0))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_LineActivation, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Sigmoid activation function                                      |
//| Parameters 'value' weighted sum of source data for activation    |
//| 'm_adParams[0]' defines range of values for activation function  |
//|                 from '0' to 'm_adParams[0]'                      |
//| 'm_adParams[1]' vertical shift of the function value             |
//+------------------------------------------------------------------+
class CActivationSigmoid   :  public CActivation
  {
public:
                     CActivationSigmoid(void) {};
                    ~CActivationSigmoid(void) {};
   //---
   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) override { return AF_SIGMOID; }
   virtual bool      Activation(CBufferType*& output) override;
   virtual bool      Derivative(CBufferType*& gradient) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CActivationSigmoid::Activation(CBufferType*& output)
  {
   if(!CActivation::Activation(output))
      return false;
//---
   if(!m_cOpenCL)
     {
      if(!m_cInputs.m_mMatrix.Activation(m_cOutputs.m_mMatrix, AF_SIGMOID))
         return false;
      output.m_mMatrix = m_cOutputs.m_mMatrix * m_adParams[0] - m_adParams[1];
     }
   else
     {
      if(m_cInputs.GetIndex() < 0)
         return false;
      if(m_cOutputs.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SigmoidActivation, def_activ_inputs, m_cInputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SigmoidActivation, def_activ_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SigmoidActivation, def_activ_param_a, m_adParams[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SigmoidActivation, def_activ_param_b, m_adParams[1]))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_SigmoidActivation, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Derivative of sigmoid activation function                        |
//| 'm_adParams[0]' defines range of values for activation function  |
//|                 from '0' to 'm_adParams[0]'                      |
//| 'm_adParams[1]' vertical shift of the function value             |
//+------------------------------------------------------------------+
bool CActivationSigmoid::Derivative(CBufferType*& gradient)
  {
   if(!m_cInputs || !m_cOutputs || !gradient ||
      gradient.Total() < m_cOutputs.Total())
      return false;
   if(!m_cOpenCL)
     {
      MATRIX temp = m_cOutputs.m_mMatrix + m_adParams[1];
      temp = (m_adParams[0] == 0 ? temp * 0 : temp * (temp / (- m_adParams[0]) + 1));
      gradient.m_mMatrix *= temp;
     }
   else
     {
      if(m_cOutputs.GetIndex() < 0 || gradient.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SigmoidDerivative, def_deactgr_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SigmoidDerivative, def_deactgr_gradients, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SigmoidDerivative, def_deactgr_deact_gradient, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SigmoidDerivative, def_deactgr_act_param_a, m_adParams[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SigmoidDerivative, def_deactgr_act_param_b, m_adParams[1]))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_SigmoidDerivative, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| TANH                                                             |
//| Parameters 'value' weighted sum of source data for activation    |
//+------------------------------------------------------------------+
class CActivationTANH   : public CActivation
  {
public:
                     CActivationTANH(void) {};
                    ~CActivationTANH(void) {};
   //---
   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) override { return AF_TANH; }
   virtual bool      Activation(CBufferType*& output) override;
   virtual bool      Derivative(CBufferType*& gradient) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CActivationTANH::Activation(CBufferType*& output)
  {
   if(!CActivation::Activation(output))
      return false;
   if(!m_cOpenCL)
     {
      if(!m_cInputs.m_mMatrix.Activation(output.m_mMatrix, AF_TANH))
         return false;
     }
   else
     {
      if(m_cInputs.GetIndex() < 0 ||
         m_cOutputs.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_TANHActivation, def_activ_inputs, m_cInputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_TANHActivation, def_activ_outputs, m_cOutputs.GetIndex()))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_TANHActivation, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Derivative of TANH                                               |
//| Parameters 'value' current value of activation function          |
//+------------------------------------------------------------------+
bool CActivationTANH::Derivative(CBufferType*& gradient)
  {
   if(!m_cOutputs || !gradient ||
      gradient.Total() < m_cOutputs.Total())
      return false;
//---
   if(!m_cOpenCL)
     {
      MATRIX temp = m_cInputs.m_mMatrix;
      if(!temp.Derivative(temp, AF_TANH))
         return false;
      gradient.m_mMatrix *= temp;
     }
   else
     {
      if(m_cOutputs.GetIndex() < 0 || gradient.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_TANHDerivative, def_deactgr_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_TANHDerivative, def_deactgr_gradients, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_TANHDerivative, def_deactgr_deact_gradient, gradient.GetIndex()))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_TANHDerivative, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| LReLU                                                            |
//| Parameters 'value' weighted sum of source data for activation    |
//|           'm_adParams[0]' leakage coefficient                    |
//+------------------------------------------------------------------+
class CActivationLReLU : public CActivation
  {
public:
                     CActivationLReLU(void) { m_adParams[0] = (TYPE)0.3; };
                    ~CActivationLReLU(void) {};
   //---
   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) override { return AF_LRELU; }
   virtual bool      Activation(CBufferType*& output) override;
   virtual bool      Derivative(CBufferType*& gradient) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CActivationLReLU::Activation(CBufferType*& output)
  {
   if(!CActivation::Activation(output))
      return false;
//---
   if(!m_cOpenCL)
     {
      if(!m_cInputs.m_mMatrix.Activation(output.m_mMatrix, AF_LRELU, AXIS_VERT, m_adParams[0]))
         return false;
     }
   else
     {
      if(m_cInputs.GetIndex() < 0)
         return false;
      if(m_cOutputs.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LReLuActivation, def_activ_inputs, m_cInputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LReLuActivation, def_activ_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LReLuActivation, def_activ_param_a, m_adParams[0]))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_LReLuActivation, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Derivative of LReLU                                              |
//+------------------------------------------------------------------+
bool CActivationLReLU::Derivative(CBufferType*& gradient)
  {
   if(!m_cOutputs || !gradient ||
      m_cOutputs.Total() <= 0 || gradient.Total() < m_cOutputs.Total())
      return false;
//---
   if(!m_cOpenCL)
     {
      MATRIX temp;
      if(!m_cInputs.m_mMatrix.Derivative(temp, AF_LRELU, AXIS_VERT, m_adParams[0]))
         return false;
      gradient.m_mMatrix *= temp;
     }
   else
     {
      if(m_cOutputs.GetIndex() < 0 || gradient.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LReLuDerivative, def_deactgr_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LReLuDerivative, def_deactgr_gradients, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LReLuDerivative, def_deactgr_deact_gradient, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LReLuDerivative, def_deactgr_act_param_a, m_adParams[0]))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_LReLuDerivative, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Swish                                                            |
//| Parameters 'value' weighted sum of source data for activation    |
//| 'm_adParams[0]' function non-linearity coefficient               |
//+------------------------------------------------------------------+
class CActivationSwish : public CActivation
  {
protected:
   virtual MATRIX    Activation(void);
   virtual MATRIX    Derivative(void);

public:
                     CActivationSwish(void) {};
                    ~CActivationSwish(void) {};
   //---
   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) override { return AF_SWISH; }
   virtual bool      Activation(CBufferType*& output) override;
   virtual bool      Derivative(CBufferType*& gradient) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MATRIX CActivationSwish::Activation(void)
  {
   return m_cInputs.m_mMatrix / (exp(m_cInputs.m_mMatrix * (-m_adParams[0])) + 1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CActivationSwish::Activation(CBufferType*& output)
  {
   if(!CActivation::Activation(output))
      return false;
//---
   if(!m_cOpenCL)
     {
      if(!m_cInputs.m_mMatrix.Activation(output.m_mMatrix, AF_SWISH, AXIS_VERT, m_adParams[0]))
         return false;
     }
   else
     {
      if(m_cOutputs.GetIndex() < 0 || m_cInputs.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SwishActivation, def_activ_inputs, m_cInputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SwishActivation, def_activ_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SwishActivation, def_activ_param_a, m_adParams[0]))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_SwishActivation, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Derivative of Swish                                              |
//| Parameters 'output' current value of activation function         |
//| 'm_cPrevInputs' weighted sum of source data for activation       |
//| 'm_adParams[0]' function non-linearity coefficient               |
//+------------------------------------------------------------------+
MATRIX  CActivationSwish::Derivative(void)
  {
   if(!m_cInputs)
      return MATRIX::Zeros(0, 0);
   MATRIX by = m_cOutputs.m_mMatrix * m_adParams[0];
   return (by + (by * (-1) + 1) / (exp(m_cInputs.m_mMatrix * (-m_adParams[0])) + 1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CActivationSwish::Derivative(CBufferType*& gradient)
  {
   if(!m_cOutputs || !gradient || !m_cInputs ||
      m_cOutputs.Total() <= 0 || gradient.Total() < m_cOutputs.Total() ||
      m_cInputs.Total() < m_cOutputs.Total())
      return false;
//---
   if(!m_cOpenCL)
     {
      MATRIX temp = Derivative();
      gradient.m_mMatrix *= temp;
     }
   else
     {
      if(m_cOutputs.GetIndex() < 0 || gradient.GetIndex() < 0 || m_cInputs.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SwishDerivative, def_deactgr_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SwishDerivative, def_deactgr_gradients, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SwishDerivative, def_deactgr_deact_gradient, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SwishDerivative, def_deactgr_act_param_a, m_adParams[0]))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SwishDerivative, def_deactgr_act_param_b, m_cInputs.GetIndex()))
         return false;
      uint offset[] = {0};
      uint NDRange[] = {(uint)m_iOutputsTotal};
      if(!m_cOpenCL.Execute(def_k_SwishDerivative, 1, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CActivationSoftMAX : public CActivation
  {
protected:
   virtual MATRIX    Derivative(ulong row);

public:
                     CActivationSoftMAX(void) {};
                    ~CActivationSoftMAX(void) {};
   //---
   virtual ENUM_ACTIVATION_FUNCTION   GetFunction(void) override { return AF_SOFTMAX; }
   virtual bool      Activation(CBufferType*& output) override;
   virtual bool      Derivative(CBufferType*& gradient) override;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CActivationSoftMAX::Activation(CBufferType*& output)
  {
   if(!CActivation::Activation(output))
      return false;
//---
   if(!m_cOpenCL)
     {
      if(!m_cInputs.m_mMatrix.Activation(output.m_mMatrix, AF_SOFTMAX))
         return false;
     }
   else
     {
      if(m_cOutputs.GetIndex() < 0 ||
         m_cInputs.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SoftMAXActivation, def_softmax_input, m_cInputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SoftMAXActivation, def_softmax_output, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SoftMAXActivation, def_softmax_total, m_cInputs.Cols()))
         return false;
      uint offset[] = {0, 0};
      uint NDRange[] = {(uint)fmin(m_cInputs.Cols(), LOCAL_SIZE), (uint)m_cInputs.Rows()};
      uint local[] = {(uint)fmin(m_cInputs.Cols(), LOCAL_SIZE), 1};
      if(!m_cOpenCL.Execute(def_k_SoftMAXActivation, 2, offset, NDRange, local))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MATRIX CActivationSoftMAX::Derivative(ulong row)
  {
   ulong size = m_cOutputs.Cols();
   MATRIX ident = MATRIX::Identity(size, size);
   MATRIX ones = MATRIX::Ones(size, 1);
   MATRIX result = MATRIX::Zeros(1, size);
   if(!result.Row(m_cOutputs.m_mMatrix.Row(row), 0))
      return MATRIX::Zeros(0, 0);
   result = ones.MatMul(result);
   result = result.Transpose() * (ident - result);
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CActivationSoftMAX::Derivative(CBufferType*& gradient)
  {
   if(!m_cOutputs || !gradient ||
      m_cOutputs.Total() <= 0 || gradient.Total() < m_cOutputs.Total())
      return false;
//---
   if(!m_cOpenCL)
     {
      MATRIX check;
      if(!m_cInputs.Derivative(check, AF_SOFTMAX))
         return false;
      for(uint r = 0; r < m_cOutputs.Rows(); r++)
        {
         MATRIX derivative = Derivative(r);
         VECTOR temp = derivative.MatMul(gradient.m_mMatrix.Row(r));
         if(!gradient.m_mMatrix.Row(temp, r))
            return false;
        }
     }
   else
     {
      CBufferType *temp = gradient;
      gradient = m_cInputs;
      m_cInputs = temp;
      if(m_cOutputs.GetIndex() < 0 || gradient.GetIndex() < 0 ||
         !m_cInputs || m_cInputs.GetIndex() < 0)
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SoftMAXDerivative, def_deactgr_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SoftMAXDerivative, def_deactgr_gradients, m_cInputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SoftMAXDerivative, def_deactgr_deact_gradient, gradient.GetIndex()))
         return false;
      uint offset[] = {0, 0};
      uint NDRange[] = {(uint)m_cOutputs.Cols(), (uint)m_cOutputs.Rows()};
      if(!m_cOpenCL.Execute(def_k_SoftMAXDerivative, 2, offset, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
