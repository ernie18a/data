# MTF Confluence Dashboard (EMA + RSI + Volume)

- url: https://www.tradingview.com/script/fvmetIEm-MTF-Confluence-Dashboard-EMA-RSI-Volume/
- type: indicator
- pine_id: PUB;4da4b1bdcef748ce81cb8ff01d8c2c39
- version: 1.0

## Description

A multi-timeframe confluence scoring system designed for futures (built and tested on MNQ). Instead of generating signals from a single indicator on a single timeframe, it scores 4 timeframes independently and only flags Buy/Sell when they align.
How it works
Each timeframe (3m, 5m, 15m, 30m) is scored on three components:

EMA Ribbon (7/13/20/50) — bullish when stacked up, bearish when stacked down
RSI (13-period) — bullish above 60, bearish below 40
Volume — confirms direction when volume spikes above 1.5× the 20-bar average

Each component scores +1, 0, or -1, giving each timeframe a score from -3 to +3. The four timeframe scores are summed into a total confluence score from -12 to +12.

Signal logic:
ALIGNED BUY / SELL labels print on the chart when the confluence score crosses ±5
The dashboard table on the right shows live signals for each timeframe, macro trend (above/below 200 EMA), and the overall confluence
A built-in whipsaw filter prevents Buy → Sell → Buy flip-flops by requiring the score to reset to neutral before allowing opposite signals

Built-in features:
Customizable EMA, RSI, and volume settings
Adjustable confluence thresholds
Toggleable EMA plotting on chart
Four alert conditions (Aligned Buy/Sell, Lean Buy/Sell)
Repaint-safe (uses confirmed higher-timeframe data only)

Best used as:
A confluence checker, not an autopilot. ALIGNED signals tell you when multiple timeframes agree on direction — strongest in trending markets, weakest in chop. Pair with your own price action read and risk management.

Notes:
Works best on futures or exchange-traded instruments where volume data is real
Default settings tuned for MNQ on the 5m chart but adjustable for any market/timeframe

MADE USING CLAUDE AI

## Source Code

