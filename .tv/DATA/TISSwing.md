<!-- tradingview-pine-id: PUB;6e94160b99504d44a49abf917c440378 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TIS_Swing

Source: https://www.tradingview.com/script/SMWqNJF2-TIS-Swing/

## Description

OVERVIEW

TIS_Swing detects swing highs and swing lows and, unlike most pivot tools, publishes the last confirmed level as a continuous value that other scripts can read.

Standard pivot indicators return a number only on the bar where the pivot is confirmed and nothing on every other bar. That is fine for drawing a dot on the chart, but it makes the level unusable for comparison: on any given bar you cannot ask whether the current price is above the last confirmed swing high, because on that bar the pivot series holds no value. TIS_Swing keeps the level alive between pivots, so that question can be answered on every bar, by you visually or by another script through the source dropdown.

HOW IT WORKS

A bar qualifies as a swing high when its high is greater than or equal to the highs of the bars that follow it, and strictly greater than the highs of the bars that precede it. The number of bars checked on each side is set by Strength Left and Strength Right. Swing lows use the mirrored rule. The comparison on the right side is inclusive, so a candidate that ties with a later bar still qualifies; this produces slightly more pivots than a strictly greater definition, and is intentional.

A pivot can only be confirmed once the bars to its right exist, so a pivot is always confirmed Strength Right bars after it forms. It is never confirmed earlier and it is never revised afterwards, so nothing repaints.

Once a pivot is confirmed, its price becomes the current level for that side and stays there until the next pivot on the same side replaces it. When the series trades through the level, the level is marked as broken. What happens next depends on Remove Broken Pivot Lines:

- ON, the default: the visible level is dropped and no level is shown until a new pivot forms. This is the familiar behaviour of most pivot tools.
- OFF: the visible level stays where it was until a new pivot replaces it, so a broken level remains on screen as a reference.

Either way, a second pair of values keeps the last level regardless of the setting. Those are the plots marked (persistent), and they exist so that comparisons are always possible.

WHAT YOU CAN DO WITH IT

Market structure on price. With the level available on every bar, a higher high is simply the current price trading above the last confirmed swing high, and a lower low is the mirror. You can read it off the chart or compute it in your own script by selecting Last Swing High (persistent) as a source and comparing it against the close.

Divergence on an oscillator. Turn on Use Other Source, point it at a stochastic, an RSI or any other plotted series, and move the script to its own pane. The pivots are then detected on the oscillator instead of on price. A higher swing low on the oscillator while price is still making lower lows is a classic divergence, and here it is visible as a stepped level moving up while price moves down.

Breakout timing. With Remove Broken Pivot Lines on, the moment the level disappears is the moment the last swing was taken out. That transition is also available as an alert.

PARAMETERS

Parameters
- Strength Left: bars to the left of the candidate that must be lower for a high, or higher for a low. Default 5.
- Strength Right: bars to the right required to confirm the pivot. Also the confirmation delay, in bars. Default 2.
- Remove Broken Pivot Lines: drop the visible level once it is broken. Default on. Does not affect the (persistent) plots.
- Use Other Source: detect pivots on another plotted series instead of the bar highs and lows. Both sides then use the selected series.
- Source: the series used when Use Other Source is on.

Visual Settings
- Show Levels: opacity of the stepped level lines.
- Show Persistent Levels: opacity of the thin lines that always keep the last level. Off by default to keep the chart clean.
- Show Pivot Markers: diamonds drawn on the confirmed pivot bars.
- Extend to the Right: horizontal line projected forward from the last pivot on each side.
- Swing High Color, Swing Low Color, Line Width, Extension Line Style.

The Show options change opacity only. The four series are always published, so another script can read them even when they are not visible on the chart.

OUTPUTS

Four values are available in the source dropdown of any other indicator or strategy:

- Last Swing High and Last Swing Low: the level as shown, honouring Remove Broken Pivot Lines.
- Last Swing High (persistent) and Last Swing Low (persistent): the last confirmed level, kept regardless of that setting.

Four alerts are available: New Swing High, New Swing Low, Swing High Broken, Swing Low Broken.

LIMITATIONS

- A pivot is confirmed Strength Right bars after the bar that forms it. On the chart this looks like a delay, and it is one. It is inherent to any pivot definition that requires confirmation from the right, and it is the price of not repainting.
- These levels are reference points, not entry signals. Nothing here tells you which way to trade.
- With Remove Broken Pivot Lines on, the level is dropped on the same bar as the break. A comparison such as close above Last Swing High will therefore never be true, because the value is already gone by the time it would be. Use the (persistent) plots for that comparison, or detect the break as the transition of the visible plot to no value.
- Before the first pivot on a side is confirmed, that side publishes no value.
- Pine fixes the pane at compile time, so with a non-price source the script has to be moved to its own pane manually.
- Larger Strength values give fewer and more significant levels but a longer confirmation delay. There is no setting that avoids that trade-off.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheIndicatorStore

