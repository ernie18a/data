<!-- tradingview-pine-id: PUB;31200fee1c52410a9803c9c3c7004282 -->
<!-- tradingviewscripts-format: 1 -->
# Yelober - Sector Rotation Detector

Source: https://www.tradingview.com/script/7jm5ebze-Yelober-Sector-Rotation-Detector/

## Description

# Yelober - Sector Rotation Detector: User Guide

## Overview
The Yelober - Sector Rotation Detector is a TradingView indicator designed to track sector performance and identify market rotations in real-time. It monitors key sector ETFs, calculates performance metrics, and provides actionable stock recommendations based on sector strength and weakness.

## Purpose
This indicator helps traders identify when capital is moving from one sector to another (sector rotation), which can provide valuable trading opportunities. It also detects risk-off conditions in the market and highlights sectors with abnormal trading volume.

## Table Columns Explained

### 1. Sector
Displays the sector name being monitored. The indicator tracks six primary sectors plus the S&P 500:
- Energy (XLE)
- Financial (XLF) 
- Technology (XLK)
- Consumer Staples (XLP)
- Utilities (XLU)
- Consumer Discretionary (XLY)
- S&P 500 (SPY)

### 2. Perf %
Shows the daily percentage performance of each sector ETF. Values are color-coded:
- Green: Positive performance
- Red: Negative performance
Positive values display with a "+" sign (e.g., +1.25%)

### 3. RSI
Displays the Relative Strength Index value for each sector, which helps identify overbought or oversold conditions:
- Values above 70 (highlighted in red): Potentially overbought
- Values below 30 (highlighted in green): Potentially oversold
- Values between 30-70 (highlighted in blue): Neutral territory

### 4. Vol Ratio
Shows the volume ratio, which compares today's volume to the average volume over the lookback period:
- Values above 1.5x (highlighted in yellow): Indicates abnormally high trading volume
- Values below 1.5x (highlighted in blue): Normal trading volume
This helps identify sectors with unusual activity that may signal important price movements.

### 5. Trend
Displays the current price trend direction with symbols:
- ▲ (green): Uptrend (today's close > yesterday's close)
- ▼ (red): Downtrend (today's close < yesterday's close)
- ◆ (gray): Neutral (today's close = yesterday's close)

## Summary & Recommendations Section

The summary section provides:

1. **Sector Rotation Detection**: Identifies when there's a significant performance gap (>2%) between the strongest and weakest sectors.

2. **Risk-Off Mode Detection**: Alerts when defensive sectors (Consumer Staples and Utilities) are positive while Technology is negative, which often signals investors are moving to safer assets.

3. **Strong Volume Detection**: Indicates when any sector shows abnormally high trading volume.

4. **Stock Recommendations**: Suggests specific stocks to consider for long positions (from the strongest sectors) and short positions (from the weakest sectors).

## Example Interpretations

### Example 1: Sector Rotation
If you see:
- Technology: -1.85%
- Financial: +2.10% 
- Summary shows: "SECTOR ROTATION DETECTED: Rotation from Technology to Financial"

**Interpretation**: Capital is moving out of tech stocks and into financial stocks. This could be due to rising interest rates, which typically benefit banks while pressuring high-growth tech companies. Consider looking at financial stocks like JPM, BAC, and WFC for potential long positions.

### Example 2: Risk-Off Conditions
If you see:
- Consumer Staples: +0.80%
- Utilities: +1.20%
- Technology: -1.50%
- Summary shows: "RISK-OFF MODE DETECTED"

**Interpretation**: Investors are seeking safety in defensive sectors while selling growth-oriented tech stocks. This often occurs during market uncertainty or ahead of economic concerns. Consider reducing exposure to high-beta stocks and possibly adding defensive names like PG, KO, or NEE.

### Example 3: Volume Spike
If you see:
- Energy: +3.20% with Volume Ratio 2.5x (highlighted in yellow)
- Summary shows: "STRONG VOLUME DETECTED"

**Interpretation**: The energy sector is making a strong move with significantly higher-than-average volume, suggesting conviction behind the price movement. This could indicate the beginning of a sustained trend in energy stocks. Consider names like XOM, CVX, and COP.

## How to Use the Indicator

1. Apply the indicator to any chart (works best on daily timeframes).
2. Customize settings if needed:
   - Timeframe: Choose between intraday (60 or 240 minutes), daily, or weekly
   - Lookback Period: Adjust the historical comparison period (default: 20)
   - RSI Period: Modify the RSI calculation period (default: 14)

3. To refresh the data: Click the settings icon, increase the "Click + to refresh data" counter, and click "OK".

4. Identify opportunities based on sector performance, RSI levels, volume ratios, and the summary recommendations.

