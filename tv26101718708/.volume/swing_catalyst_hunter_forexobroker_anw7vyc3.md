# Swing Catalyst Hunter [forexobroker]

- url: https://www.tradingview.com/script/AnW7vyC3-Swing-Catalyst-Hunter-forexobroker/
- type: indicator
- pine_id: PUB;0bae9510eff84bdca025da670b2ff1e7
- version: 1.0

## Description

Swing Catalyst Hunter isolates the exact bar that triggered each swing reversal. After every confirmed pivot high or low, it scans back through the preceding bars, scoring each for four catalyst characteristics -- abnormal volume, wide range, decisive close position, and counter-trend direction -- and marks the single bar with the highest catalyst strength. When the catalyst is recent and a confirming bar prints in the matching direction, BUY or SELL signals fire.

This indicator is designed for traders who study price action and want to pinpoint not just that a reversal happened, but exactly which bar caused it. The catalyst bar is drawn on the chart as a highlighted box with an arrow pointing to the resulting pivot, giving a clean visual record of cause-and-effect for postmortem analysis.

🔶 CONCEPTS

Every swing reversal has a cause -- a specific bar where enough buying or selling pressure printed to change the market's direction. On most charts this bar is invisible in hindsight: you see the pivot that formed, but not the bar that drove it. By scoring each bar on four structural catalyst factors and scanning a small window back from each confirmed pivot, the indicator identifies the single bar most likely to have been the trigger. Once a strong catalyst is tagged, a confirming bar in the matching direction provides a precise entry.

🔶 HOW IT WORKS

- Scores every bar 0-100 for catalyst strength using four factors: volume ratio, range ratio, close position, and counter-trend close
- On every confirmed pivot, scans back Catalyst Scan Bars and selects the bar with the highest score
- Requires the chosen bar's score to meet the catalyst strength threshold
- Draws a neon box around the catalyst bar and an arrow line from it to the pivot
- Fires BUY when the last catalyst was at a swing low and current bar confirms direction above the trend EMA with volume
- Fires SELL in the mirror case

🔶 HOW TO USE

1. Add the indicator -- every time a pivot forms, the causing catalyst bar is highlighted with a box and an arrow to the pivot
2. Watch the dashboard (top-right) for current bar catalyst strength, last detected catalyst with grade (MAJOR / STRONG / MODERATE / WEAK), direction, and bars-ago
3. Green BUY triangle with "CATALYST ↑" label fires when a recent bullish catalyst is confirmed by a bullish follow-through; pink SELL triangle fires in the mirror case
4. Use MAJOR-grade (85+) catalysts as your priority entries; STRONG (70+) as secondary
5. Increase Catalyst Scan Bars on slower timeframes if pivots form many bars after the triggering action

🔶 FEATURES

- Non-repainting signals (barstate.isconfirmed)
- Works on all timeframes and instruments
- 9 alert conditions with JSON webhook support
- Live per-bar catalyst scoring across four factors
- Catalyst box and arrow drawn from trigger bar to resulting pivot for each detection

🔶 SETTINGS GUIDE

- Pivot Length -- Lookback for swing pivot detection
- ATR Length -- ATR period for range ratio measurement
- Volume SMA Length -- Baseline for volume ratio measurement
- Catalyst Scan Bars -- Bars to scan back from each confirmed pivot
- Prior Trend Length -- EMA length used for counter-trend classification
- Volume Catalyst Multiplier -- Volume must exceed this multiple of SMA for full volume score
- Range Catalyst Multiplier -- Bar range must exceed this multiple of ATR for full range score
- Catalyst Strength Threshold -- Minimum score for a bar to qualify as a catalyst
- Signal Cooldown Bars -- Minimum bars between consecutive signals

🔶 ALERTS

