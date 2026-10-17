# Golden Momentum Spectrum | NAL

- url: https://www.tradingview.com/script/YeUTT1SX-Golden-Momentum-Spectrum-NAL/
- type: indicator
- pine_id: PUB;3515960b7c5e494d963df3328b1fd319
- version: 1.0

## Description

[i]An ancient mathematical proportion, applied to modern market momentum.[/i]

The [b]Golden Momentum Spectrum[/b] is a multi-horizon momentum framework built around one of mathematics' most recognizable constants: the [b]Golden Ratio (φ ≈ 1.618)[/b].

Found throughout geometry, mathematical sequences, and natural growth patterns, the Golden Ratio has fascinated mathematicians for centuries because of its unusual proportional properties.

This indicator brings that same mathematical structure into quantitative market analysis.

Rather than measuring momentum over one arbitrarily selected period, the model constructs [b]three interconnected momentum horizons[/b], where both their temporal spacing and their relative influence are governed by the Golden Ratio.

The result is a volatility-normalized momentum spectrum designed to measure not only directional strength, but whether that strength remains consistent as the observation horizon expands.

[b]1. The Golden Ratio Architecture[/b]

The foundation of the model is the mathematical constant:

[b]φ = (1 + √5) / 2 ≈ 1.618034[/b]

Instead of manually selecting three unrelated momentum periods, the user defines a single starting horizon. The remaining horizons are derived through successive multiplication by φ.

[pine]
float GoldenRatio = math.phi

int MediumLen = math.max(FastLen + 1, int(math.round(FastLen * GoldenRatio)))
int SlowLen = math.max(MediumLen + 1, int(math.round(MediumLen * GoldenRatio)))
[/pine]

With the default starting horizon of 12, the model generates a sequence of approximately [b]12, 19, and 31 bars[/b].

This creates a proportional progression from shorter-term momentum to broader directional persistence.

The Golden Ratio is therefore not used as an arbitrary price target or Fibonacci retracement level.

[b]It determines the structure through which momentum is observed.[/b]

[b]2. Volatility-Normalized Momentum[/b]

Each horizon independently measures logarithmic price momentum, standardized by the prevailing volatility of single-bar log returns and the square root of its observation length.

[pine]
ready ? math.log(source / source[len]) / (sigma * math.sqrt(float(len))) : na
[/pine]

This normalization places the three momentum observations on a more comparable statistical scale.

Rather than allowing longer horizons to dominate simply because they encompass larger absolute price movements, the model evaluates directional displacement relative to its volatility environment.

The result is three distinct measurements of market momentum, each observing price through a different Golden Ratio-derived horizon.

[b]3. Golden-Weighted Aggregation[/b]

The Golden Ratio plays a second role in the model: determining how the three momentum horizons contribute to the final composite.

The weighting structure follows the proportions:

[b]φ² : φ : 1[/b]

[pine]
float WeightSum = GoldenRatio * GoldenRatio + GoldenRatio + 1.0

float WeightFast = GoldenRatio * GoldenRatio / WeightSum
float WeightMedium = GoldenRatio / WeightSum
float WeightSlow = 1.0 / WeightSum
[/pine]

This assigns approximately 50% of the composite weight to the fastest horizon, 31% to the intermediate horizon, and 19% to the slowest horizon.

The resulting [b]Golden Momentum[/b] series combines short-term responsiveness with progressively broader momentum context.

[b]4. Directional Consensus[/b]

Momentum strength alone does not determine the model's final state.

The indicator also evaluates directional agreement across the three horizons, requiring a configurable minimum number of components to support the composite direction.

[list=1]
[*][b]Bullish[/b] — Golden Momentum exceeds the upper threshold and sufficient horizons exhibit positive momentum.
[*][b]Bearish[/b] — Golden Momentum falls below the lower threshold and sufficient horizons exhibit negative momentum.
[*][b]Full Agreement[/b] — all three horizons share the same directional sign, indicating complete directional alignment across the Golden Ratio structure.
[/list]

Users can require agreement from two or all three horizons.

Once established, the directional state persists until the opposing conditions are satisfied, allowing the framework to distinguish temporary momentum disagreement from a confirmed regime transition.

[b]Visuals & Interpretation[/b]

[image]https://www.tradingview.com/x/LGVW6SBX/[/image]

The primary oscillator displays the Golden Momentum composite, with its color determined by the prevailing directional regime.

The visualization includes:

• A dynamically colored composite momentum curve.

• A stronger visual glow when all three momentum horizons agree.

• Gradient fills extending toward the relevant directional threshold.

• Optional display of the individual fast, medium, and slow momentum components.

• Trend-colored candles on the main price chart.

• Three selectable color themes: Standard, Nordic, and Simple.

The optional component display is particularly useful for examining how momentum evolves across the Golden Ratio sequence before the complete spectrum reaches directional agreement.

[b]Practical Application[/b]

Most conventional momentum indicators evaluate price over a single fixed horizon.

Golden Momentum Spectrum approaches the same problem from a different perspective:

