# Market Memory Levels [forexobroker]

- url: https://www.tradingview.com/script/B7jHcmun-Market-Memory-Levels-forexobroker/
- type: indicator
- pine_id: PUB;2717d4bdb413445c8a6a12802cc9ed60
- version: 1.0

## Description

Markets have memory. The price levels that mattered yesterday still matter today, because thousands of traders are watching the exact same numbers.

Market Memory Levels automatically plots the levels that institutional traders, algorithms, and retail traders all reference -- and detects when price reacts at them.

Three Types of Memory Levels:

Previous Day High/Low/Close -- These are the most-watched intraday reference points in professional trading. The previous day's high represents yesterday's ceiling; the low represents the floor. The close represents the settlement -- where the market found agreement. Moves above or below these levels define intraday bias.

Previous Week High/Low -- Weekly levels carry even more significance because swing traders, fund managers, and position traders use them. A break of the weekly high attracts momentum; a hold of the weekly low confirms support.

Round Number Levels -- The indicator auto-detects your instrument type and plots the appropriate psychological levels:

Forex: Every 50 pips (1.0800, 1.0850, 1.0900...)
Crypto: Every $1,000 ($60,000, $61,000, $62,000...)
Stocks: Every $5 ($150, $155, $160...)
Round numbers work because humans are drawn to them. Limit orders, stop losses, and take profits cluster at these levels, creating self-fulfilling support and resistance.

Signal Logic:

BUY when price approaches a memory support level within ATR proximity, prints a bullish candle with strong body (body > 40% of range), and volume confirms above SMA(20). This is a "bounce" -- the level held and buyers stepped in.

SELL when price approaches a memory resistance level, prints a bearish rejection candle, and volume confirms. This is a "rejection" -- the level held and sellers defended it.

The Info Table:

The real-time table displays all active levels, their exact prices, the current round number spacing, and distance to the nearest round number. When price is within striking distance of a level, the table highlights it.

How to Use:

Start each trading day by checking where price sits relative to the memory levels. Is it above or below the previous day close? Has it tested the weekly high? Is a round number nearby? These levels form the battlefield map for the session.

When signals fire at these levels with volume, the probability of a genuine reaction increases because you have institutional-level awareness of where orders cluster.

Works best on intraday timeframes (5-minute to 1-hour) for forex, crypto, and stock markets.

LIMITATIONS

