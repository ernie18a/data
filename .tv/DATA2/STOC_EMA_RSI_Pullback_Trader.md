<!-- tradingview-pine-id: PUB;7b3ddfa5b52f4ce1894e6efef703bdb2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# STOC - EMA + RSI Pullback Trader

Source: https://www.tradingview.com/script/8kqNol83-STOC-EMA-RSI-Pullback-Trader/

## Description

The STOC – EMA RSI Pullback Trader is a long-only trend-following indicator designed to identify potential entries during bullish trends and controlled pullbacks.

Instead of chasing price after a large upward move, the indicator looks for opportunities when price returns toward the faster trend average while the broader trend remains positive.

How it works

The indicator combines:

* 20 EMA for identifying short-term momentum and pullback areas.
* 50 EMA for determining the broader trend.
* RSI for confirming that momentum remains bullish.

An initial Buy signal can appear when the 20 EMA crosses above the 50 EMA and RSI confirms positive momentum.

After the bullish trend is established, a Pullback Buy signal can appear when price revisits the 20 EMA and subsequently confirms strength above it while RSI remains above the selected bullish threshold.

Exit methods

The indicator provides three selectable exit methods:

* 20 EMA crossing below the 50 EMA.
* Price closing below the 50 EMA.
* Either condition, whichever occurs first.

The “Either Condition” setting offers more defensive trade management, while the EMA crossover exit generally gives the trend more room to develop.

Key features

* Initial EMA crossover entries.
* Trend-continuation pullback entries.
* RSI momentum confirmation.
* Adjustable EMA and RSI settings.
* Optional requirement for rising RSI.
* Multiple pullback-confirmation methods.
* Selectable exit logic.
* Buy, Pullback Buy and Exit labels.
* Active-trade background highlighting.
* Trend and trade-status dashboard.
* TradingView alert conditions.
* Dynamic JSON messages for webhook integration.
* Works across equities, indices, futures, forex and cryptocurrencies.

How to use

The indicator is best used on instruments displaying a clear directional trend.

A valid bullish environment generally exists when:

* The 20 EMA is above the 50 EMA.
* Price is trading above the 50 EMA.
* RSI is above 50.

The initial Buy signal identifies a possible new bullish trend. Pullback Buy signals identify potential re-entry opportunities after price returns toward the 20 EMA without invalidating the broader trend.

Avoid treating every signal as an automatic trade. Consider confirming the setup using:

* Higher-timeframe trend direction.
* Support and resistance.
* Breakout structure.
* Volume expansion.
* Relative strength.
* Overall market and sector conditions.

Suggested timeframes

* Daily and weekly charts: positional and swing trading.
* 1-hour and 4-hour charts: shorter-term swing trading.
* 5-minute and 15-minute charts: intraday trading with additional market and volume confirmation.

Alerts

Create a TradingView alert using “Any alert() function call” to receive the indicator’s dynamic Buy and Exit messages. Standard Buy and Exit alert conditions are also available.

Disclaimer

This indicator is provided solely for educational and informational purposes. It does not constitute investment advice, financial advice, trading advice or a recommendation to buy or sell any security or financial instrument.

Trading and investing involve substantial risk, including the possible loss of capital. Historical signals and past performance do not guarantee future results. Always perform your own analysis, apply appropriate position sizing and risk management, and consult a qualified financial professional when necessary.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © BoobeshDasarath93

