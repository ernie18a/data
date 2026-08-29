<!-- tradingview-pine-id: PUB;3db41248544841088afd09e334c8ec5a -->
<!-- tradingviewscripts-format: 1 -->
# Strong MTF Liquidity Matrix

Source: https://www.tradingview.com/script/NQlGkZOs-Strong-MTF-Liquidity-Matrix-ProjectSyndicate/

## Description

Strong MTF Liquidity Matrix

Strong MTF Liquidity Matrix puts four higher-timeframe charts on one screen and reads the same institutional map on every one of them — order blocks, fair value gaps, and resting liquidity — then ranks each zone by strength so you know which level actually matters. It's a command deck: your main chart stays clean while four live mini-panels track the structure above you, and the liquidity pools that price is really hunting sit directly on your candles.

Most multi-timeframe tools make you flip between charts. This one stops the flipping.

🔲 Four-Panel MTF Engine — the core. Four independent mini-charts render right on your pane — M30 · H1 · H2 · H4 by default, each one fully configurable to any timeframe (drop to seconds or push to Daily). Every panel fetches its own higher-timeframe candles, keyed on the HTF bar's own time, so the zones are invariant to your master chart timeframe — switch your main chart from M30 to H1 to D1 and the panels don't move. The last candle in each panel tracks the live, forming HTF bar tick by tick.

🟩 Order Block Detection — real ICT logic, per timeframe. Each panel runs a swing-pivot + displacement scan: the last opposing candle before an impulsive move that clears your displacement multiple becomes the order block. Bull OBs from swing-low reversals, bear OBs from swing-high reversals — detected natively on every one of the four timeframes at once.

🟥 Fair Value Gap Detection — the imbalance map. True three-candle FVGs on each timeframe, with an optional ATR gap filter so only gaps worth trading survive. Bullish and bearish gaps rendered in the original green/red palette, distinct from the order blocks, on all four panels simultaneously.

🧲 Universal Zone Height — the accuracy differentiator. Raw OB/FVG zones come in wildly different sizes and clutter the read. Every zone is normalized to one clean height — ATR-based or a fixed percentage of price — so the panels stay legible and every zone carries equal visual weight. Fair value framed; noise removed.

🔢 0–10 Strength Ranking — the power-ranking. Every zone earns a live grade, printed inside the shaded box (OB 8.5, FVG 6.0). Order blocks score on displacement force, zone height and age; fair value gaps score on gap size versus ATR. Set a minimum strength floor and the weak zones simply don't draw — only the levels that earned attention survive.

🌊 Liquidity Heatmap — resting pools on your main chart. Buy-side and sell-side liquidity, seeded from fractal swing highs and lows across two pivot passes, drawn as heat-weighted boxes whose opacity scales with liquidity weight (volume × range). Strong pools glow, weak ones stay faint. When price trades through a pool it's consumed — the zone freezes and fades to show exactly what's already been taken. Colours locked 100% to the OB/FVG palette: buy-side green, sell-side red.

🏷️ Clean Liquidity Labels — above the zone, never in the way. Each resting pool is tagged with its side (BSL/SSL), price, weight and distance from current price — anchored above the zone at its left edge so labels never overlap the fills and never protrude past the level. Read the map without the mess.

🧹 Clean-Chart Discipline — dashboard off by default. No stat panel competing with price. The liquidity dashboard exists — nearest SSL/BSL, hottest level, pool counts, consumed tally — but it's switched off out of the box. Turn it on only if you want it.

🎨 Fully Themed & Configurable. Neutral-gray candles that let the coloured zones pop, custom OB/FVG/liquidity colours, panel size and spacing, right-offset from live price, 2× timeframe labels, per-panel OB/FVG toggles, adjustable swing length, displacement, mitigation type (Touch / Full Fill / 50% Fill), gap filter, zone-height method, strength floor, pivot lengths, heat contrast, pool extension and cap.

🔒 Honest, Non-Repainting Core. Panel history is built from confirmed higher-timeframe bars only; the live forming candle refreshes as it builds — inherent to showing a real-time HTF candle, not a defect — while every closed bar is fixed. Liquidity pools consume on confirmed interaction and don't un-consume to flatter the chart. The 0–10 strength score is a descriptive ranking framework for directing attention, not a backtested edge.

🔔 Native Alerts — new sell-side pool and new buy-side pool formation.

🎯 Why this is different. MTF tools make you tab between charts and reconcile the structure in your head. Profile tools show you liquidity and leave the map disconnected from your entries. Strong MTF Liquidity Matrix holds all four higher timeframes in view at once, marks the order blocks and fair value gaps on every one of them, grades each so you know which to trust, and lays the liquidity price is actually hunting directly on your candles — so you read where structure sits, how strong it is, and where price is being pulled, at a glance.

🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto, Indices and Futures on any timeframe (liquidity heat requires a volume-bearing symbol).

