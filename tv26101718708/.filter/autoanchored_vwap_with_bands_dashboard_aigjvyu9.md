# Auto-Anchored VWAP with Bands & Dashboard

- url: https://www.tradingview.com/script/aiGJVyU9-Auto-Anchored-VWAP-with-Bands-Dashboard/
- type: indicator
- pine_id: PUB;e050cf8240564ee3a1e42e6ba4a280c6
- version: 1.0

## Description

Overview
The Auto-Anchored VWAP with Bands & Dashboard is a premium, high-performance technical analysis tool designed for TradingView (Pine Script v6). It calculates the Volume Weighted Average Price (VWAP) along with three customizable Standard Deviation (or Percentage) bands, starting from dynamic anchoring conditions. It also features a floating, real-time metrics dashboard on your screen to track distance, volatility, and trend bias, as well as optional chart coloring and crossover signals.

Key Functional Areas
1. Dynamic Anchoring System
Unlike standard VWAP indicators that reset only at the start of the day, this script lets you select how and when the VWAP calculation resets:

Calendar Boundaries: Automatically resets calculations at the start of a Session (Day), Week, Month, Quarter, Year, Decade, or Century.
Auto Mode: Detects your chart timeframe—resets daily on intraday charts (1m, 5m, 1h, etc.) and monthly on higher resolution charts (Daily, Weekly, etc.).
Lookback Back-Scanning: Scans a lookback window (e.g., the last 14 bars) to anchor the VWAP at the exact bar where the Highest High, Lowest Low, or Highest Volume occurred.
Corporate Events: Resets the calculation on the exact bar when new corporate Earnings, Dividend payouts, or Stock Splits are announced (ideal for stock traders).
2. Multi-Bands & Custom Price Sources
Dropdown Source Selection: Select your calculation price source, including Open, High, Low, Close, (H+L)/2, (H+L+C)/3 (Typical Price), (O+H+L+C)/4, or (H+L+C+C)/4 (Weighted Close).
3 Independent Bands: Toggle up to three bands above and below the VWAP using Standard Deviation multipliers or percentage offsets.
Visual Highlights: Colors the area between the upper and lower Band #1 with a transparent green background to highlight the core trading range.
3. Floating Metrics Dashboard
A clean, dark glassmorphic table floats in your selected corner of the chart (e.g., Top Right) to summarize current market conditions:

Source: The current value of the selected price source.
VWAP Value: The exact price of the VWAP line.
CMP to VWAP (Current Market Price): Displays how far the current price is from the VWAP line in absolute points/pips and as a percentage, color-coded green (above) or red (below).
Bands Mode & Volatility: Shows whether bands are Standard Deviation or Percentage based, and the current value of the standard deviation.
Anchor Type & Length: Displays the selected anchor period and the lookback length.
Bars Since Reset: Shows exactly how many bars have passed since the VWAP calculation started or reset.
Market Bias: Displays a clear Bullish (Above VWAP) or Bearish (Below VWAP) trend bias.

## Source Code

````pine
//@version=6
indicator("Auto-Anchored VWAP with Bands & Dashboard", shorttitle="AVWAP Dashboard", overlay=true)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
anchorPeriod = input.string("Auto", "Anchor Period", 
     options=["Auto", "Highest High", "Lowest Low", "Highest Volume", "Session", "Week", "Month", "Year", "Quarter", "Decade", "Century", "Earnings", "Dividends", "Splits"], 
     group="Anchor Settings", tooltip="Select how the VWAP anchor point is determined.")

length = input.int(14, "Length", minval=1, maxval=500, 
     group="Anchor Settings", tooltip="Lookback period for Highest High, Lowest Low, and Highest Volume anchor periods.")

srcInput = input.string("(H + L + C)/3", "Source", 
     options=["Open", "High", "Low", "Close", "(H + L)/2", "(H + L + C)/3", "(O + H + L + C)/4", "(H + L + C + C)/4"],
     group="Source Settings", tooltip="Select the price source series for VWAP calculations.")

