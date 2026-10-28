# Anchored VWAP Engine [Quantum Algo]

- url: https://www.tradingview.com/script/eqD9PKX8-Anchored-VWAP-Engine-Quantum-Algo/
- type: indicator
- pine_id: PUB;243b01bfd68147cda51ed04178b19775
- version: 1.0

## Description

Anchored VWAP Engine [Quantum Algo]
====================================================

🔶 OVERVIEW

Anchored VWAP Engine is a multi-stream anchored Volume Weighted Average Price indicator that removes the hardest part of trading with anchored VWAP: choosing the anchor. The engine runs up to seven independently anchored VWAP streams that place and reset their own anchors automatically — the week open (the default stream), session open, month open, confirmed swing highs and swing lows, the highest-volume bar in a lookback, and a liquidity-sweep anchor that re-anchors from the exact bar where a stop run occurred. On top of the streams it adds volume-weighted deviation bands, automatic confluence cluster zones where multiple streams converge, band-rejection signals, and a stability metric that names which VWAP the market is currently respecting most.

Out of the box the chart shows a single clean line: the week-anchored Volume Weighted Average Price with its deviation bands. Every additional stream is one checkbox away.

🔶 WHAT IS AN ANCHORED VWAP?

The Volume Weighted Average Price is the average price of an instrument weighted by traded volume — the closest public approximation of the average position price of everyone who transacted since a chosen starting point. An anchored VWAP starts that calculation from a meaningful event rather than an arbitrary date: a weekly open, a swing low, a high-volume climax bar. Price above an anchored VWAP means the average participant since that event is in profit; price returning to it often behaves as a decision level, because it is where the average position breaks even. The power of the tool depends entirely on where it is anchored — which is exactly what this engine automates.

🔶 WHY THIS SCRIPT IS ORIGINAL

1. Automatic multi-anchor engine. Seven streams anchor and re-anchor themselves from objectively defined events — no manual anchor placement, no stale anchors, no guessing.

2. The liquidity-sweep anchor. When a swing level is wicked through and rejected — a stop run — the sweep stream re-anchors from that exact bar and colors itself by implication: the accumulation tone after a sell-side sweep, the distribution tone after a buy-side raid. Averaging from the stop-run bar tracks the entry basis of the participants who engineered it. To our knowledge this anchor type has not been published before.

3. Exact swing anchoring. Swing-anchored streams rebuild their sums retroactively from the true pivot bar once the pivot confirms, so the calculation is mathematically identical to a VWAP hand-anchored on the swing itself — not started late at the confirmation bar.

4. Confluence clusters. When two or more active streams converge within an Average True Range tolerance, the engine draws a cluster zone and labels its strength. Multiple independent volume-weighted averages agreeing on one price is the strongest form of VWAP confluence, detected automatically.

5. The In Control metric. An exponentially decayed crossing-rate measures how cleanly price is respecting each stream; the dashboard names the stream currently in control. Users learn which anchor matters today instead of watching all of them equally.

6. True volume-weighted deviation bands. The bands are built from the volume-weighted variance of the primary stream — not a simple price standard deviation — at two configurable widths, with band-rejection signals printed as a single σ character whose full context lives in the hover tooltip, protected by a signal cooldown.

7. Quiet by default. One stream, one set of bands, capped signals, and a compact dashboard. The engine detects everything; the chart shows only what is asked of it.

🔶 HOW IT WORKS

Streams: Each stream maintains volume-weighted price and variance sums that reset on its anchor event — new week, new session, new month, a confirmed swing, a lookback volume record, or a qualified liquidity sweep. Between events the sums accumulate bar by bar, producing the stream's live anchored VWAP.

Sweep detection: A sweep qualifies when price wicks through the last confirmed swing level but closes back inside it, with per-level memory so the same level cannot re-trigger. The sweep stream then re-anchors from that bar.

Deviation bands: The primary stream (selectable; week open by default) carries inner and outer bands at configurable sigma multiples computed from its own volume-weighted variance, with softly tinted zones between them.

