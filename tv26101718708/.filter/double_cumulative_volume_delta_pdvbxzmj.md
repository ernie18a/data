# Double Cumulative Volume Delta

- url: https://www.tradingview.com/script/pdvbXzmj-Double-Cumulative-Volume-Delta/
- type: indicator
- pine_id: PUB;64e9278909e34df494cf6f12f9e5b4fa
- version: 1.0

## Description

Double Cumulative Volume Delta, made to make trading easier with less indicators, you can add for example a high anchored time frame with a low one and combine it with VWAP to take winning trades easily

## Source Code

````pine
//@version=6
indicator("Double Cumulative Volume Delta", "Double CVD", format=format.volume)

// IMPORT
import TradingView/ta/8

// ─────────────────────────────
// FIRST CVD SETTINGS
// ─────────────────────────────
group1 = "CVD 1"

anchorInput1 = input.timeframe("1D", "Anchor period", group=group1)

lowerTimeframeTooltip1 = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation."

useCustomTimeframeInput1 = input.bool(false, "Use custom timeframe", tooltip=lowerTimeframeTooltip1, group=group1)

lowerTimeframeInput1 = input.timeframe("1", "Custom timeframe", active=useCustomTimeframeInput1, group=group1)

var lowerTimeframe1 = switch
    useCustomTimeframeInput1 => lowerTimeframeInput1
    timeframe.isseconds      => "1S"
    timeframe.isintraday     => "1"
    timeframe.isdaily        => "5"
    => "60"

[openVolume1, maxVolume1, minVolume1, lastVolume1] = ta.requestVolumeDelta(lowerTimeframe1, anchorInput1)

col1 = lastVolume1 >= openVolume1 ? color.teal : color.red


// ─────────────────────────────
// SECOND CVD SETTINGS
// ─────────────────────────────
group2 = "CVD 2"

anchorInput2 = input.timeframe("1W", "Anchor period", group=group2)

lowerTimeframeTooltip2 = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation."

useCustomTimeframeInput2 = input.bool(false, "Use custom timeframe", tooltip=lowerTimeframeTooltip2, group=group2)

lowerTimeframeInput2 = input.timeframe("5", "Custom timeframe", active=useCustomTimeframeInput2, group=group2)

var lowerTimeframe2 = switch
    useCustomTimeframeInput2 => lowerTimeframeInput2
    timeframe.isseconds      => "1S"
    timeframe.isintraday     => "1"
    timeframe.isdaily        => "5"
    => "60"

[openVolume2, maxVolume2, minVolume2, lastVolume2] = ta.requestVolumeDelta(lowerTimeframe2, anchorInput2)

col2 = lastVolume2 >= openVolume2 ? color.blue : color.orange


// ─────────────────────────────
// PLOTS
// ─────────────────────────────
hline(0, "Zero Line")

// FIRST CVD
plotcandle(
     openVolume1,
     maxVolume1,
     minVolume1,
     lastVolume1,
     title="CVD 1",
     color=col1,
     bordercolor=col1,
     wickcolor=col1)

// SECOND CVD
plotcandle(
     openVolume2,
     maxVolume2,
     minVolume2,
     lastVolume2,
     title="CVD 2",
     color=col2,
     bordercolor=col2,
     wickcolor=col2)


// ─────────────────────────────
// VOLUME CHECK
// ─────────────────────────────
var cumVol = 0.
cumVol += nz(volume)

if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
