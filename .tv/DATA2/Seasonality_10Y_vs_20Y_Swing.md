<!-- tradingview-pine-id: PUB;4959036accaa4183bc9f3f48984a3ec9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Seasonality (10Y vs 20Y Swing)

Source: https://www.tradingview.com/script/FmnV7HI5-Seasonality-10Y-vs-20Y-Swing/

## Description

Introducing Seasonality (10Y vs 20Y Swing), a professional-grade indicator designed to analyze monthly seasonal behavior across a dual 10-year and 20-year analytical window.

Unlike traditional seasonal heatmaps that lump all historical data together statically, this script segments core metrics to evaluate how market cycles evolve across medium and long-term horizons.

⚙️ Key Features:

   - Dynamic Heatmap Matrix: Visualizes year-by-year percentage returns for every month, featuring an adaptive color gradient driven by custom cutoff thresholds.

    - 10Y vs 20Y Segmentation: Calculates independent comparative metrics across three critical dimensions:

     - Avgs (Averages): Expected average return per month.

     - StDev (Standard Deviation): Historical dispersion and volatility measurement for the period.

      - Pos% (Percent Positive): Statistical reliability of the month closing in positive territory.

       - Chart Projections (Boxes & Plots): Automatically plots seasonal range boxes for the active month (Expected price for current month) derived from historical averages, supporting data window metrics and main chart overlays (force_overlay = true).

       - Exception Filter: Allows the exclusion of outlier months or structural anomalies via a straightforward text input format (YYYY-MM).

💡 How to Use It:

        - Add the indicator to your chart (optimized for the 1M timeframe to feed historical calculations accurately).

        - Inspect the bottom-anchored Heatmap to pinpoint recurring bullish or bearish seasonal tendencies.

        - Use the current month's projection lines to benchmark live price action against expected seasonal behavior.

---

## Source Code

````pine
//@version=6
indicator("Seasonality (10Y vs 20Y Swing)", overlay = false, max_boxes_count = 500)

//#region ———————————————————— Constants, inputs, and global variables

// Tooltips
string TT_SY = "The year to start seasonality calculations. Box drawings start one year after this value."
string TT_PC = "The base color for boxes and table cells that show positive values."
string TT_NC = "The base color for boxes and table cells that show negative values."
string TT_CP = "The cutoff for maximum color intensity. Absolute values at or above this level have the same color."
string TT_WT = "The table width as a percentage of the pane where the table is located. If this value is 0, the width fits the contents of the table, and the table can be wider than the pane."
string TT_SA = "Toggles the 'Avgs' row, which shows average change percentages for each month."
string TT_SD = "Toggles the 'StDev' row, which shows the standard deviation of each month's percentages."
string TT_SP = "Toggles the 'Pos%' row, which shows the percentage of positive changes in each month's column."
string TT_SM = "Specifies months to skip. Write months in the 'YYYY-MM' format, separated by commas and spaces."

// Configuración del año de inicio
int startYearInput = input.int(2000, "Starting year data collection", minval = 1800, tooltip = TT_SY)

