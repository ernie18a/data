<!-- tradingview-pine-id: PUB;9679813161b34a788c1e70f2a97fd01c -->
<!-- tradingviewscripts-format: 1 -->
# Volume Profile Anchored VWAP, AVWAP Bands & Deviation [LunqFX]

Source: https://www.tradingview.com/script/JXRllDuK-Volume-Profile-Anchored-VWAP-AVWAP-Bands-Deviation-LunqFX/

## Description

Most anchored VWAP tools make you drag the anchor by hand, and it goes stale the moment structure changes. This one places the anchor automatically at confirmed swing pivots, wraps it in volume weighted standard deviation bands, hangs the leg's volume profile off the right edge, and then measures whether those bands are being respected on the symbol in front of you.

The annotated charts below explain the script's output element by element.

❶ AUTO ANCHORED VWAP

An anchored VWAP is only meaningful from a point that mattered. Anchor it at an arbitrary bar and it describes nothing; anchor it where the market last turned and it becomes the average price everyone trading THIS leg is carrying — which is exactly the level they defend.

The anchor is placed at confirmed swing pivots, with two guards that matter more than they sound:

▸ MINIMUM LEG — a fresh pivot cannot take over until the running leg has had room to form. Without that rule a cluster of pivots chops the curve into stubs and the VWAP never describes anything. ▸ MAXIMUM LEG — a leg that outlives its usefulness resets rather than growing into a whole-history average.

Session, weekly and monthly anchors are available for traders who prefer calendar anchoring.

❷ STANDARD DEVIATION BANDS

Around the anchored VWAP the script draws volume weighted standard deviation bands at three depths, filled as a gradient so distance from fair value is readable without measuring. Three details make them behave:

▸ WARM-UP — at the anchor the deviation is zero by definition, so the first bars of every leg would draw as a collapsing funnel. Those bars are still measured; they are simply not drawn. ▸ MINIMUM WIDTH — an ATR floor stops the bands pinching shut during dead stretches. ▸ DISPLAY SMOOTHING — the deviation path is box-filtered for drawing only. The VWAP itself and every statistic use the raw values, so nothing you act on is smoothed.

[image]https://www.tradingview.com/x/0jEhtDSf/[/image]

❸ VOLUME FLOW

Each bar's participation is drawn as fine texture reaching inward from the band edges: buy pressure rises from the lower edge, sell pressure falls from the upper one, split by where the bar closed inside its own range. The bands are the baseline, so the leg's pressure reads along the structure instead of on a separate pane.

❹ VOLUME PROFILE OF THE LEG

At the right edge the script hangs the volume distribution of the whole leg, split buy against sell, with a seam line at the join and a traced outline. Each bar is binned against its OWN slice of the channel rather than a fixed price grid, so a sloping leg does not smear the distribution — a detail most profile overlays skip, and the reason the shape stays honest on a trending market.

❺ BAND REACTION STATISTICS

Bands tell you where price is. They do not tell you what that has meant here. So the script measures it: for every touch of the chosen band inside the current leg it checks whether price returned to the VWAP within your window, and reports the share that did, together with the number of touches.

That single number changes how the same picture is read. A leg where touches of the upper band came back to VWAP most of the time is mean-reverting, and the band is a fade. A leg where they did not is trending, and the same touch is continuation. Samples too small to conclude anything from are marked with a tilde rather than presented as a result.

[image]https://www.tradingview.com/x/h6GPb26I/[/image]

❻ WHAT YOU SEE ON THE CHART

▸ Dashed vertical line with the ANCHOR badge — where the current leg begins. ▸ Three teal bands below and three red bands above, filled as a gradient — deviation depth from the VWAP. ▸ Dark line through the middle — the anchored VWAP itself. ▸ Fine ticks along the band edges — per-bar buy and sell participation. ▸ Horizontal rows at the right edge — the leg's volume profile, teal for buy, red for sell. ▸ Panel — side of the VWAP, distance in σ with a position ruler, the VWAP and band levels, and the reaction statistics.

