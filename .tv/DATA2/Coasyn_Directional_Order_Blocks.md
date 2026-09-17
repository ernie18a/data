<!-- tradingview-pine-id: PUB;95c3936d9fb44bdd8b1fc134b0dc9c9a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Coasyn Directional Order Blocks

Source: https://www.tradingview.com/script/479OoWeN-Coasyn-Directional-Order-Blocks/

## Description

Coasyn Directional Order Blocks

Coasyn Directional Order Blocks identifies directional supply and demand zones created around market-structure breaks with displacement.

The indicator is designed to help traders visualize potential areas of prior institutional participation without turning those zones into automatic trade signals.

It tracks both:

Demand Order Blocks
Supply Order Blocks

Each block remains active until it is touched, invalidated, or removed according to the settings selected by the user.

How blocks are created

A new block requires two things:

1. A structure break

The indicator tracks recent swing highs and swing lows using the configured Structure Swing Length.

A demand block requires price to break above the most recent tracked swing high.

A supply block requires price to break below the most recent tracked swing low.

2. Displacement

The structure break must occur with a directional displacement candle.

The displacement filter uses:

ATR-relative candle range
minimum candle-body percentage
bullish direction for demand
bearish direction for supply

This helps prevent every minor structure break from automatically becoming an order block.

Origin candle

After a valid structure break, the indicator searches backward for the opposing candle that preceded the move.

For a Demand Block, it searches for a bearish candle.

For a Supply Block, it searches for a bullish candle.

The number of candles searched is controlled by:

Origin Candle Search

Order Block Zone

The Order Block Zone setting determines how much of the origin candle becomes the displayed zone.

Available options:

Full Candle
Uses the full high-to-low range of the origin candle.

Body
Uses only the candle body.

Refined
Uses a directional refinement of the candle range.

For demand, the refined zone uses the candle low through the top of the body.

For supply, the refined zone uses the bottom of the body through the candle high.

Block states

Each block begins as a fresh active zone.

The indicator then tracks whether price returns to the zone.

The Touched When setting controls when a block is considered touched.

Available options:

First Contact
The block becomes touched as soon as price reaches the outer edge of the zone.

50% Reached
Price must reach the midpoint of the order block.

Full Fill
Price must travel completely through the block to its opposite boundary.

Keeping touched blocks

Enable:

Keep Touched Blocks

to leave previously contacted blocks visible.

Touched blocks are displayed with increased transparency so they can be visually distinguished from fresh zones.

Disable this setting if you want a block removed after its first qualifying interaction.

Invalidation

The Invalidated When setting determines when a block is considered structurally broken.

Available options:

Close Beyond
A candle must close beyond the invalidation boundary.

Wick Beyond
Any wick through the invalidation boundary is sufficient.

For demand blocks, invalidation occurs below the zone.

For supply blocks, invalidation occurs above the zone.

Keeping invalidated blocks

Enable:

Keep Invalidated Blocks

if you want failed blocks to remain visible for review.

Invalidated blocks are converted to a neutral gray appearance and stop extending forward.

When disabled, invalidated blocks are removed from the chart.

Maximum active blocks

Maximum Active Blocks per Direction controls how many demand and supply zones can remain active at once.

Older blocks are removed automatically when the configured maximum is exceeded.

Demand and supply limits are tracked independently.

Forward projection

Forward Projection determines how far active order blocks extend to the right of the chart.

The zone continues updating forward while it remains active.

50% midline

Enable:

Show 50% Line

to display the midpoint of each order block.

This provides a visual reference for traders who use partial mitigation or midpoint interaction as part of their own process.

Structure break markers

Enable:

Show Structure Break Marker

to mark the candle where a valid displacement-driven structure break created a new order block.

These markers are optional and are disabled by default.

Labels

Enable:

Show Demand / Supply Label

to display the directional identity of each block directly inside the zone.

Colors

Demand and supply colors are fully configurable.

Users can also adjust:

fresh-block transparency
touched-block transparency
invalidated-block color
Alerts

The indicator includes alert conditions for:

New Demand Order Block
New Supply Order Block
Demand Order Block Entered
Supply Order Block Entered
Demand Order Block Invalidated
Supply Order Block Invalidated

Alerts must still be configured by the user through TradingView's alert system.

Example workflow

A trader may use the indicator to identify a demand zone created after a strong bullish displacement through prior structure.

The trader can then observe whether price:

remains away from the block → returns to the block → reaches the selected touch threshold → holds or invalidates

