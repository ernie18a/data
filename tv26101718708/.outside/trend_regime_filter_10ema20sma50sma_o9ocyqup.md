# Trend Regime Filter (10EMA/20SMA/50SMA)

- url: https://www.tradingview.com/script/o9OCYquP-Trend-Regime-Filter-10EMA-20SMA-50SMA/
- type: indicator
- pine_id: PUB;b7efdc6216724176b838e3ccc88fd9a8
- version: 2.0

## Description

Based on the Qullamagie system this filter helps you identify favourable environments to trend trade and try more breakouts

## Source Code

````pine
//@version=6
indicator('Trend Regime Filter (NQ-Based)', overlay = true)

// ───────────────────────────────────────────
// INPUTS
// ───────────────────────────────────────────
emaLen = input.int(10, 'Fast EMA Length')
smaLen = input.int(20, 'Mid SMA Length')
slowSmaLen = input.int(50, 'Slow SMA Length')
slopeLookback = input.int(3, 'Slope Lookback (bars)', tooltip = 'Number of bars back used to check if the EMA/SMA is rising or falling')

showMAs = input.bool(true, 'Plot this chart\'s own moving averages (reference only — does not affect background color)')
bgOpacityGood = input.int(85, 'Background Transparency - Good', minval = 0, maxval = 100)
bgOpacityBad = input.int(85, 'Background Transparency - Bad', minval = 0, maxval = 100)
bgOpacityNeutral = input.int(90, 'Background Transparency - Neutral', minval = 0, maxval = 100)

indexSymbol = input.symbol('CME_MINI:NQ1!', 'Index symbol driving background color', group = 'Index Status')
showIndexLabel = input.bool(true, 'Show NQ regime label', group = 'Index Status')

// ───────────────────────────────────────────
// CURRENT CHART'S OWN MAs — reference lines only, NOT used for background
// ───────────────────────────────────────────
ema10 = ta.ema(close, emaLen)
sma20 = ta.sma(close, smaLen)
sma50 = ta.sma(close, slowSmaLen)

plot(showMAs ? ema10 : na, title = '10 EMA (this chart)', color = color.new(color.blue, 0), linewidth = 2)
plot(showMAs ? sma20 : na, title = '20 SMA (this chart)', color = color.new(color.orange, 0), linewidth = 2)
plot(showMAs ? sma50 : na, title = '50 SMA (this chart)', color = color.new(color.gray, 0), linewidth = 2)

// ───────────────────────────────────────────
// NQ REGIME CALCULATION — this drives the background on EVERY chart
// ───────────────────────────────────────────
nq_close = request.security(indexSymbol, timeframe.period, close)
nq_ema10 = request.security(indexSymbol, timeframe.period, ta.ema(close, emaLen))
nq_sma20 = request.security(indexSymbol, timeframe.period, ta.sma(close, smaLen))
nq_sma50 = request.security(indexSymbol, timeframe.period, ta.sma(close, slowSmaLen))
nq_ema10_prev = request.security(indexSymbol, timeframe.period, ta.ema(close, emaLen)[slopeLookback])
nq_sma20_prev = request.security(indexSymbol, timeframe.period, ta.sma(close, smaLen)[slopeLookback])

nq_ema10_rising = nq_ema10 > nq_ema10_prev
nq_sma20_rising = nq_sma20 > nq_sma20_prev

// GREEN: NQ's 10EMA > 20SMA, both rising
nq_isGreen = nq_ema10 > nq_sma20 and nq_ema10_rising and nq_sma20_rising

// RED: NQ's MA stack bearish (10<20<50), OR NQ price below both 20 and 50 SMA
nq_isRed = nq_ema10 < nq_sma20 and nq_sma20 < nq_sma50 or nq_close < nq_sma20 and nq_close < nq_sma50

// YELLOW: everything else
nq_isYellow = not nq_isGreen and not nq_isRed

// ───────────────────────────────────────────
// BACKGROUND COLOR — always reflects NQ, on ANY chart
// ───────────────────────────────────────────
bgcolor(nq_isGreen ? color.new(color.green, bgOpacityGood) : na, title = 'NQ Good Trend Background')
bgcolor(nq_isRed ? color.new(color.red, bgOpacityBad) : na, title = 'NQ Bad Trend Background')
bgcolor(nq_isYellow ? color.new(color.yellow, bgOpacityNeutral) : na, title = 'NQ Neutral/Choppy Background')

// ───────────────────────────────────────────
// NQ STATUS LABEL (top left)
// ───────────────────────────────────────────
var table nqStatusTable = table.new(position.top_left, 1, 1)

nqStatusText = nq_isGreen ? 'NQ: GREEN — TRADE AGGRESSIVELY' : nq_isRed ? 'NQ: RED — STAND DOWN' : 'NQ: YELLOW — NEUTRAL/CHOPPY'
nqStatusColor = nq_isGreen ? color.new(color.green, 0) : nq_isRed ? color.new(color.red, 0) : color.new(color.orange, 0)

if barstate.islast and showIndexLabel
    table.cell(nqStatusTable, 0, 0, nqStatusText, bgcolor = nqStatusColor, text_color = color.white, text_size = size.normal)

// ───────────────────────────────────────────
// ALERTS — based on NQ regime changes
// ───────────────────────────────────────────
alertcondition(nq_isGreen and not nq_isGreen[1], title = 'NQ Regime turned GREEN', message = 'NQ trend regime flipped to GREEN — favorable conditions to trade aggressively')
alertcondition(nq_isRed and not nq_isRed[1], title = 'NQ Regime turned RED', message = 'NQ trend regime flipped to RED — unfavorable conditions, stand down')
alertcondition(nq_isYellow and not nq_isYellow[1], title = 'NQ Regime turned YELLOW', message = 'NQ trend regime flipped to YELLOW — neutral/choppy conditions')
````
