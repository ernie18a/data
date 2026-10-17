# [SkuldX] Order Blocks

- url: https://www.tradingview.com/script/NlAeJFND-SkuldX-Order-Blocks/
- type: indicator
- pine_id: PUB;c15dd05ec1bb46968c9dd160727e2134
- version: 1.0

## Description

SkuldX Order Blocks — Institutional Entry Zone Detector
by SkuldX Trading Systems

[b]What is it?[/b]
SkuldX Order Blocks automatically identifies the price zones where institutional participants placed their large orders before a significant directional move. These zones — known as Order Blocks in ICT methodology — act as magnets for price on retracements and represent the highest-probability entry points in the market. When price returns to an Order Block, institutions defend their positions, creating predictable reactions that retail traders can exploit.

[b]The core concept[/b]
Every significant market move starts with institutional order flow. Before price can move strongly in one direction, large buy or sell orders must be placed. These orders leave a footprint — the last opposing candle before the impulse move. A bullish Order Block is the last bearish candle before a strong upward impulse that breaks a swing high. A bearish Order Block is the last bullish candle before a strong downward impulse that breaks a swing low.
The logic is straightforward: institutions placed their orders inside that candle zone. When price returns to that zone, those same institutions are likely to defend their positions — creating a high-probability reaction. The zone becomes a structural entry point rather than a random support or resistance level.

[b]Bullish Order Block[/b]
A bullish OB forms when a confirmed swing low develops after a strong downward move. The indicator looks back from the pivot and identifies the last bearish candle (close below open) that preceded the bullish impulse. The entire candle range — from its low to its high — becomes the Order Block zone.
When price retraces back into this zone, it is returning to where institutional buying was concentrated. This is where longs have the highest structural justification.

[b]Bearish Order Block[/b]
A bearish OB forms when a confirmed swing high develops after a strong upward move. The last bullish candle before the bearish impulse defines the zone. When price retraces into it, institutional sellers are defending their short positions.

[b]Mitigation[/b]
An Order Block is considered mitigated when price re-enters the zone. Mitigation is the moment the OB is being tested — either institutions defend it and price rejects, or they have exited and the zone fails. The indicator marks mitigated OBs with a lighter color and adds a ✓ to the label so you can instantly distinguish fresh unmitigated zones from already-tested ones.
Mitigated OBs can be hidden entirely via the Show Mitigated OB toggle — keeping the chart clean by only showing untested zones.

[b]What you see on the chart[/b]
Colored zone box — the Order Block price range from the candle's low to its high. Green for bullish, red for bearish. The box extends rightward until price mitigates the zone or the OB is displaced by a newer one.
50% midline — a dotted line at the exact midpoint of the OB zone. The 50% level is the most common precise entry within an OB — it offers the best risk-reward by entering in the middle of the zone with a stop beyond the far edge.
Label — shows the OB type (Bull OB / Bear OB) and the exact price range of the zone. Updates to show ✓ when mitigated.
Mitigation color change — when price enters the zone, the box transitions to a lighter transparent color. Fresh unmitigated zones remain at full opacity for immediate visual priority.

[b]Settings reference[/b]
Swing Lookback — how many bars on each side define a confirmed pivot. Default 5. Lower values find more frequent OBs. Higher values require more significant structural pivots and produce fewer but stronger zones.
Min Impulse Size % — the minimum size of the impulse candle as a percentage of price. Filters out weak moves that produce low-quality OBs. Default 0.1%. Increase to 0.3–0.5% on volatile instruments to require more decisive institutional moves.
Max OB to Show — limits visible OBs to the N most recent. Oldest OBs are automatically removed when the limit is reached. Default 5. Increase to see more historical zones.
Show Bullish / Bearish OB — independent toggles for each direction
Bullish / Bearish OB Color — color of the active unmitigated zone
Mitigated Color — color of the zone after price has entered it
Show Mitigated OB — keep mitigated zones visible or remove them automatically
Show 50% Midline — toggle the dotted midpoint line within each OB
Show Labels — toggle the price range labels
Label Size — tiny, small, or normal
Line Width — border thickness of the OB box

