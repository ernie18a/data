<!-- tradingview-pine-id: PUB;a6851267a7e54d29ad1dec20e56e16ae -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trendline Indicator with Dynamic Breakpoint Tracking

Source: https://www.tradingview.com/script/XTkE2MMz-Trendline-Indicator-with-Dynamic-Breakpoint-Tracking/

## Description

Trendline Indicator with Dynamic Breakpoint Tracking

This indicator automates the process of manually drawing and redrawing trendlines as price structure evolves, rather than plotting a single static line.

How it works

The script tracks confirmed swing highs and lows (pivots). It starts in downtrend mode, watching the most recent swing low:

When that low is broken, the line resets. It anchors to the top of the prior move and snaps its second point to the next confirmed swing high that's lower than that top — drawing a fresh descending resistance line.
As price continues down, each new broken low re-anchors the line the same way, so the resistance line keeps stepping down along the sequence of lower highs.
If price closes at or above the current resistance level, the script flips to uptrend mode and begins drawing an ascending support line using the mirror-image logic: anchoring from the bottom of the move and snapping to the next confirmed higher low.
The two modes alternate automatically as market structure shifts between making lower highs and higher lows.

Dynamic breakpoint tracking

Unlike a fixed trendline, the breakpoints this script uses to define the line are re-evaluated continuously:

If a transition is only halfway confirmed (e.g. resistance broke but no higher low has formed yet) and price reverses back through the original anchor before that confirmation completes, the script recognizes the transition failed and reverts to the prior trend immediately, rather than waiting on a reversal that isn't materializing.
A stale-anchor safeguard prevents the line from getting permanently locked onto an old price level if the market structure it's tracking becomes irrelevant.

Inputs

Pivot Left/Right Bars — sensitivity of swing detection (smaller = faster but noisier, larger = smoother but more lag)
Max bars to search for anchor point — how far back the script looks when re-anchoring
Line colors/width, signal colors, and toggles for trend labels, pivot markers, and the debug status table

Notes

Pivot-based detection is inherently lagging by design (a swing can only be confirmed once bars exist on both sides of it), so the line reacts after structure is confirmed, not in real time.
Built for visualizing trend structure and potential trend-change points — not a standalone buy/sell signal generator. Combine with your own confirmation and risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradezyTrades

//@version=6
indicator("Trendline Indicator with Dynamic Breakpoint Tracking", overlay=true, max_lines_count=50, max_labels_count=50)

// ---------------- INPUTS ----------------
leftBars    = input.int(3, "Pivot Left Bars", minval=1)
rightBars   = input.int(3, "Pivot Right Bars", minval=1)
lookback    = input.int(200, "Max bars to search for anchor point", minval=20)
lineColorDn = input.color(color.new(color.purple, 0), "Downtrend Line Color")
lineColorUp = input.color(color.new(color.blue, 0), "Uptrend Line Color")
lineWidth   = input.int(2, "Line Width", minval=1, maxval=5)
upSigColor  = input.color(color.new(color.lime, 0), "Uptrend Signal Color")
dnSigColor  = input.color(color.new(color.red, 0), "Downtrend Signal Color")
showLabels  = input.bool(true, "Show Break/Trend Labels")
showPivots  = input.bool(true, "Show Pivot Markers (debug)")
showStatus  = input.bool(true, "Show Status Table (debug)")

// ---------------- PIVOT STORAGE ----------------
var float[] phPrices = array.new_float()
var int[]   phBars   = array.new_int()
var float[] plPrices = array.new_float()
var int[]   plBars   = array.new_int()

ph = ta.pivothigh(leftBars, rightBars)
pl = ta.pivotlow(leftBars, rightBars)

if not na(ph)
    array.push(phPrices, ph)
    array.push(phBars, bar_index - rightBars)
    if array.size(phPrices) > 500
        array.shift(phPrices)
        array.shift(phBars)

if not na(pl)
    array.push(plPrices, pl)
    array.push(plBars, bar_index - rightBars)
    if array.size(plPrices) > 500
        array.shift(plPrices)
        array.shift(plBars)

plotshape(showPivots and not na(ph), title="Pivot High", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.tiny, offset=-rightBars)
plotshape(showPivots and not na(pl), title="Pivot Low", style=shape.triangleup, location=location.belowbar, color=color.aqua, size=size.tiny, offset=-rightBars)

// ---------------- HELPER FUNCTIONS ----------------
f_highestPivotSince(prices, bars, fromBar) =>
    float top = na
    int   topB = na
    if array.size(prices) > 0
        for i = array.size(prices) - 1 to 0
            b = array.get(bars, i)
            if b >= fromBar
                p = array.get(prices, i)
                if na(top) or p > top
                    top := p
                    topB := b
    [top, topB]

