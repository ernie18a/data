# Advanced First + Red + 12:45 Breakout Indicator

- url: https://www.tradingview.com/script/LVgXmEbf-Advanced-First-Red-12-45-Breakout-Indicator/
- type: indicator
- pine_id: PUB;17870525210240eead046bd1071ecc1e
- version: 1.0

## Description

Here's a description you can use when publishing this indicator on TradingView:

---

**Advanced First Red + 12:45 Breakout Indicator**

This multi-timeframe intraday indicator is built for NSE/BSE traders and combines several powerful confluence levels into a single overlay, helping you identify bias, breakout opportunities, and key institutional price zones — all visible consistently across any chart timeframe.

---

**What this indicator does:**

**🟣 First 5-Min Candle Zone (Purple Cloud)**
Marks the high and low of the opening 9:15 AM candle on the 5-minute timeframe as purple horizontal lines with a shaded cloud between them. When price is trapped inside this zone, the market is range-bound. A breakout above or below signals the start of a directional move.

**🔴 First Red Bar 50% Level (Red Line)**
Identifies the first red (bearish) candle of the day on the 5-minute timeframe and marks its 50% midpoint with a solid red horizontal line. Price above this line = positive/bullish bias. Price below = negative/bearish bias. Resets every trading day.

**🔵 12:45 PM Candle 50% Level (Blue Line)**
Fetches the 12:45 PM candle from the 30-minute timeframe and marks its midpoint with a solid blue line. This level acts as a mid-session bias filter — useful for afternoon trades. Shows "Pending" until 12:45 PM is reached.

**⚫ Gap 50% Level (Grey Line)**
Calculates the gap between yesterday's close and today's open, and marks the exact 50% retracement of that gap with a solid grey line. Colour-coded — lime for gap up, orange for gap down. A key magnet level that price frequently revisits during the session.

**🟢🔴 First Red / 12:45 Breakout Strategy**
The core breakout engine captures either the first red candle of the day or the 12:45 PM candle (configurable) as reference levels. Buy signals trigger when price crosses above the reference high with bullish EMA confirmation. Sell signals trigger on a cross below the reference low with bearish confirmation. Entry, stoploss, and target levels are plotted automatically based on your chosen Risk:Reward ratio.

**📊 Dashboard (Top Right)**
A clean real-time table displays all key levels and bias readings in one place: Reference candle, Ref High/Low, Strategy Bias, EMA Trend Filter, 5M High/Low, 1st Red 50% bias, 12:45 30M 50% bias, Gap direction, and Gap 50% level.

---

**Key Features:**
- All levels fetched via `request.security()` — fully timeframe-independent, visible on 1-min, 3-min, 5-min, 15-min, and higher charts
- Optional EMA trend filter (default 50 EMA) to avoid counter-trend trades
- Toggle each feature on/off independently via inputs
- Right-edge labels on every level showing price and current bias
- 10 built-in alert conditions covering breakouts, bias flips, and gap fills
- Works on any NSE/BSE instrument — index, futures, or stocks

---

**Recommended Timeframes:** 1-min, 3-min, 5-min, 15-min

**Best used with:** Nifty 50, Bank Nifty, Sensex, or liquid large-cap stocks during Indian market hours (9:15 AM – 3:30 PM IST)

---

*Code generated using PineGPT — www.marketcalls.in*
*© algostudio — Published under Mozilla Public License 2.0*

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// © algostudio

//Code Generated using PineGPT  - www.marketcalls.in

//@version=6
indicator("Advanced First Red + 12:45 Breakout Indicator", overlay=true, max_labels_count=500)

// ── INPUTS ─────────────────────────────────────────────────────────────────
sessionInput   = input.session("0915-1530", "Trading Session")
useFirstRed    = input.bool(true, "Use First Red Candle")
useSpecial     = input.bool(true, "Use 12:45 Candle")
useBodyLevels  = input.bool(false, "Use Candle Body High/Low Instead Of Wick")
useTrendFilter = input.bool(true, "Use EMA Trend Filter")
emaLength      = input.int(50, "EMA Length")
showTargets    = input.bool(true, "Show Target / Stoploss")
rr             = input.float(1.5, "Risk Reward", step=0.1)

