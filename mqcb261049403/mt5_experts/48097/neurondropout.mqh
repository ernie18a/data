//+------------------------------------------------------------------+
//|                                                NeuronDropout.mqh |
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
//| Class CNeuronDropout                                             |
//| Purpose: Dropout method implementation class                     |
//+------------------------------------------------------------------+
class CNeuronDropout    :  public CNeuronBase
  {
protected:
   TYPE              m_dOutProbability;
   int               m_iOutNumber;
   TYPE              m_dInitValue;

   CBufferType       m_cDropOutMultiplier;

public:
                     CNeuronDropout(void);
                    ~CNeuronDropout(void);
   //---
   virtual bool      Init(const CLayerDescription *desc) override;
   virtual bool      FeedForward(CNeuronBase *prevLayer) override;
   virtual bool      CalcHiddenGradient(CNeuronBase *prevLayer) override;
   virtual bool      CalcDeltaWeights(CNeuronBase *prevLayer, bool read)
                                                                 override { return true; }
   virtual bool      UpdateWeights(int batch_size, TYPE learningRate,
                                   VECTOR &Beta, VECTOR &Lambda) override { return true; }
   //--- file handling methods
   virtual bool      Save(const int file_handle) override;
   virtual bool      Load(const int file_handle) override;
   //--- object identification method
   virtual int       Type(void) override   const { return(defNeuronDropout); }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CNeuronDropout::CNeuronDropout(void)   :  m_dInitValue(1.0),
   m_dOutProbability(0),
   m_iOutNumber(0)
  {
   m_bTrain = false;
  }
//+------------------------------------------------------------------+
//| Class destructor                                                 |
//+------------------------------------------------------------------+
CNeuronDropout::~CNeuronDropout(void)
  {
  }
//+------------------------------------------------------------------+
//| Class initialization method                                      |
//+------------------------------------------------------------------+
bool CNeuronDropout::Init(const CLayerDescription *description)
  {
//--- control block
   if(!description || description.count != description.window)
      return false;
//--- call of the method of the parent class
   CLayerDescription *temp = new CLayerDescription();
   if(!temp || !temp.Copy(description))
      return false;
   temp.window = 0;
   if(!CNeuronBase::Init(temp))
      return false;
   delete temp;
//--- calculate coefficients
   m_dOutProbability = (TYPE)MathMin(description.probability, 0.9);
   if(m_dOutProbability < 0)
      return false;
   m_iOutNumber = (int)(m_cOutputs.Total() * m_dOutProbability);
   m_dInitValue = (TYPE)(1.0 / (1.0 - m_dOutProbability));
//--- initiate the masking buffer
   if(!m_cDropOutMultiplier.BufferInit(m_cOutputs.Rows(), m_cOutputs.Cols(), m_dInitValue))
      return false;
   m_bTrain = true;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Feed-forward method                                              |
//+------------------------------------------------------------------+
bool CNeuronDropout::FeedForward(CNeuronBase *prevLayer)
  {
//--- control block
   if(!prevLayer || !prevLayer.GetOutputs() || !m_cOutputs)
      return false;
//--- generate a data masking tensor
   ulong total = m_cOutputs.Total();
   if(!m_cDropOutMultiplier.m_mMatrix.Fill(m_dInitValue))
      return false;
   for(int i = 0; i < m_iOutNumber; i++)
     {
      int pos = (int)(MathRand() * MathRand() / MathPow(32767.0, 2) * total);
      if(m_cDropOutMultiplier.m_mMatrix.Flat(pos) == 0)
        {
         i--;
         continue;
        }
      if(!m_cDropOutMultiplier.m_mMatrix.Flat(pos, 0))
         return false;
     }
//--- branching of the algorithm depending on the device used for performing operations
   if(!m_cOpenCL)
     {
      //--- check the operating mode flag
      if(!m_bTrain)
         m_cOutputs.m_mMatrix = prevLayer.GetOutputs().m_mMatrix;
      else
         m_cOutputs.m_mMatrix = prevLayer.GetOutputs().m_mMatrix * m_cDropOutMultiplier.m_mMatrix;
     }
   else  // OpenCL block
     {
      //--- check the operating mode flag
      if(!m_bTrain)
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
         if(!m_cDropOutMultiplier.BufferCreate(m_cOpenCL))
            return false;
         if(m_cOutputs.GetIndex() < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult, def_mask_inputs, inputs.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult, def_mask_mask, m_cDropOutMultiplier.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult, def_mask_outputs, m_cOutputs.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_MaskMult, def_mask_total, total))
            return false;
         //--- place to execution queue
         int off_set[] = {0};
         int NDRange[] = { (int)(total + 3) / 4};
         if(!m_cOpenCL.Execute(def_k_MaskMult, 1, off_set, NDRange))
            return false;
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for propagating gradient through hidden layer             |
//+------------------------------------------------------------------+
bool CNeuronDropout::CalcHiddenGradient(CNeuronBase *prevLayer)
  {
//--- control block
   if(!prevLayer || !prevLayer.GetGradients() ||
      !m_cGradients)
      return false;
//--- branching of the algorithm depending on the device used for performing operations
   ulong total = m_cOutputs.Total();
   if(!m_cOpenCL)
     {
      //--- check the operating mode flag
      if(!m_bTrain)
         prevLayer.GetGradients().m_mMatrix = m_cGradients.m_mMatrix;
      else
         prevLayer.GetGradients().m_mMatrix = m_cGradients.m_mMatrix * m_cDropOutMultiplier.m_mMatrix;
     }
   else  // OpenCL block
     {
      //--- check the operating mode flag
      if(!m_bTrain)
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
         CBufferType* prev = prevLayer.GetGradients();
         if(prev.GetIndex() < 0)
            return false;
         if(m_cDropOutMultiplier.GetIndex() < 0)
            return false;
         if(m_cGradients.GetIndex() < 0)
            return false;
         //--- pass parameters to the kernel
         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult, def_mask_inputs, m_cGradients.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult, def_mask_mask, m_cDropOutMultiplier.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgumentBuffer(def_k_MaskMult, def_mask_outputs, prev.GetIndex()))
            return false;
         if(!m_cOpenCL.SetArgument(def_k_MaskMult, def_mask_total, total))
            return false;
         //--- place to execution queue
         int off_set[] = {0};
         int NDRange[] = { (int)(total + 3) / 4 };
         if(!m_cOpenCL.Execute(def_k_MaskMult, 1, off_set, NDRange))
            return false;
        }
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for saving class elements to a file                       |
//+------------------------------------------------------------------+
bool CNeuronDropout::Save(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronBase::Save(file_handle))
      return false;
//--- save the element dropout probability constant
   if(FileWriteDouble(file_handle, m_dOutProbability) <= 0)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Method for restoring the class from saved data                   |
//+------------------------------------------------------------------+
bool CNeuronDropout::Load(const int file_handle)
  {
//--- call of the method of the parent class
   if(!CNeuronBase::Load(file_handle))
      return false;
//--- read and restore constants
   m_dOutProbability = (TYPE)FileReadDouble(file_handle);
   m_iOutNumber = (int)(m_cOutputs.Total() * m_dOutProbability);
   m_dInitValue = (TYPE)(1.0 / (1.0 - m_dOutProbability));
//--- initialize the data masking buffer
   if(!m_cDropOutMultiplier.BufferInit(m_cOutputs.Rows(), m_cOutputs.Cols(), m_dInitValue))
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
