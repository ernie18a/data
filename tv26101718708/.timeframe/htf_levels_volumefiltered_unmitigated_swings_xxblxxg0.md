# HTF Levels + Volume-Filtered Unmitigated Swings

- url: https://www.tradingview.com/script/XxBLXXg0-HTF-Levels-Volume-Filtered-Unmitigated-Swings/
- type: indicator
- pine_id: PUB;686fc852b17e428c89e8472a6328e875
- version: 1.0

## Description

Unmitigated Swings + HTF Confluence Levels
This indicator plots six categories of price reference levels on a single chart so traders can quickly identify zones of confluence where multiple independent level types overlap. The premise is that reactions are higher quality when price is approaching a level that is simultaneously meaningful on more than one basis — for example, an untested 1H swing low that also sits near the 4H 200 SMA and the .618 of the most recent 1H leg.

What it plots
Higher-timeframe SMAs. The 50 and 200 SMAs are pulled from the Daily, 4H, and 1H using request.security with lookahead off, then drawn as horizontal extensions on the current chart with a numeric price label. Each can be toggled individually.

Previous Day High and Low. PDH and PDL are tracked bar-by-bar using a running max/min that resets on each new daily bar, so the values are accurate intraday on any chart timeframe.
Previous Session High and Low. Rather than relying on TradingView's built-in session definition, this uses a configurable session window (default 18:00–08:00 exchange time, which covers the Globex / overnight period for U.S. futures). The script tracks the running high and low during that window and finalizes them when the session closes, so PSH/PSL reflect the actual overnight extremes rather than a generic session.

1H Fibonacci levels (.382, .500, .618, .786). The Fib range is anchored to the most recent 1H pivot high and pivot low using a configurable lookback (default 5 bars on each side). The .500 and .618 are drawn at a heavier weight because they are the primary reaction zones in this methodology; .382 and .786 are drawn lighter as secondary references.
Unmitigated 1H swing highs and lows. This is the script's main original component. Pivot highs and lows are detected on the 1H timeframe, but a swing is only plotted if the volume on the pivot bar passes a two-condition filter: it must be greater than the 20-period volume SMA and greater than the prior bar's volume. The intent is to filter out low-conviction pivots and keep only swings that printed on real participation. Each swing is then tracked in an array, and as soon as price closes through it the level is automatically removed from the chart. Levels older than a configurable age (default 10 days) are also pruned. The result is that the chart only ever shows swing levels that have not yet been tested — the "unmitigated" set.

Why these components are grouped
Each of the six categories represents a different type of memory in the market: institutional moving-average reference (SMAs), prior-period extremes (PDH/PDL, PSH/PSL), proportional retracement of the most recent leg (Fibs), and liquidity left behind at high-participation turning points (unmitigated swings). Used individually, any one of them produces a lot of noise. Used together, the meaningful trade locations are the ones where two or more of these independent references stack within a small price range. This script exists to make that stacking visible at a glance instead of requiring six separate indicators that each clutter the chart with their own labels and styling.

How to use it
Wait for price to approach a level. The setup gets stronger as more level types cluster within roughly 5–10 ticks of each other on gold (scale appropriately for other instruments). The unmitigated swings in particular tend to act as liquidity targets — price often sweeps them before reversing, so a sweep-and-reclaim of an unmitigated swing that also lines up with a Fib or SMA is a higher-quality entry than the swing alone. PSH/PSL frequently mark the boundaries of overnight ranges and are useful for both breakout and fade scenarios depending on which side of the range the regular session opens.

Inputs
All six categories can be toggled independently. The Globex session window, Fib pivot lookback, swing pivot lookback, volume MA length, max swing age, and label offset are all configurable. Label offset pushes the price labels to the right of the current bar so they do not overlap candles — increase it if labels still touch price action.

Notes
All higher-timeframe data uses lookahead=barmerge.lookahead_off to avoid repainting from future data. Swing levels are detected on closed 1H pivots, so they confirm swingLB bars after the actual high or low — this is intentional and necessary to avoid false pivots. Designed and tested on Micro Gold Futures (MGC) and Gold Futures (GC) but works on any liquid instrument.

