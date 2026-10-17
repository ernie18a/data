# Trends ATR

- url: https://www.tradingview.com/script/y1umlocJ-Trends-ATR/
- type: indicator
- pine_id: PUB;cbb499c96bd94809ab6a705956e4e239
- version: 3.0

## Description

Trends ATR

OVERVIEW
Trends ATR draws stepped trend lines that only move when price travels a full ATR-based step. Small fluctuations are ignored, so the lines show the underlying direction as clean levels instead of noisy candles. The line and band turn green in an uptrend and red in a downtrend. Works on any symbol and timeframe.

THEORY
The idea is similar to Renko bricks: price is quantized into fixed-size steps, and a level only shifts after price clears it by one full step. Using ATR as the step size makes the steps adapt to each market's volatility, so the same settings behave sensibly on different assets and timeframes.

HOW IT WORKS
1. Step size = ATR(length) × multiplier.
2. Trend line: a stepped version of the close. When close moves more than one step above the current level, the level rises one step. When close moves more than one step below it, the level falls one step. Otherwise it holds.
3. Stepped open: the same stepping applied to the open.
4. Base line: each time the stepped open shifts, the base line takes its previous level.
5. Trend: UP when the trend line is above the base line, DOWN when below.
6. Band: the area between the trend line and the base line, colored by trend.

HOW TO USE
- Trend filter: favor longs while green, shorts while red.
- Trend flips: a color change marks a shift in direction confirmed by a full ATR step.
- Band width: a wide band shows price has moved well away from the previous level; a narrow band shows a fresh or weak move.
- Support / resistance: the flat steps often act as reference levels during pauses in the trend.
- Higher step multiplier or ATR length = fewer, slower signals. Lower = faster and more sensitive.

SETTINGS
- ATR length – volatility lookback for the step size (default 200).
- Step size (× ATR) – multiplier on ATR.
- Colors, trend line width, base line and band toggles.

ALERTS
- Trend turned up
- Trend turned down

NOTES
Levels are calculated on the chart's timeframe. On the live bar, the trend line can shift during the bar and is confirmed at close; use alerts set to "once per bar close" for confirmed signals.

This script is for analysis and education only and is not financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RafaelZioni

//@version=6
indicator('Trends ATR', shorttitle = 'TrendsATR', overlay = true, max_lines_count = 50)

// ════════════════════════════════════════════════════════════════
// Trends ATR
// ATR-stepped trend lines. Price must move a full ATR step beyond
// the current level before the level shifts, filtering out noise.
// Trend = stepped close vs. the previous stepped-open level.
// MTF: the current stepped levels from up to 3 higher timeframes,
// drawn as horizontal support / resistance lines.
// ════════════════════════════════════════════════════════════════

// ── inputs: calculation ──
grpCalc = 'Calculation'
atrLen  = input.int(200, 'ATR length', minval = 1, group = grpCalc,
     tooltip = 'Length of the ATR used as the step size. Longer = smoother steps.')
mult    = input.float(1.0, 'Step size (× ATR)', minval = 0.1, step = 0.1, group = grpCalc,
     tooltip = 'Price must move this many ATRs beyond the current level before the level shifts. Higher = fewer, larger steps.')

// ── inputs: style ──
grpStyle = 'Style'
upCol    = input.color(color.lime, 'Up color', group = grpStyle)
dnCol    = input.color(color.red, 'Down color', group = grpStyle)
lineW    = input.int(3, 'Trend line width', minval = 1, maxval = 5, group = grpStyle)
showBase = input.bool(true, 'Show base line', group = grpStyle)
showBand = input.bool(true, 'Show band', group = grpStyle,
     tooltip = 'Fills the area between the trend line and the base line.')

