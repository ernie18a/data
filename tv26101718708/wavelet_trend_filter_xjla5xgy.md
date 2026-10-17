# Wavelet Trend Filter

- url: https://www.tradingview.com/script/xjlA5XGY-Wavelet-Trend-Filter/
- type: indicator
- pine_id: PUB;c2e9456eb5114dba85cbe7ae40ebafc0
- version: 1.0

## Description

What it is

A denoised price line whose smoothing is derived from measured noise, not a period you pick — plus the tool's signature number, the noise fraction (what share of the recent move is noise vs structure). Most published "wavelet denoising improves prediction" results denoise the whole series including future bars, which is lookahead-contaminated and impossible live. This tool refuses that: it runs a Haar wavelet transform over a trailing power-of-two window and keeps only the endpoint as today's value, fixed at close and never revised. Strictly causal, non-repainting, no forecast.

How it's built

The engine is a five-step Donoho-Johnstone wavelet shrinkage, run every bar over a trailing window (default 128 bars): a Haar DWT (shortest support, fewest boundary coefficients — the right choice for short causal series); noise scale σ = MAD(finest detail coefficients)/0.6745 (robust to outliers); the universal threshold λ = σ·√(2 ln n) with an optional multiplier; soft or hard shrinkage of the detail coefficients; and an inverse transform, keeping the endpoint. Optional symmetric reflection padding reduces edge distortion. Because the threshold self-scales from measured noise, a quiet tape is smoothed less and a noisy tape more — automatically, on any timeframe.

Derived reads: noise fraction = 1 − var(denoised)/var(raw) over the window (share the transform removed), ranked into a percentile; trend slope in noise-σ units; and a signal-to-noise strength = slope (σ) × structure share (1 − noise fraction), the single "is this trend real?" number.

How you read it — and the honest actionable signal

The noise fraction gates everything. A bold chop/structure ribbon along the bottom of the chart shows the whole regime spectrum (green = structure/low noise/trend trustworthy, red = chop/high noise/stand aside), and a ±1σ noise envelope around the denoised line makes the removed noise visible — so it's obviously not just a moving average.

The actionable markers are structure-gated: a green ▲ / red ▼ prints when the denoised slope turns up/down and the tape has structure (low noise); in chop the tool withholds and marks the turn with a small caution dot instead. A hysteresis on the structure state keeps the signals from re-firing as noise oscillates. This is not a blind crossover generator — it goes quiet exactly when the tape is too noisy to trust, which is when ordinary signals whipsaw. The panel's "Read" row states the current call in plain English ("up-trend · structure ✓", "chop — stand aside").

Exports & alerts

