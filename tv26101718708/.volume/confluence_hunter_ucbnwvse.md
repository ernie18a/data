# Confluence Hunter

- url: https://www.tradingview.com/script/uCbNwVse-Confluence-Hunter/
- type: indicator
- pine_id: PUB;5ac4523bfcde444b869aeeb053fe5b9b
- version: 1.0

## Description

Confluence Hunter is a multi-factor confluence engine that fuses six independent dimensions of market behavior into one signal. Instead of firing on a single condition (a moving average cross, an RSI level), it only triggers when at least 4 of 6 factors agree on the same bar — dramatically cutting false signals.

THE SIX FACTORS

1. EMA STACK (Trend) — 9 / 21 / 50 / 200 EMAs. Stacked up = uptrend; stacked down = downtrend; mixed = chop, stay out.

2. SESSION VWAP (Fair Value) — Volume-weighted average price anchored to the daily session, with a configurable ±σ band. Price above VWAP = bulls in control.

3. LIQUIDITY SWEEPS (Structure) — Detects stop hunts: bars that pierce a recent swing high/low and snap back with a strong rejection wick (≥40% of range by default). These are the highest-edge structural events on the chart and act as the trigger.

4. ORDER FLOW DELTA (Intent) — Bar-by-bar buy/sell pressure derived from close position within range × volume, smoothed with an EMA. Strong-delta bars are highlighted with circle markers below/above.

5. SESSION VOLUME PROFILE (Acceptance) — Plots POC, VAH, and VAL for the active session using a configurable bin count (default 40 rows) and Value Area % (default 70%). Trading above POC with the trend = strong continuation; below POC against the trend = caution.

6. RSI(14) (Momentum) — Tiebreaker confirming momentum supports the bias.

CONFLUENCE SCORING
Each factor returns +1 (bullish), 0 (neutral), or −1 (bearish). The dashboard in the top-right shows the live status of each. A green BUY label fires only when bullish count ≥ 4 AND bearish count ≤ 1 (defaults). The same logic mirrors for SELL labels.

HOW TO USE FOR STOCK SELECTION

Step 1 — Filter by regime: throw it on the daily chart of every name in your watchlist. Skip anything with a MIXED EMA stack or trading on the wrong side of the 200 EMA.

Step 2 — Rank by Net Score: cycle the survivors and rank by the dashboard's Net Score (bullCount − bearCount, max ±6). +5 or +6 = A-tier setup.

Step 3 — Wait for a structural trigger: don't enter at +6 alone (you're late). Wait for either a fresh BUY/SELL label or a sweep arrow near a key level (VWAP, POC, or VAL).

Step 4 — Confirm on lower timeframe: drop to 1H/15m and require the same bullish/bearish state. Multi-timeframe alignment cuts losers significantly.

ENTRY / STOP / TARGET FRAMEWORK
- Entry: close of the BUY/SELL bar, or pullback to VWAP / 9-21 EMA on the next bar.
- Stop: just beyond the wick of the sweep bar.
- Target 1: opposite VWAP band (take 50% off).
- Target 2: prior session POC or next swing high; trail rest with 21 EMA.

INPUTS
All factors are tunable: swing lookback, sweep strictness (wick ratio), VWAP band width, volume profile rows and value area %, EMA lengths, and minimum confluence threshold (default 4 of 6 — raise to 5 for fewer/cleaner signals, lower to 3 for more visual analysis).

ALERTS
Built-in alerts for: Confluence BUY, Confluence SELL, Bullish Liquidity Sweep, Bearish Liquidity Sweep.

LIMITATIONS
- The order-flow delta is a proxy from close-position-in-range × volume. Pine Script does not have access to real exchange tick/footprint data. It is directionally useful but not equivalent to true CVD.
- Volume Profile is session-anchored (resets daily), not visible-range. For multi-day profiles, layer TradingView's built-in Volume Profile Visible Range on top.
- For Forex (where volume is tick-based, not real volume) the OF and VP factors are weaker — lean more on EMAs + VWAP + sweeps.

