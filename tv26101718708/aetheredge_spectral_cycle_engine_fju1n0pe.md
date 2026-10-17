# AetherEdge - Spectral Cycle Engine

- url: https://www.tradingview.com/script/FJu1N0Pe/
- type: indicator
- pine_id: PUB;33b34015d7214152b82a1fa4ef863894
- version: 1.0

## Description

🖊️ Overview

AE-SCE is a market frequency lens that exposes the cycles hiding inside price. It runs a Discrete Fourier Transform over a rolling window of linearly-detrended price, tracks the dominant cycle and its phase (rising/falling, bars-to-turn), reconstructs a denoised waveform from the strongest components and extrapolates it forward (Fourier projection), and paints a live spectrogram — period × time × amplitude — so you can watch cycles strengthen, fade, and migrate. The lens re-focuses every bar onto whichever cycles dominate now.

🔶 Key Features

DFT spectral engine — analyzes the frequency content (amplitude, phase, period) of a rolling window, quantifying the market's cyclical structure.
Dominant-cycle tracking — identifies the strongest period each bar and measures its strength (share of total spectrum).
Phase & turn forecast — from the dominant cycle's current phase, estimates rising/falling and "how many bars to the next peak/trough."
Fourier reconstruction + projection — rebuilds the waveform from the top-N components and extrapolates a forecast curve onto the chart.
Live spectrogram — a period (rows) × time (columns) × amplitude (color) heatmap, revealing the rise, fall, and migration of cycles at a glance.
Adaptive focus — rolling re-estimation keeps the lens trained on the current dominant cycle.
Live statistics panel — dominant period, strength, phase (turn forecast), projected return, and components used.
Efficient design — the trig basis is precomputed once, and the heavy transform runs only on the last bar, staying within Pine's runtime budget.

🧠 Technical Architecture

On each last bar, the newest length-N window is linearly detrended via least squares, and a DFT is applied to the residual. For each bin k=1..N/2 it computes real and imaginary parts, then amplitude A_k = (2/N)√(Re²+Im²), phase φ_k = atan2(Im,Re), and period T_k = N/k. The highest-amplitude bin within the displayed band is the dominant cycle, its strength measured as A* / ΣA. Reconstruction is the sum of the top-N components Σ A_k·cos(2πkm/N − φ_k) plus the linear trend; extending m beyond the window turns it into a forward projection.
The spectrogram applies the same transform to several windows shifted back by a stride, encoding each time-and-period amplitude as color. The phase-based turn forecast derives the dominant cycle's phase angle at the newest bar and converts the phase distance to a peak (cos=1) or trough (cos=−1) into bars. To keep it light, the cos/sin basis matrices are built once and reused, and the DFT itself runs only on the last bar. This is a spectral-analysis tool — not a learning model — that adapts to "the cycle of now" through rolling re-estimation.

🎯 Three design choices stand out. First, linear detrending suppresses trend leakage (spectral leakage), letting genuine cycles surface. Second, retaining phase lets it report not just amplitude but where in the cycle price sits. Third, the precomputed basis and last-bar concentration completely avoid the cost of recomputing across all history.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — BTC/ETH (1D, 4H): window N = 64, 5 reconstruction components, spectrogram 16×20, stride 4, horizon 16; medium-to-long cyclical structure separates cleanly. High-volatility / short-term (SOL, XRP): shorten N toward 48 for faster response to shorter cycles, and narrow components to 3–4 to avoid pulling in noise, yielding a cleaner forecast curve.
Per parameter: Window (N) is the key — larger resolves longer cycles but adds lag and load; smaller is nimbler but misses long cycles. Reconstruction components set forecast smoothness — fewer give a smooth dominant-cycle curve, more track finer detail. Stride / columns set how far the spectrogram reaches back. Horizon sets projection length.

💡 How to Use in Practice

The core read is dominant cycle × phase × strength. When cycle strength is high and the phase reads "few bars to trough," it flags a potential dip + cycle reversal — a timing cue. Conversely "few bars to peak" is a candidate for taking profit or fading rallies. By watching the forecast curve's slope and whether price tracks it, you can judge whether cycles are in control (i.e., forecast reliability is high). When the spectrogram shows the dominant cycle migrating or splitting, the cyclical structure is changing — a sign your assumptions may be shifting.
For multi-timeframe work, read the larger cycle's phase on the higher timeframe and use shorter-cycle turns on the lower timeframe for execution. Pair it with trend tools and de-weight cycle forecasts when trends are strong.

⚠️ Important Notes

