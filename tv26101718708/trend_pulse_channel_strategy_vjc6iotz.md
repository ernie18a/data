# Trend Pulse Channel Strategy

- url: https://www.tradingview.com/script/vJc6IOTz-Trend-Pulse-Channel-Strategy/
- type: strategy
- pine_id: PUB;83d6be3cc9d84d35998c7326477049a2
- version: 2.0

## Description

Trend Pulse Channel Strategy

Trend Pulse Channel Strategy is an educational trend-following strategy designed to study breakout entries above an adaptive multi-pole price channel.

The strategy builds a smoothed trend filter from the selected source price and then creates an upper and lower channel using a filtered true-range calculation. The goal is to study whether price breaking above the upper channel can represent bullish trend expansion, and whether price falling back below the upper channel can be used as an exit condition.

This script is a strategy for research, backtesting, and forward-testing only. It is not financial advice, does not predict future price movement, and does not guarantee profitable results. Historical strategy results are hypothetical and can differ from live trading because of slippage, commissions, liquidity, spread, execution quality, timeframe selection, and market regime changes.

Core concept

The strategy is built around a smoothed adaptive channel.

The center line is a filtered version of the selected source price. The upper and lower bands are calculated by adding and subtracting a filtered true-range value multiplied by the selected range multiplier.

The channel is intended to provide a dynamic trend structure:

* The center filter represents the main smoothed trend path.
* The upper band represents upside expansion beyond the filtered trend.
* The lower band represents downside expansion below the filtered trend.
* The channel fill helps visualize the active trend zone.

Strategy logic

The strategy is long-only.

A long entry occurs when price closes above the upper channel band during the selected date range.

A long exit occurs when price closes back below the upper channel band during the selected date range.

The strategy does not open short positions.

The logic is intentionally simple so that users can evaluate how channel breakouts behave across different symbols, timeframes, and market conditions.

Main components

1. Adaptive multi-pole filter

The script uses a multi-pole smoothing structure to calculate the main trend filter.

The Poles input controls how many smoothing stages are applied. A higher number of poles generally produces a smoother filter, while a lower value reacts faster.

2. Period

The Period input controls the main smoothing length used by the filter calculation.

A shorter period makes the channel more responsive but may increase noise and false breakouts. A longer period makes the channel smoother but may react more slowly to trend changes.

3. Range multiplier

The Range Multiplier controls the distance between the center filter and the upper/lower bands.

A larger multiplier creates a wider channel and usually fewer breakout entries. A smaller multiplier creates a tighter channel and usually more frequent signals.

4. Reduced Lag mode

Reduced Lag mode attempts to make the source and true-range inputs more responsive by applying a lag-reduction adjustment before filtering.

This can make the channel react faster, but it may also increase sensitivity and noise.

5. Fast Response mode

Fast Response mode blends the multi-pole filter with a faster single-pole version.

This is designed to make the channel respond more quickly to price movement, but it may also increase whipsaws in sideways markets.

Visual elements

The script plots:

* The main trend filter.
* The upper channel band.
* The lower channel band.
* A filled channel area.
* Colored bars based on price behavior relative to the filter and bands.
* A strategy equity line in the data window / chart display.

The filter and channel color change according to the filter slope:

* Green tones indicate a rising filter.
* Red tones indicate a falling filter.
* Gray indicates a flat or neutral condition.

Bar coloring

The script colors bars according to price behavior relative to the filter and channel:

* Strong bullish bars appear when price advances above the filter or upper band.
* Weaker bullish bars appear when price remains above the filter but shows less upside pressure.
* Bearish bars appear when price falls below the filter or lower band.
* Neutral bars appear when conditions are mixed.

These colors are visual aids only. They are not separate trade signals by themselves.

Default strategy properties

The script uses the following default strategy properties:

* Initial capital: 10,000
* Position sizing: percent of equity
* Default order size: 10% of equity
* Commission: 0.1%
* Slippage: 1 tick
* Fill orders on standard OHLC: enabled
* Long-only execution