//@version=6
indicator("TIS_Swing", shorttitle = "TIS_Swing", overlay = true, max_lines_count = 10)

//--------------------------------------------------------------------------------------------------
//--- Input Groups ---
//--------------------------------------------------------------------------------------------------
GRP_PARAMS = "Parameters"
GRP_VISUAL = "Visual Settings"

//--------------------------------------------------------------------------------------------------
//--- Parameters (NT8 order) ---
//--------------------------------------------------------------------------------------------------
Left_Strength  = input.int(5, "Strength Left", minval = 1, group = GRP_PARAMS,
     tooltip = "Number of bars to the left of the candidate bar that must be lower (for a swing high) or higher (for a swing low).")

Right_Strength = input.int(2, "Strength Right", minval = 1, group = GRP_PARAMS,
     tooltip = "Number of bars to the right of the candidate bar required to confirm the pivot. The pivot is only confirmed this many bars after it forms.")

Remove_Broken  = input.bool(true, "Remove Broken Pivot Lines", group = GRP_PARAMS,
     tooltip = "ON (default): the level is dropped as soon as the series trades through it, and no level is published until a new pivot forms. OFF: the last confirmed level is kept even after it is broken. This only affects the 'Last Swing High/Low' plots. The '(persistent)' plots always keep the last level regardless of this setting.")

Use_Other_Source = input.bool(false, "Use Other Source", group = GRP_PARAMS,
     tooltip = "Detect pivots on another plotted series instead of the bar highs and lows. Both the high and the low side then use the selected series. Useful on oscillators: a higher swing low on the oscillator while price keeps making lower lows is a divergence. Move the script to its own pane when using a non-price source.")

srcInput = input.source(close, "Source", group = GRP_PARAMS)

//--------------------------------------------------------------------------------------------------
//--- Visual Settings ---
//--------------------------------------------------------------------------------------------------
Show_Levels  = input.bool(true, "Show Levels", group = GRP_VISUAL,
     tooltip = "Show the stepped line that holds the last level, honouring 'Remove Broken Pivot Lines'.")

Show_Persist = input.bool(false, "Show Persistent Levels", group = GRP_VISUAL,
     tooltip = "Show the thin line that always holds the last confirmed level, even after it is broken. Off by default to keep the chart clean. The values are published either way, so other scripts can read them.")

Show_Pivots  = input.bool(true, "Show Pivot Markers", group = GRP_VISUAL)

Extend_Right = input.bool(true, "Extend to the Right", group = GRP_VISUAL)

