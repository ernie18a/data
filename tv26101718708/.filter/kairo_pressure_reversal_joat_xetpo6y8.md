# Kairo Pressure Reversal [JOAT]

- url: https://www.tradingview.com/script/xeTPo6Y8-Kairo-Pressure-Reversal-JOAT/
- type: indicator
- pine_id: PUB;0dd9b6f35f93416aad86f4917a577b9b
- version: 1.0

## Description

[b]Kairo Pressure Reversal [JOAT][/b]

[b]Introduction[/b]

Kairo Pressure Reversal is an open-source pressure-tensor study that maps how candle structure, volume, volatility stress, entropy, and pressure curvature interact. It is not a conventional POC or value-area script. Its purpose is to identify pressure shocks, curvature reversions, and compression states as market-context events.

[image]https://www.tradingview.com/x/58Nxevba/[/image]

[b]Core Concepts[/b]

[b]1. Pressure Atom[/b]

Each candle is converted into a signed pressure value using close location, body direction, wick balance, and volume.

[pine]
pressureAtom = (signedRange * 0.42 + bodyImpulse * 0.42 + wickBalance * 0.16) * volume
[/pine]

[b]2. Pressure Tensor[/b]

The pressure atom is normalized by recent absolute pressure and smoothed. This produces the main pressure tensor used throughout the indicator.

[b]3. Curvature and Jerk[/b]

The script calculates pressure velocity, curvature, and jerk. These values show how quickly pressure is changing rather than simply whether pressure is positive or negative.

[b]4. Entropy[/b]

Bid and ask energy are converted into an entropy score. Higher entropy means pressure is more balanced. Lower entropy means one side is more dominant.

[b]5. Stress Bands[/b]

ATR and pressure stress expand or contract the tensor bands. Events occur when price and pressure move into stressed areas with sufficient curvature.

[b]Features[/b]

[list]
[*][b]Pressure tensor:[/b] Normalized pressure model derived from candle structure and volume
[*][b]Curvature analysis:[/b] Tracks pressure velocity, curvature, and jerk
[*][b]Entropy score:[/b] Measures bid/ask balance
[*][b]Volatility stress rank:[/b] Uses ATR and range ranking to identify stressed conditions
[*][b]Shock cells:[/b] Compact boxes mark bid shocks, ask shocks, and reversion events
[*][b]Tensor bands:[/b] Adaptive bands visualize pressure expansion and stress
[*][b]Dashboard:[/b] Shows tensor, stress, entropy, curvature, jerk, and current event state
[/list]

[b]Input Parameters[/b]

[list]
[*]Tensor memory controls pressure normalization
[*]Entropy memory controls bid/ask energy balance
[*]Stress rank memory controls volatility ranking
[*]Shock gate controls event sensitivity
[*]Reversion gate controls curvature reversion sensitivity
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the tensor direction[/b]

Positive tensor values indicate bid-side pressure; negative values indicate ask-side pressure.

[b]Step 2: Watch stress and entropy[/b]

High stress with low entropy suggests one-sided pressure. High entropy suggests balance or compression.

[b]Step 3: Treat cells as context[/b]

Shock and reversion cells mark pressure events. They are not standalone trade recommendations.

[b]Indicator Limitations[/b]

[list]
[*]Volume-based pressure is an approximation from chart candles, not true order flow
[*]Curvature events can occur during volatility spikes that do not continue
[*]The indicator provides context, not certain reversal points
[/list]

[b]Originality Statement[/b]

Kairo Pressure Reversal is original in its combined use of candle-derived pressure, entropy, curvature, jerk, volatility stress, and compact event cells. It focuses on pressure behavior rather than standard oscillator thresholds.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Pressure events can fail or persist longer than expected. Always use independent analysis and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Kairo Pressure Reversal [JOAT]", shorttitle="KPR [JOAT]", overlay=true, max_lines_count=260, max_boxes_count=180, max_labels_count=120, max_bars_back=2200)

// Kairo Pressure Reversal [JOAT]
// Rebuilt as a pressure-tensor quant study focused on pressure curvature,
// entropy, volatility stress, impulse asymmetry, and compact shock cells.

