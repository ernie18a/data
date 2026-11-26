# Supply & Demand Zones  Liquidity & Stop Hunt [LunqFX]

- url: https://www.tradingview.com/script/JadG1taV-Supply-Demand-Zones-Liquidity-Stop-Hunt-LunqFX/
- type: indicator
- pine_id: PUB;cdd0419a7ab244ec8b420bab8d5a8771
- version: 2.0

## Description

Supply and demand zones are where price reacts — but most indicators draw every swing as a box and leave you to guess which one matters. Liquidity Zones ranks them: it marks the key supply and demand zones, scores each one by how much liquidity it holds, and shows whether it is still fresh — so you know which level to trade and which to ignore.

❶ WHAT EACH ZONE SHOWS

Every zone is a coloured block — magenta = SUPPLY (sellers, above), teal = DEMAND (buyers, below) — and carries three readings that are original to this script:

LIQ SCORE (0–100) — how much volume traded inside the zone versus the strongest zone on the chart. 100 = the heaviest zone (the real magnet); a low score = a thin, weak level.

VOLUME ▲ / ▼ — the up-volume vs down-volume that built the zone: did buyers or sellers do the work inside it.

FRESH / TESTED N× — FRESH = price has not returned yet (strongest reaction expected); TESTED N× = already retested N times, weaker each time.

❷ HOW TO TRADE IT

1 — Read the BIAS in the panel. ▲ BUY-SIDE = favour longs, ▼ SELL-SIDE = favour shorts. Trade with it, not against it.

2 — Pick a zone with a HIGH LIQ Score (70+). Low-score zones are thin and unreliable — skip them.

3 — Prefer FRESH zones. A FRESH high-LIQ zone is the highest-probability reaction. A many-times-TESTED zone is more likely to break than hold.

4 — Wait for price to return to that zone. The bright edge line is your reference level.

5 — Enter on the reaction: LONG — bias BUY-SIDE, price drops into a FRESH teal DEMAND zone, LIQ 80, Volume ▲ (buyers dominant). Long on the reaction, stop below the zone, target the next supply zone above. SHORT — bias SELL-SIDE, price rallies into a FRESH magenta SUPPLY zone, LIQ 76, Volume ▼ (sellers dominant). Short on the reaction, stop above the zone, target the next demand zone below.

❸ WHAT TO AVOID

Trading low-LIQ zones — they hold little liquidity. Fading a zone whose Volume split disagrees with its side (e.g. a supply zone built on heavy up-volume) — the level is weak. Chasing a many-times-TESTED zone expecting a clean bounce.

Works on any symbol and timeframe — forex, gold (XAUUSD), indices, crypto and stocks — intraday and higher timeframes alike.

❹ DASHBOARD

The panel lists every zone with its price, LIQ Score, FRESH/TESTED status and side (BUY/SELL), plus a LIQ-weighted overall bias — the full picture at a glance. Optional neon candles can be turned off to keep your own style.

❺ HOW IT WORKS

1 — Swing highs and lows are found from confirmed pivots (closed bars — no repainting). Each swing high opens a supply zone, each swing low a demand zone. 2 — Each zone is a block centred on the swing, its height scaled to ATR so it fits the instrument's volatility. 3 — For every zone the script measures the volume traded inside it, the up/down-volume split, and how many separate times price entered it. 4 — LIQ Score = the zone's volume ÷ the strongest zone's volume, scaled 0–100. 5 — The bias is weighted by LIQ Score, so one heavy zone counts for more than several thin ones — an honest read of whether liquidity leans buy or sell.

No repainting

Zones are built only from confirmed pivots and rendered on the last bar over a fixed lookback. A zone that appears in a screenshot is a zone that was there live — history is never recalculated.

