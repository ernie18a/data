# Nexus Kinetic Reactor [JOAT]

- url: https://www.tradingview.com/script/1HPcg23a-Nexus-Kinetic-Reactor-JOAT/
- type: indicator
- pine_id: PUB;4c0c7111c0974b18869b2f30179dffa7
- version: 1.0

## Description

[b]Nexus Kinetic Reactor [JOAT][/b]

[b]Introduction[/b]

Nexus Kinetic Reactor estimates price as a noisy state process. It tracks state, velocity, uncertainty, confidence, and optional projection cones.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/TtBJs6m0/[/image]

[b]Core Concepts[/b]

[b]1. Recursive State Estimate[/b]

A smoothing lambda updates the estimated price state bar by bar.

[b]2. Velocity Regime[/b]

Changes in the state estimate create velocity and acceleration-style context.

[b]3. Uncertainty Bands[/b]

Noise windows and sigma bands show how uncertain the current estimate is.

[b]4. Confidence Gate[/b]

Signals require tracking confidence and expectancy thresholds before labels appear.

[pine]
state := state + lambdaAdjustment * (price - state)
[/pine]

[b]Features[/b]

[list]
[*]Recursive price-state estimator
[*]Velocity and acceleration regime logic
[*]Uncertainty bands
[*]Projection cone
[*]Blocked signal markers and dashboard
[/list]

[b]Input Parameters[/b]

[list]
[*]Smoothing lambda and noise window
[*]ATR length and velocity threshold
[*]Minimum confidence and expectancy
[*]Band sigma and projection bars
[*]Cone, candle, and panel toggles
[/list]


[b]How to Use This Script[/b]

Use the state estimate and uncertainty bands as kinetic context. Labels only appear when the model clears confidence and expectancy gates.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

Nexus is original in combining state estimation, velocity gating, uncertainty bands, expectancy filtering, and projection visualization.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Nexus Kinetic Reactor [JOAT]", shorttitle="NKR [JOAT]", overlay=true, max_lines_count=240, max_labels_count=120)

// Nexus Kinetic Reactor [JOAT]
// Original alpha-beta-gamma state estimator that tracks price position, velocity, acceleration, uncertainty, and regime expectancy.

string gCore = "State Engine"
string gRisk = "Signal Gate"
string gViz = "Visual System"
float lambda = input.float(0.85, "Smoothing lambda", minval=0.50, maxval=0.99, step=0.01, group=gCore)
int noiseLen = input.int(50, "Noise window", minval=20, maxval=200, group=gCore)
int atrLen = input.int(14, "ATR length", minval=5, maxval=100, group=gCore)
float trendGate = input.float(0.15, "Velocity threshold", minval=0.03, maxval=0.60, step=0.01, group=gCore)
float minR2 = input.float(0.45, "Minimum tracking confidence", minval=0.10, maxval=0.95, step=0.05, group=gRisk)
float minExpectancy = input.float(0.05, "Minimum regime expectancy", minval=-1, maxval=2, step=0.05, group=gRisk)
float bandMult = input.float(2.0, "Band sigma", minval=0.5, maxval=4, step=0.25, group=gViz)
int coneBars = input.int(8, "Projection bars", minval=2, maxval=20, group=gViz)
bool showCone = input.bool(true, "Show projection cone", group=gViz)
bool paintBars = input.bool(true, "Paint kinetic candles", group=gViz)
bool showPanel = input.bool(true, "Show panel", group=gViz)

color C_BULL = #00ffd5
color C_BEAR = #ff1744
color C_GOLD = #ffb300
color C_BLUE = #4f7cff
color C_BG = #080a12
color C_TEXT = #ffffff
color C_MUTED = #607d8b

safeDiv(float n, float d) =>
    d == 0.0 ? 0.0 : n / d

clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

clampInt(int v, int lo, int hi) =>
    math.max(lo, math.min(hi, v))

float alpha = 1.0 - math.pow(lambda, 3)
float beta = 1.5 * math.pow(1.0 - lambda, 2) * (1.0 + lambda)
float gammaGain = 0.5 * math.pow(1.0 - lambda, 3)
float src = close
var float xEst = na
var float vEst = 0.0
var float aEst = 0.0
if na(xEst)
    xEst := src
    vEst := 0.0
    aEst := 0.0

