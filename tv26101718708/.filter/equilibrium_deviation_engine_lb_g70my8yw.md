# Equilibrium Deviation Engine [LB]

- url: https://www.tradingview.com/script/G70My8yW/
- type: indicator
- pine_id: PUB;74c7c799807f42d080d7ef564117852b
- version: 1.0

## Description

[image]https://www.tradingview.com/x/wV8rTXjy/[/image]
[b]Concept[/b]
The Equilibrium Deviation Engine [LB] is a session-resetting, volume-weighted equilibrium model that builds a dynamic fair value basis from accumulated price and volume since the last anchor point (daily by default). Around this basis, it constructs multiple deviation bands and an independent extreme contrarian channel whose width varies inversely with short-term volatility — expanding during quiet markets and contracting during turbulent ones.

[b]Mathematical Foundation[/b]
At each new session (e.g., daily open), the engine resets three accumulators and recalculates them bar by bar :

[i]PV  = SUM(Price * Volume)[/i]
[i]V   = SUM(Volume)[/i]
[i]P2V = SUM(Price^2 * Volume)[/i]

The equilibrium basis is the volume-weighted average price since reset :

[i]Basis = PV / V[/i]

The standard deviation of price around this basis is derived from the variance :

[i]Var = max( (P2V / V) - Basis^2 , 0 )[/i]
[i]Dev = sqrt(Var)[/i]

Three main bands are then computed by applying adaptive multipliers to this deviation. The adaptation uses two independent weights :

[i]TWAP Weight[/i] — compares the basis to a hidden TWAP. The larger the gap relative to the deviation, the more the bands widen, capturing potential mean-reversion targets.

[i]HV Weight[/i] — compares current historical volatility (HV) to its own smoothed baseline. When HV expands, bands widen ; when HV contracts, bands narrow.

The final band width for level k is :

[i]D_k = Dev * Mult_k * TWAP_Weight * HV_Weight[/i]

[b]The Extreme Contrarian Channel[/b]
A separate channel is built using an inverse volatility weight. Instead of expanding with rising HV, it contracts :

[i]InvWeight = clamp( 1 / (HV_contrarian / HV_contrarian_baseline) , min, max )[/i]

This creates a structural envelope that is widest during low-volatility regimes (where price tends to range) and tightens during high-volatility regimes (where price breaks through normal boundaries). The inner and outer levels use user-defined sigma multipliers.

[b]What Problem Does It Solve ?[/b]
Traditional deviation bands (Bollinger, Keltner, VWAP bands) use fixed lookback windows and a single volatility metric. They do not reset at session boundaries, nor do they distinguish between different volatility regimes for mean-reversion versus breakout scenarios. The Equilibrium Deviation Engine solves this by :

- Resetting accumulators at each session (e.g., daily), producing a true volume-weighted equilibrium for the current period.
- Adapting band width to both the TWAP gap (directional drift) and HV regime (market excitement).
- Adding a separate contrarian channel using inverse volatility, specifically designed to identify exhaustion zones where low volatility precedes expansion, or where extreme HV signals climax conditions.

[b]How To Interpret[/b]

[i]Basis line (white)[/i] — the real-time volume-weighted fair value for the current session. Price above basis signals session bullishness ; price below signals session bearishness.

[i]Deviation bands 1, 2, 3[/i] — graduated zones of overextension from the basis. Price reaching Band 3 represents an extreme statistical deviation from the session's equilibrium, often preceding reversion.

[i]Extreme contrarian channel[/i] — a separate envelope that behaves inversely to short-term HV. When this channel is wide (low HV, quiet market), price tends to oscillate within it, making the boundaries attractive mean-reversion levels. When the channel narrows sharply (high HV, excited market), it signals compression before a potential breakout.

[i]Band expansion vs contraction[/i] — widening bands indicate increasing dispersion and adaptive uncertainty ; narrowing bands indicate consolidation and equilibrium tightening.

[b]Parameters[/b]