EXP_Denoised · EXP_NoiseSigma · EXP_NoiseFrac (0–1) · EXP_Slope (σ) · EXP_SNR (trend strength) · EXP_Stance (+1 up·structure / −1 down·structure / 0). Alerts: noise fraction entering top / bottom quartile (chop / structure) · denoised slope turning up / down · confirmed up-trend / down-trend with structure present.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// WAVELET TREND FILTER                                                                        v1.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT OUTPUTS
//   A denoised price line whose smoothing is DERIVED FROM MEASURED NOISE, not a period you picked —
//   plus the single most useful daily number: what fraction of today's movement is noise.
//   Panel headline, e.g.:  Noise 78% of variance · trend slope −0.3σ · endpoint provisional
//
// THE ENGINE
//   1. Haar DWT over a trailing power-of-2 window (default 128). Haar is chosen deliberately: the
//      SHORTEST support and the fewest boundary coefficients — the standard recommendation for short
//      series (a longer wavelet reaches across the edge, exactly where a causal estimate is weakest).
//   2. Noise scale σ = MAD(level-1 detail coefficients) / 0.6745 — robust to the outliers that would
//      inflate a plain standard deviation.
//   3. Universal threshold λ = σ·√(2 ln n)  (Donoho-Johnstone), optionally scaled.
//   4. Soft thresholding (shrink toward zero) by default; hard available.
//   5. Inverse transform → denoised series; only the ENDPOINT is kept as today's value.
//   6. Optional symmetric reflection padding at the boundary to reduce edge distortion.
//
// THE NON-REPAINT / BOUNDARY DESIGN (the honest constraint)
//   At each bar the DWT is computed over the trailing window and ONLY the final reconstructed value
//   is taken as today's denoised price. It is fixed at close and never revised → strictly
//   NON-REPAINTING. But that means you always live at the boundary, which is precisely where wavelet
//   estimates are weakest. Design responses:
//     • the most recent bars render faded and are flagged "provisional";
//     • a boundary-reliability row in the panel;
//     • and this plain statement: published results showing "wavelet denoising improves prediction"
//       typically denoise the WHOLE series including future data — that is lookahead-contaminated and
//       NOT achievable live. This script is strictly causal and therefore makes NO prediction claim.
//
// ALL-TIMEFRAME
//   Window in bars; the threshold self-scales from measured noise, so a quiet tape gets less
//   smoothing and a noisy tape more — automatically. Identical machinery on 1m and 1D.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Denoised · EXP_NoiseSigma · EXP_NoiseFrac (0-1 share of variance that is noise) · EXP_Slope (σ) ·
//   EXP_SNR (slope × structure share) · EXP_Stance (+1 up·structure / −1 down·structure / 0)
//
// CONCEPT CREDIT
//   Discrete wavelet transform / multiresolution analysis — A. Haar (1910); S. Mallat (1989).
//   Wavelet shrinkage, the universal threshold λ = σ√(2 ln n) and MAD noise estimation —
//   D. Donoho & I. Johnstone (1994). The causal endpoint design, the provisional-boundary honesty,
//   the noise-fraction read, the structure-gated signals and the signal-to-noise score are the
//   author's own. No third-party code is reused.
//
// HOW YOU READ IT — the noise fraction gates everything
//   The signature output is the NOISE FRACTION: what share of the recent move is noise vs structure.
//   It drives a bottom chop/structure RIBBON on the chart and gates the trend read — the denoised
//   slope is only worth acting on when structure is present. So the actionable markers are STRUCTURE-
//   GATED: a green up-triangle / red down-triangle prints when the denoised slope turns AND noise is
//   low (a real move); in chop the tool withholds and says "stand aside". This is NOT a blind
//   crossover generator — it goes quiet exactly when the tape is too noisy to trust, which is when
//   ordinary signals whipsaw. The SIGNAL-TO-NOISE score (slope strength × structure share) is the one
//   "is this trend real?" number, exported alongside the denoised stance for downstream use.
//
// HONEST FRAMING
//   Strictly causal, non-repainting at the confirmed bars, in-sample, no forward prediction. The
//   signals are a disciplined read of the CURRENT denoised state, not a forecast — a green triangle
//   says "this move is real right now", never "it will continue". Not financial advice.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Wavelet Trend Filter", "Wavelet", overlay = true, precision = 4, max_labels_count = 50)

// ═════════════════════════ INPUTS ═══════════════════════════════════════════════════════════════
gW = "01 · Wavelet"
srcW    = input.source(close, "Source", group = gW)
winExp  = input.int(7, "Window = 2^k bars", minval = 6, maxval = 8, group = gW, tooltip = "Trailing window length as a power of two (enforced): 6 = 64, 7 = 128 (default, responsive), 8 = 256 (stabler noise estimate, heavier).")
thrMode = input.string("Soft", "Threshold mode", options = ["Soft","Hard"], group = gW, tooltip = "Soft (default) shrinks every detail coefficient toward zero — smoother. Hard keeps or kills — preserves edges but noisier.")
thrMult = input.float(1.0, "Threshold × (1.0 = universal)", minval = 0.2, maxval = 3.0, step = 0.1, group = gW, tooltip = "Multiplier on the Donoho-Johnstone universal threshold. < 1 keeps more detail (less smoothing); > 1 smooths harder.")

gB = "02 · Boundary"
padOn   = input.bool(true, "Symmetric reflection padding", group = gB, tooltip = "Mirror the window at its edges before transforming, so the current bar sits at an interior point of a symmetric signal — reduces edge distortion at the cost of ~2× computation. Off = lighter.")
provLen = input.int(8, "Provisional-zone length (bars)", minval = 0, maxval = 100, group = gB, tooltip = "How many of the most recent bars are rendered faded / flagged provisional — the region where the causal estimate is least settled.")
slopeLen= input.int(5, "Slope length (bars)", minval = 2, maxval = 100, group = gB, tooltip = "Bars over which the denoised trend slope is measured (reported in noise-σ units).")
nfLen   = input.int(200, "Noise-fraction percentile window", minval = 30, maxval = 2000, group = gB)

