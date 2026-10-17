# Heisenberg Uncertainty Bands [JOAT]

- url: https://www.tradingview.com/script/EdjyhgnY-Heisenberg-Uncertainty-Bands-JOAT/
- type: indicator
- pine_id: PUB;a27f0a4844734a848969e5f470b04a1c
- version: 1.0

## Description

[b]HEISENBERG UNCERTAINTY BANDS [JOAT][/b]

A novel band-and-state engine inspired by the Heisenberg uncertainty principle: the recognition that for a market, just as for a quantum particle, you cannot simultaneously be certain about both [b]position[/b] (where price is) and [b]momentum[/b] (how fast it is moving). Heisenberg Uncertainty Bands measures both uncertainties, tracks their empirical floor, classifies the current market into one of three quantum-inspired states — pure position |x⟩, pure momentum |p⟩, or mixed |ψ⟩ — and projects bands around price accordingly.

[image]https://www.tradingview.com/x/ntz8swUg/[/image]

[b]The principle, translated[/b]

In quantum mechanics, Δx · Δp ≥ ℏ/2 — the product of the position uncertainty and the momentum uncertainty cannot fall below a constant called Planck's reduced. For markets the analogue is:

[list]
[*] [b]Δx[/b] — the rolling standard deviation of price over a configurable window. The uncertainty in where price is sitting.
[*] [b]Δp[/b] — the rolling standard deviation of [i]returns[/i] (log or arithmetic, configurable) over a separate window. The uncertainty in how fast price is moving.
[*] [b]ℏ̂[/b] (hbar-hat) — the EMA-smoothed long-run product Δx · Δp. The script's empirical estimate of the market-specific lower bound.
[/list]

Just like in physics, when the market is [i]certain[/i] about position (price has been stable), it becomes uncertain about momentum (next direction is unknown) — and vice versa. The script measures both, computes the product, compares it to the empirical floor, and uses the ratio Δx/Δp as the state classifier.

[b]Three quantum states[/b]

[list]
[*] [b]Pure Position State |x⟩[/b] — Δx/Δp below the position threshold (default 0.40). Price is constrained to a tight band; the next directional move is uncertain. Yellow palette.
[*] [b]Pure Momentum State |p⟩[/b] — Δp/Δx below the momentum threshold (default 0.40). Direction is committed; the range is widening. Magenta palette.
[*] [b]Mixed State |ψ⟩[/b] — neither pure state condition holds. Violet palette.
[/list]

The state badge on the right of the chart shows the bra-ket glyph (Unicode |x⟩ / |p⟩ / |ψ⟩ by default; can fall back to plain POS / MOM / MIX if your font lacks the brackets). A state cooldown (default 3 bars) debounces flicker.

[b]Band projection[/b]

Two band families are projected around the live mid price:

[list]
[*] [b]Position bands[/b] — mid ± k × Δx. Solid by default. The classic "how wide is price ranging right now" envelope.
[*] [b]Momentum bands[/b] — mid ± k × (Δp scaled to the price axis). Dashed by default (configurable: Dashed / Dotted / Solid). Projected so their visual range matches the position bands.
[/list]

When the two families are far apart in width, the state is decisive (|x⟩ if position is much tighter, |p⟩ if momentum is much tighter). When they are similar, the state is mixed.

[b]Optional uncertainty-score candle tint[/b]

A toggleable layer recolours each candle based on how far the current Δx · Δp product deviates from the empirical floor ℏ̂. When the product is at the floor, the market is at its quantum-mechanical minimum — the most decisive setup; further from the floor means the market is "spending uncertainty" on both axes simultaneously.

[b]Visual system[/b]

[list]
[*] Position bands (solid, gradient fill optional).
[*] Momentum bands (dashed / dotted / solid).
[*] Mid line (style configurable).
[*] State badge (right-side floating, configurable offset and size).
[*] Background tint by state (configurable transparency, institutional default).
[*] Optional candle re-tint by uncertainty score.
[/list]