specialHour   = input.int(12, "Special Candle Hour")
specialMinute = input.int(45, "Special Candle Minute")

// ── FIRST 5-MIN CANDLE INPUTS ──────────────────────────────────────────────
showFirst5  = input.bool(true, "Show First 5-Min Candle High/Low")
first5Color = input.color(color.new(color.purple, 92), "First 5-Min Cloud Color")

// ── GAP 50% INPUTS ─────────────────────────────────────────────────────────
showGap50    = input.bool(true, "Show 50% Gap Level")
gapUpColor   = input.color(color.new(color.lime, 0),   "Gap Up 50% Line Color")
gapDownColor = input.color(color.new(color.orange, 0), "Gap Down 50% Line Color")
noGapColor   = input.color(color.new(color.gray, 0),   "No Gap - 50% Line Color")

// ── 12:45 30-MIN CANDLE INPUT ──────────────────────────────────────────────
show1245Mid = input.bool(true, "Show 12:45 30-Min Candle 50% Level")

// ── FUNCTION: First red 5-min candle midpoint ──────────────────────────────
firstRedMidFn() =>
    var float _mid   = na
    var bool  _found = false
    if ta.change(time("D")) != 0
        _mid   := na
        _found := false
    if not _found and close < open
        _mid   := (high + low) / 2
        _found := true
    _mid

// ── FUNCTION: 12:45 30-min candle midpoint ────────────────────────────────
// Captures the 12:45–13:15 candle on the 30-min TF each day
// Resets at start of new day, latches once the 12:45 candle is formed
candle1245MidFn() =>
    var float _mid   = na
    var bool  _found = false
    if ta.change(time("D")) != 0
        _mid   := na
        _found := false
    // On the 30-min TF, the 12:45 candle starts at hour==12, minute==45
    if not _found and hour == 12 and minute == 45
        _mid   := (high + low) / 2
        _found := true
    _mid

// ── REQUEST.SECURITY — ALL FETCHED FROM FIXED TIMEFRAMES ──────────────────
// 5-min: opening candle H/L
[f5High, f5Low] = request.security(syminfo.tickerid, "5",
     [ta.valuewhen(hour == 9 and minute == 15, high, 0),
      ta.valuewhen(hour == 9 and minute == 15, low,  0)])

// 5-min: first red candle midpoint
f5FirstRedMid = request.security(syminfo.tickerid, "5", firstRedMidFn())

// 30-min: 12:45 candle midpoint
// Fetched from 30-min TF so it is always the correct 12:45–13:15 candle
// regardless of what timeframe the chart is currently on
candle1245Mid = request.security(syminfo.tickerid, "30", candle1245MidFn())

// ── YESTERDAY CLOSE / TODAY OPEN FOR GAP ──────────────────────────────────
prevDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

var float todayOpen = na
if ta.change(time("D")) != 0
    todayOpen := open

gapSize    = todayOpen - prevDayClose
gap50Level = prevDayClose + gapSize * 0.5
isGapUp    = gapSize > 0
isGapDown  = gapSize < 0

// ── TIME / SESSION ─────────────────────────────────────────────────────────
newDay    = ta.change(time("D")) != 0
inSession = not na(time(timeframe.period, sessionInput))

// ── EMA FILTER ─────────────────────────────────────────────────────────────
emaValue  = ta.ema(close, emaLength)
plot(useTrendFilter ? emaValue : na, "EMA Filter", color=color.yellow, linewidth=2)

bullTrend = not useTrendFilter or close > emaValue
bearTrend = not useTrendFilter or close < emaValue