The indicator reports the state of the zone.

It does not determine whether the trader should enter.

Important

Coasyn Directional Order Blocks is a market-structure visualization tool.

It does not provide:

automatic entries
buy or sell recommendations
targets
stop placement
position sizing
automated execution

Order blocks should be interpreted within the trader's own market structure, risk, and strategy framework.

A displayed block is a reference zone, not a guarantee of future support, resistance, reversal, or continuation.

Built by Coasyn Market Systems.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Coasyn

//@version=6
indicator("Coasyn Directional Order Blocks", shorttitle="Coasyn OB", overlay=true, max_boxes_count=300, max_lines_count=300, max_labels_count=100, max_bars_back=2000)

// INPUTS
string g1 = "Order Block Detection"
int swingLength = input.int(3, "Structure Swing Length", minval=1, maxval=20, group=g1)
int originSearch = input.int(12, "Origin Candle Search", minval=1, maxval=100, group=g1)
int atrLength = input.int(14, "ATR Length", minval=1, maxval=200, group=g1)
float displacementATR = input.float(1.0, "Minimum Displacement Range (ATR)", minval=0.1, maxval=10.0, step=0.1, group=g1)
float minimumBodyPercent = input.float(55.0, "Minimum Displacement Body (%)", minval=1.0, maxval=100.0, step=1.0, group=g1)
string zoneMode = input.string("Full Candle", "Order Block Zone", options=["Full Candle", "Body", "Refined"], group=g1)

string g2 = "Block State"
string touchRule = input.string("First Contact", "Touched When", options=["First Contact", "50% Reached", "Full Fill"], group=g2)
string invalidationRule = input.string("Close Beyond", "Invalidated When", options=["Close Beyond", "Wick Beyond"], group=g2)
bool keepTouched = input.bool(true, "Keep Touched Blocks", group=g2)
bool keepInvalidated = input.bool(false, "Keep Invalidated Blocks", group=g2)

string g3 = "Display"
int maximumBlocks = input.int(12, "Maximum Active Blocks per Direction", minval=1, maxval=75, group=g3)
int forwardBars = input.int(100, "Forward Projection", minval=1, maxval=500, group=g3)
bool showMidline = input.bool(true, "Show 50% Line", group=g3)
bool showStructureBreak = input.bool(false, "Show Structure Break Marker", group=g3)
bool showLabels = input.bool(true, "Show Demand / Supply Label", group=g3)

