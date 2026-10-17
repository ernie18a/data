# Fractal Memory Projection [Jayadev Rana]

- url: https://www.tradingview.com/script/11TqZxMc-Fractal-Memory-Projection-Jayadev-Rana/
- type: indicator
- pine_id: PUB;e2204eac8cfa47f196dbd02f3a738be6
- version: 1.0

## Description

Fractal Memory Projection searches price history for the moment that most resembles the present, then shows what happened next - drawn on your chart as 50 lighter ghost candles ahead of the current bar - together with trend-flip BUY and SELL signals and volatility-adaptive targets.

HOW THE FORECAST WORKS
The last 30 closes are converted to normalized log returns (the pattern window). The script scans up to 750 past bars and scores every historical window of the same length by mean squared distance, so the comparison is about the shape of movement, not price level. The bars that followed the best match are replayed forward from the current close, rescaled by the ratio of current ATR to ATR at the match, and drawn as 50 semi-transparent ghost candles beyond the last bar. The panel reports the match similarity, how many bars ago it occurred, and the net forecast direction.

The projection is a statistical analog - a look at how the most similar past episode unfolded - not a prediction or a guarantee. It is display-only and never affects historical values, so nothing repaints.

BUY AND SELL SIGNALS
An ATR trailing stop tracks the trend. When it flips direction, a BUY or SELL label prints - by default only when the ghost-candle forecast agrees with the flip direction (toggle available). Alerts are included for both signals.

VOLATILITY-ADAPTIVE TARGETS
Target spacing is not fixed. A unit of risk R equals ATR multiplied by (0.8 + ATR percentile rank over 200 bars), so quiet markets produce tighter targets and volatile markets produce wider ones. Each signal sets TP1, TP2 and TP3 at 1R, 2R and 3R and a stop loss at 1.2R (adjustable). Only the most recent trade's levels are kept on the chart to stay clean.

PANEL
Match quality percent, bars since the match, volatility regime (Low, Normal, High), forecast direction, and current trend side.

SETTINGS
Pattern window, scan depth, forecast length, ghost candle colors, ATR length, trail multiplier, forecast-agreement filter, stop multiplier, and panel position are all configurable.

NOTES
Works on any symbol and timeframe with enough history (at least scan depth plus forecast length bars). This is an analysis tool, not financial advice. Test on your own data and manage risk before trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bluealgocapital

