# Advance Range Detector

- url: https://www.tradingview.com/script/qGaz8m1K-Advance-Range-Detector/
- type: indicator
- pine_id: PUB;801e65c6b5b540dca235d153db116252
- version: 1.0

## Description

Advance Range Detector 
[url=https://www.tradingview.com/u/Michael_Fx_Trader/]https://www.tradingview.com/u/Michael_Fx_Trader/[/url]

What This Indicator Is

Advance Range Detector automatically finds the moments when price stops trending and starts moving sideways inside a box, watches that box while it is alive, and then tells you the moment it finally breaks out upward or downward, including telling you when a breakout was actually a fake and price came straight back inside. Nothing has to be drawn by hand. Every rectangle you see on the chart is a consolidation the indicator itself detected, sized, and is actively tracking using a rule based method rather than a subjective eyeball guess.

[image]https://www.tradingview.com/x/UTr6g4mg/[/image]

Why It Was Built

Manually spotting and drawing ranges is one of the most subjective tasks in chart reading. Two traders looking at the exact same consolidation will draw two different boxes with two different boundaries, and neither can really defend their choice with anything more than a feeling. This tool exists to replace that guesswork with a defined, repeatable process built from volatility, how many times price actually tests each side of the box, how much it zig zags inside, and how flat the average price stays across the window, so that the box on your chart is the output of a rule set rather than a hand drawn opinion, and so that a breakout or a fakeout gets flagged the same way every single time.

[image]https://www.tradingview.com/x/IcEtvlFq/[/image]

How It Works

At every candle, the indicator does not commit to one fixed length of lookback. It tests a base window, and optionally a double length and a triple length window as well, and whichever of these is the longest one that actually satisfies every requirement becomes the range, which is why you will see consolidations of noticeably different sizes on the same chart rather than one forced uniform length. For each window being tested, a candidate top and bottom boundary is calculated using whichever method you choose: a percentile band, which uses a high percentile of the highs and a mirrored percentile of the lows so one random spike cannot define the whole box, absolute extremes, which simply uses the single highest high and lowest low, or body extremes, which ignores wicks entirely and only looks at open and close prices for very wick heavy instruments.

Once a candidate box exists, five separate checks have to pass together before it is accepted as a real range. First, tightness: the box's height is measured in units of average true range and ranked against a rolling history of how tall recent candidate boxes on this exact symbol and timeframe have been, so it only qualifies if it is meaningfully tighter than what this market has recently produced. Second, rotation: the number of times price crosses back and forth across the box's own midpoint is counted, since a genuine range crosses its middle many times while a sharp spike barely crosses it once, which is what stops a V shaped reversal from being mistaken for a range just because it happened to look tight. Third, touches: the top and bottom boundaries are each checked separately for a minimum number of times price actually reached them, because a real range gets defended on both sides repeatedly, not poked once on each end. Fourth, drift: the average price of the first half of the window is compared to the second half, and if the tilt between them is too strong relative to the box's height, the structure is rejected as a channel or a trend rather than a range. Fifth, containment: the percentage of closing prices that actually stayed between the two boundaries is measured, since a box that price keeps slicing straight through was never really respecting it as a box.

Only when all five checks pass at once does a qualified range exist, and even then the box is not simply drawn around the small window that was tested. Instead its left edge walks backward bar by bar, checking whether earlier candles also stayed inside the very same boundaries, extending the box further back until it fully captures where the consolidation actually began, up to a limit you control. A freshly detected range starts in a provisional state with a dashed border, meaning the indicator is not yet fully confident it will hold, and only after it has survived a minimum number of bars does it flip to a confirmed, solid border; a break during the provisional stage is simply deleted with no marker at all, since it was never treated as an established range, while a break after confirmation is what actually produces a labeled signal.

You control whether a breakout requires a full candle close beyond the boundary, which ignores quick wick spikes, or whether any wick poking through at all counts immediately, and either way a buffer distance measured in average true range must be cleared before a break is accepted, filtering out marginal one tick pokes. A related feature called absorb overshoot prevents a range from being killed off by a single small wick: if a candle's body still closes back inside the box but its wick only pokes out by a small allowed amount, the boundary simply stretches outward to include that wick and the same range keeps living, rather than ending it and immediately starting a nearly identical new box a few ticks away. When a genuine, confirmed breakout does happen, the box locks its final shape, recolors to your bullish or bearish color depending on direction, updates its label with the final bar count and the height as a percentage of price, and places a labeled Breakout marker on the triggering candle. From there, an optional merge deviations feature holds that broken range in a brief waiting window; if price closes back inside the old boundaries before that window runs out, the breakout is treated as a fakeout, the marker is removed, a new Deviation marker is placed exactly at the extreme of the failed wick, and the very same range simply continues as if the breakout had never truly happened. If price does not come back in time, the range is considered properly finished. After any range ends, a short cooldown period stops the explosive candles that often follow a real breakout from being immediately misread as the start of a brand new tiny range, and an optional maximum age setting can force a range to retire on its own after a certain number of bars even if it is never actually broken.

[image]https://www.tradingview.com/x/hC8OInGB/[/image]

How To Read The Chart

Every detected range is drawn as a shaded rectangle labeled directly above it with how many bars it lasted and what percentage of price its height represents. A dotted line running through the exact middle of the box is the equilibrium line, the same midline the indicator uses internally to count rotations, and two fainter dotted lines nearer the top and bottom mark the twenty five and seventy five percent levels of the range, useful for judging whether price sitting inside the box is still near the middle or already stretched toward an edge. A dashed border means the range is still provisional and unconfirmed; a solid border means it has been accepted as established. A colored arrow labeled Breakout marks the exact candle and direction where a confirmed range finally gave way, using your chosen bullish or bearish color, while a Deviation label marks a spot where a breakout briefly happened and then reversed straight back inside, revealing that move as a trap rather than a genuine trend change. A neutral, uncolored box with no Breakout marker yet is simply a range that is still open and unresolved as of the current candle.


How To Use It For Analysis

Use the box boundaries themselves as the levels that matter, the top as resistance and the bottom as support for as long as the range stays open, and watch the equilibrium and quartile lines to judge whether a bounce inside the range is happening near the middle or is already stretched toward an edge and due for a reaction. Treat a dashed, provisional box with caution since it has not yet proven itself, and give more weight to a solid, confirmed one. When a genuine Breakout marker appears, that is the indicator's read that the sideways phase has actually ended in that direction; if a Deviation label appears shortly afterward instead, that tells you the initial break was a trap and the prior range is still very much alive, which is valuable information for anyone who might have reacted to the original break too quickly. As always, this indicator defines and tracks structure mechanically, it does not replace your own judgment about the wider trend, other levels on the chart, or your own risk management before acting on any range, breakout, or deviation it shows you.

What The Indicator Draws On The Chart

For every range, you will see the shaded box itself in either the neutral color while unresolved or the bullish or bearish color once broken, a text label above it stating how many bars it has lasted and its height as a percentage of price, a dotted equilibrium line through its exact middle, and two fainter dotted lines marking its twenty five and seventy five percent levels. A confirmed range's border is solid while a fresh, provisional one is dashed. When a range is genuinely broken, a colored Breakout label appears on the triggering candle, placed below the candle for an upward break and above it for a downward break; if that break then fails and price returns inside the old boundaries in time, a Deviation label replaces it at the exact extreme of the failed wick, and the original range's box simply keeps extending forward as if nothing had happened.

Settings Worth Knowing Before Use

The base window length and whether double and triple length windows are also tested, the boundary calculation method and its percentile setting, the average true range length and how large the tightness history and its required percentile are, the minimum number of midline rotations, the touch tolerance and minimum touches required on each side, the maximum allowed drift and minimum required containment, how far the box is allowed to extend backward in search of the true start of the consolidation, how many bars are required before a range is considered confirmed, whether a breakout needs a full close or just a wick along with its buffer distance, the absorb overshoot allowance, whether merge deviations is enabled and how long its waiting window is, the cooldown period after a range ends, the optional maximum age, and every color used can all be adjusted from the indicator's settings panel to suit different instruments, timeframes, and personal preferences.

Disclaimer

This indicator is a technical analysis tool and does not constitute financial advice. A detected range, a Breakout marker, or a Deviation marker each describe a specific, mechanical pattern in past and current price action, not a guarantee of what price will do next. All trading involves risk, and past behavior around a range does not guarantee future results. Always use proper risk management and combine this tool with your own analysis before entering any trade.

Original Script Declaration

Script Name: Advance Range Detector
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights: Copyright Michael_Fx_Trader. All rights reserved.

Originality Statement: This is an original work, designed and coded from scratch by Michael_Fx_Trader. The multi window scanning engine, which tests a base window and optional double and triple length windows and keeps the longest one that qualifies, the five condition qualification system built from volatility ranked tightness against a rolling history of prior candidate heights, midline rotation counting, separate top and bottom touch counting, drift measurement, and close containment percentage, the backward box extension that walks earlier bars to capture the true start of the consolidation, the provisional to confirmed state transition, the close or wick breakout modes with an average true range buffer, the absorb overshoot boundary stretching logic, the merge deviations fakeout revival system with its own waiting window, the post range cooldown, and the optional maximum age retirement were all independently conceived and implemented for this publication. No proprietary source code, private scripts, or copyrighted material belonging to any other author has been copied, mashed up, or reused in any part of this script.

Author Verification and Declaration: I, Michael_Fx_Trader, am the sole author and publisher of this script. I hold full authorship rights over its source code, its underlying logic, and its visual presentation. Support and resistance ranges, average true range, and percentile based price bands are all well known, generic public domain technical analysis concepts not owned by any individual author. Only the specific detection, qualification, extension, breakout, and fakeout revival logic built around them here is original to this script, and nothing in this script was copied or adapted from another author's published work.

## Source Code

````pine
//@version=6

// =============================================================================
//                         ORIGINAL SCRIPT DECLARATION
// =============================================================================
// Script Name   : Advance Range Detector
// Author        : Michael_Fx_Trader
// Publisher     : Michael_Fx_Trader
// Rights        : © Michael_Fx_Trader. All rights reserved.
//
// Originality Statement:
//   This is an original work, designed and coded from scratch by
//   Michael_Fx_Trader. The multi-window scanning engine (which tests a base
//   window and optional double/triple length windows and keeps the longest
//   one that qualifies), the five-condition qualification system (volatility-
//   ranked tightness against a rolling history of prior candidate heights,
//   midline rotation counting, separate top/bottom touch counting, drift
//   measurement, and close-containment percentage), the backward box
//   extension that walks earlier bars to capture the true start of the
//   consolidation, the provisional-to-confirmed state transition, the close
//   or wick breakout modes with an ATR buffer, the absorb-overshoot boundary
//   stretching logic, the merge-deviation fakeout revival system with its own
//   waiting window, the post-range cooldown, and the optional maximum-age
//   retirement were all independently conceived and implemented for this
//   publication. No proprietary source code, private scripts, or copyrighted
//   material belonging to any other author has been copied, mashed-up, or
//   reused in any part of this script.
//
// Author Verification / Declaration:
//   I, Michael_Fx_Trader, am the sole author and publisher of this script.
//   I hold full authorship rights over its source code, its underlying logic,
//   and its visual presentation. Support/resistance ranges, ATR, and
//   percentile-based price bands are well-known, generic public-domain
//   technical-analysis concepts not owned by any individual author; only the
//   specific detection, qualification, extension, breakout, and fakeout-
//   revival logic built around them here is original to this script.
// =============================================================================

indicator("Advance Range Detector", shorttitle = "Adv Range", overlay = true,
     max_boxes_count = 50, max_lines_count = 150, max_labels_count = 200)

// =============================================================================
// INPUTS
// =============================================================================

grpWindow = "Window Sizes"
baseWindow = input.int(20, "Base Window (bars)", minval = 5, group = grpWindow)
useDouble  = input.bool(true, "Also Test Double-Length Window", group = grpWindow)
useTriple  = input.bool(true, "Also Test Triple-Length Window", group = grpWindow,
     tooltip = "The longest window that qualifies is always used, so a smaller consolidation is never forced to look bigger, and a bigger one is never chopped down.")

grpBoundary = "Boundary Method"
boundaryMethod = input.string("Percentile", "Boundary Method", options = ["Percentile", "Absolute Extremes", "Body Extremes"], group = grpBoundary)
topPercentile = input.float(90, "Percentile Band (Percentile Method Only)", minval = 50, maxval = 100, group = grpBoundary,
     tooltip = "Top boundary uses this percentile of highs; bottom boundary uses the mirrored percentile of lows (100 minus this value), which ignores a single outlier spike.")

grpTight = "Tightness (Volatility Ranking)"
atrLen = input.int(14, "ATR Length", minval = 1, group = grpTight)
tightnessLookback = input.int(100, "Tightness History Size", minval = 10, group = grpTight,
     tooltip = "How many recently tested candidate box heights (in ATR units) are kept to judge whether a new candidate is unusually tight for this symbol and timeframe.")
tightnessPercentile = input.float(30, "Must Be Tighter Than This Percentile", minval = 5, maxval = 95, group = grpTight)

grpRotation = "Rotation"
minRotations = input.int(4, "Minimum Midline Crossings", minval = 1, group = grpRotation,
     tooltip = "A real range crosses its own midpoint many times; a sharp spike barely crosses it. This filters out V-shaped reversals that happen to look tight.")

grpTouch = "Boundary Touches"
touchToleranceAtr = input.float(0.15, "Touch Tolerance (x ATR)", minval = 0.0, step = 0.05, group = grpTouch)
minTouchesEachSide = input.int(2, "Minimum Touches on Each Side", minval = 1, group = grpTouch)

grpDrift = "Drift / Containment"
maxDriftPct = input.float(30, "Max Drift (% of Box Height)", minval = 0, group = grpDrift,
     tooltip = "Compares the average price of the first half of the window to the second half; too much tilt means it was a channel or trend, not a range.")
minContainmentPct = input.float(80, "Minimum Containment (% of Closes Inside)", minval = 50, maxval = 100, group = grpDrift)

grpExtend = "Backward Extension"
maxBackwardExtension = input.int(100, "Max Extra Bars to Look Back", minval = 0, group = grpExtend,
     tooltip = "Once a window qualifies, the box's left edge walks further back bar by bar as long as earlier closes also stayed inside the same boundaries, up to this many extra bars.")

grpConfirm = "Confirmation"
minConfirmBars = input.int(5, "Bars Before a Range Is Confirmed", minval = 1, group = grpConfirm,
     tooltip = "While a range is younger than this, it is provisional (dashed border) and a break simply deletes it quietly. Once confirmed (solid border), a break produces a labeled Breakout marker.")

grpBreak = "Breakout"
breakoutMode = input.string("Close", "Breakout Confirmation", options = ["Close", "Wick"], group = grpBreak,
     tooltip = "Close: a candle must fully close beyond the boundary. Wick: any wick beyond the boundary counts immediately.")
bufferAtr = input.float(0.1, "Breakout Buffer (x ATR)", minval = 0, step = 0.05, group = grpBreak,
     tooltip = "Price must clear the boundary by this many ATR beyond it before a break is accepted, filtering out marginal one-tick pokes.")

grpAbsorb = "Absorb Overshoot"
useAbsorb = input.bool(true, "Enable Absorb Overshoot", group = grpAbsorb,
     tooltip = "If a candle's body still closes back inside the box but its wick pokes out by a small amount, the boundary stretches to include that wick instead of ending the range.")
overshootAllowanceAtr = input.float(0.15, "Overshoot Allowance (x ATR)", minval = 0, step = 0.05, group = grpAbsorb)

grpDeviation = "Merge Deviations (Fakeout Handling)"
useMergeDeviation = input.bool(true, "Enable Merge Deviations", group = grpDeviation)
deviationWindowBars = input.int(5, "Waiting Window After Breakout (bars)", minval = 1, group = grpDeviation,
     tooltip = "After a confirmed breakout, if price closes back inside the range within this many bars, the breakout is treated as a fakeout: the marker is replaced with a Deviation label and the same range continues.")

grpCooldown = "Cooldown / Max Age"
cooldownBars = input.int(5, "Cooldown After a Range Ends (bars)", minval = 0, group = grpCooldown)
useMaxAge = input.bool(false, "Enable Maximum Age", group = grpCooldown)
maxAgeBars = input.int(200, "Maximum Age (bars)", minval = 10, group = grpCooldown)

grpColors = "Colors"
neutralColor = input.color(color.new(color.gray, 0), "Unresolved Range Color", group = grpColors)
bullColor    = input.color(color.new(color.green, 0), "Upward Breakout Color", group = grpColors)
bearColor    = input.color(color.new(color.red, 0), "Downward Breakout Color", group = grpColors)
deviationColor = input.color(color.new(color.teal, 0), "Deviation Marker Color", group = grpColors)

// =============================================================================
// CORE VALUES
// =============================================================================

atrVal = ta.atr(atrLen)

var float[] heightHistory = array.new_float()

// =============================================================================
// BOUNDARY + QUALIFICATION TEST FOR ONE WINDOW SIZE
// =============================================================================

f_boundaries(windowSize) =>
    float t = na
    float b = na
    if boundaryMethod == "Percentile"
        t := ta.percentile_linear_interpolation(high, windowSize, topPercentile)
        b := ta.percentile_linear_interpolation(low, windowSize, 100 - topPercentile)
    else if boundaryMethod == "Absolute Extremes"
        t := ta.highest(high, windowSize)
        b := ta.lowest(low, windowSize)
    else
        t := ta.highest(math.max(open, close), windowSize)
        b := ta.lowest(math.min(open, close), windowSize)
    [t, b]

f_testWindow(windowSize) =>
    [t, b] = f_boundaries(windowSize)
    height = t - b
    mid = (t + b) / 2.0
    heightAtr = atrVal > 0 ? height / atrVal : 999.0

    histSize = array.size(heightHistory)
    greaterCount = 0
    if histSize > 0
        for k = 0 to histSize - 1
            if array.get(heightHistory, k) > heightAtr
                greaterCount += 1
    pctRank = histSize > 0 ? (greaterCount / histSize) * 100.0 : 0.0
    tightOk = histSize < 10 ? true : pctRank <= tightnessPercentile

    rotations = 0
    topTouches = 0
    bottomTouches = 0
    containedCount = 0
    sumFirstHalf = 0.0
    sumSecondHalf = 0.0
    halfLen = math.max(1, windowSize / 2)
    prevSide = 0
    for k = windowSize - 1 to 0
        c = close[k]
        h = high[k]
        l = low[k]
        side = c > mid ? 1 : c < mid ? -1 : 0
        if prevSide != 0 and side != 0 and side != prevSide
            rotations += 1
        if side != 0
            prevSide := side
        if h >= t - touchToleranceAtr * atrVal
            topTouches += 1
        if l <= b + touchToleranceAtr * atrVal
            bottomTouches += 1
        if c <= t and c >= b
            containedCount += 1
        if k >= windowSize - halfLen
            sumFirstHalf += c
        else
            sumSecondHalf += c

    containmentPct = containedCount / windowSize * 100.0
    firstAvg = sumFirstHalf / halfLen
    secondAvg = sumSecondHalf / math.max(1, windowSize - halfLen)
    driftPct = height > 0 ? math.abs(secondAvg - firstAvg) / height * 100.0 : 100.0

    qualifies = tightOk and rotations >= minRotations and topTouches >= minTouchesEachSide and
         bottomTouches >= minTouchesEachSide and driftPct <= maxDriftPct and containmentPct >= minContainmentPct

    array.push(heightHistory, heightAtr)
    if array.size(heightHistory) > tightnessLookback
        array.shift(heightHistory)

    [qualifies, t, b]

// =============================================================================
// RANGE STATE
// =============================================================================

var string rangeState = "NONE"   // "NONE", "ACTIVE", "WAITING"
var float  rTop        = na
var float  rBottom     = na
var int    rStartBar   = na
var bool   rConfirmed  = false
var int    rBarsAlive  = 0
var int    cooldownCounter = 0
var int    waitCounter = 0
var int    breakDir    = 0
var float  breakExtreme = na
var int    breakBar    = na

var box   rangeBox    = na
var line  midLine     = na
var line  q25Line     = na
var line  q75Line     = na
var label rangeLabel  = na
var label breakoutLabel = na

// =============================================================================
// STATE: NONE - COOLDOWN OR SCAN FOR A NEW RANGE
// =============================================================================

if rangeState == "NONE"
    if cooldownCounter > 0
        cooldownCounter -= 1
    else
        windowToUse = 0
        topUse = float(na)
        bottomUse = float(na)

        if useTriple and windowToUse == 0
            [q3, t3, b3] = f_testWindow(baseWindow * 3)
            if q3
                windowToUse := baseWindow * 3
                topUse := t3
                bottomUse := b3
        if useDouble and windowToUse == 0
            [q2, t2, b2] = f_testWindow(baseWindow * 2)
            if q2
                windowToUse := baseWindow * 2
                topUse := t2
                bottomUse := b2
        if windowToUse == 0
            [q1, t1, b1] = f_testWindow(baseWindow)
            if q1
                windowToUse := baseWindow
                topUse := t1
                bottomUse := b1

        if windowToUse > 0
            containTol = touchToleranceAtr * atrVal
            extStart = bar_index - windowToUse + 1
            lookExtra = 0
            keepGoing = true
            while lookExtra < maxBackwardExtension and keepGoing
                checkOffset = windowToUse + lookExtra
                if checkOffset >= bar_index
                    keepGoing := false
                else
                    cCheck = close[checkOffset]
                    if cCheck <= topUse + containTol and cCheck >= bottomUse - containTol
                        lookExtra += 1
                    else
                        keepGoing := false

            finalStart = extStart - lookExtra
            midVal = (topUse + bottomUse) / 2.0
            q75Val = bottomUse + (topUse - bottomUse) * 0.75
            q25Val = bottomUse + (topUse - bottomUse) * 0.25

            rangeBox := box.new(finalStart, topUse, bar_index, bottomUse, border_color = neutralColor,
                 border_style = line.style_dashed, border_width = 1, bgcolor = color.new(neutralColor, 85))
            midLine := line.new(finalStart, midVal, bar_index, midVal, color = color.new(neutralColor, 0), style = line.style_dotted)
            q75Line := line.new(finalStart, q75Val, bar_index, q75Val, color = color.new(neutralColor, 60), style = line.style_dotted)
            q25Line := line.new(finalStart, q25Val, bar_index, q25Val, color = color.new(neutralColor, 60), style = line.style_dotted)
            rangeLabel := label.new(finalStart, topUse, "RANGE " + str.tostring(bar_index - finalStart + 1) + " BARS  " +
                 str.tostring((topUse - bottomUse) / close * 100, "#.##") + "%", style = label.style_label_down,
                 color = color.new(color.black, 100), textcolor = neutralColor, size = size.small)

            rTop := topUse
            rBottom := bottomUse
            rStartBar := finalStart
            rConfirmed := false
            rBarsAlive := 0
            rangeState := "ACTIVE"

// =============================================================================
// STATE: ACTIVE - EXTEND, CONFIRM, ABSORB OR BREAK, MAX AGE
// =============================================================================

if rangeState == "ACTIVE"
    rBarsAlive += 1
    if not rConfirmed and rBarsAlive >= minConfirmBars
        rConfirmed := true
        box.set_border_style(rangeBox, line.style_solid)

    box.set_right(rangeBox, bar_index)
    line.set_x2(midLine, bar_index)
    line.set_x2(q25Line, bar_index)
    line.set_x2(q75Line, bar_index)

    bufferDist = bufferAtr * atrVal
    overshootDist = overshootAllowanceAtr * atrVal

    wickOvershootUp   = high > rTop and high <= rTop + overshootDist and close <= rTop
    wickOvershootDown = low < rBottom and low >= rBottom - overshootDist and close >= rBottom

    upBreach   = breakoutMode == "Close" ? close > rTop + bufferDist   : high > rTop + bufferDist
    downBreach = breakoutMode == "Close" ? close < rBottom - bufferDist : low < rBottom - bufferDist

    if useAbsorb and wickOvershootUp
        rTop := high
        box.set_top(rangeBox, rTop)
        newMid = (rTop + rBottom) / 2.0
        newQ75 = rBottom + (rTop - rBottom) * 0.75
        newQ25 = rBottom + (rTop - rBottom) * 0.25
        line.set_y1(midLine, newMid)
        line.set_y2(midLine, newMid)
        line.set_y1(q75Line, newQ75)
        line.set_y2(q75Line, newQ75)
        line.set_y1(q25Line, newQ25)
        line.set_y2(q25Line, newQ25)
    else if useAbsorb and wickOvershootDown
        rBottom := low
        box.set_bottom(rangeBox, rBottom)
        newMid2 = (rTop + rBottom) / 2.0
        newQ75b = rBottom + (rTop - rBottom) * 0.75
        newQ25b = rBottom + (rTop - rBottom) * 0.25
        line.set_y1(midLine, newMid2)
        line.set_y2(midLine, newMid2)
        line.set_y1(q75Line, newQ75b)
        line.set_y2(q75Line, newQ75b)
        line.set_y1(q25Line, newQ25b)
        line.set_y2(q25Line, newQ25b)
    else if upBreach or downBreach
        dir = upBreach ? 1 : -1
        if not rConfirmed
            box.delete(rangeBox)
            line.delete(midLine)
            line.delete(q25Line)
            line.delete(q75Line)
            label.delete(rangeLabel)
            rangeState := "NONE"
            cooldownCounter := cooldownBars
        else
            finalColor = dir == 1 ? bullColor : bearColor
            box.set_border_color(rangeBox, finalColor)
            box.set_bgcolor(rangeBox, color.new(finalColor, 80))
            totalBars = bar_index - rStartBar + 1
            heightPct = (rTop - rBottom) / close * 100
            label.set_text(rangeLabel, "RANGE " + str.tostring(totalBars) + " BARS  " + str.tostring(heightPct, "#.##") + "%")
            label.set_textcolor(rangeLabel, finalColor)
            breakoutLabel := label.new(bar_index, dir == 1 ? low : high, "Breakout",
                 style = dir == 1 ? label.style_label_up : label.style_label_down,
                 color = color.new(finalColor, 0), textcolor = color.white, size = size.small)
            breakDir := dir
            breakExtreme := dir == 1 ? high : low
            breakBar := bar_index
            if useMergeDeviation
                rangeState := "WAITING"
                waitCounter := 0
            else
                rangeState := "NONE"
                cooldownCounter := cooldownBars

    if rangeState == "ACTIVE" and useMaxAge and rBarsAlive >= maxAgeBars
        box.set_right(rangeBox, bar_index)
        line.set_x2(midLine, bar_index)
        line.set_x2(q25Line, bar_index)
        line.set_x2(q75Line, bar_index)
        rangeState := "NONE"
        cooldownCounter := cooldownBars

// =============================================================================
// STATE: WAITING - CHECK FOR A FAKEOUT REVIVAL OR LET THE BREAK STAND
// =============================================================================

if rangeState == "WAITING"
    waitCounter += 1
    if close <= rTop and close >= rBottom
        label.delete(breakoutLabel)
        label.new(breakBar, breakExtreme, "Deviation",
             style = breakDir == 1 ? label.style_label_down : label.style_label_up,
             color = color.new(deviationColor, 0), textcolor = color.white, size = size.small)
        rangeState := "ACTIVE"
        box.set_border_color(rangeBox, neutralColor)
        box.set_bgcolor(rangeBox, color.new(neutralColor, 85))
        box.set_right(rangeBox, bar_index)
        line.set_x2(midLine, bar_index)
        line.set_x2(q25Line, bar_index)
        line.set_x2(q75Line, bar_index)
    else if waitCounter >= deviationWindowBars
        rangeState := "NONE"
        cooldownCounter := cooldownBars

// =============================================================================
// ALERTS
// =============================================================================

newRangeDetected = rangeState == "ACTIVE" and rBarsAlive == 1
alertcondition(newRangeDetected, title = "New Range Detected", message = "Advance Range Detector: a new range was detected.")
````
