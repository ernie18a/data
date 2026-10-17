# Efficiency-Adaptive Trend Trail [Jayadev Rana]

- url: https://www.tradingview.com/script/tQTkMdIL-Efficiency-Adaptive-Trend-Trail-Jayadev-Rana/
- type: indicator
- pine_id: PUB;a22571b8bb214fd7a49c7492c89bbd44
- version: 1.0

## Description

OVERVIEW

Efficiency-Adaptive Trend Trail is a trend-following overlay that prints BUY and SELL signals when price closes through a ratcheting trailing line. What makes it different from a fixed ATR trail is that the trail distance is not constant: it is driven by the Kaufman efficiency ratio, so the line sits closer to price while the market is moving in a straight line and backs away while the market is rotating.

HOW IT WORKS

1. Efficiency ratio. Over the Efficiency Length the script divides the net price change by the sum of all bar-to-bar changes. A value near 1 means price travelled in a straight line; a value near 0 means it moved a lot and went nowhere.

2. Adaptive width. The trail distance in ATRs is interpolated between two user values: the Wide Multiplier applies when efficiency is 0 and the Tight Multiplier applies when efficiency is 1. The result is smoothed with an EMA so the distance changes gradually instead of jumping from bar to bar.

3. Ratcheting trail. In an up state the trail is the highest value so far of (close minus distance), so it can only rise. In a down state it is the lowest value so far of (close plus distance), so it can only fall. A close through the trail flips the state and restarts the trail on the other side of price.

The idea behind the adaptation: a choppy market needs room, otherwise every swing flips the state, while a clean trend can be followed more closely because pullbacks inside it are shallow relative to its progress.

SIGNALS

- BUY: a bar closes above the trail while the state was down.
- SELL: a bar closes below the trail while the state was up.

The state is always either up or down, so signals alternate by construction. Signals are evaluated on closed bars and are not changed afterwards.

DASHBOARD

Direction, current efficiency ratio, current trail width in ATRs, and the distance from price to the flip level in ATRs.

SETTINGS

Core: ATR Length, Efficiency Length, Tight Multiplier (Efficient Trend), Wide Multiplier (Choppy Market), Multiplier Smoothing, Color Bars by Direction.
Dashboard: visibility and position.
Style: colors.

DEFAULT SETTINGS

The default values were chosen with a parameter search on BTCUSDT on the 1-hour timeframe. The search treated the signals as a stop-and-reverse system with trading costs, split the history into an earlier and a later segment, and kept only settings that held up in both segments. The search favored wide multipliers on that market, which means few signals and long holding periods. Other symbols and timeframes will usually need different values, typically smaller multipliers on higher timeframes; treat the defaults as a starting point and not as a recommendation.

ALERTS

Buy Signal, Sell Signal.

LIMITATIONS

- This is a trend-following tool. During long sideways periods it will flip late and give back part of the previous move.
- The trail is close-based. Intrabar spikes through the line that do not hold into the close do not flip the state, and a flip is only known at the close.
- The efficiency ratio describes the recent past. A market can turn from trending to rotating faster than the ratio can register.
- Wide default multipliers mean the line can sit far from price; the distance shown on the dashboard is the amount of adverse movement the current state tolerates.
- Settings tuned on past data can stop working when market behavior changes.

This script is for analysis and education. It does not provide financial advice, and past behavior of any signal does not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) Jayadev Rana
//@version=6
indicator("Efficiency-Adaptive Trend Trail [Jayadev Rana]", shorttitle = "EATT", overlay = true)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
string GRP_CORE  = "Core"
string GRP_DASH  = "Dashboard"
string GRP_STYLE = "Style"

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
int   atrLen    = input.int(14, "ATR Length", minval = 2, maxval = 200, group = GRP_CORE)
int   erLen     = input.int(20, "Efficiency Length", minval = 5, maxval = 200, group = GRP_CORE, tooltip = "Window of the efficiency ratio: net price move divided by the total bar-to-bar path. 1 is a straight line, 0 is pure rotation.")
float minMult   = input.float(8.0, "Tight Multiplier (Efficient Trend)", minval = 0.5, maxval = 30.0, step = 0.1, group = GRP_CORE, tooltip = "ATR multiple used when the efficiency ratio is 1. A clean trend earns a closer trail.")
float maxMult   = input.float(12.0, "Wide Multiplier (Choppy Market)", minval = 0.5, maxval = 30.0, step = 0.1, group = GRP_CORE, tooltip = "ATR multiple used when the efficiency ratio is 0. A rotating market gets a wider trail so noise causes fewer flips. Keep it above the tight multiplier.")
int   multSmooth = input.int(20, "Multiplier Smoothing", minval = 1, maxval = 50, group = GRP_CORE, tooltip = "EMA length applied to the adaptive multiplier so the trail distance changes gradually.")
bool  colorBars = input.bool(false, "Color Bars by Direction", group = GRP_CORE)

