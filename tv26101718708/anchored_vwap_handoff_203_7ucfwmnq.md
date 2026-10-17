# Anchored VWAP Hand-Off 2.03

- url: https://www.tradingview.com/script/7UCfWmnQ-Anchored-VWAP-Hand-Off-2-03/
- type: indicator
- pine_id: PUB;62913960d0184d6a84c66c9af5a5405f
- version: 1.0

## Description

Anchored VWAP Hand-Off 2.03 is a multi-leg cascading VWAP indicator. It starts with a classic Anchored VWAP from a user-selected date (Leg 1), then automatically creates new "hand-off" VWAP legs (up to 24) every time price crosses the previous VWAP. Each new leg resets its calculation from the bar of the cross, creating a dynamic chain of VWAPs that follow price action.

Key Features:
Source: Typically close (customizable).
Trigger: EMA(1) of the source (essentially price itself).
Color Logic: Each VWAP leg changes color based on whether price is above (bullish) or below (bearish) it. Supports unified color mode.
Up to 24 cascading legs (user controls how many are shown).
Visual anchor line at the start date.

Main Use Cases:
Dynamic Support & Resistance
The multiple VWAP legs act as adaptive moving support/resistance zones. Traders watch for bounces off these lines or breaks through several legs at once.

Trend Strength & Momentum  
Strong trends often break multiple hand-off legs quickly.  
Choppy/consolidating markets produce many frequent hand-offs (more lines clustering).

Mean Reversion Setups
Price tends to return to the nearest active VWAP legs. Useful for fade-the-extreme strategies.

Breakout / Breakdown Confirmation
When price decisively breaks through several VWAP legs in sequence, it often signals a high-probability directional move.

Intraday & Swing Trading
Particularly popular on stocks, futures, and crypto for finding "fair value" shifts after news events or strong moves. The hand-off mechanism makes it more responsive than a single static anchored VWAP.

Visual Market Structure
Helps traders see how "value" is migrating over time as new legs form.

Best Timeframes: Works on all, but especially useful on 5min to daily charts.Pro Tip: Start with 8–12 legs. Too many legs can make the chart noisy. Use the anchor date on significant events (earnings, breakout days, macro events, etc.).This indicator is an evolution of standard Anchored VWAP, designed to solve the problem of a single anchored VWAP becoming stale after big moves.

## Source Code

````pine
//@version=6
indicator("Anchored VWAP Hand-Off 2.03", shorttitle="AVWAP_HO 2.03", overlay=true)

// ──────────────────────────────────────
// INPUTS
// ──────────────────────────────────────
startCalculationDate = input.time(timestamp("01 Jul 2026"), "Start Calculation Date", confirm=true)
vws = input.source(low, "Source")
t = input.int(10, "Transparency", minval=0, maxval=100, step=5)
num_legs = input.int(24, "Number of VWAP Legs", minval=1, maxval=24)

// Unified Color Mode Switch
unified_mode = input.bool(false, "Unified Color Mode", group="Color Settings")

// Single base color
base_color = input.color(color.aqua, "Base Color", group="Color Settings")
bullish_color = input.color(color.lime, "Bullish Color", group="Color Settings")
bearish_color = input.color(color.red, "Bearish Color", group="Color Settings")
col_anchor = input.color(color.blue, "Anchor Line Color", group="Anchor Line")

// ──────────────────────────────────────
// HELPER FUNCTION FOR COLOR
// ──────────────────────────────────────
get_color(is_up) =>
    if unified_mode
        color.new(is_up ? bullish_color : bearish_color, t)
    else
        color.new(base_color, t)

// ──────────────────────────────────────
// TRIGGER LINE
// ──────────────────────────────────────
trig = ta.ema(vws, 1)

// ──────────────────────────────────────
// LEG 1: ANCHORED VWAP (matches original)
// ──────────────────────────────────────
var float srcSum1 = 0.0
var float volSum1 = 0.0

if time >= startCalculationDate
    srcSum1 := srcSum1 + vws * volume
    volSum1 := volSum1 + volume
else
    srcSum1 := 0.0
    volSum1 := 0.0

vh = volSum1 != 0 ? srcSum1 / volSum1 : na

// ──────────────────────────────────────
// LEGS 2-24: CASCADE HAND-OFF (matching original pattern)
// ──────────────────────────────────────
// Leg 2
start2 = ta.crossover(trig, vh) or ta.crossunder(trig, vh)
var float srcSum2 = 0.0
var float volSum2 = 0.0
srcSum2 := start2 ? vws * volume : srcSum2 + vws * volume
volSum2 := start2 ? volume : volSum2 + volume
v1 = volSum2 != 0 ? srcSum2 / volSum2 : na

