# Cumulative Volume Delta

- url: https://www.tradingview.com/script/WZA1QyN1-Cumulative-Volume-Delta/
- type: indicator
- pine_id: PUB;466de004c7ad42b09705fb3ab28b39e1
- version: 1.0

## Description

Plots the cumulative volume delta based on lower timeframe data to approximate buying vs. selling pressure.
The indicator aggregates volume imbalances over a chosen anchor period and displays them as a continuous line.

Positive slope → buying pressure
Negative slope → selling pressure

Includes optional lower timeframe precision for more accurate delta estimation.

## Source Code

````pine
//@version=6
indicator("Cumulative Volume Delta", "CVD", format=format.volume)

import TradingView/ta/8

anchorInput = input.timeframe("1D", "Anchor period")
lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe."
 + " \n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(false, "Use custom timeframe", tooltip = lowerTimeframeTooltip)
lowerTimeframeInput = input.timeframe("1", "Timeframe", active = useCustomTimeframeInput)

var lowerTimeframe = switch
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"


[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe, anchorInput)

hline(0)
plot(lastVolume, "CVD", color=color.yellow, linewidth=2)

var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
