# Auto Trendline Breaks

- url: https://www.tradingview.com/script/AvvB4ZNT-Auto-Trendline-Breaks/
- type: indicator
- pine_id: PUB;3eee6d636e694f2ca37bfe81d2ad8a3b
- version: 1.0

## Description

Auto Trendline Breaks

Auto Trendline Breaks is a visual trendline analysis indicator that automatically detects confirmed swing highs and swing lows, builds validated support and resistance trendlines from those pivot points, and marks close-through trendline break events on the chart.

The purpose of this script is to reduce manual trendline drawing and help traders monitor diagonal support, diagonal resistance, confirmed pivot structure, and trendline break events in a more systematic way.

This script is an indicator, not a trading strategy. It does not place orders, does not calculate backtest results, and does not guarantee that any trendline break will lead to continuation or profit. It is designed for visual chart analysis, structure monitoring, and alert-based observation only.

Important note about signals

Auto Trendline Breaks does not generate direct buy or sell signals.

The labels and markers shown by the script are technical structure markers only. They are designed to show confirmed pivots, validated trendlines, and close-through break events.

Confirmed Peak markers are not sell signals.
Confirmed Trough markers are not buy signals.
BRK R labels are not buy signals.
BRK S labels are not sell signals.

The script does not provide trade entries, trade exits, stop-loss levels, take-profit levels, or strategy performance results. Any trading decision must come from the user’s own analysis, confirmation method, and risk-management process.

Important note about repainting and pivot delay

The Confirmed Peak and Confirmed Trough markers are based on confirmed pivot logic.

A pivot high or pivot low is only confirmed after the selected number of Pivot Right Bars has passed. For that reason, the marker appears with a natural confirmation delay.

After a pivot marker is confirmed and printed, it is not intended to move from that pivot bar. However, the marker is plotted back on the original pivot candle using an offset, so it should not be interpreted as a real-time signal that was known on that historical candle.

For example, if Pivot Right Bars is set to 10, the script needs 10 bars after a possible peak or trough before confirming it. Once confirmed, the marker is plotted on the original pivot candle for visual clarity.

This behavior is normal for pivot-based indicators. It helps identify confirmed swing structure, but it also means these markers are delayed structure markers, not real-time entry signals.

Main visual elements

The script focuses on four main visual elements:

1. Confirmed Peak markers

2. Confirmed Trough markers

3. Resistance and support trendlines

4. BRK R / BRK S trendline break labels

5. Confirmed Peak markers

A Confirmed Peak marker appears above a candle when the script confirms a swing high using pivot logic.

A swing high is confirmed only after the required number of bars has formed to the right of the potential pivot. This creates a natural delay, which is expected behavior for pivot-based indicators.

Confirmed Peak markers are used by the script as potential resistance anchor points.

They may appear in the Style tab as:

* Confirmed Peak Tiny
* Confirmed Peak Small
* Confirmed Peak Normal

These three Style entries exist because TradingView displays each plotshape used for different marker sizes. The user controls the active marker size from the indicator settings using the Pivot Marker Size input. Only the selected marker size is intended to be visible on the chart.

Confirmed Peak markers are not sell signals. They only identify confirmed swing highs used by the trendline engine.

2. Confirmed Trough markers

A Confirmed Trough marker appears below a candle when the script confirms a swing low using pivot logic.

A swing low is confirmed only after the required number of bars has formed to the right of the potential pivot. This creates a natural delay, which is expected behavior for pivot-based indicators.

Confirmed Trough markers are used by the script as potential support anchor points.

They may appear in the Style tab as:

* Confirmed Trough Tiny
* Confirmed Trough Small
* Confirmed Trough Normal

These three Style entries exist because TradingView displays each plotshape used for different marker sizes. The user controls the active marker size from the indicator settings using the Pivot Marker Size input. Only the selected marker size is intended to be visible on the chart.

Confirmed Trough markers are not buy signals. They only identify confirmed swing lows used by the trendline engine.

3. Resistance trendlines

Resistance trendlines are built from confirmed swing highs, also called confirmed peaks.

The script scans recent confirmed peaks and attempts to build a validated resistance line from them. A resistance line is accepted only if it passes the script’s validation rules.

A valid resistance trendline must:

* connect confirmed swing-high pivots,
* respect the selected line direction mode,
* stay within the ATR-based tolerance,
* receive the required number of touches,
* avoid being too old based on the Max Anchor Age setting.

Resistance trendlines are visual resistance references only. They are not automatic short entries and are not guaranteed rejection areas.

4. Support trendlines

Support trendlines are built from confirmed swing lows, also called confirmed troughs.

The script scans recent confirmed troughs and attempts to build a validated support line from them. A support line is accepted only if it passes the script’s validation rules.

A valid support trendline must:

* connect confirmed swing-low pivots,
* respect the selected line direction mode,
* stay within the ATR-based tolerance,
* receive the required number of touches,
* avoid being too old based on the Max Anchor Age setting.

Support trendlines are visual support references only. They are not automatic long entries and are not guaranteed bounce areas.

5. BRK R label

BRK R means Resistance Trendline Broken.

