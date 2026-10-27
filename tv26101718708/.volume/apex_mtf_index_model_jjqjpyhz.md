# Apex MTF Index Model

- url: https://www.tradingview.com/script/jjQjPyhZ-Apex-MTF-Index-Model/
- type: strategy
- pine_id: PUB;7dac6098e4634b05b7995fd13681e41b
- version: 1.0

## Description

Apex MTF Index Model is a multi-timeframe (MTF) trading strategy designed specifically for index products like the SPDR S&P 500 ETF Trust.
It combines higher timeframe bias with intraday execution to identify high-probability trend continuation setups.
This model is built around a simple idea:
alignment across timeframes + volatility + timing = edge

🔍 Core Logic
🧭 Higher Timeframe Bias


Uses Monthly, Weekly, and Daily trends


Weighted to prioritize macro direction


Outputs a bullish/bearish probability score


⚡ Intraday Execution


Trades only during the New York session (9:30–11:30)


Uses:


EMA (trend)


VWAP (institutional positioning)




📈 Volatility Filter


Requires ATR expansion


Avoids low-volatility / choppy conditions



🎯 Entry Models
1. Pullback Continuation


Trend-aligned market


Price pulls back to EMA


Continuation in direction of bias


2. Opening Range Breakout (ORB)


Break of the first X minutes range


Confirms strong directional intent


Filtered by higher timeframe bias



🧱 Key Levels


Previous Day High (PDH)


Previous Day Low (PDL)


Used for context, liquidity, and breakout behavior



💰 Risk Management


ATR-based stop loss


Dual take-profit structure:


TP1: Partial at ~1.5R


TP2: Runner at configurable RR (default 2.5R)




Designed to balance:


Consistent base hits


Occasional extended trend capture



📊 What to Expect


Moderate win rate (~35–50%)


Positive expectancy via risk/reward structure


Best performance in:


Trending markets


High volatility sessions


Clear macro bias environments





⚠️ Notes


Not designed for:


Low volatility / range-bound days


Overnight or illiquid sessions




Works best on:


Indices (SPY, futures, major ETFs)


Liquid, trend-following instruments





🚀 Philosophy
This is not a prediction tool.
It is a probability alignment framework.
The goal is simple:

Trade less, but trade when multiple forces agree.


If you want, I can also:


Add a short version (for public library visibility)


Write a more aggressive marketing-style description


Or tailor it specifically if you plan to publish or sell it

## Source Code

````pine
//@version=6
strategy("Apex MTF Index Model", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// === INPUTS ===
lenEMA     = input.int(21, "EMA Length")
atrLen     = input.int(14, "ATR Length")
rr         = input.float(2.5, "Runner RR")
sessionNY  = input.session("0930-1130", "NY Session")
orbMinutes = input.int(15, "Opening Range Minutes")

// === SESSION FILTER ===
inSession = not na(time(timeframe.period, sessionNY))

// === HIGHER TIMEFRAME BIAS ===
f_bias(tf) =>
    c   = request.security(syminfo.tickerid, tf, close)
    ema = request.security(syminfo.tickerid, tf, ta.ema(close, lenEMA))
    c > ema ? 1 : c < ema ? -1 : 0

bias = f_bias("M") * 5 + f_bias("W") * 4 + f_bias("D") * 3

maxBias  = 12
probBull = (bias + maxBias) / (2 * maxBias) * 100

bullBias = probBull > 60
bearBias = probBull < 40

// === VWAP + EMA ===
ema  = ta.ema(close, lenEMA)
vwap = ta.vwap

// === VOLATILITY FILTER ===
atr    = ta.atr(atrLen)
atrAvg = ta.sma(atr, atrLen)
volOk  = atr > atrAvg

// === PREVIOUS DAY LEVELS ===
pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])

plot(pdh, "PDH", color=color.green)
plot(pdl, "PDL", color=color.red)

// === OPENING RANGE (ORB) ===
var float orbHigh     = na
var float orbLow      = na
var int   sessionStart = na

isNewDay = ta.change(time("D")) > 0

if isNewDay
    orbHigh      := na
    orbLow       := na
    sessionStart := time

inORB = not na(sessionStart) and (time - sessionStart) <= orbMinutes * 60 * 1000

if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow, low)

plot(orbHigh, "ORB High", color=color.blue)
plot(orbLow,  "ORB Low",  color=color.orange)

// === ENTRY CONDITIONS ===
longPullback  = bullBias and inSession and volOk and close > ema and close > vwap and low  <= ema
shortPullback = bearBias and inSession and volOk and close < ema and close < vwap and high >= ema

longORB  = bullBias and inSession and volOk and not inORB and not na(orbHigh) and close > orbHigh and close > vwap
shortORB = bearBias and inSession and volOk and not inORB and not na(orbLow)  and close < orbLow  and close < vwap

// === STOPS & TARGETS ===
longSL  = low  - atr
shortSL = high + atr

longTP1  = close + (close - longSL)  * 1.5
longTP2  = close + (close - longSL)  * rr
shortTP1 = close - (shortSL - close) * 1.5
shortTP2 = close - (shortSL - close) * rr

// === EXECUTION ===
if longPullback or longORB
    strategy.entry("Long", strategy.long)
    strategy.exit("L TP1", from_entry="Long", limit=longTP1, qty_percent=50)
    strategy.exit("L TP2", from_entry="Long", limit=longTP2, stop=longSL)

if shortPullback or shortORB
    strategy.entry("Short", strategy.short)
    strategy.exit("S TP1", from_entry="Short", limit=shortTP1, qty_percent=50)
    strategy.exit("S TP2", from_entry="Short", limit=shortTP2, stop=shortSL)

// === VISUALS ===
bgcolor(bullBias ? color.new(color.green, 90) : bearBias ? color.new(color.red, 90) : na)
plot(probBull, title="Bull Probability", display=display.none)
````
