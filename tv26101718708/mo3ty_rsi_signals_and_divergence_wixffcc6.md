# Mo3ty RSI - Signals and Divergence

- url: https://www.tradingview.com/script/WIXFFcc6-Mo3ty-RSI-Signals-and-Divergence/
- type: indicator
- pine_id: PUB;9400d0988ab64c0596c8a803ebdc171f
- version: 1.0

## Description

# Mo3ty RSI - Signals and Divergence

## Overview

Mo3ty RSI is an open-source technical analysis indicator designed to identify potential momentum reversal signals and bullish or bearish RSI divergence. It combines configurable RSI levels, optional MACD confirmation, optional trend and candle filters, and pivot-based divergence detection in one customizable indicator.

The indicator is designed to support technical analysis and discretionary trading decisions. It does not guarantee profitable trades or predict future prices.

## Key Features

### 1. RSI Buy and Sell Signals

The indicator uses the Relative Strength Index (RSI) to identify potential reversal opportunities.

- Buy signal: RSI crosses back above the selected oversold level.
- Sell signal: RSI crosses back below the selected overbought level.
- Signals are evaluated at candle close.

Default RSI settings:
- RSI Length: 16
- Overbought Level: 70
- Oversold Level: 30

All three settings can be adjusted.

### 2. Optional MACD Confirmation

The MACD filter helps users evaluate momentum alignment when a potential RSI signal occurs.

- Buy signals require the MACD line to be above the MACD signal line when the filter is enabled.
- Sell signals require the MACD line to be below the MACD signal line when the filter is enabled.

Default MACD parameters:
- Fast Length: 12
- Slow Length: 26
- Signal Length: 9

The MACD filter is disabled by default and can be enabled or disabled in the settings.

### 3. Optional EMA Trend Filter

Users can enable an Exponential Moving Average (EMA) filter to restrict signals according to price position relative to the selected EMA.

- Buy signals require the closing price to be above the EMA.
- Sell signals require the closing price to be below the EMA.

The default EMA length is 200. This filter is disabled by default.

### 4. Optional Candle Direction Filter

When enabled:
- Buy signals require a bullish candle.
- Sell signals require a bearish candle.

This filter is disabled by default.

### 5. Bullish and Bearish RSI Divergence

The indicator identifies potential divergence by comparing price swing points with corresponding RSI values.

- Bullish divergence: price forms a lower low while RSI forms a higher low.
- Bearish divergence: price forms a higher high while RSI forms a lower high.

An optional RSI zone filter requires at least one of the compared RSI pivot values to reach the relevant oversold or overbought zone.

Divergence labels and lines can be configured independently for the price chart and RSI pane.

### 6. Pivot Confirmation

Users can adjust:
- Pivot Left
- Pivot Confirmation Bars

Both settings default to 5 bars.

Pivot confirmation requires subsequent bars to validate a potential swing point. Consequently, divergence signals are delayed by the selected confirmation period. This is an intentional feature of pivot-based detection.

### 7. Customizable Display

Available display options include:
- Buy and sell arrows on the price chart.
- Buy and sell arrows in the RSI pane.
- Adjustable arrow size and RSI-pane arrow distance.
- Configurable RSI, bullish, and bearish colors.
- Independent visibility settings for divergence labels and lines.

### 8. Alerts

The indicator provides alert conditions for:
- RSI Buy
- RSI Sell
- Bullish Divergence
- Bearish Divergence

Users can create alerts through TradingView's alert interface.

## How to Use

1. Add Mo3ty RSI to a chart.
2. Review the default RSI levels and adjust them if needed.
3. Enable the MACD filter if momentum confirmation is desired.
4. Optionally enable the EMA trend filter or candle direction filter.
5. Adjust pivot settings to control swing-point confirmation.
6. Review signals in the context of price structure, market conditions, and independent risk-management rules.

## Originality and Design

Mo3ty RSI combines RSI threshold-return signals with optional MACD state confirmation, optional EMA and candle-direction filters, and separately configurable pivot-based divergence visualization. Its purpose is to provide a unified and adjustable workflow for examining momentum reversals and potential divergence without requiring users to combine multiple separate indicators manually.

## Limitations and Risk Disclosure

Technical indicators can produce false signals, particularly during sideways markets, sudden price movements, and changing market conditions.

MACD and EMA filters may reduce the number of signals but can also delay entries or exclude potentially valid opportunities. Pivot-based divergence detection necessarily involves confirmation delay.