f_lowestPivotSince(prices, bars, fromBar) =>
    float bot = na
    int   botB = na
    if array.size(prices) > 0
        for i = array.size(prices) - 1 to 0
            b = array.get(bars, i)
            if b >= fromBar
                p = array.get(prices, i)
                if na(bot) or p < bot
                    bot := p
                    botB := b
    [bot, botB]

// ---------------- STATE ----------------
var string mode = "down"   // "down" = drawing resistance line, "up" = drawing support line

// downtrend state
var float lastSwingLow    = na
var int   lastSwingLowBar = na
var float anchorPriceDn   = na
var int   anchorBarDn     = na
var float resistPrice     = na
var int   resistBar       = na
var bool  waitingForHigh  = false
var line  trendLineDn     = na

// uptrend state
var float lastSwingHigh    = na
var int   lastSwingHighBar = na
var float anchorPriceUp    = na
var int   anchorBarUp      = na
var float supportPrice     = na
var int   supportBar       = na
var bool  waitingForLow    = false
var line  trendLineUp      = na

// =========================================================
// DOWNTREND LOGIC (resistance line connecting lower highs)
// =========================================================
if mode == "down"
    if not na(pl) and not waitingForHigh
        lastSwingLow    := pl
        lastSwingLowBar := bar_index - rightBars

    lowBroken = not na(lastSwingLow) and close < lastSwingLow and not waitingForHigh and bar_index > lookback

    if lowBroken
        [top, topB] = f_highestPivotSince(phPrices, phBars, lastSwingLowBar - lookback)
        if na(top)
            top := ta.highest(high, lookback)
            topB := bar_index - ta.highestbars(high, lookback)
        anchorPriceDn := top
        anchorBarDn   := topB
        waitingForHigh := true
        lastSwingLow    := na
        lastSwingLowBar := na
        if showLabels
            label.new(bar_index, low, "Low Broken", style=label.style_label_down, color=dnSigColor, textcolor=color.white, size=size.small)

    if waitingForHigh and not na(ph) and ph < anchorPriceDn and (bar_index - rightBars) > anchorBarDn
        resistPrice := ph
        resistBar   := bar_index - rightBars
        waitingForHigh := false
        if not na(trendLineDn)
            line.delete(trendLineDn)
        trendLineDn := line.new(anchorBarDn, anchorPriceDn, resistBar, resistPrice, xloc.bar_index, extend=extend.right, color=lineColorDn, width=lineWidth)

    // safety valve: if the anchor is stale (no qualifying lower high in a very long time),
    // refresh it to a recent high so the line can't get permanently stuck on old price levels
    if waitingForHigh and (bar_index - anchorBarDn) > lookback * 2
        anchorPriceDn := ta.highest(high, lookback)
        anchorBarDn   := bar_index - ta.highestbars(high, lookback)

    // early failure: the anticipated downtrend never confirmed and price already broke back
    // above the high that seeded it — the uptrend never actually ended, so resume it now
    if waitingForHigh and close > anchorPriceDn
        if showLabels
            label.new(bar_index, high, "Uptrend Resumed", style=label.style_label_up, color=upSigColor, textcolor=color.black, size=size.small)
        [bot, botB] = f_lowestPivotSince(plPrices, plBars, anchorBarDn)
        if na(bot)
            bot := ta.lowest(low, lookback)
            botB := bar_index - ta.lowestbars(low, lookback)
        anchorPriceUp := bot
        anchorBarUp   := botB
        waitingForLow  := true
        waitingForHigh := false
        lastSwingLow    := na
        lastSwingLowBar := na
        mode := "up"

    // uptrend trigger: price breaks even with or through the lower high
    if not na(resistPrice) and close >= resistPrice
        if showLabels
            label.new(bar_index, high, "Uptrend", style=label.style_label_up, color=upSigColor, textcolor=color.black, size=size.small)
        if not na(trendLineDn)
            line.set_extend(trendLineDn, extend.none)

        // seed the uptrend line: anchor = bottom of the move since the last resistance anchor
        [bot, botB] = f_lowestPivotSince(plPrices, plBars, anchorBarDn)
        if na(bot)
            bot := ta.lowest(low, lookback)
            botB := bar_index - ta.lowestbars(low, lookback)
        anchorPriceUp := bot
        anchorBarUp   := botB
        waitingForLow := true
        resistPrice   := na
        lastSwingLow    := na
        lastSwingLowBar := na
        mode := "up"

