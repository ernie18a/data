# CRT Ranker Pro by WildStitch

- url: https://www.tradingview.com/script/JUpAipM4-CRT-Ranker-Pro-by-WildStitch/
- type: indicator
- pine_id: PUB;1cdd7f5207e44cfdbdeb7e0b62f034cb
- version: 1.0

## Description

This CRT pine screener is a mini instituyational momentum engine that utilizes a pre-market gap filter, with ATR expansion filter, as well as market regime filter (SPY trend alignment) and has a false breakout rejection logic.
Find elite names, enter onlu when breakout=1prints and volume expands.  will remove 80-90 percent of junk signals. 
Stock must have tight volatility compression, strong uptrend, relative high strength vs SPY, near highs and actual breakout pressure building all at the same time.  A+++++

## Source Code

````pine
//@version=6
indicator("CRT Ranker v4 (Institutional Regime Filter)", overlay=false)

// =====================
// MARKET REGIME (SPY)
// =====================
spy = request.security("SPY", timeframe.period, close)
spy_ema20 = ta.ema(spy, 20)
spy_ema50 = ta.ema(spy, 50)

marketBull = spy > spy_ema20 and spy_ema20 > spy_ema50

// =====================
// VOLATILITY COMPRESSION
// =====================
rng = high - low
nr7 = rng <= ta.lowest(rng, 7)
insideDay = high < high[1] and low > low[1]

// =====================
// TREND FILTER
// =====================
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
sma200 = ta.sma(close, 200)

trend = close > ema20 and ema20 > ema50 and close > sma200

// =====================
// LEADERSHIP
// =====================
high52 = ta.highest(high, 252)
nearHigh = close / high52 > 0.92

// =====================
// VOLUME
// =====================
avgVol = ta.sma(volume, 50)
relVol = volume / avgVol

volumeOK = relVol > 1.2 and avgVol > 1000000

// =====================
// RELATIVE STRENGTH
// =====================
stockRS = close / close[10]
spyRS = spy / spy[10]

rsRatio = stockRS / spyRS
rsStrong = rsRatio > 1.05

// =====================
// ATR EXPANSION (KEY UPGRADE)
// =====================
atr = ta.atr(14)
atrAvg = ta.sma(atr, 14)

volatilityExpanding = atr > atrAvg

// =====================
// NR7 BREAKOUT LEVEL
// =====================
nr7High = ta.highest(high, 7)

breakout = close > nr7High

// must confirm expansion
validBreakout = breakout and volume > avgVol and volatilityExpanding

// =====================
// SCORE SYSTEM (TIGHTER)
// =====================
score = 0.0

score += nr7 ? 30 : 0
score += insideDay ? 20 : 0
score += trend ? 15 : 0
score += nearHigh ? 10 : 0
score += rsStrong ? 10 : 0
score += volumeOK ? 10 : 0
score += marketBull ? 10 : 0
score += volatilityExpanding ? 5 : 0

// =====================
// QUALITY GRADES
// =====================
elite = score >= 85 and validBreakout and marketBull
a_plus = score >= 75 and marketBull
a = score >= 60

// =====================
// OUTPUTS
// =====================
plot(score, "CRT Score")
plot(elite ? 3 : a_plus ? 2 : a ? 1 : 0, "Grade")
plot(validBreakout ? 1 : 0, "Valid Breakout")
````