❼ HOW TO TRADE IT

1 — Read the header. Above or below the anchored VWAP is the leg's bias; the σ figure is how stretched price is right now. 2 — Check the reaction row before deciding what a band touch means. High return rate means the bands are fades. Low return rate means they are continuation. 3 — Use the VWAP as the leg's fair value. Pullbacks into it in the direction of the leg are the cleanest entries this tool produces. 4 — Use the volume profile to find where the leg actually traded. Thin rows are areas price passed through quickly and tends to pass through quickly again. 5 — Watch the anchor. A new anchor means structure turned and the previous leg's levels stopped applying.

❽ NON-REPAINTING

This is the part that separates an anchored VWAP from a rolling regression channel, and it is worth being precise about. The anchor is a CONFIRMED pivot and only ever moves forward. A VWAP is cumulative, so once a bar closes its contribution to the average is fixed forever — every band value already printed stays exactly where it is. Nothing is recalculated behind you. Every statistic is built from closed bars only.

SETTINGS

▸ Anchor — anchor mode (swing pivot, session, week, month), pivot length, minimum and maximum leg. ▸ Bands — three deviation depths, warm-up bars hidden, minimum width in ATR, display smoothing, gradient fill and VWAP line toggles. ▸ Volume Flow — texture height in ATR and thickness. ▸ Volume Profile — rows, width, thickness, seam and outline toggle. ▸ Band Reaction — which band counts as a touch, the reaction window, optional touch markers. ▸ Visuals — candle colouring, anchor marker, dashboard position.

ALERTS — upper band touch, lower band touch, VWAP reclaimed, VWAP lost, and new anchor. All fire on closed bars only.

WHY THESE PARTS ARE ONE SCRIPT

They describe one object at four resolutions. The anchor defines the leg; the standard deviation bands measure dispersion inside it; the flow and the volume profile show where its volume actually went; and the reaction statistics say whether that structure is being respected. Take the anchor away and the VWAP averages a period nobody traded as a unit. Take the profile away and the bands float above an unknown distribution. Take the statistics away and the bands become decoration you have to interpret by feel. None of them stands alone, which is why they ship together.

Works on any symbol with volume — forex, metals, indices, crypto and stocks — on intraday and higher timeframes alike. Symbols without real volume data will report a flat profile.

This indicator is an educational market-analysis tool, not financial advice. The reaction statistics describe the recorded historical behaviour of the current leg on the loaded chart; past behaviour does not predict future results. Always confirm with your own analysis and manage your risk.

---

## Source Code

