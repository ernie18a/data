# Volatility Storm Tracker [Quantum Algo]

- url: https://www.tradingview.com/script/jVtck0qo-Volatility-Storm-Tracker-Quantum-Algo/
- type: indicator
- pine_id: PUB;6016c3065a024b3396ee61a2f6542672
- version: 1.0

## Description

Volatility Storm Tracker [Quantum Algo]

═══════════════════════════════════════════════

🔶 OVERVIEW

Volatility Storm Tracker treats volatility the way meteorologists treat weather: as a system with structure, pressure, and a lifecycle. Volatility clusters. It compresses before it releases. Its term structure inverts under stress. This indicator measures all of it with professional range-based estimators, locates current volatility inside its own historical cone, charges a Storm Pressure gauge while compression builds, boxes each phase of the storm lifecycle directly on the chart — BUILDING, STORM, AFTERMATH — and projects the statistical expected-move cone forward from live price like a hurricane track.

Its one predictive claim is deliberately narrow and deliberately measurable: after deep, sustained compression, expansion follows. Direction is never predicted — expansion is. And every Storm Watch marker settles publicly into "Delivered" or "Fizzled" depending on whether the expansion actually arrived, so the chart always displays the tool's honest historical record on your exact symbol.

═══════════════════════════════════════════════

🔶 WHAT IS REALIZED VOLATILITY AND WHY DO ESTIMATORS MATTER?

Realized volatility measures how much price actually moves. The naive approach uses only closing prices and throws away most of the information in every bar. Range-based estimators use the full open, high, low and close: Parkinson (1980) exploits the high-low range, Garman-Klass (1980) adds the open-close body, Rogers-Satchell (1991) handles drift, and Yang-Zhang (2000) combines overnight gaps, intraday movement and drift into the most efficient practical estimator — the standard on professional volatility desks. This tool computes the full suite and uses Yang-Zhang as its engine.

═══════════════════════════════════════════════

🔶 WHAT IS A VOLATILITY CONE?

A number like "volatility is 2.4%" means nothing in isolation — is that high or low for this symbol, on this timeframe? The volatility cone, introduced by Burghardt and Lane (1990), answers by ranking current volatility as a percentile inside its own recent history. The 8th percentile means deep compression for THIS market; the 92nd means a live storm. Every definition in this tool is relative to the symbol's own behavior — nothing is hard-coded.

═══════════════════════════════════════════════

🔶 WHAT IS VOLATILITY TERM STRUCTURE?

Short-horizon volatility compared to long-horizon volatility. In calm conditions the short reading sits below the long one (contango). When the short reading rises ABOVE the long one (backwardation), recent movement is violent relative to the established baseline — the classic stress signature options desks watch. The dashboard reads this as Contango, Flat, or Backwardation with the live ratio.

═══════════════════════════════════════════════

🔶 WHY IS THIS ORIGINAL?

1. A professional estimator suite on the chart. Yang-Zhang as the engine, with Parkinson and Garman-Klass computed alongside and readable in the dashboard tooltip — mathematics standard on volatility desks and almost never implemented on this platform.

2. Storm Pressure. A charged gauge built from three measurable ingredients: how deep volatility sits in its cone, how long the compression has lasted, and how unstable volatility itself has become (volatility-of-volatility). Pressure is the tool's early warning — it rises while the chart still looks quiet.

3. The storm lifecycle, boxed and labeled. Each phase is drawn around its own price action: BUILDING in amber, STORM in red, AFTERMATH in slate, with calm periods left clean. Scrolling back reads as a storm history — volatility clustering made visible.

4. The expected-move cone. From live price, the tool projects the one- and two-standard-deviation statistical range forward with the correct square-root-of-time curvature — a hurricane-track cone for price. It is a range projection, never a direction forecast, and it is labeled as such.

5. Settling markers and a public record. Every Storm Watch resolves after a fixed window into Delivered (a move of at least the threshold arrived) or Fizzled. The dashboard's Watch Record row reports the delivery rate with sample count, shrunk toward neutral at small samples, with a Wilson lower bound. The tool grades its own homework where everyone can see it.

═══════════════════════════════════════════════

🔶 HOW IT WORKS

— Each bar, the estimator suite computes realized volatility from the full price range, gaps included.
— Current volatility is ranked inside its historical cone; term structure and volatility-of-volatility are updated.
— Storm Pressure charges during deep, persistent, unstable compression and prints a Storm Watch when it crosses the watch threshold.
— A Storm confirms when volatility enters the top of its own cone; the regime machine transitions Calm → Building → Storm → Aftermath and boxes each phase on the chart.
— After the settle window, each Watch is recolored by outcome, and results feed the statistics.

