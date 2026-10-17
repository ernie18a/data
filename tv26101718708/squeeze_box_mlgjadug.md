# Squeeze Box 

- url: https://www.tradingview.com/script/mLGjaDUg-Squeeze-Box/
- type: indicator
- pine_id: PUB;1d447a1b990f4ec792c4ee0e60378304
- version: 1.0

## Description

[b]About This Script
[/b]
The Squeeze Box indicator is designed to detect periods of price compression where volatility contracts and price begins to coil into a tight range. These areas often precede expansion moves, breakouts, trend continuation, or volatility events.

Unlike traditional squeeze indicators that rely mainly on Bollinger Bands or Keltner Channels, this script focuses directly on the structure of consolidation itself.

The indicator automatically identifies tight trading ranges and draws visual “squeeze boxes” around them, helping traders spot:

[list]
[*]Volatility contraction
[*]Quiet accumulation/distribution
[*]VCP-style tightening
[*]Darvas-like consolidation zones
[*]Pre-breakout pressure buildup
[*]Pause-and-go continuation patterns[/list]

The script includes two optional squeeze-detection engines:

[list]
[*]ATR Range Compression
[*]Measures whether the total height of the consolidation zone is small relative to ATR.
[*]Regression Residual Compression
[*]Measures how tightly price hugs its regression line, helping identify orderly compression rather than random chop.
[*]
[/list]
These methods can be used individually or together to filter for higher-quality setups.

[b]Features[/b]
[b]Automatic squeeze box detection
Dynamic box extension while compression remains active
Optional midline display
Adjustable sensitivity settings
ATR-based compression filtering
Regression-based “tightness” filtering
Customizable colors and transparency
Control over how many historical boxes remain visible
Optional seed markers for early squeeze detection
Best Uses[/b]

This indicator works especially well for:

[list]
Momentum continuation setups
[*]VCP (Volatility Contraction Pattern) style trading
[*]Breakout traders
[*]Episodic Pivot follow-through
[*]Swing trading
[*]Identifying low-risk consolidation areas before expansion
[/list]

General Interpretation
Tight, narrow boxes often represent decreasing volatility and reduced selling pressure.
A breakout above the box may signal renewed momentum or institutional accumulation.
Failure to break out or rejection from the upper boundary may indicate unresolved supply.

The script is intended as a structure and pressure visualization tool rather than a standalone buy/sell system.

Suggested Settings
ATR Multiplier: ~0.6 to 1.2
Regression Multiplier: ~0.20 to 0.50
Minimum Bars in Box: 3+

Lower values create more selective squeezes, while higher values identify broader consolidation zones.

[b]Seed Dots [/b]
Optional dots beneath price indicate early compression conditions before a full squeeze box is confirmed. These dots act as an early warning that volatility and price movement are beginning to tighten.

In many cases:

Seed Dot → Squeeze Box → Expansion

They are intended to help traders monitor developing consolidation structures and potential breakout setups.

[b]Philosophy Behind the Indicator[/b]

Markets often move from:

Expansion → Contraction → Expansion

This script focuses on the contraction phase — the “quiet zone” where pressure builds before movement expands again.

The goal is not simply to find volatility squeezes, but to locate areas where price becomes compressed, orderly, and structurally tight before a potential directional move.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SpreadEagle71

//@version=5
indicator("Squeeze Box / Narrow Box (ATR or RegStd)", overlay=true, max_boxes_count=500)

//────────────────────────────────────────────────────────────
// Inputs
//────────────────────────────────────────────────────────────
mode = input.string("ATR Range", "Tightness Mode", options=["ATR Range", "Reg Residual StdDev"])

minBars     = input.int(3, "Minimum bars in box", minval=2)
atrLen      = input.int(14, "ATR Length", minval=1)

// ATR Range mode
atrMult     = input.float(1.0, "ATR Range Multiplier (box height <= ATR * mult)", step=0.05)

// Regression residual mode (normalized by ATR)
regMult     = input.float(0.35, "Reg Residual Mult (residStd <= ATR * mult)", step=0.01)

