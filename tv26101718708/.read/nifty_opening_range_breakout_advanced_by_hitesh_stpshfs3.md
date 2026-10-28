# Nifty Opening Range Breakout Advanced by hitesh

- url: https://www.tradingview.com/script/sTpshfs3-Nifty-Opening-Range-Breakout-Advanced-by-hitesh/
- type: indicator
- pine_id: PUB;f4cd36994e8a4e13a3eb383f0a3ecea6
- version: 1.0

## Description

Strategy Overview: Nifty 50 ORB
This strategy focuses on the first 15 minutes (or your preferred timeframe) of the Indian market session (09:15 AM – 09:30 AM). It is designed to capture the volatility created by institutional order flow and overnight news reactions.

1. The Setup: Defining the "Battle Zone"
Timeframe: 15-Minute Chart (Standard) or 5-Minute (Aggressive).

Establishment: Mark the High and Low of the first 15-minute candle. This range represents the initial balance between buyers and sellers.

Personal Condition (The Gap Rule): Ideally, look for days where Nifty has "Gapped Up" or "Gapped Down." Gaps often provide the necessary fuel for a sustained breakout.

2. Execution: Buy & Sell Signals
Buy Signal (Bullish Breakout)
Primary Trigger: A candle must close decisively above the Opening Range High (ORH).

Volume Filter: The breakout candle should have a volume spike (at least 1.5x to 2x the average of the previous few candles).

Personal Experience Tip: Wait for a "Retest." If the price breaks out and then successfully bounces off the ORH (now acting as support), the probability of success increases significantly.

Sell Signal (Bearish Breakout)
Primary Trigger: A candle must close decisively below the Opening Range Low (ORL).

Volume Filter: Look for increasing selling pressure on the breakout bar.

Personal Experience Tip: If Nifty is trading below the VWAP (Volume Weighted Average Price) at the time of the breakdown, it adds a massive layer of confirmation for the short side.

3. Risk Management & Personal Filters
A strategy is only as good as its exit plan. Based on experience, these conditions help avoid "Bull/Bear Traps":

## Source Code

````pine
//@version=5
indicator("Nifty Opening Range Breakout Advanced", overlay=true)

// === INPUTS ===
rangeStart = timestamp("Asia/Kolkata", year, month, dayofmonth, 9, 15)
rangeEnd   = timestamp("Asia/Kolkata", year, month, dayofmonth, 9, 30)

bufferPoints = 7
targetPoints = 50

// === VARIABLES ===
var float rangeHigh = na
var float rangeLow = na
var bool rangeSet = false

var bool buyTaken = false
var bool sellTaken = false

var bool weakHighExtended = false
var bool weakLowExtended = false

// === RESET DAILY ===
newDay = ta.change(time("D"))
if newDay
    rangeHigh := na
    rangeLow := na
    rangeSet := false
    buyTaken := false
    sellTaken := false
    weakHighExtended := false
    weakLowExtended := false

// === CAPTURE 9:15–9:30 RANGE ===
inRange = (time >= rangeStart and time <= rangeEnd)

if inRange
    rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
    rangeLow := na(rangeLow) ? low : math.min(rangeLow, low)

// lock range after 9:30
if time > rangeEnd and not rangeSet
    rangeSet := true

// === PREVIOUS DAY LEVELS ===
prevHigh = request.security(syminfo.tickerid, "D", high[1])
prevLow  = request.security(syminfo.tickerid, "D", low[1])

// adjust range with prev levels
if rangeSet
    if math.abs(prevHigh - rangeHigh) <= 20
        rangeHigh := math.max(rangeHigh, prevHigh)

    if math.abs(rangeLow - prevLow) <= 20
        rangeLow := math.min(rangeLow, prevLow)

// === WEAK CANDLE EXTENSION ===
if rangeSet
    // weak breakout above
    if not weakHighExtended and high > rangeHigh and close < rangeHigh
        rangeHigh := high
        weakHighExtended := true

    // weak breakdown below
    if not weakLowExtended and low < rangeLow and close > rangeLow
        rangeLow := low
        weakLowExtended := true

// === BREAKOUT CONDITIONS (5 MIN TF recommended) ===
buyCondition = rangeSet and not buyTaken and close > (rangeHigh + bufferPoints)
sellCondition = rangeSet and not sellTaken and close < (rangeLow - bufferPoints)

// === EXECUTE SIGNALS ===
if buyCondition
    buyTaken := true
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.green)
    line.new(bar_index, close + targetPoints, bar_index + 10, close + targetPoints, color=color.green)
    line.new(bar_index, close - targetPoints, bar_index + 10, close - targetPoints, color=color.red)

if sellCondition
    sellTaken := true
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.red)
    line.new(bar_index, close + targetPoints, bar_index + 10, close + targetPoints, color=color.green)
    line.new(bar_index, close - targetPoints, bar_index + 10, close - targetPoints, color=color.red)

// === PLOT RANGE ===
plot(rangeHigh, "Range High", color=color.blue, linewidth=2)
plot(rangeLow, "Range Low", color=color.orange, linewidth=2)
````
