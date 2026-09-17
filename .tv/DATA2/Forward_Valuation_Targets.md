<!-- tradingview-pine-id: PUB;37b2a811a68d49869d67c40f626b1d2b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Forward Valuation Targets

Source: https://www.tradingview.com/script/7Ii3OdUx/

## Description

Forward EPS and Revenue Valuation Targets

The Forward EPS Valuation Terminal Pro is a forward-looking valuation model that translates analyst earnings estimates into potential future price targets.

The indicator combines expected EPS estimates from FY1 to FY4 with an appropriate Forward P/E multiple to calculate an implied fair value for each fiscal year.

The fair P/E can be determined using different approaches: 5- and 10-year historical averages or medians, an interest-rate-adjusted valuation using the US 10Y Treasury yield, an earnings-growth-adjusted valuation, or a combination of these methods.

In addition, ±1 and ±2 standard deviation bands show how the implied price targets would change if the stock were valued at higher or lower Forward P/E multiples.

The displayed targets are not price predictions. Instead, they represent potential valuations based on current analyst expectations and the selected valuation assumptions.

At its core, the indicator answers one question:
“If earnings develop as currently expected, what could the stock be worth in future fiscal years at a reasonable valuation?”

---

## Source Code

````pine
//@version=6
indicator(
    "Forward Valuation Targets",
    shorttitle = "FwdVal",
    overlay = true,
    max_lines_count = 250,
    max_labels_count = 120
)

// ============================================================================
// DEFAULT COLORS
// ============================================================================

color DEF_ORANGE = color.rgb(255, 170, 0)
color DEF_YELLOW = color.rgb(255, 215, 0)
color DEF_GREEN  = color.rgb(0, 210, 90)
color DEF_RED    = color.rgb(255, 70, 70)
color DEF_WHITE  = color.rgb(235, 235, 235)
color DEF_BLUE   = color.rgb(70, 160, 255)
color DEF_GREY   = color.rgb(145, 145, 145)
color DEF_BLACK  = color.rgb(8, 8, 8)

// ============================================================================
// GROUPS
// ============================================================================

string groupModel   = "1. Valuation Model"
string groupSources = "2. Sources"
string groupFY      = "3. Fiscal Year"
string groupLine    = "4. Fair Value Line"
string groupBands   = "5. Standard Deviation Bands"
string groupLabels  = "6. Labels"
string groupTable   = "7. Model Table"

// ============================================================================
// MODEL
// ============================================================================

string metricType = input.string(
    "EPS",
    "Metric",
    options = ["EPS", "Revenue"],
    group = groupModel
)

string peModel = input.string(
    "Historical",
    "Fair Multiple Model",
    options = [
        "Historical",
        "Rate Adjusted",
        "Growth Adjusted",
        "Composite"
    ],
    group = groupModel
)

string valuationMethod = input.string(
    "Auto",
    "Historical Method",
    options = [
        "Auto",
        "5Y Average",
        "10Y Average",
        "5Y Median",
        "10Y Median",
        "Custom"
    ],
    group = groupModel
)

float customMultiple = input.float(
    20.0,
    "Custom Multiple",
    minval = 0.01,
    step = 0.1,
    group = groupModel
)

string stdevLookback = input.string(
    "10Y",
    "StDev Lookback",
    options = ["5Y", "10Y"],
    group = groupModel
)

// ============================================================================
// SOURCES
// ============================================================================

float multipleSource = input.source(
    close,
    "Forward P/E or P/S",
    group = groupSources
)

float treasurySource = input.source(
    close,
    "US 10Y Yield",
    group = groupSources
)

float sourceFY1 = input.source(
    close,
    "FY1 Estimate",
    group = groupSources
)

float sourceFY2 = input.source(
    close,
    "FY2 Estimate",
    group = groupSources
)

float sourceFY3 = input.source(
    close,
    "FY3 Estimate",
    group = groupSources
)

float sourceFY4 = input.source(
    close,
    "FY4 Estimate",
    group = groupSources
)

// ============================================================================
// REVENUE SETTINGS
// ============================================================================

string revenueUnit = input.string(
    "Billions",
    "Revenue Unit",
    options = [
        "Raw",
        "Thousands",
        "Millions",
        "Billions"
    ],
    group = groupSources
)

float revenueFactor = 1.0

if revenueUnit == "Thousands"
    revenueFactor := 1000.0
else if revenueUnit == "Millions"
    revenueFactor := 1000000.0
else if revenueUnit == "Billions"
    revenueFactor := 1000000000.0

// ============================================================================
// LAST VALID FY VALUES
// ============================================================================

var float lastFY1 = na
var float lastFY2 = na
var float lastFY3 = na
var float lastFY4 = na

if not na(sourceFY1) and sourceFY1 > 0
    lastFY1 := sourceFY1

if not na(sourceFY2) and sourceFY2 > 0
    lastFY2 := sourceFY2

if not na(sourceFY3) and sourceFY3 > 0
    lastFY3 := sourceFY3

if not na(sourceFY4) and sourceFY4 > 0
    lastFY4 := sourceFY4

float estimateFY1 = lastFY1
float estimateFY2 = lastFY2
float estimateFY3 = lastFY3
float estimateFY4 = lastFY4

if metricType == "Revenue"
    estimateFY1 := lastFY1 * revenueFactor
    estimateFY2 := lastFY2 * revenueFactor
    estimateFY3 := lastFY3 * revenueFactor
    estimateFY4 := lastFY4 * revenueFactor

// ============================================================================
// SHARES OUTSTANDING
// ============================================================================

float sharesOutstanding = request.financial(
    syminfo.tickerid,
    "TOTAL_SHARES_OUTSTANDING",
    "FQ"
)

// ============================================================================
// FISCAL YEAR
// ============================================================================

int fiscalMonth = input.int(
    12,
    "FY End Month",
    minval = 1,
    maxval = 12,
    group = groupFY
)

