//+------------------------------------------------------------------+
//|                                               TickCompressor.mqh |
//|                                    Copyright (c) 2020, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|                              https://www.mql5.com/en/code/30791/ |
//+------------------------------------------------------------------+

#define TICK_COMPRESSOR

/*

just for reference, default tick type
struct MqlTick
{ 
  datetime     time;
  double       bid;
  double       ask;
  double       last;
  ulong        volume;
  long         time_msc;
  uint         flags;
  double       volume_real;
};

*/

// 2 types of Mini-Ticks: for Forex/CFDs (MqlTickBidAsk) and Exchanges (MqlTickBidAskLastVolume)

// NB: potentially, instead of `float ask` we could use `ushort spread` and build ask from bid
struct MqlTickBidAsk
{
  float      bid;
  float      ask;
  long       time_msc;
  ushort     flags;
  
  static MqlTickBidAsk compress(const MqlTick &tick);
  static MqlTick decompress(const MqlTickBidAsk &tick);
};

struct MqlTickBidAskLastVolume
{
  float      bid;
  float      ask;
  float      last;
  ulong      volume;
  long       time_msc;
  ushort     flags;
  
  static MqlTickBidAskLastVolume compress(const MqlTick &tick);
  static MqlTick decompress(const MqlTickBidAskLastVolume &tick);
};


// compression/decompression static class wrapper
class TickCompressor
{
  public:
    // dummy compressions/decompressions
    // to keep dependent codes unchanged for native and mini ticks

    static void compress(const MqlTick &tick, MqlTick &result)
    {
      result = tick;
    }

    static void decompress(const MqlTick &tick, MqlTick &result)
    {
      result = tick;
    }

    static void compress(MqlTick &ticks[], MqlTick &result[])
    {
      ArraySwap(ticks, result);
    }

    static void decompress(MqlTick &ticks[], MqlTick &result[])
    {
      ArraySwap(ticks, result);
    }

    // Forex/CFDs
    static void compress(const MqlTick &tick, MqlTickBidAsk &result)
    {
      result.bid = (float)tick.bid;
      result.ask = (float)tick.ask;
      result.time_msc = tick.time_msc;
      result.flags = (ushort)tick.flags;
    }

    static void decompress(const MqlTickBidAsk &tick, MqlTick &result)
    {
      result.bid = tick.bid;
      result.ask = tick.ask;
      result.last = 0;
      result.time_msc = tick.time_msc;
      result.time = (datetime)(tick.time_msc / 1000);
      result.flags = tick.flags;
      result.volume = 0;
      result.volume_real = 0;
    }
    
    
    // Exchanges
    static void compress(const MqlTick &tick, MqlTickBidAskLastVolume &result)
    {
      result.bid = (float)tick.bid;
      result.ask = (float)tick.ask;
      result.last = (float)tick.last;
      result.volume = tick.volume;
      result.time_msc = tick.time_msc;
      result.flags = (ushort)tick.flags;
    }

    static void decompress(const MqlTickBidAskLastVolume &tick, MqlTick &result)
    {
      result.bid = tick.bid;
      result.ask = tick.ask;
      result.last = tick.last;
      result.volume = tick.volume;
      result.time_msc = tick.time_msc;
      result.time = (datetime)(tick.time_msc / 1000);
      result.flags = tick.flags;
      result.volume_real = (double)tick.volume;
    }

    // arrays
    template<typename D>
    static void compress(const MqlTick &ticks[], D &result[])
    {
      const int n = ArraySize(ticks);
      ArrayResize(result, n);
      for(int i = 0; i < n; i++)
      {
        compress(ticks[i], result[i]);
      }
    }

    template<typename S>
    static void decompress(const S &ticks[], MqlTick &result[])
    {
      const int n = ArraySize(ticks);
      ArrayResize(result, n);
      for(int i = 0; i < n; i++)
      {
        decompress(ticks[i], result[i]);
      }
    }

};

static MqlTickBidAsk MqlTickBidAsk::compress(const MqlTick &tick)
{
  MqlTickBidAsk result = {0};
  TickCompressor::compress(tick, result);
  return result;
}

static MqlTick MqlTickBidAsk::decompress(const MqlTickBidAsk &tick)
{
  MqlTick result = {0};
  TickCompressor::decompress(tick, result);
  return result;
}

static MqlTickBidAskLastVolume MqlTickBidAskLastVolume::compress(const MqlTick &tick)
{
  MqlTickBidAskLastVolume result;
  TickCompressor::compress(tick, result);
  return result;
}

static MqlTick MqlTickBidAskLastVolume::decompress(const MqlTickBidAskLastVolume &tick)
{
  MqlTick result;
  TickCompressor::decompress(tick, result);
  return result;
}
