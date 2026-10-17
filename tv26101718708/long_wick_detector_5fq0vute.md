# Long Wick Detector

- url: https://www.tradingview.com/script/5fQ0VuTE-Long-Wick-Detector/
- type: indicator
- pine_id: PUB;229b2b6f5457459693438cf6b237f537
- version: 1.0

## Description

This indicator is for traders who want a simple quick way to spot long-wick candle. 

The Long Wick Detector is a simple candlestick-based indicator designed to highlight candles with long upper or lower wicks. These candles often represent strong rejection from a price level and may appear near potential reversal areas, support/resistance zones, liquidity sweeps, or exhaustion points.

[b]The indicator marks:[/b]

[list]
[*]Long Upper Wicks with a red downward triangle above the candle
[*]Long Lower Wicks with a green upward triangle below the candle
[/list]

It can also optionally color the candle red or green when a valid signal appears.

[b]How It Works[/b]

This indicator checks each candle using three main filters:

[b]1. Wick Size Compared to Body[/b]

The script compares the wick size to the candle body.

For example, if the setting is:

[b]Wick >= 1.4 × Body[/b]

then the wick must be at least 1.4 times larger than the candle body to qualify.

This helps identify candles where rejection is meaningfully larger than the body.

[b]2. Wick Percentage of Total Candle Range[/b]

The script also checks how much of the total candle range is made up by the wick.

For example, if the setting is:

[b]Minimum Wick % of Candle Range = 50%[/b]

then the wick must represent at least half of the full candle range from high to low.

This helps filter out candles where the wick is large compared to the body but still not dominant in the full candle structure.

[b]3. ATR-Based Candle Range Filter[/b]

The script uses ATR to make sure the candle range is significant relative to recent volatility. This helps avoid weak or insignificant candles during low-volatility periods.

For example, if the setting is:

[b]Minimum Candle Range = ATR × 1.1[/b]

then the candle’s total range must be at least 1.1 times the current ATR value.

[b]Trend Bias Filter[/b]

The indicator includes an optional Preceding Trend Bias Filter.

When enabled, the script only shows signals that appear after a directional move:

[list]
[*]A long upper wick is shown only after a preceding uptrend
[*]A long lower wick is shown only after a preceding downtrend
[/list]

This makes the indicator more focused on potential reversal-style wick signals.

The trend bias can be calculated using one of three methods:

[b]EMA[/b]

Uses an Exponential Moving Average.

[list]
[*]Previous close above the EMA = uptrend
[*]Previous close below the EMA = downtrend
[/list]

[b]SMA[/b]

Uses a Simple Moving Average.

[list]
[*]Previous close above the SMA = uptrend
[*]Previous close below the SMA = downtrend
[/list]

[b]Price Action[/b]

Compares the previous candle close to the close from the selected lookback length.

[list]
[*]Previous close above the close from N bars ago = uptrend
[*]Previous close below the close from N bars ago = downtrend
[/list]

[b]Signal Meaning[/b]

[b]Red Down Triangle — Long Upper Wick[/b]

A red downward triangle above the candle means the candle has a significant upper wick.

This may suggest that price pushed higher but was rejected before the candle closed. Traders often interpret this as possible selling pressure, especially near resistance, supply zones, previous highs, or after an extended upward move.

[b]Green Up Triangle — Long Lower Wick[/b]

A green upward triangle below the candle means the candle has a significant lower wick.

This may suggest that price pushed lower but was rejected before the candle closed. Traders often interpret this as possible buying pressure, especially near support, demand zones, previous lows, or after an extended downward move.

[b]Recommended Use[/b]

This indicator is best used as a confirmation or filtering tool, not as a standalone trading system.

It may be useful for identifying:

[list]
[*]Potential reversal candles
[*]Liquidity grabs or stop hunts
[*]Rejection from support or resistance
[*]Exhaustion candles after strong moves
[*]Possible entry confirmation near key levels
[/list]

For stronger analysis, consider combining it with:

[list]
[*]Support and resistance
[*]Trend structure
[*]Market sessions
[*]Higher-timeframe bias
[*]Volume
[*]Risk management rules
[/list]

[b]Input Settings[/b]

[b]Wick >= X × Body[/b]

Controls how much larger the wick must be compared to the candle body.

Higher values produce fewer but stricter signals.

[b]Minimum Wick % of Candle Range[/b]

Controls the minimum percentage of the full candle range that must be made up by the wick.

Higher values require the wick to dominate more of the candle.

[b]Minimum Candle Range = ATR ×[/b]

Controls how large the full candle must be compared to ATR.

