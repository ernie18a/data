//+------------------------------------------------------------------+
//|                                             FourierTransform.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23491 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23491"
#property version   "1.00"
#property strict

#include <Math\Alglib\alglib.mqh>

//+------------------------------------------------------------------+
//| CDFT - the real-input Fourier front end for SFA.                 |
//|                                                                  |
//|  SFA does not need a full spectrum. For a window of length w it  |
//|  keeps only the first 'l' complex Fourier coefficients, whose    |
//|  real and imaginary parts become the l real numbers that are     |
//|  later binned into letters. Low index = low frequency, so        |
//|  keeping the first few coefficients is a low-pass filter: it     |
//|  retains the coarse shape of the window and discards the         |
//|  high-frequency jitter. That built-in denoising is the whole     |
//|  reason SFA tolerates noisy price data.                          |
//|                                                                  |
//|  The transform itself is delegated to ALGLIB's FFTR1D, a real    |
//|  FFT that accepts any window length (no power-of-two rule). We   |
//|  simply read back the coefficients we want. The class exists to  |
//|  give SFA one clean call and to fix the coefficient-ordering     |
//|  convention in a single place.                                   |
//+------------------------------------------------------------------+

//--- how many real values a request for 'coeff_count' coefficients
//--- yields once real and imaginary parts are laid out side by side.
#define DFT_REALS_PER_COEFF 2

//+------------------------------------------------------------------+
//| Interleaving convention for the flat output array.               |
//|                                                                  |
//|  ALGLIB returns coefficients as a complex[] array f[0..w/2].     |
//|  SFA wants a flat double[] of the low coefficients' real and     |
//|  imaginary parts. We lay them out as                             |
//|      out = { Re(f1), Im(f1), Re(f2), Im(f2), ... }               |
//|  starting at f[1], because f[0] (the DC term) is the window      |
//|  mean and is identically zero after z-normalization — carrying   |
//|  it would waste a letter on a constant. 'coeff_count' therefore  |
//|  counts non-DC coefficients, and the flat array has              |
//|  coeff_count * 2 entries.                                        |
//+------------------------------------------------------------------+
class CDFT
  {
public:
   //--- transform raw[0..len-1] and write the first 'coeff_count'
   //--- non-DC coefficients, interleaved (re,im,re,im,...), into
   //--- out[]. out[] is resized to coeff_count*2. Returns false if
   //--- the window is too short to supply that many coefficients.
   static bool       LowCoefficients(const double &raw[],int len,
                                     int coeff_count,double &out[]);

   //--- largest number of non-DC coefficients a length-'len' window
   //--- can supply. ALGLIB yields floor(len/2)+1 coefficients
   //--- including DC, so the usable non-DC count is floor(len/2).
   static int        MaxCoefficients(int len) { return (len>1)?(len/2):0; }
  };

//+------------------------------------------------------------------+
//| Compute the low-frequency coefficients of a real window.         |
//|                                                                  |
//|  'raw' is expected to be already z-normalized by the caller so   |
//|  that the DC term is ~0 and every window is compared on shape,   |
//|  not on price level. We still start reading at f[1] regardless,  |
//|  so a non-normalized window simply loses its mean here.          |
//+------------------------------------------------------------------+
bool CDFT::LowCoefficients(const double &raw[],int len,
                           int coeff_count,double &out[])
  {
   if(len<2 || coeff_count<1)
      return false;
   if(coeff_count>MaxCoefficients(len))
      return false;

//--- ALGLIB needs a plain double[] of exactly 'len' samples.
   double sample[];
   ArrayResize(sample,len);
   for(int i=0;i<len;i++)
      sample[i]=raw[i];

   complex spectrum[];
   CAlglib::FFTR1D(sample,len,spectrum);
   if(ArraySize(spectrum)<coeff_count+1)   // need f[1..coeff_count]
      return false;

//--- flatten f[1..coeff_count] into interleaved real/imag pairs.
   ArrayResize(out,coeff_count*DFT_REALS_PER_COEFF);
   for(int k=0;k<coeff_count;k++)
     {
      complex c=spectrum[k+1];             // skip f[0] (DC)
      out[DFT_REALS_PER_COEFF*k]  =c.real;
      out[DFT_REALS_PER_COEFF*k+1]=c.imag;
     }
   return true;
  }
//+------------------------------------------------------------------+