## Source Code

````pine
//@version=6
indicator("Key Levels", overlay=true, max_bars_back=5000)

// ─── INPUTS ──────────────────────────────────────────────────────
gSMA = "SMA Levels"
showD50   = input.bool(true, "Daily 50 SMA",   group=gSMA)
showD200  = input.bool(true, "Daily 200 SMA",  group=gSMA)
show4H50  = input.bool(true, "4H 50 SMA",      group=gSMA)
show4H200 = input.bool(true, "4H 200 SMA",     group=gSMA)
show1H50  = input.bool(true, "1H 50 SMA",      group=gSMA)
show1H200 = input.bool(true, "1H 200 SMA",     group=gSMA)

gSess = "Session Levels"
showPDHL  = input.bool(true, "Prev Day H/L",     group=gSess)
showPSHL  = input.bool(true, "Prev Session H/L", group=gSess)
psSession = input.session("1800-0800", "Globex Session (PSH/PSL)", group=gSess)

gFib = "1H Fib Levels"
showFib     = input.bool(true, "Show 1H Fibs (.382 .50 .618 .786)", group=gFib)
fibLookback = input.int(5, "Pivot Lookback (1H bars)", group=gFib)

gSwing = "Unmitigated 1H Swing Levels"
showSwings = input.bool(true, "Show Unmitigated Swings",  group=gSwing)
swingLB    = input.int(3,     "Swing Lookback (1H bars)", group=gSwing)
volMaLen   = input.int(20,    "Volume MA Length",          group=gSwing)
swingDays  = input.int(10,    "Max Age (days)",            group=gSwing)
swingColor = input.color(color.new(color.blue, 20), "Swing Level Color", group=gSwing)

gLabels     = "Label Position"
labelOffset = input.int(5, "Label Offset (bars right of price)", minval=0, maxval=50, group=gLabels, tooltip="Pushes all labels to the right so they don't overlap candles. Increase if labels still touch candles.")

// ─── SMAs ────────────────────────────────────────────────────────
smaD50   = request.security(syminfo.tickerid, "D",   ta.sma(close, 50),  lookahead=barmerge.lookahead_off)
smaD200  = request.security(syminfo.tickerid, "D",   ta.sma(close, 200), lookahead=barmerge.lookahead_off)
sma4H50  = request.security(syminfo.tickerid, "240", ta.sma(close, 50),  lookahead=barmerge.lookahead_off)
sma4H200 = request.security(syminfo.tickerid, "240", ta.sma(close, 200), lookahead=barmerge.lookahead_off)
sma1H50  = request.security(syminfo.tickerid, "60",  ta.sma(close, 50),  lookahead=barmerge.lookahead_off)
sma1H200 = request.security(syminfo.tickerid, "60",  ta.sma(close, 200), lookahead=barmerge.lookahead_off)

var line lnD50   = na
var line lnD200  = na
var line ln4H50  = na
var line ln4H200 = na
var line ln1H50  = na
var line ln1H200 = na
var label lblD50   = na
var label lblD200  = na
var label lbl4H50  = na
var label lbl4H200 = na
var label lbl1H50  = na
var label lbl1H200 = na

