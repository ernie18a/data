# Equal Highs and Lows

- url: https://www.tradingview.com/script/VpVN1mYb-Equal-Highs-and-Lows/
- type: indicator
- pine_id: PUB;bccc343377c54bb68802d9ffe016e0c8
- version: 3.0

## Description

[image]https://www.tradingview.com/x/AjJF5HaO/[/image]

Equal Highs & Lows (Extended)

This indicator automatically detects equal highs (EQH) and equal lows (EQL) — price levels where the market has printed matching highs or lows — and marks them with horizontal lines that extend in real time to the current candle. These levels often act as resting liquidity (stop clusters) that price tends to revisit and sweep, making them useful reference points for liquidity-based and Smart Money Concepts (SMC) trading.

How it works
- Each new high is compared against prior highs within the lookback window (and each low against prior lows). When a match is found, a line is drawn connecting the two equal points and is continuously extended to the live candle as new bars form.
- An EQH or EQL label rides the right end of each line, so the level stays clearly marked as it extends.

"When Swept" behavior
Choose what happens once price wicks through a level (a high above an equal high, or a low below an equal low):
- Freeze – the line stops extending at the bar where the sweep occurs, leaving a clean record of where liquidity was taken.
- Keep Extending – the line keeps tracking the current candle even after the sweep.
- Remove – the line and its label are deleted the moment the level is swept, keeping the chart clear of taken liquidity.

Settings
- Lookback Length – how many bars back to search for equal highs/lows.
- Line Color / Width / Style – full control over the appearance of the high and low lines.
- Show EQH/EQL Labels – toggle the level labels on or off.
- When Swept – Freeze, Keep Extending, or Remove (as above).

Notes
Levels are matched at the exact price, so equal highs/lows appear most frequently on instruments that trade to consistent tick values (crypto, indices, futures). This tool is for chart analysis and does not generate buy/sell signals.

NOT FINANCIAL ADVICE OR BUY/SELL SIGNALS

## Source Code

````pine
//@version=6
// Copyright (c) © 2026 @cadejames19
// Modified: extending equal-high / equal-low lines with EQH/EQL labels, a "When Swept" mode,
// a minimum-distance filter, and an every-candle / swing-points detection source.
indicator("Equal Highs and Lows", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500)

// User inputs for customization
var lineColorHigh = input.color(color.red, "Line Color for Highs", group="Appearance", tooltip="Choose the color for lines marking equal highs.")
var lineColorLow = input.color(color.green, "Line Color for Lows", group="Appearance", tooltip="Choose the color for lines marking equal lows.")
var lineWidth = input.int(1, "Line Width", minval=1, maxval=5, step=1, group="Appearance", tooltip="Adjust the thickness of the lines. Range: 1 (thin) to 5 (thick).")
var detectionSource = input.string("Every Candle", "Detection Source", options=["Every Candle", "Swing Points Only"], group="Settings", tooltip="Every Candle: compare every candle's high/low (original behavior).\nSwing Points Only: only compare swing highs to swing highs and swing lows to swing lows. A swing high is a candle whose high is >= the candle on each immediate side; a swing low is a candle whose low is <= the candle on each side.")
var swingTiming = input.string("Confirmed", "Swing Timing", options=["Confirmed", "Realtime"], group="Settings", tooltip="Only used when Detection Source = Swing Points Only.\nConfirmed: waits for the next candle to close before locking a swing (lags by 1 bar, never repaints).\nRealtime: the current candle becomes a swing the moment it closes at/above the prior candle (no right-side candle needed), plus a live preview line that updates every tick. Faster, but a level can be invalidated by later candles.")
var lookbackLength = input.int(200, "Lookback Length", minval=1, group="Settings", tooltip="Set the number of bars to look back for finding equal highs and lows.")
var minGap = input.int(1, "Minimum Candles Apart", minval=1, group="Settings", tooltip="Require the two equal highs (or lows) to be at least this many candles apart before a line is drawn. Measured as the difference in bar position between the two points (e.g. a high on bar 100 and bar 105 is 5 apart). 1 = no minimum, matches any spacing.")
var lineStyle = input.string("Solid", "Line Style", options=["Solid", "Dash", "Dotted"], group="Appearance", tooltip="Select the style of the lines: Solid, Dash, or Dotted.")
var showEqLabels = input.bool(true, "Show EQH/EQL Labels", group="Appearance", tooltip="Show an EQH label at the right end of each equal-high line and an EQL label at the right end of each equal-low line. The label rides the line as it extends to the current candle.")
var sweepMode = input.string("Freeze", "When Swept", options=["Freeze", "Keep Extending", "Remove"], group="Settings", tooltip="What to do once price wicks through a level (a high above an equal high, or a low below an equal low):\n• Freeze – stop extending the line/label at the bar where the sweep happens.\n• Keep Extending – keep tracking the current candle even after the sweep.\n• Remove – delete the line and label as soon as the level is swept.")
var showLabels = input.bool(false, "Show Debug Labels", tooltip="Toggle to show or hide labels for equal highs and lows. Useful for debugging.")

