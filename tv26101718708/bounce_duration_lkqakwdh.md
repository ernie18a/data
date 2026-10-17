# Bounce Duration

- url: https://www.tradingview.com/script/lkQakWDh-Bounce-Duration/
- type: indicator
- pine_id: PUB;f31dc59468de42238d6dcb90d4fa88ca
- version: 1.0

## Description

[b]Overview[/b]

Bounce Duration measures and visualizes the bar count of price bounces within a bearish cycle, from a confirmed swing low to its highest swing high before the next lower low. Each completed bounce is drawn as a labeled box, making it immediately obvious when the current bounce is behaving differently from historical ones.

Most bounce-analysis tools focus on price magnitude (how far a rally retraced). This indicator focuses on [i]time[/i], a dimension that is equally important but rarely visualized directly. An unusually long bounce duration is often a meaningful signal that market structure is changing.


[b]How It Works[/b]

Swing highs and lows are identified using confirmed pivots. A bounce is measured from a post-ATH swing low to the highest swing high before the next lower low. The cycle resets on a new all-time high, ensuring only post-peak corrective bounces are measured. A live box tracks the current in-progress bounce in real time for direct comparison against history.

Two safeguards prevent false signals:
[list]
[*] Bounces that reach a new ATH are excluded automatically
[*] Only swing lows occurring on or after the ATH reset bar are accepted as valid starting points
[/list]
[b]Inputs[/b]
[list]
[*] [b]Minimum Bounce Duration (bars)[/b] - Filters out bounces shorter than this threshold
[*] [b]Pivot Length (bars L/R)[/b] - Controls swing detection sensitivity. Higher values find fewer, more significant pivots
[*] [b]Use Close Instead of Wick[/b] - Switches pivot detection to closing prices, useful for filtering wick noise on volatile instruments
[*] [b]Show Current Bounce[/b] - Toggles the live unconfirmed bounce box
[*] Colors, text size, and label alignment are fully customizable
[/list]
[b]How to Use It[/b]

Compare the duration of the current bounce to all prior bounces in the same corrective cycle. Bear market bounces are typically short and uniform. When a bounce persists significantly longer than any previous one, it suggests accumulation may be underway rather than a simple relief rally.

[i]Example:[/i] On Bitcoin's daily chart, the current bounce from the 2026 lows, measured on closing prices, is already longer in duration than every prior bounce in the post-ATH correction of prior cycles. This temporal outlier supports the case for a durable bottom forming rather than just another bear market bounce.

The indicator works on any timeframe and any instrument with clear corrective cycles. Adjust Pivot Length to match your timeframe, lower values for intraday and higher for weekly or monthly analysis.
[image]https://www.tradingview.com/x/Wc37FQ3k/[/image]
[b]Notes[/b]
[list]
[*] The current bounce box repaints as it updates each bar. Confirmed historical boxes do not repaint.
[*] No boxes are shown during a sustained uptrend. The indicator is designed for post-peak corrective analysis only.
[/list]For informational and educational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
indicator("Bounce Duration", overlay=true, max_boxes_count=500, max_labels_count=500)

// ─── Detection ────────────────────────────────────────────────────
minBars  = input.int(5,     "Minimum Bounce Duration (bars)", minval=1, group="Detection",
             tooltip="The minimum number of bars a bounce must span (from swing low to swing high) before it is drawn on the chart.")
pivotLen = input.int(5,     "Pivot Length (bars L/R)", minval=1, group="Detection",
             tooltip="Number of bars required on each side of a candidate bar to confirm it as a swing high or swing low. Higher values identify fewer but more significant swings; lower values are more sensitive to minor price moves.")
useClose = input.bool(false, "Use Close Instead of Wick", group="Detection",
             tooltip="When enabled, pivot detection uses closing prices instead of high/low wicks. Useful for filtering out wick-heavy noise on volatile instruments.")

// ─── Display ──────────────────────────────────────────────────────
showCurrent  = input.bool(true, "Show Current (Unconfirmed) Bounce",  group="Display",
             tooltip="Draws a live box for the bounce currently in progress, even though it has not yet been confirmed by a new lower low.")