This label appears when price closes above an active resistance trendline after being at or below the same trendline on the previous bar.

BRK R is shown in green by default because it represents price closing above a resistance trendline. It is a resistance-break event only.

BRK R does not mean “Buy.”
BRK R is not a buy signal.
BRK R does not guarantee continuation.
BRK R only identifies that price closed through a detected resistance trendline.

Users may choose to study that event with their own trend, volume, market structure, and risk-management methods.

6. BRK S label

BRK S means Support Trendline Broken.

This label appears when price closes below an active support trendline after being at or above the same trendline on the previous bar.

BRK S is shown in red by default because it represents price closing below a support trendline. It is a support-break event only.

BRK S does not mean “Sell.”
BRK S is not a sell signal.
BRK S does not guarantee continuation.
BRK S only identifies that price closed through a detected support trendline.

Users may choose to study that event with their own trend, volume, market structure, and risk-management methods.

How the indicator works

1. Swing detection

The indicator uses pivot logic to identify confirmed swing highs and confirmed swing lows.

A swing high is confirmed when the selected source forms a high with enough bars on both sides.
A swing low is confirmed when the selected source forms a low with enough bars on both sides.

The user controls this with:

Pivot Left Bars
Pivot Right Bars

Because the script waits for right-side bars before confirming a pivot, the peak and trough markers appear after confirmation. This is normal for pivot-based logic and helps avoid using unstable unconfirmed swing points.

2. Anchor source

The user can choose how trendline anchors are calculated:

Wicks (High/Low)
Uses candle highs for resistance and candle lows for support.

Closes
Uses closing prices instead of wick extremes.

Wick-based trendlines are more reactive because they use the full candle range.
Close-based trendlines are usually cleaner and more conservative because they ignore wick extremes.

3. Trendline construction

When a new confirmed peak or trough appears, the script scans recent pivots from the same side.

For resistance, the script scans confirmed peaks.
For support, the script scans confirmed troughs.

The script then tests possible anchor pairs to decide whether a valid line can be drawn.

A valid trendline must pass several checks:

* the line must connect two confirmed pivots,
* the line direction must be allowed by the selected mode,
* price must not pierce the line beyond the ATR-based tolerance,
* the line must have at least the required number of touches,
* the anchor must not be older than the selected maximum age.

4. Line validation

The script validates a candidate trendline from the first anchor point to the current bar.

For a resistance line, the script checks whether highs remain below or near the line.
For a support line, the script checks whether lows remain above or near the line.

If price pierces the candidate line by more than the selected ATR tolerance, the candidate is rejected.

This means the script does not simply connect any two pivots. It attempts to draw only lines that price has respected within the selected tolerance.

5. Touch count

The script counts how many times price touches or comes close to the candidate trendline.

Minimum Touches controls how many touches are required before a line is drawn.

A higher value creates fewer but more selective trendlines.
A lower value creates more trendlines but may increase noise.

6. ATR-based tolerance

The tolerance setting uses ATR to adjust for volatility.

Tolerance (ATR multiple) defines how much price can touch or slightly pierce a line without invalidating it.

This makes the trendline logic more adaptive across different symbols and timeframes.

7. Line direction mode

The script includes two direction modes:

Classic only
Resistance lines must slope downward or remain flat. Support lines must slope upward or remain flat. This is the default textbook interpretation of falling resistance and rising support.

Any slope
Allows all valid slopes if the line passes the validation rules. This can be useful for channel edges, but it may produce more lines on choppy charts.

8. Active trendlines

Active trendlines remain visible while they are not broken or retired.

The user can choose how active lines are projected:

Extend Right
Active lines continue extending to the right.

Limited Projection
Lines are only projected a selected number of bars into the future.

9. Break detection

A break is detected only when price closes through an active trendline.

Resistance break
A resistance break occurs when price closes above an active resistance trendline after being at or below it on the previous bar.

Support break
A support break occurs when price closes below an active support trendline after being at or above it on the previous bar.

The indicator can display labels:

BRK R or BREAK R
Price closed above a resistance trendline.

BRK S or BREAK S
Price closed below a support trendline.

These labels are technical break labels only. They are not automatic buy or sell signals.

10. Broken lines

When a trendline is broken, the user can choose whether the line remains visible.

If Keep Broken Lines is enabled, the line remains on the chart as a broken or faded line and stops extending at the break candle.

If Keep Broken Lines is disabled, the broken line is hidden after the break.

11. Expired / retired lines

The script can retire lines that become too far from current price.

This is controlled by:

Retire Line Beyond (ATR multiple)

If an active line is farther than the selected ATR multiple from price, it is retired visually.

A retired line is not the same as a breakout. It only means the line is no longer close enough to current price to remain useful as an active reference.

Support lines that project at or below zero can also be retired to avoid unrealistic projections on low-priced instruments.

12. Smart BREAK label placement

The latest version includes Smart BREAK Label Placement to improve readability.

Earlier versions could place break labels too close to candles or away from the exact line that was broken. This version uses a combined placement method:

* The label is linked to the broken trendline price.
* The label is printed on the actual break candle by default.
* The label is prevented from touching or entering the candle body or wick.
* If the broken trendline is too close to the candle, the label is automatically moved away using an ATR-based minimum gap.

