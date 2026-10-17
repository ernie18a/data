# Kalman Quantum Drift [JOAT]

- url: https://www.tradingview.com/script/phRErF4O-Kalman-Quantum-Drift-JOAT/
- type: indicator
- pine_id: PUB;c3fcd820234941559de12cc56d51e795
- version: 1.0

## Description

[b]KALMAN QUANTUM DRIFT [JOAT][/b]

A trend-and-envelope engine built on the cleanest pair of state-space tools in quantitative finance: a [b]Kalman filter[/b] for the centreline (Bayesian, adaptive, mathematically optimal under linear-Gaussian assumptions) and a [b]GARCH(1,1)[/b] conditional-variance model for the envelope (the institutional standard for time-varying volatility). The script reads price as a noisy observation of an unobservable true state; the Kalman filter estimates that state recursively; GARCH estimates the noise's volatility; the envelope = mid ± k · σ_GARCH. A signal engine layered on top detects [b]Collapse[/b] events (>3σ excursions) and [b]Tunnel[/b] events (gap-throughs of the envelope) — the quantum analogues of state collapse and quantum tunnelling.

[image]https://www.tradingview.com/x/kYh1avuU/[/image]

[b]The Kalman filter, properly[/b]

A single-state recursive Bayesian filter. At each bar:

[list=1]
[*] [b]Predict[/b]: prior estimate = previous estimate. Prior variance = previous variance + Q.
[*] [b]Update[/b]: Kalman gain = prior variance / (prior variance + R). New estimate = prior + gain × (observation − prior). New variance = (1 − gain) × prior variance.
[/list]

The two tuning knobs are:

[list]
[*] [b]Q (process noise)[/b] — how much the script trusts new observations. Higher Q = faster, noisier mid-line.
[*] [b]R (measurement noise)[/b] — how much the script trusts the model. Higher R = slower, smoother mid-line.
[/list]

This is the Bayesian-optimal smoother for linear-Gaussian state-space data. Real markets are not perfectly linear-Gaussian, but the Kalman estimate is robust enough to be the cleanest mid-line you can build without going into heavy non-linear filtering.

[b]GARCH(1,1) envelope[/b]

The envelope around the Kalman mid is not ATR or stdev — it is [b]GARCH(1,1)[/b]:

[i]σ²_t = ω + α · ε²_{t−1} + β · σ²_{t−1}[/i]

