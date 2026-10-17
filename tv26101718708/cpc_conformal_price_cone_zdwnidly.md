# CPC - Conformal Price Cone

- url: https://www.tradingview.com/script/zdwNiDLY-CPC-Conformal-Price-Cone/
- type: indicator
- pine_id: PUB;54fe537c0c3549f2b345bd54cde26534
- version: 1.0

## Description

CPC is a historical price-distribution visualizer. It projects empirical ranges for future closing prices from the last confirmed candle, helping you compare the scale and asymmetry of past movements with the current market's volatility.

It is a market-context tool. It does not provide entries, take-profit levels, stop-loss levels, position sizing, or a risk-management system.

Reading the cone

The three nested bands show central empirical intervals at each future bar:

- 50%: the 25th to 75th percentiles.
- 80%: the 10th to 90th percentiles.
- 95%: the 2.5th to 97.5th percentiles.

Cyan shows the area above the pointwise median; magenta shows the area below it. These colors are not buy/sell signals. The dashed line connects the median closing-price estimate at each horizon; it is not the most likely trajectory.

The bands can be asymmetric because positive and negative historical returns are sampled together without imposing a symmetric distribution. A longer lower tail indicates larger downside outcomes in the sample, not automatically a higher probability of falling.

Percentages describe the full lower-to-upper interval. An 80% band does not mean an 80% probability of reaching its upper edge. The bands concern closes at individual horizons, not wick extremes, target-touch probabilities, or containment of the entire future path. Actual future coverage can differ substantially from the labels.

Chart example

On an ETHUSDT 4-hour chart with a 12-bar horizon, the right edge represents 48 hours ahead in this continuously traded market. Read each vertical slice as a separate future-close interval. The endpoint labels are the interval boundaries at bar 12.

For a simple hypothetical example, suppose the 80% endpoint labels are 2,300 and 2,600. Those numbers describe the central historical distribution after volatility scaling. They do not imply an 80% chance of hitting 2,600, and 2,300 is not a recommended stop. Price could touch either boundary during the horizon and still close inside the interval at the end.

The accompanying chart is a display example, not a trade recommendation or evidence of predictive accuracy. The live candle can move away from the cone's origin because the origin remains fixed at the last confirmed close until the next candle closes.

Historical trace

The optional small boundary dots show the 80% endpoint forecast issued exactly Horizon bars earlier for each target bar. A larger cyan or magenta dot marks a confirmed close outside that original interval. Wick-only excursions do not trigger these markers. These are forecast misses, not entry signals or a strategy backtest.

Method

For every horizon from 1 to H, CPC collects completed log returns and divides each by the volatility estimate known at that historical starting bar. Volatility is the square root of an RMA of squared one-bar log returns. A rolling window of these normalized outcomes is sorted to obtain seven empirical quantiles, then rescaled using the latest confirmed volatility and close. Each horizon is estimated separately; band widths need not increase monotonically.

Despite the indicator's name, this version uses empirical quantiles, not a formal conformal calibration procedure. The 50/80/95 levels are nominal and carry no conformal coverage guarantee. Samples overlap and are dependent. No trading profitability or out-of-sample coverage claim is made.

Timeframes and history

The model uses the active chart's bars and rebuilds when you change timeframe. A 12-bar horizon means 12 minutes on 1m, 3 hours on 15m, 12 hours on 1H, 48 hours on 4H, 12 daily bars on 1D, or 12 weekly bars on 1W. Session breaks can extend elapsed calendar time.

A full calibration window is required at every horizon. With default settings, roughly 342 confirmed bars are needed before the first cone; the historical trace needs a further horizon to mature. The maximum settings need roughly 624 bars. If history is insufficient or prices/volatility are invalid, no cone is drawn. In particular, monthly crypto charts may not have enough history even with the minimum calibration window. This is not a claim of compatibility with every available interval.

Use standard time-based candles and positive-price instruments with sufficient valid history. Synthetic chart types are rejected. Seconds, tick, and range intervals have not been validated for publication.

Confirmed-bar behavior

The model and cone update only when a candle closes. The current unfinished candle does not change the cone. Historical trace values retain the forecasts originally issued at their respective bars. Changing settings, symbol, timeframe, available history, or revised source data can change calculated results. A new cone after each close is a new forecast.

Settings

- Horizon: 6–24 bars.
- Calibration window: 200–500 valid observations per horizon.
- Volatility memory: 10–100 bars.
- Independent visibility for 50/80/95 bands, median, endpoint labels, and historical trace.
- Custom colors and transparency.

If endpoint labels are clipped, leave more empty chart space to the right. If the chart stays compressed after changing timeframe, reset its price scale to Auto.

License

© 2026 builtbyuba. Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0). Attribution, noncommercial use, and the same license for adaptations are required under the license terms. TradingView's applicable publishing and reuse rules also apply.

## Source Code

