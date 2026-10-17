# Kalman + CUSUM Segmentation

- url: https://www.tradingview.com/script/KbnUvf43/
- type: indicator
- pine_id: PUB;45199f0c9b684f88bfa8e878728d6d68
- version: 3.0

## Description

This indicator segments price with a model-based online change detector. A Kalman local-level filter estimates a drifting mean, shown as the orange line, and each bar it produces the one-step innovation, the gap between price and what the filter expected. That innovation is standardized by its own recursively estimated variance, and two CUSUM detectors watch it: one for a shift in the mean, one for a shift in dispersion, meaning volatility. When either crosses the threshold h the mean has structurally changed, so a new segment is cut and the accumulators reset. After a cut the Kalman covariance is briefly inflated so the mean re-adapts faster to the new level. The shaded background alternates per segment so boundaries are easy to read.
Around the mean is a Bollinger-style channel, except the center is the adaptive Kalman mean rather than a moving average, so it tracks trends with less lag. The z value in the panel is simply how many standard deviations price sits from that mean. The panel also shows both CUSUM values against their threshold and the length of the current segment in bars.
Inputs. Smoothness Q/R sets how tightly the Kalman mean follows price; only the ratio matters, so it behaves the same across instruments and price scales, and it is the knob for mean responsiveness. CUSUM threshold h is the main sensitivity knob and behaves like the penalty in change-point methods: raise it for fewer, larger cuts, lower it for more frequent cuts. CUSUM slack k is the standard allowance value, set to target a one-sigma shift. The dispersion CUSUM can be switched off for mean-only segmentation. The EWMA decay lambda controls the variance memory, with 0.94 being the RiskMetrics daily standard.
Scope. This is an online, causal detector: it only sees the past. It is a distinct model-based detector, not a substitute for globally optimal offline methods such as PELT run in Python or R, which place breakpoints more accurately in hindsight. Treat the segments and the z value as context, not as trade signals.
The method follows standard Kalman-residual CUSUM change detection (Kalman 1960; Page 1954; Mehra and Peschon 1971; Severo and Gama 2010; RiskMetrics 1996).

## Source Code

````pine
//@version=6
// =============================================================================
// Kalman + CUSUM Segmentation -- online change detection (final-spec port)
//
// Lightweight sibling of "SegLR + VP + Regime (six-state)": same segmentation
// core, no profiles, no state grid -- just segments plus a Kalman channel.
// Detection constants are duplicated across the two scripts; keep them in
// sync manually.
//
// PIPELINE
//   1. Kalman LOCAL LINEAR TREND (level + slope) whitens price [Harvey 1989];
//      R is fixed at 1 so only the noise ratios matter.
//   2. Innovations are standardized by an EWMA variance
//      [RiskMetrics 1996; Mehra & Peschon 1971].
//   3. A two-sided CUSUM on the standardized innovation mean -- minimax-
//      optimal causal detection [Page 1954; Moustakides 1986] -- declares
//      cuts, BACKDATED to the run start of the winning statistic, the
//      classical change-point estimate [Hinkley 1971].
//   4. A second CUSUM on (z^2-1)/sqrt(2) watches volatility shifts; always
//      running, optionally also cutting [Severo & Gama 2010].
//   5. Cuts closing a segment shorter than the minimum are discarded and
//      merged -- THE lever against tiny segments; it does not touch
//      detection sensitivity.
//   6. After an accepted cut the Kalman covariance is inflated so the filter
//      re-adapts faster [Severo & Gama 2010].
//   7. The threshold h is data-derived by default: a feedback controller
//      nudges h until the realized average segment length matches your
//      target -- you supply the intuition (how long a regime should be),
//      the data supplies the number. Fixed-h fallback available; at k = 0.5,
//      ARL0 is roughly 168 at h = 4 and 465 at h = 5.
//
// NON-REPAINT: decisions run on confirmed bars only; divider lines are drawn
// once at the backdated cut and never moved. Detection delay is irreducible
// for any causal detector [Lorden 1971]. A globally optimal offline method
// (e.g. PELT) places breakpoints more accurately in hindsight -- treat
// segments as context, not trade signals.
// =============================================================================
indicator("Kalman + CUSUM Segmentation", "K+CUSUM Seg", overlay = true, max_lines_count = 500)

