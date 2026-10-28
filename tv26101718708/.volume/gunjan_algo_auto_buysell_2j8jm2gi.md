# Gunjan Algo Auto Buy/Sell

- url: https://www.tradingview.com/script/2j8jM2GI-Gunjan-Algo-Auto-Buy-Sell/
- type: indicator
- pine_id: PUB;47a9c7518b0e4a459322463492626f56
- version: 1.0

## Description

# Gunjan Algo Edge All TF

Gunjan Algo Edge All TF is a multi-timeframe adaptive technical-analysis indicator designed to help traders evaluate trend direction, momentum, price structure, and market alignment from a single chart.

Instead of relying on one indicator or one fixed parameter set across every timeframe, the script automatically adapts its core calculation parameters to the active chart timeframe. It supports short-term intraday analysis through higher-timeframe market context, with an integrated MTF dashboard covering 1m, 3m, 5m, 10m, 15m, 30m, 1h, 2h, 3h, 4h, 1D, 1W and 1Mo.

The indicator is intended as a decision-support and market-structure tool. It does not guarantee profitable trades and should not be interpreted as financial or investment advice.

## What makes the indicator different?

The main objective of Gunjan Algo Edge All TF is to combine several independent technical conditions into a structured signal framework rather than generating a signal from a single crossover.

The signal engine evaluates:

* Fast and slow EMA relationship
* EMA direction and momentum
* EMA separation
* RSI momentum
* DMI directional pressure
* ADX trend-quality filter
* VWAP price bias
* Recent price-structure breaks
* Reversal momentum
* Candle quality
* Adaptive noise filtering
* Multi-timeframe signal alignment

The script can operate in three modes:

1. Auto
2. Original 5M
3. Manual

In Auto mode, the indicator changes its calculation parameters according to the active timeframe. The source code contains separate parameter profiles for short-term and higher-timeframe analysis.

## Adaptive timeframe engine

The Auto mode is designed to avoid using exactly the same sensitivity on every timeframe.

For example, the default Auto profiles include:

| Timeframe | Fast EMA | Slow EMA | RSI | DI | ADX Minimum |
| --------- | -------: | -------: | --: | -: | ----------: |
| 1m        |        6 |       13 |   7 |  7 |        21.0 |
| 3m        |        8 |       18 |   8 |  9 |        19.5 |
| 5m        |        9 |       21 |   9 | 10 |        18.0 |
| 10m       |       10 |       24 |  10 | 10 |        18.0 |
| 15m       |       12 |       27 |  10 | 11 |        18.0 |
| 30m       |       15 |       34 |  11 | 12 |        18.0 |
| 1h        |       18 |       40 |  12 | 13 |        18.0 |
| 2h        |       21 |       45 |  13 | 13 |        18.5 |
| 3h        |       23 |       48 |  14 | 14 |        18.5 |
| 4h        |       24 |       50 |  14 | 14 |        19.0 |
| Higher TF |       30 |       60 |  14 | 14 |        20.0 |

These profiles are part of the indicator's adaptive design and are not presented as universally optimal settings.

## Core signal architecture

### 1. EMA momentum

The bullish EMA condition requires the fast EMA to be above the slow EMA and rising.

The bearish condition requires the fast EMA to be below the slow EMA and falling.

This gives the signal engine both directional and momentum information rather than using an EMA crossover alone.

### 2. EMA separation filter

The indicator measures the percentage distance between the fast and slow EMA.

The purpose is to reduce signals when the two averages are excessively compressed and the market may be lacking directional separation.

The separation requirement itself adapts according to timeframe. The 5-minute profile, for example, does not require the same separation threshold used on several other timeframes.

### 3. RSI momentum

The BUY side requires RSI to be above the configured BUY threshold and rising.

The SELL side requires RSI to be below the configured SELL threshold and falling.

The default thresholds are:

* BUY RSI: 52
* SELL RSI: 48

These are momentum thresholds rather than traditional overbought/oversold levels.

### 4. DMI directional pressure

The indicator compares +DI and -DI.

* +DI > -DI supports bullish conditions.
* -DI > +DI supports bearish conditions.

This provides directional confirmation to the trend and momentum calculations.

### 5. ADX trend-quality filter

ADX is used as a minimum trend-quality filter.

A signal is permitted only when ADX reaches the adaptive minimum for the selected timeframe.

This is intended to reduce signals during conditions where directional movement may be too weak.

### 6. VWAP bias

The indicator uses VWAP as another contextual filter.

Bullish conditions favor price trading above VWAP or demonstrating bullish price/EMA behavior.

Bearish conditions favor price trading below VWAP or demonstrating bearish price/EMA behavior.

VWAP therefore acts as a contextual market-bias component rather than being used as a standalone entry trigger.

### 7. Price structure

The indicator evaluates the recent high and low over its adaptive structure lookback.

A bullish structure condition occurs when the confirmed closing price breaks above the recent high.

A bearish structure condition occurs when the confirmed closing price breaks below the recent low.

### 8. Reversal momentum

The script also has a second signal route designed to identify developing directional changes.

It monitors:

* RSI crossing its configured threshold
* DMI directional crossover
* Price position relative to the fast EMA
* Directional DMI confirmation
* RSI position relative to 50

This creates a second route for signals when momentum changes before a conventional structure-break setup becomes available.

## BUY signal logic

The BUY engine has two principal routes.

### Route 1 — Trend/structure confirmation

A BUY setup can develop when:

