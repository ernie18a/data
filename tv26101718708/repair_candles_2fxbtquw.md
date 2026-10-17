# Repair Candles

- url: https://www.tradingview.com/script/2FxBTqUw-Repair-Candles/
- type: indicator
- pine_id: PUB;1ac8af7e493d4871b120ae55556a4fe0
- version: 3.0

## Description

This indicator plots [b]repair candle[/b] levels and extends them until price comes back and fills them.

A [b]repair candle[/b] is a candle that prints wickless on one side, meaning price moved away from that edge without properly trading back through it. The idea is that this can leave behind an inefficient auction, where price has moved too quickly and may not have fully interacted with resting liquidity around that level. Because of that, price may later return to the area to repair the move and collect orders left behind.

In practice, these levels can be useful in two ways:
[list]
[*]as potential targets, where price may later return to fill the repair
[*]as potential reversal zones, where traders may look for reactions or limit entries when price revisits the level
[/list]

This concept is used primarily around NQ futures, where these repair levels are often watched on the 10-minute timeframe, though the idea may also be useful on other instruments. The script is configurable, so while repair candles are typically based on 10m structure, the indicator itself can be run on any chart timeframe, allowing higher timeframe repair levels to be monitored from a lower timeframe chart such as 1m or 2m.

The script detects wickless tops and wickless bottoms on the chosen higher timeframe, plots the corresponding level, and keeps that level active until price trades back into it. An optional 1-tick tolerance is included to account for minor feed differences.

[i]The idea is inspired by [url=https://x.com/OkalaNQT]Okala’s[/url] teaching around repair candles and the 8020 framework.
In simple terms, 8020 is about pre-marking the areas that matter most before the session begins, then waiting for price to interact with those locations rather than chasing moves in the middle of the range. On NQ, that often means combining 80/20 levels, repair candles, and market structure to build a cleaner map of likely reaction zones, targets, and reversions.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © godzcopilot

// Based on the idea behind repair candles taught by https://x.com/OkalaNQT

//@version=6
indicator("Repair Candles", overlay = true, max_lines_count = 500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
htf           = input.timeframe("10", "Repair candle timeframe")
useTickTol    = input.bool(true, "Use 1 tick tolerance")
upperColor    = input.color(color.red,  "Upper / wickless-top target colour")
lowerColor    = input.color(color.lime, "Lower / wickless-bottom target colour")
lineWidth     = input.int(2, "Line width", minval = 1, maxval = 4)
lineStyleIn   = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"])
deleteFilled  = input.bool(false, "Delete filled lines instead of stopping them")

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
tol       = useTickTol ? syminfo.mintick : 0.0
lineStyle = lineStyleIn == "Dashed" ? line.style_dashed : lineStyleIn == "Dotted" ? line.style_dotted : line.style_solid

var line[]  repairLines  = array.new_line()
var float[] repairLevels = array.new_float()
var int[]   repairTypes  = array.new_int()
var bool[]  filledArr    = array.new_bool()
var int[]   originBars   = array.new_int()

//------------------------------------------------------------------------------
// HTF data
//
// lookahead_on + [1] is the canonical pattern for confirmed HTF data on a
// lower timeframe chart. The [1] shift is baked into the request expression
// so every chart bar sees the last *closed* HTF bar with no transition
// ambiguity — avoiding the issue where lookahead_off + [1] on the outside
// can return the still-forming HTF bar at the exact moment a new one opens.
//------------------------------------------------------------------------------
htfOpen  = request.security(syminfo.tickerid, htf, open [1], lookahead = barmerge.lookahead_on)
htfHigh  = request.security(syminfo.tickerid, htf, high [1], lookahead = barmerge.lookahead_on)
htfLow   = request.security(syminfo.tickerid, htf, low  [1], lookahead = barmerge.lookahead_on)
htfClose = request.security(syminfo.tickerid, htf, close[1], lookahead = barmerge.lookahead_on)
htfTime  = request.security(syminfo.tickerid, htf, time [1], lookahead = barmerge.lookahead_on)

// Fires on the first chart bar of each new HTF bar
newHtfBar = ta.change(htfTime) != 0

// Confirmed HTF candle — no [1] needed here since it's already in the request
pOpen  = htfOpen
pHigh  = htfHigh
pLow   = htfLow
pClose = htfClose

//------------------------------------------------------------------------------
// HTF candle definitions
//------------------------------------------------------------------------------
wicklessTop    = math.abs(pHigh - math.max(pOpen, pClose)) <= tol and pOpen != pClose
wicklessBottom = math.abs(pLow  - math.min(pOpen, pClose)) <= tol and pOpen != pClose

//------------------------------------------------------------------------------
// Create repair lines when a new HTF bar begins
//------------------------------------------------------------------------------
if newHtfBar
    if wicklessTop
        float lvl = pHigh
        line ln = line.new(bar_index, lvl, bar_index + 1, lvl, extend = extend.right, color = upperColor, width = lineWidth, style = lineStyle)
        array.push(repairLines, ln)
        array.push(repairLevels, lvl)
        array.push(repairTypes, 1)
        array.push(filledArr, false)
        array.push(originBars, bar_index - 1)

    if wicklessBottom
        float lvl = pLow
        line ln = line.new(bar_index, lvl, bar_index + 1, lvl, extend = extend.right, color = lowerColor, width = lineWidth, style = lineStyle)
        array.push(repairLines, ln)
        array.push(repairLevels, lvl)
        array.push(repairTypes, -1)
        array.push(filledArr, false)
        array.push(originBars, bar_index - 1)

//------------------------------------------------------------------------------
// Check for fills — runs after line creation so newly created lines are
// immediately eligible on the same bar
//------------------------------------------------------------------------------
if array.size(repairLines) > 0
    for i = 0 to array.size(repairLines) - 1
        if not array.get(filledArr, i)
            float lvl = array.get(repairLevels, i)
            int   typ = array.get(repairTypes, i)
            line  ln  = array.get(repairLines, i)
            int   ob  = array.get(originBars, i)

            bool validToCheck = bar_index > ob
            bool filled = false

            if validToCheck
                filled := typ == 1 ? high >= lvl : low <= lvl

            if filled
                array.set(filledArr, i, true)

                if deleteFilled
                    line.delete(ln)
                else
                    line.set_extend(ln, extend.none)
                    line.set_x2(ln, bar_index)
````