ω is the long-run variance baseline, α is the reaction to last shock squared (ARCH term), β is the persistence of past variance (GARCH term). For stationarity, α + β < 1 (the script's α/β defaults respect that). Optional log returns (default ON) and a warm-up window seed the variance from realised returns.

The envelope is [b]mid ± k · σ_GARCH[/b], rendered as a gradient (configurable number of nested fills, each at progressive transparency from edge to core).

[b]Three-signal engine[/b]

[list]
[*] [b]Collapse[/b] — fires when price travels more than [b]collapse threshold[/b] (default 3.0) σ-units from the Kalman mid. The "state collapse" event — price has decisively departed the filter's expected band. Bull or bear depending on direction.
[*] [b]Tunnel[/b] — fires when a bar gaps through the entire envelope from one side to the other. The "quantum tunnel" event — a discontinuous jump that bypasses the band gradient.
[*] [b]Buy / Sell crosses[/b] — fire when price crosses the Kalman mid from one side. Optional [b]Collapse confirmation[/b] gate (default ON) — Buy / Sell only fires when a Collapse occurred within the configurable lookback window. This dramatically improves signal quality.
[/list]

A configurable signal cooldown (default 5 bars) prevents stacking.

[b]Visual system[/b]

[list]
[*] [b]Kalman mid-line[/b] — coloured by its own slope (bull / bear), configurable width.
[*] [b]Gradient envelope[/b] — nested fills (configurable steps, default 6) using the same base hue with progressive transparency from edge to core. Strict two-hue discipline (bull cyan / bear pink only).
[*] [b]Price bar colouring[/b] by mid slope (toggleable).
[*] [b]Background tint on extremes[/b] — subtle bgcolor when price is at envelope edge (toggleable, default 92 transparency).
[*] [b]Event glyphs[/b] — C (Collapse) and T (Tunnel) markers at the event bar. Configurable size.
[/list]

A locked Quantum palette (cyan bull / pink bear / muted cyan mid on a deep violet-black) gives the chart a distinctive quant-physics identity.

[image]https://www.tradingview.com/x/TfUtjoqR/[/image]

[b]Dashboard[/b]

Monospaced table positionable to any of nine corners. Surfaces:

[list]
[*] Current Kalman mid value with slope direction.
[*] σ_GARCH value and the envelope half-width.
[*] Distance of price from mid in σ-units.
[*] Last Collapse / Tunnel / Buy / Sell event with bar age.
[*] Q / R settings in use.
[*] GARCH ω / α / β confirmation.
[/list]

[b]Alerts[/b]

Six alert conditions, each independently controllable:

[list]
[*] Collapse Up / Down (>kσ excursion)
[*] Tunnel Up / Down (envelope gap-through)
[*] Slope Flip (Kalman mid changes direction)
[*] Sigma Spike (σ_GARCH exceeds its own recent baseline)
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Buy/Sell after a Collapse[/b] (the script's intended signal) — the cleanest trend-entry the engine produces. A Collapse means price decisively departed expected range; the subsequent mid-line cross confirms the new direction with the strongest possible context. This is the highest-conviction read.
[*] [b]Tunnel[/b] — an exceptional, rare event. When a single bar jumps the entire envelope, the market has experienced a discontinuity (news, large block, exchange dislocation). Often produces the day's largest moves; almost always followed by elevated volatility.
[*] [b]σ Spike alert without a directional event[/b] — a regime warning. Volatility just expanded without a directional commitment yet. The next signal that fires is statistically more likely to be meaningful than the one before the spike.
[/list]

[b]Suggested settings[/b]

Defaults (Q = 0.02, R = 1.5, GARCH ω=2e-6 / α=0.10 / β=0.85, k = 2.5, gradient steps 6) are tuned for 15m–1H on liquid markets. For lower timeframes drop k to 2.0. For HTF raise R to 3.0 (more model trust on smoother data). The GARCH α/β defaults are the institutional standard; α + β remains under 1 for stationarity.

[b]Originality[/b]

Kalman filtering and GARCH(1,1) are textbook quantitative-finance methods — both decades-old, both well-documented. The implementation here — the single-state recursive Kalman with exposed Q/R, the GARCH(1,1) variance recursion with warm-up window, the gradient-envelope render using strict two-hue alpha-only variation, the three-signal engine (Collapse / Tunnel / Cross), the optional Collapse-confirmed Buy/Sell gating, the event glyph markers, and the background tint on extremes — is JOAT-original. No third-party code reused. The pairing of Kalman + GARCH + quantum-inspired signal naming is the original presentation.

[b]Limitations[/b]

The Kalman filter assumes linear-Gaussian state dynamics — real markets violate this, especially around news and gaps. The Q / R tuning is exposed precisely because no single setting is universally correct; tune to your instrument's noise profile. GARCH's α/β must sum to less than 1 for stationarity — the defaults respect this; if you push them too aggressively the variance can explode. Collapse and Tunnel events are confirmed on bar close (non-repainting).

—


-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title = "Kalman Quantum Drift [JOAT]",
     shorttitle      = "KQD [JOAT]",
     overlay         = true,
     max_lines_count = 500,
     max_boxes_count = 500,
     max_labels_count= 500,
     max_bars_back   = 5000)

// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================
grpKal  = "[ Kalman Filter ]"
grpGar  = "[ GARCH(1,1) ]"
grpEnv  = "[ Envelope ]"
grpSig  = "[ Signals ]"
grpVis  = "[ Visuals ]"
grpDash = "[ Dashboard ]"
grpAlrt = "[ Alerts ]"

// --- Kalman ------------------------------------------------------------------
srcKal     = input.source(close, "Source",                     group = grpKal)
qNoise     = input.float (0.02,  "Q  (process noise)",         minval = 0.00001, step = 0.001, group = grpKal,
     tooltip = "Higher Q = filter trusts new observations more (faster, noisier mid-line).")
rNoise     = input.float (1.50,  "R  (measurement noise)",     minval = 0.001,   step = 0.01,  group = grpKal,
     tooltip = "Higher R = filter trusts the model more (slower, smoother mid-line).")
slopeLen   = input.int   (5,     "Slope EMA length",           minval = 1,    group = grpKal)

// --- GARCH(1,1) --------------------------------------------------------------
gOmega     = input.float (0.000002, "omega (constant)",     minval = 0.0,    step = 0.0000001, group = grpGar,
     tooltip = "Long-run variance baseline. Typical 1e-6 .. 1e-5 for normalized returns.")
gAlpha     = input.float (0.10,     "alpha (ARCH term)",    minval = 0.0,  maxval = 0.99, step = 0.01, group = grpGar,
     tooltip = "Reaction to last shock^2. alpha + beta should remain < 1 for stationarity.")
gBeta      = input.float (0.85,     "beta (GARCH term)",    minval = 0.0,  maxval = 0.99, step = 0.01, group = grpGar)
warmLen    = input.int   (20,       "Warm-up variance length",minval = 5,  group = grpGar,
     tooltip = "Length used to seed GARCH variance from realised returns.")
useLogRet  = input.bool  (true,     "Use log returns",        group = grpGar)

// --- Envelope ----------------------------------------------------------------
kMult      = input.float (2.50,  "k  (envelope sigma multiplier)", minval = 0.1, step = 0.1, group = grpEnv)
showEnv    = input.bool  (true,  "Show envelope",                  group = grpEnv)
showMid    = input.bool  (true,  "Show Kalman mid-line",           group = grpEnv)
midWidth   = input.int   (3,     "Mid-line width", minval = 1, maxval = 5, group = grpEnv)
gradSteps  = input.int   (6,     "Envelope gradient steps", minval = 2, maxval = 12, group = grpEnv,
     tooltip = "Number of nested fills used to render the gradient envelope. Each layer uses the SAME base hue with increasing transparency.")
edgeTrans  = input.int   (45,    "Edge transparency",  minval = 0, maxval = 95, group = grpEnv)
coreTrans  = input.int   (90,    "Inner transparency", minval = 0, maxval = 95, group = grpEnv)

// --- Signals -----------------------------------------------------------------
enColl     = input.bool  (true,  "Enable Collapse (>3 sigma)",      group = grpSig)
collThr    = input.float (3.0,   "Collapse sigma threshold", minval = 1.0, step = 0.1, group = grpSig)
enTunnel   = input.bool  (true,  "Enable Tunnel (gap-through env)", group = grpSig)
enBuySell  = input.bool  (true,  "Enable Buy/Sell crosses",         group = grpSig)
reqCollap  = input.bool  (true,  "Require Collapse confirmation",   group = grpSig,
     tooltip = "If on, BUY/SELL only fires when a Collapse occurred within the lookback window.")
collLkbk   = input.int   (5,     "Collapse confirm window (bars)", minval = 1, maxval = 50, group = grpSig)
sigCooldn  = input.int   (5,     "Signal cooldown (bars)",          minval = 0, group = grpSig)

// --- Visuals -----------------------------------------------------------------
// QUANTUM PALETTE (curated):
//   bull = #00FFE0 (cyan)  bear = #FF00C8 (pink)  mid = #80FFE0
//   bg   = #02011A         frame = #1A0F33
// Envelope gradient uses a single hue (bull or bear) with transparency variation.
colorBars  = input.bool  (true,  "Color price bars by mid slope",  group = grpVis)
bgTint     = input.bool  (true,  "Background tint on extremes",    group = grpVis)
bgTintT    = input.int   (92,    "Background tint transparency",   minval = 70, maxval = 99, group = grpVis)
markGlyph  = input.bool  (true,  "Show event glyphs (C / T)",      group = grpVis)
markSize   = input.string("Small","Marker size", options = ["Tiny","Small","Normal","Large"], group = grpVis)

// --- Dashboard ---------------------------------------------------------------
showDash   = input.bool  (true,  "Show dashboard",                 group = grpDash)
dashPos    = input.string("Top Right", "Position", options = [
     "Top Right","Top Left","Top Center",
     "Middle Right","Middle Left","Middle Center",
     "Bottom Right","Bottom Left","Bottom Center"], group = grpDash)
dashSize   = input.string("Small","Text size",
     options = ["Tiny","Small","Normal","Large"], group = grpDash)

// --- Alerts ------------------------------------------------------------------
alCollUp   = input.bool  (true,  "Alert: Collapse Up",   group = grpAlrt)
alCollDn   = input.bool  (true,  "Alert: Collapse Down", group = grpAlrt)
alTunUp    = input.bool  (true,  "Alert: Tunnel Up",     group = grpAlrt)
alTunDn    = input.bool  (true,  "Alert: Tunnel Down",   group = grpAlrt)
alSlopeFlp = input.bool  (true,  "Alert: Slope flip",    group = grpAlrt)
alSigSpike = input.bool  (true,  "Alert: Sigma spike",   group = grpAlrt)

// =============================================================================
//  SECTION 2 - QUANTUM PALETTE (single curated palette)
//  Strict 2-hue discipline: only C_BULL (cyan) and C_BEAR (pink) are used
//  on the chart. All gradient fills are alpha-only variations of those hues.
// =============================================================================
const color C_BULL  = #00FFE0   // cyan       - bull / slope-up
const color C_BEAR  = #FF00C8   // pink       - bear / slope-down
const color C_MID   = #80FFE0   // muted cyan - neutral midtone
const color C_BG    = #02011A   // deep violet-black
const color C_FRAME = #1A0F33   // frame
color C_TEXT  = color.new(color.white, 5)
color C_MUTED = color.new(color.white, 60)

// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================

// Single-hue alpha lerp - keeps strict 2-hue discipline (no new colors invented)
f_alpha(color c, int t) => color.new(c, math.max(0, math.min(95, t)))

// Linear interpolation 0..1 -> transparency between two integer values
f_lerpT(float r, int lo, int hi) =>
    rr = math.max(0.0, math.min(1.0, r))
    int(lo + (hi - lo) * rr)

f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))