Nothing displays until warmup (window + spectrogram reach-back) completes. Fourier extrapolation assumes cycles persist, so forecast reliability drops sharply in strong trends or at structural breaks (regime changes). The reconstruction/forecast curve is redrawn every bar from the current spectrum and is not a frozen historical fit — it updates as new bars arrive. Spectral leakage from the finite window is mitigated by detrending, but cycles are not strictly stationary. Large windows or many columns over long history increase compute. This is a forecasting tool, not a certain future.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Spectral Cycle Engine   ( AE-SCE )
// ----------------------------------------------------------------------------
//  A market frequency lens. It runs a Discrete Fourier Transform over a rolling
//  window of linearly-detrended price to expose the cycles hiding inside the
//  noise, then:
//    - tracks the DOMINANT cycle and its phase (rising/falling, bars-to-turn),
//    - reconstructs a denoised waveform from the strongest components and
//      EXTRAPOLATES it forward (Fourier projection),
//    - paints a live SPECTROGRAM (period x time x amplitude) so you can watch
//      cycles strengthen, fade and migrate over time.
//  The lens re-focuses every bar onto whichever cycles dominate now. The trig
//  basis is precomputed ONCE; the heavy transform runs only on the last bar,
//  so the script stays well within Pine's runtime budget. This is a signal-
//  processing tool (spectral analysis), not a learning model.
// ============================================================================
indicator("AetherEdge - Spectral Cycle Engine", "AE-SCE", overlay = true, max_polylines_count = 50, max_labels_count = 50)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Spectrum ---
var string gS = "Spectrum"
src   = input.source(close, "Source", group = gS)
N     = input.int(64, "Window (N bars)", minval = 16, maxval = 128, group = gS, tooltip = "DFT window length. Larger resolves longer cycles but is heavier and laggier.")
nComp = input.int(5,  "Reconstruction Components", minval = 1, maxval = 10, group = gS, tooltip = "Number of strongest frequency components used to rebuild & project the waveform.")

//  --- Spectrogram ---
var string gG = "Spectrogram"
KfreqRows = input.int(16, "Period Rows", minval = 6, maxval = 30, group = gG, tooltip = "How many period bins (rows) to display.")
Ktime     = input.int(20, "Time Columns", minval = 5, maxval = 40, group = gG, tooltip = "How many past spectra (columns) to display.")
stride    = input.int(4,  "Column Stride (bars)", minval = 1, group = gG)

//  --- Projection ---
var string gP = "Projection"
H = input.int(16, "Forecast Horizon", minval = 2, maxval = 60, group = gP)

