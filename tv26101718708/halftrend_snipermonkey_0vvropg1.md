# HalfTrend SNIPERMONKEY

- url: https://www.tradingview.com/script/0vvrOpg1-HalfTrend-SNIPERMONKEY/
- type: strategy
- pine_id: PUB;11a11726d64549ad9920fdfd1c5765c1
- version: 1.0

## Description

The HalfTrend algorithm identifies trend direction by tracking swing highs and lows over a configurable amplitude period. It uses ATR-based channel bands to confirm trend transitions and generates buy/sell signals only when a genuine trend flip occurs — filtering out a large portion of noise compared to a standard moving average crossover.

Strategy Features
🕘 Session-Based Entry Window (9:20 AM – 3:20 PM IST)

Entries are restricted to market hours. No new positions are opened outside this window.
⏩ Pre-Session Signal Carry-Forward

If a HalfTrend signal fires before 9:20 AM (e.g., on pre-market or overnight bars), it is latched and executed automatically at the session open — so you never miss a signal that formed while the market was closed.
🔁 Automatic Position Flip

When the trend reverses mid-session, the strategy closes the existing position and enters in the opposite direction in a single step.
🔔 EOD Square-Off at 3:20 PM

All open positions are forcibly closed at 3:20 PM IST to avoid carrying trades into close — aligned with SEBI intraday margin norms.

## Source Code

````pine
//@version=6
// Based on HalfTrend by SNIPERMONKEY
// Strategy version with time-based session filtering (9:20 AM - 3:20 PM)
// Pre-session signals are carried forward and fired at 9:20 AM open
strategy('HalfTrend Strategy', overlay = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100)

const string calcGroup = 'Calculation'
amplitude = input.int(2, title = 'Amplitude', group = calcGroup)
channelDeviation = input.int(2, title = 'Channel Deviation', group = calcGroup)

const string visualGroup = 'Visuals'
showArrows = input.bool(true, title = 'Show Arrows', group = visualGroup)
showChannels = input.bool(true, title = 'Show Channels', group = visualGroup)
showLabels = input.bool(true, title = 'Show Buy/Sell Labels', group = visualGroup)

const string sessionGroup = 'Session'
sessionTZ   = input.string('Asia/Kolkata', title = 'Timezone', group = sessionGroup)
entryStart  = input.session('0920-1520',   title = 'Entry & Exit Window', group = sessionGroup)

// ── Session gates ─────────────────────────────────────────────────
inSession  = not na(time(timeframe.period, entryStart, sessionTZ))
sessionOpen = inSession and not inSession[1]   // first bar at/after 9:20

exitTime   = (hour(time, sessionTZ) == 15 and minute(time, sessionTZ) >= 20) or
              (hour(time, sessionTZ) > 15)

// ── HalfTrend Core ───────────────────────────────────────────────
var int trend = 0
var int nextTrend = 0
var float maxLowPrice = nz(low[1], low)
var float minHighPrice = nz(high[1], high)

var float up = 0.0
var float down = 0.0
float atrHigh = 0.0
float atrLow = 0.0
float arrowUp = na
float arrowDown = na

atr2 = ta.atr(100) / 2
dev = channelDeviation * atr2

highPrice = high[math.abs(ta.highestbars(amplitude))]
lowPrice  = low[math.abs(ta.lowestbars(amplitude))]
highma    = ta.sma(high, amplitude)
lowma     = ta.sma(low, amplitude)

if nextTrend == 1
    maxLowPrice := math.max(lowPrice, maxLowPrice)
    if highma < maxLowPrice and close < nz(low[1], low)
        trend      := 1
        nextTrend  := 0
        minHighPrice := highPrice
else
    minHighPrice := math.min(highPrice, minHighPrice)
    if lowma > minHighPrice and close > nz(high[1], high)
        trend      := 0
        nextTrend  := 1
        maxLowPrice := lowPrice

if trend == 0
    if not na(trend[1]) and trend[1] != 0
        up      := na(down[1]) ? down : down[1]
        arrowUp := up - atr2
    else
        up := na(up[1]) ? maxLowPrice : math.max(maxLowPrice, up[1])
    atrHigh := up + dev
    atrLow  := up - dev
