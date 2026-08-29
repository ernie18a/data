<!-- tradingview-pine-id: PUB;6aa361ff52b34a738751353e3c084bf4 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Cone & Analog Path Projection

Source: https://www.tradingview.com/script/jLDhxHiD-Volatility-Cone-Analog-Path-Projection/

## Description

Volatility Cone & Analog Path Projection — Forward Price Envelope with Fractal Replay and Terminal Probability Distribution

Overview

Nearly every overlay on TradingView describes the past: where price has been, where volume traded, where structure broke. This tool points in the other direction. It builds a forward projection zone from the current bar using three independent layers — a realized-volatility cone, a replay of the historically most similar price fractals, and a terminal probability profile that combines both into a distribution of possible outcomes at the projection horizon.

The result is not a forecast. It is a bounded expectation: a visual answer to "given how this instrument has actually been moving, what range is normal over the next N bars, and where has price historically ended up after conditions that looked like this?"

Conceptual Framework

Price uncertainty grows with the square root of time, not linearly. A 24-bar projection is not 24 times as wide as a 1-bar projection — it is roughly 4.9 times as wide. Traders who size targets and stops on a straight-line mental model consistently misjudge what is achievable in a given number of bars.

The cone makes that curvature visible. Its width at each future bar is sigma * sqrt(t), where sigma is the standard deviation of log returns over the volatility window. Three nested bands are drawn, so you can immediately see which targets sit inside the ordinary range, which sit at the statistical edge, and which would require an exceptional move.

The Gaussian model alone, however, is a poor description of real markets: returns have fat tails, and volatility clusters. The analog layer addresses this by ignoring models entirely and asking an empirical question instead — what actually happened, historically, after the market printed this exact shape?

How It Works
Volatility estimation. Log returns are computed bar to bar. Their standard deviation over the volatility window gives the per-bar sigma; their mean gives the drift. Drift can be included or excluded from the cone's centerline.
Cone construction. For each future bar t from 1 to the horizon, the upper and lower bounds are close * exp(drift*t ± k*sigma*sqrt(t)) for each of the three band multipliers. Each band is rendered as a closed polygon with layered transparency, producing depth from the centerline outward.
Fingerprint extraction. The most recent N bars of log returns are z-scored — mean removed, divided by their own standard deviation. This makes the pattern scale-invariant: the same shape is recognised whether it happened during a quiet range or a volatile expansion, and at any price level.
Historical scan. Every candidate window inside the scan depth is z-scored the same way and compared to the current fingerprint by summed squared difference. Lower distance means a closer shape match. Candidates that overlap an already-selected match without improving on it are rejected, so the top results are not five copies of the same event shifted by one bar.
Forward replay. For each of the top matches, the bars that followed it are converted into a relative path and re-anchored to the current close. The path each analog is drawing forward is exactly the move that occurred after that historical fingerprint — nothing is fitted or optimised. Paths ending above the current price are drawn bullish, below bearish, and a thick median line traces the bar-by-bar median across all analogs.
Terminal probability profile. At the projection horizon a horizontal distribution is built across the cone's full range. Each row's density blends the Gaussian probability implied by the volatility model with an empirical kernel centred on each analog's endpoint. The Model Weight input controls that mix: 1.0 is purely theoretical, 0.0 is purely historical, and the default sits between them. The widest row — the mode of the blended distribution — is marked as the most probable zone.
Interpretation
Cone bands define what is statistically ordinary. A target beyond the outer band within the horizon is not impossible, it is simply rare — treat it accordingly when planning holding time.
Cone width itself is information. A narrow cone means compressed volatility, which historically resolves into expansion. A wide cone means the market is already moving; chasing inside it carries a worse risk profile.
Analog dispersion matters more than analog direction. Five paths that fan out in all directions means the current shape carried no historical edge. Five paths clustering in one direction is the meaningful configuration.
Best Match Quality in the panel scores how closely the nearest historical fingerprint resembles the present one. Below roughly 60%, treat the analog layer as noise and rely on the cone alone.
The most probable zone is where the blended distribution peaks. It is a magnet-style reference, not a target — the distribution is wide by construction.
Volatility Regime compares short-window volatility to the full window. Expanding means the cone is likely to understate near-term movement; contracting means the opposite.
Settings
Setting	Effect
Projection Horizon	Bars projected forward. Also the endpoint of the profile
Volatility Window	Sample size for sigma and drift. Longer = smoother, slower to adapt
Include Drift	Tilts the cone with the window's mean return
Inner / Mid / Outer Band	Sigma multipliers for the three layers
Fingerprint Length	Bars compared for similarity. Shorter = more matches, less specific
Scan Depth	How far back to search for analogs
Number of Analogs	How many historical paths to replay
Profile Rows / Width	Resolution and horizontal size of the terminal distribution
Model Weight	Gaussian versus empirical blend in the distribution
Redraw on Bar Close Only	Recommended on. The scan is heavy; this runs it once per bar
Limitations — read this
This is not a prediction and must not be traded as one. The cone describes a statistical range under an assumption of stable volatility. Real volatility is not stable, and returns have fatter tails than the Gaussian model implies, so moves outside the outer band occur more often than the model suggests.
Analog matching is weak evidence. A few dozen bars of shape similarity is a small sample; markets are non-stationary and a pattern that resolved one way in the past carries no obligation to repeat. The paths are historical context, not a probability statement about the future.
Nothing repaints, but the whole projection is recomputed each bar. Yesterday's cone is not preserved — the drawing always reflects current data only. It is anchored to the last bar by design.
On low-volume, illiquid, or heavily gapped instruments the return distribution is distorted and both layers degrade.
No entries, no stops, no targets, no signals. This is a context tool for sizing expectations and holding time.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//   V O L A T I L I T Y   C O N E   &   A N A L O G   P A T H   P R O J E C T I O N
//   Build: VCP-1.0   |   Pine Script v6
//
//   Forward-looking structure. Instead of describing where price has been,
//   this projects where it can statistically go:
//     · a realized-volatility cone scaled by sigma * sqrt(t)
//     · the K most similar historical fractals, replayed forward from now
//     · a terminal probability profile blending the Gaussian model with
//       the empirical distribution of those historical outcomes
// ══════════════════════════════════════════════════════════════════════════════