if barstate.islast
    line.delete(lnD50)
    line.delete(lnD200)
    line.delete(ln4H50)
    line.delete(ln4H200)
    line.delete(ln1H50)
    line.delete(ln1H200)
    label.delete(lblD50)
    label.delete(lblD200)
    label.delete(lbl4H50)
    label.delete(lbl4H200)
    label.delete(lbl1H50)
    label.delete(lbl1H200)
    if showD50 and not na(smaD50)
        lnD50  := line.new(bar_index - 300, smaD50, bar_index, smaD50, color=color.new(color.orange, 10), width=2, extend=extend.right)
        lblD50 := label.new(bar_index + labelOffset, smaD50, "D 50 SMA  " + str.tostring(math.round(smaD50, 1)), style=label.style_label_left, color=color.new(color.orange, 10), textcolor=color.white, size=size.small)
    if showD200 and not na(smaD200)
        lnD200  := line.new(bar_index - 300, smaD200, bar_index, smaD200, color=color.new(color.red, 5), width=2, extend=extend.right)
        lblD200 := label.new(bar_index + labelOffset, smaD200, "D 200 SMA  " + str.tostring(math.round(smaD200, 1)), style=label.style_label_left, color=color.new(color.red, 5), textcolor=color.white, size=size.small)
    if show4H50 and not na(sma4H50)
        ln4H50  := line.new(bar_index - 300, sma4H50, bar_index, sma4H50, color=color.new(color.orange, 30), width=1, extend=extend.right)
        lbl4H50 := label.new(bar_index + labelOffset, sma4H50, "4H 50 SMA  " + str.tostring(math.round(sma4H50, 1)), style=label.style_label_left, color=color.new(color.orange, 30), textcolor=color.white, size=size.small)
    if show4H200 and not na(sma4H200)
        ln4H200  := line.new(bar_index - 300, sma4H200, bar_index, sma4H200, color=color.new(color.red, 25), width=1, extend=extend.right)
        lbl4H200 := label.new(bar_index + labelOffset, sma4H200, "4H 200 SMA  " + str.tostring(math.round(sma4H200, 1)), style=label.style_label_left, color=color.new(color.red, 25), textcolor=color.white, size=size.small)
    if show1H50 and not na(sma1H50)
        ln1H50  := line.new(bar_index - 300, sma1H50, bar_index, sma1H50, color=color.new(color.orange, 50), width=1, extend=extend.right)
        lbl1H50 := label.new(bar_index + labelOffset, sma1H50, "1H 50 SMA  " + str.tostring(math.round(sma1H50, 1)), style=label.style_label_left, color=color.new(color.orange, 50), textcolor=color.white, size=size.small)
    if show1H200 and not na(sma1H200)
        ln1H200  := line.new(bar_index - 300, sma1H200, bar_index, sma1H200, color=color.new(color.red, 45), width=1, extend=extend.right)
        lbl1H200 := label.new(bar_index + labelOffset, sma1H200, "1H 200 SMA  " + str.tostring(math.round(sma1H200, 1)), style=label.style_label_left, color=color.new(color.red, 45), textcolor=color.white, size=size.small)

// ─── PDH / PDL ───────────────────────────────────────────────────
var float pdHigh = na
var float pdLow  = na
var float todH   = na
var float todL   = na

newDay = ta.change(time("D")) != 0
if newDay
    pdHigh := todH
    pdLow  := todL
    todH   := high
    todL   := low
else
    todH := math.max(nz(todH, high), high)
    todL := math.min(nz(todL, low),  low)

var line  lnPDH  = na
var line  lnPDL  = na
var label lblPDH = na
var label lblPDL = na

if showPDHL and barstate.islast
    line.delete(lnPDH)
    line.delete(lnPDL)
    label.delete(lblPDH)
    label.delete(lblPDL)
    if not na(pdHigh)
        lnPDH  := line.new(bar_index - 300, pdHigh, bar_index, pdHigh, color=color.new(color.red, 10), width=2, extend=extend.right)
        lblPDH := label.new(bar_index + labelOffset, pdHigh, "PDH  " + str.tostring(math.round(pdHigh, 1)), style=label.style_label_left, color=color.new(color.red, 10), textcolor=color.white, size=size.small)
    if not na(pdLow)
        lnPDL  := line.new(bar_index - 300, pdLow, bar_index, pdLow, color=color.new(color.lime, 10), width=2, extend=extend.right)
        lblPDL := label.new(bar_index + labelOffset, pdLow, "PDL  " + str.tostring(math.round(pdLow, 1)), style=label.style_label_left, color=color.new(color.lime, 10), textcolor=color.white, size=size.small)

// ─── PSH / PSL ───────────────────────────────────────────────────
inPS = not na(time("1", psSession))

var float psHigh   = na
var float psLow    = na
var float pshFinal = na
var float pslFinal = na
var bool  prevInPS = false

if newDay
    if not na(psHigh)
        pshFinal := psHigh
        pslFinal := psLow
    psHigh := na
    psLow  := na