//  --- Display ---
var string gD = "Display"
upCol     = input.color(#26ffe6, "Up", group = gD)
dnCol     = input.color(#ff2e88, "Down", group = gD)
neutCol   = input.color(#8892b0, "Neutral", group = gD)
accent    = input.color(#aeffff, "Accent", group = gD)
showFit   = input.bool(true,  "Reconstruction (fit)", group = gD)
showFc    = input.bool(true,  "Forward Projection",   group = gD)
showGlow  = input.bool(true,  "Neon Glow",            group = gD)
showSpec  = input.bool(true,  "Spectrogram",          group = gD)
specPos   = input.string("Bottom Right", "Spectrogram Position", options = ["Bottom Right", "Bottom Left", "Top Right", "Top Left", "Middle Right"], group = gD)
showDash  = input.bool(true,  "Dashboard",            group = gD)
dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
EPS  = 1e-12
TWO_PI = 2.0 * math.pi
half = int(math.floor(N / 2))
displayRows = math.min(KfreqRows, half)

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

f_atan2(float y, float x) =>
    x > 0 ? math.atan(y / x) : x < 0 and y >= 0 ? math.atan(y / x) + math.pi : x < 0 and y < 0 ? math.atan(y / x) - math.pi : x == 0 and y > 0 ? math.pi / 2.0 : x == 0 and y < 0 ? -math.pi / 2.0 : 0.0

// dark -> blue -> teal heat ramp
f_heat(float t) =>
    float tt = math.max(math.min(t, 1.0), 0.0)
    tt < 0.5 ? color.from_gradient(tt, 0.0, 0.5, #0b0e16, #2a6cf0) : color.from_gradient(tt, 0.5, 1.0, #2a6cf0, #26ffe6)

ready = bar_index > N + Ktime * stride + 2

// ----------------------------------------------------------------------------
//  PRECOMPUTED DFT BASIS  ( built once : CT[k-1][n] = cos , ST[k-1][n] = sin )
// ----------------------------------------------------------------------------
var matrix<float> CT = matrix.new<float>(half, N, 0.0)
var matrix<float> ST = matrix.new<float>(half, N, 0.0)
var bool built = false
if not built
    for k = 1 to half
        for n = 0 to N - 1
            float ang = TWO_PI * k * n / N
            matrix.set(CT, k - 1, n, math.cos(ang))
            matrix.set(ST, k - 1, n, math.sin(ang))
    built := true

// ----------------------------------------------------------------------------
//  LAST-BAR ENGINE : transform, reconstruct, project, render
// ----------------------------------------------------------------------------
var array<polyline> pls = array.new<polyline>()
var label endLab = na
var table spec = table.new(position = f_pos(specPos), columns = Ktime + 1, rows = displayRows + 1, bgcolor = color.new(#0b0e16, 0), frame_color = color.new(upCol, 50), frame_width = 1, border_color = color.new(#0b0e16, 100), border_width = 0)
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 9, bgcolor = color.new(#0b0e16, 15), frame_color = color.new(upCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)

if barstate.islast and ready
    // clear previous drawings
    if array.size(pls) > 0
        for pl in pls
            polyline.delete(pl)
        array.clear(pls)
    label.delete(endLab)

    // ---- detrend the newest window (n=0 oldest ... N-1 newest) ----
    array<float> resid = array.new<float>(N, 0.0)
    float sS = 0.0
    float sNS = 0.0
    for n = 0 to N - 1
        float sv = src[N - 1 - n]
        sS += sv
        sNS += n * sv
    float sN  = N * (N - 1) / 2.0
    float sNN = (N - 1) * N * (2 * N - 1) / 6.0
    float bFit = (N * sNS - sN * sS) / (N * sNN - sN * sN + EPS)
    float aFit = (sS - bFit * sN) / N
    for n = 0 to N - 1
        array.set(resid, n, src[N - 1 - n] - (aFit + bFit * n))

    // ---- DFT of the newest window ----
    array<float> ampA = array.new<float>(half + 1, 0.0)
    array<float> phA  = array.new<float>(half + 1, 0.0)
    for k = 1 to half
        float re = 0.0
        float im = 0.0
        for n = 0 to N - 1
            float r = array.get(resid, n)
            re += r * matrix.get(CT, k - 1, n)
            im += r * matrix.get(ST, k - 1, n)
        array.set(ampA, k, 2.0 / N * math.sqrt(re * re + im * im))
        array.set(phA, k, f_atan2(im, re))

    // ---- dominant cycle (within displayed period range) ----
    int   kStar = 1
    float aStar = -1.0
    float ampSum = EPS
    for k = 1 to displayRows
        float a = array.get(ampA, k)
        ampSum += a
        if a > aStar
            aStar := a
            kStar := k
    float domPeriod = N / (kStar * 1.0)
    float strength = aStar / ampSum

    // ---- pick top-nComp components for reconstruction ----
    array<int> chK = array.new<int>(0)
    array<float> tmp = array.copy(ampA)
    for c = 0 to nComp - 1
        int bk = 1
        float bv = -1.0
        for k = 1 to half
            if array.get(tmp, k) > bv
                bv := array.get(tmp, k)
                bk := k
        if bv <= 0.0
            break
        array.push(chK, bk)
        array.set(tmp, bk, -1.0)

    // ---- reconstruction + forward projection values ----
    array<float> recVals = array.new<float>(N + H, 0.0)
    for stepM = 0 to N + H - 1
        float val = aFit + bFit * stepM
        for idx = 0 to array.size(chK) - 1
            int k = array.get(chK, idx)
            val += array.get(ampA, k) * math.cos(TWO_PI * k * stepM / N - array.get(phA, k))
        array.set(recVals, stepM, val)
    float reconEnd = array.get(recVals, N + H - 1)
    float projPct = (reconEnd / close - 1.0) * 100.0
    color dirCol = projPct > 0.0 ? upCol : projPct < 0.0 ? dnCol : neutCol

    // ---- draw reconstruction (fit) and forward projection ----
    if showFit
        array<chart.point> fit = array.new<chart.point>()
        for stepM = 0 to N - 1
            array.push(fit, chart.point.from_index(bar_index - (N - 1) + stepM, array.get(recVals, stepM)))
        array.push(pls, polyline.new(points = fit, closed = false, curved = true, xloc = xloc.bar_index, line_color = color.new(neutCol, 35), line_width = 1))
    if showFc
        array<chart.point> fc = array.new<chart.point>()
        for stepM = N - 1 to N + H - 1
            array.push(fc, chart.point.from_index(bar_index - (N - 1) + stepM, array.get(recVals, stepM)))
        if showGlow
            array.push(pls, polyline.new(points = fc, closed = false, curved = true, xloc = xloc.bar_index, line_color = color.new(dirCol, 70), line_width = 6))
        array.push(pls, polyline.new(points = fc, closed = false, curved = true, xloc = xloc.bar_index, line_color = dirCol, line_width = 2))
        string arrow = projPct >= 0 ? "▲" : "▼"
        endLab := label.new(x = bar_index + H, y = reconEnd, text = arrow + " " + (projPct >= 0 ? "+" : "") + str.tostring(projPct, "#.##") + "%  ·  T " + str.tostring(math.round(domPeriod)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(dirCol, 15), textcolor = #0b0e16, size = size.small)

    // ---- dominant cycle phase / next turn ----
    float theta = TWO_PI * kStar * (N - 1) / N - array.get(phA, kStar)
    float thetam = theta - TWO_PI * math.floor(theta / TWO_PI)
    bool  rising = math.sin(thetam) < 0.0
    float dPeak = domPeriod * (1.0 - thetam / TWO_PI)
    float gT = (math.pi - thetam) / TWO_PI
    gT := gT - math.floor(gT)
    float dTrough = domPeriod * gT

    // ---- spectrogram ----
    if showSpec
        array<float> specVals = array.new<float>(displayRows * Ktime, 0.0)
        float maxAmp = EPS
        for j = 0 to Ktime - 1
            int off = j * stride
            float jS = 0.0
            float jNS = 0.0
            for n = 0 to N - 1
                float sv = src[off + (N - 1 - n)]
                jS += sv
                jNS += n * sv
            float jb = (N * jNS - sN * jS) / (N * sNN - sN * sN + EPS)
            float ja = (jS - jb * sN) / N
            array<float> jr = array.new<float>(N, 0.0)
            for n = 0 to N - 1
                array.set(jr, n, src[off + (N - 1 - n)] - (ja + jb * n))
            for k = 1 to displayRows
                float re = 0.0
                float im = 0.0
                for n = 0 to N - 1
                    float r = array.get(jr, n)
                    re += r * matrix.get(CT, k - 1, n)
                    im += r * matrix.get(ST, k - 1, n)
                float amp = 2.0 / N * math.sqrt(re * re + im * im)
                array.set(specVals, (k - 1) * Ktime + j, amp)
                maxAmp := math.max(maxAmp, amp)
        // header
        table.cell(spec, 0, 0, "per", text_color = neutCol, bgcolor = #0b0e16, text_size = size.tiny, text_halign = text.align_center)
        for c = 1 to Ktime
            table.cell(spec, c, 0, c == Ktime ? "now" : "", text_color = accent, bgcolor = #0b0e16, text_size = size.tiny, text_halign = text.align_center)
        // rows (period bins) x columns (time slices)
        for r = 0 to displayRows - 1
            int k = r + 1
            bool isDom = k == kStar
            table.cell(spec, 0, r + 1, str.tostring(math.round(N / (k * 1.0))), text_color = isDom ? accent : neutCol, bgcolor = isDom ? color.new(accent, 80) : #0b0e16, text_size = size.tiny, text_halign = text.align_center)
            for j = 0 to Ktime - 1
                float amp = array.get(specVals, r * Ktime + j)
                int col = Ktime - j
                table.cell(spec, col, r + 1, "", bgcolor = f_heat(amp / maxAmp), text_size = size.tiny)

    // ---- dashboard ----
    if showDash
        color rowBg = color.new(#11151f, 10)
        color hdrBg = #0b0e16
        color turnCol = rising ? upCol : dnCol
        string turnTxt = rising ? "▲ peak in " + str.tostring(math.round(dPeak)) + "b" : "▼ trough in " + str.tostring(math.round(dTrough)) + "b"
        table.cell(dash, 0, 0, "AE · SCE",   text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
        table.cell(dash, 1, 0, "● ACTIVE",   text_color = upCol,   bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 1, "Dom. Cycle", text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 1, str.tostring(math.round(domPeriod)) + " bars", text_color = accent, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 2, "Strength",   text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 2, str.tostring(strength * 100, "#") + "%", text_color = color.from_gradient(strength, 0.0, 0.6, neutCol, upCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 3, "Phase",      text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 3, turnTxt,      text_color = turnCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 4, "Forecast",   text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 4, (projPct >= 0 ? "+" : "") + str.tostring(projPct, "#.##") + "%", text_color = dirCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 5, "Components", text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 5, str.tostring(array.size(chK)) + " / " + str.tostring(half), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 6, "Window",     text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 6, str.tostring(N) + " bars", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 7, "Spectrogram", text_color = neutCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, 7, str.tostring(displayRows) + "×" + str.tostring(Ktime), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 8, "Horizon",    text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 8, str.tostring(H) + " bars", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
````