int fiscalDay = input.int(
    31,
    "FY End Day",
    minval = 1,
    maxval = 31,
    group = groupFY
)

// ============================================================================
// CENTER LINE SETTINGS
// ============================================================================

color targetLineColor = input.color(
    DEF_ORANGE,
    "Fair Value Line",
    group = groupLine
)

int targetLineWidth = input.int(
    2,
    "Fair Value Line Width",
    minval = 1,
    maxval = 6,
    group = groupLine
)

string targetLineStyleInput = input.string(
    "Solid",
    "Fair Value Line Style",
    options = ["Solid", "Dashed", "Dotted"],
    group = groupLine
)

targetLineStyle = line.style_solid

if targetLineStyleInput == "Dashed"
    targetLineStyle := line.style_dashed
else if targetLineStyleInput == "Dotted"
    targetLineStyle := line.style_dotted

bool connectFromClose = input.bool(
    true,
    "Connect Current Close",
    group = groupLine
)

// ============================================================================
// BAND SETTINGS
// ============================================================================

bool show1SD = input.bool(
    true,
    "Show ±1 StDev",
    group = groupBands
)

bool show2SD = input.bool(
    true,
    "Show ±2 StDev",
    group = groupBands
)

color band1LineColor = input.color(
    DEF_WHITE,
    "±1σ Line",
    group = groupBands
)

color band2LineColor = input.color(
    DEF_BLUE,
    "±2σ Line",
    group = groupBands
)

color band1FillColor = input.color(
    color.new(DEF_WHITE, 88),
    "±1σ Area",
    group = groupBands
)

color band2FillColor = input.color(
    color.new(DEF_BLUE, 93),
    "±2σ Area",
    group = groupBands
)

int bandLineWidth = input.int(
    2,
    "Band Line Width",
    minval = 1,
    maxval = 6,
    group = groupBands
)

// ============================================================================
// LABEL SETTINGS
// ============================================================================

color targetTextColor = input.color(
    DEF_YELLOW,
    "Target Text",
    group = groupLabels
)

color positiveColor = input.color(
    DEF_GREEN,
    "Positive %",
    group = groupLabels
)

color negativeColor = input.color(
    DEF_RED,
    "Negative %",
    group = groupLabels
)

string labelSizeInput = input.string(
    "Normal",
    "Text Size",
    options = [
        "Tiny",
        "Small",
        "Normal",
        "Large",
        "Huge"
    ],
    group = groupLabels
)

labelTextSize = size.normal

if labelSizeInput == "Tiny"
    labelTextSize := size.tiny
else if labelSizeInput == "Small"
    labelTextSize := size.small
else if labelSizeInput == "Large"
    labelTextSize := size.large
else if labelSizeInput == "Huge"
    labelTextSize := size.huge

bool showDates = input.bool(
    true,
    "Show FY Date",
    group = groupLabels
)

bool showPercent = input.bool(
    true,
    "Show % Change",
    group = groupLabels
)

float percentOffsetATR = input.float(
    0.70,
    "% Vertical Offset ATR",
    minval = 0.1,
    maxval = 3.0,
    step = 0.1,
    group = groupLabels
)

bool showMarkers = input.bool(
    true,
    "Show Target Ticks",
    group = groupLabels
)

color markerColor = input.color(
    DEF_YELLOW,
    "Target Tick",
    group = groupLabels
)

int markerWidth = input.int(
    3,
    "Target Tick Width",
    minval = 1,
    maxval = 6,
    group = groupLabels
)

int markerDays = input.int(
    20,
    "Target Tick Length",
    minval = 5,
    maxval = 90,
    group = groupLabels
)

// ============================================================================
// HORIZONTAL TABLE SETTINGS
// ============================================================================

bool showModelTable = input.bool(
    true,
    "Show Model Ribbon",
    group = groupTable
)

string tablePositionInput = input.string(
    "Bottom Right",
    "Position",
    options = [
        "Top Left",
        "Top Center",
        "Top Right",
        "Middle Left",
        "Middle Center",
        "Middle Right",
        "Bottom Left",
        "Bottom Center",
        "Bottom Right"
    ],
    group = groupTable
)

string tableSizeInput = input.string(
    "Small",
    "Text Size",
    options = [
        "Tiny",
        "Small",
        "Normal",
        "Large"
    ],
    group = groupTable
)

color tableBackground = input.color(
    DEF_BLACK,
    "Background",
    group = groupTable
)

int tableBackgroundTransparency = input.int(
    15,
    "Background Transparency",
    minval = 0,
    maxval = 100,
    group = groupTable
)

color tableBorderColor = input.color(
    DEF_ORANGE,
    "Border",
    group = groupTable
)

int tableBorderWidth = input.int(
    1,
    "Border Width",
    minval = 0,
    maxval = 4,
    group = groupTable
)

color tableHeaderColor = input.color(
    DEF_GREY,
    "Header Text",
    group = groupTable
)

color tableValueColor = input.color(
    DEF_WHITE,
    "Value Text",
    group = groupTable
)

color tableUsedColor = input.color(
    DEF_YELLOW,
    "Selected Model",
    group = groupTable
)

color tableInfoColor = input.color(
    DEF_GREY,
    "Info Row",
    group = groupTable
)

bool tableShowTreasury = input.bool(
    true,
    "Show US 10Y",
    group = groupTable
)

bool tableShowGrowth = input.bool(
    true,
    "Show CAGR",
    group = groupTable
)

bool tableShowSigma = input.bool(
    true,
    "Show Sigma",
    group = groupTable
)

// ============================================================================
// TABLE POSITION
// ============================================================================

tablePosition = position.bottom_right

if tablePositionInput == "Top Left"
    tablePosition := position.top_left
else if tablePositionInput == "Top Center"
    tablePosition := position.top_center
else if tablePositionInput == "Top Right"
    tablePosition := position.top_right