// Color settings 
string COLOR_GRP         = "Color settings"
color  posColorInput     = color.new(input.color(#089981, "Positive Color", group = COLOR_GRP, tooltip = TT_PC), 0)
color  negColorInput     = color.new(input.color(#F23745, "Negative Color", group = COLOR_GRP, tooltip = TT_NC), 0)
int    cutoffPercentInput = input.int(10, "Color intensity cutoff (%)", group = COLOR_GRP, tooltip = TT_CP, display = display.none)

// Table settings
string HEATMAP_GRP         = "Heatmap settings"
string tablePositionInput   = input.string("Center", "Table Position", options = ["Left", "Center", "Right"], group = HEATMAP_GRP, display = display.none)
string textSizeInput        = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = HEATMAP_GRP)
float  tableWidthInput      = input.float(100, "Table Width (%)", maxval = 100, minval = 0, group = HEATMAP_GRP, tooltip = TT_WT,  display = display.none)
bool   showAvgInput         = input.bool(true, "Show Averages",             group = HEATMAP_GRP, tooltip = TT_SA)
bool   showStDevInput       = input.bool(true, "Show Standard Deviation",   group = HEATMAP_GRP, tooltip = TT_SD)
bool   showPosInput         = input.bool(true, "Show Percent Positive",     group = HEATMAP_GRP, tooltip = TT_SP)

//@variable Controls the display of metric rows at the bottom of the Heatmap.
bool showMetrics = showAvgInput or showStDevInput or showPosInput

// Additional settings
string ADD_GRP            = "Additional settings"
string skippedMonthsInput = input.text_area("YYYY-MM, YYYY-MM", "Ignored months", group = ADD_GRP, tooltip = TT_SM)

//@variable An "int" array with all specific months to ignore, formatted as "YYYYMM".
var ignoredMonthsArray = array.new<int>()
if barstate.isfirst
    var ignoredStrArray = str.split(str.replace_all(skippedMonthsInput, " ", ""), ",")
    var ignoredIntArray = array.new<int>()
    for item in ignoredStrArray
        num = str.tonumber(str.replace_all(item, "-", ""))
        ignoredIntArray.push(math.round(num))
    ignoredMonthsArray := ignoredIntArray

//@variable The current year at the time.
int currYear = year(time_close - 1)
//@variable The current month at the time.
int currMonth = month(time_close - 1)

prevTimeClose = time_close[1] - 1
int prevBarYear  = year(prevTimeClose)
int prevBarMonth = month(prevTimeClose)
//#endregion


//#region ———————————————————— Functions and methods

//@function Calculates color used by the boxes and Heatmap cells.
calcColor(float value, int topTranspValue = na) =>
    color naColor     = color.gray
    float heavyTransp = 30
    float lightTransp = 80
    color heavyColor  = color.new(value >= 0 ? posColorInput : negColorInput, heavyTransp)
    color lightColor  = color.new(value >= 0 ? posColorInput : negColorInput, lightTransp)
    color baseColor   = na(value) ? naColor : value >= 0 ? posColorInput : negColorInput
    color transpColor = color.from_gradient(math.abs(value), 0, topTranspValue, lightColor, heavyColor)
    color result      = na(topTranspValue) ? baseColor : transpColor

//@function Returns the one-bar change percentage of the `source`.
changePercent(float source) => 100.0 * (source - source[1]) / math.abs(source[1])

//@function Returns the number of non-na values in `this` array.
method nonNA(array<float> this) =>
    int result = 0
    for item in this
        if not na(item)
            result += 1
    result

//@function Returns the percentage of positive non-na values in `this` array.
method percentPositive(array<float> this) =>
    int nonNACount = 0
    int posCount   = 0
    for item in this
        if not na(item)
            nonNACount += 1
            if item >= 0
                posCount += 1
    float result = nonNACount == 0 ? 0.0 : 100.0 * posCount / nonNACount

//@function Calculates a matrix of monthly changes, starting from the beginning of a specified year.
calculateMontlyChanges(int startYear, int prevBarYear, int prevBarMonth) =>
    var matrix<float> dataMatrix    = matrix.new<float>(0, 13)
    var array<int>    yearIndexArray    = array.new<int>()
    float             prevChangePercent = changePercent(close[1])
    if prevBarYear >= startYear and not ignoredMonthsArray.includes(prevBarYear * 100 + prevBarMonth)
        if prevBarYear != prevBarYear[1] or dataMatrix.rows() == 0
            dataMatrix.add_row()
            yearIndexArray.push(prevBarYear)
        dataMatrix.set(dataMatrix.rows() - 1, prevBarMonth, prevChangePercent)
    [yearIndexArray, dataMatrix]

//@function Filtra una columna de la matriz para obtener los últimos N años disponibles.
getFilteredArray(matrix<float> mat, array<int> years, int colIndex, int lookbackYears, int targetYear) =>
    array<float> filteredValues = array.new<float>()
    int minYear = targetYear - lookbackYears + 1
    for i = 0 to mat.rows() - 1
        int y = years.get(i)
        if y >= minYear and y <= targetYear
            filteredValues.push(mat.get(i, colIndex))
    filteredValues

//@function Calculates the total number of rows to be displayed in the Heatmap table.
countRows(matrix<float> changesMatrix, bool showMetrics, bool showAvg, bool showStDev, bool showPos) =>
    totalRowCount = 1                       // Months header 
    totalRowCount += changesMatrix.rows()   // Number of years
    if showMetrics
        totalRowCount += 1 // Metrics divider
        totalRowCount += showAvg   ? 2 : 0   // +2 (10Y y 20Y)
        totalRowCount += showStDev ? 2 : 0   // +2 (10Y y 20Y)
        totalRowCount += showPos   ? 2 : 0   // +2 (10Y y 20Y)
    totalRowCount
//#endregion


//#region ———————————————————— Main calculations and outputs

// A tuple containing year indices and monthly changes.
[yearIndexArray, changesMatrix] = request.security(
      syminfo.tickerid, "1M", calculateMontlyChanges(startYearInput, prevBarYear, prevBarMonth), lookahead = barmerge.lookahead_on
 )

// Box drawing and plot calculations
var float currMonthAverage       = na
var float currMonthStDev         = na
var float currAvgNumberOfMonths  = na
var float currMonthExpectedPrice = na
if timeframe.change("1M") and not na(changesMatrix)
    currMonthAverage       := changesMatrix.col(currMonth).avg()
    currMonthStDev         := changesMatrix.col(currMonth).stdev(false)
    currAvgNumberOfMonths  := changesMatrix.col(currMonth).nonNA()
    currMonthExpectedPrice := close[1] + close[1] * currMonthAverage / 100
    
    box.new(
          left          = time,
          top           = currMonthExpectedPrice,
          right         = time_close("1M"),
          bottom        = close[1],
          xloc          = xloc.bar_time,
          bgcolor       = calcColor(currMonthAverage, cutoffPercentInput),
          border_color  = calcColor(currMonthAverage),
          text          = str.tostring(currMonthAverage, format.percent),
          text_color    = color.new(chart.fg_color, 0),
          border_style  = line.style_dashed,
          force_overlay = true
     )

displayLoc = display.data_window + display.status_line 
plot(currMonthExpectedPrice, "Expected price for current month", color = calcColor(currMonthAverage), display = displayLoc)
plot(currMonthAverage, "Historical average for current month", color = calcColor(currMonthAverage), display = displayLoc, format = format.percent)
plot(currMonthStDev, "Historical standard deviation for current month", color = color.gray, display = displayLoc, precision = 2)
plot(currAvgNumberOfMonths, "No. of months used in the current average", display = display.data_window, precision = 0)

var monthNames = array.from("Year", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

// Heatmap calculations
if barstate.islast

    tablePosition = switch tablePositionInput
        "Left"   => position.bottom_left
        "Center" => position.bottom_center
        "Right"  => position.bottom_right

    tableTextSize = switch textSizeInput
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

    int totalRowCount = countRows(changesMatrix, showMetrics, showAvgInput, showStDevInput, showPosInput)
    // Corrección para asegurar que la tabla reserve exactamente las filas calculadas sin desbordes
    table dataTable   = table.new(tablePosition, 13, totalRowCount, border_width = 1, border_color = color.new(color.gray, 80))
    color informerCellBgcolor = color.new(#2A2E39, 0)
    color textColor           = color.white
    float cellHeight          = 0.0 
    float cellWidth           = tableWidthInput / 13.0

    // Month headers 
    for [index, item] in monthNames
        dataTable.cell(index, 0, item, bgcolor = informerCellBgcolor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
    
    // Monthly change data cell logic
    for [arrIndex, arr] in changesMatrix
        thisYear = yearIndexArray.get(arrIndex)
        for [itemIndex, item] in arr
            if itemIndex == 0
                dataTable.cell(itemIndex, arrIndex + 1, str.tostring(thisYear), bgcolor = informerCellBgcolor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            else
                isSkipped = ignoredMonthsArray.includes(int(thisYear * 100 + itemIndex))
                cellText  = isSkipped ? "SKIP" : str.tostring(item, "0.0") + "%"
                cellColor = isSkipped ? color.new(color.gray, 50) : calcColor(item, cutoffPercentInput)
                dataTable.cell(itemIndex, arrIndex + 1, cellText, bgcolor = cellColor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
    
    // Metrics cell logic (Segmentación 10Y vs 20Y)
    if showMetrics
        dividerRow = changesMatrix.rows() + 1
        dataTable.cell(0, dividerRow, "", text_color = na, bgcolor = informerCellBgcolor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
        dataTable.merge_cells(0, dividerRow, 12, dividerRow)

        int currentRow = dividerRow + 1
        int targetY = yearIndexArray.size() > 0 ? yearIndexArray.get(yearIndexArray.size() - 1) : currYear

        // --- HISTORICAL AVERAGES (Avgs) ---
        if showAvgInput
            dataTable.cell(0, currentRow, "Avgs 10Y", bgcolor = informerCellBgcolor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            for i = 1 to changesMatrix.columns() - 1
                array<float> subArray = getFilteredArray(changesMatrix, yearIndexArray, i, 10, targetY)
                avgValue = subArray.avg()
                dataTable.cell(i, currentRow, str.tostring(avgValue, "0.0") + "%", bgcolor = calcColor(avgValue, cutoffPercentInput), text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            currentRow += 1
            
            dataTable.cell(0, currentRow, "Avgs 20Y", bgcolor = informerCellBgcolor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            for i = 1 to changesMatrix.columns() - 1
                array<float> subArray = getFilteredArray(changesMatrix, yearIndexArray, i, 20, targetY)
                avgValue = subArray.avg()
                dataTable.cell(i, currentRow, str.tostring(avgValue, "0.0") + "%", bgcolor = calcColor(avgValue, cutoffPercentInput), text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            currentRow += 1

        // --- STANDARD DEVIATION (StDev) ---
        if showStDevInput
            dataTable.cell(0, currentRow, "StDev 10Y", bgcolor = informerCellBgcolor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            for i = 1 to changesMatrix.columns() - 1
                array<float> subArray = getFilteredArray(changesMatrix, yearIndexArray, i, 10, targetY)
                stdevValue = subArray.stdev(false)
                dataTable.cell(i, currentRow, str.tostring(stdevValue, "0.0"), bgcolor = color.new(#363A45, 0), text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            currentRow += 1
            
            dataTable.cell(0, currentRow, "StDev 20Y", bgcolor = informerCellBgcolor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            for i = 1 to changesMatrix.columns() - 1
                array<float> subArray = getFilteredArray(changesMatrix, yearIndexArray, i, 20, targetY)
                stdevValue = subArray.stdev(false)
                dataTable.cell(i, currentRow, str.tostring(stdevValue, "0.0"), bgcolor = color.new(#363A45, 0), text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            currentRow += 1

        // --- PERCENT POSITIVE (Pos%) ---
        if showPosInput
            dataTable.cell(0, currentRow, "Pos% 10Y", bgcolor = informerCellBgcolor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            for i = 1 to changesMatrix.columns() - 1
                array<float> subArray = getFilteredArray(changesMatrix, yearIndexArray, i, 10, targetY)
                ratioValue = subArray.percentPositive()
                dataTable.cell(i, currentRow, str.tostring(ratioValue, "0") + "%", bgcolor = calcColor(ratioValue - 50, 50), text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            currentRow += 1
            
            dataTable.cell(0, currentRow, "Pos% 20Y", bgcolor = informerCellBgcolor, text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            for i = 1 to changesMatrix.columns() - 1
                array<float> subArray = getFilteredArray(changesMatrix, yearIndexArray, i, 20, targetY)
                ratioValue = subArray.percentPositive()
                dataTable.cell(i, currentRow, str.tostring(ratioValue, "0") + "%", bgcolor = calcColor(ratioValue - 50, 50), text_color = textColor, text_size = tableTextSize, height = cellHeight, width = cellWidth)
            currentRow += 1
//#endregion
````
