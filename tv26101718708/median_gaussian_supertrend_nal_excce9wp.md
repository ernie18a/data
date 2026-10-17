# Median Gaussian SuperTrend | NAL

- url: https://www.tradingview.com/script/ExCCE9wP-Median-Gaussian-SuperTrend-NAL/
- type: indicator
- pine_id: PUB;f4595c791da343599b6f57e2d7c0d07a
- version: 1.0

## Description

Median Gaussian SuperTrend is a trend-following framework that replaces the conventional SuperTrend volatility structure with a [b]median-filtered Gaussian baseline and Gaussian-weighted deviation model[/b].

The objective is to preserve the intuitive regime behavior of SuperTrend while producing a smoother underlying price structure and a volatility envelope that is less dependent on isolated observations.

Instead of building the trend state around ATR alone, the model combines [b]median filtering, Gaussian smoothing, and Gaussian-weighted dispersion[/b] before converting the resulting bands into a trailing directional structure.

[b]1. Median Gaussian Basis[/b]

The calculation begins by extracting the rolling median of the selected source. Median filtering reduces the influence of isolated price extremes before the series enters the Gaussian filter.

[pine]median_raw = ta.median(fil_src, base_len)
median_base = gaussianFilter(median_raw, base_len, gaussian_sig)[/pine]

The resulting baseline therefore represents a smoothed estimate of underlying price structure rather than a conventional moving average.

[b]2. Gaussian Volatility Structure[/b]

Volatility around the baseline is estimated using a Gaussian-weighted deviation calculation.

Observations are not treated equally across the lookback window. Instead, the dispersion calculation uses Gaussian weights to construct both its weighted mean and weighted variance.

The resulting volatility estimate defines asymmetric upper and lower envelopes:

[pine]RawUpper = median_base + sd_range * sd_mul
RawLower = median_base - sd_range * sd_mulb[/pine]

Separate upper and lower multipliers allow the structure to be calibrated independently on each side of the market.

[b]3. SuperTrend Conversion[/b]

The raw Gaussian bands are then transformed into persistent trailing boundaries using SuperTrend-style state logic.

The active boundary only resets when price structurally clears the opposing band. This converts the continuously changing Gaussian envelope into a discrete [b]bullish or bearish trend regime[/b].

[pine]SuperTrend := Direction == -1 ? LowerBand : UpperBand[/pine]

[list=1]
[*][b]Bullish[/b] — the lower Gaussian boundary becomes the active trailing structure.
[*][b]Bearish[/b] — the upper Gaussian boundary becomes the active trailing structure.
[/list]

[b]Visuals & Interpretation[/b]

Only the currently active SuperTrend boundary is displayed.

A directional gradient extends between the active boundary and the candle body, visually showing the relationship between price and the current trend structure without plotting the inactive side of the envelope.

Candles are colored according to the prevailing model state:

[list=1]
[*][b]Bullish color[/b] — Median Gaussian SuperTrend is in its bullish regime.
[*][b]Bearish color[/b] — Median Gaussian SuperTrend is in its bearish regime.
[/list]

Three color presets — Standard, Nordic, and Simple — are included for chart customization.

[b]Practical Application[/b]

Median Gaussian SuperTrend is designed as a clean directional framework for identifying [b]trend state, structural transitions, and volatility-adjusted trailing levels[/b].

The combination of median preprocessing and Gaussian weighting makes the model particularly useful when the goal is to extract persistent directional structure while reducing sensitivity to short-lived price disturbances.

The Gaussian length, sigma, volatility horizon, and independent upper/lower band multipliers can all be adjusted to control the model's responsiveness.

[b]Automated Alerts[/b]

Built-in alerts are provided for both directional transitions:

[list=1]
[*][b]Bullish Flip[/b] — triggers when the active Median Gaussian SuperTrend changes from bearish to bullish.
[*][b]Bearish Flip[/b] — triggers when the active Median Gaussian SuperTrend changes from bullish to bearish.
[/list]

