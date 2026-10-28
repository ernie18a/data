//+------------------------------------------------------------------+
//| FFDEngine.mqh — Fixed-Width Fractional Differencing Engine       |
//| Copyright 2025, Patrick M. Njoroge                               |
//|                                                                  |
//| Implements the FFD method from:                                  |
//|   López de Prado, M. (2018). Advances in Financial Machine       |
//|   Learning, Chapter 5, Section 5.4.2, p. 83.                     |
//|                                                                  |
//| This file is a numerical translation of the Python functions     |
//|   get_weights_ffd()  and  frac_diff_ffd()                        |
//| in the afml library. It is designed to produce output that       |
//| cross-validates against those functions within 1e-12 on the      |
//| same price series (see FFDValidation.mq5).                       |
//|                                                                  |
//| Weight recurrence (AFML eq. 5.4):                                |
//|   w[0] = 1                                                       |
//|   w[k] = -w[k-1] * (d - k + 1) / k,   k = 1, 2, ...              |
//| Iteration stops when |w[k]| < threshold.                         |
//| The vector is then reversed so the oldest price receives the     |
//| smallest-magnitude weight and the newest receives 1.0.           |
//|                                                                  |
//| Numerical contract:                                              |
//|   - Log transform: p -> ln(max(p, 1e-8)) when use_log = true.    |
//|     The 1e-8 floor matches Python's clip(lower=1e-8) exactly.    |
//|   - Output bars [0, width-1] are set to EMPTY_VALUE.             |
//|   - Output bars [width, N-1] carry FFD values.                   |
//|   - Compute() and ComputeBuffer() must agree to within 1e-12.    |
//|                                                                  |
//| File placement:                                                  |
//|   FFDEngine.mqh      -> MQL5\Include\                            |
//|   FFD.mq5            -> MQL5\Indicators\                         |
//|   FFDValidation.mq5  -> MQL5\Scripts\                            |
//+------------------------------------------------------------------+

#property copyright   "Patrick M. Njoroge"
#property link        "https://www.mql5.com/en/users/patricknjoroge743"
#property version     "1.11"


#ifndef FFDENGINE_MQH
#define FFDENGINE_MQH

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFFDEngine
  {
private:
   double            m_weights[];    // Reversed weight vector, length = m_width + 1.
   // m_weights[0] = smallest |w|, applied to oldest price.
   // m_weights[m_width] = 1.0, applied to newest price.
   int               m_width;        // Number of lags = len(weights_before_reversal) - 1.
   double            m_d;            // Differentiation order.
   double            m_threshold;    // Weight cutoff: iteration stops when |w_k| < threshold.
   bool              m_use_log;      // Apply ln(p) transform before differencing.
   bool              m_initialized;  // Set to true after a successful Init() call.

   //--- Build m_weights using the FFD recurrence. No fixed cap.
   void              BuildWeights();

   //--- Log with 1e-8 floor, matching Python's clip(lower=1e-8).
   double            SafeLog(double price) const
     {
      if(price < 1e-8)
         price = 1e-8;
      return MathLog(price);
     }

public:
                     CFFDEngine() : m_d(0.0), m_threshold(1e-5),
                     m_use_log(true), m_width(0), m_initialized(false) {}

   //--- Initialize the engine and precompute the weight vector.
   //    Call once before Compute() or ComputeBuffer().
   //
   //    @param d          Fractional-differencing order. Typical range: (0, 1).
   //    @param threshold  Weight cutoff tau. Smaller values widen the window
   //                      and preserve more memory. Typical: 1e-4 to 1e-5.
   //    @param use_log    If true, apply ln(p) before differencing. Recommended
   //                      for raw price series; set false for already-stationary
   //                      inputs (e.g., log-returns).
   //    @return           true on success, false if the weight vector is empty.
   bool              Init(double d, double threshold = 1e-5, bool use_log = true);

   //--- Accessors
   int               GetWidth()   const { return m_width; }
   int               GetMinBars() const { return m_width + 1; }
   double            GetD()       const { return m_d; }
   bool              IsReady()    const { return m_initialized; }

   //--- Compute a single FFD value for the most recent bar in prices[].
   //
   //    prices[] must be chronological: prices[0] = oldest, prices[count-1] = newest.
   //    count must be >= GetMinBars(). The function uses the final (m_width + 1)
   //    elements regardless of how many extra elements prices[] contains.
   //
   //    @return  FFD value, or EMPTY_VALUE on error.
   double            Compute(const double &prices[], int count);

   //--- Fill an indicator buffer with FFD values.
   //    prices[] and buffer[] must be chronological (AsSeries = false).
   //    buffer[0..m_width-1]    = EMPTY_VALUE  (lookback not satisfied).
   //    buffer[m_width..total-1] = FFD values.
   //
   //    Uses prev_calculated to skip already-computed bars.
   //    Pass prev_calculated = 0 to compute the full buffer from scratch.
   //
   //    @return  total (mirrors the OnCalculate return convention).
   int               ComputeBuffer(const double &prices[], double &buffer[],
                                   int total, int prev_calculated);
  };


