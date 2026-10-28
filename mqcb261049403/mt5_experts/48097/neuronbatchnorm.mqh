//+------------------------------------------------------------------+
//|                                              NeuronBatchNorm.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include "neuronbase.mqh"
//+------------------------------------------------------------------+
//| Class CNeuronBatchNorm                                           |
//| Purpose: Batch normalization class                               |
//+------------------------------------------------------------------+
class CNeuronBatchNorm    :  public CNeuronBase
  {
protected:
   CBufferType       m_cBatchOptions;
   uint              m_iBatchSize;       // batch size

public:
                     CNeuronBatchNorm(void);
                    ~CNeuronBatchNorm(void);
   //---
   virtual bool      Init(const CLayerDescription* description) override;
   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;
   virtual bool      FeedForward(CNeuronBase* prevLayer) override;
   virtual bool      CalcHiddenGradient(CNeuronBase* prevLayer) override;
   virtual bool      CalcDeltaWeights(CNeuronBase* prevLayer, bool read) override;
   //--- file handling methods
   virtual bool      Save(const int file_handle) override;
   virtual bool      Load(const int file_handle) override;
   //--- object identification method
   virtual int       Type(void)  override   const { return(defNeuronBatchNorm); }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNeuronBatchNorm::CNeuronBatchNorm(void)  :  m_iBatchSize(1)
  {
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CNeuronBatchNorm::~CNeuronBatchNorm(void)
  {
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronBatchNorm::Init(const CLayerDescription *description)
  {
   if(!description ||
      description.window != description.count)
      return false;
   CLayerDescription *temp = new CLayerDescription();
   if(!temp || !temp.Copy(description))
      return false;
   temp.window = 1;
   if(!CNeuronBase::Init(temp))
      return false;
   delete temp;
//--- initialize buffer of trainable parameters
   if(!m_cWeights.m_mMatrix.Fill(0))
      return false;
   if(!m_cWeights.m_mMatrix.Col(VECTOR::Ones(description.count), 0))
      return false;
//--- initialize buffers of normalization parameters
   if(!m_cBatchOptions.BufferInit(description.count, 3, 0))
      return false;
   if(!m_cBatchOptions.Col(VECTOR::Ones(description.count), 1))
      return false;
   m_iBatchSize = description.batch;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBatchNorm::SetOpenCL(CMyOpenCL *opencl)
  {
   CNeuronBase::SetOpenCL(opencl);
   m_cBatchOptions.BufferCreate(m_cOpenCL);
   return true;
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronBatchNorm::FeedForward(CNeuronBase *prevLayer)
  {
//--- control block
   if(!prevLayer || !prevLayer.GetOutputs() || !m_cOutputs || !m_cWeights || !m_cActivation)
      return false;
//--- branching of the algorithm across computing devices
   if(!m_cOpenCL)
     {
      //--- check the normalization batch size
      if(m_iBatchSize <= 1)
         m_cOutputs.m_mMatrix = prevLayer.GetOutputs().m_mMatrix;
      else
        {
         MATRIX inputs = prevLayer.GetOutputs().m_mMatrix;
         if(!inputs.Reshape(1, prevLayer.Total()))
            return false;
         VECTOR mean = (m_cBatchOptions.Col(0) * ((TYPE)m_iBatchSize - 1.0) + inputs.Row(0)) / (TYPE)m_iBatchSize;
         VECTOR delt = inputs.Row(0) - mean;
         VECTOR variance = (m_cBatchOptions.Col(1) * ((TYPE)m_iBatchSize - 1.0) + MathPow(delt, 2)) / (TYPE)m_iBatchSize;
         VECTOR std = sqrt(variance) + 1e-32;
         VECTOR nx = delt / std;
         VECTOR res = m_cWeights.Col(0) * nx + m_cWeights.Col(1);
         if(!m_cOutputs.Row(res, 0) ||
            !m_cBatchOptions.Col(mean, 0) ||
            !m_cBatchOptions.Col(variance, 1) ||
            !m_cBatchOptions.Col(nx, 2))
            return false;
        }
     }
   else  // OpenCL block
     {
      //--- check the normalization batch size
      if(m_iBatchSize <= 1)
        {
         //--- check data buffers
         CBufferType *inputs = prevLayer.GetOutputs();
         if(inputs.GetIndex() < 0)
            return false;
         if(m_cOutputs.GetIndex() < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_inputs, inputs.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_outputs, m_cOutputs.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_a, (TYPE)1))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_b, (TYPE)0))
            return false;
         uint offset[] = {0};
         uint NDRange[] = {(uint)m_cOutputs.Total()};
         if(!m_cOpenCL.Execute(def_k_LineActivation, 1, offset, NDRange))
            return false;
        }
      else
        {
         //--- check data buffers
         CBufferType *inputs = prevLayer.GetOutputs();
         if(inputs.GetIndex() < 0)
            return false;
         if(m_cBatchOptions.GetIndex() < 0)
            return false;
         if(m_cWeights.GetIndex() < 0)
            return false;
         if(m_cOutputs.GetIndex() < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormFeedForward, def_bnff_inputs, inputs.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormFeedForward, def_bnff_weights, m_cWeights.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormFeedForward, def_bnff_options, m_cBatchOptions.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormFeedForward, def_bnff_outputs, m_cOutputs.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_BatchNormFeedForward, def_bnff_total, (int)m_cOutputs.Total()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_BatchNormFeedForward, def_bnff_batch, m_iBatchSize))
            return false;
         //--- place to execution queue
         uint off_set[] = {0};
         uint NDRange[] = { (int)(m_cOutputs.Total() + 3) / 4 };
         if(!m_cOpenCL.Execute(def_k_BatchNormFeedForward, 1, off_set, NDRange))
            return false;
        }
     }
//---
   if(!m_cActivation.Activation(m_cOutputs))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for gradient propagation through the hidden layer         |
//+------------------------------------------------------------------+
bool CNeuronBatchNorm::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- control block
   if(!prevLayer || !prevLayer.GetOutputs() || !prevLayer.GetGradients() || !m_cActivation || !m_cWeights)
      return false;
//--- adjust error gradient to the derivative of the activation function
   if(!m_cActivation.Derivative(m_cGradients))
      return false;
//--- branching of the algorithm across computing devices
   if(!m_cOpenCL)
     {
//--- check the normalization batch size
      if(m_iBatchSize <= 1)
         prevLayer.GetGradients().m_mMatrix = m_cGradients.m_mMatrix;
      else
        {
         MATRIX mat_inputs = prevLayer.GetOutputs().m_mMatrix;
         if(!mat_inputs.Reshape(1, prevLayer.Total()))
            return false;
         VECTOR inputs = mat_inputs.Row(0);
         CBufferType *inputs_grad = prevLayer.GetGradients();
         ulong total = m_cOutputs.Total();
         VECTOR gnx = m_cGradients.Row(0) * m_cWeights.Col(0);
         VECTOR temp = MathPow(MathSqrt(m_cBatchOptions.Col(1) + 1e-32), -1);
         VECTOR gvar = (inputs - m_cBatchOptions.Col(0)) / (-2 * pow(m_cBatchOptions.Col(1) + 1.0e-32, 3.0 / 2.0)) * gnx;
         VECTOR gmu = (-1) * temp * gnx - gvar * 2 * (inputs - m_cBatchOptions.Col(0)) / (TYPE)m_iBatchSize;
         VECTOR gx = temp * gnx + gmu / (TYPE)m_iBatchSize + gvar * 2 * (inputs - m_cBatchOptions.Col(0)) / (TYPE)m_iBatchSize;
         if(!inputs_grad.Row(gx, 0))
            return false;
         if(!inputs_grad.Reshape(prevLayer.Rows(), prevLayer.Cols()))
            return false;
        }
     }
   else  // OpenCL block
     {
//--- check the normalization batch size
      if(m_iBatchSize <= 1)
        {
         //--- check data buffers
         CBufferType *grad = prevLayer.GetGradients();
         if(grad.GetIndex() < 0)
            return false;
         if(m_cGradients.GetIndex() < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_inputs, m_cGradients.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LineActivation, def_activ_outputs, grad.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_a, (TYPE)1))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_LineActivation, def_activ_param_b, (TYPE)0))
            return false;
         uint offset[] = {0};
         uint NDRange[] = {(uint)m_cOutputs.Total()};
         if(!m_cOpenCL.Execute(def_k_LineActivation, 1, offset, NDRange))
            return false;
        }
      else
        {
         //--- check data buffers
         CBufferType* inputs = prevLayer.GetOutputs();
         CBufferType* inputs_grad = prevLayer.GetGradients();
         if(inputs.GetIndex() < 0)
            return false;
         if(m_cBatchOptions.GetIndex() < 0)
            return false;
         if(m_cWeights.GetIndex() < 0)
            return false;
         if(m_cOutputs.GetIndex() < 0)
            return false;
         if(m_cGradients.GetIndex() < 0)
            return false;
         if(inputs_grad.GetIndex() < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient, def_bnhgr_inputs, inputs.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient, def_bnhgr_weights, m_cWeights.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient, def_bnhgr_options, m_cBatchOptions.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient, def_bnhgr_gradient, m_cGradients.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcHiddenGradient, def_bnhgr_gradient_inputs, inputs_grad.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_BatchNormCalcHiddenGradient, def_bnhgr_total, (int)m_cOutputs.Total()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_BatchNormCalcHiddenGradient, def_bnhgr_batch, m_iBatchSize))
            return false;
         //--- place to execution queue
         int off_set[] = {0};
         int NDRange[] = { (int)(m_cOutputs.Total() + 3) / 4 };
         if(!m_cOpenCL.Execute(def_k_BatchNormCalcHiddenGradient, 1, off_set, NDRange))
            return false;
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating gradient to the weight matrix level       |
//+------------------------------------------------------------------+
bool CNeuronBatchNorm::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)
  {
//--- control block
   if(!m_cGradients || !m_cDeltaWeights)
      return false;
//--- check the normalization batch size
   if(m_iBatchSize <= 1)
      return true;
//--- branching of the algorithm across computing devices
   if(!m_cOpenCL)
     {
      VECTOR grad = m_cGradients.Row(0);
      VECTOR delta = m_cBatchOptions.Col(2) * grad + m_cDeltaWeights.Col(0);
      if(!m_cDeltaWeights.Col(delta, 0))
         return false;
      if(!m_cDeltaWeights.Col(grad + m_cDeltaWeights.Col(1), 1))
         return false;
     }
   else
     {
      //--- check data buffers
      if(m_cBatchOptions.GetIndex() < 0)
         return false;
      if(m_cGradients.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      //--- pass parameters to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcDeltaWeights, def_bndelt_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcDeltaWeights, def_bndelt_options, m_cBatchOptions.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_BatchNormCalcDeltaWeights, def_bndelt_gradient, m_cGradients.GetIndex()))
         return false;
      //--- place to execution queue
      int off_set[] = {0};
      int NDRange[] = {(int)m_cOutputs.Total()};
      if(!m_cOpenCL.Execute(def_k_BatchNormCalcDeltaWeights, 1, off_set, NDRange))
         return false;
      if(read && !m_cDeltaWeights.BufferRead())
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class object to a file                         |
//+------------------------------------------------------------------+
bool CNeuronBatchNorm::Save(const int file_handle)
  {
//--- call the parent class method
   if(!CNeuronBase::Save(file_handle))
      return false;
//--- save the size of the normalization batch
   if(FileWriteInteger(file_handle, m_iBatchSize) <= 0)
      return false;
//--- save normalization parameters
   if(!m_cBatchOptions.Save(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring a class from data in the file               |
//+------------------------------------------------------------------+
bool CNeuronBatchNorm::Load(const int file_handle)
  {
//--- call method of the parent class
   if(!CNeuronBase::Load(file_handle))
      return false;
   m_iBatchSize = FileReadInteger(file_handle);
//--- initialize the dynamic array of optimization parameters
   if(!m_cBatchOptions.Load(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
