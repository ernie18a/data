# Arc Radius Trend [JOAT]

- url: https://www.tradingview.com/script/ZC1Iry0j-Arc-Radius-Trend-JOAT/
- type: indicator
- pine_id: PUB;7f7888a82120442fbfa4fd86dd83a890
- version: 1.0

## Description

[b]Arc Radius Trend [JOAT][/b]

[b]Introduction[/b]

Arc Radius Trend is an open-source, overlay-based trend-following system that replaces the static ATR band of conventional supertrend-style indicators with a curved, acceleration-responsive radius. The band does not scale linearly with volatility alone — it also responds to how fast price is accelerating or decelerating, expanding when momentum surges and tightening when price action becomes uniform. This gives it a shape that mirrors how institutional participants view momentum: not as a constant envelope, but as one that breathes with the market.

The problem ART solves is over-sensitivity. Standard ATR-based trailing stops flip direction too freely during acceleration events, producing false exits at exactly the moment when the trend is strongest. By expanding the radius during acceleration, ART gives trends room to breathe without permanently widening the band for all conditions.

[b]Core Concepts[/b]

[b]1. Velocity and Acceleration from Price[/b]

ART computes price velocity as the EMA of the bar-to-bar change in close, and acceleration as the EMA of the change in velocity. Both use the same smoothing length. Acceleration is normalized by ATR so that it is dimensionless and comparable across instruments and timeframes:

[pine]
velocity = ta.ema(ta.change(close), accelLength)
accel = ta.ema(ta.change(velocity), accelLength)
accelNorm = atr > 0 ? accel / atr : 0.0
[/pine]

[b]2. Curved Radius Scaling[/b]

The base radius is ATR multiplied by a configurable multiplier. The acceleration norm is then used to scale that radius with a power function, creating a nonlinear expansion curve. The exponent (Curve Strength) controls how aggressively acceleration widens the band:

[pine]
radiusScale = math.pow(1.0 + math.min(math.abs(accelNorm), 2.0), curvePower)
radius = atr * baseMult * radiusScale
[/pine]

[b]3. Ratcheting Band Logic[/b]

The active band ratchets in the direction of the current trend. When price is above the band (bull), the lower band is preserved at its maximum achieved value, preventing it from retreating while the trend holds. The trend flips when price closes through the opposite band:

[pine]
trend := close > upperBand[1] ? 1 : close < lowerBand[1] ? -1 : nz(trend[1], 1)
activeBand = trend == 1 ? lowerBand : upperBand
[/pine]

[image]https://www.tradingview.com/x/1ocQWxx5/[/image]

[b]4. JOAT Institutional Expansion Layer[/b]

Each JOAT indicator carries a shared Expansion Layer — an adaptive spine built from price efficiency, Shannon entropy, Parkinson range volatility, and a market impact ratio. The spine tracks the dominant flow using an KAMA-style adaptive constant, and its width is scaled by ATR ratio, range volatility, and noise. Stress and calm rails extend beyond the outer context boundary and change color based on composite stress readings. Bull and bear regime shift nodes mark confirmed directional transitions in the expansion layer state.

[b]Features[/b]

[list]
[*][b]Curved radius expansion:[/b] Band width nonlinearly expands during price acceleration events
[*][b]Ratcheting trend band:[/b] Lower band preserved on bull trend, upper band preserved on bear trend — no backward drift
[*][b]Outer envelope:[/b] A second ring outside the active band provides an extended volatility reference
[*][b]Trend-state candle coloring:[/b] Candles tinted to reflect current trend direction
[*][b]Regime flip nodes:[/b] Circle markers on the active band at confirmed bull and bear regime transitions
[*][b]JOAT Expansion Layer:[/b] Adaptive spine with efficiency/entropy scoring, context box, stress rails, calm rails, and shift nodes
[*][b]Stress and calm telemetry rails:[/b] Outer halos that widen with impact ratio and volatility stress
[*][b]Dashboard (top right):[/b] Live display of trend state, active band level, normalized acceleration, and last flip
[*][b]All signals on confirmed bars:[/b] No repainting — all state changes fire only on barstate.isconfirmed
[/list]

[b]Input Parameters[/b]