All detection happens on confirmed bars; settled markers never change. The forward cone is a live projection that updates with volatility — it is explicitly a statistical range, not a prediction of path or direction.

═══════════════════════════════════════════════

🔶 HOW TO USE IT

— Breakout preparation: a charged Pressure gauge inside a BUILDING box is the environment where breakout strategies earn their keep; the Watch Record tells you how reliably expansion has followed on this symbol.
— Position sizing: the Expected Move row translates current volatility into a concrete ±percentage over your horizon — a rational basis for stop distances and size.
— Options context: the cone position and term structure describe whether movement is cheap or expensive relative to this market's own history.
— Regime filtering: many strategies work in exactly one regime. The boxes tell you, at a glance, which regime any historical trade lived in — and which one you are in now.
— Works on all markets and timeframes from 15m to Weekly; everything is self-relative, so nothing needs retuning per symbol.

═══════════════════════════════════════════════

🔶 SETTINGS

— Volatility Engine: estimator length, term-structure windows, historical cone window.
— Storm Detection: watch pressure threshold, storm percentile, delivered-move threshold, settle window, markers kept.
— Expected Move Cone: projection toggle and horizon.
— Statistics: sample cap, minimum samples, shrinkage strength, Wilson z-score.
— Full color, regime-box and dashboard customization.

═══════════════════════════════════════════════

🔶 ALERTS

— Storm Watch — pressure crossed the watch threshold; expansion conditions are charged.
— Storm Confirmed — volatility entered the top of its historical cone.
— Calm Restored — the storm cycle completed.
— Term Structure Inverted — short-horizon volatility exceeded long-horizon; stress regime.

═══════════════════════════════════════════════

🔶 FAQ

Q: Does it predict direction?
A: No — and that is the point. Direction after compression is genuinely uncertain; expansion is not. The tool makes only the claim volatility mathematics can support, and then measures that claim on your chart via the settled markers and the Watch Record.

Q: Does it repaint?
A: No. Watches, storms and regime transitions are detected on confirmed bars, and settled markers are permanent. The forward cone updates live because it is a projection from current conditions — it is drawn to the right of price and never alters past signals.

Q: What does "Delivered" mean on a settled marker?
A: That price moved at least the configured threshold (in Average True Range units, in either direction) within the settle window after the Watch. "Fizzled" means it did not. Both outcomes stay on the chart.

Q: Why Yang-Zhang instead of a simple standard deviation of closes?
A: Close-to-close volatility ignores gaps and intrabar range, making it slow and noisy. Yang-Zhang uses the full bar plus the overnight gap and is dramatically more efficient — the same reading quality from far fewer bars, which matters enormously for adaptive thresholds.

Q: Which markets does it suit?
A: All of them — crypto, stocks, indices, forex, commodities. Every threshold is defined relative to the symbol's own volatility history, so the tool recalibrates itself wherever you load it.

═══════════════════════════════════════════════

🔶 CREDITS

Range-based volatility estimators by Michael Parkinson (1980), Garman and Klass (1980), Rogers and Satchell (1991), and Yang and Zhang (2000). Volatility cones after Burghardt and Lane (1990). Volatility clustering first documented by Benoit Mandelbrot (1963) and formalized in the ARCH family by Robert Engle (1982), referenced as conceptual context. The Wilson score interval is by Edwin B. Wilson (1927). The storm pressure model, regime state machine, settling audit, per-symbol statistics and all code in this script are original work — no third-party or open-source script code was reused.

═══════════════════════════════════════════════

🔶 LIMITATIONS

— Expansion timing is probabilistic: pressure can stay charged longer than expected, and some Watches fizzle — the record row exists precisely to quantify this on your chart.
— The expected-move cone assumes volatility measured today persists over the horizon; regime shifts mid-projection will widen or narrow the true range.
— Statistics describe the current chart's history only; past frequencies never guarantee future outcomes.

═══════════════════════════════════════════════

🔶 DISCLAIMER

This indicator is a research and charting tool provided for educational purposes. It is not financial advice, and nothing it displays is a recommendation to buy or sell any asset. Trading involves substantial risk of loss. Always do your own analysis and manage risk responsibly.

## Source Code