else
    if not na(trend[1]) and trend[1] != 1
        down      := na(up[1]) ? up : up[1]
        arrowDown := down + atr2
    else
        down := na(down[1]) ? minHighPrice : math.min(minHighPrice, down[1])
    atrHigh := down + dev
    atrLow  := down - dev

ht = trend == 0 ? up : down

buySignal  = not na(arrowUp)   and trend == 0 and trend[1] == 1
sellSignal = not na(arrowDown) and trend == 1 and trend[1] == 0

// ── Pre-session signal latch ──────────────────────────────────────
// Tracks the most recent signal that fired before session open.
// 1 = buy pending, -1 = sell pending, 0 = nothing pending
var int pendingSignal = 0

if not inSession
    if buySignal
        pendingSignal := 1
    else if sellSignal
        pendingSignal := -1

// Resolve the pending signal on the first bar of the session,
// but only if a live signal hasn't already fired on that same bar.
carryBuy  = sessionOpen and pendingSignal == 1  and not buySignal
carrySell = sessionOpen and pendingSignal == -1 and not sellSignal

if sessionOpen
    pendingSignal := 0   // clear latch once session begins

// Final entry signals: live signal OR carried-forward signal
entryBuy  = (buySignal  and inSession) or carryBuy
entrySell = (sellSignal and inSession) or carrySell

// ── Strategy Entries / Exits ──────────────────────────────────────
if entryBuy and strategy.position_size <= 0
    if strategy.position_size < 0
        strategy.close('Short', comment = 'Short → Long flip')
    strategy.entry('Long', strategy.long, comment = carryBuy ? 'HT Buy (carried)' : 'HT Buy')

if entrySell and strategy.position_size >= 0
    if strategy.position_size > 0
        strategy.close('Long', comment = 'Long → Short flip')
    strategy.entry('Short', strategy.short, comment = carrySell ? 'HT Sell (carried)' : 'HT Sell')

// Force-close all positions at 3:20 PM
if exitTime and strategy.position_size != 0
    strategy.close_all(comment = 'EOD Exit 3:20 PM')

// ── Visuals ───────────────────────────────────────────────────────
const color buyColor      = color.blue
const color sellColor     = color.red
const color textColor     = color.white
const color buyFillColor  = color.new(color.blue, 85)
const color sellFillColor = color.new(color.red,  85)

htColor = trend == 0 ? buyColor : sellColor
htPlot  = plot(ht, title = 'HalfTrend', linewidth = 2, color = htColor)

atrHighPlot = plot(showChannels ? atrHigh : na, title = 'ATR High', style = plot.style_circles, color = sellColor)
atrLowPlot  = plot(showChannels ? atrLow  : na, title = 'ATR Low',  style = plot.style_circles, color = buyColor)

fill(htPlot, atrHighPlot, title = 'ATR High Ribbon', color = sellFillColor)
fill(htPlot, atrLowPlot,  title = 'ATR Low Ribbon',  color = buyFillColor)

plotshape(showArrows and buySignal  ? atrLow  : na, title = 'Arrow Up',   style = shape.triangleup,   location = location.absolute, size = size.tiny, color = buyColor)
plotshape(showArrows and sellSignal ? atrHigh : na, title = 'Arrow Down', style = shape.triangledown, location = location.absolute, size = size.tiny, color = sellColor)

plotshape(showLabels and buySignal  ? atrLow  : na, title = 'Buy Label',  text = 'Buy',  location = location.absolute, style = shape.labelup,   size = size.tiny, color = buyColor,  textcolor = textColor)
plotshape(showLabels and sellSignal ? atrHigh : na, title = 'Sell Label', text = 'Sell', location = location.absolute, style = shape.labeldown, size = size.tiny, color = sellColor, textcolor = textColor)

alertcondition(entryBuy,  title = 'HalfTrend Buy',  message = 'HalfTrend Buy, {{exchange}}:{{ticker}}')
alertcondition(entrySell, title = 'HalfTrend Sell', message = 'HalfTrend Sell, {{exchange}}:{{ticker}}')
````
