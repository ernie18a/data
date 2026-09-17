<!-- tradingview-pine-id: PUB;882f4ddaee9e4427ad6d8f2549a8ef1d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# STOC - Moving Average Trend & Signals

Source: https://www.tradingview.com/script/xeKjJ6gK-STOC-Moving-Average-Trend-Signals/

## Description

STOC – Moving Average Trend & Signals is a trend-following indicator designed to simplify moving-average analysis using four widely followed averages:

• 10 EMA – Short-term momentum
• 20 EMA – Short/intermediate trend
• 50 SMA – Intermediate trend
• 200 SMA – Long-term market structure

The indicator combines price position, moving-average direction and MA alignment to identify potential entries, exits and broader trend conditions.

SIGNAL MODES

1. MA Stack
   A Buy signal occurs when the averages newly align in bullish order:

10 EMA > 20 EMA > 50 SMA > 200 SMA

The standard exit occurs when this bullish alignment breaks.

2. Price vs MA
   A Buy signal occurs when price crosses above the selected signal MA. The standard exit occurs when price crosses below it.

The selectable signal averages are:

• 10 EMA
• 20 EMA
• 50 SMA
• 200 SMA

3. Fast/Slow Crossover
   A Buy signal occurs when the 10 EMA crosses above the 20 EMA. The standard exit occurs when the 10 EMA crosses below the 20 EMA.

EXIT METHODS

1. MA Signal Exit
   Uses the corresponding exit condition of the selected signal mode.

2. ATR Trailing Exit
   Replaces the standard MA exit with a volatility-adjusted trailing stop. The ATR stop follows the highest price reached after entry and never moves downward during an active trade.

   The ATR exit is confirmed only when a candle closes below the trailing stop. Intrabar touches do not trigger an exit.

OPTIONAL FILTERS

• Moving-average slope confirmation
• Volume confirmation
• Minimum separation between the 10 EMA and 200 SMA
• Bar-close signal confirmation
• Flat or choppy market filter

DASHBOARD

The high-contrast dashboard is designed to remain visible on both light and dark chart themes. It displays:

• Current market trend
• Moving-average alignment
• Selected signal MA
• Price position
• MA direction
• Active exit method
• Current ATR stop
• Volume-filter status
• Current trade status

VISUAL FEATURES

• Individually configurable moving-average plots
• Buy and Exit labels
• Bullish and bearish trend backgrounds
• Optional ATR trailing-stop line
• Adjustable dashboard position and size

ALERTS

Alert conditions are included for:

• Buy signals
• All exit signals
• MA-based exits
• ATR trailing exits
• Beginning of a strong uptrend
• Beginning of a strong downtrend

For more reliable live alerts, keep “Confirm Signals on Bar Close” enabled and select “Once Per Bar Close” when creating the TradingView alert.

SUGGESTED USE

The indicator can be used across stocks, indices, futures, forex and cryptocurrencies. Higher timeframes such as 4-hour, daily and weekly charts generally provide cleaner trend signals, while lower timeframes may generate more frequent signals and market noise.

This indicator is a trend-following decision-support tool. It does not predict future prices or guarantee profitable trades. Signals should be combined with appropriate position sizing, risk management, support and resistance analysis, and independent market evaluation.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BoobeshDasarath93

