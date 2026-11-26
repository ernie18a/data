# ATR Multi Time Frame Display

- url: https://www.tradingview.com/script/aigGA4Rw-ATR-Multi-Time-Frame-Display/
- type: indicator
- pine_id: PUB;f0fa43c708f74634875f8cb8d45642e3
- version: 1.0

## Description

An updated version to the simple ATR display. This updated version now give you an option to toggle on the 1 min ATR no matter what time frame you swap to. This also has an option to choose between RMA, SMA, EMA, or WMA. The smoothing method averages those True Range values over your chosen length, like 14 candles.
[b]RMA[/b]
This is TradingView’s default ATR style and the classic Wilder ATR. It reacts smoothly without being too jumpy. If you’re unsure, start here. Good for general trading, stops, and position sizing.
[b]SMA[/b]
Simple average. Every candle in the lookback has equal weight. It can feel a bit clunky because old high-volatility candles stay in the average until they suddenly drop off. Useful if you want a very plain “last 14 bars average range” reading.
[b]EMA[/b]
More weight on recent candles, so it reacts faster when volatility expands or contracts. Good if you scalp, trade breakouts, or want stops/targets to adjust quickly. Downside: it can get jumpier.
[b]WMA[/b]
Also weights recent candles more, often even more directly than EMA over the lookback. It can be responsive and clean, but may be too sensitive for some traders.

RMA is the best default because it’s the standard ATR most traders expect. If you find it lags too much on the 1-minute ATR, try EMA next.

## Source Code

````pine
//@version=6
indicator("ATR Display", overlay=true)

atrLength = input.int(14, "ATR Length", minval=1)
atrSmoothing = input.string("RMA", "ATR Smoothing", options=["RMA", "SMA", "EMA", "WMA"])
showOneMinuteAtr = input.bool(true, "Also Show 1 Minute ATR")
displayPosition = input.string("Top Right", "Display Position", options=["Top Right", "Bottom Right", "Bottom Center", "Bottom Left"])

f_ma(source, length) =>
    switch atrSmoothing
        "RMA" => ta.rma(source, length)
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "WMA" => ta.wma(source, length)

f_atr(length) =>
    f_ma(ta.tr(true), length)

chartAtr = f_atr(atrLength)
oneMinuteAtr = request.security(syminfo.tickerid, "1", f_atr(atrLength), barmerge.gaps_off, barmerge.lookahead_off)

tablePosition = switch displayPosition
    "Top Right" => position.top_right
    "Bottom Right" => position.bottom_right
    "Bottom Center" => position.bottom_center
    "Bottom Left" => position.bottom_left

chartTfLabel = timeframe.period
atrText = "ATR " + chartTfLabel + "(" + str.tostring(atrLength) + "): " + str.tostring(chartAtr, format.mintick)
oneMinText = "1m ATR(" + str.tostring(atrLength) + "): " + str.tostring(oneMinuteAtr, format.mintick)

var table atrTable = na

if barstate.islast
    if not na(atrTable)
        table.delete(atrTable)
    atrTable := table.new(tablePosition, 1, showOneMinuteAtr ? 2 : 1)
    table.cell(atrTable, 0, 0, atrText, text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.normal)
    if showOneMinuteAtr
        table.cell(atrTable, 0, 1, oneMinText, text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.normal)
````