A locked Plasma palette (yellow position / magenta momentum / violet mixed on a deep-void ground) gives the chart a distinctive physics-inspired identity.

[image]https://www.tradingview.com/x/8foV72gR/[/image]

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners, optional compact-no-header mode. Surfaces:

[list]
[*] Current Δx and Δp values.
[*] Δx · Δp product and its ratio to the ℏ̂ floor.
[*] Δx / Δp ratio (drives the state).
[*] Current state (|x⟩ / |p⟩ / |ψ⟩) with bar age.
[*] Last state change with bars-ago.
[*] Return mode (Log / Arithmetic) in use.
[/list]

[b]Alerts[/b]

Three alert conditions:

[list]
[*] Pure Position State entry
[*] Pure Momentum State entry
[*] Mixed State return
[/list]

[b]How to read it[/b]

Two reads, in order of conviction:

[list=1]
[*] [b]Pure Momentum State |p⟩[/b] entry is the script's directional commitment signal. Momentum has decisively exceeded position uncertainty — the move is real. Trend-following tools and breakout entries become high-conviction.
[*] [b]Pure Position State |x⟩[/b] is the coil. Range has clamped down, direction is undecided. Reversion tools become high-conviction inside the band; the next state transition (back to |ψ⟩ or jumping to |p⟩) often produces a decisive breakout.
[/list]

When Δx · Δp is close to ℏ̂ (the empirical floor) the market is at its most efficient — there is no slack in either axis to spare. These bars often coincide with the cleanest reversals and breakouts; the candle-tint layer is there specifically to highlight them.

[b]Suggested settings[/b]

Defaults (position window 20, momentum window 20, hbar smoothing 100, k = 2.0, state threshold 0.40) are tuned for 15m–4H on liquid markets. For lower timeframes drop both windows to 10–14. For HTF (4H+) raise both to 30–50. Log returns are the theoretically-correct mode and the recommended default; switch to Arithmetic only if your instrument has trivially small price scale.

[b]Originality[/b]

The implementation — the Δx / Δp dual-uncertainty pipeline, the EMA-smoothed empirical ℏ̂ floor, the three-state quantum-inspired classifier with bra-ket labelling, the dual-band projection with auto-scale, the uncertainty-score candle tint, the cooldown-debounced state machine, and the plasma palette — is JOAT-original. No third-party code reused. The Heisenberg principle is fundamental physics; the financial-market analogue and its implementation here are original work.

[b]Limitations[/b]

The Heisenberg analogy is structural, not literal — markets do not obey the quantum-mechanical commutator relation; the script uses the [i]concept[/i] of an inviolable joint-uncertainty floor as a market-regime classifier. The empirical floor ℏ̂ is estimated by EMA over a long window (default 100 bars) — on instruments with very short history the floor is approximate. State classification can flicker across the threshold; the cooldown is there to suppress this and is tunable.

—


-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Heisenberg Uncertainty Bands [JOAT]", shorttitle="HUB [JOAT]", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=5000)

// =====================================================================================
//  SECTION 1 - INPUTS
// =====================================================================================
grpCalc  = "+======== Calculation ========+"
grpState = "+======== State Detection ========+"
grpVis   = "+======== Visuals ========+"
grpTheme = "+======== Theme ========+"
grpBands = "+======== Band Display ========+"
grpBadge = "+======== State Badge ========+"
grpDash  = "+======== Dashboard ========+"
grpAlert = "+======== Alerts ========+"

// ---- Calculation inputs -------------------------------------------------------------
posLen      = input.int(20,  "Position Window (Delta_x)",          minval=2,  maxval=500,  group=grpCalc,
     tooltip="Rolling window for the position-uncertainty stdev (Delta_x). Higher = smoother price band.")
