# Zero-Lag MACD Divergence Pro 

- url: https://www.tradingview.com/script/5pZHJFCK-Zero-Lag-MACD-Divergence-Pro/
- type: indicator
- pine_id: PUB;44f3fd8651fb4144b850707f22403216
- version: 1.0

## Description

Zero-Lag MACD Divergence Pro is a MACD-family oscillator that reduces the indicator's inherent lag using zero-lag exponential averaging, detects regular divergences directly inside the MACD pane, and optionally gates its buy/sell markers so they only appear when a divergence and a crossover confirm each other. It is designed for intraday timeframes but works on any chart.
What makes it original

This is not a standard MACD with cosmetic changes. Three elements work as one system: (1) all three components — fast line, slow line, and signal line — are rebuilt on zero-lag EMAs rather than standard EMAs, (2) divergence detection runs on the zero-lag MACD line itself and draws its lines and labels inside the oscillator pane, with an optional mirrored dashed line on the price chart, and (3) a combo-gating mode suppresses crossover markers unless a divergence was confirmed within a recent, user-defined window, which filters the many insignificant crossovers a MACD produces in ranging markets.

[b]How it works[/b]
[b]Zero-Lag Core:[/b] Each component uses the zero-lag EMA construction (2 × EMA − EMA of EMA), a public-domain technique attributed to John Ehlers' error-correction work. This roughly halves the effective lag of each average, so crossovers occur earlier than on a classic MACD. A faded classic MACD line can be displayed for side-by-side comparison and switched off in the settings.

[b]Divergence Detection:[/b] Confirmed pivot highs/lows on the zero-lag MACD line are compared with price highs/lows at the same bars. A regular bullish divergence (price lower low, MACD higher low) or regular bearish divergence (price higher high, MACD lower high) draws a connecting line between the two MACD pivots with a label in the pane. Pivots confirm only after the lookback period elapses, so divergence lines appear with a delay by design and do not repaint.

[b]Combo Signals:[/b] In the default mode, a buy/sell marker prints on the price chart only when a zero-lag crossover occurs while a same-direction divergence is still valid (within a user-defined number of bars). Turning combo mode off prints markers on every confirmed crossover instead. Signals respect a cooldown and a daily maximum.

[b]Four-Color Histogram:[/b] The histogram distinguishes rising and fading momentum on both sides of the zero line.

[b]Dashboard:[/b] A dark, movable panel (styled to stay readable on light-theme charts) summarizes MACD state, histogram direction, active divergence, zero-line position, and the day's signal count.

[b]How to use it[/b]
Add the indicator to a lower-timeframe chart (5–15 min for intraday use). Watch for a divergence label in the pane, then wait for the crossover marker that confirms it — the combo mode automates exactly this sequence. The zero-line row on the dashboard helps grade signals: bullish setups above the zero line and bearish setups below it occur in the direction of the broader momentum. All lengths, the divergence window, signal limits, colors, and dashboard placement are adjustable.

[b]Limitations[/b]
Divergence lines appear only after pivots confirm (default 5 bars), so they are visible later than the pivot itself; this is the unavoidable cost of non-repainting detection. Reduced lag also means the zero-lag lines are more sensitive than a classic MACD and can produce more crossovers in choppy conditions — the combo mode exists to filter these. This tool describes momentum conditions; it does not predict future price movement, and past behavior of any signal does not guarantee future results. Always combine with your own analysis and risk management.

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════╗
// ║  ⚡ ZERO-LAG MACD DIVERGENCE PRO — Radhe Radhe 🙏 @darshakssc ║
// ║  ZLEMA MACD • 4-color histogram • Divergence in MACD pane    ║
// ╚══════════════════════════════════════════════════════════════╝
indicator("Zero-Lag MACD Divergence Pro [Radhe Radhe @darshakssc]", overlay = false, max_labels_count = 200, max_lines_count = 200)

// ─────────────── INPUTS ───────────────
grpMACD = "⚡ Zero-Lag MACD"
fastLen   = input.int(12, "Fast Length", minval = 2, group = grpMACD)
slowLen   = input.int(26, "Slow Length", minval = 5, group = grpMACD)
sigLen    = input.int(9,  "Signal Length", minval = 2, group = grpMACD)
srcIn     = input.source(close, "Source", group = grpMACD)
showOld   = input.bool(true, "Show Classic MACD (comparison, faded)", group = grpMACD)

