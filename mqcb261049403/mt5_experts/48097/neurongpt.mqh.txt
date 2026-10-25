//+------------------------------------------------------------------+
//|                                                    NeuronGPT.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#ifndef ArrayLayers
#include "arraylayers.mqh"
#endif
//+------------------------------------------------------------------+
//| Class CNeuronGPT                                                 |
//| Purpose: GPT block implementing class                            |
//+------------------------------------------------------------------+
class CNeuronGPT    :  public CNeuronBase
  {
protected:
   CArrayLayers      m_cQuerys;
   CArrayLayers      m_cKeys;
   CArrayLayers      m_cValues;
   CArrayLayers      m_cScores;
   CArrayLayers      m_cAttentionOut;
   CArrayLayers      m_cW0;
   CArrayLayers      m_cFF1;
   CArrayLayers      m_cFF2;
   //---
   int               m_iLayers;
   int               m_iWindow;
   int               m_iUnits;
   int               m_iKeysSize;
   int               m_iHeads;
   CBufferType       m_dStd[];
   int               m_iCurrentPosition;
   int               m_iScoreTemp;

   virtual bool      NormlizeBuffer(CBufferType *buffer, CBufferType *std, uint std_shift);
   virtual bool      NormlizeBufferGradient(CBufferType *output, CBufferType *gradient, CBufferType *std, uint std_shift);

public:
                     CNeuronGPT(void);
                    ~CNeuronGPT(void);
   //---
   virtual bool      Init(const CLayerDescription *desc) override;
   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;
   virtual bool      FeedForward(CNeuronBase *prevLayer) override;
   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;
   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override;
   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,
                                   VECTOR &Beta, VECTOR &Lambda) override;
   //---
   virtual int       GetUnits(void) const { return m_iUnits;   }
   virtual int       GetLayers(void) const { return m_iLayers; }
   //--- file handling methods
   virtual bool      Save(const int file_handle) override;
   virtual bool      Load(const int file_handle) override;
   //--- object identification method
   virtual int       Type(void) override  const { return(defNeuronGPT);  }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNeuronGPT::CNeuronGPT(void) :   m_iHeads(8),
   m_iWindow(0),
   m_iKeysSize(0),
   m_iUnits(0),
   m_iLayers(0),
   m_iCurrentPosition(0)
  {
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CNeuronGPT::~CNeuronGPT(void)
  {
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronGPT::Init(const CLayerDescription *desc)
  {
//--- check source data
   if(!desc || desc.type != Type() || desc.count <= 0 || desc.window <= 0 ||
      desc.window_out <= 0 || desc.step <= 0 || desc.layers <= 0)
      return false;
//--- save constants
   m_iWindow   = desc.window;
   m_iUnits    = desc.count;
   m_iKeysSize = desc.window_out;
   m_iHeads    = desc.step;
   m_iLayers   = desc.layers;
   if(!ArrayResize(m_dStd, m_iLayers))
      return false;
   for(int l = 0; l < m_iLayers; l++)
      if(!m_dStd[l].BufferInit(1, 2, 1))
         return false;
//--- call the initialization method of the parent class
   CLayerDescription *temp = new CLayerDescription();
   if(!temp || !temp.Copy(desc))
      return false;
   temp.window_out = 1;
   temp.window     = 0;
   temp.activation = AF_NONE;
   if(!CNeuronBase::Init(desc))
      return false;
   delete temp;
//--- run a loop to create internal layer objects
   for(int layer = 0; layer < m_iLayers; layer++)
     {
      //--- create a description for the internal neural layers
      temp = new CLayerDescription();
      if(!temp)
         return false;
      temp.type = defNeuronBase;
      temp.window = m_iWindow;
      temp.count = (int)(3 * m_iKeysSize * m_iHeads);
      temp.activation = AF_NONE;
      temp.optimization = desc.optimization;
      //--- initialize Querys
      CNeuronBase *Querys = new CNeuronBase();
      if(!Querys)
        {
         delete temp;
         return false;
        }
      if(!Querys.Init(temp))
        {
         delete Querys;
         delete temp;
         return false;
        }
      if(!m_cQuerys.Add(Querys))
        {
         delete Querys;
         delete temp;
         return false;
        }
      //--- initialize Keys
      CNeuronBase *Keys = new CNeuronBase();
      if(!Keys)
        {
         delete temp;
         return false;
        }
      temp.window = 0;
      temp.count = (int)(m_iUnits * m_iKeysSize * m_iHeads);
      if(!Keys.Init(temp))
        {
         delete Keys;
         delete temp;
         return false;
        }
      if(!Keys.GetOutputs().Reshape(m_iUnits, m_iKeysSize * m_iHeads))
         return false;
      if(!m_cKeys.Add(Keys))
        {
         delete Keys;
         delete temp;
         return false;
        }
      //--- initialize Values
      CNeuronBase *Values = new CNeuronBase();
      if(!Values)
        {
         delete temp;
         return false;
        }
      if(!Values.Init(temp))
        {
         delete Values;
         delete temp;
         return false;
        }
      if(!Values.GetOutputs().Reshape(m_iUnits, m_iKeysSize * m_iHeads))
         return false;
      if(!m_cValues.Add(Values))
        {
         delete Values;
         delete temp;
         return false;
        }
      //--- initialize Scores
      CNeuronBase *Scores = new CNeuronBase();
      if(!Scores)
        {
         delete temp;
         return false;
        }
      temp.count = (int)(m_iUnits * m_iHeads);
      if(!Scores.Init(temp))
        {
         delete Scores;
         delete temp;
         return false;
        }
      if(!Scores.GetOutputs().Reshape(m_iHeads, m_iUnits))
         return false;
      if(!m_cScores.Add(Scores))
        {
         delete Scores;
         delete temp;
         return false;
        }
      //--- initialize AttentionOut
      CNeuronBase *AttentionOut = new CNeuronBase();
      if(!AttentionOut)
        {
         delete temp;
         return false;
        }
      temp.count = (int)(m_iKeysSize * m_iHeads);
      if(!AttentionOut.Init(temp))
        {
         delete AttentionOut;
         delete temp;
         return false;
        }
      if(!AttentionOut.GetOutputs().Reshape(m_iHeads, m_iKeysSize))
         return false;
      if(!m_cAttentionOut.Add(AttentionOut))
        {
         delete AttentionOut;
         delete temp;
         return false;
        }
      //--- initialize W0
      CNeuronBase *W0 = new CNeuronBase();
      if(!W0)
        {
         delete temp;
         return false;
        }
      temp.window = temp.count;
      temp.count = m_iWindow;
      temp.activation = AF_NONE;
      if(!W0.Init(temp))
        {
         delete W0;
         delete temp;
         return false;
        }
      if(!m_cW0.Add(W0))
        {
         delete W0;
         delete temp;
         return false;
        }
      //--- initialize FF1
      CNeuronBase *FF1 = new CNeuronBase();
      if(!FF1)
        {
         delete temp;
         return false;
        }
      temp.window = m_iWindow;
      temp.count = temp.window * 4;
      temp.activation = AF_SWISH;
      temp.activation_params[0] = 1;
      temp.activation_params[1] = 0;
      if(!FF1.Init(temp))
        {
         delete FF1;
         delete temp;
         return false;
        }
      if(!m_cFF1.Add(FF1))
        {
         delete FF1;
         delete temp;
         return false;
        }
      //--- initialize FF2
      CNeuronBase *FF2 = new CNeuronBase();
      if(!FF2)
        {
         delete temp;
         return false;
        }
      temp.window = temp.count;
      temp.count = m_iWindow;
      temp.activation = AF_NONE;
      if(!FF2.Init(temp))
        {
         delete FF2;
         delete temp;
         return false;
        }
      if(!m_cFF2.Add(FF2))
        {
         delete FF2;
         delete temp;
         return false;
        }
      delete temp;
     }
//--- to avoid copying buffers, substitute them
   if(m_cFF2.Total() < m_iLayers)
      return false;
   if(!m_cOutputs)
      delete m_cOutputs;
   CNeuronBase *neuron = m_cFF2.At(m_iLayers - 1);
   if(!neuron)
      return false;
   m_cOutputs = neuron.GetOutputs();
   if(!m_cGradients)
      delete m_cGradients;
   m_cGradients = neuron.GetGradients();
//---
   SetOpenCL(m_cOpenCL);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for passing a pointer to the OpenCL object to all         |
//| internal objects                                                 |
//+------------------------------------------------------------------+
bool CNeuronGPT::SetOpenCL(CMyOpenCL *opencl)
  {
   CNeuronBase::SetOpenCL(opencl);
   m_cQuerys.SetOpencl(m_cOpenCL);
   m_cKeys.SetOpencl(m_cOpenCL);
   m_cValues.SetOpencl(m_cOpenCL);
   m_cScores.SetOpencl(m_cOpenCL);
   m_cAttentionOut.SetOpencl(m_cOpenCL);
   m_cW0.SetOpencl(m_cOpenCL);
   m_cFF1.SetOpencl(m_cOpenCL);
   m_cFF2.SetOpencl(m_cOpenCL);
   if(m_cOpenCL)
     {
      uint size = sizeof(TYPE) * m_iUnits * m_iHeads;
      m_iScoreTemp = m_cOpenCL.AddBuffer(size, CL_MEM_READ_WRITE);
      for(int l = 0; l < m_iLayers; l++)
         m_dStd[l].BufferCreate(m_cOpenCL);
     }
   else
     {
      for(int l = 0; l < m_iLayers; l++)
         m_dStd[l].BufferFree();
     }
//---
   return(!!m_cOpenCL);
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronGPT::FeedForward(CNeuronBase *prevLayer)
  {
//--- check the relevance of all objects
   if(!prevLayer || !prevLayer.GetOutputs())
      return false;
//--- increment the pointer to the current object on the data stack
   m_iCurrentPosition++;
   if(m_iCurrentPosition >= m_iUnits)
      m_iCurrentPosition = 0;
//--- run a loop iterating through all internal layers
   CNeuronBase *prevL = prevLayer;
   for(int layer = 0; layer < m_iLayers; layer++)
     {
      CNeuronBase *Querys = m_cQuerys.At(layer);
      if(!Querys || !Querys.FeedForward(prevL))
         return false;
      CNeuronBase *Keys = m_cKeys.At(layer);
      if(!Keys)
         return false;
      CNeuronBase *Values = m_cValues.At(layer);
      if(!Values)
         return false;
      //--- initialize Scores
      CNeuronBase *Scores = m_cScores.At(layer);
      if(!Scores)
         return false;
      //--- initialize AttentionOut
      CNeuronBase *AttentionOut = m_cAttentionOut.At(layer);
      if(!AttentionOut)
         return false;
      //--- branching of the algorithm across computing devices
      if(!m_cOpenCL)
        {
         MATRIX array[];
         if(!Querys.GetOutputs().m_mMatrix.Vsplit(3, array))
            return false;
         if(!Keys.GetOutputs().Row(array[1].Row(0), m_iCurrentPosition))
            return false;
         if(!Values.GetOutputs().Row(array[2].Row(0), m_iCurrentPosition))
            return false;
         MATRIX out;
         if(!out.Init(m_iHeads, m_iKeysSize))
            return false;
         MATRIX array_keys[], array_values[];
         MATRIX array_querys[];
         MATRIX keys = Keys.GetOutputs().m_mMatrix;
         MATRIX values = Values.GetOutputs().m_mMatrix;
         if(!array[0].Vsplit(m_iHeads, array_querys))
            return false;
         if(!keys.Reshape(m_iUnits, m_iHeads * m_iKeysSize))
            return false;
         if(!keys.Vsplit(m_iHeads, array_keys))
            return false;
         if(!values.Reshape(m_iUnits, m_iHeads * m_iKeysSize))
            return false;
         if(!values.Vsplit(m_iHeads, array_values))
            return false;
         //--- define Scores
         for(int head = 0; head < m_iHeads; head++)
           {
            MATRIX score = array_querys[head].MatMul(array_keys[head].Transpose()) / sqrt(m_iKeysSize);
            //--- normalize Scores
            if(!score.Activation(score, AF_SOFTMAX))
               return false;
            if(!Scores.GetOutputs().Row(score.Row(0), head))
               return false;
            //--- output of the Attention block
            if(!out.Row(score.MatMul(array_values[head]).Row(0), head))
               return false;
           }
         if(!out.Reshape(1, m_iHeads * m_iKeysSize))
            return false;
         AttentionOut.GetOutputs().m_mMatrix = out;
        }
      else // OpenCL block
        {
         //--- check data buffers
         if(Querys.GetOutputs().GetIndex() < 0)
            return false;
         if(Keys.GetOutputs().GetIndex() < 0)
            return false;
         if(Values.GetOutputs().GetIndex() < 0)
            return false;
         if(Scores.GetOutputs().GetIndex() < 0)
            return false;
         if(AttentionOut.GetOutputs().GetIndex() < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward, def_gptff_keys, Keys.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward, def_gptff_outputs, AttentionOut.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward, def_gptff_querys, Querys.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward, def_gptff_scores, Scores.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTFeedForward, def_gptff_values, Values.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTFeedForward, def_gptff_key_size, m_iKeysSize))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTFeedForward, def_gptff_units, m_iUnits))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTFeedForward, def_gptff_current, m_iCurrentPosition))
            return false;
         //--- place kernel to the execution queue
         int off_set[] = {0};
         int NDRange[] = {m_iHeads};
         if(!m_cOpenCL.Execute(def_k_GPTFeedForward, 1, off_set, NDRange))
            return false;
        }
      //--- weighted output of all attention heads
      CNeuronBase *W0 = m_cW0.At(layer);
      if(!W0 || !W0.FeedForward(AttentionOut))
         return false;
      //--- sum with source data and normalize
      if(!W0.GetOutputs().SumArray(prevL.GetOutputs()))
         return false;
      if(!NormlizeBuffer(W0.GetOutputs(), GetPointer(m_dStd[layer]), 0))
         return false;
      //--- Feed Forward block run
      CNeuronBase *FF1 = m_cFF1.At(layer);
      if(!FF1 || !FF1.FeedForward(W0))
         return false;
      CNeuronBase *FF2 = m_cFF2.At(layer);
      if(!FF2 || !FF2.FeedForward(FF1))
         return false;
      //--- sum with the Attention output and normalize
      CBufferType *prev = FF2.GetOutputs();
      if(!prev.SumArray(W0.GetOutputs()))
         return false;
      if(!NormlizeBuffer(prev, GetPointer(m_dStd[layer]), 1))
         return false;
      prevL = FF2;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating gradient through hidden layer             |
//+------------------------------------------------------------------+
bool CNeuronGPT::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- check the relevance of all objects
   if(!m_cOutputs || !m_cGradients ||
      m_cOutputs.Total() != m_cGradients.Total())
      return false;
//--- run a loop iterating through all internal layers in reverser order
   for(int layer = m_iLayers - 1; layer >= 0; layer--)
     {
      CNeuronBase *FF2 = m_cFF2.At(layer);
      if(!FF2)
         return false;
      CBufferType *Gradients = FF2.GetGradients();
      //--- scale the gradient for normalization
      if(!NormlizeBufferGradient(FF2.GetOutputs(), Gradients, GetPointer(m_dStd[layer]), 1))
         return false;
      //--- propagate the gradient through the Feed Forward block
      CNeuronBase *FF1 = m_cFF1.At(layer);
      if(!FF2.CalcHiddenGradient(FF1))
         return false;
      CNeuronBase *W0 = m_cW0.At(layer);
      if(!FF1.CalcHiddenGradient(W0))
         return false;
      CBufferType *attention_grad = W0.GetGradients();
      if(!attention_grad.SumArray(Gradients))
         return false;
      //--- scale the gradient for normalization
      if(!NormlizeBufferGradient(W0.GetOutputs(), attention_grad, GetPointer(m_dStd[layer]), 0))
         return false;
      //--- initialize Scores
      CNeuronBase *Scores = m_cScores.At(layer);
      if(!Scores)
         return false;
      //--- distribute error gradient to attention heads
      CNeuronBase *AttentionOut = m_cAttentionOut.At(layer);
      if(!W0.CalcHiddenGradient(AttentionOut))
         return false;
      //--- get pointers to objects Querys, Keys, Values
      CNeuronBase *Querys = m_cQuerys.At(layer);
      if(!Querys)
         return false;
      CNeuronBase *Keys = m_cKeys.At(layer);
      if(!Keys)
         return false;
      CNeuronBase *Values = m_cValues.At(layer);
      if(!Values)
         return false;
      //--- branching of the algorithm across computing devices
      attention_grad = AttentionOut.GetGradients();
      if(!m_cOpenCL)
        {
         MATRIX gradients[];
         if(!attention_grad.m_mMatrix.Vsplit(m_iHeads, gradients))
            return false;
         if(!Querys.GetGradients().m_mMatrix.Reshape(3, m_iHeads * m_iKeysSize))
            return false;
         MATRIX values[];
         if(!Values.GetOutputs().m_mMatrix.Vsplit(m_iHeads, values))
            return false;
         MATRIX keys[];
         if(!Keys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, keys))
            return false;
         MATRIX querys[];
         MATRIX query = Querys.GetOutputs().m_mMatrix;
         if(!query.Reshape(3, m_iHeads * m_iKeysSize) ||
            !query.Resize(1, query.Cols()))
            return false;
         if(!query.Vsplit(m_iHeads, querys))
            return false;
         MATRIX querys_grad = MATRIX::Zeros(m_iHeads, m_iKeysSize);
         MATRIX keys_grad = querys_grad;
         MATRIX values_grad = querys_grad;
         for(int head = 0; head < m_iHeads; head++)
           {
            MATRIX score = MATRIX::Zeros(1, m_iUnits);
            if(!score.Row(Scores.GetOutputs().m_mMatrix.Row(head), 0))
               return false;
            //--- gradient propagation to Values
            if(!values_grad.Row((gradients[head]*score[0, m_iCurrentPosition]).Row(0), head))
               return false;
            //--- gradient propagation to Querys and Keys
            MATRIX score_grad = gradients[head].MatMul(values[head].Transpose());
            //---
            MATRIX ident = MATRIX::Identity(m_iUnits, m_iUnits);
            MATRIX ones = MATRIX::Ones(m_iUnits, 1);
            score = ones.MatMul(score);
            score = score.Transpose() * (ident - score);
            score_grad = score_grad.MatMul(score.Transpose()) / sqrt(m_iKeysSize);
            MATRIX temp = score_grad.MatMul(keys[head]);
            if(!querys_grad.Row(temp.Row(0), head))
               return false;
            temp = querys[head] * score_grad[0, m_iCurrentPosition];
            if(!keys_grad.Row(temp.Row(0), head))
               return false;
           }
         if(!querys_grad.Reshape(1, m_iHeads * m_iKeysSize) ||
            !keys_grad.Reshape(1, m_iHeads * m_iKeysSize) ||
            !values_grad.Reshape(1, m_iHeads * m_iKeysSize))
            return false;
         if(!Querys.GetGradients().Row(querys_grad.Row(0), 0) ||
            !Querys.GetGradients().Row(keys_grad.Row(0), 1) ||
            !Querys.GetGradients().Row(values_grad.Row(0), 2))
            return false;
         if(!Querys.GetGradients().Reshape(1, Querys.GetGradients().Total()))
            return false;
        }
      else // OpenCL block
        {
         //--- check data buffers
         if(Values.GetOutputs().GetIndex() < 0)
            return false;
         if(Querys.GetGradients().GetIndex() < 0)
            return false;
         if(Scores.GetOutputs().GetIndex() < 0)
            return false;
         if(attention_grad.GetIndex() < 0)
            return false;
         if(Scores.GetGradients().GetIndex() < 0)
            return false;
         //---
         if(m_iScoreTemp < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients, def_gptscr_outputs_grad, attention_grad.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients, def_gptscr_scores, Scores.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients, def_gptscr_scores_grad, Scores.GetGradients().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients, def_gptscr_scores_temp, m_iScoreTemp))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients, def_gptscr_values, Values.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTScoreGradients, def_gptscr_values_grad, Querys.GetGradients().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTScoreGradients, def_gptscr_window, m_iKeysSize))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTScoreGradients, def_gptscr_units, m_iUnits))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTScoreGradients, def_gptscr_current, m_iCurrentPosition))
            return false;
         //--- place kernel to the execution queue
         int off_set[] = {0};
         int NDRange[] = {m_iHeads};
         if(!m_cOpenCL.Execute(def_k_GPTScoreGradients, 1, off_set, NDRange))
            return false;
         //---
         if(Querys.GetOutputs().GetIndex() < 0)
            return false;
         if(Keys.GetOutputs().GetIndex() < 0)
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTHiddenGradients, def_gpthgr_keys, Keys.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTHiddenGradients, def_gpthgr_querys, Querys.GetOutputs().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTHiddenGradients, def_gpthgr_querys_grad, Querys.GetGradients().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_GPTHiddenGradients, def_gpthgr_scores_grad, Scores.GetGradients().GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTHiddenGradients, def_gpthgr_key_size, m_iKeysSize))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTHiddenGradients, def_gpthgr_units, m_iUnits))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_GPTHiddenGradients, def_gpthgr_current, m_iCurrentPosition))
            return false;
         if(!m_cOpenCL.Execute(def_k_GPTHiddenGradients, 1, off_set, NDRange))
            return false;
        }
      //--- propagate error gradient to the previous year
      CNeuronBase *prevL = (layer == 0 ? prevLayer : m_cFF2.At(layer - 1));
      if(!Querys.CalcHiddenGradient(prevL))
         return false;
      if(!prevL.GetGradients().SumArray(W0.GetGradients()))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating the error gradients                       |
