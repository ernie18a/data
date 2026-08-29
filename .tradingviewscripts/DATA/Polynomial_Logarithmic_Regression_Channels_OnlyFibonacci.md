<!-- tradingview-pine-id: PUB;fe24d1bac9074fb598d106c38ee4c835 -->
<!-- tradingviewscripts-format: 1 -->
# Polynomial & Logarithmic Regression Channels [OnlyFibonacci]

Source: https://www.tradingview.com/script/KqLVr0fO/

## Description

Polynomial & Logarithmic Regression Channels [OnlyFibonacci] is an overlay indicator that fits a 2nd-degree polynomial regression curve to recent price action and builds dynamic standard deviation channels around that curve. Unlike a straight linear regression line or a simple moving average, the polynomial model captures curved trends — acceleration, deceleration, and rounded turning phases — while deviation bands quantify how far price has stretched from the fitted trend.

What Makes This Indicator Different  []Matrix-based polynomial regression — Coefficients are solved via least-squares using Pine Script v6 matrix operations (matrix.new, matrix.transpose, matrix.mult, matrix.inv), not a basic ta.linreg() call. []Logarithmic price scale toggle — Switch between standard and log-price regression. Log mode is well suited for long-horizon assets where percentage growth matters more than absolute price moves. []Residual volatility channels — Inner (±1σ) and outer (±2σ) bands are built from the standard deviation of price residuals relative to the fitted curve, not from raw price volatility alone. []Live dashboard — Model type, channel position (%), residual volatility, and trend status (Overbought / Oversold / Neutral) are displayed in an upper-right table. [*]Built-in alerts — Outer channel breaches and polynomial slope direction changes. 

