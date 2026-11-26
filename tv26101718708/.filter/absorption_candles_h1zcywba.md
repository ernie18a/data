# Absorption Candles.

- url: https://www.tradingview.com/script/h1zcYwbA-Absorption-Candles/
- type: indicator
- pine_id: PUB;aa4427c3092344e3879ef35c8b70a14d
- version: 1.0

## Description

Absorption Best used around key levels. Reads real-time absorption for you.

## Source Code

````pine
//@version=6
indicator("Absorption Detector", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────
lookback     = input.int(20, "Lookback Period", minval=5)
volMult      = input.float(1.3, "Volume Spike (x avg)", step=0.05, minval=0.5)
bodyPct      = input.float(0.5, "Max Body/Range Ratio", step=0.05, minval=0.05, maxval=1.0)
wickPct      = input.float(0.15, "Min Wick/Range Ratio", step=0.05, minval=0.0)

// ─── AVERAGES ─────────────────────────────────────────────
avgVol       = ta.sma(volume, lookback)

// ─── CANDLE MEASUREMENTS ──────────────────────────────────
candleRange  = high - low + 0.0001
bodySize     = math.abs(close - open)
bodyRatio    = bodySize / candleRange

upperWick    = high - math.max(open, close)
lowerWick    = math.min(open, close) - low
totalWick    = upperWick + lowerWick
wickRatio    = totalWick / candleRange

// ─── CONDITIONS ───────────────────────────────────────────
hugeVolume   = volume >= avgVol * volMult   // volume spike
smallBody    = bodyRatio <= bodyPct         // small body relative to range
hasWicks     = wickRatio >= wickPct         // wicks present (price rejected)

absorption   = hugeVolume and smallBody and hasWicks

// ─── PAINT ────────────────────────────────────────────────
barcolor(absorption ? color.new(color.blue, 0) : na)
````
