# Average True Range Percent

- url: https://www.tradingview.com/script/rFlCfVUA-Average-True-Range-Percent/
- type: indicator
- pine_id: PUB;b6e8e8056af24c57b84f5463807c90be
- version: 1.0

## Description

ATRP expresses Average True Range as a percentage of price instead of an absolute value. Raw ATR is denominated in price, so it can't be used to compare volatility across instruments trading at different price levels — a $10 stock and a $400 stock will have very different ATR values even if they move by the same relative amount. Dividing ATR by close (×100) normalizes it into a percentage, making volatility comparable across any symbol, timeframe, or asset class.

[b]How It's Calculated[/b]
True range is smoothed with a selectable moving average rather than a fixed method, so you can match the indicator's responsiveness to your own style.

[b]Settings[/b]
[list]
[*]ATR Lookback Period — number of bars used in the smoothing calculation (default 14).
[*]ATR Smoothing — RMA, SMA, EMA, or WMA (default RMA, the classic Wilder smoothing used by standard ATR).
[*]ATR Timeframe — calculate ATR on the chart's own timeframe, or pin it to a fixed timeframe (ticks, seconds, minutes, hours, days, weeks, or months) regardless of what chart resolution you're viewing. Useful for gauging a higher-timeframe's volatility while trading a lower one.
[*]Wait for Timeframe Closes — only relevant when ATR Timeframe differs from the chart. Off: the value updates live with the still-forming higher-timeframe bar (can repaint on historical reloads). On: the value only updates once the selected timeframe's bar has actually closed (no repainting, one-bar lag).
[/list]

## Source Code

````pine
//@version=6

indicator("Average True Range Percent", shorttitle="ATRP", overlay=false)

// Inputs
atrLookback = input.int(14, title="ATR Lookback Period")
smoothingType = input.string("RMA", options=["RMA", "SMA", "EMA", "WMA"], title="ATR Smoothing")
atrTimeframe = input.string("Chart", title="ATR Timeframe", options=["Chart", "1 tick", "10 ticks", "100 ticks", "1000 ticks", "1 second", "5 seconds", "10 seconds", "15 seconds", "30 seconds", "45 seconds", "1 minute", "2 minutes", "3 minutes", "5 minutes", "15 minutes", "30 minutes", "45 minutes", "1 hour", "2 hours", "3 hours", "4 hours", "1 day", "1 week", "1 month", "3 months", "6 months", "12 months"], group="Calculation")
waitForClose = input.bool(false, title="Wait for Timeframe Closes", group="Calculation")

// ATR Logic
toTimeframe(tf) =>
    switch tf
        "1 tick" => "1T"
        "10 ticks" => "10T"
        "100 ticks" => "100T"
        "1000 ticks" => "1000T"
        "1 second" => "1S"
        "5 seconds" => "5S"
        "10 seconds" => "10S"
        "15 seconds" => "15S"
        "30 seconds" => "30S"
        "45 seconds" => "45S"
        "1 minute" => "1"
        "2 minutes" => "2"
        "3 minutes" => "3"
        "5 minutes" => "5"
        "15 minutes" => "15"
        "30 minutes" => "30"
        "45 minutes" => "45"
        "1 hour" => "60"
        "2 hours" => "120"
        "3 hours" => "180"
        "4 hours" => "240"
        "1 day" => "1D"
        "1 week" => "1W"
        "1 month" => "1M"
        "3 months" => "3M"
        "6 months" => "6M"
        "12 months" => "12M"
        => ""

atrSmoothing(smoothType, src, length) =>
    switch smoothType
        "SMA" => ta.sma(src, length)
        "EMA" => ta.ema(src, length)
        "WMA" => ta.wma(src, length)
        => ta.rma(src, length)

atrExpression = atrSmoothing(smoothingType, ta.tr(true), atrLookback)
atrLive = request.security(syminfo.tickerid, toTimeframe(atrTimeframe), atrExpression)
atrConfirmed = request.security(syminfo.tickerid, toTimeframe(atrTimeframe), atrExpression[1], lookahead=barmerge.lookahead_on)
atrValue = waitForClose ? atrConfirmed : atrLive
atrp = (atrValue/close)*100
plot(atrp, color=color.red, linewidth=1)
````
