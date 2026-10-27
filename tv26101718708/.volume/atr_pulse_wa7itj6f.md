# ATR Pulse

- url: https://www.tradingview.com/script/wa7ITj6F-ATR-Pulse/
- type: indicator
- pine_id: PUB;5a1d6156dd58482caae835a0f082ae64
- version: 1.0

## Description

ATR Pulse is an ATR-based trend and signal indicator designed to identify transitions around a dynamic volatility-adjusted trailing stop.

The script combines one core ATR transition engine with optional validation filters. These filters are not separate trading systems merged together; they act as configurable confirmation layers around the same underlying price-versus-trailing-stop event. This allows users to keep the indicator simple or make signal requirements more selective without changing the core concept.

**How it works**

The indicator calculates Average True Range over the selected ATR Period and multiplies it by the ATR Sensitivity setting.

This produces a dynamic loss distance:

ATR distance = ATR x Sensitivity

The trailing stop then adjusts according to the relationship between the current price, the previous price, and the previous trailing-stop value.

When price remains above the trailing stop, the stop follows upward without moving lower.

When price remains below the trailing stop, the stop follows downward without moving higher.

A directional transition is detected when price crosses the ATR trailing stop:

* A bullish signal requires price to cross above the trailing stop.
* A bearish signal requires price to cross below the trailing stop.

The indicator uses standard chart prices and does not request data from another symbol or timeframe.

**ATR Sensitivity**

ATR Sensitivity controls how closely the trailing stop follows price.

Lower values create a tighter stop that reacts to smaller price movements.

Higher values create a wider stop that requires a larger price movement before a directional transition occurs.

ATR Period controls the lookback used to calculate market volatility.

**Optional EMA trend filter**

When enabled:

* Bullish signals require price to be above the selected EMA.
* Bearish signals require price to be below the selected EMA.

The purpose of this filter is to restrict ATR transitions to the selected broader price direction.

**Optional ADX / DMI filter**

When enabled, the indicator requires both directional strength and directional agreement.

For bullish signals:

* ADX must be at or above the selected minimum.
* +DI must be greater than -DI.

For bearish signals:

* ADX must be at or above the selected minimum.
* -DI must be greater than +DI.

DI Length, ADX Smoothing, and Minimum ADX are independently adjustable.

**Optional RSI filter**

The RSI filter provides an additional directional condition.

When enabled:

* Bullish signals require RSI above the selected RSI Direction Level.
* Bearish signals require RSI below that level.

The default center level is 50, but both the RSI length and directional level can be changed.

**Optional volume filter**

When enabled, current volume must be at least the selected multiple of its moving average.

For example, a setting of 1.5 requires current volume to be at least 1.5 times the selected average-volume reference.

If usable volume data is not available for the symbol, the volume condition is bypassed rather than preventing all signals. Volume therefore should be interpreted according to the quality of volume data provided for the selected market.

**Optional candle-quality filter**

This filter evaluates the signal candle itself.

When enabled:

* A bullish signal requires a bullish candle.
* A bearish signal requires a bearish candle.
* The candle body must represent at least the selected percentage of the candle's full high-to-low range.

This can be used to exclude transition candles with relatively small bodies and large wicks.

**Signal cooldown**

The Minimum bars between signals setting can be used to reduce closely spaced signals.

A value of 0 disables the cooldown.

Higher values require the specified number of bars to pass before another signal can be accepted.

**Candle-close confirmation**

Confirm signals on candle close is enabled by default.

When enabled, Buy and Sell signals are accepted only after the current candle is confirmed closed.

When disabled, signal conditions can become true while the realtime candle is still developing. In that mode, a signal may appear or disappear before the candle closes as price changes.

**Visual controls**

The indicator can display:

* Buy and Sell labels.
* The ATR trailing stop.
* The trend EMA.
* A bullish or bearish background.
* An information dashboard.

Most supplementary visuals are optional so users can keep the chart clean and display only the elements relevant to their analysis.

The dashboard can show the current trend state together with ATR, ADX, RSI, sensitivity, and current filter readiness.

**Alerts**

Two alert conditions are included:

* ATR Pulse Buy
* ATR Pulse Sell