````pine
//@version=6
// ============================================================================
//  Anchored VWAP — Deviation Bands, Flow & Volume Profile [LunqFX]
// ----------------------------------------------------------------------------
//  A VWAP only means something from a point that mattered. Anchor it anywhere
//  and it describes nothing; anchor it where the market last turned and it
//  becomes the average price everyone trading THIS leg is carrying — which is
//  precisely the level they defend.
//
//    1  AUTO ANCHOR   re-anchors at confirmed swing pivots, with a minimum
//                     leg length so the curve sweeps instead of stuttering
//    2  BANDS         volume weighted deviation at three depths, smoothed for
//                     display and floored so they never collapse to a point
//    3  FLOW          per-bar buy and sell participation as fine texture
//                     reaching inward from the band edges
//    4  PROFILE       the leg's volume distribution, split buy against sell,
//                     hung off the channel edge with a seam and a traced outline
//    5  REACTION      how often a touch of the outer band actually returned to
//                     the VWAP inside this leg — measured, not assumed
//
//  NON-REPAINTING: the anchor is a CONFIRMED pivot and only moves forward. A
//  VWAP is cumulative, so once a bar closes its contribution is fixed — every
//  band value already printed stays exactly where it is.
// ============================================================================
// max_bars_back is set explicitly because the leg is walked with a runtime
// offset that can reach the maximum leg length; Pine's automatic buffer is
// sized from the first bars it sees and would fall short of that.
indicator("Volume Profile Anchored VWAP, AVWAP Bands & Deviation [LunqFX]",
     "AVWAP", overlay = true, max_bars_back = 500,
     max_polylines_count = 100, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE — vivid enough to hold against a light violet chart, hues placed
//  far from the background so nothing turns muddy
// ─────────────────────────────────────────────────────────────────────────
// Teal against pure red: on a violet chart these two sit roughly a third of
// the wheel away from the background in opposite directions, so neither one
// blends into it the way a rose or a lime would.
BULL     = #0D9488
BEAR     = #DC2626
NEUT     = #7C8DA3
INK      = #1E293B
SEAM     = #FFFFFF
AMBER    = #B45309
CARD     = #131A24
CARD_2   = #1B2431
TXT      = #F1F5F9
MUTE     = #94A3B8
BULL_TXT = #6BE79B
BEAR_TXT = #FF9090

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gA      = "Anchor"
anchorM = input.string("Swing pivot", "Anchor at", options = ["Swing pivot", "Session", "Week", "Month"], group = gA, tooltip = "Swing pivot re-anchors at every confirmed structural turn — the leg you are actually trading. The calendar options anchor at the start of each session, week or month.")
pivLen  = input.int(28, "Pivot length", minval = 5, maxval = 80, group = gA, tooltip = "How major a swing must be to become a new anchor. Higher gives fewer, longer legs and a smoother sweep.")
minLeg  = input.int(80, "Minimum leg (bars)", minval = 20, maxval = 300, group = gA, tooltip = "A new pivot cannot re-anchor before the current leg reaches this age. Without it a cluster of pivots chops the curve into stubs.")
maxLeg  = input.int(460, "Maximum leg (bars)", minval = 60, maxval = 500, group = gA)

gB      = "Bands"
sd1     = input.float(1.0, "Band 1 (σ)", minval = 0.25, maxval = 6.0, step = 0.25, group = gB)
sd2     = input.float(2.0, "Band 2 (σ)", minval = 0.25, maxval = 6.0, step = 0.25, group = gB)
sd3     = input.float(3.0, "Band 3 (σ)", minval = 0.25, maxval = 6.0, step = 0.25, group = gB)
warmUp  = input.int(15, "Warm-up (bars hidden)", minval = 0, maxval = 60, group = gB, tooltip = "At the anchor the deviation is zero by definition, so the first bars of a leg draw as a collapsing funnel. These bars are still measured — they are simply not drawn.")
sdFloor = input.float(0.35, "Minimum width (× ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = gB, tooltip = "Stops the bands pinching shut during very quiet stretches.")
smooth  = input.int(4, "Band smoothing", minval = 0, maxval = 15, group = gB, tooltip = "Display smoothing of the deviation path. The VWAP itself and every statistic use the raw values.")
showFill= input.bool(true, "Gradient fill", group = gB)
showVwap= input.bool(true, "VWAP line", group = gB)

gF      = "Volume Flow"
showFlow= input.bool(true, "Show flow texture", group = gF)
flowH   = input.float(1.1, "Height (× ATR)", minval = 0.1, maxval = 4.0, step = 0.05, group = gF)
flowW   = input.int(3, "Thickness", minval = 1, maxval = 6, group = gF)

gP      = "Volume Profile"
showProf= input.bool(true, "Show leg profile", group = gP)
profRows= input.int(34, "Rows", minval = 12, maxval = 48, group = gP)
profW   = input.int(24, "Width (bars)", minval = 6, maxval = 60, group = gP)
profTh  = input.int(7, "Thickness", minval = 2, maxval = 12, group = gP)
profLine= input.bool(true, "Seam and outline", group = gP)

gR      = "Band Reaction"
showStat= input.bool(true, "Measure band reactions", group = gR, tooltip = "For every touch of the outer band inside this leg, checks whether price came back to the VWAP within the window below. It tells you whether the leg is mean-reverting or trending — the same touch means opposite things in each case.")
statBand= input.string("Band 1", "Measure at", options = ["Band 1", "Band 2", "Band 3"], group = gR, tooltip = "Which band counts as a touch. On a trending leg price rides one side and rarely tags the outer bands, so measuring there leaves the sample empty — band 1 is where the count actually fills up.")
revBars = input.int(20, "Reaction window (bars)", minval = 3, maxval = 100, group = gR)
showHits= input.bool(false, "Mark band touches", group = gR)

gV      = "Visuals"
candOn  = input.bool(true, "Colour candles", group = gV)
showAnch= input.bool(true, "Mark the anchor", group = gV)
showHUD = input.bool(true, "Dashboard", group = gV)
hudPos  = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gV)

// ─────────────────────────────────────────────────────────────────────────
//  ANCHOR
// ─────────────────────────────────────────────────────────────────────────
atr14  = ta.atr(14)
src    = hlc3
sdStat = statBand == "Band 1" ? sd1 : statBand == "Band 3" ? sd3 : sd2

ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)