* Recent structure breaks upward
* EMA momentum is bullish
* RSI momentum is bullish
* DMI is bullish

The broader signal then additionally requires trend quality, VWAP confirmation, candle quality, EMA separation and noise filtering.

### Route 2 — Reversal/momentum confirmation

A BUY setup can also develop when:

* RSI or DMI shows a bullish reversal event
* Price is above the fast EMA
* DMI confirms bullish direction
* RSI is above 50

Again, the broader filters must agree before the final BUY signal is produced.

The actual source code combines these routes with trend-quality, VWAP, candle, EMA-separation and noise conditions.

## SELL signal logic

The SELL engine mirrors the BUY framework.

### Route 1 — Trend/structure confirmation

A SELL setup can develop when:

* Recent structure breaks downward
* EMA momentum is bearish
* RSI momentum is bearish
* DMI is bearish

### Route 2 — Reversal/momentum confirmation

A SELL setup can develop when:

* RSI or DMI produces a bearish reversal event
* Price is below the fast EMA
* DMI confirms bearish direction
* RSI is below 50

The broader SELL filters must also agree before the final signal is displayed.

## Signal confirmation

Signals are generated only on confirmed bars.

The script also maintains a signal state so that it does not continuously print the same BUY or SELL label on every qualifying candle.

The chart therefore focuses on directional transitions rather than repeatedly printing identical labels.

## How to read the chart

The indicator displays:

* Green BUY label = bullish signal
* Red SELL label = bearish signal

The chart labels are deliberately simple so that the underlying price action remains visible.

### Example 1 — Bullish trend continuation

Imagine the following sequence on a 5-minute chart:

1. Price is trading above VWAP.
2. Fast EMA is above slow EMA and rising.
3. RSI moves above the BUY threshold and continues rising.
4. +DI moves above -DI.
5. ADX is above the required minimum.
6. Price breaks the recent structure high.
7. A bullish candle closes with sufficient strength.

If the remaining filters agree, the indicator can print:

BUY

This should be interpreted as a bullish technical alignment, not as a guarantee that price will continue higher.

### Example 2 — Bearish trend continuation

Imagine the opposite sequence:

1. Price trades below VWAP.
2. Fast EMA is below slow EMA and falling.
3. RSI moves below the SELL threshold.
4. -DI exceeds +DI.
5. ADX satisfies the timeframe requirement.
6. Price breaks recent structure support.
7. A bearish candle closes with sufficient strength.

The indicator can then print:

SELL

Again, the signal represents technical conditions detected by the indicator and not a guaranteed future outcome.

### Example 3 — Reversal setup

Suppose price has been declining but momentum begins to change.

RSI crosses upward through its BUY threshold, +DI crosses above -DI, price moves above the fast EMA, and RSI moves above 50.

If the trend-quality, VWAP, candle, separation and noise filters also agree, the reversal route can generate a BUY signal.

The same concept applies in reverse for bearish reversals.

## Multi-timeframe dashboard

One of the main features of Gunjan Algo Edge All TF is its MTF dashboard.

The dashboard evaluates the indicator's signal framework across:

1m | 3m | 5m | 10m | 15m | 30m | 1h | 2h | 3h | 4h | 1D | 1W | 1Mo

The dashboard uses:

* B = BUY
* S = SELL
* — = NO SIGNAL

It also calculates an overall directional bias from the active timeframe signals.

### Dashboard example

A hypothetical dashboard could look like:

| 1m | 3m | 5m | 10m | 15m | 30m | 1h | 2h | 4h | 1D | Bias |
| -- | -- | -- | --- | --- | --- | -- | -- | -- | -- | ---- |
| B  | B  | B  | B   | B   | B   | B  | —  | B  | B  | BUY  |

In this example, the lower and higher timeframes are generally aligned bullishly.

A different example:

| 1m | 3m | 5m | 10m | 15m | 30m | 1h | 2h | 4h | 1D | Bias  |
| -- | -- | -- | --- | --- | --- | -- | -- | -- | -- | ----- |
| S  | B  | S  | —   | B   | —   | B  | B  | S  | B  | MIXED |

This indicates conflicting timeframe information.

A MIXED condition should generally be treated as a warning that the market does not have strong multi-timeframe agreement.

## Overall bias

The dashboard calculates the proportion of active BUY and SELL signals across its monitored timeframes.

The displayed bias is classified as:

* STRONG BUY
* BUY
* MIXED
* SELL
* STRONG SELL
* NO SIGNAL

The current implementation uses an 80% threshold for STRONG BUY/STRONG SELL and a 60% threshold for BUY/SELL.

The overall bias is a summary of the indicator's multi-timeframe technical state. It is not a prediction of future price.

## Suggested workflow

### Intraday traders

A practical workflow can be:

1. Start with the higher timeframes.
2. Check whether the 1h, 2h, 4h and daily signals generally agree.
3. Move to the intended execution timeframe.
4. Wait for the chart's BUY or SELL signal.
5. Check price structure and market context.
6. Define the trade's invalidation level before entering.
7. Determine position size according to your own risk rules.
8. Use the MTF dashboard as confirmation rather than treating it as an automatic trade command.

### Scalping

For short-term trading, the 1m, 3m and 5m columns can provide faster information, but lower timeframes generally contain more market noise.

Do not assume that a lower-timeframe signal is automatically superior to a higher-timeframe signal.

### Swing analysis

For higher-timeframe analysis, the 4h, daily, weekly and monthly readings can provide broader directional context.

A trader may use the higher timeframe for market bias and a lower timeframe for execution.