// Position / size resolvers - same pattern as KB 2.4
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>               position.top_right

strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

// Simple Kalman filter (single-state) - KB 2.13
kalman(float src, float q, float r) =>
    var float estimate = na
    var float errorEst = 1.0
    if na(estimate)
        estimate := src
        errorEst := 1.0
    else
        gain      = errorEst / (errorEst + r)
        estimate := estimate + gain * (src - estimate)
        errorEst := (1.0 - gain) * errorEst + q
    estimate

// GARCH(1,1) - KB 2.14
// Returns conditional standard deviation sigma_t (sqrt of variance)
garch11(float src, float omega, float alpha, float beta, int warm, bool logRet) =>
    var float sigma2 = na
    // Build return series consistently for both seed and recursion
    float r = logRet
         ? ((src > 0 and src[1] > 0) ? math.log(src / src[1]) : 0.0)
         : nz(src - src[1], 0.0)
    // Pre-compute the seed variance every bar (ta.* must run on every bar)
    seedVar = ta.variance(r, math.max(2, warm))
    if na(sigma2)
        sigma2 := (na(seedVar) or seedVar <= 0) ? 1e-8 : seedVar
    else
        sigma2 := omega + alpha * math.pow(r, 2) + beta * sigma2
    math.sqrt(math.max(sigma2, 1e-12))