//@version=6
indicator("STOC - Moving Average Trend & Signals", overlay=true, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// 01. Moving Averages
//──────────────────────────────────────────────────────────────────────────────

string groupMA = "01. Moving Averages"
bool showEMA10 = input.bool(true, "Show 10 EMA", group=groupMA)
bool showEMA20 = input.bool(true, "Show 20 EMA", group=groupMA)
bool showSMA50 = input.bool(true, "Show 50 SMA", group=groupMA)
bool showSMA200 = input.bool(true, "Show 200 SMA", group=groupMA)
int ema10Length = input.int(10, "Fast EMA Length", minval=1, group=groupMA)
int ema20Length = input.int(20, "Intermediate EMA Length", minval=1, group=groupMA)
int sma50Length = input.int(50, "Intermediate SMA Length", minval=1, group=groupMA)
int sma200Length = input.int(200, "Long-Term SMA Length", minval=1, group=groupMA)

//──────────────────────────────────────────────────────────────────────────────
// 02. Entry Settings
//──────────────────────────────────────────────────────────────────────────────

string groupSignals = "02. Entry Settings"
string signalMode = input.string("MA Stack", "Entry Signal Mode", options=["MA Stack", "Price vs MA", "Fast/Slow Crossover"], group=groupSignals)
string signalMAChoice = input.string("20 EMA", "Price Signal MA", options=["10 EMA", "20 EMA", "50 SMA", "200 SMA"], group=groupSignals)
bool requireMASlope = input.bool(true, "Require MA Direction", tooltip="Price vs MA entries require the selected MA to be rising. Fast/Slow entries require the slow EMA to be rising.", group=groupSignals)
bool confirmOnClose = input.bool(true, "Confirm Signals on Bar Close", tooltip="Recommended for published alerts and automation.", group=groupSignals)

//──────────────────────────────────────────────────────────────────────────────
// 03. Exit Settings
//──────────────────────────────────────────────────────────────────────────────

string groupExit = "03. Exit Settings"
string exitMode = input.string("MA Signal Exit", "Exit Method", options=["MA Signal Exit", "ATR Trailing Exit"], group=groupExit)
int atrLength = input.int(14, "ATR Length", minval=1, group=groupExit)
float atrMultiplier = input.float(2.0, "ATR Multiplier", minval=0.1, step=0.1, group=groupExit)
bool showATRStop = input.bool(true, "Show ATR Trailing Stop", tooltip="Displayed only when ATR Trailing Exit is selected and a trade is active.", group=groupExit)

//──────────────────────────────────────────────────────────────────────────────
// 04. Trade Filters
//──────────────────────────────────────────────────────────────────────────────

string groupFilters = "04. Trade Filters"
bool useVolumeFilter = input.bool(false, "Use Volume Confirmation", group=groupFilters)
int volumeLength = input.int(20, "Volume Average Length", minval=1, group=groupFilters)
float volumeMultiplier = input.float(1.0, "Minimum Volume Multiplier", minval=0.1, step=0.1, group=groupFilters)
bool avoidChoppyMarket = input.bool(false, "Avoid Flat/Choppy MAs", group=groupFilters)
int slopeLookback = input.int(5, "MA Slope Lookback", minval=1, group=groupFilters)
float minimumSeparation = input.float(0.20, "Minimum 10 EMA to 200 SMA Separation %", minval=0.0, step=0.05, group=groupFilters)

//──────────────────────────────────────────────────────────────────────────────
// 05. Display
//──────────────────────────────────────────────────────────────────────────────

string groupDisplay = "05. Display"
bool showSignalLabels = input.bool(true, "Show Buy/Exit Labels", group=groupDisplay)
bool showTrendBackground = input.bool(true, "Show Trend Background", group=groupDisplay)
bool showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
string dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=groupDisplay)
string dashboardSize = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal", "Large"], group=groupDisplay)

//──────────────────────────────────────────────────────────────────────────────
// Moving Average Calculations
//──────────────────────────────────────────────────────────────────────────────

float ema10 = ta.ema(close, ema10Length)
float ema20 = ta.ema(close, ema20Length)
float sma50 = ta.sma(close, sma50Length)
float sma200 = ta.sma(close, sma200Length)
float signalMA = signalMAChoice == "10 EMA" ? ema10 : signalMAChoice == "20 EMA" ? ema20 : signalMAChoice == "50 SMA" ? sma50 : sma200

bool signalMARising = signalMA > signalMA[slopeLookback]
bool signalMAFalling = signalMA < signalMA[slopeLookback]
bool ema20Rising = ema20 > ema20[slopeLookback]

//──────────────────────────────────────────────────────────────────────────────
// Trend Conditions
//──────────────────────────────────────────────────────────────────────────────

bool strongUptrend = ema10 > ema20 and ema20 > sma50 and sma50 > sma200
bool strongDowntrend = ema10 < ema20 and ema20 < sma50 and sma50 < sma200
bool bullishTrend = close > signalMA and signalMARising
bool bearishTrend = close < signalMA and signalMAFalling

//──────────────────────────────────────────────────────────────────────────────
// Filters
//──────────────────────────────────────────────────────────────────────────────

float totalSeparation = close != 0.0 ? math.abs(ema10 - sma200) / close * 100.0 : 0.0
bool separationPassed = not avoidChoppyMarket or totalSeparation >= minimumSeparation

float averageVolume = ta.sma(volume, volumeLength)
bool volumeAvailable = not na(volume) and not na(averageVolume)
bool volumePassed = not useVolumeFilter or not volumeAvailable or volume >= averageVolume * volumeMultiplier
bool barConfirmed = not confirmOnClose or barstate.isconfirmed

//──────────────────────────────────────────────────────────────────────────────
// Entry Conditions
//──────────────────────────────────────────────────────────────────────────────

