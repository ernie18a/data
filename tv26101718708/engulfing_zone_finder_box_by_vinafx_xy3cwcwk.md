# Engulfing Zone Finder (Box) by vinafx

- url: https://www.tradingview.com/script/xY3cWcWk-Engulfing-Zone-Finder-Box-by-vinafx/
- type: indicator
- pine_id: PUB;1d40bcd19b844e0cb2b88e23caac8367
- version: 1.0

## Description

[b]Engulfing Zone (EG) Finder[/b] is an overlay indicator that automatically detects and draws boxes for two types of momentum-based price action patterns: [b]Engulfing Zones[/b] and [b]Outside Bar Zones[/b].

[h2]🔷 Engulfing Zone (EG)[/h2]

An Engulfing Zone forms when a sequence of candles results in a breakout candle (BO) that closes beyond the high or low of an origin candle. Unlike the traditional 2-candle engulfing pattern, this indicator allows intermediate candles between the origin and the breakout candle, capturing a broader range of momentum shifts.

[b]Bullish Engulfing Zone[/b]
[list]
[*]The origin candle is a [b]bearish[/b] candle.
[*]A subsequent [b]bullish[/b] candle closes [b]above the high[/b] of the origin candle — this is the breakout (BO) candle.
[*]A box is drawn from the origin candle to the BO candle, with the top and bottom set to the [b]high and low of the origin candle[/b].
[*]The box is drawn with a [b]green[/b] border by default.
[/list]

[b]Bearish Engulfing Zone[/b]
[list]
[*]The origin candle is a [b]bullish[/b] candle.
[*]A subsequent [b]bearish[/b] candle closes [b]below the low[/b] of the origin candle — this is the breakout (BO) candle.
[*]A box is drawn from the origin candle to the BO candle, with the top and bottom set to the [b]high and low of the origin candle[/b].
[*]The box is drawn with a [b]red[/b] border by default.
[/list]

[b]Smart filtering logic built in:[/b]
[list]
[*][b]Origin Shift[/b]: If a new candle of the same type sweeps the wick of the current origin candle, it automatically replaces the origin. For example, if a new bearish candle has a higher high than the existing bearish origin, the new candle becomes the origin.
[*][b]Opposite Break Invalidation[/b]: If price closes beyond the opposite side of the origin candle before a valid breakout occurs, the origin is discarded.
[*][b]Nested Zone Filtering[/b]: If a smaller EG zone exists inside a larger one (same type), the indicator keeps the smaller zone and removes the larger one, reducing visual clutter.
[*][b]Max Candle Duration[/b]: A configurable limit (default: 5) controls the maximum total number of candles from origin to BO (inclusive). This prevents excessively long zones.
[/list]

[h2]🔶 Outside Bar Zone (OB)[/h2]

An Outside Bar Zone is a 2-candle pattern where the second candle completely engulfs the first candle's range (higher high AND lower low), and both candles share the same direction.

[b]Bullish Outside Bar Zone[/b]
[list]
[*]Two consecutive [b]bullish[/b] candles.
[*]The second candle has a [b]higher high[/b] and a [b]lower low[/b] than the first.
[*]The second candle's close is [b]above the high[/b] of the first candle.
[*]A box is drawn covering the first candle, with a [b]green[/b] border by default.
[/list]

[b]Bearish Outside Bar Zone[/b]
[list]
[*]Two consecutive [b]bearish[/b] candles.
[*]The second candle has a [b]higher high[/b] and a [b]lower low[/b] than the first.
[*]The second candle's close is [b]below the low[/b] of the first candle.
[*]A box is drawn covering the first candle, with a [b]red[/b] border by default.
[/list]

[h2]⚙️ Settings[/h2]

[b]Engulfing Zone Settings (Bullish / Bearish)[/b]
[list]
[*]Show/Hide: Toggle visibility for each zone type independently.
[*]Border Color: Customize the box border color.
[*]Background Color: Customize the box fill color and transparency.
[/list]