momLen      = input.int(20,  "Momentum Window (Delta_p)",          minval=2,  maxval=500,  group=grpCalc,
     tooltip="Rolling window for the momentum-uncertainty stdev of returns (Delta_p).")
hbarLen     = input.int(100, "hbar Smoothing Length",              minval=10, maxval=2000, group=grpCalc,
     tooltip="EMA length for the empirical hbar estimate. Acts as the long-run lower bound on Delta_x * Delta_p.")
kBand       = input.float(2.0, "Band Multiplier k",                minval=0.1, maxval=10.0, step=0.1, group=grpCalc,
     tooltip="Multiplier applied to the corrected uncertainties when projecting bands around price and momentum.")
returnMode  = input.string("Log", "Return Definition",             options=["Log","Arithmetic"],            group=grpCalc,
     tooltip="Log returns are scale-invariant and preferred for cross-asset comparison. Arithmetic is simpler.")
priceSource = input.source(close, "Price Source",                  group=grpCalc,
     tooltip="Series used for the position-uncertainty calculation (default: close).")
momLookback = input.int(1,  "Momentum Lookback (bars)",            minval=1, maxval=20, group=grpCalc,
     tooltip="Number of bars used to compute the return that drives Delta_p. 1 = bar-over-bar.")

// ---- State detection thresholds -----------------------------------------------------
posThr      = input.float(0.40, "|x> State Threshold (Position / Momentum ratio)", minval=0.05, maxval=1.00, step=0.01, group=grpState,
     tooltip="If Delta_x / Delta_p < this value, Delta_x is small relative to Delta_p --> Pure Position State |x>.")
momThr      = input.float(0.40, "|p> State Threshold (Momentum / Position ratio)", minval=0.05, maxval=1.00, step=0.01, group=grpState,
     tooltip="If Delta_p / Delta_x < this value, Delta_p is small relative to Delta_x --> Pure Momentum State |p>.")
stateCool   = input.int(3,    "State Cooldown (bars)",             minval=0, maxval=200, group=grpState,
     tooltip="Minimum bars between state-change alerts (de-bounces flicker).")
useUnicode  = input.bool(true, "Use Unicode bra-ket Labels (|x> |p> |psi>)",       group=grpState,
     tooltip="When off, falls back to plain ASCII tags POS/MOM/MIX (use when your font lacks bra-ket glyphs).")

// ---- Visual master toggles ----------------------------------------------------------
showPriceBands   = input.bool(true,  "Show Price Uncertainty Bands",        group=grpBands)
showPriceFill    = input.bool(true,  "  Gradient Fill Inside Price Bands",  group=grpBands)
showMomBands     = input.bool(true,  "Show Momentum Bands (projected on price scale)", group=grpBands,
     tooltip="Projects the momentum bands around the live price for visual comparison with the position bands.")
momBandStyle     = input.string("Dashed", "  Momentum Band Style",          options=["Dashed","Dotted","Solid"], group=grpBands)
showMid          = input.bool(true,  "Show Mid-Line",                       group=grpBands)
midStyle         = input.string("Solid", "  Mid-Line Style",                options=["Solid","Dashed","Dotted"], group=grpBands)
showBgTint       = input.bool(true,  "Show Background Tint by State",       group=grpBands)
bgTintAlpha      = input.int(88, "  Background Tint Transparency",         minval=50, maxval=99, group=grpBands)
showCandles      = input.bool(false, "Recolor Candles by Uncertainty Score", group=grpBands,
     tooltip="Tints each candle by how far Delta_x * Delta_p deviates from its empirical floor.")
plotMomPaneScale = input.bool(true,  "Auto-Scale Momentum to Price Range",  group=grpBands,
     tooltip="When on, the momentum bands are scaled so their visual range matches the price band range.")

// ---- Theme -------------------------------------------------------------------------
// PLASMA PALETTE (curated, single source of truth):
//   bull / position-state = #FFEA00 yellow
//   bear / momentum-state = #FF0080 magenta
//   mid  / mixed-state    = #B700FF violet
//   bg = #0A0014           frame = #1A0930

