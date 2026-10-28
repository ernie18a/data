# Cumulative Volume Delta Signals & MA by r4ys

- url: https://www.tradingview.com/script/kTEuS0hm/
- type: indicator
- pine_id: PUB;7bd2ce79ec714450bc1c5075f43dfb9e
- version: 1.0

## Description

Cumulative Volume Delta Signals & MA by r4ys by cvd signal

## Source Code

````pine
//@version=6
indicator("Cumulative Volume Delta Signals & MA", "CVD Signals", overlay=true)


// Data collection settings
dataGroup = "Data Collection"
anchorInput = input.timeframe("", "Anchor period", tooltip="Timeframe for CVD reset. Empty = chart timeframe (recommended for smooth per-bar delta)", group=dataGroup)
maxBarsInput = input.int(1000, "Max Candlesticks to Process", minval=10, maxval=5000, tooltip="Limits calculation to this many recent bars to look back. Helps chart loading speeds.", group=dataGroup)


lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe.\n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(false, "Use custom timeframe", tooltip = lowerTimeframeTooltip, group=dataGroup)
lowerTimeframeInput = input.timeframe("1", "Custom timeframe", tooltip="Specify which lower timeframe to use for CVD calculation when 'Use custom timeframe' is enabled", group=dataGroup)


lowerTFModeInput = input.string("1s", "Lower TF for 5m and below", options=["Off", "1s", "Tick"], tooltip="Automatically uses finer data for charts 5 minutes and below.\n• Off: Use 1-minute data\n• 1s: Use 1-second data (Premium+)\n• Tick: Use tick data (Expert+ or Ultimate)", group=dataGroup)


showInfoInput = input.bool(true, "Show timeframe info", tooltip="Display lower timeframe and data availability status", group=dataGroup)


// Moving Average settings
maGroup = "Moving Average"
maLengthInput = input.int(14, minval=1, title="MA Length", tooltip="Set the length of the Moving Average", group=maGroup)
maTypeInput = input.string("SMA", "MA Type", options=["SMA", "EMA", "WMA", "RMA", "HMA", "DEMA", "TEMA", "ZLEMA", "LSMA", "SMMA", "ALMA", "SWMA"], tooltip="Type of Moving Average to calculate:\n• SMA: Simple Moving Average\n• EMA: Exponential Moving Average\n• WMA: Weighted Moving Average\n• RMA: Rolling Moving Average (Wilder's)\n• HMA: Hull Moving Average\n• DEMA: Double Exponential Moving Average\n• TEMA: Triple Exponential Moving Average\n• ZLEMA: Zero Lag Exponential Moving Average\n• LSMA: Least Squares Moving Average\n• SMMA: Smoothed Moving Average\n• ALMA: Arnaud Legoux Moving Average\n• SWMA: Symmetrically Weighted Moving Average", group=maGroup)


maThresholdDisplay = input.string("All", "Use MA from timeframe", options=["Off", "All", "1H", "4H", "1D", "1W"], tooltip="Use MA instead of raw CVD from this timeframe and above.\n• Off: Always show raw CVD\n• All: Always show MA (all timeframes)\n• 1H: 1 hour and above\n• 4H: 4 hours and above\n• 1D: Daily and above\n• 1W: Weekly and above", group=maGroup)


maThresholdInput = switch maThresholdDisplay
    "All" => "1"
    "1H" => "60"
    "4H" => "240"
    => maThresholdDisplay


// Threshold settings - Color threshold
colorThresholdGroup = "Color Threshold (Line Coloring)"
thresholdPercentInput = input.float(150.0, "Threshold %", minval=100.0, maxval=500.0, step=10.0, tooltip="Delta must be this % of recent average to trigger color in Threshold mode. Example: 150 means 1.5x the average", group=colorThresholdGroup)
thresholdLookbackInput = input.int(20, "Lookback Bars", minval=5, maxval=200, tooltip="Number of bars to calculate average delta from", group=colorThresholdGroup)