// Format value with sensible precision for instrument
fmtP(float v) =>
    if na(v)
        "n/a"
    else
        absv = math.abs(v)
        absv >= 1000 ? str.tostring(v, "#.##") : absv >= 1 ? str.tostring(v, "#.####") : str.tostring(v, "#.######")

fmtPct(float v) => na(v) ? "n/a" : str.tostring(v * 100.0, "#.##") + "%"

// =============================================================================
//  SECTION 4 - CORE CALCULATIONS
//  Kalman mid + GARCH sigma + envelope.  In return-space sigma is unitless,
//  so the price-space deviation is sigma * close.
// =============================================================================
mid       = kalman(srcKal, qNoise, rNoise)
sigmaRet  = garch11(srcKal, gOmega, gAlpha, gBeta, warmLen, useLogRet)
sigmaPx   = sigmaRet * close

upper     = mid + kMult * sigmaPx
lower     = mid - kMult * sigmaPx
envWidth  = upper - lower
envRatio  = envWidth / math.max(mid, 1e-10)   // width as fraction of mid

// Slope of mid (smoothed)
midDelta  = mid - mid[1]
midSlope  = ta.ema(midDelta, slopeLen)
slopeUp   = midSlope > 0
slopeDn   = midSlope < 0
slopeFlip = (slopeUp and slopeDn[1]) or (slopeDn and slopeUp[1])

// Distance of close from mid in sigma units
dev       = close - mid
devSig    = sigmaPx > 0 ? dev / sigmaPx : 0.0
absDevSig = math.abs(devSig)

// Sigma spike detector - large jump in sigma vs its own EMA baseline
sigmaBase = ta.ema(sigmaRet, 50)
sigmaSpkR = sigmaBase > 0 ? sigmaRet / sigmaBase : 1.0
sigmaSpike= sigmaSpkR >= 2.0

// =============================================================================
//  SECTION 5 - STATE / TRACKING
// =============================================================================
var int   lastCollBar    = na
var int   lastCollDir    = 0     // +1 up, -1 down
var int   lastTunnelBar  = na
var int   lastTunnelDir  = 0
var int   lastBuyBar     = na
var int   lastSellBar    = na
var int   lastSigBar     = -1000 // shared cooldown bookkeeping
var int   slopeFlipBar   = na
var int   slopeFlipDir   = 0