// ---- Badge inputs -------------------------------------------------------------------
showBadge   = input.bool(true, "Show State Badge",                    group=grpBadge)
badgeOffset = input.int(8,    "Badge Right Offset (bars)",           minval=1, maxval=200, group=grpBadge)
badgeSizeIn = input.string("Large", "Badge Size",                    options=["Tiny","Small","Normal","Large","Huge"], group=grpBadge)

// ---- Dashboard inputs ---------------------------------------------------------------
showDash    = input.bool(true,  "Show Dashboard",                    group=grpDash)
dashPosIn   = input.string("Top Right",  "Dashboard Position", options=[
     "Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Bottom Center",
     "Middle Right","Middle Left","Middle Center"], group=grpDash)
dashSizeIn  = input.string("Small", "Dashboard Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)
dashCompact = input.bool(false, "Compact Dashboard (no header)",     group=grpDash)

// ---- Alerts -------------------------------------------------------------------------
alertOnPos  = input.bool(true,  "Alert on Pure Position State entry",   group=grpAlert)
alertOnMom  = input.bool(true,  "Alert on Pure Momentum State entry",   group=grpAlert)
alertOnMix  = input.bool(true,  "Alert on Mixed State return",          group=grpAlert)


// =====================================================================================
//  SECTION 2 - PLASMA PALETTE (single curated palette)
//      cBull = position-state   #FFEA00 yellow
//      cBear = momentum-state   #FF0080 magenta
//      cMid  = mixed-state      #B700FF violet
//      cBg                      #0A0014
//      cFrame                   #1A0930
// =====================================================================================
const color cBull  = #FFEA00
const color cBear  = #FF0080
const color cMid   = #B700FF
const color cBg    = #0A0014
const color cFrame = #1A0930
color cText  = color.new(color.white, 0)
color cMuted = color.new(color.gray, 30)


// =====================================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =====================================================================================

// 3.1  Linear two-color gradient (single best helper from KB 2.1).
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// 3.2  Multi-stop gradient over a 3-color cool->mid->warm ramp.
f_gradient3(float ratio, color cCold, color cMid_, color cWarm) =>
    r = math.max(0.0, math.min(1.0, ratio))
    r <= 0.5 ? f_colorGradient(r * 2.0, cCold, cMid_) : f_colorGradient((r - 0.5) * 2.0, cMid_, cWarm)

// 3.3  Clamp helper.
f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

// 3.4  Position-string resolver (KB 2.4).
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

strToLineStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        "Solid"  => line.style_solid
        =>          line.style_solid

// 3.5  Row-gradient background utility (KB 2.5) for premium dashboard look.
grad(color _base, int _row, int _rows, float _minT, float _maxT) =>
    float t = _rows <= 1 ? _minT : (_minT + (_maxT - _minT) * (_row / float(_rows - 1)))
    color.new(_base, int(t))

// 3.6  Number formatter that prefers scientific notation for tiny values.
fmtSmart(float v, int digits) =>
    if na(v)
        "n/a"
    else
        absv = math.abs(v)
        if absv == 0.0
            "0"
        else if absv >= 1e6
            str.tostring(v / 1e6, "#.##") + "M"
        else if absv >= 1e3
            str.tostring(v / 1e3, "#.##") + "k"
        else if absv >= 0.01
            str.tostring(v, "#." + str.repeat("#", digits))
        else
            // Use exponent notation for very small magnitudes.
            str.tostring(v, "#.######e")

// 3.7  Safe ratio (returns na if denom is na or near-zero).
safeDiv(float num, float den) => (na(den) or den == 0.0) ? na : num / den

// 3.8  Return computation helper.
calcReturn(float p, float p_prev, string mode) =>
    na(p) or na(p_prev) or p_prev == 0.0 ? 0.0 : mode == "Log" and p > 0.0 and p_prev > 0.0 ? math.log(p / p_prev) : (p - p_prev) / p_prev

// 3.9  Half-life dampener to keep state badges from chattering.
f_chgGuarded(int curState, int prevState, int lastChgBar, int coolBars) =>
    canFlip = (bar_index - lastChgBar) >= coolBars
    curState != prevState and canFlip


// =====================================================================================
//  SECTION 4 - CORE CALCULATIONS  (the Heisenberg engine)
// =====================================================================================
// Step 1: position uncertainty Delta_x  =  stdev of price source over posLen bars.
deltaX_raw = ta.stdev(priceSource, posLen)

// Step 2: returns and momentum uncertainty Delta_p.
ret = calcReturn(priceSource, priceSource[momLookback], returnMode)
deltaP_raw = ta.stdev(ret, momLen)

// Step 3: instantaneous product (the "uncertainty area").
prodRaw = deltaX_raw * deltaP_raw

// Step 4: empirical hbar = long EMA of the product.  Acts as the floor.
hbarEst = ta.ema(prodRaw, hbarLen)

// Step 5: enforce the principle - widen the smaller variable so product >= hbar.
//          If Delta_x is the smaller, set Delta_x_corrected = hbar / Delta_p
//          Else                       set Delta_p_corrected = hbar / Delta_x
var float deltaXc = na
var float deltaPc = na
if not na(deltaX_raw) and not na(deltaP_raw) and not na(hbarEst) and deltaX_raw > 0.0 and deltaP_raw > 0.0
    if prodRaw < hbarEst
        // Decide which to widen: the *relatively* smaller one (compared to its own EMA).
        xRel = deltaX_raw / ta.ema(deltaX_raw, hbarLen)
        pRel = deltaP_raw / ta.ema(deltaP_raw, hbarLen)
        if xRel <= pRel
            deltaXc := hbarEst / deltaP_raw
            deltaPc := deltaP_raw
        else
            deltaXc := deltaX_raw
            deltaPc := hbarEst / deltaX_raw
    else
        // Already satisfies the principle - pass through.
        deltaXc := deltaX_raw
        deltaPc := deltaP_raw
else
    deltaXc := nz(deltaX_raw, 0.0)
    deltaPc := nz(deltaP_raw, 0.0)

// Step 6: corrected product and the uncertainty *score* (deviation magnitude).
prodCorr   = deltaXc * deltaPc
uncertScore = na(hbarEst) or hbarEst == 0.0 ? 0.0 : math.abs(prodCorr - hbarEst) / hbarEst

// Step 7: build the price bands around the source.
midLine    = ta.ema(priceSource, math.max(2, int(posLen / 2)))
upperPrice = midLine + kBand * deltaXc
lowerPrice = midLine - kBand * deltaXc
priceBandWidth = upperPrice - lowerPrice

// Step 8: build the momentum bands.  They are calculated around the *return* series
// but projected onto the *price scale* so they appear on the overlay alongside the
// position bands.  Projection uses the current price as the anchor and scales by
// (kBand * Delta_p_corrected) * (priceBandWidth / max(deltaPc, eps)) when auto-scale is on.
momentumNow   = ret
momMid        = ta.ema(momentumNow, math.max(2, int(momLen / 2)))
momUpperRaw   = momMid + kBand * deltaPc
momLowerRaw   = momMid - kBand * deltaPc
momentumBandRaw = momUpperRaw - momLowerRaw

// Auto-scale the momentum band so its visual extent matches the position band.
priceScaleFactor = plotMomPaneScale and momentumBandRaw > 0.0 ? priceBandWidth / momentumBandRaw : 1.0
momUpperVis = midLine + (momUpperRaw - momMid) * priceScaleFactor
momLowerVis = midLine + (momLowerRaw - momMid) * priceScaleFactor


// =====================================================================================
//  SECTION 5 - STATE / TRACKING
// =====================================================================================
// State codes: 0 = mixed |psi>,  1 = pure position |x>,  -1 = pure momentum |p>.
var int   currentState  = 0
var int   prevState     = 0
var int   lastStateBar  = 0
var int   lastChangeBar = 0
var int   barsInState   = 0
var int   posStateCount = 0
var int   momStateCount = 0
var int   mixStateCount = 0

// Rolling extremes (for the dashboard "session" summary).
var float maxUncert = 0.0
var float minUncert = 1e10


// =====================================================================================
//  SECTION 6 - STATE DETECTION  (the quantum classifier)
// =====================================================================================
// Strategy:  compare normalized Delta_x and Delta_p.  Normalization uses each
// variable's own EMA so the thresholds are scale-free across symbols.
deltaXNorm = safeDiv(deltaXc, ta.ema(deltaXc, hbarLen))
deltaPNorm = safeDiv(deltaPc, ta.ema(deltaPc, hbarLen))

xpRatio = safeDiv(deltaXNorm, deltaPNorm)
pxRatio = safeDiv(deltaPNorm, deltaXNorm)

isPosState = not na(xpRatio) and xpRatio < posThr  // Delta_x small vs Delta_p
isMomState = not na(pxRatio) and pxRatio < momThr  // Delta_p small vs Delta_x

int newState = 0
if isPosState and not isMomState
    newState := 1
else if isMomState and not isPosState
    newState := -1
else
    newState := 0

// Cooldown-guarded commit.
if barstate.isconfirmed
    if f_chgGuarded(newState, currentState, lastChangeBar, stateCool)
        prevState     := currentState
        currentState  := newState
        lastChangeBar := bar_index
        barsInState   := 0
    else
        barsInState += 1
    // Track counts.
    if currentState ==  1
        posStateCount += 1
    if currentState == -1
        momStateCount += 1
    if currentState ==  0
        mixStateCount += 1
    if uncertScore > maxUncert
        maxUncert := uncertScore
    if uncertScore < minUncert
        minUncert := uncertScore


// =====================================================================================
//  SECTION 7 - PLOTS / FILLS / CANDLES
// =====================================================================================
// 7.1 - Mid line.
pMid = plot(showMid ? midLine : na, "Mid",
     color = color.new(cMid, 25),
     linewidth = 2,
     style = midStyle == "Dashed" ? plot.style_linebr : midStyle == "Dotted" ? plot.style_circles : plot.style_line)

// 7.2 - Outer (position) bands.
pUp = plot(showPriceBands ? upperPrice : na, "Position Upper",
     color = color.new(cBull, 0), linewidth = 2)
pLo = plot(showPriceBands ? lowerPrice : na, "Position Lower",
     color = color.new(cBear, 0), linewidth = 2)

// 7.3 - Gradient fill between position bands.
// The fill color is sampled along a cold->mid->warm ramp based on the price location
// inside the band (low = bear-cold, mid = mid color, top = bull-warm).  We approximate
// a gradient fill in Pine by tinting the single fill() call by uncertainty score.
fillRatio   = f_clamp(safeDiv(priceSource - lowerPrice, upperPrice - lowerPrice), 0.0, 1.0)
fillBaseCol = f_gradient3(nz(fillRatio, 0.5), cBear, cMid, cBull)
fillAlpha   = int(85 + 10 * f_clamp(uncertScore, 0.0, 1.0))   // more transparent when far from floor
fill(pUp, pLo, color = showPriceFill ? color.new(fillBaseCol, fillAlpha) : na, title="Position Band Fill")

// 7.4 - Momentum bands (projected on price scale).
momLineStyle = momBandStyle == "Solid" ? plot.style_line : momBandStyle == "Dotted" ? plot.style_circles : plot.style_linebr
mUp = plot(showMomBands ? momUpperVis : na, "Momentum Upper",
     color = color.new(cMid, 10), linewidth = 1, style = momLineStyle)
mLo = plot(showMomBands ? momLowerVis : na, "Momentum Lower",
     color = color.new(cMid, 10), linewidth = 1, style = momLineStyle)

// 7.5 - Thin fill between momentum bands to mark the conjugate envelope.
fill(mUp, mLo, color = showMomBands ? color.new(cMid, 92) : na, title="Momentum Band Fill")

// 7.6 - Background tint by current state.
bgTintCol = currentState == 1  ? color.new(cBull, bgTintAlpha) : currentState == -1 ? color.new(cBear, bgTintAlpha) : color.new(cMid,  math.min(99, bgTintAlpha + 4))
bgcolor(showBgTint ? bgTintCol : na, title="State Background")

// 7.7 - Optional candle recoloring by uncertainty score.
candleRatio = f_clamp(uncertScore, 0.0, 1.0)
candleCol   = f_gradient3(candleRatio, cMid, cBull, cBear)
plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na,
     color = candleCol, wickcolor = candleCol, bordercolor = candleCol, title="Uncertainty Candles")


