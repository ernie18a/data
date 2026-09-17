<!-- tradingview-pine-id: PUB;b40d084612fd4c769ca99b3829b5f2af -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Strong GEX Liquidations

Source: https://www.tradingview.com/script/CPcOR9RQ-Strong-GEX-Liquidations-ProjectSyndicate/

## Description

Strong GEX Liquidations maps the one thing a liquidity trader actually wants to see — where over-leveraged positions get force-closed — and prints it as heat. Every meaningful burst of positioning projects a ladder of liquidation prices; wherever those projections stack, a wall forms, and the indicator paints a hot beam there. A thin build prints a faint magenta thread. A heavy, stacked cluster prints a bright, teal-hot beam that says a cascade is loaded at that level. Your chart stays clean — ranked liquidation beams and nothing else — while the engine measures the leverage build-up underneath, across your entire lookback.

Most volatility and support/resistance tools draw a level and leave you to guess which one matters. This one grades the wall, ranks it, and tells you which side is trapped.

XAUUSD
[image]https://www.tradingview.com/x/dG2esJQm/[/image]

💥 The Liquidation Engine — the core. On every bar, the tool reads a size proxy — volume, or volume × range as an open-interest stand-in — and flags the bars where leverage genuinely piled in (a volume spike over its adaptive baseline, optionally weighted by how fast the proxy is accelerating, the way real ∆OI behaves). Each flagged bar becomes a trigger: a place where a crowd took a position that now has a stop the market can hunt. Quiet bars print nothing. Only real build-up feeds the map.

⚡ Leverage-Tier Projection — where the levels come from. From every trigger price the engine projects the exact prices at which that crowd blows out, tier by tier: longs are force-closed BELOW at price × (1 − mm / L), shorts ABOVE at price × (1 + mm / L), for 5× / 10× / 25× / 50× / 100× leverage. 100× liquidations hug price; 5× sit far away. A realistic maintenance factor fires each one slightly before the naive 1/L move. Toggle any tier on or off, and restrict the map to longs-below, shorts-above, or both.

🌡️ Power Heatmap — the signature read. Every projection is binned to a price row, and overlapping projections STACK — that is precisely how a wall forms: many liquidations at one level equals high power. Power is then double-encoded so you can read it from across the room. Colour: a magenta → blue → teal gradient (magenta is a light poke, teal is a loaded wall). Label: a ranked strength score on the strongest levels. A faint magenta thread is a shrug; a bright teal beam is a level the whole market can feel. Hotter equals more stacked, no interpretation required.

🏷️ Strength Ranking — labels on both ends. The heavy walls carry a full read-out at the price axis — ★ stars, an X/10 score, a tier (WIPEOUT / HEAVY / STRONG / MEDIUM / LIGHT), the side that is trapped (▲ SHORT-LIQ above price, ▼ LONG-LIQ below), the dominant leverage tier that built the wall, and its distance from spot. A compact tag on the left end marks where the wall first formed. Labels are placed strongest-first with enforced vertical spacing, so the heavy levels always win the real estate and text never stacks into a blur.

📍 Wall Stacking & Anchoring — one clean beam per level. A cluster of projections at nearly the same price is collapsed to a single crest and drawn as one beam, not a smear of overlapping lines. Each beam is anchored where its build-up first formed and extends right to the live bar, so you can see when the wall was laid down. Levels price has already traded through are dimmed — their liquidations were taken — while untouched walls stay bright.

🧼 Clean-Chart Discipline — heat and nothing else. No moving-average spaghetti, no band lines across price, no dashboard, no stat panel. Just the ranked liquidation beams, their strength labels, and a faint current-price guide. A tight set of declutter controls — max beams, minimum power, beam separation and label spacing — keeps only the levels that matter on screen. Everything else lives in the alerts.

🎨 Fully Themed & Configurable. Custom low / mid / high power colours; beam thickness, glow layers, core and weak opacity, and power contrast; scan resolution and range padding (how far out-of-range to project far-leverage walls); the volume baseline, trigger-spike multiplier, OI-acceleration weighting and recency emphasis; the maintenance factor and per-tier leverage toggles; max beams, minimum-power cutoff and beam separation; beam anchoring (where it formed vs full lookback) and right-extension; consumed-level dimming; and the full label controls — count, spacing, minimum strength, dominant-leverage tag and size.