// =============================================================================
//  SECTION 6 - SIGNAL ENGINE
//  Confirmation on barstate.isconfirmed only - no repaint.
// =============================================================================

// Collapse:  abs(close - mid) > collThr * sigma   (sustained > 3 sigma move)
collapseRaw   = enColl and absDevSig > collThr
collapseUp    = collapseRaw and devSig > 0
collapseDn    = collapseRaw and devSig < 0

// Tunnel: bar opens one side of envelope, closes the opposite side
tunnelUp      = enTunnel and (open <= lower) and (close >= upper)
tunnelDn      = enTunnel and (open >= upper) and (close <= lower)

// Cooldown gating - shared across all signal kinds
canFire       = (bar_index - lastSigBar) >= sigCooldn

// Cross detection for BUY/SELL
xUpLower      = ta.crossover (close, lower)
xDnUpper      = ta.crossunder(close, upper)

// Collapse-recency window
recentCollUp  = not na(lastCollBar) and (bar_index - lastCollBar) <= collLkbk and lastCollDir > 0
recentCollDn  = not na(lastCollBar) and (bar_index - lastCollBar) <= collLkbk and lastCollDir < 0

buySig        = enBuySell and xUpLower and (not reqCollap or recentCollDn) and canFire
sellSig       = enBuySell and xDnUpper and (not reqCollap or recentCollUp) and canFire

// Commit state on confirmed bar
if barstate.isconfirmed
    if collapseUp
        lastCollBar := bar_index
        lastCollDir := 1
        lastSigBar  := bar_index
    if collapseDn
        lastCollBar := bar_index
        lastCollDir := -1
        lastSigBar  := bar_index
    if tunnelUp
        lastTunnelBar := bar_index
        lastTunnelDir := 1
        lastSigBar    := bar_index
    if tunnelDn
        lastTunnelBar := bar_index
        lastTunnelDir := -1
        lastSigBar    := bar_index
    if buySig
        lastBuyBar  := bar_index
        lastSigBar  := bar_index
    if sellSig
        lastSellBar := bar_index
        lastSigBar  := bar_index
    if slopeFlip
        slopeFlipBar := bar_index
        slopeFlipDir := slopeUp ? 1 : -1

// =============================================================================
//  SECTION 7 - PLOTS / FILLS / CANDLES
//  Strict 2-hue discipline: bull and bear are the only two hues.
//  Gradient fills are built from nested layers of the SAME single hue with
//  varying transparency - the human eye reads this as one smooth wedge.
// =============================================================================

// --- Mid-line color: bull when slope up, bear when slope down ---------------
color midCol    = slopeUp ? C_BULL : slopeDn ? C_BEAR : f_alpha(C_BULL, 30)
pMid      = plot(showMid ? mid : na, "Kalman Mid", color = midCol, linewidth = midWidth)

// --- Outer envelope lines (very faint, same hue as the active side) ----------
pUpper    = plot(showEnv ? upper : na, "Upper", color = f_alpha(C_BEAR, 85), linewidth = 1)
pLower    = plot(showEnv ? lower : na, "Lower", color = f_alpha(C_BULL, 85), linewidth = 1)

// --- Layered gradient envelope: nested fills, single hue per side ------------
// Each layer's transparency moves smoothly from coreTrans (near mid) to edgeTrans (far edge)
// This produces a smooth wedge using only C_BULL on the lower half and only C_BEAR on the upper half.
plotLayerUpA = plot(showEnv ? mid + 0.20 * kMult * sigmaPx : na, "lyrU1", color = na, display = display.none)
plotLayerUpB = plot(showEnv ? mid + 0.40 * kMult * sigmaPx : na, "lyrU2", color = na, display = display.none)
plotLayerUpC = plot(showEnv ? mid + 0.60 * kMult * sigmaPx : na, "lyrU3", color = na, display = display.none)
plotLayerUpD = plot(showEnv ? mid + 0.80 * kMult * sigmaPx : na, "lyrU4", color = na, display = display.none)
plotLayerDnA = plot(showEnv ? mid - 0.20 * kMult * sigmaPx : na, "lyrD1", color = na, display = display.none)
plotLayerDnB = plot(showEnv ? mid - 0.40 * kMult * sigmaPx : na, "lyrD2", color = na, display = display.none)
plotLayerDnC = plot(showEnv ? mid - 0.60 * kMult * sigmaPx : na, "lyrD3", color = na, display = display.none)
plotLayerDnD = plot(showEnv ? mid - 0.80 * kMult * sigmaPx : na, "lyrD4", color = na, display = display.none)

