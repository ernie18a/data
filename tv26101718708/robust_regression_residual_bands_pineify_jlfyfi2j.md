# Robust Regression Residual Bands [Pineify]

- url: https://www.tradingview.com/script/JLFyfi2j-Robust-Regression-Residual-Bands-Pineify/
- type: indicator
- pine_id: PUB;2a6d2a4cf6c74ea39de78c0580446f46
- version: 1.0

## Description

[b]Robust Regression Residual Bands [Pineify][/b]

[b]Overview[/b]
This overlay fits a rolling line while bounding influence from unusual closes. It shows a robust center, two MAD shells, confirmed extremes, and an optional dashboard. It is context, not a forecast.

[b]Problem Definition[/b]
Least-squares channels and standard deviation magnify large errors. One gap, wick, or bad print can rotate the line and widen its bands, changing both the reference and the meaning of “far.” Short windows add noise; long ones preserve distortion. The invariant is that ordinary observations define the path, extremes stay visible, and their influence remains bounded.

[b]Design Rationale[/b]
Regression stays because slope and residual distance answer different questions. Finite Huber-style refits replace unrestricted influence: residuals inside a threshold keep full weight; those outside receive progressively less. Hard deletion was rejected because values switch abruptly at a cutoff. Final scale uses median absolute deviation (MAD) times 1.4826. MAD resists isolated extremes but is less efficient for Gaussian errors. Two passes balance refreshed weights with bounded workload; users may select one to three.

[b]Key Features[/b]
[list]
[*]Rolling regression with bounded influence refits.
[*]Two shells sized from final residual MAD.
[*]Center color for normalized slope.
[*]Confirmed outer-entry diamonds.
[*]Optional bar color and dashboard for residual z, slope/MAD, scale, window, and passes.
[/list]

[b]How It Works[/b]
Each bar loads a chronological rolling window and fits an equal-weight line. It finds every residual, their median, and median absolute distance from that median. MAD times 1.4826 becomes robust scale; minimum tick prevents zero division.

Each distance is compared with clipping threshold times scale. Inside values keep weight 1. Outside values receive threshold divided by distance, smoothly capping influence. The line is refitted for the selected passes; residual median and MAD are then recomputed. Displayed center is the newest fit plus median residual.

Bands equal center plus or minus selected MAD multiples. Residual z divides current distance by scale; slope divided by scale controls color. A full window without missing data is required. Open-bar values can change; markers and alerts require confirmation.

[b]How Multiple Indicators Work Together[/b]
These are causal stages, not unrelated indicators. Regression supplies direction but needs clipping to limit leverage. Clipping needs scale, and MAD prevents the same extreme from dominating it. Final residual measures price against the stabilized path; normalized slope separates direction from dispersion. Without refitting, bands inherit a tilted center; without scale, distance is not comparable. All visuals expose one model.

[b]Trading Ideas and Insights[/b]
A confirmed outer entry means the close is unusual relative to current path and scale; it does not imply reversal. Alignment with strong slope can describe expansion, while repeated extremes with flattening slope can motivate a balance review. Alternating center crosses expose noise. Compare states with structure, liquidity, events, and risk controls. The script provides no entries, stops, sizing, or expected returns.

[b]Unique Aspects[/b]
The contribution couples bounded influence refits with a median-centered MAD field. Common channels let an extreme affect slope and width through squared error. Here distance sets a smooth influence cap, the line is rebuilt, and final residuals size the tunnel. Median residual shifts the newest fit instead of assuming zero arithmetic mean. Center is primary, shells encode distance, and amber diamonds encode confirmed entries—not probability.

[b]How to Use[/b]
[list=1]
[*]Add it to a standard chart and wait for a full window.
[*]Choose a window matching the horizon and review several regimes.
[*]Read center color as normalized direction and bands as robust distance.
[*]Use the dashboard to compare raw and scale-relative movement.
[*]Alert on confirmed outer entry or center crossing, then apply independent context and risk rules.
[/list]
Secondary layers can be disabled without changing the model.