// Bands settings block
calcMode = input.string("Standard Deviation", "Bands Calculation Mode", 
     options=["Standard Deviation", "Percentage"], 
     group="Bands Settings", tooltip="Select standard deviation or percentage for bands calculation.")

useBands1 = input.bool(true, "Bands Multiplier #1", inline="band1", group="Bands Settings")
mult1     = input.float(1.0, "", inline="band1", group="Bands Settings")

useBands2 = input.bool(false, "Bands Multiplier #2", inline="band2", group="Bands Settings")
mult2     = input.float(2.0, "", inline="band2", group="Bands Settings")

useBands3 = input.bool(false, "Bands Multiplier #3", inline="band3", group="Bands Settings")
mult3     = input.float(3.0, "", inline="band3", group="Bands Settings")

offset = input.int(0, "Offset", group="Bands Settings", tooltip="Shifts the plot lines historically.")

// Chart Visual Settings
showBiasPlot = input.bool(true, "Highlight Chart Bias & Crossovers", 
     group="Visual Settings", tooltip="Highlights chart background and plots crossover triangles when price is above or below VWAP.")

// Dashboard Settings
dashPos = input.string("Top Right", "Dashboard Position", 
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], 
     group="Dashboard Settings", tooltip="Screen position of the metrics panel.")

// Mapping source input to series float
src = switch srcInput
    "Open"              => open
    "High"              => high
    "Low"               => low
    "Close"             => close
    "(H + L)/2"         => hl2
    "(H + L + C)/3"     => hlc3
    "(O + H + L + C)/4" => ohlc4
    "(H + L + C + C)/4" => hlcc4
    => hlc3

// Mapping dashboard position
pos = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    "Middle Left"  => position.middle_left
    => position.top_right

// ==========================================
// 2. VOLUME AUTO-DETECTION & RESETS
// ==========================================
cumVol = ta.cum(volume)
hasVolume = not na(cumVol) and cumVol > 0.0
vol = hasVolume ? nz(volume, 0.0) : 1.0

// Calendar resets
isNewSession = ta.change(time("D")) != 0
isNewWeek    = ta.change(time("W")) != 0
isNewMonth   = ta.change(time("M")) != 0
isNewQuarter = ta.change(time("3M")) != 0
isNewYear    = ta.change(time("12M")) != 0
isNewDecade  = ta.change(year / 10) != 0
isNewCentury = ta.change(year / 100) != 0

isAutoReset = timeframe.isintraday ? isNewSession : isNewMonth

isCalendarReset = switch anchorPeriod
    "Auto"    => isAutoReset
    "Session" => isNewSession
    "Week"    => isNewWeek
    "Month"   => isNewMonth
    "Quarter" => isNewQuarter
    "Year"    => isNewYear
    "Decade"  => isNewDecade
    "Century" => isNewCentury
    => false

// Event-based resets (Request-driven with error safety)
isEarningsReset = false
isDividendsReset = false
isSplitsReset = false

