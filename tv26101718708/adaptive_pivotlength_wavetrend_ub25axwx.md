# Adaptive Pivot-Length WaveTrend

- url: https://www.tradingview.com/script/UB25AXWX-Adaptive-Pivot-Length-WaveTrend/
- type: indicator
- pine_id: PUB;89b83c166de44a98b3fa5cb8729c4f7e
- version: 2.0

## Description

[i][b]Adaptive Pivot-Length WaveTrend (APL-WT)[/b][/i]
A self-tuning WaveTrend oscillator that derives its smoothing lengths from the market’s own dominant cycle rather than fixed user inputs. A multi-scale pivot engine sweeps pivot strengths from 14 to 100 bars, building a probability mass function (PMF) over pivot-to-pivot distances. The mode of that distribution — the statistically dominant cycle length L — drives both WaveTrend lengths: n2 = L (average) and n1 = round(L × ratio) (channel), with floors, ceilings, and a stickiness tolerance to prevent jitter.
Because length adapts bar-to-bar, WaveTrend’s EMA state is carried manually to stay stable when periods change. Overbought, oversold, and mid-band levels are not hardcoded — they’re computed as empirical percentiles of WT1’s own recent distribution (default: 95/80/50/20/5 over 2000 bars), so the thresholds self-calibrate to each instrument and timeframe.

[i][b]Signals[/b][/i]
	•	Bullish/bearish WT1/WT2 crosses gated by the adaptive OS/OB percentile levels
	•	Mid-line cross alerts
	•	Full regular and hidden divergence suite (bull, bear, hidden bull, hidden bear) with pivot lookback controls, gated by the ±50 zones on WT1

