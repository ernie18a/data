# Market Bottom Finder [Quantum Algo]

- url: https://www.tradingview.com/script/7uvXwlnx-Market-Bottom-Finder-Quantum-Algo/
- type: indicator
- pine_id: PUB;c5b28b6798934344bd9342b216606a67
- version: 1.0

## Description

Market Bottom Finder [Quantum Algo]

═══════════════════════════════════════════════

🔶 OVERVIEW

Market Bottom Finder is a capitulation detector. It watches for the moment panic selling exhausts itself — the fear spike, the final violent flush, the volume climax, the long rejection wick — and marks that bar as a graded bottom candidate directly on your chart.

The engine is built on the Williams Vix Fix, the classic synthetic fear gauge, and extends it with four additional independent witnesses: an accumulated-stretch pressure integral, momentum-exhaustion analysis, a volume climax filter, and oscillator divergence. The more witnesses agree, the higher the grade — and a five-witness alignment prints as a gold Capitulation marker.

What makes this tool different from every other bottom indicator is accountability: every marker SETTLES. A fixed number of bars after it prints, each marker is recolored by what actually happened — solid if price held above the detected low, faded if it failed. Your chart displays the tool's genuine historical hit rate at all times. No hindsight highlight reel is possible, because the failures stay visible.

═══════════════════════════════════════════════

🔶 WHAT IS A MARKET BOTTOM?

A durable market bottom is rarely a quiet event. It is usually a capitulation: the point where fearful holders finally surrender, selling accelerates into a climax, and the supply of panic sellers runs out. The signature is consistent across markets and decades — a spike in the fear gauge, unusually fast downward movement that suddenly decelerates, climactic volume, and a candle that dives deep and closes far off its low.

This indicator formalizes that signature into measurable conditions and requires several of them to align at once.

═══════════════════════════════════════════════

🔶 WHAT IS THE WILLIAMS VIX FIX?

The Vix Fix, created by Larry Williams, synthesizes a volatility-index-style fear reading from price alone: it measures how far the current low has fallen from the highest close of the recent window. When that distance expands violently, fear is spiking — on any symbol, including those with no options market and no published volatility index.

This script extends the classic gauge with an adaptive threshold: a spike is defined as the gauge exceeding a high percentile of its own recent history, so the definition of "extreme fear" recalibrates automatically to every symbol, timeframe and volatility regime.

═══════════════════════════════════════════════

🔶 WHY IS THIS ORIGINAL?

1. Adaptive fear threshold. Fixed trigger levels fail across symbols; this gauge defines extremity from the symbol's own distribution.

2. Snapback Pressure. An accumulated-stretch integral, inspired by the action-integral form used in physics as a modeling device: the longer and deeper price stays extended below its long-term average, the more the pressure charges toward one hundred percent. A single red candle barely moves it; sustained capitulation charges it fully. Bottoms require charged pressure — depth AND duration, not depth alone.

3. Witness grading. Fear extremity, volume climax, wick rejection, oscillator divergence and high pressure are counted as independent witnesses. Grades are shown as diamonds on every marker; five or more prints a gold Capitulation.

4. Settling markers. Every marker resolves into its real outcome after a fixed window, in public, on the chart. The tool grades its own homework.

5. Two-horizon statistics. The dashboard reports how often detected bottoms held after ten and after thirty bars — computed on your exact chart, shrunk toward neutral at small samples, with Wilson lower bounds available. Each new marker's tooltip quotes the historical hold rate at the moment it prints.

═══════════════════════════════════════════════

🔶 HOW IT WORKS

— The fear gauge is computed each bar and compared against its adaptive percentile threshold; spikes paint a translucent fear wash on the chart.
— Downward momentum is measured in Average True Range units; a bottom requires a genuinely violent arrival that has begun decelerating.
— The pressure integral accumulates while price is stretched below its long-term average and decays quickly once it re-enters.
— When a fear spike, exhausted momentum and charged pressure coincide, a bottom candidate prints and is graded by the remaining witnesses.
— After the settle window, the marker is recolored by outcome, and the ten- and thirty-bar results feed the statistics panel.

All detection happens on confirmed bars. Markers do not repaint; a settled marker never changes again.

═══════════════════════════════════════════════

🔶 HOW TO USE IT

