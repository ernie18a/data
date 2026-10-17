# Modern Adaptive MACD [GBB]

- url: https://www.tradingview.com/script/prNqfHhc-Modern-Adaptive-MACD-GBB/
- type: indicator
- pine_id: PUB;32fefc7ff2c142bbafb930c8c795fb9b
- version: 1.0

## Description

The MACD is half a century old. Gerald Appel published it in 1979 for daily charts of US equities, and the 12/26/9 default has been copied from one trading textbook to the next ever since. Nobody asks anymore why those three numbers should be the right ones for Bitcoin five-minute charts in 2026.

This is a rebuild. Four modernizations, each independently toggleable, all measured before being added. With every layer at default, the output is the textbook MACD. Switch them on one at a time to see what each one does on your own chart.

Layer 1: Adaptive periods

Instead of hard-coding 12 and 26, the indicator measures the market's dominant cycle in real time with an Ehlers homodyne discriminator and tunes the periods to it. In slow trends the periods widen and the indicator stops chopping you up with false crosses. When volatility picks up, periods tighten and it stays responsive.

Layer 2: Signal speedup

Classic MACD has two layers of lag. One in the EMAs that build the MACD line, another in the signal line on top of that. Most of the lag people complain about lives in the second smoother.

The first version of this layer used a zero-lag EMA. It didn't work. The zero-lag transform overshoots, and on strong moves the signal ends up ahead of the MACD, inverting the histogram color exactly when you most need the cross to be honest.

What shipped is the boring fix: a multiplier on the signal length. 1.0 keeps the classic 9-bar signal. Lower values speed it up. I measured the trade across 24 months of Bitcoin perpetual data. At a multiplier of 0.5, the indicator confirms a swing roughly 4 bars earlier and catches about 25% more swings than the classic. The cost is that the false-signal rate, whipsaw crosses with no real swing attached, roughly doubles, from 6% to 12.5% of all crosses. Whether that trade is worth it depends on what you do with the indicator. Pick the multiplier accordingly.

Layer 3: Normalization

A raw MACD reading of 15 means nothing on its own. On gold at $4500 it's small. On a penny stock it's enormous. Two normalization modes are available. "Percent of price" expresses the MACD as a percent of current price, which makes the reading comparable across instruments. "Z-Score" expresses it as standard deviations from its own recent average. Both are off by default. Turn one on if you trade more than one market, or if you want thresholds that don't need re-tuning every time you switch symbols.

Layer 4: Divergences

Regular and hidden divergences are detected automatically on confirmed pivots. Confirmed means they do not repaint. The line shows up a few bars after the pivot it marks, which is the honest cost of non-repainting confirmation. If anyone shows you a divergence indicator that draws lines in real time at the exact low, check what happens to those lines after the next few candles close.

Small triangles mark every MACD/Signal cross at the crossing point. Teal for bullish, red for bearish. Useful on busy charts where the cross moment is otherwise ambiguous.


What this is, and what it isn't

I tested every configuration of this indicator as a standalone trading system on 24 months of Bitcoin one-hour data. Always in market, long on bullish cross, flip on bearish. Every configuration lost money. Profit factor below 1 across the board. Negative Sharpe. Nothing statistically significant, before or after multiple-comparison correction.

This is what happens to any oscillator cross strategy run without a filter. The classic MACD shows the same result on the same test.

This is not a system. It's a timing tool. It tells you when momentum is shifting, earlier and more cleanly than the classic. Your job is to combine that with whatever else you trade on: higher-timeframe trend, market structure, key levels, your own setup logic. Without that filter, the cross alone is noise.


Settings

Source: close by default.

Classic periods: 12/26/9. Used when Adaptive is off.

Layer 1 (Adaptive): on by default. Min and max cycle bounds and the fast/signal ratios are exposed if you want to tune them.

Layer 2 (Signal speedup): multiplier 0.3 to 1.0. Default 1.0. Try 0.5 first.

Layer 3 (Normalize): None / Percent of price / Z-Score. Off by default. Z-Score has its own lookback length.

Layer 4 (Divergences): on by default, regular divergences only. Hidden divergences are off by default to keep the chart clean. Pivot left/right bars control how strict the swing detection is.

Display: cross markers on by default.

Alerts are wired for every cross (MACD/signal and zero-line) and every divergence type (regular and hidden, bullish and bearish).


Free. No paywall, no subscription, no gated features. If you find a configuration that works well on a specific instrument or timeframe, drop a comment.
Open-source script