For closed-bar signal confirmation, configure TradingView alerts to trigger [b]Once Per Bar Close[/b].

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NordicAlphaLab

//@version=6
indicator("Median Gaussian SuperTrend | NAL", shorttitle = "Median Gaussian SuperTrend", overlay = true)

//                                     ███╗   ██╗ █████╗ ██╗
//                                     ████╗  ██║██╔══██╗██║
//                                     ██╔██╗ ██║███████║██║
//                                     ██║╚██╗██║██╔══██║██║
//                                     ██║ ╚████║██║  ██║███████╗
//                                     ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

// ══════════════════════════════════════ ◈ Visuals ◈ ══════════════════════════════════════

string col_mode = input.string("Standard", title = "Color Mode", group = "Visuals", options = ["Standard", "Nordic", "Simple"])

[col_up, col_dn, col_nu] = switch col_mode
    "Standard" => [color.rgb(0, 255, 200), color.rgb(32, 94, 144), color.gray]
    "Nordic"   => [color.rgb(46, 161, 255), color.rgb(150, 154, 169), color.gray]
    "Simple"   => [color.lime, color.red, color.gray]

// ══════════════════════════════════════ ◈ Functions ◈ ══════════════════════════════════════

// Gaussian Line
gaussianFilter(src, len, sigma) =>
    float totalWeight = 0.0
    float weightedSum = 0.0

    for i = 0 to len - 1
        float weight = math.exp(-0.5 * math.pow((i - (len - 1) / 2) / sigma, 2))
        totalWeight += weight
        weightedSum += src[i] * weight

    weightedSum / totalWeight

// Gaussian Deviation
gaussianDeviation(src, period) =>
    array<float> weights = array.new_float()
    float sumw = 0.0

    for i = 0 to period - 1
        float w = math.exp(-math.pow((i / period) / 2, 2))
        array.push(weights, w)
        sumw += w

    float wmean = 0.0

    for i = 0 to period - 1
        wmean += src[i] * array.get(weights, i)

    wmean := wmean / sumw

    float wvar = 0.0

    for i = 0 to period - 1
        float diff = src[i] - wmean
        wvar += math.pow(diff, 2) * array.get(weights, i)

    math.sqrt(wvar / sumw)

// ══════════════════════════════════════ ◈ Inputs ◈ ══════════════════════════════════════

float fil_src = input.source(close, "Source")
int base_len = input.int(16, "Gaussian Length", minval = 1, inline = "GAUS")
float gaussian_sig = input.float(5.0, "Sigma", minval = 0.1, step = 0.1, inline = "GAUS")

int sd_len = input.int(20, "Gaussian Volatility Length", minval = 2)
float sd_mul = input.float(2.5, "Upper Band", minval = 0.1, step = 0.1, inline = "BB")
float sd_mulb = input.float(2.0, "Lower Band", minval = 0.1, step = 0.1, inline = "BB")

// ══════════════════════════════════════ ◈ Median Gaussian Basis ◈ ══════════════════════════════════════

float median_raw = ta.median(fil_src, base_len)
float median_base = gaussianFilter(median_raw, base_len, gaussian_sig)
float sd_range = gaussianDeviation(median_base, sd_len)

float RawUpper = median_base + sd_range * sd_mul
float RawLower = median_base - sd_range * sd_mulb

// ══════════════════════════════════════ ◈ Median Gaussian SuperTrend ◈ ══════════════════════════════════════

// Raw Gaussian bands become trailing SuperTrend bands.

float UpperBand = RawUpper
float LowerBand = RawLower

float PreviousUpperBand = nz(UpperBand[1], UpperBand)
float PreviousLowerBand = nz(LowerBand[1], LowerBand)

UpperBand := UpperBand < PreviousUpperBand or close[1] > PreviousUpperBand ? UpperBand : PreviousUpperBand
LowerBand := LowerBand > PreviousLowerBand or close[1] < PreviousLowerBand ? LowerBand : PreviousLowerBand