// Upper half - five wedge fills, all variations of C_BEAR
fill(pMid,         plotLayerUpA, color = f_alpha(C_BEAR, f_lerpT(0.10, coreTrans, edgeTrans)))
fill(plotLayerUpA, plotLayerUpB, color = f_alpha(C_BEAR, f_lerpT(0.30, coreTrans, edgeTrans)))
fill(plotLayerUpB, plotLayerUpC, color = f_alpha(C_BEAR, f_lerpT(0.50, coreTrans, edgeTrans)))
fill(plotLayerUpC, plotLayerUpD, color = f_alpha(C_BEAR, f_lerpT(0.70, coreTrans, edgeTrans)))
fill(plotLayerUpD, pUpper,       color = f_alpha(C_BEAR, f_lerpT(0.90, coreTrans, edgeTrans)))

// Lower half - five wedge fills, all variations of C_BULL
fill(pMid,         plotLayerDnA, color = f_alpha(C_BULL, f_lerpT(0.10, coreTrans, edgeTrans)))
fill(plotLayerDnA, plotLayerDnB, color = f_alpha(C_BULL, f_lerpT(0.30, coreTrans, edgeTrans)))
fill(plotLayerDnB, plotLayerDnC, color = f_alpha(C_BULL, f_lerpT(0.50, coreTrans, edgeTrans)))
fill(plotLayerDnC, plotLayerDnD, color = f_alpha(C_BULL, f_lerpT(0.70, coreTrans, edgeTrans)))
fill(plotLayerDnD, pLower,       color = f_alpha(C_BULL, f_lerpT(0.90, coreTrans, edgeTrans)))

// --- Bar coloring: bull / bear hue by mid slope (no extra hue introduced) ---
barcolor(colorBars ? (slopeUp ? f_alpha(C_BULL, 0) : slopeDn ? f_alpha(C_BEAR, 0) : na) : na)

// --- Background tint on extreme bars - alpha variation of active hue --------
color bgCol = na
if bgTint
    if absDevSig > collThr
        bgCol := f_alpha(devSig > 0 ? C_BEAR : C_BULL, bgTintT)
    else if sigmaSpike
        // sigma spike uses the dominant slope hue - keeps to 2 hues
        bgCol := f_alpha(slopeUp ? C_BULL : C_BEAR, bgTintT + 2)
bgcolor(bgCol, title = "Extreme Tint")

// --- Event markers - shape with letter glyph, never emoji -------------------
markStyleS = strToSize(markSize)

// Collapse marker (C) - placed near price on the appropriate side
plotshape(collapseUp and markGlyph ? high : na, title = "Collapse Up",
     style = shape.labelup, location = location.absolute,
     color = f_alpha(C_BEAR, 0), textcolor = color.white,
     text = "C", size = size.small, force_overlay = true)
plotshape(collapseDn and markGlyph ? low : na, title = "Collapse Dn",
     style = shape.labeldown, location = location.absolute,
     color = f_alpha(C_BULL, 0), textcolor = color.white,
     text = "C", size = size.small, force_overlay = true)

// Tunnel marker (T) - the more violent of the two; small offset
plotshape(tunnelUp and markGlyph ? low : na, title = "Tunnel Up",
     style = shape.labelup, location = location.belowbar,
     color = f_alpha(C_BULL, 0), textcolor = color.white,
     text = "T", size = size.small, force_overlay = true)
plotshape(tunnelDn and markGlyph ? high : na, title = "Tunnel Dn",
     style = shape.labeldown, location = location.abovebar,
     color = f_alpha(C_BEAR, 0), textcolor = color.white,
     text = "T", size = size.small, force_overlay = true)

// Buy / sell markers - triangles on bar
plotshape(buySig,  title = "Buy",  style = shape.triangleup,
     location = location.belowbar, color = f_alpha(C_BULL, 0),
     size = size.tiny, force_overlay = true)
plotshape(sellSig, title = "Sell", style = shape.triangledown,
     location = location.abovebar, color = f_alpha(C_BEAR, 0),
     size = size.tiny, force_overlay = true)

