//+------------------------------------------------------------------+
//|                                            NeuronMHAttention.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include "neuronattention.mqh"
//+------------------------------------------------------------------+
//| Class CNeuronMHAttention                                         |
//| Purpose: Class for implementing the multi-head attention block   |
//+------------------------------------------------------------------+
class CNeuronMHAttention    :  public CNeuronAttention
  {
protected:
   CNeuronConv       m_cW0;

   int               m_iHeads;

public:
                     CNeuronMHAttention(void);
                    ~CNeuronMHAttention(void);
   //---
   virtual bool      Init(const CLayerDescription *desc) override;
   virtual bool      SetOpenCL(CMyOpenCL *opencl) override;
   virtual bool      FeedForward(CNeuronBase *prevLayer) override;
   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;
   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read) override;
   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,
                                   VECTOR &Beta, VECTOR &Lambda) override;
   //--- file handling methods
   virtual bool      Save(const int file_handle) override;
   virtual bool      Load(const int file_handle) override;
   //--- object identification method
   virtual int       Type(void) override const { return(defNeuronMHAttention);  }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNeuronMHAttention::CNeuronMHAttention(void) :  m_iHeads(8)
  {
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CNeuronMHAttention::~CNeuronMHAttention(void)
  {
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronMHAttention::Init(const CLayerDescription *desc)
  {
//--- check source data
   if(!desc || desc.type != Type() ||
      desc.count <= 0 || desc.window <= 0 || desc.window_out <= 0 ||
      desc.step <= 0)
      return false;
//--- save constants
   m_iWindow = desc.window;
   m_iUnits = desc.count;
   m_iKeysSize = desc.window_out;
   m_iHeads = desc.step;
//--- call the initialization method of the parent class
   CLayerDescription* temp = new CLayerDescription();
   if(!temp)
      return false;
   temp.type = desc.type;
   temp.optimization = desc.optimization;
   temp.activation = AF_NONE;
   temp.count = desc.count;
   temp.window_out = 1;
   temp.window = 0;
   if(!CNeuronBase::Init(temp))
     {
      delete temp;
      return false;
     }
//--- initialize AttentionOut
   temp.type = defNeuronBase;
   temp.count = (int)(m_iUnits * m_iKeysSize * m_iHeads);
   if(!m_cAttentionOut.Init(temp))
     {
      delete temp;
      return false;
     }
   if(!m_cAttentionOut.GetOutputs().m_mMatrix.Reshape(m_iUnits, m_iKeysSize * m_iHeads) ||
      !m_cAttentionOut.GetGradients().m_mMatrix.Reshape(m_iUnits, m_iKeysSize * m_iHeads))
      return false;
//--- create a description for the internal neural layers
   if(!temp)
      return false;
   temp.type = defNeuronConv;
   temp.window = m_iWindow;
   temp.window_out = (int)(m_iKeysSize * m_iHeads);
   temp.step = m_iWindow;
   temp.count = m_iUnits;
//--- initialize Querys
   if(!m_cQuerys.Init(temp))
     {
      delete temp;
      return false;
     }
   m_cQuerys.SetTransposedOutput(true);
//--- initialize Keys
   if(!m_cKeys.Init(temp))
     {
      delete temp;
      return false;
     }
   m_cKeys.SetTransposedOutput(true);
//--- initialize Values
   if(!m_cValues.Init(temp))
     {
      delete temp;
      return false;
     }
   m_cValues.SetTransposedOutput(true);
//--- initialize Scores
   if(!m_cScores.BufferInit(m_iHeads, m_iUnits * m_iUnits))
     {
      delete temp;
      return false;
     }
//--- initialize W0
   temp.window = (int)(m_iKeysSize * m_iHeads);
   temp.step = temp.window;
   temp.window_out = m_iWindow;
   if(!m_cW0.Init(temp))
     {
      delete temp;
      return false;
     }
   m_cW0.SetTransposedOutput(true);
//--- initialize FF1
   temp.window = m_iWindow;
   temp.step = temp.window;
   temp.window_out = temp.window * 4;
   temp.activation = AF_SWISH;
   temp.activation_params[0] = 1;
   temp.activation_params[1] = 0;
   if(!m_cFF1.Init(temp))
     {
      delete temp;
      return false;
     }
   m_cFF1.SetTransposedOutput(true);
//--- initialize FF2
   temp.window = temp.window_out;
   temp.window_out = temp.step;
   temp.step = temp.window;
   temp.activation = desc.activation;
   temp.activation_params = desc.activation_params;
   if(!m_cFF2.Init(temp))
     {
      delete temp;
      return false;
     }
   m_cFF2.SetTransposedOutput(true);
   delete temp;
//--- to avoid copying buffers, substitute them
   if(!SetOutputs(m_cFF2.GetOutputs()))
      return false;
   if(m_cGradients)
      delete m_cGradients;
   m_cGradients = m_cFF2.GetGradients();
//---
   SetOpenCL(m_cOpenCL);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for passing a pointer to the OpenCL object to all         |
//| internal objects                                                 |
//+------------------------------------------------------------------+
bool CNeuronMHAttention::SetOpenCL(CMyOpenCL *opencl)
  {
//--- call of the method of the parent class
   CNeuronAttention::SetOpenCL(opencl);
//--- call the relevant method for the inner layer
   m_cW0.SetOpenCL(m_cOpenCL);
//---
   return(!!m_cOpenCL);
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronMHAttention::FeedForward(CNeuronBase *prevLayer)
  {
//--- check the relevance of all objects
   if(!prevLayer || !prevLayer.GetOutputs())
      return false;
//---
   if(!m_cQuerys.FeedForward(prevLayer))
      return false;
   if(!m_cKeys.FeedForward(prevLayer))
      return false;
   if(!m_cValues.FeedForward(prevLayer))
      return false;
//--- initialize AttentionOut
   if(!m_cAttentionOut.GetOutputs())
      return false;
//--- branching of the algorithm across computing devices
   MATRIX out;
   if(!m_cOpenCL)
     {
      if(!out.Init(m_iHeads, m_iUnits * m_iKeysSize))
         return false;
      MATRIX querys[], keys[], values[];
      if(!m_cQuerys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, querys))
         return false;
      if(!m_cKeys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, keys))
         return false;
      if(!m_cValues.GetOutputs().m_mMatrix.Vsplit(m_iHeads, values))
         return false;
      for(int head = 0; head < m_iHeads; head++)
        {
         //--- define Scores
         MATRIX sc = exp(querys[head].MatMul(keys[head].Transpose()) / sqrt(m_iKeysSize));
         VECTOR sum = sc.Sum(1);
         for(uint r = 0; r < sc.Rows(); r++)
            if(!sc.Row(sc.Row(r) / sum[r], r))
               return false;
         //--- output of the Attention block
         MATRIX temp = sc.MatMul(values[head]).Transpose();
         if(!temp.Reshape(1, m_iUnits * m_iKeysSize))
            return false;
         if(!sc.Reshape(1, m_iUnits * m_iUnits))
            return false;
         if(!m_cScores.m_mMatrix.Row(sc.Row(0), head))
            return false;
         if(!out.Row(temp.Row(0), head))
            return false;
        }
      if(!out.Reshape(m_iHeads * m_iKeysSize, m_iUnits))
         return false;
      m_cAttentionOut.GetOutputs().m_mMatrix = out.Transpose();
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(m_cQuerys.GetOutputs().GetIndex() < 0)
         return false;
      if(m_cKeys.GetOutputs().GetIndex() < 0)
         return false;
      if(m_cValues.GetOutputs().GetIndex() < 0)
         return false;
      if(m_cScores.GetIndex() < 0)
         return false;
      if(m_cAttentionOut.GetOutputs().GetIndex() < 0)
         return false;
      //--- pass parameters to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_keys, m_cKeys.GetOutputs().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_outputs, m_cAttentionOut.GetOutputs().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_querys, m_cQuerys.GetOutputs().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_scores, m_cScores.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionFeedForward, def_attff_values, m_cValues.GetOutputs().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward, def_attff_key_size, m_iKeysSize))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward, def_attff_window, m_iKeysSize))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward, def_attff_mask, 0))
         return false;
      //--- place kernel to the execution queue
      int off_set[] = {0, 0};
      int NDRange[] = {m_iUnits, m_iHeads};
      if(!m_cOpenCL.Execute(def_k_AttentionFeedForward, 2, off_set, NDRange))
         return false;
     }
//---
   if(!m_cW0.FeedForward(GetPointer(m_cAttentionOut)))
      return false;
//--- sum with source data and normalize
   if(!m_cW0.GetOutputs().SumArray(prevLayer.GetOutputs()))
      return false;
   if(!NormlizeBuffer(m_cW0.GetOutputs(), GetPointer(m_cStd), 0))
      return false;
//---
   if(!m_cFF1.FeedForward(GetPointer(m_cW0)))
      return false;
   if(!m_cFF2.FeedForward(GetPointer(m_cFF1)))
      return false;
//--- sum with the attention output and normalize
   if(!m_cOutputs.SumArray(m_cW0.GetOutputs()))
      return false;
   if(!NormlizeBuffer(m_cOutputs, GetPointer(m_cStd), 1))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating error gradient through hidden layer       |
//+------------------------------------------------------------------+
bool CNeuronMHAttention::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- check the relevance of all objects
   if(!m_cOutputs || !m_cGradients ||
      m_cOutputs.Total() != m_cGradients.Total())
      return false;
//--- scale the gradient for normalization
   if(!NormlizeBufferGradient(m_cOutputs, m_cGradients, GetPointer(m_cStd), 1))
      return false;
//--- propagate error gradient through the Feed Forward block
   if(!m_cFF2.CalcHiddenGradient(GetPointer(m_cFF1)))
      return false;
   if(!m_cFF1.CalcHiddenGradient(GetPointer(m_cW0)))
      return false;
   if(!m_cW0.GetGradients().SumArray(m_cGradients))
      return false;
//--- adjust the gradient for normalization
   if(!NormlizeBufferGradient(m_cW0.GetOutputs(), m_cW0.GetGradients(), GetPointer(m_cStd), 0))
      return false;
//--- distribute error gradient to attention heads
   if(!m_cW0.CalcHiddenGradient(GetPointer(m_cAttentionOut)))
      return false;
//--- branching of the algorithm across computing devices
   if(!m_cOpenCL)
     {
      MATRIX gradients[];
      MATRIX querys[], querys_grad = MATRIX::Zeros(m_iHeads, m_iUnits * m_iKeysSize);
      MATRIX keys[], keys_grad = MATRIX::Zeros(m_iHeads, m_iUnits * m_iKeysSize);
      MATRIX values[], values_grad = MATRIX::Zeros(m_iHeads, m_iUnits * m_iKeysSize);
      MATRIX attention_grad = m_cAttentionOut.GetGradients().m_mMatrix;
      if(!m_cQuerys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, querys) ||
         !m_cKeys.GetOutputs().m_mMatrix.Vsplit(m_iHeads, keys) ||
         !m_cValues.GetOutputs().m_mMatrix.Vsplit(m_iHeads, values) ||
         !attention_grad.Reshape(m_iUnits, m_iHeads * m_iKeysSize) ||
         !attention_grad.Vsplit(m_iHeads, gradients))
         return false;
      for(int head = 0; head < m_iHeads; head++)
        {
      //--- gradient propagation to Values
         MATRIX score = MATRIX::Zeros(1, m_iUnits * m_iUnits);
         if(!score.Row(m_cScores.m_mMatrix.Row(head), 0) ||
            !score.Reshape(m_iUnits, m_iUnits))
            return false;
         MATRIX temp = (score.Transpose().MatMul(gradients[head])).Transpose();
         if(!temp.Reshape(1, m_iUnits * m_iKeysSize) ||
            !values_grad.Row(temp.Row(0), head))
            return false;
         //--- gradient propagation to Score
         gradients[head] = gradients[head].MatMul(values[head].Transpose());
         //--- adjust gradient to the SoftMax derivative
         for(int r = 0; r < m_iUnits; r++)
           {
            MATRIX ident = MATRIX::Identity(m_iUnits, m_iUnits);
            MATRIX ones = MATRIX::Ones(m_iUnits, 1);
            MATRIX result = MATRIX::Zeros(1, m_iUnits);
            if(!result.Row(score.Row(r), 0))
               return false;
            result = ones.MatMul(result);
            result = result.Transpose() * (ident - result);
            if(!gradients[head].Row(result.MatMul(gradients[head].Row(r)) / sqrt(m_iKeysSize), r))
               return false;
           }
         //--- gradient propagation to Querys and Keys
         temp = (gradients[head].MatMul(keys[head])).Transpose();
         if(! temp.Reshape(1, m_iUnits * m_iKeysSize) ||
            !querys_grad.Row(temp.Row(0), head))
            return false;
         temp = (gradients[head].Transpose().MatMul(querys[head])).Transpose();
         if(! temp.Reshape(1, m_iUnits * m_iKeysSize) ||
            !keys_grad.Row(temp.Row(0), head))
            return false;
        }
      //---
      if(!querys_grad.Reshape(m_iHeads * m_iKeysSize, m_iUnits) ||
         !keys_grad.Reshape(m_iHeads * m_iKeysSize, m_iUnits) ||
         !values_grad.Reshape(m_iHeads * m_iKeysSize, m_iUnits))
         return false;
      m_cQuerys.GetGradients().m_mMatrix = querys_grad.Transpose();
      m_cKeys.GetGradients().m_mMatrix = keys_grad.Transpose();
      m_cValues.GetGradients().m_mMatrix = values_grad.Transpose();
     }
   else // OpenCL block
     {
      //--- check data buffers
      if(m_cValues.GetOutputs().GetIndex() < 0)
         return false;
      if(m_cValues.GetGradients().GetIndex() < 0)
         return false;
      if(m_cScores.GetIndex() < 0)
         return false;
      if(m_cAttentionOut.GetGradients().GetIndex() < 0)
         return false;
      if(m_cScoreGrad < 0)
         return false;
      if(m_cScoreTemp < 0)
         return false;
      //--- pass parameters to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients, def_attscr_outputs_grad, m_cAttentionOut.GetGradients().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients, def_attscr_scores, m_cScores.GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients, def_attscr_scores_grad, m_cScoreGrad))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients, def_attscr_scores_temp, m_cScoreTemp))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients, def_attscr_values, m_cValues.GetOutputs().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionScoreGradients, def_attscr_values_grad, m_cValues.GetGradients().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AttentionScoreGradients, def_attscr_window, m_iKeysSize))
         return false;
      //--- place kernel to the execution queue
      int off_set[] = {0, 0};
      int NDRange[] = {m_iUnits, m_iHeads};
      if(!m_cOpenCL.Execute(def_k_AttentionScoreGradients, 2, off_set, NDRange))
         return false;
      //--- check data buffers
      if(m_cQuerys.GetOutputs().GetIndex() < 0)
         return false;
      if(m_cQuerys.GetGradients().GetIndex() < 0)
         return false;
      if(m_cKeys.GetOutputs().GetIndex() < 0)
         return false;
      if(m_cKeys.GetGradients().GetIndex() < 0)
         return false;
      //--- pass arguments to the kernel
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients, def_atthgr_keys, m_cKeys.GetOutputs().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients, def_atthgr_keys_grad, m_cKeys.GetGradients().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients, def_atthgr_querys, m_cQuerys.GetOutputs().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients, def_atthgr_querys_grad, m_cQuerys.GetGradients().GetIndex()))
         return false;
      if(!m_cOpenCL.SetArgumentBuffer(def_k_AttentionHiddenGradients, def_atthgr_scores_grad, m_cScoreGrad))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AttentionHiddenGradients, def_atthgr_key_size, m_iKeysSize))
         return false;
      //--- place kernel to the execution queue
      if(!m_cOpenCL.Execute(def_k_AttentionHiddenGradients, 2, off_set, NDRange))
         return false;
     }