else if tablePositionInput == "Middle Left"
    tablePosition := position.middle_left
else if tablePositionInput == "Middle Center"
    tablePosition := position.middle_center
else if tablePositionInput == "Middle Right"
    tablePosition := position.middle_right
else if tablePositionInput == "Bottom Left"
    tablePosition := position.bottom_left
else if tablePositionInput == "Bottom Center"
    tablePosition := position.bottom_center
else
    tablePosition := position.bottom_right

// ============================================================================
// TABLE SIZE
// ============================================================================

tableTextSize = size.small

if tableSizeInput == "Tiny"
    tableTextSize := size.tiny
else if tableSizeInput == "Normal"
    tableTextSize := size.normal
else if tableSizeInput == "Large"
    tableTextSize := size.large

// ============================================================================
// TIME CONSTANTS
// ============================================================================

int DAY_MS = 86400000
int YEAR_MS = 31557600000

int FIVE_YEARS_MS = YEAR_MS * 5
int TEN_YEARS_MS = YEAR_MS * 10

int cutoff5Y = time - FIVE_YEARS_MS
int cutoff10Y = time - TEN_YEARS_MS

// ============================================================================
// TREASURY NORMALIZATION
// ============================================================================

float treasuryYield = na

if not na(treasurySource)
    if treasurySource > 1.0
        treasuryYield := treasurySource / 100.0
    else
        treasuryYield := treasurySource

// ============================================================================
// EXPECTED GROWTH
// ============================================================================

float expectedGrowth = na
float expectedGrowthPct = na

if not na(lastFY1) and not na(lastFY4)
    if lastFY1 > 0 and lastFY4 > 0
        expectedGrowth := math.pow(lastFY4 / lastFY1, 1.0 / 3.0) - 1.0
        expectedGrowthPct := expectedGrowth * 100.0

// ============================================================================
// ARRAYS
// ============================================================================

var array<float> multipleValues = array.new_float()
var array<int> multipleTimes = array.new_int()

var array<float> spreadValues = array.new_float()
var array<int> spreadTimes = array.new_int()

var array<float> pegValues = array.new_float()
var array<int> pegTimes = array.new_int()

// ============================================================================
// RATE SPREAD
// ============================================================================

float earningsYield = na
float yieldSpread = na

if not na(multipleSource) and multipleSource > 0
    earningsYield := 1.0 / multipleSource

if not na(earningsYield) and not na(treasuryYield)
    yieldSpread := earningsYield - treasuryYield

// ============================================================================
// PEG
// ============================================================================

float currentPEG = na

if not na(multipleSource) and multipleSource > 0
    if not na(expectedGrowthPct) and expectedGrowthPct > 0
        currentPEG := multipleSource / expectedGrowthPct

// ============================================================================
// STORE HISTORY
// ============================================================================

if barstate.isnew

    if not na(multipleSource) and multipleSource > 0
        array.push(multipleValues, multipleSource)
        array.push(multipleTimes, time)

    if not na(yieldSpread)
        array.push(spreadValues, yieldSpread)
        array.push(spreadTimes, time)

    if not na(currentPEG) and currentPEG > 0
        array.push(pegValues, currentPEG)
        array.push(pegTimes, time)

// ============================================================================
// REMOVE > 10Y
// ============================================================================

while array.size(multipleTimes) > 0 and array.get(multipleTimes, 0) < cutoff10Y
    array.shift(multipleTimes)
    array.shift(multipleValues)

while array.size(spreadTimes) > 0 and array.get(spreadTimes, 0) < cutoff10Y
    array.shift(spreadTimes)
    array.shift(spreadValues)

while array.size(pegTimes) > 0 and array.get(pegTimes, 0) < cutoff10Y
    array.shift(pegTimes)
    array.shift(pegValues)

// ============================================================================
// STATS
// ============================================================================

float avg5 = na
float avg10 = na
float median5 = na
float median10 = na
float stdev5 = na
float stdev10 = na
float autoMultiple = na

float spreadAvg5 = na
float spreadAvg10 = na
float spreadMed5 = na
float spreadMed10 = na
float spreadAuto = na

float pegAvg5 = na
float pegAvg10 = na
float pegMed5 = na
float pegMed10 = na
float pegAuto = na

if barstate.islast

    // ------------------------------------------------------------------------
    // MULTIPLE 10Y
    // ------------------------------------------------------------------------

    if array.size(multipleValues) > 1
        avg10 := array.avg(multipleValues)
        median10 := array.median(multipleValues)
        stdev10 := array.stdev(multipleValues)

    // ------------------------------------------------------------------------
    // MULTIPLE 5Y
    // ------------------------------------------------------------------------

    array<float> values5Y = array.new_float()

    if array.size(multipleValues) > 0

        for i = 0 to array.size(multipleValues) - 1

            int storedTime = array.get(multipleTimes, i)
            float storedValue = array.get(multipleValues, i)

            if storedTime >= cutoff5Y and not na(storedValue) and storedValue > 0
                array.push(values5Y, storedValue)

    if array.size(values5Y) > 1
        avg5 := array.avg(values5Y)
        median5 := array.median(values5Y)
        stdev5 := array.stdev(values5Y)

    if not na(avg5) and not na(avg10) and not na(median5) and not na(median10)
        autoMultiple := (avg5 + avg10 + median5 + median10) / 4.0

    // ------------------------------------------------------------------------
    // RATE 10Y
    // ------------------------------------------------------------------------

    if array.size(spreadValues) > 0
        spreadAvg10 := array.avg(spreadValues)
        spreadMed10 := array.median(spreadValues)

    // ------------------------------------------------------------------------
    // RATE 5Y
    // ------------------------------------------------------------------------

    array<float> spread5Y = array.new_float()

    if array.size(spreadValues) > 0

        for i = 0 to array.size(spreadValues) - 1

            int storedTime = array.get(spreadTimes, i)

            if storedTime >= cutoff5Y
                array.push(spread5Y, array.get(spreadValues, i))

    if array.size(spread5Y) > 0
        spreadAvg5 := array.avg(spread5Y)
        spreadMed5 := array.median(spread5Y)

    if not na(spreadAvg5) and not na(spreadAvg10) and not na(spreadMed5) and not na(spreadMed10)
        spreadAuto := (spreadAvg5 + spreadAvg10 + spreadMed5 + spreadMed10) / 4.0

    // ------------------------------------------------------------------------
    // PEG 10Y
    // ------------------------------------------------------------------------

    if array.size(pegValues) > 0
        pegAvg10 := array.avg(pegValues)
        pegMed10 := array.median(pegValues)

    // ------------------------------------------------------------------------
    // PEG 5Y
    // ------------------------------------------------------------------------

    array<float> peg5Y = array.new_float()

    if array.size(pegValues) > 0

        for i = 0 to array.size(pegValues) - 1

            int storedTime = array.get(pegTimes, i)

            if storedTime >= cutoff5Y
                array.push(peg5Y, array.get(pegValues, i))

    if array.size(peg5Y) > 0
        pegAvg5 := array.avg(peg5Y)
        pegMed5 := array.median(peg5Y)

    if not na(pegAvg5) and not na(pegAvg10) and not na(pegMed5) and not na(pegMed10)
        pegAuto := (pegAvg5 + pegAvg10 + pegMed5 + pegMed10) / 4.0