````pine
//@version=6
// © 2026 builtbyuba · CPC v1.1.1 — CONFORMAL PRICE CONE
// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// Empirical, volatility-normalized, pointwise CLOSE intervals.
// 50/80/95 are nominal levels, not conformal coverage guarantees.
// All model updates and drawings use confirmed bars only.
indicator("CPC · Conformal Price Cone v1.1.1", "CPC 1.1.1", overlay = true, max_bars_back = 600, max_polylines_count = 20, max_labels_count = 60)

string G_MODEL = "Cone model"
string G_STYLE = "Style"
string G_SHOW = "Visibility"
int horizon = input.int(12, "Horizon (bars ahead)", minval = 6, maxval = 24, group = G_MODEL, display = display.none, tooltip = "Pointwise close intervals, not whole-path or wick containment. 12 bars on 4H = 48 trading hours.")
int calWindow = input.int(300, "Calibration observations per horizon", minval = 200, maxval = 500, group = G_MODEL, display = display.none, tooltip = "A full window of valid observations is required at every horizon. 200 minimum reduces sparse-tail estimates; percentages remain nominal. Overlapping observations are dependent.")
int volLength = input.int(30, "Volatility memory", minval = 10, maxval = 100, group = G_MODEL, display = display.none)
color upColor = input.color(#22D3EE, "Upside", group = G_STYLE, inline = "c", display = display.none)
color downColor = input.color(#E879F9, "Downside", group = G_STYLE, inline = "c", display = display.none)
color midColor = input.color(#94A3B8, "Median", group = G_STYLE, inline = "c", display = display.none)
int coneTransp = input.int(72, "Cone transparency", minval = 40, maxval = 95, group = G_STYLE, display = display.none)
bool show50 = input.bool(true, "50% nominal", group = G_SHOW, inline = "l", display = display.none)
bool show80 = input.bool(true, "80% nominal", group = G_SHOW, inline = "l", display = display.none)
bool show95 = input.bool(true, "95% nominal", group = G_SHOW, inline = "l", display = display.none)
bool showMedian = input.bool(true, "Median path", group = G_SHOW, display = display.none)
bool showPrices = input.bool(true, "Price labels at cone end", group = G_SHOW, display = display.none)
bool showTrace = input.bool(true, "History: frozen 80% close range + surprises", group = G_SHOW, display = display.none, tooltip = "Compares the confirmed close with the endpoint prices issued exactly Horizon bars earlier. Wicks do not trigger dots.")

if barstate.isfirst and not chart.is_standard
    runtime.error("Use standard candles. Synthetic charts change the inputs.")

float logRet = close > 0 and close[1] > 0 ? math.log(close / close[1]) : na
float sigma = math.sqrt(ta.rma(logRet * logRet, volLength))
var matrix<float> outcomes = matrix.new<float>(horizon, calWindow, na)
var int writeAt = 0
// Counts VALID samples per row, not the number of writes.
var array<int> validCounts = array.new<int>(horizon, 0)
// Columns: lower95, lower80, lower50, median, upper50, upper80, upper95.
var matrix<float> conePrices = matrix.new<float>(horizon, 7, na)
var array<float> probabilities = array.from(0.025, 0.10, 0.25, 0.50, 0.75, 0.90, 0.975)
var array<polyline> shapes = array.new<polyline>()
var array<label> tags = array.new<label>()

f_sorted(int row) =>
    array<float> values = array.new<float>()
    for j = 0 to calWindow - 1
        float value = outcomes.get(row, j)
        if not na(value)
            values.push(value)
    values.sort(order.ascending)
    values

// Preserve v1.0's nearest empirical order statistic. No conformal claim.
f_quantile(array<float> sorted, float probability) =>
    sorted.get(int(math.round(probability * (sorted.size() - 1))))

f_clear_drawings() =>
    for drawing in shapes
        polyline.delete(drawing)
    for tag in tags
        label.delete(tag)
    shapes.clear()
    tags.clear()

f_band(int x0, float p0, int lowerColumn, int upperColumn, int transparency, string name) =>
    array<chart.point> upper = array.new<chart.point>()
    array<chart.point> lower = array.new<chart.point>()
    array<chart.point> upperEdge = array.new<chart.point>()
    array<chart.point> lowerEdge = array.new<chart.point>()
    upper.push(chart.point.from_index(x0, p0))
    lower.push(chart.point.from_index(x0, p0))
    upperEdge.push(chart.point.from_index(x0, p0))
    lowerEdge.push(chart.point.from_index(x0, p0))
    for h = 1 to horizon
        float hi = conePrices.get(h - 1, upperColumn)
        float lo = conePrices.get(h - 1, lowerColumn)
        upper.push(chart.point.from_index(x0 + h, hi))
        lower.push(chart.point.from_index(x0 + h, lo))
        upperEdge.push(chart.point.from_index(x0 + h, hi))
        lowerEdge.push(chart.point.from_index(x0 + h, lo))
    for h = horizon to 1
        float median = conePrices.get(h - 1, 3)
        upper.push(chart.point.from_index(x0 + h, median))
        lower.push(chart.point.from_index(x0 + h, median))
    // Straight interpolation preserves ordering between the calculated bar points.
    shapes.push(polyline.new(upper, curved = false, closed = true, line_color = color.new(upColor, 100), fill_color = color.new(upColor, transparency), force_overlay = true))
    shapes.push(polyline.new(lower, curved = false, closed = true, line_color = color.new(downColor, 100), fill_color = color.new(downColor, transparency), force_overlay = true))
    shapes.push(polyline.new(upperEdge, curved = false, line_color = color.new(upColor, math.max(0, transparency - 30)), line_width = 1, force_overlay = true))
    shapes.push(polyline.new(lowerEdge, curved = false, line_color = color.new(downColor, math.max(0, transparency - 30)), line_width = 1, force_overlay = true))
    if showPrices
        float lastUp = conePrices.get(horizon - 1, upperColumn)
        float lastLo = conePrices.get(horizon - 1, lowerColumn)
        tags.push(label.new(x0 + horizon + 1, lastUp, name + " ▲ " + str.tostring(lastUp, format.mintick), style = label.style_label_left, color = color.new(upColor, 100), textcolor = upColor, size = size.small, tooltip = "Nominal empirical interval for the close at this horizon. Not a coverage guarantee.", force_overlay = true))
        tags.push(label.new(x0 + horizon + 1, lastLo, name + " ▼ " + str.tostring(lastLo, format.mintick), style = label.style_label_left, color = color.new(downColor, 100), textcolor = downColor, size = size.small, tooltip = "Nominal empirical interval for the close at this horizon. Not a coverage guarantee.", force_overlay = true))

// Ordinary series, not mutable array snapshots: each confirmed bar stores the
// actual issued endpoint prices. Never fill missing forecasts with newer ones.
float issued80Upper = na
float issued80Lower = na
bool drawUpdate = barstate.isconfirmed and (barstate.islastconfirmedhistory or barstate.islast)

if barstate.isconfirmed
    // At time t, the newest outcome in row h started at t-h and ended at t.
    // Its denominator was known at its origin. No unfinished outcome enters.
    for h = 1 to horizon
        float startSigma = sigma[h]
        float startClose = close[h]
        float value = not na(startSigma) and startSigma > 0 and startClose > 0 and close > 0 ? math.log(close / startClose) / startSigma : na
        float replaced = outcomes.get(h - 1, writeAt)
        int count = validCounts.get(h - 1)
        count := count - (not na(replaced) ? 1 : 0) + (not na(value) ? 1 : 0)
        validCounts.set(h - 1, count)
        outcomes.set(h - 1, writeAt, value)
    writeAt := (writeAt + 1) % calWindow

    bool ready = close > 0 and not na(sigma) and sigma > 0
    for row = 0 to horizon - 1
        ready := ready and validCounts.get(row) == calWindow

    // Historical trace only needs the final horizon. Draw updates reuse this
    // sort for all seven endpoint quantiles instead of sorting it again.
    array<float> finalSorted = array.new<float>()
    if ready and (showTrace or drawUpdate)
        finalSorted := f_sorted(horizon - 1)
        issued80Lower := close * math.exp(f_quantile(finalSorted, 0.10) * sigma)
        issued80Upper := close * math.exp(f_quantile(finalSorted, 0.90) * sigma)

    if drawUpdate
        f_clear_drawings()
        if ready
            for row = 0 to horizon - 1
                array<float> sorted = finalSorted
                if row != horizon - 1
                    sorted := f_sorted(row)
                for column = 0 to 6
                    float q = f_quantile(sorted, probabilities.get(column))
                    conePrices.set(row, column, close * math.exp(q * sigma))
            if show95
                f_band(bar_index, close, 0, 6, math.min(95, coneTransp + 16), "95%")
            if show80
                f_band(bar_index, close, 1, 5, math.min(95, coneTransp + 8), "80%")
            if show50
                f_band(bar_index, close, 2, 4, coneTransp, "50%")
            if showMedian
                array<chart.point> points = array.new<chart.point>()
                points.push(chart.point.from_index(bar_index, close))
                for h = 1 to horizon
                    points.push(chart.point.from_index(bar_index + h, conePrices.get(h - 1, 3)))
                shapes.push(polyline.new(points, curved = false, line_color = color.new(midColor, 20), line_style = line.style_dashed, line_width = 1, force_overlay = true))

// These values were issued h bars ago and are already in PRICE units.
float traceUpper = issued80Upper[horizon]
float traceLower = issued80Lower[horizon]
bool surpriseUp = showTrace and barstate.isconfirmed and not na(traceUpper) and close > traceUpper
bool surpriseDown = showTrace and barstate.isconfirmed and not na(traceLower) and close < traceLower
plot(showTrace ? traceUpper : na, "Past 80% upper", color = color.new(upColor, 55), style = plot.style_circles, linewidth = 1, force_overlay = true)
plot(showTrace ? traceLower : na, "Past 80% lower", color = color.new(downColor, 55), style = plot.style_circles, linewidth = 1, force_overlay = true)
plotshape(surpriseUp, "Close above issued 80%", shape.circle, location.abovebar, upColor, size = size.tiny, force_overlay = true)
plotshape(surpriseDown, "Close below issued 80%", shape.circle, location.belowbar, downColor, size = size.tiny, force_overlay = true)
````
