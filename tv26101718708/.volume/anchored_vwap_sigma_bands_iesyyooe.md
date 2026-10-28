# Anchored VWAP Sigma Bands

- url: https://www.tradingview.com/script/IESYYooE-Anchored-VWAP-Sigma-Bands/
- type: indicator
- pine_id: PUB;acdce06978724dfab8b80a37fc9eb5c8
- version: 1.0

## Description

Anchored VWAP Sigma Bands

1. Overview

https://www.tradingview.com/x/ctHhEPnm/

Anchored VWAP Sigma Bands is a chart-based analysis indicator that plots an Anchored Volume-Weighted Average Price together with volume-weighted standard deviation bands.

The purpose of the tool is to help traders study fair value, price extension, and distance from an anchored VWAP reference point.

This is an indicator, not a strategy. It does not place trades, does not execute orders, and does not produce TradingView Strategy Tester results. All levels are visual analytical references only and should not be treated as guaranteed support, resistance, reversal, or continuation signals.

2. Core Idea

Standard VWAP usually resets by session or period.

Anchored VWAP is different because it starts from a selected anchor point.

That anchor can represent an important market event, such as a major high, major low, selected date, start of a year, start of a month, start of a week, or a new highest/lowest level over a lookback window.

From that anchor point, the indicator calculates the volume-weighted average price.

This creates a reference for the average price traded since the selected anchor.

3. Anchored VWAP Line

https://www.tradingview.com/x/dwhxF57H/

The main blue line is the Anchored VWAP.

It represents the volume-weighted average price from the active anchor point.

A price above the anchored VWAP may suggest that price is trading above the volume-weighted fair value from that anchor.

A price below the anchored VWAP may suggest that price is trading below the volume-weighted fair value from that anchor.

This should be interpreted as context only. It does not guarantee future price direction.

4. Sigma Bands

The indicator calculates volume-weighted standard deviation from the anchored VWAP.

The sigma bands show how far price has moved from the anchored VWAP in statistical terms.

https://www.tradingview.com/x/PGkeTEYR/

The script can plot:

* +1 Sigma
* -1 Sigma
* +2 Sigma
* -2 Sigma
* +3 Sigma
* -3 Sigma

The +sigma bands are above the anchored VWAP.

The -sigma bands are below the anchored VWAP.

These bands can help identify areas where price is statistically extended relative to the anchored VWAP.

5. Band 1

Band 1 is the first standard deviation band.

By default, it uses 1.0 sigma.

This band can help users observe the normal upper and lower range around the anchored VWAP.

6. Band 2

Band 2 is the second standard deviation band.

By default, it uses 2.0 sigma.

This area can represent a stronger statistical extension from the anchored VWAP.

A move into the +2 or -2 sigma area does not guarantee reversal. It only shows that price is extended relative to the anchored VWAP calculation.

7. Band 3

Band 3 is optional and is OFF by default.

By default, it uses 3.0 sigma.

This band is intended for users who want to monitor deeper statistical extensions.

Because 3 sigma areas can be far away from price on some markets, this band is optional to keep the chart clean.

8. Anchor Modes

The indicator includes several anchor modes.

Manual date

The user selects a specific date and time as the anchor.

This is useful when anchoring VWAP to an important event, such as a major low, major high, breakout, earnings date, market cycle start, or a selected analysis date.

Year

The anchored VWAP resets at the start of each new year.

Month

The anchored VWAP resets at the start of each new month.

Week

The anchored VWAP resets at the start of each new week.

Highest high (N)

The anchor resets when price forms a new highest high over the selected lookback window.

This mode can be used to study dynamic resistance-based anchors.

Lowest low (N)

The anchor resets when price forms a new lowest low over the selected lookback window.

This mode can be used to study dynamic support-based anchors.

9. Dynamic Anchor Behavior

Dynamic anchor modes such as Highest high (N) and Lowest low (N) re-anchor when a new selected high or low forms.

This is expected behavior.