[b]Outside Bar Zone Settings[/b]
[list]
[*]Show/Hide: Toggle visibility for Bullish and Bearish OB Zones independently.
[*]Border Color / Background Color: Fully customizable for each type.
[/list]

[b]Performance & Limits[/b]
[list]
[*][b]Max Total Candles (Origin to BO)[/b]: Controls how many candles (including origin and BO) are allowed to form an EG zone. Default is 5. Set to 0 for no limit.
[*][b]Max Pending Origin Candles[/b]: Limits the number of origin candles tracked simultaneously. Default is 100.
[*][b]Max Total Boxes Displayed[/b]: Limits the total number of boxes drawn on the chart across all zone types. The quota is shared flexibly — if one type produces fewer boxes, the remaining capacity is available for other types. Default is 200. TradingView maximum is 500.
[/list]

[h2]📝 Notes[/h2]

[list]
[*]This indicator is an [b]overlay[/b] and draws directly on the price chart.
[*]It works on [b]all timeframes[/b] and [b]all instruments[/b] (stocks, forex, crypto, futures, etc.).
[*]Doji candles (where close equals open) are included in the detection logic. A Doji is treated as both bearish and bullish, so it can serve as an origin candle, a breakout candle, or part of an Outside Bar pattern.
[*]The indicator uses [b]open-source[/b] Pine Script v5. No external data requests or repainting techniques are used.
[/list]

## Source Code

````pine
//@version=6
indicator('Engulfing Zone Finder (Box) by vinafx', overlay = true, max_boxes_count = 500)

// =========================================================================
// INPUTS - CONFIGURATION
// =========================================================================
gp_bull = 'Bullish Engulfing Zone Settings'
show_bull = input.bool(true, 'Show Bullish EG Zones', group = gp_bull)
bull_color = input.color(color.new(color.green, 0), 'Bullish Border Color', group = gp_bull)
bull_fill = input.color(color.new(color.green, 92), 'Bullish Background Color', group = gp_bull)

gp_bear = 'Bearish Engulfing Zone Settings'
show_bear = input.bool(true, 'Show Bearish EG Zones', group = gp_bear)
bear_color = input.color(color.new(color.red, 0), 'Bearish Border Color', group = gp_bear)
bear_fill = input.color(color.new(color.red, 92), 'Bearish Background Color', group = gp_bear)

gp_ob = 'Outside Bar Zone Settings'
show_ob_bull = input.bool(true, 'Show Bullish OB Zones', group = gp_ob)
ob_bull_color = input.color(color.new(color.green, 0), 'Bullish OB Border Color', group = gp_ob)
ob_bull_fill = input.color(color.new(color.green, 92), 'Bullish OB Background Color', group = gp_ob)
show_ob_bear = input.bool(true, 'Show Bearish OB Zones', group = gp_ob)
ob_bear_color = input.color(color.new(color.red, 0), 'Bearish OB Border Color', group = gp_ob)
ob_bear_fill = input.color(color.new(color.red, 92), 'Bearish OB Background Color', group = gp_ob)

gp_perf = 'Performance & Limits'
max_wait = input.int(5, 'Max Total Candles (Origin to BO)', minval = 0, tooltip = 'Maximum total candles (including origin and BO candle) to form an EG zone. Set to 0 for no limit.', group = gp_perf)
max_pending = input.int(100, 'Max Pending Origin Candles', minval = 10, maxval = 200, tooltip = 'Limits the array size to ensure the indicator runs smoothly.', group = gp_perf)
box_limit = input.int(200, 'Max Total Boxes Displayed', minval = 10, maxval = 500, tooltip = 'Limits the TOTAL number of boxes of all types (EG + OB) drawn on the chart. Quota is shared flexibly between zone types. TradingView limits max 500 boxes.', group = gp_perf)

// =========================================================================
// STRUCTURES & TYPES
// =========================================================================
// Structure to store origin candle information
type CandleInfo
	int index
	float high
	float low

// =========================================================================
// STORAGE - PERSISTENT DATA PER BAR
// =========================================================================
var bearishPending = array.new<CandleInfo>()
var bullishPending = array.new<CandleInfo>()
var bullBoxes = array.new<box>()
var bearBoxes = array.new<box>()
var bullObBoxes = array.new<box>()
var bearObBoxes = array.new<box>()