grpDiv = "🔍 Divergence (in MACD pane)"
showDiv   = input.bool(true, "Detect Regular Divergence", group = grpDiv)
divLb     = input.int(5, "Pivot Lookback (confirmed)", minval = 2, maxval = 15, tooltip = "Pivot confirm hone mein itne bars lagte hain — no repaint, thoda delay natural hai.", group = grpDiv)
divRange  = input.int(60, "Max Bars Between Pivots", minval = 20, maxval = 200, group = grpDiv)
showPriceLine = input.bool(true, "Draw Price Divergence Line (on chart)", group = grpDiv)

grpSig = "🎯 Combo Signals (Divergence + Cross)"
comboOnly  = input.bool(true, "BUY/SELL only when Divergence + Cross combo", tooltip = "OFF karoge toh har confirmed crossover par signal aayega.", group = grpSig)
divValidBars = input.int(15, "Divergence Valid for (bars)", minval = 5, maxval = 50, group = grpSig)
maxSigDay  = input.int(5, "Max Signals per Day", minval = 1, maxval = 10, group = grpSig)
cooldownBars = input.int(10, "Cooldown Bars", minval = 3, group = grpSig)

grpDash = "🖥️ Dashboard (Dark — for Light Theme)"
showDash  = input.bool(true, "Show Dashboard", group = grpDash)
dashPosIn = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpDash)
dashSizeIn= input.string("Normal", "Size", options = ["Small", "Normal", "Large"], group = grpDash)

