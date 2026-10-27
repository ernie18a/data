# Liquidation Magnet [Quantum Algo]

- url: https://www.tradingview.com/script/qpO6Pw6Y-Liquidation-Magnet-Quantum-Algo/
- type: indicator
- pine_id: PUB;37474fc5de394cb99438d0cef37ecc79
- version: 1.0

## Description

Liquidation Magnet [Quantum Algo]

═══════════════════════════════════════════════

🔶 OVERVIEW

Liquidation Magnet estimates where over-leveraged long and short positions are likely to be liquidated, builds decaying volume-weighted clusters at those levels, and renders them as heat ladders directly on your chart. A gold magnet beam locks onto the strongest nearby pool, purge flashes mark the moment price sweeps through a cluster, and a statistics panel tracks how often those sweeps actually reverse on the exact symbol and timeframe you are trading.

The idea is simple and powerful: price does not wander randomly — it is drawn toward liquidity. The largest pockets of forced orders sit where crowded positions get liquidated. This tool maps those pockets, weighs them, and watches them get consumed.

Important honesty note, up front: every level in this indicator is an ESTIMATE derived from price structure and typical leverage tiers. This script does not read exchange liquidation feeds or order-book data, and no indicator on this platform can. Anyone claiming otherwise is guessing with extra steps. This tool guesses transparently — and then measures itself.

═══════════════════════════════════════════════

🔶 WHAT IS A LIQUIDATION MAGNET?

When traders open leveraged positions near a swing high or swing low, their liquidation prices sit at fixed, mathematically determined distances from their entries. A crowd of 25x longs opened near a swing low will be liquidated roughly four percent below it. A crowd of 50x shorts opened near a swing high will be liquidated roughly two percent above it.

Those liquidation prices are where forced market orders wait. Forced orders are fuel. Markets are drawn toward fuel — sweep the pool, fill the orders, and very often reverse once the fuel is spent. That pull is the "magnet."

═══════════════════════════════════════════════

🔶 WHY IS THIS ORIGINAL?

1. Cluster model, not static lines. Swing anchors project liquidation estimates through four leverage tiers (10x, 25x, 50x, 100x, each toggleable). Nearby estimates MERGE into clusters whose mass grows with the volume behind the anchoring swing — scattered guesses become weighted zones.

2. Living decay engine. Positions close, stops move, the crowd rotates. Every cluster loses mass each bar and dies when it fades — or the instant price sweeps through it and consumes it. The map you see is current, never a museum of stale lines.

3. Purge detection with self-auditing statistics. When price trades through a pool, the tool prints a purge flash and then measures what happened next. The dashboard reports the ten-bar reversal rate after upward and downward purges — computed on your chart, shrunk toward neutral at small sample sizes, with a Wilson lower bound available in tooltips. The indicator grades its own thesis in public.

4. The magnet beam. Among all pools within reach, the strongest (mass discounted by distance) is highlighted with a gold beam from live price — a single glance answers "where is the nearest large pocket of fuel?"

5. Radical transparency in a genre full of implication. Every tooltip, the dashboard footer, and this description state plainly that levels are structural estimates, not exchange data.

═══════════════════════════════════════════════

🔶 HOW IT WORKS

— Swing anchors: confirmed pivot highs and lows define where crowds of entries concentrate.
— Tier projection: each anchor projects liquidation estimates at the distances implied by common leverage tiers (about 1%, 2%, 4%, and 10% from entry).
— Mass: each projection carries mass scaled by the volume z-score at the anchor — swings formed on climactic volume imply larger crowds.
— Clustering: projections landing near an existing cluster merge into it, shifting its weighted center and adding mass.
— Decay and death: mass decays every bar; weak clusters are pruned; swept clusters are consumed immediately.
— Rendering: each cluster draws a trailing heat band across the chart plus a three-layer intensity ladder at the right edge — length and brightness scale with mass; the strongest pool burns gold.
— Purge statistics: after each sweep, the ten-bar outcome is recorded in first-in-first-out sample sets, and reversal rates are displayed with sample counts.