// ============================================================================
// HISTORICAL FAIR MULTIPLE
// ============================================================================

float historicalFairPE = na

if valuationMethod == "5Y Average"
    historicalFairPE := avg5
else if valuationMethod == "10Y Average"
    historicalFairPE := avg10
else if valuationMethod == "5Y Median"
    historicalFairPE := median5
else if valuationMethod == "10Y Median"
    historicalFairPE := median10
else if valuationMethod == "Custom"
    historicalFairPE := customMultiple
else
    historicalFairPE := autoMultiple

// ============================================================================
// RATE SPREAD SELECTION
// ============================================================================

float selectedSpread = na

if valuationMethod == "5Y Average"
    selectedSpread := spreadAvg5
else if valuationMethod == "10Y Average"
    selectedSpread := spreadAvg10
else if valuationMethod == "5Y Median"
    selectedSpread := spreadMed5
else if valuationMethod == "10Y Median"
    selectedSpread := spreadMed10
else
    selectedSpread := spreadAuto

// ============================================================================
// PEG SELECTION
// ============================================================================

float selectedPEG = na

if valuationMethod == "5Y Average"
    selectedPEG := pegAvg5
else if valuationMethod == "10Y Average"
    selectedPEG := pegAvg10
else if valuationMethod == "5Y Median"
    selectedPEG := pegMed5
else if valuationMethod == "10Y Median"
    selectedPEG := pegMed10
else
    selectedPEG := pegAuto

// ============================================================================
// RATE ADJUSTED
// ============================================================================

float fairEarningsYield = na
float rateAdjustedPE = na

if not na(treasuryYield) and not na(selectedSpread)
    fairEarningsYield := treasuryYield + selectedSpread

if not na(fairEarningsYield) and fairEarningsYield > 0
    rateAdjustedPE := 1.0 / fairEarningsYield

// ============================================================================
// GROWTH ADJUSTED
// ============================================================================

float growthAdjustedPE = na

if not na(selectedPEG) and selectedPEG > 0
    if not na(expectedGrowthPct) and expectedGrowthPct > 0
        growthAdjustedPE := selectedPEG * expectedGrowthPct

// ============================================================================
// COMPOSITE
// ============================================================================

float compositeSum = 0.0
int compositeCount = 0

if not na(historicalFairPE)
    compositeSum += historicalFairPE
    compositeCount += 1

if not na(rateAdjustedPE)
    compositeSum += rateAdjustedPE
    compositeCount += 1

if not na(growthAdjustedPE)
    compositeSum += growthAdjustedPE
    compositeCount += 1

float compositePE = na

if compositeCount > 0
    compositePE := compositeSum / compositeCount

// ============================================================================
// FINAL MULTIPLE
// ============================================================================

float fairPE = na

if peModel == "Historical"
    fairPE := historicalFairPE
else if peModel == "Rate Adjusted"
    fairPE := rateAdjustedPE
else if peModel == "Growth Adjusted"
    fairPE := growthAdjustedPE
else
    fairPE := compositePE

// ============================================================================
// SIGMA
// ============================================================================

float selectedStDev = na

if stdevLookback == "5Y"
    selectedStDev := stdev5
else
    selectedStDev := stdev10

float multipleUpper1 = na
float multipleLower1 = na
float multipleUpper2 = na
float multipleLower2 = na

if not na(fairPE) and not na(selectedStDev)
    multipleUpper1 := fairPE + selectedStDev
    multipleLower1 := math.max(fairPE - selectedStDev, 0.01)
    multipleUpper2 := fairPE + selectedStDev * 2.0
    multipleLower2 := math.max(fairPE - selectedStDev * 2.0, 0.01)

// ============================================================================
// TARGET CALCULATION
// ============================================================================

calcTarget(float estimate, float multipleValue) =>

    float result = na

    if not na(estimate) and estimate > 0 and not na(multipleValue) and multipleValue > 0

        if metricType == "EPS"
            result := estimate * multipleValue

        else
            if not na(sharesOutstanding) and sharesOutstanding > 0
                result := estimate * multipleValue / sharesOutstanding

    result

// ============================================================================
// TARGETS
// ============================================================================

float targetFY1 = calcTarget(estimateFY1, fairPE)
float targetFY2 = calcTarget(estimateFY2, fairPE)
float targetFY3 = calcTarget(estimateFY3, fairPE)
float targetFY4 = calcTarget(estimateFY4, fairPE)

