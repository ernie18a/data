<!-- tradingview-pine-id: PUB;6bce2480051445918f7010c4108aacc3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Naive Synthetic GEX & Midday Breakout

Source: https://www.tradingview.com/script/UwCS7X01-Naive-Synthetic-GEX-Midday-Breakout/

## Description

### Overview
The Naive Synthetic GEX & Midday Breakout Overlay is a multi-purpose intraday tool designed to combine options-market volatility regime tracking with systematic price-action breakouts.

It generates synthetic Gamma Exposure (GEX) levels to help traders identify whether the market is sitting in a Mean-Reverting (Positive Gamma) or Trend-Accelerating (Negative Gamma) regime, while simultaneously highlighting tight midday consolidation ranges.

---

### How It Works

1. **Synthetic GEX & Volatility Bands:**
   - **Zero Gamma Line (Orange):** Built using an anchored Session VWAP (falling back to a 20 SMA if session data is unavailable). 
   - **Call Wall & Put Wall (Red & Green Lines):** Dynamically projected using a user-definable Average True Range (ATR) multiplier (Default: 1.5x ATR).
   - **Dynamic Regime Background:** 
     - **Green Background:** Spot price is ABOVE the estimated Zero Gamma line (Positive Gamma / Low Volatility Regime).
     - **Red Background:** Spot price is BELOW the estimated Zero Gamma line (Negative Gamma / High Volatility / Breakout Expansion Regime).

2. **Midday Consolidation & Breakout Signals:**
   - **Time Filter:** Active exclusively during midday hours (11:30 AM – 2:00 PM EST).
   - **Yellow Compression Zone:** Highlights periods where candle ranges shrink below 0.8x ATR while holding above VWAP, signaling institutional compression.
   - **MIDDAY GO Signal (Green Triangle):** Triggers when price breaks out above the 12-bar highest high on expanding volume relative to its 20-period moving average.

---

### How to Trade with This Script

- **Filter Breakouts by Regime:** High-conviction intraday breakouts (or inverse setups like SQQQ) perform best when price is trading in a **Negative Gamma (Red Shading)** environment below the Zero Gamma Line, as dealer hedging accelerates directional momentum.
- **Midday Execution:** Look for tight yellow compression shading during the midday lull (11:30 AM - 2:00 PM EST). Enter on the green "MIDDAY GO" triangle when volume expands out of consolidation.
- **Profit Taking:** Use the dynamic Call and Put Walls as primary targets or rejection zones where price momentum is likely to stall.

---

## Source Code

````pine
//@version=6
indicator("Naive Synthetic GEX & Midday Breakout", overlay=true)

// --- GEX Inputs ---
gexGroup   = "GEX Band Settings"
atrLen     = input.int(14, title="ATR Volatility Period", minval=1, group=gexGroup)
gammaMult  = input.float(1.5, title="Gamma Level Range Multiplier", step=0.1, group=gexGroup)

// --- GEX Math ---
atrVal = ta.atr(atrLen)
var float basePivot = na
rawVwap = ta.vwap(hlc3)
basePivot := na(rawVwap) ? ta.sma(close, 20) : rawVwap

zeroGammaEst = basePivot
callWallEst  = basePivot + (atrVal * gammaMult)
putWallEst   = basePivot - (atrVal * gammaMult)

// --- GEX Plots ---
plot(zeroGammaEst, title="Est. Zero Gamma (Flip)", color=color.new(color.orange, 0), linewidth=2)
plot(callWallEst,  title="Est. Call Wall",        color=color.new(color.red, 0),    linewidth=2)
plot(putWallEst,   title="Est. Put Wall",         color=color.new(color.green, 0),  linewidth=2)

// Dynamic Regime Shading
isPosGamma = close >= zeroGammaEst
bgcolor(isPosGamma ? color.new(color.green, 95) : color.new(color.red, 95), title="Regime Background")

// --- Midday Consolidation & Breakout Logic ---
inMidday = not na(time(timeframe.period, "1130-1400:23456"))
ema20    = ta.ema(close, 20)
isTight  = (high - low) < (atrVal * 0.8)
aboveVWAP = close > basePivot

isConsolidating = inMidday and isTight and aboveVWAP
recentHigh = ta.highest(high[1], 12)
breakoutTrigger = inMidday and ta.crossover(close, recentHigh) and volume > ta.sma(volume, 20)

// Midday Highlights & Signals
bgcolor(isConsolidating ? color.new(color.yellow, 85) : na, title="Midday Compression Zone")
plotshape(breakoutTrigger, title="Midday Breakout", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="MIDDAY GO")
````