Signals: A wick beyond the outer band with a close back inside, on the correct side of the VWAP, prints the σ rejection signal — reversion bias toward the average — evaluated on closed bars only and rate-limited by the cooldown.

Clusters: On the live bar the engine groups all active stream values within the tolerance and draws a labeled zone for each group of two or more.

Dashboard: A fully themeable panel lists every stream with its live distance from price in Average True Range units and side, plus the In Control stream, active cluster count, and the current band width.

Non-repainting: Anchors use confirmed events, sweeps and signals are evaluated at bar close, and swing streams rebuild exactly rather than approximately.

🔶 HOW TO USE IT

1. Works on any market with reliable volume — cryptocurrency, stocks, indices, futures. On the default settings, read the week-anchored VWAP as the institutional benchmark: above it with rising distance means the average weekly participant is in profit.
2. Treat the VWAP itself as the decision level and the outer bands as stretch: σ rejections at the outer band carry a reversion bias back toward the average.
3. Enable the swing and sweep anchors to study reactions: price returning to a sweep-anchored VWAP is returning to the average entry of the stop-run — a level worth watching.
4. Cluster zones are the highest-value levels the engine produces: several independent volume-weighted averages agreeing on one price. Watch how price behaves on first touch.
5. Use the In Control row to pick which stream deserves your attention today, and the distance column to see what is nearby before it is hit.
6. Intraday traders can switch the primary stream to Session Open; swing traders can promote Month Open.

🔶 SETTINGS

- Anchors: independent toggles for all seven streams, swing pivot length, highest-volume lookback. Default: Week Open only.
- Primary stream selection with inner and outer band multiples.
- Cluster detection with Average True Range tolerance.
- Signals: toggle, cooldown, and signals to keep.
- Individual colors for every stream plus accent and neutral colors.
- Themeable dashboard: position, four text sizes, title band, background, frame, grid, and three text colors.

🔶 ALERTS

- Bullish / Bearish Band Rejection — price rejected the outer deviation band of the primary stream.
- Price Crossed Above / Below Primary VWAP.
- VWAP Cluster Formed — two or more streams converged into a confluence zone.
- Sweep Anchor Reset — a liquidity sweep occurred and the sweep stream re-anchored from the stop-run bar.

🔶 FREQUENTLY ASKED QUESTIONS

Does the indicator repaint? No. Anchor events are confirmed before they act, swing streams rebuild exactly from the confirmed pivot bar, and signals are evaluated on closed bars. Swing confirmation carries its standard pivot lag by design.

Why do I only see one line? By default only the week-anchored stream is enabled for a clean first chart. Every other anchor is a checkbox in settings.

What makes the sweep anchor special? It averages price and volume from the exact bar where stops were run — the basis of the participants who engineered the move — rather than from a calendar date or swing alone.

Why is there no cluster or In Control reading? Both features compare multiple streams; enable two or more anchors and they activate.

Which markets should avoid it? Any Volume Weighted Average Price tool is only as good as the volume feed. On symbols with unreliable or synthetic volume reporting, treat every stream with caution.

🔶 CREDITS

The Volume Weighted Average Price was introduced by Stephen Berkowitz, Dennis Logue and Eugene Noser (1988), and the anchored application was popularized by Brian Shannon, whose work established anchoring from meaningful events as a discipline. This script gratefully acknowledges both. The multi-stream auto-anchoring engine, the liquidity-sweep anchor, the exact retroactive swing rebuild, confluence clustering, the In Control stability metric, and all code in this script are original work — no third-party or open-source script code was reused.

🔶 LIMITATIONS

Volume quality determines VWAP quality; symbols with unreliable volume produce unreliable averages. Deviation bands need bars to mature after each re-anchor. Cluster detection reports convergence, not a guarantee of reaction. The In Control metric measures recent respect, not future behavior. No indicator replaces independent analysis.

🔶 DISCLAIMER

This script is provided strictly for educational and informational purposes. It is not financial advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Past behavior of any average, band, or cluster does not guarantee future results. Trading involves substantial risk. Always do your own research and manage risk independently.

## Source Code

