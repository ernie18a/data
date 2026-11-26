//+------------------------------------------------------------------+
//|                                                   NeuronBase.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include <Math\Stat\Normal.mqh>
#include "buffer.mqh"
#include "layerdescription.mqh"
#include "activation.mqh"
//+------------------------------------------------------------------+
//| Class CNeuronBase                                                |
//| Purpose: Base class for a fully connected neural layer           |
//+------------------------------------------------------------------+
class CNeuronBase    :  public CObject
  {
protected:
   bool              m_bTrain;
   CMyOpenCL*        m_cOpenCL;
   CActivation*      m_cActivation;
   ENUM_OPTIMIZATION m_eOptimization;
   CBufferType*      m_cOutputs;
   CBufferType*      m_cWeights;
   CBufferType*      m_cDeltaWeights;
   CBufferType*      m_cGradients;
   CBufferType*      m_cMomenum[2];
   //---
   virtual bool      SGDUpdate(int batch_size, TYPE learningRate,
                               VECTOR &Lambda);
   virtual bool      MomentumUpdate(int batch_size, TYPE learningRate,
                                    VECTOR &Beta, VECTOR &Lambda);
   virtual bool      AdaGradUpdate(int batch_size, TYPE learningRate,
                                   VECTOR &Lambda);
   virtual bool      RMSPropUpdate(int batch_size, TYPE learningRate,
                                   VECTOR &Beta, VECTOR &Lambda);
   virtual bool      AdaDeltaUpdate(int batch_size,
                                    VECTOR &Beta, VECTOR &Lambda);
   virtual bool      AdamUpdate(int batch_size, TYPE learningRate,
                                VECTOR &Beta, VECTOR &Lambda);
   virtual bool      SetActivation(ENUM_ACTIVATION_FUNCTION function, VECTOR &params);

public:
                     CNeuronBase(void);
                    ~CNeuronBase(void);
   //---
   virtual bool      Init(const CLayerDescription *description);
   virtual bool      SetOpenCL(CMyOpenCL *opencl);
   virtual bool      FeedForward(CNeuronBase *prevLayer);
   virtual bool      CalcOutputGradient(CBufferType *target, ENUM_LOSS_FUNCTION loss);
   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer);
   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read);
   virtual bool      UpdateWeights(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda);
   //---
   virtual void      TrainMode(bool flag)       {  m_bTrain = flag; }
   virtual bool      TrainMode(void)      const {  return m_bTrain; }
   //---
   virtual CBufferType       *GetOutputs(void)       const {  return(m_cOutputs);     }
   virtual CBufferType       *GetGradients(void)     const {  return(m_cGradients);   }
   virtual CBufferType       *GetWeights(void)       const {  return(m_cWeights);     }
   virtual CBufferType       *GetDeltaWeights(void)  const {  return(m_cDeltaWeights);}
   virtual bool      SetOutputs(CBufferType* buffer, bool delete_prevoius = true);
   //--- methods for working with files
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //--- method of identifying the object
   virtual int       Type(void)              const { return(defNeuronBase);   }
   virtual ulong     Rows(void)              const { return(m_cOutputs.Rows());   }
   virtual ulong     Cols(void)              const { return(m_cOutputs.Cols());   }
   virtual ulong     Total(void)             const { return(m_cOutputs.Total());   }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNeuronBase::CNeuronBase(void)   : m_eOptimization(Adam)
  {
   m_cOpenCL = NULL;
   m_cActivation = new CActivationSwish();
   m_cOutputs = new CBufferType();
   m_cWeights = new CBufferType();
   m_cDeltaWeights = new CBufferType();
   m_cGradients = new CBufferType();
   m_cMomenum[0] = new CBufferType();
   m_cMomenum[1] = new CBufferType();
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CNeuronBase::~CNeuronBase(void)
  {
   if(m_cActivation)
      delete m_cActivation;
   if(m_cOutputs)
      delete m_cOutputs;
   if(m_cWeights)
      delete m_cWeights;
   if(m_cDeltaWeights)
      delete m_cDeltaWeights;
   if(m_cGradients)
      delete m_cGradients;
   if(m_cMomenum[0])
      delete m_cMomenum[0];
   if(m_cMomenum[1])
      delete m_cMomenum[1];
  }
//+------------------------------------------------------------------+
//| Method for passing a pointer to the context handling object      |
//| OpenCL                                                           |
//+------------------------------------------------------------------+
bool CNeuronBase::SetOpenCL(CMyOpenCL *opencl)
  {
   if(!opencl)
     {
      if(m_cOutputs)
         m_cOutputs.BufferFree();
      if(m_cGradients)
         m_cGradients.BufferFree();
      if(m_cWeights)
         m_cWeights.BufferFree();
      if(m_cDeltaWeights)
         m_cDeltaWeights.BufferFree();
      for(int i = 0; i < 2; i++)
        {
         if(m_cMomenum[i])
            m_cMomenum[i].BufferFree();
        }
      if(m_cActivation)
         m_cActivation.SetOpenCL(m_cOpenCL, Rows(), Cols());
      m_cOpenCL = opencl;
      return true;
     }
   if(m_cOpenCL)
      delete m_cOpenCL;
   m_cOpenCL = opencl;
   if(m_cOutputs)
      m_cOutputs.BufferCreate(opencl);
   if(m_cGradients)
      m_cGradients.BufferCreate(opencl);
   if(m_cWeights)
      m_cWeights.BufferCreate(opencl);
   if(m_cDeltaWeights)
      m_cDeltaWeights.BufferCreate(opencl);
   for(int i = 0; i < 2; i++)
     {
      if(m_cMomenum[i])
         m_cMomenum[i].BufferCreate(opencl);
     }
   if(m_cActivation)
      m_cActivation.SetOpenCL(m_cOpenCL, Rows(), Cols());
//---
   return(!!m_cOpenCL);
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronBase::Init(const CLayerDescription *desc)
  {
//--- source data control block
   if(!desc || desc.type != Type() || desc.count <= 0)
      return false;
//--- create a results buffer
   if(!m_cOutputs)
      if(!(m_cOutputs = new CBufferType()))
         return false;
   if(!m_cOutputs.BufferInit(1, desc.count, 0))
      return false;
//--- create a buffer of error gradients
   if(!m_cGradients)
      if(!(m_cGradients = new CBufferType()))
         return false;
   if(!m_cGradients.BufferInit(1, desc.count, 0))
      return false;
//--- delete unused objects for the source data layer
   if(desc.window <= 0)
     {
      if(m_cActivation)
         delete m_cActivation;
      if(m_cWeights)
         delete m_cWeights;
      if(m_cDeltaWeights)
         delete m_cDeltaWeights;
      if(m_cMomenum[0])
         delete m_cMomenum[0];
      if(m_cMomenum[1])
         delete m_cMomenum[1];
      if(m_cOpenCL)
         if(!m_cOutputs.BufferCreate(m_cOpenCL))
            return false;
      m_eOptimization = desc.optimization;
      return true;
     }
//--- initialize the activation function object
   VECTOR ar_temp = desc.activation_params;
   if(!SetActivation(desc.activation, ar_temp))
      return false;
//--- initialize the weight matrix object
   if(!m_cWeights)
      if(!(m_cWeights = new CBufferType()))
         return false;
   if(!m_cWeights.BufferInit(desc.count, desc.window + 1, 0))
      return false;
   double weights[];
   TYPE sigma = (TYPE)(desc.activation == AF_LRELU ?
                       2.0 / (MathPow(1 + desc.activation_params[0], 2) * desc.window) :
                       1.0 / desc.window);
   if(!MathRandomNormal(0, MathSqrt(sigma), (uint)m_cWeights.Total(), weights))
      return false;
   for(uint i = 0; i < m_cWeights.Total(); i++)
      if(!m_cWeights.m_mMatrix.Flat(i, (TYPE)weights[i]))
         return false;
//--- initialize the object of gradient accumulation at the weight matrix level
   if(!m_cDeltaWeights)
      if(!(m_cDeltaWeights = new CBufferType()))
         return false;
   if(!m_cDeltaWeights.BufferInit(desc.count, desc.window + 1, 0))
      return false;
//--- initialize the momentum objects
   switch(desc.optimization)
     {
      case None:
      case SGD:
         for(int i = 0; i < 2; i++)
            if(m_cMomenum[i])
               delete m_cMomenum[i];
         break;
      case MOMENTUM:
      case AdaGrad:
      case RMSProp:
         if(!m_cMomenum[0])
            if(!(m_cMomenum[0] = new CBufferType()))
               return false;
         if(!m_cMomenum[0].BufferInit(desc.count, desc.window + 1, 0))
            return false;
         if(m_cMomenum[1])
            delete m_cMomenum[1];
         break;
      case AdaDelta:
      case Adam:
         for(int i = 0; i < 2; i++)
           {
            if(!m_cMomenum[i])
               if(!(m_cMomenum[i] = new CBufferType()))
                  return(false);
            if(!m_cMomenum[i].BufferInit(desc.count, desc.window + 1, 0))
               return false;
           }
         break;
      default:
         return false;
         break;
     }
//--- save the parameter optimization object
   m_eOptimization = desc.optimization;
   return true;
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronBase::FeedForward(CNeuronBase * prevLayer)
  {
//--- control block
   if(!prevLayer || !m_cOutputs || !m_cWeights || !prevLayer.GetOutputs() || !m_cActivation)
      return false;
   CBufferType *input_data = prevLayer.GetOutputs();
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      if(m_cWeights.Cols() != (input_data.Total() + 1))
         return false;
      //---
      MATRIX m = input_data.m_mMatrix;
      if(!m.Reshape(1, input_data.Total() + 1))
         return false;
      m[0, m.Cols() - 1] = 1;
      m_cOutputs.m_mMatrix = m.MatMul(m_cWeights.m_mMatrix.Transpose());
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(input_data.GetIndex() < 0)
         return false;
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(m_cOutputs.GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_PerceptronFeedForward, def_pff_inputs, input_data.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_PerceptronFeedForward, def_pff_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_PerceptronFeedForward, def_pff_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_PerceptronFeedForward, def_pff_inputs_total, (int)input_data.Total()))
         return false;
      //--- place kernel to the execution queue
      uint off_set[] = {0};
      uint NDRange[] = {(uint)m_cOutputs.Total()};
      if(!m_cOpenCL.Execute(def_k_PerceptronFeedForward, 1, off_set, NDRange))
         return false;
     }
//---
   return m_cActivation.Activation(m_cOutputs);
  }
//+------------------------------------------------------------------+
//| Method for calculating error gradient for the results layer      |
//+------------------------------------------------------------------+
bool CNeuronBase::CalcOutputGradient(CBufferType * target, ENUM_LOSS_FUNCTION loss)
  {
//--- control block
   if(!target || !m_cOutputs || !m_cGradients ||
      target.Total() < m_cOutputs.Total() ||
      m_cGradients.Total() < m_cOutputs.Total())
      return false;
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      switch(loss)
        {
         case LOSS_MAE:
            m_cGradients.m_mMatrix = target.m_mMatrix - m_cOutputs.m_mMatrix;
            break;
         case LOSS_MSE:
            m_cGradients.m_mMatrix = (target.m_mMatrix - m_cOutputs.m_mMatrix) * 2;
            break;
         case LOSS_CCE:
            m_cGradients.m_mMatrix = target.m_mMatrix / (m_cOutputs.m_mMatrix + (TYPE)FLT_MIN) *
                                     log(m_cOutputs.m_mMatrix) * (-1);
            break;
         case LOSS_BCE:
            m_cGradients.m_mMatrix = (target.m_mMatrix - m_cOutputs.m_mMatrix) /
                                     (MathPow(m_cOutputs.m_mMatrix, 2) - m_cOutputs.m_mMatrix + (TYPE)FLT_MIN);
            break;
         default:
            m_cGradients.m_mMatrix = target.m_mMatrix - m_cOutputs.m_mMatrix;
            break;
        }
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(target.GetIndex() < 0)
         return false;
      if(m_cOutputs.GetIndex() < 0)
         return false;
      if(m_cGradients.GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcOutputGradient, def_outgr_target, target.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcOutputGradient, def_outgr_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcOutputGradient, def_outgr_gradients, m_cGradients.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_CalcOutputGradient, def_outgr_loss_function, (int)loss))
         return false;
      //--- place kernel to the execution queue
      uint NDRange[] = { (uint)m_cOutputs.Total() };
      uint off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_CalcOutputGradient, 1, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating gradient through hidden layer             |
//+------------------------------------------------------------------+
bool CNeuronBase::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- adjust the input gradient to the derivative of the activation function
   if(!m_cActivation.Derivative(m_cGradients))
      return false;
//--- check buffers of the previous layer
   if(!prevLayer)
      return false;
   CBufferType *input_data = prevLayer.GetOutputs();
   CBufferType *input_gradient = prevLayer.GetGradients();
   if(!input_data || !input_gradient || input_data.Total() != input_gradient.Total())
      return false;
//--- check size correspondence between the source data buffer and the weight matrix
   if(!m_cWeights || m_cWeights.Cols() != (input_data.Total() + 1))
      return false;
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      MATRIX grad = m_cGradients.m_mMatrix.MatMul(m_cWeights.m_mMatrix);
      grad.Reshape(input_data.Rows(), input_data.Cols());
      input_gradient.m_mMatrix = grad;
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(input_gradient.GetIndex() < 0)
         return false;
      if(m_cGradients.GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient, def_hidgr_gradient_inputs, input_gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient, def_hidgr_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcHiddenGradient, def_hidgr_gradients, m_cGradients.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_CalcHiddenGradient, def_hidgr_outputs_total, (int)m_cGradients.Total()))
         return false;
      //--- place kernel to the execution queue
      uint NDRange[] = {(uint)input_data.Total()};
      uint off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_CalcHiddenGradient, 1, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating the error gradient to the weight matrix   |