groupCore = "Tensor Engine"
int tensorLen = input.int(34, "Tensor memory", minval=8, maxval=200, group=groupCore)
int entropyLen = input.int(55, "Entropy memory", minval=10, maxval=240, group=groupCore)
int stressLen = input.int(89, "Stress rank memory", minval=30, maxval=500, group=groupCore)
int smoothLen = input.int(13, "Tensor smoothing", minval=2, maxval=80, group=groupCore)
float shockGate = input.float(68.0, "Shock gate", minval=40.0, maxval=95.0, step=0.5, group=groupCore)
float reversionGate = input.float(57.0, "Reversion gate", minval=35.0, maxval=90.0, step=0.5, group=groupCore)

groupVisual = "Visual System"
bool showTensorBands = input.bool(true, "Show tensor bands", group=groupVisual)
bool showShockCells = input.bool(true, "Show shock cells", group=groupVisual)
bool showDashboard = input.bool(true, "Show dashboard", group=groupVisual)
bool paintCandles = input.bool(true, "Paint pressure candles", group=groupVisual)
int cellLife = input.int(34, "Shock cell life", minval=5, maxval=180, group=groupVisual)
int maxCells = input.int(34, "Maximum shock cells", minval=4, maxval=100, group=groupVisual)

color C_CYAN = color.rgb(8, 239, 251)
color C_MAGENTA = color.rgb(217, 2, 255)
color C_GOLD = color.rgb(255, 200, 0)
color C_TEAL = color.rgb(38, 166, 154)
color C_CORAL = color.rgb(239, 83, 80)
color C_VIOLET = color.rgb(125, 92, 255)
color C_PANEL = color.rgb(13, 16, 26)
color C_PANEL_2 = color.rgb(20, 24, 38)
color C_TEXT = color.rgb(226, 232, 240)
color C_DIM = color.rgb(130, 140, 160)
color C_CLEAR = color.rgb(0, 0, 0, 100)

f_clamp(float value, float floor, float ceiling) =>
    math.max(floor, math.min(ceiling, value))

f_safeDiv(float num, float den, float fallback) =>
    math.abs(den) > 0.0000001 ? num / den : fallback

f_rankColor(float value) =>
    color.from_gradient(value, 0.0, 100.0, C_CORAL, C_CYAN)

float rng = math.max(high - low, syminfo.mintick)
float body = close - open
float bodyAbs = math.abs(body)
float closeLocation = (close - low) / rng
float wickBalance = ((math.min(open, close) - low) - (high - math.max(open, close))) / rng
float signedRange = (closeLocation - 0.5) * 2.0
float bodyImpulse = body / rng
float pressureAtom = (signedRange * 0.42 + bodyImpulse * 0.42 + wickBalance * 0.16) * volume
float pressureNorm = f_safeDiv(pressureAtom, ta.ema(math.abs(pressureAtom), tensorLen), 0.0)
float pressureTensor = ta.ema(pressureNorm, smoothLen)
float pressureVelocity = pressureTensor - pressureTensor[1]
float pressureCurve = pressureVelocity - pressureVelocity[1]
float pressureJerk = pressureCurve - pressureCurve[1]

float atr = ta.atr(21)
float atrPct = close != 0.0 ? atr / close * 100.0 : 0.0
float stressRankRaw = ta.percentrank(atrPct, stressLen)
float stressRank = na(stressRankRaw) ? 50.0 : stressRankRaw
float rangeRankRaw = ta.percentrank(rng / close * 100.0, stressLen)
float rangeRank = na(rangeRankRaw) ? 50.0 : rangeRankRaw

float upEnergy = math.max(pressureAtom, 0.0)
float dnEnergy = math.max(-pressureAtom, 0.0)
float upShare = f_safeDiv(math.sum(upEnergy, entropyLen), math.sum(upEnergy + dnEnergy, entropyLen), 0.5)
float dnShare = 1.0 - upShare
float entropy = 0.0
entropy += upShare > 0.0 ? -upShare * math.log(upShare) : 0.0
entropy += dnShare > 0.0 ? -dnShare * math.log(dnShare) : 0.0
float entropyPct = f_clamp(entropy / math.log(2.0) * 100.0, 0.0, 100.0)
float directionalCertainty = 100.0 - entropyPct