// =========================================================================
// FUNCTIONS - HELPER FUNCTIONS
// =========================================================================
// Remove the oldest box when TOTAL box count across all types exceeds the limit (shared quota)
clean_all_boxes(int limit) =>
    int total = array.size(bullBoxes) + array.size(bearBoxes) + array.size(bullObBoxes) + array.size(bearObBoxes)
    while total > limit
        // Find the array containing the oldest box (first element with smallest left index)
        int min_left = 999999999
        int target = -1
        if array.size(bullBoxes) > 0 and box.get_left(array.get(bullBoxes, 0)) < min_left
            min_left := box.get_left(array.get(bullBoxes, 0))
            target := 0
            target
        if array.size(bearBoxes) > 0 and box.get_left(array.get(bearBoxes, 0)) < min_left
            min_left := box.get_left(array.get(bearBoxes, 0))
            target := 1
            target
        if array.size(bullObBoxes) > 0 and box.get_left(array.get(bullObBoxes, 0)) < min_left
            min_left := box.get_left(array.get(bullObBoxes, 0))
            target := 2
            target
        if array.size(bearObBoxes) > 0 and box.get_left(array.get(bearObBoxes, 0)) < min_left
            min_left := box.get_left(array.get(bearObBoxes, 0))
            target := 3
            target
        if target == 0
            box.delete(array.shift(bullBoxes))
        else if target == 1
            box.delete(array.shift(bearBoxes))
        else if target == 2
            box.delete(array.shift(bullObBoxes))
        else if target == 3
            box.delete(array.shift(bearObBoxes))
        total := total - 1
        total

// =========================================================================
// CORE LOGIC - MAIN PROCESSING
// =========================================================================
is_bearish = close <= open
is_bullish = close >= open

// 1. CHECK BREAKOUT FOR PENDING BEARISH ORIGIN CANDLES (BULLISH EG ZONE)
if array.size(bearishPending) > 0
    // Iterate array backwards to safely remove elements directly
    for i = array.size(bearishPending) - 1 to 0 by 1
        CandleInfo candle = array.get(bearishPending, i)

        // Check if total candle count (including origin and current) exceeds the limit
        if max_wait > 0 and bar_index - candle.index + 1 > max_wait
            array.remove(bearishPending, i)
            continue

        // ORIGIN SHIFT HANDLING: 
        // If current candle is ALSO BEARISH with a higher high (high > candle.high)
        // Remove the old origin. Current candle will automatically become the new origin at the end of script.
        if is_bearish and high > candle.high
            array.remove(bearishPending, i)
            continue

        // If close is above the highest high of the bearish origin candle (Forward breakout)
        if close > candle.high
            // If current candle is Bullish (meets BO candle completion criteria)
            if is_bullish and show_bull
                bool should_draw = true
                if array.size(bullBoxes) > 0
                    for j = array.size(bullBoxes) - 1 to 0 by 1
                        box b = array.get(bullBoxes, j)
                        int old_left = box.get_left(b)
                        int old_right = box.get_right(b)
                        // If old box CONTAINS new box (old box is larger or equal) -> Delete old box
                        if old_left <= candle.index and old_right >= bar_index
                            box.delete(b)
                            array.remove(bullBoxes, j)
                        // If new box CONTAINS old box (new box is larger) -> Don't draw new box
                        else if candle.index <= old_left and bar_index >= old_right
                            should_draw := false
                            should_draw

                if should_draw
                    box b = box.new(left = candle.index, top = candle.high, right = bar_index, bottom = candle.low, border_color = bull_color, border_style = line.style_solid, bgcolor = bull_fill)
                    array.push(bullBoxes, b)

            // Whether BO candle is bullish or bearish, this origin has been broken and must be removed
            array.remove(bearishPending, i)

        // If close is below the lowest low of the bearish origin candle (Reverse breakout -> Invalidate)
        else if close < candle.low
            array.remove(bearishPending, i)