[b]Customization[/b]
Short windows adapt faster and vary more; long ones smooth more and retain old regimes. Extra refit passes can limit leverage further but cost computation and may underweight a true break. Lower clipping resists extremes sooner; higher clipping approaches ordinary regression. MAD multiples set tunnel thresholds, with a minimum shell gap enforced. Visual layers and palette are independent. Defaults are not universal optima.

[b]Assumptions and Limitations[/b]
The model assumes a useful local line and comparable source data. Curves, breaks, gaps, rolls, illiquidity, adjusted history, and non-standard charts weaken it. Robust weights bound influence but cannot label an extreme as error or regime change. Results lag, parameters matter, and small MAD makes flat markets sensitive to the tick floor.

Open-bar values may change. Confirmed alerts still depend on feed and settings. Missing data restarts warm-up. The script has no volume, order flow, higher-timeframe request, future value, pivot, or simulation. It estimates neither reversal probability nor fair value, execution, risk, or profit. Outer distance is deviation, not proof of return.

[b]Conclusion[/b]
Bounded refits stabilize rolling path, MAD stabilizes scale, and the tunnel exposes both. Treat distance and direction as lagging context, not a forecast; use independent confirmation.

## Source Code

````pine
//@version=6
indicator("Robust Regression Residual Bands [Pineify]", shorttitle="RRRB [Pineify]", overlay=true, max_bars_back=500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string GROUP_MODEL = "Robust model"
string GROUP_BANDS = "Residual tunnel"
string GROUP_VISUALS = "Secondary layers"

source = input.source(close, "Source", group=GROUP_MODEL)
length = input.int(80, "Rolling window", minval=20, maxval=200, group=GROUP_MODEL)
passes = input.int(2, "Robust refit passes", minval=1, maxval=3, group=GROUP_MODEL)
clipMultiple = input.float(1.75, "Influence clipping threshold", minval=1.0, maxval=4.0, step=0.05, group=GROUP_MODEL, tooltip="Residuals beyond this multiple of robust scale receive progressively less influence.")

innerInput = input.float(1.0, "Inner MAD multiple", minval=0.5, maxval=3.0, step=0.1, group=GROUP_BANDS)
outerInput = input.float(2.5, "Outer MAD multiple", minval=1.0, maxval=6.0, step=0.1, group=GROUP_BANDS)
showTunnel = input.bool(true, "Show residual tunnel", group=GROUP_BANDS)
showOutliers = input.bool(true, "Show confirmed extreme entries", group=GROUP_VISUALS)
paintBars = input.bool(false, "Color extreme bars", group=GROUP_VISUALS)
showDashboard = input.bool(true, "Show state dashboard", group=GROUP_VISUALS)

bullColor = input.color(color.rgb(24, 190, 168), "Positive slope", group=GROUP_VISUALS)
bearColor = input.color(color.rgb(239, 102, 91), "Negative slope", group=GROUP_VISUALS)
neutralColor = input.color(color.rgb(143, 151, 166), "Flat slope", group=GROUP_VISUALS)
extremeColor = input.color(color.rgb(245, 184, 65), "Extreme residual", group=GROUP_VISUALS)

//------------------------------------------------------------------------------
// Robust rolling regression
//------------------------------------------------------------------------------
f_median(array<float> values) =>
    array<float> sorted = array.copy(values)
    array.sort(sorted, order.ascending)
    int size = array.size(sorted)
    int middle = int(math.floor(size * 0.5))
    float result = na
    if size > 0
        result := size % 2 == 1 ? array.get(sorted, middle) : (array.get(sorted, middle - 1) + array.get(sorted, middle)) * 0.5
    result

f_fit(array<float> values, array<float> weights) =>
    int size = array.size(values)
    float sumW = 0.0
    float sumX = 0.0
    float sumY = 0.0
    float sumXX = 0.0
    float sumXY = 0.0
    for index = 0 to size - 1
        float weight = array.get(weights, index)
        float x = float(index)
        float y = array.get(values, index)
        sumW += weight
        sumX += weight * x
        sumY += weight * y
        sumXX += weight * x * x
        sumXY += weight * x * y
    float denominator = sumW * sumXX - sumX * sumX
    float slope = math.abs(denominator) > 1e-12 ? (sumW * sumXY - sumX * sumY) / denominator : 0.0
    float intercept = sumW > 0.0 ? (sumY - slope * sumX) / sumW : na
    [intercept, slope]

f_robust_model(series float src, int window, int refitPasses, float clipping) =>
    array<float> values = array.new<float>()
    array<float> weights = array.new<float>()
    for index = 0 to window - 1
        array.push(values, src[window - 1 - index])
        array.push(weights, 1.0)

    [fitIntercept, fitSlope] = f_fit(values, weights)
    float residualMedian = 0.0
    float robustScale = syminfo.mintick

    for iteration = 0 to refitPasses - 1
        array<float> residuals = array.new<float>()
        for index = 0 to window - 1
            float fitted = fitIntercept + fitSlope * float(index)
            array.push(residuals, array.get(values, index) - fitted)

        residualMedian := f_median(residuals)
        array<float> deviations = array.new<float>()
        for index = 0 to window - 1
            array.push(deviations, math.abs(array.get(residuals, index) - residualMedian))
        robustScale := math.max(1.4826 * f_median(deviations), syminfo.mintick)

        for index = 0 to window - 1
            float distance = math.abs(array.get(residuals, index) - residualMedian)
            float cutoff = clipping * robustScale
            float weight = distance <= cutoff ? 1.0 : cutoff / math.max(distance, syminfo.mintick)
            array.set(weights, index, weight)

        [nextIntercept, nextSlope] = f_fit(values, weights)
        fitIntercept := nextIntercept
        fitSlope := nextSlope

    array<float> finalResiduals = array.new<float>()
    for index = 0 to window - 1
        float fitted = fitIntercept + fitSlope * float(index)
        array.push(finalResiduals, array.get(values, index) - fitted)

    residualMedian := f_median(finalResiduals)
    array<float> finalDeviations = array.new<float>()
    for index = 0 to window - 1
        array.push(finalDeviations, math.abs(array.get(finalResiduals, index) - residualMedian))
    robustScale := math.max(1.4826 * f_median(finalDeviations), syminfo.mintick)

    float currentCenter = fitIntercept + fitSlope * float(window - 1) + residualMedian
    [currentCenter, fitSlope, robustScale]

//------------------------------------------------------------------------------
// State model
//------------------------------------------------------------------------------
float barsSinceMissing = nz(ta.barssince(na(source)), bar_index + 1)
bool ready = bar_index >= length - 1 and barsSinceMissing >= length

[modelCenter, modelSlope, modelScale] = f_robust_model(source, length, passes, clipMultiple)
float center = ready ? modelCenter : na
float slope = ready ? modelSlope : na
float scale = ready ? modelScale : na

float innerMultiple = innerInput
float outerMultiple = math.max(outerInput, innerMultiple + 0.25)
float upperInner = center + innerMultiple * scale
float lowerInner = center - innerMultiple * scale
float upperOuter = center + outerMultiple * scale
float lowerOuter = center - outerMultiple * scale
float residualZ = ready ? (source - center) / scale : na
float slopeStrength = ready ? slope / scale : na

bool positiveSlope = ready and slopeStrength > 0.05
bool negativeSlope = ready and slopeStrength < -0.05
color directionColor = positiveSlope ? bullColor : negativeSlope ? bearColor : neutralColor

bool extremeHigh = ready and residualZ >= outerMultiple
bool extremeLow = ready and residualZ <= -outerMultiple
bool extreme = extremeHigh or extremeLow
bool extremeEntry = extreme and not extreme[1]
bool centerCrossRaw = ta.cross(source, center)
bool confirmedExtremeEntry = barstate.isconfirmed and extremeEntry
bool confirmedCenterCross = barstate.isconfirmed and centerCrossRaw

//------------------------------------------------------------------------------
// Residual tunnel: center is dominant; nested fills encode robust distance.
//------------------------------------------------------------------------------
centerHalo = plot(center, "Robust Center Halo", color=color.new(directionColor, 82), linewidth=7)
centerLine = plot(center, "Robust Center", color=directionColor, linewidth=2)
innerUpperPlot = plot(showTunnel ? upperInner : na, "Inner Upper", color=color.new(directionColor, 48), linewidth=1)
innerLowerPlot = plot(showTunnel ? lowerInner : na, "Inner Lower", color=color.new(directionColor, 48), linewidth=1)
outerUpperPlot = plot(showTunnel ? upperOuter : na, "Outer Upper", color=color.new(directionColor, 18), linewidth=1)
outerLowerPlot = plot(showTunnel ? lowerOuter : na, "Outer Lower", color=color.new(directionColor, 18), linewidth=1)

fill(innerUpperPlot, innerLowerPlot, color=showTunnel ? color.new(directionColor, 90) : na, title="Inner robust field")
fill(outerUpperPlot, innerUpperPlot, color=showTunnel ? color.new(directionColor, 82) : na, title="Upper residual shell")
fill(innerLowerPlot, outerLowerPlot, color=showTunnel ? color.new(directionColor, 82) : na, title="Lower residual shell")

plotshape(showOutliers and confirmedExtremeEntry and extremeHigh, title="Confirmed Upper Extreme", style=shape.diamond, location=location.abovebar, color=extremeColor, size=size.tiny, text="R+")
plotshape(showOutliers and confirmedExtremeEntry and extremeLow, title="Confirmed Lower Extreme", style=shape.diamond, location=location.belowbar, color=extremeColor, size=size.tiny, text="R-")
barcolor(paintBars and extreme ? color.new(extremeColor, 15) : na, title="Extreme residual bars")

//------------------------------------------------------------------------------
// Dashboard and alerts
//------------------------------------------------------------------------------
var table dashboard = table.new(position.top_right, 2, 5, border_width=1)
if barstate.islast
    if showDashboard
        string stateText = not ready ? "WARMING" : extremeHigh ? "UPPER EXTREME" : extremeLow ? "LOWER EXTREME" : positiveSlope ? "POSITIVE TUNNEL" : negativeSlope ? "NEGATIVE TUNNEL" : "FLAT TUNNEL"
        color stateColor = not ready ? neutralColor : extreme ? extremeColor : directionColor
        table.cell(dashboard, 0, 0, "ROBUST STATE", text_color=color.white, bgcolor=color.rgb(36, 42, 54))
        table.cell(dashboard, 1, 0, stateText, text_color=color.white, bgcolor=color.new(stateColor, 15))
        table.cell(dashboard, 0, 1, "Residual z", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 1, ready ? str.tostring(residualZ, "#.##") : "n/a", text_color=stateColor, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 0, 2, "Slope / MAD", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 2, ready ? str.tostring(slopeStrength, "#.###") : "n/a", text_color=directionColor, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 0, 3, "Robust scale", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 3, ready ? str.tostring(scale, format.mintick) : "n/a", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 0, 4, "Window / passes", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 4, str.tostring(length) + " / " + str.tostring(passes), text_color=color.white, bgcolor=color.new(color.black, 20))
    else
        table.clear(dashboard, 0, 0, 1, 4)

alertcondition(confirmedExtremeEntry, "Residual entered extreme band", "Robust regression residual entered an outer MAD band on a confirmed bar.")
alertcondition(confirmedCenterCross, "Price crossed robust center", "Price crossed the robust regression center on a confirmed bar.")
````