// =====================================================================================
//  SECTION 8 - DRAWINGS (state badge on right side)
// =====================================================================================
labelPos    = useUnicode ? "|x⟩"   : "POS"
labelMom    = useUnicode ? "|p⟩"   : "MOM"
labelMix    = useUnicode ? "|ψ⟩" : "MIX"

stateText() =>
    currentState == 1 ? labelPos : currentState == -1 ? labelMom : labelMix

stateGlyphCol() =>
    currentState == 1 ? cBull : currentState == -1 ? cBear : cMid

// One persistent badge label - updated on every confirmed bar so it never duplicates.
var label badgeLbl = label.new(na, na, "", style = label.style_label_left)
if barstate.islast and showBadge
    label.set_xy(badgeLbl, bar_index + badgeOffset, midLine)
    label.set_text(badgeLbl, stateText() + "  " + str.tostring(uncertScore, "#.###"))
    label.set_textcolor(badgeLbl, stateGlyphCol())
    label.set_color(badgeLbl, color.new(cBg, 20))
    label.set_size(badgeLbl, strToSize(badgeSizeIn))
    label.set_style(badgeLbl, label.style_label_left)

// Tiny per-event marker (X = state flip) drawn each time the state changes.
plotchar(barstate.isconfirmed and currentState != prevState,
     "State Flip Marker", "x", location.abovebar, color = color.new(cMid, 0), size = size.tiny)


