# RSI Smoothing: Wilder vs EMA

- url: https://www.tradingview.com/script/2SgSSnf1-RSI-Smoothing-Wilder-vs-EMA/
- type: indicator
- pine_id: PUB;2d19f535a6b440498d54b78f484a4855
- version: 1.0

## Description

Two RSI(14) lines built from the same up and down moves, smoothed two ways, so you can see where they disagree.

Blue is Wilder's RSI, the one the built-in RSI and ta.rsi() use. It averages with a weight of 1/14 on the newest bar. Orange uses a conventional EMA, which puts 2/15 on the newest bar, nearly twice as much. Wilder's 14 behaves like an EMA of about 27, and its average lag is 13 bars against 6.5 for the EMA version.

Markers show threshold crosses: circles for Wilder, triangles for the EMA version, at the bottom for crosses below the lower line and at the top for crosses above the upper line. Where a circle and a triangle don't line up, a rule written as "RSI(14) crosses 30" fires on different bars depending on which smoothing your platform or library uses.

The table counts crosses over the loaded bars for each version, how many landed on the same bar, and each smoother's average lag. The same counts are in the Data Window.

How big the gap can be: on BITFINEX:BTCUSD daily closes from 2021-10-31 to 2026-10-03, Wilder's RSI(14) crossed below 30 on 22 days and the EMA version on 55, and they crossed on the same bar 3 times. That figure comes from a separate offline count; the table on your chart counts whatever bars are loaded.

Use it to check which smoothing a rule was tested with before trusting a result that moved between platforms, and write the smoothing next to the length when you record a rule: RSI(14, Wilder) is a specification, RSI(14) is a label.

Inputs: length, source, lower and upper thresholds, and a switch for the table.

Notes: computed from the chart's own bars only, with no request.security and no other timeframe, so there is no lookahead to get wrong. Like any RSI, the value on the bar that is still forming moves until it closes, and the EMA version's first bars differ from Wilder's while both averages warm up. It compares two calculations; it does not tell you when to trade, and nothing here is investment advice.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © harrell.jordon
//
// Two RSI(14) lines from the same up/down moves, smoothed two ways:
//   Wilder (what ta.rsi uses): weight 1/len on the newest bar
//   EMA:                       weight 2/(len+1) on the newest bar
// Markers show the bars where each version crosses the thresholds, so the
// bars where they disagree are visible. Computed from the chart's own bars only;
// no request.security, nothing from another timeframe.
indicator("RSI Smoothing: Wilder vs EMA", shorttitle = "RSI W/E", overlay = false, precision = 2)

len     = input.int(14, "Length", minval = 2)
src     = input.source(close, "Source")
lowLvl  = input.float(30.0, "Lower threshold", minval = 1, maxval = 99)
upLvl   = input.float(70.0, "Upper threshold", minval = 1, maxval = 99)
showTbl = input.bool(true, "Show cross-count table")

// Wilder smoothing, exactly as the built-in RSI computes it
rsiW = ta.rsi(src, len)

// Same up and down moves, smoothed with a conventional EMA instead
chg   = ta.change(src)
up    = math.max(nz(chg), 0.0)
dn    = math.max(-nz(chg), 0.0)
emaUp = ta.ema(up, len)
emaDn = ta.ema(dn, len)
rsiE = switch
    emaDn == 0 => 100.0
    emaUp == 0 => 0.0
    => 100.0 - 100.0 / (1.0 + emaUp / emaDn)

// Threshold crosses for each version
wDown = ta.crossunder(rsiW, lowLvl)
eDown = ta.crossunder(rsiE, lowLvl)
wUp   = ta.crossover(rsiW, upLvl)
eUp   = ta.crossover(rsiE, upLvl)

// Running counts over the loaded bars
var int nW     = 0
var int nE     = 0
var int nSame  = 0
var int nWu    = 0
var int nEu    = 0
var int nSameU = 0
if wDown
    nW += 1
if eDown
    nE += 1
if wDown and eDown
    nSame += 1
if wUp
    nWu += 1
if eUp
    nEu += 1
if wUp and eUp
    nSameU += 1

// Average lag of each smoother, in bars: (1 - a) / a
lagW = len - 1.0
lagE = (len - 1.0) / 2.0

colW = #2962FF
colE = #FF6D00

hline(upLvl, "Upper threshold", color = color.new(#787B86, 40), linestyle = hline.style_dashed)
hline(50, "Midline", color = color.new(#787B86, 70), linestyle = hline.style_dotted)
hline(lowLvl, "Lower threshold", color = color.new(#787B86, 40), linestyle = hline.style_dashed)

plot(rsiW, "RSI Wilder", color = colW, linewidth = 2)
plot(rsiE, "RSI EMA", color = colE, linewidth = 1)

plotshape(wDown, "Wilder crosses below lower", shape.circle, location.bottom, colW, size = size.tiny)
plotshape(eDown, "EMA crosses below lower", shape.triangleup, location.bottom, colE, size = size.tiny)
plotshape(wUp, "Wilder crosses above upper", shape.circle, location.top, colW, size = size.tiny)
plotshape(eUp, "EMA crosses above upper", shape.triangledown, location.top, colE, size = size.tiny)

plot(nW, "Wilder crosses below (count)", display = display.data_window)
plot(nE, "EMA crosses below (count)", display = display.data_window)
plot(nSame, "Same-bar crosses below (count)", display = display.data_window)
plot(nWu, "Wilder crosses above (count)", display = display.data_window)
plot(nEu, "EMA crosses above (count)", display = display.data_window)
plot(nSameU, "Same-bar crosses above (count)", display = display.data_window)

var table t = table.new(position.top_right, 3, 5, border_width = 0, frame_width = 0)
if barstate.islast
    if showTbl
        bg = color.new(chart.bg_color, 12)
        fg = chart.fg_color
        table.cell(t, 0, 0, " ", bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 1, 0, " ", bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 2, 0, " ", bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 0, 1, "Loaded bars", bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 1, 1, "Wilder", bgcolor = bg, text_color = colW, text_size = size.small)
        table.cell(t, 2, 1, "EMA", bgcolor = bg, text_color = colE, text_size = size.small)
        table.cell(t, 0, 2, "Crosses below " + str.tostring(lowLvl, "0.#"), bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 1, 2, str.tostring(nW), bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 2, 2, str.tostring(nE) + " (" + str.tostring(nSame) + " same bar)", bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 0, 3, "Crosses above " + str.tostring(upLvl, "0.#"), bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 1, 3, str.tostring(nWu), bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 2, 3, str.tostring(nEu) + " (" + str.tostring(nSameU) + " same bar)", bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 0, 4, "Average lag, bars", bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 1, 4, str.tostring(lagW, "0.0"), bgcolor = bg, text_color = fg, text_size = size.small)
        table.cell(t, 2, 4, str.tostring(lagE, "0.0"), bgcolor = bg, text_color = fg, text_size = size.small)
    else
        table.clear(t, 0, 0, 2, 4)
````