// ── STRATEGY VARIABLES ─────────────────────────────────────────────────────
var float  refHigh    = na
var float  refLow     = na
var string refName    = ""
var bool   levelReady = false
var int    bias       = 0

var float entryPrice  = na
var float stopPrice   = na
var float targetPrice = na

if newDay
    refHigh     := na
    refLow      := na
    refName     := ""
    levelReady  := false
    bias        := 0
    entryPrice  := na
    stopPrice   := na
    targetPrice := na

// ── CANDLE LEVELS ──────────────────────────────────────────────────────────
bodyHigh   = math.max(open, close)
bodyLow    = math.min(open, close)
candleHigh = useBodyLevels ? bodyHigh : high
candleLow  = useBodyLevels ? bodyLow  : low

// ── FIRST RED CANDLE CAPTURE (chart TF — for breakout strategy) ────────────
isRed = close < open

if useFirstRed and inSession and not levelReady and isRed
    refHigh    := candleHigh
    refLow     := candleLow
    refName    := "First Red"
    levelReady := true

// ── 12:45 CANDLE OVERRIDE (chart TF — for breakout strategy) ──────────────
isSpecialCandle = hour == specialHour and minute == specialMinute

if useSpecial and inSession and isSpecialCandle
    refHigh    := candleHigh
    refLow     := candleLow
    refName    := "12:45"
    levelReady := true
    bias       := 0

// ── BREAKOUT SIGNALS ───────────────────────────────────────────────────────
buyRaw  = levelReady and ta.crossover(close,  refHigh) and bullTrend
sellRaw = levelReady and ta.crossunder(close, refLow)  and bearTrend

buySignal  = buyRaw  and bias != 1
sellSignal = sellRaw and bias != -1

if buySignal
    bias        := 1
    entryPrice  := close
    stopPrice   := refLow
    targetPrice := entryPrice + ((entryPrice - stopPrice) * rr)

if sellSignal
    bias        := -1
    entryPrice  := close
    stopPrice   := refHigh
    targetPrice := entryPrice - ((stopPrice - entryPrice) * rr)

// ── PLOTS ──────────────────────────────────────────────────────────────────

// 5-min opening candle high/low — purple lines + cloud
f5HighPlot = plot(showFirst5 ? f5High : na, "First 5-Min High",
     color=color.purple, linewidth=2, style=plot.style_line)
f5LowPlot  = plot(showFirst5 ? f5Low  : na, "First 5-Min Low",
     color=color.purple, linewidth=2, style=plot.style_line)
fill(f5HighPlot, f5LowPlot, color=showFirst5 ? first5Color : na, title="First 5-Min Cloud")

// First red 5-min candle 50% — solid red line
// ABOVE = positive bias | BELOW = negative bias
plot(showFirst5 and not na(f5FirstRedMid) ? f5FirstRedMid : na,
     "1st Red 5-Min 50%", color=color.red, linewidth=2, style=plot.style_line)

// 12:45 30-min candle 50% — solid blue line
// Visible on all lower timeframes, always sourced from the 30-min candle
plot(show1245Mid and not na(candle1245Mid) ? candle1245Mid : na,
     "12:45 30-Min 50%", color=color.blue, linewidth=2, style=plot.style_line)

// Gap 50% — solid grey line
plot(showGap50 ? gap50Level : na, "50% Gap Level",
     color=color.gray, linewidth=1, style=plot.style_line)

// Reference high/low from breakout strategy
plot(refHigh, "Reference High", color=color.green, linewidth=2)
plot(refLow,  "Reference Low",  color=color.red,   linewidth=2)

// Entry / stoploss / target
plot(showTargets ? entryPrice  : na, "Entry",    color=color.white, style=plot.style_linebr)
plot(showTargets ? stopPrice   : na, "Stoploss", color=color.red,   style=plot.style_linebr)
plot(showTargets ? targetPrice : na, "Target",   color=color.lime,  style=plot.style_linebr)