//+------------------------------------------------------------------+
//| BuildWeights                                                     |
//|                                                                  |
//| Translates Python's get_weights_ffd(d, thres, lim) with no cap.  |
//|                                                                  |
//| The original code had max_weights = 1000. For d = 0.4, thres =   |
//| 1e-5, the correct window width is 1457, so a cap of 1000         |
//| silently truncates the weight vector and corrupts all FFD values.|
//| This version grows the buffer dynamically — no fixed cap.        |
//+------------------------------------------------------------------+
void CFFDEngine::BuildWeights()
  {
// Start with capacity 512; double when full.
   int capacity = 512;
   double temp[];
   ArrayResize(temp, capacity);

   temp[0] = 1.0;
   int n = 1;

   for(int k = 1; ; k++)
     {
      double w_next = -temp[n - 1] * (m_d - (double)k + 1.0) / (double)k;

      if(MathAbs(w_next) < m_threshold)
         break;   // mirrors: "if abs(weights_) < thres: break"

      if(n >= capacity)
        {
         capacity *= 2;
         ArrayResize(temp, capacity);
        }

      temp[n] = w_next;
      n++;
     }

   ArrayResize(temp, n);

// Reverse into m_weights.
// m_weights[0]       = temp[n-1]  → smallest |w|, multiplies oldest price.
// m_weights[n-1]     = temp[0]    = 1.0, multiplies newest price.
   m_width = n - 1;
   ArrayResize(m_weights, n);
   for(int i = 0; i < n; i++)
      m_weights[i] = temp[n - 1 - i];
  }


//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
bool CFFDEngine::Init(double d, double threshold = 1e-5, bool use_log = true)
  {
   if(d < 0.0 || d > 2.0)
     {
      PrintFormat("CFFDEngine::Init — d must be in [0, 2], got %.4f", d);
      return false;
     }
   if(threshold <= 0.0)
     {
      Print("CFFDEngine::Init — threshold must be positive");
      return false;
     }

   m_d         = d;
   m_threshold = threshold;
   m_use_log   = use_log;

   BuildWeights();

   m_initialized = (m_width > 0);

   if(m_initialized)
      PrintFormat("CFFDEngine: d=%.4f  threshold=%.2e  width=%d  min_bars=%d  use_log=%s",
                  m_d, m_threshold, m_width, GetMinBars(),
                  m_use_log ? "true" : "false");
   else
      Print("CFFDEngine::Init — no weights generated (d or threshold may be extreme)");

   return m_initialized;
  }


//+------------------------------------------------------------------+
//| Compute — single FFD value for the last bar in prices[]          |
//+------------------------------------------------------------------+
double CFFDEngine::Compute(const double &prices[], int count)
  {
   if(!m_initialized || count < m_width + 1)
      return EMPTY_VALUE;

// Window anchored at the newest element (prices[count-1]).
   int window_start = count - m_width - 1;

   double result = 0.0;
   for(int i = 0; i <= m_width; i++)
     {
      double val = prices[window_start + i];
      if(m_use_log)
         val = SafeLog(val);
      result += m_weights[i] * val;
     }

   return result;
  }


//+------------------------------------------------------------------+
//| ComputeBuffer — fill an entire chronological indicator buffer    |
//+------------------------------------------------------------------+
int CFFDEngine::ComputeBuffer(const double &prices[], double &buffer[],
                              int total, int prev_calculated)
  {
   if(!m_initialized)
      return 0;

   int start;
   if(prev_calculated > m_width)
      start = prev_calculated - 1;   // incremental: only recompute current bar
   else
     {
      // Full computation: mark the lookback bars as empty.
      for(int i = 0; i < m_width && i < total; i++)
         buffer[i] = EMPTY_VALUE;
      start = m_width;
     }

   for(int i = start; i < total; i++)
     {
      double result = 0.0;
      for(int k = 0; k <= m_width; k++)
        {
         // Index breakdown for bar i:
         //   k = 0       → prices[i - m_width]  = oldest in window
         //   k = m_width → prices[i]             = newest (current bar)
         double val = prices[i - m_width + k];
         if(m_use_log)
            val = SafeLog(val);
         result += m_weights[k] * val;
        }
      buffer[i] = result;
     }

   return total;
  }
//+------------------------------------------------------------------+

#endif // FFDENGINE_MQH
//+------------------------------------------------------------------+
