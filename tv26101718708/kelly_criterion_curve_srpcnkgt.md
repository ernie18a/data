# Kelly Criterion Curve

- url: https://www.tradingview.com/script/srpcnkGT-Kelly-Criterion-Curve/
- type: indicator
- pine_id: PUB;797a72dbd2fb49359b6bd7d564eb21a2
- version: 1.0

## Description

The Kelly Criterion Curve indicator gives you the leverage/return tradeoff by displaying a bell curve with growth and leverage. This indicator shows where you are on the risk curve depending your allocation/leverage used and the optimal leverage to use in any asset. 

[b]What Does It Show?[/b]
The indicator plots the Kelly growth function:
g(f) = μ·f - 0.5·σ²·f²
Where:
[list]
[*]g(f) = Expected growth rate at leverage f
[*]μ = Annualized return
[*]σ = Annualized volatility
[*]f = Leverage multiplier
[/list]
The curve peaks at the Optimal Kelly leverage (full Kelly) and then declines, showing that:
[list]
[*]Too little leverage = underutilized capital
[*]Too much leverage = volatility drag destroys returns
[/list]
The curve is dynamically divided into zones based on your asset's return profile:
[list]
[*]Underinvesting (Green) - Too conservative, underutilized capital
[*]Optimal Sizing (Teal) - Sweet spot for position sizing
[*]High Risk (Yellow) - Diminishing returns, high volatility drag
[*]Never Logical (Red) - Risk outweighs reward
[*]Suicidal (Black) - Negative expected returns
[/list]
Position Markers
[list]
[*]★ Kelly Optimal (Green/Red) - Maximum long-term log growth leverage
[*]½ Kelly (Yellow) - Conservative sizing (recommended most times)
[/list]
[b]Settings for Kelly Calculation[/b]
[list]
[*]Lookback Period - Historical data window for calculations (default: 252 = 1 year)
[*]Annual Trading Days - For annualization (default: 252)
[*]Use Log Returns - More accurate for compounding (recommended: ON)
[*]Curve Smoothness (20-200) - Number of points on curve (default: 100)
[*]Maximum Leverage Display (2-10x) - X-axis range
[*]Show Short Positions - Display negative leverage for short strategies. Note the chart is not fully optimized for shorts.
[*]Show Optimal Kelly Marker - Mark optimal leverage on curve
[*]Show Half Kelly Marker - Mark conservative leverage
[/list]
[b]How to Use[/b]
[list]
[*]Look at Optimal Kelly - This is the [b]theoretical maximum[/b] for the period analyzed
[*]Use Half Kelly for conservative sizing 
[*]Check which risk zone your position falls into
[*]If your leverage is in the High Risk zone → Consider reducing
[*]If you're in Never Logical or Suicidal → I wish you good luck because you will need a lot
[*]If you're in Underinvesting → You may be too conservative
[/list]
[b]IMPORTANT[/b]
The indicator is based on past returns and volatility. It CANNOT predict:
[list]
[*]Market crashes
[*]Regime changes
[*]Black swan events
[/list]
If you use Optimal Kelly and suddenly there's a crash, you are toasted.
[list]
[*]Full Kelly maximizes long-term growth but can experience large drawdowns
[*]Most traders use ¼ to ½ Kelly for risk management
[*]You should almost never use full Kelly, unless you are extremely confident
[/list]
[b]Remember leverage amplifies gains and losses[/b]
[list]
[*]Notice how Max Growth isn't simply Ann. Return × Leverage
[*]The formula accounts for volatility drag (the cost of using leverage)
[*]Higher volatility = lower optimal leverage
[/list]
[b]The Kelly Criterion was developed by John L. Kelly Jr. in 1956 for information theory and later adapted for gambling (card counting for example, pioneered by Edward O. Thorp), and investing.[/b]

Optimal Leverage:
f* = μ / σ²
Expected Growth Function:
g(f) = μ·f - 0.5·σ²·f²
This is a quadratic function that forms the bell curve you see on the chart.

