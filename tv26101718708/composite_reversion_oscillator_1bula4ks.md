# Composite Reversion Oscillator

- url: https://www.tradingview.com/script/1BULA4ks-Composite-Reversion-Oscillator/
- type: indicator
- pine_id: PUB;e1c34108bd964ed696cbe676ab12b7e0
- version: 4.0

## Description

Composite Reversion Oscillator

A short-term mean-reversion oscillator that blends three different "how stretched is this?" reads into one 0–100 line: how overbought/oversold momentum is, how long the current up/down streak has run, and where the latest return ranks against its own recent history. Each measures a different face of over-extension; together they flag exhaustion more reliably than any one alone.

Why these parts are combined (not a mashup for show). A short momentum oscillator flags overbought/oversold but ignores persistence. A streak read (an oscillator of the consecutive up/down-close count) captures persistence it misses — three green closes isn't one. A return-rank read captures the size of the latest move relative to its own norm, which neither of the others sees. Averaging the three yields a composite that only reaches an extreme when momentum, streak and move-size all agree — far fewer false "oversold" prints.

What's different here. Rather than presenting the composite as a fixed rule, it forward-calibrates whether those agreed extremes actually revert on this symbol, with an out-of-sample split and a multiple-testing check — because mean-reversion edges are regime-dependent and decay, which is exactly where symbol-specific honesty matters most. Signals fire once per excursion (no zone-edge whipsaw).

How it works. Component 1: a short-period momentum oscillator of price. Component 2: the same oscillator applied to the signed consecutive-close streak. Component 3: the percentile rank of the latest return within a recent window. The composite is their average, mapped to a ±100 pane. A long fires on the cross up out of oversold (and locks out until the line recovers to mid); a short mirrors it. Each is labelled by a triple barrier — a profit target and equal stop in ATR units plus a time limit — split into in-sample and recent out-of-sample.

How to use. Read the Verdict (Long/Short/Watch/Wait) and the Conviction, which reads "High" only when that turn type shows a positive edge that survives the test here — otherwise it openly says so. Best used with your own trend and risk plan, not alone. Non-repainting.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// COMPOSITE REVERSION OSCILLATOR — Three-Factor Mean-Reversion, Forward-Calibrated             v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — House-standard pass (no engine change):
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model (Net R): conviction now requires a reversion edge that also survives costs.
//        • No correctness fix needed — this script had no conditional-ta.* issue; the three-factor
//          composite, the arm/disarm signal logic and the forward calibration are unchanged.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A short-term mean-reversion oscillator that blends THREE different "how stretched is this?"
//   reads into one 0-100 line: how overbought/oversold momentum is, how long the current up/down
//   STREAK has run, and where today's return ranks against its own recent history. Each measures a
//   different face of being over-extended; together they identify exhaustion more reliably than any
//   one alone. It scores its own oversold/overbought turns forward on the chart you are viewing —
//   in plain language, with an out-of-sample split — so a non-technical reader can tell whether to
//   act or wait.
//
// WHY THESE PARTS ARE COMBINED (read this if you think it is a mashup)
//   Three over-extension reads are averaged because each fails in a different way alone:
//     • A short momentum oscillator flags overbought/oversold but ignores persistence.
//     • A STREAK read (an oscillator of the consecutive up/down-close count) captures persistence a
//       momentum read misses — three green closes is different from one.
//     • A return-rank read (today's return as a percentile of recent returns) captures the SIZE of
//       the move relative to its own norm, which neither of the others sees.
//   Averaging the three yields a composite that only reaches an extreme when momentum, streak AND
//   move-size all agree — far fewer false "oversold" prints. A forward-calibration layer then
//   measures whether those agreed extremes actually revert on THIS symbol.
//
// HOW IT WORKS
//   Component 1: a short-period momentum oscillator of price. Component 2: the same oscillator
//   applied to the signed consecutive-close streak. Component 3: the percentile rank of the latest
//   return within a recent window. The composite is their average (0-100), mapped to a +/-100 pane.
//   Signals: cross up out of oversold (long) / down out of overbought (short). Each is labelled by
//   a TRIPLE BARRIER (profit target + equal stop in ATR units, plus a time limit), split into
//   in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row: Long = composite turning up out of oversold; Short = down out of
//     overbought; Wait = mid-range.
//   • The CONVICTION row says whether that turn type has a positive, statistically-surviving edge
//     on THIS chart. Low conviction = treat as context only. Mean reversion is regime-dependent —
//     this is exactly where honest, symbol-specific calibration matters most.
//   • Green wave above zero = stretched up; red below = stretched down; shaded bands = extremes.
//     Best used with your own trend and risk plan, not alone.
//
// NON-REPAINT  Reads confirmed closes; calibration logs and resolves only on barstate.isconfirmed.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: short-term momentum oscillation;
//   a consecutive-streak oscillator; return percentile-ranking; triple-barrier outcome labelling
//   from standard supervised-labelling practice in quantitative finance; the Wilson score interval
//   for the proportion bound; and the Bonferroni adjustment for multiple testing. Credit is due to
//   the originators of each technique. This is an original implementation combining them into one
//   forward-calibrated mean-reversion tool.
//
// DISCLAIMER  For research and education only. Mean-reversion edges are regime-dependent and decay.
//   Edge figures are computed on this chart's own history with overlapping windows and no costs —
//   context, not a guaranteed backtest, and past behaviour does not predict the future. Nothing
//   here is financial advice. Trading carries risk of loss; size and manage your own positions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Composite Reversion Oscillator", "Comp Rev", overlay = false)

// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the source to use any market)
gMain    = "1 · General"
srcPrice = input.source(close, "Price source", group = gMain, tooltip = "Change for any symbol/market — this script is asset-agnostic.")
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gEng     = "2 · Composite engine"
rsiLen   = input.int(3,  "Momentum length", minval = 1, maxval = 50, group = gEng, tooltip = "Short momentum oscillator length.")
strkLen  = input.int(2,  "Streak length",   minval = 1, maxval = 50, group = gEng, tooltip = "Length of the oscillator applied to the consecutive-close streak.")
rankLen  = input.int(100,"Return-rank window", minval = 10, maxval = 500, group = gEng, tooltip = "Window for ranking the latest return against its own history.")

gSig     = "3 · Signal zones"
osLvl    = input.int(20, "Oversold level",   minval = 1, maxval = 49, group = gSig)
obLvl    = input.int(80, "Overbought level", minval = 51, maxval = 99, group = gSig)

gCal     = "4 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score signals forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(10, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A signal wins if price reaches the profit target (this many ATRs) before the equal-sized stop, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal)
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal)
calMinN  = input.int(20, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")

gUI      = "5 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto adapts table, text and line colors to the chart background.")
tintBg   = input.bool(true, "Tint pane in extremes", group = gUI)
colUp    = input.color(#2ebd85, "Up color",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Down color", inline = "c", group = gUI)

// THEME
bgc        = chart.bg_color
lumaV      = na(bgc) ? 0.0 : color.r(bgc)*0.299 + color.g(bgc)*0.587 + color.b(bgc)*0.114
darkUI     = dashTheme=="Dark" ? true : dashTheme=="Light" ? false : (na(bgc) or lumaV < 140)
panelBg    = darkUI ? color.rgb(17,22,28)    : color.rgb(244,246,248)
rowAlt     = darkUI ? color.rgb(25,31,39)    : color.rgb(232,236,240)
txtMain    = darkUI ? color.rgb(236,239,243) : color.rgb(16,20,24)
txtSub     = darkUI ? color.rgb(154,166,178) : color.rgb(74,82,91)
frameC     = darkUI ? color.rgb(58,70,84)    : color.rgb(196,204,212)
upC        = darkUI ? colUp : color.rgb(22,151,106)
dnC        = darkUI ? colDn : color.rgb(200,42,64)
flatC      = darkUI ? color.rgb(120,130,140) : color.rgb(122,130,139)
gridC      = darkUI ? color.new(color.gray, 55) : color.new(color.gray, 45)

// HELPERS
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_wilson(int w, int n, float z) =>
    if n <= 0
        na
    else
        p = w / n
        (p + z*z/(2*n) - z*math.sqrt(p*(1-p)/n + z*z/(4*n*n))) / (1 + z*z/n) * 100.0
f_stars(float wl, float base, int n) =>
    n < calMinN or na(wl) or na(base) ? "n/a" : wl > base+5 ? "★★★" : wl > base ? "★★" : wl > base-5 ? "★" : "—"
f_firstHit(float up, float lo, int hor) =>
    int fh = 0
    bool done = false
    for i = 0 to hor - 1
        off = hor - 1 - i
        if not done
            hi = high[off]
            ll = low[off]
            bu = hi >= up
            bd = ll <= lo
            if bu and bd
                fh := 2
                done := true
            else if bu
                fh := 1
                done := true
            else if bd
                fh := -1
                done := true
    fh

// ENGINE — three over-extension components
mom1 = ta.rsi(srcPrice, rsiLen)
var float streak = 0.0
chg = srcPrice - srcPrice[1]
streak := chg > 0 ? (nz(streak[1]) > 0 ? nz(streak[1]) + 1 : 1) : chg < 0 ? (nz(streak[1]) < 0 ? nz(streak[1]) - 1 : -1) : 0.0
mom2 = ta.rsi(streak, strkLen)
ret  = srcPrice / srcPrice[1] - 1
rank = 0.0
for i = 1 to rankLen
    rank += (ret > nz(ret[i]) ? 1.0 : 0.0)
pctRank = rank / rankLen * 100.0
comp = (mom1 + mom2 + pctRank) / 3.0
oscC = (comp - 50) * 2

// component agreement — the core thesis made visible: an extreme is only trustworthy when all
// three reads agree. Counts how many of {momentum, streak, return-rank} share the current extreme.
osAgree = (mom1 < osLvl ? 1 : 0) + (mom2 < osLvl ? 1 : 0) + (pctRank < osLvl ? 1 : 0)
obAgree = (mom1 > obLvl ? 1 : 0) + (mom2 > obLvl ? 1 : 0) + (pctRank > obLvl ? 1 : 0)
agreeN  = comp < osLvl ? osAgree : comp > obLvl ? obAgree : 0

// A signal fires on the cross out of the zone, but only ONCE per excursion: after a long
// fires it disarms until the composite recovers to mid (50), so re-entry chatter in the zone
// does not re-fire. Shorts mirror it. Tames the fast oscillator's zone-edge whipsaw.
rawBuy  = ta.crossover(comp, osLvl)
rawSell = ta.crossunder(comp, obLvl)
var bool longArmed  = true
var bool shortArmed = true
buySig  = rawBuy  and longArmed
sellSig = rawSell and shortArmed
longArmed  := buySig  ? false : (comp >= 50 ? true : longArmed)
shortArmed := sellSig ? false : (comp <= 50 ? true : shortArmed)
phaseTxt = comp > obLvl ? "Overbought" : comp < osLvl ? "Oversold" : comp >= 50 ? "Stretched up" : "Stretched down"
wCol = comp >= 50 ? upC : dnC

// CALIBRATION
atrSeries = ta.atr(atrLen)
var int buyN = 0
var int buyW = 0
var int buyNo = 0
var int buyWo = 0
var int sellN = 0
var int sellW = 0
var int sellNo = 0
var int sellWo = 0
var int baseN = 0
var int baseW = 0
var int baseWdn = 0
var int lastBuyBar = -1000000
var int lastSellBar = -1000000

canEval = calOn and barstate.isconfirmed and not na(close[calHor]) and not na(atrSeries[calHor])
if canEval
    entryB = close[calHor]
    aB = atrSeries[calHor]
    fhB = f_firstHit(entryB + barrierK*aB, entryB - barrierK*aB, calHor)
    upOutcome = fhB == 1 or (fhB == 0 and close > entryB)
    dnOutcome = fhB == -1 or (fhB == 0 and close < entryB)
    baseN += 1
    baseW += upOutcome ? 1 : 0
    baseWdn += dnOutcome ? 1 : 0
    if buySig[calHor]
        sigBar = bar_index[calHor]
        okB = (not uniqOn) or (sigBar - lastBuyBar >= calHor)
        if okB
            buyN += 1
            buyW += upOutcome ? 1 : 0
            if sigBar >= last_bar_index - oosBars
                buyNo += 1
                buyWo += upOutcome ? 1 : 0
            lastBuyBar := sigBar
    if sellSig[calHor]
        sigBarS = bar_index[calHor]
        okS = (not uniqOn) or (sigBarS - lastSellBar >= calHor)
        if okS
            sellN += 1
            sellW += dnOutcome ? 1 : 0
            if sigBarS >= last_bar_index - oosBars
                sellNo += 1
                sellWo += dnOutcome ? 1 : 0
            lastSellBar := sigBarS

baseUp  = baseN > 0 ? baseW / baseN * 100.0 : na
baseDn  = baseN > 0 ? baseWdn / baseN * 100.0 : na
buyHit  = buyN  > 0 ? buyW  / buyN  * 100.0 : na
sellHit = sellN > 0 ? sellW / sellN * 100.0 : na
buyHitO = buyNo  > 0 ? buyWo  / buyNo  * 100.0 : na
sellHitO= sellNo > 0 ? sellWo / sellNo * 100.0 : na
buyEdge  = (not na(buyHit)  and not na(baseUp)) ? buyHit  - baseUp : na
sellEdge = (not na(sellHit) and not na(baseDn)) ? sellHit - baseDn : na
buyStars  = f_stars(f_wilson(buyW, buyN, 1.96),  baseUp, buyN)
sellStars = f_stars(f_wilson(sellW, sellN, 1.96), baseDn, sellN)
buySurv  = (buyN  >= calMinN and not na(baseUp)) and (f_wilson(buyW, buyN, 2.24)  > baseUp)
sellSurv = (sellN >= calMinN and not na(baseDn)) and (f_wilson(sellW, sellN, 2.24) > baseDn)

// COST MODEL (Net R on the symmetric 1:1 barrier)
float buyNetR  = na(buyHit)  ? na : (2.0 * buyHit  / 100.0 - 1.0) - costR
float sellNetR = na(sellHit) ? na : (2.0 * sellHit / 100.0 - 1.0) - costR

// VERDICT + CONVICTION
longConv  = buyN  >= calMinN and not na(buyEdge)  and buyEdge  > 0 and buySurv  and not na(buyNetR)  and buyNetR  > 0
shortConv = sellN >= calMinN and not na(sellEdge) and sellEdge > 0 and sellSurv and not na(sellNetR) and sellNetR > 0
verdict = buySig ? "LONG — reversion up" : sellSig ? "SHORT — reversion down" : comp < osLvl ? "WATCH — oversold" : comp > obLvl ? "WATCH — overbought" : "WAIT"
vCol    = buySig ? upC : sellSig ? dnC : (comp < osLvl ? upC : comp > obLvl ? dnC : flatC)
convTxt = (buySig and longConv) or (sellSig and shortConv) ? "High — edge survives test" : (buySig or sellSig) ? "Low — context only" : longConv or shortConv ? "Reversions have edge here" : "No proven edge here"
convCol = ((buySig and longConv) or (sellSig and shortConv)) ? upC : flatC

// PLOTS
obMapped = (obLvl - 50) * 2
osMapped = (osLvl - 50) * 2
pObIn  = plot(obMapped, "OB edge", color.new(dnC, 45), 1)
pObOut = plot(100.0,    "OB cap",  color.new(dnC, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(dnC, 30), color.new(dnC, 95), title = "Overbought zone")
pOsIn  = plot(osMapped, "OS edge", color.new(upC, 45), 1)
pOsOut = plot(-100.0,   "OS cap",  color.new(upC, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(upC, 95), color.new(upC, 30), title = "Oversold zone")
plot(0, "Mid", gridC, 1)
bgcolor(tintBg ? (comp > obLvl ? color.new(dnC, 92) : comp < osLvl ? color.new(upC, 92) : na) : na, title = "Extreme tint")

plot(oscC, "Composite glow", color.new(wCol, 70), 8)
plot(oscC, "Composite", color.new(wCol, 0), 2)

plotshape(buySig  ? osMapped : na, "Buy",  shape.triangleup,   location.absolute, color.new(upC,0), size = size.small)
plotshape(sellSig ? obMapped : na, "Sell", shape.triangledown, location.absolute, color.new(dnC,0), size = size.small)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// DASHBOARD
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 13, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = comp>obLvl?dnC : comp<osLvl?upC : comp>=50?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Composite Reversion", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Composite", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, str.tostring(comp,"#") + "/100" + ((comp < osLvl or comp > obLvl) ? "  " + str.tostring(agreeN) + "/3 agree" : ""), text_color = phCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Mom / Streak / Rank", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(mom1,"#") + " / " + str.tostring(mom2,"#") + " / " + str.tostring(pctRank,"#"), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming up" : "up " + str.tostring(baseUp,"0") + "%  dn " + str.tostring(baseDn,"0") + "%"
        string buyTxt  = buyN  < calMinN ? "warming " + str.tostring(buyN)  : "win " + str.tostring(buyHit,"0")  + "%  edge " + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warming " + str.tostring(sellN) : "win " + str.tostring(sellHit,"0") + "%  edge " + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, r, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, baseTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Long " + buyStars, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Short " + sellStars, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        string netTxt = (na(buyNetR) or na(sellNetR)) ? "warming" : "L " + (buyNetR>=0?"+":"") + str.tostring(buyNetR,"0.00") + " · S " + (sellNetR>=0?"+":"") + str.tostring(sellNetR,"0.00") + " R  (cost " + str.tostring(costR,"0.00") + ")"
        color netCol = (na(buyNetR) or na(sellNetR)) ? flatC : (buyNetR > 0 or sellNetR > 0) ? upC : dnC
        table.cell(st, 0, r, "Net R", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, netTxt, text_color = netCol, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        if not simple
            string buyOTxt = buyNo  < calMinN ? "warming " + str.tostring(buyNo)  : "win " + str.tostring(buyHitO,"0")  + "%  (" + str.tostring(buyNo) + ")"
            string selOTxt = sellNo < calMinN ? "warming " + str.tostring(sellNo) : "win " + str.tostring(sellHitO,"0") + "%  (" + str.tostring(sellNo) + ")"
            table.cell(st, 0, r, "Out-of-sample", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, r, "L " + buyOTxt + " · S " + selOTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            r += 1
            table.cell(st, 0, r, "Multi-test", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(st, 1, r, "long " + (buySurv?"survives":"no") + " · short " + (sellSurv?"survives":"no"), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, "context, not advice", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)

// GENERIC EXPORTS
plot(comp,      "EXP_CompositeRaw", color.new(color.gray,100), display = display.data_window)
plot(mom1,      "EXP_Momentum",    color.new(color.gray,100), display = display.data_window)
plot(mom2,      "EXP_StreakOsc",   color.new(color.gray,100), display = display.data_window)
plot(pctRank,   "EXP_ReturnRank",  color.new(color.gray,100), display = display.data_window)
plot(agreeN,    "EXP_ComponentAgree", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:0,  "EXP_BuySignal",  color.new(color.gray,100), display = display.data_window)
plot(sellSig?1:0, "EXP_SellSignal", color.new(color.gray,100), display = display.data_window)
plot(buySig?1:sellSig?-1:0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_LongEdge",    color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_ShortEdge",   color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_LongNetR",  color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_ShortNetR", color.new(color.gray,100), display = display.data_window)

alertcondition(buySig,  "Long signal",  "Composite Reversion: turn up out of oversold")
alertcondition(sellSig, "Short signal", "Composite Reversion: turn down out of overbought")
alertcondition(ta.crossover(comp, 50),  "Crossed above mid", "Composite Reversion above 50")
alertcondition(ta.crossunder(comp, 50), "Crossed below mid", "Composite Reversion below 50")
````
