//+------------------------------------------------------------------+
//|                                               NLPA_NeuralNet.mqh |
//|                                      Neural Loss-Pattern Auditor |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Neural Loss-Pattern Auditor"
#property link      "https://forge.mql5.io"

//+------------------------------------------------------------------+
//| CMlpNet A small feed-forward network with one tanh hidden layer  |
//| and one sigmoid output neuron, trained by plain backpropagation  |
//| written directly in MQL5. No ONNX file, no Python process, no    |
//| external service of any kind: Init() builds the weight arrays,   |
//| Forward() runs a prediction, and TrainStep() performs one        |
//| gradient-descent update from a single labeled example.           |
//+------------------------------------------------------------------+
class CMlpNet
  {
private:
   int      m_n_in;     // number of input features
   int      m_n_hidden; // number of hidden neurons
   double   m_w_ih[];   // input->hidden weights, flattened [hidden*in]
   double   m_b_h[];    // hidden-layer biases
   double   m_w_ho[];   // hidden->output weights
   double   m_b_o;      // output bias
   double   m_hidden[]; // scratch: hidden activations from the last Forward() call

   double            Sigmoid(const double x) const;
   double            TanhSafe(const double x) const;
   double            UniformWeight(const double scale);

public:
   void              Init(const int n_in,const int n_hidden,const int seed);
   double            Forward(const double &features[]);
   double            TrainStep(const double &features[],const double label,const double lr);
   int               HiddenCount(void) const { return m_n_hidden; }
  };

//+------------------------------------------------------------------+
//| Sigmoid, clamped before MathExp so a large logit cannot overflow |
//+------------------------------------------------------------------+
double CMlpNet::Sigmoid(const double x) const
  {
   double c=MathMax(-30.0,MathMin(30.0,x));
   return 1.0/(1.0+MathExp(-c));
  }

//+------------------------------------------------------------------+
//| tanh via MathExp, clamped the same way as Sigmoid()              |
//+------------------------------------------------------------------+
double CMlpNet::TanhSafe(const double x) const
  {
   double c=MathMax(-30.0,MathMin(30.0,x));
   double e2=MathExp(2.0*c);
   return (e2-1.0)/(e2+1.0);
  }

//+------------------------------------------------------------------+
//| One weight drawn from Uniform(-scale, +scale) using MathRand()   |
//+------------------------------------------------------------------+
double CMlpNet::UniformWeight(const double scale)
  {
   return (MathRand()/32767.0)*2.0*scale-scale;
  }

//+------------------------------------------------------------------+
//| Allocate the weight arrays and draw the initial weights. Scaling |
//| by 1/sqrt(fan_in) (a standard, simple init rule) keeps the first |
//| forward pass in a sane range regardless of n_in. Call            |
//| MathSrand(seed) yourself first if you need the run to be         |
//| reproducible; Init() does not reseed on its own, so a caller can |
//| draw other random numbers (for example synthetic demo data) from |
//| the same seeded stream before or after building the net.         |
//+------------------------------------------------------------------+
void CMlpNet::Init(const int n_in,const int n_hidden,const int seed)
  {
   m_n_in    =n_in;
   m_n_hidden=n_hidden;
   ArrayResize(m_w_ih,n_hidden*n_in);
   ArrayResize(m_b_h,n_hidden);
   ArrayResize(m_w_ho,n_hidden);
   ArrayResize(m_hidden,n_hidden);

   MathSrand(seed);
   double scale_ih=1.0/MathSqrt((double)n_in);
   double scale_ho=1.0/MathSqrt((double)n_hidden);

   for(int j=0; j<n_hidden; j++)
     {
      for(int i=0; i<n_in; i++)
         m_w_ih[j*n_in+i]=UniformWeight(scale_ih);
      m_b_h[j] =0.0;
      m_w_ho[j]=UniformWeight(scale_ho);
     }
   m_b_o=0.0;
  }

//+------------------------------------------------------------------+
//| Forward pass: features[] (length m_n_in) -> predicted P(loss).   |
//| Also refreshes m_hidden[], which TrainStep() reuses so the       |
//| backward pass never has to recompute the forward activations.    |
//+------------------------------------------------------------------+
double CMlpNet::Forward(const double &features[])
  {
   for(int j=0; j<m_n_hidden; j++)
     {
      double s=m_b_h[j];
      for(int i=0; i<m_n_in; i++)
         s+=m_w_ih[j*m_n_in+i]*features[i];
      m_hidden[j]=TanhSafe(s);
     }
   double s_o=m_b_o;
   for(int j=0; j<m_n_hidden; j++)
      s_o+=m_w_ho[j]*m_hidden[j];
   return Sigmoid(s_o);
  }

//+------------------------------------------------------------------+
//| One SGD step on binary cross-entropy loss for a single example.  |
//| Because the output layer is sigmoid and the loss is BCE, the     |
//| gradient with respect to the pre-sigmoid logit collapses to the  |
//| clean form (prediction - label); the hidden-layer gradient then  |
//| follows from the standard tanh derivative (1 - tanh^2). Returns  |
//| the example's loss so the caller can track convergence.          |
//+------------------------------------------------------------------+
double CMlpNet::TrainStep(const double &features[],const double label,const double lr)
  {
   double pred=Forward(features);
   double d_out=pred-label;

   double d_hidden[];
   ArrayResize(d_hidden,m_n_hidden);
   for(int j=0; j<m_n_hidden; j++)
      d_hidden[j]=d_out*m_w_ho[j]*(1.0-m_hidden[j]*m_hidden[j]);

//--- output-layer update
   for(int j=0; j<m_n_hidden; j++)
      m_w_ho[j]-=lr*d_out*m_hidden[j];
   m_b_o-=lr*d_out;

//--- hidden-layer update
   for(int j=0; j<m_n_hidden; j++)
     {
      for(int i=0; i<m_n_in; i++)
         m_w_ih[j*m_n_in+i]-=lr*d_hidden[j]*features[i];
      m_b_h[j]-=lr*d_hidden[j];
     }

   double eps=1e-9;
   double loss=-(label*MathLog(pred+eps)+(1.0-label)*MathLog(1.0-pred+eps));
   return loss;
  }
//+------------------------------------------------------------------+