## Example decision framework

### Stronger bullish alignment

Higher timeframe: BUY
Execution timeframe: BUY
Lower timeframe: BUY
Price structure: bullish
VWAP context: bullish

Possible interpretation:

"Multiple technical components are aligned bullishly."

This is still not a guarantee of a profitable trade.

### Conflicting alignment

Higher timeframe: SELL
Execution timeframe: BUY
Lower timeframe: BUY

Possible interpretation:

"Short-term momentum is bullish while the broader trend remains bearish."

A trader may choose to wait for greater alignment rather than acting immediately.

## Settings

### Mode

**Auto**

Automatically selects the timeframe-specific parameter profile.

**Original 5M**

Uses the original 5-minute parameter configuration.

**Manual**

Allows the user to specify:

* Fast EMA
* Slow EMA
* RSI length
* DI length
* ADX smoothing
* Structure lookback
* Minimum ADX

The script exposes these controls directly in its settings.

### Adaptive Noise Filter

When enabled, the indicator applies additional directional conditions intended to reduce signals during less favorable price/EMA configurations.

### EMA Separation Filter

When enabled, the indicator requires the EMA relationship to satisfy the timeframe-specific separation condition.

### MTF Dashboard

The dashboard can be enabled/disabled and positioned at:

* Top Right
* Top Left
* Bottom Right
* Bottom Left

The overall bias display can also be enabled or disabled.

## Alerts

The indicator includes alert conditions for BUY and SELL signals.

Users can create TradingView alerts from these conditions and choose their preferred notification method.

Always verify the alert configuration and the selected symbol/timeframe before relying on alerts for live monitoring.

## Repainting and data handling

The MTF calculations use `request.security()` with `lookahead=barmerge.lookahead_off`, which avoids intentionally requesting future values from higher/lower timeframe calculations.

Signals on the current chart are additionally restricted to confirmed bars.

However, traders should understand that any real-time technical indicator can change its developing conditions while the current candle is still forming. For this reason, the published indicator is intended to be interpreted using confirmed signals rather than assuming that an intrabar condition is permanent.

## Recommended chart setup

For a clean TradingView publication:

* Use a standard candlestick chart.
* Keep the Gunjan Algo Edge All TF indicator clearly visible.
* Avoid unnecessary additional indicators on the publication screenshot.
* Show the complete symbol and timeframe.
* Make the BUY/SELL labels clearly visible.
* Keep the MTF dashboard readable.
* Use a chart section where the relationship between price action, signals and dashboard can be understood.

TradingView specifically recommends clean publication charts where the script's output is easy to identify.

## Important limitations

Gunjan Algo Edge All TF is a technical-analysis tool.

It does not:

* Predict the future with certainty.
* Guarantee profitable trades.
* Guarantee a particular win rate.
* Guarantee a particular risk/reward ratio.
* Eliminate losing trades.
* Replace risk management.
* Replace market or instrument-specific analysis.
* Guarantee that every BUY signal will result in a bullish move.
* Guarantee that every SELL signal will result in a bearish move.

Market conditions can change rapidly, and technical signals can fail during news events, volatility shocks, gaps, illiquid periods, sideways markets and other abnormal conditions.

The indicator should therefore be used as one component of a broader trading process.

## Risk management

Before taking any trade, consider:

* Entry price
* Invalidation level
* Stop-loss placement
* Position size
* Maximum acceptable loss
* Transaction costs
* Slippage
* Market liquidity
* Trading-session conditions
* Higher-timeframe context

Never risk capital that you cannot afford to lose.

## House Rules and publication compliance

This publication is written to provide a clear explanation of the indicator's purpose, methodology and usage without making unsupported performance claims.

The description intentionally does not claim a guaranteed win rate, guaranteed profitability, guaranteed accuracy or future performance.

TradingView's Script Publishing Rules require descriptions to explain what a script does, how it works and how traders can use it, while also prohibiting unrealistic or unsubstantiated performance claims.

The indicator should also be published with an original, clean chart and without misleading visual demonstrations. TradingView's House Rules prohibit plagiarism and require published content to be understandable and appropriately described.

If the script contains reused open-source code from another TradingView author, the appropriate author credit and reuse requirements must be satisfied before public publication. TradingView specifically requires attribution and additional conditions when qualifying open-source code is reused.

## Financial disclaimer

This indicator is provided for informational and educational purposes only.

Nothing in this indicator or its description constitutes investment advice, financial advice, a recommendation to buy or sell any security, derivative, cryptocurrency, commodity or other financial instrument, or a guarantee of future results.

Trading involves substantial risk. Past performance or historical behavior does not guarantee future results.

Users are responsible for their own trading decisions, risk management, due diligence and compliance with applicable laws and regulations.

## Final note

Gunjan Algo Edge All TF is best viewed as a structured market-analysis framework.

The goal is not to make every candle produce a signal. The system intentionally combines trend, momentum, structure, volatility/trend quality and multi-timeframe information so that traders can distinguish between directional alignment and conflicting market conditions.

Use the BUY and SELL labels as technical events, use the MTF dashboard as context, and combine the indicator with disciplined risk management and independent analysis.

## Source Code

