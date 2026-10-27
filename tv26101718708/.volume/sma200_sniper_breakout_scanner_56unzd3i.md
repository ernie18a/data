# SMA200 Sniper Breakout Scanner

- url: https://www.tradingview.com/script/56uNzd3i-SMA200-Sniper-Breakout-Scanner/
- type: indicator
- pine_id: PUB;6836679bd29640368130e8d082baf2ae
- version: 1.0

## Description

my new baby a script created using chatgpt








bhb

## Source Code

````pine
//@version=5
indicator("SMA200 Sniper Breakout Scanner", overlay=true)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
sma200Len = input.int(200, "SMA 200")
sma50Len  = input.int(50, "SMA 50")
rsiLen    = input.int(14, "RSI")

bbLen     = input.int(20, "Bollinger Length")
bbMult    = input.float(2.0, "BB Multiplier")

volLen    = input.int(20, "Volume Avg Length")
compressionLookback = input.int(10, "Compression Lookback")

// ─────────────────────────────
// INDICATORS
// ─────────────────────────────
sma200 = ta.sma(close, sma200Len)
sma50  = ta.sma(close, sma50Len)
rsi    = ta.rsi(close, rsiLen)

// Bollinger Bands (compression tool)
bbBasis = ta.sma(close, bbLen)
bbDev   = bbMult * ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

bbWidth = (bbUpper - bbLower) / bbBasis * 100
bbSqueeze = bbWidth < ta.lowest(bbWidth, compressionLookback)

// Volume
avgVol = ta.sma(volume, volLen)
relVol = volume / avgVol
volumeBuilding = relVol > 1.0

// Price compression near SMA200
distToSMA200 = math.abs((close - sma200) / sma200) * 100
nearSMA200 = distToSMA200 <= 5

// Trend (must still be bullish context)
trendOk = close > sma200 and sma50 > sma200

// Momentum early shift (NOT full breakout yet)
rsiShift = rsi > 45 and ta.rising(rsi, 3)

// Tight structure (coiling candles)
atr = ta.atr(14)
tightRange = (ta.highest(high, 5) - ta.lowest(low, 5)) < atr * 2

// ─────────────────────────────
// SNIPER SETUP LOGIC
// ─────────────────────────────
sniperSetup =
     trendOk and
     nearSMA200 and
     bbSqueeze and
     volumeBuilding and
     rsiShift and
     tightRange

// ─────────────────────────────
// PLOTS
// ─────────────────────────────
plot(sma200, color=color.orange, linewidth=2, title="SMA 200")
plot(sma50, color=color.blue, linewidth=2, title="SMA 50")
plot(bbUpper, color=color.gray)
plot(bbLower, color=color.gray)

plotshape(sniperSetup,
     title="Sniper Setup",
     location=location.belowbar,
     style=shape.triangleup,
     size=size.small,
     color=color.lime,
     text="SNIPER")

bgcolor(sniperSetup ? color.new(color.green, 85) : na)

// ─────────────────────────────
// ALERT
// ─────────────────────────────
alertcondition(sniperSetup,
     title="Sniper Breakout Setup",
     message="SMA200 SNIPER setup forming on {{ticker}}")
````