This indicator helps traders align with market rotation trends and identify which sectors (and specific stocks) may outperform or underperform in the near term.

---

## Source Code

````pine

// © yelober - Optimized version to reduce API calls
//@version=6
indicator("Yelober - Sector Rotation Detector", overlay=false)

// User inputs
timeframeInput = input.string("D", "Timeframe", options=["60", "240", "D", "W"])
lookbackPeriod = input.int(20, "Lookback Period", minval=5, maxval=100)
rsiPeriod = input.int(14, "RSI Period", minval=5, maxval=30)
showSummary = input.bool(true, "Show Summary & Recommendations", tooltip="Display summary analysis and stock recommendations")
textSize = input.string("small", "Text Size", options=["tiny", "small", "normal", "large"])
tablePosition = input.string("top_right", "Table Position", options=["top_right", "top_left", "bottom_right", "bottom_left", "middle_right", "middle_left"])
// Add refresh trigger with a counter - this creates a new input each time
refreshCounter = input.int(0, "Click + to refresh data", minval=0)
// Add option to hide refresh instructions
hideRefreshRows = input.bool(false, "Hide refresh instructions")

// Reduce ETFs to stay under request limit - focusing on key sectors plus SPY
var string[] sectorETFs = array.from("XLE", "XLF", "XLK", "XLP", "XLU", "XLY", "SPY")
var string[] sectorNames = array.from("Energy", "Financial", "Technology", "Consumer Staples", "Utilities", "Consumer Disc", "S&P 500")

// Convert text size string to size value
var textSizeValue = size.small
if textSize == "tiny"
    textSizeValue := size.tiny
else if textSize == "small"
    textSizeValue := size.small
else if textSize == "normal"
    textSizeValue := size.normal
else if textSize == "large"
    textSizeValue := size.large

// Top stocks in key sectors
var topEnergyStocks = "XOM, CVX, COP, SLB, EOG"
var topFinancialStocks = "JPM, BAC, WFC, GS, MS"
var topTechStocks = "AAPL, MSFT, NVDA, AVGO, ADBE"
var topStaplesStocks = "PG, KO, PEP, WMT, COST"
var topUtilityStocks = "NEE, SO, DUK, D, AEP"
var topDiscretionaryStocks = "AMZN, TSLA, HD, MCD, NKE"
var topIndexStocks = "QQQ, DIA, IWM, VTI, VOO"

// Track previous refresh counter value to detect changes
var int prevRefreshCounter = 0
var bool forceRefresh = false

// Detect when refresh counter changes
if (refreshCounter != prevRefreshCounter)
    forceRefresh := true
    prevRefreshCounter := refreshCounter

// Add timestamp for last refresh
var int lastRefreshTime = timenow
if (forceRefresh)
    lastRefreshTime := timenow

// Arrays to store calculated metrics
var float[] sectorPerformance = array.new_float(7, 0.0)
var float[] sectorRSI = array.new_float(7, 0.0)
var float[] sectorVolumeRatio = array.new_float(7, 0.0)
var int[] sectorTrend = array.new_int(7, 0) // 1 = uptrend, -1 = downtrend, 0 = neutral

// OPTIMIZATION: Get data for all ETFs in a single function to reduce API calls
getETFsData() =>
    // Process each ETF in reduced set
    for i = 0 to 6
        ticker = array.get(sectorETFs, i)
        
        // Get price and volume data in one call - FIXED: put on one line
        [c, c1, c5, v, avgVol] = request.security(ticker, timeframeInput, [close, close[1], close[5], volume, ta.sma(volume, lookbackPeriod)])
        
        // Get RSI in a separate call (can't be calculated inline with the above)
        rsiVal = request.security(ticker, timeframeInput, ta.rsi(close, rsiPeriod))
        
        // Calculate metrics
        dayPerf = ((c - c1) / c1) * 100
        weekPerf = ((c - c5) / c5) * 100
        volRatio = v / avgVol
        trend = c > c1 ? 1 : c < c1 ? -1 : 0
        
        // Store results
        array.set(sectorPerformance, i, dayPerf)
        array.set(sectorRSI, i, rsiVal)
        array.set(sectorVolumeRatio, i, volRatio)
        array.set(sectorTrend, i, trend)

// Helper function to get stocks for a sector
getTopStocksForSector(sectorIndex) =>
    string result = ""
    if sectorIndex == 0
        result := topEnergyStocks
    else if sectorIndex == 1
        result := topFinancialStocks
    else if sectorIndex == 2
        result := topTechStocks
    else if sectorIndex == 3
        result := topStaplesStocks
    else if sectorIndex == 4
        result := topUtilityStocks
    else if sectorIndex == 5
        result := topDiscretionaryStocks
    else if sectorIndex == 6
        result := topIndexStocks
    result