This indicator pairs perfectly with my other indicators:
[url=https://www.tradingview.com/script/UEbVqv1F-Kelly-Optimal-Leverage-Indicator/]Kelly Optimal Leverage Indicator[/url]
[url=https://www.tradingview.com/script/c87GWJ8t-Jensen-s-Inequality-Kelly-Leverage/]Jensen's Inequality + Kelly Leverage[/url]
[url=https://www.tradingview.com/script/8nc818P0-Multi-Leverage-VAR-VaG-Indicator/]Multi-Leverage VAR/VaG Indicator[/url]

For deeper insights on Kelly Criterion and optimal leverage:
Read my article: [url=https://medium.com/limitless-investor/unlock-the-power-of-monte-carlo-the-scientific-edge-that-can-make-or-break-your-portfolio-d4c5af743358?sk=0d67c8cdd17f5aee254ab68b2b702009]Unlock the Power of Monte Carlo[/url]
Read these papers: 
[url=https://financialfactory.com/wp-content/uploads/2014/01/alphagenerationandrisksmoothingusingmanagedvolatility.pdf]Alpha Generation and Risk Smoothing using Managed
Volatility[/url]
[url=https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2741701]Leverage for the Long Run - A Systematic Approach to Managing Risk and Magnifying Returns in Stocks[/url]

[b]Trading with leverage involves substantial risk of loss. 
The Kelly Criterion provides a theoretical framework - actual trading requires additional risk management, market analysis, and psychological discipline.[/b]

[b]Some examples of using the Kelly Criterion Curve:[/b]
Russel 2000, last 500 days Kelly curve
[image]https://www.tradingview.com/x/8iVYYoT4/[/image]
Here's you can see that the optimal sizing over the last 500 days would have been around 1.7x leverage and that full Kelly is 3.4x leverage. 
While Russel 2000 returned 16%, full Kelly would have returned 27.8%, and more that full Kelly (3.4x leverage) would lower the returns.

Berkshire Hathaway, last 1000 days Kelly curve
[image]https://www.tradingview.com/x/lUniofbk/[/image]
BRK stock optimal Kelly (full Kelly) is 2.5x for the last 1000 trading days. To reduce volatility, one could use 1/2 Kelly which is 1.25x leverage.

Bitcoin, last 2000 trading days Kelly curve
[image]https://www.tradingview.com/x/EDoH2ZrJ/[/image]
Very interestingly, the indicator tells us not to leverage Bitcoin. Even a 2x leverage can lead to ruin given its volatility, and in fact, in 2025 many traders got liquidated while leveraging Bitcoin by 2x.

Let me know if you have questions, suggestions and comments. 
- Henrique Centieiro

## Source Code

````pine
//@version=6
//By your quant, Henrique Centieiro
indicator("Kelly Criterion Curve", shorttitle="Kelly", overlay=false, max_lines_count=500, max_labels_count=500)

// ==========================================
// INPUTS
// ==========================================

group_calc = "Kelly Calculation"
lookback = input.int(252, "Lookback Period", minval=1, maxval=10000, group=group_calc,
                     tooltip="Number of bars for return/volatility calculation (252 = 1 year daily)")
annual_trading_days = input.int(252, "Annual Trading Days", minval=200, maxval=365, group=group_calc)
use_log_returns = input.bool(true, "Use Log Returns", group=group_calc)

group_curve = "Curve Settings"
curveIncrements = input.int(100, "Curve Smoothness", minval=20, maxval=200, step=10, group=group_curve,
                            tooltip="Number of points on curve. Higher = smoother (100 recommended)")
maxLeverage = input.float(5.0, "Maximum Leverage Display", minval=2.0, maxval=10.0, step=0.5, group=group_curve,
                         tooltip="X-axis range (0x to max for longs, -max to +max for longs+shorts)")
showShorts = input.bool(false, "Show SHORT Positions", group=group_curve,
                       tooltip="Display negative leverage (short positions). Default: LONG only")
showOptimalMarker = input.bool(true, "Show Optimal Kelly Marker", group=group_curve,
                               tooltip="Mark current optimal Kelly leverage on curve")
showHalfKellyMarker = input.bool(true, "Show Half Kelly Marker", group=group_curve)

group_colors = "Visual Settings"
colorUnderinvesting = input.color(color.new(#4caf50, 85), "Underinvesting Zone", group=group_colors)
colorOptimal = input.color(color.new(#089981, 80), "Optimal Sizing Zone", group=group_colors)
colorHighRisk = input.color(color.new(#ffeb3b, 80), "High Risk Zone", group=group_colors)
colorNeverLogical = input.color(color.new(#ff5252, 85), "Never Logical Zone", group=group_colors)
colorSuicidal = input.color(color.new(#000000, 50), "Suicidal Zone", group=group_colors)
colorCurve = input.color(color.new(#2196f3, 0), "Curve Color", group=group_colors)
colorOptimalMarker = input.color(color.new(#00e676, 0), "Optimal Kelly Marker", group=group_colors)
colorHalfKellyMarker = input.color(color.new(#ffd600, 0), "Half Kelly Marker", group=group_colors)

// ==========================================
// KELLY CALCULATIONS
// ==========================================

// Calculate returns
returns = use_log_returns ? math.log(close / nz(close[1], close)) : (close - nz(close[1], close)) / nz(close[1], close)

// Calculate mean return and volatility
mean_return = ta.sma(returns, lookback)
volatility = ta.stdev(returns, lookback)

// Annualize
annualized_return = use_log_returns ? mean_return * annual_trading_days : math.pow(1 + mean_return, annual_trading_days) - 1
annualized_volatility = volatility * math.sqrt(annual_trading_days)

// Calculate optimal Kelly leverage
optimal_kelly = annualized_return / math.pow(annualized_volatility, 2)
half_kelly = optimal_kelly * 0.5

// Kelly growth function: g(f) = μ*f - 0.5*σ²*f²
kellyGrowth(leverage) =>
    annualized_return * leverage - 0.5 * math.pow(annualized_volatility, 2) * math.pow(leverage, 2)

// Determine regime
isLongRegime = optimal_kelly > 0
isShortRegime = optimal_kelly < 0
regimeName = isLongRegime ? "LONG" : isShortRegime ? "SHORT" : "NEUTRAL"

// Calculate leverage range based on showShorts setting
minLev = showShorts ? -maxLeverage : 0.0
maxLev = maxLeverage
levRange = maxLev - minLev

// ==========================================
// CURVE DATA ARRAYS
// ==========================================

var array<float> leverageArray = array.new_float(curveIncrements + 1)
var array<float> growthArray = array.new_float(curveIncrements + 1)
var array<line> curveLines = array.new_line(curveIncrements)
var array<label> xAxisLabels = array.new_label(0)
var bool linesInitialized = false

// Calculate growth values for each leverage level
if barstate.islast
    for i = 0 to curveIncrements
        lev = minLev + (levRange * i / curveIncrements)
        growth = kellyGrowth(lev)
        array.set(leverageArray, i, lev)
        array.set(growthArray, i, growth)

// ==========================================
// DRAW CURVE
// ==========================================

if barstate.islast
    // Calculate curve positioning
    barSpacing = 2
    startBar = bar_index - (curveIncrements * barSpacing)
    endBar = bar_index

    // Find max/min growth for Y-axis scaling
    maxGrowth = array.max(growthArray)
    minGrowth = array.min(growthArray)
    growthRange = maxGrowth - minGrowth

    // Find the optimal Kelly point (peak of curve)
    optimalKellyIndex = 0
    for i = 0 to curveIncrements
        if array.get(growthArray, i) == maxGrowth
            optimalKellyIndex := i
            break

    // Find zero crossing points
    zeroCrossIndex1 = 0
    zeroCrossIndex2 = curveIncrements
    
    for i = 0 to optimalKellyIndex
        if array.get(growthArray, i) >= 0
            zeroCrossIndex1 := i
            break
    
    for i = optimalKellyIndex to curveIncrements
        if array.get(growthArray, i) <= 0
            zeroCrossIndex2 := i
            break

    // Calculate zone boundaries
    zone1_index = math.floor(optimalKellyIndex - (optimalKellyIndex - zeroCrossIndex1) * 2.0 / 3.0)
    zone2_index = math.floor(optimalKellyIndex - (optimalKellyIndex - zeroCrossIndex1) / 3.0)
    zone3_index = optimalKellyIndex
    zone4_index = zeroCrossIndex2

    // Check if zones exist in visible range
    hasNeverLogical = (zone4_index - zone3_index) > (curveIncrements * 0.05)  // At least 5% of chart width
    hasSuicidalRight = (curveIncrements - zone4_index) > (curveIncrements * 0.05)
    hasSuicidalLeft = showShorts and zeroCrossIndex1 > (curveIncrements * 0.05)

    // Initialize or update curve lines
    if not linesInitialized
        for i = 0 to curveIncrements - 1
            barPos = startBar + (i * barSpacing)
            array.set(curveLines, i, line.new(barPos, array.get(growthArray, i), barPos + barSpacing, array.get(growthArray, i + 1), color=colorCurve, width=3))

        // Create X-axis labels
        labelStep = showShorts ? (maxLeverage <= 5.0 ? 1.0 : 2.0) : (maxLeverage <= 5.0 ? 0.5 : 1.0)
        numLabels = math.floor(levRange / labelStep) + 1
        
        array.clear(xAxisLabels)
        for j = 0 to numLabels - 1
            array.push(xAxisLabels, label(na))
        
        labelCount = 0
        for lev = minLev to maxLev by labelStep
            if labelCount < numLabels
                levRatio = (lev - minLev) / levRange
                barPos = startBar + math.floor(levRatio * curveIncrements * barSpacing)
                labelText = showShorts ? (lev == 0 ? "0" : (lev > 0 ? "+" : "") + str.tostring(lev, "#.#") + "x") : str.tostring(lev, "#.#") + "x"
                array.set(xAxisLabels, labelCount, label.new(barPos, minGrowth - growthRange * 0.08, text=labelText, color=color.new(color.black, 100), textcolor=color.rgb(178, 181, 190), style=label.style_label_center, size=size.normal))
                labelCount := labelCount + 1

        linesInitialized := true
    else
        // Update existing lines
        for i = 0 to curveIncrements - 1
            barPos = startBar + (i * barSpacing)
            lineID = array.get(curveLines, i)
            line.set_xy1(lineID, barPos, array.get(growthArray, i))
            line.set_xy2(lineID, barPos + barSpacing, array.get(growthArray, i + 1))

        // Update X-axis labels
        labelStep = showShorts ? (maxLeverage <= 5.0 ? 1.0 : 2.0) : (maxLeverage <= 5.0 ? 0.5 : 1.0)
        numLabels = array.size(xAxisLabels)
        labelCount = 0
        for lev = minLev to maxLev by labelStep
            if labelCount < numLabels
                levRatio = (lev - minLev) / levRange
                barPos = startBar + math.floor(levRatio * curveIncrements * barSpacing)
                labelText = showShorts ? (lev == 0 ? "0" : (lev > 0 ? "+" : "") + str.tostring(lev, "#.#") + "x") : str.tostring(lev, "#.#") + "x"
                labelID = array.get(xAxisLabels, labelCount)
                label.set_xy(labelID, barPos, minGrowth - growthRange * 0.08)
                label.set_text(labelID, labelText)
                labelCount := labelCount + 1

    // ==========================================
    // DRAW COLORED ZONES
    // ==========================================

    zoneTop = maxGrowth + growthRange * 0.05
    zoneBottom = minGrowth - growthRange * 0.15

    // Zone 1: Underinvesting
    z1_start = startBar + (zeroCrossIndex1 * barSpacing)
    z1_end = startBar + (zone1_index * barSpacing)
    var box zone1Box = na
    if na(zone1Box)
        zone1Box := box.new(z1_start, zoneBottom, z1_end, zoneTop, bgcolor=colorUnderinvesting, border_color=color.new(colorUnderinvesting, 100))
    else
        box.set_lefttop(zone1Box, z1_start, zoneTop)
        box.set_rightbottom(zone1Box, z1_end, zoneBottom)

    // Zone 2: Optimal Sizing
    z2_start = z1_end
    z2_end = startBar + (zone2_index * barSpacing)
    var box zone2Box = na
    if na(zone2Box)
        zone2Box := box.new(z2_start, zoneBottom, z2_end, zoneTop, bgcolor=colorOptimal, border_color=color.new(colorOptimal, 100))
    else
        box.set_lefttop(zone2Box, z2_start, zoneTop)
        box.set_rightbottom(zone2Box, z2_end, zoneBottom)

    // Zone 3: High Risk
    z3_start = z2_end
    z3_end = startBar + (zone3_index * barSpacing)
    var box zone3Box = na
    if na(zone3Box)
        zone3Box := box.new(z3_start, zoneBottom, z3_end, zoneTop, bgcolor=colorHighRisk, border_color=color.new(colorHighRisk, 100))
    else
        box.set_lefttop(zone3Box, z3_start, zoneTop)
        box.set_rightbottom(zone3Box, z3_end, zoneBottom)

    // Zone 4: Never Logical
    z4_start = z3_end
    z4_end = startBar + (zone4_index * barSpacing)
    var box zone4Box = na
    if na(zone4Box)
        zone4Box := box.new(z4_start, zoneBottom, z4_end, zoneTop, bgcolor=colorNeverLogical, border_color=color.new(colorNeverLogical, 100))
    else
        box.set_lefttop(zone4Box, z4_start, zoneTop)
        box.set_rightbottom(zone4Box, z4_end, zoneBottom)

    // Zone 5: Suicidal left
    var box zone5Box = na
    if showShorts and zeroCrossIndex1 > 0
        z5_start = startBar
        z5_end = startBar + (zeroCrossIndex1 * barSpacing)
        if na(zone5Box)
            zone5Box := box.new(z5_start, zoneBottom, z5_end, zoneTop, bgcolor=colorSuicidal, border_color=color.new(colorSuicidal, 100))
        else
            box.set_lefttop(zone5Box, z5_start, zoneTop)
            box.set_rightbottom(zone5Box, z5_end, zoneBottom)
    else if not na(zone5Box)
        box.delete(zone5Box)
        zone5Box := na

    // Zone 6: Suicidal right
    z6_start = z4_end
    z6_end = endBar
    var box zone6Box = na
    if na(zone6Box)
        zone6Box := box.new(z6_start, zoneBottom, z6_end, zoneTop, bgcolor=colorSuicidal, border_color=color.new(colorSuicidal, 100))
    else
        box.set_lefttop(zone6Box, z6_start, zoneTop)
        box.set_rightbottom(zone6Box, z6_end, zoneBottom)

    // ==========================================
    // DRAW AXES
    // ==========================================

    var line xAxis = na
    var line yAxis = na
    var line zeroLine = na
    var label xLabel = na
    var label yLabel = na
    var label shortLabel = na
    var label longLabel = na

    if na(xAxis)
        xAxis := line.new(startBar, 0.0, endBar, 0.0, color=color.rgb(178, 181, 190), width=2)
        yAxis := line.new(startBar, minGrowth, startBar, maxGrowth + growthRange * 0.1, color=color.rgb(178, 181, 190), width=2)
        xLabel := label.new(endBar, minGrowth - growthRange * 0.15, "Leverage →", color=color.new(color.black, 100), textcolor=color.rgb(178, 181, 190), style=label.style_label_left, size=size.large)
        yLabel := label.new(startBar - 8, maxGrowth * 0.5, "Expected Growth Rate ↑", color=color.new(color.black, 100), textcolor=color.rgb(178, 181, 190), style=label.style_label_right, size=size.normal, textalign=text.align_center)
        
        if showShorts
            zeroBarPos = startBar + math.floor((0.0 - minLev) / levRange * curveIncrements * barSpacing)
            zeroLine := line.new(zeroBarPos, minGrowth - growthRange * 0.15, zeroBarPos, maxGrowth + growthRange * 0.15, color=color.rgb(255, 255, 255, 50), width=2, style=line.style_dashed)
            shortLabel := label.new(startBar + math.floor(curveIncrements / 4.0) * barSpacing, minGrowth - growthRange * 0.20, "← SHORT", color=color.new(color.black, 100), textcolor=color.rgb(255, 82, 82), style=label.style_label_center, size=size.small)
            longLabel := label.new(startBar + math.floor(curveIncrements * 3.0 / 4.0) * barSpacing, minGrowth - growthRange * 0.20, "LONG →", color=color.new(color.black, 100), textcolor=color.rgb(0, 200, 83), style=label.style_label_center, size=size.small)
    else
        line.set_xy1(xAxis, startBar, 0.0)
        line.set_xy2(xAxis, endBar, 0.0)
        line.set_xy1(yAxis, startBar, minGrowth)
        line.set_xy2(yAxis, startBar, maxGrowth + growthRange * 0.1)
        label.set_xy(xLabel, endBar, minGrowth - growthRange * 0.15)
        label.set_xy(yLabel, startBar - 8, maxGrowth * 0.5)
        
        if showShorts
            zeroBarPos = startBar + math.floor((0.0 - minLev) / levRange * curveIncrements * barSpacing)
            if na(zeroLine)
                zeroLine := line.new(zeroBarPos, minGrowth - growthRange * 0.15, zeroBarPos, maxGrowth + growthRange * 0.15, color=color.rgb(255, 255, 255, 50), width=2, style=line.style_dashed)
            else
                line.set_xy1(zeroLine, zeroBarPos, minGrowth - growthRange * 0.15)
                line.set_xy2(zeroLine, zeroBarPos, maxGrowth + growthRange * 0.15)
            
            if na(shortLabel)
                shortLabel := label.new(startBar + math.floor(curveIncrements / 4.0) * barSpacing, minGrowth - growthRange * 0.20, "← SHORT", color=color.new(color.black, 100), textcolor=color.rgb(255, 82, 82), style=label.style_label_center, size=size.small)
                longLabel := label.new(startBar + math.floor(curveIncrements * 3.0 / 4.0) * barSpacing, minGrowth - growthRange * 0.20, "LONG →", color=color.new(color.black, 100), textcolor=color.rgb(0, 200, 83), style=label.style_label_center, size=size.small)
            else
                label.set_xy(shortLabel, startBar + math.floor(curveIncrements / 4.0) * barSpacing, minGrowth - growthRange * 0.20)
                label.set_xy(longLabel, startBar + math.floor(curveIncrements * 3.0 / 4.0) * barSpacing, minGrowth - growthRange * 0.20)
        else
            if not na(zeroLine)
                line.delete(zeroLine)
                zeroLine := na
            if not na(shortLabel)
                label.delete(shortLabel)
                label.delete(longLabel)
                shortLabel := na
                longLabel := na

    // ==========================================
    // OPTIMAL KELLY MARKER
    // ==========================================

    if showOptimalMarker and optimal_kelly != 0 and optimal_kelly >= minLev and optimal_kelly <= maxLev
        optimalLevRatio = (optimal_kelly - minLev) / levRange
        optimalBarPos = startBar + math.floor(optimalLevRatio * curveIncrements * barSpacing)
        optimalGrowth = kellyGrowth(optimal_kelly)

        var line optimalVertical = na
        var label optimalLabel = na

        markerText = "★ Kelly Optimal\n" + (optimal_kelly > 0 ? "+" : "") + str.tostring(optimal_kelly, "#.##") + "x"
        markerColor = optimal_kelly > 0 ? colorOptimalMarker : color.rgb(255, 82, 82)

        if na(optimalVertical)
            optimalVertical := line.new(optimalBarPos, minGrowth, optimalBarPos, optimalGrowth, color=markerColor, width=2, style=line.style_dashed)
            optimalLabel := label.new(optimalBarPos, optimalGrowth, markerText, color=color.new(markerColor, 80), textcolor=markerColor, style=label.style_label_up, size=size.normal)
        else
            line.set_xy1(optimalVertical, optimalBarPos, minGrowth)
            line.set_xy2(optimalVertical, optimalBarPos, optimalGrowth)
            line.set_color(optimalVertical, markerColor)
            label.set_xy(optimalLabel, optimalBarPos, optimalGrowth)
            label.set_text(optimalLabel, markerText)
            label.set_color(optimalLabel, color.new(markerColor, 80))
            label.set_textcolor(optimalLabel, markerColor)

    // Half Kelly marker - positioned below the curve
    if showHalfKellyMarker and half_kelly != 0 and half_kelly >= minLev and half_kelly <= maxLev
        halfLevRatio = (half_kelly - minLev) / levRange
        halfKellyBarPos = startBar + math.floor(halfLevRatio * curveIncrements * barSpacing)
        halfKellyGrowth = kellyGrowth(half_kelly)

        var line halfKellyVertical = na
        var label halfKellyLabel = na

        halfMarkerText = "½ Kelly\n" + (half_kelly > 0 ? "+" : "") + str.tostring(half_kelly, "#.##") + "x"

        if na(halfKellyVertical)
            halfKellyVertical := line.new(halfKellyBarPos, minGrowth, halfKellyBarPos, halfKellyGrowth, color=colorHalfKellyMarker, width=2, style=line.style_dashed)
            halfKellyLabel := label.new(halfKellyBarPos, halfKellyGrowth, halfMarkerText, color=color.new(colorHalfKellyMarker, 80), textcolor=colorHalfKellyMarker, style=label.style_label_down, size=size.normal)
        else
            line.set_xy1(halfKellyVertical, halfKellyBarPos, minGrowth)
            line.set_xy2(halfKellyVertical, halfKellyBarPos, halfKellyGrowth)
            label.set_xy(halfKellyLabel, halfKellyBarPos, halfKellyGrowth)
            label.set_text(halfKellyLabel, halfMarkerText)

    // ==========================================
    // ZONE LABELS
    // ==========================================

    var label zone0Label = na
    var label zone1Label = na
    var label zone2Label = na
    var label zone3Label = na
    var label zone4Label = na
    var label zone5Label = na

    labelY = maxGrowth + growthRange * 0.12

    if na(zone1Label)
        // Suicidal left (only if showing shorts and zone exists)
        if hasSuicidalLeft
            z0_pos = startBar + math.floor(zeroCrossIndex1 / 2.0) * barSpacing
            zone0Label := label.new(z0_pos, labelY, "💀 Suicidal", color=color.new(color.black, 100), textcolor=color.rgb(255, 255, 255), style=label.style_label_center, size=size.small)

        // Underinvesting
        z1_pos = startBar + math.floor((zeroCrossIndex1 + zone1_index) / 2.0) * barSpacing
        zone1Label := label.new(z1_pos, labelY, "🌱 Under-\ninvesting", color=color.new(color.black, 100), textcolor=color.rgb(76, 175, 80), style=label.style_label_center, size=size.small)

        // Optimal Sizing
        z2_pos = startBar + math.floor((zone1_index + zone2_index) / 2.0) * barSpacing
        zone2Label := label.new(z2_pos, labelY, "🎯 Optimal\nSizing", color=color.new(color.black, 100), textcolor=color.rgb(0, 153, 51), style=label.style_label_center, size=size.small)

        // High Risk
        z3_pos = startBar + math.floor((zone2_index + zone3_index) / 2.0) * barSpacing
        zone3Label := label.new(z3_pos, labelY, "⚠️ High Risk", color=color.new(color.black, 100), textcolor=color.rgb(255, 193, 7), style=label.style_label_center, size=size.small)

        // Never Logical (only if zone exists)
        if hasNeverLogical
            z4_pos = startBar + math.floor((zone3_index + zone4_index) / 2.0) * barSpacing
            zone4Label := label.new(z4_pos, labelY, "🚫 Never\nLogical", color=color.new(color.black, 100), textcolor=color.rgb(255, 82, 82), style=label.style_label_center, size=size.small)

        // Suicidal right (only if zone exists)
        if hasSuicidalRight
            z5_pos = startBar + math.floor((zone4_index + curveIncrements) / 2.0) * barSpacing
            zone5Label := label.new(z5_pos, labelY, "💀 Suicidal", color=color.new(color.black, 100), textcolor=color.rgb(255, 255, 255), style=label.style_label_center, size=size.small)
    else
        // Update positions
        if hasSuicidalLeft
            z0_pos = startBar + math.floor(zeroCrossIndex1 / 2.0) * barSpacing
            if na(zone0Label)
                zone0Label := label.new(z0_pos, labelY, "💀 Suicidal", color=color.new(color.black, 100), textcolor=color.rgb(255, 255, 255), style=label.style_label_center, size=size.small)
            else
                label.set_xy(zone0Label, z0_pos, labelY)
        else if not na(zone0Label)
            label.delete(zone0Label)
            zone0Label := na

        z1_pos = startBar + math.floor((zeroCrossIndex1 + zone1_index) / 2.0) * barSpacing
        label.set_xy(zone1Label, z1_pos, labelY)

        z2_pos = startBar + math.floor((zone1_index + zone2_index) / 2.0) * barSpacing
        label.set_xy(zone2Label, z2_pos, labelY)

        z3_pos = startBar + math.floor((zone2_index + zone3_index) / 2.0) * barSpacing
        label.set_xy(zone3Label, z3_pos, labelY)

        if hasNeverLogical
            z4_pos = startBar + math.floor((zone3_index + zone4_index) / 2.0) * barSpacing
            if na(zone4Label)
                zone4Label := label.new(z4_pos, labelY, "🚫 Never\nLogical", color=color.new(color.black, 100), textcolor=color.rgb(255, 82, 82), style=label.style_label_center, size=size.small)
            else
                label.set_xy(zone4Label, z4_pos, labelY)
        else if not na(zone4Label)
            label.delete(zone4Label)
            zone4Label := na

        if hasSuicidalRight
            z5_pos = startBar + math.floor((zone4_index + curveIncrements) / 2.0) * barSpacing
            if na(zone5Label)
                zone5Label := label.new(z5_pos, labelY, "💀 Suicidal", color=color.new(color.black, 100), textcolor=color.rgb(255, 255, 255), style=label.style_label_center, size=size.small)
            else
                label.set_xy(zone5Label, z5_pos, labelY)
        else if not na(zone5Label)
            label.delete(zone5Label)
            zone5Label := na

// ==========================================
// INFO TABLE
// ==========================================

if barstate.islast
    var table infoTable = table.new(position=position.top_right, columns=2, rows=8, bgcolor=color.rgb(0, 0, 0, 85), border_width=1)

    table.cell(infoTable, 0, 0, "Kelly Criterion", text_color=color.white, bgcolor=color.rgb(33, 150, 243, 90), text_size=size.normal)
    table.cell(infoTable, 1, 0, "Growth vs Leverage", text_color=color.white, bgcolor=color.rgb(33, 150, 243, 90), text_size=size.normal)

    table.cell(infoTable, 0, 1, "Symbol", text_color=color.white, text_size=size.normal)
    table.cell(infoTable, 1, 1, syminfo.ticker, text_color=color.white, text_size=size.normal)

    table.cell(infoTable, 0, 2, "Regime", text_color=color.white, text_size=size.normal)
    regimeColor = isLongRegime ? color.rgb(0, 200, 83) : isShortRegime ? color.rgb(255, 82, 82) : color.gray
    table.cell(infoTable, 1, 2, regimeName, text_color=regimeColor, text_size=size.normal)

    table.cell(infoTable, 0, 3, "Ann. Return", text_color=color.white, text_size=size.normal)
    returnColor = annualized_return >= 0 ? color.green : color.red
    table.cell(infoTable, 1, 3, str.tostring(annualized_return * 100, "#.##") + "%", text_color=returnColor, text_size=size.normal)

    table.cell(infoTable, 0, 4, "Ann. Volatility", text_color=color.white, text_size=size.normal)
    table.cell(infoTable, 1, 4, str.tostring(annualized_volatility * 100, "#.##") + "%", text_color=color.white, text_size=size.normal)

    table.cell(infoTable, 0, 5, "Optimal Kelly", text_color=color.white, text_size=size.normal)
    kellyColor = optimal_kelly > 0 ? colorOptimalMarker : color.rgb(255, 82, 82)
    kellyText = (optimal_kelly > 0 ? "+" : "") + str.tostring(optimal_kelly, "#.##") + "x"
    table.cell(infoTable, 1, 5, kellyText, text_color=kellyColor, text_size=size.normal)

    table.cell(infoTable, 0, 6, "Half Kelly", text_color=color.white, text_size=size.normal)
    halfKellyText = (half_kelly > 0 ? "+" : "") + str.tostring(half_kelly, "#.##") + "x"
    table.cell(infoTable, 1, 6, halfKellyText, text_color=colorHalfKellyMarker, text_size=size.normal)

    table.cell(infoTable, 0, 7, "Max Growth", text_color=color.white, text_size=size.normal)
    maxGrowthValue = kellyGrowth(optimal_kelly)
    table.cell(infoTable, 1, 7, str.tostring(maxGrowthValue * 100, "#.##") + "%", text_color=maxGrowthValue >= 0 ? color.green : color.red, text_size=size.normal)

// ==========================================
// REFERENCE LINES
// ==========================================

hline(0.0, "Zero Growth", color=color.rgb(178, 181, 190, 50), linestyle=hline.style_solid, linewidth=2)
````