// ── RIGHT EDGE LABELS ──────────────────────────────────────────────────────
if barstate.islast
    if showFirst5
        if not na(f5High)
            label.new(bar_index, f5High,
                 "5M High: " + str.tostring(f5High, "#.##"),
                 style=label.style_label_left, color=color.purple,
                 textcolor=color.white, size=size.small)
        if not na(f5Low)
            label.new(bar_index, f5Low,
                 "5M Low: " + str.tostring(f5Low, "#.##"),
                 style=label.style_label_left, color=color.purple,
                 textcolor=color.white, size=size.small)
        if not na(f5FirstRedMid)
            biasText       = close > f5FirstRedMid ? "1st Red 50%: " + str.tostring(f5FirstRedMid, "#.##") + "  ▲ Positive" :
                                                     "1st Red 50%: " + str.tostring(f5FirstRedMid, "#.##") + "  ▼ Negative"
            biasLabelColor = close > f5FirstRedMid ? color.green : color.red
            label.new(bar_index, f5FirstRedMid, biasText,
                 style=label.style_label_left, color=biasLabelColor,
                 textcolor=color.white, size=size.small)
    if show1245Mid and not na(candle1245Mid)
        midBiasText  = close > candle1245Mid ? "12:45 30M 50%: " + str.tostring(candle1245Mid, "#.##") + "  ▲ Positive" :
                                               "12:45 30M 50%: " + str.tostring(candle1245Mid, "#.##") + "  ▼ Negative"
        midBiasColor = close > candle1245Mid ? color.green : color.red
        label.new(bar_index, candle1245Mid, midBiasText,
             style=label.style_label_left, color=midBiasColor,
             textcolor=color.white, size=size.small)
    if showGap50 and not na(gap50Level)
        gapLabel = isGapUp   ? "Gap Up 50%: "   + str.tostring(gap50Level, "#.##") + "  (+" + str.tostring(gapSize, "#.##") + ")" :
                   isGapDown ? "Gap Down 50%: " + str.tostring(gap50Level, "#.##") + "  ("  + str.tostring(gapSize, "#.##") + ")" :
                               "Flat Open: "    + str.tostring(gap50Level, "#.##")
        label.new(bar_index, gap50Level, gapLabel,
             style=label.style_label_left, color=color.gray,
             textcolor=color.white, size=size.small)

// ── BUY / SELL SIGNAL SHAPES ───────────────────────────────────────────────
plotshape(buySignal,  title="BUY",  text="BUY",  style=shape.labelup,
     location=location.belowbar, color=color.green, textcolor=color.white)
plotshape(sellSignal, title="SELL", text="SELL", style=shape.labeldown,
     location=location.abovebar, color=color.red,   textcolor=color.white)

// ── CANDLE HIGHLIGHT ───────────────────────────────────────────────────────
barcolor(buySignal ? color.lime : sellSignal ? color.red : na)