float xPred = xEst + vEst + 0.5 * aEst
float vPred = vEst + aEst
float aPred = aEst
float atr = ta.atr(atrLen)
float residual = src - xPred
float normResidual = safeDiv(math.abs(residual), math.max(atr, syminfo.mintick))
float gainBoost = normResidual > 3.0 ? math.min(2.5, 1.0 + (normResidual - 3.0) * 0.30) : 1.0
xEst := xPred + alpha * gainBoost * residual
vEst := vPred + beta * gainBoost * residual
aEst := aPred + gammaGain * gainBoost * residual

float error = src - xEst
float sigmaMeas = nz(ta.stdev(error, noiseLen), atr * 0.5)
float sigmaProc = nz(ta.stdev(aEst - aEst[1], noiseLen), 0.0)
float sigma = math.max(math.sqrt(math.pow(sigmaMeas, 2) + math.pow(sigmaProc * 10, 2)), atr * 0.1)
float varPrice = ta.variance(src, noiseLen)
float varError = ta.variance(error, noiseLen)
float r2 = varPrice > 0 ? clamp(1.0 - safeDiv(varError, varPrice), 0, 1) : 0
float vNorm = safeDiv(vEst, math.max(atr, syminfo.mintick))
float volRatio = safeDiv(atr, math.max(ta.sma(atr, 50), syminfo.mintick))
int trendState = vNorm > trendGate ? 0 : vNorm < -trendGate ? 2 : 1
int volState = volRatio < 0.80 ? 0 : volRatio > 1.20 ? 2 : 1
int regime = clampInt(trendState * 3 + volState, 0, 8)

var array<int> longWins = array.new_int(9, 0)
var array<int> longLoss = array.new_int(9, 0)
var array<int> shortWins = array.new_int(9, 0)
var array<int> shortLoss = array.new_int(9, 0)
var bool vtLong = false
var bool vtShort = false
var float vtEntry = na
var float vtTp = na
var float vtSl = na
var int vtReg = 0

if vtLong
    int r = clampInt(vtReg, 0, 8)
    if high >= vtTp
        array.set(longWins, r, array.get(longWins, r) + 1)
        vtLong := false
    else if low <= vtSl
        array.set(longLoss, r, array.get(longLoss, r) + 1)
        vtLong := false
if vtShort
    int r = clampInt(vtReg, 0, 8)
    if low <= vtTp
        array.set(shortWins, r, array.get(shortWins, r) + 1)
        vtShort := false
    else if high >= vtSl
        array.set(shortLoss, r, array.get(shortLoss, r) + 1)
        vtShort := false

float upper = xEst + sigma * bandMult
float lower = xEst - sigma * bandMult
bool touchLower = low <= lower and close > lower
bool touchUpper = high >= upper and close < upper
bool rawLong = touchLower and (aEst > 0 or vEst > vEst[1])
bool rawShort = touchUpper and (aEst < 0 or vEst < vEst[1])

int lw = array.get(longWins, regime)
int ll = array.get(longLoss, regime)
int sw = array.get(shortWins, regime)
int sl = array.get(shortLoss, regime)
float longTotal = lw + ll
float shortTotal = sw + sl
float longWr = longTotal > 0 ? lw / longTotal : 0.50
float shortWr = shortTotal > 0 ? sw / shortTotal : 0.50
float longEv = longWr * 2.0 - (1.0 - longWr) * 1.0 - 0.05
float shortEv = shortWr * 2.0 - (1.0 - shortWr) * 1.0 - 0.05
bool longGate = longEv >= minExpectancy and r2 >= minR2
bool shortGate = shortEv >= minExpectancy and r2 >= minR2
bool longState = barstate.isconfirmed and rawLong and longGate
bool shortState = barstate.isconfirmed and rawShort and shortGate
if rawLong and not vtLong and not vtShort
    vtLong := true
    vtEntry := close
    vtTp := close + atr * 2.0
    vtSl := close - atr
    vtReg := regime
if rawShort and not vtLong and not vtShort
    vtShort := true
    vtEntry := close
    vtTp := close - atr * 2.0
    vtSl := close + atr
    vtReg := regime