This helps users see both the break event and the price structure without covering the candle.

The relevant settings are:

Place BREAK Label At Broken Line
Places the label near the broken trendline price.

BREAK Label Offset From Broken Line
Controls how far the label is placed from the broken trendline.

Minimum BREAK Label Gap From Candle
Defines the minimum distance between the label and the candle. This prevents labels from overlapping candles.

Fallback BREAK Label Distance from Candle
Used when label placement at the broken line is disabled.

BREAK Label Horizontal Offset Bars
Moves the label to the right if desired. The default is 0 so the label stays on the actual break candle.

Minimum Bars Between BRK R Labels
Optional filter to reduce repeated resistance-break labels.

Minimum Bars Between BRK S Labels
Optional filter to reduce repeated support-break labels.

Only Label Visible Active Lines
When enabled, labels are printed only for lines that were active and visible before the break.

These settings affect label placement and visual clarity. They do not change the underlying break logic.

Settings explained

[1] Swing Detection

Pivot Left Bars
Controls how many bars to the left are required to confirm a swing point. Higher values create fewer but more significant pivots.

Pivot Right Bars
Controls how many bars to the right are required before a pivot is confirmed. Higher values create stronger confirmation but increase delay.

Anchor Source
Selects whether trendlines use wick extremes or closing prices.

Wicks (High/Low) uses the candle high for resistance and candle low for support.
Closes uses closing prices for cleaner close-based trendlines.

[2] Line Construction

Pivots Scanned Per Side
Controls how many recent peaks or troughs are scanned when building a new line.

Tolerance (ATR multiple)
Controls how much price can touch or slightly pierce a candidate line without invalidating it.

ATR Length
Controls the ATR calculation used for tolerance, label spacing, and retirement distance.

Allowed Line Direction
Controls whether the indicator draws only classic falling resistance and rising support, or allows any valid slope.

Minimum Touches
Controls how many touches are required before a trendline is drawn.

Max Anchor Age (bars)
Prevents very old pivots from being used as anchors.

Retire Line Beyond (ATR multiple)
Retires active lines that become too far from current price.

[3] Display

Max Lines Per Side
Controls how many resistance and support lines remain on the chart.

Line Projection Mode
Selects whether active lines extend right or use limited future projection.

Limited Projection Bars
Controls the projection length when Limited Projection is selected.

Show Active Lines
Shows or hides active trendlines.

Keep Broken Lines
Keeps broken trendlines visible after price closes through them.

Show Expired Lines
Shows or hides retired trendlines.

Active Line Width
Controls the thickness of active lines.

Broken / Expired Line Width
Controls the thickness of broken and expired lines.

Broken Line Style
Controls the style of broken lines: solid, dashed, or dotted.

Expired Line Style
Controls the style of retired lines: solid, dashed, or dotted.

Resistance Trendline Color
Controls the color of resistance trendlines.

Support Trendline Color
Controls the color of support trendlines.

Active Line Transparency
Controls the visibility of active trendlines.

Broken Line Transparency
Controls the visibility of broken trendlines.

Expired Line Transparency
Controls the visibility of retired trendlines.

Mark Swing Points
Shows or hides confirmed peak and trough markers.

Pivot Marker Size
Controls which confirmed pivot marker size is shown on the chart: Tiny, Small, or Normal.

Peak Marker Color
Controls the color of confirmed peak markers.

Trough Marker Color
Controls the color of confirmed trough markers.

Important note about the Style tab
TradingView may show separate Style entries for Confirmed Peak Tiny, Confirmed Trough Tiny, Confirmed Peak Small, Confirmed Trough Small, Confirmed Peak Normal, and Confirmed Trough Normal. These are not separate signals. They are the internal visual outputs used to support the selectable Pivot Marker Size setting.

[4] Breakout Labels

Show BREAK Labels
Shows or hides labels when price closes through a trendline.

BREAK Label Text
Compact mode displays BRK R and BRK S.
Full mode displays BREAK R and BREAK S.

Break Label Size
Controls the size of the break labels.

Break Label Style
Controls whether labels appear as directional arrow labels or simple labels.

Place BREAK Label At Broken Line
Places the label near the broken trendline price.

BREAK Label Offset From Broken Line
Controls the ATR-based distance between the label and the broken trendline price.

Minimum BREAK Label Gap From Candle
Prevents the break label from touching or entering the candle.

Fallback BREAK Label Distance from Candle
Controls label distance from the candle when line-based placement is disabled.

BREAK Label Horizontal Offset Bars
Moves break labels to the right if desired. Default is 0 so the label remains on the break candle.

Only Label Visible Active Lines
When enabled, labels are printed only when the broken line was active and visible before the break.

Minimum Bars Between BRK R Labels
Limits how frequently resistance-break labels can appear.

Minimum Bars Between BRK S Labels
Limits how frequently support-break labels can appear.

BRK R Color - Resistance Broken Up
Controls the label color for resistance breaks. Green is the default because price closed above resistance.

BRK S Color - Support Broken Down
Controls the label color for support breaks. Red is the default because price closed below support.