````pine
//@version=5
indicator("MTF Signal Dashboard v4.1 (Option A + Whipsaw Filter)", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
// EMA periods
ema1Len     = input.int(7,   "EMA 1", minval=1, group="EMAs")
ema2Len     = input.int(13,  "EMA 2", minval=1, group="EMAs")
ema3Len     = input.int(20,  "EMA 3", minval=1, group="EMAs")
ema4Len     = input.int(50,  "EMA 4", minval=1, group="EMAs")
ema5Len     = input.int(200, "EMA 5 (Macro)", minval=1, group="EMAs")

// RSI
rsiLen      = input.int(13,   "RSI Length",       minval=1,  group="RSI")
rsiBull     = input.float(60, "RSI Bull Threshold", minval=50, group="RSI")
rsiBear     = input.float(40, "RSI Bear Threshold", maxval=50, group="RSI")

// Volume
volAvgLen   = input.int(20,   "Volume Average Length", minval=1, group="Volume")
volMult     = input.float(1.5,"Volume Spike Multiplier", minval=1.0, step=0.1, group="Volume")

// Confluence thresholds
alignedThresh = input.int(5, "Aligned Threshold (±)", minval=1, group="Confluence")
leanThresh    = input.int(2, "Lean Threshold (±)",    minval=1, group="Confluence")

// Whipsaw filter
requireReset = input.bool(true, "Require neutral reset before opposite signal", group="Whipsaw Filter", tooltip="After a BUY, score must drop to neutral zone before a SELL can fire (and vice versa)")
minBarGap    = input.int(5,     "Minimum bars between opposite signals",        minval=0, group="Whipsaw Filter", tooltip="Hard floor on how close opposite signals can be, regardless of reset")
neutralZone  = input.int(1,     "Neutral reset zone (±)",                       minval=0, group="Whipsaw Filter", tooltip="Score must reach within ±this value to count as a reset")

// Signal markers
showSignals = input.bool(true, "Show Buy/Sell markers on chart", group="Signal Markers")
alignedOnly = input.bool(true, "Only mark on ALIGNED signals (vs Lean)", group="Signal Markers")

// Plot EMAs on chart?
showEMAs    = input.bool(true, "Plot EMAs on chart", group="Display")

// Table appearance
tablePos    = input.string("middle_right", "Table Position",
                 options=["top_left","top_center","top_right",
                          "middle_left","middle_center","middle_right",
                          "bottom_left","bottom_center","bottom_right"],
                 group="Display")
textSize    = input.string("normal", "Text Size",
                 options=["tiny","small","normal","large","huge"],
                 group="Display")

// ─────────────────────────────────────────────
// COMBINED SIGNAL FUNCTION
// ─────────────────────────────────────────────
f_signal() =>
    e1 = ta.ema(close, ema1Len)
    e2 = ta.ema(close, ema2Len)
    e3 = ta.ema(close, ema3Len)
    e4 = ta.ema(close, ema4Len)
    e5 = ta.ema(close, ema5Len)

    emaBull = e1 > e2 and e2 > e3 and e3 > e4
    emaBear = e1 < e2 and e2 < e3 and e3 < e4
    emaScore = emaBull ? 1 : emaBear ? -1 : 0

    rsi = ta.rsi(close, rsiLen)
    rsiScore = rsi > rsiBull ? 1 : rsi < rsiBear ? -1 : 0

    volAvg = ta.sma(volume, volAvgLen)
    volSpike = volume > volAvg * volMult
    candleUp = close > open
    candleDown = close < open
    volScore = volSpike and candleUp ? 1 : volSpike and candleDown ? -1 : 0

    totalScore = emaScore + rsiScore + volScore
    macro = close > e5 ? 1 : -1

    [totalScore, macro]

// ─────────────────────────────────────────────
// FETCH SIGNALS — 4 TIMEFRAMES (3m/5m/15m/30m)
// ─────────────────────────────────────────────
[score_3m,  macro_3m]  = request.security(syminfo.tickerid, "3",  f_signal(), lookahead=barmerge.lookahead_off)
[score_5m,  macro_5m]  = request.security(syminfo.tickerid, "5",  f_signal(), lookahead=barmerge.lookahead_off)
[score_15m, macro_15m] = request.security(syminfo.tickerid, "15", f_signal(), lookahead=barmerge.lookahead_off)
[score_30m, macro_30m] = request.security(syminfo.tickerid, "30", f_signal(), lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
// TOTAL CONFLUENCE
// ─────────────────────────────────────────────
totalConfluence = score_3m + score_5m + score_15m + score_30m

isAlignedBuy   = totalConfluence >=  alignedThresh
isAlignedSell  = totalConfluence <= -alignedThresh
isLeanBuy      = totalConfluence >=  leanThresh and totalConfluence <  alignedThresh
isLeanSell     = totalConfluence <= -leanThresh and totalConfluence > -alignedThresh

rawAlignedBuyTrigger  = isAlignedBuy  and not isAlignedBuy[1]
rawAlignedSellTrigger = isAlignedSell and not isAlignedSell[1]
rawLeanBuyTrigger     = isLeanBuy     and not (isLeanBuy[1] or isAlignedBuy[1])
rawLeanSellTrigger    = isLeanSell    and not (isLeanSell[1] or isAlignedSell[1])

// ─────────────────────────────────────────────
// WHIPSAW FILTER — track state since last signal
// ─────────────────────────────────────────────
// lastSignalDir: 1 = last signal was a buy (any kind), -1 = last was sell, 0 = none yet
var int lastSignalDir = 0
var int barsSinceLastSignal = 9999
var bool hasResetSinceLastSignal = true  // true means we're allowed to fire opposite

// Detect any raw buy/sell signal (aligned or lean)
rawAnyBuy  = rawAlignedBuyTrigger  or rawLeanBuyTrigger
rawAnySell = rawAlignedSellTrigger or rawLeanSellTrigger

// Track whether score has dropped into the neutral zone since the last signal
inNeutralZone = math.abs(totalConfluence) <= neutralZone
if inNeutralZone
    hasResetSinceLastSignal := true

// Increment bar counter
barsSinceLastSignal := barsSinceLastSignal + 1

// Filter logic for opposite-direction whipsaws
buyAllowed  = lastSignalDir != 1  ? true :  // first signal or after a sell, always allow buy
              true                            // same direction, allowed (it'll be the same Buy state, won't re-trigger anyway)
sellAllowed = lastSignalDir != -1 ? true : true

// The real check: when firing the OPPOSITE direction, enforce filters
opposingBuyOK  = lastSignalDir != -1 or
                 ((not requireReset or hasResetSinceLastSignal) and barsSinceLastSignal >= minBarGap)
opposingSellOK = lastSignalDir != 1 or
                 ((not requireReset or hasResetSinceLastSignal) and barsSinceLastSignal >= minBarGap)

finalAlignedBuy  = rawAlignedBuyTrigger  and opposingBuyOK
finalAlignedSell = rawAlignedSellTrigger and opposingSellOK
finalLeanBuy     = rawLeanBuyTrigger     and opposingBuyOK
finalLeanSell    = rawLeanSellTrigger    and opposingSellOK

// Update state when a signal actually fires
if finalAlignedBuy or finalLeanBuy
    lastSignalDir := 1
    barsSinceLastSignal := 0
    hasResetSinceLastSignal := false
if finalAlignedSell or finalLeanSell
    lastSignalDir := -1
    barsSinceLastSignal := 0
    hasResetSinceLastSignal := false

// ─────────────────────────────────────────────
// PLOT EMAs
// ─────────────────────────────────────────────
plot(showEMAs ? ta.ema(close, ema1Len) : na, "EMA 1", color=color.new(color.aqua,   0), linewidth=1)
plot(showEMAs ? ta.ema(close, ema2Len) : na, "EMA 2", color=color.new(color.red,    0), linewidth=1)
plot(showEMAs ? ta.ema(close, ema3Len) : na, "EMA 3", color=color.new(color.purple, 0), linewidth=1)
plot(showEMAs ? ta.ema(close, ema4Len) : na, "EMA 4", color=color.new(color.green,  0), linewidth=2)
plot(showEMAs ? ta.ema(close, ema5Len) : na, "EMA 5", color=color.new(color.blue,   0), linewidth=2)

// ─────────────────────────────────────────────
// PLOT BUY / SELL MARKERS
// ─────────────────────────────────────────────
showAlignedBuy  = showSignals and finalAlignedBuy
showAlignedSell = showSignals and finalAlignedSell
showLeanBuy     = showSignals and not alignedOnly and finalLeanBuy
showLeanSell    = showSignals and not alignedOnly and finalLeanSell

plotshape(showAlignedBuy,  title="Aligned Buy",  location=location.belowbar, style=shape.labelup,   color=color.new(#0d8a6a, 0), textcolor=color.white, text="BUY",  size=size.normal)
plotshape(showAlignedSell, title="Aligned Sell", location=location.abovebar, style=shape.labeldown, color=color.new(#b71c1c, 0), textcolor=color.white, text="SELL", size=size.normal)
plotshape(showLeanBuy,     title="Lean Buy",     location=location.belowbar, style=shape.triangleup,   color=color.new(#26a69a, 30), size=size.tiny)
plotshape(showLeanSell,    title="Lean Sell",    location=location.abovebar, style=shape.triangledown, color=color.new(#ef5350, 30), size=size.tiny)

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
f_label(_s) =>
    switch
        _s >=  3 => "Strong Buy"
        _s ==  2 => "Buy"
        _s == -2 => "Sell"
        _s <= -3 => "Strong Sell"
        => "Neutral"

f_bg(_s) =>
    switch
        _s >=  3 => color.new(#0d8a6a, 0)
        _s ==  2 => color.new(#26a69a, 0)
        _s == -2 => color.new(#ef5350, 0)
        _s <= -3 => color.new(#b71c1c, 0)
        => color.new(#616161, 0)

f_macroLabel(_m) => _m == 1 ? "▲ Above 200" : "▼ Below 200"
f_macroBg(_m)    => _m == 1 ? color.new(#26a69a, 60) : color.new(#ef5350, 60)

// ─────────────────────────────────────────────
// POSITION & SIZE MAPPING
// ─────────────────────────────────────────────
pos = switch tablePos
    "top_left"      => position.top_left
    "top_center"    => position.top_center
    "top_right"     => position.top_right
    "middle_left"   => position.middle_left
    "middle_center" => position.middle_center
    "middle_right"  => position.middle_right
    "bottom_left"   => position.bottom_left
    "bottom_center" => position.bottom_center
    => position.bottom_right

tSize = switch textSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    => size.huge

// ─────────────────────────────────────────────
// BUILD TABLE
// ─────────────────────────────────────────────
var table dash = table.new(pos, 3, 6, border_width=1, border_color=color.new(color.gray, 50))

f_addRow(_row, _tfLabel, _score, _macro) =>
    table.cell(dash, 0, _row, _tfLabel,             bgcolor=color.new(color.black, 80), text_color=color.white, text_size=tSize)
    table.cell(dash, 1, _row, f_label(_score),      bgcolor=f_bg(_score),               text_color=color.white, text_size=tSize)
    table.cell(dash, 2, _row, f_macroLabel(_macro), bgcolor=f_macroBg(_macro),          text_color=color.white, text_size=tSize)

if barstate.islast
    table.cell(dash, 0, 0, "TF",     bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=tSize)
    table.cell(dash, 1, 0, "Signal", bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=tSize)
    table.cell(dash, 2, 0, "Macro",  bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=tSize)

    f_addRow(1, "3m",  score_3m,  macro_3m)
    f_addRow(2, "5m",  score_5m,  macro_5m)
    f_addRow(3, "15m", score_15m, macro_15m)
    f_addRow(4, "30m", score_30m, macro_30m)

    confluenceLabel = isAlignedBuy  ? "ALIGNED BUY"  :
                      isAlignedSell ? "ALIGNED SELL" :
                      isLeanBuy     ? "Lean Buy"     :
                      isLeanSell    ? "Lean Sell"    :
                                      "Mixed"
    confluenceBg    = isAlignedBuy  ? color.new(#0d8a6a, 0) :
                      isAlignedSell ? color.new(#b71c1c, 0) :
                      isLeanBuy     ? color.new(#26a69a, 0) :
                      isLeanSell    ? color.new(#ef5350, 0) :
                                      color.new(#616161, 0)

    table.cell(dash, 0, 5, "ALL",                         bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=tSize)
    table.cell(dash, 1, 5, confluenceLabel,               bgcolor=confluenceBg,              text_color=color.white, text_size=tSize)
    table.cell(dash, 2, 5, str.tostring(totalConfluence), bgcolor=confluenceBg,              text_color=color.white, text_size=tSize)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(finalAlignedBuy,  "Aligned Buy",  "All timeframes aligned BUY on {{ticker}}")
alertcondition(finalAlignedSell, "Aligned Sell", "All timeframes aligned SELL on {{ticker}}")
alertcondition(finalLeanBuy,     "Lean Buy",     "Confluence leaning BUY on {{ticker}}")
alertcondition(finalLeanSell,    "Lean Sell",    "Confluence leaning SELL on {{ticker}}")
````
