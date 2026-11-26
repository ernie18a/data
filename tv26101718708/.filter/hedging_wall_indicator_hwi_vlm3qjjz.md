# Hedging Wall Indicator [HWI]

- url: https://www.tradingview.com/script/VlM3qjJZ-Hedging-Wall-Indicator-HWI/
- type: indicator
- pine_id: PUB;6fc2e67a54924f52956c300925d1dc3a
- version: 1.0

## Description

The Hedging Wall Indicator plots the price levels where hedging flows, resting liquidity and options positioning tend to concentrate. Traders often watch these zones for pinning, rejection, bounce, breakout and acceleration. It combines five layers on one chart:

Manual options walls: Call Wall, Put Wall, Gamma Flip, Max Pain
Automatic volume walls: high-volume nodes (HVN) from a volume profile, plus POC / VAH / VAL
Automatic pivot liquidity clusters: levels rejected repeatedly
Strike grid: round-number strikes that often act as magnets
Confluence (★), nearest-wall tracking, ATR distance, flow bias, regime proxy, dashboard and alerts
⚙️ How it works

1) Volume walls (auto)
The script builds a volume profile over the last N bars (default 300) split into rows (default 48). Each bar’s volume is spread across the rows its high-low range touched. A row becomes a wall when it is a local peak and its volume exceeds the average row volume × the HVN threshold (default 1.6×).

Walls above price are drawn red (R, resistance). Walls below price are drawn green (S, support).
The label shows the price and strength (for example ×2.4 means 2.4× average row volume).
It also plots POC (highest-volume price), VAH and VAL (a 70% value area), and an optional profile histogram on the right.
If a symbol has no volume data, it falls back to time-at-price.

2) Pivot liquidity clusters (auto)
Pivot highs and lows are stored and grouped when they fall within a tolerance (default 0.35 × ATR). A cluster needs a minimum number of touches (default 3). The label P×4 means four pivots clustered at that price. These are levels the market has repeatedly respected.

3) Manual options walls
Enter values in the settings. A value of 0 turns that level off.

Call Wall: strike with the largest call open interest or gamma (resistance).
Put Wall: strike with the largest put open interest or gamma (support).
Gamma Flip: above it, dealers are typically long gamma (moves dampen, mean reversion). Below it, they are short gamma (moves can amplify).
Max Pain: strike where option holders lose the most, often a magnet near expiry.

4) Strike grid
Dotted lines at round-number strikes above and below price. The step is automatic (based on price) or user-defined.

5) Confluence ★
When a volume wall lines up with a pivot cluster, the wall gets a ★ and a thicker line. These are the highest-priority levels on the chart.

6) Flow bias
A close-location-value delta proxy, averaged over a set length and shown from -100% to +100%. It estimates buy or sell pressure from where each bar closes within its range. It is not true order flow or footprint data.

7) Regime

If Gamma Flip is set: price above it shows Positive Γ (pin / mean-revert) and price below it shows Negative Γ (expand / momentum).
If not set: it falls back to an ATR compression / expansion proxy.

 How to use it (step by step)
Use a futures chart with real volume (for example ES1!, NQ1!, GC1!, CL1!) on a 5m to 1h timeframe for intraday, or 4h to D for swing context.
Enter your options levels (Call Wall, Put Wall, Gamma Flip, Max Pain) in the settings from your data provider. Update them every day or whenever the data changes. The lines are static horizontals and do not update themselves.
Match the futures price. If your options data is quoted for the index or ETF (SPX, SPY, QQQ), convert it to the futures price (add the basis) before typing it in. A wrong basis is the most common reason levels look off.
Identify high-priority zones. Start with ★ confluence walls and any wall that coincides with a manual options level.
Read the dashboard:
Wall ↑ / Wall ↓: nearest levels and their distance in ATR
Position: where price sits between the two walls (% of range)
Regime and Flow bias: the context
Signal: the current reading
Interpret the Signal field:
Between walls (range): price is far from levels, so range logic is more likely.
Rejection risk at wall ↑ / Bounce risk at wall ↓: price is near a wall with no flow confirmation.
Breakout attempt ↑ / Breakdown attempt ↓: price is near a wall and flow is pushing through it.
Confirm with your own strategy (market structure, order flow, session levels, risk rules) before acting. HWI is context, not a trigger.

 Tips for best performance