Higher values filter out smaller candles and show only stronger volatility candles.

[b]ATR Length[/b]

Controls the ATR calculation period.

A common default is 14.

[b]Require Preceding Trend Bias[/b]

When enabled, signals must appear after a preceding directional trend.

When disabled, the indicator will detect long wick candles regardless of prior trend direction.

[b]Bias Definition Method[/b]

Controls how the script defines the preceding trend.

Options:

[list]
[*]EMA
[*]SMA
[*]Price Action
[/list]

[b]Lookback Length for Bias[/b]

Controls the moving average length or price action comparison length used for the trend bias filter.

[b]Alerts[/b]

The script includes alert conditions for both signal types:

[list]
[*]Long Upper Wick detected
[*]Long Lower Wick detected
[/list]

Users can create TradingView alerts from the indicator to receive notifications when either condition appears.

[b]Important Note[/b]

A long wick does not guarantee a reversal. It only shows that price was rejected from part of the candle’s range.

Signals should be confirmed with market context, structure and proper risk management.

This indicator does not provide financial advice and should be used for educational and analytical purposes only.

## Source Code

````pine
//@version=6
indicator("Long Wick Detector", overlay=true)

// Settings - Wick Detection
wickBodyMultiplier = input.float(1.4, "Wick >= X × Body", step=0.1, group="Wick Criteria")
minWickPercent     = input.float(50.0, "Minimum Wick % of Candle Range", minval=1, maxval=100, group="Wick Criteria")
atrMultiplier      = input.float(1.1, "Minimum Candle Range = ATR ×", step=0.1, group="Wick Criteria")
atrLength          = input.int(14, "ATR Length", group="Wick Criteria")

// Settings - Directional Bias Filter
useTrendBias = input.bool(true, "Require Preceding Trend Bias", group="Trend Bias Filter")
biasMethod   = input.string("EMA", "Bias Definition Method", options=["EMA", "SMA", "Price Action"], group="Trend Bias Filter")
biasLength   = input.int(20, "Lookback Length for Bias", group="Trend Bias Filter")

// Candle measurements
body        = math.abs(close - open)
candleRange = high - low
upperWick   = high - math.max(open, close)
lowerWick   = math.min(open, close) - low

// ATR filter
atr = ta.atr(atrLength)
significantRange = candleRange >= atr * atrMultiplier

// Wick percentage of total range
upperWickPct = candleRange > 0 ? (upperWick / candleRange) * 100 : 0
lowerWickPct = candleRange > 0 ? (lowerWick / candleRange) * 100 : 0

// Directional Bias Logic
maEMA = ta.ema(close, biasLength)
maSMA = ta.sma(close, biasLength)

// Determine if we are in an uptrend or downtrend based on the PREVIOUS candle
bool isUptrend = false
bool isDowntrend = false

switch biasMethod
    "EMA" =>
        isUptrend   := close[1] > maEMA[1]
        isDowntrend := close[1] < maEMA[1]
    "SMA" =>
        isUptrend   := close[1] > maSMA[1]
        isDowntrend := close[1] < maSMA[1]
    "Price Action" =>
        isUptrend   := close[1] > close[biasLength]
        isDowntrend := close[1] < close[biasLength]

// Filter conditions
// Bearish reversal signal: long upper wick after preceding uptrend
validUpperWickBias = not useTrendBias or isUptrend

// Bullish reversal signal: long lower wick after preceding downtrend
validLowerWickBias = not useTrendBias or isDowntrend

// Base Wick Conditions
baseUpperWick = candleRange > 0 and upperWick >= body * wickBodyMultiplier and upperWickPct >= minWickPercent and significantRange
baseLowerWick = candleRange > 0 and lowerWick >= body * wickBodyMultiplier and lowerWickPct >= minWickPercent and significantRange

// Final Conditions
longUpperWick = baseUpperWick and validUpperWickBias
longLowerWick = baseLowerWick and validLowerWickBias

// Plot signals
plotshape(
     longUpperWick,
     title="Long Upper Wick",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.red,
     size=size.small)

plotshape(
     longLowerWick,
     title="Long Lower Wick",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.small)

// Optional candle coloring
barcolor(
     longUpperWick ? color.red :
     longLowerWick ? color.lime :
     na)

// Alerts
alertcondition(
     longUpperWick,
     title="Long Upper Wick",
     message="Long upper wick detected on {{ticker}} {{interval}}")

alertcondition(
     longLowerWick,
     title="Long Lower Wick",
     message="Long lower wick detected on {{ticker}} {{interval}}")
````