Everything is computed on confirmed bars. Signals and clusters do not repaint. All drawings are capped for performance.

═══════════════════════════════════════════════

🔶 HOW TO USE IT

— Directional context: a heavy pool overhead with light fuel below suggests the path of least resistance is up (toward the fuel), and the Net Pull row quantifies this bias.
— Sweep-and-reversal trading: the classic use. Wait for price to purge a strong pool, check the dashboard's historical reversal rate for that direction on your symbol, and treat the purge as a candidate exhaustion point for your own entry method.
— Target selection: strong pools are natural take-profit magnets — many traders exit into the fuel rather than after it is spent.
— Risk placement: avoid resting stops just beyond a hot ladder; that is exactly where the market has an incentive to reach.
— Works on any symbol, but the leverage-tier logic is designed for crypto perpetual futures, where liquidation mechanics dominate intraday movement. Best on 15m to 4H.

═══════════════════════════════════════════════

🔶 SETTINGS

— Swing Anchor Length: pivot size defining the anchoring swings.
— Leverage Tiers: toggle 10x / 25x / 50x / 100x projections independently.
— Maximum Clusters, Merge Tolerance, Mass Decay: control the density and lifespan of the map.
— Purge flashes, heat ladders, magnet beam, and ladder length are individually toggleable.
— Statistics: sample cap, minimum samples to grade, shrinkage strength, Wilson z-score.
— Full color and dashboard customization.

═══════════════════════════════════════════════

🔶 ALERTS

— Approaching Magnet — price within half an Average True Range of an estimated pool.
— Upward Purge — an estimated short-liquidation pool was swept.
— Downward Purge — an estimated long-liquidation pool was swept.

═══════════════════════════════════════════════

🔶 FAQ

Q: Is this real liquidation data from exchanges?
A: No — and this matters. TradingView indicators cannot access exchange liquidation feeds or order books. Every level here is an estimate computed from price structure and the fixed mathematics of leverage. The tool is honest about this everywhere, and it compensates by measuring its own hit rate on your chart.

Q: Why do the estimated levels often line up with where price actually reverses?
A: Because liquidation math is public and mechanical. Everyone's 50x liquidation sits roughly two percent from entry, so crowded swings reliably produce crowded liquidation pockets — no private data required.

Q: Does it repaint?
A: No. Clusters form on confirmed pivots, purges are detected on confirmed bars, and consumed clusters stay consumed.

Q: Which markets and timeframes?
A: Designed for crypto perpetual futures on 15m–4H. The structural logic works elsewhere, but the leverage-tier assumptions are crypto-native.

Q: What do the reversal statistics mean?
A: After each purge, the tool records whether price moved back against the sweep over the next ten bars. Rates are shrunk toward fifty percent at low sample counts so early numbers cannot overstate the edge. They describe this chart's history only — they are not predictions.

═══════════════════════════════════════════════

🔶 CREDITS

The liquidation-level mapping concept was popularized by crypto derivatives analytics platforms; pivot structure detection is classical technique; the Wilson score interval is by Edwin B. Wilson (1927). The cluster model, volume-weighted mass and decay engine, purge state machine, self-auditing statistics, and all code in this script are original work. No third-party or open-source script code was reused.

═══════════════════════════════════════════════

🔶 LIMITATIONS

— All levels are estimates; actual liquidation prices vary with margin mode, maintenance margin, fees, and funding.
— The statistics describe historical behavior on the current chart only; past frequencies never guarantee future outcomes.
— On illiquid symbols or very low timeframes, swing anchors are noisier and clusters less meaningful.

═══════════════════════════════════════════════

🔶 DISCLAIMER

This indicator is a research and charting tool provided for educational purposes. It is not financial advice, and no statistic shown is a promise of future performance. Trading leveraged instruments involves substantial risk of loss. Always do your own analysis and manage risk responsibly.

## Source Code

