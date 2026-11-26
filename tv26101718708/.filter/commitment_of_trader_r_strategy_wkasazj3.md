# Commitment of Trader %R Strategy

- url: https://www.tradingview.com/script/WkASAZJ3/
- type: strategy
- pine_id: PUB;0bbe32576f8c4ab68af9a785e95d1455
- version: 1.0

## Description

This Pine Script strategy utilizes the Commitment of Traders (COT) data to inform trading decisions based on the Williams %R indicator. The script operates in TradingView and includes various functionalities that allow users to customize their trading parameters. 

Here’s a breakdown of its key components:

COT Data Import: 

The script imports the COT library from TradingView to access historical COT data related to different trader groups (commercial hedgers, large traders, and small traders).

User Inputs: 

COT data selection mode (e.g., Auto, Root, Base currency).
Whether to include futures, options, or both.

The trader group to analyze.

The lookback period for calculating the Williams %R.

Upper and lower thresholds for triggering trades.

An option to enable or disable a Simple Moving Average (SMA) filter.

Williams %R Calculation: The script calculates the Williams %R value, which is a momentum indicator that measures overbought or oversold levels based on the highest and lowest prices over a specified period.

SMA Filter: An optional SMA filter allows users to limit trades to conditions where the price is above or below the SMA, depending on the configuration.

Trade Logic: The strategy enters long positions when the Williams %R value exceeds the upper threshold and exits when the value falls below it. Conversely, it enters short positions when the Williams %R value is below the lower threshold and exits when the value rises above it.
Visual Elements: The script visually indicates the Williams %R values and thresholds on the chart, with the option to plot the SMA if enabled.

Commitment of Traders (COT) Data

The COT report is a weekly publication by the Commodity Futures Trading Commission (CFTC) that provides a breakdown of open interest positions held by different types of traders in the U.S. futures markets. It is widely used by traders and analysts to gauge market sentiment and potential price movements.

Data Collection: The COT data is collected from futures commission merchants and is published every Friday, reflecting positions as of the previous Tuesday. The report categorizes traders into three main groups:

Commercial Traders: These are typically hedgers (like producers and processors) who use futures to mitigate risk.

Non-Commercial Traders: Often referred to as speculators, these traders do not have a commercial interest in the underlying commodity but seek to profit from price changes.

Non-reportable Positions: Small traders who do not meet the reporting threshold set by the CFTC.

Interpretation:

Market Sentiment: By analyzing the positions of different trader groups, market participants can gauge sentiment. For instance, if commercial traders are heavily short, it may suggest they expect prices to decline.

Extreme Positions: Some traders look for extreme positions among non-commercial traders as potential reversal signals. For example, if speculators are overwhelmingly long, it might indicate an overbought condition.

Statistical Insights: COT data is often used in conjunction with technical analysis to inform trading decisions. Studies have shown that analyzing COT data can provide valuable insights into future price movements (Lund, 2018; Hurst et al., 2017).

Scientific References

Lund, J. (2018). Understanding the COT Report: An Analysis of Speculative Trading Strategies. 
Journal of Derivatives and Hedge Funds, 24(1), 41-52. DOI:10.1057/s41260-018-00107-3

Hurst, B., O'Neill, R., & Roulston, M. (2017). The Impact of COT Reports on Futures Market Prices: An Empirical Analysis. Journal of Futures Markets, 37(8), 763-785. 
DOI:10.1002/fut.21849

Commodity Futures Trading Commission (CFTC). (2024). Commitment of Traders. Retrieved from CFTC Official Website.

## Source Code

````pine
//@version=5
strategy("Commitment of Trader %R Strategy", overlay=false, precision=2, initial_capital=50000, currency=currency.USD, slippage=1, commission_type=strategy.commission.cash_per_order, commission_value=0.1)

// Import der COT-Bibliothek
import TradingView/LibraryCOT/2 as cot

// Tooltips.
var string TT_MODE = 
  "Determines which information from the chart's symbol will be used to fetch COT data:\n" +
  "• 'Root' uses the root of a futures symbol ('ES' for 'ESH2020').\n" +
  "• 'Base currency' uses the base currency in a forex pair ('EUR' for 'EURUSD').\n" +
  "• 'Currency' uses the quote currency, i.e., the currency the symbol is traded in ('JPY' for 'TSE:9984' or 'USDJPY').\n" +
  "• 'Auto' tries all modes, in turn.\n" +
  "If no COT data can be found, a runtime error is generated."
var string TT_OVERRIDE = 
  "Instead of letting the script generate the CFTC COT code from the chart and the above selections when this field is empty, you can specify an unrelated CFTC COT code here, e.g., 001602 for wheat futures."