````pine
//@version=6
indicator("Anchored VWAP Engine [Quantum Algo]", overlay = true, max_lines_count = 100, max_labels_count = 200, max_boxes_count = 100, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  Concept credits: the Volume Weighted Average Price was
//  introduced by Stephen Berkowitz, Dennis Logue and Eugene
//  Noser (1988); the anchored application was popularized by
//  Brian Shannon. The multi-stream auto-anchoring engine, the
//  liquidity-sweep anchor, confluence clustering, stability
//  metric and all code in this script are original work.
// ════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════
grpA = "Anchors"
useSes = input.bool(false, "Session Open", group = grpA)
useWk  = input.bool(true,  "Week Open", group = grpA)
useMo  = input.bool(false, "Month Open", group = grpA)
useSH  = input.bool(false, "Swing High", group = grpA)
useSL  = input.bool(false, "Swing Low", group = grpA)
useHV  = input.bool(false, "Highest Volume Bar", group = grpA)
useSw  = input.bool(false, "Liquidity Sweep", group = grpA, tooltip = "Re-anchors from the bar where a swing level was wicked through and rejected — the stop-run bar institutional entries average from.")
pivLen = input.int(10, "Swing Pivot Length", minval = 3, maxval = 40, group = grpA)
hvLB   = input.int(200, "Highest Volume Lookback", minval = 20, maxval = 480, group = grpA)

grpP = "Primary Stream & Deviation Bands"
primS    = input.string("Week Open", "Primary Stream", options = ["Session Open", "Week Open", "Month Open", "Swing High", "Swing Low", "Highest Volume Bar", "Liquidity Sweep"], group = grpP, tooltip = "The stream that carries the deviation bands and the band-rejection signals.")
showBand = input.bool(true, "Show Deviation Bands", group = grpP)
bandM1   = input.float(1.0, "Inner Band (σ)", step = 0.25, minval = 0.25, group = grpP)
bandM2   = input.float(2.0, "Outer Band (σ)", step = 0.25, minval = 0.5, group = grpP)

grpC = "Confluence Clusters"
showClus = input.bool(true, "Highlight Cluster Zones", group = grpC)
clusTol  = input.float(0.5, "Cluster Tolerance (Average True Range Ratio)", step = 0.1, minval = 0.1, group = grpC)

grpX = "Signals"
showSigs = input.bool(true, "Show Band Rejection Signals", group = grpX)
sigCool  = input.int(8, "Signal Cooldown (Bars)", minval = 1, maxval = 50, group = grpX)
keepSigs = input.int(8, "Signals To Keep", minval = 2, maxval = 30, group = grpX)

grpV = "Chart Visuals"
cSes = input.color(#d99b1e, "Session", group = grpV)
cWk  = input.color(#3b82f6, "Week", group = grpV)
cMo  = input.color(#8b5cf6, "Month", group = grpV)
cSH  = input.color(#e8365f, "Swing High", group = grpV)
cSL  = input.color(#00a89d, "Swing Low", group = grpV)
cHV  = input.color(#d97706, "Highest Volume", group = grpV)
cSw  = input.color(#0ea5e9, "Sweep", group = grpV)
silvCol = input.color(#5c6b80, "Neutral", group = grpV)
goldCol = input.color(#d99b1e, "Accent", group = grpV)

grpB = "Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = grpB)
dashPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpB)
dashSize    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpB)
dashTitleBg = input.color(color.new(#231a08, 0), "Title Band", group = grpB)
dashBg      = input.color(color.new(#171207, 8), "Background", group = grpB)
dashFrame   = input.color(color.new(#d99b1e, 15), "Frame", group = grpB)
dashGrid    = input.color(color.new(#d99b1e, 80), "Grid", group = grpB)
dashHeadTxt = input.color(color.new(#f0c05a, 0), "Header Text", group = grpB)
dashBodyTxt = input.color(color.new(#eef2f7, 5), "Body Text", group = grpB)
dashMuteTxt = input.color(color.new(#cdb87e, 15), "Muted Text", group = grpB)

// ════════════════════════════════════════════════════════════════
//  SHARED SERIES
// ════════════════════════════════════════════════════════════════
atr = ta.atr(14)
src = hlc3
hvTop = ta.highest(volume, hvLB)

f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out

// ════════════════════════════════════════════════════════════════
//  ANCHOR EVENTS
// ════════════════════════════════════════════════════════════════
newSes = timeframe.change("D")
newWk  = timeframe.change("W")
newMo  = timeframe.change("M")

ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
var float lastPH = na
var float lastPL = na
var bool  phSwept = false
var bool  plSwept = false
var int   sweepSide = 0

newSH = not na(ph)
newSL = not na(pl)
if newSH
    lastPH := ph
    phSwept := false
if newSL
    lastPL := pl
    plSwept := false

newHV = barstate.isconfirmed and not na(hvTop) and volume >= hvTop

sweepBuy  = barstate.isconfirmed and not na(lastPH) and not phSwept and high > lastPH and close < lastPH
sweepSell = barstate.isconfirmed and not na(lastPL) and not plSwept and low < lastPL and close > lastPL
if sweepBuy
    phSwept := true
    sweepSide := -1
if sweepSell
    plSwept := true
    sweepSide := 1
newSw = sweepBuy or sweepSell

// ════════════════════════════════════════════════════════════════
//  SEVEN VWAP STREAMS  ·  0 Ses · 1 Wk · 2 Mo · 3 SH · 4 SL · 5 HV · 6 Sw
// ════════════════════════════════════════════════════════════════
var array<float> sPV  = array.new<float>(7, na)
var array<float> sV   = array.new<float>(7, na)
var array<float> sPV2 = array.new<float>(7, na)
var array<float> vNow = array.new<float>(7, na)
var array<float> vPrv = array.new<float>(7, na)
var array<float> flip = array.new<float>(7, 0.0)

f_reset(int idx) =>
    sPV.set(idx, src * volume)
    sV.set(idx, volume)
    sPV2.set(idx, src * src * volume)

f_rebuild(int idx, int back) =>
    float pv = 0.0
    float vv = 0.0
    float p2 = 0.0
    for b = 0 to back
        s_ = hlc3[b]
        v_ = volume[b]
        pv += s_ * v_
        vv += v_
        p2 += s_ * s_ * v_
    sPV.set(idx, pv)
    sV.set(idx, vv)
    sPV2.set(idx, p2)

f_accum(int idx) =>
    sPV.set(idx, nz(sPV.get(idx)) + src * volume)
    sV.set(idx, nz(sV.get(idx)) + volume)
    sPV2.set(idx, nz(sPV2.get(idx)) + src * src * volume)

resets = array.from(newSes, newWk, newMo, false, false, newHV, newSw)
for i = 0 to 6
    vPrv.set(i, vNow.get(i))
    if resets.get(i) or na(sV.get(i))
        f_reset(i)
    else
        f_accum(i)
// pivot anchors rebuild retroactively from the confirmed swing bar
if newSH
    f_rebuild(3, pivLen)
if newSL
    f_rebuild(4, pivLen)
for i = 0 to 6
    vNow.set(i, sV.get(i) > 0 ? sPV.get(i) / sV.get(i) : na)
    // stability: exponentially decayed crossing rate (lower = more respected)
    crossed = not na(vNow.get(i)) and not na(vPrv.get(i)) and (close - vNow.get(i)) * (close[1] - vPrv.get(i)) < 0
    flip.set(i, flip.get(i) * 0.95 + (crossed ? 0.05 : 0.0))

enArr = array.from(useSes, useWk, useMo, useSH, useSL, useHV, useSw)
v0 = enArr.get(0) ? vNow.get(0) : na
v1 = enArr.get(1) ? vNow.get(1) : na
v2 = enArr.get(2) ? vNow.get(2) : na
v3 = enArr.get(3) ? vNow.get(3) : na
v4 = enArr.get(4) ? vNow.get(4) : na
v5 = enArr.get(5) ? vNow.get(5) : na
v6 = enArr.get(6) ? vNow.get(6) : na

plot(v0, "Session Anchored VWAP", color = color.new(cSes, 0), linewidth = 2)
plot(v1, "Week Anchored VWAP", color = color.new(cWk, 15))
plot(v2, "Month Anchored VWAP", color = color.new(cMo, 15))
plot(v3, "Swing High Anchored VWAP", color = color.new(cSH, 10))
plot(v4, "Swing Low Anchored VWAP", color = color.new(cSL, 10))
plot(v5, "Highest Volume Anchored VWAP", color = color.new(cHV, 15))
plot(v6, "Sweep Anchored VWAP", color = sweepSide == 1 ? color.new(cSL, 0) : sweepSide == -1 ? color.new(cSH, 0) : color.new(cSw, 10), linewidth = 2)

// ════════════════════════════════════════════════════════════════
//  PRIMARY STREAM + DEVIATION BANDS
// ════════════════════════════════════════════════════════════════
pIdx = primS == "Week Open" ? 1 : primS == "Month Open" ? 2 : primS == "Swing High" ? 3 : primS == "Swing Low" ? 4 : primS == "Highest Volume Bar" ? 5 : primS == "Liquidity Sweep" ? 6 : 0
pV   = vNow.get(pIdx)
pOn  = enArr.get(pIdx) and not na(pV)
sig  = pOn and sV.get(pIdx) > 0 ? math.sqrt(math.max(sPV2.get(pIdx) / sV.get(pIdx) - pV * pV, 0.0)) : na

u1 = showBand and pOn ? pV + sig * bandM1 : na
d1 = showBand and pOn ? pV - sig * bandM1 : na
u2 = showBand and pOn ? pV + sig * bandM2 : na
d2 = showBand and pOn ? pV - sig * bandM2 : na

pU1 = plot(u1, "Inner Band Upper", color = color.new(silvCol, 65))
pD1 = plot(d1, "Inner Band Lower", color = color.new(silvCol, 65))
pU2 = plot(u2, "Outer Band Upper", color = color.new(silvCol, 55))
pD2 = plot(d2, "Outer Band Lower", color = color.new(silvCol, 55))
fill(pU1, pU2, color = color.new(#e8365f, 93), title = "Upper Band Zone")
fill(pD1, pD2, color = color.new(#00a89d, 93), title = "Lower Band Zone")

// ════════════════════════════════════════════════════════════════
//  BAND REJECTION SIGNALS  ·  σ with tooltip, cooled down
// ════════════════════════════════════════════════════════════════
var array<label> sigLbs = array.new<label>()
var int lastSigBar = -10000
bool evRejBull = false
bool evRejBear = false

if barstate.isconfirmed and showSigs and pOn and not na(u2) and bar_index - lastSigBar >= sigCool
    if low <= d2 and close > d2 and close < pV
        evRejBull := true
        lastSigBar := bar_index
        sigLbs.push(label.new(bar_index, low, "σ", style = label.style_label_up, color = color.new(#00a89d, 0), textcolor = #06222b, size = size.small, tooltip = "Outer band rejection ▲ · price rejected the -" + str.tostring(bandM2, "#.##") + "σ band of the " + primS + " anchored VWAP · reversion bias toward VWAP"))
    else if high >= u2 and close < u2 and close > pV
        evRejBear := true
        lastSigBar := bar_index
        sigLbs.push(label.new(bar_index, high, "σ", style = label.style_label_down, color = color.new(#e8365f, 0), textcolor = #2b0612, size = size.small, tooltip = "Outer band rejection ▼ · price rejected the +" + str.tostring(bandM2, "#.##") + "σ band of the " + primS + " anchored VWAP · reversion bias toward VWAP"))
while sigLbs.size() > keepSigs
    label.delete(sigLbs.shift())

// ════════════════════════════════════════════════════════════════
//  CONFLUENCE CLUSTERS
// ════════════════════════════════════════════════════════════════
var array<box>   clB = array.new<box>()
var array<label> clT = array.new<label>()
int clusN = 0
bool evCluster = false
var bool hadCluster = false

while clB.size() > 0
    box.delete(clB.shift())
while clT.size() > 0
    label.delete(clT.shift())

if showClus and barstate.islast
    array<float> vals = array.new<float>()
    for i = 0 to 6
        if enArr.get(i) and not na(vNow.get(i))
            vals.push(vNow.get(i))
    array<bool> used = array.new<bool>(vals.size(), false)
    if vals.size() > 1
        for i = 0 to vals.size() - 2
            if not used.get(i)
                float lo_ = vals.get(i)
                float hi_ = vals.get(i)
                int cnt = 1
                for j = i + 1 to vals.size() - 1
                    if not used.get(j) and math.abs(vals.get(j) - vals.get(i)) <= atr * clusTol
                        used.set(j, true)
                        cnt += 1
                        lo_ := math.min(lo_, vals.get(j))
                        hi_ := math.max(hi_, vals.get(j))
                if cnt >= 2
                    clusN += 1
                    clB.push(box.new(bar_index - 3, hi_ + atr * 0.1, bar_index + 8, lo_ - atr * 0.1, border_color = color.new(goldCol, 20), bgcolor = color.new(goldCol, 84)))
                    clT.push(label.new(bar_index + 8, (hi_ + lo_) / 2, "Cluster ×" + str.tostring(cnt), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(goldCol, 0), size = size.small))
evCluster := clusN > 0 and not hadCluster
hadCluster := clusN > 0

// ════════════════════════════════════════════════════════════════
//  PREMIUM DASHBOARD
// ════════════════════════════════════════════════════════════════
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small

var table tb = table.new(dPos, 2, 11, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1)

if showDash and barstate.islast
    nmD = array.from("Session", "Week", "Month", "Swing High", "Swing Low", "High Volume", "Sweep")
    // in control: lowest crossing rate among enabled streams within 5 ATR
    int ctrl = -1
    float best = 1e10
    for i = 0 to 6
        if enArr.get(i) and not na(vNow.get(i)) and math.abs(close - vNow.get(i)) <= atr * 5
            if flip.get(i) < best
                best := flip.get(i)
                ctrl := i
    table.cell(tb, 0, 0, "◈ ANCHORED VWAP", bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 0, f_rep("◆", math.min(4, clusN * 2)), bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = bodySize)
    for i = 0 to 6
        on = enArr.get(i) and not na(vNow.get(i))
        d  = on ? math.abs(close - vNow.get(i)) / atr : na
        ab = on and close > vNow.get(i)
        table.cell(tb, 0, 1 + i, nmD.get(i), text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
        table.cell(tb, 1, 1 + i, not on ? "Off" : str.tostring(d, "#.0") + " ATR " + (ab ? "▲" : "▼"), text_color = not on ? color.new(#5c6b80, 55) : ab ? #00a89d : #e8365f, text_size = bodySize)
    table.cell(tb, 0, 8, "In Control", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 8, ctrl >= 0 ? nmD.get(ctrl) : "—", text_color = ctrl >= 0 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 9, "Clusters", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 9, str.tostring(clusN), text_color = clusN > 0 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 10, "Band Width", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 10, pOn and not na(sig) ? "±" + str.tostring(sig * bandM2 / atr, "#.0") + " ATR" : "—", text_color = dashBodyTxt, text_size = bodySize)

// ════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════
alertcondition(evRejBull, "Bullish Band Rejection", "Price rejected the lower outer deviation band of the primary anchored VWAP.")
alertcondition(evRejBear, "Bearish Band Rejection", "Price rejected the upper outer deviation band of the primary anchored VWAP.")
alertcondition(ta.crossover(close, pV), "Price Crossed Above Primary VWAP", "Price crossed above the primary anchored VWAP.")
alertcondition(ta.crossunder(close, pV), "Price Crossed Below Primary VWAP", "Price crossed below the primary anchored VWAP.")
alertcondition(evCluster, "VWAP Cluster Formed", "Two or more anchored VWAP streams converged into a confluence cluster.")
alertcondition(newSw, "Sweep Anchor Reset", "A liquidity sweep occurred and the sweep anchored VWAP re-anchored from the stop-run bar.")
````