// Get all ETF data (significantly reduces API calls)
getETFsData()

// Reset refresh flag after processing
forceRefresh := false

// Rotation detection logic
string sectorRotation = ""
bool riskOff = false
bool strongVolume = false

// 1. Find strongest and weakest sectors (excluding SPY at index 6)
int maxPerfSector = -1
float maxPerf = -100.0
int minPerfSector = -1
float minPerf = 100.0

for i = 0 to 5  // Only consider actual sectors, not SPY
    float currPerf = array.get(sectorPerformance, i)
    if currPerf > maxPerf
        maxPerf := currPerf
        maxPerfSector := i
    if currPerf < minPerf
        minPerf := currPerf
        minPerfSector := i

// Also find second strongest and second weakest for more stock recommendations
int secondMaxPerfSector = -1
float secondMaxPerf = -100.0
int secondMinPerfSector = -1
float secondMinPerf = 100.0

for i = 0 to 5  // Only consider actual sectors, not SPY
    float currPerf = array.get(sectorPerformance, i)
    if i != maxPerfSector and currPerf > secondMaxPerf
        secondMaxPerf := currPerf
        secondMaxPerfSector := i
    if i != minPerfSector and currPerf < secondMinPerf
        secondMinPerf := currPerf
        secondMinPerfSector := i

// Rotation detected if significant performance gap
if maxPerf - minPerf > 2.0
    sectorRotation := "Rotation from " + array.get(sectorNames, minPerfSector) + " to " + array.get(sectorNames, maxPerfSector)

// 2. Risk-off detection (staples and utilities up, tech down)
float staplesPerf = array.get(sectorPerformance, 3)  // XLP
float utilitiesPerf = array.get(sectorPerformance, 4)  // XLU
float techPerf = array.get(sectorPerformance, 2)  // XLK

if staplesPerf > 0 and utilitiesPerf > 0 and techPerf < 0
    riskOff := true

// 3. Volume confirmation
for i = 0 to 6
    if array.get(sectorVolumeRatio, i) > 1.5
        strongVolume := true
        break

// Generate stock recommendations
string longRecs = "Consider LONGS: "
string shortRecs = "Consider SHORTS: "

// Add strongest sector stocks to longs
if maxPerfSector >= 0 and maxPerfSector < 6
    string topLongStocks = getTopStocksForSector(maxPerfSector)
    longRecs := longRecs + topLongStocks
    
    // Add some from second strongest sector if available
    if secondMaxPerfSector >= 0 and secondMaxPerfSector < 6
        string moreLongStocks = getTopStocksForSector(secondMaxPerfSector)
        longRecs := longRecs + ", " + moreLongStocks

// Add weakest sector stocks to shorts
if minPerfSector >= 0 and minPerfSector < 6
    string topShortStocks = getTopStocksForSector(minPerfSector)
    shortRecs := shortRecs + topShortStocks
    
    // Add some from second weakest sector if available
    if secondMinPerfSector >= 0 and secondMinPerfSector < 6
        string moreShortStocks = getTopStocksForSector(secondMinPerfSector)
        shortRecs := shortRecs + ", " + moreShortStocks

// Create analysis text
string analysisText = ""
if sectorRotation != ""
    analysisText := "SECTOR ROTATION DETECTED:\n" + sectorRotation + "\n\n"
if riskOff
    analysisText := analysisText + "RISK-OFF MODE DETECTED\n\n"
if strongVolume
    analysisText := analysisText + "STRONG VOLUME DETECTED\n\n"
if analysisText == ""
    analysisText := "No significant sector activity\n\n"

// Add stock recommendations
analysisText := analysisText + longRecs + "\n\n" + shortRecs

// Format time to display
formatTime(time) =>
    timeStr = str.format("{0}:{1}:{2}", str.tostring(hour(time / 1000), "00"), str.tostring(minute(time / 1000), "00"), str.tostring(second(time / 1000), "00"))
    timeStr

// Set table position based on user input
var pos = position.top_right
if tablePosition == "top_left"
    pos := position.top_left
else if tablePosition == "bottom_right"
    pos := position.bottom_right
else if tablePosition == "bottom_left"
    pos := position.bottom_left
else if tablePosition == "middle_right"
    pos := position.middle_right
else if tablePosition == "middle_left"
    pos := position.middle_left

// Determine number of rows based on whether summary is shown and refresh rows
int tableRows = showSummary ? (hideRefreshRows ? 9 : 11) : (hideRefreshRows ? 8 : 10)

// Table to display results
var table rotationTable = table.new(pos, 5, tableRows, color.new(color.blue, 90), color.white, 2, color.gray, 1)