// Convert user input line style to line style type
lineStyleType() =>
    switch lineStyle
        "Dash" => line.style_dashed
        "Dotted" => line.style_dotted
        "Solid" => line.style_solid

// Tracks every equal-high / equal-low level so it can be extended and sweep-checked each bar
type EqLevel
    line  ln
    label lb
    float price
    bool  isHigh
    bool  swept

var array<EqLevel> levels = array.new<EqLevel>()

// Swing-point history (only used in "Swing Points Only" mode)
var array<float> shPrice = array.new<float>()   // confirmed swing-high prices
var array<int>   shBar   = array.new<int>()     // their bar_index
var array<float> slPrice = array.new<float>()   // confirmed swing-low prices
var array<int>   slBar   = array.new<int>()     // their bar_index
var int lastShBar = -1
var int lastSlBar = -1

// Search stored swing points for the nearest exact-equal one that is >= minGap away,
// within the lookback, with nothing higher (for highs) / lower (for lows) in between.
// Returns the matching bar_index, or -1 if none qualifies.
findEqualSwing(pArr, bArr, p, curBar, isHigh) =>
    result = -1
    n = array.size(pArr)
    if n > 0
        for j = n - 1 to 0
            pj = array.get(pArr, j)
            bj = array.get(bArr, j)
            dist = curBar - bj
            if dist > lookbackLength
                break
            blocked = isHigh ? (pj > p) : (pj < p)
            if blocked
                break
            if pj == p and dist >= minGap
                result := bj
                break
    result

findAndDrawEqualHighs(src, length, arr) =>
    found = false
    for i = 1 to length
        if not found and src[i] == src[0] and i >= minGap
            ln = line.new(x1=bar_index[i], y1=src[i], x2=bar_index, y2=src[0], width=lineWidth, color=lineColorHigh, style=lineStyleType())
            label lb = na
            if showEqLabels
                lb := label.new(x=bar_index, y=src[0], text="EQH", style=label.style_label_lower_right, color=color.new(color.white, 100), textcolor=chart.fg_color, size=size.small)
            array.push(arr, EqLevel.new(ln = ln, lb = lb, price = src[0], isHigh = true, swept = false))
            if showLabels
                // Calculate midpoint for the label
                midPointX = (bar_index[0] + bar_index[i]) / 2
                midPointY = src[0]
                label.new(x=midPointX, y=midPointY, text="Equal High", color=color.new(color.red, 0), style=label.style_label_center, size=size.normal)
            found := true
        if src[i] > src[0]
            break

findAndDrawEqualLows(src, length, arr) =>
    found = false
    for i = 1 to length
        if not found and src[i] == src[0] and i >= minGap
            ln = line.new(x1=bar_index[i], y1=src[i], x2=bar_index, y2=src[0], width=lineWidth, color=lineColorLow, style=lineStyleType())
            label lb = na
            if showEqLabels
                lb := label.new(x=bar_index, y=src[0], text="EQL", style=label.style_label_lower_right, color=color.new(color.white, 100), textcolor=chart.fg_color, size=size.small)
            array.push(arr, EqLevel.new(ln = ln, lb = lb, price = src[0], isHigh = false, swept = false))
            if showLabels
                // Calculate midpoint for the label
                midPointX = (bar_index[0] + bar_index[i]) / 2
                midPointY = src[0]
                label.new(x=midPointX, y=midPointY, text="Equal Low", color=color.new(color.green, 0), style=label.style_label_center, size=size.normal)
            found := true
        if src[i] < src[0]
            break