if inPS and not prevInPS
    psHigh := high
    psLow  := low
if inPS
    psHigh := math.max(psHigh, high)
    psLow  := math.min(psLow,  low)
if prevInPS and not inPS and not newDay
    pshFinal := psHigh
    pslFinal := psLow
prevInPS := inPS

var line  lnPSH  = na
var line  lnPSL  = na
var label lblPSH = na
var label lblPSL = na

if showPSHL and barstate.islast
    line.delete(lnPSH)
    line.delete(lnPSL)
    label.delete(lblPSH)
    label.delete(lblPSL)
    if not na(pshFinal)
        lnPSH  := line.new(bar_index - 300, pshFinal, bar_index, pshFinal, color=color.new(color.purple, 10), width=2, extend=extend.right)
        lblPSH := label.new(bar_index + labelOffset, pshFinal, "PSH  " + str.tostring(math.round(pshFinal, 1)), style=label.style_label_left, color=color.new(color.purple, 10), textcolor=color.white, size=size.small)
    if not na(pslFinal)
        lnPSL  := line.new(bar_index - 300, pslFinal, bar_index, pslFinal, color=color.new(color.purple, 10), width=2, extend=extend.right)
        lblPSL := label.new(bar_index + labelOffset, pslFinal, "PSL  " + str.tostring(math.round(pslFinal, 1)), style=label.style_label_left, color=color.new(color.purple, 10), textcolor=color.white, size=size.small)

// ─── 1H FIB ──────────────────────────────────────────────────────
ph1H_fib = request.security(syminfo.tickerid, "60", ta.pivothigh(high, fibLookback, fibLookback), lookahead=barmerge.lookahead_off)
pl1H_fib = request.security(syminfo.tickerid, "60", ta.pivotlow(low,   fibLookback, fibLookback), lookahead=barmerge.lookahead_off)

var float swH = na
var float swL = na
if not na(ph1H_fib)
    swH := ph1H_fib
if not na(pl1H_fib)
    swL := pl1H_fib

fibRng = not na(swH) and not na(swL) ? swH - swL : na
f382   = not na(fibRng) ? swL + fibRng * 0.382 : na
f50    = not na(fibRng) ? swL + fibRng * 0.500 : na
f618   = not na(fibRng) ? swL + fibRng * 0.618 : na
f786   = not na(fibRng) ? swL + fibRng * 0.786 : na

var line  lnF382  = na
var line  lnF50   = na
var line  lnF618  = na
var line  lnF786  = na
var label lblF382 = na
var label lblF50  = na
var label lblF618 = na
var label lblF786 = na

if showFib and barstate.islast
    line.delete(lnF382)
    line.delete(lnF50)
    line.delete(lnF618)
    line.delete(lnF786)
    label.delete(lblF382)
    label.delete(lblF50)
    label.delete(lblF618)
    label.delete(lblF786)
    if not na(f382)
        lnF382  := line.new(bar_index - 300, f382, bar_index, f382, color=color.black, width=1, extend=extend.right)
        lblF382 := label.new(bar_index + labelOffset, f382, ".382  " + str.tostring(math.round(f382, 1)), style=label.style_label_left, color=color.black, textcolor=color.white, size=size.small)
    if not na(f50)
        lnF50  := line.new(bar_index - 300, f50, bar_index, f50, color=color.black, width=2, extend=extend.right)
        lblF50 := label.new(bar_index + labelOffset, f50, ".50  " + str.tostring(math.round(f50, 1)), style=label.style_label_left, color=color.black, textcolor=color.white, size=size.small)
    if not na(f618)
        lnF618  := line.new(bar_index - 300, f618, bar_index, f618, color=color.black, width=2, extend=extend.right)
        lblF618 := label.new(bar_index + labelOffset, f618, ".618  " + str.tostring(math.round(f618, 1)), style=label.style_label_left, color=color.black, textcolor=color.white, size=size.small)
    if not na(f786)
        lnF786  := line.new(bar_index - 300, f786, bar_index, f786, color=color.black, width=1, extend=extend.right)
        lblF786 := label.new(bar_index + labelOffset, f786, ".786  " + str.tostring(math.round(f786, 1)), style=label.style_label_left, color=color.black, textcolor=color.white, size=size.small)

