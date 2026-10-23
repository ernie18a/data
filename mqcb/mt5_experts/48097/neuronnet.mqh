//+------------------------------------------------------------------+
//|                                                    NeuronNet.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include "arraylayers.mqh"
#include "positionencoder.mqh"
//+------------------------------------------------------------------+
//| Class CNet                                                       |
//| Purpose: Basic dispatcher class for implementing the operation   |
//| of the neural network                                            |
//+------------------------------------------------------------------+
class CNet  : public CObject
  {
protected:
   bool              m_bTrainMode;
   CArrayLayers*     m_cLayers;
   CMyOpenCL*        m_cOpenCL;
   bool              m_bOpenCL;
   TYPE              m_dNNLoss;
   int               m_iLossSmoothFactor;
   CPositionEncoder* m_cPositionEncoder;
   bool              m_bPositionEncoder;
   ENUM_LOSS_FUNCTION m_eLossFunction;
   VECTOR            m_adLambda;
   TYPE              m_dLearningRate;
   VECTOR            m_adBeta;

public:
                     CNet(void);
                    ~CNet(void);
   //--- Methods for creating an object
   bool              Create(CArrayObj *descriptions);
   bool              Create(CArrayObj *descriptions, TYPE learning_rate,
                            TYPE beta1, TYPE beta2);
   bool              Create(CArrayObj *descriptions, ENUM_LOSS_FUNCTION loss_function,
                            TYPE lambda1, TYPE lambda2);
   bool              Create(CArrayObj *descriptions, TYPE learning_rate, TYPE beta1,
                            TYPE beta2, ENUM_LOSS_FUNCTION loss_function, TYPE lambda1,
                            TYPE lambda2);
   //--- Implementing work with OpenCL
   void              UseOpenCL(bool value);
   bool              UseOpenCL(void)                   const { return(m_bOpenCL);          }
   bool              InitOpenCL(void);
   //--- Methods of working with positional encoding
   void              UsePositionEncoder(bool value);
   bool              UsePositionEncoder(void)          const { return(m_bPositionEncoder); }
   //--- Organization of the main algorithms for the model
   bool              FeedForward(const CBufferType *inputs);
   bool              Backpropagation(CBufferType *target);
   bool              UpdateWeights(uint batch_size = 1);
   bool              GetResults(CBufferType *&result);
   void              SetLearningRates(TYPE learning_rate, TYPE beta1 = defBeta1,
                                      TYPE beta2 = defBeta2);
   //--- Loss function methods
   bool              LossFunction(ENUM_LOSS_FUNCTION loss_function, TYPE lambda1 = defLambdaL1,
                                  TYPE lambda2 = defLambdaL2);
   ENUM_LOSS_FUNCTION LossFunction(void)    const { return(m_eLossFunction);}
   ENUM_LOSS_FUNCTION LossFunction(TYPE &lambda1, TYPE &lambda2);
   TYPE              GetRecentAverageLoss(void)        const { return(m_dNNLoss);          }
   void              LossSmoothFactor(int value)             { m_iLossSmoothFactor = value;}
   int               LossSmoothFactor(void)            const { return(m_iLossSmoothFactor);}
   //--- Model operating mode control
   bool              TrainMode(void)                   const { return m_bTrainMode;        }
   void              TrainMode(bool mode);
   //--- File handling methods
   virtual bool      Save(string file_name = NULL);
   virtual bool      Save(const int file_handle);
   virtual bool      Load(string file_name = NULL, bool common = false);
   virtual bool      Load(const int file_handle);
   //--- Object identification method
   virtual int       Type(void)                        const { return(defNeuronNet);      }
   //--- Get pointers to internal objects
   virtual CBufferType *GetGradient(uint layer)   const;
   virtual CBufferType *GetWeights(uint layer)   const;
   virtual CBufferType *GetDeltaWeights(uint layer)   const;
   virtual int       GetGPTUnits(void);
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNet::CNet(void)     :  m_bTrainMode(false),
                        m_bOpenCL(false),
                        m_bPositionEncoder(false),
                        m_dNNLoss(-1),
                        m_iLossSmoothFactor(defLossSmoothFactor),
                        m_dLearningRate(defLearningRate),
                        m_eLossFunction(LOSS_MSE)
  {
   m_adLambda.Init(2);
   m_adBeta.Init(2);
   m_adLambda[0] = defLambdaL1;
   m_adLambda[1] = defLambdaL2;
   m_adBeta[0] = defBeta1;
   m_adBeta[1] = defBeta2;
   m_cLayers = new CArrayLayers();
   m_cOpenCL = new CMyOpenCL();
   m_cPositionEncoder = new CPositionEncoder();
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CNet::~CNet(void)
  {
   if(!!m_cLayers)
      delete m_cLayers;
   if(!!m_cPositionEncoder)
      delete m_cPositionEncoder;
   if(!!m_cOpenCL)
      delete m_cOpenCL;
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNet::Create(CArrayObj *descriptions)
  {
//--- Control block
   if(!descriptions)
      return false;
//--- Check the number of layers being created
   int total = descriptions.Total();
   if(total < 2)
      return false;
//--- Initialize OpenCL objects
   if(m_bOpenCL)
      m_bOpenCL = InitOpenCL();
   if(!m_cLayers.SetOpencl(m_cOpenCL))
      m_bOpenCL = false;
//--- Organize a loop to create neural layers
   for(int i = 0; i < total; i++)
     {
      CLayerDescription *temp = descriptions.At(i);
      if(!temp)
         return false;
      if(i == 0)
        {
         if(temp.type != defNeuronBase)
            return false;
         temp.window = 0;
        }
      else
        {
         CLayerDescription *prev = descriptions.At(i - 1);
         if(temp.window <= 0 || temp.window > prev.count || temp.type == defNeuronBase)
           {
            switch(prev.type)
              {
               case defNeuronConv:
               case defNeuronProof:
                  temp.window = prev.count * prev.window_out;
                  break;
               case defNeuronAttention:
               case defNeuronMHAttention:
                  temp.window = prev.count * prev.window;
                  break;
               case defNeuronGPT:
                  temp.window = prev.window;
                  break;
               default:
                  temp.window = prev.count;
                  break;
              }
            switch(temp.type)
              {
               case defNeuronAttention:
               case defNeuronMHAttention:
               case defNeuronGPT:
                  break;
               default:
                  temp.step = 0;
              }
           }
        }
      if(!m_cLayers.CreateElement(i, temp))
         return false;
     }
//--- Initialize positional encoding objects
   if(m_bPositionEncoder)
     {
      if(!m_cPositionEncoder)
        {
         m_cPositionEncoder = new CPositionEncoder();
         if(!m_cPositionEncoder)
            m_bPositionEncoder = false;
         return true;
        }
      CLayerDescription *temp = descriptions.At(0);
      if(!m_cPositionEncoder.InitEncoder(temp.count, temp.window))
         UsePositionEncoder(false);
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNet::Create(CArrayObj *descriptions,
                  TYPE learning_rate,
                  TYPE beta1, TYPE beta2,
                  ENUM_LOSS_FUNCTION loss_function, TYPE lambda1, TYPE lambda2)
  {
   if(!Create(descriptions))
      return false;
   SetLearningRates(learning_rate, beta1, beta2);
   if(!LossFunction(loss_function, lambda1, lambda2))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNet::Create(CArrayObj *descriptions, ENUM_LOSS_FUNCTION loss_function, TYPE lambda1, TYPE lambda2)
  {
   if(!Create(descriptions))
      return false;
   if(!LossFunction(loss_function, lambda1, lambda2))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNet::Create(CArrayObj *descriptions,
                  TYPE learning_rate,
                  TYPE beta1, TYPE beta2)
  {
   if(!Create(descriptions))
      return false;
   SetLearningRates(learning_rate, beta1, beta2);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNet::FeedForward(const CBufferType *inputs)
  {
//--- Control block
   if(!inputs)
      return false;
   CNeuronBase *InputLayer = m_cLayers.At(0);
   if(!InputLayer)
      return false;
   CBufferType *Inputs = InputLayer.GetOutputs();
   if(!Inputs)
      return false;
   if(Inputs.Total() != inputs.Total())
      return false;
//--- Transfer the source data to the neural layer
   Inputs.m_mMatrix = inputs.m_mMatrix;
//--- Apply positional encoding
   if(m_bPositionEncoder && !m_cPositionEncoder.AddEncoder(Inputs))
      return false;
   if(m_bOpenCL)
      Inputs.BufferCreate(m_cOpenCL);
//--- Organize a loop through all neural layers
//--- and calling the feed-forward method for each of them
   CNeuronBase *PrevLayer = InputLayer;
   int total = m_cLayers.Total();
   for(int i = 1; i < total; i++)
     {
      CNeuronBase *Layer = m_cLayers.At(i);
      if(!Layer)
        {
         PrintFormat("%s - %d Layer %d", __FUNCTION__, __LINE__, i);
         return false;
        }
      if(!Layer.FeedForward(PrevLayer))
        {
         PrintFormat("%s - %d Layer %d", __FUNCTION__, __LINE__, i);
         return false;
        }
      PrevLayer = Layer;
     }
   if(m_bOpenCL)
      if(!PrevLayer.GetOutputs().BufferRead())
         return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Backpropagation method                                           |
//+------------------------------------------------------------------+
bool CNet::Backpropagation(CBufferType *target)
  {
//--- Control block
   if(!target)
      return false;
   int total = m_cLayers.Total();
   CNeuronBase *Output = m_cLayers.At(total - 1);
   if(!Output || Output.Total() != target.Total())
      return false;
//--- Calculate the value of the loss function
   TYPE loss = Output.GetOutputs().m_mMatrix.Loss(target.m_mMatrix, m_eLossFunction);
   if(loss == FLT_MAX || !MathIsValidNumber(loss))
     {
      printf("%s -> %d", __FUNCTION__, __LINE__);
      Print(target.m_mMatrix);
      Print(Output.GetOutputs().m_mMatrix);
      return false;
     }
   m_dNNLoss = (m_dNNLoss < 0 ? loss : m_dNNLoss + (loss - m_dNNLoss) / m_iLossSmoothFactor);
//--- Calculate error gradient at the output of the neural network
   CBufferType* grad = Output.GetGradients();
   grad.m_mMatrix = target.m_mMatrix;
   if(m_cOpenCL)
     {
      if(!grad.BufferWrite())
         return false;
     }
   if(!Output.CalcOutputGradient(grad, m_eLossFunction))
      return false;
//--- Run a loop iterating through all neural layers in reverser order
   for(int i = total - 2; i >= 0; i--)
     {
      CNeuronBase *temp = m_cLayers.At(i);
      if(!temp)
         return false;
      //--- Call method propagating the error gradient through the hidden layer
      if(!Output.CalcHiddenGradient(temp))
         return false;
      //--- Call method propagating the error gradient to the weight matrix
      if(!Output.CalcDeltaWeights(temp, i == 0))
         return false;
      Output = temp;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for updating weight matrices                              |
//+------------------------------------------------------------------+
bool CNet::UpdateWeights(uint batch_size = 1)
  {
//--- Control block
   if(batch_size <= 0)
      return false;
//--- Organize a loop through all hidden layers
   int total = m_cLayers.Total();
   for(int i = 1; i < total; i++)
     {
      //--- Check the validity of pointer to the neural layer object
      CNeuronBase *temp = m_cLayers.At(i);
      if(!temp)
         return false;
      //--- Call the method for updating the weight matrix of the inner layer
      if(!temp.UpdateWeights(batch_size, m_dLearningRate, m_adBeta, m_adLambda))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for obtaining feed-forward results                        |
//+------------------------------------------------------------------+
bool CNet::GetResults(CBufferType *&result)
  {
   int total = m_cLayers.Total();
   CNeuronBase *temp = m_cLayers.At(total - 1);
   if(!temp)
      return false;
   CBufferType *output = temp.GetOutputs();
   if(!output)
      return false;
   if(!result)
     {
      result = new CBufferType();
      if(!result)
         return false;
     }
   if(m_cOpenCL)
      if(!output.BufferRead())
         return false;
   result.m_mMatrix = output.m_mMatrix;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNet::Save(string file_name = NULL)
  {
//--- Control block
   if(file_name == NULL || file_name == "")
      file_name = defFileName;
//--- Open file for writing
   int handle = FileOpen(file_name, FILE_WRITE | FILE_BIN);
//--- Call method for saving the class using the file handle
   bool result = Save(handle);
//--- Close the open file
   FileClose(handle);
//---
   return result;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNet::Save(const int file_handle)
  {
//--- Control block
   if(file_handle == INVALID_HANDLE || !m_cLayers)
      return false;
//--- Save constants
   if(!FileWriteInteger(file_handle, (int)m_bOpenCL)           ||
      !FileWriteDouble(file_handle, m_dNNLoss)                 ||
      !FileWriteInteger(file_handle, m_iLossSmoothFactor)      ||
      !FileWriteInteger(file_handle, (int)m_bPositionEncoder)  ||
      !FileWriteDouble(file_handle, (double)m_dLearningRate)   ||
      !FileWriteDouble(file_handle, (double)m_adBeta[0])       ||
      !FileWriteDouble(file_handle, (double)m_adBeta[1])       ||
      !FileWriteDouble(file_handle, (double)m_adLambda[0])     ||
      !FileWriteDouble(file_handle, (double)m_adLambda[1])     ||
      !FileWriteInteger(file_handle, (int)m_eLossFunction))
      return false;
//--- Save the positional encoding object if necessary
   if(m_bPositionEncoder)
     {
      if(!m_cPositionEncoder ||
         !m_cPositionEncoder.Save(file_handle))
         return false;
     }
//--- Call the method for saving data of a dynamic array of neural layers
   return m_cLayers.Save(file_handle);
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from saved data                   |
//+------------------------------------------------------------------+
bool CNet::Load(string file_name = NULL, bool common = false)
  {
//--- Control block
   if(!FileIsExist(file_name, (common ? FILE_COMMON : 0)))
      file_name = defFileName;
//--- Open the file and call the method for loading data using the file handle
   int handle = FileOpen(file_name, FILE_READ | FILE_BIN | FILE_SHARE_READ | (common ? FILE_COMMON : 0));
   bool result = Load(handle);
   FileClose(handle);
//---
   return result;
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from saved data                   |
//+------------------------------------------------------------------+
bool CNet::Load(const int file_handle)
  {
//--- Control block
   if(file_handle == INVALID_HANDLE)
      return false;
//--- Read constants
   m_bOpenCL = (bool)FileReadInteger(file_handle);
   m_dNNLoss = (TYPE)FileReadDouble(file_handle);
   m_iLossSmoothFactor = FileReadInteger(file_handle);
   m_bPositionEncoder = (bool)FileReadInteger(file_handle);
   m_dLearningRate = (TYPE)FileReadDouble(file_handle);
   m_adBeta[0] = (TYPE)FileReadDouble(file_handle);
   m_adBeta[1] = (TYPE)FileReadDouble(file_handle);
   m_adLambda[0] = (TYPE)FileReadDouble(file_handle);
   m_adLambda[1] = (TYPE)FileReadDouble(file_handle);
   ENUM_LOSS_FUNCTION loss = (ENUM_LOSS_FUNCTION) FileReadInteger(file_handle);
   if(!LossFunction(loss, defLambdaL1, defLambdaL2))
     {
      Print("Error, unknown loss function: ", EnumToString(loss));
      return false;
     }
//--- Load a positional encoding object
   if(m_bPositionEncoder)
     {
      if(!m_cPositionEncoder)
        {
         m_cPositionEncoder = new CPositionEncoder();
         if(!m_cPositionEncoder)
            return false;
        }
      if(!m_cPositionEncoder.Load(file_handle))
         return false;
     }
//--- Initialize object for working with OpenCL
   if(m_bOpenCL)
     {
      if(!InitOpenCL())
         m_bOpenCL = false;
     }
   else
      if(!!m_cOpenCL)
        {
         m_cOpenCL.Shutdown();
         delete m_cOpenCL;
        }
//--- Initialize and load data from a dynamic array of neural layers
   if(!m_cLayers)
     {
      m_cLayers = new CArrayLayers();
      if(!m_cLayers)
         return false;
     }
   if(m_bOpenCL)
      m_cLayers.SetOpencl(m_cOpenCL);
//---
   return m_cLayers.Load(file_handle);
  }
//+------------------------------------------------------------------+
//| Method for initializing objects for working with OpenCL          |
//+------------------------------------------------------------------+
bool CNet::InitOpenCL(void)
  {
//--- Delete previously created OpenCL objects
   if(!!m_cOpenCL)
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
     }
//--- Create a new object to work with OpenCL
   m_cOpenCL = new CMyOpenCL();
   if(!m_cOpenCL)
      return false;
//--- Initialize object for working with OpenCL
   if(!m_cOpenCL.Initialize(cl_program, true))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.SetKernelsCount(43))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.SetBuffersCount(10))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
//---  Initialize OpenCL kernels
   if(!m_cOpenCL.KernelCreate(def_k_PerceptronFeedForward, "PerceptronFeedForward"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_CalcOutputGradient, "CalcOutputGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_CalcHiddenGradient, "CalcHiddenGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_CalcDeltaWeights, "CalcDeltaWeights"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_SGDUpdate, "SGDUpdate"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_MomentumUpdate, "MomentumUpdate"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_AdaGradUpdate, "AdaGradUpdate"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_RMSPropUpdate, "RMSPropUpdate"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_AdaDeltaUpdate, "AdaDeltaUpdate"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_AdamUpdate, "AdamUpdate"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_ProofFeedForward, "ProofFeedForward"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_ProofHiddenGradients, "ProofCalcHiddenGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_ConvolutionFeedForward, "ConvolutionFeedForward"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_ConvolutionHiddenGradients, "ConvolutionCalcHiddenGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_ConvolutionDeltaWeights, "ConvolutionCalcDeltaWeights"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_LSTMFeedForward, "LSTMFeedForward"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_LSTMHiddenGradients, "LSTMCalcHiddenGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_AttentionFeedForward, "AttentionFeedForward"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_AttentionScoreGradients, "AttentionCalcScoreGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_AttentionHiddenGradients, "AttentionCalcHiddenGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_GPTFeedForward, "GPTFeedForward"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_GPTScoreGradients, "GPTCalcScoreGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_GPTHiddenGradients, "GPTCalcHiddenGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_BatchNormFeedForward, "BatchNormFeedForward"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_BatchNormCalcHiddenGradient, "BatchNormCalcHiddenGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_BatchNormCalcDeltaWeights, "BatchNormCalcDeltaWeights"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_MaskMult, "MaskMult"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_Sum, "Sum"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_LayerNormalize, "LayerNormalize"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_LayerNormalizeGradient, "LayerNormalizeGradient"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_LineActivation, "LineActivation"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_SigmoidActivation, "SigmoidActivation"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_SigmoidDerivative, "SigmoidDerivative"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_TANHActivation, "TanhActivation"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_TANHDerivative, "TanhDerivative"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_LReLuActivation, "LReLUActivation"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_LReLuDerivative, "LReLUDerivative"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_SoftMAXActivation, "SoftMaxActivation"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_SoftMAXDerivative, "SoftMaxDerivative"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_SwishActivation, "SwishActivation"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_SwishDerivative, "SwishDerivative"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_Split, "Split"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
   if(!m_cOpenCL.KernelCreate(def_k_Concatenate, "Concatenate"))
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for passing a pointer to the OpenCL object to all         |
//| internal objects                                                 |
//+------------------------------------------------------------------+
void CNet::UseOpenCL(bool value)
  {
   if(!value)
     {
      if(!m_cOpenCL)
        {
         m_bOpenCL = value;
         return;
        }
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
      if(!!m_cLayers)
         m_cLayers.SetOpencl(m_cOpenCL);
      m_bOpenCL = value;
      return;
     }
//---
   if(!!m_cOpenCL)
     {
      m_cOpenCL.Shutdown();
      delete m_cOpenCL;
     }
   m_bOpenCL = InitOpenCL();
   if(!!m_cLayers)
      m_cLayers.SetOpencl(m_cOpenCL);
   return;
  }
//+------------------------------------------------------------------+
//| Method for setting learning parameters                           |
//+------------------------------------------------------------------+
void CNet::SetLearningRates(TYPE learning_rate, TYPE beta1 = defBeta1, TYPE beta2 = defBeta2)
  {
   m_dLearningRate = learning_rate;
   m_adBeta[0] = beta1;
   m_adBeta[1] = beta2;
  }
//+------------------------------------------------------------------+
//| Method for setting the loss function                             |
//+------------------------------------------------------------------+
bool CNet::LossFunction(ENUM_LOSS_FUNCTION loss_function, TYPE lambda1 = 0.000000, TYPE lambda2 = 0.000000)
  {
//--- save the parameters of the loss function
   m_eLossFunction = loss_function;
   m_adLambda[0] = lambda1;
   m_adLambda[1] = lambda2;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for getting a pointer to gradient buffer by layer number  |
//+------------------------------------------------------------------+
CBufferType *CNet::GetGradient(uint layer) const
  {
   if(layer >= (uint)m_cLayers.Total())
      return NULL;
//---
   CNeuronBase *l = m_cLayers.At(layer);
   return l.GetGradients();
  }
//+------------------------------------------------------------------+
//| Method for getting a pointer to weight matrix by layer number    |
//+------------------------------------------------------------------+
CBufferType *CNet::GetWeights(uint layer) const
  {
   if(layer >= (uint)m_cLayers.Total())
      return NULL;
//---
   CNeuronBase *l = m_cLayers.At(layer);
   return l.GetWeights();
  }
//+------------------------------------------------------------------+
//| Method for getting a pointer to buffer of accumulated error      |
//| gradients at the weight matrix level by layer number             |
//+------------------------------------------------------------------+
CBufferType *CNet::GetDeltaWeights(uint layer)const
  {
   if(layer >= (uint)m_cLayers.Total())
      return NULL;
//---
   CNeuronBase *l = m_cLayers.At(layer);
   return l.GetDeltaWeights();
  }
//+------------------------------------------------------------------+
//| Set model running mode                                           |
//+------------------------------------------------------------------+
void CNet::TrainMode(bool mode)
  {
   m_bTrainMode = mode;
   int total = m_cLayers.Total();
   for(int i = 0; i < total; i++)
     {
      if(!m_cLayers.At(i))
         continue;
      CNeuronBase *temp = m_cLayers.At(i);
      temp.TrainMode(mode);
     }
  }
//+------------------------------------------------------------------+
//| Method for getting the depth of GPT blocks used                  |
//+------------------------------------------------------------------+
//int CNet::GetGPTUnits(void)
//  {
//   int result = 0;
//   if(CheckPointer(m_cLayers) == POINTER_INVALID)
//      return result;
//   int total = m_cLayers.Total();
//   for(int i = 0; i < total; i++)
//     {
//      if(CheckPointer(m_cLayers.At(i)) == POINTER_INVALID)
//         continue;
//      if(m_cLayers.At(i).Type() == defNeuronGPT)
//        {
//         CNeuronGPT *temp = m_cLayers.At(i);
//         result += temp.GetUnits() * temp.GetLayers();
//        }
//      if(m_cLayers.At(i).Type() == defNeuronLSTM)
//        {
//         CNeuronLSTM *temp = m_cLayers.At(i);
//         result += temp.GetDepth();
//        }
//     }
////---
//   return result;
//  }
//+------------------------------------------------------------------+
//| Method for setting the positional encoding usage flag            |
//+------------------------------------------------------------------+
void CNet::UsePositionEncoder(bool value)
  {
   m_bPositionEncoder = value;
   if(!m_bPositionEncoder)
     {
      if(!!m_cPositionEncoder)
         delete m_cPositionEncoder;
      return;
     }
//---
   if(!m_cPositionEncoder)
      m_cPositionEncoder = new CPositionEncoder();
   if(!m_cLayers || m_cLayers.Total() < 1)
      return;
   CNeuronBase *temp = m_cLayers.At(0);
   if(!temp)
      return;
   if(!m_cPositionEncoder.InitEncoder(1, temp.GetOutputs().Total()))
      UsePositionEncoder(false);
//---
   return;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