[i]Does directional momentum remain coherent when the observation period expands according to the Golden Ratio?[/i]

Its combination of proportional horizon construction, volatility normalization, and directional consensus creates a structured framework for evaluating [b]momentum persistence, multi-horizon agreement, and changing directional regimes[/b].

The Golden Ratio is used as a deliberate mathematical design principle, rather than an assumption that markets must obey a particular numerical constant.

[b]The underlying idea is simple: measure momentum across time, but let mathematics determine the proportions.[/b]

[b]Automated Alerts[/b]

Two built-in alerts are available:

• [b]Bullish Transition[/b] — triggers when the model enters a confirmed bullish regime.

• [b]Bearish Transition[/b] — triggers when the model enters a confirmed bearish regime.

Both alert conditions require a confirmed bar and activate only when the directional state changes.

[b]Configuration[/b]

Users can customize the starting momentum horizon, volatility normalization period, minimum directional agreement, bullish and bearish thresholds, and visual presentation.

The Golden Ratio relationships are maintained automatically as the starting horizon changes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Golden Momentum Spectrum | NAL", shorttitle = "Golden Momentum Spectrum", overlay = false, precision = 3)


//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝


// ══════════════════════════════════════ ◈ Visuals ◈ ══════════════════════════════════════

string col_mode = input.string("Standard", "Color Mode", options = ["Standard", "Nordic", "Simple"], group = "Visuals")

[col_up, col_dn, col_nu] = switch col_mode
    "Standard" => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"   => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"   => [color.lime, color.red, color.gray]

bool showComponents = input.bool(false, "Show Individual Momentum Horizons", group = "Visuals")
bool showCandles = input.bool(true, "Color Candles", group = "Visuals")

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

string G1 = "Parameters"

float src = input.source(close, "Source", group = G1)
int FastLen = input.int(12, "Fast Horizon", minval = 2, maxval = 250, group = G1, tooltip = "The medium and slow horizons are generated automatically by multiplying the preceding horizon by the golden ratio.")

int VolLen = input.int(30, "Volatility Normalization Length", minval = 2, group = G1)
int MinAgreement = input.int(3, "Minimum Horizon Agreement", options = [2, 3], group = G1, tooltip = "Number of momentum horizons that must agree with the composite direction before the NAL trend changes.")

// ══════════════════════════════════════ ◈ Thresholds ◈ ══════════════════════════════════════

float uThreshold = input.float(0.50, "Bullish Threshold", step = 0.05, group = "Thresholds")
float lThreshold = input.float(0.00, "Bearish Threshold", step = 0.05, group = "Thresholds")

// ══════════════════════════════════════ ◈ Functions ◈ ══════════════════════════════════════

// Calculate logarithmic momentum standardized by single-bar return volatility.
f_normalized_momentum(series float source, simple int len, series float sigma) =>
    bool ready = not na(source[len]) and source > 0.0 and source[len] > 0.0 and not na(sigma) and sigma > 0.0

    ready ? math.log(source / source[len]) / (sigma * math.sqrt(float(len))) : na

// ══════════════════════════════════════ ◈ Golden Horizons ◈ ══════════════════════════════════════

float GoldenRatio = math.phi

int MediumLen = math.max(FastLen + 1, int(math.round(FastLen * GoldenRatio)))
int SlowLen = math.max(MediumLen + 1, int(math.round(MediumLen * GoldenRatio)))

// Golden-squared, golden ratio, and unity determine the three normalized weights.
float WeightSum = GoldenRatio * GoldenRatio + GoldenRatio + 1.0

float WeightFast = GoldenRatio * GoldenRatio / WeightSum
float WeightMedium = GoldenRatio / WeightSum
float WeightSlow = 1.0 / WeightSum

// ══════════════════════════════════════ ◈ Momentum Spectrum ◈ ══════════════════════════════════════

// Standard deviation of one-bar logarithmic returns.
float LogReturn = src > 0.0 and not na(src[1]) and src[1] > 0.0 ? math.log(src / src[1]) : na

float ReturnVolatility = ta.stdev(LogReturn, VolLen)

// Three independently measured momentum horizons.
float FastMomentum = f_normalized_momentum(src, FastLen, ReturnVolatility)
float MediumMomentum = f_normalized_momentum(src, MediumLen, ReturnVolatility)
float SlowMomentum = f_normalized_momentum(src, SlowLen, ReturnVolatility)

// Golden-weighted composite momentum.
float GoldenMom = FastMomentum * WeightFast + MediumMomentum * WeightMedium + SlowMomentum * WeightSlow

// ══════════════════════════════════════ ◈ Directional Agreement ◈ ══════════════════════════════════════

bool DataReady = not na(FastMomentum) and not na(MediumMomentum) and not na(SlowMomentum) and not na(GoldenMom)

int PositiveVotes = (FastMomentum > 0.0 ? 1 : 0) + (MediumMomentum > 0.0 ? 1 : 0) + (SlowMomentum > 0.0 ? 1 : 0)
int NegativeVotes = (FastMomentum < 0.0 ? 1 : 0) + (MediumMomentum < 0.0 ? 1 : 0) + (SlowMomentum < 0.0 ? 1 : 0)