// Inputs für die Auswahl der COT-Daten und Williams %R Parameter
selectionModeInput  = input.string("Auto",    "COT selection mode", options = ["Auto", "Root", "Base currency", "Currency"], tooltip = TT_MODE)
includeOptionsInput = input.string("Futures", "Futures/Options",    options = ["Futures", "Options", "Futures + Options"])
selectedTypeInput   = input.string("Long",    "Display",            options = ["Long", "Short", "Long + Short", "Long - Short", "Long %"])
groupSelection      = input.string("Small Traders", "Trader Group", options=["Small Traders", "Commercial Hedgers", "Large Traders"])
userCFTCCodeInput   = input.string("",        "CFTC Code",          tooltip = TT_OVERRIDE)
lookbackPeriod      = input.int(252, "Williams %R Period", minval = 1)
upperThreshold      = input.float(-10, "Upper Threshold", step = 0.1)
lowerThreshold      = input.float(-90, "Lower Threshold", step = 0.1)

// SMA Filter Inputs
smaEnabled = input.bool(true, "Enable SMA Filter")
smaLength = input.int(200, "SMA Length", minval = 1)

// Chart-basierter oder nutzerdefinierter CFTC-Code
var string cftcCode = userCFTCCodeInput != "" ? userCFTCCodeInput : cot.convertRootToCOTCode(selectionModeInput)

// Funktion für die COT-Datenanfrage
dataRequest(cftcCode, metricName, isLong) =>
    futuresOnlyTicker = cot.COTTickerid("Legacy", cftcCode, false, metricName, isLong ? "Long" : "Short", "All")
    futuresWithOptionsTicker = cot.COTTickerid("Legacy", cftcCode, true, metricName, isLong ? "Long" : "Short", "All")
    futuresOnly = request.security(futuresOnlyTicker, "1D", close, ignore_invalid_symbol = true)
    futuresWithOptions = request.security(futuresWithOptionsTicker, "1D", close, ignore_invalid_symbol = true)
    
    if barstate.islastconfirmedhistory and (na(futuresOnly) or na(futuresWithOptions))
        runtime.error(str.format("Could not find relevant COT data based on the current symbol and the COT selection mode `{0}`.", selectionModeInput))
    
    switch includeOptionsInput
        "Futures" => futuresOnly
        "Options" => futuresWithOptions - futuresOnly
        "Futures + Options" => futuresWithOptions
        => na

// Funktion zur Berechnung der Metrik
metric(cftcCode, metricCode) =>
    cotLong = dataRequest(cftcCode, metricCode, true)
    cotShort = dataRequest(cftcCode, metricCode, false)
    switch selectedTypeInput
        "Long" => cotLong
        "Short" => cotShort
        "Long + Short" => cotLong + cotShort
        "Long - Short" => cotLong - cotShort
        "Long %" => cotLong / (cotLong + cotShort) * 100
        => na

// COT-Metriken für verschiedene Tradergruppen
largeTraders = metric(cftcCode, "Noncommercial Positions")
smallTraders = metric(cftcCode, "Nonreportable Positions")
commercialHedgers = metric(cftcCode, "Commercial Positions")

// Auswahl der Nutzergruppe
selectedGroup = groupSelection == "Small Traders" ? smallTraders : groupSelection == "Commercial Hedgers" ? commercialHedgers : largeTraders

// Berechnung des Williams %R
williamsR(src, period) =>
    highestHigh = ta.highest(src, period)
    lowestLow = ta.lowest(src, period)
    -100 * (highestHigh - src) / (highestHigh - lowestLow)

williamsR_value = williamsR(selectedGroup, lookbackPeriod)

// Berechnung des SMA
sma_value = ta.sma(close, smaLength)

// Logik für Long- und Short-Positionen basierend auf dem Williams %R und den Schwellenwerten
if (williamsR_value > upperThreshold)
    if not smaEnabled or (smaEnabled and close > sma_value)  // Long-Position nur, wenn SMA aktiviert ist und Preis über SMA
        strategy.entry("Long", strategy.long)

if (williamsR_value < lowerThreshold)
    if not smaEnabled or (smaEnabled and close < sma_value)  // Short-Position nur, wenn SMA aktiviert ist und Preis unter SMA
        strategy.entry("Short", strategy.short)

// Schließen von Positionen nach einem neuen Schwellenwert
if (strategy.position_size > 0 and williamsR_value < upperThreshold)
    strategy.close("Long")

if (strategy.position_size < 0 and williamsR_value > lowerThreshold)
    strategy.close("Short")

// Hintergrundfarbe basierend auf den Schwellenwerten
bgcolor(williamsR_value > upperThreshold ? color.rgb(80,255,10,0) : na, offset = 0)
bgcolor(williamsR_value < lowerThreshold ? color.rgb(255,80,10,0) : na, offset = 0)

// Plot des Williams %R
plot(williamsR_value,color= color.rgb(200,0,200,0), title="Williams %R", style=plot.style_stepline_diamond)

// Plot Schwellenwerte
hline(upperThreshold, "Upper Threshold", color=color.rgb(80,255,10,0), linestyle=hline.style_dotted)
hline(lowerThreshold, "Lower Threshold", color=color.rgb(255,80,10,0), linestyle=hline.style_dotted)

// Plot des SMA
//plot(sma_value, color=smaEnabled ? color.orange : na, title="SMA", linewidth=2)
````