float upper1FY1 = calcTarget(estimateFY1, multipleUpper1)
float upper1FY2 = calcTarget(estimateFY2, multipleUpper1)
float upper1FY3 = calcTarget(estimateFY3, multipleUpper1)
float upper1FY4 = calcTarget(estimateFY4, multipleUpper1)

float lower1FY1 = calcTarget(estimateFY1, multipleLower1)
float lower1FY2 = calcTarget(estimateFY2, multipleLower1)
float lower1FY3 = calcTarget(estimateFY3, multipleLower1)
float lower1FY4 = calcTarget(estimateFY4, multipleLower1)

float upper2FY1 = calcTarget(estimateFY1, multipleUpper2)
float upper2FY2 = calcTarget(estimateFY2, multipleUpper2)
float upper2FY3 = calcTarget(estimateFY3, multipleUpper2)
float upper2FY4 = calcTarget(estimateFY4, multipleUpper2)

float lower2FY1 = calcTarget(estimateFY1, multipleLower2)
float lower2FY2 = calcTarget(estimateFY2, multipleLower2)
float lower2FY3 = calcTarget(estimateFY3, multipleLower2)
float lower2FY4 = calcTarget(estimateFY4, multipleLower2)

// ============================================================================
// % CHANGE
// ============================================================================

calcChange(float targetValue) =>

    float result = na

    if not na(targetValue) and close > 0
        result := (targetValue / close - 1.0) * 100.0

    result

float changeFY1 = calcChange(targetFY1)
float changeFY2 = calcChange(targetFY2)
float changeFY3 = calcChange(targetFY3)
float changeFY4 = calcChange(targetFY4)

// ============================================================================
// FY DATES
// ============================================================================

int currentYear = year(timenow)

int dateFY1 = timestamp(
    syminfo.timezone,
    currentYear,
    fiscalMonth,
    fiscalDay,
    12,
    0
)

int dateFY2 = timestamp(
    syminfo.timezone,
    currentYear + 1,
    fiscalMonth,
    fiscalDay,
    12,
    0
)

int dateFY3 = timestamp(
    syminfo.timezone,
    currentYear + 2,
    fiscalMonth,
    fiscalDay,
    12,
    0
)

int dateFY4 = timestamp(
    syminfo.timezone,
    currentYear + 3,
    fiscalMonth,
    fiscalDay,
    12,
    0
)

// ============================================================================
// FORMATTERS
// ============================================================================

formatDate(int t) =>

    string dd = str.tostring(dayofmonth(t))
    string mm = str.tostring(month(t))
    string yyyy = str.tostring(year(t))

    if dayofmonth(t) < 10
        dd := "0" + dd

    if month(t) < 10
        mm := "0" + mm

    dd + "." + mm + "." + yyyy

formatPercent(float value) =>

    string result = ""

    if not na(value)

        string signValue = value >= 0 ? "+" : ""

        result := signValue + str.tostring(value, "#.1") + "%"

    result

formatMultiple(float value) =>

    string result = "—"

    if not na(value)
        result := str.tostring(value, "#.##") + "x"

    result

formatYield(float value) =>

    string result = "—"

    if not na(value)
        result := str.tostring(value * 100.0, "#.##") + "%"

    result

formatGrowth(float value) =>

    string result = "—"

    if not na(value)
        result := str.tostring(value, "#.##") + "%"

    result

fyName(int offset) =>
    "FY" + str.tostring(currentYear + offset)

buildMainLabel(
    string targetName,
    float targetValue,
    int targetDate
) =>

    string labelValue = targetName + "  " + str.tostring(targetValue, "#.##")

    if showDates
        labelValue := labelValue + "\n" + formatDate(targetDate)

    labelValue

// ============================================================================
// DRAWING OBJECTS
// ============================================================================

var line center01 = na
var line center12 = na
var line center23 = na
var line center34 = na

var line up1_01 = na
var line up1_12 = na
var line up1_23 = na
var line up1_34 = na

var line dn1_01 = na
var line dn1_12 = na
var line dn1_23 = na
var line dn1_34 = na

var line up2_01 = na
var line up2_12 = na
var line up2_23 = na
var line up2_34 = na

var line dn2_01 = na
var line dn2_12 = na
var line dn2_23 = na
var line dn2_34 = na

var linefill fill1_01 = na
var linefill fill1_12 = na
var linefill fill1_23 = na
var linefill fill1_34 = na

var linefill fill2_01 = na
var linefill fill2_12 = na
var linefill fill2_23 = na
var linefill fill2_34 = na

var line marker1 = na
var line marker2 = na
var line marker3 = na
var line marker4 = na

var label mainLabel1 = na
var label mainLabel2 = na
var label mainLabel3 = na
var label mainLabel4 = na

var label percentLabel1 = na
var label percentLabel2 = na
var label percentLabel3 = na
var label percentLabel4 = na

// ============================================================================
// DELETE FILLS
// ============================================================================

if barstate.islast

    if not na(fill1_01)
        linefill.delete(fill1_01)
        fill1_01 := na

    if not na(fill1_12)
        linefill.delete(fill1_12)
        fill1_12 := na

    if not na(fill1_23)
        linefill.delete(fill1_23)
        fill1_23 := na

    if not na(fill1_34)
        linefill.delete(fill1_34)
        fill1_34 := na

    if not na(fill2_01)
        linefill.delete(fill2_01)
        fill2_01 := na

    if not na(fill2_12)
        linefill.delete(fill2_12)
        fill2_12 := na

    if not na(fill2_23)
        linefill.delete(fill2_23)
        fill2_23 := na

    if not na(fill2_34)
        linefill.delete(fill2_34)
        fill2_34 := na

// ============================================================================
// DELETE LINES
// ============================================================================