// Leg 3
start3 = ta.crossover(trig, v1) or ta.crossunder(trig, v1)
var float srcSum3 = 0.0
var float volSum3 = 0.0
srcSum3 := start3 ? vws * volume : srcSum3 + vws * volume
volSum3 := start3 ? volume : volSum3 + volume
v2 = volSum3 != 0 ? srcSum3 / volSum3 : na

// Leg 4
start4 = ta.crossover(trig, v2) or ta.crossunder(trig, v2)
var float srcSum4 = 0.0
var float volSum4 = 0.0
srcSum4 := start4 ? vws * volume : srcSum4 + vws * volume
volSum4 := start4 ? volume : volSum4 + volume
v3 = volSum4 != 0 ? srcSum4 / volSum4 : na

// Leg 5
start5 = ta.crossover(trig, v3) or ta.crossunder(trig, v3)
var float srcSum5 = 0.0
var float volSum5 = 0.0
srcSum5 := start5 ? vws * volume : srcSum5 + vws * volume
volSum5 := start5 ? volume : volSum5 + volume
v4 = volSum5 != 0 ? srcSum5 / volSum5 : na

// Leg 6
start6 = ta.crossover(trig, v4) or ta.crossunder(trig, v4)
var float srcSum6 = 0.0
var float volSum6 = 0.0
srcSum6 := start6 ? vws * volume : srcSum6 + vws * volume
volSum6 := start6 ? volume : volSum6 + volume
v5 = volSum6 != 0 ? srcSum6 / volSum6 : na

// Leg 7
start7 = ta.crossover(trig, v5) or ta.crossunder(trig, v5)
var float srcSum7 = 0.0
var float volSum7 = 0.0
srcSum7 := start7 ? vws * volume : srcSum7 + vws * volume
volSum7 := start7 ? volume : volSum7 + volume
v6 = volSum7 != 0 ? srcSum7 / volSum7 : na

// Leg 8
start8 = ta.crossover(trig, v6) or ta.crossunder(trig, v6)
var float srcSum8 = 0.0
var float volSum8 = 0.0
srcSum8 := start8 ? vws * volume : srcSum8 + vws * volume
volSum8 := start8 ? volume : volSum8 + volume
v7 = volSum8 != 0 ? srcSum8 / volSum8 : na

// Leg 9
start9 = ta.crossover(trig, v7) or ta.crossunder(trig, v7)
var float srcSum9 = 0.0
var float volSum9 = 0.0
srcSum9 := start9 ? vws * volume : srcSum9 + vws * volume
volSum9 := start9 ? volume : volSum9 + volume
v8 = volSum9 != 0 ? srcSum9 / volSum9 : na

// Leg 10
start10 = ta.crossover(trig, v8) or ta.crossunder(trig, v8)
var float srcSum10 = 0.0
var float volSum10 = 0.0
srcSum10 := start10 ? vws * volume : srcSum10 + vws * volume
volSum10 := start10 ? volume : volSum10 + volume
v9 = volSum10 != 0 ? srcSum10 / volSum10 : na

// Leg 11
start11 = ta.crossover(trig, v9) or ta.crossunder(trig, v9)
var float srcSum11 = 0.0
var float volSum11 = 0.0
srcSum11 := start11 ? vws * volume : srcSum11 + vws * volume
volSum11 := start11 ? volume : volSum11 + volume
v10 = volSum11 != 0 ? srcSum11 / volSum11 : na

// Leg 12
start12 = ta.crossover(trig, v10) or ta.crossunder(trig, v10)
var float srcSum12 = 0.0
var float volSum12 = 0.0
srcSum12 := start12 ? vws * volume : srcSum12 + vws * volume
volSum12 := start12 ? volume : volSum12 + volume
v11 = volSum12 != 0 ? srcSum12 / volSum12 : na

// Leg 13
start13 = ta.crossover(trig, v11) or ta.crossunder(trig, v11)
var float srcSum13 = 0.0
var float volSum13 = 0.0
srcSum13 := start13 ? vws * volume : srcSum13 + vws * volume
volSum13 := start13 ? volume : volSum13 + volume
v12 = volSum13 != 0 ? srcSum13 / volSum13 : na

// Leg 14
start14 = ta.crossover(trig, v12) or ta.crossunder(trig, v12)
var float srcSum14 = 0.0
var float volSum14 = 0.0
srcSum14 := start14 ? vws * volume : srcSum14 + vws * volume
volSum14 := start14 ? volume : volSum14 + volume
v13 = volSum14 != 0 ? srcSum14 / volSum14 : na