💡 Cleanest setup: give the four panels room — nudge Right Offset and the panels sit clear of live price to the right, while liquidity zones map onto the candles on the left.

🎯 How To Trade It — Two Approaches

Everything hinges on one read the Matrix gives you at a glance: is higher-timeframe structure lining up, and is price being pulled toward unfilled liquidity?

◾ 1) Trade into confluence toward liquidity (the core thesis)

Use when a high-strength zone on a higher panel lines up with a resting liquidity pool in the same direction.

▪️ Scan the four panels for a strong OB or FVG (7+) on H1/H2/H4 sitting where price is heading.
▪️ Confirm a naked liquidity pool (BSL below / SSL above) as the magnet — the untested pools are where price is drawn.
▪️ Entry: as price reaches the higher-timeframe zone, in the direction of the unfilled liquidity beyond it.
▪️ Stop: beyond the zone; if price closes through and accepts, the level failed — stand aside.
▪️ Target: the nearest resting pool in your direction; the opposite-side pool if the move extends.

⚖️ The cleanest version: H1 and H2 panels both print a strong bull OB at the same area, a fat buy-side pool sits just below unconsumed, and the M30 panel shows price rotating down into it. Structure, strength and liquidity all point the same way. That confluence is the exact setup this tool was built to frame.

◾ 2) Stand down — the map says wait

The Matrix also tells you when there's nothing to do.

▪️ Panels disagree — a bull OB on H1 against a bear FVG on H4 is conflict, not confluence. Wait for alignment.
▪️ Liquidity already consumed on your side — the magnet's gone; the pull is spent.
▪️ No strong zone in range — low scores everywhere means no level worth risking on. Let it develop.

Rule of thumb: ⭐ Aligned high-strength zones + an unfilled pool in the same direction → trade into the confluence toward the liquidity. ⭐ Conflicting panels, consumed pools, or weak scores → stand down until the map agrees.

⚠️ IMPORTANT NOTICE: Strong MTF Liquidity Matrix is a structure-and-liquidity mapping tool. Order blocks, fair value gaps and liquidity pools are drawn from swing-pivot and gap logic — a model of institutional behaviour, not exchange order-book data. Liquidity weight is inferred from volume × range and requires a volume-bearing symbol. The 0–10 strength score is a descriptive ranking framework for directing attention — NOT a backtested signal and NOT a standalone trade trigger. Trading into higher-timeframe structure still carries real risk of failed levels and stop-outs. Always combine it with your own strategy, price-action analysis and risk management. Past behaviour does not guarantee future results.

---

## Source Code