High_Color   = input.color(color.blue, "Swing High Color", group = GRP_VISUAL)
Low_Color    = input.color(color.red, "Swing Low Color", group = GRP_VISUAL)
Line_Width   = input.int(2, "Line Width", minval = 1, group = GRP_VISUAL)
Line_Style   = input.string("Dashed", "Extension Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_VISUAL)

//--------------------------------------------------------------------------------------------------
//--- Derived series ---
//--------------------------------------------------------------------------------------------------
srcHigh = Use_Other_Source ? srcInput : high
srcLow  = Use_Other_Source ? srcInput : low

extStyle = Line_Style == "Solid" ? line.style_solid : Line_Style == "Dashed" ? line.style_dashed : line.style_dotted

//--------------------------------------------------------------------------------------------------
//--- Operations (global scope) ---
//--------------------------------------------------------------------------------------------------
// NT8: MAX(High, Right_Strength)[0]               -> highest of the Right_Strength bars AFTER the candidate
// NT8: MAX(High, Left_Strength)[Right_Strength+1] -> highest of the Left_Strength bars BEFORE the candidate
rightMaxHigh = ta.highest(srcHigh, Right_Strength)
leftMaxHigh  = ta.highest(srcHigh, Left_Strength)[Right_Strength + 1]
rightMinLow  = ta.lowest(srcLow, Right_Strength)
leftMinLow   = ta.lowest(srcLow, Left_Strength)[Right_Strength + 1]

candHigh = srcHigh[Right_Strength]
candLow  = srcLow[Right_Strength]

//--------------------------------------------------------------------------------------------------
//--- State ---
//--------------------------------------------------------------------------------------------------
// pivotHi / pivotLo hold the last confirmed level and are NEVER invalidated. The broken flags record
// whether that level has been traded through. This keeps the raw level available for comparison while
// still reproducing NT8's behaviour on the visible plots.
var float pivotHi  = na
var float pivotLo  = na
var bool  hiBroken = false
var bool  loBroken = false
var int   hiBar    = na
var int   loBar    = na
var line  hiLine   = na
var line  loLine   = na

newPH   = false
newPL   = false
brokeHi = false
brokeLo = false

//--------------------------------------------------------------------------------------------------
//--- Bar Update (literal translation of OnBarUpdate) ---
//--------------------------------------------------------------------------------------------------
if bar_index > Left_Strength + Right_Strength

    // --- Swing high ---
    // NT8 uses >= on the right side and > on the left side. This is NOT the same as ta.pivothigh(),
    // which is strict on both sides, so the comparison is written out to preserve NT8 behaviour.
    if candHigh >= rightMaxHigh and candHigh > leftMaxHigh
        pivotHi  := candHigh
        hiBar    := bar_index - Right_Strength
        hiBroken := false
        newPH    := true

    if not na(pivotHi) and not hiBroken and srcHigh > pivotHi
        hiBroken := true
        brokeHi  := true

    // --- Swing low ---
    if candLow <= rightMinLow and candLow < leftMinLow
        pivotLo  := candLow
        loBar    := bar_index - Right_Strength
        loBroken := false
        newPL    := true

    if not na(pivotLo) and not loBroken and srcLow < pivotLo
        loBroken := true
        brokeLo  := true

//--------------------------------------------------------------------------------------------------
//--- Published series ---
//--------------------------------------------------------------------------------------------------
// NT8 equivalent: swinghi / swinglo after the 9999 sentinel is applied.
swingHi = Remove_Broken and hiBroken ? na : pivotHi
swingLo = Remove_Broken and loBroken ? na : pivotLo

//--------------------------------------------------------------------------------------------------
//--- Extension lines ---
//--------------------------------------------------------------------------------------------------
if Extend_Right
    if newPH
        if not na(hiLine)
            line.delete(hiLine)
        hiLine := line.new(hiBar, pivotHi, bar_index, pivotHi, extend = extend.right, color = High_Color, width = Line_Width, style = extStyle)
    if Remove_Broken and brokeHi and not na(hiLine)
        line.delete(hiLine)
        hiLine := na

    if newPL
        if not na(loLine)
            line.delete(loLine)
        loLine := line.new(loBar, pivotLo, bar_index, pivotLo, extend = extend.right, color = Low_Color, width = Line_Width, style = extStyle)
    if Remove_Broken and brokeLo and not na(loLine)
        line.delete(loLine)
        loLine := na
else
    if not na(hiLine)
        line.delete(hiLine)
        hiLine := na
    if not na(loLine)
        line.delete(loLine)
        loLine := na

//--------------------------------------------------------------------------------------------------
//--- Plots ---
//--------------------------------------------------------------------------------------------------
// All four series are published unconditionally so other scripts can select them with input.source.
// The Show toggles only change opacity, they never turn a series into na.
// style_steplinebr ("Step line with Breaks") is required, not style_stepline: when Remove_Broken
// drops a level the series becomes na, and a plain stepline bridges that gap by joining the last
// value before the break to the first value after it, drawing a level that was never there.
levelHiColor = Show_Levels ? High_Color : color.new(High_Color, 100)
levelLoColor = Show_Levels ? Low_Color : color.new(Low_Color, 100)
persHiColor  = Show_Persist ? color.new(High_Color, 45) : color.new(High_Color, 100)
persLoColor  = Show_Persist ? color.new(Low_Color, 45) : color.new(Low_Color, 100)

plot(swingHi, title = "Last Swing High", style = plot.style_steplinebr, color = levelHiColor, linewidth = Line_Width)
plot(swingLo, title = "Last Swing Low", style = plot.style_steplinebr, color = levelLoColor, linewidth = Line_Width)

plot(pivotHi, title = "Last Swing High (persistent)", style = plot.style_steplinebr, color = persHiColor, linewidth = 1)
plot(pivotLo, title = "Last Swing Low (persistent)", style = plot.style_steplinebr, color = persLoColor, linewidth = 1)

plotshape(Show_Pivots and newPH ? candHigh : na, title = "Pivot High Marker", style = shape.diamond,
     location = location.absolute, color = High_Color, size = size.tiny, offset = -Right_Strength)

plotshape(Show_Pivots and newPL ? candLow : na, title = "Pivot Low Marker", style = shape.diamond,
     location = location.absolute, color = Low_Color, size = size.tiny, offset = -Right_Strength)

//--------------------------------------------------------------------------------------------------
//--- Alerts ---
//--------------------------------------------------------------------------------------------------
alertcondition(newPH, title = "New Swing High", message = "TIS_Swing: new swing high confirmed")
alertcondition(newPL, title = "New Swing Low", message = "TIS_Swing: new swing low confirmed")
alertcondition(brokeHi, title = "Swing High Broken", message = "TIS_Swing: last swing high broken")
alertcondition(brokeLo, title = "Swing Low Broken", message = "TIS_Swing: last swing low broken")
````
