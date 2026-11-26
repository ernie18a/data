# CVD [Order Flow]

- url: https://www.tradingview.com/script/vfIQ3hsG-CVD-Order-Flow/
- type: indicator
- pine_id: PUB;909f744b81d74fc0b07e51ac82e8844f
- version: 1.0

## Description

Price tells you what happened. Cumulative Volume Delta tries to tell you who was leaning on it. Delta is buying pressure minus selling pressure on each bar; CVD is that delta accumulated into a running line, so a market can grind sideways in price while the delta quietly stacks in one direction. CVD [Order Flow] builds that line, draws it as informative candles instead of a flat curve, and watches it for two order-flow behaviors traders care about: divergence against price and absorption. One honest caveat sits underneath all of it, and the tool is built around it rather than hiding it: TradingView does not know real buy versus sell volume, so this CVD is a lower-timeframe estimate — and on data where that estimate is weak, the tool stays quiet instead of inventing pressure.

[b]HOW IT WORKS[/b]

CVD is reconstructed from a lower timeframe, because the chart timeframe alone cannot tell you how a bar's volume split between buyers and sellers. The tool requests intrabar data from a faster timeframe and classifies each intrabar: an up intrabar adds its volume as positive delta, a down intrabar subtracts it, and a doji counts as zero — on an ambiguous intrabar the tool refuses to guess a side.


Delta and CVD — each bar's delta is the sum of its intrabar deltas. The cumulative line is committed only when the bar closes (the live bar is shown separately and is provisional until then). Two accumulation modes: Session resets the running total at each session start; Cumulative carries it across.
CVD candles — by default CVD is drawn as candles in its own pane: the open is the previous close, the high and low are the running intrabar extremes of the cumulative within the bar, and the close is the bar's net delta. This shows the path the delta took inside the bar, not just where it ended — more informative than a plain line. Line and Line+Histogram styles are available too.
Divergence — drawn on the price chart, between a price pivot and the matching CVD pivot, on confirmed pivots only. Regular divergence (price makes a higher high or lower low while CVD does the opposite — a potential exhaustion read) and Hidden divergence (a continuation read, default off). Several filters gate it: minimum swing size, minimum CVD move, minimum pivot volume, and bar-distance bounds, so trivial wiggles do not get marked.
Absorption — a strong delta meeting a weak price result: a lot of one-sided pressure that fails to move price its way, as if the move is being absorbed. It is confirmed on the next candle. This is an order-flow pattern, not a buy or sell instruction.


The unreliable-data part is deliberate and silent. Behind the scenes the tool weighs the symbol type against how complete the intrabar measurement is. On a symbol with no real volume it withholds signals; on tick-volume data it stays cautious. There is no confidence panel or badge — the honesty is in the behavior, not in a label on your chart.


Intrabar data is pulled from a lower timeframe and classified into per-bar delta (up = +volume, down = -volume, doji = 0)
Delta is accumulated into CVD and committed on bar close; the running line is drawn as candles, line, or line+histogram
Confirmed price and CVD pivots are compared for divergence; a strong-delta / weak-result bar is flagged as absorption, confirmed next candle


[b]HOW TO READ[/b]


The CVD line rising means net buying pressure is accumulating; falling means net selling pressure. Sideways price with a steadily climbing or dropping CVD is the situation this tool is built to surface.
CVD candles show the intrabar path: a long candle that closed near its delta extreme is one-sided flow, while a candle that ran far in delta but closed back near its open is flow that met resistance.
A regular divergence is price and CVD disagreeing at a swing — price extends, delta does not. A hidden divergence (off by default) is the continuation-flavored version. Both describe an order-flow condition, not a trade.
An absorption mark is heavy delta that did not get its move. It says pressure was met, nothing more.
"Bullish" and "Bearish" describe the direction of the pattern, not a buy or sell instruction. Marking a divergence or an absorption says nothing about whether price will turn, continue, or do neither. The tool maps the order flow; the read is yours.


[b]INPUTS[/b]


LTF Source / Manual LTF — Auto picks a lower timeframe targeting enough intrabars per chart bar; Manual lets you set it yourself.
Accumulation — Session (reset the running total each session) or Cumulative (carry it across).
Show Bullish / Show Bearish Divergence — enable each direction independently.
Show Hidden — add the continuation-style hidden divergence (default off).
Pivot Left / Right — how many bars define a confirmed pivot (larger = stricter and later, but still no repaint).
Pivot Source — Wick or Close: measure pivots from the extremes or from the closes.
Min Swing Size / Min CVD Move / Min Pivot Volume / Min & Max Bars Between — the divergence quality filters; raise them for fewer, cleaner marks.
CVD Smoothing — smooth the CVD used for pivot detection.
Absorption — toggle the absorption pattern; its delta, range, and period thresholds define how strong the delta and how weak the result must be.
CVD Style — Candles (default), Line, or Line+Histogram.
Zero Line / Dim Live Bar / Up & Down Color — display options; Dim Live Bar visually marks the not-yet-committed bar.


