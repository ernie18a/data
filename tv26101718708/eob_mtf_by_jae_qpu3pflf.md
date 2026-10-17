# EOB MTF by Jae

- url: https://www.tradingview.com/script/QPu3pFLF-EOB-MTF-by-Jae/
- type: indicator
- pine_id: PUB;a418193796914601a26460c1aed354f5
- version: 1.0

## Description

EOB — Engulfing Order Block Detector
This indicator automatically identifies and plots Engulfing Order Blocks (EOBs) directly on your chart — a core concept from ICT (Inner Circle Trader) methodology.
An EOB forms when a candle with a significant wick is fully or predominantly engulfed by the following candle, signaling that smart money has stepped in aggressively to reverse price. These zones act as high-probability areas where price is likely to react on a retest.
How it works:

🟢 Bullish EOB — A red candle with an upper wick is engulfed by a larger green candle closing above it. The zone marks the area where institutional buying occurred.
🔴 Bearish EOB — A green candle with a lower wick is engulfed by a larger red candle closing below it. The zone marks the area where institutional selling occurred.

How to use it:

Wait for price to pull back into a zone after the EOB forms. Enter in the direction of the engulf with your stop loss beyond the zone and a minimum 2:1 risk-to-reward target. Best used during NY AM (09:30–11:00) and NY PM (13:30–15:30) sessions on liquid futures instruments like MNQ, NQ, ES, and CL.
Works on all timeframes. Recommended: 5m for entries, 15m/1H for bias confirmation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © ICT Enhanced Order Block - Multi-Timeframe Confluence
// Designed for MNQM2026

//@version=6
indicator("EOB Multi-TF Confluence [ICT]", overlay=true, max_boxes_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
box_candles = input.int(4,   "Box Width (candles)", minval=2, maxval=20,    group="Detection")
max_zones   = input.int(500, "Max Zones (history)", minval=10, maxval=2000, group="Detection")
c_bull      = input.color(color.new(#00C853, 60), "Bullish Color", group="Colors")
c_bear      = input.color(color.new(#FF1744, 60), "Bearish Color", group="Colors")

// ─────────────────────────────────────────────
// DETECTION
// ─────────────────────────────────────────────

// OB candle (bar[1])
ob_is_red    = close[1] < open[1]
ob_is_green  = close[1] > open[1]
ob_up_wick   = high[1] > open[1]
ob_dn_wick   = low[1]  < open[1]

// Engulfing candle (bar[0])
eng_is_green  = close > open
eng_is_red    = close < open
eng_body_size = math.abs(close - open)
ob_body_size  = math.abs(close[1] - open[1])
eng_larger    = eng_body_size > ob_body_size

eng_above = close > high[1]
eng_below = close < low[1]

// Partial engulf — body covers 90%+ of OB body
ob_body_top  = math.max(open[1], close[1])
ob_body_bot  = math.min(open[1], close[1])
eng_body_top = math.max(open, close)
eng_body_bot = math.min(open, close)
partial_bull = ob_body_size > 0 and eng_body_top >= ob_body_top and (eng_body_top - ob_body_bot) / ob_body_size >= 0.90
partial_bear = ob_body_size > 0 and eng_body_bot <= ob_body_bot and (ob_body_top - eng_body_bot) / ob_body_size >= 0.90

// Final conditions
bull_eob = ob_is_red   and ob_up_wick and eng_is_green and eng_larger and (eng_above or partial_bull)
bear_eob = ob_is_green and ob_dn_wick and eng_is_red   and eng_larger and (eng_below or partial_bear)

// Zone levels
bull_h = bull_eob ? (eng_above ? high[1] : open[1]) : na
bull_l = bull_eob ? (eng_above ? open[1] : close)   : na
bear_h = bear_eob ? (eng_below ? open[1] : close)   : na
bear_l = bear_eob ? (eng_below ? low[1]  : open[1]) : na

// ─────────────────────────────────────────────
// BOX STORAGE
// ─────────────────────────────────────────────
var box[]   bx_bull  = array.new_box()
var float[] top_bull = array.new_float()
var float[] bot_bull = array.new_float()
var int[]   born_bull = array.new_int()

var box[]   bx_bear  = array.new_box()
var float[] top_bear = array.new_float()
var float[] bot_bear = array.new_float()
var int[]   born_bear = array.new_int()

// ─────────────────────────────────────────────
// ADD BOX
// ─────────────────────────────────────────────
add_box(box[] bxs, float[] tops, float[] bots, int[] borns, float zh, float zl, color col) =>
    if not na(zh) and not na(zl)
        bar_ms = timeframe.in_seconds() * 1000
        x1 = time[1]
        x2 = time[1] + bar_ms * box_candles
        b  = box.new(x1, zh, x2, zl,
                 xloc         = xloc.bar_time,
                 border_color = color.new(col, 10),
                 bgcolor      = color.new(col, 55),
                 border_width = 1)
        array.unshift(bxs,   b)
        array.unshift(tops,  zh)
        array.unshift(bots,  zl)
        array.unshift(borns, bar_index)
        if array.size(bxs) > max_zones
            box.delete(array.pop(bxs))
            array.pop(tops)
            array.pop(bots)
            array.pop(borns)

// ─────────────────────────────────────────────
// MANAGE — cap at max_zones
// ─────────────────────────────────────────────
manage_boxes(box[] bxs, float[] tops, float[] bots, int[] borns) =>
    if array.size(bxs) > max_zones
        box.delete(array.pop(bxs))
        array.pop(tops)
        array.pop(bots)
        array.pop(borns)

// ─────────────────────────────────────────────
// DRAW
// ─────────────────────────────────────────────
if bull_eob
    add_box(bx_bull, top_bull, bot_bull, born_bull, bull_h, bull_l, c_bull)
if bear_eob
    add_box(bx_bear, top_bear, bot_bear, born_bear, bear_h, bear_l, c_bear)

manage_boxes(bx_bull, top_bull, bot_bull, born_bull)
manage_boxes(bx_bear, top_bear, bot_bear, born_bear)
````