— As a context tool: the fear wash and pressure row tell you when conditions for a durable low are building, before any marker prints.
— As a confirmation layer: combine a Capitulation marker with your own support levels, volume profile or higher-timeframe structure rather than acting on it in isolation.
— Grade discipline: the gold five-plus-witness Capitulations are historically the events worth the most attention; single-diamond bottoms are early warnings, not conclusions.
— Read your chart's own statistics first: the Held rows tell you how this exact symbol and timeframe has responded historically.
— Works on all markets — crypto, stocks, indices, forex — on timeframes from 1H to Weekly. Mirror top detection is available as an optional toggle.

═══════════════════════════════════════════════

🔶 SETTINGS

— Fear Gauge: lookback, adaptive threshold window and percentile, chart wash toggle.
— Bottom Detection: minimum momentum, minimum pressure, volume climax level, cooldown, settle window, markers kept, optional top mirror.
— Statistics: sample cap, minimum samples, shrinkage strength, Wilson z-score.
— Full color and dashboard customization.

═══════════════════════════════════════════════

🔶 ALERTS

— Fear Spike — the gauge crossed its adaptive threshold.
— Bottom Detected — fear, exhaustion and charged pressure aligned.
— Capitulation (Grade A) — five or more witnesses aligned.
— Top Detected — mirror logic, when enabled.

═══════════════════════════════════════════════

🔶 FAQ

Q: Does it repaint?
A: No. Detection uses confirmed bars only, and settled markers are permanent. The settling recolor is the tool honestly reporting an outcome, not a signal changing.

Q: Does it catch every bottom?
A: No, and it is not designed to. It detects capitulation-style bottoms — the panic-flush signature. Slow, quiet rounded bottoms without a fear spike will not qualify. Requiring the full signature is what keeps the marker meaningful.

Q: Why did a marker print and price still went lower?
A: Because no bottom detector is right every time — and this is the only one that shows you exactly how often it is right, on your chart, via the settled markers and the Held statistics. Capitulation events historically cluster near durable lows; they do not guarantee them.

Q: What do the Held percentages mean?
A: The share of past detected bottoms after which price was higher ten and thirty bars later, on the current symbol and timeframe. Small samples are shrunk toward fifty percent so early numbers cannot overstate the edge. They describe history; they are not predictions.

Q: Which settings should I change first?
A: The Fear Spike Percentile (higher = rarer, stronger events) and the Minimum Snapback Pressure (higher = demands more sustained capitulation).

═══════════════════════════════════════════════

🔶 CREDITS

The Vix Fix synthetic fear gauge is by Larry Williams. The Relative Strength Index and Average True Range are by J. Welles Wilder Jr. (1978). The pressure integral follows the action-integral form of Wentzel, Kramers and Brillouin (1926), used strictly as a modeling device. The Wilson score interval is by Edwin B. Wilson (1927). The adaptive threshold, witness grading engine, settling audit, per-symbol statistics and all code in this script are original work — no third-party or open-source script code was reused.

═══════════════════════════════════════════════

🔶 LIMITATIONS

— Capitulation detection identifies panic exhaustion; it cannot identify news-driven regime changes or slow structural declines.
— Statistics describe the current chart's history only; past frequencies never guarantee future outcomes.
— On illiquid symbols, volume-based witnesses are less reliable.

═══════════════════════════════════════════════

🔶 DISCLAIMER

This indicator is a research and charting tool provided for educational purposes. It is not financial advice, and nothing it displays is a recommendation to buy or sell any asset. Trading involves substantial risk of loss. Always do your own analysis and manage risk responsibly.

## Source Code