````pine
//@version=6
indicator("Gunjan Algo Edge All TF", shorttitle="Gunjan Algo ATF", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GUNJAN ALGO EDGE — ALL TIMEFRAME ADAPTIVE ENGINE
//
// MTF DASHBOARD:
// 1m | 3m | 5m | 10m | 15m | 30m | 1h | 2h | 3h | 4h | 1D | 1W | 1Mo
//
// B = BUY
// S = SELL
// — = NO SIGNAL
//
// Overall bias:
// STRONG BUY / BUY / MIXED / SELL / STRONG SELL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mode = input.string(
     "Auto",
     "Mode",
     options=["Auto", "Original 5M", "Manual"]
)

manualFast = input.int(9, "Manual Fast EMA", minval=1)
manualSlow = input.int(21, "Manual Slow EMA", minval=2)

manualRsiLen = input.int(9, "Manual RSI Length", minval=1)

manualDiLen = input.int(10, "Manual DI Length", minval=1)
manualAdxSmooth = input.int(10, "Manual ADX Smoothing", minval=1)

manualStructure = input.int(
     2,
     "Manual Structure Lookback",
     minval=1,
     maxval=10
)

rsiBuy = input.float(
     52.0,
     "BUY RSI",
     step=0.5
)

rsiSell = input.float(
     48.0,
     "SELL RSI",
     step=0.5
)

adxMinBase = input.float(
     18.0,
     "Minimum ADX",
     step=0.5
)

useAdaptiveNoise = input.bool(
     true,
     "Adaptive Noise Filter"
)

useEmaSeparation = input.bool(
     true,
     "EMA Separation Filter"
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showDashboard = input.bool(
     true,
     "Show MTF Dashboard"
)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options=[
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left"
     ]
)

showOverallBias = input.bool(
     true,
     "Show Overall Bias"
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT CHART TIMEFRAME DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

is1M =
     timeframe.isminutes and
     timeframe.multiplier <= 1

is3M =
     timeframe.isminutes and
     timeframe.multiplier > 1 and
     timeframe.multiplier <= 3

is5M =
     timeframe.isminutes and
     timeframe.multiplier == 5

is10M =
     timeframe.isminutes and
     timeframe.multiplier > 5 and
     timeframe.multiplier <= 10

is15M =
     timeframe.isminutes and
     timeframe.multiplier > 10 and
     timeframe.multiplier <= 15

is30M =
     timeframe.isminutes and
     timeframe.multiplier > 15 and
     timeframe.multiplier <= 30

is60M =
     timeframe.isminutes and
     timeframe.multiplier > 30 and
     timeframe.multiplier <= 60

is120M =
     timeframe.isminutes and
     timeframe.multiplier > 60 and
     timeframe.multiplier <= 120

is180M =
     timeframe.isminutes and
     timeframe.multiplier > 120 and
     timeframe.multiplier <= 180

is240M =
     timeframe.isminutes and
     timeframe.multiplier > 180 and
     timeframe.multiplier <= 240


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE PARAMETERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int fastLen = 9
int slowLen = 21
int rsiLen = 9
int diLen = 10
int adxSmooth = 10
int structureBars = 2

float adxMin = adxMinBase

if mode == "Original 5M"

    fastLen := 9
    slowLen := 21
    rsiLen := 9
    diLen := 10
    adxSmooth := 10
    structureBars := 2
    adxMin := 18.0

else if mode == "Manual"

    fastLen := manualFast
    slowLen := manualSlow
    rsiLen := manualRsiLen
    diLen := manualDiLen
    adxSmooth := manualAdxSmooth
    structureBars := manualStructure
    adxMin := adxMinBase

else

    if is1M

        fastLen := 6
        slowLen := 13
        rsiLen := 7
        diLen := 7
        adxSmooth := 7
        structureBars := 3
        adxMin := 21.0

    else if is3M

        fastLen := 8
        slowLen := 18
        rsiLen := 8
        diLen := 9
        adxSmooth := 9
        structureBars := 2
        adxMin := 19.5

    else if is5M

        fastLen := 9
        slowLen := 21
        rsiLen := 9
        diLen := 10
        adxSmooth := 10
        structureBars := 2
        adxMin := 18.0

    else if is10M

        fastLen := 10
        slowLen := 24
        rsiLen := 10
        diLen := 10
        adxSmooth := 10
        structureBars := 2
        adxMin := 18.0

    else if is15M

        fastLen := 12
        slowLen := 27
        rsiLen := 10
        diLen := 11
        adxSmooth := 11
        structureBars := 2
        adxMin := 18.0

    else if is30M

        fastLen := 15
        slowLen := 34
        rsiLen := 11
        diLen := 12
        adxSmooth := 12
        structureBars := 2
        adxMin := 18.0

    else if is60M

        fastLen := 18
        slowLen := 40
        rsiLen := 12
        diLen := 13
        adxSmooth := 13
        structureBars := 2
        adxMin := 18.0

    else if is120M

        fastLen := 21
        slowLen := 45
        rsiLen := 13
        diLen := 13
        adxSmooth := 13
        structureBars := 3
        adxMin := 18.5

    else if is180M

        fastLen := 23
        slowLen := 48
        rsiLen := 14
        diLen := 14
        adxSmooth := 14
        structureBars := 3
        adxMin := 18.5

    else if is240M

        fastLen := 24
        slowLen := 50
        rsiLen := 14
        diLen := 14
        adxSmooth := 14
        structureBars := 3
        adxMin := 19.0

    else

        fastLen := 30
        slowLen := 60
        rsiLen := 14
        diLen := 14
        adxSmooth := 14
        structureBars := 3
        adxMin := 20.0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)

vwapValue = ta.vwap(hlc3)

rsiValue = ta.rsi(close, rsiLen)

