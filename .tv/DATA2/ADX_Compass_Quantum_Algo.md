<!-- tradingview-pine-id: PUB;2d839461f1ca460fb263b60b79fb1496 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ADX Compass [Quantum Algo]

Source: https://www.tradingview.com/script/oKMstYli-ADX-Compass-Quantum-Algo/

## Description

ADX Compass [Quantum Algo]

═══════════════════════════════════════════════

🔶 OVERVIEW

ADX Compass turns the Average Directional Index into an instrument you can steer by. It answers the four questions the raw index never answers cleanly: how strong is this trend for THIS symbol, which side is driving it, how old is it compared with this market's typical trend, and is it about to fail — and then paints the answers onto the price chart as a strength aura and a directional ribbon, so the reading lives on the candles.

The central upgrade is adaptive strength. Fixed levels like 20 and 25 mean different things on every symbol and timeframe. This tool ranks the index against its own recent history, so "weak" and "strong" are defined by the market you are actually looking at. On top of that it measures trend age against the symbol's own average trend lifespan, filters directional crosses by strength, detects exhaustion as the index turns from a strong peak, and scores each signal family on your exact chart.

═══════════════════════════════════════════════

🔶 WHAT IS THE ADX?

The Average Directional Index, created by J. Welles Wilder Jr., measures the STRENGTH of a trend without regard to its direction. It is derived from Directional Movement: +DI measures upward pressure, −DI measures downward pressure, and the index smooths the spread between them. A rising index means a trend — up or down — is gaining force; a falling index means it is losing force. Direction comes from which directional line is on top.

═══════════════════════════════════════════════

🔶 WHY FIXED ADX LEVELS FAIL

The traditional rule — above 25 means trending — was calibrated on the markets of its era. A quiet index may spend years rarely reaching 25 while a volatile pair lives above it in what is effectively a range. ADX Compass replaces the constant with a percentile rank inside the symbol's recent history: weak below the 30th percentile, building in between, strong above the 70th. The classic fixed levels remain available as a toggle, and the dashboard always shows the live thresholds in use.

═══════════════════════════════════════════════

🔶 WHY IS THIS ORIGINAL?

1. Adaptive strength ranking. Weak, Building and Strong are defined by the symbol's own distribution, never by a hard-coded number, with the live thresholds displayed.

2. Trend Age. When strength enters the strong zone a trend clock starts. Its reading is compared against the average lifespan of this symbol's recent trends and labeled Early, Mature or Late — a maturity gauge that warns before the index visibly rolls over.

3. Strength-filtered directional signals. The T family fires on a directional cross only when strength is already present and rising, removing the whipsaw crosses that make raw Directional Movement unusable in ranges.

4. Ignition and Exhaustion as first-class events. B marks the index breaking into its strong zone with the dominant side; E marks the index turning down from a strong peak — the earliest measurable sign a trend is losing force.

5. The reading on the price chart. A strength aura tints the background in the dominant side's color, intensifying with strength; a directional ribbon through price whose opacity IS the index — bold in strong trends, ghosted in chop.

6. Per-family statistics. Each family's ten-bar outcomes are tracked on your chart, shrunk toward neutral at small samples with a Wilson lower bound, and quoted in every signal's tooltip and on the dashboard.

═══════════════════════════════════════════════

🔶 HOW IT WORKS

— Directional Movement and the index are computed with Wilder's smoothing at configurable lengths.
— The index is ranked inside its history window to derive adaptive thresholds and the current percentile.
— A trend clock runs while strength is strong; completed trend lengths feed the average lifespan used for the maturity label.
— Signals are evaluated on confirmed bars: T on filtered directional crosses, B on strength ignition, E on a confirmed peak-turn in the strong zone.
— Every family feeds its own first-in-first-out outcome samples; the E family is scored on whether the trend actually stalled.

Signals do not repaint. All drawings are capped for performance.

═══════════════════════════════════════════════