string g4 = "Colors"
color demandColor = input.color(#17b890, "Demand", inline="direction", group=g4)
color supplyColor = input.color(#d14b4b, "Supply", inline="direction", group=g4)
int freshTransparency = input.int(82, "Fresh Transparency", minval=0, maxval=100, group=g4)
int touchedTransparency = input.int(91, "Touched Transparency", minval=0, maxval=100, group=g4)
color invalidatedColor = input.color(color.gray, "Invalidated", group=g4)

// STORAGE
var array<box> demandBoxes = array.new<box>()
var array<line> demandLines = array.new<line>()
var array<int> demandCreated = array.new<int>()
var array<int> demandStates = array.new<int>()

var array<box> supplyBoxes = array.new<box>()
var array<line> supplyLines = array.new<line>()
var array<int> supplyCreated = array.new<int>()
var array<int> supplyStates = array.new<int>()

var float lastSwingHigh = na
var float lastSwingLow = na
var bool swingHighBroken = false
var bool swingLowBroken = false

// STRUCTURE AND DISPLACEMENT
float atr = ta.atr(atrLength)
float barRange = high - low
float barBody = math.abs(close - open)
float bodyPercent = barRange > 0.0 ? barBody / barRange * 100.0 : 0.0

bool upDisplacement = close > open and not na(atr) and barRange >= atr * displacementATR and bodyPercent >= minimumBodyPercent
bool downDisplacement = close < open and not na(atr) and barRange >= atr * displacementATR and bodyPercent >= minimumBodyPercent

float pivotHigh = ta.pivothigh(high, swingLength, swingLength)
float pivotLow = ta.pivotlow(low, swingLength, swingLength)

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    swingHighBroken := false

if not na(pivotLow)
    lastSwingLow := pivotLow
    swingLowBroken := false

bool demandBreak = not na(lastSwingHigh) and not swingHighBroken and close > lastSwingHigh and close[1] <= lastSwingHigh and upDisplacement
bool supplyBreak = not na(lastSwingLow) and not swingLowBroken and close < lastSwingLow and close[1] >= lastSwingLow and downDisplacement

// HELPERS
f_top(float o, float h, float l, float c, bool demand) =>
    float bodyTop = math.max(o, c)
    float result = h
    if zoneMode == "Body"
        result := bodyTop
    else if zoneMode == "Refined"
        result := demand ? bodyTop : h
    result

f_bottom(float o, float h, float l, float c, bool demand) =>
    float bodyBottom = math.min(o, c)
    float result = l
    if zoneMode == "Body"
        result := bodyBottom
    else if zoneMode == "Refined"
        result := demand ? l : bodyBottom
    result

f_demandTouched(float top, float bottom, float mid) =>
    bool result = false
    if touchRule == "First Contact"
        result := low <= top
    else if touchRule == "50% Reached"
        result := low <= mid
    else
        result := low <= bottom
    result

f_supplyTouched(float top, float bottom, float mid) =>
    bool result = false
    if touchRule == "First Contact"
        result := high >= bottom
    else if touchRule == "50% Reached"
        result := high >= mid
    else
        result := high >= top
    result

f_demandInvalid(float bottom) =>
    invalidationRule == "Close Beyond" ? close < bottom : low < bottom

f_supplyInvalid(float top) =>
    invalidationRule == "Close Beyond" ? close > top : high > top

f_limitDemand() =>
    while array.size(demandBoxes) > maximumBlocks
        box b = array.shift(demandBoxes)
        line m = array.shift(demandLines)
        array.shift(demandCreated)
        array.shift(demandStates)
        box.delete(b)
        line.delete(m)

f_limitSupply() =>
    while array.size(supplyBoxes) > maximumBlocks
        box b = array.shift(supplyBoxes)
        line m = array.shift(supplyLines)
        array.shift(supplyCreated)
        array.shift(supplyStates)
        box.delete(b)
        line.delete(m)

// CREATE BLOCKS
bool newDemand = false
bool newSupply = false

if demandBreak
    swingHighBroken := true
    int offset = na
    for i = 1 to originSearch
        if na(offset) and close[i] < open[i]
            offset := i
    if not na(offset)
        float top = f_top(open[offset], high[offset], low[offset], close[offset], true)
        float bottom = f_bottom(open[offset], high[offset], low[offset], close[offset], true)
        float mid = (top + bottom) / 2.0
        int leftBar = bar_index - offset
        int rightBar = bar_index + forwardBars
        box b = box.new(left=leftBar, top=top, right=rightBar, bottom=bottom, border_color=demandColor, border_width=1, bgcolor=color.new(demandColor, freshTransparency), text=showLabels ? "DEMAND" : "", text_color=demandColor, text_size=size.tiny, text_halign=text.align_right)
        line m = line.new(x1=leftBar, y1=mid, x2=rightBar, y2=mid, color=showMidline ? color.new(demandColor, 20) : na, style=line.style_dashed, width=1)
        array.push(demandBoxes, b)
        array.push(demandLines, m)
        array.push(demandCreated, bar_index)
        array.push(demandStates, 0)
        f_limitDemand()
        newDemand := true
        if showStructureBreak
            label.new(bar_index, high, "Demand break", color=na, textcolor=demandColor, style=label.style_label_down, size=size.tiny)

if supplyBreak
    swingLowBroken := true
    int offset = na
    for i = 1 to originSearch
        if na(offset) and close[i] > open[i]
            offset := i
    if not na(offset)
        float top = f_top(open[offset], high[offset], low[offset], close[offset], false)
        float bottom = f_bottom(open[offset], high[offset], low[offset], close[offset], false)
        float mid = (top + bottom) / 2.0
        int leftBar = bar_index - offset
        int rightBar = bar_index + forwardBars
        box b = box.new(left=leftBar, top=top, right=rightBar, bottom=bottom, border_color=supplyColor, border_width=1, bgcolor=color.new(supplyColor, freshTransparency), text=showLabels ? "SUPPLY" : "", text_color=supplyColor, text_size=size.tiny, text_halign=text.align_right)
        line m = line.new(x1=leftBar, y1=mid, x2=rightBar, y2=mid, color=showMidline ? color.new(supplyColor, 20) : na, style=line.style_dashed, width=1)
        array.push(supplyBoxes, b)
        array.push(supplyLines, m)
        array.push(supplyCreated, bar_index)
        array.push(supplyStates, 0)
        f_limitSupply()
        newSupply := true
        if showStructureBreak
            label.new(bar_index, low, "Supply break", color=na, textcolor=supplyColor, style=label.style_label_up, size=size.tiny)

// MANAGE DEMAND
bool demandEntered = false
bool demandInvalidated = false

if array.size(demandBoxes) > 0
    int i = array.size(demandBoxes) - 1
    while i >= 0
        box b = array.get(demandBoxes, i)
        line m = array.get(demandLines, i)
        int created = array.get(demandCreated, i)
        int state = array.get(demandStates, i)
        float top = box.get_top(b)
        float bottom = box.get_bottom(b)
        float mid = (top + bottom) / 2.0
        box.set_right(b, bar_index + forwardBars)
        line.set_x2(m, bar_index + forwardBars)
        bool canCheck = bar_index > created
        bool invalid = canCheck and f_demandInvalid(bottom)
        bool touched = canCheck and not invalid and state == 0 and f_demandTouched(top, bottom, mid)
        if touched
            demandEntered := true
            if keepTouched
                array.set(demandStates, i, 1)
                box.set_bgcolor(b, color.new(demandColor, touchedTransparency))
                box.set_border_color(b, color.new(demandColor, 45))
            else
                box.delete(b)
                line.delete(m)
                array.remove(demandBoxes, i)
                array.remove(demandLines, i)
                array.remove(demandCreated, i)
                array.remove(demandStates, i)
        if invalid
            demandInvalidated := true
            if keepInvalidated
                box.set_right(b, bar_index)
                line.set_x2(m, bar_index)
                box.set_bgcolor(b, color.new(invalidatedColor, 92))
                box.set_border_color(b, invalidatedColor)
                line.set_color(m, color.new(invalidatedColor, 60))
            else
                box.delete(b)
                line.delete(m)
            array.remove(demandBoxes, i)
            array.remove(demandLines, i)
            array.remove(demandCreated, i)
            array.remove(demandStates, i)
        i -= 1

// MANAGE SUPPLY
bool supplyEntered = false
bool supplyInvalidated = false

if array.size(supplyBoxes) > 0
    int i = array.size(supplyBoxes) - 1
    while i >= 0
        box b = array.get(supplyBoxes, i)
        line m = array.get(supplyLines, i)
        int created = array.get(supplyCreated, i)
        int state = array.get(supplyStates, i)
        float top = box.get_top(b)
        float bottom = box.get_bottom(b)
        float mid = (top + bottom) / 2.0
        box.set_right(b, bar_index + forwardBars)
        line.set_x2(m, bar_index + forwardBars)
        bool canCheck = bar_index > created
        bool invalid = canCheck and f_supplyInvalid(top)
        bool touched = canCheck and not invalid and state == 0 and f_supplyTouched(top, bottom, mid)
        if touched
            supplyEntered := true
            if keepTouched
                array.set(supplyStates, i, 1)
                box.set_bgcolor(b, color.new(supplyColor, touchedTransparency))
                box.set_border_color(b, color.new(supplyColor, 45))
            else
                box.delete(b)
                line.delete(m)
                array.remove(supplyBoxes, i)
                array.remove(supplyLines, i)
                array.remove(supplyCreated, i)
                array.remove(supplyStates, i)
        if invalid
            supplyInvalidated := true
            if keepInvalidated
                box.set_right(b, bar_index)
                line.set_x2(m, bar_index)
                box.set_bgcolor(b, color.new(invalidatedColor, 92))
                box.set_border_color(b, invalidatedColor)
                line.set_color(m, color.new(invalidatedColor, 60))
            else
                box.delete(b)
                line.delete(m)
            array.remove(supplyBoxes, i)
            array.remove(supplyLines, i)
            array.remove(supplyCreated, i)
            array.remove(supplyStates, i)
        i -= 1

// ALERTS
alertcondition(newDemand, "New Demand Order Block", "New Demand Order Block on {{ticker}} {{interval}}.")
alertcondition(newSupply, "New Supply Order Block", "New Supply Order Block on {{ticker}} {{interval}}.")
alertcondition(demandEntered, "Demand Order Block Entered", "Price entered a Demand Order Block on {{ticker}} {{interval}}.")
alertcondition(supplyEntered, "Supply Order Block Entered", "Price entered a Supply Order Block on {{ticker}} {{interval}}.")
alertcondition(demandInvalidated, "Demand Order Block Invalidated", "A Demand Order Block was invalidated on {{ticker}} {{interval}}.")
alertcondition(supplyInvalidated, "Supply Order Block Invalidated", "A Supply Order Block was invalidated on {{ticker}} {{interval}}.")
````
