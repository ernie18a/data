# Strong Rejection Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/mO6whE7e-Strong-Rejection-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;06fa5d20feb7452f8e5a61288e57d30a
- version: 1.0

## Description

[b]STRONG REJECTION ZONES

Strong Rejection Zones marks the prices where the market keeps getting pushed back, and grades every one of them so you can tell at a glance which levels are worth respecting and which are likely to fold. It scans for three independent signatures of rejection — swing pivots, dominant rejection wicks, and volume spikes — folds overlapping hits at the same price into a single zone, and assigns each zone a live 0–10 power score built only from measurable level quality. Heavily-confirmed zones are drawn bold and solid; thin, one-off levels stay faint. An on-chart leaderboard ranks every live zone, so the whole support-and-resistance map is readable in one look.[/b]

🎯 0–10 POWER SCORE
Each zone earns a live grade from four weighted, sign-stable factors:
Confluence — how many separate detections stack at the level, with diminishing returns so one isolated touch never scores high on its own.
Diversity — a level confirmed by pivots AND wicks AND volume outranks one confirmed a single way.
Detection strength — volume versus its baseline, wick dominance, and range expansion on the candle that formed the level.
Recency — recently defended levels rank above stale ones, with a configurable decay.

ELITE (9–10) is intentionally hard to reach: in practice it takes all three footprint types lining up on a strong, fresh, well-confirmed level — so the grade reflects real edge, not decoration. All four weights are adjustable.
🏷️ IN-ZONE LABELS
Every graded zone carries a tag above the band — side (BULL / BEAR), tier, the X/10 score, a star rating, the confluence count (×N detections), and live distance from price in both percent and pips. The tag is pinned to the zone's right edge and grows inward, so it never hangs off the box.
🧲 CONFLUENCE MERGING
Same-side detections that land within the cluster tolerance are folded into one zone and raise its grade, instead of littering the chart with a separate line for every swing. One graded level per pool.
🥇 ELITE HIGHLIGHT
The top tier is rendered in a brighter shade of its side colour with a heavy accent border, so the levels that matter jump out before you read a single number. Tier ladder: FAINT → WEAK → MEDIUM → STRONG → ELITE.
🎨 STRENGTH-SHADED FILL
Fill opacity tracks the score — strong zones print solid, weak ones stay faint — so relative importance is visible without reading any text.

📊 RANKED DASHBOARD
A leaderboard sorts active zones by power and shows rank, side, tier, exact price, score with stars, and distance + direction from price (▲ above / ▼ below). Choose any of four corners, four text sizes (Tiny → Large), and how many rows to show. A header line summarises how many ELITE / STRONG / active zones are live.
📍 ORIGIN-ANCHORED ZONES
Each zone is drawn from the bar where its level first formed and extended to the right. It stays anchored to that price — it does not drift or re-center as new detections arrive, so the band always sits on the price action that created it.
🔒 STABLE, LOCK-IN ZONES
Zones are built only on confirmed bars and updated in place. A zone keeps its grade, tier and position once it is drawn; it only changes state when price genuinely breaches it (by close or by wick — your choice), at which point it either clears or stays on as a faded broken level.
🧹 CLEAN-UP FILTERS
Hide any zone under a chosen power score, enforce a minimum separation between same-side zones, and suppress zones forming right on top of current price.
🔔 NATIVE ALERTS
Dedicated alerts for an ELITE cluster forming, a STRONG cluster forming, a zone being breached, fresh bullish and bearish detections, and price approaching a STRONG or an ELITE zone.

🔧 FULLY ADJUSTABLE
Detection toggles and sensitivity (pivot length, wick-dominance ratio, volume-spike multiple, baseline length); clustering tolerance and minimum separation; zone geometry (ATR length, height, max active zones, right-extension); the four score weights plus confluence-for-full-credit, decay length and decay floor; score and distance filters, breach method (close or wick), and keep-or-clear on breach; the full colour theme (bull, bear, broken, accent), fill-opacity range and ELITE border width; label size and which scores get labelled; dashboard position, rows and text size; and alert thresholds.

🚀 Works on gold (XAUUSD), silver, forex, crypto and indices, on any timeframe.
────────────────────────
HOW TO TRADE IT — TWO APPROACHES
The score chooses the playbook. High-grade zones tend to hold and reverse; thin zones tend to give way. So treat them differently.