indicator(
     title               = "Volatility Cone & Analog Path Projection",
     shorttitle          = "VOL CONE",
     overlay             = true,
     max_polylines_count = 100,
     max_boxes_count     = 500,
     max_lines_count     = 500,
     max_labels_count    = 500,
     max_bars_back       = 1000,
     calc_bars_count     = 2000)

// ══════════════════════════════════════════════════════════════════════════════
//  GROUPS
// ══════════════════════════════════════════════════════════════════════════════
string G_ENG  = "① محرك الإسقاط · Projection Engine"
string G_ANA  = "② المسارات التاريخية · Analog Paths"
string G_PRO  = "③ ملف الاحتمالات · Probability Profile"
string G_VIS  = "④ المظهر · Visuals"
string G_DASH = "⑤ اللوحة · Dashboard"

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
i_horizon  = input.int(24, "أفق الإسقاط (شمعة) · Projection Horizon", minval = 5, maxval = 120, group = G_ENG, tooltip = "عدد الشموع للأمام · Bars projected forward")
i_volLen   = input.int(100, "نافذة التقلب · Volatility Window", minval = 20, maxval = 500, group = G_ENG)
i_useDrift = input.bool(true, "إدراج الميل · Include Drift", group = G_ENG, tooltip = "متوسط العائد اللوغاريتمي · Mean log return of the window")
i_showCone = input.bool(true, "إظهار المخروط · Show Cone", group = G_ENG)
i_band1    = input.float(1.0, "النطاق الداخلي (σ) · Inner Band", minval = 0.25, maxval = 3.0, step = 0.25, group = G_ENG)
i_band2    = input.float(2.0, "النطاق الأوسط (σ) · Mid Band", minval = 0.5, maxval = 4.0, step = 0.25, group = G_ENG)
i_band3    = input.float(3.0, "النطاق الخارجي (σ) · Outer Band", minval = 1.0, maxval = 6.0, step = 0.25, group = G_ENG)