BREAK Label Transparency
Controls the label background transparency.

BREAK Label Text Color
Controls the text color of break labels.

[5] Alerts

Enable Alerts
Allows the script alert conditions to be used. Alerts must still be created manually from TradingView’s alert menu.

Alerts included

Resistance Trendline Broken
Triggered when price closes above an active resistance trendline.

Support Trendline Broken
Triggered when price closes below an active support trendline.

New Resistance Trendline
Triggered when a new validated resistance trendline is confirmed and drawn.

New Support Trendline
Triggered when a new validated support trendline is confirmed and drawn.

These alerts are notifications only. They do not instruct the user to buy or sell.

How to use this indicator

A practical workflow:

1. Choose pivot sensitivity using Pivot Left Bars and Pivot Right Bars.
2. Use Wicks for more reactive trendlines or Closes for cleaner close-based trendlines.
3. Set Minimum Touches to 3 or higher for more selective lines.
4. Use Classic only for traditional falling resistance and rising support.
5. Use Confirmed Peak and Confirmed Trough markers to understand which pivots the engine uses.
6. Watch active support and resistance trendlines as structure references.
7. Treat BRK R and BRK S labels as trendline break events, not as standalone trade signals.
8. Use Smart BREAK label placement settings if labels are too close to candles or if you want labels placed near the broken line.
9. Combine any break with market structure, volume, trend context, and risk management.

Example interpretation

If price closes above an active resistance trendline, the script may display BRK R. This means price closed through a detected resistance trendline. A trader may then study whether the market structure supports continuation, but the label itself is not a buy signal.

If price closes below an active support trendline, the script may display BRK S. This means price closed through a detected support trendline. A trader may then study whether the break changes market structure, but the label itself is not a sell signal.

If a Confirmed Peak marker appears, it means a swing high was confirmed by the pivot logic. It does not mean the user should sell.

If a Confirmed Trough marker appears, it means a swing low was confirmed by the pivot logic. It does not mean the user should buy.

If a line becomes expired or retired, it means the line is no longer close enough to current price or no longer useful as an active reference. This is not a breakout signal.

Important limitations

This indicator does not predict future price movement.

It does not generate guaranteed buy or sell signals.

It does not place orders.

It does not provide backtesting results.

Pivot points are confirmed only after the selected number of right bars has passed.

Confirmed Peak and Confirmed Trough markers appear after pivot confirmation and therefore have a natural delay.

Confirmed Peak and Confirmed Trough markers are plotted back on the original pivot candle for visual clarity, so they should not be interpreted as real-time signals on that candle.

After confirmation, pivot markers are not intended to move, but the user must understand that they were only known after the required confirmation bars.

Trendlines are algorithmic approximations and may differ from manually drawn trendlines.

Different pivot settings can produce different lines.

A close-through break does not guarantee continuation.

Smart BREAK label placement changes only the visual location of labels. It does not change the break calculation.

ATR-based tolerance and ATR-based label distance may need adjustment for different symbols, timeframes, and volatility conditions.

Very volatile or low-liquidity instruments may produce more frequent line changes.

Recommended use

Auto Trendline Breaks is best used as a visual support and resistance tool for traders who study:

* swing highs and swing lows,
* confirmed peaks and troughs,
* diagonal support and resistance,
* trendline breaks,
* structure shifts,
* breakout monitoring,
* manual chart-reading support.

It is intended for visual analysis, educational use, and workflow organization. It should not be used as a standalone trading system or as financial advice.

Originality and purpose

Auto Trendline Breaks provides a systematic and configurable method for drawing trendlines from confirmed swing points.

Instead of only connecting the latest two highs or lows, the script:

* stores confirmed peaks and troughs,
* scans recent pivot anchors,
* validates possible trendlines against historical price action,
* requires a minimum number of touches,
* applies ATR-based tolerance,
* manages active, broken, and expired line states,
* provides optional confirmed pivot markers,
* provides optional break labels,
* provides Smart BREAK label placement,
* provides alert conditions for line creation and trendline breaks.

The purpose is to help users monitor support and resistance structure without manually redrawing every trendline.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
indicator("Auto Trendline Breaks",
     shorttitle="AutoTL Breaks",
     overlay=true,
     max_lines_count=500,
     max_labels_count=500)

// =====================================================================
// Inputs
// =====================================================================

var string G1 = "[1] Swing Detection"
var string G2 = "[2] Line Construction"
var string G3 = "[3] Display"
var string G4 = "[4] Breakout Labels"
var string G5 = "[5] Alerts"

// ---------------------------------------------------------------------
// Swing Detection
// ---------------------------------------------------------------------

leftBars = input.int(10, "Pivot Left Bars", minval=2, group=G1,
     tooltip="Bars to the left of a candle that must be lower/higher for a swing to be confirmed.")

rightBars = input.int(10, "Pivot Right Bars", minval=2, group=G1,
     tooltip="Bars to the right needed to confirm the swing. This creates a confirmation delay and avoids using unconfirmed pivots.")

