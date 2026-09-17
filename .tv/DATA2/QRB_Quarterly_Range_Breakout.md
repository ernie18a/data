<!-- tradingview-pine-id: PUB;9e081074f9364d7d9dc18ef928985f64 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# QRB - Quarterly Range Breakout

Source: https://www.tradingview.com/script/deDaKCXu-QRB-Quarterly-Break-Range/

## Description

QRB — Quarterly Break Range is a market-structure indicator designed to help traders visualize how price interacts with the previous quarter’s range.

At the beginning of each new calendar quarter, QRB automatically identifies the completed previous quarter’s:

[*]High
[*]Low
[*]50% midpoint

Those three levels are then projected across the current quarter, creating a simple structural map for price.

The indicator automatically updates when a new quarter begins, so there is no need to manually redraw the levels.

The Idea Behind QRB

The concept behind QRB comes from a simple observation:

Markets often react to important historical ranges.

Intraday traders commonly use concepts such as the Opening Range, previous-day high and low, session ranges, and other reference levels to understand where price is accepting, rejecting, or breaking away from prior value.

QRB applies that same thought process to a much larger timeframe.

Instead of asking:

“Where is price relative to today's opening range?”

QRB asks:

“Where is price relative to the previous quarter?”

The previous quarter becomes the reference range, while the current quarter shows how the market responds to that range.

This allows traders to study quarterly price behavior using only three objective levels.

Understanding the Three Levels

Previous Quarter High

The previous-quarter high represents the upper boundary of the completed quarterly range.

When price approaches this level, traders may watch for:

[*]Rejection
[*]Consolidation
[*]Breakout attempts
[*]Acceptance above the range
[*]Retests after a breakout

A sustained move above the previous-quarter high may indicate that the market is beginning to expand beyond the prior quarter's range.

Previous Quarter Midpoint

The midpoint is calculated as:

(Previous Quarter High + Previous Quarter Low) ÷ 2

This represents the 50% level of the previous quarter's range.

The midpoint can be useful as a simple measure of where price is trading relative to the prior quarter.

Price holding above the midpoint places it in the upper half of the previous quarter's range.

Price holding below the midpoint places it in the lower half.

The midpoint may also act as an important area of balance, support, resistance, or transition.

Previous Quarter Low

The previous-quarter low represents the lower boundary of the completed quarterly range.

When price approaches this area, traders may watch for:

[*]Support
[*]Rejection
[*]Consolidation
[*]Breakdown attempts
[*]Acceptance below the range
[*]Retests following a breakdown

A sustained move below the previous-quarter low may indicate that the market is expanding beneath the previous quarter's range.

How to Use QRB

QRB is primarily designed as a market-structure framework, not a standalone buy or sell signal.

The three quarterly levels can help answer a few simple questions:

Where is price?

[*]Above the previous quarter
[*]Inside the previous quarter
[*]Below the previous quarter

Which half of the prior range is price occupying?

[*]Above the midpoint
[*]Below the midpoint

How is price reacting to the boundaries?

[*]Breaking
[*]Rejecting
[*]Retesting
[*]Consolidating
[*]Accepting beyond the range

That information can then be combined with a trader's existing approach to trend, momentum, price action, support and resistance, volume, or other forms of confirmation.

Example Market Behaviors

One possible bullish sequence could look like:

Previous-quarter high is tested
→ Price breaks above it
→ Price remains above the level
→ The level is retested
→ Buyers continue pushing price higher

A possible bearish sequence could look like:

Previous-quarter midpoint fails
→ Price moves into the lower half of the range
→ Previous-quarter low breaks
→ Price remains below the range
→ Selling pressure continues

Another possible scenario is simple rejection:

Price reaches the previous-quarter high
→ Fails to gain acceptance above it
→ Moves back inside the range
→ Rotates toward the midpoint

QRB does not attempt to predict which scenario will occur.

It simply provides the structural levels needed to observe what price actually does.