[b]Data Window[/b]
Hovering over any bar shows the nearest active unmitigated Bullish OB above price and the nearest active unmitigated Bearish OB below price — giving the two closest institutional reference zones at a glance. Also shows the total count of currently active OBs.

[b]How to use it in practice[/b]
Entry at the OB — when price retraces into an unmitigated OB, wait for a confirmation candle before entering. A bullish rejection candle (hammer, engulfing, or pin bar) inside the bullish OB zone is a high-probability long entry. Stop goes below the OB low. Target is the next structural high or bearish OB above.
50% entry — for better risk-reward, enter at the 50% midline rather than waiting for price to reach the bottom of the zone. This gives more room before the stop and a larger move to target.
Fresh vs mitigated — always prioritize fresh unmitigated OBs. A zone that has already been entered once has partially absorbed institutional orders and is less reliable on subsequent tests. When Show Mitigated OB is enabled, the visual distinction between fresh and tested zones is immediate.
OB + structure alignment — the most reliable setups occur when an OB aligns with the current market structure. A bullish OB that forms after a bullish CHoCH is significantly stronger than one that forms in a bearish trend — structure and OB direction agree. Use SkuldX Market Structure alongside this indicator to confirm alignment.
Multiple timeframe approach — identify OBs on a higher timeframe (1h or 4h) for the macro zones, then switch to 15m or 5m for precise entry timing when price reaches those zones. A 4h bullish OB that price approaches on the 15m chart is the ideal setup for a precise entry with a tight stop.

[b]Part of the SkuldX Suite[/b]
SkuldX Order Blocks integrates with the full suite to create high-confluence setups:
[list]
[*]A bullish OB that coincides with an Asian Low or VAL level from SkuldX Sessions creates double structural significance — session boundary and institutional order zone at the same price
[*]A CHoCH ▲ from SkuldX Market Structure followed by price returning to a bullish OB is the classic ICT reversal entry — structure changed and price is now offering a discounted entry at the institutional zone
[*]A bullish SFP that fires inside a bullish OB zone is one of the strongest setups available — liquidity was swept below the OB and price rejected, confirming institutional defense of the zone
[*]An OB that aligns with an ADR Low from SkuldX ADR Levels adds statistical confirmation that price is at a significant daily extreme while simultaneously at an institutional entry zone
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] Order Blocks", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)


// ══════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════

// Detection
pivotLen       = input.int(5,    "Swing Lookback (bars each side)", group = "Detection", minval = 2, maxval = 50)
impulsePct     = input.float(0.1,"Min Impulse Size %",              group = "Detection", minval = 0.0, maxval = 5.0, step = 0.05,
     tooltip = "Minimum size of the impulse candle that breaks structure, as % of price. Filters weak moves.")
maxOBCount     = input.int(5,    "Max OB to Show",                  group = "Detection", minval = 1, maxval = 20)

// Bullish OB
showBullOB     = input.bool(true, "Show Bullish OB",                group = "Bullish OB")
colorBullOB    = input.color(color.new(color.green, 75), "Bullish OB Color", group = "Bullish OB")
colorBullMit   = input.color(color.new(color.green, 90), "Mitigated Color",  group = "Bullish OB")

// Bearish OB
showBearOB     = input.bool(true, "Show Bearish OB",                group = "Bearish OB")
colorBearOB    = input.color(color.new(color.red,   75), "Bearish OB Color", group = "Bearish OB")
colorBearMit   = input.color(color.new(color.red,   90), "Mitigated Color",  group = "Bearish OB")

// Display
showMidline    = input.bool(true,  "Show 50% Midline",              group = "Display")
showLabel      = input.bool(true,  "Show Labels",                   group = "Display")
showMitigated  = input.bool(true,  "Show Mitigated OB",             group = "Display",
     tooltip = "Keep mitigated OBs visible with a different color. Disable to remove them when price enters the zone.")
labelSize      = input.string("small", "Label Size",                group = "Display", options = ["tiny", "small", "normal"])
obLineWidth    = input.int(1,      "Line Width",                    group = "Display", minval = 1, maxval = 4)


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

szVal() =>
    switch labelSize
        "tiny"   => size.tiny
        "normal" => size.normal
        =>          size.small