FADE THE ZONE — reversion (STRONG / ELITE, score ≥ 7)

Use when price is approaching a high-grade zone — the most-confirmed levels, and statistically the most likely to react.

Wait for price to tap the zone (the dashboard distance shows it closing in).
Look for a wick into the band and a close back outside it.
Enter on the rejection back out of the zone.
Stop just past the far edge — a sustained close through it means the level failed.
Target the next zone on the dashboard, then the nearest strong zone on the opposite side.

TRADE THE BREAK — continuation (WEAK / MEDIUM, or once a strong zone breaches)

Use on thin, single-type or stale levels — the ones most likely to break.

Wait for a decisive close through the zone on expanding volume, not a single wick.
The zone switching to a broken state is your confirmation it is a real break, not a stop-hunt.
Enter with the break beyond the zone, or on a retest of the broken level.
Stop back inside the broken zone.
Target the next zone in that direction.

Rule of thumb: high-grade → expect a reaction, fade the tap. Low-grade on volume → expect follow-through, trade the break.
────────────────────────
⚠️ This tool highlights high-probability rejection levels and frames fade-versus-break scenarios. It is NOT a standalone buy/sell signal. Always combine it with your own strategy, price-action analysis and risk management to confirm setups. Past statistical behaviour does not guarantee future results.

## Source Code

````pine
//@version=6

