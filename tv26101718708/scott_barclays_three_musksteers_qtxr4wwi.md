# Scott Barclay's Three Musksteers

- url: https://www.tradingview.com/script/QTxR4wWi-Scott-Barclay-s-Three-Musksteers/
- type: strategy
- pine_id: PUB;26b397404fed4cca8ee49f1f1eba73fe
- version: 1.0

## Description

[b]Scott Barclay's Three Muskateers[/b]

Scott Barclay's Three Musketeers is a simple multi-condition strategy that looks for agreement between [b]trend[/b], [b]momentum[/b], and [b]price location[/b]. The idea is not to predict every move, but to wait for at least [b]2 out of 3[/b] conditions to align before a trade is considered.

This script was built to stay visually clean while still being easy to follow for newer users.

[b]How It Works[/b]

The strategy checks three separate signals on every bar:

[list]
[*][b]Trend[/b]: Uses the relationship between the [b]50 EMA[/b] and [b]200 EMA[/b]
[*][b]Momentum[/b]: Uses [b]RSI(14)[/b] crossing key levels
[*][b]Location / Reversion[/b]: Uses price interaction with [b]Bollinger Bands[/b]
[/list]

A [b]buy signal[/b] appears when at least [b]2 of the 3 bullish conditions[/b] are true.

A [b]sell signal[/b] appears when at least [b]2 of the 3 bearish conditions[/b] are true.

[b]The Three Conditions[/b]

[b]1. Trend Condition[/b]
[list]
[*]Bullish when the [b]50 EMA[/b] is above the [b]200 EMA[/b]
[*]Bearish when the [b]50 EMA[/b] is below the [b]200 EMA[/b]
[/list]

This gives the strategy a broad directional filter.

[b]2. RSI Reversal Condition[/b]
[list]
[*]Bullish when [b]RSI[/b] crosses above [b]30[/b]
[*]Bearish when [b]RSI[/b] crosses below [b]70[/b]
[/list]

This part looks for a momentum shift rather than a permanent overbought/oversold interpretation.

[b]3. Bollinger Band Reaction Condition[/b]
[list]
[*]Bullish when price crosses above the [b]lower Bollinger Band[/b]
[*]Bearish when price crosses below the [b]upper Bollinger Band[/b]
[/list]

This adds a price-location component, helping the script notice when price is reacting from an extreme area.

[b]Signal Logic[/b]

The strategy counts how many bullish and bearish conditions are active.

[list]
[*][b]Bull Count[/b] = Trend Bull + RSI Bull + Bollinger Bull
[*][b]Bear Count[/b] = Trend Bear + RSI Bear + Bollinger Bear
[/list]

If [b]Bull Count >= 2[/b], the script treats that as a buy signal.

If [b]Bear Count >= 2[/b], the script treats that as a sell signal.

This makes the strategy stricter than a single-indicator trigger, while still keeping the logic simple enough to inspect visually.

[b]Trade Direction Options[/b]

The script supports three operating modes:

[list]
[*][b]Long[/b] - only takes long trades
[*][b]Short[/b] - only takes short trades
[*][b]Both[/b] - allows both long and short entries
[/list]

This makes it easier to adapt the strategy to different markets, user preferences, or testing styles.

[b]Chart Markers[/b]

Optional [b]BUY[/b] and [b]SELL[/b] tags can be shown on the chart to help visualize where the raw signal conditions appeared.

These are turned [b]off by default[/b] so the chart stays less crowded, but they can be enabled in the settings.

[b]Trade Signal Box[/b]

The script also includes an optional [b]Trade Signal[/b] box.

When enabled, it displays a simple color block in the corner of the chart:

[list]
[*][b]Green[/b] for a buy-side trade event
[*][b]Red[/b] for a sell-side trade event
[*][b]White[/b] when neutral
[/list]

A hold-bars setting lets the signal remain visible for a short time after the event, which can be useful for visual review or OCR-based workflows.

[b]Bot / Alert Support[/b]

The script includes optional bot-style alert payloads that can send a structured [b]BUY[/b] or [b]SELL[/b] message when a trade event occurs.

This is available for users who want a more automated workflow, but it can also simply be left on the chart as a visual strategy.

[b]What This Strategy Tries To Do[/b]

At a high level, Scott Barclay's Three Musketeers tries to avoid reacting to only one piece of information. Instead, it asks for at least some agreement between:

[list]
[*]directional trend
[*]momentum shift
[*]price interaction with volatility structure
[/list]

That makes it more selective than a single-indicator system, while still being straightforward enough for manual review.

[b]A Few Honest Notes[/b]

[list]
[*]This strategy does [b]not[/b] guarantee profits.
[*]It will behave differently across symbols and timeframes.
[*]Some markets produce many signals, while others may produce very few.
[*]Smooth trending indexes may not trigger often because the conditions need to align on the same bar.
[*]Like any strategy, it can perform well in some environments and poorly in others.
[/list]

[b]Best Use[/b]

This script may be most useful for:

[list]
[*]learning how multi-condition strategies behave
[*]screening charts for moments where multiple factors align
[*]comparing long-only, short-only, and both-direction behavior
[*]building a cleaner workflow around trade-event visibility
[/list]

