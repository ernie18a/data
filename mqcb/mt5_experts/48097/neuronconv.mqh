//+------------------------------------------------------------------+
//|                                                   NeuronConv.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include "neuronproof.mqh"
//+------------------------------------------------------------------+
//| Class CNeuronConv                                                |
//| Purpose: Class organizing the convolutional layer                |
//+------------------------------------------------------------------+
class CNeuronConv    :  public CNeuronProof
  {
protected:
   bool              m_bTransposedOutput;
public:
                     CNeuronConv(void) {m_bTransposedOutput = false;};
                    ~CNeuronConv(void) {};
   //---
   virtual bool      Init(const CLayerDescription *desc) override;
   virtual bool      FeedForward(CNeuronBase *prevLayer) override;
   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;
   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override;
   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,
                                   VECTOR &Beta, VECTOR &Lambda) override
     {
      return CNeuronBase::UpdateWeights(batch_size,
                                        learningRate,
                                        Beta,
                                        Lambda);
     }
   //---
   virtual CBufferType*  GetWeights(void) override   const { return(m_cWeights);     }
   virtual CBufferType*  GetDeltaWeights(void) override const { return(m_cDeltaWeights);}
   bool              SetTransposedOutput(const bool value);
   //--- file handling methods
   virtual bool      Save(const int file_handle) override;
   virtual bool      Load(const int file_handle) override;
   //--- object identification method
   virtual int       Type(void) override       const { return(defNeuronConv); }
  };
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronConv::Init(const CLayerDescription *desc)
  {
//--- control block
   if(!desc || desc.type != Type() || desc.count <= 0 || desc.window <= 0)
      return false;
//--- save constants
   m_iWindow = desc.window;
   m_iStep = desc.step;
   m_iWindowOut = desc.window_out;
   m_iNeurons = desc.count;
//--- save the parameter optimization method and the result tensor transposition flag
   m_eOptimization = desc.optimization;
   m_bTransposedOutput = (desc.probability != 0);
//--- initialize the results buffer
   if(!m_cOutputs)
      if(!(m_cOutputs = new CBufferType()))
         return false;
//--- initialize the error gradient buffer
   if(!m_cGradients)
      if(!(m_cGradients = new CBufferType()))
         return false;
   if(m_bTransposedOutput)
     {
      if(!m_cOutputs.BufferInit(m_iNeurons, m_iWindowOut, 0))
         return false;
      if(!m_cGradients.BufferInit(m_iNeurons, m_iWindowOut, 0))
         return false;
     }
   else
     {
      if(!m_cOutputs.BufferInit(m_iWindowOut, m_iNeurons, 0))
         return false;
      if(!m_cGradients.BufferInit(m_iWindowOut, m_iNeurons, 0))
         return false;
     }
//--- initialize the activation function class
   VECTOR params = desc.activation_params;
   if(!SetActivation(desc.activation, params))
      return false;
//--- initialize the weight matrix buffer
   if(!m_cWeights)
      if(!(m_cWeights = new CBufferType()))
         return false;
   if(!m_cWeights.BufferInit(desc.window_out, desc.window + 1))
      return false;
   double weights[];
   double sigma = desc.activation == AF_LRELU ?
                  2.0 / (double)(MathPow(1 + desc.activation_params[0], 2) * desc.window) :
                  1.0 / (double)desc.window;
   if(!MathRandomNormal(0, MathSqrt(sigma), (uint)m_cWeights.Total(), weights))
      return false;
   for(uint i = 0; i < m_cWeights.Total(); i++)
      if(!m_cWeights.m_mMatrix.Flat(i, (TYPE)weights[i]))
         return false;
//--- initialize the gradient buffer at the weight matrix level
   if(!m_cDeltaWeights)
      if(!(m_cDeltaWeights = new CBufferType()))
         return false;
   if(!m_cDeltaWeights.BufferInit(desc.window_out, desc.window + 1, 0))
      return false;
//--- initialize moment buffers
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
         if(!m_cMomenum[0].BufferInit(desc.window_out, desc.window + 1, 0))
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
                  return false;
            if(!m_cMomenum[i].BufferInit(desc.window_out, desc.window + 1, 0))
               return false;
           }
         break;
      default:
         return false;
         break;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronConv::FeedForward(CNeuronBase *prevLayer)
  {
//--- control block
   if(!prevLayer || !m_cOutputs || !m_cWeights || !prevLayer.GetOutputs())
      return false;
   CBufferType *input_data = prevLayer.GetOutputs();
   ulong total = input_data.Total();
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      MATRIX m;
      if(m_iWindow == m_iStep && total == (m_iNeurons * m_iWindow))
        {
         m = input_data.m_mMatrix;
         if(!m.Reshape(m_iNeurons, m_iWindow))
            return false;
        }
      else
        {
         if(!m.Init(m_iNeurons, m_iWindow))
            return false;
         for(ulong r = 0; r < m_iNeurons; r++)
           {
            ulong shift = r * m_iStep;
            for(ulong c = 0; c < m_iWindow; c++)
              {
               ulong k = shift + c;
               m[r, c] = (k < total ? input_data.At((uint)k) : 0);
              }
           }
        }
      //--- add a bias column
      if(!m.Resize(m.Rows(), m_iWindow + 1) ||
         !m.Col(VECTOR::Ones(m_iNeurons), m_iWindow))
         return false;
      //--- Calculate the weighted sum of elements of the input window
      if(m_bTransposedOutput)
         m = m.MatMul(m_cWeights.m_mMatrix.Transpose());
      else
         m = m_cWeights.m_mMatrix.MatMul(m.Transpose());
      m_cOutputs.m_mMatrix = m;
     }
   else
     {
      //--- check data buffers
      if(input_data.GetIndex() < 0)
         return false;
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(m_cOutputs.GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionFeedForward, def_cff_inputs, input_data.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionFeedForward, def_cff_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionFeedForward, def_cff_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward, def_cff_inputs_total, (int)input_data.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward, def_cff_window, m_iWindow))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward, def_cff_step, m_iStep))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward, def_cff_window_out, m_iWindowOut))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionFeedForward, def_cff_transposed_out, (int)m_bTransposedOutput))
         return false;
      //--- place kernel to the execution queue
      int off_set[] = {0};
      int NDRange[] = {(int)m_iNeurons};
      if(!m_cOpenCL.Execute(def_k_ConvolutionFeedForward, 1, off_set, NDRange))
         return false;
     }
   if(!m_cActivation.Activation(m_cOutputs))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating error gradient through hidden layer       |