[i][b]Readouts[/b][/i]
[i]Optional info table showing dominant L, active n1/n2, cumulative pivot sample count, live WT1/WT2 values, WT1’s self-percentile rank, current OB/OS levels, regime state (OB / Upper / Mid / Lower / OS), and WT1-vs-WT2 polarity. Optional bar coloring in OB/OS extremes.
Best suited for traders who want WaveTrend to respect the actual cycle structure of whatever they’re looking at, without manually tuning lengths per symbol or timeframe.​​​​​​​​​​​​​​​​[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cmo22

//@version=6
indicator("Adaptive Pivot-Length WaveTrend", "APL-WT", overlay=false, max_bars_back=5000)

// ───── Inputs ─────
grpA = "Adaptive Engine"
minStr   = input.int(14,  "Min pivot strength sweep", group=grpA)
maxStr   = input.int(100, "Max pivot strength sweep", group=grpA)
maxLen   = input.int(120, "Max pivot length tracked", group=grpA)
minN     = input.int(40,  "Min samples before adaptive engages", group=grpA)
useAlt   = input.bool(true, "Alternate H/L only", group=grpA)
n2Floor  = input.int(10,  "Average (n2) floor",   group=grpA)
n2Ceil   = input.int(120, "Average (n2) ceiling", group=grpA)
n1Floor  = input.int(5,   "Channel (n1) floor",   group=grpA)
n1Ceil   = input.int(60,  "Channel (n1) ceiling", group=grpA)
n1Ratio  = input.float(0.5, "n1 = L × ratio", minval=0.1, maxval=1.0, step=0.05, group=grpA)
stickTol = input.int(1,   "Length change tolerance (stickiness)", group=grpA)

grpL = "Adaptive Levels"
obPct   = input.float(95, "Overbought percentile", group=grpL)
osPct   = input.float(5,  "Oversold percentile",   group=grpL)
hPct    = input.float(80, "Upper mid percentile",  group=grpL)
lPct    = input.float(20, "Lower mid percentile",  group=grpL)
lvlLkbk = input.int(2000, "Level lookback bars",   group=grpL)

grpV = "Visuals"
showInfo  = input.bool(false,  "Show info table", group=grpV)
srcIn     = input.source(hlc3, "Source",         group=grpV)
colorbars = input.bool(false, "Color bars",       group=grpV)

// ───── Multi-scale pivot PMF (confirmed only, non-repainting) ─────
var array<int>   lastBarArr  = array.new<int>(maxStr + 1, na)
var array<int>   lastTypeArr = array.new<int>(maxStr + 1, 0)
var array<float> pmf         = array.new<float>(maxLen + 1, 0.0)
var int totalN = 0

for s = minStr to maxStr
    ph_s = ta.pivothigh(s, s)
    pl_s = ta.pivotlow (s, s)
    lb = array.get(lastBarArr,  s)
    lt = array.get(lastTypeArr, s)

    if not na(ph_s)
        if not na(lb) and (not useAlt or lt != 1)
            dist = (bar_index - s) - lb
            if dist >= 1 and dist <= maxLen
                array.set(pmf, dist, array.get(pmf, dist) + 1.0)
                totalN += 1
        array.set(lastBarArr,  s, bar_index - s)
        array.set(lastTypeArr, s, 1)

    if not na(pl_s)
        if not na(lb) and (not useAlt or lt != -1)
            dist = (bar_index - s) - lb
            if dist >= 1 and dist <= maxLen
                array.set(pmf, dist, array.get(pmf, dist) + 1.0)
                totalN += 1
        array.set(lastBarArr,  s, bar_index - s)
        array.set(lastTypeArr, s, -1)

// ───── Dominant cycle L (sticky PMF mode) ─────
var int L = 21
if totalN >= minN
    pmax  = 0.0
    bestK = L
    for k = n2Floor to math.min(n2Ceil, maxLen)
        v = array.get(pmf, k)
        if v > pmax
            pmax  := v
            bestK := k
    if math.abs(bestK - L) > stickTol
        L := bestK
    L := math.max(n2Floor, math.min(n2Ceil, L))

n2 = L
n1 = math.max(n1Floor, math.min(n1Ceil, math.round(L * n1Ratio)))

// ───── WaveTrend with manual EMA state (dynamic-length safe) ─────
ap = srcIn
a1 = 2.0 / (n1 + 1)
a2 = 2.0 / (n2 + 1)

var float esa = na
var float dev = na
var float tci = na

esa := na(esa) ? ap : (1 - a1) * esa + a1 * ap
absDiff = math.abs(ap - esa)
dev := na(dev) ? absDiff : (1 - a1) * dev + a1 * absDiff
ci  = dev == 0 ? 0.0 : (ap - esa) / (0.015 * dev)
tci := na(tci) ? ci : (1 - a2) * tci + a2 * ci

wt1    = tci
wt2    = ta.sma(wt1, 4)
wtDiff = wt1 - wt2

// ───── Empirical percentile levels of WT1's own distribution ─────
obLvl = ta.percentile_linear_interpolation(wt1, lvlLkbk, obPct)
osLvl = ta.percentile_linear_interpolation(wt1, lvlLkbk, osPct)
hiLvl = ta.percentile_linear_interpolation(wt1, lvlLkbk, hPct)
loLvl = ta.percentile_linear_interpolation(wt1, lvlLkbk, lPct)
midLv = ta.percentile_linear_interpolation(wt1, lvlLkbk, 50)
curPR = ta.percentrank(wt1, lvlLkbk)

// ───── Plots ─────
wt1Col = wt1 > hiLvl ? color.new(color.lime, 0) : wt1 < loLvl ? color.new(color.red, 0) : color.new(color.aqua, 20)
p1 = plot(wt1, "WT1", wt1Col, 2)
p2 = plot(wt2, "WT2", color.new(color.yellow, 40), 1)
fill(p1, p2, wt1 >= wt2 ? color.new(color.green, 80) : color.new(color.red, 80), "WT fill")

plot(wtDiff, "WT Diff", style=plot.style_columns, color=color.new(color.gray, 70))

pOB = plot(obLvl, "OB pctile", color.new(color.red,   70))
pOS = plot(osLvl, "OS pctile", color.new(color.green, 70))
plot(hiLvl, "Upper mid", color.new(color.red,   85))
plot(loLvl, "Lower mid", color.new(color.green, 85))
plot(midLv, "Median",    color.new(color.gray,  60))
fill(pOB, pOS, color.new(color.aqua, 96))
hline(0, "Zero", color.new(color.white, 70))

bgcolor(wt1 > obLvl ? color.new(color.red,   92) : na, title="OB zone")
bgcolor(wt1 < osLvl ? color.new(color.green, 92) : na, title="OS zone")

crossUp   = ta.crossover (wt1, wt2) and wt1 < osLvl
crossDown = ta.crossunder(wt1, wt2) and wt1 > obLvl
plotshape(crossUp,   "Buy OS",  shape.circle, location.bottom, color.lime, size=size.tiny)
plotshape(crossDown, "Sell OB", shape.circle, location.top,    color.red,  size=size.tiny)

barCol = wt1 > obLvl ? color.red : wt1 < osLvl ? color.lime : na
barcolor(colorbars ? barCol : na)

// ───── Info table ─────
var table info = table.new(position.top_right, 2, 8, border_width=1)
if barstate.islast and showInfo
    table.cell(info, 0, 0, "Dominant L", text_color=color.white, bgcolor=color.new(color.navy,30))
    table.cell(info, 1, 0, str.tostring(L),        text_color=color.aqua,  bgcolor=color.new(color.navy,30))
    table.cell(info, 0, 1, "n1 / n2",     text_color=color.white)
    table.cell(info, 1, 1, str.tostring(n1)+" / "+str.tostring(n2), text_color=color.white)
    table.cell(info, 0, 2, "Pivot samples", text_color=color.white)
    table.cell(info, 1, 2, str.tostring(totalN),   text_color=color.white)
    table.cell(info, 0, 3, "WT1 / WT2",   text_color=color.white)
    table.cell(info, 1, 3, str.tostring(wt1,"#.0")+" / "+str.tostring(wt2,"#.0"), text_color=color.white)
    table.cell(info, 0, 4, "Self-PctRank", text_color=color.white)
    table.cell(info, 1, 4, str.tostring(curPR,"#.0"), text_color=color.aqua)
    table.cell(info, 0, 5, "OB / OS",     text_color=color.white)
    table.cell(info, 1, 5, str.tostring(obLvl,"#.0")+" / "+str.tostring(osLvl,"#.0"), text_color=color.white)
    state = wt1 > obLvl ? "OB" : wt1 < osLvl ? "OS" : wt1 > hiLvl ? "Upper" : wt1 < loLvl ? "Lower" : "Mid"
    stCol = wt1 > obLvl ? color.red : wt1 < osLvl ? color.lime : color.gray
    table.cell(info, 0, 6, "State", text_color=color.white)
    table.cell(info, 1, 6, state,   text_color=stCol)
    table.cell(info, 0, 7, "WT1 ⟂ WT2", text_color=color.white)
    table.cell(info, 1, 7, wt1 >= wt2 ? "Bull" : "Bear", text_color = wt1 >= wt2 ? color.lime : color.red)

// ───── Alerts ─────
alertcondition(crossUp,   "APL-WT Buy",  "APL-WT: bullish cross in OS zone")
alertcondition(crossDown, "APL-WT Sell", "APL-WT: bearish cross in OB zone")
alertcondition(ta.crossover(wt1, midLv),  "APL-WT mid up",   "APL-WT crossed above median")
alertcondition(ta.crossunder(wt1, midLv), "APL-WT mid down", "APL-WT crossed below median")


len = input.int(title="Osc Period", minval=1, defval=14)
src = input(title="Osc Source", defval=close)
lbR = input(title="Pivot Lookback Right", defval=5, display = display.none)
lbL = input(title="Pivot Lookback Left", defval=3, display = display.none)
rangeUpper = input(title="Max of Lookback Range", defval=60, display = display.none)
rangeLower = input(title="Min of Lookback Range", defval=5, display = display.none)
plotBull = input(title="Plot Bullish", defval=true, display = display.none)
plotHiddenBull = input(title="Plot Hidden Bullish", defval=false, display = display.none)
plotBear = input(title="Plot Bearish", defval=true, display = display.none)
plotHiddenBear = input(title="Plot Hidden Bearish", defval=false, display = display.none)
bearColor = color.red
bullColor = color.green
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)
osc = wt1



plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true
_inRange(cond) =>
	bars = ta.barssince(cond == true)
	rangeLower <= bars and bars <= rangeUpper

//------------------------------------------------------------------------------
// Regular Bullish
// Osc: Higher Low
inRangePl = _inRange(plFound[1])
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRangePl

// Price: Lower Low

priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCondAlert = priceLL and oscHL and plFound
bullCond = plotBull and bullCondAlert and osc < -50

plot(
     plFound ? osc[lbR] : na,
     offset=-lbR,
     title="Regular Bullish",
     linewidth=2,
     color=(bullCond ? bullColor : noneColor),
	 display = display.pane,
	 editable = plotBull
     )

plotshape(
	 bullCond ? osc[lbR] : na,
	 offset=-lbR,
	 title="Regular Bullish Label",
	 text=" Bull ",
	 style=shape.labelup,
	 location=location.absolute,
	 color=bullColor,
	 textcolor=textColor,
	 editable = plotBull
	 )

//------------------------------------------------------------------------------
// Hidden Bullish
// Osc: Lower Low

oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRangePl

// Price: Higher Low

priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCondAlert = priceHL and oscLL and plFound
hiddenBullCond = plotHiddenBull and hiddenBullCondAlert

plot(
	 plFound ? osc[lbR] : na,
	 offset=-lbR,
	 title="Hidden Bullish",
	 linewidth=2,
	 color=(hiddenBullCond ? hiddenBullColor : noneColor),
	 display = display.pane,
	 editable = plotHiddenBull
	 )