newPeriod = switch anchorM
    "Session" => timeframe.change("D")
    "Week"    => timeframe.change("W")
    "Month"   => timeframe.change("M")
    => false

var int anchorBar = 0

if anchorM == "Swing pivot"
    // a fresh pivot only takes over once the running leg has had room to form
    if (not na(ph) or not na(pl)) and (bar_index - pivLen) - anchorBar >= minLeg
        anchorBar := bar_index - pivLen
    else if bar_index - anchorBar > maxLeg
        // a hard reset rather than a sliding window: sliding would re-anchor on
        // every single bar from here on and rebuild the whole leg each time
        anchorBar := bar_index
else if newPeriod
    anchorBar := bar_index

// live cumulative VWAP for candles, dashboard and alerts
// declared one per line on purpose: Pine applies `var` only to the FIRST
// name in a comma-chained declaration, so the rest would silently reset every
// bar and the running VWAP would divide a full leg by a single bar's volume
var float cPV  = 0.0
var float cV   = 0.0
var float cPV2 = 0.0
if ta.change(anchorBar) != 0
    cPV := 0.0
    cV := 0.0
    cPV2 := 0.0
    back = math.min(bar_index - anchorBar, maxLeg)
    for k = back to 0
        v = nz(volume[k])
        p = src[k]
        cPV  += p * v
        cV   += v
        cPV2 += p * p * v
else
    v = nz(volume)
    cPV  += src * v
    cV   += v
    cPV2 += src * src * v

float vwap = cV > 0 ? cPV / cV : na
float vSd  = cV > 0 ? math.sqrt(math.max(0.0, cPV2 / cV - vwap * vwap)) : na
if not na(vSd)
    vSd := math.max(vSd, nz(atr14) * sdFloor)

// ─────────────────────────────────────────────────────────────────────────
//  STORE
// ─────────────────────────────────────────────────────────────────────────
var array<polyline> pls = array.new<polyline>()
var array<line>     lns = array.new<line>()
var array<label>    lbs = array.new<label>()
var array<float>    vPath = array.new<float>()
var array<float>    sPath = array.new<float>()   // raw deviation — used by stats
var array<float>    dPath = array.new<float>()   // smoothed — used for drawing

var int upTouch = 0
var int upBack  = 0
var int dnTouch = 0
var int dnBack  = 0

wipe() =>
    if array.size(pls) > 0
        for i = 0 to array.size(pls) - 1
            polyline.delete(array.get(pls, i))
        array.clear(pls)
    if array.size(lns) > 0
        for i = 0 to array.size(lns) - 1
            line.delete(array.get(lns, i))
        array.clear(lns)
    if array.size(lbs) > 0
        for i = 0 to array.size(lbs) - 1
            label.delete(array.get(lbs, i))
        array.clear(lbs)