[plusDI, minusDI, adxValue] =
     ta.dmi(diLen, adxSmooth)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA MOMENTUM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaBull =
     emaFast > emaSlow and
     emaFast > emaFast[1]

emaBear =
     emaFast < emaSlow and
     emaFast < emaFast[1]


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA SEPARATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaDistance =
     math.abs(emaFast - emaSlow)

emaDistancePct =
     close != 0 ?
     emaDistance / close * 100.0 :
     0.0

emaSeparationRequired =
     is1M ? 0.012 :
     is3M ? 0.010 :
     is5M ? 0.0 :
     is10M ? 0.006 :
     is15M ? 0.008 :
     is30M ? 0.010 :
     is60M ? 0.012 :
     is120M ? 0.013 :
     is180M ? 0.014 :
     is240M ? 0.015 :
     0.020

emaSeparated =
     not useEmaSeparation or
     emaDistancePct >= emaSeparationRequired


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DMI MOMENTUM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dmiBull =
     plusDI > minusDI

dmiBear =
     minusDI > plusDI


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RSI MOMENTUM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rsiBull =
     rsiValue > rsiBuy and
     rsiValue > rsiValue[1]

rsiBear =
     rsiValue < rsiSell and
     rsiValue < rsiValue[1]


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADX QUALITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendQuality =
     adxValue >= adxMin


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP BIAS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vwapBull =
     close > vwapValue or
     close > close[1] and
     close > emaFast

vwapBear =
     close < vwapValue or
     close < close[1] and
     close < emaFast


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

recentHigh =
     ta.highest(high[1], structureBars)

recentLow =
     ta.lowest(low[1], structureBars)

bullBreak =
     close > recentHigh

bearBreak =
     close < recentLow


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REVERSAL MOMENTUM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rsiCrossUp =
     ta.crossover(rsiValue, rsiBuy)

diCrossUp =
     ta.crossover(plusDI, minusDI)

rsiCrossDown =
     ta.crossunder(rsiValue, rsiSell)

diCrossDown =
     ta.crossover(minusDI, plusDI)

bullReversal =
     rsiCrossUp or
     diCrossUp

bearReversal =
     rsiCrossDown or
     diCrossDown


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE QUALITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

candleRange =
     high - low

bullCandle =
     close > open and
     candleRange > 0 and
     close >= high - candleRange * 0.35

bearCandle =
     close < open and
     candleRange > 0 and
     close <= low + candleRange * 0.35


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE NOISE FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullNoiseFilter =
     not useAdaptiveNoise or
     is5M or
     (
         close > emaFast and
         emaFast > emaSlow
     )

bearNoiseFilter =
     not useAdaptiveNoise or
     is5M or
     (
         close < emaFast and
         emaFast < emaSlow
     )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buyRoute1 =
     bullBreak and
     emaBull and
     rsiBull and
     dmiBull

buyRoute2 =
     bullReversal and
     close > emaFast and
     dmiBull and
     rsiValue > 50

buyCondition =
     trendQuality and
     vwapBull and
     bullCandle and
     emaSeparated and
     bullNoiseFilter and
     (buyRoute1 or buyRoute2)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SELL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sellRoute1 =
     bearBreak and
     emaBear and
     rsiBear and
     dmiBear

sellRoute2 =
     bearReversal and
     close < emaFast and
     dmiBear and
     rsiValue < 50

sellCondition =
     trendQuality and
     vwapBear and
     bearCandle and
     emaSeparated and
     bearNoiseFilter and
     (sellRoute1 or sellRoute2)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT CHART SIGNAL STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int lastSignal = 0

buySignal =
     barstate.isconfirmed and
     buyCondition and
     lastSignal != 1

sellSignal =
     barstate.isconfirmed and
     sellCondition and
     lastSignal != -1

if buySignal
    lastSignal := 1

if sellSignal
    lastSignal := -1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ORIGINAL CHART SIGNAL DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     text="BUY",
     textcolor=color.white,
     color=color.green,
     size=size.small
)

plotshape(
     sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     text="SELL",
     textcolor=color.white,
     color=color.red,
     size=size.small
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     buySignal,
     title="Crude BUY",
     message="CRUDE ADAPTIVE BUY"
)