// ── DASHBOARD ──────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 13, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0,  "Reference",      bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0,  refName,          bgcolor=color.black, text_color=color.yellow)

    table.cell(dash, 0, 1,  "Ref High",       bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 1,  str.tostring(refHigh, "#.##"), bgcolor=color.black, text_color=color.green)

    table.cell(dash, 0, 2,  "Ref Low",        bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 2,  str.tostring(refLow,  "#.##"), bgcolor=color.black, text_color=color.red)

    table.cell(dash, 0, 3,  "Bias",           bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 3,  bias == 1 ? "BUY" : bias == -1 ? "SELL" : "WAIT",
         bgcolor=color.black, text_color=bias == 1 ? color.green : bias == -1 ? color.red : color.orange)

    table.cell(dash, 0, 4,  "Trend Filter",   bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 4,  bullTrend ? "Bullish" : bearTrend ? "Bearish" : "Neutral",
         bgcolor=color.black, text_color=bullTrend ? color.green : color.red)

    table.cell(dash, 0, 5,  "5M High",        bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 5,  str.tostring(f5High, "#.##"), bgcolor=color.black, text_color=color.purple)

    table.cell(dash, 0, 6,  "5M Low",         bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 6,  str.tostring(f5Low, "#.##"),  bgcolor=color.black, text_color=color.purple)

    table.cell(dash, 0, 7,  "1st Red 50%",    bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 7,  str.tostring(f5FirstRedMid, "#.##"),
         bgcolor=color.black, text_color=color.red)

    redBiasText  = not na(f5FirstRedMid) ? (close > f5FirstRedMid ? "▲ Positive" : "▼ Negative") : "Waiting"
    redBiasColor = not na(f5FirstRedMid) ? (close > f5FirstRedMid ? color.green  : color.red)     : color.gray
    table.cell(dash, 0, 8,  "Red Bar Bias",   bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 8,  redBiasText,      bgcolor=color.black, text_color=redBiasColor)

    table.cell(dash, 0, 9,  "12:45 30M 50%",  bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 9,  not na(candle1245Mid) ? str.tostring(candle1245Mid, "#.##") : "Pending 12:45",
         bgcolor=color.black, text_color=color.blue)

    mid1245BiasText  = not na(candle1245Mid) ? (close > candle1245Mid ? "▲ Positive" : "▼ Negative") : "Pending"
    mid1245BiasColor = not na(candle1245Mid) ? (close > candle1245Mid ? color.green  : color.red)     : color.gray
    table.cell(dash, 0, 10, "12:45 Bias",     bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 10, mid1245BiasText,  bgcolor=color.black, text_color=mid1245BiasColor)

    table.cell(dash, 0, 11, "Gap",            bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 11, isGapUp ? "▲ Gap Up" : isGapDown ? "▼ Gap Down" : "— Flat",
         bgcolor=color.black, text_color=isGapUp ? color.lime : isGapDown ? color.orange : color.gray)

    table.cell(dash, 0, 12, "Gap 50%",        bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 12, str.tostring(gap50Level, "#.##"),
         bgcolor=color.black, text_color=isGapUp ? color.lime : isGapDown ? color.orange : color.gray)

// ── ALERTS ─────────────────────────────────────────────────────────────────
alertcondition(buySignal,  "BUY Signal",  "BUY: Price crossed above reference candle high")
alertcondition(sellSignal, "SELL Signal", "SELL: Price crossed below reference candle low")

alertcondition(showFirst5 and ta.crossover(close,  f5High), "5M High Breakout", "Price broke ABOVE First 5-Min High")
alertcondition(showFirst5 and ta.crossunder(close, f5Low),  "5M Low Breakdown",  "Price broke BELOW First 5-Min Low")

alertcondition(showFirst5 and not na(f5FirstRedMid) and ta.crossover(close,  f5FirstRedMid), "1st Red 50% Cross Up",   "Price crossed ABOVE 1st Red 5-Min 50% — POSITIVE Bias")
alertcondition(showFirst5 and not na(f5FirstRedMid) and ta.crossunder(close, f5FirstRedMid), "1st Red 50% Cross Down",  "Price crossed BELOW 1st Red 5-Min 50% — NEGATIVE Bias")

alertcondition(show1245Mid and not na(candle1245Mid) and ta.crossover(close,  candle1245Mid), "12:45 30M 50% Cross Up",   "Price crossed ABOVE 12:45 30-Min 50% — POSITIVE Bias")
alertcondition(show1245Mid and not na(candle1245Mid) and ta.crossunder(close, candle1245Mid), "12:45 30M 50% Cross Down",  "Price crossed BELOW 12:45 30-Min 50% — NEGATIVE Bias")

alertcondition(showGap50 and isGapUp   and ta.crossunder(close, gap50Level), "Gap Up 50% Fill",   "Price filled 50% of Gap Up — Watch for support")
alertcondition(showGap50 and isGapDown and ta.crossover(close,  gap50Level), "Gap Down 50% Fill", "Price filled 50% of Gap Down — Watch for resistance")
````