These modes are designed to update the anchored VWAP reference when the market creates a new extreme over the selected lookback.

Manual date mode is more static because the user chooses a fixed anchor date.

10. Anchor Marker

The indicator can display an anchor marker on the chart.

The anchor marker shows where the current anchored VWAP calculation begins.

To keep the chart clean, the script keeps only the most recent anchor marker visible.

Users can enable or disable the anchor marker from the settings.

11. Optional Anchor Line

The script includes an optional vertical anchor line.

When enabled, it marks the latest anchor point on the chart.

This option is OFF by default to keep the chart visually clean.

12. Volume-Weighted Calculation

The indicator uses volume in its VWAP and standard deviation calculations.

This means that higher-volume bars have more influence on the anchored VWAP and sigma bands.

If a symbol has no real volume data, the script uses a fallback value so the calculation can still display, but the result should not be interpreted the same way as a true volume-weighted calculation.

For best results, use symbols with reliable volume data.

13. Fill Zones

The indicator can fill the area between the bands.

The center fill helps show the main value area around anchored VWAP.

The upper fill highlights the area above the VWAP between sigma bands.

The lower fill highlights the area below the VWAP between sigma bands.

Users can turn the fill on or off in settings.

14. Alerts

The script includes alert conditions for:

* Price crossing above anchored VWAP
* Price crossing below anchored VWAP
* Price reaching the selected upper sigma band
* Price reaching the selected lower sigma band

Alerts are notifications only. They do not place orders and do not confirm broker execution.

15. How to Use

A practical workflow:

1. Select an anchor mode.

2. Use Manual date if you want to anchor VWAP to a specific event.

3. Use Year, Month, or Week if you want periodic VWAP references.

4. Use Highest high (N) or Lowest low (N) if you want dynamic anchor behavior.

5. Watch the anchored VWAP as the main fair-value reference.

6. Use sigma bands to observe statistical extension from the anchored VWAP.

7. Review +2 and -2 sigma areas as extension zones, not guaranteed reversal zones.

8. Combine the indicator with market structure, volume, support/resistance, trend context, and risk management.

9. Suggested Use Cases

Anchored VWAP Sigma Bands can be useful for:

* Anchored fair value analysis
* Event-based VWAP analysis
* Market cycle reference
* Volume-weighted mean analysis
* Statistical price extension
* Trend pullback context
* Support and resistance context
* Higher-timeframe analysis
* Manual anchor analysis from major highs or lows

17. Important Limitations

This indicator does not predict future price movement.

It does not guarantee reversals.

It does not guarantee continuations.

It does not guarantee profitable trades.

It is not a trading strategy.

It does not place orders.

It does not produce Strategy Tester results.

Anchored VWAP can act as a reference level, but price may move above or below it for extended periods.

Sigma bands show statistical distance, not guaranteed turning points.

Dynamic anchor modes can re-anchor when new highs or lows occur. This is expected behavior.

The quality of the calculation depends on the quality of volume data.

On symbols without reliable volume, the VWAP calculation may be less meaningful.

Users are responsible for their own trading decisions, risk management, and position sizing.

18. Originality and Purpose

Anchored VWAP Sigma Bands combines anchored VWAP analysis with volume-weighted standard deviation bands in a clean chart format.

The script includes:

* Multiple anchor modes
* Manual date anchor
* Periodic anchors
* Dynamic high/low anchors
* Volume-weighted VWAP calculation
* Volume-weighted sigma bands
* Optional anchor marker
* Optional anchor line
* Optional filled zones
* Alerts for VWAP crosses and sigma extension events

The purpose of the indicator is to provide a clear anchored fair-value map and statistical extension zones for chart analysis.

19. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users should perform their own analysis and manage risk independently.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Anchored VWAP Sigma Bands
// ============================================================================
// Anchored VWAP with volume-weighted standard-deviation bands.
//
// The VWAP is anchored to a selected event or period:
// - Manual date
// - Year
// - Month
// - Week
// - Highest high over N bars
// - Lowest low over N bars
//
// The bands show statistical distance from the anchored VWAP using
// volume-weighted standard deviation.
//
// This is an indicator, not a strategy.
// It does not place orders and does not produce Strategy Tester results.
//
// Note:
// Dynamic anchor modes such as Highest high (N) and Lowest low (N) re-anchor
// when a new selected high or low forms. This is expected behavior.
// ============================================================================

indicator("Anchored VWAP Sigma Bands", "aVWAP Sigma", overlay = true, max_labels_count = 100)

// ============================================================================
// Inputs
// ============================================================================

grpAnchor = "1) Anchor"

anchorMode = input.string(
     "Manual date",
     "Anchor",
     options = ["Manual date", "Year", "Month", "Week", "Highest high (N)", "Lowest low (N)"],
     group = grpAnchor)

anchorTime = input.time(
     timestamp("2024-01-01 00:00"),
     "Manual anchor date",
     group = grpAnchor,
     tooltip = "Used only when Anchor is set to Manual date.")

swingLen = input.int(
     50,
     "Swing lookback (N)",
     minval = 5,
     group = grpAnchor,
     tooltip = "Used by Highest high (N) and Lowest low (N) anchor modes.")

src = input.source(
     hlc3,
     "Source",
     group = grpAnchor)

grpBands = "2) Sigma Bands"

showB1 = input.bool(
     true,
     "Band 1",
     inline = "b1",
     group = grpBands)

m1 = input.float(
     1.0,
     "x",
     inline = "b1",
     step = 0.1,
     group = grpBands)

showB2 = input.bool(
     true,
     "Band 2",
     inline = "b2",
     group = grpBands)

m2 = input.float(
     2.0,
     "x",
     inline = "b2",
     step = 0.1,
     group = grpBands)

showB3 = input.bool(
     false,
     "Band 3",
     inline = "b3",
     group = grpBands)

m3 = input.float(
     3.0,
     "x",
     inline = "b3",
     step = 0.1,
     group = grpBands)

grpDisplay = "3) Display"

showFill = input.bool(
     true,
     "Fill bands",
     group = grpDisplay)

showAnchorMarker = input.bool(
     true,
     "Show anchor marker",
     group = grpDisplay,
     tooltip = "Shows the latest anchor point on the chart. Only the most recent anchor marker is kept to reduce clutter.")

anchorMarkerText = input.string(
     "A",
     "Anchor marker text",
     group = grpDisplay)

showAnchorLine = input.bool(
     false,
     "Show anchor vertical line",
     group = grpDisplay,
     tooltip = "Draws a vertical line at the latest anchor point. Only the latest anchor line is kept.")

lineLenBars = input.int(
     1,
     "Anchor line width",
     minval = 1,
     maxval = 4,
     group = grpDisplay)

// ============================================================================
// Palette
// ============================================================================

cUp = color.rgb(54, 168, 112)
cDn = color.rgb(205, 85, 95)
cMid = color.rgb(150, 158, 170)
cVw = color.rgb(120, 140, 210)

// ============================================================================
// Anchor detection
// ============================================================================

newAnchor = switch anchorMode
    "Manual date"      => time >= anchorTime and time[1] < anchorTime
    "Year"             => ta.change(year) != 0
    "Month"            => ta.change(month) != 0
    "Week"             => ta.change(weekofyear) != 0
    "Highest high (N)" => high > nz(ta.highest(high, swingLen)[1], high)
    => low < nz(ta.lowest(low, swingLen)[1], low)

// ============================================================================
// Cumulative volume-weighted sums
// ============================================================================

v = nz(volume) > 0 ? volume : 1.0

var float cumPV = na
var float cumV = na
var float cumPV2 = na
var int anchorBar = na
var float anchorPrice = na

resetAnchor = na(cumV) or newAnchor