// Signals settings
signalsGroup = "Signal Settings"
showSignalsInput = input.bool(true, "Show Buy/Sell Labels", tooltip="Display locked labels on your chart", group=signalsGroup)
showSignalStatsInput = input.bool(true, "Show Signal Counters", tooltip="Display a widget tracking total count of BUY and SELL signals generated", group=signalsGroup)
tablePosInput = input.string("Top Right", "Stats Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], tooltip="Choose where you want the signal count dashboard to reside on the screen", group=signalsGroup)
showDivergenceBackgroundInput = input.bool(true, "Show Signal Background", tooltip="Highlight bars where extreme delta signal triggers", group=signalsGroup)
showExtremeCandlesInput = input.bool(true, "Show Extreme Candles", tooltip="Color price candles when delta exceeds extreme threshold", group=signalsGroup)
extremeThresholdInput = input.float(250.0, "Extreme Threshold %", minval=150.0, maxval=1000.0, step=10.0, group=signalsGroup)


// Convert string choice to positions type
tablePosition = switch tablePosInput
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right


// Bar processing constraint checker
bool withinProcessingRange = (last_bar_index - bar_index) <= maxBarsInput


upAndDownVolume() =>
    posVol = 0.0
    negVol = 0.0
    var isBuyVolume = true    


    switch
        close > open     => isBuyVolume := true
        close < open     => isBuyVolume := false
        close > close[1] => isBuyVolume := true
        close < close[1] => isBuyVolume := false


    if isBuyVolume
        posVol += volume
    else
        negVol -= volume


    posVol + negVol


// Determine lower timeframe
var lowerTimeframe = ""
if useCustomTimeframeInput
    lowerTimeframe := lowerTimeframeInput
else
    if timeframe.isseconds
        lowerTimeframe := "1S"
    else if timeframe.isintraday
        tf_minutes = timeframe.in_seconds(timeframe.period) / 60
        if tf_minutes <= 5 and lowerTFModeInput != "Off"
            lowerTimeframe := lowerTFModeInput == "Tick" ? "" : "1S"
        else
            lowerTimeframe := "1"
    else if timeframe.isdaily
        lowerTimeframe := "5"
    else
        lowerTimeframe := "60"


diffVolArray = withinProcessingRange ? request.security_lower_tf(syminfo.tickerid, lowerTimeframe, upAndDownVolume()) : na
bool hasLowerTFData = not na(diffVolArray)


getHighLow(arr) =>
    float cumVolume = na
    float maxVolume = na
    float minVolume = na
    if not na(arr)
        for item in arr
            cumVolume := nz(cumVolume) + item
            maxVolume := math.max(nz(maxVolume), cumVolume)
            minVolume := math.min(nz(minVolume), cumVolume)
    [maxVolume, minVolume, cumVolume]


[maxVolume, minVolume, lastVolume] = getHighLow(diffVolArray)


var cumulLastVolume = 0.0


bool isAnchorActive = anchorInput != ""
bool timeHasChanged = not na(ta.change(time(anchorInput)))
bool anchorChanged = isAnchorActive and timeHasChanged


anchorChange = anchorChanged or (not na(lastVolume) and na(lastVolume[1]))
cumulOpenVolume = anchorChange ? 0.0 : cumulLastVolume[1]
cumulLastVolume := cumulOpenVolume + nz(lastVolume)


// Calculate average absolute delta
float avgAbsDelta = ta.sma(math.abs(nz(lastVolume)), thresholdLookbackInput)
float currentAbsDelta = math.abs(nz(lastVolume))
bool isAboveThreshold = withinProcessingRange and currentAbsDelta > (avgAbsDelta * thresholdPercentInput / 100.0)
bool isExtreme = withinProcessingRange and currentAbsDelta > (avgAbsDelta * extremeThresholdInput / 100.0)


// Constants for Colors
color COLOR_BUY = #00C853
color COLOR_SELL = #FF1744


// --- Core Signal Rules ---
bool buySignal = isAboveThreshold and nz(lastVolume) >= 0
bool sellSignal = isAboveThreshold and nz(lastVolume) < 0


// Track Counter Statistics
var int totalBuys = 0
var int totalSells = 0


if buySignal
    totalBuys += 1
if sellSignal
    totalSells += 1


// --- Fixed Label Signal Engine ---
if showSignalsInput
    if buySignal
        label.new(x=bar_index, y=low, text="BUY", color=COLOR_BUY, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar, size=size.small)
    if sellSignal
        label.new(x=bar_index, y=high, text="SELL", color=COLOR_SELL, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar, size=size.small)


// Background color highlights
bgcolor(showDivergenceBackgroundInput and buySignal ? color.new(COLOR_BUY, 92) : na, title="Buy Signal Background")
bgcolor(showDivergenceBackgroundInput and sellSignal ? color.new(COLOR_SELL, 92) : na, title="Sell Signal Background")


// Candle highlight coloring for extreme moves
bool showBuyCandle = showExtremeCandlesInput and isExtreme and nz(lastVolume) >= 0
bool showSellCandle = showExtremeCandlesInput and isExtreme and nz(lastVolume) < 0
barcolor(showBuyCandle ? color.new(COLOR_BUY, 30) : na, title="Extreme Buy Candle")
barcolor(showSellCandle ? color.new(COLOR_SELL, 30) : na, title="Extreme Sell Candle")


// Alert configuration triggers
if buySignal
    alert("CVD Buy Signal triggered on " + syminfo.ticker, alert.freq_once_per_bar_close)
if sellSignal
    alert("CVD Sell Signal triggered on " + syminfo.ticker, alert.freq_once_per_bar_close)


// Statistics Table UI rendering
var table statsTable = na
if showSignalStatsInput and barstate.islast
    statsTable := table.new(tablePosition, 2, 2, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)
    table.cell(statsTable, 0, 0, "Total BUY Signals:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 0, str.tostring(totalBuys), text_color=COLOR_BUY, text_size=size.small, bgcolor=color.new(COLOR_BUY, 85))
    table.cell(statsTable, 0, 1, "Total SELL Signals:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(statsTable, 1, 1, str.tostring(totalSells), text_color=COLOR_SELL, text_size=size.small, bgcolor=color.new(COLOR_SELL, 85))


// Information table UI rendering
var table infoTable = na
bool isUsingFineTF = (lowerTimeframe == "1S" or lowerTimeframe == "") and not useCustomTimeframeInput and lowerTFModeInput != "Off"
bool hasDataIssue = isUsingFineTF and not hasLowerTFData


if showInfoInput
    if na(infoTable)
        infoTable := table.new(position.bottom_right, 2, 3, bgcolor=color.new(#2962FF, 0), border_width=2, border_color=color.white)
    if barstate.islast
        string tfDisplay = lowerTimeframe == "" ? "Tick" : lowerTimeframe
        if hasDataIssue
            string tfType = lowerTimeframe == "" ? "tick" : "1-second"
            string requiredPlan = lowerTimeframe == "" ? "Expert+ or Ultimate" : "Premium+"
            table.cell(infoTable, 0, 0, "⚠ WARNING", text_color=color.white, bgcolor=color.red)
            table.cell(infoTable, 1, 0, "", bgcolor=color.red)
            table.cell(infoTable, 0, 1, tfType + " data unavailable", text_color=color.white, text_size=size.small)
            table.cell(infoTable, 1, 1, "Requires " + requiredPlan, text_color=#FFD700, text_size=size.small)
        else
            table.cell(infoTable, 0, 0, "Lower TF:", text_color=color.white, text_size=size.small)
            table.cell(infoTable, 1, 0, tfDisplay, text_color=color.white, text_size=size.small)
````