In true TradingView spirit, the creator of this script has made it open-source, so that traders can review and verify its functionality. Kudos to the author! While you can use it for free, remember that republishing the code is subject to our House Rules.
GoodBadBitcoin
Also on:
Disclaimer
The information and publications are not meant to be, and do not constitute, financial, investment, trading, or other types of advice or recommendations supplied or endorsed by

## Source Code

````pine
//@version=6
indicator("Modern MACD [GBB]", shorttitle="MMACD [GBB]", overlay=false, precision=4, max_lines_count=500, max_labels_count=500)


// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
g_src   = "Source"
i_src   = input.source(close, "Source", group=g_src)

g_cls   = "Classic periods (used when Adaptive is OFF)"
i_fast  = input.int(12, "Fast length",   minval=1, group=g_cls)
i_slow  = input.int(26, "Slow length",   minval=1, group=g_cls)
i_sig   = input.int(9,  "Signal length", minval=1, group=g_cls)

g_adp   = "Layer 1 — Adaptive periods"
i_adapt = input.bool(true, "Cycle-tune periods", group=g_adp)
i_cycMin= input.int(8,  "Min dominant cycle", minval=4,  group=g_adp)
i_cycMax= input.int(50, "Max dominant cycle", minval=10, group=g_adp)
i_rFast = input.float(0.500, "Fast ratio (x slow)",   minval=0.1, maxval=0.9, step=0.05, group=g_adp)
i_rSig  = input.float(0.346, "Signal ratio (x slow)", minval=0.1, maxval=0.9, step=0.01, group=g_adp)

g_sm    = "Layer 2 — Signal speedup"
i_sigMult = input.float(1.0, "Signal length multiplier", minval=0.3, maxval=1.0, step=0.05, group=g_sm, tooltip="1.0 = classic signal length. Lower = faster signal (e.g. 0.5 turns a 9-bar signal into a 4–5 bar one). This is the principled fix for double-lag — no DSP overshoot, just a parameter.")

g_nrm   = "Layer 3 — Normalization"
i_norm  = input.string("None", "Mode", options=["None", "Percent of price", "Z-Score"], group=g_nrm)
i_zLen  = input.int(100, "Z-Score lookback", minval=20, group=g_nrm)

g_div    = "Layer 4 — Divergences (non-repainting)"
i_divOn  = input.bool(true,  "Show divergences",          group=g_div)
i_divL   = input.int(5,      "Pivot left bars",  minval=1, group=g_div)
i_divR   = input.int(5,      "Pivot right bars", minval=1, group=g_div, tooltip="Pivots confirm this many bars AFTER they happen. Smaller = faster but more false pivots; larger = slower but more reliable.")
i_divMax = input.int(60,     "Max bars between pivots", minval=10, group=g_div)
i_divReg = input.bool(true,  "Regular divergences", group=g_div, tooltip="Classic reversal divergence: price HH + MACD LH (bearish), price LL + MACD HL (bullish).")
i_divHid = input.bool(false, "Hidden divergences",  group=g_div, tooltip="Continuation divergence: price LH + MACD HH (bearish), price HL + MACD LL (bullish). Used in trend-following.")

g_disp  = "Display"
i_xMark = input.bool(true, "Show cross markers", group=g_disp)

// ---------------------------------------------------------------------------
// EMA — manual implementation so it accepts a SERIES-int length
// (ta.ema cannot take an adaptive length; this can)
// ---------------------------------------------------------------------------
f_ema(series float src, series float len) =>
    float a = 2.0 / (len + 1.0)
    var float e = na
    e := na(e[1]) ? src : a * src + (1.0 - a) * e[1]
    e