float compressionScore = f_clamp(100.0 - stressRank, 0.0, 100.0)
float impulseScore = f_clamp(math.abs(pressureTensor) * 34.0 + rangeRank * 0.25 + directionalCertainty * 0.35, 0.0, 100.0)
float convexityScore = f_clamp(math.abs(pressureCurve) * 55.0 + math.abs(pressureJerk) * 25.0, 0.0, 100.0)
float stressComposite = f_clamp(stressRank * 0.38 + impulseScore * 0.34 + convexityScore * 0.28, 0.0, 100.0)

float basis = ta.ema(close, tensorLen)
float skew = ta.ema(pressureTensor, tensorLen)
float tensorWidth = atr * (0.85 + stressComposite / 90.0)
float upperTensor = basis + tensorWidth * (1.0 + math.max(skew, 0.0) * 0.12)
float lowerTensor = basis - tensorWidth * (1.0 + math.max(-skew, 0.0) * 0.12)
float upperShock = basis + tensorWidth * 1.75
float lowerShock = basis - tensorWidth * 1.75

bool bidShock = barstate.isconfirmed and pressureTensor > 0.0 and stressComposite >= shockGate and pressureCurve > 0.0
bool askShock = barstate.isconfirmed and pressureTensor < 0.0 and stressComposite >= shockGate and pressureCurve < 0.0
bool bidReversion = barstate.isconfirmed and close < lowerTensor and pressureCurve > 0.0 and stressComposite >= reversionGate
bool askReversion = barstate.isconfirmed and close > upperTensor and pressureCurve < 0.0 and stressComposite >= reversionGate
bool tensorCompression = barstate.isconfirmed and compressionScore > 68.0 and entropyPct > 62.0

color tensorColor = pressureTensor >= 0.0 ? color.from_gradient(stressComposite, 0.0, 100.0, C_TEAL, C_CYAN) : color.from_gradient(stressComposite, 0.0, 100.0, C_CORAL, C_MAGENTA)
color candleColor = pressureTensor >= 0.0 ? color.new(C_CYAN, stressComposite > shockGate ? 0 : 28) : color.new(C_MAGENTA, stressComposite > shockGate ? 0 : 28)

plotBasis = plot(basis, "KPR tensor mean", color=color.new(tensorColor, 0), linewidth=2)
plotUpper = plot(showTensorBands ? upperTensor : na, "KPR upper tensor", color=color.new(tensorColor, 26), linewidth=1)
plotLower = plot(showTensorBands ? lowerTensor : na, "KPR lower tensor", color=color.new(tensorColor, 26), linewidth=1)
plotUpperShock = plot(showTensorBands ? upperShock : na, "KPR upper stress", color=color.new(C_GOLD, 55), linewidth=1)
plotLowerShock = plot(showTensorBands ? lowerShock : na, "KPR lower stress", color=color.new(C_GOLD, 55), linewidth=1)
fill(plotUpper, plotLower, color=color.new(tensorColor, 90), title="KPR tensor field")
fill(plotUpperShock, plotUpper, color=color.new(C_MAGENTA, 94), title="KPR upper shock field")
fill(plotLower, plotLowerShock, color=color.new(C_CYAN, 94), title="KPR lower shock field")

barcolor(paintCandles ? candleColor : na)
bgcolor(tensorCompression ? color.new(C_GOLD, 93) : na, title="KPR compression background")

var box[] shockBoxes = array.new_box()
var label[] shockLabels = array.new_label()

f_prune() =>
    while array.size(shockBoxes) > maxCells
        box.delete(array.shift(shockBoxes))
    while array.size(shockLabels) > maxCells
        label.delete(array.shift(shockLabels))

f_cell(bool bidSide, string textValue) =>
    color base = bidSide ? C_CYAN : C_MAGENTA
    float top = bidSide ? math.max(close, upperTensor) : math.min(close, lowerTensor) + atr * 0.35
    float bot = bidSide ? math.max(close, upperTensor) - atr * 0.35 : math.min(close, lowerTensor)
    int x2 = bar_index + cellLife
    array.push(shockBoxes, box.new(bar_index, top, x2, bot, xloc=xloc.bar_index, bgcolor=color.new(base, 86), border_color=color.new(base, 18), text=textValue, text_color=C_TEXT, text_size=size.tiny))
    array.push(shockLabels, label.new(x2, (top + bot) * 0.5, textValue, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(base, 12), textcolor=bidSide ? color.rgb(5, 10, 14) : C_TEXT, size=size.tiny))
    f_prune()