// drawing helpers walk only the visible part of the leg, so the collapsing
// funnel at the anchor never reaches the chart
trace(int n, int from, float k) =>
    pts = array.new<chart.point>()
    for i = from to n - 1
        pts.push(chart.point.from_index(bar_index - (n - 1 - i), array.get(vPath, i) + array.get(dPath, i) * k))
    pts

ribbon(int n, int from, float kt, float kb, color col, int tr) =>
    pts = array.new<chart.point>()
    for i = from to n - 1
        pts.push(chart.point.from_index(bar_index - (n - 1 - i), array.get(vPath, i) + array.get(dPath, i) * kt))
    for i = n - 1 to from
        pts.push(chart.point.from_index(bar_index - (n - 1 - i), array.get(vPath, i) + array.get(dPath, i) * kb))
    if pts.size() > 2
        array.push(pls, polyline.new(pts, true, true, line_color = color.new(col, 100), fill_color = color.new(col, tr)))

// ─────────────────────────────────────────────────────────────────────────
//  RENDER
// ─────────────────────────────────────────────────────────────────────────
if barstate.islast and not na(vwap)
    n = math.min(bar_index - anchorBar + 1, maxLeg)

    if n > warmUp + 8
        wipe()
        array.clear(vPath)
        array.clear(sPath)
        array.clear(dPath)

        // rebuild the cumulative path forward from the anchor
        float aPV  = 0.0
        float aV   = 0.0
        float aPV2 = 0.0
        floorV = nz(atr14) * sdFloor
        for i = 0 to n - 1
            off = n - 1 - i
            v   = nz(volume[off])
            p   = src[off]
            aPV  += p * v
            aV   += v
            aPV2 += p * p * v
            vw = aV > 0 ? aPV / aV : p
            sv = aV > 0 ? math.sqrt(math.max(0.0, aPV2 / aV - vw * vw)) : 0.0
            array.push(vPath, vw)
            array.push(sPath, math.max(sv, floorV))

        // display-only smoothing of the deviation path — a box filter, so the
        // edges read as one sweeping curve instead of a noisy outline
        for i = 0 to n - 1
            if smooth < 1
                array.push(dPath, array.get(sPath, i))
            else
                lo = math.max(0, i - smooth)
                hi = math.min(n - 1, i + smooth)
                acc = 0.0
                for k = lo to hi
                    acc += array.get(sPath, k)
                array.push(dPath, acc / (hi - lo + 1))

        from = math.min(warmUp, n - 6)

        // ── gradient, densest at the outer edge ──
        if showFill
            ribbon(n, from, sd3, sd2, BEAR, 90)
            ribbon(n, from, sd2, sd1, BEAR, 94)
            ribbon(n, from, sd1, 0.0, BEAR, 97)
            ribbon(n, from, 0.0, -sd1, BULL, 97)
            ribbon(n, from, -sd1, -sd2, BULL, 94)
            ribbon(n, from, -sd2, -sd3, BULL, 90)

        // ── flow texture first, so the band cores stay crisp above it ──
        if showFlow
            vMax = 0.0
            for i = from to n - 1
                vMax := math.max(vMax, nz(volume[n - 1 - i]))
            hMax = nz(atr14) * flowH
            if vMax > 0 and hMax > 0
                for i = from to n - 1
                    off = n - 1 - i
                    v   = nz(volume[off])
                    if v > 0
                        x    = bar_index - off
                        vw   = array.get(vPath, i)
                        dv   = array.get(dPath, i)
                        span = math.max(high[off] - low[off], syminfo.mintick)
                        cp   = math.max(0.0, math.min(1.0, (close[off] - low[off]) / span))
                        h    = v / vMax * hMax
                        bH   = h * cp
                        sH   = h * (1.0 - cp)
                        if bH > syminfo.mintick
                            y = vw - dv * sd3
                            array.push(lns, line.new(x, y, x, y + bH, color = color.new(BULL, 28), width = flowW))
                        if sH > syminfo.mintick
                            y = vw + dv * sd3
                            array.push(lns, line.new(x, y, x, y - sH, color = color.new(BEAR, 28), width = flowW))

        // ── edges: wide soft pass, mid pass, thin bright core ──
        for k in array.from(sd1, sd2, sd3)
            outer = k == sd3
            up = trace(n, from, k)
            dn = trace(n, from, -k)
            if up.size() > 1
                array.push(pls, polyline.new(up, false, false, line_color = color.new(BEAR, 89), line_width = outer ? 7 : 5))
                array.push(pls, polyline.new(up, false, false, line_color = color.new(BEAR, outer ? 5 : 55), line_width = outer ? 2 : 1))
            if dn.size() > 1
                array.push(pls, polyline.new(dn, false, false, line_color = color.new(BULL, 89), line_width = outer ? 7 : 5))
                array.push(pls, polyline.new(dn, false, false, line_color = color.new(BULL, outer ? 5 : 55), line_width = outer ? 2 : 1))

        if showVwap
            mid = trace(n, from, 0.0)
            if mid.size() > 1
                array.push(pls, polyline.new(mid, false, false, line_color = color.new(INK, 86), line_width = 5))
                array.push(pls, polyline.new(mid, false, false, line_color = color.new(INK, 32), line_width = 1))

        // the anchor reads better as a hairline through the channel than as a
        // flag hanging off the price — the line says WHERE, the text says WHAT,
        // and neither one covers a candle
        // a badge that points down at the top of the channel, with a hairline
        // dropping through it: visible without sitting on top of any candle
        if showAnch
            aX  = bar_index - (n - 1 - from)
            aY  = array.get(vPath, from)
            aDv = array.get(dPath, from)
            array.push(lns, line.new(aX, aY - aDv * sd3, aX, aY + aDv * sd3, color = color.new(AMBER, 25), width = 2, style = line.style_dashed))
            array.push(lbs, label.new(aX, aY + aDv * sd3, "  ⚑  ANCHOR  ", style = label.style_label_down, color = INK, textcolor = AMBER, size = size.large))

        // ── leg profile, hung off the channel edge ──
        if showProf
            vwL  = array.get(vPath, n - 1)
            dvL  = array.get(dPath, n - 1)
            pTop = vwL + dvL * sd3
            pBot = vwL - dvL * sd3
            rowH = (pTop - pBot) / profRows
            bAcc = array.new<float>(profRows, 0.0)
            sAcc = array.new<float>(profRows, 0.0)

            for i = from to n - 1
                off = n - 1 - i
                v   = nz(volume[off])
                if v > 0
                    vw   = array.get(vPath, i)
                    dv   = array.get(dPath, i)
                    rTop = vw + dv * sd3
                    rBot = vw - dv * sd3
                    rH   = (rTop - rBot) / profRows
                    span = math.max(high[off] - low[off], syminfo.mintick)
                    cp   = math.max(0.0, math.min(1.0, (close[off] - low[off]) / span))
                    // binned against the bar's OWN slice of the channel, so a
                    // sloping leg does not smear the distribution
                    for r = 0 to profRows - 1
                        lo = rBot + rH * r
                        hi = lo + rH
                        ov = math.max(0.0, math.min(high[off], hi) - math.max(low[off], lo))
                        if ov > 0
                            sh = ov / span
                            array.set(bAcc, r, array.get(bAcc, r) + v * cp * sh)
                            array.set(sAcc, r, array.get(sAcc, r) + v * (1.0 - cp) * sh)

            pMax = 0.0
            for r = 0 to profRows - 1
                pMax := math.max(pMax, array.get(bAcc, r) + array.get(sAcc, r))

            // the profile is scaled against the leg it describes — a full-width
            // profile hanging off a sixty-bar leg dwarfs the chart it belongs to
            pW   = math.max(6, math.min(profW, int(n / 4)))
            x0   = bar_index + 1
            edge = array.new<chart.point>()
            if pMax > 0
                for r = 0 to profRows - 1
                    bv = array.get(bAcc, r)
                    sv = array.get(sAcc, r)
                    tv = bv + sv
                    y  = pBot + rowH * (r + 0.5)
                    wT = int(math.round(tv / pMax * pW))
                    wB = tv > 0 ? int(math.round(wT * bv / tv)) : 0
                    wS = math.max(0, wT - wB)
                    t  = int(math.max(20, 76 - tv / pMax * 56))
                    if wB > 0
                        array.push(lns, line.new(x0, y, x0 + wB, y, color = color.new(BULL, t), width = profTh))
                    if wS > 0
                        array.push(lns, line.new(x0 + wB, y, x0 + wB + wS, y, color = color.new(BEAR, t), width = profTh))
                    edge.push(chart.point.from_index(x0 + wT, y))

                if profLine
                    array.push(lns, line.new(x0, pBot, x0, pTop, color = color.new(SEAM, 58), width = 4))
                    array.push(lns, line.new(x0, pBot, x0, pTop, color = color.new(SEAM, 12), width = 1))
                    if edge.size() > 1
                        array.push(pls, polyline.new(edge, true, false, line_color = color.new(SEAM, 74), line_width = 6))
                        array.push(pls, polyline.new(edge, true, false, line_color = color.new(SEAM, 20), line_width = 1))

        // ── band reactions, measured on the RAW deviation ──
        upTouch := 0
        upBack  := 0
        dnTouch := 0
        dnBack  := 0
        if showStat and n > warmUp + revBars + 3
            marks = 0
            for i = math.max(1, from) to n - 1 - revBars
                off = n - 1 - i
                vw  = array.get(vPath, i)
                sv  = array.get(sPath, i)
                hiU = high[off] >= vw + sv * sdStat
                loD = low[off]  <= vw - sv * sdStat
                pU  = high[off + 1] >= array.get(vPath, i - 1) + array.get(sPath, i - 1) * sdStat
                pD  = low[off + 1]  <= array.get(vPath, i - 1) - array.get(sPath, i - 1) * sdStat

                if hiU and not pU
                    upTouch += 1
                    back = false
                    for j = 1 to revBars
                        if not back and low[off - j] <= array.get(vPath, i + j)
                            back := true
                    if back
                        upBack += 1
                    if showHits and marks < 70
                        array.push(lbs, label.new(bar_index - off, vw + array.get(dPath, i) * sd3, "", style = label.style_circle, size = size.tiny, color = color.new(BEAR, back ? 15 : 72)))
                        marks += 1

                if loD and not pD
                    dnTouch += 1
                    back = false
                    for j = 1 to revBars
                        if not back and high[off - j] >= array.get(vPath, i + j)
                            back := true
                    if back
                        dnBack += 1
                    if showHits and marks < 70
                        array.push(lbs, label.new(bar_index - off, vw - array.get(dPath, i) * sd3, "", style = label.style_circle, size = size.tiny, color = color.new(BULL, back ? 15 : 72)))
                        marks += 1