🔶 HOW TO USE IT

— Trade the ribbon's opacity: bold ribbon and a full aura mean trend strategies are in their habitat; a ghosted ribbon means range tactics.
— Respect Trend Age: Early trends favor entries on pullbacks, Late trends favor tightening risk and taking profit; the E signal is the confirmation that a Late trend is failing.
— Use B as the regime trigger: strength ignition with the dominant side tells you a range just ended and which way.
— Read the family records before trusting a letter — they tell you how this symbol has historically honored each event.
— Works on all markets and timeframes; the adaptive thresholds recalibrate wherever you load it.

═══════════════════════════════════════════════

🔶 SETTINGS

— Directional Index: directional length, index smoothing, adaptive toggle, fixed levels, history window.
— Signals: visibility, cooldown.
— Statistics: sample cap, minimum samples, shrinkage strength, Wilson z-score.
— Visuals and dashboard: aura and ribbon toggles, ribbon length, full color and position control.

═══════════════════════════════════════════════

🔶 ALERTS

— Directional Cross — the directional lines crossed with strength present and rising.
— Strength Ignition — the index broke into its strong zone.
— Trend Exhaustion — the index turned down from a strong peak.
— Strong Trend Began — adaptive strength entered the strong zone.

═══════════════════════════════════════════════

🔶 FAQ

Q: Does it repaint?
A: No. Signals are evaluated on confirmed bars and never change once printed. The adaptive thresholds move slowly as the history window rolls, but past signals are not re-evaluated.

Q: Does the ADX show direction?
A: The index itself does not — it measures strength only. Direction comes from the directional lines, which this tool reads for you as the Compass row, the aura color and the ribbon color.

Q: Why does the ribbon fade?
A: Its opacity is tied to strength. A faint ribbon is not a bug — it is the tool telling you the trend has no force behind it.

Q: What does "Late" mean in Trend Age?
A: The current trend has already lasted longer than this symbol's average trend. It is not a sell signal; it is a maturity reading that raises the value of the exhaustion signal when it comes.

Q: What do the family percentages mean?
A: The share of past signals in that family after which price had moved favorably ten bars later (for E, the share after which the trend stalled), on the current symbol and timeframe, shrunk toward fifty percent at small samples. They describe history — they are not predictions.

═══════════════════════════════════════════════

🔶 CREDITS

The Average Directional Index, the Directional Movement system and the Average True Range are by J. Welles Wilder Jr. (New Concepts in Technical Trading Systems, 1978). The Wilson score interval is by Edwin B. Wilson (1927). The adaptive strength ranking, trend-age model, signal families, per-symbol statistics, on-chart rendering and all code in this script are original work — no third-party or open-source script code was reused.

═══════════════════════════════════════════════

🔶 LIMITATIONS

— The index is a smoothed, lagging measure; adaptive ranking sharpens its reading but cannot remove the lag.
— Trend Age needs several completed trends on the chart before the average lifespan is meaningful.
— Statistics describe the current chart's history only; past frequencies never guarantee future outcomes.

═══════════════════════════════════════════════

🔶 DISCLAIMER

This indicator is a research and charting tool provided for educational purposes. It is not financial advice, and nothing it displays is a recommendation to buy or sell any asset. Trading involves substantial risk of loss. Always do your own analysis and manage risk responsibly.

---

## Source Code

