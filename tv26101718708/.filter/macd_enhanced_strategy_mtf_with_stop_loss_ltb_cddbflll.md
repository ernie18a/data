# MACD Enhanced Strategy MTF with Stop Loss [LTB]

- url: https://www.tradingview.com/script/CDdBFLLL-MACD-Enhanced-Strategy-MTF-with-Stop-Loss-LTB/
- type: strategy
- pine_id: PUB;73b1fc1635284c25a0cb25498c337111
- version: 1.0

## Description

Test strategy for MACD 

This strategy, named "MACD Enhanced Strategy MTF with Stop Loss [LTB]," is a modified Moving Average Convergence Divergence (MACD) strategy with enhancements such as multi-timeframe (MTF) analysis, custom scoring, and a dynamic stop loss mechanism. Let’s break down how to effectively use it:

Key Elements of the Strategy

MACD Indicator with Modifications:

The strategy uses MACD, a well-known momentum indicator, with customizable parameters:
fastLength, slowLength, and signalLength represent the standard MACD settings.
Instead of relying solely on MACD crossovers, it introduces scoring parameters for histogram direction (histside), indicator direction (indiside), and signal cross (crossscore). This allows for a more nuanced decision-making process when determining buy and sell signals.

Multi-Timeframe Analysis (MTF):

The strategy compares the current timeframe's MACD score with that of a higher timeframe (HTF). It dynamically selects the higher timeframe based on the current timeframe. For example, if the current chart period is 1, it will select 5 as the higher timeframe.
This MTF approach aims to align trades with broader trends, filtering out false signals that could be present when analyzing only a single timeframe.

Scoring System:

A custom scoring system (count() function) is used to evaluate buy and sell signals. This includes calculations based on the direction and momentum of MACD (indi) and the histogram. The score is used to determine the strength of signals.
Positive scores indicate bullish sentiment, while negative scores indicate bearish sentiment.
This scoring mechanism aims to reduce the influence of noise and provide more reliable entries.

Entry Conditions:

Long Condition: When the Result value (a combination of MTF and current MACD analysis) changes and becomes positive, a long entry is triggered.
Short Condition: When the Result changes and becomes negative, a short entry is initiated.

Stop Loss Mechanism:

The countstop() function calculates dynamic stop loss values for both long and short trades. It is based on the Average True Range (ATR) multiplied by a factor (Mult), providing adaptive stop loss levels depending on market volatility.
The stop loss is plotted on the chart to show potential risk levels for open trades, with the line appearing only if shotsl is enabled.

How to Use the Strategy
To properly use the strategy, follow these steps:

Parameter Optimization:

Adjust the input parameters such as fastLength, slowLength, and signalLength to tune the MACD indicator to the specific asset you’re trading. The values provided are typical defaults, but optimizing these values based on backtesting can help improve performance.
Customize the scoring parameters (crossscore, indiside, histside) to balance how much weight you want to put on the direction, histogram, and cross events of the MACD indicator.

Select Appropriate Timeframes:

This strategy employs a multi-timeframe (MTF) approach, so it's important to understand how the higher timeframe (HTF) is selected based on the current timeframe. For instance, if you are trading on a 5-minute chart, the higher timeframe will be 15 minutes, which helps filter out lower timeframe noise.
Ensure you understand the relationship between the timeframe you’re using and the HTF it automatically selects. The strategy’s effectiveness can vary depending on how these timeframes align with the asset’s overall volatility.
Run Backtests:

Always backtest the strategy over historical data to determine its reliability for the asset and timeframes you’re interested in. Note that the MTF approach may require substantial data to capture how different timeframes interact.
Use the backtest results to adjust the scoring parameters or the Stop Loss Factor (Mult) for better risk management.

Stop Loss Usage:

The stop loss is calculated dynamically using ATR, which means that it adjusts with changing volatility. This can be useful to avoid being stopped out too often during periods of increased volatility.
The shotsl parameter can be set to true to visualize the stop loss line on the chart. This helps to monitor the protection level and make better decisions regarding holding or closing a trade manually.

Entry Signals and Trade Execution:

Look for changes in the Result value to determine entry points. For a long position, the Result needs to become positive, and for a short position, it must be negative.
Note that the strategy's entries are more conservative because it waits for the Result to confirm the direction using multiple factors, which helps filter out false breakouts.

Risk Management:

The adaptive stop loss mechanism reduces the risk by basing the stop level on market volatility. However, you must still consider additional risk management practices such as position sizing and profit targets.
Given the scoring mechanism, it might not enter trades frequently, which means using this strategy may result in fewer but potentially more accurate trades. It’s important to be patient and not force trades that don’t align with the calculated results.
Real-Time Monitoring:

Make sure to monitor trades actively. Since the strategy recalculates the score on each bar, real-time changes in the Result value could provide exit opportunities even if the stop loss isn't triggered.

