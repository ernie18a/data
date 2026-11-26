# Volume-Weighted Support & Resistance

- url: https://www.tradingview.com/script/TZLl2QBP/
- type: indicator
- pine_id: PUB;ebf1f356de604ad9bdca8754b7ee6109
- version: 1.0

## Description

This indicator detects swing highs and swing lows that formed on above-average volume and draws them as support/resistance zones. The idea behind the volume filter is simple: a swing point where many participants transacted is more likely to be defended or revisited than one that formed on thin volume.

How it works

Swing points are found with standard pivot detection (a bar higher/lower than a configurable number of bars on each side).
A pivot is only accepted if the volume on the pivot bar exceeded the volume moving average at that time by a configurable multiplier (default 1.5x the 20-bar average).
Accepted pivots become zones. Zone height is a multiple of ATR(14), so zones scale with the instrument's volatility.
When price closes through a zone, it is treated as broken: it either fades to gray or is removed, depending on your setting. Alert conditions fire on both resistance and support breaks.
Only the most recent N levels per side are kept (configurable), so charts stay readable.

Notes and limitations

Pivot detection needs the configured number of bars to the right before a swing point can be confirmed, so zones always appear with that delay — this is inherent to pivots, not a flaw specific to this script. Break detection uses confirmed closes only. Volume data quality varies by market and data feed (notably in forex, where volume is tick-based). Past reactions at a level do not guarantee future reactions; use this as one input in your own analysis.

## Source Code

````pine
//@version=6
// ============================================================
//  Volume-Weighted Support & Resistance
//  Detects swing highs/lows that formed on above-average
//  volume and draws them as S/R zones. Zones are removed
//  (or kept faded) once price closes through them.
// ============================================================
indicator("Volume-Weighted Support & Resistance", overlay = true, max_boxes_count = 500)

// ---------- Inputs ----------
grpDet = "Detection"
pivLen   = input.int(10,    "Pivot length (bars left/right)", minval = 2,   group = grpDet)
volLen   = input.int(20,    "Volume average length",          minval = 1,   group = grpDet)
volMult  = input.float(1.5, "Volume multiplier",              minval = 0.5, step = 0.1, group = grpDet)
zoneMult = input.float(0.25,"Zone height (ATR multiple)",     minval = 0.05, step = 0.05, group = grpDet)
maxLv    = input.int(8,     "Max levels per side",            minval = 1, maxval = 50, group = grpDet)

grpDsp = "Display"
resCol     = input.color(color.new(#ef5350, 0), "Resistance", group = grpDsp)
supCol     = input.color(color.new(#26a69a, 0), "Support",    group = grpDsp)
brokenCol  = input.color(color.new(#787b86, 0), "Broken",     group = grpDsp)
keepBroken = input.bool(true, "Keep broken levels (faded)",   group = grpDsp)

// ---------- Detection ----------
atrVal = ta.atr(14)
volAvg = ta.sma(volume, volLen)

phVal = ta.pivothigh(high, pivLen, pivLen)
plVal = ta.pivotlow(low,  pivLen, pivLen)
// The pivot bar is pivLen bars back; require its volume to exceed
// the average volume at that time by the chosen multiplier.
volOk = volume[pivLen] > volAvg[pivLen] * volMult

var array<box> resB = array.new<box>()
var array<box> supB = array.new<box>()

if not na(phVal) and volOk
    b = box.new(bar_index - pivLen, phVal, bar_index, phVal - atrVal * zoneMult,
         border_color = color.new(resCol, 40), bgcolor = color.new(resCol, 82),
         extend = extend.right)
    array.push(resB, b)
    if array.size(resB) > maxLv
        box.delete(array.shift(resB))

if not na(plVal) and volOk
    b = box.new(bar_index - pivLen, plVal + atrVal * zoneMult, bar_index, plVal,
         border_color = color.new(supCol, 40), bgcolor = color.new(supCol, 82),
         extend = extend.right)
    array.push(supB, b)
    if array.size(supB) > maxLv
        box.delete(array.shift(supB))

// ---------- Break handling ----------
f_fade(box b) =>
    box.set_extend(b, extend.none)
    box.set_right(b, bar_index)
    box.set_bgcolor(b, color.new(brokenCol, 90))
    box.set_border_color(b, color.new(brokenCol, 60))

resBroken = false
if barstate.isconfirmed and array.size(resB) > 0
    for i = array.size(resB) - 1 to 0
        b = array.get(resB, i)
        if close > box.get_top(b)
            resBroken := true
            array.remove(resB, i)
            if keepBroken
                f_fade(b)
            else
                box.delete(b)

supBroken = false
if barstate.isconfirmed and array.size(supB) > 0
    for i = array.size(supB) - 1 to 0
        b = array.get(supB, i)
        if close < box.get_bottom(b)
            supBroken := true
            array.remove(supB, i)
            if keepBroken
                f_fade(b)
            else
                box.delete(b)

// ---------- Alerts ----------
alertcondition(resBroken, "Resistance broken", "Volume-Weighted S&R: price closed above a resistance zone")
alertcondition(supBroken, "Support broken",    "Volume-Weighted S&R: price closed below a support zone")
````
