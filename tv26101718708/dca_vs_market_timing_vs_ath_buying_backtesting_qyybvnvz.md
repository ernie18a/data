# DCA vs Market Timing vs ATH Buying - Backtesting

- url: https://www.tradingview.com/script/QYybvnVz-DCA-vs-Market-Timing-vs-ATH-Buying-Backtesting/
- type: indicator
- pine_id: PUB;6339356d9f6d4c43978e5746196d7e6f
- version: 1.0

## Description

Compare investment timing strategies with equal capital to see which actually performs best.

This indicator backtests whether buying at all-time highs, waiting for pullbacks, or regular DCA builds more wealth over time.

Each strategy receives the same monthly budget (default $100). The difference is when they invest:
[list]
[*]ATH Strategy: Invests when price hits new highs (1-year lookback default)
[*]Pullback Strategies: Wait for 5%, 10%, 15%, or 20% corrections before investing
[*]Regular DCA: Invests monthly regardless of price
[/list]
Key Metrics:
[list]
[*]Budget: Total capital allocated (equal for all)
[*]Value: Current portfolio value (stocks + cash)
[*]Return%: Overall performance
[*]Deployed%: How much capital is actually invested vs sitting in cash earning 0%
[*]Trades: Number of investments made
[/list]
The Deployed% column reveals the hidden cost of waiting. Pullback strategies often underperform because they keep too much cash idle, missing the gains that occur while waiting for corrections.

Use Cases:
[list]
[*]Validate whether waiting for corrections is worth the opportunity cost
[*]Test different pullback thresholds on historical data
[*]Compare ATH investing vs DCA vs market timing
[*]Analyze performance across different time periods
[*]Results typically show that time in the market beats timing the market—this tool lets you prove it with data.
[/list]

## Source Code