Why Quarterly Ranges?

Calendar quarters are natural market periods.

Each quarter contains roughly three months of price discovery and can represent a significant amount of accumulated positioning and market activity.

Rather than treating each daily candle independently, QRB allows traders to step back and see price within a broader structural framework.

The previous quarter essentially becomes a large reference range.

The current quarter then answers the question:

Will price remain inside that range, reject its boundaries, or expand beyond it?

That is the central idea behind QRB.

Best Use

QRB was designed primarily for higher-timeframe analysis, especially the Daily chart.

It may be useful across different markets, including:

[*]Stocks
[*]Forex
[*]Futures
[*]Indices
[*]Cryptocurrencies

Because different markets behave differently, traders should evaluate the concept independently on the instruments they trade.

Customization

QRB allows users to customize the appearance of each level, including:

[*]Previous Quarter High color
[*]Previous Quarter High thickness
[*]Midpoint color
[*]Midpoint thickness
[*]Previous Quarter Low color
[*]Previous Quarter Low thickness

This allows the quarterly structure to remain visible without overwhelming the chart.

The Philosophy Behind QRB

QRB is intentionally simple.

There are no complicated calculations, predictive algorithms, or large collections of indicators.

The purpose is to create a clean structural map and allow price action to provide the information.

The core idea is:

Previous quarter = reference range

Current quarter = reaction to that range

From there, the trader observes whether price accepts, rejects, breaks, retests, or rotates around those levels.

Sometimes three well-defined levels can tell you more about market structure than twenty indicators ever could.

---

## Source Code

````pine
//@version=6
indicator("QRB - Quarterly Range Breakout", shorttitle="QRB", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────────────────────────
// USER SETTINGS
// ─────────────────────────────────────────────────────────────

// Previous Quarter High
groupHigh = "Previous Quarter High"
highColor = input.color(color.lime, "Color", group=groupHigh)
highWidth = input.int(2, "Line Thickness", minval=1, maxval=5, group=groupHigh)
highStyleInput = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupHigh)
highStyle = highStyleInput == "Solid" ? line.style_solid : highStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// Previous Quarter Midpoint
groupMid = "Previous Quarter Midpoint"
midColor = input.color(color.white, "Color", group=groupMid)
midWidth = input.int(2, "Line Thickness", minval=1, maxval=5, group=groupMid)
midStyleInput = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupMid)
midStyle = midStyleInput == "Solid" ? line.style_solid : midStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// Previous Quarter Low
groupLow = "Previous Quarter Low"
lowColor = input.color(color.fuchsia, "Color", group=groupLow)
lowWidth = input.int(2, "Line Thickness", minval=1, maxval=5, group=groupLow)
lowStyleInput = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupLow)
lowStyle = lowStyleInput == "Solid" ? line.style_solid : lowStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// Quarter Divider Lines
groupQuarter = "Quarter Divider Lines"
showQuarterLines = input.bool(true, "Show Quarter Divider Lines", group=groupQuarter)
quarterLineColor = input.color(color.gray, "Color", group=groupQuarter)
quarterLineWidth = input.int(1, "Line Thickness", minval=1, maxval=5, group=groupQuarter)
quarterLineStyleInput = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupQuarter)
quarterLineStyle = quarterLineStyleInput == "Solid" ? line.style_solid : quarterLineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// ─────────────────────────────────────────────────────────────
// PREVIOUS QUARTER DATA
// ─────────────────────────────────────────────────────────────
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

// Current calendar quarter timestamps.
currentQuarterStart = time("3M")
currentQuarterEnd = time_close("3M")
isNewQuarter = timeframe.change("3M")
drawQuarter = isNewQuarter or barstate.isfirst

// ─────────────────────────────────────────────────────────────
// DRAW QUARTER DIVIDER
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// DRAW PREVIOUS QUARTER HIGH / MID / LOW
// ─────────────────────────────────────────────────────────────
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
````