anchorMode = input.string("Wicks (High/Low)", "Anchor Source",
     options=["Wicks (High/Low)", "Closes"],
     group=G1,
     tooltip="Wicks use highs/lows. Closes use closing prices for cleaner close-based trendlines.")

// ---------------------------------------------------------------------
// Line Construction
// ---------------------------------------------------------------------

maxScan = input.int(8, "Pivots Scanned Per Side", minval=2, maxval=20, group=G2,
     tooltip="How many recent peaks/troughs are considered when building a new trendline.")

tolMult = input.float(0.25, "Tolerance (ATR multiple)", minval=0.0, step=0.05, group=G2,
     tooltip="Allowed pierce/touch distance as an ATR multiple.")

atrLen = input.int(14, "ATR Length", minval=1, group=G2)

dirMode = input.string("Classic only", "Allowed Line Direction",
     options=["Classic only", "Any slope"],
     group=G2,
     tooltip="Classic only: falling resistance and rising support. Any slope allows all valid lines.")

minTouches = input.int(3, "Minimum Touches", minval=2, maxval=6, group=G2,
     tooltip="Minimum number of touches required before drawing a line.")

maxAge = input.int(500, "Max Anchor Age (bars)", minval=50, group=G2,
     tooltip="Old pivots beyond this age are not used as anchors.")

retireMult = input.float(10.0, "Retire Line Beyond (ATR multiple)", minval=0.0, step=0.5, group=G2,
     tooltip="Active lines too far from price are retired visually. This does not fire a break alert.")

// ---------------------------------------------------------------------
// Display
// ---------------------------------------------------------------------

maxKeep = input.int(4, "Max Lines Per Side", minval=1, maxval=20, group=G3,
     tooltip="Maximum number of active/broken lines kept per side.")

lineProjectionMode = input.string("Extend Right", "Line Projection Mode",
     options=["Extend Right", "Limited Projection"],
     group=G3,
     tooltip="Extend Right keeps active lines extending. Limited Projection visually limits future projection.")

projectionBars = input.int(120, "Limited Projection Bars", minval=20, maxval=500, group=G3,
     tooltip="Used only when Line Projection Mode is set to Limited Projection.")

showActiveLines = input.bool(true, "Show Active Lines", group=G3,
     tooltip="If disabled, active trendlines are hidden. Break labels can also be restricted to visible active lines.")

keepBroken = input.bool(true, "Keep Broken Lines", group=G3,
     tooltip="If enabled, broken lines stay on the chart after a breakout.")

showExpiredLines = input.bool(false, "Show Expired Lines", group=G3,
     tooltip="If enabled, retired lines stay visible. If disabled, they are hidden.")

lineWidth = input.int(2, "Active Line Width", minval=1, maxval=5, group=G3)

brokenLineWidth = input.int(2, "Broken / Expired Line Width", minval=1, maxval=5, group=G3)

brokenLineStyle = input.string("Dashed", "Broken Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=G3,
     tooltip="Controls the style of lines after they are broken.")

expiredLineStyle = input.string("Dotted", "Expired Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=G3,
     tooltip="Controls the style of retired/expired lines.")

resColor = input.color(color.red, "Resistance Trendline Color", group=G3)
supColor = input.color(color.green, "Support Trendline Color", group=G3)

activeTransparency = input.int(0, "Active Line Transparency", minval=0, maxval=90, group=G3,
     tooltip="Lower value = more visible. 0 is fully visible.")

brokenTransparency = input.int(35, "Broken Line Transparency", minval=0, maxval=100, group=G3,
     tooltip="Lower value = stronger broken trendlines. Recommended: 25 to 45.")

expiredTransparency = input.int(65, "Expired Line Transparency", minval=0, maxval=100, group=G3,
     tooltip="Lower value = stronger expired lines. Recommended: 55 to 75.")

markPivots = input.bool(true, "Mark Swing Points", group=G3)

pivotMarkerSize = input.string("Tiny", "Pivot Marker Size",
     options=["Tiny", "Small", "Normal"],
     group=G3,
     active=markPivots)

pivotHiColor = input.color(color.new(color.red, 25), "Peak Marker Color", group=G3, active=markPivots)
pivotLoColor = input.color(color.new(color.green, 25), "Trough Marker Color", group=G3, active=markPivots)

// ---------------------------------------------------------------------
// Breakout Labels
// ---------------------------------------------------------------------

showBreakLabels = input.bool(true, "Show BREAK Labels", group=G4)

breakLabelTextMode = input.string("Compact", "BREAK Label Text",
     options=["Compact", "Full"],
     group=G4,
     active=showBreakLabels,
     tooltip="Compact uses BRK R / BRK S. Full uses BREAK R / BREAK S.")

breakLabelSize = input.string("Small", "Break Label Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group=G4,
     active=showBreakLabels)

breakLabelStyleMode = input.string("Arrow Label", "Break Label Style",
     options=["Arrow Label", "Simple Label"],
     group=G4,
     active=showBreakLabels,
     tooltip="Arrow Label uses directional labels. Simple Label uses cleaner flat labels.")

placeBreakAtLine = input.bool(true, "Place BREAK Label At Broken Line", group=G4,
     tooltip="If enabled, the break label is placed near the exact trendline price that was broken.")