[b]Radius Model:[/b]
[list]
[*]Radius ATR Length: ATR period for radius computation (default: 21)
[*]Base Radius Multiplier: Baseline band width in ATR units (default: 2.4)
[*]Acceleration Smoothing: EMA length for velocity and acceleration (default: 8)
[*]Curve Strength: Power applied to acceleration scale — higher values expand the band more aggressively (default: 1.35)
[*]Outer Envelope: Multiplier for the secondary outer ring (default: 1.65)
[/list]

[b]Display:[/b]
[list]
[*]Trend-State Candles toggle
[*]Show Dashboard toggle
[/list]

[b]JOAT Expansion Layer:[/b]
[list]
[*]Efficiency, Entropy, Impact lengths; Adaptive Fast/Slow periods; Context Width
[*]Spine, Context Box, Regime Nodes, Candle Tint, Projection Bars, and Opacity toggles
[*]Independently configurable Bull, Bear, Neutral, and Accent colors
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Establish trend direction[/b]
Read the active band color and the dashboard. Green indicates bull trend; red indicates bear. Use this as the primary directional filter for entries.

[b]Step 2: Watch for confirmed flip nodes[/b]
Circle markers at confirmed trend reversals mark the bar where the band direction changed. These are not entry signals — they are context anchors. Evaluate what triggered the flip (structural break, momentum loss) before acting.

[b]Step 3: Use the outer envelope as a volatility reference[/b]
When price extends to the outer envelope, the market is in elevated acceleration. This is not necessarily a reversal signal — it may indicate trend continuation with excess momentum.

[b]Step 4: Read the Expansion Layer spine[/b]
The JOAT spine color and state convey institutional flow independent of the ART band. Bull spine with bull ART band is high-confidence alignment. Divergence between the two (e.g., bull ART, neutral spine) suggests weakening conditions.

[b]Indicator Limitations[/b]

[list]
[*]Acceleration-driven radius expansion may produce very wide bands during high-velocity events, temporarily reducing the band's usefulness as a stop reference
[*]The ratchet mechanism preserves the band in the trend direction — during prolonged consolidation, the band will not tighten until a directional break occurs
[*]On very low-liquidity instruments, the ATR-based radius may be structurally noisy; increasing the ATR length reduces this
[*]Arc Radius Trend does not generate entries. It identifies directional state and provides a trailing reference level
[/list]

[b]Originality Statement[/b]

Arc Radius Trend is original in its use of normalized price acceleration as a multiplicative, power-scaled modifier to ATR radius. Existing supertrend variants use static ATR multiples or linear volatility adjustments. The combination of:

[list]
[*]Velocity → acceleration derivation applied to a curved radius (not a flat multiplier)
[*]Power-function scaling that produces nonlinear radius expansion only during acceleration events
[*]Ratcheting band logic that is conditioned on the curved radius (not a fixed channel)
[*]An institutional expansion layer carrying efficiency, entropy, Parkinson range vol, and impact scoring as a second independent context layer
[/list]

...makes ART a structurally distinct contribution rather than a parameter variation of existing published work.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any instrument. Trading involves substantial risk of loss. Past behavior of this indicator does not guarantee future results. All signals should be validated within a complete trading framework that includes risk management. The author is not responsible for trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Arc Radius Trend [JOAT]", shorttitle="ART [JOAT]", overlay=true, max_labels_count=200)

atrLength = input.int(21, "Radius ATR Length", minval=1)
baseMult = input.float(2.4, "Base Radius Multiplier", minval=0.2, step=0.1)
accelLength = input.int(8, "Acceleration Smoothing", minval=1)
curvePower = input.float(1.35, "Curve Strength", minval=0.5, step=0.05)
outerMult = input.float(1.65, "Outer Envelope", minval=1.0, step=0.05)
showCandles = input.bool(true, "Trend-State Candles")
showDashboard = input.bool(true, "Show Dashboard")

hl2Value = hl2
atr = ta.atr(atrLength)
velocity = ta.ema(ta.change(close), accelLength)
accel = ta.ema(ta.change(velocity), accelLength)
accelNorm = atr > 0 ? accel / atr : 0.0
radiusScale = math.pow(1.0 + math.min(math.abs(accelNorm), 2.0), curvePower)
radius = atr * baseMult * radiusScale