// Impulse candle size as % of price
impulseSizePct(int i) =>
    math.abs(close[i] - open[i]) / open[i] * 100


// ══════════════════════════════════════════════════════
// PIVOT DETECTION
// Confirmed pivot highs and lows — N bars each side
// ══════════════════════════════════════════════════════

float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low,  pivotLen, pivotLen)


// ══════════════════════════════════════════════════════
// ORDER BLOCK STORAGE
// Each OB stores: top, bottom, mid, start bar, isBull, isMitigated
// ══════════════════════════════════════════════════════

var float[] obTop      = array.new_float()
var float[] obBot      = array.new_float()
var float[] obMid      = array.new_float()
var int[]   obBar      = array.new_int()
var bool[]  obIsBull   = array.new_bool()
var bool[]  obMitFlag  = array.new_bool()
var box[]   obBoxes    = array.new_box()
var line[]  obMidlines = array.new_line()
var label[] obLabels   = array.new_label()


// ══════════════════════════════════════════════════════
// OB DETECTION
//
// Bullish OB:
// New pivot low forms → impulse broke previous swing low
// → find the LAST bearish candle before the impulse
// → that candle is the Bullish OB zone
//
// Bearish OB:
// New pivot high forms → impulse broke previous swing high
// → find the LAST bullish candle before the impulse
// → that candle is the Bearish OB zone
// ══════════════════════════════════════════════════════

addOB(float top, float bot, int startBar, bool isBull) =>
    // Limit to maxOBCount — remove oldest if exceeded
    if array.size(obTop) >= maxOBCount
        // Delete visual objects of oldest OB
        if array.size(obBoxes) > 0
            box.delete(array.shift(obBoxes))
        if array.size(obMidlines) > 0
            line.delete(array.shift(obMidlines))
        if array.size(obLabels) > 0
            label.delete(array.shift(obLabels))
        array.shift(obTop)
        array.shift(obBot)
        array.shift(obMid)
        array.shift(obBar)
        array.shift(obIsBull)
        array.shift(obMitFlag)

    float mid   = (top + bot) / 2
    color clr   = isBull ? colorBullOB : colorBearOB
    string lbl  = isBull ? "Bull OB" : "Bear OB"

    // Box
    newBox = box.new(
         left         = startBar,
         top          = top,
         right        = bar_index + 1,
         bottom       = bot,
         bgcolor      = clr,
         border_color = color.new(isBull ? color.green : color.red, 40),
         border_width = obLineWidth,
         extend       = extend.none)

    // Midline (50% level)
    line newLine = na
    if showMidline
        newLine := line.new(
             x1    = startBar,
             y1    = mid,
             x2    = bar_index + 1,
             y2    = mid,
             color = color.new(isBull ? color.green : color.red, 30),
             width = 1,
             style = line.style_dotted)

    // Label
    label newLabel = na
    if showLabel
        newLabel := label.new(
             x         = startBar,
             y         = isBull ? bot : top,
             text      = lbl + "\n" + str.tostring(top, format.mintick) +
                         " — " + str.tostring(bot, format.mintick),
             style     = isBull ? label.style_label_up : label.style_label_down,
             color     = color.new(isBull ? color.green : color.red, 40),
             textcolor = color.white,
             size      = szVal())

    // Store
    array.push(obTop,      top)
    array.push(obBot,      bot)
    array.push(obMid,      mid)
    array.push(obBar,      startBar)
    array.push(obIsBull,   isBull)
    array.push(obMitFlag,  false)
    array.push(obBoxes,    newBox)
    array.push(obMidlines, showMidline ? newLine : na)
    array.push(obLabels,   showLabel   ? newLabel : na)


// ── Bullish OB detection — on new confirmed pivot low ──
if not na(pl) and showBullOB
    // The impulse that broke structure starts at pivotLen bars ago
    // Look back from pivot for the last bearish candle (close < open)
    // that preceded the bullish impulse
    int   obCandleIdx = na
    float obTop_      = na
    float obBot_      = na

    // Search back from pivot for last bearish candle
    for i = pivotLen to pivotLen + 10
        if i < bar_index and close[i] < open[i]
            // Check impulse size
            if impulseSizePct(i - 1) >= impulsePct or impulseSizePct(i) >= impulsePct
                obCandleIdx := bar_index - i
                obTop_      := high[i]
                obBot_      := low[i]
                break

    if not na(obCandleIdx) and not na(obTop_)
        addOB(obTop_, obBot_, obCandleIdx, true)


