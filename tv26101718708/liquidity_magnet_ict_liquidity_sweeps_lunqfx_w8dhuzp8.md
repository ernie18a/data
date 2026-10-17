# Liquidity Magnet ICT Liquidity & Sweeps [LunqFX]

- url: https://www.tradingview.com/script/w8DHUZp8-Liquidity-Magnet-ICT-Liquidity-Sweeps-LunqFX/
- type: indicator
- pine_id: PUB;4c04a716dcc146c68fe69effb7252b3f
- version: 1.0

## Description

Liquidity Magnet is an ICT / Smart Money Concepts (SMC) liquidity indicator that maps buy-side and sell-side liquidity (BSL / SSL) and ranks every liquidity pool by how likely it is to be swept next. Instead of just drawing equal highs, equal lows and swing liquidity, it scores each resting pool of liquidity with a transparent 0–100 "Magnet Score" and highlights the single strongest draw on price as the NEXT TARGET — so you can anticipate the next liquidity sweep, stop hunt or liquidity grab before it happens.

If you trade ICT concepts, order flow, smart money, or supply and demand, this tool answers the one question every liquidity-based strategy needs: where is price most likely to go to take liquidity next?


WHAT IT DOES

• Detects liquidity pools automatically — swing highs / lows and equal highs / equal lows (EQH / EQL) where stop-losses cluster.
• Scores each pool 0–100 with the Magnet Score, a transparent weighted formula.
• Flags the strongest pool as the NEXT TARGET with a live arrow, price and probability.
• Marks pools as swept the moment price closes through them, then fades them.
• Shows a clean live dashboard: next target, probability, distance, bias and pool counts.
• Recolors the chart with neon gradient candles (turquoise bullish / violet bearish).


HOW THE MAGNET SCORE WORKS

The Magnet Score is fully transparent — no black box. Each unswept pool is graded on four weighted factors:

1. Proximity — how close the pool sits to current price (closer pulls harder).
2. Momentum — whether current momentum is moving toward the pool.
3. Age — how long the pool has rested untouched (older pools hold more liquidity).
4. Touches — how many times price has tagged the level (more taps = more stops stacked).

The four factors are combined into a single 0–100 score. The pool with the highest score, within a maximum distance from price, becomes the NEXT TARGET. If no pool is strong or close enough, the panel honestly reports "No clear magnet" instead of inventing a far-away target.


HOW TO USE IT

1. Read the BIAS in the panel — BUY-SIDE PULL means liquidity above is the draw (look for longs into the target); SELL-SIDE PULL means liquidity below is the draw (look for shorts).
2. Find the NEXT TARGET — the highlighted pool is where price is most likely to sweep liquidity next. Use it as a logical take-profit / objective.
3. Check the PROBABILITY bar — higher score = stronger magnet. Weak scores mean price is in a low-liquidity void; be patient.
4. Watch DISTANCE — how far the target is in %. Tight distance = an immediate objective; large distance = a swing objective.
5. Trade the sweep — as price reaches a pool and sweeps it, watch for the reaction. Swept pools fade automatically so the chart always shows live, unmitigated liquidity only.

Tip: combine the NEXT TARGET with your own entry model (FVG, order block, market structure). Liquidity Magnet tells you WHERE liquidity sits and which pool is the draw — you choose the entry.


THE DASHBOARD

[image]https://www.tradingview.com/x/OsNC5PPi/[/image]

• NEXT TARGET — price of the strongest liquidity pool and its probability.
• Probability bar — visual 0–100 strength of the current magnet.
• Distance — % distance from price to the target.
• Touches — how many times the target level was tested.
• Bias — overall liquidity pull (buy-side vs sell-side).
• Buy-side / Sell-side pools — count of active unmitigated pools on each side.


NON-REPAINTING

All liquidity pools are built from confirmed pivots (a fixed lookback of closed bars), and every sweep is confirmed on closed bars only — barstate.isconfirmed. Scores and visuals are display-side and never rewrite history. No request.security, no lookahead, no future leak. What you see is what actually happened.


SETTINGS

Liquidity Engine
• Swing length — pivot lookback; higher = only major swings become pools.
• Equal-level tolerance — how close two highs/lows must be (in ATR) to merge into one pool and count as a touch.
• Max pools per side — cap on active pools above and below.
• Max pool age — pools older than this are removed.