upperBasic = hl2Value + radius
lowerBasic = hl2Value - radius

var float upperBand = na
var float lowerBand = na
upperBand := na(upperBand[1]) ? upperBasic : close[1] > upperBand[1] ? math.max(upperBasic, upperBand[1]) : upperBasic
lowerBand := na(lowerBand[1]) ? lowerBasic : close[1] < lowerBand[1] ? math.min(lowerBasic, lowerBand[1]) : lowerBasic

var int trend = 1
trend := close > upperBand[1] ? 1 : close < lowerBand[1] ? -1 : nz(trend[1], 1)
activeBand = trend == 1 ? lowerBand : upperBand
outerUpper = activeBand + radius * outerMult
outerLower = activeBand - radius * outerMult

confirmedBull = barstate.isconfirmed and trend == 1 and nz(trend[1], 1) == -1
confirmedBear = barstate.isconfirmed and trend == -1 and nz(trend[1], 1) == 1
trendColor = trend == 1 ? color.rgb(46, 125, 98) : color.rgb(177, 74, 68)

bandPlot = plot(activeBand, "Curved Radius Band", color=trendColor, linewidth=2)
outerUpperPlot = plot(outerUpper, "Outer Upper Envelope", color=color.new(color.rgb(52, 93, 150), 75))
outerLowerPlot = plot(outerLower, "Outer Lower Envelope", color=color.new(color.rgb(52, 93, 150), 75))
fill(outerUpperPlot, outerLowerPlot, color=color.new(color.rgb(52, 93, 150), 92), title="Radius Envelope")

plot(confirmedBull ? activeBand : na, "Confirmed Bull Regime Node", style=plot.style_circles, color=color.rgb(46, 125, 98), linewidth=3)
plot(confirmedBear ? activeBand : na, "Confirmed Bear Regime Node", style=plot.style_circles, color=color.rgb(177, 74, 68), linewidth=3)
barcolor(showCandles ? color.new(trendColor, 58) : na, title="Trend-State Candles")

alertcondition(confirmedBull, "ART confirmed bull regime", "Arc Radius Trend [JOAT]: confirmed bull regime flip.")
alertcondition(confirmedBear, "ART confirmed bear regime", "Arc Radius Trend [JOAT]: confirmed bear regime flip.")

var table dash = table.new(position.top_right, 2, 5, border_width=1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "ART", bgcolor=color.rgb(35, 38, 45), text_color=color.white)
    table.cell(dash, 1, 0, trend == 1 ? "Bull" : "Bear", bgcolor=trendColor, text_color=color.white)
    table.cell(dash, 0, 1, "Radius", text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(radius, format.mintick), text_color=color.white)
    table.cell(dash, 0, 2, "Accel", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(accelNorm, "#.##"), text_color=color.white)
    table.cell(dash, 0, 3, "Band", text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(activeBand, format.mintick), text_color=color.white)
    table.cell(dash, 0, 4, "Confirmed", text_color=color.white)
    table.cell(dash, 1, 4, confirmedBull ? "Bull Flip" : confirmedBear ? "Bear Flip" : "None", text_color=color.white)
else if not showDashboard and barstate.islast
    table.clear(dash, 0, 0, 1, 4)

//==============================================================================
// JOAT Institutional Expansion Layer
//==============================================================================

string joatGroupModel = "JOAT Expansion Model"
string joatGroupVisual = "JOAT Expansion Visuals"

bool joatEnable = input.bool(true, "Enable Expansion Layer", group=joatGroupModel)
int joatEfficiencyLength = input.int(34, "Efficiency Length", minval=8, maxval=200, group=joatGroupModel)
int joatEntropyLength = input.int(21, "Entropy Length", minval=8, maxval=150, group=joatGroupModel)
int joatImpactLength = input.int(34, "Impact Length", minval=8, maxval=200, group=joatGroupModel)
int joatAdaptiveFast = input.int(3, "Adaptive Fast", minval=2, maxval=20, group=joatGroupModel)
int joatAdaptiveSlow = input.int(34, "Adaptive Slow", minval=10, maxval=120, group=joatGroupModel)
float joatExpansionMult = input.float(1.35, "Context Width", minval=0.25, maxval=6.0, step=0.05, group=joatGroupModel)

