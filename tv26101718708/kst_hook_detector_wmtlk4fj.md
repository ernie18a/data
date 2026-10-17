# KST Hook Detector

- url: https://www.tradingview.com/script/wMtlK4fJ-KST-Hook-Detector/
- type: indicator
- pine_id: PUB;2d5713c647d545dd988183909e3f76b8
- version: 1.0

## Description

Looks for V patterns in the KST oscillator which sometimes signal V tops and bottoms

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KST Hook Pattern Detector

//@version=6
indicator("KST Hook Detector", shorttitle="KST-Hook", overlay=false, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────
// ░░░  INPUTS  ░░░
// ─────────────────────────────────────────────────────────────

// KST ROC Lengths
rocLen1  = input.int(10,  "ROC Length 1",   minval=1, group="KST Settings")
rocLen2  = input.int(15,  "ROC Length 2",   minval=1, group="KST Settings")
rocLen3  = input.int(20,  "ROC Length 3",   minval=1, group="KST Settings")
rocLen4  = input.int(30,  "ROC Length 4",   minval=1, group="KST Settings")

// KST SMA Smoothing Lengths
smaLen1  = input.int(10,  "SMA Length 1",   minval=1, group="KST Settings")
smaLen2  = input.int(10,  "SMA Length 2",   minval=1, group="KST Settings")
smaLen3  = input.int(10,  "SMA Length 3",   minval=1, group="KST Settings")
smaLen4  = input.int(15,  "SMA Length 4",   minval=1, group="KST Settings")

// KST Signal Line
sigLen   = input.int(9,   "Signal Length",  minval=1, group="KST Settings")

// Pivot Detection
pivotLeft   = input.int(5,  "Pivot Lookback Left",   minval=1, group="Hook Detection")
pivotRight  = input.int(5,  "Pivot Lookback Right",  minval=1, group="Hook Detection")

// Hook Filters
maxWidthBars  = input.int(100, "Max Hook Width (bars)",   minval=10,  group="Hook Filters", tooltip="Maximum bars from first point to last point")
minWidthBars  = input.int(8,   "Min Hook Width (bars)",   minval=4,   group="Hook Filters", tooltip="Minimum bars from first point to last point")
botTolerance  = input.float(30, "Bottom/Top Tolerance (%)", minval=1.0, maxval=100.0, group="Hook Filters", tooltip="How similar the two endpoints must be")
maxBumpPct    = input.float(50, "Max Bump Height (%)",      minval=5.0, maxval=200.0, group="Hook Filters", tooltip="Max height of the middle bump relative to the avg depth of the endpoints from zero. Lower = shallower hooks only")

// Visual Settings
showLines     = input.bool(true,  "Show Hook Lines",  group="Visuals")
showLabels    = input.bool(true,  "Show Labels",       group="Visuals")
bullColor     = input.color(color.new(#00bcd4, 0), "Bullish Hook Color", group="Visuals")
bearColor     = input.color(color.new(#e91e63, 0), "Bearish Hook Color", group="Visuals")

// ─────────────────────────────────────────────────────────────
// ░░░  KST CALCULATION  ░░░
// ─────────────────────────────────────────────────────────────

roc1 = ta.sma(ta.roc(close, rocLen1), smaLen1)
roc2 = ta.sma(ta.roc(close, rocLen2), smaLen2)
roc3 = ta.sma(ta.roc(close, rocLen3), smaLen3)
roc4 = ta.sma(ta.roc(close, rocLen4), smaLen4)

kst    = roc1 * 1 + roc2 * 2 + roc3 * 3 + roc4 * 4
signal = ta.sma(kst, sigLen)
hist   = kst - signal

// ─────────────────────────────────────────────────────────────
// ░░░  KST PLOTTING  ░░░
// ─────────────────────────────────────────────────────────────

kstColor = kst >= signal ? #26a69a : #ef5350
plot(kst,    "KST",       color=color.new(#2196f3, 0), linewidth=2)
plot(signal, "Signal",    color=color.new(#ff6d00, 0), linewidth=1)
plot(hist,   "Histogram", color=kstColor, style=plot.style_columns)
hline(0, "Zero", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// ─────────────────────────────────────────────────────────────
// ░░░  PIVOT DETECTION ON KST  ░░░
// ─────────────────────────────────────────────────────────────

pivotHigh = ta.pivothigh(kst, pivotLeft, pivotRight)
pivotLow  = ta.pivotlow(kst,  pivotLeft, pivotRight)

// ─────────────────────────────────────────────────────────────
// ░░░  BULLISH HOOK (B1 → P → B2)  — entirely below zero  ░░░
// ─────────────────────────────────────────────────────────────
// Pirate-hook shape: shallow bump, B1 and B2 are lows, P is a
// small peak between them. All three points must be < 0.
// P must NOT rise too far above B1/B2 (controlled by maxBumpPct).

var int   wState     = 0
var float b1Val      = na
var int   b1Bar      = na
var float wPeakVal   = na
var int   wPeakBar   = na

bullHook = false

// ── Pivot lows → B1 and B2 candidates ──
if not na(pivotLow)
    pivBar = bar_index - pivotRight
    pivVal = pivotLow

    if wState == 0
        if pivVal < 0
            b1Val  := pivVal
            b1Bar  := pivBar
            wState := 1

    else if wState == 1
        // Another low before any peak — keep the deeper one
        if pivVal < 0 and pivVal < b1Val
            b1Val := pivVal
            b1Bar := pivBar

    else if wState == 2
        // Candidate B2
        widthBars = pivBar - b1Bar

        // All below zero
        allBelow = pivVal < 0 and b1Val < 0 and wPeakVal < 0

        // Width bounds
        validWidth = widthBars >= minWidthBars and widthBars <= maxWidthBars

        // Endpoint similarity
        avgDepth   = (math.abs(b1Val) + math.abs(pivVal)) / 2.0
        range_bp   = math.abs(wPeakVal - math.min(b1Val, pivVal))
        tolBand    = range_bp * (botTolerance / 100.0)
        validBot   = math.abs(pivVal - b1Val) <= tolBand

        // Peak above both bottoms
        validPeak  = wPeakVal > b1Val and wPeakVal > pivVal

        // Shallow bump: how far P rises above the avg bottom depth
        // bumpHeight = distance from avg bottom to P
        bumpHeight = wPeakVal - (b1Val + pivVal) / 2.0
        maxBump    = avgDepth * (maxBumpPct / 100.0)
        validBump  = bumpHeight <= maxBump

        if allBelow and validWidth and validBot and validPeak and validBump
            if showLines
                line.new(b1Bar, b1Val, wPeakBar, wPeakVal,
                     color=bullColor, width=2, xloc=xloc.bar_index)
                line.new(wPeakBar, wPeakVal, pivBar, pivVal,
                     color=bullColor, width=2, xloc=xloc.bar_index)

            if showLabels
                label.new(b1Bar, b1Val, "B1",
                     style=label.style_circle, color=bullColor,
                     textcolor=color.white, size=size.small, xloc=xloc.bar_index)
                label.new(wPeakBar, wPeakVal, "P",
                     style=label.style_circle, color=bullColor,
                     textcolor=color.white, size=size.small, xloc=xloc.bar_index)
                label.new(pivBar, pivVal, "B2",
                     style=label.style_circle, color=bullColor,
                     textcolor=color.white, size=size.small, xloc=xloc.bar_index)

            bullHook := true

            // Reset
            wState   := 0
            b1Val    := na
            b1Bar    := na
            wPeakVal := na
            wPeakBar := na
        else
            // Failed — recycle as new B1 if below zero
            if pivVal < 0
                b1Val    := pivVal
                b1Bar    := pivBar
                wPeakVal := na
                wPeakBar := na
                wState   := 1
            else
                wState   := 0
                b1Val    := na
                b1Bar    := na
                wPeakVal := na
                wPeakBar := na

// ── Pivot highs → P candidate (for bullish hook) ──
if not na(pivotHigh)
    pivBar = bar_index - pivotRight
    pivVal = pivotHigh

    if wState == 1
        if pivVal > b1Val and pivVal < 0
            wPeakVal := pivVal
            wPeakBar := pivBar
            wState   := 2

    else if wState == 2
        // Another peak before B2 — keep the higher one (still must be < 0)
        if pivVal > wPeakVal and pivVal < 0
            wPeakVal := pivVal
            wPeakBar := pivBar

// ─────────────────────────────────────────────────────────────
// ░░░  BEARISH HOOK (T1 → V → T2)  — entirely above zero  ░░░
// ─────────────────────────────────────────────────────────────
// Inverted pirate-hook: shallow dip, T1 and T2 are highs, V is
// a small valley between them. All three points must be > 0.
// V must NOT dip too far below T1/T2 (controlled by maxBumpPct).

var int   mState     = 0
var float t1Val      = na
var int   t1Bar      = na
var float mValleyVal = na
var int   mValleyBar = na

bearHook = false

// ── Pivot highs → T1 and T2 candidates ──
if not na(pivotHigh)
    mPivBar = bar_index - pivotRight
    mPivVal = pivotHigh

    if mState == 0
        if mPivVal > 0
            t1Val  := mPivVal
            t1Bar  := mPivBar
            mState := 1

    else if mState == 1
        // Another high before any valley — keep the higher one
        if mPivVal > 0 and mPivVal > t1Val
            t1Val := mPivVal
            t1Bar := mPivBar

    else if mState == 2
        // Candidate T2
        mWidthBars = mPivBar - t1Bar

        // All above zero
        allAbove = mPivVal > 0 and t1Val > 0 and mValleyVal > 0

        // Width bounds
        mValidWidth = mWidthBars >= minWidthBars and mWidthBars <= maxWidthBars

        // Endpoint similarity
        avgHeight  = (t1Val + mPivVal) / 2.0
        mRange     = math.abs(mValleyVal - math.max(t1Val, mPivVal))
        mTolBand   = mRange * (botTolerance / 100.0)
        mValidTop  = math.abs(mPivVal - t1Val) <= mTolBand

        // Valley below both tops
        mValidVal  = mValleyVal < t1Val and mValleyVal < mPivVal

        // Shallow dip: how far V drops below the avg top height
        dipDepth   = (t1Val + mPivVal) / 2.0 - mValleyVal
        maxDip     = avgHeight * (maxBumpPct / 100.0)
        mValidBump = dipDepth <= maxDip

        if allAbove and mValidWidth and mValidTop and mValidVal and mValidBump
            if showLines
                line.new(t1Bar, t1Val, mValleyBar, mValleyVal,
                     color=bearColor, width=2, xloc=xloc.bar_index)
                line.new(mValleyBar, mValleyVal, mPivBar, mPivVal,
                     color=bearColor, width=2, xloc=xloc.bar_index)

            if showLabels
                label.new(t1Bar, t1Val, "T1",
                     style=label.style_circle, color=bearColor,
                     textcolor=color.white, size=size.small, xloc=xloc.bar_index)
                label.new(mValleyBar, mValleyVal, "V",
                     style=label.style_circle, color=bearColor,
                     textcolor=color.white, size=size.small, xloc=xloc.bar_index)
                label.new(mPivBar, mPivVal, "T2",
                     style=label.style_circle, color=bearColor,
                     textcolor=color.white, size=size.small, xloc=xloc.bar_index)

            bearHook := true

            // Reset
            mState     := 0
            t1Val      := na
            t1Bar      := na
            mValleyVal := na
            mValleyBar := na
        else
            // Failed — recycle as new T1 if above zero
            if mPivVal > 0
                t1Val      := mPivVal
                t1Bar      := mPivBar
                mValleyVal := na
                mValleyBar := na
                mState     := 1
            else
                mState     := 0
                t1Val      := na
                t1Bar      := na
                mValleyVal := na
                mValleyBar := na

// ── Pivot lows → V candidate (for bearish hook) ──
if not na(pivotLow)
    mPivBar = bar_index - pivotRight
    mPivVal = pivotLow

    if mState == 1
        if mPivVal < t1Val and mPivVal > 0
            mValleyVal := mPivVal
            mValleyBar := mPivBar
            mState     := 2

    else if mState == 2
        // Another valley before T2 — keep the deeper one (still must be > 0)
        if mPivVal < mValleyVal and mPivVal > 0
            mValleyVal := mPivVal
            mValleyBar := mPivBar

// ─────────────────────────────────────────────────────────────
// ░░░  HOOK SIGNALS ON MAIN CHART  ░░░
// ─────────────────────────────────────────────────────────────

plotshape(bullHook ? low[pivotRight] : na, "Bull Hook", shape.triangleup, location.absolute,
     color.new(#4caf50, 0), size=size.tiny, offset=-pivotRight, force_overlay=true)

plotshape(bearHook ? high[pivotRight] : na, "Bear Hook", shape.triangledown, location.absolute,
     color.new(#e91e63, 0), size=size.tiny, offset=-pivotRight, force_overlay=true)
````