- SCH Buy Catalyst -- Bullish catalyst signal fired
- SCH Sell Catalyst -- Bearish catalyst signal fired
- SCH Any Signal -- Any directional catalyst signal
- SCH Major Catalyst Bar -- Current bar scores 85+ catalyst strength
- SCH New Pivot High -- New pivot high confirmed
- SCH New Pivot Low -- New pivot low confirmed
- SCH Volume Catalyst -- Volume catalyst condition met on the bar
- SCH Counter-Trend Bar -- Counter-trend bar printed on the bar
- SCH Webhook JSON -- Generic webhook payload for external automation

🔶 LIMITATIONS & DISCLAIMER

- This is a technical analysis tool, not financial advice. Always use proper risk management.
- Past catalyst-to-pivot relationships do not guarantee future price movements.
- Pivot detection lags by the pivot length; catalysts can only be identified after the pivot is confirmed.
- The catalyst score is a heuristic over four structural factors, not a statistically calibrated probability of a successful follow-through.

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Swing Catalyst Hunter [forexobroker]", shorttitle="SCH [fob]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_cat    = "Catalyst Settings"
string g_signal = "Signal Settings"
string g_visual = "Visual Settings"

int    i_pivotLen    = input.int(5, "Pivot Length", minval=2, maxval=15, group=g_cat, tooltip="Lookback for swing pivot detection")
int    i_atrLen      = input.int(14, "ATR Length", minval=5, maxval=50, group=g_cat)
int    i_volLen      = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=g_cat)
int    i_scanBars    = input.int(3, "Catalyst Scan Bars", minval=1, maxval=10, group=g_cat, tooltip="Bars to scan back from pivot for catalyst")
int    i_trendLen    = input.int(20, "Prior Trend Length", minval=5, maxval=100, group=g_cat, tooltip="Lookback for prior trend direction")
float  i_volCatMult  = input.float(1.8, "Volume Catalyst Multiplier", minval=1.2, maxval=4.0, step=0.1, group=g_cat)
float  i_rangeMult   = input.float(1.3, "Range Catalyst Multiplier", minval=1.0, maxval=3.0, step=0.1, group=g_cat)
int    i_catThresh   = input.int(65, "Catalyst Strength Threshold", minval=50, maxval=95, group=g_signal, tooltip="Minimum 0-100 catalyst strength")
int    i_cooldown    = input.int(10, "Signal Cooldown Bars", minval=3, maxval=50, group=g_signal)
bool   i_showTable   = input.bool(true, "Show Catalyst Dashboard", group=g_visual)
bool   i_showBox     = input.bool(true, "Show Catalyst Box", group=g_visual)
bool   i_showArrow   = input.bool(true, "Show Catalyst→Pivot Arrow", group=g_visual)
bool   i_showGlow    = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
color  i_buyColor    = input.color(#39ff14, "Buy Color", group=g_visual)
color  i_sellColor   = input.color(#ff2d78, "Sell Color", group=g_visual)

// ─── COLORS ────────────────────────────────────────────────────────────────────
color c_cyan   = #00d4ff
color c_pink   = #ff2d78
color c_green  = #39ff14
color c_purple = #a855f7
color c_gold   = #ffaa00

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
float atrVal = ta.atr(i_atrLen)
float volSma = ta.sma(volume, i_volLen)
float trendEma = ta.ema(close, i_trendLen)
float ph = ta.pivothigh(high, i_pivotLen, i_pivotLen)
float pl = ta.pivotlow(low,   i_pivotLen, i_pivotLen)

// Per-bar catalyst strength (0-100)
float bar_range = high - low
float volRat = volSma > 0 ? volume / volSma : 0.0
float rngRat = atrVal > 0 ? bar_range / atrVal : 0.0
float clsPos = bar_range > 0 ? (close - low) / bar_range : 0.5
bool  trendBull = close > trendEma
bool  trendBear = close < trendEma
bool  isBullBar = close > open
bool  isBearBar = close < open
bool  counterTrend = (trendBull and isBearBar) or (trendBear and isBullBar)

float s_vol    = math.min(volRat / i_volCatMult * 30.0, 30.0)
float s_range  = math.min(rngRat / i_rangeMult * 30.0, 30.0)
float s_close  = isBullBar ? clsPos * 20.0 : (1.0 - clsPos) * 20.0
float s_count  = counterTrend ? 20.0 : 0.0
float catStrength = s_vol + s_range + s_close + s_count

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
// On new pivot, scan back i_scanBars bars for max catalyst strength
var int   lastCatBar = na
var float lastCatStr = na
var bool  lastCatWasLow = false
var float lastCatHigh = na
var float lastCatLow  = na
var int   lastSignalBar = 0
var int   pivotBar    = na
var box   catBox      = na
var line  catArrow    = na

bool newPivotHigh = not na(ph)
bool newPivotLow  = not na(pl)

// Find catalyst when pivot just confirmed
if newPivotHigh or newPivotLow
    float maxStr = -1.0
    int   maxBar = na
    float maxHi = na
    float maxLo = na
    for i = i_pivotLen to i_pivotLen + i_scanBars
        float s = catStrength[i]
        if s > maxStr
            maxStr := s
            maxBar := bar_index - i
            maxHi := high[i]
            maxLo := low[i]
    if maxStr >= i_catThresh
        lastCatBar := maxBar
        lastCatStr := maxStr
        lastCatWasLow := newPivotLow
        lastCatHigh := maxHi
        lastCatLow := maxLo
        pivotBar := bar_index - i_pivotLen
        // Draw catalyst box
        if i_showBox
            if not na(catBox)
                box.delete(catBox)
            color boxCol = color.new(newPivotLow ? c_green : c_pink, 70)
            color boxBorderCol = color.new(newPivotLow ? c_green : c_pink, 20)
            catBox := box.new(maxBar, maxHi, maxBar, maxLo, bgcolor=boxCol, border_color=boxBorderCol, border_width=2, extend=extend.none)
        // Draw arrow from catalyst to pivot
        if i_showArrow
            if not na(catArrow)
                line.delete(catArrow)
            float catMid = (maxHi + maxLo) / 2.0
            float pivPx = newPivotLow ? pl : ph
            catArrow := line.new(maxBar, catMid, bar_index - i_pivotLen, pivPx, color=color.new(c_gold, 20), width=1, style=line.style_arrow_right)

// Signal fires on current bar if catalyst recently identified + confirmation direction
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool catRecent  = not na(lastCatBar) and (bar_index - lastCatBar) <= i_scanBars + i_pivotLen + 2
bool volConfirm = volume > volSma

bool rawBuy  = catRecent and lastCatWasLow and close > open and close > trendEma and volConfirm and cooldownOk and confirmed
bool rawSell = catRecent and not lastCatWasLow and close < open and close < trendEma and volConfirm and cooldownOk and confirmed

bool buySignal  = rawBuy and not rawSell
bool sellSignal = rawSell and not rawBuy

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── STATS ─────────────────────────────────────────────────────────────────────
var int catalystsFound = 0
var int buySignalsFired = 0
var int sellSignalsFired = 0
if newPivotHigh or newPivotLow
    if not na(lastCatBar)
        catalystsFound := catalystsFound + 1
if buySignal
    buySignalsFired := buySignalsFired + 1
if sellSignal
    sellSignalsFired := sellSignalsFired + 1

// ─── VISUAL: Regime EMA with 3-Layer Glow ─────────────────────────────────────
plot(trendEma, "EMA Glow 1", color=color.new(c_purple, 70), linewidth=5)
plot(trendEma, "EMA Glow 2", color=color.new(c_purple, 40), linewidth=3)
plot(trendEma, "EMA Core",   color=color.new(c_purple, 0),  linewidth=1)

// ─── VISUAL: 3-Layer Glow Signal Arrows ───────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CATALYST ↑",  textcolor=color.white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CATALYST ↓", textcolor=color.white)

// ─── VISUAL: Signal Context Label ──────────────────────────────────────────────
if buySignal
    label.new(bar_index, low - atrVal * 1.5, "CATALYST ↑\nStr: " + str.tostring(math.round(lastCatStr)) + "/100\n" + str.tostring(bar_index - lastCatBar) + " bars ago", style=label.style_label_up, color=color.new(i_buyColor, 15), textcolor=color.white, size=size.small)
if sellSignal
    label.new(bar_index, high + atrVal * 1.5, "CATALYST ↓\nStr: " + str.tostring(math.round(lastCatStr)) + "/100\n" + str.tostring(bar_index - lastCatBar) + " bars ago", style=label.style_label_down, color=color.new(i_sellColor, 15), textcolor=color.white, size=size.small)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(buySignal ? color.new(i_buyColor, 93) : sellSignal ? color.new(i_sellColor, 93) : na)

// ─── VISUAL: Catalyst Dashboard ────────────────────────────────────────────────
string catGrade = na(lastCatStr) ? "—" : lastCatStr >= 85 ? "MAJOR" : lastCatStr >= 70 ? "STRONG" : lastCatStr >= 55 ? "MODERATE" : "WEAK"
color  catCol = na(lastCatStr) ? color.gray : lastCatStr >= 85 ? c_gold : lastCatStr >= 70 ? c_green : lastCatStr >= 55 ? c_cyan : color.gray

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Swing Catalyst Hunter", text_color=c_cyan, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", text_color=color.white)
    table.cell(dash, 0, 1, "Current Bar Strength", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(math.round(catStrength)) + "/100", text_color=catStrength >= i_catThresh ? c_green : color.white, text_size=size.small)
    table.cell(dash, 0, 2, "Last Catalyst", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(lastCatStr) ? "—" : str.tostring(math.round(lastCatStr)) + "/100", text_color=catCol, text_size=size.small)
    table.cell(dash, 0, 3, "Grade", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, catGrade, text_color=catCol, text_size=size.small)
    table.cell(dash, 0, 4, "Catalyst Direction", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, na(lastCatBar) ? "—" : lastCatWasLow ? "↑ BULL" : "↓ BEAR", text_color=na(lastCatBar) ? color.gray : lastCatWasLow ? c_green : c_pink, text_size=size.small)
    table.cell(dash, 0, 5, "Bars Since Catalyst", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, na(lastCatBar) ? "—" : str.tostring(bar_index - lastCatBar), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 6, "Vol Ratio", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(math.round(volRat, 2)) + "x", text_color=volRat >= i_volCatMult ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 7, "Range Ratio", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(math.round(rngRat, 2)) + "x", text_color=rngRat >= i_rangeMult ? c_gold : color.white, text_size=size.small)
    table.cell(dash, 0, 8, "Catalysts Found", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(catalystsFound), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 9, "Signals (B / S)", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(buySignalsFired) + " / " + str.tostring(sellSignalsFired), text_color=color.white, text_size=size.small)

// ─── ALERTS (2x alert() with JSON) ─────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"SCH","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"catStr":' + str.tostring(math.round(lastCatStr)) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"SCH","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"catStr":' + str.tostring(math.round(lastCatStr)) + '}', alert.freq_once_per_bar_close)

// ─── ALERTCONDITIONS (9x global scope) ─────────────────────────────────────────
alertcondition(buySignal,                 "SCH Buy Catalyst",      "Swing Catalyst BUY on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                "SCH Sell Catalyst",     "Swing Catalyst SELL on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,   "SCH Any Signal",        "Any catalyst signal on {{ticker}} {{interval}} at {{close}}")
alertcondition(catStrength >= 85,         "SCH Major Catalyst Bar","Current bar catalyst strength 85+ on {{ticker}} {{interval}}")
alertcondition(newPivotHigh,              "SCH New Pivot High",    "New swing high confirmed on {{ticker}} {{interval}}")
alertcondition(newPivotLow,               "SCH New Pivot Low",     "New swing low confirmed on {{ticker}} {{interval}}")
alertcondition(volRat >= i_volCatMult,    "SCH Volume Catalyst",   "Volume catalyst condition met on {{ticker}} {{interval}}")
alertcondition(counterTrend,              "SCH Counter-Trend Bar", "Counter-trend bar printed on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,   "SCH Webhook JSON",      "{\"action\":\"signal\",\"indicator\":\"SCH\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