These settings are included for backtesting convenience. Users should adjust commission, slippage, order size, and test range to match the market and broker conditions they are trying to model.

Backtesting note

TradingView strategy results are simulations based on historical bar data. They are not live trading results.

Results can change significantly depending on:

* Symbol.
* Timeframe.
* Date range.
* Liquidity.
* Spread.
* Commission.
* Slippage.
* Source price.
* Number of poles.
* Filter period.
* Range multiplier.
* Reduced Lag mode.
* Fast Response mode.
* Market trend strength.
* Sideways or choppy conditions.

Users should test the strategy across a sufficiently large sample of trades and across different market regimes before drawing conclusions.

How to use it

A practical workflow is:

1. Select the symbol and timeframe to test.
2. Use a realistic date range that includes trending and sideways market conditions.
3. Review the number of trades before evaluating performance.
4. Adjust commission and slippage to match the market being tested.
5. Test the default settings first.
6. Compare results with Reduced Lag mode on and off.
7. Compare results with Fast Response mode on and off.
8. Adjust the Range Multiplier to control channel sensitivity.
9. Forward-test before considering any real-world use.

Inputs

Date Range

* Start Date: first date included in the backtest.
* End Date: last date included in the backtest.

Source

* Source: price input used by the filter. The default is HLC3.

Channel Settings

* Poles: number of smoothing stages used in the filter.
* Period: main smoothing period.
* Range Multiplier: controls the distance of the upper and lower channel bands.

Response Modes

* Reduced Lag: applies a lag-reduction adjustment before filtering.
* Fast Response: blends the multi-pole filter with a faster single-pole version.

Limitations

This strategy is long-only and does not evaluate short trades.

The strategy does not use a fixed stop-loss, fixed take-profit, trailing stop, or volatility-based exit. Exits are based on price crossing back below the upper channel band.

Channel breakout systems can perform poorly in sideways, choppy, or low-volatility markets.

A close above the upper band does not guarantee trend continuation.

A close below the upper band does not guarantee that the trend has ended.

The adaptive filter is based on historical price and true range, so it is lagging by nature.

Changing the period, poles, multiplier, lag mode, or fast mode can materially change backtest results.

Recommended use

Trend Pulse Channel Strategy is best used as an educational framework for studying adaptive channel breakouts and trend-following behavior.

