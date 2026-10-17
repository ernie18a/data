# Swing Leg 61.8% Fib

- url: https://www.tradingview.com/script/VwRKvQTg/
- type: indicator
- pine_id: PUB;46d4efb35e684c599b914e59ec2dcb18
- version: 2.0

## Description

Utilizes `ta.pivothigh` and `ta.pivotlow` to detect the most recent Swing High and Swing Low at the close of each candlestick (default lookback period: 5 bars; adjustable).

Automatically calculates the 61.8% Fibonacci retracement level based on the most recent swing leg, marking the corresponding price with a solid orange line.

Additionally, the current Swing High and Swing Low are highlighted using red and green dashed lines, respectively (this feature can be disabled in the settings).
The calculations and plotted lines are automatically recalculated and updated with every confirmed candlestick.

## Source Code

````pine
// This Pine Script™ indicator is subject to the terms of the Mozilla Public License 2.0
// NY Session Fib 61.8% & 38.2% — based on session high/low since 9:30 ET

//@version=6
indicator("NY Session Fib 61.8 / 38.2", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ──────────────────────────────────────────────
nyOpen  = input.session("0930-1600", "NY Session (ET)")
fibColor618 = input.color(color.new(color.orange, 0), "61.8% Line Color")
fibColor382 = input.color(color.new(color.blue, 0),   "38.2% Line Color")
hiColor     = input.color(color.new(color.red, 50),    "Session High Color")
loColor     = input.color(color.new(color.green, 50),  "Session Low Color")
lineWidth   = input.int(2, "Fib Line Width", minval=1, maxval=5)
showHL      = input.bool(true, "Show Session High / Low Lines")
extendBars  = input.int(15, "Extend Lines (bars)", minval=0)

// ── Session detection (New York = America/New_York) ─────
inSession = not na(time(timeframe.period, nyOpen, "America/New_York"))
sessionStart = inSession and not inSession[1]

// ── Track session high / low ────────────────────────────
var float sessHi    = na
var float sessLo    = na
var int   sessStart = na

if sessionStart
    sessHi    := high
    sessLo    := low
    sessStart := bar_index
else if inSession
    if high > sessHi
        sessHi := high
    if low < sessLo
        sessLo := low

// ── Calculate Fib levels ────────────────────────────────
// 61.8% retracement from HIGH  = sessLo + 0.382 * range  (= high - 0.618 * range)
// 38.2% retracement from HIGH  = sessLo + 0.618 * range  (= high - 0.382 * range)
diff = sessHi - sessLo
fib618 = sessHi - 0.618 * diff   // 61.8% 回撤 (从高点量)
fib382 = sessHi - 0.382 * diff   // 38.2% 回撤 (从高点量)

// ── Drawing objects ─────────────────────────────────────
var line line618 = na
var line line382 = na
var line lineHi  = na
var line lineLo  = na
var label lbl618 = na
var label lbl382 = na
var label lblHi  = na
var label lblLo  = na

if inSession and not na(sessHi) and not na(sessLo) and diff > 0
    endBar = bar_index + extendBars

    // ── 61.8% line ──
    if not na(line618)
        line.delete(line618)
    if not na(lbl618)
        label.delete(lbl618)
    line618 := line.new(sessStart, fib618, endBar, fib618, color=fibColor618, width=lineWidth, style=line.style_solid)
    lbl618  := label.new(endBar, fib618, "61.8%  " + str.tostring(fib618, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=fibColor618, size=size.normal)

    // ── 38.2% line ──
    if not na(line382)
        line.delete(line382)
    if not na(lbl382)
        label.delete(lbl382)
    line382 := line.new(sessStart, fib382, endBar, fib382, color=fibColor382, width=lineWidth, style=line.style_solid)
    lbl382  := label.new(endBar, fib382, "38.2%  " + str.tostring(fib382, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=fibColor382, size=size.normal)

    // ── Session High / Low lines ──
    if showHL
        if not na(lineHi)
            line.delete(lineHi)
        if not na(lineLo)
            line.delete(lineLo)
        if not na(lblHi)
            label.delete(lblHi)
        if not na(lblLo)
            label.delete(lblLo)
        lineHi := line.new(sessStart, sessHi, endBar, sessHi, color=hiColor, width=1, style=line.style_dashed)
        lineLo := line.new(sessStart, sessLo, endBar, sessLo, color=loColor, width=1, style=line.style_dashed)
        lblHi  := label.new(endBar, sessHi, "Hi  " + str.tostring(sessHi, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=hiColor, size=size.small)
        lblLo  := label.new(endBar, sessLo, "Lo  " + str.tostring(sessLo, format.mintick), style=label.style_label_left, color=color.new(color.black, 100), textcolor=loColor, size=size.small)

// ── Plots for data window / alerts ──────────────────────
plot(inSession ? fib618 : na, "Fib 61.8%", color=color.new(fibColor618, 80), display=display.data_window + display.status_line)
plot(inSession ? fib382 : na, "Fib 38.2%", color=color.new(fibColor382, 80), display=display.data_window + display.status_line)
````