[b]Summary[/b]
The "MACD Enhanced Strategy MTF with Stop Loss [LTB]" is a sophisticated version of the MACD strategy, enhanced with multi-timeframe analysis and adaptive stop loss. Properly using it involves optimizing MACD and scoring parameters, selecting suitable timeframes, and actively managing entries and exits based on a combination of scoring and volatility-based stop losses. Always conduct thorough backtesting before applying it in a live environment to ensure the strategy performs well on the asset you're trading.

## Source Code

````pine
//@version=5
strategy("MACD Enhanced Strategy MTF with Stop Loss [LTB]", overlay=true)

// Input Parameters
fastLength = input.int(12, title="MACD Fast Length", minval=1)
slowLength = input.int(26, title="MACD Slow Length", minval=1)
signalLength = input.int(9, title="MACD Signal Length", minval=1)
crossscore = input.float(10, title="Cross (buy/sell) Score")
indiside = input.float(8, title="Indicator Direction Score")
histside = input.float(2, title="Histogram Direction Score")
shotsl = input.bool(false, title="Show Stop Loss Line")
Mult = input.float(1.2, title="Stop Loss Factor", minval=0.1, maxval=100)
Period = input.int(10, title="Stop Loss Period", minval=1, maxval=100)
lookaheadi = input.bool(true, title="Lookahead")

// Higher Time Frame Selection
var string HTF = ''
if (timeframe.period == '1')
    HTF := '5'
else if (timeframe.period == '3')
    HTF := '15'
else if (timeframe.period == '5')
    HTF := '15'
else if (timeframe.period == '15')
    HTF := '60'
else if (timeframe.period == '30')
    HTF := '60'
else if (timeframe.period == '45')
    HTF := '60'
else if (timeframe.period == '60')
    HTF := '240'
else if (timeframe.period == '120')
    HTF := '240'
else if (timeframe.period == '180')
    HTF := '240'
else if (timeframe.period == '240')
    HTF := 'D'
else if (timeframe.period == 'D')
    HTF := 'W'
else
    HTF := 'W'

var float calc = na
if (timeframe.period == '1')
    calc := 5
else if (timeframe.period == '3')
    calc := 5
else if (timeframe.period == '5')
    calc := 3
else if (timeframe.period == '15')
    calc := 4
else if (timeframe.period == '30')
    calc := 4
else if (timeframe.period == '45')
    calc := 4
else if (timeframe.period == '60')
    calc := 4
else if (timeframe.period == '120')
    calc := 3
else if (timeframe.period == '180')
    calc := 3
else if (timeframe.period == '240')
    calc := 6
else if (timeframe.period == 'D')
    calc := 5
else
    calc := 1

// Scoring Function
count() =>
    indi = ta.ema(close, fastLength) - ta.ema(close, slowLength)
    signal = ta.ema(indi, signalLength)
    hist = indi - signal
    Anlyse = 0.0
    Anlyse += indi > indi[1] ? (hist > hist[1] ? indiside + histside : indiside) : (hist == hist[1] ? indiside : indiside - histside)
    Anlyse += indi < indi[1] ? (hist < hist[1] ? -(indiside + histside) : -indiside) : (hist == hist[1] ? -indiside : -(indiside - histside))
    Anlyse += indi == indi[1] ? (hist > hist[1] ? histside : (hist < hist[1] ? -histside : 0)) : 0
    countcross = indi >= signal and indi[1] < signal[1] ? crossscore : (indi <= signal and indi[1] > signal[1] ? -crossscore : 0.0)
    countcross += nz(countcross[1]) * 0.6
    Anlyse += countcross
    nz(Anlyse)

// Calculate Scores
Anlys = count()
AnlysHfrm = request.security(syminfo.tickerid, HTF, count(), lookahead = (lookaheadi ? barmerge.lookahead_on : barmerge.lookahead_off))
Result = (AnlysHfrm * calc + Anlys) / (calc + 1)

// Entry Conditions
longCondition = ta.change(Result) != 0 and Result > 0
shortCondition = ta.change(Result) != 0 and Result < 0

if (longCondition)
    strategy.entry("MACD Long", strategy.long)

if (shortCondition)
    strategy.entry("MACD Short", strategy.short)

// Stop Loss Calculation
countstop(pos) =>
    Upt = hl2 - Mult * ta.atr(Period)
    Dnt = hl2 + Mult * ta.atr(Period)
    var float TUp = na
    var float TDown = na
    TUp := close[1] > nz(TUp[1]) ? math.max(Upt, nz(TUp[1])) : Upt
    TDown := close[1] < nz(TDown[1]) ? math.min(Dnt, nz(TDown[1])) : Dnt
    tslmtf = pos == 1 ? TUp : TDown
    tslmtf

pos = longCondition ? 1 : -1
var float stline = na
countstop__1 = countstop(pos)
security_1 = request.security(syminfo.tickerid, HTF, countstop__1)
stline := ta.change(time(HTF)) != 0 or longCondition or shortCondition ? security_1 : nz(stline[1])
plot(stline, color=shotsl ? color.gray : na, style=plot.style_line, linewidth=2, title="Stop Loss")
````