grpCol = "🎨 Colors (Light-Theme Optimized)"
colBull  = input.color(#089981, "Bullish", group = grpCol)
colBear  = input.color(#f23645, "Bearish", group = grpCol)
colZL    = input.color(#2962ff, "ZL-MACD Line", group = grpCol)
colSig   = input.color(#ff9800, "Signal Line", group = grpCol)

// ─────────────── ZERO-LAG MACD (global scope) ───────────────
// ZLEMA = 2×EMA − EMA(EMA)  → lag ~half of standard EMA
emaF1 = ta.ema(srcIn, fastLen)
emaF2 = ta.ema(emaF1, fastLen)
zlFast = 2 * emaF1 - emaF2
emaS1 = ta.ema(srcIn, slowLen)
emaS2 = ta.ema(emaS1, slowLen)
zlSlow = 2 * emaS1 - emaS2

zlMacd = zlFast - zlSlow
emaSg1 = ta.ema(zlMacd, sigLen)
emaSg2 = ta.ema(emaSg1, sigLen)
zlSignal = 2 * emaSg1 - emaSg2
hist = zlMacd - zlSignal

// Classic MACD for comparison
[cMacd, cSig, cHist] = ta.macd(srcIn, fastLen, slowLen, sigLen)

crossUp   = ta.crossover(zlMacd, zlSignal)
crossDown = ta.crossunder(zlMacd, zlSignal)

// Divergence pivots on ZL-MACD (confirmed — no repaint)
pMacdLow  = ta.pivotlow(zlMacd, divLb, divLb)
pMacdHigh = ta.pivothigh(zlMacd, divLb, divLb)

// ─────────────── PLOTS ───────────────
histCol = hist >= 0 ? (hist > hist[1] ? colBull : color.new(colBull, 55)) : (hist < hist[1] ? colBear : color.new(colBear, 55))
plot(hist, "Histogram", style = plot.style_columns, color = histCol)
plot(showOld ? cMacd : na, "Classic MACD (laggy)", color = color.new(#9aa4b2, 35), linewidth = 1, style = plot.style_line)
plot(zlMacd, "ZL-MACD", color = colZL, linewidth = 3)
plot(zlSignal, "Signal", color = colSig, linewidth = 2)
hline(0, "Zero Line", color = #b0b8c4, linestyle = hline.style_dashed)

// Crossover markers (circles at cross point)
plotshape(crossUp and barstate.isconfirmed ? (zlMacd + zlSignal) / 2 : na, "Bull Cross", style = shape.circle, location = location.absolute, color = colBull, size = size.tiny)
plotshape(crossDown and barstate.isconfirmed ? (zlMacd + zlSignal) / 2 : na, "Bear Cross", style = shape.circle, location = location.absolute, color = colBear, size = size.tiny)

// ─────────────── DIVERGENCE ENGINE ───────────────
var float lastLowMacd  = na
var float lastLowPrice = na
var int   lastLowBar   = na
var float lastHighMacd  = na
var float lastHighPrice = na
var int   lastHighBar   = na

var int bullDivBar = -9999
var int bearDivBar = -9999

bullDivNow = false
bearDivNow = false

if showDiv and not na(pMacdLow) and barstate.isconfirmed
    curMacd  = zlMacd[divLb]
    curPrice = low[divLb]
    curBar   = bar_index - divLb
    if not na(lastLowMacd) and (curBar - lastLowBar) <= divRange
        // Regular bullish: price lower low + MACD higher low
        if curPrice < lastLowPrice and curMacd > lastLowMacd
            bullDivNow := true
            bullDivBar := bar_index
            line.new(lastLowBar, lastLowMacd, curBar, curMacd, color = colBull, width = 3)
            label.new(curBar, curMacd, "BULLISH DIVERGENCE", style = label.style_label_up, color = colBull, textcolor = color.white, size = size.small)
            if showPriceLine
                line.new(lastLowBar, lastLowPrice, curBar, curPrice, color = colBull, width = 2, style = line.style_dashed, force_overlay = true)
    lastLowMacd  := curMacd
    lastLowPrice := curPrice
    lastLowBar   := curBar

if showDiv and not na(pMacdHigh) and barstate.isconfirmed
    curMacd  = zlMacd[divLb]
    curPrice = high[divLb]
    curBar   = bar_index - divLb
    if not na(lastHighMacd) and (curBar - lastHighBar) <= divRange
        // Regular bearish: price higher high + MACD lower high
        if curPrice > lastHighPrice and curMacd < lastHighMacd
            bearDivNow := true
            bearDivBar := bar_index
            line.new(lastHighBar, lastHighMacd, curBar, curMacd, color = colBear, width = 3)
            label.new(curBar, curMacd, "BEARISH DIVERGENCE", style = label.style_label_down, color = colBear, textcolor = color.white, size = size.small)
            if showPriceLine
                line.new(lastHighBar, lastHighPrice, curBar, curPrice, color = colBear, width = 2, style = line.style_dashed, force_overlay = true)
    lastHighMacd  := curMacd
    lastHighPrice := curPrice
    lastHighBar   := curBar

bullDivActive = (bar_index - bullDivBar) <= divValidBars
bearDivActive = (bar_index - bearDivBar) <= divValidBars

// ─────────────── COMBO SIGNALS ───────────────
isNewDay = ta.change(time("D")) != 0
var int sigsToday = 0
var int lastSigBar = -9999
if isNewDay
    sigsToday := 0

canSignal = (bar_index - lastSigBar) >= cooldownBars and sigsToday < maxSigDay and barstate.isconfirmed

buySig  = crossUp and canSignal and (not comboOnly or bullDivActive)
sellSig = crossDown and canSignal and (not comboOnly or bearDivActive)

if buySig
    sigsToday += 1
    lastSigBar := bar_index
    label.new(bar_index, low, comboOnly ? "BUY • DIV+CROSS" : "BUY ▲", style = label.style_label_up, color = colBull, textcolor = color.white, size = size.normal, force_overlay = true)

if sellSig
    sigsToday += 1
    lastSigBar := bar_index
    label.new(bar_index, high, comboOnly ? "SELL • DIV+CROSS" : "SELL ▼", style = label.style_label_down, color = colBear, textcolor = color.white, size = size.normal, force_overlay = true)

// ─────────────── DARK MOVABLE DASHBOARD ───────────────
dashPos = switch dashPosIn
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Middle Right"  => position.middle_right
    "Middle Left"   => position.middle_left
    "Bottom Right"  => position.bottom_right
    => position.bottom_left
dashTxtSize = switch dashSizeIn
    "Small" => size.small
    "Large" => size.large
    => size.normal

cBg = color.new(#131722, 4)
cBrd = #2a3542
cKey = #8a97a8
cVal = #e8eaed
cGold = #f7b731
cBlue = #38bdf8

var table dash = table.new(dashPos, 2, 8, bgcolor = cBg, border_color = cBrd, border_width = 1, frame_color = cBrd, frame_width = 2)

if showDash and barstate.islast
    macdState = zlMacd > zlSignal ? "BULL CROSS ▲" : "BEAR CROSS ▼"
    histState = hist >= 0 ? (hist > hist[1] ? "RISING +" : "FADING +") : (hist < hist[1] ? "FALLING −" : "FADING −")
    divState  = bullDivActive ? "BULLISH ACTIVE" : bearDivActive ? "BEARISH ACTIVE" : "NONE"
    zeroState = zlMacd > 0 ? "ABOVE" : "BELOW"

    table.cell(dash, 0, 0, "⚡ ZL-MACD MATRIX", text_color = cGold, text_size = dashTxtSize, bgcolor = #0d1117)
    table.cell(dash, 1, 0, "Radhe Radhe 🙏", text_color = cGold, text_size = size.small, bgcolor = #0d1117)
    table.cell(dash, 0, 1, "MACD State", text_color = cKey, text_size = dashTxtSize)
    table.cell(dash, 1, 1, macdState, text_color = zlMacd > zlSignal ? colBull : colBear, text_size = dashTxtSize)
    table.cell(dash, 0, 2, "Histogram", text_color = cKey, text_size = dashTxtSize)
    table.cell(dash, 1, 2, histState, text_color = hist >= 0 ? colBull : colBear, text_size = dashTxtSize)
    table.cell(dash, 0, 3, "Divergence", text_color = cKey, text_size = dashTxtSize)
    table.cell(dash, 1, 3, divState, text_color = bullDivActive ? colBull : bearDivActive ? colBear : cGold, text_size = dashTxtSize)
    table.cell(dash, 0, 4, "Zero-Line", text_color = cKey, text_size = dashTxtSize)
    table.cell(dash, 1, 4, zeroState, text_color = zlMacd > 0 ? colBull : colBear, text_size = dashTxtSize)
    table.cell(dash, 0, 5, "Lag Reduction", text_color = cKey, text_size = dashTxtSize)
    table.cell(dash, 1, 5, "ZLEMA ON", text_color = cBlue, text_size = dashTxtSize)
    table.cell(dash, 0, 6, "Signals Today", text_color = cKey, text_size = dashTxtSize)
    table.cell(dash, 1, 6, str.tostring(sigsToday) + " / " + str.tostring(maxSigDay), text_color = cVal, text_size = dashTxtSize)
    table.cell(dash, 0, 7, "@darshakssc", text_color = #5c6b7f, text_size = size.small, bgcolor = #0d1117)
    table.cell(dash, 1, 7, timeframe.period + "m • " + syminfo.ticker, text_color = #5c6b7f, text_size = size.small, bgcolor = #0d1117)

// ─────────────── ALERTS ───────────────
alertcondition(buySig, "🟢 BUY Signal (Div+Cross)", "ZL-MACD Divergence Pro: BUY on {{ticker}} @ {{close}}")
alertcondition(sellSig, "🔴 SELL Signal (Div+Cross)", "ZL-MACD Divergence Pro: SELL on {{ticker}} @ {{close}}")
alertcondition(crossUp, "ZL-MACD Bull Cross", "ZL-MACD crossed above Signal on {{ticker}}")
alertcondition(crossDown, "ZL-MACD Bear Cross", "ZL-MACD crossed below Signal on {{ticker}}")
alertcondition(bullDivNow, "Bullish Divergence", "Bullish divergence confirmed on {{ticker}}")
alertcondition(bearDivNow, "Bearish Divergence", "Bearish divergence confirmed on {{ticker}}")
if buySig
    alert("⚡ ZL-MACD BUY • " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " • Radhe Radhe 🙏", alert.freq_once_per_bar_close)
if sellSig
    alert("⚡ ZL-MACD SELL • " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " • Radhe Radhe 🙏", alert.freq_once_per_bar_close)
````