// ─────────────────────────────────────────────────────────────────────────
//  CANDLES — tinted by the side of the anchored VWAP, so bars and bands
//  tell the same story
// ─────────────────────────────────────────────────────────────────────────
// Four readable states instead of one flat colour: the outline says which side
// of fair value the market is on, the body says whether the bar itself closed
// up or down. On a pale chart a hollow body reads as "up" without needing a
// second hue.
above = close > nz(vwap, close)
cEdge = above ? BULL : BEAR
cBody = close >= open ? #FFFFFF : cEdge
plotcandle(candOn ? open : na, high, low, close, "Candles", color = cBody, wickcolor = cEdge, bordercolor = cEdge)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
hudP(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

// a tilde flags a sample too thin to conclude anything from, so two touches
// never read like a verdict
pctOf(int a, int b) =>
    b > 0 ? (b < 5 ? "~" : "") + str.tostring(math.round(a / float(b) * 100)) + "% (" + str.tostring(b) + ")" : "—"

// a text ruler from −3σ to +3σ with the current reading marked: the panel's
// core number is a position, and a position is easier to see than to read
ruler(float dev) =>
    slot = int(math.round(math.max(0.0, math.min(20.0, (dev + 3.0) / 6.0 * 20.0))))
    out = ""
    for i = 0 to 20
        out += i == slot ? "◆" : i == 10 ? "┃" : "─"
    out

var table hud = na
if showHUD and barstate.islast and not na(vwap) and not na(vSd)
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudP(hudPos), 2, 5, bgcolor = CARD, border_color = color.new(#28323F, 0), border_width = 1)

    devNow = vSd > 0 ? (close - vwap) / vSd : 0.0
    legLen = bar_index - anchorBar
    hBg  = above ? BULL : BEAR
    hTx  = above ? "▲  ABOVE VWAP" : "▼  BELOW VWAP"
    devC = math.abs(devNow) >= sd2 ? (devNow > 0 ? BEAR_TXT : BULL_TXT) : TXT

    table.cell(hud, 0, 0, "  " + hTx + "   ·   leg " + str.tostring(legLen) + "  ", text_color = color.white, text_size = size.normal, text_halign = text.align_left, bgcolor = hBg)
    table.cell(hud, 1, 0, (devNow >= 0 ? "+" : "") + str.tostring(devNow, "#.##") + "σ  ", text_color = color.white, text_size = size.large, text_halign = text.align_right, bgcolor = hBg)

    table.cell(hud, 0, 1, "  " + ruler(devNow) + "  ", text_color = devC, text_size = size.large, text_halign = text.align_left, bgcolor = CARD_2)
    table.cell(hud, 1, 1, "−3σ … +3σ  ", text_color = MUTE, text_size = size.small, text_halign = text.align_right, bgcolor = CARD_2)

    table.cell(hud, 0, 2, "  VWAP", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 2, str.tostring(vwap, format.mintick) + "  ", text_color = TXT, text_size = size.huge, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 3, "  Band " + str.tostring(sd3, "#.#") + "σ", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 3, str.tostring(vwap + vSd * sd3, format.mintick) + "   ·   " + str.tostring(vwap - vSd * sd3, format.mintick) + "  ", text_color = TXT, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 4, "  Returned to VWAP", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 4, "from upper " + pctOf(upBack, upTouch) + "   ·   from lower " + pctOf(dnBack, dnTouch) + "  ", text_color = TXT, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS — closed bars only
// ─────────────────────────────────────────────────────────────────────────
alertcondition(barstate.isconfirmed and high >= vwap + vSd * sd3, "Upper band touch", "LunqFX Anchored VWAP: price reached the upper deviation band")
alertcondition(barstate.isconfirmed and low  <= vwap - vSd * sd3, "Lower band touch", "LunqFX Anchored VWAP: price reached the lower deviation band")
alertcondition(ta.crossover(close, vwap),  "VWAP reclaimed", "LunqFX Anchored VWAP: price closed back above the anchored VWAP")
alertcondition(ta.crossunder(close, vwap), "VWAP lost",      "LunqFX Anchored VWAP: price closed back below the anchored VWAP")
alertcondition(ta.change(anchorBar) != 0,  "New anchor",     "LunqFX Anchored VWAP: a new swing pivot confirmed and the VWAP re-anchored")
````