Keep Lookback large enough to cover the current swing or session, but not so large that old, irrelevant volume dominates.
Raise the HVN threshold (2.0+) for cleaner, fewer walls. Lower it to see more.
Raise Min touches or the Pivot length for stronger, rarer pivot clusters.
Positive-gamma conditions tend to favor fade or mean-reversion logic, and negative-gamma conditions favor momentum logic. Treat this as a bias, not a rule.
Near options expiry (0DTE, weekly, monthly), Max Pain and strike levels tend to matter more.
Combine ★ confluence walls with your own stop placement. A wall is a zone, not an exact tick.
Reduce clutter by turning off the histogram, the grid or the pivot layer.
🔔 Alerts and signals

Alert conditions available:

HWI: Break above wall: price closed above the nearest wall.
HWI: Break below wall: price closed below the nearest wall.
HWI: Rejection at wall ↑: price wicked into the wall above and closed back below.
HWI: Bounce at wall ↓: price wicked into the wall below and closed back above.

Chart markers: ▲ break up, ▼ break down, ✖ rejection and bounce.

 Limitations (please read)
Walls are calculated on the last bar only. The indicator does not keep a history of where walls were on past bars.
Because of this, break/rejection signals and alerts only work on live (realtime) bars. They will not appear on historical bars, and this is not a bug.
Auto walls (volume and pivot) shift as the lookback window rolls forward and as new data arrives.
Manual options levels are only as accurate as the data you type in.
Flow bias and regime are proxies, not real dealer positioning or order-flow data.
Results vary by symbol, timeframe and data feed. 

READ FIRST: Disclaimer
HWI is designed for FUTURES markets with real futures volume (for example ES/MES, NQ/MNQ, YM, RTY, GC, CL, and CME crypto futures). It is built around futures price levels and futures-style volume.
Do NOT rely on it on CFDs, spot forex or spot crypto. Their volume is usually tick volume or broker-specific, not real centralized volume. This distorts the volume profile, the volume walls, POC/VAH/VAL and the flow bias. Options-derived levels (Call Wall, Put Wall, Gamma Flip, Max Pain) also carry a basis difference between spot and futures, so they will not line up correctly.
This is NOT a holy grail. It does not predict price, it does not give guaranteed entries or exits, and it is not a complete trading system. It is a map of key levels and context that you combine with your own strategy, risk management and confirmation.
TradingView has no options-chain feed. The options levels are manual inputs that you type in from a data provider (SpotGamma, Barchart, etc.). The indicator does not verify or calculate them.
Nothing here is financial advice. Trading involves substantial risk of loss. Backtest and forward-test before using real money.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © iO_FX

//@version=6
indicator("Hedging Wall Indicator [HWI]", shorttitle="HWI", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=2000)

// ═══════════════════════════════════════════════════════════════════════════
//  HEDGING WALL INDICATOR (HWI)  –  Pine Script v6
//
//  TradingView has no options-chain feed, so this combines:
//   1) MANUAL options walls  : Call Wall / Put Wall / Gamma Flip / Max Pain
//                              (type in values from SpotGamma, Barchart, etc.)
//   2) AUTO volume walls     : High-Volume Nodes from a volume profile
//                              (+ POC / VAH / VAL)
//   3) AUTO pivot clusters   : price levels rejected repeatedly (liquidity walls)
//   4) STRIKE GRID           : round-number strikes that act as pin/magnet levels
//   5) Confluence (★), nearest wall above/below, ATR distance, flow bias,
//      gamma-regime proxy, dashboard and alerts.
// ═══════════════════════════════════════════════════════════════════════════