[b]Summary[/b]

Scott Barclay's Three Musketeers is a compact 2-out-of-3 confirmation strategy built from:

[list]
[*]EMA trend structure
[*]RSI momentum shifts
[*]Bollinger Band reactions
[/list]

It is meant to be simple enough to understand, flexible enough to test, and structured enough to keep one-indicator noise under control.

If you use it, it is best treated as a decision-support or testing tool rather than a promise of results.

## Source Code

````pine
//@version=6
strategy("Scott Barclay's Three Muskateers", overlay = true, margin_long = 0, margin_short = 0, calc_on_every_tick = true, pyramiding = 0, initial_capital = 10000, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, commission_type = strategy.commission.percent, commission_value = 0.1, slippage = 2)

input_group_signals = "Signal Settings"
input_group_display = "Display"
input_group_bot = "BOT CONTROL"

tradeDirection = input.string("Long", "Trade Direction", options = ["Long", "Short", "Both"], group = input_group_signals)
showBuySellSignals = input.bool(false, "Show Buy/Sell Tags", group = input_group_display)
showSignalStatusBox = input.bool(false, "Show Signal Status Box", group = input_group_display)
signalHoldBars = input.int(1, "Trade Signal Hold Bars", minval = 1, group = input_group_display)
enableBot = input.bool(true, "Enable Bot (Webhook)", group = input_group_bot)
chartPos = input.string("top", "Chart Position", options = ["top", "bottom"], group = input_group_bot)

emaFastLen = 50
emaSlowLen = 200
bbLen = 20
bbMult = 2.0

rsi = ta.rsi(close, 14)
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
basis = ta.sma(close, bbLen)
stdevVal = ta.stdev(close, bbLen)
dev = bbMult * stdevVal
upperBB = basis + dev
lowerBB = basis - dev

trendBull = emaFast > emaSlow
trendBear = emaFast < emaSlow
meanRevBull = ta.crossover(rsi, 30)
meanRevBear = ta.crossunder(rsi, 70)
arbBull = ta.crossover(close, lowerBB)
arbBear = ta.crossunder(close, upperBB)

bullCount = (trendBull ? 1 : 0) + (meanRevBull ? 1 : 0) + (arbBull ? 1 : 0)
bearCount = (trendBear ? 1 : 0) + (meanRevBear ? 1 : 0) + (arbBear ? 1 : 0)

buySignal = bullCount >= 2
sellSignal = bearCount >= 2
allowLong = tradeDirection == "Long" or tradeDirection == "Both"
allowShort = tradeDirection == "Short" or tradeDirection == "Both"
longOnly = tradeDirection == "Long"
shortOnly = tradeDirection == "Short"
bothDirections = tradeDirection == "Both"

plotshape(showBuySellSignals and allowLong and buySignal, title = "Buy Signal", location = location.belowbar, color = color.green, style = shape.labelup, text = "BUY")
plotshape(showBuySellSignals and allowShort and sellSignal, title = "Sell Signal", location = location.abovebar, color = color.red, style = shape.labeldown, text = "SELL")

openLongEvent = allowLong and buySignal and strategy.position_size <= 0
openShortEvent = allowShort and sellSignal and strategy.position_size >= 0
closeLongEvent = longOnly and sellSignal and strategy.position_size > 0
closeShortEvent = shortOnly and buySignal and strategy.position_size < 0

if closeLongEvent
    strategy.close("Long", comment = "Three Muskateers Sell")

if closeShortEvent
    strategy.close("Short", comment = "Three Muskateers Buy")

if openLongEvent
    strategy.entry("Long", strategy.long, comment = "Three Muskateers Buy")

if openShortEvent
    strategy.entry("Short", strategy.short, comment = "Three Muskateers Sell")

buyTradeEvent = openLongEvent or closeShortEvent
sellTradeEvent = openShortEvent or closeLongEvent

if enableBot and buyTradeEvent
    alert('{"action":"BUY","chart":"' + chartPos + '","symbol":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar)

if enableBot and sellTradeEvent
    alert('{"action":"SELL","chart":"' + chartPos + '","symbol":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar)

var int lastSignalBar = na
var color lastSignalBgColor = color.white

if buyTradeEvent
    lastSignalBar := bar_index
    lastSignalBgColor := color.green
else if sellTradeEvent
    lastSignalBar := bar_index
    lastSignalBgColor := color.red

signalActive = not na(lastSignalBar) and bar_index >= lastSignalBar and bar_index < lastSignalBar + signalHoldBars
signalDisplayBgColor = showSignalStatusBox ? (signalActive ? lastSignalBgColor : color.white) : color.new(color.white, 100)

if barstate.islast
    var table signalTable = table.new(position.top_right, 1, 2, border_width = 2)
    table.cell(
         signalTable, 0, 0, showSignalStatusBox ? "Trade Signal" : "",
         text_color = color.white,
         bgcolor    = showSignalStatusBox ? color.rgb(86, 86, 86) : color.new(color.white, 100),
         text_size  = size.large
     )
    table.cell(
         signalTable, 0, 1, "",
         text_color = color.white,
         bgcolor    = signalDisplayBgColor,
         text_size  = size.huge
     )
````