i_useAna   = input.bool(true, "تفعيل المسارات التاريخية · Enable Analog Paths", group = G_ANA)
i_match    = input.int(24, "طول البصمة · Fingerprint Length", minval = 8, maxval = 60, group = G_ANA, tooltip = "عدد الشموع اللي كتقارن · Bars compared for similarity")
i_scan     = input.int(400, "مدى البحث · Scan Depth", minval = 100, maxval = 600, step = 20, group = G_ANA)
i_topK     = input.int(5, "عدد المسارات · Number of Analogs", minval = 1, maxval = 8, group = G_ANA)
i_showMed  = input.bool(true, "مسار الوسيط · Median Path", group = G_ANA)
i_showEnds = input.bool(true, "نقاط النهاية · Endpoint Dots", group = G_ANA)

i_showPro  = input.bool(true, "إظهار ملف الاحتمالات · Show Probability Profile", group = G_PRO)
i_pBins    = input.int(30, "عدد الخانات · Profile Rows", minval = 10, maxval = 60, group = G_PRO)
i_pWidth   = input.int(40, "عرض الملف (شمعة) · Profile Width", minval = 10, maxval = 80, group = G_PRO)
i_blend    = input.float(0.55, "وزن النموذج الرياضي · Model Weight", minval = 0.0, maxval = 1.0, step = 0.05, group = G_PRO, tooltip = "0 = تاريخي بالكامل · 1 = غاوسي بالكامل / 0 = fully empirical, 1 = fully Gaussian")
i_showMode = input.bool(true, "تعليم المنطقة الأكثر احتمالاً · Mark Most Probable Zone", group = G_PRO)

