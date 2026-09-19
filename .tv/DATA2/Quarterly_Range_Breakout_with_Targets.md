<!-- tradingview-pine-id: PUB;27b07e7162ce4d73b306d994905e014b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Quarterly Range Breakout with Targets

Source: https://www.tradingview.com/script/BVDP21OU-Quarterly-Range-Breakout-with-Targets/

## Description

Quarterly Range Breakout with Targets

Quarterly Range Breakout with Targets is a higher-timeframe market-structure indicator designed to show how price interacts with the previous quarter’s range and how far price may expand once that range begins to break.

At the start of each new calendar quarter, the indicator automatically identifies the completed previous quarter’s:

High
Low
50% midpoint

Those levels are then projected across the current quarter.

The indicator also calculates customizable Fibonacci-based expansion targets above and below the previous quarter’s range.

Each quarter remains visually independent, with its own range levels, targets, labels, and quarter divider.

The Idea Behind the Indicator

The concept is based on a simple market-structure question:

How does the current quarter behave relative to the range established during the previous quarter?

Intraday traders often use opening ranges, previous-day highs and lows, session ranges, and similar reference levels.

Quarterly Range Breakout applies that same idea to a much larger timeframe.

Instead of asking:

“Where is price relative to today’s opening range?”

the indicator asks:

“Where is price relative to the previous three months of price discovery?”

The completed quarter becomes the reference range.

The new quarter then shows whether price:

[*]remains inside that range
[*]rejects the boundaries
[*]rotates around the midpoint
[*]breaks above the high
[*]breaks below the low
[*]expands beyond the range

The goal is not to predict price direction.

The goal is to create a clean structural map and then observe what price actually does around those levels.

Previous Quarter Range

The indicator automatically calculates three core levels.

Previous Quarter High

This is the highest price reached during the completed quarter.

It may act as:

[*]resistance
[*]breakout level
[*]retest level
[*]support after a successful breakout

Previous Quarter Midpoint

The midpoint is calculated as:

(Previous Quarter High + Previous Quarter Low) ÷ 2

This represents the 50% point of the previous quarter’s range.

It can help identify whether price is operating in the upper or lower half of that range.

Above the midpoint, price is trading in the upper half.

Below the midpoint, price is trading in the lower half.

The midpoint may also act as an area of balance, support, resistance, or transition.

Previous Quarter Low

This is the lowest price reached during the completed quarter.

It may act as:

[*]support
[*]breakdown level
[*]retest level
[*]resistance after a successful breakdown

Quarterly Expansion Targets

The target system is based on the size of the completed previous quarter.

First, the indicator calculates:

Quarterly Range = Previous Quarter High − Previous Quarter Low

That range is then used to project expansion targets above and below the original range.

For example, a 1.618 target above the range is calculated using:

Previous Quarter Low + (Quarterly Range × 1.618)

The equivalent downside target is mirrored below the range:

Previous Quarter High − (Quarterly Range × 1.618)

This creates symmetrical expansion levels above and below the previous quarter.

The default target levels include:

[*]1.618
[*]2.618
[*]3.618
[*]4.236
[*]

Additional customizable target slots are also included.

The Fib numbers can be changed manually, allowing traders to test other expansion ratios.

Why Use Range-Based Targets?

The purpose of the target system is not to suggest that price must stop exactly at a Fibonacci number.

Instead, the targets provide a structured way to measure how far price expands relative to the range that existed before the move.

A completed quarter represents roughly three months of price discovery.

If price breaks outside that range, the previous quarter provides an objective measurement unit for evaluating the size of the expansion.

For example:

Previous quarter range = 100 points.

A move to the 1.618 level means price has traveled approximately 1.618 times the size of that previous quarterly range from the opposite side of the range.

This creates a consistent framework that can be compared across different assets and different price levels.

How to Use the Indicator

The indicator can be used as a market-structure framework rather than a standalone entry signal.

A trader might first ask:

Where is price relative to the previous quarter?

Above the high
Inside the range
Below the low

Then:

How is price behaving around the boundary?

Rejecting
Breaking
Retesting
Consolidating
Accepting outside the range

If price breaks above the previous-quarter high, the upside Fib levels can provide objective expansion areas to monitor.

If price breaks below the previous-quarter low, the downside Fib levels can provide the same type of structure.

Example Bullish Sequence

A possible bullish progression might look like:

Previous-quarter high is tested
→ Price closes above the high
→ Price holds above the range
→ Previous-quarter high is retested
→ Buyers continue higher
→ Price begins moving toward the next expansion target