// Cosmetics
extendRight = input.bool(true, "Extend active box to the right?")
showMidline = input.bool(false, "Show box midline?")
keepBoxes   = input.int(50, "Keep last N boxes", minval=1, maxval=500)

boxBorderW  = input.int(1, "Border width", minval=1, maxval=4)
boxFill     = input.bool(true, "Fill box?")

//────────────────────────────────────────────────────────────
// Helpers
//────────────────────────────────────────────────────────────
atr = ta.atr(atrLen)

// “tightness” test for a window of length L that ends on current bar
tightATR(_hi, _lo) =>
    (_hi - _lo) <= atr * atrMult

tightREG(_len) =>
    // residuals from linear regression line
    // linreg returns the regression estimate of src at the current bar
    lr  = ta.linreg(close, _len, 0)
    res = close - lr
    // stddev of residuals over same window length
    rsd = ta.stdev(res, _len)
    rsd <= atr * regMult

isTight(_hi, _lo, _len) =>
    mode == "ATR Range" ? tightATR(_hi, _lo) : tightREG(_len)

//────────────────────────────────────────────────────────────
// State machine for building/ending boxes
//────────────────────────────────────────────────────────────
var bool inBox     = false
var int  startBar  = na
var float boxHi    = na
var float boxLo    = na
var box  activeBox = na
var line midLine   = na

// store boxes so we can delete old ones
var box[] boxes = array.new_box()

// Rolling minBars tightness seed
seedHi = ta.highest(high, minBars)
seedLo = ta.lowest(low,  minBars)
seedOk = isTight(seedHi, seedLo, minBars)

// Start a new box when we are NOT in a box and the seed condition is met
if not inBox and seedOk
    inBox    := true
    startBar := bar_index - (minBars - 1)
    boxHi    := seedHi
    boxLo    := seedLo

    // Create box spanning seed window
    activeBox := box.new(left=startBar, top=boxHi, right=bar_index, bottom=boxLo,
         border_width=boxBorderW,
         bgcolor=boxFill ? color.new(color.aqua, 60) : na,
         border_color=color.new(color.aqua, 0))

    // optional midline
    if showMidline
        mid = (boxHi + boxLo) * 0.5
        midLine := line.new(x1=startBar, y1=mid, x2=bar_index, y2=mid, width=1, color=color.new(color.aqua, 0))

// If we’re in a box, try to extend it
if inBox
    // Candidate extension includes current bar
    newHi = math.max(boxHi, high)
    newLo = math.min(boxLo, low)
    newLen = (bar_index - startBar + 1)

    ok = isTight(newHi, newLo, newLen)

    if ok
        // accept extension
        boxHi := newHi
        boxLo := newLo

        // update active box
        box.set_top(activeBox, boxHi)
        box.set_bottom(activeBox, boxLo)
        box.set_right(activeBox, bar_index)

        if extendRight
            // keep box “live” by extending to current bar; user can visually treat right edge as “now”
            box.set_extend(activeBox, extend.right)

        if showMidline and not na(midLine)
            mid = (boxHi + boxLo) * 0.5
            line.set_x2(midLine, bar_index)
            line.set_y1(midLine, mid)
            line.set_y2(midLine, mid)

    else
        // finalize box (stop extending), store it, and reset state
        if not extendRight
            box.set_extend(activeBox, extend.none)
        else
            // If it was extending right, stop extension so it “locks” at the end of the squeeze
            box.set_extend(activeBox, extend.none)
            box.set_right(activeBox, bar_index - 1)

        array.push(boxes, activeBox)

        // trim old boxes
        while array.size(boxes) > keepBoxes
            old = array.shift(boxes)
            box.delete(old)

        // cleanup midline
        if not na(midLine)
            line.delete(midLine)
            midLine := na

        // reset
        inBox     := false
        startBar  := na
        boxHi     := na
        boxLo     := na
        activeBox := na

// Optional: plot a tiny marker when a seed squeeze is detected (debug / feel)
plotshape(seedOk and not inBox, title="Seed Squeeze", style=shape.circle, size=size.tiny, color=color.new(color.aqua, 0), location=location.belowbar)
````