These alerts use the same final signal conditions as the chart labels, including any optional filters that the user has enabled.

Users should configure the indicator settings before creating an alert so the alert reflects the intended configuration.

**Pine Screener support**

ATR Pulse can also be used with TradingView's Pine Screener.

The script includes dedicated Buy and Sell alert conditions that can be used as screening filters, allowing users to scan a watchlist for symbols currently meeting the ATR Pulse bullish or bearish conditions.

This can be particularly useful when the same ATR Pulse settings need to be evaluated across multiple symbols instead of checking charts individually.

Pine Screener has its own platform limitations and calculation scope, so screening results should be interpreted within the data and timeframe processed by the Screener.

**Example workflow**

A user who wants the basic ATR transition behavior can leave all optional filters disabled.

A more selective configuration can enable one or more of the following:

* EMA trend alignment.
* ADX / DI directional strength.
* RSI direction.
* Volume expansion.
* Candle quality.
* Signal cooldown.

Each enabled filter becomes an additional requirement for the same underlying ATR transition signal.

There is no single recommended combination for every symbol or timeframe. Settings should be selected according to the market, timeframe, and type of analysis being performed.

**Repainting and realtime behavior**

ATR Pulse does not use future data or lookahead calculations.

With Confirm signals on candle close enabled, signal confirmation occurs only on closed candles.

The ATR trailing stop itself continues to update as new market data arrives.

If candle-close confirmation is disabled, conditions on the realtime candle can change before that candle closes. This is normal realtime behavior and should not be interpreted as a confirmed historical signal until the bar is complete.

Changing indicator settings, symbol, timeframe, or available chart history causes TradingView to recalculate the indicator.

**Limitations**

ATR Pulse is sensitive to volatility and parameter selection.

A tight ATR Sensitivity may produce more frequent transitions in sideways markets, while a wider setting can respond more slowly to directional changes.

Optional filters can reduce the number of signals, but they can also delay or exclude transitions that would otherwise qualify under the core ATR logic.

ADX, RSI, EMA, volume, and candle-quality conditions describe different aspects of current market behavior. Their inclusion does not guarantee that a subsequent price move will continue in the signal direction.

Signals are descriptive outputs of the selected rules, not forecasts of future price movement.

ATR Pulse is an indicator, not a strategy. It does not place orders, provide performance statistics, or claim a particular win rate. It is intended as a configurable technical-analysis and screening tool to help users identify and evaluate ATR-based directional transitions.

## Source Code

````pine
//@version=6
indicator(
     title = "ATR Pulse",
     shorttitle = "ATR Pulse",
     overlay = true,
     max_labels_count = 500
     )

// ============================================================================
// ATR Pulse
//
// ATR-based trend and signal engine.
//
// Core concept:
// 1. Build a dynamic ATR trailing stop.
// 2. Detect price transitions across the trailing stop.
// 3. Generate bullish / bearish signals.
// 4. Optionally validate signals with trend, ADX, RSI, volume,
//    candle quality, and cooldown filters.
// 5. Signals can be restricted to confirmed candle closes.
//
// The indicator uses standard market prices only.
// The indicator does not modify chart candle colors.
// ============================================================================


// ============================================================================
// 01. CORE ENGINE
// ============================================================================

grpCore = "01 - Core Engine"

sensitivity = input.float(
     1.0,
     "ATR Sensitivity",
     minval = 0.1,
     maxval = 20.0,
     step = 0.1,
     group = grpCore,
     tooltip = "ATR multiplier used to calculate the dynamic trailing stop. Lower values react faster; higher values create wider stops."
     )

atrPeriod = input.int(
     10,
     "ATR Period",
     minval = 1,
     maxval = 500,
     group = grpCore,
     tooltip = "Lookback period used for Average True Range."
     )

confirmOnClose = input.bool(
     true,
     "Confirm signals on candle close",
     group = grpCore,
     tooltip = "When enabled, Buy and Sell signals are only confirmed when the current candle closes."
     )


// ============================================================================
// 02. TREND FILTER
// ============================================================================

grpTrend = "02 - Trend Filter"

useEMAFilter = input.bool(
     false,
     "Enable EMA trend filter",
     group = grpTrend,
     tooltip = "Long signals require price above the EMA. Short signals require price below the EMA."
     )