if resetAnchor
    cumPV := 0.0
    cumV := 0.0
    cumPV2 := 0.0
    anchorBar := bar_index
    anchorPrice := src

cumPV += src * v
cumV += v
cumPV2 += src * src * v

vwap = cumV > 0 ? cumPV / cumV : na
variance = cumV > 0 ? math.max(cumPV2 / cumV - vwap * vwap, 0.0) : na
sd = math.sqrt(variance)

distSigma = sd > 0 ? (close - vwap) / sd : na

// ============================================================================
// Anchor marker / line
// ============================================================================

var label anchorLabel = na
var line anchorLine = na

if resetAnchor
    if not na(anchorLabel)
        label.delete(anchorLabel)

    if not na(anchorLine)
        line.delete(anchorLine)

    if showAnchorMarker
        anchorLabel := label.new(
             bar_index,
             low,
             anchorMarkerText,
             yloc = yloc.belowbar,
             style = label.style_label_up,
             color = color.new(cVw, 20),
             textcolor = color.white,
             size = size.tiny,
             tooltip = "Anchored VWAP starts here")

    if showAnchorLine
        anchorLine := line.new(
             bar_index,
             low,
             bar_index,
             high,
             xloc = xloc.bar_index,
             extend = extend.both,
             color = color.new(cVw, 60),
             style = line.style_dotted,
             width = lineLenBars)

// ============================================================================
// Plots
// ============================================================================

pV = plot(
     vwap,
     "Anchored VWAP",
     color = cVw,
     linewidth = 2)

u1 = plot(
     showB1 ? vwap + m1 * sd : na,
     "+1 Sigma",
     color = color.new(cDn, 55))

l1 = plot(
     showB1 ? vwap - m1 * sd : na,
     "-1 Sigma",
     color = color.new(cUp, 55))

u2 = plot(
     showB2 ? vwap + m2 * sd : na,
     "+2 Sigma",
     color = color.new(cDn, 45))

l2 = plot(
     showB2 ? vwap - m2 * sd : na,
     "-2 Sigma",
     color = color.new(cUp, 45))

u3 = plot(
     showB3 ? vwap + m3 * sd : na,
     "+3 Sigma",
     color = color.new(cDn, 35),
     style = plot.style_circles)

l3 = plot(
     showB3 ? vwap - m3 * sd : na,
     "-3 Sigma",
     color = color.new(cUp, 35),
     style = plot.style_circles)

fill(
     u1,
     l1,
     color = showFill and showB1 ? color.new(cVw, 92) : na,
     title = "Inner Sigma Fill")

fill(
     u2,
     u1,
     color = showFill and showB2 ? color.new(cDn, 92) : na,
     title = "Upper Sigma Fill")

fill(
     l1,
     l2,
     color = showFill and showB2 ? color.new(cUp, 92) : na,
     title = "Lower Sigma Fill")

// ============================================================================
// Alerts
// ============================================================================

crossAboveVWAP = ta.crossover(close, vwap)
crossBelowVWAP = ta.crossunder(close, vwap)

reachedUpperSigma = not na(distSigma) and distSigma >= m2 and distSigma[1] < m2
reachedLowerSigma = not na(distSigma) and distSigma <= -m2 and distSigma[1] > -m2

alertcondition(
     crossAboveVWAP,
     title = "Cross above aVWAP",
     message = "Anchored VWAP Sigma Bands: price crossed above the anchored VWAP")

alertcondition(
     crossBelowVWAP,
     title = "Cross below aVWAP",
     message = "Anchored VWAP Sigma Bands: price crossed below the anchored VWAP")

alertcondition(
     reachedUpperSigma,
     title = "Reached upper sigma band",
     message = "Anchored VWAP Sigma Bands: price reached the selected upper sigma band")

alertcondition(
     reachedLowerSigma,
     title = "Reached lower sigma band",
     message = "Anchored VWAP Sigma Bands: price reached the selected lower sigma band")

// ============================================================================
// End of file
// ============================================================================
````