This indicator is an educational market-analysis tool, not financial advice. Zone strength and past reactions describe historical behavior and do not guarantee future results. Always confirm with your own analysis and manage risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  Liquidity Zones — LIQ Score, Buy/Sell Pressure & Stop-Hunt Levels [LunqFX]
// ----------------------------------------------------------------------------
//  MY engine, one idea: big supply/demand liquidity blocks on swing structure.
//
//  Every swing high leaves a SUPPLY zone (sellers), every swing low a DEMAND
//  zone (buyers). Each block is scored by MY LIQ Score (traded volume inside
//  it vs the strongest), shows the BUY/SELL split that built it, and whether
//  it is FRESH or already TESTED.
//
//  NON-REPAINTING: zones come from confirmed pivots (closed bars); drawn on
//  the last bar. History never changes.
// ============================================================================
indicator("Liquidity Zones — LIQ Score, Buy/Sell Pressure & Stop-Hunt Levels [LunqFX]",
     "Liquidity Zones [LunqFX]", overlay = true,
     max_boxes_count = 500, max_labels_count = 60, max_lines_count = 60,
     max_bars_back = 5000)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────
TEAL    = #17C3B2
TEAL_HI = #7BF7E8
TEAL_PL = #0D5D55
MAG     = #E23E7C
MAG_HI  = #FF9DC2
MAG_PL  = #6E1B3E
NAVY    = #0B1020
CARD    = #171E34
TXT     = #EEF2FA
MUTE    = #6B7488

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gE       = "Liquidity Engine"
lookback = input.int(300, "Lookback (bars)", minval = 50, maxval = 5000, group = gE)
pivLen   = input.int(10,  "Swing length",    minval = 3, maxval = 50, group = gE, tooltip = "Bigger = only major swings become zones.")
zoneN    = input.int(5,   "Zones to show",   minval = 1, maxval = 10, group = gE)
heightM  = input.float(1.3,"Zone height (× ATR)", minval = 0.3, maxval = 5.0, step = 0.1, group = gE, tooltip = "Bigger = taller blocks.")

gV       = "Visuals"
extendR  = input.int(4,   "Extend right (bars)", minval = 0, maxval = 60, group = gV)
grad     = input.int(7,   "Gradient bands", minval = 2, maxval = 12, group = gV)
solidOp  = input.int(38,  "Fill strength (edge)", minval = 12, maxval = 70, group = gV, tooltip = "Lower = more solid block.")
neonOn   = input.bool(true, "Neon momentum candles", group = gV)

gP       = "Dashboard"
showHUD  = input.bool(true, "Show dashboard", group = gP)
hudPos   = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  SWINGS
// ─────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
var array<float> sPrice = array.new<float>()
var array<int>   sBar   = array.new<int>()
var array<bool>  sHigh  = array.new<bool>()
if not na(ph)
    array.push(sPrice, ph)
    array.push(sBar, bar_index - pivLen)
    array.push(sHigh, true)
if not na(pl)
    array.push(sPrice, pl)
    array.push(sBar, bar_index - pivLen)
    array.push(sHigh, false)
while array.size(sBar) > 0 and (bar_index - array.get(sBar, 0)) > lookback
    array.shift(sBar)
    array.shift(sPrice)
    array.shift(sHigh)

atr14 = ta.atr(14)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

miniBar(int score) =>
    seg = 8
    f   = math.round(score / 100.0 * seg)
    out = ""
    for i = 1 to seg
        out := out + (i <= f ? "▰" : "▱")
    out

// ─────────────────────────────────────────────────────────────────────────
//  RENDER
//  FIX 1: recompute only once per CLOSED bar, not on every real-time tick.
//         The old code ran the whole double-loop on every tick (barstate.islast
//         fires on each incoming tick) → 10 zones × up to 5000 bars = 50k ops
//         per tick → "loop takes too long / calculation timed out" spam on low
//         timeframes. `recalc` gates it to one pass per new bar.
// ─────────────────────────────────────────────────────────────────────────
var array<box>   bxs = array.new<box>()
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()
var table hud = na
var int lastCalcBar = na

recalc = barstate.islast and (na(lastCalcBar) or lastCalcBar != bar_index)