[i]LB Engine[/i]
[b]Source[/b] — price field used for calculations (default HLC3).
[b]Reset TF[/b] — timeframe at which accumulators reset (default Daily).
[b]Hidden TWAP Length[/b] — period for the TWAP used in the TWAP gap weight.
[b]Historical Volatility Length[/b] — period for HV calculation (main bands).
[b]HV Smoothing[/b] — smoothing period for the HV baseline.

[i]LB Bands[/i]
[b]Deviation 1, 2, 3[/b] — base multipliers for the three main deviation levels.

[i]LB Contrarian Channel[/i]
[b]Extreme Channel Inner/Outer[/b] — sigma multipliers for the contrarian channel.
[b]Use Main HV Weight[/b] — applies the main HV weight to the contrarian channel.
[b]Use Hidden TWAP Weight[/b] — applies the TWAP gap weight to the contrarian channel.
[b]Contrarian Inverse HV Length[/b] — period for the HV used in the inverse weighting.
[b]Contrarian Inverse HV Smooth[/b] — smoothing period for the contrarian HV baseline.
[b]Contrarian Inverse HV Min/Max[/b] — clamping limits for the inverse weight.

[i]LB Style[/i]
[b]Show Basis, Show Main Fills, Color Bars[/b] — visual toggles.
[b]Basis Width, Band Width, Extreme Channel Width[/b] — line thickness controls.

[b]Reference[/b]
This indicator is a proprietary design by Luis Barlier. It synthesises concepts from session volume-weighted average price (VWAP), adaptive volatility bands, and inverse volatility regime detection. It does not correspond to a single academic publication.

## Source Code

````pine
//@version=6
indicator("Equilibrium Deviation Engine [LB]", overlay = true, scale = scale.right, max_labels_count = 500, max_lines_count = 500)

//=========================================================
// UTILS
//=========================================================
clampLB(v, vMin, vMax) =>
    math.max(vMin, math.min(v, vMax))

safeDivLB(a, b) =>
    b == 0.0 ? 0.0 : a / b

//=========================================================
// INPUTS
//=========================================================
groupEngine  = "LB Engine"
groupBands   = "LB Bands"
groupContra  = "LB Contrarian Channel"
groupStyle   = "LB Style"

src              = input.source(hlc3, "Source", group = groupEngine)
sessionAnchor    = input.timeframe("D", "Reset TF", group = groupEngine)
twapLen          = input.int(18, "Hidden TWAP Length", minval = 3, group = groupEngine)
hvLen            = input.int(28, "Historical Volatility Length", minval = 5, group = groupEngine)
hvSmooth         = input.int(9, "HV Smoothing", minval = 2, group = groupEngine)

mult1            = input.float(1.10, "Deviation 1", step = 0.05, minval = 0.10, group = groupBands)
mult2            = input.float(1.80, "Deviation 2", step = 0.05, minval = 0.10, group = groupBands)
mult3            = input.float(2.60, "Deviation 3", step = 0.05, minval = 0.10, group = groupBands)

sigma5Inner      = input.float(4.70, "Extreme Channel Inner", step = 0.05, minval = 0.10, group = groupContra)
sigma5Outer      = input.float(5.20, "Extreme Channel Outer", step = 0.05, minval = 0.10, group = groupContra)
showExtremeCh    = input.bool(true, "Show Extreme Channel", group = groupContra)
useHVWeight      = input.bool(true, "Use Main HV Weight", group = groupContra)
useTWAPWeight    = input.bool(true, "Use Hidden TWAP Weight", group = groupContra)

contraHvLen      = input.int(20, "Contrarian Inverse HV Length", minval = 5, group = groupContra)
contraHvSmooth   = input.int(7, "Contrarian Inverse HV Smooth", minval = 2, group = groupContra)
contraInvMin     = input.float(0.70, "Contrarian Inverse HV Min", step = 0.01, minval = 0.10, group = groupContra)
contraInvMax     = input.float(1.25, "Contrarian Inverse HV Max", step = 0.01, minval = 0.10, group = groupContra)