//| to the weight matrix                                             |
//+------------------------------------------------------------------+
bool CNeuronGPT::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)
  {
//--- in a loop we call the relevant method for each internal object
   for(int layer = 0; layer < m_iLayers; layer++)
     {
      if(!m_cFF2.At(layer))
         return false;
      CNeuronBase *temp = m_cFF2.At(layer);
      if(!temp.CalcDeltaWeights(m_cFF1.At(layer), false))
         return false;
      temp = m_cFF1.At(layer);
      if(!temp.CalcDeltaWeights(m_cW0.At(layer), false))
         return false;
      temp = m_cW0.At(layer);
      if(!temp.CalcDeltaWeights(m_cAttentionOut.At(layer), false))
         return false;
      temp = m_cQuerys.At(layer);
      if(!temp)
         return false;
      CNeuronBase *prevL = (layer == 0 ? prevLayer : m_cFF2.At(layer - 1));
      if(!temp.CalcDeltaWeights(prevL, (read && layer == m_iLayers - 1)))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for updating parameters of the weight matrix              |
//+------------------------------------------------------------------+
bool CNeuronGPT::UpdateWeights(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda)
  {
//--- in a loop we call the relevant method for each internal object
   for(int layer = 0; layer < m_iLayers; layer++)
     {
      CNeuronBase *temp = m_cFF2.At(layer);
      if(!temp || !temp.UpdateWeights(batch_size, learningRate, Beta, Lambda))
         return false;
      temp = m_cFF1.At(layer);
      if(!temp || !temp.UpdateWeights(batch_size, learningRate, Beta, Lambda))
         return false;
      temp = m_cW0.At(layer);
      if(!temp || !temp.UpdateWeights(batch_size, learningRate, Beta, Lambda))
         return false;
      temp = m_cQuerys.At(layer);
      if(!temp || !temp.UpdateWeights(batch_size, learningRate, Beta, Lambda))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNeuronGPT::Save(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronBase::Save(file_handle))
      return false;
//--- save constants
   if(FileWriteInteger(file_handle, m_iLayers) <= 0)
      return false;
   if(FileWriteInteger(file_handle, m_iWindow) <= 0)
      return false;
   if(FileWriteInteger(file_handle, m_iKeysSize) <= 0)
      return false;
   if(FileWriteInteger(file_handle, m_iHeads) <= 0)
      return false;
   if(FileWriteInteger(file_handle, m_iUnits) <= 0)
      return false;
   if(FileWriteInteger(file_handle, m_iCurrentPosition) <= 0)
      return false;
//--- call the relevant method for all collections of internal layers
   if(!m_cQuerys.Save(file_handle))
      return false;
   if(!m_cKeys.Save(file_handle))
      return false;
   if(!m_cValues.Save(file_handle))
      return false;
   if(!m_cScores.Save(file_handle))
      return false;
   if(!m_cAttentionOut.Save(file_handle))
      return false;
   if(!m_cW0.Save(file_handle))
      return false;
   if(!m_cFF1.Save(file_handle))
      return false;
   if(!m_cFF2.Save(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from a file                       |
//+------------------------------------------------------------------+
bool CNeuronGPT::Load(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronBase::Load(file_handle))
      return false;
//--- read constants from the file
   m_iLayers = FileReadInteger(file_handle);
   m_iWindow = FileReadInteger(file_handle);
   m_iKeysSize = FileReadInteger(file_handle);
   m_iHeads = FileReadInteger(file_handle);
   m_iUnits = FileReadInteger(file_handle);
   m_iCurrentPosition = FileReadInteger(file_handle);
   if(ArrayResize(m_dStd, m_iLayers) <= 0)
      return false;
   for(int i = 0; i < m_iLayers; i++)
      if(!m_dStd[i].BufferInit(1, 2, 1))
         return false;;
//--- call the relevant method for all collections of internal layers
   if(!m_cQuerys.Load(file_handle))
      return false;
   if(!m_cKeys.Load(file_handle))
      return false;
   if(!m_cValues.Load(file_handle))
      return false;
   if(!m_cScores.Load(file_handle))
      return false;
   if(!m_cAttentionOut.Load(file_handle))
      return false;
   if(!m_cW0.Load(file_handle))
      return false;
   if(!m_cFF1.Load(file_handle))
      return false;
   if(!m_cFF2.Load(file_handle))
      return false;
//--- reformat the result matrices
   for(int i = 0; i < m_iLayers; i++)
     {
      CNeuronBase* temp = m_cKeys.At(i);
      if(!temp.GetOutputs().Reshape(m_iUnits, m_iKeysSize * m_iHeads))
         return false;
      temp = m_cValues.At(i);
      if(!temp.GetOutputs().Reshape(m_iUnits, m_iKeysSize * m_iHeads))
         return false;
      temp = m_cScores.At(i);
      if(!temp.GetOutputs().Reshape(m_iHeads, m_iUnits))
         return false;
      temp = m_cAttentionOut.At(i);
      if(!temp.GetOutputs().Reshape(m_iHeads, m_iKeysSize))
         return false;
     }
//--- substitute data buffers to avoid unnecessary copying
   CNeuronBase *last = m_cFF2.At(m_cFF2.Total() - 1);
   if(!m_cOutputs)
      delete m_cOutputs;
   m_cOutputs = last.GetOutputs();
   if(!m_cGradients)
      delete m_cGradients;
   m_cGradients = last.GetGradients();
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronGPT::NormlizeBuffer(CBufferType *buffer, CBufferType *std, uint std_shift)
  {
   if(!m_cOpenCL)
     {
      double mean = buffer.m_mMatrix.Mean();
      std.m_mMatrix[0, std_shift] = buffer.m_mMatrix.Std();
      buffer.m_mMatrix = (buffer.m_mMatrix - mean) / std.m_mMatrix[0, std_shift];
     }
   else
     {
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalize, def_layernorm_inputs, buffer.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalize, def_layernorm_outputs, buffer.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalize, def_layernorm_std, std.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LayerNormalize, def_layernorm_vector_size, (int)buffer.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LayerNormalize, def_layernorm_std_shift, std_shift))
         return false;
      int NDRange[] = {(int)MathMin(m_cOutputs.Total(), 256.0)};
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_LayerNormalize, 1, off_set, NDRange, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronGPT::NormlizeBufferGradient(CBufferType *output, CBufferType *gradient, CBufferType *std, uint std_shift)
  {
   if(std.At(std_shift) <= 0)
      return true;
//---
   if(!m_cOpenCL)
     {
      MATRIX ScG = gradient.m_mMatrix / std.m_mMatrix[0, std_shift];
      MATRIX ScOut = output.m_mMatrix / std.m_mMatrix[0, std_shift];
      TYPE dSTD = (ScG * ScOut / (-2 * MathPow(std.m_mMatrix[0, std_shift], 2))).Sum();
      TYPE dMean = -1 * ScG.Sum() - 2 * dSTD * ScOut.Sum() / (TYPE)output.Total();
      gradient.m_mMatrix = ScG + (ScOut * dSTD * 2 + dMean) / (TYPE)output.Total();
     }
   else
     {
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalizeGradient, def_layernormgr_outputs, output.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalizeGradient, def_layernormgr_inp_grad, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalizeGradient, def_layernormgr_out_grad, gradient.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_LayerNormalizeGradient, def_layernormgr_std, std.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LayerNormalizeGradient, def_layernormgr_vector_size, (int)output.Total()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_LayerNormalizeGradient, def_layernormgr_std_shift, std_shift))
         return false;
      int NDRange[] = {(int)MathMin(output.Total(), LOCAL_SIZE)};
      int off_set[] = {0};
      if(!m_cOpenCL.Execute(def_k_LayerNormalizeGradient, 1, off_set, NDRange, NDRange))
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