Signals are calculated using the available chart data and the selected settings. Confirmed signals are evaluated at candle close; divergence is recognized only after the relevant pivot is confirmed. This does not guarantee that every signal will be profitable or that all market risks can be avoided.

The indicator is an analytical tool, not financial advice. Always conduct independent research and apply appropriate risk management before making trading decisions.

## Open-Source Notice

Mo3ty RSI is published as an open-source script for the TradingView community. Users can inspect the source code and learn from its implementation, subject to the applicable license and TradingView's script publishing rules.

## Source Code

````pine

 //@version=6
indicator("Mo3ty RSI", shorttitle="Mo3ty RSI", overlay=false, max_labels_count=500, max_lines_count=500)

// 1. RSI SETTINGS
groupRSI = "RSI Settings"
rsiLength = input.int(16, "RSI Length", minval=2, group=groupRSI)
upperLevel = input.float(70.0, "Overbought", minval=50, maxval=100, group=groupRSI)
lowerLevel = input.float(30.0, "Oversold", minval=0, maxval=50, group=groupRSI)

// 2. SIGNAL SETTINGS
groupSig = "Signals"
showPriceArrows = input.bool(true, "Show Arrows on Price", group=groupSig)
showPaneSignals = input.bool(true, "Show Arrows in RSI Pane", group=groupSig)
arrowSizeInput = input.string("Huge", "Arrow Size", options=["Normal", "Large", "Huge"], group=groupSig)
paneArrowOffset = input.float(5.0, "RSI Arrow Distance", minval=0.5, maxval=20, step=0.5, group=groupSig)
useEMAFilter = input.bool(false, "Enable EMA Trend Filter", group=groupSig)
emaLength = input.int(200, "EMA Length", minval=1, group=groupSig)
useCandleFilter = input.bool(false, "Confirm Candle Direction", group=groupSig)

// 3. MACD FILTER
groupMACD = "MACD Filter"
useMACDFilter = input.bool(false, "Enable MACD Filter", group=groupMACD)
macdFastLength = input.int(12, "MACD Fast Length", minval=1, group=groupMACD)
macdSlowLength = input.int(26, "MACD Slow Length", minval=1, group=groupMACD)
macdSignalLength = input.int(9, "MACD Signal Length", minval=1, group=groupMACD)

// 4. DIVERGENCE SETTINGS
groupDiv = "Divergence"
showPriceDiv = input.bool(true, "Show Divergence on Price", group=groupDiv)
showPaneDiv = input.bool(true, "Show Divergence Labels in RSI Pane", group=groupDiv)
showDivLines = input.bool(true, "Show Divergence Lines on Price", group=groupDiv)
showPaneDivLines = input.bool(true, "Show Divergence Lines in RSI Pane", group=groupDiv)
useDivergenceZoneFilter = input.bool(true, "Require RSI Overbought/Oversold", group=groupDiv)
pivotLeft = input.int(5, "Pivot Left", minval=1, maxval=50, group=groupDiv)
pivotRight = input.int(5, "Pivot Confirmation Bars", minval=1, maxval=50, group=groupDiv)

// 5. COLORS
groupColor = "Colors"
rsiColor = input.color(color.aqua, "RSI Color", group=groupColor)
bullColor = input.color(color.lime, "Bull Color", group=groupColor)
bearColor = input.color(color.red, "Bear Color", group=groupColor)

// 6. RSI, EMA AND MACD CALCULATIONS
rsi = ta.rsi(close, rsiLength)
emaTrend = ta.ema(close, emaLength)

[macdLine, macdSignalLine, macdHistogram] = ta.macd(close, macdFastLength, macdSlowLength, macdSignalLength)

macdBuyOK = not useMACDFilter or macdLine > macdSignalLine
macdSellOK = not useMACDFilter or macdLine < macdSignalLine

// RSI pane
plot(rsi, "RSI", color=rsiColor, linewidth=2)
plot(upperLevel, "Overbought", color=color.new(bearColor, 20))
plot(lowerLevel, "Oversold", color=color.new(bullColor, 20))
plot(50, "Midline", color=color.new(color.gray, 65))

// 7. BUY AND SELL SIGNALS
buyCross = ta.crossover(rsi, lowerLevel)
sellCross = ta.crossunder(rsi, upperLevel)

buyTrendOK = not useEMAFilter or close > emaTrend
sellTrendOK = not useEMAFilter or close < emaTrend

buyCandleOK = not useCandleFilter or close > open
sellCandleOK = not useCandleFilter or close < open