Works on any market: equities, futures, commodities, crypto, forex. Best on 1H, 4H, and Daily timeframes.

This script is free and open-source. Feedback and forks welcome.

## Source Code

````pine
//@version=6
// =============================================================
// Confluence Hunter
// Multi-factor confluence engine: Liquidity Sweeps + Order Flow
// + VWAP + Volume Profile + EMA Stack + Momentum
// =============================================================
indicator("Confluence Hunter", shorttitle="ConfHunter", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ===== INPUTS =====
g_ls      = "Liquidity Sweeps"
swingLen  = input.int(10, "Swing lookback", minval=2, group=g_ls)
sweepWick = input.float(0.40, "Min wick ratio", minval=0.1, maxval=0.9, step=0.05, group=g_ls)
showSweep = input.bool(true, "Show sweep markers", group=g_ls)

g_of      = "Order Flow"
ofLen     = input.int(14, "Delta EMA length", minval=2, group=g_of)

g_vw      = "VWAP"
showVWAP  = input.bool(true, "Show VWAP", group=g_vw)
vwapBand  = input.float(1.0, "VWAP std-dev band", minval=0.0, step=0.25, group=g_vw)

g_vp      = "Volume Profile"
vpRows    = input.int(40, "VP rows", minval=10, maxval=120, group=g_vp)
vpVA      = input.float(70.0, "Value Area %", minval=50, maxval=95, step=1, group=g_vp)
showVP    = input.bool(true, "Show POC/VAH/VAL", group=g_vp)

g_em      = "EMA Stack"
ema1Len   = input.int(9,   "EMA 1", group=g_em)
ema2Len   = input.int(21,  "EMA 2", group=g_em)
ema3Len   = input.int(50,  "EMA 3", group=g_em)
ema4Len   = input.int(200, "EMA 4", group=g_em)

g_sig     = "Signals"
minScore  = input.int(4, "Min confluence (out of 6)", minval=2, maxval=6, group=g_sig)
showTbl   = input.bool(true, "Show dashboard", group=g_sig)

// ===== EMA STACK =====
ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)
ema4 = ta.ema(close, ema4Len)
bullStack = ema1 > ema2 and ema2 > ema3 and ema3 > ema4
bearStack = ema1 < ema2 and ema2 < ema3 and ema3 < ema4
trendScore = bullStack ? 1 : bearStack ? -1 : 0

plot(ema1, "EMA1", color=color.new(color.yellow, 0))
plot(ema2, "EMA2", color=color.new(color.orange, 0))
plot(ema3, "EMA3", color=color.new(color.red, 0), linewidth=2)
plot(ema4, "EMA4", color=color.new(color.maroon, 0), linewidth=2)

// ===== VWAP =====
newSession = ta.change(time("D")) != 0
var float pvSum = 0.0
var float vSum  = 0.0
var float v2Sum = 0.0
if newSession
    pvSum := 0.0
    vSum  := 0.0
    v2Sum := 0.0
src   = hlc3
pvSum := pvSum + src * volume
vSum  := vSum  + volume
v2Sum := v2Sum + src * src * volume
vwap_ = vSum > 0 ? pvSum / vSum : na
sd    = vSum > 0 ? math.sqrt(math.max(v2Sum / vSum - vwap_ * vwap_, 0)) : 0.0
vwUp  = vwap_ + vwapBand * sd
vwDn  = vwap_ - vwapBand * sd

plot(showVWAP ? vwap_ : na, "VWAP", color=color.new(color.aqua, 0), linewidth=2)
plot(showVWAP ? vwUp  : na, "VWAP+sd", color=color.new(color.aqua, 70))
plot(showVWAP ? vwDn  : na, "VWAP-sd", color=color.new(color.aqua, 70))
vwapScore = close > vwap_ ? 1 : close < vwap_ ? -1 : 0

// ===== LIQUIDITY SWEEPS =====
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

rng    = high - low
upperW = high - math.max(open, close)
lowerW = math.min(open, close) - low
upWick = rng > 0 ? upperW / rng : 0.0
loWick = rng > 0 ? lowerW / rng : 0.0