emaLength = input.int(
     200,
     "EMA Length",
     minval = 1,
     maxval = 1000,
     group = grpTrend
     )


// ============================================================================
// 03. ADX FILTER
// ============================================================================

grpADX = "03 - ADX Filter"

useADXFilter = input.bool(
     false,
     "Enable ADX filter",
     group = grpADX,
     tooltip = "Requires sufficient directional strength and confirmation from +DI / -DI."
     )

diLength = input.int(
     14,
     "DI Length",
     minval = 1,
     maxval = 100,
     group = grpADX
     )

adxSmoothing = input.int(
     14,
     "ADX Smoothing",
     minval = 1,
     maxval = 100,
     group = grpADX
     )

minimumADX = input.float(
     20.0,
     "Minimum ADX",
     minval = 0.0,
     maxval = 100.0,
     step = 0.5,
     group = grpADX
     )


// ============================================================================
// 04. RSI FILTER
// ============================================================================

grpRSI = "04 - RSI Filter"

useRSIFilter = input.bool(
     false,
     "Enable RSI filter",
     group = grpRSI,
     tooltip = "Long signals require RSI above the selected center level. Short signals require RSI below it."
     )

rsiLength = input.int(
     14,
     "RSI Length",
     minval = 2,
     maxval = 100,
     group = grpRSI
     )

rsiCenter = input.float(
     50.0,
     "RSI Direction Level",
     minval = 1.0,
     maxval = 99.0,
     step = 0.5,
     group = grpRSI
     )


// ============================================================================
// 05. VOLUME FILTER
// ============================================================================

grpVolume = "05 - Volume Filter"

useVolumeFilter = input.bool(
     false,
     "Enable volume filter",
     group = grpVolume,
     tooltip = "Requires current volume to exceed its moving average multiplied by the selected factor."
     )

volumeLength = input.int(
     20,
     "Volume Average Length",
     minval = 1,
     maxval = 500,
     group = grpVolume
     )

volumeMultiplier = input.float(
     1.0,
     "Minimum Volume x Average",
     minval = 0.1,
     maxval = 10.0,
     step = 0.1,
     group = grpVolume
     )


// ============================================================================
// 06. CANDLE QUALITY FILTER
// ============================================================================

grpCandle = "06 - Candle Quality"

useCandleFilter = input.bool(
     false,
     "Enable candle quality filter",
     group = grpCandle,
     tooltip = "Requires the signal candle to close in the signal direction with a minimum body-to-range percentage."
     )

minimumBodyPercent = input.float(
     40.0,
     "Minimum body % of candle",
     minval = 0.0,
     maxval = 100.0,
     step = 5.0,
     group = grpCandle
     )


// ============================================================================
// 07. SIGNAL CONTROL
// ============================================================================

grpControl = "07 - Signal Control"

minimumBarsBetweenSignals = input.int(
     0,
     "Minimum bars between signals",
     minval = 0,
     maxval = 100,
     group = grpControl,
     tooltip = "Optional cooldown period used to reduce closely spaced signals in choppy conditions. Set to 0 to disable."
     )


// ============================================================================
// 08. VISUAL SETTINGS
// ============================================================================

grpVisual = "08 - Visual Settings"

showSignals = input.bool(
     true,
     "Show Buy / Sell labels",
     group = grpVisual
     )

showTrailingStop = input.bool(
     false,
     "Show ATR trailing stop",
     group = grpVisual
     )

showEMA = input.bool(
     false,
     "Show EMA",
     group = grpVisual
     )

showTrendBackground = input.bool(
     false,
     "Show trend background",
     group = grpVisual
     )

showDashboard = input.bool(
     false,
     "Show information dashboard",
     group = grpVisual
     )


// ============================================================================
// 09. SOURCE
// ============================================================================

src = close


// ============================================================================
// 10. ATR TRAILING STOP ENGINE
// ============================================================================

atrValue = ta.atr(atrPeriod)

nLoss = sensitivity * atrValue

var float atrTrailingStop = 0.0

previousStop = nz(atrTrailingStop[1], 0.0)

if src > previousStop and src[1] > previousStop
    atrTrailingStop := math.max(previousStop, src - nLoss)