buySignal = barstate.isconfirmed and buyCross and buyTrendOK and buyCandleOK and macdBuyOK
sellSignal = barstate.isconfirmed and sellCross and sellTrendOK and sellCandleOK and macdSellOK

arrowSize = switch arrowSizeInput
    "Normal" => size.normal
    "Large" => size.large
    => size.huge

// Arrows on price chart
if showPriceArrows and buySignal
    label.new(bar_index, low, "▲", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_none, textcolor=bullColor, size=arrowSize, force_overlay=true)

if showPriceArrows and sellSignal
    label.new(bar_index, high, "▼", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_none, textcolor=bearColor, size=arrowSize, force_overlay=true)

// Arrows in RSI pane
if showPaneSignals and buySignal
    label.new(bar_index, math.max(0.0, rsi - paneArrowOffset), "▲", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=bullColor, size=arrowSize)

if showPaneSignals and sellSignal
    label.new(bar_index, math.min(100.0, rsi + paneArrowOffset), "▼", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=bearColor, size=arrowSize)

// 8. DIVERGENCE CALCULATIONS
pl = ta.pivotlow(low, pivotLeft, pivotRight)
ph = ta.pivothigh(high, pivotLeft, pivotRight)

var float prevLowPrice = na
var float prevLowRSI = na
var int prevLowBar = na

var float prevHighPrice = na
var float prevHighRSI = na
var int prevHighBar = na

bool bullDiv = false
bool bearDiv = false

// Bullish divergence
if barstate.isconfirmed and not na(pl)
    currLowPrice = pl
    currLowRSI = rsi[pivotRight]
    currLowBar = bar_index - pivotRight

    bullStructure = not na(prevLowPrice) and currLowPrice < prevLowPrice and currLowRSI > prevLowRSI
    bullZoneOK = not useDivergenceZoneFilter or math.min(currLowRSI, prevLowRSI) <= lowerLevel
    bullDiv := bullStructure and bullZoneOK

    if bullDiv
        if showPriceDiv and showDivLines
            line.new(prevLowBar, prevLowPrice, currLowBar, currLowPrice, xloc=xloc.bar_index, color=bullColor, width=2, force_overlay=true)

        if showPaneDivLines
            line.new(prevLowBar, prevLowRSI, currLowBar, currLowRSI, xloc=xloc.bar_index, color=bullColor, width=2)

        if showPriceDiv
            label.new(bar_index, low, "BULL", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=bullColor, textcolor=color.black, size=size.normal, force_overlay=true)

        if showPaneDiv
            label.new(bar_index, rsi, "BULL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=bullColor, textcolor=color.black, size=size.small)

    prevLowPrice := currLowPrice
    prevLowRSI := currLowRSI
    prevLowBar := currLowBar

// Bearish divergence
if barstate.isconfirmed and not na(ph)
    currHighPrice = ph
    currHighRSI = rsi[pivotRight]
    currHighBar = bar_index - pivotRight

    bearStructure = not na(prevHighPrice) and currHighPrice > prevHighPrice and currHighRSI < prevHighRSI
    bearZoneOK = not useDivergenceZoneFilter or math.max(currHighRSI, prevHighRSI) >= upperLevel
    bearDiv := bearStructure and bearZoneOK

    if bearDiv
        if showPriceDiv and showDivLines
            line.new(prevHighBar, prevHighPrice, currHighBar, currHighPrice, xloc=xloc.bar_index, color=bearColor, width=2, force_overlay=true)

        if showPaneDivLines
            line.new(prevHighBar, prevHighRSI, currHighBar, currHighRSI, xloc=xloc.bar_index, color=bearColor, width=2)

        if showPriceDiv
            label.new(bar_index, high, "BEAR", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.normal, force_overlay=true)

        if showPaneDiv
            label.new(bar_index, rsi, "BEAR", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.small)

    prevHighPrice := currHighPrice
    prevHighRSI := currHighRSI
    prevHighBar := currHighBar

// 9. ALERTS
alertcondition(buySignal, title="RSI Buy", message="Mo3ty RSI: Confirmed BUY with selected filters.")
alertcondition(sellSignal, title="RSI Sell", message="Mo3ty RSI: Confirmed SELL with selected filters.")
alertcondition(barstate.isconfirmed and bullDiv, title="Bullish Divergence", message="Mo3ty RSI: Confirmed BULL divergence with oversold filter.")
alertcondition(barstate.isconfirmed and bearDiv, title="Bearish Divergence", message="Mo3ty RSI: Confirmed BEAR divergence with overbought filter.")
````