//@version=6
indicator("STOC - EMA + RSI Pullback Trader", overlay=true, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// 01. EMA Settings
//──────────────────────────────────────────────────────────────────────────────

string groupEMA = "01. EMA Settings"

int fastLength = input.int(20, "Pullback EMA Length", minval=1, group=groupEMA)
int slowLength = input.int(50, "Trend EMA Length", minval=2, group=groupEMA)

bool showFastEMA = input.bool(true, "Show Pullback EMA", group=groupEMA)
bool showSlowEMA = input.bool(true, "Show Trend EMA", group=groupEMA)

//──────────────────────────────────────────────────────────────────────────────
// 02. RSI Settings
//──────────────────────────────────────────────────────────────────────────────

string groupRSI = "02. RSI Settings"

int rsiLength = input.int(14, "RSI Length", minval=2, group=groupRSI)
float rsiThreshold = input.float(50.0, "Bullish RSI Threshold", minval=0.0, maxval=100.0, step=0.5, group=groupRSI)

//──────────────────────────────────────────────────────────────────────────────
// 03. Entry Settings
//──────────────────────────────────────────────────────────────────────────────

string groupEntry = "03. Entry Settings"

bool enableInitialCrossover = input.bool(true, "Enable Initial EMA Crossover Buy", group=groupEntry)
bool enablePullbackEntry = input.bool(true, "Enable Pullback Buy", group=groupEntry)

string pullbackConfirmation = input.string("Bullish Close Above EMA", "Pullback Confirmation", options=["Close Above EMA", "Bullish Close Above EMA", "High Breaks Previous High"], group=groupEntry)

int touchToleranceTicks = input.int(0, "EMA Touch Tolerance in Ticks", minval=0, group=groupEntry)
int pullbackLookback = input.int(3, "Pullback Touch Lookback", minval=1, maxval=20, group=groupEntry)

bool requireRsiRising = input.bool(false, "Require RSI to Be Rising", group=groupEntry)

//──────────────────────────────────────────────────────────────────────────────
// 04. Exit Settings
//──────────────────────────────────────────────────────────────────────────────

string groupExit = "04. Exit Settings"

string exitMode = input.string("Either Condition", "Exit Method", options=["20 EMA Below 50 EMA", "Price Below 50 EMA", "Either Condition"], group=groupExit)
bool exitOnCloseOnly = input.bool(true, "Confirm Price Exit at Candle Close", group=groupExit)

//──────────────────────────────────────────────────────────────────────────────
// 05. Display Settings
//──────────────────────────────────────────────────────────────────────────────

string groupDisplay = "05. Display Settings"

bool showSignals = input.bool(true, "Show Buy and Exit Labels", group=groupDisplay)
bool showTradeBackground = input.bool(true, "Show Active Trade Background", group=groupDisplay)
int backgroundOpacity = input.int(90, "Background Opacity", minval=0, maxval=100, group=groupDisplay)

bool showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)
string dashboardPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDisplay)

//──────────────────────────────────────────────────────────────────────────────
// 06. Alert Settings
//──────────────────────────────────────────────────────────────────────────────

string groupAlerts = "06. Alert Settings"

bool enableAppAlerts = input.bool(true, "Enable alert() Notifications", group=groupAlerts)
string webhookName = input.string("STOC_EMA_RSI_PULLBACK", "Webhook Strategy Name", group=groupAlerts)

//──────────────────────────────────────────────────────────────────────────────
// Calculations
//──────────────────────────────────────────────────────────────────────────────

float fastEMA = ta.ema(close, fastLength)
float slowEMA = ta.ema(close, slowLength)
float rsiValue = ta.rsi(close, rsiLength)

float touchTolerance = syminfo.mintick * touchToleranceTicks

bool bullishTrend = fastEMA > slowEMA
bool bearishTrend = fastEMA < slowEMA

bool rsiBullish = rsiValue > rsiThreshold
bool rsiRising = rsiValue > rsiValue[1]
bool rsiFilter = rsiBullish and (not requireRsiRising or rsiRising)

//──────────────────────────────────────────────────────────────────────────────
// Initial Crossover Entry
//──────────────────────────────────────────────────────────────────────────────

bool bullishCrossover = ta.crossover(fastEMA, slowEMA)
bool initialEntrySetup = enableInitialCrossover and bullishCrossover and rsiFilter

//──────────────────────────────────────────────────────────────────────────────
// Pullback Detection
//──────────────────────────────────────────────────────────────────────────────

bool touchedFastEMA = low <= fastEMA + touchTolerance and high >= fastEMA - touchTolerance
bool recentFastEMATouch = ta.barssince(touchedFastEMA) <= pullbackLookback - 1