int Direction = na
float SuperTrend = na
float PreviousSuperTrend = SuperTrend[1]

if na(sd_range[1])
    Direction := 1
else if PreviousSuperTrend == PreviousUpperBand
    Direction := close > UpperBand ? -1 : 1
else
    Direction := close < LowerBand ? 1 : -1

SuperTrend := Direction == -1 ? LowerBand : UpperBand

bool Bullish = Direction == -1
bool Bearish = Direction == 1

bool BullishFlip = Bullish and not Bullish[1]
bool BearishFlip = Bearish and not Bearish[1]

color col = Bullish ? col_up : Bearish ? col_dn : col_nu

// ══════════════════════════════════════ ◈ Gradient Geometry ◈ ══════════════════════════════════════

float BodyAnchor = math.avg(open, close)

float GradientTop = math.max(BodyAnchor, SuperTrend)
float GradientBottom = math.min(BodyAnchor, SuperTrend)

bool BandAboveBody = SuperTrend >= BodyAnchor
color BullTopColor = BandAboveBody ? color.new(col_up, 50) : color.new(col_up, 100)
color BullBottomColor = BandAboveBody ? color.new(col_up, 100) : color.new(col_up, 50)

color BearTopColor = BandAboveBody ? color.new(col_dn, 50) : color.new(col_dn, 100)
color BearBottomColor = BandAboveBody ? color.new(col_dn, 100) : color.new(col_dn, 50)

// ══════════════════════════════════════ ◈ Plots ◈ ══════════════════════════════════════

// Invisible candle-body anchor used only to terminate the gradient at price.
BodyPlot = plot(BodyAnchor, "Candle Body Anchor", color = na, display = display.none)

// Only the active SuperTrend boundary is displayed.
BullPlot = plot(Bullish ? SuperTrend : na, "Bullish Median Gaussian SuperTrend", color = col_up, linewidth = 2, style = plot.style_linebr)
BearPlot = plot(Bearish ? SuperTrend : na, "Bearish Median Gaussian SuperTrend", color = col_dn, linewidth = 2, style = plot.style_linebr)

// Smooth vertical gradient from the active SuperTrend boundary into the bars.
fill(BodyPlot, BullPlot, Bullish ? GradientTop : na, Bullish ? GradientBottom : na, BullTopColor, BullBottomColor, title = "Bullish Gradient", fillgaps = false)
fill(BodyPlot, BearPlot, Bearish ? GradientTop : na, Bearish ? GradientBottom : na, BearTopColor, BearBottomColor, title = "Bearish Gradient", fillgaps = false)

plot(Bullish ? SuperTrend : na, "Bullish SuperTrend Glow", color = color.new(col_up, 55), linewidth = 5, style = plot.style_linebr, display = display.pane)
plot(Bearish ? SuperTrend : na, "Bearish SuperTrend Glow", color = color.new(col_dn, 55), linewidth = 5, style = plot.style_linebr, display = display.pane)
plot(Bullish ? SuperTrend : na, "Bullish SuperTrend Edge", color = col_up, linewidth = 2, style = plot.style_linebr, display = display.pane)
plot(Bearish ? SuperTrend : na, "Bearish SuperTrend Edge", color = col_dn, linewidth = 2, style = plot.style_linebr, display = display.pane)

// Trend-colored candles.
plotcandle(open, high, low, close, "Bar Color", color = col, wickcolor = col, bordercolor = col, display = display.pane, force_overlay = true)

// ══════════════════════════════════════ ◈ Alerts ◈ ══════════════════════════════════════

alertcondition(BullishFlip, "Median Gaussian SuperTrend Bullish", "Median Gaussian SuperTrend changed to bullish on {{ticker}}.")
alertcondition(BearishFlip, "Median Gaussian SuperTrend Bearish", "Median Gaussian SuperTrend changed to bearish on {{ticker}}.")
````
