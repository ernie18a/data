# Powell Model v2 

- url: https://www.tradingview.com/script/56BErSTp-Powell-Model-v2/
- type: indicator
- pine_id: PUB;652b8b759a94451fbeda1ff71d77e6f2
- version: 2.0

## Description

This is Powell strategy we used pd ray fig ifvg and plenty more

## Source Code

````pine
//@version=6
// TTFM ALERTER v1.0 — VISUAL EYEBALL AID ONLY.
// Exact port of STRATEGY_SPEC.md (TTFM Alerter Spec v1.0): §3.2 unified bias tree on Daily/4H/entry-TF,
// strict three-way alignment, §4 C2 + new C3 + rolling-C2 entries, §5 exact-wick stops (NO buffer),
// §6 previous-day H/L target banded [0.5R floor … 2R cap]. Put the chart on 30m or 1H.
// The real alerting (FORMING T-3:00 / CONFIRMED T-0:15 / VOID, 1H-beats-30m collision, Discord) lives in Python.
indicator("TTFM Alerter v1.0 — Eyeball Aid", "TTFM v1.0", overlay=true, max_labels_count=500, max_lines_count=500)

// ---------- Inputs ----------
gV = "Visuals"
showTable  = input.bool(true,  "Show bias/alignment table", group=gV)
markAll    = input.bool(true,  "Mark unaligned C2/C3 (gray)", group=gV)
markIndec  = input.bool(true,  "Mark indecisive candles (W = whipsaw, I = inside bar)", group=gV)
showPD     = input.bool(true,  "Show previous-day high/low (target source)", group=gV)
shadeSess  = input.bool(true,  "Shade 06:00–11:30 ET close-eligibility window", group=gV)
gR = "Levels on aligned signals"
showLevels = input.bool(true,  "Draw entry/stop/target (§5/§6)", group=gR)
extendBars = input.int(14,     "Level length (bars)", minval=2, group=gR)
gS = "Spec interpretation"
literalBias = input.bool(true, "Literal §3.3 entry-TF bias (predecessor candle)", group=gS,
     tooltip="ON = spec v1.0 exactly as written: the signal candle's immediate predecessor supplies entry-TF bias. KNOWN CONSEQUENCE: a C3's predecessor is a failed C2 whose bias can never match the trade, so C3/rolling-C2 entries NEVER align (pinned in the Python tests; flagged for Stage 4). OFF = anchor the C3 entry-TF bias to the candle BEFORE the pattern started — the likely Stage-4 fix that lets C3 entries qualify.")

// ---------- §3.1 indecisive + §4 pattern primitives (offset i = the candle being evaluated) ----------
isType1(i) =>
    low[i] < low[i + 1] and high[i] > high[i + 1] and close[i] >= low[i + 1] and close[i] <= high[i + 1]
isType2(i) =>
    high[i] <= high[i + 1] and low[i] >= low[i + 1]
isC2Bull(i) =>
    low[i] < low[i + 1] and close[i] > low[i + 1]
isC2Bear(i) =>
    high[i] > high[i + 1] and close[i] < high[i + 1]
isFailedBull(i) =>
    low[i] < low[i + 1] and close[i] <= low[i + 1]
isFailedBear(i) =>
    high[i] > high[i + 1] and close[i] >= high[i + 1]
isC3Bull(i) =>
    isFailedBull(i + 1) and low[i] >= low[i + 1] and close[i] > low[i + 2]
isC3Bear(i) =>
    isFailedBear(i + 1) and high[i] <= high[i + 1] and close[i] < high[i + 2]

// ---------- §3.2 bias decision tree: indecisive → C2 → C3 → directional close → tie ----------
biasAt(i) =>
    indec = isType1(i) or isType2(i)
    indec ? 0 : isC2Bull(i) ? 1 : isC2Bear(i) ? -1 : isC3Bull(i) ? 1 : isC3Bear(i) ? -1 : close[i] > close[i + 1] ? 1 : close[i] < close[i + 1] ? -1 : 0

