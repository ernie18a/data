# Volatility Squeeze Oscillator

- url: https://www.tradingview.com/script/Y1JY6jVH-Volatility-Squeeze-Oscillator/
- type: indicator
- pine_id: PUB;c76028fe3fbd4839a0be4de0de190333
- version: 4.0

## Description

Volatility Squeeze Oscillator

A volatility-regime tool that answers two questions in one pane: is the market coiled (a squeeze — volatility compressed and likely to expand), and when it releases, which way does it go? It measures compression as how low current volatility sits versus its own recent range, reads the release direction from where price sits in the band, and forward-calibrates whether squeeze releases actually pay on the chart you're viewing.

Why these parts are combined (not a mashup for show). A squeeze without a direction is half a tool; a direction without a squeeze is just momentum. Compression uses an exponentially-weighted volatility estimate (more weight on recent moves, so it reacts faster than a simple average) ranked against its own recent history — when it sits in the low percentile, volatility is unusually compressed. A relative test like this stays genuinely intermittent on any instrument; an absolute band-vs-band test drifts to "always on" or "never on" depending on the symbol. Release direction comes from a smoothed read of where price sits within an EWMA band. And forward calibration measures whether releases in each direction actually followed through on this symbol.

How it works. An EWMA volatility estimate is ranked against its own recent history; Squeeze ON = that rank is in the low percentile. The histogram is a smoothed read of where price sits inside an EWMA band (its sign = likely release direction). A signal fires when a squeeze releases in the histogram's direction. Each signal is labelled by a triple barrier — a profit target and equal stop in ATR units plus a time limit — split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict (Squeeze ON / Long release / Short release / Wait) and the Conviction, which reads "High" only when releases in that direction survive the test here — otherwise it openly says so. Histogram above zero = upward pressure inside the band; gold dots on the zero line mark squeeze-ON bars. Non-repainting. Best used with your own entry and risk plan, not alone.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// VOLATILITY SQUEEZE OSCILLATOR — Compression State, Release Direction & Forward-Calibrated    v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — House-standard pass (no engine change):
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model (Net R): conviction now requires a squeeze-release edge that also survives costs.
//        • No correctness fix needed — this script had no conditional-ta.* issue; the squeeze
//          detection, the release-direction logic and the forward calibration are unchanged.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A volatility-regime tool that answers two questions in one pane: is the market COILED (a
//   squeeze — volatility compressed and likely to expand), and when it releases, which WAY does it
//   go? It measures compression as how LOW current volatility sits versus its own recent range,
//   reads the release direction from where price sits in the band, and forward-calibrates whether
//   squeeze releases actually pay on the chart you are viewing — in plain language.
//
// WHY THESE PARTS ARE COMBINED (read this if you think it is a mashup)
//   A squeeze without a direction is half a tool; a direction without a squeeze is just momentum.
//     • Compression: an exponentially-weighted volatility estimate (more weight on recent moves,
//       so it reacts faster than a simple average) is ranked against its own recent history. When
//       it sits in the low percentile of that range, volatility is unusually compressed — a squeeze.
//       A relative test stays intermittent on any instrument; an absolute band-vs-band test drifts.
//     • Release direction: a momentum read of where price sits within the band gives the likely
//       break direction the moment compression ends.
//     • Forward calibration: instead of assuming every squeeze release is tradeable, it measures
//       whether releases in each direction actually followed through on THIS symbol.
//   The compression gauge, the direction read and the calibration form one coherent squeeze tool —
//   none alone is sufficient.
//
// HOW IT WORKS
//   An EWMA volatility estimate (recency-weighted deviation of returns) is ranked against its own
//   recent history; Squeeze ON = that rank is in the low percentile (volatility compressed). The
//   histogram is a smoothed read of where price sits inside an EWMA band (its sign = likely release
//   direction). A signal fires when a squeeze RELEASES (turns off) in the histogram's direction.
//   Each signal is labelled by a TRIPLE BARRIER (profit target + equal stop in ATR units, plus a
//   time limit), split into in-sample and recent out-of-sample, with a confidence interval and a
//   multiple-testing check.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row: Squeeze ON = coiled, wait for release; Long/Short release = a squeeze
//     just released in that direction; Wait = no squeeze.
//   • The CONVICTION row says whether releases in that direction have a positive, statistically-
//     surviving edge on THIS chart. Low conviction = treat as context only.
//   • Histogram above zero = upward pressure inside the band; below = downward. Dots on the zero
//     line mark squeeze-ON bars. Best used with your own entry and risk plan, not alone.
//
// NON-REPAINT  Reads confirmed closes; calibration logs and resolves only on barstate.isconfirmed.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: a relative volatility-compression
//   test (the classic squeeze idea, measured here as a low-percentile of recent volatility);
//   exponentially-weighted volatility estimation; band-position momentum for release direction;
//   triple-barrier outcome labelling from standard supervised-labelling practice in quantitative finance; the Wilson score interval for the
//   proportion bound; and the Bonferroni adjustment for multiple testing. Credit is due to the
//   originators of each technique. This is an original implementation combining them into one
//   forward-calibrated squeeze tool.
//
// DISCLAIMER  For research and education only. Edge figures are computed on this chart's own
//   history with overlapping windows and no costs — context, not a guaranteed backtest, and past
//   behaviour does not predict the future. Nothing here is financial advice. Trading carries risk
//   of loss; size and manage your own positions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Volatility Squeeze Oscillator", "Vol Sqz", overlay = false)

// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the source to use any market)
gMain    = "1 · General"
srcPrice = input.source(close, "Price source", group = gMain, tooltip = "Change for any symbol/market — this script is asset-agnostic.")
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gEng     = "2 · Squeeze engine"
basisLen = input.int(20, "Band length", minval = 2, maxval = 200, group = gEng)
ewmaLam  = input.float(0.94, "EWMA decay", minval = 0.80, maxval = 0.99, step = 0.01, group = gEng, tooltip = "Recency weight for the volatility estimate. Higher = smoother / slower.")
sqzLook  = input.int(100, "Squeeze lookback", minval = 20, maxval = 500, group = gEng, tooltip = "Window over which current volatility is ranked to detect compression.")
sqzPctl  = input.float(25, "Squeeze percentile (lower = rarer)", minval = 5, maxval = 50, step = 1, group = gEng, tooltip = "Squeeze is ON when EWMA volatility sits in the bottom this-percent of its recent range.")
volK     = input.float(2.0, "Direction band width", minval = 0.5, maxval = 5.0, step = 0.1, group = gEng, tooltip = "Width of the band used to read where price sits, for the release-direction histogram.")
momLen   = input.int(12, "Direction smoothing", minval = 1, maxval = 50, group = gEng)

gCal     = "3 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score squeeze releases forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(12, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A release wins if price reaches the target (this many ATRs) before the equal-sized stop, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal)
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal)
calMinN  = input.int(15, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")

gUI      = "4 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto adapts table, text and line colors to the chart background.")
tintBg   = input.bool(true, "Tint pane during squeeze", group = gUI)
colUp    = input.color(#2ebd85, "Up color",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Down color", inline = "c", group = gUI)
colSqz   = input.color(#f0b90b, "Squeeze", group = gUI)

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
sqzC       = colSqz
flatC      = darkUI ? color.rgb(120,130,140) : color.rgb(122,130,139)
gridC      = darkUI ? color.new(color.gray, 55) : color.new(color.gray, 45)

// HELPERS
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, float k) => 100.0 * f_tanh(x / math.max(k, 0.0001))
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

// ENGINE
basis = ta.sma(srcPrice, basisLen)
ret   = srcPrice - srcPrice[1]
var float ewVar = na
ewVar := na(ewVar[1]) ? ret*ret : ewmaLam*nz(ewVar[1]) + (1-ewmaLam)*ret*ret
ewDev = math.sqrt(math.max(ewVar, 0.0))
// Squeeze = EWMA volatility sitting in the LOW percentile of its own recent history. A relative-
// compression test stays genuinely intermittent on any instrument with no per-symbol scale
// tuning — an absolute band-vs-band test drifts to "always on" or "never on" by instrument.
volRank   = ta.percentrank(ewDev, sqzLook)
squeezeOn = not na(volRank) and volRank <= sqzPctl
squeezeOff = not squeezeOn and squeezeOn[1]
// squeeze age = consecutive bars coiled (a longer, deeper coil is the notable setup)
var int sqzAge = 0
sqzAge := squeezeOn ? sqzAge + 1 : 0

// direction histogram: where price sits within an EWMA band, smoothed and bounded
bandHalf = math.max(volK * ewDev, syminfo.mintick)
posIn = (srcPrice - basis) / bandHalf
hist  = f_squash(ta.linreg(posIn, momLen, 0) * 1.5, 1.0)
hCol  = hist >= 0 ? upC : dnC

buySig  = squeezeOff and hist > 0
sellSig = squeezeOff and hist < 0
phaseTxt = squeezeOn ? "Squeeze ON" : hist >= 0 ? "Expansion up" : "Expansion down"

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
verdict = squeezeOn ? "SQUEEZE ON — coiled" : buySig ? "LONG — released up" : sellSig ? "SHORT — released down" : "WAIT"
vCol    = squeezeOn ? sqzC : buySig ? upC : sellSig ? dnC : flatC
convTxt = (buySig and longConv) or (sellSig and shortConv) ? "High — edge survives test" : (buySig or sellSig) ? "Low — context only" : longConv or shortConv ? "Releases have edge here" : "No proven edge here"
convCol = ((buySig and longConv) or (sellSig and shortConv)) ? upC : flatC

// PLOTS
plot(0, "Zero", gridC, 1)
bgcolor(tintBg and squeezeOn ? color.new(sqzC, 90) : na, title = "Squeeze tint")
plot(hist, "Direction glow", color.new(hCol, 70), 8)
plot(hist, "Direction", color.new(hCol, 0), 2)
plotshape(squeezeOn ? 0 : na, "Squeeze dot", shape.circle, location.absolute, color.new(sqzC,0), size = size.tiny)

plotshape(buySig  ? hist : na, "Buy",  shape.triangleup,   location.absolute, color.new(upC,0), size = size.small)
plotshape(sellSig ? hist : na, "Sell", shape.triangledown, location.absolute, color.new(dnC,0), size = size.small)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// DASHBOARD
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 13, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = squeezeOn ? sqzC : hist>=0?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Volatility Squeeze", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "State", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, squeezeOn ? "coiled " + str.tostring(sqzAge) + "b · p" + str.tostring(nz(volRank), "0") : "expanding", text_color = squeezeOn?sqzC:txtMain, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Direction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(hist,"#") + (hist>=0?" ▲":" ▼"), text_color = phCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming up" : "up " + str.tostring(baseUp,"0") + "%  dn " + str.tostring(baseDn,"0") + "%"
        string buyTxt  = buyN  < calMinN ? "warming " + str.tostring(buyN)  : "win " + str.tostring(buyHit,"0")  + "%  edge " + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warming " + str.tostring(sellN) : "win " + str.tostring(sellHit,"0") + "%  edge " + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, r, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, baseTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Up-rel " + buyStars, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Dn-rel " + sellStars, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        string netTxt = (na(buyNetR) or na(sellNetR)) ? "warming" : "U " + (buyNetR>=0?"+":"") + str.tostring(buyNetR,"0.00") + " · D " + (sellNetR>=0?"+":"") + str.tostring(sellNetR,"0.00") + " R  (cost " + str.tostring(costR,"0.00") + ")"
        color netCol = (na(buyNetR) or na(sellNetR)) ? flatC : (buyNetR > 0 or sellNetR > 0) ? upC : dnC
        table.cell(st, 0, r, "Net R", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, netTxt, text_color = netCol, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        if not simple
            string buyOTxt = buyNo  < calMinN ? "warming " + str.tostring(buyNo)  : "win " + str.tostring(buyHitO,"0")  + "%  (" + str.tostring(buyNo) + ")"
            string selOTxt = sellNo < calMinN ? "warming " + str.tostring(sellNo) : "win " + str.tostring(sellHitO,"0") + "%  (" + str.tostring(sellNo) + ")"
            table.cell(st, 0, r, "Out-of-sample", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, r, "U " + buyOTxt + " · D " + selOTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            r += 1
            table.cell(st, 0, r, "Multi-test", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(st, 1, r, "up " + (buySurv?"survives":"no") + " · dn " + (sellSurv?"survives":"no"), text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, "context, not advice", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)

// GENERIC EXPORTS
plot(hist,      "EXP_DirectionValue", color.new(color.gray,100), display = display.data_window)
plot(squeezeOn?1:0, "EXP_SqueezeOn",   color.new(color.gray,100), display = display.data_window)
plot(sqzAge,        "EXP_SqueezeAge",  color.new(color.gray,100), display = display.data_window)
plot(ewDev,     "EXP_EwmaDev",     color.new(color.gray,100), display = display.data_window)
plot(buySig?1:0,  "EXP_UpRelease",  color.new(color.gray,100), display = display.data_window)
plot(sellSig?1:0, "EXP_DnRelease",  color.new(color.gray,100), display = display.data_window)
plot(buySig?1:sellSig?-1:0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_UpEdge",      color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_DnEdge",      color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_UpNetR", color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_DnNetR", color.new(color.gray,100), display = display.data_window)

alertcondition(buySig,  "Up release",   "Volatility Squeeze: released upward")
alertcondition(sellSig, "Down release", "Volatility Squeeze: released downward")
alertcondition(squeezeOn and not squeezeOn[1], "Squeeze on",  "Volatility Squeeze: entered squeeze")
alertcondition(squeezeOff, "Squeeze off", "Volatility Squeeze: squeeze released")
````
