//+------------------------------------------------------------------+
//|                                             LayerDescription.mqh |
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
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Class CLayerDescription                                          |
//| Purpose: Class for describing the neural layer to create         |
//+------------------------------------------------------------------+
class CLayerDescription : public CObject
  {
public:
                     CLayerDescription(void);
                    ~CLayerDescription(void) {};
   //---
   int               type;         // type of neural layer
   int               count;        // number of neurons in the layer
   int               window;       // size of the source data window
   int               window_out;   // size of results window
   int               step;         // step of the source data window
   int               layers;       // number of neural layers
   int               batch;        // size of the weight matrix update batch
   ENUM_ACTIVATION_FUNCTION   activation;   // activation function type
   VECTOR            activation_params;
   // array of activation function parameters
   ENUM_OPTIMIZATION optimization; // weight matrix optimization type
   TYPE              probability;  // masking probability, only Dropout
   bool              Copy(const CLayerDescription *source);
   virtual int       Type(void) override           const { return(defLayerDescription); }
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CLayerDescription::CLayerDescription(void)   :  type(defNeuronBase),
                                                count(100),
                                                window(0),
                                                step(0),
                                                layers(1),
                                                activation(AF_TANH),
                                                optimization(Adam),
                                                probability(0.0),
                                                batch(100)
  {
   activation_params = VECTOR::Ones(2);
   activation_params[1] = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLayerDescription::Copy(const CLayerDescription *source)
  {
   if(!source || source.Type() != Type())
      return false;
//---
   type = source.type;                          // type of neural layer
   count = source.count;                        // number of neurons in the layer
   window = source.window;                      // size of the source data window
   window_out = source.window_out;              // size of the results window
   step = source.step;                          // step of the source data window
   layers = source.layers;                      // number of neural layers
   batch = source.batch;                        // size of the weight matrix update batch
   activation = source.activation;              // activation function type
   activation_params = source.activation_params;// array of activation function parameters
   optimization = source.optimization;          // weight matrix optimization type
   probability = source.probability;            // dropout probability in Dropout
//---
   return true;
  }
//+------------------------------------------------------------------+