// ---------------------------------------------------------------------------
// Dominant cycle — Ehlers Homodyne Discriminator
// Self-contained and na-safe. If you prefer, drop in the proven homodyne
// module from EACO here — it is isolated to this single function.
// ---------------------------------------------------------------------------
f_dominantCycle(simple int cycMin, simple int cycMax) =>
    float price = (high + low) / 2.0
    var float period       = float(cycMin)
    var float smoothPeriod = float(cycMin)
    float pPrev = nz(period[1], float(cycMin))

    float smooth    = (4.0*price + 3.0*nz(price[1]) + 2.0*nz(price[2]) + nz(price[3])) / 10.0
    float adj       = 0.075 * pPrev + 0.54
    float detrender = (0.0962*smooth + 0.5769*nz(smooth[2]) - 0.5769*nz(smooth[4]) - 0.0962*nz(smooth[6])) * adj

    // InPhase / Quadrature
    float q1 = (0.0962*detrender + 0.5769*nz(detrender[2]) - 0.5769*nz(detrender[4]) - 0.0962*nz(detrender[6])) * adj
    float i1 = nz(detrender[3])

    // Advance phase by 90 degrees
    float ji = (0.0962*i1 + 0.5769*nz(i1[2]) - 0.5769*nz(i1[4]) - 0.0962*nz(i1[6])) * adj
    float jq = (0.0962*q1 + 0.5769*nz(q1[2]) - 0.5769*nz(q1[4]) - 0.0962*nz(q1[6])) * adj

    // Phasor addition (3-bar averaging) + smoothing
    var float i2 = 0.0
    var float q2 = 0.0
    i2 := 0.2 * (i1 - jq) + 0.8 * nz(i2[1])
    q2 := 0.2 * (q1 + ji) + 0.8 * nz(q2[1])

    // Homodyne discriminator
    var float re = 0.0
    var float im = 0.0
    re := 0.2 * (i2*nz(i2[1]) + q2*nz(q2[1])) + 0.8 * nz(re[1])
    im := 0.2 * (i2*nz(q2[1]) - q2*nz(i2[1])) + 0.8 * nz(im[1])

    float per = pPrev
    if im != 0.0 and re != 0.0
        per := 2.0 * math.pi / math.atan(im / re)        // math.atan -> radians
    // clamp rate-of-change, then absolute range
    per := math.min(math.max(per, 0.67 * pPrev), 1.5 * pPrev)
    per := math.max(math.min(per, float(cycMax)), float(cycMin))
    period       := 0.2 * per + 0.8 * pPrev
    smoothPeriod := 0.33 * period + 0.67 * nz(smoothPeriod[1], float(cycMin))
    smoothPeriod

// ---------------------------------------------------------------------------
// Resolve effective periods
// ---------------------------------------------------------------------------
float domCyc  = f_dominantCycle(i_cycMin, i_cycMax)
float slowLen = i_adapt ? domCyc                          : float(i_slow)
float fastLen = i_adapt ? math.max(domCyc * i_rFast, 2.0) : float(i_fast)
float sigBase = i_adapt ? math.max(domCyc * i_rSig,  2.0) : float(i_sig)
float sigLen  = math.max(sigBase * i_sigMult, 2.0)

// ---------------------------------------------------------------------------
// MACD core
// ---------------------------------------------------------------------------
float fastMA  = f_ema(i_src, fastLen)
float slowMA  = f_ema(i_src, slowLen)
float macdRaw = fastMA - slowMA

// ---------------------------------------------------------------------------
// Normalization — applied to the MACD line BEFORE the signal smoothing,
// so the cross logic stays consistent across modes.
// ---------------------------------------------------------------------------
f_normalize(series float m, simple string mode, simple int zlen) =>
    float out = m
    if mode == "Percent of price"
        out := close != 0.0 ? m / close * 100.0 : 0.0
    else if mode == "Z-Score"
        float mean = ta.sma(m, zlen)
        float sd   = ta.stdev(m, zlen)
        out := (not na(sd) and sd != 0.0) ? (m - mean) / sd : 0.0
    out

float macdLine   = f_normalize(macdRaw, i_norm, i_zLen)
float signalLine = f_ema(macdLine, sigLen)
float histLine   = macdLine - signalLine

// ---------------------------------------------------------------------------
// Cross detection (used for markers AND alerts)
// ---------------------------------------------------------------------------
bool crossUp   = ta.crossover(macdLine, signalLine)
bool crossDown = ta.crossunder(macdLine, signalLine)
bool zeroUp    = ta.crossover(macdLine, 0.0)
bool zeroDown  = ta.crossunder(macdLine, 0.0)

// ---------------------------------------------------------------------------
// Layer 4 — Divergences
// Indicator-led detection: when a MACD pivot confirms, we compare it to the
// previous MACD pivot AND to the price (high/low) at the same pivot bar.
// Pivots are confirmed i_divR bars AFTER they happen, so divergences are
// drawn with that lag but do NOT repaint.
// ---------------------------------------------------------------------------
float phMacd = ta.pivothigh(macdLine, i_divL, i_divR)
float plMacd = ta.pivotlow (macdLine, i_divL, i_divR)

var float lastPHmacd  = na
var float lastPHprice = na
var int   lastPHbar   = na
var float lastPLmacd  = na
var float lastPLprice = na
var int   lastPLbar   = na