//--- propagate error gradient to the previous year
   if(!m_cW0.CalcDeltaWeights(GetPointer(m_cAttentionOut), false))
      return false;
   CBufferType* attention_grad = m_cW0.GetGradients();
   if(!m_cValues.CalcHiddenGradient(prevLayer))
      return false;
   if(!attention_grad.SumArray(prevLayer.GetGradients()))
      return false;
   if(!m_cQuerys.CalcHiddenGradient(prevLayer))
      return false;
   if(!attention_grad.SumArray(prevLayer.GetGradients()))
      return false;
   if(!m_cKeys.CalcHiddenGradient(prevLayer))
      return false;
   if(!prevLayer.GetGradients().SumArray(attention_grad))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating the error gradient to the weight matrix   |
//+------------------------------------------------------------------+
bool CNeuronMHAttention::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)
  {
//--- call the relevant method for all internal layers
   if(!m_cFF2.CalcDeltaWeights(GetPointer(m_cFF1), false))
      return false;
   if(!m_cFF1.CalcDeltaWeights(GetPointer(m_cW0), false))
      return false;
   if(!m_cQuerys.CalcDeltaWeights(prevLayer, false))
      return false;
   if(!m_cKeys.CalcDeltaWeights(prevLayer, false))
      return false;
   if(!m_cValues.CalcDeltaWeights(prevLayer, read))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for updating weight matrices                              |
//+------------------------------------------------------------------+
bool CNeuronMHAttention::UpdateWeights(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda)
  {
//--- call of the method of the parent class
   if(!CNeuronAttention::UpdateWeights(batch_size, learningRate, Beta, Lambda))
      return false;
//--- call the relevant method for all internal layers
   if(!m_cW0.UpdateWeights(batch_size, learningRate, Beta, Lambda))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNeuronMHAttention::Save(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronAttention::Save(file_handle))
      return false;
//--- save constants
   if(FileWriteInteger(file_handle, m_iHeads) <= 0)
      return false;
//--- call the relevant method for all internal layers
   if(!m_cW0.Save(file_handle))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from saved data                   |
//+------------------------------------------------------------------+
bool CNeuronMHAttention::Load(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronAttention::Load(file_handle))
      return false;
//--- load constants
   m_iHeads = FileReadInteger(file_handle);
//--- call the relevant method for all internal layers
   if(FileReadInteger(file_handle) != defNeuronConv || !m_cW0.Load(file_handle))
      return false;
//--- initialize Scores
   if(!m_cScores.BufferInit(m_iHeads, m_iUnits * m_iUnits))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
