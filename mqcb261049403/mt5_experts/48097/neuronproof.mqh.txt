//+------------------------------------------------------------------+
//|                                                  NeuronProof.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include "neuronbase.mqh"
#include <Math\Stat\Math.mqh>
//+------------------------------------------------------------------+
//| Class CNeuronProof                                               |
//| Purpose: Class organizing the pooling layer                      |
//+------------------------------------------------------------------+
class CNeuronProof    :  public CNeuronBase
  {
protected:
   uint              m_iWindow;             //Window size at the input of the neural layer
   uint              m_iStep;               //Input window step size
   uint              m_iNeurons;            //Output size of one filter
   uint              m_iWindowOut;          //Number of filters
   ENUM_PROOF        m_eActivation;         //Activation function
public:
                     CNeuronProof(void);
                    ~CNeuronProof(void) {};
   //---
   virtual bool      Init(const CLayerDescription *desc) override;
   virtual bool      FeedForward(CNeuronBase *prevLayer) override;
   virtual bool      CalcOutputGradient(CBufferType *target, ENUM_LOSS_FUNCTION loss) override { return false;}
   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;
   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override  { return true; }
   virtual bool      UpdateWeights(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda) override
                      { return true; }
   //---
   virtual CBufferType     *GetWeights(void) override       const {  return(NULL);           }
   virtual CBufferType     *GetDeltaWeights(void) override  const {  return(NULL);           }
   virtual uint      GetNeurons(void)                       const {  return m_iNeurons;  }
   //--- File handling methods
   virtual bool      Save(const int file_handle) override;
   virtual bool      Load(const int file_handle) override;
   //--- Object identification method
   virtual int       Type(void) override               const { return(defNeuronProof); }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNeuronProof::CNeuronProof(void) :  m_eActivation(AF_MAX_POOLING),
   m_iWindow(2),
   m_iStep(1),
   m_iWindowOut(1),
   m_iNeurons(0)
  {
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronProof::Init(const CLayerDescription *description)
  {
//--- Control block
   if(!description || description.type != Type() ||
      description.count <= 0)
      return false;
//--- Save constants
   m_iWindow = description.window;
   m_iStep = description.step;
   m_iWindowOut = description.window_out;
   m_iNeurons = description.count;
   if(m_iWindow <= 0 || m_iStep <= 0 || m_iWindowOut <= 0 || m_iNeurons <= 0)
      return false;
//--- Check activation function
   switch((ENUM_PROOF)description.activation)
     {
      case AF_AVERAGE_POOLING:
      case AF_MAX_POOLING:
         m_eActivation = (ENUM_PROOF)description.activation;
         break;
      default:
         return false;
         break;
     }
//--- Initialize results buffer
   if(!m_cOutputs)
      if(!(m_cOutputs = new CBufferType()))
         return false;
   if(!m_cOutputs.BufferInit(m_iWindowOut, m_iNeurons, 0))
      return false;
//--- Initialize the error gradient buffer
   if(!m_cGradients)
      if(!(m_cGradients = new CBufferType()))
         return false;
   if(!m_cGradients.BufferInit(m_iWindowOut, m_iNeurons, 0))
      return false;
//---
   m_eOptimization = None;
//--- Delete unused objects
   if(!!m_cActivation)
      delete m_cActivation;
   if(!!m_cWeights)
      delete m_cWeights;
   if(!!m_cDeltaWeights)
      delete m_cDeltaWeights;
   for(int i = 0; i < 2; i++)
      if(!!m_cMomenum[i])
         delete m_cMomenum[i];
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronProof::FeedForward(CNeuronBase *prevLayer)
  {
//--- Control block
   if(!prevLayer || !m_cOutputs ||
      !prevLayer.GetOutputs())
      return false;
   CBufferType *input_data = prevLayer.GetOutputs();
//---  Branching of the algorithm depending on the device used for operations
   if(!m_cOpenCL)
     {
      MATRIX inputs = input_data.m_mMatrix;
      if(inputs.Rows() != m_iWindowOut)
        {
         ulong cols = (input_data.Total() + m_iWindowOut - 1) / m_iWindowOut;
         if(!inputs.Reshape(m_iWindowOut, cols))
            return false;
        }
      //--- Create a local matrix to collect data from one filter
      MATRIX array = MATRIX::Zeros(m_iNeurons, m_iWindow);
      m_cOutputs.m_mMatrix.Fill(0);
      //--- Filter iteration loop
      for(uint f = 0; f < m_iWindowOut; f++)
        {
         //--- Loop through the elements of the results buffer
         for(uint o = 0; o < m_iNeurons; o++)
           {
            uint shift = o * m_iStep;
            for(uint i = 0; i < m_iWindow; i++)
               array[o, i] = ((shift + i) >= inputs.Cols() ? 0 :
                              inputs[f, shift + i]);
           }
         //--- Save the current result in accordance with the activation function
         switch(m_eActivation)
           {
            case AF_MAX_POOLING:
               if(!m_cOutputs.Row(array.Max(1), f))
                  return false;;
               break;
            case AF_AVERAGE_POOLING:
               if(!m_cOutputs.Row(array.Mean(1), f))
                  return false;
               break;
            default:
               return false;
           }
        }
     }
   else // OpenCL operations block
     {
      //--- check the presence of buffers in the OpenCL context
      if(input_data.GetIndex() < 0)
         return false;
      if(m_cOutputs.GetIndex() < 0)
         return false;
      //--- Pass parameters to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofFeedForward, def_prff_inputs, input_data.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofFeedForward, def_prff_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_inputs_total, input_data.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_window, m_iWindow))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_step, m_iStep))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_activation, (int)m_eActivation))
         return false;
      ulong input_neurons = (input_data.Total() + m_iWindowOut - 1) / m_iWindowOut;
      if(!m_cOpenCL.SetArgument(def_k_ProofFeedForward, def_prff_input_neurons, input_neurons))
         return false;
      //--- Place kernel to the execution queue
      uint off_set[] = {0, 0};
      uint NDRange[] = {m_iNeurons, m_iWindowOut};
      if(!m_cOpenCL.Execute(def_k_ProofFeedForward, 2, off_set, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating error gradient through hidden layer       |
//+------------------------------------------------------------------+
bool CNeuronProof::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- Control block
   if(!prevLayer || !m_cOutputs ||
      !m_cGradients || !prevLayer.GetOutputs() ||
      !prevLayer.GetGradients())
      return false;
   CBufferType *input_data = prevLayer.GetOutputs();
   CBufferType *input_gradient = prevLayer.GetGradients();
   if(!input_gradient.BufferInit(input_data.Rows(), input_data.Cols(), 0))
      return false;
//---  Branching of the algorithm depending on the device used for operations
   if(!m_cOpenCL)
     {
      MATRIX inputs = input_data.m_mMatrix;
      ulong cols = (input_data.Total() + m_iWindowOut - 1) / m_iWindowOut;
      if(inputs.Rows() != m_iWindowOut)
        {
         if(!inputs.Reshape(m_iWindowOut, cols))
            return false;
        }
      //--- Create a local matrix to collect data from one filter
      MATRIX inputs_grad = MATRIX::Zeros(m_iWindowOut, cols);
      //--- Filter iteration loop
      for(uint f = 0; f < m_iWindowOut; f++)
        {
         //--- Loop through the elements of the results buffer
         for(uint o = 0; o < m_iNeurons; o++)
           {
            uint shift = o * m_iStep;
            TYPE out = m_cOutputs.m_mMatrix[f, o];
            TYPE gradient = m_cGradients.m_mMatrix[f, o];
            //--- Transfer gradient in accordance with the activation function
            switch(m_eActivation)
              {
               case AF_MAX_POOLING:
                  for(uint i = 0; i < m_iWindow; i++)
                    {
                     if((shift + i) >= cols)
                        break;
                     if(inputs[f, shift + i] == out)
                       {
                        inputs_grad[f, shift + i] += gradient;
                        break;
                       }
                    }
                  break;
               case AF_AVERAGE_POOLING:
                  gradient /= (TYPE)m_iWindow;
                  for(uint i = 0; i < m_iWindow; i++)
                    {
                     if((shift + i) >= cols)
                        break;
                     inputs_grad[f, shift + i] += gradient;
                    }
                  break;
               default:
                  return false;
              }
           }
        }
      //--- copy the gradient matrix to the buffer of the previous neural layer
      if(!inputs_grad.Reshape(input_gradient.Rows(), input_gradient.Cols()))
         return false;
      input_gradient.m_mMatrix = inputs_grad;
     }
   else    // OpenCL operation block
     {
      //--- check the presence of buffers in the OpenCL context
      if(input_data.GetIndex() < 0)
         return false;
      if(m_cOutputs.GetIndex() < 0)
         return false;
      if(input_gradient.GetIndex() < 0)
         return false;
      if(m_cGradients.GetIndex() < 0)
         return false;
      //--- Pass parameters to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofHiddenGradients, def_prhgr_inputs, input_data.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofHiddenGradients, def_prhgr_outputs, m_cOutputs.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofHiddenGradients, def_prhgr_gradients, m_cGradients.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_ProofHiddenGradients, def_prhgr_gradient_inputs, input_gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients, def_prhgr_inputs_total, input_data.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients, def_prhgr_window, m_iWindow))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients, def_prhgr_step, m_iStep))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients, def_prhgr_activation, (int)m_eActivation))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients, def_prhgr_neurons, m_iNeurons))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_ProofHiddenGradients, def_prhgr_outputs_total, m_cOutputs.Total()))
         return false;
      //--- Place kernel to the execution queue
      ulong input_neurons = (input_data.Total() + m_iWindowOut - 1) / m_iWindowOut;
      uint off_set[] = {0, 0};
      uint NDRange[] = {(uint)input_neurons, m_iWindowOut};
      if(!m_cOpenCL.Execute(def_k_ProofHiddenGradients, 2, off_set, NDRange))
         return false;
      input_gradient.BufferRead();
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNeuronProof::Save(const int file_handle)
  {
//--- Control block
   if(file_handle == INVALID_HANDLE)
      return false;
//--- Save constants
   if(FileWriteInteger(file_handle, Type()) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_iWindow) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_iStep) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_iWindowOut) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_iNeurons) <= 0)
      return false;
   if(FileWriteInteger(file_handle, (int)m_eActivation) <= 0)
      return false;
//--- Successful completion of the method
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from a file                       |
//+------------------------------------------------------------------+
bool CNeuronProof::Load(const int file_handle)
  {
//--- Control block
   if(file_handle == INVALID_HANDLE)
      return false;
//--- Load constants
   m_iWindow = (uint)FileReadInteger(file_handle);
   m_iStep = (uint)FileReadInteger(file_handle);
   m_iWindowOut = (uint)FileReadInteger(file_handle);
   m_iNeurons = (uint)FileReadInteger(file_handle);
   m_eActivation = (ENUM_PROOF)FileReadInteger(file_handle);
//--- Initialize and load the results buffer
   if(!m_cOutputs)
     {
      m_cOutputs = new CBufferType();
      if(!m_cOutputs)
         return false;
     }
   if(!m_cOutputs.BufferInit(m_iWindowOut, m_iNeurons, 0))
      return false;
//--- Initialize and load the error gradient buffer
   if(!m_cGradients)
     {
      m_cGradients = new CBufferType();
      if(!m_cGradients)
         return false;
     }
   if(!m_cGradients.BufferInit(m_iWindowOut, m_iNeurons, 0))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