// ---------------------------------------------------------------- inputs ---
grpM = "Detection model"
src        = input.source(close, "Source", group = grpM)
qLevel     = input.float(0.05,  "Level noise ratio Q_level/R", minval = 0.00001, step = 0.01, group = grpM,
     tooltip = "Process noise of the Kalman level state. Higher = level tracks price faster.")
qSlope     = input.float(0.005, "Slope noise ratio Q_slope/R", minval = 0.000001, step = 0.001, group = grpM,
     tooltip = "Process noise of the slope state. Higher = slope drifts freely, fewer cuts; lower = more sensitive to trend turns.")
ewmaLambda = input.float(0.97,  "EWMA variance memory (lambda)", minval = 0.8, maxval = 0.999, step = 0.005, group = grpM,
     tooltip = "Recursive innovation/residual variance (RiskMetrics). Higher = smoother and slower; also sizes the channel bands.")
warmupBars = input.int(30, "Warm-up bars", minval = 10, group = grpM)

grpC = "CUSUM"
cusumK    = input.float(0.5, "Allowance k (sigma)", minval = 0.0, step = 0.1, group = grpC,
     tooltip = "Reference value (Page 1954): k = half the target shift in sigma units. 0.5 targets a 1-sigma mean shift -- the textbook default.")
autoH     = input.bool(true, "Derive threshold h from target segment length", group = grpC,
     tooltip = "ON: you state the segment length you want; a feedback controller nudges h bar-by-bar until the realized average matches it (single pass, converges toward the end). OFF: use the fixed h below.")
targetSeg = input.int(30, "Target average segment length (bars)", minval = 5, group = grpC,
     tooltip = "Auto mode only. The data solves for the h that yields this average.")
hFixed    = input.float(4.0, "Fixed threshold h", minval = 1.0, step = 0.5, group = grpC,
     tooltip = "Used only when auto mode is OFF. In sigma units.")
hInit     = input.float(4.0, "Auto: starting h", minval = 1.0, step = 0.5, group = grpC)
hGain     = input.float(0.02, "Auto: controller gain", minval = 0.001, maxval = 0.2, step = 0.005, group = grpC,
     tooltip = "How hard h reacts to the running length error. Higher = faster convergence but jumpier h.")
minSegLen = input.int(15, "Minimum segment length (bars)", minval = 3, group = grpC,
     tooltip = "THE lever for 'no tiny segments'. Any cut whose closed segment is shorter than this is discarded and merged into its neighbor. Raise this (not h) if small segments persist.")
volCut    = input.bool(false, "Volatility shift also cuts the segment", group = grpC,
     tooltip = "The variance CUSUM always runs (alerts, panel); this switch additionally lets its alarms split segments.")
covInflate = input.float(5.0, "Covariance inflation after a cut", minval = 1.0, step = 1.0, group = grpC,
     tooltip = "Adaptive feedback (Severo & Gama 2010): inflate Kalman uncertainty after an accepted cut so the filter re-adapts faster.")

grpD = "Display"
bandWidth    = input.float(2.0, "Band width (sigma)", minval = 0.1, step = 0.1, group = grpD)
showBands    = input.bool(true, "Show bands", group = grpD)
showDividers = input.bool(true, "Segment divider lines (vertical at each cut)", group = grpD,
     tooltip = "A vertical line at every backdated cut point -- the authoritative segment boundary.")
showPanel    = input.bool(false, "Status panel", group = grpD)