🔒 Honest, Synthetic Core. This is a behavioural reconstruction, not a live exchange feed: it infers where leverage sits from price and volume, so it runs on any market, but it does not read real order books or open interest. The map is a live snapshot — it recomputes on the last bar as fresh build-up arrives. A level's price is fixed by the leverage maths the moment its trigger closes, but its relative power and heat can re-rank as new, larger walls appear and the strongest-wall scale shifts. It is a risk-awareness and attention tool for ranking where the market is trapped — not a backtested edge and not a promise that price will react at any level.

BTCUSD
[image]https://www.tradingview.com/x/KW67Elds/[/image]

🔔 Native Alerts. Approaching Short-Liq Wall and Approaching Long-Liq Wall fire as price closes in on a strong wall above or below; Short-Liq Cascade and Long-Liq Cascade fire the moment price actually reaches one — the point where a squeeze or a flush can ignite. Set the wall-strength threshold once and let the chart stay silent until price is near real trapped size.

🎯 Why this is different. A raw support/resistance line is static and un-graded — you eyeball a touch and guess. A liquidation feed is powerful but costs money and only exists for a handful of crypto pairs. Strong GEX Liquidations reconstructs the same idea from price and volume: it projects the actual leverage-liquidation prices, stacks them into walls, ranks each wall by power, and tells you which side is trapped and at what leverage — on any symbol, at any timeframe.

🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto, Indices and Futures on any timeframe. Because levels are projected from leverage maths and stacked by a volatility-normalised power score, the read travels across symbols without re-tuning; volume-weighted markets sharpen it where the tape carries clean volume.

💡 Cleanest setup: raise Min Power and lower Max Beams so only the heavy walls survive; widen Beam Separation and Label Spacing for a de-cluttered map; keep the near tiers (50× / 100×) on to see the walls price is most likely to reach soon, and the far tiers (5× / 10×) on to see the deeper magnets; raise the Trigger Spike to build walls only from genuine leverage bursts.

USDJPY
[image]https://www.tradingview.com/x/jO7ejzKf/[/image]

🎯 How To Trade It — Two Approaches

Everything hinges on one read: where is the trapped size, and is price being pulled into it or repelled by it?

🧲 1) Trade toward the wall — the liquidity magnet

Use when a strong, untested wall sits above or below and price has room to run at it.

Mark the heavy walls — teal, WIPEOUT / HEAVY beams are where the most leverage is stacked; price is frequently drawn toward that liquidity.
Read the side — a strong ▲ SHORT-LIQ wall above is fuel for a squeeze up; a strong ▼ LONG-LIQ wall below is fuel for a flush down.
Trigger: position in the direction of the nearest untested heavy wall, with structure or momentum agreeing; the Approaching alert flags the run-in.
Target: the wall itself, then the next unstretched level beyond it. A cascade often over-runs the wall before settling.
Stop: on the far side of the setup that argued for the move, not inside the wall.

🧱 2) Fade the wall — the barrier that repels

Use on first contact with a dense, untested wall while price arrives tired.

A large, tightly stacked cluster can act as a temporary barrier that repels price on the first tap — the classic "wall" behaviour.
Trigger: fade the first touch back toward the mean, ideally when price arrives over-extended and the wall is WIPEOUT-tier.
Invalidation: acceptance through the wall. Once price closes decisively beyond a heavy level, the trapped side is being taken — that is a cascade, not a rejection, so stand aside or flip with it.

✋ Stand down — the map says wait
Thin, magenta beams are minor build-up, not walls. Nothing to lean on.
Already-consumed (dimmed) levels have had their liquidations taken — they carry far less fuel.
No strong wall near price, or price mid-range between clusters — wait for contact with a ranked wall and let the alert bring you in.

Rule of thumb: 🔥 Strong untested wall + price running at it → trade toward the magnet, target the wall. 🧱 Dense wall + tired arrival on first touch → fade back to the mean until acceptance proves otherwise. ❄️ Thin or consumed levels, or no wall near price → stand down until the heat lines up.