````pine
//@version=6
//By Henrique Centieiro
indicator("DCA vs Market Timing: Visual Strategy Backtest with Deployment Tracking", overlay=false, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================================
// INPUTS
// ============================================================================

// Date Range
startDate = input.time(timestamp("2018-01-01 00:00"), "Start Date", group="Date Range")
endDate = input.time(timestamp("2030-12-31 23:59"), "End Date", group="Date Range")

// Investment Settings
monthlyBudget = input.float(100.0, "Monthly Investment Budget ($)", minval=1.0, group="Investment Settings", tooltip="Each strategy gets this amount monthly. If no signal, stays in cash.")
tradingDaysPerMonth = input.int(21, "Trading Days per Month", minval=1, group="Investment Settings")

// ATH Detection
athLookback = input.int(252, "ATH Lookback Period (bars)", minval=20, group="ATH Settings")

// Pullback Levels
enablePb1 = input.bool(true, "Enable Pullback 1", group="Pullback Settings")
pb1Pct = input.float(5.0, "Pullback 1 (%)", minval=1.0, maxval=50.0, step=0.5, group="Pullback Settings")

enablePb2 = input.bool(true, "Enable Pullback 2", group="Pullback Settings")
pb2Pct = input.float(10.0, "Pullback 2 (%)", minval=1.0, maxval=50.0, step=0.5, group="Pullback Settings")

enablePb3 = input.bool(true, "Enable Pullback 3", group="Pullback Settings")
pb3Pct = input.float(15.0, "Pullback 3 (%)", minval=1.0, maxval=50.0, step=0.5, group="Pullback Settings")

enablePb4 = input.bool(false, "Enable Pullback 4", group="Pullback Settings")
pb4Pct = input.float(20.0, "Pullback 4 (%)", minval=1.0, maxval=50.0, step=0.5, group="Pullback Settings")

// Regular Investment (DCA baseline)
enableRegular = input.bool(true, "Enable Regular DCA Strategy", group="Regular Investment (DCA)", tooltip="Invests monthly regardless of market conditions")

// Visual Options
showAthCurve = input.bool(true, "Show ATH Strategy Curve", group="Visual Options")
showPb1Curve = input.bool(true, "Show Pullback 1 Curve", group="Visual Options")
showPb2Curve = input.bool(true, "Show Pullback 2 Curve", group="Visual Options")
showPb3Curve = input.bool(true, "Show Pullback 3 Curve", group="Visual Options")
showPb4Curve = input.bool(false, "Show Pullback 4 Curve", group="Visual Options")
showRegularCurve = input.bool(true, "Show Regular DCA Curve", group="Visual Options")
showStatsTable = input.bool(true, "Show Statistics Table", group="Visual Options")
tablePosition = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Visual Options")
tableSize = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Visual Options")

// Check if current bar is within date range
inDateRange = time >= startDate and time <= endDate

// ============================================================================
// ATH DETECTION
// ============================================================================

// Calculate all-time high over lookback period
athValue = ta.highest(close, athLookback)
isNewAth = close >= athValue and close > close[1] and inDateRange

// Track the most recent ATH value for pullback calculations
var float recentAthValue = na
if isNewAth
    recentAthValue := close
else if not na(recentAthValue)
    recentAthValue := math.max(recentAthValue, athValue)
else
    recentAthValue := athValue

// ============================================================================
// PULLBACK DETECTION
// ============================================================================

// Calculate pullback percentage from recent ATH
pullbackPct = na(recentAthValue) or recentAthValue == 0 ? 0 : ((recentAthValue - close) / recentAthValue) * 100

// Detect when price hits each pullback level
hitPb1 = enablePb1 and pullbackPct >= pb1Pct and pullbackPct[1] < pb1Pct and inDateRange
hitPb2 = enablePb2 and pullbackPct >= pb2Pct and pullbackPct[1] < pb2Pct and inDateRange
hitPb3 = enablePb3 and pullbackPct >= pb3Pct and pullbackPct[1] < pb3Pct and inDateRange
hitPb4 = enablePb4 and pullbackPct >= pb4Pct and pullbackPct[1] < pb4Pct and inDateRange

// ============================================================================
// MONTHLY BUDGET ALLOCATION
// ============================================================================

// Track monthly intervals
var int lastMonthlyBar = 0
isMonthlyInterval = (bar_index - lastMonthlyBar) >= tradingDaysPerMonth and inDateRange

if isMonthlyInterval
    lastMonthlyBar := bar_index

// ============================================================================
// PORTFOLIO TRACKING (Stock + Cash)
// ============================================================================

// Each strategy maintains:
// - Stock positions (invested in market)
// - Cash balance (waiting for signals)
// - Total value = Stock value + Cash

// ATH Strategy
var array<float> athStockEntries = array.new<float>()
var array<float> athStockAmounts = array.new<float>()
var float athCash = 0.0
var float athTotalBudgetReceived = 0.0
var float athTotalInvestedInStocks = 0.0
var int athTradeCount = 0

// Pullback 1 Strategy
var array<float> pb1StockEntries = array.new<float>()
var array<float> pb1StockAmounts = array.new<float>()
var float pb1Cash = 0.0
var float pb1TotalBudgetReceived = 0.0
var float pb1TotalInvestedInStocks = 0.0
var int pb1TradeCount = 0

// Pullback 2 Strategy
var array<float> pb2StockEntries = array.new<float>()
var array<float> pb2StockAmounts = array.new<float>()
var float pb2Cash = 0.0
var float pb2TotalBudgetReceived = 0.0
var float pb2TotalInvestedInStocks = 0.0
var int pb2TradeCount = 0

// Pullback 3 Strategy
var array<float> pb3StockEntries = array.new<float>()
var array<float> pb3StockAmounts = array.new<float>()
var float pb3Cash = 0.0
var float pb3TotalBudgetReceived = 0.0
var float pb3TotalInvestedInStocks = 0.0
var int pb3TradeCount = 0

// Pullback 4 Strategy
var array<float> pb4StockEntries = array.new<float>()
var array<float> pb4StockAmounts = array.new<float>()
var float pb4Cash = 0.0
var float pb4TotalBudgetReceived = 0.0
var float pb4TotalInvestedInStocks = 0.0
var int pb4TradeCount = 0

// Regular DCA Strategy
var array<float> regularStockEntries = array.new<float>()
var array<float> regularStockAmounts = array.new<float>()
var float regularCash = 0.0
var float regularTotalBudgetReceived = 0.0
var float regularTotalInvestedInStocks = 0.0
var int regularTradeCount = 0

// Function to calculate stock portfolio value
calcStockValue(entries, amounts) =>
    totalValue = 0.0
    if array.size(entries) > 0
        for i = 0 to array.size(entries) - 1
            entryPrice = array.get(entries, i)
            investedAmount = array.get(amounts, i)
            currentValue = investedAmount * (close / entryPrice)
            totalValue += currentValue
    totalValue

// ============================================================================
// MONTHLY BUDGET DISTRIBUTION
// ============================================================================

// Every month, each strategy receives budget
if isMonthlyInterval
    athCash += monthlyBudget
    athTotalBudgetReceived += monthlyBudget

    pb1Cash += monthlyBudget
    pb1TotalBudgetReceived += monthlyBudget

    pb2Cash += monthlyBudget
    pb2TotalBudgetReceived += monthlyBudget

    pb3Cash += monthlyBudget
    pb3TotalBudgetReceived += monthlyBudget

    pb4Cash += monthlyBudget
    pb4TotalBudgetReceived += monthlyBudget

    regularCash += monthlyBudget
    regularTotalBudgetReceived += monthlyBudget

// ============================================================================
// SIGNAL-BASED INVESTING
// ============================================================================

// ATH Strategy: Invest cash when ATH signal
if isNewAth and athCash >= monthlyBudget
    athTradeCount += 1
    array.push(athStockEntries, close)
    array.push(athStockAmounts, athCash)
    athTotalInvestedInStocks += athCash
    athCash := 0.0

// Pullback 1: Invest cash when pullback signal
if hitPb1 and pb1Cash >= monthlyBudget
    pb1TradeCount += 1
    array.push(pb1StockEntries, close)
    array.push(pb1StockAmounts, pb1Cash)
    pb1TotalInvestedInStocks += pb1Cash
    pb1Cash := 0.0

// Pullback 2: Invest cash when pullback signal
if hitPb2 and pb2Cash >= monthlyBudget
    pb2TradeCount += 1
    array.push(pb2StockEntries, close)
    array.push(pb2StockAmounts, pb2Cash)
    pb2TotalInvestedInStocks += pb2Cash
    pb2Cash := 0.0

// Pullback 3: Invest cash when pullback signal
if hitPb3 and pb3Cash >= monthlyBudget
    pb3TradeCount += 1
    array.push(pb3StockEntries, close)
    array.push(pb3StockAmounts, pb3Cash)
    pb3TotalInvestedInStocks += pb3Cash
    pb3Cash := 0.0

// Pullback 4: Invest cash when pullback signal
if hitPb4 and pb4Cash >= monthlyBudget
    pb4TradeCount += 1
    array.push(pb4StockEntries, close)
    array.push(pb4StockAmounts, pb4Cash)
    pb4TotalInvestedInStocks += pb4Cash
    pb4Cash := 0.0

// Regular DCA: Invest monthly regardless
if isMonthlyInterval and enableRegular and regularCash >= monthlyBudget
    regularTradeCount += 1
    array.push(regularStockEntries, close)
    array.push(regularStockAmounts, monthlyBudget)
    regularTotalInvestedInStocks += monthlyBudget
    regularCash -= monthlyBudget

// ============================================================================
// PORTFOLIO VALUES (Stock + Cash)
// ============================================================================

athStockValue = calcStockValue(athStockEntries, athStockAmounts)
athTotalValue = athStockValue + athCash

pb1StockValue = calcStockValue(pb1StockEntries, pb1StockAmounts)
pb1TotalValue = pb1StockValue + pb1Cash

pb2StockValue = calcStockValue(pb2StockEntries, pb2StockAmounts)
pb2TotalValue = pb2StockValue + pb2Cash

pb3StockValue = calcStockValue(pb3StockEntries, pb3StockAmounts)
pb3TotalValue = pb3StockValue + pb3Cash

pb4StockValue = calcStockValue(pb4StockEntries, pb4StockAmounts)
pb4TotalValue = pb4StockValue + pb4Cash

regularStockValue = calcStockValue(regularStockEntries, regularStockAmounts)
regularTotalValue = regularStockValue + regularCash

// Calculate returns
athReturn = athTotalBudgetReceived > 0 ? ((athTotalValue - athTotalBudgetReceived) / athTotalBudgetReceived) * 100 : 0
pb1Return = pb1TotalBudgetReceived > 0 ? ((pb1TotalValue - pb1TotalBudgetReceived) / pb1TotalBudgetReceived) * 100 : 0
pb2Return = pb2TotalBudgetReceived > 0 ? ((pb2TotalValue - pb2TotalBudgetReceived) / pb2TotalBudgetReceived) * 100 : 0
pb3Return = pb3TotalBudgetReceived > 0 ? ((pb3TotalValue - pb3TotalBudgetReceived) / pb3TotalBudgetReceived) * 100 : 0
pb4Return = pb4TotalBudgetReceived > 0 ? ((pb4TotalValue - pb4TotalBudgetReceived) / pb4TotalBudgetReceived) * 100 : 0
regularReturn = regularTotalBudgetReceived > 0 ? ((regularTotalValue - regularTotalBudgetReceived) / regularTotalBudgetReceived) * 100 : 0

// Calculate deployment % (cost basis, not current value)
athDeployment = athTotalBudgetReceived > 0 ? (athTotalInvestedInStocks / athTotalBudgetReceived) * 100 : 0
pb1Deployment = pb1TotalBudgetReceived > 0 ? (pb1TotalInvestedInStocks / pb1TotalBudgetReceived) * 100 : 0
pb2Deployment = pb2TotalBudgetReceived > 0 ? (pb2TotalInvestedInStocks / pb2TotalBudgetReceived) * 100 : 0
pb3Deployment = pb3TotalBudgetReceived > 0 ? (pb3TotalInvestedInStocks / pb3TotalBudgetReceived) * 100 : 0
pb4Deployment = pb4TotalBudgetReceived > 0 ? (pb4TotalInvestedInStocks / pb4TotalBudgetReceived) * 100 : 0
regularDeployment = regularTotalBudgetReceived > 0 ? (regularTotalInvestedInStocks / regularTotalBudgetReceived) * 100 : 0

// ============================================================================
// PLOTTING
// ============================================================================

// Plot total portfolio values (Stock + Cash)
plot(showAthCurve ? athTotalValue : na, "ATH Strategy", color=color.green, linewidth=2)
plot(showPb1Curve and enablePb1 ? pb1TotalValue : na, "Pullback 1", color=color.rgb(255, 152, 0), linewidth=2)
plot(showPb2Curve and enablePb2 ? pb2TotalValue : na, "Pullback 2", color=color.red, linewidth=2)
plot(showPb3Curve and enablePb3 ? pb3TotalValue : na, "Pullback 3", color=color.purple, linewidth=2)
plot(showPb4Curve and enablePb4 ? pb4TotalValue : na, "Pullback 4", color=color.maroon, linewidth=2)
plot(showRegularCurve and enableRegular ? regularTotalValue : na, "Regular DCA", color=color.blue, linewidth=2)

// ============================================================================
// STATISTICS TABLE
// ============================================================================

// Convert position string to Pine Script position constant
getTablePosition() =>
    tablePosition == "Top Left" ? position.top_left :
     tablePosition == "Top Center" ? position.top_center :
     tablePosition == "Top Right" ? position.top_right :
     tablePosition == "Middle Left" ? position.middle_left :
     tablePosition == "Middle Center" ? position.middle_center :
     tablePosition == "Middle Right" ? position.middle_right :
     tablePosition == "Bottom Left" ? position.bottom_left :
     tablePosition == "Bottom Center" ? position.bottom_center :
     position.bottom_right

// Convert size string to Pine Script size constant
getTextSize() =>
    tableSize == "Tiny" ? size.tiny :
     tableSize == "Small" ? size.small :
     tableSize == "Normal" ? size.normal :
     tableSize == "Large" ? size.large :
     size.huge

textSize = getTextSize()

if showStatsTable and barstate.islast
    var table statsTable = table.new(getTablePosition(), 6, 8, bgcolor=color.new(color.black, 80), frame_color=color.gray, frame_width=1, border_width=1, border_color=color.gray)

    // Header row
    table.cell(statsTable, 0, 0, "Strategy", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=textSize)
    table.cell(statsTable, 1, 0, "Budget", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=textSize)
    table.cell(statsTable, 2, 0, "Value", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=textSize)
    table.cell(statsTable, 3, 0, "Return%", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=textSize)
    table.cell(statsTable, 4, 0, "Deployed%", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=textSize)
    table.cell(statsTable, 5, 0, "Trades", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=textSize)

    // ATH Strategy
    table.cell(statsTable, 0, 1, "ATH", text_color=color.green, text_size=textSize)
    table.cell(statsTable, 1, 1, "$" + str.tostring(athTotalBudgetReceived, "#,###"), text_color=color.white, text_size=textSize)
    table.cell(statsTable, 2, 1, "$" + str.tostring(athTotalValue, "#,###"), text_color=color.white, text_size=textSize)
    table.cell(statsTable, 3, 1, str.tostring(athReturn, "#.##") + "%", text_color=athReturn >= 0 ? color.green : color.red, text_size=textSize)
    table.cell(statsTable, 4, 1, str.tostring(athDeployment, "#.#") + "%", text_color=color.white, text_size=textSize)
    table.cell(statsTable, 5, 1, str.tostring(athTradeCount), text_color=color.white, text_size=textSize)

    // Pullback 1
    if enablePb1
        table.cell(statsTable, 0, 2, "PB " + str.tostring(pb1Pct) + "%", text_color=color.orange, text_size=textSize)
        table.cell(statsTable, 1, 2, "$" + str.tostring(pb1TotalBudgetReceived, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 2, 2, "$" + str.tostring(pb1TotalValue, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 3, 2, str.tostring(pb1Return, "#.##") + "%", text_color=pb1Return >= 0 ? color.green : color.red, text_size=textSize)
        table.cell(statsTable, 4, 2, str.tostring(pb1Deployment, "#.#") + "%", text_color=color.white, text_size=textSize)
        table.cell(statsTable, 5, 2, str.tostring(pb1TradeCount), text_color=color.white, text_size=textSize)

    // Pullback 2
    if enablePb2
        table.cell(statsTable, 0, 3, "PB " + str.tostring(pb2Pct) + "%", text_color=color.red, text_size=textSize)
        table.cell(statsTable, 1, 3, "$" + str.tostring(pb2TotalBudgetReceived, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 2, 3, "$" + str.tostring(pb2TotalValue, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 3, 3, str.tostring(pb2Return, "#.##") + "%", text_color=pb2Return >= 0 ? color.green : color.red, text_size=textSize)
        table.cell(statsTable, 4, 3, str.tostring(pb2Deployment, "#.#") + "%", text_color=color.white, text_size=textSize)
        table.cell(statsTable, 5, 3, str.tostring(pb2TradeCount), text_color=color.white, text_size=textSize)

    // Pullback 3
    if enablePb3
        table.cell(statsTable, 0, 4, "PB " + str.tostring(pb3Pct) + "%", text_color=color.purple, text_size=textSize)
        table.cell(statsTable, 1, 4, "$" + str.tostring(pb3TotalBudgetReceived, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 2, 4, "$" + str.tostring(pb3TotalValue, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 3, 4, str.tostring(pb3Return, "#.##") + "%", text_color=pb3Return >= 0 ? color.green : color.red, text_size=textSize)
        table.cell(statsTable, 4, 4, str.tostring(pb3Deployment, "#.#") + "%", text_color=color.white, text_size=textSize)
        table.cell(statsTable, 5, 4, str.tostring(pb3TradeCount), text_color=color.white, text_size=textSize)

    // Pullback 4
    if enablePb4
        table.cell(statsTable, 0, 5, "PB " + str.tostring(pb4Pct) + "%", text_color=color.maroon, text_size=textSize)
        table.cell(statsTable, 1, 5, "$" + str.tostring(pb4TotalBudgetReceived, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 2, 5, "$" + str.tostring(pb4TotalValue, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 3, 5, str.tostring(pb4Return, "#.##") + "%", text_color=pb4Return >= 0 ? color.green : color.red, text_size=textSize)
        table.cell(statsTable, 4, 5, str.tostring(pb4Deployment, "#.#") + "%", text_color=color.white, text_size=textSize)
        table.cell(statsTable, 5, 5, str.tostring(pb4TradeCount), text_color=color.white, text_size=textSize)

    // Regular DCA
    if enableRegular
        table.cell(statsTable, 0, 6, "Regular DCA", text_color=color.blue, text_size=textSize)
        table.cell(statsTable, 1, 6, "$" + str.tostring(regularTotalBudgetReceived, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 2, 6, "$" + str.tostring(regularTotalValue, "#,###"), text_color=color.white, text_size=textSize)
        table.cell(statsTable, 3, 6, str.tostring(regularReturn, "#.##") + "%", text_color=regularReturn >= 0 ? color.green : color.red, text_size=textSize)
        table.cell(statsTable, 4, 6, str.tostring(regularDeployment, "#.#") + "%", text_color=color.white, text_size=textSize)
        table.cell(statsTable, 5, 6, str.tostring(regularTradeCount), text_color=color.white, text_size=textSize)

    // Footer note
    table.cell(statsTable, 0, 7, "Equal monthly budget. Deployed% = capital in stocks vs cash", text_color=color.gray, text_size=size.tiny, tooltip="All strategies receive same monthly budget. Deployed% shows how much is invested vs sitting in cash")
    table.merge_cells(statsTable, 0, 7, 5, 7)
````