// ── inputs: MTF ──
grpMtf = 'Multi-timeframe levels'
show1  = input.bool(true, '', inline = 'tf1', group = grpMtf)
tf1    = input.timeframe('60', 'TF 1', inline = 'tf1', group = grpMtf)
col1   = input.color(color.orange, '', inline = 'tf1', group = grpMtf)
show2  = input.bool(true, '', inline = 'tf2', group = grpMtf)
tf2    = input.timeframe('240', 'TF 2', inline = 'tf2', group = grpMtf)
col2   = input.color(color.aqua, '', inline = 'tf2', group = grpMtf)
show3  = input.bool(true, '', inline = 'tf3', group = grpMtf)
tf3    = input.timeframe('D', 'TF 3', inline = 'tf3', group = grpMtf)
col3   = input.color(color.fuchsia, '', inline = 'tf3', group = grpMtf)
mtfW   = input.int(2, 'MTF line width', minval = 1, maxval = 5, group = grpMtf)
mtfSty = input.string('Dashed', 'MTF line style', options = ['Solid', 'Dashed', 'Dotted'], group = grpMtf)

// ── core ──
f_step(float lvl, float src, float s) =>
    na(lvl) ? src : src > lvl + s ? lvl + s : src < lvl - s ? lvl - s : lvl

f_trend(int len, float m) =>
    s = ta.atr(len) * m
    var float cL = na   // stepped close (trend line)
    var float oL = na   // stepped open
    var float bL = na   // previous stepped-open level (base line)
    if not na(s)
        cL := f_step(cL, close, s)
        nO = f_step(oL, open, s)
        if not na(oL) and nO != oL
            bL := oL
        oL := nO
    rdy = not na(cL) and not na(bL)
    [rdy ? cL : na, rdy ? bL : na]

// ── chart timeframe ──
[closeLvl, baseLvl] = f_trend(atrLen, mult)

ready    = not na(closeLvl) and not na(baseLvl)
isUp     = closeLvl > baseLvl
trendCol = isUp ? upCol : dnCol
flipUp   = ready and isUp and not isUp[1]
flipDn   = ready and not isUp and isUp[1]

pT = plot(closeLvl, 'Trend line', trendCol, lineW, plot.style_stepline)
pB = plot(baseLvl, 'Base line', showBase ? color.new(trendCol, 60) : na, 1, plot.style_stepline)
fill(pT, pB, showBand ? color.new(trendCol, 85) : na, 'Trend band')

// ── MTF levels (live HTF values) ──
f_tfOk(string tf) =>
    timeframe.in_seconds(tf) >= timeframe.in_seconds(timeframe.period)

[m1c, m1b] = request.security(syminfo.tickerid, tf1, f_trend(atrLen, mult))
[m2c, m2b] = request.security(syminfo.tickerid, tf2, f_trend(atrLen, mult))
[m3c, m3b] = request.security(syminfo.tickerid, tf3, f_trend(atrLen, mult))

lvl1 = show1 and f_tfOk(tf1) ? m1c : na
lvl2 = show2 and f_tfOk(tf2) ? m2c : na
lvl3 = show3 and f_tfOk(tf3) ? m3c : na

lnSty = mtfSty == 'Solid' ? line.style_solid : mtfSty == 'Dotted' ? line.style_dotted : line.style_dashed

// horizontal line from the bar where the current level began, extended right
f_level(float lvl, color col) =>
    var int  start = na
    var line ln    = na
    if not na(lvl) and (na(lvl[1]) or lvl != lvl[1])
        start := bar_index
    if barstate.islast
        line.delete(ln)
        if not na(lvl) and not na(start)
            ln := line.new(start, lvl, start + 1, lvl, extend = extend.right, color = col, style = lnSty, width = mtfW)

f_level(lvl1, col1)
f_level(lvl2, col2)
f_level(lvl3, col3)

// ── alerts ──
alertcondition(flipUp, 'Trend turned up', 'Trends ATR: trend turned UP on {{ticker}} ({{interval}})')
alertcondition(flipDn, 'Trend turned down', 'Trends ATR: trend turned DOWN on {{ticker}} ({{interval}})')
alertcondition(ta.cross(close, lvl1), 'Price crossed TF 1 level', 'Trends ATR: price crossed TF 1 level on {{ticker}}')
alertcondition(ta.cross(close, lvl2), 'Price crossed TF 2 level', 'Trends ATR: price crossed TF 2 level on {{ticker}}')
alertcondition(ta.cross(close, lvl3), 'Price crossed TF 3 level', 'Trends ATR: price crossed TF 3 level on {{ticker}}')
````