// Leg 15
start15 = ta.crossover(trig, v13) or ta.crossunder(trig, v13)
var float srcSum15 = 0.0
var float volSum15 = 0.0
srcSum15 := start15 ? vws * volume : srcSum15 + vws * volume
volSum15 := start15 ? volume : volSum15 + volume
v14 = volSum15 != 0 ? srcSum15 / volSum15 : na

// Leg 16
start16 = ta.crossover(trig, v14) or ta.crossunder(trig, v14)
var float srcSum16 = 0.0
var float volSum16 = 0.0
srcSum16 := start16 ? vws * volume : srcSum16 + vws * volume
volSum16 := start16 ? volume : volSum16 + volume
v15 = volSum16 != 0 ? srcSum16 / volSum16 : na

// Leg 17
start17 = ta.crossover(trig, v15) or ta.crossunder(trig, v15)
var float srcSum17 = 0.0
var float volSum17 = 0.0
srcSum17 := start17 ? vws * volume : srcSum17 + vws * volume
volSum17 := start17 ? volume : volSum17 + volume
v16 = volSum17 != 0 ? srcSum17 / volSum17 : na

// Leg 18
start18 = ta.crossover(trig, v16) or ta.crossunder(trig, v16)
var float srcSum18 = 0.0
var float volSum18 = 0.0
srcSum18 := start18 ? vws * volume : srcSum18 + vws * volume
volSum18 := start18 ? volume : volSum18 + volume
v17 = volSum18 != 0 ? srcSum18 / volSum18 : na

// Leg 19
start19 = ta.crossover(trig, v17) or ta.crossunder(trig, v17)
var float srcSum19 = 0.0
var float volSum19 = 0.0
srcSum19 := start19 ? vws * volume : srcSum19 + vws * volume
volSum19 := start19 ? volume : volSum19 + volume
v18 = volSum19 != 0 ? srcSum19 / volSum19 : na

// Leg 20
start20 = ta.crossover(trig, v18) or ta.crossunder(trig, v18)
var float srcSum20 = 0.0
var float volSum20 = 0.0
srcSum20 := start20 ? vws * volume : srcSum20 + vws * volume
volSum20 := start20 ? volume : volSum20 + volume
v19 = volSum20 != 0 ? srcSum20 / volSum20 : na

// Leg 21
start21 = ta.crossover(trig, v19) or ta.crossunder(trig, v19)
var float srcSum21 = 0.0
var float volSum21 = 0.0
srcSum21 := start21 ? vws * volume : srcSum21 + vws * volume
volSum21 := start21 ? volume : volSum21 + volume
v20 = volSum21 != 0 ? srcSum21 / volSum21 : na

// Leg 22
start22 = ta.crossover(trig, v20) or ta.crossunder(trig, v20)
var float srcSum22 = 0.0
var float volSum22 = 0.0
srcSum22 := start22 ? vws * volume : srcSum22 + vws * volume
volSum22 := start22 ? volume : volSum22 + volume
v21 = volSum22 != 0 ? srcSum22 / volSum22 : na

// Leg 23
start23 = ta.crossover(trig, v21) or ta.crossunder(trig, v21)
var float srcSum23 = 0.0
var float volSum23 = 0.0
srcSum23 := start23 ? vws * volume : srcSum23 + vws * volume
volSum23 := start23 ? volume : volSum23 + volume
v22 = volSum23 != 0 ? srcSum23 / volSum23 : na

// Leg 24
start24 = ta.crossover(trig, v22) or ta.crossunder(trig, v22)
var float srcSum24 = 0.0
var float volSum24 = 0.0
srcSum24 := start24 ? vws * volume : srcSum24 + vws * volume
volSum24 := start24 ? volume : volSum24 + volume
v23 = volSum24 != 0 ? srcSum24 / volSum24 : na

// ──────────────────────────────────────
// COLORS (Global scope, using function)
// ──────────────────────────────────────
col_1  = get_color(vws > vh)
col_2  = get_color(vws > v1)
col_3  = get_color(vws > v2)
col_4  = get_color(vws > v3)
col_5  = get_color(vws > v4)
col_6  = get_color(vws > v5)
col_7  = get_color(vws > v6)
col_8  = get_color(vws > v7)
col_9  = get_color(vws > v8)
col_10 = get_color(vws > v9)
col_11 = get_color(vws > v10)
col_12 = get_color(vws > v11)
col_13 = get_color(vws > v12)
col_14 = get_color(vws > v13)
col_15 = get_color(vws > v14)
col_16 = get_color(vws > v15)
col_17 = get_color(vws > v16)
col_18 = get_color(vws > v17)
col_19 = get_color(vws > v18)
col_20 = get_color(vws > v19)
col_21 = get_color(vws > v20)
col_22 = get_color(vws > v21)
col_23 = get_color(vws > v22)
col_24 = get_color(vws > v23)