Magnet Score
• Proximity range, Momentum lookback / range — sensitivity of the score factors.
• Weights: proximity / age / touches / momentum — fully customizable scoring.
• Min score to flag target — hide weak magnets below this score.
• Max target distance % — a pool farther than this can never be the NEXT TARGET.

Neon Candles
• Neon gradient candles on/off, Glow halo on/off.

Panel
• Show panel, position, background / text / accent colors.


BEST USED ON

Forex, Gold (XAUUSD), indices, crypto and stocks. Works on all timeframes; intraday (15m–4H) is ideal for liquidity sweeps, higher timeframes for swing objectives.


Keywords: liquidity, liquidity sweep, liquidity pools, ICT, SMC, smart money concepts, buy-side liquidity, sell-side liquidity, BSL, SSL, equal highs, equal lows, EQH, EQL, stop hunt, liquidity grab, order flow, smart money, market structure.

This indicator is a decision-support tool, not financial advice. Always combine it with your own analysis and risk management.

## Source Code

````pine
//@version=6
// ============================================================================
//  Liquidity Magnet [LunqFX]
// ----------------------------------------------------------------------------
//  It does not just draw liquidity levels - it ranks them. Every resting pool
//  of liquidity (equal highs / lows and swing extremes) is scored 0-100 by how
//  strongly it is likely to be swept next, based on a transparent formula:
//
//      Magnet Score = proximity + age + touches + momentum (weighted)
//
//  The strongest pool is highlighted as the NEXT TARGET with a live arrow and
//  probability. Pools glow brighter the stronger they pull; when price closes
//  through one it is marked swept and fades.
//
//  NON-REPAINTING: pools come from confirmed pivots and sweeps are confirmed on
//  closed bars only. Scores/visuals are display-side and never alter history.
// ============================================================================
indicator("Liquidity Magnet [LunqFX]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────
NEON_VIOLET = #B026FF
NEON_TURQ   = #00E5D0
// Gradient floors are already clearly neon (mid tone), so even small candles
// glow; strong candles brighten further toward the full neon above.
VIO_MID     = #7A2BD6
VIO_HI      = #D070FF
TUR_MID     = #12B8A6
TUR_HI      = #4DFCE6
INK         = #0B0E14

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gLiq    = "Liquidity Engine"
pivotLen= input.int(8,    "Swing length",            minval = 2, maxval = 50, group = gLiq, tooltip = "Pivot lookback. Higher = only major swings become liquidity pools.")
eqTol   = input.float(0.12,"Equal-level tolerance",  minval = 0.0, step = 0.02, group = gLiq, tooltip = "How close two highs/lows must be (in ATR) to be merged into one pool and counted as a touch.")
maxPool = input.int(7,    "Max pools per side",      minval = 1, maxval = 20, group = gLiq)
ageMax  = input.int(400,  "Max pool age (bars)",     minval = 50, group = gLiq, tooltip = "Pools older than this are removed.")

gScore  = "Magnet Score"
proxK   = input.float(10.0,"Proximity range (ATR)",  minval = 1.0, step = 1.0, group = gScore, tooltip = "Distance in ATR over which proximity decays to zero. Smaller = only nearby pools score high.")
momLen  = input.int(8,    "Momentum lookback",       minval = 1, group = gScore)
momK    = input.float(4.0,"Momentum range (ATR)",    minval = 1.0, step = 0.5, group = gScore)
wProx   = input.float(55, "Weight: proximity",       minval = 0, group = gScore)
wAge    = input.float(10, "Weight: age",             minval = 0, group = gScore)
wTouch  = input.float(10, "Weight: touches",         minval = 0, group = gScore)
wMom    = input.float(25, "Weight: momentum",        minval = 0, group = gScore)
minScore= input.float(35, "Min score to flag target", minval = 0, maxval = 100, group = gScore, tooltip = "If the strongest pool scores below this, no NEXT TARGET is shown - the magnet is too weak to be meaningful. Lower it to show targets more often.")
maxDist = input.float(5.0,"Max target distance %",   minval = 0.5, step = 0.5, group = gScore, tooltip = "A pool farther than this (in %) from price can never be the NEXT TARGET. Prevents flagging far-away levels as the immediate target.")

gCandle = "Neon Candles"
neonOn  = input.bool(true,"Neon gradient candles",   group = gCandle, tooltip = "Overlays glowing candles. Turquoise = bullish, violet = bearish, intensity scales with momentum.")
neonGlow= input.bool(true,"Glow halo",               group = gCandle)

gPanel  = "Panel"
showHUD = input.bool(true,"Show panel",              group = gPanel)
hudPos  = input.string("Top Right","Position",       options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gPanel)
hudBg   = input.color(#0B0E14,"Background",          group = gPanel)
hudTxt  = input.color(#E6EDF3,"Text",                group = gPanel)
accent  = input.color(#00E5D0,"Accent",              group = gPanel)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
atr = ta.atr(14)

hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

progressBar(float pct) =>
    seg    = 12
    filled = math.round(pct / 100 * seg)
    out    = ""
    for i = 1 to seg
        out := out + (i <= filled ? "█" : "░")
    out

// Magnet Score 0-100. above = pool sits above price (buy-side liquidity).
magnetScore(float price, bool above, int bar, int touches) =>
    dist   = math.abs(close - price)
    prox   = math.max(0.0, 1.0 - dist / (atr * proxK))
    age    = math.min(1.0, (bar_index - bar) / float(ageMax))
    tch    = math.min(1.0, touches / 2.5)
    mom    = close - close[momLen]
    toward = above ? mom : -mom
    msc    = math.max(0.0, math.min(1.0, toward / (atr * momK)))
    wSum   = wProx + wAge + wTouch + wMom
    wSum <= 0 ? 0.0 : 100.0 * (wProx * prox + wAge * age + wTouch * tch + wMom * msc) / wSum

// ─────────────────────────────────────────────────────────────────────────
//  TYPE
// ─────────────────────────────────────────────────────────────────────────
type Pool
    float price
    bool  above      // true = buy-side liquidity (above price), false = sell-side
    int   bar        // first bar of the pool
    int   touches
    bool  swept
    float score
    line  glow
    line  core
    label tag

// ─────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────
var array<Pool> pools = array.new<Pool>()

// ─────────────────────────────────────────────────────────────────────────
//  POOL CREATION FROM CONFIRMED PIVOTS (+ equal-level merging)
// ─────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

sideCount(bool above) =>
    n = 0
    if array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            if array.get(pools, i).above == above
                n += 1
    n

addPool(float price, bool above) =>
    tol     = atr * eqTol
    merged  = false
    if array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            p = array.get(pools, i)
            if p.above == above and not p.swept and math.abs(p.price - price) <= tol
                p.touches += 1
                p.price   := math.avg(p.price, price)   // refine the level
                merged    := true
                break
    if not merged
        col  = above ? NEON_VIOLET : NEON_TURQ
        x1   = bar_index - pivotLen
        glow = line.new(x1, price, bar_index, price, color = color.new(col, 95), width = 6)
        core = line.new(x1, price, bar_index, price, color = color.new(col, 55), width = 1)
        tag  = label.new(bar_index, price, "", style = label.style_label_left, color = color.new(INK, 8), textcolor = col, size = size.normal, textalign = text.align_left)
        array.push(pools, Pool.new(price, above, bar_index - pivotLen, 1, false, 0.0, glow, core, tag))
        // Trim oldest pool on this side beyond the limit.
        if sideCount(above) > maxPool
            for i = 0 to array.size(pools) - 1
                p = array.get(pools, i)
                if p.above == above
                    line.delete(p.glow)
                    line.delete(p.core)
                    label.delete(p.tag)
                    array.remove(pools, i)
                    break

if not na(ph)
    addPool(ph, true)
if not na(pl)
    addPool(pl, false)

// ─────────────────────────────────────────────────────────────────────────
//  SWEEP DETECTION + AGE CLEANUP (confirmed bars only -> non-repainting)
// ─────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed and array.size(pools) > 0
    for i = array.size(pools) - 1 to 0
        p = array.get(pools, i)
        // Remove pools that exceeded max age.
        if bar_index - p.bar > ageMax
            line.delete(p.glow)
            line.delete(p.core)
            label.delete(p.tag)
            array.remove(pools, i)
            continue
        // A close through the level sweeps the pool.
        if not p.swept and (p.above ? close > p.price : close < p.price)
            p.swept := true

// ─────────────────────────────────────────────────────────────────────────
//  RENDER + NEXT TARGET (last bar)
// ─────────────────────────────────────────────────────────────────────────
var label nextTag = na

if barstate.islast and array.size(pools) > 0
    bestIdx   = -1
    bestScore = -1.0
    for i = 0 to array.size(pools) - 1
        p     = array.get(pools, i)
        col   = p.above ? NEON_VIOLET : NEON_TURQ
        brite = p.above ? VIO_HI : TUR_HI
        p.score := p.swept ? 0.0 : magnetScore(p.price, p.above, p.bar, p.touches)

        // Visual strength scales with score.
        coreTr = math.round(70 - p.score * 0.45)         // stronger -> more opaque
        glowTr = math.round(96 - p.score * 0.20)
        cw     = p.score >= 66 ? 3 : p.score >= 33 ? 2 : 1

        // Keep geometry in sync (price may have been refined by merging).
        line.set_xy1(p.core, p.bar, p.price)
        line.set_xy2(p.core, bar_index + 3, p.price)
        line.set_xy1(p.glow, p.bar, p.price)
        line.set_xy2(p.glow, bar_index + 3, p.price)
        label.set_x(p.tag, bar_index + 3)
        label.set_y(p.tag, p.price)

        if p.swept
            line.set_color(p.core, color.new(col, 90))
            line.set_color(p.glow, color.new(col, 100))
            line.set_style(p.core, line.style_dashed)
            line.set_width(p.core, 1)
            label.set_text(p.tag, "")
            label.set_color(p.tag, color.new(INK, 100))
        else
            line.set_color(p.core, color.new(col, coreTr))
            line.set_color(p.glow, color.new(col, neonGlow ? glowTr : 100))
            line.set_style(p.core, line.style_solid)
            line.set_width(p.core, cw)
            arrow = p.above ? "▲" : "▼"
            label.set_text(p.tag, str.format("  {0} {1}   {2}  ", arrow, str.tostring(p.price, format.mintick), math.round(p.score)))
            label.set_textcolor(p.tag, brite)
            label.set_color(p.tag, color.new(INK, 8))

        distPct = close != 0 ? math.abs((p.price - close) / close * 100) : 1e9
        if not p.swept and distPct <= maxDist and p.score > bestScore
            bestScore := p.score
            bestIdx   := i

    // Highlight the strongest pool as NEXT TARGET.
    if not na(nextTag)
        label.delete(nextTag)
    if bestIdx >= 0 and bestScore >= minScore
        bp  = array.get(pools, bestIdx)
        col = bp.above ? NEON_VIOLET : NEON_TURQ
        arrow = bp.above ? "▲" : "▼"
        // Hide the pool's own tag so it does not overlap the NEXT TARGET label.
        label.set_text(bp.tag, "")
        nextTag := label.new(bar_index + 3, bp.price, str.format("  NEXT TARGET   {0} {1}   {2}%  ", arrow, str.tostring(bp.price, format.mintick), math.round(bp.score)), style = label.style_label_left, color = col, textcolor = color.white, size = size.large, textalign = text.align_left)

// ─────────────────────────────────────────────────────────────────────────
//  PANEL
// ─────────────────────────────────────────────────────────────────────────
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudPosition(hudPos), 2, 9, bgcolor = color.new(hudBg, 4), border_width = 0, frame_color = color.new(accent, 55), frame_width = 1)

    // Resolve best (unswept) pool for the panel readout.
    bIdx   = -1
    bScore = -1.0
    buyN   = 0
    sellN  = 0
    if array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            p = array.get(pools, i)
            if not p.swept
                s = magnetScore(p.price, p.above, p.bar, p.touches)
                dPct = close != 0 ? math.abs((p.price - close) / close * 100) : 1e9
                if p.above
                    buyN += 1
                else
                    sellN += 1
                if dPct <= maxDist and s > bScore
                    bScore := s
                    bIdx   := i

    card = color.new(hudBg, 6)
    head = color.new(hudBg, 0)
    band = color.new(hudBg, 30)
    lblC = color.new(hudTxt, 50)

    hasT   = bIdx >= 0 and bScore >= minScore
    tgtCol = hudTxt
    tgtTx  = (buyN + sellN) > 0 ? "No clear magnet" : "—"
    distS  = "—"
    tchS   = "—"
    biasS  = "—"
    scr    = 0.0
    if hasT
        bp     = array.get(pools, bIdx)
        tgtCol := bp.above ? NEON_VIOLET : NEON_TURQ
        tgtTx  := (bp.above ? "▲ " : "▼ ") + str.tostring(bp.price, format.mintick)
        dist   = bp.price - close
        distP  = close != 0 ? dist / close * 100 : 0.0
        distS  := (dist >= 0 ? "+" : "") + str.tostring(distP, "#.0#") + "%"
        tchS   := str.tostring(bp.touches)
        biasS  := bp.above ? "BUY-SIDE PULL" : "SELL-SIDE PULL"
        scr    := bScore

    // Header
    table.cell(hud, 0, 0, "  LIQUIDITY MAGNET", text_color = color.white, text_size = size.normal, text_halign = text.align_left,  bgcolor = head)
    table.cell(hud, 1, 0, "LunqFX  ",           text_color = accent, text_size = size.small, text_halign = text.align_right, bgcolor = head)

    // Next target (hero)
    table.cell(hud, 0, 1, "  NEXT TARGET", text_color = lblC, text_size = size.small, text_halign = text.align_left,  bgcolor = card)
    table.cell(hud, 1, 1, tgtTx + "  ", text_color = tgtCol, text_size = size.large, text_halign = text.align_right, bgcolor = card)

    // Probability bar
    table.cell(hud, 0, 2, "  " + progressBar(scr), text_color = tgtCol, text_size = size.normal, text_halign = text.align_left,  bgcolor = card)
    table.cell(hud, 1, 2, str.tostring(math.round(scr)) + "%  ", text_color = tgtCol, text_size = size.normal, text_halign = text.align_right, bgcolor = card)

    // Distance
    table.cell(hud, 0, 3, "  Distance", text_color = lblC, text_size = size.normal, text_halign = text.align_left,  bgcolor = card)
    table.cell(hud, 1, 3, distS + "  ", text_color = hudTxt, text_size = size.normal, text_halign = text.align_right, bgcolor = card)

    // Touches
    table.cell(hud, 0, 4, "  Touches", text_color = lblC, text_size = size.normal, text_halign = text.align_left,  bgcolor = card)
    table.cell(hud, 1, 4, tchS + "  ", text_color = hudTxt, text_size = size.normal, text_halign = text.align_right, bgcolor = card)

    // Analytics band
    table.cell(hud, 0, 5, "  ANALYTICS", text_color = color.new(accent, 10), text_size = size.small, text_halign = text.align_left,  bgcolor = band)
    table.cell(hud, 1, 5, "", bgcolor = band)

    // Bias
    table.cell(hud, 0, 6, "  Bias", text_color = lblC, text_size = size.normal, text_halign = text.align_left,  bgcolor = card)
    table.cell(hud, 1, 6, biasS + "  ", text_color = tgtCol, text_size = size.normal, text_halign = text.align_right, bgcolor = card)

    // Pool counts
    table.cell(hud, 0, 7, "  Buy-side pools", text_color = lblC, text_size = size.normal, text_halign = text.align_left,  bgcolor = card)
    table.cell(hud, 1, 7, str.tostring(buyN) + "  ", text_color = NEON_VIOLET, text_size = size.normal, text_halign = text.align_right, bgcolor = card)

    table.cell(hud, 0, 8, "  Sell-side pools", text_color = lblC, text_size = size.normal, text_halign = text.align_left,  bgcolor = band)
    table.cell(hud, 1, 8, str.tostring(sellN) + "  ", text_color = NEON_TURQ, text_size = size.normal, text_halign = text.align_right, bgcolor = band)

// ─────────────────────────────────────────────────────────────────────────
//  NEON GRADIENT CANDLES  (turquoise bullish / violet bearish)
// ─────────────────────────────────────────────────────────────────────────
isUp     = close >= open
// Momentum strength 0..1 (reaches full brightness easily).
strength = math.min(1.0, math.abs(close - open) / (atr * 0.45))
upCol    = color.from_gradient(strength, 0, 1, TUR_MID, TUR_HI)
dnCol    = color.from_gradient(strength, 0, 1, VIO_MID, VIO_HI)
bodyCol  = isUp ? upCol : dnCol
edgeCol  = isUp ? NEON_TURQ : NEON_VIOLET

// Halo layer — soft glow around each candle.
plotcandle(neonOn and neonGlow ? open : na, high, low, close, title = "Glow", color = color.new(edgeCol, 75), wickcolor = color.new(edgeCol, 55), bordercolor = color.new(edgeCol, 85), display = display.pane)
// Crisp neon body, fully opaque so it covers the native candles.
plotcandle(neonOn ? open : na, high, low, close, title = "Neon Candles", color = bodyCol, wickcolor = edgeCol, bordercolor = edgeCol, display = display.pane)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(not na(ph), "New buy-side pool",  "LunqFX: new buy-side liquidity pool formed")
alertcondition(not na(pl), "New sell-side pool", "LunqFX: new sell-side liquidity pool formed")
````