boxColor     = input.color(color.new(#0D9488, 50), "Confirmed Box Fill",  group="Display")
borderColor  = input.color(color.new(#0D9488, 10), "Box Border Color",    group="Display")
curFillColor = input.color(color.new(#2563EB, 50), "Current Box Fill",    group="Display")
lblColor     = input.color(color.new(#0D9488,  0), "Label Color",         group="Display")

// ─── Label Position ───────────────────────────────────────────────
txtSize  = input.string("Normal", "Text Size",
             options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Label Position")
txtHoriz = input.string("Center", "Horizontal Align",
             options=["Left", "Center", "Right"], group="Label Position")
txtVert  = input.string("Top", "Vertical Align",
             options=["Top", "Center", "Bottom"], group="Label Position")

// ── Helpers ───────────────────────────────────────────────────────
sz = switch txtSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Large"  => size.large
    "Huge"   => size.huge
    =>           size.normal

lblStyle = switch txtHoriz + "|" + txtVert
    "Left|Top"      => label.style_label_lower_right
    "Left|Center"   => label.style_label_right
    "Left|Bottom"   => label.style_label_upper_right
    "Center|Top"    => label.style_label_down
    "Center|Center" => label.style_label_center
    "Center|Bottom" => label.style_label_up
    "Right|Top"     => label.style_label_lower_left
    "Right|Center"  => label.style_label_left
    =>                 label.style_label_upper_left

lblX(sl, sh) =>
    switch txtHoriz
        "Left"  => sl
        "Right" => sh
        =>         math.round((sl + sh) / 2)

lblY(lo, hi) =>
    switch txtVert
        "Top"    => hi
        "Bottom" => lo
        =>          (hi + lo) / 2

// ── Source ────────────────────────────────────────────────────────
srcHigh = useClose ? close : high
srcLow  = useClose ? close : low

// ── ATH Reset ─────────────────────────────────────────────────────
var float ath        = na
var int   lastATHBar = na

ath   := na(ath) ? srcHigh : math.max(ath[1], srcHigh)
newATH = srcHigh > ath[1]

if newATH
    lastATHBar := bar_index

// ── State ─────────────────────────────────────────────────────────
var int   slBar      = na
var float slPrice    = na
var int   peakBar    = na
var float peakPrice  = na
var int   runHiBar   = na
var float runHiPrice = na
var box   curBox     = na
var label curLbl     = na

if newATH
    slBar      := na
    slPrice    := na
    peakBar    := na
    peakPrice  := na
    runHiBar   := na
    runHiPrice := na

if not na(slBar) and not newATH
    if na(runHiPrice) or srcHigh > runHiPrice
        runHiPrice := srcHigh
        runHiBar   := bar_index

// ── Pivot Detection ───────────────────────────────────────────────
ph = ta.pivothigh(srcHigh, pivotLen, pivotLen)
pl = ta.pivotlow(srcLow,  pivotLen, pivotLen)

if not na(ph) and not na(slBar)
    phBar   = bar_index[pivotLen]
    phPrice = ph
    if phBar > slBar and (na(peakPrice) or phPrice > peakPrice)
        peakBar   := phBar
        peakPrice := phPrice

if not na(pl)
    newBar   = bar_index[pivotLen]
    newPrice = pl

    if na(slBar)
        if na(lastATHBar) or newBar >= lastATHBar
            slBar      := newBar
            slPrice    := newPrice
            peakBar    := na
            peakPrice  := na
            runHiBar   := na
            runHiPrice := na

    else if newPrice < slPrice
        if not na(peakBar)
            count = peakBar - slBar
            if count >= minBars
                box.new(
                     slBar, peakPrice, peakBar, slPrice,
                     bgcolor      = boxColor,
                     border_color = borderColor,
                     border_width = 1)
                label.new(
                     lblX(slBar, peakBar),
                     lblY(slPrice, peakPrice),
                     str.tostring(count) + " bars",
                     xloc      = xloc.bar_index,
                     yloc      = yloc.price,
                     style     = lblStyle,
                     color     = color.new(color.black, 100),
                     textcolor = lblColor,
                     size      = sz)

        slBar      := newBar
        slPrice    := newPrice
        peakBar    := na
        peakPrice  := na
        runHiBar   := na
        runHiPrice := na

// ── Current (Unconfirmed) Bounce Box ──────────────────────────────
box.delete(curBox)
label.delete(curLbl)

if showCurrent and not na(slBar) and not newATH
    curTop   = na(runHiPrice) ? srcHigh  : runHiPrice
    curRight = na(runHiBar)   ? bar_index : runHiBar
    count    = curRight - slBar

    curBox := box.new(
         slBar, curTop, curRight, slPrice,
         bgcolor      = curFillColor,
         border_color = borderColor,
         border_width = 1)

    if count >= minBars
        curLbl := label.new(
             lblX(slBar, curRight),
             lblY(slPrice, curTop),
             str.tostring(count) + " bars",
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             style     = lblStyle,
             color     = color.new(color.black, 100),
             textcolor = lblColor,
             size      = sz)
````