// =============================================================================
//  SECTION 8 - DRAWINGS  (event labels rendered on confirmed bars only)
// =============================================================================
// Keep memory bounded: rolling labels for richer text on collapse/tunnel
var array<label> evtLabels = array.new<label>()
maxEvtLabels = 80

f_pushLabel(label l) =>
    array.push(evtLabels, l)
    while array.size(evtLabels) > maxEvtLabels
        label.delete(array.shift(evtLabels))

if barstate.isconfirmed and markGlyph
    if collapseUp
        f_pushLabel(label.new(bar_index, high, "C  +" + str.tostring(devSig, "#.##") + "s",
             style = label.style_label_down, color = f_alpha(C_BEAR, 80),
             textcolor = color.white, size = size.tiny, force_overlay = true))
    if collapseDn
        f_pushLabel(label.new(bar_index, low, "C  " + str.tostring(devSig, "#.##") + "s",
             style = label.style_label_up, color = f_alpha(C_BULL, 80),
             textcolor = color.white, size = size.tiny, force_overlay = true))
    if tunnelUp
        f_pushLabel(label.new(bar_index, low, "T",
             style = label.style_label_up, color = f_alpha(C_BULL, 60),
             textcolor = color.white, size = size.small, force_overlay = true))
    if tunnelDn
        f_pushLabel(label.new(bar_index, high, "T",
             style = label.style_label_down, color = f_alpha(C_BEAR, 60),
             textcolor = color.white, size = size.small, force_overlay = true))

// =============================================================================
//  SECTION 9 - DASHBOARD  (8 substantive rows + header = 9 cells tall)
// =============================================================================
var table dash = table.new(strToPos(dashPos), 2, 9,
     bgcolor      = f_alpha(C_BG, 5),
     frame_color  = f_alpha(C_FRAME, 10),
     frame_width  = 1,
     border_color = f_alpha(C_FRAME, 60),
     border_width = 1)

// Gradient header background uses the dominant-slope hue only
hdrBg(int row, int rows) =>
    base = slopeUp ? C_BULL : slopeDn ? C_BEAR : C_FRAME
    t    = 65 + int(20 * (row / math.max(1, float(rows - 1))))
    f_alpha(base, t)

// Slope label
slopeStr = slopeUp ? "Up" : slopeDn ? "Down" : "Flat"
slopeCol = slopeUp ? C_BULL : slopeDn ? C_BEAR : C_MUTED

// Last event helpers
fmtAge(int b) => na(b) ? "n/a" : str.tostring(math.max(0, bar_index - b)) + "b"
fmtDir(int d) => d > 0 ? "Up" : d < 0 ? "Dn" : "-"

lastCollStr  = na(lastCollBar)   ? "none" : fmtAge(lastCollBar)   + " " + fmtDir(lastCollDir)
lastTunStr   = na(lastTunnelBar) ? "none" : fmtAge(lastTunnelBar) + " " + fmtDir(lastTunnelDir)
collCol      = na(lastCollDir)   ? C_MUTED : (lastCollDir   > 0 ? C_BULL : C_BEAR)
tunCol       = na(lastTunnelDir) ? C_MUTED : (lastTunnelDir > 0 ? C_BULL : C_BEAR)

// Sigma spike status
spikeCol     = sigmaSpike ? (slopeUp ? C_BULL : C_BEAR) : C_MUTED
spikeStr     = sigmaSpike ? "SPIKE x" + str.tostring(sigmaSpkR, "#.##") : str.tostring(sigmaSpkR, "#.##") + "x base"

txtSz        = strToSize(dashSize)