breakLineOffsetAtr = input.float(0.20, "BREAK Label Offset From Broken Line", minval=0.0, step=0.05, group=G4,
     tooltip="ATR-based distance from the broken line. Used when labels are placed at the broken line.")

minLabelGapAtr = input.float(1.20, "Minimum BREAK Label Gap From Candle", minval=0.0, step=0.05, group=G4,
     tooltip="Minimum ATR-based distance between the BREAK label and the candle. This prevents labels from touching or entering candles.")

fallbackLabelOffsetAtr = input.float(1.40, "Fallback BREAK Label Distance from Candle", minval=0.0, step=0.05, group=G4,
     tooltip="Fallback ATR distance from candle if label placement at the broken line is disabled.")

breakLabelXOffset = input.int(0, "BREAK Label Horizontal Offset Bars", minval=0, maxval=10, group=G4,
     tooltip="Moves BREAK labels to the right. Default is 0 so labels stay on the actual break candle.")

labelOnlyVisibleActiveLines = input.bool(true, "Only Label Visible Active Lines", group=G4,
     tooltip="If enabled, a BREAK label is printed only when the broken line was an active visible line.")

minBarsBetweenResBreakLabels = input.int(0, "Minimum Bars Between BRK R Labels", minval=0, maxval=50, group=G4,
     tooltip="Prevents printing too many resistance-break labels close together. Use 0 to disable.")

minBarsBetweenSupBreakLabels = input.int(0, "Minimum Bars Between BRK S Labels", minval=0, maxval=50, group=G4,
     tooltip="Prevents printing too many support-break labels close together. Use 0 to disable.")

breakUpColor = input.color(color.green, "BRK R Color - Resistance Broken Up", group=G4,
     tooltip="Color used when price closes above a resistance trendline. This is a resistance-break event, not a buy signal.")

breakDownColor = input.color(color.red, "BRK S Color - Support Broken Down", group=G4,
     tooltip="Color used when price closes below a support trendline. This is a support-break event, not a sell signal.")

breakLabelTransparency = input.int(0, "BREAK Label Transparency", minval=0, maxval=80, group=G4)

breakLabelTextColor = input.color(color.white, "BREAK Label Text Color", group=G4)

// ---------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------

enableAlerts = input.bool(true, "Enable Alerts", group=G5)

// =====================================================================
// Buffers
// =====================================================================

var array<float> bufHi = array.new_float()
var array<float> bufLo = array.new_float()

srcHi = anchorMode == "Closes" ? close : high
srcLo = anchorMode == "Closes" ? close : low

array.push(bufHi, srcHi)
array.push(bufLo, srcLo)

// =====================================================================
// Confirmed Pivot Storage
// =====================================================================

var array<int>   phX = array.new_int()
var array<float> phY = array.new_float()
var array<int>   plX = array.new_int()
var array<float> plY = array.new_float()

// =====================================================================
// Trendline Storage
// =====================================================================

var array<line> resLines = array.new_line()
var array<bool> resBrk   = array.new_bool()
var array<line> supLines = array.new_line()
var array<bool> supBrk   = array.new_bool()

atrNow = ta.atr(atrLen)
tol = atrNow * tolMult

var int lastResBreakLabelBar = na
var int lastSupBreakLabelBar = na

// =====================================================================
// Helper Functions
// =====================================================================

f_lineExtendMode() =>
    lineProjectionMode == "Extend Right" ? extend.right : extend.none

f_lineX2(int pivotBar) =>
    lineProjectionMode == "Extend Right" ? pivotBar : pivotBar + projectionBars

f_lineStyle(string styleName) =>
    styleName == "Solid" ? line.style_solid :
     styleName == "Dashed" ? line.style_dashed :
     line.style_dotted

f_labelSize() =>
    breakLabelSize == "Tiny" ? size.tiny :
     breakLabelSize == "Small" ? size.small :
     breakLabelSize == "Normal" ? size.normal :
     breakLabelSize == "Large" ? size.large :
     size.huge

f_resBreakText() =>
    breakLabelTextMode == "Compact" ? "BRK R" : "BREAK R"

f_supBreakText() =>
    breakLabelTextMode == "Compact" ? "BRK S" : "BREAK S"

f_resLabelStyle() =>
    breakLabelStyleMode == "Arrow Label" ? label.style_label_up : label.style_label_left

f_supLabelStyle() =>
    breakLabelStyleMode == "Arrow Label" ? label.style_label_down : label.style_label_left

// =====================================================================
// Line Validation
// =====================================================================

f_validate(bool isRes, int xA, float yA, int xB, float yB, float tolerance) =>
    slope = (yB - yA) / (xB - xA)
    ok = true
    touches = 0

    for x = xA to bar_index
        lineY = yA + slope * (x - xA)
        px = isRes ? array.get(bufHi, x) : array.get(bufLo, x)
        diff = isRes ? px - lineY : lineY - px

        if diff > tolerance
            ok := false
            break

        if math.abs(diff) <= tolerance
            touches += 1

    [ok, touches]

// =====================================================================
// Build Trendlines
// =====================================================================