bool stackBuyCondition = strongUptrend and not strongUptrend[1]
bool priceBuyCondition = ta.crossover(close, signalMA) and (not requireMASlope or signalMARising)
bool crossoverBuyCondition = ta.crossover(ema10, ema20) and (not requireMASlope or ema20Rising)
bool rawBuyCondition = signalMode == "MA Stack" ? stackBuyCondition : signalMode == "Price vs MA" ? priceBuyCondition : crossoverBuyCondition

//──────────────────────────────────────────────────────────────────────────────
// Regular MA Exit Conditions
//──────────────────────────────────────────────────────────────────────────────

bool stackExitCondition = not strongUptrend and strongUptrend[1]
bool priceExitCondition = ta.crossunder(close, signalMA)
bool crossoverExitCondition = ta.crossunder(ema10, ema20)
bool rawMAExitCondition = signalMode == "MA Stack" ? stackExitCondition : signalMode == "Price vs MA" ? priceExitCondition : crossoverExitCondition

//──────────────────────────────────────────────────────────────────────────────
// Trade State and ATR Trailing Stop
//──────────────────────────────────────────────────────────────────────────────

float atrValue = ta.atr(atrLength)

var bool inTrade = false
var float entryPrice = na
var float highestSinceEntry = na
var float atrTrailingStop = na
var string lastEvent = "WAIT"

bool buySignal = false
bool exitSignal = false
bool atrExitTriggered = false
bool maExitTriggered = false

bool entryReady = rawBuyCondition and volumePassed and separationPassed and barConfirmed and not inTrade

if entryReady
    inTrade := true
    entryPrice := close
    highestSinceEntry := high
    atrTrailingStop := high - atrValue * atrMultiplier
    buySignal := true
    lastEvent := "BUY"
else if inTrade
    highestSinceEntry := math.max(nz(highestSinceEntry, high), high)
    float proposedATRStop = highestSinceEntry - atrValue * atrMultiplier
    atrTrailingStop := na(atrTrailingStop) ? proposedATRStop : math.max(atrTrailingStop, proposedATRStop)
    atrExitTriggered := exitMode == "ATR Trailing Exit" and not na(atrTrailingStop) and close < atrTrailingStop and barConfirmed
    maExitTriggered := exitMode == "MA Signal Exit" and rawMAExitCondition and barConfirmed
    exitSignal := atrExitTriggered or maExitTriggered
    if exitSignal
        inTrade := false
        entryPrice := na
        highestSinceEntry := na
        atrTrailingStop := na
        lastEvent := atrExitTriggered ? "ATR EXIT" : "MA EXIT"

//──────────────────────────────────────────────────────────────────────────────
// Plots
//──────────────────────────────────────────────────────────────────────────────

plot(showEMA10 ? ema10 : na, "10 EMA", color=color.aqua, linewidth=2)
plot(showEMA20 ? ema20 : na, "20 EMA", color=color.orange, linewidth=2)
plot(showSMA50 ? sma50 : na, "50 SMA", color=color.blue, linewidth=2)
plot(showSMA200 ? sma200 : na, "200 SMA", color=color.purple, linewidth=3)

float displayedATRStop = exitMode == "ATR Trailing Exit" and showATRStop and inTrade ? atrTrailingStop : na
plot(displayedATRStop, "ATR Trailing Stop", color=color.red, linewidth=2, style=plot.style_linebr)

plotshape(showSignalLabels and buySignal, title="Buy Signal", text="BUY", style=shape.labelup, location=location.belowbar, color=color.rgb(0, 130, 70), textcolor=color.white, size=size.small)
plotshape(showSignalLabels and exitSignal, title="Exit Signal", text="EXIT", style=shape.labeldown, location=location.abovebar, color=color.rgb(190, 35, 35), textcolor=color.white, size=size.small)

color trendBackground = strongUptrend ? color.new(color.green, 89) : strongDowntrend ? color.new(color.red, 89) : na
bgcolor(showTrendBackground ? trendBackground : na)

//──────────────────────────────────────────────────────────────────────────────
// Dashboard Settings
//──────────────────────────────────────────────────────────────────────────────

tablePosition = dashboardPosition == "Top Left" ? position.top_left : dashboardPosition == "Top Right" ? position.top_right : dashboardPosition == "Bottom Left" ? position.bottom_left : position.bottom_right
tableTextSize = dashboardSize == "Tiny" ? size.tiny : dashboardSize == "Small" ? size.small : dashboardSize == "Normal" ? size.normal : size.large

color headerBackground = color.rgb(18, 22, 30)
color labelBackground = color.rgb(42, 47, 57)
color neutralBackground = color.rgb(65, 70, 80)
color bullishBackground = color.rgb(0, 105, 65)
color bearishBackground = color.rgb(155, 35, 35)
color warningBackground = color.rgb(145, 95, 0)
color dashboardText = color.white
color borderColor = color.rgb(130, 135, 145)