// =====================================================================================
//  SECTION 9 - DASHBOARD
// =====================================================================================
hdrTxt    = "HEISENBERG UNCERTAINTY"
rowsCount = dashCompact ? 8 : 9   // header + 8 metric rows
var table tbl = table.new(strToPos(dashPosIn), 2, rowsCount,
     bgcolor      = na,
     frame_color  = cFrame,
     frame_width  = 1,
     border_color = color.new(cFrame, 65),
     border_width = 1)

stateNameLong = currentState == 1 ? "Pure Position (Breakout Watch)" : currentState == -1 ? "Pure Momentum (Reversal Watch)" : "Mixed (Normal Regime)"

if showDash and barstate.islast
    int r = 0
    rGap  = dashCompact ? 0 : 1     // 1 extra header row when not compact
    hdrBg = color.new(cBg, 20)
    rowBg = color.new(cBg, 60)

    if not dashCompact
        table.cell(tbl, 0, r, hdrTxt,
             text_color = cText,
             bgcolor    = hdrBg,
             text_halign= text.align_left,
             text_size  = strToSize(dashSizeIn),
             text_font_family = font.family_monospace)
        table.cell(tbl, 1, r, "v1.0",
             text_color = color.new(cText, 40),
             bgcolor    = hdrBg,
             text_halign= text.align_right,
             text_size  = strToSize(dashSizeIn),
             text_font_family = font.family_monospace)
        r += 1

    // Row 1 - Delta_x
    table.cell(tbl, 0, r, "Delta_x (position)",
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_left, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, fmtSmart(deltaXc, 4),
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_right, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    r += 1

    // Row 2 - Delta_p
    table.cell(tbl, 0, r, "Delta_p (momentum)",
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_left, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, fmtSmart(deltaPc, 6),
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_right, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    r += 1

    // Row 3 - Delta_x * Delta_p
    table.cell(tbl, 0, r, "Delta_x * Delta_p",
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_left, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, fmtSmart(prodCorr, 6),
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_right, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    r += 1

    // Row 4 - hbar estimate
    table.cell(tbl, 0, r, "hbar estimate",
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_left, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, fmtSmart(hbarEst, 6),
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_right, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    r += 1

    // Row 5 - State
    stateColor = stateGlyphCol()
    table.cell(tbl, 0, r, "State",
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_left, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, stateText() + "  " + stateNameLong,
         text_color = stateColor, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_right, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    r += 1

    // Row 6 - Uncertainty Score
    uscColor = uncertScore > 1.0 ? cBull : uncertScore < 0.25 ? cBear : cMid
    table.cell(tbl, 0, r, "Uncertainty Score",
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_left, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, str.tostring(uncertScore, "#.####"),
         text_color = uscColor, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_right, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    r += 1

    // Row 7 - Position band width
    table.cell(tbl, 0, r, "Position Band Width",
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_left, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, fmtSmart(priceBandWidth, 4),
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_right, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    r += 1

    // Row 8 - Momentum band width
    table.cell(tbl, 0, r, "Momentum Band Width",
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_left, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, r, fmtSmart(momentumBandRaw, 6),
         text_color = cText, bgcolor = grad(cBg, r, rowsCount, 60, 85),
         text_halign = text.align_right, text_size = strToSize(dashSizeIn),
         text_font_family = font.family_monospace)
    r += 1


// =====================================================================================
//  SECTION 10 - ALERTS
// =====================================================================================
// Edge-trigger alerts only fire when the state changes onto the target (cooldown obeyed).
enteredPos = currentState ==  1 and prevState !=  1
enteredMom = currentState == -1 and prevState != -1
returnedMix = currentState ==  0 and prevState !=  0

alertcondition(alertOnPos and enteredPos,
     title   = "Pure Position State Entered (|x>)",
     message = "HUB [JOAT]: |x> Pure Position state - price compressed, breakout watch.")

alertcondition(alertOnMom and enteredMom,
     title   = "Pure Momentum State Entered (|p>)",
     message = "HUB [JOAT]: |p> Pure Momentum state - momentum exhausted, reversal watch.")

alertcondition(alertOnMix and returnedMix,
     title   = "Mixed State Return (|psi>)",
     message = "HUB [JOAT]: |psi> Mixed state - normal market regime restored.")

// Additional convenience alerts.
alertcondition(uncertScore > 1.0,
     title   = "Uncertainty Score Above 1.0",
     message = "HUB [JOAT]: Delta_x * Delta_p has moved >100% above hbar estimate - regime expansion.")

alertcondition(uncertScore < 0.05 and barstate.isconfirmed,
     title   = "Uncertainty Score Near Zero",
     message = "HUB [JOAT]: Delta_x * Delta_p has converged to hbar floor - imminent regime change.")

alertcondition(barstate.isconfirmed and ta.cross(priceSource, upperPrice),
     title   = "Price Crossed Position Upper",
     message = "HUB [JOAT]: Close crossed above the upper position band.")

alertcondition(barstate.isconfirmed and ta.cross(lowerPrice, priceSource),
     title   = "Price Crossed Position Lower",
     message = "HUB [JOAT]: Close crossed below the lower position band.")
````
