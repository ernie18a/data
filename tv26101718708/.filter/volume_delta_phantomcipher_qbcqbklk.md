# Volume Delta [PhantomCipher]

- url: https://www.tradingview.com/script/qbCqBKLK-Volume-Delta-PhantomCipher/
- type: indicator
- pine_id: PUB;1b831255f3a145a1bf9d567a7f92d294
- version: 1.0

## Description

[b]Volume Delta[/b]

Volume Delta shows each candle's volume together with an estimate of whether buyers or sellers were in control of it. The delta (buying volume minus selling volume) is drawn inside the volume column, so you can compare the two at a glance.

SNAPSHOT: a 15m chart with the indicator in its pane, showing volume columns with delta columns inside them

[b]Shown on the 15-minute chart[/b]
The snapshots use the 15-minute timeframe. On that chart, each candle's delta is built from its fifteen 1-minute candles, which gives enough detail to separate real buying or selling pressure from noise while staying readable.

[b]How it works[/b]
[list]
[*][b]Volume column:[/b] the full volume of the candle. It's green when the candle closed at or above its open and red when it closed below.
[*][b]Delta column:[/b] drawn inside the volume column. Its height is the size of the delta, and its colour is the side that won: green when buying volume was greater and red when selling volume was greater.
[*][b]How delta is estimated:[/b] each candle is broken into smaller candles from a lower timeframe. The volume of each smaller candle is counted as buying or selling according to its direction, and the delta is the difference between the two totals.
[/list]

A large delta column means one side clearly dominated the candle. A small one inside a tall volume column means buying and selling were close to balanced, even though a lot traded.

[b]Lower timeframe used[/b]
[list]
[*]Seconds charts: 1 second
[*]Minute and hour charts, including 15m: 1 minute
[*]Daily charts: 5 minutes
[*]Weekly and monthly charts: 1 hour
[/list]

The lower timeframe is picked for you from the chart's timeframe:
[pine]
[openVolume, maxVolume, minVolume, deltaVolume] = ta.requestVolumeDelta(lowerTimeframe)
[/pine]

SNAPSHOT: a 15m close-up where a tall volume column has a small delta column, next to one where the delta fills most of the column

[b]Settings[/b]
[list]
[*][b]Render Mode:[/b] [i]Delta Highlight[/i] (default) draws volume with the delta inside it. [i]Standard[/i] draws volume columns only.
[/list]

[b]Limitations[/b]
[list]
[*]Delta is an estimate built from lower-timeframe candles, not from individual trades, so it can differ from order-flow tools that use tick data.
[*]TradingView limits how much lower-timeframe data a script can load, so delta may be missing on older candles, especially on higher timeframes.
[*]The symbol must have volume data. If the data vendor provides none, the indicator shows an error instead of an empty pane.
[/list]

Example chart: [symbol="BYBIT:BTCUSDT.P"]BYBIT:BTCUSDT.P[/symbol]

[i]This indicator estimates buying and selling pressure. It's not a trading signal on its own, so combine it with your own analysis and risk management.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © phantomcipher

//@version=6
indicator("Volume Delta [PhantomCipher]", format = format.volume)

import TradingView/ta/8

// Style
renderModeInput = input.string("Delta Highlight", "Render Mode", options = ["Delta Highlight", "Standard"], group = "Style", display = display.none)

var lowerTimeframe = switch
    timeframe.isseconds  => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily    => "5"
    => "60"

// [openVolume, maxVolume, minVolume, lastVolume] approximate up/down volume on the lower timeframe;
// lastVolume is the net buy/sell delta for the bar, used only to pick the column color.
[openVolume, maxVolume, minVolume, deltaVolume] = ta.requestVolumeDelta(lowerTimeframe)

var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")

volumeColor = close >= open ? color.new(#089981, 50) : color.new(#f23645, 50)
deltaColor  = deltaVolume >= 0 ? #26a69a : #ef5350

showDeltaCore  = renderModeInput == "Delta Highlight"
deltaMagnitude = showDeltaCore ? math.min(math.abs(deltaVolume), volume) : na

plot(volume, title = "Volume", style = plot.style_columns, color = volumeColor)
plot(deltaMagnitude, title = "Delta", style = plot.style_columns, color = deltaColor)
````