The Fib targets can then act as areas where traders monitor:

[*]slowing momentum
[*]rejection
[*]consolidation
[*]profit taking
[*]continuation through the level

Example Bearish Sequence

A bearish sequence may look like:

Previous-quarter midpoint fails
→ Price enters the lower half of the range
→ Previous-quarter low breaks
→ Price remains below the range
→ The low is retested from underneath
→ Selling continues toward lower expansion targets

Again, the targets are reference levels rather than guaranteed turning points.

Quarter-by-Quarter Structure

Each quarter is visually separated by a vertical divider.

All range levels and targets:

begin with the current quarter
remain inside that quarter
stop at the end of the quarter

When the next quarter begins, the indicator automatically calculates a completely new range based on the quarter that just finished.

This keeps historical structure clean and makes it easy to study how each quarter behaved relative to the one before it.

Customization

The indicator includes extensive visual customization.

Users can change:

[*]Previous Quarter High color
[*]Previous Quarter High thickness
[*]Previous Quarter High line style
[*]Previous Quarter Midpoint color
[*]Previous Quarter Midpoint thickness
[*]Previous Quarter Midpoint line style
[*]Previous Quarter Low color
[*]Previous Quarter Low thickness
[*]Previous Quarter Low line style
[*]Quarter divider color
[*]Quarter divider thickness
[*]Quarter divider style
[*]Fib target colors
[*]Fib target thickness
[*]Fib target line style
[*]Individual Fib numbers
[*]Which Fib targets are displayed
[*]Upside targets
[*]Downside targets
[*]Fib label visibility
[*]Fib label size
[*]Fib label placement
[*]Fib label spacing

Fib labels remain inside the quarter they belong to so the chart remains visually organized.

Best Use

The indicator is designed primarily for higher-timeframe analysis, especially the Daily chart.

It can be applied to many different markets, including:

[*]Stocks
[*]ETFs
[*]Futures
[*]Forex
[*]Indices
[*]Cryptocurrencies

Different markets have different volatility characteristics, so traders should test the concept independently on the instruments they trade.

The Thought Process Behind Quarterly Range Breakout

The indicator is intentionally simple.

It is built around one core principle:

The previous quarter defines the range.
The current quarter reveals the reaction.
The targets measure the expansion.

Rather than filling the chart with many indicators, Quarterly Range Breakout focuses on a small number of objective price levels.

Those levels provide the structure.

Price action provides the information.

The trader decides what to do with it.

---

## Source Code

