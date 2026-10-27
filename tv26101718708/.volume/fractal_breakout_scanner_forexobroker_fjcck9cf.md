# Fractal Breakout Scanner [forexobroker]

- url: https://www.tradingview.com/script/fjccK9Cf-Fractal-Breakout-Scanner-forexobroker/
- type: indicator
- pine_id: PUB;23e28072d2694833bfef542f350a76d6
- version: 1.0

## Description

🔶 OVERVIEW

Fractal Breakout Scanner is an overlay indicator that automates support and resistance level detection using Williams fractals — mathematically confirmed pivot points where price has reversed. It tracks these levels as persistent S/R lines on the chart, counts how many times each level has been tested, and generates breakout signals when price closes beyond a tested level with volume confirmation.

The advantage over manually drawn S/R levels is objectivity and consistency. Human-drawn levels are subjective — two traders looking at the same chart will draw different lines. Fractals provide a mathematical definition: a pivot high requires the high to be the highest point within a configurable number of left and right bars, and vice versa for pivot lows. Levels that are tested multiple times become stronger (the lines become thicker and more opaque), and breakouts through multi-tested levels carry more significance.

This indicator is designed for traders who want systematic, objective support and resistance analysis with automated breakout detection.

🔶 CONCEPTS

Fractals in trading are mathematically defined turning points in price. A fractal high occurs when a bar's high is higher than the highs of a set number of bars on both sides — it is a confirmed local top. A fractal low is a confirmed local bottom. These points naturally correspond to where buying or selling pressure reversed price, making them logical support and resistance levels.

The strength of an S/R level increases with each touch. When price approaches a level and bounces away, it validates the level and attracts more attention from traders who place orders at that price. A level tested three or four times has more resting orders than one tested only once. When that well-tested level finally breaks, it represents a significant shift — the orders that were defending the level have been overwhelmed, and price is likely to continue in the breakout direction.

The concept of role reversal is also important: broken resistance tends to become support, and broken support tends to become resistance. While this indicator does not explicitly implement role reversal, the breakout signals identify the moment of the break, which is the optimal entry timing for this phenomenon.

🔶 HOW IT WORKS

• Fractal highs and lows are detected using configurable left and right bar counts — the pivot must be the highest high (or lowest low) across both sides to qualify
• Each fractal is added as a support or resistance level, and nearby levels within an ATR-based proximity zone are merged (increasing the touch count) rather than duplicated
• S/R lines are drawn on the chart with color intensity and line width proportional to the touch count — lightly tested levels are thin and transparent, heavily tested levels are thick and bold
• Breakout signals fire when price closes beyond a tracked level on a confirmed bar with volume above its SMA and cooldown satisfied — the signal label includes the specific level price and touch count
• Separate touch tracking updates each level's count when price approaches within the touch zone and then retreats

🔶 HOW TO USE

1. Add the indicator to any chart — fractal dots and S/R lines will populate automatically based on recent pivot points
2. Watch for resistance lines (pink) and support lines (green) that grow thicker and more opaque over time — these are the levels being tested repeatedly and building significance
3. When a "BULL BREAK" or "BEAR BREAK" signal fires, the label shows the exact level that was broken and its touch count — higher touch counts suggest more significant breakouts
4. After a breakout signal, consider using the broken level as a stop-loss reference (broken resistance becomes support, broken support becomes resistance) and target the next S/R level visible on the chart

🔶 FEATURES

• Non-repainting signals (uses barstate.isconfirmed)
• Works on all timeframes and instruments
• 9 alert conditions with webhook JSON support
• Professional dashboard with resistance/support counts, total touches, and cooldown status
• Automatic level merging that combines nearby fractals into stronger consolidated levels
• Glow-effect fractal dots with diamond markers at confirmed pivot points

🔶 SETTINGS GUIDE

• Left Bars / Right Bars — Number of bars on each side required to confirm a fractal pivot (default: 3 / 3)
• Max S/R Levels — Maximum number of fractal levels tracked simultaneously (default: 5)
• Breakout Buffer (ticks) — Extra distance past a level required to confirm a breakout; 0 means the close must simply exceed the level (default: 0)
• Signal Cooldown — Minimum bars between consecutive breakout signals (default: 15)
• Volume SMA Length — Volume filter period for breakout confirmation (default: 20)
• Show Fractal Dots — Toggle diamond markers on confirmed fractal pivots
• Show S/R Lines — Toggle the support and resistance level lines
• Line Extension — How many bars forward S/R lines extend beyond current price (default: 50)
• Show Info Table — Toggle the level statistics dashboard