showBasis        = input.bool(true, "Show Basis", group = groupStyle)
showFills        = input.bool(true, "Show Main Fills", group = groupStyle)
showBarColors    = input.bool(false, "Color Bars", group = groupStyle)
basisWidth       = input.int(2, "Basis Width", minval = 1, maxval = 4, group = groupStyle)
bandWidth        = input.int(2, "Band Width", minval = 1, maxval = 4, group = groupStyle)
contraWidth      = input.int(2, "Extreme Channel Width", minval = 1, maxval = 4, group = groupStyle)

//=========================================================
// SESSION RESET
//=========================================================
anchorClock = request.security(syminfo.tickerid, sessionAnchor, time, barmerge.gaps_off, barmerge.lookahead_off)
newBlock    = ta.change(anchorClock) != 0

//=========================================================
// CORE ENGINE
//=========================================================
var float lb_pv  = na
var float lb_v   = na
var float lb_p2v = na

lb_pv  := newBlock ? src * volume : nz(lb_pv[1])  + src * volume
lb_v   := newBlock ? volume       : nz(lb_v[1])   + volume
lb_p2v := newBlock ? src * src * volume : nz(lb_p2v[1]) + src * src * volume

lb_basis = safeDivLB(lb_pv, lb_v)
lb_var   = math.max(safeDivLB(lb_p2v, lb_v) - lb_basis * lb_basis, 0.0)
lb_dev   = math.sqrt(lb_var)

//=========================================================
// MAIN ADAPTIVE WEIGHTING
//=========================================================
lb_twap       = ta.sma(src, twapLen)
lb_twapGap    = math.abs(lb_basis - lb_twap)
lb_twapNorm   = safeDivLB(lb_twapGap, math.max(lb_dev, syminfo.mintick))
lb_twapWeight = useTWAPWeight ? clampLB(1.0 + (lb_twapNorm - 0.45) * 0.14, 0.86, 1.20) : 1.0

lb_ret      = math.log(close / close[1])
lb_hv       = ta.stdev(lb_ret, hvLen)
lb_hvBase   = ta.sma(lb_hv, hvSmooth)
lb_hvRatio  = lb_hvBase == 0.0 ? 1.0 : lb_hv / lb_hvBase
lb_hvWeight = useHVWeight ? clampLB(lb_hvRatio, 0.78, 1.35) : 1.0

lb_adapt = lb_twapWeight * lb_hvWeight

//=========================================================
// MAIN BANDS
//=========================================================
lb_d1 = lb_dev * mult1 * lb_adapt
lb_d2 = lb_dev * mult2 * lb_adapt
lb_d3 = lb_dev * mult3 * lb_adapt

lb_u1 = lb_basis + lb_d1
lb_l1 = lb_basis - lb_d1
lb_u2 = lb_basis + lb_d2
lb_l2 = lb_basis - lb_d2
lb_u3 = lb_basis + lb_d3
lb_l3 = lb_basis - lb_d3

//=========================================================
// CONTRARIAN CHANNEL - INVERSE VOLATILITY WEIGHTING
//=========================================================
lb_contraRet      = math.log(close / close[1])
lb_contraHv       = ta.stdev(lb_contraRet, contraHvLen)
lb_contraHvBase   = ta.sma(lb_contraHv, contraHvSmooth)
lb_contraHvRatio  = lb_contraHvBase == 0.0 ? 1.0 : lb_contraHv / lb_contraHvBase

lb_contraInvRaw   = lb_contraHvRatio == 0.0 ? 1.0 : 1.0 / lb_contraHvRatio
lb_contraInvWeight = clampLB(lb_contraInvRaw, contraInvMin, contraInvMax)

// canal contrarian séparé, sans lien avec la bande 3
lb_xIn  = lb_dev * sigma5Inner * lb_adapt * lb_contraInvWeight
lb_xOut = lb_dev * sigma5Outer * lb_adapt * lb_contraInvWeight

lb_ucIn  = lb_basis + lb_xIn
lb_lcIn  = lb_basis - lb_xIn
lb_ucOut = lb_basis + lb_xOut
lb_lcOut = lb_basis - lb_xOut