// ───────────────────────────── INPUTS ─────────────────────────────
G1 = "1) Volume Walls (auto)"
showVol     = input.bool(true, "Show volume walls", group=G1)
vpLookback  = input.int(300, "Lookback bars", minval=50, maxval=2000, group=G1)
vpRows      = input.int(48, "Profile rows", minval=10, maxval=120, group=G1)
hvnMult     = input.float(1.6, "HVN threshold (× avg row volume)", minval=1.0, step=0.1, group=G1)
maxVolWalls = input.int(5, "Max volume walls", minval=1, maxval=15, group=G1)
extendBars  = input.int(25, "Extend right (bars)", minval=0, maxval=200, group=G1)
showProfile = input.bool(true, "Show profile histogram", group=G1)
histWidth   = input.int(30, "Histogram width (bars)", minval=5, maxval=100, group=G1)
showVA      = input.bool(true, "Show POC / VAH / VAL", group=G1)

G2 = "2) Pivot Liquidity Clusters (auto)"
showPiv      = input.bool(true, "Show pivot clusters", group=G2)
pivLen       = input.int(10, "Pivot length", minval=2, maxval=50, group=G2)
pivTol       = input.float(0.35, "Cluster tolerance (× ATR)", minval=0.05, step=0.05, group=G2)
minTouches   = input.int(3, "Min touches", minval=2, maxval=10, group=G2)
maxPivWalls  = input.int(4, "Max pivot walls", minval=1, maxval=10, group=G2)
maxPivs      = input.int(100, "Pivots stored", minval=20, maxval=300, group=G2)

G3 = "3) Options Walls (manual – 0 = off)"
showManual = input.bool(true, "Show manual walls", group=G3)
callWall   = input.float(0.0, "Call Wall", group=G3, tooltip="Strike with the largest call open interest / gamma. Acts as resistance.")
putWall    = input.float(0.0, "Put Wall", group=G3, tooltip="Strike with the largest put open interest / gamma. Acts as support.")
gammaFlip  = input.float(0.0, "Gamma Flip", group=G3, tooltip="Above = positive gamma (dealers dampen moves). Below = negative gamma (dealers amplify moves).")
maxPain    = input.float(0.0, "Max Pain", group=G3, tooltip="Strike where option holders lose the most. Often a pin/magnet near expiry.")

G4 = "4) Strike Grid"
showGrid   = input.bool(true, "Show strike grid", group=G4)
strikeStep = input.float(0.0, "Strike step (0 = auto)", minval=0.0, group=G4)
gridCount  = input.int(3, "Strikes each side", minval=1, maxval=10, group=G4)

G5 = "5) Flow / Dashboard / Signals"
showDash = input.bool(true, "Show dashboard", group=G5)
dashPos  = input.string(position.top_right, "Dashboard position", options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left, position.middle_right], group=G5)
flowLen  = input.int(20, "Flow bias length", minval=5, maxval=200, group=G5)
atrLen   = input.int(14, "ATR length", minval=2, maxval=100, group=G5)
nearATR  = input.float(0.5, "'Near wall' distance (× ATR)", minval=0.1, step=0.1, group=G5)

