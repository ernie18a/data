# 30-Min ORB Retest Signal

- url: https://www.tradingview.com/script/1hUOcj5H-30-Min-ORB-Retest-Signal/
- type: indicator
- pine_id: PUB;829eeb680edb4c0aa820ebe6f7bfb6c2
- version: 1.0

## Description

30 min orb for NQ futures, thsi strategy is based on the level of market

## Source Code

````pine
//@version=5
indicator("30-Min ORB Retest Signal", overlay=true, max_bars_back=500)

// ── Inputs ──────────────────────────────────────────────
retestBuffer = input.int(2, "Retest Buffer (ticks)", minval=1, maxval=10)
tickSize     = input.float(0.25, "Tick Size", step=0.25)
orbColor     = input.color(color.new(color.blue, 0), "ORB Line Color")
extendLines  = input.bool(true, "Extend Lines Right")

// ── Session Detection ────────────────────────────────────
isORBWindow  = not na(time("5", "0930-1000:23456"))  // 9:30–10:00 ET, Mon–Fri
isPostORB    = not na(time("5", "1000-1600:23456"))   // After 10:00 ET

// ── ORB State ────────────────────────────────────────────
var float  orbH      = na
var float  orbL      = na
var bool   orbSet    = false
var bool   brokeHigh = false
var bool   brokeLow  = false
var line   lineHigh  = na
var line   lineLow   = na
var label  lblHigh   = na
var label  lblLow    = na
var int    orbStartBar = na

// ── Build ORB (capture high/low during 9:30–10:00) ───────
if isORBWindow
    if na(orbH) or high > orbH
        orbH := high
    if na(orbL) or low < orbL
        orbL := low
    orbStartBar := bar_index

// ── Draw ORB lines once at 10:00 ─────────────────────────
isORBClose = isORBWindow[1] and isPostORB  // first bar after ORB window

if isORBClose and not orbSet
    orbSet := true
    brokeHigh := false
    brokeLow  := false

    lineStyle = extendLines ? extend.right : extend.none

    // Delete old lines
    if not na(lineHigh)
        line.delete(lineHigh)
    if not na(lineLow)
        line.delete(lineLow)
    if not na(lblHigh)
        label.delete(lblHigh)
    if not na(lblLow)
        label.delete(lblLow)

    // ORB High line
    lineHigh := line.new(
         x1=orbStartBar, y1=orbH,
         x2=bar_index,   y2=orbH,
         color=color.new(color.green, 0),
         width=2,
         extend=lineStyle,
         style=line.style_solid)

    // ORB Low line
    lineLow := line.new(
         x1=orbStartBar, y1=orbL,
         x2=bar_index,   y2=orbL,
         color=color.new(color.red, 0),
         width=2,
         extend=lineStyle,
         style=line.style_solid)

    // ORB High label
    lblHigh := label.new(
         x=bar_index + 2, y=orbH,
         text="ORB H — " + str.tostring(orbH, "#.##"),
         color=color.new(color.green, 10),
         textcolor=color.white,
         style=label.style_label_left,
         size=size.small)

    // ORB Low label
    lblLow := label.new(
         x=bar_index + 2, y=orbL,
         text="ORB L — " + str.tostring(orbL, "#.##"),
         color=color.new(color.red, 10),
         textcolor=color.white,
         style=label.style_label_left,
         size=size.small)

// ── Reset ORB at start of new day ────────────────────────
isNewDay = dayofweek != dayofweek[1]
if isNewDay
    orbH    := na
    orbL    := na
    orbSet  := false
    brokeHigh := false
    brokeLow  := false

// ── Shade ORB window (9:30–10:00) ────────────────────────
bgcolor(isORBWindow ? color.new(color.blue, 90) : na, title="ORB Build Window")

// ── Breakout & Retest Logic ──────────────────────────────
buf = retestBuffer * tickSize

if orbSet and isPostORB
    if not brokeHigh and close > orbH
        brokeHigh := true
    if not brokeLow and close < orbL
        brokeLow := true

    // Long retest
    if brokeHigh and not brokeLow
        if low <= orbH + buf and close > orbH - buf
            label.new(bar_index, low - buf * 6,
                 "▲ LONG\n" + str.tostring(close, "#.##"),
                 color=color.new(color.green, 5),
                 textcolor=color.white,
                 style=label.style_label_up,
                 size=size.normal)
            alert("ORB Long Retest @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)
            brokeHigh := false

    // Short retest
    if brokeLow and not brokeHigh
        if high >= orbL - buf and close < orbL + buf
            label.new(bar_index, high + buf * 6,
                 "▼ SHORT\n" + str.tostring(close, "#.##"),
                 color=color.new(color.red, 5),
                 textcolor=color.white,
                 style=label.style_label_down,
                 size=size.normal)
            alert("ORB Short Retest @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)
            brokeLow := false
````