bool Bullish = DataReady and PositiveVotes >= MinAgreement and GoldenMom > uThreshold
bool Bearish = DataReady and NegativeVotes >= MinAgreement and GoldenMom < lThreshold

bool FullAgreement = DataReady and (PositiveVotes == 3 or NegativeVotes == 3)

// ══════════════════════════════════════ ◈ NAL State ◈ ══════════════════════════════════════

int NAL = 0
NAL := Bullish ? 1 : Bearish ? -1 : nz(NAL[1], 0)

bool BullishFlip = barstate.isconfirmed and NAL == 1 and nz(NAL[1], 0) != 1
bool BearishFlip = barstate.isconfirmed and NAL == -1 and nz(NAL[1], 0) != -1

color col = NAL == 1 ? col_up : NAL == -1 ? col_dn : col_nu

// ══════════════════════════════════════ ◈ Gradient Geometry ◈ ══════════════════════════════════════

// Used for plotting.
float BullTop = math.max(GoldenMom, uThreshold)
float BullBottom = math.min(GoldenMom, uThreshold)

color BullTopColor = GoldenMom >= uThreshold ? color.new(col_up, 55) : color.new(col_up, 100)
color BullBottomColor = GoldenMom >= uThreshold ? color.new(col_up, 100) : color.new(col_up, 55)

// Bearish gradient fades from GoldenMom toward the bearish threshold.
float BearTop = math.max(GoldenMom, lThreshold)
float BearBottom = math.min(GoldenMom, lThreshold)

color BearTopColor = GoldenMom >= lThreshold ? color.new(col_dn, 55) : color.new(col_dn, 100)
color BearBottomColor = GoldenMom >= lThreshold ? color.new(col_dn, 100) : color.new(col_dn, 55)

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

// Zero-line reference.
ZeroPlot = plot(0.0, "Zero Line", color = color.new(col_nu, 80), linewidth = 1)

// Bullish and bearish thresholds.
uThresholdPlot = plot(uThreshold, "Bullish Threshold", color = color.new(col_up, 35), linewidth = 1)
lThresholdPlot = plot(lThreshold, "Bearish Threshold", color = color.new(col_dn, 35), linewidth = 1)

// Optional individual momentum horizons.
plot(showComponents ? FastMomentum : na, "Fast Golden Momentum", color = color.new(col_up, 65), linewidth = 1)
plot(showComponents ? MediumMomentum : na, "Medium Golden Momentum", color = color.new(col_nu, 50), linewidth = 1)
plot(showComponents ? SlowMomentum : na, "Slow Golden Momentum", color = color.new(col_dn, 65), linewidth = 1)

// Stronger NAL glow when all three momentum horizons agree.
plot(GoldenMom, "GoldenMom Glow", color = color.new(col, FullAgreement ? 65 : 90), linewidth = 6, display = display.pane)

GoldenMomPlot = plot(GoldenMom, "GoldenMom", color = col, linewidth = 2)

// ══════════════════════════════════════ ◈ Gradient Fill ◈ ══════════════════════════════════════

fill(GoldenMomPlot, uThresholdPlot, NAL == 1 ? BullTop : na, NAL == 1 ? BullBottom : na, BullTopColor, BullBottomColor, title = "Bullish Gradient", fillgaps = false)
fill(GoldenMomPlot, lThresholdPlot, NAL == -1 ? BearTop : na, NAL == -1 ? BearBottom : na, BearTopColor, BearBottomColor, title = "Bearish Gradient", fillgaps = false)

// ══════════════════════════════════════ ◈ Candle Colors ◈ ══════════════════════════════════════

plotcandle(open, high, low, close, "Bar Color", color = showCandles ? col : na, wickcolor = showCandles ? col : na, bordercolor = showCandles ? col : na, display = display.pane, force_overlay = true)

// ══════════════════════════════════════ ◈ Data Window ◈ ══════════════════════════════════════

plot(FastMomentum, "Fast Normalized Momentum", display = display.data_window)
plot(MediumMomentum, "Medium Normalized Momentum", display = display.data_window)
plot(SlowMomentum, "Slow Normalized Momentum", display = display.data_window)

plot(FastLen, "Fast Horizon Length", display = display.data_window)
plot(MediumLen, "Medium Horizon Length", display = display.data_window)
plot(SlowLen, "Slow Horizon Length", display = display.data_window)

plot(PositiveVotes, "Bullish Horizon Votes", display = display.data_window)
plot(NegativeVotes, "Bearish Horizon Votes", display = display.data_window)
plot(NAL, "NAL Direction", display = display.data_window)

// ══════════════════════════════════════ ◈ Alerts ◈ ══════════════════════════════════════

alertcondition(BullishFlip, "Golden Momentum Spectrum Bullish", "Golden Momentum Spectrum changed to bullish on {{ticker}}.")
alertcondition(BearishFlip, "Golden Momentum Spectrum Bearish", "Golden Momentum Spectrum changed to bearish on {{ticker}}.")
````
