//+------------------------------------------------------------------+
//|                                               TickCompressor.mqh |
//|                                    Copyright (c) 2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|                              https://www.mql5.com/en/code/30791/ |
//+------------------------------------------------------------------+

#define RATES_COMPRESSOR

/*

just for reference, default rates type
struct MqlRates 
  { 
   datetime time;         // Period start time 
   double   open;         // Open price 
   double   high;         // The highest price of the period 
   double   low;          // The lowest price of the period 
   double   close;        // Close price 
   long     tick_volume;  // Tick volume 
   int      spread;       // Spread 
   long     real_volume;  // Trade volume 
  };
*/


// NB: potentially, instead of `float ask` we could use `ushort spread` and build ask from bid
struct MqlRatesOHLC
{
  float      open;
  float      high;
  float      low;
  float      close;
  datetime   time;
  
  static MqlRatesOHLC compress(const MqlRates &rates);
  static MqlRates decompress(const MqlRatesOHLC &rates);
};

// compression/decompression static class wrapper
class RatesCompressor
{
  public:
    // dummy compressions/decompressions
    // to keep dependent codes unchanged for native and mini ticks

    static void compress(const MqlRates &rates, MqlRates &result)
    {
      result = rates;
    }

    static void decompress(const MqlRates &rates, MqlRates &result)
    {
      result = rates;
    }

    static void compress(MqlRates &rates[], MqlRates &result[])
    {
      ArraySwap(rates, result);
    }

    static void decompress(MqlRates &rates[], MqlRates &result[])
    {
      ArraySwap(rates, result);
    }

    // Forex/CFDs
    static void compress(const MqlRates &rates, MqlRatesOHLC &result)
    {
      result.open = (float)rates.open;
      result.high = (float)rates.high;
      result.low = (float)rates.low;
      result.close = (float)rates.close;
      result.time = rates.time;
    }

    static void decompress(const MqlRatesOHLC &rates, MqlRates &result)
    {
    
      result.open = rates.open;
      result.high = rates.high;
      result.low = rates.low;
      result.close = rates.close;
      result.time = rates.time;
      result.tick_volume = 0;
      result.real_volume = 0;
    }
    
    
    // arrays
    template<typename D>
    static void compress(const MqlRates &rates[], D &result[])
    {
      const int n = ArraySize(rates);
      ArrayResize(result, n);
      for(int i = 0; i < n; i++)
      {
        compress(rates[i], result[i]);
      }
    }

    template<typename S>
    static void decompress(const S &rates[], MqlRates &result[])
    {
      const int n = ArraySize(rates);
      ArrayResize(result, n);
      for(int i = 0; i < n; i++)
      {
        decompress(rates[i], result[i]);
      }
    }

};

static MqlRatesOHLC MqlRatesOHLC::compress(const MqlRates &rates)
{
  MqlRatesOHLC result = {0};
  RatesCompressor::compress(rates, result);
  return result;
}

static MqlRates MqlRatesOHLC::decompress(const MqlRatesOHLC &rates)
{
  MqlRates result = {0};
  RatesCompressor::decompress(rates, result);
  return result;
}