// ----------------------------------------------------------------- state ---
var float kLevel   = na
var float kSlope   = 0.0
var float p11      = 1.0
var float p12      = 0.0
var float p22      = 1.0
var float innovVar = na   // standardizes the CUSUM
var float residVar = na   // sizes the visual bands
var float cmUp = 0.0      // mean CUSUM, upward shift
var float cmDn = 0.0      // mean CUSUM, downward shift
var float cvUp = 0.0      // variance CUSUM, dispersion up
var float cvDn = 0.0      // variance CUSUM, dispersion down
var int runMUp = na       // run starts = backdated cut candidates
var int runMDn = na
var int runVUp = na
var int runVDn = na
var int   segStartBar = na
var float hLive      = na  // adaptive threshold
var float segLenEwma = na  // EWMA of accepted segment lengths
bool cutEvent      = false
bool volShiftEvent = false

// ------------------------------------------------------------- main loop ---
if barstate.isconfirmed
    if na(segStartBar)
        segStartBar := bar_index
        kLevel := src
        hLive := hInit

    // Kalman predict/update: F = [[1,1],[0,1]], H = [1,0], R = 1.
    float predLevel = kLevel + kSlope
    float p11p = p11 + 2.0 * p12 + p22 + qLevel
    float p12p = p12 + p22
    float p22p = p22 + qSlope
    float innov = src - predLevel
    float sPred = p11p + 1.0
    float g1    = p11p / sPred
    float g2    = p12p / sPred
    kLevel := predLevel + g1 * innov
    kSlope := kSlope + g2 * innov
    p11 := (1.0 - g1) * p11p
    p12 := (1.0 - g1) * p12p
    p22 := p22p - g2 * p12p

    innovVar := na(innovVar) ? innov * innov : ewmaLambda * innovVar + (1.0 - ewmaLambda) * innov * innov
    float zInnov = innovVar > 0 ? innov / math.sqrt(innovVar) : 0.0
    float resid = src - kLevel
    residVar := na(residVar) ? resid * resid : ewmaLambda * residVar + (1.0 - ewmaLambda) * resid * resid

    // Working CUSUM threshold: adaptive (auto) or fixed.
    float hWork = autoH ? nz(hLive, hInit) : hFixed

    if bar_index >= warmupBars
        // Mean CUSUM -> segment cuts (backdated).
        float prevUp = cmUp
        float prevDn = cmDn
        cmUp := math.max(0.0, cmUp + zInnov - cusumK)
        cmDn := math.max(0.0, cmDn - zInnov - cusumK)
        runMUp := cmUp > 0 and prevUp == 0 ? bar_index : cmUp == 0 ? int(na) : runMUp
        runMDn := cmDn > 0 and prevDn == 0 ? bar_index : cmDn == 0 ? int(na) : runMDn

        // Variance CUSUM (always on): alerts and panel, optional cuts.
        float dV = (zInnov * zInnov - 1.0) / math.sqrt(2.0)
        float prevVUp = cvUp
        float prevVDn = cvDn
        cvUp := math.max(0.0, cvUp + dV - cusumK)
        cvDn := math.max(0.0, cvDn - dV - cusumK)
        runVUp := cvUp > 0 and prevVUp == 0 ? bar_index : cvUp == 0 ? int(na) : runVUp
        runVDn := cvDn > 0 and prevVDn == 0 ? bar_index : cvDn == 0 ? int(na) : runVDn

        bool meanAlarm = cmUp > hWork or cmDn > hWork
        bool volAlarm  = cvUp > hWork or cvDn > hWork
        if volAlarm
            volShiftEvent := true
            if not volCut
                cvUp := 0.0
                cvDn := 0.0
                runVUp := int(na)
                runVDn := int(na)

        bool wantCut = meanAlarm or (volCut and volAlarm)
        if wantCut
            // Backdate the cut to the run start of the winning statistic.
            float best = -1.0
            int cutBar = na
            if cmUp > hWork and cmUp > best
                best := cmUp
                cutBar := runMUp
            if cmDn > hWork and cmDn > best
                best := cmDn
                cutBar := runMDn
            if volCut and cvUp > hWork and cvUp > best
                best := cvUp
                cutBar := runVUp
            if volCut and cvDn > hWork and cvDn > best
                best := cvDn
                cutBar := runVDn
            cutBar := na(cutBar) ? bar_index : cutBar
            cutBar := math.max(cutBar, segStartBar + 1)
            int closedLen = cutBar - segStartBar

            // Reset all accumulators whether or not the cut is accepted.
            cmUp := 0.0
            cmDn := 0.0
            cvUp := 0.0
            cvDn := 0.0
            runMUp := int(na)
            runMDn := int(na)
            runVUp := int(na)
            runVDn := int(na)

            if closedLen >= minSegLen
                cutEvent := true
                if showDividers
                    line.new(cutBar, high, cutBar, low, xloc = xloc.bar_index, extend = extend.both,
                         color = color.new(chart.fg_color, 40), style = line.style_dashed, width = 1)

                // Adaptive-h feedback: push h up when segments run short of
                // target, down when they run long.
                if autoH
                    segLenEwma := na(segLenEwma) ? closedLen : 0.1 * closedLen + 0.9 * segLenEwma
                    float err = (targetSeg - segLenEwma) / targetSeg  // >0 => too short => raise h
                    hLive := math.max(1.0, nz(hLive, hInit) + hGain * err * nz(hLive, hInit))

                segStartBar := cutBar
                p11 := p11 * covInflate
                p22 := p22 * covInflate