G6 = "6) Colors"
cRes   = input.color(color.new(#f23645, 0), "Resistance wall", group=G6)
cSup   = input.color(color.new(#089981, 0), "Support wall", group=G6)
cPoc   = input.color(color.new(#ff9800, 0), "POC / Value area", group=G6)
cPiv   = input.color(color.new(#b388ff, 0), "Pivot cluster", group=G6)
cGrid  = input.color(color.new(#9598a1, 0), "Strike grid", group=G6)
cCall  = input.color(color.new(#d32f2f, 0), "Call Wall", group=G6)
cPut   = input.color(color.new(#2e7d32, 0), "Put Wall", group=G6)
cFlip  = input.color(color.new(#fbc02d, 0), "Gamma Flip", group=G6)
cPain  = input.color(color.new(#8e24aa, 0), "Max Pain", group=G6)

// ───────────────────────────── HELPERS ─────────────────────────────
autoStep(float p) =>
    p < 25 ? 0.5 : p < 100 ? 1.0 : p < 500 ? 5.0 : p < 2000 ? 10.0 : p < 10000 ? 50.0 : p < 50000 ? 100.0 : 500.0

// ───────────────────────────── SERIES CALCS ─────────────────────────────
float atr    = ta.atr(atrLen)
float atrAvg = ta.sma(atr, 50)
float vSrc   = nz(volume) > 0 ? volume : 1.0           // fallback: time-at-price when no volume

// Order-flow proxy (close-location-value delta): -1 … +1
float rng   = high - low
float delta = rng > 0 ? vSrc * (2 * close - high - low) / rng : 0.0
float flow  = ta.sma(delta, flowLen) / ta.sma(vSrc, flowLen)

// Pivots storage
float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)
var array<float> pivs = array.new<float>()
if not na(ph)
    pivs.push(ph)
if not na(pl)
    pivs.push(pl)
while pivs.size() > maxPivs
    pivs.shift()

// Persistent nearest walls (for alerts / dashboard)
var float upWall = na
var float dnWall = na

// Drawing handles
var array<box>   boxes = array.new<box>()
var array<line>  lns   = array.new<line>()
var array<label> lbls  = array.new<label>()

// Dashboard
var table dash = table.new(dashPos, 2, 9, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.new(color.gray, 60), frame_width=1, frame_color=color.new(color.gray, 40))

// ───────────────────────────── MANUAL WALL PLOTS ─────────────────────────────
plot(showManual and callWall  > 0 ? callWall  : na, "Call Wall",  color=cCall, linewidth=2, style=plot.style_linebr)
plot(showManual and putWall   > 0 ? putWall   : na, "Put Wall",   color=cPut,  linewidth=2, style=plot.style_linebr)
plot(showManual and gammaFlip > 0 ? gammaFlip : na, "Gamma Flip", color=cFlip, linewidth=2, style=plot.style_linebr)
plot(showManual and maxPain   > 0 ? maxPain   : na, "Max Pain",   color=cPain, linewidth=1, style=plot.style_linebr)

// ───────────────────────────── MAIN (last bar only) ─────────────────────────────
if barstate.islast
    // ---- clear old drawings
    for b in boxes
        box.delete(b)
    boxes.clear()
    for l in lns
        line.delete(l)
    lns.clear()
    for lb in lbls
        label.delete(lb)
    lbls.clear()

    int lookN = math.min(vpLookback, bar_index + 1)
    int x1    = bar_index - lookN + 1
    int x2    = bar_index + extendBars

    // ---- range of lookback
    float hiN = high
    float loN = low
    for i = 0 to lookN - 1
        hiN := math.max(hiN, high[i])
        loN := math.min(loN, low[i])

    float rowH = (hiN - loN) / vpRows
    array<float> allP = array.new_float()

    // ---- volume profile
    array<float> prof = array.new_float(vpRows, 0.0)
    if rowH > 0
        for i = 0 to lookN - 1
            float h = high[i]
            float lo = low[i]
            float v = vSrc[i]
            int r1 = math.max(0, math.min(vpRows - 1, int(math.floor((lo - loN) / rowH))))
            int r2 = math.max(0, math.min(vpRows - 1, int(math.floor((h - loN) / rowH))))
            float share = v / (r2 - r1 + 1)
            for r = r1 to r2
                prof.set(r, prof.get(r) + share)

        float total  = prof.sum()
        float avgRow = total / vpRows
        float maxV   = prof.max()
        int pocIdx   = prof.indexof(maxV)

        // ---- value area (70%)
        int lowI  = pocIdx
        int highI = pocIdx
        float acc = prof.get(pocIdx)
        while acc < total * 0.7 and (lowI > 0 or highI < vpRows - 1)
            float below = lowI > 0 ? prof.get(lowI - 1) : -1.0
            float above = highI < vpRows - 1 ? prof.get(highI + 1) : -1.0
            if above >= below
                highI += 1
                acc += above
            else
                lowI -= 1
                acc += below

        float pocP = loN + (pocIdx + 0.5) * rowH
        float vahP = loN + (highI + 1) * rowH
        float valP = loN + lowI * rowH

        if showVA
            lns.push(line.new(x1, pocP, x2, pocP, color=cPoc, width=2))
            lns.push(line.new(x1, vahP, x2, vahP, color=color.new(cPoc, 30), style=line.style_dashed))
            lns.push(line.new(x1, valP, x2, valP, color=color.new(cPoc, 30), style=line.style_dashed))
            lbls.push(label.new(x2, pocP, "POC " + str.tostring(pocP, format.mintick), style=label.style_label_left, color=cPoc, textcolor=color.white, size=size.small))
            lbls.push(label.new(x2, vahP, "VAH", style=label.style_label_left, color=color.new(cPoc, 40), textcolor=color.white, size=size.tiny))
            lbls.push(label.new(x2, valP, "VAL", style=label.style_label_left, color=color.new(cPoc, 40), textcolor=color.white, size=size.tiny))
            allP.push(pocP)

        // ---- profile histogram
        if showProfile
            for k = 0 to vpRows - 1
                int len = math.max(1, int(math.round(prof.get(k) / maxV * histWidth)))
                bool inVA = k >= lowI and k <= highI
                color hc = k == pocIdx ? color.new(cPoc, 35) : inVA ? color.new(color.blue, 70) : color.new(color.gray, 80)
                int hx = bar_index + extendBars + 3
                boxes.push(box.new(hx, loN + (k + 1) * rowH, hx + len, loN + k * rowH, border_color=na, bgcolor=hc))

        // ---- pivot clusters
        float tol = nz(atr) * pivTol
        array<float> pcP = array.new_float()
        array<float> pcN = array.new_float()
        int np = pivs.size()
        if showPiv and np > 0 and tol > 0
            array<float> cnt = array.new_float(np, 0.0)
            for i = 0 to np - 1
                for j = 0 to np - 1
                    if math.abs(pivs.get(i) - pivs.get(j)) <= tol
                        cnt.set(i, cnt.get(i) + 1)
            array<int> pord = cnt.sort_indices(order.descending)
            for ii in pord
                if pcP.size() >= maxPivWalls
                    break
                if cnt.get(ii) >= minTouches
                    float p0 = pivs.get(ii)
                    bool dup = false
                    for q in pcP
                        if math.abs(q - p0) <= tol * 2
                            dup := true
                    if not dup
                        float sSum = 0.0
                        float sCnt = 0.0
                        for j = 0 to np - 1
                            if math.abs(pivs.get(j) - p0) <= tol
                                sSum += pivs.get(j)
                                sCnt += 1
                        pcP.push(sSum / sCnt)
                        pcN.push(sCnt)
            if pcP.size() > 0
                for n = 0 to pcP.size() - 1
                    float pp = pcP.get(n)
                    lns.push(line.new(x1, pp, x2, pp, color=color.new(cPiv, 10), width=1, style=line.style_dashed))
                    lbls.push(label.new(x2, pp, "P×" + str.tostring(pcN.get(n), "#") + " " + str.tostring(pp, format.mintick), style=label.style_label_left, color=color.new(cPiv, 30), textcolor=color.white, size=size.tiny))
                    allP.push(pp)

        // ---- volume walls (HVN peaks)
        if showVol
            array<float> vwP = array.new_float()
            array<float> vwS = array.new_float()
            for k = 0 to vpRows - 1
                float v0 = prof.get(k)
                float vm = k > 0 ? prof.get(k - 1) : 0.0
                float vn = k < vpRows - 1 ? prof.get(k + 1) : 0.0
                if v0 > avgRow * hvnMult and v0 > vm and v0 >= vn
                    vwP.push(loN + (k + 0.5) * rowH)
                    vwS.push(v0 / avgRow)
            int shown = math.min(maxVolWalls, vwP.size())
            if shown > 0
                array<int> ord = vwS.sort_indices(order.descending)
                for n = 0 to shown - 1
                    int ix   = ord.get(n)
                    float p  = vwP.get(ix)
                    float st = vwS.get(ix)
                    bool isRes = p > close
                    color baseC = isRes ? cRes : cSup
                    float half  = math.max(rowH, nz(atr) * 0.15) / 2
                    bool conf = false
                    for q in pcP
                        if math.abs(q - p) <= tol + rowH
                            conf := true
                    int tr = 88 - int(math.min(st / 4.0, 1.0) * 38)
                    boxes.push(box.new(x1, p + half, x2, p - half, border_color=na, bgcolor=color.new(baseC, tr)))
                    lns.push(line.new(x1, p, x2, p, color=color.new(baseC, 15), width=conf ? 2 : 1))
                    lbls.push(label.new(x2, p, (conf ? "★ " : "") + (isRes ? "R " : "S ") + str.tostring(p, format.mintick) + "  ×" + str.tostring(st, "#.#"), style=label.style_label_left, color=baseC, textcolor=color.white, size=size.small))
                    allP.push(p)

    // ---- manual options walls (labels + nearest-wall list)
    array<float>  mP = array.from(callWall, putWall, gammaFlip, maxPain)
    array<string> mT = array.from("Call Wall", "Put Wall", "Gamma Flip", "Max Pain")
    array<color>  mC = array.from(cCall, cPut, cFlip, cPain)
    if showManual
        for m = 0 to 3
            float mv = mP.get(m)
            if mv > 0
                lbls.push(label.new(bar_index, mv, mT.get(m) + " " + str.tostring(mv, format.mintick), style=label.style_label_right, color=mC.get(m), textcolor=color.white, size=size.small))
                allP.push(mv)

    // ---- strike grid
    float step = strikeStep > 0 ? strikeStep : autoStep(close)
    float base = math.floor(close / step) * step
    if showGrid
        for g = 1 to gridCount
            float dnS = base - (g - 1) * step
            float upS = base + g * step
            lns.push(line.new(bar_index - 60, dnS, x2, dnS, color=color.new(cGrid, 60), style=line.style_dotted))
            lns.push(line.new(bar_index - 60, upS, x2, upS, color=color.new(cGrid, 60), style=line.style_dotted))

    // ---- nearest walls above / below
    float up = na
    float dn = na
    for pr in allP
        if pr > close and (na(up) or pr < up)
            up := pr
        if pr <= close and (na(dn) or pr > dn)
            dn := pr
    upWall := up
    dnWall := dn

    // ---- dashboard
    if showDash
        bool compress = atr < atrAvg
        string regime = ""
        color regC = color.gray
        if gammaFlip > 0
            if close >= gammaFlip
                regime := "Positive Γ (pin / mean-revert)"
                regC := color.new(#089981, 0)
            else
                regime := "Negative Γ (expand / momentum)"
                regC := color.new(#f23645, 0)
        else
            regime := compress ? "Compression (pin-like)" : "Expansion (trend-like)"
            regC := compress ? color.new(#089981, 0) : color.new(#ff9800, 0)

        string flowTxt = (flow > 0 ? "+" : "") + str.tostring(flow * 100, "#.0") + "%  " + (flow > 0.15 ? "Buy pressure" : flow < -0.15 ? "Sell pressure" : "Balanced")
        color flowC = flow > 0.15 ? color.new(#089981, 0) : flow < -0.15 ? color.new(#f23645, 0) : color.gray

        float dUp = (not na(up) and atr > 0) ? (up - close) / atr : na
        float dDn = (not na(dn) and atr > 0) ? (close - dn) / atr : na
        string upTxt = na(up) ? "—" : str.tostring(up, format.mintick) + "  (" + str.tostring(dUp, "#.0") + " ATR)"
        string dnTxt = na(dn) ? "—" : str.tostring(dn, format.mintick) + "  (" + str.tostring(dDn, "#.0") + " ATR)"
        string posTxt = (na(up) or na(dn)) ? "—" : str.tostring((close - dn) / (up - dn) * 100, "#") + "% of range"

        string sig = "Between walls (range)"
        color sigC = color.gray
        bool nearUp = not na(dUp) and dUp <= nearATR
        bool nearDn = not na(dDn) and dDn <= nearATR
        if nearUp
            if flow > 0.15
                sig := "Breakout attempt ↑"
                sigC := color.new(#fbc02d, 0)
            else
                sig := "Rejection risk at wall ↑"
                sigC := color.new(#f23645, 0)
        else if nearDn
            if flow < -0.15
                sig := "Breakdown attempt ↓"
                sigC := color.new(#ff9800, 0)
            else
                sig := "Bounce risk at wall ↓"
                sigC := color.new(#089981, 0)

        table.cell(dash, 0, 0, "HWI", text_color=color.white, text_halign=text.align_left, text_size=size.small, bgcolor=color.new(color.gray, 40))
        table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color=color.white, text_halign=text.align_left, text_size=size.small, bgcolor=color.new(color.gray, 40))
        table.cell(dash, 0, 1, "Regime", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 1, regime, text_color=regC, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 0, 2, "Flow bias", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 2, flowTxt, text_color=flowC, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 0, 3, "Wall ↑", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 3, upTxt, text_color=cRes, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 0, 4, "Wall ↓", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 4, dnTxt, text_color=cSup, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 0, 5, "Position", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 5, posTxt, text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 0, 6, "Nearest strike", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 6, str.tostring(math.round(close / step) * step, format.mintick) + "  (step " + str.tostring(step) + ")", text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 0, 7, "ATR", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 7, str.tostring(atr, format.mintick) + (compress ? "  (below avg)" : "  (above avg)"), text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 0, 8, "Signal", text_color=color.silver, text_halign=text.align_left, text_size=size.small)
        table.cell(dash, 1, 8, sig, text_color=sigC, text_halign=text.align_left, text_size=size.small)

// ───────────────────────────── SIGNALS & ALERTS ─────────────────────────────
// Walls are recomputed every tick on the live bar, so events compare against the
// walls as they stood at the previous bar's close.
bool brkUp = not na(upWall[1]) and close > upWall[1] and close[1] <= upWall[1]
bool brkDn = not na(dnWall[1]) and close < dnWall[1] and close[1] >= dnWall[1]
bool rejUp = not na(upWall[1]) and high >= upWall[1] and close < upWall[1]
bool rejDn = not na(dnWall[1]) and low <= dnWall[1] and close > dnWall[1]

plotshape(brkUp, "Break ↑", shape.triangleup,   location.belowbar, color.new(#fbc02d, 0), size=size.tiny)
plotshape(brkDn, "Break ↓", shape.triangledown, location.abovebar, color.new(#ff9800, 0), size=size.tiny)
plotshape(rejUp, "Reject ↓ at wall", shape.xcross, location.abovebar, color.new(#f23645, 0), size=size.tiny)
plotshape(rejDn, "Bounce ↑ at wall", shape.xcross, location.belowbar, color.new(#089981, 0), size=size.tiny)

alertcondition(brkUp, "HWI: Break above wall", "Price closed above the nearest hedging wall (resistance)")
alertcondition(brkDn, "HWI: Break below wall", "Price closed below the nearest hedging wall (support)")
alertcondition(rejUp, "HWI: Rejection at wall ↑", "Price wicked into the wall above and closed back below")
alertcondition(rejDn, "HWI: Bounce at wall ↓", "Price wicked into the wall below and closed back above")
````
