# CRT Swing Ranker 2Wk+ by WildStitch

- url: https://www.tradingview.com/script/b5i9HzTd-CRT-Swing-Ranker-2Wk-by-WildStitch/
- type: indicator
- pine_id: PUB;f838f9bf3d2740edaf07ce59fe092f81
- version: 1.0

## Description

Score swing setups that show elite A+ signals using my clean output design.  This is a multi-factory swing trading indicator that scores stocks based on trend structure, relative strength, swing compression, volume consistency, and overall market regime. It is designed to identify swing setups with a typical holding pattern of 2 weeks or more. 
Use higher scores to identify the strongest setups, 70+ indicates A+ conditions, above 80 highlights elite continuation, this indicator is designed for scanning and ranking and not as a standalone buy/sell decision maker.

## Source Code

````pine
//@version=6
indicator("CRT Swing Ranker Pro (v1)", overlay=false)

// =====================
// MARKET REGIME (DAILY SPY)
// =====================
spy = request.security("SPY", "D", close)
spy_ema50 = ta.ema(spy, 50)
spy_ema200 = ta.ema(spy, 200)
marketBull = spy > spy_ema50 and spy_ema50 > spy_ema200

// =====================
// TREND (SWING STRUCTURE)
// =====================
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

trend = close > ema20 and ema20 > ema50 and ema50 > ema200
pullbackTrend = ema20 > ema50 and ema50 > ema200

// =====================
// SWING COMPRESSION (MULTI-WEEK COIL)
// =====================
swingRange = ta.highest(high, 20) - ta.lowest(low, 20)
swingCompression = swingRange < close * 0.08

// =====================
// RELATIVE STRENGTH (3-WEEK WINDOW)
// =====================
spyRS = spy / spy[20]
stockRS = close / close[20]
rsStrong = (stockRS / spyRS) > 1.03

// =====================
// VOLUME (CONSISTENT INTEREST)
// =====================
avgVol = ta.sma(volume, 20)
volumeOK = volume > avgVol

// =====================
// STRUCTURE (HIGHER LOW BIAS)
// =====================
higherLow = low > low[5]

// =====================
// LEADERSHIP (NEAR 52W HIGH)
// =====================
high252 = ta.highest(high, 252)
nearHigh = close / high252 > 0.90

// =====================
// SCORE SYSTEM (SWING WEIGHTED)
// =====================
score = 0.0
score += trend ? 30 : 0
score += pullbackTrend ? 10 : 0
score += rsStrong ? 20 : 0
score += swingCompression ? 15 : 0
score += higherLow ? 10 : 0
score += volumeOK ? 10 : 0
score += nearHigh ? 10 : 0
score += marketBull ? 5 : 0

// =====================
// FINAL SWING SETUPS
// =====================
setup = score >= 70
elite = score >= 80 and trend and rsStrong and marketBull

// =====================
// CLEAN OUTPUT
// =====================

// 1. Score line
plot(score, "CRT Swing Score", color=color.white, linewidth=2)

// 2. A+ Swing Setup
plotshape(setup, title="SWING A+ SETUP", location=location.bottom,
    style=shape.circle, size=size.tiny, color=color.yellow, text="A+")

// 3. Elite Swing Signal
plotshape(elite, title="SWING ELITE", location=location.bottom,
    style=shape.triangleup, size=size.small, color=color.lime, text="SWING BUY")
````
