//+------------------------------------------------------------------+
//|                                                 lossfunction.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
//+------------------------------------------------------------------+
//| Connect libraries                                                |
//+------------------------------------------------------------------+
#include "defines.mqh"
#include "buffer.mqh"
//+------------------------------------------------------------------+
//| Class CLossFunction                                              |
//| Purpose: Base class for working with loss functions              |
//+------------------------------------------------------------------+
class CLossFunction : public CObject
  {
protected:
   //--- protected constructor will not allow creating a CLossFunction object; only inheritance from this class is allowed
                     CLossFunction(void) { }
                     CLossFunction(const CLossFunction &loss) = delete; // copying is prohibited
public:
   virtual ENUM_LOSS_FUNCTION LossFunction(void) const = 0;
   //+------------------------------------------------------------------+
   //| Helper function for checking parameters in Calculate             |
   //+------------------------------------------------------------------+
   bool              CheckParameters(const CBufferType *calculated, const CBufferType *target) const
     {
      return(calculated && target && calculated.Rows() == target.Rows() && calculated.Cols() == target.Cols());
     }
   //+------------------------------------------------------------------+
   //| Calculate error                                                  |
   //+------------------------------------------------------------------+
   virtual TYPE    Calculate(const CBufferType *calculated, const CBufferType *target)
     {
      //--- check parameters
      if(!CheckParameters(calculated, target))
         return FLT_MAX;
      return calculated.m_mMatrix.Loss(target.m_mMatrix,LossFunction());
     }
  };
//+------------------------------------------------------------------+
//| Mean squared error (MSE)                                         |
//+------------------------------------------------------------------+
class CLoss_MSE final : public CLossFunction
  {
public:
   //+------------------------------------------------------------------+
   //| Get the type of the function                                     |
   //+------------------------------------------------------------------+
   virtual ENUM_LOSS_FUNCTION LossFunction(void) const override
     {
      return LOSS_MSE;
     }
  };
//+------------------------------------------------------------------+
//| Mean average error (MAE)                                         |
//+------------------------------------------------------------------+
class CLoss_MAE final : public CLossFunction
  {
public:
   //+------------------------------------------------------------------+
   //| Get the type of the function                                     |
   //+------------------------------------------------------------------+
   virtual ENUM_LOSS_FUNCTION LossFunction(void) const override
     {
      return LOSS_MAE;
     }
  };
//+------------------------------------------------------------------+
//| Binary Crossentropy error (BCE)                                  |
//+------------------------------------------------------------------+
class CLoss_BCE final : public CLossFunction
  {
public:
   //+------------------------------------------------------------------+
   //| Get the type of the function                                     |
   //+------------------------------------------------------------------+
   virtual ENUM_LOSS_FUNCTION LossFunction(void) const override
     {
      return LOSS_BCE;
     }
  };
//+------------------------------------------------------------------+
