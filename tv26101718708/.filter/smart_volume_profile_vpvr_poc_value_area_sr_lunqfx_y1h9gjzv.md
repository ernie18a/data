# Smart Volume Profile VPVR POC, Value Area, SR [LunqFX]

- url: https://www.tradingview.com/script/Y1H9GJzv-Smart-Volume-Profile-VPVR-POC-Value-Area-SR-LunqFX/
- type: indicator
- pine_id: PUB;7d56b3ab6f8848a9a6618d9162df8af2
- version: 1.0

## Description

Smart Volume Profile VPVR is a modern, professional-grade volume profile indicator for TradingView that turns raw traded volume into the cleanest possible map of where the market actually did business. It plots the Point of Control (POC), the full 70% Value Area (VAH / VAL), and every High and Low Volume Node (HVN / LVN) as glowing, easy-to-read horizontal support and resistance levels — on any symbol and any timeframe: forex, crypto, stocks, indices, futures, gold (XAUUSD), Bitcoin (BTCUSD), NASDAQ, S&P 500, oil and more. Unlike a plain histogram, this VPVR (Volume Profile Visible Range) tool layers a live order-flow dashboard on top that reads the market in real time and tells you whether price is accepting value, rejecting value, rotating back to fair value, or breaking out — the exact context that separates profitable volume-profile trading from guessing. Built entirely in Pine Script v6 with neon gradient candles and a fully readable, gradient-coloured profile, it is designed to be both beautiful and genuinely useful for day trading, scalping, swing trading and intraday analysis.

◆ WHY VOLUME PROFILE MATTERS

Most indicators are based on price and time. Volume profile is based on price and volume — it answers a completely different and more important question: at which prices did the most trading actually happen? Those prices are where institutions, liquidity and "fair value" concentrate. High-volume areas act as magnets and strong support/resistance; low-volume areas are vacuums that price rips through. By making this structure obvious, Smart Volume Profile helps you trade with the auction instead of against it.

◆ WHAT IT DRAWS ON THE CHART

POC — Point of Control (gold ray): the single most-traded price in the window. This is the market's fairest value and its strongest magnet. Price returns to the POC again and again; it is the most important pivot on the chart.
VAH / VAL — Value Area High & Low (dashed rays): the top and bottom of the zone that contains 70% of all traded volume (fully configurable, 40–95%). Inside this band the market is "comfortable"; outside it the market is in discovery / imbalance.
High Volume Nodes (HVN): thick, bright rows = heavy acceptance = strong support & resistance and reaction/reversal zones.
Low Volume Nodes (LVN): thin, dim rows = rejection / fast-move zones where price tends to travel quickly and gap.
Gradient histogram: every row is colour-graded by its volume, so the profile literally glows where volume is heaviest — you read the structure at a glance instead of squinting at bars.
All levels extend as live rays with clean, high-contrast labels showing the exact price.

◆ THE LIVE DASHBOARD PANEL (this is what makes it "Smart")
[image]https://www.tradingview.com/x/XUcUSoXW/[/image]

A plain volume profile just draws lines. This indicator adds a compact, modern analytics panel that computes context you cannot see on the chart and condenses it into one glance:
Signal — the headline call, colour-coded: ▲ LONG revert, ▼ SHORT revert, ▲ BREAKOUT, ▼ BREAKDOWN, or ● BALANCED. This is the playbook for the current moment (logic explained below).
→ POC — the live distance from current price to the Point of Control, in %. This is your mean-reversion target and a quick read of how stretched price is from fair value.
In VA — a clean segmented meter showing where price currently sits inside the value area (from VAL on the left to VAH on the right). Instantly tells you if you're at the top, middle, or bottom of value.
Acceptance — the split of volume traded above vs below the POC (e.g. 52% ▼ / ▲ 48%). Reveals which side the market is building value on — a directional bias the chart hides.
Pressure — a segmented meter of buy volume vs sell volume across the whole window. Shows whether buyers or sellers are in control of the auction.
Footer — the lookback size and the actual % of volume captured by the value area, so you always know the context behind the numbers.
The panel is fully themeable (position, background, accent) and stays readable on dark charts.