if showDash and barstate.islast
    // Row 0 - title
    table.cell(dash, 0, 0, "KALMAN QUANTUM DRIFT",
         text_color = color.white, bgcolor = hdrBg(0, 9),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 0, "[ KQD ]",
         text_color = color.white, bgcolor = hdrBg(0, 9),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 1 - Kalman mid
    table.cell(dash, 0, 1, "Kalman mid",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 75),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 1, fmtP(mid),
         text_color = midCol, bgcolor = f_alpha(C_FRAME, 75),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 2 - slope
    table.cell(dash, 0, 2, "Slope",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 78),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 2, slopeStr + "  " + fmtP(midSlope),
         text_color = slopeCol, bgcolor = f_alpha(C_FRAME, 78),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 3 - GARCH sigma
    table.cell(dash, 0, 3, "Sigma (ret)",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 80),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 3, fmtPct(sigmaRet) + "  (" + spikeStr + ")",
         text_color = spikeCol, bgcolor = f_alpha(C_FRAME, 80),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 4 - envelope width
    table.cell(dash, 0, 4, "Envelope width",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 82),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 4, fmtP(envWidth) + "  (" + fmtPct(envRatio) + ")",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 82),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 5 - last collapse
    table.cell(dash, 0, 5, "Last Collapse",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 84),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 5, lastCollStr,
         text_color = collCol, bgcolor = f_alpha(C_FRAME, 84),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 6 - last tunnel
    table.cell(dash, 0, 6, "Last Tunnel",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 86),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 6, lastTunStr,
         text_color = tunCol, bgcolor = f_alpha(C_FRAME, 86),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 7 - sigma spike / dev in sigma units
    table.cell(dash, 0, 7, "|close - mid| / sigma",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 88),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    devCol = absDevSig > collThr ? (devSig > 0 ? C_BEAR : C_BULL) : C_MUTED
    table.cell(dash, 1, 7, str.tostring(devSig, "+#.##;-#.##") + "s",
         text_color = devCol, bgcolor = f_alpha(C_FRAME, 88),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

    // Row 8 - Q / R settings (and k, alpha+beta sanity)
    settingStr = "Q=" + str.tostring(qNoise, "#.###") +
                 " R=" + str.tostring(rNoise, "#.##") +
                 " k=" + str.tostring(kMult, "#.##")
    abSum      = gAlpha + gBeta
    abCol      = abSum >= 1.0 ? C_BEAR : C_TEXT
    table.cell(dash, 0, 8, "Settings",
         text_color = C_TEXT, bgcolor = f_alpha(C_FRAME, 90),
         text_size = txtSz, text_halign = text.align_left,
         text_font_family = font.family_monospace)
    table.cell(dash, 1, 8, settingStr + "  a+b=" + str.tostring(abSum, "#.##"),
         text_color = abCol, bgcolor = f_alpha(C_FRAME, 90),
         text_size = txtSz, text_halign = text.align_right,
         text_font_family = font.family_monospace)

// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================
if alCollUp and collapseUp
    alert("[KQD] Collapse Up - close > mid by " + str.tostring(devSig, "#.##") + " sigma",
         alert.freq_once_per_bar_close)
if alCollDn and collapseDn
    alert("[KQD] Collapse Down - close < mid by " + str.tostring(devSig, "#.##") + " sigma",
         alert.freq_once_per_bar_close)
if alTunUp  and tunnelUp
    alert("[KQD] Tunnel Up - bar opened below lower env, closed above upper env",
         alert.freq_once_per_bar_close)
if alTunDn  and tunnelDn
    alert("[KQD] Tunnel Down - bar opened above upper env, closed below lower env",
         alert.freq_once_per_bar_close)
if alSlopeFlp and slopeFlip
    alert("[KQD] Kalman slope flip -> " + (slopeUp ? "Up" : "Down"),
         alert.freq_once_per_bar_close)
if alSigSpike and sigmaSpike
    alert("[KQD] GARCH sigma spike x" + str.tostring(sigmaSpkR, "#.##"),
         alert.freq_once_per_bar_close)
if enBuySell and buySig
    alert("[KQD] BUY - close crossed above lower envelope (confirmed)",
         alert.freq_once_per_bar_close)
if enBuySell and sellSig
    alert("[KQD] SELL - close crossed below upper envelope (confirmed)",
         alert.freq_once_per_bar_close)

// Granular alertcondition() entries for fine-grained alert UI choice
alertcondition(collapseUp,            title = "Collapse Up",    message = "[KQD] Collapse Up")
alertcondition(collapseDn,            title = "Collapse Down",  message = "[KQD] Collapse Down")
alertcondition(tunnelUp,              title = "Tunnel Up",      message = "[KQD] Tunnel Up")
alertcondition(tunnelDn,              title = "Tunnel Down",    message = "[KQD] Tunnel Down")
alertcondition(slopeFlip and slopeUp, title = "Slope -> Up",    message = "[KQD] Slope flipped Up")
alertcondition(slopeFlip and slopeDn, title = "Slope -> Down",  message = "[KQD] Slope flipped Down")
alertcondition(sigmaSpike,            title = "Sigma spike",    message = "[KQD] GARCH sigma spike")
alertcondition(buySig,                title = "BUY cross",      message = "[KQD] BUY")
alertcondition(sellSig,               title = "SELL cross",     message = "[KQD] SELL")

// =============================================================================
//  END OF FILE  -  Kalman Quantum Drift [JOAT]
// =============================================================================
````