Previous day/week levels require sufficient chart history to display
On non-standard chart types (Heikin Ashi, Renko), values may differ from standard candles
Round number spacing is preset for common asset classes and may not suit all instruments
Bounce/rejection detection uses single-candle patterns which can produce false signals
Volume filtering depends on data feed quality (tick volume for forex)
Signals are confirmed after bar close, adding one bar of delay
Memory levels are observational reference points, not predictive guarantees
Not financial advice

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Market Memory Levels [forexobroker]", shorttitle="MML [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
grpLevels = "Memory Levels"
showPrevDay  = input.bool(true, "Show Previous Day H/L/C", group=grpLevels, tooltip="Plot previous day high, low, and close")
showPrevWeek = input.bool(true, "Show Previous Week H/L", group=grpLevels, tooltip="Plot previous week high and low")
showRound    = input.bool(true, "Show Round Number Levels", group=grpLevels, tooltip="Auto-detect and plot round number levels")
roundMode    = input.string("Auto", "Round Number Mode", options=["Auto", "Forex 50pip", "Crypto 1000", "Stocks 5"], group=grpLevels, tooltip="Auto-detect or manually set round number spacing")
roundCount   = input.int(3, "Round Levels Above/Below", minval=1, maxval=10, group=grpLevels)

grpSignal = "Signal Settings"
bounceAtr    = input.float(0.3, "Bounce Proximity (ATR mult)", minval=0.1, maxval=1.0, step=0.1, group=grpSignal, tooltip="How close price must be to a level")
volMulti     = input.float(1.0, "Volume SMA(20) Multiplier", minval=0.5, maxval=3.0, step=0.1, group=grpSignal)
cooldownBars = input.int(15, "Signal Cooldown (bars)", minval=5, maxval=50, group=grpSignal)
emaFilterLen = input.int(50, "EMA Filter Length", minval=10, maxval=200, group=grpSignal)

grpVisual = "Visual Settings"
dayHighClr   = input.color(color.new(#00d4ff, 0), "Prev Day High Color", group=grpVisual)
dayLowClr    = input.color(color.new(#ff2d78, 0), "Prev Day Low Color", group=grpVisual)
dayCloseClr  = input.color(color.new(#a855f7, 0), "Prev Day Close Color", group=grpVisual)
weekClr      = input.color(color.new(#ffaa00, 0), "Prev Week Color", group=grpVisual)
roundClr     = input.color(color.new(#39ff14, 30), "Round Number Color", group=grpVisual)
bullSignalClr = input.color(color.new(#00d4ff, 0), "Bull Signal Color", group=grpVisual)
bearSignalClr = input.color(color.new(#ff2d78, 0), "Bear Signal Color", group=grpVisual)
showTable    = input.bool(true, "Show Info Table", group=grpVisual)
showGlow     = input.bool(true, "Show Glow Effects", group=grpVisual)
tablePos     = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpVisual)

grpStats = "Statistics"
showStats    = input.bool(true, "Show Signal Statistics", group=grpStats, tooltip="Display running signal count")
showProxWarn = input.bool(true, "Show Proximity Warnings", group=grpStats, tooltip="Highlight when price approaches memory levels")
proxWarnClr  = input.color(color.new(#ffaa00, 80), "Proximity Warning Color", group=grpStats)

// ─── CORE CALCULATIONS ──────────────────────────────────────────────────────
atrVal       = ta.atr(14)
ema50        = ta.ema(close, emaFilterLen)
ema200       = ta.ema(close, 200)
volSma       = ta.sma(volume, 20)
volOk        = volume > volSma * volMulti
volRatio     = volSma > 0 ? volume / volSma : 0.0

// ─── DAILY BIAS CALCULATION ─────────────────────────────────────────────────
// Determine intraday bias based on price position relative to previous day close
// This is a key institutional reference used by professional traders globally.

// ─── PREVIOUS DAY LEVELS ────────────────────────────────────────────────────
// These are the most-watched intraday reference levels in professional trading.
// PDH = yesterday's ceiling, PDL = yesterday's floor, PDC = settlement level.
prevDayHigh  = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
prevDayLow   = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
prevDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)

// ─── PREVIOUS WEEK LEVELS ────────────────────────────────────────────────────
// Weekly levels carry more weight because swing traders and fund managers use them.
// A weekly high/low break attracts significant institutional order flow.
prevWeekHigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
prevWeekLow  = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)

// ─── ROUND NUMBER CALCULATION ────────────────────────────────────────────────
// Auto-detect instrument type and calculate appropriate round number spacing.
// Forex: every 50 pips | Crypto: every $1000 | Stocks: every $5
// Round numbers work because humans cluster limit orders and stops at them.
isForex      = syminfo.type == "forex"
isCrypto     = syminfo.type == "crypto"
autoStep     = isForex ? syminfo.mintick * 500 : isCrypto ? 1000.0 : 5.0
roundStep    = roundMode == "Auto" ? autoStep : roundMode == "Forex 50pip" ? syminfo.mintick * 500 : roundMode == "Crypto 1000" ? 1000.0 : 5.0
baseRound    = math.floor(close / roundStep) * roundStep

// --- Proximity Detection ---
proximityThresh = atrVal * bounceAtr

isNearLevel(float lvl) =>
    math.abs(close - lvl) < proximityThresh

// --- Bullish Bounce Detection ---
bullishCandle = close > open and (close - open) > (high - low) * 0.4

nearSupportLevel = (showPrevDay and isNearLevel(prevDayLow)) or (showPrevWeek and isNearLevel(prevWeekLow)) or (showPrevDay and isNearLevel(prevDayClose) and close > prevDayClose)
nearResistLevel  = (showPrevDay and isNearLevel(prevDayHigh)) or (showPrevWeek and isNearLevel(prevWeekHigh)) or (showPrevDay and isNearLevel(prevDayClose) and close < prevDayClose)

// Check round number proximity
var bool nearRoundSupport = false
var bool nearRoundResist  = false
nearRoundSupport := false
nearRoundResist  := false

if showRound
    for i = -roundCount to roundCount
        lvl = baseRound + i * roundStep
        if isNearLevel(lvl) and close >= lvl
            nearRoundSupport := true
        if isNearLevel(lvl) and close <= lvl
            nearRoundResist := true

supportBounce = (nearSupportLevel or nearRoundSupport) and bullishCandle
resistReject  = (nearResistLevel or nearRoundResist) and not bullishCandle and (open - close) > (high - low) * 0.4

// --- Cooldown ---
var int lastSignalBar = 0
cooldownOk = bar_index - lastSignalBar >= cooldownBars

// --- Final Signals ---
buySignal  = supportBounce and volOk and cooldownOk and barstate.isconfirmed
sellSignal = resistReject and volOk and cooldownOk and barstate.isconfirmed

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── SIGNAL STATISTICS ───────────────────────────────────────────────────────
var int totalBounces    = 0
var int totalRejections = 0
var int dailyBounces    = 0
var int dailyRejections = 0
var int roundBounces    = 0
var int weeklyBounces   = 0

if buySignal
    totalBounces += 1
    if nearSupportLevel
        dailyBounces += 1
    if nearRoundSupport
        roundBounces += 1

if sellSignal
    totalRejections += 1
    if nearResistLevel
        dailyRejections += 1

// ─── DAILY BIAS DETERMINATION ────────────────────────────────────────────────
// Price position relative to PDC determines intraday directional bias
abovePDC     = not na(prevDayClose) and close > prevDayClose
belowPDC     = not na(prevDayClose) and close < prevDayClose
abovePDH     = not na(prevDayHigh) and close > prevDayHigh
belowPDL     = not na(prevDayLow) and close < prevDayLow
dailyBias    = abovePDH ? 2 : abovePDC ? 1 : belowPDL ? -2 : belowPDC ? -1 : 0

// ─── PROXIMITY WARNING HIGHLIGHTING ─────────────────────────────────────────
// Background highlight when price is approaching a memory level but hasn't yet reacted
anyProximity = nearSupportLevel or nearResistLevel or nearRoundSupport or nearRoundResist

// ─── LEVEL CONFLUENCE DETECTION ──────────────────────────────────────────────
// Count how many levels are near current price for confluence scoring
confluenceCount = 0
if nearSupportLevel
    confluenceCount += 1
if nearResistLevel
    confluenceCount += 1
if nearRoundSupport or nearRoundResist
    confluenceCount += 1

// ─── PLOT LEVELS ─────────────────────────────────────────────────────────────
plot(showPrevDay ? prevDayHigh : na, "Prev Day High", dayHighClr, 2, plot.style_line)
plot(showPrevDay ? prevDayLow : na, "Prev Day Low", dayLowClr, 2, plot.style_line)
plot(showPrevDay ? prevDayClose : na, "Prev Day Close", dayCloseClr, 1, plot.style_cross)
plot(showPrevWeek ? prevWeekHigh : na, "Prev Week High", weekClr, 2, plot.style_line)
plot(showPrevWeek ? prevWeekLow : na, "Prev Week Low", weekClr, 2, plot.style_line)

// --- Round Number Lines ---
if showRound and barstate.islast
    for i = -roundCount to roundCount
        lvl = baseRound + i * roundStep
        line.new(bar_index - 50, lvl, bar_index + 10, lvl, color=roundClr, style=line.style_dotted, width=1)
        label.new(bar_index + 12, lvl, str.tostring(lvl, format.mintick), style=label.style_none, textcolor=roundClr, size=size.tiny)

// ─── 3-LAYER GLOW ARROWS (Global Scope) ────────────────────────────────────
plotshape(showGlow and buySignal, "Buy Glow 1", shape.triangleup, location.belowbar, color.new(bullSignalClr, 80), size=size.huge)
plotshape(showGlow and buySignal, "Buy Glow 2", shape.triangleup, location.belowbar, color.new(bullSignalClr, 50), size=size.large)
plotshape(buySignal, "Buy Arrow", shape.triangleup, location.belowbar, color.new(bullSignalClr, 0), size=size.normal)

plotshape(showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(bearSignalClr, 80), size=size.huge)
plotshape(showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(bearSignalClr, 50), size=size.large)
plotshape(sellSignal, "Sell Arrow", shape.triangledown, location.abovebar, color.new(bearSignalClr, 0), size=size.normal)

// ─── SIGNAL LABELS ───────────────────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 0.6, "BOUNCE\nBUY", style=label.style_label_up, color=bullSignalClr, textcolor=color.white, size=size.normal)

if sellSignal
    label.new(bar_index, high + atrVal * 0.6, "REJECT\nSELL", style=label.style_label_down, color=bearSignalClr, textcolor=color.white, size=size.normal)

// ─── INFO TABLE ──────────────────────────────────────────────────────────────
if showTable and barstate.islast
    tblPos = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left
    var table info = table.new(tblPos, 2, 14, bgcolor=color.new(#1A1A2E, 10), border_width=1, border_color=color.new(#FFFFFF, 80))
    // --- Header ---
    table.cell(info, 0, 0, "MEMORY LEVELS", text_color=color.white, text_size=size.small, bgcolor=color.new(#0D47A1, 20))
    table.merge_cells(info, 0, 0, 1, 0)
    // --- Daily Levels ---
    table.cell(info, 0, 1, "Prev Day H", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 1, str.tostring(prevDayHigh, format.mintick), text_color=dayHighClr, text_size=size.tiny)
    table.cell(info, 0, 2, "Prev Day L", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 2, str.tostring(prevDayLow, format.mintick), text_color=dayLowClr, text_size=size.tiny)
    table.cell(info, 0, 3, "Prev Day C", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 3, str.tostring(prevDayClose, format.mintick), text_color=dayCloseClr, text_size=size.tiny)
    // --- Weekly Levels ---
    table.cell(info, 0, 4, "Prev Wk H", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 4, str.tostring(prevWeekHigh, format.mintick), text_color=weekClr, text_size=size.tiny)
    table.cell(info, 0, 5, "Prev Wk L", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 5, str.tostring(prevWeekLow, format.mintick), text_color=weekClr, text_size=size.tiny)
    // --- Round Numbers ---
    table.cell(info, 0, 6, "Round Step", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 6, str.tostring(roundStep, format.mintick), text_color=roundClr, text_size=size.tiny)
    distToNearest = math.abs(close - baseRound) < math.abs(close - (baseRound + roundStep)) ? math.abs(close - baseRound) : math.abs(close - (baseRound + roundStep))
    table.cell(info, 0, 7, "Nearest Rnd", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 7, str.tostring(distToNearest, format.mintick), text_color=distToNearest < proximityThresh ? bullSignalClr : color.gray, text_size=size.tiny)
    // --- Bias and Proximity ---
    biasText = dailyBias == 2 ? "STRONG BULL" : dailyBias == 1 ? "BULLISH" : dailyBias == -2 ? "STRONG BEAR" : dailyBias == -1 ? "BEARISH" : "NEUTRAL"
    biasClr = dailyBias > 0 ? bullSignalClr : dailyBias < 0 ? bearSignalClr : color.gray
    table.cell(info, 0, 8, "Daily Bias", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 8, biasText, text_color=biasClr, text_size=size.tiny)
    table.cell(info, 0, 9, "Confluence", text_color=color.gray, text_size=size.tiny)
    confText = confluenceCount >= 2 ? "HIGH (" + str.tostring(confluenceCount) + ")" : confluenceCount == 1 ? "SINGLE" : "NONE"
    confClr = confluenceCount >= 2 ? bullSignalClr : confluenceCount == 1 ? color.new(#ffaa00, 0) : color.gray
    table.cell(info, 1, 9, confText, text_color=confClr, text_size=size.tiny)
    table.cell(info, 0, 10, "Proximity", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 10, anyProximity ? "AT LEVEL" : "CLEAR", text_color=anyProximity ? color.new(#ffaa00, 0) : color.gray, text_size=size.tiny)
    table.cell(info, 0, 11, "Vol Ratio", text_color=color.gray, text_size=size.tiny)
    table.cell(info, 1, 11, str.tostring(volRatio, "#.##") + "x", text_color=volRatio >= 1.5 ? bullSignalClr : color.gray, text_size=size.tiny)
    // --- Statistics ---
    if showStats
        table.cell(info, 0, 12, "Bounces", text_color=color.gray, text_size=size.tiny)
        table.cell(info, 1, 12, str.tostring(totalBounces), text_color=bullSignalClr, text_size=size.tiny)
        table.cell(info, 0, 13, "Rejections", text_color=color.gray, text_size=size.tiny)
        table.cell(info, 1, 13, str.tostring(totalRejections), text_color=bearSignalClr, text_size=size.tiny)

// ─── BARCOLOR ────────────────────────────────────────────────────────────────
barcolor(buySignal ? bullSignalClr : sellSignal ? bearSignalClr : na)

// ─── BACKGROUND ──────────────────────────────────────────────────────────────
// Signal backgrounds take priority; proximity warning is subtle background
proxBg = showProxWarn and anyProximity and not buySignal and not sellSignal ? proxWarnClr : na
bgcolor(buySignal ? color.new(bullSignalClr, 90) : sellSignal ? color.new(bearSignalClr, 90) : proxBg)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
if buySignal
    alert("MML BUY bounce at memory level on " + syminfo.ticker + " " + timeframe.period + " | Close: " + str.tostring(close), alert.freq_once_per_bar_close)

if sellSignal
    alert("MML SELL rejection at memory level on " + syminfo.ticker + " " + timeframe.period + " | Close: " + str.tostring(close), alert.freq_once_per_bar_close)

alertcondition(buySignal, "MML Buy Signal", "Market Memory Levels BUY bounce on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal, "MML Sell Signal", "Market Memory Levels SELL rejection on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal, "MML Any Signal", "Market Memory Levels signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(nearSupportLevel, "Near Support Level", "Price near support memory level on {{ticker}} {{interval}} at {{close}}")
alertcondition(nearResistLevel, "Near Resistance Level", "Price near resistance memory level on {{ticker}} {{interval}} at {{close}}")
alertcondition(nearRoundSupport or nearRoundResist, "Near Round Number", "Price near round number on {{ticker}} {{interval}} at {{close}}")
alertcondition(supportBounce, "Support Bounce", "Support bounce detected on {{ticker}} {{interval}} at {{close}}")
alertcondition(resistReject, "Resistance Reject", "Resistance rejection detected on {{ticker}} {{interval}} at {{close}}")
alertcondition(volOk, "Volume Confirmed", "Volume confirmed above threshold on {{ticker}} {{interval}} at {{close}}")
````