// 2. CHECK BREAKOUT FOR PENDING BULLISH ORIGIN CANDLES (BEARISH EG ZONE)
if array.size(bullishPending) > 0
    // Iterate array backwards to safely remove elements directly
    for i = array.size(bullishPending) - 1 to 0 by 1
        CandleInfo candle = array.get(bullishPending, i)

        // Check if total candle count (including origin and current) exceeds the limit
        if max_wait > 0 and bar_index - candle.index + 1 > max_wait
            array.remove(bullishPending, i)
            continue

        // ORIGIN SHIFT HANDLING:
        // If current candle is ALSO BULLISH with a lower low (low < candle.low)
        // Remove the old origin. Current candle will automatically become the new origin at the end of script.
        if is_bullish and low < candle.low
            array.remove(bullishPending, i)
            continue

        // If close is below the lowest low of the bullish origin candle (Forward breakout)
        if close < candle.low
            // If current candle is Bearish (meets BO candle completion criteria)
            if is_bearish and show_bear
                bool should_draw = true
                if array.size(bearBoxes) > 0
                    for j = array.size(bearBoxes) - 1 to 0 by 1
                        box b = array.get(bearBoxes, j)
                        int old_left = box.get_left(b)
                        int old_right = box.get_right(b)
                        // If old box CONTAINS new box (old box is larger or equal) -> Delete old box
                        if old_left <= candle.index and old_right >= bar_index
                            box.delete(b)
                            array.remove(bearBoxes, j)
                        // If new box CONTAINS old box (new box is larger) -> Don't draw new box
                        else if candle.index <= old_left and bar_index >= old_right
                            should_draw := false
                            should_draw

                if should_draw
                    box b = box.new(left = candle.index, top = candle.high, right = bar_index, bottom = candle.low, border_color = bear_color, border_style = line.style_solid, bgcolor = bear_fill)
                    array.push(bearBoxes, b)

            // Whether BO candle is bearish or bullish, this origin has been broken and must be removed
            array.remove(bullishPending, i)

        // If close is above the highest high of the bullish origin candle (Reverse breakout -> Invalidate)
        else if close > candle.high
            array.remove(bullishPending, i)

// 3. CHECK OUTSIDE BAR ZONE (2 CONSECUTIVE CANDLES)
if bar_index > 0
    // Bearish Outside Bar: 2 consecutive bearish candles, candle 2 engulfs candle 1 and closes below candle 1's low
    is_ob_bear = close[1] < open[1] and close < open and high > high[1] and low < low[1] and close < low[1]
    if is_ob_bear and show_ob_bear
        box b = box.new(left = bar_index - 1, top = high[1], right = bar_index, bottom = low[1], border_color = ob_bear_color, border_style = line.style_solid, bgcolor = ob_bear_fill)
        array.push(bearObBoxes, b)

    // Bullish Outside Bar: 2 consecutive bullish candles, candle 2 engulfs candle 1 and closes above candle 1's high
    is_ob_bull = close[1] > open[1] and close > open and high > high[1] and low < low[1] and close > high[1]
    if is_ob_bull and show_ob_bull
        box b = box.new(left = bar_index - 1, top = high[1], right = bar_index, bottom = low[1], border_color = ob_bull_color, border_style = line.style_solid, bgcolor = ob_bull_fill)
        array.push(bullObBoxes, b)

// 4. CLEAN UP OLDEST BOXES WHEN TOTAL EXCEEDS LIMIT (SHARED QUOTA)
clean_all_boxes(box_limit)

// 5. ADD CURRENT CANDLE TO TRACKING LIST IF IT QUALIFIES AS A NEW ORIGIN
if is_bearish
    array.push(bearishPending, CandleInfo.new(bar_index, high, low))
    // Limit list size for performance
    if array.size(bearishPending) > max_pending
        array.shift(bearishPending)

if is_bullish
    array.push(bullishPending, CandleInfo.new(bar_index, high, low))
    // Limit list size for performance
    if array.size(bullishPending) > max_pending
        array.shift(bullishPending)
````