if recalc
    lastCalcBar := bar_index

    if array.size(bxs) > 0
        for i = 0 to array.size(bxs) - 1
            box.delete(array.get(bxs, i))
        array.clear(bxs)
    if array.size(lns) > 0
        for i = 0 to array.size(lns) - 1
            line.delete(array.get(lns, i))
        array.clear(lns)
    if array.size(lbs) > 0
        for i = 0 to array.size(lbs) - 1
            label.delete(array.get(lbs, i))
        array.clear(lbs)
    if not na(hud)
        table.delete(hud)

    nS = array.size(sPrice)
    h  = atr14 * heightM

    // FIX 2: never reference further back than the chart actually has bars.
    //        `high[i]` with i up to lookback-1 (5000) overran the historical
    //        buffer on charts with fewer bars → "requested historical offset
    //        is beyond the historical buffer's limit". Bound the scan here.
    scanN = math.min(lookback, bar_index + 1)

    // gather the most recent zoneN swings
    zP = array.new<float>()
    zB = array.new<int>()
    zHi2 = array.new<float>()
    zLo2 = array.new<float>()
    zBuy = array.new<float>()
    zVol = array.new<float>()
    zTch = array.new<int>()
    zSup = array.new<bool>()
    maxV = 0.0

    if nS > 0 and h > 0
        start = math.max(0, nS - zoneN)
        for idx = start to nS - 1
            sp  = array.get(sPrice, idx)
            sb  = array.get(sBar, idx)
            sup = array.get(sHigh, idx)
            zH  = sp + h / 2.0
            zL  = sp - h / 2.0
            // buy/sell + touches inside the band over the scan window
            buyV = 0.0
            sellV = 0.0
            touches = 0
            prevIn = false
            for i = scanN - 1 to 0
                pp = (high[i] + low[i] + close[i]) / 3.0
                inZ = pp >= zL and pp <= zH
                if inZ
                    if close[i] >= open[i]
                        buyV += nz(volume[i], 1.0)
                    else
                        sellV += nz(volume[i], 1.0)
                    if not prevIn
                        touches += 1
                prevIn := inZ
            tot = buyV + sellV
            array.push(zP, sp)
            array.push(zB, sb)
            array.push(zHi2, zH)
            array.push(zLo2, zL)
            array.push(zBuy, tot > 0 ? buyV / tot * 100.0 : 50.0)
            array.push(zVol, tot)
            array.push(zTch, touches)
            array.push(zSup, sup)
            maxV := math.max(maxV, tot)

    // draw
    nZ = array.size(zP)
    if nZ > 0 and maxV > 0
        for z = 0 to nZ - 1
            sp   = array.get(zP, z)
            sb   = array.get(zB, z)
            zH   = array.get(zHi2, z)
            zL   = array.get(zLo2, z)
            sup  = array.get(zSup, z)
            buyP = array.get(zBuy, z)
            score = math.round(array.get(zVol, z) / maxV * 100)
            tch  = array.get(zTch, z)
            baseCol = sup ? MAG : TEAL
            edgeCol = sup ? MAG_HI : TEAL_HI
            x1 = math.max(bar_index - lookback, sb)
            x2 = bar_index + extendR

            gh = (zH - zL) / grad
            for s = 0 to grad - 1
                yA = sup ? zL + gh * s : zH - gh * s
                yB = sup ? zL + gh * (s + 1) : zH - gh * (s + 1)
                op = math.min(86, math.round(solidOp + 34 * (s / float(grad))))
                array.push(bxs, box.new(x1, math.max(yA, yB), x2, math.min(yA, yB), border_color = color.new(baseCol, 100), bgcolor = color.new(baseCol, op)))
            edgeY = sup ? zL : zH
            array.push(lns, line.new(x1, edgeY, x2, edgeY, color = color.new(edgeCol, 10), width = 2))
            tag = tch <= 1 ? "FRESH" : "TESTED " + str.tostring(tch) + "x"
            txt = "LIQ " + str.tostring(score) + "  " + miniBar(score) + "\nvol ▲ " + str.tostring(math.round(buyP)) + "%   ▼ " + str.tostring(math.round(100 - buyP)) + "%   " + tag
            array.push(lbs, label.new(x2, sup ? zH : zL, txt, style = sup ? label.style_label_lower_left : label.style_label_upper_left, color = color.new(sup ? MAG_PL : TEAL_PL, 12), textcolor = TXT, size = size.normal, textalign = text.align_left))

    // ── PANEL (bigger, with bias summary) ──
    if showHUD and nZ > 0
        // bias weighted by LIQ strength (zone volume), not raw zone count
        buyW = 0.0
        sellW = 0.0
        for i = 0 to nZ - 1
            if array.get(zSup, i)
                sellW += array.get(zVol, i)
            else
                buyW += array.get(zVol, i)
        totW = buyW + sellW
        biasUp = buyW >= sellW
        biasPct = totW > 0 ? math.round((biasUp ? buyW : sellW) / totW * 100) : 50
        biasCol = biasUp ? TEAL_HI : MAG_HI

        hud := table.new(hudPosition(hudPos), 3, nZ + 2, bgcolor = color.new(NAVY, 6), border_width = 0, frame_width = 0)
        // title
        table.cell(hud, 0, 0, "  LIQUIDITY ZONES", text_color = TXT, text_size = size.large, text_halign = text.align_left, bgcolor = color.new(CARD, 0))
        table.cell(hud, 1, 0, "", bgcolor = color.new(CARD, 0))
        table.cell(hud, 2, 0, "LunqFX  ", text_color = TEAL, text_size = size.small, text_halign = text.align_right, bgcolor = color.new(CARD, 0))
        // bias line
        table.cell(hud, 0, 1, biasUp ? "  ▲ BUY-SIDE BIAS" : "  ▼ SELL-SIDE BIAS", text_color = biasCol, text_size = size.large, text_halign = text.align_left, bgcolor = color.new(NAVY, 0))
        table.cell(hud, 1, 1, "", bgcolor = color.new(NAVY, 0))
        table.cell(hud, 2, 1, str.tostring(biasPct) + "%  ", text_color = biasCol, text_size = size.normal, text_halign = text.align_right, bgcolor = color.new(NAVY, 0))
        // zone rows (nearest to price first)
        for i = 0 to nZ - 1
            r = i + 2
            sup = array.get(zSup, i)
            bp  = array.get(zBuy, i)
            sc  = math.round(array.get(zVol, i) / maxV * 100)
            tch = array.get(zTch, i)
            rowbg = color.new(NAVY, i % 2 == 0 ? 22 : 46)
            table.cell(hud, 0, r, " " + str.tostring(array.get(zP, i), format.mintick) + "  " + (tch <= 1 ? "· FRESH" : "· " + str.tostring(tch) + "x"), text_color = TXT, text_size = size.normal, text_halign = text.align_left, bgcolor = rowbg)
            table.cell(hud, 1, r, " LIQ " + str.tostring(sc) + " ", text_color = sup ? MAG_HI : TEAL_HI, text_size = size.normal, text_halign = text.align_center, bgcolor = rowbg)
            table.cell(hud, 2, r, sup ? " SELL " : " BUY ", text_color = TXT, text_size = size.normal, text_halign = text.align_center, bgcolor = sup ? MAG_PL : TEAL_PL)

// ─────────────────────────────────────────────────────────────────────────
//  NEON MOMENTUM CANDLES  (ON by default)
// ─────────────────────────────────────────────────────────────────────────
isUp     = close >= open
strength = math.min(1.0, math.abs(close - open) / (atr14 * 0.45))
upCol    = color.from_gradient(strength, 0, 1, #0FA593, TEAL_HI)
dnCol    = color.from_gradient(strength, 0, 1, #A32359, MAG_HI)
plotcandle(neonOn ? open : na, high, low, close, title = "Neon Candles", color = isUp ? upCol : dnCol, wickcolor = isUp ? TEAL : MAG, bordercolor = isUp ? TEAL : MAG)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(not na(ph), "New supply zone", "LunqFX Liquidity Zones: new supply (sell-side) zone formed")
alertcondition(not na(pl), "New demand zone", "LunqFX Liquidity Zones: new demand (buy-side) zone formed")
````