---

## Source Code

````pine
//@version=6
indicator("Strong GEX Liquidations", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 100, max_bars_back = 2000)

gE = "═══ Positioning Engine ═══"
lookback  = input.int(400, "Lookback (bars)", minval = 50, maxval = 1500, group = gE, tooltip = "How many recent bars are scanned for leverage build-up.")
oiMode    = input.string("Simulated (Vol × Range)", "OI / Size Proxy", options = ["Simulated (Vol × Range)", "Volume only"], group = gE, tooltip = "Weight given to each trigger bar. Vol×Range approximates notional / open-interest size.")
volSmaLen = input.int(60, "Volume Baseline", minval = 5, maxval = 400, group = gE)
volMult   = input.float(1.3, "Trigger Spike (× baseline)", minval = 0.5, maxval = 6.0, step = 0.05, group = gE, tooltip = "A bar only projects liquidations when its volume exceeds baseline × this. Higher = fewer, cleaner walls.")
useAccel  = input.bool(true, "Weight by OI Acceleration", group = gE, tooltip = "Emphasise bars where the size proxy is rising fast (fresh leverage), like ∆OI.")
recency   = input.float(0.25, "Recency Emphasis", minval = 0.0, maxval = 2.0, step = 0.05, group = gE, tooltip = "Weight recent build-up above old. 0 = fully historical (walls persist equally).")

gL = "═══ Leverage Tiers ═══"
useL5   = input.bool(true, "5×  (≈ far)",   group = gL)
useL10  = input.bool(true, "10×",           group = gL)
useL25  = input.bool(true, "25×",           group = gL)
useL50  = input.bool(true, "50×",           group = gL)
useL100 = input.bool(true, "100× (≈ near)", group = gL)
mm      = input.float(0.95, "Maintenance Factor", minval = 0.5, maxval = 1.0, step = 0.01, group = gL, tooltip = "Liquidation fires slightly before the naive 1/L move. 0.95 ≈ realistic maintenance margin.")
sideMode= input.string("Both", "Liquidation Side", options = ["Both", "Longs below", "Shorts above"], group = gL)

gD = "═══ Level Detection ═══"
rowsN     = input.int(180, "Scan Resolution (rows)", minval = 40, maxval = 250, group = gD, tooltip = "Vertical bins used to stack projections. Higher = finer levels.")
rangePad  = input.float(0.25, "Range Padding", minval = 0.0, maxval = 1.5, step = 0.05, group = gD, tooltip = "Extend the scan this fraction of the visible range above/below, so far liquidation levels are captured.")
maxBeams  = input.int(24, "Max Beams Drawn", minval = 5, maxval = 120, group = gD, tooltip = "Only the strongest N liquidation levels are shown. Lower = cleaner.")
cutoffPct = input.float(22, "Min Power (% of top)", minval = 0, maxval = 90, step = 1, group = gD, tooltip = "Hide levels weaker than this % of the strongest. Raise to drop the faint clutter.")
minSepAtr = input.float(0.55, "Min Beam Separation (× ATR)", minval = 0.03, maxval = 4.0, step = 0.01, group = gD, tooltip = "Merge beams closer than this so they stay distinct.")
atrLen    = input.int(100, "ATR Length", minval = 5, maxval = 500, group = gD)

gR = "═══ Beam Render ═══"
beamHtAtr = input.float(0.16, "Beam Thickness (× ATR)", minval = 0.03, maxval = 1.5, step = 0.01, group = gR)
gradLayers= input.int(3, "Glow Layers", minval = 1, maxval = 8, group = gR, tooltip = "Sub-bars per beam, faded outward, for a soft glow instead of a hard line.")
maxOpac   = input.int(92, "% Core Opacity", minval = 20, maxval = 100, step = 2, group = gR)
minOpac   = input.int(30, "% Weak Opacity", minval = 5, maxval = 90, step = 2, group = gR, tooltip = "Opacity of the weakest drawn beam.")
contrast  = input.float(0.7, "Power Contrast", minval = 0.1, maxval = 3.0, step = 0.05, group = gR)
anchorMode= input.string("Where it formed", "Beam Left Anchor", options = ["Where it formed", "Full lookback"], group = gR, tooltip = "Start each beam where its earliest projection formed (staggered), or span the whole lookback.")
extendR   = input.int(10, "Extend Right (bars)", minval = 0, maxval = 200, group = gR)
fadePassed= input.bool(true, "Dim Consumed Levels", group = gR, tooltip = "Levels price has already traded through are dimmed (their liquidations were taken).")