````pine
//@version=6
indicator("Market Bottom Finder [Quantum Algo]", overlay = true, max_labels_count = 200, max_lines_count = 60, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  MARKET BOTTOM FINDER
//  A capitulation detector built on the Williams Vix Fix fear
//  gauge, extended with an accumulated-stretch pressure integral,
//  momentum-exhaustion analysis, volume climax, wick rejection
//  and oscillator divergence. Every detected bottom is graded by
//  how many independent witnesses agree — and every marker
//  SETTLES into its real outcome after a fixed number of bars,
//  so the chart shows the tool's honest hit rate, not a
//  hindsight highlight reel.
//
//  Concept credits: the Vix Fix synthetic fear gauge by Larry
//  Williams · Relative Strength Index and Average True Range by
//  J. Welles Wilder Jr. (1978) · the pressure integral follows
//  the WKB action-integral form (Wentzel, Kramers, Brillouin,
//  1926) strictly as a modeling device · the Wilson score
//  interval by Edwin B. Wilson (1927). The grading engine,
//  pressure gauge, settling audit, per-symbol statistics and all
//  code are original work — no third-party or open-source script
//  code was reused.
// ════════════════════════════════════════════════════════════════

// ─── INPUTS ─────────────────────────────────────────────────────
grpF = "Fear Gauge"
wvfLen = input.int(22, "Fear Lookback", minval = 5, group = grpF)
thLen  = input.int(300, "Adaptive Threshold Window (Bars)", minval = 50, maxval = 480, group = grpF)
thPct  = input.int(90, "Fear Spike Percentile", minval = 70, maxval = 99, group = grpF, tooltip = "Fear counts as a spike when the gauge exceeds this percentile of its own recent history — the threshold adapts to every symbol and regime instead of using a fixed number.")
showFearBg = input.bool(true, "Paint Fear On The Chart", group = grpF)

grpB = "Bottom Detection"
extMom  = input.float(1.5, "Minimum Downward Momentum (Average True Range)", step = 0.25, minval = 0.5, group = grpB)
minPress = input.float(0.45, "Minimum Snapback Pressure", step = 0.05, minval = 0.1, maxval = 0.95, group = grpB, tooltip = "An accumulated-stretch integral: the longer and deeper price stays extended below its long-term average, the higher the pressure charges. Sustained capitulation raises it toward one; a single red candle barely moves it.")
extVolZ = input.float(1.5, "Volume Climax (z-score)", step = 0.25, group = grpB)
cooldown = input.int(8, "Cooldown (Bars)", minval = 2, group = grpB)
settleN = input.int(15, "Marker Settles After (Bars)", minval = 5, maxval = 60, group = grpB)
keepExt = input.int(14, "Markers To Keep", minval = 4, maxval = 40, group = grpB)
alsoTops = input.bool(false, "Also Detect Tops (Mirror Logic)", group = grpB)

grpX = "Statistics"
cap     = input.int(300, "Samples (FIFO Cap)", minval = 50, maxval = 1000, group = grpX)
minN    = input.int(15, "Minimum Samples To Grade", minval = 5, group = grpX)
shrinkK = input.int(10, "Shrinkage Strength", minval = 0, maxval = 100, group = grpX)
zConf   = input.float(1.645, "Wilson z-Score", step = 0.005, group = grpX)

grpV = "Visuals"
bullCol = input.color(#00a89d, "Bottom", group = grpV)
bearCol = input.color(#e8365f, "Fear / Top", group = grpV)
goldCol = input.color(#d99b1e, "Capitulation", group = grpV)
silvCol = input.color(#5c6b80, "Neutral", group = grpV)

grpD = "Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = grpD)
dashPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpD)
dashSize    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpD)
dashTitleBg = input.color(color.new(#231a08, 0), "Title Band", group = grpD)
dashBg      = input.color(color.new(#171207, 8), "Background", group = grpD)
dashFrame   = input.color(color.new(#d99b1e, 15), "Frame", group = grpD)
dashGrid    = input.color(color.new(#d99b1e, 80), "Grid", group = grpD)
dashHeadTxt = input.color(color.new(#f0c05a, 0), "Header Text", group = grpD)
dashBodyTxt = input.color(color.new(#eef2f7, 5), "Body Text", group = grpD)
dashMuteTxt = input.color(color.new(#cdb87e, 15), "Muted Text", group = grpD)

// ─── SHARED ─────────────────────────────────────────────────────
atrV = ta.atr(14)
rsiV = ta.rsi(close, 14)
volSd = ta.stdev(volume, 50)
volZ = na(volSd) or volSd == 0 ? 0.0 : (volume - ta.sma(volume, 50)) / volSd

f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out
fw(float p) => str.tostring(p * 100, "#") + "%"

// ─── FEAR GAUGE · Williams Vix Fix with adaptive threshold ─────
hiC = ta.highest(close, wvfLen)
wvf = hiC > 0 ? (hiC - low) / hiC * 100 : 0.0
var array<float> wvfHist = array.new<float>()
if barstate.isconfirmed
    wvfHist.push(wvf)
    if wvfHist.size() > thLen
        wvfHist.shift()
fearTh = wvfHist.size() >= 50 ? array.percentile_linear_interpolation(wvfHist, thPct) : na
fearHot = not na(fearTh) and wvf >= fearTh
fearX   = not na(fearTh) and wvf >= fearTh * 1.15
// mirror gauge for tops: greed = rally off the lowest close
loC = ta.lowest(close, wvfLen)
gvf = loC > 0 ? (high - loC) / loC * 100 : 0.0
var array<float> gvfHist = array.new<float>()
if barstate.isconfirmed and alsoTops
    gvfHist.push(gvf)
    if gvfHist.size() > thLen
        gvfHist.shift()
greedTh = alsoTops and gvfHist.size() >= 50 ? array.percentile_linear_interpolation(gvfHist, thPct) : na
greedHot = not na(greedTh) and gvf >= greedTh

bgcolor(showFearBg and fearHot ? color.new(bearCol, fearX ? 82 : 90) : showFearBg and greedHot ? color.new(goldCol, 92) : na, title = "Fear Wash")

// ─── SNAPBACK PRESSURE · accumulated stretch integral ──────────
baseMA = ta.sma(close, 200)
xD = (close - baseMA) / atrV
var float sNeg = 0.0
var float sPos = 0.0
sNeg := xD < -1.0 ? sNeg + (-xD - 1.0) : sNeg * 0.6
sPos := xD > 1.0 ? sPos + (xD - 1.0) : sPos * 0.6
pressUp = 1.0 - math.exp(-sNeg / 6.0)
pressDn = 1.0 - math.exp(-sPos / 6.0)

// ─── DIVERGENCE MEMORY ─────────────────────────────────────────
dvL = ta.pivotlow(low, 3, 3)
dvH = ta.pivothigh(high, 3, 3)
var float dvLoPx = na
var float dvLoRsi = na
var float dvHiPx = na
var float dvHiRsi = na
bool bullDiv = false
bool bearDiv = false
if not na(dvL)
    if not na(dvLoPx) and dvL < dvLoPx and rsiV[3] > dvLoRsi
        bullDiv := true
    dvLoPx := dvL
    dvLoRsi := rsiV[3]
if not na(dvH)
    if not na(dvHiPx) and dvH > dvHiPx and rsiV[3] < dvHiRsi
        bearDiv := true
    dvHiPx := dvH
    dvHiRsi := rsiV[3]
divRecentB = ta.barssince(bullDiv) <= 5
divRecentS = ta.barssince(bearDiv) <= 5

// ─── BOTTOM ENGINE ─────────────────────────────────────────────
m5 = (close - close[5]) / atrV
arrivedDn = ta.lowest(m5, 3) <= -extMom
arrivedUp = ta.highest(m5, 3) >= extMom
climaxZ = ta.highest(volZ, 5)
wickLo = (high - low) > 0 and (math.min(close, open) - low) >= (high - low) * 0.4
wickHi = (high - low) > 0 and (high - math.max(close, open)) >= (high - low) * 0.4
fearRecent = fearHot or fearHot[1] or fearHot[2]
var int lastExtBar = -10000
extCooled = bar_index - lastExtBar >= cooldown
bottomEv = barstate.isconfirmed and extCooled and fearRecent and arrivedDn and m5 > m5[1] and pressUp >= minPress
topEv    = barstate.isconfirmed and alsoTops and extCooled and greedHot and arrivedUp and m5 < m5[1] and pressDn >= minPress
int gradeN = 0
if bottomEv or topEv
    lastExtBar := bar_index
    gradeN := 1 + ((bottomEv ? fearX : gvf >= nz(greedTh) * 1.15) ? 1 : 0) + (climaxZ >= extVolZ ? 1 : 0) + ((bottomEv ? wickLo : wickHi) ? 1 : 0) + ((bottomEv ? divRecentB : divRecentS) ? 1 : 0) + ((bottomEv ? pressUp : pressDn) >= 0.65 ? 1 : 0)
isCapit = gradeN >= 5

// ─── STATISTICS · two horizons ─────────────────────────────────
var array<float> h10 = array.new<float>()
var array<float> h30 = array.new<float>()
pushF(array<float> a, float v) =>
    a.push(v)
    if a.size() > cap
        a.shift()
if barstate.isconfirmed and bar_index > 30
    if bottomEv[10]
        pushF(h10, close / close[10] - 1)
    if bottomEv[30]
        pushF(h30, close / close[30] - 1)
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

// ─── MARKERS THAT SETTLE INTO THEIR OUTCOME ────────────────────
var array<label> exDone = array.new<label>()
var array<label> exPend = array.new<label>()
var array<int>   exBar  = array.new<int>()
var array<int>   exDir  = array.new<int>()
var array<float> exPx   = array.new<float>()
if bottomEv or topEv
    [p10s, w10s, n10s] = statsOf(h10)
    exl = label.new(bar_index, bottomEv ? low : high, (isCapit ? "★ Capitulation " : "◈ ") + (bottomEv ? "Bottom " : "Top ") + f_rep("◆", math.min(6, gradeN)), style = bottomEv ? label.style_label_up : label.style_label_down, color = color.new(isCapit ? goldCol : bottomEv ? bullCol : bearCol, 5), textcolor = bottomEv ? #06222b : #2b0612, size = size.small, tooltip = (bottomEv ? "Capitulation candidate — fear spike, downward exhaustion, charged snapback pressure" : "Exhaustion candidate above — mirror logic") + "\nFear " + str.tostring(wvf, "#.#") + " vs threshold " + str.tostring(nz(fearTh), "#.#") + " · Pressure " + fw(bottomEv ? pressUp : pressDn) + "\nMomentum " + str.tostring(m5, "#.#") + " ATR · Climax z " + str.tostring(climaxZ, "#.#") + (n10s >= minN ? "\nHistorical " + str.tostring(10) + "-bar hold rate here: " + fw(p10s) + " ×" + str.tostring(n10s) : "") + "\nMarker settles into its outcome after " + str.tostring(settleN) + " bars")
    exPend.push(exl)
    exBar.push(bar_index)
    exDir.push(bottomEv ? 1 : -1)
    exPx.push(close)
if barstate.isconfirmed and exPend.size() > 0
    while exPend.size() > 0 and bar_index - exBar.get(0) >= settleN
        exl = exPend.shift()
        exBar.shift()
        xd = exDir.shift()
        xp = exPx.shift()
        xr = (close / xp - 1) * xd
        if xr > 0
            label.set_color(exl, color.new(xd == 1 ? bullCol : bearCol, 0))
            label.set_textcolor(exl, xd == 1 ? #06222b : #ffffff)
        else
            label.set_color(exl, color.new(silvCol, 45))
            label.set_textcolor(exl, color.new(#eef2f7, 15))
        exDone.push(exl)
        while exDone.size() > keepExt
            label.delete(exDone.shift())

// ─── DASHBOARD ─────────────────────────────────────────────────
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small
var table tb = table.new(dPos, 2, 8, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1)
if showDash and barstate.islast
    [p10, w10, n10] = statsOf(h10)
    [p30, w30, n30] = statsOf(h30)
    fearRatio = not na(fearTh) and fearTh > 0 ? wvf / fearTh : 0.0
    fMag = math.min(5, int(fearRatio * 3.4))
    table.cell(tb, 0, 0, "◈ MARKET BOTTOM FINDER", bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 0, syminfo.ticker, bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = bodySize)
    table.cell(tb, 0, 1, "Fear Gauge", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 1, (fearHot ? (fearX ? "EXTREME " : "Spiking ") : "Calm ") + f_rep("▮", math.max(fMag, 0)), text_color = fearHot ? bearCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 2, "Snapback Pressure", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 2, pressUp < 0.1 ? "Relaxed" : "Charging ▲ " + fw(pressUp), text_color = pressUp >= minPress ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 3, "Momentum", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 3, str.tostring(m5, "#.#") + " ATR · " + (m5 > m5[1] ? "decelerating" : "accelerating"), text_color = m5 < 0 ? bearCol : bullCol, text_size = bodySize)
    table.cell(tb, 0, 4, "Last Bottom", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 4, lastExtBar > -10000 ? str.tostring(bar_index - lastExtBar) + " bars ago" : "—", text_color = bar_index - lastExtBar <= 5 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 5, "Held 10 Bars", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 5, n10 > 0 ? fw(p10) + " ×" + str.tostring(n10) : "—", text_color = n10 >= minN and p10 >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 6, "Held 30 Bars", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 6, n30 > 0 ? fw(p30) + " ×" + str.tostring(n30) : "—", text_color = n30 >= minN and p30 >= 0.55 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 7, "Shrunk hold rates · this chart only", text_color = dashMuteTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 7, "", text_size = size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────
alertcondition(fearHot and not fearHot[1], "Fear Spike", "The fear gauge crossed its adaptive spike threshold.")
alertcondition(bottomEv, "Bottom Detected", "Fear, exhaustion and charged pressure aligned — a bottom candidate printed.")
alertcondition(bottomEv and isCapit, "Capitulation (Grade A)", "Five or more witnesses aligned — a capitulation-grade bottom printed.")
alertcondition(topEv, "Top Detected", "Mirror exhaustion above — a top candidate printed.")
````