// ---------- HTF bias at the most recent COMPLETED close (non-repainting: [1] + lookahead_on) ----------
dBias  = request.security(syminfo.tickerid, "D",   biasAt(1), lookahead = barmerge.lookahead_on)
hBias  = request.security(syminfo.tickerid, "240", biasAt(1), lookahead = barmerge.lookahead_on)
pdHigh = request.security(syminfo.tickerid, "D",   high[1],   lookahead = barmerge.lookahead_on)
pdLow  = request.security(syminfo.tickerid, "D",   low[1],    lookahead = barmerge.lookahead_on)

// ---------- Entry-TF patterns on the current candle (live = the FORMING hypothetical close) ----------
c2L = isC2Bull(0)
c2S = isC2Bear(0)
c3L = isC3Bull(0)
c3S = isC3Bear(0)
// Rolling C2 (§4.5) needs no special state: C2 is always checked vs the immediate predecessor.
sigTxt = c3L or c3S ? "C3" : "C2"

// ---------- §3.3 entry-TF bias (the signal candle's predecessor; never the signal itself) ----------
ePrev  = biasAt(1)                    // literal spec
ePat   = biasAt(2)                    // pattern-anchor variant (candle before the failed C2)
eBiasL = c3L and not literalBias ? ePat : ePrev
eBiasS = c3S and not literalBias ? ePat : ePrev

// ---------- §2 session window: bar CLOSE in [06:00, 11:30] ET inclusive both ends ----------
mClose   = hour(time_close, "America/New_York") * 60 + minute(time_close, "America/New_York")
inWindow = mClose >= 360 and mClose <= 690

// ---------- §4.6 entry signal: strict 3-way alignment + pattern + window ----------
ok         = bar_index > 10
alignedL   = ok and dBias == 1 and hBias == 1 and eBiasL == 1
alignedS   = ok and dBias == -1 and hBias == -1 and eBiasS == -1
validLong  = (c2L or c3L) and alignedL and inWindow
validShort = (c2S or c3S) and alignedS and inWindow
c3Blocked  = literalBias and inWindow and (c3L and dBias == 1 and hBias == 1 or c3S and dBias == -1 and hBias == -1) and not (validLong or validShort)

// ---------- Visuals ----------
bgcolor(shadeSess and inWindow ? color.new(color.blue, 92) : na, title="06:00–11:30 ET window")
plot(showPD ? pdHigh : na, "PD High", color=color.new(color.aqua, 30), style=plot.style_steplinebr, linewidth=1)
plot(showPD ? pdLow  : na, "PD Low",  color=color.new(color.aqua, 30), style=plot.style_steplinebr, linewidth=1)
plotchar(markIndec and isType1(0) and barstate.isconfirmed, "Whipsaw (Type 1)",    "W", location.abovebar, color.new(color.gray, 30), size=size.tiny)
plotchar(markIndec and isType2(0) and barstate.isconfirmed, "Inside bar (Type 2)", "I", location.abovebar, color.new(color.gray, 45), size=size.tiny)
plotshape(markAll and (c2L or c3L) and not validLong and barstate.isconfirmed,  "C2/C3 bull (unaligned)", shape.triangleup,   location.belowbar, color.new(color.gray, 35), size=size.tiny)
plotshape(markAll and (c2S or c3S) and not validShort and barstate.isconfirmed, "C2/C3 bear (unaligned)", shape.triangledown, location.abovebar, color.new(color.gray, 35), size=size.tiny)
// live FORMING preview (repaints intra-bar by design — mirrors the T-3:00 hypothetical-close check)
plotshape(validLong and not barstate.isconfirmed,  "FORMING long",  shape.triangleup,   location.belowbar, color.new(color.yellow, 0), size=size.small)
plotshape(validShort and not barstate.isconfirmed, "FORMING short", shape.triangledown, location.abovebar, color.new(color.yellow, 0), size=size.small)