bool   showDash = input.bool(true, "Show Dashboard", group = GRP_DASH)
string dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = GRP_DASH)

color upCol = input.color(#26a69a, "Up", group = GRP_STYLE)
color dnCol = input.color(#ef5350, "Down", group = GRP_STYLE)

//------------------------------------------------------------------------------
// Core calculations
//------------------------------------------------------------------------------
float atr  = ta.atr(atrLen)
float unit = math.max(nz(atr, high - low), syminfo.mintick)
float chg  = close - close[erLen]
float path = math.sum(math.abs(close - close[1]), erLen)
float er   = path > 0 ? math.abs(chg) / path : 0.0
float mult = ta.ema(maxMult - (maxMult - minMult) * nz(er), multSmooth)
float dist = mult * unit

// Ratcheting trail: only moves in the direction of the trend, flips on a close through it.
var float trail = na
var int   dir   = 1
if na(trail)
    trail := close - dist
else if dir == 1
    trail := math.max(trail, close - dist)
    if close < trail
        dir   := -1
        trail := close + dist
else
    trail := math.min(trail, close + dist)
    if close > trail
        dir   := 1
        trail := close - dist

bool warm    = bar_index > math.max(atrLen, erLen) * 3
bool buySig  = warm and barstate.isconfirmed and dir == 1 and dir[1] == -1
bool sellSig = warm and barstate.isconfirmed and dir == -1 and dir[1] == 1

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
color dirCol = dir == 1 ? upCol : dnCol
pPrice = plot(hl2, "Price Anchor", display = display.none, editable = false)
pTrail = plot(warm ? trail : na, "Trend Trail", color = dir != dir[1] ? na : dirCol, linewidth = 2, style = plot.style_linebr)
fill(pPrice, pTrail, color = color.new(dirCol, 90), title = "Trend Fill")
plotshape(buySig, "Buy", shape.labelup, location.belowbar, color = upCol, text = "BUY", textcolor = color.white, size = size.small)
plotshape(sellSig, "Sell", shape.labeldown, location.abovebar, color = dnCol, text = "SELL", textcolor = color.white, size = size.small)
barcolor(colorBars ? color.new(dirCol, 20) : na, title = "Direction Bar Color")

plot(er, "Efficiency Ratio", display = display.data_window)
plot(mult, "Adaptive Multiplier", display = display.data_window)
plot(dir, "Direction", display = display.data_window)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
f_pos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        => position.bottom_left

var table dash = table.new(f_pos(dashPos), 2, 4, bgcolor = color.new(#131722, 15), border_color = color.new(color.gray, 70), border_width = 1)

f_row(int r, string k, string v, color c) =>
    table.cell(dash, 0, r, k, text_color = color.new(color.white, 30), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, r, v, text_color = c, text_size = size.small, text_halign = text.align_right)

if showDash and barstate.islast
    f_row(0, "Direction", dir == 1 ? "Up" : "Down", dirCol)
    f_row(1, "Efficiency", str.tostring(er, "#.00"), color.white)
    f_row(2, "Trail width", str.tostring(mult, "#.00") + " ATR", color.white)
    f_row(3, "Distance to flip", str.tostring(math.abs(close - trail) / unit, "#.0") + " ATR", color.white)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(buySig, "Buy Signal", "Efficiency Trail: BUY signal on {{ticker}} ({{interval}})")
alertcondition(sellSig, "Sell Signal", "Efficiency Trail: SELL signal on {{ticker}} ({{interval}})")
````
