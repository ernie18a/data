# AetherEdge - Kalman State Filter

- url: https://www.tradingview.com/script/aIi6k14x/
- type: indicator
- pine_id: PUB;c5e5933cb67843c6b743b71dc5331ec4
- version: 1.0

## Description

🖊️ Overview

AE-KSF is a self-evolving state-space estimator that treats price as a hidden state. It models the true price as a **local linear trend — a level and a velocity — and recovers it from noisy observations with a Kalman filter. Critically, it does more than smooth: it carries the full uncertainty (covariance) of its estimate and projects it forward as a widening confidence cone. And because it estimates measurement noise online from the innovation stream, the Kalman gain self-tunes to every instrument and regime.

🔶 Key Features

A full Kalman filter engine — predict (x'=Fx, P'=FPF^T+Q) and update (x=x'+K(z−Hx')) run every bar, jointly estimating level and velocity.
Self-evolving adaptive noise — measurement noise R is estimated from the innovation stream, so the Kalman gain self-adjusts to volatility and noise level.
Uncertainty cone — the covariance is propagated forward into a probability cone that widens with confidence, visualizing how far the estimate can be trusted rather than a bare point line.
In-sample confidence band — a translucent ±σ band hugs the centerline, conveying current state uncertainty at a glance.
Velocity & trend strength — velocity (per-bar drift) and its signal-to-noise ratio (a t-statistic) quantify how certain the trend is.
Semantic coloring — centerline, band, and cone are auto-colored by velocity sign and confidence (Rising / Falling / Flat).
Live statistics panel — trend direction, velocity, trend strength, Kalman gain, estimated noise R, state uncertainty, and innovation.
Non-repainting design — state updates on confirmed bars only, with no look-ahead.

🧠 Technical Architecture

