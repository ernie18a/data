<!-- tradingview-pine-id: PUB;e07d3f00059f42c1b90ad6a265a9cc1c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Taught to Trade - Regime Tercile Dashboard

Source: https://www.tradingview.com/script/dsPXgFSZ-Taught-to-Trade-Regime-Tercile-Dashboard/

## Description

🔵 OVERVIEW

Most strategies are tested across one stretch of history and judged on a single number. This splits that history into its low, middle and high volatility thirds and reports how the instrument actually behaved inside each one.

The question it answers is not "what happens next". It is "does the thing I found exist in all three regimes, or only in one". An edge that lives in a single regime is a bet on the regime continuing, which is a different and much shorter bet than the one most people think they are making.

Everything is computed from closed bars. Nothing repaints.

🔵 WHAT A VOLATILITY REGIME IS HERE

ATR is expressed as a percentage of price, so instruments at different price levels are comparable. The sample window is then cut at its own 33rd and 67th percentiles. Bars below the lower cutoff are the low third, above the upper cutoff the high third, and the rest the middle.

The cutoffs are relative to the instrument and the window, not to any fixed number. A quiet week in one market can be a violent one in another, and a fixed ATR threshold would hide that.

🔵 HOW TO READ THE TABLE

Bars and Share show how the window divides. If one third holds most of the sample, the window is not really covering three regimes and the comparison is weak.

Range is the average high-to-low of a bar in that regime, as a percentage of price. It should rise from low to high. If it does not, the classification is not separating anything.

Up is the share of bars in that regime that closed above their open. This is the column worth sitting with. Volatility is a measure of range, not of direction, so there is no reason for this number to be far from 50 percent in any regime, and when it is, that is a property of the sample rather than a rule about the future.

Follow is conditional persistence: of the bars that followed an up bar in that regime, how many also closed up. Read it against the Up column, not on its own.

Now, Regime changes and ATR% cutoffs describe stability. Few changes across a long window means the regimes are broad and slow. Many means the classification is flickering and the per-regime statistics are thinner than the bar counts suggest.

🔵 HOW TO USE IT

Bucket your own past trades by the regime of their entry bar. The background shading makes that quick to do by eye. If every winning trade sits in one shaded band, you have found a regime, not a strategy.

Set the sample window to match the window your strategy was tested on, not to a round number. Comparing regimes across a window your test never touched tells you nothing about your test.

Check whether Range actually separates. If low and high thirds have nearly the same average bar range, the instrument has no meaningful volatility structure in that window, and the rest of the table is noise.

🔵 SETTINGS

ATR length and sample window size. Background shading on or off, with adjustable transparency. Table position and text size. Three alert conditions cover entering the high third, entering the low third, and any regime change. None of them fire on their own; you arm them yourself in the alerts dialog. This script does not send buy or sell signals and never will.

🔵 WHERE IT FAILS

The terciles are computed inside the same window they are judging. That is close to circular: a window that happens to be uniformly quiet will still be cut into three parts and labelled low, middle and high, and the labels will mean much less than they appear to.

A third is not a regime. Real regime changes are driven by things ATR cannot see, and the boundary between the 33rd and 34th percentile is arbitrary. A bar one tick either side of a cutoff gets a different label and is not meaningfully different.

The Up and Follow columns are descriptive statistics on a few hundred bars. Differences of a few percentage points are well inside what chance produces at that sample size, and nothing here corrects for that. Treat only large, stable gaps as worth a second look, and even then as a question rather than an answer.

ATR is backward looking. The current classification uses recent bars, so a regime change is visible only after it has been under way for a while. This will not warn you about anything.

Regime persistence is not modelled at all. Knowing that 20 percent of bars were high volatility says nothing about how long the current state lasts.

It measures bars, not your trades. Attributing your results to a regime by eye is a rough operation, and a proper version needs your actual trade list.

Open source, so you can read every calculation instead of taking any of this on trust.

Educational tool only, not investment advice. It does not predict anything and does not generate signals. Trading involves substantial risk of loss.

---

## Source Code

````pine
//@version=6
// Taught to Trade - Regime Tercile Dashboard
// Splits the sample window into low, middle and high volatility thirds.
// No buy/sell signals. Alerts are yours to configure.
indicator("Taught to Trade - Regime Tercile Dashboard", shorttitle = "TT REGIME", overlay = true, max_bars_back = 1000)

grpM = "Measurement"
atrLen   = input.int(14, "ATR length", minval = 2, group = grpM)
lookback = input.int(500, "Sample window (bars)", minval = 60, maxval = 1000, group = grpM)

grpV = "Chart"
shadeBg  = input.bool(true, "Shade the background by regime", group = grpV)
shadeAmt = input.int(88, "Shading transparency", minval = 60, maxval = 98, group = grpV)

grpT = "Table"
posIn = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpT)
szIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpT)

atr    = ta.atr(atrLen)
atrPct = close > 0 ? atr / close * 100.0 : na
p33 = ta.percentile_linear_interpolation(atrPct, lookback, 33)
p67 = ta.percentile_linear_interpolation(atrPct, lookback, 67)

reg = na(atrPct) or na(p33) or na(p67) ? -1 : atrPct <= p33 ? 0 : atrPct <= p67 ? 1 : 2
cls = reg >= 0

rangePct = close > 0 ? (high - low) / close * 100.0 : 0.0
isUp   = close > open
prevUp = close[1] > open[1]
pReg   = nz(reg[1], -1)

cLow  = math.sum(reg == 0 ? 1 : 0, lookback)
cMid  = math.sum(reg == 1 ? 1 : 0, lookback)
cHigh = math.sum(reg == 2 ? 1 : 0, lookback)
total = cLow + cMid + cHigh