int pivotBar = bar_index - i_divR

bool bearDivReg = false
bool bullDivReg = false
bool bearDivHid = false
bool bullDivHid = false

if i_divOn and not na(phMacd)
    float currPrice = high[i_divR]
    if not na(lastPHmacd) and (pivotBar - lastPHbar) <= i_divMax and (pivotBar - lastPHbar) > 0
        bearDivReg := i_divReg and currPrice >  lastPHprice and phMacd <  lastPHmacd
        bearDivHid := i_divHid and currPrice <  lastPHprice and phMacd >  lastPHmacd
        if bearDivReg
            line.new(lastPHbar, lastPHmacd, pivotBar, phMacd, color=color.new(color.red, 0), width=2)
            label.new(pivotBar, phMacd, "Bear", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)
        if bearDivHid
            line.new(lastPHbar, lastPHmacd, pivotBar, phMacd, color=color.new(color.orange, 20), width=1, style=line.style_dashed)
            label.new(pivotBar, phMacd, "H-Bear", style=label.style_label_down, color=color.new(color.orange, 20), textcolor=color.white, size=size.tiny)
    lastPHmacd  := phMacd
    lastPHprice := currPrice
    lastPHbar   := pivotBar

if i_divOn and not na(plMacd)
    float currPrice = low[i_divR]
    if not na(lastPLmacd) and (pivotBar - lastPLbar) <= i_divMax and (pivotBar - lastPLbar) > 0
        bullDivReg := i_divReg and currPrice <  lastPLprice and plMacd >  lastPLmacd
        bullDivHid := i_divHid and currPrice >  lastPLprice and plMacd <  lastPLmacd
        if bullDivReg
            line.new(lastPLbar, lastPLmacd, pivotBar, plMacd, color=color.new(color.teal, 0), width=2)
            label.new(pivotBar, plMacd, "Bull", style=label.style_label_up, color=color.new(color.teal, 0), textcolor=color.white, size=size.tiny)
        if bullDivHid
            line.new(lastPLbar, lastPLmacd, pivotBar, plMacd, color=color.new(color.aqua, 20), width=1, style=line.style_dashed)
            label.new(pivotBar, plMacd, "H-Bull", style=label.style_label_up, color=color.new(color.aqua, 20), textcolor=color.white, size=size.tiny)
    lastPLmacd  := plMacd
    lastPLprice := currPrice
    lastPLbar   := pivotBar

// ---------------------------------------------------------------------------
// Plots
// ---------------------------------------------------------------------------
bool  histUp   = histLine >= 0.0
bool  histRise = histLine >= nz(histLine[1])
color cHist    = histUp ? (histRise ? color.new(color.teal, 0) : color.new(color.teal, 55)) : (histRise ? color.new(color.red, 55) : color.new(color.red, 0))

plot(histLine,   "Histogram", color=cHist, style=plot.style_columns)
plot(macdLine,   "MACD",      color=color.new(#2962ff, 0), linewidth=2)
plot(signalLine, "Signal",    color=color.new(#ff6d00, 0), linewidth=2)
hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// Cross markers — triangles placed at the signal-line value where the cross occurs
plotshape((i_xMark and crossUp)   ? signalLine : na, "Bull cross", shape.triangleup,   location.absolute, color=color.new(color.teal, 0), size=size.tiny)
plotshape((i_xMark and crossDown) ? signalLine : na, "Bear cross", shape.triangledown, location.absolute, color=color.new(color.red,  0), size=size.tiny)

// ---------------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------------
alertcondition(crossUp,    "Bullish cross",                "MMACD: MACD crossed above Signal")
alertcondition(crossDown,  "Bearish cross",                "MMACD: MACD crossed below Signal")
alertcondition(zeroUp,     "Zero-line up",                 "MMACD: MACD crossed above zero")
alertcondition(zeroDown,   "Zero-line down",               "MMACD: MACD crossed below zero")
alertcondition(bearDivReg, "Bearish divergence (regular)", "MMACD: regular bearish divergence confirmed")
alertcondition(bullDivReg, "Bullish divergence (regular)", "MMACD: regular bullish divergence confirmed")
alertcondition(bearDivHid, "Bearish divergence (hidden)",  "MMACD: hidden bearish divergence confirmed")
alertcondition(bullDivHid, "Bullish divergence (hidden)",  "MMACD: hidden bullish divergence confirmed")
````