plotshape(
	 hiddenBullCond ? osc[lbR] : na,
	 offset=-lbR,
	 title="Hidden Bullish Label",
	 text=" H Bull ",
	 style=shape.labelup,
	 location=location.absolute,
	 color=bullColor,
	 textcolor=textColor,
	 editable = plotHiddenBull
	 )

//------------------------------------------------------------------------------
// Regular Bearish
// Osc: Lower High
inRangePh = _inRange(phFound[1])
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRangePh

// Price: Higher High

priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)

bearCondAlert = priceHH and oscLH and phFound
bearCond = plotBear and bearCondAlert and osc > 50

plot(
	 phFound ? osc[lbR] : na,
	 offset=-lbR,
	 title="Regular Bearish",
	 linewidth=2,
	 color=(bearCond ? bearColor : noneColor),
	 display = display.pane,
	 editable = plotBear
	 )

plotshape(
	 bearCond  ? osc[lbR] : na,
	 offset=-lbR,
	 title="Regular Bearish Label",
	 text=" Bear ",
	 style=shape.labeldown,
	 location=location.absolute,
	 color=bearColor,
	 textcolor=textColor,
	 editable = plotBear
	 )

//------------------------------------------------------------------------------
// Hidden Bearish
// Osc: Higher High

oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and inRangePh

// Price: Lower High

priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)

hiddenBearCondAlert = priceLH and oscHH and phFound
hiddenBearCond = plotHiddenBear and hiddenBearCondAlert

plot(
	 phFound ? osc[lbR] : na,
	 offset=-lbR,
	 title="Hidden Bearish",
	 linewidth=2,
	 color=(hiddenBearCond ? hiddenBearColor : noneColor),
	 display = display.pane,
	 editable = plotHiddenBear
	 )

plotshape(
	 hiddenBearCond ? osc[lbR] : na,
	 offset=-lbR,
	 title="Hidden Bearish Label",
	 text=" H Bear ",
	 style=shape.labeldown,
	 location=location.absolute,
	 color=bearColor,
	 textcolor=textColor,
	 editable = plotHiddenBear
	 )

alertcondition(bullCondAlert, title='Regular Bullish Divergence', message="Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar")
alertcondition(hiddenBullCondAlert, title='Hidden Bullish Divergence', message='Found a new Hidden Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar')
alertcondition(bearCondAlert, title='Regular Bearish Divergence', message='Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar')
alertcondition(hiddenBearCondAlert, title='Hidden Bearish Divergence', message='Found a new Hidden Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar')
````