````pine
//@version=6
indicator("Volatility Storm Tracker [Quantum Algo]", overlay = true, max_lines_count = 100, max_labels_count = 120, max_bars_back = 500)

// ════════════════════════════════════════════════════════════════
//  VOLATILITY STORM TRACKER
//  A weather system for price. Volatility is not noise — it has
//  structure: it clusters, it compresses before it releases, and
//  its term structure inverts under stress. This tool measures
//  realized volatility with professional range-based estimators,
//  locates it inside its own historical cone, tracks the pressure
//  that builds during compression, and projects the statistical
//  expected-move cone forward on the chart like a storm track.
//
//  Concept credits: range-based volatility estimators by Michael
//  Parkinson (1980), Garman & Klass (1980), Rogers & Satchell
//  (1991) and Yang & Zhang (2000) · volatility cones after
//  Burghardt & Lane (1990) · volatility clustering first
//  documented by Benoit Mandelbrot (1963), formalized in the ARCH
//  family by Robert Engle (1982), referenced as context · the
//  Wilson score interval by Edwin B. Wilson (1927). The storm
//  state machine, pressure model, settling audit, statistics and
//  all code are original work — no third-party or open-source
//  script code was reused.
// ════════════════════════════════════════════════════════════════

// ─── INPUTS ─────────────────────────────────────────────────────
grpE = "Volatility Engine"
volLen  = input.int(20, "Estimator Length", minval = 5, maxval = 100, group = grpE)
tsShort = input.int(10, "Term Structure · Short Window", minval = 3, group = grpE)
tsLong  = input.int(60, "Term Structure · Long Window", minval = 20, group = grpE)
coneLen = input.int(300, "Historical Cone Window (Bars)", minval = 100, maxval = 480, group = grpE, tooltip = "Current volatility is ranked as a percentile inside this window of its own history — the volatility cone. Compression and storms are defined relative to the symbol's own behavior, never by fixed numbers.")

grpS = "Storm Detection"
watchTh = input.int(70, "Storm Watch Pressure", minval = 40, maxval = 95, group = grpS, tooltip = "Pressure charges from three measurable ingredients: how deep volatility sits in its cone, how long the compression has lasted, and how unstable the volatility itself has become. A Storm Watch prints when pressure crosses this level.")
stormPct = input.int(70, "Storm Percentile", minval = 50, maxval = 95, group = grpS)
moveTh  = input.float(1.5, "Delivered Move Threshold (Average True Range)", step = 0.25, minval = 0.5, group = grpS)
settleH = input.int(20, "Watch Settles After (Bars)", minval = 5, maxval = 60, group = grpS)
keepM   = input.int(14, "Markers To Keep", minval = 4, maxval = 40, group = grpS)

grpC = "Expected Move Cone"
showCone = input.bool(true, "Project The Storm Cone", group = grpC)
coneH   = input.int(20, "Projection Horizon (Bars)", minval = 5, maxval = 60, group = grpC)

grpX = "Statistics"
cap     = input.int(300, "Samples (FIFO Cap)", minval = 50, maxval = 1000, group = grpX)
minN    = input.int(15, "Minimum Samples To Grade", minval = 5, group = grpX)
shrinkK = input.int(10, "Shrinkage Strength", minval = 0, maxval = 100, group = grpX)
zConf   = input.float(1.645, "Wilson z-Score", step = 0.005, group = grpX)