if anchorPeriod == "Earnings"
    earningsActual = request.earnings(syminfo.tickerid, earnings.actual, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    isEarningsReset := not na(earningsActual)
else if anchorPeriod == "Dividends"
    dividendsGross = request.dividends(syminfo.tickerid, dividends.gross, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    isDividendsReset := not na(dividendsGross)
else if anchorPeriod == "Splits"
    splitsRatio = request.splits(syminfo.tickerid, splits.denominator, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    isSplitsReset := not na(splitsRatio)

// Final combined reset condition for calendar/events
isFirstBar = bar_index == 0
isReset = isFirstBar or isCalendarReset or isEarningsReset or isDividendsReset or isSplitsReset

// Lookback-based anchor identification
isLookbackAnchor = anchorPeriod == "Highest High" or anchorPeriod == "Lowest Low" or anchorPeriod == "Highest Volume"

anchorOffset = 0
if anchorPeriod == "Highest High"
    anchorOffset := math.abs(ta.highestbars(high, length))
else if anchorPeriod == "Lowest Low"
    anchorOffset := math.abs(ta.lowestbars(low, length))
else if anchorPeriod == "Highest Volume"
    anchorOffset := math.abs(ta.highestbars(volume, length))

// ==========================================
// 3. STABLE ANCHORED VWAP & STANDARD DEVIATION (Welford's Algorithm)
// ==========================================

// A. Incremental Welford's Algorithm (for calendar/event periods - O(1) stable updates)
var float calendarW = 0.0
var float calendarMean = 0.0
var float calendarS = 0.0
var int calendarBars = 0

if isReset
    calendarW := vol
    calendarMean := src
    calendarS := 0.0
    calendarBars := 0
else
    calendarW := calendarW + vol
    calendarBars := calendarBars + 1
    if calendarW > 0.0
        oldMean = calendarMean
        calendarMean := oldMean + (vol / calendarW) * (src - oldMean)
        calendarS := calendarS + vol * (src - oldMean) * (src - calendarMean)

calendarVwap = calendarW == 0.0 ? na : calendarMean
calendarSd   = calendarW == 0.0 ? 0.0 : math.sqrt(math.max(0.0, calendarS / calendarW))

// B. Loop-Based Welford's Algorithm (for lookback periods - stable scan updates)
float lookbackW = 0.0
float lookbackMean = 0.0
float lookbackS = 0.0

if isLookbackAnchor
    for i = 0 to anchorOffset
        p = src[i]
        v = hasVolume ? nz(volume[i], 0.0) : 1.0
        lookbackW := lookbackW + v
        if lookbackW > 0.0
            oldMean = lookbackMean
            lookbackMean := oldMean + (v / lookbackW) * (p - oldMean)
            lookbackS := lookbackS + v * (p - oldMean) * (p - lookbackMean)

lookbackVwap = lookbackW == 0.0 ? na : lookbackMean
lookbackSd   = lookbackW == 0.0 ? 0.0 : math.sqrt(math.max(0.0, lookbackS / lookbackW))

// Final VWAP, Standard Deviation, and Bars since reset selection
vwapVal = isLookbackAnchor ? lookbackVwap : calendarVwap
sdVal   = isLookbackAnchor ? lookbackSd : calendarSd
barsSinceAnchor = isLookbackAnchor ? anchorOffset : calendarBars

// ==========================================
// 4. BANDS CALCULATIONS
// ==========================================
float upper1 = na
float lower1 = na
float upper2 = na
float lower2 = na
float upper3 = na
float lower3 = na

if calcMode == "Standard Deviation"
    if useBands1
        upper1 := vwapVal + mult1 * sdVal
        lower1 := vwapVal - mult1 * sdVal
    if useBands2
        upper2 := vwapVal + mult2 * sdVal
        lower2 := vwapVal - mult2 * sdVal
    if useBands3
        upper3 := vwapVal + mult3 * sdVal
        lower3 := vwapVal - mult3 * sdVal
else // Percentage mode
    if useBands1
        upper1 := vwapVal * (1.0 + mult1 / 100.0)
        lower1 := vwapVal * (1.0 - mult1 / 100.0)
    if useBands2
        upper2 := vwapVal * (1.0 + mult2 / 100.0)
        lower2 := vwapVal * (1.0 - mult2 / 100.0)
    if useBands3
        upper3 := vwapVal * (1.0 + mult3 / 100.0)
        lower3 := vwapVal * (1.0 - mult3 / 100.0)

// Helper formatting string based on symbol decimals
getPriceFormat() =>
    tick = syminfo.mintick
    if tick >= 1.0
        "#.##"
    else if tick >= 0.1
        "#.##"
    else if tick >= 0.01
        "#.##"
    else if tick >= 0.001
        "#.###"
    else if tick >= 0.0001
        "#.####"
    else if tick >= 0.00001
        "#.#####"
    else
        "#.######"

priceFormat = getPriceFormat()

// ==========================================
// 5. PLOTS & VISUALS (Matching Screenshot Styles)
// ==========================================

// VWAP Plot (Blue)
p_vwap = plot(vwapVal, color=color.new(#2962ff, 0), linewidth=2, title="VWAP", offset=offset)

// Band Plots #1 (Green)
p_upper1 = plot(useBands1 ? upper1 : na, color=color.new(#4caf50, 0), title="Upper Band #1", offset=offset)
p_lower1 = plot(useBands1 ? lower1 : na, color=color.new(#4caf50, 0), title="Lower Band #1", offset=offset)

// Band Plots #2 (Yellow/Gold)
p_upper2 = plot(useBands2 ? upper2 : na, color=color.new(#ffeb3b, 0), title="Upper Band #2", offset=offset)
p_lower2 = plot(useBands2 ? lower2 : na, color=color.new(#ffeb3b, 0), title="Lower Band #2", offset=offset)

// Band Plots #3 (Cyan/Teal)
p_upper3 = plot(useBands3 ? upper3 : na, color=color.new(#00bcd4, 0), title="Upper Band #3", offset=offset)
p_lower3 = plot(useBands3 ? lower3 : na, color=color.new(#00bcd4, 0), title="Lower Band #3", offset=offset)

// Fill backgrounds between Band 1
fill(p_upper1, p_lower1, color=color.new(#4caf50, 95), title="Bands Background Fill")

// Chart background highlight based on above/below bias (toggled by showBiasPlot flag)
bgcolor(showBiasPlot ? (src > vwapVal ? color.new(color.green, 97) : color.new(color.red, 97)) : na, title="Bias Background Color")

// Crossover shape flags (toggled by showBiasPlot flag)
plotshape(showBiasPlot and ta.crossover(src, vwapVal), "Bullish Cross", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(showBiasPlot and ta.crossunder(src, vwapVal), "Bearish Cross", shape.triangledown, location.abovebar, color.red, size=size.small)

// ==========================================
// 6. PERFORMANCE-OPTIMIZED METRICS DASHBOARD
// ==========================================

// Define table dimensions (3 Columns, 9 Rows)
var table dashboard = table.new(position=pos, columns=3, rows=9, 
     bgcolor=color.new(#131722, 100), 
     border_color=color.new(#2a2e39, 45), border_width=1,
     frame_color=color.new(#2a2e39, 20), frame_width=1)

if barstate.islast
    cellBg = color.new(#131722, 15)
    
    // Row 0: Merged Header
    table.cell(dashboard, 0, 0, "ANCHORED VWAP METRICS (V6)", 
         bgcolor=color.new(#1e222d, 10), text_color=color.white, text_size=size.small, 
         text_halign=text.align_center, text_formatting=text.format_bold)
    table.merge_cells(dashboard, 0, 0, 2, 0)
    
    // Row 1: Calculated Source
    table.cell(dashboard, 0, 1, "Source", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_left)
    table.cell(dashboard, 1, 1, srcInput, 
         bgcolor=cellBg, text_color=color.white, text_size=size.small, 
         text_halign=text.align_right)
    table.cell(dashboard, 2, 1, str.tostring(src, priceFormat), 
         bgcolor=cellBg, text_color=color.blue, text_size=size.small, 
         text_halign=text.align_center)
    
    // Row 2: Current VWAP Value
    distVwapPct = src == 0.0 ? 0.0 : ((src - vwapVal) / src) * 100.0
    table.cell(dashboard, 0, 2, "VWAP Value", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_left)
    table.cell(dashboard, 1, 2, str.tostring(vwapVal, priceFormat), 
         bgcolor=cellBg, text_color=color.white, text_size=size.small, 
         text_halign=text.align_right)
    table.cell(dashboard, 2, 2, str.tostring(distVwapPct, "#.##") + "% Dist", 
         bgcolor=cellBg, text_color=color.blue, text_size=size.small, 
         text_halign=text.align_center)

    // Row 3: CMP to VWAP Distance (New requested parameter)
    diff = src - vwapVal
    distAbs = math.abs(diff)
    distPct = src == 0.0 ? 0.0 : (diff / src) * 100.0
    signStr = diff > 0.0 ? "+" : diff < 0.0 ? "-" : ""
    distStr = signStr + str.tostring(distAbs, priceFormat) + " (" + str.tostring(math.abs(distPct), "#.##") + "%)"
    
    table.cell(dashboard, 0, 3, "CMP to VWAP", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_left)
    table.cell(dashboard, 1, 3, distStr, 
         bgcolor=cellBg, text_color=color.white, text_size=size.small, 
         text_halign=text.align_right)
    table.cell(dashboard, 2, 3, diff > 0.0 ? "Above" : diff < 0.0 ? "Below" : "Crossed", 
         bgcolor=diff > 0.0 ? color.new(color.green, 90) : diff < 0.0 ? color.new(color.red, 90) : color.new(color.gray, 90), 
         text_color=diff > 0.0 ? color.green : diff < 0.0 ? color.red : color.gray, text_size=size.small, 
         text_halign=text.align_center)
    
    // Row 4: Bands Calculation Mode
    table.cell(dashboard, 0, 4, "Bands Mode", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_left)
    table.cell(dashboard, 1, 4, calcMode, 
         bgcolor=cellBg, text_color=color.white, text_size=size.small, 
         text_halign=text.align_right)
    table.cell(dashboard, 2, 4, "Mode", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_center)

    // Row 5: Volatility Standard Deviation
    table.cell(dashboard, 0, 5, "Std Deviation", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_left)
    table.cell(dashboard, 1, 5, str.tostring(sdVal, priceFormat), 
         bgcolor=cellBg, text_color=color.white, text_size=size.small, 
         text_halign=text.align_right)
    table.cell(dashboard, 2, 5, calcMode == "Standard Deviation" ? "Active SD" : "Inactive SD", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_center)

    // Row 6: Anchor Mode
    table.cell(dashboard, 0, 6, "Anchor Period", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_left)
    table.cell(dashboard, 1, 6, anchorPeriod, 
         bgcolor=cellBg, text_color=color.white, text_size=size.small, 
         text_halign=text.align_right)
    table.cell(dashboard, 2, 6, isLookbackAnchor ? "Lookback" : "Calendar", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_center)

    // Row 7: Bars Since Anchor
    table.cell(dashboard, 0, 7, "Bars Since Reset", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_left)
    table.cell(dashboard, 1, 7, str.tostring(barsSinceAnchor), 
         bgcolor=cellBg, text_color=color.white, text_size=size.small, 
         text_halign=text.align_right)
    table.cell(dashboard, 2, 7, "Bars", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_center)

    // Row 8: Structural Trend Bias
    isBullishBias = src > vwapVal
    table.cell(dashboard, 0, 8, "Market Bias", 
         bgcolor=cellBg, text_color=color.gray, text_size=size.small, 
         text_halign=text.align_left)
    table.cell(dashboard, 1, 8, isBullishBias ? "Bullish" : "Bearish", 
         bgcolor=cellBg, text_color=isBullishBias ? color.green : color.red, text_size=size.small, 
         text_halign=text.align_right)
    table.cell(dashboard, 2, 8, isBullishBias ? "Above VWAP" : "Below VWAP", 
         bgcolor=isBullishBias ? color.new(color.green, 90) : color.new(color.red, 90), 
         text_color=isBullishBias ? color.green : color.red, text_size=size.small, 
         text_halign=text.align_center)
````