bool joatShowSpine = input.bool(true, "Adaptive Spine", group=joatGroupVisual)
bool joatShowContext = input.bool(true, "Projected Context Box", group=joatGroupVisual)
bool joatShowNodes = input.bool(true, "Regime Nodes", group=joatGroupVisual)
bool joatTintCandles = input.bool(false, "Expansion Candle Tint", group=joatGroupVisual)
int joatProjectionBars = input.int(36, "Projection Bars", minval=8, maxval=160, group=joatGroupVisual)
int joatExpansionOpacity = input.int(88, "Expansion Opacity", minval=70, maxval=96, group=joatGroupVisual)

color joatBull = input.color(#00E5FF, "Expansion Bull", group=joatGroupVisual)
color joatBear = input.color(#FF1744, "Expansion Bear", group=joatGroupVisual)
color joatNeutral = input.color(#9E9E9E, "Expansion Neutral", group=joatGroupVisual)
color joatAccent = input.color(#FFC457, "Expansion Accent", group=joatGroupVisual)

f_joatClamp(float value, float floorValue, float ceilingValue) =>
    math.max(floorValue, math.min(ceilingValue, value))

f_joatSignedEfficiency(float source, int length) =>
    float netMove = source - source[length]
    float pathMove = math.sum(math.abs(ta.change(source)), length)
    pathMove != 0.0 ? netMove / pathMove : 0.0

f_joatEntropy(int length) =>
    float upEvents = math.sum(close > close[1] ? 1.0 : 0.0, length)
    float downEvents = math.sum(close < close[1] ? 1.0 : 0.0, length)
    float totalEvents = math.max(upEvents + downEvents, 1.0)
    float pUp = f_joatClamp(upEvents / totalEvents, 0.001, 0.999)
    float pDown = f_joatClamp(downEvents / totalEvents, 0.001, 0.999)
    -((pUp * math.log(pUp)) + (pDown * math.log(pDown))) / math.log(2.0)

f_joatParkinson(int length) =>
    float guardedRange = high > 0.0 and low > 0.0 ? math.log(high / low) : 0.0
    float variance = math.sum(guardedRange * guardedRange, length) / math.max(4.0 * math.log(2.0) * length, 1.0)
    math.sqrt(math.max(variance, 0.0))

f_joatImpact(int length) =>
    float guardedReturn = close > 0.0 and close[1] > 0.0 ? math.abs(math.log(close / close[1])) : 0.0
    float dollarVolume = math.max(close * volume, 1.0)
    ta.ema(guardedReturn / dollarVolume * 100000000.0, length)

float joatEfficiency = f_joatSignedEfficiency(close, joatEfficiencyLength)
float joatNoise = 1.0 - math.abs(joatEfficiency)
float joatEntropy = f_joatEntropy(joatEntropyLength)
float joatTrendPersistence = 1.0 - joatEntropy
float joatRangeVolatility = f_joatParkinson(joatImpactLength)
float joatImpact = f_joatImpact(joatImpactLength)
float joatImpactBase = ta.sma(joatImpact, joatImpactLength)
float joatImpactRatio = joatImpactBase > 0.0 ? joatImpact / joatImpactBase : 1.0
float joatAtrValue = ta.atr(math.max(5, joatEntropyLength))
float joatAtrBase = ta.sma(joatAtrValue, joatImpactLength)
float joatAtrRatio = joatAtrBase > 0.0 ? joatAtrValue / joatAtrBase : 1.0

float joatFastConstant = 2.0 / (joatAdaptiveFast + 1.0)
float joatSlowConstant = 2.0 / (joatAdaptiveSlow + 1.0)
float joatAdaptiveConstant = math.pow(math.abs(joatEfficiency) * (joatFastConstant - joatSlowConstant) + joatSlowConstant, 2.0)
var float joatSpine = na
joatSpine := na(joatSpine[1]) ? close : joatSpine[1] + joatAdaptiveConstant * (close - joatSpine[1])

float joatParticipation = volume / math.max(ta.sma(volume, joatImpactLength), 1.0)
float joatBodyEfficiency = math.abs(close - open) / math.max(high - low, syminfo.mintick)
float joatCloseLocation = (close - low) / math.max(high - low, syminfo.mintick)
float joatPressure = (joatCloseLocation - 0.5) * 2.0
float joatDirectionalScore = joatEfficiency * 45.0
float joatPersistenceScore = joatTrendPersistence * 25.0
float joatParticipationScore = f_joatClamp((joatParticipation - 1.0) * 15.0 + joatBodyEfficiency * joatPressure * 15.0, -25.0, 25.0)
float joatLiquidityPenalty = f_joatClamp((joatImpactRatio - 1.0) * 15.0, -20.0, 20.0)
float joatExpansionScore = ta.ema(joatDirectionalScore + joatPersistenceScore + joatParticipationScore - joatLiquidityPenalty, 5)

int joatExpansionState = joatExpansionScore > 35.0 ? 2 : joatExpansionScore > 12.0 ? 1 : joatExpansionScore < -35.0 ? -2 : joatExpansionScore < -12.0 ? -1 : 0
color joatStateColor = joatExpansionState > 0 ? joatBull : joatExpansionState < 0 ? joatBear : joatNeutral
float joatContextWidth = joatAtrValue * joatExpansionMult * f_joatClamp(0.65 + joatAtrRatio * 0.35 + joatRangeVolatility * 10.0, 0.65, 2.75)
float joatUpperContext = joatSpine + joatContextWidth
float joatLowerContext = joatSpine - joatContextWidth
float joatUpperInner = joatSpine + joatContextWidth * 0.5
float joatLowerInner = joatSpine - joatContextWidth * 0.5

joatSpinePlot = plot(joatEnable and joatShowSpine ? joatSpine : na, "JOAT Adaptive Spine", color=color.new(joatStateColor, 0), linewidth=2)
joatUpperPlot = plot(joatEnable ? joatUpperContext : na, "JOAT Upper Context", color=color.new(joatStateColor, 45))
joatLowerPlot = plot(joatEnable ? joatLowerContext : na, "JOAT Lower Context", color=color.new(joatStateColor, 45))
joatUpperInnerPlot = plot(joatEnable ? joatUpperInner : na, "JOAT Upper Inner", color=color.new(joatStateColor, 72))
joatLowerInnerPlot = plot(joatEnable ? joatLowerInner : na, "JOAT Lower Inner", color=color.new(joatStateColor, 72))

fill(joatUpperPlot, joatUpperInnerPlot, color=joatEnable ? color.new(joatStateColor, joatExpansionOpacity) : na, title="JOAT Upper Expansion Field")
fill(joatLowerInnerPlot, joatLowerPlot, color=joatEnable ? color.new(joatStateColor, joatExpansionOpacity) : na, title="JOAT Lower Expansion Field")
fill(joatUpperInnerPlot, joatLowerInnerPlot, color=joatEnable ? color.new(joatStateColor, 94) : na, title="JOAT Equilibrium Field")

bool joatBullShift = joatEnable and barstate.isconfirmed and joatExpansionState > 0 and joatExpansionState[1] <= 0
bool joatBearShift = joatEnable and barstate.isconfirmed and joatExpansionState < 0 and joatExpansionState[1] >= 0
plot(joatShowNodes and joatBullShift ? joatLowerInner : na, "JOAT Bull Expansion Node", style=plot.style_circles, color=joatBull, linewidth=3)
plot(joatShowNodes and joatBearShift ? joatUpperInner : na, "JOAT Bear Expansion Node", style=plot.style_circles, color=joatBear, linewidth=3)

var box joatContextBox = na
if barstate.isfirst
    joatContextBox := box.new(left=na, top=na, right=na, bottom=na, xloc=xloc.bar_index, bgcolor=color.new(joatStateColor, 92), border_color=color.new(joatAccent, 75))

if joatEnable and joatShowContext and barstate.islast
    box.set_lefttop(joatContextBox, bar_index - joatProjectionBars, joatUpperContext)
    box.set_rightbottom(joatContextBox, bar_index + joatProjectionBars, joatLowerContext)
    box.set_bgcolor(joatContextBox, color.new(joatStateColor, 92))
else if barstate.islast and not na(joatContextBox)
    box.set_lefttop(joatContextBox, na, na)
    box.set_rightbottom(joatContextBox, na, na)

barcolor(joatEnable and joatTintCandles ? color.new(joatStateColor, 45) : na, title="JOAT Expansion Candle Tint")
alertcondition(joatBullShift, "JOAT expansion bull shift", "JOAT expansion layer: bullish institutional shift confirmed.")
alertcondition(joatBearShift, "JOAT expansion bear shift", "JOAT expansion layer: bearish institutional shift confirmed.")

//------------------------------------------------------------------------------
// Expansion telemetry rails
//------------------------------------------------------------------------------

float joatConfidence = f_joatClamp(math.abs(joatExpansionScore) / 70.0, 0.0, 1.0)
float joatStress = f_joatClamp((joatImpactRatio - 1.0) * 0.5 + (joatAtrRatio - 1.0) * 0.35 + joatNoise * 0.15, 0.0, 1.0)
float joatCalm = 1.0 - joatStress
float joatMicroRange = ta.ema(high - low, 5)
float joatMacroRange = ta.ema(high - low, joatImpactLength)
float joatCompression = joatMacroRange > 0.0 ? joatMicroRange / joatMacroRange : 1.0
float joatUpperStressRail = joatUpperContext + joatAtrValue * (0.15 + joatStress * 0.35)
float joatLowerStressRail = joatLowerContext - joatAtrValue * (0.15 + joatStress * 0.35)
float joatUpperCalmRail = joatUpperInner + joatAtrValue * (0.05 + joatCalm * 0.15)
float joatLowerCalmRail = joatLowerInner - joatAtrValue * (0.05 + joatCalm * 0.15)
color joatStressColor = color.from_gradient(joatStress, 0.0, 1.0, joatAccent, joatBear)
color joatConfidenceColor = color.from_gradient(joatConfidence, 0.0, 1.0, joatNeutral, joatStateColor)

joatUpperStressPlot = plot(joatEnable ? joatUpperStressRail : na, "JOAT Upper Stress Rail", color=color.new(joatStressColor, 78))
joatLowerStressPlot = plot(joatEnable ? joatLowerStressRail : na, "JOAT Lower Stress Rail", color=color.new(joatStressColor, 78))
joatUpperCalmPlot = plot(joatEnable ? joatUpperCalmRail : na, "JOAT Upper Calm Rail", color=color.new(joatConfidenceColor, 82))
joatLowerCalmPlot = plot(joatEnable ? joatLowerCalmRail : na, "JOAT Lower Calm Rail", color=color.new(joatConfidenceColor, 82))
fill(joatUpperStressPlot, joatUpperPlot, color=joatEnable ? color.new(joatStressColor, 94) : na, title="JOAT Upper Stress Halo")
fill(joatLowerPlot, joatLowerStressPlot, color=joatEnable ? color.new(joatStressColor, 94) : na, title="JOAT Lower Stress Halo")
fill(joatUpperCalmPlot, joatSpinePlot, color=joatEnable ? color.new(joatConfidenceColor, 96) : na, title="JOAT Upper Confidence Wash")
fill(joatSpinePlot, joatLowerCalmPlot, color=joatEnable ? color.new(joatConfidenceColor, 96) : na, title="JOAT Lower Confidence Wash")

bool joatStressExpansion = joatEnable and barstate.isconfirmed and joatStress > 0.72 and joatStress[1] <= 0.72
bool joatRangeCompression = joatEnable and barstate.isconfirmed and joatCompression < 0.62 and joatCompression[1] >= 0.62
bgcolor(joatEnable and joatStressExpansion ? color.new(joatStressColor, 92) : na, title="JOAT Stress Background")
alertcondition(joatStressExpansion, "JOAT stress expansion", "JOAT expansion layer: volatility and impact stress expanded.")
alertcondition(joatRangeCompression, "JOAT range compression", "JOAT expansion layer: range compression confirmed.")
````