// ── Bearish OB detection — on new confirmed pivot high ──
if not na(ph) and showBearOB
    int   obCandleIdx = na
    float obTop_      = na
    float obBot_      = na

    // Search back from pivot for last bullish candle
    for i = pivotLen to pivotLen + 10
        if i < bar_index and close[i] > open[i]
            if impulseSizePct(i - 1) >= impulsePct or impulseSizePct(i) >= impulsePct
                obCandleIdx := bar_index - i
                obTop_      := high[i]
                obBot_      := low[i]
                break

    if not na(obCandleIdx) and not na(obTop_)
        addOB(obTop_, obBot_, obCandleIdx, false)


// ══════════════════════════════════════════════════════
// MITIGATION + EXTEND
// On every bar:
// 1. Extend active OB boxes and midlines rightward
// 2. Check if price has entered the OB zone (mitigation)
// 3. On mitigation: change color or delete based on settings
// ══════════════════════════════════════════════════════

if array.size(obTop) > 0
    for i = 0 to array.size(obTop) - 1
        float top     = array.get(obTop,     i)
        float bot     = array.get(obBot,     i)
        bool  isBull  = array.get(obIsBull,  i)
        bool  isMit   = array.get(obMitFlag, i)
        box   bx      = array.get(obBoxes,   i)
        line  ml      = array.get(obMidlines,i)

        // Extend rightward
        if not na(bx)
            box.set_right(bx, bar_index + 1)
        if not na(ml)
            line.set_x2(ml, bar_index + 1)

        // Mitigation check — price enters OB zone
        bool mitigated = isBull ? low <= top and low >= bot :
                                  high >= bot and high <= top

        if mitigated and not isMit
            array.set(obMitFlag, i, true)

            if showMitigated
                // Change to mitigated color
                color mitClr = isBull ? colorBullMit : colorBearMit
                if not na(bx)
                    box.set_bgcolor(bx, mitClr)
                    box.set_border_color(bx, color.new(isBull ? color.green : color.red, 70))
                if not na(ml)
                    line.set_color(ml, color.new(isBull ? color.green : color.red, 70))
                // Update label
                lb = array.get(obLabels, i)
                if not na(lb)
                    label.set_text(lb,
                         (isBull ? "Bull OB ✓" : "Bear OB ✓") + "\n" +
                         str.tostring(top, format.mintick) +
                         " — " + str.tostring(bot, format.mintick))
                    label.set_color(lb, color.new(isBull ? color.green : color.red, 70))
            else
                // Delete mitigated OB
                if not na(bx)
                    box.delete(bx)
                    array.set(obBoxes, i, na)
                if not na(ml)
                    line.delete(ml)
                    array.set(obMidlines, i, na)
                lb = array.get(obLabels, i)
                if not na(lb)
                    label.delete(lb)
                    array.set(obLabels, i, na)


// ══════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════

// Nearest active OB above and below price
float nearBullOB = na
float nearBearOB = na

if array.size(obTop) > 0
    for i = 0 to array.size(obTop) - 1
        float top    = array.get(obTop,    i)
        float bot    = array.get(obBot,    i)
        bool  isBull = array.get(obIsBull, i)
        bool  isMit  = array.get(obMitFlag,i)
        if not isMit
            if isBull and top < close
                if na(nearBullOB) or top > nearBullOB
                    nearBullOB := top
            if not isBull and bot > close
                if na(nearBearOB) or bot < nearBearOB
                    nearBearOB := bot

plot(nearBullOB, "Nearest Bull OB", color = color.new(color.green, 100), display = display.data_window)
plot(nearBearOB, "Nearest Bear OB", color = color.new(color.red,   100), display = display.data_window)
plot(float(array.size(obTop)), "Active OB Count", color = color.new(color.gray, 100), display = display.data_window)
````