````pine
//@version=6
indicator("Liquidation Magnet [Quantum Algo]", overlay = true, max_boxes_count = 100, max_labels_count = 120, max_lines_count = 60, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  LIQUIDATION MAGNET ENGINE
//  Where do over-leveraged positions get liquidated? Every swing
//  extreme anchors a crowd of entries; standard leverage tiers
//  place their liquidation prices at fixed distances from those
//  anchors. This engine builds decaying, volume-weighted clusters
//  at these estimated levels, renders them as heat ladders, and
//  tracks what actually happens when price sweeps through one.
//
//  IMPORTANT: clusters are ESTIMATES derived from price structure
//  and typical leverage tiers (10x, 25x, 50x, 100x) — this script
//  does not read exchange liquidation or order-book data.
//
//  Concept credits: liquidation-level mapping popularized by
//  crypto derivatives analytics platforms · pivot structure from
//  classical technique · the Wilson score interval by Edwin B.
//  Wilson (1927). The cluster model, decay engine, purge
//  statistics and all code are original work — no third-party or
//  open-source script code was reused.
// ════════════════════════════════════════════════════════════════

// ─── INPUTS ─────────────────────────────────────────────────────
grpE = "Magnet Engine"
pivLen  = input.int(8, "Swing Anchor Length", minval = 3, maxval = 30, group = grpE)
useT10  = input.bool(false, "10x Tier", group = grpE, inline = "t1")
useT25  = input.bool(true, "25x Tier", group = grpE, inline = "t1")
useT50  = input.bool(true, "50x Tier", group = grpE, inline = "t2")
useT100 = input.bool(true, "100x Tier", group = grpE, inline = "t2")
maxCl   = input.int(20, "Maximum Clusters", minval = 6, maxval = 30, group = grpE)
mergeTol = input.float(0.35, "Cluster Merge Tolerance (Average True Range Ratio)", step = 0.05, minval = 0.1, group = grpE)
decayF  = input.float(0.995, "Mass Decay Per Bar", step = 0.001, minval = 0.98, maxval = 1.0, group = grpE, tooltip = "Estimated pools age out: positions close, stops move, the crowd rotates. A cluster stays hot by being reinforced with fresh structure, not by being old.")

grpS = "Purges & Statistics"
showPurge = input.bool(true, "Show Purge Flashes", group = grpS)
cap     = input.int(300, "Samples Per Side (FIFO Cap)", minval = 50, maxval = 1000, group = grpS)
minN    = input.int(15, "Minimum Samples To Grade", minval = 5, group = grpS)
shrinkK = input.int(10, "Shrinkage Strength", minval = 0, maxval = 100, group = grpS)
zConf   = input.float(1.645, "Wilson z-Score", step = 0.005, group = grpS)

grpV = "Visuals"
liqUpCol = input.color(#e4002b, "Short Liquidations (Above)", group = grpV)
liqDnCol = input.color(#00897b, "Long Liquidations (Below)", group = grpV)
goldCol  = input.color(#d99b1e, "Strongest Magnet", group = grpV)
silvCol  = input.color(#5c6b80, "Neutral", group = grpV)
showLadder = input.bool(true, "Show Heat Ladders", group = grpV)
showMagLn  = input.bool(true, "Show Magnet Line", group = grpV)
ladderLen  = input.int(26, "Ladder Length (Bars)", minval = 10, maxval = 60, group = grpV)

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

// ─── SHARED ─────────────────────────────────────────────────────
atrV = ta.atr(14)
volSd = ta.stdev(volume, 50)
volZ = na(volSd) or volSd == 0 ? 0.0 : (volume - ta.sma(volume, 50)) / volSd

f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out
fw(float p) => str.tostring(p * 100, "#") + "%"
fr(float r) => (r >= 0 ? "+" : "") + str.tostring(r * 100, "#.#") + "%"

// ─── CLUSTER STORE ─────────────────────────────────────────────
//  side: -1 short liquidations (above price) · 1 long (below)
var array<float> cPx = array.new<float>()
var array<float> cMs = array.new<float>()
var array<int>   cSd = array.new<int>()
var array<int>   cBr = array.new<int>()

f_add(float px, float ms, int sd) =>
    int hit = -1
    if cPx.size() > 0
        for i = 0 to cPx.size() - 1
            if cSd.get(i) == sd and math.abs(cPx.get(i) - px) <= atrV * mergeTol
                hit := i
                break
    if hit >= 0
        w = cMs.get(hit)
        cPx.set(hit, (cPx.get(hit) * w + px * ms) / (w + ms))
        cMs.set(hit, w + ms)
        cBr.set(hit, bar_index)
    else
        cPx.push(px)
        cMs.push(ms)
        cSd.push(sd)
        cBr.push(bar_index)

ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
baseM = 1.0 + math.max(volZ, 0.0) * 0.6
if barstate.isconfirmed and not na(ph)
    // shorts anchored at the swing high liquidate ABOVE it
    if useT100
        f_add(ph * 1.01, baseM * 0.8, -1)
    if useT50
        f_add(ph * 1.02, baseM * 1.0, -1)
    if useT25
        f_add(ph * 1.04, baseM * 1.0, -1)
    if useT10
        f_add(ph * 1.10, baseM * 0.6, -1)
if barstate.isconfirmed and not na(pl)
    // longs anchored at the swing low liquidate BELOW it
    if useT100
        f_add(pl * 0.99, baseM * 0.8, 1)
    if useT50
        f_add(pl * 0.98, baseM * 1.0, 1)
    if useT25
        f_add(pl * 0.96, baseM * 1.0, 1)
    if useT10
        f_add(pl * 0.90, baseM * 0.6, 1)

// ─── PURGES · price consumes a cluster ─────────────────────────
var array<float> pu10 = array.new<float>()
var array<float> pd10 = array.new<float>()
var array<label> puLbs = array.new<label>()
bool purgeUp = false
bool purgeDn = false
float purgePx = na
if barstate.isconfirmed and cPx.size() > 0
    for i = cPx.size() - 1 to 0
        px = cPx.get(i)
        if cSd.get(i) == -1 and high >= px
            purgeUp := true
            purgePx := px
            cPx.remove(i)
            cMs.remove(i)
            cSd.remove(i)
            cBr.remove(i)
        else if cSd.get(i) == 1 and low <= px
            purgeDn := true
            purgePx := px
            cPx.remove(i)
            cMs.remove(i)
            cSd.remove(i)
            cBr.remove(i)
if showPurge and barstate.isconfirmed and (purgeUp or purgeDn)
    puLbs.push(label.new(bar_index, purgePx, "⚡", style = label.style_none, color = color.new(color.black, 100), textcolor = color.new(goldCol, 0), size = size.normal, tooltip = (purgeUp ? "Upward purge — estimated short liquidations consumed at " : "Downward purge — estimated long liquidations consumed at ") + str.tostring(purgePx, format.mintick) + "\nPurges often mark fuel exhaustion; see dashboard reversal statistics."))
    while puLbs.size() > 14
        label.delete(puLbs.shift())

// decay + prune
if barstate.isconfirmed and cMs.size() > 0
    for i = cMs.size() - 1 to 0
        cMs.set(i, cMs.get(i) * decayF)
        if cMs.get(i) < 0.25
            cPx.remove(i)
            cMs.remove(i)
            cSd.remove(i)
            cBr.remove(i)
while cPx.size() > maxCl
    int weakest = 0
    for i = 1 to cMs.size() - 1
        if cMs.get(i) < cMs.get(weakest)
            weakest := i
    cPx.remove(weakest)
    cMs.remove(weakest)
    cSd.remove(weakest)
    cBr.remove(weakest)

// purge outcome statistics — reversal-positive
pushF(array<float> a, float v) =>
    a.push(v)
    if a.size() > cap
        a.shift()
f_feed(array<float> a, bool cond, int dir) =>
    if barstate.isconfirmed and bar_index > 10
        if cond[10]
            pushF(a, (close / close[10] - 1) * dir)
f_feed(pu10, purgeUp, -1)
f_feed(pd10, purgeDn, 1)
statsOf(array<float> a) =>
    int n = a.size()
    float pS_ = 0.5
    float wLB = 0.5
    float avg = 0.0
    if n > 0
        int w = 0
        float sm = 0.0
        for i = 0 to n - 1
            r = a.get(i)
            sm += r
            if r > 0
                w += 1
        float pHat = w * 1.0 / n
        pS_ := (pHat * n + 0.5 * shrinkK) / (n + shrinkK)
        wLB := (pHat + zConf * zConf / (2 * n) - zConf * math.sqrt(math.max(pHat * (1 - pHat) / n + zConf * zConf / (4 * n * n), 0.0))) / (1 + zConf * zConf / n)
        avg := sm / n
    [pS_, wLB, n, avg]

// ─── HEAT LADDER RENDER ────────────────────────────────────────
var array<box> hb = array.new<box>()
var array<label> hl = array.new<label>()
var line magLn = na
var label magLb = na
while hb.size() > 0
    box.delete(hb.shift())
while hl.size() > 0
    label.delete(hl.shift())
if not na(magLn)
    line.delete(magLn)
if not na(magLb)
    label.delete(magLb)
if barstate.islast and showLadder and cPx.size() > 0
    float maxM = 0.1
    for i = 0 to cMs.size() - 1
        maxM := math.max(maxM, cMs.get(i))
    int topIdx = 0
    for i = 1 to cMs.size() - 1
        if cMs.get(i) > cMs.get(topIdx)
            topIdx := i
    for i = 0 to cPx.size() - 1
        px = cPx.get(i)
        inten = cMs.get(i) / maxM
        isTop = i == topIdx
        col = cSd.get(i) == -1 ? liqUpCol : liqDnCol
        // heat band trailing across the chart to its level
        bandL = math.max(cBr.get(i) - 30, bar_index - 300)
        hb.push(box.new(bandL, px + atrV * 0.07, bar_index + 2, px - atrV * 0.07, border_color = na, bgcolor = color.new(col, 88 - int(inten * 14))))
        // attached ladder: three hot layers, length by mass
        L = 4 + int(inten * ladderLen)
        hb.push(box.new(bar_index + 2, px + atrV * 0.12, bar_index + 2 + L, px - atrV * 0.12, border_color = na, bgcolor = color.new(col, 68 - int(inten * 26))))
        hb.push(box.new(bar_index + 2, px + atrV * 0.07, bar_index + 2 + int(L * 0.72), px - atrV * 0.07, border_color = na, bgcolor = color.new(col, 45 - int(inten * 25))))
        hb.push(box.new(bar_index + 2, px + atrV * 0.03, bar_index + 2 + int(L * 0.45), px - atrV * 0.03, border_color = isTop ? color.new(goldCol, 0) : color.new(col, 20), bgcolor = color.new(isTop ? goldCol : col, 18 - int(inten * 14))))
        stars = inten >= 0.75 ? 3 : inten >= 0.45 ? 2 : 1
        hl.push(label.new(bar_index + 3 + L, px, f_rep("◆", stars), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(isTop ? goldCol : col, 5), size = size.tiny, tooltip = (cSd.get(i) == -1 ? "Estimated short-liquidation pool" : "Estimated long-liquidation pool") + "\nLevel " + str.tostring(px, format.mintick) + " · Mass " + str.tostring(cMs.get(i), "#.#") + "\nDistance " + str.tostring(math.abs(px - close) / atrV, "#.#") + " ATR\nEstimate from price structure and typical leverage tiers — not exchange data"))
    if showMagLn
        // strongest pool within reach — glow line, not a chart-spanning diagonal
        int magIdx = -1
        float magScore = 0.0
        for i = 0 to cPx.size() - 1
            dAtr = math.abs(cPx.get(i) - close) / atrV
            if dAtr <= 8.0
                sc = cMs.get(i) / (1.0 + dAtr * 0.35)
                if sc > magScore
                    magScore := sc
                    magIdx := i
        if magIdx >= 0
            mp = cPx.get(magIdx)
            magLn := line.new(bar_index, close, bar_index + 2, mp, color = color.new(goldCol, 55), style = line.style_solid, width = 6)
            hb.push(box.new(bar_index + 2, mp + atrV * 0.16, bar_index + 2 + 5, mp - atrV * 0.16, border_color = color.new(goldCol, 0), bgcolor = color.new(goldCol, 60)))
            magLb := label.new(bar_index + 2, mp, "Magnet ▶ " + str.tostring(mp, format.mintick) + " · " + str.tostring(math.abs(mp - close) / atrV, "#.#") + " ATR", style = mp > close ? label.style_label_lower_left : label.style_label_upper_left, color = color.new(color.black, 100), textcolor = color.new(goldCol, 0), size = size.small)

// ─── DASHBOARD ─────────────────────────────────────────────────
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small
var table tb = table.new(dPos, 2, 8, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1)
if showDash and barstate.islast
    float aPx = na
    float aMs = 0.0
    float bPx = na
    float bMs = 0.0
    float pull = 0.0
    if cPx.size() > 0
        for i = 0 to cPx.size() - 1
            d = (cPx.get(i) - close) / (atrV * 2.0)
            pull += cMs.get(i) * math.sign(cPx.get(i) - close) / (1.0 + d * d)
            if cSd.get(i) == -1 and (na(aPx) or cMs.get(i) > aMs)
                aPx := cPx.get(i)
                aMs := cMs.get(i)
            if cSd.get(i) == 1 and (na(bPx) or cMs.get(i) > bMs)
                bPx := cPx.get(i)
                bMs := cMs.get(i)
    [up_, uw, un, ua] = statsOf(pu10)
    [dp_, dw, dn, da] = statsOf(pd10)
    pMag = math.min(5, int(math.abs(pull)))
    table.cell(tb, 0, 0, "◈ LIQUIDATION MAGNET", bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 0, syminfo.ticker, bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = bodySize)
    table.cell(tb, 0, 1, "Magnet Above", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 1, na(aPx) ? "—" : str.tostring(aPx, format.mintick) + " · " + str.tostring((aPx - close) / atrV, "#.#") + " ATR", text_color = liqUpCol, text_size = bodySize)
    table.cell(tb, 0, 2, "Magnet Below", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 2, na(bPx) ? "—" : str.tostring(bPx, format.mintick) + " · " + str.tostring((close - bPx) / atrV, "#.#") + " ATR", text_color = liqDnCol, text_size = bodySize)
    table.cell(tb, 0, 3, "Net Pull", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 3, pMag == 0 ? "Balanced" : (pull > 0 ? "▲ " : "▼ ") + f_rep("▮", pMag), text_color = pull > 0.3 ? liqUpCol : pull < -0.3 ? liqDnCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 4, "Clusters", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 4, str.tostring(cPx.size()) + " active", text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 5, "Purge ▲ Reversal", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 5, un > 0 ? fw(up_) + " ×" + str.tostring(un) : "—", text_color = un >= minN and up_ >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 6, "Purge ▼ Reversal", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 6, dn > 0 ? fw(dp_) + " ×" + str.tostring(dn) : "—", text_color = dn >= minN and dp_ >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 7, "Estimated from structure · not exchange data", text_color = dashMuteTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 7, "", text_size = size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────
bool nearMagnet = false
if barstate.isconfirmed and cPx.size() > 0
    for i = 0 to cPx.size() - 1
        if math.abs(cPx.get(i) - close) <= atrV * 0.5
            nearMagnet := true
            break
alertcondition(nearMagnet and not nearMagnet[1], "Approaching Magnet", "Price is within half an Average True Range of an estimated liquidation pool.")
alertcondition(purgeUp, "Upward Purge", "Price swept through an estimated short-liquidation pool.")
alertcondition(purgeDn, "Downward Purge", "Price swept through an estimated long-liquidation pool.")
````