//+------------------------------------------------------------------+
bool CNeuronBase::CalcDeltaWeights(CNeuronBase * prevLayer, bool read)
  {
//--- control block
   if(!prevLayer || !m_cDeltaWeights || !m_cGradients)
      return false;
   CBufferType *Inputs = prevLayer.GetOutputs();
   if(!Inputs)
      return false;
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      MATRIX m = Inputs.m_mMatrix;
      m.Resize(1, Inputs.Total() + 1);
      m[0, Inputs.Total()] = 1;
      m = m_cGradients.m_mMatrix.Transpose().MatMul(m);
      m_cDeltaWeights.m_mMatrix += m;
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(m_cGradients.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      if(Inputs.GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcDeltaWeights, def_delt_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcDeltaWeights, def_delt_inputs, Inputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_CalcDeltaWeights, def_delt_gradients, m_cGradients.GetIndex()))
         return false;
      //--- place kernel to the execution queue
      uint NDRange[] = {(uint)m_cGradients.Total(), (uint)Inputs.Total()};
      uint off_set[] = {0, 0};
      if(!m_cOpenCL.Execute(def_k_CalcDeltaWeights, 2, off_set, NDRange))
         return false;
      if(read && !m_cDeltaWeights.BufferRead())
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Weight matrix update method                                      |
//+------------------------------------------------------------------+
bool CNeuronBase::UpdateWeights(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda)
  {
//--- control block
   if(!m_cDeltaWeights || !m_cWeights || m_cWeights.Total() < m_cDeltaWeights.Total() || batch_size <= 0)
      return false;
//--- gradient branching depending on the activation function used
   bool result = false;
   switch(m_eOptimization)
     {
      case None:
         result = true;
         break;
      case SGD:
         result = SGDUpdate(batch_size, learningRate, Lambda);
         break;
      case MOMENTUM:
         result = MomentumUpdate(batch_size, learningRate, Beta, Lambda);
         break;
      case AdaGrad:
         result = AdaGradUpdate(batch_size, learningRate, Lambda);
         break;
      case RMSProp:
         result = RMSPropUpdate(batch_size, learningRate, Beta, Lambda);
         break;
      case AdaDelta:
         result = AdaDeltaUpdate(batch_size, Beta, Lambda);
         break;
      case Adam:
         result = AdamUpdate(batch_size, learningRate, Beta, Lambda);
         break;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|  Update the weight matrix using stochastic gradient descent      |
//+------------------------------------------------------------------+
bool CNeuronBase::SGDUpdate(int batch_size, TYPE learningRate, VECTOR &Lambda)
  {
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      TYPE lr = learningRate / ((TYPE)batch_size);
      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];
      m_cWeights.m_mMatrix += m_cDeltaWeights.m_mMatrix * lr;
      m_cDeltaWeights.m_mMatrix.Fill(0);
     }
   else
     {
      //--- check data buffers
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SGDUpdate, def_sgd_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_SGDUpdate, def_sgd_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_total, m_cWeights.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_batch_size, batch_size))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_learningRate, learningRate))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_Lambda1, Lambda[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_SGDUpdate, def_sgd_Lambda2, Lambda[1]))
         return false;
      //--- place kernel to the execution queue
      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_SGDUpdate, 1, off_set, NDRange))
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Update the weight matrix using the momentum method               |
//+------------------------------------------------------------------+
bool CNeuronBase::MomentumUpdate(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda)
  {
   if(Beta[0] == 0)
      return SGDUpdate(batch_size, learningRate, Lambda);
//--- control block
   if(!m_cMomenum[0])
      return false;
   if(m_cMomenum[0].Total() < m_cWeights.Total())
      return false;
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      TYPE lr = learningRate / ((TYPE)batch_size);
      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];
      m_cMomenum[0].m_mMatrix = m_cDeltaWeights.m_mMatrix * lr + m_cMomenum[0].m_mMatrix * Beta[0] ;
      m_cWeights.m_mMatrix += m_cMomenum[0].m_mMatrix;
      m_cDeltaWeights.m_mMatrix.Fill(0);
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      if(m_cMomenum[0].GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_MomentumUpdate, def_moment_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_MomentumUpdate, def_moment_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_MomentumUpdate, def_moment_momentum, m_cMomenum[0].GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_total, m_cWeights.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_batch_size, batch_size))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_learningRate, learningRate))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_Lambda1, Lambda[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_Lambda2, Lambda[1]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_MomentumUpdate, def_moment_beta, Beta[0]))
         return false;
      //--- place kernel to the execution queue
      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_MomentumUpdate, 1, off_set, NDRange))
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Updating the weight matrix using the AdaGrad method              |
//+------------------------------------------------------------------+
bool CNeuronBase::AdaGradUpdate(int batch_size, TYPE learningRate, VECTOR &Lambda)
  {
//--- control block
   if(!m_cMomenum[0])
      return false;
   if(m_cMomenum[0].Total() < m_cWeights.Total())
      return false;
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];
      MATRIX delta = m_cDeltaWeights.m_mMatrix / ((TYPE)batch_size);
      MATRIX G = m_cMomenum[0].m_mMatrix = m_cMomenum[0].m_mMatrix + delta.Power(2);
      G = MathPow(MathSqrt(G) + 1e-32, -1);
      G = G * learningRate;
      m_cWeights.m_mMatrix += G * delta;
      m_cDeltaWeights.m_mMatrix.Fill(0);
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      if(m_cMomenum[0].GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaGradUpdate, def_adagrad_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaGradUpdate, def_adagrad_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaGradUpdate, def_adagrad_momentum, m_cMomenum[0].GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_total, m_cWeights.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_batch_size, batch_size))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_learningRate, learningRate))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_Lambda1, Lambda[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaGradUpdate, def_adagrad_Lambda2, Lambda[1]))
         return false;
      //--- place kernel to the execution queue
      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_AdaGradUpdate, 1, off_set, NDRange))
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Updating the weight matrix using the RMSProp method              |
//+------------------------------------------------------------------+
bool CNeuronBase::RMSPropUpdate(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda)
  {
//--- control block
   if(!m_cMomenum[0])
      return false;
   if(m_cMomenum[0].Total() < m_cWeights.Total())
      return false;
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      TYPE lr = learningRate;
      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];
      MATRIX delta = m_cDeltaWeights.m_mMatrix / ((TYPE)batch_size);
      MATRIX G = m_cMomenum[0].m_mMatrix = m_cMomenum[0].m_mMatrix * Beta[0] + delta.Power(2) * (1 - Beta[0]);
      G = MathPow(MathSqrt(G) + 1e-32, -1);
      G = G * learningRate;
      m_cWeights.m_mMatrix += G * delta;
      m_cDeltaWeights.m_mMatrix.Fill(0);
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      if(m_cMomenum[0].GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_RMSPropUpdate, def_rms_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_RMSPropUpdate, def_rms_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_RMSPropUpdate, def_rms_momentum, m_cMomenum[0].GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_total, m_cWeights.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_batch_size, batch_size))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_learningRate, learningRate))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_Lambda1, Lambda[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_Lambda2, Lambda[1]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_RMSPropUpdate, def_rms_beta, Beta[0]))
         return false;
      //--- place kernel to the execution queue
      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_RMSPropUpdate, 1, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Updating the weight matrix using the AdaDelta method             |