````pine
//@version=6
indicator("Strong MTF Liquidity Matrix", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

string G_P   = "Panels (Timeframes)"
string G_DET = "OB / FVG Detection"
string G_STR = "Strength Ranking"
string G_ZON = "Universal Zone Height"
string G_ST  = "Style & Layout"

bool  showP1 = input.bool(true, "P1", group = G_P, inline = "p1")
string tf1   = input.timeframe("30",  "", group = G_P, inline = "p1")
bool  p1OB   = input.bool(true, "OB", group = G_P, inline = "p1")
bool  p1FVG  = input.bool(true, "FVG", group = G_P, inline = "p1")

bool  showP2 = input.bool(true, "P2", group = G_P, inline = "p2")
string tf2   = input.timeframe("60",  "", group = G_P, inline = "p2")
bool  p2OB   = input.bool(true, "OB", group = G_P, inline = "p2")
bool  p2FVG  = input.bool(true, "FVG", group = G_P, inline = "p2")

bool  showP3 = input.bool(true, "P3", group = G_P, inline = "p3")
string tf3   = input.timeframe("120", "", group = G_P, inline = "p3")
bool  p3OB   = input.bool(true, "OB", group = G_P, inline = "p3")
bool  p3FVG  = input.bool(true, "FVG", group = G_P, inline = "p3")

bool  showP4 = input.bool(true, "P4", group = G_P, inline = "p4")
string tf4   = input.timeframe("240", "", group = G_P, inline = "p4")
bool  p4OB   = input.bool(true, "OB", group = G_P, inline = "p4")
bool  p4FVG  = input.bool(true, "FVG", group = G_P, inline = "p4")

int    swingLength = input.int(3,   "OB Swing Length", minval = 2, maxval = 20, group = G_DET, tooltip = "Bars each side for the swing pivot. Lower = more OBs on higher TFs.")
int    obLookback  = input.int(20,  "OB Lookback", minval = 5, maxval = 50, group = G_DET)
float  dispMult    = input.float(1.0, "OB Displacement Mult", minval = 0.3, maxval = 5.0, step = 0.1, group = G_DET)
int    maxObPer    = input.int(3,   "Max OB per side / panel", minval = 1, maxval = 6, group = G_DET)
int    maxFvgPer   = input.int(3,   "Max FVG per side / panel", minval = 1, maxval = 6, group = G_DET)
bool   useAtrFvg   = input.bool(false, "FVG ATR Filter", group = G_DET, tooltip = "Off by default — real gold gaps are often smaller than ATR and get wiped otherwise.")
float  fvgAtrMult  = input.float(0.15, "FVG Min Gap (ATR Mult)", minval = 0.0, step = 0.05, group = G_DET)
string fvgMitType  = input.string("50% Fill", "FVG Mitigation", options = ["Touch", "Full Fill", "50% Fill"], group = G_DET)
bool   obMitigate  = input.bool(true, "Remove Mitigated OB", group = G_DET)
bool   fvgMitigate = input.bool(true, "Remove Mitigated FVG", group = G_DET)

bool  enableStrength = input.bool(true, "Enable Strength Ranking", group = G_STR)
float minStrength    = input.float(0.0, "Minimum Strength Filter", minval = 0.0, maxval = 10.0, step = 0.5, group = G_STR, tooltip = "0 shows all zones. Raise to filter weak ones once zones appear.")
bool  showStrLabels  = input.bool(true, "Show Strength Labels", group = G_STR)

bool   useNormZones = input.bool(true, "Normalize All Zone Heights", group = G_ZON)
string zoneMethod   = input.string("ATR Based", "Zone Height Method", options = ["ATR Based", "Fixed Percentage"], group = G_ZON)
float  zoneAtrMult  = input.float(0.75, "Zone Height (ATR Mult)", minval = 0.1, maxval = 3.0, step = 0.05, group = G_ZON)
float  zonePercent  = input.float(0.3,  "Zone Height (% of Price)", minval = 0.05, maxval = 2.0, step = 0.05, group = G_ZON)

int   barsCount   = input.int(30, "HTF Bars to Show", minval = 15, maxval = 60, group = G_ST)
int   barSpacing  = input.int(9, "Bar Spacing", minval = 3, maxval = 20, group = G_ST)
bool  showBgBoxes = input.bool(true, "Show Panel Frames", group = G_ST)
color bullCandle  = input.color(#9598a1, "Bull Candle", group = G_ST, inline = "cnd")
color bearCandle  = input.color(#5d606b, "Bear Candle", group = G_ST, inline = "cnd")
color bullZoneClr = input.color(color.new(color.green, 80), "Bull OB", group = G_ST, inline = "z1")
color bearZoneClr = input.color(color.new(color.red, 80), "Bear OB", group = G_ST, inline = "z1")
color bullFvgClr  = input.color(color.new(color.green, 82), "Bull FVG", group = G_ST, inline = "z2")
color bearFvgClr  = input.color(color.new(color.red, 82), "Bear FVG", group = G_ST, inline = "z2")
color bullZoneBd  = input.color(color.new(color.green, 30), "Bull Border", group = G_ST, inline = "z3")
color bearZoneBd  = input.color(color.new(color.red, 30), "Bear Border", group = G_ST, inline = "z3")
int   xOff        = input.int(80, "Right Offset", group = G_ST)
int   xGapCols    = input.int(40, "Column Gap", group = G_ST)
float ySizePerc   = input.float(0.36, "Panel Height (%)", group = G_ST)
float yGapRows    = input.float(0.16, "Row Gap (%)", group = G_ST)
bool  showTfLabels = input.bool(true, "Show TF Labels", group = G_ST)

type BarData
    float o
    float h
    float l
    float c
    float atr

type PanelStore
    array<BarData> hist

type Zone
    float top
    float bot
    int   idx
    bool  bull
    bool  isFvg
    float strength

calc_ob_strength(float displacement, float zoneHeight, int age, float atrVal) =>
    if not enableStrength
        5.0
    else
        float ds = 1.0
        if atrVal > 0
            dr = displacement / atrVal
            ds := dr >= 3.0 ? 3.0 : dr >= 2.0 ? 2.5 : dr >= 1.5 ? 2.0 : dr >= 1.0 ? 1.5 : 1.0
        float ss = 1.5
        float ag = age < 50 ? 2.0 : age < 100 ? 1.5 : age < 200 ? 1.0 : 0.5
        float zsc = 1.5
        if atrVal > 0
            zr = zoneHeight / atrVal
            zsc := (zr >= 0.5 and zr <= 2.0) ? 3.0 : (zr >= 0.3 and zr <= 3.0) ? 2.0 : 1.0
        math.min(math.max(ds + ss + ag + zsc, 0.0), 10.0)

calc_fvg_strength(float gapSize, float atrVal) =>
    if not enableStrength
        5.0
    else
        float gs = 3.0
        if atrVal > 0
            gr = gapSize / atrVal
            gs := gr >= 1.5 ? 8.0 : gr >= 1.0 ? 6.0 : gr >= 0.75 ? 4.5 : gr >= 0.5 ? 3.0 : 1.5
        math.min(math.max(gs, 0.0), 10.0)

norm_height(float atrVal, float px) =>
    zoneMethod == "ATR Based" ? atrVal * zoneAtrMult : px * (zonePercent / 100.0)

normalize_zone(float top, float bot, float atrVal, float px) =>
    if useNormZones
        th = norm_height(atrVal, px)
        mid = (top + bot) / 2
        [mid + th / 2, mid - th / 2]
    else
        [top, bot]

fetchBars(string tf, PanelStore s, int count) =>
    [o1, h1, l1, c1, a1, t0, oL, hL, lL, cL, aL] = request.security(syminfo.tickerid, tf,
         [open[1], high[1], low[1], close[1], ta.atr(14)[1], time, open, high, low, close, ta.atr(14)],
         lookahead = barmerge.lookahead_on)

    htfRolled = ta.change(t0) != 0
    if not na(t0) and htfRolled
        // append the just-closed HTF bar to the front of the history deque, then trim
        // the tail so the deque never exceeds the configured window.
        s.hist.unshift(BarData.new(o1, h1, l1, c1, nz(a1)))
        int overflow = s.hist.size() - count
        if overflow > 0
            for _drop = 1 to overflow
                s.hist.pop()

    array<BarData> bars = array.new<BarData>()
    int closedRoom = na(oL) ? count : count - 1
    if not na(oL)
        bars.push(BarData.new(oL, hL, lL, cL, aL))
    int have = s.hist.size()
    if have > 0
        int take = math.min(have, closedRoom)
        int idx = 0
        while idx < take
            bars.push(s.hist.get(idx))
            idx += 1
    bars

detectZones(array<BarData> bars, bool wantOB, bool wantFVG) =>
    array<Zone> zones = array.new<Zone>()
    int n = array.size(bars)
    float pxRef  = n > 0 ? array.get(bars, 0).c : close

    float atrRef = na
    if n > 0
        float storedAtr = array.get(bars, 0).atr
        if not na(storedAtr) and storedAtr > 0
            atrRef := storedAtr
        else
            float sumTR = 0.0
            int cntTR = 0
            for i = 0 to n - 2
                bi = array.get(bars, i)
                bj = array.get(bars, i + 1)
                tr = math.max(bi.h - bi.l, math.max(math.abs(bi.h - bj.c), math.abs(bi.l - bj.c)))
                sumTR += tr
                cntTR += 1
            atrRef := cntTR > 0 ? sumTR / cntTR : (array.get(bars, 0).h - array.get(bars, 0).l)
        if na(atrRef) or atrRef <= 0
            atrRef := syminfo.mintick * 100

    if wantFVG and n >= 3
        int cntBull = 0
        int cntBear = 0
        for i = 0 to n - 3
            b0 = array.get(bars, i)
            b2 = array.get(bars, i + 2)
            atrHere = atrRef
            if b0.l > b2.h and cntBull < maxFvgPer
                gap = b0.l - b2.h
                minGap = useAtrFvg ? atrHere * fvgAtrMult : 0.0
                if gap >= minGap
                    bool mit = false
                    if fvgMitigate and i > 0
                        mid = (b0.l + b2.h) / 2
                        for k = 0 to i - 1
                            bk = array.get(bars, k)
                            filled = fvgMitType == "Touch" ? bk.l <= b0.l : fvgMitType == "Full Fill" ? bk.l <= b2.h : bk.l <= mid
                            if filled
                                mit := true
                                break
                    if not mit
                        strg = calc_fvg_strength(gap, atrHere)
                        if strg >= minStrength
                            [nt, nb] = normalize_zone(b0.l, b2.h, atrHere, pxRef)
                            array.push(zones, Zone.new(nt, nb, i + 1, true, true, strg))
                            cntBull += 1
            else if b0.h < b2.l and cntBear < maxFvgPer
                gap = b2.l - b0.h
                minGap = useAtrFvg ? atrHere * fvgAtrMult : 0.0
                if gap >= minGap
                    bool mit = false
                    if fvgMitigate and i > 0
                        mid = (b2.l + b0.h) / 2
                        for k = 0 to i - 1
                            bk = array.get(bars, k)
                            filled = fvgMitType == "Touch" ? bk.h >= b0.h : fvgMitType == "Full Fill" ? bk.h >= b2.l : bk.h >= mid
                            if filled
                                mit := true
                                break
                    if not mit
                        strg = calc_fvg_strength(gap, atrHere)
                        if strg >= minStrength
                            [nt, nb] = normalize_zone(b2.l, b0.h, atrHere, pxRef)
                            array.push(zones, Zone.new(nt, nb, i + 1, false, true, strg))
                            cntBear += 1

    if wantOB and n > (swingLength * 2 + 1)
        int cntBull = 0
        int cntBear = 0
        for p = swingLength to n - swingLength - 1
            bp = array.get(bars, p)
            bool isPH = true
            bool isPL = true
            for k = 1 to swingLength
                if array.get(bars, p - k).h > bp.h or array.get(bars, p + k).h > bp.h
                    isPH := false
                if array.get(bars, p - k).l < bp.l or array.get(bars, p + k).l < bp.l
                    isPL := false

            if isPL and cntBull < maxObPer
                float swingLow = bp.l
                bool found = false
                for j = p + 1 to math.min(n - 1, p + obLookback)
                    if not found
                        cb = array.get(bars, j)
                        if cb.c < cb.o
                            disp = swingLow - cb.l
                            rng  = cb.h - cb.l
                            if rng > 0 and disp > rng * dispMult
                                atrHere = atrRef
                                [nt, nb] = normalize_zone(cb.h, cb.l, atrHere, pxRef)
                                bool mit = false
                                if obMitigate and j > 0
                                    for k = 0 to j - 1
                                        if array.get(bars, k).c < nb
                                            mit := true
                                            break
                                if not mit
                                    strg = calc_ob_strength(pxRef - cb.l, cb.h - cb.l, j, atrHere)
                                    if strg >= minStrength
                                        array.push(zones, Zone.new(nt, nb, j, true, false, strg))
                                        cntBull += 1
                                found := true

            if isPH and cntBear < maxObPer
                float swingHigh = bp.h
                bool found = false
                for j = p + 1 to math.min(n - 1, p + obLookback)
                    if not found
                        cb = array.get(bars, j)
                        if cb.c > cb.o
                            disp = cb.h - swingHigh
                            rng  = cb.h - cb.l
                            if rng > 0 and disp > rng * dispMult
                                atrHere = atrRef
                                [nt, nb] = normalize_zone(cb.h, cb.l, atrHere, pxRef)
                                bool mit = false
                                if obMitigate and j > 0
                                    for k = 0 to j - 1
                                        if array.get(bars, k).c > nt
                                            mit := true
                                            break
                                if not mit
                                    strg = calc_ob_strength(cb.h - pxRef, cb.h - cb.l, j, atrHere)
                                    if strg >= minStrength
                                        array.push(zones, Zone.new(nt, nb, j, false, false, strg))
                                        cntBear += 1
                                found := true
    zones

var s1 = PanelStore.new(array.new<BarData>())
var s2 = PanelStore.new(array.new<BarData>())
var s3 = PanelStore.new(array.new<BarData>())
var s4 = PanelStore.new(array.new<BarData>())

bars1 = showP1 ? fetchBars(tf1, s1, barsCount) : array.new<BarData>()
bars2 = showP2 ? fetchBars(tf2, s2, barsCount) : array.new<BarData>()
bars3 = showP3 ? fetchBars(tf3, s3, barsCount) : array.new<BarData>()
bars4 = showP4 ? fetchBars(tf4, s4, barsCount) : array.new<BarData>()

float g_ctxHi = ta.highest(high, 300)
float g_ctxLo = ta.lowest(low, 300)
float g_atr14   = ta.atr(14)

var box[]   boxArr  = array.new<box>()
var line[]  lineArr = array.new<line>()
var label[] lblArr  = array.new<label>()

renderPanel(array<BarData> bars, int col, int row, string tfName, bool wantOB, bool wantFVG) =>
    int n = array.size(bars)
    if n > 0
        float ctxHi = g_ctxHi
        float ctxLo = g_ctxLo
        float ctxSpan = ctxHi - ctxLo
        ctxSpan := (na(ctxSpan) or ctxSpan < g_atr14 * 3) ? nz(g_atr14 * 3, syminfo.mintick * 100) : ctxSpan

        // panel vertical band: height as a share of context span; each row stacked
        // downward from the context high with a proportional inter-row gutter.
        float panelH = ctxSpan * ySizePerc
        float rowStep = panelH + ctxSpan * yGapRows
        float panelTop = ctxHi - (row - 1) * rowStep
        float bY = panelTop - panelH
        float uH = panelH

        int rightMargin = 12
        int reqOff = math.max(2, xOff)
        int reqGap = math.max(4, xGapCols)
        int colBudget = 480 - reqOff - reqGap - rightMargin
        int maxSpacing = math.max(1, int(colBudget / (2 * (barsCount - 1))))
        int effSpacing = math.min(barSpacing, maxSpacing)
        int cW = (barsCount - 1) * effSpacing
        int gridW = 2 * cW + reqGap + rightMargin
        int effOff = math.min(reqOff, math.max(2, 480 - gridW))
        int effGap = reqGap
        int xS = bar_index + effOff + (col - 1) * (cW + effGap)
        int xE = xS + cW
        int bHW = math.max(1, int(effSpacing * 0.34))

        if showBgBoxes
            color fBg = color.new(color.gray, 94)
            color fBd = color.new(color.gray, 72)
            array.push(boxArr, box.new(xS - effSpacing * 2, panelTop + ctxSpan * 0.02, xE + effSpacing * 2, bY - ctxSpan * 0.006, bgcolor = fBg, border_color = fBd))

        // price extent of the fetched window, then pad symmetrically and derive baseline
        float hi = na
        float lo = na
        for i = 0 to n - 1
            bv = array.get(bars, i)
            hi := na(hi) ? bv.h : math.max(hi, nz(bv.h, hi))
            lo := na(lo) ? bv.l : math.min(lo, nz(bv.l, lo))
        float span = hi - lo
        float dR = span <= 0 ? syminfo.mintick : span * 1.12
        float pad = (dR - span) / 2
        float sB = lo - pad

        zones = detectZones(bars, wantOB, wantFVG)
        if array.size(zones) > 0
            for zi = 0 to array.size(zones) - 1
                z = array.get(zones, zi)
                int zx = xS + (n - 1 - z.idx) * effSpacing
                float yT = bY + (z.top - sB) / dR * uH
                float yB = bY + (z.bot - sB) / dR * uH
                yT := math.max(bY, math.min(bY + uH, yT))
                yB := math.max(bY, math.min(bY + uH, yB))
                color zc = z.isFvg ? (z.bull ? bullFvgClr : bearFvgClr) : (z.bull ? bullZoneClr : bearZoneClr)
                color zbd = z.bull ? bullZoneBd : bearZoneBd
                int zRight = xE
                array.push(boxArr, box.new(zx - bHW, yT, zRight, yB, bgcolor = zc, border_color = zbd, border_width = 1))
                if showStrLabels
                    string tag = (z.isFvg ? "FVG " : "OB ") + str.tostring(math.round(z.strength * 10) / 10)
                    color tcol = z.bull ? color.new(color.green, 0) : color.new(color.red, 0)
                    int lblX = math.min(zRight, zx + int((zRight - zx) / 2))
                    array.push(lblArr, label.new(lblX, (yT + yB) / 2, tag, color = #00000000, textcolor = tcol, style = label.style_label_center, size = size.small))

        for i = 0 to n - 1
            b = array.get(bars, i)
            int x = xS + (n - 1 - i) * effSpacing
            color cc = b.c >= b.o ? bullCandle : bearCandle
            yH  = bY + (b.h - sB) / dR * uH
            yL  = bY + (b.l - sB) / dR * uH
            yO  = bY + (b.o - sB) / dR * uH
            yCl = bY + (b.c - sB) / dR * uH
            array.push(lineArr, line.new(x, yH, x, yL, color = cc, width = 1))
            array.push(boxArr, box.new(x - bHW, math.max(yO, yCl), x + bHW, math.min(yO, yCl), bgcolor = cc, border_color = cc))

        if showTfLabels
            array.push(lblArr, label.new(xS + cW / 2, panelTop + ctxSpan * 0.05, syminfo.ticker + " · " + tfName, color = #00000000, textcolor = color.new(color.gray, 0), style = label.style_label_down, size = size.large))

if barstate.islast
    while array.size(boxArr) > 0
        box.delete(array.pop(boxArr))
    while array.size(lineArr) > 0
        line.delete(array.pop(lineArr))
    while array.size(lblArr) > 0
        label.delete(array.pop(lblArr))

    if showP1
        renderPanel(bars1, 1, 1, tf1, p1OB, p1FVG)
    if showP2
        renderPanel(bars2, 2, 1, tf2, p2OB, p2FVG)
    if showP3
        renderPanel(bars3, 1, 2, tf3, p3OB, p3FVG)
    if showP4
        renderPanel(bars4, 2, 2, tf4, p4OB, p4FVG)

gLQ           = "◆ Liquidity"
liqShow       = input.bool(true,  "Show Liquidity Zones", group = gLQ)
liqPivLen     = input.int(8, "Pivot Length", minval = 2, maxval = 60, group = gLQ, tooltip = "Fractal lookback for the swing highs/lows that seed liquidity pools.")
liqPivLen2    = input.int(4, "Secondary Pivot Length", minval = 0, maxval = 40, group = gLQ, tooltip = "A smaller pivot pass for extra levels. 0 = off.")
liqAtrLen     = input.int(100, "ATR Length", minval = 10, maxval = 500, group = gLQ)
liqZoneHPct   = input.float(0.08, "Zone Height (× ATR)", minval = 0.01, maxval = 0.5, step = 0.01, group = gLQ, tooltip = "Thickness of each liquidity box as a fraction of ATR.")
liqLookback   = input.int(1000, "Lookback Bars", minval = 100, maxval = 2000, group = gLQ)
liqMaxZones   = input.int(60, "Max Zones", minval = 10, maxval = 200, group = gLQ, tooltip = "Hard cap on stored zones (protects the object budget shared with the panels).")
liqExtendBars = input.int(60, "Extend Resting Zones (bars)", minval = 0, maxval = 300, group = gLQ)
liqHeatCon    = input.float(0.5, "Heat Contrast", minval = 0.1, maxval = 3.0, step = 0.1, group = gLQ)
liqMinTrans   = input.int(30, "Strongest Opacity", minval = 0, maxval = 90, group = gLQ)
liqMaxTrans   = input.int(90, "Weakest Opacity", minval = 40, maxval = 100, group = gLQ)
liqTouchTrans = input.int(94, "Touched Zone Opacity", minval = 50, maxval = 100, group = gLQ)
liqKeepTouch  = input.bool(true, "Keep Touched Zones", group = gLQ)
liqShowLbls   = input.bool(true, "Zone Labels", group = gLQ)
liqLblSize    = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLQ)
liqShowPanel  = input.bool(false, "Show Liquidity Dashboard", group = gLQ, tooltip = "Off by default.")
liqPanelPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Middle Right", "Bottom Right", "Bottom Left", "Top Left"], group = gLQ)

color liqBuyCol  = color.green
color liqSellCol = color.red

liq_clamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))
liq_fmtP(float v) => str.tostring(v, format.mintick)
liq_szOf(string sName) =>
    switch sName
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

float liqAtr    = ta.atr(liqAtrLen)
float liqSafeAtr = math.max(nz(liqAtr, high - low), syminfo.mintick)
float liqZoneH  = liqSafeAtr * liqZoneHPct
float liqWeight = volume * (high - low)
float liqWMax   = ta.highest(liqWeight, liqLookback)
float liqWMin   = ta.lowest(liqWeight, liqLookback)
float liqWRange = liqWMax - liqWMin

liq_heat(float w) =>
    float nrm = liqWRange > 0.0 ? liq_clamp((w - liqWMin) / liqWRange, 0.0, 1.0) : 0.5
    math.pow(nrm, liqHeatCon)
liq_trans(float heat) => int(liqMaxTrans - heat * (liqMaxTrans - liqMinTrans))

type LPool
    box   b
    label lab
    float top
    float bot
    float price
    float weight
    int   born
    bool  sell
    bool  touched
    int   touchBar

var array<LPool> liqPools = array.new<LPool>()

liq_addPool(float px, bool sell, float w, int bornBar) =>
    float top = sell ? px + liqZoneH : px
    float bot = sell ? px : px - liqZoneH
    liqPools.push(LPool.new(na, na, top, bot, px, w, bornBar, sell, false, na))
    while liqPools.size() > liqMaxZones
        LPool old = liqPools.shift()
        if not na(old.b)
            box.delete(old.b)
        if not na(old.lab)
            label.delete(old.lab)

float liqPh1 = liqShow ? ta.pivothigh(high, liqPivLen, liqPivLen) : na
float liqPl1 = liqShow ? ta.pivotlow(low, liqPivLen, liqPivLen) : na
if not na(liqPh1)
    liq_addPool(liqPh1, true,  nz(liqWeight[liqPivLen], 0.0), bar_index - liqPivLen)
if not na(liqPl1)
    liq_addPool(liqPl1, false, nz(liqWeight[liqPivLen], 0.0), bar_index - liqPivLen)
if liqShow and liqPivLen2 > 0
    float liqPh2 = ta.pivothigh(high, liqPivLen2, liqPivLen2)
    float liqPl2 = ta.pivotlow(low, liqPivLen2, liqPivLen2)
    if not na(liqPh2)
        liq_addPool(liqPh2, true,  nz(liqWeight[liqPivLen2], 0.0), bar_index - liqPivLen2)
    if not na(liqPl2)
        liq_addPool(liqPl2, false, nz(liqWeight[liqPivLen2], 0.0), bar_index - liqPivLen2)

var int liqNSell = 0
var int liqNBuy  = 0
var int liqNCons = 0
var float liqHotW = 0.0
var float liqHotPx = na

if liqShow and liqPools.size() > 0
    int aSell = 0
    int aBuy  = 0
    int cons  = 0
    float mW  = 0.0
    float mPx = na
    int   rightX = bar_index + liqExtendBars
    for i = liqPools.size() - 1 to 0
        LPool p = liqPools.get(i)
        float mid = (p.top + p.bot) / 2.0
        if not p.touched
            bool hit = high >= mid and low <= mid
            if hit
                if liqKeepTouch
                    p.touched := true
                    p.touchBar := bar_index
                else
                    if not na(p.b)
                        box.delete(p.b)
                    if not na(p.lab)
                        label.delete(p.lab)
                    liqPools.remove(i)
                    continue
        if bar_index - p.born > liqLookback
            if not na(p.b)
                box.delete(p.b)
            if not na(p.lab)
                label.delete(p.lab)
            liqPools.remove(i)
            continue
        if p.touched
            cons += 1
        else if p.sell
            aSell += 1
        else
            aBuy += 1
        if not p.touched and p.weight > mW
            mW := p.weight
            mPx := p.price
        color baseC = p.sell ? liqSellCol : liqBuyCol
        float heat  = liq_heat(p.weight)
        int   tr    = p.touched ? liqTouchTrans : liq_trans(heat)
        color fillC = color.new(baseC, tr)
        int leftX  = p.born
        int rX     = p.touched ? p.touchBar : rightX
        if na(p.b)
            p.b := box.new(leftX, p.top, rX, p.bot, bgcolor = fillC, border_color = color.new(baseC, math.min(tr + 8, 100)), border_width = 1)
        else
            box.set_lefttop(p.b, leftX, p.top)
            box.set_rightbottom(p.b, rX, p.bot)
            box.set_bgcolor(p.b, fillC)
            box.set_border_color(p.b, color.new(baseC, math.min(tr + 8, 100)))
        if liqShowLbls and not p.touched
            string side = p.sell ? "SSL" : "BSL"
            float distPct = close != 0.0 ? math.abs((p.price - close) / close * 100.0) : 0.0
            string tag = side + "  " + liq_fmtP(p.price) + "   " + str.tostring(p.weight, format.volume) + "  ·  " + str.tostring(distPct, "#.##") + "%"
            float lblY = p.top
            if na(p.lab)
                p.lab := label.new(leftX, lblY, tag, style = label.style_label_down, color = color.new(color.black, 100), textcolor = color.new(baseC, 10), size = liq_szOf(liqLblSize), textalign = text.align_left)
            else
                label.set_xy(p.lab, leftX, lblY)
                label.set_text(p.lab, tag)
                label.set_textcolor(p.lab, color.new(baseC, 10))
                label.set_style(p.lab, label.style_label_down)
        else
            if not na(p.lab)
                label.delete(p.lab)
                p.lab := na
    liqNSell := aSell
    liqNBuy  := aBuy
    liqNCons := cons
    liqHotW  := mW
    liqHotPx := mPx

color LQ_PANEL = #0B0710
color LQ_TXT   = #E6EDF3
color LQ_MUT   = #8A94A6
color LQ_ACC   = #C77DFF
string liqPpos = switch liqPanelPos
    "Top Right"    => position.top_right
    "Middle Right" => position.middle_right
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Top Left"     => position.top_left
    => position.top_right
var table liqPanel = table.new(liqPpos, 2, 7, bgcolor = color.new(LQ_PANEL, 8), frame_color = color.new(LQ_ACC, 45), frame_width = 1, border_color = color.new(LQ_PANEL, 40), border_width = 1)
var bool liqPanelInit = false
liq_pRow(int r, string lbl, string val, color lblC, color valC) =>
    table.cell(liqPanel, 0, r, lbl, text_color = lblC, text_size = size.small, text_halign = text.align_left)
    table.cell(liqPanel, 1, r, val, text_color = valC, text_size = size.small, text_halign = text.align_right)

float liqDistSell = na
float liqDistBuy  = na
if liqShow and liqShowPanel and liqPools.size() > 0
    for i = 0 to liqPools.size() - 1
        LPool p = liqPools.get(i)
        if not p.touched
            if p.sell and p.price >= close
                float d = p.price - close
                liqDistSell := na(liqDistSell) or d < liqDistSell ? d : liqDistSell
            if not p.sell and p.price <= close
                float d = close - p.price
                liqDistBuy := na(liqDistBuy) or d < liqDistBuy ? d : liqDistBuy

if barstate.islast and liqShow and liqShowPanel
    if not liqPanelInit
        for r = 0 to 6
            table.cell(liqPanel, 0, r, "", text_size = size.small)
            table.cell(liqPanel, 1, r, "", text_size = size.small)
        table.merge_cells(liqPanel, 0, 0, 1, 0)
        table.cell(liqPanel, 0, 0, "◈  LIQUIDITY", text_color = LQ_TXT, bgcolor = color.new(LQ_ACC, 70), text_size = size.small, text_halign = text.align_center)
        liqPanelInit := true
    liq_pRow(1, "Sell-Side Pools", str.tostring(liqNSell), LQ_MUT, liqSellCol)
    liq_pRow(2, "Buy-Side Pools",  str.tostring(liqNBuy),  LQ_MUT, liqBuyCol)
    liq_pRow(3, "Consumed",        str.tostring(liqNCons), LQ_MUT, color.new(LQ_MUT, 20))
    liq_pRow(4, "Hottest Level",   na(liqHotPx) ? "—" : liq_fmtP(liqHotPx), LQ_MUT, LQ_ACC)
    liq_pRow(5, "↑ Nearest SSL",   na(liqDistSell) ? "—" : liq_fmtP(close + liqDistSell), LQ_MUT, liqSellCol)
    liq_pRow(6, "↓ Nearest BSL",   na(liqDistBuy)  ? "—" : liq_fmtP(close - liqDistBuy),  LQ_MUT, liqBuyCol)

alertcondition(not na(liqPh1), "New Sell-Side Pool", "Liquidity: new sell-side pool formed.")
alertcondition(not na(liqPl1), "New Buy-Side Pool",  "Liquidity: new buy-side pool formed.")
````