How It Works On each bar, the script collects the last N closing prices (default: 200) and fits the equation y = a + bx + cx² using matrix least-squares: β = (X'X)⁻¹X'Y. The regression line value at the current bar becomes the central trend curve. Residuals (actual price minus fitted value) across the lookback window are used to compute a sample standard deviation. Upper and lower channels are then plotted at user-defined σ multipliers. When Use Logarithmic Price Scale is enabled, prices are transformed with math.log() before regression and mapped back to the chart with math.exp() for display. The central line color reflects the instantaneous slope of the polynomial at the current bar: bright green when sloping up, bright red when sloping down.

Key Settings  []Lookback Period (default 200) — Number of bars used to fit the polynomial. Higher values produce a smoother, slower-reacting curve; lower values track price more closely. []Use Logarithmic Price Scale — Enable for long-term trending markets (equities, crypto, indices). Keep off for short-term or range-bound analysis. []Inner / Outer Multipliers (default ±1.0 / ±2.0) — Control channel width. Wider multipliers reduce false overbought/oversold signals; tighter multipliers increase sensitivity. []Visual Style — Trend colors, band colors, fill transparency, and line widths. [*]Dashboard — Toggle the info table and adjust text size. 

How to Read the Chart  []Polynomial Regression line — The dynamic trend curve. Color shows current slope direction. []Inner bands (±1σ) — Normal fluctuation zone around the trend. Pullbacks into inner bands within a trending market may offer continuation setups. []Outer bands (±2σ) — Statistical stretch zone. Price beyond outer bands signals extended deviation from the fitted trend. []Channel fills — Soft shaded areas between bands help visualize channel structure without cluttering the chart. 

Dashboard Metrics  []Model Type — "Polynomial" (standard scale) or "Log-Poly" (logarithmic scale). []Channel Position (%) — Where price sits within the outer channel (0% = outer lower, 100% = outer upper). Values above 80% or below 20% are highlighted. []Residual Volatility — Dispersion of price around the fitted curve, shown as a percentage. []Trend Status — Overbought (above outer upper), Oversold (below outer lower), or Neutral (inside outer bands). 

How to Use — Practical Interpretation Trend identification: Trade in the direction of the regression line color. A green (upward-sloping) curve supports bullish bias; red supports bearish bias. Pullback entries: In a strong trend, price pulling back toward the regression line or inner band while slope remains favorable can indicate a potential continuation zone — always confirm with your own structure or confluence. Mean reversion / exhaustion: When price pushes beyond the outer bands and dashboard shows Overbought or Oversold, the move may be statistically extended relative to the fitted curve. This does not guarantee reversal; it flags stretched conditions. Log vs. standard mode: Use log mode on higher timeframes and growth assets. Use standard mode on lower timeframes or when absolute price deviation is more relevant. Lookback tuning: Match lookback to your analysis horizon — e.g. 100–150 for swing trading, 200+ for position trend context.

Built-in Alerts  []Overbought — price above outer upper channel []Oversold — price below outer lower channel []Trend slope turned bullish — polynomial derivative crossed above zero []Trend slope turned bearish — polynomial derivative crossed below zero 

Recommended Setup  []Apply to a clean chart with no other overlapping indicators for clearest visualization. []Start with default settings (200 lookback, ±1σ / ±2σ bands). []Test on your preferred timeframe and symbol before relying on signals. []Combine with support/resistance, volume, or higher-timeframe trend for confluence — this tool provides statistical context, not standalone trade signals. 

This indicator is a quantitative analysis tool for educational and informational purposes only. It does not constitute financial advice, investment recommendation, or a guarantee of future performance. Past behavior of regression channels does not predict future results. Always manage risk and conduct your own due diligence before making trading decisions.

Credits Developed by OnlyFibonacci. Licensed under Mozilla Public License 2.0.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © only_fibonacci

//@version=6
indicator(
     'Polynomial & Logarithmic Regression Channels [OnlyFibonacci]',
     shorttitle = 'PolyLog Reg [OF]',
     overlay = true,
     precision = 4,
     max_bars_back = 5000)

// =============================================================================
// Inputs
// =============================================================================

lookback = input.int(
     200,
     title = 'Lookback Period',
     minval = 10,
     maxval = 2000,
     group = 'Regression Model',
     tooltip = 'Number of bars used to fit the 2nd-degree polynomial via matrix least-squares.')

useLogScale = input.bool(
     false,
     title = 'Use Logarithmic Price Scale',
     group = 'Regression Model',
     tooltip = 'Apply natural log transform to prices before matrix regression. Output is mapped back to price scale.')

innerUpperMult = input.float(
     1.0,
     title = 'Inner Upper Multiplier',
     step = 0.1,
     group = 'Deviation Bands',
     tooltip = 'Standard deviation multiplier for the inner upper channel.')

innerLowerMult = input.float(
     -1.0,
     title = 'Inner Lower Multiplier',
     step = 0.1,
     group = 'Deviation Bands',
     tooltip = 'Standard deviation multiplier for the inner lower channel.')

outerUpperMult = input.float(
     2.0,
     title = 'Outer Upper Multiplier',
     step = 0.1,
     group = 'Deviation Bands',
     tooltip = 'Standard deviation multiplier for the outer upper channel.')

outerLowerMult = input.float(
     -2.0,
     title = 'Outer Lower Multiplier',
     step = 0.1,
     group = 'Deviation Bands',
     tooltip = 'Standard deviation multiplier for the outer lower channel.')

colorBull = input.color(
     #00ff66,
     title = 'Bullish Trend',
     group = 'Visual Style',
     inline = 'trend')

colorBear = input.color(
     #ff3333,
     title = 'Bearish Trend',
     group = 'Visual Style',
     inline = 'trend')

colorBandUpper = input.color(
     #3b82f6,
     title = 'Upper Band',
     group = 'Visual Style',
     inline = 'bands')

colorBandLower = input.color(
     #a855f7,
     title = 'Lower Band',
     group = 'Visual Style',
     inline = 'bands')

fillTransOuter = input.int(
     92,
     title = 'Outer Fill Transparency',
     minval = 0,
     maxval = 100,
     group = 'Visual Style')

fillTransInner = input.int(
     88,
     title = 'Inner Fill Transparency',
     minval = 0,
     maxval = 100,
     group = 'Visual Style')

lineWidth = input.int(
     2,
     title = 'Regression Line Width',
     minval = 1,
     maxval = 4,
     group = 'Visual Style')

bandLineWidth = input.int(
     1,
     title = 'Band Line Width',
     minval = 1,
     maxval = 3,
     group = 'Visual Style')

showBands = input.bool(true, title = 'Show Deviation Bands', group = 'Visual Style')
showDashboard = input.bool(true, title = 'Show Dashboard Table', group = 'Dashboard')
dashboardSize = input.string(
     'Small',
     title = 'Dashboard Text Size',
     options = ['Tiny', 'Small', 'Normal'],
     group = 'Dashboard')

// =============================================================================
// Helper functions
// =============================================================================

// Map a model-space value back to the price scale.
f_toPrice(float val, bool logScale) =>
    logScale ? math.exp(val) : val

// Evaluate the polynomial at a given x index.
f_polyEval(float a, float b, float c, float x) =>
    a + b * x + c * x * x

// Transform raw price into the regression domain.
f_modelPrice(float rawPrice, bool logScale) =>
    logScale and rawPrice > 0 ? math.log(rawPrice) : rawPrice

// Fit a 2nd-degree polynomial using matrix least-squares: beta = (X'X)^-1 X'Y.
f_polyRegression(int len, bool logScale) =>
    matrix<float> designX = matrix.new<float>(len, 3, 0.0)
    matrix<float> targetY = matrix.new<float>(len, 1, 0.0)
    int validCount = 0

    for i = 0 to len - 1
        float x = float(i)
        int barsAgo = len - 1 - i
        float y = f_modelPrice(close[barsAgo], logScale)
        if not na(y)
            matrix.set(designX, validCount, 0, 1.0)
            matrix.set(designX, validCount, 1, x)
            matrix.set(designX, validCount, 2, x * x)
            matrix.set(targetY, validCount, 0, y)
            validCount += 1

    float naVal = float(na)
    float a = naVal
    float b = naVal
    float c = naVal
    float fitVal = naVal
    float slope = naVal
    float residStdev = naVal

    if validCount >= 3
        matrix<float> xMat = matrix.submatrix(designX, 0, validCount, 0, 3)
        matrix<float> yMat = matrix.submatrix(targetY, 0, validCount, 0, 1)
        matrix<float> xTrans = matrix.transpose(xMat)
        matrix<float> xtx = matrix.mult(xTrans, xMat)
        matrix<float> xty = matrix.mult(xTrans, yMat)
        matrix<float> coef = matrix.mult(matrix.inv(xtx), xty)

        a := matrix.get(coef, 0, 0)
        b := matrix.get(coef, 1, 0)
        c := matrix.get(coef, 2, 0)

        float xCur = float(len - 1)
        fitVal := f_polyEval(a, b, c, xCur)
        slope := b + 2.0 * c * xCur

        float sumSq = 0.0
        for i = 0 to validCount - 1
            float x = matrix.get(xMat, i, 1)
            float y = matrix.get(yMat, i, 0)
            float predicted = f_polyEval(a, b, c, x)
            float resid = y - predicted
            sumSq += resid * resid

        if validCount > 2
            residStdev := math.sqrt(sumSq / (validCount - 1))

    [fitVal, slope, residStdev]

// Build a band level from fitted value and residual standard deviation.
f_bandLevel(float fitVal, float residStdev, float mult, bool logScale) =>
    f_toPrice(fitVal + mult * residStdev, logScale)

// =============================================================================
// Core calculations
// =============================================================================

[fitModel, slope, residVol] = f_polyRegression(lookback, useLogScale)

regressionLine = f_toPrice(fitModel, useLogScale)
innerUpper     = f_bandLevel(fitModel, residVol, innerUpperMult, useLogScale)
innerLower     = f_bandLevel(fitModel, residVol, innerLowerMult, useLogScale)
outerUpper     = f_bandLevel(fitModel, residVol, outerUpperMult, useLogScale)
outerLower     = f_bandLevel(fitModel, residVol, outerLowerMult, useLogScale)

trendColor = slope > 0 ? colorBull : colorBear

// Channel position: where price sits within outer bands (0% = lower, 100% = upper).
float channelWidth = outerUpper - outerLower
float channelPosPct = channelWidth != 0.0 ? (close - outerLower) / channelWidth * 100.0 : 50.0
channelPosPct := math.max(0.0, math.min(100.0, channelPosPct))

// Trend status relative to outer deviation channels.
string trendStatus = close > outerUpper ? 'Overbought' : close < outerLower ? 'Oversold' : 'Neutral'

// Residual volatility expressed as a percentage for the dashboard.
float residVolPct = useLogScale ?
     (not na(residVol) ? residVol * 100.0 : na) :
     (not na(residVol) and close != 0.0 ? residVol / close * 100.0 : na)

string modelLabel = useLogScale ? 'Log-Poly' : 'Polynomial'

// =============================================================================
// Plots
// =============================================================================

pRegLine = plot(
     regressionLine,
     title = 'Polynomial Regression',
     color = trendColor,
     linewidth = lineWidth)

pOuterUpper = plot(
     showBands ? outerUpper : na,
     title = 'Outer Upper',
     color = color.new(colorBandUpper, 30),
     linewidth = bandLineWidth)

pOuterLower = plot(
     showBands ? outerLower : na,
     title = 'Outer Lower',
     color = color.new(colorBandLower, 30),
     linewidth = bandLineWidth)

pInnerUpper = plot(
     showBands ? innerUpper : na,
     title = 'Inner Upper',
     color = color.new(colorBandUpper, 55),
     linewidth = bandLineWidth,
     style = plot.style_circles)

pInnerLower = plot(
     showBands ? innerLower : na,
     title = 'Inner Lower',
     color = color.new(colorBandLower, 55),
     linewidth = bandLineWidth,
     style = plot.style_circles)

// Soft channel fills for intuitive structure.
fill(
     pOuterUpper,
     pInnerUpper,
     color = color.new(colorBandUpper, fillTransOuter),
     title = 'Upper Outer Channel Fill')

fill(
     pInnerUpper,
     pRegLine,
     color = color.new(colorBandUpper, fillTransInner),
     title = 'Upper Inner Channel Fill')

fill(
     pRegLine,
     pInnerLower,
     color = color.new(colorBandLower, fillTransInner),
     title = 'Lower Inner Channel Fill')

fill(
     pInnerLower,
     pOuterLower,
     color = color.new(colorBandLower, fillTransOuter),
     title = 'Lower Outer Channel Fill')

// =============================================================================
// Dashboard table (upper-right)
// =============================================================================

var table dashboard = table.new(
     position.top_right,
     2,
     5,
     bgcolor = color.new(#1e1e2e, 10),
     border_width = 1,
     border_color = color.new(#ffffff, 80),
     frame_width = 1,
     frame_color = color.new(#ffffff, 70))

string textSize = dashboardSize == 'Tiny' ? size.tiny : dashboardSize == 'Small' ? size.small : size.normal

if barstate.islast and showDashboard
    table.cell(dashboard, 0, 0, 'Metric', text_color = color.white, text_size = textSize, bgcolor = color.new(#2d2d44, 0))
    table.cell(dashboard, 1, 0, 'Value', text_color = color.white, text_size = textSize, bgcolor = color.new(#2d2d44, 0))

    table.cell(dashboard, 0, 1, 'Model Type', text_color = color.new(color.white, 20), text_size = textSize)
    table.cell(dashboard, 1, 1, modelLabel, text_color = color.new(#60a5fa, 0), text_size = textSize)

    table.cell(dashboard, 0, 2, 'Channel Position (%)', text_color = color.new(color.white, 20), text_size = textSize)
    table.cell(
         dashboard,
         1,
         2,
         str.tostring(channelPosPct, '#.##') + '%',
         text_color = channelPosPct > 80.0 ? colorBear : channelPosPct < 20.0 ? colorBull : color.white,
         text_size = textSize)

    table.cell(dashboard, 0, 3, 'Residual Volatility', text_color = color.new(color.white, 20), text_size = textSize)
    table.cell(
         dashboard,
         1,
         3,
         na(residVolPct) ? 'N/A' : str.tostring(residVolPct, '#.##') + '%',
         text_color = color.new(#fbbf24, 0),
         text_size = textSize)

    table.cell(dashboard, 0, 4, 'Trend Status', text_color = color.new(color.white, 20), text_size = textSize)
    color statusColor = trendStatus == 'Overbought' ? colorBear : trendStatus == 'Oversold' ? colorBull : color.new(color.white, 0)
    table.cell(dashboard, 1, 4, trendStatus, text_color = statusColor, text_size = textSize)

// =============================================================================
// Alerts
// =============================================================================

alertcondition(
     trendStatus == 'Overbought',
     title = 'Overbought — Outer Upper Channel',
     message = 'PolyLog Reg [OF]: Price is above the outer upper regression channel (Overbought).')

alertcondition(
     trendStatus == 'Oversold',
     title = 'Oversold — Outer Lower Channel',
     message = 'PolyLog Reg [OF]: Price is below the outer lower regression channel (Oversold).')

alertcondition(
     ta.crossover(slope, 0),
     title = 'Trend Slope Turned Bullish',
     message = 'PolyLog Reg [OF]: Polynomial regression slope crossed above zero (bullish turn).')

alertcondition(
     ta.crossunder(slope, 0),
     title = 'Trend Slope Turned Bearish',
     message = 'PolyLog Reg [OF]: Polynomial regression slope crossed below zero (bearish turn).')
````