[b]ALERTS[/b]


CVD Bullish Divergence and CVD Bearish Divergence fire when a confirmed, filter-passing divergence is marked.
Absorption fires when a confirmed absorption is marked.
All fire on confirmed, quality-gated events — set them up with "Once Per Bar Close."


[b]NOTES & LIMITS[/b]

This is an observation tool, not a forecast. The single most important thing to understand: TradingView does not provide real buy versus sell volume, so this CVD is a lower-timeframe estimate built by splitting each bar into faster intrabars and classifying them. That estimate is only as good as the volume data underneath it. On instruments with genuine traded volume — futures and crypto — it is at its most reliable. On forex and CFDs the "volume" is tick volume (number of price updates, not contracts traded), so the delta there is looser, and the tool treats it cautiously through a silent data-quality gate; on a symbol with no usable volume it withholds signals rather than drawing noise. There is no panel telling you this per bar — the caution is built into the behavior. Divergence and absorption are order-flow patterns, not buy or sell instructions, and marking one says nothing about whether price will reverse or continue. No repaint, no lookahead: the cumulative line is committed on confirmed (closed) bars and the live bar is shown separately as provisional; divergences are drawn on confirmed pivots only — they appear a few bars late by nature, but they do not move once printed; absorption is confirmed on the next candle. The lower-timeframe request reads completed intrabars and does not leak the future. No profit, win-rate, or guarantee claim. Open-source under CC BY-NC-SA 4.0 — non-commercial use, attribution to ElisTools required for reuse or derivatives. TradingView (Pine v6) only.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ElisTools
// CVD [Order Flow] — Attribution required: credit "ElisTools" in any reuse or derivative.
//@version=6
indicator("CVD [Order Flow]", "CVD", overlay = false, dynamic_requests = false, max_labels_count = 500, max_lines_count = 300, max_bars_back = 1000)
//------------------------------------------------------------------------------
// INPUTS
//------------------------------------------------------------------------------
string G_DATA = "Data / LTF"
string G_SIG  = "Signals"
string G_DIV  = "Divergence (Core)"
string G_DISP = "Display"
ltfMode   = input.string("Auto", "LTF Source", options = ["Auto", "Manual"], group = G_DATA, tooltip = "Auto: pick a lower TF from the chart TF. Manual: choose your own (must be lower than chart TF).")
ltfManual = input.timeframe("1", "Manual LTF", group = G_DATA, tooltip = "Used when LTF Source = Manual.")
cumMode   = input.string("Session", "Accumulation", options = ["Session", "Cumulative"], group = G_DATA, tooltip = "Session: reset at the start of each exchange day (the symbol's daily session open). Cumulative: keep accumulating without reset.")
showBull   = input.bool(true, "Bullish Divergence", group = G_DIV, tooltip = "Draw bullish divergences (price low vs CVD). Regular = reversal: price LL + CVD HL. Hidden (continuation) is added only when Show Hidden Divergence is on.")
showBear   = input.bool(true, "Bearish Divergence", group = G_DIV, tooltip = "Draw bearish divergences (price high vs CVD). Regular = reversal: price HH + CVD LH. Hidden (continuation) is added only when Show Hidden Divergence is on.")
showHidden = input.bool(false, "Show Hidden Divergence", group = G_DIV, tooltip = "Also draw hidden (continuation) divergences: price HL + CVD LL (bullish) / price LH + CVD HH (bearish). Off by default. Hidden bullish prints Bullish in blue; hidden bearish prints Bearish in orange; regular divergences keep green / red.")
pivL     = input.int(5, "Pivot Left", minval = 1, group = G_DIV)
pivR     = input.int(1, "Pivot Right", minval = 1, group = G_DIV, tooltip = "Confirmation bars after the pivot = the draw delay. Default 1 = minimal delay (absorption-style). Higher = stronger/cleaner swing but draws later.")
pivotSrc = input.string("Wick", "Pivot Source", options = ["Wick", "Close"], group = G_DIV, tooltip = "Wick: pivots from high/low. Close: pivots from close (fewer, cleaner swings).")
divMinBars = input.int(5, "Min Bars Between Pivots", minval = 1, group = G_DIV, tooltip = "Filter: the two pivots forming a divergence must be at least this far apart.")
divMinATR  = input.float(1.5, "Min Swing Size", minval = 0.0, step = 0.1, group = G_DIV, tooltip = "Strength filter: the swing into the pivot (distance from the previous opposite pivot) must exceed this multiple of ATR. Filters micro-wiggles while still allowing a marginal new high/low. 0 = off.")
divMinCvd  = input.float(1.0, "Min CVD Move", minval = 0.0, step = 0.5, group = G_DIV, tooltip = "Strength filter: the CVD gap between the two same-side pivots must exceed this multiple of the average per-bar delta. Lower = catches subtle higher-lows / lower-highs. 0 = off.")
divMaxBars = input.int(60, "Max Bars Between Pivots", minval = 2, group = G_DIV, tooltip = "Filter: ignore divergences whose two pivots are more than this far apart (stale).")
divMinVol  = input.float(1.0, "Min Pivot Volume", minval = 0.0, step = 0.1, group = G_DIV, tooltip = "Strength filter: the 2nd pivot's volume must exceed this multiple of the 20-bar average volume (real absorption vs disinterest). 0 = off.")
divSmooth  = input.int(1, "CVD Smoothing (Divergence)", minval = 1, group = G_DIV, tooltip = "Light EMA on the CVD used for divergence detection only (candles stay raw). 1 = off; try 3-5 to cut micro-noise.")
showAbsorb = input.bool(true, "Absorption", group = G_SIG, tooltip = "Strong delta but weak price result = pressure being absorbed. Drawn only if the next candle confirms. Weaker without bid/ask data.")
effMult   = input.float(1.8, "Absorption Delta Threshold", minval = 1.0, step = 0.1, group = G_SIG, tooltip = "barDelta must exceed this multiple of the average absolute delta to count as strong effort.")
resFrac   = input.float(0.6, "Absorption Range Threshold", minval = 0.1, step = 0.1, group = G_SIG, tooltip = "Bar range must be below this fraction of ATR to count as weak result.")
absLen    = input.int(14, "Absorption Period", minval = 2, group = G_SIG, tooltip = "Lookback for the average delta and the ATR used by absorption.")
cvdStyle = input.string("Candles", "CVD Style", options = ["Candles", "Line", "Line+Histogram"], group = G_DISP, tooltip = "Candles: CVD open/high/low/close per bar (open = prior close; wicks = intrabar delta extremes). Line: cumulative close only.")
showZero = input.bool(false, "Zero Line", group = G_DISP, tooltip = "Off by default: a fixed zero forces the y-scale wide and squashes the candles. Enable only if you want the absolute zero reference.")
dimLive  = input.bool(true, "Dim Live Bar", group = G_DISP)
upCol    = input.color(#26a69a, "Up Color", group = G_DISP)
dnCol    = input.color(#ef5350, "Down Color", group = G_DISP)
//------------------------------------------------------------------------------
// AUTO LTF  (constant / bar-invariant)
//   1m->1S | 5m,15m->1m | 1h->5m | 4h->15m | 1D->1h | >1D->4h
//------------------------------------------------------------------------------
int chartSec = timeframe.in_seconds()
string autoLtf = chartSec <= 60 ? "1S" : chartSec <= 900 ? "1" : chartSec <= 3600 ? "5" : chartSec <= 14400 ? "15" : chartSec <= 86400 ? "60" : "240"
string ltfStr = ltfMode == "Auto" ? autoLtf : ltfManual
//------------------------------------------------------------------------------
// LTF REQUEST  (single, global, unconditional, tuple; cannot look ahead)
//------------------------------------------------------------------------------
[ltfO, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, ltfStr, [open, close, volume], ignore_invalid_timeframe = true)
//------------------------------------------------------------------------------
// BAR DELTA  (doji = 0 neutral; zero/NaN guard)
//------------------------------------------------------------------------------
int n = array.size(ltfC)
float barDelta = 0.0
float runHi = 0.0   // running intrabar cumulative max (for CVD candle high)
float runLo = 0.0   // running intrabar cumulative min (for CVD candle low)
if n > 0
    float run = 0.0
    for i = 0 to n - 1
        float c = array.get(ltfC, i)
        float o = array.get(ltfO, i)
        float v = nz(array.get(ltfV, i))
        run += c > o ? v : c < o ? -v : 0.0
        runHi := math.max(runHi, run)
        runLo := math.min(runLo, run)
    barDelta := run
//------------------------------------------------------------------------------
// CUMULATIVE  (commits only on bar close; live kept separate; optional session reset)
//------------------------------------------------------------------------------
var float cvdCommitted = 0.0
bool  isNewSession = cumMode == "Session" and nz(ta.change(time("D"))) != 0
float base         = isNewSession ? 0.0 : cvdCommitted
float cvdDisplay   = base + barDelta
float cvdOpen      = base            // candle open = prior close (continuous)
float cvdHigh      = base + runHi    // candle high = intrabar cumulative peak
float cvdLow       = base + runLo    // candle low  = intrabar cumulative trough
if barstate.isconfirmed
    cvdCommitted := cvdDisplay
//------------------------------------------------------------------------------
// DATA QUALITY  (type ceiling x completeness -> quality grade; SILENTLY gates signals)
//   Fixed internally - no user inputs (traders won't tune these). The gate only
//   silences signals on volumeless data where CVD is meaningless; on real- or
//   tick-volume symbols it stays open.
//------------------------------------------------------------------------------
int   smoothLen  = 5      // quality-score smoothing window (anti-flicker on the gate)
float tickCeil   = 65.0   // tick-volume (forex/cfd/index) ceiling = Medium (< 80, never High)
int   sigMinRank = 1      // "Low" floor: allow Low and up; block only grade-0 (no-volume) symbols
float ltfSec       = timeframe.in_seconds(ltfStr)
float expected     = ltfSec > 0 ? chartSec / ltfSec : na
float completeness = (not na(expected) and expected >= 1) ? math.min(1.0, n / expected) : na
var bool volSeen = false
if not na(volume) and volume > 0
    volSeen := true
bool  tickType = syminfo.type == "forex" or syminfo.type == "cfd" or syminfo.type == "index" or syminfo.type == "economic" or syminfo.type == "fundamental" or syminfo.type == "spread"
bool  noVol      = not volSeen
bool  hasTickVol = volSeen and tickType
float typeCeil   = noVol ? 0.0 : hasTickVol ? tickCeil : 100.0
float trustRaw = na(completeness) ? 0.0 : (typeCeil / 100.0) * completeness
float trust    = nz(ta.sma(trustRaw, smoothLen))
int  tierRank  = trust >= 0.80 ? 3 : trust >= 0.50 ? 2 : trust >= 0.20 ? 1 : 0
bool sigGate   = tierRank >= sigMinRank
bool conf      = barstate.isconfirmed
//------------------------------------------------------------------------------
// ABSORPTION
//------------------------------------------------------------------------------
float absAvg = ta.sma(math.abs(barDelta), absLen)
float atrv   = ta.atr(absLen)
bool strongEffort = absAvg > 0 and math.abs(barDelta) >= effMult * absAvg
bool weakResult   = atrv > 0 and (high - low) <= resFrac * atrv
bool absorbBull = strongEffort and weakResult and barDelta < 0   // selling absorbed -> bullish
bool absorbBear = strongEffort and weakResult and barDelta > 0   // buying absorbed  -> bearish
bool absBullSig = absorbBull[1] and close > open
bool absBearSig = absorbBear[1] and close < open
//------------------------------------------------------------------------------
// DIVERGENCE ENGINE
//------------------------------------------------------------------------------
float srcHi    = pivotSrc == "Close" ? close : high
float srcLo    = pivotSrc == "Close" ? close : low
float ph       = ta.pivothigh(srcHi, pivL, pivR)
float pl       = ta.pivotlow(srcLo, pivL, pivR)
float cvdForDiv = ta.ema(cvdDisplay, divSmooth)   // light smoothing for DETECTION only (candles stay raw)
float cvdAtPiv  = cvdForDiv[pivR]
int   pivBar    = bar_index - pivR
float vAtPiv    = nz(volume[pivR])                // volume at the (2nd) pivot bar
float vAvgPiv   = nz(ta.sma(volume, 20)[pivR])    // 20-bar average volume there
bool  okVol     = vAvgPiv <= 0 or vAtPiv >= divMinVol * vAvgPiv
var float pPH = na   // previous pivot high: price, cvd, bar
var float pCH = na
var int   pHi = na
var float pPL = na   // previous pivot low: price, cvd, bar
var float pCL = na
var int   pLi = na
bool regBear = false
bool hidBear = false
bool regBull = false
bool hidBull = false
if conf and not na(ph)
    bool okDist = not na(pHi) and (pivBar - pHi) >= divMinBars and (pivBar - pHi) <= divMaxBars
    bool strong = (na(pPL) or (ph - pPL) >= divMinATR * atrv) and math.abs(cvdAtPiv - pCH) >= divMinCvd * absAvg
    bool arm    = sigGate and not na(pPH) and okDist and strong and okVol
    regBear := arm and showBear and ph > pPH and cvdAtPiv < pCH
    hidBear := showHidden and arm and showBear and ph < pPH and cvdAtPiv > pCH
    if regBear or hidBear
        color cBear = hidBear ? #f57c00 : #c62828
        line.new(pHi, pPH, pivBar, ph, xloc = xloc.bar_index, color = cBear, width = 1, style = line.style_solid, force_overlay = true)
        label.new(pivBar, ph, "Bearish", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = cBear, textcolor = color.white, size = size.small, force_overlay = true, tooltip = hidBear ? "Bearish divergence - continuation (price LH, CVD HH)" : "Bearish divergence - reversal (price HH, CVD LH)")
    pPH := ph
    pCH := cvdAtPiv
    pHi := pivBar
if conf and not na(pl)
    bool okDist = not na(pLi) and (pivBar - pLi) >= divMinBars and (pivBar - pLi) <= divMaxBars
    bool strong = (na(pPH) or (pPH - pl) >= divMinATR * atrv) and math.abs(cvdAtPiv - pCL) >= divMinCvd * absAvg
    bool arm    = sigGate and not na(pPL) and okDist and strong and okVol
    regBull := arm and showBull and pl < pPL and cvdAtPiv > pCL
    hidBull := showHidden and arm and showBull and pl > pPL and cvdAtPiv < pCL
    if regBull or hidBull
        color cBull = hidBull ? #1e88e5 : #2e7d32
        line.new(pLi, pPL, pivBar, pl, xloc = xloc.bar_index, color = cBull, width = 1, style = line.style_solid, force_overlay = true)
        label.new(pivBar, pl, "Bullish", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = cBull, textcolor = color.white, size = size.small, force_overlay = true, tooltip = hidBull ? "Bullish divergence - continuation (price HL, CVD LL)" : "Bullish divergence - reversal (price LL, CVD HL)")
    pPL := pl
    pCL := cvdAtPiv
    pLi := pivBar
//------------------------------------------------------------------------------
// DRAWING
//------------------------------------------------------------------------------
bool  isCandles = cvdStyle == "Candles"
bool  isLiveBar = barstate.islast and not barstate.isconfirmed
// Raw cumulative CVD (no transform). The pane auto-scales to the visible range;
// keep the Zero Line OFF so it does not force the scale and squash the candles.
// Line mode (hidden when candles)
color dirCol  = cvdDisplay >= nz(cvdDisplay[1]) ? upCol : dnCol
color lineCol = (dimLive and isLiveBar) ? color.new(dirCol, 70) : dirCol
plot(isCandles ? na : cvdDisplay, "CVD", color = lineCol, linewidth = 2)
// Candle mode (raw CVD OHLC: open = prior close, high/low = intrabar delta extremes)
color candCol  = cvdDisplay >= cvdOpen ? upCol : dnCol
color candLive = (dimLive and isLiveBar) ? color.new(candCol, 55) : candCol
plotcandle(isCandles ? cvdOpen : na, isCandles ? cvdHigh : na, isCandles ? cvdLow : na, isCandles ? cvdDisplay : na, "CVD Candles", color = candLive, wickcolor = candLive, bordercolor = candLive)
bool showHist = cvdStyle == "Line+Histogram"
plot(showHist ? barDelta : na, "Bar Delta", color = barDelta >= 0 ? color.new(upCol, 45) : color.new(dnCol, 45), style = plot.style_columns)
plot(showZero ? 0.0 : na, "Zero", color = color.new(color.gray, 40), linewidth = 1)
plotchar(showAbsorb and sigGate and conf and absBullSig, "Absorption (Bull)", "▲", location.bottom, color = #1b873f, size = size.tiny, offset = -1)
plotchar(showAbsorb and sigGate and conf and absBearSig, "Absorption (Bear)", "▼", location.top, color = #c62828, size = size.tiny, offset = -1)
// (Divergence is drawn on the PRICE chart via force_overlay - see the divergence engine above.)
//------------------------------------------------------------------------------
// ALERTS  (confirmed-gated + quality-gated; set the alert to "Once Per Bar Close")
//------------------------------------------------------------------------------
alertcondition(regBear or hidBear, "CVD Bearish Divergence", "CVD Bearish Divergence (price vs CVD)")
alertcondition(regBull or hidBull, "CVD Bullish Divergence", "CVD Bullish Divergence (price vs CVD)")
alertcondition(showAbsorb and sigGate and conf and (absBullSig or absBearSig), "CVD Absorption", "Absorption: Strong Delta, Weak Price Result, Next Candle Confirmed")
````