//+------------------------------------------------------------------+
bool CNeuronBase::AdaDeltaUpdate(int batch_size, VECTOR &Beta, VECTOR &Lambda)
  {
//--- control block
   for(int i = 0; i < 2; i++)
     {
      if(!m_cMomenum[i])
         return false;
      if(m_cMomenum[i].Total() < m_cWeights.Total())
         return false;
     }
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      MATRIX delta = m_cDeltaWeights.m_mMatrix / ((TYPE)batch_size);
      MATRIX W = m_cMomenum[0].m_mMatrix = m_cMomenum[0].m_mMatrix * Beta[0]  + m_cWeights.m_mMatrix.Power(2) * (1 - Beta[0]);
      m_cMomenum[1].m_mMatrix = m_cMomenum[1].m_mMatrix * Beta[1] + delta.Power(2) * (1 - Beta[1]);
      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];
      W = MathSqrt(W) / (MathSqrt(m_cMomenum[1].m_mMatrix) + 1e-32);
      m_cWeights.m_mMatrix += W * delta;
      m_cDeltaWeights.m_mMatrix.Fill(0);
     }
   else // OpenCL block
     {
      //--- create data buffers
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      if(m_cMomenum[0].GetIndex() < 0)
         return false;
      if(m_cMomenum[1].GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaDeltaUpdate, def_adadelt_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaDeltaUpdate, def_adadelt_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaDeltaUpdate, def_adadelt_momentumW, m_cMomenum[0].GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdaDeltaUpdate, def_adadelt_momentumG, m_cMomenum[1].GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_total, m_cWeights.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_batch_size, batch_size))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_Lambda1, Lambda[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_Lambda2, Lambda[1]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_beta1, Beta[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdaDeltaUpdate, def_adadelt_beta2, Beta[1]))
         return false;
      //--- place kernel to the execution queue
      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_AdaDeltaUpdate, 1, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Updating the weight matrix using the Adam method                 |
