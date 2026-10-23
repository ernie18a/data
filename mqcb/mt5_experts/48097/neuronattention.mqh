//+------------------------------------------------------------------+
//|                                              NeuronAttention.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#ifndef Defines
#include "defines.mqh"
#endif
#include "neuronconv.mqh"
#include <Math\Stat\Math.mqh>
//+------------------------------------------------------------------+
//| Class CNeuronAttention                                           |
//| Purpose: Self-Attention block class                              |
//+------------------------------------------------------------------+
class CNeuronAttention    :  public CNeuronBase
  {
protected:
   CNeuronConv       m_cQuerys;
   CNeuronConv       m_cKeys;
   CNeuronConv       m_cValues;
   CBufferType       m_cScores;
   int               m_cScoreGrad;
   int               m_cScoreTemp;
   CNeuronBase       m_cAttentionOut;
   CNeuronConv       m_cFF1;
   CNeuronConv       m_cFF2;
   //---
   int               m_iWindow;
   int               m_iUnits;
   int               m_iKeysSize;
   CBufferType       m_cStd;
   //---
   virtual bool      NormlizeBuffer(CBufferType *buffer, CBufferType *std, uint std_shift);
   virtual bool      NormlizeBufferGradient(CBufferType *output, CBufferType *gradient, CBufferType *std, uint std_shift);

public:
                     CNeuronAttention(void);
                    ~CNeuronAttention(void);
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
   virtual int       Type(void) override  const { return(defNeuronAttention); }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNeuronAttention::CNeuronAttention(void) :   m_iWindow(1),
   m_iUnits(0),
   m_iKeysSize(1)
  {
   m_cStd.BufferInit(1, 2, 1);
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CNeuronAttention::~CNeuronAttention(void)
  {
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronAttention::Init(const CLayerDescription *desc)
  {
//--- check source data
   if(!desc || desc.type != Type() || desc.count <= 0 || desc.window <= 0 || desc.window_out <= 0)
      return false;
//---
   m_iWindow   = desc.window;
   m_iUnits    = desc.count;
   m_iKeysSize = desc.window_out;
//--- call the initialization method of the parent class
   CLayerDescription *temp = new CLayerDescription();
   if(!temp)
      return false;
   temp.count = desc.count * desc.window;
   temp.window_out = 1;
   temp.window     = 0;
   temp.optimization = desc.optimization;
   temp.activation = desc.activation;
   temp.activation_params = desc.activation_params;
   temp.type = desc.type;
   if(!CNeuronBase::Init(temp))
     {
      delete temp;
      return false;
     }
//--- initialize AttentionOut
   temp.type = defNeuronBase;
   temp.activation = AF_NONE;
   if(!m_cAttentionOut.Init(temp))
     {
      delete temp;
      return false;
     }
//--- create a description for the internal neural layers
   temp.type = defNeuronConv;
   temp.window = desc.window;
   temp.window_out = m_iKeysSize;
   temp.step = desc.window;
   temp.count = desc.count;
   temp.probability = 1;
//--- initialize Querys
   if(!m_cQuerys.Init(temp))
     {
      delete temp;
      return false;
     }
//--- initialize Keys
   if(!m_cKeys.Init(temp))
     {
      delete temp;
      return false;
     }
//--- initialize Values
   temp.window_out = m_iWindow;
   if(!m_cValues.Init(temp))
     {
      delete temp;
      return false;
     }
//--- initialize Scores
   if(!m_cScores.BufferInit(temp.count, temp.count, 0))
     {
      delete temp;
      return false;
     }
//--- initialize FF1
   temp.window_out *= 4;
   temp.activation = AF_SWISH;
   temp.activation_params[0] = 1;
   temp.activation_params[1] = 0;
   if(!m_cFF1.Init(temp) || !m_cFF1.SetTransposedOutput(true))
     {
      delete temp;
      return false;
     }
//--- initialize FF2
   temp.window = temp.window_out;
   temp.window_out = temp.step;
   temp.step = temp.window;
   temp.activation = desc.activation;
   temp.activation_params = desc.activation_params;
   if(!m_cFF2.Init(temp) || !m_cFF2.SetTransposedOutput(true))
     {
      delete temp;
      return false;
     }
   delete temp;
//--- to avoid copying buffers, substitute them
   if(m_cOutputs)
      delete m_cOutputs;
   m_cOutputs = m_cFF2.GetOutputs();
   if(m_cGradients)
      delete m_cGradients;
   m_cGradients = m_cFF2.GetGradients();
//--- pass the pointer to the OpenCL working object to all internal object
   SetOpenCL(m_cOpenCL);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for passing a pointer to the OpenCL object to all         |
//| internal object of the class                                     |
//+------------------------------------------------------------------+
bool CNeuronAttention::SetOpenCL(CMyOpenCL *opencl)
  {
   CNeuronBase::SetOpenCL(opencl);
   m_cQuerys.SetOpenCL(m_cOpenCL);
   m_cKeys.SetOpenCL(m_cOpenCL);
   m_cValues.SetOpenCL(m_cOpenCL);
   m_cAttentionOut.SetOpenCL(m_cOpenCL);
   m_cFF1.SetOpenCL(m_cOpenCL);
   m_cFF2.SetOpenCL(m_cOpenCL);
   if(m_cOpenCL)
     {
      m_cScores.BufferCreate(m_cOpenCL);
      ulong size = sizeof(TYPE) * m_cScores.Total();
      m_cScoreGrad = m_cOpenCL.AddBuffer((uint)size, CL_MEM_READ_WRITE);
      m_cScoreTemp = m_cOpenCL.AddBuffer((uint)size, CL_MEM_READ_WRITE);
      m_cStd.BufferCreate(m_cOpenCL);
     }
   else
     {
      m_cScores.BufferFree();
      m_cStd.BufferFree();
     }
//---
   return(!!m_cOpenCL);
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronAttention::FeedForward(CNeuronBase *prevLayer)
  {
//--- calculate vectors Query, Key, Value
   if(!m_cQuerys.FeedForward(prevLayer))
      return false;
   if(!m_cKeys.FeedForward(prevLayer))
      return false;
   if(!m_cValues.FeedForward(prevLayer))
      return false;
//--- branching of the algorithm across computing devices
   MATRIX out;
   if(!m_cOpenCL)
     {
      MATRIX querys = m_cQuerys.GetOutputs().m_mMatrix;
      MATRIX keys = m_cKeys.GetOutputs().m_mMatrix;
      //--- define Scores
      MATRIX scores = MathExp(querys.MatMul(keys.Transpose()) / sqrt(m_iKeysSize));
      //--- normalize Scores
      VECTOR summs = scores.Sum(1);
      for(int r = 0; r < m_iUnits; r++)
         if(!scores.Row(scores.Row(r) / summs[r], r))
            return false;
      m_cScores.m_mMatrix = scores;
      //--- output of the Attention block
      MATRIX values = m_cValues.GetOutputs().m_mMatrix;
      out = scores.MatMul(values);
      //--- sum with source data and normalize
      if(!out.Reshape(prevLayer.Rows(), prevLayer.Cols()))
         return false;
      m_cAttentionOut.GetOutputs().m_mMatrix = out;
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
      if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward, def_attff_window, m_iWindow))
         return false;
      if(!m_cOpenCL.SetArgument(def_k_AttentionFeedForward, def_attff_mask, 0))
         return false;
      //--- place kernel to the execution queue
      int off_set[] = {0, 0};
      int NDRange[] = {m_iUnits, 1};
      if(!m_cOpenCL.Execute(def_k_AttentionFeedForward, 2, off_set, NDRange))
         return false;
     }
//--- sum with the source data
   if(!m_cAttentionOut.GetOutputs().SumArray(prevLayer.GetOutputs()))
      return false;
//--- normalize
   if(!NormlizeBuffer(m_cAttentionOut.GetOutputs(), GetPointer(m_cStd), 0))
      return false;
//--- call feed-forward pass methods for the Feed Forward block levels
   if(!m_cFF1.FeedForward(GetPointer(m_cAttentionOut)))
      return false;
   if(!m_cFF2.FeedForward(GetPointer(m_cFF1)))
      return false;
//--- sum with the Attention output and normalize
   if(!m_cOutputs.SumArray(m_cAttentionOut.GetOutputs()))
      return false;
//--- normalize
   if(!NormlizeBuffer(m_cOutputs, GetPointer(m_cStd), 1))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating gradient through the hidden layer         |
//+------------------------------------------------------------------+
bool CNeuronAttention::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- check the relevance of all objects
   if(!m_cOutputs || !m_cGradients ||
      m_cOutputs.Total() != m_cGradients.Total())
      return false;
//--- adjust the gradient for normalization
   if(!NormlizeBufferGradient(m_cOutputs, m_cGradients, GetPointer(m_cStd), 1))
      return false;
//--- propagate the gradient through the Feed Forward block
   if(!m_cFF2.CalcHiddenGradient(GetPointer(m_cFF1)))
      return false;
   if(!m_cFF1.CalcHiddenGradient(GetPointer(m_cAttentionOut)))
      return false;
//---
   CBufferType *attention_grad = m_cAttentionOut.GetGradients();
   if(!attention_grad.SumArray(m_cGradients))
      return false;
//--- adjust the gradient for normalization
   if(!NormlizeBufferGradient(m_cAttentionOut.GetOutputs(), attention_grad, GetPointer(m_cStd), 0))
      return false;
//--- branching of the algorithm across computing devices
   if(!m_cOpenCL)
     {
      MATRIX values, gradients;
      if(attention_grad.GetData(gradients, false) < (int)m_cOutputs.Total())
         return false;
      if(!gradients.Reshape(m_iUnits, m_iWindow))
         return false;
      //--- gradient propagation to Values
      m_cValues.GetGradients().m_mMatrix = m_cScores.m_mMatrix.Transpose().MatMul(gradients);
      //--- gradient propagation to Querys and Keys
      values = m_cValues.GetOutputs().m_mMatrix;
      if(!values.Reshape(m_iUnits, m_iWindow))
         return false;
      gradients = gradients.MatMul(values.Transpose());
      for(int r = 0; r < m_iUnits; r++)
        {
         MATRIX ident = MATRIX::Identity(m_iUnits, m_iUnits);
         MATRIX ones = MATRIX::Ones(m_iUnits, 1);
         MATRIX result = MATRIX::Zeros(1, m_iUnits);
         if(!result.Row(m_cScores.m_mMatrix.Row(r), 0))
            return false;
         result = ones.MatMul(result);
         result = result.Transpose() * (ident - result);
         VECTOR temp = result.MatMul(gradients.Row(r));
         if(!gradients.Row(temp / sqrt(m_iKeysSize), r))
            return false;
        }
      m_cQuerys.GetGradients().m_mMatrix = gradients.MatMul(m_cKeys.GetOutputs().m_mMatrix);
      m_cKeys.GetGradients().m_mMatrix = gradients.Transpose().MatMul(m_cQuerys.GetOutputs().m_mMatrix);
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
      if(!m_cOpenCL.SetArgument(def_k_AttentionScoreGradients, def_attscr_window, m_iWindow))
         return false;
      //--- place kernel to the execution queue
      int off_set[] = {0, 0};
      int NDRange[] = {m_iUnits, 1};
      if(!m_cOpenCL.Execute(def_k_AttentionScoreGradients, 2, off_set, NDRange))
         return false;
      //---
      if(m_cQuerys.GetOutputs().GetIndex() < 0)
         return false;
      if(m_cQuerys.GetGradients().GetIndex() < 0)
         return false;
      if(m_cKeys.GetOutputs().GetIndex() < 0)
         return false;
      if(m_cKeys.GetGradients().GetIndex() < 0)
         return false;
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
      if(!m_cOpenCL.Execute(def_k_AttentionHiddenGradients, 2, off_set, NDRange))
         return false;
      //---
     }
//--- propagate error gradient to the previous year
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
//| Method for propagating gradient to the weight matrix             |
//+------------------------------------------------------------------+
bool CNeuronAttention::CalcDeltaWeights(CNeuronBase *prevLayer, bool read)
  {
   if(!m_cFF2.CalcDeltaWeights(GetPointer(m_cFF1), false))
      return false;
   if(!m_cFF1.CalcDeltaWeights(GetPointer(m_cAttentionOut),false))
      return false;
   if(!m_cQuerys.CalcDeltaWeights(prevLayer,false))
      return false;
   if(!m_cKeys.CalcDeltaWeights(prevLayer,false))
      return false;
   if(!m_cValues.CalcDeltaWeights(prevLayer, read))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for updating weight matrices                              |
//+------------------------------------------------------------------+
bool CNeuronAttention::UpdateWeights(int batch_size, TYPE learningRate, VECTOR &Beta, VECTOR &Lambda)
  {
   if(!m_cQuerys.UpdateWeights(batch_size, learningRate, Beta, Lambda))
      return false;
   if(!m_cKeys.UpdateWeights(batch_size, learningRate, Beta, Lambda))
      return false;
   if(!m_cValues.UpdateWeights(batch_size, learningRate, Beta, Lambda))
      return false;
   if(!m_cFF1.UpdateWeights(batch_size, learningRate, Beta, Lambda))
      return false;
   if(!m_cFF2.UpdateWeights(batch_size, learningRate, Beta, Lambda))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for writing class contents to a file                      |
//+------------------------------------------------------------------+
bool CNeuronAttention::Save(const int file_handle)
  {
   if(!CNeuronBase::Save(file_handle))
      return false;
   if(!m_cQuerys.Save(file_handle))
      return false;
   if(!m_cKeys.Save(file_handle))
      return false;
   if(!m_cValues.Save(file_handle))
      return false;
   if(!m_cAttentionOut.Save(file_handle))
      return false;
   if(!m_cFF1.Save(file_handle))
      return false;
   if(!m_cFF2.Save(file_handle))
      return false;
   if(FileWriteInteger(file_handle, m_iUnits) <= 0)
      return false;
   if(FileWriteInteger(file_handle, m_iWindow) <= 0)
      return false;
   if(FileWriteInteger(file_handle, m_iKeysSize) <= 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring class operations from a file                |
//+------------------------------------------------------------------+
bool CNeuronAttention::Load(const int file_handle)
  {
   if(!CNeuronBase::Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronConv || !m_cQuerys.Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronConv || !m_cKeys.Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronConv || !m_cValues.Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronBase || !m_cAttentionOut.Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronConv || !m_cFF1.Load(file_handle))
      return false;
   if(FileReadInteger(file_handle) != defNeuronConv || !m_cFF2.Load(file_handle))
      return false;
   m_iUnits = FileReadInteger(file_handle);
   m_iWindow = FileReadInteger(file_handle);
   m_iKeysSize = FileReadInteger(file_handle);
   if(!m_cScores.BufferInit(m_iUnits, m_iUnits, 0))
      return false;
//---
   if(m_cFF2.GetOutputs() != m_cOutputs)
     {
      if(m_cOutputs)
         delete m_cOutputs;
      m_cOutputs = m_cFF2.GetOutputs();
     }
//---
   if(m_cFF2.GetGradients() != m_cGradients)
     {
      if(m_cGradients)
         delete m_cGradients;
      m_cGradients = m_cFF2.GetGradients();
     }
//---
   SetOpenCL(m_cOpenCL);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNeuronAttention::NormlizeBuffer(CBufferType *buffer, CBufferType *std, uint std_shift)
  {
   if(!m_cOpenCL)
     {
      double mean = buffer.m_mMatrix.Mean();
      std.m_mMatrix[0, std_shift] = buffer.m_mMatrix.Std();
      if(std.m_mMatrix[0, std_shift] != 0)
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
      int NDRange[] = {(int)MathMin(buffer.Total(), LOCAL_SIZE)};
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
bool CNeuronAttention::NormlizeBufferGradient(CBufferType *output, CBufferType *gradient, CBufferType *std, uint std_shift)
  {
//---
   if(!m_cOpenCL)
     {
      if(std.At(std_shift) <= 0)
         return true;
      MATRIX ScG = gradient.m_mMatrix / std.m_mMatrix[0, std_shift];
      MATRIX ScOut = output.m_mMatrix * std.m_mMatrix[0, std_shift];
      TYPE dSTD = (gradient.m_mMatrix * output.m_mMatrix / (-2 * MathPow(std.m_mMatrix[0, std_shift], 2))).Sum();
      TYPE dMean = -1 * ScG.Sum() - 2 * dSTD / (TYPE)output.Total() * ScOut.Sum();
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
