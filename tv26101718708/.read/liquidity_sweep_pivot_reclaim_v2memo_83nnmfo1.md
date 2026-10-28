# Liquidity Sweep & Pivot Reclaim v2-memo

- url: https://www.tradingview.com/script/83NNMfO1-Liquidity-Sweep-Pivot-Reclaim-v2-memo/
- type: indicator
- pine_id: PUB;0fab905a4f9647468e37924a7e1525c7
- version: 1.0

## Description

Liquidity Sweep & Pivot Reclaim v2 detects potential reversal and continuation setups based on liquidity grabs at key pivot levels.

Features:
• Detects bullish and bearish liquidity sweeps
• Identifies pivot reclaim confirmations
• Optional VWAP trend filter
• Optional 18/100 moving average alignment filter
• Relative volume confirmation
• Anti-chop filters:
   - flat VWAP detection
   - inside bar filtering
   - weak candle body filtering
• Automatic BUY and SELL labels
• Alert conditions included

Designed for ES, NQ, and other futures markets to help identify reclaim setups after stop-loss/liquidity sweeps.

## Source Code

````pine
//@version=6
indicator("Liquidity Sweep & Pivot Reclaim v2", overlay = true, max_labels_count = 500)

// ─── Inputs ───
pivotLookbackInput = input.int(5, "Pivot Lookback Left/Right", minval = 1)
maFastLengthInput  = input.int(18, "Fast MA Length", minval = 1)
maSlowLengthInput  = input.int(100, "Slow MA Length", minval = 1)

// Filters
useVwapFilter      = input.bool(true, "Use VWAP Filter", group = "Filters")
useMaFilter        = input.bool(false, "Use MA Alignment Filter", group = "Filters")
avoidFlatVwap      = input.bool(true, "Avoid Flat VWAP", group = "Filters")
avoidWeakBodies    = input.bool(true, "Avoid Weak Bodies", group = "Filters")
avoidOverlaps      = input.bool(true, "Avoid Inside Bars", group = "Filters")
useVolumeFilter    = input.bool(true, "Use Relative Volume Filter", group = "Filters")
requireRetestHold  = input.bool(true, "Require Retest Hold", group = "Filters")

// Volume Settings
volLengthInput     = input.int(20, "Volume SMA Length", minval = 1, group = "Volume")
volMultiplierInput = input.float(1.2, "Volume Multiplier", minval = 0.1, step = 0.1, group = "Volume")

// Style
bullColorInput     = input.color(#089981, "Bullish Color", group = "Style")
bearColorInput     = input.color(#f23645, "Bearish Color", group = "Style")

// ─── Calculations ───
vwapVal = ta.vwap(close)
maFast  = ta.sma(close, maFastLengthInput)
maSlow  = ta.sma(close, maSlowLengthInput)

volSma = ta.sma(volume, volLengthInput)
relVolumeOk = volume > volSma * volMultiplierInput

ph = ta.pivothigh(high, pivotLookbackInput, pivotLookbackInput)
pl = ta.pivotlow(low, pivotLookbackInput, pivotLookbackInput)

var float lastPH = na
var float lastPL = na

if not na(ph)
    lastPH := ph

if not na(pl)
    lastPL := pl

// ─── Anti-Chop Logic ───
vwapSlope  = ta.change(vwapVal)
isVwapFlat = math.abs(vwapSlope) < syminfo.mintick * 2

bodySize    = math.abs(close - open)
candleRange = high - low
isWeakBody  = candleRange > 0 ? bodySize < candleRange * 0.3 : true

isInsideBar = high <= high[1] and low >= low[1]

// ─── Sweep Logic ───
bullSweep = not na(lastPL) and low < lastPL and close > lastPL
bearSweep = not na(lastPH) and high > lastPH and close < lastPH

// Save swept levels
var float bullSweepLevel = na
var float bearSweepLevel = na

if bullSweep
    bullSweepLevel := lastPL

if bearSweep
    bearSweepLevel := lastPH

// Confirmation candle
bullConfirmRaw = bullSweep[1] and close > open
bearConfirmRaw = bearSweep[1] and close < open

// Retest hold logic
bullRetestHoldOk = not requireRetestHold or close > bullSweepLevel
bearRetestHoldOk = not requireRetestHold or close < bearSweepLevel

// ─── Filters ───
longFilter = true
shortFilter = true

if useVwapFilter
    longFilter := longFilter and close > vwapVal
    shortFilter := shortFilter and close < vwapVal

if useMaFilter
    longFilter := longFilter and maFast > maSlow
    shortFilter := shortFilter and maFast < maSlow

if avoidFlatVwap
    longFilter := longFilter and not isVwapFlat
    shortFilter := shortFilter and not isVwapFlat

if avoidWeakBodies
    longFilter := longFilter and not isWeakBody
    shortFilter := shortFilter and not isWeakBody

if avoidOverlaps
    longFilter := longFilter and not isInsideBar
    shortFilter := shortFilter and not isInsideBar

if useVolumeFilter
    longFilter := longFilter and relVolumeOk
    shortFilter := shortFilter and relVolumeOk

// ─── Final Signals ───
buySignal  = bullConfirmRaw and bullRetestHoldOk and longFilter
sellSignal = bearConfirmRaw and bearRetestHoldOk and shortFilter

// ─── Plots ───
plot(vwapVal, "VWAP", color.new(color.gray, 40), 1, plot.style_linebr)
plot(maFast, "MA Fast", color.new(bullColorInput, 40))
plot(maSlow, "MA Slow", color.new(bearColorInput, 40))

plot(lastPH, "Resistance Level", color.new(bearColorInput, 75), 1, plot.style_linebr)
plot(lastPL, "Support Level", color.new(bullColorInput, 75), 1, plot.style_linebr)

plotshape(buySignal, title = "Buy Signal", style = shape.triangleup, location = location.belowbar, color = bullColorInput, size = size.small, text = "BUY", textcolor = color.white)
plotshape(sellSignal, title = "Sell Signal", style = shape.triangledown, location = location.abovebar, color = bearColorInput, size = size.small, text = "SELL", textcolor = color.white)

// ─── Alerts ───
alertcondition(buySignal, title = "Bullish Sweep Reclaim", message = "Bullish Liquidity Sweep & Pivot Reclaim Confirmed")
alertcondition(sellSignal, title = "Bearish Sweep Reclaim", message = "Bearish Liquidity Sweep & Pivot Reclaim Confirmed")
````