var table dashboard = table.new(tablePosition, 2, 10, border_width=1, border_color=borderColor, frame_width=1, frame_color=borderColor)

//──────────────────────────────────────────────────────────────────────────────
// Dashboard Values
//──────────────────────────────────────────────────────────────────────────────

string marketTrend = strongUptrend ? "STRONG UPTREND" : strongDowntrend ? "STRONG DOWNTREND" : bullishTrend ? "BULLISH" : bearishTrend ? "BEARISH" : "NEUTRAL"
color marketTrendBackground = strongUptrend or bullishTrend ? bullishBackground : strongDowntrend or bearishTrend ? bearishBackground : neutralBackground

string stackStatus = strongUptrend ? "10 > 20 > 50 > 200" : strongDowntrend ? "10 < 20 < 50 < 200" : "MIXED"
color stackBackground = strongUptrend ? bullishBackground : strongDowntrend ? bearishBackground : warningBackground

string pricePosition = close > signalMA ? "ABOVE" : close < signalMA ? "BELOW" : "AT MA"
color pricePositionBackground = close > signalMA ? bullishBackground : close < signalMA ? bearishBackground : warningBackground

string maDirection = signalMARising ? "RISING" : signalMAFalling ? "FALLING" : "FLAT"
color maDirectionBackground = signalMARising ? bullishBackground : signalMAFalling ? bearishBackground : warningBackground

string tradeStatus = inTrade ? "LONG / HOLD" : exitSignal ? "EXIT" : "WAIT"
color tradeStatusBackground = inTrade ? bullishBackground : exitSignal ? bearishBackground : neutralBackground

string atrStopText = exitMode == "ATR Trailing Exit" ? inTrade and not na(atrTrailingStop) ? str.tostring(atrTrailingStop, format.mintick) : "WAITING" : "DISABLED"
string volumeStatus = useVolumeFilter ? volumePassed ? "PASSED" : "FAILED" : "DISABLED"
color volumeBackground = not useVolumeFilter ? neutralBackground : volumePassed ? bullishBackground : bearishBackground

//──────────────────────────────────────────────────────────────────────────────
// Dashboard
//──────────────────────────────────────────────────────────────────────────────

if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "STOC MA ANALYZER", bgcolor=headerBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 0, signalMode, bgcolor=headerBackground, text_color=color.aqua, text_size=tableTextSize)
        table.cell(dashboard, 0, 1, "Market Trend", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 1, marketTrend, bgcolor=marketTrendBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 0, 2, "MA Stack", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 2, stackStatus, bgcolor=stackBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 0, 3, "Signal MA", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 3, signalMAChoice, bgcolor=neutralBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 0, 4, "Price Position", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 4, pricePosition, bgcolor=pricePositionBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 0, 5, "MA Direction", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 5, maDirection, bgcolor=maDirectionBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 0, 6, "Exit Method", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 6, exitMode, bgcolor=neutralBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 0, 7, "ATR Stop", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 7, atrStopText, bgcolor=exitMode == "ATR Trailing Exit" and inTrade ? bearishBackground : neutralBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 0, 8, "Volume Filter", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 8, volumeStatus, bgcolor=volumeBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 0, 9, "Trade Status", bgcolor=labelBackground, text_color=dashboardText, text_size=tableTextSize)
        table.cell(dashboard, 1, 9, tradeStatus, bgcolor=tradeStatusBackground, text_color=dashboardText, text_size=tableTextSize)
    else
        table.clear(dashboard, 0, 0, 1, 9)

//──────────────────────────────────────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────────────────────────────────────

alertcondition(buySignal, "STOC MA Buy", "STOC Moving Average BUY on {{ticker}} at {{close}}")
alertcondition(exitSignal, "STOC MA Exit", "STOC Moving Average EXIT on {{ticker}} at {{close}}")
alertcondition(maExitTriggered, "STOC MA Signal Exit", "STOC Moving Average signal EXIT on {{ticker}} at {{close}}")
alertcondition(atrExitTriggered, "STOC ATR Exit", "STOC ATR trailing EXIT on {{ticker}} at {{close}}")
alertcondition(strongUptrend and not strongUptrend[1], "Strong Uptrend Started", "Strong moving-average uptrend started on {{ticker}}")
alertcondition(strongDowntrend and not strongDowntrend[1], "Strong Downtrend Started", "Strong moving-average downtrend started on {{ticker}}")
````