//@version=6
indicator("Fractal Memory Projection [Jayadev Rana]", "FMP", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

gFC   = "Forecast"
showGhost = input.bool(true, "Show Ghost Candles", group = gFC)
winLen    = input.int(30, "Pattern Window (bars)", minval = 10, maxval = 60, group = gFC)
scanDepth = input.int(750, "Scan Depth (bars)", minval = 200, maxval = 2000, group = gFC)
fcLen     = input.int(50, "Forecast Length (candles)", minval = 10, maxval = 100, group = gFC)
ghostUpCol = input.color(color.new(#26a69a, 72), "Ghost Up", inline = "gc", group = gFC)
ghostDnCol = input.color(color.new(#ef5350, 72), "Ghost Down", inline = "gc", group = gFC)

gSig  = "Signals & Targets"
showSig   = input.bool(true, "Show BUY/SELL Signals", group = gSig)
atrLen    = input.int(14, "ATR Length", minval = 2, group = gSig)
trailMult = input.float(2.5, "Trail Stop (ATR x)", minval = 0.5, step = 0.1, group = gSig)
needAgree = input.bool(true, "Require Forecast Agreement", group = gSig)
slMult    = input.float(1.2, "Stop Loss (R x)", minval = 0.2, step = 0.1, group = gSig)
showTrade = input.bool(true, "Show Last Trade Levels", group = gSig)

gUI   = "Panel"
showPanel = input.bool(true, "Show Panel", group = gUI)
panelPos  = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gUI)

atr      = ta.atr(atrLen)
volRank  = ta.percentrank(atr, 200) / 100
volTxt   = volRank > 0.7 ? "High" : volRank < 0.3 ? "Low" : "Normal"
unitR    = atr * (0.8 + volRank)

var float trail = na
var int   dir   = 1
src = close
upStop = src - atr * trailMult
dnStop = src + atr * trailMult
trail := dir == 1 ? math.max(nz(trail, upStop), upStop) : math.min(nz(trail, dnStop), dnStop)
newDir = dir == 1 and close < trail ? -1 : dir == -1 and close > trail ? 1 : dir
flipUp = newDir == 1 and dir == -1
flipDn = newDir == -1 and dir == 1
if flipUp
    trail := upStop
if flipDn
    trail := dnStop
dir := newDir

ret = math.log(close / close[1])
retSd = ta.stdev(ret, winLen)
max_bars_back(ret, 2200)
max_bars_back(atr, 2200)

var box[]  gBodies = array.new<box>()
var line[] gWicks  = array.new<line>()
var float  matchQ   = na
var int    matchAge = na
var int    fcDir    = 0
var float  fcClose  = na

if barstate.islast
    for b in gBodies
        box.delete(b)
    for w in gWicks
        line.delete(w)
    array.clear(gBodies)
    array.clear(gWicks)

    maxScan = math.min(scanDepth, bar_index - winLen - fcLen - 1)
    if maxScan > winLen + fcLen
        curSd = nz(retSd, 1e-10) + 1e-10
        bestErr = 1e20
        bestOff = -1
        for j = fcLen + 1 to maxScan
            err = 0.0
            for k = 0 to winLen - 1
                d = nz(ret[k]) / curSd - nz(ret[j + k]) / curSd
                err := err + d * d
            if err < bestErr
                bestErr := err
                bestOff := j
        if bestOff > 0
            matchAge := bestOff
            matchQ   := math.max(0, 100 - math.sqrt(bestErr / winLen) * 100)
            mAtr = nz(atr[bestOff], atr) + 1e-10
            scaleF = atr / mAtr
            pc = close
            for i = 1 to fcLen
                idx = bestOff - i
                ro = nz(ret[idx]) * scaleF
                o = pc
                c = pc * math.exp(ro)
                hiRaw = math.max(o, c) * (1 + nz(math.abs(ret[idx])) * 0.35 * scaleF)
                loRaw = math.min(o, c) * (1 - nz(math.abs(ret[idx])) * 0.35 * scaleF)
                up = c >= o
                if showGhost
                    array.push(gBodies, box.new(bar_index + i, math.max(o, c), bar_index + i, math.min(o, c), border_color = up ? ghostUpCol : ghostDnCol, border_width = 2, bgcolor = up ? ghostUpCol : ghostDnCol))
                    array.push(gWicks, line.new(bar_index + i, hiRaw, bar_index + i, loRaw, color = up ? ghostUpCol : ghostDnCol, width = 1))
                pc := c
            fcClose := pc
            fcDir   := pc > close ? 1 : -1

agreeUp = not needAgree or fcDir >= 0
agreeDn = not needAgree or fcDir <= 0
buySig  = showSig and flipUp and agreeUp
sellSig = showSig and flipDn and agreeDn

var int   tDir   = 0
var int   tBar   = na
var float tEntry = na
var float tSL    = na
var float tTP1   = na
var float tTP2   = na
var float tTP3   = na

if buySig or sellSig
    tDir   := buySig ? 1 : -1
    tBar   := bar_index
    tEntry := close
    tSL    := tEntry - tDir * unitR * slMult
    tTP1   := tEntry + tDir * unitR
    tTP2   := tEntry + tDir * unitR * 2
    tTP3   := tEntry + tDir * unitR * 3
    label.new(bar_index, buySig ? low : high, buySig ? "BUY" : "SELL", style = buySig ? label.style_label_up : label.style_label_down, color = buySig ? color.new(#26a69a, 0) : color.new(#ef5350, 0), textcolor = color.white, size = size.small)

plot(trail, "Trail Stop", color = dir == 1 ? color.new(#26a69a, 55) : color.new(#ef5350, 55), style = plot.style_linebr)

var line  eLn  = na
var line  slLn = na
var line  t1Ln = na
var line  t2Ln = na
var line  t3Ln = na
var label eLb  = na
var label slLb = na
var label t1Lb = na
var label t2Lb = na
var label t3Lb = na

if showTrade and barstate.islast and tDir != 0
    if not na(eLn)
        line.delete(eLn)
    if not na(slLn)
        line.delete(slLn)
    if not na(t1Ln)
        line.delete(t1Ln)
    if not na(t2Ln)
        line.delete(t2Ln)
    if not na(t3Ln)
        line.delete(t3Ln)
    if not na(eLb)
        label.delete(eLb)
    if not na(slLb)
        label.delete(slLb)
    if not na(t1Lb)
        label.delete(t1Lb)
    if not na(t2Lb)
        label.delete(t2Lb)
    if not na(t3Lb)
        label.delete(t3Lb)
    x2 = bar_index + 12
    eLn  := line.new(tBar, tEntry, x2, tEntry, color = color.new(#787b86, 0), width = 2)
    slLn := line.new(tBar, tSL, x2, tSL, color = color.new(#ef5350, 0), width = 2)
    t1Ln := line.new(tBar, tTP1, x2, tTP1, color = color.new(#26a69a, 0), style = line.style_dashed, width = 2)
    t2Ln := line.new(tBar, tTP2, x2, tTP2, color = color.new(#26a69a, 0), style = line.style_dashed, width = 2)
    t3Ln := line.new(tBar, tTP3, x2, tTP3, color = color.new(#26a69a, 0), style = line.style_dashed, width = 2)
    eLb  := label.new(x2, tEntry, "Entry " + str.tostring(tEntry, format.mintick), style = label.style_label_left, color = color.new(#787b86, 20), textcolor = color.white, size = size.small)
    slLb := label.new(x2, tSL, "SL " + str.tostring(tSL, format.mintick), style = label.style_label_left, color = color.new(#ef5350, 20), textcolor = color.white, size = size.small)
    t1Lb := label.new(x2, tTP1, "TP1 " + str.tostring(tTP1, format.mintick), style = label.style_label_left, color = color.new(#26a69a, 20), textcolor = color.white, size = size.small)
    t2Lb := label.new(x2, tTP2, "TP2 " + str.tostring(tTP2, format.mintick), style = label.style_label_left, color = color.new(#26a69a, 20), textcolor = color.white, size = size.small)
    t3Lb := label.new(x2, tTP3, "TP3 " + str.tostring(tTP3, format.mintick), style = label.style_label_left, color = color.new(#26a69a, 20), textcolor = color.white, size = size.small)

alertcondition(buySig, "FMP Buy", "FMP buy signal")
alertcondition(sellSig, "FMP Sell", "FMP sell signal")

f_pos(s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

GOLD  = color.new(#c9a227, 0)
INK   = color.new(#131722, 0)
CLEAR = color.new(color.white, 100)

var table pan = table.new(f_pos(panelPos), 2, 6, bgcolor = CLEAR, border_color = GOLD, border_width = 1, frame_color = GOLD, frame_width = 1)

if barstate.islast and showPanel
    table.cell(pan, 0, 0, "FMP", text_color = INK, text_size = size.small)
    table.cell(pan, 1, 0, "Fractal Memory 🔮", text_color = INK, text_size = size.small)
    table.cell(pan, 0, 1, "Match", text_color = INK, text_size = size.small)
    table.cell(pan, 1, 1, na(matchQ) ? "…" : str.tostring(matchQ, "#.#") + " %", text_color = INK, text_size = size.small)
    table.cell(pan, 0, 2, "Found", text_color = INK, text_size = size.small)
    table.cell(pan, 1, 2, na(matchAge) ? "…" : str.tostring(matchAge) + " bars ago", text_color = INK, text_size = size.small)
    table.cell(pan, 0, 3, "Volatility", text_color = INK, text_size = size.small)
    table.cell(pan, 1, 3, volTxt, text_color = volRank > 0.7 ? color.new(#ef5350, 0) : volRank < 0.3 ? color.new(#26a69a, 0) : INK, text_size = size.small)
    table.cell(pan, 0, 4, "Forecast", text_color = INK, text_size = size.small)
    table.cell(pan, 1, 4, fcDir > 0 ? "Up ▲" : fcDir < 0 ? "Down ▼" : "…", text_color = fcDir > 0 ? color.new(#26a69a, 0) : color.new(#ef5350, 0), text_size = size.small)
    table.cell(pan, 0, 5, "Trend", text_color = INK, text_size = size.small)
    table.cell(pan, 1, 5, dir == 1 ? "Long" : "Short", text_color = dir == 1 ? color.new(#26a69a, 0) : color.new(#ef5350, 0), text_size = size.small)
````