◆ HOW IT WORKS (under the hood)

Binning: the chosen lookback window is divided into price rows ("buckets"). Resolution is adjustable for coarse or razor-sharp profiles.
True volume distribution: instead of dumping each bar's volume at its close, the indicator can spread each bar's volume across every price it actually traded through (high→low), producing a far more accurate profile than close-only methods.
POC detection: the row with the maximum accumulated volume becomes the Point of Control — by construction always the longest bar in the histogram.
Value Area expansion: starting from the POC, the algorithm steps outward toward whichever neighbouring row holds more volume, accumulating until the target (default 70%) of total volume is enclosed. The final boundaries become VAH and VAL — the same methodology used in classic Market Profile.
Order-flow analytics: the script measures volume above vs below the POC (Acceptance) and buy-bar vs sell-bar volume (Pressure) across the window.
Smart Signal engine: it blends Acceptance and Pressure into a single order-flow reading and combines it with price location relative to the value area to classify the situation as a rotation or a breakout (see below).

◆ THE SMART SIGNAL LOGIC

A naive volume-profile tool always says "revert to POC", which gets you run over in trends. This one is smarter:
Price BELOW value + order flow NOT confirming the drop → ▲ LONG revert (rotation back to POC).
Price BELOW value + order flow confirming the drop → ▼ BREAKDOWN (continuation — don't catch the knife).
Price ABOVE value + order flow NOT confirming the push → ▼ SHORT revert (rotation back to POC).
Price ABOVE value + order flow confirming the push → ▲ BREAKOUT (continuation — trade with it).
Price INSIDE value → ● BALANCED (range conditions — fade the edges back toward POC).
This single distinction — rotation vs breakout — is the difference between fading a pullback and getting trapped against a trend.

◆ HOW TO USE IT

Mean-reversion / range trading: in BALANCED or revert states, fade moves at VAH/VAL back toward the POC. The → POC distance is your target; HVN rows are logical stop zones.
Breakout / trend trading: in BREAKOUT / BREAKDOWN states, trade in the direction of the move and target the next HVN. Avoid counter-trend fades when order flow confirms the break.
Support & resistance mapping: treat thick HVN rows as high-probability reaction zones and expect rapid, low-resistance moves through LVN gaps.
Bias & confluence: use Acceptance and Pressure for directional bias, and combine the POC/VAH/VAL levels with your own structure, liquidity, order blocks or session tools for higher-conviction entries.
Multi-timeframe: raise the Lookback for higher-timeframe value (swing context), lower it for intraday/scalping context. Increase Rows for more precise POC placement.

◆ SETTINGS

Volume Profile Engine: Lookback (bars), Rows (resolution), Value Area %, true-range volume distribution toggle.
Profile Look: width, gap from price, anchor side (right of price / classic overlay), Value-Area / outside / POC colours.
Levels: POC ray, VAH/VAL rays, optional Value-Area shading, ray extension, label size (Small → Huge).
Neon Candles: gradient candles (turquoise bullish / magenta bearish) with momentum-scaled glow halo.
Panel: show/hide, position, background and accent colour.

◆ ALERTS

Price crossed POC
Breakout above VAH
Breakdown below VAL

◆ NON-REPAINTING
The profile, levels and dashboard are single objects rendered on the last bar over a fixed rolling lookback — historical bars are never repainted. As with any live tool, the current bar is included in the calculation, so the real-time read updates tick by tick and settles on close; closed history never changes.

Smart Volume Profile VPVR is an educational analysis tool, not financial advice. Volume profile reflects historical traded volume and does not predict future prices. Always do your own research and manage risk. © LunqFX.

## Source Code

````pine
//@version=6
// ============================================================================
//  Volume Profile [LunqFX] — POC, Value Area & Volume Nodes
// ----------------------------------------------------------------------------
//  A clean, modern Volume Profile for any chart. It splits a lookback window
//  into price rows, distributes each bar's volume across the prices it traded
//  through, then surfaces the three levels that actually matter:
//
//      • POC  (Point of Control)  — the single most-traded price = fair value
//      • VAH  (Value Area High)   — top of the 70% volume zone
//      • VAL  (Value Area Low)    — bottom of the 70% volume zone
//
//  Rows inside the Value Area glow brighter; the POC row is highlighted. High
//  Volume Nodes (HVN) act as magnets / support-resistance, Low Volume Nodes
//  (LVN) are where price moves fast. All three levels extend as live rays so
//  you can trade the mean-reversion to POC or the breakout through value.
//
//  NON-REPAINTING: nothing is drawn on historical bars — the whole profile,
//  levels and panel are single objects rendered on the last bar over a fixed
//  rolling lookback. Past bars are never re-painted. Like any live tool it
//  includes the forming bar, so the current read updates intrabar and settles
//  on close; closed history never changes.
// ============================================================================
indicator("Smart Volume Profile VPVR — POC, Value Area & Support Resistance [LunqFX]", "Smart Volume Profile [LunqFX]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (modern neon — turquoise = value/bull, violet = bear/accent)
// ─────────────────────────────────────────────────────────────────────────
NEON_TURQ = #00E5D0
NEON_VIO  = #B026FF
NEON_GOLD = #FFC247
TUR_MID   = #12B8A6
TUR_HI    = #4DFCE6
VIO_MID   = #7A2BD6
VIO_HI    = #D070FF
INK       = #0B0E14
SLATE     = #5B6472

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gVP     = "Volume Profile Engine"
lookback= input.int(250,  "Lookback (bars)",        minval = 20, maxval = 5000, group = gVP, tooltip = "How many confirmed bars are aggregated into the profile.")
rows    = input.int(60,   "Rows (resolution)",      minval = 12, maxval = 200, group = gVP, tooltip = "Number of price buckets. Higher = finer profile, POC more precise.")
vaPct   = input.float(70, "Value Area %",           minval = 40, maxval = 95, step = 5, group = gVP, tooltip = "Share of total volume that defines the Value Area around the POC. 70% is the market standard.")
useRange= input.bool(true,"Spread volume across bar range", group = gVP, tooltip = "ON = each bar's volume is distributed across every price it traded through (true profile). OFF = all volume dropped at the bar close (faster, coarser).")

gDraw   = "Profile Look"
profW   = input.int(90,   "Profile width (bars)",   minval = 10, maxval = 400, group = gDraw, tooltip = "Horizontal length of the longest (POC) row, in bars.")
gapBars = input.int(6,    "Gap from price (bars)",  minval = 0, maxval = 100, group = gDraw, tooltip = "Space between the last candle and the profile.")
side    = input.string("Right of price","Anchor",   options = ["Right of price","Left (overlay)"], group = gDraw, tooltip = "Right = histogram sits to the right of the last bar. Left = classic overlay growing leftward from the right edge.")
vaCol   = input.color(NEON_TURQ, "Value Area rows", group = gDraw)
outCol  = input.color(SLATE,     "Outside-VA rows", group = gDraw)
pocCol  = input.color(NEON_GOLD, "POC row",         group = gDraw)

gLvl    = "Levels"
showPOC = input.bool(true, "POC ray",  group = gLvl)
showVA  = input.bool(true, "VAH / VAL rays", group = gLvl)
showVAfill = input.bool(false, "Shade Value Area band (subtle)", group = gLvl, tooltip = "Faint tint between VAH and VAL. Off by default so it never washes out the candles.")
extRight= input.int(15,   "Ray extend (bars)",      minval = 0, maxval = 200, group = gLvl)
lblSize = input.string("Large","Label size", options = ["Small","Normal","Large","Huge"], group = gLvl)

gCandle = "Neon Candles"
neonOn  = input.bool(true, "Neon gradient candles", group = gCandle, tooltip = "Glowing candles. Turquoise = bullish, magenta/pink = bearish, intensity scales with momentum.")
neonGlow= input.bool(true, "Glow halo",             group = gCandle)

gPanel  = "Panel"
showHUD = input.bool(true, "Show panel",            group = gPanel)
hudPos  = input.string("Top Right","Position",      options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gPanel)
hudBg   = input.color(#0B0E14, "Background",        group = gPanel)
accent  = input.color(NEON_TURQ,"Accent",           group = gPanel)

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

f_fmt(float v) =>
    str.tostring(v, format.mintick)

f_lblSize(string s) =>
    switch s
        "Small"  => size.small
        "Normal" => size.normal
        "Huge"   => size.huge
        => size.large

// ─────────────────────────────────────────────────────────────────────────
//  PROFILE STATE  (rebuilt on the last confirmed bar)
// ─────────────────────────────────────────────────────────────────────────
var box[]  rowBoxes = array.new<box>()
var line   pocLine  = na
var line   vahLine  = na
var line   valLine  = na
var label  pocLab   = na
var label  vahLab   = na
var label  valLab   = na
var box    vaFill   = na

// Exposed stats for the panel.
var float pocPrice = na
var float vahPrice = na
var float valPrice = na
var float vaShare  = na
var int   nBars    = 0
var float volAbove = na    // volume traded above the POC
var float volBelow = na    // volume traded below the POC
var float buyVol   = na    // volume on up-bars in the window
var float sellVol  = na    // volume on down-bars in the window

// Build once, on the last confirmed bar — no repaint of history. Kept in the
// global scope (not a function) because Pine forbids reassigning globals inside
// a user function.
if barstate.islast
    n  = math.min(lookback, bar_index)            // bars actually available
    nBars := n
    if n >= 5
        // 1) window extremes over confirmed bars (offset 0 = current closed bar on last)
        hi = high
        lo = low
        for i = 0 to n - 1
            hi := math.max(hi, high[i])
            lo := math.min(lo, low[i])
        rng = hi - lo
        if rng > 0
            binH = rng / rows
            vol  = array.new<float>(rows, 0.0)
            bV   = 0.0
            sV   = 0.0

            // 2) distribute volume into price buckets (+ track buy/sell pressure)
            for i = 0 to n - 1
                v = nz(volume[i], 0.0)
                if v > 0
                    if close[i] >= open[i]
                        bV += v
                    else
                        sV += v
                    if useRange and (high[i] - low[i]) > 0
                        loB = math.floor((low[i]  - lo) / binH)
                        hiB = math.floor((high[i] - lo) / binH)
                        loB := math.max(0, math.min(rows - 1, loB))
                        hiB := math.max(0, math.min(rows - 1, hiB))
                        span = hiB - loB + 1
                        share = v / span
                        for b = loB to hiB
                            array.set(vol, b, array.get(vol, b) + share)
                    else
                        b = math.floor((close[i] - lo) / binH)
                        b := math.max(0, math.min(rows - 1, b))
                        array.set(vol, b, array.get(vol, b) + v)

            // 3) POC + totals
            total  = array.sum(vol)
            pocIdx = array.indexof(vol, array.max(vol))
            maxV   = array.max(vol)

            // 4) value area: expand out from POC until vaPct of volume is enclosed
            target = total * (vaPct / 100.0)
            acc    = array.get(vol, pocIdx)
            up     = pocIdx
            dn     = pocIdx
            while acc < target and (up < rows - 1 or dn > 0)
                vUp = up < rows - 1 ? array.get(vol, up + 1) : -1.0
                vDn = dn > 0        ? array.get(vol, dn - 1) : -1.0
                if vUp >= vDn and vUp >= 0
                    up += 1
                    acc += vUp
                else if vDn >= 0
                    dn -= 1
                    acc += vDn
                else
                    break

            // 5) prices
            pocPrice := lo + (pocIdx + 0.5) * binH
            vahPrice := lo + (up + 1) * binH
            valPrice := lo + dn * binH
            vaShare  := total > 0 ? acc / total * 100.0 : na

            // 5b) derived analytics for the panel (not shown on the chart)
            aV = 0.0
            bbV = 0.0
            for b = 0 to rows - 1
                if b > pocIdx
                    aV += array.get(vol, b)
                else if b < pocIdx
                    bbV += array.get(vol, b)
            volAbove := aV
            volBelow := bbV
            buyVol   := bV
            sellVol  := sV

            // 6) geometry
            rightAnchor = bar_index + gapBars
            dir = side == "Left (overlay)" ? -1 : 1

            // clear previous boxes
            if array.size(rowBoxes) > 0
                for i = 0 to array.size(rowBoxes) - 1
                    box.delete(array.get(rowBoxes, i))
                array.clear(rowBoxes)

            // 7) draw each row — colour by volume so the profile GLOWS, gap
            //    between rows for a clean modern histogram (not a solid block).
            for b = 0 to rows - 1
                rv = array.get(vol, b)
                len = maxV > 0 ? math.round(rv / maxV * profW) : 0
                if len > 0
                    frac  = rv / maxV                       // 0..1 within the profile
                    yLo   = lo + b * binH + binH * 0.10     // small vertical gap
                    yHi   = lo + (b + 1) * binH - binH * 0.10
                    inVA  = b >= dn and b <= up
                    isPOC = b == pocIdx
                    // gradient: dim base -> bright neon as volume grows
                    col = isPOC ? pocCol :
                          inVA  ? color.from_gradient(frac, 0, 1, TUR_MID, TUR_HI) :
                                  color.from_gradient(frac, 0, 1, #2A3340, #6E7B8F)
                    tr  = isPOC ? 0 : inVA ? math.round(35 - frac * 25) : math.round(60 - frac * 25)
                    x1  = dir == 1 ? rightAnchor : rightAnchor - len
                    x2  = dir == 1 ? rightAnchor + len : rightAnchor
                    bx  = box.new(x1, yHi, x2, yLo, border_width = 0, bgcolor = color.new(col, tr))
                    array.push(rowBoxes, bx)

            // 8) level rays — extend fully ACROSS the profile so they read cleanly
            profEnd = dir == 1 ? rightAnchor + profW : rightAnchor
            rayL = bar_index - n + 1
            rayR = profEnd + extRight
            labX = profEnd + 2                              // labels live past the bars
            if showPOC
                if na(pocLine)
                    pocLine := line.new(rayL, pocPrice, rayR, pocPrice, color = pocCol, width = 2)
                    pocLab  := label.new(labX, pocPrice, "", style = label.style_label_left, color = color.new(pocCol, 0), textcolor = INK, size = f_lblSize(lblSize))
                line.set_xy1(pocLine, rayL, pocPrice)
                line.set_xy2(pocLine, rayR, pocPrice)
                line.set_color(pocLine, pocCol)
                label.set_xy(pocLab, labX, pocPrice)
                label.set_text(pocLab, " POC  " + f_fmt(pocPrice) + " ")
            if showVA
                if na(vahLine)
                    vahLine := line.new(rayL, vahPrice, rayR, vahPrice, color = vaCol, width = 1, style = line.style_dashed)
                    valLine := line.new(rayL, valPrice, rayR, valPrice, color = vaCol, width = 1, style = line.style_dashed)
                    vahLab  := label.new(labX, vahPrice, "", style = label.style_label_left, color = color.new(vaCol, 0), textcolor = INK, size = f_lblSize(lblSize))
                    valLab  := label.new(labX, valPrice, "", style = label.style_label_left, color = color.new(vaCol, 0), textcolor = INK, size = f_lblSize(lblSize))
                line.set_xy1(vahLine, rayL, vahPrice)
                line.set_xy2(vahLine, rayR, vahPrice)
                line.set_xy1(valLine, rayL, valPrice)
                line.set_xy2(valLine, rayR, valPrice)
                label.set_xy(vahLab, labX, vahPrice)
                label.set_xy(valLab, labX, valPrice)
                label.set_text(vahLab, " VAH  " + f_fmt(vahPrice) + " ")
                label.set_text(valLab, " VAL  " + f_fmt(valPrice) + " ")
            if showVAfill
                if na(vaFill)
                    vaFill := box.new(rayL, vahPrice, rightAnchor, valPrice, border_width = 0, bgcolor = color.new(vaCol, 96))
                box.set_lefttop(vaFill, rayL, vahPrice)
                box.set_rightbottom(vaFill, rightAnchor, valPrice)
                box.set_bgcolor(vaFill, color.new(vaCol, 96))

// ─────────────────────────────────────────────────────────────────────────
//  NEON GRADIENT CANDLES
// ─────────────────────────────────────────────────────────────────────────
// High-contrast modern neon: bullish = teal, bearish = hot magenta/pink.
// Intensity scales with candle momentum vs ATR so strong bars glow brighter.
PINK_MID = #FF2E63
PINK_HI  = #FF6FA3
mom      = math.abs(close - open)
atr14    = ta.atr(14)
strength = atr14 > 0 ? math.min(1.0, mom / atr14) : 0.0
upCol    = color.from_gradient(strength, 0, 1, TUR_MID, TUR_HI)
dnCol    = color.from_gradient(strength, 0, 1, PINK_MID, PINK_HI)
bull     = close >= open
bodyCol  = bull ? upCol : dnCol
edgeCol  = bull ? TUR_HI : PINK_HI

// Two glow halos (wide + tight) for a real neon bloom, then the crisp body.
plotcandle(neonOn and neonGlow ? open : na, high, low, close, title = "Glow Outer", color = color.new(edgeCol, 88), wickcolor = color.new(edgeCol, 80), bordercolor = color.new(edgeCol, 70))
plotcandle(neonOn and neonGlow ? open : na, high, low, close, title = "Glow Inner", color = color.new(edgeCol, 72), wickcolor = color.new(edgeCol, 45), bordercolor = color.new(edgeCol, 40))
plotcandle(neonOn ? open : na,              high, low, close, title = "Neon Candles", color = bodyCol, wickcolor = edgeCol, bordercolor = edgeCol)

// ─────────────────────────────────────────────────────────────────────────
//  PANEL
// ─────────────────────────────────────────────────────────────────────────
// Modern flat panel: one uniform surface, muted labels, a single hero metric,
// a colour-coded status pill and a live "price inside Value Area" meter.
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudPosition(hudPos), 2, 7, bgcolor = color.new(#0C0F16, 0), border_width = 0, frame_color = color.new(#222A38, 0), frame_width = 1)

    // palette
    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #1A2130), 0)
    MUTE  = #5C6675
    INKHI = #EAEEF6
    teal  = accent
    gold  = #FFB938
    pink  = #FF4D7D

    have  = not na(pocPrice)
    above = have and close > vahPrice
    below = have and close < valPrice

    // ── derived analytics (none of this is on the chart) ──
    // distance to POC (the mean-reversion target) in % and price
    dPct = have and close != 0 ? (pocPrice - close) / close * 100.0 : na
    dStr = na(dPct) ? "—" : (dPct >= 0 ? "+" : "") + str.tostring(dPct, "#.##") + "%"

    // live meter: how high price sits across VAL → VAH (slider fill)
    meter = "▱▱▱▱▱▱▱▱▱▱"
    if have and vahPrice > valPrice
        segN = 10
        t    = math.max(0.0, math.min(1.0, (close - valPrice) / (vahPrice - valPrice)))
        fN   = math.round(t * segN)
        m2 = ""
        for i = 1 to segN
            m2 := m2 + (i <= fN ? "▰" : "▱")
        meter := m2

    // volume acceptance: share of volume built ABOVE vs BELOW the POC
    accTot = nz(volAbove) + nz(volBelow)
    accUp  = accTot > 0 ? nz(volAbove) / accTot * 100.0 : 50.0
    accStr = accTot > 0 ? str.tostring(math.round(100 - accUp)) + "% ▼ / ▲ " + str.tostring(math.round(accUp)) + "%" : "—"
    accC   = accUp >= 55 ? teal : accUp <= 45 ? pink : MUTE

    // buy/sell pressure across the window
    prTot  = nz(buyVol) + nz(sellVol)
    buyP   = prTot > 0 ? nz(buyVol) / prTot * 100.0 : 50.0
    barN   = 10
    fillN  = math.round(buyP / 100.0 * barN)
    pbar   = ""
    for i = 1 to barN
        pbar := pbar + (i <= fillN ? "▰" : "▱")
    prC    = buyP >= 55 ? teal : buyP <= 45 ? pink : gold

    // ── SMART SIGNAL: distinguish ROTATION (revert) from BREAKOUT (continuation) ──
    // Order-flow = blend of buy pressure (window) and acceptance (volume vs POC).
    // >50 = net bullish flow, <50 = net bearish flow.
    flow   = (buyP + accUp) / 2.0
    bullOF = flow >= 55          // order-flow leans up
    bearOF = flow <= 45          // order-flow leans down
    sigT = "—"
    sigC = MUTE
    if have
        if below
            // price under value: revert up ONLY if flow isn't confirming the drop
            sigT := bearOF ? "▼ BREAKDOWN" : "▲ LONG revert"
            sigC := bearOF ? pink : teal
        else if above
            // price over value: revert down ONLY if flow isn't confirming the push
            sigT := bullOF ? "▲ BREAKOUT" : "▼ SHORT revert"
            sigC := bullOF ? teal : pink
        else
            sigT := "● BALANCED"
            sigC := gold

    // row 0 — header
    table.cell(hud, 0, 0, "  ◆ VOLUME PROFILE", text_color = INKHI, text_size = size.normal, text_halign = text.align_left,  bgcolor = HEADR)
    table.cell(hud, 1, 0, "VPVR · LunqFX  ",    text_color = teal,  text_size = size.normal, text_halign = text.align_right, bgcolor = HEADR)

    // row 1 — SIGNAL (hero)
    table.cell(hud, 0, 1, "  Signal", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 1, sigT + "  ", text_color = sigC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    // row 2 — distance to POC (the target)
    table.cell(hud, 0, 2, "  → POC", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 2, dStr + "  ", text_color = INKHI, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    // row 3 — live position inside value area
    table.cell(hud, 0, 3, "  In VA", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 3, meter + "  ", text_color = sigC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    // row 4 — volume acceptance around POC (below ▼ / ▲ above)
    table.cell(hud, 0, 4, "  Acceptance", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 4, accStr + "  ", text_color = accC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    // row 5 — buy/sell pressure meter
    table.cell(hud, 0, 5, "  Pressure", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 5, pbar + " " + str.tostring(math.round(buyP)) + "%  ", text_color = prC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    // row 6 — footer meta
    table.cell(hud, 0, 6, "  " + str.tostring(nBars) + " bars", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = HEADR)
    table.cell(hud, 1, 6, "VA " + (na(vaShare) ? "—" : str.tostring(math.round(vaShare))) + "%  ", text_color = MUTE, text_size = size.normal, text_halign = text.align_right, bgcolor = HEADR)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(not na(pocPrice) and ta.cross(close, pocPrice), "Price crossed POC",  "Price crossed the Point of Control")
alertcondition(not na(vahPrice) and ta.crossover(close, vahPrice),  "Breakout above VAH", "Price broke above the Value Area High")
alertcondition(not na(valPrice) and ta.crossunder(close, valPrice), "Breakdown below VAL","Price broke below the Value Area Low")
````