bullSweep = not na(lastPL) and low < lastPL and close > lastPL and loWick >= sweepWick
bearSweep = not na(lastPH) and high > lastPH and close < lastPH and upWick >= sweepWick

plotshape(showSweep and bullSweep, "Bull Sweep", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 0), size=size.small)
plotshape(showSweep and bearSweep, "Bear Sweep", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.small)
sweepScore = bullSweep ? 1 : bearSweep ? -1 : 0

// ===== ORDER FLOW DELTA =====
buyShare  = rng > 0 ? (close - low) / rng : 0.5
delta     = (2 * buyShare - 1) * volume
deltaEMA  = ta.ema(delta, ofLen)
ofScore   = deltaEMA > 0 ? 1 : deltaEMA < 0 ? -1 : 0

absD   = math.abs(delta)
absEMA = ta.ema(absD, ofLen)
strongBuy  = delta > 0 and absD > absEMA * 1.5
strongSell = delta < 0 and absD > absEMA * 1.5
plotshape(strongBuy,  "OF Buy",  style=shape.circle, location=location.belowbar, color=color.new(color.green, 30), size=size.tiny)
plotshape(strongSell, "OF Sell", style=shape.circle, location=location.abovebar, color=color.new(color.fuchsia, 30), size=size.tiny)

// ===== VOLUME PROFILE =====
var array<float> volBins = array.new<float>(vpRows, 0.0)
var float sessHi = na
var float sessLo = na
if newSession
    for i = 0 to vpRows - 1
        array.set(volBins, i, 0.0)
    sessHi := high
    sessLo := low
else
    sessHi := na(sessHi) ? high : math.max(sessHi, high)
    sessLo := na(sessLo) ? low  : math.min(sessLo, low)

if not na(sessHi) and not na(sessLo) and sessHi > sessLo
    binSize = (sessHi - sessLo) / vpRows
    if binSize > 0
        startBin = math.max(0, int(math.floor((low  - sessLo) / binSize)))
        endBin   = math.min(vpRows - 1, int(math.floor((high - sessLo) / binSize)))
        bars     = math.max(1, endBin - startBin + 1)
        vPer     = volume / bars
        for i = startBin to endBin
            cur = array.get(volBins, i)
            array.set(volBins, i, cur + vPer)

calcPoc() =>
    maxIdx = 0
    maxVol = 0.0
    for i = 0 to vpRows - 1
        v = array.get(volBins, i)
        if v > maxVol
            maxVol := v
            maxIdx := i
    binSz = (sessHi - sessLo) / vpRows
    poc = sessLo + (maxIdx + 0.5) * binSz

    totVol = 0.0
    for i = 0 to vpRows - 1
        totVol := totVol + array.get(volBins, i)
    target = totVol * vpVA / 100.0
    accum  = array.get(volBins, maxIdx)
    lo = maxIdx
    hi = maxIdx
    while accum < target and (lo > 0 or hi < vpRows - 1)
        upV = hi < vpRows - 1 ? array.get(volBins, hi + 1) : -1.0
        dnV = lo > 0          ? array.get(volBins, lo - 1) : -1.0
        if upV >= dnV
            hi := hi + 1
            if upV > 0
                accum := accum + upV
        else
            lo := lo - 1
            if dnV > 0
                accum := accum + dnV
    vah = sessLo + (hi + 0.5) * binSz
    val = sessLo + (lo + 0.5) * binSz
    [poc, vah, val]

var float pocPx = na
var float vahPx = na
var float valPx = na
if not na(sessHi) and sessHi > sessLo
    [p, h_, l_] = calcPoc()
    pocPx := p
    vahPx := h_
    valPx := l_

plot(showVP ? pocPx : na, "POC", color=color.new(color.yellow, 0), linewidth=2, style=plot.style_circles)
plot(showVP ? vahPx : na, "VAH", color=color.new(color.gray, 0),   style=plot.style_circles)
plot(showVP ? valPx : na, "VAL", color=color.new(color.gray, 0),   style=plot.style_circles)
vpScore = not na(pocPx) ? (close > pocPx ? 1 : close < pocPx ? -1 : 0) : 0