//+------------------------------------------------------------------+
bool CNeuronConv::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- control block
   if(!prevLayer || !prevLayer.GetOutputs() || !prevLayer.GetGradients() || !m_cGradients || !m_cWeights)
      return false;
//--- adjust error gradients to the derivative of the activation function
   if(m_cActivation)
     {
      if(!m_cActivation.Derivative(m_cGradients))
         return false;
     }
//--- branching of the algorithm depending on the device used for performing operations
   CBufferType* input_gradient = prevLayer.GetGradients();
   if(!m_cOpenCL)
     {
      MATRIX g = m_cGradients.m_mMatrix;
      if(m_bTransposedOutput)
        {
         if(!g.Reshape(m_iNeurons, m_iWindowOut))
            return false;
        }
      else
        {
         if(!g.Reshape(m_iWindowOut, m_iNeurons))
            return false;
         g = g.Transpose();
        }
      g = g.MatMul(m_cWeights.m_mMatrix);
      if(!g.Resize(m_iNeurons, m_iWindow))
         return false;
      if(m_iWindow == m_iStep && input_gradient.Total() == (m_iNeurons * m_iWindow))
        {
         if(!g.Reshape(input_gradient.Rows(), input_gradient.Cols()))
            return false;
         input_gradient.m_mMatrix = g;
        }
      else
        {
         input_gradient.m_mMatrix.Fill(0);
         ulong total = input_gradient.Total();
         for(ulong r = 0; r < m_iNeurons; r++)
           {
            ulong shift = r * m_iStep;
            for(ulong c = 0; c < m_iWindow; c++)
              {
               ulong k = shift + c;
               if(k >= total)
                  break;
               if(!input_gradient.m_mMatrix.Flat(k, input_gradient.m_mMatrix.Flat(k) + g[r, c]))
                  return false;
              }
           }
        }
     }
   else // OpenCL operations block
     {
      //--- check data buffers
      if(m_cWeights.GetIndex() < 0)
         return false;
      if(input_gradient.GetIndex() < 0)
         return false;
      if(m_cGradients.GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionHiddenGradients, def_convhgr_gradient_inputs, input_gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionHiddenGradients, def_convhgr_weights, m_cWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionHiddenGradients, def_convhgr_gradients, m_cGradients.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients, def_convhgr_neurons, m_iNeurons))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients, def_convhgr_window, m_iWindow))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients, def_convhgr_step, m_iStep))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients, def_convhgr_window_out, m_iWindowOut))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionHiddenGradients, def_convhgr_transposed_out, (int)m_bTransposedOutput))
         return false;
      //--- place kernel to the execution queue
      int NDRange[] = {(int)input_gradient.Total()};
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_ConvolutionHiddenGradients, 1, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating the error gradient to the weight matrix   |
//+------------------------------------------------------------------+
bool CNeuronConv::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)
  {
//--- control block
   if(!prevLayer || !prevLayer.GetOutputs() || !m_cGradients || !m_cDeltaWeights)
      return false;
//--- branching of the algorithm depending on the device used for performing operations
   CBufferType *input_data = prevLayer.GetOutputs();
   if(!m_cOpenCL)
     {
      MATRIX inp;
      ulong input_total = input_data.Total();
      if(m_iWindow == m_iStep && input_total == (m_iNeurons * m_iWindow))
        {
         inp = input_data.m_mMatrix;
         if(!inp.Reshape(m_iNeurons, m_iWindow))
            return false;
        }
      else
        {
         if(!inp.Init(m_iNeurons, m_iWindow))
            return false;
         for(ulong r = 0; r < m_iNeurons; r++)
           {
            ulong shift = r * m_iStep;
            for(ulong c = 0; c < m_iWindow; c++)
              {
               ulong k = shift + c;
               inp[r, c] = (k < input_total ? input_data.At((uint)k) : 0);
              }
           }
        }
      //--- add a bias column
      if(!inp.Resize(inp.Rows(), m_iWindow + 1) ||
         !inp.Col(VECTOR::Ones(m_iNeurons), m_iWindow))
         return false;
      //---
      MATRIX g = m_cGradients.m_mMatrix;
      if(m_bTransposedOutput)
        {
         if(!g.Reshape(m_iNeurons, m_iWindowOut))
            return false;
         g = g.Transpose();
        }
      else
        {
         if(!g.Reshape(m_iWindowOut, m_iNeurons))
            return false;
        }
      m_cDeltaWeights.m_mMatrix += g.MatMul(inp);
     }
   else // OpenCL operations block
     {
      //--- check data buffers
      if(m_cGradients.GetIndex() < 0)
         return false;
      if(m_cDeltaWeights.GetIndex() < 0)
         return false;
      if(input_data.GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionDeltaWeights, def_convdelt_delta_weights, m_cDeltaWeights.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionDeltaWeights, def_convdelt_inputs, input_data.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ConvolutionDeltaWeights, def_convdelt_gradients, m_cGradients.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionDeltaWeights, def_convdelt_inputs_total, (int)input_data.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionDeltaWeights, def_convdelt_neurons, m_iNeurons))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionDeltaWeights, def_convdelt_step, m_iStep))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ConvolutionDeltaWeights, def_convdelt_transposed_out, (int)m_bTransposedOutput))
         return false;
      //--- place kernel to the execution queue
      uint NDRange[] = {m_iWindow + 1, m_iWindowOut};
      uint off_set[] = {0, 0};
      if(!m_cOpenCL.Execute(def_k_ConvolutionDeltaWeights, 2, off_set, NDRange))
         return false;
      if(read && !m_cDeltaWeights.BufferRead())
        return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNeuronConv::Save(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronBase::Save(file_handle))
      return false;