// =========================================================
// UPTREND LOGIC (support line connecting higher lows)
// =========================================================
if mode == "up"
    if not na(ph) and not waitingForLow
        lastSwingHigh    := ph
        lastSwingHighBar := bar_index - rightBars

    highBroken = not na(lastSwingHigh) and close > lastSwingHigh and not waitingForLow and bar_index > lookback

    if highBroken
        [bot, botB] = f_lowestPivotSince(plPrices, plBars, lastSwingHighBar - lookback)
        if na(bot)
            bot := ta.lowest(low, lookback)
            botB := bar_index - ta.lowestbars(low, lookback)
        anchorPriceUp := bot
        anchorBarUp   := botB
        waitingForLow := true
        lastSwingHigh    := na
        lastSwingHighBar := na
        if showLabels
            label.new(bar_index, high, "High Broken", style=label.style_label_up, color=upSigColor, textcolor=color.black, size=size.small)

    if waitingForLow and not na(pl) and pl > anchorPriceUp and (bar_index - rightBars) > anchorBarUp
        supportPrice := pl
        supportBar   := bar_index - rightBars
        waitingForLow := false
        if not na(trendLineUp)
            line.delete(trendLineUp)
        trendLineUp := line.new(anchorBarUp, anchorPriceUp, supportBar, supportPrice, xloc.bar_index, extend=extend.right, color=lineColorUp, width=lineWidth)

    // safety valve: refresh a stale anchor so it can't get permanently stuck on old price levels
    if waitingForLow and (bar_index - anchorBarUp) > lookback * 2
        anchorPriceUp := ta.lowest(low, lookback)
        anchorBarUp   := bar_index - ta.lowestbars(low, lookback)

    // early failure: the anticipated uptrend never confirmed and price already broke back
    // below the low that seeded it — the downtrend never actually ended, so resume it now
    if waitingForLow and close < anchorPriceUp
        if showLabels
            label.new(bar_index, low, "Downtrend Resumed", style=label.style_label_down, color=dnSigColor, textcolor=color.white, size=size.small)
        [top, topB] = f_highestPivotSince(phPrices, phBars, anchorBarUp)
        if na(top)
            top := ta.highest(high, lookback)
            topB := bar_index - ta.highestbars(high, lookback)
        anchorPriceDn := top
        anchorBarDn   := topB
        waitingForHigh := true
        waitingForLow  := false
        lastSwingHigh    := na
        lastSwingHighBar := na
        mode := "down"

    // downtrend trigger: price breaks even with or through the higher low
    if not na(supportPrice) and close <= supportPrice
        if showLabels
            label.new(bar_index, low, "Downtrend", style=label.style_label_down, color=dnSigColor, textcolor=color.white, size=size.small)
        if not na(trendLineUp)
            line.set_extend(trendLineUp, extend.none)

        // seed the downtrend line: anchor = top of the move since the last support anchor
        [top, topB] = f_highestPivotSince(phPrices, phBars, anchorBarUp)
        if na(top)
            top := ta.highest(high, lookback)
            topB := bar_index - ta.highestbars(high, lookback)
        anchorPriceDn := top
        anchorBarDn   := topB
        waitingForHigh := true
        supportPrice   := na
        lastSwingHigh    := na
        lastSwingHighBar := na
        mode := "down"

// ---------------- DEBUG STATUS TABLE ----------------
if showStatus and barstate.islast
    var table dbg = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_width=1)
    table.cell(dbg, 0, 0, "mode", text_color=color.white)
    table.cell(dbg, 1, 0, mode, text_color=color.yellow)
    table.cell(dbg, 0, 1, "waitingForHigh", text_color=color.white)
    table.cell(dbg, 1, 1, str.tostring(waitingForHigh), text_color=color.white)
    table.cell(dbg, 0, 2, "waitingForLow", text_color=color.white)
    table.cell(dbg, 1, 2, str.tostring(waitingForLow), text_color=color.white)
    table.cell(dbg, 0, 3, "lastSwingLow", text_color=color.white)
    table.cell(dbg, 1, 3, str.tostring(lastSwingLow), text_color=color.white)
    table.cell(dbg, 0, 4, "lastSwingHigh", text_color=color.white)
    table.cell(dbg, 1, 4, str.tostring(lastSwingHigh), text_color=color.white)
    table.cell(dbg, 0, 5, "anchorPriceDn", text_color=color.white)
    table.cell(dbg, 1, 5, str.tostring(anchorPriceDn), text_color=color.orange)
    table.cell(dbg, 0, 6, "anchorPriceUp", text_color=color.white)
    table.cell(dbg, 1, 6, str.tostring(anchorPriceUp), text_color=color.aqua)
    table.cell(dbg, 0, 7, "resistPrice", text_color=color.white)
    table.cell(dbg, 1, 7, str.tostring(resistPrice), text_color=color.white)
    table.cell(dbg, 0, 8, "supportPrice", text_color=color.white)
    table.cell(dbg, 1, 8, str.tostring(supportPrice), text_color=color.white)

// ---------------- ALERTS ----------------
alertcondition(mode == "down" and not na(resistPrice) and close >= resistPrice, title="Uptrend Triggered", message="Price broke through the lower high — uptrend starting")
alertcondition(mode == "up" and not na(supportPrice) and close <= supportPrice, title="Downtrend Triggered", message="Price broke through the higher low — downtrend starting")
````