// ===== MOMENTUM =====
rsi = ta.rsi(close, 14)
momScore = rsi > 55 ? 1 : rsi < 45 ? -1 : 0

// ===== CONFLUENCE =====
bullCount = (trendScore==1?1:0) + (vwapScore==1?1:0) + (sweepScore==1?1:0) + (ofScore==1?1:0) + (vpScore==1?1:0) + (momScore==1?1:0)
bearCount = (trendScore==-1?1:0) + (vwapScore==-1?1:0) + (sweepScore==-1?1:0) + (ofScore==-1?1:0) + (vpScore==-1?1:0) + (momScore==-1?1:0)
netScore  = bullCount - bearCount

longSig  = bullCount >= minScore and bearCount <= 1
shortSig = bearCount >= minScore and bullCount <= 1

plotshape(longSig,  "BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, text="BUY",  size=size.normal)
plotshape(shortSig, "SELL", style=shape.labeldown, location=location.abovebar, color=color.new(color.red,   0), textcolor=color.white, text="SELL", size=size.normal)

bgcolor(longSig ? color.new(color.green, 88) : shortSig ? color.new(color.red, 88) : na)

// ===== DASHBOARD =====
var table tbl = table.new(position.top_right, 2, 8, border_color=color.gray, border_width=1)
if showTbl and barstate.islast
    table.cell(tbl, 0, 0, "Confluence Hunter", text_color=color.aqua, bgcolor=color.new(#1f1f1f, 0), text_size=size.small)
    table.cell(tbl, 1, 0, "v1.0", text_color=color.aqua, bgcolor=color.new(#1f1f1f, 0), text_size=size.small)

    table.cell(tbl, 0, 1, "EMA Stack", text_color=color.white, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)
    table.cell(tbl, 1, 1, bullStack?"BULL":bearStack?"BEAR":"MIXED", text_color=bullStack?color.lime:bearStack?color.red:color.yellow, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)

    table.cell(tbl, 0, 2, "VWAP", text_color=color.white, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)
    table.cell(tbl, 1, 2, vwapScore==1?"ABOVE":vwapScore==-1?"BELOW":"AT", text_color=vwapScore==1?color.lime:vwapScore==-1?color.red:color.yellow, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)

    table.cell(tbl, 0, 3, "Order Flow", text_color=color.white, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)
    table.cell(tbl, 1, 3, ofScore==1?"BUY+":ofScore==-1?"SELL+":"FLAT", text_color=ofScore==1?color.lime:ofScore==-1?color.red:color.yellow, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)

    table.cell(tbl, 0, 4, "Last Sweep", text_color=color.white, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)
    table.cell(tbl, 1, 4, bullSweep?"BULL":bearSweep?"BEAR":"-", text_color=bullSweep?color.lime:bearSweep?color.red:color.gray, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)

    table.cell(tbl, 0, 5, "vs POC", text_color=color.white, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)
    table.cell(tbl, 1, 5, vpScore==1?"ABOVE":vpScore==-1?"BELOW":"-", text_color=vpScore==1?color.lime:vpScore==-1?color.red:color.yellow, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)

    table.cell(tbl, 0, 6, "RSI(14)", text_color=color.white, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)
    table.cell(tbl, 1, 6, str.tostring(rsi, "#.0"), text_color=momScore==1?color.lime:momScore==-1?color.red:color.yellow, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)

    table.cell(tbl, 0, 7, "Net Score", text_color=color.white, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(netScore), text_color=netScore>=minScore?color.lime:netScore<=-minScore?color.red:color.yellow, bgcolor=color.new(#1f1f1f, 20), text_size=size.small)

// ===== ALERTS =====
alertcondition(longSig,  "Confluence BUY",  "BUY signal")
alertcondition(shortSig, "Confluence SELL", "SELL signal")
alertcondition(bullSweep,"Bull Sweep", "Bullish liquidity sweep")
alertcondition(bearSweep,"Bear Sweep", "Bearish liquidity sweep")
````