gD = "03 · Display & theme"
showBand = input.bool(true, "Noise envelope (±σ around trend)", group = gD, tooltip = "Shade a ±1 noise-σ channel around the denoised line — you SEE the measured noise scale, which is exactly what makes this a wavelet denoiser and not just a moving average.")
showPanel= input.bool(true, "Show dashboard", group = gD)
panelPos = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gD)
themeOpt = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = gD)
colUp    = input.color(#26a69a, "Up",   inline = "c", group = gD)
colDn    = input.color(#ef5350, "Down", inline = "c", group = gD)
colFlat  = input.color(#f2b01e, "Flat", inline = "c", group = gD)

gS = "04 · Signals & regime"
showSignals = input.bool(true, "Structure-gated trend signals", group = gS, tooltip = "Green up-triangle / red down-triangle when the denoised slope turns AND the tape has structure (low noise). In chop the signal is withheld — the tool stands aside instead of firing where ordinary indicators whipsaw.")
slopeThr    = input.float(0.15, "Slope deadband (σ)", minval = 0.0, maxval = 2.0, step = 0.05, group = gS, tooltip = "How strong the denoised slope (in noise-σ units) must be to count as up/down rather than flat — a deadband so the trend state doesn't flip on tiny wiggles.")
structThr   = input.int(25, "Structure ON at/below (noise pctile)", minval = 5, maxval = 50, group = gS, tooltip = "Noise-fraction percentile at or below which the tape ENTERS the STRUCTURE state — low noise, trend worth acting on.")
structOff   = input.int(40, "Structure OFF above (noise pctile)", minval = 15, maxval = 70, group = gS, tooltip = "Hysteresis: once in the STRUCTURE state the tape stays there until noise rises above this percentile — so structure (and the signals it gates) doesn't flicker on/off as noise oscillates around the ON threshold.")
chopThr     = input.int(75, "Chop at/above (noise pctile)", minval = 50, maxval = 95, group = gS, tooltip = "Noise-fraction percentile at or above which the tape counts as CHOP — stand aside.")
showChopMark= input.bool(true, "Mark unconfirmed turns in chop", group = gS, tooltip = "Small grey dot when the slope turns while the tape is choppy — a turn happened, but noise is high so it is NOT confirmed.")
showRibbon  = input.bool(true, "Chop/structure ribbon (bottom)", group = gS, tooltip = "A heat-strip along the bottom of the chart: green when structure (low noise, trend trustworthy), red when chop (high noise, stand aside).")

int N = int(math.pow(2, winExp))     // window length (power of two)

// ═════════════════════════ HELPERS ══════════════════════════════════════════════════════════════
f_median(float[] arr) =>
    int n = array.size(arr)
    float m = na
    if n > 0
        cp = array.copy(arr)
        array.sort(cp, order.ascending)
        m := n % 2 == 1 ? array.get(cp, int(n / 2)) : (array.get(cp, int(n / 2) - 1) + array.get(cp, int(n / 2))) / 2.0
    m

// forward orthonormal Haar DWT, in place. Layout after: a[0]=scaling · a[1..M-1]=details (coarse→fine,
// finest = a[M/2 .. M-1]).
f_fdwt(float[] a, int M) =>
    float rt = math.sqrt(2.0)
    int len = M
    while len > 1
        int half = int(len / 2)
        tmp = array.new_float(len, 0.0)
        for i = 0 to half - 1
            float x0 = array.get(a, 2 * i)
            float x1 = array.get(a, 2 * i + 1)
            array.set(tmp, i,        (x0 + x1) / rt)
            array.set(tmp, half + i, (x0 - x1) / rt)
        for i = 0 to len - 1
            array.set(a, i, array.get(tmp, i))
        len := half
    a

// inverse Haar DWT, in place (exact inverse of f_fdwt).
f_idwt(float[] a, int M) =>
    float rt = math.sqrt(2.0)
    int len = 2
    while len <= M
        int half = int(len / 2)
        tmp = array.new_float(len, 0.0)
        for i = 0 to half - 1
            float s = array.get(a, i)
            float d = array.get(a, half + i)
            array.set(tmp, 2 * i,     (s + d) / rt)
            array.set(tmp, 2 * i + 1, (s - d) / rt)
        for i = 0 to len - 1
            array.set(a, i, array.get(tmp, i))
        len := len * 2
    a

// full denoise over the trailing N-bar window → [endpoint, noiseSigma(price), noiseFraction]
f_denoise(simple int n, float mult, bool soft, bool pad) =>
    float endpt = na
    float sig   = na
    float nf    = na
    if not na(srcW[n - 1])
        int M = pad ? n * 2 : n
        a = array.new_float(M, 0.0)
        for i = 0 to n - 1
            float px = srcW[n - 1 - i]        // i = 0 oldest … i = n-1 newest (current bar)
            array.set(a, i, px)
            if pad
                array.set(a, 2 * n - 1 - i, px)   // mirror for symmetric reflection
        f_fdwt(a, M)
        // noise scale from the finest-level detail coefficients a[M/2 .. M-1]
        dets = array.new_float(int(M / 2), 0.0)
        for i = 0 to int(M / 2) - 1
            array.set(dets, i, array.get(a, int(M / 2) + i))
        float med = f_median(dets)
        adev = array.new_float(int(M / 2), 0.0)
        for i = 0 to int(M / 2) - 1
            array.set(adev, i, math.abs(array.get(dets, i) - med))
        float mad = f_median(adev)
        sig := mad / 0.6745
        float lambda = sig * math.sqrt(2.0 * math.log(M)) * mult
        // shrink every detail coefficient (index 1..M-1); keep the scaling coefficient a[0]
        for i = 1 to M - 1
            float d = array.get(a, i)
            float nd = soft ? math.sign(d) * math.max(math.abs(d) - lambda, 0.0) : (math.abs(d) >= lambda ? d : 0.0)
            array.set(a, i, nd)
        f_idwt(a, M)
        endpt := array.get(a, n - 1)          // current bar = index n-1
        // noise fraction over the window = 1 − var(denoised)/var(raw)
        float sr  = 0.0
        float sr2 = 0.0
        float sd  = 0.0
        float sd2 = 0.0
        for i = 0 to n - 1
            float rv = srcW[n - 1 - i]
            float dv = array.get(a, i)
            sr  += rv
            sr2 += rv * rv
            sd  += dv
            sd2 += dv * dv
        float varR = sr2 / n - math.pow(sr / n, 2.0)
        float varD = sd2 / n - math.pow(sd / n, 2.0)
        nf := varR > 0 ? math.max(0.0, math.min(1.0, 1.0 - varD / varR)) : na
    [endpt, sig, nf]

// ═════════════════════════ COMPUTE ══════════════════════════════════════════════════════════════
[denoised, noiseSig, noiseFrac] = f_denoise(N, thrMult, thrMode == "Soft", padOn)

float lambdaShown = na(noiseSig) ? na : noiseSig * math.sqrt(2.0 * math.log(padOn ? N * 2 : N)) * thrMult
float slopePx  = denoised - denoised[slopeLen]
float slopeSig = (na(slopePx) or na(noiseSig) or noiseSig <= 0) ? na : slopePx / noiseSig    // trend move in σ units
float nfRank   = ta.percentrank(noiseFrac, nfLen)

// ═════════════════════════ REGIME · SIGNALS · SIGNAL-TO-NOISE ═══════════════════════════════════
// STRUCTURE with hysteresis: enters at structThr, stays until noise rises above structOff — so the
// gated signals don't re-fire as noise oscillates around the ON threshold.
float structOn2  = structThr
float structOff2 = math.max(structOff, structThr + 1.0)
var bool structure = false
if not na(nfRank)
    structure := structure ? (nfRank <= structOff2) : (nfRank <= structOn2)
bool chop      = not na(nfRank) and nfRank >= chopThr          // high noise — stand aside
// trend state with a deadband hysteresis (holds until slope clears the opposite deadband)
var int trendState = 0
if not na(slopeSig)
    trendState := slopeSig > slopeThr ? 1 : slopeSig < -slopeThr ? -1 : trendState
bool turnUp = trendState == 1  and trendState[1] != 1
bool turnDn = trendState == -1 and trendState[1] != -1
// gated stance (persistent): +1 up·structure, −1 down·structure, 0 in chop / flat / unconfirmed
float stance = (structure and trendState > 0) ? 1.0 : (structure and trendState < 0) ? -1.0 : 0.0
// a signal fires when the gated stance flips — i.e. the slope turns in structure, OR structure
// returns while the trend is still valid (a clean re-engage). Self-suppresses in chop (stance = 0).
bool sigUp    = showSignals and stance ==  1.0 and stance[1] !=  1.0
bool sigDn    = showSignals and stance == -1.0 and stance[1] != -1.0
bool turnChop = showSignals and showChopMark and (turnUp or turnDn) and chop
// signal-to-noise trend strength: slope (in σ) scaled by the structure share (1 − noise fraction)
float snr   = (na(slopeSig) or na(noiseFrac)) ? na : slopeSig * (1.0 - noiseFrac)
// ±1 noise-σ envelope around the denoised line
float envUp = (na(denoised) or na(noiseSig)) ? na : denoised + noiseSig
float envDn = (na(denoised) or na(noiseSig)) ? na : denoised - noiseSig

// ═════════════════════════ PLOTS ════════════════════════════════════════════════════════════════
color trendCol = na(slopeSig) ? colFlat : slopeSig > 0.15 ? colUp : slopeSig < -0.15 ? colDn : colFlat
bool  inProv   = bar_index > last_bar_index - provLen
color lineCol  = inProv ? color.new(trendCol, 55) : trendCol      // recent = faded / provisional

pDen  = plot(denoised, "Denoised trend", color = lineCol, linewidth = 2)
pEnvU = plot(showBand ? envUp : na, "Noise env +σ", color = color.new(trendCol, 78))
pEnvD = plot(showBand ? envDn : na, "Noise env −σ", color = color.new(trendCol, 78))
fill(pEnvU, pEnvD, color = showBand ? color.new(trendCol, 92) : na, title = "Noise envelope")

// chop/structure heat-ribbon along the BOTTOM of the price pane (green = structure, red = chop)
color ribCol = na(nfRank) ? na : color.from_gradient(nfRank, 0.0, 100.0, colUp, colDn)
plotchar(showRibbon, "Chop/structure ribbon", "█", location.bottom, ribCol, size = size.small)

// structure-gated trend signals (self-suppress in chop) + unconfirmed-in-chop caution dots
plotshape(sigUp,    "Trend up · structure",       shape.triangleup,   location.belowbar, colUp,                   size = size.small)
plotshape(sigDn,    "Trend down · structure",     shape.triangledown, location.abovebar, colDn,                   size = size.small)
plotshape(turnChop, "Turn in chop (unconfirmed)", shape.circle,       location.belowbar, color.new(colFlat, 25),  size = size.tiny)

// mark where the provisional zone begins
plotshape(provLen > 0 and bar_index == last_bar_index - provLen ? denoised : na, "Provisional start", shape.circle, location.absolute, color.new(colFlat, 20), size = size.tiny)

// ═════════════════════════ THEME (background-adaptive) ══════════════════════════════════════════
f_lum(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
bool darkUI   = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color cUp2    = darkUI ? colUp : color.rgb(14, 124, 90)
color cDn2    = darkUI ? colDn : color.rgb(198, 40, 64)

f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

// ═════════════════════════ DASHBOARD ═══════════════════════════════════════════════════════════
var table t = table.new(f_pos(panelPos), 2, 10, frame_width = 1, border_width = 1)
f_row(int r, string k, string v, color vc, color bg) =>
    table.cell(t, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, v, text_color = vc,     text_size = size.small, text_halign = text.align_right, bgcolor = bg)

if showPanel and barstate.islast
    table.set_bgcolor(t, panelBg)
    table.set_frame_color(t, frameC)
    table.set_border_color(t, frameC)
    color nfCol = na(noiseFrac) ? color.gray : color.from_gradient(noiseFrac, 0.0, 1.0, cUp2, cDn2)
    color hdrTxt = f_lum(nfCol) > 140 ? color.rgb(10, 10, 10) : color.white
    string headline = na(noiseFrac) ? "warming" : "Noise " + str.tostring(noiseFrac * 100.0, "0") + "% · slope " + (na(slopeSig) ? "—" : (slopeSig >= 0 ? "+" : "") + str.tostring(slopeSig, "0.0") + "σ")
    string slopeTxt = na(slopeSig) ? "—" : (slopeSig >= 0 ? "+" : "") + str.tostring(slopeSig, "0.00") + "σ  " + (slopeSig > slopeThr ? "up" : slopeSig < -slopeThr ? "down" : "flat")
    string readTxt  = (na(slopeSig) or na(nfRank)) ? "warming" : chop ? "chop — stand aside" : structure ? (trendState > 0 ? "up-trend · structure ✓" : trendState < 0 ? "down-trend · structure ✓" : "flat · structure") : (trendState > 0 ? "up (unconfirmed)" : trendState < 0 ? "down (unconfirmed)" : "neutral")
    color  readCol  = (na(slopeSig) or na(nfRank)) ? txtMut : chop ? cDn2 : (structure and trendState > 0) ? cUp2 : (structure and trendState < 0) ? cDn2 : txtMain
    string snrTxt   = na(snr) ? "—" : (snr >= 0 ? "+" : "") + str.tostring(snr, "0.00")

    table.cell(t, 0, 0, "WAVELET", text_color = hdrTxt, bgcolor = nfCol, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 0, headline, text_color = hdrTxt, bgcolor = nfCol, text_size = size.small, text_halign = text.align_right)
    f_row(1, "Read", readTxt, readCol, rowAlt)
    f_row(2, "Noise fraction", na(noiseFrac) ? "warming" : str.tostring(noiseFrac * 100.0, "0") + "% of variance" + (nfRank >= chopThr ? "  ⚠ chop" : nfRank <= structThr ? "  structure" : ""), noiseFrac >= 0.7 ? cDn2 : noiseFrac <= 0.4 ? cUp2 : txtMain, panelBg)
    f_row(3, "Trend slope", slopeTxt, na(slopeSig) ? txtMut : slopeSig > slopeThr ? cUp2 : slopeSig < -slopeThr ? cDn2 : colFlat, rowAlt)
    f_row(4, "Trend strength (SNR)", snrTxt, na(snr) ? txtMut : snr > 0.2 ? cUp2 : snr < -0.2 ? cDn2 : txtMain, panelBg)
    f_row(5, "Noise σ (price)", na(noiseSig) ? "—" : str.tostring(noiseSig, format.mintick), txtMain, rowAlt)
    f_row(6, "Threshold λ", na(lambdaShown) ? "—" : str.tostring(lambdaShown, format.mintick), txtMain, panelBg)
    f_row(7, "Window / wavelet", str.tostring(N) + " · Haar · " + (padOn ? "reflected" : "no pad"), txtSub, rowAlt)
    f_row(8, "Boundary reliability", provLen == 0 ? "no provisional zone" : "last " + str.tostring(provLen) + " bars provisional", txtMut, panelBg)
    f_row(9, "Note", "strictly causal · gated · not advice", txtMut, rowAlt)

// ═════════════════════════ EXPORTS (Data Window) ═══════════════════════════════════════════════
color exC = color.new(color.gray, 100)
plot(denoised,  "EXP_Denoised",   exC, display = display.data_window)
plot(noiseSig,  "EXP_NoiseSigma", exC, display = display.data_window)
plot(noiseFrac, "EXP_NoiseFrac",  exC, display = display.data_window)
plot(slopeSig,  "EXP_Slope",      exC, display = display.data_window)
plot(snr,       "EXP_SNR",        exC, display = display.data_window)   // signal-to-noise trend strength
plot(stance,    "EXP_Stance",     exC, display = display.data_window)   // +1 up·structure / −1 down·structure / 0

// ═════════════════════════ ALERTS ═══════════════════════════════════════════════════════════════
alertcondition(ta.crossover(nfRank, 75.0),  "Noise fraction top quartile",    "Wavelet: noise fraction entered its top quartile — chop, treat breakouts with care.")
alertcondition(ta.crossunder(nfRank, 25.0), "Noise fraction bottom quartile", "Wavelet: noise fraction entered its bottom quartile — structure present, less noise.")
alertcondition(ta.crossover(slopeSig, 0.0),  "Denoised slope turned up",   "Wavelet: denoised trend slope crossed above zero.")
alertcondition(ta.crossunder(slopeSig, 0.0), "Denoised slope turned down", "Wavelet: denoised trend slope crossed below zero.")
alertcondition(sigUp, "Confirmed up-trend (structure)",   "Wavelet: denoised slope turned up with structure present (low noise) — trend worth acting on.")
alertcondition(sigDn, "Confirmed down-trend (structure)", "Wavelet: denoised slope turned down with structure present (low noise) — trend worth acting on.")
````
