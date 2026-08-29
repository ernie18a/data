<!-- tradingview-pine-id: PUB;063d1be18dda4ccbac3dce5f350efb62 -->
<!-- tradingviewscripts-format: 1 -->
# Bitcoin Monthly Seasonality [Alpha Extract]

Source: https://www.tradingview.com/script/o2toJ6Ez-Bitcoin-Monthly-Seasonality-Alpha-Extract/

## Description

The Bitcoin Monthly Seasonality indicator analyzes historical Bitcoin price performance across different months of the year, enabling traders to identify seasonal patterns and potential trading opportunities. This tool helps traders: 

[*]Visualize which months historically perform best and worst for Bitcoin.
[*]Track average returns and win rates for each month of the year. 
[*]Identify seasonal patterns to enhance trading strategies.
[*]Compare cumulative or individual monthly performance.

🔶 CALCULATION

The indicator processes historical Bitcoin price data to calculate monthly performance metrics

Monthly Return Calculation

Inputs: 

[*]Monthly open and close prices. 
[*]User-defined lookback period (1-15 years).
[*]Return Types: 
[*]Percentage: (monthEndPrice / monthStartPrice - 1) × 100 
[*]Price: monthEndPrice - monthStartPrice

Statistical Measures

[*]Monthly Averages: ◦ Average return for each month calculated from historical data.
[*]Win Rate: ◦ Percentage of positive returns for each month.
[*]Best/Worst Detection: ◦ Identifies months with highest and lowest average returns.

Cumulative Option

[*]Standard View: Shows discrete monthly performance.
[*]Cumulative View: Shows compounding effect of consecutive months.

Example Calculation (Pine Script):

[pine]monthReturn = returnType == "Percentage" ? 
              (monthEndPrice / monthStartPrice - 1) * 100 : 
              monthEndPrice - monthStartPrice

calcWinRate(arr) =>
    winCount = 0
    totalCount = array.size(arr)
    if totalCount > 0
        for i = 0 to totalCount - 1
            if array.get(arr, i) > 0
                winCount += 1
        (winCount / totalCount) * 100
    else
        0.0[/pine]

🔶 DETAILS

Visual Features

[*]Monthly Performance Bars: ◦ Color-coded bars (teal for positive, red for negative returns). ◦ Special highlighting for best (yellow) and worst (fuchsia) months.
[*]Optional Trend Line: ◦ Shows continuous performance across months.
[*]Monthly Axis Labels: ◦ Clear month names for easy reference.
[*]Statistics Table: ◦ Comprehensive view of monthly performance metrics. ◦ Color-coded rows based on performance.

Interpretation

[*]Strong Positive Months: Historically bullish periods for Bitcoin.
[*]Strong Negative Months: Historically bearish periods for Bitcoin.
[*]Win Rate Analysis: Higher win rates indicate more consistently positive months.
[*]Pattern Recognition: Identify recurring seasonal patterns across years.
[*]Best/Worst Identification: Quickly spot the historically strongest and weakest months.

🔶 EXAMPLES

The indicator helps identify key seasonal patterns

[*]Bullish Seasons: Visualize historically strong months where Bitcoin tends to perform well, allowing traders to align long positions with favorable seasonality.
[*]Bearish Seasons: Identify historically weak months where Bitcoin tends to underperform, helping traders avoid unfavorable periods or consider short positions.
[*]Seasonal Strategy Development: Create trading strategies that capitalize on recurring monthly patterns, such as entering positions in historically strong months and reducing exposure during weak months.
[*]Year-to-Year Comparison: Assess how current year performance compares to historical seasonal patterns to identify anomalies or confirmation of trends.

[image]https://www.tradingview.com/x/CcdSE4EW/[/image]
🔶 SETTINGS

Customization Options

[*]Lookback Period: Adjust the number of years (1-15) used for historical analysis.
[*]Return Type: Choose between percentage returns or absolute price changes.
[*]Cumulative Option: Toggle between discrete monthly performance or cumulative effect.
[*]Visual Style Options: Bar Display: Enable/disable and customize colors for positive/negative bars, Line Display: Enable/disable and customize colors for trend line, Axes Display: Show/hide reference axes.
[*]Visual Enhancement: Best/Worst Month Highlighting: Toggle special highlighting of extreme months, Custom highlight colors for best and worst performing months.

The Bitcoin Monthly Seasonality indicator provides traders with valuable insights into Bitcoin's historical performance patterns throughout the year, helping to identify potentially favorable and unfavorable trading periods based on seasonal tendencies.

---

## Source Code