//--- save constant values
   if(FileWriteInteger(file_handle, (int)m_iWindow) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_iStep) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_iWindowOut) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_iNeurons) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_bTransposedOutput) <= 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from a file                       |
//+------------------------------------------------------------------+
bool CNeuronConv::Load(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronBase::Load(file_handle))
      return false;
//--- read constant values
   m_iWindow = (uint)FileReadInteger(file_handle);
   m_iStep = (uint)FileReadInteger(file_handle);
   m_iWindowOut = (uint)FileReadInteger(file_handle);
   m_iNeurons = (uint)FileReadInteger(file_handle);
   m_bTransposedOutput = (bool)FileReadInteger(file_handle);
   m_eActivation = -1;
//---
   if(m_bTransposedOutput)
     {
      if(!m_cOutputs.Reshape(m_iNeurons, m_iWindowOut))
         return false;
      if(!m_cGradients.Reshape(m_iNeurons, m_iWindowOut))
         return false;
     }
   else
     {
      if(!m_cOutputs.Reshape(m_iWindowOut, m_iNeurons))
         return false;
      if(!m_cGradients.Reshape(m_iWindowOut, m_iNeurons))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronConv::SetTransposedOutput(const bool value)
  {
   m_bTransposedOutput = value;
   if(value)
     {
      if(!m_cOutputs.BufferInit(m_iNeurons, m_iWindowOut, 0))
         return false;
      if(!m_cGradients.BufferInit(m_iNeurons, m_iWindowOut, 0))
         return false;
     }
   else
     {
      if(!m_cOutputs.BufferInit(m_iWindowOut, m_iNeurons, 0))
         return false;
      if(!m_cGradients.BufferInit(m_iWindowOut, m_iNeurons, 0))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