else if src < previousStop and src[1] < previousStop
    atrTrailingStop := math.min(previousStop, src + nLoss)

else
    atrTrailingStop := src > previousStop ? src - nLoss : src + nLoss


// ============================================================================
// 11. CORE SIGNALS
// ============================================================================

signalEMA = ta.ema(src, 1)

crossAbove = ta.crossover(signalEMA, atrTrailingStop)

crossBelow = ta.crossover(atrTrailingStop, signalEMA)

rawLong =
     src > atrTrailingStop and
     crossAbove

rawShort =
     src < atrTrailingStop and
     crossBelow


// ============================================================================
// 12. TREND FILTER
// ============================================================================

trendEMA = ta.ema(src, emaLength)

emaLongOK =
     not useEMAFilter or
     src > trendEMA

emaShortOK =
     not useEMAFilter or
     src < trendEMA


// ============================================================================
// 13. ADX / DMI FILTER
// ============================================================================

[plusDI, minusDI, adxValue] = ta.dmi(
     diLength,
     adxSmoothing
     )

adxLongOK =
     not useADXFilter or
     (
         adxValue >= minimumADX and
         plusDI > minusDI
     )

adxShortOK =
     not useADXFilter or
     (
         adxValue >= minimumADX and
         minusDI > plusDI
     )


// ============================================================================
// 14. RSI FILTER
// ============================================================================

rsiValue = ta.rsi(src, rsiLength)

rsiLongOK =
     not useRSIFilter or
     rsiValue > rsiCenter

rsiShortOK =
     not useRSIFilter or
     rsiValue < rsiCenter


// ============================================================================
// 15. VOLUME FILTER
// ============================================================================

averageVolume = ta.sma(volume, volumeLength)

hasUsableVolume =
     not na(volume) and
     not na(averageVolume) and
     averageVolume > 0

volumePass =
     not useVolumeFilter or
     not hasUsableVolume or
     volume >= averageVolume * volumeMultiplier


// ============================================================================
// 16. CANDLE QUALITY FILTER
// ============================================================================

candleRange = high - low

bodySize = math.abs(close - open)

bodyPercent =
     candleRange > 0
     ? bodySize / candleRange * 100.0
     : 0.0

bullishCandle =
     close > open and
     bodyPercent >= minimumBodyPercent

bearishCandle =
     close < open and
     bodyPercent >= minimumBodyPercent

candleLongOK =
     not useCandleFilter or
     bullishCandle

candleShortOK =
     not useCandleFilter or
     bearishCandle


// ============================================================================
// 17. COMBINED FILTERS
// ============================================================================

longFiltersOK =
     emaLongOK and
     adxLongOK and
     rsiLongOK and
     volumePass and
     candleLongOK

shortFiltersOK =
     emaShortOK and
     adxShortOK and
     rsiShortOK and
     volumePass and
     candleShortOK


// ============================================================================
// 18. SIGNAL CONFIRMATION
// ============================================================================

barConfirmationOK =
     not confirmOnClose or
     barstate.isconfirmed

var int lastSignalBar = na

cooldownOK =
     na(lastSignalBar) or
     bar_index - lastSignalBar > minimumBarsBetweenSignals

buySignal =
     rawLong and
     longFiltersOK and
     barConfirmationOK and
     cooldownOK

sellSignal =
     rawShort and
     shortFiltersOK and
     barConfirmationOK and
     cooldownOK

if buySignal or sellSignal
    lastSignalBar := bar_index


// ============================================================================
// 19. TREND STATE
// ============================================================================

bullTrend = src > atrTrailingStop

bearTrend = src < atrTrailingStop

trendColor =
     bullTrend
     ? color.green
     : bearTrend
     ? color.red
     : color.gray


// ============================================================================
// 20. SIGNAL LABELS
// ============================================================================

plotshape(
     showSignals and buySignal,
     title = "Buy Signal",
     text = "Buy",
     style = shape.labelup,
     location = location.belowbar,
     color = color.green,
     textcolor = color.white,
     size = size.tiny
     )

plotshape(
     showSignals and sellSignal,
     title = "Sell Signal",
     text = "Sell",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.red,
     textcolor = color.white,
     size = size.tiny
     )