if barstate.islast

    if not na(center01)
        line.delete(center01)
        center01 := na

    if not na(center12)
        line.delete(center12)
        center12 := na

    if not na(center23)
        line.delete(center23)
        center23 := na

    if not na(center34)
        line.delete(center34)
        center34 := na

    if not na(up1_01)
        line.delete(up1_01)
        up1_01 := na

    if not na(up1_12)
        line.delete(up1_12)
        up1_12 := na

    if not na(up1_23)
        line.delete(up1_23)
        up1_23 := na

    if not na(up1_34)
        line.delete(up1_34)
        up1_34 := na

    if not na(dn1_01)
        line.delete(dn1_01)
        dn1_01 := na

    if not na(dn1_12)
        line.delete(dn1_12)
        dn1_12 := na

    if not na(dn1_23)
        line.delete(dn1_23)
        dn1_23 := na

    if not na(dn1_34)
        line.delete(dn1_34)
        dn1_34 := na

    if not na(up2_01)
        line.delete(up2_01)
        up2_01 := na

    if not na(up2_12)
        line.delete(up2_12)
        up2_12 := na

    if not na(up2_23)
        line.delete(up2_23)
        up2_23 := na

    if not na(up2_34)
        line.delete(up2_34)
        up2_34 := na

    if not na(dn2_01)
        line.delete(dn2_01)
        dn2_01 := na

    if not na(dn2_12)
        line.delete(dn2_12)
        dn2_12 := na

    if not na(dn2_23)
        line.delete(dn2_23)
        dn2_23 := na

    if not na(dn2_34)
        line.delete(dn2_34)
        dn2_34 := na

    if not na(marker1)
        line.delete(marker1)
        marker1 := na

    if not na(marker2)
        line.delete(marker2)
        marker2 := na

    if not na(marker3)
        line.delete(marker3)
        marker3 := na

    if not na(marker4)
        line.delete(marker4)
        marker4 := na

// ============================================================================
// DELETE LABELS
// ============================================================================

if barstate.islast

    if not na(mainLabel1)
        label.delete(mainLabel1)
        mainLabel1 := na

    if not na(mainLabel2)
        label.delete(mainLabel2)
        mainLabel2 := na

    if not na(mainLabel3)
        label.delete(mainLabel3)
        mainLabel3 := na

    if not na(mainLabel4)
        label.delete(mainLabel4)
        mainLabel4 := na

    if not na(percentLabel1)
        label.delete(percentLabel1)
        percentLabel1 := na

    if not na(percentLabel2)
        label.delete(percentLabel2)
        percentLabel2 := na

    if not na(percentLabel3)
        label.delete(percentLabel3)
        percentLabel3 := na

    if not na(percentLabel4)
        label.delete(percentLabel4)
        percentLabel4 := na

// ============================================================================
// DRAW 2 SIGMA
// ============================================================================

if barstate.islast and show2SD

    if connectFromClose and not na(upper2FY1) and not na(lower2FY1)

        up2_01 := line.new(
            x1 = time_close,
            y1 = close,
            x2 = dateFY1,
            y2 = upper2FY1,
            xloc = xloc.bar_time,
            color = band2LineColor,
            width = bandLineWidth
        )

        dn2_01 := line.new(
            x1 = time_close,
            y1 = close,
            x2 = dateFY1,
            y2 = lower2FY1,
            xloc = xloc.bar_time,
            color = band2LineColor,
            width = bandLineWidth
        )

        fill2_01 := linefill.new(
            up2_01,
            dn2_01,
            band2FillColor
        )

    if not na(upper2FY1) and not na(upper2FY2) and not na(lower2FY1) and not na(lower2FY2)

        up2_12 := line.new(
            x1 = dateFY1,
            y1 = upper2FY1,
            x2 = dateFY2,
            y2 = upper2FY2,
            xloc = xloc.bar_time,
            color = band2LineColor,
            width = bandLineWidth
        )

        dn2_12 := line.new(
            x1 = dateFY1,
            y1 = lower2FY1,
            x2 = dateFY2,
            y2 = lower2FY2,
            xloc = xloc.bar_time,
            color = band2LineColor,
            width = bandLineWidth
        )

        fill2_12 := linefill.new(
            up2_12,
            dn2_12,
            band2FillColor
        )

    if not na(upper2FY2) and not na(upper2FY3) and not na(lower2FY2) and not na(lower2FY3)

        up2_23 := line.new(
            x1 = dateFY2,
            y1 = upper2FY2,
            x2 = dateFY3,
            y2 = upper2FY3,
            xloc = xloc.bar_time,
            color = band2LineColor,
            width = bandLineWidth
        )

        dn2_23 := line.new(
            x1 = dateFY2,
            y1 = lower2FY2,
            x2 = dateFY3,
            y2 = lower2FY3,
            xloc = xloc.bar_time,
            color = band2LineColor,
            width = bandLineWidth
        )

        fill2_23 := linefill.new(
            up2_23,
            dn2_23,
            band2FillColor
        )

    if not na(upper2FY3) and not na(upper2FY4) and not na(lower2FY3) and not na(lower2FY4)

        up2_34 := line.new(
            x1 = dateFY3,
            y1 = upper2FY3,
            x2 = dateFY4,
            y2 = upper2FY4,
            xloc = xloc.bar_time,
            color = band2LineColor,
            width = bandLineWidth
        )

        dn2_34 := line.new(
            x1 = dateFY3,
            y1 = lower2FY3,
            x2 = dateFY4,
            y2 = lower2FY4,
            xloc = xloc.bar_time,
            color = band2LineColor,
            width = bandLineWidth
        )

        fill2_34 := linefill.new(
            up2_34,
            dn2_34,
            band2FillColor
        )

// ============================================================================
// DRAW 1 SIGMA
// ============================================================================