🔶 ALERTS

• FBS Buy Signal — Fires on confirmed bullish breakout above resistance
• FBS Sell Signal — Fires on confirmed bearish breakout below support
• FBS Any Signal — Fires on any confirmed breakout
• FBS Fractal High — Fires when a new fractal high is confirmed
• FBS Fractal Low — Fires when a new fractal low is confirmed
• FBS Any Fractal — Fires on any new fractal formation
• FBS Volume Spike — Fires when volume exceeds its SMA
• FBS 20-Bar High — Fires when price makes a new 20-bar high
• FBS 20-Bar Low — Fires when price makes a new 20-bar low

🔶 LIMITATIONS & DISCLAIMER

• This is a technical analysis tool, not financial advice
• Past patterns do not guarantee future results
• Best used alongside price action context and proper risk management
• Fractal detection has an inherent lag equal to the right-bar count — the pivot is confirmed only after the right-side bars complete, so the fractal appears retroactively
• In strongly trending markets with few pullbacks, the indicator may generate fewer S/R levels because fractals form less frequently — this is a feature, not a bug, as it prevents plotting irrelevant levels in directional markets

## Source Code

````pine
// © forexobroker
//@version=6
indicator("Fractal Breakout Scanner [forexobroker]", shorttitle="FBS [fob]", overlay=true, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
string g_frac    = "Fractal Settings"
int    fracLeft  = input.int(3, "Left Bars", minval=1, group=g_frac, tooltip="Bars to the left of the pivot")
int    fracRight = input.int(3, "Right Bars", minval=1, group=g_frac, tooltip="Bars to the right confirming the pivot")
int    maxLevels = input.int(5, "Max S/R Levels", minval=1, maxval=10, group=g_frac, tooltip="Maximum fractal levels to track")

string g_brk     = "Breakout Settings"
float  brkBuffer = input.float(0.0, "Breakout Buffer (ticks)", minval=0.0, step=1.0, group=g_brk, tooltip="Extra distance past level to confirm breakout")
int    cooldown  = input.int(15, "Signal Cooldown (bars)", minval=1, group=g_brk)
int    volSmaLen = input.int(20, "Volume SMA Length", minval=1, group=g_brk)

string g_vis     = "Visuals"
bool   showDots  = input.bool(true, "Show Fractal Dots", group=g_vis)
bool   showLines = input.bool(true, "Show S/R Lines", group=g_vis)
int    lineExt   = input.int(50, "Line Extension (bars)", minval=10, group=g_vis)
bool   showTable = input.bool(true, "Show Info Table", group=g_vis)

// ─── COLORS ───────────────────────────────────────────────────────────────────
color neonCyan   = #00d4ff
color neonPink   = #ff2d78
color neonGreen  = #39ff14
color neonPurple = #a855f7
color neonGold   = #ffaa00

// ─── FRACTAL DETECTION ────────────────────────────────────────────────────────
float fracHigh = ta.pivothigh(high, fracLeft, fracRight)
float fracLow  = ta.pivotlow(low, fracLeft, fracRight)

// ─── S/R LEVEL TRACKING WITH TOUCH COUNTS ─────────────────────────────────────
type SRLevel
    float price
    int   touches
    int   barIdx
    bool  isResistance
    line  ln

var array<SRLevel> levels = array.new<SRLevel>()

// Track proximity to existing levels
float touchZone = ta.atr(14) * 0.3

// Add new fractal high as resistance
if not na(fracHigh)
    bool merged = false
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            SRLevel lvl = array.get(levels, i)
            if lvl.isResistance and math.abs(lvl.price - fracHigh) < touchZone
                lvl.touches += 1
                lvl.barIdx := bar_index - fracRight
                merged := true
                break
    if not merged
        SRLevel newLvl = SRLevel.new(fracHigh, 1, bar_index - fracRight, true, na)
        if array.size(levels) >= maxLevels * 2
            SRLevel old = array.shift(levels)
            if not na(old.ln)
                line.delete(old.ln)
        array.push(levels, newLvl)

// Add new fractal low as support
if not na(fracLow)
    bool merged = false
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            SRLevel lvl = array.get(levels, i)
            if not lvl.isResistance and math.abs(lvl.price - fracLow) < touchZone
                lvl.touches += 1
                lvl.barIdx := bar_index - fracRight
                merged := true
                break
    if not merged
        SRLevel newLvl = SRLevel.new(fracLow, 1, bar_index - fracRight, false, na)
        if array.size(levels) >= maxLevels * 2
            SRLevel old = array.shift(levels)
            if not na(old.ln)
                line.delete(old.ln)
        array.push(levels, newLvl)

// ─── DRAW S/R LINES ──────────────────────────────────────────────────────────
if showLines and barstate.islast and array.size(levels) > 0
    for i = 0 to array.size(levels) - 1
        SRLevel lvl = array.get(levels, i)
        if not na(lvl.ln)
            line.delete(lvl.ln)
        color lineClr = lvl.isResistance ? color.from_gradient(lvl.touches, 1, 5, color.new(neonPink, 60), color.new(neonPink, 10)) : color.from_gradient(lvl.touches, 1, 5, color.new(neonGreen, 60), color.new(neonGreen, 10))
        int lineW = lvl.touches >= 3 ? 2 : 1
        lvl.ln := line.new(lvl.barIdx, lvl.price, bar_index + lineExt, lvl.price, color=lineClr, width=lineW, style=lvl.touches >= 3 ? line.style_solid : line.style_dashed)

// ─── VOLUME FILTER ────────────────────────────────────────────────────────────
float volSma     = ta.sma(volume, volSmaLen)
bool  volConfirm = volume > volSma

// ─── BREAKOUT DETECTION ──────────────────────────────────────────────────────
var int lastSigBar = 0
int barsSinceSig   = bar_index - lastSigBar
bool cooldownOk    = barsSinceSig >= cooldown
float bufferPts    = brkBuffer * syminfo.mintick

var float lastBrkLevel = na
var int   lastBrkTouches = 0

bool bullBreak = false
bool bearBreak = false

if barstate.isconfirmed and volConfirm and cooldownOk and array.size(levels) > 0
    for i = 0 to array.size(levels) - 1
        SRLevel lvl = array.get(levels, i)
        if lvl.isResistance and close > lvl.price + bufferPts and close[1] <= lvl.price + bufferPts
            bullBreak := true
            lastBrkLevel := lvl.price
            lastBrkTouches := lvl.touches
            break
        if not lvl.isResistance and close < lvl.price - bufferPts and close[1] >= lvl.price - bufferPts
            bearBreak := true
            lastBrkLevel := lvl.price
            lastBrkTouches := lvl.touches
            break

if bullBreak or bearBreak
    lastSigBar := bar_index

// ─── COUNT TOUCHES ON EXISTING LEVELS ─────────────────────────────────────────
if barstate.isconfirmed and array.size(levels) > 0
    for i = 0 to array.size(levels) - 1
        SRLevel lvl = array.get(levels, i)
        if math.abs(close - lvl.price) < touchZone and math.abs(close[1] - lvl.price) >= touchZone
            lvl.touches += 1

// ─── FRACTAL DOT GLOW EFFECT ─────────────────────────────────────────────────
plotshape(showDots and not na(fracHigh), "Frac Hi Glow", shape.diamond, location.abovebar, color.new(neonPink, 60), offset=-fracRight, size=size.small)
plotshape(showDots and not na(fracHigh), "Frac Hi Dot",  shape.diamond, location.abovebar, neonPink, offset=-fracRight, size=size.tiny)
plotshape(showDots and not na(fracLow), "Frac Lo Glow",  shape.diamond, location.belowbar, color.new(neonGreen, 60), offset=-fracRight, size=size.small)
plotshape(showDots and not na(fracLow), "Frac Lo Dot",   shape.diamond, location.belowbar, neonGreen, offset=-fracRight, size=size.tiny)

// ─── 3-LAYER GLOW ARROWS ─────────────────────────────────────────────────────
plotshape(bullBreak, "Buy Glow 3", shape.triangleup, location.belowbar, color.new(neonGreen, 70), size=size.huge)
plotshape(bullBreak, "Buy Glow 2", shape.triangleup, location.belowbar, color.new(neonGreen, 40), size=size.large)
plotshape(bullBreak, "Buy Signal",  shape.triangleup, location.belowbar, neonGreen, size=size.normal, text="BUY", textcolor=neonGreen)

plotshape(bearBreak, "Sell Glow 3", shape.triangledown, location.abovebar, color.new(neonPink, 70), size=size.huge)
plotshape(bearBreak, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(neonPink, 40), size=size.large)
plotshape(bearBreak, "Sell Signal",  shape.triangledown, location.abovebar, neonPink, size=size.normal, text="SELL", textcolor=neonPink)

// ─── BARCOLOR ─────────────────────────────────────────────────────────────────
barcolor(bullBreak ? neonGreen : bearBreak ? neonPink : na, title="Signal Bar Color")

// ─── SIGNAL LABELS ────────────────────────────────────────────────────────────
if bullBreak
    label.new(bar_index, low, "BULL BREAK\nLevel: " + str.tostring(lastBrkLevel, "#.00") + "\nTouches: " + str.tostring(lastBrkTouches) + "\nVol: " + str.tostring(volume / volSma, "#.0") + "x", style=label.style_label_up, color=color.new(neonGreen, 20), textcolor=color.white, size=size.small)

if bearBreak
    label.new(bar_index, high, "BEAR BREAK\nLevel: " + str.tostring(lastBrkLevel, "#.00") + "\nTouches: " + str.tostring(lastBrkTouches) + "\nVol: " + str.tostring(volume / volSma, "#.0") + "x", style=label.style_label_down, color=color.new(neonPink, 20), textcolor=color.white, size=size.small)

// ─── INFO TABLE ───────────────────────────────────────────────────────────────
if showTable and barstate.islast
    var table info = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.white, 80))
    int resCount = 0
    int supCount = 0
    int totalTouches = 0
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            SRLevel lvl = array.get(levels, i)
            if lvl.isResistance
                resCount += 1
            else
                supCount += 1
            totalTouches += lvl.touches

    table.cell(info, 0, 0, "FBS", text_color=neonCyan, text_size=size.normal, bgcolor=color.new(color.black, 30))
    table.cell(info, 1, 0, "Scanner", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 30))
    table.cell(info, 0, 1, "Resistance", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, str.tostring(resCount) + " levels", text_color=neonPink, text_size=size.small)
    table.cell(info, 0, 2, "Support", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, str.tostring(supCount) + " levels", text_color=neonGreen, text_size=size.small)
    table.cell(info, 0, 3, "Total Touches", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 3, str.tostring(totalTouches), text_color=neonGold, text_size=size.small)
    table.cell(info, 0, 4, "Volume", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 4, volConfirm ? "PASS" : "FAIL", text_color=volConfirm ? neonGreen : neonPink, text_size=size.small)
    table.cell(info, 0, 5, "Cooldown", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 5, cooldownOk ? "READY" : str.tostring(cooldown - barsSinceSig) + " bars", text_color=cooldownOk ? neonGreen : neonGold, text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
if bullBreak
    alert('{"indicator":"FBS","signal":"BUY","ticker":"' + syminfo.tickerid + '","price":' + str.tostring(close) + ',"level":' + str.tostring(lastBrkLevel) + ',"touches":' + str.tostring(lastBrkTouches) + '}', alert.freq_once_per_bar_close)
    alert("FBS Bullish Breakout on " + syminfo.tickerid, alert.freq_once_per_bar_close)

if bearBreak
    alert('{"indicator":"FBS","signal":"SELL","ticker":"' + syminfo.tickerid + '","price":' + str.tostring(close) + ',"level":' + str.tostring(lastBrkLevel) + ',"touches":' + str.tostring(lastBrkTouches) + '}', alert.freq_once_per_bar_close)
    alert("FBS Bearish Breakout on " + syminfo.tickerid, alert.freq_once_per_bar_close)

// ─── 9x ALERTCONDITION ───────────────────────────────────────────────────────
alertcondition(bullBreak, "FBS Buy Signal", "FBS Bullish breakout on {{ticker}} at {{close}} on {{interval}}")
alertcondition(bearBreak, "FBS Sell Signal", "FBS Bearish breakout on {{ticker}} at {{close}} on {{interval}}")
alertcondition(bullBreak or bearBreak, "FBS Any Signal", "FBS Breakout on {{ticker}} at {{close}} on {{interval}}")
alertcondition(not na(fracHigh), "FBS Fractal High", "FBS Fractal high formed on {{ticker}} {{interval}}")
alertcondition(not na(fracLow), "FBS Fractal Low", "FBS Fractal low formed on {{ticker}} {{interval}}")
alertcondition(not na(fracHigh) or not na(fracLow), "FBS Any Fractal", "FBS Fractal formed on {{ticker}} {{interval}}")
alertcondition(volConfirm, "FBS Volume Spike", "FBS Volume above SMA on {{ticker}} {{interval}}")
alertcondition(close > ta.highest(high, 20)[1], "FBS 20-Bar High", "FBS New 20-bar high on {{ticker}} {{interval}}")
alertcondition(close < ta.lowest(low, 20)[1], "FBS 20-Bar Low", "FBS New 20-bar low on {{ticker}} {{interval}}")
````