It should be used with realistic backtesting assumptions, conservative position sizing, and independent validation before any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
strategy("Trend Pulse Channel Strategy", overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=33,
     commission_type=strategy.commission.percent,
     commission_value=0.1,
     slippage=1,
     margin_long=0,
     margin_short=0,
     fill_orders_on_standard_ohlc=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Constant default dates for input.time()
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const int DEFAULT_START_DATE = 1514764800000   // 2018-01-01 00:00 UTC
const int DEFAULT_END_DATE   = 3155759940000   // 2069-12-31 23:59 UTC

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Groups
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDate    = "① BACKTEST DATE RANGE"
groupCore    = "② CHANNEL ENGINE"
groupVisual  = "③ VISUAL SETTINGS"
groupSignals = "④ SIGNAL SETTINGS"
groupStats   = "⑤ DATA WINDOW STATS"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Date Range
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
startDate = input.time(
     DEFAULT_START_DATE,
     "Start Date",
     group=groupDate,
     tooltip="The first date allowed for strategy entries. Signals before this date are ignored by the strategy.")

endDate = input.time(
     DEFAULT_END_DATE,
     "End Date",
     group=groupDate,
     tooltip="The last date allowed for strategy entries. Signals after this date are ignored by the strategy.")

inDateRange = time >= startDate and time <= endDate

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
src = input.source(
     hlc3,
     "Source",
     group=groupCore,
     tooltip="The price source used by the channel calculation. HLC3 averages High, Low, and Close, which makes the channel smoother than using Close only.")

poles = input.int(
     4,
     "Poles",
     minval=1,
     maxval=9,
     group=groupCore,
     tooltip="Controls the depth of the smoothing filter. Higher values create a smoother channel but may react slower to sudden price changes.")

period = input.int(
     144,
     "Period",
     minval=2,
     group=groupCore,
     tooltip="The main smoothing period of the channel. Higher values make the channel slower and smoother. Lower values make it faster and more sensitive.")

mult = input.float(
     1.414,
     "Range Multiplier",
     minval=0,
     step=0.001,
     group=groupCore,
     tooltip="Controls the distance between the upper and lower channel bands. Higher values create a wider channel and fewer breakouts. Lower values create a tighter channel and more signals.")

lagMode = input.bool(
     false,
     "Reduced Lag",
     group=groupCore,
     tooltip="Attempts to reduce channel lag by adjusting the input data before filtering. This can make the channel respond faster, but may also make it more sensitive.")

fastMode = input.bool(
     false,
     "Fast Response",
     group=groupCore,
     tooltip="Blends the main filtered channel with a faster single-pole version. This makes the channel react faster, but it may also increase noise.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visual Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
visualPreset = input.string(
     "Signal",
     "Visual Preset",
     options=["Clean", "Signal", "Full"],
     group=groupVisual,
     tooltip="Clean: channel only. Signal: channel with entry/exit markers. Full: channel, markers, and optional candle coloring.")

showChannel = input.bool(
     true,
     "Show Channel",
     group=groupVisual,
     tooltip="Shows or hides the main channel lines: middle filter, upper band, and lower band.")

showChannelFill = input.bool(
     true,
     "Show Channel Fill",
     group=groupVisual,
     tooltip="Fills the area between the upper and lower bands. Disable it if you want a cleaner chart.")

filterWidth = input.int(
     3,
     "Middle Line Width",
     minval=1,
     maxval=5,
     group=groupVisual,
     tooltip="Thickness of the middle filter line. A wider middle line makes the main trend direction easier to see.")

bandWidth = input.int(
     1,
     "Band Line Width",
     minval=1,
     maxval=4,
     group=groupVisual,
     tooltip="Thickness of the upper and lower channel bands. Lower values reduce visual clutter.")

bandTransparency = input.int(
     40,
     "Band Line Transparency",
     minval=0,
     maxval=100,
     group=groupVisual,
     tooltip="Transparency of the upper and lower channel bands. Higher values make the bands lighter. 0 is fully visible, 100 is invisible.")

fillTransparency = input.int(
     93,
     "Channel Fill Transparency",
     minval=0,
     maxval=100,
     group=groupVisual,
     tooltip="Transparency of the channel fill. Higher values make the shaded area lighter and less distracting.")

barColorMode = input.string(
     "Off",
     "Candle Coloring",
     options=["Off", "Trend-aware"],
     group=groupVisual,
     tooltip="Off keeps the original chart candles. Trend-aware colors candles based on their position relative to the channel and price direction.")

bullColor = input.color(
     #00e676,
     "Bullish Channel Color",
     group=groupVisual,
     tooltip="Color used when the channel filter is rising. It also colors bullish visual channel elements.")

bearColor = input.color(
     #ff1744,
     "Bearish Channel Color",
     group=groupVisual,
     tooltip="Color used when the channel filter is falling. It also colors bearish visual channel elements.")

neutralColor = input.color(
     #cccccc,
     "Neutral Channel Color",
     group=groupVisual,
     tooltip="Color used when the channel is flat or when there is no clear slope direction.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showSignalsInput = input.bool(
     true,
     "Show Entry / Exit Markers",
     group=groupSignals,
     tooltip="Shows only two custom visual markers: one for entry and one for exit. These are separate from TradingView's default strategy trade markers.")

signalAtrOffset = input.float(
     0.85,
     "Signal Distance ATR",
     minval=0.10,
     step=0.05,
     group=groupSignals,
     tooltip="Controls how far the markers are placed away from candles using ATR. Higher values move the markers farther away from price.")

signalChannelOffset = input.float(
     0.35,
     "Signal Channel Clearance",
     minval=0.00,
     step=0.05,
     group=groupSignals,
     tooltip="Adds extra distance based on channel width. This helps prevent entry and exit markers from sticking to the channel.")

longMarkerColor = input.color(
     #00c853,
     "Entry Marker Color",
     group=groupSignals,
     tooltip="Color of the entry marker. Default is green.")

exitMarkerColor = input.color(
     #ff1744,
     "Exit Marker Color",
     group=groupSignals,
     tooltip="Color of the exit marker. Default is red.")

showOnlyConfirmed = input.bool(
     true,
     "Confirm Signals On Bar Close",
     group=groupSignals,
     tooltip="When enabled, visual signals appear only after the candle closes. This reduces intrabar visual noise and avoids premature-looking signals.")

showOnlyStrongSignals = input.bool(
     false,
     "Show Only Strong Visual Signals",
     group=groupSignals,
     tooltip="When enabled, visual markers only appear when the channel slope agrees with the signal. This reduces visual clutter during choppy markets. Strategy orders still follow the main strategy logic.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Data Window Stats Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showEquityData = input.bool(
     true,
     "Show Equity In Data Window",
     group=groupStats,
     tooltip="Shows the strategy equity value in the TradingView Data Window only. It is not plotted visually on the price chart.")

showCagrData = input.bool(
     true,
     "Show CAGR In Data Window",
     group=groupStats,
     tooltip="Shows the calculated CAGR percentage in the TradingView Data Window only.")

showCagrMddData = input.bool(
     true,
     "Show CAGR / Max Drawdown In Data Window",
     group=groupStats,
     tooltip="Shows the CAGR-to-Max-Drawdown ratio in the TradingView Data Window only. This is useful for strategy quality review without adding visual clutter.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Calculate Alpha
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pi    = math.asin(1) * 2
beta  = (1 - math.cos(2 * pi / period)) / (math.pow(1.414, 2 / poles) - 1)
alpha = -beta + math.sqrt(beta * beta + 2 * beta)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Apply Lag Reduction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lag     = lagMode ? int((period - 1) / (2 * poles)) : 0
srcData = lagMode and not na(src[lag]) ? src + (src - src[lag]) : src

tr      = ta.tr(true)
trData  = lagMode and not na(tr[lag]) ? tr + (tr - tr[lag]) : tr

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AI Filter - EMA Approximation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AIFilter(data, a, p) =>
    filterLen = math.max(1, int(math.round(2 / a)))
    result = ta.ema(data, filterLen)

    if p >= 2
        result := ta.ema(result, filterLen)
    if p >= 3
        result := ta.ema(result, filterLen)
    if p >= 4
        result := ta.ema(result, filterLen)
    if p >= 5
        result := ta.ema(result, filterLen)
    if p >= 6
        result := ta.ema(result, filterLen)
    if p >= 7
        result := ta.ema(result, filterLen)
    if p >= 8
        result := ta.ema(result, filterLen)
    if p >= 9
        result := ta.ema(result, filterLen)

    result

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Apply Filter
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
filt   = AIFilter(srcData, alpha, poles)
filtTR = AIFilter(trData,  alpha, poles)

if fastMode
    filt1   = AIFilter(srcData, alpha, 1)
    filtTR1 = AIFilter(trData,  alpha, 1)
    filt    := (filt + filt1) / 2
    filtTR  := (filtTR + filtTR1) / 2

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bands
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
upper = filt + filtTR * mult
lower = filt - filtTR * mult

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendColor = filt > filt[1] ? bullColor : filt < filt[1] ? bearColor : neutralColor

barCol = src > src[1] and src > filt and src < upper ? color.new(bullColor, 0) :
         src > src[1] and src >= upper ? color.new(bullColor, 0) :
         src <= src[1] and src > filt ? color.new(bullColor, 35) :
         src < src[1] and src < filt and src > lower ? color.new(bearColor, 0) :
         src < src[1] and src <= lower ? color.new(bearColor, 0) :
         src >= src[1] and src < filt ? color.new(bearColor, 35) :
         neutralColor

useBarColor = barColorMode == "Trend-aware" or visualPreset == "Full"
barcolor(useBarColor ? barCol : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Channel Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotFilter = plot(
     showChannel ? filt : na,
     title="Filter",
     color=trendColor,
     linewidth=filterWidth,
     force_overlay=true)

plotUpper = plot(
     showChannel ? upper : na,
     title="Upper Band",
     color=color.new(trendColor, bandTransparency),
     linewidth=bandWidth,
     force_overlay=true)

plotLower = plot(
     showChannel ? lower : na,
     title="Lower Band",
     color=color.new(trendColor, bandTransparency),
     linewidth=bandWidth,
     force_overlay=true)

fill(
     plotUpper,
     plotLower,
     color=showChannel and showChannelFill ? color.new(trendColor, fillTransparency) : na,
     title="Channel Fill")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Strategy Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rawLongSignal = ta.crossover(close, upper) and inDateRange
rawExitSignal = ta.crossunder(close, upper) and inDateRange

confirmedOk = showOnlyConfirmed ? barstate.isconfirmed : true

longSignal = rawLongSignal and confirmedOk
exitSignal = rawExitSignal and confirmedOk

if longSignal
    strategy.entry("L", strategy.long, comment="", alert_message="Long entry")

if exitSignal
    strategy.close("L", comment="", alert_message="Long exit")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visual Signal Filtering
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
strongLongVisual = not showOnlyStrongSignals or filt > filt[1]
strongExitVisual = not showOnlyStrongSignals or filt < filt[1] or close < filt

showSignals = showSignalsInput and visualPreset != "Clean"

visualLongSignal = showSignals and longSignal and strongLongVisual
visualExitSignal = showSignals and exitSignal and strongExitVisual

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Cleaner Signal Placement
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atrValue     = ta.atr(14)
channelWidth = math.abs(upper - lower)

// Stronger default offset so markers do not stick to candles or channel.
signalOffset = math.max(atrValue * signalAtrOffset, channelWidth * signalChannelOffset)

// Entry is below both candle and lower band.
// Exit is above both candle and upper band.
longMarkerY = visualLongSignal ? math.min(low, lower) - signalOffset : na
exitMarkerY = visualExitSignal ? math.max(high, upper) + signalOffset : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Only two custom marker plots in Style:
// 1) Entry Marker
// 2) Exit Marker
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     longMarkerY,
     title="Entry Marker",
     style=shape.triangleup,
     location=location.absolute,
     color=longMarkerColor,
     size=size.tiny)

plotshape(
     exitMarkerY,
     title="Exit Marker",
     style=shape.triangledown,
     location=location.absolute,
     color=exitMarkerColor,
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CAGR / Max Drawdown - Data Window Only
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
msPerYear = 365.25 * 24 * 60 * 60 * 1000
finalTs   = time
years     = float(finalTs - startDate) / msPerYear

cagr = years > 0 ? math.pow(strategy.equity / strategy.initial_capital, 1 / years) - 1 : na

cagrByMddRatio = na(strategy.max_drawdown_percent) or strategy.max_drawdown_percent == 0 ? na : (cagr * 100) / strategy.max_drawdown_percent

plot(
     showEquityData ? strategy.equity : na,
     title="Equity Line",
     display=display.data_window,
     color=color.black)

plot(
     showCagrData ? cagr * 100 : na,
     title="CAGR %",
     display=display.data_window,
     color=color.teal)

plot(
     showCagrMddData ? cagrByMddRatio : na,
     title="CAGR / Max Drawdown Ratio",
     display=display.data_window,
     color=color.red)
````