// ─── UNMITIGATED 1H SWING HIGHS / LOWS ──────────────────────────
h1_ph    = request.security(syminfo.tickerid, "60", ta.pivothigh(high, swingLB, swingLB), lookahead=barmerge.lookahead_off)
h1_pl    = request.security(syminfo.tickerid, "60", ta.pivotlow(low,   swingLB, swingLB), lookahead=barmerge.lookahead_off)
h1_vol   = request.security(syminfo.tickerid, "60", volume,                               lookahead=barmerge.lookahead_off)
h1_volMA = request.security(syminfo.tickerid, "60", ta.sma(volume, volMaLen),             lookahead=barmerge.lookahead_off)
h1_volPv = request.security(syminfo.tickerid, "60", volume[1],                            lookahead=barmerge.lookahead_off)

highVol = not na(h1_vol) and not na(h1_volMA) and not na(h1_volPv)
         and h1_vol > h1_volMA and h1_vol > h1_volPv

cutoffTime = time - swingDays * 86400000

var swingHLvls   = array.new_float(0)
var swingLLvls   = array.new_float(0)
var swingHLines  = array.new<line>(0)
var swingHLabels = array.new<label>(0)
var swingLLines  = array.new<line>(0)
var swingLLabels = array.new<label>(0)

if showSwings and not na(h1_ph) and highVol
    isDupe = false
    if array.size(swingHLvls) > 0
        for i = 0 to array.size(swingHLvls) - 1
            if math.abs(array.get(swingHLvls, i) - h1_ph) < syminfo.mintick * 10
                isDupe := true
    if not isDupe
        array.push(swingHLvls,   h1_ph)
        array.push(swingHLines,  line.new(bar_index - 1, h1_ph, bar_index, h1_ph, color=swingColor, width=1, style=line.style_dashed, extend=extend.right))
        array.push(swingHLabels, label.new(bar_index + labelOffset, h1_ph, "SH  " + str.tostring(math.round(h1_ph, 1)), style=label.style_label_left, color=swingColor, textcolor=color.white, size=size.small))

if showSwings and not na(h1_pl) and highVol
    isDupe = false
    if array.size(swingLLvls) > 0
        for i = 0 to array.size(swingLLvls) - 1
            if math.abs(array.get(swingLLvls, i) - h1_pl) < syminfo.mintick * 10
                isDupe := true
    if not isDupe
        array.push(swingLLvls,   h1_pl)
        array.push(swingLLines,  line.new(bar_index - 1, h1_pl, bar_index, h1_pl, color=swingColor, width=1, style=line.style_dashed, extend=extend.right))
        array.push(swingLLabels, label.new(bar_index + labelOffset, h1_pl, "SL  " + str.tostring(math.round(h1_pl, 1)), style=label.style_label_left, color=swingColor, textcolor=color.white, size=size.small))

if showSwings and array.size(swingHLvls) > 0
    i = array.size(swingHLvls) - 1
    while i >= 0
        lvl = array.get(swingHLvls, i)
        if close > lvl or time < cutoffTime
            line.delete(array.get(swingHLines,   i))
            label.delete(array.get(swingHLabels, i))
            array.remove(swingHLvls,   i)
            array.remove(swingHLines,  i)
            array.remove(swingHLabels, i)
        else
            label.set_x(array.get(swingHLabels, i), bar_index + labelOffset)
        i -= 1

if showSwings and array.size(swingLLvls) > 0
    i = array.size(swingLLvls) - 1
    while i >= 0
        lvl = array.get(swingLLvls, i)
        if close < lvl or time < cutoffTime
            line.delete(array.get(swingLLines,   i))
            label.delete(array.get(swingLLabels, i))
            array.remove(swingLLvls,   i)
            array.remove(swingLLines,  i)
            array.remove(swingLLabels, i)
        else
            label.set_x(array.get(swingLLabels, i), bar_index + labelOffset)
        i -= 1
````