//=========================================================
// COLORS - GREEN / RED
//=========================================================
cBasis = color.rgb(220, 220, 220)

cUp1 = color.rgb(46, 204, 113)
cUp2 = color.rgb(39, 174, 96)
cUp3 = color.rgb(30, 132, 73)

cDn1 = color.rgb(255, 107, 107)
cDn2 = color.rgb(231, 76, 60)
cDn3 = color.rgb(192, 57, 43)

cChUpIn  = color.rgb(0, 255, 128)
cChUpOut = color.rgb(0, 166, 81)
cChDnIn  = color.rgb(255, 82, 82)
cChDnOut = color.rgb(176, 0, 32)

//=========================================================
// PLOTS MAIN
//=========================================================
pBasis = plot(showBasis ? lb_basis : na, title = "LB Basis", color = cBasis, linewidth = basisWidth, force_overlay = true)

pU1 = plot(lb_u1, title = "LB Upper 1", color = cUp1, linewidth = bandWidth, force_overlay = true)
pL1 = plot(lb_l1, title = "LB Lower 1", color = cDn1, linewidth = bandWidth, force_overlay = true)

pU2 = plot(lb_u2, title = "LB Upper 2", color = cUp2, linewidth = 1, force_overlay = true)
pL2 = plot(lb_l2, title = "LB Lower 2", color = cDn2, linewidth = 1, force_overlay = true)

pU3 = plot(lb_u3, title = "LB Upper 3", color = cUp3, linewidth = 1, force_overlay = true)
pL3 = plot(lb_l3, title = "LB Lower 3", color = cDn3, linewidth = 1, force_overlay = true)

//=========================================================
// PLOTS EXTREME CHANNEL
//=========================================================
pUcIn  = plot(showExtremeCh ? lb_ucIn : na,  title = "LB Extreme Channel Upper Inner", color = cChUpIn,  linewidth = contraWidth, force_overlay = true)
pUcOut = plot(showExtremeCh ? lb_ucOut : na, title = "LB Extreme Channel Upper Outer", color = cChUpOut, linewidth = contraWidth, force_overlay = true)

pLcIn  = plot(showExtremeCh ? lb_lcIn : na,  title = "LB Extreme Channel Lower Inner", color = cChDnIn,  linewidth = contraWidth, force_overlay = true)
pLcOut = plot(showExtremeCh ? lb_lcOut : na, title = "LB Extreme Channel Lower Outer", color = cChDnOut, linewidth = contraWidth, force_overlay = true)

//=========================================================
// FILLS MAIN ONLY
//=========================================================
fill(pBasis, pU1, color = showFills ? color.new(cUp1, 90) : na, title = "LB Fill Basis Upper1")
fill(pBasis, pL1, color = showFills ? color.new(cDn1, 90) : na, title = "LB Fill Basis Lower1")

fill(pU1, pU2, color = showFills ? color.new(cUp2, 92) : na, title = "LB Fill Upper1 Upper2")
fill(pL1, pL2, color = showFills ? color.new(cDn2, 92) : na, title = "LB Fill Lower1 Lower2")

fill(pU2, pU3, color = showFills ? color.new(cUp3, 94) : na, title = "LB Fill Upper2 Upper3")
fill(pL2, pL3, color = showFills ? color.new(cDn3, 94) : na, title = "LB Fill Lower2 Lower3")

//=========================================================
// FILLS EXTREME CHANNEL ONLY
//=========================================================
fill(pUcIn, pUcOut, color = showExtremeCh ? color.new(cChUpIn, 86) : na, title = "LB Extreme Upper Channel")
fill(pLcIn, pLcOut, color = showExtremeCh ? color.new(cChDnIn, 86) : na, title = "LB Extreme Lower Channel")

//=========================================================
// BAR COLORS
//=========================================================
barcolor(showBarColors ? (close >= lb_basis ? color.new(cUp2, 75) : color.new(cDn2, 75)) : na)
````
