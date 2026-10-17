# GK XAUUSD Sniper Adaptive

- url: https://www.tradingview.com/script/IDbFkptC-GK-XAUUSD-Sniper-Adaptive/
- type: indicator
- pine_id: PUB;908921c75cd2455faad0e37c97eac22d
- version: 1.0

## Description

GOLDKING WARNING – READ BEFORE USE ⚠️

This indicator is built strictly for XAUUSD / Gold only.
Do NOT use this on any other asset.

The logic, volatility filters, TP system, and entry conditions
are specifically designed around XAUUSD behaviour, movement speed,
and pip structure.

Using this on other markets may produce unreliable signals.

------------------------------------------------

👑 Author Insight:
This system is built from my personal analysis and understanding
of XAUUSD price action, including trend behaviour, momentum,
structure, and volatility.

------------------------------------------------

⏱️ Recommended Timeframes:
• Best Overall: 15 Minute
• Also Works Well: 5M, 20M, 30M, 1H, 2H

For cleaner setups and more patience, the 15-minute chart
is strongly recommended.

------------------------------------------------

⚠️ This is a precision XAUUSD sniper system.
Use correctly with proper risk management.

------------------------------------------------

GK XAUUSD SNIPER ADAPTIVE

This indicator is a trend-following and momentum-based system
designed specifically for XAUUSD.

It combines:
• Trend direction (ZLEMA-based logic)
• EMA bias filtering
• Momentum confirmation
• Candle strength validation
• Market structure breaks
• Pullback + reclaim entries
• Anti-chop filtering
• One-print-per-trend logic

The goal is to identify cleaner directional setups
and avoid low-quality market conditions.

------------------------------------------------

SIGNALS:

GK BUY → Bullish setup detected
GK SELL → Bearish setup detected
TP → Target reached after defined move
PREPARE → Early signal forming (not confirmed)

Weekly HUD tracks:
• Total signals
• TP hits
• TP score %

------------------------------------------------

HOW IT WORKS:

1. Trend Detection
Uses adaptive ZLEMA lines to define trend direction.

2. Bias Filter
Uses EMA to align trades with overall direction.

3. Momentum
Confirms movement strength before printing signals.

4. Candle Strength
Filters weak candles and low-quality entries.

5. Structure
Detects breaks of recent highs/lows.

6. Pullback Logic
Identifies continuation entries after retracements.

7. Anti-Chop Filter
Avoids sideways / low volatility zones.

8. One Print Per Trend
Prevents repeated signals in same move.

9. TP System
Default TP move: 11.0 (XAUUSD-specific)

------------------------------------------------

BEST USE:

Recommended chart:
XAUUSD – 15 Minute

Lower timeframes = more signals (more noise)
Higher timeframes = cleaner trend (fewer entries)

------------------------------------------------

⚠️ DISCLAIMER:

This indicator does NOT guarantee profits.
It is a technical tool for analysis only.

Always use proper risk management.
Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("GK XAUUSD Sniper Adaptive", overlay=true, max_labels_count=500)

// INPUTS
mainLen = input.int(25, "Main Trend Speed", minval=2)
fastLen = input.int(9, "Fast Trigger Speed", minval=2)
emaBiasLen = input.int(200, "EMA Bias Length", minval=20)
atrLen = input.int(14, "ATR Length", minval=1)
structureLookback = input.int(5, "Structure Lookback", minval=2)
slopeLookback = input.int(2, "Slope Lookback", minval=1)
pullbackWindow = input.int(2, "Pullback Window", minval=1, maxval=10)
minBodyATR = input.float(0.18, "Min Body ATR", step=0.01)
minSlopeATR = input.float(0.08, "Min Slope ATR", step=0.01)
minSepATR = input.float(0.08, "Min Separation ATR", step=0.01)
maxStretchATR = input.float(1.25, "Max Stretch ATR", step=0.05)
chopThreshATR = input.float(0.16, "Anti-Chop Threshold ATR", step=0.01)
scoreToPrint = input.int(3, "Score To Print", minval=2, maxval=8)

// ✅ ONLY CHANGE
tpMove = input.float(11.0, "TP Move", step=0.1)

showPrepare = input.bool(true, "Show PREPARE")
showTP = input.bool(true, "Show TP")
showSignals = input.bool(true, "Show GK BUY / SELL")
showWeeklyHUD = input.bool(true, "Show Weekly HUD")

// ZLEMA
lagMain = int(math.floor((mainLen - 1) / 2))
mainAdj = lagMain > 0 ? close + (close - close[lagMain]) : close
mainLine = ta.ema(mainAdj, mainLen)

lagFast = int(math.floor((fastLen - 1) / 2))
fastAdj = lagFast > 0 ? close + (close - close[lagFast]) : close
fastLine = ta.ema(fastAdj, fastLen)