f_buildLine(bool isRes, array<int> pxArr, array<float> pyArr, int pb, float pp,
             array<line> lines, array<bool> brks, color col) =>
    n = array.size(pxArr)
    bestX = -1
    bestY = float(na)
    bestT = 0

    if n >= 2
        for k = 0 to n - 2
            xA = array.get(pxArr, k)
            yA = array.get(pyArr, k)

            if bar_index - xA <= maxAge
                slope = (pp - yA) / (pb - xA)
                dirOk = dirMode == "Any slope" or (isRes ? slope <= 0 : slope >= 0)

                if dirOk
                    [ok, t] = f_validate(isRes, xA, yA, pb, pp, tol)

                    if ok and t >= bestT
                        bestX := xA
                        bestY := yA
                        bestT := t

    created = false

    if bestX >= 0 and bestT >= minTouches
        x2 = f_lineX2(pb)

        ln = line.new(
             bestX,
             bestY,
             x2,
             pp,
             xloc=xloc.bar_index,
             extend=showActiveLines ? f_lineExtendMode() : extend.none,
             color=showActiveLines ? color.new(col, activeTransparency) : color.new(col, 100),
             width=lineWidth,
             style=line.style_solid)

        array.push(lines, ln)
        array.push(brks, false)
        created := true

        if array.size(lines) > maxKeep
            line.delete(array.shift(lines))
            array.shift(brks)

    created

// =====================================================================
// Break Detection
// =====================================================================

f_checkBreaks(bool isRes, array<line> lines, array<bool> brks, color col) =>
    brokeNow = false
    brokenPrice = float(na)
    bestDistance = float(na)

    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            if not array.get(brks, i)
                ln = array.get(lines, i)
                lp = line.get_price(ln, bar_index)
                lpPrev = line.get_price(ln, bar_index - 1)

                lineVisibleForLabel = showActiveLines or not labelOnlyVisibleActiveLines

                crossedUp = close > lp and close[1] <= lpPrev
                crossedDn = close < lp and close[1] >= lpPrev
                crossed = isRes ? crossedUp : crossedDn

                if crossed
                    array.set(brks, i, true)
                    brokeNow := true

                    distance = math.abs(close - lp)

                    if lineVisibleForLabel and (na(bestDistance) or distance < bestDistance)
                        bestDistance := distance
                        brokenPrice := lp

                    if keepBroken
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, bar_index)
                        line.set_y2(ln, lp)
                        line.set_style(ln, f_lineStyle(brokenLineStyle))
                        line.set_width(ln, brokenLineWidth)
                        line.set_color(ln, color.new(col, brokenTransparency))
                    else
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, bar_index)
                        line.set_y2(ln, lp)
                        line.set_color(ln, color.new(col, 100))

    [brokeNow, brokenPrice]

// =====================================================================
// Retire Lines
// =====================================================================

f_retire(bool isRes, array<line> lines, array<bool> brks, color col) =>
    retired = 0

    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            if not array.get(brks, i)
                ln = array.get(lines, i)
                lp = line.get_price(ln, bar_index)

                faraway = retireMult > 0 and math.abs(close - lp) > retireMult * atrNow
                subZero = not isRes and lp <= 0

                if faraway or subZero
                    array.set(brks, i, true)
                    line.set_extend(ln, extend.none)
                    line.set_x2(ln, bar_index)
                    line.set_y2(ln, lp)
                    line.set_style(ln, f_lineStyle(expiredLineStyle))
                    line.set_width(ln, brokenLineWidth)
                    line.set_color(ln, showExpiredLines ? color.new(col, expiredTransparency) : color.new(col, 100))
                    retired += 1

    retired

// =====================================================================
// Refresh Active Lines
// =====================================================================

f_refreshActive(array<line> lines, array<bool> brks, color col) =>
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            if not array.get(brks, i)
                ln = array.get(lines, i)
                line.set_color(ln, showActiveLines ? color.new(col, activeTransparency) : color.new(col, 100))
                line.set_width(ln, lineWidth)
                line.set_style(ln, line.style_solid)
                line.set_extend(ln, showActiveLines ? f_lineExtendMode() : extend.none)

// =====================================================================
// Pivot Flow
// =====================================================================

ph = ta.pivothigh(srcHi, leftBars, rightBars)
pl = ta.pivotlow(srcLo, leftBars, rightBars)

newResLine = false
newSupLine = false

if not na(ph) and not na(tol)
    pb = bar_index - rightBars
    array.push(phX, pb)
    array.push(phY, ph)

    while array.size(phX) > maxScan + 1
        array.shift(phX)
        array.shift(phY)

    newResLine := f_buildLine(true, phX, phY, pb, ph, resLines, resBrk, resColor)

if not na(pl) and not na(tol)
    pbl = bar_index - rightBars
    array.push(plX, pbl)
    array.push(plY, pl)

    while array.size(plX) > maxScan + 1
        array.shift(plX)
        array.shift(plY)

    newSupLine := f_buildLine(false, plX, plY, pbl, pl, supLines, supBrk, supColor)

// =====================================================================
// Breaks and Retirements
// =====================================================================