// -------------------------------------------------------------- rendering ---
float bandStd = math.sqrt(math.max(nz(residVar, 0.0), 0.0))
float zChan   = bandStd > 0 ? (src - kLevel) / bandStd : 0.0
plot(kLevel, "Kalman level", color = color.orange, linewidth = 2)
plot(showBands ? kLevel + bandWidth * bandStd : na, "Upper band", color = color.new(color.gray, 55))
plot(showBands ? kLevel - bandWidth * bandStd : na, "Lower band", color = color.new(color.gray, 55))

var table panel = table.new(position.top_right, 2, 4, border_width = 1)
if showPanel and barstate.islast
    color bg = color.new(color.gray, 30)
    string hShown = autoH ? str.tostring(nz(hLive, hInit), "#.##") + (na(segLenEwma) ? "" : " (~" + str.tostring(segLenEwma, "#") + "b)") : str.tostring(hFixed, "#.#")
    table.cell(panel, 0, 0, "Segment (bars)", text_color = color.white, bgcolor = bg)
    table.cell(panel, 1, 0, str.tostring(bar_index - nz(segStartBar, bar_index)), text_color = color.white, bgcolor = bg)
    table.cell(panel, 0, 1, "CUSUM / h", text_color = color.white, bgcolor = bg)
    table.cell(panel, 1, 1, str.tostring(math.max(cmUp, cmDn), "#.#") + " / " + hShown, text_color = color.white, bgcolor = bg)
    table.cell(panel, 0, 2, "CUSUM vol", text_color = color.white, bgcolor = bg)
    table.cell(panel, 1, 2, str.tostring(math.max(cvUp, cvDn), "#.#") + " / " + str.tostring(autoH ? nz(hLive, hInit) : hFixed, "#.#"), text_color = color.white, bgcolor = bg)
    table.cell(panel, 0, 3, "z (channel)", text_color = color.white, bgcolor = bg)
    table.cell(panel, 1, 3, str.tostring(zChan, "#.##"), text_color = color.white, bgcolor = bg)

// ---------------------------------------------------------------- alerts ---
alertcondition(cutEvent,      "Segment cut (backdated)", "K+CUSUM Seg: new segment cut ({{ticker}} {{interval}})")
alertcondition(volShiftEvent, "Volatility shift",        "K+CUSUM Seg: volatility shift ({{ticker}} {{interval}})")
````