````pine
//@version=6
indicator("ADX Compass [Quantum Algo]", overlay = false, max_labels_count = 200, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  ADX COMPASS
//  The Average Directional Index read as an instrument, not a
//  number. Strength is ranked against the symbol's own history
//  instead of fixed thresholds, trend age is measured against the
//  symbol's typical trend lifespan, directional crosses are
//  filtered by strength, exhaustion is detected as the index
//  turns from its peak, and the whole reading is painted onto the
//  price chart — a strength aura and a directional ribbon — so the
//  compass is readable from the candles.
//
//  Concept credits: the Average Directional Index, Directional
//  Movement and Average True Range by J. Welles Wilder Jr. (1978)
//  · the Wilson score interval by Edwin B. Wilson (1927). The
//  adaptive strength ranking, trend-age model, signal families,
//  per-symbol statistics and all code are original work — no
//  third-party or open-source script code was reused.
// ════════════════════════════════════════════════════════════════

// ─── INPUTS ─────────────────────────────────────────────────────
grpA = "Directional Index"
diLen  = input.int(14, "Directional Length", minval = 2, group = grpA)
adxLen = input.int(14, "Index Smoothing", minval = 2, group = grpA)
adaptive = input.bool(true, "Adaptive Strength Thresholds", group = grpA, tooltip = "Fixed levels like 20 and 25 mean different things on every symbol. Adaptive mode ranks the index against its own recent history: weak below the 30th percentile, strong above the 70th.")
fixedWeak   = input.float(20, "Fixed Weak Level", minval = 5, group = grpA)
fixedStrong = input.float(25, "Fixed Strong Level", minval = 10, group = grpA)
histWin = input.int(300, "Strength History Window (Bars)", minval = 100, maxval = 480, group = grpA)

grpS = "Signals"
showSigs = input.bool(true, "Show Signals On Price", group = grpS)
cooldown = input.int(6, "Signal Cooldown (Bars)", minval = 1, group = grpS)

grpX = "Statistics"
cap     = input.int(300, "Samples Per Family (FIFO Cap)", minval = 50, maxval = 1000, group = grpX)
minN    = input.int(15, "Minimum Samples To Grade", minval = 5, group = grpX)
shrinkK = input.int(10, "Shrinkage Strength", minval = 0, maxval = 100, group = grpX)
zConf   = input.float(1.645, "Wilson z-Score", step = 0.005, group = grpX)

grpV = "Visuals"
bullCol = input.color(#00897b, "Bullish", group = grpV)
bearCol = input.color(#e4002b, "Bearish", group = grpV)
goldCol = input.color(#c77800, "Strength / Accent", group = grpV)
silvCol = input.color(#37474f, "Neutral", group = grpV)
showAura   = input.bool(true, "Strength Aura On Price", group = grpV)
showRibbon = input.bool(true, "Directional Ribbon On Price", group = grpV)
ribbonLen  = input.int(21, "Ribbon Length", minval = 5, group = grpV)

grpD = "Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = grpD)
dashPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpD)
dashSize    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpD)
dashTitleBg = input.color(color.new(#ef9a13, 0), "Title Band", group = grpD)
dashBg      = input.color(color.new(#171207, 8), "Background", group = grpD)
dashFrame   = input.color(color.new(#d99b1e, 15), "Frame", group = grpD)
dashGrid    = input.color(color.new(#d99b1e, 80), "Grid", group = grpD)
dashHeadTxt = input.color(color.new(#1a1207, 0), "Header Text", group = grpD)
dashBodyTxt = input.color(color.new(#eef2f7, 5), "Body Text", group = grpD)
dashMuteTxt = input.color(color.new(#cdb87e, 15), "Muted Text", group = grpD)

// ─── SHARED ─────────────────────────────────────────────────────
f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out
fw(float p) => str.tostring(p * 100, "#") + "%"
f_meter(float x, int slots) =>
    k = math.min(slots, math.max(0, int(x * slots + 0.5)))
    f_rep("▮", k) + f_rep("▭", slots - k)

// ─── WILDER'S DIRECTIONAL SYSTEM ───────────────────────────────
upM = high - high[1]
dnM = low[1] - low
plusDM  = upM > dnM and upM > 0 ? upM : 0.0
minusDM = dnM > upM and dnM > 0 ? dnM : 0.0
trR = ta.rma(ta.tr, diLen)
plusDI  = trR > 0 ? 100 * ta.rma(plusDM, diLen) / trR : 0.0
minusDI = trR > 0 ? 100 * ta.rma(minusDM, diLen) / trR : 0.0
dxV = plusDI + minusDI > 0 ? 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI) : 0.0
adx = ta.rma(dxV, adxLen)
adxSlope = adx - adx[3]
bullDir = plusDI > minusDI

// ─── ADAPTIVE STRENGTH RANKING ─────────────────────────────────
var array<float> aHist = array.new<float>()
if barstate.isconfirmed
    aHist.push(adx)
    if aHist.size() > histWin
        aHist.shift()
adxPct = 50.0
if aHist.size() >= 50
    int below = 0
    for i = 0 to aHist.size() - 1
        if aHist.get(i) < adx
            below += 1
    adxPct := below * 100.0 / aHist.size()
weakTh   = adaptive and aHist.size() >= 50 ? array.percentile_linear_interpolation(aHist, 30) : fixedWeak
strongTh = adaptive and aHist.size() >= 50 ? array.percentile_linear_interpolation(aHist, 70) : fixedStrong
strength = adx >= strongTh ? 2 : adx >= weakTh ? 1 : 0
sName = strength == 2 ? "Strong" : strength == 1 ? "Building" : "Weak"

// ─── TREND AGE vs THIS SYMBOL'S TYPICAL LIFESPAN ───────────────
var int trendStart = na
var array<float> lifeHist = array.new<float>()
trendOn = strength == 2
if barstate.isconfirmed
    if trendOn and not trendOn[1]
        trendStart := bar_index
    if not trendOn and trendOn[1] and not na(trendStart)
        lifeHist.push(bar_index - trendStart)
        if lifeHist.size() > 60
            lifeHist.shift()
avgLife = lifeHist.size() > 0 ? lifeHist.avg() : na
trendAge = trendOn and not na(trendStart) ? bar_index - trendStart : 0
maturity = trendOn and not na(avgLife) and avgLife > 0 ? trendAge / avgLife : na
matName = na(maturity) ? "—" : maturity < 0.5 ? "Early" : maturity < 1.0 ? "Mature" : "Late"

// ─── SIGNAL FAMILIES ───────────────────────────────────────────
var int lastSigBar = -10000
cooled = bar_index - lastSigBar >= cooldown
// T · directional cross with strength present and rising
tBuy  = barstate.isconfirmed and cooled and ta.crossover(plusDI, minusDI) and adx >= weakTh and adxSlope > 0
tSell = barstate.isconfirmed and cooled and ta.crossunder(plusDI, minusDI) and adx >= weakTh and adxSlope > 0
// B · strength ignition: the index breaks from weak into strong
bUp = barstate.isconfirmed and cooled and adx >= strongTh and adx[1] < strongTh and bullDir
bDn = barstate.isconfirmed and cooled and adx >= strongTh and adx[1] < strongTh and not bullDir
// E · exhaustion: the index turns down from a strong peak
eEv = barstate.isconfirmed and cooled and strength == 2 and adx < adx[1] and adx[1] >= adx[2] and adx[1] >= adx[3]
if tBuy or tSell or bUp or bDn or eEv
    lastSigBar := bar_index

// ─── STATISTICS ────────────────────────────────────────────────
var array<float> fT = array.new<float>()
var array<float> fB = array.new<float>()
var array<float> fE = array.new<float>()
pushF(array<float> a, float v) =>
    a.push(v)
    if a.size() > cap
        a.shift()
f_feed(array<float> a, bool cB, bool cS) =>
    if barstate.isconfirmed and bar_index > 10
        if cB[10]
            pushF(a, close / close[10] - 1)
        if cS[10]
            pushF(a, 1 - close / close[10])
f_feed(fT, tBuy, tSell)
f_feed(fB, bUp, bDn)
// exhaustion is graded on whether the trend's momentum actually stalled
if barstate.isconfirmed and bar_index > 10 and eEv[10]
    pushF(fE, (bullDir[10] ? (close[10] - close) : (close - close[10])) / close[10] + 0.0)
statsOf(array<float> a) =>
    int n = a.size()
    float pS_ = 0.5
    float wLB = 0.5
    if n > 0
        int w = 0
        for i = 0 to n - 1
            if a.get(i) > 0
                w += 1
        float pHat = w * 1.0 / n
        pS_ := (pHat * n + 0.5 * shrinkK) / (n + shrinkK)
        wLB := (pHat + zConf * zConf / (2 * n) - zConf * math.sqrt(math.max(pHat * (1 - pHat) / n + zConf * zConf / (4 * n * n), 0.0))) / (1 + zConf * zConf / n)
    [pS_, wLB, n]

// ─── PANE RENDER ───────────────────────────────────────────────
hline(0, "Floor", color = color.new(#37474f, 70))
pW = plot(weakTh, "Weak Threshold", color = color.new(silvCol, 40), style = plot.style_linebr)
pS = plot(strongTh, "Strong Threshold", color = color.new(goldCol, 30), style = plot.style_linebr)
fill(pW, pS, color = color.new(goldCol, 90), title = "Building Zone")
adxCol = strength == 2 ? goldCol : strength == 1 ? color.new(goldCol, 35) : silvCol
plot(adx, "ADX", color = adxCol, linewidth = 3)
plot(plusDI, "+DI", color = color.new(bullCol, 0), linewidth = 2)
plot(minusDI, "-DI", color = color.new(bearCol, 0), linewidth = 2)

// ─── PRICE-CHART CANVAS · aura + ribbon + signals ──────────────
auraT = strength == 2 ? 84 : strength == 1 ? 91 : 97
bgcolor(showAura ? color.new(bullDir ? bullCol : bearCol, auraT) : na, title = "Strength Aura", force_overlay = true)
ribbon = ta.ema(close, ribbonLen)
plot(showRibbon ? ribbon : na, "Directional Ribbon", color = color.new(bullDir ? bullCol : bearCol, strength == 2 ? 0 : strength == 1 ? 35 : 70), linewidth = 3, force_overlay = true)

var array<label> sigLbs = array.new<label>()
f_sig(bool cond, bool isBuy, string ltr, string desc, array<float> fam) =>
    if showSigs and cond
        [p10, w10, n10] = statsOf(fam)
        sigLbs.push(label.new(bar_index, isBuy ? low : high, ltr, style = isBuy ? label.style_label_up : label.style_label_down, color = color.new(ltr == "E" ? goldCol : isBuy ? bullCol : bearCol, 0), textcolor = ltr == "E" ? #231a08 : color.white, size = size.small, tooltip = desc + "\nADX " + str.tostring(adx, "#.#") + " · " + str.tostring(adxPct, "#") + "th percentile · " + sName + (trendOn ? " · age " + str.tostring(trendAge) + " bars" : "") + (n10 >= minN ? "\nFamily record · favorable 10 bars: " + fw(p10) + " · Wilson " + fw(w10) + " · ×" + str.tostring(n10) : "\nCollecting history (" + str.tostring(n10) + "/" + str.tostring(minN) + ")"), force_overlay = true))
        while sigLbs.size() > 30
            label.delete(sigLbs.shift())
f_sig(tBuy, true, "T", "Directional cross up with strength present and rising", fT)
f_sig(tSell, false, "T", "Directional cross down with strength present and rising", fT)
f_sig(bUp, true, "B", "Strength ignition — the index broke into its strong zone, bulls dominant", fB)
f_sig(bDn, false, "B", "Strength ignition — the index broke into its strong zone, bears dominant", fB)
f_sig(eEv, not bullDir, "E", "Exhaustion — the index turned down from a strong peak; the trend is losing force", fE)

// ─── PREMIUM DASHBOARD · three columns, golden title ───────────
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small
var table tb = table.new(dPos, 3, 10, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1, force_overlay = true)
if showDash and barstate.islast
    [pT, wT, nT] = statsOf(fT)
    [pB, wB, nB] = statsOf(fB)
    [pE, wE, nE] = statsOf(fE)
    spread = plusDI - minusDI
    titleSize = dashSize == "Tiny" ? size.small : dashSize == "Small" ? size.normal : dashSize == "Normal" ? size.large : size.huge
    table.cell(tb, 0, 0, "◈ ADX COMPASS · " + syminfo.ticker, bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = titleSize, text_halign = text.align_center)
    table.cell(tb, 1, 0, "", bgcolor = dashTitleBg)
    table.cell(tb, 2, 0, "", bgcolor = dashTitleBg)
    table.merge_cells(tb, 0, 0, 2, 0)
    table.cell(tb, 0, 1, "Compass", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 1, bullDir ? "▲" : "▼", text_color = bullDir ? bullCol : bearCol, text_size = bodySize)
    table.cell(tb, 2, 1, (bullDir ? "Bulls lead by " : "Bears lead by ") + str.tostring(math.abs(spread), "#.#"), text_color = bullDir ? bullCol : bearCol, text_size = bodySize)
    table.cell(tb, 0, 2, "Strength", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 2, f_meter(adxPct / 100, 6), text_color = strength == 2 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 2, sName + " · " + str.tostring(adx, "#.#") + " · " + str.tostring(adxPct, "#") + "th pct", text_color = strength == 2 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 3, "Slope", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 3, adxSlope > 0.5 ? "⇗" : adxSlope < -0.5 ? "⇘" : "→", text_color = adxSlope > 0.5 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 3, adxSlope > 0.5 ? "Strength rising" : adxSlope < -0.5 ? "Strength fading" : "Flat", text_color = adxSlope > 0.5 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 4, "Trend Age", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 4, na(maturity) ? "—" : f_meter(math.min(maturity, 1.0), 6), text_color = matName == "Late" ? bearCol : matName == "Early" ? bullCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 4, trendOn ? str.tostring(trendAge) + " bars · " + matName + (na(avgLife) ? "" : " (avg " + str.tostring(avgLife, "#") + ")") : "No active trend", text_color = matName == "Late" ? bearCol : matName == "Early" ? bullCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 5, "Thresholds", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 5, adaptive ? "◉" : "—", text_color = adaptive ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 5, (adaptive ? "Adaptive · " : "Fixed · ") + str.tostring(weakTh, "#") + " / " + str.tostring(strongTh, "#"), text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 6, "Trend T", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 6, nT >= minN ? f_meter(pT, 6) : "—", text_color = nT >= minN and pT >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 6, nT > 0 ? fw(pT) + " ×" + str.tostring(nT) : "—", text_color = nT >= minN and pT >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 7, "Ignition B", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 7, nB >= minN ? f_meter(pB, 6) : "—", text_color = nB >= minN and pB >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 7, nB > 0 ? fw(pB) + " ×" + str.tostring(nB) : "—", text_color = nB >= minN and pB >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 8, "Exhaustion E", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 8, nE >= minN ? f_meter(pE, 6) : "—", text_color = nE >= minN and pE >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 8, nE > 0 ? fw(pE) + " stalled ×" + str.tostring(nE) : "—", text_color = nE >= minN and pE >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 9, "Shrunk rates · this chart only", text_color = dashMuteTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 9, "", text_size = size.tiny)
    table.cell(tb, 2, 9, "", text_size = size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────
alertcondition(tBuy or tSell, "Directional Cross", "The directional lines crossed with strength present and rising.")
alertcondition(bUp or bDn, "Strength Ignition", "The index broke into its strong zone.")
alertcondition(eEv, "Trend Exhaustion", "The index turned down from a strong peak.")
alertcondition(strength == 2 and strength[1] < 2, "Strong Trend Began", "Adaptive strength entered the strong zone.")
````