color theme = vEst > 0 ? C_BULL : vEst < 0 ? C_BEAR : C_BLUE
pUpper = plot(upper, "NKR upper kinetic band", color=color.new(theme, 65))
pLower = plot(lower, "NKR lower kinetic band", color=color.new(theme, 65))
plot(xEst, "NKR state estimate", color=color.new(C_TEXT, 8), linewidth=2)
fill(pUpper, pLower, color=color.new(theme, 89), title="NKR kinetic envelope")
plotshape(longState, "NKR long state", shape.labelup, location.belowbar, color=color.new(C_BULL, 8), text="NKR", textcolor=C_BG, size=size.tiny)
plotshape(shortState, "NKR short state", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 8), text="NKR", textcolor=C_TEXT, size=size.tiny)
plotshape(rawLong and not longGate, "NKR blocked long", shape.circle, location.belowbar, color=color.new(C_MUTED, 40), size=size.tiny)
plotshape(rawShort and not shortGate, "NKR blocked short", shape.circle, location.abovebar, color=color.new(C_MUTED, 40), size=size.tiny)
barcolor(paintBars ? vEst > 0 and aEst > 0 ? color.new(C_BULL, 8) : vEst > 0 ? color.new(C_BULL, 55) : vEst < 0 and aEst < 0 ? color.new(C_BEAR, 8) : vEst < 0 ? color.new(C_BEAR, 55) : na : na)

predX(float n) =>
    xEst + n * vEst + 0.5 * n * n * aEst

predSigma(float n) =>
    math.sqrt(math.pow(sigma, 2) + math.pow(n * sigma * 0.25, 2) + math.pow(0.5 * n * n * sigma * 0.08, 2))

var line[] coneLines = array.new_line()
var linefill[] coneFills = array.new_linefill()
if barstate.islast and showCone
    while array.size(coneLines) > 0
        line.delete(array.pop(coneLines))
    while array.size(coneFills) > 0
        linefill.delete(array.pop(coneFills))
    for i = 0 to coneBars - 1
        float n1 = i
        float n2 = i + 1
        float m1 = predX(n1)
        float m2 = predX(n2)
        float s1 = predSigma(n1)
        float s2 = predSigma(n2)
        line lu = line.new(bar_index + i, m1 + s1, bar_index + i + 1, m2 + s2, color=color.new(theme, 35))
        line ld = line.new(bar_index + i, m1 - s1, bar_index + i + 1, m2 - s2, color=color.new(theme, 35))
        line lm = line.new(bar_index + i, m1, bar_index + i + 1, m2, color=color.new(C_TEXT, 60), style=line.style_dotted)
        linefill lf = linefill.new(lu, ld, color.new(theme, 89))
        array.push(coneLines, lu)
        array.push(coneLines, ld)
        array.push(coneLines, lm)
        array.push(coneFills, lf)

var table panel = na
if showPanel and barstate.islast
    if na(panel)
        panel := table.new(position.top_right, 2, 8, bgcolor=color.new(C_BG, 5), border_color=color.new(C_TEXT, 82), border_width=1)
    table.cell(panel, 0, 0, "NEXUS", text_color=C_TEXT, bgcolor=color.new(theme, 72), text_size=size.small)
    table.cell(panel, 1, 0, "NKR", text_color=C_TEXT, bgcolor=color.new(theme, 72), text_size=size.small)
    table.cell(panel, 0, 1, "Velocity", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 1, str.tostring(vNorm, "#.###"), text_color=theme, text_size=size.small)
    table.cell(panel, 0, 2, "Accel", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 2, str.tostring(aEst, "#.####"), text_color=aEst >= 0 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 0, 3, "R2", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 3, str.tostring(r2, "#.###"), text_color=r2 >= minR2 ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(panel, 0, 4, "Regime", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 4, str.tostring(regime), text_color=C_TEXT, text_size=size.small)
    table.cell(panel, 0, 5, "Long EV", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 5, str.tostring(longEv, "#.##"), text_color=longGate ? C_BULL : C_MUTED, text_size=size.small)
    table.cell(panel, 0, 6, "Short EV", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 6, str.tostring(shortEv, "#.##"), text_color=shortGate ? C_BEAR : C_MUTED, text_size=size.small)
    table.cell(panel, 0, 7, "Volatility", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 7, str.tostring(volRatio, "#.##") + "x", text_color=volRatio > 1.2 ? C_GOLD : C_TEXT, text_size=size.small)

alertcondition(longState, "NKR Long [JOAT]", "Nexus Kinetic Reactor long state")
alertcondition(shortState, "NKR Short [JOAT]", "Nexus Kinetic Reactor short state")
````