// ---------- §5/§6 levels: stop EXACTLY on the wick, target = PD H/L banded [0.5R, 2R] ----------
f_levels(isLong, stopRaw) =>
    entry = close
    risk  = math.abs(entry - stopRaw)
    if risk > 0
        distPD = isLong ? pdHigh - entry : entry - pdLow
        rrPD   = distPD / risk
        tp     = distPD <= 0 ? (isLong ? entry + 0.5 * risk : entry - 0.5 * risk) : rrPD < 0.5 ? (isLong ? entry + 0.5 * risk : entry - 0.5 * risk) : rrPD <= 2.0 ? (isLong ? pdHigh : pdLow) : (isLong ? entry + 2.0 * risk : entry - 2.0 * risk)
        src    = distPD <= 0 ? "0.5R fallback (PD passed)" : rrPD < 0.5 ? "0.5R floor" : rrPD <= 2.0 ? (isLong ? "PD high" : "PD low") : "2R cap"
        x2 = bar_index + extendBars
        line.new(bar_index, stopRaw, x2, stopRaw, color=color.yellow, width=2)
        line.new(bar_index, entry,   x2, entry,   color=color.white, style=line.style_dotted)
        line.new(bar_index, tp,      x2, tp,      color=color.blue,  width=2)
        label.new(x2, stopRaw, "Stop " + str.tostring(stopRaw, format.mintick), style=label.style_label_left, color=color.new(color.yellow, 25), textcolor=color.black, size=size.tiny)
        label.new(x2, tp, "TP " + str.tostring(tp, format.mintick) + " (" + src + ", R:R " + str.tostring(math.abs(tp - entry) / risk, "#.##") + ")", style=label.style_label_left, color=color.new(color.blue, 20), textcolor=color.white, size=size.tiny)

if validLong and barstate.isconfirmed
    label.new(bar_index, low, sigTxt + " LONG", yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
    if showLevels
        f_levels(true, c3L ? low[1] : low)      // §5: C3 stop = failed C2's wick
if validShort and barstate.isconfirmed
    label.new(bar_index, high, sigTxt + " SHORT", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
    if showLevels
        f_levels(false, c3S ? high[1] : high)
if c3Blocked and barstate.isconfirmed
    label.new(bar_index, high, "C3 blocked by strict §3.3 bias", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.orange, 40), textcolor=color.white, size=size.tiny)

// ---------- Bias / alignment table ----------
biasTxt(b) =>
    b == 1 ? "BULLISH" : b == -1 ? "BEARISH" : "NO_BIAS"
biasCol(b) =>
    color.new(b == 1 ? color.green : b == -1 ? color.red : color.gray, 50)
var table t = table.new(position.top_right, 1, 7, border_width=1)
if showTable and barstate.islast
    eShow = literalBias ? ePrev : c3L or c3S ? ePat : ePrev
    table.cell(t, 0, 0, "TTFM Alerter v1.0", bgcolor=color.new(color.navy, 10), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 1, "Daily: " + biasTxt(dBias), bgcolor=biasCol(dBias), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "4H: " + biasTxt(hBias), bgcolor=biasCol(hBias), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 3, "Entry-TF (prev): " + biasTxt(eShow), bgcolor=biasCol(eShow), text_color=color.white, text_size=size.small)
    alignedTxt = dBias == 1 and hBias == 1 and eShow == 1 ? "LONG ✔" : dBias == -1 and hBias == -1 and eShow == -1 ? "SHORT ✔" : "none"
    table.cell(t, 0, 4, "3-way aligned: " + alignedTxt, bgcolor=color.new(alignedTxt == "none" ? color.gray : alignedTxt == "LONG ✔" ? color.green : color.red, 30), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 5, "PD H/L: " + str.tostring(pdHigh, format.mintick) + " / " + str.tostring(pdLow, format.mintick), bgcolor=color.new(color.aqua, 70), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 6, inWindow ? "Window: OPEN (06:00–11:30 ET)" : "Window: closed", bgcolor=color.new(inWindow ? color.blue : color.gray, 60), text_color=color.white, text_size=size.small)

// ---------- OPTIONAL bar-close convenience alerts — Python is the real alerter ----------
alertcondition(validLong,  "TTFM v1.0 — LONG valid (bar close)",  "TTFM LONG {{ticker}} {{interval}} @ {{close}}")
alertcondition(validShort, "TTFM v1.0 — SHORT valid (bar close)", "TTFM SHORT {{ticker}} {{interval}} @ {{close}}")
````