//+------------------------------------------------------------------+
bool CNeuronBase::AdamUpdate(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda)
  {
//--- control block
   for(int i = 0; i < 2; i++)
     {
      if(!m_cMomenum[i])
         return false;
      if(m_cMomenum[i].Total() != m_cWeights.Total())
         return false;
     }
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      MATRIX delta = m_cDeltaWeights.m_mMatrix / ((TYPE)batch_size);
      m_cMomenum[0].m_mMatrix = m_cMomenum[0].m_mMatrix * Beta[0]  + delta * (1 - Beta[0]);
      m_cMomenum[1].m_mMatrix = m_cMomenum[1].m_mMatrix * Beta[1]  + MathPow(delta, 2) * (1 - Beta[1]);
      MATRIX M = m_cMomenum[0].m_mMatrix / (1 - Beta[0]);
      MATRIX V = m_cMomenum[1].m_mMatrix / (1 - Beta[1]);
      m_cWeights.m_mMatrix -= m_cWeights.m_mMatrix * Lambda[1] + Lambda[0];
      m_cWeights.m_mMatrix += M * learningRate  / MathSqrt(V);
      m_cDeltaWeights.m_mMatrix.Fill(0);
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      if(m_cMomenum[0].GetIndex() < 0)
         return false;
      if(m_cMomenum[1].GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdamUpdate, def_adam_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdamUpdate, def_adam_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdamUpdate, def_adam_momentumM, m_cMomenum[0].GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AdamUpdate, def_adam_momentumV, m_cMomenum[1].GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_total, (int)m_cWeights.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_batch_size, batch_size))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_Lambda1, Lambda[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_Lambda2, Lambda[1]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_beta1, Beta[0]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_beta2, Beta[1]))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AdamUpdate, def_adam_learningRate, learningRate))
         return false;
      //--- place kernel to the execution queue
      int NDRange[] = { (int)((m_cWeights.Total() + 3) / 4) };
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_AdamUpdate, 1, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNeuronBase::Save(const int file_handle)
  {
//--- control block
   if(file_handle == INVALID_HANDLE)
      return false;
//--- write data to the results buffer
   if(!m_cOutputs)
      return false;
   if(FileWriteInteger(file_handle, Type()) <= 0 ||
      FileWriteInteger(file_handle, (uint)m_cOutputs.Total()) <= 0)
      return false;
//--- check and write the source data layer flag
   if(!m_cActivation || !m_cWeights)
     {
      if(FileWriteInteger(file_handle, 1) <= 0)
         return false;
      return true;
     }
   if(FileWriteInteger(file_handle, 0) <= 0)
      return false;
   int momentums = 0;
   switch(m_eOptimization)
     {
      case SGD:
         momentums = 0;
         break;
      case MOMENTUM:
      case AdaGrad:
      case RMSProp:
         momentums = 1;
         break;
      case AdaDelta:
      case Adam:
         momentums = 2;
         break;
      default:
         return false;
         break;
     }
   for(int i = 0; i < momentums; i++)
      if(!m_cMomenum[i])
         return false;
//--- save the matrix of weighs, moments and activation function
   if(FileWriteInteger(file_handle, (int)m_eOptimization) <= 0 ||
      FileWriteInteger(file_handle, momentums) <= 0)
      return false;
   if(!m_cWeights.Save(file_handle) || !m_cActivation.Save(file_handle))
      return false;
   for(int i = 0; i < momentums; i++)
      if(!m_cMomenum[i].Save(file_handle))
         return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring class state from data in the file           |
//+------------------------------------------------------------------+
bool CNeuronBase::Load(const int file_handle)
  {
//--- control block
   if(file_handle == INVALID_HANDLE)
      return false;
//--- load the results buffer
   if(!m_cOutputs)
      if(!(m_cOutputs = new CBufferType()))
         return false;
   int outputs = FileReadInteger(file_handle);
   if(!m_cOutputs.BufferInit(1, outputs, 0))
      return false;
//--- create an error gradient buffer
   if(!m_cGradients)
      if(!(m_cGradients = new CBufferType()))
         return false;
   if(!m_cGradients.BufferInit(1, outputs, 0))
      return false;
//--- check the source data layer flag
   int input_layer = FileReadInteger(file_handle);
   if(input_layer == 1)
     {
      if(m_cActivation)
         delete m_cActivation;
      if(m_cWeights)
         delete m_cWeights;
      if(m_cDeltaWeights)
         delete m_cDeltaWeights;
      if(m_cMomenum[0])
         delete m_cMomenum[0];
      if(m_cMomenum[1])
         delete m_cMomenum[1];
      if(m_cOpenCL)
         if(!m_cOutputs.BufferCreate(m_cOpenCL))
            return false;
      m_eOptimization = None;
      return true;
     }
//---
   m_eOptimization = (ENUM_OPTIMIZATION)FileReadInteger(file_handle);
   int momentums = FileReadInteger(file_handle);
//--- create objects before loading data
   if(!m_cWeights)
      if(!(m_cWeights = new CBufferType()))
         return false;
//--- load data from the file
   if(!m_cWeights.Load(file_handle))
      return false;
//--- activation function
   if(FileReadInteger(file_handle) != defActivation)
      return false;
   ENUM_ACTIVATION_FUNCTION activation = (ENUM_ACTIVATION_FUNCTION)FileReadInteger(file_handle);
   if(!SetActivation(activation, VECTOR::Zeros(2)))
      return false;
   if(!m_cActivation.Load(file_handle))
      return false;
//---
   for(int i = 0; i < momentums; i++)
     {
      if(!m_cMomenum[i])
         if(!(m_cMomenum[i] = new CBufferType()))
            return false;
      if(!m_cMomenum[i].Load(file_handle))
         return false;
     }
//--- initialize the remaining buffers
   if(!m_cDeltaWeights)
      if(!(m_cDeltaWeights = new CBufferType()))
         return false;
   if(!m_cDeltaWeights.BufferInit(m_cWeights.m_mMatrix.Rows(), m_cWeights.m_mMatrix.Cols(), 0))
      return false;
//--- pass pointer to an OpenCL object to objects
   SetOpenCL(m_cOpenCL);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBase::SetOutputs(CBufferType * buffer, bool delete_prevoius = true)
  {
   if(!buffer)
      return false;
//---
   if(delete_prevoius)
      if(!!m_cOutputs)
         delete m_cOutputs;
   m_cOutputs = buffer;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronBase::SetActivation(ENUM_ACTIVATION_FUNCTION function, VECTOR &params)
  {
   if(m_cActivation)
      delete m_cActivation;
   switch(function)
     {
      case AF_LINEAR:
         if(!(m_cActivation = new CActivationLine()))
            return false;
         break;
      case AF_SIGMOID:
         if(!(m_cActivation = new CActivationSigmoid()))
            return false;
         break;
      case AF_LRELU:
         if(!(m_cActivation = new CActivationLReLU()))
            return false;
         break;
      case AF_TANH:
         if(!(m_cActivation = new CActivationTANH()))
            return false;
         break;
      case AF_SOFTMAX:
         if(!(m_cActivation = new CActivationSoftMAX()))
            return false;
         break;
      case AF_SWISH:
         if(!(m_cActivation = new CActivationSwish()))
            return false;
         break;
      default:
         if(!(m_cActivation = new CActivation()))
            return false;
         break;
     }
   if(!m_cActivation.Init(params))
      return false;
   m_cActivation.SetOpenCL(m_cOpenCL, m_cOutputs.Rows(), m_cOutputs.Cols());
   return true;
  }
//+------------------------------------------------------------------+