````pine
// @version=6
indicator("Bitcoin Monthly Seasonality [Alpha Extract]", overlay=false, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// Input parameters - simplified to just use lookback
var int lookback = input.int(10, "Lookback (Years)", minval=1, maxval=15, group="Data Settings")
var string returnType = input.string("Percentage", "Return Type", options=["Percentage", "Price"], group="Data Settings")
var bool useCumulative = input.bool(true, "Cumulate", group="Data Settings")

// Style settings
var bool showBars = input.bool(true, "Show Bars", inline="bars", group="Style")
var color barUpColor = input.color(color.new(color.teal, 10), "", inline="bars", group="Style")
var color barDnColor = input.color(color.new(color.red, 10), "", inline="bars", group="Style")

var bool showLine = input.bool(false, "Show Line", inline="line", group="Style")
var color upLineColor = input.color(color.teal, "", inline="line", group="Style")
var color dnLineColor = input.color(color.red, "", inline="line", group="Style")

var bool showAxes = input.bool(true, "Show Axes", inline="axes", group="Style")

// NEW: Visual enhancement settings
var bool highlightBestWorst = input.bool(true, "Highlight Best/Worst Months", group="Visual Enhancements")
var color bestMonthColor = input.color(color.yellow, "Best Month Highlight", group="Visual Enhancements")
var color worstMonthColor = input.color(color.fuchsia, "Worst Month Highlight", group="Visual Enhancements")

// Arrays to store monthly returns
var float[] janReturns = array.new_float()
var float[] febReturns = array.new_float()
var float[] marReturns = array.new_float()
var float[] aprReturns = array.new_float()
var float[] mayReturns = array.new_float()
var float[] junReturns = array.new_float()
var float[] julReturns = array.new_float()
var float[] augReturns = array.new_float()
var float[] sepReturns = array.new_float()
var float[] octReturns = array.new_float()
var float[] novReturns = array.new_float()
var float[] decReturns = array.new_float()

// Monthly return calculation variables
var float monthStartPrice = 0.0
var float monthEndPrice = 0.0
var int currentMonth = 0
var int prevMonth = 0
var int currentYear = 0

// Draw objects arrays
var array<line> lines = array.new_line()
var array<line> axes = array.new_line()
var array<box> boxes = array.new_box()

// Initialize drawing objects
if barstate.isfirst
    // Create lines and boxes for the chart
    for i = 0 to 364
        if showLine
            array.push(lines, line.new(na, na, na, na))
        if showBars
            array.push(boxes, box.new(na, na, na, na, bgcolor=color.new(color.teal, 80), border_width=0))
    
    // Create vertical month separator lines
    if showAxes
        for i = 0 to 11
            array.push(axes, line.new(na, na, na, na, color=color.gray, style=line.style_dotted))
        
        // Add one more line for the horizontal axis (will be set in barstate.islast)
        array.push(axes, line.new(na, na, na, na, color=chart.fg_color, style=line.style_solid, width=2))

// Get the current month and year
month = month(time)
yr = year(time)

// Process data and update arrays based on lookback only
isWithinLookback = yr >= year(timenow) - lookback

if month != currentMonth and isWithinLookback
    if currentMonth > 0 and monthStartPrice > 0 and currentYear >= year(timenow) - lookback
        monthReturn = 0.0
        if returnType == "Percentage"
            monthReturn := (monthEndPrice / monthStartPrice - 1) * 100
        else
            monthReturn := monthEndPrice - monthStartPrice
        
        if currentMonth == 1
            array.push(janReturns, monthReturn)
        else if currentMonth == 2
            array.push(febReturns, monthReturn)
        else if currentMonth == 3
            array.push(marReturns, monthReturn)
        else if currentMonth == 4
            array.push(aprReturns, monthReturn)
        else if currentMonth == 5
            array.push(mayReturns, monthReturn)
        else if currentMonth == 6
            array.push(junReturns, monthReturn)
        else if currentMonth == 7
            array.push(julReturns, monthReturn)
        else if currentMonth == 8
            array.push(augReturns, monthReturn)
        else if currentMonth == 9
            array.push(sepReturns, monthReturn)
        else if currentMonth == 10
            array.push(octReturns, monthReturn)
        else if currentMonth == 11
            array.push(novReturns, monthReturn)
        else if currentMonth == 12
            array.push(decReturns, monthReturn)
    
    if month < prevMonth
        currentYear := yr
    
    prevMonth := currentMonth
    currentMonth := month
    monthStartPrice := open

// Update the end price for the current month
monthEndPrice := close

// Calculate average function
calcAvg(arr) =>
    result = 0.0
    if array.size(arr) > 0
        result := array.avg(arr)
    result

// NEW: Calculate win rate function (percentage of positive returns)
calcWinRate(arr) =>
    winCount = 0
    totalCount = array.size(arr)
    if totalCount > 0
        for i = 0 to totalCount - 1
            if array.get(arr, i) > 0
                winCount += 1
        (winCount / totalCount) * 100
    else
        0.0

// Create array of average returns
var float[] averageReturns = array.new_float(12)
array.set(averageReturns, 0, calcAvg(janReturns))
array.set(averageReturns, 1, calcAvg(febReturns))
array.set(averageReturns, 2, calcAvg(marReturns))
array.set(averageReturns, 3, calcAvg(aprReturns))
array.set(averageReturns, 4, calcAvg(mayReturns))
array.set(averageReturns, 5, calcAvg(junReturns))
array.set(averageReturns, 6, calcAvg(julReturns))
array.set(averageReturns, 7, calcAvg(augReturns))
array.set(averageReturns, 8, calcAvg(sepReturns))
array.set(averageReturns, 9, calcAvg(octReturns))
array.set(averageReturns, 10, calcAvg(novReturns))
array.set(averageReturns, 11, calcAvg(decReturns))

// NEW: Create array of win rates
var float[] winRates = array.new_float(12)
array.set(winRates, 0, calcWinRate(janReturns))
array.set(winRates, 1, calcWinRate(febReturns))
array.set(winRates, 2, calcWinRate(marReturns))
array.set(winRates, 3, calcWinRate(aprReturns))
array.set(winRates, 4, calcWinRate(mayReturns))
array.set(winRates, 5, calcWinRate(junReturns))
array.set(winRates, 6, calcWinRate(julReturns))
array.set(winRates, 7, calcWinRate(augReturns))
array.set(winRates, 8, calcWinRate(sepReturns))
array.set(winRates, 9, calcWinRate(octReturns))
array.set(winRates, 10, calcWinRate(novReturns))
array.set(winRates, 11, calcWinRate(decReturns))

// Month names
var string[] monthNames = array.from("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

//Find best and worst months
findBestWorstMonths() =>
    bestIdx = 0
    worstIdx = 0
    bestReturn = array.get(averageReturns, 0)
    worstReturn = array.get(averageReturns, 0)
    
    for i = 1 to 11
        currReturn = array.get(averageReturns, i)
        if currReturn > bestReturn
            bestReturn := currReturn
            bestIdx := i
        if currReturn < worstReturn
            worstReturn := currReturn
            worstIdx := i
    
    [bestIdx, worstIdx]

// Display seasonal chart
if barstate.islast
    n = bar_index
    x1 = useCumulative ? n - 366 : n - 365
    x2 = n - 365
    
    [bestMonthIdx, worstMonthIdx] = findBestWorstMonths()
    
    for i = 0 to 11  // Change from 10 to 11 to include December
        monthPos = x2 + (i * 30) + 15
        label.new(monthPos, 0, array.get(monthNames, i), color=color.rgb(54, 58, 69, 100), textcolor=color.white)
    
    if showAxes
        for i = 0 to 10
            get_axes = array.get(axes, i)
            linePos = x2 + (i * 30)
            get_axes.set_xy1(linePos, 0)
            get_axes.set_xy2(linePos, 0 + syminfo.mintick)
            get_axes.set_style(i == 0 ? line.style_solid : line.style_dotted)
            get_axes.set_width(i == 0 ? 2 : 1)
        
        if array.size(axes) > 12
            horizAxis = array.get(axes, 12)
            
            horizAxis.set_xy1(x2 - 15, 0)  
            horizAxis.set_xy2(x2 + 350, 0)
            horizAxis.set_color(chart.fg_color)
            horizAxis.set_width(2)
    
    float out = 0.0
    float y1 = 0.0
    float wma = 0.0
    float sma = 0.0
    int k = 0
    
    // Process each month's data
    for m = 0 to 11
        
        daysInMonth = m == 1 ? 28 : m == 3 or m == 5 or m == 8 or m == 10 ? 30 : 31
        
        
        monthlyValue = array.get(averageReturns, m)
        out := useCumulative ? out + monthlyValue : monthlyValue
        
        css = out > 0 ? upLineColor : dnLineColor
        cssBar = out > 0 ? barUpColor : barDnColor
        
        
        if highlightBestWorst
            if m == bestMonthIdx
                cssBar := bestMonthColor
            if m == worstMonthIdx
                cssBar := worstMonthColor

        if showLine and k < 365
            get_l = array.get(lines, k)
            get_l.set_xy1(x1 + k, y1)
            get_l.set_xy2(x2 + k, out)
            get_l.set_color(css)
        
        
        if showBars and k < 365
            get_b = array.get(boxes, k)
            get_b.set_lefttop(x2 + k, out)
            get_b.set_rightbottom(x2 + k, 0)
            
            
            if highlightBestWorst
                if m == bestMonthIdx or m == worstMonthIdx
                    get_b.set_border_color(m == bestMonthIdx ? bestMonthColor : worstMonthColor)
                    get_b.set_border_width(3)
                else
                    get_b.set_border_color(cssBar)
                    get_b.set_border_width(2)
            else
                get_b.set_border_color(cssBar)
                get_b.set_border_width(2)
            
            get_b.set_bgcolor(color.rgb(54, 58, 69, 100))
            
            
        k += 30  
        y1 := useCumulative ? out : 0
        wma += out * k
        sma += out
    
    if highlightBestWorst
        
        float cumulativeReturn = 0.0
        if useCumulative
            for i = 0 to 11
                cumulativeReturn += array.get(averageReturns, i)
        
        bestMonthX = x2 + (bestMonthIdx * 30) + 15  
        bestMonthY = useCumulative ? cumulativeReturn : array.get(averageReturns, bestMonthIdx)
        label.new(bestMonthX, bestMonthY + 5, "★ BEST", 
                 color=color.new(color.black, 100), 
                 textcolor=bestMonthColor, 
                 style=label.style_label_center, 
                 size=size.small)
        
        worstMonthX = x2 + (worstMonthIdx * 30) + 15  
        worstMonthY = useCumulative ? cumulativeReturn : array.get(averageReturns, worstMonthIdx)
        label.new(worstMonthX, worstMonthY - 5, "★ WORST", 
                 color=color.new(color.black, 100), 
                 textcolor=worstMonthColor, 
                 style=label.style_label_center, 
                 size=size.small)


// Add statistics table
var table seasonalTable = table.new(position.top_right, columns=4, rows=13, bgcolor=color.rgb(0, 0, 0, 80), frame_color=color.rgb(0, 0, 0, 80), frame_width=1, border_width=1)

// Add table headers
table.cell(seasonalTable, 0, 0, "Month", bgcolor=color.rgb(0, 0, 0), text_color=color.white)
table.cell(seasonalTable, 1, 0, "Avg. Return", bgcolor=color.rgb(0, 0, 0), text_color=color.white)
table.cell(seasonalTable, 2, 0, "Win Rate", bgcolor=color.rgb(0, 0, 0), text_color=color.white) 
table.cell(seasonalTable, 3, 0, "# Years", bgcolor=color.rgb(0, 0, 0), text_color=color.white)

// Get best and worst month indices for table highlighting//
[bestMonthIdxTable, worstMonthIdxTable] = findBestWorstMonths()

// Add data rows
for i = 0 to 11
    
    avgReturn = array.get(averageReturns, i)
    rowColor = avgReturn >= 0 ? color.new(barUpColor, 70) : color.new(barDnColor, 70)
    
    
    if highlightBestWorst
        if i == bestMonthIdxTable
            rowColor := color.new(bestMonthColor, 70)
        if i == worstMonthIdxTable
            rowColor := color.new(worstMonthColor, 70)
    
    // Month name cell
    monthText = array.get(monthNames, i)
    if highlightBestWorst
        if i == bestMonthIdxTable
            monthText := "★ " + monthText
        if i == worstMonthIdxTable
            monthText := "★ " + monthText
    table.cell(seasonalTable, 0, i + 1, monthText, bgcolor=rowColor, text_color=color.white)
    
    // Return value cell
    returnValue = array.get(averageReturns, i)
    returnText = returnType == "Percentage" ? 
                 str.tostring(returnValue, "#.##") + "%" : 
                 "$" + str.tostring(returnValue, "#.##")
    
    table.cell(seasonalTable, 1, i + 1, returnText, bgcolor=rowColor, text_color=color.white)
    
    // NEW: Win rate cell
    winRateValue = array.get(winRates, i)
    winRateText = str.tostring(winRateValue, "#.#") + "%"
    table.cell(seasonalTable, 2, i + 1, winRateText, bgcolor=rowColor, text_color=color.white)
    
    // Sample size cell
    yearCount = 0
    if i == 0
        yearCount := array.size(janReturns)
    else if i == 1
        yearCount := array.size(febReturns)
    else if i == 2
        yearCount := array.size(marReturns)
    else if i == 3
        yearCount := array.size(aprReturns)
    else if i == 4
        yearCount := array.size(mayReturns)
    else if i == 5
        yearCount := array.size(junReturns)
    else if i == 6
        yearCount := array.size(julReturns)
    else if i == 7
        yearCount := array.size(augReturns)
    else if i == 8
        yearCount := array.size(sepReturns)
    else if i == 9
        yearCount := array.size(octReturns)
    else if i == 10
        yearCount := array.size(novReturns)
    else if i == 11
        yearCount := array.size(decReturns)
    
    table.cell(seasonalTable, 3, i + 1, str.tostring(yearCount), bgcolor=rowColor, text_color=color.white)
````