if showShockCells and bidShock
    f_cell(true, "KPR BID TENSOR\nStress " + str.tostring(stressComposite, "#") + "\nEntropy " + str.tostring(entropyPct, "#"))
if showShockCells and askShock
    f_cell(false, "KPR ASK TENSOR\nStress " + str.tostring(stressComposite, "#") + "\nEntropy " + str.tostring(entropyPct, "#"))
if showShockCells and bidReversion
    f_cell(true, "KPR BID REVERT\nCurve " + str.tostring(pressureCurve, "#.00"))
if showShockCells and askReversion
    f_cell(false, "KPR ASK REVERT\nCurve " + str.tostring(pressureCurve, "#.00"))

plotshape(bidShock, "KPR bid shock", shape.square, location.belowbar, color=color.new(C_CYAN, 0), size=size.tiny, text="KPR", textcolor=color.rgb(5, 10, 14))
plotshape(askShock, "KPR ask shock", shape.square, location.abovebar, color=color.new(C_MAGENTA, 0), size=size.tiny, text="KPR", textcolor=C_TEXT)

var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(C_PANEL, 4), border_color=color.new(C_VIOLET, 45), border_width=1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Kairo Tensor", text_color=C_TEXT, bgcolor=color.new(tensorColor, 65), text_size=size.small)
    table.cell(dash, 1, 0, pressureTensor >= 0.0 ? "BID" : "ASK", text_color=tensorColor, bgcolor=color.new(tensorColor, 65), text_size=size.small)
    table.cell(dash, 0, 1, "Tensor", text_color=C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(pressureTensor, "#.00"), text_color=tensorColor, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 0, 2, "Stress", text_color=C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(stressComposite, "#.0"), text_color=f_rankColor(stressComposite), bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 0, 3, "Entropy", text_color=C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(entropyPct, "#.0") + "%", text_color=color.from_gradient(entropyPct, 0.0, 100.0, C_CYAN, C_GOLD), bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 0, 4, "Curvature", text_color=C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(pressureCurve, "#.00"), text_color=pressureCurve >= 0.0 ? C_CYAN : C_MAGENTA, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 0, 5, "Jerk", text_color=C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(pressureJerk, "#.00"), text_color=pressureJerk >= 0.0 ? C_CYAN : C_MAGENTA, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 0, 6, "Vol Stress", text_color=C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(stressRank, "#.0") + "%", text_color=f_rankColor(stressRank), bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 0, 7, "Compression", text_color=C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 1, 7, tensorCompression ? "ACTIVE" : "NONE", text_color=tensorCompression ? C_GOLD : C_DIM, bgcolor=C_PANEL, text_size=size.tiny)
    table.cell(dash, 0, 8, "Event", text_color=C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)
    table.cell(dash, 1, 8, bidShock ? "BID SHOCK" : askShock ? "ASK SHOCK" : bidReversion ? "BID REVERT" : askReversion ? "ASK REVERT" : "MONITOR", text_color=bidShock or bidReversion ? C_CYAN : askShock or askReversion ? C_MAGENTA : C_DIM, bgcolor=C_PANEL_2, text_size=size.tiny)

alertcondition(bidShock, "KPR Bid Tensor Shock [JOAT]", "Kairo Pressure Reversal [JOAT]: bid-side pressure tensor shock confirmed.")
alertcondition(askShock, "KPR Ask Tensor Shock [JOAT]", "Kairo Pressure Reversal [JOAT]: ask-side pressure tensor shock confirmed.")
alertcondition(bidReversion, "KPR Bid Curvature Reversion [JOAT]", "Kairo Pressure Reversal [JOAT]: bid-side curvature reversion confirmed.")
alertcondition(askReversion, "KPR Ask Curvature Reversion [JOAT]", "Kairo Pressure Reversal [JOAT]: ask-side curvature reversion confirmed.")
alertcondition(tensorCompression, "KPR Tensor Compression [JOAT]", "Kairo Pressure Reversal [JOAT]: entropy/compression state confirmed.")
````