alertcondition(
     sellSignal,
     title="Crude SELL",
     message="CRUDE ADAPTIVE SELL"
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF SIGNAL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_mtfSignal() =>

    mtfIsMinutes = timeframe.isminutes
    mtfMultiplier = timeframe.multiplier

    mtfIs1M =
         mtfIsMinutes and
         mtfMultiplier <= 1

    mtfIs3M =
         mtfIsMinutes and
         mtfMultiplier > 1 and
         mtfMultiplier <= 3

    mtfIs5M =
         mtfIsMinutes and
         mtfMultiplier == 5

    mtfIs10M =
         mtfIsMinutes and
         mtfMultiplier > 5 and
         mtfMultiplier <= 10

    mtfIs15M =
         mtfIsMinutes and
         mtfMultiplier > 10 and
         mtfMultiplier <= 15

    mtfIs30M =
         mtfIsMinutes and
         mtfMultiplier > 15 and
         mtfMultiplier <= 30

    mtfIs60M =
         mtfIsMinutes and
         mtfMultiplier > 30 and
         mtfMultiplier <= 60

    mtfIs120M =
         mtfIsMinutes and
         mtfMultiplier > 60 and
         mtfMultiplier <= 120

    mtfIs180M =
         mtfIsMinutes and
         mtfMultiplier > 120 and
         mtfMultiplier <= 180

    mtfIs240M =
         mtfIsMinutes and
         mtfMultiplier > 180 and
         mtfMultiplier <= 240


    //──────────────────────────────────────────────────────────────────
    // PARAMETERS
    //──────────────────────────────────────────────────────────────────

    int fLen = 9
    int sLen = 21
    int rLen = 9
    int dLen = 10
    int aSmooth = 10
    int sBars = 2

    float aMin = adxMinBase

    if mode == "Original 5M"

        fLen := 9
        sLen := 21
        rLen := 9
        dLen := 10
        aSmooth := 10
        sBars := 2
        aMin := 18.0

    else if mode == "Manual"

        fLen := manualFast
        sLen := manualSlow
        rLen := manualRsiLen
        dLen := manualDiLen
        aSmooth := manualAdxSmooth
        sBars := manualStructure
        aMin := adxMinBase

    else

        if mtfIs1M

            fLen := 6
            sLen := 13
            rLen := 7
            dLen := 7
            aSmooth := 7
            sBars := 3
            aMin := 21.0

        else if mtfIs3M

            fLen := 8
            sLen := 18
            rLen := 8
            dLen := 9
            aSmooth := 9
            sBars := 2
            aMin := 19.5

        else if mtfIs5M

            fLen := 9
            sLen := 21
            rLen := 9
            dLen := 10
            aSmooth := 10
            sBars := 2
            aMin := 18.0

        else if mtfIs10M

            fLen := 10
            sLen := 24
            rLen := 10
            dLen := 10
            aSmooth := 10
            sBars := 2
            aMin := 18.0

        else if mtfIs15M

            fLen := 12
            sLen := 27
            rLen := 10
            dLen := 11
            aSmooth := 11
            sBars := 2
            aMin := 18.0

        else if mtfIs30M

            fLen := 15
            sLen := 34
            rLen := 11
            dLen := 12
            aSmooth := 12
            sBars := 2
            aMin := 18.0

        else if mtfIs60M

            fLen := 18
            sLen := 40
            rLen := 12
            dLen := 13
            aSmooth := 13
            sBars := 2
            aMin := 18.0

        else if mtfIs120M

            fLen := 21
            sLen := 45
            rLen := 13
            dLen := 13
            aSmooth := 13
            sBars := 3
            aMin := 18.5

        else if mtfIs180M

            fLen := 23
            sLen := 48
            rLen := 14
            dLen := 14
            aSmooth := 14
            sBars := 3
            aMin := 18.5

        else if mtfIs240M

            fLen := 24
            sLen := 50
            rLen := 14
            dLen := 14
            aSmooth := 14
            sBars := 3
            aMin := 19.0

        else

            fLen := 30
            sLen := 60
            rLen := 14
            dLen := 14
            aSmooth := 14
            sBars := 3
            aMin := 20.0


    //──────────────────────────────────────────────────────────────────
    // CORE
    //──────────────────────────────────────────────────────────────────

    eFast = ta.ema(close, fLen)
    eSlow = ta.ema(close, sLen)

    vwap = ta.vwap(hlc3)

    rsi = ta.rsi(close, rLen)

    [pDI, mDI, adx] =
         ta.dmi(dLen, aSmooth)


    //──────────────────────────────────────────────────────────────────
    // EMA MOMENTUM
    //──────────────────────────────────────────────────────────────────

    eBull =
         eFast > eSlow and
         eFast > eFast[1]

    eBear =
         eFast < eSlow and
         eFast < eFast[1]


    //──────────────────────────────────────────────────────────────────
    // EMA SEPARATION
    //──────────────────────────────────────────────────────────────────

    eDistance =
         math.abs(eFast - eSlow)

    eDistancePct =
         close != 0 ?
         eDistance / close * 100.0 :
         0.0

    eRequired =
         mtfIs1M ? 0.012 :
         mtfIs3M ? 0.010 :
         mtfIs5M ? 0.0 :
         mtfIs10M ? 0.006 :
         mtfIs15M ? 0.008 :
         mtfIs30M ? 0.010 :
         mtfIs60M ? 0.012 :
         mtfIs120M ? 0.013 :
         mtfIs180M ? 0.014 :
         mtfIs240M ? 0.015 :
         0.020

    eSeparated =
         not useEmaSeparation or
         eDistancePct >= eRequired


    //──────────────────────────────────────────────────────────────────
    // DMI
    //──────────────────────────────────────────────────────────────────

    dBull =
         pDI > mDI

    dBear =
         mDI > pDI


    //──────────────────────────────────────────────────────────────────
    // RSI
    //──────────────────────────────────────────────────────────────────

    rBull =
         rsi > rsiBuy and
         rsi > rsi[1]

    rBear =
         rsi < rsiSell and
         rsi < rsi[1]


    //──────────────────────────────────────────────────────────────────
    // ADX
    //──────────────────────────────────────────────────────────────────

    quality =
         adx >= aMin


    //──────────────────────────────────────────────────────────────────
    // VWAP
    //──────────────────────────────────────────────────────────────────

    vBull =
         close > vwap or
         close > close[1] and
         close > eFast

    vBear =
         close < vwap or
         close < close[1] and
         close < eFast


    //──────────────────────────────────────────────────────────────────
    // STRUCTURE
    //──────────────────────────────────────────────────────────────────

    rHigh =
         ta.highest(high[1], sBars)

    rLow =
         ta.lowest(low[1], sBars)

    bBreak =
         close > rHigh

    sBreak =
         close < rLow


    //──────────────────────────────────────────────────────────────────
    // REVERSAL
    //──────────────────────────────────────────────────────────────────

    rsiUp =
         ta.crossover(rsi, rsiBuy)

    diUp =
         ta.crossover(pDI, mDI)

    rsiDown =
         ta.crossunder(rsi, rsiSell)

    diDown =
         ta.crossover(mDI, pDI)

    bReversal =
         rsiUp or diUp

    sReversal =
         rsiDown or diDown


    //──────────────────────────────────────────────────────────────────
    // CANDLE
    //──────────────────────────────────────────────────────────────────

    cRange =
         high - low

    bCandle =
         close > open and
         cRange > 0 and
         close >= high - cRange * 0.35

    sCandle =
         close < open and
         cRange > 0 and
         close <= low + cRange * 0.35


    //──────────────────────────────────────────────────────────────────
    // NOISE
    //──────────────────────────────────────────────────────────────────

    bNoise =
         not useAdaptiveNoise or
         mtfIs5M or
         (
             close > eFast and
             eFast > eSlow
         )

    sNoise =
         not useAdaptiveNoise or
         mtfIs5M or
         (
             close < eFast and
             eFast < eSlow
         )


    //──────────────────────────────────────────────────────────────────
    // BUY
    //──────────────────────────────────────────────────────────────────

    bRoute1 =
         bBreak and
         eBull and
         rBull and
         dBull

    bRoute2 =
         bReversal and
         close > eFast and
         dBull and
         rsi > 50

    bCondition =
         quality and
         vBull and
         bCandle and
         eSeparated and
         bNoise and
         (bRoute1 or bRoute2)


    //──────────────────────────────────────────────────────────────────
    // SELL
    //──────────────────────────────────────────────────────────────────

    sRoute1 =
         sBreak and
         eBear and
         rBear and
         dBear

    sRoute2 =
         sReversal and
         close < eFast and
         dBear and
         rsi < 50

    sCondition =
         quality and
         vBear and
         sCandle and
         eSeparated and
         sNoise and
         (sRoute1 or sRoute2)


    //──────────────────────────────────────────────────────────────────
    // STATE
    //──────────────────────────────────────────────────────────────────

    var int state = 0

    bSignal =
         barstate.isconfirmed and
         bCondition and
         state != 1

    sSignal =
         barstate.isconfirmed and
         sCondition and
         state != -1

    if bSignal
        state := 1

    if sSignal
        state := -1

    state


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF REQUESTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sig1 =
     request.security(
         syminfo.tickerid,
         "1",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig3 =
     request.security(
         syminfo.tickerid,
         "3",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig5 =
     request.security(
         syminfo.tickerid,
         "5",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig10 =
     request.security(
         syminfo.tickerid,
         "10",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig15 =
     request.security(
         syminfo.tickerid,
         "15",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig30 =
     request.security(
         syminfo.tickerid,
         "30",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig1H =
     request.security(
         syminfo.tickerid,
         "60",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig2H =
     request.security(
         syminfo.tickerid,
         "120",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig3H =
     request.security(
         syminfo.tickerid,
         "180",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sig4H =
     request.security(
         syminfo.tickerid,
         "240",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sigD =
     request.security(
         syminfo.tickerid,
         "D",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sigW =
     request.security(
         syminfo.tickerid,
         "W",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )

sigMo =
     request.security(
         syminfo.tickerid,
         "M",
         f_mtfSignal(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off
     )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD POSITION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tablePosition =
     dashboardPosition == "Top Left" ?
         position.top_left :
     dashboardPosition == "Bottom Right" ?
         position.bottom_right :
     dashboardPosition == "Bottom Left" ?
         position.bottom_left :
         position.top_right


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD TABLE
//
// 15 columns:
// 13 timeframes + BIAS + spacer
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table mtfTable =
     table.new(
         tablePosition,
         15,
         3,
         border_width=1
     )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL TEXT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_signalText(int sig) =>
     sig == 1 ? "B" :
     sig == -1 ? "S" :
     "—"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL BACKGROUND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_signalBg(int sig) =>
     sig == 1 ?
         color.new(color.green, 15) :
     sig == -1 ?
         color.new(color.red, 15) :
         color.new(color.gray, 65)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OVERALL BIAS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buyCount =
     (sig1 == 1 ? 1 : 0) +
     (sig3 == 1 ? 1 : 0) +
     (sig5 == 1 ? 1 : 0) +
     (sig10 == 1 ? 1 : 0) +
     (sig15 == 1 ? 1 : 0) +
     (sig30 == 1 ? 1 : 0) +
     (sig1H == 1 ? 1 : 0) +
     (sig2H == 1 ? 1 : 0) +
     (sig3H == 1 ? 1 : 0) +
     (sig4H == 1 ? 1 : 0) +
     (sigD == 1 ? 1 : 0) +
     (sigW == 1 ? 1 : 0) +
     (sigMo == 1 ? 1 : 0)

sellCount =
     (sig1 == -1 ? 1 : 0) +
     (sig3 == -1 ? 1 : 0) +
     (sig5 == -1 ? 1 : 0) +
     (sig10 == -1 ? 1 : 0) +
     (sig15 == -1 ? 1 : 0) +
     (sig30 == -1 ? 1 : 0) +
     (sig1H == -1 ? 1 : 0) +
     (sig2H == -1 ? 1 : 0) +
     (sig3H == -1 ? 1 : 0) +
     (sig4H == -1 ? 1 : 0) +
     (sigD == -1 ? 1 : 0) +
     (sigW == -1 ? 1 : 0) +
     (sigMo == -1 ? 1 : 0)

activeCount =
     buyCount + sellCount

buyPercent =
     activeCount > 0 ?
     buyCount * 100.0 / activeCount :
     0.0

sellPercent =
     activeCount > 0 ?
     sellCount * 100.0 / activeCount :
     0.0

overallBias =
     activeCount == 0 ?
         "NO SIGNAL" :
     buyPercent >= 80 ?
         "STRONG BUY" :
     buyPercent >= 60 ?
         "BUY" :
     sellPercent >= 80 ?
         "STRONG SELL" :
     sellPercent >= 60 ?
         "SELL" :
         "MIXED"


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OVERALL BIAS COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

overallBg =
     overallBias == "STRONG BUY" ?
         color.green :
     overallBias == "BUY" ?
         color.new(color.green, 25) :
     overallBias == "STRONG SELL" ?
         color.red :
     overallBias == "SELL" ?
         color.new(color.red, 25) :
     overallBias == "MIXED" ?
         color.orange :
         color.gray


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD DRAW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.islast

    if showDashboard

        // Header row
        table.cell(
             mtfTable,
             0,
             0,
             "1m",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             1,
             0,
             "3m",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             2,
             0,
             "5m",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             3,
             0,
             "10m",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             4,
             0,
             "15m",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             5,
             0,
             "30m",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             6,
             0,
             "1h",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             7,
             0,
             "2h",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             8,
             0,
             "3h",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             9,
             0,
             "4h",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             10,
             0,
             "1D",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             11,
             0,
             "1W",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             12,
             0,
             "1Mo",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             13,
             0,
             "BIAS",
             text_color=color.white,
             bgcolor=color.new(color.black, 0),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             14,
             0,
             "",
             bgcolor=color.new(color.black, 100)
         )


        // Signal row
        table.cell(
             mtfTable,
             0,
             1,
             f_signalText(sig1),
             text_color=color.white,
             bgcolor=f_signalBg(sig1),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             1,
             1,
             f_signalText(sig3),
             text_color=color.white,
             bgcolor=f_signalBg(sig3),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             2,
             1,
             f_signalText(sig5),
             text_color=color.white,
             bgcolor=f_signalBg(sig5),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             3,
             1,
             f_signalText(sig10),
             text_color=color.white,
             bgcolor=f_signalBg(sig10),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             4,
             1,
             f_signalText(sig15),
             text_color=color.white,
             bgcolor=f_signalBg(sig15),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             5,
             1,
             f_signalText(sig30),
             text_color=color.white,
             bgcolor=f_signalBg(sig30),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             6,
             1,
             f_signalText(sig1H),
             text_color=color.white,
             bgcolor=f_signalBg(sig1H),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             7,
             1,
             f_signalText(sig2H),
             text_color=color.white,
             bgcolor=f_signalBg(sig2H),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             8,
             1,
             f_signalText(sig3H),
             text_color=color.white,
             bgcolor=f_signalBg(sig3H),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             9,
             1,
             f_signalText(sig4H),
             text_color=color.white,
             bgcolor=f_signalBg(sig4H),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             10,
             1,
             f_signalText(sigD),
             text_color=color.white,
             bgcolor=f_signalBg(sigD),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             11,
             1,
             f_signalText(sigW),
             text_color=color.white,
             bgcolor=f_signalBg(sigW),
             text_size=size.normal
         )

        table.cell(
             mtfTable,
             12,
             1,
             f_signalText(sigMo),
             text_color=color.white,
             bgcolor=f_signalBg(sigMo),
             text_size=size.normal
         )


        // Overall bias
        table.cell(
             mtfTable,
             13,
             1,
             showOverallBias ? overallBias : "",
             text_color=color.white,
             bgcolor=showOverallBias ? overallBg : color.new(color.black, 100),
             text_size=size.small
         )

        table.cell(
             mtfTable,
             14,
             1,
             "",
             bgcolor=color.new(color.black, 100)
         )


        // Count row
        table.cell(
             mtfTable,
             0,
             2,
             "B:" + str.tostring(buyCount),
             text_color=color.white,
             bgcolor=color.new(color.green, 65),
             text_size=size.tiny
         )

        table.cell(
             mtfTable,
             1,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             2,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             3,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             4,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             5,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             6,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             7,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             8,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             9,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             10,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             11,
             2,
             "",
             bgcolor=color.new(color.black, 100)
         )

        table.cell(
             mtfTable,
             12,
             2,
             "S:" + str.tostring(sellCount),
             text_color=color.white,
             bgcolor=color.new(color.red, 65),
             text_size=size.tiny
         )

        table.cell(
             mtfTable,
             13,
             2,
             str.tostring(buyPercent, "#") + "% B",
             text_color=color.white,
             bgcolor=color.new(color.black, 15),
             text_size=size.tiny
         )

        table.cell(
             mtfTable,
             14,
             2,
             str.tostring(sellPercent, "#") + "% S",
             text_color=color.white,
             bgcolor=color.new(color.black, 15),
             text_size=size.tiny
         )


    else

        // Clear dashboard
        for row = 0 to 2

            for col = 0 to 14

                table.cell(
                     mtfTable,
                     col,
                     row,
                     "",
                     bgcolor=color.new(color.black, 100)
                 )
````