if barstate.islast and show1SD

    if connectFromClose and not na(upper1FY1) and not na(lower1FY1)

        up1_01 := line.new(
            x1 = time_close,
            y1 = close,
            x2 = dateFY1,
            y2 = upper1FY1,
            xloc = xloc.bar_time,
            color = band1LineColor,
            width = bandLineWidth
        )

        dn1_01 := line.new(
            x1 = time_close,
            y1 = close,
            x2 = dateFY1,
            y2 = lower1FY1,
            xloc = xloc.bar_time,
            color = band1LineColor,
            width = bandLineWidth
        )

        fill1_01 := linefill.new(
            up1_01,
            dn1_01,
            band1FillColor
        )

    if not na(upper1FY1) and not na(upper1FY2) and not na(lower1FY1) and not na(lower1FY2)

        up1_12 := line.new(
            x1 = dateFY1,
            y1 = upper1FY1,
            x2 = dateFY2,
            y2 = upper1FY2,
            xloc = xloc.bar_time,
            color = band1LineColor,
            width = bandLineWidth
        )

        dn1_12 := line.new(
            x1 = dateFY1,
            y1 = lower1FY1,
            x2 = dateFY2,
            y2 = lower1FY2,
            xloc = xloc.bar_time,
            color = band1LineColor,
            width = bandLineWidth
        )

        fill1_12 := linefill.new(
            up1_12,
            dn1_12,
            band1FillColor
        )

    if not na(upper1FY2) and not na(upper1FY3) and not na(lower1FY2) and not na(lower1FY3)

        up1_23 := line.new(
            x1 = dateFY2,
            y1 = upper1FY2,
            x2 = dateFY3,
            y2 = upper1FY3,
            xloc = xloc.bar_time,
            color = band1LineColor,
            width = bandLineWidth
        )

        dn1_23 := line.new(
            x1 = dateFY2,
            y1 = lower1FY2,
            x2 = dateFY3,
            y2 = lower1FY3,
            xloc = xloc.bar_time,
            color = band1LineColor,
            width = bandLineWidth
        )

        fill1_23 := linefill.new(
            up1_23,
            dn1_23,
            band1FillColor
        )

    if not na(upper1FY3) and not na(upper1FY4) and not na(lower1FY3) and not na(lower1FY4)

        up1_34 := line.new(
            x1 = dateFY3,
            y1 = upper1FY3,
            x2 = dateFY4,
            y2 = upper1FY4,
            xloc = xloc.bar_time,
            color = band1LineColor,
            width = bandLineWidth
        )

        dn1_34 := line.new(
            x1 = dateFY3,
            y1 = lower1FY3,
            x2 = dateFY4,
            y2 = lower1FY4,
            xloc = xloc.bar_time,
            color = band1LineColor,
            width = bandLineWidth
        )

        fill1_34 := linefill.new(
            up1_34,
            dn1_34,
            band1FillColor
        )

// ============================================================================
// CENTER FAIR VALUE LINE
// ============================================================================

if barstate.islast

    if connectFromClose and not na(targetFY1)

        center01 := line.new(
            x1 = time_close,
            y1 = close,
            x2 = dateFY1,
            y2 = targetFY1,
            xloc = xloc.bar_time,
            color = targetLineColor,
            width = targetLineWidth,
            style = targetLineStyle
        )

    if not na(targetFY1) and not na(targetFY2)

        center12 := line.new(
            x1 = dateFY1,
            y1 = targetFY1,
            x2 = dateFY2,
            y2 = targetFY2,
            xloc = xloc.bar_time,
            color = targetLineColor,
            width = targetLineWidth,
            style = targetLineStyle
        )

    if not na(targetFY2) and not na(targetFY3)

        center23 := line.new(
            x1 = dateFY2,
            y1 = targetFY2,
            x2 = dateFY3,
            y2 = targetFY3,
            xloc = xloc.bar_time,
            color = targetLineColor,
            width = targetLineWidth,
            style = targetLineStyle
        )

    if not na(targetFY3) and not na(targetFY4)

        center34 := line.new(
            x1 = dateFY3,
            y1 = targetFY3,
            x2 = dateFY4,
            y2 = targetFY4,
            xloc = xloc.bar_time,
            color = targetLineColor,
            width = targetLineWidth,
            style = targetLineStyle
        )

// ============================================================================
// TARGET TICKS
// ============================================================================

int markerHalf = markerDays * DAY_MS

if barstate.islast and showMarkers

    if not na(targetFY1)

        marker1 := line.new(
            x1 = dateFY1 - markerHalf,
            y1 = targetFY1,
            x2 = dateFY1 + markerHalf,
            y2 = targetFY1,
            xloc = xloc.bar_time,
            color = markerColor,
            width = markerWidth
        )

    if not na(targetFY2)

        marker2 := line.new(
            x1 = dateFY2 - markerHalf,
            y1 = targetFY2,
            x2 = dateFY2 + markerHalf,
            y2 = targetFY2,
            xloc = xloc.bar_time,
            color = markerColor,
            width = markerWidth
        )

    if not na(targetFY3)

        marker3 := line.new(
            x1 = dateFY3 - markerHalf,
            y1 = targetFY3,
            x2 = dateFY3 + markerHalf,
            y2 = targetFY3,
            xloc = xloc.bar_time,
            color = markerColor,
            width = markerWidth
        )

    if not na(targetFY4)

        marker4 := line.new(
            x1 = dateFY4 - markerHalf,
            y1 = targetFY4,
            x2 = dateFY4 + markerHalf,
            y2 = targetFY4,
            xloc = xloc.bar_time,
            color = markerColor,
            width = markerWidth
        )

// ============================================================================
// TARGET LABELS
// ============================================================================