// CORE
atr = ta.atr(atrLen)
emaBias = ta.ema(close, emaBiasLen)

// TREND
mainSlope = mainLine - mainLine[slopeLookback]
fastSlope = fastLine - fastLine[1]
sep = math.abs(fastLine - mainLine)

bullSlopeOk = mainSlope > atr * minSlopeATR
bearSlopeOk = mainSlope < -atr * minSlopeATR

bullSepOk = fastLine > mainLine and sep > atr * minSepATR
bearSepOk = fastLine < mainLine and sep > atr * minSepATR

bullBias = close > emaBias
bearBias = close < emaBias

bullTrend = close > mainLine and fastLine > mainLine and bullSlopeOk
bearTrend = close < mainLine and fastLine < mainLine and bearSlopeOk

// CANDLE QUALITY
bodySize = math.abs(close - open)
bodyStrong = bodySize > atr * minBodyATR
rangeBar = high - low

bullCandle = close > open and close >= high - rangeBar * 0.35
bearCandle = close < open and close <= low + rangeBar * 0.35

bullExpansion = close > high[1] and bullCandle and bodyStrong
bearExpansion = close < low[1] and bearCandle and bodyStrong

// STRUCTURE
prevHigh = ta.highest(high, structureLookback)[1]
prevLow = ta.lowest(low, structureLookback)[1]

bullBreak = close > prevHigh or high > prevHigh
bearBreak = close < prevLow or low < prevLow

// PULLBACK
bullPullbackTouch = low <= fastLine or low <= mainLine or close <= fastLine
bearPullbackTouch = high >= fastLine or high >= mainLine or close >= fastLine

barsSinceBullTouch = ta.barssince(bullPullbackTouch)
barsSinceBearTouch = ta.barssince(bearPullbackTouch)

recentBullTouch = barsSinceBullTouch >= 0 and barsSinceBullTouch <= pullbackWindow
recentBearTouch = barsSinceBearTouch >= 0 and barsSinceBearTouch <= pullbackWindow

bullReclaim = ta.crossover(close, fastLine) or close > fastLine and close[1] <= fastLine[1] or ta.crossover(fastLine, mainLine)
bearReject = ta.crossunder(close, fastLine) or close < fastLine and close[1] >= fastLine[1] or ta.crossunder(fastLine, mainLine)

// ANTI-CHOP
rangeNow = ta.highest(high, 5) - ta.lowest(low, 5)
notChoppy = rangeNow > atr * chopThreshATR

bullStretch = math.abs(close - mainLine) <= atr * maxStretchATR
bearStretch = math.abs(close - mainLine) <= atr * maxStretchATR

// MOMENTUM
bullMomentum = fastSlope > 0 and close > close[1]
bearMomentum = fastSlope < 0 and close < close[1]

// SCORING
buyScore = 0
buyScore := bullTrend ? buyScore + 1 : buyScore
buyScore := bullSepOk ? buyScore + 1 : buyScore
buyScore := bullBias ? buyScore + 1 : buyScore
buyScore := bullExpansion ? buyScore + 1 : buyScore
buyScore := bullBreak ? buyScore + 1 : buyScore
buyScore := recentBullTouch and bullReclaim ? buyScore + 1 : buyScore
buyScore := notChoppy ? buyScore + 1 : buyScore
buyScore := bullStretch ? buyScore + 1 : buyScore
buyScore := bullMomentum ? buyScore + 1 : buyScore

sellScore = 0
sellScore := bearTrend ? sellScore + 1 : sellScore
sellScore := bearSepOk ? sellScore + 1 : sellScore
sellScore := bearBias ? sellScore + 1 : sellScore
sellScore := bearExpansion ? sellScore + 1 : sellScore
sellScore := bearBreak ? sellScore + 1 : sellScore
sellScore := recentBearTouch and bearReject ? sellScore + 1 : sellScore
sellScore := notChoppy ? sellScore + 1 : sellScore
sellScore := bearStretch ? sellScore + 1 : sellScore
sellScore := bearMomentum ? sellScore + 1 : sellScore

// ENTRY ENGINE
impulseBuy = bullTrend and bullSepOk and bullExpansion and bullBias and bullMomentum and notChoppy
impulseSell = bearTrend and bearSepOk and bearExpansion and bearBias and bearMomentum and notChoppy

pullbackBuy = bullTrend and recentBullTouch and bullReclaim and bullCandle and bodyStrong and bullStretch and bullMomentum and notChoppy
pullbackSell = bearTrend and recentBearTouch and bearReject and bearCandle and bodyStrong and bearStretch and bearMomentum and notChoppy

rawBuy = impulseBuy or pullbackBuy or buyScore >= scoreToPrint
rawSell = impulseSell or pullbackSell or sellScore >= scoreToPrint

