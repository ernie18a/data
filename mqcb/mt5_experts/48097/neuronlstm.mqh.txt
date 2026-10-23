//+------------------------------------------------------------------+
//|                                                   NeuronLSTM.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include "neuronbase.mqh"
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//| Class CNeuronLSTM                                                |
//| Purpose: Class for implementing a recurrent LSTM block           |
//+------------------------------------------------------------------+
class CNeuronLSTM    :  public CNeuronBase
  {
protected:
   CNeuronBase*      m_cForgetGate;
   CNeuronBase*      m_cInputGate;
   CNeuronBase*      m_cNewContent;
   CNeuronBase*      m_cOutputGate;
   CArrayObj*        m_cMemorys;
   CArrayObj*        m_cHiddenStates;
   CArrayObj*        m_cInputs;
   CArrayObj*        m_cForgetGateOuts;
   CArrayObj*        m_cInputGateOuts;
   CArrayObj*        m_cNewContentOuts;
   CArrayObj*        m_cOutputGateOuts;
   CBufferType*      m_cInputGradient;
   int               m_iDepth;

   void              ClearBuffer(CArrayObj *buffer);
   bool              InsertBuffer(CArrayObj *&array, CBufferType *element, bool create_new = true);
   CBufferType*      CreateBuffer(CArrayObj *&array);

public:
                     CNeuronLSTM(void);
                    ~CNeuronLSTM(void);
   //---
   virtual bool      Init(const CLayerDescription *desc) override;
   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;
   virtual bool      FeedForward(CNeuronBase *prevLayer) override;
   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;
   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override
                                { return (!m_cOpenCL ? true : m_cDeltaWeights.BufferRead()); }
   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,
                                   VECTOR &Beta, VECTOR &Lambda) override;
   //---
   virtual int       GetDepth(void)  const { return m_iDepth; }
   //--- file handling methods
   virtual bool      Save(const int file_handle) override;
   virtual bool      Load(const int file_handle) override;
   //--- object identification method
   virtual int       Type(void)  override         const { return(defNeuronLSTM); }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNeuronLSTM::CNeuronLSTM(void)   : m_iDepth(2)
  {
   m_cForgetGate = new CNeuronBase();
   m_cInputGate = new CNeuronBase();
   m_cNewContent = new CNeuronBase();
   m_cOutputGate = new CNeuronBase();
   m_cMemorys = new CArrayObj();
   m_cHiddenStates = new CArrayObj();
   m_cInputs = new CArrayObj();
   m_cForgetGateOuts = new CArrayObj();
   m_cInputGateOuts = new CArrayObj();
   m_cNewContentOuts = new CArrayObj();
   m_cOutputGateOuts = new CArrayObj();
   m_cInputGradient = new CBufferType();
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CNeuronLSTM::~CNeuronLSTM(void)
  {
   if(m_cForgetGate)
      delete m_cForgetGate;
   if(m_cInputGate)
      delete m_cInputGate;
   if(m_cNewContent)
      delete m_cNewContent;
   if(m_cOutputGate)
      delete m_cOutputGate;
   if(m_cMemorys)
      delete m_cMemorys;
   if(m_cHiddenStates)
      delete m_cHiddenStates;
   if(m_cInputs)
      delete m_cInputs;
   if(m_cForgetGateOuts)
      delete m_cForgetGateOuts;
   if(m_cInputGateOuts)
      delete m_cInputGateOuts;
   if(m_cNewContentOuts)
      delete m_cNewContentOuts;
   if(m_cOutputGateOuts)
      delete m_cOutputGateOuts;
   if(m_cInputGradient)
      delete m_cInputGradient;
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronLSTM::Init(const CLayerDescription *desc)
  {
//--- control block
   if(!desc || desc.type != Type() || desc.count <= 0 || desc.window == 0)
      return false;
//--- create a description for the internal neural layers
   CLayerDescription *temp = new CLayerDescription();
   if(!temp)
      return false;
   temp.type = defNeuronBase;
   temp.window = desc.window + desc.count;
   temp.count = desc.count;
   temp.activation = AF_SIGMOID;
   temp.activation_params[0] = 1;
   temp.activation_params[1] = 0;
   temp.optimization = desc.optimization;
//--- call the initialization method of the parent class
   CLayerDescription *temp2 = new CLayerDescription();
   if(!temp2 || !temp2.Copy(desc))
      return false;
   temp2.window = 0;
   if(!CNeuronBase::Init(temp2))
      return false;
   delete temp2;
   if(!InsertBuffer(m_cHiddenStates, m_cOutputs, false))
      return false;
   m_iDepth = (int)fmax(desc.window_out, 2);
//--- initialize ForgetGate
   if(!m_cForgetGate)
     {
      if(!(m_cForgetGate = new CNeuronBase()))
         return false;
     }
   if(!m_cForgetGate.Init(temp))
      return false;
   if(!InsertBuffer(m_cForgetGateOuts, m_cForgetGate.GetOutputs(), false))
      return false;
//--- initialize InputGate
   if(!m_cInputGate)
     {
      if(!(m_cInputGate = new CNeuronBase()))
         return false;
     }
   if(!m_cInputGate.Init(temp))
      return false;
   if(!InsertBuffer(m_cInputGateOuts, m_cInputGate.GetOutputs(), false))
      return false;
//--- initialize OutputGate
   if(!m_cOutputGate)
     {
      if(!(m_cOutputGate = new CNeuronBase()))
         return false;
     }
   if(!m_cOutputGate.Init(temp))
      return false;
   if(!InsertBuffer(m_cOutputGateOuts, m_cOutputGate.GetOutputs(), false))
      return false;
//--- initialize NewContent
   if(!m_cNewContent)
     {
      if(!(m_cNewContent = new CNeuronBase()))
         return false;
     }
   temp.activation = AF_TANH;
   if(!m_cNewContent.Init(temp))
      return false;
   if(!InsertBuffer(m_cNewContentOuts, m_cNewContent.GetOutputs(), false))
      return false;
//--- initialize InputGradient buffer
   if(!m_cInputGradient)
     {
      if(!(m_cInputGradient = new CBufferType()))
         return false;
     }
   if(!m_cInputGradient.BufferInit(1, temp.window, 0))
      return false;
   delete temp;
//--- initialize Memory
   CBufferType *buffer =  CreateBuffer(m_cMemorys);
   if(!buffer)
      return false;
   if(!InsertBuffer(m_cMemorys, buffer, false))
     {
      delete buffer;
      return false;
     }
//--- initialize HiddenStates
   if(!(buffer =  CreateBuffer(m_cHiddenStates)))
      return false;
   if(!InsertBuffer(m_cHiddenStates, buffer, false))
     {
      delete buffer;
      return false;
     }
//---
   SetOpenCL(m_cOpenCL);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for passing a pointer to the OpenCL object to all         |
//| internal objects                                                 |
//+------------------------------------------------------------------+
bool CNeuronLSTM::SetOpenCL(CMyOpenCL *opencl)
  {
//--- call of the method of the parent class
   CNeuronBase::SetOpenCL(opencl);
//--- call the relevant method for all internal layers
   m_cForgetGate.SetOpenCL(m_cOpenCL);
   m_cInputGate.SetOpenCL(m_cOpenCL);
   m_cOutputGate.SetOpenCL(m_cOpenCL);
   m_cNewContent.SetOpenCL(m_cOpenCL);
   m_cInputGradient.BufferCreate(m_cOpenCL);
   for(int i = 0; i < m_cMemorys.Total(); i++)
     {
      CBufferType *temp = m_cMemorys.At(i);
      temp.BufferCreate(m_cOpenCL);
     }
   for(int i = 0; i < m_cHiddenStates.Total(); i++)
     {
      CBufferType *temp = m_cHiddenStates.At(i);
      temp.BufferCreate(m_cOpenCL);
     }
//---
   return(!!m_cOpenCL);
  }
//+------------------------------------------------------------------+
//| Method for deleting unnecessary data from the stack              |
//+------------------------------------------------------------------+
void CNeuronLSTM::ClearBuffer(CArrayObj *buffer)
  {
   if(!buffer)
      return;
   int total = buffer.Total();
   if(total > m_iDepth + 1)
      buffer.DeleteRange(m_iDepth + 1, total);
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronLSTM::FeedForward(CNeuronBase *prevLayer)
  {
//--- check the relevance of all objects
   if(!prevLayer || !prevLayer.GetOutputs() || !m_cOutputs ||
      !m_cForgetGate || !m_cInputGate || !m_cOutputGate ||
      !m_cNewContent)
      return false;
//--- prepare blanks for new buffers
   if(!m_cForgetGate.SetOutputs(CreateBuffer(m_cForgetGateOuts), false))
      return false;
   if(!m_cInputGate.SetOutputs(CreateBuffer(m_cInputGateOuts), false))
      return false;
   if(!m_cOutputGate.SetOutputs(CreateBuffer(m_cOutputGateOuts), false))
      return false;
   if(!m_cNewContent.SetOutputs(CreateBuffer(m_cNewContentOuts), false))
      return false;
   CBufferType *memory = CreateBuffer(m_cMemorys);
   if(!memory)
      return false;
   CBufferType *hidden = CreateBuffer(m_cHiddenStates);
   if(!hidden)
     {
      delete memory;
      return false;
     }
//--- only to check the gradient
//memory.m_mMatrix.Fill(0);
//hidden.m_mMatrix.Fill(0);
//if(!!m_cOpenCL)
//  {
//   memory.BufferWrite();
//   hidden.BufferWrite();
//  }
//--- create the buffer of source data
   if(!m_cInputs)
     {
      m_cInputs = new CArrayObj();
      if(!m_cInputs)
        {
         delete memory;
         delete hidden;
         return false;
        }
     }
   CNeuronBase *inputs = new CNeuronBase();
   if(!inputs)
     {
      delete memory;
      delete hidden;
      return false;
     }
   CLayerDescription *desc = new CLayerDescription();
   if(!desc)
     {
      delete inputs;
      delete memory;
      delete hidden;
      return false;
     }
   desc.type = defNeuronBase;
   desc.count = (int)(prevLayer.GetOutputs().Total() + m_cOutputs.Total());
   desc.window = 0;
   if(!inputs.Init(desc))
     {
      delete inputs;
      delete memory;
      delete hidden;
      delete desc;
      return false;
     }
   delete desc;
   inputs.SetOpenCL(m_cOpenCL);
   CBufferType *inputs_buffer = inputs.GetOutputs();
   if(!inputs_buffer)
     {
      delete inputs;
      delete memory;
      delete hidden;
      return false;
     }
   if(!inputs_buffer.Concatenate(prevLayer.GetOutputs(), hidden, prevLayer.Total(), hidden.Total()))
     {
      delete inputs;
      delete memory;
      delete hidden;
      return false;
     }
//--- feed-forward pass through internal neural layers
   if(!m_cForgetGate.FeedForward(inputs))
     {
      delete inputs;
      delete memory;
      delete hidden;
      return false;
     }
   if(!m_cInputGate.FeedForward(inputs))
     {
      delete inputs;
      delete memory;
      delete hidden;
      return false;
     }
   if(!m_cOutputGate.FeedForward(inputs))
     {
      delete inputs;
      delete memory;
      delete hidden;
      return false;
     }
   if(!m_cNewContent.FeedForward(inputs))
     {
      delete inputs;
      delete memory;
      delete hidden;
      return false;
     }
//--- branching of the algorithm across computing devices
   CBufferType *fg = m_cForgetGate.GetOutputs();
   CBufferType *ig = m_cInputGate.GetOutputs();
   CBufferType *og = m_cOutputGate.GetOutputs();
   CBufferType *nc = m_cNewContent.GetOutputs();
   if(!m_cOpenCL)
     {
      memory.m_mMatrix *= fg.m_mMatrix;
      memory.m_mMatrix += ig.m_mMatrix * nc.m_mMatrix;
      hidden.m_mMatrix = MathTanh(memory.m_mMatrix) * og.m_mMatrix;
     }
   else
     {
      //--- check buffers
      if(fg.GetIndex() < 0 || ig.GetIndex() < 0 || og.GetIndex() < 0 ||
         nc.GetIndex() < 0 || memory.GetIndex() < 0 || hidden.GetIndex() < 0)
         return false;
      //--- pass parameters to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_forgetgate, fg.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_inputgate, ig.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_newcontent, nc.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_outputgate, og.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_memory, memory.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMFeedForward, def_lstmff_hiddenstate, hidden.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LSTMFeedForward, def_lstmff_outputs_total, (int)m_cOutputs.Total()))
         return false;
      //--- launch the kernel
      int NDRange[] = {(int)(m_cOutputs.Total() + 3) / 4};
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_LSTMFeedForward, 1, off_set, NDRange))
         return false;
     }
//--- copy the hidden state to the results buffer of the neural layer
   m_cOutputs = hidden;
//--- save the current state
   if(!m_cInputs.Insert(inputs, 0))
     {
      delete inputs;
      delete memory;
      delete hidden;
      return false;
     }
   ClearBuffer(m_cInputs);
   if(!InsertBuffer(m_cForgetGateOuts, m_cForgetGate.GetOutputs(), false))
     {
      delete memory;
      delete hidden;
      return false;
     }
   if(!InsertBuffer(m_cInputGateOuts, m_cInputGate.GetOutputs(), false))
     {
      delete memory;
      delete hidden;
      return false;
     }
   if(!InsertBuffer(m_cOutputGateOuts, m_cOutputGate.GetOutputs(), false))
     {
      delete memory;
      delete hidden;
      return false;
     }
   if(!InsertBuffer(m_cNewContentOuts, m_cNewContent.GetOutputs(), false))
     {
      delete memory;
      delete hidden;
      return false;
     }
   if(!InsertBuffer(m_cMemorys, memory, false))
     {
      delete hidden;
      return false;
     }
   if(!InsertBuffer(m_cHiddenStates, hidden, false))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for adding data to the stack                              |
//+------------------------------------------------------------------+
bool CNeuronLSTM::InsertBuffer(CArrayObj *&array, CBufferType *element, bool create_new = true)
  {
//--- control block
   if(!element)
      return false;
   if(!array)
     {
      array = new CArrayObj();
      if(!array)
         return false;
     }
//---
   if(create_new)
     {
      CBufferType *buffer = new CBufferType();
      if(!buffer)
         return false;
      buffer.m_mMatrix = element.m_mMatrix;
      if(!array.Insert(buffer, 0))
        {
         delete buffer;
         return false;
        }
     }
   else
     {
      if(!array.Insert(element, 0))
        {
         delete element;
         return false;
        }
     }
//--- remove unnecessary history from the buffer
   ClearBuffer(array);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for creating a new data buffer                            |
//+------------------------------------------------------------------+
CBufferType *CNeuronLSTM::CreateBuffer(CArrayObj *&array)
  {
   if(!array)
     {
      array = new CArrayObj();
      if(!array)
         return NULL;
     }
   CBufferType *buffer = new CBufferType();
   if(!buffer)
      return NULL;
   if(array.Total() <= 0)
     {
      if(!buffer.BufferInit(m_cOutputs.Rows(), m_cOutputs.Cols(), 0))
        {
         delete buffer;
         return NULL;
        }
     }
   else
     {
      CBufferType *temp = array.At(0);
      if(!temp)
        {
         delete buffer;
         return NULL;
        }
      buffer.m_mMatrix = temp.m_mMatrix;
     }
//---
   if(m_cOpenCL)
     {
      if(!buffer.BufferCreate(m_cOpenCL))
         delete buffer;
     }
//---
   return buffer;
  }
//+------------------------------------------------------------------+
//| Method for propagating error gradient through hidden layer       |
//+------------------------------------------------------------------+
bool CNeuronLSTM::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- check the relevance of all objects
   if(!prevLayer || !prevLayer.GetGradients() ||
      !m_cGradients || !m_cForgetGate || !m_cForgetGateOuts ||
      !m_cInputGate || !m_cInputGateOuts || !m_cOutputGate ||
      !m_cOutputGateOuts || !m_cNewContent || !m_cNewContentOuts)
      return false;
//--- check the presence of feed-forward data
   int total = (int)fmin(m_cMemorys.Total(), m_cHiddenStates.Total()) - 1;
   if(total <= 0)
      return false;
//--- make pointers to buffers of gradients and results of internal layers
   CBufferType *fg_grad = m_cForgetGate.GetGradients();
   if(!fg_grad)
      return false;
   CBufferType *fg_out = m_cForgetGate.GetOutputs();
   if(!fg_out)
      return false;
   CBufferType *ig_grad = m_cInputGate.GetGradients();
   if(!ig_grad)
      return false;
   CBufferType *ig_out = m_cInputGate.GetOutputs();
   if(!ig_out)
      return false;
   CBufferType *og_grad = m_cOutputGate.GetGradients();
   if(!og_grad)
      return false;
   CBufferType *og_out = m_cOutputGate.GetOutputs();
   if(!og_out)
      return false;
   CBufferType *nc_grad = m_cNewContent.GetGradients();
   if(!nc_grad)
      return false;
   CBufferType *nc_out = m_cNewContent.GetOutputs();
   if(!nc_out)
      return false;
//---
   ulong out_total = m_cOutputs.Total();
//--- loop through the accumulated history
   for(int i = 0; i < total; i++)
     {
      //--- get pointers to buffers from the stack
      CBufferType *fg = m_cForgetGateOuts.At(i);
      if(!fg)
         return false;
      CBufferType *ig = m_cInputGateOuts.At(i);
      if(!ig)
         return false;
      CBufferType *og = m_cOutputGateOuts.At(i);
      if(!og)
         return false;
      CBufferType *nc = m_cNewContentOuts.At(i);
      if(!nc)
         return false;
      CBufferType *memory = m_cMemorys.At(i + 1);
      if(!memory)
         return false;
      CBufferType *hidden = m_cHiddenStates.At(i);
      if(!hidden)
         return false;
      CNeuronBase *inputs = m_cInputs.At(i);
      if(!inputs)
         return false;
      //--- branching of the algorithm across computing devices
      if(!m_cOpenCL)
        {
         //--- calculate the gradient at the output of each internal layer
         MATRIX m = hidden.m_mMatrix / (og.m_mMatrix + 1e-8);
         //--- OutputGate gradient
         MATRIX grad = m_cGradients.m_mMatrix;
         og_grad.m_mMatrix = grad * m;
         //--- memory gradient
         grad *= og.m_mMatrix;
         //--- adjust the gradient to the derivative
         grad *= MathPow(m, 2) * (-1) + 1;
         //--- InputGate gradient
         ig_grad.m_mMatrix = grad * nc.m_mMatrix;
         //--- NewContent gradient
         nc_grad.m_mMatrix = grad * ig.m_mMatrix;
         //--- ForgetGates gradient
         fg_grad.m_mMatrix = grad * memory.m_mMatrix;
        }
      else
        {
         //--- check buffers
         if(hidden.GetIndex() < 0)
            return false;
         if(m_cGradients.GetIndex() < 0)
            return false;
         if(ig.GetIndex() < 0)
            return false;
         if(og.GetIndex() < 0)
            return false;
         if(nc.GetIndex() < 0)
            return false;
         if(memory.GetIndex() < 0)
            return false;
         if(fg_grad.GetIndex() < 0)
            return false;
         if(ig_grad.GetIndex() < 0)
            return false;
         if(og_grad.GetIndex() < 0)
            return false;
         if(nc_grad.GetIndex() < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_fg_gradients, fg_grad.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_gradients, m_cGradients.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_ig_gradients, ig_grad.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_inputgate, ig.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_memory, memory.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_nc_gradients, nc_grad.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_newcontent, nc.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_og_gradients, og_grad.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_outputgate, og.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_LSTMHiddenGradients, def_lstmhgr_outputs, hidden.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_LSTMHiddenGradients, def_lstmhgr_outputs_total, (int)m_cOutputs.Total()))
            return false;
         //--- launch the kernel
         int NDRange[] = { (int)(m_cOutputs.Total() + 3) / 4 };
         int off_set[] = {0};
         if(!m_cOpenCL.Execute(def_k_LSTMHiddenGradients, 1, off_set, NDRange))
            return false;
        }
      //--- copy the corresponding historical data to the buffers of internal layers
      if(!m_cForgetGate.SetOutputs(fg, false))
         return false;
      if(!m_cInputGate.SetOutputs(ig, false))
         return false;
      if(!m_cOutputGate.SetOutputs(og, false))
         return false;
      if(!m_cNewContent.SetOutputs(nc, false))
         return false;
      //--- propagate gradient through the inner layers
      if(!m_cForgetGate.CalcHiddenGradient(inputs))
         return false;
      if(!m_cInputGradient)
        {
         m_cInputGradient = new CBufferType();
         if(!m_cInputGradient)
            return false;
         m_cInputGradient.m_mMatrix = inputs.GetGradients().m_mMatrix;
         m_cInputGradient.BufferCreate(m_cOpenCL);
        }
      else
        {
         m_cInputGradient.Scaling(0);
         if(!m_cInputGradient.SumArray(inputs.GetGradients()))
            return false;
        }
      if(!m_cInputGate.CalcHiddenGradient(inputs))
         return false;
      if(!m_cInputGradient.SumArray(inputs.GetGradients()))
         return false;
      if(!m_cOutputGate.CalcHiddenGradient(inputs))
         return false;
      if(!m_cInputGradient.SumArray(inputs.GetGradients()))
         return false;
      if(!m_cNewContent.CalcHiddenGradient(inputs))
         return false;
      if(!inputs.GetGradients().SumArray(m_cInputGradient))
         return false;
      //--- project gradient onto weight matrices of internal layers
      if(!m_cForgetGate.CalcDeltaWeights(inputs, false))
         return false;
      if(!m_cInputGate.CalcDeltaWeights(inputs, false))
         return false;
      if(!m_cOutputGate.CalcDeltaWeights(inputs, false))
         return false;
      if(!m_cNewContent.CalcDeltaWeights(inputs, false))
         return false;
      //--- if gradient for the current state is calculated, pass it to the previous layer
      //--- and write the hidden state gradient to the gradient buffer for a new iteration
      if(!inputs.GetGradients().Split((i == 0 ? prevLayer.GetGradients() : inputs.GetGradients()), m_cGradients, (uint)prevLayer.Total()))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for updating weight matrices                              |
//+------------------------------------------------------------------+
bool CNeuronLSTM::UpdateWeights(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda)
  {
//--- check the state of objects
   if(!m_cForgetGate || !m_cInputGate || !m_cOutputGate || !m_cNewContent || m_iDepth <= 0)
      return false;
   int batch = batch_size * m_iDepth;
//--- update weight matrices of internal layers
   if(!m_cForgetGate.UpdateWeights(batch, learningRate, Beta, Lambda))
      return false;
   if(!m_cInputGate.UpdateWeights(batch, learningRate, Beta, Lambda))
      return false;
   if(!m_cOutputGate.UpdateWeights(batch, learningRate, Beta, Lambda))
      return false;
   if(!m_cNewContent.UpdateWeights(batch, learningRate, Beta, Lambda))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNeuronLSTM::Save(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronBase::Save(file_handle))
      return false;
//--- save constants
   if(FileWriteInteger(file_handle, m_iDepth) <= 0)
      return false;
//--- call the relevant method for all internal layers
   if(!m_cForgetGate.Save(file_handle))
      return false;
   if(!m_cInputGate.Save(file_handle))
      return false;
   if(!m_cOutputGate.Save(file_handle))
      return false;
   if(!m_cNewContent.Save(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from a file                       |
//+------------------------------------------------------------------+
bool CNeuronLSTM::Load(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronBase::Load(file_handle))
      return false;
//--- read constants
   m_iDepth = FileReadInteger(file_handle);
//--- call the relevant method for all internal layers
   if(FileReadInteger(file_handle) != defNeuronBase || !m_cForgetGate.Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronBase || !m_cInputGate.Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronBase || !m_cOutputGate.Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronBase || !m_cNewContent.Load(file_handle))
      return false;
//--- initialize Memory
   if(m_cMemorys.Total() > 0)
      m_cMemorys.Clear();
   CBufferType *buffer =  CreateBuffer(m_cMemorys);
   if(!buffer)
      return false;
   if(!m_cMemorys.Add(buffer))
      return false;
//--- initialize HiddenStates
   if(m_cHiddenStates.Total() > 0)
      m_cHiddenStates.Clear();
   buffer =  CreateBuffer(m_cHiddenStates);
   if(!buffer)
      return false;
   if(!m_cHiddenStates.Add(buffer))
      return false;
//--- clear the remaining stacks
   if(!m_cInputs)
      m_cInputs.Clear();
   if(!m_cForgetGateOuts)
      m_cForgetGateOuts.Clear();
   if(!m_cInputGateOuts)
      m_cInputGateOuts.Clear();
   if(!m_cNewContentOuts)
      m_cNewContentOuts.Clear();
   if(!m_cOutputGateOuts)
      m_cOutputGateOuts.Clear();
//---
   return true;
  }
//+------------------------------------------------------------------+