// Update table content
if barstate.islast
    // Clear table before updating
    int clearRows = tableRows - 1
    table.clear(rotationTable, 0, 0, 4, clearRows)
    
    // Headers
    table.cell(rotationTable, 0, 0, "Sector", bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = textSizeValue)
    table.cell(rotationTable, 1, 0, "Perf %", bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = textSizeValue)
    table.cell(rotationTable, 2, 0, "RSI", bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = textSizeValue)
    table.cell(rotationTable, 3, 0, "Vol Ratio", bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = textSizeValue)
    table.cell(rotationTable, 4, 0, "Trend", bgcolor = color.new(color.blue, 70), text_color = color.white, text_size = textSizeValue)
    
    // Sector data
    for i = 0 to 6
        color bgColor = array.get(sectorPerformance, i) > 0 ? color.new(color.green, 90) : color.new(color.red, 90)
        color trendColor = array.get(sectorTrend, i) > 0 ? color.green : array.get(sectorTrend, i) < 0 ? color.red : color.gray
        string trendSymbol = array.get(sectorTrend, i) > 0 ? "▲" : array.get(sectorTrend, i) < 0 ? "▼" : "◆"
        
        // Format performance with plus sign for positive values
        string perfText = ""
        if array.get(sectorPerformance, i) > 0
            perfText := "+" + str.tostring(array.get(sectorPerformance, i), "#.##") + "%"
        else
            perfText := str.tostring(array.get(sectorPerformance, i), "#.##") + "%"
        
        table.cell(rotationTable, 0, i+1, array.get(sectorNames, i), bgcolor = color.new(color.blue, 90), text_size = textSizeValue)
        table.cell(rotationTable, 1, i+1, perfText, bgcolor = bgColor, text_size = textSizeValue)
        table.cell(rotationTable, 2, i+1, str.tostring(math.round(array.get(sectorRSI, i))), bgcolor = array.get(sectorRSI, i) > 70 ? color.new(color.red, 90) : array.get(sectorRSI, i) < 30 ? color.new(color.green, 90) : color.new(color.blue, 90), text_size = textSizeValue)
        table.cell(rotationTable, 3, i+1, str.tostring(array.get(sectorVolumeRatio, i), "#.#x"), bgcolor = array.get(sectorVolumeRatio, i) > 1.5 ? color.new(color.yellow, 90) : color.new(color.blue, 90), text_size = textSizeValue)
        table.cell(rotationTable, 4, i+1, trendSymbol, text_color = trendColor, bgcolor = color.new(color.blue, 90), text_size = textSizeValue)
    
    // Refresh instruction rows - only show if not hidden
    int refreshRow = 8
    if not hideRefreshRows
        // Refresh instruction row
        table.cell(rotationTable, 0, refreshRow, "To refresh:", bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        table.cell(rotationTable, 1, refreshRow, "Click settings →", bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        table.cell(rotationTable, 2, refreshRow, "increase counter", bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        table.cell(rotationTable, 3, refreshRow, "", bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        table.cell(rotationTable, 4, refreshRow, "", bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        
        // Last updated row
        table.cell(rotationTable, 0, refreshRow+1, "Last Updated:", bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        table.cell(rotationTable, 1, refreshRow+1, formatTime(lastRefreshTime), bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        table.cell(rotationTable, 2, refreshRow+1, "Refresh #:", bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        table.cell(rotationTable, 3, refreshRow+1, str.tostring(refreshCounter), bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        table.cell(rotationTable, 4, refreshRow+1, "", bgcolor = color.new(color.gray, 80), text_size = textSizeValue)
        
        // Adjust summary row position if refresh rows are shown
        refreshRow += 2
    
    // Summary row - only displayed if showSummary is true
    if showSummary
        // First create individual cells to ensure they exist
        table.cell(rotationTable, 0, refreshRow, "", bgcolor = color.new(color.navy, 10))
        table.cell(rotationTable, 1, refreshRow, "", bgcolor = color.new(color.navy, 10))
        table.cell(rotationTable, 2, refreshRow, "", bgcolor = color.new(color.navy, 10))
        table.cell(rotationTable, 3, refreshRow, "", bgcolor = color.new(color.navy, 10))
        table.cell(rotationTable, 4, refreshRow, "", bgcolor = color.new(color.navy, 10))
        
        // Now merge them properly
        table.cell(rotationTable, 0, refreshRow, "SUMMARY & RECOMMENDATIONS\n\n" + analysisText, bgcolor = color.new(color.navy, 10), text_color = color.white, text_size = textSizeValue)
        table.merge_cells(rotationTable, 0, refreshRow, 4, refreshRow)

// Plot placeholder
plot(0, color=color.new(color.blue, 100), title="Yelober - Sector Rotation Detector")
````