bool closeAboveConfirmation = close > fastEMA
bool bullishCloseConfirmation = close > open and close > fastEMA
bool previousHighConfirmation = close > high[1] and close > fastEMA

bool pullbackConfirmed = switch pullbackConfirmation
    "Close Above EMA" => closeAboveConfirmation
    "Bullish Close Above EMA" => bullishCloseConfirmation
    "High Breaks Previous High" => previousHighConfirmation
    => bullishCloseConfirmation

bool validPullbackStructure = bullishTrend and recentFastEMATouch and close > slowEMA
bool pullbackEntrySetup = enablePullbackEntry and validPullbackStructure and pullbackConfirmed and rsiFilter

//──────────────────────────────────────────────────────────────────────────────
// Exit Conditions
//──────────────────────────────────────────────────────────────────────────────

bool emaExitCondition = ta.crossunder(fastEMA, slowEMA)

bool rawPriceExit = close < slowEMA
bool priceExitCondition = exitOnCloseOnly ? rawPriceExit and barstate.isconfirmed : low < slowEMA

bool selectedExitCondition = switch exitMode
    "20 EMA Below 50 EMA" => emaExitCondition
    "Price Below 50 EMA" => priceExitCondition
    "Either Condition" => emaExitCondition or priceExitCondition
    => emaExitCondition or priceExitCondition

//──────────────────────────────────────────────────────────────────────────────
// Trade State
//──────────────────────────────────────────────────────────────────────────────

var bool inTrade = false
var float entryPrice = na
var int entryBar = na

bool initialBuySignal = not inTrade and initialEntrySetup and barstate.isconfirmed
bool pullbackBuySignal = not inTrade and not initialBuySignal and pullbackEntrySetup and barstate.isconfirmed
bool buySignal = initialBuySignal or pullbackBuySignal

bool exitSignal = inTrade and selectedExitCondition and barstate.isconfirmed

if buySignal
    inTrade := true
    entryPrice := close
    entryBar := bar_index

if exitSignal
    inTrade := false
    entryPrice := na
    entryBar := na

//──────────────────────────────────────────────────────────────────────────────
// Plots
//──────────────────────────────────────────────────────────────────────────────

plot(showFastEMA ? fastEMA : na, "Pullback EMA", color=color.rgb(35, 35, 35), linewidth=2)
plot(showSlowEMA ? slowEMA : na, "Trend EMA", color=color.rgb(218, 190, 79), linewidth=2)

plotshape(showSignals and initialBuySignal, title="Initial Buy", text="BUY", style=shape.labelup, location=location.belowbar, color=color.rgb(0, 150, 80), textcolor=color.white, size=size.small)
plotshape(showSignals and pullbackBuySignal, title="Pullback Buy", text="PULLBACK\nBUY", style=shape.labelup, location=location.belowbar, color=color.rgb(0, 125, 65), textcolor=color.white, size=size.small)
plotshape(showSignals and exitSignal, title="Exit", text="EXIT", style=shape.labeldown, location=location.abovebar, color=color.rgb(210, 55, 55), textcolor=color.white, size=size.small)

bgcolor(showTradeBackground and inTrade ? color.new(color.green, backgroundOpacity) : na)

// Hidden values for Data Window and alert placeholders

plot(rsiValue, "RSI Value", display=display.none)
plot(entryPrice, "Active Entry Price", display=display.none)

//──────────────────────────────────────────────────────────────────────────────
// Dashboard
//──────────────────────────────────────────────────────────────────────────────

tablePosition = switch dashboardPosition
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

var table dashboard = table.new(tablePosition, 2, 7, border_width=1, border_color=color.rgb(70, 70, 70))

color dashboardBackground = color.rgb(25, 28, 34)
color headerBackground = color.rgb(45, 50, 60)
color textColor = color.white
color positiveColor = color.rgb(45, 185, 105)
color negativeColor = color.rgb(225, 75, 75)
color neutralColor = color.rgb(230, 180, 60)