indicator("Strong Rejection Zones", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

grpDet = "① Detection footprints"
detPivot   = input.bool(true,  "Swing pivots",         group=grpDet, inline="p")
pivotLen   = input.int(15,     "len",                  group=grpDet, inline="p", minval=2, maxval=60, tooltip="Pivot left/right strength. Higher = fewer, more significant swings.")
detWick    = input.bool(true,  "Wick-rejection traps", group=grpDet, inline="w")
wickRatio  = input.float(0.55, "ratio",                group=grpDet, inline="w", minval=0.3, maxval=0.9, step=0.05, tooltip="Min share of the candle range taken by the rejection wick.")
detVol     = input.bool(true,  "Volume spikes",        group=grpDet, inline="v")
volMult    = input.float(2.0,  "× baseline",           group=grpDet, inline="v", minval=1.2, maxval=6.0, step=0.1, tooltip="Volume must exceed this multiple of its moving baseline.")
volLen     = input.int(20,     "Volume / range baseline length", group=grpDet, minval=5, maxval=200)

grpClu = "② Clustering & zone geometry"
clusterATR = input.float(0.30, "Cluster tolerance (ATR ×)", group=grpClu, minval=0.1, maxval=3.0, step=0.05, tooltip="Detections within this distance of an active zone merge into it instead of spawning a new one.")
zoneHtATR  = input.float(0.55, "Zone height (ATR ×)",       group=grpClu, minval=0.1, maxval=3.0, step=0.05, tooltip="Uniform band thickness, centred on the pooled liquidity.")
atrLen     = input.int(200,    "ATR length",                group=grpClu, minval=5, maxval=500)
maxZones   = input.int(20,     "Max active zones",          group=grpClu, minval=2, maxval=30, tooltip="Oldest / weakest zone is freed past this so loading stays fast.")
minSepATR  = input.float(0.20, "Min separation (ATR ×)",    group=grpClu, minval=0.0, maxval=3.0, step=0.05, tooltip="New zones closer than this to an existing same-side zone are merged.")
extendRight= input.int(30,     "Extend zones right (bars)",  group=grpClu, minval=0, maxval=300)

grpScore = "③ Strength scoring (0–10)"
wConf  = input.float(0.30, "Weight: Confluence", group=grpScore, minval=0, maxval=1, step=0.05)
wDiv   = input.float(0.25, "Weight: Diversity",  group=grpScore, minval=0, maxval=1, step=0.05)
wStr   = input.float(0.25, "Weight: Strength",   group=grpScore, minval=0, maxval=1, step=0.05)
wRec   = input.float(0.20, "Weight: Recency",    group=grpScore, minval=0, maxval=1, step=0.05)
confFull = input.int(4,    "Confluence for full credit", group=grpScore, minval=2, maxval=12, tooltip="How many stacked detections count as maximum confluence.")
decayBars= input.int(400,  "Full recency decay (idle bars)", group=grpScore, minval=20, maxval=5000)
decayFloor=input.float(0.45,"Recency floor", group=grpScore, minval=0.05, maxval=1.0, step=0.05)

grpFilt = "④ Filters"
minScore   = input.float(0.0, "Hide zones below score", group=grpFilt, minval=0, maxval=10, step=0.5)
minDistATR = input.float(0.0, "Min distance from price (ATR ×)", group=grpFilt, minval=0.0, maxval=10.0, step=0.1, tooltip="Suppress zones forming right on top of current price.")
invalidMethod = input.string("Close", "Breach by", options=["Close","Wick"], group=grpFilt, tooltip="A zone is breached on a closing penetration (Close) or any wick through it (Wick).")
keepBroken = input.bool(false, "Keep broken zones (faded)", group=grpFilt, tooltip="Off = remove on breach. On = recolour to broken tone and keep as historic.")

grpStyle = "⑤ Style"
bullCol   = input.color(#21c997, "Demand / support tone",   group=grpStyle)
bearCol   = input.color(#cc24e2, "Supply / resistance tone", group=grpStyle)
brokenCol = input.color(#5a5a5a, "Broken-zone tone",        group=grpStyle)
maxTransp = input.int(92, "Faint fill transparency", group=grpStyle, minval=60, maxval=98, tooltip="Transparency of the weakest visible zones.")
minTransp = input.int(68, "Strong fill transparency", group=grpStyle, minval=40, maxval=95, tooltip="Transparency of the strongest zones (lower = more opaque).")
eliteBord = input.int(3,  "ELITE border width", group=grpStyle, minval=1, maxval=5)
showLabels= input.bool(true, "Show in-zone strength labels", group=grpStyle)
minLblScr = input.float(5.0, "Label only zones scoring ≥", group=grpStyle, minval=0, maxval=10, step=0.5)
labSize   = input.string("Small", "Label size", options=["Tiny","Small","Normal","Large"], group=grpStyle)

grpDash = "⑥ Dashboard"
showDash  = input.bool(true,  "Show leaderboard dashboard", group=grpDash)
dashPos   = input.string("Top Right", "Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpDash)
dashRows  = input.int(8, "Max ranked rows", group=grpDash, minval=3, maxval=20)
dashSize  = input.string("Small", "Text size", options=["Tiny","Small","Normal","Large"], group=grpDash)

grpAlert = "⑦ Alerts"
alertProxATR = input.float(0.50, "Proximity (ATR ×)", group=grpAlert, minval=0.05, maxval=5.0, step=0.05, tooltip="Proximity alerts fire when price is within this distance of a zone midline.")
strongThr = input.float(7.0, "STRONG threshold (score)", group=grpAlert, minval=0, maxval=10, step=0.5)
eliteThr  = input.float(9.0, "ELITE threshold (score)",  group=grpAlert, minval=0, maxval=10, step=0.5)

accent = input.color(#00B4D8, "Accent (ELITE highlight)", group=grpStyle)

C_BG0     = color.new(#0D0D0D, 0)
C_BG1     = color.new(#141414, 0)
C_BG2     = color.new(#1E1E1E, 0)
C_BG3     = color.new(#2A2A2A, 0)
C_TXT_PRI = color.new(#E8E8E8, 0)
C_TXT_SEC = color.new(#9A9A9A, 0)

f_pos(s)  => s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Bottom Left" ? position.bottom_left : position.bottom_right
f_size(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large
f_stars(sc) => sc >= 9 ? "★★★★★" : sc >= 7 ? "★★★★" : sc >= 5 ? "★★★" : sc >= 3 ? "★★" : "★"
f_tier(sc)  => sc >= eliteThr ? "ELITE" : sc >= strongThr ? "STRONG" : sc >= 5 ? "MEDIUM" : sc >= 3 ? "WEAK" : "FAINT"
f_fmt1(x) => na(x) ? "-" : str.tostring(math.round(x * 10) / 10)

f_toPips(val) =>
    pipVal = syminfo.type == "forex" ? (syminfo.currency == "JPY" ? 0.01 : 0.0001) : (syminfo.mintick * 10)
    math.abs(val) / pipVal

f_fillTransp(sc) => int(maxTransp - (math.min(sc, 10.0) / 10.0) * (maxTransp - minTransp))

f_score(int conf, int diversity, float strAvg, int age) =>
    cF = 1.0 - 1.0 / math.max(conf, 1)
    cF := math.min(cF / (1.0 - 1.0 / math.max(confFull, 2)), 1.0)
    dF = (diversity - 1) / 2.0
    sF = math.min(math.max(strAvg, 0.0), 1.0)
    rF = math.max(1.0 - math.min(age / math.max(decayBars, 1), 1.0) * (1.0 - decayFloor), decayFloor)
    wSum = wConf + wDiv + wStr + wRec
    raw = wSum > 0 ? (cF * wConf + dF * wDiv + sF * wStr + rF * wRec) / wSum : 0.0
    math.min(math.max(raw * 10.0, 0.0), 10.0)

type Zone
    box   bx       = na
    label tag      = na
    float top      = na
    float bot      = na
    float mid      = na
    int   side     = 0
    int   bornBar  = na
    int   lastBar  = na
    int   conf     = 0
    bool  hasPivot = false
    bool  hasWick  = false
    bool  hasVol   = false
    float strSum   = 0.0
    int   strN     = 0
    float score    = 0.0
    bool  broken   = false

var array<Zone> zones = array.new<Zone>()

n       = bar_index
atr     = nz(ta.atr(atrLen), ta.cum(high - low) / (n + 1))
volBase = ta.sma(volume, volLen)
rng     = high - low
upWick  = high - math.max(open, close)
dnWick  = math.min(open, close) - low
volRatio = volBase > 0 ? volume / volBase : 0.0
rangeExp = atr > 0 ? rng / atr : 0.0
wickDomUp = rng > 0 ? upWick / rng : 0.0
wickDomDn = rng > 0 ? dnWick / rng : 0.0

ph = detPivot ? ta.pivothigh(pivotLen, pivotLen) : na
pl = detPivot ? ta.pivotlow(pivotLen, pivotLen)  : na

f_detStr(float wickDom) =>
    vN = math.min(volRatio / math.max(volMult, 1.0), 1.0)
    rN = math.min(rangeExp / 2.0, 1.0)
    math.min(0.40 * vN + 0.35 * wickDom + 0.25 * rN, 1.0)

f_addDetection(float price, int side, int dtype, float dstr, int originBar) =>
    float tol  = atr * clusterATR
    float sep  = atr * minSepATR
    int   best = -1
    float bestD = 1e20
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            if not z.broken and z.side == side
                float d = math.abs(price - z.mid)
                if (d <= tol or d <= sep) and d < bestD
                    bestD := d
                    best  := i
    if best >= 0
        Zone z = array.get(zones, best)
        z.conf    += 1
        z.strSum  += dstr
        z.strN    += 1
        z.lastBar := n
        z.hasPivot := z.hasPivot or dtype == 0
        z.hasWick  := z.hasWick  or dtype == 1
        z.hasVol   := z.hasVol   or dtype == 2
    else
        float h = atr * zoneHtATR
        Zone z = Zone.new()
        z.side    := side
        z.mid     := price
        z.top     := price + h / 2.0
        z.bot     := price - h / 2.0
        z.bornBar := originBar
        z.lastBar := n
        z.conf    := 1
        z.strSum  := dstr
        z.strN    := 1
        z.hasPivot := dtype == 0
        z.hasWick  := dtype == 1
        z.hasVol   := dtype == 2
        z.bx := box.new(originBar, z.top, n + extendRight, z.bot, bgcolor=color.new(side == 1 ? bullCol : bearCol, maxTransp), border_color=color.new(side == 1 ? bullCol : bearCol, 40), border_width=1)
        array.push(zones, z)
    true

f_enforceCap() =>
    while array.size(zones) > maxZones
        int worst = 0
        float ws = 1e20
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            float key = z.broken ? -1.0 : z.score
            if key < ws
                ws := key
                worst := i
        Zone z = array.remove(zones, worst)
        box.delete(z.bx)
        label.delete(z.tag)

bool evNewBull = false
bool evNewBear = false

if barstate.isconfirmed

    if detPivot and not na(ph)
        f_addDetection(ph, -1, 0, f_detStr(wickDomUp[pivotLen]), n - pivotLen)
        evNewBear := true
    if detPivot and not na(pl)
        f_addDetection(pl, 1, 0, f_detStr(wickDomDn[pivotLen]), n - pivotLen)
        evNewBull := true

    if detWick and rng > 0
        if wickDomUp >= wickRatio
            f_addDetection(high, -1, 1, f_detStr(wickDomUp), n)
            evNewBear := true
        if wickDomDn >= wickRatio
            f_addDetection(low, 1, 1, f_detStr(wickDomDn), n)
            evNewBull := true

    if detVol and volBase > 0 and volume >= volBase * volMult
        if close >= open
            f_addDetection(low, 1, 2, f_detStr(math.max(wickDomDn, 0.4)), n)
            evNewBull := true
        else
            f_addDetection(high, -1, 2, f_detStr(math.max(wickDomUp, 0.4)), n)
            evNewBear := true

bool evBreach = false
bool evElite  = false
bool evStrong = false

if barstate.isconfirmed and array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        Zone z = array.get(zones, i)
        if not z.broken

            bool brk = z.side == 1 ? (invalidMethod == "Close" ? close < z.bot : low < z.bot) : (invalidMethod == "Close" ? close > z.top : high > z.top)
            if brk
                z.broken := true
                evBreach := true
                box.set_bgcolor(z.bx, color.new(brokenCol, 88))
                box.set_border_color(z.bx, color.new(brokenCol, 60))
                box.set_border_width(z.bx, 1)
                if not na(z.tag)
                    label.set_text(z.tag, "")
                if not keepBroken
                    box.delete(z.bx)
                    label.delete(z.tag)
                    array.set(zones, i, Zone.new())
            else

                int diversity = (z.hasPivot ? 1 : 0) + (z.hasWick ? 1 : 0) + (z.hasVol ? 1 : 0)
                float strAvg = z.strN > 0 ? z.strSum / z.strN : 0.0
                float sc = f_score(z.conf, diversity, strAvg, n - z.lastBar)
                z.score := sc

                bool farEnough = math.abs(close - z.mid) >= atr * minDistATR
                bool vis = sc >= minScore and farEnough
                bool elite = sc >= eliteThr

                color sideC = z.side == 1 ? bullCol : bearCol
                int ft = f_fillTransp(sc)
                box.set_bgcolor(z.bx, vis ? color.new(sideC, elite ? math.max(ft - 10, 40) : ft) : na)
                box.set_border_color(z.bx, vis ? (elite ? color.new(accent, 0) : color.new(sideC, 40)) : na)
                box.set_border_width(z.bx, elite ? eliteBord : 1)
                box.set_top(z.bx, z.top)
                box.set_bottom(z.bx, z.bot)
                box.set_right(z.bx, n + extendRight)

                if sc >= eliteThr
                    evElite := true
                else if sc >= strongThr
                    evStrong := true

                if showLabels and vis and sc >= minLblScr
                    string arrow = z.side == 1 ? "▲" : "▼"
                    string sideStr = z.side == 1 ? "BULL" : "BEAR"
                    float distPct = close != 0 ? math.abs(close - z.mid) / close * 100.0 : 0.0
                    string txt = arrow + " " + sideStr + " · " + f_tier(sc) + " " + f_stars(sc) + " " + f_fmt1(sc) + "/10 · ×" + str.tostring(z.conf) + " · " + str.tostring(math.round(distPct * 100) / 100) + "% / " + str.tostring(math.round(f_toPips(close - z.mid))) + "p"
                    int lblX = n + extendRight
                    if na(z.tag)
                        z.tag := label.new(lblX, z.top, txt, xloc=xloc.bar_index, style=label.style_label_lower_right, color=color.new(C_BG0, 8), textcolor=color.new(elite ? accent : sideC, 0), size=f_size(labSize))
                    else
                        label.set_style(z.tag, label.style_label_lower_right)
                        label.set_xy(z.tag, lblX, z.top)
                        label.set_text(z.tag, txt)
                        label.set_textcolor(z.tag, color.new(elite ? accent : sideC, 0))
                else if not na(z.tag)
                    label.set_text(z.tag, "")

    if not keepBroken
        int k = 0
        while k < array.size(zones)
            Zone z = array.get(zones, k)
            if na(z.bx) and z.conf == 0
                array.remove(zones, k)
            else
                k += 1

    f_enforceCap()

var table dash = na
if showDash and barstate.isfirst
    dash := table.new(f_pos(dashPos), 6, dashRows + 3, border_width=1, border_color=C_BG3, bgcolor=C_BG0)

f_cell(c, r, txt, tc, bg) => table.cell(dash, c, r, txt, text_color=tc, bgcolor=bg, text_size=f_size(dashSize))

if showDash and barstate.islast and not na(dash)

    idx = array.new<int>()
    scr = array.new<float>()
    int nZ = array.size(zones)
    int eliteN = 0
    int strongN = 0
    if nZ > 0
        for i = 0 to nZ - 1
            Zone z = array.get(zones, i)
            if not z.broken and not na(z.bx) and z.score >= minScore
                array.push(idx, i)
                array.push(scr, z.score)
                if z.score >= eliteThr
                    eliteN += 1
                else if z.score >= strongThr
                    strongN += 1

    f_cell(0, 0, "STRONG REJECTION ZONES", accent, C_BG3)
    table.merge_cells(dash, 0, 0, 5, 0)
    f_cell(0, 1, "ELITE " + str.tostring(eliteN) + "  ·  STRONG " + str.tostring(strongN) + "  ·  ACTIVE " + str.tostring(array.size(idx)), C_TXT_SEC, C_BG2)
    table.merge_cells(dash, 0, 1, 5, 1)
    f_cell(0, 2, "#",     C_TXT_SEC, C_BG2)
    f_cell(1, 2, "SIDE",  C_TXT_SEC, C_BG2)
    f_cell(2, 2, "TIER",  C_TXT_SEC, C_BG2)
    f_cell(3, 2, "PRICE", C_TXT_SEC, C_BG2)
    f_cell(4, 2, "SCORE", C_TXT_SEC, C_BG2)
    f_cell(5, 2, "DIST",  C_TXT_SEC, C_BG2)

    for r = 0 to dashRows - 1
        for c = 0 to 5
            f_cell(c, r + 3, "", C_TXT_PRI, C_BG0)

    int shown = math.min(dashRows, array.size(idx))
    if shown > 0
        for rank = 0 to shown - 1
            int bestPos = -1
            float bestSc = -1.0
            for j = 0 to array.size(scr) - 1
                float s = array.get(scr, j)
                if s > bestSc
                    bestSc := s
                    bestPos := j
            if bestPos >= 0
                int zi = array.get(idx, bestPos)
                array.set(scr, bestPos, -1.0)
                Zone z = array.get(zones, zi)
                color sideC = z.side == 1 ? bullCol : bearCol
                bool elite = z.score >= eliteThr
                string sideTxt = (z.side == 1 ? "▲ BULL" : "▼ BEAR")
                float distPct = close != 0 ? (z.mid - close) / close * 100.0 : 0.0
                string dirArrow = z.mid >= close ? "▲" : "▼"
                string distTxt = dirArrow + " " + str.tostring(math.round(math.abs(distPct) * 100) / 100) + "%"
                int row = rank + 3
                f_cell(0, row, str.tostring(rank + 1), C_TXT_SEC, C_BG1)
                f_cell(1, row, sideTxt, color.new(sideC, 0), C_BG1)
                f_cell(2, row, f_tier(z.score), elite ? accent : C_TXT_PRI, C_BG1)
                f_cell(3, row, str.tostring(z.mid, format.mintick), C_TXT_PRI, C_BG1)
                f_cell(4, row, f_fmt1(z.score) + " " + f_stars(z.score), elite ? accent : color.new(sideC, 0), C_BG1)
                f_cell(5, row, distTxt, C_TXT_SEC, C_BG1)

bool nearStrong = false
bool nearElite  = false
float prox = atr * alertProxATR
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        Zone z = array.get(zones, i)
        if not z.broken and not na(z.bx) and math.abs(close - z.mid) <= prox
            if z.score >= eliteThr
                nearElite := true
            else if z.score >= strongThr
                nearStrong := true

alertcondition(evElite,    "ELITE cluster formed",   "An ELITE (9-10) rejection cluster has formed.")
alertcondition(evStrong,   "STRONG cluster formed",  "A STRONG (7-8) rejection cluster has formed.")
alertcondition(evBreach,   "Zone breached",          "A rejection zone was breached.")
alertcondition(evNewBull,  "New demand detection",   "Fresh bullish rejection detected.")
alertcondition(evNewBear,  "New supply detection",   "Fresh bearish rejection detected.")
alertcondition(nearStrong, "Approaching STRONG zone","Price approaching a STRONG zone - expect a reaction.")
alertcondition(nearElite,  "Approaching ELITE zone", "Price approaching an ELITE zone - expect a reaction.")
````