gLab = "═══ Strength Labels ═══"
showLabels  = input.bool(true,  "Show Strength Labels", group = gLab)
bothSides   = input.bool(true,  "Label Both Sides (left + right)", group = gLab, tooltip = "Right = full ranking near the price axis; left = compact tag where the wall formed.")
maxLabeled  = input.int(14, "Max Labelled Levels (strongest)", minval = 1, maxval = 80, group = gLab, tooltip = "Only the strongest N walls get labels, so the map stays readable and the heavy levels pop.")
labelSepAtr = input.float(0.9, "Min Label Spacing (× ATR)", minval = 0.1, maxval = 6.0, step = 0.1, group = gLab, tooltip = "Labels closer together than this are skipped (strongest kept), so text never stacks into a blur.")
minLabelSc  = input.float(0.0, "Min Label Strength (0–10)", minval = 0.0, maxval = 10.0, step = 0.5, group = gLab, tooltip = "Hide labels on walls weaker than this score.")
showLev     = input.bool(true,  "Show Dominant Leverage Tier", group = gLab, tooltip = "Print the leverage tier (5×–100×) that contributed most to the wall.")
labelSize   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLab)

gC = "═══ Style (reclaim palette) ═══"
lowCol  = input.color(#cc24e2, "Low Power",  group = gC, tooltip = "Weakest liquidation levels.")
midCol  = input.color(#2f6de0, "Mid Power",  group = gC)
highCol = input.color(#21c997, "High Power", group = gC, tooltip = "Strongest liquidation walls.")

gAl = "Alerts"
alertProx = input.float(0.15, "Wall Proximity (% of price)", minval = 0.0, step = 0.01, group = gAl)
wallStr   = input.float(6.0, "Alert Wall Strength (0-10)", minval = 0.0, maxval = 10.0, step = 0.5, group = gAl, tooltip = "Only walls at least this strong arm the proximity and cascade alerts.")

clamp01(x) => math.min(math.max(x, 0.0), 1.0)
f_stars(sc) => sc >= 8.5 ? "★★★★★" : sc >= 7 ? "★★★★" : sc >= 5.5 ? "★★★" : sc >= 4 ? "★★" : "★"
f_tier(sc)  => sc >= 8.5 ? "WIPEOUT" : sc >= 7 ? "HEAVY" : sc >= 5.5 ? "STRONG" : sc >= 4 ? "MEDIUM" : "LIGHT"
f_lsz(s)    => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

f_grad(float p) =>
    float v = clamp01(p)
    v < 0.5 ? color.from_gradient(v, 0.0, 0.5, lowCol, midCol) : color.from_gradient(v, 0.5, 1.0, midCol, highCol)

f_tr(float p) =>
    float adj = math.pow(clamp01(p), contrast)
    int(math.round((100 - minOpac) + adj * (minOpac - maxOpac)))

float atr    = math.max(nz(ta.atr(atrLen), ta.tr), syminfo.mintick)
int   n      = bar_index
float volSma = ta.sma(volume, volSmaLen)
float hiG    = ta.highest(high, lookback)
float loG    = ta.lowest(low,  lookback)

var array<box>  dBox  = array.new<box>()
var array<line> dLine = array.new<line>()
var array<label> dLab = array.new<label>()
var float vUp = na
var float vDn = na

if barstate.islast
    for b in dBox
        box.delete(b)
    for l in dLine
        line.delete(l)
    for lb in dLab
        label.delete(lb)
    array.clear(dBox)
    array.clear(dLine)
    array.clear(dLab)

    int   bars = math.max(2, math.min(lookback, n))
    float hi   = hiG
    float lo   = loG
    float rng  = math.max(hi - lo, syminfo.mintick)
    float eLo  = lo - rng * rangePad
    float eHi  = hi + rng * rangePad
    float espan= math.max(eHi - eLo, syminfo.mintick)
    int   R    = math.max(8, rowsN)
    float rowH = espan / R

    array<float> tiers = array.new<float>()
    if useL5
        array.push(tiers, 5.0)
    if useL10
        array.push(tiers, 10.0)
    if useL25
        array.push(tiers, 25.0)
    if useL50
        array.push(tiers, 50.0)
    if useL100
        array.push(tiers, 100.0)
    int nT = array.size(tiers)
    bool doLong  = sideMode == "Both" or sideMode == "Longs below"
    bool doShort = sideMode == "Both" or sideMode == "Shorts above"

    array<float> rW   = array.new<float>(R, 0.0)
    array<int>   rOrg = array.new<int>(R, 0)
    array<bool>  rHas = array.new<bool>(R, false)
    array<float> rLev = array.new<float>(R, 0.0)
    array<float> rLevW= array.new<float>(R, 0.0)

    if nT > 0
        for s = 0 to bars - 1
            int   off = bars - 1 - s
            float v   = nz(volume[off], 0.0)
            float base= nz(volSma[off], v)
            if base > 0 and v >= base * volMult
                float px  = (high[off] + low[off] + close[off]) / 3.0
                float sz  = oiMode == "Volume only" ? v : v * (high[off] - low[off])
                float acc = useAccel ? math.max(0.0, v - base) / math.max(base, 1e-9) : 1.0
                float rw  = 1.0 + recency * (float(bars - off) / bars)
                float w   = sz * (useAccel ? (0.5 + 0.5 * math.min(acc, 3.0)) : 1.0) * rw
                for ti = 0 to nT - 1
                    float L = array.get(tiers, ti)
                    if doLong
                        float lp = px * (1.0 - mm / L)
                        int   rr = int((lp - eLo) / rowH)
                        if rr >= 0 and rr < R
                            array.set(rW, rr, array.get(rW, rr) + w)
                            array.set(rHas, rr, true)
                            if off > array.get(rOrg, rr)
                                array.set(rOrg, rr, off)
                            if w > array.get(rLevW, rr)
                                array.set(rLevW, rr, w)
                                array.set(rLev, rr, L)
                    if doShort
                        float sp = px * (1.0 + mm / L)
                        int   rr = int((sp - eLo) / rowH)
                        if rr >= 0 and rr < R
                            array.set(rW, rr, array.get(rW, rr) + w)
                            array.set(rHas, rr, true)
                            if off > array.get(rOrg, rr)
                                array.set(rOrg, rr, off)
                            if w > array.get(rLevW, rr)
                                array.set(rLevW, rr, w)
                                array.set(rLev, rr, L)

    float wMax = 1e-9
    for r = 0 to R - 1
        wMax := math.max(wMax, array.get(rW, r))

    float thr = wMax * cutoffPct / 100.0
    array<int>   cRow = array.new<int>()
    array<float> cW   = array.new<float>()
    for r = 0 to R - 1
        if array.get(rHas, r) and array.get(rW, r) >= thr
            bool lOk = r == 0     or array.get(rW, r) >= array.get(rW, r - 1)
            bool rOk = r == R - 1 or array.get(rW, r) >= array.get(rW, r + 1)
            if lOk and rOk
                array.push(cRow, r)
                array.push(cW, array.get(rW, r))

    float minSep = math.max(rowH, atr * minSepAtr)
    int   nC = array.size(cRow)
    array<bool> used = array.new<bool>(nC, false)
    array<int>  kRow = array.new<int>()
    while array.size(kRow) < maxBeams and nC > 0
        int   bi = -1
        float bm = -1.0
        for i = 0 to nC - 1
            if not array.get(used, i) and array.get(cW, i) > bm
                bm := array.get(cW, i)
                bi := i
        if bi < 0
            break
        array.set(used, bi, true)
        float pxi = eLo + (array.get(cRow, bi) + 0.5) * rowH
        bool ok = true
        if array.size(kRow) > 0
            for kk = 0 to array.size(kRow) - 1
                if math.abs((eLo + (array.get(kRow, kk) + 0.5) * rowH) - pxi) < minSep
                    ok := false
                    break
        if ok
            array.push(kRow, array.get(cRow, bi))

    float h2   = atr * beamHtAtr / 2.0
    int   rEnd = n + extendR
    array<float> placedY = array.new<float>()
    float labSep = atr * labelSepAtr
    vUp := na
    vDn := na
    float bestUp = 1e18
    float bestDn = 1e18
    if array.size(kRow) > 0
        for idx = 0 to array.size(kRow) - 1
            int   r    = array.get(kRow, idx)
            float mid  = eLo + (r + 0.5) * rowH
            float pow  = clamp01(array.get(rW, r) / wMax)
            int   org  = array.get(rOrg, r)
            int   left = anchorMode == "Full lookback" ? n - bars : n - org
            color base = f_grad(pow)
            int   baseTr = f_tr(pow)
            bool consumed = fadePassed and mid <= hi and mid >= lo and (high >= mid and low <= mid)
            int   dimAdd = consumed ? 22 : 0

            if 10.0 * pow >= wallStr
                if mid > close and (mid - close) < bestUp
                    bestUp := mid - close
                    vUp := mid
                if mid < close and (close - mid) < bestDn
                    bestDn := close - mid
                    vDn := mid

            for g = gradLayers - 1 to 0
                float frac = gradLayers > 1 ? float(g) / (gradLayers - 1) : 0.0
                float hh   = h2 * (0.45 + 0.55 * frac)
                int   tr   = math.min(96, baseTr + int(frac * (92 - baseTr)) + dimAdd)
                box bx = box.new(left, mid + hh, rEnd, mid - hh, border_color = na, border_width = 0, bgcolor = color.new(base, tr))
                array.push(dBox, bx)

            if showLabels and array.size(placedY) < maxLabeled
                float sc = 10.0 * pow
                bool spaced = true
                if array.size(placedY) > 0
                    for pi = 0 to array.size(placedY) - 1
                        if math.abs(array.get(placedY, pi) - mid) < labSep
                            spaced := false
                            break
                if sc >= minLabelSc and spaced
                    array.push(placedY, mid)
                    bool  isShort = mid > close
                    string sideT  = isShort ? "▲ SHORT-LIQ" : "▼ LONG-LIQ"
                    float dpc     = math.abs(mid - close) / close * 100.0
                    string levT   = showLev ? "  " + str.tostring(int(array.get(rLev, r))) + "×" : ""
                    color labCol  = color.new(base, 15)
                    string rTxt = f_stars(sc) + "  " + str.tostring(sc, "#.0") + "/10  " + f_tier(sc) + "  " + sideT + levT + "  " + str.tostring(dpc, "#.#") + "%"
                    label rl = label.new(rEnd, mid, rTxt, xloc = xloc.bar_index, style = label.style_label_left, color = labCol, textcolor = color.white, size = f_lsz(labelSize))
                    array.push(dLab, rl)
                    if bothSides
                        string lTxt = str.tostring(sc, "#.0") + " " + f_stars(sc) + "  " + str.tostring(mid, format.mintick)
                        label ll = label.new(left, mid, lTxt, xloc = xloc.bar_index, style = label.style_label_right, color = labCol, textcolor = color.white, size = f_lsz(labelSize))
                        array.push(dLab, ll)

    line pl = line.new(n - bars, close, rEnd, close, color = color.new(color.gray, 60), width = 1, style = line.style_dotted)
    array.push(dLine, pl)

float prox = close * alertProx / 100.0
alertcondition(not na(vUp) and math.abs(close - vUp) <= prox, "Approaching Short-Liq Wall", "Price approaching a strong short-liquidation wall above.")
alertcondition(not na(vDn) and math.abs(close - vDn) <= prox, "Approaching Long-Liq Wall",  "Price approaching a strong long-liquidation wall below.")
alertcondition(not na(vUp) and ta.crossover(close, vUp),  "Short-Liq Cascade", "Price reached a strong short-liquidation wall - potential cascade / squeeze up.")
alertcondition(not na(vDn) and ta.crossunder(close, vDn), "Long-Liq Cascade",  "Price reached a strong long-liquidation wall - potential cascade / flush down.")
````