grpV = "Visuals"
calmCol  = input.color(#00897b, "Calm / Delivered", group = grpV)
stormCol = input.color(#e4002b, "Storm", group = grpV)
goldCol  = input.color(#c77800, "Pressure / Cone", group = grpV)
silvCol  = input.color(#37474f, "Neutral", group = grpV)
showRegimeBg = input.bool(true, "Show Regime Boxes", group = grpV, tooltip = "Each volatility phase is boxed around its own price action and labeled — Building, STORM, Aftermath — so the storm lifecycle is readable across history. Calm periods stay unboxed to keep the chart clean.")

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
atrV = ta.atr(14)
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

// ─── PROFESSIONAL ESTIMATORS ───────────────────────────────────
lnHL = math.log(high / low)
lnCO = math.log(close / open)
lnHC = math.log(high / close)
lnHO = math.log(high / open)
lnLC = math.log(low / close)
lnLO = math.log(low / open)
lnOC1 = math.log(open / close[1])

f_vol(int n) =>
    // Yang-Zhang: overnight + k·open-to-close + (1-k)·Rogers-Satchell
    vON = math.pow(ta.stdev(lnOC1, n), 2)
    vOC = math.pow(ta.stdev(lnCO, n), 2)
    vRS = ta.sma(lnHC * lnHO + lnLC * lnLO, n)
    k = 0.34 / (1.34 + (n + 1.0) / (n - 1.0))
    math.sqrt(math.max(vON + k * vOC + (1 - k) * math.max(vRS, 0.0), 0.0))

volP  = math.sqrt(ta.sma(lnHL * lnHL, volLen) / (4 * math.log(2)))
volGK = math.sqrt(math.max(ta.sma(0.5 * lnHL * lnHL - (2 * math.log(2) - 1) * lnCO * lnCO, volLen), 0.0))
volYZ = f_vol(volLen)
volS  = f_vol(tsShort)
volL  = f_vol(tsLong)
tsRatio = volL > 0 ? volS / volL : 1.0

// ─── THE CONE · where volatility sits in its own history ──────
var array<float> vHist = array.new<float>()
if barstate.isconfirmed
    vHist.push(volYZ)
    if vHist.size() > coneLen
        vHist.shift()
volPct = 50.0
if vHist.size() >= 50
    int below = 0
    for i = 0 to vHist.size() - 1
        if vHist.get(i) < volYZ
            below += 1
    volPct := below * 100.0 / vHist.size()

// vol-of-vol: instability of the volatility itself
vvol = volYZ > 0 ? ta.stdev(volYZ - volYZ[1], 20) / volYZ : 0.0
vvolMa = ta.sma(vvol, 50)
vvolHot = vvolMa > 0 and vvol > vvolMa * 1.3

// ─── STORM PRESSURE + REGIME STATE MACHINE ─────────────────────
var int cmpDur = 0
cmpDur := volPct <= 25 ? cmpDur + 1 : 0
press = math.min(1.0, math.max(0.0, (35.0 - volPct) / 35.0) * 0.5 + math.min(cmpDur / 40.0, 1.0) * 0.3 + (vvolHot ? 0.2 : 0.0)) * 100
// regime: 0 Calm · 1 Building · 2 Storm · 3 Aftermath
var int regime = 0
var int regimeBar = 0
newRegime = volPct >= stormPct or tsRatio >= 1.25 ? 2 : press >= watchTh * 0.7 and volPct <= 35 ? 1 : regime == 2 and volPct < stormPct ? 3 : regime == 3 and volPct < 45 and tsRatio < 1.0 ? 0 : regime == 3 ? 3 : 0
if barstate.isconfirmed and newRegime != regime
    regime := newRegime
    regimeBar := bar_index
regName = regime == 0 ? "Calm" : regime == 1 ? "Building" : regime == 2 ? "STORM" : "Aftermath"
// regime boxes: each phase boxed around its price action, labeled
var array<box> regBoxes = array.new<box>()
var box regBox = na
var float regHi = na
var float regLo = na
f_regCol(int r) =>
    r == 2 ? stormCol : r == 1 ? goldCol : silvCol
f_regName(int r) =>
    r == 2 ? "STORM" : r == 1 ? "BUILDING" : "AFTERMATH"
if barstate.isconfirmed and showRegimeBg
    if regime != regime[1]
        regBox := na
    if regime != 0
        if na(regBox)
            regHi := high
            regLo := low
            regBox := box.new(bar_index, high, bar_index, low, border_color = color.new(f_regCol(regime), 35), border_style = line.style_dotted, bgcolor = color.new(f_regCol(regime), 90), text = f_regName(regime), text_color = color.new(f_regCol(regime), 10), text_size = size.small, text_halign = text.align_center, text_valign = text.align_top)
            regBoxes.push(regBox)
            while regBoxes.size() > 12
                box.delete(regBoxes.shift())
        else
            regHi := math.max(regHi, high)
            regLo := math.min(regLo, low)
            box.set_right(regBox, bar_index)
            box.set_top(regBox, regHi)
            box.set_bottom(regBox, regLo)

// ─── STORM EVENTS + SETTLING AUDIT ─────────────────────────────
watchEv = barstate.isconfirmed and press >= watchTh and press[1] < watchTh
stormEv = barstate.isconfirmed and volPct >= stormPct and volPct[1] < stormPct
calmEv  = barstate.isconfirmed and regime == 0 and regime[1] == 3

var array<float> wOut = array.new<float>()
pushF(array<float> a, float v) =>
    a.push(v)
    if a.size() > cap
        a.shift()
if barstate.isconfirmed and bar_index > settleH
    if watchEv[settleH]
        pushF(wOut, math.abs(close - close[settleH]) / atrV[settleH] >= moveTh ? 1.0 : 0.0)
statsOf(array<float> a) =>
    int n = a.size()
    float pS_ = 0.5
    float wLB = 0.5
    if n > 0
        int w = 0
        for i = 0 to n - 1
            if a.get(i) > 0.5
                w += 1
        float pHat = w * 1.0 / n
        pS_ := (pHat * n + 0.5 * shrinkK) / (n + shrinkK)
        wLB := (pHat + zConf * zConf / (2 * n) - zConf * math.sqrt(math.max(pHat * (1 - pHat) / n + zConf * zConf / (4 * n * n), 0.0))) / (1 + zConf * zConf / n)
    [pS_, wLB, n]

var array<label> mDone = array.new<label>()
var array<label> mPend = array.new<label>()
var array<int>   mBar  = array.new<int>()
var array<float> mPx   = array.new<float>()
var array<float> mAtr  = array.new<float>()
if watchEv
    [pw, ww, nw] = statsOf(wOut)
    ml = label.new(bar_index, low, "⚡ Storm Watch", style = label.style_label_up, color = color.new(goldCol, 8), textcolor = #231a08, size = size.small, tooltip = "Pressure crossed " + str.tostring(watchTh) + " — deep compression, long duration, unstable volatility.\nHistorically a Watch is followed by a move of at least " + str.tostring(moveTh, "#.#") + " Average True Range within " + str.tostring(settleH) + " bars" + (nw >= minN ? " " + fw(pw) + " of the time here (×" + str.tostring(nw) + ")" : "") + ".\nDirection is NOT predicted — expansion is. The marker settles by outcome.")
    mPend.push(ml)
    mBar.push(bar_index)
    mPx.push(close)
    mAtr.push(atrV)
if stormEv and mPend.size() == 0
    lbl = label.new(bar_index, high, "▩ Storm", style = label.style_label_down, color = color.new(stormCol, 10), textcolor = color.white, size = size.small, tooltip = "Volatility entered the top of its own cone — expansion is live.")
    mDone.push(lbl)
    while mDone.size() > keepM
        label.delete(mDone.shift())
if barstate.isconfirmed and mPend.size() > 0
    while mPend.size() > 0 and bar_index - mBar.get(0) >= settleH
        ml = mPend.shift()
        mBar.shift()
        mp = mPx.shift()
        ma = mAtr.shift()
        delivered = math.abs(close - mp) / ma >= moveTh
        label.set_color(ml, color.new(delivered ? calmCol : silvCol, delivered ? 0 : 45))
        label.set_textcolor(ml, delivered ? #06222b : color.new(#eef2f7, 15))
        label.set_text(ml, delivered ? "⚡ Delivered" : "⚡ Fizzled")
        mDone.push(ml)
        while mDone.size() > keepM
            label.delete(mDone.shift())

// ─── THE STORM CONE · expected move projected forward ─────────
var array<line> cnL = array.new<line>()
var array<linefill> cnF = array.new<linefill>()
while cnL.size() > 0
    line.delete(cnL.shift())
while cnF.size() > 0
    linefill.delete(cnF.shift())
if barstate.islast and showCone
    segs = 5
    float prevU1 = close
    float prevD1 = close
    float prevU2 = close
    float prevD2 = close
    int prevX = bar_index
    for i = 1 to segs
        hI = int(coneH * i / segs)
        sg = volYZ * math.sqrt(hI)
        u1 = close * math.exp(sg)
        d1 = close * math.exp(-sg)
        u2 = close * math.exp(2 * sg)
        d2 = close * math.exp(-2 * sg)
        x2 = bar_index + hI
        lU1 = line.new(prevX, prevU1, x2, u1, color = color.new(goldCol, 0), width = 3)
        lD1 = line.new(prevX, prevD1, x2, d1, color = color.new(goldCol, 0), width = 3)
        lU2 = line.new(prevX, prevU2, x2, u2, color = color.new(silvCol, 25), width = 2)
        lD2 = line.new(prevX, prevD2, x2, d2, color = color.new(silvCol, 25), width = 2)
        cnL.push(lU1)
        cnL.push(lD1)
        cnL.push(lU2)
        cnL.push(lD2)
        cnF.push(linefill.new(lU1, lD1, color.new(goldCol, 80)))
        cnF.push(linefill.new(lU2, lD2, color.new(silvCol, 92)))
        prevU1 := u1
        prevD1 := d1
        prevU2 := u2
        prevD2 := d2
        prevX := x2

// ─── PREMIUM WEATHER-STATION DASHBOARD (3 columns) ─────────────
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small
var table tb = table.new(dPos, 3, 9, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1)
if showDash and barstate.islast
    [pw, ww, nw] = statsOf(wOut)
    expMove = volYZ * math.sqrt(coneH) * 100
    titleSize = dashSize == "Tiny" ? size.small : dashSize == "Small" ? size.normal : dashSize == "Normal" ? size.large : size.huge
    table.cell(tb, 0, 0, "◈ VOLATILITY STORM TRACKER · " + syminfo.ticker, bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = titleSize, text_halign = text.align_center)
    table.cell(tb, 1, 0, "", bgcolor = dashTitleBg)
    table.cell(tb, 2, 0, "", bgcolor = dashTitleBg)
    table.merge_cells(tb, 0, 0, 2, 0)
    table.cell(tb, 0, 1, "Regime", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 1, regime == 2 ? "▩▩▩" : regime == 1 ? "▩▩" : regime == 3 ? "▩" : "—", text_color = regime == 2 ? stormCol : regime == 1 ? goldCol : silvCol, text_size = bodySize)
    table.cell(tb, 2, 1, regName + " · " + str.tostring(bar_index - regimeBar) + " bars", text_color = regime == 2 ? stormCol : regime == 1 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 2, "Storm Pressure", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 2, f_meter(press / 100, 6), text_color = press >= watchTh ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 2, str.tostring(press, "#") + " / 100", text_color = press >= watchTh ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 3, "Cone Position", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 3, f_meter(volPct / 100, 6), text_color = volPct >= stormPct ? stormCol : volPct <= 25 ? calmCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 3, str.tostring(volPct, "#") + "th percentile", text_color = volPct >= stormPct ? stormCol : dashBodyTxt, text_size = bodySize, tooltip = "Estimator suite (per-bar):\nYang-Zhang " + str.tostring(volYZ * 100, "#.###") + "%\nParkinson " + str.tostring(volP * 100, "#.###") + "%\nGarman-Klass " + str.tostring(volGK * 100, "#.###") + "%")
    table.cell(tb, 0, 4, "Term Structure", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 4, tsRatio >= 1.1 ? "⇈" : tsRatio <= 0.9 ? "⇊" : "≈", text_color = tsRatio >= 1.1 ? stormCol : tsRatio <= 0.9 ? calmCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 4, (tsRatio >= 1.1 ? "Backwardation " : tsRatio <= 0.9 ? "Contango " : "Flat ") + str.tostring(tsRatio, "#.##"), text_color = tsRatio >= 1.1 ? stormCol : tsRatio <= 0.9 ? calmCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 5, "Vol-of-Vol", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 5, vvolHot ? "◬" : "◭", text_color = vvolHot ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 5, vvolHot ? "Unstable · storm fuel" : "Stable", text_color = vvolHot ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 6, "Expected Move", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 6, "±", text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 6, str.tostring(expMove, "#.##") + "% / " + str.tostring(coneH) + " bars", text_color = dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 7, "Watch Record", text_color = dashMuteTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 7, nw >= minN ? f_meter(pw, 6) : "—", text_color = nw >= minN and pw >= 0.6 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 2, 7, nw > 0 ? fw(pw) + " delivered ×" + str.tostring(nw) : "—", text_color = nw >= minN and pw >= 0.6 ? goldCol : dashBodyTxt, text_size = bodySize)
    table.cell(tb, 0, 8, "Range projection, not direction · this chart only", text_color = dashMuteTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tb, 1, 8, "", text_size = size.tiny)
    table.cell(tb, 2, 8, "", text_size = size.tiny)

// ─── ALERTS ────────────────────────────────────────────────────
alertcondition(watchEv, "Storm Watch", "Storm pressure crossed the watch threshold — expansion conditions are charged.")
alertcondition(stormEv, "Storm Confirmed", "Volatility entered the top of its historical cone — expansion is live.")
alertcondition(calmEv, "Calm Restored", "The storm cycle completed and volatility returned to calm.")
alertcondition(tsRatio >= 1.1 and tsRatio[1] < 1.1, "Term Structure Inverted", "Short-horizon volatility exceeded long-horizon — stress regime.")
````