rLow  = math.sum(reg == 0 ? rangePct : 0.0, lookback)
rMid  = math.sum(reg == 1 ? rangePct : 0.0, lookback)
rHigh = math.sum(reg == 2 ? rangePct : 0.0, lookback)

uLow  = math.sum(reg == 0 and isUp ? 1 : 0, lookback)
uMid  = math.sum(reg == 1 and isUp ? 1 : 0, lookback)
uHigh = math.sum(reg == 2 and isUp ? 1 : 0, lookback)

pLow  = math.sum(pReg == 0 and prevUp ? 1 : 0, lookback)
pMid  = math.sum(pReg == 1 and prevUp ? 1 : 0, lookback)
pHigh = math.sum(pReg == 2 and prevUp ? 1 : 0, lookback)

bLow  = math.sum(pReg == 0 and prevUp and isUp ? 1 : 0, lookback)
bMid  = math.sum(pReg == 1 and prevUp and isUp ? 1 : 0, lookback)
bHigh = math.sum(pReg == 2 and prevUp and isUp ? 1 : 0, lookback)

regimeChanges = math.sum(cls and cls[1] and reg != reg[1] ? 1 : 0, lookback)
barsInRegime  = ta.barssince(cls and cls[1] and reg != reg[1])
regimeName    = reg == 0 ? "Low" : reg == 1 ? "Middle" : reg == 2 ? "High" : "n/a"

f_safe(float num, float den) => den > 0 ? num / den : na
f_pc(float v)  => na(v) ? "-" : str.tostring(v, "#") + "%"
f_pc2(float v) => na(v) ? "-" : str.tostring(v, "#.##") + "%"

bgcolor(shadeBg and reg == 0 ? color.new(#2F6FED, shadeAmt) : shadeBg and reg == 2 ? color.new(#B3261E, shadeAmt) : na, title = "Regime shading")

tblPos = posIn == "Top left" ? position.top_left : posIn == "Bottom right" ? position.bottom_right : posIn == "Bottom left" ? position.bottom_left : position.top_right
tblSz  = szIn == "Tiny" ? size.tiny : szIn == "Normal" ? size.normal : size.small

bgCol  = color.new(#0E1526, 10)
txtCol = color.new(#E6EAF2, 0)
hdrCol = color.new(#2F6FED, 0)

var table t = table.new(tblPos, 6, 7, border_width = 1, border_color = color.new(#2F6FED, 70))

f_h(int c, string s) => table.cell(t, c, 0, s, text_color = color.white, text_size = tblSz, bgcolor = hdrCol)
f_v(int c, int r, string s) => table.cell(t, c, r, s, text_color = txtCol, text_size = tblSz, text_halign = text.align_right, bgcolor = bgCol)
f_n(int r, string s, color bc) => table.cell(t, 0, r, s, text_color = color.white, text_size = tblSz, text_halign = text.align_left, bgcolor = bc)
f_l(int c, int r, string s) => table.cell(t, c, r, s, text_color = txtCol, text_size = tblSz, text_halign = text.align_left, bgcolor = bgCol)

if barstate.islast
    f_h(0, "REGIME")
    f_h(1, "Bars")
    f_h(2, "Share")
    f_h(3, "Range")
    f_h(4, "Up")
    f_h(5, "Follow")
    f_n(1, "Low vol", color.new(#2F6FED, 35))
    f_v(1, 1, str.tostring(cLow))
    f_v(2, 1, f_pc(f_safe(cLow * 100.0, total)))
    f_v(3, 1, f_pc2(f_safe(rLow, cLow)))
    f_v(4, 1, f_pc(f_safe(uLow * 100.0, cLow)))
    f_v(5, 1, f_pc(f_safe(bLow * 100.0, pLow)))
    f_n(2, "Middle", color.new(#5A6478, 35))
    f_v(1, 2, str.tostring(cMid))
    f_v(2, 2, f_pc(f_safe(cMid * 100.0, total)))
    f_v(3, 2, f_pc2(f_safe(rMid, cMid)))
    f_v(4, 2, f_pc(f_safe(uMid * 100.0, cMid)))
    f_v(5, 2, f_pc(f_safe(bMid * 100.0, pMid)))
    f_n(3, "High vol", color.new(#B3261E, 35))
    f_v(1, 3, str.tostring(cHigh))
    f_v(2, 3, f_pc(f_safe(cHigh * 100.0, total)))
    f_v(3, 3, f_pc2(f_safe(rHigh, cHigh)))
    f_v(4, 3, f_pc(f_safe(uHigh * 100.0, cHigh)))
    f_v(5, 3, f_pc(f_safe(bHigh * 100.0, pHigh)))
    f_n(4, "Now", hdrCol)
    f_l(1, 4, regimeName + " for " + str.tostring(nz(barsInRegime, 0)) + " bars")
    f_l(0, 5, "Regime changes")
    f_l(1, 5, str.tostring(regimeChanges) + " in " + str.tostring(lookback) + " bars")
    f_l(0, 6, "ATR% cutoffs")
    f_l(1, 6, str.tostring(p33, "#.##") + " / " + str.tostring(p67, "#.##"))

enteredHigh = cls and cls[1] and reg == 2 and reg[1] != 2
enteredLow  = cls and cls[1] and reg == 0 and reg[1] != 0
anyChange   = cls and cls[1] and reg != reg[1]

alertcondition(enteredHigh, title = "Entered the high volatility third", message = "Regime Tercile Dashboard: this chart has entered the high volatility third of its sample window.")
alertcondition(enteredLow, title = "Entered the low volatility third", message = "Regime Tercile Dashboard: this chart has entered the low volatility third of its sample window.")
alertcondition(anyChange, title = "Volatility regime changed", message = "Regime Tercile Dashboard: the volatility regime on this chart has changed.")
````