// ---- Detection ----
if detectionSource == "Swing Points Only"
    isRT = swingTiming == "Realtime"

    // Swing HIGH: 1-bar pivot, ties allowed. Confirmed uses the previous bar as the pivot
    // (needs the current bar closed on its right); Realtime uses the current bar (no right bar).
    swHighCond = isRT ? (high >= high[1]) : (high[1] >= high[2] and high[1] >= high[0])
    bH = isRT ? bar_index : bar_index - 1
    pH = isRT ? high : high[1]
    if barstate.isconfirmed and swHighCond and bH != lastShBar
        lastShBar := bH
        while array.size(shBar) > 0 and (bH - array.get(shBar, 0)) > lookbackLength
            array.shift(shBar)
            array.shift(shPrice)
        mBarH = findEqualSwing(shPrice, shBar, pH, bH, true)
        if mBarH >= 0
            lnH = line.new(x1=mBarH, y1=pH, x2=bH, y2=pH, width=lineWidth, color=lineColorHigh, style=lineStyleType())
            label lbH = na
            if showEqLabels
                lbH := label.new(x=bH, y=pH, text="EQH", style=label.style_label_lower_right, color=color.new(color.white, 100), textcolor=chart.fg_color, size=size.small)
            array.push(levels, EqLevel.new(ln = lnH, lb = lbH, price = pH, isHigh = true, swept = false))
            if showLabels
                label.new(x=(bH + mBarH) / 2, y=pH, text="Equal High", color=color.new(color.red, 0), style=label.style_label_center, size=size.normal)
        array.push(shPrice, pH)
        array.push(shBar, bH)

    // Swing LOW: mirror of the above
    swLowCond = isRT ? (low <= low[1]) : (low[1] <= low[2] and low[1] <= low[0])
    bL = isRT ? bar_index : bar_index - 1
    pL = isRT ? low : low[1]
    if barstate.isconfirmed and swLowCond and bL != lastSlBar
        lastSlBar := bL
        while array.size(slBar) > 0 and (bL - array.get(slBar, 0)) > lookbackLength
            array.shift(slBar)
            array.shift(slPrice)
        mBarL = findEqualSwing(slPrice, slBar, pL, bL, false)
        if mBarL >= 0
            lnL = line.new(x1=mBarL, y1=pL, x2=bL, y2=pL, width=lineWidth, color=lineColorLow, style=lineStyleType())
            label lbL = na
            if showEqLabels
                lbL := label.new(x=bL, y=pL, text="EQL", style=label.style_label_lower_right, color=color.new(color.white, 100), textcolor=chart.fg_color, size=size.small)
            array.push(levels, EqLevel.new(ln = lnL, lb = lbL, price = pL, isHigh = false, swept = false))
            if showLabels
                label.new(x=(bL + mBarL) / 2, y=pL, text="Equal Low", color=color.new(color.green, 0), style=label.style_label_center, size=size.normal)
        array.push(slPrice, pL)
        array.push(slBar, bL)

    // Realtime intrabar preview: transient lines that Pine redraws every tick on the
    // forming candle and rolls back automatically (not stored, so state stays clean).
    if isRT and not barstate.isconfirmed
        if high >= high[1]
            pmH = findEqualSwing(shPrice, shBar, high, bar_index, true)
            if pmH >= 0
                line.new(x1=pmH, y1=high, x2=bar_index, y2=high, width=lineWidth, color=lineColorHigh, style=lineStyleType())
                if showEqLabels
                    label.new(x=bar_index, y=high, text="EQH", style=label.style_label_lower_right, color=color.new(color.white, 100), textcolor=chart.fg_color, size=size.small)
        if low <= low[1]
            pmL = findEqualSwing(slPrice, slBar, low, bar_index, false)
            if pmL >= 0
                line.new(x1=pmL, y1=low, x2=bar_index, y2=low, width=lineWidth, color=lineColorLow, style=lineStyleType())
                if showEqLabels
                    label.new(x=bar_index, y=low, text="EQL", style=label.style_label_lower_right, color=color.new(color.white, 100), textcolor=chart.fg_color, size=size.small)
else
    // Every-candle detection (original behavior)
    findAndDrawEqualHighs(high, lookbackLength, levels)
    findAndDrawEqualLows(low, lookbackLength, levels)

// Keep the tracked list bounded (in step with max_lines_count) by dropping the oldest levels
while array.size(levels) > 490
    old = array.shift(levels)
    line.delete(old.ln)
    if not na(old.lb)
        label.delete(old.lb)

// Extend each level to the current candle, and apply the "When Swept" behavior
if array.size(levels) > 0
    for idx = array.size(levels) - 1 to 0
        lv = array.get(levels, idx)
        alreadyFrozen = lv.swept and sweepMode == "Freeze"
        if not alreadyFrozen
            // Wick-through sweep: high above an equal high, or low below an equal low
            sweptNow = lv.isHigh ? (high > lv.price) : (low < lv.price)
            if sweptNow and not lv.swept
                lv.swept := true
                if sweepMode == "Remove"
                    line.delete(lv.ln)
                    if not na(lv.lb)
                        label.delete(lv.lb)
                    array.remove(levels, idx)
                else
                    // Freeze or Keep Extending: pin/extend to the sweep bar
                    line.set_x2(lv.ln, bar_index)
                    if not na(lv.lb)
                        label.set_x(lv.lb, bar_index)
                        label.set_y(lv.lb, lv.price)
            else
                // Not swept (or Keep Extending after a sweep): follow the current candle
                line.set_x2(lv.ln, bar_index)
                if not na(lv.lb)
                    label.set_x(lv.lb, bar_index)
                    label.set_y(lv.lb, lv.price)
````