The state is two-dimensional — level p and velocity v. Transition F = [[1,1],[0,1]] (constant-velocity), observation H = [1,0] (level only). Each confirmed bar runs a predict step (advancing state and covariance P) and an update step (folding in the innovation z−Hx' through gain K). Observation is in log-price space by default, so the cone becomes multiplicative and asymmetric in price — a financially natural shape.
The heart of the self-evolution is adaptive noise estimation. An EMA tracks the squared innovation, and measurement noise is estimated as R ≈ EMA(innov²) − P'_position (floored). The filter thus dials its gain down in noisy phases (smoother) and up when structure is clear (snappier) — balancing itself. Process noise q is set as a ratio to that estimated R via the "Responsiveness" knob, auto-scaling to the instrument's noise level. The forward cone is built by propagating state and covariance with no measurements; its width starts at the current state uncertainty and widens with horizon.

🎯 Three design choices stand out. First, carrying covariance delivers a confidence-aware estimate beyond a smooth line. Second, adaptive R auto-calibrates the cone to real price noise. Third, confining state updates to confirmed bars keeps the historical estimate non-repainting.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — BTC/ETH (1D, 4H): Responsiveness 20, Adaptive Noise on, Confidence σ = 2.0, horizon 16; smooth, low-lag trend tracking. High-volatility names (SOL, XRP): lower Responsiveness to 10–15 to absorb noise, and widen Confidence σ toward 2.5 for a steadier centerline and cone in rough action.
Per parameter: Responsiveness is the main knob — higher tracks price faster (less lag, less smoothing); lower is smoother (more lag, more noise tolerance). Adaptive Noise is best left on — it auto-calibrates per market; for manual control, set Manual Noise (R) directly. Confidence σ sets band and cone width; Horizon sets projection length. Trend Deadband (t-stat) sets how much trend certainty counts as Rising / Falling.

💡 How to Use in Practice

The core read is centerline × velocity × trend strength. When the centerline tilts up (cyan) with a high trend-strength (t-statistic), it reads as a tailwind for buying dips. A tag-and-reject at the in-sample band edge marks a deviation from the state estimate — a mean-reversion cue. A contracting band/cone means a calm, high-confidence state; an expanding one means rising uncertainty — useful for sizing. The forward cone's slope and width convey trend direction and confidence at a glance.
For multi-timeframe work, read the higher-timeframe centerline for the backdrop and use velocity turns (t-stat sign flips) on a lower timeframe for execution. Layered over support/resistance or volume, the Kalman centerline acts as a proxy for the "smooth price path institutions watch" — a reference line for entries and exits.

⚠️ Important Notes

Estimates are hidden until the warmup period (default 30 bars) completes (kept short, as the Kalman converges fast). Reloading the indicator makes the filter reprocess history from scratch — state is not persisted. This is a constant-velocity (local linear trend) model, so the forward point estimate is a straight line — it does not foretell sharp moves or reversals themselves. The uncertainty cone is a probabilistic range under the model's assumptions, not a certain forecast. State updates on confirmed bars; on the forming bar the centerline holds its last confirmed value.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Kalman State Filter   ( AE-KSF )
// ----------------------------------------------------------------------------
//  A self-evolving state-space estimator. It treats the true price as a HIDDEN
//  state - a local linear trend with level (p) and velocity (v) - and recovers
//  it from noisy observations with a Kalman filter:
//      Predict:  x' = F x ,   P' = F P F^T + Q
//      Update:   K = P' H^T / (H P' H^T + R) ,  x = x' + K (z - H x') ,
//                P = (I - K H) P'
//  The filter does not merely smooth: it carries a full covariance P, so it
//  knows HOW SURE it is, and projects that forward as a widening uncertainty
//  cone. Crucially the measurement noise R is estimated ONLINE from the
//  innovation stream, so the Kalman gain self-tunes to each instrument and
//  regime. State updates occur on confirmed bars only (no look-ahead).
// ============================================================================
indicator("AetherEdge - Kalman State Filter", "AE-KSF", overlay = true, max_polylines_count = 100, max_labels_count = 50)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Filter ---
var string gF = "Filter"
src         = input.source(close, "Source", group = gF)
useLog      = input.bool(true,  "Log-Price Space", group = gF, tooltip = "Filter in log space (scale-free; cone becomes multiplicative and asymmetric in price).")
respo       = input.float(20,   "Responsiveness", minval = 1, maxval = 100, step = 1, group = gF, tooltip = "How fast the state tracks price. Higher = snappier and less smooth (more process noise relative to measurement noise).")
adaptive    = input.bool(true,  "Adaptive Noise", group = gF, tooltip = "Estimate measurement noise R online from the innovation stream, so the gain self-tunes.")
adaptWin    = input.int(50,     "Adaptation Window", minval = 5, group = gF, tooltip = "EMA window for the innovation-variance estimate.")
Rmanual     = input.float(0.0001, "Manual Noise (R)", minval = 0.0, step = 0.0001, group = gF, tooltip = "Measurement-noise variance used when Adaptive Noise is off (log-price units).")

//  --- Projection / band ---
var string gP = "Projection & Band"
bandSig  = input.float(2.0, "Confidence (sigma)", minval = 0.5, maxval = 4.0, step = 0.25, group = gP, tooltip = "Width of the uncertainty band and forward cone, in standard deviations.")
H        = input.int(16, "Projection Horizon", minval = 2, maxval = 60, group = gP)
tdz      = input.float(0.5, "Trend Deadband (t-stat)", minval = 0.0, step = 0.1, group = gP, tooltip = "Velocity t-statistic magnitude separating Rising / Flat / Falling.")

//  --- Display ---
var string gD = "Display"
warmup    = input.int(30, "Warmup Bars", minval = 5, group = gD)
upCol     = input.color(#26ffe6, "Rising", group = gD)
dnCol     = input.color(#ff2e88, "Falling", group = gD)
flatCol   = input.color(#8892b0, "Flat", group = gD)
showBand  = input.bool(true,  "In-Sample Band", group = gD)
showGlow  = input.bool(true,  "Neon Glow", group = gD)
showCone  = input.bool(true,  "Forward Cone", group = gD)
showTint  = input.bool(true,  "Background Tint", group = gD)
showDash  = input.bool(true,  "Dashboard", group = gD)
dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
EPS = 1e-12

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

f_toP(float x) => useLog ? math.exp(x) : x

ready  = bar_index > warmup
qRatio = math.pow(respo / 100.0, 2) * 0.10   // process/measurement variance ratio

// ----------------------------------------------------------------------------
//  PERSISTENT STATE  (the Kalman filter)
// ----------------------------------------------------------------------------
var float p      = na      // level (log-price or price)
var float v      = na      // velocity (per bar)
var float P00    = 1.0     // covariance
var float P01    = 0.0
var float P11    = 0.1
var float innVar = 0.0001  // innovation-variance estimate
var float Rused  = 0.0001  // measurement-noise variance in use
var float Kp     = 0.0      // current Kalman gain (level), for display
var float inn    = 0.0      // last innovation, for display
var bool  built  = false

// ----------------------------------------------------------------------------
//  KALMAN RECURSION  (advance once per CLOSED bar)
// ----------------------------------------------------------------------------
if barstate.isconfirmed and ready
    float z = useLog ? math.log(src) : src
    if not built
        p   := z
        v   := 0.0
        P00 := 1.0
        P01 := 0.0
        P11 := 0.1
        built := true
    else
        // process-noise level scaled to the current measurement noise
        float q = qRatio * Rused
        // --- Predict ---
        float pPred = p + v
        float vPred = v
        float Pp00 = P00 + 2.0 * P01 + P11 + q / 3.0
        float Pp01 = P01 + P11 + q / 2.0
        float Pp11 = P11 + q
        // --- Innovation + adaptive measurement noise ---
        inn := z - pPred
        float aE = 2.0 / (adaptWin + 1.0)
        innVar := innVar * (1.0 - aE) + aE * inn * inn
        Rused := adaptive ? math.max(math.max(innVar - Pp00, innVar * 0.10), EPS) : math.max(Rmanual, EPS)
        // --- Update ---
        float S = Pp00 + Rused
        Kp := Pp00 / S
        float Kv = Pp01 / S
        p := pPred + Kp * inn
        v := vPred + Kv * inn
        P00 := (1.0 - Kp) * Pp00
        P01 := (1.0 - Kp) * Pp01
        P11 := Pp11 - Kv * Pp01

// ----------------------------------------------------------------------------
//  DERIVED METRICS
// ----------------------------------------------------------------------------
float sigP  = math.sqrt(math.max(P00, 0.0))          // level uncertainty (std)
float tstat = v / (math.sqrt(math.max(P11, EPS)))    // velocity signal-to-noise
float conf  = math.min(math.abs(tstat) / 3.0, 1.0)
color dirCol = na(tstat) ? flatCol : tstat > tdz ? upCol : tstat < -tdz ? dnCol : flatCol
active = ready and built and bar_index > warmup

// ----------------------------------------------------------------------------
//  CENTERLINE + IN-SAMPLE BAND  (on price)
// ----------------------------------------------------------------------------
float line  = active ? f_toP(p) : na
float upper = active and showBand ? f_toP(p + bandSig * sigP) : na
float lower = active and showBand ? f_toP(p - bandSig * sigP) : na

pGlow = plot(active and showGlow ? line : na, "Glow", color = color.new(dirCol, 70), linewidth = 6)
pLine = plot(line, "Kalman", color = dirCol, linewidth = 2)
pUp = plot(upper, "Upper", color = color.new(dirCol, 100))
pLo = plot(lower, "Lower", color = color.new(dirCol, 100))
fill(pUp, pLo, color = color.new(dirCol, 86))

int tintT = 93 - int(conf * 8.0)
bgcolor(showTint and active ? color.new(dirCol, tintT) : na)

// ----------------------------------------------------------------------------
//  FORWARD UNCERTAINTY CONE  (last bar)
// ----------------------------------------------------------------------------
var array<polyline> pls = array.new<polyline>()
var label endLab = na

if barstate.islast
    if array.size(pls) > 0
        for pl in pls
            polyline.delete(pl)
        array.clear(pls)
    label.delete(endLab)

    if active and showCone
        // propagate state + covariance forward (no measurements)
        array<float> cLog = array.new<float>(H + 1, 0.0)
        array<float> cSig = array.new<float>(H + 1, 0.0)
        float PP00 = P00
        float PP01 = P01
        float PP11 = P11
        float q = qRatio * Rused
        array.set(cLog, 0, p)
        array.set(cSig, 0, sigP)
        for h = 1 to H
            float n00 = PP00 + 2.0 * PP01 + PP11 + q / 3.0
            float n01 = PP01 + PP11 + q / 2.0
            float n11 = PP11 + q
            PP00 := n00
            PP01 := n01
            PP11 := n11
            array.set(cLog, h, p + v * h)
            array.set(cSig, h, math.sqrt(math.max(PP00, 0.0)))

        // centerline
        array<chart.point> ctr = array.new<chart.point>()
        for h = 0 to H
            array.push(ctr, chart.point.from_index(bar_index + h, f_toP(array.get(cLog, h))))
        if showGlow
            array.push(pls, polyline.new(points = ctr, closed = false, curved = false, xloc = xloc.bar_index, line_color = color.new(dirCol, 70), line_width = 5))
        array.push(pls, polyline.new(points = ctr, closed = false, curved = false, xloc = xloc.bar_index, line_color = dirCol, line_width = 2))

        // nested cones -> soft gradient
        for layer = 1 to 3
            float frac = layer / 3.0
            array<chart.point> poly = array.new<chart.point>()
            for h = 0 to H
                array.push(poly, chart.point.from_index(bar_index + h, f_toP(array.get(cLog, h) + bandSig * array.get(cSig, h) * frac)))
            for h = H to 0
                array.push(poly, chart.point.from_index(bar_index + h, f_toP(array.get(cLog, h) - bandSig * array.get(cSig, h) * frac)))
            int tr = 90 + layer * 2
            array.push(pls, polyline.new(points = poly, closed = true, curved = false, xloc = xloc.bar_index, line_color = color.new(dirCol, 100), fill_color = color.new(dirCol, tr)))

        float projPct = (f_toP(array.get(cLog, H)) / close - 1.0) * 100.0
        string arrow = tstat > tdz ? "▲" : tstat < -tdz ? "▼" : "◆"
        string labTxt = arrow + " " + (projPct >= 0 ? "+" : "") + str.tostring(projPct, "#.##") + "%  ·  t " + str.tostring(tstat, "#.#")
        endLab := label.new(x = bar_index + H, y = f_toP(array.get(cLog, H)), text = labTxt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(dirCol, 15), textcolor = #0b0e16, size = size.small)

// ----------------------------------------------------------------------------
//  DASHBOARD
// ----------------------------------------------------------------------------
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 9, bgcolor = color.new(#0b0e16, 20), frame_color = color.new(upCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)

if barstate.islast and showDash
    color hdrBg = #0b0e16
    color rowBg = color.new(#11151f, 10)
    string stat = active ? "● ACTIVE" : "◌ LEARNING"
    color  statCol = active ? upCol : flatCol
    string trend = tstat > tdz ? "▲ RISING" : tstat < -tdz ? "▼ FALLING" : "◆ FLAT"
    float velPct  = (useLog ? math.exp(v) - 1.0 : v / close) * 100.0
    float noiseBps = (useLog ? math.sqrt(Rused) : math.sqrt(Rused) / close) * 10000.0
    float sigBps   = (useLog ? sigP : sigP / close) * 10000.0
    float innBps   = (useLog ? inn : inn / close) * 10000.0
    table.cell(dash, 0, 0, "AE · KSF",     text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, stat,           text_color = statCol, bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
    table.cell(dash, 0, 1, "Trend",        text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 1, trend,          text_color = dirCol,  bgcolor = rowBg, text_size = size.small,  text_halign = text.align_right)
    table.cell(dash, 0, 2, "Velocity",     text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 2, (velPct >= 0 ? "+" : "") + str.tostring(velPct, "#.###") + "%/bar", text_color = dirCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "Trend Strength", text_color = flatCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(tstat, "#.##") + "σ", text_color = color.from_gradient(conf, 0.0, 1.0, flatCol, dirCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 4, "Kalman Gain",  text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(Kp * 100, "#") + "%", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 5, "Noise (R)",    text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(noiseBps, "#") + " bps", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 6, "State Uncert.", text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 6, "±" + str.tostring(sigBps, "#") + " bps", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 7, "Innovation",   text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 7, (innBps >= 0 ? "+" : "") + str.tostring(innBps, "#") + " bps", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 8, "Mode",         text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 8, adaptive ? "Adaptive" : "Manual", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
turnUp = active and tstat > tdz and not (tstat[1] > tdz)
turnDn = active and tstat < -tdz and not (tstat[1] < -tdz)
alertcondition(turnUp, "Trend turned up",   "AE-KSF: state velocity turned positive")
alertcondition(turnDn, "Trend turned down", "AE-KSF: state velocity turned negative")
````