if barstate.islast

    if not na(targetFY1)

        mainLabel1 := label.new(
            x = dateFY1,
            y = targetFY1,
            text = buildMainLabel(
                fyName(0),
                targetFY1,
                dateFY1
            ),
            xloc = xloc.bar_time,
            style = label.style_none,
            textcolor = targetTextColor,
            size = labelTextSize
        )

    if not na(targetFY2)

        mainLabel2 := label.new(
            x = dateFY2,
            y = targetFY2,
            text = buildMainLabel(
                fyName(1),
                targetFY2,
                dateFY2
            ),
            xloc = xloc.bar_time,
            style = label.style_none,
            textcolor = targetTextColor,
            size = labelTextSize
        )

    if not na(targetFY3)

        mainLabel3 := label.new(
            x = dateFY3,
            y = targetFY3,
            text = buildMainLabel(
                fyName(2),
                targetFY3,
                dateFY3
            ),
            xloc = xloc.bar_time,
            style = label.style_none,
            textcolor = targetTextColor,
            size = labelTextSize
        )

    if not na(targetFY4)

        mainLabel4 := label.new(
            x = dateFY4,
            y = targetFY4,
            text = buildMainLabel(
                fyName(3),
                targetFY4,
                dateFY4
            ),
            xloc = xloc.bar_time,
            style = label.style_none,
            textcolor = targetTextColor,
            size = labelTextSize
        )

// ============================================================================
// % LABELS
// ============================================================================

float labelOffset = math.max(
    ta.atr(14) * percentOffsetATR,
    close * 0.01
)

if barstate.islast and showPercent

    if not na(targetFY1)

        percentLabel1 := label.new(
            x = dateFY1,
            y = targetFY1 - labelOffset,
            text = formatPercent(changeFY1),
            xloc = xloc.bar_time,
            style = label.style_none,
            textcolor = changeFY1 >= 0 ? positiveColor : negativeColor,
            size = labelTextSize
        )

    if not na(targetFY2)

        percentLabel2 := label.new(
            x = dateFY2,
            y = targetFY2 - labelOffset,
            text = formatPercent(changeFY2),
            xloc = xloc.bar_time,
            style = label.style_none,
            textcolor = changeFY2 >= 0 ? positiveColor : negativeColor,
            size = labelTextSize
        )

    if not na(targetFY3)

        percentLabel3 := label.new(
            x = dateFY3,
            y = targetFY3 - labelOffset,
            text = formatPercent(changeFY3),
            xloc = xloc.bar_time,
            style = label.style_none,
            textcolor = changeFY3 >= 0 ? positiveColor : negativeColor,
            size = labelTextSize
        )

    if not na(targetFY4)

        percentLabel4 := label.new(
            x = dateFY4,
            y = targetFY4 - labelOffset,
            text = formatPercent(changeFY4),
            xloc = xloc.bar_time,
            style = label.style_none,
            textcolor = changeFY4 >= 0 ? positiveColor : negativeColor,
            size = labelTextSize
        )

// ============================================================================
// 3-ROW BLOOMBERG RIBBON
// ============================================================================

color tableBgFinal = color.new(
    tableBackground,
    tableBackgroundTransparency
)

var table modelTable = table.new(
    tablePosition,
    8,
    3,
    bgcolor = tableBgFinal,
    frame_color = tableBorderColor,
    frame_width = tableBorderWidth,
    border_color = tableBorderColor,
    border_width = tableBorderWidth
)

// ============================================================================
// TABLE UPDATE
// ============================================================================

if barstate.islast

    table.clear(
        modelTable,
        0,
        0,
        7,
        2
    )

    if showModelTable

        // ====================================================================
        // ROW 1 - HEADERS
        // ====================================================================

        table.cell(
            modelTable,
            0,
            0,
            "HIST",
            text_color = tableHeaderColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            1,
            0,
            "RATE",
            text_color = tableHeaderColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            2,
            0,
            "GROWTH",
            text_color = tableHeaderColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            3,
            0,
            "COMP",
            text_color = tableHeaderColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            4,
            0,
            "USED",
            text_color = tableUsedColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            5,
            0,
            "US10Y",
            text_color = tableHeaderColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            6,
            0,
            "CAGR",
            text_color = tableHeaderColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            7,
            0,
            metricType == "EPS" ? "P/E σ" : "P/S σ",
            text_color = tableHeaderColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        // ====================================================================
        // ROW 2 - VALUES
        // ====================================================================

        table.cell(
            modelTable,
            0,
            1,
            formatMultiple(historicalFairPE),
            text_color = peModel == "Historical" ? tableUsedColor : tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            1,
            1,
            formatMultiple(rateAdjustedPE),
            text_color = peModel == "Rate Adjusted" ? tableUsedColor : tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            2,
            1,
            formatMultiple(growthAdjustedPE),
            text_color = peModel == "Growth Adjusted" ? tableUsedColor : tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            3,
            1,
            formatMultiple(compositePE),
            text_color = peModel == "Composite" ? tableUsedColor : tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            4,
            1,
            formatMultiple(fairPE),
            text_color = tableUsedColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            5,
            1,
            tableShowTreasury ? formatYield(treasuryYield) : "—",
            text_color = tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            6,
            1,
            tableShowGrowth ? formatGrowth(expectedGrowthPct) : "—",
            text_color = tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            7,
            1,
            tableShowSigma ? formatMultiple(selectedStDev) : "—",
            text_color = tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        // ====================================================================
        // ROW 3 - STATUS / MODEL INFO
        // ====================================================================

        table.cell(
            modelTable,
            0,
            2,
            "MODEL",
            text_color = tableInfoColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            1,
            2,
            peModel,
            text_color = tableUsedColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            2,
            2,
            "METHOD",
            text_color = tableInfoColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            3,
            2,
            valuationMethod,
            text_color = tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            4,
            2,
            "METRIC",
            text_color = tableInfoColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            5,
            2,
            metricType,
            text_color = tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            6,
            2,
            "STDEV",
            text_color = tableInfoColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )

        table.cell(
            modelTable,
            7,
            2,
            stdevLookback,
            text_color = tableValueColor,
            text_size = tableTextSize,
            bgcolor = tableBgFinal
        )
````