i_palette  = input.string("Aurora", "لوحة الألوان · Palette", options = ["Aurora", "Solar", "Ice", "Mono"], group = G_VIS)
i_colUp    = input.color(#00E5A0, "لون صعودي · Bullish", group = G_VIS)
i_colDn    = input.color(#FF4E6A, "لون هبوطي · Bearish", group = G_VIS)
i_coneOp   = input.int(88, "شفافية المخروط · Cone Transparency", minval = 55, maxval = 98, group = G_VIS)
i_anaOp    = input.int(45, "شفافية المسارات · Path Transparency", minval = 0, maxval = 90, group = G_VIS)
i_barClose = input.bool(true, "إعادة الرسم عند الإغلاق فقط · Redraw on Bar Close Only", group = G_VIS, tooltip = "يخلي الشارت خفيف · Keeps the chart fast")

i_showDash = input.bool(true, "إظهار اللوحة · Show Dashboard", group = G_DASH)
i_lang     = input.string("English", "اللغة · Language", options = ["العربية", "English"], group = G_DASH)
i_dashPos  = input.string("Top Right", "الموضع · Position", options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = G_DASH)
i_dashSize = input.string("small", "حجم الخط · Text Size", options = ["tiny", "small", "normal", "large"], group = G_DASH)
i_signature = input.string("", "التوقيع · Signature", group = G_DASH, tooltip = "نص حر يظهر أسفل اللوحة · Optional free text in the panel footer")

// ══════════════════════════════════════════════════════════════════════════════
//  THEME
// ══════════════════════════════════════════════════════════════════════════════
bool isDark = color.r(chart.bg_color) < 128

color C_TXT   = isDark ? color.rgb(226, 226, 226) : color.rgb(26, 26, 26)
color C_MUTED = isDark ? color.rgb(148, 148, 148) : color.rgb(108, 108, 108)
color C_PANEL = isDark ? color.new(color.rgb(10, 13, 20), 6) : color.new(color.rgb(255, 255, 255), 6)
color C_FRAME = isDark ? color.new(color.rgb(120, 92, 20), 20) : color.new(color.rgb(190, 190, 190), 20)
color C_ROW_A = isDark ? color.new(color.rgb(16, 20, 28), 8) : color.new(color.rgb(246, 248, 252), 8)
color C_ROW_B = isDark ? color.new(color.rgb(23, 28, 38), 8) : color.new(color.rgb(234, 238, 245), 8)
color C_HDRBG = color.new(color.rgb(140, 100, 8), 0)
color C_HDRTX = color.rgb(255, 228, 150)
color C_GOLD  = color.rgb(255, 196, 60)

color P_CORE = switch i_palette
    "Aurora" => color.rgb(120, 90, 255)
    "Solar"  => color.rgb(255, 150, 30)
    "Ice"    => color.rgb(60, 180, 255)
    =>          color.rgb(170, 170, 180)

color P_EDGE = switch i_palette
    "Aurora" => color.rgb(0, 220, 220)
    "Solar"  => color.rgb(255, 70, 40)
    "Ice"    => color.rgb(180, 240, 255)
    =>          color.rgb(120, 120, 130)

color P_PATH = switch i_palette
    "Aurora" => color.rgb(190, 140, 255)
    "Solar"  => color.rgb(255, 210, 90)
    "Ice"    => color.rgb(120, 220, 255)
    =>          color.rgb(200, 200, 210)

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_div(float num, float den, float fallback) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

L(string ar, string en) =>
    i_lang == "العربية" ? ar : en

f_pos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Middle Left"  => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Left"  => position.bottom_left
        =>                position.bottom_right

f_pct(float a, float b) =>
    f_div(a - b, b, 0.0) * 100.0

// ══════════════════════════════════════════════════════════════════════════════
//  GLOBAL CALCULATIONS  (no ta.* inside conditional blocks)
// ══════════════════════════════════════════════════════════════════════════════
float logRet = math.log(f_div(close, close[1], 1.0))
float sigma  = nz(ta.stdev(logRet, i_volLen), 0.0)
float drift  = nz(ta.sma(logRet, i_volLen), 0.0)
float driftUse = i_useDrift ? drift : 0.0

// Volatility regime context
float sigFast = nz(ta.stdev(logRet, 20), 0.0)
float volRegime = f_div(sigFast, sigma, 1.0)

// ══════════════════════════════════════════════════════════════════════════════
//  DRAW-STATE
// ══════════════════════════════════════════════════════════════════════════════
var array<polyline> pls    = array.new<polyline>()
var array<box>      bxs    = array.new<box>()
var array<line>     lns    = array.new<line>()
var array<label>    lbs    = array.new<label>()

var int   lastDraw  = na
var float medTarget = na
var float modePrice = na
var int   bullCount = 0
var int   anaCount  = 0
var float bestSim   = na
var float up1Px     = na
var float dn1Px     = na
var float up2Px     = na
var float dn2Px     = na

bool doDraw = barstate.islast and bar_index > i_scan + i_match + 10 and (not i_barClose or na(lastDraw) or lastDraw != bar_index)

// ══════════════════════════════════════════════════════════════════════════════
//  CONE BUILDER
// ══════════════════════════════════════════════════════════════════════════════
f_cone(float mult, color lineCol, color fillCol) =>
    array<chart.point> pts = array.new<chart.point>()
    for t = 0 to i_horizon
        float u = close * math.exp(driftUse * t + mult * sigma * math.sqrt(t))
        array.push(pts, chart.point.from_index(bar_index + t, u))
    for t = i_horizon to 0
        float d = close * math.exp(driftUse * t - mult * sigma * math.sqrt(t))
        array.push(pts, chart.point.from_index(bar_index + t, d))
    polyline.new(points = pts, curved = false, closed = true, line_color = lineCol, fill_color = fillCol, line_width = 1)

// ══════════════════════════════════════════════════════════════════════════════
//  MAIN RENDER
// ══════════════════════════════════════════════════════════════════════════════
if doDraw
    lastDraw := bar_index

    // ── cleanup ──────────────────────────────────────────────────────────────
    if array.size(pls) > 0
        for p in pls
            polyline.delete(p)
        array.clear(pls)
    if array.size(bxs) > 0
        for b in bxs
            box.delete(b)
        array.clear(bxs)
    if array.size(lns) > 0
        for l in lns
            line.delete(l)
        array.clear(lns)
    if array.size(lbs) > 0
        for lb in lbs
            label.delete(lb)
        array.clear(lbs)

    int   N  = i_horizon
    float sN = sigma * math.sqrt(N)

    up1Px := close * math.exp(driftUse * N + i_band1 * sN)
    dn1Px := close * math.exp(driftUse * N - i_band1 * sN)
    up2Px := close * math.exp(driftUse * N + i_band2 * sN)
    dn2Px := close * math.exp(driftUse * N - i_band2 * sN)

    // ── 1. volatility cone (outer first so inner layers stack on top) ────────
    if i_showCone and sigma > 0
        array.push(pls, f_cone(i_band3, color.new(P_CORE, 92), color.new(P_CORE, math.min(98, i_coneOp + 8))))
        array.push(pls, f_cone(i_band2, color.new(P_CORE, 80), color.new(P_CORE, i_coneOp)))
        array.push(pls, f_cone(i_band1, color.new(P_EDGE, 55), color.new(P_EDGE, math.max(55, i_coneOp - 10))))

    // ── 2. analog fingerprint search ─────────────────────────────────────────
    array<float> ends = array.new<float>()
    bullCount := 0
    anaCount  := 0
    bestSim   := na
    medTarget := na

    if i_useAna
        int Lm = i_match
        int M  = i_scan
        int K  = i_topK

        // Pre-compute the log-return series once
        int RN = M + Lm + 2
        array<float> rets = array.new<float>(RN, 0.0)
        for i = 0 to RN - 1
            array.set(rets, i, math.log(f_div(close[i], close[i + 1], 1.0)))

        // Current fingerprint, z-scored
        float cSum = 0.0
        for k = 0 to Lm - 1
            cSum += array.get(rets, k)
        float cMean = cSum / Lm
        float cVar = 0.0
        for k = 0 to Lm - 1
            float dv = array.get(rets, k) - cMean
            cVar += dv * dv
        float cSd = math.sqrt(cVar / Lm)
        cSd := cSd <= 0 ? 0.0000001 : cSd

        array<float> bScore = array.new<float>(K, 1000000000.0)
        array<int>   bOff   = array.new<int>(K, -1)

        for j = N to M
            float sSum = 0.0
            for k = 0 to Lm - 1
                sSum += array.get(rets, j + k)
            float sMean = sSum / Lm
            float sVar = 0.0
            for k = 0 to Lm - 1
                float dv = array.get(rets, j + k) - sMean
                sVar += dv * dv
            float sSd = math.sqrt(sVar / Lm)
            sSd := sSd <= 0 ? 0.0000001 : sSd

            float ssd = 0.0
            for k = 0 to Lm - 1
                float zc = (array.get(rets, k) - cMean) / cSd
                float zs = (array.get(rets, j + k) - sMean) / sSd
                float dz = zc - zs
                ssd += dz * dz

            // reject near-duplicate windows that are not an improvement
            bool skip = false
            for q = 0 to K - 1
                int o = array.get(bOff, q)
                if o >= 0 and math.abs(o - j) < Lm and array.get(bScore, q) <= ssd
                    skip := true
                    break

            if not skip and ssd < array.get(bScore, K - 1)
                int pos = K - 1
                while pos > 0 and array.get(bScore, pos - 1) > ssd
                    array.set(bScore, pos, array.get(bScore, pos - 1))
                    array.set(bOff, pos, array.get(bOff, pos - 1))
                    pos -= 1
                array.set(bScore, pos, ssd)
                array.set(bOff, pos, j)

        // ── 3. replay each analog forward from the current close ─────────────
        array<int> valid = array.new<int>()

        for q = 0 to K - 1
            int o = array.get(bOff, q)
            if o >= 0
                array.push(valid, o)
        anaCount := array.size(valid)

        if anaCount > 0
            bestSim := f_clamp(100.0 * (1.0 - array.get(bScore, 0) / (2.0 * Lm)), 0.0, 100.0)

            for q = 0 to anaCount - 1
                int o = array.get(valid, q)
                float baseP = close[o]
                array<chart.point> pp = array.new<chart.point>()
                array.push(pp, chart.point.from_index(bar_index, close))
                for t = 1 to N
                    float px = close * f_div(close[o - t], baseP, 1.0)
                    array.push(pp, chart.point.from_index(bar_index + t, px))
                float endP = close * f_div(close[o - N], baseP, 1.0)
                array.push(ends, endP)
                if endP > close
                    bullCount += 1
                color pc = endP >= close ? i_colUp : i_colDn
                array.push(pls, polyline.new(points = pp, curved = false, closed = false, line_color = color.new(pc, i_anaOp), line_width = 1))
                if i_showEnds
                    array.push(lbs, label.new(bar_index + N, endP, "", style = label.style_circle, color = color.new(pc, 25), size = size.tiny))

            // median projected path
            if i_showMed and anaCount > 1
                array<float> srt = array.new<float>(anaCount, 0.0)
                array<chart.point> mp = array.new<chart.point>()
                array.push(mp, chart.point.from_index(bar_index, close))
                for t = 1 to N
                    for q = 0 to anaCount - 1
                        int o = array.get(valid, q)
                        array.set(srt, q, close * f_div(close[o - t], close[o], 1.0))
                    array.sort(srt, order.ascending)
                    float med = array.get(srt, int(anaCount / 2))
                    array.push(mp, chart.point.from_index(bar_index + t, med))
                    if t == N
                        medTarget := med
                array.push(pls, polyline.new(points = mp, curved = false, closed = false, line_color = color.new(P_PATH, 10), line_width = 3))

    // ── 4. terminal probability profile ──────────────────────────────────────
    if i_showPro and sigma > 0
        float hiP = close * math.exp(driftUse * N + i_band3 * sN)
        float loP = close * math.exp(driftUse * N - i_band3 * sN)
        float rng = hiP - loP
        if rng > 0
            int   nb   = i_pBins
            float binH = rng / nb
            float bw   = sN * 0.35
            int   x0   = bar_index + N + 3

            array<float> dens = array.new<float>(nb, 0.0)
            for b = 0 to nb - 1
                float pc = loP + (b + 0.5) * binH
                float z  = f_div(math.log(f_div(pc, close, 1.0)) - driftUse * N, sN, 0.0)
                float g  = math.exp(-0.5 * z * z)
                float e  = 0.0
                if array.size(ends) > 0
                    for q = 0 to array.size(ends) - 1
                        float ze = f_div(math.log(f_div(pc, array.get(ends, q), 1.0)), bw, 0.0)
                        e += math.exp(-0.5 * ze * ze)
                    e := e / array.size(ends)
                array.set(dens, b, i_blend * g + (1.0 - i_blend) * e)

            float dMax = array.max(dens)
            int   mIdx = 0
            for b = 0 to nb - 1
                if array.get(dens, b) == dMax
                    mIdx := b
                    break
            modePrice := loP + (mIdx + 0.5) * binH

            if dMax > 0
                for b = 0 to nb - 1
                    float ratio = array.get(dens, b) / dMax
                    int w = int(math.round(ratio * i_pWidth))
                    if w > 0
                        float bLo = loP + b * binH
                        float pcMid = bLo + binH * 0.5
                        color bc = pcMid >= close ? i_colUp : i_colDn
                        int tr = int(math.round(90 - ratio * 55))
                        array.push(bxs, box.new(x0, bLo + binH * 0.88, x0 + w, bLo + binH * 0.12, border_color = color.new(color.black, 100), border_width = 0, bgcolor = color.new(bc, tr)))

                if i_showMode
                    array.push(lns, line.new(bar_index, modePrice, x0 + i_pWidth, modePrice, color = color.new(C_GOLD, 30), width = 1, style = line.style_dotted))
                    array.push(lbs, label.new(x0 + i_pWidth, modePrice, L("الأكثر احتمالاً ", "MOST PROBABLE ") + str.tostring(modePrice, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = C_GOLD, size = size.small))

    // ── 5. horizon markers ───────────────────────────────────────────────────
    if i_showCone and sigma > 0
        array.push(lbs, label.new(bar_index + N, up1Px, "+" + str.tostring(i_band1, "#.##") + "σ  " + str.tostring(up1Px, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(P_EDGE, 15), size = size.small))
        array.push(lbs, label.new(bar_index + N, dn1Px, "-" + str.tostring(i_band1, "#.##") + "σ  " + str.tostring(dn1Px, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(P_EDGE, 15), size = size.small))
        array.push(lns, line.new(bar_index, close, bar_index + N, close, color = color.new(C_MUTED, 55), width = 1, style = line.style_dashed))

// ══════════════════════════════════════════════════════════════════════════════
//  VOLATILITY EXPANSION FLAG
// ══════════════════════════════════════════════════════════════════════════════
bool volShock = sigma > 0 and math.abs(logRet) > 2.5 * sigma
plotshape(volShock, title = "Volatility Shock", style = shape.diamond, location = location.belowbar, color = color.new(P_EDGE, 20), size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════
f_head(table t, int r, string a, string b) =>
    table.cell(t, 0, r, a, text_color = C_HDRTX, bgcolor = C_HDRBG, text_size = i_dashSize, text_halign = text.align_left)
    table.cell(t, 1, r, b, text_color = C_HDRTX, bgcolor = C_HDRBG, text_size = i_dashSize, text_halign = text.align_right)

f_row(table t, int r, string k, string v, color vc, bool alt) =>
    color bg = alt ? C_ROW_A : C_ROW_B
    table.cell(t, 0, r, k, text_color = C_MUTED, bgcolor = bg, text_size = i_dashSize, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = vc, bgcolor = bg, text_size = i_dashSize, text_halign = text.align_right)

if i_showDash and barstate.islast
    var table dash = table.new(f_pos(i_dashPos), 2, 16, bgcolor = C_PANEL, border_color = C_FRAME, border_width = 1, frame_color = C_FRAME, frame_width = 1)

    string volTxt  = str.tostring(sigma * 100.0, "#.###") + "%"
    string regTxt  = volRegime > 1.25 ? L("توسّع", "EXPANDING") : volRegime < 0.8 ? L("انكماش", "CONTRACTING") : L("مستقر", "STABLE")
    color  regCol  = volRegime > 1.25 ? i_colDn : volRegime < 0.8 ? C_MUTED : C_GOLD
    string r1Txt   = na(up1Px) ? "—" : str.tostring(dn1Px, format.mintick) + " ↔ " + str.tostring(up1Px, format.mintick)
    string r2Txt   = na(up2Px) ? "—" : str.tostring(dn2Px, format.mintick) + " ↔ " + str.tostring(up2Px, format.mintick)
    string medTxt  = na(medTarget) ? "—" : str.tostring(medTarget, format.mintick) + "  (" + (medTarget >= close ? "+" : "") + str.tostring(f_pct(medTarget, close), "#.##") + "%)"
    color  medCol  = na(medTarget) ? C_MUTED : medTarget >= close ? i_colUp : i_colDn
    string anaTxt  = anaCount == 0 ? "—" : str.tostring(bullCount) + " ▲ / " + str.tostring(anaCount - bullCount) + " ▼"
    color  anaCol  = anaCount == 0 ? C_MUTED : bullCount * 2 > anaCount ? i_colUp : bullCount * 2 < anaCount ? i_colDn : C_GOLD
    string simTxt  = na(bestSim) ? "—" : str.tostring(bestSim, "#.0") + "%"
    string modeTxt = na(modePrice) ? "—" : str.tostring(modePrice, format.mintick)
    string drfTxt  = str.tostring(driftUse * i_horizon * 100.0, "+#.##;-#.##") + "%"

    int r = 0
    f_head(dash, r, "◆ " + L("مخروط التقلب", "VOLATILITY CONE"), "v1.0")
    r += 1
    f_row(dash, r, syminfo.ticker + " · " + timeframe.period, str.tostring(i_horizon) + L(" شمعة أمام", " bars ahead"), C_TXT, true)
    r += 1
    f_row(dash, r, L("تقلب الشمعة (σ)", "Per-Bar Volatility"), volTxt, C_TXT, false)
    r += 1
    f_row(dash, r, L("نظام التقلب", "Volatility Regime"), regTxt, regCol, true)
    r += 1
    f_row(dash, r, L("النطاق ±1σ", "Range ±1σ"), r1Txt, C_TXT, false)
    r += 1
    f_row(dash, r, L("النطاق ±2σ", "Range ±2σ"), r2Txt, C_MUTED, true)
    r += 1
    f_head(dash, r, L("─ المسارات التاريخية ─", "─ HISTORICAL ANALOGS ─"), str.tostring(anaCount))
    r += 1
    f_row(dash, r, L("جودة أفضل تطابق", "Best Match Quality"), simTxt, na(bestSim) ? C_MUTED : bestSim >= 70 ? i_colUp : C_GOLD, false)
    r += 1
    f_row(dash, r, L("النتائج", "Outcomes"), anaTxt, anaCol, true)
    r += 1
    f_row(dash, r, L("هدف الوسيط", "Median Target"), medTxt, medCol, false)
    r += 1
    f_row(dash, r, L("المنطقة الأكثر احتمالاً", "Most Probable Zone"), modeTxt, C_GOLD, true)
    r += 1
    f_row(dash, r, L("الميل على الأفق", "Drift over Horizon"), drfTxt, driftUse >= 0 ? i_colUp : i_colDn, false)
    r += 1
    f_head(dash, r, i_signature == "" ? L("مخروط التقلب", "Volatility Cone") : i_signature, "VCP-1.0")

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(volShock, title = "Volatility Shock", message = "Volatility Cone: bar range exceeded 2.5 sigma on {{ticker}} ({{interval}})")
````