// ──────────────────────────────────────
// PLOTS (Global scope, conditional on num_legs)
// ──────────────────────────────────────
plot(num_legs >= 1  ? vh   : na, "VWAP 1",  linewidth=2, color=num_legs >= 1  ? col_1  : na)
plot(num_legs >= 2  ? v1   : na, "VWAP 2",  linewidth=2, color=num_legs >= 2  ? col_2  : na)
plot(num_legs >= 3  ? v2   : na, "VWAP 3",  linewidth=2, color=num_legs >= 3  ? col_3  : na)
plot(num_legs >= 4  ? v3   : na, "VWAP 4",  linewidth=2, color=num_legs >= 4  ? col_4  : na)
plot(num_legs >= 5  ? v4   : na, "VWAP 5",  linewidth=2, color=num_legs >= 5  ? col_5  : na)
plot(num_legs >= 6  ? v5   : na, "VWAP 6",  linewidth=2, color=num_legs >= 6  ? col_6  : na)
plot(num_legs >= 7  ? v6   : na, "VWAP 7",  linewidth=2, color=num_legs >= 7  ? col_7  : na)
plot(num_legs >= 8  ? v7   : na, "VWAP 8",  linewidth=2, color=num_legs >= 8  ? col_8  : na)
plot(num_legs >= 9  ? v8   : na, "VWAP 9",  linewidth=2, color=num_legs >= 9  ? col_9  : na)
plot(num_legs >= 10 ? v9   : na, "VWAP 10", linewidth=2, color=num_legs >= 10 ? col_10 : na)
plot(num_legs >= 11 ? v10  : na, "VWAP 11", linewidth=2, color=num_legs >= 11 ? col_11 : na)
plot(num_legs >= 12 ? v11  : na, "VWAP 12", linewidth=2, color=num_legs >= 12 ? col_12 : na)
plot(num_legs >= 13 ? v12  : na, "VWAP 13", linewidth=2, color=num_legs >= 13 ? col_13 : na)
plot(num_legs >= 14 ? v13  : na, "VWAP 14", linewidth=2, color=num_legs >= 14 ? col_14 : na)
plot(num_legs >= 15 ? v14  : na, "VWAP 15", linewidth=2, color=num_legs >= 15 ? col_15 : na)
plot(num_legs >= 16 ? v15  : na, "VWAP 16", linewidth=2, color=num_legs >= 16 ? col_16 : na)
plot(num_legs >= 17 ? v16  : na, "VWAP 17", linewidth=2, color=num_legs >= 17 ? col_17 : na)
plot(num_legs >= 18 ? v17  : na, "VWAP 18", linewidth=2, color=num_legs >= 18 ? col_18 : na)
plot(num_legs >= 19 ? v18  : na, "VWAP 19", linewidth=2, color=num_legs >= 19 ? col_19 : na)
plot(num_legs >= 20 ? v19  : na, "VWAP 20", linewidth=2, color=num_legs >= 20 ? col_20 : na)
plot(num_legs >= 21 ? v20  : na, "VWAP 21", linewidth=2, color=num_legs >= 21 ? col_21 : na)
plot(num_legs >= 22 ? v21  : na, "VWAP 22", linewidth=2, color=num_legs >= 22 ? col_22 : na)
plot(num_legs >= 23 ? v22  : na, "VWAP 23", linewidth=2, color=num_legs >= 23 ? col_23 : na)
plot(num_legs >= 24 ? v23  : na, "VWAP 24", linewidth=2, color=num_legs >= 24 ? col_24 : na)

// ──────────────────────────────────────
// ANCHOR LINE (matches original)
// ──────────────────────────────────────
bool anchorChanged = ta.change(startCalculationDate) != 0
var line anchorLine = na

if barstate.isfirst or anchorChanged
    if na(anchorLine)
        anchorLine := line.new(startCalculationDate, -1e12, startCalculationDate, 1e12,
             xloc = xloc.bar_time,
             extend = extend.both,
             color = col_anchor,
             style = line.style_dashed,
             width = 2)
    else
        line.set_x1(anchorLine, startCalculationDate)
        line.set_x2(anchorLine, startCalculationDate)
````
