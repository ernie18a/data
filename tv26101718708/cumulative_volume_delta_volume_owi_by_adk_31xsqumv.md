# Cumulative Volume Delta & Volume OWI By ADK

- url: https://www.tradingview.com/script/31XsQUmv-Cumulative-Volume-Delta-Volume-OWI-By-ADK/
- type: indicator
- pine_id: PUB;e5975885a2154240993955d0fc16b7c1
- version: 2.0

## Description

[b]Cumulative Volume Delta & Volume OWI By ADK[/b]
A powerful dual-purpose volume analysis tool that combines Cumulative Volume Delta (CVD) and Volume Order Wave Indicator (VOWI) in one script.
What does this indicator do?

[b]1. Cumulative Volume Delta (CVD)[/b]

Shows the net buying vs selling pressure using true volume delta calculation.

Blue candles = Buying dominance
Red candles = Selling dominance
Built using TradingView’s official ta.requestVolumeDelta() for higher accuracy
Supports both Time-based and 1 Tick aggregation (tick mode available on Expert plans)
Fully customizable Anchor Period and lower timeframe settings

[b]2. Volume OWI (Order Wave Indicator)[/b]

Visualizes Buy Volume vs Sell Volume as colored columns:

Green columns = Buy Volume
Red columns = Sell Volume (Total Volume)
Helps traders quickly see which side is more aggressive on each bar.

[b]Key Features[/b]

Toggle CVD and VOWI independently
Advanced CVD settings (Anchor Period, Data Aggregation, Custom Lower Timeframe)
Optional US Market Hours time filter for VOWI
Clean and optimized Pine Script v6 code
Works on all symbols that provide volume data

[b]How to use[/b]

Use CVD to track institutional buying/selling pressure and potential divergences with price.
Use VOWI to see real-time order flow strength (Buy vs Sell volume).
Best used on liquid instruments (stocks, futures, crypto with good volume).

[b]Recommended Settings:[/b]

[list]
[*]CVD Anchor: 1D or Session
[*]Data Aggregation: Time (or 1 Tick if available)
[*]VOWI: Enable Time Filter for US stocks/futures
[/list]


[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. Trading involves substantial risk of loss and is not suitable for every investor. Always do your own research and consult a qualified financial advisor before making any trading decisions. The authors and publishers of this script accept no liability for any losses incurred from its use.

[i]Developed by ADK Team[/i]

## Source Code

````pine
//@ Made by ADK Team
//Cumulative Volume Delta & Volume OWI Indicator
//@version=6
indicator("CVD By ADK", "CVD By ADK", format=format.volume)
import TradingView/ta/12
anchorInput = input.timeframe("1D", "Anchor Period")
dataAggregationTooltip = "Defines how lower timeframe data is aggregated for the delta calculation. \"1 tick\" computes the delta on tick data and is available only on expert plans."
dataAggregationInput = input.string("Time", "Data Aggregation", options = ["Time", "1 tick"], tooltip = dataAggregationTooltip)
useTicks = dataAggregationInput == "1 tick"
lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe."
 + " \n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(true, "Custom timeframe", tooltip = lowerTimeframeTooltip, active = not useTicks)
lowerTimeframeInput = input.timeframe("", "Timeframe", active = useCustomTimeframeInput and not useTicks)
var lowerTimeframe = switch
    useTicks => "1T"
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"

[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe, anchorInput)

col = lastVolume >= openVolume ? color.blue : color.red
hline(0)
plotcandle(openVolume, maxVolume, minVolume, lastVolume, "CVD", color = col, bordercolor = col, wickcolor = col)

var cumVol = 0.
cumVol += nz(volume)
deltaIsNa = na(openVolume) and na(maxVolume) and na(minVolume) and na(lastVolume)

if barstate.islast
    if cumVol == 0
        runtime.error("The data vendor doesn't provide volume data for this symbol.")
    if str.endswith(lowerTimeframe, "T") and deltaIsNa
        runtime.error("Not enough tick depth for the current anchor period. The available tick depth ends before reaching the start of the anchor period (" + anchorInput + "). Please shorten the 'Anchor period' input or switch the calculation base from '1 Tick' to 'Time' or higher custom timeframe.")

// === INPUTS === //
smaLength = input.int(20, title = 'SMA Length')
useTimeFilter = input.bool(true, title = 'Enable Time Filter')
startHour = input.int(9, title = 'Start Hour (ET)')
startMinute = input.int(45, title = 'Start Minute (ET)')
endHour = input.int(16, title = 'End Hour (ET)')
endMinute = input.int(15, title = 'End Minute (ET)')

// === VOLUME CALCULATIONS === //
buyVolume = high == low ? 0 : volume * (close - low) / (high - low)
sellVolume = high == low ? 0 : volume * (high - close) / (high - low)
//volumeSMA = ta.sma(volume, smaLength)

// === PLOTTING VOLUME === //
plot(volume, style = plot.style_columns, color = color.red, title = 'SELL V')
plot(buyVolume, style = plot.style_columns, color = color.green, title = 'BUY V')
//plot(volumeSMA, color = color.black, title = 'Total Volume SMA', linewidth = 2)

// === TIME FILTER (US MARKET HOURS) === //
startTime = timestamp('America/New_York', year, month, dayofmonth, startHour, startMinute)
endTime = timestamp('America/New_York', year, month, dayofmonth, endHour, endMinute)
isUSMarketTime = time >= startTime and time <= endTime

//// === HIGHLIGHT CONDITIONS === //
//highlightVPlus = volume > 1.5 * volumeSMA and volume <= 2 * volumeSMA and (not useTimeFilter or isUSMarketTime)
//highlightVPlusPlus = volume > 2 * volumeSMA and (not useTimeFilter or isUSMarketTime)

// === DYNAMIC COLOR BASED ON BUY/SELL VOLUME === //
shapeColor = buyVolume > sellVolume ? color.green : color.red
labelColor = shapeColor

// === LABEL ABOVE VOLUME BAR === //
// labelY = volume + volume * 0.3
// if highlightVPlus
//     label.new(bar_index, labelY, 'V+', style = label.style_label_down, color = labelColor, textcolor = color.white, size = size.small)
//     if highlightVPlusPlus
//         label.new(bar_index, labelY, 'V++', style = label.style_label_down, color = labelColor, textcolor = color.white, size = size.small)
````