// ============================================================================
// 21. ATR TRAILING STOP
// ============================================================================

plot(
     showTrailingStop
     ? atrTrailingStop
     : na,
     title = "ATR Trailing Stop",
     color = trendColor,
     linewidth = 2,
     style = plot.style_linebr
     )


// ============================================================================
// 22. EMA
// ============================================================================

plot(
     showEMA
     ? trendEMA
     : na,
     title = "Trend EMA",
     color = color.orange,
     linewidth = 2
     )


// ============================================================================
// 23. TREND BACKGROUND
// ============================================================================

backgroundColor =
     bullTrend
     ? color.new(color.green, 93)
     : bearTrend
     ? color.new(color.red, 93)
     : na

bgcolor(
     showTrendBackground
     ? backgroundColor
     : na
     )


// ============================================================================
// 24. INFORMATION DASHBOARD
// ============================================================================

var table dashboard = table.new(
     position.top_right,
     2,
     6,
     border_width = 1
     )

if barstate.islast and showDashboard

    stateText =
         bullTrend
         ? "BULLISH"
         : bearTrend
         ? "BEARISH"
         : "NEUTRAL"

    stateBackground =
         bullTrend
         ? color.new(color.green, 20)
         : bearTrend
         ? color.new(color.red, 20)
         : color.new(color.gray, 40)

    filterText =
         longFiltersOK
         ? "LONG READY"
         : shortFiltersOK
         ? "SHORT READY"
         : "WAIT"

    filterBackground =
         longFiltersOK
         ? color.new(color.green, 30)
         : shortFiltersOK
         ? color.new(color.red, 30)
         : color.new(color.gray, 50)

    table.cell(
         dashboard,
         0,
         0,
         "ATR Pulse",
         text_color = color.white,
         bgcolor = color.rgb(35, 35, 35)
         )

    table.cell(
         dashboard,
         1,
         0,
         stateText,
         text_color = color.white,
         bgcolor = stateBackground
         )

    table.cell(
         dashboard,
         0,
         1,
         "ATR",
         text_color = color.white,
         bgcolor = color.rgb(55, 55, 55)
         )

    table.cell(
         dashboard,
         1,
         1,
         str.tostring(atrValue, format.mintick),
         text_color = color.white,
         bgcolor = color.rgb(35, 35, 35)
         )

    table.cell(
         dashboard,
         0,
         2,
         "ADX",
         text_color = color.white,
         bgcolor = color.rgb(55, 55, 55)
         )

    table.cell(
         dashboard,
         1,
         2,
         str.tostring(adxValue, "#.0"),
         text_color = color.white,
         bgcolor = color.rgb(35, 35, 35)
         )

    table.cell(
         dashboard,
         0,
         3,
         "RSI",
         text_color = color.white,
         bgcolor = color.rgb(55, 55, 55)
         )

    table.cell(
         dashboard,
         1,
         3,
         str.tostring(rsiValue, "#.0"),
         text_color = color.white,
         bgcolor = color.rgb(35, 35, 35)
         )

    table.cell(
         dashboard,
         0,
         4,
         "Sensitivity",
         text_color = color.white,
         bgcolor = color.rgb(55, 55, 55)
         )

    table.cell(
         dashboard,
         1,
         4,
         str.tostring(sensitivity, "#.##"),
         text_color = color.white,
         bgcolor = color.rgb(35, 35, 35)
         )

    table.cell(
         dashboard,
         0,
         5,
         "Signal Filters",
         text_color = color.white,
         bgcolor = color.rgb(55, 55, 55)
         )

    table.cell(
         dashboard,
         1,
         5,
         filterText,
         text_color = color.white,
         bgcolor = filterBackground
         )


// ============================================================================
// 25. ALERTS
// ============================================================================

alertcondition(
     buySignal,
     title = "ATR Pulse Buy",
     message = "ATR Pulse BUY | {{ticker}} | {{interval}} | Close: {{close}}"
     )

alertcondition(
     sellSignal,
     title = "ATR Pulse Sell",
     message = "ATR Pulse SELL | {{ticker}} | {{interval}} | Close: {{close}}"
     )
````