f_refreshActive(resLines, resBrk, resColor)
f_refreshActive(supLines, supBrk, supColor)

[resBreak, resBrokenPrice] = f_checkBreaks(true, resLines, resBrk, resColor)
[supBreak, supBrokenPrice] = f_checkBreaks(false, supLines, supBrk, supColor)

retiredRes = f_retire(true, resLines, resBrk, resColor)
retiredSup = f_retire(false, supLines, supBrk, supColor)

// =====================================================================
// Smart Break Label Placement
// =====================================================================

labelSz = f_labelSize()
breakLabelX = bar_index + breakLabelXOffset

fallbackResLabelY = low - atrNow * fallbackLabelOffsetAtr
fallbackSupLabelY = high + atrNow * fallbackLabelOffsetAtr

resLineBasedY = not na(resBrokenPrice) ? resBrokenPrice - atrNow * breakLineOffsetAtr : fallbackResLabelY
supLineBasedY = not na(supBrokenPrice) ? supBrokenPrice + atrNow * breakLineOffsetAtr : fallbackSupLabelY

minResAwayFromCandle = low - atrNow * minLabelGapAtr
minSupAwayFromCandle = high + atrNow * minLabelGapAtr

resLabelY = placeBreakAtLine and not na(resBrokenPrice) ? math.min(resLineBasedY, minResAwayFromCandle) : fallbackResLabelY
supLabelY = placeBreakAtLine and not na(supBrokenPrice) ? math.max(supLineBasedY, minSupAwayFromCandle) : fallbackSupLabelY

canPrintResBreakLabel = minBarsBetweenResBreakLabels == 0 or na(lastResBreakLabelBar) or bar_index - lastResBreakLabelBar >= minBarsBetweenResBreakLabels
canPrintSupBreakLabel = minBarsBetweenSupBreakLabels == 0 or na(lastSupBreakLabelBar) or bar_index - lastSupBreakLabelBar >= minBarsBetweenSupBreakLabels

if showBreakLabels and resBreak and not na(resBrokenPrice) and canPrintResBreakLabel
    label.new(
         breakLabelX,
         resLabelY,
         f_resBreakText(),
         xloc=xloc.bar_index,
         style=f_resLabelStyle(),
         color=color.new(breakUpColor, breakLabelTransparency),
         textcolor=breakLabelTextColor,
         size=labelSz)
    lastResBreakLabelBar := bar_index

if showBreakLabels and supBreak and not na(supBrokenPrice) and canPrintSupBreakLabel
    label.new(
         breakLabelX,
         supLabelY,
         f_supBreakText(),
         xloc=xloc.bar_index,
         style=f_supLabelStyle(),
         color=color.new(breakDownColor, breakLabelTransparency),
         textcolor=breakLabelTextColor,
         size=labelSz)
    lastSupBreakLabelBar := bar_index

// =====================================================================
// Pivot Markers
// =====================================================================

// Pivot markers - Tiny
plotshape(markPivots and pivotMarkerSize == "Tiny" and not na(ph),
     title="Confirmed Peak Tiny",
     style=shape.triangledown,
     location=location.abovebar,
     color=pivotHiColor,
     size=size.tiny,
     offset=-rightBars)

plotshape(markPivots and pivotMarkerSize == "Tiny" and not na(pl),
     title="Confirmed Trough Tiny",
     style=shape.triangleup,
     location=location.belowbar,
     color=pivotLoColor,
     size=size.tiny,
     offset=-rightBars)

// Pivot markers - Small
plotshape(markPivots and pivotMarkerSize == "Small" and not na(ph),
     title="Confirmed Peak Small",
     style=shape.triangledown,
     location=location.abovebar,
     color=pivotHiColor,
     size=size.small,
     offset=-rightBars)

plotshape(markPivots and pivotMarkerSize == "Small" and not na(pl),
     title="Confirmed Trough Small",
     style=shape.triangleup,
     location=location.belowbar,
     color=pivotLoColor,
     size=size.small,
     offset=-rightBars)

// Pivot markers - Normal
plotshape(markPivots and pivotMarkerSize == "Normal" and not na(ph),
     title="Confirmed Peak Normal",
     style=shape.triangledown,
     location=location.abovebar,
     color=pivotHiColor,
     size=size.normal,
     offset=-rightBars)

plotshape(markPivots and pivotMarkerSize == "Normal" and not na(pl),
     title="Confirmed Trough Normal",
     style=shape.triangleup,
     location=location.belowbar,
     color=pivotLoColor,
     size=size.normal,
     offset=-rightBars)

// =====================================================================
// Alerts
// =====================================================================

alertcondition(enableAlerts and resBreak,
     title="Resistance Trendline Broken",
     message="Price closed ABOVE a resistance trendline.")

alertcondition(enableAlerts and supBreak,
     title="Support Trendline Broken",
     message="Price closed BELOW a support trendline.")

alertcondition(enableAlerts and newResLine,
     title="New Resistance Trendline",
     message="A new resistance trendline was confirmed and drawn.")

alertcondition(enableAlerts and newSupLine,
     title="New Support Trendline",
     message="A new support trendline was confirmed and drawn.")
````