string trendText = bullishTrend ? "BULLISH" : bearishTrend ? "BEARISH" : "NEUTRAL"
color trendColor = bullishTrend ? positiveColor : bearishTrend ? negativeColor : neutralColor

string rsiText = str.tostring(rsiValue, "#.##") + (rsiBullish ? " • BULLISH" : " • WEAK")
color rsiColor = rsiBullish ? positiveColor : negativeColor

string positionText = inTrade ? "ACTIVE LONG" : "WAITING"
color positionColor = inTrade ? positiveColor : neutralColor

string setupText = initialEntrySetup ? "CROSSOVER READY" : pullbackEntrySetup ? "PULLBACK READY" : "NO SETUP"
color setupColor = initialEntrySetup or pullbackEntrySetup ? positiveColor : neutralColor

string entryText = inTrade and not na(entryPrice) ? str.tostring(entryPrice, format.mintick) : "—"

if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "STOC EMA–RSI", bgcolor=headerBackground, text_color=textColor, text_size=size.small)
        table.cell(dashboard, 1, 0, "PULLBACK", bgcolor=headerBackground, text_color=textColor, text_size=size.small)

        table.cell(dashboard, 0, 1, "Trend", bgcolor=dashboardBackground, text_color=textColor)
        table.cell(dashboard, 1, 1, trendText, bgcolor=dashboardBackground, text_color=trendColor)

        table.cell(dashboard, 0, 2, "RSI " + str.tostring(rsiLength), bgcolor=dashboardBackground, text_color=textColor)
        table.cell(dashboard, 1, 2, rsiText, bgcolor=dashboardBackground, text_color=rsiColor)

        table.cell(dashboard, 0, 3, "Setup", bgcolor=dashboardBackground, text_color=textColor)
        table.cell(dashboard, 1, 3, setupText, bgcolor=dashboardBackground, text_color=setupColor)

        table.cell(dashboard, 0, 4, "Position", bgcolor=dashboardBackground, text_color=textColor)
        table.cell(dashboard, 1, 4, positionText, bgcolor=dashboardBackground, text_color=positionColor)

        table.cell(dashboard, 0, 5, "Entry Price", bgcolor=dashboardBackground, text_color=textColor)
        table.cell(dashboard, 1, 5, entryText, bgcolor=dashboardBackground, text_color=textColor)

        table.cell(dashboard, 0, 6, "Exit Method", bgcolor=dashboardBackground, text_color=textColor)
        table.cell(dashboard, 1, 6, exitMode, bgcolor=dashboardBackground, text_color=neutralColor, text_size=size.tiny)
    else
        table.clear(dashboard, 0, 0, 1, 6)

//──────────────────────────────────────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────────────────────────────────────

alertcondition(buySignal, title="STOC EMA RSI Buy", message="STOC EMA RSI Pullback BUY")
alertcondition(exitSignal, title="STOC EMA RSI Exit", message="STOC EMA RSI Pullback EXIT")

string entryType = initialBuySignal ? "INITIAL_CROSSOVER" : "PULLBACK"

string buyMessage = '{"strategy":"' + webhookName + '","action":"BUY","entry_type":"' + entryType + '","ticker":"' + syminfo.ticker + '","exchange":"' + syminfo.prefix + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"rsi":' + str.tostring(rsiValue, "#.##") + ',"time":' + str.tostring(time) + '}'

string exitMessage = '{"strategy":"' + webhookName + '","action":"EXIT","ticker":"' + syminfo.ticker + '","exchange":"' + syminfo.prefix + '","timeframe":"' + timeframe.period + '","price":' + str.tostring(close) + ',"rsi":' + str.tostring(rsiValue, "#.##") + ',"reason":"' + exitMode + '","time":' + str.tostring(time) + '}'

if enableAppAlerts and buySignal
    alert(buyMessage, alert.freq_once_per_bar_close)

if enableAppAlerts and exitSignal
    alert(exitMessage, alert.freq_once_per_bar_close)
````