````pine
//@version=6
indicator("Quarterly Range Breakout with Targets", shorttitle="QRB Targets", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// QUARTERLY RANGE BREAKOUT WITH TARGETS
// Previous quarter High / Mid / Low + mirrored Fibonacci extension targets.
// Each quarter is self-contained: all horizontal levels begin at the start
// of the quarter and stop at the end of that quarter.
// ============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// PREVIOUS QUARTER HIGH
// ─────────────────────────────────────────────────────────────────────────────
groupHigh = "Previous Quarter High"
highColor = input.color(color.lime, "Color", group=groupHigh)
highWidth = input.int(2, "Line Thickness", minval=1, maxval=5, group=groupHigh)
highStyleInput = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupHigh)
highStyle = highStyleInput == "Solid" ? line.style_solid : highStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// ─────────────────────────────────────────────────────────────────────────────
// PREVIOUS QUARTER MIDPOINT
// ─────────────────────────────────────────────────────────────────────────────
groupMid = "Previous Quarter Midpoint"
midColor = input.color(color.white, "Color", group=groupMid)
midWidth = input.int(2, "Line Thickness", minval=1, maxval=5, group=groupMid)
midStyleInput = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupMid)
midStyle = midStyleInput == "Solid" ? line.style_solid : midStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// ─────────────────────────────────────────────────────────────────────────────
// PREVIOUS QUARTER LOW
// ─────────────────────────────────────────────────────────────────────────────
groupLow = "Previous Quarter Low"
lowColor = input.color(color.fuchsia, "Color", group=groupLow)
lowWidth = input.int(2, "Line Thickness", minval=1, maxval=5, group=groupLow)
lowStyleInput = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupLow)
lowStyle = lowStyleInput == "Solid" ? line.style_solid : lowStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// ─────────────────────────────────────────────────────────────────────────────
// QUARTER DIVIDER LINES
// ─────────────────────────────────────────────────────────────────────────────
groupQuarter = "Quarter Divider Lines"
showQuarterLines = input.bool(true, "Show Quarter Divider Lines", group=groupQuarter)
quarterLineColor = input.color(color.gray, "Color", group=groupQuarter)
quarterLineWidth = input.int(1, "Line Thickness", minval=1, maxval=5, group=groupQuarter)
quarterLineStyleInput = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupQuarter)
quarterLineStyle = quarterLineStyleInput == "Solid" ? line.style_solid : quarterLineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// ─────────────────────────────────────────────────────────────────────────────
// FIBONACCI EXTENSION TARGET SETTINGS
// The ratio uses the completed previous-quarter range.
//
// Example for a 1.618 ratio:
// Upper target = Previous Low + (Quarter Range × 1.618)
// Lower target = Previous High - (Quarter Range × 1.618)
//
// Therefore, 1.000 equals the opposite edge of the original range,
// while values above 1.000 project outside the range.
// ─────────────────────────────────────────────────────────────────────────────
groupFibGeneral = "Fib Targets - General"
showUpperFib = input.bool(true, "Show Targets Above High", group=groupFibGeneral)
showLowerFib = input.bool(true, "Show Targets Below Low", group=groupFibGeneral)
fibWidth = input.int(1, "Line Thickness", minval=1, maxval=5, group=groupFibGeneral)
fibStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupFibGeneral)
fibStyle = fibStyleInput == "Solid" ? line.style_solid : fibStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// Fib target labels
showFibLabels = input.bool(true, "Show Fib Number Labels", group=groupFibGeneral)
fibLabelPosition = input.string("On Line", "Label Position", options=["Above", "On Line", "Below"], group=groupFibGeneral)
fibLabelSizeInput = input.string("Small", "Label Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupFibGeneral)
fibLabelOffsetPct = input.float(1.0, "Above/Below Offset (% of Quarter Range)", minval=0.0, step=0.1, group=groupFibGeneral)
fibLabelSize = fibLabelSizeInput == "Tiny" ? size.tiny : fibLabelSizeInput == "Small" ? size.small : fibLabelSizeInput == "Normal" ? size.normal : fibLabelSizeInput == "Large" ? size.large : size.huge

groupFib1 = "Fib Target 1"
fib1Show = input.bool(true, "Show", group=groupFib1)
fib1Ratio = input.float(1.618, "Fib Number", minval=1.0, step=0.001, group=groupFib1)
fib1Color = input.color(color.blue, "Color", group=groupFib1)

groupFib2 = "Fib Target 2"
fib2Show = input.bool(true, "Show", group=groupFib2)
fib2Ratio = input.float(2.618, "Fib Number", minval=1.0, step=0.001, group=groupFib2)
fib2Color = input.color(color.red, "Color", group=groupFib2)

groupFib3 = "Fib Target 3"
fib3Show = input.bool(true, "Show", group=groupFib3)
fib3Ratio = input.float(3.618, "Fib Number", minval=1.0, step=0.001, group=groupFib3)
fib3Color = input.color(color.purple, "Color", group=groupFib3)

groupFib4 = "Fib Target 4"
fib4Show = input.bool(true, "Show", group=groupFib4)
fib4Ratio = input.float(4.236, "Fib Number", minval=1.0, step=0.001, group=groupFib4)
fib4Color = input.color(color.fuchsia, "Color", group=groupFib4)

groupFib5 = "Fib Target 5"
fib5Show = input.bool(false, "Show", group=groupFib5)
fib5Ratio = input.float(1.272, "Fib Number", minval=1.0, step=0.001, group=groupFib5)
fib5Color = input.color(color.orange, "Color", group=groupFib5)

groupFib6 = "Fib Target 6"
fib6Show = input.bool(false, "Show", group=groupFib6)
fib6Ratio = input.float(2.000, "Fib Number", minval=1.0, step=0.001, group=groupFib6)
fib6Color = input.color(color.aqua, "Color", group=groupFib6)

// ─────────────────────────────────────────────────────────────────────────────
// PREVIOUS QUARTER DATA
// ─────────────────────────────────────────────────────────────────────────────
prevQuarterHigh = request.security(
     syminfo.tickerid,
     "3M",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

prevQuarterLow = request.security(
     syminfo.tickerid,
     "3M",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

prevQuarterMid = (prevQuarterHigh + prevQuarterLow) / 2.0
prevQuarterRange = prevQuarterHigh - prevQuarterLow

// Label vertical placement. "Above" and "Below" use a small percentage
// of the completed previous-quarter range so the spacing scales with price.
fibLabelOffset = prevQuarterRange * (fibLabelOffsetPct / 100.0)
fibLabelYShift = fibLabelPosition == "Above" ? fibLabelOffset : fibLabelPosition == "Below" ? -fibLabelOffset : 0.0

currentQuarterStart = time("3M")
currentQuarterEnd = time_close("3M")
isNewQuarter = timeframe.change("3M")
drawQuarter = isNewQuarter or barstate.isfirst

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATE MIRRORED FIB TARGETS
// ─────────────────────────────────────────────────────────────────────────────
fib1Upper = prevQuarterLow + (prevQuarterRange * fib1Ratio)
fib1Lower = prevQuarterHigh - (prevQuarterRange * fib1Ratio)

fib2Upper = prevQuarterLow + (prevQuarterRange * fib2Ratio)
fib2Lower = prevQuarterHigh - (prevQuarterRange * fib2Ratio)

fib3Upper = prevQuarterLow + (prevQuarterRange * fib3Ratio)
fib3Lower = prevQuarterHigh - (prevQuarterRange * fib3Ratio)

fib4Upper = prevQuarterLow + (prevQuarterRange * fib4Ratio)
fib4Lower = prevQuarterHigh - (prevQuarterRange * fib4Ratio)

fib5Upper = prevQuarterLow + (prevQuarterRange * fib5Ratio)
fib5Lower = prevQuarterHigh - (prevQuarterRange * fib5Ratio)

fib6Upper = prevQuarterLow + (prevQuarterRange * fib6Ratio)
fib6Lower = prevQuarterHigh - (prevQuarterRange * fib6Ratio)

// ─────────────────────────────────────────────────────────────────────────────
// DRAW QUARTER DIVIDER
// ─────────────────────────────────────────────────────────────────────────────
if drawQuarter and showQuarterLines
    line.new(
         x1=currentQuarterStart,
         y1=low,
         x2=currentQuarterStart,
         y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=quarterLineColor,
         width=quarterLineWidth,
         style=quarterLineStyle)

// ─────────────────────────────────────────────────────────────────────────────
// DRAW PREVIOUS QUARTER HIGH / MID / LOW
// ─────────────────────────────────────────────────────────────────────────────
if drawQuarter and not na(prevQuarterHigh) and not na(prevQuarterLow)
    line.new(
         x1=currentQuarterStart,
         y1=prevQuarterHigh,
         x2=currentQuarterEnd,
         y2=prevQuarterHigh,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=highColor,
         width=highWidth,
         style=highStyle)

    line.new(
         x1=currentQuarterStart,
         y1=prevQuarterMid,
         x2=currentQuarterEnd,
         y2=prevQuarterMid,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=midColor,
         width=midWidth,
         style=midStyle)

    line.new(
         x1=currentQuarterStart,
         y1=prevQuarterLow,
         x2=currentQuarterEnd,
         y2=prevQuarterLow,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=lowColor,
         width=lowWidth,
         style=lowStyle)

// ─────────────────────────────────────────────────────────────────────────────
// DRAW FIB TARGETS + FIB NUMBER LABELS
// Labels are anchored at the right end of each quarterly target line.
// label.style_label_right makes the text extend LEFT from the quarter-end
// anchor so every Fib number stays inside the quarter it belongs to.
// ─────────────────────────────────────────────────────────────────────────────
if drawQuarter and not na(prevQuarterRange) and prevQuarterRange > 0
    if fib1Show and showUpperFib
        line.new(x1=currentQuarterStart, y1=fib1Upper, x2=currentQuarterEnd, y2=fib1Upper, xloc=xloc.bar_time, extend=extend.none, color=fib1Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib1Upper + fibLabelYShift, text=str.tostring(fib1Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib1Color, 100), style=label.style_label_right, textcolor=fib1Color, size=fibLabelSize, textalign=text.align_right)
    if fib1Show and showLowerFib
        line.new(x1=currentQuarterStart, y1=fib1Lower, x2=currentQuarterEnd, y2=fib1Lower, xloc=xloc.bar_time, extend=extend.none, color=fib1Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib1Lower + fibLabelYShift, text=str.tostring(fib1Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib1Color, 100), style=label.style_label_right, textcolor=fib1Color, size=fibLabelSize, textalign=text.align_right)

    if fib2Show and showUpperFib
        line.new(x1=currentQuarterStart, y1=fib2Upper, x2=currentQuarterEnd, y2=fib2Upper, xloc=xloc.bar_time, extend=extend.none, color=fib2Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib2Upper + fibLabelYShift, text=str.tostring(fib2Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib2Color, 100), style=label.style_label_right, textcolor=fib2Color, size=fibLabelSize, textalign=text.align_right)
    if fib2Show and showLowerFib
        line.new(x1=currentQuarterStart, y1=fib2Lower, x2=currentQuarterEnd, y2=fib2Lower, xloc=xloc.bar_time, extend=extend.none, color=fib2Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib2Lower + fibLabelYShift, text=str.tostring(fib2Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib2Color, 100), style=label.style_label_right, textcolor=fib2Color, size=fibLabelSize, textalign=text.align_right)

    if fib3Show and showUpperFib
        line.new(x1=currentQuarterStart, y1=fib3Upper, x2=currentQuarterEnd, y2=fib3Upper, xloc=xloc.bar_time, extend=extend.none, color=fib3Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib3Upper + fibLabelYShift, text=str.tostring(fib3Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib3Color, 100), style=label.style_label_right, textcolor=fib3Color, size=fibLabelSize, textalign=text.align_right)
    if fib3Show and showLowerFib
        line.new(x1=currentQuarterStart, y1=fib3Lower, x2=currentQuarterEnd, y2=fib3Lower, xloc=xloc.bar_time, extend=extend.none, color=fib3Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib3Lower + fibLabelYShift, text=str.tostring(fib3Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib3Color, 100), style=label.style_label_right, textcolor=fib3Color, size=fibLabelSize, textalign=text.align_right)

    if fib4Show and showUpperFib
        line.new(x1=currentQuarterStart, y1=fib4Upper, x2=currentQuarterEnd, y2=fib4Upper, xloc=xloc.bar_time, extend=extend.none, color=fib4Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib4Upper + fibLabelYShift, text=str.tostring(fib4Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib4Color, 100), style=label.style_label_right, textcolor=fib4Color, size=fibLabelSize, textalign=text.align_right)
    if fib4Show and showLowerFib
        line.new(x1=currentQuarterStart, y1=fib4Lower, x2=currentQuarterEnd, y2=fib4Lower, xloc=xloc.bar_time, extend=extend.none, color=fib4Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib4Lower + fibLabelYShift, text=str.tostring(fib4Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib4Color, 100), style=label.style_label_right, textcolor=fib4Color, size=fibLabelSize, textalign=text.align_right)

    if fib5Show and showUpperFib
        line.new(x1=currentQuarterStart, y1=fib5Upper, x2=currentQuarterEnd, y2=fib5Upper, xloc=xloc.bar_time, extend=extend.none, color=fib5Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib5Upper + fibLabelYShift, text=str.tostring(fib5Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib5Color, 100), style=label.style_label_right, textcolor=fib5Color, size=fibLabelSize, textalign=text.align_right)
    if fib5Show and showLowerFib
        line.new(x1=currentQuarterStart, y1=fib5Lower, x2=currentQuarterEnd, y2=fib5Lower, xloc=xloc.bar_time, extend=extend.none, color=fib5Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib5Lower + fibLabelYShift, text=str.tostring(fib5Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib5Color, 100), style=label.style_label_right, textcolor=fib5Color, size=fibLabelSize, textalign=text.align_right)

    if fib6Show and showUpperFib
        line.new(x1=currentQuarterStart, y1=fib6Upper, x2=currentQuarterEnd, y2=fib6Upper, xloc=xloc.bar_time, extend=extend.none, color=fib6Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib6Upper + fibLabelYShift, text=str.tostring(fib6Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib6Color, 100), style=label.style_label_right, textcolor=fib6Color, size=fibLabelSize, textalign=text.align_right)
    if fib6Show and showLowerFib
        line.new(x1=currentQuarterStart, y1=fib6Lower, x2=currentQuarterEnd, y2=fib6Lower, xloc=xloc.bar_time, extend=extend.none, color=fib6Color, width=fibWidth, style=fibStyle)
        if showFibLabels
            label.new(x=currentQuarterEnd, y=fib6Lower + fibLabelYShift, text=str.tostring(fib6Ratio, "#.###"), xloc=xloc.bar_time, yloc=yloc.price, color=color.new(fib6Color, 100), style=label.style_label_right, textcolor=fib6Color, size=fibLabelSize, textalign=text.align_right)
````