// 1 PRINT PER TREND
var int trendDir = 0
var bool trendPrinted = false

bullFlip = barstate.isconfirmed and bullTrend and bullMomentum
bearFlip = barstate.isconfirmed and bearTrend and bearMomentum

trendDir := trendDir == 0 and bullTrend ? 1 : trendDir
trendDir := trendDir == 0 and bearTrend ? -1 : trendDir

newBullTrend = bullFlip and trendDir != 1
newBearTrend = bearFlip and trendDir != -1

trendDir := newBullTrend ? 1 : newBearTrend ? -1 : trendDir
trendPrinted := newBullTrend or newBearTrend ? false : trendPrinted

buyAllowed = (trendDir == 1 or bullTrend) and not trendPrinted
sellAllowed = (trendDir == -1 or bearTrend) and not trendPrinted

// PREPARE
prepareBuyRaw = rawBuy and buyAllowed and close > mainLine and bullCandle
prepareSellRaw = rawSell and sellAllowed and close < mainLine and bearCandle

prepareBuy = showPrepare and prepareBuyRaw and not barstate.isconfirmed
prepareSell = showPrepare and prepareSellRaw and not barstate.isconfirmed

// CONFIRMED
gkBuy = barstate.isconfirmed and rawBuy and buyAllowed
gkSell = barstate.isconfirmed and rawSell and sellAllowed

trendPrinted := gkBuy or gkSell ? true : trendPrinted

finalBuy = close > mainLine and bullCandle and gkBuy
finalSell = close < mainLine and bearCandle and gkSell

// TP ENGINE
var float entryPrice = na
var int entryBar = na
var int tradeDir = 0
var bool tpDone = false

entryPrice := finalBuy ? close : finalSell ? close : entryPrice
entryBar := finalBuy or finalSell ? bar_index : entryBar
tradeDir := finalBuy ? 1 : finalSell ? -1 : tradeDir
tpDone := finalBuy or finalSell ? false : tpDone

afterEntry = not na(entryBar) and bar_index > entryBar

buyTP = showTP and afterEntry and tradeDir == 1 and not tpDone and high >= entryPrice + tpMove
sellTP = showTP and afterEntry and tradeDir == -1 and not tpDone and low <= entryPrice - tpMove

tpDone := buyTP or sellTP ? true : tpDone

// HUD
newWeek = ta.change(time("W")) != 0
var int weeklySignals = 0
var int weeklyTPHits = 0

weeklySignals := newWeek ? 0 : weeklySignals
weeklyTPHits := newWeek ? 0 : weeklyTPHits

weeklySignals := finalBuy or finalSell ? weeklySignals + 1 : weeklySignals
weeklyTPHits := buyTP or sellTP ? weeklyTPHits + 1 : weeklyTPHits

tpScore = weeklySignals > 0 ? weeklyTPHits * 100.0 / weeklySignals : 0.0
scoreColor = tpScore >= 70 ? color.green : tpScore >= 50 ? color.orange : color.red

var table hud = table.new(position.top_right, 1, 4)

table.cell(hud, 0, 0, showWeeklyHUD ? "GK WEEKLY" : "", text_color=color.white, bgcolor=color.black)
table.cell(hud, 0, 1, showWeeklyHUD ? "Signals: " + str.tostring(weeklySignals) : "", text_color=color.white, bgcolor=color.black)
table.cell(hud, 0, 2, showWeeklyHUD ? "TP Hits: " + str.tostring(weeklyTPHits) : "", text_color=color.white, bgcolor=color.black)
table.cell(hud, 0, 3, showWeeklyHUD ? "Score: " + str.tostring(tpScore, "#.##") + "%" : "", text_color=color.white, bgcolor=scoreColor)

// VISUALS
trendColor = bullTrend ? color.lime : bearTrend ? color.red : color.orange
plot(mainLine, color=trendColor, linewidth=3)

plotshape(prepareBuy, style=shape.circle, location=location.belowbar, color=color.new(color.green, 20), size=size.tiny)
plotshape(prepareSell, style=shape.circle, location=location.abovebar, color=color.new(color.red, 20), size=size.tiny)

plotshape(showSignals and finalBuy, text="GK BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.normal)
plotshape(showSignals and finalSell, text="GK SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.normal)

plotshape(buyTP, text="TP", style=shape.labeldown, location=location.abovebar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(sellTP, text="TP", style=shape.labelup, location=location.belowbar, color=color.red, textcolor=color.white, size=size.tiny)

alertcondition(finalBuy, "GK BUY", "GK BUY printed")
alertcondition(finalSell, "GK SELL", "GK SELL printed")
alertcondition(buyTP or sellTP, "TP", "TP printed")
````
